local _, ns = ...
local oUF = ns.oUF or oUF
local cfg = ns.cfg
local glcolors = cfg.globals.colors
local L = ns.L

-----------
-- UTILS --
-----------
function ns.numFormat(v, nomod)
	if nomod == true then 
		if abs(v) >= 1E6 then
			return ("%.0fM"):format(v / 1E6)
		elseif abs(v) >= 1E4 then
			return ("%.0fK"):format(v / 1E3)
		else
			return v
		end
	else
		if abs(v) >= 1E6 then
			return ("%.1fM"):format(v / 1E6)
		elseif abs(v) >= 1E4 then
			return ("%.1fK"):format(v / 1E3)
		else
			return v
		end
	end

end

function ns.percFormat(v1, v2)
	return ("%.1f"):format((v1 / v2) * 100)
end

function ns.timeFormat(s)
	if s >= 86400 then
		return ("%dd"):format(floor(s / 86400 + 0.5))
	elseif s >= 3600 then
		return ("%dh"):format(floor(s / 3600 + 0.5))
	elseif s >= 60 then
		return ("%dm"):format(floor(s / 60 + 0.5))
	elseif s >= 1 then
		return ("%d"):format(math.fmod(s, 60))
	end
	return format("%.1f", s)
end

function ns.UnitFrame_OnEnter(self)
	if self.__owner then
		self = self.__owner
	end
	UnitFrame_OnEnter(self)

	if strsub(self:GetName(), 1, -2) == "oUF_LSPartyUnitButton" then
		PartyMemberBuffTooltip:SetPoint("TOPLEFT", self, "BOTTOMRIGHT", -10, 10)
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

	if strsub(self:GetName(), 1, -2) == "oUF_LSPartyUnitButton" then
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

function ns.menu (self)
	local unit = strsub(self.unit, 1, -2)
	if unit == "party" or unit == "partypet" then
		ToggleDropDownMenu(1, nil, _G["PartyMemberFrame" .. self.id .. "DropDown"], "cursor", 0, 0)
	else
		local cunit = gsub(self.unit, "^%l", string.upper)
		if cunit == "Vehicle" then
			cunit = "Pet"
		end
		if _G[cunit .. "FrameDropDown"] then
			ToggleDropDownMenu(1, nil, _G[cunit .. "FrameDropDown"], "cursor", 0, 0)
		end
	end
end

do
	for v, k in pairs(UnitPopupMenus) do
		for i = #k, 1, -1 do
			local n = k[i]
			if n == "SET_FOCUS" or n == "CLEAR_FOCUS" or n:match("^LOCK_%u+_FRAME$") or n:match("^UNLOCK_%u+_FRAME$") or n:match("^MOVE_%u+_FRAME$") or n:match("^RESET_%u+_FRAME_POSITION$") or n:match("^LARGE_%u+$") then
				tremove(k, i)
			end
		end
	end
end

function ns.InitUnitFrameParameters(self, config)
	self:SetFrameStrata("BACKGROUND")
	self:SetFrameLevel(1)
	self:SetSize(config.size)
	self:SetScale(cfg.globals.scale)
	self.menu = ns.menu
	self:RegisterForClicks("AnyUp")
	self:HookScript("OnEnter", ns.UnitFrame_OnEnter)
	self:HookScript("OnLeave", ns.UnitFrame_OnLeave)
end

function ns.CreateButtonBackdrop(button)
	button.bg = CreateFrame("Frame", nil, button)
	button.bg:SetAllPoints(button)
	button.bg:SetPoint("TOPLEFT", button, "TOPLEFT", -4, 4)
	button.bg:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 4, -4)
	button.bg:SetFrameLevel(button:GetFrameLevel()-1)
	button.bg:SetBackdrop(cfg.globals.backdrop)
	button.bg:SetBackdropBorderColor(0, 0, 0, .9)
end

function ns.NormalTextureVertexColor(nt, r, g, b, a)
	if nt then
		local self = nt:GetParent()
		nt = self.NewBorder
		local action = self.action
		if r == 1 and g == 1 and b == 1 and action and IsEquippedAction(action) then
			nt:SetVertexColor(unpack(glcolors.btnstate.equiped))
		else
			nt:SetVertexColor(unpack(glcolors.btnstate.normal))
		end	
	end 
