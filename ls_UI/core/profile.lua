local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF

-- Lua
local _G = getfenv(0)
local ipairs = _G.ipairs
local loadstring = _G.loadstring
local next = _G.next
local pcall = _G.pcall
local s_format = _G.string.format
local s_rep = _G.string.rep
local t_insert = _G.table.insert
local t_sort = _G.table.sort
local t_wipe = _G.table.wipe
local tonumber = _G.tonumber
local tostring = _G.tostring
local type = _G.type

-- Mine
local LibDeflate = LibStub("LibDeflate")
local LibSerialize = LibStub("LibSerialize")

local profileTypeToDataType = {
	["global-colors"] = "global",
	["global-tags"] = "global",
	["private"] = "private",
	["profile"] = "profile",
}

local function getProfileData(profileType)
	if not profileType or type(profileType) ~= "string" then
		return
	end

	local data = {}

	if profileType == "global-colors" then
		data.colors = {}

		E:CopyTable(C.db.global.colors, data.colors)

		data.colors.power[ 0] = nil
		data.colors.power[ 1] = nil
		data.colors.power[ 2] = nil
		data.colors.power[ 3] = nil
		data.colors.power[ 4] = nil
		data.colors.power[ 5] = nil
		data.colors.power[ 6] = nil
		data.colors.power[ 7] = nil
		data.colors.power[ 8] = nil
		data.colors.power[ 9] = nil
		data.colors.power[10] = nil
		data.colors.power[11] = nil
		data.colors.power[13] = nil
		data.colors.power[17] = nil
		data.colors.power[18] = nil
		data.colors.power[19] = nil

		E:DiffTable(D.global, data)
	elseif profileType == "global-tags" then
		data.tags = {}
		E:CopyTable(C.db.global.tags, data.tags)

		data.tag_vars = {}
		E:CopyTable(C.db.global.tag_vars, data.tag_vars)

		E:DiffTable(D.global, data)
	elseif profileType == "profile" then
		E.Movers:SaveConfig()

		E:CopyTable(C.db.profile, data)

		data.version = nil

		E:DiffTable(D.profile, data)
	elseif profileType == "private" then
		E:CopyTable(PrC.db.profile, data)

		data.version = nil

		E:DiffTable(PrD.profile, data)
	end

	return data
end

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

-- Credit goes to Mirrored (WeakAuras) and Simpy (ElvUI)
local function stringify(tbl, level, ret)
	local keys = {}
	for i in next, tbl do
		t_insert(keys, i)
	end
	t_sort(keys, keySort)

	for _, i in ipairs(keys) do
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
			ret = stringify(v, level + 1, ret)
			ret = ret .. s_rep('    ', level) .. '},\n'
		else
			ret = ret .. '"' .. tostring(v) .. '",\n'
		end
	end

	return ret
end

local function tableToString(tbl)
	return stringify(tbl, 1, "{\n") .. "}"
end

local function stringToTable(str)
	return pcall(loadstring("return " .. str:gsub("\124\124", "\124")))
end

E.Profiles = {}

function E.Profiles:Decode(data, dataFormat)
	if dataFormat == "string" then
		local decoded = LibDeflate:DecodeForPrint(data)
		if not decoded then return end

		local decompressed = LibDeflate:DecompressDeflate(decoded)
		if not decompressed then return end

		local isOK, rawData = LibSerialize:Deserialize(decompressed)
		if isOK then
			return rawData
		end
	elseif dataFormat == "table" then
		local isOK, rawData = stringToTable(data)
		if isOK then
			return rawData
		end
	end
end

function E.Profiles:Encode(data, dataFormat)
	if dataFormat == "string" then
		local serialized = LibSerialize:Serialize(data)
		local compressed = LibDeflate:CompressDeflate(serialized, {level = 9})

		return LibDeflate:EncodeForPrint(compressed)
	elseif dataFormat == "table" then
		return tableToString(data)
	end
end

function E.Profiles:Recode(data, newFormat)
	local version, profileType, curFormat, profileData = data:match("::lsui:(%d-):([%a\\-]-):(%a-):(.-)::")
	if not (version or profileType or curFormat or profileData) then return end

	profileData = self:Decode(profileData, curFormat)
	if not profileData then return end

	local header = s_format("::lsui:%s:%s:%s:", version, profileType, newFormat)

	-- "Stringified" tables can have other issues aside from the data itself,
	-- for instance, indentation or the order of subtables/elements, re-encoding
	-- them fixes such discrepancies which makes checking for dupes a lot easier
	-- There's probably no need to re-encode strings, but might as well do it
	profileData = self:Encode(profileData, newFormat)

	return header .. profileData .. "::"
end

function E.Profiles:Export(profileType, exportFormat)
	local header = s_format("::lsui:%s:%s:%s:", E.VER.number, profileType, exportFormat)
	local profileData = getProfileData(profileType)
	profileData = self:Encode(profileData, exportFormat)

	return header .. profileData .. "::"
end

function E.Profiles:Import(data, overwrite)
	local version, profileType, importFormat, profileData = data:match("::lsui:(%d-):([%a\\-]-):(%a-):(.-)::")
	if not (version or profileType or importFormat or profileData) then return end

	profileData = self:Decode(profileData, importFormat)
	profileData.version = tonumber(version)

	if profileData.version < E.VER.number then
		P:Modernize(profileData, "Imported Data", profileTypeToDataType[profileType])

		profileData.version = E.VER.number
	end

	if profileType == "profile" then
		if overwrite then
			C.db:DeleteProfile("LSUI_TEMP_PROFILE", true)

			C.db.profiles["LSUI_TEMP_PROFILE"] = profileData

			C.db:CopyProfile("LSUI_TEMP_PROFILE")
			C.db:DeleteProfile("LSUI_TEMP_PROFILE")

			return C.db:GetCurrentProfile(), profileType
		else
			-- 100 should be enough, right? RIGHT?
			local name
			for i = 1, 100 do
				name = "Imported Profile #" .. i
				if not C.db.profiles[name] then
					C.db.profiles[name] = profileData

					break
				end
			end

			return name, profileType
		end
	elseif profileType == "global-colors" then
		t_wipe(C.db.global.colors)
		E:CopyTable(D.global.colors, C.db.global.colors)

		E:CopyTable(profileData, C.db.global)

		return nil, profileType
	elseif profileType == "global-tags" then
		t_wipe(C.db.global.tags)
		E:CopyTable(D.global.tags, C.db.global.tags)

		t_wipe(C.db.global.tag_vars)
		E:CopyTable(D.global.tag_vars, C.db.global.tag_vars)

		E:CopyTable(profileData, C.db.global)

		return nil, profileType
	elseif profileType == "private" then
		if overwrite then
			PrC.db:DeleteProfile("LSUI_TEMP_PROFILE", true)

			PrC.db.profiles["LSUI_TEMP_PROFILE"] = profileData

			PrC.db:CopyProfile("LSUI_TEMP_PROFILE")
			PrC.db:DeleteProfile("LSUI_TEMP_PROFILE")

			return PrC.db:GetCurrentProfile(), profileType
		else
			-- 100 should be enough, right? RIGHT?
			local name
			for i = 1, 100 do
				name = "Imported Profile #" .. i
				if not PrC.db.profiles[name] then
					PrC.db.profiles[name] = profileData

					break
				end
			end

			return name, profileType
		end
	end
end
