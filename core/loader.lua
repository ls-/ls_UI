local _, ns = ...
local E, D, oUF = ns.E, ns.D, ns.oUF

E:SetScript("OnEvent", function(self, event, ...)
	self[event](self, ...)
end)

function E:ADDON_LOADED(arg)
	if arg ~= "oUF_LS" then return end

	-- use bar manager with default settings only
	local enableActionBarManager = true
	if oUF_LS_CONFIG and oUF_LS_CONFIG.bars and (oUF_LS_CONFIG.bars.bar1
		or oUF_LS_CONFIG.bars.bar2 or oUF_LS_CONFIG.bars.bar3
		or oUF_LS_CONFIG.bars.bar6 or oUF_LS_CONFIG.bars.bar7) then
		enableActionBarManager = false
	end

	ns.C = self:CopyTable(D, oUF_LS_CONFIG) -- local config

	if ns.C.minimap.enabled then
		E.Minimap:Initialize()
	end

	if ns.C.auras.enabled then
		E.Auras:Initialize()
	end

	if ns.C.infobars.enabled then
		ns.lsInfobars_Initialize()
	end

	if ns.C.bars.enabled then
		E.ActionBars:Initialize(enableActionBarManager)
		E.MM:Initialize()
		E.Vehicle:Initialize()
		E.Extra:Initialize()
	end

	if ns.C.nameplates.enabled then
		E.NP:Initialize()
	end

	E.AT:Initialize()

	if ns.C.units.enabled then
		oUF:Factory(ns.lsFactory)
	end

	E.Mail:Initialize()

	if ns.C.bags.enabled then
		E.Bags:Initialize()
	end

	if ns.C.petbattle.enabled then
		E.PetBattle:Initialize()
	end

	E.Blizzard:Initialize()

	lsOptionsFrame_Initialize()

	self:UnregisterEvent("ADDON_LOADED")

	collectgarbage("collect")
end

function E:PLAYER_LOGOUT(...)
	oUF_LS_CONFIG = self:DiffTable(D, ns.C)
end

E:RegisterEvent("ADDON_LOADED")
E:RegisterEvent("PLAYER_LOGOUT")
