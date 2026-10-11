-- Cyber Hammer (Epic) — un martillo de asalto sci-fi: chasis de grafito con placas de blindaje
-- blanco-plata biseladas y circuitos de neón MAGENTA gruesos corriendo por ranuras HUNDIDAS entre placas.
-- Al centro, en ambas caras, un panel blindado con el emblema TRIÁNGULO "play" de neón (halo que
-- late y núcleo blanco caliente) y trazos de circuito en Y. Arriba, tres almenas con neón en las muescas.
-- Remates con recortes escalonados (ranura vertical + horizontal hundidas 0.15 con neón adentro) y una
-- segunda placa escalonada; tapas de golpe octagonales con panel hundido, cruz de circuito de neón con
-- terminales y 4 tornillos. Algunos segmentos del circuito parpadean como "glitch".
-- Mango de grafito grueso segmentado con anillos de acero y franjas magenta bajo vidrio, collar y pomo
-- octagonales grandes. FX: destellos holográficos, chispas magenta, motas, luz magenta que late,
-- impacto de píxeles.
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
		local purple = P.rgb(214, 54, 255) -- magenta
		local purpleHot = P.rgb(246, 176, 255)
		local neon = P.neon(purple, 0.2)
		local neonHot = P.neon(purpleHot)
		local halo = P.neon(P.rgb(190, 40, 255), 0.5)
		local glass = P.glass(P.rgb(230, 170, 255), 0.62)

		-- ── medidas ────────────────────────────────────────────
		local CW, CH, CD = 1.5, 1.9, 1.9
		local gx = CW / 2 + 0.08
		local EX0, EX1 = CW / 2 + 0.16, 1.78
		local EW, EH, ED = EX1 - EX0, 2.04, 2.04
		local ex = (EX0 + EX1) / 2
		local capX = EX1 + 0.09
		local outerX = capX + 0.09
		local R = 0.15 -- profundidad de los recortes

		local circuit = {} -- piezas que "laten" en secuencia
		local function C(p)
			table.insert(circuit, p)
			return p
		end

		b:group("Head", function()
			-- ── núcleo ─────────────────────────────────────────
			b:bevelBox(Vector3.new(CW, CH, CD), CFrame.new(0, headY, 0), graphite, 0.12, { edges = "Z", edgeStyle = graphiteEdge, name = "Core" })

			B.both(function(s)
				local face = B.faceZ(s, headY, CD / 2)
				-- panel blindado con marco
				b:bevelBox(Vector3.new(1.36, 1.62, 0.12), face * CFrame.new(0, 0, 0.05), armor, 0.1, { edges = "Z", edgeStyle = armorEdge, name = "Panel" })
				-- ventana oscura del emblema
				b:box(Vector3.new(1.0, 0.92, 0.06), face * CFrame.new(0, 0.2, 0.1), black, "EmblemWell")
				-- triángulo "play" apuntando hacia abajo: halo + neón + núcleo caliente
				local tp = face * CFrame.new(0, 0.2, 0.14) * CFrame.Angles(0, 0, math.pi)
				local h = b:shape(tp, B.Shapes.triangle(0.86, 0.74), 0.03, halo, "TriHalo")
				b:shape(tp * CFrame.new(0, 0.02, 0.03), B.Shapes.triangle(0.66, 0.56), 0.04, P.neon(purple), "Triangle")
				b:shape(tp * CFrame.new(0, 0.06, 0.055), B.Shapes.triangle(0.3, 0.26), 0.03, neonHot, "TriCore")
				b:pulse(h, 0.15, 0.8, 1.3, if s > 0 then 0 else 0.4)
				-- trazos en Y bajo la ventana (ranura oscura + neón grueso)
				local tz = 0.12
				local function trace(p0: Vector2, p1: Vector2)
					local a = face:PointToWorldSpace(Vector3.new(p0.X, p0.Y, tz))
					local c = face:PointToWorldSpace(Vector3.new(p1.X, p1.Y, tz))
					b:line(a, c, 0.2, 0.05, black, face.ZVector, "TraceSlot")
					C(b:line(a + face.ZVector * 0.035, c + face.ZVector * 0.035, 0.12, 0.08, neon, face.ZVector, "Trace"))
				end
				trace(Vector2.new(0, -0.3), Vector2.new(0, -0.5))
				trace(Vector2.new(0, -0.5), Vector2.new(-0.36, -0.66))
				trace(Vector2.new(0, -0.5), Vector2.new(0.36, -0.66))
				for _, x in { -0.5, 0.5 } do
					b:box(Vector3.new(0.18, 0.42, 0.05), face * CFrame.new(x, -0.42, 0.125), black, "PillSlot")
					C(b:box(Vector3.new(0.12, 0.34, 0.08), face * CFrame.new(x, -0.42, 0.14), neon, "Pill"))
				end
				-- tornillos del panel
				for _, c in { Vector2.new(-1, -1), Vector2.new(1, -1), Vector2.new(1, 1), Vector2.new(-1, 1) } do
					b:rivet(face:PointToWorldSpace(Vector3.new(c.X * 0.56, c.Y * 0.68, 0.1)), 0.09, armorDark)
				end
			end)

			-- corona almenada: 3 almenas de 0.3 con neón en las 2 muescas
			local ty = headY + CH / 2
			b:box(Vector3.new(1.4, 0.12, 1.62), CFrame.new(0, ty + 0.05, 0), armor, "TopPlate")
			for _, x in { -0.5, 0, 0.5 } do
				b:bevelBox(Vector3.new(0.32, 0.3, 1.4), CFrame.new(x, ty + 0.26, 0), armor, 0.05, { edges = "Z", edgeStyle = armorEdge, name = "Merlon" })
			end
			for _, x in { -0.25, 0.25 } do
				b:box(Vector3.new(0.2, 0.06, 1.2), CFrame.new(x, ty + 0.13, 0), black, "NotchWell")
				C(b:box(Vector3.new(0.12, 0.1, 1.12), CFrame.new(x, ty + 0.16, 0), neon, "NotchNeon"))
			end
			-- abajo
			b:box(Vector3.new(1.1, 0.08, 1.3), CFrame.new(0, headY - CH / 2 - 0.03, 0), armorDark, "BottomPlate")

			-- ── juntas + remates con recortes escalonados ──────
			B.both(function(sx)
				-- junta oscura con ranura de energía vertical
				b:box(Vector3.new(0.16, CH - 0.16, CD - 0.16), CFrame.new(sx * gx, headY, 0), black, "Gasket")
				for _, sz in { 1, -1 } do
					C(b:box(Vector3.new(0.1, CH - 0.5, 0.08), CFrame.new(sx * gx, headY, sz * (CD / 2 - 0.1)), neon, "GasketNeon"))
				end

				-- chasis del remate, más delgado en Z: las placas lo cubren y dejan ranuras hundidas
				local ecf = CFrame.new(sx * ex, headY, 0)
				b:bevelBox(Vector3.new(EW, EH, ED - 2 * R), ecf, graphite, 0.12, { edges = "X", edgeStyle = graphiteEdge, name = "End" })
				local function ux(u)
					return sx * (EX0 + u)
				end
				local W, hh = EW, EH / 2
				for _, sz in { 1, -1 } do
					local zc = sz * (ED / 2 - R / 2 + 0.01) -- centro de las placas (superficie = ED/2 + 0.01 + R/2...)
					local function plate(u0, u1, y0, y1, st, bev)
						local size = Vector3.new(u1 - u0, y1 - y0, R + 0.02)
						local cf = CFrame.new(ux((u0 + u1) / 2), headY + (y0 + y1) / 2, zc)
						if bev then
							b:bevelBox(size, cf, st, bev, { edges = "Z", edgeStyle = armorEdge, name = "EndPlate" })
						else
							b:box(size, cf, st, "EndPlate")
						end
					end
					-- placas grandes arriba/abajo (dejan la ranura horizontal)
					plate(0.36, W, 0.08, hh, armor, 0.1)
					plate(0.36, W, -hh, -0.08, armor, 0.1)
					-- columna interior + tapas de la ranura vertical
					plate(0, 0.12, -hh, hh, armorDark)
					plate(0.12, 0.36, 0.64, hh, armorDark)
					plate(0.12, 0.36, -hh, -0.64, armorDark)
					-- segunda placa escalonada sobre la de arriba (tercer nivel)
					local zs = sz * (ED / 2 + 0.05)
					b:box(Vector3.new(W - 0.62, 0.36, 0.06), CFrame.new(ux(0.58 + (W - 0.62) / 2 - 0.04), headY + hh - 0.32, zs), armorEdge, "StepPlate")
					b:box(Vector3.new(W - 0.62, 0.36, 0.06), CFrame.new(ux(0.58 + (W - 0.62) / 2 - 0.04), headY - hh + 0.32, zs), armorEdge, "StepPlate")
					-- neón en el fondo de las ranuras (hundido R)
					local zn = sz * (ED / 2 - R + 0.04)
					C(b:box(Vector3.new(0.13, 1.2, 0.08), CFrame.new(ux(0.24), headY, zn), neon, "EndSlot"))
					C(b:box(Vector3.new(W - 0.44, 0.1, 0.08), CFrame.new(ux(0.36 + (W - 0.36) / 2), headY, zn), neon, "EndGroove"))
				end
				-- placas arriba/abajo del remate con luz
				for _, sy in { 1, -1 } do
					local y = headY + sy * (EH / 2 + 0.04)
					b:box(Vector3.new(EW - 0.16, 0.1, ED - 0.36), CFrame.new(sx * ex, y, 0), armor, "EndTop")
					C(b:box(Vector3.new(EW - 0.4, 0.06, 0.12), CFrame.new(sx * ex, y + sy * 0.04, 0), neon, "EndTopNeon"))
				end

				-- tapa de golpe: octágono con panel hundido, cruz de circuito y 4 tornillos
				b:bevelBox(Vector3.new(0.18, 1.86, 1.86), CFrame.new(sx * capX, headY, 0), armorDark, 0.4, { edges = "X", edgeStyle = armorEdge, name = "StrikeCap" })
				local f = B.faceX(sx, capX + 0.09, headY)
				-- marco elevado (4 barras) alrededor del panel hundido
				for _, d in { { 0, 0.6, 1.3, 0.14 }, { 0, -0.6, 1.3, 0.14 }, { 0.6, 0, 0.14, 1.06 }, { -0.6, 0, 0.14, 1.06 } } do
					b:box(Vector3.new(d[3], d[4], 0.1), f * CFrame.new(d[1], d[2], 0.05), armor, "CapFrame")
				end
				b:box(Vector3.new(1.08, 1.08, 0.03), f * CFrame.new(0, 0, 0.012), black, "CapWell")
				C(b:box(Vector3.new(0.96, 0.14, 0.06), f * CFrame.new(0, 0, 0.03), neon, "CapCross"))
				C(b:box(Vector3.new(0.14, 0.96, 0.06), f * CFrame.new(0, 0, 0.03), neon, "CapCross"))
				-- terminales del circuito en las puntas de la cruz
				for _, t in { { 0.46, 0 }, { -0.46, 0 }, { 0, 0.46 }, { 0, -0.46 } } do
					C(b:box(Vector3.new(0.24, 0.24, 0.05), f * CFrame.new(t[1], t[2], 0.03), neon, "CapPad"))
				end
				b:cylZ(0.08, 0.3, f * CFrame.new(0, 0, 0.07), neonHot, "CapNode")
				for _, c in { { 1, 1 }, { 1, -1 }, { -1, 1 }, { -1, -1 } } do
					b:rivet(f:PointToWorldSpace(Vector3.new(c[1] * 0.6, c[2] * 0.6, 0.1)), 0.13, armorEdge)
				end
			end)
		end)

		-- circuito: oleada de brillo recorriéndolo (fases escalonadas por posición)
		for _, p in circuit do
			local pos = p.CFrame.Position
			local ph = (pos.X + 2) * 0.12 + pos.Z * 0.03
			b:pulse(p, 0, 0.45, 1.2, ph)
		end

		-- segmentos de "glitch" que parpadean (datos cruzando el chasis)
		local glitch = b:group("Glitch", function()
			B.both(function(s)
				local face = B.faceZ(s, headY, CD / 2)
				for i, d in { { -0.62, 0.86, 0.22 }, { 0.62, -0.84, 0.2 } } do
					b:box(Vector3.new(d[3], 0.05, 0.05), face * CFrame.new(d[1], d[2] + (i % 2) * 0.01, 0.13), neonHot, "Data")
				end
			end)
		end)
		b:flicker(glitch, 7, 0.6)

		-- ── mango (grueso y corto) ──────────────────────────────
		b:group("Shaft", function()
			local top = headY - CH / 2 - 0.07
			local bottom = A.ShaftBottom + 0.15
			b:cylY(top - bottom, 0.46, CFrame.new(0, (top + bottom) / 2, 0), graphite, "ShaftCore")
			-- collar octagonal con anillo de neón
			b:bevelBox(Vector3.new(0.78, 0.28, 0.78), CFrame.new(0, top - 0.14, 0), armor, 0.16, { edges = "Y", edgeStyle = armorEdge, name = "Collar" })
			C(b:cylY(0.08, 0.7, CFrame.new(0, top - 0.32, 0), neon, "CollarNeon"))
			b:bevelBox(Vector3.new(0.68, 0.16, 0.68), CFrame.new(0, top - 0.44, 0), armorDark, 0.14, { edges = "Y", edgeStyle = armor, name = "CollarLow" })
			-- agarre segmentado
			local g0, g1 = -0.98, 1.6
			local segs = 5
			local step = (g1 - g0) / segs
			for i = 0, segs - 1 do
				b:cylY(step - 0.08, 0.62, CFrame.new(0, g0 + step * (i + 0.5), 0), rubber, "Grip")
			end
			for i = 0, segs do
				local y = g0 + step * i
				if i == 1 or i == 2 or i == 4 then
					local r = b:cylY(0.12, 0.68, CFrame.new(0, y, 0), neon, "GripNeon")
					b:cylY(0.18, 0.72, CFrame.new(0, y, 0), glass, "GripGlass")
					b:pulse(r, 0, 0.45, 1.2, 1 - i * 0.1)
				else
					b:cylY(0.12, 0.7, CFrame.new(0, y, 0), armor, "GripRing")
				end
			end
		end)

		-- ── pomo (1.3x) ─────────────────────────────────────────
		b:group("Pommel", function()
			local y = A.PommelY + 0.06
			b:bevelBox(Vector3.new(1.0, 0.6, 1.0), CFrame.new(0, y, 0), armor, 0.27, { edges = "Y", edgeStyle = armorEdge, name = "Pommel" })
			b:cylY(0.14, 1.1, CFrame.new(0, y, 0), black, "PommelSlot")
			C(b:cylY(0.06, 1.13, CFrame.new(0, y, 0), neon, "PommelNeon"))
			b:bevelBox(Vector3.new(0.78, 0.14, 0.78), CFrame.new(0, y - 0.37, 0), graphite, 0.2, { edges = "Y", edgeStyle = graphiteEdge, name = "PommelCap" })
			b:cylY(0.05, 0.28, CFrame.new(0, y - 0.45, 0), neonHot, "PommelNode")
		end)

		-- ── efectos ─────────────────────────────────────────────
		b:group("FX", function()
			local v = b:fxVolume(Vector3.new(3.8, 2.3, 2.3), CFrame.new(0, headY, 0), "HoloVolume")
			local holo = B.Particles.sparkle(P.rgb(226, 140, 255), 8)
			holo.Color = B.colors({ 0, P.rgb(255, 255, 255) }, { 0.4, P.rgb(220, 110, 255) }, { 1, P.rgb(110, 200, 255) })
			b:emitter(v, holo, "HoloSparkle")
			local motes = B.Particles.orb(purple, 4)
			motes.Size = B.seq(0, 0, 0.3, 0.22, 1, 0)
			b:emitter(v, motes, "Motes")
			local zap = B.Particles.electric(purple, 3)
			zap.Size = B.seq(0, 0.25, 1, 0)
			b:emitter(v, zap, "Glitch")
			-- chispas magenta que saltan de las ranuras de los remates
			local sparks = B.Particles.ember(purple, 4)
			sparks.Texture = B.Textures.Sparkle
			sparks.Size = B.seq(0, 0.2, 1, 0)
			sparks.Speed = NumberRange.new(1.5, 3)
			sparks.Acceleration = Vector3.new(0, -4, 0)
			sparks.SpreadAngle = Vector2.new(60, 60)
			b:emitter(b:fxVolume(Vector3.new(3.4, 0.2, 2.1), CFrame.new(0, headY, 0), "SparkVolume"), sparks, "MagentaSparks")
		end)
		b:light(Vector3.new(0, headY, 0), purple, 2.6, 12, { pulse = { 1.6, 3.4 }, pulseSpeed = 1.3, name = "CoreGlow" })
		b:light(Vector3.new(-outerX - 0.2, headY, 0), purpleHot, 1.2, 6, { pulse = { 0.6, 1.8 }, pulseSpeed = 1.3, name = "CapGlow" })

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
