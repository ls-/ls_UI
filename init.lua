local addonName, ns = ...
local E, C, D, M, L, P = ns.E, ns.C, ns.D, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)
local type = _G.type
local next = _G.next

--[[ luacheck: globals
	LibStub
]]

-- Mine
local function cleanUpStep1()
	-- -> 80000.12
	if not C.db.profile.version or C.db.profile.version < 8000012 then
		if C.db.profile.units.player and C.db.profile.units.player.ls then
			E:CopyTable(C.db.profile.units.player.ls, C.db.profile.units.ls.player)

			C.db.profile.units.player.ls = nil
		end

		if C.db.profile.units.player and C.db.profile.units.player.traditional then
			E:CopyTable(C.db.profile.units.player.traditional, C.db.profile.units.traditional.player)

			C.db.profile.units.player.traditional = nil
		end

		if C.db.profile.units.pet and C.db.profile.units.pet.ls then
			E:CopyTable(C.db.profile.units.pet.ls, C.db.profile.units.ls.pet)

			C.db.profile.units.pet.ls = nil
		end

		if C.db.profile.units.pet and C.db.profile.units.pet.traditional then
			E:CopyTable(C.db.profile.units.pet.traditional, C.db.profile.units.traditional.pet)

			C.db.profile.units.pet.traditional = nil
		end

		local bars = {"bar1", "bar2", "bar3", "bar4", "bar5", "bar6", "bar7", "pet_battle", "extra",
		"zone"}

		for _, bar in next, bars do
			if C.db.profile.bars[bar] then
				if C.db.profile.bars[bar].cooldown then
					C.db.profile.bars[bar].cooldown.text.h_alignment = nil
				end
			end
		end

		C.db.profile.auras.HELPFUL.cooldown.text.h_alignment = nil
		C.db.profile.auras.HARMFUL.cooldown.text.h_alignment = nil
		C.db.profile.auras.TOTEM.cooldown.text.h_alignment = nil

		C.db.profile.blizzard.castbar.icon.enabled = nil
		C.db.profile.blizzard.castbar.text.flag = nil
	end

	-- -> 80000.13
	if not C.db.profile.version or C.db.profile.version < 8000013 then
		C.db.char.auratracker.cooldown.colors = nil

		C.db.profile.auras.cooldown.colors = nil

		C.db.profile.bars.colors = nil
		C.db.profile.bars.cooldown.colors = nil
		C.db.profile.bars.desaturation.cooldown = nil

		C.db.profile.blizzard.castbar.colors = nil

		C.db.profile.minimap.colors = nil

		C.db.profile.units.castbar = nil
		C.db.profile.units.colors = nil
	end

	-- -> 80100.07
	if not C.db.profile.version or C.db.profile.version < 8010007 then
		if C.db.profile.colors then
			if C.db.profile.colors.power and C.db.profiles.colors.power.ALT_POWER then
				C.db.profiles.colors.power.ALTERNATE = C.db.profiles.colors.power.ALT_POWER
				C.db.profiles.colors.power.ALT_POWER = nil
			end

			E:CopyTable(C.db.profile.colors, C.db.global.colors)

			C.db.profile.colors = nil
		end
	end
end

local function cleanUpStep2()
	-- -> 80000.13
	if not C.db.profile.version or C.db.profile.version < 8000013 then
		local units = {"player", "pet", "target", "targettarget", "focus", "focustarget", "boss"}

		for _, unit in next, units do
			if C.db.profile.units[unit] then
				if C.db.profile.units[unit].castbar then
					C.db.profile.units[unit].castbar.icon.enabled = nil
					C.db.profile.units[unit].castbar.text.flag = nil
				end

				if C.db.profile.units[unit].debuff then
					C.db.profile.units[unit].debuff.h_alignment = nil
				end

				if C.db.profile.units[unit].auras then
					C.db.profile.units[unit].auras.cooldown.text.h_alignment = nil
				end

				C.db.profile.units[unit].class = nil
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

	C.db:RegisterCallback("OnDatabaseShutdown", function()
		C.db.char.version = E.VER.number
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
