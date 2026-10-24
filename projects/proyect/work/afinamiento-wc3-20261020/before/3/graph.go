// Package jassgraph builds a conservative, source-preserving lexical graph.
// It reuses Forge's lexer, never the Lua emitter or rewriting preprocessors.
package jassgraph

import (
	"crypto/sha256"
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"sort"
	"strings"

	lex "github.com/StephenSHorton/wc3-forge/internal/forge/jass2lua"
)

type Location struct {
	File   string `json:"file"`
	Line   int    `json:"line"`
	Column int    `json:"column"`
}
type Symbol struct {
	Location
	ID        string `json:"id"`
	Name      string `json:"name"`
	Qualified string `json:"qualified"`
	Kind      string `json:"kind"`
	Scope     string `json:"scope"`
	Private   bool   `json:"private"`
	EndLine   int    `json:"end_line,omitempty"`
}
type Call struct {
	Location
	Caller     string   `json:"caller"`
	CallerName string   `json:"caller_name"`
	Target     string   `json:"target"`
	Kind       string   `json:"kind"`
	Resolution string   `json:"resolution"`
	Candidates []string `json:"candidates"`
}
type Dependency struct {
	Location
	Library  string `json:"library"`
	Requires string `json:"requires"`
	Optional bool   `json:"optional"`
}
type Diagnostic struct {
	Location
	Message string `json:"message"`
}
type Source struct {
	File   string `json:"file"`
	SHA256 string `json:"sha256"`
}
type Graph struct {
	Root         string       `json:"root"`
	Analysis     string       `json:"analysis"`
	Sources      []Source     `json:"sources"`
	Symbols      []Symbol     `json:"symbols"`
	Calls        []Call       `json:"calls"`
	Dependencies []Dependency `json:"dependencies"`
	Diagnostics  []Diagnostic `json:"diagnostics"`
	Skipped      []string     `json:"skipped"`
}

// Scan reads only .j/.jass/.vjass beneath one explicit directory. It does not
// follow directory/file symlinks, extract archives, write indexes or run code.
func Scan(root string) (*Graph, error) {
	root, err := filepath.Abs(root)
	if err != nil {
		return nil, err
	}
	root, err = filepath.EvalSymlinks(root)
	if err != nil {
		return nil, err
	}
	info, err := os.Stat(root)
	if err != nil {
		return nil, err
	}
	if !info.IsDir() {
		return nil, fmt.Errorf("root must be a directory")
	}
	g := &Graph{Root: root, Analysis: "lexical-prototype; not compilation, runtime validation or proof of completeness", Sources: []Source{}, Symbols: []Symbol{}, Calls: []Call{}, Dependencies: []Dependency{}, Diagnostics: []Diagnostic{}, Skipped: []string{}}
	err = filepath.WalkDir(root, func(path string, d fs.DirEntry, walkErr error) error {
		if walkErr != nil {
			return walkErr
		}
		rel, err := filepath.Rel(root, path)
		if err != nil {
			return err
		}
		rel = filepath.ToSlash(rel)
		if d.Type()&os.ModeSymlink != 0 {
			g.Skipped = append(g.Skipped, rel+" (symlink)")
			return nil
		}
		if d.IsDir() {
			if path != root && excluded(d.Name()) {
				g.Skipped = append(g.Skipped, rel+"/")
				return filepath.SkipDir
			}
			return nil
		}
		ext := strings.ToLower(filepath.Ext(path))
		if ext != ".j" && ext != ".jass" && ext != ".vjass" {
			return nil
		}
		if len(g.Sources) >= 2000 {
			return fmt.Errorf("more than 2000 source files; choose a narrower root")
		}
		st, err := d.Info()
		if err != nil {
			return err
		}
		if !st.Mode().IsRegular() || st.Size() > 4<<20 {
			return fmt.Errorf("not a regular file or larger than 4 MiB: %s", rel)
		}
		data, err := os.ReadFile(path)
		if err != nil {
			return err
		}
		g.Sources = append(g.Sources, Source{rel, fmt.Sprintf("%x", sha256.Sum256(data))})
		g.addSource(rel, string(data))
		return nil
	})
	if err != nil {
		return nil, err
	}
	g.resolve()
	return g, nil
}
func excluded(name string) bool {
	switch strings.ToLower(name) {
	case ".git", ".codegraph", ".jassgraph", "node_modules", ".venv", "build", "dist", "backups":
		return true
	}
	return false
}
func (g *Graph) warn(file string, line int, message string) {
	g.Diagnostics = append(g.Diagnostics, Diagnostic{Location{file, line, 1}, message})
}
func (g *Graph) symbol(file string, t lex.Token, kind, scope string, private bool) int {
	q := t.Value
	if scope != "" {
		q = scope + "." + q
	}
	id := fmt.Sprintf("%s:%d:%d", file, t.Line, t.Col)
	g.Symbols = append(g.Symbols, Symbol{Location: Location{file, t.Line, t.Col}, ID: id, Name: t.Value, Qualified: q, Kind: kind, Scope: scope, Private: private})
	return len(g.Symbols) - 1
}

