local _, ns = ...
local E, M = ns. E, ns.M
local UF = E.UF

local SHARED_FRAME_TEXTURES = M.frame_textures.shared
local SHORT_FRAME_TEXTURES = M.frame_textures.long
local LONG_FRAME_TEXTURES = M.frame_textures.long

local unpack = unpack
local UnitClassification = UnitClassification

local function SetRareStyle(frame)
	-- print("setting rare style")
	frame.BgIndicatorLeft:SetTexCoord(unpack(SHARED_FRAME_TEXTURES.corner_rare_left.coords))
	frame.BgIndicatorLeft:SetSize(unpack(SHARED_FRAME_TEXTURES.corner_rare_left.size))
	frame.BgIndicatorLeft:SetPoint("LEFT", -1, 0)
	frame.BgIndicatorLeft:Show()

	frame.BgIndicatorMiddle:SetTexCoord(unpack(SHARED_FRAME_TEXTURES.corner_rare_mid.coords))
	frame.BgIndicatorMiddle:SetSize(unpack(SHARED_FRAME_TEXTURES.corner_rare_mid.size))
	frame.BgIndicatorMiddle:SetPoint("CENTER", 0, 0)
	frame.BgIndicatorMiddle:Show()

	frame.BgIndicatorRight:SetTexCoord(unpack(SHARED_FRAME_TEXTURES.corner_rare_right.coords))
	frame.BgIndicatorRight:SetSize(unpack(SHARED_FRAME_TEXTURES.corner_rare_right.size))
	frame.BgIndicatorRight:SetPoint("RIGHT", 1, 0)
	frame.BgIndicatorRight:Show()

	frame.Fg:SetTexCoord(unpack(LONG_FRAME_TEXTURES.fg_silver.coords))
	frame.Fg:SetSize(unpack(LONG_FRAME_TEXTURES.fg_silver.size))
	frame.Fg:SetPoint("BOTTOM", 0, 3)
end

local function SetRareEliteStyle(frame)
	-- print("setting rareelite style")
	frame.BgIndicatorLeft:SetTexCoord(unpack(SHARED_FRAME_TEXTURES.corner_elite_left.coords))
	frame.BgIndicatorLeft:SetSize(unpack(SHARED_FRAME_TEXTURES.corner_elite_left.size))
	frame.BgIndicatorLeft:SetPoint("LEFT", -3, 0)
	frame.BgIndicatorLeft:Show()

	frame.BgIndicatorMiddle:Hide()

	frame.BgIndicatorRight:SetTexCoord(unpack(SHARED_FRAME_TEXTURES.corner_elite_right.coords))
	frame.BgIndicatorRight:SetSize(unpack(SHARED_FRAME_TEXTURES.corner_elite_right.size))
	frame.BgIndicatorRight:SetPoint("RIGHT", 3, 0)
	frame.BgIndicatorRight:Show()

	frame.Fg:SetTexCoord(unpack(LONG_FRAME_TEXTURES.fg_silver_elite.coords))
	frame.Fg:SetSize(unpack(LONG_FRAME_TEXTURES.fg_silver_elite.size))
	frame.Fg:SetPoint("BOTTOM", 0, 1)
end

local function SetEliteStyle(frame)
	-- print("setting elite style")
	frame.BgIndicatorLeft:SetTexCoord(unpack(SHARED_FRAME_TEXTURES.corner_elite_left.coords))
	frame.BgIndicatorLeft:SetSize(unpack(SHARED_FRAME_TEXTURES.corner_elite_left.size))
	frame.BgIndicatorLeft:SetPoint("LEFT", -3, 0)
	frame.BgIndicatorLeft:Show()

	frame.BgIndicatorMiddle:Hide()

	frame.BgIndicatorRight:SetTexCoord(unpack(SHARED_FRAME_TEXTURES.corner_elite_right.coords))
	frame.BgIndicatorRight:SetSize(unpack(SHARED_FRAME_TEXTURES.corner_elite_right.size))
	frame.BgIndicatorRight:SetPoint("RIGHT", 3, 0)
	frame.BgIndicatorRight:Show()

	frame.Fg:SetTexCoord(unpack(LONG_FRAME_TEXTURES.fg_copper_elite.coords))
	frame.Fg:SetSize(unpack(LONG_FRAME_TEXTURES.fg_copper_elite.size))
	frame.Fg:SetPoint("BOTTOM", 0, 1)
end

local function SetNormalStyle(frame)
	-- print("setting normal style")
	frame.BgIndicatorLeft:Hide()
	frame.BgIndicatorMiddle:Hide()
	frame.BgIndicatorRight:Hide()

	frame.Fg:SetTexCoord(unpack(LONG_FRAME_TEXTURES.fg_copper.coords))
	frame.Fg:SetSize(unpack(LONG_FRAME_TEXTURES.fg_copper.size))
	frame.Fg:SetPoint("BOTTOM", 0, 3)
end

local function CheckUnitClassification(frame)
	local class = UnitClassification(frame.unit)
	if class == "worldboss" or class == "elite" then
		SetEliteStyle(frame)
	elseif class == "rare" then
		SetRareStyle(frame)
	elseif class == "rareelite" then
		SetRareEliteStyle(frame)
	else
		SetNormalStyle(frame)
	end
end

function UF:SetupRarityIndication(frame)
	hooksecurefunc(frame, "Show", CheckUnitClassification)
end
