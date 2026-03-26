#!/usr/bin/env node

/**
 * Structural Test: Code Conventions
 * Enforces project-wide code quality standards: file size limits, no debug code, test file coverage
 */

const fs = require('fs');
const path = require('path');
const glob = require('glob');

describe('Code Conventions', () => {
  const srcRoot = path.join(__dirname, '../../src');

  test('no source file exceeds 300 lines', () => {
    if (!fs.existsSync(srcRoot)) return; // skip if src doesn't exist

    const files = glob.sync(path.join(srcRoot, '**/*.{js,ts,jsx,tsx,py}'));
    const violations = [];

    for (const filePath of files) {
      // Skip test files
      if (/(__tests__|tests|\.test\.|\.spec\.)/.test(filePath)) continue;

      const content = fs.readFileSync(filePath, 'utf8');
      const lines = content.split('\n').length;

      if (lines > 300) {
        violations.push({
          file: path.relative(process.cwd(), filePath),
          lines,
          message: `File exceeds 300-line limit (${lines} lines)`,
        });
      }
    }

    if (violations.length > 0) {
      console.error('\n❌ SIZE VIOLATIONS: Files must be under 300 lines\n');
      violations.forEach((v) => {
        console.error(`  ${v.file} (${v.lines} lines)`);
        console.error(`    → Extract logical groups into separate modules`);
        console.error(`    → See SCAFFOLDING.md § File Size Guidelines\n`);
      });
    }

    expect(violations).toEqual([]);
  });

  test('no console.log in production code', () => {
    if (!fs.existsSync(srcRoot)) return;

    const files = glob.sync(path.join(srcRoot, '**/*.{js,ts,jsx,tsx,py}'));
    const violations = [];

    for (const filePath of files) {
      // Skip test files and dev utilities
      if (/(__tests__|tests|\.test\.|\.spec\.|dev\/|debug\/)/.test(filePath)) continue;

      const content = fs.readFileSync(filePath, 'utf8');
      const lines = content.split('\n');

      lines.forEach((line, i) => {
        // Match console.log, console.warn, console.error, print()
        if (/console\.(log|warn|error)|^[^#]*print\(/.test(line)) {
          violations.push({
            file: path.relative(process.cwd(), filePath),
            line: i + 1,
            code: line.trim(),
            message: 'Debug statement left in production code',
          });
        }
      });
    }

    if (violations.length > 0) {
      console.error('\n❌ DEBUG CODE VIOLATIONS: Remove console.log/print from production\n');
      violations.forEach((v) => {
        console.error(`  ${v.file}:${v.line}`);
        console.error(`    ${v.code}`);
        console.error(`    → Use structured logging (logger.info, logger.debug) instead`);
        console.error(`    → See SCAFFOLDING.md § Logging Patterns\n`);
      });
    }

    expect(violations).toEqual([]);
  });

  test('every service file has a corresponding test file', () => {
    if (!fs.existsSync(srcRoot)) return;

    const serviceRoot = path.join(srcRoot, 'services', 'service');
    if (!fs.existsSync(serviceRoot)) return; // skip if no services directory

    const serviceFiles = glob.sync(path.join(serviceRoot, '*.{js,ts}'))
      .filter(f => !/(\.test\.|\.spec\.)/.test(f));

    const violations = [];

    for (const serviceFile of serviceFiles) {
      const testFile = serviceFile.replace(/\.([jt]s)$/, '.test.$1');

      if (!fs.existsSync(testFile)) {
        violations.push({
          service: path.relative(process.cwd(), serviceFile),
          expectedTest: path.relative(process.cwd(), testFile),
          message: 'No corresponding test file found',
        });
      }
    }

    if (violations.length > 0) {
      console.error('\n❌ MISSING TEST FILES: Every service needs a corresponding .test.js\n');
      violations.forEach((v) => {
        console.error(`  ${v.service}`);
        console.error(`    Missing: ${v.expectedTest}`);
        console.error(`    → Create test file and define unit tests for all public functions`);
        console.error(`    → See SCAFFOLDING.md § Testing Requirements\n`);
      });
    }

    expect(violations).toEqual([]);
  });
});
