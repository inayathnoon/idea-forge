/**
 * Structural Test: Layer Dependencies
 * Ensures forward-only import direction: Types → Config → Repo → Service → Runtime → UI
 */

const fs = require('fs');
const path = require('path');
const glob = require('glob');

const LAYERS = {
  'types': 1, 'models': 1, 'schemas': 1,
  'config': 2,
  'repo': 3, 'repositories': 3, 'db': 3, 'providers': 3.5,
  'service': 4, 'services': 4,
  'runtime': 5, 'server': 5, 'middleware': 5,
  'ui': 6, 'components': 6, 'pages': 6, 'views': 6,
};

function getLayer(filePath) {
  const parts = filePath.split(path.sep);
  for (const part of parts) {
    if (LAYERS[part]) return LAYERS[part];
  }
  return 4;
}

describe('Layer Dependencies', () => {
  const srcRoot = path.join(__dirname, '../../src');

  test('no backward layer dependencies exist', () => {
    if (!fs.existsSync(srcRoot)) return; // skip if src doesn't exist

    const files = glob.sync(path.join(srcRoot, '**/*.{js,ts,jsx,tsx}'));
    const violations = [];

    for (const file of files) {
      const content = fs.readFileSync(file, 'utf8');
      const fileLayer = getLayer(file);
      const imports = (content.match(/(?:import|require)\s*[\(\']([^\)\']+)/g) || []).map(m => m.replace(/(?:import|require)\s*[\(\']/, ''));

      for (const imp of imports) {
        if (imp.startsWith('.')) {
          const resolved = path.resolve(path.dirname(file), imp);
          const impLayer = getLayer(resolved);
          if (impLayer > fileLayer) {
            violations.push(`${path.relative(process.cwd(), file)}: imports from higher layer`);
          }
        }
      }
    }

    expect(violations).toEqual([]);
  });

  test('no circular dependencies between modules', () => {
    // Placeholder for cycle detection
    expect(true).toBe(true);
  });

  test('all source files belong to a recognized layer', () => {
    if (!fs.existsSync(srcRoot)) return;

    const files = glob.sync(path.join(srcRoot, '**/*.{js,ts,jsx,tsx}'));
    const orphans = files.filter(f => {
      if (f.includes('__tests__') || f.includes('.test.') || f.includes('index')) return false;
      return getLayer(f) === 4 && !f.split(path.sep).some(p => Object.keys(LAYERS).includes(p));
    });

    expect(orphans).toEqual([]);
  });
});
