local _, ns = ...
local cfg = ns.cfg
local buffcfg = cfg.buffs
local glcolors = cfg.globals.colors
local buff_module = CreateFrame("Frame")

local BuffFrame = _G["BuffFrame"]
local TemporaryEnchantFrame = _G["TemporaryEnchantFrame"]
local ConsolidatedBuffs = _G["ConsolidatedBuffs"]

--buff/debuff
local frame1 = CreateFrame("Frame", "new_BuffFrame1", UIParent)
--tempench
local frame2 = CreateFrame("Frame", "new_BuffFrame2", UIParent)

local function SetDurationText(duration, arg1, arg2)
	duration:SetText(format(gsub(arg1, "[ .]", ""), arg2))
end

local function SetBuffFramePosition()
	BuffFrame:SetParent(_G["new_BuffFrame1"])
	BuffFrame:ClearAllPoints()
	BuffFrame:SetPoint("TOPRIGHT", 0, 0)
end

local function SetTemporaryEnchantFramePosition()
	TemporaryEnchantFrame:SetParent(_G["new_BuffFrame2"])
	TemporaryEnchantFrame:ClearAllPoints()
	TemporaryEnchantFrame:SetPoint("TOPRIGHT", 0, 0)
end

local function SetAuraFramePosition(f)
	_G["new_BuffFrame"..f]:SetSize(buffcfg.size, buffcfg.size)
	_G["new_BuffFrame"..f]:SetPoint(unpack(buffcfg["pos"..f]))
 	_G["new_BuffFrame"..f]:SetScale(cfg.globals.scale)
	if f == 1 then 
		SetBuffFramePosition()
	elseif f == 2 then
		SetTemporaryEnchantFramePosition()
	end
end

local function UpdateBuffAnchors()
	local numBuffs = 0
	local button, previous, above
	local slack = 0
	
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
			button:SetSize(buffcfg.size, buffcfg.size)
			if index > 1 and (mod(index, buffcfg.buffsperrow) == 1) then
				if index == buffcfg.buffsperrow + 1 then
					button:SetPoint("TOP", ConsolidatedBuffs, "BOTTOM", 0, -buffcfg.rowspacing);
				else
					button:SetPoint("TOP", above, "BOTTOM", 0, -buffcfg.rowspacing)
				end
				above = button
			elseif index == 1 then
				button:SetPoint("TOPRIGHT", BuffFrame, "TOPRIGHT", 0, 0)
				above = button
			else
				if numBuffs == 1 then
					button:SetPoint("RIGHT", ConsolidatedBuffs, "LEFT", -buffcfg.colspacing, 0);
				else
					button:SetPoint("RIGHT", previous, "LEFT", -buffcfg.colspacing, 0)
				end
			end
			previous = button
		end
	end
end

local function UpdateDebuffAnchors(buttonName, index)
	local rows = ceil(BUFF_ACTUAL_DISPLAY / buffcfg.buffsperrow)
	local button = _G[buttonName..index]
	button:ClearAllPoints()
	button:SetSize(buffcfg.size, buffcfg.size)
	if index > 1 and mod(index, buffcfg.buffsperrow) == 1 then
		button:SetPoint("TOP", _G[buttonName..(index - buffcfg.buffsperrow)], "BOTTOM", 0, -buffcfg.rowspacing)
	elseif index == 1 then
		if rows < 3 then
			button:SetPoint("TOPRIGHT", BuffFrame, "TOPRIGHT", 0, -2 * (buffcfg.rowspacing + buffcfg.size))
		else
			button:SetPoint("TOPRIGHT", BuffFrame, "TOPRIGHT", 0, -rows * (buffcfg.rowspacing + buffcfg.size))
		end
	else
		button:SetPoint("RIGHT", _G[buttonName..(index-1)], "LEFT", -buffcfg.colspacing, 0)
	end  
end

