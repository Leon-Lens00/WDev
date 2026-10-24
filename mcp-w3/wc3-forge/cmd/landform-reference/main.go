// landform-reference reads only a donor MPQ and exports its actual W3E vertices.
package main

import (
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"flag"
	"fmt"
	"os"
	"path/filepath"

	"github.com/StephenSHorton/wc3-forge/internal/formats/mpq"
	"github.com/StephenSHorton/wc3-forge/internal/formats/w3e"
)

func main() {
	source := flag.String("source", "", "donor W3X/W3M (read only)")
	out := flag.String("out", "", "new output directory")
	offset := flag.Float64("water-offset", 0, "measured Water.slk world offset")
	flag.Parse()
	if *source == "" || *out == "" {
		panic("--source and --out are required")
	}
	bytes, err := os.ReadFile(*source)
	must(err)
	a, err := mpq.Open(*source)
	must(err)
	defer a.Close()
	raw, err := a.Read("war3map.w3e")
	must(err)
	f, err := w3e.Parse(raw)
	must(err)
	if f.Version != 11 {
		panic("this reference extractor requires Classic W3E version 11")
	}
	must(os.MkdirAll(*out, 0755))
	must(os.WriteFile(filepath.Join(*out, "war3map.w3e"), raw, 0644))
	ground := make([]float32, len(f.Tiles))
	water := make([]float64, len(f.Tiles))
	flags := make([]int, len(f.Tiles))
	layers := make([]int, len(f.Tiles))
	tiles := make([]string, len(f.Tiles))
	for i, t := range f.Tiles {
		ground[i] = t.FinalZ()
		water[i] = float64(t.WaterZ()) + *offset
		flags[i] = int(t.Flags)
		layers[i] = int(t.LayerHeight)
		tiles[i] = f.GroundTilesets[t.GroundTexIdx()]
	}
	data := map[string]any{"format": "wc3-source-height-grid-v1", "source": *source, "source_sha256": sum(bytes), "w3e_sha256": sum(raw), "version": f.Version, "tileset": string(f.Tileset), "width": f.Width, "height": f.Height, "origin": f.CenterOffset, "step": 128, "water_slk_offset": *offset, "ground_z": ground, "water_z": water, "flags": flags, "cliff_layers": layers, "tiles": tiles}
	j, err := json.Marshal(data)
	must(err)
	must(os.WriteFile(filepath.Join(*out, "grid.json"), j, 0644))
	fmt.Printf("source_sha256=%s w3e_sha256=%s dimensions=%dx%d offset=%g\n", sum(bytes), sum(raw), f.Width, f.Height, *offset)
}
func sum(b []byte) string { s := sha256.Sum256(b); return hex.EncodeToString(s[:]) }
func must(err error) {
	if err != nil {
		panic(err)
	}
}
