-- Dragon Maul (Legendary) — una roca volcánica rajada por LAVA viva, con una CABEZA DE DRAGÓN de oro
-- saliendo por el extremo +X: cráneo biselado, ceja afilada, cuernos largos barridos hacia atrás,
-- cresta de púas, hocico con fosas que echan humo, mandíbula abierta que "respira" (sube y baja),
-- colmillos de marfil, ojos de neón ardiendo y escamas de oro bajando por el cuello.
-- El otro extremo (-X, cara de golpe) es roca de lava enmarcada en oro con grietas en estrella y picos
-- de bronce dorado en las esquinas. Grietas de lava que laten en todas las caras.
-- Mango forrado de cuero rojo cruzado con anillos de oro; pomo = GARRA de dragón de oro con uñas de
-- cristal rojo apretando un orbe de fuego. FX: llamas y brasas saliendo del hocico, humo de las fosas,
-- brasas subiendo de las grietas, luz rojo-naranja que late y parpadea; impacto con brasas y llamarada.
return {
	Id = "DragonMaul",
	DisplayName = "Dragon Maul",
	Rarity = "Legendary",
	Order = 3,
	Theme = "Dragon's Hoard",
	Build = function(b, P, B)
		local A = B.Anatomy
		local headY = A.HeadY + 0.1

		-- ── estilos ─────────────────────────────────────────────
		local fireC = P.rgb(255, 96, 20)
		local rock = P.style(P.rgb(48, 22, 20), Enum.Material.Basalt, 0)
		local rockEdge = P.style(P.rgb(98, 46, 34), Enum.Material.Basalt, 0)
		local rockDark = P.style(P.rgb(34, 16, 14), Enum.Material.Basalt, 0)
		local lavaRock = P.style(P.rgb(64, 26, 20), Enum.Material.CrackedLava, 0)
		local gold = P.metal(P.rgb(232, 160, 34), 0.2)
		local goldDeep = P.metal(P.rgb(176, 104, 18), 0.16)
		local goldPale = P.foil(P.rgb(255, 210, 108), 0.24)
		local goldDark = P.metal(P.rgb(110, 60, 12), 0.1)
		local ivory = P.stone(P.rgb(246, 232, 200), Enum.Material.Marble)
		local leather = P.leather(P.rgb(158, 30, 26))
		local leatherDark = P.leather(P.rgb(80, 14, 14))
		local talon = P.crystal(P.rgb(200, 24, 20), 0.08)
		local lava = P.neon(P.rgb(255, 92, 14))
		local lavaHot = P.neon(P.rgb(255, 196, 70))
		local eyeNeon = P.neon(P.rgb(255, 60, 10))

		-- ── helpers ─────────────────────────────────────────────
		local function along(pos: Vector3, dir: Vector3): CFrame
			local up = dir.Unit
			local ref = if math.abs(up.Y) < 0.9 then Vector3.yAxis else Vector3.xAxis
			local vx = up:Cross(ref).Unit
			local vz = vx:Cross(up).Unit
			return CFrame.fromMatrix(pos, vx, up, vz)
		end
		local function spike(pos: Vector3, dir: Vector3, len: number, w: number, sides: number?, st)
			return b:pyramid(along(pos - dir.Unit * 0.06, dir), len + 0.06, w, sides or 3, st or gold, "Spike")
		end
		local crackParts = {}
		local V = Vector2.new
		local function crack(face: CFrame, pts2: { Vector2 }, w: number?, st)
			local pts = {}
			for _, v in pts2 do
				table.insert(pts, face:PointToWorldSpace(Vector3.new(v.X, v.Y, 0.012)))
			end
			for _, p in b:polyline(pts, w or 0.07, 0.05, st or lava, face.LookVector, false, "LavaCrack") do
				table.insert(crackParts, p)
			end
		end

		-- ── medidas ────────────────────────────────────────────
		local RH, RD = 2.0, 1.9
		local LX0, LX1 = -1.9, -0.86 -- bloque de golpe
		local CX0, CX1 = -0.68, 0.48 -- roca central
		local bandX = (LX1 + CX0) / 2

		b:group("Head", function()
			-- ── bloque de golpe (-X) ──────────────────────────
			local lcx = (LX0 + LX1) / 2
			b:bevelBox(Vector3.new(LX1 - LX0, RH + 0.1, RD + 0.1), CFrame.new(lcx, headY, 0), rock, 0.2, { edgeStyle = rockEdge, name = "StrikeRock" })
			-- banda de oro entre bloques
			b:bevelBox(Vector3.new(0.24, RH + 0.3, RD + 0.3), CFrame.new(bandX, headY, 0), gold, 0.08, { edges = "X", edgeStyle = goldPale, name = "GoldBand" })
			b:box(Vector3.new(0.28, RH - 0.2, RD - 0.2), CFrame.new(bandX, headY, 0), goldDark, "GoldBandInner")
			for _, sz in { 1, -1 } do
				for _, y in { 0.78, -0.78 } do
					b:rivet(Vector3.new(bandX, headY + y, sz * (RD / 2 + 0.16)), 0.13, goldPale)
				end
			end
			-- marco de oro de la cara de golpe
			local fx = LX0 - 0.04
			local fh, fd = RH + 0.18, RD + 0.18
			for _, sy in { 1, -1 } do
				b:box(Vector3.new(0.2, 0.24, fd), CFrame.new(fx, headY + sy * (fh / 2 - 0.12), 0), gold, "StrikeFrame")
			end
			for _, sz in { 1, -1 } do
				b:box(Vector3.new(0.2, fh - 0.48, 0.24), CFrame.new(fx, headY, sz * (fd / 2 - 0.12)), gold, "StrikeFrame")
			end
			b:box(Vector3.new(0.08, fh - 0.4, fd - 0.4), CFrame.new(fx - 0.02, headY, 0), lavaRock, "StrikePanel")
			-- grieta en estrella sobre la cara de golpe
			local sf = B.faceX(-1, -fx + 0.04, headY)
			for i = 0, 4 do
				local a = math.rad(90 + i * 72 + (i % 2) * 9)
				local r1 = 0.62 + (i % 2) * 0.12
				crack(sf, { V(0, 0), V(math.cos(a) * r1 * 0.5 + 0.06, math.sin(a) * r1 * 0.5), V(math.cos(a) * r1, math.sin(a) * r1) }, 0.07)
			end
			table.insert(crackParts, b:cylinder(0.06, 0.3, CFrame.new(fx - 0.07, headY, 0), lavaHot, "StrikeCore"))
			-- picos de bronce dorado en las esquinas de golpe y arriba
			for _, cy in { 1, -1 } do
				for _, cz in { 1, -1 } do
					spike(Vector3.new(LX0 + 0.05, headY + cy * (RH / 2 - 0.05), cz * (RD / 2 - 0.05)), Vector3.new(-1, cy * 0.75, cz * 0.6), 0.62, 0.32, 3, goldDeep)
				end
			end
			spike(Vector3.new(lcx + 0.05, headY + RH / 2 + 0.05, 0.25), Vector3.new(-0.25, 1, 0.15), 0.62, 0.34, 3, goldDeep)

			-- ── roca central ──────────────────────────────────
			local ccx = (CX0 + CX1) / 2
			b:bevelBox(Vector3.new(CX1 - CX0, RH, RD), CFrame.new(ccx, headY, 0), rock, 0.18, { edgeStyle = rockEdge, name = "CoreRock" })
			-- resplandor de lava abajo (la roca "flota" sobre magma)
			table.insert(crackParts, b:box(Vector3.new(CX1 - CX0 - 0.5, 0.05, RD - 0.5), CFrame.new(ccx, headY - RH / 2 - 0.005, 0), lava, "UnderGlow"))

			-- grietas de lava en ambas caras (bloque de golpe + roca central)
			B.both(function(s)
				local f1 = B.faceZ(s, headY, (RD + 0.1) / 2, lcx)
				local k = s
				crack(f1, { V(-0.42 * k, 0.9), V(-0.1 * k, 0.42), V(-0.2 * k, 0.02), V(0.16 * k, -0.34), V(0.08 * k, -0.9) }, 0.08)
				crack(f1, { V(-0.2 * k, 0.02), V(-0.46 * k, -0.24) }, 0.06)
				local f2 = B.faceZ(s, headY, RD / 2, ccx)
				crack(f2, { V(-0.5 * k, 0.5), V(-0.22 * k, 0.32), V(0.0, 0.5), V(0.24 * k, 0.12), V(0.5 * k, 0.26) }, 0.08)
				crack(f2, { V(-0.1 * k, 0.4), V(-0.18 * k, -0.1), V(0.1 * k, -0.5), V(0.02 * k, -0.95) }, 0.07)
			end)
			-- grietas arriba
			local top = CFrame.new(ccx, headY + RH / 2, 0) * CFrame.Angles(-math.pi / 2, 0, 0)
			crack(top, { V(-0.5, 0.2), V(-0.16, -0.1), V(0.16, 0.25), V(0.5, -0.15) }, 0.07)
			local top2 = CFrame.new(lcx, headY + (RH + 0.1) / 2, 0) * CFrame.Angles(-math.pi / 2, 0, 0)
			crack(top2, { V(-0.4, -0.5), V(0.0, -0.05), V(0.3, 0.6) }, 0.07)
		end)

		-- ── cabeza de dragón (+X) ──────────────────────────────
		-- Espacio local del dragón: origen en el cuello (x0, headY), escala k.
		local jawParts, eyeParts, mouthParts = {}, {}, {}
		local x0, k = CX1, 1.35
		local function D(lx: number, ly: number, lz: number, rz: number?): CFrame
			return CFrame.new(x0 + lx * k, headY + ly * k, lz * k) * CFrame.Angles(0, 0, math.rad(rz or 0))
		end
		local function Dp(lx: number, ly: number, lz: number): Vector3
			return Vector3.new(x0 + lx * k, headY + ly * k, lz * k)
		end
		local mouthPos = Dp(1.95, -0.16, 0)
		local jawPivot = D(0.75, -0.3, 0)
		b:group("Dragon", function()
			-- collar de oro (cuello) pegado a la roca
			b:bevelBox(Vector3.new(0.22, RH + 0.24, RD + 0.24), CFrame.new(x0 + 0.06, headY, 0), gold, 0.09, { edges = "X", edgeStyle = goldPale, name = "NeckRing" })
			-- cuello con escamas (debajo del cráneo)
			b:bevelBox(Vector3.new(0.7, 0.62, 1.06) * k, D(0.36, -0.5, 0), goldDeep, 0.14, { edges = "Z", edgeStyle = gold, name = "Neck" })
			-- cráneo
			b:bevelBox(Vector3.new(0.86, 1.3, 1.3) * k, D(0.55, 0.2, 0), gold, 0.24, { edgeStyle = goldPale, name = "Skull" })
			-- ceja afilada (cae hacia el hocico)
			b:bevelBox(Vector3.new(0.7, 0.28, 1.44) * k, D(0.88, 0.6, 0, -14), goldDeep, 0.1, { edges = "Z", edgeStyle = goldPale, name = "Brow" })
			-- hocico superior + nariz
			local snout = D(1.32, 0.24, 0, -7)
			b:bevelBox(Vector3.new(1.0, 0.5, 0.9) * k, snout, gold, 0.18, { edgeStyle = goldPale, name = "Snout" })
			b:bevelBox(Vector3.new(0.3, 0.44, 0.78) * k, D(1.86, 0.14, 0, -12), goldDeep, 0.12, { edges = "Z", edgeStyle = goldPale, name = "Nose" })
			b:box(Vector3.new(0.9 * k, 0.07, 0.42 * k), snout * CFrame.new(-0.02, 0.25 * k + 0.02, 0), goldPale, "SnoutRidge")
			B.both(function(s)
				b:box(Vector3.new(0.14, 0.12, 0.14), D(1.98, 0.24, s * 0.22, -12), goldDark, "Nostril")
			end)
			-- garganta de fuego (entre mandíbulas)
			table.insert(mouthParts, b:box(Vector3.new(0.9, 0.3, 0.62) * k, D(1.25, -0.16, 0), lava, "MouthFire"))
			table.insert(mouthParts, b:box(Vector3.new(0.5, 0.16, 0.4) * k, D(1.05, -0.16, 0), lavaHot, "MouthCore"))
			-- mandíbula inferior (abierta, "respira")
			local jcf = jawPivot * CFrame.Angles(0, 0, math.rad(-14)) * CFrame.new(0.55 * k, -0.12 * k, 0)
			for _, p in b:bevelBox(Vector3.new(1.05, 0.26, 0.8) * k, jcf, gold, 0.1, { edgeStyle = goldPale, name = "Jaw" }) do
				table.insert(jawParts, p)
			end
			table.insert(jawParts, b:wedge(Vector3.new(0.7, 0.2, 0.4) * k, jcf * CFrame.new(0.02, -0.2 * k, 0) * CFrame.Angles(0, -math.pi / 2, math.pi), goldDeep, "Chin"))
			B.both(function(s)
				-- colmillos de marfil
				for _, t in { { 0.98, 0.3 }, { 1.3, 0.22 }, { 1.62, 0.32 } } do
					local ly = -0.02 - (t[1] - 0.8) * 0.12
					b:wedge(Vector3.new(0.07, t[2] * k, 0.14), D(t[1], ly - t[2] / 2, s * 0.37) * CFrame.Angles(math.pi, 0, 0), ivory, "Fang")
				end
				for _, t in { { 0.45, 0.2 }, { 0.8, 0.24 } } do
					table.insert(jawParts, b:wedge(Vector3.new(0.07, t[2] * k, 0.14), jcf * CFrame.new((t[1] - 0.55) * k, (0.13 + t[2] / 2) * k, s * 0.31 * k), ivory, "Fang"))
				end
				-- ojos de neón bajo la ceja
				local eye = D(0.92, 0.4, s * 0.655, -16)
				table.insert(eyeParts, b:box(Vector3.new(0.32 * k, 0.12 * k, 0.06), eye, eyeNeon, "Eye"))
				table.insert(eyeParts, b:box(Vector3.new(0.1, 0.09, 0.07), eye * CFrame.new(0.05, 0, 0.012), lavaHot, "Pupil"))
				-- cuernos barridos hacia atrás + cuerno secundario
				spike(Dp(0.5, 0.78, s * 0.4), Vector3.new(-1, 0.75, s * 0.22), 1.35 * k, 0.36 * k, 4, goldPale)
				spike(Dp(0.72, 0.66, s * 0.6), Vector3.new(-1, 0.25, s * 0.55), 0.78 * k, 0.26 * k, 3, gold)
				-- aletas de la mejilla (hacia atrás)
				spike(Dp(0.45, -0.22, s * 0.6), Vector3.new(-0.8, -0.3, s * 0.6), 0.55 * k, 0.24 * k, 3, goldDeep)
				-- escamas: dos filas escalonadas sobre el cuello
				local zf = (1.06 / 2 + 0.03) * k
				for i, sc in { { 0.14, -0.36 }, { 0.36, -0.36 }, { 0.58, -0.36 }, { 0.25, -0.6 }, { 0.47, -0.6 }, { 0.36, -0.8 } } do
					local st = if i > 3 then gold else goldPale
					b:box(Vector3.new(0.17, 0.17, 0.06) * k, CFrame.new(x0 + sc[1] * k, headY + sc[2] * k, s * (zf + 0.01 * (i % 2))) * CFrame.Angles(0, 0, math.pi / 4), st, "Scale")
				end
			end)
			-- cresta de púas sobre el cráneo
			spike(Dp(0.35, 0.86, 0), Vector3.new(-0.6, 1, 0), 0.6 * k, 0.3 * k, 3, goldPale)
			spike(Dp(0.8, 0.7, 0), Vector3.new(-0.5, 1, 0), 0.42 * k, 0.24 * k, 3, gold)
		end)
		b:animate(jawParts, jawPivot, { Bob = Vector3.new(0, -0.06, 0), BobSpeed = 0.5 })
		b:pulse(eyeParts, 0, 0.35, 1.3)
		b:pulse(crackParts, 0, 0.5, 0.6)
		b:pulse(mouthParts, 0, 0.3, 2.2)

		-- ── mango ───────────────────────────────────────────────
		b:group("Shaft", function()
			local top = headY - RH / 2
			local bottom = A.ShaftBottom
			b:cylY(top - bottom, 0.4, CFrame.new(0, (top + bottom) / 2, 0), goldDeep, "ShaftCore")
			local cy = top - 0.22
			b:bevelBox(Vector3.new(0.74, 0.38, 0.74), CFrame.new(0, cy, 0), gold, 0.16, { edges = "Y", edgeStyle = goldPale, name = "Collar" })
			b:cylY(0.1, 0.64, CFrame.new(0, cy - 0.25, 0), goldDark, "CollarLip")
			for i = 0, 3 do
				local a = math.pi / 2 * i + math.pi / 4
				b:rivet(Vector3.new(math.cos(a) * 0.3, cy, math.sin(a) * 0.3), 0.13, goldPale)
			end
			-- cuero rojo cruzado
			local g0, g1 = -1.12, 1.66
			b:cylY(g1 - g0, 0.48, CFrame.new(0, (g0 + g1) / 2, 0), leatherDark, "GripBase")
			local n = 7
			local step = (g1 - g0) / n
			for i = 0, n - 1 do
				local tilt = if i % 2 == 0 then 0.2 else -0.2
				b:cylY(step * 1.05, 0.56 - (i % 2) * 0.02, CFrame.new(0, g0 + step * (i + 0.5), 0) * CFrame.Angles(0, i * 0.7, 0) * CFrame.Angles(tilt, 0, 0), leather, "LeatherWrap")
			end
			for _, y in { g0, g1 } do
				b:cylY(0.14, 0.62, CFrame.new(0, y, 0), gold, "GripRing")
				b:cylY(0.05, 0.66, CFrame.new(0, y, 0), goldPale, "GripRingLip")
			end
		end)

		-- ── pomo: garra de dragón ───────────────────────────────
		local py = A.PommelY - 0.04
		b:group("Pommel", function()
			b:bevelBox(Vector3.new(0.74, 0.36, 0.74), CFrame.new(0, py, 0), gold, 0.18, { edges = "Y", edgeStyle = goldPale, name = "ClawCuff" })
			b:cylY(0.08, 0.8, CFrame.new(0, py + 0.14, 0), goldDeep, "CuffRim")
			-- orbe de fuego apretado por la garra
			local oy = py - 0.46
			table.insert(eyeParts, b:ball(0.16, Vector3.new(0, oy, 0), lava, "OrbCore"))
			b:ball(0.34, Vector3.new(0, oy, 0), P.glass(P.rgb(170, 20, 10), 0.3), "Orb")
			-- dedos (nudillos de oro) + uñas de cristal rojo curvadas hacia el orbe
			for i = 0, 3 do
				local a = math.pi / 2 * i + math.pi / 4
				local d = Vector3.new(math.cos(a), 0, math.sin(a))
				b:ball(0.22, Vector3.new(0, py - 0.18, 0) + d * 0.32, goldPale, "Knuckle")
				spike(Vector3.new(0, py - 0.24, 0) + d * 0.32, Vector3.new(0, -1, 0) - d * 0.4, 0.62, 0.2, 3, talon)
			end
		end)

		-- ── efectos ─────────────────────────────────────────────
		b:group("FX", function()
			-- llamas del hocico: el emisor apunta a +X (Y local → +X)
			local mouthCF = CFrame.new(mouthPos) * CFrame.Angles(0, 0, -math.pi / 2)
			local fl = B.Particles.flame(fireC, 14)
			fl.Speed = NumberRange.new(1.2, 2.2)
			fl.Acceleration = Vector3.new(0, 3, 0)
			fl.SpreadAngle = Vector2.new(18, 18)
			fl.Size = B.seq(0, 0.3, 0.5, 0.55, 1, 0)
			b:emitter(mouthCF, fl, "DragonBreath")
			local em = B.Particles.ember(P.rgb(255, 140, 40), 6)
			em.SpreadAngle = Vector2.new(30, 30)
			b:emitter(mouthCF, em, "BreathEmbers")
			-- humo de las fosas
			B.both(function(s)
				local sm = B.Particles.smoke(P.rgb(70, 54, 50), 2)
				sm.Size = B.seq(0, 0.15, 1, 0.6)
				sm.Speed = NumberRange.new(0.3, 0.6)
				b:emitter(Dp(2.02, 0.26, s * 0.22), sm, "NostrilSmoke")
			end)
			-- brasas que suben de las grietas
			local v = b:fxVolume(Vector3.new(2.8, 2.0, 2.0), CFrame.new(-0.6, headY, 0), "LavaVolume")
			b:emitter(v, B.Particles.ember(fireC, 8), "LavaEmbers")
			local glow = B.Particles.sparkle(P.rgb(255, 170, 60), 4)
			b:emitter(b:fxVolume(Vector3.new(1.6, 1.6, 1.6), Dp(0.9, 0.2, 0), "DragonVolume"), glow, "GoldGlints")
		end)
		b:light(mouthPos, fireC, 1.2, 8, { pulse = { 0.6, 1.6 }, pulseSpeed = 2.2, name = "BreathGlow" })
		b:light(Vector3.new(-0.6, headY, 0), P.rgb(255, 80, 20), 1.0, 8, { pulse = { 0.6, 1.4 }, pulseSpeed = 0.6, name = "LavaGlow" })

		local embers = B.Particles.ember(fireC, 0)
		embers.Speed = NumberRange.new(6, 12)
		embers.Acceleration = Vector3.new(0, -6, 0)
		embers.SpreadAngle = Vector2.new(70, 70)
		local blast = B.Particles.flame(fireC, 0)
		blast.Speed = NumberRange.new(4, 8)
		blast.SpreadAngle = Vector2.new(60, 60)
		blast.Size = B.seq(0, 0.8, 0.5, 1.4, 1, 0)
		local rubble = B.Particles.smoke(P.rgb(60, 36, 30), 0)
		rubble.Speed = NumberRange.new(2, 4)
		local hit = b:impact(CFrame.new(LX0 - 0.5, headY, 0), fireC, { sparks = 26, flash = 8, extra = { embers, blast, rubble } })
		hit:FindFirstChild("ImpactExtra1"):SetAttribute("FX_Emit", 22)
		hit:FindFirstChild("ImpactExtra2"):SetAttribute("FX_Emit", 10)
		hit:FindFirstChild("ImpactExtra3"):SetAttribute("FX_Emit", 6)
		b:trail(Vector3.new(0, headY + RH / 2, 0), Vector3.new(0, headY - RH / 2, 0), P.rgb(255, 210, 90), P.rgb(200, 30, 10), { lifetime = 0.26 })
	end,
}
