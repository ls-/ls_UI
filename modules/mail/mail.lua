local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local Mail = P:AddModule("Mail")

-- Lua
local _G = _G
local pairs = _G.pairs
local table = _G.table

-- Mine
local mailItems = {}
local isInit = false
local isReceiving = false
local overflow
local ReceiveMail

-----------
-- UTILS --
-----------

local function SortByName(a, b)
	return a.name < b.name
end

local function GetIndexForName(t, name)
	for k, v in pairs(t) do
		if name == v.name then
			return k
		end
	end

	return
end

local function GetFreeSlots()
	local free = 0

	for i = 0, _G.NUM_BAG_SLOTS do
		local freeSlots, bagType = _G.GetContainerNumFreeSlots(i)

		if bagType == 0 then
			free = free + freeSlots
		end
	end

	return free
end

local function LazyLootMail(index, delay)
	if not _G.MailFrame:IsShown() then
		isReceiving = false

		return
	end

	local _, _, _, _, money, CODAmount, _, itemCount, _, _, _, _, isGM = _G.GetInboxHeaderInfo(index)

	if index > 0 then
		if not (CODAmount and CODAmount > 0 or isGM) then
			if money == 0 and not itemCount then
				_G.DeleteInboxItem(index)

				_G.C_Timer.After(delay, function() LazyLootMail(index - 1, delay) end)
			else
				if GetFreeSlots() > 0 then
					local mod = 1

					if money > 0 then
						_G.TakeInboxMoney(index)
					elseif itemCount and itemCount > 0 then
						mod = 1.33

						local name = _G.GetInboxItem(index, itemCount)
						if not name then
							_G.AutoLootMailItem(index)
						else
							_G.TakeInboxItem(index, itemCount)
						end
					end

					_G.C_Timer.After(delay * mod, function() LazyLootMail(index, delay) end)
				end
			end
		else
			LazyLootMail(index - 1, delay)
		end
	else
		_G.CheckInbox()
		_G.InboxFrame_Update()

		isReceiving = false

		if overflow then
			_G.C_Timer.After(delay * 1.33, ReceiveMail)
		else
			_G.InboxFrame.ReceiveButton:SetChecked(false)
			_G.MiniMapMailFrame:Hide()
		end
	end
end

function ReceiveMail()
	if not isReceiving then
		local _, _, lag = _G.GetNetStats()
		local numMessages, totalMessages = _G.GetInboxNumItems()
		overflow = totalMessages > numMessages
		isReceiving = true

		LazyLootMail(numMessages, lag > 0 and lag / 750 or 0.1)
	end
end

--------------------
-- RECEIVE BUTTON --
--------------------

local function ReceiveButton_OnClick()
	ReceiveMail()
end
local function ReceiveButton_OnEvent(self, event)
	if event == "MAIL_INBOX_UPDATE" then
		self:Enable()
		self:UnregisterEvent("MAIL_INBOX_UPDATE")

		self.Icon:SetDesaturated(false)
	elseif event == "MAIL_CLOSED" then
		self:SetChecked(false)
		self:Disable()
		self:RegisterEvent("MAIL_INBOX_UPDATE")

		self.Icon:SetDesaturated(true)
	end
end

local function ReceiveButton_OnEnter(self)
	_G.GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")

	local numMessages = _G.GetInboxNumItems()
	local gold, items, cod = 0, 0, 0
	table.wipe(mailItems)

	for i = 1, numMessages do
		local _, _, _, _, money, CODAmount, _, itemCount = _G.GetInboxHeaderInfo(i)

		if money and money > 0 then
			gold = gold + money
		end

		if CODAmount and CODAmount > 0 then
			cod = cod + CODAmount
		end

		if itemCount then
			for j = 1, itemCount do
				local itemLink = _G.GetInboxItemLink(i, j)

				if itemLink then
					local _, _, _, count = _G.GetInboxItem(i, j)
					local name, _, quality, _, _, _, _, _, _, icon = _G.GetItemInfo(itemLink)

					if not name then
						name = _G.UNKNOWN
						icon = icon or "Interface\\Icons\\INV_Misc_QuestionMark"
						count = count or 1
						quality = quality or 0
					end

					local index = GetIndexForName(mailItems, name)

					if index then
						mailItems[index].count = mailItems[index].count + count
					else
						table.insert(mailItems, {name = name, count = count, icon = "|T"..icon..":0|t", color = _G.ITEM_QUALITY_COLORS[quality].hex})
					end
				end

				items = items + 1
			end
		end
	end

	if gold > 0 or cod > 0 or items > 0 then
		_G.GameTooltip:AddLine(_G.MAIL_LABEL, 1, 1, 1)
	end

	if gold > 0 then
		_G.GameTooltip:AddLine(" ")
		_G.GameTooltip:AddLine(_G.ENCLOSED_MONEY..":")
		_G.GameTooltip:AddLine(_G.GetMoneyString(gold), 1, 1, 1)
	end

	if cod > 0 then
		_G.GameTooltip:AddLine(" ")
		_G.GameTooltip:AddLine(_G.COD_AMOUNT)
		_G.GameTooltip:AddLine(_G.GetMoneyString(cod), 1, 1, 1)
	end

	if items > 0 then
		table.sort(mailItems, SortByName)

		_G.GameTooltip:AddLine(" ")
		_G.GameTooltip:AddLine(_G.ITEMS..":")

		for _, v in pairs(mailItems) do
			_G.GameTooltip:AddDoubleLine(v.color..v.name.."|r", v.count..v.icon, 1, 1, 1, 1, 1, 1)
		end
	end

	_G.GameTooltip:Show()
end

local function ReceiveButton_OnLeave()
	_G.GameTooltip:Hide()
end

-----------------
-- INITIALISER --
-----------------

function Mail:IsInit()
	return isInit
end

function Mail:Init(isForced)
	if not isInit and (C.mail.enabled or isForced) then
		local button = E:CreateCheckButton(_G.InboxFrame, "$parentReceiveMailButton")
		button:SetPoint("BOTTOMRIGHT", _G.MailFrameInset, "TOPRIGHT", -2, 4)
		button:RegisterEvent("MAIL_INBOX_UPDATE")
		button:RegisterEvent("MAIL_CLOSED")
		button:SetScript("OnClick", ReceiveButton_OnClick)
		button:SetScript("OnEvent", ReceiveButton_OnEvent)
		button:SetScript("OnEnter", ReceiveButton_OnEnter)
		button:SetScript("OnLeave", ReceiveButton_OnLeave)
		button:Disable()
		_G.InboxFrame.ReceiveButton = button

		button.Icon:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-ItemIntoBag")
		button.Icon:SetDesaturated(true)

		-- Finalise
		isInit = true
	end
end
