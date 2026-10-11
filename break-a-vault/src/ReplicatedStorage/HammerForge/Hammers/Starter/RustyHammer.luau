-- Rusty Hammer (Starter) — el primer martillo: un ladrillo de hierro viejo, gris acero comido por el óxido.
-- La cabeza está hecha de dos bloques (el remate izquierdo rajado y medio chueco por tanto golpe),
-- con esquinas despostilladas que rompen la silueta, aristas gastadas más claras, manchas y escurrimientos
-- de óxido, remaches viejos y caras de golpe pulidas por el uso (con su "punto de impacto" brillante).
-- Mango octagonal de madera con vetas, venda de tela cruzada en el agarre y pomo de madera astillado.
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
		local core = P.style(P.rgb(124, 112, 104), Enum.Material.CorrodedMetal, 0.05) -- acero viejo
		local rust = P.with(P.Rust, { Color = P.rgb(168, 82, 36) })
		local rustHot = P.with(P.RustOrange, { Color = P.rgb(206, 112, 50) })
		local rustDark = P.with(P.RustDark, { Color = P.rgb(78, 40, 24) })
		local worn = P.metal(P.rgb(196, 186, 172), 0.14) -- metal desnudo (raspones)
		local edgeRust = P.style(P.rgb(214, 128, 66), Enum.Material.CorrodedMetal, 0.02) -- arista gastada clara
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
		local capX0, capX1 = -1.78, -0.9 -- remate izquierdo (rajado)
		b:group("Head", function()
			chunk(Vector3.new(bodyX1 - bodyX0, H, D), CFrame.new((bodyX0 + bodyX1) / 2, headY, 0), core, edgeRust, 0.16, {
				{ "X", 1, 1, -0.55, -0.2 },
				{ "X", -1, -1, 0.35, 0.75 },
				{ "Y", 1, -1, -0.9, -0.35 },
				{ "Z", 1, 1, 0.1, 0.6 },
				{ "X", 1, -1, 0.5, 0.82 },
			}, rustDark, "HeadCore")
			-- remate izquierdo: un poco más grande y torcido (golpeado)
			local capCF = CFrame.new((capX0 + capX1) / 2, headY + 0.02, 0) * CFrame.Angles(0.025, 0, math.rad(2.2))
			chunk(Vector3.new(capX1 - capX0, H + 0.08, D + 0.06), capCF, core, edgeRust, 0.2, {
				{ "Y", -1, 1, 0.2, 0.75 },
				{ "X", 1, -1, -0.8, -0.1 },
				{ "Z", -1, -1, -0.7, -0.15 },
			}, rustDark, "HeadCap")
			-- raja entre bloques (oscura, hundida)
			b:box(Vector3.new(0.12, H - 0.06, D - 0.06), CFrame.new(-0.88, headY, 0), rustDark, "Crack")

			-- caras de golpe pulidas con "punto de impacto"
			local function strikeFace(s, x, base)
				local pcf = base * CFrame.new(s * 0.07, 0, 0)
				b:box(Vector3.new(0.1, H * 0.9, D * 0.88), base * CFrame.new(-s * 0.01, 0, 0), rust, "StrikeLip")
				b:bevelBox(Vector3.new(0.14, H * 0.78, D * 0.76), pcf, polish, 0.07, { edges = "X", edgeStyle = worn, name = "StrikeFace" })
				-- zona brillante del uso: cuadro pulido un poco chueco
				b:box(Vector3.new(0.05, H * 0.5, D * 0.46), pcf * CFrame.new(s * 0.07, 0.05, -0.04) * CFrame.Angles(math.rad(9), 0, 0), shine, "StrikeShine")
			end
			strikeFace(1, bodyX1, CFrame.new(bodyX1, headY, 0))
			strikeFace(-1, capX0, capCF * CFrame.new(-(capX1 - capX0) / 2, 0, 0))

			-- ojo arriba: anillo de hierro, punta del mango y cuña metálica
			b:bevelBox(Vector3.new(0.62, 0.14, 0.62), CFrame.new(0.15, headY + H / 2 + 0.06, 0), rust, 0.05, { edges = "Y", edgeStyle = rustHot, name = "EyeRing" })
			b:cylY(0.14, 0.42, CFrame.new(0.15, headY + H / 2 + 0.1, 0), woodDark, "ShaftTop")
			b:box(Vector3.new(0.48, 0.07, 0.1), CFrame.new(0.15, headY + H / 2 + 0.17, 0) * CFrame.Angles(0, math.rad(32), 0), worn, "IronWedge")
			-- abajo: salida del ojo
			b:box(Vector3.new(0.6, 0.1, 0.6), CFrame.new(0.15, headY - H / 2 - 0.04, 0) * CFrame.Angles(0, q, 0), rust, "EyeRingLow")

			-- caras de emblema (±Z): manchas de óxido en capas, escurrimientos, raspones, remaches
			B.both(function(s)
				local zs = D / 2
				local face = B.faceZ(s, headY, zs + 0.015)
				local n = face.LookVector
				local function spot(x, y, w, h, rot, st, z)
					b:box(Vector3.new(w, h, 0.04), face * CFrame.new(x, y, z or 0) * CFrame.Angles(0, 0, rot), st, "RustSpot")
				end
				-- óxido que "trepa" desde las aristas (franjas irregulares pegadas al borde)
				spot(0.35, H / 2 - 0.26, 1.1, 0.18, 0.04, rust)
				spot(1.0, H / 2 - 0.3, 0.5, 0.26, -0.12, rustHot, 0.012)
				spot(-0.2, -H / 2 + 0.27, 0.9, 0.2, -0.05, rust)
				spot(1.25, -H / 2 + 0.32, 0.42, 0.3, 0.1, rustDark, 0.006)
				-- mancha central en capas (oscura → óxido → óxido vivo), girada distinto cada capa
				spot(0.45, 0.12, 0.7, 0.4, 0.16, rustDark)
				spot(0.52, 0.16, 0.56, 0.28, -0.12, rust, 0.012)
				spot(0.4, 0.12, 0.26, 0.14, 0.22, rustHot, 0.024)
				-- salpicado
				spot(-0.35, -0.3, 0.34, 0.16, 0.14, rust)
				spot(-0.6, 0.42, 0.26, 0.15, -0.2, rustHot)
				spot(1.12, -0.12, 0.22, 0.12, -0.15, rust)
				spot(-1.36, -0.25, 0.28, 0.44, 0.2, rust) -- en el remate
				-- escurrimientos de óxido desde la arista superior
				for i, x in { -0.12, 0.72, 1.3 } do
					local len = 0.3 + 0.13 * i
					b:box(Vector3.new(0.06, len, 0.04), face * CFrame.new(x, H / 2 - 0.3 - len / 2, 0.018), rustHot, "RustDrip")
				end
				-- raspones de metal desnudo (brillan)
				b:line(face:PointToWorldSpace(Vector3.new(-0.1, 0.66, 0.02)), face:PointToWorldSpace(Vector3.new(0.65, 0.5, 0.02)), 0.05, 0.04, worn, n, "Scratch")
				b:line(face:PointToWorldSpace(Vector3.new(0.15, -0.25, 0.02)), face:PointToWorldSpace(Vector3.new(0.9, -0.68, 0.02)), 0.045, 0.04, worn, n, "Scratch")
				-- remaches viejos: dos en el remate rajado, dos en el cuerpo
				local capFace = capCF * CFrame.new(0, 0, s * ((D + 0.06) / 2 + 0.02))
				for _, y in { -0.62, 0.62 } do
					b:rivet(capFace:PointToWorldSpace(Vector3.new(0, y, 0)), 0.18, rustHot)
				end
				b:rivet(Vector3.new(bodyX1 - 0.3, headY + 0.64, s * (zs + 0.02)), 0.16, rustDark)
				b:rivet(Vector3.new(bodyX1 - 0.3, headY - 0.64, s * (zs + 0.02)), 0.16, rustHot)
			end)
		end)

		-- ── mango ───────────────────────────────────────────────
		local shaftW = 0.48
		b:group("Shaft", function()
			local bottom, top = A.ShaftBottom + 0.05, headY - H / 2 - 0.05
			local mid = (top + bottom) / 2
			-- octágono de madera (bisel en Y) con vetas
			b:bevelBox(Vector3.new(shaftW, top - bottom, shaftW), CFrame.new(0, mid, 0), wood, 0.1, { edges = "Y", edgeStyle = woodLight, name = "Shaft" })
			b:box(Vector3.new(0.04, 1.2, 0.03), CFrame.new(0.07, 1.75, shaftW / 2 + 0.008), woodDark, "Grain")
			b:box(Vector3.new(0.04, 0.9, 0.03), CFrame.new(-0.06, 1.55, -shaftW / 2 - 0.008), woodDark, "Grain")
			b:box(Vector3.new(0.03, 1.0, 0.04), CFrame.new(shaftW / 2 + 0.008, 1.65, -0.05), woodDark, "Grain")
			-- collar de madera bajo la cabeza (bloque como en el concepto)
			b:bevelBox(Vector3.new(0.6, 0.36, 0.6), CFrame.new(0, top - 0.2, 0), woodDark, 0.09, { edges = "Y", edgeStyle = wood, name = "Collar" })

			-- venda cruzada: discos de tela inclinados en direcciones alternas (barato y lee como vendaje en X)
			local bandDia = 0.64
			local turns = {
				{ -0.58, 0.36, 0.2 }, { -0.3, -0.36, 0.2 }, { -0.02, 0.36, 1.3 },
				{ 0.26, -0.36, 1.3 }, { 0.54, 0.34, 0.5 },
			}
			for i, t in turns do
				b:cylY(0.26, bandDia - (i % 2) * 0.03, CFrame.new(0, t[1], 0) * CFrame.Angles(0, t[3], 0) * CFrame.Angles(t[2], 0, 0), if i % 2 == 0 then clothDirty else cloth, "Bandage")
			end
			b:disc(CFrame.new(0, 0.8, 0), bandDia - 0.04, 0.2, cloth, "BandageEnd")
			b:disc(CFrame.new(0, -0.8, 0), bandDia - 0.04, 0.16, clothDirty, "BandageEnd")
			-- cola de la venda
			b:box(Vector3.new(0.05, 0.42, 0.18), CFrame.new(bandDia / 2 + 0.01, 0.58, 0.1) * CFrame.Angles(0, 0, math.rad(-10)), clothDirty, "BandageTail")
		end)

		-- ── pomo ────────────────────────────────────────────────
		b:group("Pommel", function()
			local y = A.PommelY + 0.05
			b:bevelBox(Vector3.new(0.6, 0.36, 0.6), CFrame.new(0, y, 0), woodDark, 0.11, { edges = "Y", edgeStyle = wood, name = "Pommel" })
			b:cylY(0.06, 0.46, CFrame.new(0, y - 0.19, 0), woodLight, "EndGrain")
			-- astillas
			b:wedge(Vector3.new(0.1, 0.16, 0.08), CFrame.new(0.18, y - 0.22, 0.12) * CFrame.Angles(math.pi, 0.4, 0), wood, "Splinter")
			b:wedge(Vector3.new(0.08, 0.13, 0.07), CFrame.new(-0.15, y - 0.21, -0.14) * CFrame.Angles(math.pi, 2.2, 0), woodLight, "Splinter")
			b:box(Vector3.new(0.62, 0.07, 0.62), CFrame.new(0, y + 0.2, 0), rustDark, "PommelBand")
		end)

		-- ── efectos ─────────────────────────────────────────────
		b:impact(CFrame.new(capX0 - 0.2, headY, 0), P.rgb(255, 156, 72), {
			sparks = 16,
			extra = { B.Particles.smoke(P.rgb(150, 96, 62), 0) },
		})
		b:trail(Vector3.new(0, headY + H / 2, 0), Vector3.new(0, headY - H / 2, 0), P.rgb(240, 214, 186), P.rgb(170, 100, 60), { lifetime = 0.18 })
	end,
}
