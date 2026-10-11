-- Obsidian Breaker (Legendary) — un bloque de obsidiana volcánica arrancado del corazón de una bóveda
-- maldita: roca negra pulida en losas irregulares, partida por GRIETAS de energía morada que laten.
-- Bandas de acero oscuro remachadas abrazan el bloque central; en cada cara un rombo de oro viejo
-- engasta una gema morada facetada con núcleo de neón. Los remates son rocas en capas, rotas y
-- chuecas, de las que brotan CRISTALES morados (vidrio con núcleo de neón) hacia arriba, abajo y afuera.
-- Caras de golpe: placa de acero negro con runa de neón en rombo y cristales en las esquinas.
-- Mango de obsidiana segmentado con anillos de neón morado, collar de acero y pomo erizado de cristales
-- con un cristal flotante que gira debajo. FX: partículas que se succionan hacia la gema, motas
-- moradas, destellos, grietas pulsantes y luz morada que late; impacto con esquirlas de obsidiana.
return {
	Id = "ObsidianBreaker",
	DisplayName = "Obsidian Breaker",
	Rarity = "Legendary",
	Order = 2,
	Theme = "Void Vault",
	Build = function(b, P, B)
		local A = B.Anatomy
		local headY = A.HeadY - 0.15

		-- ── estilos ─────────────────────────────────────────────
		local purple = P.rgb(160, 60, 255)
		local obs = P.style(P.rgb(26, 22, 34), Enum.Material.Basalt, 0.08)
		local obsEdge = P.style(P.rgb(104, 92, 128), Enum.Material.Slate, 0.22) -- arista clara
		local obsDeep = P.style(P.rgb(16, 13, 22), Enum.Material.Basalt, 0.04)
		local obsGloss = P.style(P.rgb(40, 34, 54), Enum.Material.Slate, 0.2)
		local steel = P.metal(P.rgb(92, 96, 108), 0.16)
		local steelEdge = P.metal(P.rgb(168, 174, 188), 0.22)
		local steelDark = P.metal(P.rgb(40, 42, 50), 0.1)
		local oldGold = P.metal(P.rgb(196, 146, 60), 0.18)
		local oldGoldPale = P.foil(P.rgb(236, 196, 110), 0.22)
		local crystal = P.crystal(P.rgb(96, 16, 214), 0.12)
		local crystalLight = P.crystal(P.rgb(150, 58, 255), 0.12)
		local neon = P.neon(P.rgb(150, 56, 255))
		local neonHot = P.neon(P.rgb(226, 170, 255))

		-- ── helpers ─────────────────────────────────────────────
		local function along(pos: Vector3, dir: Vector3): CFrame
			local up = dir.Unit
			local ref = if math.abs(up.Y) < 0.9 then Vector3.yAxis else Vector3.xAxis
			local vx = up:Cross(ref).Unit
			local vz = vx:Cross(up).Unit
			return CFrame.fromMatrix(pos, vx, up, vz)
		end
		local glowParts = {}
		-- cristal morado: pirámide de vidrio con núcleo de neón adentro (base enterrada en la roca)
		local function shard(pos: Vector3, dir: Vector3, len: number, w: number, sides: number?, light: boolean?, noCore: boolean?)
			local base = along(pos - dir.Unit * 0.12, dir)
			b:pyramid(base, len + 0.12, w, sides or 4, if light then crystalLight else crystal, "Crystal")
			if noCore then
				return
			end
			table.insert(glowParts, b:box(Vector3.new(w * 0.38, len * 0.66, w * 0.38), base * CFrame.new(0, len * 0.36, 0) * CFrame.Angles(0, math.pi / 4, 0), neon, "CrystalCore"))
		end
		local crackParts = {}
		local function crack(face: CFrame, pts2: { Vector2 }, w: number?)
			local pts = {}
			for _, v in pts2 do
				table.insert(pts, face:PointToWorldSpace(Vector3.new(v.X, v.Y, 0.012)))
			end
			for _, p in b:polyline(pts, w or 0.06, 0.05, neon, face.LookVector, false, "Crack") do
				table.insert(crackParts, p)
			end
		end
		local V = Vector2.new

		-- ── medidas ────────────────────────────────────────────
		local CW, CH, CD = 1.5, 2.1, 2.0 -- bloque central
		local bandW, BH, BD = 0.3, 2.5, 2.36 -- bandas de acero
		local bx = CW / 2 + bandW / 2 - 0.02
		local EX0, EX1 = bx + bandW / 2 - 0.04, 2.12
		local EW, EH, ED = EX1 - EX0, 2.34, 2.24
		local ex = (EX0 + EX1) / 2
		local rnd = B.rng(7331)

		-- trozo de obsidiana: bloque biselado, un poco chueco, con arista clara
		local function chunk(sx: number, u0: number, u1: number, y0: number, y1: number, depth: number, st, tilt: number)
			local g = 0.09 -- junta (deja ver el núcleo de neón)
			local size = Vector3.new(u1 - u0 - g, y1 - y0 - g, depth)
			local ctr = Vector3.new(sx * (EX0 + (u0 + u1) / 2), headY + (y0 + y1) / 2, rnd(-0.03, 0.03))
			local cf = CFrame.new(ctr) * CFrame.Angles(rnd(-tilt, tilt), rnd(-tilt, tilt) * sx, rnd(-tilt, tilt) * sx)
			b:bevelBox(size, cf, st, math.min(0.18, math.min(size.X, size.Y) * 0.24), { edges = "Z", edgeStyle = obsEdge, name = "Chunk" })
			return cf, size
		end

		b:group("Head", function()
			-- ── bloque central de obsidiana ───────────────────
			b:bevelBox(Vector3.new(CW, CH, CD), CFrame.new(0, headY, 0), obs, 0.14, { edgeStyle = obsEdge, name = "Core" })

			-- ── emblema: rombo de oro con gema facetada ───────
			B.both(function(s)
				local face = B.faceZ(s, headY, CD / 2)
				local function wp(x, y, z)
					return face:PointToWorldSpace(Vector3.new(x, y, z))
				end
				-- marco de oro (doble: base oscura + filo claro)
				local rw, rh = 0.62, 0.95
				local outer = { wp(0, rh, 0.05), wp(rw, 0, 0.05), wp(0, -rh, 0.05), wp(-rw, 0, 0.05) }
				b:polyline(outer, 0.16, 0.1, oldGold, face.LookVector, true, "EmblemFrame")
				local outer2 = { wp(0, rh + 0.1, 0.03), wp(rw + 0.07, 0, 0.03), wp(0, -rh - 0.1, 0.03), wp(-rw - 0.07, 0, 0.03) }
				b:polyline(outer2, 0.05, 0.06, oldGoldPale, face.LookVector, true, "EmblemLip")
				-- fondo de neón (asoma alrededor de la gema)
				table.insert(glowParts, b:box(Vector3.new(rw * 0.95, rh * 0.95, 0.04), face * CFrame.new(0, 0, 0.04) * CFrame.Angles(0, 0, math.pi / 4), neon, "GemGlow"))
				-- gema facetada: 4 facetas a un vértice
				local gw, gh = rw * 0.78, rh * 0.8
				local g = { wp(0, gh, 0.07), wp(gw, 0, 0.07), wp(0, -gh, 0.07), wp(-gw, 0, 0.07) }
				local apex = wp(0, 0.05, 0.3)
				for i = 1, 4 do
					b:triangle(g[i], g[i % 4 + 1], apex, 0.05, if i % 2 == 0 then crystalLight else crystal, "Gem")
				end
				table.insert(glowParts, b:box(Vector3.new(0.12, 0.2, 0.06), face * CFrame.new(0, 0.04, 0.2) * CFrame.Angles(0, 0, 0), neonHot, "GemSpark"))
				-- grietas en el bloque central (salen del emblema)
				crack(face, { V(-0.36, 0.6), V(-0.55, 0.78), V(-0.62, 1.0) }, 0.08)
				crack(face, { V(0.38, -0.56), V(0.52, -0.78), V(0.7, -0.88) }, 0.08)
			end)

			-- ── bandas de acero gruesas, biseladas y remachadas ─
			B.both(function(sx)
				local x = sx * bx
				b:bevelBox(Vector3.new(bandW, BH, BD), CFrame.new(x, headY, 0), steel, 0.09, { edges = "X", edgeStyle = steelEdge, name = "Band" })
				b:box(Vector3.new(bandW + 0.04, BH - 0.44, BD - 0.44), CFrame.new(x, headY, 0), steelDark, "BandInner")
				for _, sz in { 1, -1 } do
					b:rivetLine(Vector3.new(x, headY + BH / 2 - 0.22, sz * (BD / 2 + 0.01)), Vector3.new(x, headY - BH / 2 + 0.22, sz * (BD / 2 + 0.01)), 2, 0.15, steelEdge)
				end
				b:rivet(Vector3.new(x, headY + BH / 2 + 0.01, 0), 0.14, steelEdge)
			end)

			-- ── remates: cúmulos de trozos de obsidiana sobre un núcleo de neón ─
			B.both(function(sx)
				-- núcleo de energía: brilla por TODAS las juntas (hundido ~0.1 bajo la superficie)
				table.insert(crackParts, b:box(Vector3.new(EW - 0.16, EH - 0.2, ED - 0.2), CFrame.new(sx * ex, headY, 0), neon, "SeamCore"))
				local W = EW
				-- aparejo irregular (u = 0 junto a la banda, W = cara de golpe; y relativo al centro)
				chunk(sx, -0.02, 0.62, 0.2, 1.19, ED + 0.02, obs, 0.1)
				chunk(sx, 0.62, W + 0.06, 0.02, 1.3, ED + 0.14, obsGloss, 0.11)
				chunk(sx, -0.02, 0.5, -0.52, 0.2, ED + 0.1, obsGloss, 0.1)
				chunk(sx, 0.5, W + 0.04, -1.2, 0.02, ED + 0.06, obs, 0.11)
				chunk(sx, -0.02, 0.5, -1.2, -0.52, ED - 0.04, obs, 0.1)
				-- cara de golpe: placa de acero negro con runa de neón y gema
				local fx = sx * (EX1 + 0.05)
				b:bevelBox(Vector3.new(0.16, EH - 0.62, ED - 0.62), CFrame.new(fx, headY, 0), steelDark, 0.07, { edges = "X", edgeStyle = steel, name = "StrikePlate" })
				b:box(Vector3.new(0.12, EH - 0.5, ED - 0.5), CFrame.new(sx * (EX1 + 0.01), headY, 0), steel, "StrikeLip")
				local sf = B.faceX(sx, EX1 + 0.13, headY)
				local rr = 0.5
				local rune = { sf:PointToWorldSpace(Vector3.new(0, rr, 0)), sf:PointToWorldSpace(Vector3.new(rr, 0, 0)), sf:PointToWorldSpace(Vector3.new(0, -rr, 0)), sf:PointToWorldSpace(Vector3.new(-rr, 0, 0)) }
				for _, p in b:polyline(rune, 0.09, 0.05, neon, sf.LookVector, true, "Rune") do
					table.insert(crackParts, p)
				end
				for _, p in b:gem(sf * CFrame.new(0, 0, 0.04), 0.3, crystalLight, neonHot) do
					table.insert(glowParts, p)
				end
				for _, c in { { 1, 1 }, { 1, -1 }, { -1, 1 }, { -1, -1 } } do
					b:rivet(sf:PointToWorldSpace(Vector3.new(c[1] * 0.66, c[2] * 0.66, -0.02)), 0.14, steelEdge)
				end
				-- cristales (1.5x): brotan de las juntas hacia arriba, abajo, afuera y al frente
				shard(Vector3.new(sx * (ex + 0.22), headY + EH / 2 + 0.1, 0.22), Vector3.new(sx * 0.35, 1, 0.15), 1.35, 0.6, 4, true)
				shard(Vector3.new(sx * (ex - 0.26), headY + EH / 2 + 0.02, -0.5), Vector3.new(sx * 0.1, 1, -0.45), 0.85, 0.42, 3)
				shard(Vector3.new(sx * (EX1 - 0.12), headY - EH / 2 + 0.22, 0.55), Vector3.new(sx * 0.8, -0.9, 0.35), 0.95, 0.46, 3)
				shard(Vector3.new(sx * (EX1 - 0.12), headY + 0.3, -ED / 2 + 0.25), Vector3.new(sx, 0.25, -0.75), 0.9, 0.44, 3, true)
				shard(Vector3.new(sx * (EX1 - 0.15), headY - 0.4, ED / 2 - 0.2), Vector3.new(sx, -0.1, 0.8), 0.78, 0.4, 3)
			end)

			-- cristales sobre el bloque central
			shard(Vector3.new(0.18, headY + CH / 2, -0.25), Vector3.new(0.15, 1, -0.2), 1.05, 0.48, 4, true)
		end)

		-- ── mango ───────────────────────────────────────────────
		local K = 1.24 -- escala radial del mango (agarre chunky como el concepto)
		local g0, g1 = -0.9, 1.42 -- agarre (mango ~12% más corto)
		b:group("Shaft", function()
			local top = headY - CH / 2
			local bottom = g0 - 0.1
			b:cylY(top - bottom, 0.5 * K, CFrame.new(0, (top + bottom) / 2, 0), obsDeep, "ShaftCore")
			-- collar de acero con anillo de neón
			local cy = top - 0.2
			b:bevelBox(Vector3.new(0.8 * K, 0.38, 0.8 * K), CFrame.new(0, cy, 0), steel, 0.15 * K, { edges = "Y", edgeStyle = steelEdge, name = "Collar" })
			table.insert(glowParts, b:cylY(0.1, 0.68 * K, CFrame.new(0, cy - 0.26, 0), neon, "CollarGlow"))
			b:cylY(0.12, 0.74 * K, CFrame.new(0, cy - 0.37, 0), steelDark, "CollarLip")
			for i = 0, 3 do
				local a = math.pi / 2 * i + math.pi / 4
				b:rivet(Vector3.new(math.cos(a) * 0.34 * K, cy, math.sin(a) * 0.34 * K), 0.13, steelEdge)
			end
			-- segmentos de obsidiana (octágonos chuecos) con anillos de neón entre ellos
			local gap = 0.12
			local segH = (g1 - g0 - 3 * gap) / 4
			local ringYs = {}
			for i = 1, 4 do
				local s1 = g1 - (i - 1) * (segH + gap)
				local y = s1 - segH / 2
				b:cylY(segH, 0.64 * K, CFrame.new(0, y, 0), if i % 2 == 0 then obs else obsGloss, "GripSeg")
				b:cylY(segH - 0.14, 0.68 * K, CFrame.new(0, y, 0), obsEdge, "GripSegBulge")
				if i < 4 then
					table.insert(ringYs, s1 - segH - gap / 2)
				end
			end
			for i, y in ringYs do
				if i == 2 then
					table.insert(glowParts, b:cylY(0.1, 0.62 * K, CFrame.new(0, y, 0), neon, "GripGlow"))
					b:cylY(0.04, 0.7 * K, CFrame.new(0, y + 0.07, 0), steelEdge, "GripRingLip")
					b:cylY(0.04, 0.7 * K, CFrame.new(0, y - 0.07, 0), steelEdge, "GripRingLip")
				else
					b:cylY(0.1, 0.7 * K, CFrame.new(0, y, 0), steel, "GripRing")
				end
			end
			table.insert(glowParts, b:cylY(0.08, 0.64 * K, CFrame.new(0, g0 - 0.05, 0), neon, "GripGlow"))
		end)

		-- ── pomo erizado (1.3x) ─────────────────────────────────
		local floatParts = {}
		local PK = 1.28
		local py = g0 - 0.1 - 0.25 * PK
		local fy = py - 0.72
		b:group("Pommel", function()
			b:bevelBox(Vector3.new(0.86 * PK, 0.5 * PK, 0.86 * PK), CFrame.new(0, py, 0), steelDark, 0.22 * PK, { edges = "Y", edgeStyle = steel, name = "Pommel" })
			b:cylY(0.1, 0.94 * PK, CFrame.new(0, py + 0.22 * PK, 0), steel, "PommelBand")
			table.insert(glowParts, b:cylY(0.07, 0.8 * PK, CFrame.new(0, py + 0.12 * PK, 0), neon, "PommelGlow"))
			-- corona de cristales: 6 grandes hacia afuera/abajo
			for i = 0, 5 do
				local a = math.pi / 3 * i + math.pi / 6
				local d = Vector3.new(math.cos(a), 0, math.sin(a))
				shard(Vector3.new(0, py - 0.04, 0) + d * 0.4 * PK, d + Vector3.new(0, -0.45, 0), 0.78 * PK * 0.92, 0.36 * PK, 3, i % 2 == 0)
				b:rivet(Vector3.new(math.cos(a + math.pi / 6) * 0.44 * PK, py + 0.02, math.sin(a + math.pi / 6) * 0.44 * PK), 0.14, steelEdge)
			end
			b:cylY(0.14, 0.56 * PK, CFrame.new(0, py - 0.3 * PK, 0), steel, "PommelCap")
			-- cristal flotante que gira bajo el pomo (bipirámide)
			for _, p in b:gem(CFrame.new(0, fy, 0), 0.3, crystalLight, neonHot) do
				table.insert(floatParts, p)
			end
		end)
		b:animate(floatParts, CFrame.new(0, fy, 0), { Spin = Vector3.new(0, 1.4, 0), Bob = Vector3.new(0, 0.06, 0), BobSpeed = 0.6 })

		-- ── pulsos ──────────────────────────────────────────────
		b:pulse(crackParts, 0, 0.55, 0.7)
		b:pulse(glowParts, 0, 0.3, 0.7, 0.35)

		-- ── efectos ─────────────────────────────────────────────
		b:group("FX", function()
			B.both(function(s)
				local gemPt = b:fxVolume(Vector3.new(0.2, 0.2, 0.2), CFrame.new(0, headY, s * (CD / 2 + 0.25)), "GemCore")
				local imp = B.Particles.implode(purple, 7)
				imp.Size = B.seq(0, 0.22, 1, 0.04)
				imp.Speed = NumberRange.new(1.2, 1.8)
				b:emitter(b:fxVolume(Vector3.new(1.6, 1.6, 1.6), CFrame.new(0, headY, s * (CD / 2 + 0.25)), "ImplodeShell"), imp, "VoidImplode")
				b:emitter(gemPt, B.Particles.sparkle(P.rgb(220, 160, 255), 2), "GemSparkle")
			end)
			local v = b:fxVolume(Vector3.new(4.6, 2.8, 2.6), CFrame.new(0, headY, 0), "AuraVolume")
			local motes = B.Particles.orb(purple, 7)
			motes.Size = B.seq(0, 0, 0.3, 0.28, 1, 0)
			b:emitter(v, motes, "VoidMotes")
			b:emitter(v, B.Particles.sparkle(P.rgb(200, 120, 255), 6), "VoidSparkle")
			-- brasas moradas que suben de las juntas de los remates
			B.both(function(sx)
				local emb = B.Particles.ember(P.rgb(176, 70, 255), 5)
				emb.Size = B.seq(0, 0.16, 1, 0)
				emb.Speed = NumberRange.new(0.6, 1.6)
				b:emitter(b:fxVolume(Vector3.new(EW, EH * 0.8, ED), CFrame.new(sx * ex, headY, 0), "EmberVolume"), emb, "VoidEmbers")
			end)
			local wisp = B.Particles.smoke(P.rgb(70, 20, 110), 3)
			wisp.LightEmission = 0.4
			wisp.Size = B.seq(0, 0.5, 1, 1.4)
			b:emitter(v, wisp, "VoidWisp")
		end)
		b:light(Vector3.new(0, headY, 0), purple, 2.4, 12, { pulse = { 1.4, 3.2 }, pulseSpeed = 0.7, name = "VoidGlow" })
		b:light(Vector3.new(0, fy, 0), P.rgb(200, 120, 255), 0.6, 4, { pulse = { 0.3, 0.9 }, pulseSpeed = 0.7, name = "PommelGlow" })

		local chips = B.Particles.sparkle(P.rgb(60, 40, 80), 0)
		chips.Texture = B.Textures.FireSparks
		chips.LightEmission = 0
		chips.LightInfluence = 1
		chips.Speed = NumberRange.new(7, 14)
		chips.Size = B.seq(0, 0.35, 1, 0.1)
		chips.Acceleration = Vector3.new(0, -24, 0)
		chips.Lifetime = NumberRange.new(0.4, 0.7)
		local shards = B.Particles.sparkle(purple, 0)
		shards.Speed = NumberRange.new(8, 15)
		shards.Size = B.seq(0, 0.5, 1, 0)
		shards.Acceleration = Vector3.new(0, -16, 0)
		shards.Lifetime = NumberRange.new(0.3, 0.6)
		local burst = B.Particles.implode(purple, 0)
		burst.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
		burst.Speed = NumberRange.new(5, 9)
		local hit = b:impact(CFrame.new(-EX1 - 0.35, headY, 0), purple, { sparks = 24, flash = 7, extra = { shards, chips, burst } })
		hit:FindFirstChild("ImpactExtra1"):SetAttribute("FX_Emit", 22)
		hit:FindFirstChild("ImpactExtra2"):SetAttribute("FX_Emit", 14)
		hit:FindFirstChild("ImpactExtra3"):SetAttribute("FX_Emit", 18)
		b:trail(Vector3.new(0, headY + CH / 2, 0), Vector3.new(0, headY - CH / 2, 0), P.rgb(220, 160, 255), P.rgb(90, 20, 160), { lifetime = 0.26 })
	end,
}
