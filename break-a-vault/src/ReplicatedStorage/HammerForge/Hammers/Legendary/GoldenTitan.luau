-- Golden Titan (Legendary) — el martillo de un titán solar: oro macizo pulido con paneles de mármol
-- blanco veteado. Bloque central de oro con un MEDALLÓN SOLAR en cada cara (aro de oro escalonado,
-- fondo negro, halo de neón dorado que late y una estrella de oro que gira lento sobre un sol de rayos
-- que gira al revés). Bandas de hierro negro con una ranura de neón dorado y remaches de oro.
-- Remates de mármol enmarcados en oro con aristas biseladas brillantes, grietas finas, picos de oro en
-- las esquinas exteriores y cara de golpe con marco, sol de mármol y punta central de oro.
-- Mango: cuello de oro remachado, agarre negro en espiral con anillos de oro y pomo de oro con picos.
-- FX: destellos dorados, motas de luz cálida, brillo subiendo del medallón, luz cálida pulsante,
-- impacto con esquirlas de oro y estallido solar.
return {
	Id = "GoldenTitan",
	DisplayName = "Golden Titan",
	Rarity = "Legendary",
	Order = 1,
	Theme = "Royal Treasury",
	Build = function(b, P, B)
		local A = B.Anatomy
		local headY = A.HeadY + 0.1

		-- ── estilos ─────────────────────────────────────────────
		local goldC = P.rgb(255, 196, 52)
		local gold = P.metal(P.rgb(236, 162, 30), 0.2)
		local goldDeep = P.metal(P.rgb(184, 112, 16), 0.16)
		local goldPale = P.foil(P.rgb(255, 214, 110), 0.26) -- arista brillante
		local goldDark = P.metal(P.rgb(120, 70, 12), 0.12) -- sombras / huecos
		local marble = P.stone(P.rgb(210, 204, 194), Enum.Material.Marble)
		local vein = P.stone(P.rgb(150, 144, 140), Enum.Material.Marble)
		local iron = P.metal(P.rgb(34, 30, 30), 0.08)
		local ironEdge = P.metal(P.rgb(84, 74, 64), 0.12)
		local field = P.style(P.rgb(22, 16, 20), Enum.Material.Basalt, 0)
		local neonGold = P.neon(P.rgb(255, 206, 70))
		local neonHot = P.neon(P.rgb(255, 240, 170))
		local grip = P.leather(P.rgb(28, 24, 24))
		local gripWrap = P.leather(P.rgb(48, 40, 36))

		-- ── helpers ─────────────────────────────────────────────
		local function along(pos: Vector3, dir: Vector3): CFrame
			local up = dir.Unit
			local ref = if math.abs(up.Y) < 0.9 then Vector3.yAxis else Vector3.xAxis
			local vx = up:Cross(ref).Unit
			local vz = vx:Cross(up).Unit
			return CFrame.fromMatrix(pos, vx, up, vz)
		end
		local function spike(pos: Vector3, dir: Vector3, len: number, w: number, sides: number?, st)
			return b:pyramid(along(pos - dir.Unit * 0.05, dir), len + 0.05, w, sides or 4, st or gold, "Spike")
		end
		local function frame(cf: CFrame, w: number, h: number, bar: number, depth: number, st, name)
			-- marco rectangular (4 barras) en el plano XY local de cf
			b:box(Vector3.new(w, bar, depth), cf * CFrame.new(0, h / 2 - bar / 2, 0), st, name)
			b:box(Vector3.new(w, bar, depth), cf * CFrame.new(0, -h / 2 + bar / 2, 0), st, name)
			b:box(Vector3.new(bar, h - 2 * bar, depth), cf * CFrame.new(w / 2 - bar / 2, 0, 0), st, name)
			b:box(Vector3.new(bar, h - 2 * bar, depth), cf * CFrame.new(-w / 2 + bar / 2, 0, 0), st, name)
		end

		-- ── medidas ────────────────────────────────────────────
		local CW, CH, CD = 1.5, 2.05, 1.95 -- bloque central
		local bandW, BH, BD = 0.22, 2.36, 2.26 -- bandas negras
		local bx = CW / 2 + bandW / 2 - 0.02
		local EX0, EX1 = bx + bandW / 2 - 0.02, 2.0
		local EW, EH, ED = EX1 - EX0, 2.24, 2.14 -- remates de mármol
		local ex = (EX0 + EX1) / 2

		local starParts, rayParts, haloParts = {}, {}, {}

		b:group("Head", function()
			-- ── bloque central de oro ─────────────────────────
			b:bevelBox(Vector3.new(CW, CH, CD), CFrame.new(0, headY, 0), gold, 0.16, { edgeStyle = goldPale, name = "Core" })
			-- placas de oro profundo arriba/abajo (segundo nivel)
			for _, sy in { 1, -1 } do
				b:box(Vector3.new(CW - 0.36, 0.1, CD - 0.36), CFrame.new(0, headY + sy * (CH / 2 + 0.03), 0), goldDeep, "TopPlate")
			end
			-- picos superiores (sol): uno alto al centro, dos inclinados
			spike(Vector3.new(0, headY + CH / 2 + 0.08, 0), Vector3.yAxis, 0.78, 0.38)
			B.both(function(s)
				spike(Vector3.new(s * 0.46, headY + CH / 2 + 0.06, 0), Vector3.new(s * 0.45, 1, 0), 0.5, 0.28, 3)
			end)

			-- ── medallón solar en ambas caras ─────────────────
			B.both(function(s)
				local z0 = CD / 2
				local face = B.faceZ(s, headY, z0)
				local function at(x, y, z)
					return face * CFrame.new(x, y, z)
				end
				b:cylZ(0.12, 1.5, at(0, 0, 0.06), goldDark, "MedallionBack")
				b:cylZ(0.22, 1.34, at(0, 0, 0.11), gold, "MedallionRim")
				b:cylZ(0.05, 1.18, at(0, 0, 0.2), goldPale, "MedallionLip")
				local halo = b:cylZ(0.05, 1.1, at(0, 0, 0.23), neonGold, "Halo")
				table.insert(haloParts, halo)
				b:cylZ(0.07, 1.0, at(0, 0, 0.25), field, "MedallionField")
				-- sol de rayos (gira al revés que la estrella)
				for i = 0, 7 do
					local a = math.rad(22.5 + i * 45)
					local long = i % 2 == 0
					local r0, r1 = 0.48, if long then 1.02 else 0.84
					local hw = if long then 0.13 else 0.1
					local dir = Vector3.new(math.cos(a), math.sin(a), 0)
					local side = Vector3.new(-dir.Y, dir.X, 0)
					local zz = 0.3
					local p0 = face:PointToWorldSpace(dir * r0 + side * hw + Vector3.new(0, 0, zz))
					local p1 = face:PointToWorldSpace(dir * r0 - side * hw + Vector3.new(0, 0, zz))
					local p2 = face:PointToWorldSpace(dir * r1 + Vector3.new(0, 0, zz))
					for _, p in b:triangle(p0, p1, p2, 0.08, if long then goldPale else gold, "SunRay") do
						table.insert(rayParts, p)
					end
				end
				-- estrella de oro (gira lento) con núcleo de luz
				-- estrella facetada 3D: 10 facetas que suben a un vértice central (claras/oscuras alternadas)
				local zb, rO, rI = 0.31, 0.54, 0.23
				local apex = face:PointToWorldSpace(Vector3.new(0, 0, zb + 0.16))
				local pts = {}
				for i = 0, 9 do
					local r = if i % 2 == 0 then rO else rI
					local a = math.pi / 2 + math.pi * i / 5
					table.insert(pts, face:PointToWorldSpace(Vector3.new(math.cos(a) * r, math.sin(a) * r, zb)))
				end
				for i = 1, 10 do
					local st = if i % 2 == 0 then goldPale else gold
					for _, p in b:triangle(pts[i], pts[i % 10 + 1], apex, 0.05, st, "Star") do
						table.insert(starParts, p)
					end
				end
				for _, p in b:gem(at(0, 0, 0.47), 0.12, goldPale, neonHot) do
					table.insert(starParts, p)
				end

			end)

			-- ── bandas de hierro negro con ranura de neón ─────
			B.both(function(sx)
				local x = sx * bx
				b:bevelBox(Vector3.new(bandW, BH, BD), CFrame.new(x, headY, 0), iron, 0.08, { edges = "X", edgeStyle = ironEdge, name = "Band" })
				-- filos de oro a los lados de la banda
				for _, ox in { -1, 1 } do
					b:box(Vector3.new(0.05, BH + 0.02, BD + 0.02), CFrame.new(x + ox * (bandW / 2 + 0.005), headY, 0), goldDeep, "BandLip")
				end
				-- ranura de neón dorado en las caras de emblema y arriba
				for _, sz in { 1, -1 } do
					table.insert(haloParts, b:box(Vector3.new(0.06, BH - 0.7, 0.05), CFrame.new(x, headY, sz * (BD / 2 + 0.005)), neonGold, "BandGlow"))
					b:rivet(Vector3.new(x, headY + BH / 2 - 0.2, sz * (BD / 2 + 0.01)), 0.13, goldPale)
					b:rivet(Vector3.new(x, headY - BH / 2 + 0.2, sz * (BD / 2 + 0.01)), 0.13, goldPale)
				end
			end)

			-- ── remates de mármol enmarcados en oro ───────────
			B.both(function(sx)
				local ecf = CFrame.new(sx * ex, headY, 0)
				b:bevelBox(Vector3.new(EW, EH, ED), ecf, marble, 0.22, { edgeStyle = gold, name = "EndBlock" })
				-- marcos de oro en las caras ±Z y ±Y (segunda capa) + vetas
				for _, sz in { 1, -1 } do
					local f = B.faceZ(sz, headY, ED / 2 + 0.02, sx * ex)
					frame(f, EW - 0.36, EH - 0.36, 0.08, 0.05, goldDeep, "PanelFrame")
					-- vetas del mármol
					local vx = sx * sz
					b:polyline({
						f:PointToWorldSpace(Vector3.new(-0.3 * vx, 0.62, 0.02)),
						f:PointToWorldSpace(Vector3.new(-0.06 * vx, 0.2, 0.02)),
						f:PointToWorldSpace(Vector3.new(0.14 * vx, -0.6, 0.02)),
					}, 0.035, 0.04, vein, f.LookVector, false, "Vein")
				end

				-- cara de golpe: marco de oro, sol de mármol, boss y punta
				local fx = sx * (EX1 + 0.06)
				local fcf = CFrame.new(fx, headY, 0) * CFrame.Angles(0, sx * math.pi / 2, 0)
				frame(fcf * CFrame.new(0, 0, 0.09), ED - 0.04, EH - 0.04, 0.2, 0.12, goldDeep, "StrikeFrame")
				b:box(Vector3.new(0.06, EH - 0.5, ED - 0.5), CFrame.new(sx * (EX1 + 0.14), headY, 0), marble, "StrikePanel")
				b:cylinder(0.16, 0.86, CFrame.new(sx * (EX1 + 0.2), headY, 0), goldDeep, "StrikeBoss")
				b:cylinder(0.08, 0.66, CFrame.new(sx * (EX1 + 0.3), headY, 0), goldPale, "StrikeBossLip")
				spike(Vector3.new(sx * (EX1 + 0.32), headY, 0), Vector3.new(sx, 0, 0), 0.55, 0.42, 4, gold)
				-- picos en las 4 esquinas exteriores
				for _, cy in { 1, -1 } do
					for _, cz in { 1, -1 } do
						spike(Vector3.new(sx * (EX1 - 0.08), headY + cy * (EH / 2 - 0.12), cz * (ED / 2 - 0.12)), Vector3.new(sx * 0.9, cy * 0.75, cz * 0.6), 0.6, 0.3, 3, gold)
					end
				end
			end)
		end)

		-- ── mango ───────────────────────────────────────────────
		b:group("Shaft", function()
			local top = headY - CH / 2
			local bottom = A.ShaftBottom
			b:cylY(top - bottom, 0.4, CFrame.new(0, (top + bottom) / 2, 0), goldDeep, "ShaftCore")
			-- cuello de oro bajo la cabeza
			local cy = top - 0.24
			b:bevelBox(Vector3.new(0.74, 0.4, 0.74), CFrame.new(0, cy, 0), gold, 0.16, { edges = "Y", edgeStyle = goldPale, name = "Collar" })
			b:cylY(0.1, 0.66, CFrame.new(0, cy - 0.25, 0), goldDark, "CollarLip")
			b:cylY(0.1, 0.56, CFrame.new(0, cy - 0.34, 0), goldPale, "CollarRing")
			for i = 0, 3 do
				local a = math.pi / 2 * i + math.pi / 4
				b:rivet(Vector3.new(math.cos(a) * 0.3, cy, math.sin(a) * 0.3), 0.13, goldPale)
			end
			-- agarre negro con espiral y anillos de oro
			local g0, g1 = -1.12, 1.62
			b:cylY(g1 - g0, 0.48, CFrame.new(0, (g0 + g1) / 2, 0), grip, "Grip")
			local n = 8
			local step = (g1 - g0) / n
			for i = 0, n - 1 do
				local tilt = if i % 2 == 0 then 0.2 else -0.2
				b:cylY(step * 0.9, 0.54, CFrame.new(0, g0 + step * (i + 0.5), 0) * CFrame.Angles(0, i * 0.8, 0) * CFrame.Angles(tilt, 0, 0), gripWrap, "GripWrap")
			end
			for _, y in { g0, g1, -0.2 } do
				b:cylY(0.13, 0.58, CFrame.new(0, y, 0), gold, "GripRing")
				b:cylY(0.05, 0.62, CFrame.new(0, y, 0), goldPale, "GripRingLip")
			end
		end)

		-- ── pomo ────────────────────────────────────────────────
		b:group("Pommel", function()
			local y = A.PommelY - 0.06
			b:bevelBox(Vector3.new(0.8, 0.5, 0.8), CFrame.new(0, y, 0), gold, 0.2, { edges = "Y", edgeStyle = goldPale, name = "Pommel" })
			b:bevelBox(Vector3.new(0.62, 0.14, 0.62), CFrame.new(0, y - 0.31, 0), goldDeep, 0.16, { edges = "Y", edgeStyle = gold, name = "PommelCap" })
			for i = 0, 3 do
				local a = math.pi / 2 * i
				b:ball(0.26, Vector3.new(math.cos(a) * 0.4, y, math.sin(a) * 0.4), goldPale, "Stud")
				local a2 = a + math.pi / 4
				b:rivet(Vector3.new(math.cos(a2) * 0.34, y + 0.12, math.sin(a2) * 0.34), 0.12, goldPale)
			end
			b:gem(CFrame.new(0, y - 0.42, 0), 0.18, goldPale, neonHot)
		end)

		-- ── animación ───────────────────────────────────────────
		B.both(function(s)
			local pivot = B.faceZ(s, headY, CD / 2)
			local mine = {}
			for _, p in starParts do
				if math.sign(p.CFrame.Position.Z) == s then
					table.insert(mine, p)
				end
			end
			b:animate(mine, pivot, { Spin = Vector3.new(0, 0, 0.6) })
			local rays = {}
			for _, p in rayParts do
				if math.sign(p.CFrame.Position.Z) == s then
					table.insert(rays, p)
				end
			end
			b:animate(rays, pivot, { Spin = Vector3.new(0, 0, -0.35) })
		end)
		b:pulse(haloParts, 0, 0.4, 0.8)

		-- ── efectos ─────────────────────────────────────────────
		b:group("FX", function()
			local v = b:fxVolume(Vector3.new(4.4, 2.6, 2.6), CFrame.new(0, headY, 0), "SparkleVolume")
			b:emitter(v, B.Particles.sparkle(goldC, 12), "GoldSparkle")
			local motes = B.Particles.orb(P.rgb(255, 210, 90), 5)
			motes.Size = B.seq(0, 0, 0.3, 0.26, 1, 0)
			b:emitter(v, motes, "GoldMotes")
			B.both(function(s)
				local m = b:fxVolume(Vector3.new(1.2, 1.2, 0.2), CFrame.new(0, headY, s * (CD / 2 + 0.4)), "MedallionFX")
				local rise = B.Particles.ember(P.rgb(255, 214, 96), 4)
				rise.Texture = B.Textures.Sparkle
				rise.Speed = NumberRange.new(0.3, 0.8)
				rise.Acceleration = Vector3.new(0, 1.2, 0)
				rise.Size = B.seq(0, 0.2, 1, 0)
				b:emitter(m, rise, "SunGlitter")
				local e = b:fxVolume(Vector3.new(0.3, 1.8, 1.8), CFrame.new(s * (EX1 + 0.2), headY, 0), "EndSparkle")
				b:emitter(e, B.Particles.sparkle(P.rgb(255, 236, 170), 3), "EndSparkle")
			end)
		end)
		b:light(Vector3.new(0, headY, 0), goldC, 1.4, 9, { pulse = { 0.9, 1.8 }, pulseSpeed = 0.8, name = "SunGlow" })
		b:light(Vector3.new(-EX1 - 0.4, headY, 0), P.rgb(255, 224, 140), 0.6, 5, { pulse = { 0.4, 0.9 }, pulseSpeed = 0.8, name = "StrikeGlow" })

		local shards = B.Particles.sparkle(P.rgb(255, 214, 90), 0)
		shards.Speed = NumberRange.new(8, 16)
		shards.Size = B.seq(0, 0.5, 1, 0)
		shards.Acceleration = Vector3.new(0, -18, 0)
		shards.Lifetime = NumberRange.new(0.35, 0.7)
		local burst = B.Particles.orb(P.rgb(255, 236, 160), 0)
		burst.Speed = NumberRange.new(6, 10)
		burst.Size = B.seq(0, 0.6, 1, 0)
		burst.Lifetime = NumberRange.new(0.25, 0.45)
		burst.Drag = 4
		local hit = b:impact(CFrame.new(-EX1 - 0.8, headY, 0), goldC, { sparks = 28, flash = 8, extra = { shards, burst } })
		hit:FindFirstChild("ImpactExtra1"):SetAttribute("FX_Emit", 24)
		hit:FindFirstChild("ImpactExtra2"):SetAttribute("FX_Emit", 16)
		b:trail(Vector3.new(0, headY + CH / 2, 0), Vector3.new(0, headY - CH / 2, 0), P.rgb(255, 244, 196), P.rgb(255, 160, 20), { lifetime = 0.26 })
	end,
}
