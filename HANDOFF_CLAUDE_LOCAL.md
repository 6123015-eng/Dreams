# Break a Vault — Traspaso de martillos (nube → Claude local)

> **Estado real = los archivos que existan en `break-a-vault/src/ReplicatedStorage/HammerForge/Hammers/`
> y el `git log` de la rama.** Cada martillo terminado tiene su propio commit "Martillo <Id>".
>
> **Para el usuario:** si la sesión en la nube se cortó (créditos, error, lo que sea), copia
> TODO el bloque "PROMPT PARA CLAUDE LOCAL" de abajo y pégaselo a tu Claude local
> (el que está conectado a Roblox Studio por MCP). Este archivo se actualiza cada vez
> que se termina algo, así que siempre refleja lo último.

## Estado actual

- [x] Plan y estructura del proyecto subidos (`break-a-vault/`)
- [x] Imágenes de concepto guardadas en `break-a-vault/concepts/` (y recortes por martillo en `concepts/hammers/`)
- [x] Fábrica de martillos (`HammerForge`: Builder, Palette, FX, init) + build con Lune + visor 3D
- [x] Guía de modelado: `break-a-vault/docs/MODELING_GUIDE.md`
- [x] Rusty Hammer (primera versión de referencia)
- [x] Martillos Starter (4) · Uncommon (4)
- [x] Martillos Rare (4) · Epic (4)
- [x] Martillos Legendary (4) · Mythic (4)
- [x] Martillos Special & Event (8)
- [x] Revisión de director de arte + pulido de los 11 más flojos
- [x] `break-a-vault/dist/BreakAVault_Hammers.rbxm` y `BreakAVault_Showcase.rbxl` (los 32)
- [x] Vista previa 3D publicada: https://claude.ai/artifact/KduHYx4Kbo2tj8xkSAAugN
- [x] Mangos más gruesos y chaparros + pomos más grandes en los 32 (commits "Mango <Id>")
- [x] Thunder Core con firma propia (orbe grande, anillo giratorio, rayos más gruesos); Shock Hammer con menos rayos

## Pendientes de calidad (si la nube no alcanzó)

1. **Thunder Core** brilla muchísimo en la vista previa; en Studio confirma que el orbe no se vea
   como una mancha blanca (baja Brightness de su luz o sube la transparencia del neón si hace falta).
2. **Revisar en Studio** (el visor es una aproximación): colores de mármol/oro/vidrio, que las formas
   hechas con WedgeParts (picos, alas, flamas, coronas, franjas) no salgan invertidas, y el brillo del
   neón con BloomEffect.

## Qué es esto

El juego de Roblox **Break a Vault** se trabaja entre dos IAs:
- **Claude** = todo lo visual (modelos, efectos, UI).
- **Codex** = todo lo funcional (daño, datos, tienda, etc.).

Esta parte son **los 32 martillos** de las 4 hojas de concepto, rehechos para que se
vean premium ("dopamínicos"), no plásticos: materiales reales de Roblox, bordes biselados,
remaches, vendas, neón con glow, luces, partículas, piezas animadas (engranes que giran,
anillos que orbitan, núcleos que laten) y efectos de golpe.

Todo se genera **por código** (Luau), así que se puede reconstruir y modificar.

## Martillos (32)

| Rareza | Martillos |
|---|---|
| Starter | Rusty Hammer, Wooden Mallet, Iron Breaker, Yellow Construction Hammer |
| Uncommon | Steel Sledge, Spike Hammer, Reinforced Hammer, Safe Cracker |
| Rare | Diamond Crusher, Plasma Hammer, Vault Buster, Nitro Sledge |
| Epic | Shock Hammer, Ruby Mauler, Cyber Hammer, Elite Breacher |
| Legendary | Golden Titan, Obsidian Breaker, Dragon Maul, Inferno Hammer |
| Mythic | Frostbane Hammer, Thunder Core Hammer, Celestial Crusher, Void Smasher |
| Special & Event | Toxic Hammer, Neon Reactor Hammer, Magma Pounder, Crystal Shatter Hammer, Steampunk Crusher, Radioactive Sledge, Pixel Smash Hammer, Cosmic Vaultbreaker |

## Dónde está todo

Repositorio: `https://github.com/6123015-eng/Dreams` — rama `claude/dreamy-wright-vjz0hp`

```
break-a-vault/
  concepts/                      ← las 4 hojas de concepto originales
  src/ReplicatedStorage/HammerForge/
    init.luau                    ← API: HammerForge.Build(nombre), BuildAll(), List()
    Builder.luau                 ← primitivas (bloques biselados, remaches, picos, gemas…)
    Palette.luau                 ← colores/materiales por rareza
    FX.luau                      ← animaciones en cliente (giro, pulso, parpadeo) + golpe
    Hammers/<Rareza>/<Martillo>.luau   ← un archivo por martillo
  src/StarterPlayer/StarterPlayerScripts/HammerFXClient.client.luau
  tools/build.luau               ← (Lune) construye todo y exporta el .rbxm
  dist/BreakAVault_Hammers.rbxm  ← arrastrar a Studio
```

