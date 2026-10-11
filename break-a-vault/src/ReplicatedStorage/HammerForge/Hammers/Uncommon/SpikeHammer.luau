-- Spike Hammer (Uncommon) — martillo agresivo: bloques de hierro oscuro con marcos de acero remachados,
-- banda central pintada de rojo (con desgaste) y placa de hierro con un gran pico de acero en cada cara.
-- Picos de acero pulido en las caras de golpe, arriba y abajo; mango forrado de cuero rojo, collar de
-- hierro y pomo octagonal con tachones y pico inferior.
return {
	Id = "SpikeHammer",
	DisplayName = "Spike Hammer",
	Rarity = "Uncommon",
	Order = 2,
	Theme = "Scrap Yard",
	Build = function(b, P, B)
		local A = B.Anatomy
		local headY = A.HeadY

		-- materiales
		local iron = P.metal(P.rgb(64, 66, 74), 0.08)
		local ironEdge = P.metal(P.rgb(150, 154, 164), 0.18)
		local frameSt = P.metal(P.rgb(108, 112, 122), 0.12)
		local dark = P.Blackened
		local red = P.paint(P.rgb(170, 30, 28))
		local redEdge = P.paint(P.rgb(226, 70, 56))
		local redDeep = P.paint(P.rgb(104, 18, 18))
		local spikeSt = P.metal(P.rgb(200, 206, 216), 0.26)
		local tipSt = P.Chrome
		local rivetSt = P.BrightSteel
		local leather = P.leather(P.rgb(150, 44, 32))
		local leatherDark = P.leather(P.rgb(96, 26, 20))

		-- marco ortonormal con la Y local apuntando a `dir`
		local function along(pos: Vector3, dir: Vector3): CFrame
			local d = dir.Unit
			local ref = if math.abs(d.Y) < 0.9 then Vector3.yAxis else Vector3.zAxis
			local right = ref:Cross(d).Unit
			return CFrame.fromMatrix(pos, right, d)
		end
		-- pico con collar oscuro en la base
		local function spikeOut(pos: Vector3, dir: Vector3, len: number, w: number, collar: boolean?)
			local cf = along(pos, dir)
			if collar then
				b:cylY(0.1, w * 1.3, cf * CFrame.new(0, 0.03, 0), dark, "SpikeCollar")
			end
			b:spike(cf * CFrame.new(0, 0.05, 0), len, w, spikeSt)
		end
		local function oct(len: number, dia: number, cf: CFrame, st, name: string?)
			local s = dia * 0.4142
			local t = dia * 0.2071
			b:box(Vector3.new(dia, len, s), cf, st, name)
			b:box(Vector3.new(s, len, dia), cf, st, name)
			for i = 0, 3 do
				b:box(Vector3.new(t, len, s), cf * CFrame.Angles(0, math.rad(45 + 90 * i), 0) * CFrame.new(dia / 2 - t / 2, 0, 0), st, name)
			end
		end

		local RW, RH, RD = 1.24, 1.8, 1.8 -- banda roja central
		local EW, EH, ED = 1.0, 2.04, 2.04 -- bloques de hierro
		local ex = RW / 2 + 0.08 + EW / 2
		local outerX = ex + EW / 2

		b:group("Head", function()
			-- ── centro rojo
			b:bevelBox(Vector3.new(RW, RH, RD), CFrame.new(0, headY, 0), red, 0.12, { edgeStyle = redEdge, name = "RedBand" })
			B.both(function(s)
				local face = B.faceZ(s, headY, RD / 2)
				-- placa de hierro remachada + pico central
				b:box(Vector3.new(0.98, 0.98, 0.06), face * CFrame.new(0, 0, 0.02), ironEdge, "CenterPlateRim")
				b:box(Vector3.new(0.88, 0.88, 0.1), face * CFrame.new(0, 0, 0.04), iron, "CenterPlate")
				for _, c in { Vector2.new(-1, -1), Vector2.new(1, -1), Vector2.new(1, 1), Vector2.new(-1, 1) } do
					b:rivet(face:PointToWorldSpace(Vector3.new(c.X * 0.33, c.Y * 0.33, 0.1)), 0.14, rivetSt)
				end
				spikeOut(face:PointToWorldSpace(Vector3.new(0, 0, 0.08)), face.ZVector, 0.74, 0.54, true)
				-- pintura descascarada (hierro asomando)
				b:line(face:PointToWorldSpace(Vector3.new(-0.55, 0.72, 0.005)), face:PointToWorldSpace(Vector3.new(-0.3, 0.6, 0.005)), 0.05, 0.04, redDeep, face.LookVector, "Chip")
				b:line(face:PointToWorldSpace(Vector3.new(0.3, -0.62, 0.005)), face:PointToWorldSpace(Vector3.new(0.56, -0.74, 0.005)), 0.06, 0.04, dark, face.LookVector, "Chip")
			end)

			-- ── bloques de hierro con marcos de acero
			B.both(function(sx)
				local cx = sx * ex
				b:bevelBox(Vector3.new(EW, EH, ED), CFrame.new(cx, headY, 0), iron, 0.16, { edgeStyle = ironEdge, name = "EndBlock" })
				-- marco interior (banda vertical de acero que abraza la banda roja)
				b:box(Vector3.new(0.12, EH + 0.12, ED + 0.12), CFrame.new(sx * (RW / 2 + 0.1), headY, 0), ironEdge, "FrameLip")
				b:box(Vector3.new(0.2, EH + 0.06, ED + 0.06), CFrame.new(sx * (RW / 2 + 0.1), headY, 0), frameSt, "Frame")
				-- remaches en el marco y en las caras del bloque
				B.both(function(sz)
					local face = B.faceZ(sz, headY, ED / 2 + 0.04, sx * (RW / 2 + 0.1))
					b:rivet(face:PointToWorldSpace(Vector3.new(0, 0.62, 0)), 0.15, rivetSt)
					b:rivet(face:PointToWorldSpace(Vector3.new(0, -0.62, 0)), 0.15, rivetSt)
					local bf = B.faceZ(sz, headY, ED / 2, cx)
					b:rivet(bf:PointToWorldSpace(Vector3.new(0, 0.52, 0.01)), 0.2, rivetSt)
					b:rivet(bf:PointToWorldSpace(Vector3.new(0, -0.52, 0.01)), 0.2, rivetSt)
				end)

				-- cara de golpe: placa de acero con marco y dos picos inclinados
				local f = B.faceX(sx, outerX, headY)
				b:box(Vector3.new(1.56, 1.56, 0.06), f * CFrame.new(0, 0, 0.02), ironEdge, "StrikeRim")
				b:box(Vector3.new(1.4, 1.4, 0.1), f * CFrame.new(0, 0, 0.04), frameSt, "StrikePlate")
				b:box(Vector3.new(0.9, 0.32, 0.06), f * CFrame.new(0, 0, 0.08), iron, "StrikeSlot")
				spikeOut(Vector3.new(sx * (outerX + 0.06), headY + 0.48, 0), Vector3.new(sx, 0.4, 0), 0.78, 0.46)
				spikeOut(Vector3.new(sx * (outerX + 0.06), headY - 0.48, 0), Vector3.new(sx, -0.4, 0), 0.78, 0.46)
				-- pico superior e inferior del bloque
				spikeOut(Vector3.new(cx, headY + EH / 2 - 0.02, 0), Vector3.new(sx * 0.18, 1, 0), 0.74, 0.46)
				spikeOut(Vector3.new(cx + sx * 0.1, headY - EH / 2 + 0.02, 0), Vector3.new(sx * 0.5, -1, 0), 0.5, 0.36)
			end)
			-- puntas pulidas: destello sutil
			local tips = b:fxVolume(Vector3.new(outerX * 2 + 1, EH + 1, ED + 1.2), CFrame.new(0, headY, 0), "TipGlints")
			local gl = B.Particles.sparkle(P.rgb(255, 235, 225), 3)
			gl.Size = B.seq(0, 0, 0.25, 0.24, 1, 0)
			gl.Speed = NumberRange.new(0, 0.1)
			b:emitter(tips, gl, "SpikeGlint")
		end)

		-- mango grueso y corto: K = escala radial de todo el mango; el pomo sube
		local K = 1.4
		local shaftBottom = -1.0
		b:group("Shaft", function()
			local bottom, top = shaftBottom, headY - RH / 2
			b:cylY(top - bottom, A.ShaftDia * K, CFrame.new(0, (top + bottom) / 2, 0), dark, "Shaft")
			-- collar de hierro bajo la cabeza
			oct(0.46, 0.66 * K, CFrame.new(0, top - 0.24, 0), iron, "Collar")
			b:disc(CFrame.new(0, top - 0.5, 0), 0.6 * K, 0.08, ironEdge, "CollarLip")
			b:rivet(Vector3.new(0, top - 0.24, 0.33 * K), 0.16, rivetSt)
			b:rivet(Vector3.new(0, top - 0.24, -0.33 * K), 0.16, rivetSt)
			-- forro de cuero rojo con vueltas cruzadas
			local g0, g1 = -0.92, top - 0.56
			b:cylY(g1 - g0, 0.46 * K, CFrame.new(0, (g0 + g1) / 2, 0), leatherDark, "Grip")
			local n = 9
			for i = 0, n - 1 do
				local y = g0 + 0.16 + (g1 - g0 - 0.32) * i / (n - 1)
				local tilt = if i % 2 == 0 then 0.16 else -0.16
				b:cylY(0.19, 0.53 * K, CFrame.new(0, y, 0) * CFrame.Angles(tilt, i * 0.7, 0), if i % 3 == 1 then leatherDark else leather, "LeatherBand")
			end
			b:disc(CFrame.new(0, g1 - 0.02, 0), 0.56 * K, 0.12, leather, "WrapEnd")
			b:disc(CFrame.new(0, g0 + 0.02, 0), 0.56 * K, 0.12, leather, "WrapEnd")
			b:box(Vector3.new(0.05, 0.36, 0.16), CFrame.new(0.3 * K, g0 + 0.22, 0.06) * CFrame.Angles(0, 0, math.rad(14)), leatherDark, "WrapTail")
		end)

		b:group("Pommel", function()
			local PK = 1.45 -- pomo ~1.3x del mango (más grueso)
			local py = -1.12
			b:disc(CFrame.new(0, -0.9, 0), 0.58 * K, 0.08, ironEdge, "PommelLip")
			oct(0.38, 0.76 * PK, CFrame.new(0, py, 0), iron, "Pommel")
			b:disc(CFrame.new(0, py + 0.2, 0), 0.66 * PK, 0.06, ironEdge, "PommelBevel")
			b:disc(CFrame.new(0, py - 0.2, 0), 0.66 * PK, 0.06, ironEdge, "PommelBevel")
			-- tachones alrededor
			for i = 0, 3 do
				local a = math.rad(90 * i)
				b:rivet(Vector3.new(math.cos(a) * 0.39 * PK, py, math.sin(a) * 0.39 * PK), 0.18, rivetSt)
			end
			-- pico inferior
			b:cylY(0.1, 0.4 * PK, CFrame.new(0, py - 0.24, 0), dark, "PommelBase")
			b:ball(0.3, CFrame.new(0, py - 0.3, 0), spikeSt, "PommelStud")
		end)

		-- golpe: chispas rojo-naranja y polvo de pintura
		b:impact(CFrame.new(-(outerX + 0.12), headY, 0), P.rgb(255, 92, 60), {
			sparks = 22,
			extra = { B.Particles.ember(P.rgb(255, 120, 70), 0) },
		})
		b:trail(Vector3.new(0, headY + EH / 2, 0), Vector3.new(0, headY - EH / 2, 0), P.rgb(255, 120, 100), P.rgb(150, 30, 30), { lifetime = 0.2 })
	end,
}
