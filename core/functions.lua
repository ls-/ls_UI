local _, ns = ...
local E, M, oUF = ns.E, ns.M, ns.oUF or oUF

--[[ NEW ]]

function E:CreateFontString(parent, size, name, shadow, outline, ...)
	local r, g, b, a = ...

	object = parent:CreateFontString(name, "ARTWORK")
	object:SetFont(M.font, size, outline)
	object:SetTextColor(r, g, b, a)

	if shadow then
		object:SetShadowColor(0, 0, 0)
		object:SetShadowOffset(1, -1)
	end

	return object
end

function E:TweakIcon(icon, l, r, t, b)
	icon:SetTexCoord(l or 0.0625, r or 0.9375, t or 0.0625, b or 0.9375)
	icon:SetDrawLayer("BACKGROUND", 0)
	icon:SetAllPoints()
end

function E:CreateButtonBorder(button, curTexture)
	local texture = curTexture or button:CreateTexture()
	texture:SetDrawLayer("BORDER", 2)
	texture:SetTexture(ns.M.textures.button.normal)
	texture:SetTexCoord(0.140625, 0.859375, 0.140625, 0.859375)
	texture:ClearAllPoints()
	texture:SetPoint("TOPLEFT", -3, 3)
	texture:SetPoint("BOTTOMRIGHT", 3, -3)

	return texture
end

function E:AlwaysShow(self)
	if not self then return end
	self:Show()
	self.Hide = self.Show
end

function E:AlwaysHide(self)
	if not self then return end
	self:Hide()
	self.Show = self.Hide
end

function E:GetCoords(object)
	local p, anchor, rP, x, y = object:GetPoint()

	if not x then
		return p, anchor, rP, x, y
	else
		return p, anchor and anchor:GetName() or "UIParent", rP, E:Round(x), E:Round(y)
	end
end





















-----------
-- DEBUG --
-----------

function ns.DebugTexture(self)
	if self:IsObjectType("Texture") then
		self.tex = self:GetParent():CreateTexture(nil, "BACKGROUND",nil,-8)
	else
		self.tex = self:CreateTexture(nil, "BACKGROUND",nil,-8)
	end
	self.tex:SetAllPoints(self)
	self.tex:SetTexture(1, 0, 0.5, 0.4)
end

-----------
-- UTILS --
-----------

function ns.lsAlwaysShow(self)
	if not self then return end
	self:Show()
	self.Hide = self.Show
end

function ns.lsAlwaysHide(self)
	if not self then return end
	self:Hide()
	self.Show = self.Hide
end

function ns.UnitFrame_OnEnter(self)
	if self.__owner then
		self = self.__owner
	end

	UnitFrame_OnEnter(self)

	local frameName = gsub(self:GetName(), "%d", "")
	if frameName == "lsPartyFrameUnitButton" then
		PartyMemberBuffTooltip:ClearAllPoints()
		PartyMemberBuffTooltip:SetPoint("TOPLEFT", self, "BOTTOMRIGHT", -10, 10)
		PartyMemberBuffTooltip_Update(self)
	elseif frameName == "lsPetFrame" then
		PartyMemberBuffTooltip:ClearAllPoints()
		PartyMemberBuffTooltip:SetPoint("BOTTOMRIGHT", self, "TOPLEFT", 4, -4)
		PartyMemberBuffTooltip_Update(self)
	end

	self.isMouseOver = true
	if self.mouseovers then
		for _, element in ipairs(self.mouseovers) do
			if element.ForceUpdate then
				element:ForceUpdate()
			else
				element:Show()
			end
		end
	end
end

function ns.UnitFrame_OnLeave(self)
	if self.__owner then
		self = self.__owner
	end

	UnitFrame_OnLeave(self)

	local frameName = gsub(self:GetName(), "%d", "")
	if frameName == "lsPartyFrameUnitButton" then
		PartyMemberBuffTooltip:Hide()
	elseif frameName == "lsPetFrame" then
		PartyMemberBuffTooltip:Hide()
	end

	self.isMouseOver = nil
	if self.mouseovers then
		for _, element in ipairs(self.mouseovers) do
			if element.ForceUpdate then
				element:ForceUpdate()
			else
				element:Hide()
			end
		end
	end
