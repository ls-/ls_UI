local _, ns = ...

local tremove, tinsert, tcontains, tonumber = tremove, tinsert, tContains, tonumber
local AURATRACKER_CONFIG, AURATRACKER_LOCKED
local AuraTracker
local spec

local function lsScanAuras(auras, index, filter)
	local name, _, iconTexture, count, debuffType, duration, expirationTime, _, _, _, spellId = UnitAura("player", index, filter)
	if name and tcontains(AURATRACKER_CONFIG[spec][filter], spellId) then
		local aura = {
			index = index,
			icon = iconTexture,
			count = count,
			debuffType = debuffType,
			duration = duration,
			expire = expirationTime,
			filter = filter,
		}

		tinsert(auras, aura)
	end
end

local function lsHandleDataCorruption(aType, spec, overflow)
	local auraList, size = AURATRACKER_CONFIG[spec][aType], #AURATRACKER_CONFIG[spec][aType]

	if size > 0 then
		for i, v in next, auraList do
			if not GetSpellInfo(v) then
				tremove(auraList, i)
			end
		end
	end

	if overflow and size > 4 then
		for i = 1, size - 4 do
			local ID = auraList[5]
			if ID then
				print("|cff1ec77eAuraTracker|r: Removed "..GetSpellInfo(ID).." ("..ID..").")

				tremove(auraList, 5)
			end
		end

		print("|cff1ec77eAuraTracker|r: Reduced number of entries to 4 auras per list.")
	end
end

