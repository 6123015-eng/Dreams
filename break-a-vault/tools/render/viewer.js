// HammerForge viewer — reconstruye en three.js los martillos exportados por tools/build.luau (hammers.json).
// Aproximación del render de Roblox: misma geometría (Block/Cylinder/Ball/WedgePart), materiales aproximados,
// neón con bloom, luces, partículas y animaciones FX (giro, flotación, pulso, parpadeo, arcoíris).
import * as THREE from 'three';
import { RoomEnvironment } from 'three/addons/environments/RoomEnvironment.js';
import { EffectComposer } from 'three/addons/postprocessing/EffectComposer.js';
import { RenderPass } from 'three/addons/postprocessing/RenderPass.js';
import { UnrealBloomPass } from 'three/addons/postprocessing/UnrealBloomPass.js';
import { OutputPass } from 'three/addons/postprocessing/OutputPass.js';

// ── utilidades ────────────────────────────────────────────────────────
function cfToMatrix(c) {
  const m = new THREE.Matrix4();
  m.set(c[3], c[4], c[5], c[0], c[6], c[7], c[8], c[1], c[9], c[10], c[11], c[2], 0, 0, 0, 1);
  return m;
}
const arr = (x) => (Array.isArray(x) ? x : []);
function srgb(rgb) { return new THREE.Color().setRGB(rgb[0], rgb[1], rgb[2], THREE.SRGBColorSpace); }
function mulberry(seed) {
  let a = seed >>> 0;
  return () => { a |= 0; a = (a + 0x6d2b79f5) | 0; let t = Math.imul(a ^ (a >>> 15), 1 | a); t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t; return ((t ^ (t >>> 14)) >>> 0) / 4294967296; };
}
function sampleSeq(seq, t, fallback) {
  if (!Array.isArray(seq) || !seq.length) return fallback;
  if (t <= seq[0][0]) return seq[0][1];
  for (let i = 1; i < seq.length; i++) {
    if (t <= seq[i][0]) {
      const [t0, v0] = seq[i - 1], [t1, v1] = seq[i];
      const k = (t - t0) / Math.max(1e-6, t1 - t0);
      if (Array.isArray(v0)) return [v0[0] + (v1[0] - v0[0]) * k, v0[1] + (v1[1] - v0[1]) * k, v0[2] + (v1[2] - v0[2]) * k];
      return v0 + (v1 - v0) * k;
    }
  }
  return seq[seq.length - 1][1];
}

