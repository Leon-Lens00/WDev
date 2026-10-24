from pathlib import Path
import sys,json
ROOT=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT/'upstream'));import snes65816 as d
# Explicit instruction regions only. Jump-pointer/data tables omitted.
# M/X states derived from local REP/SEP and the preserving call 018CA4.
blocks=[(0x818ca4,0x818cb3,1,1),(0x81c5a6,0x81c5db,1,1),(0x81c610,0x81c62e,1,1),(0x82d7c2,0x82d7f3,1,1),(0x82d78e,0x82d7c2,1,1),(0x81c124,0x81c149,1,1),(0x81c1c5,0x81c1fb,1,1),(0x81c263,0x81c289,1,1),(0x81c3be,0x81c3ea,1,1),(0x81c42f,0x81c49d,1,1),(0x81c49d,0x81c4d0,1,1),(0x819040,0x819068,1,1)]
for variant,name in [('original','original.sfc'),('zero-project-v4.1','zero-project-v4.1.sfc')]:
 rom=(ROOT/'private'/name).read_bytes();lines=['Focused static decoding. Not a full game trace. Numbers after mnemonics are addressing-mode IDs from the pinned decoder.\n']
 for start,end,m,x in blocks:
  lines.append(f'\nBLOCK {start:06X}-{end:06X} entry M{m}X{x}');a=start;stack=[]
  while a<end:
   off=((a>>16)&127)*32768+(a&32767);r=d.decode_insn(rom,off,a&65535,a>>16,m,x)
   lines.append(f'{a:06X}  {rom[off:off+r.length].hex():9} {r.mnem:4} mode={r.mode:2} operand=${r.operand:06X} M{m}X{x}')
   if r.mnem=='PHP':stack.append((m,x))
   if r.mnem=='PLP' and stack:m,x=stack.pop()
   if r.mnem=='REP':
    if r.operand&32:m=0
    if r.operand&16:x=0
   if r.mnem=='SEP':
    if r.operand&32:m=1
    if r.operand&16:x=1
   a+=r.length
  assert a==end,(hex(start),hex(a),hex(end))
 (ROOT/f'focused-disassembly-{variant}.txt').write_text('\n'.join(lines)+'\n')
print('Focused blocks decoded:',len(blocks),'x 2 ROM variants')
