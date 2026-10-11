-- Cyber Hammer (Epic) — un martillo de asalto sci-fi: chasis de grafito con placas de blindaje
-- blanco-plata biseladas y circuitos de neón morado corriendo por las ranuras entre placas.
-- Al centro, en ambas caras, un panel blindado con el emblema TRIÁNGULO "play" de neón (halo que
-- late y núcleo blanco caliente) y trazos de circuito en Y. Corona almenada arriba con luz morada.
-- Remates con placas partidas, ranuras verticales de energía y tapas de golpe octagonales con
-- cuadrantes de blindaje y cruz de neón. Algunos segmentos del circuito parpadean como "glitch".
-- Mango de grafito segmentado con anillos de acero y tres franjas moradas bajo vidrio, collar y
-- pomo octagonales. FX: destellos holográficos, motas moradas, luz pulsante, impacto de píxeles.
return {
	Id = "CyberHammer",
	DisplayName = "Cyber Hammer",
	Rarity = "Epic",
	Order = 3,
	Theme = "Cyber City",
	Build = function(b, P, B)
		local A = B.Anatomy
		local headY = A.HeadY + 0.05

		-- ── estilos ─────────────────────────────────────────────
		local graphite = P.metal(P.rgb(38, 38, 48), 0.08) -- chasis
		local graphiteEdge = P.metal(P.rgb(92, 92, 108), 0.14)
		local armor = P.metal(P.rgb(150, 152, 168), 0.12) -- blindaje blanco-plata
		local armorEdge = P.metal(P.rgb(214, 216, 230), 0.2)
		local armorDark = P.metal(P.rgb(100, 102, 118), 0.1)
		local black = P.Blackened
		local rubber = P.GripRubber
		local purple = P.rgb(186, 60, 255)
		local purpleHot = P.rgb(232, 170, 255)
		local neon = P.neon(purple)
		local neonHot = P.neon(purpleHot)
		local halo = P.neon(P.rgb(150, 40, 255), 0.55)
		local glass = P.glass(P.rgb(210, 170, 255), 0.62)

		-- ── medidas ────────────────────────────────────────────
		local CW, CH, CD = 1.5, 1.9, 1.9
		local gx = CW / 2 + 0.08
		local EX0, EX1 = CW / 2 + 0.16, 1.76
		local EW, EH, ED = EX1 - EX0, 2.02, 2.02
		local ex = (EX0 + EX1) / 2
		local capX = EX1 + 0.09
		local outerX = capX + 0.09

		local circuit = {} -- piezas que "laten" en secuencia

		b:group("Head", function()
			-- ── núcleo ─────────────────────────────────────────
			b:bevelBox(Vector3.new(CW, CH, CD), CFrame.new(0, headY, 0), graphite, 0.12, { edges = "Z", edgeStyle = graphiteEdge, name = "Core" })

			B.both(function(s)
				local face = B.faceZ(s, headY, CD / 2)
				-- panel blindado con marco
				b:bevelBox(Vector3.new(1.36, 1.62, 0.12), face * CFrame.new(0, 0, 0.05), armor, 0.1, { edges = "Z", edgeStyle = armorEdge, name = "Panel" })
				-- ventana oscura del emblema
				b:bevelBox(Vector3.new(1.0, 0.92, 0.06), face * CFrame.new(0, 0.2, 0.1), black, 0.16, { edges = "Z", name = "EmblemWell" })
				-- triángulo "play" apuntando hacia abajo: halo + neón + núcleo caliente
				local tp = face * CFrame.new(0, 0.2, 0.14) * CFrame.Angles(0, 0, math.pi)
				local h = b:shape(tp, B.Shapes.triangle(0.84, 0.72), 0.03, halo, "TriHalo")
				b:shape(tp * CFrame.new(0, 0.02, 0.03), B.Shapes.triangle(0.64, 0.54), 0.04, neon, "Triangle")
				b:shape(tp * CFrame.new(0, 0.06, 0.055), B.Shapes.triangle(0.28, 0.24), 0.03, neonHot, "TriCore")
				b:pulse(h, 0.2, 0.85, 1.3, if s > 0 then 0 else 0.4)
				-- trazos en Y bajo la ventana (ranura oscura + neón) con terminales
				local tz = 0.12
				local function trace(p0: Vector2, p1: Vector2)
					local a = face:PointToWorldSpace(Vector3.new(p0.X, p0.Y, tz))
					local c = face:PointToWorldSpace(Vector3.new(p1.X, p1.Y, tz))
					b:line(a, c, 0.14, 0.05, black, face.ZVector, "TraceSlot")
					local n = b:line(a + face.ZVector * 0.035, c + face.ZVector * 0.035, 0.07, 0.05, neon, face.ZVector, "Trace")
					table.insert(circuit, n)
				end
				trace(Vector2.new(0, -0.3), Vector2.new(0, -0.5))
				trace(Vector2.new(0, -0.5), Vector2.new(-0.36, -0.66))
				trace(Vector2.new(0, -0.5), Vector2.new(0.36, -0.66))
				for _, x in { -0.5, 0.5 } do
					b:box(Vector3.new(0.14, 0.4, 0.05), face * CFrame.new(x, -0.42, 0.125), black, "PillSlot")
					table.insert(circuit, b:box(Vector3.new(0.07, 0.32, 0.05), face * CFrame.new(x, -0.42, 0.14), neon, "Pill"))
				end
				-- tornillos del panel
				for _, c in { Vector2.new(-1, -1), Vector2.new(1, -1), Vector2.new(1, 1), Vector2.new(-1, 1) } do
					b:rivet(face:PointToWorldSpace(Vector3.new(c.X * 0.56, c.Y * 0.68, 0.1)), 0.08, armorDark)
				end
			end)

			-- corona almenada arriba (luz morada entre almenas)
			local ty = headY + CH / 2
			b:bevelBox(Vector3.new(1.26, 0.12, 1.5), CFrame.new(0, ty + 0.05, 0), armor, 0.05, { edges = "Y", edgeStyle = armorEdge, name = "TopPlate" })
			for _, x in { -0.4, 0.4 } do
				b:bevelBox(Vector3.new(0.34, 0.26, 1.1), CFrame.new(x, ty + 0.22, 0), armor, 0.06, { edges = "Z", edgeStyle = armorEdge, name = "Merlon" })
			end
			b:box(Vector3.new(0.44, 0.1, 1.0), CFrame.new(0, ty + 0.14, 0), black, "CrownWell")
			local crownNeon = b:box(Vector3.new(0.32, 0.08, 0.86), CFrame.new(0, ty + 0.2, 0), neon, "CrownNeon")
			b:box(Vector3.new(0.38, 0.12, 0.94), CFrame.new(0, ty + 0.21, 0), glass, "CrownGlass")
			table.insert(circuit, crownNeon)
			-- abajo
			b:bevelBox(Vector3.new(1.1, 0.08, 1.3), CFrame.new(0, headY - CH / 2 - 0.03, 0), armorDark, 0.04, { edges = "Y", edgeStyle = armor, name = "BottomPlate" })

			-- ── juntas + remates ───────────────────────────────
			B.both(function(sx)
				-- junta oscura con ranura de energía vertical
				b:box(Vector3.new(0.16, CH - 0.16, CD - 0.16), CFrame.new(sx * gx, headY, 0), black, "Gasket")
				for _, sz in { 1, -1 } do
					table.insert(circuit, b:box(Vector3.new(0.07, CH - 0.5, 0.06), CFrame.new(sx * gx, headY, sz * (CD / 2 - 0.1)), neon, "GasketNeon"))
				end

				-- remate: chasis + placas de blindaje partidas
				local ecf = CFrame.new(sx * ex, headY, 0)
				b:bevelBox(Vector3.new(EW, EH, ED), ecf, graphite, 0.14, { edges = "X", edgeStyle = graphiteEdge, name = "End" })
				local pw = EW - 0.3
				local px = sx * (ex + 0.08)
				for _, sz in { 1, -1 } do
					local fz = sz * (ED / 2 + 0.04)
					for _, sy in { 1, -1 } do
						b:bevelBox(Vector3.new(pw, 0.82, 0.1), CFrame.new(px, headY + sy * 0.47, fz), armor, 0.07, { edges = "Z", edgeStyle = armorEdge, name = "EndPlate" })
					end
					-- ranura horizontal de neón entre placas y ranura vertical junto a la junta
					table.insert(circuit, b:box(Vector3.new(pw - 0.1, 0.08, 0.05), CFrame.new(px, headY, sz * (ED / 2 + 0.03)), neon, "EndGroove"))
					local vx = sx * (EX0 + 0.1)
					b:box(Vector3.new(0.14, 1.5, 0.06), CFrame.new(vx, headY, sz * (ED / 2 + 0.01)), black, "SlotWell")
					table.insert(circuit, b:box(Vector3.new(0.09, 1.36, 0.05), CFrame.new(vx, headY, sz * (ED / 2 + 0.03)), neon, "EndSlot"))
					b:box(Vector3.new(0.12, 1.42, 0.05), CFrame.new(vx, headY, sz * (ED / 2 + 0.06)), glass, "EndSlotGlass")
				end
				-- placas arriba/abajo del remate con luz
				for _, sy in { 1, -1 } do
					local y = headY + sy * (EH / 2 + 0.04)
					b:box(Vector3.new(EW - 0.16, 0.1, ED - 0.36), CFrame.new(sx * ex, y, 0), armor, "EndTop")
					b:box(Vector3.new(EW - 0.4, 0.05, 0.08), CFrame.new(sx * ex, y + sy * 0.04, 0), neon, "EndTopNeon")
				end

				-- tapa de golpe: octágono con cuadrantes y cruz de neón
				b:bevelBox(Vector3.new(0.18, 1.84, 1.84), CFrame.new(sx * capX, headY, 0), armorDark, 0.4, { edges = "X", edgeStyle = armorEdge, name = "StrikeCap" })
				local f = B.faceX(sx, capX + 0.09, headY)
				b:box(Vector3.new(1.3, 1.3, 0.04), f * CFrame.new(0, 0, 0.01), black, "CapWell")
				for _, qx in { 1, -1 } do
					for _, qy in { 1, -1 } do
						b:box(Vector3.new(0.54, 0.54, 0.08), f * CFrame.new(qx * 0.33, qy * 0.33, 0.04), armor, "CapQuad")
						b:box(Vector3.new(0.3, 0.3, 0.04), f * CFrame.new(qx * 0.36, qy * 0.36, 0.09), armorEdge, "CapQuadInset")
					end
				end
				table.insert(circuit, b:box(Vector3.new(1.16, 0.09, 0.04), f * CFrame.new(0, 0, 0.035), neon, "CapCross"))
				table.insert(circuit, b:box(Vector3.new(0.09, 1.16, 0.04), f * CFrame.new(0, 0, 0.035), neon, "CapCross"))
				b:cylZ(0.06, 0.24, f * CFrame.new(0, 0, 0.06), neonHot, "CapNode")
			end)
		end)

		-- circuito: oleada de brillo recorriéndolo (fases escalonadas por posición)
		for _, p in circuit do
			local pos = p.CFrame.Position
			local ph = (pos.X + 2) * 0.12 + pos.Z * 0.03
			b:pulse(p, 0, 0.5, 1.2, ph)
		end

		-- segmentos de "glitch" que parpadean (datos cruzando el chasis)
		local glitch = b:group("Glitch", function()
			B.both(function(s)
				local face = B.faceZ(s, headY, CD / 2)
				for i, d in { { -0.62, 0.86, 0.22 }, { 0.6, 0.86, 0.16 }, { -0.62, -0.84, 0.14 }, { 0.62, -0.84, 0.2 } } do
					b:box(Vector3.new(d[3], 0.04, 0.04), face * CFrame.new(d[1], d[2] + (i % 2) * 0.01, 0.13), neonHot, "Data")
				end
			end)
		end)
		b:flicker(glitch, 7, 0.6)

		-- ── mango ───────────────────────────────────────────────
		b:group("Shaft", function()
			local top = headY - CH / 2 - 0.07
			local bottom = A.ShaftBottom
			b:cylY(top - bottom, 0.38, CFrame.new(0, (top + bottom) / 2, 0), graphite, "ShaftCore")
			-- collar octagonal con anillo de neón
			b:bevelBox(Vector3.new(0.66, 0.26, 0.66), CFrame.new(0, top - 0.13, 0), armor, 0.14, { edges = "Y", edgeStyle = armorEdge, name = "Collar" })
			b:cylY(0.07, 0.6, CFrame.new(0, top - 0.3, 0), neon, "CollarNeon")
			b:bevelBox(Vector3.new(0.56, 0.16, 0.56), CFrame.new(0, top - 0.42, 0), armorDark, 0.12, { edges = "Y", edgeStyle = armor, name = "CollarLow" })
			-- agarre segmentado
			local g0, g1 = -1.12, 1.9
			local segs = 6
			local step = (g1 - g0) / segs
			for i = 0, segs - 1 do
				b:cylY(step - 0.08, 0.5, CFrame.new(0, g0 + step * (i + 0.5), 0), rubber, "Grip")
			end
			for i = 0, segs do
				local y = g0 + step * i
				if i == 1 or i == 3 or i == 5 then
					local r = b:cylY(0.1, 0.56, CFrame.new(0, y, 0), neon, "GripNeon")
					b:cylY(0.16, 0.6, CFrame.new(0, y, 0), glass, "GripGlass")
					b:pulse(r, 0, 0.5, 1.2, 1 - i * 0.1)
				else
					b:cylY(0.1, 0.58, CFrame.new(0, y, 0), armor, "GripRing")
				end
			end
		end)

		-- ── pomo ────────────────────────────────────────────────
		b:group("Pommel", function()
			local y = A.PommelY - 0.05
			b:bevelBox(Vector3.new(0.82, 0.5, 0.82), CFrame.new(0, y, 0), armor, 0.22, { edges = "Y", edgeStyle = armorEdge, name = "Pommel" })
			b:bevelBox(Vector3.new(0.84, 0.08, 0.84), CFrame.new(0, y, 0), black, 0.22, { edges = "Y", name = "PommelSlot" })
			b:cylY(0.05, 0.6, CFrame.new(0, y, 0), neon, "PommelNeon")
			b:bevelBox(Vector3.new(0.64, 0.12, 0.64), CFrame.new(0, y - 0.31, 0), graphite, 0.17, { edges = "Y", edgeStyle = graphiteEdge, name = "PommelCap" })
			b:cylY(0.04, 0.22, CFrame.new(0, y - 0.38, 0), neonHot, "PommelNode")
		end)

		-- ── efectos ─────────────────────────────────────────────
		b:group("FX", function()
			local v = b:fxVolume(Vector3.new(3.8, 2.3, 2.3), CFrame.new(0, headY, 0), "HoloVolume")
			local holo = B.Particles.sparkle(P.rgb(206, 140, 255), 9)
			holo.Color = B.colors({ 0, P.rgb(255, 255, 255) }, { 0.4, P.rgb(200, 120, 255) }, { 1, P.rgb(110, 200, 255) })
			b:emitter(v, holo, "HoloSparkle")
			local motes = B.Particles.orb(purple, 4)
			motes.Size = B.seq(0, 0, 0.3, 0.2, 1, 0)
			b:emitter(v, motes, "Motes")
			local zap = B.Particles.electric(purple, 3)
			zap.Size = B.seq(0, 0.25, 1, 0)
			b:emitter(v, zap, "Glitch")
		end)
		b:light(Vector3.new(0, headY, 0), purple, 2, 10, { pulse = { 1.1, 2.6 }, pulseSpeed = 1.3, name = "CoreGlow" })
		b:light(Vector3.new(-outerX - 0.2, headY, 0), purpleHot, 1, 6, { pulse = { 0.5, 1.5 }, pulseSpeed = 1.3, name = "CapGlow" })

		-- impacto: "píxeles" cuadrados que salen disparados + chispa eléctrica
		local pix = {
			Texture = "rbxasset://textures/particles/sparkles_main.dds",
			Color = B.colors(purpleHot, purple),
			LightEmission = 1,
			LightInfluence = 0,
			Brightness = 3,
			Size = B.seq(0, 0.3, 1, 0),
			Transparency = B.seq(0, 0, 1, 1),
			Lifetime = NumberRange.new(0.3, 0.6),
			Speed = NumberRange.new(8, 15),
			SpreadAngle = Vector2.new(70, 70),
			Acceleration = Vector3.new(0, -12, 0),
			Drag = 2,
			Rotation = NumberRange.new(45, 45),
			Rate = 0,
		}
		local zapHit = B.Particles.electric(purpleHot, 0)
		zapHit.Speed = NumberRange.new(10, 18)
		local hit = b:impact(CFrame.new(-outerX - 0.05, headY, 0), purple, { sparks = 22, flash = 7, extra = { pix, zapHit } })
		-- (Builder no acepta EmitCount dentro de props: se fija el atributo directo)
		hit:FindFirstChild("ImpactExtra1"):SetAttribute("FX_Emit", 18)
		hit:FindFirstChild("ImpactExtra2"):SetAttribute("FX_Emit", 16)
		b:trail(Vector3.new(0, headY + CH / 2, 0), Vector3.new(0, headY - CH / 2, 0), purpleHot, P.rgb(90, 20, 200), { lifetime = 0.24 })
	end,
}