// ── texturas procedurales (detalle de material) ───────────────────────
const texCache = new Map();
function canvasTex(key, draw, size = 256, color = true) {
  if (texCache.has(key)) return texCache.get(key);
  const cv = document.createElement('canvas'); cv.width = cv.height = size;
  const g = cv.getContext('2d'); draw(g, size, mulberry(key.length * 977 + 13));
  const t = new THREE.CanvasTexture(cv);
  t.wrapS = t.wrapT = THREE.RepeatWrapping;
  if (color) t.colorSpace = THREE.SRGBColorSpace;
  t.anisotropy = 4;
  texCache.set(key, t);
  return t;
}
function noiseFill(g, s, r, base, amp, blobs, blobSize) {
  g.fillStyle = `rgb(${base},${base},${base})`; g.fillRect(0, 0, s, s);
  for (let i = 0; i < blobs; i++) {
    const v = Math.max(0, Math.min(255, base + (r() - 0.5) * 2 * amp));
    g.fillStyle = `rgba(${v},${v},${v},${0.25 + r() * 0.5})`;
    const w = blobSize * (0.3 + r());
    g.beginPath(); g.ellipse(r() * s, r() * s, w, w * (0.4 + r()), r() * 3, 0, 7); g.fill();
  }
}
const TEX = {
  brushed: () => canvasTex('brushed', (g, s, r) => { g.fillStyle = '#d8d8d8'; g.fillRect(0, 0, s, s); for (let i = 0; i < 900; i++) { const v = 170 + r() * 85; g.strokeStyle = `rgba(${v},${v},${v},0.35)`; g.beginPath(); const y = r() * s; g.moveTo(0, y); g.lineTo(s, y + (r() - 0.5) * 3); g.stroke(); } }),
  diamond: () => canvasTex('diamond', (g, s, r) => { g.fillStyle = '#c8c8c8'; g.fillRect(0, 0, s, s); for (let y = 0; y < s; y += 16) for (let x = 0; x < s; x += 16) { const o = ((y / 16) % 2) * 8; g.fillStyle = '#f2f2f2'; g.save(); g.translate(x + o, y + 8); g.rotate(((x + y) / 16) % 2 ? 0.7 : -0.7); g.fillRect(-6, -1.6, 12, 3.2); g.restore(); } }),
  corroded: () => canvasTex('corroded', (g, s, r) => { noiseFill(g, s, r, 190, 70, 260, 18); for (let i = 0; i < 60; i++) { g.fillStyle = `rgba(80,40,20,${0.15 + r() * 0.3})`; g.beginPath(); g.arc(r() * s, r() * s, 2 + r() * 10, 0, 7); g.fill(); } }),
  wood: () => canvasTex('wood', (g, s, r) => { g.fillStyle = '#d6d6d6'; g.fillRect(0, 0, s, s); for (let i = 0; i < 60; i++) { const v = 140 + r() * 90; g.strokeStyle = `rgba(${v},${v},${v},0.55)`; g.lineWidth = 1 + r() * 3; g.beginPath(); const x = r() * s; g.moveTo(x, 0); for (let y = 0; y <= s; y += 16) g.lineTo(x + Math.sin(y * 0.05 + i) * 4, y); g.stroke(); } }),
  planks: () => canvasTex('planks', (g, s, r) => { TEX.wood(); g.drawImage(TEX.wood().image, 0, 0); g.strokeStyle = 'rgba(40,40,40,0.6)'; g.lineWidth = 3; for (let x = 0; x < s; x += 64) { g.beginPath(); g.moveTo(x, 0); g.lineTo(x, s); g.stroke(); } }),
  stone: () => canvasTex('stone', (g, s, r) => noiseFill(g, s, r, 200, 55, 500, 10)),
  marble: () => canvasTex('marble', (g, s, r) => { g.fillStyle = '#f4f4f4'; g.fillRect(0, 0, s, s); for (let i = 0; i < 14; i++) { g.strokeStyle = `rgba(150,150,150,${0.2 + r() * 0.3})`; g.lineWidth = 1 + r() * 2; g.beginPath(); let x = r() * s, y = 0; g.moveTo(x, y); while (y < s) { x += (r() - 0.5) * 30; y += 10 + r() * 20; g.lineTo(x, y); } g.stroke(); } }),
  fabric: () => canvasTex('fabric', (g, s) => { g.fillStyle = '#d0d0d0'; g.fillRect(0, 0, s, s); for (let i = 0; i < s; i += 4) { g.fillStyle = 'rgba(255,255,255,0.25)'; g.fillRect(i, 0, 2, s); g.fillStyle = 'rgba(0,0,0,0.12)'; g.fillRect(0, i, s, 2); } }),
  leather: () => canvasTex('leather', (g, s, r) => noiseFill(g, s, r, 205, 30, 900, 5)),
  ice: () => canvasTex('ice', (g, s, r) => { g.fillStyle = '#eef6ff'; g.fillRect(0, 0, s, s); for (let i = 0; i < 30; i++) { g.strokeStyle = `rgba(255,255,255,${0.3 + r() * 0.5})`; g.lineWidth = 1; g.beginPath(); g.moveTo(r() * s, r() * s); g.lineTo(r() * s, r() * s); g.stroke(); } }),
  lava: () => canvasTex('lava', (g, s, r) => { noiseFill(g, s, r, 60, 30, 300, 14); g.strokeStyle = '#ffffff'; for (let i = 0; i < 26; i++) { g.lineWidth = 1 + r() * 2.5; g.beginPath(); let x = r() * s, y = r() * s; g.moveTo(x, y); for (let k = 0; k < 6; k++) { x += (r() - 0.5) * 50; y += (r() - 0.5) * 50; g.lineTo(x, y); } g.stroke(); } }),
  lavaEmissive: () => canvasTex('lavaE', (g, s, r) => { g.fillStyle = '#000'; g.fillRect(0, 0, s, s); const src = TEX.lava().image; g.globalCompositeOperation = 'source-over'; g.drawImage(src, 0, 0); const d = g.getImageData(0, 0, s, s); for (let i = 0; i < d.data.length; i += 4) { const v = d.data[i] > 200 ? 255 : 0; d.data[i] = v; d.data[i + 1] = v * 0.45; d.data[i + 2] = v * 0.1; } g.putImageData(d, 0, 0); }),
  forcefield: () => canvasTex('ff', (g, s, r) => { g.fillStyle = '#000'; g.fillRect(0, 0, s, s); for (let i = 0; i < 160; i++) { const v = 120 + r() * 135; g.fillStyle = `rgba(${v},${v},${v},${0.2 + r() * 0.6})`; g.beginPath(); g.ellipse(r() * s, r() * s, 4 + r() * 18, 2 + r() * 6, r() * 3, 0, 7); g.fill(); } }),
};

