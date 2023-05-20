local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF, Profiler = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF, ns.Profiler
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

-- Mine
function UF:CreateFocusTargetFrame(frame)
	self:CreateSmallUnitFrame(frame)

	frame.Status = self:CreateStatus(frame, frame.TextParent)

	return true
end
