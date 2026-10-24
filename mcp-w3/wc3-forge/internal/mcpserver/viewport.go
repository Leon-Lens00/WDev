package mcpserver

import (
	"bytes"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"image/png"

	"github.com/modelcontextprotocol/go-sdk/mcp"
)

// Images must be MCP image content, never megabytes of base64 text.
func viewportImageResult(raw json.RawMessage) *mcp.CallToolResult {
	var payload map[string]json.RawMessage
	if err := json.Unmarshal(raw, &payload); err != nil {
		return errorResult(err)
	}
	var data, mime string
	_ = json.Unmarshal(payload["bytes_base64"], &data)
	_ = json.Unmarshal(payload["mime_type"], &mime)
	if mime != "image/png" || len(data) > 32*1024*1024 {
		return errorResult(fmt.Errorf("invalid capture format or size"))
	}
	decoded, err := base64.StdEncoding.DecodeString(data)
	if err != nil {
		return errorResult(err)
	}
	config, err := png.DecodeConfig(bytes.NewReader(decoded))
	if err != nil || config.Width < 1 || config.Height < 1 || config.Width > 4096 || config.Height > 4096 {
		return errorResult(fmt.Errorf("invalid PNG capture"))
	}
	delete(payload, "bytes_base64")
	delete(payload, "mime_type")
	metadata, err := json.Marshal(payload)
	if err != nil {
		return errorResult(err)
	}
	return &mcp.CallToolResult{Content: []mcp.Content{
		&mcp.ImageContent{Data: decoded, MIMEType: "image/png"},
		&mcp.TextContent{Text: prettyJSON(metadata)},
	}}
}