// propiedades por material de Roblox: [roughness, metalness, textura]
const MAT = {
  Plastic: [0.55, 0, null], SmoothPlastic: [0.35, 0, null], Metal: [0.34, 0.85, 'brushed'], DiamondPlate: [0.38, 0.85, 'diamond'],
  CorrodedMetal: [0.85, 0.45, 'corroded'], Foil: [0.16, 1, null], Wood: [0.75, 0, 'wood'], WoodPlanks: [0.75, 0, 'planks'],
  Slate: [0.88, 0, 'stone'], Granite: [0.85, 0, 'stone'], Basalt: [0.78, 0.05, 'stone'], Rock: [0.9, 0, 'stone'], Concrete: [0.95, 0, 'stone'],
  Marble: [0.28, 0, 'marble'], Pebble: [0.9, 0, 'stone'], Cobblestone: [0.9, 0, 'stone'], Limestone: [0.9, 0, 'stone'], Sandstone: [0.9, 0, 'stone'],
  Asphalt: [0.95, 0, 'stone'], Pavement: [0.92, 0, 'stone'], Brick: [0.9, 0, 'stone'], CrackedLava: [0.85, 0, 'lava'], Ice: [0.12, 0, 'ice'],
  Glacier: [0.2, 0, 'ice'], Glass: [0.04, 0.1, null], Fabric: [0.97, 0, 'fabric'], Leather: [0.65, 0, 'leather'], Cardboard: [0.95, 0, 'fabric'],
  Carpet: [1, 0, 'fabric'], Salt: [0.8, 0, 'stone'], Snow: [0.9, 0, 'stone'], Mud: [0.95, 0, 'stone'], Ground: [0.95, 0, 'stone'],
};

const matCache = new Map();
function materialFor(p, unique) {
  const key = `${p.m}|${p.col.join(',')}|${p.t}|${p.r}`;
  if (!unique && matCache.has(key)) return matCache.get(key);
  const color = srgb(p.col);
  const opacity = 1 - (p.t || 0);
  let mat;
  if (p.m === 'Neon') {
    mat = new THREE.MeshBasicMaterial({ color: color.clone().multiplyScalar(1.7), toneMapped: false, transparent: opacity < 1, opacity: Math.max(0.05, opacity) });
  } else if (p.m === 'ForceField') {
    const tex = TEX.forcefield().clone(); tex.needsUpdate = true;
    mat = new THREE.MeshBasicMaterial({ color: color.clone().multiplyScalar(1.6), map: tex, transparent: true, opacity: 0.85 * opacity, blending: THREE.AdditiveBlending, depthWrite: false, toneMapped: false, side: THREE.DoubleSide });
    mat.userData.scroll = tex;
  } else if (p.m === 'Glass') {
    mat = new THREE.MeshPhysicalMaterial({ color, roughness: 0.04, metalness: 0.05, transparent: true, opacity: Math.max(0.18, opacity * 0.85), envMapIntensity: 2.2, clearcoat: 1, clearcoatRoughness: 0.05, depthWrite: opacity > 0.7 });
  } else {
    const [rough, metal, texName] = MAT[p.m] || MAT.Plastic;
    const refl = p.r || 0;
    const opts = { color, roughness: Math.max(0.12, rough - refl * 0.5), metalness: Math.min(1, metal + refl * 0.5), envMapIntensity: 0.7 + refl * 1.6 };
    if (texName && TEX[texName]) { opts.map = TEX[texName](); opts.roughnessMap = null; }
    if (p.m === 'CrackedLava') { opts.emissive = new THREE.Color(1, 0.5, 0.15); opts.emissiveMap = TEX.lavaEmissive(); opts.emissiveIntensity = 1.6; }
    if (p.m === 'Ice' || p.m === 'Glacier') { opts.transparent = true; opts.opacity = Math.min(opacity, 0.88); }
    else if (opacity < 1) { opts.transparent = true; opts.opacity = opacity; opts.depthWrite = opacity > 0.6; }
    mat = new THREE.MeshStandardMaterial(opts);
  }
  if (!unique) matCache.set(key, mat);
  return mat;
}

