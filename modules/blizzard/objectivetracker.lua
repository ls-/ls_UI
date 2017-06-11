local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local BLIZZARD = P:GetModule("Blizzard")

-- Lua
local _G = getfenv(0)

-- Mine
local isInit = false

function BLIZZARD:HasObjectiveTracker()
	return isInit
end

function BLIZZARD:SetUpObjectiveTracker()
	if not isInit and C.db.char.blizzard.objective_tracker.enabled then
		local header = _G.CreateFrame("Frame", "LSOTFrameHolder", _G.UIParent)
		header:SetFrameStrata("LOW")
		header:SetFrameLevel(_G.ObjectiveTrackerFrame:GetFrameLevel() + 1)
		header:SetSize(229, 25)
		header:SetPoint("TOPRIGHT", -192, -192)
		E:CreateMover(header, true, -4, 18, 4, -4)

		_G.ObjectiveTrackerFrame:SetMovable(true)
		_G.ObjectiveTrackerFrame:SetUserPlaced(true)
		_G.ObjectiveTrackerFrame:SetParent(header)
		_G.ObjectiveTrackerFrame:ClearAllPoints()
		_G.ObjectiveTrackerFrame:SetPoint("TOPRIGHT", header, "TOPRIGHT", 16, 0)
		_G.ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:HookScript("OnClick", function()
			if _G.ObjectiveTrackerFrame.collapsed then
				E:UpdateMoverSize(header, 84)
			else
				E:UpdateMoverSize(header)
			end
		end)
		_G.ObjectiveTrackerFrame.HeaderMenu:HookScript("OnShow", function()
			local mover = E:GetMover(header)

			if mover then
				mover:Show()
			end
		end)
		_G.ObjectiveTrackerFrame.HeaderMenu:HookScript("OnHide", function()
			local mover = E:GetMover(header)

			if mover then
				mover:Hide()
			end
		end)

		isInit = true

		self.SetUpObjectiveTracker = E.NOOP
	end
end

function BLIZZARD:UpdateObjectiveTracker()
	if isInit then
		local config = C.db.profile.blizzard.objective_tracker

		_G.ObjectiveTrackerFrame:SetHeight(config.height)
	end
end
