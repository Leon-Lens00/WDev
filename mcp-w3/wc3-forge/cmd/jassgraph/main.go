// jassgraph is a read-only lexical source graph, not a map compiler.
package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"os"

	"github.com/StephenSHorton/wc3-forge/internal/jassgraph"
)

func run(args []string, out, stderr io.Writer) int {
	f := flag.NewFlagSet("wc3-jassgraph", flag.ContinueOnError)
	f.SetOutput(stderr)
	root := f.String("root", "", "required source project directory (no archives; nested symlinks skipped)")
	symbol := f.String("symbol", "", "exact simple or qualified symbol name")
	format := f.String("format", "text", "text or json")
	strict := f.Bool("strict", false, "exit 1 after emitting report if lexical coverage is partial")
	if err := f.Parse(args); err != nil {
		if err == flag.ErrHelp {
			return 0
		}
		return 2
	}
	if *root == "" || f.NArg() != 0 || (*format != "text" && *format != "json") {
		fmt.Fprintln(stderr, "Use -root DIRECTORY [-symbol NAME] [-format text|json] [-strict]")
		return 2
	}
	g, err := jassgraph.Scan(*root)
	if err != nil {
		fmt.Fprintln(stderr, err)
		return 1
	}
	if *symbol != "" {
		g = g.Query(*symbol)
	}
	status := 0
	if *strict && g.Coverage == "partial" {
		status = 1
	}
	if *format == "json" {
		e := json.NewEncoder(out)
		e.SetIndent("", "  ")
		if err = e.Encode(g); err != nil {
			fmt.Fprintln(stderr, err)
			return 1
		}
		return status
	}
	fmt.Fprintf(out, "Root: %s\n%s\nCoverage: %s\nSources: %d; definitions: %d; references: %d; diagnostics: %d\n", g.Root, g.Analysis, g.Coverage, len(g.Sources), len(g.Symbols), len(g.Calls), len(g.Diagnostics))
	for _, s := range g.Symbols {
		fmt.Fprintf(out, "DEF %s %s %s:%d:%d\n", s.Kind, s.Qualified, s.File, s.Line, s.Column)
	}
	for _, c := range g.Calls {
		details := c.Kind + "; " + c.Resolution
		if c.QueryMatch != "" {
			details += "; query=" + c.QueryMatch
		}
		fmt.Fprintf(out, "REF %s -> %s [%s] %s:%d:%d\n", c.CallerName, c.Target, details, c.File, c.Line, c.Column)
	}
	for _, d := range g.Dependencies {
		fmt.Fprintf(out, "DEP %s -> %s optional=%t %s:%d\n", d.Library, d.Requires, d.Optional, d.File, d.Line)
	}
	for _, d := range g.Diagnostics {
		fmt.Fprintf(out, "WARN %s:%d %s\n", d.File, d.Line, d.Message)
	}
	if *symbol != "" && len(g.Symbols) == 0 {
		fmt.Fprintln(out, "No matching definition in the scanned sources; this does not prove the symbol is absent from the map.")
	}
	return status
}
func main() { os.Exit(run(os.Args[1:], os.Stdout, os.Stderr)) }
