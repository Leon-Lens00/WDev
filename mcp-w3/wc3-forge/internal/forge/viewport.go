package forge

import (
	"encoding/json"
	"fmt"
	"strings"
	"sync"
	"time"

	"github.com/StephenSHorton/wc3-forge/internal/bridge"
)

// Viewport operations belong to the frontend, not the map's undo history.
// An acknowledged request prevents capturing the old view after a camera move.
type viewportRequest struct {
	ID        uint64                     `json:"id"`
	Operation string                     `json:"operation"`
	Args      map[string]json.RawMessage `json:"args"`
	Deadline  int64                      `json:"deadline"`
	Evidence  *MapEvidence               `json:"expected_evidence,omitempty"`
}
type viewportReply struct {
	result json.RawMessage
	err    string
}
type viewportRequests struct {
	serial  sync.Mutex
	mu      sync.Mutex
	next    uint64
	pending map[uint64]chan viewportReply
}

func (s *Session) requestViewport(operation string, args json.RawMessage, timeout time.Duration) (json.RawMessage, error) {
	if !s.viewport.serial.TryLock() {
		return nil, fmt.Errorf("viewport is busy; retry after the current request completes")
	}
	defer s.viewport.serial.Unlock()
	s.mu.RLock()
	ready := len(s.uiCommandListeners) > 0
	s.mu.RUnlock()
	if !ready {
		return nil, fmt.Errorf("viewport requires a running GUI editor (headless mode has no renderer)")
	}
	params := map[string]json.RawMessage{}
	if len(args) > 0 {
		if err := json.Unmarshal(args, &params); err != nil {
			return nil, fmt.Errorf("invalid viewport arguments: %w", err)
		}
	}
	delete(params, "_token")
	before := s.Evidence()
	var requirements struct {
		RequireClean bool    `json:"require_clean"`
		SHA          string  `json:"expected_sha256"`
		Revision     *uint64 `json:"expected_revision"`
	}
	if len(args) > 0 {
		if err := json.Unmarshal(args, &requirements); err != nil {
			return nil, err
		}
	}
	strict := requirements.RequireClean || requirements.SHA != "" || requirements.Revision != nil
	if strict && operation != "viewport.screenshot" {
		return nil, fmt.Errorf("evidence requirements apply only to screenshots")
	}
	var expected *MapEvidence
	if strict {
		if err := before.requireCleanArchive(); err != nil {
			return nil, err
		}
		if requirements.SHA != "" && requirements.SHA != before.LoadedSHA256 {
			return nil, fmt.Errorf("loaded archive SHA256 differs from expected")
		}
		if requirements.Revision != nil && *requirements.Revision != before.Revision {
			return nil, fmt.Errorf("map revision differs from expected")
		}
		expected = &before
	}
	delete(params, "require_clean")
	delete(params, "expected_sha256")
	delete(params, "expected_revision")
	s.viewport.mu.Lock()
	s.viewport.next++
	id := s.viewport.next
	reply := make(chan viewportReply, 1)
	if s.viewport.pending == nil {
		s.viewport.pending = make(map[uint64]chan viewportReply)
	}
	s.viewport.pending[id] = reply
	s.viewport.mu.Unlock()
	defer func() { s.viewport.mu.Lock(); delete(s.viewport.pending, id); s.viewport.mu.Unlock() }()
	payload, err := json.Marshal(viewportRequest{ID: id, Operation: operation, Args: params, Deadline: time.Now().Add(timeout).UnixMilli(), Evidence: expected})
	if err != nil {
		return nil, err
	}
	s.EmitUICommand("viewport.request " + string(payload))
	timer := time.NewTimer(timeout)
	defer timer.Stop()
	select {
	case response := <-reply:
		if response.err != "" {
			return nil, fmt.Errorf("viewport: %s", response.err)
		}
		after := s.Evidence()
		if strings.HasPrefix(operation, "model_preview.") && before != after {
			return nil, fmt.Errorf("map changed during model preview request; reopen preview")
		}
		var result map[string]json.RawMessage
		if err := json.Unmarshal(response.result, &result); err != nil || result == nil {
			return nil, fmt.Errorf("invalid viewport response object")
		}
		if strict {
			if before != after {
				return nil, fmt.Errorf("map changed during capture")
			}
			if err := after.requireCleanArchive(); err != nil {
				return nil, err
			}
			var version int
			var rendered MapEvidence
			_ = json.Unmarshal(result["renderer_evidence_version"], &version)
			_ = json.Unmarshal(result["rendered_evidence"], &rendered)
			if version != 1 {
				return nil, fmt.Errorf("renderer lacks evidence v1; rebuild GUI with current frontend")
			}
			if rendered != before {
				return nil, fmt.Errorf("renderer represents a different map revision; reopen map before certified capture")
			}
		}
		result["evidence"], _ = json.Marshal(after)
		result["runtime"], _ = json.Marshal(captureRuntimeEvidence())
		return json.Marshal(result)
	case <-timer.C:
		return nil, fmt.Errorf("viewport timed out; the GUI may be loading, minimized, or unresponsive")
	}
}

// CompleteViewportRequest is called only by the Wails frontend binding.
func (s *Session) CompleteViewportRequest(id uint64, result, message string) bool {
	s.viewport.mu.Lock()
	defer s.viewport.mu.Unlock()
	reply, ok := s.viewport.pending[id]
	if !ok {
		return false
	}
	if message == "" && !json.Valid([]byte(result)) {
		message = "invalid frontend response"
	}
	delete(s.viewport.pending, id)
	reply <- viewportReply{json.RawMessage(result), message}
	return true
}

func registerViewportHandlers(reg func(string, bridge.Handler)) {
	for _, operation := range []string{"camera.get_state", "camera.set_state", "camera.frame", "viewport.screenshot",
		"model_preview.open", "model_preview.get_state", "model_preview.set_camera", "model_preview.set_animation", "model_preview.screenshot", "model_preview.close"} {
		reg(operation, func(args json.RawMessage) (any, error) {
			return Current.requestViewport(operation, args, 25*time.Second)
		})
	}
}
