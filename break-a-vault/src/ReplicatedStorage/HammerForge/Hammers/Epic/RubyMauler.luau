-- Ruby Mauler (Epic) — un rubí gigante encadenado en hierro negro: la cabeza es un bloque de rubí
-- facetado (punta de diamante en cada cara) con un NÚCLEO de neón rojo que late adentro, sujeto por
-- dos marcos de hierro negro erizados de picos de acero. A los lados, dos rubíes más chicos con
-- caras de golpe facetadas, cada uno enmarcado en hierro con picos en las esquinas apuntando afuera.
-- Mango forrado de cuero rojo en espiral con amarres oscuros, collar de hierro remachado y pomo de
-- hierro con tachones. FX: destellos rojos, motas de luz carmesí, luz del núcleo pulsante,
-- impacto con esquirlas de rubí.
return {
	Id = "RubyMauler",
	DisplayName = "Ruby Mauler",
	Rarity = "Epic",
	Order = 2,
	Theme = "Gem Mine",
	Build = function(b, P, B)
		local A = B.Anatomy
		local headY = A.HeadY + 0.05

		-- ── estilos ─────────────────────────────────────────────
		local red = P.rgb(230, 24, 52)
		local ruby = P.crystal(P.rgb(150, 4, 26), 0.06)
		local rubyFacet = P.crystal(P.rgb(214, 20, 48), 0.06)
		local rubyEdge = P.crystal(P.rgb(255, 80, 104), 0.04) -- arista brillante
		local rubyDeep = P.crystal(P.rgb(120, 6, 24), 0.08)
		local core = P.neon(P.rgb(255, 30, 60))
		local coreHot = P.neon(P.rgb(255, 64, 84))
		local iron = P.metal(P.rgb(72, 74, 82), 0.1)
		local ironEdge = P.metal(P.rgb(150, 154, 166), 0.16)
		local ironDark = P.Blackened
		local spikeSt = P.metal(P.rgb(160, 166, 178), 0.08) -- acero pulido
		local chrome = P.Chrome
		local leather = P.leather(P.rgb(150, 30, 30))
		local leatherDark = P.leather(P.rgb(70, 16, 18))

		-- ── helpers ─────────────────────────────────────────────
		-- CFrame en `pos` cuya Y local apunta en `dir` (para picos)
		local function along(pos: Vector3, dir: Vector3): CFrame
			local up = dir.Unit
			local ref = if math.abs(up.Y) < 0.9 then Vector3.yAxis else Vector3.xAxis
			local vx = up:Cross(ref).Unit
			local vz = vx:Cross(up).Unit
			return CFrame.fromMatrix(pos, vx, up, vz)
		end
		local function spike(pos: Vector3, dir: Vector3, len: number, w: number, sides: number?)
			-- base metida un poco en la superficie para que no se vea el hueco
			b:pyramid(along(pos - dir.Unit * 0.04, dir), len + 0.04, w, sides or 4, spikeSt, "Spike")
		end

		-- ── medidas ────────────────────────────────────────────
		local CW, CH, CD = 1.5, 1.95, 1.95 -- rubí central
		local bandW, BH, BD = 0.34, 2.22, 2.22 -- marcos de hierro
		local bx = CW / 2 + bandW / 2 - 0.02
		local EX0, EX1 = bx + bandW / 2 - 0.02, 1.76
		local EW, EH, ED = EX1 - EX0, 1.8, 1.8 -- rubíes de los extremos
		local ex = (EX0 + EX1) / 2
		local frameX = EX1 + 0.06

		local coreParts = {}

		b:group("Head", function()
			-- ── rubí central con núcleo ────────────────────────
			table.insert(coreParts, b:box(Vector3.new(CW - 0.5, CH - 0.6, CD - 0.6), CFrame.new(0, headY, 0), core, "Core"))
			b:box(Vector3.new(CW - 0.3, CH - 0.3, CD - 0.3), CFrame.new(0, headY, 0) * CFrame.Angles(0, math.pi / 4, 0), rubyDeep, "InnerFacets")
			b:bevelBox(Vector3.new(CW, CH, CD), CFrame.new(0, headY, 0), ruby, 0.26, { edgeStyle = rubyEdge, name = "Ruby" })
			-- punta de diamante en ambas caras de emblema (facetas como en el concepto)
			B.both(function(s)
				local base = CFrame.new(0, headY, s * (CD / 2 - 0.02)) * CFrame.Angles(s * math.pi / 2, 0, 0)
				b:pyramid(base, 0.34, CW - 0.18, 4, rubyFacet, "Facet", 0.06)
				-- chispa de luz dentro de la punta
				table.insert(coreParts, b:box(Vector3.new(0.22, 0.22, 0.06), CFrame.new(0, headY, s * (CD / 2 + 0.06)) * CFrame.Angles(0, 0, math.pi / 4), coreHot, "FacetSpark"))
			end)
			-- arriba y abajo: facetas planas giradas
			for _, sy in { 1, -1 } do
				b:box(Vector3.new(0.9, 0.06, 0.9), CFrame.new(0, headY + sy * (CH / 2 + 0.01), 0) * CFrame.Angles(0, math.pi / 4, 0), rubyFacet, "TopFacet")
			end

			-- ── marcos de hierro con picos ─────────────────────
			B.both(function(sx)
				local x = sx * bx
				b:bevelBox(Vector3.new(bandW, BH, BD), CFrame.new(x, headY, 0), iron, 0.1, { edges = "X", edgeStyle = ironEdge, name = "Band" })
				-- reborde interior más oscuro (lee como marco con profundidad)
				b:box(Vector3.new(bandW + 0.04, BH - 0.5, BD - 0.5), CFrame.new(x, headY, 0), ironDark, "BandInner")
				-- picos: arriba, abajo, y uno por cara de emblema
				spike(Vector3.new(x, headY + BH / 2, 0), Vector3.yAxis, 0.6, 0.3)
				spike(Vector3.new(x, headY - BH / 2, 0), -Vector3.yAxis, 0.42, 0.26)
				for _, sz in { 1, -1 } do
					spike(Vector3.new(x, headY + 0.34, sz * BD / 2), Vector3.new(0, 0.25, sz), 0.48, 0.28)
					b:rivet(Vector3.new(x, headY - 0.62, sz * (BD / 2 + 0.01)), 0.15, chrome)
					b:rivet(Vector3.new(x, headY + 0.86, sz * (BD / 2 + 0.01)), 0.12, chrome)
				end

				-- ── rubí del extremo ───────────────────────────
				local ecf = CFrame.new(sx * ex, headY, 0)
				table.insert(coreParts, b:box(Vector3.new(EW - 0.1, EH - 0.6, ED - 0.6), ecf, core, "EndCore"))
				b:bevelBox(Vector3.new(EW, EH, ED), ecf, ruby, 0.3, { edges = "X", edgeStyle = rubyEdge, name = "EndRuby" })
				-- grieta/faceta diagonal en las caras ±Z
				for _, sz in { 1, -1 } do
					b:box(Vector3.new(0.05, EH - 0.5, 0.04), ecf * CFrame.new(0, 0, sz * (ED / 2 + 0.005)) * CFrame.Angles(0, 0, sx * 0.5), rubyEdge, "FacetLine")
				end

				-- marco de hierro de la cara de golpe
				local fh = 1.9
				for _, sy in { 1, -1 } do
					b:box(Vector3.new(0.18, 0.22, fh), CFrame.new(sx * frameX, headY + sy * (fh / 2 - 0.11), 0), iron, "Frame")
					b:box(Vector3.new(0.05, 0.05, fh - 0.1), CFrame.new(sx * (frameX + 0.08), headY + sy * (fh / 2 - 0.02), 0), ironEdge, "FrameEdge")
				end
				for _, sz in { 1, -1 } do
					b:box(Vector3.new(0.18, fh - 0.44, 0.22), CFrame.new(sx * frameX, headY, sz * (fh / 2 - 0.11)), iron, "Frame")
					b:box(Vector3.new(0.05, fh - 0.44, 0.05), CFrame.new(sx * (frameX + 0.08), headY, sz * (fh / 2 - 0.02)), ironEdge, "FrameEdge")
				end
				-- cara de golpe: punta de rubí facetada con chispa
				local fbase = CFrame.new(sx * (EX1 - 0.02), headY, 0) * CFrame.Angles(0, 0, -sx * math.pi / 2)
				b:pyramid(fbase, 0.36, 1.36, 4, rubyFacet, "StrikeFacet", 0.06)
				table.insert(coreParts, b:box(Vector3.new(0.06, 0.24, 0.24), CFrame.new(sx * (EX1 + 0.08), headY, 0) * CFrame.Angles(math.pi / 4, 0, 0), coreHot, "StrikeSpark"))
				-- picos en las 4 esquinas, apuntando hacia afuera
				for _, cy in { 1, -1 } do
					for _, cz in { 1, -1 } do
						spike(Vector3.new(sx * (frameX + 0.06), headY + cy * (fh / 2 - 0.12), cz * (fh / 2 - 0.12)), Vector3.new(sx, cy * 0.55, cz * 0.55), 0.5, 0.24, 3)
					end
				end
			end)
		end)

		-- ── mango ───────────────────────────────────────────────
		b:group("Shaft", function()
			local top = headY - CH / 2
			local bottom = A.ShaftBottom
			b:cylY(top - bottom, 0.4, CFrame.new(0, (top + bottom) / 2, 0), iron, "ShaftCore")
			-- collar de hierro octagonal con tachones
			local cy = top - 0.22
			b:bevelBox(Vector3.new(0.7, 0.34, 0.7), CFrame.new(0, cy, 0), iron, 0.15, { edges = "Y", edgeStyle = ironEdge, name = "Collar" })
			b:cylY(0.08, 0.6, CFrame.new(0, cy - 0.21, 0), ironDark, "CollarLip")
			for i = 0, 3 do
				local a = math.pi / 2 * i + math.pi / 4
				b:rivet(Vector3.new(math.cos(a) * 0.29, cy, math.sin(a) * 0.29), 0.14, chrome)
			end
			-- agarre de cuero rojo en espiral con amarres oscuros
			local g0, g1 = -1.1, 1.75
			b:cylY(g1 - g0, 0.48, CFrame.new(0, (g0 + g1) / 2, 0), leatherDark, "GripBase")
			-- vueltas de cuero: discos inclinados alternados (lee como cuero cruzado) + cordón oscuro entre vueltas
			local n = 9
			local step = (g1 - g0) / n
			for i = 0, n - 1 do
				local y = g0 + step * (i + 0.5)
				local tilt = if i % 2 == 0 then 0.18 else -0.18
				b:cylY(step * 1.08, 0.56 - (i % 2) * 0.02, CFrame.new(0, y, 0) * CFrame.Angles(0, i * 0.7, 0) * CFrame.Angles(tilt, 0, 0), leather, "LeatherWrap")
			end
			-- cordón oscuro cruzado entre vueltas
			for i = 1, n - 1, 2 do
				b:cylY(0.05, 0.59, CFrame.new(0, g0 + step * i, 0) * CFrame.Angles(0, i * 0.9, 0) * CFrame.Angles(-0.3, 0, 0), leatherDark, "Cord")
			end
			for _, y in { g0, g1 } do
				b:cylY(0.14, 0.6, CFrame.new(0, y, 0), leatherDark, "Binding")
			end
		end)

		-- ── pomo ────────────────────────────────────────────────
		b:group("Pommel", function()
			local y = A.PommelY - 0.05
			b:bevelBox(Vector3.new(0.82, 0.5, 0.82), CFrame.new(0, y, 0), iron, 0.22, { edges = "Y", edgeStyle = ironEdge, name = "Pommel" })
			b:bevelBox(Vector3.new(0.66, 0.12, 0.66), CFrame.new(0, y - 0.3, 0), ironDark, 0.18, { edges = "Y", edgeStyle = iron, name = "PommelCap" })
			for i = 0, 3 do
				local a = math.pi / 2 * i
				b:rivet(Vector3.new(math.cos(a) * 0.42, y, math.sin(a) * 0.42), 0.2, spikeSt)
			end
			-- rubí en la base del pomo
			b:gem(CFrame.new(0, y - 0.4, 0), 0.2, rubyFacet, core)
		end)

		b:pulse(coreParts, 0, 0.45, 1.1)

		-- ── efectos ─────────────────────────────────────────────
		b:group("FX", function()
			local v = b:fxVolume(Vector3.new(3.6, 2.4, 2.4), CFrame.new(0, headY, 0), "SparkleVolume")
			b:emitter(v, B.Particles.sparkle(P.rgb(255, 70, 100), 9), "RubySparkle")
			local orb = B.Particles.orb(P.rgb(255, 40, 70), 4)
			orb.Size = B.seq(0, 0, 0.3, 0.22, 1, 0)
			b:emitter(v, orb, "RubyMotes")
			B.both(function(sx)
				local e = b:fxVolume(Vector3.new(0.3, 1.6, 1.6), CFrame.new(sx * (EX1 + 0.1), headY, 0), "EndSparkle")
				b:emitter(e, B.Particles.sparkle(P.rgb(255, 120, 140), 3), "EndSparkle")
			end)
		end)
		b:light(Vector3.new(0, headY, 0), red, 2.2, 10, { pulse = { 1.2, 3 }, pulseSpeed = 1.1, name = "CoreGlow" })
		b:light(Vector3.new(-EX1 - 0.3, headY, 0), P.rgb(255, 60, 80), 1, 6, { pulse = { 0.6, 1.6 }, pulseSpeed = 1.1, name = "StrikeGlow" })

		local shards = B.Particles.sparkle(P.rgb(255, 50, 80), 0)
		shards.Speed = NumberRange.new(8, 16)
		shards.Size = B.seq(0, 0.45, 1, 0)
		shards.Acceleration = Vector3.new(0, -20, 0)
		shards.Lifetime = NumberRange.new(0.3, 0.6)
		local embers = B.Particles.ember(red, 0)
		embers.Speed = NumberRange.new(4, 9)
		local hit = b:impact(CFrame.new(-EX1 - 0.4, headY, 0), red, { sparks = 24, flash = 7, extra = { shards, embers } })
		-- (Builder no acepta EmitCount dentro de props: se fija el atributo directo)
		hit:FindFirstChild("ImpactExtra1"):SetAttribute("FX_Emit", 20)
		hit:FindFirstChild("ImpactExtra2"):SetAttribute("FX_Emit", 14)
		b:trail(Vector3.new(0, headY + CH / 2, 0), Vector3.new(0, headY - CH / 2, 0), P.rgb(255, 120, 140), P.rgb(150, 0, 30), { lifetime = 0.24 })
	end,
}
