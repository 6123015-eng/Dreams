# Break a Vault — Traspaso de martillos (nube → Claude local)

> **Para el usuario:** si la sesión en la nube se cortó (créditos, error, lo que sea), copia
> TODO el bloque "PROMPT PARA CLAUDE LOCAL" de abajo y pégaselo a tu Claude local
> (el que está conectado a Roblox Studio por MCP). Este archivo se actualiza cada vez
> que se termina algo, así que siempre refleja lo último.

## Estado actual

- [x] Plan y estructura del proyecto subidos (`break-a-vault/`)
- [x] Imágenes de concepto guardadas en `break-a-vault/concepts/`
- [ ] Fábrica de martillos (`HammerForge`: Builder, Palette, FX)
- [ ] Martillos Starter (4) · Uncommon (4)
- [ ] Martillos Rare (4) · Epic (4)
- [ ] Martillos Legendary (4) · Mythic (4)
- [ ] Martillos Special & Event (8)
- [ ] Archivo final `break-a-vault/dist/BreakAVault_Hammers.rbxm`
- [ ] Vista previa 3D publicada

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

2. Mete los martillos a Studio. Opción A (rápida): inserta
   break-a-vault/dist/BreakAVault_Hammers.rbxm en el lugar (contiene la carpeta
   HammerForge con los ModuleScripts, la carpeta Hammers con los Tools ya construidos
   y el LocalScript HammerFXClient). Opción B: crea por MCP los ModuleScripts con el
   contenido de break-a-vault/src/ (misma jerarquía) y llama
   require(ReplicatedStorage.HammerForge).BuildAll() para generar los Tools.
   - HammerForge → ReplicatedStorage
   - Hammers (Tools) → ReplicatedStorage (o ServerStorage si Codex lo prefiere)
   - HammerFXClient → StarterPlayer.StarterPlayerScripts

3. Revisa cada martillo en Studio (Play) y ajusta lo visual que se vea mal en el motor
   real (escala en la mano, Grip, brillo del neón, cantidad de partículas).

4. Los martillos que la sesión en la nube NO alcanzó a terminar (ver "Estado actual"),
   hazlos tú siguiendo el mismo estilo: usa Builder.luau y copia la estructura de los
   que ya existen en Hammers/. Referencia visual en break-a-vault/concepts/.

5. Asigna cada martillo a su zona (Starter Yard, Bank Alley, Steel Factory, Gold Vault,
   Frozen Vault, Cyber Lab, Volcano Vault) para que el tema visual concuerde.

6. Al terminar, dame un prompt para Codex con el contrato de la API de efectos
   (está en la sección "Contrato para Codex" de HANDOFF_CLAUDE_LOCAL.md) para que él
   conecte el daño/golpes con HammerFX.
```

## Contrato para Codex (funcional)

_(Se completa cuando quede lista la API de FX.)_