// WedgePart: rampa de (abajo, -Z) a (arriba, +Z); cara vertical completa en +Z.
function wedgeGeometry(sx, sy, sz) {
  const x = sx / 2, y = sy / 2, z = sz / 2;
  const A = [-x, -y, -z], B = [-x, -y, z], C = [-x, y, z], D = [x, -y, -z], E = [x, -y, z], F = [x, y, z];
  const tris = [A, C, B, D, E, F, A, B, E, A, E, D, B, C, F, B, F, E, A, D, F, A, F, C];
  const pos = new Float32Array(tris.flat());
  const g = new THREE.BufferGeometry();
  g.setAttribute('position', new THREE.BufferAttribute(pos, 3));
  const uv = new Float32Array((tris.length) * 2);
  for (let i = 0; i < tris.length; i++) { uv[i * 2] = (tris[i][2] / sz + 0.5); uv[i * 2 + 1] = (tris[i][1] / sy + 0.5); }
  g.setAttribute('uv', new THREE.BufferAttribute(uv, 2));
  g.computeVertexNormals();
  return g;
}

function geometryFor(p) {
  const [sx, sy, sz] = p.sz;
  if (p.c === 'WedgePart') return wedgeGeometry(sx, sy, sz);
  if (p.s === 'Cylinder') { const d = Math.min(sy, sz); const g = new THREE.CylinderGeometry(d / 2, d / 2, sx, 28); g.rotateZ(Math.PI / 2); return g; }
  if (p.s === 'Ball') { const d = Math.min(sx, sy, sz); return new THREE.SphereGeometry(d / 2, 24, 16); }
  return new THREE.BoxGeometry(sx, sy, sz);
}

// ── partículas ────────────────────────────────────────────────────────
const spriteCache = new Map();
function sprite(kind) {
  if (spriteCache.has(kind)) return spriteCache.get(kind);
  const s = 64; const cv = document.createElement('canvas'); cv.width = cv.height = s; const g = cv.getContext('2d');
  const grad = (r0, stops) => { const gr = g.createRadialGradient(s / 2, s / 2, 0, s / 2, s / 2, r0); stops.forEach(([o, c]) => gr.addColorStop(o, c)); return gr; };
  if (kind === 'sparkle') {
    g.fillStyle = grad(s / 2, [[0, 'rgba(255,255,255,1)'], [0.25, 'rgba(255,255,255,0.5)'], [1, 'rgba(255,255,255,0)']]); g.fillRect(0, 0, s, s);
    g.fillStyle = 'rgba(255,255,255,0.95)'; g.beginPath(); g.moveTo(s / 2, 2); g.lineTo(s / 2 + 4, s / 2 - 4); g.lineTo(s - 2, s / 2); g.lineTo(s / 2 + 4, s / 2 + 4); g.lineTo(s / 2, s - 2); g.lineTo(s / 2 - 4, s / 2 + 4); g.lineTo(2, s / 2); g.lineTo(s / 2 - 4, s / 2 - 4); g.closePath(); g.fill();
  } else if (kind === 'fire') {
    g.fillStyle = grad(s / 2, [[0, 'rgba(255,255,255,0.95)'], [0.45, 'rgba(255,255,255,0.45)'], [1, 'rgba(255,255,255,0)']]); g.fillRect(0, 0, s, s);
  } else if (kind === 'firesparks') {
    g.fillStyle = grad(s / 4, [[0, 'rgba(255,255,255,1)'], [1, 'rgba(255,255,255,0)']]); g.fillRect(0, 0, s, s);
  } else if (kind === 'smoke') {
    for (let i = 0; i < 6; i++) { g.fillStyle = grad(s / 2.4, [[0, 'rgba(255,255,255,0.35)'], [1, 'rgba(255,255,255,0)']]); g.save(); g.translate((i % 3 - 1) * 8, (Math.floor(i / 3) - 0.5) * 10); g.fillRect(0, 0, s, s); g.restore(); }
  } else {
    g.fillStyle = grad(s / 2, [[0, 'rgba(255,255,255,1)'], [0.35, 'rgba(255,255,255,0.55)'], [1, 'rgba(255,255,255,0)']]); g.fillRect(0, 0, s, s);
  }
  const t = new THREE.CanvasTexture(cv); spriteCache.set(kind, t); return t;
}
function spriteKind(tex) {
  if (!tex) return 'glow';
  if (tex.includes('sparkles')) return 'sparkle';
  if (tex.includes('fire_sparks')) return 'firesparks';
  if (tex.includes('fire')) return 'fire';
  if (tex.includes('smoke')) return 'smoke';
  return 'glow';
}
const DIRS = { Top: [0, 1, 0], Bottom: [0, -1, 0], Front: [0, 0, -1], Back: [0, 0, 1], Right: [1, 0, 0], Left: [-1, 0, 0] };

