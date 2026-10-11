-- Iron Breaker (Starter) — maza de hierro forjado, pesada y honesta. Cabeza en tres bloques de casi la misma
-- altura: el central, alto y muy biselado con aristas de acero brillante, y dos remates más gordos de perfil
-- octagonal (facetas de acero frío con un toque azul), separados por juntas negras delgadas. Grietas y mellas
-- de forja en las caras, tapas de golpe escalonadas, cuello de acero, agarre grueso de cuero en dos tonos con
-- correa en espiral, y pomo octagonal grande y achaflanado con aro oscuro.
return {
	Id = "IronBreaker",
	DisplayName = "Iron Breaker",
	Rarity = "Starter",
	Order = 3,
	Theme = "Starter Yard",
	Build = function(b, P, B)
		local A = B.Anatomy
		local headY = A.HeadY + 0.08

		-- ── estilos ─────────────────────────────────────────────
		local iron = P.metal(P.rgb(84, 90, 102), 0.1)
		local ironMid = P.metal(P.rgb(66, 70, 82), 0.08)
		local facet = P.metal(P.rgb(162, 176, 198), 0.2) -- faceta clara, acero frío
		local edgeHi = P.metal(P.rgb(206, 220, 240), 0.28) -- arista más brillante (azulada)
		local edgeMatte = P.metal(P.rgb(196, 204, 216), 0.03) -- arista clara pero mate (bloque central)
		local dark = P.metal(P.rgb(34, 36, 44), 0.05)
		local crack = P.metal(P.rgb(40, 42, 50), 0)
		local polish = P.metal(P.rgb(188, 196, 208), 0.3)
		local leather = P.leather(P.rgb(150, 86, 40))
		local leatherDark = P.leather(P.rgb(104, 56, 26))

		-- ── cabeza ──────────────────────────────────────────────
		local cW, cH, cD = 1.24, 2.02, 1.9 -- bloque central (alto, casi como los remates)
		local eL, eH, eD = 1.04, 2.12, 2.0 -- remates (más gordos)
		local gap = 0.08 -- junta negra entre bloques
		local eX = cW / 2 + gap + eL / 2 -- centro de cada remate
		local tipX = eX + eL / 2
		b:group("Head", function()
			-- bloque central: alto, bisel marcado y aristas brillantes propias
			b:bevelBox(Vector3.new(cW, cH, cD), CFrame.new(0, headY, 0), iron, 0.15, { edges = "X", edgeStyle = edgeMatte, name = "CenterBlock" })
			-- panel forjado un pelo salido en ambas caras (da la lectura de "bloque" grueso)
			B.both(function(s)
				b:bevelBox(Vector3.new(cW - 0.36, cH - 0.4, 0.06), CFrame.new(0, headY, s * (cD / 2 + 0.01)), ironMid, 0.04, { edges = "Z", edgeStyle = facet, name = "CenterPanel" })
			end)

			B.both(function(s)
				-- banda negra hundida entre bloques
				b:bevelBox(Vector3.new(gap + 0.04, cH - 0.1, cD - 0.1), CFrame.new(s * (cW / 2 + gap / 2), headY, 0), dark, 0.2, { edges = "X", name = "Gap" })
				-- remate octagonal (facetas grandes) + aro claro en la cara interior
				b:bevelBox(Vector3.new(eL, eH, eD), CFrame.new(s * eX, headY, 0), iron, 0.44, { edges = "X", edgeStyle = facet, name = "EndBlock" })
				b:bevelBox(Vector3.new(0.06, eH - 0.06, eD - 0.06), CFrame.new(s * (tipX - 0.02), headY, 0), edgeHi, 0.42, { edges = "X", name = "EndRim" })
				-- tapa de golpe escalonada: octágono oscuro + placa pulida + centro
				b:bevelBox(Vector3.new(0.16, eH - 0.42, eD - 0.42), CFrame.new(s * (tipX + 0.06), headY, 0), ironMid, 0.3, { edges = "X", edgeStyle = facet, name = "StrikeStep" })
				b:bevelBox(Vector3.new(0.08, eH - 0.84, eD - 0.84), CFrame.new(s * (tipX + 0.16), headY, 0), polish, 0.14, { edges = "X", edgeStyle = edgeHi, name = "StrikeFace" })
			end)

			-- caras de emblema (±Z): grietas de forja y abolladuras
			B.both(function(s)
				local cface = B.faceZ(s, headY, cD / 2 + 0.046)
				local n = cface.LookVector
				local function crackAt(planeCF, pts, w)
					local world = {}
					for _, p in pts do
						table.insert(world, planeCF:PointToWorldSpace(Vector3.new(p.X, p.Y, 0)))
					end
					b:polyline(world, w or 0.045, 0.03, crack, n, false, "Crack")
				end
				-- centro: grieta fina que nace en la arista de arriba + rayón claro
				crackAt(cface, { Vector2.new(-0.32, cH / 2 - 0.2), Vector2.new(-0.2, 0.42), Vector2.new(-0.27, 0.2) }, 0.03)
				b:line(cface:PointToWorldSpace(Vector3.new(0.02, -0.25, 0)), cface:PointToWorldSpace(Vector3.new(0.3, -0.48, 0)), 0.035, 0.03, facet, n, "Scratch")
				-- remates: grietas que nacen de las aristas (como despostilladas) + mella clara
				for _, side in { 1, -1 } do
					local eface = B.faceZ(s, headY, eD / 2 + 0.006, side * eX)
					local k = (if side == 1 then 1 else -1) * s
					local ex = eL / 2 - 0.1
					crackAt(eface, { Vector2.new(k * ex, 0.35), Vector2.new(k * (ex - 0.22), 0.26), Vector2.new(k * (ex - 0.3), 0.05) }, 0.03)
					crackAt(eface, { Vector2.new(-k * 0.1, -(eH / 2 - 0.46)), Vector2.new(-k * 0.02, -0.32), Vector2.new(-k * 0.14, -0.14) }, 0.03)
					b:box(Vector3.new(0.18, 0.1, 0.03), eface * CFrame.new(-k * 0.2, 0.42, 0) * CFrame.Angles(0, 0, 0.4), facet, "Nick")
				end
			end)

			-- arriba: punta del mango con cuña de acero
			b:cylY(0.08, 0.5, CFrame.new(0, headY + cH / 2 + 0.03, 0), dark, "EyeTop")
			b:box(Vector3.new(0.4, 0.06, 0.08), CFrame.new(0, headY + cH / 2 + 0.08, 0) * CFrame.Angles(0, math.rad(90), 0), edgeHi, "Wedge")
		end)

		-- ── mango (grueso y corto: K = escala radial de todo el mango) ──
		local K = 1.2
		local shaftDia = 0.5 * K
		local shaftBottom = -0.9
		b:group("Shaft", function()
			local bottom, top = shaftBottom, headY - cH / 2
			b:cylY(top - bottom, shaftDia, CFrame.new(0, (top + bottom) / 2, 0), leatherDark, "Shaft")
			-- cuello de acero bajo la cabeza
			local neckY = top - 0.3
			b:bevelBox(Vector3.new(0.74 * K, 0.54, 0.74 * K), CFrame.new(0, neckY, 0), iron, 0.18 * K, { edges = "Y", edgeStyle = facet, name = "Neck" })
			b:disc(CFrame.new(0, neckY - 0.3, 0), 0.82 * K, 0.1, dark, "NeckRing")
			b:cylY(0.16, shaftDia + 0.08 * K, CFrame.new(0, neckY - 0.42, 0), ironMid, "NeckTaper")

			-- agarre grueso: cuero en dos tonos (discos inclinados = vueltas) + correa oscura en espiral
			local y0, y1 = -0.86, 1.56
			local nWraps = 7
			local leatherLight = P.with(leather, { Color = P.rgb(176, 104, 50) })
			for i = 0, nWraps - 1 do
				local y = y0 + (y1 - y0) * (i + 0.5) / nWraps
				b:cylY(0.36, (0.6 - (i % 2) * 0.02) * K, CFrame.new(0, y, 0) * CFrame.Angles(0, 0.35, 0) * CFrame.Angles(0.3, 0, 0), if i % 2 == 0 then leather else leatherLight, "LeatherWrap")
			end
			b:wrap(y0 + 0.04, y1 - 0.04, 0.3 * K, 4.5, leatherDark, { width = 0.07, thickness = 0.045, segmentsPerTurn = 6, name = "WrapLine" })
			b:disc(CFrame.new(0, y1 + 0.05, 0), 0.66 * K, 0.1, leatherDark, "WrapEnd")
			b:disc(CFrame.new(0, y0 - 0.05, 0), 0.66 * K, 0.1, leatherDark, "WrapEnd")
		end)

		-- ── pomo octagonal grande y achaflanado (más grande y más arriba) ──
		b:group("Pommel", function()
			local y = -1.1
			local w = 1.08 * 1.22
			b:bevelBox(Vector3.new(w, 0.44, w), CFrame.new(0, y, 0), iron, 0.24, { edgeStyle = facet, name = "Pommel" })
			b:bevelBox(Vector3.new(0.7 * 1.22, 0.08, 0.7 * 1.22), CFrame.new(0, y - 0.25, 0), ironMid, 0.2, { edges = "Y", edgeStyle = facet, name = "PommelCap" })
			b:bevelBox(Vector3.new(0.8 * 1.22, 0.1, 0.8 * 1.22), CFrame.new(0, y + 0.25, 0), dark, 0.22, { edges = "Y", name = "PommelRing" })
		end)

		-- ── efectos ─────────────────────────────────────────────
		local sparksBlue = B.Particles.electric(P.rgb(170, 210, 255), 0)
		sparksBlue.Lifetime = NumberRange.new(0.12, 0.28)
		b:impact(CFrame.new(-(tipX + 0.22), headY, 0), P.rgb(255, 214, 150), {
			sparks = 22,
			extra = { sparksBlue },
		})
		b:trail(Vector3.new(0, headY + eH / 2, 0), Vector3.new(0, headY - eH / 2, 0), P.rgb(230, 240, 255), P.rgb(120, 150, 200), { lifetime = 0.18 })
	end,
}
