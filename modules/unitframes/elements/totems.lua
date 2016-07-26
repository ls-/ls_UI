local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local UF = E:GetModule("UnitFrames")

-- Lua
local _G = _G
local unpack = unpack

-- Mine
local LAYOUT = {
	[1] = {"TOP", -44, 26},
	[2] = {"TOP", -15, 34},
	[3] = {"TOP", 15, 34},
	[4] = {"TOP", 44, 26},
}

function UF:HandleTotems(parent, level)
	for i = 1, _G.MAX_TOTEMS do
		local totem = _G["TotemFrameTotem"..i]
		local iconFrame, border = totem:GetChildren()
		local background = _G["TotemFrameTotem"..i.."Background"]
		local duration = _G["TotemFrameTotem"..i.."Duration"]
		local icon = _G["TotemFrameTotem"..i.."IconTexture"]
		local cd = _G["TotemFrameTotem"..i.."IconCooldown"]

		E:ForceHide(border)
		E:ForceHide(duration)
		E:ForceHide(background)

		totem:SetParent(parent)
		totem:SetSize(32, 32)
		totem:ClearAllPoints()
		totem:SetPoint(unpack(LAYOUT[i]))

		iconFrame:SetAllPoints()

		border = iconFrame:CreateTexture(nil, "ARTWORK", nil, 1)
		border:SetTexture("Interface\\AddOns\\ls_UI\\media\\minimap-button")
		border:SetTexCoord(1 / 64, 35 / 64, 1 / 64, 35 / 64)
		border:SetAllPoints()

		icon:SetMask("Interface\\Minimap\\UI-Minimap-Background")
		icon:SetPoint("TOPLEFT", 2, -2)
		icon:SetPoint("BOTTOMRIGHT", -2, 2)

		cd:SetSwipeTexture("Interface\\PlayerFrame\\ClassOverlay-RuneCooldown")
		cd:SetReverse(false)
		cd:SetPoint("TOPLEFT", 2, -2)
		cd:SetPoint("BOTTOMRIGHT", -2, 2)

		E:HandleCooldown(cd, 10)

		if cd.Timer then
			cd.Timer:SetPoint("BOTTOM", 0, 2)
		end
	end
end
