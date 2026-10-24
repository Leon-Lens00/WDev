package terrainproc

import (
	"bytes"
	"encoding/binary"
	"fmt"
	"github.com/StephenSHorton/wc3-forge/internal/formats/doodadsdoo"
	"github.com/StephenSHorton/wc3-forge/internal/formats/imp"
	"github.com/StephenSHorton/wc3-forge/internal/formats/w3objmod"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
)

// Walk classic object records without inferring numeric field types or rewriting unrelated records.
func objectRecords(b []byte, opt bool) ([][]byte, [][]byte, error) {
	if len(b) < 12 || binary.LittleEndian.Uint32(b) > 2 {
		return nil, nil, fmt.Errorf("requires classic object table v1/v2")
	}
	pos := 4
	tables := [2][][]byte{}
	for table := 0; table < 2; table++ {
		if pos+4 > len(b) {
			return nil, nil, fmt.Errorf("short object count")
		}
		n := int(binary.LittleEndian.Uint32(b[pos:]))
		pos += 4
		if n > 100000 {
			return nil, nil, fmt.Errorf("object count exceeds budget")
		}
		for i := 0; i < n; i++ {
			start := pos
			if pos+12 > len(b) {
				return nil, nil, fmt.Errorf("short object")
			}
			mods := int(binary.LittleEndian.Uint32(b[pos+8:]))
			pos += 12
			for j := 0; j < mods; j++ {
				if pos+8 > len(b) {
					return nil, nil, fmt.Errorf("short modification")
				}
				typ := binary.LittleEndian.Uint32(b[pos+4:])
				pos += 8
				if opt {
					pos += 8
				}
				if pos > len(b) {
					return nil, nil, fmt.Errorf("short level")
				}
				if typ == 3 {
					end := bytes.IndexByte(b[pos:], 0)
					if end < 0 {
						return nil, nil, fmt.Errorf("unterminated string")
					}
					pos += end + 1
				} else if typ <= 2 {
					pos += 4
				} else {
					return nil, nil, fmt.Errorf("unknown modification type")
				}
				pos += 4
				if pos > len(b) {
					return nil, nil, fmt.Errorf("short value")
				}
			}
			tables[table] = append(tables[table], append([]byte{}, b[start:pos]...))
		}
	}
	if pos != len(b) {
		return nil, nil, fmt.Errorf("object table trailing data")
	}
	return tables[0], tables[1], nil
}
func transformRecord(b []byte, opt bool, id string, remap map[string]string, wts map[string]string) []byte {
	out := append([]byte{}, b[:12]...)
	copy(out[4:8], id)
	pos := 12
	for j := 0; j < int(binary.LittleEndian.Uint32(b[8:])); j++ {
		start := pos
		typ := binary.LittleEndian.Uint32(b[pos+4:])
		pos += 8
		if opt {
			pos += 8
		}
		out = append(out, b[start:pos]...)
		if typ == 3 {
			end := pos + bytes.IndexByte(b[pos:], 0)
			s := string(b[pos:end])
			if v, ok := wts[s]; ok {
				s = v
			}
			if v, ok := remap[key(s)]; ok {
				s = v
			} else {
				p := strings.TrimSuffix(strings.TrimSuffix(key(s), ".mdl"), ".mdx") + ".mdx"
				if v, ok := remap[p]; ok {
					s = v
				}
			}
			out = append(out, []byte(s)...)
			out = append(out, 0)
			pos = end + 1
		} else {
			out = append(out, b[pos:pos+4]...)
			pos += 4
		}
		out = append(out, b[pos:pos+4]...)
		pos += 4
	}
	return out
}
func appendRecord(b, record []byte, opt bool) ([]byte, error) {
	orig, custom, e := objectRecords(b, opt)
	if e != nil {
		return nil, e
	}
	out := append([]byte{}, b[:4]...)
	u32 := func(n int) {
		tmp := make([]byte, 4)
		binary.LittleEndian.PutUint32(tmp, uint32(n))
		out = append(out, tmp...)
	}
	u32(len(orig))
	for _, v := range orig {
		out = append(out, v...)
	}
	u32(len(custom) + 1)
	for _, v := range custom {
		out = append(out, v...)
	}
	out = append(out, record...)
	return out, nil
}
func remapMDX(b []byte, paths map[string]string) ([]byte, error) {
	out := append([]byte{}, b...)
	if _, _, e := modelTextures(out); e != nil {
		return nil, e
	}
	for pos := 4; pos+8 <= len(out); {
		tag := string(out[pos : pos+4])
		n := int(binary.LittleEndian.Uint32(out[pos+4:]))
		pos += 8
		if tag == "ATCH" && n > 0 {
			return nil, fmt.Errorf("attachment dependencies require a dedicated asset profile")
		}
		if tag == "TEXS" {
			for j := pos; j < pos+n; j += 268 {
				old := strings.TrimRight(string(out[j+4:j+264]), "\x00")
				if p, ok := paths[key(old)]; ok {
					if len(p) >= 260 {
						return nil, fmt.Errorf("texture path too long")
					}
					clear(out[j+4 : j+264])
					copy(out[j+4:j+264], p)
				}
			}
		}
		pos += n
	}
	return out, nil
}

