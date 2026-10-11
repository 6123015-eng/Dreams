--[[
	HammerForge.Builder
	Primitivas para construir martillos con partes de Roblox (sin mallas ni texturas externas).

	ESPACIO DEL MODELO (todas las coordenadas que recibe el Builder):
	  * Origen = centro del agarre (donde va la mano). El "Handle" (invisible) está ahí con rotación identidad.
	  * +Y = hacia la cabeza (el mango corre a lo largo de Y).
	  * La cabeza se extiende a lo largo de X (caras de golpe en +X / -X).
	  * Las caras "de emblema" (las que se ven en las hojas de concepto) miran a +Z / -Z.
	  * Unidades = studs a escala 1. Ver Builder.Anatomy para proporciones estándar.

	Todo se suelda al Handle con Welds (C0 explícito) para que el .rbxm sea determinista.
	Las piezas animadas usan un Weld llamado "FXWeld" con atributos que lee HammerForge.FX.
]]

local Palette = require(script.Parent.Palette)

type Style = Palette.Style

local Builder = {}
Builder.__index = Builder

-- Rotación del agarre: la cara -X queda hacia el frente del personaje al sostenerlo.
-- Si en Studio el martillo sale de lado, ajusta SOLO esta línea.
Builder.GRIP = CFrame.Angles(0, math.rad(90), 0)
Builder.TAG = "BAV_Hammer"

--- Proporciones estándar (escala 1). Los martillos pueden salirse de esto, pero sirve de guía.
Builder.Anatomy = table.freeze({
	GripLength = 1.8, -- largo del Handle (zona de la mano), centrado en Y = 0
	ShaftDia = 0.36, -- diámetro del mango
	ShaftBottom = -1.25, -- donde termina el mango abajo (arriba del pomo)
	PommelY = -1.45, -- centro del pomo
	HeadY = 3.35, -- centro de la cabeza
	HeadW = 3.3, -- largo de la cabeza (X)
	HeadH = 1.9, -- alto de la cabeza (Y)
	HeadD = 1.9, -- grosor de la cabeza (Z)
})

Builder.Textures = table.freeze({
	Sparkle = "rbxasset://textures/particles/sparkles_main.dds",
	Fire = "rbxasset://textures/particles/fire_main.dds",
	FireSparks = "rbxasset://textures/particles/fire_sparks_main.dds",
	Smoke = "rbxasset://textures/particles/smoke_main.dds",
	Glow = "rbxasset://textures/particles/forcefield_glow_main.dds",
})

local TAU = math.pi * 2
local MIN_SIZE = 0.001

-- ── helpers internos ─────────────────────────────────────────────────

local function toCF(x: CFrame | Vector3): CFrame
	if typeof(x) == "Vector3" then
		return CFrame.new(x :: Vector3)
	end
	return x :: CFrame
end

local function rotOnly(cf: CFrame): CFrame
	return cf - cf.Position
end

local function clampSize(v: Vector3): Vector3
	return Vector3.new(math.max(v.X, MIN_SIZE), math.max(v.Y, MIN_SIZE), math.max(v.Z, MIN_SIZE))
end

local function applyStyle(p: BasePart, style: Style?)
	local s = style or Palette.Iron
	p.Color = s.Color
	p.Material = s.Material
	p.Reflectance = s.Reflectance or 0
	p.Transparency = s.Transparency or 0
	if s.CastShadow == false then
		p.CastShadow = false
	end
end

local function scaleSequence(seq: NumberSequence, k: number): NumberSequence
	local kps = {}
	for _, kp in seq.Keypoints do
		table.insert(kps, NumberSequenceKeypoint.new(kp.Time, kp.Value * k, kp.Envelope * k))
	end
	return NumberSequence.new(kps)
end

--- NumberSequence rápida: Builder.seq(0, 0.5, 1, 0) -> keypoints (t=0,v=0.5) (t=1,v=0)
function Builder.seq(...: number): NumberSequence
	local args = { ... }
	if #args == 1 then
		return NumberSequence.new(args[1])
	end
	local kps = {}
	for i = 1, #args, 2 do
		table.insert(kps, NumberSequenceKeypoint.new(args[i], args[i + 1]))
	end
	return NumberSequence.new(kps)
end

--- ColorSequence rápida: Builder.colors(c1) | Builder.colors(c1, c2) | Builder.colors({0,c1},{0.5,c2},{1,c3})
function Builder.colors(...: any): ColorSequence
	local args = { ... }
	if #args == 1 and typeof(args[1]) == "Color3" then
		return ColorSequence.new(args[1])
	elseif #args == 2 and typeof(args[1]) == "Color3" then
		return ColorSequence.new(args[1], args[2])
	end
	local kps = {}
	for _, pair in args do
		table.insert(kps, ColorSequenceKeypoint.new(pair[1], pair[2]))
	end
	return ColorSequence.new(kps)
end

--- Generador pseudoaleatorio determinista (mismo resultado en cada build).
function Builder.rng(seed: number)
	local state = (seed or 1) % 2147483647
	if state <= 0 then
		state += 2147483646
	end
	return function(a: number?, b: number?): number
		state = (state * 16807) % 2147483647
		local r = (state - 1) / 2147483646
		if a and b then
			return a + (b - a) * r
		end
		return r
	end
end

--- Llama fn(1) y fn(-1). Para simetría: Builder.both(function(s) ... CFrame.new(s * 1.2, y, 0) ... end)
function Builder.both(fn: (number) -> ())
	fn(1)
	fn(-1)
end

--- Plano sobre una cara ±Z de la cabeza (local XY = superficie, local Z = normal hacia afuera).
function Builder.faceZ(sign: number, y: number, z: number, x: number?): CFrame
	local cf = CFrame.new(x or 0, y, sign * z)
	if sign < 0 then
		cf *= CFrame.Angles(0, math.pi, 0)
	end
	return cf
end

--- Plano sobre una cara ±X (tapa de golpe). local Z = normal hacia afuera.
function Builder.faceX(sign: number, x: number, y: number, z: number?): CFrame
	return CFrame.new(sign * x, y, z or 0) * CFrame.Angles(0, sign * math.pi / 2, 0)
end

-- ── Formas 2D (listas de Vector2) ────────────────────────────────────

local Shapes = {}
Builder.Shapes = Shapes

function Shapes.circle(r: number, n: number?, rot: number?): { Vector2 }
	local pts = {}
	local count = n or 16
	for i = 0, count - 1 do
		local a = (rot or 0) + TAU * i / count
		table.insert(pts, Vector2.new(math.cos(a) * r, math.sin(a) * r))
	end
	return pts
end

function Shapes.star(points: number, rOuter: number, rInner: number, rot: number?): { Vector2 }
	local pts = {}
	local base = (rot or 0) + math.pi / 2
	for i = 0, points * 2 - 1 do
		local r = if i % 2 == 0 then rOuter else rInner
		local a = base + math.pi * i / points
		table.insert(pts, Vector2.new(math.cos(a) * r, math.sin(a) * r))
	end
	return pts
