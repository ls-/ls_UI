local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF
local MODULE = P:AddModule("Tooltips")

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local m_floor = _G.math.floor
local next = _G.next
local s_trim = _G.string.trim
local s_upper = _G.string.upper
local unpack = _G.unpack

-- Mine
local isInit = false

local AFK = "[" .. _G.AFK .. "] "
local DND = "[" .. _G.DND .. "] "
local EXPANSION = "|cffffd100" .. _G.EXPANSION_FILTER_TEXT .. _G.HEADER_COLON .. "|r %s"
local GUILD_TEMPLATE = _G.GUILD_TEMPLATE
local ID = "|cffffd100" .. _G.ID .. _G.HEADER_COLON .. "|r %d"
local NAME_FORMAT = "%s%s"
local LEVEL_FORMAT = "%s %s"
local ILVL_SPEC_FORMAT = "|cffffd100%s|r %s"
local PLAYER_TARGET_FORMAT = "%s (|c%s" .. _G.PLAYER .. "|r)"
local TARGET = "|cffffd100" .. _G.TARGET .. _G.HEADER_COLON .. "|r %s"
local TOTAL = "|cffffd100" .. _G.TOTAL .. _G.HEADER_COLON .. "|r %d"
local TOTAL_DETAILED = TOTAL .. " |cff888987(%d + %d)|r"

local PHASE_ICONS = {
	[Enum.PhaseReason.Phasing] = M.textures.icons_inline.PHASE,
	[Enum.PhaseReason.Sharding] = M.textures.icons_inline.SHARD,
	[Enum.PhaseReason.WarMode] = M.textures.icons_inline.WM,
	[Enum.PhaseReason.ChromieTime] = M.textures.icons_inline.CHROMIE,
}

local GOOD_TOOLTIPS = {
	[GameTooltip] = true,
	[GameTooltipTooltip] = true,
	[ItemRefTooltip] = true,
}

local inspectGUIDCache = {}
local lastGUID

local function INSPECT_READY(unitGUID)
	if UnitExists("mouseover") and UnitGUID("mouseover") == unitGUID then
		if not inspectGUIDCache[unitGUID] then
			inspectGUIDCache[unitGUID] = {}
		end

		inspectGUIDCache[unitGUID].time = GetTime()
		inspectGUIDCache[unitGUID].itemLevel = E:GetUnitAverageItemLevel("mouseover")

		if inspectGUIDCache[unitGUID].itemLevel then
			GameTooltip:RefreshData()
		else
			inspectGUIDCache[unitGUID].time = nil
			inspectGUIDCache[unitGUID].itemLevel = nil
		end
	end

	lastGUID = nil

	E:UnregisterEvent("INSPECT_READY", INSPECT_READY)
end

local function getInspectInfo(unit)
	if not CanInspect(unit, true) then return end

	local unitGUID = UnitGUID(unit)
	if unitGUID == E.PLAYER_GUID then
		return E:GetUnitAverageItemLevel(unit)
	elseif inspectGUIDCache[unitGUID] and inspectGUIDCache[unitGUID].time then
		if GetTime() - inspectGUIDCache[unitGUID].time > 120 then
			inspectGUIDCache[unitGUID].time = nil
			inspectGUIDCache[unitGUID].itemLevel = nil

			lastGUID = unitGUID

			NotifyInspect(unit)
			E:RegisterEvent("INSPECT_READY", INSPECT_READY)

			return
		end

		return inspectGUIDCache[unitGUID].itemLevel
	elseif lastGUID ~= unitGUID then
		lastGUID = unitGUID

		NotifyInspect(unit)
		E:RegisterEvent("INSPECT_READY", INSPECT_READY)
	end
end

local function findLine(tooltip, start, pattern)
	for i = start, tooltip:NumLines() do
		local text = _G["GameTooltipTextLeft" .. i]:GetText()
		if text and text:match(pattern) then
			return _G["GameTooltipTextLeft" .. i], i + 1
		end
	end
end

function MODULE:IsInit()
	return isInit
end

