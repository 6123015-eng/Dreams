-- Ruby Mauler (Epic) — un rubí gigante encadenado en acero: la cabeza es un bloque de rubí rojo profundo
-- (vidrio carmesí con un NÚCLEO de neón rojo que late adentro) con una pirámide baja facetada en cada cara,
-- sujeto por dos BANDAS GRUESAS de acero biselado con tachones piramidales y picos arriba y abajo.
-- A los lados, dos rubíes más chicos, también facetados en pirámide, con caras de golpe en punta y
-- marcos de hierro con picos en las esquinas apuntando afuera.
-- Mango grueso forrado de cuero rojo en espiral con cordón oscuro, collar de acero con tachones y pomo
-- grande de acero con tachones y rubí. FX: destellos rojos, motas carmesí, luz roja pulsante,
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
		local function glassSt(c: Color3, t: number)
			local st = P.style(c, Enum.Material.Glass, 0.12, t)
			st.CastShadow = false
			return st
		end
		local ruby = glassSt(P.rgb(178, 12, 32), 0.08)
		local rubyLight = glassSt(P.rgb(232, 30, 54), 0.06) -- faceta iluminada
		local rubyDark = P.foil(P.rgb(120, 4, 20), 0.3) -- faceta en sombra (opaca, rojo profundo)
		local rubyEdge = glassSt(P.rgb(255, 84, 104), 0.04) -- arista brillante
		local rubyDeep = P.foil(P.rgb(104, 2, 18), 0.25)
		local core = P.neon(P.rgb(255, 24, 52), 0.3)
		local coreHot = P.neon(P.rgb(255, 80, 96))
		local iron = P.metal(P.rgb(72, 74, 82), 0.1)
		local ironEdge = P.metal(P.rgb(150, 154, 166), 0.16)
		local steel = P.metal(P.rgb(120, 124, 136), 0.16) -- bandas
		local steelEdge = P.metal(P.rgb(186, 192, 204), 0.22)
		local ironDark = P.Blackened
		local spikeSt = P.metal(P.rgb(176, 182, 194), 0.12) -- acero pulido
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
		-- tachón piramidal de UNA pieza: cubo con un vértice hacia afuera, medio enterrado (asoma una pirámide)
		local diag = Vector3.new(1, 1, 1).Unit
		local function stud(pos: Vector3, n: Vector3, size: number, h: number, roll: number?)
			local axis = diag:Cross(n)
			local rot = if axis.Magnitude < 1e-4 then CFrame.new() else CFrame.fromAxisAngle(axis.Unit, math.acos(math.clamp(diag:Dot(n), -1, 1)))
			local ctr = pos - n * (size * math.sqrt(3) / 2 - h)
			return b:box(Vector3.new(size, size, size), CFrame.new(ctr) * CFrame.fromAxisAngle(n, roll or 0) * rot, spikeSt, "Stud")
		end
		-- pirámide baja facetada (4 facetas clara/oscura) sobre un rectángulo w×h del plano XY de `face`
		local function facetTop(face: CFrame, w: number, h: number, height: number)
			local c = {
				face:PointToWorldSpace(Vector3.new(-w / 2, -h / 2, 0)),
				face:PointToWorldSpace(Vector3.new(w / 2, -h / 2, 0)),
				face:PointToWorldSpace(Vector3.new(w / 2, h / 2, 0)),
				face:PointToWorldSpace(Vector3.new(-w / 2, h / 2, 0)),
			}
			local apex = face:PointToWorldSpace(Vector3.new(0, 0, height))
			local sts = { rubyDark, ruby, rubyLight, ruby }
			for i = 1, 4 do
				b:triangle(c[i], c[i % 4 + 1], apex, 0.05, sts[i], "Facet")
			end
		end

		-- ── medidas ────────────────────────────────────────────
		local CW, CH, CD = 1.5, 1.95, 1.95 -- rubí central
		local bandW, BH, BD = 0.48, 2.3, 2.3 -- bandas gruesas de acero (sobresalen ~0.18)
		local bx = CW / 2 + bandW / 2 - 0.04
		local EX0, EX1 = bx + bandW / 2 - 0.04, 1.86
		local EW, EH, ED = EX1 - EX0, 1.8, 1.8 -- rubíes de los extremos
		local ex = (EX0 + EX1) / 2
		local frameX = EX1 + 0.06

		local coreParts = {}

		b:group("Head", function()
			-- ── rubí central con núcleo ────────────────────────
			table.insert(coreParts, b:box(Vector3.new(CW - 0.4, CH - 0.4, CD - 0.4), CFrame.new(0, headY, 0), core, "Core"))
			b:box(Vector3.new(CW - 0.2, CH - 0.2, CD - 0.2), CFrame.new(0, headY, 0) * CFrame.Angles(0, math.pi / 4, 0), rubyDeep, "InnerFacets")
			b:bevelBox(Vector3.new(CW, CH, CD), CFrame.new(0, headY, 0), ruby, 0.26, { edgeStyle = rubyEdge, name = "Ruby" })
			-- pirámide baja facetada en ambas caras de emblema
			B.both(function(s)
				facetTop(B.faceZ(s, headY, CD / 2 - 0.02), CW - 0.2, CH - 0.24, 0.4)
				table.insert(coreParts, b:box(Vector3.new(0.2, 0.2, 0.06), CFrame.new(0, headY, s * (CD / 2 + 0.12)) * CFrame.Angles(0, 0, math.pi / 4), coreHot, "FacetSpark"))
			end)
			-- arriba y abajo: facetas planas giradas
			for _, sy in { 1, -1 } do
				b:box(Vector3.new(0.9, 0.06, 0.9), CFrame.new(0, headY + sy * (CH / 2 + 0.01), 0) * CFrame.Angles(0, math.pi / 4, 0), rubyLight, "TopFacet")
			end

			-- ── bandas gruesas de acero con tachones ───────────
			B.both(function(sx)
				local x = sx * bx
				b:bevelBox(Vector3.new(bandW, BH, BD), CFrame.new(x, headY, 0), steel, 0.13, { edges = "X", edgeStyle = steelEdge, name = "Band" })
				-- filos oscuros a los lados (separan la banda del rubí)
				for _, ox in { -1, 1 } do
					b:box(Vector3.new(0.04, BH - 0.2, BD - 0.2), CFrame.new(x + ox * (bandW / 2 + 0.01), headY, 0), ironDark, "BandLip")
				end
				-- picos: arriba y abajo
				spike(Vector3.new(x, headY + BH / 2, 0), Vector3.yAxis, 0.62, 0.34)
				spike(Vector3.new(x, headY - BH / 2, 0), -Vector3.yAxis, 0.44, 0.28)
				-- 3 tachones piramidales por cara
				for _, sz in { 1, -1 } do
					for _, y in { -0.66, 0, 0.66 } do
						stud(Vector3.new(x, headY + y, sz * BD / 2), Vector3.new(0, 0, sz), 0.4, 0.21, math.rad(15))
					end
				end

				-- ── rubí del extremo ───────────────────────────
				local ecf = CFrame.new(sx * ex, headY, 0)
				table.insert(coreParts, b:box(Vector3.new(EW - 0.14, EH - 0.4, ED - 0.4), ecf, core, "EndCore"))
				b:bevelBox(Vector3.new(EW, EH, ED), ecf, ruby, 0.26, { edges = "X", edgeStyle = rubyEdge, name = "EndRuby" })
				for _, sz in { 1, -1 } do
					facetTop(B.faceZ(sz, headY, ED / 2 - 0.02, sx * ex), EW - 0.12, EH - 0.5, 0.26)
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
				b:pyramid(fbase, 0.38, 1.36, 4, rubyLight, "StrikeFacet", 0.06)
				table.insert(coreParts, b:box(Vector3.new(0.06, 0.24, 0.24), CFrame.new(sx * (EX1 + 0.08), headY, 0) * CFrame.Angles(math.pi / 4, 0, 0), coreHot, "StrikeSpark"))
				-- picos en las 4 esquinas, apuntando hacia afuera
				for _, cy in { 1, -1 } do
					for _, cz in { 1, -1 } do
						spike(Vector3.new(sx * (frameX + 0.06), headY + cy * (fh / 2 - 0.12), cz * (fh / 2 - 0.12)), Vector3.new(sx, cy * 0.55, cz * 0.55), 0.52, 0.26, 3)
					end
				end
			end)
		end)

		-- ── mango (grueso y corto) ──────────────────────────────
		b:group("Shaft", function()
			local top = headY - CH / 2
			local bottom = A.ShaftBottom + 0.15
			b:cylY(top - bottom, 0.46, CFrame.new(0, (top + bottom) / 2, 0), iron, "ShaftCore")
			-- collar de acero octagonal con tachones
			local cy = top - 0.24
			b:bevelBox(Vector3.new(0.86, 0.4, 0.86), CFrame.new(0, cy, 0), steel, 0.18, { edges = "Y", edgeStyle = steelEdge, name = "Collar" })
			b:cylY(0.08, 0.76, CFrame.new(0, cy - 0.24, 0), ironDark, "CollarLip")
			for i = 0, 5 do
				local a = math.pi / 3 * i
				local n = Vector3.new(math.cos(a), 0, math.sin(a))
				stud(Vector3.new(0, cy, 0) + n * 0.4, n, 0.2, 0.1)
			end
			-- agarre de cuero rojo en espiral con cordón oscuro
			local g0, g1 = -0.98, 1.5
			b:cylY(g1 - g0, 0.6, CFrame.new(0, (g0 + g1) / 2, 0), leatherDark, "GripBase")
			local n = 8
			local step = (g1 - g0) / n
			for i = 0, n - 1 do
				local y = g0 + step * (i + 0.5)
				local tilt = if i % 2 == 0 then 0.18 else -0.18
				b:cylY(step * 1.08, 0.7 - (i % 2) * 0.02, CFrame.new(0, y, 0) * CFrame.Angles(0, i * 0.7, 0) * CFrame.Angles(tilt, 0, 0), leather, "LeatherWrap")
			end
			for i = 1, n - 1, 2 do
				b:cylY(0.05, 0.73, CFrame.new(0, g0 + step * i, 0) * CFrame.Angles(0, i * 0.9, 0) * CFrame.Angles(-0.3, 0, 0), leatherDark, "Cord")
			end
			for _, y in { g0, g1 } do
				b:cylY(0.14, 0.74, CFrame.new(0, y, 0), leatherDark, "Binding")
			end
		end)

		-- ── pomo (1.3x) ─────────────────────────────────────────
		b:group("Pommel", function()
			local y = A.PommelY + 0.04
			b:bevelBox(Vector3.new(1.04, 0.6, 1.04), CFrame.new(0, y, 0), steel, 0.27, { edges = "Y", edgeStyle = steelEdge, name = "Pommel" })
			b:bevelBox(Vector3.new(0.84, 0.14, 0.84), CFrame.new(0, y - 0.37, 0), ironDark, 0.22, { edges = "Y", edgeStyle = iron, name = "PommelCap" })
			for i = 0, 7 do
				local a = math.pi / 4 * i
				local n = Vector3.new(math.cos(a), 0, math.sin(a))
				local r = if i % 2 == 0 then 0.52 else 0.47
				stud(Vector3.new(0, y, 0) + n * r, n, 0.26, 0.13)
			end
			-- rubí en la base del pomo
			b:gem(CFrame.new(0, y - 0.5, 0), 0.26, rubyLight, core)
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
		b:light(Vector3.new(0, headY, 0), red, 2.6, 11, { pulse = { 1.4, 3.4 }, pulseSpeed = 1.1, name = "CoreGlow" })
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
