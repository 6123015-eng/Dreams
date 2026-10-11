-- Steel Sledge (Uncommon) — mazo de acero grande y biselado, con contraste de valores: bloque central de
-- acero pavonado OSCURO con placa en relieve llena de abolladuras de martillo (huecos oscuros con borde
-- claro) y filetes de cromo brillante en cada bisel; tapas laterales un tono más claras y más grandes,
-- separadas por una junta negra, con nichos oscuros para los remaches, y caras de golpe enmarcadas con un
-- filo de neón azul frío (el brillo sutil del Uncommon) y tope pulido. Mango: casquillo remachado, anillo
-- de acero, agarre corto y grueso de hule con ranuras hondas, y pomo octagonal grande.
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
		local brushed = P.metal(P.rgb(70, 76, 88), 0.12) -- acero pavonado oscuro (bloque central)
		local plateSt = P.metal(P.rgb(88, 94, 106), 0.1) -- placa central, un pelo más clara
		local chrome = P.Chrome -- filos y brillos de arista
		local capSt = P.metal(P.rgb(140, 148, 162), 0.14) -- tapas un tono más claras
		local capEdge = P.metal(P.rgb(206, 214, 226), 0.26)
		local dentSt = P.metal(P.rgb(46, 50, 60), 0.06)
		local dentRim = P.metal(P.rgb(150, 158, 172), 0.16)
		local iceNeon = P.neon(P.rgb(120, 200, 255), 0.6)
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
			b:bevelBox(Vector3.new(CW, CH, CD), CFrame.new(0, headY, 0), brushed, 0.1, { edgeStyle = chrome, name = "Core" })

			-- placas en relieve sobre ambas caras de emblema, con filete de cromo y rayones
			local rand = B.rng(7)
			B.both(function(s)
				local face = B.faceZ(s, headY, CD / 2)
				b:bevelBox(Vector3.new(1.24, 1.3, 0.08), face * CFrame.new(0, 0, 0.03), plateSt, 0.035, { edges = "Z", edgeStyle = chrome, name = "FacePlate" })
				-- abolladuras de martillo: hueco oscuro + borde claro (6 por cara, distintas en cada cara)
				local dents = if s > 0
					then { { -0.38, 0.4, 0.24 }, { 0.3, 0.46, 0.17 }, { 0.05, 0.02, 0.27 }, { -0.4, -0.3, 0.18 }, { 0.42, -0.18, 0.21 }, { -0.02, -0.48, 0.15 } }
					else { { 0.36, 0.36, 0.23 }, { -0.3, 0.5, 0.16 }, { -0.12, 0.0, 0.26 }, { 0.4, -0.36, 0.19 }, { -0.42, -0.24, 0.2 }, { 0.1, -0.5, 0.15 } }
				for _, dn in dents do
					local dc = face * CFrame.new(dn[1], dn[2], 0.07)
					b:cylZ(0.04, dn[3] + 0.07, dc, dentRim, "DentRim")
					b:cylZ(0.04, dn[3], dc * CFrame.new(0, 0, 0.006), dentSt, "Dent")
				end
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
					-- nicho oscuro para los remaches, con borde claro
					b:box(Vector3.new(0.5, 1.58, 0.06), face * CFrame.new(0, 0, 0.0), capEdge, "CapRecessRim")
					b:box(Vector3.new(0.38, 1.46, 0.06), face * CFrame.new(0, 0, 0.012), gun, "CapRecess")
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
				-- filo de neón azul frío sobre el marco
				for _, sy in { 1, -1 } do
					b:box(Vector3.new(fr * 2 + th, 0.03, 0.04), f * CFrame.new(0, sy * fr, 0.06), iceNeon, "StrikeGlow")
					b:box(Vector3.new(0.03, fr * 2 + th, 0.04), f * CFrame.new(sy * fr, 0, 0.06), iceNeon, "StrikeGlow")
				end
				b:box(Vector3.new(fr * 2 - 0.02, fr * 2 - 0.02, 0.03), f * CFrame.new(0, 0, 0.01), dark, "StrikePanel")
				b:box(Vector3.new(1.02, 1.02, 0.07), f * CFrame.new(0, 0, 0.035), capEdge, "StrikeBossRim")
				b:box(Vector3.new(0.9, 0.9, 0.1), f * CFrame.new(0, 0, 0.05), P.BrightSteel, "StrikeBoss")
				b:cylZ(0.04, 0.5, f * CFrame.new(0, 0, 0.11), chrome, "StrikeShine")
			end)

			-- ojo: casquillo bajo la cabeza
			b:cylY(0.1, 0.7, CFrame.new(0, headY - CH / 2 - 0.02, 0), gun, "EyePlate")
		end)

		-- mango grueso y corto: K = escala radial de todo el mango; el pomo sube
		local K = 1.2
		local shaftBottom = -1.02
		b:group("Shaft", function()
			local bottom, top = shaftBottom, headY - CH / 2
			b:cylY(top - bottom, 0.46 * K, CFrame.new(0, (top + bottom) / 2, 0), dark, "Shaft")

			-- casquillo remachado (socket) bajo la cabeza
			oct(0.5, 0.78 * K, CFrame.new(0, top - 0.3, 0), gun, "Socket")
			b:disc(CFrame.new(0, top - 0.04, 0), 0.84 * K, 0.06, capEdge, "SocketLip")
			for _, a in { 0, math.pi } do
				b:rivet(Vector3.new(math.sin(a) * 0.39 * K, top - 0.3, math.cos(a) * 0.39 * K), 0.17, rivetSt)
			end
			-- anillo de acero biselado
			local ry = top - 0.68
			b:disc(CFrame.new(0, ry, 0), 0.76 * K, 0.17, P.BrightSteel, "SteelRing")
			b:disc(CFrame.new(0, ry + 0.1, 0), 0.68 * K, 0.05, chrome, "SteelRingLip")
			b:disc(CFrame.new(0, ry - 0.1, 0), 0.68 * K, 0.05, chrome, "SteelRingLip")
			b:rivet(Vector3.new(0, ry, 0.38 * K), 0.14, chrome)
			b:rivet(Vector3.new(0, ry, -0.38 * K), 0.14, chrome)

			-- agarre corto y grueso: núcleo hundido + costillas gruesas (ranuras hondas)
			local g0, g1 = -0.9, ry - 0.17
			b:cylY(g1 - g0, 0.5 * K, CFrame.new(0, (g0 + g1) / 2, 0), dark, "GripCore")
			local n = 7
			for i = 0, n - 1 do
				local y = g0 + 0.1 + (g1 - g0 - 0.2) * i / (n - 1)
				b:disc(CFrame.new(0, y, 0), 0.68 * K, 0.24, rubber, "GripRib")
				b:disc(CFrame.new(0, y + 0.11, 0), 0.62 * K, 0.04, rubberRib, "GripRibTop")
			end
		end)

		b:group("Pommel", function()
			local PK = 1.25 -- pomo ~1.3x
			local py = -1.12
			b:disc(CFrame.new(0, -0.9, 0), 0.66 * K, 0.08, chrome, "PommelLip")
			oct(0.4, 0.96 * PK, CFrame.new(0, py, 0), capSt, "Pommel")
			b:disc(CFrame.new(0, py + 0.22, 0), 0.86 * PK, 0.08, capEdge, "PommelBevel")
			b:disc(CFrame.new(0, py - 0.22, 0), 0.86 * PK, 0.08, capEdge, "PommelBevel")
			b:cylY(0.08, 0.66 * PK, CFrame.new(0, py - 0.28, 0), dark, "PommelCap")
			b:cylY(0.04, 0.3 * PK, CFrame.new(0, py - 0.33, 0), chrome, "PommelBoss")
		end)

		-- destello sutil sobre el acero
		local vol = b:fxVolume(Vector3.new(outerX * 2, capH, capD), CFrame.new(0, headY, 0), "GlintVolume")
		local glint = B.Particles.sparkle(P.rgb(200, 228, 255), 3)
		glint.Size = B.seq(0, 0, 0.25, 0.42, 1, 0)
		glint.Speed = NumberRange.new(0, 0.1)
		b:emitter(vol, glint, "SteelGlint")

		-- golpe: chispas de acero blanco-dorado
		b:impact(CFrame.new(-(outerX + 0.12), headY, 0), P.rgb(255, 214, 150), { sparks = 20 })
		b:trail(Vector3.new(0, headY + capH / 2, 0), Vector3.new(0, headY - capH / 2, 0), P.rgb(235, 242, 255), P.rgb(130, 145, 170), { lifetime = 0.2 })
	end,
}