end

function ns.lsCreateButtonBorder(button, curTexture)
	local texture = curTexture or button:CreateTexture()
	texture:SetDrawLayer("BORDER", 2)
	texture:SetTexture(ns.M.textures.button.normal)
	texture:SetTexCoord(0.140625, 0.859375, 0.140625, 0.859375)
	texture:ClearAllPoints()
	texture:SetPoint("TOPLEFT", -3, 3)
	texture:SetPoint("BOTTOMRIGHT", 3, -3)

	return texture
end

function ns.lsTweakIcon(icon, l, r, t, b)
	icon:SetTexCoord(l or 0.0625, r or 0.9375, t or 0.0625, b or 0.9375)
	icon:SetDrawLayer("BACKGROUND", 0)
	icon:SetAllPoints()
end

function ns.lsSetHighlightTexture(texture)
	texture:SetTexture(ns.M.textures.button.highlight)
	texture:SetTexCoord(0.234375, 0.765625, 0.234375, 0.765625)
	texture:SetAllPoints()
end

function ns.lsSetPushedTexture(texture)
	texture:SetTexture(ns.M.textures.button.pushed)
	texture:SetTexCoord(0.234375, 0.765625, 0.234375, 0.765625)
	texture:SetAllPoints()
end

function ns.lsSetCheckedTexture(texture)
	texture:SetTexture(ns.M.textures.button.checked)
	texture:SetTexCoord(0.234375, 0.765625, 0.234375, 0.765625)
	texture:SetAllPoints()
end

function lsCreateAlphaAnimation(self, change, duration, loopType)
	self.animation = self:CreateAnimationGroup()
	self.animation:SetLooping(loopType or "BOUNCE")
	local glowAnimation = self.animation:CreateAnimation("ALPHA")
	glowAnimation:SetDuration(duration or 1)
	glowAnimation:SetChange(change)
end

do
	oUF.colors.health = ns.M.colors.health

	for r, data in pairs(ns.M.colors.reaction) do
		oUF.colors.reaction[r] = data
	end

	for p, data in pairs(ns.M.colors.power) do
		oUF.colors.power[p] = data
	end
end

-----------------
-- BUFF/DEBUFF --
-----------------

function ns.CreateBuff (self, unit)
	local frame = CreateFrame("Frame", nil, self)
	frame:SetPoint("BOTTOMLEFT", self.NameText, "TOP", 8, 6)
	frame:SetWidth(20 * 4 + 4 * 3)
	frame:SetHeight(20 * 8 + 4 * 7)

	frame["growth-x"] = "LEFT"
	frame["initialAnchor"] = "BOTTOMRIGHT"
	frame["num"] = 32
	frame["size"] = 20
	frame["spacing-x"] = 4
	frame["spacing-y"] = 4
	frame.showStealableBuffs = true

	frame.PreUpdate = ns.BuffPreUpdate
	frame.PostCreateIcon = ns.CreateAuraIcon
	frame.PostUpdateIcon = ns.UpdateAuraIcon

	return frame
end

function ns.CreateDebuff (self, unit)
	local numAuras, auraSize
	local frame = CreateFrame("Frame", nil, self)
	if unit == "party" then
		frame:SetPoint("TOP", self, "BOTTOM", 0, -2)
		frame:SetWidth(16 * 4 + 4 * 3)
		frame:SetHeight(16 * 1)
		numAuras, auraSize = 4, 16
	else
		frame:SetPoint("BOTTOMRIGHT", self.NameText, "TOP", -8, 6)
		frame:SetWidth(20 * 4 + 4 * 3)
		frame:SetHeight(20 * 4 + 4 * 3)
		numAuras, auraSize = 16, 20
	end

	frame["showType"] = true
	frame["num"] = numAuras
	frame["size"] = auraSize
	frame["spacing-x"] = 4
	frame["spacing-y"] = 4

	frame.PreUpdate = ns.DebuffPreUpdate
	frame.PostCreateIcon = ns.CreateAuraIcon
	frame.PostUpdateIcon = ns.UpdateAuraIcon
	frame.CustomFilter = ns.CustomDebuffFilter

	return frame
