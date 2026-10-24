package main

import (
	"bytes"
	"encoding/json"
	"os"
	"path/filepath"
	"testing"
)

func TestCLIContracts(t *testing.T) {
	root := t.TempDir()
	if e := os.WriteFile(filepath.Join(root, "main.j"), []byte("function F takes nothing returns nothing\nendfunction\n"), 0644); e != nil {
		t.Fatal(e)
	}
	for _, args := range [][]string{{}, {"-root", root, "-format", "invalid"}, {"-root", root, "unexpected"}} {
		var out, err bytes.Buffer
		if run(args, &out, &err) != 2 || err.Len() == 0 {
			t.Fatalf("accepted invalid arguments: %v", args)
		}
	}
	var out, err bytes.Buffer
	if code := run([]string{"-root", root, "-symbol", "F", "-format", "json"}, &out, &err); code != 0 {
		t.Fatalf("exit %d: %s", code, err.String())
	}
	var result struct {
		Symbols []struct {
			Name string `json:"name"`
		}
	}
	if e := json.Unmarshal(out.Bytes(), &result); e != nil {
		t.Fatal(e)
	}
	if len(result.Symbols) != 1 || result.Symbols[0].Name != "F" {
		t.Fatalf("wrong output: %s", out.String())
	}
}
