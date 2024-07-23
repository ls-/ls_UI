local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF
local MODULE = P:GetModule("Bars")

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local next = _G.next
local t_insert = _G.table.insert
local t_sort = _G.table.sort
local t_wipe = _G.table.wipe

-- Mine
local isInit = false

local bags = {
	CharacterBag0Slot,
	CharacterBag1Slot,
	CharacterBag2Slot,
	CharacterBag3Slot,
	CharacterReagentBag0Slot,
}

local backpack_proto = {}
do
	local CURRENCY_COLON = _G.CURRENCY .. _G.HEADER_COLON
	local CURRENCY_DETAILED_TEMPLATE = "%s / %s|T%s:0|t"
	local CURRENCY_TEMPLATE = "%s |T%s:0|t"
	local GOLD = _G.BONUS_ROLL_REWARD_MONEY
	local _, TOKEN_NAME = C_Item.GetItemInfoInstant(WOW_TOKEN_ITEM_ID)
	local TOKEN_COLOR = ITEM_QUALITY_COLORS[8]

	local function sorter(a, b)
		return a.name < b.name
	end

	local currencyList = {}
	local lastTokenUpdate = 0

	function backpack_proto:OnEnterHook()
		if not KeybindFrames_InQuickKeybindMode() then
			local p, rP, x, y = E:GetTooltipPoint(self)

			GameTooltip:SetAnchorType("ANCHOR_NONE")
			GameTooltip:SetPoint(p, self, rP, x, y)

			if C.db.profile.bars.bag.tooltip then
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(CURRENCY_COLON)

				t_wipe(currencyList)

				for id in next, C.db.profile.bars.bag.currency do
					local info = C_CurrencyInfo.GetCurrencyInfo(id)
					if info then
						t_insert(currencyList, info)
					end
				end

				t_sort(currencyList, sorter)

				for i = 1, #currencyList do
					local info = currencyList[i]
					if info.maxQuantity and info.maxQuantity > 0 then
						if info.quantity == info.maxQuantity then
							GameTooltip:AddDoubleLine(info.name, CURRENCY_DETAILED_TEMPLATE:format(BreakUpLargeNumbers(info.quantity), BreakUpLargeNumbers(info.maxQuantity), info.iconFileID), 1, 1, 1, C.db.global.colors.red:GetRGB())
						else
							GameTooltip:AddDoubleLine(info.name, CURRENCY_DETAILED_TEMPLATE:format(BreakUpLargeNumbers(info.quantity), BreakUpLargeNumbers(info.maxQuantity), info.iconFileID), 1, 1, 1, C.db.global.colors.green:GetRGB())
						end
					else
						GameTooltip:AddDoubleLine(info.name, CURRENCY_TEMPLATE:format(BreakUpLargeNumbers(info.quantity), info.iconFileID), 1, 1, 1, 1, 1, 1)
					end
				end

				GameTooltip:AddDoubleLine(GOLD, GetMoneyString(GetMoney(), true), 1, 1, 1, 1, 1, 1)

				local tokenPrice = C_WowTokenPublic.GetCurrentMarketPrice()
				if tokenPrice and tokenPrice > 0 then
					GameTooltip:AddDoubleLine(TOKEN_NAME, GetMoneyString(tokenPrice, true), TOKEN_COLOR.r, TOKEN_COLOR.g, TOKEN_COLOR.b, 1, 1, 1)
				elseif GetTime() - lastTokenUpdate > 300 then -- 300 is pollTimeSeconds = select(2, C_WowTokenPublic.GetCommerceSystemStatus())
					C_WowTokenPublic.UpdateMarketPrice()
				end
			end

			GameTooltip:Show()
		end
	end

	function backpack_proto:OnEventHook(event, ...)
		if event == "TOKEN_MARKET_PRICE_UPDATED" then
			lastTokenUpdate = GetTime()

			if ... == LE_TOKEN_RESULT_ERROR_DISABLED then
				return
			end

			if GameTooltip:IsOwned(self) then
				GameTooltip:Hide()

				self:GetScript("OnEnter")(self)
			end
		end
	end
end

local bag_proto = {}
do
	function bag_proto:OnEnterHook()
		if not KeybindFrames_InQuickKeybindMode() then
			local p, rP, x, y = E:GetTooltipPoint(self)

			GameTooltip:SetAnchorType("ANCHOR_NONE")
			GameTooltip:SetPoint(p, self, rP, x, y)
		end
	end
end

function MODULE:HasBag()
	return isInit
end

function MODULE:CreateBag()
	if not isInit then
		Mixin(MainMenuBarBackpackButton, backpack_proto)

		MainMenuBarBackpackButton:HookScript("OnEnter", MainMenuBarBackpackButton.OnEnterHook)
		MainMenuBarBackpackButton:HookScript("OnEvent", MainMenuBarBackpackButton.OnEventHook)
		MainMenuBarBackpackButton:RegisterEvent("TOKEN_MARKET_PRICE_UPDATED")

		for _, bag in next, bags do
			Mixin(bag, bag_proto)

			bag:HookScript("OnEnter", bag.OnEnterHook)
			hooksecurefunc(bag, "UpdateTooltip", bag.OnEnterHook)
		end

		E:SetUpFading(BagsBar)

		isInit = true

		self:UpdateBag()
	end
end

function MODULE:UpdateBag()
	if isInit then
		BagsBar._config = t_wipe(BagsBar._config or {})
		BagsBar._config.fade = E:CopyTable(C.db.profile.bars.bag.fade, BagsBar._config.fade)

		BagsBar:UpdateFading()
	end
end
