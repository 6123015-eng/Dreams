-- Inferno Hammer (Legendary) — un pedazo de volcán encadenado: la cabeza es un NÚCLEO DE LAVA de neón
-- cubierto por losas de roca quemada que no alcanzan a cerrar, así que el magma brilla por TODAS las
-- juntas, además de grietas al rojo vivo sobre cada losa. Dos cadenas de hierro negro (eslabones planos
-- y de canto alternados) la abrazan en diagonal y de una cuelga un tramo suelto que se mece.
-- LENGUAS DE FUEGO de neón (naranja por fuera, amarillo por dentro) brotan de la parte de arriba y
-- parpadean como fuego real. Cara de golpe con placa de hierro, panel de lava y picos de hierro en las
-- esquinas; el otro extremo con remate de hierro y núcleo al rojo. Mango de roca de lava en bloques con
-- magma entre las juntas, collar de hierro y pomo de roca rajada. FX: llamas fuertes, brasas, humo,
-- luz naranja que parpadea; impacto con brasas, llamarada y humo.
return {
	Id = "InfernoHammer",
	DisplayName = "Inferno Hammer",
	Rarity = "Legendary",
	Order = 4,
	Theme = "Magma Forge",
	Build = function(b, P, B)
		local A = B.Anatomy
		local headY = A.HeadY + 0.1

		-- ── estilos ─────────────────────────────────────────────
		local fireC = P.rgb(255, 110, 20)
		local rock = P.style(P.rgb(30, 22, 22), Enum.Material.Basalt, 0)
		local rockEdge = P.style(P.rgb(150, 54, 22), Enum.Material.CrackedLava, 0) -- arista al rojo
		local rockAlt = P.style(P.rgb(40, 28, 26), Enum.Material.Basalt, 0)
		local lavaRock = P.style(P.rgb(70, 30, 22), Enum.Material.CrackedLava, 0)
		local iron = P.metal(P.rgb(52, 50, 52), 0.12)
		local ironEdge = P.metal(P.rgb(120, 112, 108), 0.18)
		local ironDark = P.metal(P.rgb(30, 28, 30), 0.08)
		local lava = P.neon(P.rgb(255, 98, 10))
		local lavaHot = P.neon(P.rgb(255, 178, 40))
		local tongueOut = P.neon(P.rgb(255, 96, 12), 0.3)
		local tongueIn = P.neon(P.rgb(255, 214, 80), 0.15)

		-- ── helpers ─────────────────────────────────────────────
		local function along(pos: Vector3, dir: Vector3): CFrame
			local up = dir.Unit
			local ref = if math.abs(up.Y) < 0.9 then Vector3.yAxis else Vector3.xAxis
			local vx = up:Cross(ref).Unit
			local vz = vx:Cross(up).Unit
			return CFrame.fromMatrix(pos, vx, up, vz)
		end
		local function spike(pos: Vector3, dir: Vector3, len: number, w: number, sides: number?, st)
			return b:pyramid(along(pos - dir.Unit * 0.06, dir), len + 0.06, w, sides or 3, st or iron, "Spike")
		end
		local glowParts = {}
		local V = Vector2.new
		local function crack(face: CFrame, pts2: { Vector2 }, w: number?)
			local pts = {}
			for _, v in pts2 do
				table.insert(pts, face:PointToWorldSpace(Vector3.new(v.X, v.Y, 0.012)))
			end
			for _, p in b:polyline(pts, w or 0.06, 0.05, lavaHot, face.LookVector, false, "Crack") do
				table.insert(glowParts, p)
			end
		end
		-- barra orientada: X = a, Y = c, Z = a × c
		local function bar(pos: Vector3, a: Vector3, c: Vector3, size: Vector3, st, name)
			return b:box(size, CFrame.fromMatrix(pos, a, c), st, name)
		end

		-- ── medidas ────────────────────────────────────────────
		local HW, H, D = 3.8, 2.1, 2.0
		local X0, X1 = -HW / 2, HW / 2

		b:group("Head", function()
			-- núcleo de lava (se ve por todas las juntas)
			table.insert(glowParts, b:box(Vector3.new(HW - 0.2, H - 0.16, D - 0.16), CFrame.new(0, headY, 0), lava, "LavaCore"))

			-- losas de roca: 3 columnas × 2 filas, con juntas de ~0.08 y giros leves
			local cols = { { X0, -0.74, 0.28 }, { -0.66, 0.5, -0.14 }, { 0.58, X1, 0.36 } } -- {x0, x1, junta horizontal}
			local rots = { 0.05, -0.04, -0.035, 0.03, 0.045, -0.05 }
			local n = 0
			for ci, c in cols do
				local split = c[3]
				for ri, r in { { split + 0.04, H / 2 }, { -H / 2, split - 0.04 } } do
					n += 1
					local w = c[2] - c[1]
					local h = r[2] - r[1]
					local bulge = if (ci + ri) % 2 == 0 then 0.06 else 0
					local cf = CFrame.new((c[1] + c[2]) / 2, headY + (r[1] + r[2]) / 2, 0) * CFrame.Angles(rots[n] * 0.6, 0, rots[n])
					b:bevelBox(Vector3.new(w, h + bulge, D + bulge), cf, if n % 2 == 0 then rockAlt else rock, 0.14, { edges = "X", edgeStyle = rockEdge, name = "RockSlab" })
				end
			end

			-- grietas al rojo: una grieta larga en zigzag que cruza cada cara + ramas (ambas caras + arriba)
			B.both(function(s)
				local face = B.faceZ(s, headY, D / 2 + 0.03)
				local k = s
				local function jag(x0, y0, x1, y1, segs, amp, seed, w)
					local pts2 = {}
					for _, v in B.jitterPath(Vector3.new(x0, y0, 0), Vector3.new(x1, y1, 0), segs, amp, seed) do
						table.insert(pts2, V(v.X * k, v.Y))
					end
					crack(face, pts2, w)
				end
				jag(-1.75, 0.55, 1.75, -0.35, 9, 0.22, if s > 0 then 7 else 19, 0.085)
				jag(-1.2, 0.95, -0.9, 0.3, 3, 0.12, 31, 0.06)
				jag(-0.1, 0.1, 0.25, -0.95, 3, 0.12, 43, 0.065)
				jag(0.9, 0.0, 1.35, 0.95, 3, 0.12, 57, 0.06)
			end)
			local topF = CFrame.new(0, headY + H / 2 + 0.04, 0) * CFrame.Angles(-math.pi / 2, 0, 0)
			local tp = {}
			for _, v in B.jitterPath(Vector3.new(-1.75, 0, 0), Vector3.new(1.75, 0.1, 0), 7, 0.3, 77) do
				table.insert(tp, V(v.X, v.Y))
			end
			crack(topF, tp, 0.09)

			-- ── cara de golpe (-X): placa de hierro, panel de lava, picos ──
			local fx = X0 - 0.06
			b:bevelBox(Vector3.new(0.16, H + 0.06, D + 0.06), CFrame.new(fx, headY, 0), iron, 0.07, { edges = "X", edgeStyle = ironEdge, name = "StrikePlate" })
			b:box(Vector3.new(0.08, H - 0.5, D - 0.5), CFrame.new(fx - 0.08, headY, 0), lavaRock, "StrikePanel")
			local sf = B.faceX(-1, -fx + 0.12, headY)
			crack(sf, { V(-0.6, 0.55), V(-0.15, 0.1), V(0.1, 0.18), V(0.6, -0.5) }, 0.08)
			crack(sf, { V(-0.15, 0.1), V(-0.35, -0.55) }, 0.07)
			crack(sf, { V(0.1, 0.18), V(0.45, 0.6) }, 0.06)
			for _, cy in { 1, -1 } do
				for _, cz in { 1, -1 } do
					spike(Vector3.new(fx, headY + cy * (H / 2 - 0.12), cz * (D / 2 - 0.12)), Vector3.new(-1, cy * 0.5, cz * 0.45), 0.62, 0.32, 3, iron)
				end
			end
			-- dos picos grandes arriba del lado de golpe (silueta del concepto)
			spike(Vector3.new(X0 + 0.35, headY + H / 2, 0.35), Vector3.new(-0.7, 1, 0.2), 0.6, 0.34, 3, ironDark)

			-- ── remate +X: placa de hierro con núcleo al rojo ──
			local rx = X1 + 0.06
			b:bevelBox(Vector3.new(0.16, H + 0.06, D + 0.06), CFrame.new(rx, headY, 0), iron, 0.07, { edges = "X", edgeStyle = ironEdge, name = "EndPlate" })
			b:box(Vector3.new(0.14, 0.95, 0.95), CFrame.new(rx + 0.12, headY, 0) * CFrame.Angles(math.pi / 4, 0, 0), ironDark, "EndBoss")
			b:box(Vector3.new(0.06, H - 0.5, D - 0.5), CFrame.new(rx + 0.07, headY, 0), lavaRock, "EndPanel")
			table.insert(glowParts, b:cylinder(0.08, 0.46, CFrame.new(rx + 0.2, headY, 0), lavaHot, "EndCore"))
			local ef = B.faceX(1, rx + 0.11, headY)
			crack(ef, { V(-0.65, -0.6), V(-0.3, -0.3), V(0.3, 0.32), V(0.62, 0.62) }, 0.07)
		end)

		-- ── cadenas de hierro ───────────────────────────────────
		local chainParts = {}
		local LINK = 0.4
		local function chainLoop(cx: number, tilt: number)
			local t = math.rad(tilt)
			local nrm = Vector3.new(math.cos(t), math.sin(t), 0)
			local u = Vector3.new(-math.sin(t), math.cos(t), 0)
			local w = Vector3.zAxis
			local g = 0.07
			local hy = (H / 2 + g) / math.cos(t)
			local hz = D / 2 + g
			local c = Vector3.new(cx, headY, 0)
			local P1, P2, P3, P4 = c + u * hy + w * hz, c - u * hy + w * hz, c - u * hy - w * hz, c + u * hy - w * hz
			local edges = { { P1, P2, w }, { P2, P3, -u }, { P3, P4, -w }, { P4, P1, u } }
			local parity = 0
			for _, e in edges do
				local p0, p1, out = e[1], e[2], e[3]
				local len = (p1 - p0).Magnitude
				local dir = (p1 - p0).Unit
				local m = math.max(1, math.floor(len / LINK + 0.5))
				local sp = len / m
				for i = 0, m - 1 do
					local ctr = p0 + dir * (i + 0.5) * sp
					parity += 1
					if parity % 2 == 0 then
						-- eslabón plano: dos barras paralelas
						-- eslabón plano: placa de hierro con hueco oscuro
						table.insert(chainParts, bar(ctr + out * 0.05, nrm, out, Vector3.new(0.34, 0.08, sp * 1.22), iron, "ChainLink"))
						table.insert(chainParts, bar(ctr + out * 0.05, nrm, out, Vector3.new(0.14, 0.1, sp * 0.62), ironDark, "ChainHole"))
					else
						-- eslabón de canto: barra elevada que cruza
						table.insert(chainParts, bar(ctr + out * 0.12, out, nrm, Vector3.new(0.2, 0.09, sp * 1.35), ironEdge, "ChainLink"))
					end
				end
			end
			return P2, P3
		end
		local hangParts = {}
		local hangTop = Vector3.zero
		b:group("Chains", function()
			chainLoop(-1.05, 16)
			local fb = chainLoop(1.18, -18)
			-- tramo suelto colgando del frente-abajo de la cadena derecha
			local top = fb + Vector3.new(0.05, -0.05, 0.04)
			hangTop = top
			for i = 0, 4 do
				local ctr = top + Vector3.new(0.03 * i, -(i + 0.5) * LINK, 0.02 * i)
				if i % 2 == 0 then
					table.insert(hangParts, bar(ctr, Vector3.xAxis, Vector3.zAxis, Vector3.new(0.34, 0.08, LINK * 1.22), iron, "HangLink"))
					table.insert(hangParts, bar(ctr, Vector3.xAxis, Vector3.zAxis, Vector3.new(0.14, 0.1, LINK * 0.62), ironDark, "HangHole"))
				else
					table.insert(hangParts, bar(ctr, Vector3.zAxis, Vector3.xAxis, Vector3.new(0.1, 0.1, LINK * 1.35), ironEdge, "HangLink"))
				end
			end
		end)
		b:animate(hangParts, CFrame.new(hangTop), { Bob = Vector3.new(0.06, 0, 0.04), BobSpeed = 0.4 })

		-- ── lenguas de fuego (parpadean) ────────────────────────
		local tongues = b:group("FlameTongues", function()
			-- {x, z, largo, ancho, inclinación X, inclinación Z}
			local defs = {
				{ -1.6, 0.35, 1.0, 0.3, 0.1, -0.35 }, { -1.15, -0.3, 1.45, 0.36, -0.1, 0.12 }, { -0.6, 0.3, 1.15, 0.32, 0.08, -0.12 },
				{ -0.1, -0.25, 1.7, 0.4, -0.12, 0.05 }, { 0.4, 0.3, 1.25, 0.32, 0.1, 0.1 }, { 0.9, -0.3, 1.5, 0.36, -0.06, 0.18 },
				{ 1.45, 0.3, 1.1, 0.3, 0.1, 0.35 }, { 0.15, 0.55, 0.8, 0.26, 0.35, 0 },
			}
			for i, d in defs do
				local base = CFrame.new(d[1], headY + H / 2 - 0.12, d[2]) * CFrame.Angles(d[5], i * 0.9, 0) * CFrame.Angles(0, 0, d[6])
				b:pyramid(base, d[3], d[4], 3, tongueOut, "FlameTongue")
				if i % 2 == 0 then
					b:pyramid(base * CFrame.new(0, 0.02, 0) * CFrame.Angles(0, 1, 0), d[3] * 0.6, d[4] * 0.6, 3, tongueIn, "FlameCore")
				end
			end
		end)
		b:flicker(tongues, 9, 0.75)

		-- ── mango de roca de lava ───────────────────────────────
		b:group("Shaft", function()
			local top = headY - H / 2
			local bottom = A.ShaftBottom
			table.insert(glowParts, b:cylY(top - bottom, 0.4, CFrame.new(0, (top + bottom) / 2, 0), lava, "ShaftCore"))
			-- collar de hierro
			local cy = top - 0.2
			b:bevelBox(Vector3.new(0.72, 0.36, 0.72), CFrame.new(0, cy, 0), iron, 0.15, { edges = "Y", edgeStyle = ironEdge, name = "Collar" })
			b:cylY(0.1, 0.64, CFrame.new(0, cy - 0.24, 0), ironDark, "CollarLip")
			-- bloques de roca con magma entre juntas
			local segs = { { 1.9, 1.12 }, { 1.04, 0.26 }, { 0.18, -0.52 }, { -0.6, -1.25 } }
			for i, sg in segs do
				local h = sg[1] - sg[2]
				b:bevelBox(Vector3.new(0.54, h, 0.54), CFrame.new(0, (sg[1] + sg[2]) / 2, 0) * CFrame.Angles(0, i * 0.5, (if i % 2 == 0 then 1 else -1) * 0.03), if i % 2 == 0 then rockAlt else rock, 0.12, { edges = "Y", edgeStyle = rockEdge, name = "GripRock" })
			end
		end)

		-- ── pomo de roca rajada ─────────────────────────────────
		local py = A.PommelY - 0.06
		b:group("Pommel", function()
			b:bevelBox(Vector3.new(0.78, 0.6, 0.78), CFrame.new(0, py, 0) * CFrame.Angles(0.05, 0.4, -0.04), rock, 0.2, { edgeStyle = rockEdge, name = "PommelRock" })
			table.insert(glowParts, b:box(Vector3.new(0.82, 0.05, 0.82), CFrame.new(0, py + 0.02, 0) * CFrame.Angles(0, 0.4, 0.06), lava, "PommelSeam"))
			table.insert(glowParts, b:cylY(0.05, 0.36, CFrame.new(0, py - 0.31, 0), lavaHot, "PommelCore"))
		end)

		b:pulse(glowParts, 0, 0.35, 0.9)

		-- ── efectos ─────────────────────────────────────────────
		b:group("FX", function()
			local topV = b:fxVolume(Vector3.new(HW - 0.4, 0.2, D - 0.4), CFrame.new(0, headY + H / 2 + 0.1, 0), "FlameVolume")
			local fl = B.Particles.flame(fireC, 30)
			fl.Size = B.seq(0, 0.6, 0.5, 0.9, 1, 0)
			fl.Lifetime = NumberRange.new(0.4, 0.8)
			b:emitter(topV, fl, "InfernoFlames")
			local v = b:fxVolume(Vector3.new(HW, H, D), CFrame.new(0, headY, 0), "EmberVolume")
			b:emitter(v, B.Particles.ember(P.rgb(255, 150, 40), 9), "InfernoEmbers")
			local sm = B.Particles.smoke(P.rgb(54, 44, 40), 4)
			sm.Size = B.seq(0, 0.6, 1, 2)
			b:emitter(b:fxVolume(Vector3.new(HW - 0.6, 0.2, D - 0.6), CFrame.new(0, headY + H / 2 + 0.9, 0), "SmokeVolume"), sm, "InfernoSmoke")
			local dr = B.Particles.drip(P.rgb(255, 120, 20), 2)
			b:emitter(b:fxVolume(Vector3.new(HW - 0.4, 0.1, D - 0.4), CFrame.new(0, headY - H / 2 - 0.05, 0), "DripVolume"), dr, "MagmaDrip")
		end)
		b:light(Vector3.new(0, headY + 0.6, 0), fireC, 1.6, 11, { pulse = { 0.9, 2.2 }, pulseSpeed = 3.2, name = "InfernoGlow" })
		b:light(Vector3.new(X0 - 0.4, headY, 0), P.rgb(255, 140, 40), 0.7, 6, { pulse = { 0.4, 1.0 }, pulseSpeed = 2.1, name = "StrikeGlow" })

		local embers = B.Particles.ember(fireC, 0)
		embers.Speed = NumberRange.new(6, 13)
		embers.Acceleration = Vector3.new(0, -6, 0)
		embers.SpreadAngle = Vector2.new(70, 70)
		local blast = B.Particles.flame(fireC, 0)
		blast.Speed = NumberRange.new(4, 9)
		blast.SpreadAngle = Vector2.new(65, 65)
		blast.Size = B.seq(0, 0.9, 0.5, 1.6, 1, 0)
		local smoke = B.Particles.smoke(P.rgb(50, 40, 36), 0)
		smoke.Speed = NumberRange.new(2, 4)
		smoke.Size = B.seq(0, 0.8, 1, 2.4)
		local hit = b:impact(CFrame.new(X0 - 0.55, headY, 0), fireC, { sparks = 30, flash = 9, extra = { embers, blast, smoke } })
		hit:FindFirstChild("ImpactExtra1"):SetAttribute("FX_Emit", 26)
		hit:FindFirstChild("ImpactExtra2"):SetAttribute("FX_Emit", 12)
		hit:FindFirstChild("ImpactExtra3"):SetAttribute("FX_Emit", 8)
		b:trail(Vector3.new(0, headY + H / 2, 0), Vector3.new(0, headY - H / 2, 0), P.rgb(255, 220, 110), P.rgb(220, 40, 0), { lifetime = 0.28 })
	end,
}
