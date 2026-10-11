--[[
	HammerForge — fábrica de martillos de Break a Vault (parte VISUAL).

	Uso (servidor o barra de comandos de Studio):
		local HammerForge = require(game.ReplicatedStorage.HammerForge)
		local tool = HammerForge.Build("RustyHammer")            -- un Tool listo para dar al jugador
		local folder = HammerForge.BuildAll(game.ReplicatedStorage) -- carpeta "Hammers" con todos
		HammerForge.BuildShowcase(workspace, CFrame.new(0, 0, 0)) -- vitrina con pedestales
		print(HammerForge.List())                                  -- { {Id, DisplayName, Rarity, Order}, ... }

	Cada martillo vive en Hammers/<Rareza>/<Id>.luau y devuelve:
		{ Id = "RustyHammer", DisplayName = "Rusty Hammer", Rarity = "Starter", Order = 1,
		  Theme = "Starter Yard", Build = function(b, Palette, Builder) ... end }

	Los efectos animados (giros, pulsos, parpadeos, golpe) los ejecuta HammerForge.FX en el cliente.
]]

local Builder = require(script.Builder)
local Palette = require(script.Palette)

local HammerForge = {}
HammerForge.Builder = Builder
HammerForge.Palette = Palette
HammerForge.TAG = Builder.TAG

local defs: { { [string]: any } }? = nil
local byId: { [string]: { [string]: any } } = {}

local function rarityIndex(r: string): number
	for i, v in Palette.RarityOrder do
		if v == r then
			return i
		end
	end
	return 99
end

local function load(): { { [string]: any } }
	if defs then
		return defs
	end
	local list = {}
	for _, m in script.Hammers:GetDescendants() do
		if m:IsA("ModuleScript") then
			local ok, def = pcall(require, m)
			if not ok then
				warn(string.format("[HammerForge] Error cargando %s: %s", m:GetFullName(), tostring(def)))
			elseif type(def) == "table" and def.Id and def.Build then
				if byId[def.Id] then
					warn("[HammerForge] Id duplicado: " .. def.Id)
				end
				byId[def.Id] = def
				table.insert(list, def)
			else
				warn("[HammerForge] " .. m:GetFullName() .. " no devuelve una definición válida (falta Id o Build)")
			end
		end
	end
	table.sort(list, function(a, b)
		local ra, rb = rarityIndex(a.Rarity), rarityIndex(b.Rarity)
		if ra ~= rb then
			return ra < rb
		end
		return (a.Order or 0) < (b.Order or 0)
	end)
	defs = list
	return list
end

--- Lista de martillos disponibles (ordenada por rareza y orden).
function HammerForge.List(): { { [string]: any } }
	local out = {}
	for _, def in load() do
		table.insert(out, { Id = def.Id, DisplayName = def.DisplayName, Rarity = def.Rarity, Order = def.Order, Theme = def.Theme })
	end
	return out
end

--- Construye un martillo y devuelve el Tool. options = { Scale = 1 }
function HammerForge.Build(id: string, options: Builder.BuildOptions?): Tool
	load()
	local def = byId[id]
	assert(def, "[HammerForge] Martillo desconocido: " .. tostring(id))
	local b = Builder.new(def, options)
	def.Build(b, Palette, Builder)
	return b:finish()
end

--- Construye todos los martillos dentro de una carpeta "Hammers".
function HammerForge.BuildAll(parent: Instance?, options: Builder.BuildOptions?): Folder
	local folder = Instance.new("Folder")
	folder.Name = "Hammers"
	for _, def in load() do
		local ok, result = pcall(HammerForge.Build, def.Id, options)
		if ok then
			result.Parent = folder
		else
			warn(string.format("[HammerForge] Falló %s: %s", def.Id, tostring(result)))
		end
	end
	if parent then
		folder.Parent = parent
	end
	return folder
end

--- Mueve un martillo recién construido (construido en el origen) a `cf`.
local function moveBuilt(model: Instance, cf: CFrame)
	for _, d in model:GetDescendants() do
		if d:IsA("BasePart") then
			d.CFrame = cf * d.CFrame
		end
	end
end
HammerForge.MoveBuilt = moveBuilt

--- Convierte un Tool en un Model anclado para exhibición (no se puede recoger).
function HammerForge.ToDisplayModel(tool: Tool): Model
	local model = Instance.new("Model")
	model.Name = tool.Name
	for name, value in tool:GetAttributes() do
		model:SetAttribute(name, value)
	end
	for _, child in tool:GetChildren() do
		child.Parent = model
	end
	local handle = model:FindFirstChild("Handle") :: BasePart
	handle.Anchored = true
	handle.CanTouch = false
	model.PrimaryPart = handle
	model:AddTag(Builder.TAG)
	tool:Destroy()
	return model
