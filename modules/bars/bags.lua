local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local BARS = P:GetModule("Bars")

-- Lua
local _G = _G
local unpack = _G.unpack
local pairs = _G.pairs

-- Mine
local isInit = false
local CURRENCY = _G.CURRENCY..":"

local CFG = {
	visible = true,
	button_size = 32,
	button_gap = 4,
	init_anchor = "TOPLEFT",
	buttons_per_row = 5,
}

local BAGS = {
	_G.MainMenuBarBackpackButton,
	_G.CharacterBag0Slot,
	_G.CharacterBag1Slot,
	_G.CharacterBag2Slot,
	_G.CharacterBag3Slot
}

local function GetBagUsageInfo()
	local free, total = 0, 0

	for i = _G.BACKPACK_CONTAINER, _G.NUM_BAG_SLOTS do
		local slots, bagType = _G.GetContainerNumFreeSlots(i)

		if bagType == 0 then
			free, total = free + slots, total + _G.GetContainerNumSlots(i)
		end
	end

	return free, total
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
	_G.GameTooltip:AddLine(" ")
	_G.GameTooltip:AddLine(CURRENCY)

	for i = 1, 3 do
		local name, count, icon = _G.GetBackpackCurrencyInfo(i)

		if name then
			_G.GameTooltip:AddDoubleLine(name, count.."|T"..icon..":0|t", 1, 1, 1, 1, 1, 1)
		end
	end

	_G.GameTooltip:AddDoubleLine("Gold", _G.GetMoneyString(_G.GetMoney()), 1, 1, 1, 1, 1, 1)
	_G.GameTooltip:Show()
end

local function BackpackButton_Update(self, event, ...)
	if event == "BAG_UPDATE" then
		local bag = ...

		if bag >= _G.BACKPACK_CONTAINER and bag <= _G.NUM_BAG_SLOTS then
			local free, total = GetBagUsageInfo()

			self.icon:SetVertexColor(M.COLORS.GYR:GetRGB(1 - free / total))
		end
	elseif event == "PLAYER_ENTERING_WORLD" or event == "FORCE_UPDATE" then
		local free, total = GetBagUsageInfo()

		self.icon:SetVertexColor(M.COLORS.GYR:GetRGB(1 - free / total))
	end
end

-----------------
-- INITIALISER --
-----------------

function BARS:Bags_IsInit()
	return isInit
end

function BARS:Bags_Init()
	if not isInit and C.bars.bags.enabled then
		if not C.bars.restricted then
			CFG = C.bars.bags
		end

		local bar = _G.CreateFrame("Frame", "LSBagBar", _G.UIParent, "SecureHandlerBaseTemplate")

		E:SaveFrameState(bar, "visibility", "show")

		_G.RegisterStateDriver(bar, "visibility", CFG.visible and "show" or "hide")

		_G.MainMenuBarBackpackButton:SetScript("OnClick", BackpackButton_OnClick)
		_G.MainMenuBarBackpackButton:HookScript("OnEnter", BackpackButton_OnEnter)
		_G.MainMenuBarBackpackButton:HookScript("OnEvent", BackpackButton_Update)

		for _, bag in pairs(BAGS) do
			bag:UnregisterEvent("ITEM_PUSH")
			bag:SetParent(bar)
			E:SkinBagButton(bag)

			if bag ~= _G.MainMenuBarBackpackButton then
				bag:Hide()
			end
		end

		_G.MainMenuBarBackpackButton.icon:SetDesaturated(true)
		_G.hooksecurefunc(_G.MainMenuBarBackpackButton.icon, "SetDesaturated", function(self, flag)
			if not flag then
				self:SetDesaturated(true)
			end
		end)

		bar.buttons = BAGS

		E:UpdateBarLayout(bar, bar.buttons, CFG.button_size, CFG.button_gap, CFG.init_anchor, CFG.buttons_per_row)

		if not C.bars.restricted then
			bar:SetPoint(unpack(CFG.point))
			E:CreateMover(bar)
		else
			self:ActionBarController_AddWidget(bar, "BAG")
		end

		-- Finalise
		_G.MainMenuBarBackpackButton_UpdateFreeSlots()
		BackpackButton_Update(_G.MainMenuBarBackpackButton, "FORCE_UPDATE")

		isInit = true

		return true
	end
end
