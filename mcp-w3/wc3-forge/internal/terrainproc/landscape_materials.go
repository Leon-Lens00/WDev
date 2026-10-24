package terrainproc

// Existing tileset order stays untouched. Adaptable sand/rock contacts with
// vines receive one 128-unit dirt/grass transition. Authored cores are immutable.
func landscapeMaterialBands(g *Scene, p LandscapePlan) {
	change := []int{}
	for i, t := range g.Map.Terrain.Tiles {
		if p.Masks[i] == "rigid" || t.GroundTexture != 8 {
			continue
		}
		for _, j := range []int{i - 1, i + 1, i - 193, i + 193} {
			if j < 0 || j >= len(p.Masks) || j/193 != i/193 && (j == i-1 || j == i+1) {
				continue
			}
			tex := g.Map.Terrain.Tiles[j].GroundTexture
			if tex == 3 || tex == 5 {
				change = append(change, i)
				break
			}
		}
	}
	for _, i := range change {
		g.Map.Terrain.Tiles[i].GroundTexture = 2
	}
}
