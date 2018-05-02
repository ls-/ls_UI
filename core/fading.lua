local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)
local next = _G.next

--[[ luacheck: globals
	CreateFrame SpellFlyout UIParent
]]

-- Mine
local widgets = {}
local activeWidgets = {}

local function isMouseOverBar(frame)
	return frame:IsMouseOver(4, -4, -4, 4) or (SpellFlyout:IsShown() and SpellFlyout:GetParent() and SpellFlyout:GetParent():GetParent() == frame and SpellFlyout:IsMouseOver(4, -4, -4, 4))
end

local updater = CreateFrame("Frame", nil, UIParent)
updater:SetScript("OnUpdate", function(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed

	-- keep it as responsive as possible, 1s / 60fps = 0.016
	if self.elapsed > 0.016 then
		for object, widget in next, activeWidgets do
			if widget.isFading and isMouseOverBar(object) then
				widget.FadeOut:Finish()
				widget.FadeIn:Play()
			elseif not widget.isFading then
				if not isMouseOverBar(object) then
					widget.FadeIn:Finish()
					widget.FadeOut:Play()
				elseif isMouseOverBar(object) then
					if widget.FadeOut:IsPlaying() then
						widget.FadeOut:Stop()
					end
				end
			end
		end

		self.elapsed = 0
	end
end)

local function fadeIn_OnFinished(self)
	widgets[self:GetParent()].isFading = nil
end

local function fadeOut_OnFinished(self)
	widgets[self:GetParent()].isFading = true
end

local function object_PauseFading(self)
	local widget = widgets[self]
	activeWidgets[self] = nil

	if widget.FadeOut:IsPlaying() then
		widget.FadeOut:Stop()
	end

	if widget.FadeIn:IsPlaying() then
		widget.FadeIn:Stop()
	end

	widget.isFading = nil

	self:SetAlpha(1)
end

local function object_ResumeFading(self)
	local widget = widgets[self]
	activeWidgets[self] = widget
end

local function object_UpdateFading(self)
	local widget = widgets[self]

	widget.FadeIn.Anim:SetFromAlpha(self._config.fade.min_alpha)
	widget.FadeIn.Anim:SetToAlpha(self._config.fade.max_alpha)
	widget.FadeIn.Anim:SetStartDelay(self._config.fade.in_delay)
	widget.FadeIn.Anim:SetDuration(self._config.fade.in_duration)

	widget.FadeOut.Anim:SetFromAlpha(self._config.fade.max_alpha)
	widget.FadeOut.Anim:SetToAlpha(self._config.fade.min_alpha)
	widget.FadeOut.Anim:SetStartDelay(self._config.fade.out_delay)
	widget.FadeOut.Anim:SetDuration(self._config.fade.out_duration)

	if self._config.visible and self._config.fade and self._config.fade.enabled then
		object_ResumeFading(self)

		if widget.FadeOut:IsPlaying() then
			widget.FadeOut:Stop()
		end

		widget.FadeIn:Play()
	else
		object_PauseFading(self)
	end
end

function E.SetUpFading(_, object)
	local fadeIn = object:CreateAnimationGroup()
	fadeIn:SetToFinalAlpha(true)
	fadeIn:SetScript("OnFinished", fadeIn_OnFinished)
	fadeIn.Anim = fadeIn:CreateAnimation("Alpha")

	local fadeOut = object:CreateAnimationGroup()
	fadeOut:SetToFinalAlpha(true)
	fadeOut:SetScript("OnFinished", fadeOut_OnFinished)
	fadeOut.Anim = fadeOut:CreateAnimation("Alpha")

	widgets[object] = {
		FadeIn = fadeIn,
		FadeOut = fadeOut,
		isFading = nil,
	}

	object.PauseFading = object_PauseFading
	object.ResumeFading = object_ResumeFading
	object.UpdateFading = object_UpdateFading
end
