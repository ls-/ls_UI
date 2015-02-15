local _, ns = ...
local E, M = ns.E, ns.M

local COLORS = ns.M.colors

E.OT = {}

local OT = E.OT

local function OTButton_OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > 0.2 then
		local bIcon = self.icon

		if bIcon then
			local valid = IsQuestLogSpecialItemInRange(self:GetID())

			if not valid or valid == 0 then
				bIcon:SetVertexColor(unpack(COLORS.icon.oor))
			else
				bIcon:SetVertexColor(1, 1, 1, 1)
			end
		end

		self.elapsed = 0
	end
end

function OT:Initialize()
	hooksecurefunc("QuestObjectiveItem_OnShow", E.SkinOTButton)
	hooksecurefunc("QuestObjectiveItem_OnUpdate", OTButton_OnUpdate)
end
