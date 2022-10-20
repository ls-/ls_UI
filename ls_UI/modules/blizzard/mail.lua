local _, ns = ...
local E, C, PrC, M, L, P = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P
local BLIZZARD = P:GetModule("Blizzard")

-- Lua
local _G = getfenv(0)

-- Mine
local isInit = false
local DELAY = 0.15

local button_proto = {}

function button_proto:ProcessNextMessage()
	if self.index > 0 then
		local _, _, _, _, money, CODAmount, _, itemCount, _, _, _, _, isGM = GetInboxHeaderInfo(self.index)
		if not (CODAmount and CODAmount > 0 or isGM) and money == 0 and not itemCount then
			DeleteInboxItem(self.index)
		end

		self.delay = DELAY
	else
		self.delay = nil
	end
end

function button_proto:OnClick()
	if not self.delay then
		self.index = GetInboxNumItems()

		self:ProcessNextMessage()
	end
end

function button_proto:OnEvent(event)
	if event == "MAIL_CLOSED" then
		self.index = 0
		self.delay = nil
	end
end

function button_proto:OnUpdate(elapsed)
	if self.delay then
		self.delay = self.delay - elapsed
		if self.delay <= 0 then
			if not C_Mail.IsCommandPending() then
				self.index = self.index - 1
				self.delay = nil

				self:ProcessNextMessage()
			else
				self.delay = DELAY
			end
		end
	end
end

function button_proto:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
	GameTooltip:AddLine(L["CLEAN_UP"])
	GameTooltip:AddLine(L["CLEAN_UP_MAIL_DESC"], 1, 1, 1)
	GameTooltip:Show()
end

function button_proto:OnLeave()
	GameTooltip:Hide()
end

function BLIZZARD:HasMail()
	return isInit
end

function BLIZZARD:SetUpMail()
	if not isInit and PrC.db.profile.blizzard.mail.enabled then
		local button = Mixin(E:CreateButton(InboxFrame, "$parentCleanUpButton"), button_proto)
		button:SetPoint("BOTTOMRIGHT", MailFrameInset, "TOPRIGHT", -2, 4)
		button:RegisterEvent("MAIL_INBOX_UPDATE")
		button:RegisterEvent("MAIL_CLOSED")
		button:SetScript("OnClick", button.OnClick)
		button:SetScript("OnEnter", button.OnEnter)
		button:SetScript("OnEvent", button.OnEvent)
		button:SetScript("OnLeave", button.OnLeave)
		button:SetScript("OnUpdate", button.OnUpdate)
		InboxFrame.ReceiveButton = button

		button.Icon:SetTexture("Interface\\ICONS\\INV_Pet_Broom")

		isInit = true
	end
end
