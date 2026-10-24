package terrainproc

import (
	"fmt"
	"math"
	"math/rand"
	"slices"
)

func landformWorld(g MaterialGeometry, p [2]float64) [2]float64 {
	return [2]float64{float64(g.Origin[0]) + p[0]*float64(g.Width-1)*128, float64(g.Origin[1]) + p[1]*float64(g.Height-1)*128}
}
func landformNormalized(g MaterialGeometry, p [2]float64) [2]float64 {
	return [2]float64{(p[0] - float64(g.Origin[0])) / (float64(g.Width-1) * 128), (p[1] - float64(g.Origin[1])) / (float64(g.Height-1) * 128)}
}
func landformXY(g MaterialGeometry, i int) [2]float64 {
	return [2]float64{float64(g.Origin[0]) + float64(i%g.Width)*128, float64(g.Origin[1]) + float64(i/g.Width)*128}
}
func landformArea(a [][2]float64) float64 {
	z := 0.
	for i, p := range a {
		q := a[(i+1)%len(a)]
		z += p[0]*q[1] - q[0]*p[1]
	}
	return z / 2
}
func landformCross(a, b, c [2]float64) float64 {
	return (b[0]-a[0])*(c[1]-a[1]) - (b[1]-a[1])*(c[0]-a[0])
}
func landformOnSegment(p, a, b [2]float64) bool {
	return math.Abs(landformCross(a, b, p)) < 1e-10 && p[0] >= min(a[0], b[0])-1e-10 && p[0] <= max(a[0], b[0])+1e-10 && p[1] >= min(a[1], b[1])-1e-10 && p[1] <= max(a[1], b[1])+1e-10
}
func landformIntersects(a, b, c, d [2]float64) bool {
	x, y, u, v := landformCross(a, b, c), landformCross(a, b, d), landformCross(c, d, a), landformCross(c, d, b)
	return x*y < 0 && u*v < 0 || landformOnSegment(c, a, b) || landformOnSegment(d, a, b) || landformOnSegment(a, c, d) || landformOnSegment(b, c, d)
}
func landformSelfCrosses(p [][2]float64, closed bool) bool {
	n := len(p) - 1
	if closed {
		n++
	}
	for i := 0; i < n; i++ {
		for j := i + 1; j < n; j++ {
			if j == i+1 || closed && i == 0 && j == n-1 {
				continue
			}
			if landformIntersects(p[i], p[(i+1)%len(p)], p[j], p[(j+1)%len(p)]) {
				return true
			}
		}
	}
	for i := 1; i < len(p)-1; i++ {
		a, b, c := p[i-1], p[i], p[i+1]
		if math.Abs(landformCross(a, b, c)) < 1e-12 && (b[0]-a[0])*(c[0]-b[0])+(b[1]-a[1])*(c[1]-b[1]) < 0 {
			return true
		}
	}
	return false
}
func landformInPolygon(p [2]float64, a [][2]float64) bool {
	in := false
	for i, q := range a {
		r := a[(i+1)%len(a)]
		if landformOnSegment(p, q, r) {
			return true
		}
		if (q[1] > p[1]) != (r[1] > p[1]) && p[0] < (r[0]-q[0])*(p[1]-q[1])/(r[1]-q[1])+q[0] {
			in = !in
		}
	}
	return in
}
func landformSegment(p, a, b [2]float64) (float64, float64) {
	dx, dy := b[0]-a[0], b[1]-a[1]
	l := dx*dx + dy*dy
	t := 0.
	if l > 0 {
		t = max(0, min(1, ((p[0]-a[0])*dx+(p[1]-a[1])*dy)/l))
	}
	return math.Hypot(p[0]-a[0]-t*dx, p[1]-a[1]-t*dy), t
}
func landformSignedDistance(p [2]float64, a [][2]float64) float64 {
	d := math.Inf(1)
	for i, q := range a {
		v, _ := landformSegment(p, q, a[(i+1)%len(a)])
		d = min(d, v)
	}
	if !landformInPolygon(p, a) {
		d = -d
	}
	return d
}

type landformCompiled struct {
	Feature LandformFeature
	Points  [][2]float64
	Lengths []float64
	Length  float64
}

