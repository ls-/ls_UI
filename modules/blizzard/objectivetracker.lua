local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local B = E:GetModule("Blizzard")

-- Lua
local _G = _G

-- Blizz
local ObjectiveTrackerFrame = ObjectiveTrackerFrame

-- Mine
local isInitialized = false
local isEnabled = false
local header

local function MinimizeButton_OnClickHook(self)
	if ObjectiveTrackerFrame.collapsed then
		E:UpdateMoverSize(header, 84)
	else
		E:UpdateMoverSize(header)
	end
end

local function HeaderMenu_OnShow(self)
	local mover = E:GetMover(header)

	if mover then
		mover:Show()
	end
end

local function HeaderMenu_OnHide(self)
	local mover = E:GetMover(header)

	if mover then
		mover:Hide()
	end
end

function B:OT_IsLoaded()
	return isInitialized, isEnabled
end

function B:OT_SetHeight(height)
	if height then
		-- FIX-ME
		C.blizzard.ot.height = height

		if isEnabled then
			ObjectiveTrackerFrame:SetHeight(height)

			_G.ObjectiveTracker_Update(0x0)
		end
	end
end

function B:OT_Initialize(forceEnable)
	-- FIX-ME: I need to rewrite how config refreshes values
	if forceEnable then
		C.blizzard.ot.enabled = true
	end

	if C.blizzard.ot.enabled then
		header = _G.CreateFrame("Frame", "LSOTFrameHolder", _G.UIParent)
		header:SetFrameStrata("LOW")
		header:SetFrameLevel(ObjectiveTrackerFrame:GetFrameLevel() + 1)
		header:SetSize(229, 25)
		header:SetPoint("TOPRIGHT", -192, -192)

		E:CreateMover(header, true, {-4, 18, 4, -4})

		-- ugly, but works fine
		ObjectiveTrackerFrame:ClearAllPoints()
		ObjectiveTrackerFrame.ClearAllPoints = function() return end
		ObjectiveTrackerFrame:SetPoint("TOPRIGHT", header, "TOPRIGHT", 16, 0)
		ObjectiveTrackerFrame.SetPoint = function() return end
		ObjectiveTrackerFrame:SetHeight(C.blizzard.ot.height)
		ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:HookScript("OnClick", MinimizeButton_OnClickHook)
		ObjectiveTrackerFrame.HeaderMenu:HookScript("OnShow", HeaderMenu_OnShow)
		ObjectiveTrackerFrame.HeaderMenu:HookScript("OnHide", HeaderMenu_OnHide)

		_G.hooksecurefunc("QuestObjectiveItem_OnShow", E.SkinOTButton)

		isInitialized = true
		isEnabled = true
	end
end
