local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Bars")

-- Lua
local _G = getfenv(0)
local next = _G.next

-- Mine
local isInit = false

local BUTTONS = {
	StanceButton1, StanceButton2, StanceButton3, StanceButton4, StanceButton5,
	StanceButton6, StanceButton7, StanceButton8, StanceButton9, StanceButton10,
}

local TOP_POINT = {
	p = "BOTTOM",
	anchor = "UIParent",
	rP = "BOTTOM",
	x = 0,
	y = 152,
}

local BOTTOM_POINT = {
	p = "BOTTOM",
	anchor = "UIParent",
	rP = "BOTTOM",
	x = 0,
	y = 124,
}

local LAYOUT = {
	WARRIOR = BOTTOM_POINT,
	PALADIN = BOTTOM_POINT,
	HUNTER = TOP_POINT,
	ROGUE = TOP_POINT,
	PRIEST = BOTTOM_POINT,
	DEATHKNIGHT = TOP_POINT,
	SHAMAN = TOP_POINT,
	MAGE = TOP_POINT,
	WARLOCK = TOP_POINT,
	MONK = BOTTOM_POINT,
	DRUID = BOTTOM_POINT,
	DEMONHUNTER = TOP_POINT,
}

local function GetBarPoint()
	return LAYOUT[E.PLAYER_CLASS]
end

local function button_UpdateState(self)
	if self:IsShown() then
		local id = self:GetID()
		local texture, _, isActive, isCastable = GetShapeshiftFormInfo(id)

		self.icon:SetTexture(texture)

		if texture then
			self.cooldown:Show()
		else
			self.cooldown:Hide()
		end

		self:SetChecked(isActive)

		if isCastable then
			self.icon:SetDesaturated(false)
			self.icon:SetVertexColor(M.COLORS.BUTTON_ICON.N:GetRGBA(1))
		else
			self.icon:SetDesaturated(true)
			self.icon:SetVertexColor(M.COLORS.BUTTON_ICON.N:GetRGBA(0.65))
		end

		self.HotKey:SetVertexColor(0.75, 0.75, 0.75)

		self:UpdateHotKey(C.db.profile.bars.bar7.hotkey)
		CooldownFrame_Set(self.cooldown, GetShapeshiftFormCooldown(id))
	end
end

function MODULE.CreateStanceBar()
	if not isInit then
		local bar = CreateFrame("Frame", "LSStanceBar", UIParent, "SecureHandlerStateTemplate")
		bar._id = "bar7"
		bar._buttons = {}

		for i = 1, #BUTTONS do
			local button = CreateFrame("CheckButton", "$parentButton"..i, bar, "StanceButtonTemplate")
			button:SetID(i)
			button:SetScript("OnEvent", nil)
			button:SetScript("OnUpdate", nil)
			button:UnregisterAllEvents()
			button._parent = bar
			button._command = "SHAPESHIFTBUTTON"..i
			button.UpdateState = button_UpdateState

			BUTTONS[i]:SetAllPoints(button)
			BUTTONS[i]:SetAttribute("statehidden", true)
			BUTTONS[i]:SetParent(E.HIDDEN_PARENT)
			BUTTONS[i]:SetScript("OnEvent", nil)
			BUTTONS[i]:SetScript("OnUpdate", nil)
			BUTTONS[i]:UnregisterAllEvents()

			E:SkinStanceButton(button)

			bar._buttons[i] = button
		end

		bar.UpdateButtons = function(self)
			local numStances = GetNumShapeshiftForms()

			for i, button in next, self._buttons do
				if i <= numStances then
					button:Show()
					button:UpdateState()
				else
					button:Hide()
				end
			end
		end

		bar.UpdateButtonsStates = function(self)
			for _, button in next, self._buttons do
				button:UpdateState()
			end
		end

		bar:SetScript("OnEvent", function(self, event)
			if event == "UPDATE_SHAPESHIFT_COOLDOWN" then
				self:UpdateButtonsStates()
			elseif event == "PLAYER_REGEN_ENABLED" then
				if self.needsUpdate and not InCombatLockdown() then
					self.needsUpdate = nil
					self:UpdateButtons()
				end
			else
				if InCombatLockdown() then
					self.needsUpdate = true
					self:UpdateButtonsStates()
				else
					self:UpdateButtons()
				end
			end
		end)

		bar:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
		bar:RegisterEvent("PLAYER_ENTERING_WORLD")
		bar:RegisterEvent("PLAYER_REGEN_ENABLED")
		bar:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
		bar:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR")
		bar:RegisterEvent("UPDATE_POSSESS_BAR")
		bar:RegisterEvent("UPDATE_SHAPESHIFT_COOLDOWN")
		bar:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
		bar:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
		bar:RegisterEvent("UPDATE_SHAPESHIFT_USABLE")
		bar:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR")

		MODULE:AddBar("bar7", bar)

		local point = GetBarPoint()
		bar:SetPoint(point.p, point.anchor, point.rP, point.x, point.y)
		E:CreateMover(bar)

		bar._config = C.db.profile.bars.bar7

		bar:Update()

		isInit = true
	end
end
