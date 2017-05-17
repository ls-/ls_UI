local _, ns = ...
local E, C, D, M, L, P = ns.E, ns.C, ns.D, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)

-- Mine
local function ADDON_LOADED(arg)
	if arg ~= "ls_UI" then return end

	-- -> 70200.06
	if _G.LS_UI_CONFIG and _G.LS_UI_CONFIG.version and (not _G.LS_UI_CONFIG.version.number or type(_G.LS_UI_CONFIG.version.number) ~= "number") then
		_G.LS_UI_CONFIG.version = nil
	end

	-- -> 70200.05
	if _G.LS_UI_CONFIG and (not _G.LS_UI_CONFIG.version or _G.LS_UI_CONFIG.version.number and _G.LS_UI_CONFIG.version.number < 7020005) then
		if _G.LS_UI_CONFIG.movers then
			_G.LS_UI_CONFIG.movers.LSFocusTargetFrameMover = nil
			_G.LS_UI_CONFIG.movers.LSTargetTargetFrameMover = nil
		end
	end

	E:CopyTable(E:CopyTable(D, _G.LS_UI_CONFIG), C)
	E:UnregisterEvent("ADDON_LOADED", ADDON_LOADED)
end

local function PLAYER_LOGIN()
	E:UpdateConstants()

	P:InitModules()
end

local function PLAYER_LOGOUT()
	E:CleanUpMoversConfig()

	_G.LS_UI_CONFIG = E:DiffTable(D, C)
	_G.LS_UI_CONFIG.version = E.VER
end

E:RegisterEvent("ADDON_LOADED", ADDON_LOADED)
E:RegisterEvent("PLAYER_LOGIN", PLAYER_LOGIN)
E:RegisterEvent("PLAYER_LOGOUT", PLAYER_LOGOUT)

-- No one needs to see these
ns.C, ns.D, ns.L, ns.P = nil, nil, nil, nil
