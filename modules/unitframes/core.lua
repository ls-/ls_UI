local _, ns = ...
local E, C, M, L, P, oUF = ns.E, ns.C, ns.M, ns.L, ns.P, ns.oUF
local UF = P:AddModule("UnitFrames")

-- Lua
local _G = getfenv(0)
local string = _G.string
local unpack = _G.unpack

-- Mine
local isInit = false
local objects = {}
local units = {}

local function LSUnitFrame_OnEnter(self)
	if self.__owner then
		self = self.__owner
	end

	_G.UnitFrame_OnEnter(self)

	if string.match(self:GetName(), "LSPetFrame") then
		_G.PartyMemberBuffTooltip:ClearAllPoints()
		_G.PartyMemberBuffTooltip:SetPoint("BOTTOMRIGHT", self, "TOPLEFT", 4, -4)
		_G.PartyMemberBuffTooltip_Update(self)
	end
end

local function LSUnitFrame_OnLeave(self)
	if self.__owner then
		self = self.__owner
	end

	_G.UnitFrame_OnLeave(self)

	if string.match(self:GetName(), "LSPetFrame") then
		_G.PartyMemberBuffTooltip:Hide()
	end
end

local function Style(frame, unit)
	frame:RegisterForClicks("AnyUp")
	frame:SetScript("OnEnter", LSUnitFrame_OnEnter)
	frame:SetScript("OnLeave", LSUnitFrame_OnLeave)

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
end

local function MainConstructor()
	oUF:RegisterStyle("LS", Style)
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

function UF:CreateUnitFrame(unit)
	if unit == "player" and not objects["player"] then
		objects["player"] = oUF:Spawn("player", "LSPlayerFrame")
		objects["player"].Update = function(self)
			UF:UpdatePlayerFrame(self)
		end

		objects["player"]:SetPoint(unpack(C.db.profile.units[E.UI_LAYOUT].player.point))
		E:CreateMover(objects["player"])

		objects["pet"] = oUF:Spawn("pet", "LSPetFrame")
		objects["pet"].Update = function(self)
			UF:UpdatePetFrame(self)
		end

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

		objects["target"]:SetPoint(unpack(C.db.profile.units[E.UI_LAYOUT].target.point))
		E:CreateMover(objects["target"])

		objects["targettarget"] = oUF:Spawn("targettarget", "LSTargetTargetFrame")
		objects["targettarget"].Update = function(self)
			UF:UpdateTargetTargetFrame(self)
		end

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

		objects["focus"]:SetPoint(unpack(C.db.profile.units[E.UI_LAYOUT].focus.point))
		E:CreateMover(objects["focus"])

		objects["focustarget"] = oUF:Spawn("focustarget", "LSFocusTargetFrame")
		objects["focustarget"].Update = function(self)
			UF:UpdateFocusTargetFrame(self)
		end

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
		oUF:Factory(MainConstructor)

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
