local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local CFG = P:GetModule("Config")
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = _G
local string = _G.string
local table = _G.table
local pairs = _G.pairs

function CFG:UnitFrames_Init()
	local panel = _G.CreateFrame("Frame", "LSUIAuraTrackerConfigPanel", _G.InterfaceOptionsFramePanelContainer)
	panel.name = L["UNIT_FRAME"]
	panel.parent = L["LS_UI"]
	panel:Hide()

	local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetJustifyH("LEFT")
	title:SetJustifyV("TOP")
	title:SetText(L["UNIT_FRAME"])

	local subtext = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	subtext:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
	subtext:SetPoint("RIGHT", -16, 0)
	subtext:SetHeight(44)
	subtext:SetJustifyH("LEFT")
	subtext:SetJustifyV("TOP")
	subtext:SetNonSpaceWrap(true)
	subtext:SetMaxLines(4)
	subtext:SetText(L["UNIT_FRAME_DESC"])

	local ufToggle = CFG:CreateCheckButton(panel,
		{
			parent = panel,
			name = "$parentUnitFramesToggle",
			text = L["ENABLE"],
			get = function() return C.units.enabled end,
			set = function(_, value)
				C.units.enabled = value
			end,
			refresh = function(self)
				self:SetChecked(C.units.enabled)
			end,
			click = function(self)
				local isChecked = self:GetChecked()

				self:SetValue(isChecked)

				if isChecked then
					if UF:IsInit() then
						panel.Log:SetText(string.format(
							L["LOG_ENABLED_ERR"],
							L["UNIT_FRAME"]))
					else
						local result = UF:Init(true)

						if result then
							UF:UpdateUnitFrames()

							panel.Log:SetText(string.format(
								L["LOG_ENABLED"],
								L["ICON_GREEN_INLINE"],
								L["UNIT_FRAME"],
								""))
						end
					end
				else
					if UF:IsInit() then
						panel.Log:SetText(string.format(
							L["LOG_DISABLED"],
							L["ICON_YELLOW_INLINE"],
							L["UNIT_FRAME"],
							L["REQUIRES_RELOAD"]))
					end
				end
			end
		})
	ufToggle:SetPoint("TOPLEFT", subtext, "BOTTOMLEFT", 0, -8)

	local divider = CFG:CreateDivider(panel, L["UNITS"])
	divider:SetPoint("TOP", ufToggle, "BOTTOM", 0, -10)

	local playerToggle = CFG:CreateCheckButton(panel,
		{
			parent = panel,
			name = "$parentPlayerPetToggle",
			text = L["UNIT_FRAME_PLAYER_PET"],
			get = function() return C.units.player.enabled end,
			set = function(_, value)
				C.units.player.enabled = value
			end,
			refresh = function(self)
				self:SetChecked(C.units.player.enabled)
			end,
			click = function(self)
				local isChecked = self:GetChecked()

				self:SetValue(isChecked)

				if UF:IsInit() then
					if isChecked then
						local result = UF:SpawnFrame("player")

						if result then
							UF:UpdateUnitFrames()

							panel.Log:SetText(string.format(
								L["LOG_ENABLED"],
								L["ICON_GREEN_INLINE"],
								L["UNIT_FRAME_PLAYER_PET"],
								""))
						else
							panel.Log:SetText(string.format(
								L["LOG_ENABLED_ERR"],
								L["UNIT_FRAME_PLAYER_PET"]))
						end
					else
						panel.Log:SetText(string.format(
							L["LOG_DISABLED"],
							L["ICON_YELLOW_INLINE"],
							L["UNIT_FRAME_PLAYER_PET"],
							L["REQUIRES_RELOAD"]))
					end
				end
			end
		})
	playerToggle:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 6, -8)

	local targetToggle = CFG:CreateCheckButton(panel,
		{
			parent = panel,
			name = "$parentTargetToTToggle",
			text = L["UNIT_FRAME_TARGET_TOT"],
			get = function() return C.units.target.enabled end,
			set = function(_, value)
				C.units.target.enabled = value
			end,
			refresh = function(self)
				self:SetChecked(C.units.target.enabled)
			end,
			click = function(self)
				local isChecked = self:GetChecked()

				self:SetValue(isChecked)

				if UF:IsInit() then
					if isChecked then
						local result = UF:SpawnFrame("target")

						if result then
							UF:UpdateUnitFrames()

							panel.Log:SetText(string.format(
								L["LOG_ENABLED"],
								L["ICON_GREEN_INLINE"],
								L["UNIT_FRAME_TARGET_TOT"],
								""))
						else
							panel.Log:SetText(string.format(
								L["LOG_ENABLED_ERR"],
								L["UNIT_FRAME_TARGET_TOT"]))
						end
					else
						panel.Log:SetText(string.format(
							L["LOG_DISABLED"],
							L["ICON_YELLOW_INLINE"],
							L["UNIT_FRAME_TARGET_TOT"],
							L["REQUIRES_RELOAD"]))
					end
				end
			end
		})
	targetToggle:SetPoint("LEFT", playerToggle, "RIGHT", 110, 0)

	local focusToggle = CFG:CreateCheckButton(panel,
		{
			parent = panel,
			name = "$parentFocusToFToggle",
			text = L["UNIT_FRAME_FOCUS_TOF"],
			get = function() return C.units.focus.enabled end,
			set = function(_, value)
				C.units.focus.enabled = value
			end,
			refresh = function(self)
				self:SetChecked(C.units.focus.enabled)
			end,
			click = function(self)
				local isChecked = self:GetChecked()

				self:SetValue(isChecked)

				if UF:IsInit() then
					if isChecked then
						local result = UF:SpawnFrame("focus")

						if result then
							UF:UpdateUnitFrames()

							panel.Log:SetText(string.format(
								L["LOG_ENABLED"],
								L["ICON_GREEN_INLINE"],
								L["UNIT_FRAME_FOCUS_TOF"],
								""))
						else
							panel.Log:SetText(string.format(
								L["LOG_ENABLED_ERR"],
								L["UNIT_FRAME_FOCUS_TOF"]))
						end
					else
						panel.Log:SetText(string.format(
							L["LOG_DISABLED"],
							L["ICON_YELLOW_INLINE"],
							L["UNIT_FRAME_FOCUS_TOF"],
							L["REQUIRES_RELOAD"]))
					end
				end
			end
		})
	focusToggle:SetPoint("LEFT", targetToggle, "RIGHT", 110, 0)

	local bossToggle = CFG:CreateCheckButton(panel,
		{
			parent = panel,
			name = "$parentBossToggle",
			text = L["UNIT_FRAME_BOSS"],
			get = function() return C.units.boss.enabled end,
			set = function(_, value)
				C.units.boss.enabled = value
			end,
			refresh = function(self)
				self:SetChecked(C.units.boss.enabled)
			end,
			click = function(self)
				local isChecked = self:GetChecked()

				self:SetValue(isChecked)

				if UF:IsInit() then
					if isChecked then
						local result = UF:SpawnFrame("boss")

						if result then
							UF:UpdateUnitFrames()

							panel.Log:SetText(string.format(
								L["LOG_ENABLED"],
								L["ICON_GREEN_INLINE"],
								L["UNIT_FRAME_BOSS"],
								""))
						else
							panel.Log:SetText(string.format(
								L["LOG_ENABLED_ERR"],
								L["UNIT_FRAME_BOSS"]))
						end
					else
						panel.Log:SetText(string.format(
							L["LOG_DISABLED"],
							L["ICON_YELLOW_INLINE"],
							L["UNIT_FRAME_BOSS"],
							L["REQUIRES_RELOAD"]))
					end
				end
			end
		})
	bossToggle:SetPoint("LEFT", focusToggle, "RIGHT", 110, 0)

	divider = CFG:CreateDivider(panel, L["UNIT_FRAME_CASTBAR"])
	divider:SetPoint("TOP", playerToggle, "BOTTOM", 0, -10)

	local playerCastBarToggle = CFG:CreateCheckButton(panel,
		{
			parent = panel,
			name = "$parentPlayerPetCastBarToggle",
			text = L["UNIT_FRAME_PLAYER"],
			get = function() return C.units.player.castbar end,
			set = function(_, value)
				C.units.player.castbar = value
			end,
			refresh = function(self)
				self:SetChecked(C.units.player.castbar)
			end,
			click = function(self)
				local isChecked = self:GetChecked()

				self:SetValue(isChecked)

				if UF:IsInit() then
					if isChecked then
						UF:EnableElement("player", "Castbar")
						UF:EnableElement("pet", "Castbar")
					else
						UF:DisableElement("player", "Castbar")
						UF:DisableElement("pet", "Castbar")
						UF:EnableDefaultCastingBars()
					end
				end
			end
		})
	playerCastBarToggle:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 6, -8)

	local targetCastBarToggle = CFG:CreateCheckButton(panel,
		{
			parent = panel,
			name = "$parentPlayerPetCastBarToggle",
			text = L["UNIT_FRAME_TARGET"],
			get = function() return C.units.target.castbar end,
			set = function(_, value)
				C.units.target.castbar = value
			end,
			refresh = function(self)
				self:SetChecked(C.units.target.castbar)
			end,
			click = function(self)
				local isChecked = self:GetChecked()

				self:SetValue(isChecked)

				if UF:IsInit() then
					if isChecked then
						UF:EnableElement("target", "Castbar")
					else
						UF:DisableElement("target", "Castbar")
					end
				end
			end
		})
	targetCastBarToggle:SetPoint("LEFT", playerCastBarToggle, "RIGHT", 110, 0)

	local focusCastBarToggle = CFG:CreateCheckButton(panel,
		{
			parent = panel,
			name = "$parentPlayerPetCastBarToggle",
			text = L["UNIT_FRAME_FOCUS"],
			get = function() return C.units.focus.castbar end,
			set = function(_, value)
				C.units.focus.castbar = value
			end,
			refresh = function(self)
				self:SetChecked(C.units.focus.castbar)
			end,
			click = function(self)
				local isChecked = self:GetChecked()

				self:SetValue(isChecked)

				if UF:IsInit() then
					if isChecked then
						UF:EnableElement("focus", "Castbar")
					else
						UF:DisableElement("focus", "Castbar")
					end
				end
			end
		})
	focusCastBarToggle:SetPoint("LEFT", targetCastBarToggle, "RIGHT", 110, 0)

	local bossCastBarToggle = CFG:CreateCheckButton(panel,
		{
			parent = panel,
			name = "$parentPlayerPetCastBarToggle",
			text = L["UNIT_FRAME_BOSS"],
			get = function() return C.units.boss.castbar end,
			set = function(_, value)
				C.units.boss.castbar = value
			end,
			refresh = function(self)
				self:SetChecked(C.units.boss.castbar)
			end,
			click = function(self)
				local isChecked = self:GetChecked()

				self:SetValue(isChecked)

				if UF:IsInit() then
					if isChecked then
						UF:EnableElement("boss", "Castbar")
					else
						UF:DisableElement("boss", "Castbar")
					end
				end
			end
		})
	bossCastBarToggle:SetPoint("LEFT", focusCastBarToggle, "RIGHT", 110, 0)

	CFG:AddPanel(panel)
end