end

do
	oUF.colors.health = glcolors.health.normal
	oUF.colors.reaction = glcolors.reaction
	oUF.colors.power = glcolors.power
end

-----------------
-- BUFF/DEBUFF --
-----------------
function ns.CreateBuff (self)
	local bar = CreateFrame("Frame", nil, self)
	-- bar.tex = bar:CreateTexture(nil, "BACKGROUND",nil,-8)
	-- bar.tex:SetAllPoints(bar)
	-- bar.tex:SetTexture(0.6, 1, 0, 0.4)
	local point, relativePoint, x, y = unpack(self.cfg.auras.buffs.pos)
	bar:SetPoint(point, self, relativePoint, x, y)
	bar:SetWidth(self.cfg.auras.size * self.cfg.auras.buffs.columns + self.cfg.auras.spacing * (self.cfg.auras.buffs.columns - 1))
	bar:SetHeight(self.cfg.auras.size * self.cfg.auras.buffs.rows + self.cfg.auras.spacing * (self.cfg.auras.buffs.rows - 1))
	bar["growth-x"] = self.cfg.auras.buffs.growthx
	bar["growth-y"] = self.cfg.auras.buffs.growthy
	bar["initialAnchor"] = self.cfg.auras.buffs.initialAnchor
	bar["num"] = self.cfg.auras.buffs.num
	bar["size"] = self.cfg.auras.size
	bar["spacing-x"] = self.cfg.auras.spacing
	bar["spacing-y"] = self.cfg.auras.spacing
	bar.onlyShowPlayer = self.cfg.auras.onlyShowPlayerBuffs or false
	bar.showStealableBuffs = self.cfg.auras.showStealableBuffs or false
	return bar
end

function ns.CreateDebuff (self)
	local bar = CreateFrame("Frame", nil, self)
	-- bar.tex = bar:CreateTexture(nil, "BACKGROUND",nil,-8)
	-- bar.tex:SetAllPoints(bar)
	-- bar.tex:SetTexture(0.6, 1, 0, 0.4)
	local point, relativePoint, x, y = unpack(self.cfg.auras.debuffs.pos)
	bar:SetPoint(point, self, relativePoint, x, y)
	bar:SetWidth(self.cfg.auras.size * self.cfg.auras.debuffs.columns + self.cfg.auras.spacing * (self.cfg.auras.debuffs.columns - 1))
	bar:SetHeight(self.cfg.auras.size * self.cfg.auras.debuffs.rows + self.cfg.auras.spacing * (self.cfg.auras.debuffs.rows - 1))
	bar["growth-x"] = self.cfg.auras.debuffs.growthx
	bar["growth-y"] = self.cfg.auras.debuffs.growthy
	bar["initialAnchor"] = self.cfg.auras.debuffs.initialAnchor
	bar["num"] = self.cfg.auras.debuffs.num
	bar["showType"] = self.cfg.auras.showDebuffType or false
	bar["size"] = self.cfg.auras.size
	bar["spacing-x"] = self.cfg.auras.spacing
	bar["spacing-y"] = self.cfg.auras.spacing
	bar.onlyShowPlayer = self.cfg.auras.onlyShowPlayerDebuffs or false
	return bar
end

