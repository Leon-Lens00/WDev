package terrainproc

import (
	"bytes"
	"encoding/json"
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func TestRealTransferConflicts(t *testing.T) {
	spec := os.Getenv("WC3_TERRAIN_SPEC")
	if spec == "" {
		t.Skip("set WC3_TERRAIN_SPEC for installed classic asset integration")
	}
	s, e := ReadSpec(spec)
	if e != nil {
		t.Fatal(e)
	}
	src, e := Load(s.Source)
	if e != nil {
		t.Fatal(e)
	}
	out := t.TempDir()
	target := filepath.Join(out, "conflict.w3x")
	// Genuine, different BLP bytes at the same texture path, and already occupied rawcodes.
	if e = src.Write(target, map[string][]byte{"belshirtreeb.blp": src.Files["sandbagskn.blp"]}); e != nil {
		t.Fatal(e)
	}
	result := filepath.Join(out, "transfer.w3x")
	if e = Transfer(s.Source, target, s.Install, result, []string{"B003", "D006"}, [2]float64{1536, -2048}); e != nil {
		t.Fatal(e)
	}
	data, e := os.ReadFile(result + ".transfer.json")
	if e != nil {
		t.Fatal(e)
	}
	var r struct {
		Rawcodes map[string]string `json:"rawcodes"`
		Paths    map[string]string `json:"paths"`
	}
	if e = json.Unmarshal(data, &r); e != nil {
		t.Fatal(e)
	}
	if r.Rawcodes["B003"] == "B003" || !strings.HasPrefix(r.Paths["belshirtreeb.blp"], "terrainproc\\") {
		t.Fatal("collision not resolved", r)
	}
	check, e := Load(result)
	if e != nil {
		t.Fatal(e)
	}
	if !bytes.Equal(check.Files["belshirtreeb.blp"], src.Files["sandbagskn.blp"]) {
		t.Fatal("existing texture overwritten")
	}
	if !bytes.Equal(check.Files[key(r.Paths["belshirtreeb.blp"])], src.Files["belshirtreeb.blp"]) {
		t.Fatal("imported texture mismatch")
	}
	oldO, oldC, e := objectRecords(src.Files["war3map.w3b"], false)
	if e != nil {
		t.Fatal(e)
	}
	newO, newC, e := objectRecords(check.Files["war3map.w3b"], false)
	if e != nil {
		t.Fatal(e)
	}
	for i, v := range oldO {
		if !bytes.Equal(v, newO[i]) {
			t.Fatal("original definition changed")
		}
	}
	for i, v := range oldC {
		if !bytes.Equal(v, newC[i]) {
			t.Fatal("custom definition changed")
		}
	}
}
