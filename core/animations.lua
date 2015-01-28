local _, ns = ...
local E, M = ns.E, ns.M

local function SetAnimationGroup(object, type, ...)
	local duration, change = ...
	if type == "FadeIn" then
		object[type] = object:CreateAnimationGroup()
		object[type]:SetToFinalAlpha(true)

		local anim1 = object[type]:CreateAnimation("ALPHA")
		anim1:SetOrder(1)
		anim1:SetDuration(0)
		anim1:SetChange(-1)

		local anim2 = object[type]:CreateAnimation("ALPHA")
		anim2:SetOrder(2)
		anim2:SetDuration(duration or 0.15)
		anim2:SetChange(change or 1)

	elseif type == "FadeOut" then
		object[type] = object:CreateAnimationGroup()
		object[type]:SetToFinalAlpha(true)

		local anim1 = object[type]:CreateAnimation("ALPHA")
		anim1:SetOrder(1)
		anim1:SetDuration(duration or 0.15)
		anim1:SetChange(-(change or 1))
		anim1:SetScript("OnFinished", function() object:Hide() end)
	end
end

function E:FadeIn(object, duration, change)
	if not object.FadeIn then
		SetAnimationGroup(object, "FadeIn", duration, change)
	end

	if duration then object.FadeIn.anim1:SetDuration(duration) end
	if changhe then object.FadeIn.anim1:SetChange(change) end

	object:Show()
	object.FadeIn:Play()
end

function E:FadeOut(object, duration, change)
	if not object.FadeOut then
		SetAnimationGroup(object, "FadeOut", duration, change)
	end

	if duration then object.FadeOut.anim1:SetDuration(duration) end
	if changhe then object.FadeOut.anim1:SetChange(change) end

	object.FadeOut:Play()
end
