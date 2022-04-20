local _, ns = ...
local E, C, PrC, M, L, P = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Blizzard")

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local next = _G.next

-- Mine
local isInit = false

local function mirrorTimer_OnUpdate(self, elapsed)
	if self.paused then return end

	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed >= 0.1 then
		self.Time:SetFormattedText(TIMER_MINUTES_DISPLAY, self.RealBar:GetValue() / 60, self.RealBar:GetValue() % 60)

		self.elapsed = 0
	end
end

local function START_TIMER()
	local config = C.db.profile.blizzard.timer

	for _, timer in next, TimerTracker.timerList do
		if not timer.bar.handled then
			E:HandleStatusBar(timer.bar)
			timer.bar:SetSize(config.width, config.height)

			E:SetStatusBarSkin(timer.bar, "HORIZONTAL-" .. config.height)

			local time = timer.bar.Text
			time:UpdateFont(config.text.size)
			time:SetJustifyV("MIDDLE")
			time:SetJustifyH("RIGHT")
			time:ClearAllPoints()
			time:SetPoint("RIGHT", timer.bar, "RIGHT", -2, 0)
		end
	end
end

function MODULE:HasMirrorTimer()
	return isInit
end

function MODULE:SetUpMirrorTimers()
	if not isInit and PrC.db.profile.blizzard.timer.enabled then
		local point = C.db.profile.blizzard.timer.point[E.UI_LAYOUT]

		for i = 1, MIRRORTIMER_NUMTIMERS do
			local timer = _G["MirrorTimer" .. i]
			E:HandleStatusBar(timer)
			timer:ClearAllPoints()
			if i == 1 then
				timer:SetPoint(point.p, point.anchor, point.rP, point.x, point.y)
			else
				timer:SetPoint("TOP", _G["MirrorTimer" .. (i - 1)], "BOTTOM", 0, -8)
			end
			E.Movers:Create(timer)

			local time = timer:CreateFontString(nil, "ARTWORK")
			E.FontStrings:Capture(time, "statusbar")
			time:SetWordWrap(false)
			time:SetJustifyV("MIDDLE")
			time:SetJustifyH("RIGHT")
			time:SetPoint("RIGHT", timer, "RIGHT", -2, 0)
			timer.Time = time

			local text = timer.Text
			text:SetJustifyH("LEFT")
			text:ClearAllPoints()
			text:SetPoint("LEFT", timer, "LEFT", 2, 0)
			text:SetPoint("RIGHT", time, "LEFT", -2, 0)
		end

		for _, timer in next, TimerTracker.timerList do
			E:HandleStatusBar(timer.bar)

			local time = timer.bar.Text
			time:SetJustifyV("MIDDLE")
			time:SetJustifyH("RIGHT")
			time:ClearAllPoints()
			time:SetPoint("RIGHT", timer.bar, "RIGHT", -2, 0)
		end

		hooksecurefunc("MirrorTimerFrame_OnUpdate", mirrorTimer_OnUpdate)

		E:RegisterEvent("START_TIMER", START_TIMER)

		isInit = true

		self:UpdateMirrorTimers()
	end
end

function MODULE:UpdateMirrorTimers()
	if isInit then
		local config = C.db.profile.blizzard.timer

		for i = 1, MIRRORTIMER_NUMTIMERS do
			local timer = _G["MirrorTimer" .. i]
			timer:SetSize(config.width, config.height)

			local mover = E.Movers:Get(timer, true)
			if mover then
				mover:UpdateSize()
			end

			E:SetStatusBarSkin(timer, "HORIZONTAL-" .. config.height)

			timer.Text:UpdateFont(config.text.size)

			timer.Time:UpdateFont(config.text.size)
		end

		for _, timer in next, TimerTracker.timerList do
			timer.bar:SetSize(config.width, config.height)

			E:SetStatusBarSkin(timer.bar, "HORIZONTAL-" .. config.height)

			timer.bar.Text:UpdateFont(config.text.size)
		end
	end
end
