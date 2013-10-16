local _, ns = ...
local L = ns.L
local cfg = ns.cfg
local buffConfig = cfg.buffs
local gColors = cfg.globals.colors

local BuffFrame = _G["BuffFrame"]
local ConsolidatedBuffs = _G["ConsolidatedBuffs"]

local BUFF_MAX_DISPLAY = BUFF_MAX_DISPLAY
local DEBUFF_MAX_DISPLAY = DEBUFF_MAX_DISPLAY
local NUM_TEMP_ENCHANT_FRAMES = NUM_TEMP_ENCHANT_FRAMES

local function SetDurationText(duration, arg1, arg2)
	duration:SetText(format(gsub(arg1, "[ .]", ""), arg2))
end

local function UpdateBuffAnchors()
	local numBuffs, slack = 0, 0
	local button, previous, above
	local BUFF_ACTUAL_DISPLAY = BUFF_ACTUAL_DISPLAY
	if IsInGroup() and GetCVarBool("consolidateBuffs") then
		slack = 1
	end
	for i = 1, BUFF_ACTUAL_DISPLAY do
		button = _G["BuffButton"..i]
		if not button.consolidated then
			numBuffs = numBuffs + 1
			index = numBuffs + slack
			if button.parent ~= BuffFrame then
				button.count:SetFont(cfg.font, 12, "THINOUTLINE")
				button:SetParent(BuffFrame)
				button.parent = BuffFrame
			end
			button:ClearAllPoints()
			button:SetSize(30, 30)
			if index > 1 and (mod(index, 16) == 1) then
				if index == 17 then
					button:SetPoint("TOP", ConsolidatedBuffs, "BOTTOM", 0, -4)
				else
					button:SetPoint("TOP", above, "BOTTOM", 0, -4)
				end
				above = button
			elseif index == 1 then
				button:SetPoint("TOPRIGHT", BuffFrame, "TOPRIGHT", 0, 0)
				above = button
			else
				if numBuffs == 1 then
					button:SetPoint("RIGHT", ConsolidatedBuffs, "LEFT", -4, 0)
				else
					button:SetPoint("RIGHT", previous, "LEFT", -4, 0)
				end
			end
			previous = button
		end
	end
end

local function UpdateDebuffAnchors(buttonName, index)
	local BUFF_ACTUAL_DISPLAY = BUFF_ACTUAL_DISPLAY
	local rows = ceil(BUFF_ACTUAL_DISPLAY / 16)
	local button = _G[buttonName..index]
	button:ClearAllPoints()
	button:SetSize(30, 30)
	if index == 1 then
		button:SetPoint("TOPRIGHT", oUF_LSDebuffHeader, "TOPRIGHT", 0, 0)
	else
		button:SetPoint("RIGHT", _G[buttonName..(index - 1)], "LEFT", -4, 0)
	end  
end

function UpdateTemporaryEnchantAnchors(self)
	local previous
	for i = 1, NUM_TEMP_ENCHANT_FRAMES do
		local button = _G["TempEnchant"..i]
		if button then
			button:ClearAllPoints()
			button:SetSize(30, 30)
			if i == 1 then
				button:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)
			else
				button:SetPoint("RIGHT", previous, "LEFT", -4, 0)
			end
			previous = button
		end
	end
end

local function SetAuraButtonStyle(btn, index, atype)
	local name = btn..index
	local button = _G[name]
	if not button then return end
	if button.styled then return end
	local bBorder = _G[name.."Border"]
	local bIcon = _G[name.."Icon"]
	local bCount = _G[name.."Count"]
	local bDuration = _G[name.."Duration"]
	if bIcon then
		if atype == "CONSOLIDATED" then
			bIcon:SetTexCoord(18 / 128, 46 / 128, 18 / 64, 46 / 64)
		else
			bIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		end
		bIcon:SetDrawLayer("BACKGROUND", 0)
		bIcon:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -2)
		bIcon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
	end
	if bCount then
		bCount:SetFont(cfg.font, 12, "THINOUTLINE")
		bCount:ClearAllPoints()
		bCount:SetPoint("TOPRIGHT", 0, 0)
	end
	if bDuration then
		bDuration:SetFont(cfg.font, 14, "THINOUTLINE")
		bDuration:ClearAllPoints()
		bDuration:SetPoint("BOTTOM", button, "BOTTOM", 2, 0)
		hooksecurefunc(bDuration, "SetFormattedText", SetDurationText)
	end
	if atype == "HARMFUL" or atype == "TEMPENCHANT" then
		if bBorder then
			bBorder:SetTexCoord(14 / 64, 50 / 64, 14 / 64, 50 / 64)
			bBorder:SetTexture(cfg.globals.textures.button_normal)
			if atype == "TEMPENCHANT" then
				bBorder:SetVertexColor(0.7, 0, 1)
			end
			bBorder:SetDrawLayer("BACKGROUND", 1)
			bBorder:ClearAllPoints()
			bBorder:SetPoint("TOPLEFT", button, "TOPLEFT", -3, 3)
			bBorder:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 3, -3)
		end
	else
		button.NewBorder = button:CreateTexture(nil, "BACKGROUND", nil, 1)
		bBorder = button.NewBorder
		bBorder:SetTexture(cfg.globals.textures.button_normal)
		bBorder:SetTexCoord(14 / 64, 50 / 64, 14 / 64, 50 / 64)
		bBorder:SetVertexColor(unpack(cfg.globals.colors.btnstate.normal))
		bBorder:ClearAllPoints()
		bBorder:SetPoint("TOPLEFT", button, "TOPLEFT", -3, 3)
		bBorder:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 3, -3)
	end
	button.styled = true
end

do
	hooksecurefunc("BuffFrame_UpdateAllBuffAnchors", UpdateBuffAnchors)
	hooksecurefunc("DebuffButton_UpdateAnchors", UpdateDebuffAnchors)
	hooksecurefunc("AuraButton_Update", SetAuraButtonStyle)
	for i = 1, NUM_TEMP_ENCHANT_FRAMES do
		SetAuraButtonStyle("TempEnchant", i, "TEMPENCHANT")
	end
	SetAuraButtonStyle("ConsolidatedBuffs", "", "CONSOLIDATED")
	ConsolidatedBuffsTooltip:SetScale(1)
end