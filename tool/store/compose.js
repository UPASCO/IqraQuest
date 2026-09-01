// Composes App Store 6.5" marketing frames (1242x2688) from raw app captures
// taken by drive.js. Usage: node tool/store/compose.js
const { chromium } = require(process.env.PW || 'playwright');
const fs = require('fs');
const path = require('path');

const RAW = process.env.RAW || 'build/store/raw';
const OUT = process.env.OUT || 'build/store/appstore_65';

// Caption, accent word (gold), sub-line, source capture, and how far the
// device art is pushed down.
const FRAMES = [
  { src: 'home',      line: 'Le voyage commence par', accent: 'ce que tu sais', sub: 'Les petits chevaux, version savoir — de 7 à 99 ans.' },
  { src: 'deck',      line: 'Pas de dé.', accent: 'Tu pioches une carte.', sub: 'Quatre écuries, 52 cases, une pioche équitable.' },
  { src: 'card',      line: 'La carte dit', accent: 'combien de cases… et quelle question', sub: 'Un 6 emmène loin — il faudra le mériter.' },
  { src: 'question',  line: 'Chaque question', accent: 'cite sa source', sub: 'Coran, Sahîh al-Bukhârî, Sahîh Muslim.' },
  { src: 'results',   line: 'Gagne,', accent: 'partage, rejoue.', sub: 'Le tableau de course se partage en une image.' },
  { src: 'mode',      line: 'Trois parcours,', accent: 'visibles avant de partir', sub: 'Du plus paisible au plus mouvementé.' },
  { src: 'daily',     line: 'Le Défi du jour,', accent: 'cinq questions', sub: 'Gratuit, chaque jour, entièrement hors connexion.' },
  { src: 'premium',   line: 'Sans pub. Sans compte.', accent: 'Sans abonnement.', sub: 'Tout reste sur votre appareil. Un seul achat, optionnel.' },
];

const page = (f, dataUri) => `
<meta charset="utf-8">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:opsz,wght@12..96,600;12..96,800&display=swap">
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  html, body { width: 1242px; height: 2688px; overflow: hidden; }
  body {
    background:
      radial-gradient(90% 46% at 50% 0%, #12513C 0%, rgba(0,0,0,0) 60%),
      linear-gradient(176deg, #06251C 0%, #0A3327 46%, #0F4634 100%);
    font-family: "Bricolage Grotesque", system-ui, sans-serif;
    position: relative;
  }
  .motif {
    position: absolute; inset: 0; opacity: 0.075;
    background-image: url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='150' height='150' viewBox='0 0 96 96'><g fill='none' stroke='%23E4BC6B' stroke-width='1.2'><path d='M48 6 L60 24 L82 24 L70 42 L82 60 L60 60 L48 78 L36 60 L14 60 L26 42 L14 24 L36 24 Z'/><circle cx='48' cy='42' r='9'/></g></svg>");
    background-size: 150px 150px;
  }
  .glow {
    position: absolute; left: 50%; top: 470px; transform: translateX(-50%);
    width: 1500px; height: 900px; border-radius: 50%;
    background: radial-gradient(closest-side, rgba(232,187,105,0.22), rgba(232,187,105,0));
  }
  .cap {
    position: relative;
    padding: 116px 88px 0;
    text-align: center;
  }
  h1 {
    font-size: 92px;
    line-height: 1.06;
    font-weight: 800;
    letter-spacing: -0.022em;
    color: #F6EFE0;
    text-wrap: balance;
  }
  h1 .a { color: #EBC474; display: block; }
  p {
    margin-top: 30px;
    font-size: 40px;
    line-height: 1.34;
    font-weight: 600;
    color: rgba(233,222,199,0.80);
    text-wrap: balance;
  }
  .device {
    position: absolute;
    left: 50%;
    transform: translateX(-50%);
    top: ${f.top || 468}px;
    width: 940px;
    border-radius: 62px;
    padding: 13px;
    background: linear-gradient(160deg, #DCC79A 0%, #7E6A45 42%, #C9AE79 100%);
    box-shadow: 0 46px 100px rgba(0,0,0,0.55), 0 6px 16px rgba(0,0,0,0.35);
  }
  .device img {
    display: block;
    width: 100%;
    border-radius: 50px;
  }
</style>
<div class="motif"></div>
<div class="glow"></div>
<div class="cap">
  <h1>${f.line}<span class="a">${f.accent}</span></h1>
  <p>${f.sub}</p>
</div>
<div class="device"><img src="${dataUri}"></div>
`;

(async () => {
  fs.mkdirSync(OUT, { recursive: true });
  const browser = await chromium.launch({
    executablePath: process.env.CHROME || undefined,
    args: ['--no-sandbox'],
  });
  const ctx = await browser.newContext({
    viewport: { width: 1242, height: 2688 },
    deviceScaleFactor: 1,
  });
  const p = await ctx.newPage();

  let i = 0;
  for (const f of FRAMES) {
    i++;
    const file = path.join(RAW, `${f.src}.png`);
    if (!fs.existsSync(file)) { console.log('MISSING', f.src); continue; }
    const uri = 'data:image/png;base64,' + fs.readFileSync(file).toString('base64');
    await p.setContent(page(f, uri), { waitUntil: 'load' });
    await p.evaluate(() => document.fonts.ready);
    await p.waitForTimeout(700);
    const name = `${String(i).padStart(2, '0')}_${f.src}.png`;
    await p.screenshot({ path: path.join(OUT, name) });
    console.log('composed', name);
  }
  await browser.close();
})();
