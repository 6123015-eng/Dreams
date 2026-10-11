-- Reinforced Hammer (Uncommon) — núcleo oscuro blindado con placas de acero atornilladas en capas:
-- dos bloques de extremo y una banda central de acero biselado, grapas atornilladas sobre el núcleo,
-- franjas de pintura azul con una línea de brillo azul muy tenue dentro, tornillos por todos lados.
-- Mango: collar de acero atornillado, anillo, agarre negro acanalado y pomo con placas azules.
return {
	Id = "ReinforcedHammer",
	DisplayName = "Reinforced Hammer",
	Rarity = "Uncommon",
	Order = 3,
	Theme = "Armored Depot",
	Build = function(b, P, B)
		local A = B.Anatomy
		local headY = A.HeadY

		-- materiales
		local core = P.metal(P.rgb(38, 40, 48), 0.06)
		local coreEdge = P.metal(P.rgb(78, 84, 96), 0.1)
		local steel = P.metal(P.rgb(160, 168, 180), 0.18)
		local steelEdge = P.metal(P.rgb(214, 222, 232), 0.26)
		local steelDark = P.metal(P.rgb(104, 110, 122), 0.12)
		local blue = P.paint(P.rgb(36, 112, 230))
		local blueDeep = P.paint(P.rgb(20, 60, 140))
		local glow = P.neon(P.rgb(90, 175, 255), 0.35)
		local boltSt = P.BrightSteel
		local rubber = P.GripRubber
		local rubberRib = P.leather(P.rgb(40, 42, 50))

		local function bolt(cf: CFrame, d: number?)
			-- tornillo: cabeza cilíndrica pulida que sobresale de la placa
			local dia = d or 0.18
			b:cylZ(0.1, dia, cf * CFrame.new(0, 0, 0.03), boltSt, "Bolt")
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
		-- franja azul con línea de brillo dentro (vertical sobre una cara)
		local function blueStrip(face: CFrame, x: number, h: number, z: number)
			b:box(Vector3.new(0.16, h, 0.05), face * CFrame.new(x, 0, z), blue, "BlueStrip")
			b:box(Vector3.new(0.045, h - 0.12, 0.05), face * CFrame.new(x, 0, z + 0.012), glow, "BlueGlow")
		end

		local CW, CH, CD = 3.24, 1.64, 1.64 -- núcleo
		local EW, EH, ED = 0.68, 1.98, 1.98 -- bloques de extremo
		local MW = 0.56 -- banda central
		local ex = CW / 2 - EW / 2 + 0.02
		local outerX = ex + EW / 2
		local gapX = (MW / 2 + (ex - EW / 2)) / 2 -- centro del hueco de núcleo visible

		b:group("Head", function()
			-- núcleo oscuro
			b:bevelBox(Vector3.new(CW, CH, CD), CFrame.new(0, headY, 0), core, 0.1, { edges = "X", edgeStyle = coreEdge, name = "Core" })

			-- banda central de acero
			b:bevelBox(Vector3.new(MW, EH - 0.06, ED - 0.06), CFrame.new(0, headY, 0), steel, 0.14, { edgeStyle = steelEdge, name = "MidBand" })
			b:box(Vector3.new(0.16, 0.05, ED - 0.4), CFrame.new(0.1, headY + (EH - 0.06) / 2 + 0.01, 0), blue, "BlueTop")

			-- bloques de extremo
			B.both(function(sx)
				local cx = sx * ex
				b:bevelBox(Vector3.new(EW, EH, ED), CFrame.new(cx, headY, 0), steel, 0.18, { edgeStyle = steelEdge, name = "EndPlate" })
				-- placa interior (escalón de blindaje)
				b:bevelBox(Vector3.new(0.12, EH + 0.06, ED + 0.06), CFrame.new(sx * (ex - EW / 2 + 0.02), headY, 0), steelDark, 0.06, { edges = "X", edgeStyle = steelEdge, name = "EndLip" })
				b:box(Vector3.new(EW - 0.36, 0.05, 0.16), CFrame.new(cx, headY + EH / 2 + 0.005, 0), blue, "BlueTop")

				-- cara de golpe: marco azul alrededor de placa de acero
				local f = B.faceX(sx, outerX, headY)
				b:box(Vector3.new(1.46, 1.46, 0.06), f * CFrame.new(0, 0, 0.02), blueDeep, "StrikeBase")
				b:box(Vector3.new(1.34, 1.34, 0.08), f * CFrame.new(0, 0, 0.03), blue, "StrikeFrame")
				b:bevelBox(Vector3.new(1.08, 1.08, 0.12), f * CFrame.new(0, 0, 0.05), steel, 0.06, { edges = "Z", edgeStyle = steelEdge, name = "StrikePlate" })
				for _, c in { Vector2.new(-1, -1), Vector2.new(1, -1), Vector2.new(1, 1), Vector2.new(-1, 1) } do
					bolt(f * CFrame.new(c.X * 0.38, c.Y * 0.38, 0.1), 0.15)
				end
			end)

			-- caras de emblema: franjas azules, grapas atornilladas y tornillos sobre el núcleo
			B.both(function(sz)
				local face = B.faceZ(sz, headY, ED / 2)
				-- franjas azules en los extremos (cerca de la arista exterior) y en la banda central
				blueStrip(face, outerX - 0.2, EH - 0.5, 0.02)
				blueStrip(face, -(outerX - 0.2), EH - 0.5, 0.02)
				local mf = B.faceZ(sz, headY, (ED - 0.06) / 2)
				blueStrip(mf, 0.12, EH - 0.5, 0.02)
				-- tornillos en los bloques
				for _, x in { outerX - 0.48, -(outerX - 0.48) } do
					bolt(face * CFrame.new(x, 0.6, 0), 0.17)
					bolt(face * CFrame.new(x, -0.6, 0), 0.17)
				end
				bolt(mf * CFrame.new(-0.12, 0.62, 0), 0.15)
				bolt(mf * CFrame.new(-0.12, -0.62, 0), 0.15)

				-- grapas de acero sobre el hueco del núcleo
				local cf0 = B.faceZ(sz, headY, CD / 2)
				for _, gx in { gapX, -gapX } do
					for _, gy in { 0.5, -0.5 } do
						b:box(Vector3.new(0.5, 0.38, 0.08), cf0 * CFrame.new(gx, gy, 0.03), steelDark, "Clamp")
						bolt(cf0 * CFrame.new(gx, gy, 0.07), 0.14)
					end
					bolt(cf0 * CFrame.new(gx, 0, 0.0), 0.13)
				end
			end)

			-- grapas arriba y abajo del núcleo
			for _, gx in { gapX, -gapX } do
				for _, sy in { 1, -1 } do
					b:box(Vector3.new(0.42, 0.08, 1.0), CFrame.new(gx, headY + sy * (CH / 2 + 0.03), 0), steelDark, "ClampTop")
					b:rivet(Vector3.new(gx, headY + sy * (CH / 2 + 0.08), 0.3), 0.12, boltSt)
					b:rivet(Vector3.new(gx, headY + sy * (CH / 2 + 0.08), -0.3), 0.12, boltSt)
				end
			end
		end)

		b:group("Shaft", function()
			local bottom, top = A.ShaftBottom, headY - CH / 2
			b:cylY(top - bottom, A.ShaftDia, CFrame.new(0, (top + bottom) / 2, 0), core, "Shaft")
			-- collar de acero atornillado
			oct(0.42, 0.66, CFrame.new(0, top - 0.24, 0), steel, "Collar")
			b:disc(CFrame.new(0, top - 0.02, 0), 0.74, 0.06, steelEdge, "CollarLip")
			bolt(CFrame.new(0, top - 0.24, 0.33), 0.14)
			bolt(CFrame.new(0, top - 0.24, -0.33) * CFrame.Angles(0, math.pi, 0), 0.14)
			-- anillo
			local ry = top - 0.6
			b:disc(CFrame.new(0, ry, 0), 0.62, 0.14, steelEdge, "Ring")
			b:disc(CFrame.new(0, ry, 0), 0.66, 0.05, blue, "RingBlue")
			-- agarre negro acanalado
			local g0, g1 = -1.05, ry - 0.12
			b:cylY(g1 - g0, 0.48, CFrame.new(0, (g0 + g1) / 2, 0), rubber, "Grip")
			local n = 9
			for i = 0, n - 1 do
				local y = g0 + 0.1 + (g1 - g0 - 0.2) * i / (n - 1)
				b:disc(CFrame.new(0, y, 0), 0.58, 0.12, rubberRib, "GripRib")
			end
		end)

		b:group("Pommel", function()
			local py = A.PommelY - 0.04
			b:disc(CFrame.new(0, A.ShaftBottom + 0.1, 0), 0.6, 0.08, steelEdge, "PommelLip")
			oct(0.44, 0.76, CFrame.new(0, py, 0), steel, "Pommel")
			b:disc(CFrame.new(0, py + 0.24, 0), 0.68, 0.06, steelEdge, "PommelBevel")
			b:disc(CFrame.new(0, py - 0.24, 0), 0.68, 0.06, steelDark, "PommelBevel")
			b:cylY(0.06, 0.46, CFrame.new(0, py - 0.29, 0), core, "PommelCap")
			-- placas azules cuadradas en las 4 caras
			for i = 0, 3 do
				local a = math.rad(90 * i)
				local cf = CFrame.new(0, py, 0) * CFrame.Angles(0, a, 0) * CFrame.new(0, 0, 0.385)
				b:box(Vector3.new(0.22, 0.22, 0.04), cf, blue, "PommelBlue")
				b:box(Vector3.new(0.08, 0.08, 0.04), cf * CFrame.new(0, 0, 0.01), glow, "PommelGlow")
			end
		end)

		-- luz azul tenue para que las franjas "respiren" en el metal
		b:light(Vector3.new(0, headY, 0), P.rgb(80, 160, 255), 0.45, 5)

		-- golpe: chispas blanco-azules
		b:impact(CFrame.new(-(outerX + 0.14), headY, 0), P.rgb(120, 190, 255), { sparks = 22 })
		b:trail(Vector3.new(0, headY + EH / 2, 0), Vector3.new(0, headY - EH / 2, 0), P.rgb(200, 230, 255), P.rgb(40, 110, 230), { lifetime = 0.2 })
	end,
}
