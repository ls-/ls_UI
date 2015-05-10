local _, ns = ...
local E, M = ns.E, ns.M

local function SetAnimationGroup(object, type, ...)
	if type == "FadeIn" then
		object[type] = object:CreateAnimationGroup()
		object[type]:SetToFinalAlpha(true)

		local anim1 = object[type]:CreateAnimation("ALPHA")
		anim1:SetOrder(1)
		anim1:SetDuration(0)
		anim1:SetChange(-1)

		local anim2 = object[type]:CreateAnimation("ALPHA")
		anim2:SetOrder(2)
		anim2:SetDuration(0.15)
		anim2:SetChange(1)

		object[type].anim = anim2
	elseif type == "FadeOut" then
		object[type] = object:CreateAnimationGroup()
		object[type]:SetToFinalAlpha(true)

		local anim1 = object[type]:CreateAnimation("ALPHA")
		anim1:SetOrder(1)
		anim1:SetDuration(0.15)
		anim1:SetChange(-1)

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

function E:FadeOut(object, duration, change)
	if not object.FadeOut then
		SetAnimationGroup(object, "FadeOut")
	end

	if not object.FadeOut:IsPlaying() then
		if duration then object.FadeOut.anim1:SetDuration(duration) end
		if change then object.FadeOut.anim1:SetChange(change) end

		object.FadeOut:Play()
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
