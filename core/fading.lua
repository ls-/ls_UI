local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)
local next = _G.next

-- Mine
local activeWidgets = {}
local miscWidgets = {}
local oocWidgets = {} -- out of combat
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
					widget.mode = nil
					widget.isFaded = nil
					activeWidgets[object] = nil

					object:SetAlpha(config.max_alpha)
				end
			end
		elseif widget.mode == "OUT" then
			if widget.fadeTimer >= config.out_delay then
				object:SetAlpha(config.max_alpha - ((config.max_alpha - config.min_alpha) * ((widget.fadeTimer - config.out_delay) / config.out_duration)))

				if widget.fadeTimer >= config.out_delay + config.out_duration then
					widget.mode = nil
					widget.isFaded = true
					activeWidgets[object] = nil

					object:SetAlpha(config.min_alpha)
				end
			end
		end
	end
end)

updater:SetScript("OnEvent", function(_, event)
	if event == "PLAYER_REGEN_ENABLED" then
		for object in next, oocWidgets do
			object:UpdateFading()
		end
	elseif event == "PLAYER_REGEN_DISABLED" then
		for object in next, oocWidgets do
			object:StopFading()
		end
	end
end)

updater:RegisterEvent("PLAYER_REGEN_ENABLED")
updater:RegisterEvent("PLAYER_REGEN_DISABLED")

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
	widgets[self.object].mode = nil
	widgets[self.object].isFaded = nil
	activeWidgets[self.object] = nil

	self.object:SetAlpha(1)
end

local object_proto = {}

function object_proto:StopFading()
	self.Fader:SetScript("OnUpdate", nil)

	widgets[self].mode = nil
	widgets[self].isFaded = nil
	activeWidgets[self] = nil

	-- I might want to rework how it's handeled
	E:FadeIn(self, widgets[self].config.in_delay, widgets[self].config.in_duration, widgets[self].config.min_alpha, widgets[self].config.max_alpha)
end

function object_proto:ResumeFading()
	self.Fader.elapsed = 0
	self.Fader:SetScript("OnUpdate", fader_OnUpdate)
end

function object_proto:UpdateFading()
	widgets[self].config = E:CopyTable(self._config.fade, widgets[self].config)
	widgets[self].isFaded = nil

	if widgets[self].config.ooc then
		oocWidgets[self] = true
	else
		oocWidgets[self] = nil
	end

	-- FIXME! use this ugly ~= false check for now, it's related to action bars
	-- I'll fix when I'm rewriting those
	if self._config.visible ~= false and widgets[self].config.enabled then
		self:ResumeFading()
	else
		self:StopFading()
	end
end

function E:SetUpFading(object)
	local fader = CreateFrame("Frame", "$parentFader", object)
	fader:SetFrameLevel(object:GetFrameLevel())
	fader:SetPoint("TOPLEFT", -4, 4)
	fader:SetPoint("BOTTOMRIGHT", 4, -4)
	fader:SetScript("OnHide", fader_OnHide)
	fader:SetMouseClickEnabled(false)
	fader.object = object
	fader.threshold = 0.05

	widgets[object] = {
		config = {},
	}

	object.Fader = fader

	P:Mixin(object, object_proto)

	return object
end

function E:FadeIn(object, inDelay, inDuration, minAlpha, maxAlpha)
	-- override the already existing entry for a widget
	-- reset it via UpdateFading later
	local tbl = widgets[object] and widgets or miscWidgets

	if not tbl[object] then
		tbl[object] = {
			config = {},
		}
	end

	tbl[object].config.in_delay = inDelay or 0
	tbl[object].config.in_duration = inDuration or 0.15
	tbl[object].config.min_alpha = minAlpha or 0
	tbl[object].config.max_alpha = maxAlpha or 1
	tbl[object].config.out_delay = 0
	tbl[object].config.out_duration = 0.15

	tbl[object].mode = "IN"
	tbl[object].fadeTimer = 0
	activeWidgets[object] = tbl[object]
end

function E:FadeOut(object, outDelay, outDuration, minAlpha, maxAlpha)
	-- override the already existing entry for a widget
	-- reset it via UpdateFading later
	local tbl = widgets[object] and widgets or miscWidgets

	if not tbl[object] then
		tbl[object] = {
			config = {},
		}
	end

	tbl[object].config.in_delay = 0
	tbl[object].config.in_duration = 0.15
	tbl[object].config.min_alpha = minAlpha or 0
	tbl[object].config.max_alpha = maxAlpha or 1
	tbl[object].config.out_delay = outDelay or 0
	tbl[object].config.out_duration = outDuration or 0.15

	tbl[object].mode = "OUT"
	tbl[object].fadeTimer = 0
	activeWidgets[object] = tbl[object]
end
