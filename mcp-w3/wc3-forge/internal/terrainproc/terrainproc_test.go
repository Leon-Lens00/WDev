package terrainproc

import (
	"bytes"
	"encoding/binary"
	"testing"
)

func TestPathingChannelsOriginAndRLE(t *testing.T) {
	b := make([]byte, 18)
	b[2] = 2
	b[12] = 2
	b[14] = 2
	b[16] = 24
	b[17] = 32
	b = append(b, 0, 0, 255, 0, 255, 0, 255, 0, 0, 255, 255, 255)
	fp, e := DecodePathing(b)
	if e != nil {
		t.Fatal(e)
	}
	if !bytes.Equal(fp.Cells, []byte{8, 14, 2, 4}) {
		t.Fatalf("channel/origin mismatch %v", fp.Cells)
	}
	b = b[:18]
	b[2] = 10
	b[17] = 0
	b = append(b, 0x83, 255, 0, 255)
	fp, e = DecodePathing(b)
	if e != nil {
		t.Fatal(e)
	}
	if !bytes.Equal(fp.Cells, []byte{10, 10, 10, 10}) {
		t.Fatal(fp.Cells)
	}
	b = b[:len(b)-1]
	if _, e = DecodePathing(b); e == nil {
		t.Fatal("truncated RLE accepted")
	}
}
func TestLosslessObjectTransfer(t *testing.T) {
	b := []byte{2, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0}
	r := append([]byte("ATtrB000"), 1, 0, 0, 0)
	r = append(r, []byte("bfil")...)
	r = append(r, 3, 0, 0, 0)
	r = append(r, []byte("old.mdl\x00")...)
	r = append(r, 0, 0, 0, 0)
	b = append(b, r...)
	_, c, e := objectRecords(b, false)
	if e != nil || !bytes.Equal(c[0], r) {
		t.Fatal(e)
	}
	next := transformRecord(r, false, "T001", map[string]string{"old.mdx": "new.mdx"}, nil)
	out, e := appendRecord(b, next, false)
	if e != nil {
		t.Fatal(e)
	}
	_, c, e = objectRecords(out, false)
	if e != nil || len(c) != 2 || !bytes.Equal(c[0], r) || string(c[1][4:8]) != "T001" || !bytes.Contains(c[1], []byte("new.mdx")) {
		t.Fatal("record preservation/remapping failed", e)
	}
	if binary.LittleEndian.Uint32(c[1][16:]) != 3 {
		t.Fatal("wire type changed")
	}
	if _, _, e = objectRecords(out[:len(out)-1], false); e == nil {
		t.Fatal("truncated records accepted")
	}
}
func TestProtectedPathGeometry(t *testing.T) {
	s := Spec{Edit: Rect{[2]float64{0, 0}, [2]float64{1024, 1024}}, Protected: []Rect{{[2]float64{256, 256}, [2]float64{512, 512}}}, Path: [][2]float64{{0, 0}, {1024, 0}, {1024, 1024}}}
	if s.Editable(300, 300) || s.Editable(-1, 0) || !s.Editable(700, 700) {
		t.Fatal("protection")
	}
	if s.PathDistance(512, 128) != 128 {
		t.Fatal("segment distance")
	}
}
