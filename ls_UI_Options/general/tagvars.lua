-- Lua
local _G = getfenv(0)
local loadstring = _G.loadstring
local next = _G.next
local rawset = _G.rawset
local s_trim = _G.string.trim
local t_insert = _G.table.insert
local t_sort = _G.table.sort
local t_wipe = _G.table.wipe
local tonumber = _G.tonumber
local tostring = _G.tostring
local unpack = _G.unpack

-- Libs
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

-- Mine
local E, M, L, C, D, PrC, PrD, P, oUF, CONFIG = unpack(ls_UI)

local orders = {}

local function reset(order)
	orders[order] = 1
	return orders[order]
end

local function inc(order)
	orders[order] = orders[order] + 1
	return orders[order]
end

local function isDefaultVar(info)
	return D.global.tag_vars[info[#info - 1]]
end

local function isVarStringValid(varString)
	if tonumber(varString) then
		return true
	else
		local _, err = loadstring("return " .. varString)
		return err and L["LUA_ERROR_TEMPLATE"]:format("|cffffffff" .. err .. "|r") or true
	end
end

local function validateVar(_, value)
	CONFIG:SetStatusText("")
	return isVarStringValid(value)
end

local updateVarsOptions

local curVarOptions = {
	name = {
		order = reset(1),
		type = "input",
		width = "full",
		name = L["NAME"],
		disabled = isDefaultVar,
		validate = function(info, value)
			value = s_trim(value):gsub("\124\124", "\124")

			CONFIG:SetStatusText("")
			return (value ~= info[#info - 1] and oUF.Tags.Vars[value]) and L["NAME_TAKEN_ERR"] or true
		end,
		get = function(info)
			return info[#info - 1]:gsub("\124", "\124\124")
		end,
		set = function(info, value)
			value = s_trim(value):gsub("\124\124", "\124")
			if value ~= "" and value ~= info[#info - 1] then
				if not C.db.global.tag_vars[value] then
					C.db.global.tag_vars[value] = C.db.global.tag_vars[info[#info - 1]]
					C.db.global.tag_vars[info[#info - 1]] = nil

					oUF.Tags.Vars[value] = C.db.global.tag_vars[value].vars
					rawset(oUF.Tags.Vars, info[#info - 1], nil)

					updateVarsOptions()

					AceConfigDialog:SelectGroup("ls_UI", "general", "tag_vars", value)
				end
			end
		end,
	},
	value = {
		order = inc(1),
		type = "input",
		width = "full",
		name = L["VALUE"],
		multiline = 16,
		disabled = isDefaultVar,
		validate = validateVar,
		get = function(info)
			return tostring(C.db.global.tag_vars[info[#info - 1]] or ""):gsub("\124", "\124\124")
		end,
		set = function(info, value)
			value = tonumber(value) or s_trim(value):gsub("\124\124", "\124")
			if C.db.global.tag_vars[info[#info - 1]] ~= value then
				rawset(oUF.Tags.Vars, info[#info - 1], nil)

				if value ~= "" then
					C.db.global.tag_vars[info[#info - 1]] = value
					oUF.Tags.Vars[info[#info - 1]] = value
				else
					C.db.global.tag_vars[info[#info - 1]] = nil
				end
			end
		end,
	},
	delete = {
		order = inc(1),
		type = "execute",
		name = L["DELETE"],
		width = "full",
		disabled = isDefaultVar,
		confirm = function(info)
			return L["CONFIRM_DELETE"]:format(info[#info - 1])
		end,
		func = function(info)
			C.db.global.tag_vars[info[#info - 1]] = nil
			rawset(oUF.Tags.Vars, info[#info - 1], nil)

			updateVarsOptions()

			AceConfigDialog:SelectGroup("ls_UI", "general", "tag_vars")
		end,
	},
}

local newVarInfo = {
	name = "",
	value = "",
}

local newVarOptions = {
	order = 1,
	type = "group",
	name = L["NEW"],
	get = function(info)
		return tostring(newVarInfo[info[#info]] or ""):gsub("\124", "\124\124")
	end,
	args = {
		name = {
			order = reset(1),
			type = "input",
			width = "full",
			name = L["NAME"],
			validate = function(_, value)
				value = s_trim(value):gsub("\124\124", "\124")

				CONFIG:SetStatusText("")
				return oUF.Tags.Vars[value] and L["NAME_TAKEN_ERR"] or true
			end,
			set = function(_, value)
				newVarInfo.name = s_trim(value):gsub("\124\124", "\124")
			end,
		},
		value = {
			order = inc(1),
			type = "input",
			width = "full",
			name = L["VALUE"],
			multiline = 16,
			validate = validateVar,
			set = function(_, value)
				newVarInfo.value = tonumber(value) or s_trim(value):gsub("\124\124", "\124")
			end,
		},
		add = {
			order = inc(1),
			type = "execute",
			name = L["ADD"],
			width = "full",
			func = function()
				if newVarInfo.name ~= "" then
					C.db.global.tag_vars[newVarInfo.name] = newVarInfo.value

					oUF.Tags.Vars[newVarInfo.name] = newVarInfo.value

					updateVarsOptions()

					AceConfigDialog:SelectGroup("ls_UI", "general", "tag_vars", newVarInfo.name)

					newVarInfo.name = ""
					newVarInfo.value = ""
				end
			end,
		},
	},
}

local varsOptions = {}

function updateVarsOptions()
	local options = CONFIG.options.args.general.args.tag_vars.args
	t_wipe(options)

	local order = {}

	options.new = newVarOptions

	for var in next, C.db.global.tag_vars do
		if not varsOptions[var] then
			varsOptions[var] = {
				type = "group",
				name = var,
				args = curVarOptions,
			}
		end

		options[var] = varsOptions[var]

		t_insert(order, var)
	end

	t_sort(order)

	for i, var in next, order do
		if options[var] then
			options[var].order = 1 + i
		end
	end
end

function CONFIG:GetTagVarsOptions(order)
	self.options.args.general.args.tag_vars = {
		order = order,
		type = "group",
		childGroups = "tree",
		name = L["TAG_VARS"],
		args = {},
	}

	updateVarsOptions()
end
