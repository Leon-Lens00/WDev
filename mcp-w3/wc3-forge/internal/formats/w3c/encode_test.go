package w3c

import (
	"bytes"
	"encoding/binary"
	"reflect"
	"testing"
)

func TestEncodeClassicAndModernRoundtrip(t *testing.T) {
	for _, modern := range []bool{false, true} {
		f := &File{Cameras: []Camera{{Name: "Camera_001", TargetX: -2048, TargetY: 1024, ZOffset: 100, Rotation: 204.5095, AngleOfAttack: 315, Distance: 1650, FOV: 70, FarZ: 10000, Has131Locals: modern}, {Name: "Camera_002", Rotation: 90, Has131Locals: modern}}}
		raw, e := Encode(f)
		if e != nil {
			t.Fatal(e)
		}
		got, e := Parse(raw)
		if e != nil || !reflect.DeepEqual(f, got) {
			t.Fatal("camera semantic roundtrip", e)
		}
		again, e := Encode(got)
		if e != nil || !bytes.Equal(raw, again) {
			t.Fatal("camera byte roundtrip")
		}
		if !modern && len(raw) != 8+2*40+len("Camera_001")+len("Camera_002")+2 {
			t.Fatal("modern fields leaked into classic")
		}
	}
}
func TestCameraRejectsTruncationAndExcessCount(t *testing.T) {
	f := &File{Cameras: []Camera{{Name: "Camera_001", Rotation: 270}}}
	raw, _ := Encode(f)
	for _, b := range [][]byte{raw[:len(raw)-1], append(append([]byte{}, raw...), 1)} {
		if _, e := Parse(b); e == nil {
			t.Fatal("malformed camera accepted")
		}
	}
	binary.LittleEndian.PutUint32(raw[4:], 10001)
	if _, e := Parse(raw); e == nil {
		t.Fatal("excess count accepted")
	}
	f.Cameras[0].Name = "bad\x00name"
	if _, e := Encode(f); e == nil {
		t.Fatal("NUL name accepted")
	}
}
