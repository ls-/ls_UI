local _, ns = ...

local tremove, tinsert, twipe = table.remove, table.insert, table.wipe
local AURATRACKER_CONFIG, AURATRACKER_LOCKED
local AuraTracker

local function lsAuraTracker_OnEvent(self, event)
	if event == "UNIT_AURA" or event == "PLAYER_LOGIN" or event == "CUSTOM_FORCE_UPDATE" or event == "CUSTOM_ENABLE" then
		if event == "PLAYER_LOGIN" or event == "CUSTOM_ENABLE" then
			if not AURATRACKER_CONFIG.enabled then
				self:Hide()

				print("|cff1ec77eAuraTracker|r is disabled. Type \"/at enable\" to enable the module.")
				return
			else
				if not self:IsEventRegistered("UNIT_AURA") then self:RegisterUnitEvent("UNIT_AURA", "player", "vehicle") end

				self:SetPoint(unpack(AURATRACKER_CONFIG.point))

				AURATRACKER_LOCKED = AURATRACKER_CONFIG.locked
				
				if #AURATRACKER_CONFIG.buffList + #AURATRACKER_CONFIG.debuffList > 8 then
					print("|cff1ec77eAuraTracker|r: Cleaning up lists. Too many entries.")

					for i = 1, #AURATRACKER_CONFIG.buffList - 4 do
						print("|cff1ec77eAuraTracker|r: Aura", AURATRACKER_CONFIG.buffList[5], "was removed from the buff list.")
						
						tremove(AURATRACKER_CONFIG.buffList, 5)
					end

					for i = 1, #AURATRACKER_CONFIG.debuffList - 4 do
						print("|cff1ec77eAuraTracker|r: Aura", AURATRACKER_CONFIG.debuffList[5], "was removed from the debuff list.")
						
						tremove(AURATRACKER_CONFIG.debuffList, 5)
					end
				end
			end

			if not AURATRACKER_CONFIG.showHeader then self.header:Hide() end
		end

		self.auras = twipe(self.auras or {})
		for i = 1, 32 do
			local name, _, iconTexture, count, debuffType, duration, expirationTime, _, _, _, spellId = UnitBuff("player", i)
			if name and tContains(AURATRACKER_CONFIG.buffList, spellId) then
				local aura = {}
				aura.index = i
				aura.icon = iconTexture
				aura.count = count
				aura.duration = duration
				aura.expire = expirationTime
				aura.filter = "HELPFUL"
				self.auras[#self.auras + 1] = aura
			end
		end

		for i = 1, 16 do
			local name, _, iconTexture, count, debuffType, duration, expirationTime, _, _, _, spellId = UnitDebuff("player", i)
			if name and tContains(AURATRACKER_CONFIG.debuffList, spellId) then
				local aura = {}
				aura.index = i
				aura.icon = iconTexture
				aura.count = count
				aura.duration = duration
				aura.expire = expirationTime
				aura.debuffType = debuffType
				aura.filter = "HARMFUL"
				self.auras[#self.auras + 1] = aura
			end
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

			local timeLeft
			button:SetScript("OnUpdate", function(self, elapsed)
				self.elapsed = (self.elapsed or 0) + elapsed
				
				if self.elapsed > 0.1 then
					self.count:SetText(self.stacks > 0 and self.stacks or "")

					if GameTooltip:IsOwned(self) then
						GameTooltip:SetUnitAura("player", self:GetID(), self.filter)
					end

					timeLeft = self.expire - GetTime()
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

local function AuraTrackerHeader_OnDragStart(self)
	if not AURATRACKER_LOCKED then
		local frame = self:GetParent()
		frame:StartMoving()
	end
end

local function AuraTrackerHeader_OnDragStop(self)
	if not AURATRACKER_LOCKED then
		local frame = self:GetParent()
		frame:StopMovingOrSizing()

		local point, _, relativePoint, xOfs, yOfs = frame:GetPoint()
		AURATRACKER_CONFIG.point = {point, "UIParent", relativePoint, xOfs, yOfs}
	end
end

local function AuraTrackerHeader_OnClick(self, button)
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

local function lsAuraTracker_CreateSlashCommands()
	SLASH_ATBUFF1 = '/atbuff'
	SlashCmdList["ATBUFF"] = function(msg)
		if #AURATRACKER_CONFIG.buffList + #AURATRACKER_CONFIG.debuffList == 8 then print("|cff1ec77eAuraTracker|r: Can\'t add aura. List is full. Max of 8.") return end
		if not AURATRACKER_CONFIG.enabled then print("|cff1ec77eAuraTracker|r: Can\'t add aura. Module is disabled.") return end
		if tContains(AURATRACKER_CONFIG.buffList, tonumber(msg)) then print("|cff1ec77eAuraTracker|r: Can\'t add aura. Already in the list.") return end

		local name = GetSpellInfo(tonumber(msg))
		if not name then print("|cff1ec77eAuraTracker|r: Can\'t add aura, that doesn't exist.") return end
		print("|cff1ec77eAuraTracker|r: "..name.." ("..msg..") was added to the list.")
		
		tinsert(AURATRACKER_CONFIG.buffList, tonumber(msg))
		
		AuraTracker:lsAuraTracker_OnEvent("CUSTOM_FORCE_UPDATE")
	end

	SLASH_ATDEBUFF1 = '/atdebuff'
	SlashCmdList["ATDEBUFF"] = function(msg)
		if #AURATRACKER_CONFIG.buffList + #AURATRACKER_CONFIG.debuffList == 8 then print("|cff1ec77eAuraTracker|r: Can\'t add aura. List is full. Max of 8.") return end
		if not AURATRACKER_CONFIG.enabled then print("|cff1ec77eAuraTracker|r: Can\'t add aura. Module is disabled.") return end
		if tContains(AURATRACKER_CONFIG.debuffList, tonumber(msg)) then print("|cff1ec77eAuraTracker|r: Can\'t add aura. Already in the list.") return end

		local name = GetSpellInfo(tonumber(msg))
		if not name then print("|cff1ec77eAuraTracker|r: Can\'t add aura, that doesn't exist.") return end
		print("|cff1ec77eAuraTracker|r: "..name.." ("..msg..") was added to the list.")
		
		tinsert(AURATRACKER_CONFIG.debuffList, tonumber(msg))

		AuraTracker:lsAuraTracker_OnEvent("CUSTOM_FORCE_UPDATE")
	end

	SLASH_ATREM1 = '/atrem'
	SlashCmdList["ATREM"] = function(msg)
		if not AURATRACKER_CONFIG.enabled then print("|cff1ec77eAuraTracker|r: Can\'t remove aura. Module is disabled.") return end

		for k,v in next, AURATRACKER_CONFIG.buffList do
			if v == tonumber(msg) then
				tremove(AURATRACKER_CONFIG.buffList, k)

				local name = GetSpellInfo(v) or " "
				print("|cff1ec77eAuraTracker|r: "..name.." ("..v..") was removed from the list of buffs.")
			end
		end

		for k,v in next, AURATRACKER_CONFIG.debuffList do
			if v == tonumber(msg) then
				tremove(AURATRACKER_CONFIG.debuffList, k)

				local name = GetSpellInfo(v) or " "
				print("|cff1ec77eAuraTracker|r: "..name.." ("..v..") was removed from the list of debuffs.")
			end
		end

		AuraTracker:lsAuraTracker_OnEvent("CUSTOM_FORCE_UPDATE")
	end

	SLASH_ATLIST1 = '/atlist'
	SlashCmdList["ATLIST"] = function(msg)
		if not AURATRACKER_CONFIG.enabled then print("|cff1ec77eAuraTracker|r: Can\'t print the list. Module is disabled.") return end

		print("|cff1ec77eAuraTracker|r: List of auras:")
		for k,v in next, AURATRACKER_CONFIG.buffList do
			local name = GetSpellInfo(v) or " "
			print("|cff00ccff+|r "..name.." ("..v..")")
		end

		for k,v in next, AURATRACKER_CONFIG.debuffList do
			local name = GetSpellInfo(v) or " "
			print("|cffd01717-|r "..name.." ("..v..")")
		end
	end

	SLASH_ATWIPE1 = '/atwipe'
	SlashCmdList["ATWIPE"] = function(msg)
		if not AURATRACKER_CONFIG.enabled then print("|cff1ec77eAuraTracker|r: Can\'t wipe the list. Module is disabled.") return end

		AURATRACKER_CONFIG.buffList = {}

		print("|cff1ec77eAuraTracker|r: List of auras was wiped.")

		AuraTracker:lsAuraTracker_OnEvent("CUSTOM_FORCE_UPDATE")
	end

	SLASH_AT1 = '/at'
	SlashCmdList["AT"] = function(msg)
		if msg == "enable" then
			if AURATRACKER_CONFIG.enabled then print("|cff1ec77eAuraTracker|r is already enabled.") return end
			if InCombatLockdown() then print("|cff1ec77eAuraTracker|r can\'t be enabled, while in combat.") return end

			print("|cff1ec77eAuraTracker|r was enabled.")

			AURATRACKER_CONFIG.enabled = true

			AuraTracker:Show()
			AuraTracker:lsAuraTracker_OnEvent("CUSTOM_ENABLE")
		elseif msg == "disable" then
			if not AURATRACKER_CONFIG.enabled then print("|cff1ec77eAuraTracker|r is already disabled.") return end
			if InCombatLockdown() then print("|cff1ec77eAuraTracker|r can\'t be disabled, while in combat.") return end

			print("|cff1ec77eAuraTracker|r was disabled.")

			AURATRACKER_CONFIG.enabled = false

			AuraTracker:Hide()
			AuraTracker:UnregisterEvent("UNIT_AURA")
		else
			print("|cff1ec77eAuraTracker|r: Unknown command.")
		end
	end

	SLASH_ATHEADER1 = '/atheader'
	SlashCmdList["ATHEADER"] = function(msg)
		if InCombatLockdown() then print("|cff1ec77eAuraTracker|r\'s header can\'t be toggled, while in combat.") return end

		if AuraTracker.header:IsShown() then
			AuraTracker.header:Hide()
			AURATRACKER_CONFIG.showHeader = false
		else
			AuraTracker.header:Show()
			AURATRACKER_CONFIG.showHeader = true
		end
	end

	SLASH_ATCMD1 = '/atcmd'
	SlashCmdList["ATCMD"] = function(msg)
		lsAuraTracker_PrintCommands()
	end
end

function ns.lsAuraTracker_Initialize()
	AURATRACKER_CONFIG = ns.C.auratracker

	AuraTracker = CreateFrame("Frame", nil, UIParent, "lsAuraTrackerTemplate")
	AuraTracker.lsAuraTracker_OnEvent = lsAuraTracker_OnEvent
	AuraTracker:lsAuraTracker_OnEvent("CUSTOM_ENABLE")

	lsAuraTracker_CreateSlashCommands()

	local atHeader = AuraTracker.header
	atHeader.AuraTrackerHeader_OnDragStart = AuraTrackerHeader_OnDragStart
	atHeader.AuraTrackerHeader_OnDragStop = AuraTrackerHeader_OnDragStop
	atHeader.AuraTrackerHeader_OnClick = AuraTrackerHeader_OnClick

	UIDropDownMenu_Initialize(atHeader.menu, lsAuraTrackerHeaderDropDown_Initialize, "MENU")
end
