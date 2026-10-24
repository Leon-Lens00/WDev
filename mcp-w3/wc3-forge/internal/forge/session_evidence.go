package forge

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"os"
	"sync"
)

// MapEvidence identifies the archive represented by this session, rather than
// whatever happens to exist at Path now. Folder maps remain usable but cannot
// claim an archive digest. Revision is monotonic even across undo and reopen.
type MapEvidence struct {
	Version        int    `json:"version"`
	Loaded         bool   `json:"loaded"`
	Path           string `json:"path"`
	LoadedSHA256   string `json:"loaded_sha256"`
	LoadGeneration uint64 `json:"load_generation"`
	Revision       uint64 `json:"revision"`
	Dirty          bool   `json:"dirty"`
	IOPending      int    `json:"io_pending"`
	IdentityError  string `json:"identity_error,omitempty"`
}

type RuntimeEvidence struct {
	PID        int    `json:"pid"`
	Executable string `json:"executable"`
	SHA256     string `json:"sha256"`
	Error      string `json:"error,omitempty"`
}

var runtimeEvidenceOnce sync.Once
var runtimeEvidence RuntimeEvidence

func captureRuntimeEvidence() RuntimeEvidence {
	runtimeEvidenceOnce.Do(func() {
		runtimeEvidence.PID = os.Getpid()
		path, err := os.Executable()
		if err == nil {
			runtimeEvidence.Executable = path
			var data []byte
			data, err = os.ReadFile(path)
			if err == nil {
				runtimeEvidence.SHA256 = archiveDigest(data)
			}
		}
		if err != nil {
			runtimeEvidence.Error = err.Error()
		}
	})
	return runtimeEvidence
}

func archiveDigest(data []byte) string {
	h := sha256.Sum256(data)
	return hex.EncodeToString(h[:])
}

func (s *Session) Evidence() MapEvidence {
	s.mu.RLock()
	defer s.mu.RUnlock()
	return s.evidenceLocked()
}

func (s *Session) evidenceLocked() MapEvidence {
	return MapEvidence{Version: 1, Loaded: s.loaded, Path: s.path,
		LoadedSHA256: s.evidenceSHA, LoadGeneration: s.evidenceGeneration,
		Revision: s.evidenceRevision, Dirty: s.anyDirtyLocked() || s.pendingSkyModel != nil,
		IOPending: s.evidenceIO, IdentityError: s.evidenceError}
}

func (e MapEvidence) requireCleanArchive() error {
	if !e.Loaded || e.LoadedSHA256 == "" || e.IdentityError != "" {
		return fmt.Errorf("capture requires a verified archive load: %s", e.IdentityError)
	}
	if e.Dirty || e.IOPending != 0 {
		return fmt.Errorf("capture requires a clean, idle map session")
	}
	return nil
}

// A save clears dirty flags before its unlocked I/O phase. Keep a separate
// barrier so captures cannot mistake those intermediate flags for a saved map.
func (s *Session) beginEvidenceSave() func(error) {
	s.mu.Lock()
	s.evidenceIO++
	s.evidenceRevision++
	generation, path := s.evidenceGeneration, s.path
	s.mu.Unlock()
	return func(saveErr error) {
		var digest string
		if saveErr == nil {
			if data, err := os.ReadFile(path); err == nil {
				digest = archiveDigest(data)
			} else {
				saveErr = fmt.Errorf("cannot certify saved archive: %w", err)
			}
		}
		s.mu.Lock()
		defer s.mu.Unlock()
		s.evidenceIO--
		s.evidenceRevision++
		if generation != s.evidenceGeneration || path != s.path {
			return
		}
		if saveErr != nil {
			// Failed repacks may already have cleared file dirty flags. Require
			// a successful save/reopen before any new certified evidence.
			s.evidenceError = saveErr.Error()
			return
		}
		s.evidenceSHA = digest
		s.evidenceError = ""
	}
}
