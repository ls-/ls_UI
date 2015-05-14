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
	elseif unit == "target" then
		UF:ConstructTargetFrame(frame)
	elseif unit == "targettarget" then
		UF:ConstructTargetTargetFrame(frame)
	elseif unit == "focus" then
		UF:ConstructFocusFrame(frame)
	elseif unit == "focustarget" then
		UF:ConstructFocusTargetFrame(frame)
	elseif unit == "party" then
		UF:ConstructPartyFrame(frame)
	elseif unit == "boss1" then
		UF:CreateBossHeader()
		UF:ConstructBossFrame(frame)
	elseif unit == "boss2" then
		UF:ConstructBossFrame(frame)
	elseif unit == "boss3" then
		UF:ConstructBossFrame(frame)
	elseif unit == "boss4" then
		UF:ConstructBossFrame(frame)
	elseif unit == "boss5" then
		UF:ConstructBossFrame(frame)
	end
end

function UF:Initialize()
	-- self is oUF
	self:RegisterStyle("LSv2", ConstructUnitFrame)
	self:SetActiveStyle("LSv2")

	UF.objects["player"] = self:Spawn("player", "LSPlayerFrame")
	UF.objects["pet"] = self:Spawn("pet", "LSPetFrame")
	UF.objects["target"] = self:Spawn("target", "LSTargetFrame")
	UF.objects["targettarget"] = self:Spawn("targettarget", "LSTargetTargetFrame")
	UF.objects["focus"] = self:Spawn("focus", "LSFocusFrame")
	UF.objects["focustarget"] = self:Spawn("focustarget", "LSFocusTargetFrame")
	UF.objects["boss1"] = self:Spawn("boss1", "LSBoss1Frame")
	UF.objects["boss2"] = self:Spawn("boss2", "LSBoss2Frame")
	UF.objects["boss3"] = self:Spawn("boss3", "LSBoss3Frame")
	UF.objects["boss4"] = self:Spawn("boss4", "LSBoss4Frame")
	UF.objects["boss5"] = self:Spawn("boss5", "LSBoss5Frame")
	UF.objects["party"] = self:SpawnHeader("party", nil, C.units["party"].visibility, unpack(C.units["party"].attributes))

	for unit, object in next, UF.objects do
		if strmatch(unit, "^boss%d") then
			local id = tonumber(strmatch(unit, "boss(%d)"))
			if id == 1 then
				object:SetPoint("TOP", "LSBossHeader", "TOP", 0, - 16)
			else
				object:SetPoint("TOP", "LSBoss"..(id - 1).."Frame", "BOTTOM", 0, -C.units.boss.yOffset)
			end
		else
			object:SetPoint(unpack(C.units[unit].point))

			E:CreateMover(object)
		end
	end
end
