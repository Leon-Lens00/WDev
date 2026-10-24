package main

import (
	"flag"
	"fmt"
	"github.com/StephenSHorton/wc3-forge/internal/mpqchain"
	"github.com/StephenSHorton/wc3-forge/internal/terrainproc"
	"os"
	"strings"
)

func main() {
	if e := run(); e != nil {
		fmt.Fprintln(os.Stderr, e)
		os.Exit(1)
	}
}
func run() error {
	if len(os.Args) < 2 {
		return fmt.Errorf("usage: terrain-gen <inspect|discover|library|compile-brief|generate|batch|validate|bake|transfer|audit|editor-audit|harness|resource> [flags]")
	}
	f := flag.NewFlagSet(os.Args[1], flag.ContinueOnError)
	spec := f.String("spec", "", "scene JSON")
	seed := f.Int("seed", -1, "override seed")
	path := f.String("map", "", "source W3X")
	out := f.String("out", "", "output directory")
	install := f.String("install", "", "classic installation")
	target := f.String("target", "", "target map for transfer")
	resource := f.String("resource", "", "archive path for resource inspection")
	ids := f.String("ids", "", "comma-separated custom rawcodes")
	x := f.Float64("x", 0, "transfer anchor x")
	y := f.Float64("y", 0, "transfer anchor y")
	brief := f.String("brief", "", "scene brief JSON")
	library := f.String("library", "", "reviewed scene library v2 JSON")
	stream := f.String("stream", "", "named landscape random stream")
	vegetation := f.String("vegetation", "", "landscape habitat, s-control or bare")
	if e := f.Parse(os.Args[2:]); e != nil {
		return e
	}
	if os.Args[1] == "biome-generate" {
		return terrainproc.GenerateBiome(*spec, *out, *seed)
	}
	if os.Args[1] == "terrain-neutral" {
		return terrainproc.NeutralTerrain(*path, *out, *ids)
	}
	if os.Args[1] == "biome-editor-audit" {
		return terrainproc.AuditBiomeEditor(*spec, *path, *target, *out)
	}
	if os.Args[1] == "biome-validate" {
		return terrainproc.ValidateBiome(*spec, *path, *out)
	}
	if os.Args[1] == "biome-context" {
		return terrainproc.ExtractBiomeContext(*spec, *out)
	}
	if os.Args[1] == "biome-discover" {
		return terrainproc.DiscoverBiome(*spec, *out)
	}
	if os.Args[1] == "biome-material-profile" {
		return terrainproc.CreateBiomeMaterialProfile(*spec, *out)
	}
	if os.Args[1] == "material-profile" {
		return terrainproc.CreateMaterialProfile(*path, *install, *out)
	}
	if os.Args[1] == "repaint-materials" {
		return terrainproc.RepaintMaterials(*spec, *out)
	}
	if os.Args[1] == "validate-materials" {
		return terrainproc.ValidateMaterials(*spec, *path, *out)
	}
	if os.Args[1] == "material-diagnostic" {
		return terrainproc.MaterialDiagnostic(*path, *out)
	}
	if os.Args[1] == "landscape-config" {
		s, e := terrainproc.ReadSpec(*spec)
		if e != nil {
			return e
		}
		return terrainproc.ConfigureLandscape(s, *stream, *seed, *vegetation, *out)
	}
	if os.Args[1] == "discover" || os.Args[1] == "compile-brief" || os.Args[1] == "compile-landscape" {
		s, e := terrainproc.ReadSpec(*spec)
		if e != nil {
			return e
		}
		if *seed >= 0 {
			if e := terrainproc.ReseedScenes(&s, *seed); e != nil {
				return e
			}
		}
		if os.Args[1] == "discover" {
			return terrainproc.DiscoverScenes(s, *out)
		}
		if os.Args[1] == "compile-landscape" {
			return terrainproc.CompileLandscapeBrief(s, *brief, *library, *out)
		}
		return terrainproc.CompileSceneBrief(s, *brief, *library, *out)
	}
	if os.Args[1] == "resource" {
		m, e := terrainproc.Load(*path)
		if e != nil {
			return e
		}
		stock, e := mpqchain.Open(*install)
		if e != nil {
			return e
		}
		defer stock.Close()
		r := terrainproc.Resolver{Map: m, Stock: stock}
		b, _, e := r.Read(*resource)
		if e != nil {
			return e
		}
		return os.WriteFile(*out, b, 0644)
	}
	if os.Args[1] == "library" {
		s, e := terrainproc.ReadSpec(*spec)
		if e != nil {
			return e
		}
		return terrainproc.InspectRecompose(s, *out)
	}
	if os.Args[1] == "editor-audit" {
		s, e := terrainproc.ReadSpec(*spec)
		if e != nil {
			return e
		}
		return terrainproc.AuditRecomposeEditor(s, *path, *target, *out)
	}
	if os.Args[1] == "landscape-fixture" {
		s, e := terrainproc.ReadSpec(*spec)
		if e != nil {
			return e
		}
		return terrainproc.ExportLandscapeFixture(s, *out)
	}
	if os.Args[1] == "audit" {
		return terrainproc.Audit(*path, *target, *out)
	}
	if os.Args[1] == "validate" {
		s, e := terrainproc.ReadSpec(*spec)
		if e != nil {
			return e
		}
		return terrainproc.ValidateExport(s, *path, *out)
	}
	if os.Args[1] == "harness" {
		s, e := terrainproc.ReadSpec(*spec)
		if e != nil {
			return e
		}
		return terrainproc.Harness(s, *path, *out)
	}
	if os.Args[1] == "bake" {
		s, e := terrainproc.ReadSpec(*spec)
		if e != nil {
			return e
		}
		return terrainproc.Bake(s, *path, *target, *out)
	}
	if os.Args[1] == "transfer" {
		if *path == "" || *target == "" || *out == "" || *ids == "" || *install == "" {
			return fmt.Errorf("transfer requires --map --target --out --ids --install")
		}
		return terrainproc.Transfer(*path, *target, *install, *out, strings.Split(*ids, ","), [2]float64{*x, *y})
	}
	if os.Args[1] == "generate" || os.Args[1] == "batch" {
		if *spec == "" || *out == "" {
			return fmt.Errorf("--spec and --out required")
		}
		s, e := terrainproc.ReadSpec(*spec)
		if e != nil {
			return e
		}
		if *seed >= 0 {
			if e := terrainproc.ReseedScenes(&s, *seed); e != nil {
				return e
			}
		}
		if os.Args[1] == "batch" {
			return terrainproc.Batch(s, *out)
		}
		r, e := terrainproc.Generate(s, *out)
		if e != nil {
			return e
		}
		fmt.Printf("seed=%d added=%d changed_vertices=%d route=%v map=%s\n", r.Seed, r.Added, r.TerrainChanges, r.RouteReachable, r.Map)
		return nil
	}
	if *path == "" || *out == "" {
		return fmt.Errorf("--map and --out required")
	}
	m, e := terrainproc.Load(*path)
	if e != nil {
		return e
	}
	switch os.Args[1] {
	case "inspect":
		if e := m.Inspect(*out); e != nil {
			return e
		}
		if *install != "" {
			c, e := terrainproc.CatalogMap(m, *install)
			if e != nil {
				return e
			}
			return terrainproc.JSON(*out+"/catalog.json", c)
		}
		return nil
	default:
		return fmt.Errorf("unknown command %s", os.Args[1])
	}
}
