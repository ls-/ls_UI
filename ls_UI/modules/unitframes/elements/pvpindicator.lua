local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF, Profiler = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF, ns.Profiler
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

-- Mine
local element_proto = {}

function element_proto:Override(_, unit)
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

		element.Banner:SetTexture("Interface\\AddOns\\ls_UI\\assets\\pvp-banner-" .. status)
		element.Banner:SetTexCoord(1 / 256, 101 / 256, 1 / 128, 109 / 128)

		element:Show()
		element.Banner:Show()
		element.Holder:Show()
	else
		element:Hide()
		element.Banner:Hide()
		element.Holder:Hide()
	end
end

function element_proto:UpdateConfig()
	local unit = self.__owner.__unit
	self._config = E:CopyTable(C.db.profile.units[unit].pvp, self._config)
end

function element_proto:UpdateTags()
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

local frame_proto = {}

function frame_proto:UpdatePvPIndicator()
	local element = self.PvPIndicator
	element:UpdateConfig()
	element:UpdateTags()

	if element._config.enabled and not self:IsElementEnabled("PvPIndicator") then
		self:EnableElement("PvPIndicator")
	elseif not element._config.enabled and self:IsElementEnabled("PvPIndicator") then
		self:DisableElement("PvPIndicator")
		element.Holder:Hide()
	end

	if self:IsElementEnabled("PvPIndicator") then
		element:ForceUpdate()
	end
end

function UF:CreatePvPIndicator(frame, parent)
	Mixin(frame, frame_proto)

	local holder = CreateFrame("Frame", nil, parent)
	holder:SetSize(50, 54)

	local element = Mixin(holder:CreateTexture(nil, "ARTWORK", nil, 0), element_proto)
	element:SetPoint("TOPLEFT", holder, "TOPLEFT", 10, -12)
	element:SetSize(30, 30)
	element.Holder = holder

	local banner = holder:CreateTexture(nil, "ARTWORK", nil, -1)
	banner:SetAllPoints()
	element.Banner = banner

	return element
end
