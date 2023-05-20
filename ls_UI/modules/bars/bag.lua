local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF, Profiler = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF, ns.Profiler
local MODULE = P:GetModule("Bars")

-- Lua
local _G = getfenv(0)
local next = _G.next
local t_wipe = _G.table.wipe

-- Mine
local isInit = false

local button_proto = {}
do
	local CURRENCY_TEMPLATE = "%s |T%s:0|t"
	local CURRENCY_DETAILED_TEMPLATE = "%s / %s|T%s:0|t"
	local _, TOKEN_NAME = GetItemInfoInstant(WOW_TOKEN_ITEM_ID) -- technically it's its item class
	local TOKEN_COLOR = ITEM_QUALITY_COLORS[8]

	local lastTokenUpdate = 0

	function button_proto:OnEnter()
		if KeybindFrames_InQuickKeybindMode() then
			self:QuickKeybindButtonOnEnter()
		else
			local p, rP, x, y = E:GetTooltipPoint(self)

			GameTooltip:SetOwner(self, "ANCHOR_NONE")
			GameTooltip:SetPoint(p, self, rP, x, y)
			GameTooltip:SetText(self.tooltipText, 1, 1, 1, 1)
			GameTooltip:AddLine(L["FREE_BAG_SLOTS_TOOLTIP"]:format(self.freeSlots))

			if C.db.profile.bars.bag.tooltip then
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(L["CURRENCY_COLON"])

				for id in next, C.db.profile.bars.bag.currency do
					local info = C_CurrencyInfo.GetCurrencyInfo(id)
					if info then
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
				end

				GameTooltip:AddDoubleLine(L["GOLD"], GetMoneyString(GetMoney(), true), 1, 1, 1, 1, 1, 1)

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

	function button_proto:OnEventHook(event, ...)
		if event == "UPDATE_BINDINGS" then
			-- that's not how it's supposed to be used, but it works
			self.tooltipText = MicroButtonTooltipText(BACKPACK_TOOLTIP, "TOGGLEBACKPACK")
		elseif event == "TOKEN_MARKET_PRICE_UPDATED" then
			lastTokenUpdate = GetTime()

			if ... == LE_TOKEN_RESULT_ERROR_DISABLED then
				return
			end

			if GameTooltip:IsOwned(self) then
				GameTooltip:Hide()

				self:OnEnter()
			end
		end
	end
end

function MODULE:HasBag()
	return isInit
end

function MODULE:CreateBag()
	if not isInit then
		Mixin(MainMenuBarBackpackButton, button_proto)
		MainMenuBarBackpackButton:SetScript("OnEnter", MainMenuBarBackpackButton.OnEnter)
		MainMenuBarBackpackButton:HookScript("OnEvent", MainMenuBarBackpackButton.OnEventHook)
		MainMenuBarBackpackButton:RegisterEvent("UPDATE_BINDINGS")
		MainMenuBarBackpackButton:RegisterEvent("TOKEN_MARKET_PRICE_UPDATED")

		MainMenuBarBackpackButton.tooltipText = MicroButtonTooltipText(BACKPACK_TOOLTIP, "TOGGLEBACKPACK")

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
