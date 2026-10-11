-- Celestial Crusher (Mythic) — el martillo de un ángel guardián de bóvedas: mármol blanco y oro.
-- Cabeza de mármol con grietas reparadas en oro (kintsugi), marcos dorados en los remates, bandas negras
-- con filo de oro junto al centro y tapas de golpe octagonales doradas con un sol incrustado.
-- En ambas caras, el EMBLEMA SOLAR: medallón de oro con núcleo de luz dorada, anillo celeste y rayos
-- que giran lento detrás, flanqueado por alitas de plumas blancas ribeteadas en oro. De la parte alta de
-- cada remate brota un ala grande de plumas (blancas con contorno dorado) que barre hacia arriba y afuera.
-- Arriba flota un HALO dorado que gira y sube y baja; orbes de luz dorada orbitan la cabeza.
-- Mango de mármol con venas de oro, cinta dorada en espiral, anillo celeste bajo el collar y pomo de oro.
-- FX: orbes dorados suaves, destellos, luz cálida pulsante.
return {
	Id = "CelestialCrusher",
	DisplayName = "Celestial Crusher",
	Rarity = "Mythic",
	Order = 3,
	Theme = "Heaven's Vault",
	Build = function(b, P, B)
		local A = B.Anatomy
		local headY = A.HeadY + 0.1
		local TAU = math.pi * 2

		-- ── estilos ─────────────────────────────────────────────
		local marble = P.with(P.Marble, { Color = P.rgb(196, 192, 186) })
		local marbleWarm = P.with(P.Marble, { Color = P.rgb(184, 176, 164) })
		local pearl = P.stone(P.rgb(214, 210, 202), Enum.Material.Marble) -- plumas
		local crack = P.stone(P.rgb(150, 146, 140), Enum.Material.Slate)
		local gold = P.with(P.Gold, { Color = P.rgb(255, 190, 50) })
		local goldDeep = P.metal(P.rgb(214, 140, 26), 0.2)
		local goldPale = P.foil(P.rgb(255, 224, 140), 0.26)
		local band = P.metal(P.rgb(34, 30, 36), 0.08) -- bandas negras
		local sun = P.rgb(255, 196, 70)
		local sunHot = P.rgb(255, 242, 196)
		local neonGold = P.neon(sun)
		local neonSun = P.neon(sunHot)
		local neonVein = P.neon(P.rgb(255, 210, 110), 0.1)
		local sky = P.neon(P.rgb(140, 205, 255), 0.1) -- anillo celeste
		local glass = P.glass(P.rgb(255, 236, 190), 0.65)
		local skyGlass = P.glass(P.rgb(170, 220, 255), 0.5)

		-- ── medidas ────────────────────────────────────────────
		local CW, CH, CD = 1.44, 1.9, 1.8 -- bloque central
		local bandX = 0.8
		local EX0, EX1 = 0.9, 1.84 -- remates de mármol
		local EH, ED = 1.98, 1.88
		local capX = EX1 + 0.08

		-- ── helpers ────────────────────────────────────────────
		-- pluma (cuerpo + punta) sobre el plano XY local de `plane`; ang en radianes dentro del plano
		local function feather(plane: CFrame, root: Vector2, ang: number, len: number, w: number, thick: number, st, z: number?)
			local dir = Vector3.new(math.cos(ang), math.sin(ang), 0)
			local right = Vector3.new(dir.Y, -dir.X, 0)
			local cf = plane * CFrame.fromMatrix(Vector3.new(root.X, root.Y, z or 0), right, dir, Vector3.zAxis)
			local bodyLen = len * 0.68
			local out = { b:box(Vector3.new(w, bodyLen, thick), cf * CFrame.new(0, bodyLen / 2, 0), st, "Feather") }
			for _, p in b:triangle(
				cf:PointToWorldSpace(Vector3.new(-w / 2, bodyLen - 0.001, 0)),
				cf:PointToWorldSpace(Vector3.new(w / 2, bodyLen - 0.001, 0)),
				cf:PointToWorldSpace(Vector3.new(-w * 0.2, len, 0)),
				thick, st, "FeatherTip"
			) do
				table.insert(out, p)
			end
			return out
		end
		-- pluma con contorno dorado: capa de oro más grande y delgada + pluma blanca más gruesa encima
		local function goldFeather(plane: CFrame, root: Vector2, ang: number, len: number, w: number, thick: number, z: number?, rimSt, bodySt)
			feather(plane, root, ang, len + 0.1, w + 0.08, thick * 0.6, rimSt or gold, z)
			feather(plane, root, ang, len, w, thick, bodySt or pearl, z)
		end

		b:group("Head", function()
			-- ── bloque central de mármol ───────────────────────
			b:bevelBox(Vector3.new(CW, CH, CD), CFrame.new(0, headY, 0), marble, 0.12, { edges = "X", edgeStyle = goldPale, name = "Core" })
			for _, sy in { 1, -1 } do
				local y = headY + sy * (CH / 2 + 0.03)
				b:box(Vector3.new(1.1, 0.08, 1.3), CFrame.new(0, y, 0), gold, "TopPlate")
				b:cylY(0.06, 0.4, CFrame.new(0, y + sy * 0.05, 0), neonGold, "TopSun")
			end

			-- ── bandas negras con filo de oro ──────────────────
			B.both(function(sx)
				local x = sx * bandX
				b:box(Vector3.new(0.16, CH + 0.1, CD + 0.1), CFrame.new(x, headY, 0), band, "Band")
				for _, k in { -1, 1 } do
					b:box(Vector3.new(0.05, CH + 0.16, CD + 0.16), CFrame.new(x + k * 0.1, headY, 0), gold, "BandTrim")
				end
			end)

			-- ── remates de mármol con marco dorado ────────────
			B.both(function(sx)
				local ex = sx * (EX0 + EX1) / 2
				local ecf = CFrame.new(ex, headY, 0)
				b:bevelBox(Vector3.new(EX1 - EX0, EH, ED), ecf, marble, 0.14, { edges = "X", edgeStyle = gold, name = "End" })
				-- marco dorado exterior (anillo que abraza el remate)
				b:bevelBox(Vector3.new(0.18, EH + 0.12, ED + 0.12), CFrame.new(sx * (EX1 - 0.12), headY, 0), gold, 0.12, { edges = "X", edgeStyle = goldPale, name = "EndFrame" })
				-- banda negra diagonal (como en el concepto) + filo dorado, en ambas caras
				for _, sz in { 1, -1 } do
					local f = B.faceZ(sz, headY, ED / 2 + 0.01, ex)
					b:box(Vector3.new(0.14, EH - 0.1, 0.04), f * CFrame.new(-sx * 0.14 * sz, 0, 0) * CFrame.Angles(0, 0, sx * sz * 0.35), band, "Stripe")
					-- grietas de mármol reparadas con oro (kintsugi) que brillan
					local n = f.LookVector
					local rnd = B.rng(if sx > 0 then (if sz > 0 then 3 else 5) else (if sz > 0 then 7 else 9))
					local pts = {}
					local x0, y0 = rnd(-0.1, 0.25) * sx * sz, 0.92
					for i = 0, 3 do
						table.insert(pts, f:PointToWorldSpace(Vector3.new(x0 + rnd(-0.12, 0.12), y0 - i * 0.26, 0.015)))
					end
					b:polyline(pts, 0.04, 0.04, neonVein, n, false, "GoldVein")
					b:line(f:PointToWorldSpace(Vector3.new(sx * sz * 0.3, -0.9, 0.012)), f:PointToWorldSpace(Vector3.new(sx * sz * 0.2, -0.55, 0.012)), 0.035, 0.04, crack, n, "Crack")
				end
				-- arriba/abajo: grieta y placa
				b:box(Vector3.new(0.5, 0.04, 0.04), CFrame.new(ex, headY + EH / 2 + 0.005, 0.3) * CFrame.Angles(0, 0.5, 0), neonVein, "GoldVein")

				-- tapa de golpe: octágono dorado + placa de mármol + sol incrustado
				local capCF = CFrame.new(sx * capX, headY, 0)
				b:bevelBox(Vector3.new(0.16, 1.6, 1.52), capCF, goldDeep, 0.4, { edges = "X", edgeStyle = gold, name = "StrikeCap" })
				local fcf = B.faceX(sx, capX + 0.08, headY)
				b:bevelBox(Vector3.new(1.08, 1.08, 0.06), fcf * CFrame.new(0, 0, 0.02), marbleWarm, 0.28, { edges = "Z", edgeStyle = goldPale, name = "StrikeMarble" })
				for i = 0, 3 do
					local a = i * math.pi / 2 + math.pi / 4
					local d = Vector3.new(math.cos(a), math.sin(a), 0)
					b:triangle(fcf:PointToWorldSpace(Vector3.new(-d.Y * 0.1, d.X * 0.1, 0.06)), fcf:PointToWorldSpace(Vector3.new(d.Y * 0.1, -d.X * 0.1, 0.06)), fcf:PointToWorldSpace(d * 0.44 + Vector3.new(0, 0, 0.06)), 0.04, gold, "StrikeRay")
				end
				local sc = b:cylZ(0.06, 0.36, fcf * CFrame.new(0, 0, 0.07), neonSun, "StrikeSun")
				b:cylZ(0.08, 0.44, fcf * CFrame.new(0, 0, 0.065), gold, "StrikeSunRim")
				b:pulse({ sc }, 0, 0.35, 1, if sx > 0 then 0 else 0.5)
			end)

			-- ── emblema solar (ambas caras) ────────────────────
			B.both(function(s)
				local face = B.faceZ(s, headY + 0.02, CD / 2)
				-- rayos que giran detrás del medallón (4 grandes + 4 chicos)
				local rays = {}
				local rp = face * CFrame.new(0, 0, 0.06)
				for i = 0, 7 do
					local a = i * math.pi / 4 + math.pi / 2
					local d = Vector3.new(math.cos(a), math.sin(a), 0)
					local big = i % 2 == 0
					local r1 = if big then 1.02 else 0.82
					local w = if big then 0.2 else 0.15
					for _, p in b:triangle(
						rp:PointToWorldSpace(Vector3.new(-d.Y * w, d.X * w, 0) + d * 0.45),
						rp:PointToWorldSpace(Vector3.new(d.Y * w, -d.X * w, 0) + d * 0.45),
						rp:PointToWorldSpace(d * r1),
						0.06, if big then gold else goldPale, "SunRay"
					) do
						table.insert(rays, p)
					end
				end
				b:animate(rays, rp, { Spin = Vector3.new(0, 0, 0.35 * s) })
				-- alitas a los lados del medallón
				for _, sx in { 1, -1 } do
					local base = math.pi / 2 - sx * math.pi / 2 -- 0 hacia +X, pi hacia -X
					for j, f in { { 0.15, 0.9, 0.22 }, { 0.6, 0.72, 0.19 } } do
						local ang = base + sx * f[1]
						goldFeather(face, Vector2.new(sx * 0.5, 0.08 - j * 0.06), ang, f[2], f[3], 0.05, 0.1 + j * 0.012)
					end
				end
				-- medallón: aro dorado, disco profundo, anillo celeste, núcleo de sol
				b:cylZ(0.12, 1.12, face * CFrame.new(0, 0, 0.12), gold, "MedalRim")
				b:cylZ(0.12, 0.94, face * CFrame.new(0, 0, 0.15), goldDeep, "MedalDisc")
				b:cylZ(0.06, 0.8, face * CFrame.new(0, 0, 0.2), sky, "SkyRing")
				b:cylZ(0.06, 0.7, face * CFrame.new(0, 0, 0.215), goldDeep, "SkyRingInner")
				local core = b:ball(0.6, face * CFrame.new(0, 0, 0.22), neonGold, "SunCore")
				local hot = b:ball(0.36, face * CFrame.new(0, 0, 0.36), neonSun, "SunHot")
				b:ball(0.7, face * CFrame.new(0, 0, 0.2), glass, "SunGlass")
				b:pulse({ core }, 0, 0.25, 1.1, if s > 0 then 0 else 0.3)
				b:pulse({ hot }, 0, 0.4, 2.2)
			end)
		end)

		-- ── alas grandes en los remates (plano XY, se ven de ambos lados) ─────
		b:group("Wings", function()
			local plane = CFrame.new()
			B.both(function(sx)
				local function a(deg: number): number
					local r = math.rad(deg)
					return if sx > 0 then r else math.pi - r
				end
				-- hombro sobre el remate; el "brazo" del ala sube hacia afuera y las plumas cuelgan de él
				local S = Vector2.new(sx * 1.0, headY + 1.02)
				local armAng = a(74)
				local armDir = Vector2.new(math.cos(armAng), math.sin(armAng))
				local armLen = 1.3
				-- primarias: de abajo (cortas, casi horizontales) a la punta (largas, más inclinadas)
				for i, t in { 0.1, 0.32, 0.54, 0.76, 0.98 } do
					local root = S + armDir * armLen * t
					goldFeather(plane, root, a(-8 + t * 34), 0.72 + t * 0.72, 0.36, 0.1, 0, gold)
				end
				-- coberteras sobre la raíz de las primarias (más gruesas → quedan encima)
				for _, t in { 0.22, 0.66 } do
					local root = S + armDir * armLen * t
					goldFeather(plane, root, a(t * 30), 0.5 + t * 0.25, 0.36, 0.18, 0, goldDeep)
				end
				-- brazo del ala, muñeca y hombro dorados
				local p0 = Vector3.new(S.X, S.Y, 0)
				local p1 = p0 + Vector3.new(armDir.X, armDir.Y, 0) * armLen
				b:line(p0, p1, 0.16, 0.26, gold, Vector3.zAxis, "WingArm")
				b:ball(0.24, p1, goldPale, "WingWrist")
				b:ball(0.36, p0, gold, "WingShoulder")
				b:line(Vector3.new(S.X - sx * 0.02, headY + EH / 2 - 0.05, 0), p0, 0.2, 0.26, goldDeep, Vector3.zAxis, "WingMount")
				b:ball(0.16, p0 + Vector3.new(0, 0, 0.15), neonSun, "WingGem")
				b:ball(0.16, p0 - Vector3.new(0, 0, 0.15), neonSun, "WingGem")
			end)
		end)

		-- ── halo flotante ──────────────────────────────────────
		local haloY = headY + CH / 2 + 0.95
		b:group("Halo", function()
			local hcf = CFrame.new(0.15, haloY, 0) * CFrame.Angles(math.rad(14), 0, math.rad(-10))
			local parts = b:ring(hcf, 0.72, 0.12, 18, neonGold, "Halo", 0.1)
			for i = 0, 3 do
				local a = TAU * i / 4
				table.insert(parts, b:ball(0.13, hcf:PointToWorldSpace(Vector3.new(math.cos(a) * 0.72, 0, math.sin(a) * 0.72)), neonSun, "HaloStar"))
			end
			b:animate(parts, CFrame.new(0.15, haloY, 0), { Spin = Vector3.new(0, 0.9, 0), Bob = Vector3.new(0, 0.12, 0), BobSpeed = 0.45 })
		end)

		-- orbes dorados que orbitan la cabeza (órbita inclinada)
		local orbit = {}
		local ocf = CFrame.new(0, headY, 0) * CFrame.Angles(math.rad(70), 0, math.rad(12))
		for i = 0, 3 do
			local a = TAU * i / 4
			table.insert(orbit, b:ball(if i % 2 == 0 then 0.16 else 0.11, ocf:PointToWorldSpace(Vector3.new(math.cos(a) * 2.25, 0, math.sin(a) * 1.4)), neonSun, "OrbitOrb"))
		end
		b:animate(orbit, ocf, { Spin = Vector3.new(0, 0.8, 0) })

		-- ── mango ───────────────────────────────────────────────
		b:group("Shaft", function()
			local top = headY - CH / 2
			local bottom = A.ShaftBottom
			-- collar dorado con picos de rayo + anillo celeste
			b:bevelBox(Vector3.new(0.9, 0.22, 0.9), CFrame.new(0, top - 0.11, 0), gold, 0.22, { edges = "Y", edgeStyle = goldPale, name = "Collar" })
			for i = 0, 3 do
				local a = TAU * i / 4 + math.pi / 4
				b:wedge(Vector3.new(0.14, 0.3, 0.22), CFrame.new(math.cos(a) * 0.42, top - 0.3, math.sin(a) * 0.42) * CFrame.Angles(0, -a - math.pi / 2, 0) * CFrame.Angles(math.pi, 0, 0), goldDeep, "CollarSpike")
			end
			b:cylY(0.18, 0.56, CFrame.new(0, top - 0.33, 0), sky, "SkyCollar")
			b:cylY(0.22, 0.6, CFrame.new(0, top - 0.33, 0), skyGlass, "SkyCollarGlass")
			b:cylY(0.1, 0.66, CFrame.new(0, top - 0.49, 0), gold, "CollarLow")
			-- eje de mármol
			local s0, s1 = bottom + 0.05, top - 0.5
			b:cylY(s1 - s0, 0.48, CFrame.new(0, (s0 + s1) / 2, 0), marble, "Shaft")
			-- cinta dorada en espiral
			b:wrap(-0.85, 1.6, 0.24, 2, goldPale, { width = 0.1, thickness = 0.04, segmentsPerTurn = 7, name = "GoldRibbon" })
			-- anillos de oro
			for _, y in { -0.95, 0.35, 1.7 } do
				b:cylY(0.14, 0.58, CFrame.new(0, y, 0), gold, "GoldRing")
			end
			-- venas doradas en el mármol
			b:polyline({ Vector3.new(0.1, 1.2, 0.24), Vector3.new(0.02, 0.95, 0.245), Vector3.new(0.12, 0.65, 0.24) }, 0.035, 0.03, neonVein, Vector3.zAxis, false, "GoldVein")
		end)

		-- ── pomo ────────────────────────────────────────────────
		b:group("Pommel", function()
			local y = A.PommelY - 0.05
			b:bevelBox(Vector3.new(0.8, 0.14, 0.8), CFrame.new(0, y + 0.26, 0), gold, 0.2, { edges = "Y", edgeStyle = goldPale, name = "PommelTop" })
			b:bevelBox(Vector3.new(0.88, 0.38, 0.88), CFrame.new(0, y, 0), marble, 0.24, { edges = "Y", edgeStyle = gold, name = "Pommel" })
			b:bevelBox(Vector3.new(0.82, 0.12, 0.82), CFrame.new(0, y - 0.24, 0), goldDeep, 0.22, { edges = "Y", edgeStyle = gold, name = "PommelCap" })
			for i = 0, 3 do
				local a = TAU * i / 4
				b:ball(0.13, Vector3.new(math.cos(a) * 0.45, y, math.sin(a) * 0.45), neonSun, "PommelGem")
			end
			b:cylY(0.06, 0.32, CFrame.new(0, y - 0.32, 0), neonSun, "PommelSun")
		end)

		-- ── efectos ─────────────────────────────────────────────
		b:group("FX", function()
			local v = b:fxVolume(Vector3.new(4.2, 2.6, 2.4), CFrame.new(0, headY + 0.2, 0), "HolyVolume")
			b:emitter(v, B.Particles.orb(sun, 9), "GoldOrbs")
			b:emitter(v, B.Particles.sparkle(sunHot, 12), "Sparkle")
			local hv = b:fxVolume(Vector3.new(1.4, 0.2, 1.4), CFrame.new(0.15, haloY, 0), "HaloVolume")
			local dust = B.Particles.sparkle(sun, 6)
			dust.Acceleration = Vector3.new(0, -1.2, 0)
			dust.Size = B.seq(0, 0, 0.2, 0.2, 1, 0)
			b:emitter(hv, dust, "HaloDust")
			B.both(function(sx)
				local wv = b:fxVolume(Vector3.new(1.2, 1.2, 0.3), CFrame.new(sx * 1.9, headY + 1.5, 0), "WingVolume")
				local fl = B.Particles.orb(sunHot, 4)
				fl.Size = B.seq(0, 0, 0.3, 0.22, 1, 0)
				fl.Acceleration = Vector3.new(0, -0.4, 0)
				b:emitter(wv, fl, "WingGlow")
			end)
		end)
		b:light(Vector3.new(0, headY, 0), sun, 1.3, 9, { pulse = { 0.8, 1.8 }, pulseSpeed = 1.1, name = "SunLight" })
		b:light(Vector3.new(0.15, haloY, 0), sun, 0.9, 6, { pulse = { 0.5, 1.2 }, pulseSpeed = 0.45, name = "HaloLight" })

		-- impacto: chispas doradas + estallido de luz + plumas de luz
		local burst = B.Particles.sparkle(sunHot, 0)
		burst.Speed = NumberRange.new(6, 12)
		burst.Size = B.seq(0, 0.5, 1, 0)
		local orbs = B.Particles.orb(sun, 0)
		orbs.Speed = NumberRange.new(3, 6)
		orbs.Lifetime = NumberRange.new(0.5, 1)
		local ring = B.Particles.sparkle(P.rgb(150, 210, 255), 0)
		ring.Speed = NumberRange.new(9, 14)
		ring.Drag = 5
		local hit = b:impact(CFrame.new(-capX - 0.2, headY, 0), sun, { sparks = 26, flash = 9, extra = { burst, orbs, ring } })
		hit:FindFirstChild("ImpactExtra1"):SetAttribute("FX_Emit", 26)
		hit:FindFirstChild("ImpactExtra2"):SetAttribute("FX_Emit", 10)
		hit:FindFirstChild("ImpactExtra3"):SetAttribute("FX_Emit", 16)
		b:trail(Vector3.new(0, headY + CH / 2 + 0.3, 0), Vector3.new(0, headY - CH / 2 - 0.3, 0), sunHot, P.rgb(255, 170, 40), { lifetime = 0.26 })
	end,
}
