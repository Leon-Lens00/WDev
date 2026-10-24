package terrainproc

import (
	"encoding/binary"
	"fmt"
	"path/filepath"
	"sort"
	"strconv"
	"strings"

	"github.com/StephenSHorton/wc3-forge/internal/formats/slk"
	"github.com/StephenSHorton/wc3-forge/internal/formats/w3objmod"
	"github.com/StephenSHorton/wc3-forge/internal/mpqchain"
)

type Resource struct {
	Path   string `json:"path"`
	SHA256 string `json:"sha256"`
	Source string `json:"source"`
}
type Model struct {
	Resource
	Textures       []Resource `json:"textures"`
	ReplaceableIDs []uint32   `json:"replaceable_ids,omitempty"`
}
type Asset struct {
	ID          string            `json:"id"`
	BaseID      string            `json:"base_id"`
	Kind        string            `json:"kind"`
	Custom      bool              `json:"custom"`
	Fields      map[string]string `json:"fields"`
	Models      map[uint32]Model  `json:"models"`
	Errors      []string          `json:"errors,omitempty"`
	Pathing     *Footprint        `json:"pathing,omitempty"`
	DeadPathing *Footprint        `json:"dead_pathing"`
	MinScale    [3]float32        `json:"observed_min_scale"`
	MaxScale    [3]float32        `json:"observed_max_scale"`
	Count       int               `json:"count"`
}
type Footprint struct {
	Resource
	Width  int    `json:"width"`
	Height int    `json:"height"`
	Cells  []byte `json:"cells"`
}
type Catalog struct {
	Format  string            `json:"format"`
	MapHash string            `json:"map_sha256"`
	Assets  map[string]*Asset `json:"assets"`
}
type Resolver struct {
	Map   *Map
	Stock *mpqchain.Chain
}

