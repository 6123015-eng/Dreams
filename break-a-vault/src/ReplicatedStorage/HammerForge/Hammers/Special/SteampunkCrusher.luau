-- Steampunk Crusher (Special) — una caldera de vapor convertida en martillo: tambor octagonal de hierro
-- oscuro con bandas de latón remachadas, placas atornilladas y aristas de acero gastado.
-- En la cara de golpe izquierda (-X), un RELOJ dentro de un engrane gigante de latón: el engrane gira lento,
-- las manecillas avanzan y un cristal ámbar lo cubre. En ambas caras de emblema, un engrane grande con rayos
-- que gira engranado con uno chico (en sentido contrario), un MANÓMETRO con aguja que tiembla y una
-- rejilla de horno con fuego ámbar que late. Arriba: tubería de cobre con coples, dos chimeneas que
-- escupen vapor y una válvula de seguridad. Abajo, un codo de tubo que suelta vapor. La tapa derecha (+X)
-- lleva un engrane que gira y un volante de válvula.
-- Mango de hierro con agarre de anillos de cobre, collar de latón con brida y pomo octagonal remachado.
-- FX: bocanadas de vapor, chispas de horno, engranes girando, luz cálida que late.
return {
	Id = "SteampunkCrusher",
	DisplayName = "Steampunk Crusher",
	Rarity = "Special",
	Order = 5,
	Theme = "Clockwork Foundry",
	Build = function(b, P, B)
		local A = B.Anatomy
		local headY = A.HeadY + 0.1
		local TAU = math.pi * 2
		local H, D = 1.95, 1.8
		local X0, X1 = -1.36, 1.46 -- tambor

		-- ── estilos ─────────────────────────────────────────────
		local iron = P.metal(P.rgb(46, 44, 48), 0.08)
		local ironPlate = P.metal(P.rgb(32, 31, 35), 0.06)
		local ironEdge = P.metal(P.rgb(118, 112, 104), 0.16) -- acero gastado en aristas
		local drumEdge = P.metal(P.rgb(96, 82, 66), 0.14) -- chaflán del tambor: acero tostado
		local black = P.metal(P.rgb(22, 20, 22), 0.04)
		local brass = P.metal(P.rgb(214, 158, 64), 0.2)
		local brassBright = P.foil(P.rgb(246, 202, 112), 0.24)
		local brassDeep = P.metal(P.rgb(158, 104, 36), 0.16)
		local copper = P.metal(P.rgb(198, 104, 54), 0.18)
		local copperBright = P.foil(P.rgb(232, 146, 92), 0.22)
		local copperDark = P.metal(P.rgb(126, 62, 34), 0.12)
		local leather = P.leather(P.rgb(62, 38, 26))
		local dialFace = P.metal(P.rgb(236, 226, 200), 0.04)
		local clockFace = P.metal(P.rgb(44, 30, 24), 0.08)
		local red = P.paint(P.rgb(196, 34, 28))
		local fireC = P.rgb(255, 150, 40)
		local fireHot = P.rgb(255, 214, 120)
		local fire = P.neon(fireC)
		local fireCore = P.neon(fireHot)
		local amberGlass = P.glass(P.rgb(255, 226, 180), 0.86)
		local gaugeGlass = P.glass(P.rgb(230, 240, 255), 0.75)

		-- ── helpers ────────────────────────────────────────────
		local function addAll(dst, src)
			for _, p in src do
				table.insert(dst, p)
			end
			return dst
		end
		-- engrane sobre el plano XY de `plane` (eje = Z local). Devuelve sus piezas (para animarlas).
		local function gear(plane: CFrame, r: number, teeth: number, td: number, t: number, st, opts)
			local o = opts or {}
			local parts = {}
			local rim = r * (o.rimK or 0.24)
			if o.spokes then
				addAll(parts, b:ring(plane * CFrame.Angles(math.pi / 2, 0, 0), r - rim / 2, rim, o.segments or 12, st, "GearRim", t))
				for i = 0, o.spokes - 1 do
					local a = TAU * i / o.spokes + (o.rot or 0)
					local d = Vector3.new(math.cos(a), math.sin(a), 0)
					local sp = b:line(plane:PointToWorldSpace(d * r * 0.2), plane:PointToWorldSpace(d * (r - rim * 0.6)), r * 0.13, t * 0.75, o.spokeSt or st, plane.ZVector, "GearSpoke")
					if sp then
						table.insert(parts, sp)
					end
				end
			else
				table.insert(parts, b:cylZ(t, r * 2, plane, st, "GearBody"))
				table.insert(parts, b:cylZ(t + 0.02, r * 1.3, plane, o.spokeSt or st, "GearInner"))
			end
			local tw = TAU * r / teeth * 0.5
			for i = 0, teeth - 1 do
				local a = TAU * i / teeth + (o.rot or 0)
				table.insert(parts, b:box(Vector3.new(td + 0.04, tw, t * 0.92), plane * CFrame.Angles(0, 0, a) * CFrame.new(r + td / 2 - 0.02, 0, 0), o.toothSt or st, "GearTooth"))
			end
			if o.noHub then
				return parts
			end
			-- cubo: tambor + tapa brillante + tornillo
			table.insert(parts, b:cylZ(t + 0.08, r * 0.5, plane * CFrame.new(0, 0, 0.02), o.hubSt or st, "GearHub"))
			table.insert(parts, b:cylZ(0.05, r * 0.3, plane * CFrame.new(0, 0, t / 2 + 0.07), o.capSt or brassBright, "GearCap"))
			return parts
		end
		-- placa remachada sobre una cara
		local function plate(face: CFrame, x: number, y: number, w: number, h: number, st, rivetSt, noRivets)
			b:box(Vector3.new(w + 0.06, h + 0.06, 0.04), face * CFrame.new(x, y, 0.02), ironEdge, "PlateLip")
			b:box(Vector3.new(w, h, 0.07), face * CFrame.new(x, y, 0.035), st, "Plate")
			if noRivets then
				return
			end
			for _, c in { -1, 1 } do
				b:rivet(face:PointToWorldSpace(Vector3.new(x + c * (w / 2 - 0.09), y + c * (h / 2 - 0.09), 0.075)), 0.1, rivetSt or brass)
			end
		end

		-- ── cabeza ──────────────────────────────────────────────
		b:group("Head", function()
			local cx = (X0 + X1) / 2
			-- tambor octagonal (chaflanes a lo largo de X)
			b:bevelBox(Vector3.new(X1 - X0, H, D), CFrame.new(cx, headY, 0), iron, 0.32, { edges = "X", edgeStyle = drumEdge, name = "Drum" })
			-- bandas de latón remachadas
			for _, x in { -1.24, -0.52, 0.78 } do
				b:bevelBox(Vector3.new(0.17, H + 0.12, D + 0.12), CFrame.new(x, headY, 0), brass, 0.38, { edges = "X", edgeStyle = brassBright, name = "Band" })
				B.both(function(s)
					b:rivetLine(Vector3.new(x, headY - 0.52, s * (D / 2 + 0.07)), Vector3.new(x, headY + 0.52, s * (D / 2 + 0.07)), 2, 0.1, brassBright)
				end)
			end

			-- ── caras de emblema (±Z) ───────────────────────────
			B.both(function(s)
				local face = B.faceZ(s, headY, D / 2)
				-- placas atornilladas por sección
				plate(face, s * -0.88, -0.02, 0.6, 1.16, ironPlate)
				plate(face, s * 0.13, 0, 1.18, 1.22, ironPlate, nil, true)
				plate(face, s * 1.12, 0, 0.6, 1.16, ironPlate)

				-- engrane grande con rayos + engrane chico engranado (giran en sentidos opuestos)
				local gc = Vector2.new(s * 0.13, 0.04)
				local r1, r2, td = 0.6, 0.27, 0.13
				local mount = face * CFrame.new(gc.X, gc.Y, 0.1)
				b:cylZ(0.08, 0.5, mount * CFrame.new(0, 0, -0.03), black, "GearAxle")
				local g1 = face * CFrame.new(gc.X, gc.Y, 0.16)
				local big = gear(g1, r1, 10, td, 0.12, brass, { spokes = 6, segments = 10, toothSt = brassDeep, hubSt = copper })
				b:animate(big, g1, { Spin = Vector3.new(0, 0, 0.55) })
				local ang = math.rad(if s > 0 then 205 else -25)
				local dist = r1 + r2 + td * 0.55
				local g2p = gc + Vector2.new(math.cos(ang), math.sin(ang)) * dist
				local g2 = face * CFrame.new(g2p.X, g2p.Y, 0.2)
				local small = gear(g2, r2, 8, 0.1, 0.1, copper, { spokeSt = copperDark, hubSt = brass, rot = 0.2 })
				b:animate(small, g2, { Spin = Vector3.new(0, 0, -0.55 * r1 / r2) })

				-- manómetro: bisel de latón, carátula crema, marcas, zona roja, aguja que tiembla, cristal
				local gp = face * CFrame.new(s * 1.12, 0.3, 0.16)
				b:cylZ(0.14, 0.82, gp, brass, "GaugeBezel")
				b:cylZ(0.1, 0.9, gp * CFrame.new(0, 0, -0.04), brassDeep, "GaugeBack")
				b:cylZ(0.04, 0.64, gp * CFrame.new(0, 0, 0.06), dialFace, "GaugeFace")
				for i = 0, 4 do
					local a = math.rad(220 - i * 65)
					local d = Vector3.new(math.cos(a), math.sin(a), 0)
					b:line(gp:PointToWorldSpace(d * 0.22 + Vector3.new(0, 0, 0.085)), gp:PointToWorldSpace(d * 0.29 + Vector3.new(0, 0, 0.085)), 0.025, 0.02, if i >= 4 then red else black, gp.ZVector, "GaugeTick")
				end
				local needles = {}
				for k, deg in { 140, 55 } do
					local a = math.rad(if s > 0 then deg else 180 - deg)
					local d = Vector3.new(math.cos(a), math.sin(a), 0)
					local nd = b:line(gp:PointToWorldSpace(Vector3.new(0, 0, 0.1) - d * 0.05), gp:PointToWorldSpace(d * 0.26 + Vector3.new(0, 0, 0.1)), 0.035, 0.025, red, gp.ZVector, "GaugeNeedle")
					table.insert(needles, nd)
					b:pulse({ nd }, 0, 1, 1.4, (k - 1) * 0.357)
				end
				b:cylZ(0.05, 0.09, gp * CFrame.new(0, 0, 0.12), brassBright, "GaugePin")
				b:cylZ(0.03, 0.66, gp * CFrame.new(0, 0, 0.14), gaugeGlass, "GaugeGlass")
				-- tubito que alimenta el manómetro
				b:cylY(0.32, 0.1, gp * CFrame.new(0, -0.5, -0.06), copper, "GaugeStem")

				-- rejilla del horno con fuego ámbar (debajo del manómetro)
				local fp = face * CFrame.new(s * 1.12, -0.42, 0.02)
				b:box(Vector3.new(0.5, 0.32, 0.08), fp * CFrame.new(0, 0, 0.04), brass, "FurnaceFrame")
				b:box(Vector3.new(0.56, 0.06, 0.1), fp * CFrame.new(0, 0.17, 0.05), brassBright, "FurnaceHood")
				b:box(Vector3.new(0.4, 0.22, 0.04), fp * CFrame.new(0, 0, 0.07), black, "FurnaceHole")
				local f1 = b:box(Vector3.new(0.38, 0.2, 0.04), fp * CFrame.new(0, 0, 0.08), fire, "FurnaceFire")
				local f2 = b:box(Vector3.new(0.24, 0.1, 0.04), fp * CFrame.new(0, -0.03, 0.09), fireCore, "FurnaceCore")
				b:pulse({ f1 }, 0, 0.35, 1.3)
				b:pulse({ f2 }, 0, 0.6, 2.1, 0.3)
				for _, i in { -0.6, 0.6 } do
					b:box(Vector3.new(0.035, 0.24, 0.05), fp * CFrame.new(i * 0.1, 0, 0.11), ironEdge, "FurnaceBar")
				end

				-- ojo de buey en la sección izquierda (fuego visto a través del cristal)
				local pp = face * CFrame.new(s * -0.88, 0.32, 0.08)
				b:cylZ(0.1, 0.42, pp, copper, "Porthole")
				b:cylZ(0.04, 0.3, pp * CFrame.new(0, 0, 0.04), fire, "PortholeFire")
				b:cylZ(0.04, 0.32, pp * CFrame.new(0, 0, 0.065), amberGlass, "PortholeGlass")

				-- tubo frontal inferior con abrazaderas
				local py = -0.74
				local p0 = face:PointToWorldSpace(Vector3.new(-1.25, py, 0.12))
				local p1 = face:PointToWorldSpace(Vector3.new(0.72, py, 0.12))
				b:line(p0, p1, 0.13, 0.13, copper, Vector3.yAxis, "FrontPipe")
				for _, x in { -0.9, 0.3 } do
					b:box(Vector3.new(0.08, 0.17, 0.17), face * CFrame.new(x, py, 0.12), brassDeep, "PipeClamp")
				end
			end)

			-- ── cara de golpe -X: reloj dentro de un engrane gigante ─────
			local cp = B.faceX(-1, -X0, headY) -- plano: Z local = -X
			b:cylZ(0.16, 1.66, cp * CFrame.new(0, 0, 0.06), iron, "ClockMount")
			local cg = cp * CFrame.new(0, 0, 0.24)
			local clockGear = gear(cg, 1.05, 16, 0.17, 0.24, brass, { spokes = 0, segments = 14, rimK = 0.2, toothSt = brassDeep, noHub = true })
			-- (el cubo del engrane gigante queda oculto detrás de la carátula)
			b:animate(clockGear, cg, { Spin = Vector3.new(0, 0, 0.3) })
			b:cylZ(0.12, 1.86, cp * CFrame.new(0, 0, 0.26), copper, "ClockBezel")
			b:cylZ(0.06, 1.66, cp * CFrame.new(0, 0, 0.22), brassDeep, "ClockBack")
			b:cylZ(0.05, 1.62, cp * CFrame.new(0, 0, 0.27), clockFace, "ClockFace")
			-- marcas de hora (las 4 principales brillan en ámbar)
			for i = 0, 11 do
				local a = TAU * i / 12
				local d = Vector3.new(math.cos(a), math.sin(a), 0)
				local major = i % 3 == 0
				b:line(cp:PointToWorldSpace(d * (if major then 0.52 else 0.6) + Vector3.new(0, 0, 0.3)), cp:PointToWorldSpace(d * 0.72 + Vector3.new(0, 0, 0.3)), if major then 0.07 else 0.04, 0.03, if major then fire else brassBright, cp.ZVector, "ClockTick")
			end
			-- manecillas (giran) + centro
			local hp = cp * CFrame.new(0, 0, 0.33)
			local hour = b:line(hp:PointToWorldSpace(Vector3.new(0, -0.08, 0)), hp:PointToWorldSpace(Vector3.new(0.3, 0.26, 0)), 0.09, 0.03, brassBright, cp.ZVector, "HourHand")
			local minute = b:line(hp:PointToWorldSpace(Vector3.new(0, -0.1, 0.02)), hp:PointToWorldSpace(Vector3.new(-0.08, 0.6, 0.02)), 0.05, 0.03, brassBright, cp.ZVector, "MinuteHand")
			b:animate({ hour }, hp, { Spin = Vector3.new(0, 0, -0.12) })
			b:animate({ minute }, hp, { Spin = Vector3.new(0, 0, -0.9) })
			b:cylZ(0.08, 0.16, cp * CFrame.new(0, 0, 0.36), brass, "ClockPin")
			b:cylZ(0.04, 1.58, cp * CFrame.new(0, 0, 0.4), amberGlass, "ClockGlass")
			for i = 0, 7 do
				local a = TAU * i / 8 + TAU / 16
				b:rivet(cp:PointToWorldSpace(Vector3.new(math.cos(a) * 0.86, math.sin(a) * 0.86, 0.41)), 0.08, brassBright)
			end

			-- placas negras remachadas arriba y abajo entre bandas (rompen el gris del tambor)
			for _, seg in { { -1.16, -0.6 }, { -0.44, 0.7 }, { 0.86, 1.38 } } do
				for _, sy in { 1, -1 } do
					b:box(Vector3.new(seg[2] - seg[1], 0.05, D - 0.78), CFrame.new((seg[1] + seg[2]) / 2, headY + sy * (H / 2 + 0.02), 0), ironPlate, "TopPlate")
				end
			end

			-- ── tapa +X: brida octagonal, engrane giratorio y volante de válvula ─────
			local rp = B.faceX(1, X1, headY)
			b:bevelBox(Vector3.new(H + 0.14, D + 0.14, 0.2), rp * CFrame.new(0, 0, 0.02), brass, 0.42, { edges = "Z", edgeStyle = brassBright, name = "EndFlange" })
			b:bevelBox(Vector3.new(H - 0.2, D - 0.2, 0.08), rp * CFrame.new(0, 0, 0.14), copperDark, 0.32, { edges = "Z", edgeStyle = copper, name = "EndPlate" })
			for i = 0, 7 do
				local a = TAU * i / 8 + TAU / 16
				b:rivet(rp:PointToWorldSpace(Vector3.new(math.cos(a) * 0.84, math.sin(a) * 0.8, 0.13)), 0.1, brassBright)
			end
			local eg = rp * CFrame.new(0, 0, 0.24)
			local endGear = gear(eg, 0.5, 10, 0.12, 0.1, brass, { spokeSt = brassDeep, hubSt = copper })
			b:animate(endGear, eg, { Spin = Vector3.new(0, 0, -0.7) })
			local vw = rp * CFrame.new(0, 0, 0.42)
			b:cylZ(0.2, 0.12, rp * CFrame.new(0, 0, 0.33), iron, "ValveStem")
			b:ring(vw * CFrame.Angles(math.pi / 2, 0, 0), 0.24, 0.06, 8, red, "ValveWheel", 0.06)
			for i = 0, 3 do
				local a = TAU * i / 4
				b:line(vw:PointToWorldSpace(Vector3.zero), vw:PointToWorldSpace(Vector3.new(math.cos(a), math.sin(a), 0) * 0.23), 0.04, 0.04, red, vw.ZVector, "ValveSpoke")
			end
			b:cylZ(0.06, 0.1, vw * CFrame.new(0, 0, 0.02), brassBright, "ValveCap")

			-- ── arriba: tubería, chimeneas de vapor y válvula de seguridad ─────
			local top = headY + H / 2
			local pz = 0.48
			b:cylinder(2.3, 0.18, CFrame.new(-0.1, top + 0.32, pz), copper, "TopPipe")
			for _, x in { -1.25, 1.05 } do
				b:cylY(0.32, 0.18, CFrame.new(x, top + 0.16, pz), copper, "PipeDrop")
				b:ball(0.22, Vector3.new(x, top + 0.32, pz), copperBright, "PipeElbow")
				b:cylY(0.08, 0.3, CFrame.new(x, top + 0.04, pz), brass, "PipeFlange")
			end
			for _, x in { -0.6, 0.35 } do
				b:cylinder(0.12, 0.25, CFrame.new(x, top + 0.32, pz), brass, "PipeCoupling")
			end
			local stacks = {}
			for i, x in { -0.85, 0.95 } do
				local z = -0.36
				local h = if i == 1 then 0.62 else 0.48
				b:cylY(0.1, 0.46, CFrame.new(x, top + 0.04, z), brassDeep, "StackBase")
				b:cylY(h, 0.3, CFrame.new(x, top + h / 2, z), copper, "Stack")
				b:cylY(0.06, 0.36, CFrame.new(x, top + h * 0.45, z), brass, "StackRing")
				b:cylY(0.1, 0.4, CFrame.new(x, top + h, z), brass, "StackLip")
				b:cylY(0.02, 0.26, CFrame.new(x, top + h + 0.05, z), black, "StackMouth")
				table.insert(stacks, Vector3.new(x, top + h + 0.12, z))
			end
			-- válvula de seguridad (domo de latón + palanca)
			b:cylY(0.18, 0.3, CFrame.new(0.1, top + 0.09, -0.3), brassDeep, "ValveBase")
			b:ball(0.36, Vector3.new(0.1, top + 0.24, -0.3), brass, "ValveDome")
			b:line(Vector3.new(0.1, top + 0.42, -0.3), Vector3.new(0.48, top + 0.36, -0.3), 0.05, 0.05, ironEdge, Vector3.zAxis, "ValveLever")
			b:ball(0.12, Vector3.new(0.5, top + 0.36, -0.3), red, "ValveWeight")

			-- ── abajo: codo de tubo con salida de vapor ─────
			local bot = headY - H / 2
			local ex, ez = 1.1, 0.36
			b:cylY(0.5, 0.2, CFrame.new(ex, bot - 0.22, ez), copper, "ElbowDown")
			b:cylY(0.08, 0.3, CFrame.new(ex, bot - 0.02, ez), brass, "ElbowFlange")
			b:ball(0.24, Vector3.new(ex, bot - 0.5, ez), copperBright, "Elbow")
			b:cylinder(0.32, 0.2, CFrame.new(ex + 0.16, bot - 0.5, ez), copper, "ElbowOut")
			b:cylinder(0.08, 0.3, CFrame.new(ex + 0.34, bot - 0.5, ez), brass, "ElbowNozzle")
			b:cylinder(0.02, 0.18, CFrame.new(ex + 0.385, bot - 0.5, ez), black, "ElbowMouth")
			b:box(Vector3.new(0.9, 0.06, 0.9), CFrame.new(0.1, bot - 0.02, 0), brassDeep, "BottomPlate")

			-- ── FX de cabeza ─────
			for i, pos in stacks do
				local steam = B.Particles.smoke(P.rgb(236, 232, 228), 4)
				steam.Size = B.seq(0, 0.3, 1, 1.4)
				steam.Speed = NumberRange.new(1.2, 2)
				steam.Transparency = B.seq(0, 0.45, 0.4, 0.7, 1, 1)
				b:emitter(pos, steam, "Steam" .. i)
				local sp = B.Particles.ember(fireC, 3)
				sp.Size = B.seq(0, 0.1, 1, 0)
				b:emitter(pos, sp, "StackSparks" .. i)
			end
			local jet = B.Particles.smoke(P.rgb(236, 232, 228), 5)
			jet.EmissionDirection = Enum.NormalId.Right
			jet.Speed = NumberRange.new(1.5, 2.6)
			jet.Size = B.seq(0, 0.2, 1, 1.2)
			jet.Lifetime = NumberRange.new(0.7, 1.2)
			b:emitter(CFrame.new(ex + 0.42, bot - 0.5, ez), jet, "ElbowSteam")
		end)

		-- ── mango ───────────────────────────────────────────────
		-- k = escala radial del mango (agarre robusto como el concepto); gBot = fin inferior del agarre
		local k = 1.25
		local gBot = -0.95
		b:group("Shaft", function()
			local top = headY - H / 2
			-- collar de latón con brida y anillo de hierro remachado
			b:bevelBox(Vector3.new(0.84 * k, 0.16, 0.84 * k), CFrame.new(0, top - 0.1, 0), brass, 0.22 * k, { edges = "Y", edgeStyle = brassBright, name = "CollarFlange" })
			b:cylY(0.34, 0.6 * k, CFrame.new(0, top - 0.34, 0), brassDeep, "CollarBell")
			b:cylY(0.06, 0.66 * k, CFrame.new(0, top - 0.2, 0), brassBright, "CollarLip")
			b:cylY(0.14, 0.58 * k, CFrame.new(0, top - 0.6, 0), iron, "IronRing")
			for i = 0, 5 do
				local a = TAU * i / 6
				b:rivet(Vector3.new(math.cos(a) * 0.29 * k, top - 0.6, math.sin(a) * 0.29 * k), 0.07 * k, brassBright)
			end
			local s0, s1 = gBot, top - 0.6
			b:cylY(s1 - s0, 0.42 * k, CFrame.new(0, (s0 + s1) / 2, 0), iron, "Shaft")
			-- banda de hierro y latón arriba del agarre
			b:cylY(0.18, 0.54 * k, CFrame.new(0, 1.1, 0), ironEdge, "UpperBand")
			b:cylY(0.06, 0.58 * k, CFrame.new(0, 1.22, 0), brass, "UpperBandLip")
			-- agarre: anillos de cobre sobre cuero
			b:cylY(1.76, 0.46 * k, CFrame.new(0, 0.07, 0), leather, "GripCore")
			local n = 9
			for i = 0, n - 1 do
				local y = -0.78 + i * (1.7 / (n - 1))
				b:cylY(0.13, (if i % 2 == 0 then 0.6 else 0.54) * k, CFrame.new(0, y, 0), if i % 2 == 0 then copper else copperDark, "GripRing")
			end
			b:cylY(0.1, 0.6 * k, CFrame.new(0, gBot + 0.05, 0), brass, "LowerBand")
		end)

		-- ── pomo (1.3x, achatado) ───────────────────────────────
		b:group("Pommel", function()
			local pk = 1.3
			local y = gBot - 0.23
			b:bevelBox(Vector3.new(0.82 * pk, 0.28, 0.82 * pk), CFrame.new(0, y, 0), iron, 0.22 * pk, { edges = "Y", edgeStyle = ironEdge, name = "Pommel" })
			b:bevelBox(Vector3.new(0.88 * pk, 0.08, 0.88 * pk), CFrame.new(0, y + 0.18, 0), brass, 0.24 * pk, { edges = "Y", edgeStyle = brassBright, name = "PommelTop" })
			b:bevelBox(Vector3.new(0.7 * pk, 0.08, 0.7 * pk), CFrame.new(0, y - 0.18, 0), brassDeep, 0.19 * pk, { edges = "Y", edgeStyle = brass, name = "PommelCap" })
			for i = 0, 3 do
				local a = TAU * i / 4 + TAU / 8
				b:rivet(Vector3.new(math.cos(a) * 0.4 * pk, y, math.sin(a) * 0.4 * pk), 0.1 * pk, brassBright)
			end
			local pg = CFrame.new(0, y - 0.23, 0) * CFrame.Angles(math.pi / 2, 0, 0)
			local pgear = gear(pg, 0.2 * pk, 6, 0.07 * pk, 0.06, brass, { hubSt = copper })
			b:animate(pgear, pg, { Spin = Vector3.new(0, 0, 0.8) })
		end)

		-- ── efectos ─────────────────────────────────────────────
		b:group("FX", function()
			local v = b:fxVolume(Vector3.new(3, 1.8, 2.1), CFrame.new(0.05, headY, 0), "HeatVolume")
			local glint = B.Particles.sparkle(fireHot, 5)
			glint.Size = B.seq(0, 0, 0.2, 0.22, 1, 0)
			b:emitter(v, glint, "BrassGlint")
		end)
		b:light(Vector3.new(0.1, headY, 0), fireC, 1.2, 9, { pulse = { 0.7, 1.5 }, pulseSpeed = 1.3, name = "FurnaceLight" })

		-- impacto: chispas de forja + bocanada de vapor + engranitos/brasas
		local puff = B.Particles.smoke(P.rgb(236, 232, 228), 0)
		puff.Speed = NumberRange.new(3, 6)
		puff.SpreadAngle = Vector2.new(70, 70)
		puff.Lifetime = NumberRange.new(0.5, 1)
		local embers = B.Particles.ember(fireC, 0)
		embers.Speed = NumberRange.new(5, 10)
		embers.SpreadAngle = Vector2.new(80, 80)
		embers.Acceleration = Vector3.new(0, -8, 0)
		local hit = b:impact(CFrame.new(X0 - 0.62, headY, 0), fireC, { sparks = 26, flash = 7, extra = { puff, embers } })
		hit:FindFirstChild("ImpactExtra1"):SetAttribute("FX_Emit", 8)
		hit:FindFirstChild("ImpactExtra2"):SetAttribute("FX_Emit", 18)
		b:trail(Vector3.new(0, headY + H / 2 + 0.2, 0), Vector3.new(0, headY - H / 2 - 0.2, 0), fireHot, P.rgb(190, 110, 50), { lifetime = 0.22 })
	end,
}
