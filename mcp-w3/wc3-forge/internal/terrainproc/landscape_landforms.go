package terrainproc

import (
	"encoding/json"
	"fmt"
	"math"
	"math/rand"
	"os"
	"slices"

	"github.com/StephenSHorton/wc3-forge/internal/formats/w3e"
)

const tropicalContextualProfileSHA = "807dcfe966f8424373ae84c6092b0aab0da1a6440160418e81ffe48cc4a36239"

// This adapter is deliberately narrower than LandformPlan. It preserves P/D's
// approved placement graph and source supports, and changes adaptable terrain.
// It is optional so historical v4 specs keep their exact geometry and RNG calls.
type LandscapeLandformOptions struct {
	Format          string         `json:"format"`
	Strategy        string         `json:"strategy"`
	Profile         string         `json:"profile"`
	ProfileSHA      string         `json:"profile_sha256"`
	Streams         map[string]int `json:"streams"`
	BodyTransition  float64        `json:"body_transition"`
	BodyWidthScale  float64        `json:"body_width_scale"`
	BodyHeightScale float64        `json:"body_height_scale"`
	CoastJitter     float64        `json:"coast_jitter"`
	ChannelDepth    float64        `json:"channel_depth"`
	LeftBank        float64        `json:"left_bank"`
	RightBank       float64        `json:"right_bank"`
	SupportBlend    float64        `json:"support_blend"`
	MaxCandidates   int            `json:"max_candidates"`
}

type LandscapeLandformCompiled struct {
	Format     string            `json:"format"`
	Strategy   string            `json:"strategy"`
	ProfileSHA string            `json:"profile_sha256"`
	Streams    map[string]int    `json:"streams"`
	Plan       LandformPlan      `json:"plan"`
	Supports   []LandformSupport `json:"supports"`
	// Retain the authored connection graph separately from its adaptable axes.
	// This makes repeated compilation idempotent and exposes the physical change
	// for inspection instead of silently checking a different legacy polyline.
	SourceReaches []LandscapeReach `json:"source_reaches"`
	Reaches       []LandscapeReach `json:"reaches"`
}

// The old P axes turn at grid-aligned routing waypoints. Rounding each tiny
// emitted segment cannot remove that large right-angle shape. Convolve the
// entire arc-length axis instead, while leaving the native ports and all axes
// within one minimum channel width of an authored crop exactly where they are.
// Quadrature weights prevent densely subdivided legacy bends from pulling the
// curve more strongly than straight segments sampled every 128 units.
func landscapeNaturalReach(reach LandscapeReach, placements []Placement) LandscapeReach {
	points := reach.Points
	if len(points) < 3 {
		return reach
	}
	lengths := make([]float64, len(points))
	for i := 1; i < len(points); i++ {
		lengths[i] = lengths[i-1] + dist(points[i-1], points[i])
	}
	const sigma = 896.
	out := slices.Clone(points)
	for i := 1; i < len(points)-1; i++ {
		point := points[i]
		clearance := math.Inf(1)
		for _, q := range placements {
			clearance = min(clearance, rectDistance(q.Core, point[0], point[1]))
		}
		weight := smooth((clearance-reach.Width)/768) * smooth((min(lengths[i], lengths[len(points)-1]-lengths[i])-reach.Width)/sigma)
		if weight == 0 {
			continue
		}
		var mean [2]float64
		total := 0.
		for j, other := range points {
			d := math.Abs(lengths[j] - lengths[i])
			if d > 3*sigma {
				continue
			}
			span := (lengths[min(len(points)-1, j+1)] - lengths[max(0, j-1)]) / 2
			w := span * math.Exp(-d*d/(2*sigma*sigma))
			mean[0] += other[0] * w
			mean[1] += other[1] * w
			total += w
		}
		if total == 0 {
			continue
		}
		mean[0], mean[1] = mean[0]/total, mean[1]/total
		weight *= min(1, 768/max(1, dist(point, mean)))
		candidate := [2]float64{point[0] + (mean[0]-point[0])*weight, point[1] + (mean[1]-point[1])*weight}
		// The filter may not enter a protected crop from outside. The continuous
		// clearance envelope normally makes this a no-op; the explicit guard
		// handles a tightly packed scene graph without moving authored support.
		for _, q := range placements {
			if rectDistance(q.Core, candidate[0], candidate[1]) < reach.Width {
				candidate = point
				break
			}
		}
		out[i] = candidate
	}
	reach.Points, reach.Length = out, 0
	closest := math.Inf(1)
	for i := 1; i < len(out); i++ {
		reach.Length += dist(out[i-1], out[i])
		if d := dist(out[i], reach.OutletConnectionEnd); d < closest {
			closest = d
			reach.OutletConnectionLength = reach.Length
		}
	}
	for _, point := range out {
		if dist(point, reach.OutletConnectionEnd) == closest {
			reach.OutletConnectionEnd = point
			break
		}
	}
	return reach
}

