local _, ns = ...
local E, M = ns. E, ns.M
local UF = E.UF

local FRAME_TEXTURES = M.frame_textures
local SHARED_FRAME_TEXTURES = FRAME_TEXTURES.shared

local unpack = unpack
local UnitClassification = UnitClassification

local function SetRareSkin(frame)
	local textureSet = FRAME_TEXTURES[frame.frameType]
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

	frame.Fg:SetTexCoord(unpack(textureSet.fg_silver.coords))
	frame.Fg:SetSize(unpack(textureSet.fg_silver.size))
	frame.Fg:SetPoint("BOTTOM", 0, 3)

	if frame.Power then
		frame.Power.Tube[1]:SetDesaturated(true)
		frame.Power.Tube[4]:SetDesaturated(true)
	end

	frame.skin = "rare"
end

local function SetRareEliteSkin(frame)
	local textureSet = FRAME_TEXTURES[frame.frameType]
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

	frame.Fg:SetTexCoord(unpack(textureSet.fg_silver_elite.coords))
	frame.Fg:SetSize(unpack(textureSet.fg_silver_elite.size))
	frame.Fg:SetPoint("BOTTOM", 0, 1)

	if frame.Power then
		frame.Power.Tube[1]:SetDesaturated(true)
		frame.Power.Tube[4]:SetDesaturated(true)
	end

	frame.skin = "rareelite"
end

local function SetEliteSkin(frame)
	local textureSet = FRAME_TEXTURES[frame.frameType]
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

	frame.Fg:SetTexCoord(unpack(textureSet.fg_copper_elite.coords))
	frame.Fg:SetSize(unpack(textureSet.fg_copper_elite.size))
	frame.Fg:SetPoint("BOTTOM", 0, 1)

	if frame.Power then
		frame.Power.Tube[1]:SetDesaturated(false)
		frame.Power.Tube[4]:SetDesaturated(false)
	end

	frame.skin = "elite"
end

local function SetNormalSkin(frame)
	local textureSet = FRAME_TEXTURES[frame.frameType]
	-- print("setting normal style")

	frame.BgIndicatorLeft:Hide()
	frame.BgIndicatorMiddle:Hide()
	frame.BgIndicatorRight:Hide()

	frame.Fg:SetTexCoord(unpack(textureSet.fg_copper.coords))
	frame.Fg:SetSize(unpack(textureSet.fg_copper.size))
	frame.Fg:SetPoint("BOTTOM", 0, 3)

	if frame.Power then
		frame.Power.Tube[1]:SetDesaturated(false)
		frame.Power.Tube[4]:SetDesaturated(false)
	end

	frame.skin = "normal"
end

local function CheckUnitClassification(frame)
	local class = UnitClassification(frame.unit)
	local skin = frame.skin

	if class == "worldboss" or class == "elite" then
		if skin ~= "elite" then
			SetEliteSkin(frame)
		end
	elseif class == "rare" then
		if skin ~= "rare" then
			SetRareSkin(frame)
		end
	elseif class == "rareelite" then
		if skin ~= "rareelite" then
			SetRareEliteSkin(frame)
		end
	else
		if skin ~= "normal" then
			SetNormalSkin(frame)
		end
	end
end

function UF:SetupRarityIndication(frame, frameType)
	frame.frameType = frameType
	frame.skin = "none"

	hooksecurefunc(frame, "Show", CheckUnitClassification)
end
