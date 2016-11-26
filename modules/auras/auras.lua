local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local AURAS = P:AddModule("Auras")

-- Lua
local _G = _G
local unpack = unpack
local mfmod = math.fmod

-- Blizz
local BuffFrame, TemporaryEnchantFrame = BuffFrame, TemporaryEnchantFrame

-- Mine
local AURAS_CFG
local buffHeader, debuffHeader, enchHeader

local function UpdateBuffAnchors()
	local numBuffs = 0
	local button, previous, above

	for i = 1, _G.BUFF_ACTUAL_DISPLAY do
		button = _G["BuffButton"..i]
		numBuffs = numBuffs + 1

		button:ClearAllPoints()
		button:SetSize(AURAS_CFG.aura_size, AURAS_CFG.aura_size)

		if numBuffs > 1 and (mfmod(numBuffs, 16) == 1) then
			button:SetPoint("TOP", above, "BOTTOM", 0, -AURAS_CFG.aura_gap)

			above = button
		elseif numBuffs == 1 then
			button:SetPoint("CENTER", buffHeader, "CENTER", 0, 0)

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
		button:SetPoint("CENTER", debuffHeader, "CENTER", 0, 0)
	else
		button:SetPoint("RIGHT", _G[name..(i - 1)], "LEFT", -AURAS_CFG.aura_gap, 0)
	end

	E:SkinAuraButton(button)
end

local function UpdateTemporaryEnchantAnchors()
	local button, previous

	for i = 1, _G.NUM_TEMP_ENCHANT_FRAMES do
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

function AURAS:Init()
	AURAS_CFG = C.auras

	if AURAS_CFG.enabled then
		buffHeader = _G.CreateFrame("Frame", "LSBuffHeader", _G.UIParent)
		buffHeader:SetSize(AURAS_CFG.aura_size + AURAS_CFG.aura_gap * 2,
			AURAS_CFG.aura_size + AURAS_CFG.aura_gap * 2)
		buffHeader:SetPoint(unpack(AURAS_CFG.buff.point))
		E:CreateMover(buffHeader)

		debuffHeader = _G.CreateFrame("Frame", "LSDebuffHeader", _G.UIParent)
		debuffHeader:SetSize(AURAS_CFG.aura_size + AURAS_CFG.aura_gap * 2,
			AURAS_CFG.aura_size + AURAS_CFG.aura_gap * 2)
		debuffHeader:SetPoint(unpack(AURAS_CFG.debuff.point))
		E:CreateMover(debuffHeader)

		enchHeader = _G.CreateFrame("Frame", "LSTempEnchantHeader", _G.UIParent)
		enchHeader:SetSize(AURAS_CFG.aura_size + AURAS_CFG.aura_gap * 2,
			AURAS_CFG.aura_size + AURAS_CFG.aura_gap * 2)
		enchHeader:SetPoint(unpack(AURAS_CFG.tempench.point))
		E:CreateMover(enchHeader)

		BuffFrame:SetParent(buffHeader)
		BuffFrame:SetAllPoints()

		TemporaryEnchantFrame:SetParent(enchHeader)
		TemporaryEnchantFrame:SetAllPoints()

		UpdateTemporaryEnchantAnchors(enchHeader)
		_G.TemporaryEnchantFrame_Update(_G.GetWeaponEnchantInfo())

		_G.hooksecurefunc("BuffFrame_UpdateAllBuffAnchors", UpdateBuffAnchors)
		_G.hooksecurefunc("DebuffButton_UpdateAnchors", UpdateDebuffAnchors)
	end
end
