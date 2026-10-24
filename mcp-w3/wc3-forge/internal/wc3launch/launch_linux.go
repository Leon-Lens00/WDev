//go:build linux

package wc3launch

// Linux can host the map-editing bridge, but this package does not manage Wine.
// Keep the game launch unavailable rather than resolving a Windows executable.
var binaryRelPath []string
