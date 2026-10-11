--[[
	HammerForge.Palette
	Colores y "estilos" (color + material + reflectancia) que usan todos los martillos.

	Un estilo es una tabla:
		{ Color = Color3, Material = Enum.Material, Reflectance = number?, Transparency = number?, CastShadow = boolean? }

	Regla de oro para que NO se vea plástico:
	  * Nunca uses Plastic/SmoothPlastic para metal, madera o piedra.
	  * Metal casi negro + bordes más claros (bisel) = lectura de volumen.
	  * El neón siempre "dentro" de algo (ranuras, tubos de vidrio, grietas), nunca suelto.
	  * Usa 2–3 materiales por martillo y 1 color de acento fuerte.
]]

local Palette = {}

export type Style = {
	Color: Color3,
	Material: Enum.Material,
	Reflectance: number?,
	Transparency: number?,
	CastShadow: boolean?,
}

local function rgb(r: number, g: number, b: number): Color3
	return Color3.fromRGB(r, g, b)
end
Palette.rgb = rgb

--- Crea un estilo.
function Palette.style(color: Color3, material: Enum.Material?, reflectance: number?, transparency: number?): Style
	return {
		Color = color,
		Material = material or Enum.Material.Metal,
		Reflectance = reflectance or 0,
		Transparency = transparency or 0,
	}
end

--- Copia un estilo cambiando campos: Palette.with(Palette.Steel, { Color = ... })
function Palette.with(base: Style, overrides: { [string]: any }): Style
	local s = table.clone(base)
	for k, v in overrides do
		s[k] = v
	end
	return s
end

-- ── Utilidades de color ────────────────────────────────────────────────

function Palette.mix(a: Color3, b: Color3, t: number): Color3
	return a:Lerp(b, t)
end

function Palette.lighten(c: Color3, t: number): Color3
	return c:Lerp(Color3.new(1, 1, 1), t)
end

function Palette.darken(c: Color3, t: number): Color3
	return c:Lerp(Color3.new(0, 0, 0), t)
end

--- Sube saturación/brillo para neón (el neón de Roblox se ve mejor con colores muy saturados).
function Palette.vivid(c: Color3, boost: number?): Color3
	local h, s, v = c:ToHSV()
	local k = boost or 0.25
	return Color3.fromHSV(h, math.clamp(s + k, 0, 1), math.clamp(v + k, 0, 1))
end

-- ── Generadores de estilo ──────────────────────────────────────────────

function Palette.metal(color: Color3, reflectance: number?): Style
	return Palette.style(color, Enum.Material.Metal, reflectance or 0.12)
end

function Palette.paint(color: Color3): Style
	-- metal pintado: color fuerte pero con microdetalle del material Metal
	return Palette.style(color, Enum.Material.Metal, 0.04)
end

function Palette.foil(color: Color3, reflectance: number?): Style
	return Palette.style(color, Enum.Material.Foil, reflectance or 0.25)
end

function Palette.neon(color: Color3, transparency: number?): Style
	local s = Palette.style(color, Enum.Material.Neon, 0, transparency or 0)
	s.CastShadow = false
	return s
end

function Palette.glass(color: Color3, transparency: number?, reflectance: number?): Style
	local s = Palette.style(color, Enum.Material.Glass, reflectance or 0.25, transparency or 0.45)
	s.CastShadow = false
	return s
end

function Palette.forcefield(color: Color3, transparency: number?): Style
	local s = Palette.style(color, Enum.Material.ForceField, 0, transparency or 0)
	s.CastShadow = false
	return s
end

function Palette.crystal(color: Color3, transparency: number?): Style
	-- cristal facetado: Glass con un poco de transparencia y reflejo alto
	local s = Palette.style(color, Enum.Material.Glass, 0.35, transparency or 0.2)
	s.CastShadow = false
	return s
end

function Palette.stone(color: Color3, material: Enum.Material?): Style
	return Palette.style(color, material or Enum.Material.Slate, 0)
end

function Palette.fabric(color: Color3): Style
	return Palette.style(color, Enum.Material.Fabric, 0)
end

function Palette.leather(color: Color3): Style
	return Palette.style(color, Enum.Material.Leather, 0)
end

function Palette.wood(color: Color3, planks: boolean?): Style
	return Palette.style(color, if planks then Enum.Material.WoodPlanks else Enum.Material.Wood, 0)
end

--- Estilo invisible (para volúmenes de partículas, centros de pivote, etc.)
Palette.Invisible = {
	Color = rgb(255, 255, 255),
	Material = Enum.Material.SmoothPlastic,
	Reflectance = 0,
	Transparency = 1,
	CastShadow = false,
} :: Style

