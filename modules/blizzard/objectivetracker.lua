local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local B = E:GetModule("Blizzard")

-- Lua
local _G = _G

-- Mine
local isInitialized = false
local isEnabled = false

function B:OT_IsLoaded()
	return isInitialized, isEnabled
end

function B:OT_SetHeight(height)
	if height then
		-- FIX-ME
		C.blizzard.ot.height = height

		if isEnabled then
			_G.ObjectiveTrackerFrame:SetHeight(height)
		end
	end
end

function B:OT_Initialize(forceEnable)
	-- FIX-ME: I need to rewrite how config refreshes values
	if forceEnable then
		C.blizzard.ot.enabled = true
	end

	if C.blizzard.ot.enabled then
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
		_G.ObjectiveTrackerFrame:SetHeight(C.blizzard.ot.height)
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

		isInitialized = true
		isEnabled = true
	end
end
