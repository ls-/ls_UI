local _, ns = ...
local E, C, PrC, M, L, P = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Bars")

-- Lua
local _G = getfenv(0)
local next = _G.next

-- Mine
local LibKeyBound = LibStub("LibKeyBound-1.0")

local isInit = false

local BUTTONS = {
	StanceButton1, StanceButton2, StanceButton3, StanceButton4, StanceButton5,
	StanceButton6, StanceButton7, StanceButton8, StanceButton9, StanceButton10,
}

local TOP_POINT = {
	round = {p = "BOTTOM", anchor = "UIParent", rP = "BOTTOM", x = 0, y = 155},
	rect = {p = "BOTTOM", anchor = "UIParent", rP = "BOTTOM", x = 0, y = 155},
}

local BOTTOM_POINT = {
	round = {p = "BOTTOM", anchor = "UIParent", rP = "BOTTOM", x = 0, y = 127},
	rect = {p = "BOTTOM", anchor = "UIParent", rP = "BOTTOM", x = 0, y = 127},
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

local function getBarPoint()
	return LAYOUT[E.PLAYER_CLASS][E.UI_LAYOUT]
end

local bar_proto = {}

function bar_proto:Update()
	self:UpdateConfig()
	self:UpdateVisibility()
	self:UpdateForms()
	self:ForEach("UpdateHotKeyFont")
	self:UpdateCooldownConfig()
	self:UpdateFading()
	E.Layout:Update(self)
end

function bar_proto:UpdateForms()
	local numStances = GetNumShapeshiftForms()

	for i, button in next, self._buttons do
		if i <= numStances then
			button:Show()
			button:Update()
		else
			button:Hide()
		end
	end
end

function bar_proto:OnEvent(event)
	if event == "UPDATE_SHAPESHIFT_COOLDOWN" then
		self:ForEach("Update")
	elseif event == "PLAYER_REGEN_ENABLED" then
		if self.needsUpdate and not InCombatLockdown() then
			self.needsUpdate = nil
			self:UpdateForms()
		end
	else
		if InCombatLockdown() then
			self.needsUpdate = true
			self:ForEach("Update")
		else
			self:UpdateForms()
		end
	end
end

local button_proto = {}

function button_proto:Update()
	if self:IsShown() then
		local id = self:GetID()
		local texture, isActive, isCastable = GetShapeshiftFormInfo(id)

		self.icon:SetTexture(texture)

		if texture then
			self.cooldown:Show()
		else
			self.cooldown:Hide()
		end

		self:SetChecked(isActive)

		if isCastable then
			self.icon:SetDesaturated(false)
			self.icon:SetVertexColor(E:GetRGB(C.db.global.colors.button.normal))
		else
			self.icon:SetDesaturated(true)
			self.icon:SetVertexColor(E:GetRGB(C.db.global.colors.button.unusable))
		end

		self.HotKey:SetVertexColor(E:GetRGB(C.db.global.colors.button.normal))

		self:UpdateHotKey()
		self:UpdateCooldown()
	end
end

function button_proto:UpdateHotKey(state)
	if state ~= nil then
		self._parent._config.hotkey.enabled = state
	end

	if self._parent._config.hotkey.enabled then
		self.HotKey:SetParent(self)
		self.HotKey:SetFormattedText("%s", self:GetHotkey())
		self.HotKey:Show()
	else
		self.HotKey:SetParent(E.HIDDEN_PARENT)
	end
end

function button_proto:UpdateHotKeyFont()
	self.HotKey:UpdateFont(self._parent._config.hotkey.size)
end

function button_proto:UpdateCooldown()
	CooldownFrame_Set(self.cooldown, GetShapeshiftFormCooldown(self:GetID()))
end

function button_proto:OnEnterHook()
	if LibKeyBound then
		LibKeyBound:Set(self)
	end
end

function MODULE:CreateStanceBar()
	if not isInit then
		local bar = Mixin(self:Create("stance", "LSStanceBar"), bar_proto)

		for i = 1, #BUTTONS do
			local button = Mixin(CreateFrame("CheckButton", "$parentButton" .. i, bar, "StanceButtonTemplate"), button_proto)
			button:SetID(i)
			button:SetScript("OnEvent", nil)
			button:SetScript("OnUpdate", nil)
			button:HookScript("OnEnter", button.OnEnterHook)
			button:UnregisterAllEvents()
			button._parent = bar
			button._command = "SHAPESHIFTBUTTON" .. i
			bar._buttons[i] = button

			E:SkinStanceButton(button)

			BUTTONS[i]:SetAllPoints(button)
			BUTTONS[i]:SetAttribute("statehidden", true)
			BUTTONS[i]:SetParent(E.HIDDEN_PARENT)
			BUTTONS[i]:SetScript("OnEvent", nil)
			BUTTONS[i]:SetScript("OnUpdate", nil)
			BUTTONS[i]:UnregisterAllEvents()
		end

		bar:SetScript("OnEvent", bar.OnEvent)

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

		local point = getBarPoint()
		bar:SetPoint(point.p, point.anchor, point.rP, point.x, point.y)
		E.Movers:Create(bar)

		bar:Update()

		isInit = true
	end
end