end

function ns.CreateAuraIcon(self, button)
	button.cd:SetAllPoints()
	button.cd:SetReverse()
	button.cd:SetHideCountdownNumbers(true)

	E:TweakIcon(button.icon)

	E:CreateButtonBorder(button, button.overlay)
	ns.lsAlwaysShow(button.overlay)

	E:CreateButtonBorder(button, button.stealable)
	button.stealable:SetVertexColor(1.0, 0.82, 0.0)

	button.fg = CreateFrame("Frame", nil, button)
	button.fg:SetAllPoints(button)
	button.fg:SetFrameLevel(5)

	if not OmniCC then
		button.timer = ns.CreateFontString(button.fg, ns.M.font, 12, "THINOUTLINE")
		button.timer:SetPoint("BOTTOM", button.fg, "BOTTOM", 1, 0)
	end

	button.count:ClearAllPoints()
	button.count:SetPoint("TOPRIGHT", button.fg, "TOPRIGHT", 4, 4)
	button.count:SetFont(ns.M.font, 12, "THINOUTLINE")
end

function ns.UpdateAuraIcon(self, unit, icon, index, offset)
	local name, _, _, _, _, duration, expirationTime, _, stealable = UnitAura(unit, index, icon.filter)
	local texture = icon.icon

	if not self.onlyShowPlayer then
		if (icon.owner == "player" or icon.owner == "vehicle" or icon.owner == "pet") and icon.isDebuff
			or (not icon.isDebuff and (stealable or icon.owner == "player" or icon.owner == "vehicle" or icon.owner == "pet")) then
			texture:SetDesaturated(false)
			icon:SetAlpha(1)
		else
			texture:SetDesaturated(true)
			icon:SetAlpha(0.75)
		end
	end
	if not OmniCC then
		if duration and duration > 0 then
			icon.timer:Show()
			icon.expires = expirationTime
			icon:SetScript("OnUpdate", function(self, elapsed)
				self.elapsed = (self.elapsed or 0) + elapsed
				if self.elapsed < 0.1 then return end
				self.elapsed = 0

				local timeLeft = self.expires - GetTime()
				if timeLeft > 0 and timeLeft <= 30 then
					if timeLeft > 10 then
						self.timer:SetTextColor(0.9, 0.9, 0.9)
					elseif timeLeft > 5 and timeLeft <= 10 then
						self.timer:SetTextColor(1, 0.75, 0.1)
					elseif timeLeft <= 5 then
						self.timer:SetTextColor(0.9, 0.1, 0.1)
					end
					self.timer:SetText(E:TimeFormat(timeLeft))
				else
					self.timer:SetText(nil)
				end
			end)
		else
			icon.timer:Hide()
			icon:SetScript("OnUpdate", nil)
		end
	end
end

function ns.CustomDebuffFilter(...)
	local icons, unit, icon, name, _, _, _, _, _, _, caster, _, _, spellID = ...
	if GetCVar("showAllEnemyDebuffs") == "1" or not UnitCanAttack("player", unit) or (icons.onlyShowPlayer and icon.isPlayer) then
		return true
	else
		local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(spellID, "ENEMY_TARGET")
		if hasCustom then
			return showForMySpec or (alwaysShowMine and (caster == "player" or caster == "pet" or caster == "vehicle"))
		else
			return icon.isPlayer or caster == "player" or caster == "pet" or caster == "vehicle"
		end
	end
end

function ns.BuffPreUpdate(self, unit)
	if GetCVar("showCastableBuffs") == "1" and UnitCanAssist("player", unit) then
		self.filter = "HELPFUL|RAID"
	else
		self.filter = nil
	end
end

function ns.DebuffPreUpdate(self, unit)
	if GetCVar("showDispelDebuffs") == "1" and UnitCanAssist("player", unit) then
		self.filter = "HARMFUL|RAID"
	else
		self.filter = nil
	end
end

------------------
-- HEALTH/POWER --
------------------

