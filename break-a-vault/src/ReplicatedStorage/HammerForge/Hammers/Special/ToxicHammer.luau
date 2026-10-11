-- Toxic Hammer (Special) — un mazo de acero oscuro de laboratorio que se está deshaciendo en residuo
-- radiactivo. La cabeza son TRES bloques de acero biselado (remates a los lados y bloque central) unidos
-- por dos BANDAS DE SLIME verde neón encapsuladas en vidrio que se desbordan: goterones que escurren por
-- las caras, charcos encima y gotas largas que cuelgan por debajo y se mecen. En el bloque central, un
-- panel negro con marco de acero y remaches lleva el SÍMBOLO DE RADIACIÓN (disco lima brillante con aspas
-- negras) que GIRA lento. Caras de golpe con placa, puerto redondo de neón y remaches. Burbujas de vidrio
-- con núcleo tóxico flotan alrededor de la cabeza. Mango de hule negro acanalado, collar de acero con
-- slime escurriendo, venda verde cruzada y pomo de bronce con cápsula tóxica.
-- FX: goteo verde, burbujas que suben, vapor tóxico, destellos; luz verde que late; impacto con
-- salpicadura de slime, burbujas y vapor.
return {
	Id = "ToxicHammer",
	DisplayName = "Toxic Hammer",
	Rarity = "Special",
	Order = 1,
	Theme = "Toxic Lab",
	Build = function(b, P, B)
		local A = B.Anatomy
		local headY = A.HeadY + 0.1
		local H, D = 2.0, 1.9

		-- ── estilos ─────────────────────────────────────────────
		local toxC = P.rgb(120, 255, 40)
		local steel = P.metal(P.rgb(46, 49, 54), 0.08)
		local steelAlt = P.metal(P.rgb(60, 64, 70), 0.1)
		local steelEdge = P.metal(P.rgb(150, 158, 164), 0.2)
		local steelDark = P.metal(P.rgb(34, 36, 40), 0.06)
		local panel = P.metal(P.rgb(22, 24, 26), 0.04)
		local rivetSt = P.metal(P.rgb(176, 182, 186), 0.24)
		local slime = P.neon(P.rgb(64, 200, 18))
		local slimeDeep = P.neon(P.rgb(40, 150, 12))
		local slimeHot = P.neon(P.rgb(190, 255, 80))
		local slimeShell = P.glass(P.rgb(50, 140, 24), 0.45)
		local bubbleShell = P.glass(P.rgb(150, 255, 90), 0.6, 0.4)
		local lime = P.paint(P.rgb(196, 236, 40))
		local limeGlow = P.neon(P.rgb(170, 255, 40))
		local blade = P.metal(P.rgb(16, 18, 14), 0.08)
		local rubber = P.leather(P.rgb(24, 26, 28))
		local rubberRib = P.leather(P.rgb(44, 46, 50))
		local wrapA = P.fabric(P.rgb(126, 214, 40))
		local wrapB = P.fabric(P.rgb(84, 160, 30))
		local bronze = P.metal(P.rgb(150, 112, 64), 0.16)

		-- sector de anillo sólido (aspa del trébol) con tiras de triángulos: más limpio que triangular el polígono
		local function sector(plane: CFrame, r1: number, r2: number, a0: number, a1: number, n: number, t: number, st, name)
			local out = {}
			local function pt(r, a)
				return plane:PointToWorldSpace(Vector3.new(math.cos(a) * r, math.sin(a) * r, 0))
			end
			for i = 0, n - 1 do
				local u0 = a0 + (a1 - a0) * i / n
				local u1 = a0 + (a1 - a0) * (i + 1) / n
				for _, w in b:triangle(pt(r2, u0), pt(r2, u1), pt(r1, u1), t, st, name) do
					table.insert(out, w)
				end
				for _, w in b:triangle(pt(r2, u0), pt(r1, u1), pt(r1, u0), t, st, name) do
					table.insert(out, w)
				end
			end
			return out
		end

		local glow = {}
		local function G(p)
			table.insert(glow, p)
			return p
		end

		-- ── medidas ────────────────────────────────────────────
		local capW = 0.66
		local bandW = 0.42
		local cX = 0.86 -- media longitud del bloque central
		local bandX = cX + bandW / 2 -- centro de banda
		local capX = cX + bandW + capW / 2 -- centro de remate
		local X1 = cX + bandW + capW -- extremo (1.94)
		local yTop, yBot = headY + H / 2, headY - H / 2

		-- gota que cuelga: lámina pegada + tallo + bulbo con cáscara de vidrio
		local dripParts = {}
		local function drip(x: number, z: number, len: number, r: number, y0: number?)
			local top = y0 or yBot
			local list = {}
			table.insert(list, G(b:ball(r * 2.4, Vector3.new(x, top + 0.02, z), slime, "SlimeLip")))
			table.insert(list, G(b:cylY(len, r * 1.1, CFrame.new(x, top - len / 2, z), slime, "DripStem")))
			table.insert(list, G(b:ball(r * 1.6, Vector3.new(x, top - len * 0.55, z), slime, "DripNeck")))
			table.insert(list, G(b:ball(r * 2.2, Vector3.new(x, top - len, z), slimeHot, "DripBulb")))
			table.insert(list, b:ball(r * 2.7, Vector3.new(x, top - len - 0.02, z), slimeShell, "DripShell"))
			for _, p in list do
				table.insert(dripParts, p)
			end
			return list
		end
		-- goterón sobre una cara (escurre hacia abajo pegado a la superficie)
		local function faceRun(x: number, zs: number, yStart: number, len: number, w: number)
			G(b:box(Vector3.new(w, len, 0.06), CFrame.new(x, yStart - len / 2, zs), slime, "SlimeRun"))
			G(b:ball(w * 1.45, Vector3.new(x, yStart - len, zs), slimeHot, "SlimeRunTip"))
		end

		b:group("Head", function()
			-- ── remates (±X) ─────────────────────────────────
			B.both(function(s)
				local cf = CFrame.new(s * capX, headY, 0)
				b:bevelBox(Vector3.new(capW, H + 0.16, D + 0.16), cf, steel, 0.15, { edgeStyle = steelEdge, name = "Cap" })
				-- aro de refuerzo pegado a la banda
				b:bevelBox(Vector3.new(0.1, H + 0.24, D + 0.24), CFrame.new(s * (cX + bandW + 0.05), headY, 0), steelAlt, 0.05, { edges = "X", edgeStyle = steelEdge, name = "CapFlange" })
				-- placas en ±Z con remaches y canal
				B.both(function(t)
					local z = t * ((D + 0.16) / 2 + 0.03)
					local face = B.faceZ(t, headY, (D + 0.16) / 2 + 0.03, s * capX)
					b:box(Vector3.new(capW - 0.2, H - 0.3, 0.06), face, steelAlt, "CapPlate")
					b:box(Vector3.new(0.05, H - 0.75, 0.05), face * CFrame.new(0, -0.05, 0.035), steelDark, "CapGroove")
					b:rivet(Vector3.new(s * capX, headY + H / 2 - 0.32, z + 0.03), 0.17, rivetSt)
					b:rivet(Vector3.new(s * capX, headY - H / 2 + 0.32, z + 0.03), 0.17, rivetSt)
					-- salpicaduras de slime cerca de la banda
					G(b:ball(0.16, Vector3.new(s * (cX + bandW + 0.16), headY + 0.45, z + 0.02), slimeHot, "Splat"))
					G(b:ball(0.1, Vector3.new(s * (cX + bandW + 0.24), headY + 0.2, z + 0.02), slime, "Splat"))
				end)
				-- tapa superior del remate
				b:box(Vector3.new(capW - 0.18, 0.06, D - 0.2), CFrame.new(s * capX, yTop + 0.1, 0), steelAlt, "CapTop")

				-- ── cara de golpe: placa + puerto de neón ──────
				local px = s * (X1 + 0.06)
				b:bevelBox(Vector3.new(0.12, H + 0.02, D + 0.02), CFrame.new(px, headY, 0), steelAlt, 0.05, { edges = "X", edgeStyle = steelEdge, name = "StrikePlate" })
				b:cylinder(0.08, 1.02, CFrame.new(s * (X1 + 0.15), headY, 0), steelEdge, "PortRing")
				b:cylinder(0.08, 0.84, CFrame.new(s * (X1 + 0.17), headY, 0), panel, "PortSeat")
				G(b:cylinder(0.08, 0.62, CFrame.new(s * (X1 + 0.19), headY, 0), slime, "PortCore"))
				b:cylinder(0.08, 0.7, CFrame.new(s * (X1 + 0.22), headY, 0), slimeShell, "PortGlass")
				local sf = B.faceX(s, X1 + 0.27, headY)
				-- mini trébol en el puerto
				for i = 0, 2 do
					local a = math.pi / 2 + i * math.pi * 2 / 3
					b:box(Vector3.new(0.17, 0.15, 0.04), sf * CFrame.Angles(0, 0, a) * CFrame.new(0.17, 0, 0), blade, "PortBlade")
				end
				b:cylinder(0.05, 0.1, CFrame.new(s * (X1 + 0.27), headY, 0), blade, "PortHub")
				for _, cy in { 1, -1 } do
					for _, cz in { 1, -1 } do
						b:rivet(Vector3.new(s * (X1 + 0.13), headY + cy * (H / 2 - 0.16), cz * (D / 2 - 0.16)), 0.16, rivetSt)
					end
				end
			end)

			-- ── bloque central ───────────────────────────────
			b:bevelBox(Vector3.new(cX * 2, H, D), CFrame.new(0, headY, 0), steel, 0.13, { edgeStyle = steelEdge, name = "CenterBlock" })
			-- tapa superior con rejilla de ventilación tóxica
			b:bevelBox(Vector3.new(1.3, 0.08, D - 0.36), CFrame.new(0, yTop + 0.04, 0), steelAlt, 0.035, { edges = "Y", edgeStyle = steelEdge, name = "TopPlate" })
			for i = -1, 1 do
				b:box(Vector3.new(0.82, 0.04, 0.14), CFrame.new(0, yTop + 0.09, i * 0.36), panel, "VentSlot")
				G(b:box(Vector3.new(0.76, 0.04, 0.07), CFrame.new(0, yTop + 0.1, i * 0.36), slimeHot, "VentGlow"))
			end
			-- abajo: ojo del mango
			b:bevelBox(Vector3.new(0.86, 0.1, 0.86), CFrame.new(0, yBot - 0.05, 0), steelAlt, 0.04, { edges = "Y", edgeStyle = steelEdge, name = "EyePlate" })

			-- ── paneles de emblema con símbolo de radiación ──
			local trefoil = {}
			B.both(function(s)
				local z0 = D / 2
				local face = B.faceZ(s, headY, z0 + 0.03)
				b:box(Vector3.new(1.44, 1.56, 0.06), face, panel, "EmblemPanel")
				-- marco
				local fr = 0.12
				for _, sy in { 1, -1 } do
					b:box(Vector3.new(1.48, fr, 0.1), face * CFrame.new(0, sy * (0.78 - fr / 2), 0.03), steelEdge, "EmblemFrame")
					b:box(Vector3.new(fr, 1.56 - 2 * fr, 0.1), face * CFrame.new(sy * (0.74 - fr / 2), 0, 0.03), steelEdge, "EmblemFrame")
				end
				for _, cx in { 1, -1 } do
					for _, cy in { 1, -1 } do
						b:rivet(face:PointToWorldSpace(Vector3.new(cx * 0.62, cy * 0.66, 0.09)), 0.17, rivetSt)
					end
				end
				-- disco lima brillante + aro de acero
				local disc = face * CFrame.new(0, 0, 0.05)
				b:cylZ(0.06, 1.0, disc, lime, "TrefoilDisc")
				G(b:cylZ(0.06, 1.16, face * CFrame.new(0, 0, 0.035), limeGlow, "TrefoilGlow"))
				b:ring(face * CFrame.new(0, 0, 0.08) * CFrame.Angles(math.pi / 2, 0, 0), 0.62, 0.09, 14, steelEdge, "TrefoilRing", 0.1)
				-- aspas (giran)
				local bf = face * CFrame.new(0, 0, 0.16)
				for i = 0, 2 do
					local a = math.pi / 2 + i * math.pi * 2 / 3
					for _, p in sector(bf, 0.15, 0.45, a - math.pi / 6, a + math.pi / 6, 2, 0.05, blade, "TrefoilBlade") do
						table.insert(trefoil, { p, s })
					end
				end
				table.insert(trefoil, { b:cylZ(0.1, 0.22, bf * CFrame.new(0, 0, -0.03), blade, "TrefoilHub"), s })
				table.insert(trefoil, { G(b:cylZ(0.06, 0.08, bf * CFrame.new(0, 0, 0.02), slimeHot, "TrefoilEye")), s })
				-- goterones que bajan desde el borde superior del panel
				faceRun(-0.45, s * (z0 + 0.03), headY + 0.82, 0.22, 0.07)
			end)
			local front, back = {}, {}
			for _, e in trefoil do
				table.insert(if e[2] > 0 then front else back, e[1])
			end
			b:animate(front, B.faceZ(1, headY, D / 2 + 0.19), { Spin = Vector3.new(0, 0, 0.9) })
			b:animate(back, B.faceZ(-1, headY, D / 2 + 0.19), { Spin = Vector3.new(0, 0, 0.9) })

			-- ── bandas de slime ──────────────────────────────
			B.both(function(s)
				local x = s * bandX
				G(b:box(Vector3.new(bandW + 0.02, H - 0.1, D - 0.1), CFrame.new(x, headY, 0), slimeDeep, "SlimeCore"))
				b:box(Vector3.new(bandW - 0.02, H + 0.02, D + 0.02), CFrame.new(x, headY, 0), slimeShell, "SlimeGlass")
				-- flejes de acero que sujetan la banda
				for _, cy in { 0.62, -0.62 } do
					b:box(Vector3.new(bandW + 0.04, 0.14, D + 0.12), CFrame.new(x, headY + cy, 0), steelDark, "BandStrap")
				end
				-- goterones que se desbordan sobre las caras
				B.both(function(t)
					local zs = t * (D / 2 + 0.03)
					G(b:ball(0.34, Vector3.new(x + s * 0.02, headY + 0.25, zs - t * 0.08), slimeHot, "Ooze"))
					G(b:ball(0.26, Vector3.new(x - s * 0.1, headY - 0.18, zs - t * 0.06), slime, "Ooze"))
					G(b:ball(0.22, Vector3.new(x + s * 0.08, headY - 0.3, zs - t * 0.05), slime, "Ooze"))
					faceRun(x + s * 0.06, zs, headY - 0.3, 0.42, 0.11)
					faceRun(x - s * 0.12, zs, headY + 0.6, 0.3, 0.08)
					b:ball(0.4, Vector3.new(x + s * 0.02, headY + 0.25, zs - t * 0.08), slimeShell, "OozeGlass")
				end)
				-- charco encima que se derrama
				G(b:cylY(0.08, 0.72, CFrame.new(x, yTop + 0.03, 0.1), slime, "Puddle"))
				G(b:ball(0.34, Vector3.new(x + s * 0.12, yTop + 0.06, -0.35), slimeHot, "PuddleBlob"))
				G(b:ball(0.26, Vector3.new(x - s * 0.08, yTop + 0.05, 0.55), slime, "PuddleBlob"))
				G(b:ball(0.2, Vector3.new(x + s * 0.3, yTop + 0.08, 0.3), slimeHot, "PuddleBlob"))
				-- charco abajo (de donde cuelgan las gotas)
				G(b:cylY(0.08, 0.6, CFrame.new(x, yBot - 0.02, 0), slime, "UnderPool"))
			end)
		end)

		-- ── gotas colgantes (se mecen) ──────────────────────────
		b:group("Drips", function()
			drip(-bandX - 0.05, 0.42, 0.85, 0.09)
			drip(-bandX + 0.1, -0.35, 0.45, 0.07)
			drip(bandX + 0.05, 0.38, 0.62, 0.085)
			drip(bandX - 0.08, -0.4, 1.0, 0.095)
			drip(bandX + 0.15, 0.0, 0.32, 0.065)
			drip(-0.55, 0.55, 0.38, 0.07)
			drip(0.6, -0.55, 0.28, 0.06)
		end)
		b:animate(dripParts, CFrame.new(0, yBot, 0), { Bob = Vector3.new(0, 0.05, 0), BobSpeed = 0.7 })
		-- gotas sueltas cayendo
		local loose = {}
		for i, d in { { -bandX - 0.05, 0.42, yBot - 1.32, 0.15 }, { bandX - 0.08, -0.4, yBot - 1.45, 0.13 }, { bandX + 0.05, 0.38, yBot - 1.05, 0.1 } } do
			local core = G(b:ball(d[4], Vector3.new(d[1], d[3], d[2]), slimeHot, "LooseDrop"))
			local sh = b:ball(d[4] * 1.3, Vector3.new(d[1], d[3], d[2]), slimeShell, "LooseDropShell")
			b:animate({ core, sh }, CFrame.new(d[1], d[3], d[2]), { Bob = Vector3.new(0, 0.14, 0), BobSpeed = 0.9, Phase = i * 0.33 })
			table.insert(loose, core)
		end

		-- ── burbujas flotando ───────────────────────────────────
		b:group("Bubbles", function()
			local defs = {
				{ -2.25, headY + 1.25, 0.4, 0.38 }, { -1.1, headY + 1.45, -0.3, 0.26 }, { 0.3, headY + 1.6, 0.45, 0.2 },
				{ 1.5, headY + 1.3, -0.2, 0.32 }, { 2.35, headY + 0.6, 0.35, 0.22 }, { -2.45, headY - 0.2, -0.3, 0.2 },
				{ 2.4, headY - 0.9, -0.4, 0.16 }, { -0.4, headY + 1.2, -0.9, 0.16 },
			}
			for i, d in defs do
				local pos = Vector3.new(d[1], d[2], d[3])
				local sh = b:ball(d[4], pos, bubbleShell, "Bubble")
				local core = G(b:ball(d[4] * 0.55, pos, slime, "BubbleCore"))
				b:animate({ sh, core }, CFrame.new(pos), { Bob = Vector3.new(0.04, 0.16, 0.03), BobSpeed = 0.35 + (i % 4) * 0.08, Phase = i * 0.41 })
			end
		end)

		-- ── mango ───────────────────────────────────────────────
		b:group("Shaft", function()
			local top = yBot - 0.1
			local bottom = A.ShaftBottom
			b:cylY(top - bottom, 0.36, CFrame.new(0, (top + bottom) / 2, 0), steelDark, "ShaftCore")
			-- collar de acero con remaches
			local cy = top - 0.2
			b:cylY(0.34, 0.74, CFrame.new(0, cy, 0), steel, "Collar")
			b:cylY(0.07, 0.82, CFrame.new(0, cy + 0.15, 0), steelEdge, "CollarRim")
			b:cylY(0.07, 0.82, CFrame.new(0, cy - 0.15, 0), steelEdge, "CollarRim")
			for i = 0, 5 do
				local a = i * math.pi / 3 + 0.3
				b:rivet(Vector3.new(math.cos(a) * 0.37, cy, math.sin(a) * 0.37), 0.12, rivetSt)
			end
			-- slime escurriendo por el collar y el mango
			G(b:cylY(0.08, 0.6, CFrame.new(0, cy - 0.21, 0), slime, "CollarOoze"))
			faceRun(0.0, 0.27, cy - 0.2, 0.36, 0.1)
			G(b:box(Vector3.new(0.06, 0.38, 0.09), CFrame.new(0.22, cy - 0.38, 0.12) * CFrame.Angles(0, -0.5, 0), slime, "ShaftRun"))
			G(b:ball(0.13, Vector3.new(0.22, cy - 0.58, 0.12), slimeHot, "ShaftRunTip"))
			-- agarre superior de hule acanalado
			for i = 0, 5 do
				local y = 1.92 - i * 0.18
				b:cylY(0.11, 0.5, CFrame.new(0, y, 0), rubber, "GripRib")
				b:cylY(0.05, 0.44, CFrame.new(0, y - 0.09, 0), rubberRib, "GripGap")
			end
			-- venda verde cruzada
			b:cylY(1.5, 0.44, CFrame.new(0, 0.2, 0), P.fabric(P.rgb(40, 70, 24)), "WrapBase")
			local bands = { { -0.42, 0.34, 0.3 }, { -0.16, -0.34, 1.1 }, { 0.1, 0.34, 2.0 }, { 0.36, -0.34, 0.6 }, { 0.62, 0.34, 1.5 }, { 0.84, -0.3, 2.4 } }
			for i, t in bands do
				b:cylY(0.2, 0.54 - (i % 2) * 0.02, CFrame.new(0, t[1], 0) * CFrame.Angles(0, t[3], 0) * CFrame.Angles(t[2], 0, 0), if i % 2 == 0 then wrapB else wrapA, "Wrap")
			end
			b:cylY(0.1, 0.52, CFrame.new(0, 1.0, 0), steelDark, "WrapStop")
			b:cylY(0.1, 0.52, CFrame.new(0, -0.6, 0), steelDark, "WrapStop")
			-- agarre inferior acanalado
			for i = 0, 2 do
				local y = -0.76 - i * 0.17
				b:cylY(0.11, 0.48, CFrame.new(0, y, 0), rubber, "GripRib")
			end
		end)

		-- ── pomo de bronce con cápsula tóxica ───────────────────
		b:group("Pommel", function()
			local py = A.PommelY - 0.02
			b:cylY(0.16, 0.76, CFrame.new(0, py + 0.16, 0), bronze, "PommelBand")
			for i = 0, 3 do
				local a = i * math.pi / 2 + math.pi / 4
				b:rivet(Vector3.new(math.cos(a) * 0.38, py + 0.16, math.sin(a) * 0.38), 0.14, rivetSt)
			end
			b:bevelBox(Vector3.new(0.7, 0.32, 0.7), CFrame.new(0, py - 0.08, 0), steel, 0.14, { edges = "Y", edgeStyle = steelEdge, name = "PommelCap" })
			b:cylY(0.06, 0.56, CFrame.new(0, py - 0.26, 0), steelEdge, "PommelRim")
			G(b:ball(0.28, Vector3.new(0, py - 0.32, 0), slimeHot, "PommelCore"))
			b:ball(0.36, Vector3.new(0, py - 0.33, 0), bubbleShell, "PommelGlass")
			drip(0.2, 0.18, 0.22, 0.05, py - 0.2)
		end)

		b:pulse(glow, 0, 0.3, 0.8)

		-- ── efectos ─────────────────────────────────────────────
		b:group("FX", function()
			local under = b:fxVolume(Vector3.new(X1 * 2 - 0.4, 0.1, D - 0.3), CFrame.new(0, yBot - 0.08, 0), "DripVolume")
			b:emitter(under, B.Particles.drip(toxC, 6), "ToxicDrip")
			local bub = B.Particles.orb(P.rgb(150, 255, 70), 7)
			bub.Speed = NumberRange.new(0.3, 0.8)
			bub.Acceleration = Vector3.new(0, 1.2, 0)
			bub.Size = B.seq(0, 0, 0.25, 0.22, 1, 0.05)
			local bands = b:fxVolume(Vector3.new(X1 * 2, H, D + 0.2), CFrame.new(0, headY, 0), "BubbleVolume")
			b:emitter(bands, bub, "ToxicBubbles")
			b:emitter(bands, B.Particles.sparkle(P.rgb(180, 255, 80), 5), "ToxicSparkle")
			local vap = B.Particles.smoke(P.rgb(110, 200, 60), 3)
			vap.LightEmission = 0.3
			vap.Size = B.seq(0, 0.4, 1, 1.5)
			vap.Transparency = B.seq(0, 0.75, 0.4, 0.82, 1, 1)
			b:emitter(b:fxVolume(Vector3.new(X1 * 2 - 0.4, 0.1, D - 0.4), CFrame.new(0, yTop + 0.2, 0), "VaporVolume"), vap, "ToxicVapor")
		end)
		b:light(Vector3.new(0, headY, 0), toxC, 1.2, 10, { pulse = { 0.6, 1.6 }, pulseSpeed = 0.8, name = "ToxicGlow" })
		b:light(Vector3.new(0, yBot - 0.6, 0), P.rgb(150, 255, 60), 0.8, 6, { pulse = { 0.4, 1.1 }, pulseSpeed = 1.3, name = "DripGlow" })

		-- impacto: salpicadura de slime + burbujas + vapor
		local splash = B.Particles.drip(toxC, 0)
		splash.Speed = NumberRange.new(6, 12)
		splash.SpreadAngle = Vector2.new(70, 70)
		splash.EmissionDirection = Enum.NormalId.Top
		splash.Acceleration = Vector3.new(0, -24, 0)
		splash.Size = B.seq(0, 0.32, 1, 0.08)
		local pop = B.Particles.orb(P.rgb(170, 255, 90), 0)
		pop.Speed = NumberRange.new(2, 5)
		pop.Size = B.seq(0, 0.2, 0.3, 0.45, 1, 0)
		local gas = B.Particles.smoke(P.rgb(110, 210, 60), 0)
		gas.Speed = NumberRange.new(1.5, 3.5)
		gas.Size = B.seq(0, 0.8, 1, 2.6)
		local hit = b:impact(CFrame.new(-(X1 + 0.35), headY, 0), toxC, { sparks = 24, flash = 7, extra = { splash, pop, gas } })
		hit:FindFirstChild("ImpactExtra1"):SetAttribute("FX_Emit", 24)
		hit:FindFirstChild("ImpactExtra2"):SetAttribute("FX_Emit", 14)
		hit:FindFirstChild("ImpactExtra3"):SetAttribute("FX_Emit", 7)
		b:trail(Vector3.new(0, yTop, 0), Vector3.new(0, yBot, 0), P.rgb(210, 255, 120), P.rgb(40, 150, 20), { lifetime = 0.26 })
	end,
}
