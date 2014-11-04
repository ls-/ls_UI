local _, ns = ...

local BuffFrame = _G["BuffFrame"]
local ConsolidatedBuffs = _G["ConsolidatedBuffs"]

local function lsSetDurationText(duration, arg1, arg2)
	duration:SetText(format(gsub(arg1, "[ .]", ""), arg2))
end

local function lsUpdateBuffAnchors()
	local numBuffs, slack = 0, 0
	local button, previous, above, index

	if IsInGroup() and GetCVarBool("consolidateBuffs") then
		slack = 1
	end

	for i = 1, BUFF_ACTUAL_DISPLAY do
		button = _G["BuffButton"..i]

		if not button.consolidated then
			numBuffs = numBuffs + 1
			index = numBuffs + slack

			if button.parent ~= BuffFrame then
				button.count:SetFont(ns.M.font, 12, "THINOUTLINE")
				button:SetParent(BuffFrame)
				button.parent = BuffFrame
			end

			button:ClearAllPoints()
			button:SetSize(ns.C.auras.aura_size, ns.C.auras.aura_size)

			if index > 1 and (mod(index, 16) == 1) then
				if index == 17 then
					button:SetPoint("TOP", ConsolidatedBuffs, "BOTTOM", 0, -ns.C.auras.aura_gap)
				else
					button:SetPoint("TOP", above, "BOTTOM", 0, -ns.C.auras.aura_gap)
				end

				above = button
			elseif index == 1 then
				button:SetPoint("TOPRIGHT", BuffFrame, "TOPRIGHT", 0, 0)

				above = button
			else
				if numBuffs == 1 then
					button:SetPoint("RIGHT", ConsolidatedBuffs, "LEFT", -ns.C.auras.aura_gap, 0)
				else
					button:SetPoint("RIGHT", previous, "LEFT", -ns.C.auras.aura_gap, 0)
				end
			end

			previous = button
		end
	end
end

local function lsUpdateDebuffAnchors(buttonName, index)
	local rows = ceil(BUFF_ACTUAL_DISPLAY / 16)
	local button = _G[buttonName..index]

	button:ClearAllPoints()
	button:SetSize(ns.C.auras.aura_size, ns.C.auras.aura_size)

	if index == 1 then
		button:SetPoint("TOPRIGHT", lsDebuffHeader, "TOPRIGHT", 0, 0)
	else
		button:SetPoint("RIGHT", _G[buttonName..(index - 1)], "LEFT", -4, 0)
	end
end

local function lsUpdateTemporaryEnchantAnchors(self)
	local previous
	for i = 1, NUM_TEMP_ENCHANT_FRAMES do
		local button = _G["TempEnchant"..i]
		if button then
			button:ClearAllPoints()
			button:SetSize(ns.C.auras.aura_size, ns.C.auras.aura_size)

			if i == 1 then
				button:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)
			else
				button:SetPoint("RIGHT", previous, "LEFT", -4, 0)
			end

			previous = button
		end
	end
end

local function lsSetAuraButtonStyle(btn, index, atype)
	local name = btn..(index or "")
	local button = _G[name]

	if not button then return end
	if button.styled then return end

	local bBorder = _G[name.."Border"]
	local bIcon = _G[name.."Icon"]
	local bCount = _G[name.."Count"]
	local bDuration = _G[name.."Duration"]

	if bIcon then
		ns.lsTweakIcon(bIcon)

		if atype == "CONSOLIDATED" then
			bIcon:SetTexCoord(18 / 128, 46 / 128, 18 / 64, 46 / 64)
		end
	end

	if bCount then
		bCount:SetFont(ns.M.font, 12, "THINOUTLINE")
		bCount:ClearAllPoints()
		bCount:SetPoint("TOPRIGHT", 0, 0)
	end

	if bDuration then
		bDuration:SetFont(ns.M.font, 14, "THINOUTLINE")
		bDuration:ClearAllPoints()
		bDuration:SetPoint("BOTTOM", 1, 0)
		hooksecurefunc(bDuration, "SetFormattedText", lsSetDurationText)
	end

	bBorder = ns.lsCreateButtonBorder(button, bBorder)
	bBorder:SetDrawLayer("BACKGROUND", 1)

	if atype == "TEMPENCHANT" then
		bBorder:SetVertexColor(0.7, 0, 1)
	end

	button.styled = true
end

function ns.lsBuffFrame_Initialize()
	local lsBuffHeader = CreateFrame("Frame", "lsBuffHeader", UIParent)
	lsBuffHeader:SetSize(ns.C.auras.aura_size + ns.C.auras.aura_gap,
		ns.C.auras.aura_size + ns.C.auras.aura_gap)
	lsBuffHeader:SetPoint(unpack(ns.C.auras.buff.point))

	local lsDebuffHeader = CreateFrame("Frame", "lsDebuffHeader", UIParent)
	lsDebuffHeader:SetSize(ns.C.auras.aura_size + ns.C.auras.aura_gap,
		ns.C.auras.aura_size + ns.C.auras.aura_gap)
	lsDebuffHeader:SetPoint(unpack(ns.C.auras.debuff.point))

	local lsTemporaryEnchantHeader = CreateFrame("Frame", "lsTemporaryEnchantHeader", UIParent)
	lsTemporaryEnchantHeader:SetSize(ns.C.auras.aura_size + ns.C.auras.aura_gap,
		ns.C.auras.aura_size + ns.C.auras.aura_gap)
	lsTemporaryEnchantHeader:SetPoint(unpack(ns.C.auras.tempench.point))

	BuffFrame:SetParent(lsBuffHeader)
	BuffFrame:ClearAllPoints()
	BuffFrame:SetPoint("TOPRIGHT", -ns.C.auras.aura_gap / 2, -ns.C.auras.aura_gap / 2)

	TemporaryEnchantFrame:SetParent(lsTemporaryEnchantHeader)
	TemporaryEnchantFrame:ClearAllPoints()
	TemporaryEnchantFrame:SetPoint("TOPRIGHT", -ns.C.auras.aura_gap / 2, -ns.C.auras.aura_gap / 2)

	lsUpdateTemporaryEnchantAnchors(lsTemporaryEnchantHeader)

	hooksecurefunc("BuffFrame_UpdateAllBuffAnchors", lsUpdateBuffAnchors)
	hooksecurefunc("DebuffButton_UpdateAnchors", lsUpdateDebuffAnchors)
	hooksecurefunc("AuraButton_Update", lsSetAuraButtonStyle)
	hooksecurefunc(GameTooltip, "SetUnitAura", function(self, unit, id, filter)
		if unit == "player" or unit == "vehicle" then
			local spellId = select(11, UnitAura(unit, id, filter))
			if spellId then
				self:AddLine("ID: "..spellId, 0.11, 0.75, 0.95)
				self:Show()
			end
		end
	end)

	for i = 1, NUM_TEMP_ENCHANT_FRAMES do
		lsSetAuraButtonStyle("TempEnchant", i, "TEMPENCHANT")
	end

	lsSetAuraButtonStyle("ConsolidatedBuffs", nil, "CONSOLIDATED")
	ConsolidatedBuffsTooltip:SetScale(1)
end
