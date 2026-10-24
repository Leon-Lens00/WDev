package mcpserver

import (
	"bytes"
	"encoding/base64"
	"encoding/json"
	"image"
	"image/png"
	"strings"
	"testing"

	"github.com/modelcontextprotocol/go-sdk/mcp"
)

func TestViewportImageContent(t *testing.T) {
	var b bytes.Buffer
	if err := png.Encode(&b, image.NewRGBA(image.Rect(0, 0, 4, 3))); err != nil {
		t.Fatal(err)
	}
	encoded := base64.StdEncoding.EncodeToString(b.Bytes())
	raw, _ := json.Marshal(map[string]any{"mime_type": "image/png", "bytes_base64": encoded, "width": 4, "camera": map[string]any{"pitch": 1.5}})
	result := viewportImageResult(raw)
	if result.IsError || len(result.Content) != 2 {
		t.Fatal(result)
	}
	img, ok := result.Content[0].(*mcp.ImageContent)
	if !ok || img.MIMEType != "image/png" || !bytes.Equal(img.Data, b.Bytes()) {
		t.Fatal("not native image content")
	}
	metadata := result.Content[1].(*mcp.TextContent).Text
	if strings.Contains(metadata, encoded) || !strings.Contains(metadata, "camera") {
		t.Fatal("bad capture metadata")
	}
}

func TestViewportRejectsInvalidImages(t *testing.T) {
	for _, raw := range []string{`{}`, `{"mime_type":"image/png","bytes_base64":"not png"}`, `{"mime_type":"image/jpeg"}`} {
		if !viewportImageResult(json.RawMessage(raw)).IsError {
			t.Fatal(raw)
		}
	}
}
