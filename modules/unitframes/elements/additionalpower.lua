local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)
local m_abs = _G.math.abs

-- Mine
local diffThreshold = 0.1

local function AttachGainToVerticalBar(parent, prev, max)
	local offset = parent:GetHeight() * (1 - E:Clamp(prev / max))

	parent.Gain:SetPoint("BOTTOMLEFT", parent, "TOPLEFT", 0, -offset)
	parent.Gain:SetPoint("BOTTOMRIGHT", parent, "TOPRIGHT", 0, -offset)
end

local function AttachLossToVerticalBar(parent, prev, max)
	local offset = parent:GetHeight() * (1 - E:Clamp(prev / max))

	parent.Loss:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -offset)
	parent.Loss:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, -offset)
end

local function AttachGainToHorizontalBar(parent, prev, max)
	local offset = parent:GetWidth() * (1 - E:Clamp(prev / max))

	parent.Gain:SetPoint("TOPLEFT", parent, "TOPRIGHT", -offset, 0)
	parent.Gain:SetPoint("BOTTOMLEFT", parent, "BOTTOMRIGHT", -offset, 0)
end

local function AttachLossToHorizontalBar(parent, prev, max)
	local offset = parent:GetWidth() * (1 - E:Clamp(prev / max))

	parent.Loss:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -offset, 0)
	parent.Loss:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -offset, 0)
end

local function PostUpdate(bar, _, cur, max)
	if bar:IsShown() then
		if max ~= 0 then
			local prev = bar._prev or 0
			local diff = cur - prev

			if m_abs(diff) / max < diffThreshold then
				diff = 0
			end

			if diff > 0 then
				if bar.Gain:GetAlpha() == 0 then
					bar.Gain:SetAlpha(1)

					if bar:GetOrientation() == "VERTICAL" then
						AttachGainToVerticalBar(bar, prev, max)
					else
						AttachGainToHorizontalBar(bar, prev, max)
					end

					bar.Gain.FadeOut:Play()
				end
			elseif diff < 0 then
				bar.Gain.FadeOut:Stop()
				bar.Gain:SetAlpha(0)

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

		bar._prev = cur
	end
end

function UF:CreateAdditionalPower(parent)
	local element = _G.CreateFrame("StatusBar", "$parentAdditionalPowerBar", parent)
	element:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
	E:SmoothBar(element)

	local gainTexture = element:CreateTexture(nil, "ARTWORK", nil, 1)
	gainTexture:SetColorTexture(M.COLORS.LIGHT_GREEN:GetRGB())
	gainTexture:SetAlpha(0)
	element.Gain = gainTexture

	local lossTexture = element:CreateTexture(nil, "BACKGROUND")
	lossTexture:SetColorTexture(M.COLORS.DARK_RED:GetRGB())
	lossTexture:SetAlpha(0)
	element.Loss = lossTexture

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

	element.colorPower = true
	element.PostUpdate = PostUpdate

	return element
end

function UF:UpdateAdditionalPower(frame)
	local config = frame._config.add_power
	local element = frame.AdditionalPower

	element:SetOrientation(config.orientation)

	if config.orientation == "HORIZONTAL" then
		element.Gain:SetPoint("TOPRIGHT", element:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
		element.Gain:SetPoint("BOTTOMRIGHT", element:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)

		element.Loss:SetPoint("TOPLEFT", element:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
		element.Loss:SetPoint("BOTTOMLEFT", element:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)
	else
		element.Gain:SetPoint("TOPLEFT", element:GetStatusBarTexture(), "TOPLEFT", 0, 0)
		element.Gain:SetPoint("TOPRIGHT", element:GetStatusBarTexture(), "TOPRIGHT", 0, 0)

		element.Loss:SetPoint("BOTTOMLEFT", element:GetStatusBarTexture(), "TOPLEFT", 0, 0)
		element.Loss:SetPoint("BOTTOMRIGHT", element:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
	end

	if config.enabled and not frame:IsElementEnabled("AdditionalPower") then
		frame:EnableElement("AdditionalPower")
	elseif not config.enabled and frame:IsElementEnabled("AdditionalPower") then
		frame:DisableElement("AdditionalPower")
	end

	if frame:IsElementEnabled("AdditionalPower") then
		element:ForceUpdate()
	end
end
