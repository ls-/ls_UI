local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local UF = E:GetModule("UnitFrames")

function UF:CreateDebuffHighlight(parent, texture, l, r, t, b)
	local debuff = parent:CreateTexture("$parentDebuffGlow", "BACKGROUND", nil, 1)
	debuff:SetTexture(texture)
	debuff:SetTexCoord(l, r, t, b)
	debuff:SetAlpha(0)
	debuff.Alpha = 1
	debuff.Filter = true

	return debuff
end
