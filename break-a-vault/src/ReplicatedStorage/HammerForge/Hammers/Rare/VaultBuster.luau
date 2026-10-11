-- Vault Buster (Rare) — la puerta de una bóveda hecha martillo. Bloque central de hierro negro con un
-- VOLANTE DE BÓVEDA de oro en cada cara que gira lento; detrás del volante, una ranura de luz dorada que late
-- (como si el oro de adentro se asomara). Bisel de oro con pernos alrededor del volante.
-- Bandas de oro gruesas con estoperoles de diamante separan el centro de los remates de ladrillo de piedra
-- (bloques biselados en aparejo cuatrapeado, con grietas) que son las caras de golpe, reforzadas con
-- esquineros de oro. Picos de oro arriba. Mango de hierro negro segmentado con bandas de oro,
-- collar octagonal de oro y pomo de oro remachado.
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
		local stone = P.stone(P.rgb(104, 100, 110), Enum.Material.Slate)
		local stoneDark = P.stone(P.rgb(80, 76, 86), Enum.Material.Slate)
		local stoneEdge = P.stone(P.rgb(156, 152, 164), Enum.Material.Slate)
		local crack = P.stone(P.rgb(34, 32, 38), Enum.Material.Basalt)
		local chrome = P.Chrome
		local goldGlow = P.neon(P.rgb(255, 150, 20))

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
		local GW, GH = 0.26, 2.08 -- bandas de oro
		local gx = CW / 2 + GW / 2
		local SX0 = CW / 2 + GW -- inicio del remate de piedra
		local SW, SH, SD = 0.82, 1.98, 1.98
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
				b:cylZ(0.06, 1.62, face * CFrame.new(0, 0, 0.02), ironEdge, "DialBezelBack")
				b:cylZ(0.06, 1.5, face * CFrame.new(0, 0, 0.05), goldDeep, "DialBezel")
				for i = 0, 5 do
					local a = math.pi * 2 * i / 6 + math.pi / 6
					b:ball(0.14, face:PointToWorldSpace(Vector3.new(math.cos(a) * 0.66, math.sin(a) * 0.66, 0.09)), goldEdge, "DialBolt")
				end
				b:cylZ(0.06, 1.26, face * CFrame.new(0, 0, 0.07), black, "DialRecess")
				-- ranura de luz dorada detrás del volante
				table.insert(glow, b:cylZ(0.04, 1.1, face * CFrame.new(0, 0, 0.09), goldGlow, "VaultGlow"))
				b:cylZ(0.04, 0.92, face * CFrame.new(0, 0, 0.1), black, "VaultGlowInner")

				-- volante (gira)
				local plane = face * CFrame.new(0, 0, 0.16)
				local wheel = {}
				for _, p in b:ring(plane * CFrame.Angles(math.pi / 2, 0, 0), 0.35, 0.12, 12, gold, "DialRing", 0.12) do
					table.insert(wheel, p)
				end
				for i = 0, 5 do
					local a = math.pi * 2 * i / 6
					local dir = Vector3.new(math.cos(a), math.sin(a), 0)
					local sp = b:line(plane:PointToWorldSpace(dir * 0.1), plane:PointToWorldSpace(dir * 0.5), 0.09, 0.09, gold, plane.ZVector, "DialSpoke")
					if sp then
						table.insert(wheel, sp)
					end
					table.insert(wheel, b:ball(0.13, plane:PointToWorldSpace(dir * 0.52), goldEdge, "DialKnob"))
				end
				table.insert(wheel, b:cylZ(0.12, 0.3, plane * CFrame.new(0, 0, 0.03), goldEdge, "DialHub"))
				table.insert(wheel, b:ball(0.16, plane * CFrame.new(0, 0, 0.1), chrome, "DialCenter"))
				b:animate(wheel, plane, { Spin = Vector3.new(0, 0, 0.45) })
			end)

			-- ── bandas de oro + remates de piedra (±X)
			B.both(function(sx)
				b:bevelBox(Vector3.new(GW, GH, GH), CFrame.new(sx * gx, headY, 0), gold, 0.09, { edges = "X", edgeStyle = goldEdge, name = "GoldBand" })
				b:box(Vector3.new(0.05, GH + 0.01, GH - 0.36), CFrame.new(sx * gx, headY, 0), goldDeep, "BandGroove")
				-- estoperoles de diamante (cara frontal, trasera y arriba)
				B.both(function(sz)
					b:box(Vector3.new(0.14, 0.14, 0.08), CFrame.new(sx * gx, headY + 0.45, sz * (GH / 2 + 0.01)) * CFrame.Angles(0, 0, math.pi / 4), goldEdge, "Stud")
					b:box(Vector3.new(0.14, 0.14, 0.08), CFrame.new(sx * gx, headY - 0.45, sz * (GH / 2 + 0.01)) * CFrame.Angles(0, 0, math.pi / 4), goldEdge, "Stud")
				end)

				-- ladrillos de piedra en aparejo cuatrapeado (2 hileras)
				local rows = {
					{ y = headY + SH / 4, split = 0.5 },
					{ y = headY - SH / 4, split = 0.32 },
				}
				for ri, row in rows do
					local x0, x1 = SX0 + 0.02, SX1
					local xm = x0 + row.split
					for bi, seg in { { x0, xm }, { xm, x1 } } do
						local w = seg[2] - seg[1] - 0.04
						local cx = sx * (seg[1] + seg[2]) / 2
						local st = if (ri + bi) % 2 == 0 then stone else stoneDark
						b:bevelBox(Vector3.new(w, SH / 2 - 0.04, SD), CFrame.new(cx, row.y, 0), st, 0.1, { edges = "Z", edgeStyle = stoneEdge, name = "Brick" })
					end
				end
				-- relleno oscuro entre ladrillos (junta hundida)
				b:box(Vector3.new(SW - 0.06, SH - 0.1, SD - 0.12), CFrame.new(sx * (SX0 + SX1) / 2, headY, 0), crack, "Mortar")
				-- grietas en las caras ±Z de la piedra
				B.both(function(sz)
					local f = B.faceZ(sz, headY, SD / 2 + 0.005)
					local n = f.LookVector
					local function pt(x, y)
						return f:PointToWorldSpace(Vector3.new(sx * x, y, 0))
					end
					b:polyline({ pt(SX0 + 0.55, 0.88), pt(SX0 + 0.45, 0.66), pt(SX0 + 0.58, 0.5) }, 0.04, 0.03, crack, n, false, "Crack")
				end)
				-- esquineros de oro sobre la cara de golpe (refuerzo de bóveda)
				for _, c in { Vector2.new(-1, -1), Vector2.new(1, -1), Vector2.new(1, 1), Vector2.new(-1, 1) } do
					local cy, cz = headY + c.X * (SH / 2 - 0.13), c.Y * (SD / 2 - 0.13)
					b:box(Vector3.new(0.26, 0.3, 0.3), CFrame.new(sx * (SX1 - 0.1), cy, cz), gold, "CornerCap")
				end
			end)
		end)

		-- ── mango ───────────────────────────────────────────────
		b:group("Shaft", function()
			local bottom, top = A.ShaftBottom, headY - CH / 2
			b:cylY(top - bottom, 0.46, CFrame.new(0, (top + bottom) / 2, 0), black, "Shaft")
			-- collar octagonal de oro
			oct(0.42, 0.76, CFrame.new(0, top - 0.21, 0), gold, "Collar")
			b:disc(CFrame.new(0, top - 0.44, 0), 0.66, 0.06, goldEdge, "CollarLip")
			b:disc(CFrame.new(0, top - 0.02, 0), 0.84, 0.05, goldDeep, "CollarTop")
			-- segmentos de hierro con arista
			for _, y in { 0.98, 0.42, -0.14, -0.7 } do
				b:disc(CFrame.new(0, y, 0), 0.54, 0.38, iron, "GripSeg")
			end
			-- bandas de oro
			for _, y in { 0.7, 0.14, -0.42 } do
				b:disc(CFrame.new(0, y, 0), 0.58, 0.14, gold, "GoldBand")
				b:disc(CFrame.new(0, y, 0), 0.62, 0.05, goldEdge, "GoldBandRidge")
			end
		end)

		-- ── pomo ────────────────────────────────────────────────
		b:group("Pommel", function()
			local py = A.PommelY - 0.04
			oct(0.44, 0.8, CFrame.new(0, py, 0), gold, "Pommel")
			b:disc(CFrame.new(0, py + 0.24, 0), 0.7, 0.06, goldEdge, "PommelBevel")
			b:disc(CFrame.new(0, py - 0.24, 0), 0.7, 0.06, goldDeep, "PommelBevel")
			b:cylY(0.06, 0.5, CFrame.new(0, py - 0.29, 0), black, "PommelCap")
			for _, a in { 0, math.pi / 2, math.pi, 3 * math.pi / 2 } do
				b:rivet(Vector3.new(math.cos(a) * 0.4, py, math.sin(a) * 0.4), 0.13, chrome)
			end
		end)

		-- ── efectos ─────────────────────────────────────────────
		b:pulse(glow, 0, 0.45, 0.7)
		b:light(Vector3.new(0, headY, 0), P.rgb(255, 190, 80), 0.9, 8, { pulse = { 0.5, 1.3 }, pulseSpeed = 0.7 })
		local vol = b:fxVolume(Vector3.new(SX1 * 2, GH, GH), CFrame.new(0, headY, 0), "GoldGlints")
		local gl = B.Particles.sparkle(P.rgb(255, 214, 110), 5)
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
		b:impact(CFrame.new(-(SX1 + 0.12), headY, 0), P.rgb(255, 200, 70), {
			sparks = 24,
			flash = 6,
			extra = { coins, dust },
		})
		b:trail(Vector3.new(0, headY + GH / 2, 0), Vector3.new(0, headY - GH / 2, 0), P.rgb(255, 236, 160), P.rgb(210, 130, 20), { lifetime = 0.22 })
	end,
}
