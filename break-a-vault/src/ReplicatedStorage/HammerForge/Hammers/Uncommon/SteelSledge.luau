-- Steel Sledge (Uncommon) — mazo de acero grande y biselado: bloque central de acero cepillado con
-- placa en relieve, filetes de cromo y rayones de uso; tapas laterales más oscuras y más grandes,
-- separadas por una junta negra, con placas remachadas y caras de golpe enmarcadas con un tope pulido.
-- Mango: casquillo remachado bajo la cabeza, anillo de acero, agarre negro acanalado y pomo octagonal.
return {
	Id = "SteelSledge",
	DisplayName = "Steel Sledge",
	Rarity = "Uncommon",
	Order = 1,
	Theme = "Iron Works",
	Build = function(b, P, B)
		local A = B.Anatomy
		local headY = A.HeadY

		-- materiales
		local brushed = P.metal(P.rgb(150, 158, 170), 0.16) -- acero cepillado (bloque central)
		local plateSt = P.metal(P.rgb(146, 154, 166), 0.12) -- placa central, un pelo más clara
		local chrome = P.Chrome -- filos y brillos de arista
		local capSt = P.metal(P.rgb(92, 98, 110), 0.1) -- tapas más oscuras
		local capEdge = P.metal(P.rgb(176, 184, 196), 0.24)
		local dark = P.Blackened
		local gun = P.metal(P.rgb(58, 62, 72), 0.08)
		local scratch = P.metal(P.rgb(96, 102, 114), 0.04)
		local rivetSt = P.BrightSteel
		local rubber = P.GripRubber
		local rubberRib = P.leather(P.rgb(40, 42, 50))

		-- prisma octagonal a lo largo de la Y local de cf
		-- (cruz + 4 tapas diagonales = octágono regular de ancho `dia` entre caras)
		local function oct(len: number, dia: number, cf: CFrame, st, name: string?)
			local s = dia * 0.4142 -- lado del octágono
			local t = dia * 0.2071 -- grosor de la tapa diagonal
			b:box(Vector3.new(dia, len, s), cf, st, name)
			b:box(Vector3.new(s, len, dia), cf, st, name)
			for i = 0, 3 do
				local a = math.rad(45 + 90 * i)
				b:box(Vector3.new(t, len, s), cf * CFrame.Angles(0, a, 0) * CFrame.new(dia / 2 - t / 2, 0, 0), st, name)
			end
		end

		local CW, CH, CD = 1.72, 1.8, 1.76 -- bloque central
		local capW, capH, capD = 0.76, 2.12, 2.08 -- tapas
		local gapX = CW / 2 + 0.06 -- junta
		local capX = CW / 2 + 0.1 + capW / 2
		local outerX = capX + capW / 2

		b:group("Head", function()
			-- ── bloque central de acero cepillado
			b:bevelBox(Vector3.new(CW, CH, CD), CFrame.new(0, headY, 0), brushed, 0.14, { edgeStyle = chrome, name = "Core" })

			-- placas en relieve sobre ambas caras de emblema, con filete de cromo y rayones
			local rand = B.rng(7)
			B.both(function(s)
				local face = B.faceZ(s, headY, CD / 2)
				b:bevelBox(Vector3.new(1.24, 1.3, 0.08), face * CFrame.new(0, 0, 0.03), plateSt, 0.035, { edges = "Z", edgeStyle = chrome, name = "FacePlate" })
				-- rayones finos de acero fresco (más claros)
				for i = 1, 3 do
					local x0, y0 = rand(-0.45, 0.3), rand(-0.45, 0.45)
					local ang = rand(-0.5, 0.5) + (if i == 2 then 2.2 else 0)
					local len = rand(0.2, 0.36)
					local p0 = face:PointToWorldSpace(Vector3.new(x0, y0, 0.075))
					local p1 = face:PointToWorldSpace(Vector3.new(x0 + math.cos(ang) * len, y0 + math.sin(ang) * len, 0.075))
					b:line(p0, p1, 0.025, 0.04, P.BrightSteel, face.LookVector, "Scratch")
				end
				-- brillo diagonal del cepillado (raya de luz)
				b:line(face:PointToWorldSpace(Vector3.new(-0.62, 0.42, 0.075)), face:PointToWorldSpace(Vector3.new(-0.2, 0.55, 0.075)), 0.04, 0.04, chrome, face.LookVector, "Glint")
				b:line(face:PointToWorldSpace(Vector3.new(0.22, -0.55, 0.075)), face:PointToWorldSpace(Vector3.new(0.62, -0.42, 0.075)), 0.04, 0.04, chrome, face.LookVector, "Glint")
			end)

			-- lomo de cromo arriba y abajo del bloque central
			for _, sy in { 1, -1 } do
				b:box(Vector3.new(CW - 0.36, 0.08, 0.46), CFrame.new(0, headY + sy * (CH / 2 + 0.02), 0), chrome, "SpineEdge")
				b:box(Vector3.new(CW - 0.3, 0.1, 0.34), CFrame.new(0, headY + sy * (CH / 2 + 0.03), 0), gun, "Spine")
				b:rivet(Vector3.new(-0.5, headY + sy * (CH / 2 + 0.08), 0), 0.13, rivetSt)
				b:rivet(Vector3.new(0.5, headY + sy * (CH / 2 + 0.08), 0), 0.13, rivetSt)
			end

			-- ── juntas negras + tapas laterales
			B.both(function(sx)
				b:bevelBox(Vector3.new(0.14, CH + 0.1, CD + 0.1), CFrame.new(sx * gapX, headY, 0), dark, 0.07, { edges = "X", edgeStyle = gun, name = "Gasket" })

				local cx = sx * capX
				b:bevelBox(Vector3.new(capW, capH, capD), CFrame.new(cx, headY, 0), capSt, 0.2, { edgeStyle = capEdge, name = "Cap" })

				-- placas remachadas en las caras ±Z de cada tapa
				B.both(function(sz)
					local face = B.faceZ(sz, headY, capD / 2, cx)
					b:bevelBox(Vector3.new(0.44, 1.5, 0.07), face * CFrame.new(0, 0, 0.025), gun, 0.03, { edges = "Z", edgeStyle = capEdge, name = "CapPlate" })
					b:rivet(face:PointToWorldSpace(Vector3.new(0, 0.52, 0.07)), 0.2, rivetSt)
					b:rivet(face:PointToWorldSpace(Vector3.new(0, 0, 0.07)), 0.14, rivetSt)
					b:rivet(face:PointToWorldSpace(Vector3.new(0, -0.52, 0.07)), 0.2, rivetSt)
				end)
				-- remaches arriba y abajo de la tapa
				for _, sy in { 1, -1 } do
					b:rivet(Vector3.new(cx, headY + sy * (capH / 2 + 0.01), 0.5), 0.17, rivetSt)
					b:rivet(Vector3.new(cx, headY + sy * (capH / 2 + 0.01), -0.5), 0.17, rivetSt)
				end

				-- cara de golpe: marco claro, panel oscuro hundido y tope de cromo pulido
				local f = B.faceX(sx, outerX, headY)
				local fr, th = 0.72, 0.07
				for _, sy in { 1, -1 } do
					b:box(Vector3.new(fr * 2 + th, th, 0.06), f * CFrame.new(0, sy * fr, 0.02), capEdge, "StrikeFrame")
					b:box(Vector3.new(th, fr * 2 + th, 0.06), f * CFrame.new(sy * fr, 0, 0.02), capEdge, "StrikeFrame")
				end
				b:box(Vector3.new(fr * 2 - 0.02, fr * 2 - 0.02, 0.03), f * CFrame.new(0, 0, 0.01), dark, "StrikePanel")
				b:box(Vector3.new(1.02, 1.02, 0.07), f * CFrame.new(0, 0, 0.035), capEdge, "StrikeBossRim")
				b:box(Vector3.new(0.9, 0.9, 0.1), f * CFrame.new(0, 0, 0.05), P.BrightSteel, "StrikeBoss")
				b:cylZ(0.04, 0.5, f * CFrame.new(0, 0, 0.11), chrome, "StrikeShine")
			end)

			-- ojo: casquillo bajo la cabeza
			b:cylY(0.1, 0.7, CFrame.new(0, headY - CH / 2 - 0.02, 0), gun, "EyePlate")
		end)

		b:group("Shaft", function()
			local bottom, top = A.ShaftBottom, headY - CH / 2
			b:cylY(top - bottom, A.ShaftDia, CFrame.new(0, (top + bottom) / 2, 0), dark, "Shaft")

			-- casquillo remachado (socket) bajo la cabeza
			oct(0.5, 0.7, CFrame.new(0, top - 0.3, 0), gun, "Socket")
			b:disc(CFrame.new(0, top - 0.04, 0), 0.76, 0.06, capEdge, "SocketLip")
			for _, a in { 0, math.pi } do
				b:rivet(Vector3.new(math.sin(a) * 0.35, top - 0.3, math.cos(a) * 0.35), 0.15, rivetSt)
			end
			-- anillo de acero biselado
			local ry = top - 0.68
			b:disc(CFrame.new(0, ry, 0), 0.68, 0.16, P.BrightSteel, "SteelRing")
			b:disc(CFrame.new(0, ry + 0.1, 0), 0.6, 0.05, chrome, "SteelRingLip")
			b:disc(CFrame.new(0, ry - 0.1, 0), 0.6, 0.05, chrome, "SteelRingLip")
			b:rivet(Vector3.new(0, ry, 0.34), 0.12, chrome)
			b:rivet(Vector3.new(0, ry, -0.34), 0.12, chrome)

			-- agarre negro acanalado
			local g0, g1 = -1.05, ry - 0.18
			b:cylY(g1 - g0, 0.5, CFrame.new(0, (g0 + g1) / 2, 0), rubber, "Grip")
			local n = 9
			for i = 0, n - 1 do
				local y = g0 + 0.1 + (g1 - g0 - 0.2) * i / (n - 1)
				b:disc(CFrame.new(0, y, 0), 0.6, 0.13, rubberRib, "GripRib")
			end
		end)

		b:group("Pommel", function()
			local py = A.PommelY - 0.02
			b:disc(CFrame.new(0, A.ShaftBottom + 0.12, 0), 0.56, 0.08, chrome, "PommelLip")
			oct(0.42, 0.74, CFrame.new(0, py, 0), capSt, "Pommel")
			b:disc(CFrame.new(0, py + 0.24, 0), 0.66, 0.07, capEdge, "PommelBevel")
			b:disc(CFrame.new(0, py - 0.24, 0), 0.66, 0.07, capEdge, "PommelBevel")
			b:cylY(0.08, 0.52, CFrame.new(0, py - 0.3, 0), dark, "PommelCap")
			b:cylY(0.04, 0.24, CFrame.new(0, py - 0.35, 0), chrome, "PommelBoss")
		end)

		-- destello sutil sobre el acero
		local vol = b:fxVolume(Vector3.new(outerX * 2, capH, capD), CFrame.new(0, headY, 0), "GlintVolume")
		local glint = B.Particles.sparkle(P.rgb(225, 236, 255), 2)
		glint.Size = B.seq(0, 0, 0.25, 0.22, 1, 0)
		glint.Speed = NumberRange.new(0, 0.1)
		b:emitter(vol, glint, "SteelGlint")

		-- golpe: chispas de acero blanco-dorado
		b:impact(CFrame.new(-(outerX + 0.12), headY, 0), P.rgb(255, 214, 150), { sparks = 20 })
		b:trail(Vector3.new(0, headY + capH / 2, 0), Vector3.new(0, headY - capH / 2, 0), P.rgb(235, 242, 255), P.rgb(130, 145, 170), { lifetime = 0.2 })
	end,
}
