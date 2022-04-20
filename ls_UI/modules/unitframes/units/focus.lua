local _, ns = ...
local E, C, PrC, M, L, P = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

-- Mine
local isInit = false

function UF:HasFocusFrame()
	return isInit
end

function UF:CreateFocusFrame(frame)
	isInit = true

	return self:CreateLargeFrame(frame)
end
