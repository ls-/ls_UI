local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Blizzard")

-- Lua
local _G = getfenv(0)

-- Blizz
local IsAltKeyDown = _G.IsAltKeyDown
local IsControlKeyDown = _G.IsControlKeyDown
local IsShiftKeyDown = _G.IsShiftKeyDown

--[[ luacheck: globals
	CreateFrame ObjectiveTrackerFrame UIParent
]]

-- Mine
local isInit = false

function MODULE.HasObjectiveTracker()
	return isInit
end

function MODULE.SetUpObjectiveTracker()
	if not isInit and C.db.char.blizzard.objective_tracker.enabled then
		local holder = CreateFrame("Frame", "LSOTFrameHolder", UIParent)
		holder:SetFrameStrata("LOW")
		holder:SetFrameLevel(ObjectiveTrackerFrame:GetFrameLevel() + 1)
		holder:SetSize(229, 25)
		holder:SetPoint("TOPRIGHT", -192, -192)

		local mover = E.Movers:Create(holder, true)
		mover:SetClampRectInsets(-4, 18, 4, -4)
		mover.IsDragKeyDown = function()
			return C.db.profile.blizzard.objective_tracker.drag_key == "NONE"
				or C.db.profile.blizzard.objective_tracker.drag_key == (IsShiftKeyDown() and "SHIFT" or IsControlKeyDown() and "CTRL" or IsAltKeyDown() and "ALT")
		end

		ObjectiveTrackerFrame:SetMovable(true)
		ObjectiveTrackerFrame:SetUserPlaced(true)
		ObjectiveTrackerFrame:SetParent(holder)
		ObjectiveTrackerFrame:ClearAllPoints()
		ObjectiveTrackerFrame:SetPoint("TOPRIGHT", holder, "TOPRIGHT", 16, 0)
		ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:HookScript("OnClick", function()
			E.Movers:Get(holder):UpdateSize(ObjectiveTrackerFrame.collapsed and 84 or nil)
		end)
		ObjectiveTrackerFrame.HeaderMenu:HookScript("OnShow", function()
			E.Movers:Get(holder):Show()
		end)
		ObjectiveTrackerFrame.HeaderMenu:HookScript("OnHide", function()
			E.Movers:Get(holder):Hide()
		end)

		isInit = true
	end
end

function MODULE.UpdateObjectiveTracker()
	if isInit then
		ObjectiveTrackerFrame:SetHeight(C.db.profile.blizzard.objective_tracker.height)
	end
end
