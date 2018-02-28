local _, ns = ...
local E, C, M, L, P, oUF = ns.E, ns.C, ns.M, ns.L, ns.P, ns.oUF
local UF = P:AddModule("UnitFrames")

-- Lua
local _G = getfenv(0)
local next = _G.next
local unpack = _G.unpack

--[[ luacheck: globals
	PartyMemberBuffTooltip
	PartyMemberBuffTooltip_Update
	RegisterUnitWatch
	UnitFrame_OnEnter
	UnitFrame_OnLeave
	UnregisterUnitWatch
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

local function frame_UpdateConfig(self)
	self._config = C.db.profile.units[E.UI_LAYOUT][self._unit]
end

local function frame_UpdateSize(self)
	self:SetSize(self._config.width, self._config.height)
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

		if self:IsVisible() then
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

		if self:IsVisible() then
			self:Update()
		end
	end
end

function UF:CreateUnitFrame(unit, name)
	if not units[unit] then
		if unit == "boss" then
			local holder = self:CreateBossHolder()

			for i = 1, 5 do
				local object = oUF:Spawn(unit..i, name..i.."Frame")
				object.UpdateConfig = frame_UpdateConfig
				object.UpdateSize = frame_UpdateSize
				object.Preview = frame_Preview
				objects[unit..i] = object

				object._parent = holder
				holder._buttons[i] = object
			end
		else
			local object = oUF:Spawn(unit, name.."Frame")
			object.UpdateConfig = frame_UpdateConfig
			object.UpdateSize = frame_UpdateSize
			object.Preview = frame_Preview
			objects[unit] = object

			object:SetPoint(unpack(C.db.profile.units[E.UI_LAYOUT][unit].point))
			E:CreateMover(object)
		end

		units[unit] = true
	end
end

function UF:UpdateUnitFrame(unit, method)
	if units[unit] then
		if unit == "boss" then
			if method then
				for i = 1, 5 do
					if objects[unit..i][method] then
						objects[unit..i][method](objects[unit..i])
					end
				end
			else
				for i = 1, 5 do
					objects["boss"..i]:Update()
				end

				UF:UpdateBossHolder()
			end
		elseif objects[unit] then
			if method then
				if objects[unit][method] then
					objects[unit][method](objects[unit])
				end
			else
				objects[unit]:Update()
			end
		end
	end
end

function UF:GetUnits(ignoredUnits)
	local temp = {}

	for unit in next, units do
		if not ignoredUnits or not ignoredUnits[unit] then
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
		oUF:Factory(function()
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

			if C.db.char.units.player.enabled then
				UF:CreateUnitFrame("player", "LSPlayer")
				UF:UpdateUnitFrame("player")
				UF:CreateUnitFrame("pet", "LSPet")
				UF:UpdateUnitFrame("pet")
			end

			if C.db.char.units.target.enabled then
				UF:CreateUnitFrame("target", "LSTarget")
				UF:UpdateUnitFrame("target")
				UF:CreateUnitFrame("targettarget", "LSTargetTarget")
				UF:UpdateUnitFrame("targettarget")
			end

			if C.db.char.units.focus.enabled then
				UF:CreateUnitFrame("focus", "LSFocus")
				UF:UpdateUnitFrame("focus")
				UF:CreateUnitFrame("focustarget", "LSFocusTarget")
				UF:UpdateUnitFrame("focustarget")
			end

			if C.db.char.units.boss.enabled then
				UF:CreateUnitFrame("boss", "LSBoss")
				UF:UpdateUnitFrame("boss")
			end
		end)

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
