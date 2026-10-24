package mpq

import (
	"bytes"
	"strings"
	"testing"
)

func TestLosslessRetainsKnownImportNames(t *testing.T) {
	const model = `war3mapImported\dummy.mdx`
	const deleted = `custom\removed.blp`
	original, err := Build([]FileEntry{{Name: model, Data: bytes.Repeat([]byte("model payload"), 64)}, {Name: deleted, Data: []byte("texture")}})
	if err != nil {
		t.Fatal(err)
	}
	a, err := OpenReader(bytes.NewReader(original), int64(len(original)))
	if err != nil {
		t.Fatal(err)
	}
	defer a.Close()
	raw, err := a.RawEntries()
	if err != nil {
		t.Fatal(err)
	}
	_, lfA, lfB := HashName(listfileName)
	_, delA, delB := HashName(deleted)
	var keep []RawEntry
	for _, entry := range raw {
		if (entry.HashA == lfA && entry.HashB == lfB) || (entry.HashA == delA && entry.HashB == delB) {
			continue
		}
		keep = append(keep, entry)
	}
	names := append(a.List(), strings.ToUpper(model), "not-present.mdx")
	result, err := BuildLossless(keep, []FileEntry{{Name: "added.txt", Data: []byte("new")}}, a.HashTableSize(), a.SectorSizeShift(), true, names...)
	if err != nil {
		t.Fatal(err)
	}
	b, err := OpenReader(bytes.NewReader(result), int64(len(result)))
	if err != nil {
		t.Fatal(err)
	}
	defer b.Close()
	payload, err := b.Read(model)
	if err != nil || !bytes.Equal(payload, bytes.Repeat([]byte("model payload"), 64)) {
		t.Fatalf("import: %q, %v", payload, err)
	}
	listfile, err := b.Read(listfileName)
	if err != nil {
		t.Fatal(err)
	}
	listed := strings.Split(strings.ToUpper(strings.TrimSpace(string(listfile))), "\r\n")
	want := []string{strings.ToUpper(model), "ADDED.TXT", "(LISTFILE)"}
	if len(listed) != len(want) {
		t.Fatalf("unexpected listfile: %q", listfile)
	}
	for _, name := range want {
		count := 0
		for _, entry := range listed {
			if entry == name {
				count++
			}
		}
		if count != 1 {
			t.Errorf("%s listed %d times", name, count)
		}
	}
	if b.Has(deleted) {
		t.Fatal("deleted import survived")
	}
}
