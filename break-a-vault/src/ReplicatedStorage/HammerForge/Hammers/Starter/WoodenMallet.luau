-- Wooden Mallet (Starter) — mazo gordo de taller: la cabeza es un barrilito de duelas de madera
-- (12 duelas en 3 tramos, ligeramente abombado como barril de verdad), con los anillos del tronco
-- marcados en capas sobre las dos caras de golpe (con grietas), dos aros de hierro con remaches y bordes
-- brillantes, mango de tabla con vetas, venda de tela cruzada y pomo de madera astillado. Cálido y "cozy".
return {
	Id = "WoodenMallet",
	DisplayName = "Wooden Mallet",
	Rarity = "Starter",
	Order = 2,
	Theme = "Starter Yard",
	Build = function(b, P, B)
		local A = B.Anatomy
		local headY = A.HeadY + 0.1
		local L, R = 3.4, 1.03 -- largo del barril (X) y radio

		-- ── estilos ─────────────────────────────────────────────
		local woods = {
			P.wood(P.rgb(206, 116, 48)),
			P.wood(P.rgb(228, 140, 62)),
			P.wood(P.rgb(186, 100, 42)),
		}
		local woodCore = P.wood(P.rgb(62, 32, 16))
		local woodDark = P.wood(P.rgb(118, 66, 32))
		local endLight = P.wood(P.rgb(240, 172, 92)) -- madera de corte (más clara)
		local endRing = P.wood(P.rgb(170, 100, 48))
		local iron = P.metal(P.rgb(70, 74, 84), 0.08)
		local ironEdge = P.metal(P.rgb(150, 158, 172), 0.2)
		local rivetSt = P.metal(P.rgb(176, 182, 192), 0.24)
		local cloth = P.fabric(P.rgb(226, 208, 168))
		local clothDirty = P.fabric(P.rgb(190, 166, 124))
		local rand = B.rng(42)

		-- ── cabeza: barril de duelas ───────────────────────────
		local bandX = 0.92 -- centro de los aros (±X)
		b:group("Head", function()
			b:cylinder(L - 0.1, 2 * (R - 0.16), CFrame.new(0, headY, 0), woodCore, "BarrelCore")
			local n = 12
			local t = 0.24 -- grosor de duela
			local w = 2 * R * math.sin(math.pi / n) * 0.9 -- deja ranura oscura entre duelas
			local shrink = 0.08 -- cuánto se cierra el barril hacia las puntas
			for i = 0, n - 1 do
				local th = (i + 0.5) * 2 * math.pi / n
				local st = woods[(i % 3) + 1]
				local jitter = rand(-0.012, 0.018)
				local rot = CFrame.new(0, headY, 0) * CFrame.Angles(th, 0, 0)
				-- tramo central (recto)
				b:box(Vector3.new(2 * bandX + 0.02, t, w), rot * CFrame.new(0, R - t / 2 + jitter, 0), st, "Stave")
				-- tramos de las puntas (se cierran un poco: barril abombado)
				local segLen = L / 2 - bandX
				local phi = math.atan(shrink / segLen)
				B.both(function(s)
					local cx = s * (bandX + segLen / 2)
					b:box(Vector3.new(segLen + 0.02, t, w), rot * CFrame.new(cx, R - t / 2 - shrink / 2 + jitter, 0) * CFrame.Angles(0, 0, -s * phi), st, "Stave")
				end)
			end
			-- nudos de la madera sobre algunas duelas
			for _, k in { { 0.35, 0.4 }, { -0.55, 2.3 }, { 0.2, 3.6 }, { -0.25, 5.0 } } do
				local rot = CFrame.new(0, headY, 0) * CFrame.Angles(k[2], 0, 0)
				b:cylY(0.04, 0.16, rot * CFrame.new(k[1], R + 0.012, 0), woodDark, "Knot")
			end

			-- aros de hierro: banda oscura + labios brillantes + remaches
			B.both(function(s)
				local x = s * bandX
				b:cylinder(0.4, 2 * R + 0.12, CFrame.new(x, headY, 0), iron, "Band")
				for _, e in { -1, 1 } do
					b:cylinder(0.05, 2 * R + 0.17, CFrame.new(x + e * 0.185, headY, 0), ironEdge, "BandLip")
				end
				for j = 0, 7 do
					local a = (j + (if s > 0 then 0.5 else 0)) * math.pi / 4
					b:rivet(CFrame.new(x, headY, 0) * CFrame.Angles(a, 0, 0) * CFrame.new(0, R + 0.06, 0), 0.15, rivetSt)
				end
			end)

			-- caras de golpe: anillos del tronco en capas (cada anillo sale un poco más) + grietas
			B.both(function(s)
				local x0 = s * (L / 2 - 0.035)
				local full = 2 * (R - 0.08) - 0.03 -- cubre la punta de las duelas: toda la cara es corte de tronco
				local rings = { { full, endLight }, { full - 0.12, endRing }, { full - 0.22, endLight }, { 1.22, endRing }, { 1.12, endLight }, { 0.74, endRing }, { 0.64, endLight }, { 0.28, endRing }, { 0.18, endLight } }
				for i, rr in rings do
					b:cylinder(0.06, rr[1], CFrame.new(x0 + s * (0.015 * i), headY, 0), rr[2], "EndGrain")
				end
				-- grietas radiales (oscuras, encima de los anillos)
				local fx = x0 + s * 0.17
				local a1, a2 = (if s > 0 then 0.6 else 2.4), (if s > 0 then 3.9 else 5.2)
				for k, a in { a1, a2 } do
					local dir = Vector3.new(0, math.sin(a), math.cos(a))
					local r0 = 0.25 + k * 0.08
					b:line(Vector3.new(fx, headY, 0) + dir * r0, Vector3.new(fx, headY, 0) + dir * 0.78, 0.045, 0.03, woodCore, Vector3.new(s, 0, 0), "Crack")
				end
			end)

			-- donde entra el mango: placa de hierro curva + cuña arriba
			b:bevelBox(Vector3.new(0.78, 0.16, 0.78), CFrame.new(0, headY - R + 0.06, 0), iron, 0.06, { edges = "Y", edgeStyle = ironEdge, name = "EyePlate" })
			b:cylY(0.06, 0.42, CFrame.new(0, headY + R + 0.005, 0), endLight, "ShaftTop")
			b:box(Vector3.new(0.44, 0.06, 0.08), CFrame.new(0, headY + R + 0.035, 0) * CFrame.Angles(0, math.rad(90), 0), iron, "Wedge")
		end)

		-- ── mango ───────────────────────────────────────────────
		local shaftW = 0.52
		local wood = woods[1]
		local woodLight = woods[2]
		b:group("Shaft", function()
			local bottom, top = A.ShaftBottom + 0.05, headY - R + 0.05
			b:bevelBox(Vector3.new(shaftW, top - bottom, shaftW), CFrame.new(0, (top + bottom) / 2, 0), wood, 0.1, { edges = "Y", edgeStyle = woodLight, name = "Shaft" })
			b:box(Vector3.new(0.04, 1.1, 0.03), CFrame.new(0.08, 1.7, shaftW / 2 + 0.008), woodDark, "Grain")
			b:box(Vector3.new(0.04, 0.8, 0.03), CFrame.new(-0.07, 1.45, -shaftW / 2 - 0.008), woodDark, "Grain")
			b:box(Vector3.new(0.03, 0.9, 0.04), CFrame.new(shaftW / 2 + 0.008, 1.6, 0.06), woodDark, "Grain")
			b:box(Vector3.new(0.03, 0.7, 0.04), CFrame.new(-shaftW / 2 - 0.008, 1.9, -0.04), woodDark, "Grain")

			-- venda cruzada (discos de tela inclinados)
			local bandDia = 0.7
			local turns = {
				{ -0.58, 0.36, 0.3 }, { -0.3, -0.36, 0.3 }, { -0.02, 0.36, 1.4 },
				{ 0.26, -0.36, 1.4 }, { 0.54, 0.34, 0.6 },
			}
			for i, tt in turns do
				b:cylY(0.26, bandDia - (i % 2) * 0.03, CFrame.new(0, tt[1], 0) * CFrame.Angles(0, tt[3], 0) * CFrame.Angles(tt[2], 0, 0), if i % 2 == 0 then clothDirty else cloth, "Bandage")
			end
			b:disc(CFrame.new(0, 0.8, 0), bandDia - 0.04, 0.2, cloth, "BandageEnd")
			b:disc(CFrame.new(0, -0.8, 0), bandDia - 0.04, 0.16, clothDirty, "BandageEnd")
			b:box(Vector3.new(0.05, 0.42, 0.18), CFrame.new(bandDia / 2 + 0.01, 0.6, -0.1) * CFrame.Angles(0, 0, math.rad(-10)), clothDirty, "BandageTail")
		end)

		-- ── pomo ────────────────────────────────────────────────
		b:group("Pommel", function()
			local y = A.PommelY + 0.05
			b:bevelBox(Vector3.new(0.64, 0.38, 0.64), CFrame.new(0, y, 0), woodDark, 0.11, { edges = "Y", edgeStyle = wood, name = "Pommel" })
			b:cylY(0.06, 0.5, CFrame.new(0, y - 0.2, 0), endLight, "EndGrain")
			b:cylY(0.065, 0.22, CFrame.new(0, y - 0.2, 0), endRing, "EndGrainRing")
			b:wedge(Vector3.new(0.1, 0.16, 0.08), CFrame.new(0.17, y - 0.22, 0.12) * CFrame.Angles(math.pi, 0.4, 0), wood, "Splinter")
			b:wedge(Vector3.new(0.08, 0.13, 0.07), CFrame.new(-0.15, y - 0.21, -0.13) * CFrame.Angles(math.pi, 2.2, 0), woodLight, "Splinter")
			b:box(Vector3.new(0.66, 0.08, 0.66), CFrame.new(0, y + 0.21, 0), iron, "PommelBand")
		end)

		-- ── efectos ─────────────────────────────────────────────
		local chips = B.Particles.ember(P.rgb(214, 150, 84), 0)
		chips.LightEmission = 0.15
		chips.Brightness = 1
		chips.Acceleration = Vector3.new(0, -22, 0)
		chips.Speed = NumberRange.new(8, 14)
		chips.SpreadAngle = Vector2.new(60, 60)
		chips.Size = B.seq(0, 0.22, 1, 0.12)
		b:impact(CFrame.new(-(L / 2 + 0.2), headY, 0), P.rgb(255, 196, 120), {
			sparks = 10,
			extra = { chips, B.Particles.smoke(P.rgb(176, 136, 96), 0) },
		})
		b:trail(Vector3.new(0, headY + R, 0), Vector3.new(0, headY - R, 0), P.rgb(255, 226, 180), P.rgb(200, 130, 70), { lifetime = 0.18 })
	end,
}
