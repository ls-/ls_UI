local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = _G

-- Mine
local function OnShow(self)
	if self:IsFree() then
		self:Refresh()
	end
end

function UF:CreateIndicator(parent, options)
	P.argcheck(1, parent, "table")

	options = options or {}

	local indicator = _G.CreateFrame("Frame", nil, parent, "LSUILineTemplate")
	indicator:SetScript("OnShow", OnShow)

	indicator.ResetPoints = function()
		indicator:SetStartPoint(options.is_vertical and "BOTTOM" or "LEFT", indicator)
		indicator:SetEndPoint(options.is_vertical and "TOP" or "RIGHT", indicator)
	end

	indicator.Refresh = function()
		local status = _G.UnitThreatSituation("player")
		local r, g, b = M.COLORS.CLASS[E.PLAYER_CLASS]:GetRGB()

		if _G.UnitAffectingCombat("player") then
			r, g, b = M.COLORS.THREAT[status and status + 1 or 1]:GetRGB()
		end

		E:SetSmoothedVertexColor(indicator, r, g, b)
	end

	indicator.Free = function(_, flag)
		indicator.free = flag
	end

	indicator.IsFree = function()
		return indicator.free
	end

	indicator:Free(true)
	indicator:Refresh()
	indicator:ResetPoints()
	indicator.ScrollAnim:Play()

	return indicator
end
