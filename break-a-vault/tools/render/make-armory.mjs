// Arma la vista previa "Break a Vault Armory" (un solo HTML con datos, miniaturas y visor).
//   node tools/render/make-armory.mjs <salida.html> [dist/hammers.json]
import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { chromium } from 'playwright-core';

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '..', '..');
const outFile = path.resolve(process.argv[2] || path.join(root, 'dist', 'armory.html'));
const jsonRel = process.argv[3] || 'dist/hammers.json';
const data = JSON.parse(fs.readFileSync(path.join(root, jsonRel), 'utf8'));

const TYPES = { '.html': 'text/html', '.js': 'text/javascript', '.json': 'application/json' };
const server = http.createServer((req, res) => {
  const url = decodeURIComponent(req.url.split('?')[0]);
  const file = url.startsWith('/dist/') ? path.join(root, url) : path.join(here, url);
  fs.readFile(file, (err, buf) => { if (err) { res.writeHead(404); return res.end(); } res.writeHead(200, { 'Content-Type': TYPES[path.extname(file)] || 'application/octet-stream' }); res.end(buf); });
});
await new Promise((r) => server.listen(0, '127.0.0.1', r));
const exe = ['/opt/pw-browsers/chromium-1194/chrome-linux/chrome', '/opt/pw-browsers/chromium/chrome-linux/chrome'].find((p) => fs.existsSync(p));
const browser = await chromium.launch({ executablePath: exe, args: ['--use-angle=swiftshader', '--enable-unsafe-swiftshader', '--ignore-gpu-blocklist'] });
const page = await browser.newPage();
page.on('pageerror', (e) => console.error('pageerror:', e.message));
await page.goto(`http://127.0.0.1:${server.address().port}/render.html`);
await page.waitForFunction(() => window.ready === true, null, { timeout: 60000 });
const thumbs = await page.evaluate((p) => window.renderThumbs(p, 240, 300), '/' + jsonRel);
await browser.close(); server.close();

const viewer = fs.readFileSync(path.join(here, 'viewer.js'), 'utf8').replace(/^export /gm, '');
const safe = (s) => s.replace(/<\//g, '<\\/');
let html = fs.readFileSync(path.join(here, 'armory.template.html'), 'utf8');
html = html.replace('/*__DATA__*/', () => safe(JSON.stringify(data)));
html = html.replace('/*__THUMBS__*/', () => safe(JSON.stringify(thumbs)));
html = html.replace('/*__VIEWER__*/', () => viewer);
fs.mkdirSync(path.dirname(outFile), { recursive: true });
fs.writeFileSync(outFile, html);
console.log(`→ ${outFile} (${(html.length / 1024 / 1024).toFixed(2)} MB, ${data.hammers.length} martillos)`);
