local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)
local next = _G.next
local select = _G.select
local unpack = _G.unpack

-- Mine
local MOUNTS = {}

for _, id in next, C_MountJournal.GetMountIDs() do
	MOUNTS[select(2, C_MountJournal.GetMountInfoByID(id))] = true
end

local filterFunctions = {
	default = function(self, unit, data)
		local config = self._config and self._config.filter or nil
		if not config then return end

		-- black- and whitelists
		for filter, enabled in next, config.custom do
			if enabled then
				filter = C.db.global.aura_filters[filter]
				if filter and filter[data.spellId] then
					return filter.state
				end
			end
		end

		local isFriend = UnitIsFriend("player", unit)

		config = isFriend and config.friendly or config.enemy
		if not config then return end

		config = data.isHarmful and config.debuff or config.buff
		if not config then return end

		-- boss
		if data.isBossAura or E:IsUnitBoss(data.sourceUnit) then
			return config.boss
		end

		-- applied by a tank
		if data.sourceUnit and E:IsUnitTank(data.sourceUnit) and not data.isPlayerAura then
			return config.tank
		end

		-- applied by a healer
		if data.sourceUnit and E:IsUnitHealer(data.sourceUnit) and not data.isPlayerAura then
			return config.healer
		end

		-- mounts
		if MOUNTS[data.spellId] then
			return config.mount
		end

		-- self-cast
		if data.sourceUnit and UnitIsUnit(unit, data.sourceUnit) then
			if data.duration and data.duration ~= 0 then
				return config.selfcast
			else
				return config.selfcast and config.selfcast_permanent
			end
		end

		-- applied by the player/vehicle/pet
		if data.isPlayerAura then
			if data.duration and data.duration ~= 0 then
				return config.player
			else
				return config.player and config.player_permanent
			end
		end

		if isFriend then
			if data.isHarmful then
				-- dispellable
				if data.dispelName and E:IsDispellable(data.dispelName) then
					return config.dispellable
				end
			end
		else
			if data.isHelpful then
				-- dispellable (enrage)
				if data.dispelName and E:IsDispellable(data.dispelName) then
					return config.dispellable
				end

				-- stealable
				if data.isStealable then
					return config.dispellable
				end
			end
		end

		return config.misc
	end,
	boss = function(self, unit, data)
		local config = self._config and self._config.filter or nil
		if not config then return end

		-- black- and whitelists
		for filter, enabled in next, config.custom do
			if enabled then
				filter = C.db.global.aura_filters[filter]
				if filter and filter[data.spellId] then
					return filter.state
				end
			end
		end

		local isFriend = UnitIsFriend("player", unit)

		config = isFriend and config.friendly or config.enemy
		if not config then return end

		config = data.isHarmful and config.debuff or config.buff
		if not config then return end

		-- boss
		if data.isBossAura or E:IsUnitBoss(data.sourceUnit) then
			return config.boss
		end

		-- applied by a tank
		if data.sourceUnit and E:IsUnitTank(data.sourceUnit) and not data.isPlayerAura then
			return config.tank
		end

		-- applied by a healer
		if data.sourceUnit and E:IsUnitHealer(data.sourceUnit) and not data.isPlayerAura then
			return config.healer
		end

		-- applied by the player/vehicle/pet
		if data.isPlayerAura then
			if data.duration and data.duration ~= 0 then
				return config.player
			else
				return config.player and config.player_permanent
			end
		end

		if isFriend then
			if data.isHarmful then
				-- dispellable
				if data.dispelName and E:IsDispellable(data.dispelName) then
					return config.dispellable
				end
			end
		else
			if data.isHelpful then
				-- dispellable (enrage)
				if data.dispelName and E:IsDispellable(data.dispelName) then
					return config.dispellable
				end

				-- stealable
				if data.isStealable then
					return config.dispellable
				end
			end
		end

		return config.misc
	end,
}

local button_proto = {}

