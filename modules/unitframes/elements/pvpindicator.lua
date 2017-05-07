local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

-- Mine
-- local ICON_COORDS = {48 / 128, 78 / 128, 1 / 64, 31 / 64}
-- local BANNER_COORDS = {1 / 128, 47 / 128, 1 / 64, 49 / 64}

local function Override(self, event, unit)
	if unit ~= self.unit then return end

	local pvp = self.PvPIndicator

	-- local status = "Horde"
	-- local level = 0

	local status
	local level = _G.UnitPrestige(unit)
	local factionGroup = _G.UnitFactionGroup(unit)

	if _G.UnitIsPVPFreeForAll(unit) then
		status = "FFA"
	elseif factionGroup and factionGroup ~= "Neutral" and _G.UnitIsPVP(unit) then
		if unit == 'player' and _G.UnitIsMercenary(unit) then
			if factionGroup == "Horde" then
				factionGroup = "Alliance"
			elseif factionGroup == "Alliance" then
				factionGroup = "Horde"
			end
		end

		status = factionGroup
	end

	if status then
		if level > 0 and pvp.Prestige then
			pvp:SetTexture(_G.GetPrestigeInfo(level))
			pvp:SetTexCoord(0, 1, 0, 1)
		else
			pvp:SetTexture("Interface\\AddOns\\ls_UI\\media\\pvp-banner-"..status)
			pvp:SetTexCoord(48 / 128, 78 / 128, 1 / 64, 31 / 64)
		end

		pvp.Prestige:SetTexture("Interface\\AddOns\\ls_UI\\media\\pvp-banner-"..status)
		pvp.Prestige:SetTexCoord(1 / 128, 47 / 128, 1 / 64, 49 / 64)

		pvp:Show()
		pvp.Prestige:Show()

		if not pvp.Holder:IsExpanded() then
			pvp.Holder:Expand()
		end
	else
		pvp:Hide()
		pvp.Prestige:Hide()

		if pvp.Holder:IsExpanded() then
			pvp.Holder:Collapse()
		end
	end
end

local function Expand(self)
	self:Show()

	if self.PostExpand then
		self:PostExpand()
	end

	self._expanded = true
end

local function Collapse(self)
	self:Hide()

	if self.PostCollapse then
		self:PostCollapse()
	end

	self._expanded = false
end

local function IsExpanded(self)
	return self._expanded
end

function UF:CreatePvPIndicator(parent)
	local holder = _G.CreateFrame("Frame", nil, parent)
	holder:SetSize(46, 48)

	holder.Expand = Expand
	holder.Collapse = Collapse
	holder.IsExpanded = IsExpanded

	local pvp = holder:CreateTexture(nil, "ARTWORK", nil, 0)
	pvp:SetSize(30, 30)

	local banner = holder:CreateTexture(nil, "ARTWORK", nil, -1)
	banner:SetSize(46, 48)
	banner:SetPoint("TOP", pvp, "TOP", 0, 9)

	pvp.Holder = holder
	pvp.Prestige = banner
	pvp.Override = Override

	return pvp
end

function UF:UpdatePvPIndicator(frame)
	local config = frame._config.pvp
	local element = frame.PvPIndicator

	if config.enabled and not frame:IsElementEnabled("PvPIndicator") then
		frame:EnableElement("PvPIndicator")
	elseif not config.enabled and frame:IsElementEnabled("PvPIndicator") then
		frame:DisableElement("PvPIndicator")
	end

	if frame:IsElementEnabled("PvPIndicator") then
		element:ForceUpdate()
	end
end
