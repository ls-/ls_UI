local AddOn, ns = ...
ns.E, ns.D, ns.M, ns.L = CreateFrame("Frame"), {}, {}, {} -- engine(event handler), defaults, media, locales
-- ns.C is created on ADDON_LOADED, see core.lua

SLASH_RELOADUI1 = "/rl"
SlashCmdList.RELOADUI = ReloadUI