function button_proto:UpdateTooltip()
	if GameTooltip:IsForbidden() then return end

	if self.isHarmful then
		GameTooltip:SetUnitDebuffByAuraInstanceID(self:GetParent().__owner.unit, self.auraInstanceID)
	else
		GameTooltip:SetUnitBuffByAuraInstanceID(self:GetParent().__owner.unit, self.auraInstanceID)
	end
end

function button_proto:OnEnter()
	if GameTooltip:IsForbidden() or not self:IsVisible() then return end

	-- Avoid parenting GameTooltip to frames with anchoring restrictions,
	-- otherwise it'll inherit said restrictions which will cause issues with
	-- its further positioning, clamping, etc
	GameTooltip:SetOwner(self, self:GetParent().__restricted and "ANCHOR_CURSOR" or self:GetParent().tooltipAnchor)
	self:UpdateTooltip()
end

function button_proto:OnLeave()
	if GameTooltip:IsForbidden() then return end

	GameTooltip:Hide()
end

local element_proto = {
	showDebuffType = true,
	showStealableBuffs = true,
	spacing = 4,
}

function element_proto:CreateButton(index)
	local config = self._config
	if not config then
		self:UpdateConfig()
		config = self._config
	end

	local button = Mixin(E:CreateButton(self, "$parentAura" .. index, true, true, true), button_proto)
	button:SetScript("OnEnter", button.OnEnter)
	button:SetScript("OnLeave", button.OnLeave)

	local count = button.Count
	count:UpdateFont(config.count.size)
	count:SetJustifyH(config.count.h_alignment)
	count:SetJustifyV(config.count.v_alignment)
	count:SetWordWrap(false)
	count:SetAllPoints()

	if button.Cooldown.UpdateConfig then
		button.Cooldown:UpdateConfig(self.cooldownConfig or {})
		button.Cooldown:UpdateFont()
		button.Cooldown:UpdateSwipe()
	end

	button:SetPushedTexture(0)
	button:SetHighlightTexture(0)

	local stealable = button.TextureParent:CreateTexture(nil, "OVERLAY", nil, 2)
	stealable:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Stealable")
	stealable:SetTexCoord(2 / 32, 30 / 32, 2 / 32, 30 / 32)
	stealable:SetPoint("TOPLEFT", -1, 1)
	stealable:SetPoint("BOTTOMRIGHT", 1, -1)
	stealable:SetBlendMode("ADD")
	button.Stealable = stealable

	local auraType = button.TextureParent:CreateTexture(nil, "OVERLAY", nil, 3)
	auraType:SetTexture("Interface\\AddOns\\ls_UI\\assets\\unit-frame-aura-icons")
	auraType:SetPoint(config.type.position, 0, 0)
	auraType:SetSize(config.type.size, config.type.size)
	auraType:SetShown(config.type.enabled)
	button.AuraType = auraType

	return button
end

function element_proto:PostUpdateButton(button, unit, data)
	if button.isHarmful then
		button.Border:SetVertexColor((C.db.global.colors.debuff[data.dispelName] or C.db.global.colors.debuff.None):GetRGB())

		if self._config.type.enabled then
			if UnitIsFriend("player", unit) then
				button.AuraType:SetTexCoord(unpack(M.textures.debuff_icons[data.dispelName] or M.textures.debuff_icons.Debuff))
			else
				button.AuraType:SetTexCoord(unpack(M.textures.debuff_icons.Debuff))
			end
		end
	else
		-- "" is enrage, it's a legit buff dispelName
		button.Border:SetVertexColor((C.db.global.colors.buff[data.dispelName] or C.db.global.colors.white):GetRGB())

		if self._config.type.enabled then
			if not UnitIsFriend("player", unit) then
				button.AuraType:SetTexCoord(unpack(M.textures.buff_icons[data.dispelName] or M.textures.buff_icons.Buff))
			else
				button.AuraType:SetTexCoord(unpack(M.textures.buff_icons.Buff))
			end
		end
	end
end