class Emitter {
  constructor(def, scaleRef) {
    this.def = def; this.scaleRef = scaleRef;
    this.rand = mulberry((def.p[0] * 1000 + def.p[1] * 100 + def.rate) | 0);
    const lifeMax = def.life[1] || 1;
    this.max = Math.min(600, Math.ceil((def.rate || 0) * lifeMax * 1.3) + (def.emit || 0) * 3 + 8);
    this.parts = [];
    const geo = new THREE.BufferGeometry();
    this.pos = new Float32Array(this.max * 3); this.col = new Float32Array(this.max * 3); this.size = new Float32Array(this.max); this.alpha = new Float32Array(this.max);
    geo.setAttribute('position', new THREE.BufferAttribute(this.pos, 3));
    geo.setAttribute('pcolor', new THREE.BufferAttribute(this.col, 3));
    geo.setAttribute('psize', new THREE.BufferAttribute(this.size, 1));
    geo.setAttribute('palpha', new THREE.BufferAttribute(this.alpha, 1));
    const additive = (def.le || 0) > 0.35;
    this.material = new THREE.ShaderMaterial({
      uniforms: { map: { value: sprite(spriteKind(def.tex)) }, uScale: scaleRef, uBright: { value: additive ? 1.6 : 1.0 } },
      vertexShader: `attribute vec3 pcolor; attribute float psize; attribute float palpha; varying vec3 vColor; varying float vAlpha; uniform float uScale;
        void main(){ vColor=pcolor; vAlpha=palpha; vec4 mv=modelViewMatrix*vec4(position,1.0); gl_PointSize=psize*uScale/max(0.1,-mv.z); gl_Position=projectionMatrix*mv; }`,
      fragmentShader: `uniform sampler2D map; uniform float uBright; varying vec3 vColor; varying float vAlpha;
        void main(){ vec4 t=texture2D(map, gl_PointCoord); gl_FragColor=vec4(vColor*uBright, t.a*vAlpha); if(gl_FragColor.a<0.01) discard; }`,
      transparent: true, depthWrite: false, blending: additive ? THREE.AdditiveBlending : THREE.NormalBlending, toneMapped: false,
    });
    this.points = new THREE.Points(geo, this.material);
    this.points.frustumCulled = false;
    this.acc = 0;
    if (def.vcf) { this.vm = cfToMatrix(def.vcf); this.vrot = new THREE.Matrix4().extractRotation(this.vm); }
  }
  spawn() {
    const d = this.def, r = this.rand;
    if (this.parts.length >= this.max) return;
    let p = new THREE.Vector3(...d.p);
    let dir = new THREE.Vector3(...(DIRS[d.dir] || DIRS.Top));
    if (d.vol && this.vm) {
      const [sx, sy, sz] = d.vol;
      if (d.shape === 'Sphere') {
        const u = new THREE.Vector3(r() - 0.5, r() - 0.5, r() - 0.5).normalize();
        p = u.clone().multiply(new THREE.Vector3(sx / 2, sy / 2, sz / 2)).applyMatrix4(this.vm);
        dir = u.clone().transformDirection(this.vrot);
        if (d.inout === 'Inward') dir.negate();
      } else {
        p = new THREE.Vector3((r() - 0.5) * sx, (r() - 0.5) * sy, (r() - 0.5) * sz).applyMatrix4(this.vm);
        dir.transformDirection(this.vrot);
      }
    }
    const sx = (d.spread[0] || 0) * Math.PI / 180, sy = (d.spread[1] || 0) * Math.PI / 180;
    if (sx > 0 || sy > 0) {
      const ax = (r() * 2 - 1) * sx, ay = (r() * 2 - 1) * sy;
      const perp1 = new THREE.Vector3(1, 0, 0); if (Math.abs(dir.x) > 0.9) perp1.set(0, 0, 1);
      const perp2 = new THREE.Vector3().crossVectors(dir, perp1).normalize(); perp1.crossVectors(perp2, dir).normalize();
      dir.applyAxisAngle(perp1, ax).applyAxisAngle(perp2, ay).normalize();
    }
    const speed = d.speed[0] + (d.speed[1] - d.speed[0]) * r();
    const life = d.life[0] + (d.life[1] - d.life[0]) * r();
    this.parts.push({ p, v: dir.multiplyScalar(speed), age: 0, life });
  }
  burst(n) { for (let i = 0; i < n; i++) this.spawn(); }
  update(dt, rateMul = 1) {
    const d = this.def;
    if (d.enabled && d.rate > 0) { this.acc += d.rate * rateMul * dt; while (this.acc >= 1) { this.spawn(); this.acc -= 1; } }
    const acc = new THREE.Vector3(...(d.acc || [0, 0, 0]));
    const drag = d.drag || 0;
    let n = 0;
    for (let i = this.parts.length - 1; i >= 0; i--) {
      const q = this.parts[i]; q.age += dt;
      if (q.age >= q.life) { this.parts.splice(i, 1); continue; }
      q.v.addScaledVector(acc, dt); if (drag) q.v.multiplyScalar(Math.exp(-drag * dt)); q.p.addScaledVector(q.v, dt);
    }
    for (const q of this.parts) {
      const t = q.age / q.life;
      this.pos.set([q.p.x, q.p.y, q.p.z], n * 3);
      const c = sampleSeq(d.col, t, [1, 1, 1]); this.col.set(c, n * 3);
      this.size[n] = sampleSeq(d.size, t, 1); this.alpha[n] = 1 - sampleSeq(d.transp, t, 0);
      n++;
    }
    const geo = this.points.geometry;
    geo.setDrawRange(0, n);
    for (const k of ['position', 'pcolor', 'psize', 'palpha']) geo.attributes[k].needsUpdate = true;
  }
}

