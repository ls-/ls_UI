local _, ns = ...
local E, M = ns.E, ns.M

local COLORS = M.colors

local OT_UNLOCKED

local B = E.Blizzard

local function OTHeader_OnClick(self)
	ToggleDropDownMenu(1, nil, self.menu, "cursor", 2, -2)
end

local function ToggleOTMover(self)
	OT_UNLOCKED = E:ToggleMover(LSOTFrameHolder)
end

local function OTDropDown_Initialize(self)
	local info = UIDropDownMenu_CreateInfo()
	info = UIDropDownMenu_CreateInfo()
	info.notCheckable = 1
	info.text = OT_UNLOCKED and LOCK_FRAME or UNLOCK_FRAME
	info.func = ToggleOTMover
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL)
end

function B:HandleObjectiveTracker()
	local holder = CreateFrame("Frame", "LSOTFrameHolder", UIParent)
	holder:SetFrameStrata("LOW")
	holder:SetFrameLevel(1)
	holder:SetSize(251, 24)
	holder:SetPoint("TOPRIGHT", -170, -210)

	E:CreateMover(holder)

	-- ugly, but works fine
	ObjectiveTrackerFrame:ClearAllPoints()
	ObjectiveTrackerFrame.ClearAllPoints = function() return end
	ObjectiveTrackerFrame:SetPoint("TOP", holder, "BOTTOM", 8, 2)
	ObjectiveTrackerFrame.SetPoint = function() return end
	ObjectiveTrackerFrame:SetHeight(E.height * 0.6)

	local header = CreateFrame("Button", nil, ObjectiveTrackerFrame)
	header:SetFrameLevel(ObjectiveTrackerFrame:GetFrameLevel() + 2)
	header:SetSize(251, 24)
	header:SetPoint("TOP", -8, 0)
	header:RegisterForClicks("RightButtonUp")
	header:SetScript("OnClick", OTHeader_OnClick)

	local dropdown = CreateFrame("Frame", "LSOTDropDown", holder, "UIDropDownMenuTemplate")
	UIDropDownMenu_Initialize(dropdown, OTDropDown_Initialize, "MENU")

	header.menu = dropdown

	hooksecurefunc("QuestObjectiveItem_OnShow", E.SkinOTButton)
end
