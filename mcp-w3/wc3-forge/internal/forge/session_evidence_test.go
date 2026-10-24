package forge

import (
	"encoding/json"
	"errors"
	"os"
	"path/filepath"
	"strings"
	"testing"
	"time"

	"github.com/StephenSHorton/wc3-forge/internal/formats/mpq"
)

func evidenceFixture(t *testing.T) (string, *Session) {
	t.Helper()
	folder := copyCommittedMapFixture(t)
	files, err := os.ReadDir(folder)
	if err != nil {
		t.Fatal(err)
	}
	var entries []mpq.FileEntry
	for _, f := range files {
		data, err := os.ReadFile(filepath.Join(folder, f.Name()))
		if err != nil {
			t.Fatal(err)
		}
		entries = append(entries, mpq.FileEntry{Name: f.Name(), Data: data})
	}
	path := filepath.Join(t.TempDir(), "evidence.w3x")
	if err := mpq.WriteFile(path, entries, nil); err != nil {
		t.Fatal(err)
	}
	s := &Session{}
	if err := s.Open(path); err != nil {
		t.Fatal(err)
	}
	t.Cleanup(s.Close)
	return path, s
}

func TestEvidenceLoadMutationSaveReopen(t *testing.T) {
	path, s := evidenceFixture(t)
	data, _ := os.ReadFile(path)
	initial := s.Evidence()
	if initial.LoadedSHA256 != archiveDigest(data) || initial.requireCleanArchive() != nil {
		t.Fatal(initial)
	}
	u := s.Units().Entities[0]
	if err := s.MoveUnit(u.CreationNumber, u.Position[0]+128, u.Position[1], u.Position[2]); err != nil {
		t.Fatal(err)
	}
	mutated := s.Evidence()
	if !mutated.Dirty || mutated.Revision <= initial.Revision || mutated.LoadedSHA256 != initial.LoadedSHA256 {
		t.Fatal(mutated)
	}
	if err := s.Undo(); err != nil {
		t.Fatal(err)
	}
	if s.Evidence().Revision <= mutated.Revision || !s.Evidence().Dirty {
		t.Fatal("undo must advance revision and remain dirty")
	}
	if err := s.Redo(); err != nil {
		t.Fatal(err)
	}
	if err := s.Save(); err != nil {
		t.Fatal(err)
	}
	data, _ = os.ReadFile(path)
	saved := s.Evidence()
	if saved.requireCleanArchive() != nil || saved.LoadedSHA256 != archiveDigest(data) || saved.LoadedSHA256 == initial.LoadedSHA256 {
		t.Fatal(saved)
	}
	if err := s.Open(path); err != nil {
		t.Fatal(err)
	}
	if s.Evidence().LoadGeneration <= saved.LoadGeneration || s.Evidence().Revision <= saved.Revision {
		t.Fatal("reopen must be distinguishable")
	}
	s.Close()
	if e := s.Evidence(); e.Loaded || e.LoadedSHA256 != "" || e.Revision <= saved.Revision {
		t.Fatal(e)
	}
}

func TestEvidenceArchiveSnapshotAndSaveBarrier(t *testing.T) {
	path, s := evidenceFixture(t)
	before := s.Evidence()
	original, _, err := s.ReadFile("war3map.w3i")
	if err != nil {
		t.Fatal(err)
	}
	// Replacing the pathname does not alter the archive snapshot supplying assets.
	if err := os.WriteFile(path, []byte("external replacement"), 0644); err != nil {
		t.Fatal(err)
	}
	read, _, err := s.ReadFile("war3map.w3i")
	if err != nil || string(read) != string(original) || s.Evidence().LoadedSHA256 != before.LoadedSHA256 {
		t.Fatal("disk path masqueraded as loaded archive")
	}
	finish := s.beginEvidenceSave()
	if s.Evidence().requireCleanArchive() == nil {
		t.Fatal("save in flight accepted")
	}
	finish(errors.New("failed repack"))
	if s.Evidence().IOPending != 0 || s.Evidence().requireCleanArchive() == nil {
		t.Fatal("failed save accepted")
	}
}

func TestEvidenceStrictCaptureGates(t *testing.T) {
	for _, scenario := range []string{"valid", "wrong-hash", "dirty", "old-renderer", "stale-render", "mutation", "reopen", "saving"} {
		t.Run(scenario, func(t *testing.T) {
			_, s := evidenceFixture(t)
			before := s.Evidence()
			s.OnUICommand(func(command string) {
				var req viewportRequest
				if err := json.Unmarshal([]byte(strings.TrimPrefix(command, "viewport.request ")), &req); err != nil {
					t.Fatal(err)
				}
				result := map[string]any{"renderer_evidence_version": 1, "rendered_evidence": before, "frame": 12}
				switch scenario {
				case "old-renderer":
					delete(result, "renderer_evidence_version")
				case "stale-render":
					stale := before
					stale.Revision--
					result["rendered_evidence"] = stale
				case "mutation":
					u := s.Units().Entities[0]
					_ = s.MoveUnit(u.CreationNumber, u.Position[0]+128, u.Position[1], u.Position[2])
				case "reopen":
					if err := s.Open(before.Path); err != nil {
						t.Fatal(err)
					}
				}
				b, _ := json.Marshal(result)
				s.CompleteViewportRequest(req.ID, string(b), "")
			})
			requiredSHA := before.LoadedSHA256
			switch scenario {
			case "wrong-hash":
				requiredSHA = strings.Repeat("0", 64)
			case "dirty":
				u := s.Units().Entities[0]
				_ = s.MoveUnit(u.CreationNumber, u.Position[0]+128, u.Position[1], u.Position[2])
			case "saving":
				finish := s.beginEvidenceSave()
				defer finish(errors.New("test"))
			}
			args, _ := json.Marshal(map[string]any{"require_clean": true, "expected_sha256": requiredSHA, "expected_revision": before.Revision})
			_, err := s.requestViewport("viewport.screenshot", args, time.Second)
			if (err == nil) != (scenario == "valid") {
				t.Fatalf("scenario=%s err=%v", scenario, err)
			}
		})
	}
}
