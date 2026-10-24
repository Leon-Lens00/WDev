// Package terrainproc generates classic Warcraft scenes on disposable map copies.
package terrainproc

import (
	"bytes"
	"crypto/sha256"
	"encoding/binary"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strings"

	"github.com/StephenSHorton/wc3-forge/internal/formats/doodadsdoo"
	"github.com/StephenSHorton/wc3-forge/internal/formats/mpq"
	"github.com/StephenSHorton/wc3-forge/internal/formats/w3e"
	"github.com/StephenSHorton/wc3-forge/internal/formats/wpm"
)

type Map struct {
	Path    string
	Hash    string
	Files   map[string][]byte
	Names   map[string]string
	Header  []byte
	Terrain *w3e.File
	Doodads *doodadsdoo.File
	Pathing *wpm.File
}

func key(s string) string  { return strings.ToLower(strings.ReplaceAll(s, "/", "\\")) }
func Hash(b []byte) string { h := sha256.Sum256(b); return hex.EncodeToString(h[:]) }
func JSON(path string, v any) error {
	b, e := json.MarshalIndent(v, "", "  ")
	if e != nil {
		return e
	}
	if e = os.MkdirAll(filepath.Dir(path), 0755); e != nil {
		return e
	}
	return os.WriteFile(path, append(b, '\n'), 0644)
}
func Load(path string) (*Map, error) {
	raw, e := os.ReadFile(path)
	if e != nil {
		return nil, e
	}
	a, e := mpq.Open(path)
	if e != nil {
		return nil, e
	}
	defer a.Close()
	m := &Map{Path: path, Hash: Hash(raw), Files: map[string][]byte{}, Names: map[string]string{}, Header: append([]byte{}, raw[:a.ArchiveOffset()]...)}
	for _, n := range a.List() {
		b, e := a.Read(n)
		if e != nil {
			return nil, fmt.Errorf("read %s: %w", n, e)
		}
		m.Files[key(n)] = b
		m.Names[key(n)] = n
	}
	known := len(m.Files)
	for _, n := range []string{"(listfile)", "(attributes)"} {
		if a.Has(n) {
			if _, ok := m.Files[n]; !ok {
				known++
			}
		}
	}
	if known < a.PresentFileCount() {
		return nil, fmt.Errorf("archive has unnamed members; refusing lossy repack")
	}
	wi := m.Files["war3map.w3i"]
	if len(wi) < 4 || binary.LittleEndian.Uint32(wi) > 25 {
		return nil, fmt.Errorf("requires classic W3I")
	}
	m.Terrain, e = w3e.Parse(m.Files["war3map.w3e"])
	if e != nil {
		return nil, e
	}
	if m.Terrain.Version != 11 {
		return nil, fmt.Errorf("requires classic W3E v11, got %d", m.Terrain.Version)
	}
	m.Doodads, e = doodadsdoo.Parse(m.Files["war3map.doo"])
	if e != nil {
		return nil, e
	}
	if m.Doodads.Version > 8 || m.Doodads.SubVersion > 11 {
		return nil, fmt.Errorf("modern DOO is not supported")
	}
	for _, d := range m.Doodads.Doodads {
		if d.SkinID != "" {
			return nil, fmt.Errorf("modern skin rawcode found")
		}
	}
	m.Pathing, e = wpm.Parse(m.Files["war3map.wpm"])
	if e != nil {
		return nil, e
	}
	if m.Pathing.Width != int(m.Terrain.Width-1)*4 || m.Pathing.Height != int(m.Terrain.Height-1)*4 || len(m.Files["war3map.wpm"]) != 16+len(m.Pathing.Cells) {
		return nil, fmt.Errorf("pathing dimensions do not match terrain")
	}
	// No-op byte identity is a gate, not just a successful parse.
	tb, e := w3e.Encode(m.Terrain)
	if e != nil {
		return nil, e
	}
	db, e := doodadsdoo.Encode(m.Doodads)
	if e != nil {
		return nil, e
	}
	if !bytes.Equal(tb, m.Files["war3map.w3e"]) || !bytes.Equal(db, m.Files["war3map.doo"]) {
		return nil, fmt.Errorf("classic terrain/DOO round-trip is not byte-identical")
	}
	return m, nil
}
func (m *Map) Write(path string, changes map[string][]byte) error {
	src, _ := filepath.Abs(m.Path)
	dst, _ := filepath.Abs(path)
	if strings.EqualFold(src, dst) {
		return fmt.Errorf("refusing to overwrite source map")
	}
	names := make([]string, 0, len(m.Files)+len(changes))
	all := map[string][]byte{}
	for n, b := range m.Files {
		all[n] = b
	}
	for n, b := range changes {
		all[key(n)] = b
	}
	for n := range all {
		if n != "(listfile)" && n != "(attributes)" {
			names = append(names, n)
		}
	}
	sort.Strings(names)
	entries := make([]mpq.FileEntry, 0, len(names))
	for _, n := range names {
		label := m.Names[n]
		if label == "" {
			label = n
		}
		entries = append(entries, mpq.FileEntry{Name: label, Data: all[n]})
	}
	if e := os.MkdirAll(filepath.Dir(path), 0755); e != nil {
		return e
	}
	if e := mpq.WriteFile(path, entries, m.Header); e != nil {
		return e
	}
	a, e := mpq.Open(path)
	if e != nil {
		return e
	}
	defer a.Close()
	for _, n := range names {
		b, e := a.Read(n)
		if e != nil || !bytes.Equal(b, all[n]) {
			return fmt.Errorf("re-extraction mismatch: %s", n)
		}
	}
	return nil
}
func (m *Map) Inspect(out string) error {
	for _, n := range []string{"war3map.j", "war3map.wts"} {
		if b, ok := m.Files[n]; ok {
			if e := os.MkdirAll(out, 0755); e != nil {
				return e
			}
			if e := os.WriteFile(filepath.Join(out, n), b, 0644); e != nil {
				return e
			}
		}
	}
	counts := map[string]int{}
	for _, d := range m.Doodads.Doodads {
		counts[d.TypeID]++
	}
	members := map[string]any{}
	for n, b := range m.Files {
		members[n] = map[string]any{"bytes": len(b), "sha256": Hash(b)}
	}
	info := map[string]any{"source": m.Path, "sha256": m.Hash, "members": members, "width": m.Terrain.Width, "height": m.Terrain.Height, "origin": m.Terrain.CenterOffset, "tileset": string(m.Terrain.Tileset), "ground": m.Terrain.GroundTilesets, "doodad_types": counts, "doodad_count": len(m.Doodads.Doodads), "classic_roundtrip": true}
	if e := JSON(filepath.Join(out, "inventory.json"), info); e != nil {
		return e
	}
	if e := JSON(filepath.Join(out, "placements.json"), m.Doodads.Doodads); e != nil {
		return e
	}
	if e := JSON(filepath.Join(out, "terrain.json"), m.Terrain); e != nil {
		return e
	}
	return m.Write(filepath.Join(out, "roundtrip.w3x"), nil)
}
