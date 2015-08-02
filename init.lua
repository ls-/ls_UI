local _, ns = ...
local E, C, D, oUF = ns.E, ns.C, ns.D, ns.oUF

E:SetScript("OnEvent", function(self, event, ...)
	self[event](self, ...)
end)

function E:ADDON_LOADED(arg)
	if arg ~= "oUF_LS" then return end

	self:CopyTable(self:CopyTable(D, oUF_LS_CONFIG), C)

	if C.minimap.enabled then
		E.Minimap:Initialize()
	end

	if C.auras.enabled then
		E.Auras:Initialize()
	end

	if C.infobars.enabled then
		ns.lsInfobars_Initialize()
	end

	if C.bars.enabled then
		E.ActionBars:Initialize()
		E.MM:Initialize()
		E.Vehicle:Initialize()
		E.Extra:Initialize()
		E.PetBattle:Initialize()

		if C.bags.enabled then
			E.Bags:Initialize()
		end
	end

	if C.nameplates.enabled then
		E.NP:Initialize()
	end

	if C.auratracker.enabled then
		E.AT:Initialize()
	end

	if C.units.enabled then
		oUF:Factory(E.UF.Initialize)
	end

	if C.mail.enabled then
		E.Mail:Initialize()
	end

	E.TT:Initialize()

	E.Blizzard:Initialize()

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
