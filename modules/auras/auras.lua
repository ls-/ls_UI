local _, ns = ...
local E, M = ns.E, ns.M

E.Auras = {}

local Auras = E.Auras

local AURA_CONFIG

local BuffFrame = BuffFrame
local ConsolidatedBuffs = ConsolidatedBuffs
local TemporaryEnchantFrame = TemporaryEnchantFrame

local function UpdateBuffAnchors()
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

			button:ClearAllPoints()
			button:SetSize(AURA_CONFIG.aura_size, AURA_CONFIG.aura_size)

			if index > 1 and (mod(index, 16) == 1) then
				if index == 17 then
					button:SetPoint("TOP", ConsolidatedBuffs, "BOTTOM", 0, -AURA_CONFIG.aura_gap)
				else
					button:SetPoint("TOP", above, "BOTTOM", 0, -AURA_CONFIG.aura_gap)
				end

				above = button
			elseif index == 1 then
				button:SetPoint("CENTER", 0, 0)

				above = button
			else
				if numBuffs == 1 then
					button:SetPoint("RIGHT", ConsolidatedBuffs, "LEFT", -AURA_CONFIG.aura_gap, 0)
				else
					button:SetPoint("RIGHT", previous, "LEFT", -AURA_CONFIG.aura_gap, 0)
				end
			end

			E:SkinAuraButton(button)

			previous = button
		end
	end
end

local function UpdateDebuffAnchors(name, i)
	local button = _G[name..i]

	button:ClearAllPoints()
	button:SetSize(AURA_CONFIG.aura_size, AURA_CONFIG.aura_size)

	if i == 1 then
		button:SetPoint("CENTER", LSDebuffHeader, "CENTER", 0, 0)
	else
		button:SetPoint("RIGHT", _G[name..(i - 1)], "LEFT", -AURA_CONFIG.aura_gap, 0)
	end

	E:SkinAuraButton(button)
end

local function UpdateTemporaryEnchantAnchors()
	local button, previous

	for i = 1, NUM_TEMP_ENCHANT_FRAMES do
		button = _G["TempEnchant"..i]

		if button then
			button:ClearAllPoints()
			button:SetSize(AURA_CONFIG.aura_size, AURA_CONFIG.aura_size)

			if i == 1 then
				button:SetPoint("CENTER", 0, 0)
			else
				button:SetPoint("RIGHT", previous, "LEFT", -AURA_CONFIG.aura_gap, 0)
			end

			E:SkinAuraButton(button)

			previous = button
		end
	end
end

function Auras:Initialize()
	AURA_CONFIG = ns.C.auras

	local header1 = CreateFrame("Frame", "LSBuffHeader", UIParent)
	header1:SetSize(AURA_CONFIG.aura_size + AURA_CONFIG.aura_gap * 2,
		AURA_CONFIG.aura_size + AURA_CONFIG.aura_gap * 2)
	header1:SetPoint(unpack(AURA_CONFIG.buff.point))
	E:CreateMover(header1)

	local header2 = CreateFrame("Frame", "LSDebuffHeader", UIParent)
	header2:SetSize(AURA_CONFIG.aura_size + AURA_CONFIG.aura_gap * 2,
		AURA_CONFIG.aura_size + AURA_CONFIG.aura_gap * 2)
	header2:SetPoint(unpack(AURA_CONFIG.debuff.point))
	E:CreateMover(header2)

	local header3 = CreateFrame("Frame", "LSTempEnchantHeader", UIParent)
	header3:SetSize(AURA_CONFIG.aura_size + AURA_CONFIG.aura_gap * 2,
		AURA_CONFIG.aura_size + AURA_CONFIG.aura_gap * 2)
	header3:SetPoint(unpack(AURA_CONFIG.tempench.point))
	E:CreateMover(header3)

	BuffFrame:SetParent(header1)
	BuffFrame:SetAllPoints()

	TemporaryEnchantFrame:SetParent(header3)
	TemporaryEnchantFrame:SetAllPoints()

	UpdateTemporaryEnchantAnchors(header3)

	hooksecurefunc("BuffFrame_UpdateAllBuffAnchors", UpdateBuffAnchors)
	hooksecurefunc("DebuffButton_UpdateAnchors", UpdateDebuffAnchors)

	E:SkinAuraButton(ConsolidatedBuffs)

	ConsolidatedBuffsTooltip:SetScale(1)
end
