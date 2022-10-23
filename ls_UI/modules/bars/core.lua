local _, ns = ...
local E, C, PrC, M, L, P = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P
local MODULE = P:AddModule("Bars")

-- Lua
local _G = getfenv(0)
local next = _G.next

-- Mine
local isInit = false
local bars = {}

-- Fading
local function pauseFading()
	for _, bar in next, bars do
		if bar._config.visible and bar._config.fade.enabled then
			bar:DisableFading()

			if bar.ForEach then
				bar:ForEach("SetAlpha", 1)
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

local bar_proto = {}

function bar_proto:ForEach(method, ...)
	for _, button in next, self._buttons do
		if button[method] then
			button[method](button, ...)
		end
	end
end

function bar_proto:UpdateConfig()
	self._config = E:CopyTable(C.db.profile.bars[self._id], self._config)
	self._config.height = self._config.height ~= 0 and self._config.height or self._config.width
	self._config.desaturation = E:CopyTable(C.db.profile.bars.desaturation, self._config.desaturation)
	self._config.mana_indicator = C.db.profile.bars.mana_indicator
	self._config.range_indicator = C.db.profile.bars.range_indicator
	self._config.rightclick_selfcast = C.db.profile.bars.rightclick_selfcast

	if C.db.profile.bars[self._id].cooldown then
		self._config.cooldown = E:CopyTable(C.db.profile.bars[self._id].cooldown, self._config.cooldown)
		self._config.cooldown = E:CopyTable(C.db.profile.bars.cooldown, self._config.cooldown)
	end
end

function bar_proto:UpdateCooldownConfig()
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

function bar_proto:UpdateLayout()
	E.Layout:Update(self)
end

function bar_proto:UpdateVisibility()
	if self._config.visible then
		RegisterStateDriver(self, "visibility", self._config.visibility or "show")
	else
		RegisterStateDriver(self, "visibility", "hide")
	end
end

function MODULE:Create(id, name, isInsecure)
	local bar = Mixin(CreateFrame("Frame", name, UIParent, isInsecure and nil or "SecureHandlerStateTemplate"), bar_proto)
	bar._id = id
	bar._buttons = {}
	bars[id] = bar

	E:SetUpFading(bar)

	return bar
end

function MODULE:Register(id, bar)
	Mixin(bar, bar_proto)
	bar._id = id
	bars[id] = bar

	E:SetUpFading(bar)

	return bar
end

function MODULE:GetBars()
	return bars
end

function MODULE:ForEach(method, ...)
	for _, bar in next, bars do
		if bar[method] then
			bar[method](bar, ...)
		end
	end
end

function MODULE:For(id, method, ...)
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
	bar8 = true,
	pet = true,
	stance = true,
}

local function reassignBindings()
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

local function clearBindings()
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

function MODULE:IsInit()
	return isInit
end

function MODULE:Init()
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
		MODULE:CreateBag()
		MODULE:CreateXPBar()
		MODULE:CleanUp()
		MODULE:UpdateBlizzVehicle()

		E:RegisterEvent("ACTIONBAR_HIDEGRID", resumeFading)
		E:RegisterEvent("ACTIONBAR_SHOWGRID", pauseFading)
		E:RegisterEvent("PET_BAR_HIDEGRID", resumeFading)
		E:RegisterEvent("PET_BAR_SHOWGRID", pauseFading)
		E:RegisterEvent("PET_BATTLE_CLOSE", reassignBindings)
		E:RegisterEvent("PET_BATTLE_OPENING_DONE", clearBindings)
		E:RegisterEvent("UPDATE_BINDINGS", reassignBindings)

		if C_PetBattles.IsInBattle() then
			clearBindings()
		else
			reassignBindings()
		end

		E:WatchCVar("ActionButtonUseKeyDown", function(value)
			return value ~= "1", "1"
		end)

		E:WatchCVar("lockActionBars", function(value)
			return value ~= "1", "1"
		end)

		isInit = true
	end
end

function MODULE:Update()
	if isInit then
		self:ForEach("Update")
	end
end
