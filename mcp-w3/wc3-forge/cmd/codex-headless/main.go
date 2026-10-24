// codex-headless hosts wc3-forge's real editing bridge without the Wails GUI.
// It does not render a viewport, mount CASC, or run Warcraft III.
package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"os/signal"
	"path/filepath"
	"strings"
	"syscall"

	"github.com/StephenSHorton/wc3-forge/internal/bridge"
	"github.com/StephenSHorton/wc3-forge/internal/forge"
)

func main() {
	assets := flag.String("assets", "", "explicit local directory of extracted stock tables")
	open := flag.String("open", "", "map to open")
	fixture := flag.String("fixture", "", "create a fresh Classic-format technical test fixture (not a playable map)")
	target := flag.String("target", os.Getenv("WC3FORGE_TARGET"), "authoring target: empty for editor defaults, or 1.27b")
	flag.Parse()
	if *target != "" && *target != "1.27b" {
		log.Fatal("unsupported authoring target; use 1.27b or omit --target")
	}
	if err := forge.Current.SetClassic127b(*target == "1.27b"); err != nil {
		log.Fatal(err)
	}
	if *fixture != "" {
		if err := writeFixture(*fixture); err != nil {
			log.Fatal(err)
		}
	}
	forge.SetBaseAssetReader(func(name string) ([]byte, bool, error) {
		if data, found, err := forge.Current.ReadFile(name); err == nil && found {
			return data, true, nil
		}
		if *assets == "" {
			return nil, false, nil
		}
		name = filepath.Clean(strings.ReplaceAll(name, "\\", "/"))
		if filepath.IsAbs(name) || name == ".." || strings.HasPrefix(name, "../") {
			return nil, false, fmt.Errorf("invalid asset path")
		}
		data, err := os.ReadFile(filepath.Join(*assets, name))
		if os.IsNotExist(err) {
			return nil, false, nil
		}
		return data, err == nil, err
	})
	if *open != "" {
		if err := forge.Current.Open(*open); err != nil {
			log.Fatal(err)
		}
	}
	b := bridge.New()
	forge.RegisterAll(b)
	if err := b.Start(); err != nil {
		log.Fatal(err)
	}
	defer b.Stop()
	fmt.Printf("wc3-forge headless bridge: pid=%d port=%d (no GUI/game runtime)\n", os.Getpid(), b.Port())
	sigs := make(chan os.Signal, 1)
	signal.Notify(sigs, syscall.SIGINT, syscall.SIGTERM)
	<-sigs
}