func compileLandform(g MaterialGeometry, f LandformFeature) landformCompiled {
	c := landformCompiled{Feature: f}
	for _, p := range f.Points {
		c.Points = append(c.Points, landformWorld(g, p))
	}
	c.Lengths = make([]float64, len(c.Points))
	for i := 1; i < len(c.Points); i++ {
		c.Length += dist(c.Points[i-1], c.Points[i])
		c.Lengths[i] = c.Length
	}
	return c
}
func landformSection(f LandformFeature, t float64) LandformSection {
	s := LandformSection{At: t, Width: f.Width, Height: f.Height, Depth: f.Depth, LeftBank: f.LeftBank, RightBank: f.RightBank}
	for i := 1; i < len(f.Sections); i++ {
		a, b := f.Sections[i-1], f.Sections[i]
		if t <= b.At {
			u := max(0, min(1, (t-a.At)/(b.At-a.At)))
			mix := func(x, y float64) float64 { return x + (y-x)*u }
			s = LandformSection{t, mix(a.Width, b.Width), mix(a.Height, b.Height), mix(a.Depth, b.Depth), mix(a.LeftBank, b.LeftBank), mix(a.RightBank, b.RightBank)}
			break
		}
	}
	if s.LeftBank == 0 {
		s.LeftBank = f.Transition
	}
	if s.RightBank == 0 {
		s.RightBank = f.Transition
	}
	return s
}
func (c landformCompiled) axis(p [2]float64) (float64, float64, LandformSection) {
	best, at, side := math.Inf(1), 0., 1.
	for i := 1; i < len(c.Points); i++ {
		a, b := c.Points[i-1], c.Points[i]
		d, t := landformSegment(p, a, b)
		if d < best {
			best = d
			at = (c.Lengths[i-1] + t*dist(a, b)) / c.Length
			side = landformCross(a, b, p)
		}
	}
	return best, side, landformSection(c.Feature, at)
}

// Curve rounding keeps endpoints fixed and replaces corners with quadratic
// Beziers. A conservative subdivision bound gives <=4 world-unit chord error.
func landformRound(p [][2]float64, limit int) ([][2]float64, error) {
	out := [][2]float64{p[0]}
	for i := 1; i < len(p)-1; i++ {
		a, b, c := p[i-1], p[i], p[i+1]
		radius := min(512, min(dist(a, b), dist(b, c))*.3)
		start, end := b, b
		for k := 0; k < 2; k++ {
			start[k] += (a[k] - b[k]) * radius / dist(a, b)
			end[k] += (c[k] - b[k]) * radius / dist(b, c)
		}
		if dist(out[len(out)-1], start) > 1e-8 {
			out = append(out, start)
		}
		n := max(2, int(math.Ceil(math.Sqrt(2*radius/4))))
		for j := 1; j <= n; j++ {
			t := float64(j) / float64(n)
			out = append(out, [2]float64{(1-t)*(1-t)*start[0] + 2*(1-t)*t*b[0] + t*t*end[0], (1-t)*(1-t)*start[1] + 2*(1-t)*t*b[1] + t*t*end[1]})
			if len(out) > limit {
				return nil, fmt.Errorf("landform: curve subdivision budget")
			}
		}
	}
	out = append(out, p[len(p)-1])
	return out, nil
}

