local addonName, ns = ...
local E, C, D, M, L, P = ns.E, ns.C, ns.D, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)
local next = _G.next

--[[ luacheck: globals
	AdiButtonAuras hooksecurefunc LibStub MaxDps MinimapButtonFrame
]]

-- Mine
local function cleanUpStep1()
	local bars = {"bar1", "bar2", "bar3", "bar4", "bar5", "bar6", "bar7", "pet_battle", "extra", "zone"}

	-- -> 90001.05
	if C.db.profile.version and C.db.profile.version < 9000105 then
		for _, bar in next, bars do
			if C.db.profile.bars[bar] then
				if C.db.profile.bars[bar].hotkey then
					C.db.profile.bars[bar].hotkey.flag = nil
				end

				if C.db.profile.bars[bar].macro then
					C.db.profile.bars[bar].macro.flag = nil
				end

				if C.db.profile.bars[bar].count then
					C.db.profile.bars[bar].count.flag = nil
				end

				if C.db.profile.bars[bar].cooldown then
					C.db.profile.bars[bar].cooldown.text.flag = nil
				end
			end
		end

		C.db.profile.bars.xpbar.text.flag = nil

		C.db.profile.auras.HELPFUL.cooldown.text.flag = nil
		C.db.profile.auras.HARMFUL.cooldown.text.flag = nil
		C.db.profile.auras.TOTEM.cooldown.text.flag = nil
	end

	if C.db.char.version and C.db.char.version < 9000105 then
		C.db.char.auratracker.cooldown.text.flag = nil
	end

	-- -> 90002.04
	if C.db.global.version and C.db.global.version < 9000204 then
		if C.db.global.fonts.units then
			E:CopyTable(C.db.global.fonts.units, C.db.global.fonts.unit)
			C.db.global.fonts.units = nil
		end

		if C.db.global.fonts.bars then
			E:CopyTable(C.db.global.fonts.bars, C.db.global.fonts.button)
			C.db.global.fonts.bars = nil
		end
	end

	if C.db.profile.version and C.db.profile.version < 9000204 then
		C.db.profile.units.traditional.player.auras.count.outline = nil
		C.db.profile.units.traditional.player.auras.count.shadow = nil

		C.db.profile.auras.HELPFUL.count.flag = nil
		C.db.profile.auras.HARMFUL.count.flag = nil

		C.db.profile.blizzard.digsite_bar.text.flag = nil
		C.db.profile.blizzard.timer.text.flag = nil
	end

	if C.db.char.version and C.db.char.version < 9000204 then
		C.db.char.auratracker.count.enabled = nil
		C.db.char.auratracker.count.outline = nil
		C.db.char.auratracker.count.shadow = nil
		C.db.char.auratracker.count.flag = nil
	end

	-- -> 90002.06
	if C.db.profile.version and C.db.profile.version < 9000206 then
		C.db.profile.units.ls.player.name = nil

		C.db.profile.units.ls.player.health.prediction.absorb_text = nil
		C.db.profile.units.ls.player.health.prediction.heal_absorb_text = nil
		C.db.profile.units.traditional.player.health.prediction.absorb_text = nil
		C.db.profile.units.traditional.player.health.prediction.heal_absorb_text = nil

		C.db.profile.units.ls.player.class_power.change_threshold = nil
		C.db.profile.units.traditional.player.class_power.change_threshold = nil
	end
end

