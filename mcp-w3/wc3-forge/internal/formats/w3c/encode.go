package w3c

import (
	"bytes"
	"encoding/binary"
	"fmt"
	"strings"
)

// Encode preserves the source layout; classic cameras never gain 1.31 fields.
func Encode(f *File) ([]byte, error) {
	if f == nil || len(f.Cameras) > 10000 {
		return nil, fmt.Errorf("invalid camera table")
	}
	var b bytes.Buffer
	put := func(v any) { _ = binary.Write(&b, binary.LittleEndian, v) }
	put(f.Version)
	put(uint32(len(f.Cameras)))
	for _, c := range f.Cameras {
		if strings.ContainsRune(c.Name, 0) {
			return nil, fmt.Errorf("camera name contains NUL")
		}
		for _, v := range []float32{c.TargetX, c.TargetY, c.ZOffset, c.Rotation, c.AngleOfAttack, c.Distance, c.Roll, c.FOV, c.FarZ, c.NearZ} {
			put(v)
		}
		if c.Has131Locals {
			put(c.LocalPitch)
			put(c.LocalYaw)
			put(c.LocalRoll)
		}
		b.WriteString(c.Name)
		b.WriteByte(0)
	}
	return b.Bytes(), nil
}
