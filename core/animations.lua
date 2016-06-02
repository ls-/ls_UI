local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L

local function SetAnimationGroup(object, type, ...)
	if type == "FadeIn" then
		object[type] = object:CreateAnimationGroup()
		object[type]:SetToFinalAlpha(true)

		local anim = object[type]:CreateAnimation("ALPHA")
		anim:SetOrder(1)
		anim:SetDuration(0)
		anim:SetFromAlpha(1)
		anim:SetToAlpha(0)

		anim = object[type]:CreateAnimation("ALPHA")
		anim:SetOrder(2)
		anim:SetDuration(0.075)
		anim:SetFromAlpha(0)
		anim:SetToAlpha(1)

		object[type].anim = anim
	elseif type == "FadeOut" then
		object[type] = object:CreateAnimationGroup()
		object[type]:SetToFinalAlpha(true)

		local anim1 = object[type]:CreateAnimation("ALPHA")
		anim1:SetOrder(1)
		anim1:SetDuration(0.05)
		anim1:SetFromAlpha(1)
		anim1:SetToAlpha(0)

		object[type].anim = anim1
	elseif type == "Blink" then
		object[type] = object:CreateAnimationGroup()
		object[type]:SetLooping("BOUNCE")

		local anim1 = object[type]:CreateAnimation("ALPHA")
		anim1:SetDuration(1)
		anim1:SetFromAlpha(1)
		anim1:SetToAlpha(0)

		object[type].anim = anim1
	end
end

function E:FadeIn(object, duration, change)
	if not object.FadeIn then
		SetAnimationGroup(object, "FadeIn")
	end

	if not object.FadeIn:IsPlaying() then
		if duration then object.FadeIn.anim:SetDuration(duration) end
		if change then object.FadeIn.anim:SetChange(change) end

		object.FadeIn:Play()
	end
end

function E:StopFadeIn(object)
	if object.FadeIn then
		object.FadeIn:Stop()
	end
end

function E:FadeOut(object, duration, change)
	if not object.FadeOut then
		SetAnimationGroup(object, "FadeOut")
	end

	if not object.FadeOut:IsPlaying() then
		if duration then object.FadeOut.anim:SetDuration(duration) end
		if change then object.FadeOut.anim:SetChange(change) end

		object.FadeOut:Play()
	end
end

function E:StopFadeOut(object)
	if object.FadeOut then
		object.FadeOut:Stop()
	end
end

function E:Blink(object, duration, fromAlpha, toAlpha)
	if not object.Blink then
		SetAnimationGroup(object, "Blink")
	end

	if not object.Blink:IsPlaying() then
		if duration then object.Blink.anim:SetDuration(duration) end
		if fromAlpha then object.Blink.anim:SetFromAlpha(fromAlpha) end
		if toAlpha then object.Blink.anim:SetToAlpha(toAlpha) end

		object.Blink:Play()
	end
end

function E:StopBlink(object, force)
	if object.Blink then
		if force then object.Blink:Stop() else object.Blink:Finish() end
	end
end