local function cleanUpStep2()
	local units = {"player", "pet", "target", "targettarget", "focus", "focustarget", "boss"}

	-- -> 90001.05
	if C.db.profile.version and C.db.profile.version < 9000105 then
		for _, unit in next, units do
			if C.db.profile.units[unit] then
				if C.db.profile.units[unit].health then
					C.db.profile.units[unit].health.text.outline = nil
					C.db.profile.units[unit].health.text.shadow = nil

					if C.db.profile.units[unit].health.prediction then
						if C.db.profile.units[unit].health.prediction.absorb_text then
							C.db.profile.units[unit].health.prediction.absorb_text.outline = nil
							C.db.profile.units[unit].health.prediction.absorb_text.shadow = nil
						end

						if C.db.profile.units[unit].health.prediction.heal_absorb_text then
							C.db.profile.units[unit].health.prediction.heal_absorb_text.outline = nil
							C.db.profile.units[unit].health.prediction.heal_absorb_text.shadow = nil
						end
					end
				end

				if C.db.profile.units[unit].power then
					C.db.profile.units[unit].power.text.outline = nil
					C.db.profile.units[unit].power.text.shadow = nil
				end

				if C.db.profile.units[unit].castbar then
					C.db.profile.units[unit].castbar.text.outline = nil
					C.db.profile.units[unit].castbar.text.shadow = nil
				end

				if C.db.profile.units[unit].name then
					C.db.profile.units[unit].name.outline = nil
					C.db.profile.units[unit].name.shadow = nil
				end

				if C.db.profile.units[unit].auras then
					if C.db.profile.units[unit].auras.cooldown then
						C.db.profile.units[unit].auras.cooldown.text.outline = nil
						C.db.profile.units[unit].auras.cooldown.text.shadow = nil
					end
				end
			end
		end
	end

	-- -> 90002.04
	if C.db.profile.version and C.db.profile.version < 9000204 then
		for _, unit in next, units do
			if C.db.profile.units[unit] then
				if C.db.profile.units[unit].auras then
					C.db.profile.units[unit].auras.count.outline = nil
					C.db.profile.units[unit].auras.count.shadow = nil
				end
			end
		end
	end

	-- -> 90002.06
	if C.db.profile.version and C.db.profile.version < 9000206 then
		C.db.profile.units.boss.alt_power.change_threshold = nil

		C.db.profile.units.player.class_power.change_threshold = nil

		C.db.profile.units.targettarget.custom_texts = nil
		C.db.profile.units.focustarget.custom_texts = nil

		for _, unit in next, units do
			C.db.profile.units[unit].health.change_threshold = nil
			C.db.profile.units[unit].power.change_threshold = nil

			if C.db.profile.units[unit].prediction then
				C.db.profile.units[unit].prediction.absorb_text = nil
				C.db.profile.units[unit].prediction.heal_absorb_text = nil
			end

			if C.db.profile.units[unit].pvp then
				C.db.profile.units[unit].pvp.point1 = nil
			end

			if C.db.profile.units[unit].insets then
				C.db.profile.units[unit].insets.t_height = nil
				C.db.profile.units[unit].insets.b_height = nil
			end

			if C.db.profile.units[unit].auras then
				C.db.profile.units[unit].auras.count.outline = nil
				C.db.profile.units[unit].auras.count.shadow = nil
			end
		end
	end

	-- -> 90005.01
	if C.db.profile.version and C.db.profile.version < 9000501 then
		for _, unit in next, units do
			if C.db.profile.units[unit].insets then
				if C.db.profile.units[unit].insets.t_size > 0.25 then
					C.db.profile.units[unit].insets.t_size = 0.25
				end
			end
		end
	end
end

local function addRefs()
	C.db.profile.units.player = C.db.profile.units[E.UI_LAYOUT].player
	C.db.profile.units.pet = C.db.profile.units[E.UI_LAYOUT].pet

	C.db.global.colors.power[ 0] = C.db.global.colors.power.MANA
	C.db.global.colors.power[ 1] = C.db.global.colors.power.RAGE
	C.db.global.colors.power[ 2] = C.db.global.colors.power.FOCUS
	C.db.global.colors.power[ 3] = C.db.global.colors.power.ENERGY
	C.db.global.colors.power[ 4] = C.db.global.colors.power.CHI
	C.db.global.colors.power[ 5] = C.db.global.colors.power.RUNES
	C.db.global.colors.power[ 6] = C.db.global.colors.power.RUNIC_POWER
	C.db.global.colors.power[ 7] = C.db.global.colors.power.SOUL_SHARDS
	C.db.global.colors.power[ 8] = C.db.global.colors.power.LUNAR_POWER
	C.db.global.colors.power[ 9] = C.db.global.colors.power.HOLY_POWER
	C.db.global.colors.power[10] = C.db.global.colors.power.ALTERNATE
	C.db.global.colors.power[11] = C.db.global.colors.power.MAELSTROM
	C.db.global.colors.power[13] = C.db.global.colors.power.INSANITY
	C.db.global.colors.power[17] = C.db.global.colors.power.FURY
	C.db.global.colors.power[18] = C.db.global.colors.power.PAIN
