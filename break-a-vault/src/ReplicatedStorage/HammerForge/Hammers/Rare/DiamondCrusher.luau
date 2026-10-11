-- Diamond Crusher (Rare) — un marco de acero oscuro que apenas puede contener dos racimos de DIAMANTE azul
-- que revientan por ambos extremos. Cada racimo: un diamante central facetado (dos cubos girados = muchas
-- caras) con núcleo de neón que late, rodeado de cristales en abanico que salen del casquillo, y cristales
-- chicos que brotan por arriba y por abajo junto a las bandas de acero.
-- Placa central remachada con un ROMBO de cristal facetado (4 caras de vidrio sobre neón azul) en ambas caras,
-- ranuras de luz azul en el marco, bandas de acero claro con remaches grandes.
-- Mango negro con correas azules cruzadas, anillos de neón, collar octagonal de acero y pomo con diamante.
return {
	Id = "DiamondCrusher",
	DisplayName = "Diamond Crusher",
	Rarity = "Rare",
	Order = 1,
	Theme = "Crystal Caverns",
	Build = function(b, P, B)
		local A = B.Anatomy
		local headY = A.HeadY

		-- ── estilos ─────────────────────────────────────────────
		local frame = P.metal(P.rgb(44, 48, 58), 0.08) -- acero oscuro del marco
		local frameDark = P.metal(P.rgb(26, 28, 36), 0.05)
		local plate = P.style(P.rgb(36, 40, 50), Enum.Material.DiamondPlate, 0.06)
		local steel = P.metal(P.rgb(150, 160, 176), 0.18)
		local steelEdge = P.metal(P.rgb(210, 218, 230), 0.25) -- brillo de arista
		local chrome = P.Chrome
		local crystal = P.crystal(P.rgb(60, 150, 255), 0.12)
		local crystalPale = P.crystal(P.rgb(120, 200, 255), 0.18)
		local crystalDeep = P.crystal(P.rgb(36, 100, 235), 0.1)
		local core = P.neon(P.rgb(30, 120, 255))
		local coreHot = P.neon(P.rgb(80, 180, 255))
		local facetA = P.crystal(P.rgb(50, 140, 255), 0.35)
		local facetB = P.crystal(P.rgb(110, 195, 255), 0.42)
		local blueStrap = P.fabric(P.rgb(36, 132, 245))
		local grip = P.GripRubber

		local cores = {} -- neón que late

		-- ── helpers ─────────────────────────────────────────────
		local r23, r13 = math.sqrt(2 / 3), 1 / math.sqrt(3)
		-- rotación que pone una diagonal del cubo sobre la Y local → la parte de arriba es una punta de 3 caras
		local VERTEX_UP = CFrame.fromMatrix(Vector3.zero, Vector3.new(r23, r13, 0), Vector3.new(r23 * math.cos(math.rad(120)), r13, r23 * math.sin(math.rad(120))))

		local function aim(pos: Vector3, dir: Vector3, roll: number?): CFrame
			local up = dir.Unit
			local ref = if math.abs(up.Y) < 0.9 then Vector3.yAxis else Vector3.xAxis
			local right = ref:Cross(up).Unit
			local back = right:Cross(up).Unit
			return CFrame.fromMatrix(pos, right, up, back) * CFrame.Angles(0, roll or 0, 0)
		end

		-- cristal barato: prisma (girado 45°) + cubo con la punta hacia afuera + núcleo de neón
		local function shard(base: CFrame, len: number, w: number, shell, withCore: boolean?)
			local tipSide = w * 0.82
			local bl = len - tipSide * 0.866
			b:box(Vector3.new(w, bl, w), base * CFrame.new(0, bl / 2, 0) * CFrame.Angles(0, math.pi / 4, 0), shell, "Crystal")
			b:box(Vector3.new(tipSide, tipSide, tipSide), base * CFrame.new(0, bl, 0) * VERTEX_UP, shell, "CrystalTip")
			if withCore then
				table.insert(cores, b:box(Vector3.new(w * 0.4, bl * 0.8, w * 0.4), base * CFrame.new(0, bl * 0.45, 0) * CFrame.Angles(0, math.pi / 4, 0), core, "CrystalCore"))
			end
		end

		local function oct(len: number, dia: number, cf: CFrame, st, name: string?)
			local s = dia * 0.4142
			local t = dia * 0.2071
			b:box(Vector3.new(dia, len, s), cf, st, name)
			b:box(Vector3.new(s, len, dia), cf, st, name)
			for i = 0, 3 do
				b:box(Vector3.new(t, len, s), cf * CFrame.Angles(0, math.rad(45 + 90 * i), 0) * CFrame.new(dia / 2 - t / 2, 0, 0), st, name)
			end
		end

		-- ── medidas ─────────────────────────────────────────────
		local CW, CH, CD = 1.5, 1.82, 1.82 -- bloque central
		local BW, BH = 0.32, 2.04 -- bandas de acero
		local bandX = CW / 2 + BW / 2 + 0.01
		local SW, SH = 0.36, 1.66 -- casquillo que sujeta el racimo
		local sockX = CW / 2 + BW + SW / 2
		local rootX = CW / 2 + BW + SW -- donde nace el racimo

		b:group("Head", function()
			-- bloque central
			b:bevelBox(Vector3.new(CW, CH, CD), CFrame.new(0, headY, 0), frame, 0.12, { edgeStyle = steel, name = "Core" })
			-- arriba/abajo: placas con ranura de luz
			for _, sy in { 1, -1 } do
				local y = headY + sy * (CH / 2 + 0.02)
				b:box(Vector3.new(CW - 0.3, 0.06, CD - 0.3), CFrame.new(0, y, 0), plate, "TopPlate")
				b:box(Vector3.new(CW - 0.62, 0.07, 0.08), CFrame.new(0, y + sy * 0.005, 0), core, "TopSlot")
			end

			-- caras de emblema ±Z: placa remachada + rombo de cristal facetado
			B.both(function(s)
				local face = B.faceZ(s, headY, CD / 2)
				b:box(Vector3.new(CW - 0.16, CH - 0.2, 0.06), face * CFrame.new(0, 0, 0.02), P.metal(P.rgb(84, 92, 108), 0.12), "PlateFrame")
				b:box(Vector3.new(CW - 0.3, CH - 0.34, 0.08), face * CFrame.new(0, 0, 0.03), plate, "Plate")
				-- ranuras de luz en los bordes laterales de la placa
				for _, sx in { -1, 1 } do
					b:box(Vector3.new(0.05, CH - 0.7, 0.06), face * CFrame.new(sx * (CW / 2 - 0.22), 0, 0.06), core, "PlateGlow")
				end
				for _, c in { Vector2.new(-1, -1), Vector2.new(1, -1), Vector2.new(1, 1), Vector2.new(-1, 1) } do
					b:rivet(face:PointToWorldSpace(Vector3.new(c.X * (CW / 2 - 0.27), c.Y * (CH / 2 - 0.27), 0.08)), 0.15, chrome)
				end
				-- rombo: marco de acero → hueco oscuro → neón → pirámide de cristal facetada
				local rw, rh = 0.8, 1.12
				b:shape(face * CFrame.new(0, 0, 0.09), B.Shapes.rhombus(rw + 0.16, rh + 0.22), 0.04, steelEdge, "RhombusFrame")
				b:shape(face * CFrame.new(0, 0, 0.11), B.Shapes.rhombus(rw + 0.04, rh + 0.08), 0.04, frameDark, "RhombusRecess")
				for _, p in b:shape(face * CFrame.new(0, 0, 0.13), B.Shapes.rhombus(rw * 0.86, rh * 0.86), 0.04, coreHot, "RhombusCore") do
					table.insert(cores, p)
				end
				local apex = face:PointToWorldSpace(Vector3.new(0, 0.04, 0.36))
				local v = {
					face:PointToWorldSpace(Vector3.new(0, rh / 2, 0.15)),
					face:PointToWorldSpace(Vector3.new(rw / 2, 0, 0.15)),
					face:PointToWorldSpace(Vector3.new(0, -rh / 2, 0.15)),
					face:PointToWorldSpace(Vector3.new(-rw / 2, 0, 0.15)),
				}
				for i = 1, 4 do
					b:triangle(v[i], v[i % 4 + 1], apex, 0.04, if i % 2 == 0 then facetA else facetB, "RhombusFacet")
				end
			end)

			-- ── bandas de acero, casquillos y racimos de diamante (±X)
			B.both(function(sx)
				-- banda de acero claro (sobresale del marco)
				b:bevelBox(Vector3.new(BW, BH, BH), CFrame.new(sx * bandX, headY, 0), steel, 0.1, { edges = "X", edgeStyle = steelEdge, name = "Band" })
				B.both(function(sz)
					local f = B.faceZ(sz, headY, BH / 2, sx * bandX)
					b:box(Vector3.new(0.06, BH - 0.36, 0.03), f * CFrame.new(0, 0, 0.01), frameDark, "BandGroove")
					b:rivet(f:PointToWorldSpace(Vector3.new(0, 0.62, 0.02)), 0.22, chrome)
					b:rivet(f:PointToWorldSpace(Vector3.new(0, -0.62, 0.02)), 0.22, chrome)
				end)
				b:rivet(Vector3.new(sx * bandX, headY + BH / 2 + 0.02, 0.62), 0.18, chrome)
				b:rivet(Vector3.new(sx * bandX, headY + BH / 2 + 0.02, -0.62), 0.18, chrome)

				-- casquillo oscuro + labio de acero que muerde los cristales
				b:bevelBox(Vector3.new(SW, SH, SH), CFrame.new(sx * sockX, headY, 0), frame, 0.12, { edges = "X", edgeStyle = steel, name = "Socket" })
				b:bevelBox(Vector3.new(0.1, SH + 0.12, SH + 0.12), CFrame.new(sx * (rootX - 0.04), headY, 0), steel, 0.1, { edges = "X", edgeStyle = steelEdge, name = "SocketLip" })
				-- garras de acero que abrazan el diamante (4, en diagonal)
				for i = 0, 3 do
					local a = math.rad(45 + 90 * i)
					local r = 0.7
					local p0 = Vector3.new(sx * (rootX + 0.02), headY + math.sin(a) * r, math.cos(a) * r)
					local p1 = Vector3.new(sx * (rootX + 0.36), headY + math.sin(a) * (r - 0.1), math.cos(a) * (r - 0.1))
					b:line(p0, p1, 0.14, 0.1, steelEdge, nil, "Claw")
				end
				-- raíz de luz bajo el racimo
				table.insert(cores, b:box(Vector3.new(0.06, SH - 0.36, SH - 0.36), CFrame.new(sx * (rootX + 0.03), headY, 0), core, "CrystalRoot"))

				-- diamante central: dos cubos de cristal girados distinto (= muchas facetas) + núcleo
				local gc = CFrame.new(sx * (rootX + 0.42), headY, 0)
				b:box(Vector3.new(0.98, 0.98, 0.98), gc * CFrame.Angles(math.rad(45), math.rad(35.26), 0), crystal, "Diamond")
				b:box(Vector3.new(0.92, 0.92, 0.92), gc * CFrame.Angles(math.rad(12), math.rad(-30), math.rad(40)), crystalPale, "Diamond")
				table.insert(cores, b:box(Vector3.new(0.52, 0.52, 0.52), gc * CFrame.Angles(math.rad(45), math.rad(35.26), 0), coreHot, "DiamondCore"))

				-- abanico de cristales que revientan hacia afuera
				local root = sx * (rootX - 0.05)
				local fan = {
					-- { y, z, dirX, dirY, dirZ, len, w, shell, core }
					{ 0.5, 0.1, 0.7, 1.0, 0.15, 1.35, 0.5, crystal, true }, -- el grande de arriba
					{ -0.5, -0.15, 0.9, -0.8, -0.25, 1.15, 0.46, crystalDeep, true },
					{ 0.05, 0.45, 0.8, 0.15, 0.85, 0.95, 0.4, crystalPale, false },
					{ 0.0, -0.48, 0.85, 0.3, -0.8, 0.92, 0.38, crystal, false },
					{ -0.3, 0.38, 1.0, -0.5, 0.45, 0.8, 0.34, crystalPale, false },
				}
				for i, f in fan do
					local pos = Vector3.new(root, headY + f[1], f[2])
					shard(aim(pos, Vector3.new(sx * f[3], f[4], f[5]), i * 0.7), f[6], f[7], f[8], f[9])
				end

				-- cristales chicos que brotan junto a la banda (arriba y abajo)
				shard(aim(Vector3.new(sx * (sockX + 0.02), headY + SH / 2 - 0.05, -0.25), Vector3.new(sx * 0.35, 1, -0.2), 0.3), 0.55, 0.26, crystal, false)
				shard(aim(Vector3.new(sx * (sockX + 0.06), headY + SH / 2 - 0.05, 0.3), Vector3.new(sx * 0.6, 1, 0.35), 1.1), 0.4, 0.2, crystalPale, false)
				shard(aim(Vector3.new(sx * (sockX + 0.04), headY - SH / 2 + 0.05, 0.1), Vector3.new(sx * 0.5, -1, 0.25), 0.6), 0.42, 0.22, crystalDeep, false)

				-- esquirlas de diamante flotando junto al racimo (suben y bajan)
				for i, o in { { 0.95, 1.0, 0.35, 0.2 }, { 0.8, -0.95, -0.4, 0.16 } } do
					local gcf = CFrame.new(sx * (rootX + o[1]), headY + o[2], o[3])
					local fl = {
						b:box(Vector3.new(o[4], o[4], o[4]), gcf * VERTEX_UP, crystalPale, "FloatShard"),
						b:box(Vector3.new(o[4], o[4], o[4]) * 0.5, gcf * VERTEX_UP, coreHot, "FloatShardCore"),
					}
					b:animate(fl, gcf, { Spin = Vector3.new(0, 1.6, 0), Bob = Vector3.new(0, 0.1, 0), BobSpeed = 0.6, Phase = i * 0.8 + (sx + 1) * 0.4 })
				end
			end)
		end)

		-- ── mango ───────────────────────────────────────────────
		b:group("Shaft", function()
			local bottom, top = A.ShaftBottom, headY - CH / 2
			b:cylY(top - bottom, 0.46, CFrame.new(0, (top + bottom) / 2, 0), grip, "Shaft")
			-- collar octagonal de acero con remaches
			oct(0.44, 0.78, CFrame.new(0, top - 0.22, 0), steel, "Collar")
			b:disc(CFrame.new(0, top - 0.46, 0), 0.68, 0.06, steelEdge, "CollarLip")
			b:disc(CFrame.new(0, top - 0.02, 0), 0.76, 0.06, frameDark, "CollarTop")
			for _, a in { 0, math.pi / 2, math.pi, 3 * math.pi / 2 } do
				b:rivet(Vector3.new(math.cos(a) * 0.39, top - 0.22, math.sin(a) * 0.39), 0.13, chrome)
			end
			-- agarre: segmentos de cuero negro + correas azules cruzadas
			for i = 0, 5 do
				b:disc(CFrame.new(0, -0.88 + i * 0.36, 0), 0.52, 0.24, grip, "GripRib")
			end
			for i = 0, 5 do
				local tilt = if i % 2 == 0 then 0.42 else -0.42
				b:cylY(0.12, 0.56, CFrame.new(0, -0.72 + i * 0.3, 0) * CFrame.Angles(0, i * 0.5, 0) * CFrame.Angles(tilt, 0, 0), blueStrap, "Strap")
			end
			-- anillos de neón en los extremos del agarre
			for _, y in { 1.08, -1.06 } do
				b:disc(CFrame.new(0, y, 0), 0.56, 0.1, steel, "RingBase")
				table.insert(cores, b:disc(CFrame.new(0, y, 0), 0.6, 0.04, core, "GripGlow"))
			end
		end)

		-- ── pomo ────────────────────────────────────────────────
		b:group("Pommel", function()
			local py = A.PommelY - 0.04
			oct(0.46, 0.8, CFrame.new(0, py, 0), steel, "Pommel")
			b:disc(CFrame.new(0, py + 0.25, 0), 0.7, 0.06, steelEdge, "PommelBevel")
			b:disc(CFrame.new(0, py - 0.25, 0), 0.7, 0.06, frameDark, "PommelBevel")
			for _, a in { 0, math.pi / 2, math.pi, 3 * math.pi / 2 } do
				b:rivet(Vector3.new(math.cos(a) * 0.4, py, math.sin(a) * 0.4), 0.13, chrome)
			end
			-- diamante en la punta del pomo
			local tip = CFrame.new(0, py - 0.32, 0) * CFrame.Angles(math.pi, 0, 0)
			b:box(Vector3.new(0.36, 0.36, 0.36), tip * VERTEX_UP, crystal, "PommelGem")
			table.insert(cores, b:box(Vector3.new(0.16, 0.16, 0.16), tip * VERTEX_UP, coreHot, "PommelGemCore"))
		end)

		-- ── efectos ─────────────────────────────────────────────
		b:pulse(cores, 0, 0.35, 0.9)
		b:light(Vector3.new(0, headY, 0), P.rgb(80, 170, 255), 1.6, 11, { pulse = { 1.0, 2.6 }, pulseSpeed = 0.9 })
		-- destellos de diamante en cada racimo
		B.both(function(sx)
			local vol = b:fxVolume(Vector3.new(0.9, 1.6, 1.6), CFrame.new(sx * (rootX + 0.4), headY, 0), "DiamondGlints")
			local sp = B.Particles.sparkle(P.rgb(140, 210, 255), 4)
			sp.Size = B.seq(0, 0, 0.25, 0.38, 1, 0)
			sp.Speed = NumberRange.new(0.05, 0.3)
			b:emitter(vol, sp, "DiamondSparkle")
		end)

		-- golpe: chispas azules + esquirlas de diamante + escarcha
		local shards = B.Particles.sparkle(P.rgb(170, 225, 255), 0)
		shards.Speed = NumberRange.new(8, 16)
		shards.Acceleration = Vector3.new(0, -20, 0)
		shards.Size = B.seq(0, 0.5, 1, 0)
		shards.Lifetime = NumberRange.new(0.4, 0.8)
		local frost = B.Particles.frost(P.rgb(110, 190, 255), 0)
		b:impact(CFrame.new(-(rootX + 1.0), headY, 0), P.rgb(70, 170, 255), {
			sparks = 26,
			flash = 7,
			extra = { shards, frost },
		})
		b:trail(Vector3.new(0, headY + CH / 2, 0), Vector3.new(0, headY - CH / 2, 0), P.rgb(200, 240, 255), P.rgb(40, 130, 255), { lifetime = 0.24 })
	end,
}
