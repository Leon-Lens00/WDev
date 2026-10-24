package terrainproc

import (
	"bytes"
	"fmt"
)

const biomeLandformMember = "war3map.landforms.json"

// World Editor can discard this nonstandard member. Native audits therefore
// retain an explicit, verified reference to the generated archive, rather than
// treating a missing native record as evidence about the native physical data.
type BiomeNativeLandformProvenance struct {
	Mode                    string `json:"mode"`
	GeneratedMapSHA         string `json:"generated_map_sha256"`
	NativeMapSHA            string `json:"native_map_sha256"`
	Member                  string `json:"member"`
	RecordSHA               string `json:"record_sha256"`
	GeneratedRecordVerified bool   `json:"generated_record_verified"`
	NativeRecordRetained    bool   `json:"native_record_retained"`
}

type BiomeNativeLandformInspection struct {
	LandformInspection
	Provenance BiomeNativeLandformProvenance `json:"provenance"`
}

func inspectBiomeNativeLandforms(q BiomeRecipe, library SceneLibrary, donor *Map, mat MaterialProfile, generated, native *Map) (*BiomeNativeLandformInspection, error) {
	r := &BiomeNativeLandformInspection{}
	if generated == nil || native == nil {
		return r, fmt.Errorf("native physical audit requires generated and native maps")
	}
	raw := generated.Files[biomeLandformMember]
	nativeRaw, retained := native.Files[biomeLandformMember]
	r.Provenance = BiomeNativeLandformProvenance{Mode: "verified-generated-record", GeneratedMapSHA: generated.Hash, NativeMapSHA: native.Hash, Member: biomeLandformMember, RecordSHA: Hash(raw), NativeRecordRetained: retained}
	// This checks recipe hashes, allowed seed, its resolved plan, and the actual
	// generated W3E/WPM. A record copied from an unrelated map is not trusted.
	if _, e := inspectBiomeLandforms(q, library, donor, mat, generated); e != nil {
		return r, fmt.Errorf("generated physical provenance: %w", e)
	}
	r.Provenance.GeneratedRecordVerified = true
	if retained && !bytes.Equal(raw, nativeRaw) {
		return r, fmt.Errorf("native physical provenance changed instead of being removed")
	}
	// Overlay only the proven recipe record for this read-only inspection. Every
	// physical pointer and archive identity still belongs to the native map. The
	// native archive and its in-memory Files map remain untouched.
	view := *native
	view.Files = map[string][]byte{biomeLandformMember: raw}
	inspection, e := inspectBiomeLandforms(q, library, donor, mat, &view)
	if inspection != nil {
		r.LandformInspection = *inspection
	}
	return r, e
}

func biomeEditorLandformRemoval(q BiomeRecipe, generated, native *Map, member string) bool {
	if q.Landforms == nil || member != biomeLandformMember || len(generated.Files[member]) == 0 {
		return false
	}
	_, retained := native.Files[member]
	return !retained
}
