import { Type } from "@earendil-works/pi-ai";
import { defineTool, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "../..");
const cli = resolve(root, "tools/wc3-workshop/wc3.py");
const actions = ["doctor", "sources", "objects", "imports"] as const;
const kinds = ["unit", "item", "ability", "destructable", "doodad", "buff", "upgrade"] as const;
const limit = 64 * 1024;
const messages = {
  arguments: "Invalid action, fields or action-specific arguments.",
  cancelled: "Inspection cancelled.",
  deadline: "Inspection exceeded its execution deadline.",
  output: "Inspector output exceeds the tool limit; inspect a narrower input.",
  protocol: "Inspector returned an invalid evidence envelope.",
  process: "Inspector process failed without valid rejection evidence.",
};

function fail(code: keyof typeof messages): never {
  throw new Error(`[wc3_workshop:${code}] ${messages[code]}`);
}

function record(value: unknown): value is Record<string, any> {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

function pathArgument(value: unknown): value is string {
  return typeof value === "string" && value.length > 0 && value.length <= 4096 && !value.includes("\0");
}

function argumentsFor(params: unknown): string[] {
  // Revalidate at execution: Pi tool_call hooks can mutate already-validated input.
  if (!record(params) || !actions.includes(params.action) ||
      Object.keys(params).some(key => !["action", "path", "config", "kind"].includes(key))) fail("arguments");
  if (params.action === "doctor") {
    if ("path" in params || "kind" in params || ("config" in params && !pathArgument(params.config))) fail("arguments");
    return params.config === undefined ? ["doctor"] : ["doctor", `--config=${params.config}`];
  }
  if (!pathArgument(params.path) || "config" in params) fail("arguments");
  if (params.action === "objects") {
    if (!kinds.includes(params.kind)) fail("arguments");
    return ["objects", params.kind, "--", params.path];
  }
  if ("kind" in params) fail("arguments");
  return [params.action, "--", params.path];
}

const pathSchema = Type.String({ minLength: 1, maxLength: 4096,
  description: "Existing WDev-contained path; CLI enforces canonical containment and bounds." });
const outputSchema = Type.Object({
  schema_version: Type.Literal(1), ok: Type.Boolean(), action: Type.String(),
  target: Type.Literal("Warcraft III Classic 1.27b"),
  evidence: Type.Union([Type.Literal("Scanned"), Type.Literal("Rejected")]),
  limitations: Type.Array(Type.String()), result: Type.Any(),
  error: Type.Union([Type.Null(), Type.Object({ code: Type.String(), message: Type.String() })]),
});

function parseEnvelope(stdout: string, action: string, code: number) {
  let value: unknown;
  try { value = JSON.parse(stdout); } catch { fail("protocol"); }
  const keys = ["schema_version", "ok", "action", "target", "evidence", "limitations", "result", "error"];
  if (!record(value) || Object.keys(value).length !== keys.length ||
      !keys.every(key => Object.hasOwn(value, key)) || value.schema_version !== 1 ||
      value.action !== action || value.target !== "Warcraft III Classic 1.27b" ||
      !Array.isArray(value.limitations) || value.limitations.length === 0 ||
      !value.limitations.every((item: unknown) => typeof item === "string")) fail("protocol");
  if (code === 0) {
    if (value.ok !== true || value.evidence !== "Scanned" || value.error !== null || !record(value.result)) fail("protocol");
  } else if (value.ok !== false || value.evidence !== "Rejected" || value.result !== null ||
             !record(value.error) || typeof value.error.code !== "string" || typeof value.error.message !== "string") {
    fail("protocol");
  }
  return value;
}

export default function (pi: ExtensionAPI) {
  pi.registerTool(defineTool({
    name: "wc3_workshop",
    label: "Classic Warcraft workshop",
    description: "Read-only Warcraft III Classic 1.27b inspection: doctor, lexical sources, seven extracted v2 object kinds, " +
      "or extracted imports. No MPQ opening, full vJASS semantics, compilation or game launch. " +
      "10-second execution timeout; 64 KiB combined process output limit. Narrow inputs if oversized.",
    annotations: { readOnlyHint: true, destructiveHint: false, idempotentHint: true, openWorldHint: false },
    parameters: Type.Object({
      action: Type.Union(actions.map(action => Type.Literal(action))),
      path: Type.Optional(pathSchema),
      config: Type.Optional(Type.String({ minLength: 1, maxLength: 4096,
        description: "doctor only: optional project-contained profile; never an external config." })),
      kind: Type.Optional(Type.Union(kinds.map(kind => Type.Literal(kind)))),
    }, { additionalProperties: false }),
    outputSchema,
    async execute(_id, params, signal) {
      if (signal?.aborted) fail("cancelled");
      const args = argumentsFor(params);
      let result;
      try {
        result = await pi.exec("/usr/bin/python3", ["-B", cli, ...args], { cwd: root, timeout: 10_000, signal });
      } catch {
        if (signal?.aborted) fail("cancelled");
        fail("process");
      }
      if (signal?.aborted) fail("cancelled");
      if (result.killed) fail("deadline");
      if (Buffer.byteLength(result.stdout) + Buffer.byteLength(result.stderr) > limit) fail("output");
      if (result.code !== 0 && result.code !== 2) fail("process");
      if (result.stderr !== "") fail("protocol");
      const evidence = parseEnvelope(result.stdout, params.action, result.code);
      return { content: [{ type: "text", text: JSON.stringify(evidence) }], details: evidence,
        structuredContent: evidence, isError: !evidence.ok };
    },
  }));
}
