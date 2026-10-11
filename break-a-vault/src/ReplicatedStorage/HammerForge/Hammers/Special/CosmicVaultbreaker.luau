-- Cosmic Vaultbreaker (Special) — un pedazo de universo encerrado en oro.
-- Cabeza de "metal estelar" morado-marino salpicado de estrellitas, con aristas de oro, dos correas de oro
-- remachadas y marcos dorados en los remates. Al centro de ambas caras, una VENTANA DE GALAXIA: bisel de oro,
-- fondo de espacio profundo y una espiral de brazos de neón (blanco-rosa → morado → azul) que gira, con un
-- núcleo brillante y cristal encima. En los remates, paneles con destellos de estrella que titilan.
-- Arriba del remate izquierdo, un DOMO de cristal con nebulosa adentro; en la cara +X, un planeta engastado en
-- un anillo de oro. Alrededor, un gran anillo orbital dorado inclinado y tres planetitas que lo recorren.
-- Mango de cristal cósmico (núcleo de nebulosa + estrellas), collar de oro escalonado, banda y aro con
-- gemas azules y pomo de oro octagonal.
-- FX: planetas orbitando, destellos de estrella, partículas que se succionan hacia la galaxia, luz morada.
return {
	Id = "CosmicVaultbreaker",
	DisplayName = "Cosmic Vaultbreaker",
	Rarity = "Special",
	Order = 8,
	Theme = "Starfall Observatory",
	Build = function(b, P, B)
		local A = B.Anatomy
		local headY = A.HeadY + 0.1
		local TAU = math.pi * 2
		local rnd = B.rng(2024)

		-- ── estilos ─────────────────────────────────────────────
		local cosmos = P.metal(P.rgb(40, 24, 86), 0.12) -- metal estelar
		local cosmosDeep = P.metal(P.rgb(18, 12, 44), 0.08)
		local violetEdge = P.metal(P.rgb(104, 72, 190), 0.18)
		local space = P.metal(P.rgb(8, 6, 22), 0.05)
		local gold = P.with(P.Gold, { Color = P.rgb(255, 188, 56) })
		local goldDeep = P.metal(P.rgb(232, 158, 36), 0.22)
		local goldPale = P.foil(P.rgb(255, 226, 150), 0.26)
		local pinkC = P.rgb(255, 110, 220)
		local purpleC = P.rgb(160, 80, 255)
		local blueC = P.rgb(80, 120, 255)
		local starC = P.rgb(235, 225, 255)
		local goldGlowC = P.rgb(255, 200, 90)
		local star = P.neon(starC)
		local glassV = P.glass(P.rgb(200, 190, 255), 0.8, 0.15)
		local glassDome = P.glass(P.rgb(120, 90, 255), 0.42)

		-- ── medidas ────────────────────────────────────────────
		local CW, CH, CD = 1.5, 2.02, 1.92
		local EX0, EX1, EH, ED = 0.9, 1.76, 1.86, 1.8
		local strapX = 0.81

		-- ── helpers ────────────────────────────────────────────
		local twinkles = {}
		-- estrellitas sueltas sobre una cara (plano XY local), evitando un círculo central
		local function specks(face: CFrame, w: number, h: number, n: number, avoid: number?)
			local placed = 0
			local guard = 0
			while placed < n and guard < 200 do
				guard += 1
				local x, y = rnd(-w / 2, w / 2), rnd(-h / 2, h / 2)
				if not avoid or (x * x + y * y) > avoid * avoid then
					local s = rnd(0.035, 0.065)
					local p = b:box(Vector3.new(s, s, 0.03), face * CFrame.new(x, y, 0.012) * CFrame.Angles(0, 0, math.rad(45)), star, "StarSpeck")
					if placed % 3 == 0 then
						table.insert(twinkles, p)
					end
					placed += 1
				end
			end
		end
		-- destello de estrella de 4 puntas (cruz de barras finas + núcleo)
		local function sparkleStar(face: CFrame, size: number, st)
			local out = {}
			table.insert(out, b:box(Vector3.new(size, size * 0.12, 0.04), face, st, "StarRay"))
			table.insert(out, b:box(Vector3.new(size * 0.12, size, 0.04), face, st, "StarRay"))
			table.insert(out, b:box(Vector3.new(size * 0.45, size * 0.08, 0.035), face * CFrame.Angles(0, 0, math.rad(45)), st, "StarRay"))
			table.insert(out, b:box(Vector3.new(size * 0.45, size * 0.08, 0.035), face * CFrame.Angles(0, 0, math.rad(-45)), st, "StarRay"))
			table.insert(out, b:box(Vector3.new(size * 0.2, size * 0.2, 0.05), face * CFrame.Angles(0, 0, math.rad(45)), P.neon(P.rgb(255, 255, 255)), "StarCore"))
			return out
		end

		b:group("Head", function()
			-- ── bloque central con aristas de oro ─────────────
			b:bevelBox(Vector3.new(CW, CH, CD), CFrame.new(0, headY, 0), cosmos, 0.12, { edges = "all", edgeStyle = gold, name = "Core" })
			-- ── remates con aristas violetas y marco de oro ───
			B.both(function(sx)
				local ex = sx * (EX0 + EX1) / 2
				b:bevelBox(Vector3.new(EX1 - EX0, EH, ED), CFrame.new(ex, headY, 0), cosmos, 0.18, { edges = "X", edgeStyle = violetEdge, name = "End" })
				b:bevelBox(Vector3.new(0.16, EH + 0.12, ED + 0.12), CFrame.new(sx * (EX1 - 0.1), headY, 0), gold, 0.22, { edges = "X", edgeStyle = goldPale, name = "EndFrame" })
				-- correa de oro entre centro y remate
				b:bevelBox(Vector3.new(0.24, CH + 0.16, CD + 0.16), CFrame.new(sx * strapX, headY, 0), gold, 0.14, { edges = "X", edgeStyle = goldPale, name = "Strap" })
				b:box(Vector3.new(0.08, CH + 0.2, CD + 0.2), CFrame.new(sx * strapX, headY, 0), goldDeep, "StrapCenter")
				for _, sz in { -1, 1 } do
					b:rivetLine(Vector3.new(sx * strapX, headY - 0.7, sz * (CD / 2 + 0.1)), Vector3.new(sx * strapX, headY + 0.7, sz * (CD / 2 + 0.1)), 3, 0.1, goldPale)
					-- panel del remate: espacio profundo con destello que titila
					local f = B.faceZ(sz, headY, ED / 2, ex)
					b:box(Vector3.new(0.56, 1.24, 0.05), f * CFrame.new(0, 0, 0.02), goldDeep, "EndPanelRim")
					b:box(Vector3.new(0.48, 1.16, 0.06), f * CFrame.new(0, 0, 0.03), space, "EndPanel")
					specks(f * CFrame.new(0, 0, 0.055), 0.42, 1.08, 3, 0.22)
					local st = sparkleStar(f * CFrame.new(0, 0.12, 0.08), 0.42, P.neon(P.rgb(220, 200, 255)))
					b:pulse(st, 0, 0.75, 0.8, if sx * sz > 0 then 0 else 0.6)
				end
				-- estrellitas arriba de los remates
				specks(CFrame.new(ex, headY + EH / 2, 0) * CFrame.Angles(-math.pi / 2, 0, 0), 0.6, 1.5, 3)
			end)

			-- ── ventanas de galaxia (±Z) ──────────────────────
			B.both(function(s)
				local f = B.faceZ(s, headY + 0.02, CD / 2)
				specks(f, CW - 0.3, CH - 0.3, 4, 0.8)
				b:cylZ(0.12, 1.5, f * CFrame.new(0, 0, 0.05), gold, "GalaxyBezel")
				b:cylZ(0.1, 1.62, f * CFrame.new(0, 0, 0.02), goldDeep, "GalaxyBezelBack")
				for i = 0, 7 do
					local a = TAU * i / 8 + TAU / 16
					b:rivet(f:PointToWorldSpace(Vector3.new(math.cos(a) * 0.68, math.sin(a) * 0.68, 0.11)), 0.08, goldPale)
				end
				b:cylZ(0.06, 1.26, f * CFrame.new(0, 0, 0.1), space, "GalaxySpace")
				-- nebulosa de fondo (discos oscuros morado/magenta: el neón queda solo en los brazos)
				b:cylZ(0.03, 1.1, f * CFrame.new(0, 0, 0.125), P.metal(P.rgb(34, 16, 70), 0.1), "Nebula")
				b:cylZ(0.03, 0.62, f * CFrame.new(0, 0, 0.13), P.metal(P.rgb(64, 20, 78), 0.1), "NebulaInner")
				-- brazos espirales (giran)
				local gp = f * CFrame.new(0, 0, 0.15)
				local arms = {}
				for arm = 0, 1 do
					local prev
					for i = 0, 8 do
						local r = 0.06 + i * 0.062
						local th = arm * math.pi + i * 0.62 * s
						local pt = Vector3.new(math.cos(th) * r, math.sin(th) * r, 0)
						local t = i / 8
						local c = if t < 0.3 then P.mix(P.rgb(255, 210, 245), pinkC, t / 0.3) elseif t < 0.65 then P.darken(P.mix(pinkC, purpleC, (t - 0.3) / 0.35), 0.25) else P.darken(P.mix(purpleC, blueC, (t - 0.65) / 0.35), 0.28)
						if prev then
							local seg = b:line(gp:PointToWorldSpace(prev), gp:PointToWorldSpace(pt), 0.15 - t * 0.08, 0.03, P.neon(c), gp.ZVector, "GalaxyArm")
							if seg then
								table.insert(arms, seg)
							end
							-- polvo estelar al lado del brazo
							if i % 2 == 0 or i == 7 then
								local dust = pt * 1.12 + Vector3.new(0, 0, 0.01)
								table.insert(arms, b:box(Vector3.new(0.035, 0.035, 0.03), gp * CFrame.new(dust), star, "GalaxyDust"))
							end
						end
						prev = pt
					end
				end
				b:animate(arms, gp, { Spin = Vector3.new(0, 0, 0.7 * s) })
				local core = b:ball(0.22, f * CFrame.new(0, 0, 0.16), P.neon(P.rgb(255, 225, 248)), "GalaxyCore")
				local halo = b:cylZ(0.03, 0.4, f * CFrame.new(0, 0, 0.14), P.neon(P.darken(pinkC, 0.2), 0.15), "GalaxyHalo")
				b:pulse({ core }, 0, 0.3, 1.2)
				b:pulse({ halo }, 0, 0.6, 1.2, 0.2)
			end)

			-- ── arriba/abajo del centro: placa de oro con gema ─
			for _, sy in { -1, 1 } do
				b:bevelBox(Vector3.new(0.9, 0.08, 1.1), CFrame.new(0, headY + sy * (CH / 2 + 0.03), 0), gold, 0.04, { edges = "Y", edgeStyle = goldPale, name = "TopPlate" })
				b:ball(0.2, Vector3.new(0, headY + sy * (CH / 2 + 0.08), 0), P.neon(purpleC), "TopGem")
			end

			-- ── cara de golpe -X: tapa octagonal de oro con nebulosa ─
			local lf = B.faceX(-1, EX1, headY)
			b:bevelBox(Vector3.new(ED - 0.16, EH - 0.16, 0.12), lf * CFrame.new(0, 0, 0.05), goldDeep, 0.42, { edges = "Z", edgeStyle = gold, name = "StrikeCap" })
			b:bevelBox(Vector3.new(ED - 0.5, EH - 0.5, 0.06), lf * CFrame.new(0, 0, 0.12), cosmosDeep, 0.3, { edges = "Z", edgeStyle = goldPale, name = "StrikeInset" })
			local neb = b:cylZ(0.04, 0.78, lf * CFrame.new(0, 0, 0.16), P.neon(P.darken(purpleC, 0.2)), "StrikeNebula")
			b:cylZ(0.04, 0.46, lf * CFrame.new(0, 0, 0.175), P.neon(pinkC), "StrikeNebulaCore")
			b:pulse({ neb }, 0, 0.35, 1.0)
			sparkleStar(lf * CFrame.new(0, 0, 0.21), 0.62, star)
			b:cylZ(0.03, 0.84, lf * CFrame.new(0, 0, 0.23), glassV, "StrikeGlass")
			specks(lf * CFrame.new(0, 0, 0.15), 1.1, 1.1, 5, 0.46)

			-- ── domo de cristal con nebulosa (arriba del remate izquierdo) ─
			local dx, dy = -(EX0 + EX1) / 2 - 0.08, headY + EH / 2
			b:cylY(0.14, 0.96, CFrame.new(dx, dy + 0.06, 0), gold, "DomeCollar")
			b:cylY(0.06, 1.04, CFrame.new(dx, dy + 0.14, 0), goldPale, "DomeLip")
			local domeCore = b:ball(0.5, Vector3.new(dx, dy + 0.42, 0), P.neon(P.darken(purpleC, 0.1)), "DomeNebula")
			b:ball(0.24, Vector3.new(dx + 0.08, dy + 0.48, 0.05), P.neon(pinkC), "DomeStar")
			b:ball(0.84, Vector3.new(dx, dy + 0.4, 0), glassDome, "Dome")
			b:pulse({ domeCore }, 0, 0.4, 0.9, 0.3)
			for i = 0, 3 do
				local a = TAU * i / 4 + 0.5
				b:box(Vector3.new(0.05, 0.05, 0.05), CFrame.new(dx + math.cos(a) * 0.3, dy + 0.5 + (i % 2) * 0.12, math.sin(a) * 0.3), star, "DomeSpeck")
			end

			-- ── cara +X: planeta engastado en anillo de oro ───
			local rf = B.faceX(1, EX1, headY)
			b:bevelBox(Vector3.new(ED - 0.16, EH - 0.16, 0.1), rf * CFrame.new(0, 0, 0.04), goldDeep, 0.42, { edges = "Z", edgeStyle = gold, name = "EndCap" })
			b:cylZ(0.14, 1.12, rf * CFrame.new(0, 0, 0.12), gold, "PlanetSeat")
			local planet = b:ball(0.92, rf * CFrame.new(0, 0, 0.3), P.neon(P.darken(blueC, 0.35)), "PlanetCore")
			b:ball(1.0, rf * CFrame.new(0, 0, 0.3), glassDome, "Planet")
			b:pulse({ planet }, 0, 0.3, 0.7)
			b:ring(rf * CFrame.new(0, 0, 0.3) * CFrame.Angles(math.rad(70), 0, math.rad(25)), 0.66, 0.06, 18, goldPale, "PlanetRing", 0.03)
		end)

		-- ── anillo orbital dorado + planetitas ──────────────────
		b:group("Orbit", function()
			local ocf = CFrame.new(0, headY, 0) * CFrame.Angles(math.rad(13), 0, math.rad(-11))
			local R = 2.3
			local ring = b:ring(ocf, R, 0.06, 30, P.neon(goldGlowC), "OrbitRing", 0.035)
			b:pulse(ring, 0, 0.35, 0.6)
			local planets = {}
			local function addAll(src)
				for _, p in src do
					table.insert(planets, p)
				end
			end
			local function at(a)
				return ocf:PointToWorldSpace(Vector3.new(math.cos(a) * R, 0, math.sin(a) * R))
			end
			-- planeta morado grande
			local p1 = at(0.7)
			addAll({ b:ball(0.3, p1, P.neon(P.darken(purpleC, 0.25)), "PlanetBigCore"), b:ball(0.4, p1, glassDome, "PlanetBig") })
			-- planeta con anillo
			local p2 = at(2.75)
			addAll({ b:ball(0.28, p2, P.neon(P.darken(pinkC, 0.3)), "PlanetRingedCore") })
			addAll(b:ring(CFrame.new(p2) * CFrame.Angles(math.rad(20), 0, math.rad(30)), 0.24, 0.04, 10, goldPale, "PlanetRingedBand", 0.02))
			-- planetita azul
			local p3 = at(4.6)
			addAll({ b:ball(0.22, p3, P.neon(blueC), "PlanetSmall") })
			b:animate(planets, ocf, { Spin = Vector3.new(0, 0.55, 0) })
		end)

		-- ── mango ───────────────────────────────────────────────
		b:group("Shaft", function()
			local top = headY - CH / 2
			-- collar escalonado de oro
			b:bevelBox(Vector3.new(0.98, 0.14, 0.98), CFrame.new(0, top - 0.07, 0), gold, 0.28, { edges = "Y", edgeStyle = goldPale, name = "CollarFlange" })
			b:cylY(0.3, 0.76, CFrame.new(0, top - 0.29, 0), goldDeep, "Collar")
			b:cylY(0.06, 0.82, CFrame.new(0, top - 0.17, 0), goldPale, "CollarLip")
			b:cylY(0.1, 0.66, CFrame.new(0, top - 0.48, 0), gold, "CollarLow")
			for i = 0, 3 do
				local a = TAU * i / 4 + TAU / 8
				b:ball(0.12, Vector3.new(math.cos(a) * 0.38, top - 0.29, math.sin(a) * 0.38), P.neon(purpleC), "CollarGem")
			end
			-- eje de cristal cósmico: núcleo de nebulosa + cáscara + estrellas
			local s0, s1 = A.ShaftBottom, top - 0.5
			local mid, len = (s0 + s1) / 2, s1 - s0
			local core = b:cylY(len, 0.34, CFrame.new(0, mid, 0), P.neon(P.darken(purpleC, 0.45)), "ShaftNebula")
			b:cylY(len, 0.5, CFrame.new(0, mid, 0), P.glass(P.rgb(60, 30, 130), 0.3, 0.3), "ShaftGlass")
			b:pulse({ core }, 0, 0.25, 0.8)
			for i = 0, 11 do
				local a = i * 2.4
				local y = s0 + 0.15 + (len - 0.3) * (i / 11)
				b:box(Vector3.new(0.04, 0.04, 0.04), CFrame.new(math.cos(a) * 0.255, y, math.sin(a) * 0.255) * CFrame.Angles(0.6, a, 0.6), star, "ShaftStar")
			end
			-- banda de oro media y aro bajo con gemas azules
			b:cylY(0.18, 0.62, CFrame.new(0, 0.55, 0), gold, "MidBand")
			b:cylY(0.05, 0.66, CFrame.new(0, 0.66, 0), goldPale, "MidBandLip")
			b:cylY(0.05, 0.66, CFrame.new(0, 0.44, 0), goldPale, "MidBandLip")
			b:cylY(0.2, 0.66, CFrame.new(0, -1.02, 0), gold, "LowBand")
			for _, sz in { -1, 1 } do
				b:ball(0.14, Vector3.new(0, -1.02, sz * 0.33), P.neon(P.rgb(90, 200, 255)), "LowGem")
				b:ball(0.12, Vector3.new(0, 0.55, sz * 0.31), P.neon(purpleC), "MidGem")
			end
		end)

		-- ── pomo ────────────────────────────────────────────────
		b:group("Pommel", function()
			local y = A.PommelY - 0.06
			b:bevelBox(Vector3.new(0.86, 0.34, 0.86), CFrame.new(0, y, 0), gold, 0.24, { edges = "Y", edgeStyle = goldPale, name = "Pommel" })
			b:bevelBox(Vector3.new(0.72, 0.14, 0.72), CFrame.new(0, y - 0.23, 0), cosmos, 0.2, { edges = "Y", edgeStyle = goldDeep, name = "PommelCap" })
			b:cylY(0.06, 0.4, CFrame.new(0, y - 0.31, 0), P.neon(purpleC), "PommelNebula")
			for i = 0, 3 do
				local a = TAU * i / 4 + TAU / 8
				b:ball(0.13, Vector3.new(math.cos(a) * 0.43, y, math.sin(a) * 0.43), P.neon(P.rgb(90, 200, 255)), "PommelGem")
			end
		end)

		b:pulse(twinkles, 0, 0.85, 1.3)

		-- ── efectos ─────────────────────────────────────────────
		b:group("FX", function()
			local v = b:fxVolume(Vector3.new(4.6, 2.8, 2.8), CFrame.new(0, headY, 0), "CosmosVolume")
			local st = B.Particles.sparkle(starC, 12)
			st.Size = B.seq(0, 0, 0.2, 0.22, 1, 0)
			b:emitter(v, st, "StarSparkle")
			b:emitter(v, B.Particles.orb(purpleC, 5), "NebulaOrbs")
			B.both(function(s)
				local iv = b:fxVolume(Vector3.new(1.6, 1.6, 0.1), CFrame.new(0, headY, s * (CD / 2 + 0.2)), "GalaxyPull")
				local imp = B.Particles.implode(pinkC, 5)
				imp.Size = B.seq(0, 0.18, 1, 0.03)
				b:emitter(iv, imp, "GalaxyImplode")
			end)
		end)
		b:light(Vector3.new(0, headY, 0), purpleC, 1.3, 10, { pulse = { 0.8, 1.7 }, pulseSpeed = 0.8, name = "CosmosLight" })
		b:light(Vector3.new(-(EX0 + EX1) / 2, headY + EH / 2 + 0.45, 0), P.rgb(190, 150, 255), 0.5, 4, { pulse = { 0.3, 0.7 }, pulseSpeed = 0.9, name = "DomeLight" })

		-- impacto: chispas doradas + estallido de estrellas + implosión de nebulosa
		local burst = B.Particles.sparkle(starC, 0)
		burst.Speed = NumberRange.new(7, 13)
		burst.Size = B.seq(0, 0.45, 1, 0)
		local neb = B.Particles.orb(purpleC, 0)
		neb.Speed = NumberRange.new(3, 6)
		neb.Size = B.seq(0, 0.4, 0.4, 0.8, 1, 0)
		neb.Lifetime = NumberRange.new(0.4, 0.8)
		local pull = B.Particles.implode(pinkC, 0)
		local hit = b:impact(CFrame.new(-EX1 - 0.4, headY, 0), P.rgb(190, 120, 255), { sparks = 24, flash = 8, extra = { burst, neb, pull } })
		hit:FindFirstChild("ImpactExtra1"):SetAttribute("FX_Emit", 24)
		hit:FindFirstChild("ImpactExtra2"):SetAttribute("FX_Emit", 8)
		hit:FindFirstChild("ImpactExtra3"):SetAttribute("FX_Emit", 14)
		b:trail(Vector3.new(0, headY + CH / 2 + 0.25, 0), Vector3.new(0, headY - CH / 2 - 0.25, 0), P.rgb(255, 210, 255), P.rgb(110, 70, 255), { lifetime = 0.26 })
	end,
}
