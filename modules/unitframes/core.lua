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
			end
		end
	end

	local first = true
	if self.rearrangeables then
		local prev
		for _, element in next, self.rearrangeables do
			if element:GetAlpha() == 1 then
				element:ClearAllPoints()

				if first then
					first = nil

					element:SetPoint("TOPLEFT", 4, 0)
				else
					element:SetPoint("LEFT", prev, "RIGHT", 2, 0)
				end

				prev = element
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

function UF:Initialize()
	self:RegisterStyle("LSv2", ConstructUnitFrame)
	self:SetActiveStyle("LSv2")

	if C.units.player.enabled then
		UF.objects["player"] = self:Spawn("player", "LSPlayerFrame")
		UF.objects["pet"] = self:Spawn("pet", "LSPetFrame")
	end

	if C.units.target.enabled then
		UF.objects["target"] = self:Spawn("target", "LSTargetFrame")
		UF.objects["targettarget"] = self:Spawn("targettarget", "LSTargetTargetFrame")
	end

	if C.units.focus.enabled then
		UF.objects["focus"] = self:Spawn("focus", "LSFocusFrame")
		UF.objects["focustarget"] = self:Spawn("focustarget", "LSFocusTargetFrame")
	end

	if C.units.boss.enabled then
		UF.objects["boss1"] = self:Spawn("boss1", "LSBoss1Frame")
		UF.objects["boss2"] = self:Spawn("boss2", "LSBoss2Frame")
		UF.objects["boss3"] = self:Spawn("boss3", "LSBoss3Frame")
		UF.objects["boss4"] = self:Spawn("boss4", "LSBoss4Frame")
		UF.objects["boss5"] = self:Spawn("boss5", "LSBoss5Frame")
	end

	if C.units.arena.enabled then
		if not IsAddOnLoaded("Blizzard_ArenaUI") then
			E:ForceLoadAddOn("Blizzard_ArenaUI")
		end

		UF.objects["arena1"] = self:Spawn("arena1", "LSArena1Frame")
		UF.objects["arena2"] = self:Spawn("arena2", "LSArena2Frame")
		UF.objects["arena3"] = self:Spawn("arena3", "LSArena3Frame")
		UF.objects["arena4"] = self:Spawn("arena4", "LSArena4Frame")
		UF.objects["arena5"] = self:Spawn("arena5", "LSArena5Frame")
	end

	for unit, object in next, UF.objects do
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
				object:SetPoint("TOP", "LSArena"..(id - 1).."Frame", "BOTTOM", 0, -12)
			end
		else
			object:SetPoint(unpack(C.units[unit].point))

			E:CreateMover(object)
		end
	end

	if C.units.party.enabled then
		if not IsAddOnLoaded("Blizzard_CompactRaidFrames") then
			E:ForceLoadAddOn("Blizzard_CompactRaidFrames")
		end

		UF.headers["party"] = self:SpawnHeader("LSPartyFrame", nil,
			"custom [nogroup][group:party,@party1,noexists][group:raid,@raid6,exists]hide;show",
			"oUF-initialConfigFunction", [[self:SetWidth(112); self:SetHeight(38)]],
			"showPlayer", true,
			"showParty", true,
			"groupBy", "ROLE",
			"groupingOrder", "TANK,HEALER,DAMAGER",
			"point", "TOP", "yOffset", -40)

		UF:CreatePartyHolder()

		UF.headers["party"]:SetParent(LSPartyHolder)
		UF.headers["party"]:SetPoint("TOPLEFT", "LSPartyHolder", "TOPLEFT", 0, - 16)
	end
end
