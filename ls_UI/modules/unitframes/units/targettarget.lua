local _, ns = ...
local E, C, PrC, M, L, P = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

-- Mine
function UF:CreateTargetTargetFrame(frame)
	self:CreateSmallUnitFrame(frame)

	frame.Status = self:CreateStatus(frame, frame.TextParent)

	return true
end
