local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)
local math = _G.math

-- Mine
local diffThreshold = 0.1

local function CalcMult(prev, max)
	local d = prev / max

	if d > 1 then
		d = 1
	elseif d < 0 then
		d = 0
	end

	return 1 - d
end

local function AttachGainToVerticalBar(parent, prev, max)
	local offset = parent:GetHeight() * CalcMult(prev, max)

	parent.Gain:SetPoint("BOTTOMLEFT", parent, "TOPLEFT", 0, -offset)
	parent.Gain:SetPoint("BOTTOMRIGHT", parent, "TOPRIGHT", 0, -offset)
end

local function AttachLossToVerticalBar(parent, prev, max)
	local offset = parent:GetHeight() * CalcMult(prev, max)

	parent.Loss:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -offset)
	parent.Loss:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, -offset)
end

local function AttachGainToHorizontalBar(parent, prev, max)
	local offset = parent:GetWidth() * CalcMult(prev, max)

	parent.Gain:SetPoint("TOPLEFT", parent, "TOPRIGHT", -offset, 0)
	parent.Gain:SetPoint("BOTTOMLEFT", parent, "BOTTOMRIGHT", -offset, 0)
end

local function AttachLossToHorizontalBar(parent, prev, max)
	local offset = parent:GetWidth() * CalcMult(prev, max)

	parent.Loss:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -offset, 0)
	parent.Loss:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -offset, 0)
end

local function PostUpdate(bar, _, cur, max)
	if bar:IsShown() then
		if max ~= 0 then
			local prev = bar.prev or 0
			local diff = cur - prev

			if math.abs(diff) / max < diffThreshold then
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

		bar.prev = cur
	end
end

function UF:CreateAdditionalPowerBar(parent, options)
	P.argcheck(1, parent, "table")

	options = options or {}

	local bar = _G.CreateFrame("StatusBar", "$parentAdditionalPowerBar", parent)
	bar:SetOrientation(options.is_vertical and "VERTICAL" or "HORIZONTAL")
	bar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
	E:SmoothBar(bar)
	bar:Hide()

	local gainTexture = bar:CreateTexture(nil, "ARTWORK", nil, 1)
	gainTexture:SetColorTexture(M.COLORS.LIGHT_GREEN:GetRGB())
	gainTexture:SetAlpha(0)
	bar.Gain = gainTexture

	local lossTexture = bar:CreateTexture(nil, "BACKGROUND")
	lossTexture:SetColorTexture(M.COLORS.DARK_RED:GetRGB())
	lossTexture:SetAlpha(0)
	bar.Loss = lossTexture

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

	if options.is_vertical then
		gainTexture:SetPoint("TOPLEFT", bar:GetStatusBarTexture(), "TOPLEFT", 0, 0)
		gainTexture:SetPoint("TOPRIGHT", bar:GetStatusBarTexture(), "TOPRIGHT", 0, 0)

		lossTexture:SetPoint("BOTTOMLEFT", bar:GetStatusBarTexture(), "TOPLEFT", 0, 0)
		lossTexture:SetPoint("BOTTOMRIGHT", bar:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
	else
		gainTexture:SetPoint("TOPRIGHT", bar:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
		gainTexture:SetPoint("BOTTOMRIGHT", bar:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)

		lossTexture:SetPoint("TOPLEFT", bar:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
		lossTexture:SetPoint("BOTTOMLEFT", bar:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)
	end

	bar.colorPower = true
	bar.PostUpdate = PostUpdate

	return bar
end
