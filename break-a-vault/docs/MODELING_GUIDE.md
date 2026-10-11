# HammerForge — Guía de modelado (para agentes y para el Claude local)

Objetivo: los 32 martillos de `concepts/` rehechos con partes de Roblox para que se vean **premium y
"dopamínicos"**: brillo, capas, contraste, movimiento. Nada de "bloque de plástico con palo".

Cada martillo = un archivo `src/ReplicatedStorage/HammerForge/Hammers/<Rareza>/<Id>.luau`.
Referencia completa de la API: `src/ReplicatedStorage/HammerForge/Builder.luau` y `Palette.luau`.
Ejemplo terminado: `Hammers/Starter/RustyHammer.luau`.

---

## 1. Formato del archivo

```lua
return {
	Id = "SafeCracker",            -- igual al nombre del archivo, PascalCase, único
	DisplayName = "Safe Cracker",  -- como en la hoja de concepto
	Rarity = "Uncommon",           -- Starter | Uncommon | Rare | Epic | Legendary | Mythic | Special
	Order = 4,                     -- posición dentro de su rareza (1..4, Special 1..8, orden de la hoja)
	Theme = "Bank Alley",          -- zona sugerida (opcional; el Claude local decide al final)
	Build = function(b, P, B)      -- b = builder de ESTE martillo, P = Palette, B = Builder (estático)
		local A = B.Anatomy
		...
	end,
}
```

## 2. Espacio del modelo (MUY importante)

- Origen = centro del agarre (mano). `Handle` invisible en el origen con rotación identidad.
- **+Y** = hacia la cabeza. El mango corre por el eje Y.
- La cabeza se extiende por **X** (caras de golpe en ±X).
- Las caras de emblema (las que se ven en la hoja de concepto) miran a **±Z**. Detalla AMBAS.
- Escala 1: `B.Anatomy` → HeadY=3.35, HeadW=3.3, HeadH=1.9, HeadD=1.9, ShaftDia=0.36,
  ShaftBottom=-1.25, PommelY=-1.45, GripLength=1.8. Altura total esperada 5.5–7 studs.
  Rarezas altas pueden tener cabezas más grandes (hasta ~4.2 de largo, ~2.6 de alto).
- Cilindros de Roblox tienen el eje en X → usa `b:cylY` (eje Y) o `b:cylZ` (eje Z).
- `B.faceZ(s, y, z)` da un plano sobre la cara ±Z (local XY = superficie, local Z = hacia afuera,
  ya espejado para s = -1). `B.faceX(s, x, y)` igual para las caras de golpe.
- `B.both(function(s) ... end)` repite con s = 1 y s = -1 (simetría).

## 3. Lo que hace que NO se vea plástico (reglas de calidad)

1. **Silueta primero.** Proporciones de la hoja de concepto, exageradas: cabeza robusta, bandas gruesas,
   remates que sobresalen. Revisa la vista `profile` contra el concepto.
2. **Capas (mínimo 3 niveles de profundidad).** Núcleo → bandas/marcos/placas que sobresalen 0.05–0.15 →
   detalles (remaches, emblema, grietas). Una cara plana sin nada = mal.
3. **Biseles en todo bloque grande** (`b:bevelBox`) con `edgeStyle` MÁS CLARO que el núcleo → "brillo de arista".
4. **Contraste de materiales.** Base oscura + metal claro en bordes + UN color de acento fuerte. 2–4 materiales.
   **Prohibido** `Plastic`/`SmoothPlastic` (salvo `Palette.Invisible`).
5. **Neón con contexto.** El neón va DENTRO de algo: ranuras, tubos con vidrio encima (`P.glass` sobre `P.neon`),
   grietas, núcleos, runas. Siempre rodeado de material oscuro. Para energía usa capas: núcleo neón +
   cáscara `P.forcefield` o `P.glass` un poco más grande.
6. **Las 6 caras importan.** Ambas caras de emblema, ambas caras de golpe (tapas con diseño) y arriba/abajo de la cabeza.
7. **Mango con diseño.** Nunca un cilindro liso: agarre (`b:wrap`, anillos), collar bajo la cabeza, pomo con detalle.
8. **Movimiento = dopamina** (desde Rare): algo que gira (`b:animate` con Spin), flota (Bob), late (`b:pulse`),
   parpadea (`b:flicker`) o cambia de color (`b:hue`). Luz del color de acento con pulso.
