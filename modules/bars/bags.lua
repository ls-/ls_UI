local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local COLORS = M.colors
local GRADIENT = COLORS.gradient["GYR"]
local B = E:GetModule("Bars")

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

local BAGS_CFG = {
	button_size = 26,
	button_gap = 4,
	direction = "RIGHT",
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

	for i = 1, 3 do
		name, count, icon = GetBackpackCurrencyInfo(i)

		if name then
			GameTooltip:AddDoubleLine(name, count.."|T"..icon..":0|t", 1, 1, 1, 1, 1, 1)
		end
	end

	GameTooltip:AddDoubleLine("Gold", GetMoneyString(GetMoney()), 1, 1, 1, 1, 1, 1)
	GameTooltip:Show()
end

local function BackpackButton_Update(self, event, ...)
	if event == "BAG_UPDATE" then
		local bag = ...
		if bag >= BACKPACK_CONTAINER and bag <= NUM_BAG_SLOTS then
			local free, total = GetBagUsageInfo()

			self.icon:SetVertexColor(E:ColorGradient(1 - free / total, unpack(GRADIENT)))
		end
	elseif event == "CUSTOM_FORCE_UPDATE" then
		local free, total = GetBagUsageInfo()

		self.icon:SetVertexColor(E:ColorGradient(1 - free / total, unpack(GRADIENT)))
	end
end

function B:IsBagEnabled()
	return not not LSBagBar
end

function B:EnableBags()
	if InCombatLockdown() then
		return false, "|cffe52626Error!|r Can't be done, while in combat."
	end

	if not B:IsBagEnabled() then
		B:HandleBags(true)
	else
		return true, "|cffe56619Warning!|r Bag sub-module is already enabled."
	end

	return true, "|cff26a526Success!|r Bag sub-module is enabled."
end

function B:HandleBags(forceInit)
	if not C.bars.restricted then
		BAGS_CFG = C.bars.bags
	end

	if C.bars.bags.enabled or forceInit then
		local size = BAGS_CFG.button_size
		local bar = CreateFrame("Frame", "LSBagBar", UIParent, "SecureHandlerBaseTemplate")

		E:SetupBar(BAGS, BAGS_CFG.button_size, BAGS_CFG.button_gap, bar,
			BAGS_CFG.direction, E.SkinBagButton)

		if C.bars.restricted then
			B:SetupControlledBar(bar, "Bags")
		else
			bar:SetPoint(unpack(BAGS_CFG.point))
			E:CreateMover(bar)
		end

		MainMenuBarBackpackButton.icon:SetDesaturated(true)
		hooksecurefunc(MainMenuBarBackpackButton.icon, "SetDesaturated", ResetDesaturated)

		MainMenuBarBackpackButton:SetScript("OnClick", BackpackButton_OnClick)
		MainMenuBarBackpackButton:HookScript("OnEnter", BackpackButton_OnEnter)
		MainMenuBarBackpackButton:HookScript("OnEvent", BackpackButton_Update)

		if forceInit then
			BackpackButton_Update(MainMenuBarBackpackButton, "CUSTOM_FORCE_UPDATE")
		end

		for _, bag in next, BAGS do
			bag:UnregisterEvent("ITEM_PUSH")

			if bag ~= MainMenuBarBackpackButton then
				bag:Hide()
			end
		end
	end
end