---

## PROMPT PARA CLAUDE LOCAL

```
Hola. Vengo de una sesión de Claude en la nube que estuvo rehaciendo los modelos de los
32 martillos de Break a Vault. Tú estás conectado a Roblox Studio por MCP, así que te
toca meterlos al juego.

1. Clona o actualiza el repo https://github.com/6123015-eng/Dreams en la rama
   claude/dreamy-wright-vjz0hp y lee HANDOFF_CLAUDE_LOCAL.md (sección "Estado actual")
   para ver qué martillos ya están terminados.

   La lista definitiva de terminados = archivos en
   break-a-vault/src/ReplicatedStorage/HammerForge/Hammers/ (cada uno con commit "Martillo <Id>").
   Lee también break-a-vault/docs/MODELING_GUIDE.md (convenciones y reglas de calidad).

2. Si dist/BreakAVault_Hammers.rbxm está desactualizado (más viejo que el último martillo),
   regenéralo: instala Lune (cargo install lune --locked, o rokit/aftman) y corre
   `cd break-a-vault && lune run tools/build.luau`. También genera
   dist/BreakAVault_Showcase.rbxl: un lugar de prueba con todos los martillos en vitrina.

3. Mete los martillos a Studio. Opción A (rápida): inserta
   break-a-vault/dist/BreakAVault_Hammers.rbxm en el lugar (contiene la carpeta
   HammerForge con los ModuleScripts, la carpeta Hammers con los Tools ya construidos
   y el LocalScript HammerFXClient). Opción B: crea por MCP los ModuleScripts con el
   contenido de break-a-vault/src/ (misma jerarquía) y llama
   require(ReplicatedStorage.HammerForge).BuildAll() para generar los Tools.
   - HammerForge → ReplicatedStorage
   - Hammers (Tools) → ReplicatedStorage (o ServerStorage si Codex lo prefiere)
   - HammerFXClient → StarterPlayer.StarterPlayerScripts

4. Revisa cada martillo en Studio (Play) y ajusta lo visual que se vea mal en el motor
   real (escala en la mano, Grip, brillo del neón, cantidad de partículas). Notas:
   - Builder.GRIP controla cómo se sostiene (una sola línea en Builder.luau).
   - Las formas con WedgeParts (picos, símbolos, cristales) asumen que la rampa de una
     WedgePart sube de (abajo, -Z) a (arriba, +Z). Si en Studio salen invertidas, el
     arreglo es solo en Builder:triangle().
   - Para que el neón brille como en la vista previa, Lighting necesita BloomEffect
     (ver la vitrina .rbxl: Intensity 0.9, Size 30, Threshold 0.9) y EnvironmentSpecularScale = 1.

5. Los martillos que la sesión en la nube NO alcanzó a terminar,
   hazlos tú siguiendo docs/MODELING_GUIDE.md: usa Builder.luau y copia la estructura de los
   que ya existen en Hammers/. Referencia visual en break-a-vault/concepts/hammers/<Id>.png.

6. Asigna cada martillo a su zona (Starter Yard, Bank Alley, Steel Factory, Gold Vault,
   Frozen Vault, Cyber Lab, Volcano Vault) para que el tema visual concuerde.

7. Al terminar, dame un prompt para Codex con el contrato de la API de efectos
   (está en la sección "Contrato para Codex" de HANDOFF_CLAUDE_LOCAL.md) para que él
   conecte el daño/golpes con HammerFX.
```

## Contrato para Codex (funcional)

Los martillos son `Tool` con tag `BAV_Hammer` y atributos: `HammerId`, `DisplayName`, `Rarity`,
`Order`, `RarityColor`, `PartCount`, `Theme`. Se construyen con
`require(ReplicatedStorage.HammerForge).Build(id)` o se clonan de la carpeta `Hammers`.
Los stats (daño, velocidad, precio) NO están en los modelos: son de Codex.

Efectos (módulo `ReplicatedStorage.HammerForge.FX`, ya iniciado por `HammerFXClient`):
- Cliente que golpea (feedback instantáneo): `FX.Swing(tool)` al empezar el swing y
  `FX.Impact(tool)` cuando conecta con la bóveda.
- Para que lo vean TODOS los jugadores, desde el servidor:
  `tool:SetAttribute("FX_SwingSeq", (tool:GetAttribute("FX_SwingSeq") or 0) + 1)` y
  `tool:SetAttribute("FX_ImpactSeq", (tool:GetAttribute("FX_ImpactSeq") or 0) + 1)`.
- `FX.OnImpact` (evento) para sacudir cámara o poner sonido.
- `FX.AutoSwing = true` muestra el trail al hacer clic aunque no se llame Swing (se puede apagar).
