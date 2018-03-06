local addonName, ns = ...
local E, C, D, M, L, P = ns.E, ns.C, ns.D, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)
local type = _G.type
local next = _G.next

-- Mine
local function cleanUpProfile()
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

		C.db.profile.units.ls.boss.y_offset = nil
		C.db.profile.units.traditional.y_offset = nil
	end
end

local function UpdateAll()
	cleanUpProfile()
	P:UpdateModules()
	P:UpdateMoverConfig()
end

E:RegisterEvent("ADDON_LOADED", function(arg1)
	if arg1 ~= addonName then return end

	-- -> 70300.12
	if LS_UI_GLOBAL_CONFIG and LS_UI_GLOBAL_CONFIG.profiles then
		for _, profile in next, LS_UI_GLOBAL_CONFIG.profiles do
			if profile.bars then
				for _, bar in next, profile.bars do
					if type(bar) == "table" then
						if bar.hotkey ~= nil and type(bar.hotkey) == "boolean" then
							bar.hotkey = nil
						end

						if bar.macro ~= nil and type(bar.macro) == "boolean" then
							bar.macro = nil
						end
					end
				end
			end
		end
	end

	C.db = LibStub("AceDB-3.0"):New("LS_UI_GLOBAL_CONFIG", D)
	LibStub("LibDualSpec-1.0"):EnhanceDatabase(C.db, "LS_UI_GLOBAL_CONFIG")

	-- layout type change shouldn't affect anything after SVs are loaded
	E.UI_LAYOUT = C.db.char.layout

	cleanUpProfile()

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
end)
