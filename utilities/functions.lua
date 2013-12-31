local _, ns = ...
local oUF = ns.oUF or oUF
local C, M = ns.C, ns.M

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

function ns.AlwaysShow(self)
	if not self then return end
	self:Show()
	self.Hide = self.Show 
end

function ns.AlwaysHide(self)
	if not self then return end
	self:Hide()
	self.Show = self.Hide
end

function ns.NumFormat(v, nomod)
	if nomod == true then 
		if abs(v) >= 1E6 then
			return format("%.0f"..gsub(SECOND_NUMBER_CAP, "[ ]", ""), v / 1E6)
		elseif abs(v) >= 1E4 then
			return format("%.0f"..gsub(FIRST_NUMBER_CAP, "[ ]", ""), v / 1E3)
		else
			return v
		end
	else
		if abs(v) >= 1E6 then
			return format("%.1f"..gsub(SECOND_NUMBER_CAP, "[ ]", ""), v / 1E6)
		elseif abs(v) >= 1E4 then
			return format("%.1f"..gsub(FIRST_NUMBER_CAP, "[ ]", ""), v / 1E3)
		else
			return v
		end
	end

end

function ns.PercFormat(v1, v2)
	return ("%.1f"):format((v1 / v2) * 100)
end

function ns.TimeFormat(s)
	if s >= 86400 then
		return format(gsub(DAY_ONELETTER_ABBR, "[ .]", ""), floor(s / 86400 + 0.5))
	elseif s >= 3600 then
		return format(gsub(ONELETTER_ABBR, "[ .]", ""), floor(s / 3600 + 0.5))
	elseif s >= 60 then
		return format(gsub(MINUTE_ONELETTER_ABBR, "[ .]", ""), floor(s / 60 + 0.5))
	elseif s >= 1 then
		return format(gsub(SECOND_ONELETTER_ABBR, "[ .]", ""), math.fmod(s, 60))
	end
	return format("%.1f", s)
end

function ns.UnitFrame_OnEnter(self)
	if self.__owner then
		self = self.__owner
	end

	UnitFrame_OnEnter(self)

	local frameName = gsub(self:GetName(), "%d", "")
	if frameName == "oUF_LSPartyFrameUnitButton" then
		PartyMemberBuffTooltip:ClearAllPoints()
		PartyMemberBuffTooltip:SetPoint("TOPLEFT", self, "BOTTOMRIGHT", -10, 10)
		PartyMemberBuffTooltip_Update(self)
	elseif frameName == "oUF_LSPetFrame" then
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
	if frameName == "oUF_LSPartyFrameUnitButton" then
		PartyMemberBuffTooltip:Hide()
	elseif frameName == "oUF_LSPetFrame" then
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

function ns.CreateButtonBorder(button, borderType, curTexture)
	local texture = curTexture or button:CreateTexture(nil, "BORDER", nil, 0)
	if borderType == 0 then
		texture:SetTexture(M.textures.button.normalstone)
	elseif borderType == 1 then
		texture:SetTexture(M.textures.button.normalmetal)
	end
	texture:SetTexCoord(14 / 64, 50 / 64, 14 / 64, 50 / 64)
	texture:ClearAllPoints()
	texture:SetPoint("TOPLEFT", button, "TOPLEFT", -3, 3)
	texture:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 3, -3)
	return texture
end

function ns.SetIconStyle(self, icon)
	icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	icon:SetDrawLayer("BACKGROUND", 0)
	icon:ClearAllPoints()
	icon:SetPoint("TOPLEFT", self, "TOPLEFT", 2, -2)
	icon:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, 2)
end

function ns.SetHighlightTexture(self)
	self:SetHighlightTexture(M.textures.button.highlight)
	self:GetHighlightTexture():SetTexCoord(17 / 64, 47 / 64, 17 / 64, 47 / 64)
	self:GetHighlightTexture():ClearAllPoints()
	self:GetHighlightTexture():SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
	self:GetHighlightTexture():SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
end

function ns.SetPushedTexture(self)
	self:SetPushedTexture(M.textures.button.pushedchecked)
	self:GetPushedTexture():SetTexCoord(17 / 64, 47 / 64, 17 / 64, 47 / 64)
	self:GetPushedTexture():ClearAllPoints()
	self:GetPushedTexture():SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
	self:GetPushedTexture():SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
