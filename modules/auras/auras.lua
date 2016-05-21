local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local AURAS = E:AddModule("Auras")
local AURAS_CFG

local BuffFrame, TemporaryEnchantFrame = BuffFrame, TemporaryEnchantFrame

local function UpdateBuffAnchors()
	local numBuffs = 0
	local button, previous, above, index

	for i = 1, BUFF_ACTUAL_DISPLAY do
		button = _G["BuffButton"..i]
		numBuffs = numBuffs + 1
		index = numBuffs

		button:ClearAllPoints()
		button:SetSize(AURAS_CFG.aura_size, AURAS_CFG.aura_size)

		if index > 1 and (mod(index, 16) == 1) then
			button:SetPoint("TOP", above, "BOTTOM", 0, -AURAS_CFG.aura_gap)

			above = button
		elseif index == 1 then
			button:SetPoint("CENTER", LSBuffHeader, "CENTER", 0, 0)

			above = button
		else
			button:SetPoint("RIGHT", previous, "LEFT", -AURAS_CFG.aura_gap, 0)
		end

		E:SkinAuraButton(button)

		previous = button
	end
end

local function UpdateDebuffAnchors(name, i)
	local button = _G[name..i]
	button:ClearAllPoints()
	button:SetSize(AURAS_CFG.aura_size, AURAS_CFG.aura_size)

	if i == 1 then
		button:SetPoint("CENTER", LSDebuffHeader, "CENTER", 0, 0)
	else
		button:SetPoint("RIGHT", _G[name..(i - 1)], "LEFT", -AURAS_CFG.aura_gap, 0)
	end

	E:SkinAuraButton(button)
end

local function UpdateTemporaryEnchantAnchors()
	local button, previous

	for i = 1, NUM_TEMP_ENCHANT_FRAMES do
		button = _G["TempEnchant"..i]

		if button then
			button:ClearAllPoints()
			button:SetSize(AURAS_CFG.aura_size, AURAS_CFG.aura_size)

			if i == 1 then
				button:SetPoint("CENTER", 0, 0)
			else
				button:SetPoint("RIGHT", previous, "LEFT", -AURAS_CFG.aura_gap, 0)
			end

			E:SkinAuraButton(button)

			previous = button
		end
	end
end

function AURAS:Initialize()
	AURAS_CFG = C.auras

	if AURAS_CFG.enabled then
		local header1 = CreateFrame("Frame", "LSBuffHeader", UIParent)
		header1:SetSize(AURAS_CFG.aura_size + AURAS_CFG.aura_gap * 2,
			AURAS_CFG.aura_size + AURAS_CFG.aura_gap * 2)
		header1:SetPoint(unpack(AURAS_CFG.buff.point))
		E:CreateMover(header1)

		local header2 = CreateFrame("Frame", "LSDebuffHeader", UIParent)
		header2:SetSize(AURAS_CFG.aura_size + AURAS_CFG.aura_gap * 2,
			AURAS_CFG.aura_size + AURAS_CFG.aura_gap * 2)
		header2:SetPoint(unpack(AURAS_CFG.debuff.point))
		E:CreateMover(header2)

		local header3 = CreateFrame("Frame", "LSTempEnchantHeader", UIParent)
		header3:SetSize(AURAS_CFG.aura_size + AURAS_CFG.aura_gap * 2,
			AURAS_CFG.aura_size + AURAS_CFG.aura_gap * 2)
		header3:SetPoint(unpack(AURAS_CFG.tempench.point))
		E:CreateMover(header3)

		BuffFrame:SetParent(header1)
		BuffFrame:SetAllPoints()

		TemporaryEnchantFrame:SetParent(header3)
		TemporaryEnchantFrame:SetAllPoints()

		UpdateTemporaryEnchantAnchors(header3)

		hooksecurefunc("BuffFrame_UpdateAllBuffAnchors", UpdateBuffAnchors)
		hooksecurefunc("DebuffButton_UpdateAnchors", UpdateDebuffAnchors)
	end
end
