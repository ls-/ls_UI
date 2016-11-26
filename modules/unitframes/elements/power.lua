local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = _G
local math = _G.math

-- Blizz
local UnitGUID = _G.UnitGUID
local UnitIsConnected = _G.UnitIsConnected
local UnitIsDeadOrGhost = _G.UnitIsDeadOrGhost

-- Mine
local diffThreshold = 0.1

local function AttachGainToVerticalBar(parent, prev, max)
	local d = prev / max

	if d > 1 then
		d = 1
	elseif d < 0 then
		d = 0
	end

	local offset = parent:GetHeight() * (1 - d)
	parent.Gain:SetPoint("BOTTOMLEFT", parent, "TOPLEFT", 0, -offset)
	parent.Gain:SetPoint("BOTTOMRIGHT", parent, "TOPRIGHT", 0, -offset)
end

local function AttachLossToVerticalBar(parent, prev, max)
	local d = prev / max

	if d > 1 then
		d = 1
	elseif d < 0 then
		d = 0
	end

	local offset = parent:GetHeight() * (1 - d)
	parent.Loss:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -offset)
	parent.Loss:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, -offset)
end

local function AttachGainToHorizontalBar(parent, prev, max)
	local d = prev / max

	if d > 1 then
		d = 1
	elseif d < 0 then
		d = 0
	end

	local offset = parent:GetWidth() * (1 - d)
	parent.Gain:SetPoint("TOPLEFT", parent, "TOPRIGHT", -offset, 0)
	parent.Gain:SetPoint("BOTTOMLEFT", parent, "BOTTOMRIGHT", -offset, 0)
end

local function AttachLossToHorizontalBar(parent, prev, max)
	local d = prev / max

	if d > 1 then
		d = 1
	elseif d < 0 then
		d = 0
	end

	local offset = parent:GetWidth() * (1 - d)
	parent.Loss:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -offset, 0)
	parent.Loss:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -offset, 0)
end

-- Mine
local function PostUpdatePower(bar, unit, cur, max)
	if bar.Tube then
		if max == 0 then
			for i = 0, #bar.Tube do
				bar.Tube[i]:Hide()
			end
		else
			for i = 0, #bar.Tube do
				bar.Tube[i]:Show()
			end
		end
	end

	if bar.Gain or bar.Loss then
		local unitGUID = UnitGUID(unit)

		if max ~= 0 and unitGUID == bar.lastUnitGUID then
			local prev = bar.prev or 0
			local diff = cur - prev

			if math.abs(diff) / max < diffThreshold then
				diff = 0
			end

			if diff > 0 and bar.Gain then
				if bar.Gain:GetAlpha() == 0 then
					bar.Gain:SetAlpha(1)

					if bar:GetOrientation() == "VERTICAL" then
						AttachGainToVerticalBar(bar, prev, max)
					else
						AttachGainToHorizontalBar(bar, prev, max)
					end

					bar.Gain.FadeOut:Play()
				end
			elseif diff < 0 and bar.Loss then
				if bar.Gain then
					bar.Gain.FadeOut:Stop()
					bar.Gain:SetAlpha(0)
				end

				if bar.Loss:GetAlpha() == 0 then
					bar.Loss:SetAlpha(1)

					if bar:GetOrientation() == "VERTICAL" then
						AttachLossToVerticalBar(bar, prev, max)
					else
						AttachLossToHorizontalBar(bar, prev, max)
					end

					bar.Loss.FadeOut:Play()
				end
			end
		else
			bar.Gain.FadeOut:Stop()
			bar.Gain:SetAlpha(0)

			bar.Loss.FadeOut:Stop()
			bar.Loss:SetAlpha(0)
		end

		bar.prev = cur
		bar.lastUnitGUID = unitGUID
	end

	if not bar.Text then return end

	if max == 0 then
		return bar.Text:SetText(nil)
	elseif UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
		bar:SetValue(0)

		return bar.Text:SetText(nil)
	end

	local color = E:RGBToHEX(bar:GetStatusBarColor())

	if bar.__owner.isMouseOver then
		if unit ~= "player" and unit ~= "vehicle" and unit ~= "pet" then
			return bar.Text:SetFormattedText("%s / |cff%s%s|r", E:NumberFormat(cur, 1), color, E:NumberFormat(max, 1))
		end
	else
		if cur == max or cur == 0 then
			if unit == "player" or unit == "vehicle" or unit == "pet" then
				return bar.Text:SetText(nil)
			end
		end
	end

	bar.Text:SetFormattedText("|cff%s%s|r", color, E:NumberFormat(cur, 1))