// Keep the free territorial ridge far enough inside the playable rectangle for
// its own coastal cross section to reach water. Otherwise the mandatory border
// reservation trims several overlapping ridges to one ruler-straight coast.
// Authored terrain is restored independently by the exact rigid supports.
func landscapeInsetSpine(point [2]float64, radius, transition float64) [2]float64 {
	margin := radius + transition
	minimum := [2]float64{-11776 + margin, -3584 + margin}
	maximum := [2]float64{11776 - margin, 7680 - margin}
	for k := range point {
		if point[k] < minimum[k] {
			point[k] = minimum[k] - 128*math.Tanh((minimum[k]-point[k])/512)
		} else if point[k] > maximum[k] {
			point[k] = maximum[k] + 128*math.Tanh((point[k]-maximum[k])/512)
		}
	}
	return point
}

func landscapeLandformStreams(seed int) map[string]int {
	streams := map[string]int{}
	for _, key := range []string{"forms", "relief", "water", "finish"} {
		streams[key] = int(sceneSeed(seed, "landscape-landforms-v1", key) % 2147483647)
	}
	return streams
}

func validateLandscapeLandforms(s Spec) error {
	if s.Landscape.Landforms == nil {
		return nil
	}
	o := s.Landscape.Landforms
	if o.Format != "wc3-landscape-landforms-v1" || o.Strategy != "p-d-adaptable-v1" || s.Landscape.Brief.ID != "D" {
		return fmt.Errorf("landscape landforms: unsupported adapter/brief")
	}
	if o.MaxCandidates < 1 || o.MaxCandidates > 8 || o.BodyTransition < 512 || o.BodyTransition > 1536 ||
		o.BodyWidthScale < .85 || o.BodyWidthScale > 1.3 || o.BodyHeightScale < .65 || o.BodyHeightScale > 1.5 ||
		o.ChannelDepth < 64 || o.ChannelDepth > 192 || o.LeftBank < 256 || o.LeftBank > 768 ||
		o.RightBank < 256 || o.RightBank > 768 || o.SupportBlend < 512 || o.SupportBlend > 1024 || o.CoastJitter < 0 || o.CoastJitter > 128 {
		return fmt.Errorf("landscape landforms: parameters outside bounded P/D adapter")
	}
	for _, v := range []float64{o.BodyTransition, o.BodyWidthScale, o.BodyHeightScale, o.ChannelDepth, o.LeftBank, o.RightBank, o.SupportBlend, o.CoastJitter} {
		if !finite(v) {
			return fmt.Errorf("landscape landforms: nonfinite parameter")
		}
	}
	if len(o.Streams) != 4 {
		return fmt.Errorf("landscape landforms: four independent streams required")
	}
	for _, name := range []string{"forms", "relief", "water", "finish"} {
		if value, ok := o.Streams[name]; !ok || value < 0 || value > 2147483647 {
			return fmt.Errorf("landscape landforms: invalid stream %s", name)
		}
	}
	if s.Landscape.Materials == nil || s.Landscape.Materials.ProfileSHA != tropicalContextualProfileSHA {
		return fmt.Errorf("landscape landforms: approved contextual material profile is mandatory")
	}
	material, err := os.ReadFile(s.Landscape.Materials.Profile)
	if err != nil {
		return err
	}
	if Hash(material) != tropicalContextualProfileSHA {
		return fmt.Errorf("landscape landforms: contextual material profile fingerprint mismatch")
	}
	profile, err := os.ReadFile(o.Profile)
	if err != nil {
		return err
	}
	if len(o.ProfileSHA) != 64 || Hash(profile) != o.ProfileSHA {
		return fmt.Errorf("landscape landforms: source profile fingerprint mismatch")
	}
	var header struct {
		Format string `json:"format"`
		Donor  struct {
			SHA string `json:"sha256"`
		} `json:"donor"`
		Geometry struct {
			Width  int        `json:"width"`
			Height int        `json:"height"`
			Origin [2]float32 `json:"origin"`
		} `json:"geometry"`
		Water struct {
			Offset float64 `json:"slk_offset"`
		} `json:"water"`
	}
	if err := json.Unmarshal(profile, &header); err != nil || header.Format != "wc3-landform-profile-v1" {
		return fmt.Errorf("landscape landforms: unsupported physical source profile")
	}
	if header.Donor.SHA != s.SourceHash || header.Geometry.Width != 193 || header.Geometry.Height != 97 || header.Geometry.Origin != [2]float32{-12288, -4096} || !finite(header.Water.Offset) || math.Abs(header.Water.Offset-(-89.6)) > .001 {
		return fmt.Errorf("landscape landforms: source profile does not describe the accredited tropical donor")
	}
	return nil
}

