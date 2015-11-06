local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local B = E:GetModule("Blizzard")

function B:HandleTimers()
	E:HandleStatusBar(MirrorTimer1, true)

	MirrorTimer2:ClearAllPoints()
	MirrorTimer2:SetPoint("TOP", "MirrorTimer1", "BOTTOM", 0, -6)
	E:HandleStatusBar(MirrorTimer2, true)

	MirrorTimer3:ClearAllPoints()
	MirrorTimer3:SetPoint("TOP", "MirrorTimer2", "BOTTOM", 0, -6)
	E:HandleStatusBar(MirrorTimer3, true)

	-- 3 should be enough
	for i = 1, 3 do
		local timer = CreateFrame("FRAME", "TimerTrackerTimer"..i, UIParent, "StartTimerBar")
		TimerTracker.timerList[i] = timer

		E:HandleStatusBar(timer.bar, true)
	end
end
