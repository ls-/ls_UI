local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Blizzard")

-- Lua
local _G = getfenv(0)

-- Blizz
local CreateFrame = _G.CreateFrame
local IsAltKeyDown = _G.IsAltKeyDown
local IsControlKeyDown = _G.IsControlKeyDown
local IsShiftKeyDown = _G.IsShiftKeyDown

-- Mine
local isInit = false
local header

function MODULE.HasObjectiveTracker()
	return isInit
end

function MODULE.SetUpObjectiveTracker()
	if not isInit and C.db.char.blizzard.objective_tracker.enabled then
		header = CreateFrame("Frame", "LSOTFrameHolder", UIParent)
		header:SetFrameStrata("LOW")
		header:SetFrameLevel(ObjectiveTrackerFrame:GetFrameLevel() + 1)
		header:SetSize(229, 25)
		header:SetPoint("TOPRIGHT", -192, -192)
		E:CreateMover(header, true, function()
			return C.db.profile.blizzard.objective_tracker.drag_key == "NONE"
				or C.db.profile.blizzard.objective_tracker.drag_key == (IsShiftKeyDown() and "SHIFT" or IsControlKeyDown() and "CTRL" or IsAltKeyDown() and "ALT")
		end, -4, 18, 4, -4)

		ObjectiveTrackerFrame:SetMovable(true)
		ObjectiveTrackerFrame:SetUserPlaced(true)
		ObjectiveTrackerFrame:SetParent(header)
		ObjectiveTrackerFrame:ClearAllPoints()
		ObjectiveTrackerFrame:SetPoint("TOPRIGHT", header, "TOPRIGHT", 16, 0)
		ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:HookScript("OnClick", function()
			if ObjectiveTrackerFrame.collapsed then
				E:UpdateMoverSize(header, 84)
			else
				E:UpdateMoverSize(header)
			end
		end)
		ObjectiveTrackerFrame.HeaderMenu:HookScript("OnShow", function()
			local mover = E:GetMover(header)

			if mover then
				mover:Show()
			end
		end)
		ObjectiveTrackerFrame.HeaderMenu:HookScript("OnHide", function()
			local mover = E:GetMover(header)

			if mover then
				mover:Hide()
			end
		end)

		isInit = true
	end
end

function MODULE.UpdateObjectiveTracker()
	if isInit then
		ObjectiveTrackerFrame:SetHeight(C.db.profile.blizzard.objective_tracker.height)
	end
end
