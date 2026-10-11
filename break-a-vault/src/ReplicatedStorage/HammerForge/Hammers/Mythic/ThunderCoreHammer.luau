-- Thunder Core Hammer (Mythic) — un generador de tormenta con forma de martillo.
-- Bloque central de acero negro con la CÁMARA DEL NÚCLEO en ambas caras: aro de latón con cuatro
-- abrazaderas en cruz, un orbe de neón azul blanco dentro de una cáscara de campo de fuerza, un anillo
-- de energía en arcos que gira alrededor y un aro tipo giroscopio que precesa sobre el orbe.
-- A cada lado: ranura de neón, bloque interior de bronce claro con placas, otra ranura y el remate exterior
-- con tapa de golpe de vidrio azul segmentada. Arcos eléctricos que chisporrotean envuelven los remates
-- y saltan sobre la cabeza. Mango negro con cinco anillos de neón bajo vidrio (la energía sube en pulso),
-- collar y pomo de bronce octagonal con banda de neón.
-- FX: chispas eléctricas, pulso del núcleo, luces azules que parpadean, impacto de descarga.
return {
	Id = "ThunderCoreHammer",
	DisplayName = "Thunder Core Hammer",
	Rarity = "Mythic",
	Order = 2,
	Theme = "Storm Reactor",
	Build = function(b, P, B)
		local A = B.Anatomy
		local headY = A.HeadY + 0.1
		local TAU = math.pi * 2

		-- ── estilos ─────────────────────────────────────────────
		local dark = P.metal(P.rgb(30, 34, 44), 0.08) -- acero negro
		local darkMid = P.metal(P.rgb(52, 58, 72), 0.1)
		local darkEdge = P.metal(P.rgb(118, 128, 148), 0.18)
		local plate = P.metal(P.rgb(150, 124, 82), 0.16) -- bronce claro / caqui
		local plateEdge = P.metal(P.rgb(222, 190, 128), 0.22)
		local brass = P.metal(P.rgb(232, 164, 42), 0.2)
		local brassEdge = P.metal(P.rgb(255, 210, 110), 0.24)
		local rubber = P.GripRubber
		local blue = P.rgb(40, 150, 255)
		local blueHot = P.rgb(165, 225, 255)
		local white = P.rgb(230, 246, 255)
		local neon = P.neon(blue)
		local neonHot = P.neon(blueHot)
		local neonWhite = P.neon(white)
		local shell = P.glass(P.rgb(120, 200, 255), 0.72, 0.3)
		local well = P.neon(P.rgb(30, 120, 255), 0.35)
		local glass = P.glass(P.rgb(150, 210, 255), 0.6)
		local glassBlue = P.glass(P.rgb(60, 150, 255), 0.35)
		local arcCore = P.neon(P.rgb(205, 238, 255))
		local arcGlow = P.neon(P.rgb(50, 140, 255), 0.62)

		-- ── medidas ────────────────────────────────────────────
		local CW, CH, CD = 1.5, 2.0, 1.9 -- bloque central
		local slot1 = 0.84 -- ranura núcleo/bloque interior
		local IX0, IX1 = 0.93, 1.45 -- bloque interior
		local IH, ID = 2.14, 2.02
		local slot2 = 1.52
		local OX0, OX1 = 1.59, 1.98 -- remate exterior
		local OH, OD = 1.96, 1.86
		local faceX = OX1 + 0.06

		b:group("Head", function()
			-- ── bloque central ─────────────────────────────────
			b:bevelBox(Vector3.new(CW, CH, CD), CFrame.new(0, headY, 0), dark, 0.14, { edgeStyle = darkEdge, name = "Core" })
			-- arriba/abajo: placa con rejilla de neón
			for _, sy in { 1, -1 } do
				local y = headY + sy * (CH / 2 + 0.03)
				b:box(Vector3.new(1.0, 0.08, 1.3), CFrame.new(0, y, 0), darkMid, "TopPlate")
				for _, z in { -0.36, 0, 0.36 } do
					b:box(Vector3.new(0.7, 0.05, 0.07), CFrame.new(0, y + sy * 0.045, z), neon, "Vent")
				end
			end

			-- ── cámara del núcleo (ambas caras) ───────────────
			B.both(function(s)
				local face = B.faceZ(s, headY, CD / 2)
				-- placa base oscura con borde
				b:bevelBox(Vector3.new(1.36, 1.5, 0.08), face * CFrame.new(0, 0, 0.03), darkMid, 0.08, { edges = "Z", edgeStyle = darkEdge, name = "CoreBack" })
				-- abrazaderas en cruz (latón) con remache
				for i = 0, 3 do
					local a = i * math.pi / 2
					local d = Vector3.new(math.cos(a), math.sin(a), 0)
					local len = if i % 2 == 0 then 0.24 else 0.34
					local r0 = 0.62
					local mid = d * (r0 + len / 2)
					local sz = if i % 2 == 0 then Vector3.new(len, 0.3, 0.12) else Vector3.new(0.3, len, 0.12)
					b:box(sz, face * CFrame.new(mid.X, mid.Y, 0.1), brass, "Clamp")
					b:box(sz + Vector3.new(-0.08, -0.08, 0.02), face * CFrame.new(mid.X, mid.Y, 0.12), neon, "ClampLed")
					b:rivet(face:PointToWorldSpace(Vector3.new(d.X * (r0 + len + 0.02), d.Y * (r0 + len + 0.02), 0.08)), 0.1, brassEdge)
				end
				-- aro de latón grueso + bisel interior claro
				local rcf = face * CFrame.new(0, 0, 0.13) * CFrame.Angles(math.pi / 2, 0, 0)
				b:ring(rcf, 0.56, 0.16, 14, brass, "CoreRing", 0.16)
				-- fondo de la cámara: disco negro + anillo de luz azul alrededor del orbe
				b:cylZ(0.08, 0.98, face * CFrame.new(0, 0, 0.07), P.Blackened, "CoreWell")
				local wl = b:cylZ(0.04, 0.88, face * CFrame.new(0, 0, 0.12), well, "CoreWellGlow")
				b:pulse({ wl }, 0.2, 0.6, 3, 0.1)
				-- orbe: núcleo blanco + neón azul + cáscara de campo de fuerza
				local ocf = face * CFrame.new(0, 0, 0.1)
				local orb = b:ball(0.72, ocf, neon, "CoreOrb")
				local hot = b:ball(0.48, ocf * CFrame.new(0, 0, 0.14), neonWhite, "CoreHot")
				local sh = b:ball(0.9, ocf, shell, "CoreShell")
				b:pulse({ orb }, 0, 0.3, 3, if s > 0 then 0 else 0.15)
				b:pulse({ sh }, 0.6, 0.85, 1.5)
				b:pulse({ hot }, 0, 0.35, 6)
				-- anillo de energía en tres arcos (gira)
				local spin = {}
				for k = 0, 2 do
					local a0 = k * TAU / 3
					for j = 0, 2 do
						local a = a0 + j * 0.32
						local p = face * CFrame.new(math.cos(a) * 0.82, math.sin(a) * 0.82, 0.24) * CFrame.Angles(0, 0, a)
						table.insert(spin, b:box(Vector3.new(0.06, 0.29, 0.06), p, if j == 1 then neonWhite else neonHot, "EnergyArc"))
					end
				end
				b:animate(spin, face * CFrame.new(0, 0, 0.24), { Spin = Vector3.new(0, 0, 1.8 * s) })
				-- aro giroscopio inclinado sobre el orbe (precesa)
				local gyro = b:ring(face * CFrame.new(0, 0, 0.12) * CFrame.Angles(math.rad(62), 0, 0), 0.52, 0.04, 10, neonHot, "GyroRing", 0.04)
				b:animate(gyro, face * CFrame.new(0, 0, 0.12), { Spin = Vector3.new(0, 0, -2.6 * s) })
				-- tiras de neón verticales a los lados de la cámara
				for _, sx in { 1, -1 } do
					b:box(Vector3.new(0.07, 1.1, 0.05), face * CFrame.new(sx * 0.67, 0, 0.09), neon, "SideLed")
				end
			end)

			-- ── ranuras, bloques y remates (ambos lados) ───────
			B.both(function(sx)
				-- ranura 1: empaque negro con neón en las cuatro caras
				local function slot(x: number, h: number, d: number)
					b:box(Vector3.new(0.12, h - 0.16, d - 0.16), CFrame.new(sx * x, headY, 0), P.Blackened, "Gasket")
					for _, sz in { 1, -1 } do
						b:box(Vector3.new(0.08, h - 0.4, 0.06), CFrame.new(sx * x, headY, sz * (d / 2 - 0.1)), neon, "SlotNeon")
					end
					for _, sy in { 1, -1 } do
						b:box(Vector3.new(0.08, 0.06, d - 0.4), CFrame.new(sx * x, headY + sy * (h / 2 - 0.1), 0), neon, "SlotNeon")
					end
				end
				slot(slot1, CH, CD)

				-- bloque interior de bronce claro (biselado) con placa negra y remaches
				local ix = sx * (IX0 + IX1) / 2
				b:bevelBox(Vector3.new(IX1 - IX0, IH, ID), CFrame.new(ix, headY, 0), plate, 0.15, { edges = "X", edgeStyle = brassEdge, name = "Inner" })
				for _, sz in { 1, -1 } do
					local f = CFrame.new(ix, headY, sz * (ID / 2 + 0.02))
					b:box(Vector3.new(0.3, 1.5, 0.05), f, dark, "InnerInset")
					b:box(Vector3.new(0.08, 1.1, 0.05), f * CFrame.new(0, 0, sz * 0.02), neon, "InnerLed")
					for _, y in { -0.86, 0.86 } do
						b:rivet(Vector3.new(ix, headY + y, sz * (ID / 2 + 0.03)), 0.11, plateEdge)
					end
				end
				for _, sy in { 1, -1 } do
					b:box(Vector3.new(0.3, 0.05, 1.4), CFrame.new(ix, headY + sy * (IH / 2 + 0.02), 0), dark, "InnerInset")
				end

				slot(slot2, OH, OD)

				-- remate exterior con placas en esquina
				local ox = sx * (OX0 + OX1) / 2
				local ocf = CFrame.new(ox, headY, 0)
				b:bevelBox(Vector3.new(OX1 - OX0, OH, OD), ocf, plate, 0.18, { edges = "X", edgeStyle = brassEdge, name = "Outer" })
				for _, sz in { 1, -1 } do
					b:box(Vector3.new(0.26, 0.9, 0.05), CFrame.new(ox, headY, sz * (OD / 2 + 0.02)), darkMid, "OuterInset")
					b:rivetLine(Vector3.new(ox, headY - 0.62, sz * (OD / 2 + 0.05)), Vector3.new(ox, headY + 0.62, sz * (OD / 2 + 0.05)), 2, 0.1, plateEdge)
				end

				-- tapa de golpe: marco oscuro + vidrio azul sobre neón, segmentado en rejilla
				local fcf = B.faceX(sx, faceX, headY)
				b:bevelBox(Vector3.new(1.74, 1.66, 0.12), fcf, dark, 0.2, { edges = "Z", edgeStyle = darkEdge, name = "StrikeFrame" })
				local sn = b:box(Vector3.new(1.3, 1.22, 0.06), fcf * CFrame.new(0, 0, 0.05), neon, "StrikeNeon")
				b:box(Vector3.new(1.4, 1.32, 0.08), fcf * CFrame.new(0, 0, 0.08), glassBlue, "StrikeGlass")
				for _, k in { -1, 1 } do
					b:box(Vector3.new(0.08, 1.36, 0.08), fcf * CFrame.new(k * 0.22, 0, 0.11), dark, "StrikeBar")
				end
				b:box(Vector3.new(1.44, 0.08, 0.08), fcf * CFrame.new(0, 0, 0.115), dark, "StrikeBar")
				b:cylZ(0.06, 0.34, fcf * CFrame.new(0, 0, 0.13), neonWhite, "StrikeHot")
				b:pulse({ sn }, 0, 0.35, 2.2, if sx > 0 then 0 else 0.25)
			end)
		end)

		-- ── arcos eléctricos (parpadean) ───────────────────────
		local function arcPoints(cx, cy, z, r, a0, a1, n, amp, seed)
			local rnd = B.rng(seed)
			local pts = {}
			for i = 0, n do
				local t = i / n
				local a = a0 + (a1 - a0) * t
				local rr = r + (if i == 0 or i == n then -0.14 else rnd(-amp, amp))
				table.insert(pts, Vector3.new(cx + math.cos(a) * rr, cy + math.sin(a) * rr, z + rnd(-0.15, 0.15)))
			end
			return pts
		end
		B.both(function(sx)
			local folder = b:group(if sx > 0 then "ArcsR" else "ArcsL", function()
				local cx = sx * 1.55
				local defs = {
					-- { z, radio, a0, a1, semilla, glow }
					{ 1.15, 1.4, 1.9, -1.3, 11, true },
					{ -1.15, 1.38, 1.2, -1.9, 23, true },
					{ 0.25, 1.55, 2.5, 0.4, 37, false },
				}
				for _, d in defs do
					local a0, a1 = d[3], d[4]
					if sx < 0 then
						a0, a1 = math.pi - d[3], math.pi - d[4]
					end
					local pts = arcPoints(cx, headY, d[1], d[2], a0, a1, 5, 0.28, d[5] + (if sx > 0 then 0 else 100))
					b:polyline(pts, 0.05, 0.05, arcCore, Vector3.zAxis, false, "Arc")
					if d[6] then
						b:polyline(pts, 0.13, 0.13, arcGlow, Vector3.zAxis, false, "ArcGlow")
					end
				end
				-- rayo que salta del núcleo al remate por arriba
				local top = B.jitterPath(Vector3.new(sx * 0.2, headY + CH / 2 + 0.1, 0.2 * sx), Vector3.new(sx * 1.75, headY + OH / 2 + 0.05, -0.2), 5, 0.22, if sx > 0 then 71 else 171, Vector3.zAxis)
				for i, p in top do
					if i > 1 and i < #top then
						top[i] = p + Vector3.new(0, 0.32, 0)
					end
				end
				b:polyline(top, 0.05, 0.05, arcCore, Vector3.zAxis, false, "Arc")
				b:polyline(top, 0.12, 0.12, arcGlow, Vector3.zAxis, false, "ArcGlow")
			end)
			b:flicker(folder, if sx > 0 then 15 else 12, 0.55)
		end)

		-- ── mango ───────────────────────────────────────────────
		b:group("Shaft", function()
			local top = headY - CH / 2
			local bottom = A.ShaftBottom
			-- collar de bronce octagonal escalonado con banda de neón
			b:bevelBox(Vector3.new(0.86, 0.22, 0.86), CFrame.new(0, top - 0.11, 0), brass, 0.2, { edges = "Y", edgeStyle = brassEdge, name = "Collar" })
			b:cylY(0.08, 0.72, CFrame.new(0, top - 0.26, 0), neon, "CollarNeon")
			b:bevelBox(Vector3.new(0.7, 0.2, 0.7), CFrame.new(0, top - 0.4, 0), plate, 0.16, { edges = "Y", edgeStyle = plateEdge, name = "CollarLow" })
			for i = 0, 3 do
				local a = TAU * i / 4
				b:rivet(Vector3.new(math.cos(a) * 0.43, top - 0.11, math.sin(a) * 0.43), 0.1, brassEdge)
			end
			-- eje
			b:cylY(top - bottom - 0.4, 0.4, CFrame.new(0, (top + bottom) / 2 - 0.2, 0), dark, "ShaftCore")
			-- agarre: segmentos de goma + cinco anillos de neón bajo vidrio
			local g0, g1 = -1.12, 1.95
			local n = 5
			local step = (g1 - g0) / n
			for i = 0, n - 1 do
				local y = g0 + step * (i + 0.5)
				b:cylY(step - 0.12, 0.54, CFrame.new(0, y, 0), rubber, "Grip")
				b:cylY(step - 0.36, 0.58, CFrame.new(0, y, 0), P.Blackened, "GripPad")
			end
			for i = 0, n do
				local y = g0 + step * i
				local ring = b:cylY(0.12, 0.6, CFrame.new(0, y, 0), neon, "GripNeon")
				b:cylY(0.16, 0.64, CFrame.new(0, y, 0), glass, "GripGlass")
				-- la energía sube por el mango
				b:pulse({ ring }, 0, 0.6, 1.6, 1 - i * 0.1)
			end
		end)

		-- ── pomo ────────────────────────────────────────────────
		b:group("Pommel", function()
			local y = A.PommelY - 0.05
			b:bevelBox(Vector3.new(0.92, 0.5, 0.92), CFrame.new(0, y, 0), brass, 0.26, { edges = "Y", edgeStyle = brassEdge, name = "Pommel" })
			b:cylY(0.12, 0.86, CFrame.new(0, y + 0.04, 0), neon, "PommelNeon")
			b:cylY(0.16, 0.9, CFrame.new(0, y + 0.04, 0), glass, "PommelGlass")
			b:bevelBox(Vector3.new(0.8, 0.12, 0.8), CFrame.new(0, y + 0.31, 0), brass, 0.22, { edges = "Y", edgeStyle = brassEdge, name = "PommelTop" })
			b:bevelBox(Vector3.new(0.74, 0.14, 0.74), CFrame.new(0, y - 0.32, 0), dark, 0.2, { edges = "Y", edgeStyle = darkEdge, name = "PommelCap" })
			b:cylY(0.05, 0.4, CFrame.new(0, y - 0.4, 0), neonHot, "PommelCore")
			for i = 0, 3 do
				local a = TAU * i / 4 + math.pi / 4
				b:rivet(Vector3.new(math.cos(a) * 0.4, y + 0.2, math.sin(a) * 0.4), 0.1, brassEdge)
			end
		end)

		-- ── efectos ─────────────────────────────────────────────
		b:group("FX", function()
			B.both(function(sx)
				local v = b:fxVolume(Vector3.new(1.4, 2.6, 2.6), CFrame.new(sx * 1.7, headY, 0), "SparkVolume")
				b:emitter(v, B.Particles.electric(blue, 10), "Sparks")
			end)
			local core = b:fxVolume(Vector3.new(1.0, 1.0, CD + 0.6), CFrame.new(0, headY, 0), "CoreVolume")
			b:emitter(core, B.Particles.sparkle(blueHot, 6), "CoreSparkle")
			local zap = B.Particles.electric(white, 8)
			zap.Speed = NumberRange.new(2, 5)
			zap.Size = B.seq(0, 0.3, 1, 0)
			b:emitter(core, zap, "CoreZap")
			local glow = B.Particles.orb(blue, 4)
			glow.Size = B.seq(0, 0, 0.3, 0.6, 1, 0)
			b:emitter(core, glow, "CoreGlow")
		end)
		b:light(Vector3.new(0, headY, 0), blue, 2.4, 11, { pulse = { 1.4, 3.4 }, pulseSpeed = 3, name = "CoreLight" })
		b:light(Vector3.new(faceX + 0.4, headY, 0), blueHot, 1.4, 7, { pulse = { 0.3, 2.2 }, pulseSpeed = 6, name = "ArcLightR" })
		b:light(Vector3.new(-faceX - 0.4, headY, 0), blueHot, 1.4, 7, { pulse = { 0.3, 2.2 }, pulseSpeed = 7, name = "ArcLightL" })

		-- impacto: chispas + descarga eléctrica + onda de destellos + chispazo blanco
		local zap = B.Particles.electric(blueHot, 0)
		zap.Speed = NumberRange.new(12, 22)
		zap.Lifetime = NumberRange.new(0.1, 0.25)
		local ring = B.Particles.sparkle(blue, 0)
		ring.Speed = NumberRange.new(5, 9)
		ring.Size = B.seq(0, 0.5, 1, 0)
		local bolt = B.Particles.electric(white, 0)
		bolt.Size = B.seq(0, 1.4, 1, 0)
		bolt.Speed = NumberRange.new(0, 1)
		bolt.Lifetime = NumberRange.new(0.06, 0.12)
		local hit = b:impact(CFrame.new(-faceX - 0.2, headY, 0), blue, { sparks = 28, flash = 9, extra = { zap, ring, bolt } })
		hit:FindFirstChild("ImpactExtra1"):SetAttribute("FX_Emit", 30)
		hit:FindFirstChild("ImpactExtra2"):SetAttribute("FX_Emit", 16)
		hit:FindFirstChild("ImpactExtra3"):SetAttribute("FX_Emit", 4)
		b:trail(Vector3.new(0, headY + CH / 2 + 0.2, 0), Vector3.new(0, headY - CH / 2 - 0.2, 0), white, P.rgb(30, 100, 255), { lifetime = 0.26 })
	end,
}
