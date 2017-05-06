local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

-- Blizz
local UnitIsConnected = _G.UnitIsConnected
local UnitIsDeadOrGhost = _G.UnitIsDeadOrGhost
local DEAD = _G.DEAD
local PLAYER_OFFLINE = _G.PLAYER_OFFLINE

-- Mine
do
	local function PostUpdate(element, unit, cur, max)
		if not UnitIsConnected(unit) then
			element:SetValue(0)

			return element.Text and element.Text:SetText(PLAYER_OFFLINE)
		elseif UnitIsDeadOrGhost(unit) then
			element:SetValue(0)

			return element.Text and element.Text:SetText(DEAD)
		end

		if not element.Text then
			return
		end

		if element.__owner.isMouseOver then
			if unit == "target" or unit == "focus" then
				return element.Text:SetFormattedText(L["BAR_VALUE_PERC_TEMPLATE"], E:NumberFormat(cur, 1), E:NumberToPerc(cur, max))
			elseif unit:match("(boss)%d+") then
				return element.Text:SetFormattedText(L["BAR_VALUE_TEMPLATE"], E:NumberFormat(cur, 1))
			end
		else
			if cur == max then
				if unit == "player" or unit == "vehicle" or unit == "pet" then
					return element.Text:SetText(nil)
				end
			else
				if unit == "target" or unit == "focus" then
					return element.Text:SetFormattedText(L["BAR_VALUE_PERC_TEMPLATE"], E:NumberFormat(cur, 1), E:NumberToPerc(cur, max))
				elseif unit:match("(boss)%d+") then
					return element.Text:SetFormattedText(L["BAR_PERC_TEMPLATE"], E:NumberToPerc(cur, max))
				end
			end
		end

		element.Text:SetFormattedText(L["BAR_VALUE_TEMPLATE"], E:NumberFormat(cur, 1))
	end

	function UF:CreateHealth(parent, text, textFontObject, textParent)
		local element = _G.CreateFrame("StatusBar", "$parentHealthBar", parent)
		element:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		E:SmoothBar(element)

		if text then
			text = (textParent or element):CreateFontString(nil, "ARTWORK", textFontObject)
			text:SetWordWrap(false)
			E:ResetFontStringHeight(text)
			element.Text = text
		end

		element.colorHealth = true
		element.colorTapping = true
		element.colorDisconnected = true
		element.PostUpdate = PostUpdate

		return element
	end

	function UF:UpdateHealth(frame)
		local config = frame._config.health
		local element = frame.Health

		element:SetOrientation(config.orientation)

		if config.color then
			element.colorClass = config.color.class
			element.colorReaction = config.color.reaction
		end

		if element.Text then
			element.Text:SetJustifyV(config.text.v_alignment or "MIDDLE")
			element.Text:SetJustifyH(config.text.h_alignment or "CENTER")
			element.Text:ClearAllPoints()

			local point1 = config.text.point1

			if point1 and point1.p then
				element.Text:SetPoint(point1.p, E:ResolveAnchorPoint(frame, point1.anchor), point1.rP, point1.x, point1.y)
			end
		end

		frame._mouseovers[element] = config.update_on_mouseover and true or nil

		if element.ForceUpdate then
			element:ForceUpdate()
		end
	end
end

