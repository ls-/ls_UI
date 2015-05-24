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

function ns.lsAlwaysShow(self)
	if not self then return end
	self:Show()
	self.Hide = self.Show
end

function ns.lsAlwaysHide(self)
	if not self then return end
	self:Hide()
	self.Show = self.Hide
end

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

do
	oUF.colors.health = ns.M.colors.health

	for r, data in pairs(ns.M.colors.reaction) do
		oUF.colors.reaction[r] = data
	end

	for p, data in pairs(ns.M.colors.power) do
		oUF.colors.power[p] = data
	end
end