local function lsAuraTracker_OnEvent(self, event, ...)
	if event == "CUSTOM_ENABLE" then
		if not AURATRACKER_CONFIG.enabled then
			self:Hide()

			print("|cff1ec77eAuraTracker|r is disabled. Type \"/at enable\" to enable the module.")
		else
			if not self:IsEventRegistered("UNIT_AURA") then self:RegisterUnitEvent("UNIT_AURA", "player", "vehicle") end
			if not self:IsEventRegistered("PLAYER_SPECIALIZATION_CHANGED") then self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED") end

			self:SetPoint(unpack(AURATRACKER_CONFIG.point))

			spec = tostring(GetSpecialization() or 0)

			-- TODO_BEGIN: Remove it later
			if #AURATRACKER_CONFIG.HELPFUL > 0 then
				AURATRACKER_CONFIG["0"].HELPFUL = {unpack(AURATRACKER_CONFIG.HELPFUL)}

				AURATRACKER_CONFIG.HELPFUL = {}
			end

			if #AURATRACKER_CONFIG.HARMFUL > 0 then
				AURATRACKER_CONFIG["0"].HARMFUL = {unpack(AURATRACKER_CONFIG.HARMFUL)}

				AURATRACKER_CONFIG.HARMFUL = {}
			end
			-- TODO_END

			AURATRACKER_LOCKED = AURATRACKER_CONFIG.locked
		end

		if not AURATRACKER_CONFIG.showHeader then self.header:Hide() end

		return
	elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
		local oldSpec = spec
		spec = tostring(GetSpecialization() or 0)
		print(oldSpec, spec)

		if oldSpec ~= spec then
			if #AURATRACKER_CONFIG[spec].HELPFUL + #AURATRACKER_CONFIG[spec].HARMFUL == 0 then
				AURATRACKER_CONFIG[spec].HELPFUL = {unpack(AURATRACKER_CONFIG[oldSpec].HELPFUL)}
				AURATRACKER_CONFIG[spec].HARMFUL = {unpack(AURATRACKER_CONFIG[oldSpec].HARMFUL)}
			end

			if oldSpec == "0" then
				AURATRACKER_CONFIG[oldSpec].HELPFUL = {}
				AURATRACKER_CONFIG[oldSpec].HARMFUL = {}
			end
		end

		return
	elseif event == "PLAYER_ENTERING_WORLD" then
		local num = GetNumSpecializations()

		for i = 0, num do
			i = tostring(i)

			local overflow = #AURATRACKER_CONFIG[i].HELPFUL + #AURATRACKER_CONFIG[i].HARMFUL > 8

			lsHandleDataCorruption("HELPFUL", i, overflow)
			lsHandleDataCorruption("HARMFUL", i, overflow)
		end

		spec = tostring(GetSpecialization() or 0)

		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		self:OnEvent("CUSTOM_FORCE_UPDATE")

		return
	end

	self.auras = {}
	for i = 1, 32 do
		lsScanAuras(self.auras, i, "HELPFUL")
	end

	for i = 1, 16 do
		lsScanAuras(self.auras, i, "HARMFUL")
	end

	for i = #self.auras + 1, 8 do
		if self.buttons[i] then
			self.buttons[i]:Hide()
			self.buttons[i]:SetScript("OnUpdate", nil)
		end
	end

	for i = 1, #self.auras do
		local button, aura = self.buttons[i], self.auras[i]

		button:Show()
		button:SetID(aura.index)
		button.icon:SetTexture(aura.icon)
		button.cd:SetCooldown(aura.expire - aura.duration, aura.duration)
		button.debuffType = aura.debuffType
		button.filter = aura.filter
		button.expire = aura.expire
		button.stacks = aura.count

		local color
		if button.filter == "HARMFUL" then
			color = {r = 0.8, g = 0, b = 0}

			if button.debuffType then
				color = DebuffTypeColor[button.debuffType]
			end
		else
			color = {r = 1, g = 1, b = 1}
		end
		button.border:SetVertexColor(color.r, color.g, color.b)

		button:SetScript("OnUpdate", function(self, elapsed)
			self.elapsed = (self.elapsed or 0) + elapsed

			if self.elapsed > 0.1 then
				self.count:SetText(self.stacks > 0 and self.stacks or "")

				if GameTooltip:IsOwned(self) then
					GameTooltip:SetUnitAura("player", self:GetID(), self.filter)
				end

				local timeLeft = self.expire - GetTime()
				if timeLeft > 0 then
					if timeLeft <= 30 and not self.animation:IsPlaying() then
						self.animation:Play()
					end

					if timeLeft > 30 and self.animation:IsPlaying() then
						self.animation:Stop()
						self:SetAlpha(1)
					end

					if not OmniCC then
						if timeLeft > 10 then
							self.timer:SetTextColor(0.9, 0.9, 0.9)
						elseif timeLeft > 5 and timeLeft <= 10 then
							self.timer:SetTextColor(1, 0.75, 0.1)
						elseif timeLeft <= 5 then
							self.timer:SetTextColor(0.9, 0.1, 0.1)
						end

						self.timer:SetText(ns.TimeFormat(timeLeft))
					end
				else
					if not OmniCC then
						self.timer:SetText(nil)
					end

					if self.animation:IsPlaying() then
						self.animation:Stop()
						self:SetAlpha(1)
					end
				end

				self.elapsed = 0
			end
		end)
	end
end

local function lsAuraTracker_PrintCommands()
	print("|cff1ec77eAuraTracker|r: List of commands:")
	print("|cff00ccff/atbuff spellId|r - adds aura to the list of buffs;")
	print("|cff00ccff/atdebuff spellId|r - adds aura to the list of debuffs;")
	print("|cff00ccff/atrem spellId|r - removes aura from the list;")
	print("|cff00ccff/atlist|r - prints the list of tracked auras;")
	print("|cff00ccff/atwipe|r - wipes the list of tracked auras;")
	print("|cff00ccff/atheader|r - toggles AuraTracker header visibility;")
	print("|cff00ccff/atcmd|r - prints the list of commands;")
	print("|cff00ccff/at enable/disable|r - enables or disables the module.")
end

local function lsAuraTrackerHeader_OnDragStart(self)
	if not AURATRACKER_LOCKED then
		local frame = self:GetParent()
		frame:StartMoving()
	end
end

local function lsAuraTrackerHeader_OnDragStop(self)
	if not AURATRACKER_LOCKED then
		local frame = self:GetParent()
		frame:StopMovingOrSizing()

		local point, _, relativePoint, xOfs, yOfs = frame:GetPoint()
		AURATRACKER_CONFIG.point = {point, "UIParent", relativePoint, xOfs, yOfs}
	end
