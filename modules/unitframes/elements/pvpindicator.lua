local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

-- Blizz
local CreateFrame = _G.CreateFrame
local GetPrestigeInfo = _G.GetPrestigeInfo
local UnitFactionGroup = _G.UnitFactionGroup
local UnitIsMercenary = _G.UnitIsMercenary
local UnitIsPVP = _G.UnitIsPVP
local UnitIsPVPFreeForAll = _G.UnitIsPVPFreeForAll
local UnitPrestige = _G.UnitPrestige

-- Mine
local function Override(self, _, unit)
	if unit ~= self.unit then return end

	local pvp = self.PvPIndicator

	local status
	local level = UnitPrestige(unit)
	local factionGroup = UnitFactionGroup(unit)

	if UnitIsPVPFreeForAll(unit) then
		status = "FFA"
	elseif factionGroup and factionGroup ~= "Neutral" and UnitIsPVP(unit) then
		if unit == "player" and UnitIsMercenary(unit) then
			if factionGroup == "Horde" then
				factionGroup = "Alliance"
			elseif factionGroup == "Alliance" then
				factionGroup = "Horde"
			end
		end

		status = factionGroup
	end

	-- local status = "FFA"
	-- local level = 0

	if status then
		if level > 0 and pvp.Prestige then
			pvp:SetTexture(GetPrestigeInfo(level))
			pvp:SetTexCoord(0, 1, 0, 1)
		else
			pvp:SetTexture("Interface\\AddOns\\ls_UI\\assets\\pvp-banner-"..status)
			pvp:SetTexCoord(102 / 256, 162 / 256, 22 / 128, 82 / 128)
		end

		pvp.Prestige:SetTexture("Interface\\AddOns\\ls_UI\\assets\\pvp-banner-"..status)
		pvp.Prestige:SetTexCoord(1 / 256, 101 / 256, 1 / 128, 109 / 128)

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
	local holder = CreateFrame("Frame", nil, parent)
	holder:SetSize(50, 54)

	holder.Expand = Expand
	holder.Collapse = Collapse
	holder.IsExpanded = IsExpanded

	local pvp = holder:CreateTexture(nil, "ARTWORK", nil, 0)
	pvp:SetSize(30, 30)

	local banner = holder:CreateTexture(nil, "ARTWORK", nil, -1)
	banner:SetSize(50, 54)
	banner:SetPoint("TOP", pvp, "TOP", 0, 11)

	pvp.Holder = holder
	pvp.Prestige = banner
	pvp.Override = Override

	return pvp
end

function UF:UpdatePvPIndicator(frame)
	local config = frame._config.pvp
	local element = frame.PvPIndicator

	element:ClearAllPoints()

	local point1 = config.point1

	if point1 and point1.p then
		element:SetPoint(point1.p, E:ResolveAnchorPoint(frame, point1.anchor), point1.rP, point1.x, point1.y)
	end

	if element.Holder:IsExpanded() and element.Holder.PostExpand then
		element.Holder:PostExpand()
	end

	if config.enabled and not frame:IsElementEnabled("PvPIndicator") then
		frame:EnableElement("PvPIndicator")
	elseif not config.enabled and frame:IsElementEnabled("PvPIndicator") then
		frame:DisableElement("PvPIndicator")
	end

	local timer = element.Timer

	if timer then
		timer.frequentUpdates = config.enabled and 0.1 or nil
		frame:Tag(timer, config.enabled and "[ls:pvptimer]" or "")
		timer:UpdateTag()
	end

	if frame:IsElementEnabled("PvPIndicator") then
		element:ForceUpdate()
	else
		element.Holder:Collapse()
	end
end