func landscapeLandformNormalize(geometry MaterialGeometry, xy [2]float64) [2]float64 {
	return [2]float64{(xy[0] - float64(geometry.Origin[0])) / (float64(geometry.Width-1) * 128), (xy[1] - float64(geometry.Origin[1])) / (float64(geometry.Height-1) * 128)}
}

// Bodies already describe the shared territorial organization. Their whole
// axes are retained; complete cross sections add broad variations in elevation
// and coast width without perturbing individual structural pieces.
func compileLandscapeLandforms(g *Scene, p LandscapePlan, lib Library) (LandscapeLandformCompiled, error) {
	o := g.Spec.Landscape.Landforms
	t := g.Map.Terrain
	compiled := LandscapeLandformCompiled{Format: "wc3-landscape-landform-compiled-v1", Strategy: o.Strategy, ProfileSHA: o.ProfileSHA, Streams: o.Streams}
	if t.Width != 193 || t.Height != 97 || t.CenterOffset != [2]float32{-12288, -4096} {
		return compiled, fmt.Errorf("landscape landforms: P/D adapter requires the accredited 193x97 geometry")
	}
	plan := LandformPlan{Format: "wc3-landform-plan-v1", Geometry: MaterialGeometry{193, 97, t.CenterOffset}, WaterLevel: g.Water, WaterOffset: g.Water, BaseHeight: -210, Budget: DefaultLandformBudget()}
	plan.Streams = map[string]int{}
	for name, seed := range o.Streams {
		plan.Streams[name] = seed
	}
	plan.Finish = "off"
	normalize := func(xy [2]float64) [2]float64 { return landscapeLandformNormalize(plan.Geometry, xy) }
	for _, body := range p.Bodies {
		rng := rand.New(rand.NewSource(sceneSeed(o.Streams["relief"], "body", body.ID)))
		widthRNG := rand.New(rand.NewSource(sceneSeed(o.Streams["forms"], "body-width", body.ID)))
		// LandBody.Width is the historical outer radius. A generic ridge Width
		// is its flat core, so subtract both transition bands instead of growing
		// every island by another complete coastal band.
		width := body.Width*2*o.BodyWidthScale - 2*o.BodyTransition
		if width < 64 {
			return compiled, fmt.Errorf("landscape landforms: body %s has no core after its transition", body.ID)
		}
		height := body.Height * o.BodyHeightScale
		feature := LandformFeature{ID: body.ID, Kind: "ridge", Width: width, Height: height, Transition: o.BodyTransition, Jitter: o.CoastJitter, Curve: true}
		if len(body.Spine) == 1 {
			// An isolated approved motif receives a deliberately bounded polygon,
			// rather than a zero-length ridge that the generic contract rejects.
			feature.Kind, feature.Curve, feature.Jitter = "land", false, 0
			for n := 0; n < 12; n++ {
				a := 2 * math.Pi * float64(n) / 12
				feature.Points = append(feature.Points, normalize([2]float64{body.Spine[0][0] + body.Width*.85*math.Cos(a), body.Spine[0][1] + body.Width*.85*math.Sin(a)}))
			}
		} else {
			for _, xy := range body.Spine {
				original := normalize(xy)
				if original[0] < 0 || original[0] > 1 || original[1] < 0 || original[1] > 1 {
					return compiled, fmt.Errorf("landscape landforms: body %s outside the map", body.ID)
				}
				feature.Points = append(feature.Points, normalize(landscapeInsetSpine(xy, body.Width*o.BodyWidthScale, o.BodyTransition)))
			}
			for n, at := range []float64{0, .32, .68, 1} {
				w := width * (.82 + widthRNG.Float64()*.36)
				h := height * (.8 + rng.Float64()*.4)
				if n == 1 {
					h += 40
				}
				feature.Sections = append(feature.Sections, LandformSection{At: at, Width: w, Height: h})
			}
		}
		plan.Features = append(plan.Features, feature)
	}
	compiled.SourceReaches = p.Reaches
	if p.Landforms != nil && len(p.Landforms.SourceReaches) > 0 {
		compiled.SourceReaches = p.Landforms.SourceReaches
	}
	for _, source := range compiled.SourceReaches {
		reach := landscapeNaturalReach(source, p.Placements)
		compiled.Reaches = append(compiled.Reaches, reach)
		rng := rand.New(rand.NewSource(sceneSeed(o.Streams["water"], "reach", reach.ID)))
		feature := LandformFeature{ID: reach.ID, Kind: "channel", Width: reach.Width, Depth: o.ChannelDepth, Transition: o.LeftBank, LeftBank: o.LeftBank, RightBank: o.RightBank, Priority: 10}
		for _, xy := range reach.Points {
			point := normalize(xy)
			if len(feature.Points) == 0 || dist(point, feature.Points[len(feature.Points)-1]) > 1e-9 {
				feature.Points = append(feature.Points, point)
			}
		}
		// Width never falls below the original physical acceptance criterion.
		for _, at := range []float64{0, .2, .48, .75, 1} {
			feature.Sections = append(feature.Sections, LandformSection{At: at, Width: reach.Width * (1.05 + rng.Float64()*.45), Depth: o.ChannelDepth * (.85 + rng.Float64()*.3), LeftBank: o.LeftBank, RightBank: o.RightBank})
		}
		plan.Features = append(plan.Features, feature)
		plan.Relations = append(plan.Relations, LandformRelation{ID: reach.ID + "-native-water", Kind: "connect", Feature: reach.ID, From: normalize(reach.Points[0]), To: normalize(reach.Points[len(reach.Points)-1]), Width: reach.Width, MinDepth: .25, Margin: 384})
	}
	for _, support := range landscapeSupports(g, p, lib) {
		s := LandformSupport{ID: support.Owner.ID, Blend: o.SupportBlend, Tolerance: .125}
		for _, xy := range support.Vertices {
			index := g.index(xy[0], xy[1])
			source := g.index(xy[0]-support.Owner.Offset[0], xy[1]-support.Owner.Offset[1])
			if index < 0 || source < 0 {
				return compiled, fmt.Errorf("landscape landforms: support %s outside source/destination", s.ID)
			}
			s.Vertices = append(s.Vertices, LandformVertex{Index: index, Height: float64(g.Original[source].FinalZ())})
		}
		compiled.Supports = append(compiled.Supports, s)
		plan.Relations = append(plan.Relations, LandformRelation{ID: s.ID + "-source-support", Kind: "support", Support: s.ID})
	}
	// The boundary is a reservation compiled before water, not a late clamp.
	boundary := LandformSupport{ID: "map-boundary", Blend: 768, Tolerance: .125}
	for i := range t.Tiles {
		x, y := g.xy(i%193, i/193)
		if x < -11776 || x >= 11776 || y < -3584 || y >= 7680 {
			boundary.Vertices = append(boundary.Vertices, LandformVertex{Index: i, Height: plan.BaseHeight})
		}
	}
	compiled.Supports = append(compiled.Supports, boundary)
	plan.Relations = append(plan.Relations, LandformRelation{ID: "map-boundary-support", Kind: "support", Support: boundary.ID})
	compiled.Plan = plan
	return compiled, ValidateLandformPlan(plan)
}

