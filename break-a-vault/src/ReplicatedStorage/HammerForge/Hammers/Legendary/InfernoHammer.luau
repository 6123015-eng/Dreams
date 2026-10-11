-- Inferno Hammer (Legendary) — un pedazo de volcán encadenado y envuelto en fuego.
-- La cabeza es un NÚCLEO DE MAGMA de neón cubierto por bloques de roca volcánica biselados, cada uno un poco
-- chueco y abultado, con JUNTAS ANCHAS por donde se ve la lava al rojo vivo (arriba, abajo y en ambas caras),
-- y grietas incandescentes que parten cada bloque en lajas. Dos CADENAS de eslabones gruesos y redondeados
-- (ovalados, de 4 piezas, alternando plano/de canto) la abrazan en diagonal; de una cuelga un tramo suelto
-- que se mece. LLAMAS de neón (naranja por fuera, amarillo por dentro) lamen la cabeza por arriba, por los
-- lados y por las caras, ondulando y latiendo; además fuego de partículas sale de TODO el volumen de la cabeza.
-- Cara de golpe con tapa de roca, panel de lava y tres picos de hierro; el otro extremo con remate de hierro
-- y núcleo al rojo. Mango grueso de roca en bloques con magma entre juntas, collar de hierro y pomo de roca
-- enorme y rajado. FX: llamas, brasas, humo, goteo de magma, luz naranja que titila; impacto con brasas,
-- llamarada y humo.
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
		local rock = P.style(P.rgb(34, 24, 22), Enum.Material.Basalt, 0)
		local rockAlt = P.style(P.rgb(46, 32, 28), Enum.Material.Basalt, 0)
		local rockEdge = P.style(P.rgb(150, 58, 24), Enum.Material.CrackedLava, 0) -- arista al rojo
		local lavaRock = P.style(P.rgb(90, 36, 20), Enum.Material.CrackedLava, 0)
		local iron = P.metal(P.rgb(58, 54, 54), 0.14)
		local ironEdge = P.metal(P.rgb(128, 118, 110), 0.2)
		local ironDark = P.metal(P.rgb(30, 28, 30), 0.08)
		local chainSt = P.metal(P.rgb(84, 76, 72), 0.22)
		local chainHi = P.metal(P.rgb(118, 104, 96), 0.26)
		local lava = P.neon(P.rgb(255, 128, 22))
		local lavaHot = P.neon(P.rgb(255, 190, 60))
		local flameOut = P.neon(P.rgb(255, 92, 10), 0.3)
		local flameIn = P.neon(P.rgb(255, 222, 96), 0.12)

		-- ── helpers ─────────────────────────────────────────────
		local function along(pos: Vector3, dir: Vector3): CFrame
			local up = dir.Unit
			local ref = if math.abs(up.Y) < 0.9 then Vector3.yAxis else Vector3.xAxis
			local vx = up:Cross(ref).Unit
			local vz = vx:Cross(up).Unit
			return CFrame.fromMatrix(pos, vx, up, vz)
		end
		local function spike(pos: Vector3, dir: Vector3, len: number, w: number, st)
			return b:pyramid(along(pos - dir.Unit * 0.08, dir), len + 0.08, w, 3, st or iron, "Spike")
		end
		local glowParts = {}
		local V = Vector2.new
		local function crack(face: CFrame, pts2: { Vector2 }, w: number?, st)
			local pts = {}
			for _, v in pts2 do
				table.insert(pts, face:PointToWorldSpace(Vector3.new(v.X, v.Y, 0.014)))
			end
			for _, p in b:polyline(pts, w or 0.09, 0.05, st or lavaHot, face.LookVector, false, "Crack") do
				table.insert(glowParts, p)
			end
		end
		-- flama estilizada (8 puntos, curvita en la punta)
		local function flamePts(w: number, h: number, core: boolean?): { Vector2 }
			local raw = if core
				then { { 0, -0.5 }, { 0.42, -0.2 }, { 0.08, 0.5 }, { -0.3, 0.05 }, { -0.4, -0.3 } }
				else { { 0, -0.5 }, { 0.44, -0.24 }, { 0.32, 0.16 }, { 0.1, 0.5 }, { -0.28, 0.08 }, { -0.44, -0.24 } }
			local out = {}
			for _, p in raw do
				table.insert(out, V(p[1] * w, p[2] * h))
			end
			return out
		end

		-- ── medidas ────────────────────────────────────────────
		local HW, H, D = 3.8, 2.1, 2.0
		local X0, X1 = -HW / 2, HW / 2
		local GAP = 0.13 -- ancho de las juntas de lava

		b:group("Head", function()
			-- núcleo de magma (se ve por todas las juntas)
			table.insert(glowParts, b:box(Vector3.new(HW - 0.14, H - 0.22, D - 0.22), CFrame.new(0, headY, 0), lava, "MagmaCore"))

			-- bloques de roca: fila de arriba 3, fila de abajo 3 (juntas desfasadas como mampostería)
			local ySplit = 0.06
			local rows = {
				{ ySplit + GAP / 2, H / 2, { X0 + 0.06, -0.62, 0.52, X1 - 0.06 } },
				{ -H / 2, ySplit - GAP / 2, { X0 + 0.06, -1.02, 0.02, X1 - 0.06 } },
			}
			local rand = B.rng(9137)
			local n = 0
			for ri, r in rows do
				local xs = r[3]
				for ci = 1, #xs - 1 do
					n += 1
					local x0 = xs[ci] + (if ci > 1 then GAP / 2 else 0)
					local x1 = xs[ci + 1] - (if ci < #xs - 1 then GAP / 2 else 0)
					local w = x1 - x0
					local h = r[2] - r[1]
					local bulge = rand(0.02, 0.12)
					local dz = D + bulge
					local hh = h + (if ri == 1 then bulge * 0.6 else 0)
					local cy = (r[1] + r[2]) / 2 + (if ri == 1 then bulge * 0.3 else 0)
					local cf = CFrame.new((x0 + x1) / 2, headY + cy, 0) * CFrame.Angles(rand(-0.035, 0.035), rand(-0.03, 0.03), rand(-0.035, 0.035))
					b:bevelBox(Vector3.new(w, hh, dz), cf, if n % 2 == 0 then rockAlt else rock, 0.17, { edgeStyle = rockEdge, name = "RockChunk" })
					-- grieta incandescente que parte el bloque en lajas (en ambas caras, distinta en cada una)
					for _, s in { 1, -1 } do
						local face = cf * CFrame.new(0, 0, s * dz / 2)
						if s < 0 then
							face *= CFrame.Angles(0, math.pi, 0)
						end
						local hx, hy = w / 2 - 0.16, hh / 2 - 0.16
						local pts
						if w > 1.15 then
							-- de lado a lado, en zigzag
							pts = { V(-hx, rand(-0.6, 0.6) * hy), V(rand(-0.55, -0.15) * hx, rand(-0.5, 0.5) * hy), V(rand(0.1, 0.5) * hx, rand(-0.5, 0.5) * hy), V(hx, rand(-0.6, 0.6) * hy) }
							crack(face, pts, 0.1)
							local k = pts[if rand() > 0.5 then 2 else 3]
							crack(face, { k, V(k.X + rand(-0.25, 0.25), if rand() > 0.5 then hy else -hy) }, 0.075)
						else
							-- de arriba a abajo
							pts = { V(rand(-0.5, 0.5) * hx, hy), V(rand(-0.6, 0.6) * hx, rand(0.0, 0.4) * hy), V(rand(-0.6, 0.6) * hx, -hy) }
							crack(face, pts, 0.1)
						end
					end
				end
			end
			-- grieta larga en el lomo (arriba)
			local topF = CFrame.new(0, headY + H / 2 + 0.07, 0) * CFrame.Angles(-math.pi / 2, 0, 0)
			local tp = {}
			for _, v in B.jitterPath(Vector3.new(-1.7, 0, 0), Vector3.new(1.7, 0.1, 0), 6, 0.3, 77) do
				table.insert(tp, V(v.X, v.Y))
			end
			crack(topF, tp, 0.1)

			-- ── cara de golpe (-X): tapa de roca, panel de lava, picos de hierro ──
			local fx = X0 - 0.04
			b:bevelBox(Vector3.new(0.2, H + 0.1, D + 0.1), CFrame.new(fx, headY, 0), rock, 0.09, { edges = "X", edgeStyle = rockEdge, name = "StrikeCap" })
			b:box(Vector3.new(0.08, H - 0.44, D - 0.44), CFrame.new(fx - 0.1, headY, 0), lavaRock, "StrikePanel")
			local sf = B.faceX(-1, -fx + 0.15, headY)
			crack(sf, { V(-0.7, 0.62), V(-0.15, 0.12), V(0.12, 0.2), V(0.7, -0.6) }, 0.1)
			crack(sf, { V(-0.15, 0.12), V(-0.4, -0.66) }, 0.08)
			crack(sf, { V(0.12, 0.2), V(0.5, 0.66) }, 0.07)
			-- tres picos grandes (como el concepto) + uno arriba en la esquina
			spike(Vector3.new(fx - 0.1, headY + 0.55, 0.5), Vector3.new(-1, 0.32, 0.18), 0.85, 0.42, iron)
			spike(Vector3.new(fx - 0.1, headY + 0.55, -0.5), Vector3.new(-1, 0.32, -0.18), 0.85, 0.42, iron)
			spike(Vector3.new(fx - 0.1, headY - 0.5, 0), Vector3.new(-1, -0.25, 0), 0.8, 0.42, iron)
			spike(Vector3.new(X0 + 0.3, headY + H / 2 + 0.05, 0), Vector3.new(-0.75, 1, 0), 0.7, 0.38, ironDark)

			-- ── remate +X: placa de hierro con núcleo al rojo ──
			local rx = X1 + 0.05
			b:bevelBox(Vector3.new(0.18, H + 0.08, D + 0.08), CFrame.new(rx, headY, 0), iron, 0.08, { edges = "X", edgeStyle = ironEdge, name = "EndPlate" })
			b:box(Vector3.new(0.06, H - 0.44, D - 0.44), CFrame.new(rx + 0.1, headY, 0), lavaRock, "EndPanel")
			b:box(Vector3.new(0.16, 0.95, 0.95), CFrame.new(rx + 0.14, headY, 0) * CFrame.Angles(math.pi / 4, 0, 0), ironDark, "EndBoss")
			table.insert(glowParts, b:cylinder(0.1, 0.5, CFrame.new(rx + 0.2, headY, 0), lavaHot, "EndCore"))
			local ef = B.faceX(1, rx + 0.13, headY)
			crack(ef, { V(-0.72, -0.66), V(-0.36, -0.34) }, 0.08)
			crack(ef, { V(0.36, 0.36), V(0.72, 0.68) }, 0.08)
		end)

		-- ── cadenas: eslabones ovalados gruesos (4 piezas: 2 lados + 2 cabezas), plano / de canto ──
		local LL, LW, LT = 0.86, 0.5, 0.16 -- largo, ancho, grosor del eslabón
		local PITCH = 0.66
		local function link(ctr: Vector3, dir: Vector3, out: Vector3, flat: boolean, list)
			dir, out = dir.Unit, out.Unit
			local lat = dir:Cross(out).Unit
			local w = if flat then lat else out
			local c = ctr + out * (if flat then LT / 2 + 0.01 else LW / 2 - 0.02)
			for _, sg in { -1, 1 } do
				table.insert(list, b:cylinder(LL - LT * 0.6, LT, CFrame.fromMatrix(c + w * sg * (LW / 2 - LT / 2), dir, w), chainSt, "ChainLink"))
				table.insert(list, b:cylinder(LW - LT * 0.4, LT * 0.96, CFrame.fromMatrix(c + dir * sg * (LL / 2 - LT / 2), w, dir), chainHi, "ChainLink"))
			end
		end
		local function chainLoop(cx: number, tilt: number, list)
			local t = math.rad(tilt)
			local u = Vector3.new(-math.sin(t), math.cos(t), 0)
			local wz = Vector3.zAxis
			local g = 0.1
			local hy = (H / 2 + g) / math.cos(t)
			local hz = D / 2 + g
			local c = Vector3.new(cx, headY, 0)
			local P1, P2, P3, P4 = c + u * hy + wz * hz, c - u * hy + wz * hz, c - u * hy - wz * hz, c + u * hy - wz * hz
			local edges = { { P1, P2, wz }, { P2, P3, -u }, { P3, P4, -wz }, { P4, P1, u } }
			local parity = 0
			for _, e in edges do
				local p0, p1, out = e[1], e[2], e[3]
				local len = (p1 - p0).Magnitude
				local dir = (p1 - p0).Unit
				local m = math.max(1, math.floor(len / PITCH + 0.5))
				local sp = len / m
				for i = 0, m - 1 do
					parity += 1
					link(p0 + dir * (i + 0.5) * sp, dir, out, parity % 2 == 1, list)
				end
			end
			return P2
		end
		local hangParts = {}
		local hangTop = Vector3.zero
		b:group("Chains", function()
			local junk = {}
			chainLoop(-1.0, 15, junk)
			local fb = chainLoop(1.15, -17, junk)
			-- tramo suelto colgando del frente-abajo de la cadena derecha
			hangTop = fb + Vector3.new(0.04, -0.1, 0.12)
			for i = 0, 2 do
				local ctr = hangTop + Vector3.new(0.03 * i, -(i + 0.5) * PITCH, 0.03 * i)
				link(ctr - Vector3.zAxis * (if i % 2 == 0 then LT / 2 else LW / 2), Vector3.new(0, -1, 0), Vector3.zAxis, i % 2 == 0, hangParts)
			end
		end)
		b:animate(hangParts, CFrame.new(hangTop), { Bob = Vector3.new(0.07, 0, 0.05), BobSpeed = 0.45 })

		-- ── llamas de neón alrededor de la cabeza (ondulan y laten) ──
		local flameGroups = {}
		b:group("Flames", function()
			local top = headY + H / 2
			-- {cf de la base (centro de la flama), ancho, alto, núcleo?}
			local defs = {
				{ CFrame.new(-0.1, top + 0.55, 0.05) * CFrame.Angles(0, 0.12, -0.05), 1.0, 1.9, true },
				{ CFrame.new(-1.2, top + 0.35, 0.5) * CFrame.Angles(0, -0.4, 0.18), 0.8, 1.4, false },
				{ CFrame.new(1.05, top + 0.4, -0.45) * CFrame.Angles(0, 0.5, -0.16), 0.85, 1.55, true },
				{ CFrame.new(X1 + 0.32, headY + 0.75, 0.15) * CFrame.Angles(0, math.pi / 2, -0.3), 0.8, 1.5, false },
				{ CFrame.new(0.95, headY - 0.05, D / 2 + 0.24) * CFrame.Angles(0.22, 0, -0.08), 0.75, 1.5, false },
				{ CFrame.new(-0.55, headY + 0.1, -D / 2 - 0.24) * CFrame.Angles(-0.22, math.pi, 0.1), 0.75, 1.45, false },
				{ CFrame.new(0.55, top + 0.3, 0.75) * CFrame.Angles(0.35, 0.2, -0.1), 0.6, 1.1, true },
			}
			for i, d in defs do
				local parts = b:shape(d[1], flamePts(d[2], d[3]), 0.06, flameOut, "Flame")
				if d[4] then
					for _, p in b:shape(d[1] * CFrame.new(0, -d[3] * 0.12, 0.05), flamePts(d[2] * 0.5, d[3] * 0.55, true), 0.05, flameIn, "FlameCore") do
						table.insert(parts, p)
					end
				end
				table.insert(flameGroups, { parts, d[1], i })
			end
		end)
		for _, fg in flameGroups do
			b:animate(fg[1], fg[2], { Bob = Vector3.new(0.03, 0.09, 0), BobSpeed = 1.6 + fg[3] * 0.17, Phase = fg[3] * 0.23 })
			b:pulse(fg[1], 0.12, 0.5, 2.4 + fg[3] * 0.3, fg[3] * 0.11)
		end

		-- ── mango grueso de roca de lava ────────────────────────
		local shaftTop = headY - H / 2
		local shaftBottom = A.ShaftBottom + 0.22
		b:group("Shaft", function()
			table.insert(glowParts, b:cylY(shaftTop - shaftBottom, 0.48, CFrame.new(0, (shaftTop + shaftBottom) / 2, 0), lava, "ShaftCore"))
			-- collar de hierro
			local cy = shaftTop - 0.2
			b:bevelBox(Vector3.new(0.84, 0.38, 0.84), CFrame.new(0, cy, 0), iron, 0.16, { edges = "Y", edgeStyle = ironEdge, name = "Collar" })
			b:cylY(0.1, 0.76, CFrame.new(0, cy - 0.25, 0), ironDark, "CollarLip")
			-- bloques de roca con magma entre juntas
			local segs = { { 1.8, 1.08 }, { 0.98, 0.26 }, { 0.16, -0.5 }, { -0.6, shaftBottom } }
			for i, sg in segs do
				local h = sg[1] - sg[2]
				b:bevelBox(Vector3.new(0.64, h, 0.64), CFrame.new(0, (sg[1] + sg[2]) / 2, 0) * CFrame.Angles(0, i * 0.5, (if i % 2 == 0 then 1 else -1) * 0.035), if i % 2 == 0 then rockAlt else rock, 0.14, { edges = "Y", edgeStyle = rockEdge, name = "GripRock" })
			end
		end)

		-- ── pomo: roca enorme y rajada ──────────────────────────
		local py = shaftBottom - 0.36
		b:group("Pommel", function()
			b:bevelBox(Vector3.new(0.98, 0.74, 0.98), CFrame.new(0, py, 0) * CFrame.Angles(0.06, 0.4, -0.05), rock, 0.26, { edgeStyle = rockEdge, name = "PommelRock" })
			b:box(Vector3.new(0.8, 0.6, 0.8), CFrame.new(0, py - 0.04, 0) * CFrame.Angles(0.5, 1.2, 0.45), rockAlt, "PommelFacet")
			table.insert(glowParts, b:box(Vector3.new(0.9, 0.07, 0.9), CFrame.new(0, py + 0.04, 0) * CFrame.Angles(0.06, 0.4, -0.02), lava, "PommelSeam"))
			table.insert(glowParts, b:box(Vector3.new(0.07, 0.62, 0.9), CFrame.new(0, py - 0.02, 0) * CFrame.Angles(0.06, 1.1, 0.06), lava, "PommelSeam"))
			table.insert(glowParts, b:cylY(0.05, 0.42, CFrame.new(0, py - 0.38, 0), lavaHot, "PommelCore"))
		end)

		b:pulse(glowParts, 0, 0.3, 1.1)

		-- ── efectos ─────────────────────────────────────────────
		b:group("FX", function()
			-- fuego desde TODO el volumen de la cabeza
			local hv = b:fxVolume(Vector3.new(HW + 0.2, H, D + 0.2), CFrame.new(0, headY, 0), "FireVolume")
			local fl = B.Particles.flame(fireC, 26)
			fl.Size = B.seq(0, 0.5, 0.45, 0.85, 1, 0)
			fl.Lifetime = NumberRange.new(0.35, 0.65)
			fl.SpreadAngle = Vector2.new(25, 25)
			b:emitter(hv, fl, "InfernoBody")
			local topV = b:fxVolume(Vector3.new(HW - 0.4, 0.2, D - 0.4), CFrame.new(0, headY + H / 2 + 0.15, 0), "FlameVolume")
			local tf = B.Particles.flame(P.rgb(255, 150, 40), 14)
			tf.Size = B.seq(0, 0.7, 0.5, 1.15, 1, 0)
			tf.Lifetime = NumberRange.new(0.45, 0.85)
			b:emitter(topV, tf, "InfernoCrown")
			b:emitter(hv, B.Particles.ember(P.rgb(255, 160, 50), 10), "InfernoEmbers")
			local sm = B.Particles.smoke(P.rgb(54, 44, 40), 3)
			sm.Size = B.seq(0, 0.6, 1, 2.2)
			b:emitter(b:fxVolume(Vector3.new(HW - 0.6, 0.2, D - 0.6), CFrame.new(0, headY + H / 2 + 1.1, 0), "SmokeVolume"), sm, "InfernoSmoke")
			local dr = B.Particles.drip(P.rgb(255, 120, 20), 2)
			b:emitter(b:fxVolume(Vector3.new(HW - 0.4, 0.1, D - 0.4), CFrame.new(0, headY - H / 2 - 0.05, 0), "DripVolume"), dr, "MagmaDrip")
		end)
		-- luz de fuego que titila (rápida e irregular) + brillo en la cara de golpe + brasa del pomo
		b:light(Vector3.new(0, headY + 0.7, 0), fireC, 2.4, 13, { pulse = { 1.2, 3.4 }, pulseSpeed = 6.5, name = "InfernoFlicker" })
		b:light(Vector3.new(X0 - 0.5, headY, 0), P.rgb(255, 150, 50), 0.9, 6, { pulse = { 0.5, 1.4 }, pulseSpeed = 2.3, name = "StrikeGlow" })
		b:light(Vector3.new(0, py, 0), P.rgb(255, 120, 30), 0.6, 4, { pulse = { 0.3, 0.9 }, pulseSpeed = 1.7, name = "PommelGlow" })

		local embers = B.Particles.ember(fireC, 0)
		embers.Speed = NumberRange.new(6, 13)
		embers.Acceleration = Vector3.new(0, -6, 0)
		embers.SpreadAngle = Vector2.new(70, 70)
		local blast = B.Particles.flame(fireC, 0)
		blast.Speed = NumberRange.new(4, 9)
		blast.SpreadAngle = Vector2.new(65, 65)
		blast.Size = B.seq(0, 0.9, 0.5, 1.7, 1, 0)
		local smoke = B.Particles.smoke(P.rgb(50, 40, 36), 0)
		smoke.Speed = NumberRange.new(2, 4)
		smoke.Size = B.seq(0, 0.8, 1, 2.4)
		local hit = b:impact(CFrame.new(X0 - 0.6, headY, 0), fireC, { sparks = 32, flash = 10, extra = { embers, blast, smoke } })
		hit:FindFirstChild("ImpactExtra1"):SetAttribute("FX_Emit", 28)
		hit:FindFirstChild("ImpactExtra2"):SetAttribute("FX_Emit", 14)
		hit:FindFirstChild("ImpactExtra3"):SetAttribute("FX_Emit", 8)
		b:trail(Vector3.new(0, headY + H / 2, 0), Vector3.new(0, headY - H / 2, 0), P.rgb(255, 224, 120), P.rgb(220, 40, 0), { lifetime = 0.3 })
	end,
}
