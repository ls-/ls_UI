local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc

-- Blizz
local UnitIsPlayer = _G.UnitIsPlayer
local UnitClass = _G.UnitClass
local UnitClassification = _G.UnitClassification

-- Mine
local function CheckUnitClass(frame)
	local class, _

	if UnitIsPlayer(frame.unit) then
		if frame._config.class.player then
			_, class = UnitClass(frame.unit)

			if class and frame._skin ~= class then
				frame.Border:SetVertexColor(M.COLORS.CLASS[class]:GetRGB())
				frame.Insets:SetVertexColor(M.COLORS.CLASS[class]:GetRGB())

				frame._skin = class

				return
			end
		end
	else
		if frame._config.class.npc then
			class = UnitClassification(frame.unit)

			if class and (class == "worldboss" or class == "elite" or class == "rareelite") then
				if frame._skin ~= "elite" then
					frame.Border:SetVertexColor(M.COLORS.YELLOW:GetRGB())
					frame.Insets:SetVertexColor(M.COLORS.YELLOW:GetRGB())

					frame._skin = "elite"

					return
				end
			else
				class = nil
			end
		end
	end

	if not class and frame._skin ~= "none" then
		frame.Border:SetVertexColor(1, 1, 1)
		frame.Insets:SetVertexColor(1, 1, 1)

		frame._skin = "none"
	end
end

function UF:CreateClassIndicator(frame)
	frame._skin = "none"

	hooksecurefunc(frame, "Show", CheckUnitClass)

	frame.ClassIndicator = true
end

function UF:UpdateClassIndicator(frame)
	CheckUnitClass(frame)
end