// ── martillo ─────────────────────────────────────────────────────────
export function buildHammer(data, opts = {}) {
  const group = new THREE.Group();
  group.name = data.id;
  const animated = [], pulses = [], hues = [], flickers = [], lights = [], emitters = [], scroll = [];
  const meshes = [];
  const scaleRef = opts.scaleRef || { value: 400 };
  arr(data.parts).forEach((p, i) => {
    if ((p.t || 0) >= 0.999) { meshes.push(null); return; }
    const unique = !!(p.pulse || p.hue);
    const mat = materialFor(p, unique);
    const mesh = new THREE.Mesh(geometryFor(p), mat);
    mesh.matrixAutoUpdate = false;
    mesh.matrix.copy(cfToMatrix(p.cf));
    mesh.castShadow = p.m !== 'Neon' && p.m !== 'Glass' && p.m !== 'ForceField';
    mesh.receiveShadow = true;
    if (p.m === 'Glass' || p.m === 'ForceField' || (p.t || 0) > 0) mesh.renderOrder = 2;
    group.add(mesh); meshes.push(mesh);
    if (mat.userData.scroll) scroll.push(mat.userData.scroll);
    if (p.fx) animated.push({ mesh, base: cfToMatrix(p.fx.base), c1inv: cfToMatrix(p.fx.c1inv), spin: p.fx.spin, bob: p.fx.bob, bobSpeed: p.fx.bobSpeed || 0.5, phase: p.fx.phase || 0 });
    if (p.pulse) pulses.push({ mat, min: p.pulse[0], max: p.pulse[1], speed: p.pulse[2], phase: p.pulse[3] || 0 });
    if (p.hue) { const hsl = {}; mat.color.getHSL(hsl); hues.push({ mat, speed: p.hue, h: hsl.h, neon: p.m === 'Neon' }); }
  });
  arr(data.flickers).forEach((f) => flickers.push({ meshes: arr(f.parts).map((i) => meshes[i]).filter(Boolean), hz: f.hz, on: f.on, next: 0, rand: mulberry(f.parts.length * 31 + 7) }));
  arr(data.lights).forEach((l) => {
    const light = new THREE.PointLight(srgb(l.col), l.b * 2.2, l.r * 1.2, 1);
    light.position.set(...l.p); group.add(light); lights.push({ light, base: l.b * 2.2, pulse: l.pulse });
  });
  arr(data.emitters).forEach((e) => {
    const em = new Emitter(e, scaleRef); group.add(em.points); emitters.push(em);
  });
  let impactLight = null;
  if (data.impact) { impactLight = new THREE.PointLight(0xffffff, 0, 16, 1); impactLight.position.set(...data.impact); group.add(impactLight); }
  let flash = 0;
  const impactColor = (() => { const e = arr(data.emitters).find((x) => x.n === 'ImpactFlash'); return e && e.col ? srgb(e.col[0][1]) : new THREE.Color(1, 0.8, 0.5); })();

  const tmp = new THREE.Matrix4(), rot = new THREE.Matrix4(), tr = new THREE.Matrix4(), axis = new THREE.Vector3();
  function update(t, dt) {
    for (const a of animated) {
      const tt = t + a.phase;
      tmp.copy(a.base);
      if (a.bob) { const s = Math.sin(tt * a.bobSpeed * Math.PI * 2); tr.makeTranslation(a.bob[0] * s, a.bob[1] * s, a.bob[2] * s); tmp.multiply(tr); }
      if (a.spin) { axis.set(...a.spin); const mag = axis.length(); if (mag > 0) { rot.makeRotationAxis(axis.normalize(), mag * tt); tmp.multiply(rot); } }
      a.mesh.matrix.copy(tmp).multiply(a.c1inv);
    }
    for (const p of pulses) { const k = 0.5 + 0.5 * Math.sin((t + p.phase) * p.speed * Math.PI * 2); const tr2 = p.min + (p.max - p.min) * k; p.mat.transparent = true; p.mat.opacity = Math.max(0.03, 1 - tr2); }
    for (const h of hues) { h.mat.color.setHSL((h.h + t * h.speed) % 1, 1, 0.55); if (h.neon) h.mat.color.multiplyScalar(1.6); }
    for (const f of flickers) { if (t >= f.next) { f.next = t + 1 / f.hz; for (const m of f.meshes) m.visible = f.rand() < f.on; } }
    for (const l of lights) { if (l.pulse) { const k = 0.5 + 0.5 * Math.sin(t * l.pulse[2] * Math.PI * 2); l.light.intensity = (l.pulse[0] + (l.pulse[1] - l.pulse[0]) * k) * 2.2; } }
    for (const s of scroll) { s.offset.x = (t * 0.05) % 1; s.offset.y = (t * 0.11) % 1; }
    for (const e of emitters) e.update(dt);
    if (impactLight) { flash = Math.max(0, flash - dt * 4); impactLight.intensity = flash * 14; impactLight.color.copy(impactColor); }
  }
  function impact() {
    for (const e of emitters) if (e.def.emit) e.burst(e.def.emit);
    flash = 1;
  }
  function prewarm(seconds = 1.5, step = 1 / 30) { for (let t = 0; t < seconds; t += step) update(t, step); }
  return { group, update, impact, prewarm, data };
}

