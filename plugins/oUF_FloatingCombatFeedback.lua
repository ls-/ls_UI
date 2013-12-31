local __, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "oUF FloatingCombatFeedback was unable to locate oUF install")

local colors = {
	["DEFAULT"] = {1, 1, 1},
	["INTERRUPT"] = {1, 1, 1},
	["MISS"] = {1, 1, 1},
	["RESIST"] = {1, 1, 1},
	["DODGE"] = {1, 1, 1},
	["PARRY"] = {1, 1, 1},
	["BLOCK"] = {1, 1, 1},
	["EVADE"] = {1, 1, 1},
	["IMMUNE"] = {1, 1, 1},
	["DEFLECT"] = {1, 1, 1},
	["ABSORB"] = {1, 1, 1},
	["REFLECT"] = {1, 1, 1},
	["WOUND"] = {0.7, 0.1, 0.1},
	["HEAL"] = {0.1, 0.8, 0.1},
	["ENERGIZE"] = {0.11, 0.75, 0.95},
}

local function RemoveString(self, i, string)
	tremove(self.FeedbackToAnimate, i)
	string:SetAlpha(0)
	string:Hide()
end

local function GetAvailableString(self)
	local NoStringAvailable = true
	for i = 1, self.__max do
		if not self[i]:IsShown() then
			NoStringAvailable = false
			return self[i]
		end
	end
	if NoStringAvailable == true then
		RemoveString(self, 1, self.FeedbackToAnimate[1])
	end
	return nil, 1
end

local function FountainScroll(self)
	local x = self.__x + self.__side * (65 * (1 - cos(90 * self.__scrollTime / self.__time)))
	local y = 8 + 65 * sin(90 * self.__scrollTime / self.__time)
	return x, y
end

local function StandardScroll(self)
	local x = self.__x
	local y = 8 + 65 * sin(90 * self.__scrollTime / self.__time)
	return x, y
end

local function SetScrolling(self, elapsed)
	local alpha, x, y, shown
	for index, string in pairs(self.FeedbackToAnimate) do
		if string.__scrollTime >= self.__time then
			RemoveString(self, index, string)
		else
			string.__scrollTime = string.__scrollTime + elapsed
			x, y = self.scrollFunction(string)
			string:SetPoint("BOTTOM", self:GetParent(), "CENTER", x, y)
			if ( string.__scrollTime >= self.__fadeout) then
				alpha = 1 - ((string.__scrollTime - self.__fadeout) / (self.__time - self.__fadeout))
				alpha = math.max(alpha, 0)
				string:SetAlpha(alpha)
			end
		end
	end
	if #self.FeedbackToAnimate == 0 then
		self:SetScript("OnUpdate", nil)
	end
end

local function Update(self, ...)
	local _, unit, event, flags, amount = ...

	if(self.unit ~= unit) then return end

	local combatText = self.FloatingCombatFeedback

	if not combatText:GetScript("OnUpdate") then
		combatText:SetScript("OnUpdate", SetScrolling)
	end

	local r, g, b, text, multiplier
	if event == "IMMUNE" and not combatText.ignoreImmune then
		text = IMMUNE
		r, g, b = unpack(combatText.colors and combatText.colors[event] or colors[event])
	elseif event == "WOUND" and not combatText.ignoreDamage then
		if amount ~= 0	then
			text = "-"..amount
			r, g, b = unpack(combatText.colors and combatText.colors[event] or colors[event])
			if flags == "CRITICAL" then
				r, g, b = r * 0.75, g * 0.75, b * 0.75
				multiplier = 1.25
			elseif flags == "CRUSHING" then
				multiplier = 1.25
			end
		elseif flags == "ABSORB" then
			text = ABSORB
			r, g, b = unpack(combatText.colors and combatText.colors[flags] or colors[flags])
		elseif flags == "BLOCK" then
			text = BLOCK
			r, g, b = unpack(combatText.colors and combatText.colors[flags] or colors[flags])
		elseif flags == "RESIST" then
			text = RESIST
			r, g, b = unpack(combatText.colors and combatText.colors[flags] or colors[flags])
		else
			text = MISS
			r, g, b = unpack(combatText.colors and combatText.colors["MISS"] or colors["MISS"])
		end
	elseif event == "HEAL" and not combatText.ignoreHeal then
		text = "+"..amount
		r, g, b = unpack(combatText.colors and combatText.colors[event] or colors[event])
		if flags == "CRITICAL" then
			r, g, b = r * 0.75, g * 0.75, b * 0.75
			multiplier = 1.25
		end
	elseif event == "BLOCK" and not combatText.ignoreDamage then
		text = BLOCK
		r, g, b = unpack(combatText.colors and combatText.colors[event] or colors[event])
	elseif event == "ENERGIZE" and not combatText.ignoreEnergize then
		text = "+"..amount
		r, g, b = uunpack(combatText.colors and combatText.colors[event] or colors[event])
		if flags == "CRITICAL" then
			multiplier = 1.25
		end
	elseif not combatText.ignoreMisc then
		text = _G[event]
		r, g, b = unpack(combatText.colors and combatText.colors[event] or colors[event and event or "DEFAULT"])
	end

	if text then
		local string, NoneIsAvailable = GetAvailableString(combatText)

		if NoneIsAvailable then return end

		local font, _, outline = string:GetFont()
		if font then
			string:SetFont(font, combatText.__fontHeight * (multiplier or 1), outline)
		end

		string:SetText(text)
		string:SetTextColor(r, g, b)
		string.__scrollTime = 0
		string.__side = combatText.__side
		string.__time = combatText.__time
		string.__x = combatText.__offset * combatText.__side
		string:SetPoint("BOTTOM", self, "CENTER", string.__x, 8)
		string:SetAlpha(1)
		string:Show()

		tinsert(combatText.FeedbackToAnimate, string)
		combatText.__side = combatText.__side * -1
	end
end

local function Path(self, ...)
	return (self.FloatingCombatFeedback.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self, unit)
	local combatText = self.FloatingCombatFeedback

	if not combatText then return end

	combatText:SetScript("OnShow", function(self) 
		for index, string in pairs(self.FeedbackToAnimate) do
			RemoveString(self, index, string)
		end
	end)

	combatText.__owner = self
	combatText.__max = #combatText
	combatText.__time = (combatText.ScrollTime or 1.5)
	combatText.__fadeout = combatText.__time / 3
	combatText.__side = 1
	combatText.__fontHeight = select(2, combatText[1]:GetFont())
	combatText.FeedbackToAnimate = {}

	if combatText.Mode == "Fountain" then
		combatText.scrollFunction = FountainScroll
		combatText.__offset = combatText.Offset or 6
	else
		combatText.scrollFunction = StandardScroll
		combatText.__offset = combatText.Offset or 30
	end

	for i = 1, combatText.__max do
		combatText[i]:Hide()
	end

	combatText.ForceUpdate = ForceUpdate
	self:RegisterEvent("UNIT_COMBAT", Path)

	return true
end

local function Disable(self)
	local combatText = self.FloatingCombatFeedback

	if combatText then
		self:UnregisterEvent("UNIT_COMBAT", Path)
	end
end

oUF:AddElement("FloatingCombatFeedback", Path, Enable, Disable)