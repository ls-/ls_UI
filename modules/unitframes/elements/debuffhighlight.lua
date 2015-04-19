local _, ns = ...
local E, C, M = ns.E, ns.C, ns.M

local UF = E.UF

function UF:CreateDebuffHighlight(parent, texture)
	local debuff = parent:CreateTexture("$parentDebuffGlow", "BACKGROUND", nil, 1)
	debuff:SetTexture(texture)
	debuff:SetAlpha(0)
	debuff.Alpha = 1
	debuff.Filter = true

	return debuff
end