// Transfer copies explicit custom assets and one placement of each into an independently editable map.
// Unrelated definitions remain byte-identical; conflicting IDs/paths receive deterministic names.
func Transfer(source, target, install, out string, ids []string, anchor [2]float64) error {
	src, e := Load(source)
	if e != nil {
		return e
	}
	dst, e := Load(target)
	if e != nil {
		return e
	}
	cat, e := CatalogMap(src, install)
	if e != nil {
		return e
	}
	changes := map[string][]byte{}
	paths := map[string]string{}
	idMap := map[string]string{}
	used := map[string]bool{}
	for _, n := range []string{"war3map.w3b", "war3map.w3d"} {
		if b, ok := dst.Files[n]; ok {
			o, c, e := objectRecords(b, n == "war3map.w3d")
			if e != nil {
				return e
			}
			for _, r := range append(o, c...) {
				used[string(r[:4])] = true
				used[string(r[4:8])] = true
			}
		}
	}
	wts := map[string]string{}
	for _, m := range regexp.MustCompile(`(?ms)STRING\s+(\d+)[^\{]*\{\r?\n(.*?)\r?\n\}`).FindAllStringSubmatch(string(src.Files["war3map.wts"]), -1) {
		wts["TRIGSTR_"+fmt.Sprintf("%03s", m[1])] = m[2]
	}
	for _, id := range ids {
		a := cat.Assets[id]
		if a == nil || !a.Custom || len(a.Errors) > 0 {
			return fmt.Errorf("unresolved custom transfer asset %s", id)
		}
		if len(a.Models) != 1 {
			return fmt.Errorf("transfer v1 requires an explicit single-variation asset: %s", id)
		}
		newid := id
		for i := 1; used[newid]; i++ {
			if i >= 4096 {
				return fmt.Errorf("rawcode namespace exhausted")
			}
			newid = fmt.Sprintf("T%03X", i)
		}
		used[newid] = true
		idMap[id] = newid
		for _, model := range a.Models {
			resources := append([]Resource{model.Resource}, model.Textures...)
			if a.Pathing != nil {
				resources = append(resources, a.Pathing.Resource)
			}
			for _, r := range resources {
				if r.Source != "map" {
					continue
				}
				n := key(r.Path)
				if _, ok := paths[n]; ok {
					continue
				}
				data := src.Files[n]
				p := r.Path
				if existing, ok := dst.Files[n]; ok && !bytes.Equal(existing, data) {
					p = "terrainproc\\" + Hash(data)[:12] + "\\" + filepath.Base(strings.ReplaceAll(r.Path, "\\", "/"))
				}
				paths[n] = p
				changes[key(p)] = data
			}
		}
	}
	// A model must receive a new path when its texture references change, even if its input bytes match.
	for n, p := range paths {
		if strings.HasSuffix(n, ".mdx") {
			b, e := remapMDX(src.Files[n], paths)
			if e != nil {
				return e
			}
			if old, ok := dst.Files[key(p)]; ok && !bytes.Equal(old, b) {
				p = "terrainproc\\" + Hash(b)[:12] + "\\" + filepath.Base(strings.ReplaceAll(p, "\\", "/"))
				paths[n] = p
			}
			changes[key(p)] = b
		}
	}
	var next uint32
	for _, d := range dst.Doodads.Doodads {
		next = max(next, d.CreationNumber)
	}
	g := &Scene{Map: dst}
	for i, id := range ids {
		a := cat.Assets[id]
		n := "war3map.w3d"
		if a.Kind == "destructible" {
			n = "war3map.w3b"
		}
		opt := n == "war3map.w3d"
		orig, records, e := objectRecords(src.Files[n], opt)
		if e != nil {
			return e
		}
		for _, r := range orig {
			if string(r[:4]) == a.BaseID {
				return fmt.Errorf("transfer base %s has source overrides", a.BaseID)
			}
		}
		destData := dst.Files[n]
		if b, ok := changes[n]; ok {
			destData = b
		}
		if len(destData) == 0 {
			destData = make([]byte, 12)
			binary.LittleEndian.PutUint32(destData, 2)
		}
		destMods, e := w3objmod.Parse(destData, opt, nil)
		if e != nil {
			return e
		}
		for _, o := range destMods.OriginalEdits {
			if o.BaseID == a.BaseID {
				return fmt.Errorf("target overrides transfer base %s", a.BaseID)
			}
		}
		found := false
		for _, r := range records {
			if string(r[4:8]) == id {
				destData, e = appendRecord(destData, transformRecord(r, opt, idMap[id], paths, wts), opt)
				if e != nil {
					return e
				}
				found = true
				break
			}
		}
		if !found {
			return fmt.Errorf("missing custom definition %s", id)
		}
		changes[n] = destData
		for _, d := range src.Doodads.Doodads {
			if d.TypeID == id {
				x, y := anchor[0]+float64(i)*256, anchor[1]
				z := g.height(x, y, dst.Terrain.Tiles)
				if z == -1000 {
					return fmt.Errorf("transfer anchor outside map")
				}
				d.TypeID = idMap[id]
				d.Position = [3]float32{float32(x), float32(y), float32(z)}
				next++
				d.CreationNumber = next
				dst.Doodads.Doodads = append(dst.Doodads.Doodads, d)
				break
			}
		}
	}
	imports := &imp.File{Version: 1}
	if b := dst.Files["war3map.imp"]; len(b) > 0 {
		imports, e = imp.Parse(b)
		if e != nil {
			return e
		}
	}
	known := map[string]bool{}
	for _, v := range imports.Entries {
		known[key(v.Path)] = true
	}
	newpaths := []string{}
	for _, p := range paths {
		if !known[key(p)] {
			known[key(p)] = true
			newpaths = append(newpaths, p)
		}
	}
	sort.Strings(newpaths)
	for _, p := range newpaths {
		imports.Entries = append(imports.Entries, imp.Entry{Flag: 13, Path: p})
	}
	changes["war3map.imp"] = imports.Encode()
	changes["war3map.doo"], e = doodadsdoo.Encode(dst.Doodads)
	if e != nil {
		return e
	}
	if e = dst.Write(out, changes); e != nil {
		return e
	}
	check, e := Load(out)
	if e != nil {
		return e
	}
	cc, e := CatalogMap(check, install)
	if e != nil {
		return e
	}
	for _, id := range idMap {
		if a := cc.Assets[id]; a == nil || len(a.Errors) > 0 {
			return fmt.Errorf("transferred asset failed dependency validation: %s", id)
		}
	}
	return JSON(out+".transfer.json", map[string]any{"source_sha256": src.Hash, "target_sha256": dst.Hash, "output_sha256": check.Hash, "rawcodes": idMap, "paths": paths, "anchor": anchor, "profile": "classic custom single-variation MDX TEXS; base edits and attachments rejected"})
}
