local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local CFG = P:GetModule("Config")
local BLIZZARD = P:GetModule("Blizzard")

-- Lua
local _G = getfenv(0)
local string = _G.string

function CFG:Blizzard_Init()
	local panel = _G.CreateFrame("Frame", "LSUIBlizzardConfigPanel", _G.InterfaceOptionsFramePanelContainer)
	panel.name = L["BLIZZARD"]
	panel.parent = L["LS_UI"]
	panel:Hide()

	local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetJustifyH("LEFT")
	title:SetJustifyV("TOP")
	title:SetText(L["BLIZZARD"])

	local subtext = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	subtext:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
	subtext:SetPoint("RIGHT", -16, 0)
	subtext:SetHeight(44)
	subtext:SetJustifyH("LEFT")
	subtext:SetJustifyV("TOP")
	subtext:SetNonSpaceWrap(true)
	subtext:SetMaxLines(4)
	subtext:SetText(L["BLIZZARD_DESC"])

	local blizzToggle = CFG:CreateCheckButton(panel,
		{
			parent = panel,
			name = "$parentTooltipsToggle",
			text = L["ENABLE"],
			get = function() return C.blizzard.enabled end,
			set = function(_, value)
				C.blizzard.enabled = value
			end,
			refresh = function(self)
				self:SetChecked(C.blizzard.enabled)
			end,
			click = function(self)
				local isChecked = self:GetChecked()

				self:SetValue(isChecked)

				if isChecked then
					if BLIZZARD:IsInit() then
						panel.Log:SetText(string.format(
							L["LOG_ENABLED_ERR"],
							L["BLIZZARD"]))
					else
						local result = BLIZZARD:Init()

						if result then
							panel.Log:SetText(string.format(
								L["LOG_ENABLED"],
								L["ICON_GREEN_INLINE"],
								L["BLIZZARD"],
								""))
						end
					end
				else
					if BLIZZARD:IsInit() then
						panel.Log:SetText(string.format(
							L["LOG_DISABLED"],
							L["ICON_YELLOW_INLINE"],
							L["BLIZZARD"],
							L["REQUIRES_RELOAD"]))
					end
				end
			end
		})
	blizzToggle:SetPoint("TOPLEFT", subtext, "BOTTOMLEFT", 0, -8)

	local divider = CFG:CreateDivider(panel, {
		text = L["BLIZZARD_OBJECTIVE_TRACKER"]
	})
	divider:SetPoint("TOP", blizzToggle, "BOTTOM", 0, -10)

	subtext = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	subtext:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 6, -10)
	subtext:SetPoint("RIGHT", -16, 0)
	subtext:SetHeight(44)
	subtext:SetJustifyH("LEFT")
	subtext:SetJustifyV("TOP")
	subtext:SetNonSpaceWrap(true)
	subtext:SetMaxLines(4)
	subtext:SetText(L["BLIZZARD_OBJECTIVE_TRACKER_DESC"])

	local otToggle = CFG:CreateCheckButton(panel,
		{
			parent = panel,
			name = "$parentTooltipsToggle",
			text = L["ENABLE"],
			get = function() return C.blizzard.objective_tracker.enabled end,
			set = function(_, value)
				C.blizzard.objective_tracker.enabled = value
			end,
			refresh = function(self)
				self:SetChecked(C.blizzard.objective_tracker.enabled)
			end,
			click = function(self)
				local isChecked = self:GetChecked()

				self:SetValue(isChecked)

				if BLIZZARD:IsInit() then
					if isChecked then
						if BLIZZARD:ObjectiveTracker_IsInit() then
							panel.Log:SetText(string.format(
								L["LOG_ENABLED_ERR"],
								L["BLIZZARD_OBJECTIVE_TRACKER"]))
						else
							local result = BLIZZARD:ObjectiveTracker_Init()

							if result then
								panel.Log:SetText(string.format(
									L["LOG_ENABLED"],
									L["ICON_GREEN_INLINE"],
									L["BLIZZARD_OBJECTIVE_TRACKER"],
									""))
							end
						end
					else
						if BLIZZARD:ObjectiveTracker_IsInit() then
							panel.Log:SetText(string.format(
								L["LOG_DISABLED"],
								L["ICON_YELLOW_INLINE"],
								L["BLIZZARD_OBJECTIVE_TRACKER"],
								L["REQUIRES_RELOAD"]))
						end
					end
				end
			end
		})
	otToggle:SetPoint("TOPLEFT", subtext, "BOTTOMLEFT", 0, -8)

	local otHeightSlider = CFG:CreateSlider(panel,
		{
			parent = panel,
			name = "$parentTrackerHeightSlider",
			min = 400,
			max = 1000,
			step = 50,
			text = L["FRAME_HEIGHT"],
			get = function(self) return C.blizzard.objective_tracker.height end,
			set = function(self, value)
				C.blizzard.objective_tracker.height = value

				if BLIZZARD:ObjectiveTracker_IsInit() then
					BLIZZARD:ObjectiveTracker_SetHeight(value)
				end
			end,
		})
	otHeightSlider:SetPoint("TOPLEFT", otToggle, "BOTTOMLEFT", 8, -22)

	divider = CFG:CreateDivider(panel, {
		text = L["MISC"]
	})
	divider:SetPoint("TOP", otHeightSlider, "BOTTOM", 0, -22)

	subtext = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	subtext:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 6, -10)
	subtext:SetPoint("RIGHT", -16, 0)
	subtext:SetHeight(44)
	subtext:SetJustifyH("LEFT")
	subtext:SetJustifyV("TOP")
	subtext:SetNonSpaceWrap(true)
	subtext:SetMaxLines(4)
	subtext:SetText(L["BLIZZARD_MISC_DESC"])

	local cbToggle = CFG:CreateCheckButton(panel,
		{
			parent = panel,
			name = "$parentCommandBarToggle",
			text = L["BLIZZARD_COMMAND_BAR"],
			get = function() return C.blizzard.command_bar.enabled end,
			set = function(_, value)
				C.blizzard.command_bar.enabled = value
			end,
			refresh = function(self)
				self:SetChecked(C.blizzard.command_bar.enabled)
			end,
			click = function(self)
				local isChecked = self:GetChecked()

				self:SetValue(isChecked)

				if BLIZZARD:IsInit() then
					if isChecked then
						local result = BLIZZARD:CommandBar_Init()

						if result then
							panel.Log:SetText(string.format(
								L["LOG_ENABLED"],
								L["ICON_GREEN_INLINE"],
								L["BLIZZARD_COMMAND_BAR"],
								""))
						else
							panel.Log:SetText(string.format(
								L["LOG_ENABLED_ERR"],
								L["BLIZZARD_COMMAND_BAR"]))
						end
					else
						panel.Log:SetText(string.format(
							L["LOG_DISABLED"],
							L["ICON_YELLOW_INLINE"],
							L["BLIZZARD_COMMAND_BAR"],
							L["REQUIRES_RELOAD"]))
					end
				end
			end
		})
	cbToggle:SetPoint("TOPLEFT", subtext, "BOTTOMLEFT", 0, -8)

	local dsbToggle = CFG:CreateCheckButton(panel,
		{
			parent = panel,
			name = "$parentDigsiteBarToggle",
			text = L["BLIZZARD_DIGSITE_BAR"],
			get = function() return C.blizzard.digsite_bar.enabled end,
			set = function(_, value)
				C.blizzard.digsite_bar.enabled = value
			end,
			refresh = function(self)
				self:SetChecked(C.blizzard.digsite_bar.enabled)
			end,
			click = function(self)
				local isChecked = self:GetChecked()

				self:SetValue(isChecked)

				if BLIZZARD:IsInit() then
					if isChecked then
						local result = BLIZZARD:DigsiteBar_Init()

						if result then
							panel.Log:SetText(string.format(
								L["LOG_ENABLED"],
								L["ICON_GREEN_INLINE"],
								L["BLIZZARD_DIGSITE_BAR"],
								""))
						else
							panel.Log:SetText(string.format(
								L["LOG_ENABLED_ERR"],
								L["BLIZZARD_DIGSITE_BAR"]))
						end
					else
						panel.Log:SetText(string.format(
							L["LOG_DISABLED"],
							L["ICON_YELLOW_INLINE"],
							L["BLIZZARD_DIGSITE_BAR"],
							L["REQUIRES_RELOAD"]))
					end
				end
			end
		})
	dsbToggle:SetPoint("TOPLEFT", cbToggle, "BOTTOMLEFT", 0, -8)

	local durabilityToggle = CFG:CreateCheckButton(panel,
		{
			parent = panel,
			name = "$parentDurabilityToggle",
			text = L["BLIZZARD_DURABILITY_FRAME"],
			get = function() return C.blizzard.durability.enabled end,
			set = function(_, value)
				C.blizzard.durability.enabled = value
			end,
			refresh = function(self)
				self:SetChecked(C.blizzard.durability.enabled)
			end,
			click = function(self)
				local isChecked = self:GetChecked()

				self:SetValue(isChecked)

				if BLIZZARD:IsInit() then
					if isChecked then
						local result = BLIZZARD:Durability_Init()

						if result then
							panel.Log:SetText(string.format(
								L["LOG_ENABLED"],
								L["ICON_GREEN_INLINE"],
								L["BLIZZARD_DURABILITY_FRAME"],
								""))
						else
							panel.Log:SetText(string.format(
								L["LOG_ENABLED_ERR"],
								L["BLIZZARD_DURABILITY_FRAME"]))
						end
					else
						panel.Log:SetText(string.format(
							L["LOG_DISABLED"],
							L["ICON_YELLOW_INLINE"],
							L["BLIZZARD_DURABILITY_FRAME"],
							L["REQUIRES_RELOAD"]))
					end
				end
			end
		})
	durabilityToggle:SetPoint("TOPLEFT", dsbToggle, "BOTTOMLEFT", 0, -8)

	local gmToggle = CFG:CreateCheckButton(panel,
		{
			parent = panel,
			name = "$parentGMToggle",
			text = L["BLIZZARD_GM_FRAME"],
			get = function() return C.blizzard.gm.enabled end,
			set = function(_, value)
				C.blizzard.gm.enabled = value
			end,
			refresh = function(self)
				self:SetChecked(C.blizzard.gm.enabled)
			end,
			click = function(self)
				local isChecked = self:GetChecked()

				self:SetValue(isChecked)

				if BLIZZARD:IsInit() then
					if isChecked then
						local result = BLIZZARD:GM_Init()

						if result then
							panel.Log:SetText(string.format(
								L["LOG_ENABLED"],
								L["ICON_GREEN_INLINE"],
								L["BLIZZARD_GM_FRAME"],
								""))
						else
							panel.Log:SetText(string.format(
								L["LOG_ENABLED_ERR"],
								L["BLIZZARD_GM_FRAME"]))
						end
					else
						panel.Log:SetText(string.format(
							L["LOG_DISABLED"],
							L["ICON_YELLOW_INLINE"],
							L["BLIZZARD_GM_FRAME"],
							L["REQUIRES_RELOAD"]))
					end
				end
			end
		})
	gmToggle:SetPoint("TOPLEFT", durabilityToggle, "BOTTOMLEFT", 0, -8)

	local npeToggle = CFG:CreateCheckButton(panel,
		{
			parent = panel,
			name = "$parentNPEToggle",
			text = L["BLIZZARD_NPE_FRAME"],
			get = function() return C.blizzard.npe.enabled end,
			set = function(_, value)
				C.blizzard.npe.enabled = value
			end,
			refresh = function(self)
				self:SetChecked(C.blizzard.npe.enabled)
			end,
			click = function(self)
				local isChecked = self:GetChecked()

				self:SetValue(isChecked)

				if BLIZZARD:IsInit() then
					if isChecked then
						local result = BLIZZARD:NPE_Init()

						if result then
							panel.Log:SetText(string.format(
								L["LOG_ENABLED"],
								L["ICON_GREEN_INLINE"],
								L["BLIZZARD_NPE_FRAME"],
								""))
						else
							panel.Log:SetText(string.format(
								L["LOG_ENABLED_ERR"],
								L["BLIZZARD_NPE_FRAME"]))
						end
					else
						panel.Log:SetText(string.format(
							L["LOG_DISABLED"],
							L["ICON_YELLOW_INLINE"],
							L["BLIZZARD_NPE_FRAME"],
							L["REQUIRES_RELOAD"]))
					end
				end
			end
		})
	npeToggle:SetPoint("TOPLEFT", gmToggle, "BOTTOMLEFT", 0, -8)

	local apbToggle = CFG:CreateCheckButton(panel,
		{
			parent = panel,
			name = "$parentPlayerAltPowerToggle",
			text = L["BLIZZARD_PLAYER_ALT_POWER_BAR"],
			get = function() return C.blizzard.player_alt_power_bar.enabled end,
			set = function(_, value)
				C.blizzard.player_alt_power_bar.enabled = value
			end,
			refresh = function(self)
				self:SetChecked(C.blizzard.player_alt_power_bar.enabled)
			end,
			click = function(self)
				local isChecked = self:GetChecked()

				self:SetValue(isChecked)

				if BLIZZARD:IsInit() then
					if isChecked then
						local result = BLIZZARD:PlayerAltPowerBar_Init()

						if result then
							panel.Log:SetText(string.format(
								L["LOG_ENABLED"],
								L["ICON_GREEN_INLINE"],
								L["BLIZZARD_PLAYER_ALT_POWER_BAR"],
								""))
						else
							panel.Log:SetText(string.format(
								L["LOG_ENABLED_ERR"],
								L["BLIZZARD_PLAYER_ALT_POWER_BAR"]))
						end
					else
						panel.Log:SetText(string.format(
							L["LOG_DISABLED"],
							L["ICON_YELLOW_INLINE"],
							L["BLIZZARD_PLAYER_ALT_POWER_BAR"],
							L["REQUIRES_RELOAD"]))
					end
				end
			end
		})
	apbToggle:SetPoint("TOP", subtext, "BOTTOM", 0, -8)
	apbToggle:SetPoint("LEFT", panel, "CENTER", 16, 0)

	local thToggle = CFG:CreateCheckButton(panel,
		{
			parent = panel,
			name = "$parentTalkingHeadToggle",
			text = L["BLIZZARD_TALKING_HEAD_FRAME"],
			get = function() return C.blizzard.talking_head.enabled end,
			set = function(_, value)
				C.blizzard.talking_head.enabled = value
			end,
			refresh = function(self)
				self:SetChecked(C.blizzard.talking_head.enabled)
			end,
			click = function(self)
				local isChecked = self:GetChecked()

				self:SetValue(isChecked)

				if BLIZZARD:IsInit() then
					if isChecked then
						local result = BLIZZARD:TalkingHead_Init()

						if result then
							panel.Log:SetText(string.format(
								L["LOG_ENABLED"],
								L["ICON_GREEN_INLINE"],
								L["BLIZZARD_TALKING_HEAD_FRAME"],
								""))
						else
							panel.Log:SetText(string.format(
								L["LOG_ENABLED_ERR"],
								L["BLIZZARD_TALKING_HEAD_FRAME"]))
						end
					else
						panel.Log:SetText(string.format(
							L["LOG_DISABLED"],
							L["ICON_YELLOW_INLINE"],
							L["BLIZZARD_TALKING_HEAD_FRAME"],
							L["REQUIRES_RELOAD"]))
					end
				end
			end
		})
	thToggle:SetPoint("TOPLEFT", apbToggle, "BOTTOMLEFT", 0, -8)

	local mtToggle = CFG:CreateCheckButton(panel,
		{
			parent = panel,
			name = "$parentMirrorTimerToggle",
			text = L["BLIZZARD_MIRROR_TIMER"],
			get = function() return C.blizzard.timer.enabled end,
			set = function(_, value)
				C.blizzard.timer.enabled = value
			end,
			refresh = function(self)
				self:SetChecked(C.blizzard.timer.enabled)
			end,
			click = function(self)
				local isChecked = self:GetChecked()

				self:SetValue(isChecked)

				if BLIZZARD:IsInit() then
					if isChecked then
						local result = BLIZZARD:Timer_Init()

						if result then
							panel.Log:SetText(string.format(
								L["LOG_ENABLED"],
								L["ICON_GREEN_INLINE"],
								L["BLIZZARD_MIRROR_TIMER"],
								""))
						else
							panel.Log:SetText(string.format(
								L["LOG_ENABLED_ERR"],
								L["BLIZZARD_MIRROR_TIMER"]))
						end
					else
						panel.Log:SetText(string.format(
							L["LOG_DISABLED"],
							L["ICON_YELLOW_INLINE"],
							L["BLIZZARD_MIRROR_TIMER"],
							L["REQUIRES_RELOAD"]))
					end
				end
			end
		})
	mtToggle:SetPoint("TOPLEFT", thToggle, "BOTTOMLEFT", 0, -8)

	local vsiToggle = CFG:CreateCheckButton(panel,
		{
			parent = panel,
			name = "$parentVehicleSeatToggle",
			text = L["BLIZZARD_VEHICLE_SEAT_INDICATOR"],
			get = function() return C.blizzard.vehicle.enabled end,
			set = function(_, value)
				C.blizzard.vehicle.enabled = value
			end,
			refresh = function(self)
				self:SetChecked(C.blizzard.vehicle.enabled)
			end,
			click = function(self)
				local isChecked = self:GetChecked()

				self:SetValue(isChecked)

				if BLIZZARD:IsInit() then
					if isChecked then
						local result = BLIZZARD:Vehicle_Init()

						if result then
							panel.Log:SetText(string.format(
								L["LOG_ENABLED"],
								L["ICON_GREEN_INLINE"],
								L["BLIZZARD_VEHICLE_SEAT_INDICATOR"],
								""))
						else
							panel.Log:SetText(string.format(
								L["LOG_ENABLED_ERR"],
								L["BLIZZARD_VEHICLE_SEAT_INDICATOR"]))
						end
					else
						panel.Log:SetText(string.format(
							L["LOG_DISABLED"],
							L["ICON_YELLOW_INLINE"],
							L["BLIZZARD_VEHICLE_SEAT_INDICATOR"],
							L["REQUIRES_RELOAD"]))
					end
				end
			end
		})
	vsiToggle:SetPoint("TOPLEFT", mtToggle, "BOTTOMLEFT", 0, -8)

	CFG:AddPanel(panel)
end
