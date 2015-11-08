local _, ns = ...
local E, C, D, oUF = ns.E, ns.C, ns.D, ns.oUF

E:SetScript("OnEvent", E.EventHandler)

function E:ADDON_LOADED(arg)
	if arg ~= "oUF_LS" then return end

	self:CopyTable(self:CopyTable(D, oUF_LS_CONFIG), C)

	if C.units.enabled then
		oUF:Factory(E.UF.Initialize)
	end

	E:InitializeModules()

	lsOptionsFrame_Initialize()

	self:UnregisterEvent("ADDON_LOADED")

	collectgarbage("collect")
end

function E:PLAYER_ENTERING_WORLD(...)
	-- E:ToggleAllMovers()
end

function E:PLAYER_LOGOUT(...)
	oUF_LS_CONFIG = self:DiffTable(D, ns.C)
end

E:RegisterEvent("ADDON_LOADED")
E:RegisterEvent("PLAYER_ENTERING_WORLD")
E:RegisterEvent("PLAYER_LOGOUT")
