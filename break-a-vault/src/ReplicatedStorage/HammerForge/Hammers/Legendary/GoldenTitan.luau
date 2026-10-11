-- Golden Titan (Legendary) — el martillo de un titán solar: ORO MACIZO brillante y saturado por todos lados,
-- con apenas unas incrustaciones chicas de mármol blanco rajado (enmarcadas en oro grueso) en los remates.
-- Bloque central de oro con un gran MEDALLÓN SOLAR en cada cara: aro de oro escalonado, núcleo de luz cálida
-- de neón que late, estrella de oro facetada que gira lento y una corona de 6 picos de oro alrededor.
-- Bandas de hierro negro con ranura de neón dorado y remaches de oro. Remates de oro biselado con picos en
-- las esquinas; caras de golpe con marco de oro, escudo y punta central.
-- Mango: cuello de oro remachado, agarre negro grueso en espiral con anillos de oro y pomo de oro grande con
-- tachones y gema. FX: destellos y brasas doradas, motas de luz, brillo subiendo del medallón, luz dorada
-- pulsante, impacto con esquirlas de oro y estallido solar.
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
		local gold = P.metal(P.rgb(255, 195, 40), 0.3)
		local goldDeep = P.metal(P.rgb(232, 158, 22), 0.26)
		local goldPale = P.foil(P.rgb(255, 220, 104), 0.26) -- arista brillante
		local goldDark = P.metal(P.rgb(170, 104, 14), 0.2) -- sombras / huecos
		local marble = P.stone(P.rgb(212, 206, 196), Enum.Material.Marble)
		local vein = P.stone(P.rgb(120, 112, 108), Enum.Material.Marble)
		local iron = P.metal(P.rgb(34, 30, 30), 0.08)
		local ironEdge = P.metal(P.rgb(84, 74, 64), 0.12)
		local neonGold = P.neon(P.rgb(255, 196, 60))
		local neonWarm = P.neon(P.rgb(255, 150, 40))
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
		-- pico facetado sobre una cara (4 cuñas: dos faldas que suben a una arista, una clara y una oscura)
		local function faceSpike(face: CFrame, ang: number, r0: number, len: number, w: number, h: number)
			local dir = Vector3.new(math.cos(ang), math.sin(ang), 0)
			local side = Vector3.new(-dir.Y, dir.X, 0)
			local L = face:PointToWorldSpace(dir * r0 + side * w / 2)
			local R = face:PointToWorldSpace(dir * r0 - side * w / 2)
			local M = face:PointToWorldSpace(dir * (r0 - 0.04) + Vector3.new(0, 0, h))
			local T = face:PointToWorldSpace(dir * (r0 + len) + Vector3.new(0, 0, h * 0.25))
			b:triangle(L, M, T, 0.05, gold, "SunSpike")
			b:triangle(M, R, T, 0.05, goldPale, "SunSpike")
		end

		-- ── medidas ────────────────────────────────────────────
		local CW, CH, CD = 1.92, 2.16, 1.95 -- bloque central
		local bandW, BH, BD = 0.22, 2.4, 2.28 -- bandas negras
		local bx = CW / 2 + bandW / 2 - 0.02
		local EX0, EX1 = bx + bandW / 2 - 0.02, 2.24
		local EW, EH, ED = EX1 - EX0, 2.26, 2.16 -- remates de oro
		local ex = (EX0 + EX1) / 2

		local starParts, haloParts = {}, {}

		b:group("Head", function()
			-- ── bloque central de oro ─────────────────────────
			b:bevelBox(Vector3.new(CW, CH, CD), CFrame.new(0, headY, 0), gold, 0.16, { edgeStyle = goldPale, name = "Core" })
			-- placas de oro profundo arriba/abajo (segundo nivel)
			for _, sy in { 1, -1 } do
				b:box(Vector3.new(CW - 0.36, 0.1, CD - 0.36), CFrame.new(0, headY + sy * (CH / 2 + 0.03), 0), goldDeep, "TopPlate")
			end
			-- picos superiores: uno alto al centro, dos inclinados
			spike(Vector3.new(0, headY + CH / 2 + 0.08, 0), Vector3.yAxis, 0.85, 0.42)
			B.both(function(s)
				spike(Vector3.new(s * 0.58, headY + CH / 2 + 0.06, 0), Vector3.new(s * 0.45, 1, 0), 0.55, 0.3, 3)
			end)

			-- ── medallón solar (1.4x) en ambas caras ──────────
			B.both(function(s)
				local face = B.faceZ(s, headY, CD / 2)
				local function at(x, y, z)
					return face * CFrame.new(x, y, z)
				end
				b:cylZ(0.1, 1.98, at(0, 0, 0.05), goldDark, "MedallionBack")
				b:cylZ(0.2, 1.84, at(0, 0, 0.1), gold, "MedallionRim")
				b:cylZ(0.05, 1.62, at(0, 0, 0.2), goldPale, "MedallionLip")
				b:cylZ(0.06, 1.42, at(0, 0, 0.23), goldDeep, "MedallionStep")
				-- núcleo de luz cálida detrás de la estrella
				table.insert(haloParts, b:cylZ(0.05, 1.18, at(0, 0, 0.27), neonWarm, "SunCore"))
				table.insert(haloParts, b:cylZ(0.05, 0.62, at(0, 0, 0.29), neonHot, "SunCoreHot"))
				-- aro de oro elevado alrededor del núcleo
				b:ring(at(0, 0, 0.32) * CFrame.Angles(math.pi / 2, 0, 0), 0.64, 0.15, 10, goldPale, "SunRing", 0.12)
				-- corona de 6 picos de oro alrededor del medallón
				for i = 0, 5 do
					local ang = math.pi / 2 + i * math.pi / 3
					local long = i % 3 == 0
					faceSpike(at(0, 0, 0.2), ang, 0.86, if long then 0.5 else 0.36, if long then 0.36 else 0.3, 0.24)
				end
				-- estrella de oro facetada (gira lento): 10 facetas a un vértice
				local zb, rO, rI = 0.33, 0.76, 0.32
				local apex = face:PointToWorldSpace(Vector3.new(0, 0, zb + 0.24))
				local pts = {}
				for i = 0, 9 do
					local r = if i % 2 == 0 then rO else rI
					local an = math.pi / 2 + math.pi * i / 5
					table.insert(pts, face:PointToWorldSpace(Vector3.new(math.cos(an) * r, math.sin(an) * r, zb)))
				end
				for i = 1, 10 do
					local st = if i % 2 == 0 then goldPale else gold
					for _, p in b:triangle(pts[i], pts[i % 10 + 1], apex, 0.05, st, "Star") do
						table.insert(starParts, p)
					end
				end
				for _, p in b:gem(at(0, 0, 0.58), 0.14, goldPale, neonHot) do
					table.insert(starParts, p)
				end
				-- remaches de oro en las esquinas del bloque central
				for _, c in { { 1, 1 }, { 1, -1 }, { -1, 1 }, { -1, -1 } } do
					b:rivet(face:PointToWorldSpace(Vector3.new(c[1] * (CW / 2 - 0.2), c[2] * (CH / 2 - 0.2), 0.01)), 0.15, goldPale)
				end
			end)

			-- ── bandas de hierro negro con ranura de neón ─────
			B.both(function(sx)
				local x = sx * bx
				b:bevelBox(Vector3.new(bandW, BH, BD), CFrame.new(x, headY, 0), iron, 0.08, { edges = "X", edgeStyle = ironEdge, name = "Band" })
				for _, ox in { -1, 1 } do
					b:box(Vector3.new(0.05, BH + 0.02, BD + 0.02), CFrame.new(x + ox * (bandW / 2 + 0.005), headY, 0), goldDeep, "BandLip")
				end
				for _, sz in { 1, -1 } do
					table.insert(haloParts, b:box(Vector3.new(0.07, BH - 0.7, 0.05), CFrame.new(x, headY, sz * (BD / 2 + 0.005)), neonGold, "BandGlow"))
					b:rivet(Vector3.new(x, headY + BH / 2 - 0.2, sz * (BD / 2 + 0.01)), 0.14, goldPale)
					b:rivet(Vector3.new(x, headY - BH / 2 + 0.2, sz * (BD / 2 + 0.01)), 0.14, goldPale)
				end
			end)

			-- ── remates de oro con incrustaciones chicas de mármol rajado ──
			B.both(function(sx)
				local ecf = CFrame.new(sx * ex, headY, 0)
				b:bevelBox(Vector3.new(EW, EH, ED), ecf, gold, 0.2, { edgeStyle = goldPale, name = "EndBlock" })
				local function inset(f: CFrame, pw: number, ph: number, k: number)
					-- incrustación ~55% del área del panel, con marco de oro grueso (0.2) que sobresale
					local iw, ih = pw * 0.74, ph * 0.74
					b:box(Vector3.new(iw, ih, 0.06), f * CFrame.new(0, 0, 0.02), marble, "MarbleInset")
					frame(f * CFrame.new(0, 0, 0.05), iw + 0.4, ih + 0.4, 0.2, 0.12, goldDeep, "InsetFrame")
					-- grietas del mármol
					b:polyline({
						f:PointToWorldSpace(Vector3.new(-0.3 * iw * k, 0.42 * ih, 0.055)),
						f:PointToWorldSpace(Vector3.new(-0.04 * iw * k, 0.08 * ih, 0.055)),
						f:PointToWorldSpace(Vector3.new(0.12 * iw * k, -0.2 * ih, 0.055)),
						f:PointToWorldSpace(Vector3.new(0.34 * iw * k, -0.42 * ih, 0.055)),
					}, 0.035, 0.03, vein, f.LookVector, false, "Vein")
				end
				for _, sz in { 1, -1 } do
					inset(B.faceZ(sz, headY, ED / 2, sx * ex), EW - 0.3, EH - 0.36, sx * sz)
				end

				-- cara de golpe: marco de oro, escudo y punta
				local fx = sx * (EX1 + 0.06)
				local fcf = CFrame.new(fx, headY, 0) * CFrame.Angles(0, sx * math.pi / 2, 0)
				frame(fcf * CFrame.new(0, 0, 0.09), ED - 0.04, EH - 0.04, 0.2, 0.12, goldDeep, "StrikeFrame")
				b:box(Vector3.new(0.06, EH - 0.5, ED - 0.5), CFrame.new(sx * (EX1 + 0.12), headY, 0), goldDark, "StrikePanel")
				b:cylinder(0.16, 1.0, CFrame.new(sx * (EX1 + 0.2), headY, 0), gold, "StrikeBoss")
				b:cylinder(0.08, 0.76, CFrame.new(sx * (EX1 + 0.3), headY, 0), goldPale, "StrikeBossLip")
				spike(Vector3.new(sx * (EX1 + 0.32), headY, 0), Vector3.new(sx, 0, 0), 0.6, 0.48, 4, gold)
				-- picos en las aristas exteriores (arriba y abajo)
				for _, cy in { 1, -1 } do
					spike(Vector3.new(sx * (EX1 - 0.1), headY + cy * (EH / 2 - 0.1), 0), Vector3.new(sx * 0.9, cy * 0.8, 0), 0.72, 0.4, 4, goldPale)
				end
			end)
		end)

		-- ── mango (grueso y corto) ──────────────────────────────
		local K = 1.22 -- escala radial del mango (agarre ~0.73 de diámetro, como el concepto)
		local gripBottom = -0.96 -- fondo del agarre (mango ~12% más corto)
		b:group("Shaft", function()
			local top = headY - CH / 2
			local bottom = gripBottom - 0.1
			b:cylY(top - bottom, 0.56 * K, CFrame.new(0, (top + bottom) / 2, 0), goldDeep, "ShaftCore")
			-- cuello de oro bajo la cabeza
			local cy = top - 0.26
			b:bevelBox(Vector3.new(0.86 * K, 0.46, 0.86 * K), CFrame.new(0, cy, 0), gold, 0.18 * K, { edges = "Y", edgeStyle = goldPale, name = "Collar" })
			b:cylY(0.12, 0.78 * K, CFrame.new(0, cy - 0.28, 0), goldDark, "CollarLip")
			b:cylY(0.12, 0.7 * K, CFrame.new(0, cy - 0.38, 0), goldPale, "CollarRing")
			for i = 0, 3 do
				local a = math.pi / 2 * i + math.pi / 4
				b:rivet(Vector3.new(math.cos(a) * 0.36 * K, cy, math.sin(a) * 0.36 * K), 0.15, goldPale)
			end
			-- agarre negro con espiral y anillos de oro
			local g0, g1 = gripBottom, 1.36
			b:cylY(g1 - g0, 0.6 * K, CFrame.new(0, (g0 + g1) / 2, 0), grip, "Grip")
			local n = 6
			local step = (g1 - g0) / n
			for i = 0, n - 1 do
				local tilt = if i % 2 == 0 then 0.2 else -0.2
				b:cylY(step * 0.9, 0.66 * K, CFrame.new(0, g0 + step * (i + 0.5), 0) * CFrame.Angles(0, i * 0.8, 0) * CFrame.Angles(tilt, 0, 0), gripWrap, "GripWrap")
			end
			for _, y in { g0, g1, 0.2 } do
				b:cylY(0.16, 0.74 * K, CFrame.new(0, y, 0), gold, "GripRing")
				b:cylY(0.06, 0.78 * K, CFrame.new(0, y, 0), goldPale, "GripRingLip")
			end
		end)

		-- ── pomo (más ancho, pegado al agarre) ──────────────────
		b:group("Pommel", function()
			local PK = 1.32
			local ph = 0.66
			local y = gripBottom - 0.06 - ph / 2
			b:bevelBox(Vector3.new(1.04 * PK, ph, 1.04 * PK), CFrame.new(0, y, 0), gold, 0.26 * PK, { edges = "Y", edgeStyle = goldPale, name = "Pommel" })
			b:cylY(0.1, 1.08 * PK, CFrame.new(0, y + ph / 2 - 0.06, 0), goldDeep, "PommelBand")
			b:bevelBox(Vector3.new(0.8 * PK, 0.14, 0.8 * PK), CFrame.new(0, y - ph / 2 - 0.04, 0), goldDeep, 0.2 * PK, { edges = "Y", edgeStyle = gold, name = "PommelCap" })
			for i = 0, 3 do
				local a = math.pi / 2 * i
				b:ball(0.36, Vector3.new(math.cos(a) * 0.52 * PK, y, math.sin(a) * 0.52 * PK), goldPale, "Stud")
				local a2 = a + math.pi / 4
				b:rivet(Vector3.new(math.cos(a2) * 0.44 * PK, y + 0.15, math.sin(a2) * 0.44 * PK), 0.15, goldPale)
				b:rivet(Vector3.new(math.cos(a2) * 0.44 * PK, y - 0.15, math.sin(a2) * 0.44 * PK), 0.15, goldPale)
			end
			b:gem(CFrame.new(0, y - ph / 2 - 0.14, 0), 0.24, goldPale, neonHot)
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
			b:animate(mine, pivot, { Spin = Vector3.new(0, 0, 0.5) })
		end)
		b:pulse(haloParts, 0, 0.35, 0.8)

		-- ── efectos ─────────────────────────────────────────────
		b:group("FX", function()
			local v = b:fxVolume(Vector3.new(4.6, 2.7, 2.7), CFrame.new(0, headY, 0), "SparkleVolume")
			b:emitter(v, B.Particles.sparkle(goldC, 12), "GoldSparkle")
			local motes = B.Particles.orb(P.rgb(255, 210, 90), 5)
			motes.Size = B.seq(0, 0, 0.3, 0.26, 1, 0)
			b:emitter(v, motes, "GoldMotes")
			local emb = B.Particles.ember(P.rgb(255, 176, 40), 8)
			emb.Size = B.seq(0, 0.14, 1, 0)
			emb.Speed = NumberRange.new(0.6, 1.6)
			b:emitter(v, emb, "GoldEmbers")
			B.both(function(s)
				local m = b:fxVolume(Vector3.new(1.4, 1.4, 0.2), CFrame.new(0, headY, s * (CD / 2 + 0.45)), "MedallionFX")
				local rise = B.Particles.ember(P.rgb(255, 214, 96), 4)
				rise.Texture = B.Textures.Sparkle
				rise.Speed = NumberRange.new(0.3, 0.8)
				rise.Acceleration = Vector3.new(0, 1.2, 0)
				rise.Size = B.seq(0, 0.22, 1, 0)
				b:emitter(m, rise, "SunGlitter")
				local e = b:fxVolume(Vector3.new(0.3, 1.8, 1.8), CFrame.new(s * (EX1 + 0.2), headY, 0), "EndSparkle")
				b:emitter(e, B.Particles.sparkle(P.rgb(255, 236, 170), 3), "EndSparkle")
			end)
		end)
		b:light(Vector3.new(0, headY, 0), goldC, 1.9, 11, { pulse = { 1.2, 2.5 }, pulseSpeed = 0.8, name = "SunGlow" })
		b:light(Vector3.new(-EX1 - 0.4, headY, 0), P.rgb(255, 224, 140), 0.8, 6, { pulse = { 0.5, 1.1 }, pulseSpeed = 0.8, name = "StrikeGlow" })

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
