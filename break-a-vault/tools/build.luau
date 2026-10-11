--[[
	Build de HammerForge fuera de Roblox (con Lune).

	  cd break-a-vault
	  lune run tools/build.luau                      -- todos los martillos
	  lune run tools/build.luau -- --only RustyHammer,SafeCracker
	  lune run tools/build.luau -- --only RustyHammer --no-files   -- solo valida y genera JSON

	Salidas (carpeta dist/):
	  BreakAVault_Hammers.rbxm   → arrastrar a Studio: HammerForge (módulos) + Hammers (Tools) + HammerFXClient
	  BreakAVault_Showcase.rbxl  → lugar listo: vitrina con todos los martillos, iluminación y prueba de golpe
	  hammers.json               → datos para la vista previa 3D (tools/render)

	Ejecuta el MISMO código Luau que corre en Roblox: valida nombres de propiedades y enums
	contra la base de datos de reflexión de Roblox (rbx-dom), así que un typo truena aquí.
]]

local fs = require("@lune/fs")
local luau = require("@lune/luau")
local process = require("@lune/process")
local roblox = require("@lune/roblox")
local serde = require("@lune/serde")

local SRC = "src"
local DIST = "dist"

-- ── argumentos ─────────────────────────────────────────────────────
local only: { [string]: boolean }? = nil
local writeFiles = true
local jsonPath = DIST .. "/hammers.json"
do
	local i = 1
	local args = process.args
	while i <= #args do
		local a = args[i]
		if a == "--only" then
			only = {}
			for id in string.gmatch(args[i + 1] or "", "[^,]+") do
				(only :: any)[id] = true
			end
			i += 1
		elseif a == "--no-files" then
			writeFiles = false
		elseif a == "--json" then
			jsonPath = args[i + 1]
			i += 1
		end
		i += 1
	end
end

if not fs.isDir(SRC) then
	print("Corre este script desde la carpeta break-a-vault/ (no encuentro src/)")
	process.exit(1)
end

-- ── árbol virtual de scripts (como Rojo) ───────────────────────────
local VNode = {}
local VNodeMethods = {}

local function newNode(name: string, className: string, path: string?, parent: any)
	local node = setmetatable({ Name = name, ClassName = className, Path = path, Parent = parent, _children = {} }, VNode)
	if parent then
		table.insert(rawget(parent, "_children"), node)
	end
	return node
end

VNode.__index = function(self, key)
	local m = VNodeMethods[key]
	if m then
		return m
	end
	for _, c in rawget(self, "_children") do
		if c.Name == key then
			return c
		end
	end
	error(string.format("%s is not a valid member of %s", tostring(key), rawget(self, "Name")), 2)
end
VNode.__tostring = function(self)
	return rawget(self, "Name")
end

function VNodeMethods.GetChildren(self)
	return table.clone(rawget(self, "_children"))
end
function VNodeMethods.GetDescendants(self)
	local out = {}
	local function walk(n)
		for _, c in rawget(n, "_children") do
			table.insert(out, c)
			walk(c)
		end
	end
	walk(self)
	return out
end
function VNodeMethods.IsA(self, cls)
	return rawget(self, "ClassName") == cls or (cls == "LuaSourceContainer")
end
function VNodeMethods.FindFirstChild(self, name)
	for _, c in rawget(self, "_children") do
		if c.Name == name then
			return c
		end
	end
	return nil
end
VNodeMethods.WaitForChild = VNodeMethods.FindFirstChild
function VNodeMethods.GetFullName(self)
	local parts = {}
	local n = self
	while n do
		table.insert(parts, 1, rawget(n, "Name"))
		n = rawget(n, "Parent")
	end
	return table.concat(parts, ".")
end

local function stripExt(file: string): (string, string)
	if string.sub(file, -12) == ".client.luau" then
		return string.sub(file, 1, -13), "LocalScript"
	elseif string.sub(file, -12) == ".server.luau" then
		return string.sub(file, 1, -13), "Script"
	elseif string.sub(file, -5) == ".luau" then
		return string.sub(file, 1, -6), "ModuleScript"
	end
	return file, "Unknown"
end

