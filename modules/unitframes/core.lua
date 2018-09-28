local _, ns = ...
local E, C, M, L, P, oUF = ns.E, ns.C, ns.M, ns.L, ns.P, ns.oUF
local UF = P:AddModule("UnitFrames")

-- Lua
local _G = getfenv(0)
local next = _G.next
local unpack = _G.unpack

--[[ luacheck: globals
	PartyMemberBuffTooltip PartyMemberBuffTooltip_Update RegisterUnitWatch UnitFrame_OnEnter UnitFrame_OnLeave
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
	self._config = E:CopyTable(C.db.profile.units[self._unit], self._config)
	-- self._config.cooldown = E:CopyTable(C.db.profile.units.cooldown, self._config.cooldown)
end

local function frame_UpdateSize(self)
	self:SetSize(self._config.width, self._config.height)

	local mover = E.Movers:Get(self, true)
	if mover then
		mover:UpdateSize()
	end
end

local function frame_ForElement(self, element, method, ...)
	if self[element] and self[element][method] then
		self[element][method](self[element], ...)
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
				local object = oUF:Spawn(unit .. i, name .. i .. "Frame")
				objects[unit .. i] = object

				object._parent = holder
				holder._buttons[i] = object
			end
		else
			local object = oUF:Spawn(unit, name .. "Frame")
			object:UpdateConfig()
			object:SetPoint(unpack(object._config.point[E.UI_LAYOUT]))
			E.Movers:Create(object)
			objects[unit] = object
		end

		units[unit] = true
	end
end

function UF:UpdateUnitFrame(unit, method, ...)
	if units[unit] then
		if unit == "boss"then
			for i = 1, 5 do
				if objects[unit .. i][method] then
					objects[unit .. i][method](objects[unit .. i], ...)
				end
			end

			if method == "Update" then
				UF:UpdateBossHolder()
			end
		elseif objects[unit] then
			if objects[unit][method] then
				objects[unit][method](objects[unit], ...)
			end
		end
	end
end

function UF:UpdateUnitFrames(method, ...)
	for unit in next, units do
		self:UpdateUnitFrame(unit, method, ...)
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
				frame._unit = unit:gsub("%d+", "")

				frame.ForElement = frame_ForElement
				frame.Preview = frame_Preview
				frame.UpdateConfig = frame_UpdateConfig
				frame.UpdateSize = frame_UpdateSize

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
				elseif unit:match("^boss%d") then
					UF:CreateBossFrame(frame)
				end
			end)
			oUF:SetActiveStyle("LS")

			if C.db.char.units.player.enabled then
				UF:CreateUnitFrame("player", "LSPlayer")
				UF:UpdateUnitFrame("player", "Update")
				UF:CreateUnitFrame("pet", "LSPet")
				UF:UpdateUnitFrame("pet", "Update")
			end

			if C.db.char.units.target.enabled then
				UF:CreateUnitFrame("target", "LSTarget")
				UF:UpdateUnitFrame("target", "Update")
				UF:CreateUnitFrame("targettarget", "LSTargetTarget")
				UF:UpdateUnitFrame("targettarget", "Update")
			end

			if C.db.char.units.focus.enabled then
				UF:CreateUnitFrame("focus", "LSFocus")
				UF:UpdateUnitFrame("focus", "Update")
				UF:CreateUnitFrame("focustarget", "LSFocusTarget")
				UF:UpdateUnitFrame("focustarget", "Update")
			end

			if C.db.char.units.boss.enabled then
				UF:CreateUnitFrame("boss", "LSBoss")
				UF:UpdateUnitFrame("boss", "Update")
			end
		end)

		isInit = true
	end
end

function UF:Update()
	if isInit then
		for unit in next, units do
			self:UpdateUnitFrame(unit, "Update")
		end
	end
end
