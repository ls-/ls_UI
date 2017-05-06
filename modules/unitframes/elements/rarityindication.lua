local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc

-- Mine
local function CheckUnitClassification(frame)
	local class = _G.UnitClassification(frame.unit)

	if class == "worldboss" or class == "elite" or class == "rareelite" then
		if frame._skin ~= "elite" then
			frame.FGParent:SetBorderColor(M.COLORS.YELLOW:GetRGB())
			frame.Insets:SetVertexColor(M.COLORS.YELLOW:GetRGB())

			frame._skin = "elite"
		end
	else
		if frame._skin ~= "none" then
			frame.FGParent:SetBorderColor(1, 1, 1)
			frame.Insets:SetVertexColor(1, 1, 1)

			frame._skin = "none"
		end
	end
end

function UF:CreateRarityIndicator(frame)
	frame._skin = "none"

	hooksecurefunc(frame, "Show", CheckUnitClassification)
end
