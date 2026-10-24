package forge

import (
	"github.com/StephenSHorton/wc3-forge/internal/formats/w3objmod"
	"testing"
)

func TestClassic127bRoutesAllFieldsToVersion2(t *testing.T) {
	stubUnitsBaseNetSafe(t)
	s := &Session{loaded: true, classic127b: true}
	for id, value := range map[string]string{"unam": "001", "umdl": "model.mdx", "uhpm": "100"} {
		if _, _, skin, err := setObjectField(s, UnitsConfig(), "hpea", id, value); err != nil || skin {
			t.Fatalf("%s: skin=%v err=%v", id, skin, err)
		}
	}
	if s.unitMods == nil || s.unitMods.Version != 2 {
		t.Fatalf("wrong new table: %+v", s.unitMods)
	}
	if len(s.objectSkinMods) != 0 {
		t.Fatal("Classic created skin companion")
	}
	if err := s.SetClassic127b(false); err == nil {
		t.Fatal("changed profile on open map")
	}
}

func TestClassic127bSaveRejectsModernTables(t *testing.T) {
	for _, skin := range []bool{false, true} {
		s := &Session{loaded: true, classic127b: true}
		if skin {
			s.objectSkinMods = map[string]*w3objmod.File{"units": {Version: 2}}
		} else {
			s.unitMods = &w3objmod.File{Version: 3}
		}
		// A nil source is deliberate: rejection must happen before any write.
		if err := s.Save(); err == nil {
			t.Fatalf("accepted incompatible table (skin=%v)", skin)
		}
	}
}

func TestMetadataWireTypes(t *testing.T) {
	m := &ObjectMetadata{Fields: []ObjectFieldMeta{
		{ID: "usca", Type: "real"}, {ID: "udtm", Type: "unreal"}, {ID: "unam", Type: "string"},
		{ID: "umdl", Type: "model"}, {ID: "uhpm", Type: "int"}, {ID: "test", Type: "channelFlags"},
		{ID: "list", Type: "intList"}, {ID: "none", Type: ""},
	}}
	types := m.WireTypes()
	for id, want := range map[string]uint32{"usca": 1, "udtm": 2, "unam": 3, "umdl": 3, "uhpm": 0, "test": 0, "list": 3} {
		if got, ok := types[id]; !ok || got != want {
			t.Fatalf("%s got=%d present=%v want=%d", id, got, ok, want)
		}
	}
	if _, ok := types["none"]; ok {
		t.Fatal("empty metadata overrides parsed type")
	}
}