function ns.UpdateHealth(self, unit, cur, max)
	if self.lowHP then
		local perc = floor(cur / max * 100)
		if perc <= 25 and cur > 1 then
			self.lowHP.animation:Play()
		else
			self.lowHP.animation:Stop()
		end
	end

	if not self.value then print(unit, "no health value") return end

	local color
	if not UnitIsConnected(unit) then
		color = E:RGBToHEX(self.__owner.colors.disconnected)
		return self.value:SetFormattedText("|cff"..color.."%s|r", PLAYER_OFFLINE)
	elseif UnitIsDeadOrGhost(unit) then
		color = E:RGBToHEX(self.__owner.colors.disconnected)
		local deadText
		if UnitIsPlayer(unit) and unit == "player" then
			if UnitSex(unit) == 2 or UnitSex(unit) == 1 then
				deadText = gsub(SPELL_FAILED_CASTER_DEAD, "[.]", "")
			elseif UnitSex(unit) == 3 then
				deadText = gsub(SPELL_FAILED_CASTER_DEAD_FEMALE, "[.]", "")
			end
		end
		return self.value:SetFormattedText("|cff"..color.."%s|r", deadText and deadText or DEAD)
	end

	if cur < max then
		if self.__owner.isMouseOver then
			return self.value:SetFormattedText("|cffffffff%s|r", E:NumberFormat(cur, 1))
		else
			if GetCVar("statusTextDisplay") == "PERCENT" then
				return self.value:SetFormattedText("|cffffffff%d%%|r", E:NumberToPerc(cur, max))
			else
				self.value:SetFormattedText("|cffffffff%s|r", E:NumberFormat(cur, 1))
			end
		end
	elseif self.__owner.isMouseOver then
		return self.value:SetFormattedText("|cffffffff%s|r", E:NumberFormat(max, 1))
	else
		return self.value:SetText(nil)
	end
end

function ns.UnitFrameReskin(frame, texType)
	if texType == "sol" then
		frame.Health:SetPoint("BOTTOM", frame, "BOTTOM", 0, 8)
	else
		frame.Health:SetPoint("BOTTOM", frame, "BOTTOM", 0, 14)
	end
	frame.fg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_"..frame.frameType.."_"..texType)
end

function ns.UpdatePower(self, unit, cur, max)
	local realUnit = self.__owner:GetAttribute("oUF-guessUnit") or unit
	if realUnit ~= "player" and realUnit ~= "vehicle" and realUnit ~= "pet" then
		if self.prevMax ~= max then
			self.prevMax = max
			if max == 0 then
				ns.UnitFrameReskin(self.__owner, "sol")
				return self:Hide(), self.value:Hide()
			else
				ns.UnitFrameReskin(self.__owner, "sep")
				self:Show() self.value:Show()
			end
		end
	end

	if not self.value then return end

	if max == 0 then
		self.value:SetText(nil)
		return
	end

	if UnitIsDeadOrGhost(unit) then
		self:SetValue(0)
		self.value:SetText(nil)
		return
	end

	local _, powerType = UnitPowerType(unit)
	local color = E:RGBToHEX(self.__owner.colors.power[powerType] or self.__owner.colors.power["FOCUS"])

	if cur < max then
		if self.__owner.isMouseOver then
			self.value:SetFormattedText("%s / |cff"..color.."%s|r", E:NumberFormat(cur), E:NumberFormat(max))
		elseif cur > 0 then
			if GetCVar("statusTextDisplay") == "PERCENT" then
				self.value:SetFormattedText("%d|cff"..color.."%%|r", E:NumberToPerc(cur, max))
			else
				self.value:SetFormattedText("|cff"..color.."%s|r", E:NumberFormat(cur))
			end
		else
			self.value:SetText(nil)
		end
	elseif self.__owner.isMouseOver then
		self.value:SetFormattedText("|cff"..color.."%s|r", E:NumberFormat(cur))
	else
		self.value:SetText(nil)
	end
end

--------------------
-- HEALPREDICTION --
--------------------

local function UpdateHealPredictionAnchor(self, orientation, appendTexture, offset)
	if orientation == "HORIZONTAL" then
		self:SetPoint('LEFT', appendTexture, 'RIGHT', offset or 0, 0)
	else
		self:SetPoint('BOTTOM', appendTexture, 'TOP', 0, offset or 0)
	end
	return self:GetStatusBarTexture()
