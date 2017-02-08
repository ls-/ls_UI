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

function UF:CreateIndicator(parent, isVertical)
	P.argcheck(1, parent, "table")
	P.argcheck(2, isVertical, "boolean")

	local indicator = _G.CreateFrame("Frame", nil, parent, "LSUILineTemplate")
	indicator:SetScript("OnShow", OnShow)

	indicator.ResetPoints = function(self)
		if isVertical then
			indicator:SetStartPoint("BOTTOM", indicator)
			indicator:SetEndPoint("TOP", indicator)
		else
			indicator:SetStartPoint("LEFT", indicator)
			indicator:SetEndPoint("RIGHT", indicator)
		end
	end

	indicator.Refresh = function(self)
		local status = _G.UnitThreatSituation("player")
		local r, g, b = M.COLORS.CLASS[E.PLAYER_CLASS]:GetRGB()

		if _G.UnitAffectingCombat("player") then
			r, g, b = M.COLORS.THREAT[status and status + 1 or 1]:GetRGB()
		end

		E:SetSmoothedVertexColor(self, r, g, b)
	end

	indicator.Free = function(self, flag)
		self.free = flag
	end

	indicator.IsFree = function(self)
		return self.free
	end

	if isVertical then
		indicator:SetStartPoint("BOTTOM", indicator)
		indicator:SetEndPoint("TOP", indicator)
	else
		indicator:SetStartPoint("LEFT", indicator)
		indicator:SetEndPoint("RIGHT", indicator)
	end

	indicator:Free(true)
	indicator:Refresh()
	indicator.ScrollAnim:Play()

	return indicator
end