func resolveLandformPlan(p LandformPlan, seed int) (LandformPlan, error) {
	r := p
	r.Features = append([]LandformFeature{}, p.Features...)
	r.Budget = landformBudget(p)
	r.Finish = "off"
	r.Streams = map[string]int{}
	for _, name := range []string{"forms", "relief", "water", "finish"} {
		value, ok := p.Streams[name]
		if !ok {
			value = int(sceneSeed(seed, "landform-stream-v1", name) % 2147483647)
		}
		r.Streams[name] = value
	}
	for i, f := range r.Features {
		f.Points = append([][2]float64{}, f.Points...)
		stream := "forms"
		switch f.Kind {
		case "ridge", "valley":
			stream = "relief"
		case "lake", "channel":
			stream = "water"
		}
		rng := rand.New(rand.NewSource(sceneSeed(r.Streams[stream], "landform-feature-v1", f.ID)))
		for j, pt := range f.Points {
			if f.Jitter > 0 && (landformPolygon(f) || j > 0 && j < len(f.Points)-1) {
				w := landformWorld(p.Geometry, pt)
				a := rng.Float64() * 2 * math.Pi
				d := rng.Float64() * f.Jitter
				w[0] += math.Cos(a) * d
				w[1] += math.Sin(a) * d
				f.Points[j] = landformNormalized(p.Geometry, w)
			}
		}
		if f.Curve {
			var points [][2]float64
			for _, pt := range f.Points {
				points = append(points, landformWorld(p.Geometry, pt))
			}
			points, e := landformRound(points, r.Budget.MaxPoints)
			if e != nil {
				return r, e
			}
			f.Points = nil
			for _, pt := range points {
				f.Points = append(f.Points, landformNormalized(p.Geometry, pt))
			}
		}
		f.Jitter = 0
		f.Curve = false
		r.Features[i] = f
	}
	rank := map[string]int{"land": 0, "ridge": 1, "valley": 2, "lake": 3, "channel": 3, "route": 4}
	slices.SortStableFunc(r.Features, func(a, b LandformFeature) int {
		if a.Priority != b.Priority {
			return a.Priority - b.Priority
		}
		if rank[a.Kind] != rank[b.Kind] {
			return rank[a.Kind] - rank[b.Kind]
		}
		if a.ID < b.ID {
			return -1
		}
		if a.ID > b.ID {
			return 1
		}
		return 0
	})
	return r, ValidateLandformPlan(r)
}

// ResolveLandformPlan is shared only for checking recipe/seed provenance. It
// performs no height generation and cannot certify the exported physical map.
func ResolveLandformPlan(p LandformPlan, seed int) (LandformPlan, error) {
	if seed < 0 || seed > 2147483647 {
		return p, fmt.Errorf("landform: invalid seed")
	}
	if e := ValidateLandformPlan(p); e != nil {
		return p, e
	}
	return resolveLandformPlan(p, seed)
}

