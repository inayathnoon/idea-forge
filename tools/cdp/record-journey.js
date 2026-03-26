#!/usr/bin/env node

/**
 * Multi-Step Journey Recorder
 * Executes a sequence of browser actions (navigate, click, type, assert, etc.)
 * Usage: node record-journey.js <journey-config.json>
 * Exit codes: 0=success, 1=failure
 */

const { program } = require('commander');
const fs = require('fs');
const path = require('path');
const browser = require('./browser');

async function recordJourney(configPath) {
  let config;

  try {
    // Load config
    if (!fs.existsSync(configPath)) {
      throw new Error(`Config file not found: ${configPath}`);
    }

    const configContent = fs.readFileSync(configPath, 'utf8');
    config = JSON.parse(configContent);

    console.log('='.repeat(60));
    console.log(`🎬 Journey: ${config.name}`);
    console.log('='.repeat(60));
    console.log(`Base URL: ${config.baseUrl}`);
    console.log(`Output: ${config.outputDir}`);
    console.log(`Steps: ${config.steps.length}`);
    console.log();

    // Create output directory
    if (!fs.existsSync(config.outputDir)) {
      fs.mkdirSync(config.outputDir, { recursive: true });
    }

    // Launch browser
    await browser.launchBrowser();

    // Execute steps
    for (let i = 0; i < config.steps.length; i++) {
      const step = config.steps[i];
      const stepNum = i + 1;

      try {
        console.log(`[Step ${stepNum}/${config.steps.length}] ${step.action}`);

        switch (step.action) {
          case 'navigate':
            const url = step.url.startsWith('http') ? step.url : config.baseUrl + step.url;
            await browser.navigateTo(url);
            break;

          case 'screenshot':
            const screenshotPath = path.join(config.outputDir, `${step.name || `step-${stepNum}`}.png`);
            await browser.takeScreenshot(screenshotPath);
            break;

          case 'click':
            await browser.clickElement(step.selector);
            break;

          case 'type':
            await browser.typeInto(step.selector, step.text);
            break;

          case 'wait':
            await new Promise(resolve => setTimeout(resolve, step.ms || 1000));
            console.log(`  waited ${step.ms}ms`);
            break;

          case 'assert-text':
            const visibleText = await browser.getVisibleText();
            if (!visibleText.includes(step.text)) {
              throw new Error(`Expected text not found: "${step.text}"`);
            }
            console.log(`  ✓ Text found: "${step.text}"`);
            break;

          case 'assert-element':
            const exists = await browser.elementExists(step.selector);
            if (!exists) {
              throw new Error(`Element not found: "${step.selector}"`);
            }
            console.log(`  ✓ Element exists: "${step.selector}"`);
            break;

          case 'assert-no-errors':
            const errors = browser.getConsoleErrors();
            if (errors.length > 0) {
              throw new Error(`Found ${errors.length} console error(s)`);
            }
            console.log(`  ✓ No console errors`);
            break;

          default:
            throw new Error(`Unknown action: ${step.action}`);
        }

        console.log();
      } catch (stepError) {
        // Capture failure screenshot
        const failureScreenshot = path.join(
          config.outputDir,
          `FAILURE-step-${stepNum}.png`
        );
        try {
          await browser.takeScreenshot(failureScreenshot);
          console.error(`  ❌ Failed: ${stepError.message}`);
          console.error(`  Screenshot: ${failureScreenshot}`);
        } catch (screenshotErr) {
          console.error(`  ❌ Failed: ${stepError.message}`);
          console.error(`  (Could not capture failure screenshot)`);
        }

        console.log();
        console.log('='.repeat(60));
        console.log('❌ Journey FAILED');
        console.log('='.repeat(60));
        await browser.closeBrowser();
        process.exit(1);
      }
    }

    // Success
    console.log('='.repeat(60));
    console.log('✅ Journey PASSED');
    console.log('='.repeat(60));
    await browser.closeBrowser();
    process.exit(0);
  } catch (error) {
    console.error('❌ Journey error:', error.message);
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
  .name('record-journey')
  .description('Execute a multi-step browser journey from config JSON')
  .argument('<config>', 'Path to journey config JSON file')
  .action(async (config) => {
    await recordJourney(config);
  })
  .parse(process.argv);

// Handle missing arguments
if (process.argv.length < 3) {
  program.outputHelp();
  process.exit(1);
}
