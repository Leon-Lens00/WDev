package forge

import "fmt"

// SetClassic127b selects a conservative authoring profile before a map is
// opened. It is not a converter or a certificate of in-game compatibility.
// Desktop users may instead set WC3FORGE_TARGET=1.27b before launch.
func (s *Session) SetClassic127b(enabled bool) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	if s.loaded {
		return fmt.Errorf("select the target before opening a map")
	}
	s.classic127b = enabled
	return nil
}

func (s *Session) newObjectVersionLocked() uint32 {
	if s.classic127b {
		return 2
	}
	return 3
}

// Save rejects incompatible input instead of silently downgrading a map.
// This guard covers authoring formats, not every runtime or asset limit.
func (s *Session) validateClassic127bLocked() error {
	if !s.classic127b {
		return nil
	}
	if s.info != nil && (s.info.FileVersion > 25 || s.info.Lua) {
		return fmt.Errorf("1.27b profile requires Classic map info and JASS")
	}
	if s.terrain != nil && s.terrain.Version > 11 {
		return fmt.Errorf("1.27b profile requires terrain version 11 or older")
	}
	if len(s.objectSkinMods) > 0 {
		return fmt.Errorf("1.27b profile refuses war3mapSkin object companions; convert a copy explicitly")
	}
	for _, cfg := range kindConfigs {
		if mods := cfg.GetMods(s); mods != nil && mods.Version > 2 {
			return fmt.Errorf("1.27b profile refuses %s version %d; convert a copy explicitly", cfg.ShadowFile, mods.Version)
		}
	}
	return nil
}