func landscapeLandformTerrain(g *Scene, p *LandscapePlan, lib Library) error {
	compiled, err := compileLandscapeLandforms(g, *p, lib)
	if err != nil {
		return err
	}
	surface, err := RealizeLandforms(compiled.Plan, g.Spec.Landscape.Landforms.Streams["forms"], compiled.Supports)
	if err != nil {
		return err
	}
	compiled.Plan = surface.Plan
	p.Reaches = compiled.Reaches
	p.Ownership = slices.Clone(surface.Ownership)
	p.Masks = slices.Clone(surface.Masks)
	for i, z := range surface.Heights {
		x, y := g.xy(i%193, i/193)
		tile := w3e.Tilepoint{WaterLevel: 8192, LayerHeight: 1, CliffTexture: 1, GroundTexture: 3, Flags: 4, Boundary: x < -11776 || x >= 11776 || y < -3584 || y >= 7680}
		setGround(&tile, z)
		if surface.Masks[i] == "rigid" && p.Ownership[i] != "map-boundary" {
			owner := landscapePlacement(*p, p.Ownership[i])
			if owner.ID == "" {
				return fmt.Errorf("landscape landforms: unknown preserved support %s", p.Ownership[i])
			}
			tile = g.Original[g.index(x-owner.Offset[0], y-owner.Offset[1])]
			tile.Boundary = false
			tile.Flags &^= 8
			p.Masks[i] = "rigid"
		} else if p.Ownership[i] == "map-boundary" && tile.Boundary {
			// Boundary supports are physical constraints, not source compositions.
			p.Masks[i] = "territorial"
		}
		g.Map.Terrain.Tiles[i] = tile
	}
	p.Landforms = &compiled
	return nil
}
