local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local COLORS = M.colors
local GRADIENT = COLORS.gradient["GYR"]
local B = E:GetModule("Bars")
local BAGS_CFG

local unpack = unpack
local BACKPACK_CONTAINER, NUM_BAG_SLOTS = BACKPACK_CONTAINER, NUM_BAG_SLOTS
local MainMenuBarBackpackButton, CharacterBag0Slot, CharacterBag1Slot, CharacterBag2Slot, CharacterBag3Slot =
	MainMenuBarBackpackButton, CharacterBag0Slot, CharacterBag1Slot, CharacterBag2Slot, CharacterBag3Slot
local GameTooltip = GameTooltip
local GetContainerNumFreeSlots, GetContainerNumSlots = GetContainerNumFreeSlots, GetContainerNumSlots
local BackpackButton_UpdateChecked = BackpackButton_UpdateChecked
local ToggleAllBags = ToggleAllBags

local BAGS = {
	MainMenuBarBackpackButton,
	CharacterBag0Slot,
	CharacterBag1Slot,
	CharacterBag2Slot,
	CharacterBag3Slot
}

local function GetBagUsageInfo()
	local free, total, slots, bagType = 0, 0

	for i = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		slots, bagType = GetContainerNumFreeSlots(i)

		if bagType == 0 then
			free, total = free + slots, total + GetContainerNumSlots(i)
		end
	end

	return free, total
end

local function ResetDesaturated(self, flag)
	if not flag then
		self:SetDesaturated(true)
	end
end

local function BackpackButton_OnClick(self, button)
	if button == "RightButton" then
		if not InCombatLockdown() then
			if CharacterBag0Slot:IsShown() then
				for i = 3, 0, -1 do
					_G["CharacterBag"..i.."Slot"]:Hide()
				end
			else
				for i = 0, 3 do
					_G["CharacterBag"..i.."Slot"]:Show()
				end
			end
		end

		BackpackButton_UpdateChecked(self)
	else
		ToggleAllBags()

		BackpackButton_UpdateChecked(self)
	end
end

local function BackpackButton_OnEnter(self)
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(CURRENCY..":")

	for i=1, 3 do
		name, count, icon = GetBackpackCurrencyInfo(i)

		if name then
			GameTooltip:AddDoubleLine(name, count.."|T"..icon..":0|t", 1, 1, 1, 1, 1, 1)
		end
	end

	GameTooltip:AddDoubleLine("Gold", GetMoneyString(GetMoney()), 1, 1, 1, 1, 1, 1)
	GameTooltip:Show()
end

local function BackpackButton_OnEvent(self, event, ...)
	if event == "BAG_UPDATE" then
		local bag = ...
		if bag >= BACKPACK_CONTAINER and bag <= NUM_BAG_SLOTS then
			local free, total = GetBagUsageInfo()

			self.icon:SetVertexColor(E:ColorGradient(1 - free / total, unpack(GRADIENT)))
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		local free, total = GetBagUsageInfo()

		self.icon:SetVertexColor(E:ColorGradient(1 - free / total, unpack(GRADIENT)))
	end
end

function B:HandleBags()
	BAGS_CFG = C.bars.bags

	if BAGS_CFG.enabled then
		local header = CreateFrame("Frame", "lsBagsHeader", UIParent, "SecureHandlerBaseTemplate")
		header:SetFrameStrata("LOW")
		header:SetFrameLevel(1)

		if BAGS_CFG.direction == "RIGHT" or BAGS_CFG.direction == "LEFT" then
			header:SetSize(BAGS_CFG.button_size * 5 + BAGS_CFG.button_gap * 5,
				BAGS_CFG.button_size + BAGS_CFG.button_gap)
		else
			header:SetSize(BAGS_CFG.button_size + BAGS_CFG.button_gap,
				BAGS_CFG.button_size * 5 + BAGS_CFG.button_gap * 5)
		end

		header:SetPoint(unpack(BAGS_CFG.point))

		E:CreateMover(header)

		E:SetButtonPosition(BAGS, BAGS_CFG.button_size, BAGS_CFG.button_gap, header,
			BAGS_CFG.direction, E.SkinBagButton)

		MainMenuBarBackpackButton.icon:SetDesaturated(true)

		hooksecurefunc(MainMenuBarBackpackButton.icon, "SetDesaturated", ResetDesaturated)

		MainMenuBarBackpackButton:SetScript("OnClick", BackpackButton_OnClick)
		MainMenuBarBackpackButton:HookScript("OnEnter", BackpackButton_OnEnter)
		MainMenuBarBackpackButton:HookScript("OnEvent", BackpackButton_OnEvent)

		for _, bag in next, BAGS do
			bag:UnregisterEvent("ITEM_PUSH")

			if bag ~= MainMenuBarBackpackButton then
				bag:Hide()
			end
		end
	end
end
