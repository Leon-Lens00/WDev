"""Compara los registros de A y B de una prueba LAN v12q. Uso: leer-lan-v12q.py DIR"""
import collections, glob, re, sys
L = collections.defaultdict(dict)
for f in glob.glob(sys.argv[1] + '/lat/j*'):
    m = re.search(r'j(\d)-(\d+)', f)
    x = re.search(r'Preload\( "(.*?)" \)', open(f, errors='replace').read())
    if x:
        L[int(m[1])][int(m[2])] = x[1]
A, B = ([L[j][k] for k in sorted(L[j])] for j in (1, 2))
print('lineas', len(A), len(B), 'no chequeo iguales', sum(x == y for x, y in zip(A, B) if not x.startswith('chequeo')))
for a in A:
    if not a.startswith('chequeo'):
        print(a[:230])
ch = lambda X: [x.split(' | ') for x in X if x.startswith('chequeo')]
ca, cb = ch(A), ch(B)
print('chequeos', len(ca), len(cb), 'iguales', sum(x[0] == y[0] for x, y in zip(ca, cb)))
for x, y in list(zip(ca, cb))[::3]:
    print(x[0][:78], '|', x[1], '|', y[1])
