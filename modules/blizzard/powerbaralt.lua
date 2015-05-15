local _, ns = ...
local E, M = ns.E, ns.M

local B = E.Blizzard

function B:HandlePowerBarAlt()
	local holder = CreateFrame("Frame", "LSPowerBarAltHolder", UIParent)
	holder:SetSize(64, 64)
	holder:SetPoint("BOTTOM", 0, 230)
	E:CreateMover(holder)

	PlayerPowerBarAlt:ClearAllPoints()
	PlayerPowerBarAlt:SetParent(holder)
	PlayerPowerBarAlt:SetPoint("BOTTOM", holder, "BOTTOM", 0, 0)
	PlayerPowerBarAlt.ignoreFramePositionManager = true
end
