from pathlib import Path
import ctypes,json,subprocess,sys,warnings,re
import tree_sitter
root=Path(__file__).resolve().parent.parent
if not sys.argv[1:]:raise SystemExit('Usage: jass-pattern-review COMPILED.j [COMPILED.j ...]')
lib=ctypes.CDLL(str(root/'lib/tree-sitter-jass.so'));symbol=lib.tree_sitter_jass;symbol.restype=ctypes.c_void_p
with warnings.catch_warnings():
    warnings.simplefilter('ignore');language=tree_sitter.Language(symbol())
parser=tree_sitter.Parser(language)
coverage=[]
for value in sys.argv[1:]:
    path=Path(value).resolve(strict=True);payload=path.read_bytes();tree=parser.parse(payload)
    source=payload.decode('utf-8',errors='replace')
    extension_lines=re.findall(r'(?m)^[ \t]*(?:(?:private|public|static)\s+)*(?:library|library_once|struct|module|method|scope|interface|endlibrary|endstruct|endmodule|endmethod|endscope|endinterface)\b',source)
    coverage.append({'file':str(path),'parser_errors':tree.root_node.has_error,'possible_vjass_blocks':len(extension_lines)})
if any(x['parser_errors'] or x['possible_vjass_blocks'] for x in coverage):
    print(json.dumps({'status':'unsupported_or_unparsed','coverage':coverage,'findings':[],
        'action':'Compile vJASS with the exact JassHelper first; do not treat this as an empty review.'},indent=2))
    raise SystemExit(2)
p=subprocess.run([str(root/'bin/ast-grep'),'scan','--config',str(root/'sgconfig.yml'),'--custom-languages','allow','--json',*sys.argv[1:]],capture_output=True,text=True)
if p.returncode not in [0,1]:
    print(p.stderr,file=sys.stderr);raise SystemExit(p.returncode)
print(json.dumps({'status':'advisory','coverage':coverage,'findings':json.loads(p.stdout),
    'limitations':['Permissive JASS grammar, not a compiler','No proof of absence of bugs or desync','Run JassHelper/pJASS and applicable game tests']},indent=2))
raise SystemExit(p.returncode)