// RealizeLandforms is pure: it does not mutate map objects, import data or the
// input recipe. Returned heights are quarter-unit quantized absolute FinalZ.
func RealizeLandforms(p LandformPlan, seed int, supports []LandformSupport) (LandformSurface, error) {
	r := LandformSurface{}
	if seed < 0 || seed > 2147483647 {
		return r, fmt.Errorf("landform: invalid seed")
	}
	if e := ValidateLandformPlan(p); e != nil {
		return r, e
	}
	if e := validateLandformSupports(p, supports); e != nil {
		return r, e
	}
	plan, e := resolveLandformPlan(p, seed)
	if e != nil {
		return r, e
	}
	r.Plan = plan
	n := p.Geometry.Width * p.Geometry.Height
	r.Heights = make([]float64, n)
	r.Ownership = make([]string, n)
	r.Masks = make([]string, n)
	compiled := []landformCompiled{}
	for _, f := range plan.Features {
		compiled = append(compiled, compileLandform(plan.Geometry, f))
	}
	for i := 0; i < n; i++ {
		pt := landformXY(p.Geometry, i)
		z := p.BaseHeight
		owner, mask := "ocean", "territorial"
		for _, c := range compiled {
			f := c.Feature
			if f.Kind == "lake" || f.Kind == "channel" || f.Kind == "route" {
				continue
			}
			next := z
			fm := "territorial"
			if f.Kind == "land" {
				d := landformSignedDistance(pt, c.Points)
				h := p.WaterLevel + (f.Height-p.WaterLevel)*smooth(d/f.Transition)
				if d < 0 {
					h = p.WaterLevel + (p.BaseHeight-p.WaterLevel)*smooth(-d/f.Transition)
				}
				next = max(z, h)
			} else {
				d, side, s := c.axis(pt)
				bank := s.LeftBank
				if side < 0 {
					bank = s.RightBank
				}
				edge := d - s.Width/2
				weight := 1 - smooth(edge/bank)
				if weight > 0 {
					switch f.Kind {
					case "ridge":
						next = z + (max(z, s.Height)-z)*weight
					case "valley":
						next = z + (min(z, s.Height)-z)*weight
					}
				}
			}
			if math.Abs(next-z) > 1e-9 {
				z, owner, mask = next, f.ID, fm
			}
		}
		if !landformHeightValid(z) {
			return r, fmt.Errorf("landform: unencodable height %.3f at %d", z, i)
		}
		r.Heights[i] = z
		r.Ownership[i] = owner
		r.Masks[i] = mask
	}
	// A deterministic distance-field blend around authored vertices. The actual
	// source vertices override transitions exactly; wet supports are legitimate.
	ordered := append([]LandformSupport{}, supports...)
	slices.SortFunc(ordered, func(a, b LandformSupport) int {
		if a.ID < b.ID {
			return -1
		}
		if a.ID > b.ID {
			return 1
		}
		return 0
	})
	best := make([]float64, n)
	unblended := slices.Clone(r.Heights)
	for i := range best {
		best[i] = math.Inf(1)
	}
	for _, s := range ordered {
		nearest := make([]float64, n)
		sum := make([]float64, n)
		weights := make([]float64, n)
		for i := range nearest {
			nearest[i] = math.Inf(1)
		}
		for _, v := range s.Vertices {
			pt := landformXY(p.Geometry, v.Index)
			rad := int(math.Ceil(s.Blend / 128))
			cx, cy := v.Index%p.Geometry.Width, v.Index/p.Geometry.Width
			for yy := max(0, cy-rad); yy <= min(p.Geometry.Height-1, cy+rad); yy++ {
				for xx := max(0, cx-rad); xx <= min(p.Geometry.Width-1, cx+rad); xx++ {
					i := xx + yy*p.Geometry.Width
					d := dist(pt, landformXY(p.Geometry, i))
					if d > s.Blend {
						continue
					}
					nearest[i] = min(nearest[i], d)
					weight := math.Exp(-d / 80)
					sum[i] += weight * v.Height
					weights[i] += weight
				}
			}
		}
		for i, d := range nearest {
			if d >= best[i] || weights[i] == 0 {
				continue
			}
			best[i] = d
			weight := 1.
			if s.Blend > 0 {
				weight = 1 - smooth(d/s.Blend)
			}
			r.Heights[i] = unblended[i]*(1-weight) + sum[i]/weights[i]*weight
			r.Ownership[i] = s.ID
			r.Masks[i] = "transition"
		}
	}
	for _, s := range ordered {
		for _, v := range s.Vertices {
			r.Heights[v.Index] = v.Height
			r.Ownership[v.Index] = s.ID
			r.Masks[v.Index] = "rigid"
		}
	}
	// Resolve adaptive water and routes after support blending. Authored wet
	// vertices remain valid hydraulic support; source dry vertices are immutable
	// and any incompatible requested connection must fail physical inspection.
	for i, z := range r.Heights {
		if r.Masks[i] == "rigid" {
			continue
		}
		pt := landformXY(p.Geometry, i)
		for _, c := range compiled {
			f := c.Feature
			next := z
			mask := "water-adaptable"
			switch f.Kind {
			case "lake":
				d := landformSignedDistance(pt, c.Points)
				if d >= 0 {
					next = min(z, p.WaterLevel-f.Depth*smooth(d/f.Transition))
				} else if d > -f.Transition {
					weight := 1 - smooth(-d/f.Transition)
					next = min(z, z*(1-weight)+p.WaterLevel*weight)
				}
			case "channel", "route":
				d, side, s := c.axis(pt)
				bank := s.LeftBank
				if side < 0 {
					bank = s.RightBank
				}
				weight := 1 - smooth((d-s.Width/2)/bank)
				if f.Kind == "route" {
					next = z + (s.Height-z)*weight
					mask = "route"
				} else {
					next = z + (min(z, p.WaterLevel-s.Depth)-z)*weight
				}
			default:
				continue
			}
			if math.Abs(next-z) > 1e-9 {
				z = next
				r.Ownership[i] = f.ID
				r.Masks[i] = mask
			}
		}
		r.Heights[i] = z
	}
	for i, z := range r.Heights {
		if !landformHeightValid(z) {
			return r, fmt.Errorf("landform: unencodable final height %.3f at %d", z, i)
		}
		r.Heights[i] = math.Round(z*4) / 4
	}
	return r, nil
}
