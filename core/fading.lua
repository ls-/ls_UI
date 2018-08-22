local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)
local next = _G.next

--[[ luacheck: globals
	CreateFrame SpellFlyout UIParent
]]

-- Mine
local activeWidgets = {}
local miscWidgets = {}
local widgets = {}

local updater = CreateFrame("Frame", nil, UIParent)
local config

updater:SetScript("OnUpdate", function(_, elapsed)
	for object, widget in next, activeWidgets do
		widget.fadeTimer = widget.fadeTimer + elapsed
		config = widget.config

		if widget.mode == "IN" then
			if widget.fadeTimer >= config.in_delay then
				object:SetAlpha(config.min_alpha + ((config.max_alpha - config.min_alpha) * ((widget.fadeTimer - config.in_delay) / config.in_duration)))

				if widget.fadeTimer >= config.in_delay + config.in_duration then
					activeWidgets[object] = nil
					object:SetAlpha(config.max_alpha)
					widget.mode = nil
					widget.isFaded = nil
				end
			end
		elseif widget.mode == "OUT" then
			if widget.fadeTimer >= config.out_delay then
				object:SetAlpha(config.max_alpha - ((config.max_alpha - config.min_alpha) * ((widget.fadeTimer - config.out_delay) / config.out_duration)))

				if widget.fadeTimer >= config.out_delay + config.out_duration then
					activeWidgets[object] = nil
					object:SetAlpha(config.min_alpha)
					widget.mode = nil
					widget.isFaded = true
				end
			end
		end
	end
end)

local function isMouseOverBar(frame)
	return frame:IsMouseOver(4, -4, -4, 4)
		or (SpellFlyout:IsShown() and SpellFlyout:GetParent() and SpellFlyout:GetParent():GetParent() == frame and SpellFlyout:IsMouseOver(4, -4, -4, 4))
end

local function fader_OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > 0.032 then
		local widget = widgets[self.object]
		if widget then
			if widget.isFaded and isMouseOverBar(self.object) then
				if widget.mode ~= "IN" then
					widget.mode = "IN"
					widget.fadeTimer = 0
					activeWidgets[self.object] = widget
				end
			elseif not widget.isFaded then
				if not isMouseOverBar(self.object) then
					if widget.mode ~= "OUT" then
						widget.mode = "OUT"
						widget.fadeTimer = 0
						activeWidgets[self.object] = widget
					end
				else
					if widget.mode == "OUT" then
						widget.mode = nil
						widget.isFaded = nil
						activeWidgets[self.object] = nil
						self.object:SetAlpha(widget.config.max_alpha)
					end
				end
			end
		end

		self.elapsed = 0
	end
end

local function fader_OnHide(self)
	widgets[self.object].isFaded = nil
	self.object:SetAlpha(1)
end

local function object_PauseFading(self)
	self.Fader:SetScript("OnUpdate", nil)

	widgets[self].isFaded = nil

	self:SetAlpha(1)
end

local function object_ResumeFading(self)
	self.Fader.elapsed = 0
	self.Fader:SetScript("OnUpdate", fader_OnUpdate)
end

local function object_UpdateFading(self)
	widgets[self].config = E:CopyTable(self._config.fade, widgets[self].config)
	widgets[self].isFaded = nil

	if self._config.visible and self._config.fade and self._config.fade.enabled then
		object_ResumeFading(self)
	else
		object_PauseFading(self)
	end
end

function E.SetUpFading(_, object)
	local fader = CreateFrame("Frame", "$parentFader", object)
	fader:SetFrameLevel(object:GetFrameLevel())
	fader:SetPoint("TOPLEFT", -4, 4)
	fader:SetPoint("BOTTOMRIGHT", 4, -4)
	fader:SetScript("OnHide", fader_OnHide)
	fader:SetMouseClickEnabled(false)
	fader.object = object
	fader.threshold = 0.05

	widgets[object] = {}

	object.Fader = fader
	object.PauseFading = object_PauseFading
	object.ResumeFading = object_ResumeFading
	object.UpdateFading = object_UpdateFading
end

function E:FadeIn(object, inDelay, inDuration, minAlpha, maxAlpha)
	if not miscWidgets[object] then
		miscWidgets[object] = {
			config = {
				in_delay = 0,
				in_duration = 0.15,
				max_alpha = 1,
				min_alpha = 0,
				out_delay = 0,
				out_duration = 0.05,
			},
		}
	end

	if inDelay then
		miscWidgets[object].config.in_delay = inDelay
	end

	if inDuration then
		miscWidgets[object].config.in_duration = inDuration
	end

	if minAlpha then
		miscWidgets[object].config.min_alpha = minAlpha
	end

	if maxAlpha then
		miscWidgets[object].config.max_alpha = maxAlpha
	end

	miscWidgets[object].mode = "IN"
	miscWidgets[object].fadeTimer = 0
	activeWidgets[object] = miscWidgets[object]
end

function E:FadeOut(object, outDelay, outDuration, minAlpha, maxAlpha)
	if not miscWidgets[object] then
		miscWidgets[object] = {
			config = {
				in_delay = 0,
				in_duration = 0.15,
				max_alpha = 1,
				min_alpha = 0,
				out_delay = 0,
				out_duration = 0.05,
			},
		}
	end

	if outDelay then
		miscWidgets[object].config.out_delay = outDelay
	end

	if outDuration then
		miscWidgets[object].config.out_duration = outDuration
	end

	if minAlpha then
		miscWidgets[object].config.min_alpha = minAlpha
	end

	if maxAlpha then
		miscWidgets[object].config.max_alpha = maxAlpha
	end

	miscWidgets[object].mode = "OUT"
	miscWidgets[object].fadeTimer = 0
	activeWidgets[object] = miscWidgets[object]
end