end

function ns.SetCheckedTexture(self)
	self:SetCheckedTexture(M.textures.button.pushedchecked)
	self:GetCheckedTexture():SetTexCoord(17 / 64, 47 / 64, 17 / 64, 47 / 64)
	self:GetCheckedTexture():ClearAllPoints()
	self:GetCheckedTexture():SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
	self:GetCheckedTexture():SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
end


function ns.CreateGlowAnimation(self, change, duration, loopType)
	self.animation = self:CreateAnimationGroup()
	self.animation:SetLooping(loopType or "BOUNCE")
	local glowAnimation = self.animation:CreateAnimation("ALPHA")
	glowAnimation:SetDuration(duration or 1)
	glowAnimation:SetChange(change)
end

do
	oUF.colors.health = M.colors.health

	for r, data in pairs(M.colors.reaction) do
		oUF.colors.reaction[r] = data
	end

	for p, data in pairs(M.colors.power) do
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

function ns.CreateAuraIcon (self, button)
	button.cd:SetReverse()
	button.cd:SetPoint("TOPLEFT", 2, -2)
	button.cd:SetPoint("BOTTOMRIGHT", -2, 2)

	button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	button.icon:SetDrawLayer("BACKGROUND", -8)

	button.overlay:SetTexture(M.textures.button.normalstone)
	button.overlay:ClearAllPoints()
	button.overlay:SetTexCoord(14 / 64, 50 / 64, 14 / 64, 50 / 64)
	button.overlay:SetPoint("TOPLEFT", button, "TOPLEFT", -3, 3)
	button.overlay:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 3, -3)
	button.overlay:SetVertexColor(0.57, 0.52, 0.55)
	button.overlay:SetDrawLayer("BACKGROUND", -7)
	ns.AlwaysShow(button.overlay)

	button.stealable:SetTexture(M.textures.button.normalstone)
	button.stealable:SetDrawLayer("OVERLAY", 1)
	button.stealable:ClearAllPoints()
	button.stealable:SetSize(28, 28)
	button.stealable:SetTexCoord(14 / 64, 50 / 64, 14 / 64, 50 / 64)
	button.stealable:SetPoint("CENTER", 0, 0)
	button.stealable:SetVertexColor(1.0, 0.82, 0.0)

	button.fg = CreateFrame("Frame", nil, button)
	button.fg:SetAllPoints(button)
	button.fg:SetFrameLevel(5)

	button.timer = ns.CreateFontString(button.fg, M.font, 12, "THINOUTLINE")
	button.timer:SetPoint("BOTTOM", button.fg, "BOTTOM", 1, 0)

	button.count:ClearAllPoints()
	button.count:SetPoint("TOPRIGHT", button.fg, "TOPRIGHT", 4, 4)
	button.count:SetFont(M.font, 12, "THINOUTLINE")
end