local function buildTree(dir: string, name: string, parent: any)
	local initPath = dir .. "/init.luau"
	local node
	if fs.isFile(initPath) then
		node = newNode(name, "ModuleScript", initPath, parent)
	else
		node = newNode(name, "Folder", nil, parent)
	end
	local entries = fs.readDir(dir)
	table.sort(entries)
	for _, entry in entries do
		local full = dir .. "/" .. entry
		if fs.isDir(full) then
			buildTree(full, entry, node)
		elseif entry ~= "init.luau" then
			local n, cls = stripExt(entry)
			if cls ~= "Unknown" then
				newNode(n, cls, full, node)
			end
		end
	end
	return node
end

local forgeRoot = buildTree(SRC .. "/ReplicatedStorage/HammerForge", "HammerForge", nil)
local clientScriptPath = SRC .. "/StarterPlayer/StarterPlayerScripts/HammerFXClient.client.luau"

-- ── require virtual ────────────────────────────────────────────────
local baseEnv = getfenv(1)
local cache: { [any]: any } = {}
local loading: { [any]: boolean } = {}
local vrequire

local fakeGame = setmetatable({}, {
	__index = function(_, key)
		if key == "GetService" then
			return function(_, service)
				error("game:GetService('" .. tostring(service) .. "') no está disponible durante el build (los martillos no deben usar servicios)")
			end
		end
		error("game." .. tostring(key) .. " no está disponible durante el build")
	end,
})

local function makeEnv(node)
	return setmetatable({
		script = node,
		require = function(target)
			return vrequire(target)
		end,
		warn = function(...)
			print("[warn]", ...)
		end,
		game = fakeGame,
		Instance = roblox.Instance,
		Vector3 = roblox.Vector3,
		Vector2 = roblox.Vector2,
		CFrame = roblox.CFrame,
		Color3 = roblox.Color3,
		ColorSequence = roblox.ColorSequence,
		ColorSequenceKeypoint = roblox.ColorSequenceKeypoint,
		NumberSequence = roblox.NumberSequence,
		NumberSequenceKeypoint = roblox.NumberSequenceKeypoint,
		NumberRange = roblox.NumberRange,
		Enum = roblox.Enum,
		UDim = roblox.UDim,
		UDim2 = roblox.UDim2,
		BrickColor = roblox.BrickColor,
		Rect = roblox.Rect,
		Font = roblox.Font,
	}, { __index = baseEnv })
end

function vrequire(target)
	if type(target) ~= "table" or getmetatable(target) ~= VNode then
		error("require() en el build solo acepta ModuleScripts del árbol (script.Parent.X)", 2)
	end
	if cache[target] ~= nil then
		return cache[target]
	end
	if rawget(target, "ClassName") ~= "ModuleScript" then
		error("require() de algo que no es ModuleScript: " .. target:GetFullName(), 2)
	end
	if loading[target] then
		error("require circular: " .. target:GetFullName(), 2)
	end
	loading[target] = true
	local source = fs.readFile(rawget(target, "Path"))
	local fn = luau.load(source, { debugName = target:GetFullName(), environment = makeEnv(target), injectGlobals = false })
	local result = fn()
	loading[target] = nil
	cache[target] = result
	return result
end

-- ── chequeo de sintaxis de TODOS los scripts (incluye FX y el LocalScript) ──
do
	local bad = 0
	local function check(node)
		local path = rawget(node, "Path")
		if path then
			local ok, err = pcall(luau.compile, fs.readFile(path))
			if not ok then
				bad += 1
				print("  ✗ sintaxis: " .. path .. "\n      " .. tostring(err))
			end
		end
		for _, c in rawget(node, "_children") do
			check(c)
		end
	end
	check(forgeRoot)
	local ok, err = pcall(luau.compile, fs.readFile(clientScriptPath))
	if not ok then
		bad += 1
		print("  ✗ sintaxis: " .. clientScriptPath .. "\n      " .. tostring(err))
	end
	if bad > 0 then
		process.exit(1)
	end
end

-- ── construir ──────────────────────────────────────────────────────
local HammerForge = vrequire(forgeRoot)
local list = HammerForge.List()

local function round(x: number, d: number?): number
	local m = 10 ^ (d or 4)
	return math.floor(x * m + 0.5) / m
end

local function cfArray(cf): { number }
	local c = { cf:GetComponents() }
	for i, v in c do
		c[i] = round(v, 5)
	end
	return c
end

