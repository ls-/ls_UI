local _, ns = ...
local E, M = ns.E, ns.M

local COLORS = ns.M.colors

ns.infobars = {}

local INFOBAR_INFO = {
	Clock = {
		infobar_type = "Button",
		length = "Short",
	},
}

local function lsClockInfoBar_Initialize()
	lsClockInfoBar:RegisterForClicks("LeftButtonUp")
end

local function lsClockInfoBar_OnClick(...)
	TimeManager_Toggle()
end

local function lsClockInfoBar_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -4)
		GameTooltip:AddLine(TIMEMANAGER_TOOLTIP_TITLE, 1, 1, 1)
	GameTooltip:AddDoubleLine(TIMEMANAGER_TOOLTIP_REALMTIME, GameTime_GetGameTime(true),
		COLORS.yellow[1], COLORS.yellow[2], COLORS.yellow[3], 1, 1, 1)
	GameTooltip:AddDoubleLine(TIMEMANAGER_TOOLTIP_LOCALTIME, GameTime_GetLocalTime(true),
		COLORS.yellow[1], COLORS.yellow[2], COLORS.yellow[3], 1, 1, 1)
	GameTooltip:Show()
end

local function lsClockInfoBar_OnUpdate(self, elapsed)
	if self.updateInterval > 0 then
		self.updateInterval = self.updateInterval - elapsed
	else
		self.updateInterval = 1
		self.text:SetText(GameTime_GetTime(true))
		if GameTooltip:IsOwned(self) then
			lsClockInfoBar_OnEnter(self)
		end
		if TimeManagerClockButton.alarmFiring then
			self.filling:SetVertexColor(unpack(COLORS.red))
		else
			self.filling:SetVertexColor(unpack(COLORS.black))
		end
	end
end

function ns.lsInfobars_Initialize()
	for ib, ibdata in next, INFOBAR_INFO do
		local ibar = CreateFrame(ibdata.infobar_type, "ls"..ib.."InfoBar", UIParent, "lsInfoBarButtonTemplate-"..ibdata.length)
		ibar:SetFrameStrata("LOW")
		ibar:SetFrameLevel(1)

		ns.infobars[strlower(ib)] = ibar
	end

	for ib, ibar in next, ns.infobars do
		ibar:SetPoint(unpack(ns.C.infobars[ib].point))
	end

	lsClockInfoBar_Initialize()
	lsClockInfoBar:SetScript("OnClick", lsClockInfoBar_OnClick)
	lsClockInfoBar:SetScript("OnEnter", lsClockInfoBar_OnEnter)
	lsClockInfoBar:SetScript("OnUpdate", lsClockInfoBar_OnUpdate)
end
