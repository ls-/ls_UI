local name, ns = ...

-- Lua
local _G = getfenv(0)

-- Mine
local E = _G.LibStub("AceAddon-3.0"):NewAddon(name) -- engine
local C, D, M, L, P = {}, {}, {}, {}, {} -- config, defaults, media, locales, private
ns.E, ns.C, ns.D, ns.M, ns.L, ns.P = E, C, D, M, L, P

_G[name] = {
	[1] = ns.E,
	[2] = ns.L,
	[3] = ns.M,
	[4] = ns.C,
}

local function ConvertConfig(old, base)
	local temp = {}

	for k, v in next, base do
		if old[k] ~= nil then
			if type(v) == "table" then
				if next(v) then
					temp[k] = ConvertConfig(old[k], v)
				else
					temp[k] = old[k]
				end
			else
				if old[k] ~= v then
					temp[k] = old[k]
				end

				old[k] = nil
			end
		end
	end

	return temp
end

function E:OnInitialize()
	C.db = _G.LibStub("AceDB-3.0"):New("LS_UI_GLOBAL_CONFIG", D)
	_G.LibStub("LibDualSpec-1.0"):EnhanceDatabase(C.db, "LS_UI_GLOBAL_CONFIG")

	-- -> 70200.07
	-- old config conversion
	if _G.LS_UI_CONFIG then
		_G.LS_UI_CONFIG.version = nil

		self:CopyTable(ConvertConfig(_G.LS_UI_CONFIG, D.char), C.db.char)

		if _G.LS_UI_CONFIG.auras then
			self:CopyTable(ConvertConfig(_G.LS_UI_CONFIG.auras, D.profile.auras["**"]), C.db.profile.auras.ls)

			_G.LS_UI_CONFIG.auras = nil
		end

		if _G.LS_UI_CONFIG.units then
			self:CopyTable(ConvertConfig(_G.LS_UI_CONFIG.units, D.profile.units["**"]), C.db.profile.units.ls)

			_G.LS_UI_CONFIG.units = nil
		end

		if _G.LS_UI_CONFIG.minimap then
			self:CopyTable(ConvertConfig(_G.LS_UI_CONFIG.minimap, D.profile.minimap["**"]), C.db.profile.minimap.ls)

			_G.LS_UI_CONFIG.minimap = nil
		end

		if _G.LS_UI_CONFIG.movers then
			self:CopyTable(_G.LS_UI_CONFIG.movers, C.db.profile.movers.ls)

			_G.LS_UI_CONFIG.movers = nil
		end

		self:CopyTable(ConvertConfig(_G.LS_UI_CONFIG, D.profile), C.db.profile)
	end

	C.db:RegisterCallback("OnDatabaseShutdown", function()
		C.db.char.version = E.VER.number
		C.db.profile.version = E.VER.number

		E:CleanUpMoversConfig()
	end)

	self:RegisterEvent("PLAYER_LOGIN", function()
		E:UpdateConstants()

		P:InitModules()
	end)

	-- No one needs to see these
	ns.C, ns.D, ns.L, ns.P = nil, nil, nil, nil
end
