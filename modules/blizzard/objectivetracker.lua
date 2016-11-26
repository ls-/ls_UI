local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local BLIZZARD = P:GetModule("Blizzard")

-- Lua
local _G = _G

-- Mine
local isInit = false

-----------
-- UTILS --
-----------

function BLIZZARD:ObjectiveTracker_SetHeight(height)
	if isInit then
		_G.ObjectiveTrackerFrame:SetHeight(height)
	end
end

-----------------
-- INITIALISER --
-----------------

function BLIZZARD:ObjectiveTracker_IsInit()
	return isInit
end

function BLIZZARD:ObjectiveTracker_Init(forceEnable)
	if not isInit and (C.blizzard.objective_tracker.enabled or forceEnable) then
		local header = _G.CreateFrame("Frame", "LSOTFrameHolder", _G.UIParent)
		header:SetFrameStrata("LOW")
		header:SetFrameLevel(_G.ObjectiveTrackerFrame:GetFrameLevel() + 1)
		header:SetSize(229, 25)
		header:SetPoint("TOPRIGHT", -192, -192)
		E:CreateMover(header, true, {-4, 18, 4, -4})

		_G.ObjectiveTrackerFrame:SetMovable(true)
		_G.ObjectiveTrackerFrame:SetUserPlaced(true)
		_G.ObjectiveTrackerFrame:SetParent(header)
		_G.ObjectiveTrackerFrame:ClearAllPoints()
		_G.ObjectiveTrackerFrame:SetPoint("TOPRIGHT", header, "TOPRIGHT", 16, 0)
		_G.ObjectiveTrackerFrame:SetHeight(C.blizzard.objective_tracker.height)
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

		-- Finalise
		isInit = true
	end
end
