local name, ns = ...

-- Lua
local _G = getfenv(0)
local type = _G.type
local next = _G.next

-- Mine
local LibStub = _G.LibStub

local E = LibStub("AceAddon-3.0"):NewAddon(name) -- engine
local C, D, M, L, P = {}, {}, {}, {}, {} -- config, defaults, media, locales, private
ns.E, ns.C, ns.D, ns.M, ns.L, ns.P = E, C, D, M, L, P

_G[name] = {
	[1] = ns.E,
	[2] = ns.M,
	[3] = ns.C,
}

local function ConvertConfig(old, base)
	local temp = {}

	for k, v in next, base do
		if old[k] ~= nil then
			if type(v) == "table" then
				if next(v) then
					temp[k] = ConvertConfig(old[k], v)
				else
					temp[k] = old[k]
				end
			else
				if old[k] ~= v then
					temp[k] = old[k]
				end

				old[k] = nil
			end
		end
	end

	return temp
end

local function UpdateAll()
	P:UpdateModules()
	P:UpdateMoverConfig()
end

function E.OnInitialize()
	C.db = LibStub("AceDB-3.0"):New("LS_UI_GLOBAL_CONFIG", D)
	LibStub("LibDualSpec-1.0"):EnhanceDatabase(C.db, "LS_UI_GLOBAL_CONFIG")

	-- layout type change shouldn't affect anything after SVs are loaded
	E.UI_LAYOUT = C.db.char.layout

	-- -> 70200.07
	-- old config conversion
	if LS_UI_CONFIG then
		LS_UI_CONFIG.version = nil

		E:CopyTable(ConvertConfig(LS_UI_CONFIG, D.char), C.db.char)

		if LS_UI_CONFIG.auras then
			E:CopyTable(ConvertConfig(LS_UI_CONFIG.auras, D.profile.auras.ls), C.db.profile.auras.ls)

			LS_UI_CONFIG.auras = nil
		end

		if LS_UI_CONFIG.units then
			E:CopyTable(ConvertConfig(LS_UI_CONFIG.units, D.profile.units.ls), C.db.profile.units.ls)

			LS_UI_CONFIG.units = nil
		end

		if LS_UI_CONFIG.minimap then
			E:CopyTable(ConvertConfig(LS_UI_CONFIG.minimap, D.profile.minimap.ls), C.db.profile.minimap.ls)

			LS_UI_CONFIG.minimap = nil
		end

		if LS_UI_CONFIG.movers then
			LS_UI_CONFIG.movers.LSPetFrameMover = nil
			LS_UI_CONFIG.movers.LSFocusTargetFrameMover = nil
			LS_UI_CONFIG.movers.LSTargetTargetFrameMover = nil

			E:CopyTable(LS_UI_CONFIG.movers, C.db.profile.movers.ls)

			LS_UI_CONFIG.movers = nil
		end

		if LS_UI_CONFIG.auratracker then
			if LS_UI_CONFIG.auratracker.HELPFUL then
				E:CopyTable(LS_UI_CONFIG.auratracker.HELPFUL, C.db.char.auratracker.filter.HELPFUL)

				for k in next, C.db.char.auratracker.filter.HELPFUL do
					C.db.char.auratracker.filter.HELPFUL[k] = true
				end
			end

			if LS_UI_CONFIG.auratracker.HARMFUL then
				E:CopyTable(LS_UI_CONFIG.auratracker.HARMFUL, C.db.char.auratracker.filter.HARMFUL)

				for k in next, C.db.char.auratracker.filter.HARMFUL do
					C.db.char.auratracker.filter.HARMFUL[k] = true
				end
			end

			LS_UI_CONFIG.auratracker = nil
		end

		E:CopyTable(ConvertConfig(LS_UI_CONFIG, D.profile), C.db.profile)
	end

	-- -> 70200.08
	if not C.db.profile.version or C.db.profile.version < 7020008 then
		if C.db.profile.auratracker then
			if C.db.profile.auratracker.HELPFUL then
				E:CopyTable(C.db.profile.auratracker.HELPFUL, C.db.char.auratracker.filter.HELPFUL)

				for k in next, C.db.char.auratracker.filter.HELPFUL do
					C.db.char.auratracker.filter.HELPFUL[k] = true
				end
			end

			if C.db.profile.auratracker.HARMFUL then
				E:CopyTable(C.db.profile.auratracker.HARMFUL, C.db.char.auratracker.filter.HARMFUL)

				for k in next, C.db.char.auratracker.filter.HARMFUL do
					C.db.char.auratracker.filter.HARMFUL[k] = true
				end
			end

			C.db.profile.auratracker = nil
		end

		C.db.profile.tooltips.show_id = nil
		C.db.profile.tooltips.unit = nil

		for i = 1, 7 do
			C.db.profile.bars["bar"..i].button_gap = nil
			C.db.profile.bars["bar"..i].button_size = nil
			C.db.profile.bars["bar"..i].buttons_per_row = nil
			C.db.profile.bars["bar"..i].init_anchor = nil
		end

		C.db.profile.bars.bags.visible = nil
		C.db.profile.bars.bags.button_gap = nil
		C.db.profile.bars.bags.button_size = nil
		C.db.profile.bars.bags.buttons_per_row = nil
		C.db.profile.bars.bags.init_anchor = nil

		C.db.profile.bars.extra.visible = nil
		C.db.profile.bars.extra.button_size = nil

		C.db.profile.bars.zone.visible = nil
		C.db.profile.bars.zone.button_size = nil

		C.db.profile.bars.vehicle.visible = nil
		C.db.profile.bars.vehicle.button_size = nil

		C.db.profile.bars.garrison = nil

		C.db.profile.bars.micromenu.visible = nil

		for _, v in next, C.db.profile.units.ls do
			if v.auras then
				v.auras.show_boss = nil
				v.auras.show_mount = nil
				v.auras.show_Ecast = nil
				v.auras.show_selfcast_permanent = nil
				v.auras.show_blizzard = nil
				v.auras.show_player = nil
				v.auras.show_dispellable = nil
				v.auras.y_grwoth = nil
				v.auras.init_anchor = nil
			end
		end

		for _, v in next, C.db.profile.units.traditional do
			if v.auras then
				v.auras.show_boss = nil
				v.auras.show_mount = nil
				v.auras.show_selfcast = nil
				v.auras.show_selfcast_permanent = nil
				v.auras.show_blizzard = nil
				v.auras.show_player = nil
				v.auras.show_dispellable = nil
				v.auras.y_grwoth = nil
				v.auras.init_anchor = nil
			end
		end
	end

	-- -> 70200.09
	if not C.db.profile.version or C.db.profile.version < 7020009 then
		C.db.profile.auras.ls.aura_gap = nil
		C.db.profile.auras.ls.aura_size = nil
		C.db.profile.auras.ls.buff = nil
		C.db.profile.auras.ls.debuff = nil
		C.db.profile.auras.ls.tempench = nil

		C.db.profile.auras.traditional.aura_gap = nil
		C.db.profile.auras.traditional.aura_size = nil
		C.db.profile.auras.traditional.buff = nil
		C.db.profile.auras.traditional.debuff = nil
		C.db.profile.auras.traditional.tempench = nil
	end

	-- -> 70300.04
	if not C.db.profile.version or C.db.profile.version < 7030004 then
		C.db.profile.movers.ls.ExtraActionBarFrameMover = nil
		C.db.profile.movers.ls.ZoneAbilityFrameMover = nil

		C.db.profile.movers.traditional.ExtraActionBarFrameMover = nil
		C.db.profile.movers.traditional.ZoneAbilityFrameMover = nil

		C.db.profile.bars.hotkey = nil
		C.db.profile.bars.icon_indicator = nil
		C.db.profile.bars.macro = nil

		C.db.profile.bars.micromenu.holder1 = nil
		C.db.profile.bars.micromenu.holder2 = nil
	end

	-- -> 70300.10
	if not C.db.profile.version or C.db.profile.version < 7030010 then
		for _, v in next, C.db.profile.units.ls do
			if v.insets then
				if v.insets.t_height == 14 or v.insets.t_height == 10 then
					v.insets.t_height = v.insets.t_height - 2
				end

				if v.insets.b_height == 14 or v.insets.b_height == 10 then
					v.insets.b_height = v.insets.b_height - 2
				end
			end
		end

		for _, v in next, C.db.profile.units.traditional do
			if v.insets then
				if v.insets.t_height == 14 or v.insets.t_height == 10 then
					v.insets.t_height = v.insets.t_height - 2
				end

				if v.insets.b_height == 14 or v.insets.b_height == 10 then
					v.insets.b_height = v.insets.b_height - 2
				end
			end
		end
	end
end

	C.db:RegisterCallback("OnDatabaseShutdown", function()
		C.db.char.version = E.VER.number
		C.db.profile.version = E.VER.number

		P:CleanUpMoverConfig()
	end)

	C.db:RegisterCallback("OnProfileShutdown", function()
		C.db.profile.version = E.VER.number

		P:CleanUpMoverConfig()
	end)

	C.db:RegisterCallback("OnProfileChanged", UpdateAll)
	C.db:RegisterCallback("OnProfileCopied", UpdateAll)
	C.db:RegisterCallback("OnProfileReset", UpdateAll)

	E:RegisterEvent("PLAYER_LOGIN", function()
		E:UpdateConstants()

		P:InitModules()
	end)

	-- No one needs to see these
	ns.C, ns.D, ns.L, ns.P = nil, nil, nil, nil
end
