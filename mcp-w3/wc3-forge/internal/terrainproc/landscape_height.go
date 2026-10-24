package terrainproc

import (
	"fmt"
	"math"
)

// All values are world units. A policy preserves the authored offset, including
// intentional elevation, submersion and embedded architectural pieces.
func landscapeHeight(policy string, z, oldGround, newGround, oldWater, newWater, oldParent, newParent float64) (float64, error) {
	result := z
	switch policy {
	case "absolute-rigid":
	case "ground-offset":
		result = newGround + z - oldGround
	case "water-offset":
		result = newWater + z - oldWater
	case "parent-relative":
		result = newParent + z - oldParent
	default:
		return 0, fmt.Errorf("unsupported height policy %s", policy)
	}
	if math.IsNaN(result) || math.IsInf(result, 0) {
		return 0, fmt.Errorf("height policy has no finite supporting reference")
	}
	return result, nil
}
