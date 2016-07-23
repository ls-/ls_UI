local _, ns = ...
local E, C, M, D, oUF = ns.E, ns.C, ns.M, ns.D, ns.oUF

E:SetScript("OnEvent", E.EventHandler)

function E:ADDON_LOADED(arg)
	if arg ~= "ls_UI" then return end

	if oUF_LS_CONFIG then
		E:CopyTable(E:CopyTable(D, oUF_LS_CONFIG), C)
		oUF_LS_CONFIG = nil
	else
		E:CopyTable(E:CopyTable(D, LS_UI_CONFIG), C)
	end

	E:InitializeModules()

	E:UnregisterEvent("ADDON_LOADED")

	collectgarbage("collect")
end

function E:PLAYER_LOGIN()
	E:UpdateConstants()
end

function E:PLAYER_LOGOUT(...)
	LS_UI_CONFIG = E:DiffTable(D, C)
end

E:RegisterEvent("ADDON_LOADED")
E:RegisterEvent("PLAYER_LOGIN")
E:RegisterEvent("PLAYER_LOGOUT")