end

local function lsAuraTrackerHeader_OnClick(self, button)
	if button == "RightButton" then
		ToggleDropDownMenu(1, nil, self.menu, "cursor", 3, -3)
	end
end

local function lsAuraTrackerHeaderDropDown_Initialize(self)
	local info = UIDropDownMenu_CreateInfo()
	info.notCheckable = 1
	info.text = AURATRACKER_LOCKED and UNLOCK_FRAME or LOCK_FRAME
	info.func = function()
		AURATRACKER_LOCKED = not AURATRACKER_LOCKED
		AURATRACKER_CONFIG.locked = AURATRACKER_LOCKED
	end
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL)

	info = UIDropDownMenu_CreateInfo()
	info.notCheckable = 1
	info.text = lsLISTOFCOMMANDS
	info.func = lsAuraTracker_PrintCommands
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL)
end

local function lsAuraTracker_AddToList(aType, ID)
	if #AURATRACKER_CONFIG[spec].HELPFUL + #AURATRACKER_CONFIG[spec].HARMFUL == 8 then
		print("|cff1ec77eAuraTracker|r: Can\'t add aura. List is full. Max of 8.")
		return
	end

	if not AURATRACKER_CONFIG.enabled then
		print("|cff1ec77eAuraTracker|r: Can\'t add aura. Module is disabled.")
		return
	end

	local name = GetSpellInfo(ID)
	if not name then
		print("|cff1ec77eAuraTracker|r: Can\'t add aura, that doesn't exist.")
		return
	end

	if tcontains(AURATRACKER_CONFIG[spec][aType], ID) then
		print("|cff1ec77eAuraTracker|r: Can\'t add aura. Already in the list.")
		return
	end

	tinsert(AURATRACKER_CONFIG[spec][aType], ID)

	print("|cff1ec77eAuraTracker|r: Added "..name.." ("..ID..").")

	AuraTracker:OnEvent("CUSTOM_FORCE_UPDATE")
end

local function lsAuraTracker_RemoveFromList(aType, ID)
	for i, v in next, AURATRACKER_CONFIG[spec][aType] do
		if v == ID then
			tremove(AURATRACKER_CONFIG[spec][aType], i)

			print("|cff1ec77eAuraTracker|r: Removed "..GetSpellInfo(ID).." ("..ID..").")
			return true
		end
	end
end

