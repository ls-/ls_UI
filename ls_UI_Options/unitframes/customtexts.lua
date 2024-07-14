-- Lua
local _G = getfenv(0)
local next = _G.next
local s_trim = _G.string.trim
local t_insert = _G.table.insert
local t_sort = _G.table.sort
local t_wipe = _G.table.wipe
local unpack = _G.unpack

-- Libs
local ACD = LibStub("AceConfigDialog-3.0")

-- Mine
local E, M, L, C, D, PrC, PrD, P, oUF, CONFIG = unpack(ls_UI)
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

local updateOptions
do
	local ignoredAnchors = {
		["Health.Text"] = true,
		["Power"] = true,
		["Power.Text"] = true,
	}

	local curOptions = {
		enabled = {
			order = reset(2),
			type = "toggle",
			name = L["ENABLE"],
			set = function(info, value)
				if C.db.profile.units[info[#info - 3]].custom_texts[info[#info - 1]].enabled ~= value then
					C.db.profile.units[info[#info - 3]].custom_texts[info[#info - 1]].enabled = value

					UNITFRAMES:For(info[#info - 3], "For", "CustomTexts", "UpdateConfig", info[#info - 1])
					UNITFRAMES:For(info[#info - 3], "For", "CustomTexts", "UpdatePoint", info[#info - 1])
					UNITFRAMES:For(info[#info - 3], "For", "CustomTexts", "UpdateFonts", info[#info - 1])
					UNITFRAMES:For(info[#info - 3], "For", "CustomTexts", "UpdateTags", info[#info - 1])
				end
			end,
		},
		spacer_1 = CONFIG:CreateSpacer(inc(2)),
		size = {
			order = inc(2),
			type = "range",
			name = L["SIZE"],
			min = 8, max = 48, step = 1,
		},
		h_alignment = {
			order = inc(2),
			type = "select",
			name = L["TEXT_HORIZ_ALIGNMENT"],
			values = CONFIG.H_ALIGNMENTS,
		},
		spacer_2 = CONFIG:CreateSpacer(inc(2)),
		point1 = {
			order = inc(2),
			type = "group",
			name = "",
			inline = true,
			get = function(info)
				return C.db.profile.units[info[#info - 4]].custom_texts[info[#info - 2]].point1[info[#info]]
			end,
			set = function(info, value)
				if C.db.profile.units[info[#info - 4]].custom_texts[info[#info - 2]].point1[info[#info]] ~= value then
					C.db.profile.units[info[#info - 4]].custom_texts[info[#info - 2]].point1[info[#info]] = value

					UNITFRAMES:For(info[#info - 4], "For", "CustomTexts", "UpdateConfig", info[#info - 2])
					UNITFRAMES:For(info[#info - 4], "For", "CustomTexts", "UpdatePoint", info[#info - 2])
				end
			end,
			args = {
				p = {
					order = reset(3),
					type = "select",
					name = L["POINT"],
					desc = L["POINT_DESC"],
					values = CONFIG.POINTS,
				},
				anchor = {
					order = inc(3),
					type = "select",
					name = L["ANCHOR"],
					values = CONFIG:GetRegionAnchors(ignoredAnchors),
				},
				rP = {
					order = inc(3),
					type = "select",
					name = L["RELATIVE_POINT"],
					desc = L["RELATIVE_POINT_DESC"],
					values = CONFIG.POINTS,
				},
				x = {
					order = inc(3),
					type = "range",
					name = L["X_OFFSET"],
					min = -256, max = 256, step = 1,
				},
				y = {
					order = inc(3),
					type = "range",
					name = L["Y_OFFSET"],
					min = -256, max = 256, step = 1,
				},
			},
		},
		spacer_3 = CONFIG:CreateSpacer(inc(2)),
		tag = {
			order = inc(2),
			type = "input",
			width = "full",
			name = L["FORMAT"],
			get = function(info)
				return C.db.profile.units[info[#info - 3]].custom_texts[info[#info - 1]].tag:gsub("\124", "\124\124")
			end,
			set = function(info, value)
				value = value:gsub("\124\124+", "\124")
				if C.db.profile.units[info[#info - 3]].custom_texts[info[#info - 1]].tag ~= value then
					C.db.profile.units[info[#info - 3]].custom_texts[info[#info - 1]].tag = value

					UNITFRAMES:For(info[#info - 3], "For", "CustomTexts", "UpdateConfig", info[#info - 1])
					UNITFRAMES:For(info[#info - 3], "For", "CustomTexts", "UpdateTags", info[#info - 1])
				end
			end,
		},
		spacer_4 = CONFIG:CreateSpacer(inc(2)),
		delete = {
			order = inc(2),
			type = "execute",
			name = L["DELETE"],
			width = "full",
			confirm = function(info)
				return L["CONFIRM_DELETE"]:format(info[#info - 1])
			end,
			func = function(info)
				C.db.profile.units[info[#info - 3]].custom_texts[info[#info - 1]] = nil

				updateOptions(info[#info - 3])

				UNITFRAMES:For(info[#info - 3], "For", "CustomTexts", "UpdateConfig", info[#info - 1])
				UNITFRAMES:For(info[#info - 3], "For", "CustomTexts", "UpdatePoint", info[#info - 1])
				UNITFRAMES:For(info[#info - 3], "For", "CustomTexts", "UpdateFonts", info[#info - 1])
				UNITFRAMES:For(info[#info - 3], "For", "CustomTexts", "UpdateTags", info[#info - 1])

				ACD:SelectGroup("ls_UI", "unitframes", info[#info - 3], "custom_texts")
			end,
		},
	}

	local function curGetter(info)
		return C.db.profile.units[info[#info - 3]].custom_texts[info[#info - 1]][info[#info]]
	end

	local function curSetter(info, value)
		if C.db.profile.units[info[#info - 3]].custom_texts[info[#info - 1]][info[#info]] ~= value then
			C.db.profile.units[info[#info - 3]].custom_texts[info[#info - 1]][info[#info]] = value

			UNITFRAMES:For(info[#info - 3], "For", "CustomTexts", "UpdateConfig", info[#info - 1])
			UNITFRAMES:For(info[#info - 3], "For", "CustomTexts", "UpdateFonts", info[#info - 1])
		end
	end

	function updateOptions(unit)
		local options = t_wipe(CONFIG.options.args.unitframes.args[unit].args.custom_texts.plugins.texts)
		local order = {}

		for text in next, C.db.profile.units[unit].custom_texts do
			if not options[text] then
				options[text] = {
					type = "group",
					name = text,
					get = curGetter,
					set = curSetter,
					args = curOptions,
				}
			end

			t_insert(order, text)
		end

		t_sort(order)

		for i, text in next, order do
			if options[text] then
				options[text].order = 1 + i
			end
		end
	end
end

function CONFIG:CreateUnitFrameCustomTextsOptions(order, unit)
	local temp = {
		order = order,
		type = "group",
		childGroups = "tree",
		name = L["CUSTOM_TEXTS"],
		args = {
			new = {
				order = 1,
				type = "group",
				name = L["NEW"],
				args = {
					name = {
						order = reset(2),
						type = "input",
						width = "full",
						name = L["NAME"],
						validate = function(info, value)
							value = s_trim(value):gsub("\124\124+", "\124")
							if value ~= "" then
								CONFIG:SetStatusText("")

								return C.db.profile.units[info[#info - 3]].custom_texts[value] and L["NAME_TAKEN_ERR"] or true
							else
								return false
							end
						end,
						set = function(info, value)
							value = s_trim(value):gsub("\124\124+", "\124")

							C.db.profile.units[info[#info - 3]].custom_texts[value] = {
								enabled = true,
								size = 12,
								tag = "",
								h_alignment = "CENTER",
								v_alignment = "MIDDLE",
								point1 = {
									p = "CENTER",
									anchor = "",
									rP = "CENTER",
									x = 0,
									y = 0,
								},
							}

							updateOptions(info[#info - 3])

							UNITFRAMES:For(info[#info - 3], "For", "CustomTexts", "UpdateConfig", value)
							UNITFRAMES:For(info[#info - 3], "For", "CustomTexts", "UpdatePoint", value)
							UNITFRAMES:For(info[#info - 3], "For", "CustomTexts", "UpdateFonts", value)
							UNITFRAMES:For(info[#info - 3], "For", "CustomTexts", "UpdateTags", value)

							ACD:SelectGroup("ls_UI", "unitframes", info[#info - 3], "custom_texts", value)
						end,
					},
				},
			},
		},
		plugins = {
			texts = {},
		},
	}

	self:AddCallback(function()
		updateOptions(unit)
	end)

	return temp
end
