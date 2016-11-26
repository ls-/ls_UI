local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = _G

-- Mine
local function Update(self)
	local status = _G.UnitThreatSituation("player")
	local r, g, b = M.COLORS.CLASS[E.PLAYER_CLASS]:GetRGB()

	if _G.UnitAffectingCombat("player") then
		r, g, b = M.COLORS.THREAT[status and status + 1 or 1]:GetRGB()
	end

	self.Spin1:SetVertexColor(r, g, b)
	self.Spin2:SetVertexColor(r, g, b)
end

function UF:CreateStatusHighlight(parent)
	local r, g, b = M.COLORS.CLASS[E.PLAYER_CLASS]:GetRGB()

	local spin1 = parent:CreateTexture(nil, "BACKGROUND", nil, -1)
	spin1:SetTexture("Interface\\AddOns\\ls_UI\\media\\spinner-alt")
	spin1:SetTexCoord(1 / 256, 169 / 256, 1 / 256, 169 / 256)
	spin1:SetVertexColor(r, g, b)
	spin1:SetSize(172, 172)
	spin1:SetPoint("CENTER", 0, 0)
	parent.Spin1 = spin1

	local spin2 = parent:CreateTexture(nil, "BACKGROUND", nil, -2)
	spin2:SetBlendMode("ADD")
	spin2:SetTexture("Interface\\AddOns\\ls_UI\\media\\spinner")
	spin2:SetVertexColor(r, g, b)
	spin2:SetTexCoord(169 / 256, 1 / 256, 1 / 256, 169 / 256)
	spin2:SetSize(168, 168)
	spin2:SetPoint("CENTER", 0, 0)
	parent.Spin2 = spin2

	local ag = parent:CreateAnimationGroup()
	ag:SetLooping("REPEAT")

	local anim = ag:CreateAnimation("Rotation")
	anim:SetChildKey("Spin1")
	anim:SetOrder(1)
	anim:SetDuration(60)
	anim:SetDegrees(-360)

	anim = ag:CreateAnimation("Rotation")
	anim:SetChildKey("Spin2")
	anim:SetOrder(1)
	anim:SetDuration(60)
	anim:SetDegrees(720)

	parent:RegisterEvent("PLAYER_REGEN_ENABLED", Update)
	parent:RegisterEvent("PLAYER_REGEN_DISABLED", Update)
	parent:RegisterEvent("UNIT_THREAT_LIST_UPDATE", Update)
	parent:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", Update)

	ag:Play()
end
