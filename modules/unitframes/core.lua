local _, ns = ...
local E, C, M, L, P, oUF = ns.E, ns.C, ns.M, ns.L, ns.P, ns.oUF
local UF = P:AddModule("UnitFrames")

-- Lua
local _G = getfenv(0)
local unpack = _G.unpack

--[[ luacheck: globals
UnitFrame_OnEnter
PartyMemberBuffTooltip
PartyMemberBuffTooltip_Update
UnitFrame_OnLeave
]]

-- Mine
local isInit = false
local objects = {}
local units = {}

local function frame_OnEnter(self)
	self = self.__owner or self

	UnitFrame_OnEnter(self)

	if self:GetName() == "LSPetFrame" then
		PartyMemberBuffTooltip:ClearAllPoints()
		PartyMemberBuffTooltip:SetPoint("BOTTOMRIGHT", self, "TOPLEFT", 4, -4)
		PartyMemberBuffTooltip_Update(self)
	end
end

local function frame_OnLeave(self)
	self = self.__owner or self

	UnitFrame_OnLeave(self)
	PartyMemberBuffTooltip:Hide()
end

local function constructor()
	oUF:RegisterStyle("LS", function(frame, unit)
		frame:RegisterForClicks("AnyUp")
		frame:SetScript("OnEnter", frame_OnEnter)
		frame:SetScript("OnLeave", frame_OnLeave)

		if unit == "player" then
			if E.UI_LAYOUT == "ls" then
				UF:CreateVerticalPlayerFrame(frame)
			else
				UF:CreateHorizontalPlayerFrame(frame)
			end
		elseif unit == "pet" then
			if E.UI_LAYOUT == "ls" then
				UF:CreateVerticalPetFrame(frame)
			else
				UF:CreateHorizontalPetFrame(frame)
			end
		elseif unit == "target" then
			UF:CreateTargetFrame(frame)
		elseif unit == "targettarget" then
			UF:CreateTargetTargetFrame(frame)
		elseif unit == "focus" then
			UF:CreateFocusFrame(frame)
		elseif unit == "focustarget" then
			UF:CreateFocusTargetFrame(frame)
		elseif unit == "boss1" then
			UF:CreateBossFrame(frame)
		elseif unit == "boss2" then
			UF:CreateBossFrame(frame)
		elseif unit == "boss3" then
			UF:CreateBossFrame(frame)
		elseif unit == "boss4" then
			UF:CreateBossFrame(frame)
		elseif unit == "boss5" then
			UF:CreateBossFrame(frame)
		end
	end)
	oUF:SetActiveStyle("LS")

	if C.db.profile.units[E.UI_LAYOUT].player.enabled then
		UF:CreateUnitFrame("player")
		UF:UpdateUnitFrame("player")
		UF:UpdateUnitFrame("pet")
	end

	if C.db.profile.units[E.UI_LAYOUT].target.enabled then
		UF:CreateUnitFrame("target")
		UF:UpdateUnitFrame("target")
		UF:UpdateUnitFrame("targettarget")
	end

	if C.db.profile.units[E.UI_LAYOUT].focus.enabled then
		UF:CreateUnitFrame("focus")
		UF:UpdateUnitFrame("focus")
		UF:UpdateUnitFrame("focustarget")
	end

	if C.db.profile.units[E.UI_LAYOUT].boss.enabled then
		UF:CreateUnitFrame("boss")
		UF:UpdateUnitFrame("boss")
	end
end

local function frame_Preview(self, state)
	if not self.isPreviewed or state == true then
		if not self.isPreviewed then
			self.oldUnit = self.unit
			self.unit = "player"
			self.oldOnUpdate = self:GetScript("OnUpdate")
			self.isPreviewed = true
		end

		UnregisterUnitWatch(self)
		RegisterUnitWatch(self, true)

		self:SetScript("OnUpdate", nil)
		self:Show()

		if self:IsVisible() and self.Update then
			self:Update()
		end
	elseif self.isPreviewed or state == false then
		self.unit = self.oldUnit or self.unit
		self.isPreviewed = nil

		UnregisterUnitWatch(self)
		RegisterUnitWatch(self)

		if self.oldOnUpdate then
			self:SetScript("OnUpdate", self.oldOnUpdate)
			self.oldOnUpdate = nil
		end

		if self:IsVisible() and self.Update then
			self:Update()
		end
	end
