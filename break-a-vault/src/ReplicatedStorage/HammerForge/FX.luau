--[[
	HammerForge.FX — efectos visuales de los martillos (SOLO CLIENTE).

	Se inicia una vez desde HammerFXClient (StarterPlayerScripts):
		require(game.ReplicatedStorage.HammerForge.FX).Start()

	Anima todo lo que tenga el tag "BAV_Hammer" dentro de Workspace (martillos equipados por
	cualquier jugador y la vitrina), leyendo atributos que pone el Builder:
	  * Weld "FXWeld" con FX_Spin / FX_Bob / FX_BobSpeed / FX_Phase / FX_BaseC0 → giros y flotación
	  * FX_Pulse (NumberRange) + FX_PulseSpeed en piezas (Transparency) y luces (Brightness)
	  * FX_Flicker (Hz) + FX_FlickerOn (0–1) en carpetas → parpadeo eléctrico
	  * FX_Hue (vueltas/seg) en piezas o luces → arcoíris
	  * FX_Turntable (rad/s) en modelos anclados (vitrina) → giro lento

	CONTRATO PARA LA PARTE FUNCIONAL (Codex):
	  * En el cliente que golpea:  FX.Swing(tool)  y  FX.Impact(tool)
	  * Para que TODOS los clientes lo vean, desde el servidor:
	        tool:SetAttribute("FX_SwingSeq", (tool:GetAttribute("FX_SwingSeq") or 0) + 1)
	        tool:SetAttribute("FX_ImpactSeq", (tool:GetAttribute("FX_ImpactSeq") or 0) + 1)
	    Cada cambio de esos atributos dispara el efecto en todos los clientes (sin RemoteEvents).
	  * FX.OnImpact (BindableEvent opcional) para sacudir la cámara, sonidos, etc.
]]

local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local FX = {}
FX.TAG = "BAV_Hammer"
FX.CullDistance = 160
FX.AutoSwing = true -- el jugador local ve el trail al hacer clic aunque la parte funcional no llame Swing
FX.SwingDuration = 0.32

local TAU = math.pi * 2

type WeldFX = { weld: Weld, base: CFrame, spin: Vector3?, bob: Vector3?, bobSpeed: number, phase: number }
type PulseFX = { inst: Instance, prop: string, min: number, max: number, speed: number, phase: number }
type FlickerFX = { hz: number, on: number, parts: { BasePart }, base: { number }, nextT: number }
type HueFX = { inst: Instance, speed: number, h: number, s: number, v: number }
type Entry = {
	root: Instance,
	handle: BasePart?,
	welds: { WeldFX },
	pulses: { PulseFX },
	flickers: { FlickerFX },
	hues: { HueFX },
	trails: { Trail },
	emitters: { ParticleEmitter },
	flashes: { PointLight },
	turntable: number?,
	pivot: CFrame?,
	swingToken: number,
	conns: { RBXScriptConnection },
}

local entries: { [Instance]: Entry } = {}
local started = false

local impactEvent = Instance.new("BindableEvent")
FX.OnImpact = impactEvent.Event

local function scan(root: Instance): Entry
	local e: Entry = {
		root = root,
		handle = root:FindFirstChild("Handle") :: BasePart?,
		welds = {},
		pulses = {},
		flickers = {},
		hues = {},
		trails = {},
		emitters = {},
		flashes = {},
		turntable = nil,
		pivot = nil,
		swingToken = 0,
		conns = {},
	}
	for _, d in root:GetDescendants() do
		if d:IsA("Weld") and d.Name == "FXWeld" then
			table.insert(e.welds, {
				weld = d,
				base = d:GetAttribute("FX_BaseC0") or d.C0,
				spin = d:GetAttribute("FX_Spin"),
				bob = d:GetAttribute("FX_Bob"),
				bobSpeed = d:GetAttribute("FX_BobSpeed") or 0.5,
				phase = d:GetAttribute("FX_Phase") or 0,
			})
		end
		local pulse = d:GetAttribute("FX_Pulse")
		if typeof(pulse) == "NumberRange" then
			local prop = if d:IsA("BasePart") then "Transparency" elseif d:IsA("Light") then "Brightness" elseif d:IsA("ParticleEmitter") then "Rate" else nil
			if prop then
				table.insert(e.pulses, {
					inst = d,
					prop = prop,
					min = pulse.Min,
					max = pulse.Max,
					speed = d:GetAttribute("FX_PulseSpeed") or 1,
					phase = d:GetAttribute("FX_Phase") or 0,
				})
			end
		end
		local flicker = d:GetAttribute("FX_Flicker")
		if type(flicker) == "number" then
			local parts, base = {}, {}
			for _, p in d:GetDescendants() do
				if p:IsA("BasePart") then
					table.insert(parts, p)
					table.insert(base, p.Transparency)
				end
			end
			table.insert(e.flickers, { hz = flicker, on = d:GetAttribute("FX_FlickerOn") or 0.5, parts = parts, base = base, nextT = 0 })
		end
		local hue = d:GetAttribute("FX_Hue")
		if type(hue) == "number" and (d:IsA("BasePart") or d:IsA("Light")) then
			local h, s, v = (d :: any).Color:ToHSV()
			table.insert(e.hues, { inst = d, speed = hue, h = h, s = math.max(s, 0.6), v = math.max(v, 0.8) })
		end
		if d:IsA("Trail") and d.Name == "SwingTrail" then
			table.insert(e.trails, d)
		elseif d:IsA("ParticleEmitter") and d:GetAttribute("FX_Emit") then
			table.insert(e.emitters, d)
		elseif d:IsA("PointLight") and d:GetAttribute("FX_Flash") then
			table.insert(e.flashes, d)
		end
	end
	local tt = root:GetAttribute("FX_Turntable")
	if type(tt) == "number" and root:IsA("Model") then
		e.turntable = tt
		e.pivot = root:GetPivot()
	end
	table.insert(e.conns, root:GetAttributeChangedSignal("FX_SwingSeq"):Connect(function()
		FX.Swing(root)
	end))
	table.insert(e.conns, root:GetAttributeChangedSignal("FX_ImpactSeq"):Connect(function()
		FX.Impact(root)
	end))
	if root:IsA("Tool") then
		table.insert(e.conns, root.Activated:Connect(function()
			if FX.AutoSwing then
				local player = Players.LocalPlayer
				if player and root.Parent == player.Character then
					FX.Swing(root)
				end
			end
		end))
	end
	return e
