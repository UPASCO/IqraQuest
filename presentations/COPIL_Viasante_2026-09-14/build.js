// COPIL Selligent × Mutuelle Viasanté — 14/09/2026 — deck generator (pptxgenjs)
const pptxgen = require('pptxgenjs');
const React = require('react');
const RDS = require('react-dom/server');
const fi = require('react-icons/fi');
const sharp = require('sharp');
const path = require('path');

const OUT = process.argv[2] || path.join(__dirname, 'COPIL_Selligent_Mutuelle_Viasante_14092026_v5.pptx');

// ---------- palette ----------
const C = {
  teal: '06404F', teal2: '0F6B7A', teal3: '3D8E9C', tealL: 'E4F0F2', tealXL: 'F2F8F9',
  orange: 'F28C28', orangeL: 'FDEBD9',
  ink: '1F2A30', muted: '6B7B83', line: 'D6E0E3', white: 'FFFFFF', bg: 'FFFFFF',
  green: '2E8B57', greenL: 'E3F3EA', amber: 'D99A00', amberL: 'FFF3D6', red: 'C0392B', redL: 'FBE5E2',
  grey: 'B8C4C9',
};
const FONT = 'Calibri';
const W = 13.333, H = 7.5, M = 0.55;
const NB = ' ';           // espace insécable (avant % et unités)
const DATE_LONG = '14 septembre 2026';

// ---------- icons ----------
async function icon(name, hex, size = 256) {
  const Comp = fi[name];
  if (!Comp) throw new Error('icon missing ' + name);
  let svg = RDS.renderToStaticMarkup(React.createElement(Comp, { size, color: '#' + hex, strokeWidth: 2 }));
  svg = svg.replace(/currentColor/g, '#' + hex);
  const buf = await sharp(Buffer.from(svg)).png().toBuffer();
  return 'image/png;base64,' + buf.toString('base64');
}
const ICONS = {};
async function preloadIcons(list) {
  for (const [name, hex] of list) ICONS[name + hex] = await icon(name, hex);
}
function ic(name, hex) { const k = name + hex; if (!ICONS[k]) throw new Error('icon not preloaded ' + k); return ICONS[k]; }

// ---------- helpers ----------
function txt(slide, text, o) {
  slide.addText(text, Object.assign({ fontFace: FONT, color: C.ink, isTextBox: true, margin: 0, valign: 'top' }, o));
}
function rect(slide, x, y, w, h, o = {}) {
  const opts = { x, y, w, h, fill: { color: o.fill || C.white }, line: o.line ? { color: o.line, width: o.lineW || 0.75 } : { color: o.fill || C.white, width: 0 } };
  if (o.shadow) opts.shadow = { type: 'outer', color: '000000', blur: 6, offset: 2, angle: 90, opacity: 0.10 };
  if (o.radius != null) { opts.rectRadius = o.radius; slide.addShape('roundRect', opts); } else slide.addShape('rect', opts);
}
function card(slide, x, y, w, h, o = {}) {
  rect(slide, x, y, w, h, { fill: o.fill || C.white, line: o.line === undefined ? C.line : o.line, radius: o.radius == null ? 0.12 : o.radius, shadow: o.shadow });
}
function circle(slide, x, y, d, fill) {
  slide.addShape('ellipse', { x, y, w: d, h: d, fill: { color: fill }, line: { color: fill, width: 0 } });
}
function iconCircle(slide, x, y, d, name, o = {}) {
  circle(slide, x, y, d, o.bg || C.teal);
  const pad = d * 0.26;
  slide.addImage({ data: ic(name, o.fg || C.white), x: x + pad, y: y + pad, w: d - 2 * pad, h: d - 2 * pad });
}
function pill(slide, x, y, w, h, text, o = {}) {
  slide.addShape('roundRect', { x, y, w, h, rectRadius: h / 2, fill: { color: o.fill || C.tealL }, line: { color: o.fill || C.tealL, width: 0 } });
  txt(slide, text, { x, y, w, h, fontSize: o.fontSize || 9, bold: true, color: o.color || C.teal, align: 'center', valign: 'middle', charSpacing: 1 });
}
function hline(slide, x, y, w, color = C.line, width = 0.75) {
  slide.addShape('line', { x, y, w, h: 0, line: { color, width } });
}
function bullets(slide, items, o) {
  const runs = items.map((t, i) => {
    const r = typeof t === 'string' ? { text: t } : t;
    return Object.assign({ options: { bullet: { indent: 12 }, breakLine: i < items.length - 1, paraSpaceAfter: o.gap == null ? 4 : o.gap } }, r);
  });
  txt(slide, runs, Object.assign({ fontSize: 11.5, color: C.ink, valign: 'top' }, o));
}

let pageNo = 0;
function header(slide, { section, title, subtitle, sectionColor }) {
  pageNo += 1;
  slide.background = { color: C.bg };
  slide.addImage({ path: path.join(__dirname, 'logo_teal.png'), x: M, y: 0.32, w: 1.25, h: 1.25 * 421 / 1169 });
  if (section) pill(slide, W - M - 1.6, 0.36, 1.6, 0.3, section, { fill: sectionColor || C.tealL, color: sectionColor ? C.white : C.teal });
  const tfs = title.length <= 54 ? 26 : title.length <= 66 ? 22 : 20;
  txt(slide, title, { x: M, y: 0.92, w: W - 2 * M, h: 0.62, fontSize: tfs, bold: true, color: C.teal, valign: 'middle' });
  if (subtitle) txt(slide, subtitle, { x: M, y: 1.55, w: W - 2 * M, h: 0.4, fontSize: 13, color: C.muted, valign: 'top' });
  // footer
  txt(slide, String(pageNo), { x: W - M - 0.6, y: H - 0.42, w: 0.6, h: 0.25, fontSize: 9, color: C.muted, align: 'right', valign: 'middle' });
}
function darkSlide(slide) {
  pageNo += 1;
  slide.background = { color: C.teal };
  slide.addImage({ path: path.join(__dirname, 'logo_white.png'), x: M, y: 0.38, w: 1.6, h: 1.6 * 421 / 1169 });
}
function kpi(slide, x, y, w, h, { label, value, sub, iconName, status, statusColor, statusFill, valueSize }) {
  card(slide, x, y, w, h, { shadow: true, line: null });
  iconCircle(slide, x + 0.22, y + 0.22, 0.5, iconName, { bg: C.tealL, fg: C.teal });
  txt(slide, label, { x: x + 0.85, y: y + 0.22, w: w - 1.05, h: 0.5, fontSize: 11, bold: true, color: C.muted, valign: 'middle' });
  txt(slide, value, { x: x + 0.22, y: y + 0.78, w: w - 0.44, h: 0.55, fontSize: valueSize || 26, bold: true, color: C.teal, valign: 'middle' });
  txt(slide, sub, { x: x + 0.22, y: y + 1.33, w: w - 0.44, h: status ? h - 1.33 - 0.42 : h - 1.33 - 0.15, fontSize: 10, color: C.ink, valign: 'top' });
  if (status) pill(slide, x + 0.22, y + h - 0.4, Math.min(w - 0.44, 2.4), 0.26, status, { fill: statusFill, color: statusColor, fontSize: 8.5 });
}
function callout(slide, x, y, w, h, title, body, o = {}) {
  card(slide, x, y, w, h, { fill: o.fill || C.tealXL, line: null });
  if (o.inline) { // icon + title on the left, body text on the same row
    const tw = o.titleW || 1.9;
    if (o.iconName) iconCircle(slide, x + 0.2, y + (h - 0.42) / 2, 0.42, o.iconName, { bg: o.iconBg || C.teal, fg: C.white });
    txt(slide, title, { x: x + (o.iconName ? 0.75 : 0.25), y, w: tw, h, fontSize: 12.5, bold: true, color: o.titleColor || C.teal, valign: 'middle' });
    txt(slide, body, { x: x + (o.iconName ? 0.75 : 0.25) + tw + 0.1, y, w: w - (o.iconName ? 0.75 : 0.25) - tw - 0.35, h, fontSize: o.fontSize || 11, color: C.ink, valign: 'middle' });
    return;
  }
  if (o.iconName) iconCircle(slide, x + 0.2, y + 0.2, 0.42, o.iconName, { bg: o.iconBg || C.teal, fg: C.white });
  txt(slide, title, { x: x + (o.iconName ? 0.75 : 0.25), y: y + 0.2, w: w - (o.iconName ? 0.95 : 0.5), h: 0.42, fontSize: 12.5, bold: true, color: o.titleColor || C.teal, valign: 'middle' });
  if (Array.isArray(body)) bullets(slide, body, { x: x + 0.25, y: y + 0.7, w: w - 0.5, h: h - 0.85, fontSize: o.fontSize || 11 });
  else txt(slide, body, { x: x + 0.25, y: y + 0.7, w: w - 0.5, h: h - 0.85, fontSize: o.fontSize || 11, color: C.ink, valign: 'top' });
}
// frise chronologique : axe + jalons avec icône, période et carte descriptive
function timeline(slide, steps, o = {}) {
  const y = o.y || 2.85, n = steps.length, gap = o.gap == null ? 0.22 : o.gap;
  const cw = (W - 2 * M - gap * (n - 1)) / n;
  const cardY = y + 0.75, cardH = o.cardH || 2.55;
  slide.addShape('line', { x: M + cw / 2, y, w: W - 2 * M - cw, h: 0, line: { color: C.line, width: 2.5 } });
  steps.forEach((st, i) => {
    const x = M + i * (cw + gap), cx = x + cw / 2;
    txt(slide, st.when, { x, y: y - 0.75, w: cw, h: 0.35, fontSize: 13, bold: true, color: C.orange, align: 'center', valign: 'middle' });
    iconCircle(slide, cx - 0.3, y - 0.3, 0.6, st.icon, { bg: st.last ? C.orange : C.teal, fg: C.white });
    card(slide, x, cardY, cw, cardH, { shadow: true, line: null });
    txt(slide, st.title, { x: x + 0.22, y: cardY + 0.2, w: cw - 0.44, h: 0.62, fontSize: 14, bold: true, color: C.teal, valign: 'middle' });
    hline(slide, x + 0.22, cardY + 0.88, cw - 0.44);
    bullets(slide, st.items, { x: x + 0.22, y: cardY + 1.0, w: cw - 0.44, h: cardH - 1.15, fontSize: 10.5, gap: 5 });
  });
}
function fr(n, dec = 0) { // format nombre à la française
  const s = n.toFixed(dec).split('.');
  s[0] = s[0].replace(/\B(?=(\d{3})+(?!\d))/g, NB);
  return s.join(',');
}

