-- Inicia los efectos visuales de los martillos (giros, pulsos, trail y golpe) en este cliente.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HammerForge = ReplicatedStorage:WaitForChild("HammerForge")
local FX = require(HammerForge:WaitForChild("FX"))

FX.Start()
