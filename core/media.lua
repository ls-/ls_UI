local _, ns = ...
local E, C, M, L, P, oUF = ns.E, ns.C, ns.M, ns.L, ns.P, ns.oUF

-- Lua
local _G = getfenv(0)

--[[ luacheck: globals
]]

-- Mine
local LSM = LibStub("LibSharedMedia-3.0")

LSM:Register("border", "LS Thick Border", "Interface\\AddOns\\ls_UI\\assets\\border-thick-tooltip")
LSM:Register("border", "LS Thin Border", "Interface\\AddOns\\ls_UI\\assets\\border-thin-tooltip")
