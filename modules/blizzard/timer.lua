local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local Blizzard = P:GetModule("Blizzard")

-- Lua
local _G = getfenv(0)
local pairs = _G.pairs

-- Mine
local isInit = false

-----------------
-- INITIALISER --
-----------------

function Blizzard:Timer_IsInit()
	return isInit
end

function Blizzard:Timer_Init()
	if not isInit and C.db.char.blizzard.timer.enabled then
		E:HandleStatusBar(_G.MirrorTimer1)
		E:SetStatusBarSkin(_G.MirrorTimer1, "HORIZONTAL-L")

		_G.MirrorTimer2:ClearAllPoints()
		_G.MirrorTimer2:SetPoint("TOP", "MirrorTimer1", "BOTTOM", 0, -6)
		E:HandleStatusBar(_G.MirrorTimer2)
		E:SetStatusBarSkin(_G.MirrorTimer2, "HORIZONTAL-L")

		_G.MirrorTimer3:ClearAllPoints()
		_G.MirrorTimer3:SetPoint("TOP", "MirrorTimer2", "BOTTOM", 0, -6)
		E:HandleStatusBar(_G.MirrorTimer3)
		E:SetStatusBarSkin(_G.MirrorTimer3, "HORIZONTAL-L")

		-- 3 should be enough
		local indices = {}

		for i = 1, 3 do
			if not _G["TimerTrackerTimer"..i] then
				indices[i] = true
			end
		end

		for i in pairs(indices) do
			local timer = _G.CreateFrame("FRAME", "TimerTrackerTimer"..i, _G.UIParent, "StartTimerBar")
			_G.TimerTracker.timerList[i] = timer

			E:HandleStatusBar(timer.bar)
			E:SetStatusBarSkin(timer.bar, "HORIZONTAL-L")
		end

		-- Finalise
		isInit = true

		return true
	end
end
