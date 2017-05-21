local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local BARS = P:GetModule("Bars")

-- Lua
local _G = getfenv(0)
local unpack = _G.unpack
local pairs = _G.pairs

-- Mine
local isInit = false

local BAGS = {
	_G.MainMenuBarBackpackButton,
	_G.CharacterBag0Slot,
	_G.CharacterBag1Slot,
	_G.CharacterBag2Slot,
	_G.CharacterBag3Slot
}

local CURRENCIES = {
	[1226] = true, -- Nethershards
	[1273] = true, -- Seal of Broken Fate
	[1342] = true, -- Legionfall War Supplies
}

local CFG = {
	visible = true,
	button_size = 32,
	button_gap = 4,
	init_anchor = "TOPLEFT",
	buttons_per_row = 5,
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

local function BackpackButton_OnEnter()
	_G.GameTooltip:AddLine(" ")
	_G.GameTooltip:AddLine(L["CURRENCY_COLON"])

	for id in pairs(CURRENCIES) do
		local name, cur, icon, _, _, max = _G.GetCurrencyInfo(id)

		if name and icon then
			if max and max > 0 then
				if cur == max then
					_G.GameTooltip:AddDoubleLine(name, _G.BreakUpLargeNumbers(cur).." / ".._G.BreakUpLargeNumbers(max).."|T"..icon..":0|t", 1, 1, 1, M.COLORS.RED:GetRGB())
				else
					_G.GameTooltip:AddDoubleLine(name, _G.BreakUpLargeNumbers(cur).." / ".._G.BreakUpLargeNumbers(max).."|T"..icon..":0|t", 1, 1, 1, M.COLORS.GREEN:GetRGB())
				end
			else
				_G.GameTooltip:AddDoubleLine(name, _G.BreakUpLargeNumbers(cur).."|T"..icon..":0|t", 1, 1, 1, 1, 1, 1)
			end
		end
	end

	for i = 1, 3 do
		local _, _, _, id = _G.GetBackpackCurrencyInfo(i)

		if id then
			local name, cur, icon, _, _, max = _G.GetCurrencyInfo(id)

			if not CURRENCIES[id] then
				if name and icon then
					if max and max > 0 then
						if cur == max then
							_G.GameTooltip:AddDoubleLine(name, _G.BreakUpLargeNumbers(cur).." / ".._G.BreakUpLargeNumbers(max).."|T"..icon..":0|t", 1, 1, 1, M.COLORS.RED:GetRGB())
						else
							_G.GameTooltip:AddDoubleLine(name, _G.BreakUpLargeNumbers(cur).." / ".._G.BreakUpLargeNumbers(max).."|T"..icon..":0|t", 1, 1, 1, M.COLORS.GREEN:GetRGB())
						end
					else
						_G.GameTooltip:AddDoubleLine(name, _G.BreakUpLargeNumbers(cur).."|T"..icon..":0|t", 1, 1, 1, 1, 1, 1)
					end
				end
			end
		end
	end

	_G.GameTooltip:AddDoubleLine(L["GOLD"], _G.GetMoneyString(_G.GetMoney(), true), 1, 1, 1, 1, 1, 1)
	_G.GameTooltip:Show()
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

local function BackpackButton_OnEvent(self, event, ...)
	if event == "BAG_UPDATE" then
		local bag = ...

		if bag >= _G.BACKPACK_CONTAINER and bag <= _G.NUM_BAG_SLOTS then
			-- NOTE: this event is quite spammy, always combine few updates into one!
			local t = _G.GetTime()

			if t - (self.recentUpdate or 0 ) >= 0.1 then
				_G.C_Timer.After(0.1, function()
					self:Update()
				end)

				self.recentUpdate = t
			end
		end
	elseif event == "INVENTORY_SEARCH_UPDATE" then
		if _G.IsContainerFiltered(_G.BACKPACK_CONTAINER) then
			self.searchOverlay:Show();
		else
			self.searchOverlay:Hide();
		end
	end
end

-----------------
-- INITIALISER --
-----------------

function BARS:Bags_IsInit()
	return isInit
end

function BARS:Bags_Init()
	if not isInit and C.db.char.bars.bags.enabled then
		if not self:ActionBarController_IsInit() then
			CFG = C.db.profile.bars.bags
		end

		local bar = _G.CreateFrame("Frame", "LSBagBar", _G.UIParent, "SecureHandlerBaseTemplate")
		E:SaveFrameState(bar, "visibility", "show")
		_G.RegisterStateDriver(bar, "visibility", CFG.visible and "show" or "hide")

		_G.MainMenuBarBackpackButton:HookScript("OnEnter", BackpackButton_OnEnter)
		_G.MainMenuBarBackpackButton:SetScript("OnClick", BackpackButton_OnClick)
		_G.MainMenuBarBackpackButton:SetScript("OnEvent", BackpackButton_OnEvent)

		for _, bag in pairs(BAGS) do
			bag:UnregisterEvent("ITEM_PUSH")
			bag:SetParent(bar)
			E:SkinBagButton(bag)

			if bag ~= _G.MainMenuBarBackpackButton then
				bag:Hide()
			end
		end

		_G.MainMenuBarBackpackButton.Update = function(self)
			local free, total = GetBagUsageInfo()
			local r, g, b = M.COLORS.GYR:GetRGB(1 - free / total)
			local indicator = self:GetParent().Indicator

			if indicator then
				indicator.Texture:SetVertexColor(r, g, b)

				indicator:SetMinMaxValues(0, total)
				indicator:SetValue(total - free)
			else
				self.icon:SetVertexColor(r, g, b)
			end

			self.Count:SetText(free)
			self.freeSlots = free
		end

		bar.buttons = BAGS

		E:UpdateBarLayout(bar, bar.buttons, CFG.button_size, CFG.button_gap, CFG.init_anchor, CFG.buttons_per_row)

		if self:ActionBarController_IsInit() then
			self:ActionBarController_AddWidget(bar, "BAG")
		else
			bar:SetPoint(unpack(CFG.point))
			E:CreateMover(bar)

			_G.MainMenuBarBackpackButton.icon:SetDesaturated(true)
			_G.hooksecurefunc(_G.MainMenuBarBackpackButton.icon, "SetDesaturated", function(self, flag)
				if not flag then
					self:SetDesaturated(true)
				end
			end)
		end

		-- Finalise
		_G.MainMenuBarBackpackButton.Count:Show()
		_G.MainMenuBarBackpackButton:Update()

		isInit = true

		return true
	end
end
