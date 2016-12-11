local _, ns = ...
local E, C, D, M, L, P = ns.E, ns.C, ns.D, ns.M, ns.L, ns.P

-- Lua
local _G = _G

-- Mine
local function ADDON_LOADED(arg)
	if arg ~= "ls_UI" then return end

	E:CopyTable(E:CopyTable(D, _G.LS_UI_CONFIG), C)
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
