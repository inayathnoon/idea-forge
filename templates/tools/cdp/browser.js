/**
 * Chrome DevTools Protocol (CDP) Browser Client
 * Puppeteer wrapper for headless browser automation
 */

const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

let browser = null;
let page = null;
const consoleErrors = [];

/**
 * Launch headless Chrome with error capture
 */
async function launchBrowser() {
  try {
    browser = await puppeteer.launch({
      headless: true,
      args: ['--no-sandbox', '--disable-setuid-sandbox'],
    });

    page = await browser.newPage();
    await page.setViewport({ width: 1280, height: 720 });

    // Capture console messages
    page.on('console', (msg) => {
      if (msg.type() === 'error') {
        const text = msg.text();
        console.log(`[BROWSER CONSOLE ERROR] ${text}`);
        consoleErrors.push(text);
      }
    });

    // Capture page errors
    page.on('error', (err) => {
      console.log(`[BROWSER PAGE ERROR] ${err.message}`);
      consoleErrors.push(err.message);
    });

    // Capture uncaught exceptions in page
    page.on('pageerror', (err) => {
      console.log(`[BROWSER PAGE ERROR] ${err.message}`);
      consoleErrors.push(err.message);
    });

    console.log('[CDP] Browser launched');
  } catch (error) {
    console.error('[CDP] Failed to launch browser:', error.message);
    throw error;
  }
}

/**
 * Navigate to URL and wait for network idle
 */
async function navigateTo(url) {
  if (!browser || !page) {
    throw new Error('[CDP] Browser not launched. Call launchBrowser() first.');
  }

  try {
    await page.goto(url, {
      waitUntil: 'networkidle0',
      timeout: 30000,
    });
    console.log(`[CDP] Navigated to ${url}`);
  } catch (error) {
    console.error('[CDP] Navigation failed:', error.message);
    throw error;
  }
}

/**
 * Take full-page screenshot
 */
async function takeScreenshot(outputPath) {
  if (!browser || !page) {
    throw new Error('[CDP] Browser not launched. Call launchBrowser() first.');
  }

  try {
    const dir = path.dirname(outputPath);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }

    await page.screenshot({
      path: outputPath,
      fullPage: true,
    });
    console.log(`[CDP] Screenshot saved to ${outputPath}`);
  } catch (error) {
    console.error('[CDP] Screenshot failed:', error.message);
    throw error;
  }
}

/**
 * Get full DOM snapshot
 */
async function getDOMSnapshot() {
  if (!browser || !page) {
    throw new Error('[CDP] Browser not launched. Call launchBrowser() first.');
  }

  try {
    const html = await page.content();
    return html;
  } catch (error) {
    console.error('[CDP] DOM snapshot failed:', error.message);
    throw error;
  }
}

/**
 * Get visible text content
 */
async function getVisibleText() {
  if (!browser || !page) {
    throw new Error('[CDP] Browser not launched. Call launchBrowser() first.');
  }

  try {
    const text = await page.evaluate(() => document.body.innerText);
    return text;
  } catch (error) {
    console.error('[CDP] Get visible text failed:', error.message);
    throw error;
  }
}

/**
 * Click an element by selector
 */
async function clickElement(selector) {
  if (!browser || !page) {
    throw new Error('[CDP] Browser not launched. Call launchBrowser() first.');
  }

  try {
    await page.waitForSelector(selector, { timeout: 10000 });
    await page.click(selector);
    console.log(`[CDP] Clicked element: ${selector}`);
  } catch (error) {
    console.error(`[CDP] Click failed for ${selector}:`, error.message);
    throw error;
  }
}

/**
 * Type text into an input element
 */
async function typeInto(selector, text) {
  if (!browser || !page) {
    throw new Error('[CDP] Browser not launched. Call launchBrowser() first.');
  }

  try {
    await page.waitForSelector(selector, { timeout: 10000 });
    await page.click(selector);
    await page.type(selector, text, { delay: 50 });
    console.log(`[CDP] Typed into ${selector}: ${text.substring(0, 50)}...`);
  } catch (error) {
    console.error(`[CDP] Type failed for ${selector}:`, error.message);
    throw error;
  }
}

/**
 * Check if an element exists
 */
async function elementExists(selector) {
  if (!browser || !page) {
    throw new Error('[CDP] Browser not launched. Call launchBrowser() first.');
  }

  try {
    const element = await page.$(selector);
    return element !== null;
  } catch (error) {
    console.error(`[CDP] Element check failed for ${selector}:`, error.message);
    return false;
  }
}

/**
 * Get captured console errors
 */
function getConsoleErrors() {
  return consoleErrors;
}

/**
 * Close browser and reset state
 */
async function closeBrowser() {
  try {
    if (page) {
      await page.close();
      page = null;
    }
    if (browser) {
      await browser.close();
      browser = null;
    }
    consoleErrors.length = 0;
    console.log('[CDP] Browser closed');
  } catch (error) {
    console.error('[CDP] Close failed:', error.message);
    throw error;
  }
}

module.exports = {
  launchBrowser,
  navigateTo,
  takeScreenshot,
  getDOMSnapshot,
  getVisibleText,
  clickElement,
  typeInto,
  elementExists,
  getConsoleErrors,
  closeBrowser,
};
