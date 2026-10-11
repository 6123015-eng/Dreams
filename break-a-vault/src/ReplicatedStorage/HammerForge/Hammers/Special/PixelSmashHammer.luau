-- Pixel Smash Hammer (Special) — un martillo salido de un videojuego retro: todo es VOXEL.
-- Al centro, un cubo negro con marco de metal gris y escuadras en las esquinas; en ambas caras, una
-- CALAVERA de píxeles de neón cian/blanco con contorno morado. A cada lado, racimos de cubos de cristal en
-- degradado cian → azul → morado → rosa (el izquierdo grande y chueco, el derecho más chico), con un núcleo
-- de neón adentro que brilla por las rendijas entre cubos; algunos píxeles están "encendidos", otros parpadean
-- y unos cambian de color como arcoíris. Cubitos sueltos flotan y giran alrededor de la cabeza.
-- Mango de cubos apilados (cristal con núcleo de neón) en degradado, collar de cubos rosas y pomo de 2×2×2.
-- FX: destellos de píxel cian/rosa, cubos flotando, luz que cambia de color.
return {
	Id = "PixelSmashHammer",
	DisplayName = "Pixel Smash Hammer",
	Rarity = "Special",
	Order = 7,
	Theme = "Arcade Vault",
	Build = function(b, P, B)
		local A = B.Anatomy
		local headY = A.HeadY + 0.1
		local TAU = math.pi * 2
		local rnd = B.rng(77)

		-- ── colores ─────────────────────────────────────────────
		local C = {
			P.rgb(70, 230, 255), -- cian
			P.rgb(60, 160, 255), -- celeste
			P.rgb(72, 92, 255), -- azul
			P.rgb(140, 72, 255), -- violeta
			P.rgb(196, 70, 255), -- morado
			P.rgb(255, 80, 214), -- rosa
		}
		local cyan, pink, purple = C[1], C[6], C[5]
		local dark = P.metal(P.rgb(22, 20, 34), 0.08)
		local darkEdge = P.metal(P.rgb(70, 66, 96), 0.16)
		local frame = P.metal(P.rgb(118, 120, 136), 0.2)
		local frameBright = P.metal(P.rgb(176, 180, 196), 0.26)
		-- cristal profundo casi opaco (saturado y oscuro) → contraste con los píxeles de neón
		local function glassOf(c: Color3)
			return P.glass(P.darken(P.vivid(c, 0.15), 0.45), 0.04, 0.28)
		end
		local function pickColor(bias: number): Color3
			-- bias 0..1 empuja hacia cian (0) o rosa (1)
			local r = math.clamp(rnd() * 0.75 + bias * 0.5 - 0.12, 0, 0.999)
			return C[math.floor(r * #C) + 1]
		end

		-- ── voxel: cubo de cristal (o neón encendido) ─────────
		local lit, blinkers, rainbow = {}, {}, {}
		local function voxel(pos: Vector3, size: number, c: Color3, mode: string?)
			local st = if mode == "neon" then P.neon(P.darken(c, 0.08)) else glassOf(c)
			local p = b:box(Vector3.new(size, size, size), CFrame.new(pos), st, if mode == "neon" then "PixelLit" else "Voxel")
			if mode == "neon" then
				table.insert(lit, p)
			end
			return p
		end

		-- racimo de voxeles: solo la cáscara; núcleo de neón adentro
		local function cluster(cx: number, nx: number, ny: number, nz: number, v: number, dirX: number, bias: number, coreC: Color3, seedSkip)
			local x0 = cx - (nx - 1) * v / 2
			for ix = 0, nx - 1 do
				for iy = 0, ny - 1 do
					for iz = 0, nz - 1 do
						local surface = ix == 0 or ix == nx - 1 or iy == 0 or iy == ny - 1 or iz == 0 or iz == nz - 1
						local outer = (dirX > 0 and ix == nx - 1) or (dirX < 0 and ix == 0)
						local cornerY = iy == 0 or iy == ny - 1
						local cornerZ = iz == 0 or iz == nz - 1
						-- quita esquinas para silueta de "blob" pixelado
						local skip = (cornerY and cornerZ and (outer or rnd() < 0.5)) or (surface and seedSkip(ix, iy, iz))
						if surface and not skip then
							local pos = Vector3.new(x0 + ix * v, headY + (iy - (ny - 1) / 2) * v, (iz - (nz - 1) / 2) * v)
							local jitter = Vector3.new(rnd(-0.02, 0.02), rnd(-0.02, 0.02), rnd(-0.02, 0.02))
							local yBias = bias + (iy / (ny - 1) - 0.5) * -0.35
							local r = rnd()
							local mode = if r < 0.28 then "neon" else nil
							local p = voxel(pos + jitter, v - 0.035, pickColor(yBias), mode)
							if mode == "neon" and r < 0.035 then
								table.insert(rainbow, p)
							elseif mode == nil and r > 0.9 then
								table.insert(blinkers, p)
							end
						end
					end
				end
			end
			-- núcleo de energía
			local core = b:box(Vector3.new(nx * v - 0.3, ny * v - 0.3, nz * v - 0.3), CFrame.new(cx, headY, 0), P.neon(P.darken(coreC, 0.15)), "VoxelCore")
			return core
		end

		local CW, CH, CD = 1.66, 1.98, 1.98
		local v = 0.42
		local LX = -CW / 2 - 1.5 * v + 0.02 -- centro del racimo izquierdo (3 capas)
		local RX = CW / 2 + v - 0.02 -- centro del racimo derecho (2 capas)

		b:group("Head", function()
			-- ── cubo central negro con marco metálico ─────────
			b:bevelBox(Vector3.new(CW, CH, CD), CFrame.new(0, headY, 0), dark, 0.1, { edges = "all", edgeStyle = darkEdge, name = "Core" })
			B.both(function(s)
				local f = B.faceZ(s, headY, CD / 2)
				-- marco gris
				for _, sx in { -1, 1 } do
					b:box(Vector3.new(0.12, CH + 0.04, 0.08), f * CFrame.new(sx * (CW / 2 - 0.04), 0, 0.03), frame, "FrameBar")
					b:box(Vector3.new(0.04, CH + 0.04, 0.09), f * CFrame.new(sx * (CW / 2 - 0.1), 0, 0.04), frameBright, "FrameShine")
				end
				for _, sy in { -1, 1 } do
					b:box(Vector3.new(CW - 0.2, 0.1, 0.07), f * CFrame.new(0, sy * (CH / 2 - 0.04), 0.03), frame, "FrameBar")
				end
				-- escuadras en las esquinas (placa en L + perno)
				for _, sx in { -1, 1 } do
					for _, sy in { -1, 1 } do
						local cx, cy = sx * (CW / 2 - 0.2), sy * (CH / 2 - 0.2)
						b:box(Vector3.new(0.34, 0.08, 0.06), f * CFrame.new(cx - sx * 0.02, cy + sy * 0.1, 0.08), frameBright, "Bracket")
						b:box(Vector3.new(0.08, 0.34, 0.06), f * CFrame.new(cx + sx * 0.1, cy - sy * 0.02, 0.08), frameBright, "Bracket")
					end
				end
				-- marco interior morado de neón (pantalla)
				b:box(Vector3.new(1.34, 1.56, 0.04), f * CFrame.new(0, 0, 0.02), P.neon(P.darken(purple, 0.25)), "ScreenGlow")
				b:box(Vector3.new(1.24, 1.46, 0.05), f * CFrame.new(0, 0, 0.03), P.metal(P.rgb(12, 10, 24), 0.05), "Screen")
				-- calavera de píxeles
				b:pixels(f * CFrame.new(0, 0.02, 0.07), {
					"..ppppp..",
					".pWWWWWp.",
					"pWCCCCCWp",
					"pCCCCCCCp",
					"pC..C..Cp",
					"pC..C..Cp",
					"pCCC.CCCp",
					".pCCCCCp.",
					"..C.C.C..",
					"..BBBBB..",
				}, 0.13, 0.05, {
					W = P.neon(P.rgb(190, 240, 255)),
					C = P.neon(P.rgb(40, 190, 255)),
					B = P.neon(P.rgb(60, 110, 255)),
					p = P.neon(P.darken(P.rgb(150, 80, 255), 0.1)),
				})
				-- ojos: brillo rosa al fondo de las cuencas
				for _, ex in { -1, 1 } do
					local eye = b:box(Vector3.new(0.2, 0.2, 0.03), f * CFrame.new(ex * 0.26, 0.02 - 0.065, 0.055), P.neon(pink), "SkullEye")
					b:pulse({ eye }, 0, 0.7, 1.4, if ex > 0 then 0 else 0.35)
				end
			end)
			-- arriba/abajo: ranura morada
			for _, sy in { -1, 1 } do
				b:box(Vector3.new(CW - 0.3, 0.04, 0.24), CFrame.new(0, headY + sy * (CH / 2 + 0.005), 0), P.neon(purple), "TopSlot")
				b:box(Vector3.new(CW - 0.2, 0.05, 0.08), CFrame.new(0, headY + sy * (CH / 2 + 0.02), 0.2), frame, "TopRail")
				b:box(Vector3.new(CW - 0.2, 0.05, 0.08), CFrame.new(0, headY + sy * (CH / 2 + 0.02), -0.2), frame, "TopRail")
			end

			-- ── racimos de voxeles ────────────────────────────
			local lcore = cluster(LX, 3, 5, 5, v, -1, 0.4, P.rgb(110, 90, 255), function(ix, iy, iz)
				return (ix == 0 and ((iy == 1 and iz == 4) or (iy == 3 and iz == 0) or (iy == 4 and iz == 2))) or (ix == 1 and iy == 4 and iz == 0)
			end)
			local rcore = cluster(RX, 2, 4, 4, v, 1, 0.55, P.rgb(170, 80, 255), function(ix, iy, iz)
				return ix == 1 and ((iy == 0 and iz == 2) or (iy == 2 and iz == 3))
			end)
			b:pulse({ lcore, rcore }, 0, 0.3, 0.9)
			-- cubos que sobresalen del racimo (rompen la silueta)
			local extras = {
				{ LX - 1.5 * v - 0.08, headY + 0.2, 0.2, 0.34, 1 },
				{ LX - 1.5 * v - 0.06, headY - 0.45, -0.4, 0.3, 6 },
				{ LX - 0.3, headY + 2.5 * v + 0.12, 0.35, 0.3, 2 },
				{ LX + 0.25, headY + 2.5 * v + 0.08, -0.5, 0.26, 5 },
				{ LX - 0.4, headY - 2.5 * v - 0.08, -0.2, 0.3, 3 },
				{ LX, headY + 0.6, 2.5 * v + 0.08, 0.28, 6 },
				{ LX - 0.25, headY - 0.3, -2.5 * v - 0.08, 0.3, 4 },
				{ RX + v + 0.06, headY + 0.25, -0.3, 0.3, 6 },
				{ RX + v + 0.05, headY - 0.4, 0.35, 0.26, 2 },
				{ RX, headY + 2 * v + 0.08, 0.1, 0.28, 4 },
				{ RX + 0.1, headY - 2 * v - 0.06, -0.35, 0.26, 1 },
			}
			for i, e in extras do
				voxel(Vector3.new(e[1], e[2], e[3]), e[4], C[e[5]], if i % 3 == 0 then "neon" else nil)
			end
			-- caras de golpe: placa de píxeles "power-up" (cuadro brillante en el centro del racimo)
			local lf = B.faceX(-1, -(LX - 1.5 * v) + 0.01, headY)
			b:pixels(lf * CFrame.new(0, 0, 0.0), { ".WW.", "WCCW", "WCCW", ".WW." }, 0.14, 0.05, { W = P.neon(P.rgb(210, 245, 255)), C = P.neon(pink) })
			local rf = B.faceX(1, RX + v - 0.01, headY)
			b:pixels(rf * CFrame.new(0, 0, 0.0), { ".W.", "WCW", ".W." }, 0.14, 0.05, { W = P.neon(P.rgb(210, 245, 255)), C = P.neon(cyan) })
		end)

		-- ── cubitos flotando ────────────────────────────────────
		b:group("FloatingPixels", function()
			local spots = {
				{ -2.45, 1.2, 0.5, 0.2, 1 }, { -2.2, -1.0, -0.6, 0.16, 6 }, { -1.1, 1.75, 0.9, 0.18, 2 },
				{ 0.4, 1.55, -0.9, 0.15, 6 }, { 1.95, 1.3, 0.6, 0.2, 1 }, { 2.25, -0.6, -0.5, 0.17, 5 },
				{ -0.9, -1.55, 1.0, 0.15, 3 }, { 1.2, -1.45, 0.9, 0.18, 6 },
			}
			for i, sp in spots do
				local pos = Vector3.new(sp[1], headY + sp[2], sp[3])
				local cube = b:box(Vector3.new(sp[4], sp[4], sp[4]), CFrame.new(pos) * CFrame.Angles(0.4 * i, 0.7 * i, 0), P.neon(C[sp[5]]), "FloatPixel")
				b:animate({ cube }, pos, { Spin = Vector3.new(0.5, 1.1, 0.3) * (if i % 2 == 0 then 1 else -1), Bob = Vector3.new(0, 0.14, 0), BobSpeed = 0.4 + (i % 3) * 0.12, Phase = i * 0.37 })
				if i == 4 or i == 7 then
					table.insert(rainbow, cube)
				end
			end
			-- órbita lenta de cubitos alrededor de la cabeza
			local ocf = CFrame.new(0, headY, 0) * CFrame.Angles(math.rad(76), 0, math.rad(-8))
			local orbit = {}
			for i = 0, 3 do
				local a = TAU * i / 4 + 0.4
				table.insert(orbit, b:box(Vector3.new(0.14, 0.14, 0.14), ocf:PointToWorldSpace(Vector3.new(math.cos(a) * 2.7, 0, math.sin(a) * 1.5)), P.neon(if i % 2 == 0 then cyan else pink), "OrbitPixel"))
			end
			b:animate(orbit, ocf, { Spin = Vector3.new(0, 0.7, 0) })
		end)

		-- ── mango de cubos apilados ─────────────────────────────
		b:group("Shaft", function()
			local top = headY - CH / 2
			-- collar de cubos rosas/morados (2×2)
			for _, sx in { -1, 1 } do
				for _, sz in { -1, 1 } do
					voxel(Vector3.new(sx * 0.19, top - 0.18, sz * 0.19), 0.36, if sx * sz > 0 then pink else purple, if sx > 0 and sz > 0 then "neon" else nil)
				end
			end
			b:box(Vector3.new(0.5, 0.36, 0.5), CFrame.new(0, top - 0.18, 0), P.neon(P.darken(pink, 0.2)), "CollarCore")
			-- columna de cubos: cristal + núcleo de neón, degradado cian → azul → violeta
			local yTop, yBot = top - 0.36, A.ShaftBottom - 0.05
			local n = 7
			local step = (yTop - yBot) / n
			for i = 0, n - 1 do
				local y = yTop - step * (i + 0.5)
				local t = i / (n - 1)
				local c = if t < 0.3 then C[1] elseif t < 0.55 then C[2] elseif t < 0.8 then C[3] else C[4]
				local off = Vector3.new(if i % 2 == 0 then 0.02 else -0.02, 0, if i % 3 == 0 then 0.02 else -0.015)
				local sz = step - 0.04
				b:box(Vector3.new(0.52, sz, 0.52), CFrame.new(Vector3.new(0, y, 0) + off) * CFrame.Angles(0, if i % 2 == 0 then 0 else math.rad(4), 0), glassOf(c), "ShaftVoxel")
				local core = b:box(Vector3.new(0.34, sz - 0.1, 0.34), CFrame.new(Vector3.new(0, y, 0) + off), P.neon(P.darken(c, 0.1)), "ShaftCore")
				if i % 3 == 1 then
					table.insert(blinkers, core)
				end
				-- pixelito saliente en algunos cubos
				if i % 2 == 1 then
					local sgn = if i % 4 == 1 then 1 else -1
					voxel(Vector3.new(sgn * 0.31, y, -sgn * 0.08), 0.13, C[(i % #C) + 1], "neon")
				end
			end
		end)

		-- ── pomo: bloque de 2×2×2 cubos rosas/morados ───────────
		b:group("Pommel", function()
			local y = A.PommelY - 0.14
			local k = 0.24
			for _, sx in { -1, 1 } do
				for _, sy in { -1, 1 } do
					for _, sz in { -1, 1 } do
						local c = if sy > 0 then (if sx * sz > 0 then purple else pink) else (if sx * sz > 0 then pink else C[4])
						voxel(Vector3.new(sx * k, y + sy * k, sz * k), 0.46, c, if sx < 0 and sy < 0 and sz > 0 then "neon" else nil)
					end
				end
			end
			b:box(Vector3.new(0.7, 0.7, 0.7), CFrame.new(0, y, 0), P.neon(P.darken(purple, 0.15)), "PommelCore")
			voxel(Vector3.new(0, y - 0.54, 0), 0.22, cyan, "neon")
		end)

		-- ── animación de color ─────────────────────────────────
		b:hue(rainbow, 0.18)
		b:pulse(blinkers, 0, 0.8, 1.6)
		for i, p in lit do
			if i % 4 == 0 then
				b:pulse({ p }, 0, 0.5, 1.2, i * 0.13)
			end
		end

		-- ── efectos ─────────────────────────────────────────────
		b:group("FX", function()
			local vol = b:fxVolume(Vector3.new(4.4, 2.4, 2.4), CFrame.new(-0.2, headY, 0), "PixelVolume")
			local px = B.Particles.sparkle(cyan, 10)
			px.Size = B.seq(0, 0, 0.2, 0.26, 1, 0)
			b:emitter(vol, px, "PixelSparkle")
			local pk = B.Particles.orb(pink, 5)
			pk.Size = B.seq(0, 0, 0.3, 0.3, 1, 0)
			b:emitter(vol, pk, "PinkGlow")
			local lv = b:fxVolume(Vector3.new(1.3, 2.1, 2.1), CFrame.new(LX, headY, 0), "ClusterVolume")
			local up = B.Particles.sparkle(P.rgb(150, 110, 255), 6)
			up.Acceleration = Vector3.new(0, 1.5, 0)
			up.Size = B.seq(0, 0, 0.2, 0.2, 1, 0)
			b:emitter(lv, up, "ClusterPixels")
		end)
		b:light(Vector3.new(0, headY, 0), purple, 1.0, 9, { pulse = { 0.6, 1.3 }, pulseSpeed = 0.9, name = "ScreenLight" })
		b:light(Vector3.new(LX - 0.6, headY + 1.2, 0), cyan, 0.5, 5, { pulse = { 0.3, 0.7 }, pulseSpeed = 1.3, name = "ClusterLight" })

		-- impacto: chispas cian + lluvia de píxeles rosa/cian + destello
		local burstC = B.Particles.sparkle(cyan, 0)
		burstC.Speed = NumberRange.new(7, 13)
		burstC.Size = B.seq(0, 0.45, 1, 0)
		local burstP = B.Particles.orb(pink, 0)
		burstP.Speed = NumberRange.new(5, 10)
		burstP.Size = B.seq(0, 0.3, 1, 0)
		burstP.Lifetime = NumberRange.new(0.4, 0.8)
		burstP.Acceleration = Vector3.new(0, -12, 0)
		local hit = b:impact(CFrame.new(LX - 1.5 * v - 0.3, headY, 0), P.rgb(140, 120, 255), { sparks = 22, flash = 8, extra = { burstC, burstP } })
		hit:FindFirstChild("ImpactExtra1"):SetAttribute("FX_Emit", 22)
		hit:FindFirstChild("ImpactExtra2"):SetAttribute("FX_Emit", 16)
		b:trail(Vector3.new(0, headY + CH / 2 + 0.25, 0), Vector3.new(0, headY - CH / 2 - 0.25, 0), cyan, pink, { lifetime = 0.24 })
	end,
}
