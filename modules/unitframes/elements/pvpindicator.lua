local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

-- Blizz
local C_PvP = _G.C_PvP
local UnitFactionGroup = _G.UnitFactionGroup
local UnitHonorLevel = _G.UnitHonorLevel
local UnitIsMercenary = _G.UnitIsMercenary
local UnitIsPVP = _G.UnitIsPVP
local UnitIsPVPFreeForAll = _G.UnitIsPVPFreeForAll

--[[ luacheck: globals
	CreateFrame
]]

-- Mine
local function element_Override(self, _, unit)
	if unit ~= self.unit then return end

	local element = self.PvPIndicator

	local factionGroup = UnitFactionGroup(unit)
	local honorRewardInfo = C_PvP.GetHonorRewardInfo(UnitHonorLevel(unit))
	local status

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

	if status then
		if honorRewardInfo then
			element:SetTexture(honorRewardInfo.badgeFileDataID)
			element:SetTexCoord(0, 1, 0, 1)
		else
			element:SetTexture("Interface\\AddOns\\ls_UI\\assets\\pvp-banner-" .. status)
			element:SetTexCoord(102 / 256, 162 / 256, 22 / 128, 82 / 128)
		end

		element:Show()

		element.Banner:SetTexture("Interface\\AddOns\\ls_UI\\assets\\pvp-banner-" .. status)
		element.Banner:SetTexCoord(1 / 256, 101 / 256, 1 / 128, 109 / 128)
		element.Banner:Show()

		if not element.Holder:IsExpanded() then
			element.Holder:Expand()
		end
	else
		element:Hide()
		element.Banner:Hide()

		if element.Holder:IsExpanded() then
			element.Holder:Collapse()
		end
	end
end

local function holder_Expand(self)
	self:Show()

	if self.PostExpand then
		self:PostExpand()
	end

	self._expanded = true
end

local function holder_Collapse(self)
	self:Hide()

	if self.PostCollapse then
		self:PostCollapse()
	end

	self._expanded = false
end

local function holder_IsExpanded(self)
	return self._expanded
end

local function element_UpdateConfig(self)
	local unit = self.__owner._unit
	self._config = E:CopyTable(C.db.profile.units[unit].pvp, self._config)
end

local function element_UpdatePoints(self)
	self:ClearAllPoints()

	local config = self._config.point1
	if config and config.p and config.p ~= "" then
		self:SetPoint(config.p, E:ResolveAnchorPoint(self.__owner, config.anchor), config.rP, config.x, config.y)
	end
end

local function element_UpdateTags(self)
	if self.Timer then
		local tag = self._config.enabled and "[ls:pvptimer]" or ""
		if tag ~= "" then
			self.Timer.frequentUpdates = 0.1
			self.__owner:Tag(self.Timer, tag)
			self.Timer:UpdateTag()
		else
			self.Timer.frequentUpdates = nil
			self.__owner:Untag(self.Timer)
			self.Timer:SetText("")
		end
	end
end

local function frame_UpdatePvPIndicator(self)
	local element = self.PvPIndicator
	element:UpdateConfig()
	element:UpdatePoints()
	element:UpdateTags()

	if element._config.enabled and not self:IsElementEnabled("PvPIndicator") then
		self:EnableElement("PvPIndicator")
	elseif not element._config.enabled and self:IsElementEnabled("PvPIndicator") then
		self:DisableElement("PvPIndicator")
	end

	if self:IsElementEnabled("PvPIndicator") then
		if element.Holder:IsExpanded() and element.Holder.PostExpand then
			element.Holder:PostExpand()
		end

		element:ForceUpdate()
	else
		element.Holder:Collapse()
	end
end

function UF:CreatePvPIndicator(frame, parent)
	local holder = CreateFrame("Frame", nil, parent)
	holder:SetSize(50, 54)

	holder.Expand = holder_Expand
	holder.Collapse = holder_Collapse
	holder.IsExpanded = holder_IsExpanded

	local element = holder:CreateTexture(nil, "ARTWORK", nil, 0)
	element:SetSize(30, 30)
	element.Holder = holder

	local banner = holder:CreateTexture(nil, "ARTWORK", nil, -1)
	banner:SetSize(50, 54)
	banner:SetPoint("TOP", element, "TOP", 0, 11)
	element.Banner = banner

	element.Override = element_Override
	element.UpdateConfig = element_UpdateConfig
	element.UpdatePoints = element_UpdatePoints
	element.UpdateTags = element_UpdateTags

	frame.UpdatePvPIndicator = frame_UpdatePvPIndicator

	return element
end