local function UpdateTempEnchantAnchors()
	local previous
	for i = 1, NUM_TEMP_ENCHANT_FRAMES do
		local button = _G["TempEnchant"..i]
		if button then
			button:ClearAllPoints()
			button:SetSize(buffcfg.size, buffcfg.size)
			if i == 1 then
				button:SetPoint("TOPRIGHT", TemporaryEnchantFrame, "TOPRIGHT", 0, 0)
			else
				button:SetPoint("RIGHT", previous, "LEFT", -buffcfg.colspacing, 0)
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
		bIcon:SetDrawLayer("BACKGROUND", -7)
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
			bBorder:SetTexCoord(0, 1, 0, 1)
			bBorder:SetTexture(cfg.globals.textures.button_normal)
			if atype == "TEMPENCHANT" then
				bBorder:SetVertexColor(0.7, 0, 1)
			end
			bBorder:SetDrawLayer("BACKGROUND", -6)
			bBorder:ClearAllPoints()
			bBorder:SetAllPoints(button)
		end
	else
		button.NewBorder = button:CreateTexture(nil, "BACKGROUND", nil, -6)
		bBorder = button.NewBorder
		bBorder:SetTexture(cfg.globals.textures.button_normal)
		bBorder:SetVertexColor(unpack(glcolors.btnstate.normal))
		bBorder:ClearAllPoints()
		bBorder:SetAllPoints(button)
	end
	if not button.bg then ns.CreateButtonBackdrop(button) end
	button.styled = true
end

local function InitAuraFrameParameters()
	for i = 1, 2 do
		SetAuraFramePosition(i)
	end
	hooksecurefunc("BuffFrame_UpdateAllBuffAnchors", UpdateBuffAnchors)
	hooksecurefunc("DebuffButton_UpdateAnchors", UpdateDebuffAnchors)
	hooksecurefunc("AuraButton_Update", SetAuraButtonStyle)
	for i = 1, NUM_TEMP_ENCHANT_FRAMES do
		SetAuraButtonStyle("TempEnchant", i, "TEMPENCHANT")
	end
	SetAuraButtonStyle("ConsolidatedBuffs", "", "CONSOLIDATED") -- well, i just don't want to write a clone-function
	ConsolidatedBuffsTooltip:SetScale(1)

	-- _G["new_BuffFrame1"].tex = _G["new_BuffFrame1"]:CreateTexture(nil, "BACKGROUND",nil,-8)
	-- _G["new_BuffFrame1"].tex:SetPoint("TOPRIGHT", "UIParent", "TOPRIGHT", -6, -60)
	-- _G["new_BuffFrame1"].tex:SetTexture(0.6, 1, 0, 0.4)
	-- _G["new_BuffFrame1"].tex:SetWidth(buffcfg.buffsperrow * buffcfg.size + (buffcfg.buffsperrow - 1) * buffcfg.colspacing)
	-- _G["new_BuffFrame1"].tex:SetHeight(3 * buffcfg.size + 2 * buffcfg.rowspacing)
	-- _G["new_BuffFrame2"].tex = _G["new_BuffFrame1"]:CreateTexture(nil, "BACKGROUND",nil,-8)
	-- _G["new_BuffFrame2"].tex:SetPoint("TOPRIGHT", "UIParent", "TOPRIGHT", -6, -180)
	-- _G["new_BuffFrame2"].tex:SetTexture(1, 0.6, 0, 0.4)
	-- _G["new_BuffFrame2"].tex:SetWidth(3 * buffcfg.size + 2 * buffcfg.colspacing)
	-- _G["new_BuffFrame2"].tex:SetHeight(1 * buffcfg.size + 0 * buffcfg.rowspacing)

	hooksecurefunc("ConsolidatedBuffs_OnShow", SetTemporaryEnchantFramePosition)
	hooksecurefunc("ConsolidatedBuffs_OnHide", SetTemporaryEnchantFramePosition)
	UpdateTempEnchantAnchors()
end

buff_module:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_LOGIN" then
		InitAuraFrameParameters()
	end
end)

buff_module:RegisterEvent("PLAYER_LOGIN")