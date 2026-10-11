-- Rusty Hammer (Starter) — el primer martillo: hierro oxidado con caras de golpe pulidas por el uso,
-- mango de madera con venda de tela, cuña de madera visible arriba y remaches viejos.
return {
	Id = "RustyHammer",
	DisplayName = "Rusty Hammer",
	Rarity = "Starter",
	Order = 1,
	Theme = "Starter Yard",
	Build = function(b, P, B)
		local A = B.Anatomy
		local headY = A.HeadY
		local W, H, D = 3.1, 1.75, 1.7

		local rust = P.Rust
		local rustEdge = P.with(P.RustOrange, { Color = P.rgb(196, 112, 58) })
		local rustDark = P.RustDark
		local bare = P.metal(P.rgb(150, 146, 140), 0.18) -- metal expuesto por golpes
		local wood = P.wood(P.rgb(146, 92, 52))
		local woodDark = P.wood(P.rgb(104, 64, 36))
		local cloth = P.fabric(P.rgb(214, 194, 150))
		local clothDirty = P.fabric(P.rgb(176, 152, 112))

		b:group("Head", function()
			-- bloque principal oxidado con bisel claro (bordes gastados)
			b:bevelBox(Vector3.new(W, H, D), CFrame.new(0, headY, 0), rust, 0.16, { edgeStyle = rustEdge, name = "HeadCore" })

			-- caras de golpe: placas de metal pulido por el uso, ligeramente salidas
			B.both(function(s)
				b:bevelBox(Vector3.new(0.2, H * 0.84, D * 0.82), CFrame.new(s * (W / 2 + 0.06), headY, 0), bare, 0.06, { edges = "X", name = "StrikeFace" })
				-- anillo oscuro alrededor de la cara (borde aplastado)
				b:bevelBox(Vector3.new(0.12, H * 0.94, D * 0.92), CFrame.new(s * (W / 2 - 0.02), headY, 0), rustDark, 0.05, { edges = "X", name = "StrikeLip" })
			end)

			-- manchas de óxido y raspones en las dos caras de emblema
			B.both(function(s)
				local face = B.faceZ(s, headY, D / 2 + 0.005)
				b:shape(face * CFrame.new(-0.75, 0.25, 0), {
					Vector2.new(-0.45, -0.2), Vector2.new(-0.1, -0.38), Vector2.new(0.4, -0.25),
					Vector2.new(0.5, 0.1), Vector2.new(0.15, 0.32), Vector2.new(-0.35, 0.22),
				}, 0.03, rustDark, "RustPatch")
				b:shape(face * CFrame.new(0.85, -0.3, 0), {
					Vector2.new(-0.3, -0.12), Vector2.new(0.05, -0.25), Vector2.new(0.32, -0.05),
					Vector2.new(0.18, 0.2), Vector2.new(-0.2, 0.16),
				}, 0.03, rustEdge, "RustPatch")
				-- raspones de metal desnudo
				b:line(face:PointToWorldSpace(Vector3.new(0.1, 0.45, 0)), face:PointToWorldSpace(Vector3.new(0.75, 0.2, 0)), 0.05, 0.035, bare, face.LookVector, "Scratch")
				b:line(face:PointToWorldSpace(Vector3.new(-1.1, -0.45, 0)), face:PointToWorldSpace(Vector3.new(-0.55, -0.6, 0)), 0.04, 0.035, bare, face.LookVector, "Scratch")
				-- remaches viejos
				for _, x in { -1.2, 1.2 } do
					b:rivet(Vector3.new(x, headY + 0.52, s * (D / 2 + 0.02)), 0.2, rustEdge)
					b:rivet(Vector3.new(x, headY - 0.52, s * (D / 2 + 0.02)), 0.2, rustEdge)
				end
			end)

			-- muescas (golpes) en las aristas superiores
			b:box(Vector3.new(0.3, 0.12, 0.3), CFrame.new(-0.9, headY + H / 2 - 0.02, D / 2 - 0.08) * CFrame.Angles(0.3, 0.4, 0.2), rustDark, "Chip")
			b:box(Vector3.new(0.24, 0.1, 0.26), CFrame.new(1.05, headY - H / 2 + 0.02, -D / 2 + 0.07) * CFrame.Angles(-0.2, 0.5, 0.3), rustDark, "Chip")

			-- ojo del martillo: la punta del mango asoma arriba con su cuña metálica
			b:cylY(0.08, 0.5, CFrame.new(0, headY + H / 2 + 0.02, 0), woodDark, "ShaftTop")
			b:box(Vector3.new(0.5, 0.06, 0.08), CFrame.new(0, headY + H / 2 + 0.07, 0) * CFrame.Angles(0, math.rad(35), 0), bare, "Wedge")
		end)

		b:group("Shaft", function()
			local bottom, top = A.ShaftBottom, headY - H / 2 + 0.1
			b:cylY(top - bottom, A.ShaftDia, CFrame.new(0, (top + bottom) / 2, 0), wood, "Shaft")
			-- vetas: anillos finos más oscuros
			for i, y in { -0.95, 1.55, 2.0 } do
				b:cylY(0.035, A.ShaftDia + 0.012, CFrame.new(0, y, 0) * CFrame.Angles(0, i, 0.04), woodDark, "Grain")
			end
			-- collar de hierro bajo la cabeza
			b:disc(CFrame.new(0, top - 0.02, 0), A.ShaftDia + 0.16, 0.14, rustDark, "Collar")
			b:disc(CFrame.new(0, top - 0.13, 0), A.ShaftDia + 0.1, 0.06, rustEdge, "CollarLip")

			-- venda de tela en espiral con dos capas (se ve "amarrada")
			b:wrap(-0.75, 0.95, A.ShaftDia / 2, 4.5, cloth, { width = 0.26, thickness = 0.06, name = "Bandage" })
			b:wrap(-0.55, 0.75, A.ShaftDia / 2 + 0.03, 3, clothDirty, { width = 0.18, thickness = 0.05, phase = 1.7, name = "BandageOver" })
			-- vueltas planas en los extremos + cola de la venda
			b:disc(CFrame.new(0, 0.98, 0), A.ShaftDia + 0.11, 0.18, cloth, "BandageEnd")
			b:disc(CFrame.new(0, -0.78, 0), A.ShaftDia + 0.11, 0.18, cloth, "BandageEnd")
			b:box(Vector3.new(0.05, 0.42, 0.16), CFrame.new(A.ShaftDia / 2 + 0.07, 0.75, 0.05) * CFrame.Angles(0, 0, math.rad(-12)), clothDirty, "BandageTail")
		end)

		b:group("Pommel", function()
			b:disc(CFrame.new(0, A.ShaftBottom - 0.05, 0), A.ShaftDia + 0.14, 0.12, rustDark, "PommelRing")
			b:cylY(0.32, A.ShaftDia + 0.08, CFrame.new(0, A.PommelY + 0.02, 0), woodDark, "Pommel")
			b:ball(A.ShaftDia + 0.06, CFrame.new(0, A.PommelY - 0.14, 0), woodDark, "PommelCap")
		end)

		-- golpe: polvo de óxido y chispas naranjas
		b:impact(CFrame.new(-(W / 2 + 0.16), headY, 0), P.rgb(255, 170, 90), {
			sparks = 14,
			extra = { B.Particles.smoke(P.rgb(150, 100, 70), 0) },
		})
		b:trail(Vector3.new(0, headY + H / 2, 0), Vector3.new(0, headY - H / 2, 0), P.rgb(230, 220, 205), P.rgb(150, 120, 100), { lifetime = 0.18 })
	end,
}
