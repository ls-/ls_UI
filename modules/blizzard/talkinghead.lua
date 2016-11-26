local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local BLIZZARD = P:GetModule("Blizzard")

-- Lua
local _G = _G
local table = _G.table
local pairs = _G.pairs

-- Mine
local isInit = false

-----------------
-- INITIALISER --
-----------------

function BLIZZARD:TalkingHead_IsInit()
	return isInit
end

function BLIZZARD:TalkingHead_Init(isForced)
	if not isInit and (C.blizzard.talking_head.enabled or isForced) then
		local isLoaded = true

		if not _G.IsAddOnLoaded("Blizzard_TalkingHeadUI") then
			isLoaded = _G.LoadAddOn("Blizzard_TalkingHeadUI")
		end

		if isLoaded then
			_G.TalkingHeadFrame.ignoreFramePositionManager = true
			_G.UIPARENT_MANAGED_FRAME_POSITIONS["TalkingHeadFrame"] = nil

			for i, subSystem in pairs(_G.AlertFrame.alertFrameSubSystems) do
				if subSystem.anchorFrame and subSystem.anchorFrame == _G.TalkingHeadFrame then
					table.remove(_G.AlertFrame.alertFrameSubSystems, i)
				end
			end

			_G.TalkingHeadFrame:ClearAllPoints()
			_G.TalkingHeadFrame:SetPoint("TOP", "UIParent", "TOP", 0, -188)
			E:CreateMover(_G.TalkingHeadFrame)

			-- Finalise
			isInit = true
		end
	end
end
