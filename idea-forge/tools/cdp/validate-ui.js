#!/usr/bin/env node

/**
 * Single-Page UI Validator
 * Takes screenshot and DOM snapshot, reports console errors
 * Usage: node validate-ui.js <url> <screenshot-output-path>
 * Exit codes: 0=healthy, 1=errors found
 */

const { program } = require('commander');
const path = require('path');
const browser = require('./browser');

async function validateUI(url, screenshotPath) {
  try {
    console.log('='.repeat(60));
    console.log('🔍 UI Validation Starting');
    console.log('='.repeat(60));
    console.log(`URL: ${url}`);
    console.log(`Screenshot: ${screenshotPath}`);
    console.log();

    // Launch browser
    await browser.launchBrowser();

    // Navigate to URL
    await browser.navigateTo(url);
    console.log();

    // Take screenshot
    await browser.takeScreenshot(screenshotPath);
    console.log();

    // Get visible text (first 20 lines)
    console.log('📝 Visible Text (first 20 lines):');
    console.log('-'.repeat(60));
    const visibleText = await browser.getVisibleText();
    const textLines = visibleText.split('\n').slice(0, 20);
    textLines.forEach(line => {
      if (line.trim()) {
        console.log(`  ${line}`);
      }
    });
    console.log();

    // Get DOM snapshot and count tags
    console.log('📊 DOM Summary:');
    console.log('-'.repeat(60));
    const html = await browser.getDOMSnapshot();
    const tagCounts = {
      div: (html.match(/<div/gi) || []).length,
      p: (html.match(/<p/gi) || []).length,
      h1: (html.match(/<h1/gi) || []).length,
      h2: (html.match(/<h2/gi) || []).length,
      h3: (html.match(/<h3/gi) || []).length,
      button: (html.match(/<button/gi) || []).length,
      input: (html.match(/<input/gi) || []).length,
      form: (html.match(/<form/gi) || []).length,
      a: (html.match(/<a/gi) || []).length,
      img: (html.match(/<img/gi) || []).length,
      table: (html.match(/<table/gi) || []).length,
      li: (html.match(/<li/gi) || []).length,
    };

    Object.entries(tagCounts).forEach(([tag, count]) => {
      if (count > 0) {
        console.log(`  ${tag.padEnd(8)} : ${count}`);
      }
    });
    console.log();

    // Check for console errors
    const errors = browser.getConsoleErrors();
    console.log('⚠️  Console Errors:');
    console.log('-'.repeat(60));
    if (errors.length === 0) {
      console.log('  ✅ No console errors detected');
    } else {
      errors.forEach((err, idx) => {
        console.log(`  ${idx + 1}. ${err}`);
      });
    }
    console.log();

    // Summary
    console.log('='.repeat(60));
    if (errors.length === 0) {
      console.log('✅ UI Validation PASSED');
      console.log('='.repeat(60));
      await browser.closeBrowser();
      process.exit(0);
    } else {
      console.log('❌ UI Validation FAILED');
      console.log(`   ${errors.length} console error(s) found`);
      console.log('='.repeat(60));
      await browser.closeBrowser();
      process.exit(1);
    }
  } catch (error) {
    console.error('❌ Validation error:', error.message);
    try {
      await browser.closeBrowser();
    } catch (closeErr) {
      // Ignore close errors
    }
    process.exit(1);
  }
}

// CLI
program
  .name('validate-ui')
  .description('Validate a single page: screenshot + DOM analysis + error checking')
  .argument('<url>', 'URL to validate (e.g., http://localhost:3000)')
  .argument('<screenshot>', 'Output path for screenshot')
  .action(async (url, screenshot) => {
    await validateUI(url, screenshot);
  })
  .parse(process.argv);

// Handle missing arguments
if (process.argv.length < 4) {
  program.outputHelp();
  process.exit(1);
}