// ── escenario ────────────────────────────────────────────────────────
export function createStage(canvas, opts = {}) {
  const renderer = new THREE.WebGLRenderer({ canvas, antialias: true, preserveDrawingBuffer: !!opts.preserve, alpha: false });
  renderer.setPixelRatio(opts.pixelRatio || Math.min(2, window.devicePixelRatio || 1));
  renderer.toneMapping = THREE.ACESFilmicToneMapping;
  renderer.toneMappingExposure = opts.exposure || 1.05;
  renderer.outputColorSpace = THREE.SRGBColorSpace;
  renderer.shadowMap.enabled = true;
  renderer.shadowMap.type = THREE.PCFSoftShadowMap;
  const scene = new THREE.Scene();
  scene.background = new THREE.Color(opts.background || 0x121a26);
  const pmrem = new THREE.PMREMGenerator(renderer);
  scene.environment = pmrem.fromScene(new RoomEnvironment(), 0.04).texture;
  scene.environmentIntensity = 0.55;
  const hemi = new THREE.HemisphereLight(0xbfd6ff, 0x1a1410, 0.6); scene.add(hemi);
  const key = new THREE.DirectionalLight(0xfff1dc, 2.4); key.position.set(4, 8, 7); key.castShadow = true; key.shadow.mapSize.set(1024, 1024); key.shadow.bias = -0.0004;
  key.shadow.camera.left = -6; key.shadow.camera.right = 6; key.shadow.camera.top = 8; key.shadow.camera.bottom = -6; scene.add(key);
  const rim = new THREE.DirectionalLight(0x6fb6ff, 1.6); rim.position.set(-6, 4, -6); scene.add(rim);
  const fill = new THREE.DirectionalLight(0xffc9a0, 0.5); fill.position.set(-4, -2, 6); scene.add(fill);
  const camera = new THREE.PerspectiveCamera(opts.fov || 30, 1, 0.05, 200);
  const composer = new EffectComposer(renderer);
  composer.addPass(new RenderPass(scene, camera));
  const bloom = new UnrealBloomPass(new THREE.Vector2(512, 512), opts.bloomStrength ?? 0.85, opts.bloomRadius ?? 0.55, opts.bloomThreshold ?? 0.9);
  composer.addPass(bloom);
  composer.addPass(new OutputPass());
  const scaleRef = { value: 400 };
  function resize(w, h) {
    renderer.setSize(w, h, false); composer.setSize(w, h); camera.aspect = w / h; camera.updateProjectionMatrix();
    scaleRef.value = h * renderer.getPixelRatio() * 0.5 * camera.projectionMatrix.elements[5];
  }
  function render() { composer.render(); }
  return { THREE, renderer, scene, camera, composer, bloom, resize, render, scaleRef, key };
}

