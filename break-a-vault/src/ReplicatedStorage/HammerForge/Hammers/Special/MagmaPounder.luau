-- Magma Pounder (Special) — dos pedazos de volcán amarrados con un fleje de hierro. Cada extremo de la
-- cabeza es un CÚMULO DE ROCA hecho de trozos biselados de basalto y roca de lava de tamaños distintos
-- (aparejo irregular, cada trozo chueco y con arista clara) sobre un NÚCLEO DE MAGMA de neón hundido que
-- brilla por las juntas anchas. En las caras de golpe, el bloque central está hundido y deja ver una bolsa de magma
-- al rojo vivo. En medio, un fleje ancho de hierro forjado con rebordes, remaches chicos en las orillas
-- y dos remaches grandes de cobre; costuras de magma donde el hierro toca la roca. Del fondo cuelgan
-- gotas de roca fundida y alrededor flotan esquirlas de roca con el corazón encendido.
-- Mango forrado de trozos de roca con magma entre las juntas, collar de hierro y pomo de roca rajada.
-- FX: brasas que suben, lenguas de fuego chicas, humo, goteo de magma, luz naranja que titila.
return {
	Id = "MagmaPounder",
	DisplayName = "Magma Pounder",
	Rarity = "Special",
	Order = 3,
	Theme = "Magma Forge",
	Build = function(b, P, B)
		local A = B.Anatomy
		local headY = A.HeadY + 0.1
		local H, D = 2.4, 2.26 -- cúmulos de roca
		local HB, DB = 2.12, 2.04 -- fleje
		local rnd = B.rng(4417)

		-- ── estilos ─────────────────────────────────────────────
		local fireC = P.rgb(255, 110, 20)
		local rockA = P.style(P.rgb(46, 36, 34), Enum.Material.Basalt, 0)
		local rockB = P.style(P.rgb(78, 60, 52), Enum.Material.Basalt, 0)
		local rockC = P.style(P.rgb(36, 30, 30), Enum.Material.Slate, 0)
		local rockLava = P.style(P.rgb(86, 38, 24), Enum.Material.CrackedLava, 0)
		local rockEdge = P.style(P.rgb(112, 88, 74), Enum.Material.Basalt, 0) -- arista clara
		local magma = P.neon(P.rgb(255, 96, 8))
		local magmaDeep = P.neon(P.rgb(255, 84, 4))
		local magmaHot = P.neon(P.rgb(255, 176, 40))
		local magmaWhite = P.neon(P.rgb(255, 230, 150))
		local iron = P.metal(P.rgb(54, 50, 52), 0.1)
		local ironAlt = P.metal(P.rgb(40, 38, 40), 0.08)
		local ironEdge = P.metal(P.rgb(138, 124, 112), 0.18)
		local copper = P.metal(P.rgb(176, 70, 44), 0.2)
		local copperHot = P.metal(P.rgb(226, 120, 70), 0.3)
		local rivetSt = P.metal(P.rgb(150, 136, 124), 0.2)

		local glow = {}
		local function G(p)
			table.insert(glow, p)
			return p
		end

		-- bloque de roca con aristas "despostilladas": 3 cajas cruzadas (deja muescas en las aristas,
		-- por donde asoma el magma del núcleo)
		local function rock(cf: CFrame, size: Vector3, st, c: number?)
			local k = c or math.min(size.X, size.Y, size.Z) * 0.13
			local out = {}
			table.insert(out, b:box(Vector3.new(size.X, size.Y - 2 * k, size.Z - 2 * k), cf, st, "Rock"))
			table.insert(out, b:box(Vector3.new(size.X - 2 * k, size.Y, size.Z - 2 * k), cf, st, "Rock"))
			table.insert(out, b:box(Vector3.new(size.X - 2 * k, size.Y - 2 * k, size.Z), cf, st, "Rock"))
			return out
		end
		local function pick()
			local r = rnd()
			if r < 0.22 then
				return rockLava
			elseif r < 0.55 then
				return rockB
			elseif r < 0.8 then
				return rockA
			end
			return rockC
		end

		local bandX = 0.72
		local X1 = 2.04
		local yTop, yBot = headY + H / 2, headY - H / 2

		b:group("Head", function()
			-- ── cúmulos de roca: trozos irregulares sobre un núcleo de magma ──
			B.both(function(s)
				local xa, xb = bandX + 0.02, X1
				local L = xb - xa
				-- núcleo de magma en dos capas: naranja (se ve en las juntas) y amarillo caliente al fondo
				G(b:box(Vector3.new(L - 0.5, H - 0.5, D - 0.5), CFrame.new(s * (xa + xb) / 2, headY, 0), magmaDeep, "MagmaCore"))
				local gap = 0.095 -- juntas anchas y hundidas
				-- filas con alturas distintas (aparejo irregular)
				local yb = { -H / 2, -H / 2 + H * rnd(0.3, 0.38), -H / 2 + H * rnd(0.62, 0.7), H / 2 }
				for j = 1, 3 do
					local zsplit = rnd(-0.18, 0.18)
					local zb = { -D / 2, zsplit, D / 2 }
					for k = 1, 2 do
						-- 1, 2 o 3 trozos a lo largo de X (tamaños variados)
						local r = rnd()
						local xbnd = if r < 0.25 then { 0, 1 } elseif r < 0.8 then { 0, rnd(0.36, 0.64), 1 } else { 0, rnd(0.26, 0.38), rnd(0.6, 0.72), 1 }
						for i = 1, #xbnd - 1 do
							local u0, u1 = xa + L * xbnd[i], xa + L * xbnd[i + 1]
							local y0, y1 = yb[j], yb[j + 1]
							local z0, z1 = zb[k], zb[k + 1]
							local outer = i == #xbnd - 1
							local size = Vector3.new(u1 - u0 - gap, y1 - y0 - gap, z1 - z0 - gap) * Vector3.new(rnd(0.98, 1.1), rnd(0.98, 1.1), rnd(0.98, 1.08))
							-- empuje hacia afuera (relieve irregular en la silueta)
							local push = Vector3.new(
								if outer then rnd(0.0, 0.1) else 0,
								if j == 3 then rnd(0.0, 0.06) elseif j == 1 then -rnd(0.0, 0.05) else 0,
								if k == 2 then rnd(0.01, 0.08) else -rnd(0.01, 0.08)
							)
							local st = pick()
							if outer and j == 2 then
								-- bolsa de magma en la cara de golpe: los trozos del centro se hunden
								push = Vector3.new(-0.18, 0, push.Z * 0.5)
								st = rockLava
							end
							local ctr = Vector3.new(s * ((u0 + u1) / 2 + push.X), headY + (y0 + y1) / 2 + push.Y, (z0 + z1) / 2 + push.Z)
							local cf = CFrame.new(ctr) * CFrame.Angles(rnd(-0.1, 0.1), rnd(-0.1, 0.1), rnd(-0.12, 0.12))
							-- trozo biselado (chaflanes vistos desde las caras ±Z, con arista más clara)
							b:bevelBox(size, cf, st, math.min(size.X, size.Y) * rnd(0.16, 0.24), { edges = "Z", edgeStyle = if st == rockLava then rockB else rockEdge, name = "Chunk" })
						end
					end
				end
				-- bolsa de magma: núcleo blanco-amarillo + anillo caliente
				local px = s * (X1 - 0.12)
				G(b:cylinder(0.06, 0.66, CFrame.new(px, headY, 0), magmaHot, "PocketGlow"))
				G(b:cylinder(0.06, 0.34, CFrame.new(px + s * 0.03, headY, 0), magmaWhite, "PocketCore"))
				-- costura de magma junto al fleje
				G(b:box(Vector3.new(0.06, HB + 0.1, DB + 0.1), CFrame.new(s * (bandX + 0.035), headY, 0), magma, "BandSeam"))
			end)

			-- ── fleje de hierro central ─────────────────────
			b:bevelBox(Vector3.new(bandX * 2 - 0.3, HB, DB), CFrame.new(0, headY, 0), iron, 0.1, { edgeStyle = ironEdge, name = "Band" })
			B.both(function(s)
				b:bevelBox(Vector3.new(0.18, HB + 0.14, DB + 0.14), CFrame.new(s * (bandX - 0.1), headY, 0), ironAlt, 0.07, { edges = "X", edgeStyle = ironEdge, name = "BandRim" })
			end)
			B.both(function(s)
				local zs = DB / 2
				local face = B.faceZ(s, headY, zs + 0.025)
				-- panel hundido con marco
				b:box(Vector3.new(0.86, HB - 0.22, 0.05), face, ironAlt, "BandPanel")
				b:box(Vector3.new(0.05, HB - 0.3, 0.04), face * CFrame.new(-0.32, 0, 0.03), ironEdge, "BandLine")
				b:box(Vector3.new(0.05, HB - 0.3, 0.04), face * CFrame.new(0.32, 0, 0.03), ironEdge, "BandLine")
				-- remaches chicos en las orillas
				for _, cx in { -0.42, 0.42 } do
					for i = 0, 3 do
						b:rivet(face:PointToWorldSpace(Vector3.new(cx, -0.78 + i * 0.52, 0.05)), 0.09, rivetSt)
					end
				end
				-- dos remaches grandes de cobre
				for _, cy in { 0.42, -0.42 } do
					b:cylZ(0.06, 0.38, face * CFrame.new(0, cy, 0.04), ironEdge, "BossSeat")
					b:ball(0.3, face:PointToWorldSpace(Vector3.new(0, cy, 0.07)), copper, "CopperBoss")
					b:ball(0.1, face:PointToWorldSpace(Vector3.new(-0.05, cy + 0.06, 0.2)), copperHot, "BossShine")
				end
				-- grieta al rojo que cruza el panel (el calor ya rajó el hierro)
				local pts = {}
				for _, v in B.jitterPath(Vector3.new(-0.28, 0.95, 0), Vector3.new(0.1, 0.08, 0), 4, 0.07, if s > 0 then 5 else 9) do
					table.insert(pts, face:PointToWorldSpace(Vector3.new(v.X, v.Y, 0.04)))
				end
				for _, p in b:polyline(pts, 0.04, 0.03, magmaHot, face.LookVector, false, "BandCrack") do
					G(p)
				end
			end)
			-- arriba y abajo del fleje
			b:box(Vector3.new(0.86, 0.05, DB - 0.3), CFrame.new(0, headY + HB / 2 + 0.02, 0), ironAlt, "BandTopPlate")
			b:rivetLine(Vector3.new(-0.3, headY + HB / 2 + 0.05, 0), Vector3.new(0.3, headY + HB / 2 + 0.05, 0), 3, 0.1, rivetSt)
		end)

		-- ── gotas de magma ──────────────────────────────────────
		local drips = {}
		b:group("Drips", function()
			local function drip(x: number, z: number, len: number, r: number)
				table.insert(drips, G(b:ball(r * 2.4, Vector3.new(x, yBot - 0.02, z), magma, "DripLip")))
				table.insert(drips, G(b:cylY(len, r * 1.1, CFrame.new(x, yBot - len / 2, z), magma, "DripStem")))
				table.insert(drips, G(b:ball(r * 2.2, Vector3.new(x, yBot - len, z), magmaHot, "DripBulb")))
			end
			drip(-1.5, 0.35, 0.55, 0.08)
			drip(-1.05, -0.4, 0.32, 0.07)
			drip(1.25, 0.42, 0.7, 0.085)
			drip(1.7, -0.3, 0.38, 0.07)
		end)
		b:animate(drips, CFrame.new(0, yBot, 0), { Bob = Vector3.new(0, 0.04, 0), BobSpeed = 0.6 })

		-- ── esquirlas flotantes ─────────────────────────────────
		b:group("Debris", function()
			local defs = {
				{ -2.45, yTop + 0.25, 0.4, 0.26 }, { -1.3, yTop + 0.55, -0.5, 0.2 }, { 1.0, yTop + 0.5, 0.55, 0.22 },
				{ 2.5, yTop + 0.1, -0.35, 0.28 }, { 2.55, headY - 0.8, 0.5, 0.18 }, { -2.5, headY - 0.6, -0.45, 0.2 },
			}
			for i, d in defs do
				local pos = Vector3.new(d[1], d[2], d[3])
				local cf = CFrame.new(pos) * CFrame.Angles(i * 0.7, i * 1.3, i * 0.4)
				local parts = rock(cf, Vector3.new(d[4], d[4] * 0.85, d[4] * 0.9), if i % 2 == 0 then rockLava else rockB, d[4] * 0.22)
				table.insert(parts, G(b:box(Vector3.new(d[4] * 0.6, d[4] * 0.6, d[4] * 0.6) * 1.02, cf, magma, "DebrisCore")))
				b:animate(parts, CFrame.new(pos), { Bob = Vector3.new(0, 0.14, 0), BobSpeed = 0.3 + i * 0.04, Phase = i * 0.5, Spin = Vector3.new(0.2, 0.5, 0.1) })
			end
		end)

		-- ── mango forrado de roca ───────────────────────────────
		-- k = escala radial del mango (agarre robusto como el concepto); gBot = fin inferior del agarre
		local k = 1.25
		local gBot = -1.0
		b:group("Shaft", function()
			local top = headY - HB / 2 - 0.05
			local bottom = gBot
			G(b:cylY(top - bottom, 0.38 * k, CFrame.new(0, (top + bottom) / 2, 0), magma, "ShaftCore"))
			-- collar de hierro
			local cy = top - 0.22
			b:bevelBox(Vector3.new(0.8 * k, 0.36, 0.8 * k), CFrame.new(0, cy, 0), iron, 0.2 * k, { edges = "Y", edgeStyle = ironEdge, name = "Collar" })
			b:cylY(0.08, 0.7 * k, CFrame.new(0, cy - 0.22, 0), ironAlt, "CollarLip")
			for i = 0, 3 do
				local a = i * math.pi / 2 + math.pi / 4
				b:rivet(Vector3.new(math.cos(a) * 0.3 * k, cy, math.sin(a) * 0.3 * k), 0.1 * k, rivetSt)
			end
			-- trozos de roca en espiral alrededor del magma
			local y = cy - 0.3
			local lvl = 0
			while y > bottom + 0.1 do
				local h = 0.28
				for q = 0, 3 do
					local a = q * math.pi / 2 + lvl * 0.45
					local cf = CFrame.new(0, y - h / 2, 0) * CFrame.Angles(0, a, 0) * CFrame.new(0.15 * k, 0, 0) * CFrame.Angles(0, 0, rnd(-0.06, 0.06))
					b:box(Vector3.new(0.26 * k, h - 0.04, 0.38 * k), cf, if (q + lvl) % 3 == 0 then rockLava elseif q % 2 == 0 then rockA else rockB, "GripRock")
				end
				y -= h + 0.05
				lvl += 1
			end
		end)

		-- ── pomo de roca rajada (1.3x, achatado) ────────────────
		b:group("Pommel", function()
			local pk = 1.3
			local py = gBot - 0.22
			b:cylY(0.08, 0.66 * pk, CFrame.new(0, py + 0.2, 0), ironAlt, "PommelBand")
			rock(CFrame.new(0, py, 0) * CFrame.Angles(0, 0.4, 0.04), Vector3.new(0.8 * pk, 0.38, 0.8 * pk), rockB, 0.15)
			G(b:box(Vector3.new(0.74 * pk, 0.05, 0.74 * pk), CFrame.new(0, py - 0.02, 0) * CFrame.Angles(0, 0.4, 0.05), magmaHot, "PommelSeam"))
			rock(CFrame.new(0, py - 0.24, 0) * CFrame.Angles(0.05, 1.1, 0), Vector3.new(0.5 * pk, 0.18, 0.5 * pk), rockLava, 0.07)
			G(b:cylY(0.04, 0.22 * pk, CFrame.new(0, py - 0.34, 0), magmaHot, "PommelCore"))
		end)

		b:pulse(glow, 0, 0.3, 0.9)

		-- ── efectos ─────────────────────────────────────────────
		b:group("FX", function()
			local v = b:fxVolume(Vector3.new(X1 * 2, H, D), CFrame.new(0, headY, 0), "EmberVolume")
			b:emitter(v, B.Particles.ember(P.rgb(255, 150, 40), 14), "MagmaEmbers")
			B.both(function(s)
				local top = b:fxVolume(Vector3.new(1.1, 0.1, 1.6), CFrame.new(s * 1.38, yTop + 0.05, 0), "FlameVolume")
				local fl = B.Particles.flame(fireC, 5)
				fl.Size = B.seq(0, 0.35, 0.5, 0.5, 1, 0)
				fl.Lifetime = NumberRange.new(0.3, 0.55)
				b:emitter(top, fl, "MagmaFlames")
			end)
			local sm = B.Particles.smoke(P.rgb(58, 48, 44), 5)
			sm.Size = B.seq(0, 0.5, 1, 1.8)
			b:emitter(b:fxVolume(Vector3.new(X1 * 2 - 0.4, 0.2, D - 0.4), CFrame.new(0, yTop + 0.6, 0), "SmokeVolume"), sm, "MagmaSmoke")
			b:emitter(b:fxVolume(Vector3.new(X1 * 2 - 0.6, 0.1, D - 0.5), CFrame.new(0, yBot - 0.05, 0), "DripVolume"), B.Particles.drip(P.rgb(255, 120, 20), 4), "MagmaDrip")
		end)
		b:light(Vector3.new(-1.4, headY + 0.3, 0), fireC, 1.5, 10, { pulse = { 0.8, 2.1 }, pulseSpeed = 3.7, name = "MagmaGlowL" })
		b:light(Vector3.new(1.4, headY + 0.3, 0), P.rgb(255, 140, 40), 1.3, 10, { pulse = { 0.7, 1.9 }, pulseSpeed = 2.9, name = "MagmaGlowR" })

		-- impacto: brasas, llamarada, esquirlas de roca y humo
		local embers = B.Particles.ember(fireC, 0)
		embers.Speed = NumberRange.new(6, 13)
		embers.Acceleration = Vector3.new(0, -6, 0)
		embers.SpreadAngle = Vector2.new(70, 70)
		local blast = B.Particles.flame(fireC, 0)
		blast.Speed = NumberRange.new(4, 9)
		blast.SpreadAngle = Vector2.new(65, 65)
		blast.Size = B.seq(0, 0.9, 0.5, 1.5, 1, 0)
		local smoke = B.Particles.smoke(P.rgb(52, 42, 38), 0)
		smoke.Speed = NumberRange.new(2, 4)
		smoke.Size = B.seq(0, 0.8, 1, 2.4)
		local splash = B.Particles.drip(P.rgb(255, 130, 30), 0)
		splash.Speed = NumberRange.new(5, 10)
		splash.EmissionDirection = Enum.NormalId.Top
		splash.SpreadAngle = Vector2.new(70, 70)
		splash.Acceleration = Vector3.new(0, -22, 0)
		local hit = b:impact(CFrame.new(-(X1 + 0.3), headY, 0), fireC, { sparks = 30, flash = 9, extra = { embers, blast, smoke, splash } })
		hit:FindFirstChild("ImpactExtra1"):SetAttribute("FX_Emit", 26)
		hit:FindFirstChild("ImpactExtra2"):SetAttribute("FX_Emit", 10)
		hit:FindFirstChild("ImpactExtra3"):SetAttribute("FX_Emit", 7)
		hit:FindFirstChild("ImpactExtra4"):SetAttribute("FX_Emit", 18)
		b:trail(Vector3.new(0, yTop, 0), Vector3.new(0, yBot, 0), P.rgb(255, 214, 110), P.rgb(210, 40, 0), { lifetime = 0.26 })
	end,
}
