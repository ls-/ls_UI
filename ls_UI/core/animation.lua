local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF, Profiler = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF, ns.Profiler

local animGroups = {}

local function SetAnimationGroup(object, type)
	if not animGroups[object] then
		animGroups[object] = {}
	end

	local animGroup = animGroups[object]

	if type == "Blink" then
		animGroup[type] = object:CreateAnimationGroup()
		animGroup[type]:SetLooping("BOUNCE")

		local anim = animGroup[type]:CreateAnimation("Alpha")
		anim:SetDuration(1)
		anim:SetFromAlpha(1)
		anim:SetToAlpha(0)
		animGroup[type].Anim = anim
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
