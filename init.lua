local AddOn, ns = ...
ns.E, ns.C, ns.D, ns.M, ns.L = CreateFrame("Frame"), {}, {}, {}, {} -- engine(event handler), config, defaults, media, locales

SLASH_RELOADUI1 = "/rl"
SlashCmdList.RELOADUI = ReloadUI