end

local function track(inst: Instance)
	if entries[inst] then
		return
	end
	entries[inst] = scan(inst)
end

local function untrack(inst: Instance)
	local e = entries[inst]
	if e then
		for _, c in e.conns do
			c:Disconnect()
		end
		entries[inst] = nil
	end
end

local function update()
	local t = os.clock()
	local cam = Workspace.CurrentCamera
	local camPos = if cam then cam.CFrame.Position else nil
	for root, e in entries do
		if not root.Parent or not root:IsDescendantOf(Workspace) then
			continue
		end
		local h = e.handle
		if h and camPos and (h.Position - camPos).Magnitude > FX.CullDistance then
			continue
		end
		for _, w in e.welds do
			local tt = t + w.phase
			local cf = w.base
			if w.bob then
				cf *= CFrame.new(w.bob * math.sin(tt * w.bobSpeed * TAU))
			end
			if w.spin then
				local mag = w.spin.Magnitude
				if mag > 0 then
					cf *= CFrame.fromAxisAngle(w.spin / mag, (mag * tt) % TAU)
				end
			end
			w.weld.C0 = cf
		end
		for _, p in e.pulses do
			local inst: any = p.inst
			local a = 0.5 + 0.5 * math.sin((t + p.phase) * p.speed * TAU)
			inst[p.prop] = p.min + (p.max - p.min) * a
		end
		for _, f in e.flickers do
			if t >= f.nextT then
				f.nextT = t + 1 / f.hz
				for i, part in f.parts do
					part.Transparency = if math.random() < f.on then f.base[i] else 1
				end
			end
		end
		for _, hu in e.hues do
			local inst: any = hu.inst
			inst.Color = Color3.fromHSV((hu.h + t * hu.speed) % 1, hu.s, hu.v)
		end
		if e.turntable and e.pivot and root:IsA("Model") then
			root:PivotTo(e.pivot * CFrame.Angles(0, (t * e.turntable) % TAU, 0))
		end
	end
end

local function resolve(target: Instance): Entry?
	local e = entries[target]
	if not e then
		track(target)
		e = entries[target]
	end
	return e
end

--- Enciende el trail del golpe por un momento.
function FX.Swing(tool: Instance)
	local e = resolve(tool)
	if not e then
		return
	end
	e.swingToken += 1
	local token = e.swingToken
	for _, tr in e.trails do
		tr.Enabled = true
	end
	task.delay(FX.SwingDuration, function()
		if e.swingToken == token then
			for _, tr in e.trails do
				tr.Enabled = false
			end
		end
	end)
end

--- Explosión de chispas + flash de luz en la cara de golpe.
function FX.Impact(tool: Instance)
	local e = resolve(tool)
	if not e then
		return
	end
	for _, em in e.emitters do
		em:Emit(em:GetAttribute("FX_Emit") or 10)
	end
	for _, l in e.flashes do
		l.Brightness = l:GetAttribute("FX_Flash") or 5
		TweenService:Create(l, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Brightness = 0 }):Play()
	end
	impactEvent:Fire(tool)
end

function FX.Start()
	if started then
		return
	end
	started = true
	for _, inst in CollectionService:GetTagged(FX.TAG) do
		track(inst)
	end
	CollectionService:GetInstanceAddedSignal(FX.TAG):Connect(track)
	CollectionService:GetInstanceRemovedSignal(FX.TAG):Connect(untrack)
	RunService.RenderStepped:Connect(update)
end

return FX
