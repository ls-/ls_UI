local _, ns = ...
local E, C, M, oUF = ns.E, ns.C, ns.M, ns.oUF
local UF = E:AddModule("UnitFrames")

UF.framesByUnit = {
	player = {},
	pet = {},
	target = {},
	targettarget = {},
	focus = {},
	focustarget = {},
	party = {},
	boss = {},
	arena = {},
}

local objects, headers = {}, {}

local function LSUnitFrame_OnEnter(self)
	if self.__owner then
		self = self.__owner
	end

	UnitFrame_OnEnter(self)

	local name = gsub(self:GetName(), "%d", "")

	if name == "LSPartyFrameUnitButton" then
		PartyMemberBuffTooltip:ClearAllPoints()
		PartyMemberBuffTooltip:SetPoint("TOPLEFT", self, "BOTTOMRIGHT", -10, 10)
		PartyMemberBuffTooltip_Update(self)
	elseif name == "LSPetFrame" then
		PartyMemberBuffTooltip:ClearAllPoints()
		PartyMemberBuffTooltip:SetPoint("BOTTOMRIGHT", self, "TOPLEFT", 4, -4)
		PartyMemberBuffTooltip_Update(self)
	end

	self.isMouseOver = true
	if self.mouseovers then
		for _, element in next, self.mouseovers do
			if element.ForceUpdate then
				element:ForceUpdate()

				if element:IsObjectType("Texture") then
					element:Show()
				end
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

	if name == "LSPartyFrameUnitButton" then
		PartyMemberBuffTooltip:Hide()
	elseif name == "LSPetFrame" then
		PartyMemberBuffTooltip:Hide()
	end

	self.isMouseOver = nil
	if self.mouseovers then
		for _, element in next, self.mouseovers do
			if element.ForceUpdate then
				element:ForceUpdate()

				if element:IsObjectType("Texture") then
					element:Hide()
				end
			else
				element:Hide()
			end
		end
	end
end

local function UnitFrameConstructor(frame, unit)
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
	elseif unit == "boss1" then
		UF:ConstructBossFrame(frame)
	elseif unit == "boss2" then
		UF:ConstructBossFrame(frame)
	elseif unit == "boss3" then
		UF:ConstructBossFrame(frame)
	elseif unit == "boss4" then
		UF:ConstructBossFrame(frame)
	elseif unit == "boss5" then
		UF:ConstructBossFrame(frame)
	elseif unit == "party" then
		UF:ConstructPartyFrame(frame)
	elseif unit == "arena1" then
		UF:ConstructArenaFrame(frame)
	elseif unit == "arena2" then
		UF:ConstructArenaFrame(frame)
	elseif unit == "arena3" then
		UF:ConstructArenaFrame(frame)
	elseif unit == "arena4" then
		UF:ConstructArenaFrame(frame)
	elseif unit == "arena5" then
		UF:ConstructArenaFrame(frame)
	end
end

local function MainConstructor()
	oUF:RegisterStyle("LSv2", UnitFrameConstructor)
	oUF:SetActiveStyle("LSv2")

	if C.units.player.enabled then
		objects["player"] = oUF:Spawn("player", "LSPlayerFrame")
		objects["pet"] = oUF:Spawn("pet", "LSPetFrame")
	end

	if C.units.target.enabled then
		objects["target"] = oUF:Spawn("target", "LSTargetFrame")
		objects["targettarget"] = oUF:Spawn("targettarget", "LSTargetTargetFrame")
	end

	if C.units.focus.enabled then
		objects["focus"] = oUF:Spawn("focus", "LSFocusFrame")
		objects["focustarget"] = oUF:Spawn("focustarget", "LSFocusTargetFrame")
	end

	if C.units.boss.enabled then
		objects["boss1"] = oUF:Spawn("boss1", "LSBoss1Frame")
		objects["boss2"] = oUF:Spawn("boss2", "LSBoss2Frame")
		objects["boss3"] = oUF:Spawn("boss3", "LSBoss3Frame")
		objects["boss4"] = oUF:Spawn("boss4", "LSBoss4Frame")
		objects["boss5"] = oUF:Spawn("boss5", "LSBoss5Frame")
	end

	local ArenaPrepFrames
	if C.units.arena.enabled then
		objects["arena1"] = oUF:Spawn("arena1", "LSArena1Frame")
		objects["arena2"] = oUF:Spawn("arena2", "LSArena2Frame")
		objects["arena3"] = oUF:Spawn("arena3", "LSArena3Frame")
		objects["arena4"] = oUF:Spawn("arena4", "LSArena4Frame")
		objects["arena5"] = oUF:Spawn("arena5", "LSArena5Frame")

		ArenaPrepFrames = UF:SetupArenaPrepFrames()
	end

	for unit, object in next, objects do
		if strmatch(unit, "^boss%d") then
			local id = tonumber(strmatch(unit, "boss(%d)"))
			if id == 1 then
				UF:CreateBossHolder()

				object:SetPoint("TOPRIGHT", "LSBossHolder", "TOPRIGHT", 0, -16)
			else
				object:SetPoint("TOP", "LSBoss"..(id - 1).."Frame", "BOTTOM", 0, -36)
			end
		 elseif strmatch(unit, "^arena%d") then
			local id = tonumber(strmatch(unit, "arena(%d)"))
			if id == 1 then
				UF:CreateArenaHolder()

				object:SetPoint("TOPRIGHT", "LSArenaHolder", "TOPRIGHT", -(2 + 28 + 6 + 28 + 2), -16)
			else
				object:SetPoint("TOP", "LSArena"..(id - 1).."Frame", "BOTTOM", 0, -14)
			end
		else
			object:SetPoint(unpack(C.units[unit].point))
			E:CreateMover(object)
		end
	end

	if ArenaPrepFrames then
		ArenaPrepFrames:SetPoint("TOPLEFT", "LSArenaHolder", "TOPLEFT", 0, 0)

		for i = 1, 5 do
			if i == 1 then
				ArenaPrepFrames[i]:SetPoint("TOPLEFT", ArenaPrepFrames.Label, "BOTTOMLEFT", 0, -4)
			else
				ArenaPrepFrames[i]:SetPoint("LEFT", ArenaPrepFrames[i - 1], "RIGHT", 4, 0)
			end
		end
	end

	if C.units.party.enabled then
		headers["party"] = oUF:SpawnHeader("LSPartyFrame", nil,
			"custom [nogroup][group:party,@party1,noexists][group:raid,@raid1,exists]hide;show",
			"oUF-initialConfigFunction", [[self:SetWidth(110); self:SetHeight(36)]],
			"showPlayer", true,
			"showParty", true,
			"groupBy", "ROLE",
			"groupingOrder", "TANK,HEALER,DAMAGER",
			"point", "TOP", "yOffset", -40)

		UF:CreatePartyHolder()

		headers["party"]:SetParent(LSPartyHolder)
		headers["party"]:SetPoint("TOPLEFT", "LSPartyHolder", "TOPLEFT", 0, -16)
	end
end

function UF:Initialize(forceInit)
	if C.units.enabled or forceInit then
		oUF:Factory(MainConstructor)
	end
end
