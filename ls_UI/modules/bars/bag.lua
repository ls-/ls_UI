local _, ns = ...
local E, C, PrC, M, L, P = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Bars")

-- Lua
local _G = getfenv(0)
local next = _G.next

-- Mine
local isInit = false

local function getTooltipPoint(self)
	local quadrant = E:GetScreenQuadrant(self)
	local p, rP, x, y = "TOPLEFT", "BOTTOMRIGHT", 2, -2

	if quadrant == "BOTTOMLEFT" or quadrant == "BOTTOM" then
		p, rP, x, y = "BOTTOMLEFT", "TOPRIGHT", 2, 2
	elseif quadrant == "TOPRIGHT" or quadrant == "RIGHT" then
		p, rP, x, y = "TOPRIGHT", "BOTTOMLEFT", -2, -2
	elseif quadrant == "BOTTOMRIGHT" then
		p, rP, x, y = "BOTTOMRIGHT", "TOPLEFT", -2, 2
	end

	return p, rP, x, y
end

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
			local p, rP, x, y = getTooltipPoint(self)

			GameTooltip:SetOwner(self, "ANCHOR_NONE")
			GameTooltip:SetPoint(p, self, rP, x, y)
			GameTooltip:SetText(self.tooltipText, 1, 1, 1, 1)
			GameTooltip:AddLine(L["FREE_BAG_SLOTS_TOOLTIP"]:format(self.freeSlots))

			if self._parent._config.tooltip then
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(L["CURRENCY_COLON"])

				for id in next, C.db.profile.bars.bag.currency do
					local info = C_CurrencyInfo.GetCurrencyInfo(id)
					if info then
						if info.maxQuantity and info.maxQuantity > 0 then
							if info.quantity == info.maxQuantity then
								GameTooltip:AddDoubleLine(info.name, CURRENCY_DETAILED_TEMPLATE:format(BreakUpLargeNumbers(info.quantity), BreakUpLargeNumbers(info.maxQuantity), info.iconFileID), 1, 1, 1, E:GetRGB(C.db.global.colors.red))
							else
								GameTooltip:AddDoubleLine(info.name, CURRENCY_DETAILED_TEMPLATE:format(BreakUpLargeNumbers(info.quantity), BreakUpLargeNumbers(info.maxQuantity), info.iconFileID), 1, 1, 1, E:GetRGB(C.db.global.colors.green))
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

local bar_proto = {
	UpdateCooldownConfig = E.NOOP,
	UpdateLayout = E.NOOP,
	ForEach = E.NOOP,
}
do
	function bar_proto:UpdateConfig()
		self._config = E:CopyTable(C.db.profile.bars.bag, self._config)
	end

	function bar_proto:Update()
		self:UpdateConfig()
		self:UpdateFading()
	end
end

function MODULE:HasBag()
	return isInit
end

function MODULE:CreateBag()
	if not isInit then
		local bar = Mixin(self:Create("bag", "LSBagBar"), bar_proto)
		bar:SetSize(216, 44)

		MainMenuBarBackpackButton:SetParent(bar)
		BagBarExpandToggle:SetParent(bar)
		CharacterBag0Slot:SetParent(bar)
		CharacterBag1Slot:SetParent(bar)
		CharacterBag2Slot:SetParent(bar)
		CharacterBag3Slot:SetParent(bar)
		CharacterReagentBag0Slot:SetParent(bar)

		local point = C.db.profile.bars.bag.point
		bar:SetPoint(point.p, point.anchor, point.rP, point.x, point.y)
		E.Movers:Create(bar)

		Mixin(MainMenuBarBackpackButton, button_proto)
		MainMenuBarBackpackButton:SetPoint("TOPRIGHT", 4, 2)
		MainMenuBarBackpackButton:SetScript("OnEnter", MainMenuBarBackpackButton.OnEnter)
		MainMenuBarBackpackButton:HookScript("OnEvent", MainMenuBarBackpackButton.OnEventHook)
		MainMenuBarBackpackButton:RegisterEvent("UPDATE_BINDINGS")
		MainMenuBarBackpackButton:RegisterEvent("TOKEN_MARKET_PRICE_UPDATED")

		MainMenuBarBackpackButton._parent = bar
		MainMenuBarBackpackButton.tooltipText = MicroButtonTooltipText(BACKPACK_TOOLTIP, "TOGGLEBACKPACK")
		MainMenuBarBackpackButton.UpdateTooltip = MainMenuBarBackpackButton.OnEnter

		isInit = true

		self:UpdateBag()
	end
end

function MODULE:UpdateBag()
	if isInit then
		self:Get("bag"):Update()
	end
end
