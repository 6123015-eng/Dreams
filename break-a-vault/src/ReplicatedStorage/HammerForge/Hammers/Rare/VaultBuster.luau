-- Vault Buster (Rare) — la puerta de una bóveda hecha martillo. Bloque central de hierro negro con un
-- VOLANTE DE BÓVEDA de oro, grande, en cada cara, que gira lento; detrás del aro del volante, un anillo de
-- luz dorada de neón que late (como si el oro de adentro se asomara). Bisel de oro con 10 pernos alrededor.
-- A cada lado, DOS bandas de oro gruesas con estoperoles de diamante, y luego los remates de granito oscuro:
-- dos bloques apilados con biseles gordos, un poco chuecos, con junta oscura hundida y grietas. Las caras
-- de golpe son puertas de bóveda en miniatura: placa con borde de oro, anillos concéntricos hundidos y
-- 4 pernos. Picos de oro arriba. Mango grueso de hierro negro segmentado con bandas de oro, collar
-- octagonal de oro y pomo de oro remachado grande.
return {
	Id = "VaultBuster",
	DisplayName = "Vault Buster",
	Rarity = "Rare",
	Order = 3,
	Theme = "Bank Vault",
	Build = function(b, P, B)
		local A = B.Anatomy
		local headY = A.HeadY

		-- ── estilos ─────────────────────────────────────────────
		local iron = P.metal(P.rgb(40, 38, 40), 0.06) -- hierro negro del centro
		local ironEdge = P.metal(P.rgb(92, 88, 86), 0.1)
		local ironPlate = P.style(P.rgb(52, 48, 48), Enum.Material.DiamondPlate, 0.05)
		local black = P.Blackened
		local gold = P.metal(P.rgb(232, 164, 34), 0.14)
		local goldEdge = P.metal(P.rgb(255, 214, 110), 0.2)
		local goldDeep = P.metal(P.rgb(170, 108, 20), 0.1)
		local stone = P.stone(P.rgb(84, 84, 95), Enum.Material.Granite)
		local stoneDark = P.stone(P.rgb(70, 70, 80), Enum.Material.Granite)
		local stoneEdge = P.stone(P.rgb(138, 138, 150), Enum.Material.Granite)
		local crack = P.stone(P.rgb(34, 32, 38), Enum.Material.Basalt)
		local chrome = P.Chrome
		local goldGlow = P.neon(P.rgb(255, 176, 40), 0.4)

		local glow = {}

		local function oct(len: number, dia: number, cf: CFrame, st, name: string?)
			local s = dia * 0.4142
			local t = dia * 0.2071
			b:box(Vector3.new(dia, len, s), cf, st, name)
			b:box(Vector3.new(s, len, dia), cf, st, name)
			for i = 0, 3 do
				b:box(Vector3.new(t, len, s), cf * CFrame.Angles(0, math.rad(45 + 90 * i), 0) * CFrame.new(dia / 2 - t / 2, 0, 0), st, name)
			end
		end

		-- ── medidas ─────────────────────────────────────────────
		local CW, CH, CD = 1.7, 1.86, 1.86
		local GW, GH = 0.25, 2.1 -- bandas de oro (2 por lado)
		local GG = 0.06 -- ranura entre bandas
		local SX0 = CW / 2 + 2 * GW + GG -- inicio del remate de piedra
		local SW, SH, SD = 0.9, 2.0, 2.0
		local SX1 = SX0 + SW

		b:group("Head", function()
			-- ── bloque central de hierro
			b:bevelBox(Vector3.new(CW, CH, CD), CFrame.new(0, headY, 0), iron, 0.12, { edgeStyle = ironEdge, name = "Core" })
			b:box(Vector3.new(CW - 0.3, 0.05, CD - 0.3), CFrame.new(0, headY + CH / 2 + 0.01, 0), ironPlate, "TopPlate")
			b:box(Vector3.new(CW - 0.3, 0.05, CD - 0.3), CFrame.new(0, headY - CH / 2 - 0.01, 0), ironPlate, "BottomPlate")
			-- picos de oro arriba (cuatrapeados como en el concepto)
			for i, p in { Vector2.new(-0.35, 0.3), Vector2.new(0.4, -0.25) } do
				local base = CFrame.new(p.X, headY + CH / 2 + 0.03, p.Y)
				b:cylY(0.08, 0.36, base, goldDeep, "SpikeBase")
				b:spike(base * CFrame.new(0, 0.03, 0) * CFrame.Angles(0, i * 0.4, 0), 0.38, 0.28, gold)
			end

			-- ── caras de emblema: volante de bóveda que gira, con luz dorada detrás
			B.both(function(s)
				local face = B.faceZ(s, headY, CD / 2)
				-- remaches de oro en las esquinas
				for _, c in { Vector2.new(-1, -1), Vector2.new(1, -1), Vector2.new(1, 1), Vector2.new(-1, 1) } do
					b:rivet(face:PointToWorldSpace(Vector3.new(c.X * (CW / 2 - 0.2), c.Y * (CH / 2 - 0.2), 0.01)), 0.17, goldEdge)
				end
				-- bisel de oro fijo + pernos
				b:cylZ(0.06, 1.68, face * CFrame.new(0, 0, 0.02), ironEdge, "DialBezelBack")
				b:cylZ(0.06, 1.58, face * CFrame.new(0, 0, 0.05), goldDeep, "DialBezel")
				for i = 0, 9 do
					local a = math.pi * 2 * i / 10 + math.pi / 10
					b:ball(0.13, face:PointToWorldSpace(Vector3.new(math.cos(a) * 0.71, math.sin(a) * 0.71, 0.09)), goldEdge, "DialBolt")
				end
				b:cylZ(0.06, 1.3, face * CFrame.new(0, 0, 0.07), black, "DialRecess")
				-- anillo de neón dorado detrás del aro del volante
				table.insert(glow, b:cylZ(0.04, 1.14, face * CFrame.new(0, 0, 0.09), goldGlow, "VaultGlow"))
				b:cylZ(0.04, 0.78, face * CFrame.new(0, 0, 0.1), black, "VaultGlowInner")

				-- volante (gira) — 15% más grande
				local plane = face * CFrame.new(0, 0, 0.17)
				local wheel = {}
				for _, p in b:ring(plane * CFrame.Angles(math.pi / 2, 0, 0), 0.41, 0.13, 12, gold, "DialRing", 0.13) do
					table.insert(wheel, p)
				end
				for i = 0, 5 do
					local a = math.pi * 2 * i / 6
					local dir = Vector3.new(math.cos(a), math.sin(a), 0)
					local sp = b:line(plane:PointToWorldSpace(dir * 0.12), plane:PointToWorldSpace(dir * 0.58), 0.1, 0.1, gold, plane.ZVector, "DialSpoke")
					if sp then
						table.insert(wheel, sp)
					end
					table.insert(wheel, b:ball(0.15, plane:PointToWorldSpace(dir * 0.6), goldEdge, "DialKnob"))
				end
				table.insert(wheel, b:cylZ(0.13, 0.36, plane * CFrame.new(0, 0, 0.03), goldEdge, "DialHub"))
				table.insert(wheel, b:ball(0.18, plane * CFrame.new(0, 0, 0.1), chrome, "DialCenter"))
				b:animate(wheel, plane, { Spin = Vector3.new(0, 0, 0.45) })
			end)

			-- ── 2 bandas de oro + remates de granito (±X)
			B.both(function(sx)
				for bi = 0, 1 do
					local gx = CW / 2 + GW / 2 + bi * (GW + GG)
					b:bevelBox(Vector3.new(GW, GH, GH), CFrame.new(sx * gx, headY, 0), gold, 0.08, { edges = "X", edgeStyle = goldEdge, name = "GoldBand" })
					-- estoperoles de diamante (frente y atrás, en la banda de afuera)
					B.both(function(sz)
						for _, y in (if bi == 1 then { 0.5, -0.5 } else {}) do
							b:box(Vector3.new(0.13, 0.13, 0.08), CFrame.new(sx * gx, headY + y, sz * (GH / 2 + 0.01)) * CFrame.Angles(0, 0, math.pi / 4), goldEdge, "Stud")
						end
					end)
				end
				b:box(Vector3.new(GG + 0.02, GH - 0.14, GH - 0.14), CFrame.new(sx * (CW / 2 + GW + GG / 2), headY, 0), black, "BandGroove")

				-- granito: 2 bloques apilados, biseles gordos, un poco chuecos, junta oscura hundida
				local sx0, sx1 = SX0 + 0.03, SX0 + SW
				local cxm = sx * (sx0 + sx1) / 2
				local seam = 0.1
				local hTop, hBot = SH * 0.52 - seam / 2, SH * 0.48 - seam / 2
				b:box(Vector3.new(SW - 0.12, SH - 0.14, SD - 0.14), CFrame.new(cxm, headY, 0), crack, "Mortar")
				local topCF = CFrame.new(cxm, headY + SH / 2 - hTop / 2, 0) * CFrame.Angles(0.02 * sx, 0, 0.025 * sx)
				local botCF = CFrame.new(cxm + sx * 0.02, headY - SH / 2 + hBot / 2, 0) * CFrame.Angles(-0.015 * sx, 0, -0.02 * sx)
				b:bevelBox(Vector3.new(sx1 - sx0, hTop, SD), topCF, stone, 0.17, { edgeStyle = stoneEdge, name = "Granite" })
				b:bevelBox(Vector3.new(sx1 - sx0 - 0.04, hBot, SD - 0.04), botCF, stoneDark, 0.17, { edgeStyle = stoneEdge, name = "Granite" })
				-- grietas en las caras ±Z del granito
				B.both(function(sz)
					local f = B.faceZ(sz, headY, SD / 2 + 0.008)
					local n = f.LookVector
					local function pt(x, y)
						return f:PointToWorldSpace(Vector3.new(sx * sz * x, y, 0))
					end
					if sz > 0 then
						b:polyline({ pt(sx0 + 0.66, 0.84), pt(sx0 + 0.5, 0.62), pt(sx0 + 0.58, 0.44), pt(sx0 + 0.4, 0.22) }, 0.05, 0.03, crack, n, false, "Crack")
					else
						b:polyline({ pt(sx0 + 0.18, -0.24), pt(sx0 + 0.36, -0.42), pt(sx0 + 0.3, -0.62), pt(sx0 + 0.5, -0.84) }, 0.05, 0.03, crack, n, false, "Crack")
					end
				end)

				-- cara de golpe: puerta de bóveda (placa con borde de oro + anillos hundidos + 4 pernos)
				local fx = sx1 + 0.02
				b:bevelBox(Vector3.new(0.12, SH - 0.3, SD - 0.3), CFrame.new(sx * fx, headY, 0), gold, 0.1, { edges = "X", edgeStyle = goldEdge, name = "VaultDoorRim" })
				local function disc(d, out, st, name)
					return b:cylinder(0.06, d, CFrame.new(sx * (fx + out), headY, 0), st, name)
				end
				disc(1.3, 0.04, black, "VaultDoor")
				disc(1.0, 0.06, goldDeep, "VaultDoorRing")
				disc(0.86, 0.075, black, "VaultDoorRing")
				disc(0.5, 0.09, goldEdge, "VaultDoorRing")
				disc(0.36, 0.105, black, "VaultDoorHub")
				disc(0.18, 0.12, chrome, "VaultDoorCore")
				for i = 0, 3 do
					local a = math.pi / 4 + i * math.pi / 2
					b:ball(0.15, Vector3.new(sx * (fx + 0.07), headY + math.cos(a) * 0.58, math.sin(a) * 0.58), goldEdge, "VaultDoorBolt")
				end
			end)
		end)

		-- ── mango ───────────────────────────────────────────────
		b:group("Shaft", function()
			local bottom, top = A.ShaftBottom + 0.27, headY - CH / 2
			b:cylY(top - bottom, 0.52, CFrame.new(0, (top + bottom) / 2, 0), black, "Shaft")
			-- collar octagonal de oro
			oct(0.42, 0.86, CFrame.new(0, top - 0.21, 0), gold, "Collar")
			b:disc(CFrame.new(0, top - 0.44, 0), 0.76, 0.06, goldEdge, "CollarLip")
			b:disc(CFrame.new(0, top - 0.02, 0), 0.94, 0.05, goldDeep, "CollarTop")
			-- segmentos de hierro con arista
			for _, y in { 1.02, 0.5, -0.02, -0.54 } do
				b:disc(CFrame.new(0, y, 0), 0.62, 0.36, iron, "GripSeg")
			end
			-- bandas de oro
			for _, y in { 0.76, 0.24, -0.28 } do
				b:disc(CFrame.new(0, y, 0), 0.68, 0.15, gold, "GoldBand")
				b:disc(CFrame.new(0, y, 0), 0.72, 0.05, goldEdge, "GoldBandRidge")
			end
		end)

		-- ── pomo ────────────────────────────────────────────────
		b:group("Pommel", function()
			local py = A.PommelY + 0.2
			oct(0.5, 1.02, CFrame.new(0, py, 0), gold, "Pommel")
			b:disc(CFrame.new(0, py + 0.28, 0), 0.9, 0.07, goldEdge, "PommelBevel")
			b:disc(CFrame.new(0, py - 0.28, 0), 0.9, 0.07, goldDeep, "PommelBevel")
			b:cylY(0.07, 0.62, CFrame.new(0, py - 0.34, 0), black, "PommelCap")
			for _, a in { 0, math.pi / 2, math.pi, 3 * math.pi / 2 } do
				b:rivet(Vector3.new(math.cos(a) * 0.51, py, math.sin(a) * 0.51), 0.15, chrome)
			end
		end)

		-- ── efectos ─────────────────────────────────────────────
		b:pulse(glow, 0.25, 0.65, 0.7)
		b:light(Vector3.new(0, headY, 0), P.rgb(255, 190, 80), 1.1, 9, { pulse = { 0.6, 1.6 }, pulseSpeed = 0.7 })
		local vol = b:fxVolume(Vector3.new(SX1 * 2, GH, GH), CFrame.new(0, headY, 0), "GoldGlints")
		local gl = B.Particles.sparkle(P.rgb(255, 214, 110), 7)
		gl.Size = B.seq(0, 0, 0.25, 0.3, 1, 0)
		gl.Speed = NumberRange.new(0, 0.15)
		b:emitter(vol, gl, "GoldSparkle")

		-- golpe: chispas doradas + monedas brillantes + polvo de piedra
		local coins = B.Particles.sparkle(P.rgb(255, 220, 110), 0)
		coins.Speed = NumberRange.new(6, 12)
		coins.Acceleration = Vector3.new(0, -22, 0)
		coins.Size = B.seq(0, 0.45, 1, 0.1)
		coins.Lifetime = NumberRange.new(0.5, 0.9)
		local dust = B.Particles.smoke(P.rgb(150, 144, 150), 0)
		b:impact(CFrame.new(-(SX1 + 0.25), headY, 0), P.rgb(255, 200, 70), {
			sparks = 24,
			flash = 6,
			extra = { coins, dust },
		})
		b:trail(Vector3.new(0, headY + GH / 2, 0), Vector3.new(0, headY - GH / 2, 0), P.rgb(255, 236, 160), P.rgb(210, 130, 20), { lifetime = 0.22 })
	end,
}
