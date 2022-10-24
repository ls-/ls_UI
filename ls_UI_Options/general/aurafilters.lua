local _, CONFIG = ...

-- Lua
local _G = getfenv(0)
local next = _G.next
local s_trim = _G.string.trim
local t_insert = _G.table.insert
local t_sort = _G.table.sort
local t_wipe = _G.table.wipe
local unpack = _G.unpack

-- Libs
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

-- Mine
local E, M, L, C, D, PrC, PrD, P, oUF = unpack(ls_UI)
local FILTERS = P:GetModule("Filters")
local UNITFRAMES = P:GetModule("UnitFrames")

local orders = {}

local function reset(order)
	orders[order] = 1
	return orders[order]
end

local function inc(order)
	orders[order] = orders[order] + 1
	return orders[order]
end

local function isDefaultFilter(info)
	return D.global.aura_filters[info[#info - 1]]
end

local units = {"player", "target", "focus", "boss"}

local function callback()
	for _, unit in next, units do
		UNITFRAMES:For(unit, "For", "Auras", "UpdateConfig")
		UNITFRAMES:For(unit, "For", "Auras", "ForceUpdate")
	end

	if not InCombatLockdown() then
		AceConfigDialog:Open("ls_UI")
	end
end

local updateFiltersOptions

local curFilterOptions = {
	name = {
		order = reset(1),
		type = "input",
		width = "full",
		name = L["NAME"],
		disabled = isDefaultFilter,
		validate = function(info, value)
			value = s_trim(value):gsub("\124\124", "\124")

			CONFIG:SetStatusText("")
			return (value ~= info[#info - 1] and C.db.global.aura_filters[value]) and L["NAME_TAKEN_ERR"] or true
		end,
		get = function(info)
			return info[#info - 1]:gsub("\124", "\124\124")
		end,
		set = function(info, value)
			value = s_trim(value):gsub("\124\124", "\124")
			if value ~= "" and value ~= info[#info - 1] then
				if not C.db.global.aura_filters[value] then
					C.db.global.aura_filters[value] = C.db.global.aura_filters[info[#info - 1]]
					C.db.global.aura_filters[info[#info - 1]] = nil

					for _, unit in next, units do
						if C.db.profile.units[unit].auras then
							if C.db.profile.units[unit].auras.filter.custom[info[#info - 1]] then
								C.db.profile.units[unit].auras.filter.custom[value] = C.db.profile.units[unit].auras.filter.custom[info[#info - 1]]
								C.db.profile.units[unit].auras.filter.custom[info[#info - 1]] = nil
							end
						end
					end

					CONFIG:UpdateUnitFrameAuraFilters()
					updateFiltersOptions()

					AceConfigDialog:SelectGroup("ls_UI", "general", "aura_filters", value)
				end
			end
		end,
	},
	state = {
		order = inc(1),
		type = "toggle",
		name = L["BLACKLIST"],
		disabled = isDefaultFilter,
		get = function(info)
			return not C.db.global.aura_filters[info[#info - 1]].state
		end,
		set = function(info, value)
			C.db.global.aura_filters[info[#info - 1]].state = not value
		end,
	},
	settings = {
		type = "execute",
		order = inc(1),
		name = L["FILTER_SETTINGS"],
		width = "full",
		func = function(info)
			AceConfigDialog:Close("ls_UI")
			GameTooltip:Hide()

			CONFIG:OpenAuraConfig(info[#info - 1], C.db.global.aura_filters[info[#info - 1]], nil, nil, callback, not not D.global.aura_filters[info[#info - 1]])
		end,
	},
	delete = {
		order = inc(1),
		type = "execute",
		name = L["DELETE"],
		width = "full",
		hidden = isDefaultFilter,
		confirm = function(info)
			return L["CONFIRM_DELETE"]:format(info[#info - 1])
		end,
		func = function(info)
			C.db.global.aura_filters[info[#info - 1]] = nil

			for _, unit in next, units do
				if C.db.profile.units[unit].auras then
					C.db.profile.units[unit].auras.filter.custom[info[#info - 1]] = nil
				end
			end

			for _, unit in next, units do
				UNITFRAMES:For(unit, "For", "Auras", "UpdateConfig")
				UNITFRAMES:For(unit, "For", "Auras", "ForceUpdate")
			end

			CONFIG:UpdateUnitFrameAuraFilters()
			updateFiltersOptions()

			AceConfigDialog:SelectGroup("ls_UI", "general", "aura_filters")
		end,
	},
}

local newFilterInfo = {
	name = "",
	state = false,
}

local newFilterOptions = {
	order = 1,
	type = "group",
	name = L["NEW"],
	args = {
		name = {
			order = reset(1),
			type = "input",
			width = "full",
			name = L["NAME"],
			validate = function(_, value)
				value = s_trim(value):gsub("\124\124", "\124")

				CONFIG:SetStatusText("")
				return C.db.global.aura_filters[value] and L["NAME_TAKEN_ERR"] or true
			end,
			get = function(info)
				return newFilterInfo[info[#info]]:gsub("\124", "\124\124")
			end,
			set = function(_, value)
				newFilterInfo.name = s_trim(value):gsub("\124\124", "\124")
			end,
		},
		state = {
			order = inc(1),
			type = "toggle",
			name = L["BLACKLIST"],
			get = function()
				return not newFilterInfo.state
			end,
			set = function(_, value)
				newFilterInfo.state = not value
			end,
		},
		add = {
			order = inc(1),
			type = "execute",
			name = L["ADD"],
			width = "full",
			func = function()
				if newFilterInfo.name ~= "" then
					C.db.global.aura_filters[newFilterInfo.name] = {
						state = newFilterInfo.state
					}

					CONFIG:UpdateUnitFrameAuraFilters()
					updateFiltersOptions()

					AceConfigDialog:SelectGroup("ls_UI", "general", "aura_filters", newFilterInfo.name)

					newFilterInfo.name = ""
					newFilterInfo.state = false
				end
			end,
		},
	},
}

local filtersOptions = {}

function updateFiltersOptions()
	local options = CONFIG.options.args.general.args.aura_filters.args
	t_wipe(options)

	local order = {}

	options.new = newFilterOptions

	for filter in next, C.db.global.aura_filters do
		if not filtersOptions[filter] then
			filtersOptions[filter] = {
				type = "group",
				name = filter,
				args = curFilterOptions,
			}
		end

		options[filter] = filtersOptions[filter]

		t_insert(order, filter)
	end

	t_sort(order)

	for i, filter in next, order do
		if options[filter] then
			options[filter].order = 1 + i
		end
	end
end

function CONFIG:GetAuraFiltersOptions(order)
	self.options.args.general.args.aura_filters = {
		order = order,
		type = "group",
		childGroups = "tree",
		name = L["AURA_FILTERS"],
		args = {},
	}

	updateFiltersOptions()
end
