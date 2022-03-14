local _, ns = ...
local E, C, PrC, M, L, P, D, PrD = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD

-- Lua
local _G = getfenv(0)
local ipairs = _G.ipairs
local loadstring = _G.loadstring
local next = _G.next
local pcall = _G.pcall
local s_rep = _G.string.rep
local t_insert = _G.table.insert
local t_sort = _G.table.sort
local tostring = _G.tostring
local type = _G.type

-- Mine
local LibDeflate = LibStub("LibDeflate")
local LibSerialize = LibStub("LibSerialize")

local TEST_TABLE = "!LSUI:global:table!{\n    [\"global\"] = {\n        [\"fonts\"] = {\n            [\"button\"] = {\n                [\"font\"] = \"Noto Sans SemiBold\",\n            },\n            [\"cooldown\"] = {\n                [\"font\"] = \"Noto Sans SemiBold\",\n            },\n            [\"statusbar\"] = {\n                [\"font\"] = \"Noto Sans SemiBold\",\n            },\n            [\"unit\"] = {\n                [\"font\"] = \"Noto Sans SemiBold\",\n            },\n        },\n        [\"version\"] = 9020002,\n    },\n    [\"profile\"] = {\n        [\"bars\"] = {\n            [\"bar2\"] = {\n                [\"fade\"] = {\n                    [\"combat\"] = true,\n                    [\"enabled\"] = true,\n                    [\"ooc\"] = true,\n                },\n            },\n            [\"bar4\"] = {\n                [\"fade\"] = {\n                    [\"ooc\"] = true,\n                },\n            },\n            [\"bar5\"] = {\n                [\"fade\"] = {\n                    [\"enabled\"] = true,\n                    [\"min_alpha\"] = 0.15,\n                    [\"ooc\"] = true,\n                },\n            },\n            [\"micromenu\"] = {\n                [\"fade\"] = {\n                    [\"enabled\"] = true,\n                    [\"ooc\"] = true,\n                },\n            },\n        },\n        [\"minimap\"] = {\n            [\"buttons\"] = {\n                [\"GameTimeFrame\"] = 45.674015787002,\n                [\"GarrisonLandingPageMinimapButton\"] = 235.71311008564,\n                [\"MiniMapMailFrame\"] = 151.69912001079,\n            },\n            [\"collect\"] = {\n                [\"enabled\"] = false,\n            },\n        },\n        [\"movers\"] = {\n            [\"rect\"] = {\n                [\"LSAuraTrackerHeaderMover\"] = {\n                    [1] = \"BOTTOMLEFT\",\n                    [3] = \"BOTTOMLEFT\",\n                    [4] = 530,\n                    [5] = 507,\n                },\n                [\"LSOTFrameHolderMover\"] = {\n                    [4] = -249,\n                    [5] = -229,\n                },\n            },\n            [\"round\"] = {\n                [\"LSActionBar5Mover\"] = {\n                    [1] = \"TOPRIGHT\",\n                    [3] = \"TOPRIGHT\",\n                    [5] = -384,\n                },\n                [\"LSAuraTrackerHeaderMover\"] = {\n                    [1] = \"TOP\",\n                    [3] = \"TOP\",\n                    [4] = -110,\n                    [5] = -435,\n                },\n                [\"LSOTFrameHolderMover\"] = {\n                    [4] = -351,\n                    [5] = -161,\n                },\n                [\"LSPetFrameCastbarHolderMover\"] = {\n                    [2] = \"UIParent\",\n                    [3] = \"BOTTOM\",\n                    [5] = 208,\n                },\n            },\n        },\n        [\"units\"] = {\n            [\"cooldown\"] = {\n                [\"exp_threshold\"] = 10,\n                [\"m_ss_threshold\"] = 91,\n                [\"s_ms_threshold\"] = 10,\n            },\n            [\"focus\"] = {\n                [\"fade\"] = {\n                    [\"combat\"] = true,\n                    [\"enabled\"] = true,\n                    [\"target\"] = true,\n                },\n            },\n            [\"rect\"] = {\n                [\"player\"] = {\n                    [\"auras\"] = {\n                        [\"enabled\"] = true,\n                    },\n                },\n            },\n            [\"round\"] = {\n                [\"pet\"] = {\n                    [\"fade\"] = {\n                        [\"ooc\"] = true,\n                    },\n                },\n                [\"player\"] = {\n                    [\"fade\"] = {\n                        [\"combat\"] = true,\n                        [\"enabled\"] = true,\n                        [\"ooc\"] = true,\n                        [\"target\"] = true,\n                    },\n                },\n            },\n        },\n        [\"version\"] = 9020002,\n    },\n}"
local TEST_STRING = "!LSUI:global:string!njvmVnnquyHi00utlqvIvqujcsipbOsejsiHqfd4Kkf3eLyycP43zFjXc77oD35cSMnw6qNzQ)gqI)digoYa)a6mSYed8CsbLf779DFF37DF33LCKcjFssk91dZzjALNRKgPTjIu4duP9qixckBjLbKuAC4Wj8OCLT7eiM22SrijINraDirdYPuD4qjpNf70uq12MnTBY5rHMs4spKSPsOz7qZwHZJ480y(7yTppBSsnwptsvZqOVCUAC2A11wqFVyTs5XuPkHZQ)XZiKmErLJ5YoIQ9g1pWtcz0UinQ0VylNkF6AwVzhr9EJEgElcKq0BPYUu4Feo5m3(bb9979sVGYg7k39owF(2glpXnqfrASpUGS1sQhnpO)GHh2PlsSU1vRBQDstePS5Mv(5gwp5wI96nAavVCeEoO0eqU2K0UmzvNUY8xD4aaDtTvPTnvDQ8NAw7TLlYgnE8Bt0PA)FNQaP1fiNMLWgdPIzWGs7)Gh2c3gHIK8mklh54uOALKhv484AjkjjdeossUwZzQ2IR7Jq(GWhssxzxhq(949)1xxiA0bKYefN1dyXjSPdGPu)vhG7s5Dpi74V)TNU5lw0bfgKKrV4e8(HNZJRglJ4PPfzhZgZitt5ei1bJlmmtDQsd6CfoByYbre7EexZBmcyQgJOzjUOvrwnK2M7zUVzNL)ClsKRa2T4f)V"