9. **Golpe y trail siempre.** `b:impact(cara -X, colorTema, {extra = {...}})` y `b:trail(arriba, abajo, c0, c1)`.
   En rarezas altas agrega emisores extra al impacto (brasas, escarcha, chispas eléctricas, píxeles…).
10. **Evita el z-fighting.** Nada coplanar: las calcomanías/placas salen ≥ 0.01 studs de la superficie.
    Piezas de menos de 0.03 de grosor parpadean a distancia: usa ≥ 0.04.

### Escalera de rarezas (guía, no ley)

| Rareza | Look | Partículas (Rate total) | Luces | Animación | Piezas aprox. |
|---|---|---|---|---|---|
| Starter | materiales crudos bien hechos (óxido, madera, hierro), desgaste | 0 (solo impacto) | 0 | — | 80–150 |
| Uncommon | metal trabajado, pintura industrial, remaches, brillo de arista | 0–4 (destello sutil) | 0–1 | — | 110–190 |
| Rare | acentos azules/energía, primer neón | 4–12 | 1 | 1 elemento | 140–240 |
| Epic | neón morado/temático marcado, gemas, aura | 10–25 | 1–2 | 1–2 | 170–280 |
| Legendary | oro/fuego/obsidiana, muchas capas, brillo fuerte | 20–45 | 1–2 | 2+ | 200–340 |
| Mythic | VFX pesado: anillos orbitando, rayos, halo | 30–70 | 2–3 | 3+ | 220–380 |
| Special | temático extremo (tóxico, reactor, magma, cristal, steampunk, píxel, cósmico) | 20–60 | 1–3 | 2+ | 180–380 |

Límites duros que valida el build: Rate total ≤ 120, luces ≤ 4 (sin contar la luz de impacto).

## 4. API rápida (todas las coordenadas en espacio del modelo)

```lua
-- básicas (devuelven la pieza)
b:box(size, cf, style, name)
b:cylinder(len, dia, cf, style, name)   -- eje X local
b:cylY(len, dia, cf, style, name)       -- eje Y local
b:cylZ(len, dia, cf, style, name)       -- eje Z local
b:ball(dia, cf, style, name)
b:wedge(size, cf, style, name)          -- rampa de (abajo,-Z) a (arriba,+Z)
b:disc(cf, dia, thickness, style)       -- collar/disco con eje = Y local de cf
-- compuestas (devuelven lista de piezas)
b:bevelBox(size, cf, style, bevel, { edges = "all"|"X"|"Y"|"Z", edgeStyle = st, corners = bool })
b:rivet(pos, dia, style)    b:rivetLine(p0, p1, n, dia, style)
b:ring(cf, radius, tube, segments, style, name, width)   -- anillo en el plano XZ local de cf
b:wrap(y0, y1, radius, turns, style, { width, thickness, phase, segmentsPerTurn, cf })
b:triangle(a, b, c, thickness, style)                    -- 2 WedgeParts
b:pyramid(baseCF, length, baseWidth, sides, style)       -- punta hacia +Y local
b:spike(baseCF, length, baseWidth, style, sides)         -- pirámide de 4 caras
b:crystal(baseCF, length, width, style, coreStyle)       -- prisma + punta
b:gem(cf, size, style, coreStyle)                        -- cubo facetado + núcleo
b:line(p0, p1, width, depth, style, normal)              -- barra recta
b:polyline(points, width, depth, style, normal, closed)  -- grietas, rayos, contornos
B.jitterPath(p0, p1, segments, amplitude, seed, normal)  -- puntos en zigzag (rayos)
b:shape(planeCF, points2D, thickness, style)             -- extruye una forma 2D (triangula sola)
b:stripes(planeCF, w, h, stripeW, angleDeg, thickness, style)  -- franjas de peligro
b:pixels(planeCF, { "..XX..", ".X..X." }, pixel, depth, { X = st })  -- arte de píxeles
b:dial(planeCF, radius, ringSt, spokeSt, hubSt, spokes)  -- volante de bóveda (motivo del logo)
B.Shapes.circle/star/rect/rhombus/triangle/bolt/flame/crown/sector(r1,r2,a0,a1)/clipRect/triangulate
-- organización
b:group("Head", function() ... end)
-- efectos
b:fxVolume(size, cf)                       -- parte invisible para emitir partículas desde un volumen
b:emitter(atPartOrAttOrPos, B.Particles.sparkle(color, rate), name)
--   presets: sparkle, ember, flame, smoke, drip, frost, electric, orb, implode (props editables)
b:light(pos, color, brightness, range, { pulse = {min,max}, pulseSpeed = hz })
b:trail(p0, p1, color0, color1, { lifetime })
b:impact(cf, color, { sparks = n, flash = brillo, extra = { propsDeEmisor, ... } })   -- props.EmitCount
b:highlight(color, fillT, outlineT)        -- contorno; solo si de verdad suma (máx. Legendary+)
-- animación (la ejecuta FX en el cliente; el visor la previsualiza)
b:animate(parts, pivotCF, { Spin = Vector3 (eje*rad/s), Bob = Vector3, BobSpeed = hz, Phase = s })
b:pulse(partsOrLights, min, max, hz, phase)   -- piezas: Transparency; luces: Brightness
b:flicker(folder, hz, visibleFraction)        -- arcos eléctricos: crea un b:group y parpadéalo
b:hue(partsOrLights, speed)                   -- arcoíris
```

