using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using Wc3.GameData;
using War3Net.IO.Mpq;

var game = args[0];
var results = new List<object>();
void Check(string name, bool ok, object? detail = null) {
    results.Add(new { name, ok, detail });
    Console.WriteLine(JsonSerializer.Serialize(new { name, ok, detail }));
    if (!ok) Environment.ExitCode = 1;
}
using (var source = new ClassicMpqGameDataSource(game)) {
    foreach (var name in new[] { @"Scripts\common.j", @"Scripts\Blizzard.j", @"Units\UnitMetaData.slk", @"Units\AbilityMetaData.slk", @"UI\TriggerData.txt", @"units\human\Footman\Footman.mdx" }) {
        var bytes = source.ReadFile("war3.w3mod:" + name);
        Check("read:" + name, bytes is {Length: >0}, bytes is null ? null : new { bytes = bytes.Length, sha256 = Convert.ToHexString(SHA256.HashData(bytes)) });
    }
    var common = source.ReadFile(@"Scripts\common.j")!;
    var reference = File.ReadAllBytes(args[1]);
    Check("common.j matches local 1.27b toolchain", common.SequenceEqual(reference));
    Check("path traversal rejected", source.ReadFile("../outside") is null);
    var fromChain = source.ReadFile(@"Units\UnitBalance.slk");
    var patchFile = Directory.EnumerateFiles(game).First(p=>Path.GetFileName(p).Equals("War3Patch.mpq",StringComparison.OrdinalIgnoreCase));
    using var patch = MpqArchive.Open(patchFile, loadListFile: true);
    using var entry = patch.OpenFile(@"Units\UnitBalance.slk");
    using var buffer = new MemoryStream(); entry.CopyTo(buffer);
    Check("patch overrides base", fromChain!.SequenceEqual(buffer.ToArray()));
}
Check("full GameData.TryOpen", GameData.TryOpen(game, out var ctx, out var diagnostic), diagnostic);
if (ctx is not null) {
    Check("base unit hfoo", ctx.Units.TryGetUnit("hfoo", out var fields), fields?.Count);
    Check("base abilities present", ctx.Abilities.Rawcodes.Any(), ctx.Abilities.Rawcodes.Count());
    Check("lazy asset read", ctx.TryReadFile(@"units\human\Footman\Footman.mdx", out var model), model.Length);
    Check("asset enumeration", ctx.FindFiles("Footman.mdx").Count > 0);
    Check("objects diagnostics", ctx.Diagnostics.Count == 0, ctx.Diagnostics);
}
