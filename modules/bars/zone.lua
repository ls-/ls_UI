local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Bars")

-- Lua
local _G = getfenv(0)

-- Mine
local isInit = false

function MODULE.CreateZoneButton()
	if not isInit then

		local bar = CreateFrame("Frame", "LSZoneAbilityBar", UIParent, "SecureHandlerStateTemplate")
		bar._id = "zone"
		bar._buttons = {}

		MODULE:AddBar("zone", bar)

		bar.Update = function(self)
			self:UpdateConfig()
			self:UpdateFading()
			self:UpdateVisibility()

			ZoneAbilityFrame:SetAllPoints()

			self:SetSize(self._config.size + 4, self._config.size + 4)
			E:UpdateMoverSize(self)
		end

		ZoneAbilityFrame.ignoreFramePositionManager = true
		UIPARENT_MANAGED_FRAME_POSITIONS["ZoneAbilityFrame"] = nil

		ZoneAbilityFrame:EnableMouse(false)
		ZoneAbilityFrame:SetParent(bar)
		ZoneAbilityFrame:SetAllPoints()

		ZoneAbilityFrame.SpellButton:SetPoint("TOPLEFT", 2, -2)
		ZoneAbilityFrame.SpellButton:SetPoint("BOTTOMRIGHT", -2, 2)
		ZoneAbilityFrame.SpellButton._parent = bar
		E:SkinZoneAbilityButton(ZoneAbilityFrame.SpellButton)
		bar._buttons[1] = ZoneAbilityFrame.SpellButton

		local point = C.db.profile.bars.zone.point
		bar:SetPoint(point.p, point.anchor, point.rP, point.x, point.y)
		E:CreateMover(bar)

		bar:Update()

		isInit = true
	end
end