end

local function removeRefs()
	C.db.profile.units.player = nil
	C.db.profile.units.pet = nil

	C.db.global.colors.power[ 0] = nil
	C.db.global.colors.power[ 1] = nil
	C.db.global.colors.power[ 2] = nil
	C.db.global.colors.power[ 3] = nil
	C.db.global.colors.power[ 4] = nil
	C.db.global.colors.power[ 5] = nil
	C.db.global.colors.power[ 6] = nil
	C.db.global.colors.power[ 7] = nil
	C.db.global.colors.power[ 8] = nil
	C.db.global.colors.power[ 9] = nil
	C.db.global.colors.power[10] = nil
	C.db.global.colors.power[11] = nil
	C.db.global.colors.power[13] = nil
	C.db.global.colors.power[17] = nil
	C.db.global.colors.power[18] = nil
end

local function updateAll()
	cleanUpStep1()
	addRefs()
	cleanUpStep2()

	P:UpdateModules()
	P.Movers:UpdateConfig()
end

E:RegisterEvent("ADDON_LOADED", function(arg1)
	if arg1 ~= addonName then return end

	C.db = LibStub("AceDB-3.0"):New("LS_UI_GLOBAL_CONFIG", D)
	LibStub("LibDualSpec-1.0"):EnhanceDatabase(C.db, "LS_UI_GLOBAL_CONFIG")

	-- layout type change shouldn't affect anything after SVs are loaded
	E.UI_LAYOUT = C.db.char.layout

	D.profile.units.player = D.profile.units[E.UI_LAYOUT].player
	D.profile.units.pet = D.profile.units[E.UI_LAYOUT].pet

	cleanUpStep1()
	addRefs()
	cleanUpStep2()

	if AdiButtonAuras and AdiButtonAuras.RegisterLAB then
		AdiButtonAuras:RegisterLAB("LibActionButton-1.0-ls")
	end

	if MaxDps then
		if MaxDps.RegisterLibActionButton then
			MaxDps:RegisterLibActionButton("LibActionButton-1.0-ls")
		else
			local LAB = LibStub("LibActionButton-1.0-ls")

			if MaxDps.FetchLibActionButton then
				hooksecurefunc(MaxDps, "FetchLibActionButton", function(self)
					for button in next, LAB:GetAllButtons() do
						self:AddButton(button:GetSpellId(), button)
					end
				end)
			end

			if MaxDps.UpdateButtonGlow then
				hooksecurefunc(MaxDps, "UpdateButtonGlow", function(self)
					if self.db.global.disableButtonGlow then
						LAB.eventFrame:UnregisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW")
					else
						LAB.eventFrame:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW")
					end
				end)
			end
		end
	end

	if MinimapButtonFrame then
		C.db.profile.minimap.collect.enabled = false
	end

	C.db:RegisterCallback("OnDatabaseShutdown", function()
		C.db.char.version = E.VER.number
		C.db.global.version = E.VER.number
		C.db.profile.version = E.VER.number

		removeRefs()

		P.Movers:CleanUpConfig()
	end)

	C.db:RegisterCallback("OnProfileShutdown", function()
		C.db.profile.version = E.VER.number

		removeRefs()

		P.Movers:CleanUpConfig()
	end)

	C.db:RegisterCallback("OnProfileChanged", updateAll)
	C.db:RegisterCallback("OnProfileCopied", updateAll)
	C.db:RegisterCallback("OnProfileReset", updateAll)

	E:RegisterEvent("PLAYER_LOGIN", function()
		E:UpdateConstants()

		P:InitModules()
	end)

	-- No one needs to see these
	ns.C, ns.D, ns.L, ns.P = nil, nil, nil, nil
end)
