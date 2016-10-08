local _, ns = ...
local E, C, D = ns.E, ns.C, ns.D

function E:ADDON_LOADED(arg)
	if arg ~= "ls_UI" then return end

	self:CopyTable(self:CopyTable(D, _G.LS_UI_CONFIG), C)
	self:InitializeModules()
	self:UnregisterEvent("ADDON_LOADED")

	_G.collectgarbage("collect")
end

function E:PLAYER_LOGIN()
	self:UpdateConstants()
	self:InitializeDelayedModules()
end

function E:PLAYER_LOGOUT()
	self:CleanUpMoversConfig()

	_G.LS_UI_CONFIG = self:DiffTable(D, C)
end

E:RegisterEvent("ADDON_LOADED")
E:RegisterEvent("PLAYER_LOGIN")
E:RegisterEvent("PLAYER_LOGOUT")
