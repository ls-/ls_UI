local _, ns = ...
local E, C, PrC, M, L, P = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P
local MODULE = P:AddModule("Bars")

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local next = _G.next

-- Blizz
local C_PetBattles = _G.C_PetBattles

--[[ luacheck: globals
	ClearOverrideBindings CreateFrame GetBindingKey InCombatLockdown MainMenuBar OverrideActionBar RegisterStateDriver
	SetCVar SetOverrideBindingClick SpellFlyout UIParent UnregisterStateDriver
]]

-- Mine
local isInit = false
local bars = {}

function MODULE.GetBars()
	return bars
end

function MODULE.GetBar(_, barID)
	return bars[barID]
end

-- Fading
local function pauseFading()
	for _, bar in next, bars do
		if bar._config.visible and bar._config.fade.enabled then
			bar:DisableFading()

			if bar.UpdateButtons then
				bar:UpdateButtons("SetAlpha", 1)
			end
		end
	end
end

local function resumeFading()
	for _, bar in next, bars do
		if bar._config.visible and bar._config.fade.enabled then
			bar:EnableFading()
		end
	end
end

-- Updates
local function bar_UpdateButtons(self, method, ...)
	for _, button in next, self._buttons do
		if button[method] then
			button[method](button, ...)
		end
	end
end

local function bar_ForEach(self, method, ...)
	for _, button in next, self._buttons do
		if button[method] then
			button[method](button, ...)
		end
	end
end

local function bar_UpdateConfig(self)
	self._config = E:CopyTable(C.db.profile.bars[self._id], self._config)
	self._config.click_on_down = C.db.profile.bars.click_on_down
	self._config.desaturation = E:CopyTable(C.db.profile.bars.desaturation, self._config.desaturation)
	self._config.lock = C.db.profile.bars.lock
	self._config.mana_indicator = C.db.profile.bars.mana_indicator
	self._config.range_indicator = C.db.profile.bars.range_indicator
	self._config.rightclick_selfcast = C.db.profile.bars.rightclick_selfcast

	if C.db.profile.bars[self._id].cooldown then
		self._config.cooldown = E:CopyTable(C.db.profile.bars[self._id].cooldown, self._config.cooldown)
		self._config.cooldown = E:CopyTable(C.db.profile.bars.cooldown, self._config.cooldown)
	end
end

local function bar_UpdateCooldownConfig(self)
	if not self.cooldownConfig then
		self.cooldownConfig = {
			swipe = {},
			text = {},
		}
	end

	self.cooldownConfig = E:CopyTable(self._config.cooldown, self.cooldownConfig)

	local cooldown
	for _, button in next, self._buttons do
		cooldown = button.cooldown or button.Cooldown
		if not cooldown.UpdateConfig then
			break
		end

		cooldown:UpdateConfig(self.cooldownConfig)
		cooldown:UpdateFont()
		cooldown:UpdateSwipe()
	end
end

local function bar_UpdateLayout(self)
	E.Layout:Update(self)
end

local function bar_UpdateVisibility(self)
	if self._config.visible then
		RegisterStateDriver(self, "visibility", self._config.visibility or "show")
	else
		RegisterStateDriver(self, "visibility", "hide")
	end
end

function MODULE.AddBar(_, barID, bar)
	bars[barID] = bar
	bar.UpdateConfig = bar.UpdateConfig or bar_UpdateConfig
	bar.UpdateCooldownConfig = bar.UpdateCooldownConfig or bar_UpdateCooldownConfig
	bar.UpdateLayout = bar.UpdateLayout or bar_UpdateLayout
	bar.UpdateVisibility = bar.UpdateVisibility or bar_UpdateVisibility

	if bar._buttons then
		bar.ForEach = bar.ForEach or bar_ForEach
		bar.UpdateButtons = bar.UpdateButtons or bar_UpdateButtons
	end

	E:SetUpFading(bar)
end

function MODULE.UpdateBars(_, method, ...)
	for _, bar in next, bars do
		if bar[method] then
			bar[method](bar, ...)
		end
	end
end

function MODULE:ForEach(method, ...)
	for _, bar in next, bars do
		if bar[method] then
			bar[method](bar, ...)
		end
	end
end

function MODULE:ForBar(id, method, ...)
	if bars[id] and bars[id][method] then
		bars[id][method](bars[id], ...)
	end
end

-- Bindings
local rebindable = {
	bar1 = true,
	bar2 = true,
	bar3 = true,
	bar4 = true,
	bar5 = true,
	bar6 = true,
	bar7 = true,
}