function ns.CreateAuraIcon (self, button)
	local bw = button:GetWidth()

	button.cd:SetReverse()
	button.cd:SetPoint("TOPLEFT", 2, -2)
	button.cd:SetPoint("BOTTOMRIGHT", -2, 2)

	button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	button.icon:SetDrawLayer("BACKGROUND",-8)

	button.count:ClearAllPoints()
	button.count:SetPoint("TOPRIGHT", button, "TOPRIGHT", 4, 4)
	button.count:SetFont(cfg.font, 12, "THINOUTLINE")

	button.overlay:SetTexture(cfg.globals.textures.button_normal)
	button.overlay:SetTexCoord(0, 1, 0, 1)
	button.overlay:SetAllPoints(button)
	button.overlay:SetVertexColor(unpack(glcolors.btnstate.normal))
	button.overlay:SetDrawLayer("BACKGROUND",-7)
	button.overlay:Show()
	hooksecurefunc(button.overlay, "Hide", function(self) self:Show() end)

	button.stealable:SetTexture(cfg.globals.textures.button_normal)
	button.stealable:SetTexCoord(0,1,0,1)
	button.stealable:SetAllPoints(button)
	button.stealable:SetVertexColor(1.0, 0.82, 0.0)

	button.timer = ns.CreateFontString(button, cfg.font, 12, "THINOUTLINE")
	button.timer:SetPoint("BOTTOM", button, "BOTTOM", 1, 0)
	if not button.bg then ns.CreateButtonBackdrop(button) end
end

function ns.UpdateAuraIcon(self, unit, icon, index, offset)
	local _, _, _, _, _, duration, expirationTime, _, stealable = UnitAura(unit, index, icon.filter)
	local texture = icon.icon

	if (icon.owner == "player" or icon.owner == "vehicle" or icon.owner == "pet") and icon.isDebuff
		or (not icon.isDebuff and (stealable or icon.owner == "player" or icon.owner == "vehicle" or icon.owner == "pet")) then
		texture:SetDesaturated(false)
		icon:SetAlpha(1)
	else
		texture:SetDesaturated(true)
		icon:SetAlpha(0.65)
	end
	if duration and duration > 0 then
		icon.timer:Show()
	else
		icon.timer:Hide()
	end
	icon.expires = expirationTime
	icon:SetScript("OnUpdate", function(self, elapsed)
		self.elapsed = (self.elapsed or 0) + elapsed
		if self.elapsed < 0.1 then return end
		self.elapsed = 0
		local timeLeft = self.expires - GetTime()
		if timeLeft <= 0 then
			self.timer:SetText(nil)
		else
			self.timer:SetText(ns.timeFormat(timeLeft))
		end
	end)
end

-- function ns.CustomDebuffFilter(...)
-- 	local icons, unit, icon, name, _, _, _, _, _, _, caster, _, _, spellID = ...
-- 	if GetCVar("showAllEnemyDebuffs") == "1" or not UnitCanAttack("player", unit) or (icons.onlyShowPlayer and icon.isPlayer) then
-- 		return true
-- 	else
-- 		local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(spellID, "ENEMY_TARGET")
-- 		if hasCustom then
-- 			return showForMySpec or (alwaysShowMine and (caster == "player" or caster == "pet" or caster == "vehicle"))
-- 		else
-- 			return icon.isPlayer or caster == "player" or caster == "pet" or caster == "vehicle"
-- 		end
-- 	end
-- end

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

----------------------
-- DEBUFF HIGHLIGHT --
----------------------

function ns.CreateDebuffHighlight(self, frametype)
	local bar
	if self.unit == "player" then
		bar = self.back:CreateTexture(nil, "BACKGROUND", nil, -8)
	else
		bar = self:CreateTexture(nil, "BACKGROUND", nil, -8)
	end
	bar:SetPoint("CENTER", 0, 0)
	if frametype == "orb" then
		bar:SetSize(256, 256)
	elseif frametype == "long" then
		bar:SetSize(512, 64)
	elseif frametype == "short" then
		bar:SetSize(256, 64)
	elseif frametype == "pet" then
		bar:SetSize(64, 256)
	end
	bar:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_"..frametype.."_debuff")
	bar:SetVertexColor(0, 0, 0, 0)
	return bar
end

------------------
-- HEALTH/POWER --
------------------

