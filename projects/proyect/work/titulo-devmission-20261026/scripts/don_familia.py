"""Familia de triggers DBZ de Battle Stadium D.O.N 2.1a (Valkemiere) para trasplantarla a Dev Mission.
Raíces: triggers cuya condición comprueba GetSpellAbilityId() == una de las 110 habilidades DBZ (rawcodes de la fase 1).
Cierre: triggers nombrados con gg_trg_ desde los de la familia, sin la IA de DON ni sus contadores/cancelaciones.
Se añaden las tablas de Trig_Quest_Actions (udg_Missile[], udg_AllPlayer) que las habilidades leen.
"""
import re, struct, collections

NO = re.compile(r'RectAI|RECT_|^AI|attacked|HeroDamage|spell_name|Unit_die|Cancel|^Quest$|learn_', re.I)


def cargar(j_path, rawcodes_path):
    j = open(j_path, encoding='latin-1').read()
    ids = [l.split()[0] for l in open(rawcodes_path) if l.split()[1].startswith('Az')]
    fn = {m.group(1): m.group(0) for m in re.finditer(r'^function (\w+) takes.*?^endfunction', j, re.M | re.S)}
    orden = [m.group(1) for m in re.finditer(r'^function (\w+) takes', j, re.M)]
    trigs = sorted({m.group(1) for m in re.finditer(r'^function InitTrig_(\w+) takes', j, re.M)}, key=len, reverse=True)
    own = collections.defaultdict(list)
    for k in orden:
        for t in trigs:
            if k.startswith('Trig_' + t + '_') or k == 'InitTrig_' + t:
                own[t].append(k)
                break
    nums = {str(struct.unpack('>i', a.encode())[0]): a for a in ids}
    raiz = collections.defaultdict(set)
    for t, ks in own.items():
        if NO.search(t):
            continue
        for k in ks:
            if k.endswith('_Conditions'):
                for n in re.findall(r'GetSpellAbilityId\(\)==(\d+)', fn[k]):
                    if n in nums:
                        raiz[nums[n]].add(t)
    todo = set()
    pend = [t for ts in raiz.values() for t in ts]
    while pend:
        t = pend.pop()
        if t in todo:
            continue
        todo.add(t)
        for k in own[t]:
            for x in re.findall(r'gg_trg_(\w+)', fn[k]):
                if x != t and not NO.search(x) and x in own:
                    pend.append(x)
    funcs = [k for k in orden if any(k in own[t] for t in todo)]
    quest = fn['Trig_Quest_Actions']
    tablas = [l for l in quest.splitlines() if re.match(r'set udg_(Missile|AllPlayer)\b', l)]
    return dict(j=j, fn=fn, own=own, todo=sorted(todo), funcs=funcs, raiz=raiz, tablas=tablas, ids=ids)


def rawcodes(texto):
    """Rawcodes de 4 caracteres escritos como entero decimal en el código de DON."""
    out = set()
    for n in re.findall(r'(?<![\w$.])(1[0-9]{9})(?![\w.])', texto):
        s = struct.pack('>i', int(n)).decode('latin-1')
        if s.isalnum():
            out.add(s)
    return out


def cuerpo(f):
    return ''.join(f['fn'][k] for k in f['funcs']) + '\n'.join(f['tablas'])


# Modelos de DON cuyo nombre ya usa el mapa con OTRO contenido (Ivan): se importan con prefijo DON_.
RENOMBRE = ('NewMassiveEX', 'NuclearExplosion')


def ruta_don(s):
    """Ruta de un recurso de DON dentro de Dev Mission (prefijo DON_ en los modelos que chocan)."""
    for n in RENOMBRE:
        s = re.sub(r'(war3mapImported\\+)' + n + r'(\.md[lx])', r'\1DON_' + n + r'\2', s, flags=re.I)
    return s
