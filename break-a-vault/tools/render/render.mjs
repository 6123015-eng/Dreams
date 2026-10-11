// Renderiza vistas previas de los martillos con Chromium headless.
//   node tools/render/render.mjs                      -> todos (una imagen 2×2 por martillo) + hoja de contacto
//   node tools/render/render.mjs RustyHammer SafeCracker
//   node tools/render/render.mjs --sheet              -> solo hoja de contacto
// Lee dist/hammers.json (generado por `lune run tools/build.luau`). Escribe en tools/render/out/.
import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { chromium } from 'playwright-core';

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '..', '..');
const outDir = path.join(here, 'out');
fs.mkdirSync(outDir, { recursive: true });

const args = process.argv.slice(2);
const sheetOnly = args.includes('--sheet');
const noSheet = args.includes('--no-sheet');
const ids = args.filter((a) => !a.startsWith('--'));

const TYPES = { '.html': 'text/html', '.js': 'text/javascript', '.mjs': 'text/javascript', '.json': 'application/json', '.png': 'image/png' };
const server = http.createServer((req, res) => {
  const url = decodeURIComponent(req.url.split('?')[0]);
  let file = url.startsWith('/dist/') ? path.join(root, url) : path.join(here, url);
  if (!file.startsWith(root)) { res.writeHead(403); return res.end(); }
  fs.readFile(file, (err, buf) => {
    if (err) { res.writeHead(404); return res.end(); }
    res.writeHead(200, { 'Content-Type': TYPES[path.extname(file)] || 'application/octet-stream' });
    res.end(buf);
  });
});
await new Promise((r) => server.listen(0, '127.0.0.1', r));
const port = server.address().port;

const exe = ['/opt/pw-browsers/chromium-1194/chrome-linux/chrome', '/opt/pw-browsers/chromium/chrome-linux/chrome'].find((p) => fs.existsSync(p));
const browser = await chromium.launch({ executablePath: exe, args: ['--use-angle=swiftshader', '--enable-unsafe-swiftshader', '--ignore-gpu-blocklist'] });
const page = await browser.newPage({ viewport: { width: 1100, height: 1100 } });
page.on('pageerror', (e) => console.error('pageerror:', e.message));
page.on('console', (m) => { if (m.type() === 'error') console.error('console:', m.text()); });
await page.goto(`http://127.0.0.1:${port}/render.html`);
await page.waitForFunction(() => window.ready === true, null, { timeout: 60000 });

const jsonRel = process.env.HAMMERS_JSON || 'dist/hammers.json';
const dataPath = '/' + jsonRel.replace(/^\.?\//, '');
const data = JSON.parse(fs.readFileSync(path.join(root, jsonRel), 'utf8'));
const targets = ids.length ? ids : data.hammers.map((h) => h.id);

function save(name, dataUrl) {
  const file = path.join(outDir, name);
  fs.writeFileSync(file, Buffer.from(dataUrl.split(',')[1], 'base64'));
  console.log('→ ' + path.relative(root, file));
}

if (!sheetOnly) {
  for (const id of targets) {
    if (!data.hammers.find((h) => h.id === id)) { console.error('no está en hammers.json: ' + id); continue; }
    const url = await page.evaluate(([p, i]) => window.renderHammer(p, i, 512), [dataPath, id]);
    save(`${id}.png`, url);
  }
}
if (!noSheet && (sheetOnly || !ids.length)) {
  const url = await page.evaluate((p) => window.renderSheet(p, 8, 220, 300), dataPath);
  save('_contact_sheet.png', url);
}
await browser.close();
server.close();