type frame struct {
	name, kind string
	index      int
}

func scopeName(stack []frame) string {
	a := []string{}
	for _, f := range stack {
		a = append(a, f.name)
	}
	return strings.Join(a, ".")
}
func word(t lex.Token) bool { return t.Kind == lex.TokIdent || t.Kind == lex.TokType }
func modifier(s string) bool {
	switch s {
	case "private", "public", "static", "stub", "constant", "debug":
		return true
	}
	return false
}

func (g *Graph) addSource(file, src string) {
	masked, closed := maskBlocks(src)
	if !closed {
		g.warn(file, 1, "Unterminated block comment; source is incomplete")
	}
	tokens, err := lex.Tokenize(masked)
	if err != nil {
		g.warn(file, 1, "Lexer rejected source: "+err.Error())
		return
	}
	stack := []frame{}
	active := -1
	macro := false
	for start := 0; start < len(tokens); {
		end := start
		for end < len(tokens) && tokens[end].Kind != lex.TokEOL && tokens[end].Kind != lex.TokEOF {
			end++
		}
		line := tokens[start:end]
		start = end + 1
		if len(line) == 0 {
			continue
		}
		if line[0].Kind == lex.TokComment {
			c := strings.TrimSpace(line[0].Value)
			if strings.HasPrefix(c, "! textmacro ") {
				macro = true
				g.warn(file, line[0].Line, "Textmacro body omitted; expansions are not analyzed")
			}
			if strings.HasPrefix(c, "! endtextmacro") {
				macro = false
			}
			if strings.HasPrefix(c, "!") && !strings.HasPrefix(c, "! textmacro ") && !strings.HasPrefix(c, "! endtextmacro") {
				g.warn(file, line[0].Line, "Preprocessor directive not expanded: "+c)
			}
			continue
		}
		if macro {
			continue
		}
		for k, t := range line {
			if t.Kind == lex.TokComment {
				line = line[:k]
				break
			}
		}
		if len(line) == 0 {
			continue
		}
		i := 0
		private := false
		for i < len(line) && modifier(line[i].Value) {
			private = private || line[i].Value == "private"
			i++
		}
		if i >= len(line) {
			continue
		}
		head := line[i].Value
		if head == "endfunction" || head == "endmethod" {
			if active < 0 {
				g.warn(file, line[i].Line, "Unmatched "+head)
			} else {
				g.Symbols[active].EndLine = line[i].Line
				active = -1
			}
			continue
		}
		if strings.HasPrefix(head, "end") && len(stack) > 0 && head == "end"+stack[len(stack)-1].kind {
			f := stack[len(stack)-1]
			g.Symbols[f.index].EndLine = line[i].Line
			stack = stack[:len(stack)-1]
			continue
		}
		if head == "library" || head == "library_once" || head == "scope" || head == "struct" || head == "module" || head == "interface" {
			if i+1 >= len(line) || !word(line[i+1]) {
				g.warn(file, line[i].Line, "Malformed scope declaration")
				continue
			}
			kind := head
			if kind == "library_once" {
				kind = "library"
			}
			idx := g.symbol(file, line[i+1], kind, scopeName(stack), private)
			stack = append(stack, frame{line[i+1].Value, kind, idx})
			if kind == "module" || kind == "interface" {
				g.warn(file, line[i].Line, "Module/interface references are lexical only; implementation/dispatch is not expanded")
			}
			dep := false
			optional := false
			for j := i + 2; j < len(line); j++ {
				v := line[j].Value
				if v == "initializer" && j+1 < len(line) {
					j++
					g.Calls = append(g.Calls, Call{Location: Location{file, line[j].Line, line[j].Col}, Caller: g.Symbols[idx].ID, Target: line[j].Value, Kind: "initializer", Candidates: []string{}})
					continue
				}
				if v == "requires" || v == "needs" || v == "uses" {
					dep = true
					continue
				}
				if !dep {
					continue
				}
				if v == "optional" {
					optional = true
					continue
				}
				if v == "," {
					optional = false
					continue
				}
				if word(line[j]) {
					g.Dependencies = append(g.Dependencies, Dependency{Location{file, line[j].Line, line[j].Col}, g.Symbols[idx].Qualified, v, optional})
					optional = false
				}
			}
			continue
		}
		if head == "function" || head == "method" || head == "native" {
			j := i + 1
			if j >= len(line) {
				continue
			}
			if line[j].Value == "interface" || line[j].Value == "operator" {
				g.warn(file, line[j].Line, "Function interface/operator declaration is unsupported")
				continue
			}
			if !word(line[j]) {
				g.warn(file, line[j].Line, "Unsupported function/method name")
				continue
			}
			if active >= 0 {
				g.warn(file, line[j].Line, "Previous function has no closing marker")
			}
			idx := g.symbol(file, line[j], head, scopeName(stack), private)
			if head != "native" && (len(stack) == 0 || stack[len(stack)-1].kind != "interface") {
				active = idx
			}
			continue
		}
		if head == "implement" {
			g.warn(file, line[i].Line, "Module implementation not expanded")
		}
		if active >= 0 {
			g.calls(file, g.Symbols[active].ID, line)
		}
	}
	if macro {
		g.warn(file, 1, "Unclosed textmacro")
	}
	if active >= 0 {
		g.warn(file, g.Symbols[active].Line, "Function/method has no closing marker")
	}
	for _, s := range stack {
		g.warn(file, g.Symbols[s.index].Line, "Unclosed "+s.kind)
	}
}