function MODULE:Init()
	if not isInit and PrC.db.profile.tooltips.enabled then
		TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, data)
			if not GOOD_TOOLTIPS[tooltip] or tooltip:IsForbidden() then return end
			if not C.db.profile.tooltips.id then return end

			local id = data.id
			if id then
				local textRight
				if C.db.profile.tooltips.count then
					local inBags = C_Item.GetItemCount(id)
					local total = C_Item.GetItemCount(id, true, false, true, true)
					local inBanks = total - inBags
					if inBanks > 0 then
						textRight = TOTAL_DETAILED:format(total, inBags, inBanks)
					else
						textRight = TOTAL:format(total)
					end
				end

				tooltip:AddLine(" ")
				tooltip:AddDoubleLine(ID:format(id), textRight or "", 1, 1, 1, 1, 1, 1)

				local _, _, _, _, _, _, _, _, _, _, _, _, _, _, expacID = C_Item.GetItemInfo(id)
				if expacID and expacID > 0 then
					tooltip:AddLine(EXPANSION:format(_G["EXPANSION_NAME" .. expacID]), 1, 1, 1)
				end
			end
		end)

		TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, function(tooltip, data)
			if not GOOD_TOOLTIPS[tooltip] or tooltip:IsForbidden() then return end
			if not C.db.profile.tooltips.id then return end

			local id = data.id
			if id then
				tooltip:AddLine(" ")
				tooltip:AddLine(ID:format(id), 1, 1, 1)
			end
		end)

		TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Currency, function(tooltip, data)
			if not GOOD_TOOLTIPS[tooltip] or tooltip:IsForbidden() then return end
			if not C.db.profile.tooltips.id then return end

			local id = data.id
			if id then
				tooltip:AddLine(ID:format(id), 1, 1, 1)
			end
		end)

		local auraGetterToAPI = {
			["GetUnitAura"] = function(...)
				local data = C_UnitAuras.GetAuraDataByIndex(unpack(...))
				if data then
					return data.sourceUnit
				end
			end,
			["GetUnitBuff"] = function(...)
				local data = C_UnitAuras.GetBuffDataByIndex(unpack(...))
				if data then
					return data.sourceUnit
				end
			end,
			["GetUnitBuffByAuraInstanceID"] = function(...)
				local data = C_UnitAuras.GetAuraDataByAuraInstanceID(unpack(...))
				if data then
					return data.sourceUnit
				end
			end,
			["GetUnitDebuff"] = function(...)
				local data = C_UnitAuras.GetDebuffDataByIndex(unpack(...))
				if data then
					return data.sourceUnit
				end
			end,
			["GetUnitDebuffByAuraInstanceID"] = function(...)
				local data = C_UnitAuras.GetAuraDataByAuraInstanceID(unpack(...))
				if data then
					return data.sourceUnit
				end
			end,
		}

		TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.UnitAura, function(tooltip, data)
			if not GOOD_TOOLTIPS[tooltip] or tooltip:IsForbidden() then return end
			if not C.db.profile.tooltips.id then return end

			local id = data.id
			if id then
				tooltip:AddLine(" ")

				local caster
				if auraGetterToAPI[tooltip.processingInfo.getterName] then
					caster = auraGetterToAPI[tooltip.processingInfo.getterName](tooltip.processingInfo.getterArgs)
				end

				if caster then
					tooltip:AddDoubleLine(ID:format(id), UnitName(caster), 1, 1, 1, E:GetUnitColor(caster, true, true):GetRGB())
				else
					tooltip:AddLine(ID:format(id), 1, 1, 1)
				end
			end
		end)

		TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Toy, function(tooltip, data)
			if tooltip ~= GameTooltip or tooltip:IsForbidden() then return end
			if not C.db.profile.tooltips.id then return end

			local id = data.id
			if id then
				local addBlankLine = true
				for i = 3, #data.lines do
					if data.lines[i].type == Enum.TooltipDataLineType.Blank then
						addBlankLine = false
						break
					end
				end

				if addBlankLine then
					tooltip:AddLine(" ")
				end

				tooltip:AddLine(ID:format(id), 1, 1, 1)
			end
		end)

		TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Achievement, function(tooltip, data)
			if not GOOD_TOOLTIPS[tooltip] or tooltip:IsForbidden() then return end
			if not C.db.profile.tooltips.id then return end

			local id = data.id
			if id then
				tooltip:AddLine(" ")
				tooltip:AddLine(ID:format(id), 1, 1, 1)
			end
		end)

		local TEXTS_TO_REMOVE = {
			[_G.FACTION_ALLIANCE] = true,
			[_G.FACTION_HORDE] = true,
			[_G.PVP] = true,
			[_G.UNIT_POPUP_RIGHT_CLICK] = true,
		}

		TooltipDataProcessor.AddLinePreCall(Enum.TooltipDataLineType.None, function(tooltip, lineData)
			if not GOOD_TOOLTIPS[tooltip] or tooltip:IsForbidden() then return end
			if not tooltip:IsTooltipType(Enum.TooltipDataType.Unit) then return end

			if TEXTS_TO_REMOVE[lineData.leftText] then
				return true
			end

			-- TODO: replace it if/when blizz add a proper line type for it
			local tooltipData = tooltip:GetPrimaryTooltipData()
			local unit = tooltipData.guid and UnitTokenFromGUID(tooltipData.guid)
			local creatureType = unit and UnitCreatureType(unit)
			if creatureType then
				return lineData.leftText == creatureType
			end
		end)

		TooltipDataProcessor.AddLinePreCall(Enum.TooltipDataLineType.Blank, function(tooltip)
			if not GOOD_TOOLTIPS[tooltip] or tooltip:IsForbidden() then return end
			if not tooltip:IsTooltipType(Enum.TooltipDataType.Unit) then return end

			return true
		end)

		TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip)
			if not GOOD_TOOLTIPS[tooltip] or tooltip:IsForbidden() then return end

			local _, unit = tooltip:GetUnit()
			if not unit then return end

			local scaledLevel = UnitEffectiveLevel(unit)
			local difficultyColor = E:GetCreatureDifficultyColor(unit)
			local isShiftKeyDown = IsShiftKeyDown()

			if UnitIsPlayer(unit) then
				local name, realm = UnitName(unit)
				local pvpName = UnitPVPName(unit)

				if C.db.profile.tooltips.title and pvpName ~= "" then
					name = pvpName
				end

				if realm and realm ~= "" then
					if isShiftKeyDown then
						name = NAME_FORMAT:format(name, C.db.global.colors.gray:WrapTextInColorCode("-" .. realm))
					elseif UnitRealmRelationship(unit) ~= LE_REALM_RELATION_VIRTUAL then
						name = NAME_FORMAT:format(name, C.db.global.colors.gray:WrapTextInColorCode(_G.FOREIGN_SERVER_LABEL))
					end
				end

				GameTooltipTextLeft1:SetText(C.db.global.colors.gray:WrapTextInColorCode((UnitIsAFK(unit) and AFK or UnitIsDND(unit) and DND or "")) .. name)
				GameTooltipTextLeft1:SetTextColor(E:GetUnitColor_(unit, UnitIsFriend("player", unit), true):GetRGB())

				local status = ""

				if UnitInParty(unit) or UnitInRaid(unit) then
					if UnitIsGroupLeader(unit) then
						status = status .. M.textures.icons_inline["LEADER"]:format(16)
					end

					local role = UnitGroupRolesAssigned(unit)
					if role and role ~= "NONE" then
						status = status .. M.textures.icons_inline[role]:format(16)
					end
				end

				local phaseReason = UnitIsPlayer(unit) and UnitIsConnected(unit) and UnitPhaseReason(unit)
				if phaseReason then
					status = status .. PHASE_ICONS[phaseReason]:format(16)
				end

				local isPVPReady, pvpFaction = E:GetUnitPVPStatus(unit)
				if isPVPReady then
					status = status .. M.textures.icons_inline[s_upper(pvpFaction)]:format(16)
				end

				if status ~= "" then
					GameTooltipTextRight1:SetText(status)
					GameTooltipTextRight1:Show()
				else
					GameTooltipTextRight1:SetText(nil)
					GameTooltipTextRight1:Hide()
				end

				local lineOffset = 2

				local guildName, guildRankName , _, guildRealm = GetGuildInfo(unit)
				if guildName then
					lineOffset = 3

					if isShiftKeyDown then
						if guildRealm then
							guildName = NAME_FORMAT:format(guildName, C.db.global.colors.gray:WrapTextInColorCode("-" .. guildRealm))
						end

						if guildRankName then
							guildName = GUILD_TEMPLATE:format("|c" .. C.db.global.colors.gray:GetHex() .. guildRankName, "|r" .. guildName)
						end
					end

					GameTooltipTextLeft2:SetText(guildName)
				end

				local levelLine
				levelLine, lineOffset = findLine(tooltip, lineOffset, scaledLevel > 0 and scaledLevel or "%?%?")
				if levelLine then
					local level = UnitLevel(unit)

					levelLine:SetFormattedText(
						LEVEL_FORMAT,
						difficultyColor:WrapTextInColorCode(scaledLevel > 0 and (scaledLevel ~= level and scaledLevel .. " (" .. level .. ")" or scaledLevel) or "??"),
						UnitRace(unit)
					)

					local specLine = _G["GameTooltipTextLeft" .. lineOffset]
					local specText = s_trim(specLine:GetText() or "") -- just to make sure that it's no an empty line like " "
					if specText ~= "" then
						if C.db.profile.tooltips.inspect and isShiftKeyDown and level > 10 then
							local itemLevel = getInspectInfo(unit)
							if itemLevel then
								specLine:SetFormattedText(ILVL_SPEC_FORMAT, itemLevel, specText)
							end
						end

						if UnitIsDead(unit) then
							specLine:SetTextColor(C.db.global.colors.disconnected:GetRGB())
						else
							specLine:SetTextColor(E:GetUnitClassColor(unit):GetRGB())
						end
					end
				end
			elseif UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit) then
				GameTooltipTextLeft1:SetText(UnitName(unit) or _G.UNKNOWN)
				GameTooltipTextLeft1:SetTextColor(E:GetUnitColor_(unit, false, true):GetRGB())

				scaledLevel = UnitBattlePetLevel(unit)

				local levelLine = findLine(tooltip, 2, scaledLevel > 0 and scaledLevel or "%?%?")
				if levelLine then
					local teamLevel = C_PetJournal.GetPetTeamAverageLevel()
					if teamLevel then
						difficultyColor = E:GetRelativeDifficultyColor(teamLevel, scaledLevel)
					end

					local petType = _G["BATTLE_PET_NAME_" .. UnitBattlePetType(unit)]

					levelLine:SetFormattedText(
						LEVEL_FORMAT,
						difficultyColor:WrapTextInColorCode(scaledLevel > 0 and scaledLevel or "??"),
						(UnitCreatureType(unit) or _G.PET) .. (petType and ", " .. petType or "")
					)
				end
			else
				GameTooltipTextLeft1:SetText(UnitName(unit) or _G.UNKNOWN)
				GameTooltipTextLeft1:SetTextColor(E:GetUnitColor_(unit, false, true):GetRGB())

				local status = ""

				if UnitIsQuestBoss(unit) then
					status = status .. M.textures.icons_inline["QUEST"]:format(16)
				end

				local isPVPReady, pvpFaction = E:GetUnitPVPStatus(unit)
				if isPVPReady then
					status = status .. M.textures.icons_inline[s_upper(pvpFaction)]:format(16)
				end

				if status ~= "" then
					GameTooltipTextRight1:SetText(status)
					GameTooltipTextRight1:Show()
				else
					GameTooltipTextRight1:SetText(nil)
					GameTooltipTextRight1:Hide()
				end

				local levelLine = findLine(tooltip, 2, scaledLevel > 0 and scaledLevel or "%?%?")
				if levelLine then
					levelLine:SetFormattedText(
						LEVEL_FORMAT,
						difficultyColor:WrapTextInColorCode((scaledLevel > 0 and scaledLevel or "??") .. E:GetUnitClassification(unit)),
						UnitCreatureType(unit) or ""
					)
				end
			end

			if C.db.profile.tooltips.target then
				local unitTarget = unit .. "target"
				if UnitExists(unitTarget) then
					local name = UnitName(unitTarget)

					if UnitIsPlayer(unitTarget) then
						name = PLAYER_TARGET_FORMAT:format(E:GetUnitClassColor(unitTarget):WrapTextInColorCode(name), E:GetUnitReactionColor(unitTarget):GetHex())
					else
						name = E:GetUnitColor_(unitTarget, UnitIsFriend("player", unit), true):WrapTextInColorCode(name)
					end

					tooltip:AddLine(TARGET:format(name), 1, 1, 1)
				end
			end
		end)

		-- Status Bars
		local function hideHealthBar(tooltip, tooltipData)
			if tooltip.StatusBar then
				if not tooltipData.healthGUID then
					tooltip.StatusBar:ClearWatch()
				end
			end
		end

		TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Corpse, hideHealthBar)
		TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.MinimapMouseover, hideHealthBar)

		local function tooltipBarHook(self)
			if self:IsForbidden() or self:GetParent():IsForbidden() then return end

			self.Text:Hide()
			self:SetStatusBarColor(C.db.global.colors.health:GetRGB())

			local _, unit = self:GetParent():GetUnit()
			if not unit then
				self:GetParent():SetMinimumWidth(0)

				return
			end

			local max = UnitHealthMax(unit)
			if max > 1 then
				self.Text:Show()
				self.Text:SetFormattedText("%s / %s", E:FormatNumber(UnitHealth(unit)), E:FormatNumber(max))

				self:GetParent():SetMinimumWidth(m_floor(self.Text:GetStringWidth() + 32))
			end
		end

		E.StatusBars:Reskin(E.StatusBars:Handle(GameTooltipStatusBar))

		GameTooltipStatusBar:ClearAllPoints()
		GameTooltipStatusBar:SetPoint("TOPLEFT", GameTooltip, "BOTTOMLEFT", 3, -2)
		GameTooltipStatusBar:SetPoint("TOPRIGHT", GameTooltip, "BOTTOMRIGHT", -3, -2)
		GameTooltipStatusBar:HookScript("OnShow", tooltipBarHook)
		GameTooltipStatusBar:HookScript("OnValueChanged", tooltipBarHook)

		hooksecurefunc("GameTooltip_AddStatusBar", function(self, _, max, value)
			if self:IsForbidden() then return end

			for _, child in next, {self:GetChildren()} do
				if child ~= GameTooltipStatusBar and child:GetObjectType() == "StatusBar" then
					if not child.handled then
						E.StatusBars:Reskin(E.StatusBars:Handle(child))

						child:SetHeight(10)
					end

					-- theoretically, there should be only 1 bar visible
					if value < max then
						child:SetStatusBarColor(C.db.global.colors.yellow:GetRGB())
					else
						child:SetStatusBarColor(C.db.global.colors.green:GetRGB())
					end
				end
			end
		end)

		E:RegisterEvent("MODIFIER_STATE_CHANGED", function(key)
			if GameTooltip:IsForbidden() then return end

			if UnitExists("mouseover") and (key == "LSHIFT" or key == "RSHIFT") then
				GameTooltip:RefreshData()
			end
		end)

		E:RegisterEvent("UPDATE_MOUSEOVER_UNIT", function()
			if GameTooltip:IsForbidden() then return end

			GameTooltip:RefreshData()
		end)

		isInit = true

		self:Update()
	end
end

function MODULE:Update()
	if isInit then
		GameTooltipStatusBar:SetHeight(C.db.profile.tooltips.health.height)
		GameTooltipStatusBar.Text:UpdateFont(C.db.profile.tooltips.health.text.size)
	end
end
