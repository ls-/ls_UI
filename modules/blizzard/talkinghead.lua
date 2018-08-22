local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Blizzard")

-- Lua
local _G = getfenv(0)
local next = _G.next
local t_remove = _G.table.remove

--[[ luacheck: globals
	AlertFrame CreateFrame IsAddOnLoaded LoadAddOn TalkingHeadFrame UIParent

	UIPARENT_MANAGED_FRAME_POSITIONS
]]

-- Mine
local isInit = false

function MODULE.HasTalkingHead()
	return isInit
end

function MODULE.SetUpTalkingHead()
	if not isInit and C.db.char.blizzard.talking_head.enabled then
		local isLoaded = true

		if not IsAddOnLoaded("Blizzard_TalkingHeadUI") then
			isLoaded = LoadAddOn("Blizzard_TalkingHeadUI")
		end

		if isLoaded then
			TalkingHeadFrame.ignoreFramePositionManager = true
			UIPARENT_MANAGED_FRAME_POSITIONS["TalkingHeadFrame"] = nil

			for i, subSystem in next, AlertFrame.alertFrameSubSystems do
				if subSystem.anchorFrame and subSystem.anchorFrame == TalkingHeadFrame then
					t_remove(AlertFrame.alertFrameSubSystems, i)
				end
			end

			TalkingHeadFrame:ClearAllPoints()
			TalkingHeadFrame:SetPoint("TOP", "UIParent", "TOP", 0, -188)
			E.Movers:Create(TalkingHeadFrame)

			isInit = true
		end
	end
end
