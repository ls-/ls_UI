local addonName, ns = ...
local E, C, D, M, L, P = ns.E, ns.C, ns.D, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)
local type = _G.type
local next = _G.next

--[[ luacheck: globals
	LibStub
]]

-- Mine
local function cleanUpProfile()
	-- -> 80000.03
	if not C.db.profile.version or C.db.profile.version < 8000003 then
		C.db.profile.movers.ls.LSMicroMenu = nil
		C.db.profile.movers.traditional.LSMicroMenu = nil

		C.db.profile.bars.micromenu.bags = nil
		C.db.profile.bars.micromenu.height = nil
		C.db.profile.bars.micromenu.menu1 = nil
		C.db.profile.bars.micromenu.menu2 = nil
		C.db.profile.bars.micromenu.num = nil
		C.db.profile.bars.micromenu.per_row = nil
		C.db.profile.bars.micromenu.point = nil
		C.db.profile.bars.micromenu.spacing = nil
		C.db.profile.bars.micromenu.tooltip = nil
		C.db.profile.bars.micromenu.width = nil
		C.db.profile.bars.micromenu.x_growth = nil
		C.db.profile.bars.micromenu.y_growth = nil

		C.db.char.bars.bags = nil
		C.db.profile.bars.bags = nil
	end

	-- -> 80000.04
	if not C.db.profile.version or C.db.profile.version < 8000004 then
		C.db.profile.bars.micromenu.bars.micromenu1.fade = nil
		C.db.profile.bars.micromenu.bars.micromenu1.visible = nil
		C.db.profile.bars.micromenu.bars.micromenu2.fade = nil
		C.db.profile.bars.micromenu.bars.micromenu2.visible = nil
		C.db.profile.bars.micromenu.bars.bags.fade = nil
		C.db.profile.bars.micromenu.bars.bags.visible = nil

		if C.db.profile.auras[E.UI_LAYOUT] then
			if C.db.profile.auras[E.UI_LAYOUT].HELPFUL then
				E:CopyTable(C.db.profile.auras[E.UI_LAYOUT].HELPFUL, C.db.profile.auras.HELPFUL)
			end

			if C.db.profile.auras[E.UI_LAYOUT].HARMFUL then
				E:CopyTable(C.db.profile.auras[E.UI_LAYOUT].HARMFUL, C.db.profile.auras.HARMFUL)
			end

			if C.db.profile.auras[E.UI_LAYOUT].TOTEM then
				E:CopyTable(C.db.profile.auras[E.UI_LAYOUT].TOTEM, C.db.profile.auras.TOTEM)
			end
		end

		C.db.profile.auras.ls = nil
		C.db.profile.auras.traditional = nil
	end

	-- -> 80000.05
	if not C.db.profile.version or C.db.profile.version < 8000005 then
		C.db.profile.bars.desaturate_on_cd = nil
		C.db.profile.bars.desaturate_when_unusable = nil
	end
end

local function updateAll()
	cleanUpProfile()
	P:UpdateModules()
	P.Movers:UpdateConfig()
end

E:RegisterEvent("ADDON_LOADED", function(arg1)
	if arg1 ~= addonName then return end

	C.db = LibStub("AceDB-3.0"):New("LS_UI_GLOBAL_CONFIG", D)
	LibStub("LibDualSpec-1.0"):EnhanceDatabase(C.db, "LS_UI_GLOBAL_CONFIG")

	-- layout type change shouldn't affect anything after SVs are loaded
	E.UI_LAYOUT = C.db.char.layout

	cleanUpProfile()

	C.db:RegisterCallback("OnDatabaseShutdown", function()
		C.db.char.version = E.VER.number
		C.db.profile.version = E.VER.number

		P.Movers:CleanUpConfig()
	end)

	C.db:RegisterCallback("OnProfileShutdown", function()
		C.db.profile.version = E.VER.number

		P.Movers:CleanUpConfig()
	end)

	C.db:RegisterCallback("OnProfileChanged", updateAll)
	C.db:RegisterCallback("OnProfileCopied", updateAll)
	C.db:RegisterCallback("OnProfileReset", updateAll)

	E:RegisterEvent("PLAYER_LOGIN", function()
		E:UpdateConstants()

		P:InitModules()
	end)

	-- No one needs to see these
	ns.C, ns.D, ns.L, ns.P = nil, nil, nil, nil
end)
