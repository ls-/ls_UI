local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local MODULE = P:AddModule("Bars")

-- Lua
local _G = getfenv(0)
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
			bar:PauseFading()

			if bar.UpdateButtons then
				bar:UpdateButtons("SetAlpha", 1)
			end
		end
	end
end

local function resumeFading()
	for _, bar in next, bars do
		if bar._config.visible and bar._config.fade.enabled then
			bar:ResumeFading()
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

local function bar_UpdateConfig(self)
	self._config = E:CopyTable(C.db.profile.bars[self._id], self._config)
	self._config.click_on_down = C.db.profile.bars.click_on_down
	self._config.colors = E:CopyTable(C.db.profile.bars.colors, self._config.colors)
	self._config.desaturate_on_cd = C.db.profile.bars.desaturate_on_cd
	self._config.desaturate_when_unusable = C.db.profile.bars.desaturate_when_unusable
	self._config.draw_bling = C.db.profile.bars.draw_bling
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
			colors = {},
			text = {},
		}
	end

	self.cooldownConfig.exp_threshold = self._config.cooldown.exp_threshold
	self.cooldownConfig.m_ss_threshold = self._config.cooldown.m_ss_threshold
	self.cooldownConfig.colors = E:CopyTable(self._config.cooldown.colors, self.cooldownConfig.colors)
	self.cooldownConfig.text = E:CopyTable(self._config.cooldown.text, self.cooldownConfig.text)

	local cooldown
	for _, button in next, self._buttons do
		cooldown = button.cooldown or button.Cooldown
		if not cooldown.UpdateConfig then
			break
		end

		cooldown:UpdateConfig(self.cooldownConfig)
		cooldown:UpdateFontObject()
	end
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
	bar.UpdateConfig = bar_UpdateConfig
	bar.UpdateCooldownConfig = bar_UpdateCooldownConfig
	bar.UpdateVisibility = bar_UpdateVisibility

	if bar._buttons then
		bar.UpdateButtons = bar_UpdateButtons
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

function MODULE.IsInit()
	return isInit
end

function MODULE.Init()
	if not isInit and C.db.char.bars.enabled then
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

		isInit = true
	end
end

function MODULE.Update()
	if isInit then
		MODULE:UpdateBars("Update")
	end
end
