-- Void Smasher (Mythic) — un pedazo de roca negra arrancado del borde de un agujero negro.
-- Cabeza de piedra obsidiana biselada y rajada, con grietas de neón morado que laten. En ambas caras, la
-- VENTANA GALÁCTICA: marco octagonal de piedra con remaches, fondo de vacío, espiral de dos brazos morado/rosa
-- con núcleo blanco y estrellas, todo girando bajo un vidrio violeta. Bandas de acero gris remachadas separan
-- el centro de los remates, que llevan remolinos pequeños, picos de obsidiana arriba y tapas de golpe con
-- un portal morado. Dos anillos de energía tipo cometa orbitan la cabeza y cubos de roca flotan alrededor.
-- Mango de bloques de piedra con costuras de neón, collar de acero y pomo con gema de vacío.
-- FX: partículas que se succionan hacia el núcleo, destellos morados, orbes, luz morada pulsante.
return {
	Id = "VoidSmasher",
	DisplayName = "Void Smasher",
	Rarity = "Mythic",
	Order = 4,
	Theme = "Void Rift",
	Build = function(b, P, B)
		local A = B.Anatomy
		local headY = A.HeadY + 0.1
		local TAU = math.pi * 2

		-- ── estilos ─────────────────────────────────────────────
		local obsidian = P.style(P.rgb(26, 22, 36), Enum.Material.Basalt, 0.06)
		local stone = P.style(P.rgb(44, 40, 56), Enum.Material.Basalt, 0.04)
		local stoneEdge = P.style(P.rgb(104, 98, 124), Enum.Material.Slate, 0.04) -- arista clara
		local steel = P.metal(P.rgb(116, 118, 132), 0.16)
		local steelEdge = P.metal(P.rgb(176, 178, 194), 0.22)
		local voidBlack = P.metal(P.rgb(8, 4, 16), 0)
		local purple = P.rgb(160, 70, 255)
		local purpleHot = P.rgb(230, 160, 255)
		local pink = P.rgb(255, 150, 240)
		local neon = P.neon(purple)
		local neonHot = P.neon(purpleHot)
		local neonPink = P.neon(pink)
		local neonWhite = P.neon(P.rgb(255, 236, 255))
		local crackSt = P.neon(P.rgb(170, 80, 255), 0.05)
		local nebula = P.neon(P.rgb(110, 40, 220), 0.45)
		local glass = P.glass(P.rgb(170, 110, 255), 0.6)

		-- ── medidas ────────────────────────────────────────────
		local CW, CH, CD = 1.7, 2.1, 1.95 -- bloque central
		local bandX = 0.93
		local EX0, EX1 = 1.05, 1.98 -- remates
		local EH, ED = 2.2, 2.06
		local capX = EX1 + 0.07

		-- ── helpers ────────────────────────────────────────────
		-- espiral de 2 brazos sobre el plano `plane` (XY local); devuelve las piezas
		local function spiral(plane: CFrame, R: number, w: number, segs: number, turns: number, z: number, list)
			local n = plane.LookVector
			for arm = 0, 1 do
				local pts = {}
				for i = 0, segs do
					local t = i / segs
					local r = R * (0.12 + 0.88 * t)
					local a = arm * math.pi + t * turns * TAU
					table.insert(pts, plane:PointToWorldSpace(Vector3.new(math.cos(a) * r, math.sin(a) * r, z)))
				end
				for k, p in b:polyline(pts, w, 0.04, if arm == 0 then neonPink else neonHot, n, false, "Spiral") do
					table.insert(list, p)
				end
			end
		end
		-- grieta de neón (zigzag) sobre una cara: p0/p1 en coords locales de `face`
		local function crack(face: CFrame, p0: Vector2, p1: Vector2, segs: number, amp: number, seed: number, w: number?)
			local pts = B.jitterPath(Vector3.new(p0.X, p0.Y, 0), Vector3.new(p1.X, p1.Y, 0), segs, amp, seed, Vector3.zAxis)
			local world = {}
			for _, p in pts do
				table.insert(world, face:PointToWorldSpace(Vector3.new(p.X, p.Y, 0.012)))
			end
			return b:polyline(world, w or 0.05, 0.04, crackSt, face.LookVector, false, "VoidCrack")
		end
		-- anillo "cometa": cabeza opaca y cola que se desvanece (al girar se ve la persecución)
		local function cometRing(cf: CFrame, radius: number, n: number, tube: number, color: Color3, name: string)
			local out = {}
			local segLen = TAU * radius / n * 1.08
			for i = 0, n - 1 do
				local th = TAU * i / n
				local t = (i / n) ^ 1.1
				local st = P.neon(P.lighten(color, 0.35 * (1 - t)), 0.02 + 0.9 * t)
				table.insert(out, b:box(Vector3.new(tube, tube, segLen), cf * CFrame.Angles(0, -th, 0) * CFrame.new(radius, 0, 0), st, name))
			end
			return out
		end

		local cracks = {}
		local function addCracks(list)
			for _, p in list do
				table.insert(cracks, p)
			end
		end

		b:group("Head", function()
			-- ── bloque central ─────────────────────────────────
			b:bevelBox(Vector3.new(CW, CH, CD), CFrame.new(0, headY, 0), obsidian, 0.16, { edges = "X", edgeStyle = stoneEdge, name = "Core" })

			-- ventana galáctica (ambas caras)
			B.both(function(s)
				local face = B.faceZ(s, headY, CD / 2)
				b:bevelBox(Vector3.new(1.56, 1.56, 0.12), face * CFrame.new(0, 0, 0.04), stone, 0.42, { edges = "Z", edgeStyle = stoneEdge, name = "WindowFrame" })
				for i = 0, 3 do
					local a = TAU * i / 4 + math.pi / 4
					b:rivet(face:PointToWorldSpace(Vector3.new(math.cos(a) * 0.7, math.sin(a) * 0.7, 0.1)), 0.09, steelEdge)
				end
				b:cylZ(0.1, 1.26, face * CFrame.new(0, 0, 0.07), voidBlack, "Void")
				local neb = b:cylZ(0.04, 1.1, face * CFrame.new(0, 0, 0.13), nebula, "Nebula")
				b:pulse({ neb }, 0.4, 0.75, 0.8, if s > 0 then 0 else 0.4)
				-- espiral + estrellas + núcleo (giran)
				local spin = {}
				local sp = face * CFrame.new(0, 0, 0.16)
				spiral(sp, 0.58, 0.06, 9, 1.15, 0, spin)
				local rnd = B.rng(if s > 0 then 4 else 8)
				for i = 0, 1 do
					local a = rnd(0, TAU)
					local r = rnd(0.25, 0.55)
					table.insert(spin, b:ball(if i == 0 then 0.07 else 0.05, sp:PointToWorldSpace(Vector3.new(math.cos(a) * r, math.sin(a) * r, 0.01)), neonWhite, "Star"))
				end
				b:animate(spin, sp, { Spin = Vector3.new(0, 0, -0.9 * s) })
				local core = b:ball(0.22, sp * CFrame.new(0, 0, 0.02), neonWhite, "GalaxyCore")
				b:ball(0.36, sp, P.neon(pink, 0.45), "GalaxyHalo")
				b:pulse({ core }, 0, 0.35, 1.6)
				b:cylZ(0.06, 1.3, face * CFrame.new(0, 0, 0.24), glass, "WindowGlass")
				-- grietas que salen de la ventana
				addCracks(crack(face, Vector2.new(-0.62, 0.62), Vector2.new(-0.8, 0.98), 2, 0.05, 11 + s))
				addCracks(crack(face, Vector2.new(0.6, -0.62), Vector2.new(0.78, -0.98), 2, 0.05, 21 + s))
			end)


			-- ── bandas de acero, remates, tapas ───────────────
			B.both(function(sx)
				local bcf = CFrame.new(sx * bandX, headY, 0)
				b:bevelBox(Vector3.new(0.22, CH + 0.16, CD + 0.16), bcf, steel, 0.1, { edges = "X", edgeStyle = steelEdge, name = "Band" })
				for _, sz in { 1, -1 } do
					b:rivetLine(Vector3.new(sx * bandX, headY - 0.78, sz * (CD / 2 + 0.09)), Vector3.new(sx * bandX, headY + 0.78, sz * (CD / 2 + 0.09)), 2, 0.12, steelEdge)
				end

				-- remate de obsidiana biselado (todas las aristas)
				local ex = sx * (EX0 + EX1) / 2
				local ecf = CFrame.new(ex, headY, 0)
				b:bevelBox(Vector3.new(EX1 - EX0, EH, ED), ecf, obsidian, 0.17, { edgeStyle = stoneEdge, name = "End" })
				-- banda de acero exterior delgada
				b:box(Vector3.new(0.12, EH + 0.06, ED + 0.06), CFrame.new(sx * (EX1 - 0.14), headY, 0), steel, "EndBand")
				-- caras ±Z: grietas + remolino pequeño
				for _, sz in { 1, -1 } do
					local f = B.faceZ(sz, headY, ED / 2, ex - sx * 0.06)
					local k = sx * sz
					addCracks(crack(f, Vector2.new(-k * 0.36, 0.98), Vector2.new(k * 0.05, 0.36), 3, 0.1, 41 + sx * 3 + sz))
					addCracks(crack(f, Vector2.new(k * 0.3, -0.98), Vector2.new(-k * 0.12, -0.42), 3, 0.1, 51 + sx * 3 + sz))
					-- remolino pequeño (gira)
					local wcf = f * CFrame.new(0, 0, 0.02)
					b:cylZ(0.05, 0.72, wcf, steel, "SmallVoidRim")
					b:cylZ(0.05, 0.6, wcf * CFrame.new(0, 0, 0.02), voidBlack, "SmallVoid")
					b:cylZ(0.04, 0.52, wcf * CFrame.new(0, 0, 0.035), nebula, "SmallNebula")
					local sw = {}
					spiral(wcf * CFrame.new(0, 0, 0.065), 0.26, 0.045, 5, 1.0, 0, sw)
					table.insert(sw, b:ball(0.1, wcf * CFrame.new(0, 0, 0.065), neonWhite, "SmallCore"))
					b:animate(sw, wcf * CFrame.new(0, 0, 0.065), { Spin = Vector3.new(0, 0, -1.3 * sz) })
				end
				-- pico de obsidiana arriba del remate
				b:pyramid(CFrame.new(ex - sx * 0.05, headY + EH / 2 - 0.02, 0.15 * sx) * CFrame.Angles(0, 0.3, sx * -0.18), 0.62, 0.44, 3, stone, "TopSpike")

				-- tapa de golpe: marco de piedra octagonal + disco portal morado bajo vidrio
				local capCF = CFrame.new(sx * capX, headY, 0)
				b:bevelBox(Vector3.new(0.14, 1.7, 1.6), capCF, stone, 0.44, { edges = "X", edgeStyle = stoneEdge, name = "StrikeCap" })
				local fcf = B.faceX(sx, capX + 0.07, headY)
				b:cylZ(0.06, 1.0, fcf * CFrame.new(0, 0, 0.01), voidBlack, "Portal")
				local pr = b:cylZ(0.05, 0.8, fcf * CFrame.new(0, 0, 0.03), neon, "PortalRing")
				b:cylZ(0.05, 0.58, fcf * CFrame.new(0, 0, 0.045), voidBlack, "PortalInner")
				b:cylZ(0.05, 0.22, fcf * CFrame.new(0, 0, 0.06), neonWhite, "PortalCore")
				b:cylZ(0.06, 1.04, fcf * CFrame.new(0, 0, 0.07), glass, "PortalGlass")
				b:pulse({ pr }, 0, 0.45, 1.3, if sx > 0 then 0 else 0.6)
			end)
		end)
		b:pulse(cracks, 0.0, 0.55, 0.9)

		-- ── anillos orbitales (cometa) ─────────────────────────
		local ringA = CFrame.new(0, headY, 0) * CFrame.Angles(math.rad(16), 0, math.rad(-12))
		b:animate(cometRing(ringA, 2.3, 16, 0.09, purple, "OrbitRing"), ringA, { Spin = Vector3.new(0, 1.4, 0) })
		local ringB = CFrame.new(-1.55, headY, 0) * CFrame.Angles(0, 0, math.pi / 2) * CFrame.Angles(math.rad(22), 0, 0)
		b:animate(cometRing(ringB, 1.62, 12, 0.075, pink, "OrbitRingEnd"), ringB, { Spin = Vector3.new(0, -1.9, 0) })

		-- ── escombros: cubos de roca flotando alrededor ────────
		local rnd = B.rng(77)
		for g = 0, 1 do
			local list = {}
			for i = 0, 4 do
				local a = TAU * (i + g * 0.5) / 5 + rnd(-0.2, 0.2)
				local r = 2.05 + rnd(-0.2, 0.25)
				local pos = Vector3.new(math.cos(a) * r, headY + rnd(-1.4, 1.4), math.sin(a) * r * 0.7)
				local size = rnd(0.28, 0.46)
				local rot = CFrame.Angles(rnd(0, 3), rnd(0, 3), rnd(0, 3))
				table.insert(list, b:box(Vector3.new(size, size, size), CFrame.new(pos) * rot, if i % 2 == 0 then stone else obsidian, "Debris"))
				-- vena de neón que atraviesa el cubo (lo hace leer contra el fondo oscuro)
				table.insert(list, b:box(Vector3.new(size * 1.04, 0.05, size * 0.3), CFrame.new(pos) * rot * CFrame.new(0, 0, size * 0.12), if i % 2 == 0 then neon else neonHot, "DebrisVein"))
			end
			b:animate(list, CFrame.new(0, headY, 0), { Spin = Vector3.new(0, if g == 0 then 0.35 else -0.25, 0), Bob = Vector3.new(0, 0.14, 0), BobSpeed = 0.35 + g * 0.15, Phase = g * 1.3 })
		end

		-- ── mango ───────────────────────────────────────────────
		b:group("Shaft", function()
			local top = headY - CH / 2
			local bottom = A.ShaftBottom
			-- collar: bloque de acero + bloque de piedra
			b:bevelBox(Vector3.new(0.84, 0.2, 0.84), CFrame.new(0, top - 0.1, 0), steel, 0.16, { edges = "Y", edgeStyle = steelEdge, name = "Collar" })
			b:bevelBox(Vector3.new(0.7, 0.3, 0.7), CFrame.new(0, top - 0.35, 0), stone, 0.12, { edges = "Y", edgeStyle = stoneEdge, name = "CollarStone" })
			-- eje de vacío (se ve en las costuras)
			b:box(Vector3.new(0.34, top - bottom - 0.4, 0.34), CFrame.new(0, (top + bottom) / 2 - 0.2, 0), voidBlack, "ShaftCore")
			-- bloques de piedra con costuras de neón
			local g0, g1 = bottom + 0.05, top - 0.52
			local n = 4
			local step = (g1 - g0) / n
			for i = 0, n - 1 do
				local y = g0 + step * (i + 0.5)
				local w = if i % 2 == 0 then 0.5 else 0.46
				b:bevelBox(Vector3.new(w, step - 0.1, w), CFrame.new(0, y, 0) * CFrame.Angles(0, (i % 2) * 0.12, 0), obsidian, 0.08, { edges = "Y", edgeStyle = stoneEdge, name = "GripBlock" })
				if i > 0 then
					local seam = b:box(Vector3.new(0.4, 0.07, 0.4), CFrame.new(0, g0 + step * i, 0), neon, "Seam")
					b:pulse({ seam }, 0, 0.5, 1.2, i * 0.25)
				end
			end
			addCracks(crack(CFrame.new(0, 0.4, 0.251), Vector2.new(0.05, 0.5), Vector2.new(-0.08, -0.3), 3, 0.06, 91, 0.035))
		end)

		-- ── pomo ────────────────────────────────────────────────
		b:group("Pommel", function()
			local y = A.PommelY - 0.05
			b:bevelBox(Vector3.new(0.7, 0.12, 0.7), CFrame.new(0, y + 0.3, 0), steel, 0.12, { edges = "Y", edgeStyle = steelEdge, name = "PommelBand" })
			b:bevelBox(Vector3.new(0.86, 0.46, 0.86), CFrame.new(0, y, 0), stone, 0.14, { edgeStyle = stoneEdge, name = "Pommel" })
			-- gema de vacío en cada cara del pomo
			for i = 0, 3 do
				local a = i * math.pi / 2
				local f = CFrame.new(math.cos(a) * 0.43, y, math.sin(a) * 0.43) * CFrame.Angles(0, -a + math.pi / 2, 0)
				b:box(Vector3.new(0.22, 0.22, 0.04), f * CFrame.Angles(0, 0, math.pi / 4), neon, "PommelRune")
			end
			b:pyramid(CFrame.new(0, y - 0.22, 0) * CFrame.Angles(math.pi, math.pi / 4, 0), 0.42, 0.5, 4, P.crystal(purple, 0.25), "PommelGem")
			local gc = b:ball(0.22, CFrame.new(0, y - 0.32, 0), neonHot, "PommelCore")
			b:pulse({ gc }, 0, 0.5, 1.2)
		end)

		-- ── efectos ─────────────────────────────────────────────
		b:group("FX", function()
			local sphere = b:fxVolume(Vector3.new(3.4, 3.4, 3.4), CFrame.new(0, headY, 0), "ImplodeVolume")
			b:emitter(sphere, B.Particles.implode(purpleHot, 16), "Implode")
			local v = b:fxVolume(Vector3.new(4.2, 2.6, 2.6), CFrame.new(0, headY, 0), "VoidVolume")
			b:emitter(v, B.Particles.sparkle(purple, 10), "Sparkle")
			b:emitter(v, B.Particles.orb(P.rgb(120, 50, 230), 6), "VoidOrbs")
			B.both(function(s)
				local w = b:fxVolume(Vector3.new(0.9, 0.9, 0.1), CFrame.new(0, headY, s * (CD / 2 + 0.3)), "WindowVolume")
				local stars = B.Particles.sparkle(P.rgb(255, 220, 255), 4)
				stars.Size = B.seq(0, 0, 0.3, 0.16, 1, 0)
				stars.Speed = NumberRange.new(0.05, 0.2)
				b:emitter(w, stars, "Twinkle")
			end)
		end)
		b:light(Vector3.new(0, headY, 0), purple, 2.8, 12, { pulse = { 1.6, 3.6 }, pulseSpeed = 0.9, name = "VoidLight" })
		b:light(Vector3.new(-capX - 0.4, headY, 0), pink, 1.2, 7, { pulse = { 0.5, 1.6 }, pulseSpeed = 1.3, name = "PortalLight" })

		-- impacto: chispas moradas + implosión + fragmentos de roca + destello
		local imp = B.Particles.implode(purpleHot, 0)
		imp.Lifetime = NumberRange.new(0.3, 0.5)
		local shards = B.Particles.sparkle(purple, 0)
		shards.Speed = NumberRange.new(8, 14)
		shards.Acceleration = Vector3.new(0, -20, 0)
		local dust = B.Particles.smoke(P.rgb(60, 40, 90), 0)
		dust.Speed = NumberRange.new(2, 4)
		dust.Size = B.seq(0, 0.8, 1, 2.4)
		local hit = b:impact(CFrame.new(-capX - 0.2, headY, 0), purple, { sparks = 26, flash = 9, extra = { imp, shards, dust } })
		hit:FindFirstChild("ImpactExtra1"):SetAttribute("FX_Emit", 30)
		hit:FindFirstChild("ImpactExtra2"):SetAttribute("FX_Emit", 18)
		hit:FindFirstChild("ImpactExtra3"):SetAttribute("FX_Emit", 6)
		b:trail(Vector3.new(0, headY + CH / 2 + 0.3, 0), Vector3.new(0, headY - CH / 2 - 0.3, 0), purpleHot, P.rgb(70, 20, 160), { lifetime = 0.28 })
	end,
}
