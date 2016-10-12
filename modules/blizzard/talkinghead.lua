local _, ns = ...
local E = ns.E
local B = E:GetModule("Blizzard")

-- Lua
local _G = _G
local table = _G.table
local pairs = _G.pairs

-- Mine
function B:HandleTH()
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
	end
end
