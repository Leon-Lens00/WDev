package forge

import (
	"github.com/StephenSHorton/wc3-forge/internal/formats/w3objmod"
	"strings"
)

// WireTypes uses metadata, never the spelling of a cell's value. A list of
// numbers is still a string; a whole-valued real is still a float. Numeric
// editor enums are encoded as integers, while token enums are strings.
func (m *ObjectMetadata) WireTypes() w3objmod.TypeHints {
	result := w3objmod.TypeHints{}
	if m == nil {
		return result
	}
	for _, field := range m.Fields {
		var typ uint32
		switch strings.ToLower(field.Type) {
		case "":
			continue // absent metadata: preserve a parsed type, if available
		case "real":
			typ = w3objmod.TypeFloat
		case "unreal":
			typ = w3objmod.TypeUnreal
		case "int", "bool", "attackbits", "channeltype", "channelflags",
			"deathtype", "defensetypeint", "detectiontype", "fullflags", "interactionflags",
			"morphflags", "pickflags", "silenceflags", "spelldetail", "stackflags",
			"teamcolor", "techavail", "versionflags":
			typ = w3objmod.TypeInt
		default:
			typ = w3objmod.TypeString
		}
		result[field.ID] = typ
	}
	return result
}
