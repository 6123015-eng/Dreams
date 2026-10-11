-- Rusty Hammer (Starter) — el primer martillo: un ladrillo de hierro viejo COMIDO POR EL ÓXIDO.
-- La cabeza son dos bloques de óxido naranja-café (el remate izquierdo rajado, chueco y con la esquina
-- de arriba despostillada a lo bruto) donde asoman parches de acero gris desnudo, biselados y un pelo
-- salidos, como si el óxido se hubiera descarapelado. Aristas gastadas más claras, escurrimientos de óxido
-- oscuro desde el lomo, remaches viejos. Caras de golpe: un anillo de óxido oscuro con un parche pulido
-- irregular encima, con dos abolladuras del uso. Mango de madera grueso y un poco cónico, venda de tela
-- en capas cruzadas con la punta suelta, y pomo de madera grande y astillado.
return {
	Id = "RustyHammer",
	DisplayName = "Rusty Hammer",
	Rarity = "Starter",
	Order = 1,
	Theme = "Starter Yard",
	Build = function(b, P, B)
		local A = B.Anatomy
		local headY = A.HeadY + 0.05
		local H, D = 1.95, 1.85

		-- ── estilos ─────────────────────────────────────────────
		local core = P.style(P.rgb(158, 80, 40), Enum.Material.CorrodedMetal, 0.02) -- óxido (base)
		local steel = P.style(P.rgb(132, 132, 134), Enum.Material.CorrodedMetal, 0.08) -- acero desnudo
		local steelEdge = P.style(P.rgb(176, 172, 166), Enum.Material.CorrodedMetal, 0.04)
		local rust = P.with(P.Rust, { Color = P.rgb(168, 82, 36) })
		local rustHot = P.with(P.RustOrange, { Color = P.rgb(206, 112, 50) })
		local rustDark = P.with(P.RustDark, { Color = P.rgb(78, 40, 24) })
		local worn = P.metal(P.rgb(196, 186, 172), 0.14) -- metal desnudo (raspones)
		local edgeRust = P.style(P.rgb(160, 138, 120), Enum.Material.CorrodedMetal, 0.04) -- arista gastada (acero asomando)
		local polish = P.metal(P.rgb(206, 208, 210), 0.3) -- cara de golpe pulida
		local shine = P.foil(P.rgb(236, 236, 232), 0.36)
		local wood = P.wood(P.rgb(168, 96, 46))
		local woodLight = P.wood(P.rgb(198, 126, 66))
		local woodDark = P.wood(P.rgb(108, 60, 30))
		local cloth = P.fabric(P.rgb(222, 204, 164))
		local clothDirty = P.fabric(P.rgb(184, 160, 118))

		-- ── helper: bloque biselado con despostilladuras ───────
		-- gaps = { {axis, a, b, t0, t1}, ... } quita un tramo del bisel (t en -1..1 a lo largo de la arista)
		-- y pone en el hueco un bisel hundido y oscuro: lee como esquina rota.
		local q = math.pi / 4
		local function chunk(size: Vector3, cf: CFrame, st, edgeSt, c: number, gaps, chipSt, name)
			local sx, sy, sz = size.X, size.Y, size.Z
			local d = c * math.sqrt(2)
			b:box(Vector3.new(sx, sy - 2 * c, sz - 2 * c), cf, st, name)
			b:box(Vector3.new(sx - 2 * c, sy, sz - 2 * c), cf, st, name)
			b:box(Vector3.new(sx - 2 * c, sy - 2 * c, sz), cf, st, name)
			local function gapsFor(axis, a, bb)
				local list = {}
				for _, g in gaps or {} do
					if g[1] == axis and g[2] == a and g[3] == bb then
						table.insert(list, { g[4], g[5] })
					end
				end
				table.sort(list, function(x, y) return x[1] < y[1] end)
				return list
			end
			for _, a in { -1, 1 } do
				for _, bb in { -1, 1 } do
					for _, axis in { "X", "Y", "Z" } do
						local len, pos, rot
						if axis == "X" then
							len, pos, rot = sx - 2 * c, Vector3.new(0, a * (sy / 2 - c), bb * (sz / 2 - c)), CFrame.Angles(q, 0, 0)
						elseif axis == "Y" then
							len, pos, rot = sy - 2 * c, Vector3.new(a * (sx / 2 - c), 0, bb * (sz / 2 - c)), CFrame.Angles(0, q, 0)
						else
							len, pos, rot = sz - 2 * c, Vector3.new(a * (sx / 2 - c), bb * (sy / 2 - c), 0), CFrame.Angles(0, 0, q)
						end
						local dir = if axis == "X" then Vector3.xAxis elseif axis == "Y" then Vector3.yAxis else Vector3.zAxis
						local function seg(t0, t1, segSt, dd, inset)
							local l = (t1 - t0) * len / 2
							if l < 0.02 then
								return
							end
							local mid = (t0 + t1) / 2 * len / 2
							local p = pos + dir * mid - (pos - dir * pos:Dot(dir)).Unit * inset
							local sz3 = if axis == "X" then Vector3.new(l, dd, dd) elseif axis == "Y" then Vector3.new(dd, l, dd) else Vector3.new(dd, dd, l)
							b:box(sz3, cf * CFrame.new(p) * rot, segSt, name .. "Edge")
						end
						local cur = -1
						for _, g in gapsFor(axis, a, bb) do
							seg(cur, g[1], edgeSt, d, 0)
							seg(g[1], g[2], chipSt, d * 1.05, c * 0.95) -- hueco: bisel hundido oscuro
							cur = g[2]
						end
						seg(cur, 1, edgeSt, d, 0)
					end
				end
			end
		end

		-- ── cabeza ──────────────────────────────────────────────
		local bodyX0, bodyX1 = -0.86, 1.66 -- cuerpo principal
		local capX0, capX1 = -1.92, -0.92 -- remate izquierdo (rajado)
		local capCF = CFrame.new((capX0 + capX1) / 2, headY + 0.02, 0) * CFrame.Angles(0.025, 0, math.rad(2.2))
		local capH, capD = H + 0.08, D + 0.06
		b:group("Head", function()
			chunk(Vector3.new(bodyX1 - bodyX0, H, D), CFrame.new((bodyX0 + bodyX1) / 2, headY, 0), core, edgeRust, 0.17, {
				{ "X", 1, 1, -0.55, -0.2 },
				{ "X", -1, -1, 0.35, 0.75 },
				{ "Y", 1, -1, -0.9, -0.35 },
				{ "Z", 1, 1, 0.1, 0.6 },
				{ "X", 1, -1, 0.5, 0.82 },
			}, rustDark, "HeadCore")
			-- remate izquierdo: torcido, biseles grandes y la esquina de arriba-izquierda rota (despostilladuras hondas)
			chunk(Vector3.new(capX1 - capX0, capH, capD), capCF, core, edgeRust, 0.26, {
				{ "X", 1, 1, -1, 0.15 },
				{ "X", 1, -1, -1, -0.2 },
				{ "Z", -1, 1, -0.9, 0.9 },
				{ "Y", -1, 1, 0.25, 1 },
				{ "Y", -1, -1, 0.45, 1 },
				{ "Y", 1, -1, -0.8, -0.2 },
			}, rustDark, "HeadCap")
			-- lajas rotas en la esquina: cuñas de metal desnudo dentro del despostillado
			B.both(function(s)
				local c0 = capCF * CFrame.new(-(capX1 - capX0) / 2 + 0.2, capH / 2 - 0.2, s * (capD / 2 - 0.2))
				b:box(Vector3.new(0.18, 0.14, 0.14), c0 * CFrame.new(-0.04, 0.02, s * 0.02) * CFrame.Angles(0.5 * s, 0.4, 0.7), steel, "ChipFlake")
			end)
			b:box(Vector3.new(0.4, 0.2, 0.5), capCF * CFrame.new(0.05, capH / 2 - 0.12, 0.25) * CFrame.Angles(0.2, 0.5, 0.25), rustDark, "ChipPit")
			-- raja entre bloques (oscura, hundida)
			b:box(Vector3.new(0.12, H - 0.06, D - 0.06), CFrame.new(-0.89, headY, 0), rustDark, "Crack")

			-- caras de golpe: anillo de óxido oscuro + parche pulido irregular + 2 abolladuras
			local V = Vector2.new
			local function strikeFace(s, base, h, d, seed)
				local r = B.rng(seed)
				b:bevelBox(Vector3.new(0.12, h * 0.9, d * 0.88), base * CFrame.new(s * 0.04, 0, 0), rustDark, 0.12, { edges = "X", edgeStyle = rust, name = "StrikeRing" })
				local face = base * CFrame.new(s * 0.1, 0, 0) * CFrame.Angles(0, s * math.pi / 2, 0)
				local pts = {}
				for i = 0, 5 do
					local a = math.pi * 2 * i / 6 + 0.3
					local rr = r(0.56, 0.74)
					table.insert(pts, V(math.cos(a) * rr * d * 0.5, math.sin(a) * rr * h * 0.5))
				end
				b:shape(face, pts, 0.06, polish, "StrikePolish")
				b:box(Vector3.new(0.4, 0.3, 0.04), face * CFrame.new(0.06, 0.08, 0.03) * CFrame.Angles(0, 0, 0.35), shine, "StrikeShine")
				for _, dent in { { -0.3, 0.32, 0.26 }, { 0.36, -0.3, 0.2 } } do
					local dc = face * CFrame.new(dent[1], dent[2], 0.03)
					b:cylZ(0.03, dent[3] + 0.06, dc, worn, "DentRim")
					b:cylZ(0.04, dent[3], dc * CFrame.new(0, 0, 0.01), rustDark, "Dent")
				end
			end
			strikeFace(1, CFrame.new(bodyX1, headY, 0), H, D, 11)
			strikeFace(-1, capCF * CFrame.new(-(capX1 - capX0) / 2, 0, 0), capH, capD, 23)

			-- ojo arriba: anillo de hierro, punta del mango y cuña metálica
			b:bevelBox(Vector3.new(0.72, 0.14, 0.72), CFrame.new(0.15, headY + H / 2 + 0.06, 0), rustDark, 0.06, { edges = "Y", edgeStyle = rustHot, name = "EyeRing" })
			b:cylY(0.14, 0.5, CFrame.new(0.15, headY + H / 2 + 0.1, 0), woodDark, "ShaftTop")
			b:box(Vector3.new(0.56, 0.07, 0.1), CFrame.new(0.15, headY + H / 2 + 0.17, 0) * CFrame.Angles(0, math.rad(32), 0), worn, "IronWedge")
			-- parches de acero en el lomo
			b:box(Vector3.new(0.7, 0.06, 0.5), CFrame.new(1.05, headY + H / 2, -0.3) * CFrame.Angles(0, 0.2, 0), steel, "SteelPatch")
			b:box(Vector3.new(0.5, 0.06, 0.4), CFrame.new(-0.45, headY + H / 2, 0.35) * CFrame.Angles(0, -0.3, 0), steel, "SteelPatch")

			-- caras de emblema (±Z): parches de acero desnudo, escurrimientos de óxido oscuro, raspones, remaches
			B.both(function(s)
				local zs = D / 2
				local face = B.faceZ(s, headY, zs)
				local n = face.LookVector
				local k = s -- espeja X para que cada cara sea distinta
				-- {x, y, w, h, rot, biselado?}
				local patches = if s > 0
					then { { 0.1, 0.2, 0.9, 0.62, 0.05, true }, { 1.05, -0.42, 0.6, 0.44, -0.08, true }, { -0.42, -0.5, 0.5, 0.36, 0.12, true }, { 1.15, 0.5, 0.34, 0.28, 0.2, false }, { 0.55, -0.62, 0.3, 0.2, -0.15, false } }
					else { { 0.75, 0.12, 0.8, 0.7, -0.06, true }, { -0.25, -0.4, 0.66, 0.4, 0.1, true }, { 0.05, 0.55, 0.42, 0.26, -0.14, true }, { 1.3, -0.5, 0.3, 0.3, 0.25, false }, { -0.55, 0.3, 0.26, 0.22, -0.2, false } }
				for _, p in patches do
					local cf = face * CFrame.new(p[1] * k + 0.4 * (1 - k), p[2], 0.02) * CFrame.Angles(0, 0, p[5])
					if p[6] then
						-- arista clara (como bisel) + parche
						b:box(Vector3.new(p[3] + 0.06, p[4] + 0.06, 0.04), cf * CFrame.new(0, 0, -0.01), steelEdge, "SteelPatchEdge")
						b:box(Vector3.new(p[3], p[4], 0.06), cf, steel, "SteelPatch")
					else
						b:box(Vector3.new(p[3], p[4], 0.06), cf, steel, "SteelPatch")
					end
				end
				-- escurrimientos de óxido oscuro desde la arista de arriba
				for i, x in { -0.35, 0.62, 1.32 } do
					local len = 0.5 + 0.2 * ((i + (if s > 0 then 0 else 1)) % 3)
					b:box(Vector3.new(0.06, len, 0.05), face * CFrame.new(x * k + 0.4 * (1 - k), H / 2 - 0.17 - len / 2, 0.025), rustDark, "RustStreak")
				end
				-- raspón brillante sobre el parche grande
				b:line(face:PointToWorldSpace(Vector3.new(-0.2 * k + 0.4 * (1 - k), 0.36, 0.06)), face:PointToWorldSpace(Vector3.new(0.4 * k + 0.4 * (1 - k), 0.16, 0.06)), 0.04, 0.03, worn, n, "Scratch")
				-- remaches viejos: dos en el remate rajado, dos en el cuerpo
				local capFace = capCF * CFrame.new(0.06, 0, s * (capD / 2 + 0.01))
				for _, y in { -0.6, 0.45 } do
					b:rivet(capFace:PointToWorldSpace(Vector3.new(0, y, 0)), 0.2, rustHot)
				end
				b:rivet(Vector3.new(bodyX1 - 0.28, headY + 0.66, s * (zs + 0.02)), 0.17, rustDark)
				b:rivet(Vector3.new(bodyX1 - 0.28, headY - 0.66, s * (zs + 0.02)), 0.17, rustHot)
			end)
		end)

		-- ── mango: madera gruesa y un poco cónica ───────────────
		local shaftBottom = A.ShaftBottom + 0.3
		b:group("Shaft", function()
			local top = headY - H / 2 - 0.05
			-- tramo de arriba (más grueso) y tramo de abajo (más delgado); el escalón queda bajo la venda
			local split = 0.2
			b:bevelBox(Vector3.new(0.64, top - split, 0.64), CFrame.new(0, (top + split) / 2, 0), wood, 0.13, { edges = "Y", edgeStyle = woodLight, name = "Shaft" })
			b:bevelBox(Vector3.new(0.57, split - shaftBottom, 0.57), CFrame.new(0, (split + shaftBottom) / 2, 0), wood, 0.12, { edges = "Y", edgeStyle = woodLight, name = "Shaft" })
			b:box(Vector3.new(0.05, 1.1, 0.03), CFrame.new(0.08, 1.55, 0.33), woodDark, "Grain")
			b:box(Vector3.new(0.05, 0.85, 0.03), CFrame.new(-0.07, 1.4, -0.33), woodDark, "Grain")
			b:box(Vector3.new(0.03, 0.95, 0.05), CFrame.new(0.33, 1.5, -0.06), woodDark, "Grain")
			-- collar de madera bajo la cabeza
			b:bevelBox(Vector3.new(0.76, 0.38, 0.76), CFrame.new(0, top - 0.2, 0), woodDark, 0.11, { edges = "Y", edgeStyle = wood, name = "Collar" })

			-- venda: 7 vueltas de tela inclinadas y encimadas (alternando dirección) + punta suelta
			local bandDia = 0.74
			local turns = {
				{ -0.62, 0.24, 0.2 }, { -0.42, -0.26, 0.2 }, { -0.2, 0.26, 0.2 }, { 0.02, -0.26, 0.2 },
				{ 0.24, 0.26, 0.2 }, { 0.46, -0.26, 0.2 }, { 0.64, 0.2, 0.2 },
			}
			for i, t in turns do
				b:cylY(0.24, bandDia - (i % 2) * 0.03, CFrame.new(0, t[1], 0) * CFrame.Angles(0, t[3], 0) * CFrame.Angles(t[2], 0, 0), if i % 2 == 0 then clothDirty else cloth, "Bandage")
			end
			b:disc(CFrame.new(0, -0.78, 0), bandDia - 0.06, 0.12, clothDirty, "BandageEnd")
			-- punta suelta de la venda
			b:box(Vector3.new(0.05, 0.5, 0.2), CFrame.new(bandDia / 2 - 0.02, 0.52, 0.14) * CFrame.Angles(0.15, 0, math.rad(-14)), clothDirty, "BandageTail")
			b:box(Vector3.new(0.05, 0.22, 0.17), CFrame.new(bandDia / 2 + 0.04, 0.2, 0.18) * CFrame.Angles(0.2, 0, math.rad(-30)), cloth, "BandageTail")
		end)

		-- ── pomo grande y astillado ─────────────────────────────
		b:group("Pommel", function()
			local y = shaftBottom - 0.24
			b:bevelBox(Vector3.new(0.8, 0.46, 0.8), CFrame.new(0, y, 0), woodDark, 0.14, { edges = "Y", edgeStyle = wood, name = "Pommel" })
			b:cylY(0.06, 0.6, CFrame.new(0, y - 0.24, 0), woodLight, "EndGrain")
			b:cylY(0.065, 0.3, CFrame.new(0, y - 0.25, 0), woodDark, "EndRing")
			-- astillas
			b:wedge(Vector3.new(0.12, 0.2, 0.1), CFrame.new(0.24, y - 0.28, 0.16) * CFrame.Angles(math.pi, 0.4, 0), wood, "Splinter")
			b:wedge(Vector3.new(0.1, 0.16, 0.09), CFrame.new(-0.2, y - 0.27, -0.18) * CFrame.Angles(math.pi, 2.2, 0), woodLight, "Splinter")
			b:box(Vector3.new(0.82, 0.08, 0.82), CFrame.new(0, y + 0.25, 0), rustDark, "PommelBand")
		end)

		-- ── efectos ─────────────────────────────────────────────
		b:impact(CFrame.new(capX0 - 0.2, headY, 0), P.rgb(255, 156, 72), {
			sparks = 16,
			extra = { B.Particles.smoke(P.rgb(150, 96, 62), 0) },
		})
		b:trail(Vector3.new(0, headY + H / 2, 0), Vector3.new(0, headY - H / 2, 0), P.rgb(240, 214, 186), P.rgb(170, 100, 60), { lifetime = 0.18 })
	end,
}
