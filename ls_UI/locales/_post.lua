local _, ns = ...
local E, L = ns.E, ns.L

-- Lua
local _G = getfenv(0)

-- Mine
-- These rely on custom strings
L["LATENCY_COLON"] = L["LATENCY"] .. _G.HEADER_COLON
L["MEMORY_COLON"] = L["MEMORY"] .. _G.HEADER_COLON

-- Multi-liners
