local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local UF = E:GetModule("UnitFrames")

-- Lua
local _G = _G

-- Mine
local ICONS = {
	Alliance = {124 / 256, 154 / 256, 1 / 128, 31 / 128},
	Horde = {155 / 256, 185 / 256, 1 / 128, 31 / 128},
	FFA = {186 / 256, 216 / 256, 1 / 128, 31 / 128},
}

local BANNERS = {
	Alliance = {1 / 256, 41 / 256, 1 / 128, 46 / 128},
	Horde = {42 / 256, 82 / 256, 1 / 128, 46 / 128},
	FFA = {83 / 256, 123 / 256, 1 / 128, 46 / 128}
}

local function Override(self, event, unit)
	if unit ~= self.unit then return end

	local pvp = self.PvP

	-- local status = "Horde"
	-- local level = 3

	local status
	local level = UnitPrestige(unit)
	local factionGroup = UnitFactionGroup(unit)

	if(UnitIsPVPFreeForAll(unit)) then
		status = "FFA"
	elseif(factionGroup and factionGroup ~= "Neutral" and UnitIsPVP(unit)) then
		if(UnitIsMercenary(unit)) then
			if(factionGroup == "Horde") then
				factionGroup = "Alliance"
			elseif(factionGroup == "Alliance") then
				factionGroup = "Horde"
			end
		end

		status = factionGroup
	end

	if(status) then
		if(level > 0 and pvp.Prestige) then
			pvp:SetTexture(GetPrestigeInfo(level))
			pvp:SetTexCoord(0, 1, 0, 1)
		else
			pvp:SetTexture("Interface\\AddOns\\oUF_LS\\media\\pvp-banners")
			pvp:SetTexCoord(unpack(ICONS[status]))
		end

		pvp.Prestige:SetTexture("Interface\\AddOns\\oUF_LS\\media\\pvp-banners")
		pvp.Prestige:SetTexCoord(unpack(BANNERS[status]))

		pvp:Show()
		pvp.Prestige:Show()
	else
		pvp:Hide()
		pvp.Prestige:Hide()
	end
end

function UF:CreatePvPIcon(parent)
	local pvp = parent:CreateTexture(nil, "ARTWORK", nil, 6)
	pvp:SetSize(30, 30)

	local banner = parent:CreateTexture(nil, "ARTWORK", nil, 5)
	banner:SetSize(40, 45)
	banner:SetPoint("TOP", pvp, "TOP", 0, 6)
	pvp.Prestige = banner

	pvp.Override = Override

	return pvp
end
