local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)

-- Mine
-- These rely on custom strings
L["LATENCY_COLON"] = L["LATENCY"] .. ":"
L["MEMORY_COLON"] = L["MEMORY"] .. ":"

-- Multi-liners
