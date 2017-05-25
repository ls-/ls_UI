local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local CFG = P:GetModule("Config")
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)
local bit = _G.bit

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
	subtext:SetText(L["UNIT_FRAME_AURAS_DESC"])

	local tabbedFrame = self:CreateTabbedFrame(panel,
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

				self.BossAuraFriendlyBuffsDial.key = self.key
				self.BossAuraFriendlyBuffsDial:RefreshValue()

				self.BossAuraHostileBuffsDial.key = self.key
				self.BossAuraHostileBuffsDial:RefreshValue()

				self.BossAuraFriendlyDebuffsDial.key = self.key
				self.BossAuraFriendlyDebuffsDial:RefreshValue()

				self.BossAuraHostileDebuffsDial.key = self.key
				self.BossAuraHostileDebuffsDial:RefreshValue()

				self.MountFriendlyBuffsDial.key = self.key
				self.MountFriendlyBuffsDial:RefreshValue()

				self.MountHostileBuffsDial.key = self.key
				self.MountHostileBuffsDial:RefreshValue()

				self.SelfCastFriendlyBuffsDial.key = self.key
				self.SelfCastFriendlyBuffsDial:RefreshValue()

				self.SelfCastHostileBuffsDial.key = self.key
				self.SelfCastHostileBuffsDial:RefreshValue()

				self.SelfCastFriendlyDebuffsDial.key = self.key
				self.SelfCastFriendlyDebuffsDial:RefreshValue()

				self.SelfCastHostileDebuffsDial.key = self.key
				self.SelfCastHostileDebuffsDial:RefreshValue()

				self.PermaSelfCastFriendlyBuffsDial.key = self.key
				self.PermaSelfCastFriendlyBuffsDial:RefreshValue()

				self.PermaSelfCastHostileBuffsDial.key = self.key
				self.PermaSelfCastHostileBuffsDial:RefreshValue()

				self.PermaSelfCastFriendlyDebuffsDial.key = self.key
				self.PermaSelfCastFriendlyDebuffsDial:RefreshValue()

				self.PermaSelfCastHostileDebuffsDial.key = self.key
				self.PermaSelfCastHostileDebuffsDial:RefreshValue()

				self.CastableFriendlyBuffsDial.key = self.key
				self.CastableFriendlyBuffsDial:RefreshValue()

				self.CastableHostileBuffsDial.key = self.key
				self.CastableHostileBuffsDial:RefreshValue()

				self.CastableFriendlyDebuffsDial.key = self.key
				self.CastableFriendlyDebuffsDial:RefreshValue()

				self.CastableHostileDebuffsDial.key = self.key
				self.CastableHostileDebuffsDial:RefreshValue()

				self.DispellableFriendlyDebuffsDial.key = self.key
				self.DispellableFriendlyDebuffsDial:RefreshValue()

				self.DispellableHostileBuffsDial.key = self.key
				self.DispellableHostileBuffsDial:RefreshValue()
			end,
			tabs = {
				[1] = {
					text = L["UNIT_FRAME_TARGET"]
				},
				[2] = {
					text = L["UNIT_FRAME_FOCUS"]
				},

			},
		})
	tabbedFrame:SetPoint("TOPLEFT", subtext, "BOTTOMLEFT", 6, -40)
	tabbedFrame:SetPoint("RIGHT", panel, "RIGHT", -16, 0)
	tabbedFrame:SetHeight(416)
	tabbedFrame.key = "target"
	_G.PanelTemplates_SetTab(tabbedFrame, 1)
	panel.TabbedFrame = tabbedFrame

	local aurasToggle = self:CreateCheckButton(panel,
		{
			parent = tabbedFrame,
			name = "$parentAuraToggle",
			text = L["ENABLE"],
			get = function(self)
				return C.db.profile.units[E.UI_LAYOUT][self.key].auras.enabled
			end,
			set = function(self, value)
				C.db.profile.units[E.UI_LAYOUT][self.key].auras.enabled = value
			end,
			refresh = function(self)
				self:SetChecked(C.db.profile.units[E.UI_LAYOUT][self.key].auras.enabled)
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

	local unitHeader = self:CreateDivider(tabbedFrame, {
		text = M.COLORS.GREEN:WrapText(L["UNIT_FRAME_FRIENDLY_TARGET"])
	})
	unitHeader:SetPoint("TOP", aurasToggle, "BOTTOM", 0, -12)
	unitHeader:SetPoint("RIGHT", tabbedFrame, "CENTER", -8, 0)

	unitHeader = self:CreateDivider(tabbedFrame, {
		text = M.COLORS.RED:WrapText(L["UNIT_FRAME_ENEMY_TARGET"])
	})
	unitHeader:SetPoint("TOP", aurasToggle, "BOTTOM", 0, -12)
	unitHeader:SetPoint("LEFT", tabbedFrame, "CENTER", 8, 0)

	local divider = self:CreateDivider(tabbedFrame, {
		text = L["UNIT_FRAME_BOSS_AURAS"]
	})
	divider:SetPoint("TOP", unitHeader, "BOTTOM", 0, -12)

	local bossAuraFriendlyBuffsDial = self:CreateMaskDial(panel, {
		parent = tabbedFrame,
		name = "$parentBossAuraFriendlyBuffsDial",
		text = L["BUFFS"],
		get = function(self)
			return C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_boss
		end,
		set = function(self, value)
			C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_boss = value
		end,
		calc = function(self)
			local value = C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_boss

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
	bossAuraFriendlyBuffsDial:SetWidth(266)
	bossAuraFriendlyBuffsDial:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 10, -12)
	tabbedFrame.BossAuraFriendlyBuffsDial = bossAuraFriendlyBuffsDial

	local bossAuraHostileBuffsDial = self:CreateMaskDial(panel, {
		parent = tabbedFrame,
		name = "$parentBossAuraHostileBuffsDial",
		text = L["BUFFS"],
		get = function(self)
			return C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_boss
		end,
		set = function(self, value)
			C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_boss = value
		end,
		calc = function(self)
			local value = C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_boss

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
	bossAuraHostileBuffsDial:SetWidth(266)
	bossAuraHostileBuffsDial:SetPoint("TOPLEFT", bossAuraFriendlyBuffsDial, "TOPRIGHT", 16, 0)
	tabbedFrame.BossAuraHostileBuffsDial = bossAuraHostileBuffsDial

	local bossAuraFriendlyDebuffsDial = self:CreateMaskDial(panel, {
		parent = tabbedFrame,
		name = "$parentBossAuraFriendlyDebuffsDial",
		text = L["DEBUFFS"],
		get = function(self)
			return C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_boss
		end,
		set = function(self, value)
			C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_boss = value
		end,
		calc = function(self)
			local value = C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_boss

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
	bossAuraFriendlyDebuffsDial:SetWidth(266)
	bossAuraFriendlyDebuffsDial:SetPoint("TOPLEFT", bossAuraFriendlyBuffsDial, "BOTTOMLEFT", 0, -8)
	tabbedFrame.BossAuraFriendlyDebuffsDial = bossAuraFriendlyDebuffsDial

	local bossAuraHostileDebuffsDial = self:CreateMaskDial(panel, {
		parent = tabbedFrame,
		name = "$parentBossAuraHostileDebuffsDial",
		text = L["DEBUFFS"],
		get = function(self)
			return C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_boss
		end,
		set = function(self, value)
			C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_boss = value
		end,
		calc = function(self)
			local value = C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_boss

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
	bossAuraHostileDebuffsDial:SetWidth(266)
	bossAuraHostileDebuffsDial:SetPoint("TOPLEFT", bossAuraFriendlyDebuffsDial, "TOPRIGHT", 16, 0)
	tabbedFrame.BossAuraHostileDebuffsDial = bossAuraHostileDebuffsDial

	divider = self:CreateDivider(tabbedFrame, {
		text = L["UNIT_FRAME_MOUNT_AURAS"]
	})
	divider:SetPoint("TOP", bossAuraFriendlyDebuffsDial, "BOTTOM", 0, -12)

	local mountFriendlyBuffsDial = self:CreateMaskDial(panel, {
		parent = tabbedFrame,
		name = "$parentMountFriendlyBuffsDial",
		text = L["BUFFS"],
		get = function(self)
			return C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_mount
		end,
		set = function(self, value)
			C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_mount = value
		end,
		calc = function(self)
			local value = C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_mount

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
	mountFriendlyBuffsDial:SetWidth(266)
	mountFriendlyBuffsDial:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 10, -12)
	tabbedFrame.MountFriendlyBuffsDial = mountFriendlyBuffsDial

	local mountHostileBuffsDial = self:CreateMaskDial(panel, {
		parent = tabbedFrame,
		name = "$parentMountHostileBuffsDial",
		text = L["BUFFS"],
		get = function(self)
			return C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_mount
		end,
		set = function(self, value)
			C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_mount = value
		end,
		calc = function(self)
			local value = C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_mount

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
	mountHostileBuffsDial:SetWidth(266)
	mountHostileBuffsDial:SetPoint("TOPLEFT", mountFriendlyBuffsDial, "TOPRIGHT", 16, 0)
	tabbedFrame.MountHostileBuffsDial = mountHostileBuffsDial

	divider = self:CreateDivider(tabbedFrame, {
		text = L["UNIT_FRAME_SELF_CAST_AURAS"],
		tooltip_text = L["UNIT_FRAME_SELF_CAST_AURAS_TOOLTIP"]
	})
	divider:SetPoint("TOP", mountFriendlyBuffsDial, "BOTTOM", 0, -12)

	local selfCastFriendlyBuffsDial = self:CreateMaskDial(panel, {
		parent = tabbedFrame,
		name = "$parentSelfCastFriendlyBuffsDial",
		text = L["BUFFS"],
		get = function(self)
			return C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_selfcast
		end,
		set = function(self, value)
			C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_selfcast = value
		end,
		calc = function(self)
			local value = C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_selfcast

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
	selfCastFriendlyBuffsDial:SetWidth(266)
	selfCastFriendlyBuffsDial:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 10, -12)
	tabbedFrame.SelfCastFriendlyBuffsDial = selfCastFriendlyBuffsDial

	local selfCastHostileBuffsDial = self:CreateMaskDial(panel, {
		parent = tabbedFrame,
		name = "$parentSelfCastHostileBuffsDial",
		text = L["BUFFS"],
		get = function(self)
			return C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_selfcast
		end,
		set = function(self, value)
			C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_selfcast = value
		end,
		calc = function(self)
			local value = C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_selfcast

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
	selfCastHostileBuffsDial:SetWidth(266)
	selfCastHostileBuffsDial:SetPoint("TOPLEFT", selfCastFriendlyBuffsDial, "TOPRIGHT", 16, 0)
	tabbedFrame.SelfCastHostileBuffsDial = selfCastHostileBuffsDial

	local selfCastFriendlyDebuffsDial = self:CreateMaskDial(panel, {
		parent = tabbedFrame,
		name = "$parentSelfCastFriendlyDebuffsDial",
		text = L["DEBUFFS"],
		get = function(self)
			return C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_selfcast
		end,
		set = function(self, value)
			C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_selfcast = value
		end,
		calc = function(self)
			local value = C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_selfcast

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
	selfCastFriendlyDebuffsDial:SetWidth(266)
	selfCastFriendlyDebuffsDial:SetPoint("TOPLEFT", selfCastFriendlyBuffsDial, "BOTTOMLEFT", 0, -8)
	tabbedFrame.SelfCastFriendlyDebuffsDial = selfCastFriendlyDebuffsDial

	local selfCastHostileDebuffsDial = self:CreateMaskDial(panel, {
		parent = tabbedFrame,
		name = "$parentSelfCastHostileDebuffsDial",
		text = L["DEBUFFS"],
		get = function(self)
			return C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_selfcast
		end,
		set = function(self, value)
			C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_selfcast = value
		end,
		calc = function(self)
			local value = C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_selfcast

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
	selfCastHostileDebuffsDial:SetWidth(266)
	selfCastHostileDebuffsDial:SetPoint("TOPLEFT", selfCastFriendlyDebuffsDial, "TOPRIGHT", 16, 0)
	tabbedFrame.SelfCastHostileDebuffsDial = selfCastHostileDebuffsDial

	divider = self:CreateDivider(tabbedFrame, {
		text = L["UNIT_FRAME_PERMA_SELF_CAST_AURAS"],
		tooltip_text = L["UNIT_FRAME_PERMA_SELF_CAST_AURAS_TOOLTIP"]
	})
	divider:SetPoint("TOP", selfCastFriendlyDebuffsDial, "BOTTOM", 0, -12)

	local permaSelfCastFriendlyBuffsDial = self:CreateMaskDial(panel, {
		parent = tabbedFrame,
		name = "$parentPermaSelfCastFriendlyBuffsDial",
		text = L["BUFFS"],
		get = function(self)
			return C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_selfcast_permanent
		end,
		set = function(self, value)
			C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_selfcast_permanent = value
		end,
		calc = function(self)
			local value = C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_selfcast_permanent

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
	permaSelfCastFriendlyBuffsDial:SetWidth(266)
	permaSelfCastFriendlyBuffsDial:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 10, -12)
	tabbedFrame.PermaSelfCastFriendlyBuffsDial = permaSelfCastFriendlyBuffsDial

	local permaSelfCastHostileBuffsDial = self:CreateMaskDial(panel, {
		parent = tabbedFrame,
		name = "$parentPermaSelfCastHostileBuffsDial",
		text = L["BUFFS"],
		get = function(self)
			return C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_selfcast_permanent
		end,
		set = function(self, value)
			C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_selfcast_permanent = value
		end,
		calc = function(self)
			local value = C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_selfcast_permanent

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
	permaSelfCastHostileBuffsDial:SetWidth(266)
	permaSelfCastHostileBuffsDial:SetPoint("TOPLEFT", permaSelfCastFriendlyBuffsDial, "TOPRIGHT", 16, 0)
	tabbedFrame.PermaSelfCastHostileBuffsDial = permaSelfCastHostileBuffsDial

	local permaSelfCastFriendlyDebuffsDial = self:CreateMaskDial(panel, {
		parent = tabbedFrame,
		name = "$parentPermaSelfCastFriendlyDebuffsDial",
		text = L["DEBUFFS"],
		get = function(self)
			return C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_selfcast_permanent
		end,
		set = function(self, value)
			C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_selfcast_permanent = value
		end,
		calc = function(self)
			local value = C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_selfcast_permanent

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
	permaSelfCastFriendlyDebuffsDial:SetWidth(266)
	permaSelfCastFriendlyDebuffsDial:SetPoint("TOPLEFT", permaSelfCastFriendlyBuffsDial, "BOTTOMLEFT", 0, -8)
	tabbedFrame.PermaSelfCastFriendlyDebuffsDial = permaSelfCastFriendlyDebuffsDial

	local permaSelfCastHostileDebuffsDial = self:CreateMaskDial(panel, {
		parent = tabbedFrame,
		name = "$parentPermaSelfCastHostileDebuffsDial",
		text = L["DEBUFFS"],
		get = function(self)
			return C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_selfcast_permanent
		end,
		set = function(self, value)
			C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_selfcast_permanent = value
		end,
		calc = function(self)
			local value = C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_selfcast_permanent

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
	permaSelfCastHostileDebuffsDial:SetWidth(266)
	permaSelfCastHostileDebuffsDial:SetPoint("TOPLEFT", permaSelfCastFriendlyDebuffsDial, "TOPRIGHT", 16, 0)
	tabbedFrame.PermaSelfCastHostileDebuffsDial = permaSelfCastHostileDebuffsDial

	divider = self:CreateDivider(tabbedFrame, {
		text = L["UNIT_FRAME_CASTABLE_AURAS"],
		tooltip_text = L["UNIT_FRAME_CASTABLE_AURAS_TOOLTIP"]
	})
	divider:SetPoint("TOP", permaSelfCastFriendlyDebuffsDial, "BOTTOM", 0, -12)

	local personalFriendlyBuffsDial = self:CreateMaskDial(panel, {
		parent = tabbedFrame,
		name = "$parentCastableFriendlyBuffsDial",
		text = L["BUFFS"],
		get = function(self)
			return C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_player
		end,
		set = function(self, value)
			C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_player = value
		end,
		calc = function(self)
			local value = C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_player

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
	personalFriendlyBuffsDial:SetWidth(266)
	personalFriendlyBuffsDial:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 10, -12)
	tabbedFrame.CastableFriendlyBuffsDial = personalFriendlyBuffsDial

	local personalHostileBuffsDial = self:CreateMaskDial(panel, {
		parent = tabbedFrame,
		name = "$parentCastableHostileBuffsDial",
		text = L["BUFFS"],
		get = function(self)
			return C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_player
		end,
		set = function(self, value)
			C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_player = value
		end,
		calc = function(self)
			local value = C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_player

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
	personalHostileBuffsDial:SetWidth(266)
	personalHostileBuffsDial:SetPoint("TOPLEFT", personalFriendlyBuffsDial, "TOPRIGHT", 16, 0)
	tabbedFrame.CastableHostileBuffsDial = personalHostileBuffsDial

	local personalFriendlyDebuffsDial = self:CreateMaskDial(panel, {
		parent = tabbedFrame,
		name = "$parentCastableFriendlyDebuffsDial",
		text = L["DEBUFFS"],
		get = function(self)
			return C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_player
		end,
		set = function(self, value)
			C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_player = value
		end,
		calc = function(self)
			local value = C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_player

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
	personalFriendlyDebuffsDial:SetWidth(266)
	personalFriendlyDebuffsDial:SetPoint("TOPLEFT", personalFriendlyBuffsDial, "BOTTOMLEFT", 0, -8)
	tabbedFrame.CastableFriendlyDebuffsDial = personalFriendlyDebuffsDial

	local personalHostileDebuffsDial = self:CreateMaskDial(panel, {
		parent = tabbedFrame,
		name = "$parentCastableHostileDebuffsDial",
		text = L["DEBUFFS"],
		get = function(self)
			return C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_player
		end,
		set = function(self, value)
			C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_player = value
		end,
		calc = function(self)
			local value = C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_player

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
	personalHostileDebuffsDial:SetWidth(266)
	personalHostileDebuffsDial:SetPoint("TOPLEFT", personalFriendlyDebuffsDial, "TOPRIGHT", 16, 0)
	tabbedFrame.CastableHostileDebuffsDial = personalHostileDebuffsDial

	divider = self:CreateDivider(tabbedFrame, {
		text = L["UNIT_FRAME_DISPELLABLE_AURAS"],
		tooltip_text = L["UNIT_FRAME_DISPELLABLE_AURAS_TOOLTIP"]
	})
	divider:SetPoint("TOP", personalFriendlyDebuffsDial, "BOTTOM", 0, -12)

	local dispellableFriendlyDebuffsDial = self:CreateMaskDial(panel, {
		parent = tabbedFrame,
		name = "$parentDispellableFriendlyDebuffsDial",
		text = L["DEBUFFS"],
			get = function(self)
				return C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_dispellable
			end,
			set = function(self, value)
				C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_dispellable = value
			end,
			calc = function(self)
				local value = C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_dispellable

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
	dispellableFriendlyDebuffsDial:SetWidth(266)
	dispellableFriendlyDebuffsDial:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 10, -12)
	tabbedFrame.DispellableFriendlyDebuffsDial = dispellableFriendlyDebuffsDial

	local dispellableHostileBuffsDial = self:CreateMaskDial(panel, {
		parent = tabbedFrame,
		name = "$parentDispellableHostileBuffsDial",
		text = L["BUFFS"],
		get = function(self)
			return C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_dispellable
		end,
		set = function(self, value)
			C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_dispellable = value
		end,
		calc = function(self)
			local value = C.db.profile.units[E.UI_LAYOUT][self.key].auras.show_dispellable

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
	dispellableHostileBuffsDial:SetWidth(266)
	dispellableHostileBuffsDial:SetPoint("TOPLEFT", dispellableFriendlyDebuffsDial, "TOPRIGHT", 16, 0)
	tabbedFrame.DispellableHostileBuffsDial = dispellableHostileBuffsDial

	self:AddPanel(panel)
end