local function getProfileData(profileType)
	if not profileType or type(profileType) ~= "string" then
		return
	end

	local data = {
		profile = {},
	}

	if profileType == "global" then
		E.Movers:SaveConfig()

		E:CopyTable(C.db.profile, data.profile)

		data.profile.units.player = nil
		data.profile.units.pet = nil

		-- ? I'm still not sure how I want to handle global data
		-- data.global = {}

		-- E:CopyTable(C.db.global, data.global)

		-- data.global.colors.power[ 0] = nil
		-- data.global.colors.power[ 1] = nil
		-- data.global.colors.power[ 2] = nil
		-- data.global.colors.power[ 3] = nil
		-- data.global.colors.power[ 4] = nil
		-- data.global.colors.power[ 5] = nil
		-- data.global.colors.power[ 6] = nil
		-- data.global.colors.power[ 7] = nil
		-- data.global.colors.power[ 8] = nil
		-- data.global.colors.power[ 9] = nil
		-- data.global.colors.power[10] = nil
		-- data.global.colors.power[11] = nil
		-- data.global.colors.power[13] = nil
		-- data.global.colors.power[17] = nil
		-- data.global.colors.power[18] = nil

		-- data.global.aura_filters = nil

		E:DiffTable(D, data)
	elseif profileType == "private" then
		E:CopyTable(PrC.db.profile, data.profile)
		E:DiffTable(PrD, data)
	end

	return data
end