// ---------- data ----------
const SLA = { total: 50, support: 17.87, caseTime: 5.02, tickets: 14, asOf: '2 septembre 2026',
  cats: [
    { name: 'Anomalies produit (Defect)', h: 5.58, n: 5, counted: false },
    { name: 'Demandes de service (Case)', h: 5.02, n: 3, counted: true },
    { name: 'Non catégorisé', h: 4.35, n: 4, counted: false },
    { name: 'Questions simples', h: 2.92, n: 2, counted: false },
  ],
  months: [['Juillet', 7.1, 9], ['Août', 10.1, 8], ['Sept. (au 02/09)', 0.7, 2]] };
const DB = { labels: ['Mars 26', 'Avr. 26', 'Mai 26', 'Juin 26', 'Juil. 26', 'Août 26'], values: [44.0, 44.9, 45.6, 46.8, 46.9, 46.9], limit: 50 };
const UC = { labels: ['Juin 25', 'Juil. 25', 'Août 25', 'Sept. 25', 'Oct. 25', 'Nov. 25', 'Déc. 25', 'Janv. 26', 'Fév. 26', 'Mars 26', 'Avr. 26', 'Mai 26', 'Juin 26', 'Juil. 26', 'Août 26'],
  values: [701932, 704132, 686466, 704410, 717070, 733930, 747925, 755189, 770614, 783378, 792265, 802916, 812472, 820039, 824913] };
const EMAIL = { delivered: 1545190, period: '25 février → 23 août 2026',
  kpis: [
    { key: 'DR', label: 'Délivrabilité', v: 99.37, ind: 98.72, good: 'up' },
    { key: 'VR', label: 'Taux d’ouverture', v: 46.67, ind: 27.25, good: 'up' },
    { key: 'CTO', label: 'Clics / ouvertures', v: 4.08, ind: 11.20, good: 'up' },
    { key: 'CTR', label: 'Clics / délivrés', v: 1.91, ind: 3.05, good: 'up' },
    { key: 'Unsub', label: 'Désabonnement', v: 0.30, ind: 0.20, good: 'down' },
  ] };
const SMS = { // k SMS délivrés / mois — lecture graphique dashboard (arrondi)
  start: [2023, 8],
  values: [4.5, 19.7, 21.0, 20.7, 20.1, 22.3, 7.5, 20.7, 22.7, 23.1, 22.5, 30.5, 21.7, 21.9, 22.8, 22.3, 22.7, 26.0, 22.5, 24.3, 23.3, 21.0, 2.5, 1.8, 1.9, 2.4, 3.1, 2.8, 2.5, 3.9, 3.4, 2.6, 2.3, 1.8, 2.3, 3.3, 6.1] };
const MOIS = ['janv.', 'fév.', 'mars', 'avr.', 'mai', 'juin', 'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'];

