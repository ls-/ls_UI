local _, ns = ...
local E, M = ns.E, ns.M

E.Extra = {}

local Extra = E.Extra

local function LeaveButton_OnEvent(self, event)
	if not InCombatLockdown() then
		if event == "PLAYER_REGEN_ENABLED" then
			self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		end

		if UnitOnTaxi("player") then
			RegisterStateDriver(self, "visibility", "show")
		else
			RegisterStateDriver(self, "visibility", "[canexitExtra] show; hide")
		end

		self.Icon:SetDesaturated(false)
		self:Enable()
	else
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
	end
end

local function LeaveButton_OnClick(self)
	if UnitOnTaxi("player") then
		TaxiRequestEarlyLanding()

		self:SetButtonState("NORMAL")
		self.Icon:SetDesaturated(true)
		self:Disable()
	else
		VehicleExit()
	end
end

function Extra:Initialize()
	local EXTRA_CONFIG = ns.C.bars.extra

	ExtraActionBarFrame:SetParent(UIParent)
	ExtraActionBarFrame:SetSize(EXTRA_CONFIG.button_size, EXTRA_CONFIG.button_size)
	ExtraActionBarFrame:ClearAllPoints()
	ExtraActionBarFrame:SetPoint(unpack(EXTRA_CONFIG.point))
	ExtraActionBarFrame:EnableMouse(false)
	ExtraActionBarFrame.ignoreFramePositionManager = true

	E:CreateMover(ExtraActionBarFrame)

	ExtraActionButton1:SetSize(EXTRA_CONFIG.button_size, EXTRA_CONFIG.button_size)
	ExtraActionButton1:SetFrameStrata("LOW")
	ExtraActionButton1:SetFrameLevel(2)

	E:SkinExtraActionButton(ExtraActionButton1)
end