-- Credit goes to Mirrored (WeakAuras) and Simpy (ElvUI)
local tableToString
local function keySort(a, b)
	local A, B = type(a), type(b)

	if A == B then
		if A == "number" or A == "string" then
			return a < b
		elseif A == "boolean" then
			return (a and 1 or 0) > (b and 1 or 0)
		end
	end

	return A < B
end

local function recurse(tbl, level, ret)
	local tkeys = {}
	for i in next, tbl do
		t_insert(tkeys, i)
	end
	t_sort(tkeys, keySort)

	for _, i in ipairs(tkeys) do
		local v = tbl[i]

		ret = ret .. s_rep('    ', level) .. '['

		if type(i) == "string" then
			ret = ret .. '"' .. i .. '"'
		else
			ret = ret .. i
		end

		ret = ret .. '] = '

		if type(v) == "number" then
			ret = ret .. v .. ',\n'
		elseif type(v) == "string" then
			ret = ret .. '"' .. v:gsub('\\', '\\\\'):gsub('\n', '\\n'):gsub('"', '\\"'):gsub('\124', '\124\124') .. '",\n'
		elseif type(v) == "boolean" then
			if v then
				ret = ret .. 'true,\n'
			else
				ret = ret .. 'false,\n'
			end
		elseif type(v) == "table" then
			ret = ret .. '{\n'
			ret = recurse(v, level + 1, ret)
			ret = ret .. s_rep('    ', level) .. '},\n'
		else
			ret = ret .. '"' .. tostring(v) .. '",\n'
		end
	end

	return ret
end

function tableToString(tbl)
	return recurse(tbl, 1, "{\n") .. "}"
end

local EXPORT_HEADER_FORMAT = "!LSUI:%s:%s!"

local function exportProfile(profileType, exportFormat)
	local data = getProfileData(profileType)
	local encoded = EXPORT_HEADER_FORMAT:format(profileType, exportFormat)

	if exportFormat == "string" then
		local serialized = LibSerialize:Serialize(data)
		local compressed = LibDeflate:CompressDeflate(serialized, {level = 9})
		encoded = encoded .. LibDeflate:EncodeForPrint(compressed)
	elseif exportFormat == "table" then
		encoded = encoded .. tableToString(data)
	end

	print(encoded)

	return encoded
end

local function stringToTable(str)
	return pcall(loadstring("return " .. str:gsub("\124\124", "\124")))
end

local IMPORT_HEADER_FORMAT = "^!LSUI:(%a-):(%a-)!"

local function importProfile(data)
	local profileType, importFormat = data:match(IMPORT_HEADER_FORMAT)
	data = data:gsub("^!.-!", "")

	if importFormat == "string" then
		local decoded = LibDeflate:DecodeForPrint(data)
		if not decoded then return end

		local decompressed = LibDeflate:DecompressDeflate(decoded)
		if not decompressed then return end

		local isOK
		isOK, data = LibSerialize:Deserialize(decompressed)
		if not isOK then return end

		print("|cffff00d2DECODED!|r")
		-- DevTools_Dump(data)
	elseif importFormat == "table" then
		local isOK
		isOK, data = stringToTable(data)
		if not isOK then return end

		print("|cffff00d2DECODED!|r")
		-- DevTools_Dump(data)
	end

	if profileType == "global" then
		-- ? I'm still not sure how I want to handle global data
		-- E:CopyTable(data.global, C.db.global)

		C.db.profiles["LSUI_TEMP_PROFILE"] = data.profile

		C.db:CopyProfile("LSUI_TEMP_PROFILE")
		C.db:DeleteProfile("LSUI_TEMP_PROFILE")
	elseif profileType == "private" then
		-- E:CopyTable(data.profile, PrC.db.profile)
	end

	return data
end

-- C_Timer.After(5, function()
-- 	exportProfile("global", "string")
-- 	exportProfile("global", "table")
-- 	importProfile(TEST_STRING)
-- 	importProfile(TEST_TABLE)
-- end)
