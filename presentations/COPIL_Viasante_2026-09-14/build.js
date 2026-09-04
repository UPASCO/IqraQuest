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
  txt(slide, `COPIL Mutuelle Viasanté${NB}·${NB}${DATE_LONG}${NB}·${NB}Confidentiel`, { x: M, y: H - 0.42, w: 8, h: 0.25, fontSize: 8.5, color: C.muted, valign: 'middle' });
  txt(slide, String(pageNo), { x: W - M - 0.6, y: H - 0.42, w: 0.6, h: 0.25, fontSize: 8.5, color: C.muted, align: 'right', valign: 'middle' });
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
    s.addNotes('NOTE INTERNE — Ouverture : rappeler l’objectif du COPIL (état des lieux factuel de CDM et Engage, décisions à prendre ensemble, prochaines étapes). Durée cible : 45 min.');
  }

  // ===== 2. Ordre du jour =====
  {
    const s = pres.addSlide();
    header(s, { title: 'Ordre du jour', subtitle: 'Deux outils, deux séquences : votre CRM (CDM) puis votre plateforme marketing (Engage), et les actions à décider ensemble.' });
    const cols = [
      { n: '01', title: 'CDM — votre CRM', icon: 'FiDatabase', items: ['Consommation du SLA Gold 2026–2027', 'Capacité de la base de données', 'Audience unique et licence', 'Sécurisation de la configuration et patch du 10/09', 'Orientations roadmap CDM 2026–2027'] },
      { n: '02', title: 'Engage — votre plateforme marketing', icon: 'FiSend', items: ['Selligent by Zeta : ce qui change pour vous', 'Performance email vs secteur', 'Volumes SMS et option RCS', 'Nouveau SSO Engage : trajectoire', 'Pixel d’ouverture et recommandation CNIL', 'Roadmap Engage 2026–2027'] },
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
    s.addNotes('NOTE INTERNE — Annoncer la logique : d’abord le CRM (exploitation, capacité, sécurité, roadmap), puis Engage (performance, canaux, produit, conformité, roadmap), puis le plan d’actions. Demander s’il y a des sujets à ajouter avant de démarrer.');
  }

  // ===== 3. Vue d'ensemble =====
  {
    const s = pres.addSlide();
    header(s, { title: 'Votre dispositif Selligent en un coup d’œil', subtitle: 'Trois indicateurs de santé, trois indicateurs d’activité — le détail et les actions suivent dans chaque section.' });
    const rows = [
      { caption: 'SANTÉ DU DISPOSITIF', tiles: [
        { label: 'SLA Gold 2026–2027', value: `5,0${NB}h / 50${NB}h`, sub: `10${NB}% du forfait · 14 tickets traités · au 02/09`, iconName: 'FiClock', status: 'SOUS CONTRÔLE', statusFill: C.greenL, statusColor: C.green },
        { label: 'Base de données', value: `47 / 50${NB}GB`, sub: `94${NB}% de la capacité · +3${NB}GB en six mois · au 24/08`, iconName: 'FiDatabase', status: 'À ANTICIPER', statusFill: C.amberL, statusColor: C.amber },
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
    s.addNotes('NOTE INTERNE — Lecture rapide : exploitation saine (SLA, délivrabilité), deux points d’anticipation (capacité base, clics email), une vérification contractuelle (palier Ucount) et une question d’usage (SMS/RCS). Ne pas entrer dans le détail ici. Le taux d’ouverture inclut les interactions automatisées (bots) : préférer le taux de clics comme indicateur d’engagement.');
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
  divider('01', 'CDM — votre CRM', 'Exploitation, capacité, sécurité et trajectoire produit', ['SLA Gold : consommation et règle de décompte', 'Capacité de la base de données', 'Audience unique et licence', 'Sécurisation de la configuration et patch du 10/09', 'Orientations roadmap 2026–2027']);

  // ===== 5. SLA =====
  {
    const s = pres.addSlide();
    header(s, { section: 'CDM', title: 'Support : 5 h consommées sur 50, un rythme maîtrisé', subtitle: `SLA Gold, période du 1er juillet 2026 au 30 juin 2027 · 10${NB}% du forfait consommés pour 17${NB}% de la période écoulée · situation au ${SLA.asOf}.` });
    // gauge card
    card(s, M, 2.15, 3.6, 4.65, { shadow: true, line: null });
    txt(s, 'Heures décomptées du SLA', { x: M + 0.25, y: 2.35, w: 3.1, h: 0.3, fontSize: 11, bold: true, color: C.muted });
    s.addChart(pres.charts.DOUGHNUT, [{ name: 'SLA', labels: ['Consommé', 'Disponible'], values: [SLA.caseTime, SLA.total - SLA.caseTime] }], {
      x: M + 0.35, y: 2.7, w: 2.9, h: 2.9, holeSize: 68, chartColors: [C.orange, 'DDE6E9'], showLegend: false, showValue: false, showLabel: false, showPercent: false, dataBorder: { pt: 0, color: C.white },
    });
    txt(s, `10${NB}%`, { x: M + 0.35, y: 3.7, w: 2.9, h: 0.6, fontSize: 30, bold: true, color: C.teal, align: 'center', valign: 'middle' });
    txt(s, `5,0${NB}h sur 50${NB}h`, { x: M + 0.35, y: 4.28, w: 2.9, h: 0.3, fontSize: 11, color: C.muted, align: 'center' });
    txt(s, [{ text: `45,0${NB}h `, options: { bold: true, color: C.teal } }, { text: 'restent disponibles jusqu’au 30 juin 2027', options: { breakLine: true } }, { text: `8,5${NB}h `, options: { bold: true, color: C.teal } }, { text: 'd’anomalies et de questions traitées hors forfait' }], { x: M + 0.25, y: 5.7, w: 3.1, h: 0.95, fontSize: 11, color: C.ink, align: 'center', valign: 'middle', paraSpaceAfter: 4 });
    // category bars card
    const bx = M + 3.9, bw = 5.2;
    card(s, bx, 2.15, bw, 4.65, { shadow: true, line: null });
    txt(s, `Temps de support par catégorie — 17,9${NB}h au total`, { x: bx + 0.25, y: 2.35, w: bw - 0.5, h: 0.3, fontSize: 11, bold: true, color: C.muted });
    const maxH = 6, barX = bx + 0.25, barW = bw - 1.5, rowY = 2.85, rowH = 0.72;
    SLA.cats.forEach((c, i) => {
      const y = rowY + i * rowH;
      txt(s, [{ text: c.name, options: { bold: true } }, { text: `  ·  ${c.n} ticket${c.n > 1 ? 's' : ''}`, options: { color: C.muted } }], { x: barX, y, w: barW + 1.0, h: 0.26, fontSize: 10.5, valign: 'middle' });
      rect(s, barX, y + 0.3, barW, 0.22, { fill: 'EEF3F5', radius: 0.05 });
      rect(s, barX, y + 0.3, Math.max(0.08, barW * c.h / maxH), 0.22, { fill: c.counted ? C.orange : C.teal3, radius: 0.05 });
      txt(s, `${fr(c.h, 1)}${NB}h`, { x: barX + barW + 0.1, y: y + 0.26, w: 0.9, h: 0.3, fontSize: 11, bold: true, color: c.counted ? C.orange : C.teal, valign: 'middle' });
    });
    // legend
    rect(s, barX, 5.85, 0.18, 0.18, { fill: C.orange, radius: 0.03 });
    txt(s, 'Décompté du SLA', { x: barX + 0.25, y: 5.8, w: 1.8, h: 0.28, fontSize: 9.5, color: C.ink, valign: 'middle' });
    rect(s, barX + 2.1, 5.85, 0.18, 0.18, { fill: C.teal3, radius: 0.03 });
    txt(s, 'Non décompté (pris en charge par Selligent)', { x: barX + 2.35, y: 5.8, w: 2.8, h: 0.28, fontSize: 9.5, color: C.ink, valign: 'middle' });
    txt(s, `Temps de support par mois (tickets actifs) : juillet 7,1${NB}h (9) · août 10,1${NB}h (8) · septembre 0,7${NB}h (2, au 02/09)`, { x: barX + 0.25, y: 6.25, w: bw - 0.5, h: 0.4, fontSize: 9.5, color: C.muted, valign: 'middle' });
    // rule callout
    const cx = bx + bw + 0.3, cw = W - M - cx;
    callout(s, cx, 2.15, cw, 2.55, 'Règle de décompte', ['Seules les heures qualifiées « Case » (demandes de service) sont décomptées des 50 h.', 'Anomalies produit, questions et suivi sont pris en charge par Selligent, hors forfait.', 'Suivi partagé chaque mois avec le rapport SLA.'], { iconName: 'FiInfo', fontSize: 10.5 });
    callout(s, cx, 4.85, cw, 1.95, 'Ce que nous proposons', ['Point SLA mensuel dans le reporting CSM.', 'Alerte proactive dès 60 % de consommation.'], { iconName: 'FiCheckCircle', iconBg: C.green, fill: C.greenL, titleColor: C.green, fontSize: 10.5 });
    s.addNotes(`NOTE INTERNE — Source : extract SLA Gold 01/07/2026–30/06/2027 mis à jour le 03/09/2026 (33 lignes, 14 tickets, activité du 01/07 au 02/09). Temps support total 17,87 h ; temps « Case » 5,02 h = 10,0 % des 50 h ; 17 % de la période écoulée (64 jours sur 365). 12,9 h (anomalies 5,58 h + questions 2,92 h + non catégorisé 4,35 h) assurées hors forfait. Le décompte suit la logique du dashboard BI (% SLA Use = Case Time / 50) : règle déduite des données, à confirmer avec le support avant la séance.\nÀ FAIRE AVANT LE 14/09 : (1) trancher la période de référence — le dashboard BI « SLA Support Follow-up » affiche une période 24/02/2026–23/02/2027 avec 36,67 h de support et 7,92 h de Case Time (15,83 %) ; si cette période est la bonne, la jauge devient 7,9 h / 50 h (16 %) ; (2) faire qualifier les 4 tickets « None » (4,35 h, dont le 550647 = 4,17 h, encore actif le 31/08) : requalifiés en « Case », la consommation passerait à ≈ 19 %.\nTickets les plus consommateurs : 550647 (4,17 h, non catégorisé), 550586 (Case, 3,75 h, 03→30/07), 550263 (anomalie, 2,92 h, 01/07→05/08), 551396 (question, 2,08 h), 551314 (anomalie, 1,67 h). Consultant support référent : Pierre Foucart.`);
  }

  // ===== 6. Base de données =====
  {
    const s = pres.addSlide();
    header(s, { section: 'CDM', title: 'Base de données : 47 GB sur 50, anticipons ensemble', subtitle: '+3 GB en six mois, par paliers, et un plateau à 47 GB depuis juin : 3 GB de marge, soit environ six mois si le rythme du premier semestre reprend.' });
    // chart card
    card(s, M, 2.15, 7.4, 4.65, { shadow: true, line: null });
    txt(s, 'Taille de la base de données (GB, moyenne mensuelle) — mars à août 2026', { x: M + 0.25, y: 2.3, w: 6.9, h: 0.3, fontSize: 11, bold: true, color: C.muted });
    s.addChart([
      { type: pres.charts.BAR, data: [{ name: 'Taille (GB)', labels: DB.labels, values: DB.values }], options: { chartColors: [C.teal3], barGapWidthPct: 60 } },
      { type: pres.charts.LINE, data: [{ name: 'Seuil 50 GB', labels: DB.labels, values: DB.labels.map(() => DB.limit) }], options: { chartColors: [C.orange], lineSize: 2, lineDataSymbol: 'none', lineDash: 'dash', showValue: false } },
    ], {
      x: M + 0.2, y: 2.65, w: 7.0, h: 3.7, valAxisMinVal: 0, valAxisMaxVal: 55, valAxisMajorUnit: 10,
      showValue: true, dataLabelPosition: 'outEnd', dataLabelFontSize: 10, dataLabelColor: C.teal, dataLabelFormatCode: '0.0',
      catAxisLabelColor: C.muted, valAxisLabelColor: C.muted, catAxisLabelFontSize: 10, valAxisLabelFontSize: 10,
      valGridLine: { color: 'E6ECEF', size: 0.5 }, catGridLine: { style: 'none' }, showLegend: true, legendPos: 'b', legendFontSize: 10, legendColor: C.muted,
    });
    txt(s, 'Source : dashboard Database Sizes, données au 24/08/2026 — valeurs lues sur le graphique, arrondies.', { x: M + 0.25, y: 6.42, w: 6.9, h: 0.3, fontSize: 8.5, color: C.muted, italic: true });
    // right column
    const rx = M + 7.7, rw = W - M - rx;
    kpi(s, rx, 2.15, rw, 1.75, { label: 'Marge restante', value: `3${NB}GB (6${NB}%)`, sub: 'sur un seuil de 50 GB · plateau à 47 GB depuis juin', iconName: 'FiHardDrive', valueSize: 24 });
    callout(s, rx, 4.05, rw, 2.75, 'Deux options à étudier ensemble', ['Optimiser : analyse de la répartition de la base, puis purge ou archivage des données obsolètes (historiques, journaux, imports temporaires) — proposition : audit conjoint en octobre.', 'Étendre : augmentation de capacité par palier de 100 GB, sur devis — à décider avant d’approcher le seuil.'], { iconName: 'FiTool', fontSize: 10.5 });
    s.addNotes('NOTE INTERNE — Source : dashboard Database Sizes (24/08/2026) — ≈ 43,9 GB jusqu’au 20/03, ≈ 44,9 GB à partir du 21/03, ≈ 46,0 GB à partir du 13/05, ≈ 46,9 GB depuis le 06/06 puis plateau. Seuil affiché 50 GB. La date de dépassement n’est qu’une extrapolation : la présenter au conditionnel.\nPRIX : la pricelist indicative de 6 900 €/an par tranche de 100 GB n’est pas vérifiée (devis Deal Desk requis) — ne pas l’annoncer ; la slide dit « sur devis ». Préciser en séance ce qui se passe au-delà du seuil (délai, procédure) une fois confirmé avec le TPM.\nProposer de trancher au COPIL : audit de nettoyage d’abord (octobre), décision d’extension en novembre si nécessaire.');
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
    txt(s, 'Source : dashboard Compliance Count, licence Ucount · Tier Gold, données au 24/08/2026.', { x: M + 0.25, y: 6.42, w: 7.4, h: 0.3, fontSize: 8.5, color: C.muted, italic: true });
    const rx = M + 8.2, rw = W - M - rx;
    kpi(s, rx, 2.15, rw, 1.45, { label: 'Août 2026', value: fr(824913), sub: `+0,6${NB}% vs juillet (+${fr(4874)}) · +20,2${NB}% sur un an`, iconName: 'FiUsers', valueSize: 24 });
    kpi(s, rx, 3.75, rw, 1.45, { label: 'Depuis juin 2025', value: `+17,5${NB}%`, sub: `≈${NB}+8${NB}800 contacts par mois · en ralentissement`, iconName: 'FiTrendingUp', valueSize: 24 });
    callout(s, rx, 5.35, rw, 1.45, 'Licence', 'Nous vérifions que votre palier de licence reste adapté à cette croissance — retour formel d’ici fin septembre, aucune action de votre côté.', { iconName: 'FiFileText', fontSize: 10.5 });
    s.addNotes('NOTE INTERNE — Source : Compliance Count (calcul du 16/08/2026, données au 24/08). Juin 2025 : 701 932 → août 2026 : 824 913 (+122 981, soit +17,5 % ; ≈ +8 800/mois). Juillet 2026 : 820 039 → août : +4 874 (+0,6 %). Août 2025 : 686 466 → août 2026 : +20,2 % sur un an. La croissance mensuelle ralentit (+4,9 k en août contre ≈ +15 k fin 2025).\nFormuler le sujet licence comme une vérification contractuelle du palier Ucount (licence Gold), jamais comme un incident. Aucune source ne donne le palier contracté : ne pas parler de dépassement. Si la position n’est pas connue le 14/09, s’en tenir à « retour formel d’ici fin septembre ».\nQuestion à poser au client : cette croissance correspond-elle à son plan (adhérents, prospects) ?');
  }

  // ===== 8. Sécurisation & patch =====
  {
    const s = pres.addSlide();
    header(s, { section: 'CDM', title: 'Sécurisation de la configuration et patch du 10 septembre', subtitle: 'Deux interventions techniques menées par Selligent, sans changement d’usage pour vos équipes.' });
    // timeline
    const steps = [
      { date: '31 août 2026', title: 'Sécurisation de la configuration', body: 'Solution communiquée et mise en œuvre sur les accès SSO, AdminTool et ConfigTool.', status: 'LIVRÉ', fill: C.greenL, color: C.green, icon: 'FiShield' },
      { date: '10 septembre 2026', title: 'Patch asynchrone CDM', body: 'Déploiement du correctif sur les traitements asynchrones (redescente planifiée).', status: 'DÉPLOYÉ — EN OBSERVATION', fill: C.amberL, color: C.amber, icon: 'FiSettings' },
      { date: '14 septembre 2026', title: 'Bilan post-patch', body: 'Vérification conjointe : traitements nominaux, aucun impact opérationnel constaté.', status: 'CE JOUR', fill: C.tealL, color: C.teal, icon: 'FiCheckCircle' },
    ];
    const tx = M, tw = W - 2 * M, sw = (tw - 0.6) / 3, ty = 2.25;
    hline(s, tx + sw / 2, ty + 0.35, tw - sw, C.line, 2);
    steps.forEach((st, i) => {
      const x = tx + i * (sw + 0.3);
      iconCircle(s, x + sw / 2 - 0.35, ty, 0.7, st.icon, { bg: C.teal, fg: C.white });
      txt(s, st.date, { x, y: ty + 0.85, w: sw, h: 0.3, fontSize: 11, bold: true, color: C.orange, align: 'center' });
      card(s, x, ty + 1.25, sw, 2.2, { shadow: true, line: null });
      txt(s, st.title, { x: x + 0.25, y: ty + 1.4, w: sw - 0.5, h: 0.4, fontSize: 13.5, bold: true, color: C.teal, valign: 'middle' });
      txt(s, st.body, { x: x + 0.25, y: ty + 1.85, w: sw - 0.5, h: 0.9, fontSize: 11, color: C.ink });
      pill(s, x + 0.25, ty + 2.95, Math.min(sw - 0.5, 2.6), 0.3, st.status, { fill: st.fill, color: st.color });
    });
    const cy = 5.85;
    callout(s, M, cy, (tw - 0.3) / 2, 0.95, 'Périmètre', 'Accès d’administration CDM (SSO technique, AdminTool, ConfigTool) et traitements asynchrones.', { iconName: 'FiLock', fontSize: 10.5, inline: true });
    callout(s, M + (tw - 0.3) / 2 + 0.3, cy, (tw - 0.3) / 2, 0.95, 'Pour vos équipes', 'Aucune action attendue de votre côté ; accès d’administration mieux sécurisés, bilan d’impact partagé ce jour.', { iconName: 'FiUsers', iconBg: C.green, fill: C.greenL, titleColor: C.green, fontSize: 10.5, inline: true });
    s.addNotes('NOTE INTERNE — À METTRE À JOUR AVANT LA SÉANCE (avec Frederic Schneider / Ops, le 11/09 au plus tard) : résultat du patch du 10/09 (statut, éventuels effets de bord) → ajuster la pastille « Déployé — en observation » (→ « Validé » ou « Reporté au … ») et la phrase du bilan ; préparer les deux variantes. Rappeler en une phrase pourquoi la sécurisation a été menée (contexte de la demande du 31/08) si le client le demande.\nLes éléments 31/08 et 10/09 proviennent du suivi CSM : les confirmer avec le TPM. Sujet strictement technique CDM : ne pas le mêler au futur SSO produit Engage (slide dédiée) ni aux sujets de licence.');
  }

  // ===== 9. Roadmap CDM =====
  {
    const s = pres.addSlide();
    header(s, { section: 'CDM', title: 'Roadmap CDM 2026–2027 : cinq axes d’évolution', subtitle: 'De l’ergonomie et de la qualité de donnée vers l’automatisation et l’intelligence artificielle — orientations produit, non contractuelles.' });
    const axes = [
      { icon: 'FiGrid', title: 'Expérience utilisateur', obj: 'Simplifier l’interface pour favoriser l’adoption', items: ['Vues intuitives et personnalisables (glisser-déposer, thèmes)', 'Navigation simplifiée vers les fonctions clés', 'Meilleure intégration contacts, opportunités, incidents'] },
      { icon: 'FiLayers', title: 'Vue client 360°', obj: 'Une fiche unique, des données consolidées', items: ['Historique, interactions, incidents, opportunités réunis', 'Synchronisation messagerie, réseaux sociaux, ERP', 'Dédoublonnage centralisé et validation automatique'] },
      { icon: 'FiZap', title: 'Automatisation & IA', obj: 'Réduire les tâches répétitives', items: ['Workflows de relance, rappels, gestion d’incidents', 'Suggestions d’actions et priorisation par IA', 'Aide à la rédaction de comptes rendus, auto-complétion, recherche intelligente'] },
      { icon: 'FiBarChart2', title: 'Analytique avancée', obj: 'Mieux décider grâce aux insights', items: ['Tableaux de bord ventes et service client', 'Rapports prédictifs (tendances, opportunités)', 'Segmentation dynamique'] },
      { icon: 'FiShare2', title: 'Collaboration & mobilité', obj: 'Travailler efficacement, même à distance', items: ['Partage temps réel et commentaires sur les fiches', 'Application mobile complète', 'Chat et visio intégrés au CRM'] },
    ];
    const n = axes.length, gap = 0.22, cw = (W - 2 * M - gap * (n - 1)) / n, y0 = 2.15, ch = 4.3;
    axes.forEach((a, i) => {
      const x = M + i * (cw + gap);
      card(s, x, y0, cw, ch, { shadow: true, line: null });
      iconCircle(s, x + 0.22, y0 + 0.22, 0.6, a.icon, { bg: C.teal, fg: C.white });
      txt(s, String(i + 1).padStart(2, '0'), { x: x + cw - 0.8, y: y0 + 0.2, w: 0.6, h: 0.6, fontSize: 22, bold: true, color: C.orange, align: 'right', valign: 'middle' });
      txt(s, a.title, { x: x + 0.22, y: y0 + 0.95, w: cw - 0.44, h: 0.45, fontSize: 13.5, bold: true, color: C.teal, valign: 'middle' });
      txt(s, a.obj, { x: x + 0.22, y: y0 + 1.42, w: cw - 0.44, h: 0.6, fontSize: 10.5, italic: true, color: C.muted });
      hline(s, x + 0.22, y0 + 2.08, cw - 0.44);
      bullets(s, a.items, { x: x + 0.22, y: y0 + 2.2, w: cw - 0.44, h: ch - 2.3, fontSize: 10, gap: 5 });
    });
    txt(s, 'Orientations produit : les évolutions et leur calendrier peuvent être ajustés ; elles ne constituent pas un engagement de livraison. Quels axes sont prioritaires pour vous ?', { x: M, y: 6.6, w: W - 2 * M, h: 0.3, fontSize: 8.5, italic: true, color: C.muted });
    s.addNotes('NOTE INTERNE — Source : deck « CDM Roadmap 2026–2027 » (5 axes, sans jalon trimestriel : ne pas annoncer de dates par axe ; les trimestres du deck précédent étaient inventés). Présenter la séquence logique : adoption et qualité de donnée d’abord, IA ensuite. Mettre en avant les deux axes les plus utiles à Viasanté (vue 360° et dédoublonnage — lien avec la volumétrie ; automatisation des relances) et demander au client ses priorités. Proposer une session roadmap dédiée avec le Product Management.');
  }

  // ===== 10. Intercalaire Engage =====
  divider('02', 'Engage — votre plateforme marketing', 'Continuité, performance, canaux, produit et conformité', ['Selligent by Zeta : ce qui change, ce qui ne change pas', 'Performance email vs secteur', 'Volumes SMS et option RCS', 'Nouveau SSO Engage : trajectoire', 'Pixel d’ouverture et recommandation CNIL', 'Roadmap Engage 2026–2027']);

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
    txt(s, 'Orientations communiquées par Selligent by Zeta en juin 2026.', { x: M, y: 6.5, w: W - 2 * M, h: 0.3, fontSize: 8.5, italic: true, color: C.muted });
    s.addNotes('NOTE INTERNE — Source : session roadmap interne juin 2026 (réponses recommandées aux questions clients) : investissement continu (équipes produit / ingénierie principalement en Belgique, étendues par des équipes dédiées IA et Data) ; aucune stratégie de migration forcée, priorité à la valeur de l’investissement actuel ; pour les clients Selligent seuls, aucune obligation de passer à une nouvelle tarification au renouvellement ; pas de changement immédiat sur les modules existants ; stratégie produit fondée sur l’analyse du marché européen et les retours clients ; RGPD, vie privée et réglementation européenne restent une priorité. Questions probables : avenir de Selligent, décisions prises depuis les États-Unis, données hors UE, tarifs — répondre avec ces éléments, sans entrer dans la stratégie Zeta / ZMP.');
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
    txt(s, 'Source : Deliverability Report, données au 23/08/2026 · interactions totales, y compris automatisées (bots) — vue « hors bots » disponible sur demande.', { x: M + 0.25, y: cy + chH - 0.32, w: 6.1, h: 0.25, fontSize: 8.5, italic: true, color: C.muted, valign: 'middle' });
    const rx = M + 6.9, rw = W - M - rx;
    callout(s, rx, cy, rw, 1.45, 'Ce que disent les chiffres', ['99,4 % délivrés et près d’un email sur deux ouvert : la chaîne technique délivre.', 'Le clic est en retrait : 1,9 % contre 3,1 % pour le secteur — contenus et appels à l’action sont le levier 2027.'], { iconName: 'FiEye', fontSize: 10.5 });
    callout(s, rx, cy + 1.6, rw, chH - 1.6, 'Proposition', ['Atelier d’optimisation en octobre sur trois campagnes prioritaires : contenus, appels à l’action, ciblage, scénarios.', 'Objectif partagé : rapprocher votre taux de clics du niveau du secteur.'], { iconName: 'FiTarget', iconBg: C.orange, fill: C.orangeL, titleColor: C.orange, fontSize: 10.5 });
    s.addNotes('NOTE INTERNE — Source : Deliverability Report – Client vs Industry (25/02/2026 → 23/08/2026, secteur « Professional Services », 48 installs, mode « All interactions »). DR 99,37 % (secteur 98,72 %), VR 46,67 % (27,25 %), CTO 4,08 % (11,20 %), CTR 1,91 % (3,05 %), Unsub 0,30 % (0,20 %). 1 545 190 emails délivrés.\nLe taux d’ouverture inclut les ouvertures automatiques (Apple MPP, bots) et gonfle mécaniquement la VR tout en écrasant le CTO : si possible, re-tirer le rapport en mode « Non bot interactions » avant la séance ; sinon, s’en tenir au message CTR (−1,1 pt vs secteur). Le secteur « Professional Services » n’est pas une mutuelle santé : présenter le panel comme une référence indicative.\nLe taux de désabonnement légèrement supérieur au secteur (0,30 % vs 0,20 %) se traite dans le même atelier (pression marketing, pertinence). Volumes mensuels (dashboard Timeline Interactions, lecture graphique) : montée en charge de mars à juin (≈ 0,16 M → 0,47 M), juillet ≈ 0,40 M ; le CTO et le CTR reviennent vers le niveau du secteur en juillet–août.');
  }

  // ===== 12. SMS & RCS =====
  {
    const s = pres.addSlide();
    header(s, { section: 'ENGAGE', title: 'SMS et RCS : quelle place pour le mobile en 2027 ?', subtitle: `Près de 0,5${NB}million de SMS délivrés depuis août 2023 · ≈${NB}20–26${NB}k par mois jusqu’en mai 2025, ≈${NB}2–3${NB}k par mois depuis juin 2025.` });
    card(s, M, 2.15, 7.6, 4.65, { shadow: true, line: null });
    txt(s, 'SMS délivrés par mois (milliers) — août 2023 à août 2026', { x: M + 0.25, y: 2.3, w: 7.1, h: 0.3, fontSize: 11, bold: true, color: C.muted });
    const labels = SMS.values.map((_, i) => { const m = (SMS.start[1] - 1 + i) % 12, y = SMS.start[0] + Math.floor((SMS.start[1] - 1 + i) / 12); return (m === 0 || m === 6) ? `${MOIS[m]} ${String(y).slice(2)}` : ''; });
    s.addChart(pres.charts.BAR, [{ name: 'SMS délivrés (k)', labels, values: SMS.values }], {
      x: M + 0.2, y: 2.65, w: 7.2, h: 3.7, barDir: 'col', barGapWidthPct: 35, chartColors: [C.teal3],
      valAxisMinVal: 0, valAxisMaxVal: 35, valAxisMajorUnit: 5, valAxisLabelFontSize: 9, catAxisLabelFontSize: 9, catAxisLabelColor: C.muted, valAxisLabelColor: C.muted,
      valGridLine: { color: 'E6ECEF', size: 0.5 }, catGridLine: { style: 'none' }, showLegend: false, showValue: false,
    });
    txt(s, 'Source : dashboard SMS Deliveries, données au 23/08/2026 — valeurs mensuelles arrondies.', { x: M + 0.25, y: 6.42, w: 7.1, h: 0.3, fontSize: 8.5, color: C.muted, italic: true });
    const rx = M + 7.9, rw = W - M - rx;
    txt(s, 'Passer au RCS : deux options', { x: rx, y: 2.15, w: rw, h: 0.3, fontSize: 13, bold: true, color: C.teal, valign: 'middle' });
    const oh = 1.55, o1 = 2.55, o2 = o1 + oh + 0.15;
    card(s, rx, o1, rw, oh, { shadow: true, line: null });
    iconCircle(s, rx + 0.2, o1 + 0.17, 0.42, 'FiZap', { bg: C.teal, fg: C.white });
    txt(s, 'LinkMobility — connecteur natif', { x: rx + 0.75, y: o1 + 0.15, w: rw - 0.95, h: 0.45, fontSize: 12, bold: true, color: C.teal, valign: 'middle' });
    bullets(s, ['Connecteur prêt, intégration par API (plus de SFTP)', 'Sans interface dédiée ni prévisualisation', 'Mise en œuvre rapide, simple et efficace'], { x: rx + 0.25, y: o1 + 0.68, w: rw - 0.5, h: oh - 0.75, fontSize: 10.5, gap: 3 });
    card(s, rx, o2, rw, oh, { shadow: true, line: null });
    iconCircle(s, rx + 0.2, o2 + 0.17, 0.42, 'FiSmartphone', { bg: C.teal, fg: C.white });
    txt(s, 'Infobip — expérience enrichie', { x: rx + 0.75, y: o2 + 0.15, w: rw - 0.95, h: 0.45, fontSize: 12, bold: true, color: C.teal, valign: 'middle' });
    bullets(s, ['Interface de conception et prévisualisation', 'Orchestration plus riche pour le marketing', 'Adapté à une ambition RCS plus large'], { x: rx + 0.25, y: o2 + 0.68, w: rw - 0.5, h: oh - 0.75, fontSize: 10.5, gap: 3 });
    const o3 = o2 + oh + 0.15;
    callout(s, rx, o3, rw, 6.8 - o3, 'À décider ensemble', 'Quel niveau d’expérience RCS vos équipes attendent-elles : industrialisation rapide ou orchestration riche ?', { iconName: 'FiHelpCircle', iconBg: C.orange, fill: C.orangeL, titleColor: C.orange, fontSize: 10.5, inline: true, titleW: 1.35 });
    s.addNotes('NOTE INTERNE — Source : dashboard SMS Deliveries (23/08/2026) : ≈ 0,50 M de SMS délivrés au total sur la période affichée (août 2023 → août 2026) ; ≈ 20–26 k/mois de septembre 2023 à mai 2025 (pic ≈ 30 k en juillet 2024, creux ≈ 7,5 k en février 2024) ; ≈ 2–3 k/mois depuis juin 2025 ; août 2026 ≈ 6 k (mois partiel au 23/08). Valeurs lues sur le graphique, arrondies.\nÀ FAIRE AVANT LE 14/09 : connaître la raison de la baisse depuis juin 2025 (changement de prestataire, arrêt d’un usage, budget) et l’énoncer en séance ; sinon poser la question au client plutôt que de laisser lire « vous abandonnez le canal ». Relier le RCS à des cas d’usage mutuelle (rappels, relances d’adhésion, transactionnel).\nRCS LinkMobility : connecteur prêt / live selon retour opérationnel, API (plus de SFTP), pas d’UI ni de preview. Infobip : UI + preview. Confirmer avec Product / Delivery que les deux options sont bien supportées pour Viasanté avant de les nommer. Faire exprimer le besoin réel avant d’orienter ; rapprocher le volume SMS du budget et du plan d’usage 2026–2027.');
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
    callout(s, M + cw + 0.3, cy, cw, ch, 'Ce qui ne change pas', ['Aucune bascule avant la fenêtre cible du 1er trimestre 2027.', 'Sujet distinct de la sécurisation technique des accès CDM réalisée le 31 août.'], { iconName: 'FiInfo', fontSize: 10.5 });
    txt(s, 'Trajectoire produit indicative, susceptible d’évoluer ; ne constitue pas un engagement de disponibilité.', { x: M, y: 6.9, w: W - 2 * M, h: 0.25, fontSize: 8.5, italic: true, color: C.muted });
    s.addNotes('NOTE INTERNE — Message à tenir : le nouveau SSO Engage est sur la trajectoire produit avec une fenêtre cible T1 2027 — aucune promesse de disponibilité antérieure, aucune autre date (les étapes intermédiaires ne sont pas sourcées). Ne pas confondre avec le sujet technique CDM (SSO / AdminTool / ConfigTool) traité le 31/08.\nPoint à clarifier avec Product avant la séance : la roadmap de juin 2026 liste un « Zeta login » (connexion unique à l’écosystème Zeta) comme disponible ; préciser si le besoin de Viasanté est ce login Zeta ou une fédération SSO avec leur annuaire d’entreprise (SAML), et si la fenêtre T1 2027 porte bien sur ce dernier. Le login Zeta est volontairement absent de la roadmap présentée pour éviter la contradiction.');
  }

  // ===== 14. Pixel d'ouverture =====
  {
    const s = pres.addSlide();
    header(s, { section: 'CONFORMITÉ', title: 'Pixel d’ouverture : un suivi conforme à la recommandation CNIL', subtitle: 'Recommandation finale du 14 avril 2026, période transitoire close le 14 juillet · Engage sait déjà tracer les ouvertures sous consentement.' });
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
    callout(s, M + 2 * (cw + 0.25), cy, cw, ch, 'Prochaine étape proposée', ['Atelier DPO Viasanté × Selligent en octobre : cartographie des cas d’usage, décision par typologie.', 'Activation progressive dans Engage à l’issue de la validation.'], { iconName: 'FiCalendar', iconBg: C.orange, fill: C.orangeL, titleColor: C.orange, fontSize: 10.5 });
    s.addNotes('NOTE INTERNE — Cadre vérifié : délibération CNIL n° 2026-042 du 12/03/2026, recommandation finale publiée le 14/04/2026 (cnil.fr/fr/recommandation-pixel-suivi-courriels). Les pixels invisibles relèvent du même régime que les cookies : consentement préalable pour la plupart des usages ; exemption pour la seule mesure individuelle de délivrabilité liée à un service demandé (ex. identifier les adresses inactives). Pour les adresses existantes, période transitoire de trois mois avec information claire et possibilité de refus, close le 14/07/2026.\nEngage « Consent-based open tracking » : livré = collecte du consentement (Data Component / stored procedures), tracking d’ouverture basé sur le consentement, journal d’audit basique ; à venir = support Data Importer, tracking basé sur exemption, historique d’audit étendu. Activation via ticket Connect après collecte du consentement ; revoir la stratégie pour les contacts existants.\nÀ FAIRE AVANT LE 14/09 : connaître le statut réel de Viasanté (tracking activé ? consentement collecté ? contacts existants informés avant le 14/07 ?) pour répondre aux trois questions de la slide, ou les poser en séance. Traiter le sujet en gouvernance / conformité : validation DPO formelle avant activation ou généralisation.');
  }

  // ===== 15. Roadmap Engage =====
  {
    const s = pres.addSlide();
    header(s, { section: 'ENGAGE', title: 'Roadmap Engage 2026–2027 : des fondations à l’intelligence', subtitle: 'Selligent by Zeta — ce qui est disponible, ce qui arrive, ce qui suivra. Roadmap directionnelle, sans engagement de livraison.' });
    const cols = [
      { tag: 'DISPONIBLE', fill: C.green, items: [
        ['Filtrage des interactions automatisées (bots)', 'des indicateurs fondés sur les vrais comportements'],
        ['Suivi d’ouverture fondé sur le consentement', 'conforme à la recommandation CNIL'],
        ['Désabonnement omnicanal', 'gestion centralisée des préférences'],
        ['Blocs de contenu, prévisualisation et groupes de test', 'accélérer et sécuriser chaque envoi'],
        ['Canal RCS', 'messages mobiles riches et interactifs'],
        ['Signaux temps réel', 'transmettre les interactions à vos systèmes'],
        ['Bibliothèque de connecteurs', 'Snowflake, Shopify, Salesforce, Dynamics…'],
      ] },
      { tag: 'À VENIR', fill: C.teal2, items: [
        ['Workflow privacy automatisé', 'traitement des demandes RGPD'],
        ['QuickStart Library', 'modèles de segments, contenus et parcours'],
        ['Ask Your Data', 'interroger vos données en langage naturel'],
        ['Analytique temps réel', 'comportements, campagnes, revenus'],
        ['WhatsApp et Interactive Moments', 'options complémentaires, sur devis'],
      ] },
      { tag: 'PLUS TARD', fill: C.teal3, items: [
        ['Vue client enrichie', 'vue unique temps réel et segmentation relationnelle'],
        ['Blocs de contenu simplifiés', 'blocs réutilisables sans compétence technique'],
        ['Audience Composition', 'comprendre les étapes du cycle de vie'],
        ['Performance Advisor', 'recommandations pour optimiser l’impact'],
      ] },
    ];
    const n = 3, gap = 0.3, cw = (W - 2 * M - gap * (n - 1)) / n, y0 = 2.15, ch = 4.35;
    cols.forEach((c, i) => {
      const x = M + i * (cw + gap);
      card(s, x, y0, cw, ch, { shadow: true, line: null });
      pill(s, x + 0.25, y0 + 0.22, 1.5, 0.32, c.tag, { fill: c.fill, color: C.white, fontSize: 9.5 });
      const runs = [];
      c.items.forEach(([t, d], j) => {
        runs.push({ text: t, options: { bold: true, color: C.teal, breakLine: true, paraSpaceAfter: 0 } });
        runs.push({ text: d, options: { color: C.muted, breakLine: j < c.items.length - 1, paraSpaceAfter: 9 } });
      });
      txt(s, runs, { x: x + 0.25, y: y0 + 0.72, w: cw - 0.5, h: ch - 0.85, fontSize: 11, valign: 'top' });
    });
    txt(s, 'Cette roadmap contient des éléments prospectifs susceptibles d’évoluer ; elle ne constitue ni une garantie ni un engagement de livraison de fonctionnalités. Le SSO Engage suit sa propre trajectoire (fenêtre cible T1 2027).', { x: M, y: 6.6, w: W - 2 * M, h: 0.3, fontSize: 8.5, italic: true, color: C.muted });
    s.addNotes('NOTE INTERNE — Source : roadmap Selligent by Zeta (session interne juin 2026) — statuts vérifiés sur la slide « Where we’re heading » : Now = Real-time Signals, Connector Library (Zeta) ; Next = Automated Privacy Workflow, QuickStart Library, WhatsApp ($), Interactive Moments ($), Ask Your Data (Zeta), Real-time Analytics ; Later = Enriched Customer View (Zeta), Easy Content Blocks, Audience Composition, Performance Advisor (Zeta). Sans trimestre : ne pas dater les items. Ne relayer que les noms de fonctionnalités et leur bénéfice, jamais le contenu stratégie / pricing du deck interne.\nIA : outils MCP en lecture seule (Segment Helper disponible ; Ask Your Data à venir) — ne pas promettre l’interrogation en langage naturel comme disponible. Le « Zeta login » est volontairement absent de la colonne Disponible pour rester cohérent avec le message SSO (fenêtre cible T1 2027).\nToujours distinguer disponible / prévu / cible / sous réserve. L’IA arrive après les fondations : conformité, sécurité, données, connecteurs.');
  }

  // ===== 16. Vos arbitrages =====
  {
    const s = pres.addSlide();
    header(s, { section: 'SYNTHÈSE', title: 'Vos arbitrages : cinq questions pour orienter la suite', subtitle: 'Vos réponses en séance alimentent directement le plan d’actions de la page suivante.' });
    const qs = [
      { icon: 'FiDatabase', topic: 'Base de données', q: 'Lançons-nous l’audit de nettoyage en octobre avant d’envisager une extension de capacité ?' },
      { icon: 'FiUsers', topic: 'Audience', q: 'La croissance de votre base de contacts (+17,5 % sur 14 mois) est-elle conforme à votre plan 2027 ?' },
      { icon: 'FiMail', topic: 'Email', q: 'Quelles sont les trois campagnes prioritaires à traiter dans l’atelier d’optimisation des clics ?' },
      { icon: 'FiSmartphone', topic: 'Mobile', q: 'Quelle ambition SMS / RCS en 2027 : option simple (LinkMobility) ou expérience enrichie (Infobip) ?' },
      { icon: 'FiShield', topic: 'Conformité', q: 'Quelle date pour l’atelier DPO, et quelles typologies d’emails traiter en priorité ?' },
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
    s.addNotes('NOTE INTERNE — Poser chaque question et noter la réponse ou l’arbitrage en séance (elles alimentent le tableau d’actions). Ne pas pousser de réponse : le client décide, Selligent propose.');
  }

  // ===== 17. Synthèse & prochaines étapes =====
  {
    const s = pres.addSlide();
    header(s, { section: 'SYNTHÈSE', title: 'Plan d’actions et prochaines étapes', subtitle: 'Neuf actions, un responsable et une échéance pour chacune — à ajuster avec vos arbitrages.' });
    const hdr = ['Sujet', 'Action proposée', 'Qui', 'Quand (proposition)'];
    const rows = [
      ['SLA Gold', 'Suivi mensuel de la consommation dans le reporting CSM ; alerte proactive à 60 %.', 'Selligent (CSM)', 'Mensuel'],
      ['Base de données', 'Audit de nettoyage / archivage, puis décision sur l’extension de capacité.', 'Viasanté + Selligent', 'Octobre → novembre 2026'],
      ['Audience / licence', 'Confirmation écrite de la lecture contractuelle du palier Ucount.', 'Selligent', 'Fin septembre 2026'],
      ['Sécurisation & patch', 'Bilan post-patch partagé et clôture du sujet.', 'Selligent (Ops)', 'Septembre 2026'],
      ['Email', 'Atelier d’optimisation clics (contenus, CTA, ciblage, scénarios) sur les campagnes prioritaires.', 'Viasanté (Marketing) + Selligent', 'Octobre 2026'],
      ['SMS / RCS', 'Choix de l’option RCS (LinkMobility API ou Infobip) et plan d’usage 2026–2027.', 'Viasanté (Marketing)', 'T4 2026'],
      ['SSO Engage', 'Point d’avancement produit et préparation de la bascule.', 'Selligent (Product)', 'T1 2027'],
      ['Pixel d’ouverture', 'Atelier DPO : cartographie des cas d’usage et go / no-go par typologie d’email.', 'Viasanté (DPO) + Selligent', 'Octobre 2026'],
      ['Roadmaps', 'Session roadmap dédiée CDM et Engage avec le Product Management.', 'Selligent', 'T4 2026'],
    ];
    const widths = [1.9, 6.0, 2.35, 1.98];
    const tableRows = [hdr.map(h => ({ text: h, options: { bold: true, color: C.white, fill: { color: C.teal }, fontSize: 11, fontFace: FONT, valign: 'middle', margin: [4, 6, 4, 6] } }))]
      .concat(rows.map((r, i) => r.map((cell, j) => ({ text: cell, options: { fontSize: 10.5, fontFace: FONT, color: C.ink, bold: j === 0, fill: { color: i % 2 ? C.white : C.tealXL }, valign: 'middle', margin: [3, 6, 3, 6] } }))));
    s.addTable(tableRows, { x: M, y: 2.1, w: W - 2 * M, colW: widths, border: { type: 'solid', pt: 0.5, color: 'E1E8EB' }, rowH: 0.38 });
    callout(s, M, 6.05, W - 2 * M, 0.75, 'Prochain COPIL', 'Proposition : décembre 2026 — bilan des actions, point capacité base de données, préparation 2027.', { iconName: 'FiCalendar', iconBg: C.orange, fill: C.orangeL, titleColor: C.orange, fontSize: 11.5, inline: true, titleW: 1.5 });
    s.addNotes('NOTE INTERNE — Les échéances sont des propositions Selligent (aucune n’est contractuelle) : les faire valider ou ajuster en séance ligne par ligne, noter les responsables nommément côté Viasanté. Sortie attendue : un relevé de décisions envoyé sous 48 h. Proposer une date précise pour le prochain COPIL (décembre 2026).');
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
    s.addNotes('NOTE INTERNE — Clore sur les décisions prises et la date du prochain COPIL.');
  }

  await pres.writeFile({ fileName: OUT });
  console.log('written', OUT, 'slides:', pageNo);
})().catch(e => { console.error(e); process.exit(1); });
