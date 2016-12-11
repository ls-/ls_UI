local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local CFG = P:GetModule("Config")
local TOOLTIPS = P:GetModule("Tooltips")

-- Lua
local _G = _G
local string = _G.string

function CFG:Tooltips_Init()
	local panel = _G.CreateFrame("Frame", "LSUIAuraTrackerConfigPanel", _G.InterfaceOptionsFramePanelContainer)
	panel.name = L["TOOLTIP"]
	panel.parent = L["LS_UI"]
	panel:Hide()

	local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetJustifyH("LEFT")
	title:SetJustifyV("TOP")
	title:SetText(L["TOOLTIP"])

	local subtext = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	subtext:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
	subtext:SetPoint("RIGHT", -16, 0)
	subtext:SetHeight(44)
	subtext:SetJustifyH("LEFT")
	subtext:SetJustifyV("TOP")
	subtext:SetNonSpaceWrap(true)
	subtext:SetMaxLines(4)
	subtext:SetText(L["TOOLTIP_DESC"])

	local ttToggle = CFG:CreateCheckButton(panel,
		{
			parent = panel,
			name = "$parentTooltipsToggle",
			text = L["ENABLE"],
			get = function() return C.tooltips.enabled end,
			set = function(_, value)
				C.tooltips.enabled = value
			end,
			refresh = function(self)
				self:SetChecked(C.tooltips.enabled)
			end,
			click = function(self)
				local isChecked = self:GetChecked()

				self:SetValue(isChecked)

				if isChecked then
					if TOOLTIPS:IsInit() then
						panel.Log:SetText(string.format(
							L["LOG_ENABLED_ERR"],
							L["TOOLTIP"]))
					else
						local result = TOOLTIPS:Init()

						if result then
							panel.Log:SetText(string.format(
								L["LOG_ENABLED"],
								L["ICON_GREEN_INLINE"],
								L["TOOLTIP"],
								""))
						end
					end
				else
					if TOOLTIPS:IsInit() then
						panel.Log:SetText(string.format(
							L["LOG_DISABLED"],
							L["ICON_YELLOW_INLINE"],
							L["TOOLTIP"],
							L["REQUIRES_RELOAD"]))
					end
				end
			end
		})
	ttToggle:SetPoint("TOPLEFT", subtext, "BOTTOMLEFT", 0, -8)

	local divider = CFG:CreateDivider(panel, L["TOOLTIP_UNIT_NAME_COLOR"])
	divider:SetPoint("TOP", ttToggle, "BOTTOM", 0, -10)

	subtext = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	subtext:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 6, -10)
	subtext:SetPoint("RIGHT", -16, 0)
	subtext:SetHeight(44)
	subtext:SetJustifyH("LEFT")
	subtext:SetJustifyV("TOP")
	subtext:SetNonSpaceWrap(true)
	subtext:SetMaxLines(4)
	subtext:SetText(L["TOOLTIP_UNIT_NAME_COLOR_DESC"])

	local pvpToggle = CFG:CreateCheckButton(panel,
		{
			parent = panel,
			name = "$parentPvPToggleToggle",
			text = L["TOOLTIP_UNIT_NAME_COLOR_PVP"],
			tooltip_text = L["TOOLTIP_UNIT_NAME_COLOR_PVP_TOOLTIP"],
			get = function() return C.tooltips.unit.name_color_pvp_hostility end,
			set = function(_, value)
				C.tooltips.unit.name_color_pvp_hostility = value
			end,
			refresh = function(self)
				self:SetChecked(C.tooltips.unit.name_color_pvp_hostility)
			end,
			click = function(self)
				self:SetValue(self:GetChecked())
			end
		})
	pvpToggle:SetPoint("TOPLEFT", subtext, "BOTTOMLEFT", 0, -8)

	local classToggle = CFG:CreateCheckButton(panel,
		{
			parent = panel,
			name = "$parentPvPToggleToggle",
			text = L["TOOLTIP_UNIT_NAME_COLOR_CLASS"],
			tooltip_text = L["TOOLTIP_UNIT_NAME_COLOR_CLASS_TOOLTIP"],
			get = function() return C.tooltips.unit.name_color_class end,
			set = function(_, value)
				C.tooltips.unit.name_color_class = value
			end,
			refresh = function(self)
				self:SetChecked(C.tooltips.unit.name_color_class)
			end,
			click = function(self)
				self:SetValue(self:GetChecked())
			end
		})
	classToggle:SetPoint("TOPLEFT", pvpToggle, "BOTTOMLEFT", 0, -8)

	local tapToggle = CFG:CreateCheckButton(panel,
		{
			parent = panel,
			name = "$parentPvPToggleToggle",
			text = L["TOOLTIP_UNIT_NAME_COLOR_TAP"],
			tooltip_text = L["TOOLTIP_UNIT_NAME_COLOR_TAP_TOOLTIP"],
			get = function() return C.tooltips.unit.name_color_tapping end,
			set = function(_, value)
				C.tooltips.unit.name_color_tapping = value
			end,
			refresh = function(self)
				self:SetChecked(C.tooltips.unit.name_color_tapping)
			end,
			click = function(self)
				self:SetValue(self:GetChecked())
			end
		})
	tapToggle:SetPoint("TOPLEFT", classToggle, "BOTTOMLEFT", 0, -8)

	local reactionToggle = CFG:CreateCheckButton(panel,
		{
			parent = panel,
			name = "$parentPvPToggleToggle",
			text = L["TOOLTIP_UNIT_NAME_COLOR_REACTION"],
			tooltip_text = L["TOOLTIP_UNIT_NAME_COLOR_REACTION_TOOLTIP"],
			get = function() return C.tooltips.unit.name_color_reaction end,
			set = function(_, value)
				C.tooltips.unit.name_color_reaction = value
			end,
			refresh = function(self)
				self:SetChecked(C.tooltips.unit.name_color_reaction)
			end,
			click = function(self)
				self:SetValue(self:GetChecked())
			end
		})
	reactionToggle:SetPoint("TOPLEFT", tapToggle, "BOTTOMLEFT", 0, -8)

	divider = CFG:CreateDivider(panel, L["MISC"])
	divider:SetPoint("TOP", reactionToggle, "BOTTOM", 0, -10)

	local idToggle = CFG:CreateCheckButton(panel,
		{
			parent = panel,
			name = "$parentIDToggle",
			text = L["TOOLTIP_SHOW_ID"],
			get = function() return C.tooltips.show_id end,
			set = function(_, value)
				C.tooltips.show_id = value
			end,
			refresh = function(self)
				self:SetChecked(C.tooltips.show_id)
			end,
			click = function(self)
				self:SetValue(self:GetChecked())
			end
		})
	idToggle:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 6, -8)

	CFG:AddPanel(panel)
end
