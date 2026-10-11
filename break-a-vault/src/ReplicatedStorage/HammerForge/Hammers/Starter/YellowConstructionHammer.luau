-- Yellow Construction Hammer (Starter) — herramienta de obra pintada de amarillo industrial, limpia y
-- saturada como juguete premium. Bloque central con panel de franjas de peligro negro/amarillo enmarcado
-- (en las dos caras), flejes oscuros, remates biselados con pernos cromados, defensas de hule negro abajo
-- con sus tornillos, tapas de golpe de acero, cuello negro con collar amarillo, agarre de hule negro
-- con costillas y pomo amarillo con anillo negro.
return {
	Id = "YellowConstructionHammer",
	DisplayName = "Yellow Construction Hammer",
	Rarity = "Starter",
	Order = 4,
	Theme = "Construction Site",
	Build = function(b, P, B)
		local A = B.Anatomy
		local headY = A.HeadY + 0.08

		-- ── estilos ─────────────────────────────────────────────
		local yellow = P.paint(P.rgb(242, 170, 10))
		local yellowEdge = P.paint(P.rgb(252, 204, 70)) -- arista con brillo
		local yellowDeep = P.paint(P.rgb(232, 152, 10))
		local black = P.paint(P.rgb(24, 24, 28))
		local strap = P.metal(P.rgb(64, 60, 58), 0.08)
		local rubber = P.GripRubber
		local rubberHi = P.leather(P.rgb(52, 54, 62))
		local bolt = P.metal(P.rgb(200, 206, 214), 0.3)
		local steel = P.metal(P.rgb(120, 126, 136), 0.16)
		local steelHi = P.metal(P.rgb(196, 204, 214), 0.26)

		-- ── cabeza ──────────────────────────────────────────────
		local cW, cH, cD = 1.5, 1.72, 1.62
		local eL, eH, eD = 0.9, 1.96, 1.86
		local eX = cW / 2 + 0.08 + eL / 2
		local tipX = eX + eL / 2
		b:group("Head", function()
			b:bevelBox(Vector3.new(cW, cH, cD), CFrame.new(0, headY, 0), yellow, 0.12, { edgeStyle = yellowEdge, name = "CenterBlock" })

			-- panel de franjas de peligro en ambas caras: marco amarillo → fondo negro → franjas amarillas
			B.both(function(s)
				local face = B.faceZ(s, headY, cD / 2)
				local pw, ph = 1.18, 0.98
				b:box(Vector3.new(pw + 0.16, ph + 0.16, 0.06), face * CFrame.new(0, 0, 0.02), yellowDeep, "PanelFrame")
				b:box(Vector3.new(pw, ph, 0.06), face * CFrame.new(0, 0, 0.04), black, "PanelBack")
				b:stripes(face * CFrame.new(0, 0, 0.075), pw, ph, 0.27, 40, 0.04, yellow)
			end)

			B.both(function(s)
				-- fleje oscuro entre bloques
				b:box(Vector3.new(0.16, cH + 0.06, cD + 0.06), CFrame.new(s * (cW / 2 + 0.04), headY, 0), strap, "Strap")
				-- remate biselado
				b:bevelBox(Vector3.new(eL, eH, eD), CFrame.new(s * eX, headY, 0), yellow, 0.22, { edgeStyle = yellowEdge, name = "EndBlock" })
				-- pernos cromados en ambas caras del remate
				for _, z in { 1, -1 } do
					for _, y in { 0.56, -0.05 } do
						local p = CFrame.new(s * (eX + 0.1), headY + y, z * (eD / 2))
						b:cylZ(0.1, 0.22, p * CFrame.new(0, 0, z * 0.03), bolt, "Bolt")
					end
				end
				-- defensa de hule negro abajo del remate (con tornillos)
				local bumpY = headY - eH / 2 + 0.12
				b:bevelBox(Vector3.new(eL + 0.06, 0.42, eD + 0.1), CFrame.new(s * eX, bumpY, 0), black, 0.1, { edges = "X", edgeStyle = rubberHi, name = "Bumper" })
				for _, z in { 1, -1 } do
					for _, dx in { s * 0.24 } do
						b:cylZ(0.05, 0.11, CFrame.new(s * eX + dx, bumpY, z * ((eD + 0.1) / 2 + 0.02)), steel, "BumperScrew")
					end
				end
				-- tapa de golpe: placa de acero biselada + centro brillante
				b:bevelBox(Vector3.new(0.12, eH - 0.5, eD - 0.44), CFrame.new(s * (tipX + 0.05), headY + 0.06, 0), steel, 0.1, { edges = "X", edgeStyle = steelHi, name = "StrikeFace" })
				b:box(Vector3.new(0.05, eH - 0.98, eD - 0.92), CFrame.new(s * (tipX + 0.12), headY + 0.06, 0), steelHi, "StrikeShine")
			end)

			-- arriba: ojo del mango con tapa negra
			b:cylY(0.08, 0.56, CFrame.new(0, headY + cH / 2 + 0.03, 0), black, "EyeTop")
		end)

		-- ── mango ───────────────────────────────────────────────
		local shaftDia = 0.46
		b:group("Shaft", function()
			local bottom, top = A.ShaftBottom, headY - cH / 2
			b:cylY(top - bottom, shaftDia, CFrame.new(0, (top + bottom) / 2, 0), rubber, "Shaft")
			-- cuello negro + collar amarillo
			b:cylY(0.42, 0.58, CFrame.new(0, top - 0.22, 0), black, "Neck")
			b:bevelBox(Vector3.new(0.7, 0.26, 0.7), CFrame.new(0, top - 0.62, 0), yellow, 0.14, { edges = "Y", edgeStyle = yellowEdge, name = "Collar" })
			-- agarre de hule con costillas
			local y0, y1 = -1.08, 1.02
			local nRibs = 9
			for i = 0, nRibs - 1 do
				local y = y0 + (y1 - y0) * (i + 0.5) / nRibs
				b:cylY(0.15, shaftDia + 0.16, CFrame.new(0, y, 0), if i % 2 == 0 then rubber else P.with(rubber, { Color = P.rgb(34, 35, 42) }), "GripRib")
			end
		end)

		-- ── pomo ────────────────────────────────────────────────
		b:group("Pommel", function()
			local y = A.PommelY - 0.04
			b:disc(CFrame.new(0, y + 0.24, 0), shaftDia + 0.24, 0.08, black, "PommelRing")
			b:bevelBox(Vector3.new(0.74, 0.36, 0.74), CFrame.new(0, y, 0), yellow, 0.16, { edges = "Y", edgeStyle = yellowEdge, name = "PommelCap" })
			b:cylY(0.12, 0.62, CFrame.new(0, y - 0.24, 0), black, "PommelBase")
			b:cylZ(0.05, 0.12, CFrame.new(0, y, 0.37), bolt, "PommelBolt")
			b:cylZ(0.05, 0.12, CFrame.new(0, y, -0.37), bolt, "PommelBolt")
		end)

		-- ── efectos ─────────────────────────────────────────────
		local chips = B.Particles.ember(P.rgb(255, 200, 40), 0)
		chips.Speed = NumberRange.new(6, 12)
		chips.Acceleration = Vector3.new(0, -20, 0)
		chips.SpreadAngle = Vector2.new(60, 60)
		b:impact(CFrame.new(-(tipX + 0.2), headY, 0), P.rgb(255, 204, 60), {
			sparks = 20,
			extra = { chips },
		})
		b:trail(Vector3.new(0, headY + eH / 2, 0), Vector3.new(0, headY - eH / 2, 0), P.rgb(255, 230, 120), P.rgb(255, 170, 20), { lifetime = 0.18 })
	end,
}
