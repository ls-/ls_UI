local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

-- Mine
local function OnShow(self)
	if self:IsFree() then
		self:Refresh()
	end
end

local function Refresh(self)
	local status = _G.UnitThreatSituation("player")
	local r, g, b = M.COLORS.CLASS[E.PLAYER_CLASS]:GetRGB()

	if _G.UnitAffectingCombat("player") then
		r, g, b = M.COLORS.THREAT[status and status + 1 or 1]:GetRGB()
	end

	E:SetSmoothedVertexColor(self, r, g, b)

	if self.PostRefresh then
		self:PostRefresh()
	end
end

local function Free(self, flag)
	self.free = flag
end

local function IsFree(self)
	return self.free
end

function UF:CreateIndicator(parent, options)
	P.argcheck(1, parent, "table")

	options = options or {}

	local indicator = _G.CreateFrame("Frame", nil, parent, "LSUILineTemplate")
	indicator:SetOrientation(options.is_vertical and "VERTICAL" or "HORIZONTAL")
	indicator:HookScript("OnShow", OnShow)

	indicator.Refresh = Refresh
	indicator.PostRefresh = options.post_update
	indicator.Free = Free
	indicator.IsFree = IsFree

	indicator:Free(true)
	indicator:Refresh()
	indicator.ScrollAnim:Play()

	return indicator
end