// Encuadra la cámara a la caja del martillo. view: hero | profile | back | head | top
export function frame(camera, stats, view = 'hero', margin = 1.12) {
  const min = new THREE.Vector3(...stats.bboxMin), max = new THREE.Vector3(...stats.bboxMax);
  const center = min.clone().add(max).multiplyScalar(0.5);
  const size = max.clone().sub(min);
  let dir, target = center.clone(), fit = Math.max(size.y, size.x) * 0.5;
  if (view === 'profile') dir = new THREE.Vector3(0, 0.02, 1);
  else if (view === 'back') dir = new THREE.Vector3(-0.55, -0.12, -1);
  else if (view === 'top') dir = new THREE.Vector3(0.2, 1, 0.35);
  else if (view === 'head') { const headY = max.y - Math.min(size.y * 0.22, 1.3); target = new THREE.Vector3(center.x, headY, center.z); dir = new THREE.Vector3(0.75, 0.35, 1); fit = Math.max(size.x, size.z) * 0.62; }
  else dir = new THREE.Vector3(0.62, 0.22, 1);
  dir.normalize();
  const dist = (fit * margin) / Math.tan((camera.fov * Math.PI) / 360) + Math.max(size.z, size.x) * 0.5;
  camera.position.copy(target).addScaledVector(dir, dist);
  camera.lookAt(target);
  camera.updateProjectionMatrix();
  return { center, size, target };
}
