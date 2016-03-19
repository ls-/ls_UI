local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local B = E:GetModule("Blizzard")

function B:HandleTimers()
	E:HandleStatusBar(MirrorTimer1)
	E:SetStatusBarSkin(MirrorTimer1, "HORIZONTAL-BIG")

	MirrorTimer2:ClearAllPoints()
	MirrorTimer2:SetPoint("TOP", "MirrorTimer1", "BOTTOM", 0, -6)
	E:HandleStatusBar(MirrorTimer2)
	E:SetStatusBarSkin(MirrorTimer2, "HORIZONTAL-BIG")

	MirrorTimer3:ClearAllPoints()
	MirrorTimer3:SetPoint("TOP", "MirrorTimer2", "BOTTOM", 0, -6)
	E:HandleStatusBar(MirrorTimer3)
	E:SetStatusBarSkin(MirrorTimer3, "HORIZONTAL-BIG")

	-- 3 should be enough
	for i = 1, 3 do
		local timer = CreateFrame("FRAME", "TimerTrackerTimer"..i, UIParent, "StartTimerBar")
		TimerTracker.timerList[i] = timer

		E:HandleStatusBar(timer.bar)
		E:SetStatusBarSkin(timer.bar, "HORIZONTAL-BIG")
	end
end