function ns.UpdateHealth(self, unit, cur, max)
	if self.lowHP then
		local perc = floor(cur / max * 100)
		if perc <= 25 and cur > 1 then
			self.lowHP:Show()
		else
			self.lowHP:Hide()
		end
	end

	if not self.value then return end

	local tUnit = unit
	if unit == "focustarget" or unit == "targettarget" then
		tUnit = select(1, gsub(tUnit, "target", "", 1))
	elseif unit:match'(party)%d?$' == "party" then
		tUnit = "party"
	end
	if not GetCVarBool(((((tUnit == "focus" or gsub(tUnit, "%d", "") == "boss") and "target") or (tUnit == "vehicle" and "player")) or tUnit).."StatusText") then self.value:SetText(nil) return end

	if not UnitIsConnected(unit) then
		local color = self.__owner.colors.disconnected
		return self.value:SetFormattedText("|cff%02x%02x%02x%s|r", color[1] * 255, color[2] * 255, color[3] * 255, PLAYER_OFFLINE)
	elseif UnitIsDeadOrGhost(unit) then
		local color = self.__owner.colors.disconnected
		local deadText
		if UnitIsPlayer(unit) then
			if UnitSex(unit) == 2 or UnitSex(unit) == 1 then 
				deadText = L["mDead"]
			elseif UnitSex(unit) == 3 then
				deadText = L["fDead"]
			end
		end
		return self.value:SetFormattedText("|cff%02x%02x%02x%s|r", color[1] * 255, color[2] * 255, color[3] * 255, deadText and deadText or DEAD)
	end

	local color = { 1, 1, 1 }

	if cur < max then
		if self.__owner.isMouseOver or not GetCVarBool("statusTextPercentage") then
			return self.value:SetFormattedText("|cff%02x%02x%02x%s|r", color[1] * 255, color[2] * 255, color[3] * 255, ns.numFormat(cur))
		else
			if GetCVarBool("statusTextPercentage") then
				return self.value:SetFormattedText("|cff%02x%02x%02x%d%%|r", color[1] * 255, color[2] * 255, color[3] * 255, ns.percFormat(cur, max))
			end
		end
	elseif self.__owner.isMouseOver then
		return self.value:SetFormattedText("|cff%02x%02x%02x%s|r", color[1] * 255, color[2] * 255, color[3] * 255, ns.numFormat(max))
	else
		return self.value:SetText(nil)
	end
end

function ns.UpdatePower(self, unit, cur, max)
	if not self.value then return end

	local tUnit = unit
	if unit == "focustarget" or unit == "targettarget" then
		tUnit = select(1, gsub(tUnit, "target", "", 1))
	elseif unit:match'(party)%d?$' == "party" then
		tUnit = "party"
	end
	if not GetCVarBool(((((tUnit == "focus" or gsub(tUnit, "%d", "") == "boss") and "target") or (tUnit == "vehicle" and "player")) or tUnit).."StatusText") then self.value:SetText(nil) return end

	if max == 0 then
		self.value:SetText(nil)
		return
	end

	if UnitIsDeadOrGhost(unit) then
		self:SetValue(0)
		if self.value then
			self.value:SetText(nil)
		end
		return
	end

	local _, powerType = UnitPowerType(unit)
	local color = self.__owner.colors.power[powerType] or self.__owner.colors.power["FOCUS"]

	if cur < max then
		if self.__owner.isMouseOver then
			self.value:SetFormattedText("%s / |cff%02x%02x%02x%s|r", ns.numFormat(cur, true), color[1] * 255, color[2] * 255, color[3] * 255, ns.numFormat(max, true))
		elseif cur > 0 then
			if not GetCVarBool("statusTextPercentage") then
				self.value:SetFormattedText("|cff%02x%02x%02x%s|r", color[1] * 255, color[2] * 255, color[3] * 255, ns.numFormat(cur, true))
			else
				self.value:SetFormattedText("%d|cff%02x%02x%02x%%|r", ns.percFormat(cur, max), color[1] * 255, color[2] * 255, color[3] * 255)
			end
		else
			self.value:SetText(nil)
		end
	elseif self.__owner.isMouseOver then
		self.value:SetFormattedText("|cff%02x%02x%02x%s|r", color[1] * 255, color[2] * 255, color[3] * 255, ns.numFormat(cur, true))
	else
		self.value:SetText(nil)
	end
end

--------------------
-- HEALPREDICTION --
--------------------

