import { afterEach, expect, it } from 'vitest';
import * as fs from 'node:fs';
import * as os from 'node:os';
import * as path from 'node:path';
import { DatabaseConnection } from '../src/db';
import { QueryBuilder } from '../src/db/queries';
import type { Node } from '../src/types';

let root: string | undefined;
let connection: DatabaseConnection | undefined;
afterEach(() => { connection?.close(); if (root) fs.rmSync(root, { recursive: true, force: true }); });

it('persists semantic facts through single/batch insertion, updates and reopen', () => {
  root = fs.mkdtempSync(path.join(os.tmpdir(), 'cg-semantic-data-'));
  const file = path.join(root, 'graph.db');
  connection = DatabaseConnection.initialize(file);
  let query = new QueryBuilder(connection.getDb());
  const node: Node = { id: 'f', kind: 'variable', name: 'f', qualifiedName: 'Run.f', filePath: 'test.j', language: 'jass', startLine: 2, endLine: 2, startColumn: 0, endColumn: 4, updatedAt: 1, semanticData: { declaredType: 'Callback', values: [{ kind: 'name', name: 'Foo' }] } };
  query.insertNode(node);
  expect(query.getNodeById('f')?.semanticData).toEqual(node.semanticData);
  query.insertNodes([{ ...node, id: 'g', semanticData: { declaredType: 'Other' } }]);
  query.updateNode({ ...node, semanticData: { declaredType: 'Changed' } });
  connection.close();
  connection = DatabaseConnection.open(file);
  query = new QueryBuilder(connection.getDb());
  expect(query.getNodeById('f')?.semanticData).toEqual({ declaredType: 'Changed' });
  expect(query.getNodeById('g')?.semanticData).toEqual({ declaredType: 'Other' });
});
