-- Radioactive Sledge (Special) — un contenedor de desechos nucleares hecho mazo.
-- Tres bloques de acero negro blindado: remate izquierdo grande con franja de peligro amarilla/negra y una
-- ventana de cristal verde radiactivo en la cara de golpe; bloque central con placa atornillada y el
-- SÍMBOLO DE RADIACIÓN (disco amarillo, trébol negro y halo verde que late); remate derecho con franja de
-- peligro y rendijas verdes. Entre los bloques, cápsulas de vidrio con núcleo de neón verde que laten
-- desfasadas y tienen burbujas subiendo. Arriba, celdas verdes encendidas; abajo, baba radiactiva que
-- escurre y gotea.
-- Mango negro con espiral amarilla de peligro, bandas de acero, anillo verde brillante y pomo blindado.
-- FX: pulso verde, goteo, burbujas, destellos tóxicos y luz verde latiendo.
return {
	Id = "RadioactiveSledge",
	DisplayName = "Radioactive Sledge",
	Rarity = "Special",
	Order = 6,
	Theme = "Nuclear Waste Plant",
	Build = function(b, P, B)
		local A = B.Anatomy
		local headY = A.HeadY + 0.1
		local TAU = math.pi * 2

		-- ── estilos ─────────────────────────────────────────────
		local armor = P.metal(P.rgb(30, 32, 36), 0.08)
		local armorDark = P.metal(P.rgb(24, 25, 28), 0.05)
		local plateSt = P.style(P.rgb(44, 46, 50), Enum.Material.DiamondPlate, 0.06)
		local edge = P.metal(P.rgb(128, 134, 140), 0.18) -- arista de acero claro
		local steel = P.metal(P.rgb(160, 168, 176), 0.2)
		local yellow = P.paint(P.rgb(255, 204, 20))
		local black = P.paint(P.rgb(20, 20, 22))
		local greenC = P.rgb(120, 255, 40)
		local greenHot = P.rgb(214, 255, 150)
		local green = P.neon(greenC)
		local greenCore = P.neon(greenHot)
		local greenSoft = P.neon(P.rgb(90, 230, 30), 0.15)
		local glass = P.glass(P.rgb(160, 255, 110), 0.55)
		local slime = P.neon(P.rgb(110, 240, 30), 0.05)

		-- ── medidas ────────────────────────────────────────────
		local LX0, LX1, LH, LD = -1.98, -1.0, 2.06, 2.0 -- remate izquierdo
		local CX0, CX1, CH, CD = -0.58, 0.72, 1.86, 1.82 -- bloque central
		local RX0, RX1, RH, RD = 1.14, 1.9, 1.9, 1.9 -- remate derecho

		-- ── helpers ────────────────────────────────────────────
		-- franja de peligro sobre el plano XY de `plane` (w = lado angosto en X, h = largo en Y)
		local function hazard(plane: CFrame, w: number, h: number)
			b:box(Vector3.new(w + 0.12, h + 0.12, 0.04), plane * CFrame.new(0, 0, 0.02), armorDark, "HazardBed")
			b:box(Vector3.new(w, h, 0.06), plane * CFrame.new(0, 0, 0.03), yellow, "HazardYellow")
			local pitch = 0.3
			local span = h - w - 0.02
			local n = math.max(1, math.floor(span / pitch) + 1)
			local y0 = -((n - 1) * pitch) / 2
			for i = 0, n - 1 do
				b:box(Vector3.new(w * math.sqrt(2) - 0.06, 0.13, 0.04), plane * CFrame.new(0, y0 + i * pitch, 0.065) * CFrame.Angles(0, 0, math.rad(45)), black, "HazardBlack")
			end
			-- rieles que enmarcan la franja (tapan las puntas de las barras)
			for _, sx in { -1, 1 } do
				b:box(Vector3.new(0.07, h + 0.12, 0.1), plane * CFrame.new(sx * (w / 2 + 0.02), 0, 0.05), edge, "HazardRail")
			end
		end
		-- cápsula radiactiva vertical (núcleo de neón + vidrio + tapas + anillos)
		local cores = {}
		local function canister(x: number, z: number, len: number, phase: number)
			local cf = CFrame.new(x, headY, z)
			local core = b:cylY(len - 0.2, 0.28, cf, green, "CellCore")
			b:cylY(len - 0.3, 0.12, cf, greenCore, "CellHot")
			b:cylY(len - 0.14, 0.42, cf, glass, "CellGlass")
			for _, sy in { -1, 1 } do
				b:cylY(0.16, 0.5, cf * CFrame.new(0, sy * (len / 2 - 0.04), 0), armorDark, "CellCap")
				b:cylY(0.05, 0.54, cf * CFrame.new(0, sy * (len / 2 - 0.13), 0), steel, "CellCapRing")
			end
			b:cylY(0.05, 0.46, cf, steel, "CellBand")
			b:pulse({ core }, 0, 0.3, 1.1, phase)
			table.insert(cores, core)
		end
		-- gota de baba colgando (bola + hilo) desde `pos` hacia abajo
		local function drip(pos: Vector3, len: number, dia: number)
			b:ball(dia * 1.25, pos, slime, "SlimeBlob")
			b:cylY(len, dia * 0.6, CFrame.new(pos - Vector3.new(0, len / 2, 0)), slime, "SlimeThread")
			b:ball(dia, pos - Vector3.new(0, len, 0), greenCore, "SlimeDrop")
		end

		b:group("Head", function()
			-- ── núcleo que une todo (detrás de las cápsulas) ──
			b:box(Vector3.new(RX0 - LX1 + 0.2, 1.0, 1.0), CFrame.new((LX1 + RX0) / 2, headY, 0), armorDark, "Spine")
			-- rieles arriba/abajo en los huecos
			for _, gap in { { LX1, CX0 }, { CX1, RX0 } } do
				local gx = (gap[1] + gap[2]) / 2
				for _, sy in { -1, 1 } do
					b:box(Vector3.new(gap[2] - gap[1] + 0.1, 0.16, 1.6), CFrame.new(gx, headY + sy * (CH / 2 - 0.02), 0), armor, "GapRail")
					b:box(Vector3.new(gap[2] - gap[1] + 0.12, 0.05, 1.64), CFrame.new(gx, headY + sy * (CH / 2 + 0.04), 0), edge, "GapRailLip")
				end
				canister(gx, 0.48, CH - 0.2, 0)
				canister(gx, -0.48, CH - 0.2, 0.45)
			end

			-- ── remate izquierdo ─────────────────────────────
			local lcx = (LX0 + LX1) / 2
			b:bevelBox(Vector3.new(LX1 - LX0, LH, LD), CFrame.new(lcx, headY, 0), armor, 0.16, { edges = "all", edgeStyle = edge, name = "LeftBlock" })
			local bandX = LX1 - 0.3
			B.both(function(s)
				hazard(B.faceZ(s, headY, LD / 2, bandX), 0.4, LH - 0.3)
				-- placa exterior con pernos
				local f = B.faceZ(s, headY, LD / 2)
				b:box(Vector3.new(0.4, LH - 0.42, 0.05), f * CFrame.new(s * (LX0 + 0.3), 0, 0.025), plateSt, "LeftPlate")
				for _, y in { -0.72, 0.72 } do
					b:rivet(f:PointToWorldSpace(Vector3.new(s * (LX0 + 0.3), y, 0.06)), 0.11, steel)
				end
			end)
			for _, sy in { -1, 1 } do
				-- franja también arriba y abajo (plano con X local = X, Y local = Z)
				local pl = CFrame.new(bandX, headY + sy * LH / 2, 0) * CFrame.Angles(-sy * math.pi / 2, 0, 0)
				hazard(pl, 0.4, LD - 0.3)
			end
			-- cara de golpe -X: marco, ventana verde con rejilla y pernos
			local lf = B.faceX(-1, -LX0, headY)
			b:bevelBox(Vector3.new(LD - 0.24, LH - 0.24, 0.1), lf * CFrame.new(0, 0, 0.04), armorDark, 0.14, { edges = "Z", edgeStyle = edge, name = "StrikeFrame" })
			b:box(Vector3.new(1.16, 1.24, 0.06), lf * CFrame.new(0, 0, 0.08), black, "WindowWell")
			local win = b:box(Vector3.new(1.06, 1.14, 0.06), lf * CFrame.new(0, 0, 0.1), green, "Window")
			b:box(Vector3.new(0.5, 0.56, 0.04), lf * CFrame.new(0, 0, 0.13), greenCore, "WindowHot")
			b:box(Vector3.new(1.08, 1.16, 0.05), lf * CFrame.new(0, 0, 0.15), glass, "WindowGlass")
			b:pulse({ win }, 0, 0.25, 1.1, 0.2)
			b:box(Vector3.new(1.12, 0.07, 0.08), lf * CFrame.new(0, 0, 0.17), edge, "WindowBar")
			b:box(Vector3.new(0.07, 1.2, 0.08), lf * CFrame.new(0, 0, 0.17), edge, "WindowBar")
			for _, cx in { -1, 1 } do
				for _, cy in { -1, 1 } do
					b:rivet(lf:PointToWorldSpace(Vector3.new(cx * 0.74, cy * 0.78, 0.1)), 0.13, steel)
				end
			end

			-- ── bloque central + símbolo de radiación ────────
			b:bevelBox(Vector3.new(CX1 - CX0, CH, CD), CFrame.new((CX0 + CX1) / 2, headY, 0), armor, 0.14, { edges = "all", edgeStyle = edge, name = "CenterBlock" })
			local ccx = (CX0 + CX1) / 2
			B.both(function(s)
				local f = B.faceZ(s, headY, CD / 2, ccx)
				b:bevelBox(Vector3.new(1.18, 1.56, 0.08), f * CFrame.new(0, 0, 0.04), plateSt, 0.08, { edges = "Z", edgeStyle = edge, name = "EmblemPlate" })
				for _, cx in { -1, 1 } do
					for _, cy in { -1, 1 } do
						b:rivet(f:PointToWorldSpace(Vector3.new(cx * 0.48, cy * 0.66, 0.09)), 0.12, steel)
					end
				end
				local halo = b:cylZ(0.04, 1.2, f * CFrame.new(0, 0, 0.1), greenSoft, "RadHalo")
				b:pulse({ halo }, 0, 0.5, 1.1)
				b:cylZ(0.05, 1.1, f * CFrame.new(0, 0, 0.115), black, "RadRim")
				b:cylZ(0.05, 1.02, f * CFrame.new(0, 0, 0.13), yellow, "RadDisc")
				-- aspas del trébol: cada una = 3 cuadriláteros (arco interior/exterior), triángulos bien formados
				local bp = f * CFrame.new(0, 0, 0.2) -- en relieve (cara trasera de la cuña por delante del disco)
				for _, deg in { 30, 150, 270 } do
					local steps = 2
					for k = 0, steps - 1 do
						local a0 = math.rad(deg - 30 + 60 * k / steps)
						local a1 = math.rad(deg - 30 + 60 * (k + 1) / steps)
						local function pt(r, a)
							return bp:PointToWorldSpace(Vector3.new(math.cos(a) * r, math.sin(a) * r, 0))
						end
						b:triangle(pt(0.14, a0), pt(0.46, a0), pt(0.46, a1), 0.05, black, "RadBlade")
						b:triangle(pt(0.14, a0), pt(0.46, a1), pt(0.14, a1), 0.05, black, "RadBlade")
					end
				end
				b:cylZ(0.09, 0.22, f * CFrame.new(0, 0, 0.18), black, "RadCenter")
				local dot = b:cylZ(0.03, 0.09, f * CFrame.new(0, 0, 0.23), greenCore, "RadDot")
				b:pulse({ dot }, 0, 0.6, 2.2)
			end)
			-- arriba: celdas verdes encendidas en un marco
			local top = headY + CH / 2
			b:bevelBox(Vector3.new(1.06, 0.12, 1.4), CFrame.new(ccx, top + 0.05, 0), armorDark, 0.04, { edges = "Y", edgeStyle = edge, name = "TopFrame" })
			for i, x in { -0.25, 0.25 } do
				local c = b:box(Vector3.new(0.3, 0.1, 1.1), CFrame.new(ccx + x, top + 0.12, 0), green, "TopCell")
				b:box(Vector3.new(0.34, 0.08, 1.14), CFrame.new(ccx + x, top + 0.16, 0), glass, "TopCellGlass")
				b:pulse({ c }, 0, 0.3, 1.1, i * 0.3)
			end
			b:box(Vector3.new(0.08, 0.12, 1.2), CFrame.new(ccx, top + 0.16, 0), edge, "TopDivider")

			-- ── remate derecho ───────────────────────────────
			local rcx = (RX0 + RX1) / 2
			b:bevelBox(Vector3.new(RX1 - RX0, RH, RD), CFrame.new(rcx, headY, 0), armor, 0.16, { edges = "all", edgeStyle = edge, name = "RightBlock" })
			local rBand = RX0 + 0.26
			B.both(function(s)
				hazard(B.faceZ(s, headY, RD / 2, rBand), 0.36, RH - 0.3)
				local f = B.faceZ(s, headY, RD / 2)
				for _, y in { -0.66, 0, 0.66 } do
					b:rivet(f:PointToWorldSpace(Vector3.new(s * (RX1 - 0.18), y, 0.02)), 0.11, steel)
				end
			end)
			for _, sy in { -1, 1 } do
				local pl = CFrame.new(rBand, headY + sy * RH / 2, 0) * CFrame.Angles(-sy * math.pi / 2, 0, 0)
				hazard(pl, 0.36, RD - 0.3)
			end
			-- cara de golpe +X: placa y rendijas verdes
			local rf = B.faceX(1, RX1, headY)
			b:bevelBox(Vector3.new(RD - 0.24, RH - 0.24, 0.1), rf * CFrame.new(0, 0, 0.04), armorDark, 0.14, { edges = "Z", edgeStyle = edge, name = "EndFrame" })
			for i, y in { -0.4, 0, 0.4 } do
				b:box(Vector3.new(1.08, 0.2, 0.05), rf * CFrame.new(0, y, 0.09), black, "SlotWell")
				local sl = b:box(Vector3.new(1.0, 0.13, 0.05), rf * CFrame.new(0, y, 0.11), green, "Slot")
				b:pulse({ sl }, 0, 0.4, 1.1, i * 0.25)
			end
			b:box(Vector3.new(1.06, 1.0, 0.04), rf * CFrame.new(0, 0, 0.14), glass, "SlotGlass")

			-- ── baba radiactiva escurriendo ──────────────────
			local bot = headY - CH / 2
			drip(Vector3.new((LX1 + CX0) / 2, bot - 0.06, 0.5), 0.42, 0.14)
			drip(Vector3.new((CX1 + RX0) / 2, bot - 0.06, -0.48), 0.3, 0.13)
			drip(Vector3.new(ccx + 0.38, bot - 0.02, 0.7), 0.22, 0.11)
			drip(Vector3.new(LX0 + 0.35, headY - LH / 2 - 0.02, -0.55), 0.26, 0.12)
			-- charco de baba sobre los bordes de las cápsulas (arriba)
			b:box(Vector3.new(0.5, 0.08, 0.5), CFrame.new((LX1 + CX0) / 2, headY + CH / 2 + 0.07, 0.48), slime, "SlimeTop")
			b:box(Vector3.new(0.5, 0.08, 0.5), CFrame.new((CX1 + RX0) / 2, headY + CH / 2 + 0.07, -0.48), slime, "SlimeTop")
			b:cylY(0.32, 0.12, CFrame.new((LX1 + CX0) / 2 + 0.18, headY + CH / 2 - 0.12, 0.74), slime, "SlimeRun")
		end)

		-- ── mango ───────────────────────────────────────────────
		local gripTop = 1.7
		b:group("Shaft", function()
			local top = headY - CH / 2
			b:bevelBox(Vector3.new(0.86, 0.3, 0.86), CFrame.new(0, top - 0.15, 0), armor, 0.18, { edges = "Y", edgeStyle = edge, name = "Collar" })
			for i = 0, 3 do
				local a = TAU * i / 4 + TAU / 8
				b:rivet(Vector3.new(math.cos(a) * 0.43, top - 0.15, math.sin(a) * 0.43), 0.1, steel)
			end
			b:cylY(0.12, 0.66, CFrame.new(0, top - 0.36, 0), steel, "CollarRing")
			local s0, s1 = A.ShaftBottom, top - 0.36
			b:cylY(s1 - s0, 0.52, CFrame.new(0, (s0 + s1) / 2, 0), black, "Shaft")
			-- espiral de peligro amarilla
			b:wrap(-0.8, gripTop - 0.1, 0.26, 3, yellow, { width = 0.22, thickness = 0.045, segmentsPerTurn = 8, name = "HazardWrap" })
			-- bandas de acero negro
			for _, y in { gripTop, 0.45, -0.88 } do
				b:cylY(0.2, 0.66, CFrame.new(0, y, 0), armor, "Band")
				b:cylY(0.05, 0.7, CFrame.new(0, y, 0), edge, "BandEdge")
			end
			-- anillo verde brillante cerca del pomo
			b:cylY(0.06, 0.7, CFrame.new(0, -1.02, 0), armorDark, "GlowRingLip")
			local ring = b:cylY(0.2, 0.6, CFrame.new(0, -1.15, 0), green, "GlowRing")
			b:cylY(0.22, 0.68, CFrame.new(0, -1.15, 0), glass, "GlowRingGlass")
			b:pulse({ ring }, 0, 0.3, 1.1, 0.6)
		end)

		-- ── pomo ────────────────────────────────────────────────
		b:group("Pommel", function()
			local y = A.PommelY - 0.06
			b:bevelBox(Vector3.new(0.86, 0.36, 0.86), CFrame.new(0, y, 0), armor, 0.22, { edges = "Y", edgeStyle = edge, name = "Pommel" })
			b:bevelBox(Vector3.new(0.7, 0.1, 0.7), CFrame.new(0, y - 0.22, 0), armorDark, 0.18, { edges = "Y", edgeStyle = edge, name = "PommelCap" })
			for i = 0, 3 do
				local a = TAU * i / 4 + TAU / 8
				b:rivet(Vector3.new(math.cos(a) * 0.43, y, math.sin(a) * 0.43), 0.11, steel)
				-- cuadritos amarillos de peligro en las caras del octágono
				b:box(Vector3.new(0.04, 0.18, 0.18), CFrame.new(math.cos(a - TAU / 8) * 0.43, y, math.sin(a - TAU / 8) * 0.43) * CFrame.Angles(0, -(a - TAU / 8), 0), yellow, "PommelMark")
			end
			b:cylY(0.04, 0.3, CFrame.new(0, y - 0.28, 0), green, "PommelGlow")
		end)

		-- ── efectos ─────────────────────────────────────────────
		b:group("FX", function()
			local v = b:fxVolume(Vector3.new(4, 2.2, 2.2), CFrame.new(0, headY, 0), "RadVolume")
			b:emitter(v, B.Particles.sparkle(greenC, 8), "RadSparkle")
			local haze = B.Particles.orb(greenC, 4)
			haze.Size = B.seq(0, 0, 0.3, 0.45, 1, 0)
			haze.Acceleration = Vector3.new(0, 0.6, 0)
			b:emitter(v, haze, "RadHaze")
			-- burbujas subiendo dentro de las cápsulas
			for i, gap in { { LX1, CX0 }, { CX1, RX0 } } do
				local bv = b:fxVolume(Vector3.new(0.2, 1.2, 1.1), CFrame.new((gap[1] + gap[2]) / 2, headY - 0.1, 0), "BubbleVolume")
				local bub = B.Particles.orb(greenHot, 3)
				bub.Size = B.seq(0, 0.06, 1, 0.1)
				bub.Speed = NumberRange.new(0.4, 0.8)
				bub.EmissionDirection = Enum.NormalId.Top
				bub.SpreadAngle = Vector2.new(5, 5)
				bub.Lifetime = NumberRange.new(0.8, 1.2)
				b:emitter(bv, bub, "Bubbles" .. i)
			end
			-- llamitas radiactivas que lamen la parte de arriba (como en el concepto)
			local fv = b:fxVolume(Vector3.new(1.0, 0.1, 1.1), CFrame.new((CX0 + CX1) / 2, headY + CH / 2 + 0.2, 0), "FlameVolume")
			local fl = B.Particles.flame(greenC, 7)
			fl.Size = B.seq(0, 0.3, 0.5, 0.42, 1, 0)
			fl.Speed = NumberRange.new(0.8, 1.6)
			fl.Lifetime = NumberRange.new(0.3, 0.55)
			b:emitter(fv, fl, "RadFlames")
			-- goteo desde la baba
			local bot = headY - CH / 2
			for i, p in { Vector3.new((LX1 + CX0) / 2, bot - 0.55, 0.5), Vector3.new((CX1 + RX0) / 2, bot - 0.42, -0.48) } do
				b:emitter(p, B.Particles.drip(greenC, 2), "Drip" .. i)
			end
		end)
		b:light(Vector3.new(0, headY, 0), greenC, 1.0, 9, { pulse = { 0.6, 1.5 }, pulseSpeed = 1.1, name = "RadLight" })
		b:light(Vector3.new(LX0 - 0.4, headY, 0), greenC, 0.6, 5, { pulse = { 0.3, 0.8 }, pulseSpeed = 1.1, name = "WindowLight" })

		-- impacto: chispas verdes + salpicadura de baba + destello tóxico
		local splash = B.Particles.drip(greenC, 0)
		splash.Speed = NumberRange.new(4, 8)
		splash.SpreadAngle = Vector2.new(70, 70)
		splash.EmissionDirection = Enum.NormalId.Top
		splash.Acceleration = Vector3.new(0, -18, 0)
		local burst = B.Particles.sparkle(greenHot, 0)
		burst.Speed = NumberRange.new(6, 12)
		burst.Size = B.seq(0, 0.45, 1, 0)
		local haze = B.Particles.orb(greenC, 0)
		haze.Speed = NumberRange.new(2, 4)
		haze.Size = B.seq(0, 0.3, 0.3, 0.9, 1, 0)
		haze.Lifetime = NumberRange.new(0.4, 0.8)
		local hit = b:impact(CFrame.new(LX0 - 0.25, headY, 0), greenC, { sparks = 24, flash = 8, extra = { splash, burst, haze } })
		hit:FindFirstChild("ImpactExtra1"):SetAttribute("FX_Emit", 16)
		hit:FindFirstChild("ImpactExtra2"):SetAttribute("FX_Emit", 20)
		hit:FindFirstChild("ImpactExtra3"):SetAttribute("FX_Emit", 6)
		b:trail(Vector3.new(0, headY + CH / 2 + 0.2, 0), Vector3.new(0, headY - CH / 2 - 0.2, 0), greenHot, P.rgb(255, 210, 30), { lifetime = 0.22 })
	end,
}
