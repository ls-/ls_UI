local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local Mail = E:AddModule("Mail")

-- Lua
local _G = _G
local pairs = pairs
local twipe, tsort = table.wipe, table.sort

-- Blizz
local C_Timer = C_Timer
local GameTooltip = GameTooltip
local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS
local AutoLootMailItem = AutoLootMailItem
local DeleteInboxItem = DeleteInboxItem
local GetContainerNumFreeSlots = GetContainerNumFreeSlots
local GetInboxHeaderInfo = GetInboxHeaderInfo
local GetInboxItem = GetInboxItem
local GetInboxItemLink = GetInboxItemLink
local GetItemInfo = GetItemInfo
local TakeInboxItem = TakeInboxItem
local TakeInboxMoney = TakeInboxMoney

-- Mine
local ReceiveMail
local MailItems = {}

-- http://wow.gamepedia.com/Orderedpairs
local function orderednext(t, n)
	local key = t[t.__next]
	if not key then return end

	t.__next = t.__next + 1

	return key, t.__source[key]
end

local keys = {}
local function orderedpairs(t)
	local kn = 1

	twipe(keys)
	keys = {__source = t, __next = 1}

	for k in pairs(t) do
		keys[kn], kn = k, kn + 1
	end

	tsort(keys)

	return orderednext, keys
end

local function GetFreeSlots()
	local free = 0

	for i = 0, _G.NUM_BAG_SLOTS do
		local freeSlots, bagType = GetContainerNumFreeSlots(i)

		if bagType == 0 then
			free = free + freeSlots
		end
	end

	return free
end

local function ReceiveButton_OnEvent(self, event)
	if event == "MAIL_INBOX_UPDATE" then
		self:Enable()
		self:UnregisterEvent("MAIL_INBOX_UPDATE")

		self.Icon:SetDesaturated(false)
	elseif event == "MAIL_CLOSED" then
		self:Disable()
		self:RegisterEvent("MAIL_INBOX_UPDATE")

		self.Icon:SetDesaturated(true)
	end
end

local function ReceiveButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")

	local numMessages, totalMessages = _G.GetInboxNumItems()
	local gold, items, cod = 0, 0, 0
	twipe(MailItems)

	for i = 1, numMessages do
		local _, _, _, _, money, CODAmount, _, itemCount = GetInboxHeaderInfo(i)

		if money and money > 0 then
			gold = gold + money
		end

		if CODAmount and CODAmount> 0 then
			cod = cod + CODAmount
		end

		if itemCount then
			for j = 1, itemCount do
				local itemLink = GetInboxItemLink(i, j)
				if itemLink then
					local name, icon, count = GetInboxItem(i, j)
					local _, _, quality = GetItemInfo(itemLink)

					if MailItems[name] then
						MailItems[name].count = MailItems[name].count + count
					else
						MailItems[name] = {count = count, icon = "|T"..icon..":0|t", color = ITEM_QUALITY_COLORS[quality].hex}
					end
				end

				items = items + 1
			end
		end
	end

	if gold > 0 or cod > 0 or items > 0 then
		GameTooltip:AddLine(_G.MAIL_LABEL, 1, 1, 1)
	end

	if gold > 0 then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(_G.ENCLOSED_MONEY..":")
		GameTooltip:AddLine(_G.GetMoneyString(gold), 1, 1, 1)
	end

	if cod > 0 then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(_G.COD_AMOUNT)
		GameTooltip:AddLine(_G.GetMoneyString(cod), 1, 1, 1)
	end

	if items > 0 then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(_G.ITEMS..":")
		for k, v in orderedpairs(MailItems) do
			GameTooltip:AddDoubleLine(v.color..k.."|r", v.count..v.icon, 1, 1, 1, 1, 1, 1)
		end
	end

	GameTooltip:Show()
end

local function ReceiveButton_OnLeave(self)
	GameTooltip:Hide()
end

local function LazyLootMail(index, delay)
	local _, _, _, _, money, CODAmount, _, itemCount, _, _, _, _, isGM = GetInboxHeaderInfo(index)

	if index > 0 then
		if not (CODAmount and CODAmount > 0 or isGM) then
			if money == 0 and not itemCount then
				DeleteInboxItem(index)

				C_Timer.After(delay, function() LazyLootMail(index - 1, delay) end)
			else
				if GetFreeSlots() > 0 then
					local mod = 1

					if money > 0 then
						TakeInboxMoney(index)
					elseif itemCount and itemCount > 0 then
						mod = 1.33

						local name, _, count = GetInboxItem(index, itemCount)
						if not name then
							AutoLootMailItem(index)
						else
							TakeInboxItem(index, itemCount)
						end
					end

					C_Timer.After(delay * mod, function() LazyLootMail(index, delay) end)
				end
			end
		else
			LazyLootMail(index - 1, delay)
		end
	elseif index == 0 then
		_G.InboxFrame_Update()
		_G.CheckInbox()

		if Mail.overflow then
			ReceiveMail()
		else
			_G.InboxFrame.ReceiveButton:SetChecked(false)
			_G.MiniMapMailFrame:Hide()
		end
	end
end

function ReceiveMail()
	local _, _, lag = _G.GetNetStats()
	local numMessages, totalMessages = _G.GetInboxNumItems()
	Mail.overflow = totalMessages > numMessages

	LazyLootMail(numMessages, lag > 0 and lag / 750 or 0.1)
end

function Mail:Initialize()
	if C.mail.enabled then
		local button = E:CreateCheckButton(_G.InboxFrame, "$parentReceiveMailButton")
		button:SetPoint("BOTTOMRIGHT", _G.MailFrameInset, "TOPRIGHT", -2, 4)
		button:RegisterEvent("MAIL_INBOX_UPDATE")
		button:RegisterEvent("MAIL_CLOSED")
		button:SetScript("OnEvent", ReceiveButton_OnEvent)
		button:SetScript("OnEnter", ReceiveButton_OnEnter)
		button:SetScript("OnLeave", ReceiveButton_OnLeave)
		button:SetScript("OnClick", ReceiveMail)
		button:Disable()
		_G.InboxFrame.ReceiveButton = button

		button.Icon:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-ItemIntoBag")
		button.Icon:SetDesaturated(true)
	end
end
