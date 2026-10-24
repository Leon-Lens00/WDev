package forge

import (
	"encoding/json"
	"strings"
	"testing"
	"time"
)

func TestViewportRequiresFrontend(t *testing.T) {
	s := &Session{}
	if _, err := s.requestViewport("camera.get_state", nil, time.Millisecond); err == nil {
		t.Fatal("headless viewport request must fail")
	}
}

func TestModelPreviewAcknowledgedWithoutMapMutation(t *testing.T) {
	s := &Session{}
	before := s.Evidence()
	s.OnUICommand(func(cmd string) {
		var request viewportRequest
		_ = json.Unmarshal([]byte(strings.TrimPrefix(cmd, "viewport.request ")), &request)
		if request.Operation != "model_preview.open" {
			t.Error(request.Operation)
		}
		s.CompleteViewportRequest(request.ID, `{"opened":true}`, "")
	})
	result, err := s.requestViewport("model_preview.open", json.RawMessage(`{"kind":"doodad","id":7}`), time.Second)
	if err != nil || !strings.Contains(string(result), `"opened":true`) {
		t.Fatalf("%s %v", result, err)
	}
	if s.Evidence() != before || s.IsDirty() {
		t.Fatal("preview altered map state")
	}
}

func TestViewportAcknowledgementAndTokenRemoval(t *testing.T) {
	s := &Session{}
	s.OnUICommand(func(cmd string) {
		if strings.Contains(cmd, "secret") {
			t.Error("bridge token leaked into frontend")
		}
		var request viewportRequest
		if err := json.Unmarshal([]byte(strings.TrimPrefix(cmd, "viewport.request ")), &request); err != nil {
			t.Fatal(err)
		}
		if request.Operation != "camera.get_state" {
			t.Fatal(request.Operation)
		}
		if s.CompleteViewportRequest(request.ID+1, `{}`, "") {
			t.Error("accepted unrelated reply")
		}
		if !s.CompleteViewportRequest(request.ID, `{"yaw":1}`, "") {
			t.Error("reply rejected")
		}
	})
	result, err := s.requestViewport("camera.get_state", json.RawMessage(`{"_token":"secret"}`), time.Second)
	var payload struct {
		Yaw      int         `json:"yaw"`
		Evidence MapEvidence `json:"evidence"`
	}
	_ = json.Unmarshal(result, &payload)
	if err != nil || payload.Yaw != 1 || payload.Evidence.Version != 1 {
		t.Fatalf("result=%s err=%v", result, err)
	}
	if s.IsDirty() {
		t.Fatal("camera dirtied map")
	}
}

func TestViewportTimeoutAndLateReply(t *testing.T) {
	s := &Session{}
	var id uint64
	s.OnUICommand(func(cmd string) {
		var request viewportRequest
		_ = json.Unmarshal([]byte(strings.TrimPrefix(cmd, "viewport.request ")), &request)
		id = request.ID
	})
	if _, err := s.requestViewport("viewport.screenshot", nil, 5*time.Millisecond); err == nil {
		t.Fatal("missing timeout")
	}
	if s.CompleteViewportRequest(id, `{}`, "") {
		t.Fatal("accepted late reply")
	}
}

func TestViewportFrontendError(t *testing.T) {
	s := &Session{}
	s.OnUICommand(func(cmd string) {
		var request viewportRequest
		_ = json.Unmarshal([]byte(strings.TrimPrefix(cmd, "viewport.request ")), &request)
		s.CompleteViewportRequest(request.ID, "", "map still loading")
	})
	if _, err := s.requestViewport("viewport.screenshot", nil, time.Second); err == nil || !strings.Contains(err.Error(), "map still loading") {
		t.Fatal(err)
	}
}
