local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local CFG = P:GetModule("Config")
local AURAS = P:GetModule("Auras")
local MAIL = P:GetModule("Mail")
local MINIMAP = P:GetModule("MiniMap")

-- Lua
local _G = getfenv(0)
local string = _G.string

-- Mine
function CFG:General_Init()
	local panel = _G.LSUIGeneralConfigPanel

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
	subtext:SetText(L["LS_UI_DESC"])

	local divider = CFG:CreateDivider(panel, {
		text = L["MISC"]
	})
	divider:SetPoint("TOP", subtext, "BOTTOM", 0, -10)

	subtext = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	subtext:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 6, -10)
	subtext:SetPoint("RIGHT", -16, 0)
	subtext:SetHeight(44)
	subtext:SetJustifyH("LEFT")
	subtext:SetJustifyV("TOP")
	subtext:SetNonSpaceWrap(true)
	subtext:SetMaxLines(4)
	subtext:SetText("These settings don't have their own pages yet :'<")

	local aurasToggle = CFG:CreateCheckButton(panel,
		{
			parent = panel,
			name = "$parentAurasToggle",
			text = L["AURAS"],
			get = function() return C.auras.enabled end,
			set = function(_, value)
				C.auras.enabled = value
			end,
			refresh = function(self)
				self:SetChecked(C.auras.enabled)
			end,
			click = function(self)
				local isChecked = self:GetChecked()

				self:SetValue(isChecked)

				if isChecked then
					if AURAS:IsInit() then
						panel.Log:SetText(string.format(
							L["LOG_ENABLED_ERR"],
							L["AURAS"]))
					else
						local result = AURAS:Init()

						if result then
							panel.Log:SetText(string.format(
								L["LOG_ENABLED"],
								L["ICON_GREEN_INLINE"],
								L["AURAS"],
								""))
						end
					end
				else
					if AURAS:IsInit() then
						panel.Log:SetText(string.format(
							L["LOG_DISABLED"],
							L["ICON_YELLOW_INLINE"],
							L["AURAS"],
							L["REQUIRES_RELOAD"]))
					end
				end
			end
		})
	aurasToggle:SetPoint("TOPLEFT", subtext, "BOTTOMLEFT", 0, -8)

	local minimapToggle = CFG:CreateCheckButton(panel,
		{
			parent = panel,
			name = "$parentMailToggle",
			text = L["MINIMAP"],
			get = function() return C.minimap.enabled end,
			set = function(_, value)
				C.minimap.enabled = value
			end,
			refresh = function(self)
				self:SetChecked(C.minimap.enabled)
			end,
			click = function(self)
				local isChecked = self:GetChecked()

				self:SetValue(isChecked)

				if isChecked then
					if MINIMAP:IsInit() then
						panel.Log:SetText(string.format(
							L["LOG_ENABLED_ERR"],
							L["MINIMAP"]))
					else
						local result = MINIMAP:Init()

						if result then
							panel.Log:SetText(string.format(
								L["LOG_ENABLED"],
								L["ICON_GREEN_INLINE"],
								L["MINIMAP"],
								""))
						end
					end
				else
					if MINIMAP:IsInit() then
						panel.Log:SetText(string.format(
							L["LOG_DISABLED"],
							L["ICON_YELLOW_INLINE"],
							L["MINIMAP"],
							L["REQUIRES_RELOAD"]))
					end
				end
			end
		})
	minimapToggle:SetPoint("LEFT", aurasToggle, "RIGHT", 110, 0)

	local mailToggle = CFG:CreateCheckButton(panel,
		{
			parent = panel,
			name = "$parentMailToggle",
			text = L["MAIL"],
			get = function() return C.mail.enabled end,
			set = function(_, value)
				C.mail.enabled = value
			end,
			refresh = function(self)
				self:SetChecked(C.mail.enabled)
			end,
			click = function(self)
				local isChecked = self:GetChecked()

				self:SetValue(isChecked)

				if isChecked then
					if MAIL:IsInit() then
						panel.Log:SetText(string.format(
							L["LOG_ENABLED_ERR"],
							L["MAIL"]))
					else
						local result = MAIL:Init()

						if result then
							panel.Log:SetText(string.format(
								L["LOG_ENABLED"],
								L["ICON_GREEN_INLINE"],
								L["MAIL"],
								""))
						end
					end
				else
					if MAIL:IsInit() then
						panel.Log:SetText(string.format(
							L["LOG_DISABLED"],
							L["ICON_YELLOW_INLINE"],
							L["MAIL"],
							L["REQUIRES_RELOAD"]))
					end
				end
			end
		})
	mailToggle:SetPoint("LEFT", minimapToggle, "RIGHT", 110, 0)
end
