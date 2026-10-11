-- Safe Cracker (Uncommon) — el martillo de la marca: bloques de extremo de oro con remaches, juntas
-- negras y bloque central oscuro con un VOLANTE DE BÓVEDA de oro en cada cara que gira lento.
-- Caras de golpe con marco de oro y placa de cerradura (ojo de llave), pico de oro arriba.
-- Mango negro con bandas y grapa de oro, collar octagonal de oro y pomo de oro remachado.
return {
	Id = "SafeCracker",
	DisplayName = "Safe Cracker",
	Rarity = "Uncommon",
	Order = 4,
	Theme = "Bank Alley",
	Build = function(b, P, B)
		local A = B.Anatomy
		local headY = A.HeadY

		-- materiales
		local gold = P.metal(P.rgb(236, 166, 36), 0.12)
		local goldEdge = P.metal(P.rgb(255, 214, 110), 0.18) -- brillo de arista
		local goldDeep = P.metal(P.rgb(176, 112, 22), 0.1)
		local darkCore = P.metal(P.rgb(46, 40, 36), 0.06)
		local darkPlate = P.metal(P.rgb(66, 58, 50), 0.08)
		local black = P.Blackened
		local silver = P.Chrome
		local grip = P.GripRubber

		local function oct(len: number, dia: number, cf: CFrame, st, name: string?)
			local s = dia * 0.4142
			local t = dia * 0.2071
			b:box(Vector3.new(dia, len, s), cf, st, name)
			b:box(Vector3.new(s, len, dia), cf, st, name)
			for i = 0, 3 do
				b:box(Vector3.new(t, len, s), cf * CFrame.Angles(0, math.rad(45 + 90 * i), 0) * CFrame.new(dia / 2 - t / 2, 0, 0), st, name)
			end
		end

		local CW, CH, CD = 1.6, 1.8, 1.8 -- bloque central oscuro
		local EW, EH, ED = 0.8, 2.04, 2.04 -- bloques de oro
		local gx = CW / 2 + 0.08
		local ex = CW / 2 + 0.16 + EW / 2
		local outerX = ex + EW / 2

		b:group("Head", function()
			-- ── bloque central
			b:bevelBox(Vector3.new(CW, CH, CD), CFrame.new(0, headY, 0), darkCore, 0.12, { edgeStyle = goldDeep, name = "Core" })

			-- volante de bóveda en ambas caras (gira lento)
			B.both(function(s)
				local face = B.faceZ(s, headY, CD / 2)
				b:box(Vector3.new(1.4, 1.4, 0.06), face * CFrame.new(0, 0, 0.02), darkPlate, "DialPlate")
				for _, c in { Vector2.new(-1, -1), Vector2.new(1, -1), Vector2.new(1, 1), Vector2.new(-1, 1) } do
					b:rivet(face:PointToWorldSpace(Vector3.new(c.X * 0.56, c.Y * 0.56, 0.05)), 0.15, goldEdge)
				end
				-- bisel de oro fijo alrededor del volante
				b:cylZ(0.04, 1.42, face * CFrame.new(0, 0, 0.05), goldEdge, "DialBezel")
				b:cylZ(0.04, 1.3, face * CFrame.new(0, 0, 0.07), black, "DialRecess")
				local plane = face * CFrame.new(0, 0, 0.08)
				local wheel = {}
				for _, p in b:ring(plane * CFrame.Angles(math.pi / 2, 0, 0), 0.53, 0.15, 14, gold, "DialRing", 0.14) do
					table.insert(wheel, p)
				end
				for i = 0, 7 do
					local a = math.pi * 2 * i / 8
					local dir = Vector3.new(math.cos(a), math.sin(a), 0)
					local sp = b:line(plane:PointToWorldSpace(dir * 0.12), plane:PointToWorldSpace(dir * 0.5), 0.08, 0.08, gold, plane.ZVector, "DialSpoke")
					if sp then
						table.insert(wheel, sp)
					end
				end
				table.insert(wheel, b:cylZ(0.14, 0.34, plane * CFrame.new(0, 0, 0.03), goldEdge, "DialHub"))
				table.insert(wheel, b:ball(0.18, plane * CFrame.new(0, 0, 0.1), silver, "DialCenter"))
				b:animate(wheel, plane, { Spin = Vector3.new(0, 0, 0.5) })
			end)

			-- pico de oro arriba del bloque central
			b:cylY(0.1, 0.5, CFrame.new(0, headY + CH / 2 + 0.03, 0), goldDeep, "SpikeBase")
			b:spike(CFrame.new(0, headY + CH / 2 + 0.07, 0), 0.46, 0.36, gold)

			-- ── juntas negras + bloques de oro
			B.both(function(sx)
				b:bevelBox(Vector3.new(0.16, CH + 0.12, CD + 0.12), CFrame.new(sx * gx, headY, 0), black, 0.06, { edges = "X", edgeStyle = darkPlate, name = "Gasket" })

				local cx = sx * ex
				b:bevelBox(Vector3.new(EW, EH, ED), CFrame.new(cx, headY, 0), gold, 0.18, { edgeStyle = goldEdge, name = "GoldBlock" })
				-- franja negra que abraza el bloque (lectura oro/negro)
				b:box(Vector3.new(0.12, EH - 0.3, ED + 0.04), CFrame.new(cx + sx * 0.12, headY, 0), black, "BlackStrap")
				b:box(Vector3.new(0.12, EH + 0.04, ED - 0.3), CFrame.new(cx + sx * 0.12, headY, 0), black, "BlackStrap")
				-- remaches de oro en caras ±Z y arriba
				B.both(function(sz)
					local f = B.faceZ(sz, headY, ED / 2, cx - sx * 0.16)
					b:rivet(f:PointToWorldSpace(Vector3.new(0, 0.58, 0)), 0.19, goldEdge)
					b:rivet(f:PointToWorldSpace(Vector3.new(0, -0.58, 0)), 0.19, goldEdge)
				end)
				b:rivet(Vector3.new(cx - sx * 0.16, headY + EH / 2, 0.45), 0.17, goldEdge)
				b:rivet(Vector3.new(cx - sx * 0.16, headY + EH / 2, -0.45), 0.17, goldEdge)

				-- cara de golpe: marco de oro, panel negro y placa de cerradura
				local f = B.faceX(sx, outerX, headY)
				b:box(Vector3.new(1.42, 1.42, 0.06), f * CFrame.new(0, 0, 0.02), goldEdge, "StrikeFrame")
				b:box(Vector3.new(1.22, 1.22, 0.08), f * CFrame.new(0, 0, 0.03), black, "StrikePanel")
				b:box(Vector3.new(0.82, 0.82, 0.1), f * CFrame.new(0, 0, 0.05), goldDeep, "LockPlate")
				b:cylZ(0.06, 0.26, f * CFrame.new(0, 0.1, 0.1), black, "Keyhole")
				b:box(Vector3.new(0.12, 0.3, 0.06), f * CFrame.new(0, -0.1, 0.1), black, "KeyholeSlot")
				for _, c in { Vector2.new(-1, -1), Vector2.new(1, -1), Vector2.new(1, 1), Vector2.new(-1, 1) } do
					b:rivet(f:PointToWorldSpace(Vector3.new(c.X * 0.31, c.Y * 0.31, 0.1)), 0.11, goldEdge)
				end
			end)
		end)

		-- mango grueso y corto: K = escala radial de todo el mango; el pomo sube
		local K = 1.4
		local shaftBottom = -1.0
		b:group("Shaft", function()
			local bottom, top = shaftBottom, headY - CH / 2
			b:cylY(top - bottom, 0.44 * K, CFrame.new(0, (top + bottom) / 2, 0), grip, "Shaft")
			-- collar octagonal de oro
			oct(0.4, 0.7 * K, CFrame.new(0, top - 0.2, 0), gold, "Collar")
			b:disc(CFrame.new(0, top - 0.42, 0), 0.62 * K, 0.06, goldEdge, "CollarLip")
			b:rivet(Vector3.new(0, top - 0.2, 0.35 * K), 0.17, goldEdge)
			b:rivet(Vector3.new(0, top - 0.2, -0.35 * K), 0.17, goldEdge)
			-- bandas de oro
			for _, y in { 1.35, -0.2 } do
				b:disc(CFrame.new(0, y, 0), 0.54 * K, 0.34, gold, "GoldBand")
				b:disc(CFrame.new(0, y, 0), 0.58 * K, 0.09, goldEdge, "GoldBandRidge")
			end
			-- banda de oro inclinada (vuelta de cinta)
			b:disc(CFrame.new(0, 0.58, 0) * CFrame.Angles(0.22, 0.6, 0), 0.52 * K, 0.28, gold, "GoldWrap")
		end)

		b:group("Pommel", function()
			local PK = 1.4 -- pomo más grande
			local py = -1.12
			oct(0.4, 0.74 * PK, CFrame.new(0, py, 0), gold, "Pommel")
			b:disc(CFrame.new(0, py + 0.22, 0), 0.66 * PK, 0.06, goldEdge, "PommelBevel")
			b:disc(CFrame.new(0, py - 0.22, 0), 0.66 * PK, 0.06, goldDeep, "PommelBevel")
			b:cylY(0.06, 0.48 * PK, CFrame.new(0, py - 0.27, 0), black, "PommelCap")
			b:rivet(Vector3.new(0, py, 0.37 * PK), 0.19, goldEdge)
			b:rivet(Vector3.new(0, py, -0.37 * PK), 0.19, goldEdge)
		end)

		-- brillo de oro: destellos sutiles + luz cálida suave
		local vol = b:fxVolume(Vector3.new(outerX * 2, EH, ED), CFrame.new(0, headY, 0), "GoldGlints")
		local gl = B.Particles.sparkle(P.rgb(255, 220, 120), 3)
		gl.Size = B.seq(0, 0, 0.25, 0.26, 1, 0)
		gl.Speed = NumberRange.new(0, 0.1)
		b:emitter(vol, gl, "GoldSparkle")

		-- golpe: chispas doradas + destellos de monedas
		b:impact(CFrame.new(-(outerX + 0.14), headY, 0), P.rgb(255, 205, 70), {
			sparks = 24,
			extra = { B.Particles.sparkle(P.rgb(255, 225, 120), 0) },
		})
		b:trail(Vector3.new(0, headY + EH / 2, 0), Vector3.new(0, headY - EH / 2, 0), P.rgb(255, 236, 160), P.rgb(220, 140, 30), { lifetime = 0.22 })
	end,
}