// ---------- build ----------
(async () => {
  await preloadIcons([].concat(...["FiActivity", "FiAlertCircle", "FiArrowRight", "FiBarChart2", "FiBookOpen", "FiCalendar", "FiCheckCircle", "FiClock", "FiCpu", "FiDatabase", "FiEye", "FiFileText", "FiFlag", "FiGlobe", "FiGrid", "FiHardDrive", "FiHelpCircle", "FiInfo", "FiKey", "FiLayers", "FiLock", "FiMail", "FiMessageSquare", "FiPieChart", "FiRefreshCw", "FiSearch", "FiSend", "FiSettings", "FiShare2", "FiShield", "FiSmartphone", "FiTarget", "FiTool", "FiTrendingUp", "FiUserCheck", "FiUsers", "FiZap"].map(n => [C.teal, C.white, C.green, C.amber, C.orange, C.teal2].map(c => [n, c]))));

  const pres = new pptxgen();
  pres.layout = 'LAYOUT_WIDE';
  pres.author = 'Nadir Echaara — Selligent';
  pres.company = 'Selligent by Zeta';
  pres.title = 'COPIL Selligent × Mutuelle Viasanté — 14 septembre 2026';
  pres.lang = 'fr-FR';

  // ===== 1. Titre =====
  {
    const s = pres.addSlide(); darkSlide(s);
    // motif cercles
    s.addShape('ellipse', { x: 9.2, y: -1.6, w: 6.2, h: 6.2, fill: { color: C.teal2, transparency: 55 }, line: { color: C.teal2, width: 0 } });
    s.addShape('ellipse', { x: 11.3, y: 3.9, w: 3.6, h: 3.6, fill: { color: C.orange, transparency: 20 }, line: { color: C.orange, width: 0 } });
    s.addShape('ellipse', { x: 8.6, y: 5.2, w: 1.4, h: 1.4, fill: { color: C.teal3, transparency: 40 }, line: { color: C.teal3, width: 0 } });
    txt(s, 'COMITÉ DE PILOTAGE', { x: M, y: 2.15, w: 8, h: 0.35, fontSize: 13, bold: true, color: C.orange, charSpacing: 3 });
    txt(s, 'Mutuelle Viasanté', { x: M, y: 2.55, w: 9, h: 0.95, fontSize: 48, bold: true, color: C.white, valign: 'middle' });
    txt(s, 'Point d’avancement CDM & Engage', { x: M, y: 3.5, w: 9, h: 0.6, fontSize: 24, color: C.white, valign: 'middle' });
    txt(s, DATE_LONG, { x: M, y: 4.25, w: 9, h: 0.4, fontSize: 16, color: 'CFE3E7', valign: 'middle' });
    hline(s, M, 5.35, 3.2, '3D8E9C', 1);
    txt(s, [
      { text: 'Nadir Echaara', options: { bold: true, breakLine: true } },
      { text: 'Customer Success Manager — Selligent', options: { breakLine: true } },
      { text: 'Frederic Schneider', options: { bold: true, breakLine: true } },
      { text: 'Technical Project Manager — Selligent' },
    ], { x: M, y: 5.5, w: 6, h: 1.2, fontSize: 12.5, color: 'E6F0F2', valign: 'top', paraSpaceAfter: 2 });
  }

  // ===== 2. Ordre du jour =====
  {
    const s = pres.addSlide();
    header(s, { title: 'Ordre du jour', subtitle: 'Deux outils, deux séquences : votre CRM (CDM) puis votre plateforme marketing (Engage), et les actions à décider ensemble.' });
    const cols = [
      { n: '01', title: 'CDM — votre CRM', icon: 'FiDatabase', items: ['Consommation du SLA Gold 2026–2027', 'Audience unique et licence', 'Rapidité de l’application : navigation asynchrone', 'Correctif SSO AdminTool et ConfigTool', 'Roadmap CDM 2026–2027'] },
      { n: '02', title: 'Engage — votre plateforme marketing', icon: 'FiSend', items: ['Selligent by Zeta : ce qui change pour vous', 'Taille de la base de données Engage', 'Performance email vs secteur', 'Volumes SMS', 'Connecteur RCS LinkMobility', 'Nouveau SSO Engage : trajectoire', 'Pixel d’ouverture et exigences CNIL', 'Roadmap Engage 2026–2027'] },
      { n: '03', title: 'Synthèse', icon: 'FiFlag', items: ['Vos arbitrages : cinq questions ouvertes', 'Plan d’actions : qui fait quoi, pour quand', 'Date du prochain COPIL'] },
    ];
    const cw = (W - 2 * M - 0.6) / 3, y0 = 2.2, ch = 4.4;
    cols.forEach((c, i) => {
      const x = M + i * (cw + 0.3);
      card(s, x, y0, cw, ch, { shadow: true, line: null });
      txt(s, c.n, { x: x + 0.3, y: y0 + 0.25, w: 1.2, h: 0.7, fontSize: 40, bold: true, color: C.orange, valign: 'middle' });
      iconCircle(s, x + cw - 0.9, y0 + 0.3, 0.6, c.icon, { bg: C.tealL, fg: C.teal });
      txt(s, c.title, { x: x + 0.3, y: y0 + 1.05, w: cw - 0.6, h: 0.55, fontSize: 16, bold: true, color: C.teal, valign: 'middle' });
      hline(s, x + 0.3, y0 + 1.7, cw - 0.6);
      bullets(s, c.items, { x: x + 0.3, y: y0 + 1.9, w: cw - 0.6, h: ch - 2.1, fontSize: 12.5, gap: 7 });
    });
  }

  // ===== 3. Vue d'ensemble =====
  {
    const s = pres.addSlide();
    header(s, { title: 'Votre dispositif Selligent en un coup d’œil', subtitle: 'Trois indicateurs de santé, trois indicateurs d’activité — le détail et les actions suivent dans chaque section.' });
    const rows = [
      { caption: 'SANTÉ DU DISPOSITIF', tiles: [
        { label: 'SLA Gold 2026–2027', value: `7,9${NB}h / 50${NB}h`, sub: `16${NB}% du forfait consommé · 42,1${NB}h disponibles`, iconName: 'FiClock', status: 'SOUS CONTRÔLE', statusFill: C.greenL, statusColor: C.green },
        { label: 'Base de données Engage', value: `47 / 50${NB}GB`, sub: `94${NB}% de la capacité · +3${NB}GB en six mois · au 24/08`, iconName: 'FiDatabase', status: 'À ANTICIPER', statusFill: C.amberL, statusColor: C.amber },
        { label: 'Audience unique (Ucount)', value: fr(824913), sub: `contacts en août 2026 · +20${NB}% sur un an`, iconName: 'FiUsers', status: 'PALIER EN VÉRIFICATION', statusFill: C.tealL, statusColor: C.teal },
      ] },
      { caption: 'ACTIVITÉ DU SEMESTRE (25 FÉVRIER → 23 AOÛT 2026)', tiles: [
        { label: 'Emails délivrés', value: `1,55${NB}M`, sub: `délivrabilité 99,4${NB}% (secteur 98,7${NB}%)`, iconName: 'FiMail' },
        { label: 'Taux de clics email', value: `1,9${NB}%`, sub: `secteur 3,1${NB}% · ouverture 46,7${NB}% (secteur 27,3${NB}%)`, iconName: 'FiTrendingUp' },
        { label: 'SMS délivrés', value: `≈${NB}2–3${NB}k / mois`, sub: `depuis juin 2025 · ≈${NB}22${NB}k / mois auparavant`, iconName: 'FiMessageSquare' },
      ] },
    ];
    const tw = (W - 2 * M - 0.6) / 3, th = 2.0, y0 = 2.0;
    rows.forEach((r, ri) => {
      const cy = y0 + ri * (th + 0.55);
      txt(s, r.caption, { x: M, y: cy, w: 8, h: 0.25, fontSize: 9, bold: true, color: C.muted, charSpacing: 2, valign: 'middle' });
      r.tiles.forEach((t, i) => kpi(s, M + i * (tw + 0.3), cy + 0.3, tw, th, t));
    });
  }

  // ===== 4. Intercalaire CDM =====
  function divider(num, title, sub, topics) {
    const s = pres.addSlide(); darkSlide(s);
    s.addShape('ellipse', { x: 9.6, y: 1.2, w: 5.2, h: 5.2, fill: { color: C.teal2, transparency: 55 }, line: { color: C.teal2, width: 0 } });
    s.addShape('ellipse', { x: 8.9, y: 4.6, w: 1.6, h: 1.6, fill: { color: C.orange, transparency: 15 }, line: { color: C.orange, width: 0 } });
    txt(s, num, { x: M, y: 1.55, w: 3, h: 0.9, fontSize: 56, bold: true, color: C.orange, valign: 'middle' });
    txt(s, title, { x: M, y: 2.45, w: 9.3, h: 1.35, fontSize: 36, bold: true, color: C.white, valign: 'middle' });
    txt(s, sub, { x: M, y: 3.85, w: 9.3, h: 0.45, fontSize: 18, color: 'CFE3E7', valign: 'middle' });
    txt(s, topics.map((t, i) => ({ text: t, options: { breakLine: i < topics.length - 1, bullet: { indent: 12 }, paraSpaceAfter: 3 } })), { x: M, y: 4.55, w: 7.5, h: 1.9, fontSize: 13, color: 'E6F0F2' });
    return s;
  }
  divider('01', 'CDM — votre CRM', 'Exploitation, correctifs et trajectoire produit', ['SLA Gold : consommation et règle de décompte', 'Audience unique et licence', 'Rapidité de l’application : navigation asynchrone', 'Correctif SSO AdminTool et ConfigTool', 'Roadmap 2026–2027']);

  // ===== 5. SLA =====
  {
    const s = pres.addSlide();
    header(s, { section: 'CDM', title: 'Support : 8 h consommées sur 50, un rythme maîtrisé', subtitle: `SLA Gold 50${NB}h · 36,7${NB}h de temps de support, dont 7,9${NB}h décomptées de votre forfait · 42,1${NB}h restent disponibles.` });
    // gauge card
    card(s, M, 2.15, 3.6, 4.65, { shadow: true, line: null });
    txt(s, 'Forfait SLA consommé', { x: M + 0.25, y: 2.35, w: 3.1, h: 0.3, fontSize: 11, bold: true, color: C.muted });
    s.addChart(pres.charts.DOUGHNUT, [{ name: 'SLA', labels: ['Consommé', 'Disponible'], values: [7.92, 42.08] }], {
      x: M + 0.35, y: 2.7, w: 2.9, h: 2.9, holeSize: 68, chartColors: [C.orange, 'DDE6E9'], showLegend: false, showValue: false, showLabel: false, showPercent: false, dataBorder: { pt: 0, color: C.white },
    });
    txt(s, `16${NB}%`, { x: M + 0.35, y: 3.7, w: 2.9, h: 0.6, fontSize: 32, bold: true, color: C.teal, align: 'center', valign: 'middle' });
    txt(s, `7,9${NB}h sur 50${NB}h`, { x: M + 0.35, y: 4.28, w: 2.9, h: 0.3, fontSize: 11, color: C.muted, align: 'center' });
    txt(s, [{ text: `42,1${NB}h `, options: { bold: true, color: C.teal } }, { text: 'restent disponibles sur votre forfait' }], { x: M + 0.25, y: 5.8, w: 3.1, h: 0.8, fontSize: 11.5, color: C.ink, align: 'center', valign: 'middle' });
    // split bars card
    const bx = M + 3.9, bw = 5.2;
    card(s, bx, 2.15, bw, 4.65, { shadow: true, line: null });
    txt(s, `Répartition du temps de support — 36,7${NB}h`, { x: bx + 0.25, y: 2.35, w: bw - 0.5, h: 0.3, fontSize: 11, bold: true, color: C.muted });
    const splits = [
      { name: 'Décompté de votre forfait', detail: 'demandes de service', h: 7.92, counted: true },
      { name: 'Pris en charge par Selligent', detail: 'anomalies produit, questions, suivi', h: 28.75, counted: false },
    ];
    const barX = bx + 0.25, barW = bw - 1.5, maxH = 36.7;
    splits.forEach((c, i) => {
      const y = 2.85 + i * 1.05;
      txt(s, [{ text: c.name, options: { bold: true } }, { text: `  ·  ${c.detail}`, options: { color: C.muted } }], { x: barX, y, w: barW + 1.0, h: 0.28, fontSize: 11, valign: 'middle' });
      rect(s, barX, y + 0.34, barW, 0.36, { fill: 'EEF3F5', radius: 0.06 });
      rect(s, barX, y + 0.34, Math.max(0.12, barW * c.h / maxH), 0.36, { fill: c.counted ? C.orange : C.teal3, radius: 0.06 });
      txt(s, `${fr(c.h, 1)}${NB}h`, { x: barX + barW + 0.1, y: y + 0.34, w: 0.9, h: 0.36, fontSize: 12, bold: true, color: c.counted ? C.orange : C.teal, valign: 'middle' });
    });
    hline(s, barX, 5.15, barW + 1.0);
    txt(s, 'Nature des demandes traitées depuis juillet', { x: barX, y: 5.3, w: bw - 0.5, h: 0.3, fontSize: 11, bold: true, color: C.muted, valign: 'middle' });
    const nat = [['Anomalies produit', 5], ['Demandes de service', 3], ['Questions d’usage', 2], ['Suivi et divers', 4]];
    nat.forEach(([label, count], i) => {
      const x = barX + (i % 2) * ((barW + 1.0) / 2), y = 5.7 + Math.floor(i / 2) * 0.45;
      circle(s, x, y + 0.05, 0.3, i === 1 ? C.orange : C.tealL);
      txt(s, String(count), { x, y: y + 0.05, w: 0.3, h: 0.3, fontSize: 11, bold: true, color: i === 1 ? C.white : C.teal, align: 'center', valign: 'middle' });
      txt(s, label, { x: x + 0.4, y, w: (barW + 1.0) / 2 - 0.5, h: 0.4, fontSize: 10.5, color: C.ink, valign: 'middle' });
    });
    // rule callout
    const cx = bx + bw + 0.3, cw = W - M - cx;
    callout(s, cx, 2.15, cw, 2.85, 'Règle de décompte', ['Seules les demandes de service sont décomptées des 50 h de votre forfait.', 'Anomalies produit, questions d’usage et suivi sont pris en charge par Selligent, hors forfait.'], { iconName: 'FiInfo', fontSize: 10.5 });
    callout(s, cx, 5.15, cw, 1.65, 'Suivi', ['Point SLA mensuel dans votre reporting.', 'Alerte dès 60 % de consommation.'], { iconName: 'FiCheckCircle', iconBg: C.green, fill: C.greenL, titleColor: C.green, fontSize: 10.5 });
  }

  // ===== 7. Ucount =====
  {
    const s = pres.addSlide();
    header(s, { section: 'CDM', title: 'Audience unique : 824 913 contacts, en croissance régulière', subtitle: 'Indicateur Ucount (contacts uniques) de votre licence Gold — évolution de juin 2025 à août 2026.' });
    card(s, M, 2.15, 7.9, 4.65, { shadow: true, line: null });
    txt(s, 'Contacts uniques (Ucount) par mois', { x: M + 0.25, y: 2.3, w: 7.4, h: 0.3, fontSize: 11, bold: true, color: C.muted });
    s.addChart(pres.charts.LINE, [{ name: 'Ucount', labels: UC.labels, values: UC.values }], {
      x: M + 0.2, y: 2.65, w: 7.5, h: 3.7, chartColors: [C.teal], lineSize: 2.5, lineDataSymbol: 'circle', lineDataSymbolSize: 6,
      valAxisMinVal: 650000, valAxisMaxVal: 850000, valAxisMajorUnit: 50000, valAxisLabelFormatCode: '#,##0',
      catAxisLabelColor: C.muted, valAxisLabelColor: C.muted, catAxisLabelFontSize: 9, valAxisLabelFontSize: 9, catAxisLabelRotate: -45,
      valGridLine: { color: 'E6ECEF', size: 0.5 }, catGridLine: { style: 'none' }, showLegend: false, showValue: false,
    });
    const rx = M + 8.2, rw = W - M - rx;
    kpi(s, rx, 2.15, rw, 1.45, { label: 'Août 2026', value: fr(824913), sub: `+0,6${NB}% vs juillet (+${fr(4874)}) · +20,2${NB}% sur un an`, iconName: 'FiUsers', valueSize: 24 });
    kpi(s, rx, 3.75, rw, 1.45, { label: 'Depuis juin 2025', value: `+17,5${NB}%`, sub: `≈${NB}+8${NB}800 contacts par mois · en ralentissement`, iconName: 'FiTrendingUp', valueSize: 24 });
    callout(s, rx, 5.35, rw, 1.45, 'Question', 'Votre palier de licence est-il toujours adapté ? Quel volume de contacts prévoyez-vous en 2027 ?', { iconName: 'FiHelpCircle', iconBg: C.orange, fill: C.orangeL, titleColor: C.orange, fontSize: 11 });
  }

  // ===== 8a. Navigation asynchrone — rapidité de l'application =====
  {
    const s = pres.addSlide();
    header(s, { section: 'CDM', title: 'Rapidité de l’application : le patch de navigation asynchrone', subtitle: 'Correctif en cours de résolution sur les temps de réponse et la fluidité de navigation dans CDM.' });
    // statut hero
    card(s, M, 2.15, 3.9, 4.65, { fill: C.tealXL, line: null });
    iconCircle(s, M + 1.45, 2.55, 1.0, 'FiActivity', { bg: C.teal, fg: C.white });
    txt(s, 'Navigation asynchrone', { x: M + 0.3, y: 3.75, w: 3.3, h: 0.5, fontSize: 17, bold: true, color: C.teal, align: 'center', valign: 'middle' });
    pill(s, M + 0.8, 4.4, 2.3, 0.36, 'EN COURS DE RÉSOLUTION', { fill: C.amberL, color: C.amber, fontSize: 9.5 });
    txt(s, 'Correctif développé par nos équipes produit, redescente planifiée le 10 septembre 2026.', { x: M + 0.35, y: 5.0, w: 3.2, h: 1.0, fontSize: 11.5, color: C.ink, align: 'center', valign: 'top' });
    // three cards
    const cx = M + 4.2, cw = (W - M - cx - 0.5) / 3;
    const cards = [
      { icon: 'FiClock', title: 'Le constat', items: ['Temps de réponse dégradés sur certains écrans.', 'Enchaînement des actions ralenti pour vos utilisateurs.'] },
      { icon: 'FiTool', title: 'Ce que nous faisons', items: ['Passage de la navigation en mode asynchrone.', 'Correctif validé en interne, redescente planifiée.'] },
      { icon: 'FiUsers', title: 'Pour vos équipes', items: ['Navigation plus fluide, sans changement d’usage.', 'Aucune action ni paramétrage de votre côté.'] },
    ];
    cards.forEach((c, i) => {
      const x = cx + i * (cw + 0.25);
      card(s, x, 2.15, cw, 4.65, { shadow: true, line: null });
      iconCircle(s, x + 0.25, 2.4, 0.6, c.icon, { bg: C.tealL, fg: C.teal });
      txt(s, c.title, { x: x + 0.25, y: 3.15, w: cw - 0.5, h: 0.45, fontSize: 14, bold: true, color: C.teal, valign: 'middle' });
      hline(s, x + 0.25, 3.68, cw - 0.5);
      bullets(s, c.items, { x: x + 0.25, y: 3.8, w: cw - 0.5, h: 2.8, fontSize: 11, gap: 8 });
    });
  }

  // ===== 8b. Correctif SSO AdminTool / ConfigTool =====
  {
    const s = pres.addSlide();
    header(s, { section: 'CDM', title: 'Correctif SSO sur les pages AdminTool et ConfigTool', subtitle: 'Solution communiquée le 31 août 2026, correctif en cours de résolution sur l’authentification des pages d’administration.' });
    const items = [
      { icon: 'FiLock', title: 'Le périmètre', items: ['Authentification SSO des pages d’administration.', 'AdminTool et ConfigTool uniquement.'] },
      { icon: 'FiFileText', title: 'Où nous en sommes', items: ['Solution communiquée le 31 août 2026.', 'Correctif en cours de résolution côté produit.'] },
      { icon: 'FiUsers', title: 'Pour vos équipes', items: ['Aucun impact sur les utilisateurs finaux du CRM.', 'Accès d’administration mieux sécurisés à l’issue du correctif.'] },
      { icon: 'FiAlertCircle', title: 'À ne pas confondre', items: ['Sujet technique CDM, sans lien avec le nouveau SSO Engage.', 'Le SSO Engage suit sa propre trajectoire, fenêtre cible T1 2027.'] },
    ];
    const n = items.length, gap = 0.22, cw = (W - 2 * M - gap * (n - 1)) / n, y0 = 2.15, ch = 3.3;
    items.forEach((c, i) => {
      const x = M + i * (cw + gap);
      card(s, x, y0, cw, ch, { shadow: true, line: null });
      iconCircle(s, x + 0.25, y0 + 0.25, 0.6, c.icon, { bg: i === 3 ? C.orange : C.teal, fg: C.white });
      txt(s, c.title, { x: x + 0.25, y: y0 + 1.0, w: cw - 0.5, h: 0.45, fontSize: 14, bold: true, color: i === 3 ? C.orange : C.teal, valign: 'middle' });
      hline(s, x + 0.25, y0 + 1.53, cw - 0.5);
      bullets(s, c.items, { x: x + 0.25, y: y0 + 1.65, w: cw - 0.5, h: ch - 1.8, fontSize: 11, gap: 7 });
    });
    // bandeau statut
    const by = y0 + ch + 0.35;
    card(s, M, by, W - 2 * M, 1.15, { fill: C.tealXL, line: null });
    iconCircle(s, M + 0.3, by + 0.3, 0.55, 'FiShield', { bg: C.teal, fg: C.white });
    txt(s, 'Statut', { x: M + 1.05, y: by, w: 1.2, h: 1.15, fontSize: 13, bold: true, color: C.teal, valign: 'middle' });
    txt(s, 'Correctif en cours de résolution. Nous vous confirmons la mise en production et son résultat dès la clôture du sujet.', { x: M + 2.3, y: by, w: W - 2 * M - 5.0, h: 1.15, fontSize: 12, color: C.ink, valign: 'middle' });
    pill(s, W - M - 2.6, by + 0.4, 2.3, 0.36, 'EN COURS DE RÉSOLUTION', { fill: C.amberL, color: C.amber, fontSize: 9.5 });
  }

  // ===== 9. Roadmap CDM =====
  {
    const s = pres.addSlide();
    header(s, { section: 'CDM', title: 'Roadmap CDM : cinq étapes de fin 2026 à fin 2027', subtitle: 'Votre CRM évolue de l’ergonomie et de la qualité de donnée vers l’automatisation, puis l’intelligence artificielle en fin de parcours.' });
    timeline(s, [
      { when: 'Fin 2026', icon: 'FiGrid', title: 'Expérience utilisateur', items: ['Interface modernisée, vues personnalisables', 'Navigation simplifiée vers les fonctions clés'] },
      { when: 'Q1 2027', icon: 'FiLayers', title: 'Vue client 360°', items: ['Historique, interactions, incidents et opportunités réunis', 'Dédoublonnage centralisé et validation automatique'] },
      { when: 'Q2 2027', icon: 'FiZap', title: 'Automatisation', items: ['Workflows de relance et gestion d’incidents', 'Rappels intelligents sur les échéances clés'] },
      { when: 'Q3 2027', icon: 'FiBarChart2', title: 'Analytique avancée', items: ['Tableaux de bord ventes et service client', 'Segmentation dynamique et rapports prédictifs'] },
      { when: 'Q4 2027', icon: 'FiCpu', title: 'Intelligence artificielle', items: ['Suggestions d’actions et priorisation des tâches', 'Aide à la rédaction, auto-complétion, recherche intelligente'], last: true },
    ], { y: 2.95, cardH: 2.5 });
    txt(s, 'Quelles étapes sont prioritaires pour vos équipes ?', { x: M, y: 6.45, w: W - 2 * M, h: 0.35, fontSize: 12.5, bold: true, color: C.teal, align: 'center', valign: 'middle' });
  }

  // ===== 10. Intercalaire Engage =====
  divider('02', 'Engage — votre plateforme marketing', 'Continuité, capacité, performance, canaux et conformité', ['Selligent by Zeta : ce qui change, ce qui ne change pas', 'Taille de la base de données Engage', 'Performance email vs secteur', 'Volumes SMS', 'Connecteur RCS LinkMobility', 'Nouveau SSO Engage : trajectoire', 'Pixel d’ouverture et exigences CNIL', 'Roadmap Engage 2026–2027']);

  // ===== Selligent by Zeta =====
  {
    const s = pres.addSlide();
    header(s, { section: 'ENGAGE', title: 'Selligent by Zeta : ce qui change, ce qui ne change pas', subtitle: 'Selligent fait désormais partie de Zeta Global. Pour Mutuelle Viasanté, la continuité prime : mêmes équipes, mêmes conditions, une plateforme qui continue d’investir.' });
    const cards = [
      { icon: 'FiTrendingUp', title: 'Un investissement produit continu', body: ['Équipes produit et ingénierie en Belgique, renforcées par des équipes dédiées à l’IA et à la donnée.', 'Roadmap Engage active : conformité, données, orchestration, intelligence.'] },
      { icon: 'FiRefreshCw', title: 'Aucune migration imposée', body: ['Priorité : tirer le meilleur de votre plateforme actuelle.', 'Les capacités Zeta (IA, données) viennent en complément, uniquement si elles servent vos besoins.'] },
      { icon: 'FiFileText', title: 'Vos conditions préservées', body: ['Aucun changement tarifaire imposé au renouvellement pour les clients Selligent.', 'Vos modules et vos usages restent inchangés.'] },
      { icon: 'FiGlobe', title: 'Europe, RGPD et proximité', body: ['Stratégie produit fondée sur le marché européen et sur les retours des clients.', 'RGPD, confidentialité et réglementation européenne restent prioritaires ; vos interlocuteurs restent les mêmes.'] },
    ];
    const n = cards.length, gap = 0.22, cw = (W - 2 * M - gap * (n - 1)) / n, y0 = 2.15, ch = 4.2;
    cards.forEach((c, i) => {
      const x = M + i * (cw + gap);
      card(s, x, y0, cw, ch, { shadow: true, line: null });
      iconCircle(s, x + 0.22, y0 + 0.22, 0.6, c.icon, { bg: C.teal, fg: C.white });
      txt(s, c.title, { x: x + 0.22, y: y0 + 0.95, w: cw - 0.44, h: 0.7, fontSize: 13.5, bold: true, color: C.teal, valign: 'middle' });
      hline(s, x + 0.22, y0 + 1.75, cw - 0.44);
      bullets(s, c.body, { x: x + 0.22, y: y0 + 1.9, w: cw - 0.44, h: ch - 2.05, fontSize: 11, gap: 6 });
    });
  }

  // ===== Base de données Engage =====
  {
    const s = pres.addSlide();
    header(s, { section: 'ENGAGE', title: 'Base de données Engage : 47 GB sur 50, anticipons ensemble', subtitle: '+3 GB en six mois, par paliers, et un plateau à 47 GB depuis juin : 3 GB de marge, soit environ six mois si le rythme du premier semestre reprend.' });
    // chart card
    card(s, M, 2.15, 7.4, 4.65, { shadow: true, line: null });
    txt(s, 'Taille de la base de données Engage (GB, moyenne mensuelle) — mars à août 2026', { x: M + 0.25, y: 2.3, w: 6.9, h: 0.3, fontSize: 11, bold: true, color: C.muted });
    s.addChart([
      { type: pres.charts.BAR, data: [{ name: 'Taille (GB)', labels: DB.labels, values: DB.values }], options: { chartColors: [C.teal3], barGapWidthPct: 60 } },
      { type: pres.charts.LINE, data: [{ name: 'Seuil 50 GB', labels: DB.labels, values: DB.labels.map(() => DB.limit) }], options: { chartColors: [C.orange], lineSize: 2, lineDataSymbol: 'none', lineDash: 'dash', showValue: false } },
    ], {
      x: M + 0.2, y: 2.65, w: 7.0, h: 3.7, valAxisMinVal: 0, valAxisMaxVal: 55, valAxisMajorUnit: 10,
      showValue: true, dataLabelPosition: 'outEnd', dataLabelFontSize: 10, dataLabelColor: C.teal, dataLabelFormatCode: '0.0',
      catAxisLabelColor: C.muted, valAxisLabelColor: C.muted, catAxisLabelFontSize: 10, valAxisLabelFontSize: 10,
      valGridLine: { color: 'E6ECEF', size: 0.5 }, catGridLine: { style: 'none' }, showLegend: true, legendPos: 'b', legendFontSize: 10, legendColor: C.muted,
    });
    // right column
    const rx = M + 7.7, rw = W - M - rx;
    kpi(s, rx, 2.15, rw, 1.55, { label: 'Marge restante', value: `3${NB}GB (6${NB}%)`, sub: 'sur un seuil de 50 GB', iconName: 'FiHardDrive', valueSize: 24 });
    card(s, rx, 3.85, rw, 2.95, { fill: C.orangeL, line: null });
    iconCircle(s, rx + 0.25, 4.05, 0.5, 'FiFileText', { bg: C.orange, fg: C.white });
    txt(s, 'Extension de capacité', { x: rx + 0.9, y: 4.05, w: rw - 1.15, h: 0.5, fontSize: 12.5, bold: true, color: C.orange, valign: 'middle' });
    txt(s, `+100${NB}GB`, { x: rx + 0.25, y: 4.7, w: rw - 0.5, h: 0.55, fontSize: 30, bold: true, color: C.teal, valign: 'middle' });
    txt(s, `6 900${NB}€ / an`, { x: rx + 0.25, y: 5.3, w: rw - 0.5, h: 0.45, fontSize: 20, bold: true, color: C.teal, valign: 'middle' });
    txt(s, 'Passage de 50 à 150 GB. Alternative : purger et archiver les données obsolètes.', { x: rx + 0.25, y: 5.85, w: rw - 0.5, h: 0.8, fontSize: 10.5, color: C.ink, valign: 'top' });
  }

  // ===== 11. Email performance =====
  {
    const s = pres.addSlide();
    header(s, { section: 'ENGAGE', title: 'Email : délivrabilité exemplaire, le clic comme prochain levier', subtitle: `${fr(EMAIL.delivered)} emails délivrés du ${EMAIL.period} · panel de référence : 48 plateformes Selligent, secteur Services.` });
    // KPI tiles row
    const n = EMAIL.kpis.length, gap = 0.2, tw = (W - 2 * M - gap * (n - 1)) / n, ty = 2.05, th = 1.5;
    EMAIL.kpis.forEach((k, i) => {
      const x = M + i * (tw + gap);
      const better = k.good === 'up' ? k.v >= k.ind : k.v <= k.ind;
      const near = Math.abs(k.v - k.ind) < 0.7 && k.key === 'DR';
      const col = better ? C.green : (k.key === 'Unsub' ? C.amber : C.amber);
      const fill = better ? C.greenL : C.amberL;
      card(s, x, ty, tw, th, { shadow: true, line: null });
      txt(s, k.label, { x: x + 0.2, y: ty + 0.15, w: tw - 0.4, h: 0.3, fontSize: 10.5, bold: true, color: C.muted, valign: 'middle' });
      txt(s, `${fr(k.v, 2)}${NB}%`, { x: x + 0.2, y: ty + 0.45, w: tw - 0.4, h: 0.55, fontSize: 24, bold: true, color: C.teal, valign: 'middle' });
      pill(s, x + 0.2, ty + 1.08, tw - 0.4, 0.3, `${better ? '▲' : '▼'}  secteur ${fr(k.ind, 2)}${NB}%`, { fill, color: col, fontSize: 9 });
    });
    // chart
    const cy = 3.75, chH = 3.05;
    card(s, M, cy, 6.6, chH, { shadow: true, line: null });
    txt(s, 'Taux d’engagement : Viasanté vs secteur (%)', { x: M + 0.25, y: cy + 0.12, w: 6.1, h: 0.3, fontSize: 11, bold: true, color: C.muted });
    s.addChart(pres.charts.BAR, [
      { name: 'Viasanté', labels: ['Ouverture', 'Clics / ouvertures', 'Clics / délivrés'], values: [46.67, 4.08, 1.91] },
      { name: 'Secteur', labels: ['Ouverture', 'Clics / ouvertures', 'Clics / délivrés'], values: [27.25, 11.20, 3.05] },
    ], {
      x: M + 0.2, y: cy + 0.38, w: 6.2, h: chH - 0.85, barDir: 'col', barGrouping: 'clustered', barGapWidthPct: 80, chartColors: [C.teal, C.grey],
      showValue: true, dataLabelPosition: 'outEnd', dataLabelFontSize: 9, dataLabelColor: C.ink, dataLabelFormatCode: '0.0',
      valAxisMinVal: 0, valAxisMaxVal: 55, valAxisMajorUnit: 10, valAxisLabelFontSize: 9, catAxisLabelFontSize: 10, catAxisLabelColor: C.muted, valAxisLabelColor: C.muted,
      valGridLine: { color: 'E6ECEF', size: 0.5 }, catGridLine: { style: 'none' }, showLegend: true, legendPos: 'r', legendFontSize: 10, legendColor: C.muted,
    });
    const rx = M + 6.9, rw = W - M - rx;
    callout(s, rx, cy, rw, 1.45, 'Ce que disent les chiffres', ['99,4 % délivrés et près d’un email sur deux ouvert : la chaîne technique délivre.', 'Le clic est en retrait : 1,9 % contre 3,1 % pour le secteur.'], { iconName: 'FiEye', fontSize: 10.5 });
    callout(s, rx, cy + 1.6, rw, chH - 1.6, 'Le levier 2027', ['Les contenus et les appels à l’action, pas l’infrastructure.', 'Ciblage plus fin et scénarios relationnels sur les campagnes à fort volume.', 'Objectif : rapprocher le taux de clics du niveau du secteur.'], { iconName: 'FiTarget', iconBg: C.orange, fill: C.orangeL, titleColor: C.orange, fontSize: 10.5 });
  }

  // ===== 12. SMS & RCS =====
  {
    const s = pres.addSlide();
    header(s, { section: 'ENGAGE', title: 'SMS : un canal en retrait depuis juin 2025', subtitle: 'Quelle place voulez-vous donner au mobile en 2027 ? Le connecteur RCS ouvre une alternative, présentée sur la page suivante.' });
    card(s, M, 2.15, 8.4, 4.65, { shadow: true, line: null });
    txt(s, 'SMS délivrés par mois (milliers) — août 2023 à août 2026', { x: M + 0.25, y: 2.3, w: 7.9, h: 0.3, fontSize: 11, bold: true, color: C.muted });
    const labels = SMS.values.map((_, i) => { const m = (SMS.start[1] - 1 + i) % 12, y = SMS.start[0] + Math.floor((SMS.start[1] - 1 + i) / 12); return (m === 0 || m === 6) ? `${MOIS[m]} ${String(y).slice(2)}` : ''; });
    s.addChart(pres.charts.BAR, [{ name: 'SMS délivrés (k)', labels, values: SMS.values }], {
      x: M + 0.2, y: 2.65, w: 8.0, h: 3.9, barDir: 'col', barGapWidthPct: 35, chartColors: [C.teal3],
      valAxisMinVal: 0, valAxisMaxVal: 35, valAxisMajorUnit: 5, valAxisLabelFontSize: 9, catAxisLabelFontSize: 9, catAxisLabelColor: C.muted, valAxisLabelColor: C.muted,
      valGridLine: { color: 'E6ECEF', size: 0.5 }, catGridLine: { style: 'none' }, showLegend: false, showValue: false,
    });
    const rx = M + 8.7, rw = W - M - rx;
    kpi(s, rx, 2.15, rw, 1.45, { label: 'Total délivré', value: `≈${NB}0,5${NB}M`, sub: 'd’août 2023 à août 2026', iconName: 'FiMessageSquare', valueSize: 26 });
    kpi(s, rx, 3.75, rw, 1.45, { label: 'Jusqu’en mai 2025', value: `20–26${NB}k`, sub: 'SMS par mois, pic à 30 k en juillet 2024', iconName: 'FiTrendingUp', valueSize: 26 });
    kpi(s, rx, 5.35, rw, 1.45, { label: 'Depuis juin 2025', value: `2–3${NB}k`, sub: 'SMS par mois, 6 k en août 2026', iconName: 'FiActivity', valueSize: 26 });
  }

  // ===== 12b. Connecteur RCS LinkMobility =====
  {
    const s = pres.addSlide();
    header(s, { section: 'ENGAGE', title: 'Connecteur RCS LinkMobility : prêt, par API, sans interface', subtitle: 'Le connecteur est disponible et fonctionne désormais par API. Il n’a pas d’interface graphique : c’est un passe-plat simple et efficace.' });
    // hero statut
    card(s, M, 2.15, 3.9, 4.65, { fill: C.tealXL, line: null });
    iconCircle(s, M + 1.45, 2.55, 1.0, 'FiSmartphone', { bg: C.teal, fg: C.white });
    txt(s, 'LinkMobility', { x: M + 0.3, y: 3.75, w: 3.3, h: 0.5, fontSize: 19, bold: true, color: C.teal, align: 'center', valign: 'middle' });
    pill(s, M + 1.1, 4.4, 1.7, 0.36, 'CONNECTEUR PRÊT', { fill: C.greenL, color: C.green, fontSize: 9.5 });
    txt(s, 'Disponible pour vos campagnes RCS, avec les mêmes limites fonctionnelles qu’auparavant.', { x: M + 0.35, y: 5.0, w: 3.2, h: 1.0, fontSize: 11.5, color: C.ink, align: 'center', valign: 'top' });
    // trois cartes
    const cx = M + 4.2, cw = (W - M - cx - 0.5) / 3;
    const cards = [
      { icon: 'FiZap', title: 'Une intégration par API', items: ['Le connecteur fonctionne désormais par API.', 'Fin des dépôts de fichiers par SFTP.', 'Envois déclenchés directement depuis Engage.'] },
      { icon: 'FiEye', title: 'Pas d’interface graphique', items: ['Aucune interface dédiée à la composition des messages.', 'Donc pas de prévisualisation avant envoi.', 'Le rendu se vérifie sur un terminal de test.'] },
      { icon: 'FiSend', title: 'Un passe-plat simple', items: ['Mise en œuvre rapide, sans projet lourd.', 'Adapté aux envois RCS standardisés.', 'Une interface complète passerait par Infobip.'] },
    ];
    cards.forEach((c, i) => {
      const x = cx + i * (cw + 0.25);
      card(s, x, 2.15, cw, 4.65, { shadow: true, line: null });
      iconCircle(s, x + 0.25, 2.4, 0.6, c.icon, { bg: i === 1 ? C.orange : C.teal, fg: C.white });
      txt(s, c.title, { x: x + 0.25, y: 3.15, w: cw - 0.5, h: 0.7, fontSize: 14, bold: true, color: i === 1 ? C.orange : C.teal, valign: 'middle' });
      hline(s, x + 0.25, 3.9, cw - 0.5);
      bullets(s, c.items, { x: x + 0.25, y: 4.02, w: cw - 0.5, h: 2.6, fontSize: 11, gap: 8 });
    });
  }

  // ===== 13. SSO Engage =====
  {
    const s = pres.addSlide();
    header(s, { section: 'ENGAGE', title: 'Nouveau SSO Engage : fenêtre cible au 1er trimestre 2027', subtitle: 'Une trajectoire produit progressive pour le nouveau système d’authentification ; votre accès actuel reste en place jusqu’à la bascule.' });
    const steps = [
      { when: 'Aujourd’hui', title: 'Authentification actuelle', body: 'Fonctionnement inchangé et support assuré jusqu’à la bascule.', icon: 'FiKey', bg: C.teal3 },
      { when: 'Fenêtre cible : 1er trimestre 2027', title: 'Nouveau SSO Engage', body: 'Mise à disposition du nouveau système d’authentification — trajectoire produit, pas avant cette fenêtre.', icon: 'FiLock', bg: C.teal },
      { when: 'Ensuite', title: 'Bascule accompagnée', body: 'Préparation avec vos équipes, puis adoption progressive des utilisateurs.', icon: 'FiUserCheck', bg: C.orange },
    ];
    const n = steps.length, gap = 0.12, sw = (W - 2 * M - gap * (n - 1)) / n, y0 = 2.2;
    steps.forEach((st, i) => {
      const x = M + i * (sw + gap);
      s.addShape(i === 0 ? 'homePlate' : 'chevron', { x, y: y0, w: sw, h: 0.6, fill: { color: st.bg }, line: { color: st.bg, width: 0 } });
      txt(s, st.when, { x: x + (i === 0 ? 0.15 : 0.35), y: y0, w: sw - 0.6, h: 0.6, fontSize: 13, bold: true, color: C.white, valign: 'middle' });
      card(s, x, y0 + 0.8, sw, 1.65, { shadow: true, line: null });
      iconCircle(s, x + 0.22, y0 + 1.0, 0.5, st.icon, { bg: C.tealL, fg: C.teal });
      txt(s, st.title, { x: x + 0.85, y: y0 + 1.0, w: sw - 1.05, h: 0.5, fontSize: 12.5, bold: true, color: C.teal, valign: 'middle' });
      txt(s, st.body, { x: x + 0.22, y: y0 + 1.6, w: sw - 0.44, h: 0.8, fontSize: 11, color: C.ink });
    });
    const cy = 4.95, ch = 1.75, cw = (W - 2 * M - 0.3) / 2;
    callout(s, M, cy, cw, ch, 'Ce qui change pour vous', ['Une connexion unifiée et sécurisée à Engage.', 'Un accompagnement Selligent pour la bascule des utilisateurs.'], { iconName: 'FiCheckCircle', iconBg: C.green, fill: C.greenL, titleColor: C.green, fontSize: 10.5 });
    callout(s, M + cw + 0.3, cy, cw, ch, 'Ce qui ne change pas', ['Aucune bascule avant la fenêtre cible du 1er trimestre 2027.', 'Sujet distinct du correctif SSO en cours sur les pages d’administration CDM.'], { iconName: 'FiInfo', fontSize: 10.5 });
  }

  // ===== 14. Pixel d'ouverture =====
  {
    const s = pres.addSlide();
    header(s, { section: 'CONFORMITÉ', title: 'Pixel d’ouverture : le cadre CNIL appliqué dans Engage', subtitle: 'Recommandation finale du 14 avril 2026, période transitoire close le 14 juillet · Engage trace déjà les ouvertures sous consentement.' });
    const steps = [
      { icon: 'FiSearch', title: 'Cartographier', body: 'Recenser les cas d’usage : marketing, newsletters, transactionnel, mesure de délivrabilité.' },
      { icon: 'FiBookOpen', title: 'Qualifier la base légale', body: 'Consentement préalable par défaut ; exemption limitée à la mesure de délivrabilité d’un service demandé.' },
      { icon: 'FiFileText', title: 'Informer et prouver', body: 'Information claire, preuve du consentement, gestion du retrait, journal d’audit.' },
      { icon: 'FiUserCheck', title: 'Valider avec votre DPO', body: 'Go / no-go par typologie d’email, puis activation des seules catégories autorisées.' },
    ];
    const n = steps.length, gap = 0.22, sw = (W - 2 * M - gap * (n - 1)) / n, y0 = 2.15, sh = 2.25;
    steps.forEach((st, i) => {
      const x = M + i * (sw + gap);
      card(s, x, y0, sw, sh, { shadow: true, line: null });
      iconCircle(s, x + 0.22, y0 + 0.22, 0.6, st.icon, { bg: C.teal, fg: C.white });
      txt(s, String(i + 1), { x: x + sw - 0.8, y: y0 + 0.2, w: 0.6, h: 0.6, fontSize: 24, bold: true, color: C.orange, align: 'right', valign: 'middle' });
      txt(s, st.title, { x: x + 0.22, y: y0 + 0.95, w: sw - 0.44, h: 0.4, fontSize: 13, bold: true, color: C.teal, valign: 'middle' });
      txt(s, st.body, { x: x + 0.22, y: y0 + 1.4, w: sw - 0.44, h: 0.9, fontSize: 10.5, color: C.ink });
    });
    const cy = y0 + sh + 0.25, ch = 6.8 - cy, cw = (W - 2 * M - 0.5) / 3;
    callout(s, M, cy, cw, ch, 'Ce que Engage apporte', ['Collecte du consentement (composant de données ou procédure stockée).', 'Suivi d’ouverture conditionné au consentement, avec journal d’audit.', 'Activation sur simple demande, une fois le consentement collecté.'], { iconName: 'FiShield', fontSize: 10.5 });
    callout(s, M + cw + 0.25, cy, cw, ch, 'Où en êtes-vous ?', ['Consentement collecté pour les nouveaux contacts ?', 'Contacts existants informés, avec possibilité de refus ?', 'Suivi sous consentement activé dans Engage ?'], { iconName: 'FiHelpCircle', iconBg: C.teal2, fontSize: 10.5 });
    callout(s, M + 2 * (cw + 0.25), cy, cw, ch, 'Ce qui reste à faire', ['Validation formelle du DPO par typologie d’email.', 'Activation des seules catégories autorisées dans Engage.', 'Traitement des contacts existants restés hors consentement.'], { iconName: 'FiFlag', iconBg: C.orange, fill: C.orangeL, titleColor: C.orange, fontSize: 10.5 });
  }

  // ===== Au-delà du pixel d'ouverture : les prochaines exigences CNIL =====
  {
    const s = pres.addSlide();
    header(s, { section: 'CONFORMITÉ', title: 'Au-delà de l’ouverture : les prochaines exigences CNIL', subtitle: 'Le suivi des clics, la qualité du consentement et la preuve deviennent les prochains sujets à traiter.' });
    const cards = [
      { icon: 'FiTarget', title: 'Le clic aussi', items: ['La recommandation vise les pixels de mesure d’ouverture et de clic.', 'Des recommandations complémentaires sur le suivi des clics sont annoncées par la CNIL.'] },
      { icon: 'FiUserCheck', title: 'Un consentement distinct', items: ['Préalable, spécifique et séparé de l’inscription à la newsletter.', 'Le retrait doit être aussi simple que le recueil, sans parcours complexe.'] },
      { icon: 'FiFileText', title: 'La preuve et la durée', items: ['Documenter qui a consenti, à quoi et quand.', 'Fixer et respecter une durée de conservation des données de suivi.'] },
      { icon: 'FiLock', title: 'La sécurité en tête', items: ['La CNIL consacre la moitié de ses contrôles 2026 à la cybersécurité.', 'La logique 2026 : prouver la conformité, pas seulement la déclarer.'] },
    ];
    const n = cards.length, gap = 0.22, cw = (W - 2 * M - gap * (n - 1)) / n, y0 = 2.15, ch = 3.2;
    cards.forEach((c, i) => {
      const x = M + i * (cw + gap);
      card(s, x, y0, cw, ch, { shadow: true, line: null });
      iconCircle(s, x + 0.22, y0 + 0.22, 0.6, c.icon, { bg: C.teal, fg: C.white });
      txt(s, c.title, { x: x + 0.22, y: y0 + 0.95, w: cw - 0.44, h: 0.45, fontSize: 14, bold: true, color: C.teal, valign: 'middle' });
      hline(s, x + 0.22, y0 + 1.48, cw - 0.44);
      bullets(s, c.items, { x: x + 0.22, y: y0 + 1.6, w: cw - 0.44, h: ch - 1.75, fontSize: 10.5, gap: 6 });
    });
    const cy = y0 + ch + 0.3, ch2 = 6.8 - cy, cw2 = (W - 2 * M - 0.3) / 2;
    callout(s, M, cy, cw2, ch2, 'Ce qu’Engage permet déjà', ['Conditionner ouverture et clic au consentement recueilli, par typologie d’email.', 'Journal d’audit du consentement, étendu à l’historique des changements.'], { iconName: 'FiShield', fontSize: 11 });
    callout(s, M + cw2 + 0.3, cy, cw2, ch2, 'Ce que nous vous recommandons', ['Étendre dès maintenant la mécanique de consentement au suivi des clics.', 'Cadrer la durée de conservation des données de suivi avec votre DPO.'], { iconName: 'FiFlag', iconBg: C.orange, fill: C.orangeL, titleColor: C.orange, fontSize: 11 });
  }

  // ===== 15. Roadmap Engage =====
  {
    const s = pres.addSlide();
    header(s, { section: 'ENGAGE', title: 'Roadmap Engage : de la confiance opérationnelle à l’intelligence', subtitle: 'Les fondations de conformité et de contenu d’abord, l’authentification et les connecteurs ensuite, l’intelligence artificielle en fin de parcours.' });
    timeline(s, [
      { when: 'Aujourd’hui', icon: 'FiShield', title: 'Confiance', items: ['Désabonnement omnicanal et en-têtes email', 'Suivi d’ouverture sous consentement', 'Filtrage des interactions automatisées'] },
      { when: 'Q4 2026', icon: 'FiGrid', title: 'Contenus & canaux', items: ['Blocs de contenu publiés et prévisualisation', 'Groupes de test et seed lists', 'Canal RCS'] },
      { when: 'Q1 2027', icon: 'FiLock', title: 'Authentification', items: ['Nouveau système d’authentification SSO', 'Connexion unifiée et sécurisée'] },
      { when: 'Q2–Q3 2027', icon: 'FiShare2', title: 'Connecteurs & privacy', items: ['Bibliothèque de connecteurs (Snowflake, Salesforce, Dynamics)', 'Workflow RGPD automatisé', 'Modèles de segments et de parcours'] },
      { when: 'Q4 2027', icon: 'FiCpu', title: 'IA & Data', items: ['Interrogation des données en langage naturel', 'Analytique temps réel et recommandations'], last: true },
    ], { y: 2.95, cardH: 2.5 });
    txt(s, 'Trajectoire produit : les jalons peuvent être ajustés et ne constituent pas un engagement de livraison.', { x: M, y: 6.45, w: W - 2 * M, h: 0.35, fontSize: 11, color: C.muted, align: 'center', valign: 'middle' });
  }

  // ===== 16. Vos arbitrages =====
  {
    const s = pres.addSlide();
    header(s, { section: 'SYNTHÈSE', title: 'Vos arbitrages : cinq questions pour orienter la suite', subtitle: 'Vos réponses en séance alimentent directement le plan d’actions de la page suivante.' });
    const qs = [
      { icon: 'FiDatabase', topic: 'Base de données', q: 'Nettoyage et archivage d’abord, ou extension de 100 GB à 6 900 € par an ?' },
      { icon: 'FiUsers', topic: 'Licence', q: 'Quel volume de contacts prévoyez-vous en 2027, et votre palier de licence reste-t-il adapté ?' },
      { icon: 'FiMail', topic: 'Email', q: 'Quelles campagnes prioriser pour travailler le taux de clics ?' },
      { icon: 'FiSmartphone', topic: 'Mobile', q: 'Quelle ambition SMS et RCS en 2027 : le passe-plat LinkMobility suffit-il, ou faut-il une interface ?' },
      { icon: 'FiShield', topic: 'Conformité', q: 'Étendons-nous le consentement au suivi des clics, et quelles typologies d’emails en priorité ?' },
    ];
    const y0 = 2.15, rh = 0.8, gap = 0.12;
    qs.forEach((it, i) => {
      const y = y0 + i * (rh + gap);
      card(s, M, y, W - 2 * M, rh, { fill: i % 2 ? C.white : C.tealXL, line: i % 2 ? C.line : null });
      circle(s, M + 0.22, y + (rh - 0.46) / 2, 0.46, C.orange);
      txt(s, String(i + 1), { x: M + 0.22, y: y + (rh - 0.46) / 2, w: 0.46, h: 0.46, fontSize: 15, bold: true, color: C.white, align: 'center', valign: 'middle' });
      iconCircle(s, M + 0.85, y + (rh - 0.46) / 2, 0.46, it.icon, { bg: C.tealL, fg: C.teal });
      txt(s, it.topic, { x: M + 1.48, y, w: 1.9, h: rh, fontSize: 12.5, bold: true, color: C.teal, valign: 'middle' });
      txt(s, it.q, { x: M + 3.45, y, w: W - 2 * M - 3.7, h: rh, fontSize: 12.5, color: C.ink, valign: 'middle' });
    });
  }

  // ===== 17. Synthèse & prochaines étapes =====
  {
    const s = pres.addSlide();
    header(s, { section: 'SYNTHÈSE', title: 'Plan d’actions et prochaines étapes', subtitle: 'Dix actions, un responsable et une échéance pour chacune — à ajuster avec vos arbitrages.' });
    const hdr = ['Sujet', 'Action proposée', 'Qui', 'Quand (proposition)'];
    const rows = [
      ['SLA Gold', 'Suivi mensuel de la consommation dans votre reporting ; alerte dès 60 %.', 'Selligent', 'Mensuel'],
      ['Base de données Engage', 'Analyse de la répartition de la base, puis choix entre nettoyage et extension.', 'Viasanté + Selligent', 'Octobre 2026'],
      ['Extension 100 GB', 'Confirmation de la redevance de 6 900 € / an au-delà du seuil de 50 GB.', 'Selligent', 'Septembre 2026'],
      ['Licence', 'Palier de licence à confirmer au regard du volume de contacts prévu en 2027.', 'Viasanté + Selligent', 'T4 2026'],
      ['Navigation asynchrone', 'Redescente du patch de performance, puis confirmation du résultat.', 'Selligent', 'Septembre 2026'],
      ['Correctif SSO admin', 'Mise en production du correctif AdminTool / ConfigTool et clôture du sujet.', 'Selligent', 'Septembre 2026'],
      ['Email', 'Plan d’optimisation du taux de clics sur les campagnes prioritaires.', 'Viasanté (Marketing)', 'T4 2026'],
      ['SMS / RCS', 'Choix du connecteur RCS (LinkMobility ou Infobip) et plan d’usage 2027.', 'Viasanté (Marketing)', 'T4 2026'],
      ['Conformité CNIL', 'Extension du consentement au suivi des clics et validation DPO par typologie.', 'Viasanté (DPO) + Selligent', 'T4 2026'],
      ['SSO Engage', 'Point d’avancement produit et préparation de la bascule.', 'Selligent', 'T1 2027'],
    ];
    const widths = [1.9, 6.0, 2.35, 1.98];
    const tableRows = [hdr.map(h => ({ text: h, options: { bold: true, color: C.white, fill: { color: C.teal }, fontSize: 10.5, fontFace: FONT, valign: 'middle', margin: [3, 6, 3, 6] } }))]
      .concat(rows.map((r, i) => r.map((cell, j) => ({ text: cell, options: { fontSize: 10, fontFace: FONT, color: C.ink, bold: j === 0, fill: { color: i % 2 ? C.white : C.tealXL }, valign: 'middle', margin: [2, 6, 2, 6] } }))));
    s.addTable(tableRows, { x: M, y: 2.05, w: W - 2 * M, colW: widths, border: { type: 'solid', pt: 0.5, color: 'E1E8EB' }, rowH: 0.33 });
    callout(s, M, 6.1, W - 2 * M, 0.7, 'Prochain COPIL', 'Proposition : décembre 2026 — bilan des actions, point capacité base de données, préparation 2027.', { iconName: 'FiCalendar', iconBg: C.orange, fill: C.orangeL, titleColor: C.orange, fontSize: 11, inline: true, titleW: 1.5 });
  }

  // ===== 17. Merci =====
  {
    const s = pres.addSlide(); darkSlide(s);
    s.addShape('ellipse', { x: 9.4, y: 0.6, w: 5.6, h: 5.6, fill: { color: C.teal2, transparency: 55 }, line: { color: C.teal2, width: 0 } });
    s.addShape('ellipse', { x: 8.7, y: 4.4, w: 1.9, h: 1.9, fill: { color: C.orange, transparency: 15 }, line: { color: C.orange, width: 0 } });
    txt(s, 'Merci', { x: M, y: 1.9, w: 8, h: 1.0, fontSize: 54, bold: true, color: C.white, valign: 'middle' });
    txt(s, 'Vos interlocuteurs Selligent', { x: M, y: 3.0, w: 8, h: 0.4, fontSize: 14, bold: true, color: C.orange, charSpacing: 2 });
    txt(s, [
      { text: 'Nadir Echaara', options: { bold: true, breakLine: true } },
      { text: 'Customer Success Manager — relation, contrat, pilotage', options: { breakLine: true, paraSpaceAfter: 8 } },
      { text: 'Frederic Schneider', options: { bold: true, breakLine: true } },
      { text: 'Technical Project Manager — sujets techniques et projets' },
    ], { x: M, y: 3.45, w: 7.5, h: 1.5, fontSize: 14, color: 'E6F0F2' });
    txt(s, 'Comment nous joindre', { x: M, y: 5.1, w: 8, h: 0.4, fontSize: 14, bold: true, color: C.orange, charSpacing: 2 });
    txt(s, [
      { text: 'Support et incidents : ', options: { bold: true } }, { text: 'ticket via le portail support Selligent (Connect), suivi dans le rapport SLA.', options: { breakLine: true, paraSpaceAfter: 4 } },
      { text: 'Escalade : ', options: { bold: true } }, { text: 'Frederic Schneider pour la technique, Nadir Echaara pour la relation et le contrat.' },
    ], { x: M, y: 5.5, w: 7.8, h: 0.9, fontSize: 12, color: 'E6F0F2' });
    txt(s, 'Relevé de décisions transmis sous 48 heures.', { x: M, y: 6.55, w: 8, h: 0.35, fontSize: 12, italic: true, color: 'CFE3E7' });
  }

  await pres.writeFile({ fileName: OUT });
  console.log('written', OUT, 'slides:', pageNo);
})().catch(e => { console.error(e); process.exit(1); });