func (r *Resolver) Read(path string) ([]byte, Resource, error) {
	if b, ok := r.Map.Files[key(path)]; ok {
		return b, Resource{path, Hash(b), "map"}, nil
	}
	if key(path) == "replaceabletextures\\cliff\\cliff0.tga" || key(path) == "replaceabletextures\\cliff\\cliff1.tga" {
		i := 0
		if strings.Contains(key(path), "cliff1") {
			i = 1
		}
		if i >= len(r.Map.Terrain.CliffTilesets) {
			return nil, Resource{}, fmt.Errorf("missing cliff palette index")
		}
		t, e := r.Table("TerrainArt\\CliffTypes.slk")
		if e != nil {
			return nil, Resource{}, e
		}
		row := t.Rows[r.Map.Terrain.CliffTilesets[i]]
		if row == nil {
			return nil, Resource{}, fmt.Errorf("missing cliff palette row")
		}
		return r.Read(row.String("texdir") + "\\" + row.String("texfile") + ".blp")
	}
	b, ok, e := r.Stock.ReadFile(path)
	if e != nil {
		return nil, Resource{}, e
	}
	if !ok {
		return nil, Resource{}, fmt.Errorf("missing resource %s", path)
	}
	return b, Resource{path, Hash(b), "classic-install"}, nil
}
func (r *Resolver) Table(path string) (*slk.Mapped, error) {
	b, _, e := r.Read(path)
	if e != nil {
		return nil, e
	}
	s := slk.New()
	e = s.Load(b)
	return s, e
}
func CatalogMap(m *Map, install string) (*Catalog, error) {
	stock, e := mpqchain.Open(install)
	if e != nil {
		return nil, e
	}
	defer stock.Close()
	r := &Resolver{m, stock}
	catalog := &Catalog{Format: "wc3-catalog-v1", MapHash: m.Hash, Assets: map[string]*Asset{}}
	for _, kind := range []struct {
		name, table, meta, mods string
		opt                     bool
	}{{"doodad", "Doodads\\Doodads.slk", "Doodads\\DoodadMetaData.slk", "war3map.w3d", true}, {"destructible", "Units\\DestructableData.slk", "Units\\DestructableMetaData.slk", "war3map.w3b", false}} {
		rows, e := r.Table(kind.table)
		if e != nil {
			return nil, e
		}
		meta, e := r.Table(kind.meta)
		if e != nil {
			return nil, e
		}
		fm := w3objmod.FieldMap{}
		for id, row := range meta.Rows {
			fm[id] = strings.ToLower(row.String("field"))
		}
		bases := map[string]string{}
		custom := map[string]bool{}
		if data, ok := m.Files[kind.mods]; ok {
			mods, e := w3objmod.Parse(data, kind.opt, fm)
			if e != nil {
				return nil, e
			}
			for _, o := range mods.OriginalEdits {
				row := rows.Rows[o.BaseID]
				if row == nil {
					return nil, fmt.Errorf("missing original base %s", o.BaseID)
				}
				for k, v := range o.Overrides {
					row[k] = v
				}
				for _, v := range o.Levels {
					if v.Level == 0 {
						row[v.FourCC] = v.Value
					}
				}
			}
			for _, o := range mods.Customs {
				row := slk.MappedRow{}
				base := rows.Rows[o.BaseID]
				if base == nil {
					return nil, fmt.Errorf("missing custom base %s", o.BaseID)
				}
				for k, v := range base {
					row[k] = v
				}
				for k, v := range o.Overrides {
					row[k] = v
				}
				for _, v := range o.Levels {
					if v.Level == 0 {
						row[v.FourCC] = v.Value
					}
				}
				rows.Rows[o.ID] = row
				bases[o.ID] = o.BaseID
				custom[o.ID] = true
			}
		}
		for _, d := range m.Doodads.Doodads {
			row, ok := rows.Rows[d.TypeID]
			if !ok {
				continue
			}
			a := catalog.Assets[d.TypeID]
			if a == nil {
				a = &Asset{ID: d.TypeID, BaseID: bases[d.TypeID], Custom: custom[d.TypeID], Kind: kind.name, Fields: row, Models: map[uint32]Model{}, MinScale: d.Scale, MaxScale: d.Scale}
				catalog.Assets[d.TypeID] = a
				if p := row.String("pathtexdeath"); p != "" && p != "_" && !strings.EqualFold(p, "none") {
					b, res, err := r.Read(p)
					if err != nil {
						a.Errors = append(a.Errors, err.Error())
					} else {
						fp, err := DecodePathing(b)
						if err != nil {
							a.Errors = append(a.Errors, err.Error())
						} else {
							fp.Resource = res
							a.DeadPathing = fp
						}
					}
				}
				p := row.String("pathtex")
				if p != "" && p != "_" && !strings.EqualFold(p, "none") {
					b, res, err := r.Read(p)
					if err != nil {
						a.Errors = append(a.Errors, err.Error())
					} else {
						fp, err := DecodePathing(b)
						if err != nil {
							a.Errors = append(a.Errors, err.Error())
						} else {
							fp.Resource = res
							a.Pathing = fp
						}
					}
				}
			}
			a.Count++
			for i, v := range d.Scale {
				a.MinScale[i] = min(a.MinScale[i], v)
				a.MaxScale[i] = max(a.MaxScale[i], v)
			}
			if _, ok := a.Models[d.Variation]; ok {
				continue
			}
			base := strings.TrimSuffix(strings.TrimSuffix(row.String("file"), ".mdl"), ".mdx")
			paths := []string{base + ".mdx", base + strconv.Itoa(int(d.Variation)) + ".mdx"}
			if row.Number("numvar") > 1 {
				paths[0], paths[1] = paths[1], paths[0]
			}
			var model Model
			var b []byte
			var err error
			for _, p := range paths {
				b, model.Resource, err = r.Read(p)
				if err == nil {
					break
				}
			}
			if err != nil {
				a.Errors = append(a.Errors, err.Error())
				continue
			}
			deps, repl, err := modelTextures(b)
			if err != nil {
				a.Errors = append(a.Errors, model.Path+": "+err.Error())
			}
			model.ReplaceableIDs = repl
			tex := row.String("texfile")
			if tex != "" && tex != "_" {
				if filepath.Ext(tex) == "" {
					tex += ".blp"
				}
				deps = append(deps, tex)
			}
			for _, p := range deps {
				_, res, err := r.Read(p)
				if err != nil {
					a.Errors = append(a.Errors, err.Error())
				} else {
					model.Textures = append(model.Textures, res)
				}
			}
			a.Models[d.Variation] = model
		}
	}
	for _, d := range m.Doodads.Doodads {
		if catalog.Assets[d.TypeID] == nil {
			return nil, fmt.Errorf("unknown placed rawcode %s", d.TypeID)
		}
	}
	for _, a := range catalog.Assets {
		sort.Strings(a.Errors)
	}
	return catalog, nil
}
func modelTextures(b []byte) ([]string, []uint32, error) {
	if len(b) < 4 || string(b[:4]) != "MDLX" {
		return nil, nil, fmt.Errorf("requires classic MDX")
	}
	var paths []string
	var ids []uint32
	for o := 4; o+8 <= len(b); {
		tag := string(b[o : o+4])
		n := int(binary.LittleEndian.Uint32(b[o+4:]))
		o += 8
		if n < 0 || o+n > len(b) {
			return nil, nil, fmt.Errorf("truncated MDX chunk")
		}
		if tag == "VERS" && (n != 4 || binary.LittleEndian.Uint32(b[o:]) != 800) {
			return nil, nil, fmt.Errorf("MDX version must be 800")
		}
		if tag == "TEXS" {
			if n%268 != 0 {
				return nil, nil, fmt.Errorf("invalid TEXS")
			}
			for j := o; j < o+n; j += 268 {
				id := binary.LittleEndian.Uint32(b[j:])
				p := strings.TrimRight(string(b[j+4:j+264]), "\x00")
				if p != "" {
					paths = append(paths, p)
				}
				if id != 0 {
					ids = append(ids, id)
				}
			}
		}
		o += n
	}
	return paths, ids, nil
}