do
	local function UpdateBar(self, width, height, value, orientation, appendTexture)
		if orientation == "HORIZONTAL" then
			self:SetWidth(width)
			self:SetPoint("LEFT", appendTexture, "RIGHT")
		else
			self:SetHeight(height)
			self:SetPoint("BOTTOM", appendTexture, "TOP")
		end

		if self.Overlay then
			self.Overlay:SetShown(value ~= 0)
		end

		return self:GetStatusBarTexture()
	end

	local function PostUpdate(self, _, myIncomingHeal, otherIncomingHeal, absorb)
		local appendTexture = self.__owner.Health:GetStatusBarTexture()
		local orientation = self.__owner.Health:GetOrientation()
		local width, height = self.__owner.Health:GetSize()

		if self.myBar and myIncomingHeal > 0 then
			appendTexture = UpdateBar(self.myBar, width, height, myIncomingHeal, orientation, appendTexture)
		end

		if self.otherBar and otherIncomingHeal > 0 then
			appendTexture = UpdateBar(self.otherBar, width, height, otherIncomingHeal, orientation, appendTexture)
		end

		if self.absorbBar then
			UpdateBar(self.absorbBar, width, height, absorb, orientation, appendTexture)
		end
	end

	function UF:CreateHealthPrediction(parent)
		local level = parent:GetFrameLevel()

		local myBar = _G.CreateFrame("StatusBar", "$parentMyIncomingHeal", parent)
		myBar:SetFrameLevel(level)
		myBar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		myBar:SetStatusBarColor(M.COLORS.HEALPREDICTION.MY_HEAL:GetRGB())
		E:SmoothBar(myBar)

		local otherBar = _G.CreateFrame("StatusBar", "$parentOtherIncomingHeal", parent)
		otherBar:SetFrameLevel(level)
		otherBar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		otherBar:SetStatusBarColor(M.COLORS.HEALPREDICTION.OTHER_HEAL:GetRGB())
		E:SmoothBar(otherBar)

		local absorbBar = _G.CreateFrame("StatusBar", "$parentTotalAbsorb", parent)
		absorbBar:SetFrameLevel(level + 1)
		absorbBar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")

		absorbBar.Overlay = absorbBar:CreateTexture(nil, "ARTWORK", "TotalAbsorbBarOverlayTemplate", 1)
		absorbBar.Overlay:SetAllPoints(absorbBar:GetStatusBarTexture())

		local healAbsorbBar = _G.CreateFrame("StatusBar", "$parentHealAbsorb", parent)
		healAbsorbBar:SetReverseFill(true)
		healAbsorbBar:SetFrameLevel(level + 1)
		healAbsorbBar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		healAbsorbBar:SetStatusBarColor(M.COLORS.HEALPREDICTION.HEAL_ABSORB:GetRGB())
		E:SmoothBar(healAbsorbBar)

		return {
			myBar = myBar,
			otherBar = otherBar,
			healAbsorbBar = healAbsorbBar,
			absorbBar = absorbBar,
			maxOverflow = 1,
			frequentUpdates = true,
			PostUpdate = PostUpdate
		}
	end

	function UF:UpdateHealthPrediction(frame)
		local config = frame._config.health
		local element = frame.HealthPrediction
		local myBar = element.myBar
		local otherBar = element.otherBar
		local absorbBar = element.absorbBar
		local healAbsorbBar = element.healAbsorbBar

		myBar:SetOrientation(config.orientation)
		otherBar:SetOrientation(config.orientation)
		absorbBar:SetOrientation(config.orientation)
		healAbsorbBar:SetOrientation(config.orientation)

		if config.orientation == "HORIZONTAL" then
			myBar:ClearAllPoints()
			myBar:SetPoint("TOP")
			myBar:SetPoint("BOTTOM")

			otherBar:ClearAllPoints()
			otherBar:SetPoint("TOP")
			otherBar:SetPoint("BOTTOM")

			absorbBar:ClearAllPoints()
			absorbBar:SetPoint("TOP")
			absorbBar:SetPoint("BOTTOM")

			healAbsorbBar:ClearAllPoints()
			healAbsorbBar:SetPoint("TOP")
			healAbsorbBar:SetPoint("BOTTOM")
			healAbsorbBar:SetPoint("RIGHT", frame.Health:GetStatusBarTexture(), "RIGHT")
		else
			myBar:ClearAllPoints()
			myBar:SetPoint("LEFT")
			myBar:SetPoint("RIGHT")

			otherBar:ClearAllPoints()
			otherBar:SetPoint("LEFT")
			otherBar:SetPoint("RIGHT")

			absorbBar:ClearAllPoints()
			absorbBar:SetPoint("LEFT")
			absorbBar:SetPoint("RIGHT")

			healAbsorbBar:ClearAllPoints()
			healAbsorbBar:SetPoint("LEFT")
			healAbsorbBar:SetPoint("RIGHT")
			healAbsorbBar:SetPoint("TOP", frame.Health:GetStatusBarTexture(), "TOP")
		end

		if config.prediction.enabled and not frame:IsElementEnabled("HealthPrediction") then
			frame:EnableElement("HealthPrediction")
		elseif not config.prediction.enabled and frame:IsElementEnabled("HealthPrediction") then
			frame:DisableElement("HealthPrediction")
		end

		if frame:IsElementEnabled("HealthPrediction") then
			element:ForceUpdate()
		end
	end
end
