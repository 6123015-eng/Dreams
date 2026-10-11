-- Nitro Sledge (Rare) — un mazo de carreras con motor de nitro. Cabeza roja pintada (aristas claras) con
-- placa de advertencia amarilla y FLAMA negra con núcleo de neón naranja en ambas caras; bandas de acero
-- remachadas. El extremo de golpe (-X) es un bloque de escape: placa de acero perforada con puertos que
-- brillan por dentro y escupen llamas y chispas. El otro extremo (+X) tiene una TURBINA que gira rápido
-- detrás de un bisel de acero, con resplandor naranja. Canistros rojos de nitro con válvulas doradas a los
-- lados, tanque grande arriba conectado por manguera, y costuras de luz naranja en los bloques.
-- Mango rojo con correas negras cruzadas, collar de acero y pomo negro con anillo de acero.
return {
	Id = "NitroSledge",
	DisplayName = "Nitro Sledge",
	Rarity = "Rare",
	Order = 4,
	Theme = "Speedway",
	Build = function(b, P, B)
		local A = B.Anatomy
		local headY = A.HeadY

		-- ── estilos ─────────────────────────────────────────────
		local red = P.paint(P.rgb(200, 30, 32))
		local redEdge = P.metal(P.rgb(250, 96, 84), 0.12) -- arista clara
		local redDark = P.paint(P.rgb(128, 18, 22))
		local steel = P.metal(P.rgb(150, 156, 166), 0.16)
		local steelEdge = P.metal(P.rgb(205, 212, 222), 0.22)
		local dark = P.metal(P.rgb(46, 46, 52), 0.06)
		local black = P.Blackened
		local chrome = P.Chrome
		local gold = P.metal(P.rgb(236, 170, 40), 0.14)
		local yellow = P.paint(P.rgb(255, 188, 36))
		local yellowEdge = P.paint(P.rgb(214, 112, 16))
		local hot = P.neon(P.rgb(255, 110, 20))
		local hotCore = P.neon(P.rgb(255, 190, 60))
		local hose = P.leather(P.rgb(28, 28, 32))
		local gripRed = P.leather(P.rgb(176, 28, 30))

		local glow = {}

		local function oct(len: number, dia: number, cf: CFrame, st, name: string?)
			local s = dia * 0.4142
			local t = dia * 0.2071
			b:box(Vector3.new(dia, len, s), cf, st, name)
			b:box(Vector3.new(s, len, dia), cf, st, name)
			for i = 0, 3 do
				b:box(Vector3.new(t, len, s), cf * CFrame.Angles(0, math.rad(45 + 90 * i), 0) * CFrame.new(dia / 2 - t / 2, 0, 0), st, name)
			end
		end

		local function pts(list, w: number, h: number)
			local out = {}
			for _, p in list do
				table.insert(out, Vector2.new(p[1] * w, p[2] * h))
			end
			return out
		end
		local FLAME = { { 0, -0.5 }, { 0.36, -0.36 }, { 0.46, -0.04 }, { 0.3, 0.26 }, { 0.2, 0.04 }, { 0.06, 0.5 }, { -0.2, 0.2 }, { -0.42, -0.04 }, { -0.36, -0.36 } }
		local FLAME_IN = { { 0, -0.5 }, { 0.34, -0.26 }, { 0.3, 0.1 }, { 0.04, 0.5 }, { -0.22, 0.12 }, { -0.32, -0.24 } }

		-- ── medidas ─────────────────────────────────────────────
		local CW, CH, CD = 1.6, 1.84, 1.84
		local BW, BH = 0.24, 2.0
		local bandX = CW / 2 + BW / 2
		local EW, EH, ED = 0.78, 1.76, 1.76 -- bloques de los extremos
		local EX0 = CW / 2 + BW
		local EX1 = EX0 + EW
		local ex = (EX0 + EX1) / 2

		b:group("Head", function()
			-- ── bloque central rojo
			b:bevelBox(Vector3.new(CW, CH, CD), CFrame.new(0, headY, 0), red, 0.13, { edgeStyle = redEdge, name = "Core" })
			b:box(Vector3.new(CW - 0.34, 0.05, CD - 0.34), CFrame.new(0, headY - CH / 2 - 0.01, 0), redDark, "BottomPlate")

			-- placa de advertencia con flama (ambas caras)
			B.both(function(s)
				local face = B.faceZ(s, headY, CD / 2)
				b:box(Vector3.new(1.2, 1.24, 0.06), face * CFrame.new(0, 0, 0.02), yellowEdge, "PlateFrame")
				b:box(Vector3.new(1.06, 1.1, 0.08), face * CFrame.new(0, 0, 0.03), yellow, "Plate")
				for _, c in { Vector2.new(-1, -1), Vector2.new(1, -1), Vector2.new(1, 1), Vector2.new(-1, 1) } do
					b:rivet(face:PointToWorldSpace(Vector3.new(c.X * 0.44, c.Y * 0.46, 0.08)), 0.11, steelEdge)
				end
				b:shape(face * CFrame.new(0, -0.02, 0.085), pts(FLAME, 0.78, 0.86), 0.04, black, "Flame")
				for _, p in b:shape(face * CFrame.new(0.0, -0.1, 0.1), pts(FLAME_IN, 0.34, 0.44), 0.04, hot, "FlameCore") do
					table.insert(glow, p)
				end
			end)

			-- ── tanque de nitro arriba + manguera al escape
			local tankY = headY + CH / 2 + 0.3
			local tankX0, tankX1 = -0.45, 0.95
			b:cylinder(tankX1 - tankX0, 0.56, CFrame.new((tankX0 + tankX1) / 2, tankY, -0.15), red, "Tank")
			b:cylinder(0.08, 0.6, CFrame.new((tankX0 + tankX1) / 2, tankY, -0.15), redEdge, "TankRib")
			b:cylinder(0.14, 0.5, CFrame.new(tankX1 + 0.05, tankY, -0.15), gold, "TankCap")
			b:cylinder(0.12, 0.26, CFrame.new(tankX1 + 0.17, tankY, -0.15), gold, "TankValve")
			b:box(Vector3.new(0.08, 0.32, 0.08), CFrame.new(tankX1 + 0.17, tankY + 0.2, -0.15), steel, "ValveStem")
			b:box(Vector3.new(0.3, 0.06, 0.08), CFrame.new(tankX1 + 0.17, tankY + 0.36, -0.15), gold, "ValveHandle")
			b:cylinder(0.12, 0.44, CFrame.new(tankX0 - 0.04, tankY, -0.15), steel, "TankEnd")
			for _, x in { tankX0 + 0.25, tankX1 - 0.25 } do
				b:box(Vector3.new(0.12, 0.66, 0.66), CFrame.new(x, tankY - 0.04, -0.15), dark, "TankStrap")
				b:box(Vector3.new(0.16, 0.12, 0.72), CFrame.new(x, tankY - 0.3, -0.15), steel, "TankFoot")
			end
			-- tira de luz a lo largo del tanque
			table.insert(glow, b:box(Vector3.new(0.6, 0.05, 0.06), CFrame.new(-0.05, tankY + 0.27, -0.15), hot, "TankGlow"))
			-- manguera: del tanque al bloque de escape
			local hp = {
				Vector3.new(tankX0 - 0.1, tankY, -0.15),
				Vector3.new(tankX0 - 0.45, tankY + 0.12, -0.25),
				Vector3.new(-(EX0 + 0.25), tankY + 0.02, -0.35),
				Vector3.new(-(EX0 + 0.4), headY + EH / 2 + 0.05, -0.35),
			}
			b:polyline(hp, 0.15, 0.15, hose, nil, false, "Hose")
			b:ball(0.2, hp[3], chrome, "HoseJoint")
			b:cylY(0.1, 0.26, CFrame.new(hp[4]), steel, "HoseFitting")

			-- ── bandas de acero
			B.both(function(sx)
				b:bevelBox(Vector3.new(BW, BH, BH), CFrame.new(sx * bandX, headY, 0), steel, 0.08, { edges = "X", edgeStyle = steelEdge, name = "Band" })
				B.both(function(sz)
					local f = B.faceZ(sz, headY, BH / 2, sx * bandX)
					b:rivet(f:PointToWorldSpace(Vector3.new(0, 0.6, 0.01)), 0.15, chrome)
					b:rivet(f:PointToWorldSpace(Vector3.new(0, -0.6, 0.01)), 0.15, chrome)
				end)
			end)

			-- ── bloques de los extremos (oscuros) con costura de luz
			B.both(function(sx)
				b:bevelBox(Vector3.new(EW, EH, ED), CFrame.new(sx * ex, headY, 0), dark, 0.12, { edges = "X", edgeStyle = steel, name = "EndBlock" })
				-- costuras naranjas abajo (brillan en las aristas inferiores)
				for _, sz in { -1, 1 } do
					table.insert(glow, b:box(Vector3.new(EW - 0.16, 0.05, 0.05), CFrame.new(sx * ex, headY - EH / 2 + 0.2, sz * (ED / 2 + 0.005)), hot, "Seam"))
					table.insert(glow, b:box(Vector3.new(EW - 0.16, 0.05, 0.05), CFrame.new(sx * ex, headY + EH / 2 - 0.2, sz * (ED / 2 + 0.005)), hot, "Seam"))
				end
				-- canistros de nitro en las caras ±Z del bloque
				B.both(function(sz)
					local cz = sz * (ED / 2 + 0.16)
					local cx = sx * (ex + 0.02)
					b:cylY(1.04, 0.44, CFrame.new(cx, headY - 0.04, cz), red, "Canister")
					b:cylY(0.1, 0.48, CFrame.new(cx, headY + 0.46, cz), chrome, "CanisterCap")
					b:cylY(0.1, 0.48, CFrame.new(cx, headY - 0.54, cz), chrome, "CanisterCap")
					table.insert(glow, b:cylY(0.05, 0.47, CFrame.new(cx, headY + 0.18, cz), hot, "CanisterGlow"))
					b:box(Vector3.new(0.5, 0.1, 0.12), CFrame.new(cx, headY - 0.2, sz * (ED / 2 + 0.02)), dark, "CanisterStrap")
					b:cylY(0.12, 0.16, CFrame.new(cx, headY + 0.56, cz), gold, "CanisterValve")
					b:box(Vector3.new(0.22, 0.05, 0.06), CFrame.new(cx, headY + 0.63, cz), gold, "CanisterKnob")
				end)
			end)

			-- ── cara de golpe -X: placa de escape perforada con puertos brillantes
			do
				local f = B.faceX(-1, EX1, headY)
				b:box(Vector3.new(EH - 0.12, EH - 0.12, 0.08), f * CFrame.new(0, 0, 0.02), steel, "ExhaustPlate")
				b:box(Vector3.new(EH - 0.32, EH - 0.32, 0.04), f * CFrame.new(0, 0, 0.06), steelEdge, "ExhaustPlateRim")
				local ports = { Vector2.new(0, 0) }
				for i = 0, 5 do
					local a = math.rad(30 + 60 * i)
					table.insert(ports, Vector2.new(math.cos(a) * 0.48, math.sin(a) * 0.48))
				end
				for _, p in ports do
					b:cylZ(0.1, 0.32, f * CFrame.new(p.X, p.Y, 0.07), black, "Port")
					table.insert(glow, b:cylZ(0.07, 0.18, f * CFrame.new(p.X, p.Y, 0.065), hotCore, "PortGlow"))
				end
				for _, c in { Vector2.new(-1, -1), Vector2.new(1, -1), Vector2.new(1, 1), Vector2.new(-1, 1) } do
					b:rivet(f:PointToWorldSpace(Vector3.new(c.X * 0.7, c.Y * 0.7, 0.09)), 0.12, chrome)
				end
			end

			-- ── cara +X: turbina que gira
			do
				local f = B.faceX(1, EX1, headY)
				b:box(Vector3.new(EH - 0.12, EH - 0.12, 0.06), f * CFrame.new(0, 0, 0.02), dark, "TurbinePlate")
				b:cylZ(0.1, 1.34, f * CFrame.new(0, 0, 0.06), steel, "TurbineBezel")
				b:cylZ(0.04, 1.42, f * CFrame.new(0, 0, 0.04), steelEdge, "TurbineBezelRim")
				b:cylZ(0.04, 1.14, f * CFrame.new(0, 0, 0.1), black, "TurbineRecess")
				table.insert(glow, b:cylZ(0.04, 0.9, f * CFrame.new(0, 0, 0.115), hot, "TurbineGlow"))
				local plane = f * CFrame.new(0, 0, 0.16)
				local fan = {}
				for i = 0, 5 do
					local a = math.pi * 2 * i / 6
					table.insert(fan, b:box(Vector3.new(0.46, 0.15, 0.04), plane * CFrame.Angles(0, 0, a) * CFrame.new(0.3, 0, 0) * CFrame.Angles(math.rad(25), 0, 0), steelEdge, "FanBlade"))
				end
				table.insert(fan, b:cylZ(0.1, 0.26, plane * CFrame.new(0, 0, 0.02), chrome, "FanHub"))
				b:animate(fan, plane, { Spin = Vector3.new(0, 0, 7) })
				for _, c in { Vector2.new(-1, -1), Vector2.new(1, -1), Vector2.new(1, 1), Vector2.new(-1, 1) } do
					b:rivet(f:PointToWorldSpace(Vector3.new(c.X * 0.7, c.Y * 0.7, 0.06)), 0.12, chrome)
				end
			end
		end)

		-- ── mango ───────────────────────────────────────────────
		b:group("Shaft", function()
			local bottom, top = A.ShaftBottom, headY - CH / 2
			b:cylY(top - bottom, 0.48, CFrame.new(0, (top + bottom) / 2, 0), gripRed, "Shaft")
			-- collar de acero
			oct(0.4, 0.74, CFrame.new(0, top - 0.2, 0), steel, "Collar")
			b:disc(CFrame.new(0, top - 0.42, 0), 0.64, 0.06, steelEdge, "CollarLip")
			b:disc(CFrame.new(0, top - 0.02, 0), 0.8, 0.05, dark, "CollarTop")
			-- correas negras cruzadas sobre el rojo
			for i = 0, 5 do
				local tilt = if i % 2 == 0 then 0.45 else -0.45
				b:cylY(0.06, 0.52, CFrame.new(0, -0.62 + i * 0.3, 0) * CFrame.Angles(0, i * 0.6, 0) * CFrame.Angles(tilt, 0, 0), hose, "Strap")
			end
			-- banda de acero abajo con remache
			b:disc(CFrame.new(0, -1.02, 0), 0.6, 0.2, steel, "LowBand")
			b:disc(CFrame.new(0, -1.02, 0), 0.64, 0.05, steelEdge, "LowBandRidge")
			b:rivet(Vector3.new(0, -1.02, 0.31), 0.12, chrome)
			b:rivet(Vector3.new(0, -1.02, -0.31), 0.12, chrome)
		end)

		-- ── pomo ────────────────────────────────────────────────
		b:group("Pommel", function()
			local py = A.PommelY - 0.06
			oct(0.42, 0.8, CFrame.new(0, py, 0), dark, "Pommel")
			b:disc(CFrame.new(0, py + 0.23, 0), 0.7, 0.06, steelEdge, "PommelBevel")
			b:disc(CFrame.new(0, py - 0.23, 0), 0.7, 0.06, steel, "PommelBevel")
			b:cylY(0.06, 0.46, CFrame.new(0, py - 0.28, 0), black, "PommelCap")
			table.insert(glow, b:cylY(0.06, 0.18, CFrame.new(0, py - 0.29, 0), hot, "PommelGlow"))
		end)

		-- ── efectos ─────────────────────────────────────────────
		b:pulse(glow, 0, 0.3, 2)
		b:light(Vector3.new(-(EX1 + 0.3), headY, 0), P.rgb(255, 110, 40), 1.8, 9, { pulse = { 1.0, 2.6 }, pulseSpeed = 2 })
		-- llamas y chispas saliendo de los puertos de escape
		local ex0 = b:fxVolume(Vector3.new(0.1, 1.1, 1.1), CFrame.new(-(EX1 + 0.12), headY, 0), "ExhaustVolume")
		local fl = B.Particles.flame(P.rgb(255, 120, 30), 7)
		fl.EmissionDirection = Enum.NormalId.Left
		fl.Size = B.seq(0, 0.32, 0.5, 0.5, 1, 0)
		fl.Speed = NumberRange.new(2, 3.5)
		fl.Lifetime = NumberRange.new(0.2, 0.4)
		fl.Acceleration = Vector3.new(0, 2, 0)
		b:emitter(ex0, fl, "ExhaustFlame")
		local sp = B.Particles.ember(P.rgb(255, 170, 60), 4)
		sp.EmissionDirection = Enum.NormalId.Left
		sp.Speed = NumberRange.new(2, 4)
		b:emitter(ex0, sp, "ExhaustSparks")

		-- golpe: chispas naranjas + bocanada de fuego + humo
		local boom = B.Particles.flame(P.rgb(255, 110, 20), 0)
		boom.Speed = NumberRange.new(3, 7)
		boom.SpreadAngle = Vector2.new(70, 70)
		boom.Size = B.seq(0, 0.8, 0.5, 1.2, 1, 0)
		local smoke = B.Particles.smoke(P.rgb(70, 66, 66), 0)
		b:impact(CFrame.new(-(EX1 + 0.15), headY, 0), P.rgb(255, 120, 30), {
			sparks = 28,
			flash = 7,
			extra = { boom, smoke },
		})
		b:trail(Vector3.new(0, headY + BH / 2, 0), Vector3.new(0, headY - BH / 2, 0), P.rgb(255, 210, 120), P.rgb(220, 30, 20), { lifetime = 0.24 })
	end,
}
