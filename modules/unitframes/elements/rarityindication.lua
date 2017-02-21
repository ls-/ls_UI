local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)
local unpack = unpack

-- Blizz
local UnitClassification = UnitClassification

-- Mine
local TEXTURES = {
	shared = {
		corner_rare_left = {
			size = {19, 38},
			coords = {0 / 512, 19 / 512, 66 / 256, 104 / 256},
		},
		corner_rare_mid = {
			size = {36, 36},
			coords = {19 / 512, 55 / 512, 67 / 256, 103 / 256},
		},
		corner_rare_right = {
			size = {19, 38},
			coords = {55 / 512, 74 / 512, 66 / 256, 104 / 256},
		},
		corner_elite_left = {
			size = {21, 42},
			coords = {74 / 512, 95 / 512, 66 / 256, 108 / 256},
		},
		corner_elite_right = {
			size = {21, 42},
			coords = {95 / 512, 116 / 512, 66 / 256, 108 / 256},
		},
	},
	long = {
		fg_copper = {
			size = {200, 30},
			coords = {206 / 512, 406 / 512, 30 / 256, 60 / 256},
		},
		fg_copper_elite = {
			size = {202, 35},
			coords = {206 / 512, 408 / 512, 95 / 256, 130 / 256},
		},
		fg_silver = {
			size = {200, 30},
			coords = {206 / 512, 406 / 512, 0 / 256, 30 / 256},
		},
		fg_silver_elite = {
			size = {202, 35},
			coords = {206 / 512, 408 / 512, 60 / 256, 95 / 256},
		},
	},
	short = {
		fg_copper = {
			size = {106, 30},
			coords = {112 / 512, 218 / 512, 160 / 256, 190 / 256},
		},
		fg_copper_elite = {
			size = {108, 35},
			coords = {218 / 512, 326 / 512, 165 / 256, 200 / 256},
		},
		fg_silver = {
			size = {106, 30},
			coords = {112 / 512, 218 / 512, 130 / 256, 160 / 256},
		},
		fg_silver_elite = {
			size = {108, 35},
			coords = {218 / 512, 326 / 512, 130 / 256, 165 / 256},
		},
	},
}

local function SetRareSkin(frame)
	local textureSet = TEXTURES[frame.frameType]

	frame.BgIndicatorLeft:SetTexCoord(unpack(TEXTURES.shared.corner_rare_left.coords))
	frame.BgIndicatorLeft:SetSize(unpack(TEXTURES.shared.corner_rare_left.size))
	frame.BgIndicatorLeft:SetPoint("LEFT", -1, 0)
	frame.BgIndicatorLeft:Show()

	frame.BgIndicatorMiddle:SetTexCoord(unpack(TEXTURES.shared.corner_rare_mid.coords))
	frame.BgIndicatorMiddle:SetSize(unpack(TEXTURES.shared.corner_rare_mid.size))
	frame.BgIndicatorMiddle:SetPoint("CENTER", 0, 0)
	frame.BgIndicatorMiddle:Show()

	frame.BgIndicatorRight:SetTexCoord(unpack(TEXTURES.shared.corner_rare_right.coords))
	frame.BgIndicatorRight:SetSize(unpack(TEXTURES.shared.corner_rare_right.size))
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
	local textureSet = TEXTURES[frame.frameType]

	frame.BgIndicatorLeft:SetTexCoord(unpack(TEXTURES.shared.corner_elite_left.coords))
	frame.BgIndicatorLeft:SetSize(unpack(TEXTURES.shared.corner_elite_left.size))
	frame.BgIndicatorLeft:SetPoint("LEFT", -3, 0)
	frame.BgIndicatorLeft:Show()

	frame.BgIndicatorMiddle:Hide()

	frame.BgIndicatorRight:SetTexCoord(unpack(TEXTURES.shared.corner_elite_right.coords))
	frame.BgIndicatorRight:SetSize(unpack(TEXTURES.shared.corner_elite_right.size))
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
	local textureSet = TEXTURES[frame.frameType]

	frame.BgIndicatorLeft:SetTexCoord(unpack(TEXTURES.shared.corner_elite_left.coords))
	frame.BgIndicatorLeft:SetSize(unpack(TEXTURES.shared.corner_elite_left.size))
	frame.BgIndicatorLeft:SetPoint("LEFT", -3, 0)
	frame.BgIndicatorLeft:Show()

	frame.BgIndicatorMiddle:Hide()

	frame.BgIndicatorRight:SetTexCoord(unpack(TEXTURES.shared.corner_elite_right.coords))
	frame.BgIndicatorRight:SetSize(unpack(TEXTURES.shared.corner_elite_right.size))
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
	local textureSet = TEXTURES[frame.frameType]

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

	_G.hooksecurefunc(frame, "Show", CheckUnitClassification)
end
