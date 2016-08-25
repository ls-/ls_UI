local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local B = E:GetModule("Blizzard")

-- Lua
local _G = _G

-- Mine
function B:HandleWorldMap()
	function _G.WorldMapFrame.UIElementsFrame.BountyBoard.GetDisplayLocation(self)
		if _G.InCombatLockdown() then
			return
		end

		return _G.WorldMapBountyBoardMixin.GetDisplayLocation(self)
	end

	function _G.WorldMapFrame.UIElementsFrame.ActionButton.GetDisplayLocation(self, useAlternateLocation)
		if _G.InCombatLockdown() then
			return
		end

		return _G.WorldMapActionButtonMixin.GetDisplayLocation(self, useAlternateLocation)
	end

	function _G.WorldMapFrame.UIElementsFrame.ActionButton.Refresh(self)
		if _G.InCombatLockdown() then
			return
		end

		_G.WorldMapActionButtonMixin.Refresh(self)
	end

	WorldMapFrame.questLogMode = true
	QuestMapFrame_Open(true)
end
