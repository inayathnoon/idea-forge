#!/usr/bin/env node

/**
 * Naming & Size Linter
 * Checks file naming conventions and enforces 300-line limit
 */

const fs = require('fs');
const path = require('path');
const glob = require('glob');

const RULES = [
  { pattern: /components|pages|views/, regex: /^[A-Z][a-zA-Z0-9]+\.(jsx|tsx)$/, name: 'Components', layer: 'UI' },
  { pattern: /services|service/, regex: /^[a-z][a-zA-Z0-9]+\.(js|ts)$/, name: 'Services', layer: 'Service' },
  { pattern: /types|models/, regex: /^[a-z][a-zA-Z0-9]+\.(ts|py)$/, name: 'Types', layer: 'Types' },
];

function getSize(filePath) {
  const content = fs.readFileSync(filePath, 'utf8');
  return content.split('\n').length;
}

function checkNaming(filePath) {
  const fileName = path.basename(filePath);
  const dir = path.dirname(filePath);

  // Check test files
  if (/(__tests__|tests|\.test\.|\.spec\.)/.test(filePath)) {
    return { valid: true };
  }

  // Check against rules
  for (const rule of RULES) {
    if (rule.pattern.test(dir)) {
      if (!rule.regex.test(fileName)) {
        return {
          valid: false,
          rule: rule.name,
          pattern: rule.regex.toString(),
          message: `${rule.layer} files must match: ${rule.regex}`,
        };
      }
      return { valid: true };
    }
  }

  return { valid: true }; // default OK
}

function lint(srcDir) {
  const files = glob.sync(path.join(srcDir, '**/*.{js,ts,jsx,tsx,py}'));
  let violations = 0;

  for (const filePath of files) {
    // Check naming
    const naming = checkNaming(filePath);
    if (!naming.valid) {
      console.error(`\nNAMING VIOLATION: ${naming.message}`);
      console.error(`  File:     ${path.relative(process.cwd(), filePath)}`);
      console.error(`  Expected: ${naming.pattern}\n`);
      console.error('HOW TO FIX:');
      console.error('  Rename the file to match the naming convention.');
      console.error('  See: SCAFFOLDING.md § File Naming Conventions\n');
      violations++;
    }

    // Check size
    const lines = getSize(filePath);
    if (lines > 300) {
      console.error(`\nSIZE VIOLATION: Files must be under 300 lines.`);
      console.error(`  File:  ${path.relative(process.cwd(), filePath)}`);
      console.error(`  Lines: ${lines} (max: 300)\n`);
      console.error('HOW TO FIX:');
      console.error('  1. Identify logical groups of functions');
      console.error('  2. Extract each group into its own module');
      console.error('  3. Each module should have a single responsibility');
      console.error('  See: SCAFFOLDING.md § Patterns & Conventions\n');
      violations++;
    }
  }

  return violations === 0 ? 0 : 1;
}

const srcDir = process.argv[2] || 'src';
process.exit(lint(srcDir));
