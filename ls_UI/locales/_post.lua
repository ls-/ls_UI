local _, ns = ...
local E, L = ns.E, ns.L

-- Lua
local _G = getfenv(0)

-- Mine
-- These rely on custom strings
L["LATENCY_COLON"] = L["LATENCY"] .. ":"
L["MEMORY_COLON"] = L["MEMORY"] .. ":"

-- Multi-liners
