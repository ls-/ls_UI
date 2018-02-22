local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Blizzard")

-- Lua
local _G = getfenv(0)
local next = _G.next

-- Blizz
local CreateFrame = _G.CreateFrame

-- Mine
local isInit = false

function MODULE.HasMirrorTimer()
	return isInit
end

function MODULE.SetUpMirrorTimer()
	if not isInit and C.db.char.blizzard.timer.enabled then
		E:HandleStatusBar(MirrorTimer1)
		E:SetStatusBarSkin(MirrorTimer1, "HORIZONTAL-12")

		MirrorTimer2:ClearAllPoints()
		MirrorTimer2:SetPoint("TOP", "MirrorTimer1", "BOTTOM", 0, -6)
		E:HandleStatusBar(MirrorTimer2)
		E:SetStatusBarSkin(MirrorTimer2, "HORIZONTAL-12")

		MirrorTimer3:ClearAllPoints()
		MirrorTimer3:SetPoint("TOP", "MirrorTimer2", "BOTTOM", 0, -6)
		E:HandleStatusBar(MirrorTimer3)
		E:SetStatusBarSkin(MirrorTimer3, "HORIZONTAL-12")

		-- 3 should be enough
		local indices = {}

		for i = 1, 3 do
			if not _G["TimerTrackerTimer"..i] then
				indices[i] = true
			end
		end

		for i in next, indices do
			local timer = CreateFrame("Frame", "TimerTrackerTimer"..i, TimerTracker, "StartTimerBar")
			TimerTracker.timerList[i] = timer

			E:HandleStatusBar(timer.bar)
			E:SetStatusBarSkin(timer.bar, "HORIZONTAL-12")
		end

		isInit = true
	end
end
