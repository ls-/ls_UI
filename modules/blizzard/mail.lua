local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local BLIZZARD = P:GetModule("Blizzard")

-- Lua
local _G = getfenv(0)

-- Blizz
local C_Mail = _G.C_Mail

--[[
	luacheck: globals
	DeleteInboxItem GameTooltip GetInboxHeaderInfo GetInboxNumItems InboxFrame MailFrameInset
]]

-- Mine
local isInit = false
local DELAY = 0.15

local function button_ProcessNextMessage(self)
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

local function button_OnClick(self)
	if not self.delay then
		self.index = GetInboxNumItems()

		self:ProcessNextMessage()
	end
end

local function button_OnEvent(self, event)
	if event == "MAIL_CLOSED" then
		self.index = 0
		self.delay = nil
	end
end

local function button_OnUpdate(self, elapsed)
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

local function button_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
	GameTooltip:AddLine(L["CLEAN_UP"])
	GameTooltip:AddLine(L["CLEAN_UP_MAIL_DESC"], 1, 1, 1)
	GameTooltip:Show()
end

local function button_OnLeave()
	GameTooltip:Hide()
end

function BLIZZARD:HasMail()
	return isInit
end

function BLIZZARD:SetUpMail()
	if not isInit and C.db.char.blizzard.mail.enabled then
		local button = E:CreateButton(InboxFrame, "$parentCleanUpButton")
		button:SetPoint("BOTTOMRIGHT", MailFrameInset, "TOPRIGHT", -2, 4)
		button:RegisterEvent("MAIL_INBOX_UPDATE")
		button:RegisterEvent("MAIL_CLOSED")
		button:SetScript("OnClick", button_OnClick)
		button:SetScript("OnEnter", button_OnEnter)
		button:SetScript("OnEvent", button_OnEvent)
		button:SetScript("OnLeave", button_OnLeave)
		button:SetScript("OnUpdate", button_OnUpdate)
		InboxFrame.ReceiveButton = button

		button.Icon:SetTexture("Interface\\ICONS\\INV_Pet_Broom")

		button.ProcessNextMessage = button_ProcessNextMessage

		isInit = true
	end
end
