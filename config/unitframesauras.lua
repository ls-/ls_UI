local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local CFG = P:GetModule("Config")
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)
local bit = _G.bit

-- Mine
local FRIENDLY_TARGET_BUFFS = "Buffs"
local FRIENDLY_TARGET_DEBUFFS = "Debuffs"
local HOSTILE_TARGET_BUFFS = "Buffs"
local HOSTILE_TARGET_DEBUFFS = "Debuffs"

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

	local tabbedFrame = CFG:CreateTabbedFrame(panel,
		{
			parent = panel,
			name = "$parentFilterOptionsFrame",
			get = function(self)
				return self.key
			end,
			set = function(self, i)
				if i == 1 then
					self.key = "target"
				elseif i == 2 then
					self.key = "focus"
				end
			end,
			refresh = function(self)
				self.AurasToggle.key = self.key
				self.AurasToggle:RefreshValue()

				self.BossAuraFriendlyBuffDial.key = self.key
				self.BossAuraFriendlyBuffDial:RefreshValue()

				self.BossAuraHostileBuffDial.key = self.key
				self.BossAuraHostileBuffDial:RefreshValue()

				self.BossAuraFriendlyDebuffDial.key = self.key
				self.BossAuraFriendlyDebuffDial:RefreshValue()

				self.BossAuraHostileDebuffDial.key = self.key
				self.BossAuraHostileDebuffDial:RefreshValue()

				self.MountFriendlyBuffDial.key = self.key
				self.MountFriendlyBuffDial:RefreshValue()

				self.MountHostileBuffDial.key = self.key
				self.MountHostileBuffDial:RefreshValue()

				self.SelfCastFriendlyBuffDial.key = self.key
				self.SelfCastFriendlyBuffDial:RefreshValue()

				self.SelfCastHostileBuffDial.key = self.key
				self.SelfCastHostileBuffDial:RefreshValue()

				self.SelfCastFriendlyDebuffDial.key = self.key
				self.SelfCastFriendlyDebuffDial:RefreshValue()

				self.SelfCastHostileDebuffDial.key = self.key
				self.SelfCastHostileDebuffDial:RefreshValue()

				self.PersonalFriendlyBuffDial.key = self.key
				self.PersonalFriendlyBuffDial:RefreshValue()

				self.PersonalHostileBuffDial.key = self.key
				self.PersonalHostileBuffDial:RefreshValue()

				self.PersonalFriendlyDebuffDial.key = self.key
				self.PersonalFriendlyDebuffDial:RefreshValue()

				self.PersonalHostileDebuffDial.key = self.key
				self.PersonalHostileDebuffDial:RefreshValue()

				self.DispellableFriendlyDebuffDial.key = self.key
				self.DispellableFriendlyDebuffDial:RefreshValue()

				self.DispellableHostileBuffDial.key = self.key
				self.DispellableHostileBuffDial:RefreshValue()
			end,
			tabs = {
				[1] = {
					text = "target",
					tooltip_text = "yeah boi",
				},
				[2] = {
					text = "focus",
					tooltip_text = "nah boi",
				},

			},
		})
	tabbedFrame:SetPoint("TOPLEFT", subtext, "BOTTOMLEFT", 6, -40)
	tabbedFrame:SetPoint("RIGHT", panel, "RIGHT", -16, 0)
	tabbedFrame:SetHeight(352)
	tabbedFrame.key = "target"
	_G.PanelTemplates_SetTab(tabbedFrame, 1)
	panel.TabbedFrame = tabbedFrame

	local aurasToggle = CFG:CreateCheckButton(panel,
		{
			parent = tabbedFrame,
			name = "$parentAuraToggle",
			text = L["ENABLE"],
			get = function(self)
				return C.units[self.key].auras.enabled
			end,
			set = function(self, value)
				C.units[self.key].auras.enabled = value
			end,
			refresh = function(self)
				self:SetChecked(C.units[self.key].auras.enabled)
			end,
			click = function(self)
				local isChecked = self:GetChecked()

				self:SetValue(isChecked)

				if UF:IsInit() then
					if isChecked then
						UF:EnableElement(self.key, "Aura")
					else
						UF:DisableElement(self.key, "Aura")
					end
				end
			end
		})
	aurasToggle:SetPoint("TOPLEFT", tabbedFrame, "TOPLEFT", 16, -16)
	tabbedFrame.AurasToggle = aurasToggle

	local unitHeader = CFG:CreateDivider(tabbedFrame, "Friendly Targets")
	unitHeader:SetPoint("TOP", aurasToggle, "BOTTOM", 0, -12)
	unitHeader:SetPoint("RIGHT", tabbedFrame, "CENTER", -8, 0)

	unitHeader = CFG:CreateDivider(tabbedFrame, "Hostile Targets")
	unitHeader:SetPoint("TOP", aurasToggle, "BOTTOM", 0, -12)
	unitHeader:SetPoint("LEFT", tabbedFrame, "CENTER", 8, 0)

	local divider = CFG:CreateDivider(tabbedFrame, "Boss Auras")
	divider:SetPoint("TOP", unitHeader, "BOTTOM", 0, -12)

	local bossAuraFriendlyBuffDial = CFG:CreateMaskDial(panel, {
		parent = tabbedFrame,
		name = "$parentBossAuraFriendlyBuffDial",
		text = FRIENDLY_TARGET_BUFFS,
		get = function(self)
			return C.units[self.key].auras.show_boss
		end,
		set = function(self, value)
			C.units[self.key].auras.show_boss = value
		end,
		calc = function(self)
			local value = C.units[self.key].auras.show_boss

			for i = 1, #self do
				if self[i]:IsPositive() then
					value = E:EnableFlag(value, self[i].value)
				else
					value = E:DisableFlag(value, self[i].value)
				end
			end

			return value
		end,
		flags = {
			[0] = E.PLAYER_SPEC_FLAGS[0],
			[1] = E.PLAYER_SPEC_FLAGS[1],
			[2] = E.PLAYER_SPEC_FLAGS[2],
			[3] = E.PLAYER_SPEC_FLAGS[3],
			[4] = E.PLAYER_SPEC_FLAGS[4],
		}
	})
	bossAuraFriendlyBuffDial:SetWidth(266)
	bossAuraFriendlyBuffDial:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 10, -12) -- + 4
	tabbedFrame.BossAuraFriendlyBuffDial = bossAuraFriendlyBuffDial

	local bossAuraHostileBuffDial = CFG:CreateMaskDial(panel, {
		parent = tabbedFrame,
		name = "$parentBossAuraHostileBuffDial",
		text = HOSTILE_TARGET_BUFFS,
		get = function(self)
			return C.units[self.key].auras.show_boss
		end,
		set = function(self, value)
			C.units[self.key].auras.show_boss = value
		end,
		calc = function(self)
			local value = C.units[self.key].auras.show_boss

			for i = 1, #self do
				if self[i]:IsPositive() then
					value = E:EnableFlag(value, self[i].value)
				else
					value = E:DisableFlag(value, self[i].value)
				end
			end

			return value
		end,
		flags = {
			[0] = bit.lshift(E.PLAYER_SPEC_FLAGS[0], 4),
			[1] = bit.lshift(E.PLAYER_SPEC_FLAGS[1], 4),
			[2] = bit.lshift(E.PLAYER_SPEC_FLAGS[2], 4),
			[3] = bit.lshift(E.PLAYER_SPEC_FLAGS[3], 4),
			[4] = bit.lshift(E.PLAYER_SPEC_FLAGS[4], 4),
		}
	})
	bossAuraHostileBuffDial:SetWidth(266)
	bossAuraHostileBuffDial:SetPoint("TOPLEFT", bossAuraFriendlyBuffDial, "TOPRIGHT", 16, 0) -- + 4
	tabbedFrame.BossAuraHostileBuffDial = bossAuraHostileBuffDial

	local bossAuraFriendlyDebuffDial = CFG:CreateMaskDial(panel, {
		parent = tabbedFrame,
		name = "$parentBossAuraFriendlyDebuffDial",
		text = FRIENDLY_TARGET_DEBUFFS,
		get = function(self)
			return C.units[self.key].auras.show_boss
		end,
		set = function(self, value)
			C.units[self.key].auras.show_boss = value
		end,
		calc = function(self)
			local value = C.units[self.key].auras.show_boss

			for i = 1, #self do
				if self[i]:IsPositive() then
					value = E:EnableFlag(value, self[i].value)
				else
					value = E:DisableFlag(value, self[i].value)
				end
			end

			return value
		end,
		flags = {
			[0] = bit.lshift(E.PLAYER_SPEC_FLAGS[0], 8),
			[1] = bit.lshift(E.PLAYER_SPEC_FLAGS[1], 8),
			[2] = bit.lshift(E.PLAYER_SPEC_FLAGS[2], 8),
			[3] = bit.lshift(E.PLAYER_SPEC_FLAGS[3], 8),
			[4] = bit.lshift(E.PLAYER_SPEC_FLAGS[4], 8),
		}
	})
	bossAuraFriendlyDebuffDial:SetWidth(266)
	bossAuraFriendlyDebuffDial:SetPoint("TOPLEFT", bossAuraFriendlyBuffDial, "BOTTOMLEFT", 0, -8) -- + 4
	tabbedFrame.BossAuraFriendlyDebuffDial = bossAuraFriendlyDebuffDial

	local bossAuraHostileDebuffDial = CFG:CreateMaskDial(panel, {
		parent = tabbedFrame,
		name = "$parentBossAuraHostileDebuffDial",
		text = HOSTILE_TARGET_DEBUFFS,
		get = function(self)
			return C.units[self.key].auras.show_boss
		end,
		set = function(self, value)
			C.units[self.key].auras.show_boss = value
		end,
		calc = function(self)
			local value = C.units[self.key].auras.show_boss

			for i = 1, #self do
				if self[i]:IsPositive() then
					value = E:EnableFlag(value, self[i].value)
				else
					value = E:DisableFlag(value, self[i].value)
				end
			end

			return value
		end,
		flags = {
			[0] = bit.lshift(E.PLAYER_SPEC_FLAGS[0], 12),
			[1] = bit.lshift(E.PLAYER_SPEC_FLAGS[1], 12),
			[2] = bit.lshift(E.PLAYER_SPEC_FLAGS[2], 12),
			[3] = bit.lshift(E.PLAYER_SPEC_FLAGS[3], 12),
			[4] = bit.lshift(E.PLAYER_SPEC_FLAGS[4], 12),
		}
	})
	bossAuraHostileDebuffDial:SetWidth(266)
	bossAuraHostileDebuffDial:SetPoint("TOPLEFT", bossAuraFriendlyDebuffDial, "TOPRIGHT", 16, 0) -- + 4
	tabbedFrame.BossAuraHostileDebuffDial = bossAuraHostileDebuffDial

	divider = CFG:CreateDivider(tabbedFrame, "Mount Auras")
	divider:SetPoint("TOP", bossAuraFriendlyDebuffDial, "BOTTOM", 0, -12)

	local mountFriendlyBuffDial = CFG:CreateMaskDial(panel, {
		parent = tabbedFrame,
		name = "$parentMountFriendlyBuffDial",
		text = FRIENDLY_TARGET_BUFFS,
		get = function(self)
			return C.units[self.key].auras.show_mount
		end,
		set = function(self, value)
			C.units[self.key].auras.show_mount = value
		end,
		calc = function(self)
			local value = C.units[self.key].auras.show_mount

			for i = 1, #self do
				if self[i]:IsPositive() then
					value = E:EnableFlag(value, self[i].value)
				else
					value = E:DisableFlag(value, self[i].value)
				end
			end

			return value
		end,
		flags = {
			[0] = E.PLAYER_SPEC_FLAGS[0],
			[1] = E.PLAYER_SPEC_FLAGS[1],
			[2] = E.PLAYER_SPEC_FLAGS[2],
			[3] = E.PLAYER_SPEC_FLAGS[3],
			[4] = E.PLAYER_SPEC_FLAGS[4],
		}
	})
	mountFriendlyBuffDial:SetWidth(266)
	mountFriendlyBuffDial:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 10, -12) -- + 4
	tabbedFrame.MountFriendlyBuffDial = mountFriendlyBuffDial

	local mountHostileBuffDial = CFG:CreateMaskDial(panel, {
		parent = tabbedFrame,
		name = "$parentMountHostileBuffDial",
		text = HOSTILE_TARGET_BUFFS,
		get = function(self)
			return C.units[self.key].auras.show_mount
		end,
		set = function(self, value)
			C.units[self.key].auras.show_mount = value
		end,
		calc = function(self)
			local value = C.units[self.key].auras.show_mount

			for i = 1, #self do
				if self[i]:IsPositive() then
					value = E:EnableFlag(value, self[i].value)
				else
					value = E:DisableFlag(value, self[i].value)
				end
			end

			return value
		end,
		flags = {
			[0] = bit.lshift(E.PLAYER_SPEC_FLAGS[0], 4),
			[1] = bit.lshift(E.PLAYER_SPEC_FLAGS[1], 4),
			[2] = bit.lshift(E.PLAYER_SPEC_FLAGS[2], 4),
			[3] = bit.lshift(E.PLAYER_SPEC_FLAGS[3], 4),
			[4] = bit.lshift(E.PLAYER_SPEC_FLAGS[4], 4),
		}
	})
	mountHostileBuffDial:SetWidth(266)
	mountHostileBuffDial:SetPoint("TOPLEFT", mountFriendlyBuffDial, "TOPRIGHT", 16, 0) -- + 4
	tabbedFrame.MountHostileBuffDial = mountHostileBuffDial

	divider = CFG:CreateDivider(tabbedFrame, "Self Buffs and Debuffs")
	divider:SetPoint("TOP", mountFriendlyBuffDial, "BOTTOM", 0, -12)

	local selfCastFriendlyBuffDial = CFG:CreateMaskDial(panel, {
		parent = tabbedFrame,
		name = "$parentSelfCastFriendlyBuffDial",
		text = FRIENDLY_TARGET_BUFFS,
		get = function(self)
			return C.units[self.key].auras.show_selfcast
		end,
		set = function(self, value)
			C.units[self.key].auras.show_selfcast = value
		end,
		calc = function(self)
			local value = C.units[self.key].auras.show_selfcast

			for i = 1, #self do
				if self[i]:IsPositive() then
					value = E:EnableFlag(value, self[i].value)
				else
					value = E:DisableFlag(value, self[i].value)
				end
			end

			return value
		end,
		flags = {
			[0] = E.PLAYER_SPEC_FLAGS[0],
			[1] = E.PLAYER_SPEC_FLAGS[1],
			[2] = E.PLAYER_SPEC_FLAGS[2],
			[3] = E.PLAYER_SPEC_FLAGS[3],
			[4] = E.PLAYER_SPEC_FLAGS[4],
		}
	})
	selfCastFriendlyBuffDial:SetWidth(266)
	selfCastFriendlyBuffDial:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 10, -12) -- + 4
	tabbedFrame.SelfCastFriendlyBuffDial = selfCastFriendlyBuffDial

	local selfCastHostileBuffDial = CFG:CreateMaskDial(panel, {
		parent = tabbedFrame,
		name = "$parentSelfCastHostileBuffDial",
		text = HOSTILE_TARGET_BUFFS,
		get = function(self)
			return C.units[self.key].auras.show_selfcast
		end,
		set = function(self, value)
			C.units[self.key].auras.show_selfcast = value
		end,
		calc = function(self)
			local value = C.units[self.key].auras.show_selfcast

			for i = 1, #self do
				if self[i]:IsPositive() then
					value = E:EnableFlag(value, self[i].value)
				else
					value = E:DisableFlag(value, self[i].value)
				end
			end

			return value
		end,
		flags = {
			[0] = bit.lshift(E.PLAYER_SPEC_FLAGS[0], 4),
			[1] = bit.lshift(E.PLAYER_SPEC_FLAGS[1], 4),
			[2] = bit.lshift(E.PLAYER_SPEC_FLAGS[2], 4),
			[3] = bit.lshift(E.PLAYER_SPEC_FLAGS[3], 4),
			[4] = bit.lshift(E.PLAYER_SPEC_FLAGS[4], 4),
		}
	})
	selfCastHostileBuffDial:SetWidth(266)
	selfCastHostileBuffDial:SetPoint("TOPLEFT", selfCastFriendlyBuffDial, "TOPRIGHT", 16, 0) -- + 4
	tabbedFrame.SelfCastHostileBuffDial = selfCastHostileBuffDial

	local selfCastFriendlyDebuffDial = CFG:CreateMaskDial(panel, {
		parent = tabbedFrame,
		name = "$parentSelfCastFriendlyDebuffDial",
		text = FRIENDLY_TARGET_DEBUFFS,
		get = function(self)
			return C.units[self.key].auras.show_selfcast
		end,
		set = function(self, value)
			C.units[self.key].auras.show_selfcast = value
		end,
		calc = function(self)
			local value = C.units[self.key].auras.show_selfcast

			for i = 1, #self do
				if self[i]:IsPositive() then
					value = E:EnableFlag(value, self[i].value)
				else
					value = E:DisableFlag(value, self[i].value)
				end
			end

			return value
		end,
		flags = {
			[0] = bit.lshift(E.PLAYER_SPEC_FLAGS[0], 8),
			[1] = bit.lshift(E.PLAYER_SPEC_FLAGS[1], 8),
			[2] = bit.lshift(E.PLAYER_SPEC_FLAGS[2], 8),
			[3] = bit.lshift(E.PLAYER_SPEC_FLAGS[3], 8),
			[4] = bit.lshift(E.PLAYER_SPEC_FLAGS[4], 8),
		}
	})
	selfCastFriendlyDebuffDial:SetWidth(266)
	selfCastFriendlyDebuffDial:SetPoint("TOPLEFT", selfCastFriendlyBuffDial, "BOTTOMLEFT", 0, -8) -- + 4
	tabbedFrame.SelfCastFriendlyDebuffDial = selfCastFriendlyDebuffDial

	local selfCastHostileDebuffDial = CFG:CreateMaskDial(panel, {
		parent = tabbedFrame,
		name = "$parentSelfCastHostileDebuffDial",
		text = HOSTILE_TARGET_DEBUFFS,
		get = function(self)
			return C.units[self.key].auras.show_selfcast
		end,
		set = function(self, value)
			C.units[self.key].auras.show_selfcast = value
		end,
		calc = function(self)
			local value = C.units[self.key].auras.show_selfcast

			for i = 1, #self do
				if self[i]:IsPositive() then
					value = E:EnableFlag(value, self[i].value)
				else
					value = E:DisableFlag(value, self[i].value)
				end
			end

			return value
		end,
		flags = {
			[0] = bit.lshift(E.PLAYER_SPEC_FLAGS[0], 12),
			[1] = bit.lshift(E.PLAYER_SPEC_FLAGS[1], 12),
			[2] = bit.lshift(E.PLAYER_SPEC_FLAGS[2], 12),
			[3] = bit.lshift(E.PLAYER_SPEC_FLAGS[3], 12),
			[4] = bit.lshift(E.PLAYER_SPEC_FLAGS[4], 12),
		}
	})
	selfCastHostileDebuffDial:SetWidth(266)
	selfCastHostileDebuffDial:SetPoint("TOPLEFT", selfCastFriendlyDebuffDial, "TOPRIGHT", 16, 0) -- + 4
	tabbedFrame.SelfCastHostileDebuffDial = selfCastHostileDebuffDial

	divider = CFG:CreateDivider(tabbedFrame, "Personal Auras")
	divider:SetPoint("TOP", selfCastFriendlyDebuffDial, "BOTTOM", 0, -12)

	local personalFriendlyBuffDial = CFG:CreateMaskDial(panel, {
		parent = tabbedFrame,
		name = "$parentPersonalFriendlyBuffDial",
		text = FRIENDLY_TARGET_BUFFS,
		get = function(self)
			return C.units[self.key].auras.show_player
		end,
		set = function(self, value)
			C.units[self.key].auras.show_player = value
		end,
		calc = function(self)
			local value = C.units[self.key].auras.show_player

			for i = 1, #self do
				if self[i]:IsPositive() then
					value = E:EnableFlag(value, self[i].value)
				else
					value = E:DisableFlag(value, self[i].value)
				end
			end

			return value
		end,
		flags = {
			[0] = E.PLAYER_SPEC_FLAGS[0],
			[1] = E.PLAYER_SPEC_FLAGS[1],
			[2] = E.PLAYER_SPEC_FLAGS[2],
			[3] = E.PLAYER_SPEC_FLAGS[3],
			[4] = E.PLAYER_SPEC_FLAGS[4],
		}
	})
	personalFriendlyBuffDial:SetWidth(266)
	personalFriendlyBuffDial:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 10, -12) -- + 4
	tabbedFrame.PersonalFriendlyBuffDial = personalFriendlyBuffDial

	local personalHostileBuffDial = CFG:CreateMaskDial(panel, {
		parent = tabbedFrame,
		name = "$parentPersonalHostileBuffDial",
		text = HOSTILE_TARGET_BUFFS,
		get = function(self)
			return C.units[self.key].auras.show_player
		end,
		set = function(self, value)
			C.units[self.key].auras.show_player = value
		end,
		calc = function(self)
			local value = C.units[self.key].auras.show_player

			for i = 1, #self do
				if self[i]:IsPositive() then
					value = E:EnableFlag(value, self[i].value)
				else
					value = E:DisableFlag(value, self[i].value)
				end
			end

			return value
		end,
		flags = {
			[0] = bit.lshift(E.PLAYER_SPEC_FLAGS[0], 4),
			[1] = bit.lshift(E.PLAYER_SPEC_FLAGS[1], 4),
			[2] = bit.lshift(E.PLAYER_SPEC_FLAGS[2], 4),
			[3] = bit.lshift(E.PLAYER_SPEC_FLAGS[3], 4),
			[4] = bit.lshift(E.PLAYER_SPEC_FLAGS[4], 4),
		}
	})
	personalHostileBuffDial:SetWidth(266)
	personalHostileBuffDial:SetPoint("TOPLEFT", personalFriendlyBuffDial, "TOPRIGHT", 16, 0) -- + 4
	tabbedFrame.PersonalHostileBuffDial = personalHostileBuffDial

	local personalFriendlyDebuffDial = CFG:CreateMaskDial(panel, {
		parent = tabbedFrame,
		name = "$parentPersonalFriendlyDebuffDial",
		text = FRIENDLY_TARGET_DEBUFFS,
		get = function(self)
			return C.units[self.key].auras.show_player
		end,
		set = function(self, value)
			C.units[self.key].auras.show_player = value
		end,
		calc = function(self)
			local value = C.units[self.key].auras.show_player

			for i = 1, #self do
				if self[i]:IsPositive() then
					value = E:EnableFlag(value, self[i].value)
				else
					value = E:DisableFlag(value, self[i].value)
				end
			end

			return value
		end,
		flags = {
			[0] = bit.lshift(E.PLAYER_SPEC_FLAGS[0], 8),
			[1] = bit.lshift(E.PLAYER_SPEC_FLAGS[1], 8),
			[2] = bit.lshift(E.PLAYER_SPEC_FLAGS[2], 8),
			[3] = bit.lshift(E.PLAYER_SPEC_FLAGS[3], 8),
			[4] = bit.lshift(E.PLAYER_SPEC_FLAGS[4], 8),
		}
	})
	personalFriendlyDebuffDial:SetWidth(266)
	personalFriendlyDebuffDial:SetPoint("TOPLEFT", personalFriendlyBuffDial, "BOTTOMLEFT", 0, -8) -- + 4
	tabbedFrame.PersonalFriendlyDebuffDial = personalFriendlyDebuffDial

	local personalHostileDebuffDial = CFG:CreateMaskDial(panel, {
		parent = tabbedFrame,
		name = "$parentPersonalHostileDebuffDial",
		text = HOSTILE_TARGET_DEBUFFS,
		get = function(self)
			return C.units[self.key].auras.show_player
		end,
		set = function(self, value)
			C.units[self.key].auras.show_player = value
		end,
		calc = function(self)
			local value = C.units[self.key].auras.show_player

			for i = 1, #self do
				if self[i]:IsPositive() then
					value = E:EnableFlag(value, self[i].value)
				else
					value = E:DisableFlag(value, self[i].value)
				end
			end

			return value
		end,
		flags = {
			[0] = bit.lshift(E.PLAYER_SPEC_FLAGS[0], 12),
			[1] = bit.lshift(E.PLAYER_SPEC_FLAGS[1], 12),
			[2] = bit.lshift(E.PLAYER_SPEC_FLAGS[2], 12),
			[3] = bit.lshift(E.PLAYER_SPEC_FLAGS[3], 12),
			[4] = bit.lshift(E.PLAYER_SPEC_FLAGS[4], 12),
		}
	})
	personalHostileDebuffDial:SetWidth(266)
	personalHostileDebuffDial:SetPoint("TOPLEFT", personalFriendlyDebuffDial, "TOPRIGHT", 16, 0) -- + 4
	tabbedFrame.PersonalHostileDebuffDial = personalHostileDebuffDial

	divider = CFG:CreateDivider(tabbedFrame, "Dispellable Auras")
	divider:SetPoint("TOP", personalFriendlyDebuffDial, "BOTTOM", 0, -12)

	local dispellableFriendlyDebuffDial = CFG:CreateMaskDial(panel, {
		parent = tabbedFrame,
		name = "$parentDispellableFriendlyDebuffDial",
		text = FRIENDLY_TARGET_DEBUFFS,
			get = function(self)
				return C.units[self.key].auras.show_dispellable
			end,
			set = function(self, value)
				C.units[self.key].auras.show_dispellable = value
			end,
			calc = function(self)
				local value = C.units[self.key].auras.show_dispellable

				for i = 1, #self do
					if self[i]:IsPositive() then
						value = E:EnableFlag(value, self[i].value)
					else
						value = E:DisableFlag(value, self[i].value)
					end
				end

				return value
			end,
			flags = {
				[0] = bit.lshift(E.PLAYER_SPEC_FLAGS[0], 4),
				[1] = bit.lshift(E.PLAYER_SPEC_FLAGS[1], 4),
				[2] = bit.lshift(E.PLAYER_SPEC_FLAGS[2], 4),
				[3] = bit.lshift(E.PLAYER_SPEC_FLAGS[3], 4),
				[4] = bit.lshift(E.PLAYER_SPEC_FLAGS[4], 4),
		}
	})
	dispellableFriendlyDebuffDial:SetWidth(266)
	dispellableFriendlyDebuffDial:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 10, -12) -- + 4
	tabbedFrame.DispellableFriendlyDebuffDial = dispellableFriendlyDebuffDial

	local dispellableHostileBuffDial = CFG:CreateMaskDial(panel, {
		parent = tabbedFrame,
		name = "$parentDispellableHostileBuffDial",
		text = HOSTILE_TARGET_BUFFS,
		get = function(self)
			return C.units[self.key].auras.show_dispellable
		end,
		set = function(self, value)
			C.units[self.key].auras.show_dispellable = value
		end,
		calc = function(self)
			local value = C.units[self.key].auras.show_dispellable

			for i = 1, #self do
				if self[i]:IsPositive() then
					value = E:EnableFlag(value, self[i].value)
				else
					value = E:DisableFlag(value, self[i].value)
				end
			end

			return value
		end,
		flags = {
			[0] = bit.lshift(E.PLAYER_SPEC_FLAGS[0], 8),
			[1] = bit.lshift(E.PLAYER_SPEC_FLAGS[1], 8),
			[2] = bit.lshift(E.PLAYER_SPEC_FLAGS[2], 8),
			[3] = bit.lshift(E.PLAYER_SPEC_FLAGS[3], 8),
			[4] = bit.lshift(E.PLAYER_SPEC_FLAGS[4], 8),
		}
	})
	dispellableHostileBuffDial:SetWidth(266)
	dispellableHostileBuffDial:SetPoint("TOPLEFT", dispellableFriendlyDebuffDial, "TOPRIGHT", 16, 0) -- + 4
	tabbedFrame.DispellableHostileBuffDial = dispellableHostileBuffDial

	CFG:AddPanel(panel)
end