end

function ns.PostUpdateHealPrediction(self, unit, overAbsorb, overHealAbsorb)
	local healthBar = self.__owner.Health
	local myHeals = self.myBar
	local otherHeals = self.otherBar
	local healAbsorb = self.healAbsorbBar
	local damageAbsorb = self.absorbBar
	local sbOrientation = self.myBar:GetOrientation()

	local myHealsValue = myHeals:GetValue()
	local otherHealsValue = otherHeals:GetValue()
	local healAbsorbValue = healAbsorb:GetValue()
	local damageAbsorbValue = damageAbsorb:GetValue()
	local curHealth, maxHealth = UnitHealth(unit), UnitHealthMax(unit)
	local myInitialHealAbsorb = UnitGetTotalHealAbsorbs(unit) or 0

	local appendTexture = healthBar:GetStatusBarTexture()

	local healthSize
	if sbOrientation == "HORIZONTAL" then
		healthSize = healthBar:GetWidth()
	else
		healthSize = healthBar:GetHeight()
	end

	if myHeals and myHealsValue > 0 then
		appendTexture = UpdateHealPredictionAnchor(myHeals, sbOrientation, appendTexture, -(healthSize * myInitialHealAbsorb / maxHealth))
	end
	if otherHeals and otherHealsValue > 0 then
		appendTexture = UpdateHealPredictionAnchor(otherHeals, sbOrientation, appendTexture)
	end
	if healAbsorb and healAbsorbValue > 0 then
		appendTexture = UpdateHealPredictionAnchor(healAbsorb, sbOrientation, healthBar:GetStatusBarTexture(), -(healthSize * healAbsorbValue / maxHealth))
	end
	if damageAbsorb and damageAbsorbValue > 0 then
		appendTexture = UpdateHealPredictionAnchor(damageAbsorb, sbOrientation, appendTexture)
	end
end

-------------
-- CASTBAR --
-------------

function ns.CustomTimeText(self, duration)
	if self.casting then
		self.Time:SetFormattedText("%.1f", self.max - duration)
	elseif self.channeling then
		self.Time:SetFormattedText("%.1f", duration)
	end
end

function ns.CustomDelayText(self, duration)
	if self.casting then
		if self.__owner.unit == "player" then
			self.Time:SetFormattedText("%.1f|cffe61a1a-%.1f|r", self.max - duration, self.delay)
		else
			self.Time:SetFormattedText("%.1f", self.max - duration)
		end
	elseif self.channeling then
		if self.__owner.unit == "player" then
			self.Time:SetFormattedText("%.1f|cffe61a1a+%.1f|r", duration, abs(self.delay))
		else
			self.Time:SetFormattedText("%.1f", duration)
		end
	end
end

------------
-- STRING --
------------

function ns.CreateFontString(f, font, size, outline, fsname)
	local fs = f:CreateFontString(fsname, "OVERLAY")
	fs:SetFont(font, size, outline)
	return fs
end

-----------
-- ICONS --
-----------

function ns.PvPOverride(self, event, unit)
	if(unit ~= self.unit) then return end

	local pvp = self.PvP
	local status
	local factionGroup = UnitFactionGroup(unit)

	if UnitIsPVPFreeForAll(unit) then
		pvp:SetTexCoord(42 / 128, 60 / 128, 22 / 64, 40 / 64)
		status = "FFA"
	elseif UnitIsPVP(unit) then
		if factionGroup == "Horde" then
			pvp:SetTexCoord(2 / 128, 20 / 128, 22 / 64, 40 / 64)
			status = factionGroup
		elseif factionGroup == "Alliance" then
			pvp:SetTexCoord(22 / 128, 40 / 128, 22 / 64, 40 / 64)
			status = factionGroup
		end
	end
	if status then
		pvp:Show()
	else
		pvp:Hide()
	end
end

