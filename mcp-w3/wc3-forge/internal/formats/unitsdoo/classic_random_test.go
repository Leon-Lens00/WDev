package unitsdoo

import (
	"bytes"
	"os"
	"testing"
)

func TestClassicNoRandomSelectionRoundTrip(t *testing.T) {
	// First start-location record from Relativistic Missiles 2.8 Classic.
	// Subversion 11, no skin, random flag -1 and no random-data payload.
	data, err := os.ReadFile("testdata/classic-no-random.doo")
	if err != nil {
		t.Fatal(err)
	}
	f, err := Parse(data)
	if err != nil {
		t.Fatal(err)
	}
	if len(f.Entities) != 1 || f.Entities[0].TypeID != "sloc" || f.Entities[0].RandomType != ^uint32(0) || len(f.Entities[0].RandomData) != 0 {
		t.Fatalf("incorrect Classic sentinel decode: %+v", f.Entities)
	}
	out, err := Encode(f)
	if err != nil {
		t.Fatal(err)
	}
	if !bytes.Equal(data, out) {
		t.Fatal("Classic record changed on round trip")
	}
	f.Entities[0].RandomData = []byte{1, 2, 3, 4}
	if _, err := Encode(f); err == nil {
		t.Fatal("unexpected random payload was silently lost")
	}
}