function ns.UpdateAuraIcon(self, unit, icon, index, offset)
	local _, _, _, _, _, duration, expirationTime, _, stealable = UnitAura(unit, index, icon.filter)
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
				self.timer:SetText(ns.TimeFormat(timeLeft))
			else
				self.timer:SetText(nil)
			end
		end)
	else
		icon.timer:Hide()
		icon:SetScript("OnUpdate", nil)
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

	if not UnitIsConnected(unit) then
		local color = self.__owner.colors.disconnected
		return self.value:SetFormattedText("|cff%02x%02x%02x%s|r", color[1] * 255, color[2] * 255, color[3] * 255, PLAYER_OFFLINE)
	elseif UnitIsDeadOrGhost(unit) then
		local color = self.__owner.colors.disconnected
		local deadText
		if UnitIsPlayer(unit) and unit == "player" then
			if UnitSex(unit) == 2 or UnitSex(unit) == 1 then 
				deadText = gsub(SPELL_FAILED_CASTER_DEAD, "[.]", "")
			elseif UnitSex(unit) == 3 then
				deadText = gsub(SPELL_FAILED_CASTER_DEAD_FEMALE, "[.]", "")
			end
		end
		return self.value:SetFormattedText("|cff%02x%02x%02x%s|r", color[1] * 255, color[2] * 255, color[3] * 255, deadText and deadText or DEAD)
	end

	local color = { 1, 1, 1 }

	if cur < max then
		if self.__owner.isMouseOver then
			return self.value:SetFormattedText("|cff%02x%02x%02x%s|r", color[1] * 255, color[2] * 255, color[3] * 255, ns.NumFormat(cur))
		else
			if GetCVar("statusTextDisplay") == "PERCENT" then
				return self.value:SetFormattedText("|cff%02x%02x%02x%d%%|r", color[1] * 255, color[2] * 255, color[3] * 255, ns.PercFormat(cur, max))
			else 
				self.value:SetFormattedText("|cff%02x%02x%02x%s|r", color[1] * 255, color[2] * 255, color[3] * 255, ns.NumFormat(cur))
			end
		end
	elseif self.__owner.isMouseOver then
		return self.value:SetFormattedText("|cff%02x%02x%02x%s|r", color[1] * 255, color[2] * 255, color[3] * 255, ns.NumFormat(max))
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
	realUnit = self.__owner:GetAttribute("oUF-guessUnit") or unit
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
	local color = self.__owner.colors.power[powerType] or self.__owner.colors.power["FOCUS"]

	if cur < max then
		if self.__owner.isMouseOver then
			self.value:SetFormattedText("%s / |cff%02x%02x%02x%s|r", ns.NumFormat(cur, true), color[1] * 255, color[2] * 255, color[3] * 255, ns.NumFormat(max, true))
		elseif cur > 0 then
			if GetCVar("statusTextDisplay") == "PERCENT" then
				self.value:SetFormattedText("%d|cff%02x%02x%02x%%|r", ns.PercFormat(cur, max), color[1] * 255, color[2] * 255, color[3] * 255)
			else
				self.value:SetFormattedText("|cff%02x%02x%02x%s|r", color[1] * 255, color[2] * 255, color[3] * 255, ns.NumFormat(cur, true))
			end
		else
			self.value:SetText(nil)
		end
	elseif self.__owner.isMouseOver then
		self.value:SetFormattedText("|cff%02x%02x%02x%s|r", color[1] * 255, color[2] * 255, color[3] * 255, ns.NumFormat(cur, true))
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

----------------
-- WATCHFRAME --
----------------

local WATCHFRAME_LOCKED = true

_G["WatchFrame"]:SetMovable(1)
-- _G["WatchFrame"]:ClearAllPoints()
-- _G["WatchFrame"].ClearAllPoints = function() return end
-- _G["WatchFrame"]:SetPoint("TOPRIGHT", "UIParent", "TOPRIGHT",-250, -250)
-- _G["WatchFrame"].SetPoint = function() return end
_G["WatchFrame"]:SetUserPlaced(true)
_G["WatchFrame"]:SetHeight(C.height / 2)
_G["WatchFrameHeader"]:EnableMouse(true)
_G["WatchFrameHeader"]:RegisterForDrag("LeftButton")
_G["WatchFrameHeader"]:SetHitRectInsets(-10, -10, -10, -10)

_G["WatchFrameHeader"]:SetScript("OnDragStart", function(self) 
	if not WATCHFRAME_LOCKED then
		local frame = self:GetParent()
		frame:StartMoving()
	end
end)
_G["WatchFrameHeader"]:SetScript("OnDragStop", function(self) 
	if not WATCHFRAME_LOCKED then
		local frame = self:GetParent()
		frame:StopMovingOrSizing()
	end
end)

local function ToggleDrag()
	WATCHFRAME_LOCKED = not WATCHFRAME_LOCKED
end

hooksecurefunc("ToggleDropDownMenu", function(...) 
	local level, _, dropDownFrame = ...
	if dropDownFrame == WatchFrameHeaderDropDown and _G["DropDownList"..level]:IsShown() then
		local info = UIDropDownMenu_CreateInfo()
		-- lock/unlock 
		info = UIDropDownMenu_CreateInfo()
		info.notCheckable = 1
		info.text = WATCHFRAME_LOCKED and UNLOCK_FRAME or LOCK_FRAME
		info.func = ToggleDrag
		UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL)
	end
end)