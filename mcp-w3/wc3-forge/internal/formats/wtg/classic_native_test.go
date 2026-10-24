package wtg

import (
	"bytes"
	"encoding/binary"
	"testing"
)

func TestClassicNativeMagicRoundTrip(t *testing.T) {
	for _, version := range []uint32{4, 7} {
		raw := make([]byte, 24)
		copy(raw, "WTG!")
		binary.LittleEndian.PutUint32(raw[4:], version)
		binary.LittleEndian.PutUint32(raw[12:], 2)
		v, e := Parse(raw, map[string]int{})
		if e != nil {
			t.Fatal(e)
		}
		if !v.IsPre131 || !v.PreMagic {
			t.Fatal("Classic header misclassified")
		}
		out, e := Encode(v, nil)
		if e != nil || !bytes.Equal(raw, out) {
			t.Fatalf("native roundtrip: %v", e)
		}
	}
}