local function v3(v): { number }
	return { round(v.X), round(v.Y), round(v.Z) }
end

local function col(c): { number }
	return { round(c.R, 4), round(c.G, 4), round(c.B, 4) }
end

local function try(inst, prop, default)
	local ok, v = pcall(function()
		return inst[prop]
	end)
	if ok and v ~= nil then
		return v
	end
	return default
end

local function seqToArray(seq, isColor: boolean?)
	if seq == nil then
		return nil
	end
	local out = {}
	for _, kp in seq.Keypoints do
		if isColor then
			table.insert(out, { round(kp.Time, 3), col(kp.Value) })
		else
			table.insert(out, { round(kp.Time, 3), round(kp.Value, 3) })
		end
	end
	return out
end

local function partCorners(p, acc)
	local cf, s = p.CFrame, p.Size / 2
	for _, x in { -1, 1 } do
		for _, y in { -1, 1 } do
			for _, z in { -1, 1 } do
				local w = cf:PointToWorldSpace(roblox.Vector3.new(s.X * x, s.Y * y, s.Z * z))
				acc.min = roblox.Vector3.new(math.min(acc.min.X, w.X), math.min(acc.min.Y, w.Y), math.min(acc.min.Z, w.Z))
				acc.max = roblox.Vector3.new(math.max(acc.max.X, w.X), math.max(acc.max.Y, w.Y), math.max(acc.max.Z, w.Z))
			end
		end
	end
end

local LIMITS = {
	Starter = 150,
	Uncommon = 190,
	Rare = 240,
	Epic = 280,
	Legendary = 340,
	Mythic = 380,
	Special = 380,
}

local function attachPos(parent)
	if parent:IsA("Attachment") then
		return parent.CFrame.Position, nil, nil
	elseif parent:IsA("BasePart") then
		return parent.CFrame.Position, parent.Size, parent.CFrame
	end
	return roblox.Vector3.new(0, 0, 0), nil, nil
end

