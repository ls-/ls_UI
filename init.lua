local _, ns = ...
local E, C, D, M, L, P = ns.E, ns.C, ns.D, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)

-- Mine
local function ADDON_LOADED(arg)
	if arg ~= "ls_UI" then return end

	E:CopyTable(E:CopyTable(D, _G.LS_UI_CONFIG), C)

	-------------------------
	-- CONFIG TWEAKS START --
	-------------------------

	-- > 70100.14
	C.bars.expbar = nil
	C.bars.xpbar.hide_if_empty = nil
	C.login_msg = nil
	C.units.boss.auras = nil
	C.units.focus.auras.HARMFUL = nil
	C.units.focus.auras.HELPFUL = nil
	C.units.focus.auras.show_only_filtered = nil
	C.units.focustarget.enabled = nil
	C.units.party = nil
	C.units.pet.castbar = nil
	C.units.pet.enabled = nil
	C.units.target.auras.HARMFUL = nil
	C.units.target.auras.HELPFUL = nil
	C.units.target.auras.show_only_filtered = nil
	C.units.targettarget.enabled = nil

	-----------------------
	-- CONFIG TWEAKS END --
	-----------------------

	E:UnregisterEvent("ADDON_LOADED", ADDON_LOADED)

	_G.collectgarbage("collect")
end

local function PLAYER_LOGIN()
	E:UpdateConstants()

	P:InitModules()
end

local function PLAYER_LOGOUT()
	E:CleanUpMoversConfig()

	_G.LS_UI_CONFIG = E:DiffTable(D, C)
end

E:RegisterEvent("ADDON_LOADED", ADDON_LOADED)
E:RegisterEvent("PLAYER_LOGIN", PLAYER_LOGIN)
E:RegisterEvent("PLAYER_LOGOUT", PLAYER_LOGOUT)

-- No one needs to see these
ns.C, ns.D, ns.L, ns.P = nil, nil, nil, nil
