local _, CONFIG = ...

-- Lua
local _G = getfenv(0)
local loadstring = _G.loadstring
local next = _G.next
local pcall = _G.pcall
local rawset = _G.rawset
local s_trim = _G.string.trim
local t_concat = _G.table.concat
local t_insert = _G.table.insert
local t_sort = _G.table.sort
local t_wipe = _G.table.wipe
local tonumber = _G.tonumber
local tostring = _G.tostring
local unpack = _G.unpack

-- Libs
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

-- Mine
local E, M, L, C, D, PrC, PrD, P, oUF = unpack(ls_UI)

local orders = {}

local function reset(order)
	orders[order] = 1
	return orders[order]
end

local function inc(order)
	orders[order] = orders[order] + 1
	return orders[order]
end

local function isDefaultTag(info)
	return D.global.tags[info[#info - 1]]
end

local validator = CreateFrame("Frame")
local function isEventStringValid(eventString)
	local badEvents = {}

	for event in eventString:gmatch('%S+') do
		if not pcall(validator.RegisterEvent, validator, event) then
			t_insert(badEvents, "|cffffffff" .. event .. "|r")
		end
	end

	return #badEvents > 0 and L["INVALID_EVENTS_ERR"]:format(t_concat(badEvents, ", ")) or true
end

local function validateEvents(_, value)
	CONFIG:SetStatusText("")
	return isEventStringValid(value)
end

local function isVarStringValid(varString)
	if tonumber(varString) then
		return true
	else
		local _, err = loadstring("return " .. varString)
		return err and L["LUA_ERROR"]:format("|cffffffff" .. err .. "|r") or true
	end
end

local function validateVar(_, value)
	CONFIG:SetStatusText("")
	return isVarStringValid(value)
end

local function isFuncStringValid(funcString)
	local _, err = loadstring("return " .. funcString)
	return err and L["LUA_ERROR"]:format("|cffffffff" .. err .. "|r") or true
end

local function validateFunc(_, value)
	CONFIG:SetStatusText("")
	return isFuncStringValid(value)
end

local updateTagsOptions

local curTagOptions = {
	name = {
		order = reset(1),
		type = "input",
		width = "full",
		name = L["NAME"],
		disabled = isDefaultTag,
		validate = function(info, value)
			value = s_trim(value):gsub("\124\124", "\124")

			CONFIG:SetStatusText("")
			return (value ~= info[#info - 1] and oUF.Tags.Methods[value]) and L["NAME_TAKEN_ERR"] or true
		end,
		get = function(info)
			return info[#info - 1]:gsub("\124", "\124\124")
		end,
		set = function(info, value)
			value = s_trim(value):gsub("\124\124", "\124")
			if value ~= "" and value ~= info[#info - 1] then
				if not C.db.global.tags[value] then
					C.db.global.tags[value] = C.db.global.tags[info[#info - 1]]
					C.db.global.tags[info[#info - 1]] = nil

					oUF.Tags.Events[value] = C.db.global.tags[value].events
					oUF.Tags.Events[info[#info - 1]] = nil

					rawset(oUF.Tags.Vars, info[#info - 1], nil)
					oUF.Tags.Vars[value] = C.db.global.tags[value].vars

					rawset(oUF.Tags.Methods, info[#info - 1], nil)
					oUF.Tags.Methods[value] = C.db.global.tags[value].func

					updateTagsOptions()

					AceConfigDialog:SelectGroup("ls_UI", "general", "tags", value)
				end
			end
		end,
	},
	events = {
		order = inc(1),
		type = "input",
		width = "full",
		name = L["EVENTS"],
		validate = validateEvents,
		set = function(info, value)
			value = s_trim(value)
			if C.db.global.tags[info[#info - 1]].events ~= value then
				if value ~= "" then
					C.db.global.tags[info[#info - 1]].events = value
					oUF.Tags.Events[info[#info - 1]] = value
				else
					C.db.global.tags[info[#info - 1]].events = nil
					oUF.Tags.Events[info[#info - 1]] = nil
				end

				oUF.Tags:RefreshEvents(info[#info - 1])
			end
		end,
	},
	vars = {
		order = inc(1),
		type = "input",
		width = "full",
		name = L["VAR"],
		multiline = 8,
		disabled = isDefaultTag,
		validate = validateVar,
		set = function(info, value)
			value = tonumber(value) or s_trim(value):gsub("\124\124", "\124")
			if C.db.global.tags[info[#info - 1]].vars ~= value then
				rawset(oUF.Tags.Vars, info[#info - 1], nil)

				if value ~= "" then
					C.db.global.tags[info[#info - 1]].vars = value
					oUF.Tags.Vars[info[#info - 1]] = value
				else
					C.db.global.tags[info[#info - 1]].vars = nil
				end
			end
		end,
	},
	func = {
		order = inc(1),
		type = "input",
		width = "full",
		name = L["FUNC"],
		multiline = 16,
		validate = validateFunc,
		set = function(info, value)
			value = s_trim(value):gsub("\124\124", "\124")
			if C.db.global.tags[info[#info - 1]].func ~= value then
				C.db.global.tags[info[#info - 1]].func = value

				rawset(oUF.Tags.Methods, info[#info - 1], nil)
				oUF.Tags.Methods[info[#info - 1]] = value

				oUF.Tags:RefreshMethods(info[#info - 1])
			end
		end,
	},
	delete = {
		order = inc(1),
		type = "execute",
		name = L["DELETE"],
		width = "full",
		hidden = isDefaultTag,
		confirm = function(info)
			return L["CONFIRM_DELETE"]:format(info[#info - 1])
		end,
		func = function(info)
			C.db.global.tags[info[#info - 1]] = nil
			oUF.Tags.Events[info[#info - 1]] = nil
			rawset(oUF.Tags.Vars, info[#info - 1], nil)
			rawset(oUF.Tags.Methods, info[#info - 1], nil)

			updateTagsOptions()

			AceConfigDialog:SelectGroup("ls_UI", "general", "tags")
		end,
	},
	reset = {
		type = "execute",
		order = inc(1),
		name = L["RESTORE_DEFAULTS"],
		width = "full",
		confirm = CONFIG.ConfirmReset,
		hidden = function(info)
			return not D.global.tags[info[#info - 1]]
		end,
		func = function(info)
			local tag = info[#info - 1]

			E:ReplaceTable(D.global.tags[tag], C.db.global.tags[tag])

			oUF.Tags.Events[tag] = nil
			rawset(oUF.Tags.Methods, tag, nil)

			if C.db.global.tags[tag].events then
				oUF.Tags.Events[tag] = C.db.global.tags[tag].events
				oUF.Tags:RefreshEvents(tag)
			end

			oUF.Tags.Methods[tag] = C.db.global.tags[tag].func
			oUF.Tags:RefreshMethods(tag)
		end,
	},
}

local newTagInfo = {
	name = "",
	events = "",
	vars = "",
	func = "",
}

local newTagOptions = {
	order = 1,
	type = "group",
	name = L["NEW"],
	get = function(info)
		return tostring(newTagInfo[info[#info]] or ""):gsub("\124", "\124\124")
	end,
	set = function(info, value)
		newTagInfo[info[#info]] = s_trim(value):gsub("\124\124", "\124")
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
				return oUF.Tags.Methods[value] and L["NAME_TAKEN_ERR"] or true
			end,
		},
		events = {
			order = inc(1),
			type = "input",
			width = "full",
			name = L["EVENTS"],
			validate = validateEvents,
		},
		vars = {
			order = inc(1),
			type = "input",
			width = "full",
			name = L["VAR"],
			multiline = 8,
			validate = validateVar,
			set = function(_, value)
				newTagInfo.vars = tonumber(value) or s_trim(value):gsub("\124\124", "\124")
			end,
		},
		func = {
			order = inc(1),
			type = "input",
			width = "full",
			name = L["FUNC"],
			multiline = 16,
			validate = validateFunc,
		},
		add = {
			order = inc(1),
			type = "execute",
			name = L["ADD"],
			width = "full",
			func = function()
				if newTagInfo.name ~= "" and newTagInfo.func ~= "" then
					C.db.global.tags[newTagInfo.name] = {}

					if newTagInfo.events ~= "" then
						C.db.global.tags[newTagInfo.name].events = newTagInfo.events
						oUF.Tags.Events[newTagInfo.name] = newTagInfo.events
					end

					if newTagInfo.vars ~= "" then
						C.db.global.tags[newTagInfo.name].vars = newTagInfo.vars
						oUF.Tags.Vars[newTagInfo.name] = newTagInfo.vars
					end

					C.db.global.tags[newTagInfo.name].func = newTagInfo.func
					oUF.Tags.Methods[newTagInfo.name] = newTagInfo.func

					updateTagsOptions()

					AceConfigDialog:SelectGroup("ls_UI", "general", "tags", newTagInfo.name)

					newTagInfo.name = ""
					newTagInfo.events = ""
					newTagInfo.vars = ""
					newTagInfo.func = ""
				end
			end,
		},
	},
}

local tagOptions = {}

function updateTagsOptions()
	local options = CONFIG.options.args.general.args.tags.args
	t_wipe(options)

	local order = {}

	options.new = newTagOptions

	for tag in next, C.db.global.tags do
		if not tagOptions[tag] then
			tagOptions[tag] = {
				type = "group",
				name = tag,
				args = curTagOptions,
			}
		end

		options[tag] = tagOptions[tag]

		t_insert(order, tag)
	end

	t_sort(order)

	for i, tag in next, order do
		if options[tag] then
			options[tag].order = 1 + i
		end
	end
end

function CONFIG:GetTagsOptions(order)
	self.options.args.general.args.tags = {
		order = order,
		type = "group",
		childGroups = "tree",
		name = L["TAGS"],
		get = function(info)
			return tostring(C.db.global.tags[info[#info - 1]][info[#info]] or ""):gsub("\124", "\124\124")
		end,
		args = {},
	}

	updateTagsOptions()
end
