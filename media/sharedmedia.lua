local _, ns = ...
local M = ns.M

M.hiddenParent = CreateFrame("Frame")
M.hiddenParent:Hide()

M["font"] = STANDARD_TEXT_FONT

M["textures"] = {
	button = {
		normal = "Interface\\AddOns\\oUF_LS\\media\\button\\normal",
		normalmetal = "Interface\\AddOns\\oUF_LS\\media\\button\\normal_bronze",
		highlight = "Interface\\AddOns\\oUF_LS\\media\\button\\highlight",
		pushed = "Interface\\AddOns\\oUF_LS\\media\\button\\pushed",
		checked = "Interface\\AddOns\\oUF_LS\\media\\button\\checked",
		flash = "Interface\\AddOns\\oUF_LS\\media\\button\\flash",
	},
}
