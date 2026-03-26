/**
 * Structural Test: Code Conventions
 * Enforces project-wide standards: file size limits, no debug code, test coverage
 */

const fs = require('fs');
const path = require('path');
const glob = require('glob');

describe('Code Conventions', () => {
  const srcRoot = path.join(__dirname, '../../src');

  test('no source file exceeds 300 lines', () => {
    if (!fs.existsSync(srcRoot)) return;

    const files = glob.sync(path.join(srcRoot, '**/*.{js,ts,jsx,tsx,py}'));
    const violations = [];

    for (const filePath of files) {
      if (/(__tests__|tests|\.test\.|\.spec\.)/.test(filePath)) continue;

      const content = fs.readFileSync(filePath, 'utf8');
      const lines = content.split('\n').length;

      if (lines > 300) {
        violations.push({
          file: path.relative(process.cwd(), filePath),
          lines,
        });
      }
    }

    if (violations.length > 0) {
      console.error('\nSIZE VIOLATIONS: Files must be under 300 lines\n');
      violations.forEach((v) => {
        console.error(`  ${v.file} (${v.lines} lines)`);
        console.error(`    -> Extract logical groups into separate modules`);
        console.error(`    -> See SCAFFOLDING.md\n`);
      });
    }

    expect(violations).toEqual([]);
  });

  test('no console.log/warn in production code (console.error is allowed)', () => {
    if (!fs.existsSync(srcRoot)) return;

    const files = glob.sync(path.join(srcRoot, '**/*.{js,ts,jsx,tsx}'));
    const violations = [];

    for (const filePath of files) {
      if (/(__tests__|tests|\.test\.|\.spec\.|dev\/|debug\/)/.test(filePath)) continue;

      const content = fs.readFileSync(filePath, 'utf8');
      const lines = content.split('\n');

      lines.forEach((line, i) => {
        // Ban console.log and console.warn — use structured logging
        // Allow console.error — legitimate for error boundaries
        if (/console\.(log|warn)\s*\(/.test(line)) {
          violations.push({
            file: path.relative(process.cwd(), filePath),
            line: i + 1,
            code: line.trim(),
          });
        }
      });
    }

    if (violations.length > 0) {
      console.error('\nDEBUG CODE VIOLATIONS: Remove console.log/warn from production\n');
      violations.forEach((v) => {
        console.error(`  ${v.file}:${v.line}`);
        console.error(`    ${v.code}`);
        console.error(`    -> Use structured logging instead (console.error is allowed)\n`);
      });
    }

    expect(violations).toEqual([]);
  });

  test('every service file has a corresponding test file', () => {
    if (!fs.existsSync(srcRoot)) return;

    const serviceRoot = path.join(srcRoot, 'services');
    if (!fs.existsSync(serviceRoot)) return;

    const serviceFiles = glob.sync(path.join(serviceRoot, '*.{js,ts}'))
      .filter(f => !/(\.test\.|\.spec\.)/.test(f));

    const violations = [];

    for (const serviceFile of serviceFiles) {
      const testFile = serviceFile.replace(/\.([jt]s)$/, '.test.$1');

      if (!fs.existsSync(testFile)) {
        violations.push({
          service: path.relative(process.cwd(), serviceFile),
          expectedTest: path.relative(process.cwd(), testFile),
        });
      }
    }

    if (violations.length > 0) {
      console.error('\nMISSING TEST FILES: Every service needs a corresponding .test file\n');
      violations.forEach((v) => {
        console.error(`  ${v.service}`);
        console.error(`    Missing: ${v.expectedTest}\n`);
      });
    }

    expect(violations).toEqual([]);
  });
});