func (g *Graph) calls(file, caller string, line []lex.Token) {
	for i := 0; i < len(line); i++ {
		t := line[i]
		if t.Value == "function" && i+1 < len(line) && word(line[i+1]) {
			i++
			t = line[i]
			g.Calls = append(g.Calls, Call{Location: Location{file, t.Line, t.Col}, Caller: caller, Target: t.Value, Kind: "function_reference", Candidates: []string{}})
			continue
		}
		if !word(t) {
			continue
		}
		target := t.Value
		j := i + 1
		for j+1 < len(line) && line[j].Value == "." && word(line[j+1]) {
			target += "." + line[j+1].Value
			j += 2
		}
		if j < len(line) && line[j].Value == "(" {
			if i > 0 && line[i-1].Value == "." {
				target = "<implicit-receiver>." + target
			}
			g.Calls = append(g.Calls, Call{Location: Location{file, t.Line, t.Col}, Caller: caller, Target: target, Kind: "call", Candidates: []string{}})
		}
		i = j - 1
	}
}

// Resolve only unqualified lexical names. Member calls stay unresolved: a
// dotted receiver can be a variable, a type, or dynamic vJASS dispatch.
func (g *Graph) resolve() {
	byID := map[string]Symbol{}
	byName := map[string][]Symbol{}
	for _, s := range g.Symbols {
		byID[s.ID] = s
		if s.Kind == "function" || s.Kind == "method" || s.Kind == "native" {
			byName[s.Qualified] = append(byName[s.Qualified], s)
		}
	}
	for i := range g.Calls {
		c := &g.Calls[i]
		c.CallerName = byID[c.Caller].Qualified
		c.Resolution = "external_or_unresolved"
		if strings.Contains(c.Target, ".") {
			c.Resolution = "member_unresolved"
			continue
		}
		caller := byID[c.Caller]
		scope := caller.Scope
		if caller.Kind == "library" || caller.Kind == "scope" || caller.Kind == "struct" {
			scope = caller.Qualified
		}
		for {
			q := c.Target
			if scope != "" {
				q = scope + "." + q
			}
			for _, s := range byName[q] {
				visiblePrivate := s.Scope != "" && (s.Scope == caller.Scope || strings.HasPrefix(caller.Scope, s.Scope+".") || (caller.Kind == "library" && s.Scope == caller.Qualified))
				if s.Private && !visiblePrivate && !(s.Scope == "" && s.File == caller.File) {
					continue
				}
				c.Candidates = append(c.Candidates, s.ID)
			}
			if len(c.Candidates) > 0 {
				break
			}
			if scope == "" {
				break
			}
			p := strings.LastIndex(scope, ".")
			if p < 0 {
				scope = ""
			} else {
				scope = scope[:p]
			}
		}
		if len(c.Candidates) == 1 {
			c.Resolution = "lexical_candidate"
		}
		if len(c.Candidates) > 1 {
			c.Resolution = "ambiguous"
		}
		sort.Strings(c.Candidates)
	}
}

