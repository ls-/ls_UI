local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)
local next = _G.next

-- Mine
local FADE_IN = 1
local FADE_OUT = -1

local widgets = {}
local miscWidgets = {}

local activeWidgets = {}

local function addActiveWidget(object, widget, mode)
	widget.mode = mode
	widget.fadeTimer = 0
	widget.initAlpha = nil
	activeWidgets[object] = widget
end

local function removeActiveWidget(object, widget, atMinAlpha, atMaxAlpha)
	widget.mode = nil
	widget.atMaxAlpha = atMaxAlpha
	widget.atMinAlpha = atMinAlpha
	widget.isFading = nil
	activeWidgets[object] = nil
end

local targetWidgets = {}

local function addTargetWidget(object, widget)
	widget.hasTarget = UnitExists("target") or UnitExists("focus")
	targetWidgets[object] = widget
end

local function removeTargetWidget(object, widget)
	widget.hasTarget = false
	targetWidgets[object] = nil
end

local combatWidgets = {}

local function addCombatWidget(object, widget)
	widget.hasTarget = InCombatLockdown()
	combatWidgets[object] = widget
end

local function removeCombatWidget(object, widget)
	widget.hasTarget = false
	combatWidgets[object] = nil
end

local updater = CreateFrame("Frame")

updater:SetScript("OnUpdate", function(_, elapsed)
	for object, widget in next, activeWidgets do
		widget.fadeTimer = widget.fadeTimer + elapsed
		widget.initAlpha = widget.initAlpha or object:GetAlpha()

		if widget.mode == FADE_IN then
			widget.isFading = true

			-- add 0.0001 to avoid any "divide by 0" errors in case a user sets both min and max
			-- alphas to the same value, I could add a bunch of checks for it to never happen,
			-- but precision isn't really necessary here
			widget.newAlpha = widget.initAlpha + ((widget.config.max_alpha - widget.initAlpha)
				* (widget.fadeTimer / (widget.config.in_duration
					* (1 - (widget.initAlpha - widget.config.min_alpha)
						/ (widget.config.max_alpha - widget.config.min_alpha + 0.0001)))))
			-- print("|cff00ffd2IN|r", "|cff00ccff" .. object:GetDebugName() .. "|r", "  \n|cffffd200 initAlpha:|r ", widget.initAlpha, "  \n|cffffd200 newAlpha:|r ", widget.newAlpha, "  \n|cffffd200 delta:|r ", widget.newAlpha - object:GetAlpha())
			object:SetAlpha(widget.newAlpha)

			if widget.newAlpha >= widget.config.max_alpha then
				removeActiveWidget(object, widget, nil, true)

				if widget.callback then
					widget.callback(object)
					widget.callback = nil
				end

				object:SetAlpha(widget.config.max_alpha)
			end
		elseif widget.mode == FADE_OUT then
			if widget.fadeTimer >= widget.config.out_delay then
				widget.isFading = true

				-- add 0.0001 to avoid any "divide by 0" errors in case a user sets both min and max
				-- alphas to the same value, I could add a bunch of checks for it to never happen,
				-- but precision isn't really necessary here
				widget.newAlpha = widget.initAlpha - ((widget.initAlpha - widget.config.min_alpha)
					* ((widget.fadeTimer - widget.config.out_delay) / (widget.config.out_duration
						* (1 - (widget.config.max_alpha - widget.initAlpha)
							/ (widget.config.max_alpha - widget.config.min_alpha + 0.0001)))))
				-- print("|cffffd200OUT|r", "|cff00ccff" .. object:GetDebugName() .. "|r", "  \n|cffffd200 initAlpha:|r ", widget.initAlpha, "  \n|cffffd200 newAlpha:|r ", widget.newAlpha, "  \n|cffffd200delta:|r ", object:GetAlpha() - widget.newAlpha)
				object:SetAlpha(widget.newAlpha)

				if widget.newAlpha <= widget.config.min_alpha then
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
end)

updater:SetScript("OnEvent", function(self, event)
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
	end
end)

-- combat widgets
updater:RegisterEvent("PLAYER_REGEN_ENABLED")
updater:RegisterEvent("PLAYER_REGEN_DISABLED")

-- target widgets
updater:RegisterEvent("PLAYER_TARGET_CHANGED")
updater:RegisterEvent("PLAYER_FOCUS_CHANGED")

local function isMouseOver(frame)
	return frame:IsMouseOver(4, -4, -4, 4)
		or (SpellFlyout:IsShown() and SpellFlyout:GetParent() and SpellFlyout:GetParent():GetParent() == frame and SpellFlyout:IsMouseOver(4, -4, -4, 4))
end

local hoverUpdater = CreateFrame("Frame")

hoverUpdater:SetScript("OnUpdate", function(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > elapsed * 1.5 then -- run it at half the refresh rate
		for object, widget in next, widgets do
			if object:IsShown() and widget.canHover then
				if isMouseOver(object) then
					if (not widget.atMaxAlpha or widget.isFading) and widget.mode ~= FADE_IN then
						addActiveWidget(object, widget, FADE_IN)
					end
				elseif not widget.atMinAlpha and widget.mode ~= FADE_OUT then
					addActiveWidget(object, widget, FADE_OUT)
				end
			end
		end

		self.elapsed = 0
	end
end)

local object_proto = {}

function object_proto:DisableFading(ignoreFade)
	local widget = widgets[self]

	if widget.canHover then
		widget.canHover = false

		if not ignoreFade and (widget.atMinAlpha or widget.mode ~= FADE_IN) then
			addActiveWidget(self, widget, FADE_IN)
		end
	end
end

function object_proto:EnableFading()
	local widget = widgets[self]

	if not (widget.hasTarget or widget.inCombat) then
		widget.canHover = true
	end
end

function object_proto:UpdateFading()
	local widget = widgets[self]

	widget.config = E:CopyTable(self._config.fade, widget.config)

	removeActiveWidget(self, widget)
	removeTargetWidget(self, widget)
	removeCombatWidget(self, widget)

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

		self:EnableFading()
	end
end

function E:SetUpFading(object)
	if widgets[object] then
		return
	end

	local fader = CreateFrame("Frame", "$parentFader", object)
	fader:SetFrameLevel(object:GetFrameLevel())
	fader:SetPoint("TOPLEFT", -4, 4)
	fader:SetPoint("BOTTOMRIGHT", 4, -4)
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

local function resetCallback(object)
	object:UpdateFading()
end

function E:FadeIn(object, inDuration, minAlpha, maxAlpha, shouldReset)
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
end

function E:FadeOut(object, outDelay, outDuration, minAlpha, maxAlpha, shouldReset)
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
end
