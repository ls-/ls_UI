local _, ns = ...
local E, D, oUF = ns.E, ns.D, ns.oUF

E:SetScript("OnEvent", function(self, event, ...)
	self[event](self, ...)
end)

function E:ADDON_LOADED(arg)
	if arg ~= "oUF_LS2" then return end

	-- use bar manager with default settings only
	local enableActionBarManager = true
	if oUF_LS_CONFIG and oUF_LS_CONFIG.bars and (oUF_LS_CONFIG.bars.bar1
		or oUF_LS_CONFIG.bars.bar2 or oUF_LS_CONFIG.bars.bar3
		or oUF_LS_CONFIG.bars.bar6 or oUF_LS_CONFIG.bars.bar7) then
		enableActionBarManager = false
	end

	ns.C = self:CopyTable(D, oUF_LS_CONFIG) -- local config

	-- Minimap
	if ns.C.minimap.enabled then
		LoadAddOn("Blizzard_TimeManager")
		ns.lsMinimap_Initialize()
	end

	-- Player buffs/debuffs/tempenchants
	if ns.C.auras.enabled then
		ns.lsBuffFrame_Initialize()
	end

	-- Infobars
	if ns.C.infobars.enabled then
		ns.lsInfobars_Initialize()
	end

	-- Actionbars & MicroMenu
	if ns.C.bars.enabled then
		ns.lsActionBars_Initialize(enableActionBarManager)
		ns.lsMicroMenu_Initialize()
	end

	-- NamePlates
	if ns.C.nameplates.enabled then
		ns.lsNamePlates_Initialize()
	end

	-- AuraTracker
	ns.lsAuraTracker_Initialize()

	-- ObjectiveTracker
	ns.lsOTDragHeader_Initialize()

	if ns.C.units.enabled then
		oUF:Factory(ns.lsFactory)
	end

	E.Mail:Initialize()

	lsOptionsFrame_Initialize()

	self:UnregisterEvent("ADDON_LOADED")
end

function E:PLAYER_LOGOUT(...)
	oUF_LS_CONFIG = self:DiffTable(D, ns.C)
end

E:RegisterEvent("ADDON_LOADED")
E:RegisterEvent("PLAYER_LOGOUT")