// maskBlocks preserves newlines and byte columns, ignoring comment markers
// inside quoted strings, rawcodes and // comments. No source rewriting occurs.
func maskBlocks(src string) (string, bool) {
	b := []byte(src)
	block := false
	quote := byte(0)
	lineComment := false
	for i := 0; i < len(b); i++ {
		c := b[i]
		if block {
			if c == '*' && i+1 < len(b) && b[i+1] == '/' {
				b[i] = ' '
				b[i+1] = ' '
				i++
				block = false
			} else if c != '\n' && c != '\r' {
				b[i] = ' '
			}
			continue
		}
		if c == '\n' {
			lineComment = false
		}
		if lineComment {
			continue
		}
		if quote != 0 {
			if c == '\\' && quote == '"' && i+1 < len(b) {
				i++
				continue
			}
			if c == quote {
				quote = 0
			}
			continue
		}
		if c == '"' || c == '\'' {
			quote = c
			continue
		}
		if c == '/' && i+1 < len(b) {
			if b[i+1] == '/' {
				lineComment = true
				i++
				continue
			}
			if b[i+1] == '*' {
				b[i] = ' '
				b[i+1] = ' '
				i++
				block = true
			}
		}
	}
	return string(b), !block
}

// Query retains definitions and incoming/outgoing references for all matching
// symbols. Ambiguous name matches are deliberately returned together.
func (g *Graph) Query(name string) *Graph {
	q := *g
	q.Symbols = []Symbol{}
	q.Calls = []Call{}
	q.Dependencies = []Dependency{}
	ids := map[string]bool{}
	names := map[string]bool{}
	for _, s := range g.Symbols {
		if s.Name == name || s.Qualified == name {
			q.Symbols = append(q.Symbols, s)
			ids[s.ID] = true
			names[s.Name] = true
			// Member references are only textual candidates, never resolved edges.
			for q := s.Qualified; strings.Contains(q, "."); {
				names[q] = true
				q = q[strings.Index(q, ".")+1:]
			}
		}
	}
	for _, c := range g.Calls {
		match := ids[c.Caller] || c.Target == name || names[c.Target]
		for _, id := range c.Candidates {
			match = match || ids[id]
		}
		if match {
			q.Calls = append(q.Calls, c)
		}
	}
	for _, d := range g.Dependencies {
		if d.Library == name || d.Requires == name {
			q.Dependencies = append(q.Dependencies, d)
		}
	}
	return &q
}
