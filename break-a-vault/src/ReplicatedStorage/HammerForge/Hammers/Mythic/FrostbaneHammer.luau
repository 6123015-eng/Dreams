-- Frostbane Hammer (Mythic) — un martillo de acero congelado al que el hielo le está comiendo los extremos.
-- Bloque central de acero azulado con marco biselado y panel hundido donde GIRA lento un copo de nieve
-- de neón cian (con halo que late) en ambas caras. Dos pilares de acero con remaches-gema cian lo separan
-- de los remates, que están envueltos por racimos de cristales de hielo translúcidos con núcleo de neón
-- (una "flor" de picos alrededor de cada cara de golpe), más esquirlas que orbitan cada racimo.
-- Caras de golpe: marco octagonal de acero con placa de glaciar y núcleo cian bajo hielo.
-- Mango de cuero azul noche con correas plateadas cruzadas, anillos de neón bajo vidrio, collar con gemas
-- y pomo de acero que sostiene una gran gema azul facetada que brilla por dentro.
-- FX: escarcha y nieve que cae de los racimos, vaho frío, destellos, luces cian pulsantes.
return {
	Id = "FrostbaneHammer",
	DisplayName = "Frostbane Hammer",
	Rarity = "Mythic",
	Order = 1,
	Theme = "Frozen Vault",
	Build = function(b, P, B)
		local A = B.Anatomy
		local headY = A.HeadY + 0.05
		local TAU = math.pi * 2

		-- ── estilos ─────────────────────────────────────────────
		local steelDark = P.metal(P.rgb(40, 48, 66), 0.1) -- acero azulado
		local steelCore = P.metal(P.rgb(70, 82, 104), 0.14)
		local steel = P.metal(P.rgb(112, 128, 154), 0.16)
		local steelEdge = P.metal(P.rgb(176, 194, 220), 0.22) -- brillo de arista
		local recess = P.metal(P.rgb(12, 20, 36), 0.05)
		local frost = P.with(P.Ice, { Color = P.rgb(222, 240, 255) }) -- escarcha blanca
		local glacier = P.with(P.Glacier, { Color = P.rgb(120, 196, 250) })
		local cyan = P.rgb(70, 220, 255)
		local cyanHot = P.rgb(205, 248, 255)
		local blue = P.rgb(40, 130, 255)
		local neonCyan = P.neon(cyan)
		local neonHot = P.neon(cyanHot)
		local halo = P.neon(P.rgb(40, 140, 255), 0.78)
		local ice = P.crystal(P.rgb(130, 206, 255), 0.32)
		local iceDeep = P.crystal(P.rgb(50, 120, 255), 0.26)
		local iceCore = P.neon(P.rgb(90, 200, 255), 0.25)
		local iceCoreDeep = P.neon(P.rgb(40, 120, 255), 0.3)
		local glass = P.glass(P.rgb(170, 225, 255), 0.6)
		local leather = P.leather(P.rgb(26, 34, 58))
		local strap = P.metal(P.rgb(168, 186, 212), 0.18)
		local strapDark = P.metal(P.rgb(110, 126, 150), 0.12)

		-- ── medidas ────────────────────────────────────────────
		local CW, CH, CD = 2.0, 1.95, 1.8 -- bloque central
		local bandX = 1.0 -- pilares de acero
		local EX0, EX1 = 1.14, 1.64 -- remates (dentro del hielo)
		local capX = 1.71 -- tapa de golpe
		local clusterX = 1.5

		-- ── helpers ────────────────────────────────────────────
		-- CFrame con su Y local apuntando a `dir` (para cristales)
		local function alignY(pos: Vector3, dir: Vector3, roll: number?): CFrame
			local up = dir.Unit
			local ref = if math.abs(up.Y) < 0.9 then Vector3.yAxis else Vector3.xAxis
			local right = ref:Cross(up).Unit
			local back = right:Cross(up).Unit
			return CFrame.fromMatrix(pos, right, up, back) * CFrame.Angles(0, roll or 0, 0)
		end
		-- dirección en coordenadas esféricas alrededor del eje ±X (theta desde el eje, phi alrededor)
		local function sph(sx: number, theta: number, phi: number): Vector3
			local t, p = math.rad(theta), math.rad(phi)
			return Vector3.new(sx * math.cos(t), math.sin(t) * math.cos(p), math.sin(t) * math.sin(p))
		end
		-- esquirla con punta de cincel (3–4 piezas): cuerpo + prisma triangular
		local function shard(base: CFrame, len: number, w: number, st, coreSt)
			local bodyLen = len * 0.6
			local d = w * 0.72
			local out = {}
			table.insert(out, b:box(Vector3.new(w, bodyLen, d), base * CFrame.new(0, bodyLen / 2, 0), st, "Shard"))
			for _, p in b:triangle(
				base:PointToWorldSpace(Vector3.new(-w / 2, bodyLen - 0.001, 0)),
				base:PointToWorldSpace(Vector3.new(w / 2, bodyLen - 0.001, 0)),
				base:PointToWorldSpace(Vector3.new(w * 0.08, len, 0)),
				d, st, "ShardTip"
			) do
				table.insert(out, p)
			end
			if coreSt then
				table.insert(out, b:box(Vector3.new(w * 0.42, bodyLen * 0.85, d * 0.42), base * CFrame.new(0, bodyLen * 0.5, 0), coreSt, "ShardCore"))
			end
			return out
		end

		local cores = {}
		local snowflakes = {}

		b:group("Head", function()
			-- ── bloque central ─────────────────────────────────
			b:bevelBox(Vector3.new(CW, CH, CD), CFrame.new(0, headY, 0), steelDark, 0.14, { edges = "X", edgeStyle = steelEdge, name = "Core" })

			-- panel del copo en ambas caras
			B.both(function(s)
				local face = B.faceZ(s, headY, CD / 2)
				b:bevelBox(Vector3.new(1.5, 1.62, 0.12), face * CFrame.new(0, 0, 0.04), steel, 0.07, { edges = "Z", edgeStyle = steelEdge, name = "PanelFrame" })
				b:box(Vector3.new(1.22, 1.34, 0.08), face * CFrame.new(0, 0, 0.07), recess, "PanelRecess")
				-- grietas finas en el marco (acero claro)
				b:line(face:PointToWorldSpace(Vector3.new(-0.7, 0.55, 0.105)), face:PointToWorldSpace(Vector3.new(-0.62, 0.3, 0.105)), 0.035, 0.04, steelEdge, face.LookVector, "Crack")
				b:line(face:PointToWorldSpace(Vector3.new(0.62, -0.78, 0.105)), face:PointToWorldSpace(Vector3.new(0.42, -0.7, 0.105)), 0.035, 0.04, steelEdge, face.LookVector, "Crack")
				-- remaches de esquina (gema cian)
				for _, c in { Vector2.new(-1, -1), Vector2.new(1, -1), Vector2.new(1, 1), Vector2.new(-1, 1) } do
					b:ball(0.1, face:PointToWorldSpace(Vector3.new(c.X * 0.66, c.Y * 0.72, 0.1)), neonCyan, "PanelGem")
				end
				-- escarcha que trepa por la esquina inferior del marco
				b:box(Vector3.new(0.5, 0.12, 0.05), face * CFrame.new(-0.44, -0.74, 0.11) * CFrame.Angles(0, 0, 0.12), frost, "Rime")

				-- halo que late detrás del copo
				local hp = face * CFrame.new(0, 0, 0.12)
				local h = b:cylZ(0.04, 0.84, hp, halo, "SnowHalo")
				b:pulse(h, 0.35, 0.8, 1.2, if s > 0 then 0 else 0.4)
				-- copo de nieve (6 brazos con ramas en V + puntas) — gira lento
				local fp = face * CFrame.new(0, 0, 0.16)
				local n = fp.LookVector
				local R = 0.5
				local flake = {}
				local function seg(a: Vector2, c: Vector2, w: number, st)
					local p = b:line(fp:PointToWorldSpace(Vector3.new(a.X, a.Y, 0)), fp:PointToWorldSpace(Vector3.new(c.X, c.Y, 0)), w, 0.05, st, n, "Snowflake")
					if p then
						table.insert(flake, p)
					end
				end
				for i = 0, 2 do
					local a = math.pi / 2 + i * math.pi / 3
					local d = Vector2.new(math.cos(a), math.sin(a))
					seg(-d * R, d * R, 0.085, neonCyan)
				end
				for i = 0, 5 do
					local a = math.pi / 2 + i * math.pi / 3
					local d = Vector2.new(math.cos(a), math.sin(a))
					local nrm = Vector2.new(-d.Y, d.X)
					for _, k in { { 0.28, 0.16 } } do
						local root = d * R * (k[1] / 0.5)
						for _, side in { 1, -1 } do
							seg(root, root + (d * 0.75 + nrm * side * 0.66).Unit * k[2], 0.055, neonCyan)
						end
					end
				end
				table.insert(flake, b:cylZ(0.07, 0.24, fp * CFrame.new(0, 0, 0.01), neonHot, "SnowHub"))
				b:animate(flake, fp, { Spin = Vector3.new(0, 0, 0.45 * s) })
				table.insert(snowflakes, flake)
			end)

			-- arriba / abajo del núcleo: placa con ranura cian bajo vidrio y costra de escarcha
			for _, sy in { 1, -1 } do
				local y = headY + sy * (CH / 2 + 0.03)
				b:box(Vector3.new(1.3, 0.08, 1.24), CFrame.new(0, y, 0), steel, "TopPlate")
				b:box(Vector3.new(0.9, 0.05, 0.1), CFrame.new(0, y + sy * 0.05, 0), neonCyan, "Vent")
				b:box(Vector3.new(1.0, 0.06, 0.18), CFrame.new(0, y + sy * 0.065, 0), glass, "VentGlass")
			end
			b:box(Vector3.new(0.7, 0.1, 0.5), CFrame.new(-0.42, headY + CH / 2 + 0.1, 0.32) * CFrame.Angles(0, 0.3, 0), frost, "SnowCap")

			-- ── pilares, remates y tapas de golpe ──────────────
			B.both(function(sx)
				-- pilar de acero (anillo octagonal que abraza la cabeza)
				local bcf = CFrame.new(sx * bandX, headY, 0)
				b:bevelBox(Vector3.new(0.3, CH + 0.18, CD + 0.18), bcf, steel, 0.12, { edges = "X", edgeStyle = steelEdge, name = "Pillar" })
				b:box(Vector3.new(0.1, CH + 0.22, CD + 0.06), bcf, recess, "PillarGroove")
				for _, sz in { 1, -1 } do
					for _, y in { -0.66, 0, 0.66 } do
						b:ball(0.12, Vector3.new(sx * bandX, headY + y, sz * (CD / 2 + 0.1)), if y == 0 then neonHot else neonCyan, "PillarGem")
					end
				end

				-- remate de acero (casi todo cubierto por el hielo)
				local ex = sx * (EX0 + EX1) / 2
				b:box(Vector3.new(EX1 - EX0, CH - 0.15, CD - 0.12), CFrame.new(ex, headY, 0), steelCore, "End")
				-- placa de glaciar sobre el remate (hielo opaco)
				for _, sz in { 1, -1 } do
					b:box(Vector3.new(0.38, 1.3, 0.06), CFrame.new(ex, headY, sz * (CD / 2 - 0.04)), glacier, "EndIce")
				end

				-- tapa de golpe: marco octagonal + placa de glaciar + núcleo cian bajo hielo
				local capCF = CFrame.new(sx * capX, headY, 0)
				b:bevelBox(Vector3.new(0.16, 1.5, 1.42), capCF, steel, 0.36, { edges = "X", edgeStyle = steelEdge, name = "StrikeCap" })
				local fcf = B.faceX(sx, capX + 0.08, headY)
				b:bevelBox(Vector3.new(1.08, 1.12, 0.08), fcf * CFrame.new(0, 0, 0.02), glacier, 0.26, { edges = "Z", edgeStyle = frost, name = "StrikeIce" })
				local sc = b:cylZ(0.05, 0.56, fcf * CFrame.new(0, 0, 0.06), neonCyan, "StrikeCore")
				b:cylZ(0.08, 0.7, fcf * CFrame.new(0, 0, 0.07), glass, "StrikeCoreGlass")
				b:pulse(sc, 0, 0.4, 0.9, if sx > 0 then 0 else 0.5)
			end)
		end)

		-- ── racimos de cristales de hielo ──────────────────────
		B.both(function(sx)
			b:group(if sx > 0 then "IceR" else "IceL", function()
				local C = Vector3.new(sx * clusterX, headY, 0)
				local seed = if sx > 0 then 7 else 31
				local rnd = B.rng(seed)
				-- cristales grandes: corona alrededor de la cara de golpe (prisma + punta + núcleo)
				for i = 0, 4 do
					local phi = i * 72 + 15 + rnd(-12, 12)
					local theta = 50 + rnd(-8, 10)
					local dir = sph(sx, theta, phi)
					local len = 1.25 + rnd(0, 0.4)
					local w = 0.5 + rnd(0, 0.12)
					local st = if i % 2 == 0 then ice else iceDeep
					local parts = b:crystal(alignY(C + dir * 0.55, dir, rnd(0, 1.5)), len, w, st, if i % 2 == 0 then iceCore else iceCoreDeep)
					table.insert(cores, parts[#parts])
				end
				-- cristales medianos: salen de los lados del remate (arriba, abajo, frente, atrás)
				for i = 0, 4 do
					local phi = i * 72 + 51 + rnd(-10, 10)
					local theta = 88 + rnd(-10, 6)
					local dir = sph(sx, theta, phi)
					local len = 0.8 + rnd(0, 0.35)
					local w = 0.32 + rnd(0, 0.08)
					shard(alignY(C + Vector3.new(sx * rnd(-0.1, 0.15), 0, 0) + dir * 0.6, dir, rnd(0, 3)), len, w, if i % 2 == 0 then iceDeep else ice)
				end
				-- esquirlas chicas entre los grandes (cerca de la cara de golpe y hacia el centro)
				for i = 0, 1 do
					local phi = i * 180 + 40 + rnd(-20, 20)
					local theta = if i % 2 == 0 then 24 + rnd(0, 8) else 116 + rnd(0, 10)
					local dir = sph(sx, theta, phi)
					shard(alignY(C + dir * 0.55, dir, rnd(0, 3)), 0.5 + rnd(0, 0.25), 0.22, ice)
				end
				-- costra de hielo que une el racimo al acero + bloques gruesos de hielo (densidad)
				b:ball(1.35, C + Vector3.new(sx * 0.08, 0, 0), P.with(iceDeep, { Transparency = 0.4 }), "IceBulk")
				for i = 0, 3 do
					local a = TAU * i / 4 + rnd(-0.3, 0.3) + 0.5
					local pos = C + Vector3.new(sx * rnd(0.1, 0.35), math.cos(a) * 0.62, math.sin(a) * 0.62)
					b:box(Vector3.new(0.62, 0.62, 0.62) * rnd(0.85, 1.15), CFrame.new(pos) * CFrame.Angles(rnd(0, 3), rnd(0, 3), rnd(0, 3)), if i % 2 == 0 then ice else glacier, "IceChunk")
				end
			end)
		end)
		b:pulse(cores, 0.05, 0.55, 0.7)

		-- esquirlas que orbitan cada racimo (gema facetada con núcleo)
		local orbiters = {}
		B.both(function(sx)
			local list = {}
			for i = 0, 2 do
				local a = TAU * i / 3 + (if sx > 0 then 0 else 0.6)
				local pos = Vector3.new(sx * (clusterX + 0.35), headY + math.cos(a) * 1.75, math.sin(a) * 1.75)
				for _, p in b:gem(pos, 0.2, ice, neonHot) do
					table.insert(list, p)
				end
			end
			b:animate(list, CFrame.new(sx * (clusterX + 0.35), headY, 0), { Spin = Vector3.new(0.9 * sx, 0, 0), Bob = Vector3.new(sx * 0.08, 0, 0), BobSpeed = 0.4 })
			table.insert(orbiters, list)
		end)

		-- ── mango ───────────────────────────────────────────────
		local K = 1.4 -- escala radial del mango (agarre ~0.7 chunky como el concepto)
		local g0, g1 = -0.92, 1.74 -- agarre (mango más corto)
		b:group("Shaft", function()
			local top = headY - CH / 2
			-- collar: anillo de acero octagonal + banda con gemas + escarcha
			b:bevelBox(Vector3.new(0.86 * K, 0.24, 0.86 * K), CFrame.new(0, top - 0.12, 0), steel, 0.2 * K, { edges = "Y", edgeStyle = steelEdge, name = "Collar" })
			b:bevelBox(Vector3.new(0.7 * K, 0.28, 0.7 * K), CFrame.new(0, top - 0.37, 0), steelDark, 0.16 * K, { edges = "Y", edgeStyle = steel, name = "CollarBand" })
			for i = 0, 3 do
				local a = TAU * i / 4 + math.pi / 4
				b:ball(0.15, Vector3.new(math.cos(a) * 0.3 * K, top - 0.37, math.sin(a) * 0.3 * K), neonCyan, "CollarGem")
			end
			b:cylY(0.1, 0.6 * K, CFrame.new(0, top - 0.56, 0), steelEdge, "CollarLip")
			-- eje
			b:cylY(top - g0, 0.42 * K, CFrame.new(0, (top + g0) / 2, 0), steelDark, "ShaftCore")
			-- agarre de cuero azul noche
			b:cylY(g1 - g0, 0.5 * K, CFrame.new(0, (g0 + g1) / 2, 0), leather, "Grip")
			-- correas plateadas cruzadas (dos hélices en sentidos opuestos)
			local function helix(dirSign: number, phase: number, st)
				local turns, per = 2, 5
				local n = turns * per
				local r = 0.25 * K
				local height = g1 - g0
				local circ = TAU * r
				local pitch = height / turns
				local alpha = math.atan(pitch / circ)
				local segLen = math.sqrt((circ / per) ^ 2 + (pitch / per) ^ 2) * 1.1
				for i = 0, n - 1 do
					local t = (i + 0.5) / n
					local th = phase + dirSign * TAU * turns * t
					local y = g0 + height * t
					b:box(Vector3.new(0.06, 0.14, segLen), CFrame.new(0, y, 0) * CFrame.Angles(0, -th, 0) * CFrame.new(r + 0.025, 0, 0) * CFrame.Angles(-dirSign * alpha, 0, 0), st, "Strap")
				end
			end
			helix(1, 0, strap)
			helix(-1, math.pi, strapDark)
			-- anillos de neón bajo vidrio en los extremos del agarre
			for i, y in { g0 - 0.04, g1 + 0.04 } do
				local r = b:cylY(0.09, 0.58 * K, CFrame.new(0, y, 0), neonCyan, "GripNeon")
				b:cylY(0.16, 0.62 * K, CFrame.new(0, y, 0), glass, "GripGlass")
				b:pulse(r, 0, 0.5, 1.1, i * 0.4)
				b:cylY(0.07, 0.6 * K, CFrame.new(0, y + (if i == 1 then -0.12 else 0.12), 0), steel, "GripRing")
			end
		end)

		-- ── pomo (1.3x, pegado al agarre) ───────────────────────
		b:group("Pommel", function()
			local PK = 1.3
			local y = g0 - 0.08 - 0.29 * PK
			b:bevelBox(Vector3.new(0.66 * PK, 0.14 * PK, 0.66 * PK), CFrame.new(0, y + 0.22 * PK, 0), steelDark, 0.14 * PK, { edges = "Y", edgeStyle = steel, name = "PommelNeck" })
			b:bevelBox(Vector3.new(0.9 * PK, 0.28 * PK, 0.9 * PK), CFrame.new(0, y + 0.02 * PK, 0), steel, 0.24 * PK, { edges = "Y", edgeStyle = steelEdge, name = "PommelCup" })
			b:cylY(0.08, 0.78 * PK, CFrame.new(0, y - 0.13 * PK, 0), steelEdge, "PommelRim")
			for i = 0, 3 do
				local a = TAU * i / 4 + math.pi / 4
				b:ball(0.15, Vector3.new(math.cos(a) * 0.37 * PK, y + 0.02 * PK, math.sin(a) * 0.37 * PK), neonCyan, "PommelGem")
			end
			-- gran gema azul (corona dentro de la copa + pabellón facetado hacia abajo, más rechoncho)
			local gy = y - 0.14 * PK
			b:pyramid(CFrame.new(0, gy, 0) * CFrame.Angles(math.pi, 0, 0), 0.66, 0.8 * PK, 6, iceDeep, "PommelGem")
			b:cylY(0.12, 0.84 * PK, CFrame.new(0, gy + 0.02, 0), iceDeep, "PommelGemTable")
			local gc = b:ball(0.46, CFrame.new(0, gy - 0.18, 0), iceCore, "PommelGemCore")
			b:ball(0.2, CFrame.new(0, gy - 0.22, 0), neonHot, "PommelGemSpark")
			b:pulse(gc, 0.05, 0.5, 0.8, 0.3)
		end)

		-- ── efectos ─────────────────────────────────────────────
		b:group("FX", function()
			B.both(function(sx)
				local v = b:fxVolume(Vector3.new(2.2, 2.8, 2.8), CFrame.new(sx * (clusterX + 0.4), headY, 0), "FrostVolume")
				b:emitter(v, B.Particles.frost(cyan, 12), "Frost")
				-- nieve que cae del racimo
				local snow = B.Particles.frost(cyanHot, 6)
				snow.Acceleration = Vector3.new(0, -2.5, 0)
				snow.Size = B.seq(0, 0.14, 1, 0.06)
				snow.Lifetime = NumberRange.new(1.4, 2.2)
				b:emitter(v, snow, "Snow")
				-- vaho frío que baja
				local mist = B.Particles.smoke(P.rgb(190, 230, 255), 3)
				mist.Acceleration = Vector3.new(0, -0.6, 0)
				mist.Transparency = B.seq(0, 0.8, 0.4, 0.85, 1, 1)
				b:emitter(v, mist, "ColdMist")
			end)
			local core = b:fxVolume(Vector3.new(1.4, 1.5, CD + 0.5), CFrame.new(0, headY, 0), "SparkleVolume")
			b:emitter(core, B.Particles.sparkle(cyanHot, 5), "Sparkle")
		end)
		b:light(Vector3.new(0, headY, 0), cyan, 1.6, 10, { pulse = { 1.2, 2.6 }, pulseSpeed = 1.2, name = "CoreGlow" })
		b:light(Vector3.new(clusterX + 1.1, headY, 0), P.rgb(70, 170, 255), 1.3, 8, { pulse = { 0.8, 2 }, pulseSpeed = 0.7, name = "IceGlowR" })
		b:light(Vector3.new(-clusterX - 1.1, headY, 0), P.rgb(70, 170, 255), 1.3, 8, { pulse = { 0.8, 2 }, pulseSpeed = 0.75, name = "IceGlowL" })

		-- impacto: chispas cian + estallido de escarcha + esquirlas de hielo
		local burst = B.Particles.frost(cyanHot, 0)
		burst.Speed = NumberRange.new(6, 12)
		burst.Drag = 4
		burst.Lifetime = NumberRange.new(0.4, 0.9)
		local chips = B.Particles.sparkle(cyan, 0)
		chips.Speed = NumberRange.new(8, 14)
		chips.Acceleration = Vector3.new(0, -25, 0)
		chips.Size = B.seq(0, 0.26, 1, 0)
		local fog = B.Particles.smoke(P.rgb(200, 236, 255), 0)
		fog.Speed = NumberRange.new(2, 4)
		fog.Size = B.seq(0, 0.8, 1, 2.6)
		local hit = b:impact(CFrame.new(-capX - 0.2, headY, 0), cyan, { sparks = 24, flash = 8, extra = { burst, chips, fog } })
		hit:FindFirstChild("ImpactExtra1"):SetAttribute("FX_Emit", 30)
		hit:FindFirstChild("ImpactExtra2"):SetAttribute("FX_Emit", 18)
		hit:FindFirstChild("ImpactExtra3"):SetAttribute("FX_Emit", 6)
		b:trail(Vector3.new(0, headY + CH / 2 + 0.3, 0), Vector3.new(0, headY - CH / 2 - 0.3, 0), cyanHot, blue, { lifetime = 0.26 })
	end,
}
