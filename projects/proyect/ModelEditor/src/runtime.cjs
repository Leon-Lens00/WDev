const fs = require('node:fs');
const path = require('node:path');

const modules = '/home/snz/Documentos/Slendytubbies-WC3-recuperado-2026-10-09/Personajes-WC3-127b/migracion-linux/runtime/node_modules';
function dependency(name) {
  return require(path.join(modules, name));
}

module.exports = { dependency, modules, fs, path };
