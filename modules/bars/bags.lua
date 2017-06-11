local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local BARS = P:GetModule("Bars")

-- Lua
local _G = getfenv(0)
local next = _G.next
local hooksecurefunc = _G.hooksecurefunc

-- Blizz
local BACKPACK_CONTAINER = _G.BACKPACK_CONTAINER
local NUM_BAG_SLOTS = _G.NUM_BAG_SLOTS
local GetTime = _G.GetTime
local C_Timer_After = _G.C_Timer.After
local IsContainerFiltered = _G.IsContainerFiltered
local GameTooltip = _G.GameTooltip
local BreakUpLargeNumbers = _G.BreakUpLargeNumbers
local GetMoneyString = _G.GetMoneyString
local GetMoney = _G.GetMoney
local GetCurrencyInfo = _G.GetCurrencyInfo
local GetBackpackCurrencyInfo = _G.GetBackpackCurrencyInfo
local MainMenuBarBackpackButton = _G.MainMenuBarBackpackButton

-- Mine
local isInit = false
local bar

local CURRENCY_TEMPLATE = "%s |T%s:0|t"
local CURRENCY_DETAILED_TEMPLATE = "%s / %s|T%s:0|t"

local BAGS = {
	MainMenuBarBackpackButton,
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
	num = 5,
	size = 32,
	spacing = 4,
	x_growth = "RIGHT",
	y_growth = "DOWN",
	per_row = 5,
	point = {
		p = "BOTTOM",
		anchor = "UIParent",
		rP = "BOTTOM",
		x = 434,
		y = 16
	},
}

local function GetBagUsageInfo()
	local free, total = 0, 0

	for i = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		local slots, bagType = _G.GetContainerNumFreeSlots(i)

		if bagType == 0 then
			free, total = free + slots, total + _G.GetContainerNumSlots(i)
		end
	end

	return free, total
end

local function BackpackButton_OnEnter()
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(L["CURRENCY_COLON"])

	for id in next, CURRENCIES do
		local name, cur, icon, _, _, max = GetCurrencyInfo(id)

		if name and icon then
			if max and max > 0 then
				if cur == max then
					GameTooltip:AddDoubleLine(name, CURRENCY_DETAILED_TEMPLATE:format(BreakUpLargeNumbers(cur), BreakUpLargeNumbers(max), icon), 1, 1, 1, M.COLORS.RED:GetRGB())
				else
					GameTooltip:AddDoubleLine(name, CURRENCY_DETAILED_TEMPLATE:format(BreakUpLargeNumbers(cur), BreakUpLargeNumbers(max), icon), 1, 1, 1, M.COLORS.GREEN:GetRGB())
				end
			else
				GameTooltip:AddDoubleLine(name, CURRENCY_TEMPLATE:format(BreakUpLargeNumbers(cur), icon), 1, 1, 1, 1, 1, 1)
			end
		end
	end

	for i = 1, 3 do
		local _, _, _, id = GetBackpackCurrencyInfo(i)

		if id then
			local name, cur, icon, _, _, max = GetCurrencyInfo(id)

			if not CURRENCIES[id] then
				if name and icon then
					if max and max > 0 then
						if cur == max then
							GameTooltip:AddDoubleLine(name, CURRENCY_DETAILED_TEMPLATE:format(BreakUpLargeNumbers(cur), BreakUpLargeNumbers(max), icon), 1, 1, 1, M.COLORS.RED:GetRGB())
						else
							GameTooltip:AddDoubleLine(name, CURRENCY_DETAILED_TEMPLATE:format(BreakUpLargeNumbers(cur), BreakUpLargeNumbers(max), icon), 1, 1, 1, M.COLORS.GREEN:GetRGB())
						end
					else
						GameTooltip:AddDoubleLine(name, CURRENCY_TEMPLATE:format(BreakUpLargeNumbers(cur), icon), 1, 1, 1, 1, 1, 1)
					end
				end
			end
		end
	end

	GameTooltip:AddDoubleLine(L["GOLD"], GetMoneyString(GetMoney(), true), 1, 1, 1, 1, 1, 1)
	GameTooltip:Show()
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

		if bag >= BACKPACK_CONTAINER and bag <= NUM_BAG_SLOTS then
			-- NOTE: this event is quite spammy, always combine few updates into one!
			local t = GetTime()

			if t - (self.recentUpdate or 0 ) >= 0.1 then
				C_Timer_After(0.1, function()
					self:Update()
				end)

				self.recentUpdate = t
			end
		end
	elseif event == "INVENTORY_SEARCH_UPDATE" then
		if IsContainerFiltered(BACKPACK_CONTAINER) then
			self.searchOverlay:Show();
		else
			self.searchOverlay:Hide();
		end
	end
end

function BARS:HasBags()
	return isInit
end

function BARS:CreateBags()
	if C.db.char.bars.bags.enabled then
		local config = self:IsRestricted() and CFG or C.db.profile.bars.bags

		bar = _G.CreateFrame("Frame", "LSBagBar", _G.UIParent, "SecureHandlerBaseTemplate")

		self:AddBar("bags", bar)

		-- hacks
		bar.Update = function(self)
			self._config = BARS:IsRestricted() and CFG or C.db.profile.bars.bags

			E:UpdateBarLayout(self)
		end

		MainMenuBarBackpackButton:HookScript("OnEnter", BackpackButton_OnEnter)
		MainMenuBarBackpackButton:SetScript("OnClick", BackpackButton_OnClick)
		MainMenuBarBackpackButton:SetScript("OnEvent", BackpackButton_OnEvent)

		for _, bag in next, BAGS do
			bag:UnregisterEvent("ITEM_PUSH")
			bag._parent = bar
			bag:SetParent(bar)
			E:SkinBagButton(bag)

			if bag ~= MainMenuBarBackpackButton then
				bag:Hide()
			end
		end

		MainMenuBarBackpackButton.Update = function(self)
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

		if self:IsRestricted() then
			self:ActionBarController_AddWidget(bar, "BAG")
		else
			local point = config.point

			bar:SetPoint(point.p, point.anchor, point.rP, point.x, point.y)
			E:CreateMover(bar)

			MainMenuBarBackpackButton.icon:SetDesaturated(true)
			hooksecurefunc(MainMenuBarBackpackButton.icon, "SetDesaturated", function(self, flag)
				if not flag then
					self:SetDesaturated(true)
				end
			end)
		end

		bar._buttons = BAGS

		bar:Update()

		MainMenuBarBackpackButton.Count:Show()
		MainMenuBarBackpackButton:Update()

		self.CreateBags = E.NOOP

		isInit = true
	end
end
