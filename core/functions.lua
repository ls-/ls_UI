local _, ns = ...
local E, M, oUF = ns.E, ns.M, ns.oUF or oUF

-----------
-- DEBUG --
-----------

function ns.DebugTexture(self)
	if self:IsObjectType("Texture") then
		self.tex = self:GetParent():CreateTexture(nil, "BACKGROUND",nil,-8)
	else
		self.tex = self:CreateTexture(nil, "BACKGROUND",nil,-8)
	end
	self.tex:SetAllPoints(self)
	self.tex:SetTexture(1, 0, 0.5, 0.4)
end

-----------
-- UTILS --
-----------

function ns.lsSetHighlightTexture(texture)
	texture:SetTexture(ns.M.textures.button.highlight)
	texture:SetTexCoord(0.234375, 0.765625, 0.234375, 0.765625)
	texture:SetAllPoints()
end

function ns.lsSetPushedTexture(texture)
	texture:SetTexture(ns.M.textures.button.pushed)
	texture:SetTexCoord(0.234375, 0.765625, 0.234375, 0.765625)
	texture:SetAllPoints()
end

function ns.lsSetCheckedTexture(texture)
	texture:SetTexture(ns.M.textures.button.checked)
	texture:SetTexCoord(0.234375, 0.765625, 0.234375, 0.765625)
	texture:SetAllPoints()
end