end

function Shapes.rect(w: number, h: number): { Vector2 }
	return { Vector2.new(-w / 2, -h / 2), Vector2.new(w / 2, -h / 2), Vector2.new(w / 2, h / 2), Vector2.new(-w / 2, h / 2) }
end

function Shapes.rhombus(w: number, h: number): { Vector2 }
	return { Vector2.new(0, -h / 2), Vector2.new(w / 2, 0), Vector2.new(0, h / 2), Vector2.new(-w / 2, 0) }
end

function Shapes.triangle(w: number, h: number): { Vector2 }
	return { Vector2.new(-w / 2, -h / 2), Vector2.new(w / 2, -h / 2), Vector2.new(0, h / 2) }
end

--- Rayo (zigzag) de alto h y ancho w, centrado.
function Shapes.bolt(w: number, h: number): { Vector2 }
	local raw = {
		{ 0.18, 0.5 },
		{ -0.32, -0.04 },
		{ -0.02, -0.04 },
		{ -0.2, -0.5 },
		{ 0.34, 0.08 },
		{ 0.04, 0.08 },
	}
	local pts = {}
	for _, p in raw do
		table.insert(pts, Vector2.new(p[1] * w / 0.68, p[2] * h))
	end
	return pts
end

--- Flama estilizada (para Nitro / Inferno).
function Shapes.flame(w: number, h: number): { Vector2 }
	local raw = {
		{ 0.0, -0.5 },
		{ 0.32, -0.38 },
		{ 0.46, -0.12 },
		{ 0.4, 0.14 },
		{ 0.24, 0.32 },
		{ 0.22, 0.08 },
		{ 0.1, 0.22 },
		{ 0.04, 0.5 },
		{ -0.14, 0.26 },
		{ -0.3, 0.06 },
		{ -0.44, -0.12 },
		{ -0.34, -0.38 },
	}
	local pts = {}
	for _, p in raw do
		table.insert(pts, Vector2.new(p[1] * w, p[2] * h))
	end
	return pts
end

--- Corona (para Elite Breacher).
function Shapes.crown(w: number, h: number): { Vector2 }
	local raw = {
		{ -0.5, -0.5 },
		{ 0.5, -0.5 },
		{ 0.5, 0.3 },
		{ 0.27, 0.0 },
		{ 0.0, 0.5 },
		{ -0.27, 0.0 },
		{ -0.5, 0.3 },
	}
	local pts = {}
	for _, p in raw do
		table.insert(pts, Vector2.new(p[1] * w, p[2] * h))
	end
	return pts
end

--- Sector de anillo (aspas del símbolo de radiación, etc.). Ángulos en radianes.
function Shapes.sector(r1: number, r2: number, a0: number, a1: number, n: number?): { Vector2 }
	local pts = {}
	local steps = n or 6
	for i = 0, steps do
		local a = a0 + (a1 - a0) * i / steps
		table.insert(pts, Vector2.new(math.cos(a) * r2, math.sin(a) * r2))
	end
	for i = steps, 0, -1 do
		local a = a0 + (a1 - a0) * i / steps
		table.insert(pts, Vector2.new(math.cos(a) * r1, math.sin(a) * r1))
	end
	return pts
end

