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
		local headY = A.HeadY + 0.1

		-- ── estilos ─────────────────────────────────────────────
		local purple = P.rgb(160, 60, 255)
		local obs = P.style(P.rgb(26, 22, 34), Enum.Material.Basalt, 0.08)
		local obsEdge = P.style(P.rgb(70, 62, 88), Enum.Material.Basalt, 0.12) -- arista clara
		local obsDeep = P.style(P.rgb(16, 13, 22), Enum.Material.Basalt, 0.04)
		local obsGloss = P.style(P.rgb(44, 38, 58), Enum.Material.Slate, 0.15)
		local steel = P.metal(P.rgb(92, 96, 108), 0.16)
		local steelEdge = P.metal(P.rgb(168, 174, 188), 0.22)
		local steelDark = P.metal(P.rgb(40, 42, 50), 0.1)
		local oldGold = P.metal(P.rgb(196, 146, 60), 0.18)
		local oldGoldPale = P.foil(P.rgb(236, 196, 110), 0.22)
		local crystal = P.crystal(P.rgb(124, 36, 232), 0.1)
		local crystalLight = P.crystal(P.rgb(172, 86, 255), 0.1)
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
			table.insert(glowParts, b:box(Vector3.new(w * 0.3, len * 0.6, w * 0.3), base * CFrame.new(0, len * 0.3, 0) * CFrame.Angles(0, math.pi / 4, 0), neon, "CrystalCore"))
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
		local bandW, BH, BD = 0.24, 2.36, 2.24 -- bandas de acero
		local bx = CW / 2 + bandW / 2 - 0.02
		local EX0, EX1 = bx + bandW / 2 - 0.04, 2.0
		local EW, EH, ED = EX1 - EX0, 2.2, 2.12
		local ex = (EX0 + EX1) / 2

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
				crack(face, { V(-0.36, 0.6), V(-0.55, 0.78), V(-0.62, 1.0) }, 0.07)
				crack(face, { V(0.38, -0.56), V(0.52, -0.78), V(0.7, -0.88) }, 0.07)
			end)

			-- ── bandas de acero remachadas ────────────────────
			B.both(function(sx)
				local x = sx * bx
				b:bevelBox(Vector3.new(bandW, BH, BD), CFrame.new(x, headY, 0), steel, 0.08, { edges = "X", edgeStyle = steelEdge, name = "Band" })
				b:box(Vector3.new(bandW + 0.04, BH - 0.4, BD - 0.4), CFrame.new(x, headY, 0), steelDark, "BandInner")
				for _, sz in { 1, -1 } do
					b:rivetLine(Vector3.new(x, headY + BH / 2 - 0.22, sz * (BD / 2 + 0.01)), Vector3.new(x, headY - BH / 2 + 0.22, sz * (BD / 2 + 0.01)), 2, 0.13, steelEdge)
				end
			end)

			-- ── remates de roca en capas con cristales ────────
			B.both(function(sx)
				local ecf = CFrame.new(sx * ex, headY, 0) * CFrame.Angles(0.03 * sx, 0, math.rad(2.5) * sx)
				b:bevelBox(Vector3.new(EW, EH, ED), ecf, obs, 0.22, { edgeStyle = obsEdge, name = "Rock" })
				-- losas que sobresalen (rompen la silueta): arriba-afuera y abajo-adentro
				b:bevelBox(Vector3.new(EW * 0.62, 0.62, ED * 0.78), CFrame.new(sx * (ex + 0.12), headY + EH / 2 - 0.12, 0.08) * CFrame.Angles(0.06, 0.1 * sx, math.rad(-9) * sx), obsGloss, 0.12, { edges = "Z", edgeStyle = obsEdge, name = "RockSlab" })
				b:bevelBox(Vector3.new(EW * 0.7, 0.55, ED * 0.85), CFrame.new(sx * (ex - 0.04), headY - EH / 2 + 0.1, -0.05) * CFrame.Angles(-0.05, 0, math.rad(6) * sx), obs, 0.12, { edges = "Z", edgeStyle = obsEdge, name = "RockSlab" })
				-- losa lateral en cada cara (capa) + grietas
				for _, sz in { 1, -1 } do
					local f = B.faceZ(sz, headY, ED / 2 + 0.01, sx * ex)
					local k = sx * sz
					crack(f, { V(-0.48 * k, 0.8), V(-0.2 * k, 0.42), V(0.08 * k, -0.06), V(0.0, -0.5), V(0.3 * k, -0.86) }, 0.075)
					crack(f, { V(0.08 * k, -0.06), V(0.42 * k, 0.16) }, 0.055)
				end
				-- cara de golpe: placa de acero negro con runa de neón y gema
				local fx = sx * (EX1 + 0.04)
				b:bevelBox(Vector3.new(0.14, EH - 0.36, ED - 0.36), CFrame.new(fx, headY, 0), steelDark, 0.07, { edges = "X", edgeStyle = steel, name = "StrikePlate" })
				local sf = B.faceX(sx, EX1 + 0.11, headY)
				local rr = 0.58
				local rune = { sf:PointToWorldSpace(Vector3.new(0, rr, 0)), sf:PointToWorldSpace(Vector3.new(rr, 0, 0)), sf:PointToWorldSpace(Vector3.new(0, -rr, 0)), sf:PointToWorldSpace(Vector3.new(-rr, 0, 0)) }
				for _, p in b:polyline(rune, 0.08, 0.05, neon, sf.LookVector, true, "Rune") do
					table.insert(crackParts, p)
				end
				for _, p in b:gem(sf * CFrame.new(0, 0, 0.04), 0.26, crystalLight, neonHot) do
					table.insert(glowParts, p)
				end
				-- cristales: arriba (grande), abajo, esquinas exteriores y uno que sale por el frente
				shard(Vector3.new(sx * (ex + 0.2), headY + EH / 2 + 0.12, 0.2), Vector3.new(sx * 0.35, 1, 0.15), 0.9, 0.42, 4, true)
				shard(Vector3.new(sx * (ex - 0.22), headY + EH / 2 + 0.05, -0.45), Vector3.new(sx * 0.1, 1, -0.45), 0.55, 0.28, 3)
				shard(Vector3.new(sx * (EX1 - 0.1), headY - EH / 2 + 0.2, 0.55), Vector3.new(sx * 0.8, -0.9, 0.35), 0.62, 0.32, 3)
				shard(Vector3.new(sx * (EX1 - 0.12), headY + 0.25, -ED / 2 + 0.25), Vector3.new(sx, 0.2, -0.75), 0.6, 0.3, 3, true)
				shard(Vector3.new(sx * (EX1 - 0.15), headY - 0.35, ED / 2 - 0.2), Vector3.new(sx, -0.1, 0.8), 0.5, 0.26, 3)
			end)

			-- cristales sobre el bloque central
			shard(Vector3.new(0.18, headY + CH / 2, -0.25), Vector3.new(0.15, 1, -0.2), 0.72, 0.34, 4, true)
		end)

		-- ── mango ───────────────────────────────────────────────
		b:group("Shaft", function()
			local top = headY - CH / 2
			local bottom = A.ShaftBottom
			b:cylY(top - bottom, 0.38, CFrame.new(0, (top + bottom) / 2, 0), obsDeep, "ShaftCore")
			-- collar de acero con anillo de neón
			local cy = top - 0.2
			b:bevelBox(Vector3.new(0.72, 0.36, 0.72), CFrame.new(0, cy, 0), steel, 0.15, { edges = "Y", edgeStyle = steelEdge, name = "Collar" })
			table.insert(glowParts, b:cylY(0.1, 0.6, CFrame.new(0, cy - 0.26, 0), neon, "CollarGlow"))
			b:cylY(0.12, 0.66, CFrame.new(0, cy - 0.37, 0), steelDark, "CollarLip")
			for i = 0, 3 do
				local a = math.pi / 2 * i + math.pi / 4
				b:rivet(Vector3.new(math.cos(a) * 0.3, cy, math.sin(a) * 0.3), 0.12, steelEdge)
			end
			-- segmentos de obsidiana (octágonos chuecos) con anillos de neón entre ellos
			local segs = { { 1.62, 1.12 }, { 1.0, 0.42 }, { 0.3, -0.3 }, { -0.42, -1.05 } }
			for i, sgm in segs do
				local y = (sgm[1] + sgm[2]) / 2
				local h = sgm[1] - sgm[2]
				b:cylY(h, 0.56, CFrame.new(0, y, 0), if i % 2 == 0 then obs else obsGloss, "GripSeg")
				b:cylY(h - 0.14, 0.6, CFrame.new(0, y, 0), obsEdge, "GripSegBulge")
			end
			for i, y in { 1.06, 0.36, -0.36 } do
				if i == 2 then
					table.insert(glowParts, b:cylY(0.1, 0.54, CFrame.new(0, y, 0), neon, "GripGlow"))
					b:cylY(0.04, 0.62, CFrame.new(0, y + 0.07, 0), steelEdge, "GripRingLip")
					b:cylY(0.04, 0.62, CFrame.new(0, y - 0.07, 0), steelEdge, "GripRingLip")
				else
					b:cylY(0.1, 0.6, CFrame.new(0, y, 0), steel, "GripRing")
				end
			end
			table.insert(glowParts, b:cylY(0.08, 0.56, CFrame.new(0, -1.11, 0), neon, "GripGlow"))
		end)

		-- ── pomo erizado ────────────────────────────────────────
		local floatParts = {}
		local py = A.PommelY - 0.08
		b:group("Pommel", function()
			b:bevelBox(Vector3.new(0.78, 0.46, 0.78), CFrame.new(0, py, 0), steelDark, 0.2, { edges = "Y", edgeStyle = steel, name = "Pommel" })
			b:cylY(0.08, 0.84, CFrame.new(0, py + 0.2, 0), steel, "PommelBand")
			for i = 0, 3 do
				local a = math.pi / 2 * i + math.pi / 4
				local d = Vector3.new(math.cos(a), 0, math.sin(a))
				shard(Vector3.new(0, py - 0.05, 0) + d * 0.36, d + Vector3.new(0, -0.5, 0), 0.56, 0.26, 3, i % 2 == 0, true)
				b:rivet(Vector3.new(math.cos(a - math.pi / 4) * 0.4, py + 0.02, math.sin(a - math.pi / 4) * 0.4), 0.12, steelEdge)
			end
			b:cylY(0.12, 0.52, CFrame.new(0, py - 0.28, 0), steel, "PommelCap")
			-- cristal flotante que gira bajo el pomo (bipirámide)
			local fy = py - 0.66
			for _, p in b:gem(CFrame.new(0, fy, 0), 0.26, crystalLight, neonHot) do
				table.insert(floatParts, p)
			end
		end)
		b:animate(floatParts, CFrame.new(0, py - 0.66, 0), { Spin = Vector3.new(0, 1.4, 0), Bob = Vector3.new(0, 0.06, 0), BobSpeed = 0.6 })

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
			b:emitter(v, B.Particles.sparkle(P.rgb(200, 120, 255), 8), "VoidSparkle")
			local wisp = B.Particles.smoke(P.rgb(70, 20, 110), 3)
			wisp.LightEmission = 0.4
			wisp.Size = B.seq(0, 0.5, 1, 1.4)
			b:emitter(v, wisp, "VoidWisp")
		end)
		b:light(Vector3.new(0, headY, 0), purple, 1.6, 10, { pulse = { 0.9, 2.2 }, pulseSpeed = 0.7, name = "VoidGlow" })
		b:light(Vector3.new(0, py - 0.66, 0), P.rgb(200, 120, 255), 0.6, 4, { pulse = { 0.3, 0.9 }, pulseSpeed = 0.7, name = "PommelGlow" })

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
