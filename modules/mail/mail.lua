local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local Mail = E:AddModule("Mail")

local LazyLootMail, ReceiveMail

local function GetFreeSlots()
	local free = 0

	for i = 0, NUM_BAG_SLOTS do
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

	local numItems, totalItems = GetInboxNumItems()
	local gold, items, cod = 0, 0, 0

	for i = 1, numItems do
		local _, _, _, _, money, CODAmount, _, hasItem = GetInboxHeaderInfo(i)

		if CODAmount and CODAmount> 0 then
			cod = cod + CODAmount
		elseif money and money > 0 then
			gold = gold + money
		end

		if hasItem then
			items = items + hasItem
		end
	end

	if gold > 0 then
		GameTooltip:AddLine(ENCLOSED_MONEY..":")
		GameTooltip:AddLine(GetMoneyString(gold), 1, 1, 1)
	end

	if cod > 0 then
		GameTooltip:AddLine(COD_AMOUNT)
		GameTooltip:AddLine(GetMoneyString(cod), 1, 1, 1)
	end

	if items > 0 then
		GameTooltip:AddLine(ITEMS..":")
		GameTooltip:AddLine(items.."|TInterface\\MINIMAP\\TRACKING\\Banker:0|t", 1, 1, 1)
	end

	GameTooltip:Show()
end

local function ReceiveButton_OnLeave(self)
	GameTooltip:Hide()
end

function LazyLootMail(index, delay)
	local _, _, _, _, money, CODAmount, _, hasItem, _, _, _, _, isGM = GetInboxHeaderInfo(index)

	if index > 0 then
		if not (CODAmount and CODAmount > 0 or isGM) then
			if money == 0 and not hasItem then
				DeleteInboxItem(index)

				C_Timer.After(delay, function() LazyLootMail(index - 1, delay) end)
			else
				local freeSlots = GetFreeSlots()

				if money > 0 or (hasItem and hasItem <= freeSlots) then
					local mod = 1

					if money > 0 then
						TakeInboxMoney(index)
					elseif hasItem and hasItem > 0 then
						local name, _, count = GetInboxItem(index, hasItem)
						mod = 1.5

						if not name then
							AutoLootMailItem(index)
						else
							TakeInboxItem(index, hasItem)
						end
					end

					C_Timer.After(delay * mod, function() LazyLootMail(index, delay) end)
				else
					print("not enough inventory space")
				end
			end
		else
			LazyLootMail(index - 1, delay)
		end
	elseif index == 0 then
		InboxFrame_Update()

		if Mail.overflow then
			ReceiveMail()
		else
			MiniMapMailFrame:Hide()
		end
	end
end

function ReceiveMail()
	local numItems, totalItems = GetInboxNumItems()
	Mail.overflow = totalItems > numItems

	local _, _, lag = GetNetStats()
	lag = lag > 0 and lag / 500 or 0.1

	LazyLootMail(numItems, lag)
end

function Mail:Initialize()
	if C.mail.enabled then
		local button = CreateFrame("Button", "$parentReceiveMailButton", InboxFrame)
		button:SetSize(28, 28)
		button:SetPoint("BOTTOMRIGHT", MailFrameInset, "TOPRIGHT", -2, 4)
		button:RegisterEvent("MAIL_INBOX_UPDATE")
		button:RegisterEvent("MAIL_CLOSED")
		button:SetScript("OnEvent", ReceiveButton_OnEvent)
		button:SetScript("OnEnter", ReceiveButton_OnEnter)
		button:SetScript("OnLeave", ReceiveButton_OnLeave)
		button:SetScript("OnClick", ReceiveMail)
		button:Disable()

		button:SetHighlightTexture(1)
		ns.lsSetHighlightTexture(button:GetHighlightTexture())

		button:SetPushedTexture(1)
		ns.lsSetPushedTexture(button:GetPushedTexture())

		E:CreateBorder(button, 8)

		local icon = button:CreateTexture()
		icon:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-ItemIntoBag")
		icon:SetDesaturated(true)
		E:TweakIcon(icon)
		button.Icon = icon
	end
end