function ns.CreateHealPrediction(self)
	local bar = {}
	bar.myBar = CreateFrame('StatusBar', nil, self.Health)
	bar.myBar:SetFrameLevel(self.Health:GetFrameLevel())
	bar.myBar:SetStatusBarTexture(cfg.globals.textures.statusbar)
	bar.myBar:SetPoint("TOPLEFT", self.Health:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
	bar.myBar:SetPoint("BOTTOMLEFT", self.Health:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)
	bar.myBar:SetWidth(self.Health:GetWidth())

	bar.otherBar = CreateFrame('StatusBar', nil, self.Health)
	bar.otherBar:SetFrameLevel(self.Health:GetFrameLevel())
	bar.otherBar:SetStatusBarTexture(cfg.globals.textures.statusbar)
	bar.otherBar:SetPoint("TOPLEFT", bar.myBar:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
	bar.otherBar:SetPoint("BOTTOMLEFT", bar.myBar:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)
	bar.otherBar:SetWidth(self.Health:GetWidth())
	return bar
end

function ns.UpdateHealPrediction(self, unit)
	local r, g, b = self.__owner.Health:GetStatusBarColor()
	self.myBar:SetStatusBarColor(r * 2.4, g * 2.4, b * 2.4)
	self.otherBar:SetStatusBarColor(r * 2.4, g * 2.4, b * 2.4)
end

-------------
-- CASTBAR --
-------------

function ns.CreateCastbar(self)
	local bar = CreateFrame("StatusBar", nil, self)

	bar:SetSize((self.cfg.long or self.unit == "player") and 246 or 118, 24)
	bar:SetStatusBarTexture(cfg.globals.textures.statusbar)
	bar:SetPoint(unpack(self.cfg.castbar.pos))
	bar:SetStatusBarColor(unpack(glcolors.castbar.bar))

	bar.front = bar:CreateTexture(nil, "OVERLAY", nil, -3)
	bar.front:SetTexture("Interface\\AddOns\\oUF_LS\\media\\castbar_"..((self.cfg.long or self.unit == "player") and "long" or "short"))
	bar.front:SetSize((self.cfg.long or self.unit == "player") and 512 or 256, 64)
	bar.front:SetPoint("CENTER", 0, 0)

	bar.bg = bar:CreateTexture(nil, "BACKGROUND", nil, -6)
	bar.bg:SetTexture(unpack(glcolors.castbar.bg))
	bar.bg:SetAllPoints(bar)

	bar.Text =	ns.CreateFontString(bar, cfg.font, 12, "THINOUTLINE")
	bar.Text:SetPoint("LEFT", 15, 0)
	bar.Text:SetPoint("RIGHT", -15, 0)

	bar.Time =	ns.CreateFontString(bar, cfg.font, 12, "THINOUTLINE")
	bar.Time:SetPoint("BOTTOM", 0, -8)

	bar.Spark = bar:CreateTexture(nil, "LOW", nil, -7)
	bar.Spark:SetBlendMode("ADD")
	bar.Spark:SetVertexColor(0.8, 0.6, 0, 1)

	if self.unit == "player" and self.cfg.castbar.latency then
		bar.SafeZone = bar:CreateTexture(nil,"OVERLAY",nil,-4)
		bar.SafeZone:SetTexture(cfg.globals.textures.statusbar)
		bar.SafeZone:SetVertexColor(0.6, 0, 0, 0.6)
	end
	return bar
end

function ns.CustomTimeText(self, duration)
	if self.casting then
		self.Time:SetFormattedText("%.1f", self.max - duration)
	elseif self.channeling then
		self.Time:SetFormattedText("%.1f", duration)
	end
end

function ns.CustomDelayText(self, duration)
	if self.casting then
		self.Time:SetFormattedText("%.1f|cffe61a1a-%.1f|r", self.max - duration, self.delay)
	elseif self.channeling then
		self.Time:SetFormattedText("%.1f|cffe61a1a+%.1f|r", duration, abs(self.delay))
	end
end

function ns.CastPostUpdate(self, unit)
	if self.interrupt == true then
		self:SetStatusBarColor(0.5, 0.5, 0.5, 1)
		self.bg:SetTexture(0.8, 0.8, 0.8, 1)
	else
		self:SetStatusBarColor(unpack(glcolors.castbar.bar))
		self.bg:SetTexture(unpack(glcolors.castbar.bg))
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

function ns.CreateIcon(f, size, p, x, y, texture)
	local icon = f:CreateTexture(nil, "OVERLAY")
	icon:SetSize(size, size)
	icon:SetTexture(texture)
	icon:SetPoint(p, x, y)
	return icon
end

function ns.PvPOverride (self, event, unit)
	if(unit ~= self.unit) then return end

	local pvp = self.PvP
	local status
	local factionGroup = UnitFactionGroup(unit)

	if UnitIsPVPFreeForAll(unit) then
		pvp:SetTexture("Interface\\AddOns\\oUF_LS\\media\\icon_pvp_ffa")
		status = "FFA"
	elseif factionGroup and factionGroup ~= 'Neutral' and UnitIsPVP(unit) then
		pvp:SetTexture("Interface\\AddOns\\oUF_LS\\media\\icon_pvp_"..factionGroup:gsub("^%a", string.lower))
		status = factionGroup
	end
	if status then
		pvp:Show()
	else
		pvp:Hide()
	end
end

------------
-- THREAT --
------------

function ns.CreateThreat (self, frametype)
	local bar
	if self.unit == "player" then
		bar = self.back:CreateTexture(nil, "BACKGROUND", nil, -8)
	else
		bar = self:CreateTexture(nil, "BACKGROUND", nil, -8)
	end
	bar:SetPoint("CENTER", 0, 0)
	if frametype == "orb" then
		bar:SetSize(256, 256)
	elseif frametype == "long" then
		bar:SetSize(512, 64)
	elseif frametype == "short" then
		bar:SetSize(256, 64)
	elseif frametype == "pet" then
		bar:SetSize(64, 256)
	end
	bar:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_"..frametype.."_threat")
	return bar
end

function ns.ThreatUpdateOverride (self, event, unit)
	if not unit then return end
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
_G["WatchFrame"]:ClearAllPoints()
_G["WatchFrame"]:SetPoint("TOPRIGHT", "UIParent", "TOPRIGHT",-250, -250)
_G["WatchFrame"]:SetUserPlaced(true)
_G["WatchFrame"].ClearAllPoints = function() return end
_G["WatchFrame"].SetPoint = function() return end
_G["WatchFrame"]:SetHeight(string.match(({GetScreenResolutions()})[GetCurrentResolution()], "%d+x(%d+)")-400)
_G["WatchFrameHeader"]:EnableMouse(true)
_G["WatchFrameHeader"]:RegisterForDrag("LeftButton")
_G["WatchFrameHeader"]:SetHitRectInsets(-10, -10, -10, -10)

_G["WatchFrameHeader"]:SetScript("OnDragStart", function(s) 
	if not WATCHFRAME_LOCKED then
		local f = s:GetParent()
		f:StartMoving()
	end
end)
_G["WatchFrameHeader"]:SetScript("OnDragStop", function(s) 
	if not WATCHFRAME_LOCKED then
		local f = s:GetParent()
		f:StopMovingOrSizing()
	end
end)

local function ToggleDrag()
	WATCHFRAME_LOCKED = not WATCHFRAME_LOCKED
end

-- u can lock/unlock watchframe via dropdown menu
hooksecurefunc("ToggleDropDownMenu", function(...) 
	local level, _, dropDownFrame = ...
	if dropDownFrame == WatchFrameHeaderDropDown and _G["DropDownList"..level]:IsShown() then
		local info = UIDropDownMenu_CreateInfo()
		-- position
		info.text = L["position"]
		info.checked = false
		info.isTitle = 1
		info.notCheckable = 1
		UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL)
		-- lock/unlock 
		info = UIDropDownMenu_CreateInfo()
		info.checked = WATCHFRAME_LOCKED
		info.text = L["lockframe"]
		info.func = ToggleDrag
		UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL)
	end
end)