function ns.LFDOverride(self, event)
	local lfdrole = self.LFDRole

	local role = UnitGroupRolesAssigned(self.unit)
	if role == "TANK" then
		lfdrole:SetTexCoord(62 / 128, 80 / 128, 2 / 64, 20 / 64)
		lfdrole:Show()
	elseif role == "HEALER" then
		lfdrole:SetTexCoord(42 / 128, 60 / 128, 2 / 64, 20 / 64)
		lfdrole:Show()
	elseif role == "DAMAGER" then
		lfdrole:SetTexCoord(22 / 128, 40 / 128, 2 / 64, 20 / 64)
		lfdrole:Show()
	else
		lfdrole:Hide()
	end
end

------------
-- THREAT --
------------

function ns.ThreatUpdateOverride (self, event, unit)
	if(unit ~= self.unit) then return end
	if not self:IsEventRegistered("UNIT_THREAT_LIST_UPDATE") and (self.unit == "target" or self.unit == "focus" or string.sub(self.unit, 1, 4) == "boss") then
		self:RegisterEvent("UNIT_THREAT_LIST_UPDATE", ns.ThreatUpdateOverride)
	end
	local threat = self.Threat
	local status
	if UnitPlayerControlled(unit) then
		status = UnitThreatSituation(unit)
	else
		status = UnitThreatSituation("player", unit)
	end

	local r, g, b
	if(status and status > 0) then
		r, g, b = GetThreatStatusColor(status)
		threat:SetVertexColor(r, g, b)
		threat:Show()
	else
		threat:Hide()
	end
end

-----------------------
-- OBJECTIVE TRACKER --
-----------------------

function ns.lsOTDragHeader_Initialize()
	local OT_LOCKED = ns.C.objectivetracker.locked

	local OTDragHeader = CreateFrame("BUTTON", "lsObjectiveTrackerDragHeader", ObjectiveTrackerFrame)
	OTDragHeader:SetFrameStrata(ObjectiveTrackerBlocksFrame.QuestHeader:GetFrameStrata())
	OTDragHeader:SetFrameLevel(ObjectiveTrackerBlocksFrame.QuestHeader:GetFrameLevel() + 1)
	OTDragHeader:SetSize(235, 25)
	OTDragHeader:SetPoint("TOP", -10, 0)
	OTDragHeader:RegisterForClicks("RightButtonUp")
	OTDragHeader:RegisterForDrag("LeftButton")

	OTDragHeader:SetScript("OnDragStart", function(self)
		if not OT_LOCKED then
			local frame = self:GetParent()
			frame:StartMoving()
		end
	end)

	OTDragHeader:SetScript("OnDragStop", function(self)
		if not OT_LOCKED then
			local frame = self:GetParent()
			frame:StopMovingOrSizing()

			local point, _, relativePoint, xOfs, yOfs = frame:GetPoint()
			ns.C.objectivetracker.point = {point, "UIParent", relativePoint, xOfs, yOfs}
		end
	end)

	local function OTHeaderDragToggle()
		OT_LOCKED = not OT_LOCKED
		ns.C.objectivetracker.locked = OT_LOCKED
	end

	local function OTDropDown_Initialize(self)
		local info = UIDropDownMenu_CreateInfo()
		info = UIDropDownMenu_CreateInfo()
		info.notCheckable = 1
		info.text = OT_LOCKED and UNLOCK_FRAME or LOCK_FRAME
		info.func = OTHeaderDragToggle
		UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL)
	end

	local OTDropDown = CreateFrame("Frame", "ObjectiveTrackerDragHeaderDropDown", UIParent, "UIDropDownMenuTemplate")
	UIDropDownMenu_Initialize(OTDropDown, OTDropDown_Initialize, "MENU")

	OTDragHeader:SetScript("OnClick", function(...) ToggleDropDownMenu(1, nil, OTDropDown, "cursor", 2, -2) end)

	ObjectiveTrackerFrame:SetMovable(1)
	ObjectiveTrackerFrame:ClearAllPoints()
	ObjectiveTrackerFrame.ClearAllPoints = function() return end
	ObjectiveTrackerFrame:SetPoint(unpack(ns.C.objectivetracker.point))
	ObjectiveTrackerFrame.SetPoint = function() return end
	ObjectiveTrackerFrame:SetHeight(ns.E.height * 0.6)
end
