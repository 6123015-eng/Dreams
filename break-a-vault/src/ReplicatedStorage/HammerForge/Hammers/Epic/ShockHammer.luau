-- Shock Hammer (Epic) — un martillo-condensador de acero oscuro cargado hasta el tope.
-- Bloque central de acero pavonado con un panel hundido y el RAYO de neón azul (con halo que late)
-- en ambas caras; ranuras de neón bajo vidrio separan el núcleo de los dos remates. Cada remate lleva
-- abrazaderas de oro remachadas, banda de hierro y una tapa de golpe octagonal de acero con una
-- "bobina" azul brillante. Arcos eléctricos que chisporrotean (parpadeo) envuelven ambos extremos.
-- Mango segmentado de goma negra con tres anillos de neón azul bajo vidrio, collar de bronce y pomo
-- octagonal de acero remachado. FX: chispas eléctricas, luz azul pulsante, impacto de descarga.
return {
	Id = "ShockHammer",
	DisplayName = "Shock Hammer",
	Rarity = "Epic",
	Order = 1,
	Theme = "Power Plant",
	Build = function(b, P, B)
		local A = B.Anatomy
		local headY = A.HeadY + 0.05

		-- ── estilos ─────────────────────────────────────────────
		local steelDark = P.metal(P.rgb(36, 42, 56), 0.1) -- acero pavonado (azulado)
		local steelCore = P.metal(P.rgb(58, 66, 82), 0.12)
		local steelEdge = P.metal(P.rgb(176, 188, 206), 0.22) -- brillo de arista
		local steel = P.metal(P.rgb(136, 146, 162), 0.18)
		local chrome = P.Chrome
		local black = P.Blackened
		local gold = P.metal(P.rgb(255, 190, 56), 0.2)
		local goldEdge = P.metal(P.rgb(255, 212, 104), 0.22)
		local bronze = P.metal(P.rgb(156, 104, 56), 0.12)
		local bronzeEdge = P.metal(P.rgb(206, 150, 92), 0.16)
		local rubber = P.GripRubber
		local blue = P.rgb(40, 140, 255)
		local blueHot = P.rgb(150, 215, 255)
		local neon = P.neon(blue)
		local neonHot = P.neon(blueHot)
		local halo = P.neon(P.rgb(40, 120, 255), 0.55)
		local arcCore = P.neon(P.rgb(200, 236, 255))
		local arcGlow = P.neon(P.rgb(50, 140, 255), 0.62)
		local glass = P.glass(P.rgb(150, 210, 255), 0.6)

		-- ── medidas ────────────────────────────────────────────
		local CW, CH, CD = 1.6, 1.86, 1.86 -- bloque central
		local slotX = CW / 2 + 0.09 -- ranura de neón entre núcleo y remate
		local EX0, EX1 = CW / 2 + 0.18, 1.72 -- remate
		local EW, EH, ED = EX1 - EX0, 2.02, 2.02
		local ex = (EX0 + EX1) / 2
		local capX = EX1 + 0.12 -- tapa octagonal
		local outerX = EX1 + 0.26

		local arcParts = {}

		b:group("Head", function()
			-- ── bloque central ─────────────────────────────────
			b:bevelBox(Vector3.new(CW, CH, CD), CFrame.new(0, headY, 0), steelDark, 0.12, { edgeStyle = steelEdge, name = "Core" })

			-- panel del rayo en ambas caras
			B.both(function(s)
				local face = B.faceZ(s, headY, CD / 2)
				-- marco de acero (biselado) que sobresale
				b:bevelBox(Vector3.new(1.42, 1.52, 0.1), face * CFrame.new(0, 0, 0.04), steel, 0.05, { edges = "Z", edgeStyle = steelEdge, name = "PanelFrame" })
				-- placa hundida negra
				b:box(Vector3.new(1.18, 1.28, 0.06), face * CFrame.new(0, 0, 0.075), black, "PanelRecess")
				-- remaches de esquina
				for _, c in { Vector2.new(-1, -1), Vector2.new(1, -1), Vector2.new(1, 1), Vector2.new(-1, 1) } do
					b:rivet(face:PointToWorldSpace(Vector3.new(c.X * 0.6, c.Y * 0.65, 0.1)), 0.11, steelEdge)
				end
				-- halo (rayo más grande translúcido) + rayo de neón + filo caliente
				local p = face * CFrame.new(0, 0, 0.12)
				local h = b:shape(p, B.Shapes.bolt(0.86, 1.18), 0.04, halo, "BoltHalo")
				b:shape(p * CFrame.new(0, 0, 0.04), B.Shapes.bolt(0.68, 1.0), 0.05, neon, "Bolt")
				b:pulse(h, 0.25, 0.85, 1.6, if s > 0 then 0 else 0.3)
				-- tira de luz bajo el panel
				b:box(Vector3.new(0.9, 0.06, 0.05), face * CFrame.new(0, -0.84, 0.03), neon, "PanelLed")
			end)

			-- arriba / abajo del núcleo: placa con ranuras azules
			for _, sy in { 1, -1 } do
				local y = headY + sy * (CH / 2 + 0.03)
				b:box(Vector3.new(1.2, 0.08, 1.3), CFrame.new(0, y, 0), steel, "TopPlate")
				for _, z in { -0.3, 0.3 } do
					b:box(Vector3.new(0.76, 0.05, 0.06), CFrame.new(0, y + sy * 0.045, z), neon, "Vent")
				end
			end

			-- ── juntas de neón + remates ───────────────────────
			B.both(function(sx)
				-- junta: núcleo negro con tiras de neón bajo vidrio en las 4 caras
				b:box(Vector3.new(0.18, CH - 0.2, CD - 0.2), CFrame.new(sx * slotX, headY, 0), black, "Gasket")
				for _, sz in { 1, -1 } do
					b:box(Vector3.new(0.09, CH - 0.5, 0.06), CFrame.new(sx * slotX, headY, sz * (CD / 2 - 0.1)), neon, "SlotNeon")
					b:box(Vector3.new(0.14, CH - 0.44, 0.06), CFrame.new(sx * slotX, headY, sz * (CD / 2 - 0.06)), glass, "SlotGlass")
				end
				b:box(Vector3.new(0.09, 0.06, CD - 0.5), CFrame.new(sx * slotX, headY + CH / 2 - 0.1, 0), neon, "SlotNeonTop")

				-- remate de acero
				local ecf = CFrame.new(sx * ex, headY, 0)
				b:bevelBox(Vector3.new(EW, EH, ED), ecf, steelCore, 0.14, { edges = "X", edgeStyle = steelEdge, name = "End" })

				-- abrazaderas de oro (en L sobre las esquinas, lado del núcleo) — 4 por remate
				local bx = sx * (EX0 + 0.2)
				for _, cy in { 1, -1 } do
					for _, cz in { 1, -1 } do
						local cy0 = headY + cy * (EH / 2 - 0.22)
						local cz0 = cz * (ED / 2 - 0.22)
						-- pata en la cara Z
						b:box(Vector3.new(0.34, 0.54, 0.1), CFrame.new(bx, cy0, cz * (ED / 2 + 0.03)), gold, "Bracket")
						-- pata en la cara Y
						b:box(Vector3.new(0.34, 0.1, 0.54), CFrame.new(bx, headY + cy * (EH / 2 + 0.03), cz0), gold, "Bracket")
						-- canto brillante en la esquina
						b:box(Vector3.new(0.36, 0.1, 0.1), CFrame.new(bx, headY + cy * (EH / 2 - 0.01), cz * (ED / 2 - 0.01)) * CFrame.Angles(math.pi / 4, 0, 0), goldEdge, "BracketEdge")
					end
				end
				-- banda de hierro con remaches (lado exterior)
				local bandX = sx * (EX1 - 0.2)
				b:bevelBox(Vector3.new(0.2, EH + 0.08, ED + 0.08), CFrame.new(bandX, headY, 0), black, 0.06, { edges = "X", edgeStyle = steel, name = "Band" })
				for _, cz in { 1, -1 } do
					for _, y in { -0.6, 0.6 } do
						b:rivet(Vector3.new(bandX, headY + y, cz * (ED / 2 + 0.05)), 0.11, steelEdge)
					end
					-- tira de neón vertical en la cara del remate
					b:box(Vector3.new(0.07, 0.9, 0.05), CFrame.new(sx * (ex + 0.02), headY, cz * (ED / 2 + 0.01)), neon, "EndNeon")
					b:box(Vector3.new(0.15, 1.02, 0.05), CFrame.new(sx * (ex + 0.02), headY, cz * (ED / 2 + 0.035)), glass, "EndNeonGlass")
				end
				for _, cy in { 1, -1 } do
					b:rivet(Vector3.new(bandX, headY + cy * (EH / 2 + 0.05), 0), 0.11, steelEdge)
				end

				-- tapa de golpe octagonal con bobina brillante
				local capCF = CFrame.new(sx * capX, headY, 0)
				b:bevelBox(Vector3.new(0.26, 1.78, 1.78), capCF, steel, 0.42, { edges = "X", edgeStyle = steelEdge, name = "StrikeCap" })
				local fcf = B.faceX(sx, capX + 0.13, headY)
				b:bevelBox(Vector3.new(1.24, 1.24, 0.06), fcf * CFrame.new(0, 0, 0.02), black, 0.28, { edges = "Z", name = "CoilRecess" })
				b:cylZ(0.05, 1.0, fcf * CFrame.new(0, 0, 0.05), neon, "Coil")
				b:cylZ(0.05, 0.62, fcf * CFrame.new(0, 0, 0.075), black, "CoilRing")
				b:cylZ(0.05, 0.42, fcf * CFrame.new(0, 0, 0.1), neonHot, "CoilHot")
				for i = 0, 3 do
					local a = math.pi * 2 * i / 4 + math.pi / 4
					b:rivet(fcf:PointToWorldSpace(Vector3.new(math.cos(a) * 0.74, math.sin(a) * 0.74, 0)), 0.1, steelEdge)
				end
			end)
		end)

		-- ── arcos eléctricos ───────────────────────────────────
		-- arco = puntos sobre una circunferencia (alrededor del remate) con ruido radial
		local function arcPoints(cx, cy, z, r, a0, a1, n, amp, seed)
			local rnd = B.rng(seed)
			local pts = {}
			for i = 0, n do
				local t = i / n
				local a = a0 + (a1 - a0) * t
				local rr = r + (if i == 0 or i == n then -0.12 else rnd(-amp, amp))
				table.insert(pts, Vector3.new(cx + math.cos(a) * rr, cy + math.sin(a) * rr, z + rnd(-0.12, 0.12)))
			end
			return pts
		end
		B.both(function(sx)
			local folder = b:group(if sx > 0 then "ArcsR" else "ArcsL", function()
				local cx = sx * (ex + 0.2)
				local defs = {
					-- { z, radio, a0, a1, semilla, glow }  (ángulos para el lado +X; se espejan)
					{ 1.1, 1.32, 1.9, -1.2, 11, true }, -- lazo grande al frente (de arriba-adentro a abajo-afuera)
					{ -1.1, 1.3, 1.0, -1.9, 23, true }, -- lazo grande atrás
					{ 0.2, 1.45, 2.4, 0.5, 37, false }, -- chispazo arriba
				}
				for _, d in defs do
					local a0, a1 = d[3], d[4]
					if sx < 0 then
						a0, a1 = math.pi - d[3], math.pi - d[4]
					end
					local pts = arcPoints(cx, headY, d[1], d[2], a0, a1, 6, 0.24, d[5] + (if sx > 0 then 0 else 100))
					for _, p in b:polyline(pts, 0.05, 0.05, arcCore, Vector3.zAxis, false, "Arc") do
						table.insert(arcParts, p)
					end
					if d[6] then
						for _, p in b:polyline(pts, 0.12, 0.12, arcGlow, Vector3.zAxis, false, "ArcGlow") do
							table.insert(arcParts, p)
						end
					end
				end
			end)
			b:flicker(folder, if sx > 0 then 14 else 11, 0.55)
		end)

		-- ── mango ───────────────────────────────────────────────
		b:group("Shaft", function()
			local top = headY - CH / 2
			local bottom = A.ShaftBottom
			-- collar de bronce octagonal bajo la cabeza
			b:bevelBox(Vector3.new(0.7, 0.2, 0.7), CFrame.new(0, top - 0.1, 0), bronze, 0.14, { edges = "Y", edgeStyle = bronzeEdge, name = "Collar" })
			b:bevelBox(Vector3.new(0.56, 0.14, 0.56), CFrame.new(0, top - 0.27, 0), steelDark, 0.1, { edges = "Y", edgeStyle = steelEdge, name = "CollarLow" })
			-- eje de acero pavonado
			b:cylY(top - bottom - 0.2, A.ShaftDia, CFrame.new(0, (top + bottom) / 2 - 0.1, 0), steelDark, "ShaftCore")
			-- agarre segmentado: goma + anillos de acero + 3 anillos de neón bajo vidrio
			local g0, g1 = -1.15, 1.95
			local segs = 8
			local step = (g1 - g0) / segs
			local neonAt = { [2] = true, [4] = true, [6] = true }
			for i = 0, segs - 1 do
				local y = g0 + step * (i + 0.5)
				b:cylY(step - 0.05, 0.54, CFrame.new(0, y, 0), rubber, "Grip")
			end
			for i = 0, segs do
				local y = g0 + step * i
				if neonAt[i] then
					local ringN = b:cylY(0.1, 0.6, CFrame.new(0, y, 0), neon, "GripNeon")
					-- la energía "sube" por el mango: pulso escalonado de abajo hacia arriba
					b:pulse(ringN, 0, 0.55, 1.4, 1 - i * 0.12)
					b:cylY(0.16, 0.64, CFrame.new(0, y, 0), glass, "GripNeonGlass")
				else
					b:cylY(0.08, 0.62, CFrame.new(0, y, 0), steel, "GripRing")
				end
			end
		end)

		-- ── pomo ────────────────────────────────────────────────
		b:group("Pommel", function()
			local y = A.PommelY - 0.05
			b:cylY(0.08, 0.52, CFrame.new(0, y + 0.3, 0), neon, "PommelNeon")
			b:bevelBox(Vector3.new(0.86, 0.56, 0.86), CFrame.new(0, y, 0), steel, 0.24, { edges = "Y", edgeStyle = steelEdge, name = "Pommel" })
			b:bevelBox(Vector3.new(0.7, 0.12, 0.7), CFrame.new(0, y - 0.33, 0), black, 0.19, { edges = "Y", edgeStyle = steel, name = "PommelCap" })
			for i = 0, 3 do
				local a = math.pi / 2 * i
				b:rivet(Vector3.new(math.cos(a) * 0.44, y, math.sin(a) * 0.44), 0.14, chrome)
			end
			b:cylY(0.04, 0.24, CFrame.new(0, y - 0.4, 0), neonHot, "PommelGem")
		end)

		-- ── efectos ─────────────────────────────────────────────
		b:group("FX", function()
			B.both(function(sx)
				local v = b:fxVolume(Vector3.new(EW + 0.6, EH + 0.5, ED + 0.5), CFrame.new(sx * (ex + 0.15), headY, 0), "SparkVolume")
				b:emitter(v, B.Particles.electric(blue, 7), "Sparks")
			end)
			local core = b:fxVolume(Vector3.new(CW, CH, CD + 0.4), CFrame.new(0, headY, 0), "SparkleVolume")
			b:emitter(core, B.Particles.sparkle(blueHot, 5), "Sparkle")
		end)
		b:light(Vector3.new(0, headY, 0), blue, 2.2, 11, { pulse = { 1.2, 3 }, pulseSpeed = 2.2, name = "CoreGlow" })
		b:light(Vector3.new(-outerX, headY, 0), blueHot, 1.4, 7, { pulse = { 0.4, 2 }, pulseSpeed = 5, name = "ArcGlow" })

		local zap = B.Particles.electric(blueHot, 0)
		zap.Speed = NumberRange.new(10, 20)
		zap.Lifetime = NumberRange.new(0.1, 0.25)
		local ring = B.Particles.sparkle(blue, 0)
		ring.Speed = NumberRange.new(4, 8)
		local hit = b:impact(CFrame.new(-outerX - 0.05, headY, 0), blue, { sparks = 26, flash = 8, extra = { zap, ring } })
		-- (Builder no acepta EmitCount dentro de props: se fija el atributo directo)
		hit:FindFirstChild("ImpactExtra1"):SetAttribute("FX_Emit", 24)
		hit:FindFirstChild("ImpactExtra2"):SetAttribute("FX_Emit", 14)
		b:trail(Vector3.new(0, headY + CH / 2, 0), Vector3.new(0, headY - CH / 2, 0), blueHot, P.rgb(30, 90, 255), { lifetime = 0.24 })
	end,
}