local function lsAuraTracker_CreateSlashCommands()
	SLASH_ATBUFF1 = "/atbuff"
	SlashCmdList["ATBUFF"] = function(msg)
		lsAuraTracker_AddToList("HELPFUL", tonumber(msg))
	end

	SLASH_ATDEBUFF1 = "/atdebuff"
	SlashCmdList["ATDEBUFF"] = function(msg)
		lsAuraTracker_AddToList("HARMFUL", tonumber(msg))
	end

	SLASH_ATREM1 = "/atrem"
	SlashCmdList["ATREM"] = function(msg)
		if not AURATRACKER_CONFIG.enabled then
			print("|cff1ec77eAuraTracker|r: Can\'t remove aura. Module is disabled.")
			return
		end

		local ID = tonumber(msg)
		if not GetSpellInfo(ID) then
			print("|cff1ec77eAuraTracker|r: Can\'t remove aura, that doesn't exist.")
			return
		end

		local br = lsAuraTracker_RemoveFromList("HELPFUL", ID)
		local dr = lsAuraTracker_RemoveFromList("HARMFUL", ID)

		if br or dr then
			AuraTracker:OnEvent("CUSTOM_FORCE_UPDATE")
		end
	end

	SLASH_ATLIST1 = "/atlist"
	SlashCmdList["ATLIST"] = function(msg)
		if not AURATRACKER_CONFIG.enabled then
			print("|cff1ec77eAuraTracker|r: Can\'t print the list. Module is disabled.")
			return
		end

		print("|cff1ec77eAuraTracker|r: List of auras:")

		for _, v in next, AURATRACKER_CONFIG[spec].HELPFUL do
			local name = GetSpellInfo(v) or " "
			print("|cff00ccff+|r "..name.." ("..v..")")
		end

		for _, v in next, AURATRACKER_CONFIG[spec].HARMFUL do
			local name = GetSpellInfo(v) or " "
			print("|cffd01717-|r "..name.." ("..v..")")
		end
	end

	SLASH_ATWIPE1 = "/atwipe"
	SlashCmdList["ATWIPE"] = function(msg)
		if not AURATRACKER_CONFIG.enabled then
			print("|cff1ec77eAuraTracker|r: Can\'t wipe the list. Module is disabled.")
			return
		end

		AURATRACKER_CONFIG[spec].HELPFUL = {}
		AURATRACKER_CONFIG[spec].HARMFUL = {}

		print("|cff1ec77eAuraTracker|r: Wiped aura list.")

		AuraTracker:OnEvent("CUSTOM_FORCE_UPDATE")
	end

	SLASH_AT1 = "/at"
	SlashCmdList["AT"] = function(msg)
		if msg == "enable" then
			if AURATRACKER_CONFIG.enabled then
				print("|cff1ec77eAuraTracker|r is already enabled.")
				return
			end

			if InCombatLockdown() then
				print("|cff1ec77eAuraTracker|r can\'t be enabled, while in combat.")
				return
			end

			print("|cff1ec77eAuraTracker|r was enabled.")

			AURATRACKER_CONFIG.enabled = true

			AuraTracker:Show()
			AuraTracker:OnEvent("CUSTOM_ENABLE")
			AuraTracker:OnEvent("CUSTOM_FORCE_UPDATE")
		elseif msg == "disable" then
			if not AURATRACKER_CONFIG.enabled then
				print("|cff1ec77eAuraTracker|r is already disabled.")
				return
			end

			if InCombatLockdown() then
				print("|cff1ec77eAuraTracker|r can\'t be disabled, while in combat.")
				return
			end

			print("|cff1ec77eAuraTracker|r was disabled.")

			AURATRACKER_CONFIG.enabled = false

			AuraTracker:Hide()
			AuraTracker:UnregisterEvent("UNIT_AURA")
			AuraTracker:UnregisterEvent("PLAYER_SPECIALIZATION_CHANGED")
		else
			print("|cff1ec77eAuraTracker|r: Unknown command.")
		end
	end

	SLASH_ATHEADER1 = "/atheader"
	SlashCmdList["ATHEADER"] = function(msg)
		if InCombatLockdown() then
			print("|cff1ec77eAuraTracker|r\'s header visibility can\'t be toggled, while in combat.")
			return
		end

		if AuraTracker.header:IsShown() then
			AuraTracker.header:Hide()
			AURATRACKER_CONFIG.showHeader = false
		else
			AuraTracker.header:Show()
			AURATRACKER_CONFIG.showHeader = true
		end
	end

	SLASH_ATCMD1 = "/atcmd"
	SlashCmdList["ATCMD"] = function(msg)
		lsAuraTracker_PrintCommands()
	end
end

function ns.lsAuraTracker_Initialize()
	AURATRACKER_CONFIG = ns.C.auratracker

	AuraTracker = CreateFrame("Frame", nil, UIParent, "lsAuraTrackerTemplate")
	AuraTracker:RegisterEvent("PLAYER_ENTERING_WORLD")
	AuraTracker.OnEvent = lsAuraTracker_OnEvent
	AuraTracker:OnEvent("CUSTOM_ENABLE")

	local atHeader = AuraTracker.header
	atHeader.OnDragStart = lsAuraTrackerHeader_OnDragStart
	atHeader.OnDragStop = lsAuraTrackerHeader_OnDragStop
	atHeader.OnClick = lsAuraTrackerHeader_OnClick

	lsAuraTracker_CreateSlashCommands()
	UIDropDownMenu_Initialize(atHeader.menu, lsAuraTrackerHeaderDropDown_Initialize, "MENU")
end
