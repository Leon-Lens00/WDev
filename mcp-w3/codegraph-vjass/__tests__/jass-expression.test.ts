import { describe, expect, it } from 'vitest';
import { lexJass } from '../src/extraction/jass-lexer';
import { parseJassExpression, expressionName } from '../src/extraction/jass-expression';

const expression = (text: string) => parseJassExpression(lexJass(text).semanticLines.flat());

describe('vJASS expression syntax', () => {
  it('retains complete chained call/index receivers and nested argument expressions', () => {
    const result = expression('Factory.make(GetPlayerId(p)).items[next()].tick(a + other.value)');
    expect(result.errors).toEqual([]);
    expect(result.expression?.kind).toBe('call');
    const call = result.expression!;
    expect(call.kind === 'call' && call.callee.kind === 'member' && call.callee.object.kind).toBe('index');
    expect(expressionName(call)).toBe('Factory.make().items[].tick()');
    expect(result.consumed).toBe(lexJass('Factory.make(GetPlayerId(p)).items[next()].tick(a + other.value)').semanticLines.flat().length);
  });

  it('keeps strings, rawcodes and numbers as literals, never executable identifiers', () => {
    const result = expression('F("call Evil()", \'hfoo\', $FF, 0x12, .25, 1.5)');
    expect(result.errors).toEqual([]);
    expect(result.expression?.kind === 'call' && result.expression.args.map(a => a.kind)).toEqual(Array(6).fill('literal'));
    expect(lexJass('F("call Evil()")').lines.flat().some(t => t.value === 'Evil')).toBe(false);
  });

  it('implements precedence, unary operators and grouped receivers', () => {
    const result = expression('not a and b + c * d == 4');
    expect(result.errors).toEqual([]);
    expect(result.expression?.kind === 'binary' && result.expression.operator).toBe('and');
    expect(expressionName(expression('(S(value)).child.tick()').expression!)).toBe('(S()).child.tick()');
  });

  it('models function references, implicit this and colon access', () => {
    expect(expressionName(expression('function S.callback').expression!)).toBe('function S.callback');
    expect(expressionName(expression('.child[0].tick()').expression!)).toBe('this.child[].tick()');
    expect(expressionName(expression('data:SIZE').expression!)).toBe('data:SIZE');
  });

  it('reports incomplete expressions and bounds hostile nesting instead of fabricating targets', () => {
    expect(expression('Factory.make(').errors.length).toBeGreaterThan(0);
    expect(expression('('.repeat(400) + 'a' + ')'.repeat(400)).errors.length).toBeGreaterThan(0);
  });
  it('excludes nested block comments before tokenization and directive discovery', () => {
    const source = '/* outer /* inner */ call Ghost()\n//! runtextmacro Ghost()\n*/\ncall Real()';
    const lexed = lexJass(source);
    expect(lexed.errors).toEqual([]);
    expect(lexed.directives).toEqual([]);
    expect(lexed.semanticLines.flat().map(t => t.value)).toEqual(['call', 'Real', '(', ')']);
  });

  it('joins physical multiline string statements while preserving following token coordinates', () => {
    const lexed = lexJass('local string name = "first\nsecond" + I2S(1)\ncall Done()');
    expect(lexed.semanticLines[0]!.some(t => t.value === 'I2S' && t.line === 2)).toBe(true);
    expect(lexed.semanticLines[1]).toEqual([]);
    expect(lexed.semanticLines[2]!.some(t => t.value === 'Done')).toBe(true);
  });

  it('bounds long left-associated trees before recursive consumers or JSON serialization can overflow', () => {
    const result = expression(Array(2000).fill('value').join('+'));
    expect(result.errors.some(e => /budget/.test(e))).toBe(true);
    expect(result.expression?.kind).toBe('unknown');
  });

});
