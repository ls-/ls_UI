local _, ns = ...
local E = ns.E

local function SetAnimationGroup(object, type)
	if type == "FadeIn" then
		object[type] = object:CreateAnimationGroup()
		object[type]:SetToFinalAlpha(true)

		local anim = object[type]:CreateAnimation("Alpha")
		anim:SetOrder(1)
		anim:SetDuration(0.001)
		anim:SetFromAlpha(1)
		anim:SetToAlpha(0)

		anim = object[type]:CreateAnimation("Alpha")
		anim:SetOrder(2)
		anim:SetDuration(0.05)
		anim:SetFromAlpha(0)
		anim:SetToAlpha(1)

		object[type].anim = anim
	elseif type == "FadeOut" then
		object[type] = object:CreateAnimationGroup()
		object[type]:SetToFinalAlpha(true)

		local anim = object[type]:CreateAnimation("Alpha")
		anim:SetOrder(1)
		anim:SetDuration(0.05)
		anim:SetFromAlpha(1)
		anim:SetToAlpha(0)

		object[type].anim = anim
	elseif type == "Blink" then
		object[type] = object:CreateAnimationGroup()
		object[type]:SetLooping("BOUNCE")

		local anim = object[type]:CreateAnimation("Alpha")
		anim:SetDuration(1)
		anim:SetFromAlpha(1)
		anim:SetToAlpha(0)

		object[type].anim = anim
	end
end

function E:FadeIn(object, duration, toAlpha)
	if not object.FadeIn then
		SetAnimationGroup(object, "FadeIn")
	end

	if not object.FadeIn:IsPlaying() then
		if duration then object.FadeIn.anim:SetDuration(duration) end
		if toAlpha then object.FadeIn.anim:SetToAlpha(toAlpha) end

		object.FadeIn:Play()
	end
end

function E:StopFadeIn(object)
	if object.FadeIn then
		object.FadeIn:Stop()
	end
end

function E:FadeOut(object, duration, toAlpha)
	if not object.FadeOut then
		SetAnimationGroup(object, "FadeOut")
	end

	if not object.FadeOut:IsPlaying() then
		if duration then object.FadeOut.anim:SetDuration(duration) end
		if toAlpha then object.FadeOut.anim:SetToAlpha(toAlpha) end

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