end

--- Vitrina: una fila por rareza, cada martillo en un pedestal con su nombre.
--- Los martillos giran solos (atributo FX_Turntable) cuando corre HammerForge.FX en el cliente.
function HammerForge.BuildShowcase(parent: Instance, origin: CFrame?, options: { [string]: any }?): Model
	local o = options or {}
	local base = origin or CFrame.new()
	local spacing = o.Spacing or 8
	local rowGap = o.RowGap or 11
	local showcase = Instance.new("Model")
	showcase.Name = "HammerShowcase"

	local rows: { [string]: { { [string]: any } } } = {}
	for _, def in load() do
		rows[def.Rarity] = rows[def.Rarity] or {}
		table.insert(rows[def.Rarity], def)
	end

	local rowIndex = 0
	for _, rarity in Palette.RarityOrder do
		local list = rows[rarity]
		if list then
			local info = Palette.Rarity[rarity]
			for i, def in list do
				local x = (i - (#list + 1) / 2) * spacing
				local spot = base * CFrame.new(x, 0, rowIndex * rowGap)

				local pedestal = Instance.new("Part")
				pedestal.Name = def.Id .. "_Pedestal"
				pedestal.Anchored = true
				pedestal.Size = Vector3.new(4.2, 1, 4.2)
				pedestal.CFrame = spot * CFrame.new(0, 0.5, 0)
				pedestal.Material = Enum.Material.Slate
				pedestal.Color = Color3.fromRGB(28, 34, 46)
				pedestal.TopSurface = Enum.SurfaceType.Smooth
				pedestal.BottomSurface = Enum.SurfaceType.Smooth
				pedestal.Parent = showcase

				local trim = Instance.new("Part")
				trim.Name = def.Id .. "_Trim"
				trim.Anchored = true
				trim.CanCollide = false
				trim.Size = Vector3.new(4.4, 0.12, 4.4)
				trim.CFrame = spot * CFrame.new(0, 1.0, 0)
				trim.Material = Enum.Material.Neon
				trim.Color = info.Color
				trim.TopSurface = Enum.SurfaceType.Smooth
				trim.BottomSurface = Enum.SurfaceType.Smooth
				trim.Parent = showcase

				local ok, tool = pcall(HammerForge.Build, def.Id, o.BuildOptions)
				if ok then
					local model = HammerForge.ToDisplayModel(tool)
					local handle = model.PrimaryPart :: BasePart
					local pivot = spot * CFrame.new(0, 3.2 * ((o.BuildOptions and o.BuildOptions.Scale) or 1), 0)
					moveBuilt(model, pivot)
					model:SetAttribute("FX_Turntable", o.TurnSpeed or 0.6)
					model.Parent = showcase

					local gui = Instance.new("BillboardGui")
					gui.Name = "Label"
					gui.Size = UDim2.fromOffset(220, 56)
					gui.StudsOffsetWorldSpace = Vector3.new(0, 4.4, 0)
					gui.AlwaysOnTop = false
					gui.MaxDistance = 90
					gui.Adornee = pedestal
					local title = Instance.new("TextLabel")
					title.Name = "Name"
					title.BackgroundTransparency = 1
					title.Size = UDim2.new(1, 0, 0.6, 0)
					title.FontFace = Font.fromEnum(Enum.Font.FredokaOne)
					title.Text = string.upper(def.DisplayName)
					title.TextScaled = true
					title.TextColor3 = Color3.fromRGB(240, 246, 255)
					title.TextStrokeTransparency = 0.2
					title.Parent = gui
					local tag = Instance.new("TextLabel")
					tag.Name = "Rarity"
					tag.BackgroundTransparency = 1
					tag.Position = UDim2.new(0, 0, 0.6, 0)
					tag.Size = UDim2.new(1, 0, 0.4, 0)
					tag.FontFace = Font.fromEnum(Enum.Font.GothamBlack)
					tag.Text = info.Label
					tag.TextScaled = true
					tag.TextColor3 = info.Color
					tag.TextStrokeTransparency = 0.4
					tag.Parent = gui
					gui.Parent = pedestal
					handle.Anchored = true
				else
					warn(string.format("[HammerForge] Vitrina: falló %s: %s", def.Id, tostring(tool)))
				end
			end
			rowIndex += 1
		end
	end
	showcase.Parent = parent
	return showcase
end

return HammerForge
