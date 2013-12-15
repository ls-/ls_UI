local __, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "oUF FloatingCombatFeedback was unable to locate oUF install")

local colors = {
	DEFAULT  = {1, 1, 1},
	IMMUNE	 = {1, 1, 1},
	WOUND	 = {0.7, 0.1, 0.1},
	HEAL	 = {0.1, 0.8, 0.1},
	BLOCK	 = {1, 1, 1},
	ABSORB	 = {1, 1, 1},
	RESIST	 = {1, 1, 1},
	MISS 	 = {1, 1, 1},
	ENERGIZE = {0.11, 0.75, 0.95},
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
	local x = self.startX - self.__direction * (65 * (1 - cos(90 * self.scrollTime / self.__time)))
	local y = 5 + 65 * sin(90 * self.scrollTime / self.__time)
	return x, y
end

local function StandardScroll(self)
	local x = self.startX
	local y = 5 + self.endY * self.scrollTime / self.__time
	return x, y
end

local function SetScrolling(self, elapsed)
	local alpha, x, y, shown
	for index, string in pairs(self.FeedbackToAnimate) do
		if string.scrollTime >= self.__time then
			RemoveString(self, index, string)
		else
			string.scrollTime = string.scrollTime + elapsed
			x, y = self.scrollFunction(string)
			string.y = y
			string:SetPoint("TOP", self, "BOTTOM", x, y)
			if ( string.scrollTime >= self.__fadeout) then
				alpha = 1 - ((string.scrollTime - self.__fadeout) / (self.__time - self.__fadeout))
				alpha = math.max(alpha, 0)
				string:SetAlpha(alpha)
			end
		end
	end
	if #self.FeedbackToAnimate == 0 then
		self:SetScript("OnUpdate", nil)
	end
end

local function Update(self, event, unit, eventType, flags, amount)
	if(self.unit ~= unit) then return end
	local combatText = self.FloatingCombatFeedback
	if not combatText:GetScript("OnUpdate") then
		combatText:SetScript("OnUpdate", SetScrolling)
	end
	local r, g, b, text, multiplier
	if event == "IMMUNE" and not combatText.hideImmune then
		text = IMMUNE
		r, g, b = unpack(combatText.colors and combatText.colors.IMMUNE or colors.IMMUNE)
	elseif eventType == "WOUND" and not combatText.hideDamage then
		if amount ~= 0	then
			text = "-"..amount
			r, g, b = unpack(combatText.colors and combatText.colors.WOUND or colors.WOUND)
			if flags == "CRITICAL" then
				r, g, b = r * 0.75, g * 0.75, b * 0.75
				multiplier = 1.25
			elseif flags == "CRUSHING" then
				multiplier = 1.25
			end
		elseif flags == "ABSORB" then
			text = ABSORB
			r, g, b = unpack(combatText.colors and combatText.colors.ABSORB or colors.ABSORB)
		elseif flags == "BLOCK" then
			text = BLOCK
			r, g, b = unpack(combatText.colors and combatText.colors.BLOCK or colors.BLOCK)
		elseif flags == "RESIST" then
			text = RESIST
			r, g, b = unpack(combatText.colors and combatText.colors.RESIST or colors.RESIST)
		else
			text = MISS
			r, g, b = unpack(combatText.colors and combatText.colors.MISS or colors.MISS)
		end
	elseif eventType == "HEAL" and not combatText.hideHeal then
		text = "+"..amount
		r, g, b = unpack(combatText.colors and combatText.colors.HEAL or colors.HEAL)
		if flags == "CRITICAL" then
			r, g, b = r * 0.75, g * 0.75, b * 0.75
			multiplier = 1.25
		end
	elseif eventType == "BLOCK" and not combatText.hideBlock then
		text = BLOCK
		r, g, b = unpack(combatText.colors and combatText.colors.BLOCK or colors.BLOCK)
	elseif eventType == "ENERGIZE" and not combatText.hideEnergize then
		text = "+"..amount
		r, g, b = unpack(combatText.colors and combatText.colors.ENERGIZE or colors.ENERGIZE)
		if flags == "CRITICAL" then
			multiplier = 1.25
		end
	elseif not combatText.hideMisc then
		text = _G[eventType]
		r, g, b = unpack(combatText.colors and combatText.colors.DEFAULT or colors.DEFAULT)
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
		string.scrollTime = 0
		string.__direction = combatText.__direction
		string.__time = combatText.__time
		string.startX = combatText.__offset * combatText.__direction
		string.endY = combatText:GetHeight()
		string:SetPoint("TOP", combatText, "BOTTOM", string.startX, 5)
		string:SetAlpha(1)
		string:Show()
		tinsert(combatText.FeedbackToAnimate, string)
		combatText.__direction = combatText.__direction * -1
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
	combatText.__owner = self
	combatText.__max = #combatText
	combatText.__time = (combatText.scrollTime or 1.5)
	combatText.__fadeout = combatText.__time / 3
	combatText.__direction = 1
	combatText.FeedbackToAnimate = {}
	combatText.__fontHeight = 18
	if combatText.Mode == "Fountain" then
		combatText.scrollFunction = FountainScroll
		combatText.__offset = combatText.Offset or -6
	else
		combatText.scrollFunction = StandardScroll
		combatText.__offset = combatText.Offset or -30
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