// Warcraft path textures: red=walk, green=fly, blue=build restrictions; TGA origin is normalized bottom-up.
func DecodePathing(b []byte) (*Footprint, error) {
	if len(b) < 18 || b[1] != 0 || (b[2] != 2 && b[2] != 10) || (b[16] != 24 && b[16] != 32) {
		return nil, fmt.Errorf("unsupported pathing TGA")
	}
	w := int(binary.LittleEndian.Uint16(b[12:]))
	h := int(binary.LittleEndian.Uint16(b[14:]))
	if w < 1 || h < 1 || w*h > 1048576 {
		return nil, fmt.Errorf("invalid TGA size")
	}
	fp := &Footprint{Width: w, Height: h, Cells: make([]byte, w*h)}
	pos := 18 + int(b[0])
	stride := int(b[16] / 8)
	pixels := make([][]byte, 0, w*h)
	for len(pixels) < w*h {
		run := 1
		repeat := false
		if b[2] == 10 {
			if pos >= len(b) {
				return nil, fmt.Errorf("truncated TGA")
			}
			run = int(b[pos]&127) + 1
			repeat = b[pos]&128 != 0
			pos++
		}
		if len(pixels)+run > w*h {
			return nil, fmt.Errorf("oversized TGA run")
		}
		for i := 0; i < run; i++ {
			if pos+stride > len(b) {
				return nil, fmt.Errorf("truncated TGA pixels")
			}
			pixels = append(pixels, b[pos:pos+stride])
			if !repeat || i == run-1 {
				pos += stride
			}
		}
	}
	for i, p := range pixels {
		x, y := i%w, i/w
		if b[17]&32 != 0 {
			y = h - 1 - y
		}
		if b[17]&16 != 0 {
			x = w - 1 - x
		}
		var flag byte
		if p[2] > 250 {
			flag |= 2
		}
		if p[1] > 250 {
			flag |= 4
		}
		if p[0] > 250 {
			flag |= 8
		}
		fp.Cells[x+y*w] = flag
	}
	return fp, nil
}
