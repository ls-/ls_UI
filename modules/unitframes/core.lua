local _, ns = ...
local E, C, M = ns.E, ns.C, ns.M
local oUF = ns.oUF

E.UF = {}

local UF = E.UF

UF.objects, UF.headers = {}, {}

local function LSUnitFrame_OnEnter(self)
	if self.__owner then
		self = self.__owner
	end

	UnitFrame_OnEnter(self)

	local name = gsub(self:GetName(), "%d", "")
	-- if frameName == "lsPartyFrameUnitButton" then
	-- 	PartyMemberBuffTooltip:ClearAllPoints()
	-- 	PartyMemberBuffTooltip:SetPoint("TOPLEFT", self, "BOTTOMRIGHT", -10, 10)
	-- 	PartyMemberBuffTooltip_Update(self)
	if name == "LSPetFrame" then
		PartyMemberBuffTooltip:ClearAllPoints()
		PartyMemberBuffTooltip:SetPoint("BOTTOMRIGHT", self, "TOPLEFT", 4, -4)
		PartyMemberBuffTooltip_Update(self)
	end

	self.isMouseOver = true
	if self.mouseovers then
		for _, element in ipairs(self.mouseovers) do
			if element.ForceUpdate then
				element:ForceUpdate()
			else
				element:Show()
			end
		end
	end
end

local function LSUnitFrame_OnLeave(self)
	if self.__owner then
		self = self.__owner
	end

	UnitFrame_OnLeave(self)

	local name = gsub(self:GetName(), "%d", "")
	-- if name == "lsPartyFrameUnitButton" then
	-- 	PartyMemberBuffTooltip:Hide()
	if name == "LSPetFrame" then
		PartyMemberBuffTooltip:Hide()
	end

	self.isMouseOver = nil
	if self.mouseovers then
		for _, element in ipairs(self.mouseovers) do
			if element.ForceUpdate then
				element:ForceUpdate()
			else
				element:Hide()
			end
		end
	end
end

local function ConstructUnitFrame(frame, unit)
	frame:RegisterForClicks("AnyUp")
	frame:SetScript("OnEnter", LSUnitFrame_OnEnter)
	frame:SetScript("OnLeave", LSUnitFrame_OnLeave)

	if unit == "player" then
		UF:ConstructPlayerFrame(frame)
	elseif unit == "pet" then
		UF:ConstructPetFrame(frame)
	end
end

function UF:Initialize()
	-- self is oUF
	self:RegisterStyle("LSv2", ConstructUnitFrame)
	self:SetActiveStyle("LSv2")

	if ns.C.units.player.enabled then
		UF.objects["player"] = self:Spawn("player", "LSPlayerFrame")
		UF.objects["pet"] = self:Spawn("pet", "LSPetFrame")
	end

	for unit, object in next, UF.objects do
		object:SetPoint(unpack(C.units[unit].point))

		E:CreateMover(object)
	end
end