local function exportTool(tool, def)
	local handle = tool:FindFirstChild("Handle")
	local issues = {}
	local data = {
		id = def.Id,
		name = def.DisplayName,
		rarity = def.Rarity,
		order = def.Order,
		theme = def.Theme,
		parts = {},
		lights = {},
		emitters = {},
		trails = {},
		flickers = {},
		impact = nil,
	}
	local index = {}
	local acc = { min = roblox.Vector3.new(math.huge, math.huge, math.huge), max = roblox.Vector3.new(-math.huge, -math.huge, -math.huge) }
	local partCount, rate, lights = 0, 0, 0

	for _, d in tool:GetDescendants() do
		if d:IsA("BasePart") then
			partCount += 1
			if d ~= handle then
				local w = d:FindFirstChild("W") or d:FindFirstChild("FXWeld")
				if not w or w.Part0 ~= handle or w.Part1 ~= d then
					table.insert(issues, "pieza sin soldar al Handle: " .. d:GetFullName())
				end
				local transparency = try(d, "Transparency", 0)
				if transparency < 1 then
					partCorners(d, acc)
				end
				local entry = {
					n = d.Name,
					c = d.ClassName,
					s = if d.ClassName == "Part" then try(d, "Shape", roblox.Enum.PartType.Block).Name else nil,
					sz = v3(d.Size),
					cf = cfArray(d.CFrame),
					col = col(d.Color),
					m = d.Material.Name,
					t = round(transparency, 3),
					r = round(try(d, "Reflectance", 0), 3),
					g = d.Parent and d.Parent ~= tool and d.Parent.Name or nil,
				}
				if w and w.Name == "FXWeld" then
					entry.fx = {
						base = cfArray(w:GetAttribute("FX_BaseC0") or w.C0),
						c1inv = cfArray(w.C1:Inverse()),
						spin = w:GetAttribute("FX_Spin") and v3(w:GetAttribute("FX_Spin")) or nil,
						bob = w:GetAttribute("FX_Bob") and v3(w:GetAttribute("FX_Bob")) or nil,
						bobSpeed = w:GetAttribute("FX_BobSpeed"),
						phase = w:GetAttribute("FX_Phase"),
					}
				end
				local pulse = d:GetAttribute("FX_Pulse")
				if pulse then
					entry.pulse = { pulse.Min, pulse.Max, d:GetAttribute("FX_PulseSpeed") or 1, d:GetAttribute("FX_Phase") or 0 }
				end
				if d:GetAttribute("FX_Hue") then
					entry.hue = d:GetAttribute("FX_Hue")
				end
				table.insert(data.parts, entry)
				index[d] = #data.parts - 1
				if d.Anchored then
					table.insert(issues, "pieza anclada (debe ir soldada): " .. d:GetFullName())
				end
			end
		elseif d:IsA("PointLight") then
			if not d:GetAttribute("FX_Flash") then
				lights += 1
			end
			local pos = attachPos(d.Parent)
			local pulse = d:GetAttribute("FX_Pulse")
			if not d:GetAttribute("FX_Flash") then
				table.insert(data.lights, {
					p = v3(pos),
					col = col(try(d, "Color", roblox.Color3.new(1, 1, 1))),
					b = try(d, "Brightness", 1),
					r = try(d, "Range", 8),
					pulse = pulse and { pulse.Min, pulse.Max, d:GetAttribute("FX_PulseSpeed") or 1 } or nil,
				})
			end
		elseif d:IsA("ParticleEmitter") then
			local enabled = try(d, "Enabled", true)
			local erate = try(d, "Rate", 20)
			if enabled then
				rate += erate
			end
			local pos, size, pcf = attachPos(d.Parent)
			local lt = try(d, "Lifetime", roblox.NumberRange.new(1, 1))
			local sp = try(d, "Speed", roblox.NumberRange.new(5, 5))
			local spread = try(d, "SpreadAngle", roblox.Vector2.new(0, 0))
			table.insert(data.emitters, {
				n = d.Name,
				p = v3(pos),
				vol = size and v3(size) or nil,
				vcf = pcf and cfArray(pcf) or nil,
				tex = try(d, "Texture", ""),
				col = seqToArray(try(d, "Color", nil), true),
				size = seqToArray(try(d, "Size", nil)),
				transp = seqToArray(try(d, "Transparency", nil)),
				rate = erate,
				life = { lt.Min, lt.Max },
				speed = { sp.Min, sp.Max },
				acc = v3(try(d, "Acceleration", roblox.Vector3.new(0, 0, 0))),
				spread = { spread.X, spread.Y },
				le = try(d, "LightEmission", 0),
				dir = try(d, "EmissionDirection", roblox.Enum.NormalId.Top).Name,
				shape = try(d, "Shape", roblox.Enum.ParticleEmitterShape.Box).Name,
				inout = try(d, "ShapeInOut", roblox.Enum.ParticleEmitterShapeInOut.Outward).Name,
				drag = try(d, "Drag", 0),
				enabled = enabled,
				emit = d:GetAttribute("FX_Emit"),
				pulse = d:GetAttribute("FX_Pulse") and { d:GetAttribute("FX_Pulse").Min, d:GetAttribute("FX_Pulse").Max, d:GetAttribute("FX_PulseSpeed") or 1 } or nil,
			})
		elseif d:IsA("Trail") then
			local a0, a1 = try(d, "Attachment0", nil), try(d, "Attachment1", nil)
			if a0 and a1 then
				table.insert(data.trails, { a = v3(a0.CFrame.Position), b = v3(a1.CFrame.Position), col = seqToArray(try(d, "Color", nil), true) })
			end
		elseif d:IsA("Attachment") and d.Name == "ImpactPoint" then
			data.impact = v3(d.CFrame.Position)
		end
	end
	-- carpetas con parpadeo y piezas con FX_Pulse a nivel carpeta
	for _, d in tool:GetDescendants() do
		local hz = d:GetAttribute("FX_Flicker")
		if hz then
			local idx = {}
			for _, p in d:GetDescendants() do
				if p:IsA("BasePart") and index[p] then
					table.insert(idx, index[p])
				end
			end
			table.insert(data.flickers, { parts = idx, hz = hz, on = d:GetAttribute("FX_FlickerOn") or 0.5 })
		end
	end
	if not handle then
		table.insert(issues, "falta el Handle")
	end
	local bbox = acc.max - acc.min
	data.stats = {
		parts = partCount,
		emitterRate = rate,
		lights = lights,
		bboxMin = v3(acc.min),
		bboxMax = v3(acc.max),
		size = v3(bbox),
	}
	local limit = LIMITS[def.Rarity] or 300
	local warnings = {}
	if partCount > limit then
		table.insert(warnings, string.format("muchas piezas: %d (límite sugerido %d para %s)", partCount, limit, def.Rarity))
	end
	if rate > 120 then
		table.insert(warnings, string.format("demasiadas partículas: Rate total %d (máx. sugerido 120)", rate))
	end
	if lights > 4 then
		table.insert(warnings, string.format("demasiadas luces: %d (máx. sugerido 4)", lights))
	end
	if bbox.Y > 9 or bbox.Y < 4 then
		table.insert(warnings, string.format("altura total rara: %.2f studs (esperado 4.5–8)", bbox.Y))
	end
	if bbox.X > 6.5 or bbox.Z > 6.5 then
		table.insert(warnings, string.format("cabeza muy ancha: %.2f × %.2f studs", bbox.X, bbox.Z))
	end
	return data, issues, warnings
