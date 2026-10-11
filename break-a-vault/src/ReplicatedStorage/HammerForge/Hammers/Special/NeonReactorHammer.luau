-- Neon Reactor Hammer (Special) — un reactor de fusión portátil convertido en mazo. La cabeza es un
-- BARRIL OCTAGONAL de acero oscuro acostado a lo largo del golpe. En la punta (-X) va la LENTE DEL
-- REACTOR: un anillo cian acanalado que GIRA alrededor de una lente magenta con aro cromado. En medio,
-- el núcleo expuesto: TUBOS DE VIDRIO CIAN con neón adentro y varillas magenta, sujetos por anillos,
-- que rotan lentamente alrededor del eje como una turbina. Bandas de sujeción octagonales con remaches
-- y costuras de neón morado entre cada segmento; el blindaje trasero lleva tiras de neón morado en las
-- aristas y una tapa con anillo morado. Encima, dos soportes con ARCOS ELÉCTRICOS morados que
-- parpadean de uno a otro. Mango segmentado oscuro con anillo morado arriba, anillo cian abajo y pomo
-- octagonal. FX: chispas eléctricas, destellos cian, orbes morados, luces que laten.
return {
	Id = "NeonReactorHammer",
	DisplayName = "Neon Reactor Hammer",
	Rarity = "Special",
	Order = 2,
	Theme = "Reactor Core",
	Build = function(b, P, B)
		local A = B.Anatomy
		local headY = A.HeadY + 0.1

		-- ── estilos ─────────────────────────────────────────────
		local cyanC = P.rgb(50, 200, 255)
		local purpleC = P.rgb(176, 70, 255)
		local magentaC = P.rgb(236, 80, 255)
		local hull = P.metal(P.rgb(38, 38, 48), 0.1)
		local hullAlt = P.metal(P.rgb(50, 50, 62), 0.12)
		local hullEdge = P.metal(P.rgb(88, 82, 112), 0.2)
		local hullDark = P.metal(P.rgb(20, 20, 26), 0.06)
		local chrome = P.foil(P.rgb(200, 204, 222), 0.3)
		local rivetSt = P.metal(P.rgb(150, 150, 170), 0.22)
		local cyan = P.neon(P.rgb(40, 190, 255))
		local cyanHot = P.neon(P.rgb(150, 236, 255))
		local purple = P.neon(P.rgb(160, 60, 255))
		local magenta = P.neon(P.rgb(230, 70, 255))
		local pinkHot = P.neon(P.rgb(255, 190, 255))
		local cyanGlass = P.glass(P.rgb(110, 210, 255), 0.55, 0.35)
		local lensGlass = P.glass(P.rgb(220, 140, 255), 0.5, 0.4)
		local arcSt = P.neon(P.rgb(196, 110, 255))
		local arcCore = P.neon(P.rgb(250, 225, 255))
		local grip = P.leather(P.rgb(28, 26, 34))

		local glow = {}
		local function G(p)
			table.insert(glow, p)
			return p
		end

		-- prisma octagonal regular a lo largo de X con 4 tablones (2 rectos + 2 a 45°) que llenan el
		-- octágono exacto sin importar el largo (bevelBox recorta el chaflán en piezas delgadas).
		-- Los tablones diagonales llevan `edge` → las caras diagonales brillan como arista.
		local function oct(x0: number, x1: number, W: number, st, edge, name)
			local f = W * math.tan(math.pi / 8) -- largo de cada cara
			local cf = CFrame.new((x0 + x1) / 2, headY, 0)
			local L = x1 - x0
			local out = {}
			table.insert(out, b:box(Vector3.new(L, W, f), cf, st, name))
			table.insert(out, b:box(Vector3.new(L, f, W), cf, st, name))
			table.insert(out, b:box(Vector3.new(L - 0.004, W - 0.004, f), cf * CFrame.Angles(math.pi / 4, 0, 0), edge or st, name .. "Edge"))
			table.insert(out, b:box(Vector3.new(L - 0.004, W - 0.004, f), cf * CFrame.Angles(-math.pi / 4, 0, 0), edge or st, name .. "Edge"))
			return out
		end
		-- tiras de neón sobre las 4 caras diagonales del octágono
		local function facetStrips(x0: number, x1: number, W: number, st, width: number?)
			local m = W / 2 + 0.02
			for _, sy in { 1, -1 } do
				for _, sz in { 1, -1 } do
					local th = math.atan2(sz, sy)
					G(b:box(Vector3.new(x1 - x0, 0.05, width or 0.09), CFrame.new((x0 + x1) / 2, headY, 0) * CFrame.Angles(th, 0, 0) * CFrame.new(0, m, 0), st, "FacetNeon"))
				end
			end
		end
		-- costura de neón entre segmentos (queda hundida entre dos piezas más anchas)
		local function seam(x0: number, x1: number, W: number, st)
			for _, p in oct(x0, x1, W, st, st, "NeonSeam") do
				G(p)
			end
		end
		local function cylX(x0: number, x1: number, dia: number, st, name)
			return b:cylinder(x1 - x0, dia, CFrame.new((x0 + x1) / 2, headY, 0), st, name)
		end

		local lensRing = {}
		local turbine = {}
		local coreX0, coreX1 = -1.18, -0.18
		local coreMid = (coreX0 + coreX1) / 2

		b:group("Head", function()
			-- ── lente del reactor (-X) ──────────────────────
			oct(-1.8, -1.46, 2.2, hull, hullEdge, "LensCollar")
			oct(-1.84, -1.8, 2.06, hullDark, hullDark, "LensCollarLip")
			-- anillo cian acanalado (gira)
			G(cylX(-2.12, -1.8, 1.86, cyan, "LensRingCore"))
			cylX(-2.1, -1.82, 1.96, cyanGlass, "LensRingGlass")
			for i = 0, 13 do
				local a = i * math.pi * 2 / 14
				local r = 0.99
				table.insert(lensRing, b:box(Vector3.new(0.34, 0.1, 0.13), CFrame.new(-1.96, headY + math.cos(a) * r, math.sin(a) * r) * CFrame.Angles(a, 0, 0), hullEdge, "LensRib"))
			end
			table.insert(lensRing, b:cylinder(0.04, 2.04, CFrame.new(-2.13, headY, 0), hullDark, "LensRingLip"))
			-- cara de la lente
			cylX(-2.2, -2.12, 1.6, hull, "LensPlate")
			cylX(-2.24, -2.2, 1.34, chrome, "LensBezel")
			cylX(-2.27, -2.24, 1.14, hullDark, "LensSeat")
			G(cylX(-2.3, -2.27, 0.86, magenta, "LensCore"))
			cylX(-2.34, -2.28, 0.96, lensGlass, "LensGlass")
			G(cylX(-2.36, -2.3, 0.34, pinkHot, "LensEye"))
			cylX(-2.37, -2.33, 0.5, lensGlass, "LensEyeGlass")
			-- retícula
			for i = 0, 3 do
				local a = i * math.pi / 2 + math.pi / 4
				b:box(Vector3.new(0.04, 0.05, 0.3), CFrame.new(-2.33, headY + math.cos(a) * 0.36, math.sin(a) * 0.36) * CFrame.Angles(a, 0, 0) * CFrame.Angles(math.pi / 2, 0, 0), chrome, "LensTick")
			end
			for i = 0, 5 do
				local a = i * math.pi / 3
				b:rivet(Vector3.new(-2.21, headY + math.cos(a) * 0.72, math.sin(a) * 0.72), 0.1, rivetSt)
			end

			-- ── banda A, núcleo expuesto, banda B ──────────
			seam(-1.46, -1.42, 2.25, purple)
			oct(-1.42, -1.18, 2.28, hullAlt, hullEdge, "ClampA")
			oct(-0.18, 0.18, 2.28, hullAlt, hullEdge, "ClampB")
			for _, cx in { -1.3, 0 } do
				B.both(function(s)
					local z = s * (2.28 / 2 + 0.01)
					b:rivet(Vector3.new(cx, headY + 0.42, z), 0.13, rivetSt)
					b:rivet(Vector3.new(cx, headY - 0.42, z), 0.13, rivetSt)
					G(b:box(Vector3.new(0.08, 0.2, 0.04), CFrame.new(cx, headY, z), magenta, "ClampLight"))
				end)
				b:box(Vector3.new(0.2, 0.05, 0.6), CFrame.new(cx, headY + 2.28 / 2 + 0.02, 0), hullEdge, "ClampTopPlate")
			end
			-- eje del núcleo (fijo) con anillos de energía
			cylX(coreX0, coreX1, 1.0, hullDark, "CoreAxle")
			G(cylX(coreX0 + 0.1, coreX1 - 0.1, 0.7, P.neon(P.rgb(80, 120, 255)), "CoreGlow"))
			cylX(coreX0 + 0.05, coreX1 - 0.05, 0.82, cyanGlass, "CoreGlass")
			-- turbina de tubos (gira alrededor de X)
			for i = 0, 5 do
				local a = i * math.pi / 3
				local r = 0.74
				local y, z = headY + math.cos(a) * r, math.sin(a) * r
				local len = coreX1 - coreX0 + 0.16
				table.insert(turbine, G(b:cylinder(len, 0.2, CFrame.new(coreMid, y, z), cyanHot, "TubeCore")))
				table.insert(turbine, b:cylinder(len - 0.04, 0.34, CFrame.new(coreMid, y, z), cyanGlass, "TubeGlass"))
				local a2 = a + math.pi / 6
				table.insert(turbine, G(b:cylinder(len - 0.1, 0.08, CFrame.new(coreMid, headY + math.cos(a2) * 0.86, math.sin(a2) * 0.86), magenta, "TubeRod")))
			end
			for _, x in { coreMid - 0.28, coreMid + 0.28 } do
				for _, p in b:ring(CFrame.new(x, headY, 0) * CFrame.Angles(0, 0, math.pi / 2), 0.8, 0.12, 12, hullEdge, "TurbineRing", 0.1) do
					table.insert(turbine, p)
				end
			end

			-- ── blindaje trasero (+X) ───────────────────────
			seam(0.18, 0.22, 2.11, purple)
			oct(0.22, 1.42, 2.06, hull, P.metal(P.rgb(70, 54, 100), 0.16), "Armor")
			facetStrips(0.32, 1.32, 2.06, purple)
			-- placas en ±Z con remaches y luces
			B.both(function(s)
				local face = B.faceZ(s, headY, 2.06 / 2 + 0.03, 0.82)
				b:bevelBox(Vector3.new(0.86, 0.9, 0.06), face, hullAlt, 0.03, { edges = "Z", edgeStyle = hullEdge, name = "ArmorPlate" })
				for _, cx in { -0.33, 0.33 } do
					for _, cy in { -0.33, 0.33 } do
						b:rivet(face:PointToWorldSpace(Vector3.new(cx, cy, 0.04)), 0.11, rivetSt)
					end
				end
				for i = -1, 1 do
					b:box(Vector3.new(0.5, 0.07, 0.04), face * CFrame.new(0, i * 0.15, 0.04), hullDark, "ArmorSlot")
					G(b:box(Vector3.new(0.44, 0.04, 0.04), face * CFrame.new(0, i * 0.15, 0.05), if i == 0 then cyan else purple, "ArmorSlotGlow"))
				end
			end)
			-- placa superior con rejilla
			b:box(Vector3.new(0.86, 0.05, 0.5), CFrame.new(0.82, headY + 2.06 / 2 + 0.02, 0), hullAlt, "ArmorTop")
			for i = -1, 1 do
				G(b:box(Vector3.new(0.7, 0.04, 0.05), CFrame.new(0.82, headY + 2.06 / 2 + 0.05, i * 0.14), purple, "ArmorTopVent"))
			end
			seam(1.42, 1.46, 2.11, purple)
			oct(1.46, 1.8, 2.18, hullAlt, hullEdge, "EndBand")
			B.both(function(s)
				b:rivet(Vector3.new(1.63, headY + 0.4, s * (2.18 / 2 + 0.01)), 0.13, rivetSt)
				b:rivet(Vector3.new(1.63, headY - 0.4, s * (2.18 / 2 + 0.01)), 0.13, rivetSt)
			end)
			-- tapa trasera (+X): octágono, anillo morado y perno
			oct(1.8, 1.9, 1.84, hull, hull, "EndPlate")
			cylX(1.9, 1.94, 1.4, hullDark, "EndSeat")
			G(cylX(1.92, 1.96, 1.2, purple, "EndRing"))
			cylX(1.94, 1.99, 0.94, hull, "EndHub")
			for i = 0, 5 do
				local a = i * math.pi / 3 + math.pi / 6
				b:box(Vector3.new(0.05, 0.26, 0.08), CFrame.new(1.99, headY + math.cos(a) * 0.3, math.sin(a) * 0.3) * CFrame.Angles(a, 0, 0), hullEdge, "EndFin")
			end
			cylX(1.99, 2.06, 0.3, chrome, "EndBolt")
			G(cylX(2.06, 2.08, 0.14, cyanHot, "EndBoltEye"))

			-- ── soportes de los arcos (arriba) ──────────────
			local function bracket(x: number, baseY: number)
				local topY = baseY + 0.42
				B.both(function(s)
					b:box(Vector3.new(0.12, 0.44, 0.1), CFrame.new(x, baseY + 0.2, s * 0.2), hullAlt, "BracketPost")
				end)
				b:box(Vector3.new(0.16, 0.1, 0.52), CFrame.new(x, topY, 0), hullEdge, "BracketBar")
				G(b:ball(0.16, Vector3.new(x, topY + 0.07, 0), pinkHot, "BracketNode"))
				b:ball(0.22, Vector3.new(x, topY + 0.07, 0), lensGlass, "BracketNodeGlass")
				return Vector3.new(x, topY + 0.07, 0)
			end
			local n1 = bracket(-1.3, headY + 2.28 / 2)
			local n2 = bracket(0.82, headY + 2.06 / 2 + 0.04)
			local arcs = b:group("Arcs", function()
				for i, seed in { 11, 23, 37 } do
					local mid = (n1 + n2) / 2 + Vector3.new(0, 0.35 + i * 0.08, (i - 2) * 0.12)
					local pts = B.jitterPath(n1, mid, 4, 0.12, seed, Vector3.zAxis)
					local pts2 = B.jitterPath(mid, n2, 4, 0.12, seed + 5, Vector3.zAxis)
					for j = 2, #pts2 do
						table.insert(pts, pts2[j])
					end
					b:polyline(pts, if i == 2 then 0.07 else 0.05, 0.05, if i == 2 then arcCore else arcSt, Vector3.zAxis, false, "Arc")
				end
				-- chispas cortas sobre los nodos
				for _, nd in { n1, n2 } do
					b:polyline(B.jitterPath(nd, nd + Vector3.new(0.1, 0.35, 0.15), 3, 0.06, 71, Vector3.xAxis), 0.035, 0.035, arcSt, Vector3.xAxis, false, "ArcSpark")
				end
			end)
			b:flicker(arcs, 14, 0.55)
		end)
		b:animate(lensRing, CFrame.new(-1.96, headY, 0), { Spin = Vector3.new(-1.6, 0, 0) })
		b:animate(turbine, CFrame.new(coreMid, headY, 0), { Spin = Vector3.new(1.1, 0, 0) })

		-- ── mango ───────────────────────────────────────────────
		-- k = escala radial del mango (agarre robusto como el concepto); gBot = fin inferior del agarre
		local k = 1.2
		local gBot = -0.95
		b:group("Shaft", function()
			local top = headY - 2.28 / 2 + 0.05
			b:cylY(top - gBot, 0.34 * k, CFrame.new(0, (top + gBot) / 2, 0), hullDark, "ShaftCore")
			-- collar con remaches
			local cy = top - 0.22
			b:bevelBox(Vector3.new(0.74 * k, 0.34, 0.74 * k), CFrame.new(0, cy, 0), hullAlt, 0.2 * k, { edges = "Y", edgeStyle = hullEdge, name = "Collar" })
			for i = 0, 3 do
				local a = i * math.pi / 2
				b:rivet(Vector3.new(math.cos(a) * 0.37 * k, cy, math.sin(a) * 0.37 * k), 0.12 * k, rivetSt)
			end
			-- anillo morado
			local function neonRing(y: number, st)
				b:cylY(0.06, 0.6 * k, CFrame.new(0, y + 0.09, 0), hullEdge, "RingLip")
				G(b:cylY(0.1, 0.56 * k, CFrame.new(0, y, 0), st, "NeonRing"))
				b:cylY(0.06, 0.6 * k, CFrame.new(0, y - 0.09, 0), hullEdge, "RingLip")
			end
			neonRing(cy - 0.36, purple)
			-- agarre segmentado
			for i = 0, 8 do
				local y = 1.5 - i * 0.24
				b:cylY(0.17, 0.58 * k, CFrame.new(0, y, 0), grip, "GripSeg")
				b:cylY(0.04, 0.6 * k, CFrame.new(0, y + 0.07, 0), hull, "GripEdge")
			end
			neonRing(-0.68, cyan)
			b:cylY(0.16, 0.56 * k, CFrame.new(0, gBot + 0.1, 0), grip, "GripSeg")
		end)

		-- ── pomo octagonal (1.3x, achatado) ─────────────────────
		b:group("Pommel", function()
			local pk = 1.3
			local py = gBot - 0.18
			b:bevelBox(Vector3.new(0.84 * pk, 0.32, 0.84 * pk), CFrame.new(0, py, 0), hullAlt, 0.24 * pk, { edges = "Y", edgeStyle = P.metal(P.rgb(90, 66, 130), 0.18), name = "Pommel" })
			b:cylY(0.06, 0.66 * pk, CFrame.new(0, py + 0.19, 0), hullEdge, "PommelLip")
			G(b:cylY(0.06, 0.6 * pk, CFrame.new(0, py - 0.18, 0), purple, "PommelRing"))
			b:cylY(0.08, 0.4 * pk, CFrame.new(0, py - 0.22, 0), chrome, "PommelCap")
			G(b:cylY(0.04, 0.16 * pk, CFrame.new(0, py - 0.27, 0), cyanHot, "PommelEye"))
		end)

		b:pulse(glow, 0, 0.3, 1.2)

		-- ── efectos ─────────────────────────────────────────────
		b:group("FX", function()
			local arcV = b:fxVolume(Vector3.new(2.0, 0.5, 0.4), CFrame.new(-0.24, headY + 1.7, 0), "ArcVolume")
			b:emitter(arcV, B.Particles.electric(purpleC, 14), "ReactorSparks")
			local coreV = b:fxVolume(Vector3.new(1.0, 1.8, 1.8), CFrame.new(coreMid, headY, 0), "CoreVolume")
			b:emitter(coreV, B.Particles.sparkle(cyanC, 8), "CoreSparkle")
			b:emitter(b:fxVolume(Vector3.new(4.0, 2.2, 2.2), CFrame.new(-0.1, headY, 0), "OrbVolume"), B.Particles.orb(magentaC, 4), "ReactorOrbs")
			local lensV = b:fxVolume(Vector3.new(0.1, 1.2, 1.2), CFrame.new(-2.36, headY, 0), "LensVolume")
			local ls = B.Particles.sparkle(magentaC, 4)
			ls.EmissionDirection = Enum.NormalId.Left
			ls.Speed = NumberRange.new(0.4, 1.2)
			b:emitter(lensV, ls, "LensSparkle")
		end)
		b:light(Vector3.new(coreMid, headY, 0), cyanC, 1.5, 10, { pulse = { 0.9, 2.0 }, pulseSpeed = 1.2, name = "CoreGlow" })
		b:light(Vector3.new(-0.24, headY + 1.9, 0), purpleC, 0.8, 6, { pulse = { 0.2, 1.4 }, pulseSpeed = 3.3, name = "ArcGlow" })
		b:light(Vector3.new(-2.6, headY, 0), magentaC, 1.0, 7, { pulse = { 0.6, 1.5 }, pulseSpeed = 1.7, name = "LensGlow" })

		-- impacto: descarga eléctrica + orbes + destellos
		local zap = B.Particles.electric(purpleC, 0)
		zap.Speed = NumberRange.new(8, 16)
		zap.Size = B.seq(0, 0.6, 1, 0)
		zap.Lifetime = NumberRange.new(0.12, 0.3)
		local orbs = B.Particles.orb(cyanC, 0)
		orbs.Speed = NumberRange.new(3, 7)
		orbs.Size = B.seq(0, 0.3, 0.3, 0.5, 1, 0)
		orbs.Lifetime = NumberRange.new(0.4, 0.8)
		local glint = B.Particles.sparkle(magentaC, 0)
		glint.Speed = NumberRange.new(4, 9)
		glint.Size = B.seq(0, 0, 0.2, 0.5, 1, 0)
		local hit = b:impact(CFrame.new(-2.6, headY, 0), magentaC, { sparks = 26, flash = 8, extra = { zap, orbs, glint } })
		hit:FindFirstChild("ImpactExtra1"):SetAttribute("FX_Emit", 30)
		hit:FindFirstChild("ImpactExtra2"):SetAttribute("FX_Emit", 12)
		hit:FindFirstChild("ImpactExtra3"):SetAttribute("FX_Emit", 16)
		b:trail(Vector3.new(0, headY + 1.1, 0), Vector3.new(0, headY - 1.1, 0), P.rgb(120, 230, 255), P.rgb(170, 60, 255), { lifetime = 0.26 })
	end,
}
