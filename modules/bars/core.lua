local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local MODULE = P:AddModule("Bars")

-- Lua
local _G = getfenv(0)
local next = _G.next

-- Blizz
local MouseIsOver = _G.MouseIsOver

-- Mine
local isInit = false
local bars = {}

function MODULE.GetBars()
	return bars
end

function MODULE.GetBar(_, barID)
	return bars[barID]
end

-- Fading & visibility
local function isMouseOverBar(frame)
	return MouseIsOver(frame) or (SpellFlyout:IsShown() and SpellFlyout:GetParent() and SpellFlyout:GetParent():GetParent() == frame and MouseIsOver(SpellFlyout))
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
	for id, bar in next, bars do
		local config = C.db.profile.bars[id]

		if config.visible and config.fade.enabled then
			bar:SetScript("OnUpdate", nil)
			bar.FadeIn:Stop()
			bar.FadeOut:Stop()
			bar:SetAlpha(1)

			bar.faded = nil
		end
	end
end

E:RegisterEvent("ACTIONBAR_SHOWGRID", pauseFading)
E:RegisterEvent("PET_BAR_SHOWGRID", pauseFading)

local function resumeFading()
	for id, bar in next, bars do
		local config = C.db.profile.bars[id]

		if config.visible and config.fade.enabled then
			bar:SetScript("OnUpdate", bar_OnUpdate)
		end
	end
end

E:RegisterEvent("ACTIONBAR_HIDEGRID", resumeFading)
E:RegisterEvent("PET_BAR_HIDEGRID", resumeFading)

function MODULE.UpdateBarVisibility(_, bar)
	if bar._config.visibility then
		E:SetFrameState(bar, "visibility", bar._config.visible and bar._config.visibility or "hide")
	end

	if bar._config.visible and bar._config.fade and bar._config.fade.enabled then
		bar.FadeIn.Anim:SetFromAlpha(bar._config.fade.min_alpha)
		bar.FadeIn.Anim:SetToAlpha(bar._config.fade.max_alpha)
		bar.FadeIn.Anim:SetStartDelay(bar._config.fade.in_delay)
		bar.FadeIn.Anim:SetDuration(bar._config.fade.in_duration)

		bar.FadeOut.Anim:SetFromAlpha(bar._config.fade.max_alpha)
		bar.FadeOut.Anim:SetToAlpha(bar._config.fade.min_alpha)
		bar.FadeOut.Anim:SetStartDelay(bar._config.fade.out_delay)
		bar.FadeOut.Anim:SetDuration(bar._config.fade.out_duration)

		bar:SetScript("OnUpdate", bar_OnUpdate)
	else
		bar:SetScript("OnUpdate", nil)
		bar.FadeIn:Stop()
		bar.FadeOut:Stop()
		bar:SetAlpha(1)

		bar.faded = nil
	end
end

-- LAB config
local LAB_bars = {
	bar1 = true,
	bar2 = true,
	bar3 = true,
	bar4 = true,
	bar5 = true,
}

function MODULE.UpdateBarLABConfig(_, bar)
	if LAB_bars[bar._id] then
		local buttonConfig = {
			outOfRangeColoring = C.db.profile.bars.range_indicator,
			tooltip = C.db.profile.bars.tooltip,
			showGrid = bar._config.grid,
			colors = {
				range = {
					[1] = C.db.profile.bars.colors.range[1],
					[2] = C.db.profile.bars.colors.range[2],
					[3] = C.db.profile.bars.colors.range[3],
				},
				mana = {
					[1] = C.db.profile.bars.colors.mana[1],
					[2] = C.db.profile.bars.colors.mana[2],
					[3] = C.db.profile.bars.colors.mana[3],
				},
			},
			hideElements = {
				macro = not bar._config.macro,
				hotkey = not bar._config.hotkey,
				equipped = false,
			},
			clickOnDown = false,
			flyoutDirection = bar._config.flyout_dir,
		}

		for _, button in next, bar._buttons do
			buttonConfig.keyBoundTarget = button._command

			button:UpdateConfig(buttonConfig)
			button:SetAttribute("buttonlock", C.db.profile.bars.lock)
			button:SetAttribute("checkselfcast", true)
			button:SetAttribute("checkfocuscast", true)
			button:SetAttribute("*unit2", C.db.profile.bars.rightclick_selfcast and "player" or nil)
		end
	end
end

function MODULE.AddBar(_, barID, bar)
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

	bars[barID] = bar
	bars[barID].Update = function(self)
		MODULE:UpdateBarVisibility(self)
		MODULE:UpdateBarLABConfig(self)
		E:UpdateBarLayout(self)
	end
end

function MODULE.UpdateBar(_, bar)
	bar._config = C.db.profile.bars[bar._id]

	bar:Update()
end

function MODULE.UpdateBars()
	for id, bar in next, bars do
		bar._config = C.db.profile.bars[id]

		bar:Update()
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

E:RegisterEvent("UPDATE_BINDINGS", MODULE.ReassignBindings)

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
		MODULE:CreateBags()
		MODULE:ReassignBindings()
		MODULE:CleanUp()

		isInit = true
	end
end

function MODULE.Update()
	if isInit then
		MODULE:UpdateBars()
		MODULE:UpdateExtraButton()
		MODULE:UpdateZoneButton()
		MODULE:UpdateMicroButtons()
		MODULE:UpdateVehicleExitButton()
		MODULE:UpdateXPBar()
	end
end
