-- Elite Breacher (Epic) — el martillo de la guardia real del banco: dos bloques de MÁRMOL blanco
-- con aristas pulidas, unidos por un núcleo negro con el ESCUDO de oro en ambas caras: marco de oro,
-- filo de luz dorada y la CORONA de oro sobre placa negra (con halo que late). Alas de oro de cuatro
-- plumas se abren desde el escudo sobre el mármol. Remates con tapas de oro facetadas en capas y
-- puntas de oro colgando; picos de oro en los bloques y un diamante de oro que flota y gira sobre la
-- cabeza. Mango negro laqueado con anillos de oro, collar y pomo octagonales de oro con corona.
-- FX: destellos dorados, motas cálidas, luz cálida pulsante, impacto de oro.
return {
	Id = "EliteBreacher",
	DisplayName = "Elite Breacher",
	Rarity = "Epic",
	Order = 4,
	Theme = "Royal Vault",
	Build = function(b, P, B)
		local A = B.Anatomy
		local headY = A.HeadY + 0.1

		-- ── estilos ─────────────────────────────────────────────
		local marble = P.stone(P.rgb(184, 180, 176), Enum.Material.Marble)
		local marbleEdge = P.stone(P.rgb(214, 212, 206), Enum.Material.Marble)
		local marbleVein = P.stone(P.rgb(140, 134, 128), Enum.Material.Marble)
		local gold = P.metal(P.rgb(232, 160, 34), 0.12)
		local goldEdge = P.metal(P.rgb(255, 206, 96), 0.16)
		local goldDeep = P.metal(P.rgb(186, 118, 22), 0.12)
		local black = P.metal(P.rgb(26, 24, 28), 0.08)
		local blackEdge = P.metal(P.rgb(70, 64, 60), 0.1)
		local warm = P.rgb(255, 196, 70)
		local goldNeon = P.neon(P.rgb(255, 190, 60))
		
		-- ── helpers ─────────────────────────────────────────────
		local function along(pos: Vector3, dir: Vector3): CFrame
			local up = dir.Unit
			local ref = if math.abs(up.Y) < 0.9 then Vector3.yAxis else Vector3.xAxis
			local vx = up:Cross(ref).Unit
			local vz = vx:Cross(up).Unit
			return CFrame.fromMatrix(pos, vx, up, vz)
		end

		-- ── medidas ────────────────────────────────────────────
		local CW, CH, CD = 1.44, 1.9, 1.9 -- núcleo negro
		local MX0, MX1 = 0.7, 1.72 -- bloques de mármol
		local EW, EH, ED = MX1 - MX0, 2.06, 2.0
		local ex = (MX0 + MX1) / 2
		local outerX = MX1 + 0.62

		local halos = {}

		b:group("Head", function()
			b:bevelBox(Vector3.new(CW, CH, CD), CFrame.new(0, headY, 0), black, 0.1, { edges = "X", edgeStyle = blackEdge, name = "Core" })

			-- ── bloques de mármol ──────────────────────────────
			B.both(function(sx)
				local mcf = CFrame.new(sx * ex, headY, 0)
				b:bevelBox(Vector3.new(EW, EH, ED), mcf, marble, 0.16, { edges = "Z", edgeStyle = marbleEdge, name = "Marble" })
				-- vetas del mármol (ambas caras)
				for _, sz in { 1, -1 } do
					local z = sz * (ED / 2 + 0.004)
					b:box(Vector3.new(0.04, 0.7, 0.04), CFrame.new(sx * (ex + 0.25), headY + 0.4, z) * CFrame.Angles(0, 0, sx * 0.6), marbleVein, "Vein")
					-- bandas negro/oro horizontales bajo las alas
					b:box(Vector3.new(EW - 0.14, 0.14, 0.06), CFrame.new(sx * ex, headY - 0.58, sz * (ED / 2 + 0.02)), gold, "BandGold")
					b:box(Vector3.new(EW - 0.14, 0.04, 0.07), CFrame.new(sx * ex, headY - 0.5, sz * (ED / 2 + 0.025)), goldEdge, "BandShine")
					b:box(Vector3.new(EW - 0.14, 0.12, 0.05), CFrame.new(sx * ex, headY - 0.73, sz * (ED / 2 + 0.015)), black, "BandBlack")
				end
				-- marco de oro entre núcleo y mármol
				b:bevelBox(Vector3.new(0.14, EH + 0.08, ED + 0.08), CFrame.new(sx * (MX0 + 0.06), headY, 0), gold, 0.05, { edges = "X", edgeStyle = goldEdge, name = "Trim" })

				-- tapas de golpe de oro facetadas en capas
				b:bevelBox(Vector3.new(0.14, 1.96, 1.92), CFrame.new(sx * (MX1 + 0.07), headY, 0), goldDeep, 0.42, { edges = "X", edgeStyle = goldEdge, name = "CapPlate" })
				b:bevelBox(Vector3.new(0.14, 1.6, 1.56), CFrame.new(sx * (MX1 + 0.2), headY, 0), gold, 0.34, { edges = "X", edgeStyle = goldEdge, name = "CapPlate2" })
				b:pyramid(CFrame.new(sx * (MX1 + 0.26), headY, 0) * CFrame.Angles(0, 0, -sx * math.pi / 2), 0.36, 1.16, 4, goldEdge, "CapFacet", 0.06)
				-- punta de oro colgando bajo el remate
				b:pyramid(along(Vector3.new(sx * (MX1 - 0.12), headY - EH / 2 + 0.04, 0), Vector3.new(sx * 0.35, -1, 0)), 0.5, 0.4, 3, gold, "DropSpike")
				-- pico de oro arriba del mármol, inclinado hacia afuera
				b:box(Vector3.new(0.46, 0.1, 0.46), CFrame.new(sx * (ex + 0.12), headY + EH / 2 + 0.03, 0), goldDeep, "SpikeBase")
				b:pyramid(along(Vector3.new(sx * (ex + 0.12), headY + EH / 2 + 0.05, 0), Vector3.new(sx * 0.3, 1, 0)), 0.62, 0.34, 4, gold, "TopSpike")
			end)

			-- ── escudo con corona en ambas caras ───────────────
			-- escudo = rectángulo (1 pieza) + trapecio inferior en punta (pocas piezas)
			local function shieldLayer(cf: CFrame, k: number, t: number, st, name: string)
				local top, mid, bot = 0.74 * k, -0.28 * k, -0.74 * k
				b:box(Vector3.new(1.32 * k, top - mid, t), cf * CFrame.new(0, (top + mid) / 2, 0), st, name)
				b:shape(cf, { Vector2.new(0.66 * k, mid + 0.001), Vector2.new(0.3 * k, bot), Vector2.new(-0.3 * k, bot), Vector2.new(-0.66 * k, mid + 0.001) }, t, st, name)
			end
			B.both(function(s)
				local face = B.faceZ(s, headY + 0.06, ED / 2 + 0.06)
				shieldLayer(face, 1, 0.1, gold, "ShieldFrame")
				shieldLayer(face * CFrame.new(0, 0, 0.035), 0.89, 0.05, goldNeon, "ShieldGlow")
				shieldLayer(face * CFrame.new(0, 0, 0.06), 0.83, 0.06, black, "ShieldPlate")
				-- remaches de oro en las esquinas superiores
				b:rivet(face:PointToWorldSpace(Vector3.new(-0.5, 0.6, 0.06)), 0.09, goldEdge)
				b:rivet(face:PointToWorldSpace(Vector3.new(0.5, 0.6, 0.06)), 0.09, goldEdge)
				-- halo de corona (late) + corona + barra
				local cf = face * CFrame.new(0, 0.1, 0.1)
				b:shape(cf * CFrame.new(0, 0, 0.03), B.Shapes.crown(0.64, 0.48), 0.05, goldEdge, "Crown")
				b:box(Vector3.new(0.64, 0.12, 0.06), cf * CFrame.new(0, -0.38, 0.03), goldEdge, "CrownBar")
				for _, x in { -0.32, 0, 0.32 } do
					table.insert(halos, b:ball(0.11, cf:PointToWorldSpace(Vector3.new(x, if x == 0 then 0.26 else 0.17, 0.05)), goldNeon, "CrownJewel"))
				end

				-- alas de oro: 4 plumas triangulares en capas + brazo superior
				B.both(function(w)
					local function fp(x: number, y: number, z: number): Vector3
						return face:PointToWorldSpace(Vector3.new(w * x, y, z))
					end
					-- plumas anchas (cuadriláteros con punta roma), de arriba hacia abajo, en capas
					local feathers = {
						{ { 0.64, 0.58 }, { 1.36, 0.86 }, { 1.66, 0.7 }, { 0.64, 0.2 }, 0.0, goldEdge },
						{ { 0.64, 0.32 }, { 1.46, 0.36 }, { 1.7, 0.16 }, { 0.64, -0.06 }, 0.03, gold },
						{ { 0.64, 0.06 }, { 1.34, -0.14 }, { 1.5, -0.38 }, { 0.64, -0.32 }, 0.06, goldEdge },
					}
					for _, f in feathers do
						local pts = {}
						for k = 1, 4 do
							table.insert(pts, Vector2.new(w * f[k][1], f[k][2]))
						end
						b:shape(face * CFrame.new(0, 0, f[5]), pts, 0.05, f[6], "Feather")
					end
					b:line(fp(0.62, 0.6, 0.02), fp(1.4, 0.9, 0.02), 0.1, 0.07, goldEdge, face.ZVector, "WingArm")
				end)
			end)

			-- arriba del núcleo: pedestal + diamante de oro flotando y girando
			local ty = headY + CH / 2
			b:bevelBox(Vector3.new(0.7, 0.14, 0.9), CFrame.new(0, ty + 0.07, 0), gold, 0.05, { edges = "Y", edgeStyle = goldEdge, name = "Plinth" })
			table.insert(halos, b:cylY(0.04, 0.42, CFrame.new(0, ty + 0.16, 0), goldNeon, "PlinthGlow"))
			local dy = ty + 0.62
			local diamond = {}
			for _, p in b:pyramid(CFrame.new(0, dy, 0), 0.46, 0.4, 4, goldEdge, "Diamond") do
				table.insert(diamond, p)
			end
			for _, p in b:pyramid(CFrame.new(0, dy, 0) * CFrame.Angles(math.pi, 0, 0), 0.3, 0.4, 4, gold, "Diamond") do
				table.insert(diamond, p)
			end
			b:animate(diamond, CFrame.new(0, dy, 0), { Spin = Vector3.new(0, 1.2, 0), Bob = Vector3.new(0, 0.08, 0), BobSpeed = 0.6 })
			-- abajo
			b:bevelBox(Vector3.new(0.9, 0.08, 1.2), CFrame.new(0, headY - CH / 2 - 0.03, 0), goldDeep, 0.03, { edges = "Y", edgeStyle = gold, name = "Underplate" })
		end)

		b:pulse(halos, 0.15, 0.8, 1.2)

		-- ── mango ───────────────────────────────────────────────
		b:group("Shaft", function()
			local top = headY - CH / 2 - 0.07
			local bottom = A.ShaftBottom
			b:cylY(top - bottom, 0.4, CFrame.new(0, (top + bottom) / 2, 0), black, "ShaftCore")
			-- collar de oro octagonal en dos pisos
			b:bevelBox(Vector3.new(0.76, 0.26, 0.76), CFrame.new(0, top - 0.13, 0), gold, 0.16, { edges = "Y", edgeStyle = goldEdge, name = "Collar" })
			b:cylY(0.08, 0.56, CFrame.new(0, top - 0.3, 0), black, "CollarGap")
			b:bevelBox(Vector3.new(0.62, 0.16, 0.62), CFrame.new(0, top - 0.42, 0), goldDeep, 0.13, { edges = "Y", edgeStyle = gold, name = "CollarLow" })
			-- agarre negro laqueado con anillos de oro
			local g0, g1 = -1.12, 1.9
			local segs = 5
			local step = (g1 - g0) / segs
			for i = 0, segs - 1 do
				b:cylY(step - 0.1, 0.52, CFrame.new(0, g0 + step * (i + 0.5), 0), black, "Grip")
			end
			for i = 0, segs do
				local y = g0 + step * i
				b:cylY(0.12, 0.6, CFrame.new(0, y, 0), gold, "GripRing")
			end
		end)

		-- ── pomo ────────────────────────────────────────────────
		b:group("Pommel", function()
			local y = A.PommelY - 0.07
			b:bevelBox(Vector3.new(0.9, 0.56, 0.9), CFrame.new(0, y, 0), gold, 0.24, { edges = "Y", edgeStyle = goldEdge, name = "Pommel" })
			b:bevelBox(Vector3.new(0.7, 0.12, 0.7), CFrame.new(0, y - 0.33, 0), black, 0.18, { edges = "Y", edgeStyle = blackEdge, name = "PommelCap" })
			B.both(function(s)
				b:box(Vector3.new(0.26, 0.2, 0.05), B.faceZ(s, y, 0.45 + 0.01), black, "PommelBadge")
				b:pyramid(B.faceZ(s, y - 0.06, 0.45 + 0.03), 0.14, 0.14, 3, goldEdge, "PommelCrown")
			end)
			b:gem(CFrame.new(0, y - 0.42, 0), 0.16, goldEdge, goldNeon)
		end)

		-- ── efectos ─────────────────────────────────────────────
		b:group("FX", function()
			local v = b:fxVolume(Vector3.new(3.8, 2.4, 2.4), CFrame.new(0, headY, 0), "SparkleVolume")
			b:emitter(v, B.Particles.sparkle(P.rgb(255, 214, 110), 10), "GoldSparkle")
			local motes = B.Particles.orb(warm, 4)
			motes.Size = B.seq(0, 0, 0.3, 0.2, 1, 0)
			b:emitter(v, motes, "WarmMotes")
			local d = b:fxVolume(Vector3.new(0.5, 0.6, 0.5), CFrame.new(0, headY + CH / 2 + 0.62, 0), "DiamondVolume")
			b:emitter(d, B.Particles.sparkle(P.rgb(255, 240, 180), 3), "DiamondSparkle")
		end)
		b:light(Vector3.new(0, headY, 0), warm, 1.2, 8, { pulse = { 0.8, 1.7 }, pulseSpeed = 1.2, name = "RoyalGlow" })
		b:light(Vector3.new(0, headY + CH / 2 + 0.62, 0), P.rgb(255, 220, 140), 1, 6, { pulse = { 0.6, 1.4 }, pulseSpeed = 0.6, name = "DiamondGlow" })

		local burst = B.Particles.sparkle(P.rgb(255, 220, 120), 0)
		burst.Speed = NumberRange.new(8, 15)
		burst.Size = B.seq(0, 0.45, 1, 0)
		burst.Lifetime = NumberRange.new(0.3, 0.6)
		local coins = B.Particles.ember(P.rgb(255, 190, 60), 0)
		coins.Speed = NumberRange.new(5, 10)
		coins.Acceleration = Vector3.new(0, -18, 0)
		local hit = b:impact(CFrame.new(-outerX, headY, 0), warm, { sparks = 24, flash = 7, extra = { burst, coins } })
		-- (Builder no acepta EmitCount dentro de props: se fija el atributo directo)
		hit:FindFirstChild("ImpactExtra1"):SetAttribute("FX_Emit", 20)
		hit:FindFirstChild("ImpactExtra2"):SetAttribute("FX_Emit", 14)
		b:trail(Vector3.new(0, headY + CH / 2, 0), Vector3.new(0, headY - CH / 2, 0), P.rgb(255, 238, 176), P.rgb(220, 140, 24), { lifetime = 0.24 })
	end,
}
