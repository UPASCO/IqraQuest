// Drives the real IqraQuest web build through a scripted sequence of taps,
// capturing iPhone 6.5" frames (1242x2688 = 414x896 CSS px at DPR 3).
// Usage: node drive.js '<json steps>'
//   steps: [{tap:[x,y]}, {click:"label"}, {labels:true}, {wait:1500},
//           {shot:"name"}, {goto:"/progress"}, {seed:{key:val}}, {reload:true}]
const { chromium } = require(process.env.PW || 'playwright');
const fs = require('fs');

const OUT = process.env.OUT || 'build/store/raw';
const BASE = process.env.BASE || 'http://localhost:8099';

(async () => {
  fs.mkdirSync(OUT, { recursive: true });
  const steps = JSON.parse(process.argv[2]);
  const browser = await chromium.launch({
    executablePath: process.env.CHROME || undefined,
    args: ['--no-sandbox', '--use-gl=swiftshader', '--enable-unsafe-swiftshader'],
  });
  const ctx = await browser.newContext({
    viewport: { width: Number(process.env.VW||414), height: Number(process.env.VH||896) },
    deviceScaleFactor: Number(process.env.DPR||3),
    isMobile: true,
    hasTouch: true,
    locale: 'fr-FR',
  });
  const page = await ctx.newPage();
  page.setDefaultTimeout(8000);
  page.on('pageerror', (e) => console.log('[pageerror]', String(e).slice(0, 200)));

  await page.goto(`${BASE}/#/home`, { waitUntil: 'load', timeout: 90000 });
  await page.waitForTimeout(14000); // Flutter boot + first paint
  await enableSemantics(page);

  // Flutter web only builds its accessibility DOM once something asks for
  // it; the placeholder button is that ask. With it on, steps can target
  // widgets by their label instead of by coordinates.
  async function enableSemantics(p) {
    try {
      const ph = p.locator('flt-semantics-placeholder');
      if (await ph.count()) {
        await ph.first().evaluate((el) => el.click());
        await p.waitForTimeout(1500);
      }
    } catch (e) { console.log('[semantics]', String(e).slice(0, 120)); }
  }
  async function find(label) {
    // A trailing "*" matches by prefix: {click:"A. *"} taps answer A
    // whatever the question turned out to be.
    if (label.endsWith('*')) {
      const pre = label.slice(0, -1);
      const re = new RegExp('^' + pre.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'));
      const byLabel = page.locator(`[aria-label^="${pre.replace(/"/g, '\\"')}"]`);
      if (await byLabel.count()) return byLabel.first();
      return page.locator('flt-semantics', { hasText: re }).last();
    }
    const esc = label.replace(/"/g, '\\"');
    const byLabel = page.locator(`flt-semantics[aria-label="${esc}"], [aria-label="${esc}"]`);
    if (await byLabel.count()) return byLabel.first();
    const byText = page.locator('flt-semantics', { hasText: label });
    if (await byText.count()) return byText.last();
    return page.getByText(label, { exact: false }).first();
  }

  for (const s of steps) {
    if (s.goto) {
      await page.evaluate((r) => { window.location.hash = r; }, s.goto);
      await page.waitForTimeout(s.after || 2500);
    }
    if (s.click) {
      // Tap a widget by its semantics label (or a prefix/substring of it).
      let el = await find(s.click);
      let box = await el.boundingBox();
      const vh = page.viewportSize().height;
      if (box && (box.y + box.height > vh || box.y < 0)) {
        // Off-screen: scroll the page towards it and look again.
        await page.mouse.move(207, vh / 2);
        await page.mouse.wheel(0, box.y + box.height / 2 - vh / 2);
        await page.waitForTimeout(900);
        el = await find(s.click);
        box = await el.boundingBox();
      }
      if (!box) { console.log('[missing]', s.click); }
      else {
        await page.mouse.click(box.x + box.width / 2, box.y + box.height / 2);
      }
      await page.waitForTimeout(s.after || 1600);
    }
    if (s.labels) {
      const all = await page.locator('flt-semantics').evaluateAll((els) =>
        els.map((e) => (e.getAttribute('aria-label') || e.textContent || '').trim()).filter(Boolean));
      console.log('[labels]', JSON.stringify([...new Set(all)]).slice(0, 4000));
    }
    if (s.tap) {
      await page.mouse.click(s.tap[0], s.tap[1]);
      await page.waitForTimeout(s.after || 1600);
    }
    if (s.drag) {
      // A finger drag in CSS px: down at [x1,y1], glide to [x2,y2], up.
      const [x1, y1, x2, y2] = s.drag;
      await page.mouse.move(x1, y1);
      await page.mouse.down();
      const n = s.steps || 12;
      for (let i = 1; i <= n; i++) {
        await page.mouse.move(x1 + (x2 - x1) * i / n, y1 + (y2 - y1) * i / n);
        await page.waitForTimeout(30);
      }
      if (s.hold) await page.waitForTimeout(s.hold);
      if (s.shotMid) { await page.screenshot({ path: `${OUT}/${s.shotMid}.png` }); console.log('captured', s.shotMid); }
      await page.mouse.up();
      await page.waitForTimeout(s.after || 1600);
    }
    if (s.scroll) {
      await page.mouse.move(207, 500);
      await page.mouse.wheel(0, s.scroll);
      await page.waitForTimeout(s.after || 1200);
    }
    if (s.seed) {
      await page.evaluate((kv) => {
        for (const [k, v] of Object.entries(kv)) window.localStorage.setItem(k, v);
      }, s.seed);
    }
    if (s.reload) {
      await page.reload({ waitUntil: 'load' });
      await page.waitForTimeout(s.after || 14000);
      await enableSemantics(page);
    }
    if (s.viewport) {
      await page.setViewportSize({ width: s.viewport[0], height: s.viewport[1] });
      await page.waitForTimeout(s.after || 1500);
    }
    if (s.wait) await page.waitForTimeout(s.wait);
    if (s.shot) {
      await page.screenshot({ path: `${OUT}/${s.shot}.png` });
      console.log('captured', s.shot);
    }
  }
  await browser.close();
})();
