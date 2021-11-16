local addonName, ns = ...
local E, C, D, M, L, P = ns.E, ns.C, ns.D, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)
local next = _G.next

--[[ luacheck: globals
	AdiButtonAuras hooksecurefunc LibStub MaxDps MinimapButtonFrame
]]

-- Mine
local function cleanUpStep1()
	-- -> 90105.04
	if C.db.profile.version and C.db.profile.version < 9010504 then
		if C.db.profile.units.ls then
			for _, unit in next, {"player", "pet"} do
				if C.db.profile.units.ls[unit] then
					if C.db.profile.units.ls[unit].point then
						C.db.profile.units.ls[unit].point.ls = nil
						C.db.profile.units.ls[unit].point.traditional = nil
					end

					E:CopyTable(C.db.profile.units.ls[unit], C.db.profile.units.round[unit])
					C.db.profile.units.ls[unit] = nil
				end
			end

			C.db.profile.units.ls = nil
		end

		if C.db.profile.units.traditional then
			for _, unit in next, {"player", "pet"} do
				if C.db.profile.units.traditional[unit] then
					if C.db.profile.units.traditional[unit].point then
						C.db.profile.units.traditional[unit].point.ls = nil
						C.db.profile.units.traditional[unit].point.traditional = nil
					end

					E:CopyTable(C.db.profile.units.traditional[unit], C.db.profile.units.rect[unit])
					C.db.profile.units.traditional[unit] = nil
				end
			end

			C.db.profile.units.traditional = nil
		end

		if C.db.profile.movers.ls then
			E:CopyTable(C.db.profile.movers.ls, C.db.profile.movers.round)
			C.db.profile.movers.ls = nil
		end

		if C.db.profile.movers.traditional then
			E:CopyTable(C.db.profile.movers.traditional, C.db.profile.movers.rect)
			C.db.profile.movers.traditional = nil
		end

		if C.db.profile.minimap.ls then
			E:CopyTable(C.db.profile.minimap.ls, C.db.profile.minimap.round)
			C.db.profile.minimap.ls = nil
		end

		if C.db.profile.minimap.traditional then
			E:CopyTable(C.db.profile.minimap.traditional, C.db.profile.minimap.rect)
			C.db.profile.minimap.traditional = nil
		end

		if C.db.char.minimap.ls then
			E:CopyTable(C.db.char.minimap.ls, C.db.char.minimap.round)
			C.db.char.minimap.ls = nil
		end

		if C.db.char.minimap.traditional then
			E:CopyTable(C.db.char.minimap.traditional, C.db.char.minimap.rect)
			C.db.char.minimap.traditional = nil
		end
	end
end

local function cleanUpStep2()
end

local function addRefs()
	C.db.profile.units.player = C.db.profile.units[E.UI_LAYOUT].player
	C.db.profile.units.pet = C.db.profile.units[E.UI_LAYOUT].pet

	C.db.global.colors.power[ 0] = C.db.global.colors.power.MANA
	C.db.global.colors.power[ 1] = C.db.global.colors.power.RAGE
	C.db.global.colors.power[ 2] = C.db.global.colors.power.FOCUS
	C.db.global.colors.power[ 3] = C.db.global.colors.power.ENERGY
	C.db.global.colors.power[ 4] = C.db.global.colors.power.CHI
	C.db.global.colors.power[ 5] = C.db.global.colors.power.RUNES
	C.db.global.colors.power[ 6] = C.db.global.colors.power.RUNIC_POWER
	C.db.global.colors.power[ 7] = C.db.global.colors.power.SOUL_SHARDS
	C.db.global.colors.power[ 8] = C.db.global.colors.power.LUNAR_POWER
	C.db.global.colors.power[ 9] = C.db.global.colors.power.HOLY_POWER
	C.db.global.colors.power[10] = C.db.global.colors.power.ALTERNATE
	C.db.global.colors.power[11] = C.db.global.colors.power.MAELSTROM
	C.db.global.colors.power[13] = C.db.global.colors.power.INSANITY
	C.db.global.colors.power[17] = C.db.global.colors.power.FURY
	C.db.global.colors.power[18] = C.db.global.colors.power.PAIN
end

local function removeRefs()
	C.db.profile.units.player = nil
	C.db.profile.units.pet = nil

	C.db.global.colors.power[ 0] = nil
	C.db.global.colors.power[ 1] = nil
	C.db.global.colors.power[ 2] = nil
	C.db.global.colors.power[ 3] = nil
	C.db.global.colors.power[ 4] = nil
	C.db.global.colors.power[ 5] = nil
	C.db.global.colors.power[ 6] = nil
	C.db.global.colors.power[ 7] = nil
	C.db.global.colors.power[ 8] = nil
	C.db.global.colors.power[ 9] = nil
	C.db.global.colors.power[10] = nil
	C.db.global.colors.power[11] = nil
	C.db.global.colors.power[13] = nil
	C.db.global.colors.power[17] = nil
	C.db.global.colors.power[18] = nil
end

local function updateAll()
	cleanUpStep1()
	addRefs()
	cleanUpStep2()

	P:UpdateModules()
	E.Movers:UpdateConfig()
end

E:RegisterEvent("ADDON_LOADED", function(arg1)
	if arg1 ~= addonName then return end

	C.db = LibStub("AceDB-3.0"):New("LS_UI_GLOBAL_CONFIG", D)
	LibStub("LibDualSpec-1.0"):EnhanceDatabase(C.db, "LS_UI_GLOBAL_CONFIG")

	-- -> 90105.04
	if C.db.char.layout == "ls" then
		C.db.char.layout = "round"
	elseif C.db.char.layout == "traditional" then
		C.db.char.layout = "rect"
	end

	-- layout type change shouldn't affect anything after SVs are loaded
	E.UI_LAYOUT = C.db.char.layout

	D.profile.units.player = D.profile.units[E.UI_LAYOUT].player
	D.profile.units.pet = D.profile.units[E.UI_LAYOUT].pet

	cleanUpStep1()
	addRefs()
	cleanUpStep2()

	if AdiButtonAuras and AdiButtonAuras.RegisterLAB then
		AdiButtonAuras:RegisterLAB("LibActionButton-1.0-ls")
	end

	if MaxDps then
		if MaxDps.RegisterLibActionButton then
			MaxDps:RegisterLibActionButton("LibActionButton-1.0-ls")
		else
			local LAB = LibStub("LibActionButton-1.0-ls")

			if MaxDps.FetchLibActionButton then
				hooksecurefunc(MaxDps, "FetchLibActionButton", function(self)
					for button in next, LAB:GetAllButtons() do
						self:AddButton(button:GetSpellId(), button)
					end
				end)
			end

			if MaxDps.UpdateButtonGlow then
				hooksecurefunc(MaxDps, "UpdateButtonGlow", function(self)
					if self.db.global.disableButtonGlow then
						LAB.eventFrame:UnregisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW")
					else
						LAB.eventFrame:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW")
					end
				end)
			end
		end
	end

	if MinimapButtonFrame then
		C.db.profile.minimap.collect.enabled = false
	end

	C.db:RegisterCallback("OnDatabaseShutdown", function()
		C.db.char.version = E.VER.number
		C.db.global.version = E.VER.number
		C.db.profile.version = E.VER.number

		removeRefs()

		E.Movers:CleanUpConfig()
	end)

	C.db:RegisterCallback("OnProfileShutdown", function()
		C.db.profile.version = E.VER.number

		removeRefs()

		E.Movers:CleanUpConfig()
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
