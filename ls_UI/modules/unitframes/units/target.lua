local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

-- Mine
local isInit = false

function UF:HasTargetFrame()
	return isInit
end

function UF:CreateTargetFrame(frame)
	isInit = true

	return self:CreateLargeFrame(frame)
end