-- ── Rarezas (colores del HUD) ──────────────────────────────────────────

Palette.RarityOrder = { "Starter", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Special" }

Palette.Rarity = {
	Starter = { Color = rgb(159, 182, 204), Glow = rgb(190, 214, 235), Label = "STARTER" },
	Uncommon = { Color = rgb(79, 208, 107), Glow = rgb(124, 242, 154), Label = "UNCOMMON" },
	Rare = { Color = rgb(58, 166, 255), Glow = rgb(127, 220, 255), Label = "RARE" },
	Epic = { Color = rgb(180, 114, 255), Glow = rgb(214, 170, 255), Label = "EPIC" },
	Legendary = { Color = rgb(255, 194, 59), Glow = rgb(255, 228, 154), Label = "LEGENDARY" },
	Mythic = { Color = rgb(255, 77, 94), Glow = rgb(255, 150, 160), Label = "MYTHIC" },
	Special = { Color = rgb(170, 90, 255), Glow = rgb(255, 154, 46), Label = "SPECIAL & EVENT" },
}

-- ── Materiales base ───────────────────────────────────────────────────
-- Metales
Palette.Iron = Palette.metal(rgb(96, 102, 112), 0.08)
Palette.DarkIron = Palette.metal(rgb(54, 58, 66), 0.06)
Palette.Blackened = Palette.metal(rgb(30, 32, 38), 0.05)
Palette.Gunmetal = Palette.style(rgb(44, 48, 56), Enum.Material.DiamondPlate, 0.06)
Palette.Steel = Palette.metal(rgb(150, 160, 172), 0.16)
Palette.BrightSteel = Palette.metal(rgb(198, 206, 216), 0.22)
Palette.Chrome = Palette.foil(rgb(222, 228, 236), 0.32)
Palette.Rust = Palette.style(rgb(146, 74, 38), Enum.Material.CorrodedMetal, 0)
Palette.RustDark = Palette.style(rgb(98, 50, 28), Enum.Material.CorrodedMetal, 0)
Palette.RustOrange = Palette.style(rgb(184, 98, 46), Enum.Material.CorrodedMetal, 0)
Palette.Gold = Palette.foil(rgb(255, 192, 58), 0.22)
Palette.GoldDeep = Palette.metal(rgb(212, 140, 28), 0.18)
Palette.GoldPale = Palette.foil(rgb(255, 222, 140), 0.25)
Palette.Brass = Palette.metal(rgb(198, 150, 72), 0.16)
Palette.Copper = Palette.metal(rgb(186, 106, 60), 0.14)
Palette.Bronze = Palette.metal(rgb(140, 92, 52), 0.1)

-- Pinturas industriales
Palette.HazardYellow = Palette.paint(rgb(255, 196, 28))
Palette.HazardBlack = Palette.paint(rgb(26, 26, 30))
Palette.SafetyRed = Palette.paint(rgb(204, 38, 38))
Palette.SignalBlue = Palette.paint(rgb(30, 110, 220))

-- Madera, cuero, tela
Palette.Wood = Palette.wood(rgb(156, 98, 56))
Palette.WoodLight = Palette.wood(rgb(200, 140, 84), true)
Palette.WoodDark = Palette.wood(rgb(96, 58, 32))
Palette.Leather = Palette.leather(rgb(112, 64, 38))
Palette.LeatherDark = Palette.leather(rgb(58, 36, 26))
Palette.LeatherRed = Palette.leather(rgb(132, 34, 30))
Palette.Bandage = Palette.fabric(rgb(222, 204, 166))
Palette.GripBlack = Palette.fabric(rgb(30, 32, 38))
Palette.GripRubber = Palette.leather(rgb(24, 25, 30))

-- Piedra y elementos
Palette.Stone = Palette.stone(rgb(110, 112, 118), Enum.Material.Slate)
Palette.DarkStone = Palette.stone(rgb(52, 50, 58), Enum.Material.Basalt)
Palette.Obsidian = Palette.style(rgb(24, 18, 34), Enum.Material.Basalt, 0.1)
Palette.Lava = Palette.style(rgb(70, 36, 26), Enum.Material.CrackedLava, 0)
Palette.Marble = Palette.stone(rgb(238, 234, 226), Enum.Material.Marble)
Palette.Ice = Palette.style(rgb(160, 214, 255), Enum.Material.Ice, 0.1)
Palette.Glacier = Palette.style(rgb(120, 190, 240), Enum.Material.Glacier, 0.1)

return Palette
