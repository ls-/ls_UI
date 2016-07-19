local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local B = E:GetModule("Bars")

-- Lua
local _G = _G
local unpack, pairs = unpack, pairs

-- Blizz
local BACKPACK_CONTAINER = BACKPACK_CONTAINER
local NUM_BAG_SLOTS = NUM_BAG_SLOTS
local GameTooltip = GameTooltip
local GetContainerNumFreeSlots = GetContainerNumFreeSlots
local GetContainerNumSlots = GetContainerNumSlots

-- Mine
local bagBar

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
		if not _G.InCombatLockdown() then
			if _G.CharacterBag0Slot:IsShown() then
				for i = 3, 0, -1 do
					_G["CharacterBag"..i.."Slot"]:Hide()
				end
			else
				for i = 0, 3 do
					_G["CharacterBag"..i.."Slot"]:Show()
				end
			end
		end

		_G.BackpackButton_UpdateChecked(self)
	else
		_G.ToggleAllBags()
		_G.BackpackButton_UpdateChecked(self)
	end
end

local function BackpackButton_OnEnter(self)
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(_G.CURRENCY..":")

	for i = 1, 3 do
		local name, count, icon = _G.GetBackpackCurrencyInfo(i)

		if name then
			GameTooltip:AddDoubleLine(name, count.."|T"..icon..":0|t", 1, 1, 1, 1, 1, 1)
		end
	end

	GameTooltip:AddDoubleLine("Gold", _G.GetMoneyString(_G.GetMoney()), 1, 1, 1, 1, 1, 1)
	GameTooltip:Show()
end

local function BackpackButton_Update(self, event, ...)
	if event == "BAG_UPDATE" then
		local bag = ...

		if bag >= BACKPACK_CONTAINER and bag <= NUM_BAG_SLOTS then
			local free, total = GetBagUsageInfo()

			self.icon:SetVertexColor(E:ColorGradient(1 - free / total, unpack(M.colors.gradient["GYR"])))
		end
	elseif event == "PLAYER_ENTERING_WORLD" or event == "FORCE_UPDATE" then
		local free, total = GetBagUsageInfo()

		self.icon:SetVertexColor(E:ColorGradient(1 - free / total, unpack(M.colors.gradient["GYR"])))
	end
end

function B:IsBagEnabled()
	return not not bagBar
end

function B:EnableBags()
	if _G.InCombatLockdown() then
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
		bagBar = _G.CreateFrame("Frame", "LSBagBar", _G.UIParent, "SecureHandlerBaseTemplate")

		E:SetupBar(bagBar, BAGS, BAGS_CFG.button_size, BAGS_CFG.button_gap, BAGS_CFG.direction, E.SkinBagButton)

		if C.bars.restricted then
			B:SetupControlledBar(bagBar, "Bags")
		else
			bagBar:SetPoint(unpack(BAGS_CFG.point))
			E:CreateMover(bagBar)
		end

		_G.MainMenuBarBackpackButton.icon:SetDesaturated(true)
		_G.MainMenuBarBackpackButton:SetScript("OnClick", BackpackButton_OnClick)
		_G.MainMenuBarBackpackButton:HookScript("OnEnter", BackpackButton_OnEnter)
		_G.MainMenuBarBackpackButton:HookScript("OnEvent", BackpackButton_Update)
		_G.hooksecurefunc(_G.MainMenuBarBackpackButton.icon, "SetDesaturated", ResetDesaturated)

		if forceInit then
			BackpackButton_Update(_G.MainMenuBarBackpackButton, "FORCE_UPDATE")
		end

		for _, bag in pairs(BAGS) do
			bag:UnregisterEvent("ITEM_PUSH")
			bag:SetParent(bagBar)

			if bag ~= _G.MainMenuBarBackpackButton then
				bag:Hide()
			end
		end
	end
end
