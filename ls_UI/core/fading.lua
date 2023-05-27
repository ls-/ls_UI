local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF, Profiler = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF, ns.Profiler

-- Lua
local _G = getfenv(0)
local collectgarbage = _G.collectgarbage
local debugprofilestop = _G.debugprofilestop
local next = _G.next

-- Mine
local function clamp(v)
	if v > 1 then
		return 1
	elseif v < 0 then
		return 0
	end

	return v
end

local function lerp(v1, v2, perc)
	return clamp(v1 + (v2 - v1) * perc)
end

local FADE_IN = 1
local FADE_OUT = -1

local widgets = {}
local miscWidgets = {}

local targetWidgets = {}

local function addTargetWidget(object, widget)
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	widget.hasTarget = UnitExists("target") or UnitExists("focus")
	targetWidgets[object] = widget

	if Profiler:IsLogging() then
		Profiler:Log("local fading", "addTargetWidget", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

local function removeTargetWidget(object, widget)
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	widget.hasTarget = nil
	targetWidgets[object] = nil

	if Profiler:IsLogging() then
		Profiler:Log("local fading", "removeTargetWidget", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

local combatWidgets = {}

local function addCombatWidget(object, widget)
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	widget.inCombat = InCombatLockdown()
	combatWidgets[object] = widget

	if Profiler:IsLogging() then
		Profiler:Log("local fading", "addCombatWidget", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

local function removeCombatWidget(object, widget)
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	widget.inCombat = nil
	combatWidgets[object] = nil

	if Profiler:IsLogging() then
		Profiler:Log("local fading", "removeCombatWidget", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

local healthWidgets = {}

local function addHealthWidget(object, widget)
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	widget.maxHealth = (UnitHealth("player") / UnitHealthMax("player")) == 1
	healthWidgets[object] = widget

	if Profiler:IsLogging() then
		Profiler:Log("local fading", "addHealthWidget", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

local function removeHealthWidget(object, widget)
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	widget.maxHealth = nil
	healthWidgets[object] = nil

	if Profiler:IsLogging() then
		Profiler:Log("local fading", "removeHealthWidget", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

local activeWidgets = {}
local addActiveWidget, removeActiveWidget

local updater = CreateFrame("Frame", "LSFadingUpdater")

local function updater_OnUpdate(_, elapsed)
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	for object, widget in next, activeWidgets do
		widget.fadeTimer = widget.fadeTimer + elapsed
		widget.initAlpha = widget.initAlpha or object:GetAlpha()

		if widget.mode == FADE_IN then
			widget.isFading = true

			object:SetAlpha(lerp(widget.initAlpha, widget.config.max_alpha, widget.fadeTimer / widget.config.in_duration))

			if widget.fadeTimer >= widget.config.in_duration then
				removeActiveWidget(object, widget, nil, true)

				if widget.callback then
					widget.callback(object)
					widget.callback = nil
				end

				object:SetAlpha(widget.config.max_alpha)
			end
		elseif widget.mode == FADE_OUT then
			if widget.fadeTimer >= 0 then
				widget.isFading = true

				object:SetAlpha(lerp(widget.initAlpha, widget.config.min_alpha, widget.fadeTimer / widget.config.out_duration))

				if widget.fadeTimer >= widget.config.out_duration then
					removeActiveWidget(object, widget, true)

					if widget.callback then
						widget.callback(object)
						widget.callback = nil
					end

					object:SetAlpha(widget.config.min_alpha)
				end
			end
		end
	end

	if Profiler:IsLogging() then
		Profiler:Log("LSFadingUpdater", "OnUpdate", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

function addActiveWidget(object, widget, mode)
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	widget.mode = mode
	widget.fadeTimer = mode == FADE_OUT and -widget.config.out_delay or 0
	widget.initAlpha = nil
	activeWidgets[object] = widget

	if not updater:GetScript("OnUpdate") then
		updater:SetScript("OnUpdate", updater_OnUpdate)
	end

	if Profiler:IsLogging() then
		Profiler:Log("local fading", "addActiveWidget", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

function removeActiveWidget(object, widget, atMinAlpha, atMaxAlpha)
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	widget.mode = nil
	widget.atMaxAlpha = atMaxAlpha
	widget.atMinAlpha = atMinAlpha
	widget.isFading = nil
	activeWidgets[object] = nil

	if not next(activeWidgets) then
		updater:SetScript("OnUpdate", nil)
	end

	if Profiler:IsLogging() then
		Profiler:Log("local fading", "removeActiveWidget", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

updater:SetScript("OnEvent", function(self, event)
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	if event == "PLAYER_REGEN_DISABLED" then
		for object, widget in next, combatWidgets do
			widget.inCombat = true

			object:DisableFading()
		end
	elseif event == "PLAYER_REGEN_ENABLED" then
		for object, widget in next, combatWidgets do
			widget.inCombat = false

			object:EnableFading()
		end
	elseif event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_FOCUS_CHANGED" then
		if UnitExists("target") or UnitExists("focus") then
			if not self.hasTarget then
				for object, widget in next, targetWidgets do
					widget.hasTarget = true

					object:DisableFading()
				end

				self.hasTarget = true
			end
		else
			for object, widget in next, targetWidgets do
				widget.hasTarget = false

				object:EnableFading()
			end

			self.hasTarget = false
		end
	elseif event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" then
		if (UnitHealth("player") / UnitHealthMax("player")) == 1 then
			if not self.maxHealth then
				for object, widget in next, healthWidgets do
					widget.maxHealth = true

					object:EnableFading()
				end

				self.maxHealth = true
			end
		else
			for object, widget in next, healthWidgets do
				widget.maxHealth = false

				object:DisableFading()
			end

			self.maxHealth = false
		end
	end

	if Profiler:IsLogging() then
		Profiler:Log("LSFadingUpdater", "OnEvent", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end)

-- combat widgets
updater:RegisterEvent("PLAYER_REGEN_ENABLED")
updater:RegisterEvent("PLAYER_REGEN_DISABLED")

-- target widgets
updater:RegisterEvent("PLAYER_TARGET_CHANGED")
updater:RegisterEvent("PLAYER_FOCUS_CHANGED")

-- player hp widgets
-- ? should I add others units? I don't have party/raid frames, but...
updater:RegisterUnitEvent("UNIT_HEALTH", "player")
updater:RegisterUnitEvent("UNIT_MAXHEALTH", "player")

local function isMouseOver(frame)
	return frame:IsMouseOver(4, -4, -4, 4)
		or (SpellFlyout:IsShown() and SpellFlyout:GetParent() and SpellFlyout:GetParent():GetParent() == frame and SpellFlyout:IsMouseOver(4, -4, -4, 4))
end

local hoverWidgets = {}
local addHoverWidget, removeHoverWidget

local hoverUpdater = CreateFrame("Frame", "LSHoverFadingUpdater")

local function hoverUpdater_OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > 0.016 then -- limit to 60 fps
		local timeStart, memStart
		if Profiler:IsLogging() then
			timeStart, memStart = debugprofilestop(), collectgarbage("count")
		end

		for object, widget in next, hoverWidgets do
			if object:IsShown() then
				if isMouseOver(object) then
					if (not widget.atMaxAlpha or widget.isFading) and widget.mode ~= FADE_IN then
						addActiveWidget(object, widget, FADE_IN)
					end
				elseif (not widget.atMinAlpha and not widget.isFading) and widget.mode ~= FADE_OUT then
					addActiveWidget(object, widget, FADE_OUT)
				end
			end
		end

		self.elapsed = 0

		if Profiler:IsLogging() then
			Profiler:Log("LSHoverFadingUpdater", "OnUpdate", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
		end
	end
end

function addHoverWidget(object, widget)
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	widget.canHover = true
	hoverWidgets[object] = widget

	if not hoverUpdater:GetScript("OnUpdate") then
		hoverUpdater:SetScript("OnUpdate", hoverUpdater_OnUpdate)
	end

	if Profiler:IsLogging() then
		Profiler:Log("local fading", "addHoverWidget", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

function removeHoverWidget(object, widget)
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	widget.canHover = nil
	hoverWidgets[object] = nil

	if not next(hoverWidgets) then
		hoverUpdater:SetScript("OnUpdate", nil)
	end

	if Profiler:IsLogging() then
		Profiler:Log("local fading", "removeHoverWidget", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

local object_proto = {}

function object_proto:DisableFading(ignoreFade)
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	local widget = widgets[self]

	-- it's nil on load, but we still want to get in
	if widget.canHover ~= false then
		removeHoverWidget(self, widget)

		if not ignoreFade and (widget.atMinAlpha or widget.mode ~= FADE_IN) then
			addActiveWidget(self, widget, FADE_IN)
		end
	end

	if Profiler:IsLogging() then
		Profiler:Log(self:GetDebugName(), "DisableFading", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

function object_proto:EnableFading()
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	local widget = widgets[self]

	if not (widget.inCombat or widget.hasTarget) and widget.maxHealth ~= false then
		addHoverWidget(self, widget)
	end

	if Profiler:IsLogging() then
		Profiler:Log(self:GetDebugName(), "EnableFading", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

function object_proto:UpdateFading()
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	local widget = widgets[self]

	widget.config = E:CopyTable(self._config.fade, widget.config)

	removeActiveWidget(self, widget)
	removeTargetWidget(self, widget)
	removeCombatWidget(self, widget)
	removeHealthWidget(self, widget)

	-- reset alpha, kinda ghetto, but it works
	self:SetAlpha(1)
	self:DisableFading()

	-- FIXME! use this ugly ~= false check for now, it's related to action bars
	-- I'll fix when I'm rewriting those
	if self._config.visible ~= false and widget.config.enabled then
		if widget.config.combat then
			addCombatWidget(self, widget)
		end

		if widget.config.target then
			addTargetWidget(self, widget)
		end

		if widget.config.health then
			addHealthWidget(self, widget)
		end

		self:EnableFading()
	end

	if Profiler:IsLogging() then
		Profiler:Log(self:GetDebugName(), "UpdateFading", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

function E:SetUpFading(object)
	if widgets[object] then
		return
	end

	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	local fader = CreateFrame("Frame", "$parentFader", object)
	fader:SetFrameLevel(object:GetFrameLevel())
	fader:SetPoint("TOPLEFT", -4, 4)
	fader:SetPoint("BOTTOMRIGHT", 4, -4)
	fader:SetMouseClickEnabled(false)

	widgets[object] = {
		config = {},
	}

	object.Fader = fader

	Mixin(object, object_proto)

	if Profiler:IsLogging() then
		Profiler:Log("E", "SetUpFading", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end

	return object
end

local function resetCallback(object)
	object:UpdateFading()
end

function E:FadeIn(object, inDuration, minAlpha, maxAlpha, shouldReset)
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	if widgets[object] then
		removeActiveWidget(object, widgets[object])

		object:DisableFading(true)
	end

	local tbl = widgets[object] and widgets or miscWidgets

	if not tbl[object] then
		tbl[object] = {
			config = {},
		}
	end

	tbl[object].config.in_duration = inDuration or 0.15
	tbl[object].config.min_alpha = minAlpha or 0
	tbl[object].config.max_alpha = maxAlpha or 1
	tbl[object].config.out_delay = 0
	tbl[object].config.out_duration = 0.15

	if shouldReset then
		tbl[object].callback = resetCallback
	end

	addActiveWidget(object, tbl[object], FADE_IN)

	if Profiler:IsLogging() then
		Profiler:Log("E", "FadeIn", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

function E:FadeOut(object, outDelay, outDuration, minAlpha, maxAlpha, shouldReset)
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	if widgets[object] then
		removeActiveWidget(object, widgets[object])

		object:DisableFading(true)
	end

	local tbl = widgets[object] and widgets or miscWidgets

	if not tbl[object] then
		tbl[object] = {
			config = {},
		}
	end

	tbl[object].config.in_duration = 0.15
	tbl[object].config.min_alpha = minAlpha or 0
	tbl[object].config.max_alpha = maxAlpha or 1
	tbl[object].config.out_delay = outDelay or 0
	tbl[object].config.out_duration = outDuration or 0.15

	if shouldReset then
		tbl[object].callback = resetCallback
	end

	addActiveWidget(object, tbl[object], FADE_OUT)

	if Profiler:IsLogging() then
		Profiler:Log("E", "FadeOut", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end