Estilos: `P.Iron, P.DarkIron, P.Blackened, P.Gunmetal, P.Steel, P.BrightSteel, P.Chrome, P.Rust, P.RustDark,
P.Gold, P.GoldDeep, P.GoldPale, P.Brass, P.Copper, P.Bronze, P.HazardYellow, P.HazardBlack, P.SafetyRed,
P.Wood, P.WoodLight, P.WoodDark, P.Leather, P.LeatherDark, P.Bandage, P.GripBlack, P.Stone, P.DarkStone,
P.Obsidian, P.Lava, P.Marble, P.Ice, P.Glacier` y generadores `P.metal(c, refl), P.paint(c), P.foil(c),
P.neon(c, t), P.glass(c, t), P.forcefield(c, t), P.crystal(c, t), P.stone(c, mat), P.fabric(c), P.leather(c),
P.wood(c)`, `P.with(style, {Color=...})`, `P.rgb(r,g,b)`, `P.lighten/darken/mix/vivid`.
Colores de rareza: `P.Rarity.Epic.Color` / `.Glow`.

## 5. Ciclo de trabajo (obligatorio)

```bash
cd break-a-vault
tools/check.sh SafeCracker            # valida (Lune) + renderiza → tools/render/out/SafeCracker.png
```
1. Mira el concepto: `concepts/hammers/<Id>.png` (Read).
2. Escribe el módulo. Corre `tools/check.sh <Id>`. Si truena, el error dice la línea/propiedad.
3. Abre `tools/render/out/<Id>.png` (Read) y compáralo con el concepto. Mínimo **3 iteraciones** de mejora:
   silueta → capas/materiales → brillo/movimiento/detalle fino.
4. Verifica que el build no marque `ERROR` (avisos de piezas se pueden justificar, pero respeta el límite duro).
5. Commit SOLO de tus archivos (nunca `git add -A`), con candado para no chocar con otros agentes:
```bash
flock /tmp/bav-git.lock -c 'git add src/ReplicatedStorage/HammerForge/Hammers/<Rareza>/<Id>.luau && git commit -q -m "Martillo <Id>" && git push -q'
```
(Si `git push` falla por red, reintenta 3 veces con espera.)

### Sobre el visor
Es una aproximación: geometría exacta, materiales aproximados (CorrodedMetal/Slate/Wood usan texturas
procedurales), neón con bloom parecido al de Roblox con BloomEffect. No te obsesiones con el color exacto
del material; sí con silueta, capas, contraste, brillo y movimiento.

## 6. Errores comunes
- `X is not a valid member of Part` → typo de propiedad. `The enum item ... does not exist` → typo de Enum.
- No uses `game:GetService` ni `workspace` dentro de `Build` (el build corre fuera de Roblox).
- `Ball` siempre esférica (usa diámetro). Cilindro: diámetro = Y = Z.
- No toques archivos de otros martillos ni `Builder.luau`/`Palette.luau`/`FX.luau`/`init.luau`.
  Si necesitas un helper, defínelo como función local dentro de tu archivo.