end

local built = {}
local exported = {}
local failures = 0
print(string.format("HammerForge: %d martillos encontrados", #list))
for _, info in list do
	if only and not only[info.Id] then
		continue
	end
	local ok, tool = pcall(HammerForge.Build, info.Id)
	if not ok then
		failures += 1
		print(string.format("  ✗ %-22s ERROR: %s", info.Id, tostring(tool)))
		continue
	end
	local data, issues, warnings = exportTool(tool, info)
	table.insert(exported, data)
	table.insert(built, tool)
	local mark = if #issues > 0 then "✗" elseif #warnings > 0 then "!" else "✓"
	print(string.format("  %s %-22s %-10s piezas=%3d partículas=%3d luces=%d tamaño=%.1f×%.1f×%.1f",
		mark, info.Id, info.Rarity, data.stats.parts, data.stats.emitterRate, data.stats.lights,
		data.stats.size[1], data.stats.size[2], data.stats.size[3]))
	for _, msg in issues do
		print("      ERROR: " .. msg)
	end
	for _, msg in warnings do
		print("      aviso: " .. msg)
	end
	if #issues > 0 then
		failures += 1
	end
end

if not fs.isDir(DIST) then
	fs.writeDir(DIST)
end
fs.writeFile(jsonPath, serde.encode("json", { generated = "HammerForge", hammers = exported }, false))
print("→ " .. jsonPath)

if writeFiles and not only then
	-- ModuleScripts reales con el código fuente
	local function materialize(node)
		local cls = rawget(node, "ClassName")
		local inst = roblox.Instance.new(cls)
		inst.Name = rawget(node, "Name")
		local path = rawget(node, "Path")
		if path then
			inst.Source = fs.readFile(path)
		end
		for _, child in rawget(node, "_children") do
			materialize(child).Parent = inst
		end
		return inst
	end

	local function freshHammers()
		local folder = roblox.Instance.new("Folder")
		folder.Name = "Hammers"
		for _, info in list do
			local ok, tool = pcall(HammerForge.Build, info.Id)
			if ok then
				tool.Parent = folder
			end
		end
		return folder
	end

	local function clientScript()
		local s = roblox.Instance.new("LocalScript")
		s.Name = "HammerFXClient"
		s.Source = fs.readFile(clientScriptPath)
		return s
	end

	-- 1) Paquete para el juego
	local pack = roblox.Instance.new("Folder")
	pack.Name = "BreakAVault_Hammers"
	local readme = roblox.Instance.new("StringValue")
	readme.Name = "LEEME"
	readme.Value = "HammerForge -> ReplicatedStorage | Hammers -> ReplicatedStorage (o ServerStorage) | HammerFXClient -> StarterPlayer.StarterPlayerScripts"
	readme.Parent = pack
	materialize(forgeRoot).Parent = pack
	freshHammers().Parent = pack
	clientScript().Parent = pack
	fs.writeFile(DIST .. "/BreakAVault_Hammers.rbxm", roblox.serializeModel({ pack }))
	print("→ " .. DIST .. "/BreakAVault_Hammers.rbxm")

	-- 2) Lugar de vitrina listo para abrir en Studio
	local game = roblox.Instance.new("DataModel")
	local Workspace = game:GetService("Workspace")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Lighting = game:GetService("Lighting")
	local StarterPlayer = game:GetService("StarterPlayer")
	local StarterPack = game:GetService("StarterPack")

	materialize(forgeRoot).Parent = ReplicatedStorage
	freshHammers().Parent = StarterPack
	local sps = roblox.Instance.new("StarterPlayerScripts")
	sps.Parent = StarterPlayer
	clientScript().Parent = sps
	local test = roblox.Instance.new("LocalScript")
	test.Name = "HammerTestClient"
	test.Source = [[
-- SOLO PARA LA VITRINA: al hacer clic con un martillo equipado, anima el golpe y dispara los efectos.
-- En el juego real esto lo hace la parte funcional (Codex) con FX.Swing / FX.Impact.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FX = require(ReplicatedStorage:WaitForChild("HammerForge"):WaitForChild("FX"))
local player = Players.LocalPlayer
local function hook(tool)
	if not tool:IsA("Tool") or tool:GetAttribute("_testHooked") then return end
	tool:SetAttribute("_testHooked", true)
	tool.Activated:Connect(function()
		local anim = Instance.new("StringValue")
		anim.Name = "toolanim"
		anim.Value = "Slash"
		anim.Parent = tool
		FX.Swing(tool)
		task.delay(0.18, function() FX.Impact(tool) end)
	end)
end
local function watch(container)
	for _, c in container:GetChildren() do hook(c) end
	container.ChildAdded:Connect(hook)
end
watch(player:WaitForChild("Backpack"))
player.CharacterAdded:Connect(function(char) watch(char) end)
if player.Character then watch(player.Character) end
]]
	test.Parent = sps

	Lighting.Technology = roblox.Enum.Technology.Future
	Lighting.ClockTime = 19.2
	Lighting.Brightness = 2
	Lighting.Ambient = roblox.Color3.fromRGB(46, 54, 74)
	Lighting.OutdoorAmbient = roblox.Color3.fromRGB(70, 80, 104)
	Lighting.EnvironmentDiffuseScale = 1
	Lighting.EnvironmentSpecularScale = 1
	Lighting.GlobalShadows = true
	local bloom = roblox.Instance.new("BloomEffect")
	bloom.Intensity = 0.9
	bloom.Size = 30
	bloom.Threshold = 0.9
	bloom.Parent = Lighting
	local cc = roblox.Instance.new("ColorCorrectionEffect")
	cc.Contrast = 0.12
	cc.Saturation = 0.15
	cc.Parent = Lighting
	local atmo = roblox.Instance.new("Atmosphere")
	atmo.Density = 0.32
	atmo.Color = roblox.Color3.fromRGB(70, 90, 130)
	atmo.Decay = roblox.Color3.fromRGB(30, 40, 70)
	atmo.Glare = 0.2
	atmo.Haze = 1.4
	atmo.Parent = Lighting

	local floor = roblox.Instance.new("Part")
	floor.Name = "Floor"
	floor.Anchored = true
	floor.Size = roblox.Vector3.new(160, 1, 160)
	floor.CFrame = roblox.CFrame.new(0, -0.5, 30)
	floor.Material = roblox.Enum.Material.Slate
	floor.Color = roblox.Color3.fromRGB(22, 26, 36)
	floor.TopSurface = roblox.Enum.SurfaceType.Smooth
	floor.BottomSurface = roblox.Enum.SurfaceType.Smooth
	floor.Parent = Workspace
	local spawn = roblox.Instance.new("SpawnLocation")
	spawn.Name = "Spawn"
	spawn.Anchored = true
	spawn.Size = roblox.Vector3.new(8, 1, 8)
	spawn.CFrame = roblox.CFrame.new(0, 0.5, -12)
	spawn.Material = roblox.Enum.Material.DiamondPlate
	spawn.Color = roblox.Color3.fromRGB(40, 48, 64)
	spawn.TopSurface = roblox.Enum.SurfaceType.Smooth
	spawn.Parent = Workspace

	HammerForge.BuildShowcase(Workspace, roblox.CFrame.new(0, 0, 0))
	fs.writeFile(DIST .. "/BreakAVault_Showcase.rbxl", roblox.serializePlace(game))
	print("→ " .. DIST .. "/BreakAVault_Showcase.rbxl")
end

if failures > 0 then
	print(string.format("%d martillo(s) con errores", failures))
	process.exit(1)
end
