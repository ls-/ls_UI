local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)

----------------
-- PLAYGROUND --
----------------

local oUF = ns.oUF or oUF

local function SetupNameplates(self, unit)
	local Health = _G.CreateFrame("StatusBar", nil, self)
	Health:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
	Health:SetHeight(12)
	Health:SetPoint("TOPRIGHT", self, 0, 0)
	Health:SetPoint("TOPLEFT", self, 0, 0)
	Health.frequentUpdates = true
	Health.colorHealth = true
	Health.colorReaction = true
	-- Health.colorClass = true
	E:SetStatusBarSkin(Health, "HORIZONTAL-L")
	self.Health = Health

	self.Target = self:CreateTexture()
	self.Target:SetSize(16, 16)
	self.Target:SetColorTexture(1, 0, 0)
	self.Target:SetPoint("TOP", self, "BOTTOM")
	self.Target:Hide()

	self.Name = self:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	self.Name:SetPoint("BOTTOM", self, "TOP")
	self.Name:Hide()
	self:Tag(self.Name, "[ls:name]")

	self:SetScale(_G.UIParent:GetEffectiveScale())
	self:SetSize(128, 26)
	self:SetPoint("CENTER", 0, 0)

	local bg = self:CreateTexture(nil, "BACKGROUND")
	bg:SetColorTexture(0.3, 0.3, 0.3)
	bg:SetAllPoints(Health)
	-- local FGParent = CreateFrame("Frame", nil, self)
	-- FGParent:SetAllPoints()
end

local function callback(self, event, unit)
	if event == "NAME_PLATE_UNIT_ADDED" then
		if UnitIsUnit(unit, "player") then
	-- 		-- print("NAME_PLATE_UNIT_ADDED", unit)
	-- 		-- self.Target:Show()
			self.Name:Hide()
	-- 		-- print("|cffffff00name1:|r", UnitName(unit), "|cffffff00health1:|r", UnitHealth(unit), "|cffffff00power1:|r", UnitPower(unit))
	-- 		-- print("|cff00ffffname2:|r", UnitName(unit), "|cff00ffffhealth2:|r", UnitHealth(unit), "|cff00ffffpower2:|r", UnitPower(unit))
	-- 		-- self.nameFrame:Hide()
	-- 		-- self.Power:Show()
		else
	-- 		-- self.Target:Hide()
			self.Name:Show()

	-- 		-- self.nameFrame:Show()
	-- 		-- self.Power:Hide()
		end
	elseif event == "NAME_PLATE_UNIT_REMOVED" then
	-- 		-- self.Target:Hide()
			self.Name:Hide()
	-- 	-- self.nameFrame:Hide()
	-- 	-- self.Power:Hide()
	end
end

local cvars = {
	-- important, strongly recommend to set these to 1
	nameplateGlobalScale = 1,
	NamePlateHorizontalScale = 1,
	NamePlateVerticalScale = 1,
	-- optional, you may use any values
	nameplateLargerScale = 1,
	nameplateMaxScale = 1,
	nameplateMinScale = 1,
	nameplateSelectedScale = 1,
	nameplateSelfScale = 1,
}

-- oUF:RegisterStyle("LSTEST", SetupNameplates)
-- oUF:SpawnNamePlates("LS", callback, cvars)