function MODULE.ReassignBindings()
	if not InCombatLockdown() then
		for barID, bar in next, bars do
			if rebindable[barID] then
				ClearOverrideBindings(bar)

				for _, button in next, bar._buttons do
					for _, key in next, {GetBindingKey(button._command)} do
						if key and key ~= "" then
							SetOverrideBindingClick(bar, false, key, button:GetName())
						end
					end
				end
			end
		end
	end
end

function MODULE.ClearBindings()
	if not InCombatLockdown() then
		for barID, bar in next, bars do
			if rebindable[barID] then
				ClearOverrideBindings(bar)
			end
		end
	end
end

local vehicleController

function MODULE:UpdateBlizzVehicle()
	if not self:IsRestricted() then
		if C.db.profile.bars.blizz_vehicle then
			-- MainMenuBar:SetParent(UIParent)
			OverrideActionBar:SetParent(UIParent)

			if not vehicleController then
				vehicleController = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
				vehicleController:SetFrameRef("bar", OverrideActionBar)
				vehicleController:SetAttribute("_onstate-vehicle", [[
					if newstate == "override" then
						if (self:GetFrameRef("bar"):GetAttribute("actionpage") or 0) > 10 then
							newstate = "vehicle"
						end
					end

					if newstate == "vehicle" then
						local bar = self:GetFrameRef("bar")

						for i = 1, 6 do
							local button = ("ACTIONBUTTON%d"):format(i)

							for k = 1, select("#", GetBindingKey(button)) do
								bar:SetBindingClick(true, select(k, GetBindingKey(button)), ("OverrideActionBarButton%d"):format(i))
							end
						end
					else
						self:GetFrameRef("bar"):ClearBindings()
					end
				]])
			end

			RegisterStateDriver(vehicleController, "vehicle", "[overridebar] override; [vehicleui] vehicle; novehicle")
		else
			-- MainMenuBar:SetParent(E.HIDDEN_PARENT)
			OverrideActionBar:SetParent(E.HIDDEN_PARENT)

			if vehicleController then
				UnregisterStateDriver(vehicleController, "vehicle")
			end
		end
	else
		-- MainMenuBar:SetParent(E.HIDDEN_PARENT)
		OverrideActionBar:SetParent(E.HIDDEN_PARENT)
	end
end

-----

local isNPEHooked = false

local function disableNPE()
	if NewPlayerExperience then
		if NewPlayerExperience:GetIsActive() then
			NewPlayerExperience:Shutdown()
		end

		if not isNPEHooked then
			hooksecurefunc(NewPlayerExperience, "Begin", disableNPE)
			isNPEHooked = true
		end
	end
end

-----

function MODULE.IsInit()
	return isInit
end

function MODULE.Init()
	if not isInit and PrC.db.profile.bars.enabled then
		MODULE:SetupActionBarController()
		MODULE:CreateActionBars()
		MODULE:CreateStanceBar()
		MODULE:CreatePetActionBar()
		MODULE:CreatePetBattleBar()
		MODULE:CreateExtraButton()
		MODULE:CreateZoneButton()
		MODULE:CreateVehicleExitButton()
		MODULE:CreateMicroMenu()
		MODULE:CreateXPBar()
		MODULE:ReassignBindings()
		MODULE:CleanUp()
		MODULE:UpdateBlizzVehicle()

		E:RegisterEvent("ACTIONBAR_HIDEGRID", resumeFading)
		E:RegisterEvent("ACTIONBAR_SHOWGRID", pauseFading)
		E:RegisterEvent("PET_BAR_HIDEGRID", resumeFading)
		E:RegisterEvent("PET_BAR_SHOWGRID", pauseFading)
		E:RegisterEvent("PET_BATTLE_CLOSE", MODULE.ReassignBindings)
		E:RegisterEvent("PET_BATTLE_OPENING_DONE", MODULE.ClearBindings)
		E:RegisterEvent("UPDATE_BINDINGS", MODULE.ReassignBindings)

		if C_PetBattles.IsInBattle() then
			MODULE:ClearBindings()
		else
			MODULE:ReassignBindings()
		end

		SetCVar("ActionButtonUseKeyDown", C.db.profile.bars.click_on_down and 1 or 0)
		SetCVar("lockActionBars", C.db.profile.bars.lock and 1 or 0)

		if NewPlayerExperience then
			disableNPE()
		else
			E:AddOnLoadTask("Blizzard_NewPlayerExperience", disableNPE)
		end

		isInit = true
	end
end

function MODULE.Update()
	if isInit then
		MODULE:UpdateBars("Update")
	end
end
