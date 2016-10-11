local _, ns = ...
local E = ns.E
local B = E:GetModule("Blizzard")

-- Lua
local _G = _G

-- Mine
function B:HandleTH()
	local function Handler()
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

	if _G.IsAddOnLoaded("Blizzard_TalkingHeadUI") then
		Handler()
	else
		E:AddOnLoadTask("Blizzard_TalkingHeadUI", Handler)
	end
end