end

function UF:CreatePowerBar(parent, textSize, textBg, isVertical)
	local power = _G.CreateFrame("StatusBar", "$parentPowerBar", parent)
	power:SetOrientation(isVertical and "VERTICAL" or "HORIZONTAL")
	power:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
	E:SmoothBar(power)

	local text = E:CreateFontString(power, textSize, "$parentPowerValue", true)
	power.Text = text

	if textBg then
		local shadow = power:CreateTexture(nil, "ARTWORK", nil, 7)
		shadow:SetTexture("Interface\\Scenarios\\Objective-Lineglow")
		shadow:SetTexCoord(0, 1, 0, 13 / 16)
		shadow:SetVertexColor(M.COLORS.BLACK:GetRGB())
		shadow:SetPoint("TOPLEFT", text, "TOPLEFT", 0, -2)
		shadow:SetPoint("BOTTOMRIGHT", text, "BOTTOMRIGHT", 0, 2)
	end

	local gainTexture = power:CreateTexture(nil, "ARTWORK", nil, 1)
	gainTexture:SetPoint("TOPRIGHT", power:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
	gainTexture:SetPoint("BOTTOMRIGHT", power:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)
	gainTexture:SetColorTexture(M.COLORS.LIGHT_GREEN:GetRGB())
	gainTexture:SetAlpha(0)
	power.Gain = gainTexture

	local lossTexture = power:CreateTexture(nil, "BACKGROUND")
	lossTexture:SetPoint("TOPLEFT", power:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
	lossTexture:SetPoint("BOTTOMLEFT", power:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)
	lossTexture:SetColorTexture(M.COLORS.DARK_RED:GetRGB())
	lossTexture:SetAlpha(0)
	power.Loss = lossTexture

	local ag = gainTexture:CreateAnimationGroup()
	ag:SetToFinalAlpha(true)
	gainTexture.FadeOut = ag

	local anim1 = ag:CreateAnimation("Alpha")
	anim1:SetOrder(1)
	anim1:SetFromAlpha(1)
	anim1:SetToAlpha(0)
	anim1:SetStartDelay(0.6)
	anim1:SetDuration(0.2)

	ag = lossTexture:CreateAnimationGroup()
	ag:SetToFinalAlpha(true)
	lossTexture.FadeOut = ag

	anim1 = ag:CreateAnimation("Alpha")
	anim1:SetOrder(1)
	anim1:SetFromAlpha(1)
	anim1:SetToAlpha(0)
	anim1:SetStartDelay(0.6)
	anim1:SetDuration(0.2)

	if isVertical then
		gainTexture:SetPoint("TOPLEFT", power:GetStatusBarTexture(), "TOPLEFT", 0, 0)
		gainTexture:SetPoint("TOPRIGHT", power:GetStatusBarTexture(), "TOPRIGHT", 0, 0)

		lossTexture:SetPoint("BOTTOMLEFT", power:GetStatusBarTexture(), "TOPLEFT", 0, 0)
		lossTexture:SetPoint("BOTTOMRIGHT", power:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
	else
		gainTexture:SetPoint("TOPRIGHT", power:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
		gainTexture:SetPoint("BOTTOMRIGHT", power:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)

		lossTexture:SetPoint("TOPLEFT", power:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
		lossTexture:SetPoint("BOTTOMLEFT", power:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)
	end

	power.colorPower = true
	power.colorDisconnected = true
	power.frequentUpdates = true
	power.PostUpdate = PostUpdatePower

	return power
end
