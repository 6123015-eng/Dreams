-- Crystal Shatter Hammer (Special) — un bloque de acero que ya no aguanta lo que lleva adentro: un
-- corazón de cristal azul que lo está reventando. La cabeza es acero biselado con aristas claras,
-- abrazado por dos FLEJES gruesos remachados y un par de flejes delgados al final; arriba, un pico de
-- acero. En la punta de golpe (-X) estalla un RAMILLETE DE CRISTALES enorme que sale de un marco de
-- acero con un núcleo azul encendido; del otro extremo, arriba y abajo brotan más cristales. En el
-- bloque derecho el acero está ROTO: grietas dentadas por las que asoma el cristal brillante y salen
-- cristales cortos. Cada cristal es vidrio facetado con un núcleo de neón que late a destiempo
-- (centelleo). Alrededor flotan esquirlas que giran. Mango oscuro segmentado con collar de cobre,
-- jaula de acero con diamantes de cristal y pomo de acero con gema.
-- FX: destellos, escarcha brillante, orbes azules, luz azul que late; impacto con esquirlas y destello.
return {
	Id = "CrystalShatterHammer",
	DisplayName = "Crystal Shatter Hammer",
	Rarity = "Special",
	Order = 4,
	Theme = "Crystal Caves",
	Build = function(b, P, B)
		local A = B.Anatomy
		local headY = A.HeadY + 0.1
		local H, D = 1.95, 1.85
		local X0, X1 = -1.7, 1.7

		-- ── estilos ─────────────────────────────────────────────
		local iceC = P.rgb(90, 190, 255)
		local steel = P.metal(P.rgb(56, 60, 70), 0.1)
		local steelAlt = P.metal(P.rgb(70, 75, 86), 0.12)
		local steelEdge = P.metal(P.rgb(150, 158, 172), 0.2)
		local steelDark = P.metal(P.rgb(40, 44, 52), 0.08)
		local rivetSt = P.metal(P.rgb(200, 206, 216), 0.26)
		local copper = P.metal(P.rgb(184, 104, 62), 0.2)
		local grip = P.leather(P.rgb(30, 32, 40))
		local gripRib = P.metal(P.rgb(52, 56, 66), 0.1)
		local cryst = P.crystal(P.rgb(40, 140, 255), 0.18)
		local crystPale = P.crystal(P.rgb(110, 200, 255), 0.15)
		local core = P.neon(P.rgb(40, 150, 255))
		local coreHot = P.neon(P.rgb(170, 230, 255))
		local cavity = P.neon(P.rgb(40, 140, 255))

		local glowA, glowB = {}, {}
		local flip = false
		local function G(p)
			flip = not flip
			table.insert(if flip then glowA else glowB, p)
			return p
		end

		-- cristal: prisma + punta a dos aguas (2 cuñas) + núcleo de neón. Sale de `base` hacia `dir`.
		local function frame(pos: Vector3, dir: Vector3, twist: number?): CFrame
			local up = dir.Unit
			local ref = if math.abs(up.Y) < 0.9 then Vector3.yAxis else Vector3.xAxis
			local vx = up:Cross(ref).Unit
			local vz = vx:Cross(up).Unit
			return CFrame.fromMatrix(pos, vx, up, vz) * CFrame.Angles(0, twist or 0, 0)
		end
		local function shard(base: Vector3, dir: Vector3, len: number, w: number, st, twist: number?, noCore: boolean?)
			local cf = frame(base - dir.Unit * 0.12, dir, twist)
			local bodyLen = len * 0.66
			local tipLen = len - bodyLen
			local d = w * 0.8
			local out = {}
			table.insert(out, b:box(Vector3.new(w, bodyLen, d), cf * CFrame.new(0, bodyLen / 2, 0), st, "Crystal"))
			table.insert(out, b:wedge(Vector3.new(w, tipLen, d / 2), cf * CFrame.new(0, bodyLen + tipLen / 2, -d / 4), st, "CrystalTip"))
			table.insert(out, b:wedge(Vector3.new(w, tipLen, d / 2), cf * CFrame.new(0, bodyLen + tipLen / 2, d / 4) * CFrame.Angles(0, math.pi, 0), st, "CrystalTip"))
			if not noCore then
				table.insert(out, G(b:box(Vector3.new(w * 0.52, bodyLen * 0.96, d * 0.52), cf * CFrame.new(0, bodyLen * 0.5, 0), if len > 0.8 then coreHot else core, "CrystalCore")))
			end
			return out
		end

		b:group("Head", function()
			-- ── bloque de acero ─────────────────────────────
			b:bevelBox(Vector3.new(X1 - X0, H, D), CFrame.new(0, headY, 0), steel, 0.14, { edgeStyle = steelEdge, name = "HeadCore" })
			-- ranura horizontal en el bloque izquierdo (lo parte en dos losas)
			B.both(function(s)
				b:box(Vector3.new(0.9, 0.1, 0.04), CFrame.new(-1.08, headY + 0.03, s * (D / 2 + 0.005)), steelDark, "SlabGroove")
				G(b:box(Vector3.new(0.84, 0.05, 0.04), CFrame.new(-1.08, headY + 0.02, s * (D / 2 + 0.012)), core, "SlabGlow"))
				b:box(Vector3.new(0.9, 0.035, 0.04), CFrame.new(-1.08, headY + 0.1, s * (D / 2 + 0.014)), steelEdge, "SlabEdge")
			end)

			-- ── flejes ─────────────────────────────────────
			local function strap(x: number, w: number, rivets: boolean)
				b:bevelBox(Vector3.new(w, H + 0.2, D + 0.2), CFrame.new(x, headY, 0), steelAlt, math.min(0.07, w * 0.3), { edges = "X", edgeStyle = steelEdge, name = "Strap" })
				if rivets then
					B.both(function(s)
						for _, y in { 0.62, 0, -0.62 } do
							b:rivet(Vector3.new(x, headY + y, s * (D / 2 + 0.11)), 0.14, rivetSt)
						end
					end)
					b:rivet(Vector3.new(x, headY + H / 2 + 0.11, 0.45), 0.14, rivetSt)
					b:rivet(Vector3.new(x, headY + H / 2 + 0.11, -0.45), 0.14, rivetSt)
				end
			end
			strap(-0.42, 0.34, true)
			strap(0.32, 0.34, true)
			strap(1.36, 0.1, false)
			strap(1.54, 0.1, false)
			-- pico de acero arriba
			b:spike(CFrame.new(-0.42, headY + H / 2 + 0.08, 0), 0.5, 0.26, steelEdge)
			b:box(Vector3.new(0.36, 0.06, 0.36), CFrame.new(-0.42, headY + H / 2 + 0.11, 0) * CFrame.Angles(0, math.pi / 4, 0), steelDark, "SpikeBase")

			-- ── grietas con cristal en el bloque derecho (±Z) ──
			B.both(function(s)
				local face = B.faceZ(s, headY, D / 2 + 0.02, 0.85)
				local V = Vector2.new
				local hole = { V(-0.3, 0.62), V(-0.05, 0.4), V(0.18, 0.66), V(0.36, 0.3), V(0.32, -0.1), V(0.4, -0.5), V(0.1, -0.38), V(-0.12, -0.66), V(-0.3, -0.32), V(-0.4, 0.1) }
				-- relleno en abanico desde el centro (polígono en estrella → triángulos limpios)
				local cav = face * CFrame.new(0, 0, 0.03)
				local ctr = cav:PointToWorldSpace(Vector3.zero)
				for i = 1, #hole do
					local p0, p1 = hole[i], hole[i % #hole + 1]
					for _, w in b:triangle(ctr, cav:PointToWorldSpace(Vector3.new(p0.X, p0.Y, 0)), cav:PointToWorldSpace(Vector3.new(p1.X, p1.Y, 0)), 0.05, cavity, "Cavity") do
						G(w)
					end
				end
				-- borde dentado de acero roto (más claro)
				local rim = {}
				for _, v in hole do
					table.insert(rim, face:PointToWorldSpace(Vector3.new(v.X * 1.08, v.Y * 1.08, 0.03)))
				end
				b:polyline(rim, 0.07, 0.06, steelEdge, face.LookVector, true, "BrokenRim")
				-- cristales cortos que salen de la grieta
				local n = face.LookVector
				local defs = { { -0.1, 0.25, 0.55, 0.2, 0.4, 0.5 }, { 0.15, -0.15, 0.5, 0.17, -0.3, -0.2 }, { -0.15, -0.35, 0.36, 0.14, -0.2, -0.6 } }
				for i, d in defs do
					local base = face:PointToWorldSpace(Vector3.new(d[1], d[2], 0))
					local dir = n + face.RightVector * d[5] * s + face.UpVector * d[6] * 0.6
					shard(base, dir, d[3], d[4], if i == 1 then crystPale else cryst, i * 0.5)
				end
				-- grieta fina que corre hacia el fleje
				local crack = {}
				for _, v in B.jitterPath(Vector3.new(-0.4, 0.1, 0), Vector3.new(-0.95, 0.4, 0), 3, 0.06, if s > 0 then 3 else 8) do
					table.insert(crack, face:PointToWorldSpace(Vector3.new(v.X, v.Y, 0.01)))
				end
				for _, p in b:polyline(crack, 0.035, 0.03, core, n, false, "HairCrack") do
					G(p)
				end
			end)

			-- ── marco de acero en la cara de golpe (-X) + núcleo ──
			local fx = X0 - 0.04
			for _, sy in { 1, -1 } do
				b:box(Vector3.new(0.14, 0.18, D + 0.06), CFrame.new(fx, headY + sy * (H / 2 - 0.06), 0), steelEdge, "StrikeFrame")
				b:box(Vector3.new(0.14, H - 0.24, 0.18), CFrame.new(fx, headY, sy * (D / 2 - 0.06)), steelEdge, "StrikeFrame")
			end
			for _, cy in { 1, -1 } do
				for _, cz in { 1, -1 } do
					b:rivet(Vector3.new(fx - 0.07, headY + cy * (H / 2 - 0.06), cz * (D / 2 - 0.06)), 0.14, rivetSt)
				end
			end
			b:box(Vector3.new(0.06, H - 0.36, D - 0.36), CFrame.new(fx + 0.01, headY, 0), steelDark, "StrikeSeat")
			G(b:cylinder(0.08, 1.2, CFrame.new(fx - 0.02, headY, 0), cavity, "StrikeCore"))
			b:cylinder(0.08, 0.6, CFrame.new(fx - 0.06, headY, 0), coreHot, "StrikeCoreHot")
		end)

		-- ── estallidos de cristal ───────────────────────────────
		local shimmer = {}
		b:group("Crystals", function()
			local function add(list)
				for _, p in list do
					table.insert(shimmer, p)
				end
			end
			-- gran ramillete en -X
			local burst = {
				{ 0.1, 0.05, 1.45, 0.42, 0, 0, 0.3 },
				{ 0.55, 0.45, 1.15, 0.34, 0.5, 0.45, 0.9 },
				{ -0.5, 0.4, 1.0, 0.3, -0.5, 0.35, 1.6 },
				{ 0.45, -0.5, 0.95, 0.3, 0.45, -0.5, 2.2 },
				{ -0.45, -0.45, 1.1, 0.32, -0.45, -0.4, 0.6 },
				{ 0.75, -0.05, 0.8, 0.26, 0.9, 0.05, 1.2 },
				{ -0.1, 0.75, 0.85, 0.26, 0.05, 0.85, 2.6 },
				{ -0.75, 0.05, 0.75, 0.24, -0.9, 0.1, 0.2 },
				{ 0.0, -0.78, 0.7, 0.24, 0.0, -0.95, 1.9 },
			}
			for i, d in burst do
				local base = Vector3.new(X0 - 0.02, headY + d[2], d[1])
				local dir = Vector3.new(-1, d[6] * 0.9, d[5] * 0.9)
				add(shard(base, dir, d[3] * 1.4, d[4] * 1.35, if i % 3 == 0 then crystPale else cryst, d[7]))
			end
			-- esquina superior izquierda (sube) y abajo
			add(shard(Vector3.new(-1.35, headY + H / 2, 0.45), Vector3.new(-0.55, 1, 0.3), 1.25, 0.4, cryst, 0.4))
			add(shard(Vector3.new(-1.05, headY + H / 2, -0.4), Vector3.new(-0.2, 1, -0.35), 0.9, 0.3, crystPale, 1.1))
			add(shard(Vector3.new(-1.3, headY - H / 2, 0.3), Vector3.new(-0.5, -1, 0.35), 0.85, 0.3, cryst, 0.8))
			-- extremo +X
			local back = {
				{ 0.0, 0.1, 0.85, 0.3, 0, 0.1 },
				{ 0.45, 0.45, 0.7, 0.26, 0.5, 0.55 },
				{ -0.45, -0.4, 0.75, 0.26, -0.5, -0.4 },
				{ 0.4, -0.5, 0.55, 0.22, 0.4, -0.6 },
				{ -0.4, 0.5, 0.6, 0.22, -0.4, 0.6 },
			}
			for i, d in back do
				add(shard(Vector3.new(X1 + 0.02, headY + d[2], d[1]), Vector3.new(1, d[6], d[5]), d[3] * 1.3, d[4] * 1.3, if i % 2 == 0 then crystPale else cryst, i * 0.7))
			end
			-- arriba y abajo del bloque derecho
			add(shard(Vector3.new(1.0, headY + H / 2, 0.35), Vector3.new(0.35, 1, 0.25), 0.95, 0.32, cryst, 0.3))
			add(shard(Vector3.new(0.8, headY + H / 2, -0.45), Vector3.new(0.1, 1, -0.4), 0.5, 0.2, crystPale, 1.3))
			add(shard(Vector3.new(1.05, headY - H / 2, -0.3), Vector3.new(0.3, -1, -0.3), 0.85, 0.3, cryst, 0.9))
			add(shard(Vector3.new(0.75, headY - H / 2, 0.45), Vector3.new(0.1, -1, 0.45), 0.45, 0.2, crystPale, 2.0))
		end)

		-- ── esquirlas flotantes ─────────────────────────────────
		b:group("FloatingShards", function()
			local defs = {
				{ -2.55, headY + 1.25, 0.5, 0.36 }, { -0.9, headY + 1.6, -0.6, 0.28 }, { 1.4, headY + 1.45, 0.5, 0.3 },
				{ 2.75, headY + 0.75, -0.3, 0.26 }, { 2.6, headY - 1.15, 0.55, 0.3 }, { -2.7, headY - 1.0, -0.4, 0.28 },
				{ 0.2, headY + 1.85, 0.2, 0.22 },
			}
			for i, d in defs do
				local pos = Vector3.new(d[1], d[2], d[3])
				local dir = Vector3.new(math.sin(i * 1.7), 1, math.cos(i * 2.3))
				local parts = shard(pos - dir.Unit * (d[4] * 0.5 - 0.12), dir, d[4], d[4] * 0.34, if i % 2 == 0 then crystPale else cryst, i, true)
				table.insert(parts, G(b:box(Vector3.new(d[4] * 0.14, d[4] * 0.42, d[4] * 0.12), frame(pos, dir), coreHot, "ShardCore")))
				b:animate(parts, CFrame.new(pos), { Bob = Vector3.new(0, 0.14, 0), BobSpeed = 0.32 + i * 0.05, Phase = i * 0.45, Spin = Vector3.new(0, 0.9 + (i % 3) * 0.3, 0) })
			end
		end)

		-- ── mango ───────────────────────────────────────────────
		b:group("Shaft", function()
			local top = headY - H / 2 - 0.05
			local bottom = A.ShaftBottom
			b:cylY(top - bottom, 0.38, CFrame.new(0, (top + bottom) / 2, 0), grip, "ShaftCore")
			-- collar de acero + anillo de cobre
			b:bevelBox(Vector3.new(0.7, 0.24, 0.7), CFrame.new(0, top - 0.12, 0), steelAlt, 0.18, { edges = "Y", edgeStyle = steelEdge, name = "Collar" })
			b:cylY(0.16, 0.6, CFrame.new(0, top - 0.33, 0), copper, "CopperRing")
			b:cylY(0.04, 0.64, CFrame.new(0, top - 0.25, 0), steelEdge, "CopperLip")
			b:cylY(0.04, 0.64, CFrame.new(0, top - 0.41, 0), steelEdge, "CopperLip")
			for i = 0, 3 do
				local a = i * math.pi / 2 + math.pi / 4
				b:rivet(Vector3.new(math.cos(a) * 0.33, top - 0.12, math.sin(a) * 0.33), 0.1, rivetSt)
			end
			-- segmentos de agarre
			for i = 0, 6 do
				b:cylY(0.05, 0.46, CFrame.new(0, 1.55 - i * 0.22, 0), gripRib, "GripRib")
			end
			-- jaula de acero con diamantes de cristal
			local function cage(y: number, h: number, gem: number)
				b:bevelBox(Vector3.new(0.58, h, 0.58), CFrame.new(0, y, 0), steelAlt, 0.16, { edges = "Y", edgeStyle = steelEdge, name = "Cage" })
				b:cylY(0.05, 0.66, CFrame.new(0, y + h / 2, 0), steelEdge, "CageLip")
				b:cylY(0.05, 0.66, CFrame.new(0, y - h / 2, 0), steelEdge, "CageLip")
				for i = 0, 3 do
					local a = i * math.pi / 2
					local pos = Vector3.new(math.cos(a) * 0.3, y, math.sin(a) * 0.3)
					local list = b:gem(CFrame.new(pos) * CFrame.Angles(0, -a, 0), gem, cryst, core)
					G(list[2])
				end
			end
			cage(0.05, 0.5, 0.2)
			cage(-0.95, 0.3, 0.14)
			for i = 0, 2 do
				b:cylY(0.05, 0.46, CFrame.new(0, -0.45 - i * 0.18, 0), gripRib, "GripRib")
			end
		end)

		-- ── pomo con gema ───────────────────────────────────────
		b:group("Pommel", function()
			local py = A.PommelY - 0.05
			b:bevelBox(Vector3.new(0.76, 0.38, 0.76), CFrame.new(0, py, 0), steel, 0.2, { edges = "Y", edgeStyle = steelEdge, name = "Pommel" })
			b:cylY(0.06, 0.62, CFrame.new(0, py + 0.22, 0), steelEdge, "PommelLip")
			for i = 0, 3 do
				local a = i * math.pi / 2 + math.pi / 4
				b:rivet(Vector3.new(math.cos(a) * 0.31, py, math.sin(a) * 0.31), 0.1, rivetSt)
			end
			local g = b:gem(CFrame.new(0, py - 0.3, 0), 0.26, crystPale, coreHot)
			G(g[2])
		end)

		b:pulse(glowA, 0, 0.35, 0.9, 0)
		b:pulse(glowB, 0, 0.35, 0.9, 0.55)
		local _ = shimmer

		-- ── efectos ─────────────────────────────────────────────
		b:group("FX", function()
			local v = b:fxVolume(Vector3.new(5.2, 2.8, 2.6), CFrame.new(-0.2, headY, 0), "SparkleVolume")
			b:emitter(v, B.Particles.sparkle(P.rgb(150, 220, 255), 10), "CrystalSparkle")
			b:emitter(b:fxVolume(Vector3.new(1.2, 2.2, 2.2), CFrame.new(X0 - 0.7, headY, 0), "BurstVolume"), B.Particles.frost(P.rgb(120, 200, 255), 8), "CrystalFrost")
			b:emitter(v, B.Particles.orb(iceC, 4), "CrystalOrbs")
		end)
		b:light(Vector3.new(X0 - 0.6, headY, 0), iceC, 1.6, 10, { pulse = { 1.0, 2.2 }, pulseSpeed = 0.9, name = "BurstGlow" })
		b:light(Vector3.new(0.85, headY, 0), P.rgb(130, 210, 255), 0.9, 7, { pulse = { 0.5, 1.3 }, pulseSpeed = 1.3, name = "CoreGlow" })

		-- impacto: esquirlas de cristal + escarcha + destello
		local shards = B.Particles.sparkle(P.rgb(170, 230, 255), 0)
		shards.Speed = NumberRange.new(8, 16)
		shards.Size = B.seq(0, 0.45, 1, 0)
		shards.Acceleration = Vector3.new(0, -20, 0)
		shards.SpreadAngle = Vector2.new(75, 75)
		shards.Lifetime = NumberRange.new(0.4, 0.8)
		local frost = B.Particles.frost(iceC, 0)
		frost.Speed = NumberRange.new(3, 7)
		frost.Size = B.seq(0, 0.4, 1, 0)
		local ring = B.Particles.orb(P.rgb(140, 210, 255), 0)
		ring.Speed = NumberRange.new(5, 9)
		ring.Lifetime = NumberRange.new(0.25, 0.45)
		ring.Size = B.seq(0, 0.3, 1, 0.6)
		local hit = b:impact(CFrame.new(X0 - 0.5, headY, 0), iceC, { sparks = 26, flash = 8, extra = { shards, frost, ring } })
		hit:FindFirstChild("ImpactExtra1"):SetAttribute("FX_Emit", 28)
		hit:FindFirstChild("ImpactExtra2"):SetAttribute("FX_Emit", 16)
		hit:FindFirstChild("ImpactExtra3"):SetAttribute("FX_Emit", 12)
		b:trail(Vector3.new(0, headY + H / 2, 0), Vector3.new(0, headY - H / 2, 0), P.rgb(200, 240, 255), P.rgb(40, 120, 255), { lifetime = 0.26 })
	end,
}
