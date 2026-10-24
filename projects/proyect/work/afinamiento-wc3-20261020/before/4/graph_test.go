package jassgraph

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func fixture(t *testing.T, files map[string]string) string {
	t.Helper()
	root := t.TempDir()
	for name, text := range files {
		p := filepath.Join(root, name)
		if err := os.MkdirAll(filepath.Dir(p), 0755); err != nil {
			t.Fatal(err)
		}
		if err := os.WriteFile(p, []byte(text), 0644); err != nil {
			t.Fatal(err)
		}
	}
	return root
}
func scan(t *testing.T, root string) *Graph {
	t.Helper()
	g, e := Scan(root)
	if e != nil {
		t.Fatal(e)
	}
	return g
}

func TestSourceLocationsReferencesAndComments(t *testing.T) {
	src := "/* fake function Hidden takes nothing returns nothing\ncall Fake() */\nfunction Target takes nothing returns nothing\nendfunction\nfunction Start takes nothing returns nothing\nlocal string s = \"call Fake() /* string */\"\ncall Target() // Fake()\ncall TriggerAddAction(t, function Target)\ncall Outer(Inner())\nendfunction\n"
	root := fixture(t, map[string]string{"main.j": src})
	g := scan(t, root)
	if len(g.Symbols) != 2 || g.Symbols[0].Line != 3 || g.Symbols[1].EndLine != 10 {
		t.Fatalf("definitions: %+v", g.Symbols)
	}
	if len(g.Calls) != 5 {
		t.Fatalf("references: %+v", g.Calls)
	}
	if g.Calls[0].Target != "Target" || g.Calls[0].Line != 7 || g.Calls[0].Column != 6 || g.Calls[0].Resolution != "lexical_candidate" {
		t.Fatalf("call: %+v", g.Calls[0])
	}
	if g.Calls[2].Kind != "function_reference" || g.Calls[2].Target != "Target" {
		t.Fatalf("callback: %+v", g.Calls[2])
	}
	if len(g.Query("Target").Calls) != 2 {
		t.Fatalf("incoming query: %+v", g.Query("Target"))
	}
	after, e := os.ReadFile(filepath.Join(root, "main.j"))
	if e != nil || string(after) != src {
		t.Fatal("source was modified")
	}
}
func TestVJASSScopeDependenciesAndUnresolvedMembers(t *testing.T) {
	src := "library Demo initializer Init requires optional TimerUtils, Damage\nprivate function Init takes nothing returns nothing\ncall Work()\nendfunction\nfunction Work takes nothing returns nothing\ncall Damage.apply()\ncall this.tick()\ncall .tick()\nendfunction\nstruct Missile\nstatic method create takes nothing returns thistype\nreturn 0\nendmethod\nendstruct\nendlibrary\n"
	g := scan(t, fixture(t, map[string]string{"demo.j": src}))
	if len(g.Diagnostics) != 0 {
		t.Fatalf("diagnostics: %+v", g.Diagnostics)
	}
	if len(g.Dependencies) != 2 || !g.Dependencies[0].Optional || g.Dependencies[1].Optional {
		t.Fatalf("dependencies: %+v", g.Dependencies)
	}
	if g.Calls[0].Kind != "initializer" || g.Calls[0].Resolution != "lexical_candidate" {
		t.Fatalf("initializer: %+v", g.Calls[0])
	}
	if len(g.Query("Demo.Missile.create").Symbols) != 1 {
		t.Fatal("missing scoped method")
	}
	for _, c := range g.Calls[2:] {
		if c.Resolution != "member_unresolved" || len(c.Candidates) != 0 {
			t.Fatalf("guessed member: %+v", c)
		}
	}
}
func TestDuplicatesRemainAmbiguous(t *testing.T) {
	g := scan(t, fixture(t, map[string]string{"a.j": "function F takes nothing returns nothing\nendfunction\n", "b.j": "function F takes nothing returns nothing\ncall F()\nendfunction\n"}))
	if g.Calls[0].Resolution != "ambiguous" || len(g.Calls[0].Candidates) != 2 || len(g.Query("F").Symbols) != 2 {
		t.Fatalf("collapsed duplicate: %+v", g)
	}
}

func TestNestedPrivateAccessAndMemberQueries(t *testing.T) {
	src := "library L\nprivate function Help takes nothing returns nothing\nendfunction\nstruct S\nmethod tick takes nothing returns nothing\ncall Help()\ncall S.tick()\nendmethod\nendstruct\nendlibrary\n"
	g := scan(t, fixture(t, map[string]string{"scope.j": src}))
	if g.Calls[0].Resolution != "lexical_candidate" || g.Calls[0].CallerName != "L.S.tick" {
		t.Fatalf("lost visible private function: %+v", g.Calls[0])
	}
	q := g.Query("L.S.tick")
	if len(q.Symbols) != 1 || len(q.Calls) != 2 || q.Calls[1].Resolution != "member_unresolved" {
		t.Fatalf("lost unresolved member reference: %+v", q)
	}
}
func TestMacrosAndUnsupportedSourcesAreReported(t *testing.T) {
	g := scan(t, fixture(t, map[string]string{"macro.j": "//! textmacro M\nfunction Phantom takes nothing returns nothing\nendfunction\n//! endtextmacro\n//! runtextmacro M()\n", "broken.j": "function Bad takes nothing returns nothing\ncall F(\"unterminated\n"}))
	if len(g.Symbols) != 0 || len(g.Diagnostics) < 3 {
		t.Fatalf("invented expansion or swallowed error: %+v", g)
	}
}
func TestProjectBoundaryAndExclusions(t *testing.T) {
	root := fixture(t, map[string]string{"main.j": "function F takes nothing returns nothing\nendfunction", "build/generated.j": "function Noise takes nothing returns nothing\nendfunction", "note.txt": "call Ignore()"})
	outside := fixture(t, map[string]string{"secret.j": "function Outside takes nothing returns nothing\nendfunction"})
	if err := os.Symlink(outside, filepath.Join(root, "linked")); err != nil {
		t.Fatal(err)
	}
	if err := os.Symlink(filepath.Join(outside, "secret.j"), filepath.Join(root, "outside.j")); err != nil {
		t.Fatal(err)
	}
	g := scan(t, root)
	if len(g.Sources) != 1 || len(g.Symbols) != 1 || len(g.Skipped) != 3 {
		t.Fatalf("scope escaped: %+v", g)
	}
	if _, e := os.Stat(filepath.Join(root, ".jassgraph")); !os.IsNotExist(e) {
		t.Fatal("unexpected index write")
	}
}
func TestInvalidRootAndOversizeFailClearly(t *testing.T) {
	root := fixture(t, map[string]string{"large.j": strings.Repeat(" ", 4<<20+1)})
	if _, e := Scan(root); e == nil {
		t.Fatal("accepted oversized source")
	}
	if _, e := Scan(filepath.Join(root, "large.j")); e == nil {
		t.Fatal("accepted file as root")
	}
}
