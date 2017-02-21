local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local CFG = P:GetModule("Config")
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

-- Mine
function CFG:UnitFramesAuras_Init()
	local panel = _G.CreateFrame("Frame", "LSUIUnitFramesAurasConfigPanel", _G.InterfaceOptionsFramePanelContainer)
	panel.name = L["SUBCAT_OFFSET"]:format(L["AURAS"])
	panel.parent = L["UNIT_FRAME"]
	panel:Hide()

	local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetJustifyH("LEFT")
	title:SetJustifyV("TOP")
	title:SetText(L["UNIT_FRAME_AURAS"])

	local subtext = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	subtext:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
	subtext:SetPoint("RIGHT", -16, 0)
	subtext:SetHeight(44)
	subtext:SetJustifyH("LEFT")
	subtext:SetJustifyV("TOP")
	subtext:SetNonSpaceWrap(true)
	subtext:SetMaxLines(4)
	subtext:SetText("NYI")

	local divider = CFG:CreateDivider(panel, L["INFO"])
	divider:SetPoint("TOP", subtext, "BOTTOM", 0, -10)

	subtext = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	subtext:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 6, -10)
	subtext:SetPoint("RIGHT", -16, 0)
	subtext:SetJustifyH("LEFT")
	subtext:SetJustifyV("TOP")
	subtext:SetNonSpaceWrap(true)
	subtext:SetMaxLines(12)
	subtext:SetText("Auras you can see on target and focus frames:\n- |cffe52626hostile|r target:\n  - boss auras\n  - auras defined by Blizzard\n  - permanent auras on NPCs\n  - self-buffs on players\n  - stealable buffs\n  - debuffs applied by |cffffdd20you|r\n- |cff26a526friendly|r target:\n  - boss auras\n  - auras defined by Blizzard\n  - dispelable debuffs")

	CFG:AddPanel(panel)
end