function element_proto:UpdateConfig()
	local unit = self.__owner.__unit
	self._config = E:CopyTable(C.db.profile.units[unit].auras, self._config)
	self._config.width = self._config.width ~= 0 and self._config.width
		or E:Round((C.db.profile.units[unit].width - (self.spacing * (self._config.per_row - 1)) + 2) / self._config.per_row)
	self._config.height = self._config.height ~= 0 and self._config.height or self._config.width
end

function element_proto:UpdateCooldownConfig()
	if not self.cooldownConfig then
		self.cooldownConfig = {
			swipe = {},
			text = {},
		}
	end

	self.cooldownConfig = E:CopyTable(C.db.profile.units.cooldown, self.cooldownConfig)
	self.cooldownConfig.text = E:CopyTable(self._config.cooldown.text, self.cooldownConfig.text)

	for i = 1, self.createdButtons do
		if not self[i].Cooldown.UpdateConfig then
			break
		end

		self[i].Cooldown:UpdateConfig(self.cooldownConfig)
		self[i].Cooldown:UpdateFont()
		self[i].Cooldown:UpdateSwipe()
	end
end

function element_proto:UpdateFonts()
	local config = self._config.count
	local count

	for i = 1, self.createdButtons do
		count = self[i].Count
		count:UpdateFont(config.size)
		count:SetJustifyH(config.h_alignment)
		count:SetJustifyV(config.v_alignment)
	end
end

function element_proto:UpdateAuraTypeIcon()
	local config = self._config.type
	local auraType

	for i = 1, self.createdButtons do
		auraType = self[i].AuraType
		auraType:ClearAllPoints()
		auraType:SetPoint(config.position, 0, 0)
		auraType:SetSize(config.size, config.size)
		auraType:SetShown(config.enabled)
	end
end

function element_proto:UpdateSize()
	local config = self._config

	self.width = config.width
	self.height = config.height
	self.numTotal = config.per_row * config.rows

	self:SetSize(config.width * config.per_row + self.spacing * (config.per_row - 1),
		config.height * config.rows + self.spacing * (config.rows - 1))
end

function element_proto:UpdatePoints()
	local config = self._config.point1

	self:ClearAllPoints()

	if config.p and config.p ~= "" then
		self:SetPoint(config.p, E:ResolveAnchorPoint(self.__owner, config.anchor), config.rP, config.x, config.y)
	end
end

function element_proto:UpdateGrowthDirection()
	local config = self._config

	self["growth-x"] = config.x_growth
	self["growth-y"] = config.y_growth

	if config.y_growth == "UP" then
		if config.x_growth == "RIGHT" then
			self.initialAnchor = "BOTTOMLEFT"
		else
			self.initialAnchor = "BOTTOMRIGHT"
		end
	else
		if config.x_growth == "RIGHT" then
			self.initialAnchor = "TOPLEFT"
		else
			self.initialAnchor = "TOPRIGHT"
		end
	end
end

function element_proto:UpdateMouse()
	self.disableMouse = self._config.disable_mouse
end

function element_proto:UpdateColors()
	if self.__owner:IsElementEnabled("Auras") then
		self:ForceUpdate()
	end
end

local frame_proto = {}

function frame_proto:UpdateAuras()
	local element = self.Auras
	element:UpdateConfig()
	element:UpdateCooldownConfig()
	element:UpdateSize()
	element:UpdatePoints()
	element:UpdateGrowthDirection()
	element:UpdateAuraTypeIcon()
	element:UpdateFonts()
	element:UpdateMouse()

	if element._config.enabled and not self:IsElementEnabled("Auras") then
		self:EnableElement("Auras")
	elseif not element._config.enabled and self:IsElementEnabled("Auras") then
		self:DisableElement("Auras")
	end

	if self:IsElementEnabled("Auras") then
		element:ForceUpdate()
	end
end

function UF:CreateAuras(frame, unit)
	Mixin(frame, frame_proto)

	local element = Mixin(CreateFrame("Frame", nil, frame), element_proto)
	element:SetSize(48, 48)

	element.FilterAura = filterFunctions[unit] or filterFunctions.default

	return element
end
