local _, ns = ...
local E = ns.E

local animGroups = {}

local function SetAnimationGroup(object, type)
	if not animGroups[object] then
		animGroups[object] = {}
	end

	local animGroup = animGroups[object]

	if type == "FadeIn" then
		animGroup[type] = object:CreateAnimationGroup()
		animGroup[type]:SetToFinalAlpha(true)

		local anim = animGroup[type]:CreateAnimation("Alpha")
		anim:SetOrder(1)
		anim:SetDuration(0.001)
		anim:SetToAlpha(0)

		anim = animGroup[type]:CreateAnimation("Alpha")
		anim:SetOrder(2)
		anim:SetDuration(0.1)
		anim:SetFromAlpha(0)
		anim:SetToAlpha(1)
		animGroup[type].Anim = anim
	elseif type == "FadeOut" then
		animGroup[type] = object:CreateAnimationGroup()
		animGroup[type]:SetToFinalAlpha(true)

		local anim = animGroup[type]:CreateAnimation("Alpha")
		anim:SetOrder(1)
		anim:SetDuration(0.05)
		anim:SetFromAlpha(1)
		anim:SetToAlpha(0)
		animGroup[type].Anim = anim
	elseif type == "Blink" then
		animGroup[type] = object:CreateAnimationGroup()
		animGroup[type]:SetLooping("BOUNCE")

		local anim = animGroup[type]:CreateAnimation("Alpha")
		anim:SetDuration(1)
		anim:SetFromAlpha(1)
		anim:SetToAlpha(0)
		animGroup[type].Anim = anim
	end
end

function E:FadeIn(object, duration, toAlpha)
	if not (animGroups[object] and animGroups[object].FadeIn) then
		SetAnimationGroup(object, "FadeIn")
	end

	local ag = animGroups[object].FadeIn

	if not ag:IsPlaying() then
		if duration then ag.Anim:SetDuration(duration) end
		if toAlpha then ag.Anim:SetToAlpha(toAlpha) end

		ag:Play()
	end
end

function E:StopFadeIn(object)
	if animGroups[object] and animGroups[object].FadeIn then
		animGroups[object].FadeIn:Stop()
	end
end

function E:FadeOut(object, duration, toAlpha)
	if not (animGroups[object] and animGroups[object].FadeOut) then
		SetAnimationGroup(object, "FadeOut")
	end

	local ag = animGroups[object].FadeOut

	if not ag:IsPlaying() then
		if duration then ag.Anim:SetDuration(duration) end
		if toAlpha then ag.Anim:SetToAlpha(toAlpha) end

		ag:Play()
	end
end

function E:StopFadeOut(object)
	if animGroups[object] and animGroups[object].FadeOut then
		animGroups[object].FadeOut:Stop()
	end
end

function E:Blink(object, duration, fromAlpha, toAlpha)
	if not (animGroups[object] and animGroups[object].Blink) then
		SetAnimationGroup(object, "Blink")
	end

	local ag = animGroups[object].Blink

	if not ag:IsPlaying() then
		if duration then ag.Anim:SetDuration(duration) end
		if fromAlpha then ag.Anim:SetFromAlpha(fromAlpha) end
		if toAlpha then ag.Anim:SetToAlpha(toAlpha) end

		ag:Play()
	end
end

function E:StopBlink(object, force)
	if animGroups[object] and animGroups[object].Blink then
		if force then
			animGroups[object].Blink:Stop()
		else
			animGroups[object].Blink:Finish()
		end
	end
end
