local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local UF = E:GetModule("UnitFrames")

local _G = _G

local function Update(self, event)
	local status = _G.UnitThreatSituation("player")
	local color = status and M.colors.threat[status] or M.colors.class[E.PLAYER_CLASS]

	self.Spin1:SetVertexColor(color[1], color[2], color[3])
	self.Spin2:SetVertexColor(color[1], color[2], color[3])
end

function UF:CreateStatusHighlight(parent)
	local color = M.colors.class[E.PLAYER_CLASS]

	local spin1 = parent:CreateTexture(nil, "BACKGROUND", nil, -1)
	spin1:SetBlendMode("ADD")
	spin1:SetTexture("Interface\\AddOns\\oUF_LS\\media\\minimap")
	spin1:SetTexCoord(1 / 512, 169 / 512, 204 / 512, 372 / 512)
	spin1:SetVertexColor(color[1], color[2], color[3])
	spin1:SetSize(168, 168)
	spin1:SetPoint("CENTER", 0, 0)
	parent.Spin1 = spin1

	local spin2 = parent:CreateTexture(nil, "BACKGROUND", nil, -2)
	spin2:SetBlendMode("ADD")
	spin2:SetTexture("Interface\\AddOns\\oUF_LS\\media\\minimap")
	spin2:SetVertexColor(color[1], color[2], color[3])
	spin2:SetTexCoord(169 / 512, 1 / 512, 204 / 512, 372 / 512)
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
