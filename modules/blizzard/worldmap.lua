local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local B = E:GetModule("Blizzard")

-- Lua
local _G = _G

-- Mine
function B:HandleWorldMap()
	if _G.WorldMapFrame.UIElementsFrame.BountyBoard.GetDisplayLocation == _G.WorldMapBountyBoardMixin.GetDisplayLocation then
		_G.WorldMapFrame.UIElementsFrame.BountyBoard.GetDisplayLocation = function(frame)
			if _G.InCombatLockdown() then
				return
			end

			return _G.WorldMapBountyBoardMixin.GetDisplayLocation(frame)
		end
	end

	if _G.WorldMapFrame.UIElementsFrame.ActionButton.GetDisplayLocation == _G.WorldMapActionButtonMixin.GetDisplayLocation then
		_G.WorldMapFrame.UIElementsFrame.ActionButton.GetDisplayLocation = function(frame, useAlternateLocation)
			if _G.InCombatLockdown() then
				return
			end

			return _G.WorldMapActionButtonMixin.GetDisplayLocation(frame, useAlternateLocation)
		end
	end

	if _G.WorldMapFrame.UIElementsFrame.ActionButton.Refresh == _G.WorldMapActionButtonMixin.Refresh then
		_G.WorldMapFrame.UIElementsFrame.ActionButton.Refresh = function(frame)
			if _G.InCombatLockdown() then
				return
			end

			_G.WorldMapActionButtonMixin.Refresh(frame)
		end
	end

	_G.WorldMapFrame.questLogMode = true
	_G.QuestMapFrame_Open(true)
end
