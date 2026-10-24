package w3objmod

import (
	"bytes"
	"encoding/binary"
	"math"
	"testing"
)

// Assemble bytes independently of Encode: strings that look like integers,
// whole-valued reals, and unreal tags must survive edit/save cycles.
func typedFixture(opt bool) []byte {
	b := new(bytes.Buffer)
	u := func(n uint32) { _ = binary.Write(b, binary.LittleEndian, n) }
	u(2)
	u(0)
	u(1)
	b.WriteString("hfoo")
	b.WriteString("u001")
	u(4)
	for i, row := range []struct {
		id  string
		typ uint32
	}{
		{"unam", 3}, {"usca", 1}, {"udtm", 2}, {"uhpm", 0},
	} {
		b.WriteString(row.id)
		u(row.typ)
		if opt {
			u(uint32(i + 1))
			u(1)
		}
		switch row.typ {
		case 3:
			b.WriteString("001\x00")
		case 1:
			u(math.Float32bits(1))
		case 2:
			u(math.Float32bits(2.6))
		case 0:
			u(100)
		}
		u(0)
	}
	return b.Bytes()
}

func TestPreserveWireTypesWithoutMetadata(t *testing.T) {
	for _, opt := range []bool{false, true} {
		data := typedFixture(opt)
		for cycle := 0; cycle < 2; cycle++ {
			f, err := Parse(data, opt, nil)
			if err != nil {
				t.Fatal(err)
			}
			encoded, err := Encode(f, opt, nil)
			if err != nil {
				t.Fatal(err)
			}
			// Field order is canonicalized, so independently locate each unique
			// FourCC and read its following tag directly from output bytes.
			for id, want := range map[string]uint32{"unam": 3, "usca": 1, "udtm": 2, "uhpm": 0} {
				i := bytes.Index(encoded, []byte(id))
				if i < 0 {
					t.Fatalf("missing %s", id)
				}
				if got := binary.LittleEndian.Uint32(encoded[i+4 : i+8]); got != want {
					t.Fatalf("opt=%v cycle=%d %s type=%d want=%d", opt, cycle, id, got, want)
				}
			}
			if !bytes.Contains(encoded, []byte("001\x00")) {
				t.Fatal("numeric string changed")
			}
			data = encoded
		}
	}
}

func TestMetadataTypesForNewAndEditedFields(t *testing.T) {
	f, err := Parse(typedFixture(false), false, nil)
	if err != nil {
		t.Fatal(err)
	}
	f.Customs[0].Overrides["usca"] = "2"
	f.Customs[0].Overrides["udtm"] = "3"
	f.Customs[0].Overrides["unew"] = "0002"
	f.Customs[0].Overrides["uflt"] = "1"
	f.Customs[0].Overrides["unrl"] = "2.6"
	hints := TypeHints{"unew": 3, "uflt": 1, "unrl": 2}
	data, err := EncodeWithTypes(f, false, nil, hints)
	if err != nil {
		t.Fatal(err)
	}
	for id, want := range map[string]uint32{"usca": 1, "udtm": 2, "unew": 3, "uflt": 1, "unrl": 2} {
		i := bytes.Index(data, []byte(id))
		if i < 0 {
			t.Fatalf("missing %s", id)
		}
		if got := binary.LittleEndian.Uint32(data[i+4 : i+8]); got != want {
			t.Fatalf("%s type=%d want=%d", id, got, want)
		}
	}
	f.Customs[0].Overrides["uflt"] = "invalid"
	if _, err := EncodeWithTypes(f, false, nil, hints); err == nil {
		t.Fatal("invalid real accepted")
	}
}
