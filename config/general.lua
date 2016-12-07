local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local CFG = P:GetModule("Config")
-- local BLIZZARD = P:GetModule("Blizzard")

-- Lua
local _G = _G

-- Mine

function CFG:General_Init()
	local panel = _G.CreateFrame("Frame", "LSUIGeneralConfigPanel", _G.InterfaceOptionsFramePanelContainer)
	panel.name = L["LS_UI"]
	-- panel:HookScript("OnShow", LSGeneralConfigPanel_OnShow)
	panel:Hide()

	local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetJustifyH("LEFT")
	title:SetJustifyV("TOP")
	title:SetText(L["LS_UI"])

	local subtext = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	subtext:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
	subtext:SetPoint("RIGHT", -16, 0)
	subtext:SetHeight(44)
	subtext:SetJustifyH("LEFT")
	subtext:SetJustifyV("TOP")
	subtext:SetNonSpaceWrap(true)
	subtext:SetMaxLines(4)
	subtext:SetText(L["SETTINGS_GENERAL_DESC"])

	local divider = CFG:CreateDivider(panel, L["INFO"])
	divider:SetPoint("TOP", subtext, "BOTTOM", 0, -10)

	CFG:AddPanel(panel)
end