--- Recorta un polígono convexo/simple contra un rectángulo centrado (Sutherland–Hodgman).
function Shapes.clipRect(poly: { Vector2 }, w: number, h: number): { Vector2 }
	local function clip(pts: { Vector2 }, inside: (Vector2) -> boolean, intersect: (Vector2, Vector2) -> Vector2)
		local out = {}
		for i = 1, #pts do
			local cur = pts[i]
			local prev = pts[(i - 2) % #pts + 1]
			local cin, pin = inside(cur), inside(prev)
			if cin then
				if not pin then
					table.insert(out, intersect(prev, cur))
				end
				table.insert(out, cur)
			elseif pin then
				table.insert(out, intersect(prev, cur))
			end
		end
		return out
	end
	local function lerpX(a: Vector2, b: Vector2, x: number)
		local t = (x - a.X) / (b.X - a.X)
		return Vector2.new(x, a.Y + (b.Y - a.Y) * t)
	end
	local function lerpY(a: Vector2, b: Vector2, y: number)
		local t = (y - a.Y) / (b.Y - a.Y)
		return Vector2.new(a.X + (b.X - a.X) * t, y)
	end
	local hw, hh = w / 2, h / 2
	local pts = poly
	pts = clip(pts, function(p) return p.X >= -hw end, function(a, b) return lerpX(a, b, -hw) end)
	if #pts == 0 then return pts end
	pts = clip(pts, function(p) return p.X <= hw end, function(a, b) return lerpX(a, b, hw) end)
	if #pts == 0 then return pts end
	pts = clip(pts, function(p) return p.Y >= -hh end, function(a, b) return lerpY(a, b, -hh) end)
	if #pts == 0 then return pts end
	pts = clip(pts, function(p) return p.Y <= hh end, function(a, b) return lerpY(a, b, hh) end)
	return pts
end

--- Triangulación por "ear clipping" de un polígono simple (sin auto-intersecciones).
function Shapes.triangulate(poly: { Vector2 }): { { Vector2 } }
	local pts = table.clone(poly)
	-- orientar CCW
	local area = 0
	for i = 1, #pts do
		local a, b = pts[i], pts[i % #pts + 1]
		area += a.X * b.Y - b.X * a.Y
	end
	if area < 0 then
		local rev = {}
		for i = #pts, 1, -1 do
			table.insert(rev, pts[i])
		end
		pts = rev
	end
	local function cross(o: Vector2, a: Vector2, b: Vector2)
		return (a.X - o.X) * (b.Y - o.Y) - (a.Y - o.Y) * (b.X - o.X)
	end
	local function inTri(p: Vector2, a: Vector2, b: Vector2, c: Vector2)
		return cross(a, b, p) >= -1e-9 and cross(b, c, p) >= -1e-9 and cross(c, a, p) >= -1e-9
	end
	local tris = {}
	local guard = 0
	while #pts > 3 and guard < 1000 do
		guard += 1
		local found = false
		for i = 1, #pts do
			local a = pts[(i - 2) % #pts + 1]
			local b = pts[i]
			local c = pts[i % #pts + 1]
			if cross(a, b, c) > 1e-9 then
				local ear = true
				for j = 1, #pts do
					local p = pts[j]
					if p ~= a and p ~= b and p ~= c and inTri(p, a, b, c) then
						ear = false
						break
					end
				end
				if ear then
					table.insert(tris, { a, b, c })
					table.remove(pts, i)
					found = true
					break
				end
			end
		end
		if not found then
			break
		end
	end
	if #pts == 3 then
		table.insert(tris, { pts[1], pts[2], pts[3] })
	end
	return tris
end

-- ── Partículas predefinidas (devuelven tablas de propiedades) ─────────

local Particles = {}
Builder.Particles = Particles
local TEX = Builder.Textures

--- Destellos suaves alrededor (rarezas Rare+).
function Particles.sparkle(color: Color3, rate: number?): { [string]: any }
	return {
		Texture = TEX.Sparkle,
		Color = ColorSequence.new(Palette.lighten(color, 0.35), color),
		LightEmission = 1,
		LightInfluence = 0,
		Brightness = 2,
		Size = Builder.seq(0, 0, 0.2, 0.32, 1, 0),
		Transparency = Builder.seq(0, 0.1, 1, 1),
		Lifetime = NumberRange.new(0.6, 1.3),
		Rate = rate or 6,
		Speed = NumberRange.new(0.2, 0.9),
		SpreadAngle = Vector2.new(180, 180),
		Rotation = NumberRange.new(0, 360),
		RotSpeed = NumberRange.new(-120, 120),
	}
end

--- Chispas/brasas que suben (fuego, magma, forja).
function Particles.ember(color: Color3, rate: number?): { [string]: any }
	return {
		Texture = TEX.FireSparks,
		Color = Builder.colors({ 0, Palette.lighten(color, 0.5) }, { 0.4, color }, { 1, Palette.darken(color, 0.4) }),
		LightEmission = 1,
		LightInfluence = 0,
		Brightness = 3,
		Size = Builder.seq(0, 0.18, 1, 0),
		Transparency = Builder.seq(0, 0, 0.7, 0.2, 1, 1),
		Lifetime = NumberRange.new(0.7, 1.4),
		Rate = rate or 10,
		Speed = NumberRange.new(1, 2.5),
		Acceleration = Vector3.new(0, 3, 0),
		SpreadAngle = Vector2.new(35, 35),
		Drag = 1,
	}
end

--- Llama (textura de fuego), para Inferno / Dragon / Magma.
function Particles.flame(color: Color3, rate: number?): { [string]: any }
	return {
		Texture = TEX.Fire,
		Color = Builder.colors({ 0, Palette.lighten(color, 0.6) }, { 0.35, color }, { 1, Palette.darken(color, 0.55) }),
		LightEmission = 0.9,
		LightInfluence = 0,
		Brightness = 2.5,
		Size = Builder.seq(0, 0.5, 0.5, 0.8, 1, 0),
		Transparency = Builder.seq(0, 0.3, 0.6, 0.5, 1, 1),
		Lifetime = NumberRange.new(0.35, 0.7),
		Rate = rate or 25,
		Speed = NumberRange.new(1.5, 3),
		Acceleration = Vector3.new(0, 4, 0),
		Rotation = NumberRange.new(0, 360),
		RotSpeed = NumberRange.new(-60, 60),
		SpreadAngle = Vector2.new(15, 15),
	}
end

--- Humo/vapor.
function Particles.smoke(color: Color3, rate: number?): { [string]: any }
	return {
		Texture = TEX.Smoke,
		Color = ColorSequence.new(color),
		LightEmission = 0,
		LightInfluence = 0.6,
		Size = Builder.seq(0, 0.4, 1, 1.6),
		Transparency = Builder.seq(0, 0.6, 0.3, 0.75, 1, 1),
		Lifetime = NumberRange.new(1, 1.8),
		Rate = rate or 4,
		Speed = NumberRange.new(0.4, 1),
		Acceleration = Vector3.new(0, 1.2, 0),
		Rotation = NumberRange.new(0, 360),
		RotSpeed = NumberRange.new(-30, 30),
		SpreadAngle = Vector2.new(25, 25),
	}
end

--- Gotas que caen (tóxico, radiactivo, magma líquido).
function Particles.drip(color: Color3, rate: number?): { [string]: any }
	return {
		Texture = TEX.Glow,
		Color = ColorSequence.new(Palette.lighten(color, 0.3), color),
		LightEmission = 1,
		LightInfluence = 0,
		Brightness = 2,
		Size = Builder.seq(0, 0.22, 0.8, 0.16, 1, 0),
		Transparency = Builder.seq(0, 0, 0.8, 0.2, 1, 1),
		Lifetime = NumberRange.new(0.6, 1),
		Rate = rate or 4,
		Speed = NumberRange.new(0, 0.3),
		Acceleration = Vector3.new(0, -14, 0),
		EmissionDirection = Enum.NormalId.Bottom,
		SpreadAngle = Vector2.new(5, 5),
	}
end

--- Escarcha / nieve brillante que flota.
function Particles.frost(color: Color3, rate: number?): { [string]: any }
	return {
		Texture = TEX.Sparkle,
		Color = ColorSequence.new(Color3.new(1, 1, 1), color),
		LightEmission = 1,
		LightInfluence = 0,
		Brightness = 2,
		Size = Builder.seq(0, 0.25, 1, 0),
		Transparency = Builder.seq(0, 0.2, 1, 1),
		Lifetime = NumberRange.new(1, 2),
		Rate = rate or 8,
		Speed = NumberRange.new(0.2, 0.6),
		Acceleration = Vector3.new(0, -0.8, 0),
		SpreadAngle = Vector2.new(180, 180),
		Rotation = NumberRange.new(0, 360),
		RotSpeed = NumberRange.new(-45, 45),
		Drag = 2,
	}
end

--- Chispazos eléctricos rápidos.
function Particles.electric(color: Color3, rate: number?): { [string]: any }
	return {
		Texture = TEX.Sparkle,
		Color = ColorSequence.new(Color3.new(1, 1, 1), color),
		LightEmission = 1,
		LightInfluence = 0,
		Brightness = 4,
		Size = Builder.seq(0, 0.4, 1, 0),
		Transparency = Builder.seq(0, 0, 1, 1),
		Lifetime = NumberRange.new(0.08, 0.2),
		Rate = rate or 18,
		Speed = NumberRange.new(4, 9),
		SpreadAngle = Vector2.new(180, 180),
		Rotation = NumberRange.new(0, 360),
	}
end

--- Orbes de luz suaves que flotan (celestial, cósmico, void).
function Particles.orb(color: Color3, rate: number?): { [string]: any }
	return {
		Texture = TEX.Glow,
		Color = ColorSequence.new(color),
		LightEmission = 1,
		LightInfluence = 0,
		Brightness = 2,
		Size = Builder.seq(0, 0, 0.3, 0.35, 1, 0),
		Transparency = Builder.seq(0, 0.2, 1, 1),
		Lifetime = NumberRange.new(1.2, 2.2),
		Rate = rate or 5,
		Speed = NumberRange.new(0.1, 0.4),
		SpreadAngle = Vector2.new(180, 180),
		Drag = 1,
	}
end

--- Partículas que se "succionan" hacia la cabeza (void, cósmico). Usar en un fxVolume con forma esfera.
function Particles.implode(color: Color3, rate: number?): { [string]: any }
	return {
		Texture = TEX.Glow,
		Color = ColorSequence.new(Palette.lighten(color, 0.3), color),
		LightEmission = 1,
		LightInfluence = 0,
		Brightness = 2,
		Size = Builder.seq(0, 0.3, 1, 0.05),
		Transparency = Builder.seq(0, 1, 0.3, 0.2, 1, 0.8),
		Lifetime = NumberRange.new(0.6, 0.9),
		Rate = rate or 12,
		Speed = NumberRange.new(1.5, 2.5),
		Shape = Enum.ParticleEmitterShape.Sphere,
		ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface,
		ShapeInOut = Enum.ParticleEmitterShapeInOut.Inward,
	}
end

-- ── Constructor ──────────────────────────────────────────────────────

export type BuildOptions = {
	Scale: number?,
}

function Builder.new(def: { [string]: any }, options: BuildOptions?)
	local opts = options or {}
	local self = setmetatable({}, Builder)
	self.def = def
	self.scale = opts.Scale or 1
	self.count = 0
	self.emitterRate = 0
	self.lightCount = 0

	local tool = Instance.new("Tool")
	tool.Name = def.DisplayName or def.Id
	tool.CanBeDropped = false
	tool.RequiresHandle = true
	tool.ToolTip = def.DisplayName or def.Id
	local grip: CFrame = def.Grip or Builder.GRIP
	tool.Grip = CFrame.new(grip.Position * self.scale) * rotOnly(grip)
	self.tool = tool

	local h = Instance.new("Part")
	h.Name = "Handle"
	h.Size = Vector3.new(0.45, Builder.Anatomy.GripLength, 0.45) * self.scale
	h.CFrame = CFrame.new()
	h.Transparency = 1
	h.Material = Enum.Material.SmoothPlastic
	h.TopSurface = Enum.SurfaceType.Smooth
	h.BottomSurface = Enum.SurfaceType.Smooth
	h.Anchored = false
	h.CanCollide = false
	h.CanQuery = false
	h.CastShadow = false
	h.Parent = tool
	self.handle = h
	self.parent = tool
	return self
end

function Builder:_cf(cf: CFrame | Vector3): CFrame
	local c = toCF(cf)
	if self.scale == 1 then
		return c
	end
	return CFrame.new(c.Position * self.scale) * rotOnly(c)
end

function Builder:_weld(p: BasePart): Weld
	local w = Instance.new("Weld")
	w.Name = "W"
	w.C0 = self.handle.CFrame:Inverse() * p.CFrame
	w.C1 = CFrame.new()
	w.Part0 = self.handle
	w.Part1 = p
	w.Parent = p
	return w
end

function Builder:_new(className: string, shape: Enum.PartType?, size: Vector3, cf: CFrame | Vector3, style: Style?, name: string?): BasePart
	local p = Instance.new(className) :: BasePart
	p.Name = name or "Detail"
	if shape then
		local asPart: any = p
		asPart.Shape = shape
	end
	p.Size = clampSize(size * self.scale)
	p.CFrame = self:_cf(cf)
	applyStyle(p, style)
	p.Anchored = false
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.Massless = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = self.parent
	self:_weld(p)
	self.count += 1
	return p
end

--- Agrupa piezas en una carpeta (Head, Shaft, Emblem, FX...). Devuelve la carpeta.
function Builder:group(name: string, fn: () -> ()): Folder
	local f = Instance.new("Folder")
	f.Name = name
	f.Parent = self.parent
	local prev = self.parent
	self.parent = f
	fn()
	self.parent = prev
	return f
end

-- ── Primitivas básicas ───────────────────────────────────────────────

function Builder:box(size: Vector3, cf: CFrame | Vector3, style: Style?, name: string?): BasePart
	return self:_new("Part", nil, size, cf, style, name or "Block")
end

--- Cilindro con eje a lo largo de la X local de `cf` (eje nativo de Roblox).
function Builder:cylinder(length: number, diameter: number, cf: CFrame | Vector3, style: Style?, name: string?): BasePart
	return self:_new("Part", Enum.PartType.Cylinder, Vector3.new(length, diameter, diameter), cf, style, name or "Cylinder")
end

--- Cilindro con eje a lo largo de la Y local de `cf` (mangos, collares, discos horizontales).
function Builder:cylY(length: number, diameter: number, cf: CFrame | Vector3, style: Style?, name: string?): BasePart
	return self:cylinder(length, diameter, toCF(cf) * CFrame.Angles(0, 0, math.pi / 2), style, name)
end

--- Cilindro con eje a lo largo de la Z local de `cf` (discos sobre las caras de emblema).
function Builder:cylZ(length: number, diameter: number, cf: CFrame | Vector3, style: Style?, name: string?): BasePart
	return self:cylinder(length, diameter, toCF(cf) * CFrame.Angles(0, math.pi / 2, 0), style, name)
end

function Builder:ball(diameter: number, cf: CFrame | Vector3, style: Style?, name: string?): BasePart
	return self:_new("Part", Enum.PartType.Ball, Vector3.new(diameter, diameter, diameter), cf, style, name or "Ball")
end

--- WedgePart: la rampa sube de (abajo, frente -Z) a (arriba, atrás +Z). Cara vertical completa en +Z.
function Builder:wedge(size: Vector3, cf: CFrame | Vector3, style: Style?, name: string?): BasePart
	return self:_new("WedgePart", nil, size, cf, style, name or "Wedge")
end

--- Parte invisible (para emitir partículas desde un volumen, o como pivote).
function Builder:fxVolume(size: Vector3, cf: CFrame | Vector3, name: string?): BasePart
	local p = self:_new("Part", nil, size, cf, Palette.Invisible, name or "FXVolume")
	p.CastShadow = false
	return p
end

-- ── Primitivas compuestas ────────────────────────────────────────────

export type BevelOptions = {
	edges: string?, -- "all" (15 piezas) | "X" | "Y" | "Z" (6 piezas: solo aristas paralelas a ese eje)
	edgeStyle: Style?, -- estilo del bisel (p. ej. metal más claro para que "brille" la arista)
	corners: boolean?, -- rellena las 8 esquinas con esferas (solo "all")
	name: string?,
}

--- Bloque con aristas biseladas (chaflán a 45°). bevel = tamaño del chaflán en studs.
function Builder:bevelBox(size: Vector3, cf: CFrame | Vector3, style: Style?, bevel: number?, opts: BevelOptions?): { BasePart }
	local o = opts or {}
	local base = toCF(cf)
	local sx, sy, sz = size.X, size.Y, size.Z
	local mode = o.edges or "all"
	-- el chaflán solo depende de las dimensiones perpendiculares a las aristas biseladas
	local cross = if mode == "X" then math.min(sy, sz) elseif mode == "Y" then math.min(sx, sz) elseif mode == "Z" then math.min(sx, sy) else math.min(sx, sy, sz)
	local c = bevel or cross * 0.12
	c = math.min(c, cross * 0.45)
	local d = c * math.sqrt(2)
	local es = o.edgeStyle or style
	local name = o.name or "Block"
	local parts = {}
	local q = math.pi / 4

	local function add(p: BasePart)
		table.insert(parts, p)
	end

	if mode == "all" then
		add(self:box(Vector3.new(sx, sy - 2 * c, sz - 2 * c), base, style, name))
		add(self:box(Vector3.new(sx - 2 * c, sy, sz - 2 * c), base, style, name))
		add(self:box(Vector3.new(sx - 2 * c, sy - 2 * c, sz), base, style, name))
		for _, a in { -1, 1 } do
			for _, b in { -1, 1 } do
				add(self:box(Vector3.new(sx - 2 * c, d, d), base * CFrame.new(0, a * (sy / 2 - c), b * (sz / 2 - c)) * CFrame.Angles(q, 0, 0), es, name .. "Edge"))
				add(self:box(Vector3.new(d, sy - 2 * c, d), base * CFrame.new(a * (sx / 2 - c), 0, b * (sz / 2 - c)) * CFrame.Angles(0, q, 0), es, name .. "Edge"))
				add(self:box(Vector3.new(d, d, sz - 2 * c), base * CFrame.new(a * (sx / 2 - c), b * (sy / 2 - c), 0) * CFrame.Angles(0, 0, q), es, name .. "Edge"))
			end
		end
		if o.corners then
			for _, a in { -1, 1 } do
				for _, b in { -1, 1 } do
					for _, e in { -1, 1 } do
						add(self:ball(d, base * CFrame.new(a * (sx / 2 - c), b * (sy / 2 - c), e * (sz / 2 - c)), es, name .. "Corner"))
					end
				end
			end
		end
	elseif mode == "X" then
		add(self:box(Vector3.new(sx, sy - 2 * c, sz), base, style, name))
		add(self:box(Vector3.new(sx, sy, sz - 2 * c), base, style, name))
		for _, a in { -1, 1 } do
			for _, b in { -1, 1 } do
				add(self:box(Vector3.new(sx, d, d), base * CFrame.new(0, a * (sy / 2 - c), b * (sz / 2 - c)) * CFrame.Angles(q, 0, 0), es, name .. "Edge"))
			end
		end
	elseif mode == "Y" then
		add(self:box(Vector3.new(sx - 2 * c, sy, sz), base, style, name))
		add(self:box(Vector3.new(sx, sy, sz - 2 * c), base, style, name))
		for _, a in { -1, 1 } do
			for _, b in { -1, 1 } do
				add(self:box(Vector3.new(d, sy, d), base * CFrame.new(a * (sx / 2 - c), 0, b * (sz / 2 - c)) * CFrame.Angles(0, q, 0), es, name .. "Edge"))
			end
		end
	elseif mode == "Z" then
		add(self:box(Vector3.new(sx - 2 * c, sy, sz), base, style, name))
		add(self:box(Vector3.new(sx, sy - 2 * c, sz), base, style, name))
		for _, a in { -1, 1 } do
			for _, b in { -1, 1 } do
				add(self:box(Vector3.new(d, d, sz), base * CFrame.new(a * (sx / 2 - c), b * (sy / 2 - c), 0) * CFrame.Angles(0, 0, q), es, name .. "Edge"))
			end
		end
	else
		error("bevelBox: edges debe ser 'all', 'X', 'Y' o 'Z'")
	end
	return parts
end

--- Remache (media esfera saliendo de la superficie). `pos` = punto sobre la superficie.
function Builder:rivet(pos: Vector3 | CFrame, diameter: number?, style: Style?): BasePart
	return self:ball(diameter or 0.16, pos, style or Palette.BrightSteel, "Rivet")
end

--- Fila de `n` remaches entre p0 y p1 (incluidos).
function Builder:rivetLine(p0: Vector3, p1: Vector3, n: number, diameter: number?, style: Style?): { BasePart }
	local out = {}
	for i = 0, n - 1 do
		local t = if n == 1 then 0.5 else i / (n - 1)
		table.insert(out, self:rivet(p0:Lerp(p1, t), diameter, style))
	end
	return out
end

--- Disco/collar: cilindro corto cuyo eje es la Y local de `cf`.
function Builder:disc(cf: CFrame | Vector3, diameter: number, thickness: number, style: Style?, name: string?): BasePart
	return self:cylY(thickness, diameter, cf, style, name or "Disc")
end

--- Anillo (toro aproximado con `segments` bloques) en el plano XZ local de `cf` (eje = Y local).
function Builder:ring(cf: CFrame | Vector3, radius: number, tube: number, segments: number?, style: Style?, name: string?, width: number?): { BasePart }
	local base = toCF(cf)
	local n = segments or 16
	local segLen = TAU * radius / n * 1.08 + tube * 0.3
	local out = {}
	for i = 0, n - 1 do
		local th = TAU * i / n
		local pcf = base * CFrame.Angles(0, -th, 0) * CFrame.new(radius, 0, 0)
		table.insert(out, self:box(Vector3.new(tube, width or tube, segLen), pcf, style, name or "Ring"))
	end
	return out
end

--- Venda/agarre en espiral alrededor del eje Y (x=0,z=0 o el eje de opts.cf) entre y0 y y1.
function Builder:wrap(y0: number, y1: number, radius: number, turns: number, style: Style?, opts: { [string]: any }?): { BasePart }
	local o = opts or {}
	local base = if o.cf then toCF(o.cf) else CFrame.new()
	local perTurn = o.segmentsPerTurn or 8
	local n = math.max(3, math.floor(turns * perTurn + 0.5))
	local width = o.width or ((y1 - y0) / turns) * 0.8
	local thick = o.thickness or 0.05
	local height = y1 - y0
	local circ = TAU * radius
	local pitch = height / turns
	local alpha = math.atan(pitch / circ)
	local segLen = math.sqrt((circ / perTurn) ^ 2 + (pitch / perTurn) ^ 2) * 1.12
	local out = {}
	for i = 0, n - 1 do
		local t = (i + 0.5) / n
		local th = (o.phase or 0) + TAU * turns * t
		local y = y0 + height * t
		local pcf = base * CFrame.new(0, y, 0) * CFrame.Angles(0, -th, 0) * CFrame.new(radius + thick / 2, 0, 0) * CFrame.Angles(-alpha, 0, 0)
		table.insert(out, self:box(Vector3.new(thick, width, segLen), pcf, style, o.name or "Wrap"))
	end
	return out
end

--- Triángulo sólido (prisma de grosor `thickness`) con vértices a, b, c en espacio del modelo.
--- Usa 2 WedgeParts (técnica de EgoMoose). Base de pirámides, picos, símbolos y cristales.
function Builder:triangle(a: Vector3, b: Vector3, c: Vector3, thickness: number?, style: Style?, name: string?): { BasePart }
	local t = thickness or 0.05
	local ab, ac, bc = b - a, c - a, c - b
	local abd, acd, bcd = ab:Dot(ab), ac:Dot(ac), bc:Dot(bc)
	if abd > acd and abd > bcd then
		c, a = a, c
	elseif acd > bcd and acd > abd then
		a, b = b, a
	end
	ab, ac, bc = b - a, c - a, c - b
	local out = {}
	local n = ac:Cross(ab)
	if n.Magnitude < 1e-6 then
		return out
	end
	local right = n.Unit
	local up = bc:Cross(right).Unit
	local back = bc.Unit
	local height = math.abs(ab:Dot(up))
	local d1 = math.abs(ab:Dot(back))
	local d2 = math.abs(ac:Dot(back))
	if height < 1e-4 then
		return out
	end
	if d1 > 1e-4 then
		table.insert(out, self:wedge(Vector3.new(t, height, d1), CFrame.fromMatrix((a + b) / 2, right, up, back), style, name or "Tri"))
	end
	if d2 > 1e-4 then
		table.insert(out, self:wedge(Vector3.new(t, height, d2), CFrame.fromMatrix((a + c) / 2, -right, up, -back), style, name or "Tri"))
	end
	return out
end

--- Pirámide de `sides` caras (3–8) con base centrada en `baseCF` y punta a lo largo de su Y local.
--- Úsala para picos, puntas de cristal, cuernos. Interior hueco (la base debe quedar enterrada).
function Builder:pyramid(baseCF: CFrame | Vector3, length: number, baseWidth: number, sides: number?, style: Style?, name: string?, shell: number?): { BasePart }
	local base = toCF(baseCF)
	local n = sides or 4
	local r = baseWidth / 2 / math.cos(math.pi / n) -- circunradio para que el ancho entre caras = baseWidth
	local apex = base:PointToWorldSpace(Vector3.new(0, length, 0))
	local rot = if n == 4 then math.pi / 4 else 0
	local pts = {}
	for i = 0, n - 1 do
		local a = rot + TAU * i / n
		table.insert(pts, base:PointToWorldSpace(Vector3.new(math.cos(a) * r, 0, math.sin(a) * r)))
	end
	local th = shell or math.max(0.03, baseWidth * 0.08)
	local out = {}
	for i = 1, n do
		local p0, p1 = pts[i], pts[i % n + 1]
		-- desplaza el triángulo hacia adentro medio grosor para que la cara exterior quede en su lugar
		local mid = (p0 + p1 + apex) / 3
		local center = base:PointToWorldSpace(Vector3.new(0, length / 3, 0))
		local inward = (center - mid)
		local off = if inward.Magnitude > 1e-6 then inward.Unit * th / 2 else Vector3.zero
		for _, w in self:triangle(p0 + off, p1 + off, apex + off * 0.2, th, style, name or "Spike") do
			table.insert(out, w)
		end
	end
	return out
end

--- Pico estándar (pirámide de 4 caras). `baseCF` en la superficie; la punta sale por su Y local.
function Builder:spike(baseCF: CFrame | Vector3, length: number, baseWidth: number, style: Style?, sides: number?): { BasePart }
	return self:pyramid(baseCF, length, baseWidth, sides or 4, style, "Spike")
end

--- Cristal: prisma + punta piramidal, a lo largo de la Y local de `baseCF`.
function Builder:crystal(baseCF: CFrame | Vector3, length: number, width: number, style: Style?, coreStyle: Style?): { BasePart }
	local base = toCF(baseCF)
	local bodyLen = length * 0.68
	local out = {}
	table.insert(out, self:box(Vector3.new(width, bodyLen, width), base * CFrame.new(0, bodyLen / 2, 0) * CFrame.Angles(0, math.pi / 4, 0), style, "Crystal"))
	for _, p in self:pyramid(base * CFrame.new(0, bodyLen - 0.001, 0) * CFrame.Angles(0, math.pi / 4, 0), length - bodyLen, width, 4, style, "CrystalTip") do
		table.insert(out, p)
	end
	if coreStyle then
		table.insert(out, self:box(Vector3.new(width * 0.45, bodyLen * 0.9, width * 0.45), base * CFrame.new(0, bodyLen / 2, 0) * CFrame.Angles(0, math.pi / 4, 0), coreStyle, "CrystalCore"))
	end
	return out
end

--- Gema facetada: cubo girado (lee como diamante) con núcleo de neón opcional.
function Builder:gem(cf: CFrame | Vector3, size: number, style: Style?, coreStyle: Style?): { BasePart }
	local base = toCF(cf) * CFrame.Angles(math.rad(45), math.rad(35.26), 0)
	local out = { self:box(Vector3.new(size, size, size), base, style, "Gem") }
	if coreStyle then
		table.insert(out, self:box(Vector3.new(size, size, size) * 0.55, base, coreStyle, "GemCore"))
	end
	return out
end

--- Línea recta (barra) de p0 a p1. `normal` orienta el "grosor" (útil para grietas sobre superficies).
function Builder:line(p0: Vector3, p1: Vector3, width: number, depth: number?, style: Style?, normal: Vector3?, name: string?): BasePart?
	local len = (p1 - p0).Magnitude
	if len < 1e-4 then
		return nil
	end
	local mid = (p0 + p1) / 2
	local dir = (p1 - p0).Unit
	local up = normal or (if math.abs(dir.Y) < 0.95 then Vector3.yAxis else Vector3.xAxis)
	local right = dir:Cross(up)
	if right.Magnitude < 1e-6 then
		right = dir:Cross(Vector3.zAxis)
	end
	right = right.Unit
	local realUp = right:Cross(dir).Unit
	local cf = CFrame.fromMatrix(mid, right, realUp, -dir)
	return self:box(Vector3.new(width, depth or width, len), cf, style, name or "Line")
end

--- Polilínea: segmentos entre puntos consecutivos (grietas de lava, rayos, contornos).
function Builder:polyline(points: { Vector3 }, width: number, depth: number?, style: Style?, normal: Vector3?, closed: boolean?, name: string?): { BasePart }
	local out = {}
	local count = #points
	local last = if closed then count else count - 1
	for i = 1, last do
		local a, b = points[i], points[i % count + 1]
		local seg = self:line(a, b, width, depth, style, normal, name)
		if seg then
			-- alarga un poco cada segmento para tapar las uniones
			seg.Size += Vector3.new(0, 0, width * self.scale * 0.9)
			table.insert(out, seg)
		end
	end
	return out
end

--- Camino zigzag determinista de p0 a p1 (para arcos eléctricos y grietas).
function Builder.jitterPath(p0: Vector3, p1: Vector3, segments: number, amplitude: number, seed: number, normal: Vector3?): { Vector3 }
	local rand = Builder.rng(seed)
	local dir = p1 - p0
	local side = dir:Cross(normal or Vector3.zAxis)
	if side.Magnitude < 1e-6 then
		side = dir:Cross(Vector3.xAxis)
	end
	side = side.Unit
	local up = side:Cross(dir.Unit).Unit
	local pts = { p0 }
	for i = 1, segments - 1 do
		local t = i / segments
		local off = side * rand(-amplitude, amplitude) + up * rand(-amplitude, amplitude) * 0.35
		table.insert(pts, p0 + dir * t + off)
	end
	table.insert(pts, p1)
	return pts
end

--- Extruye una forma 2D (lista de Vector2) sobre el plano XY local de `planeCF` con grosor `thickness`.
--- El grosor queda centrado en el plano (sobresale thickness/2 hacia la normal local Z).
function Builder:shape(planeCF: CFrame | Vector3, points: { Vector2 }, thickness: number, style: Style?, name: string?): { BasePart }
	local plane = toCF(planeCF)
	local out = {}
	for _, tri in Shapes.triangulate(points) do
		local a = plane:PointToWorldSpace(Vector3.new(tri[1].X, tri[1].Y, 0))
		local b = plane:PointToWorldSpace(Vector3.new(tri[2].X, tri[2].Y, 0))
		local c = plane:PointToWorldSpace(Vector3.new(tri[3].X, tri[3].Y, 0))
		for _, w in self:triangle(a, b, c, thickness, style, name or "Shape") do
			table.insert(out, w)
		end
	end
	return out
end

--- Franjas diagonales tipo "peligro" dentro de un rectángulo w×h sobre `planeCF`.
function Builder:stripes(planeCF: CFrame | Vector3, w: number, h: number, stripeWidth: number, angle: number, thickness: number, style: Style?): { BasePart }
	local out = {}
	local span = w + h * 2
	local k = math.tan(math.rad(angle))
	local x = -span / 2
	while x < span / 2 do
		local poly = {
			Vector2.new(x - h * k, -h),
			Vector2.new(x + stripeWidth - h * k, -h),
			Vector2.new(x + stripeWidth + h * k, h),
			Vector2.new(x + h * k, h),
		}
		local clipped = Shapes.clipRect(poly, w, h)
		if #clipped >= 3 then
			for _, p in self:shape(planeCF, clipped, thickness, style, "Stripe") do
				table.insert(out, p)
			end
		end
		x += stripeWidth * 2
	end
	return out
end

--- Arte de píxeles: `grid` = lista de strings (fila superior primero); `styles` mapea carácter -> estilo.
--- Une píxeles contiguos de la misma fila en un solo bloque para ahorrar piezas.
function Builder:pixels(planeCF: CFrame | Vector3, grid: { string }, pixel: number, depth: number, styles: { [string]: Style }): { BasePart }
	local plane = toCF(planeCF)
	local rows = #grid
	local cols = #grid[1]
	local out = {}
	for r = 1, rows do
		local row = grid[r]
		local c = 1
		while c <= cols do
			local ch = string.sub(row, c, c)
			local st = styles[ch]
			if st then
				local start = c
				while c + 1 <= cols and string.sub(row, c + 1, c + 1) == ch do
					c += 1
				end
				local run = c - start + 1
				local cx = ((start - 1) + run / 2 - cols / 2) * pixel
				local cy = (rows / 2 - (r - 0.5)) * pixel
				table.insert(out, self:box(Vector3.new(run * pixel, pixel, depth), plane * CFrame.new(cx, cy, 0), st, "Pixel"))
			end
			c += 1
		end
	end
	return out
end

--- Disco de bóveda (motivo de la marca): aro + rayos + centro + perillas. Mira hacia la Z local de `planeCF`.
function Builder:dial(planeCF: CFrame | Vector3, radius: number, ringStyle: Style?, spokeStyle: Style?, hubStyle: Style?, spokes: number?): { BasePart }
	local plane = toCF(planeCF)
	local n = spokes or 8
	local out = {}
	local tube = radius * 0.18
	for _, p in self:ring(plane * CFrame.Angles(math.pi / 2, 0, 0), radius - tube / 2, tube, 20, ringStyle, "DialRing", tube * 0.7) do
		table.insert(out, p)
	end
	for i = 0, n - 1 do
		local a = TAU * i / n
		local dir = Vector3.new(math.cos(a), math.sin(a), 0)
		local p0 = plane:PointToWorldSpace(dir * radius * 0.22)
		local p1 = plane:PointToWorldSpace(dir * (radius * 1.12))
		local spoke = self:line(p0, p1, radius * 0.1, radius * 0.1, spokeStyle, plane.LookVector, "DialSpoke")
		if spoke then
			table.insert(out, spoke)
		end
		table.insert(out, self:ball(radius * 0.2, plane:PointToWorldSpace(dir * radius * 1.16), spokeStyle, "DialKnob"))
	end
	table.insert(out, self:cylZ(radius * 0.22, radius * 0.5, plane * CFrame.new(0, 0, radius * 0.04), hubStyle, "DialHub"))
	return out
end

-- ── Efectos ─────────────────────────────────────────────────────────

function Builder:attachment(cf: CFrame | Vector3, name: string?): Attachment
	local a = Instance.new("Attachment")
	a.Name = name or "Attachment"
	a.CFrame = self:_cf(cf)
	a.Parent = self.handle
	return a
end

--- Luz. `at` = Vector3/CFrame (crea Attachment) o una pieza/attachment existente.
function Builder:light(at: any, color: Color3, brightness: number?, range: number?, opts: { [string]: any }?): PointLight
	local o = opts or {}
	local parent = at
	if typeof(at) == "Vector3" or typeof(at) == "CFrame" then
		parent = self:attachment(at, o.name and (o.name .. "Att") or "LightAtt")
	end
	local l = Instance.new("PointLight")
	l.Name = o.name or "Glow"
	l.Color = color
	l.Brightness = brightness or 1.5
	l.Range = (range or 8) * self.scale
	l.Shadows = false
	if o.pulse then
		l:SetAttribute("FX_Pulse", NumberRange.new(o.pulse[1], o.pulse[2]))
		l:SetAttribute("FX_PulseSpeed", o.pulseSpeed or 1)
	end
	l.Parent = parent
	self.lightCount += 1
	return l
end

--- Emisor de partículas. `at` = pieza (emite desde su volumen), attachment, o Vector3/CFrame.
--- `props` = tabla de propiedades (usa Builder.Particles.*) — se escalan Size/Speed/Acceleration.
function Builder:emitter(at: any, props: { [string]: any }, name: string?): ParticleEmitter
	local parent = at
	if typeof(at) == "Vector3" or typeof(at) == "CFrame" then
		parent = self:attachment(at, (name or "Emitter") .. "Att")
	end
	local e = Instance.new("ParticleEmitter")
	e.Name = name or "Emitter"
	for k, v in props do
		if k == "EmitCount" then
			continue -- no es propiedad de Roblox: la usa impact() para FX_Emit
		end
		local value = v
		if self.scale ~= 1 then
			if k == "Size" then
				value = scaleSequence(v, self.scale)
			elseif k == "Speed" then
				value = NumberRange.new(v.Min * self.scale, v.Max * self.scale)
			elseif k == "Acceleration" then
				value = v * self.scale
			end
		end
		local target: any = e
		target[k] = value
	end
	if props.Enabled ~= false then
		self.emitterRate += props.Rate or 20
	end
	e.Parent = parent
	return e
end

--- Trail del golpe (apagado; HammerFX lo enciende al hacer swing). p0/p1 = extremos en espacio del modelo.
function Builder:trail(p0: Vector3, p1: Vector3, color0: Color3, color1: Color3?, opts: { [string]: any }?): Trail
	local o = opts or {}
	local a0 = self:attachment(p0, "TrailA")
	local a1 = self:attachment(p1, "TrailB")
	local t = Instance.new("Trail")
	t.Name = "SwingTrail"
	t.Attachment0 = a0
	t.Attachment1 = a1
	t.Enabled = false
	t.Lifetime = o.lifetime or 0.22
	t.MinLength = 0.05
	t.LightEmission = o.lightEmission or 1
	t.LightInfluence = 0
	t.FaceCamera = false
	t.Color = ColorSequence.new(color0, color1 or color0)
	t.Transparency = o.transparency or Builder.seq(0, 0.15, 0.6, 0.6, 1, 1)
	t.WidthScale = Builder.seq(0, 1, 1, 0.25)
	t.Parent = self.handle
	return t
end

--- Punto de impacto: attachment + emisores apagados (HammerFX hace :Emit al golpear) + luz de flash.
--- `cf` = centro de la cara de golpe en espacio del modelo. Devuelve el Attachment.
function Builder:impact(cf: CFrame | Vector3, color: Color3, opts: { [string]: any }?): Attachment
	local o = opts or {}
	local att = self:attachment(cf, "ImpactPoint")
	local sparks = self:emitter(att, {
		Texture = TEX.FireSparks,
		Color = ColorSequence.new(Color3.new(1, 1, 1), color),
		LightEmission = 1,
		LightInfluence = 0,
		Brightness = 3,
		Size = Builder.seq(0, 0.35, 1, 0),
		Transparency = Builder.seq(0, 0, 1, 1),
		Lifetime = NumberRange.new(0.25, 0.5),
		Speed = NumberRange.new(14, 26),
		SpreadAngle = Vector2.new(75, 75),
		Acceleration = Vector3.new(0, -30, 0),
		Drag = 3,
		Rate = 0,
		Enabled = false,
	}, "ImpactSparks")
	sparks:SetAttribute("FX_Emit", o.sparks or 22)
	local flash = self:emitter(att, {
		Texture = TEX.Glow,
		Color = ColorSequence.new(color),
		LightEmission = 1,
		LightInfluence = 0,
		Brightness = 4,
		Size = Builder.seq(0, 1.2, 1, 4),
		Transparency = Builder.seq(0, 0, 1, 1),
		Lifetime = NumberRange.new(0.12, 0.18),
		Speed = NumberRange.new(0, 0),
		Rate = 0,
		Enabled = false,
		ZOffset = 1,
	}, "ImpactFlash")
	flash:SetAttribute("FX_Emit", 1)
	if o.extra then
		for i, props in o.extra do
			local e = self:emitter(att, props, "ImpactExtra" .. i)
			e.Enabled = false
			e.Rate = 0
			e:SetAttribute("FX_Emit", props.EmitCount or 12)
		end
	end
	local l = Instance.new("PointLight")
	l.Name = "ImpactLight"
	l.Color = color
	l.Brightness = 0
	l.Range = 14 * self.scale
	l.Shadows = false
	l:SetAttribute("FX_Flash", o.flash or 6)
	l.Parent = att
	return att
end

--- Contorno brillante (Highlight). Úsalo con moderación: Roblox limita ~31 en pantalla.
function Builder:highlight(color: Color3, fillTransparency: number?, outlineTransparency: number?): Highlight
	local h = Instance.new("Highlight")
	h.Name = "RarityHighlight"
	h.FillColor = color
	h.OutlineColor = color
	h.FillTransparency = fillTransparency or 1
	h.OutlineTransparency = outlineTransparency or 0.35
	h.DepthMode = Enum.HighlightDepthMode.Occluded
	h.Parent = self.tool
	return h
end

-- ── Animación (la ejecuta HammerFX en el cliente) ───────────────────

export type AnimateFX = {
	Spin: Vector3?, -- eje * velocidad (rad/s) en el espacio local del pivote
	Bob: Vector3?, -- amplitud (studs) de flotación en el espacio local del pivote
	BobSpeed: number?, -- ciclos por segundo
	Phase: number?, -- desfase en segundos
}

--- Hace que `parts` giren/floten alrededor de `pivot` (espacio del modelo).
function Builder:animate(parts: any, pivot: CFrame | Vector3, fx: AnimateFX)
	local list = if typeof(parts) == "Instance" then { parts } else parts
	local P = self:_cf(pivot)
	for _, p in list do
		local w = p:FindFirstChild("W") or p:FindFirstChild("FXWeld")
		if w then
			w.Name = "FXWeld"
			w.C0 = P
			w.C1 = p.CFrame:Inverse() * P
			w:SetAttribute("FX_BaseC0", P)
			if fx.Spin then
				w:SetAttribute("FX_Spin", fx.Spin)
			end
			if fx.Bob then
				w:SetAttribute("FX_Bob", fx.Bob * self.scale)
				w:SetAttribute("FX_BobSpeed", fx.BobSpeed or 0.5)
			end
			if fx.Phase then
				w:SetAttribute("FX_Phase", fx.Phase)
			end
		end
	end
end

--- Pulso: piezas -> Transparency entre [min,max]; luces -> Brightness entre [min,max].
function Builder:pulse(targets: any, minValue: number, maxValue: number, hz: number?, phase: number?)
	local list = if typeof(targets) == "Instance" then { targets } else targets
	for _, inst in list do
		inst:SetAttribute("FX_Pulse", NumberRange.new(minValue, maxValue))
		inst:SetAttribute("FX_PulseSpeed", hz or 1)
		if phase then
			inst:SetAttribute("FX_Phase", phase)
		end
	end
end

--- Parpadeo eléctrico: HammerFX muestra al azar una fracción de las piezas de `folder` cada tick.
function Builder:flicker(folder: Instance, hz: number?, visibleFraction: number?)
	folder:SetAttribute("FX_Flicker", hz or 12)
	folder:SetAttribute("FX_FlickerOn", visibleFraction or 0.5)
end

--- Ciclo de color (arcoíris) en piezas o luces. speed = vueltas por segundo.
function Builder:hue(targets: any, speed: number?)
	local list = if typeof(targets) == "Instance" then { targets } else targets
	for _, inst in list do
		inst:SetAttribute("FX_Hue", speed or 0.2)
	end
end

-- ── Final ───────────────────────────────────────────────────────────

function Builder:finish(): Tool
	local tool = self.tool
	local def = self.def
	local rarity = Palette.Rarity[def.Rarity]
	tool:SetAttribute("HammerId", def.Id)
	tool:SetAttribute("DisplayName", def.DisplayName or def.Id)
	tool:SetAttribute("Rarity", def.Rarity)
	tool:SetAttribute("Order", def.Order or 0)
	tool:SetAttribute("PartCount", self.count)
	if def.Theme then
		tool:SetAttribute("Theme", def.Theme)
	end
	if rarity then
		tool:SetAttribute("RarityColor", rarity.Color)
	end
	tool:AddTag(Builder.TAG)
	return tool
end

return Builder
