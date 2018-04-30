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
local function isMouseOverBar(frame)
	return frame:IsMouseOver(4, -4, -4, 4) or (SpellFlyout:IsShown() and SpellFlyout:GetParent() and SpellFlyout:GetParent():GetParent() == frame and SpellFlyout:IsMouseOver(4, -4, -4, 4))
end

local function bar_OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed

	-- keep it as responsive as possible, 1s / 60fps = 0.016
	if self.elapsed > 0.016 then
		if self.faded and isMouseOverBar(self) then
			self.FadeOut:Finish()
			self.FadeIn:Play()
		elseif not self.faded then
			if not isMouseOverBar(self) then
				self.FadeIn:Finish()
				self.FadeOut:Play()
			elseif isMouseOverBar(self) then
				if self.FadeOut:IsPlaying() then
					self.FadeOut:Stop()
				end
			end
		end

		self.elapsed = 0
	end
end

local function fadeIn_OnFinished(self)
	self:GetParent().faded = nil
end

local function fadeOut_OnFinished(self)
	self:GetParent().faded = true
end

local function pauseFading()
	for _, bar in next, bars do
		if bar._config.visible and bar._config.fade.enabled then
			bar:SetScript("OnUpdate", nil)
			bar.FadeIn:Stop()
			bar.FadeOut:Stop()
			bar:SetAlpha(1)

			bar.faded = nil
		end
	end
end

local function resumeFading()
	for _, bar in next, bars do
		if bar._config.visible and bar._config.fade.enabled then
			bar:SetScript("OnUpdate", bar_OnUpdate)
		end
	end
end

local function bar_UpdateFading(self)
	if self._config.visible and self._config.fade and self._config.fade.enabled then
		self.FadeIn.Anim:SetFromAlpha(self._config.fade.min_alpha)
		self.FadeIn.Anim:SetToAlpha(self._config.fade.max_alpha)
		self.FadeIn.Anim:SetStartDelay(self._config.fade.in_delay)
		self.FadeIn.Anim:SetDuration(self._config.fade.in_duration)

		self.FadeOut.Anim:SetFromAlpha(self._config.fade.max_alpha)
		self.FadeOut.Anim:SetToAlpha(self._config.fade.min_alpha)
		self.FadeOut.Anim:SetStartDelay(self._config.fade.out_delay)
		self.FadeOut.Anim:SetDuration(self._config.fade.out_duration)

		self:SetScript("OnUpdate", bar_OnUpdate)
		self.FadeOut:Finish()
		self.FadeIn:Play()
	else
		self:SetScript("OnUpdate", nil)
		self.FadeIn:Stop()
		self.FadeOut:Stop()
		self:SetAlpha(1)

		self.faded = nil
	end
end

function MODULE.InitBarFading(_, bar)
	local ag = bar:CreateAnimationGroup()
	ag:SetToFinalAlpha(true)
	ag:SetScript("OnFinished", fadeIn_OnFinished)
	bar.FadeIn = ag

	local anim = ag:CreateAnimation("Alpha")
	ag.Anim = anim

	ag = bar:CreateAnimationGroup()
	ag:SetToFinalAlpha(true)
	ag:SetScript("OnFinished", fadeOut_OnFinished)
	bar.FadeOut = ag

	anim = ag:CreateAnimation("Alpha")
	ag.Anim = anim

	bar.UpdateFading = bar_UpdateFading
end

local function bar_UpdateButtons(self, method, ...)
	for _, button in next, self._buttons do
		if button[method] then
			button[method](button, ...)
		end
	end
end

local function bar_UpdateConfig(self)
	self._config = C.db.profile.bars[self._id]
end

local function bar_UpdateVisibility(self)
	if self._config.visible then
		RegisterStateDriver(self, "visibility", self._config.visibility or "show")
	else
		RegisterStateDriver(self, "visibility", "hide")
	end
end

function MODULE.AddBar(self, barID, bar)
	bars[barID] = bar
	bar.UpdateConfig = bar_UpdateConfig
	bar.UpdateVisibility = bar_UpdateVisibility

	if bar._buttons then
		bar.UpdateButtons = bar_UpdateButtons
	end

	self:InitBarFading(bar)
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
		-- MODULE:CreateBags()
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
