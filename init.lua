local _, ns = ...
local E, C, M, D, oUF = ns.E, ns.C, ns.M, ns.D, ns.oUF

E:SetScript("OnEvent", E.EventHandler)

function E:ADDON_LOADED(arg)
	if arg ~= "oUF_LS" then return end

	E:CopyTable(E:CopyTable(D, oUF_LS_CONFIG), C)

	E:InitializeModules()

	E:UnregisterEvent("ADDON_LOADED")

	collectgarbage("collect")
end

function E:PLAYER_LOGIN()
	M:UpdateConstants()
end

function E:PLAYER_LOGOUT(...)
	oUF_LS_CONFIG = E:DiffTable(D, C)
end

E:RegisterEvent("ADDON_LOADED")
E:RegisterEvent("PLAYER_LOGIN")
E:RegisterEvent("PLAYER_LOGOUT")