end

function UF:CreateUnitFrame(unit)
	if unit == "player" and not objects["player"] then
		objects["player"] = oUF:Spawn("player", "LSPlayerFrame")
		objects["player"].Update = function(self)
			UF:UpdatePlayerFrame(self)
		end
		objects["player"].Preview = frame_Preview

		objects["player"]:SetPoint(unpack(C.db.profile.units[E.UI_LAYOUT].player.point))
		E:CreateMover(objects["player"])

		objects["pet"] = oUF:Spawn("pet", "LSPetFrame")
		objects["pet"].Update = function(self)
			UF:UpdatePetFrame(self)
		end
		objects["pet"].Preview = frame_Preview

		objects["pet"]:SetPoint(unpack(C.db.profile.units[E.UI_LAYOUT].pet.point))
		E:CreateMover(objects["pet"])

		units["player"] = true
		units["pet"] = true

		return true
	elseif unit == "target" and not objects["target"] then
		objects["target"] = oUF:Spawn("target", "LSTargetFrame")
		objects["target"].Update = function(self)
			UF:UpdateTargetFrame(self)
		end
		objects["target"].Preview = frame_Preview

		objects["target"]:SetPoint(unpack(C.db.profile.units[E.UI_LAYOUT].target.point))
		E:CreateMover(objects["target"])

		objects["targettarget"] = oUF:Spawn("targettarget", "LSTargetTargetFrame")
		objects["targettarget"].Update = function(self)
			UF:UpdateTargetTargetFrame(self)
		end
		objects["targettarget"].Preview = frame_Preview

		objects["targettarget"]:SetPoint(unpack(C.db.profile.units[E.UI_LAYOUT].targettarget.point))
		E:CreateMover(objects["targettarget"])

		units["target"] = true
		units["targettarget"] = true

		return true
	elseif unit == "focus" and not objects["focus"] then
		objects["focus"] = oUF:Spawn("focus", "LSFocusFrame")
		objects["focus"].Update = function(self)
			UF:UpdateFocusFrame(self)
		end
		objects["focus"].Preview = frame_Preview

		objects["focus"]:SetPoint(unpack(C.db.profile.units[E.UI_LAYOUT].focus.point))
		E:CreateMover(objects["focus"])

		objects["focustarget"] = oUF:Spawn("focustarget", "LSFocusTargetFrame")
		objects["focustarget"].Update = function(self)
			UF:UpdateFocusTargetFrame(self)
		end
		objects["focustarget"].Preview = frame_Preview

		objects["focustarget"]:SetPoint(unpack(C.db.profile.units[E.UI_LAYOUT].focustarget.point))
		E:CreateMover(objects["focustarget"])

		units["focus"] = true
		units["focustarget"] = true

		return true
	elseif unit == "boss" and not objects["boss1"] then
		local holder = self:CreateBossHolder()

		for i = 1, 5 do
			objects["boss"..i] = oUF:Spawn("boss"..i, "LSBoss"..i.."Frame")
			objects["boss"..i].Update = function(self)
				UF:UpdateBossFrame(self)
			end
			objects["boss"..i].Preview = frame_Preview
			objects["boss"..i]._parent = holder

			holder._buttons[i] = objects["boss"..i]
		end

		units["boss"] = true

		return true
	end
end

function UF:UpdateUnitFrame(unit)
	if unit == "boss" and objects["boss1"] then
		for i = 1, 5 do
			objects["boss"..i]:Update()
		end

		UF:UpdateBossHolder()

		return true
	elseif objects[unit] then
		objects[unit]:Update()
		E:UpdateMoverSize(objects[unit])

		return true
	end
end

function UF:GetUnits(removeUnits)
	local temp = {}

	for unit in next, units do
		if not removeUnits or not removeUnits[unit] then
			temp[unit] = unit
		end
	end

	return temp
end

function UF:GetUnitFrameForUnit(unit)
	if unit == "boss" then
		return objects["boss1"]
	else
		return objects[unit]
	end
end

function UF:IsInit()
	return isInit
end

function UF:Init()
	if not isInit and C.db.char.units.enabled then
		oUF:Factory(constructor)

		isInit = true
	end
end

function UF:Update()
	if isInit then
		for unit in next, units do
			self:UpdateUnitFrame(unit)
		end
	end
end
