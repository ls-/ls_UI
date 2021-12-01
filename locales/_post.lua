local _, ns = ...
local E, C, PrC, M, L, P = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)

-- Mine
-- These rely on custom strings
L["LATENCY_COLON"] = L["LATENCY"] .. ":"
L["MEMORY_COLON"] = L["MEMORY"] .. ":"

-- Multi-liners
