local _, ns = ...
local E, M = ns.E, ns.M

local COLORS = ns.M.colors

E.Bags = {}

local Bags = E.Bags

local BACKPACK_CONTAINER, NUM_BAG_SLOTS = BACKPACK_CONTAINER, NUM_BAG_SLOTS

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

	return total - free, total, free
end

local function BagUsageToColor(used, total)
	local usage = E:NumberToPerc(used, total)

	if usage ~= 0 then
		if usage > 85 then
			return unpack(COLORS.red)
		elseif usage > 50 then
			return unpack(COLORS.yellow)
		else
			return unpack(COLORS.green)
		end
	else
		return unpack(COLORS.black)
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

local function BackpackButton_OnEvent(self, event, ...)
	if event == "BAG_UPDATE" then
		local bag = ...
		if bag >= BACKPACK_CONTAINER and bag <= NUM_BAG_SLOTS then
			self.icon:SetVertexColor(BagUsageToColor(GetBagUsageInfo()))
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		self.icon:SetVertexColor(BagUsageToColor(GetBagUsageInfo()))
	end
end

function Bags:Initialize()
	local BAGS_CONFIG = ns.C.bags

	local header = CreateFrame("Frame", "lsBagsHeader", UIParent, "SecureHandlerBaseTemplate")
	header:SetFrameStrata("LOW")
	header:SetFrameLevel(1)

	if BAGS_CONFIG.direction == "RIGHT" or BAGS_CONFIG.direction == "LEFT" then
		header:SetSize(BAGS_CONFIG.button_size * 5 + BAGS_CONFIG.button_gap * 5,
			BAGS_CONFIG.button_size + BAGS_CONFIG.button_gap)
	else
		header:SetSize(BAGS_CONFIG.button_size + BAGS_CONFIG.button_gap,
			BAGS_CONFIG.button_size * 5 + BAGS_CONFIG.button_gap * 5)
	end

	header:SetPoint(unpack(BAGS_CONFIG.point))

	E:SetButtonPosition(BAGS, BAGS_CONFIG.button_size, BAGS_CONFIG.button_gap, header,
		BAGS_CONFIG.direction, E.SkinBagButton)

	MainMenuBarBackpackButton.icon:SetDesaturated(true)
	MainMenuBarBackpackButton.icon.SetDesaturated = function() return end

	MainMenuBarBackpackButton:SetScript("OnClick", BackpackButton_OnClick)
	MainMenuBarBackpackButton:HookScript("OnEvent", BackpackButton_OnEvent)

	for _, bag in next, BAGS do
		bag:UnregisterEvent("ITEM_PUSH")

		if bag ~= MainMenuBarBackpackButton then
			bag:Hide()
		end
	end
end
