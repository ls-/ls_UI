local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF

-- Lua
local _G = getfenv(0)

-- Mine
local LSM = LibStub("LibSharedMedia-3.0")

LSM:Register("border", "LS Thick", "Interface\\AddOns\\ls_UI\\assets\\border-thick-tooltip")
LSM:Register("border", "LS Thin", "Interface\\AddOns\\ls_UI\\assets\\border-thin-tooltip")

LSM:Register("statusbar", "LS", "Interface\\AddOns\\ls_UI\\assets\\statusbar-texture")
