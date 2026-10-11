-- Plasma Hammer (Rare) — un cañón de plasma convertido en martillo. La cabeza es un barril a lo largo de X:
-- en medio, un tubo de vidrio lleno de plasma naranja que late, con un núcleo amarillo y dos filamentos de
-- energía que giran adentro; lo sujeta una jaula de barras oscuras con tiras de luz.
-- A cada lado, anillos facetados y pesados de metal gris (aristas claras) con ventanas de luz naranja
-- alrededor, y tapas de golpe con un LENTE de plasma (bisel de acero, domo de vidrio, núcleo caliente)
-- rodeado de segmentos brillantes.
-- Mango oscuro segmentado con anillos de luz naranja, collar y bandas doradas, pomo octagonal remachado.
return {
	Id = "PlasmaHammer",
	DisplayName = "Plasma Hammer",
	Rarity = "Rare",
	Order = 2,
	Theme = "Power Plant",
	Build = function(b, P, B)
		local A = B.Anatomy
		local headY = A.HeadY + 0.05

		-- ── estilos ─────────────────────────────────────────────
		local ringMetal = P.metal(P.rgb(104, 106, 114), 0.1) -- anillos gris piedra/metal
		local ringEdge = P.metal(P.rgb(178, 182, 190), 0.2) -- arista clara
		local dark = P.metal(P.rgb(46, 46, 52), 0.06)
		local black = P.Blackened
		local steel = P.metal(P.rgb(150, 156, 166), 0.16)
		local chrome = P.Chrome
		local gold = P.metal(P.rgb(236, 170, 40), 0.14)
		local goldEdge = P.metal(P.rgb(255, 210, 110), 0.2)
		local plasma = P.neon(P.rgb(255, 112, 0))
		local plasmaHot = P.neon(P.rgb(255, 176, 40))
		local plasmaDim = P.neon(P.rgb(230, 92, 10))
		local glass = P.glass(P.rgb(255, 150, 60), 0.55, 0.3)
		local lensGlass = P.glass(P.rgb(255, 200, 120), 0.72, 0.3)
		local grip = P.GripRubber

		local glowParts = {}
		local AX = CFrame.Angles(0, 0, math.pi / 2) -- eje Y local → eje X del modelo (para b:ring / b:disc)

		local function oct(len: number, dia: number, cf: CFrame, st, name: string?)
			local s = dia * 0.4142
			local t = dia * 0.2071
			b:box(Vector3.new(dia, len, s), cf, st, name)
			b:box(Vector3.new(s, len, dia), cf, st, name)
			for i = 0, 3 do
				b:box(Vector3.new(t, len, s), cf * CFrame.Angles(0, math.rad(45 + 90 * i), 0) * CFrame.new(dia / 2 - t / 2, 0, 0), st, name)
			end
		end

		-- bloques alternos un poco más oscuros: el aro lee como bloques de metal ensamblados
		local function twoTone(parts)
			for i, p in parts do
				if i % 2 == 0 then
					p.Color = P.rgb(84, 86, 94)
				end
			end
		end

		-- punto sobre la superficie del barril: x, ángulo (0 = arriba, +90° = +Z), radio
		local function around(x: number, a: number, r: number): CFrame
			return CFrame.new(x, headY, 0) * CFrame.Angles(a, 0, 0) * CFrame.new(0, r, 0)
		end

		-- ── medidas (a lo largo de X) ───────────────────────────
		local TUBE_R = 0.74 -- radio del tubo de vidrio
		local tubeHalf = 0.78
		local BAND_X0, BAND_X1 = 0.86, 1.5 -- anillo pesado
		local CAP_X0, CAP_X1 = 1.5, 1.98 -- tapa de golpe
		local BAND_R = 1.04
		local CAP_R = 0.98

		b:group("Head", function()
			-- ── tubo central de plasma
			b:cylinder(tubeHalf * 2 + 0.1, TUBE_R * 2, CFrame.new(0, headY, 0), glass, "PlasmaGlass")
			local core = b:cylinder(tubeHalf * 2, 1.12, CFrame.new(0, headY, 0), plasma, "Plasma")
			local coreHot = b:cylinder(tubeHalf * 2 + 0.02, 0.56, CFrame.new(0, headY, 0), plasmaHot, "PlasmaCore")
			table.insert(glowParts, core)
			table.insert(glowParts, coreHot)

			-- filamentos de energía que giran dentro del tubo
			local fil = {}
			for i, a in { 0, math.pi } do
				local pts = {}
				for k = 0, 6 do
					local t = k / 6
					local x = -tubeHalf + 0.06 + t * (tubeHalf * 2 - 0.12)
					local ang = a + t * math.pi * 1.4
					local r = 0.62 + 0.04 * math.sin(k * 2.3 + i)
					table.insert(pts, Vector3.new(x, headY + math.cos(ang) * r, math.sin(ang) * r))
				end
				for _, p in b:polyline(pts, 0.06, 0.06, plasmaHot, nil, false, "Filament") do
					table.insert(fil, p)
				end
			end
			b:animate(fil, CFrame.new(0, headY, 0), { Spin = Vector3.new(2.2, 0, 0) })

			-- jaula: 4 barras en diagonal con tira de luz + abrazadera central arriba/abajo
			for i = 0, 3 do
				local a = math.rad(45 + 90 * i)
				local cf = around(0, a, TUBE_R + 0.06)
				b:box(Vector3.new(tubeHalf * 2 + 0.1, 0.14, 0.24), cf, dark, "CageBar")
				b:box(Vector3.new(tubeHalf * 2 + 0.1, 0.06, 0.3), cf * CFrame.new(0, -0.04, 0), ringEdge, "CageBarEdge")
				table.insert(glowParts, b:box(Vector3.new(tubeHalf * 2 - 0.24, 0.05, 0.08), cf * CFrame.new(0, 0.07, 0), plasma, "CageGlow"))
				b:rivet((cf * CFrame.new(tubeHalf - 0.08, 0.07, 0)).Position, 0.1, chrome)
				b:rivet((cf * CFrame.new(-tubeHalf + 0.08, 0.07, 0)).Position, 0.1, chrome)
			end

			-- ── lados (±X): collar, anillo pesado facetado, tapa con lente
			B.both(function(s)
				-- collar que muerde el tubo
				b:cylinder(0.18, TUBE_R * 2 + 0.26, CFrame.new(s * (tubeHalf + 0.05), headY, 0), dark, "TubeCollar")
				b:cylinder(0.06, TUBE_R * 2 + 0.36, CFrame.new(s * (tubeHalf + 0.12), headY, 0), ringEdge, "CollarLip")

				-- anillo pesado: núcleo + aro facetado de 12 segmentos + labios de arista
				local bx = s * (BAND_X0 + BAND_X1) / 2
				local bw = BAND_X1 - BAND_X0
				b:cylinder(bw, BAND_R * 2 - 0.2, CFrame.new(bx, headY, 0), dark, "BandCore")
				twoTone(b:ring(CFrame.new(bx, headY, 0) * AX, BAND_R - 0.12, 0.26, 10, ringMetal, "BandRing", bw - 0.12))
				for _, e in { -1, 1 } do
					b:ring(CFrame.new(bx + e * (bw / 2 - 0.04), headY, 0) * AX, BAND_R - 0.1, 0.3, 10, ringEdge, "BandEdge", 0.07)
				end
				-- ventanas de plasma alrededor del anillo (marco oscuro hundido + neón)
				for i = 0, 5 do
					local a = math.rad(30 + 60 * i)
					local cf = around(bx, a, BAND_R + 0.005)
					b:box(Vector3.new(0.3, 0.08, 0.32), cf, black, "SlotFrame")
					table.insert(glowParts, b:box(Vector3.new(0.22, 0.09, 0.22), cf * CFrame.new(0, 0.01, 0), plasma, "SlotGlow"))
				end
				-- remaches entre ventanas
				for i = 0, 2 do
					local a = math.rad(120 * i)
					b:rivet(around(bx, a, BAND_R + 0.01).Position, 0.12, chrome)
				end

				-- junta entre anillo y tapa (brilla un poco)
				b:cylinder(0.06, CAP_R * 2 - 0.06, CFrame.new(s * (CAP_X0 + 0.01), headY, 0), black, "CapJoint")
				table.insert(glowParts, b:cylinder(0.04, CAP_R * 2 - 0.02, CFrame.new(s * (CAP_X0 + 0.01), headY, 0), plasmaDim, "CapSeam"))

				-- tapa: escalón facetado + cara plana con lente
				local cx = s * (CAP_X0 + CAP_X1) / 2
				local cw = CAP_X1 - CAP_X0
				b:cylinder(cw, CAP_R * 2 - 0.16, CFrame.new(cx, headY, 0), dark, "CapCore")
				twoTone(b:ring(CFrame.new(cx - s * 0.04, headY, 0) * AX, CAP_R - 0.1, 0.22, 10, ringMetal, "CapRing", cw - 0.1))
				b:cylinder(0.08, CAP_R * 2 - 0.3, CFrame.new(s * (CAP_X1 - 0.02), headY, 0), ringEdge, "CapRim")

				-- cara de golpe: segmentos brillantes + bisel + lente de plasma
				local f = B.faceX(s, CAP_X1, headY)
				b:cylZ(0.04, CAP_R * 2 - 0.42, f * CFrame.new(0, 0, 0.01), black, "LensPlate")
				for i = 0, 7 do
					local a = math.rad(22.5 + 45 * i)
					local p = f * CFrame.Angles(0, 0, a) * CFrame.new(0, 0.66, 0.035)
					table.insert(glowParts, b:box(Vector3.new(0.2, 0.14, 0.05), p, plasmaHot, "LensSegment"))
				end
				b:cylZ(0.1, 1.08, f * CFrame.new(0, 0, 0.06), steel, "LensBezel")
				b:cylZ(0.04, 1.16, f * CFrame.new(0, 0, 0.03), ringEdge, "LensBezelRim")
				table.insert(glowParts, b:cylZ(0.06, 0.86, f * CFrame.new(0, 0, 0.1), plasma, "Lens"))
				table.insert(glowParts, b:cylZ(0.06, 0.42, f * CFrame.new(0, 0, 0.13), plasmaHot, "LensCore"))
				b:cylZ(0.06, 0.92, f * CFrame.new(0, 0, 0.16), lensGlass, "LensDome")
				-- cruz de rejilla sobre el lente
				b:box(Vector3.new(0.86, 0.05, 0.04), f * CFrame.new(0, 0, 0.2), dark, "LensGrille")
				b:box(Vector3.new(0.05, 0.86, 0.04), f * CFrame.new(0, 0, 0.2), dark, "LensGrille")
			end)

			-- soporte bajo el tubo (une con el mango)
			b:bevelBox(Vector3.new(0.7, 0.26, 0.74), CFrame.new(0, headY - TUBE_R - 0.06, 0), dark, 0.07, { edges = "Y", edgeStyle = ringEdge, name = "Mount" })
			b:box(Vector3.new(0.76, 0.06, 0.8), CFrame.new(0, headY - TUBE_R - 0.2, 0), gold, "MountBand")
		end)

		-- ── mango ───────────────────────────────────────────────
		b:group("Shaft", function()
			local bottom, top = A.ShaftBottom, headY - TUBE_R - 0.22
			b:cylY(top - bottom, 0.46, CFrame.new(0, (top + bottom) / 2, 0), black, "Shaft")
			-- collar dorado octagonal
			oct(0.34, 0.72, CFrame.new(0, top - 0.17, 0), gold, "Collar")
			b:disc(CFrame.new(0, top - 0.36, 0), 0.56, 0.06, goldEdge, "CollarLip")
			-- segmentos oscuros con arista clara
			local segs = { 0.95, 0.55, 0.15, -0.25, -0.65 }
			for _, y in segs do
				b:disc(CFrame.new(0, y, 0), 0.58, 0.3, dark, "GripSeg")
			end
			-- anillos de plasma entre segmentos
			for _, y in { 0.35, -0.45 } do
				b:disc(CFrame.new(0, y, 0), 0.56, 0.1, black, "GlowRingBase")
				table.insert(glowParts, b:disc(CFrame.new(0, y, 0), 0.6, 0.06, plasma, "GlowRing"))
			end
			-- bandas doradas abajo
			for _, y in { -0.95, -1.15 } do
				b:disc(CFrame.new(0, y, 0), 0.6, 0.12, gold, "GoldBand")
				b:disc(CFrame.new(0, y, 0), 0.64, 0.04, goldEdge, "GoldBandRidge")
			end
		end)

		-- ── pomo ────────────────────────────────────────────────
		b:group("Pommel", function()
			local py = A.PommelY - 0.06
			oct(0.44, 0.8, CFrame.new(0, py, 0), dark, "Pommel")
			b:disc(CFrame.new(0, py + 0.23, 0), 0.66, 0.06, ringEdge, "PommelBevel")
			b:disc(CFrame.new(0, py - 0.23, 0), 0.66, 0.06, ringEdge, "PommelBevel")
			for _, a in { 0, math.pi / 2, math.pi, 3 * math.pi / 2 } do
				b:rivet(Vector3.new(math.cos(a) * 0.37, py, math.sin(a) * 0.37), 0.12, chrome)
			end
			b:cylY(0.05, 0.4, CFrame.new(0, py - 0.27, 0), black, "PommelCap")
			table.insert(glowParts, b:cylY(0.06, 0.2, CFrame.new(0, py - 0.28, 0), plasmaHot, "PommelGlow"))
		end)

		-- ── efectos ─────────────────────────────────────────────
		b:pulse(glowParts, 0, 0.3, 1.4)
		b:light(Vector3.new(0, headY, 0), P.rgb(255, 140, 40), 1.8, 11, { pulse = { 1.1, 2.8 }, pulseSpeed = 1.4 })
		-- brasas que escapan del tubo
		local vol = b:fxVolume(Vector3.new(tubeHalf * 2, 1.1, 1.1), CFrame.new(0, headY, 0), "PlasmaVolume")
		local em = B.Particles.ember(P.rgb(255, 150, 40), 6)
		em.Speed = NumberRange.new(0.6, 1.6)
		em.Size = B.seq(0, 0.14, 1, 0)
		b:emitter(vol, em, "PlasmaEmbers")
		-- chispitas en los lentes
		B.both(function(s)
			local sp = B.Particles.sparkle(P.rgb(255, 190, 80), 2)
			sp.Size = B.seq(0, 0, 0.25, 0.3, 1, 0)
			b:emitter(Vector3.new(s * (CAP_X1 + 0.2), headY, 0), sp, "LensSparkle")
		end)

		-- golpe: chispas naranjas + brasas + onda de plasma
		local burst = B.Particles.ember(P.rgb(255, 160, 50), 0)
		burst.Speed = NumberRange.new(6, 12)
		burst.SpreadAngle = Vector2.new(80, 80)
		burst.Acceleration = Vector3.new(0, -6, 0)
		local wave = B.Particles.orb(P.rgb(255, 120, 20), 0)
		wave.Size = B.seq(0, 0.6, 1, 2.6)
		wave.Lifetime = NumberRange.new(0.2, 0.3)
		wave.Speed = NumberRange.new(0, 0.5)
		b:impact(CFrame.new(-(CAP_X1 + 0.22), headY, 0), P.rgb(255, 140, 30), {
			sparks = 26,
			flash = 7,
			extra = { burst, wave },
		})
		b:trail(Vector3.new(0, headY + BAND_R, 0), Vector3.new(0, headY - BAND_R, 0), P.rgb(255, 220, 140), P.rgb(255, 90, 10), { lifetime = 0.24 })
	end,
}
