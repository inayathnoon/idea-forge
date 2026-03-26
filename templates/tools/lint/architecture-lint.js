#!/usr/bin/env node

/**
 * Architecture Layer Linter
 * Ensures imports follow forward-only dependency: Types → Config → Repo → Service → Runtime → UI
 */

const fs = require('fs');
const path = require('path');
const glob = require('glob');

const LAYERS = {
  'types': 1,
  'models': 1,
  'schemas': 1,
  'config': 2,
  'repo': 3,
  'repositories': 3,
  'db': 3,
  'providers': 3.5,
  'service': 4,
  'services': 4,
  'runtime': 5,
  'server': 5,
  'middleware': 5,
  'ui': 6,
  'components': 6,
  'pages': 6,
  'views': 6,
};

function getLayer(filePath) {
  const parts = filePath.split(path.sep);
  for (const part of parts) {
    if (LAYERS[part]) return LAYERS[part];
  }
  return 4; // default to service layer
}

function getLayerName(filePath) {
  const parts = filePath.split(path.sep);
  for (const part of parts) {
    if (LAYERS[part]) return part;
  }
  return 'service';
}

function extractImports(content, filePath) {
  const imports = [];
  const jsRegex = /(?:import\s+.*from\s+['"]([^'"]+)['"]|require\s*\(['"]([^'"]+)['"]\))/g;
  const pyRegex = /(?:from\s+([^\s]+)\s+import|import\s+([^\s]+))/g;

  let match;
  const fileExt = path.extname(filePath);
  const isJs = ['.js', '.ts', '.jsx', '.tsx'].includes(fileExt);
  const isPy = ['.py'].includes(fileExt);

  const regex = isJs ? jsRegex : isPy ? pyRegex : null;
  if (!regex) return imports;

  while ((match = regex.exec(content)) !== null) {
    let importPath = match[1] || match[2];
    if (importPath && importPath.startsWith('.')) {
      imports.push(importPath);
    }
  }

  return imports;
}

function resolvePath(filePath, importPath) {
  const dir = path.dirname(filePath);
  let resolved = path.join(dir, importPath);

  // Handle missing extensions
  for (const ext of ['.js', '.ts', '.jsx', '.tsx', '.py', '/index.js', '/index.ts']) {
    if (fs.existsSync(resolved + ext)) {
      return resolved + ext;
    }
  }

  return resolved;
}

function lint(srcDir) {
  const files = glob.sync(path.join(srcDir, '**/*.{js,ts,jsx,tsx,py}'));
  let violations = 0;

  for (const filePath of files) {
    const content = fs.readFileSync(filePath, 'utf8');
    const imports = extractImports(content, filePath);
    const fileLayer = getLayer(filePath);
    const fileLayerName = getLayerName(filePath);

    for (const imp of imports) {
      const resolved = resolvePath(filePath, imp);
      const importLayer = getLayer(resolved);
      const importLayerName = getLayerName(resolved);

      if (importLayer > fileLayer) {
        console.error(`\nARCHITECTURE VIOLATION: ${fileLayerName} layer cannot import from ${importLayerName} layer.`);
        console.error(`  File:   ${path.relative(process.cwd(), filePath)} (layer: ${fileLayerName}, level ${fileLayer})`);
        console.error(`  Import: ${imp} (layer: ${importLayerName}, level ${importLayer})\n`);
        console.error('HOW TO FIX:');
        console.error('  Dependency direction must be forward only: Types → Config → Repo → Service → Runtime → UI');
        console.error(`  The ${fileLayerName} layer (level ${fileLayer}) can only import from layers with level < ${fileLayer}.\n`);
        console.error('  Options:');
        console.error(`  1. Move the imported code DOWN to the ${fileLayerName} layer or lower`);
        console.error(`  2. Create an interface/type in the Types layer and implement it in ${importLayerName}`);
        console.error('  3. If this is a cross-cutting concern, route it through Providers\n');
        console.error('  See: ARCHITECTURE.md § Architecture Layers');
        console.error('  See: docs/design-docs/core-beliefs.md § "Enforce boundaries, allow autonomy within"\n');

        violations++;
      }
    }
  }

  return violations === 0 ? 0 : 1;
}

const srcDir = process.argv[2] || 'src';
process.exit(lint(srcDir));
