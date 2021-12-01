local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF = ns.E, ns.C, ns.RrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF
local BARS = P:GetModule("Bars")
local BLIZZARD = P:GetModule("Blizzard")
local CONFIG = P:GetModule("Config")
local FILTERS = P:GetModule("Filters")
local MINIMAP = P:GetModule("Minimap")
local UNITFRAMES = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)
local next = _G.next
local rawset = _G.rawset
local s_trim = _G.string.trim
local t_insert = _G.table.insert
local t_sort = _G.table.sort
local t_wipe = _G.table.wipe
local tonumber = _G.tonumber
local tostring = _G.tostring
local type = _G.type

--[[ luacheck: globals
	GameTooltip GetText InCombatLockdown LibStub UnitSex

	FACTION_STANDING_LABEL1 FACTION_STANDING_LABEL2 FACTION_STANDING_LABEL3 FACTION_STANDING_LABEL4
	FACTION_STANDING_LABEL5 FACTION_STANDING_LABEL6 FACTION_STANDING_LABEL7 FACTION_STANDING_LABEL8
]]

-- Mine
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local updateTagOptions
do
	local function isDefaultTag(info)
		return D.global.tags[info[#info - 1]]
	end

	local function validateTagEvents(_, value)
		CONFIG:SetStatusText("")
		return CONFIG:IsEventStringValid(value)
	end

	local function validateTagVars(_, value)
		CONFIG:SetStatusText("")
		return CONFIG:IsVarStringValid(value)
	end

	local function validateTagFunc(_, value)
		CONFIG:SetStatusText("")
		return CONFIG:IsFuncStringValid(value)
	end

	local curTagInfo = {
		name = {
			order = 1,
			type = "input",
			width = "full",
			name = L["NAME"],
			disabled = isDefaultTag,
			validate = function(info, value)
				value = s_trim(value):gsub("\124\124+", "\124")

				CONFIG:SetStatusText("")
				return (value ~= info[#info - 1] and oUF.Tags.Methods[value]) and L["NAME_TAKEN_ERR"] or true
			end,
			get = function(info)
				return info[#info - 1]
			end,
			set = function(info, value)
				value = s_trim(value):gsub("\124\124+", "\124")
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

						updateTagOptions()

						AceConfigDialog:SelectGroup("ls_UI", "general", "tags", value)
					end
				end
			end,
		},
		events = {
			order = 2,
			type = "input",
			width = "full",
			name = L["EVENTS"],
			validate = validateTagEvents,
			set = function(info, value)
				value = s_trim(value):gsub("\124\124+", "\124")
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
			order = 3,
			type = "input",
			width = "full",
			name = L["VAR"],
			multiline = 8,
			disabled = isDefaultTag,
			validate = validateTagVars,
			set = function(info, value)
				value = tonumber(value) or s_trim(value):gsub("\124\124+", "\124")
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
			order = 4,
			type = "input",
			width = "full",
			name = L["FUNC"],
			multiline = 16,
			validate = validateTagFunc,
			set = function(info, value)
				value = s_trim(value):gsub("\124\124+", "\124")
				if C.db.global.tags[info[#info - 1]].func ~= value then
					C.db.global.tags[info[#info - 1]].func = value

					rawset(oUF.Tags.Methods, info[#info - 1], nil)
					oUF.Tags.Methods[info[#info - 1]] = value

					oUF.Tags:RefreshMethods(info[#info - 1])
				end
			end,
		},
		delete = {
			order = 5,
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

				updateTagOptions()

				AceConfigDialog:SelectGroup("ls_UI", "general", "tags")
			end,
		},
		reset = {
			type = "execute",
			order = 6,
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

	local tagOptionTables = {
		new = {
			order = 1,
			type = "group",
			name = L["NEW"],
			get = function(info)
				return tostring(newTagInfo[info[#info]]):gsub("\124", "\124\124")
			end,
			set = function(info, value)
				newTagInfo[info[#info]] = s_trim(value):gsub("\124\124+", "\124")
			end,
			args = {
				name = {
					order = 1,
					type = "input",
					width = "full",
					name = L["NAME"],
					validate = function(_, value)
						value = s_trim(value):gsub("\124\124+", "\124")

						CONFIG:SetStatusText("")
						return oUF.Tags.Methods[value] and L["NAME_TAKEN_ERR"] or true
					end,
				},
				events = {
					order = 2,
					type = "input",
					width = "full",
					name = L["EVENTS"],
					validate = validateTagEvents,
				},
				vars = {
					order = 3,
					type = "input",
					width = "full",
					name = L["VAR"],
					multiline = 8,
					validate = validateTagVars,
					set = function(_, value)
						newTagInfo.vars = tonumber(value) or s_trim(value):gsub("\124\124+", "\124")
					end,
				},
				func = {
					order = 4,
					type = "input",
					width = "full",
					name = L["FUNC"],
					multiline = 16,
					validate = validateTagFunc,
				},
				add = {
					order = 5,
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

							updateTagOptions()

							AceConfigDialog:SelectGroup("ls_UI", "general", "tags", newTagInfo.name)

							newTagInfo.name = ""
							newTagInfo.events = ""
							newTagInfo.vars = ""
							newTagInfo.func = ""
						end
					end,
				},
			},
		},
	}

	local order = {}

	function updateTagOptions()
		local options = C.options.args.general.args.tags.args

		t_wipe(options)
		t_wipe(order)

		options.new = tagOptionTables.new

		for tag in next, C.db.global.tags do
			if not tagOptionTables[tag] then
				tagOptionTables[tag] = {
					type = "group",
					name = tag,
					args = curTagInfo,
				}
			end

			options[tag] = tagOptionTables[tag]

			t_insert(order, tag)
		end

		t_sort(order)

		for i, tag in next, order do
			if options[tag] then
				options[tag].order = i + 10
			end
		end
	end
end

local updateTagVarsOptions
do
	local function isDefaultTag(info)
		return D.global.tag_vars[info[#info - 1]]
	end

	local function validateTagVars(_, value)
		CONFIG:SetStatusText("")
		return CONFIG:IsVarStringValid(value)
	end

	local curVarInfo = {
		name = {
			order = 1,
			type = "input",
			width = "full",
			name = L["NAME"],
			disabled = isDefaultTag,
			validate = function(info, value)
				value = s_trim(value):gsub("\124\124+", "\124")

				CONFIG:SetStatusText("")
				return (value ~= info[#info - 1] and oUF.Tags.Vars[value]) and L["NAME_TAKEN_ERR"] or true
			end,
			get = function(info)
				return info[#info - 1]
			end,
			set = function(info, value)
				value = s_trim(value):gsub("\124\124+", "\124")
				if value ~= "" and value ~= info[#info - 1] then
					if not C.db.global.tag_vars[value] then
						C.db.global.tag_vars[value] = C.db.global.tag_vars[info[#info - 1]]
						C.db.global.tag_vars[info[#info - 1]] = nil

						oUF.Tags.Vars[value] = C.db.global.tag_vars[value].vars
						rawset(oUF.Tags.Vars, info[#info - 1], nil)

						updateTagVarsOptions()

						AceConfigDialog:SelectGroup("ls_UI", "general", "tag_vars", value)
					end
				end
			end,
		},
		value = {
			order = 2,
			type = "input",
			width = "full",
			name = L["VALUE"],
			multiline = 16,
			disabled = isDefaultTag,
			validate = validateTagVars,
			get = function(info)
				return tostring(C.db.global.tag_vars[info[#info - 1]]):gsub("\124", "\124\124")
			end,
			set = function(info, value)
				value = tonumber(value) or s_trim(value):gsub("\124\124+", "\124")
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
			order = 3,
			type = "execute",
			name = L["DELETE"],
			width = "full",
			disabled = isDefaultTag,
			confirm = function(info)
				return L["CONFIRM_DELETE"]:format(info[#info - 1])
			end,
			func = function(info)
				C.db.global.tag_vars[info[#info - 1]] = nil
				rawset(oUF.Tags.Vars, info[#info - 1], nil)

				updateTagVarsOptions()

				AceConfigDialog:SelectGroup("ls_UI", "general", "tag_vars")
			end,
		},
	}

	local newVarInfo = {
		name = "",
		value = "",
	}

	local varOptionTables = {
		new = {
			order = 1,
			type = "group",
			name = L["NEW"],
			get = function(info)
				return tostring(newVarInfo[info[#info]]):gsub("\124", "\124\124")
			end,
			args = {
				name = {
					order = 1,
					type = "input",
					width = "full",
					name = L["NAME"],
					validate = function(_, value)
						value = s_trim(value):gsub("\124\124+", "\124")

						CONFIG:SetStatusText("")
						return oUF.Tags.Vars[value] and L["NAME_TAKEN_ERR"] or true
					end,
					set = function(_, value)
						newVarInfo.name = s_trim(value):gsub("\124\124+", "\124")
					end,
				},
				value = {
					order = 3,
					type = "input",
					width = "full",
					name = L["VALUE"],
					multiline = 16,
					validate = validateTagVars,
					set = function(_, value)
						newVarInfo.value = tonumber(value) or s_trim(value):gsub("\124\124+", "\124")
					end,
				},
				add = {
					order = 5,
					type = "execute",
					name = L["ADD"],
					width = "full",
					func = function()
						if newVarInfo.name ~= "" then
							C.db.global.tag_vars[newVarInfo.name] = newVarInfo.value

							oUF.Tags.Vars[newVarInfo.name] = newVarInfo.value

							updateTagVarsOptions()

							AceConfigDialog:SelectGroup("ls_UI", "general", "tag_vars", newVarInfo.name)

							newVarInfo.name = ""
							newVarInfo.value = ""
						end
					end,
				},
			},
		},
	}

	local order = {}

	function updateTagVarsOptions()
		local options = C.options.args.general.args.tag_vars.args

		t_wipe(options)
		t_wipe(order)

		options.new = varOptionTables.new

		for var in next, C.db.global.tag_vars do
			if not varOptionTables[var] then
				varOptionTables[var] = {
					type = "group",
					name = var,
					args = curVarInfo,
				}
			end

			options[var] = varOptionTables[var]

			t_insert(order, var)
		end

		t_sort(order)

		for i, var in next, order do
			if options[var] then
				options[var].order = i + 10
			end
		end
	end
end

local updateAuraFiltersOptions
do
	local units = {"player", "target", "focus", "boss"}
	local curFilter

	local function isDefaultFilter(info)
		return D.global.aura_filters[info[#info - 1]]
	end

	local function callback()
		for _, unit in next, units do
			UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Auras", "UpdateConfig")
			UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Auras", "ForceUpdate")
		end

		if not InCombatLockdown() then
			AceConfigDialog:Open("ls_UI")
			AceConfigDialog:SelectGroup("ls_UI", "general", "aura_filters", curFilter)
		end

		curFilter = nil
	end

	local curFilterInfo = {
		name = {
			order = 1,
			type = "input",
			width = "full",
			name = L["NAME"],
			disabled = isDefaultFilter,
			validate = function(info, value)
				value = s_trim(value):gsub("\124\124+", "\124")

				CONFIG:SetStatusText("")
				return (value ~= info[#info - 1] and C.db.global.aura_filters[value]) and L["NAME_TAKEN_ERR"] or true
			end,
			get = function(info)
				return info[#info - 1]
			end,
			set = function(info, value)
				value = s_trim(value):gsub("\124\124+", "\124")
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

						CONFIG:CreateUnitFrameAuraFilters()
						updateTagVarsOptions()

						AceConfigDialog:SelectGroup("ls_UI", "general", "aura_filters", value)
					end
				end
			end,
		},
		state = {
			order = 2,
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
			order = 3,
			name = L["FILTER_SETTINGS"],
			width = "full",
			func = function(info)
				curFilter = info[#info - 1]

				AceConfigDialog:Close("ls_UI")
				GameTooltip:Hide()

				CONFIG:OpenAuraConfig(info[#info - 1], C.db.global.aura_filters[info[#info - 1]], nil, nil, callback)
			end,
		},
		delete = {
			order = 4,
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
					UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Auras", "UpdateConfig")
					UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Auras", "ForceUpdate")
				end

				CONFIG:CreateUnitFrameAuraFilters()
				updateAuraFiltersOptions()

				AceConfigDialog:SelectGroup("ls_UI", "general", "aura_filters")
			end,
		},
		reset = {
			type = "execute",
			order = 5,
			name = L["RESTORE_DEFAULTS"],
			width = "full",
			hidden = function(info)
				return not D.global.aura_filters[info[#info - 1]]
			end,
			confirm = CONFIG.ConfirmReset,
			func = function(info)
				FILTERS:Reset(info[#info - 1])

				for _, unit in next, units do
					UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Auras", "UpdateConfig")
					UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Auras", "ForceUpdate")
				end
			end,
		},
	}

	local newFilterInfo = {
		name = "",
		state = false,
	}

	local filterOptionTables = {
		new = {
			order = 1,
			type = "group",
			name = L["NEW"],
			args = {
				name = {
					order = 1,
					type = "input",
					width = "full",
					name = L["NAME"],
					validate = function(_, value)
						value = s_trim(value):gsub("\124\124+", "\124")

						CONFIG:SetStatusText("")
						return C.db.global.aura_filters[value] and L["NAME_TAKEN_ERR"] or true
					end,
					get = function(info)
						return tostring(newFilterInfo[info[#info]]):gsub("\124", "\124\124")
					end,
					set = function(_, value)
						newFilterInfo.name = s_trim(value):gsub("\124\124+", "\124")
					end,
				},
				state = {
					order = 2,
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
					order = 5,
					type = "execute",
					name = L["ADD"],
					width = "full",
					func = function()
						if newFilterInfo.name ~= "" then
							C.db.global.aura_filters[newFilterInfo.name] = {
								state = newFilterInfo.state
							}

							CONFIG:CreateUnitFrameAuraFilters()
							updateAuraFiltersOptions()

							AceConfigDialog:SelectGroup("ls_UI", "general", "aura_filters", newFilterInfo.name)

							newFilterInfo.name = ""
							newFilterInfo.state = false
						end
					end,
				},
			},
		},
	}

	local order = {}

	function updateAuraFiltersOptions()
		local options = C.options.args.general.args.aura_filters.args

		t_wipe(options)
		t_wipe(order)

		options.new = filterOptionTables.new

		for filter in next, C.db.global.aura_filters do
			if not filterOptionTables[filter] then
				filterOptionTables[filter] = {
					type = "group",
					name = filter,
					args = curFilterInfo,
				}
			end

			options[filter] = filterOptionTables[filter]

			t_insert(order, filter)
		end

		t_sort(order)

		for i, filter in next, order do
			if options[filter] then
				options[filter].order = i + 10
			end
		end
	end
end

function CONFIG:CreateGeneralPanel(order)
	C.options.args.general = {
		order = order,
		type = "group",
		childGroups = "tab",
		name = L["GENERAL"],
		args = {
			colors = {
				order = 1,
				type = "group",
				childGroups = "tree",
				name = L["COLORS"],
				get = function(info)
					return E:GetRGB(C.db.global.colors[info[#info]])
				end,
				args = {
					health = {
						order = 1,
						type = "group",
						name = L["HEALTH"],
						set = function(info, r, g, b)
							if r ~= nil then
								info = info[#info]

								local color = C.db.global.colors[info]
								if color.r ~= r or color.g ~= g or color.g ~= b then
									E:SetRGB(color, r, g, b)

									UNITFRAMES:UpdateHealthColors()
									UNITFRAMES:ForEach("ForElement", "Health", "UpdateColors")
									UNITFRAMES:ForEach("ForElement", "Health", "UpdateTags")
								end
							end
						end,
						args = {
							reset = {
								type = "execute",
								order = 1,
								name = L["RESTORE_DEFAULTS"],
								confirm = CONFIG.ConfirmReset,
								func = function()
									E:SetRGB(C.db.global.colors.health, E:GetRGB(D.global.colors.health))
									E:SetRGB(C.db.global.colors.disconnected, E:GetRGB(D.global.colors.disconnected))
									E:SetRGB(C.db.global.colors.tapped, E:GetRGB(D.global.colors.tapped))

									UNITFRAMES:UpdateHealthColors()
									UNITFRAMES:ForEach("ForElement", "Health", "UpdateColors")
									UNITFRAMES:ForEach("ForElement", "Health", "UpdateTags")
								end,
							},
							spacer_1 = {
								order = 9,
								type = "description",
								name = " ",
							},
							health = {
								order = 10,
								type = "color",
								name = L["HEALTH"],
							},
							disconnected = {
								order = 11,
								type = "color",
								name = L["OFFLINE"],
							},
							tapped = {
								order = 12,
								type = "color",
								name = L["TAPPED"],
							},
						},
					},
					power = {
						order = 2,
						type = "group",
						name = L["POWER"],
						get = function(info)
							return E:GetRGB(C.db.global.colors.power[info[#info]])
						end,
						set = function(info, r, g, b)
							if r ~= nil then
								info = info[#info]

								local color
								if info == "RUNES_BLOOD" then
									color = C.db.global.colors.rune[1]
								elseif info == "RUNES_FROST" then
									color = C.db.global.colors.rune[2]
								elseif info == "RUNES_UNHOLY" then
									color = C.db.global.colors.rune[3]
								elseif info == "STAGGER_LOW" then
									color = C.db.global.colors.power.STAGGER[1]
								elseif info == "STAGGER_MEDIUM" then
									color = C.db.global.colors.power.STAGGER[2]
								elseif info == "STAGGER_HIGH" then
									color = C.db.global.colors.power.STAGGER[3]
								else
									color = C.db.global.colors.power[info]
								end

								if color.r ~= r or color.g ~= g or color.g ~= b then
									E:SetRGB(color, r, g, b)

									UNITFRAMES:UpdatePowerColors()
									UNITFRAMES:ForEach("ForElement", "AdditionalPower", "UpdateColors")
									UNITFRAMES:ForEach("ForElement", "AlternativePower", "UpdateColors")
									UNITFRAMES:ForEach("ForElement", "Power", "UpdateColors")
									UNITFRAMES:ForEach("ForElement", "ClassPower", "UpdateColors")
									UNITFRAMES:ForEach("ForElement", "Runes", "UpdateColors")
									UNITFRAMES:ForEach("ForElement", "Stagger", "UpdateColors")
									UNITFRAMES:ForEach("ForElement", "AlternativePower", "UpdateTags")
									UNITFRAMES:ForEach("ForElement", "Power", "UpdateTags")
								end
							end
						end,
						args = {
							reset = {
								type = "execute",
								order = 1,
								name = L["RESTORE_DEFAULTS"],
								confirm = CONFIG.ConfirmReset,
								func = function()
									for k, v in next, D.global.colors.power do
										if type(k) == "string" then
											if type(v[1]) == "table" then
												for i, v_ in next, v do
													E:SetRGB(C.db.global.colors.power[k][i], E:GetRGB(v_))
												end
											else
												E:SetRGB(C.db.global.colors.power[k], E:GetRGB(v))
											end
										end
									end

									for k, v in next, D.global.colors.rune do
										E:SetRGB(C.db.global.colors.rune[k], E:GetRGB(v))
									end

									UNITFRAMES:UpdatePowerColors()
									UNITFRAMES:ForEach("ForElement", "AdditionalPower", "UpdateColors")
									UNITFRAMES:ForEach("ForElement", "AlternativePower", "UpdateColors")
									UNITFRAMES:ForEach("ForElement", "Power", "UpdateColors")
									UNITFRAMES:ForEach("ForElement", "ClassPower", "UpdateColors")
									UNITFRAMES:ForEach("ForElement", "Runes", "UpdateColors")
									UNITFRAMES:ForEach("ForElement", "Stagger", "UpdateColors")
									UNITFRAMES:ForEach("ForElement", "AlternativePower", "UpdateTags")
									UNITFRAMES:ForEach("ForElement", "Power", "UpdateTags")
								end,
							},
							spacer_1 = {
								order = 9,
								type = "description",
								name = " ",
							},
							MANA = {
								order = 10,
								type = "color",
								name = L["MANA"],
							},
							RAGE = {
								order = 11,
								type = "color",
								name = L["RAGE"],
							},
							FOCUS = {
								order = 12,
								type = "color",
								name = L["FOCUS"],
							},
							ENERGY = {
								order = 13,
								type = "color",
								name = L["ENERGY"],
							},
							COMBO_POINTS = {
								order = 14,
								type = "color",
								name = L["COMBO_POINTS"],
							},
							RUNES = {
								order = 15,
								type = "color",
								name = L["RUNES"],
							},
							RUNES_BLOOD = {
								order = 16,
								type = "color",
								name = L["RUNES_BLOOD"],
								get = function()
									return E:GetRGB(C.db.global.colors.rune[1])
								end,
							},
							RUNES_FROST = {
								order = 17,
								type = "color",
								name = L["RUNES_FROST"],
								get = function()
									return E:GetRGB(C.db.global.colors.rune[2])
								end,
							},
							RUNES_UNHOLY = {
								order = 18,
								type = "color",
								name = L["RUNES_UNHOLY"],
								get = function()
									return E:GetRGB(C.db.global.colors.rune[3])
								end,
							},
							RUNIC_POWER = {
								order = 19,
								type = "color",
								name = L["RUNIC_POWER"],
							},
							SOUL_SHARDS = {
								order = 20,
								type = "color",
								name = L["SOUL_SHARDS"],
							},
							LUNAR_POWER = {
								order = 21,
								type = "color",
								name = L["LUNAR_POWER"],
							},
							HOLY_POWER = {
								order = 22,
								type = "color",
								name = L["HOLY_POWER"],
							},
							ALTERNATE = {
								order = 23,
								type = "color",
								name = L["ALTERNATIVE_POWER"],
							},
							MAELSTROM = {
								order = 24,
								type = "color",
								name = L["MAELSTROM_POWER"],
							},
							INSANITY = {
								order = 25,
								type = "color",
								name = L["INSANITY"],
							},
							CHI = {
								order = 26,
								type = "color",
								name = L["CHI"],
							},
							ARCANE_CHARGES = {
								order = 27,
								type = "color",
								name = L["ARCANE_CHARGES"],
							},
							FURY = {
								order = 28,
								type = "color",
								name = L["FURY"],
							},
							PAIN = {
								order = 29,
								type = "color",
								name = L["PAIN"],
							},
							STAGGER_LOW = {
								order = 30,
								type = "color",
								name = L["STAGGER_LOW"],
								get = function()
									return E:GetRGB(C.db.global.colors.power.STAGGER[1])
								end,
							},
							STAGGER_MEDIUM = {
								order = 31,
								type = "color",
								name = L["STAGGER_MEDIUM"],
								get = function()
									return E:GetRGB(C.db.global.colors.power.STAGGER[2])
								end,
							},
							STAGGER_HIGH = {
								order = 32,
								type = "color",
								name = L["STAGGER_HIGH"],
								get = function()
									return E:GetRGB(C.db.global.colors.power.STAGGER[3])
								end,
							},
						},
					},
					change = {
						order = 3,
						type = "group",
						name = L["CHANGE"],
						set = function(info, r, g, b)
							if r ~= nil then
								local color = C.db.global.colors[info[#info]]
								if color.r ~= r or color.g ~= g or color.g ~= b then
									E:SetRGB(color, r, g, b)

									UNITFRAMES:ForEach("ForElement", "Health", "UpdateGainLossColors")
									UNITFRAMES:ForEach("ForElement", "AdditionalPower", "UpdateGainLossColors")
									UNITFRAMES:ForEach("ForElement", "AlternativePower", "UpdateGainLossColors")
									UNITFRAMES:ForEach("ForElement", "Power", "UpdateGainLossColors")
									UNITFRAMES:ForEach("ForElement", "Stagger", "UpdateGainLossColors")
								end
							end
						end,
						args = {
							reset = {
								type = "execute",
								order = 1,
								name = L["RESTORE_DEFAULTS"],
								confirm = CONFIG.ConfirmReset,
								func = function()
									E:SetRGB(C.db.global.colors.gain, E:GetRGB(D.global.colors.gain))
									E:SetRGB(C.db.global.colors.loss, E:GetRGB(D.global.colors.loss))

									UNITFRAMES:ForEach("ForElement", "Health", "UpdateGainLossColors")
									UNITFRAMES:ForEach("ForElement", "AdditionalPower", "UpdateGainLossColors")
									UNITFRAMES:ForEach("ForElement", "AlternativePower", "UpdateGainLossColors")
									UNITFRAMES:ForEach("ForElement", "Power", "UpdateGainLossColors")
									UNITFRAMES:ForEach("ForElement", "Stagger", "UpdateGainLossColors")
								end,
							},
							spacer_1 = {
								order = 9,
								type = "description",
								name = " ",
							},
							gain = {
								order = 10,
								type = "color",
								name = L["GAIN"]
							},
							loss = {
								order = 11,
								type = "color",
								name = L["LOSS"]
							},
						},
					},
					prediction = {
						order = 4,
						type = "group",
						name = L["PREDICTION"],
						get = function(info)
							return E:GetRGBA(C.db.global.colors.prediction[info[#info]])
						end,
						set = function(info, r, g, b)
							if r ~= nil then
								local color = C.db.global.colors.prediction[info[#info]]
								if color.r ~= r or color.g ~= g or color.g ~= b then
									E:SetRGB(color, r, g, b)

									UNITFRAMES:ForEach("ForElement", "HealthPrediction", "UpdateColors")
									UNITFRAMES:ForEach("ForElement", "PowerPrediction", "UpdateColors")
								end
							end
						end,
						args = {
							reset = {
								type = "execute",
								order = 1,
								name = L["RESTORE_DEFAULTS"],
								confirm = CONFIG.ConfirmReset,
								func = function()
									for k, v in next, D.global.colors.prediction do
										E:SetRGB(C.db.global.colors.prediction[k], E:GetRGB(v))
									end

									UNITFRAMES:ForEach("ForElement", "HealthPrediction", "UpdateColors")
									UNITFRAMES:ForEach("ForElement", "PowerPrediction", "UpdateColors")
								end,
							},
							spacer_1 = {
								order = 9,
								type = "description",
								name = " ",
							},
							my_heal = {
								order = 10,
								type = "color",
								name = L["YOUR_HEALING"],
								hasAlpha = true,
							},
							other_heal = {
								order = 11,
								type = "color",
								name = L["OTHERS_HEALING"],
								hasAlpha = true,
							},
							damage_absorb = {
								order = 12,
								type = "color",
								name = L["DAMAGE_ABSORB"],
								hasAlpha = true,
							},
							heal_absorb = {
								order = 13,
								type = "color",
								name = L["HEAL_ABSORB"],
								hasAlpha = true,
							},
							power_cost = {
								order = 14,
								type = "color",
								name = L["POWER_COST"],
								hasAlpha = true,
							},
						},
					},
					reaction = {
						order = 5,
						type = "group",
						name = L["REACTION"],
						get = function(info)
							return E:GetRGB(C.db.global.colors.reaction[tonumber(info[#info])])
						end,
						set = function(info, r, g, b)
							if r ~= nil then
								local color = C.db.global.colors.reaction[tonumber(info[#info])]
								if color.r ~= r or color.g ~= g or color.g ~= b then
									E:SetRGB(color, r, g, b)

									UNITFRAMES:UpdateReactionColors()
									UNITFRAMES:ForEach("ForElement", "Health", "UpdateColors")
									UNITFRAMES:ForEach("ForElement", "ClassIndicator", "ForceUpdate")
								end
							end
						end,
						args = {
							reset = {
								type = "execute",
								order = 1,
								name = L["RESTORE_DEFAULTS"],
								confirm = CONFIG.ConfirmReset,
								func = function()
									for k, v in next, D.global.colors.reaction do
										E:SetRGB(C.db.global.colors.reaction[k], E:GetRGB(v))
									end

									UNITFRAMES:UpdateReactionColors()
									UNITFRAMES:ForEach("ForElement", "Health", "UpdateColors")
									UNITFRAMES:ForEach("ForElement", "ClassIndicator", "ForceUpdate")
								end,
							},
							spacer_1 = {
								order = 9,
								type = "description",
								name = " ",
							},
							["1"] = {
								order = 10,
								type = "color",
								name = FACTION_STANDING_LABEL1,
							},
							["2"] = {
								order = 11,
								type = "color",
								name = FACTION_STANDING_LABEL2,
							},
							["3"] = {
								order = 12,
								type = "color",
								name = FACTION_STANDING_LABEL3,
							},
							["4"] = {
								order = 13,
								type = "color",
								name = FACTION_STANDING_LABEL4,
							},
							["5"] = {
								order = 14,
								type = "color",
								name = FACTION_STANDING_LABEL5,
							},
							["6"] = {
								order = 15,
								type = "color",
								name = FACTION_STANDING_LABEL6,
							},
							["7"] = {
								order = 16,
								type = "color",
								name = FACTION_STANDING_LABEL7,
							},
							["8"] = {
								order = 17,
								type = "color",
								name = FACTION_STANDING_LABEL8,
							},
						},
					},
					faction = {
						order = 6,
						type = "group",
						name = L["FACTION"],
						get = function(info)
							return E:GetRGB(C.db.global.colors.faction[info[#info]])
						end,
						set = function(info, r, g, b)
							if r ~= nil then
								local color = C.db.global.colors.faction[info[#info]]
								if color.r ~= r or color.g ~= g or color.g ~= b then
									E:SetRGB(color, r, g, b)

									if BARS:HasXPBar() then
										BARS:GetBar("xpbar"):UpdateSegments()
									end
								end
							end
						end,
						args = {
							reset = {
								type = "execute",
								order = 1,
								name = L["RESTORE_DEFAULTS"],
								confirm = CONFIG.ConfirmReset,
								func = function()
									for k, v in next, D.global.colors.faction do
										E:SetRGB(C.db.global.colors.faction[k], E:GetRGB(v))
									end

									if BARS:HasXPBar() then
										BARS:GetBar("xpbar"):UpdateSegments()
									end
								end,
							},
							spacer_1 = {
								order = 9,
								type = "description",
								name = " ",
							},
							Alliance = {
								order = 10,
								type = "color",
								name = L["FACTION_ALLIANCE"],
							},
							Horde = {
								order = 11,
								type = "color",
								name = L["FACTION_HORDE"],
							},
							Neutral = {
								order = 12,
								type = "color",
								name = L["FACTION_NEUTRAL"],
							},
						},
					},
					xp = {
						order = 7,
						type = "group",
						name = L["EXPERIENCE"],
						get = function(info)
							return E:GetRGB(C.db.global.colors.xp[tonumber(info[#info])])
						end,
						set = function(info, r, g, b)
							if r ~= nil then
								local color = C.db.global.colors.xp[tonumber(info[#info])]
								if color.r ~= r or color.g ~= g or color.g ~= b then
									E:SetRGB(color, r, g, b)

									if BARS:HasXPBar() then
										BARS:GetBar("xpbar"):UpdateSegments()
									end
								end
							end
						end,
						args = {
							reset = {
								type = "execute",
								order = 1,
								name = L["RESTORE_DEFAULTS"],
								confirm = CONFIG.ConfirmReset,
								func = function()
									for k, v in next, D.global.colors.xp do
										E:SetRGB(C.db.global.colors.xp[k], E:GetRGB(v))
									end

									E:SetRGB(C.db.global.colors.artifact, E:GetRGB(D.global.colors.artifact))
									E:SetRGB(C.db.global.colors.honor, E:GetRGB(D.global.colors.honor))

									if BARS:HasXPBar() then
										BARS:GetBar("xpbar"):UpdateSegments()
									end
								end,
							},
							spacer_1 = {
								order = 9,
								type = "description",
								name = " ",
							},
							["1"] = {
								order = 10,
								type = "color",
								name = L["EXPERIENCE_RESTED"],
							},
							["2"] = {
								order = 11,
								type = "color",
								name = L["EXPERIENCE_NORMAL"],
							},
							artifact = {
								order = 12,
								type = "color",
								name = L["ARTIFACT_POWER"],
								get = function()
									return E:GetRGB(C.db.global.colors.artifact)
								end,
								set = function(_, r, g, b)
									if r ~= nil then
										local color = C.db.global.colors.artifact
										if color.r ~= r or color.g ~= g or color.g ~= b then
											E:SetRGB(color, r, g, b)

											if BARS:HasXPBar() then
												BARS:GetBar("xpbar"):UpdateSegments()
											end
										end
									end
								end,
							},
							honor = {
								order = 13,
								type = "color",
								name = L["HONOR"],
								get = function()
									return E:GetRGB(C.db.global.colors.honor)
								end,
								set = function(_, r, g, b)
									if r ~= nil then
										local color = C.db.global.colors.honor
										if color.r ~= r or color.g ~= g or color.g ~= b then
											E:SetRGB(color, r, g, b)

											if BARS:HasXPBar() then
												BARS:GetBar("xpbar"):UpdateSegments()
											end
										end
									end
								end,
							},
						},
					},
					difficulty = {
						order = 8,
						type = "group",
						name = L["DIFFICULTY"],
						get = function(info)
							return E:GetRGB(C.db.global.colors.difficulty[info[#info]])
						end,
						set = function(info, r, g, b)
							if r ~= nil then
								local color = C.db.global.colors.difficulty[info[#info]]
								if color.r ~= r or color.g ~= g or color.g ~= b then
									E:SetRGB(color, r, g, b)
								end

								UNITFRAMES:ForEach("ForElement", "Name", "UpdateTags")
							end
						end,
						args = {
							reset = {
								type = "execute",
								order = 1,
								name = L["RESTORE_DEFAULTS"],
								confirm = CONFIG.ConfirmReset,
								func = function()
									for k, v in next, D.global.colors.difficulty do
										E:SetRGB(C.db.global.colors.difficulty[k], E:GetRGB(v))
									end

									UNITFRAMES:ForEach("ForElement", "Name", "UpdateTags")
								end,
							},
							spacer_1 = {
								order = 9,
								type = "description",
								name = " ",
							},
							trivial = {
								order = 10,
								type = "color",
								name = L["TRIVIAL"],
							},
							standard = {
								order = 11,
								type = "color",
								name = L["STANDARD"],
							},
							difficult = {
								order = 12,
								type = "color",
								name = L["DIFFICULT"],
							},
							very_difficult = {
								order = 13,
								type = "color",
								name = L["VERY_DIFFICULT"],
							},
							impossible = {
								order = 14,
								type = "color",
								name = L["IMPOSSIBLE"],
							},
						}
					},
					castbar = {
						order = 9,
						type = "group",
						name = L["CASTBAR"],
						get = function(info)
							return E:GetRGB(C.db.global.colors.castbar[info[#info]])
						end,
						set = function(info, r, g, b)
							if r ~= nil then
								local color = C.db.global.colors.castbar[info[#info]]
								if color.r ~= r or color.g ~= g or color.g ~= b then
									E:SetRGB(color, r, g, b)
								end

								BLIZZARD:UpdateCastBarColors()
							end
						end,
						args = {
							reset = {
								type = "execute",
								order = 1,
								name = L["RESTORE_DEFAULTS"],
								confirm = CONFIG.ConfirmReset,
								func = function()
									for k, v in next, D.global.colors.castbar do
										E:SetRGB(C.db.global.colors.castbar[k], E:GetRGB(v))
									end

									BLIZZARD:UpdateCastBarColors()
								end,
							},
							spacer_1 = {
								order = 9,
								type = "description",
								name = " ",
							},
							casting = {
								order = 10,
								type = "color",
								name = L["SPELL_CAST"],
							},
							channeling = {
								order = 11,
								type = "color",
								name = L["SPELL_CHANNELED"],
							},
							failed = {
								order = 12,
								type = "color",
								name = L["SPELL_FAILED"],
							},
							notinterruptible = {
								order = 13,
								type = "color",
								name = L["SPELL_UNINTERRUPTIBLE"],
							},
						},
					},
					aura = {
						order = 10,
						type = "group",
						name = L["AURA"],
						get = function(info)
							return E:GetRGB(C.db.global.colors.debuff[info[#info]])
						end,
						set = function(info, r, g, b)
							if r ~= nil then
								local color = C.db.global.colors.debuff[info[#info]]
								if color.r ~= r or color.g ~= g or color.g ~= b then
									E:SetRGB(color, r, g, b)
								end

								UNITFRAMES:ForEach("ForElement", "Auras", "UpdateColors")
							end
						end,
						args = {
							reset = {
								type = "execute",
								order = 1,
								name = L["RESTORE_DEFAULTS"],
								confirm = CONFIG.ConfirmReset,
								func = function()
									for k, v in next, D.global.colors.debuff do
										E:SetRGB(C.db.global.colors.debuff[k], E:GetRGB(v))
									end

									for k, v in next, D.global.colors.buff do
										E:SetRGB(C.db.global.colors.buff[k], E:GetRGB(v))
									end

									UNITFRAMES:ForEach("ForElement", "Auras", "UpdateColors")
								end,
							},
							spacer_1 = {
								order = 9,
								type = "description",
								name = " ",
							},
							None = {
								order = 10,
								type = "color",
								name = L["DEBUFF"],
							},
							Magic = {
								order = 11,
								type = "color",
								name = L["MAGIC"],
							},
							Curse = {
								order = 12,
								type = "color",
								name = L["CURSE"],
							},
							Disease = {
								order = 13,
								type = "color",
								name = L["DISEASE"],
							},
							Poison = {
								order = 14,
								type = "color",
								name = L["POISON"],
							},
							Enchant = {
								order = 15,
								type = "color",
								name = L["TEMP_ENCHANT"],
								get = function()
									return E:GetRGB(C.db.global.colors.buff.Enchant)
								end,
								set = function(_, r, g, b)
									if r ~= nil then
										local color = C.db.global.colors.buff.Enchant
										if color.r ~= r or color.g ~= g or color.g ~= b then
											E:SetRGB(color, r, g, b)
										end
									end
								end,
							},
						},
					},
					button = {
						order = 11,
						type = "group",
						name = L["BUTTON"],
						get = function(info)
							return E:GetRGB(C.db.global.colors.button[info[#info]])
						end,
						set = function(info, r, g, b)
							if r ~= nil then
								local color = C.db.global.colors.button[info[#info]]
								if color.r ~= r or color.g ~= g or color.g ~= b then
									E:SetRGB(color, r, g, b)
								end

								BARS:ForEach("UpdateButtonConfig")
							end
						end,
						args = {
							reset = {
								type = "execute",
								order = 1,
								name = L["RESTORE_DEFAULTS"],
								confirm = CONFIG.ConfirmReset,
								func = function()
									for k, v in next, D.global.colors.button do
										E:SetRGB(C.db.global.colors.button[k], E:GetRGB(v))
									end

									BARS:ForEach("UpdateButtonConfig")
								end,
							},
							spacer_1 = {
								order = 9,
								type = "description",
								name = " ",
							},
							normal = {
								order = 10,
								type = "color",
								name = L["USABLE"],
							},
							unusable = {
								order = 11,
								type = "color",
								name = L["UNUSABLE"],
							},
							mana = {
								order = 12,
								type = "color",
								name = L["OOM"],
							},
							range = {
								order = 13,
								type = "color",
								name = L["OOR"],
							},
						},
					},
					cooldown = {
						order = 12,
						type = "group",
						name = L["COOLDOWN"],
						get = function(info)
							return E:GetRGB(C.db.global.colors.cooldown[info[#info]])
						end,
						set = function(info, r,g, b)
							if r ~= nil then
								local color = C.db.global.colors.cooldown[info[#info]]
								if color.r ~= r or color.g ~= g or color.g ~= b then
									E:SetRGB(color, r, g, b)
								end
							end
						end,
						args = {
							reset = {
								type = "execute",
								order = 1,
								name = L["RESTORE_DEFAULTS"],
								confirm = CONFIG.ConfirmReset,
								func = function()
									for k, v in next, D.global.colors.cooldown do
										E:SetRGB(C.db.global.colors.cooldown[k], E:GetRGB(v))
									end
								end,
							},
							spacer_1 = {
								order = 9,
								type = "description",
								name = " ",
							},
							expiration = {
								order = 10,
								type = "color",
								name = L["EXPIRATION"],
							},
							second = {
								order = 11,
								type = "color",
								name = L["SECONDS"],
							},
							minute = {
								order = 12,
								type = "color",
								name = L["MINUTES"],
							},
							hour = {
								order = 13,
								type = "color",
								name = L["HOURS"],
							},
							day = {
								order = 14,
								type = "color",
								name = L["DAYS"],
							},
						},
					},
					zone = {
						order = 13,
						type = "group",
						name = L["ZONE"],
						get = function(info)
							return E:GetRGB(C.db.global.colors.zone[info[#info]])
						end,
						set = function(info, r, g, b)
							if r ~= nil then
								local color = C.db.global.colors.zone[info[#info]]
								if color.r ~= r or color.g ~= g or color.g ~= b then
									E:SetRGB(color, r, g, b)

									if MINIMAP:IsInit() then
										MINIMAP:GetMinimap():UpdateBorderColor()
										MINIMAP:GetMinimap():UpdateZoneColor()
									end
								end
							end
						end,
						args = {
							reset = {
								type = "execute",
								order = 1,
								name = L["RESTORE_DEFAULTS"],
								confirm = CONFIG.ConfirmReset,
								func = function()
									for k, v in next, D.global.colors.zone do
										E:SetRGB(C.db.global.colors.zone[k], E:GetRGB(v))
									end

									if MINIMAP:IsInit() then
										MINIMAP:GetMinimap():UpdateBorderColor()
										MINIMAP:GetMinimap():UpdateZoneColor()
									end
								end,
							},
							spacer_1 = {
								order = 9,
								type = "description",
								name = " ",
							},
							contested = {
								order = 10,
								type = "color",
								name = L["CONTESTED_TERRITORY"],
							},
							friendly = {
								order = 11,
								type = "color",
								name = L["FRIENDLY_TERRITORY"],
							},
							hostile = {
								order = 12,
								type = "color",
								name = L["HOSTILE_TERRITORY"],
							},
							sanctuary = {
								order = 13,
								type = "color",
								name = L["SANCTUARY"],
							},
						},
					},
				},
			},
			tags = {
				order = 3,
				type = "group",
				childGroups = "tree",
				name = L["TAGS"],
				get = function(info)
					return tostring(C.db.global.tags[info[#info - 1]][info[#info]] or ""):gsub("\124", "\124\124")
				end,
				args = {},
			},
			tag_vars = {
				order = 4,
				type = "group",
				childGroups = "tree",
				name = L["TAG_VARS"],
				args = {},
			},
			aura_filters = {
				order = 5,
				type = "group",
				childGroups = "tree",
				name = L["AURA_FILTERS"],
				args = {},
			},
		},
	}

	self:CreateGeneralFontsPanel(2)

	updateTagOptions()
	updateTagVarsOptions()
	updateAuraFiltersOptions()
end
