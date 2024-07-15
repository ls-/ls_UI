-- Lua
local _G = getfenv(0)
local s_split = _G.string.split
local unpack = _G.unpack

-- Mine
local E, M, L, C, D, PrC, PrD, P, oUF, CONFIG = unpack(ls_UI)
local BARS = P:GetModule("Bars")

local orders = {}

local function reset(order, v)
	orders[order] = v or 1
	return orders[order]
end

local function inc(order)
	orders[order] = orders[order] + 1
	return orders[order]
end

local GROWTH_DIRS = {
	["LEFT_DOWN"] = L["LEFT_DOWN"],
	["LEFT_UP"] = L["LEFT_UP"],
	["RIGHT_DOWN"] = L["RIGHT_DOWN"],
	["RIGHT_UP"] = L["RIGHT_UP"],
}

local FLYOUT_DIRS = {
	["UP"] = L["UP"],
	["DOWN"] = L["DOWN"],
	["LEFT"] = L["LEFT"],
	["RIGHT"] = L["RIGHT"],
}

local V_ALIGNMENTS = {
	["BOTTOM"] = "BOTTOM",
	["MIDDLE"] = "MIDDLE",
	["TOP"] = "TOP",
}

local function isModuleDisabled()
	return not BARS:IsInit()
end

local function isModuleDisabledOrRestricted()
	return BARS:IsRestricted() or not BARS:IsInit()
end

local function isPetBattleBarDisabledOrRestricted()
	return BARS:IsRestricted() or not BARS:HasPetBattleBar()
end

function CONFIG:CreateBarOptions(order, barID, name)
	local temp = {
		order = order,
		type = "group",
		childGroups = "select",
		name = name,
		disabled = isModuleDisabled,
		get = function(info)
			return C.db.profile.bars[barID][info[#info]]
		end,
		set = function(info, value)
			if C.db.profile.bars[barID][info[#info]] ~= value then
				C.db.profile.bars[barID][info[#info]] = value

				BARS:For(barID, "Update")
			end
		end,
		args = {
			reset = {
				type = "execute",
				order = reset(1, 2),
				name = L["RESTORE_DEFAULTS"],
				confirm = CONFIG.ConfirmReset,
				func = function()
					CONFIG:CopySettings(D.profile.bars[barID], C.db.profile.bars[barID], {visible = true, point = true})
					BARS:For(barID, "Update")
				end,
			},
			spacer_1 = CONFIG:CreateSpacer(inc(1)),
			visible = {
				order = inc(1),
				type = "toggle",
				name = L["SHOW"],
				set = function(_, value)
					C.db.profile.bars[barID].visible = value

					BARS:For(barID, "UpdateConfig")
					BARS:For(barID, "UpdateFading")
					BARS:For(barID, "UpdateVisibility")
				end
			},
			grid = {
				order = inc(1),
				type = "toggle",
				name = L["BUTTON_GRID"],
				set = function(_, value)
					C.db.profile.bars[barID].grid = value

					BARS:For(barID, "UpdateConfig")
					BARS:For(barID, "UpdateButtonConfig")
				end,
			},
			scale = {
				order = inc(1),
				type = "range",
				name = L["SCALE"],
				isPercent = true,
				min = 1, max = 2, step = 0.01, bigStep = 0.05,
			},
			num = {
				order = inc(1),
				type = "range",
				name = L["NUM_BUTTONS"],
				min = 1, max = 12, step = 1,
			},
			per_row = {
				order = inc(1),
				type = "range",
				name = L["PER_ROW"],
				min = 1, max = 12, step = 1,
			},
			x_spacing = {
				order = inc(1),
				type = "range",
				name = L["X_SPACING"],
				min = 4, max = 24, step = 1,
			},
			y_spacing = {
				order = inc(1),
				type = "range",
				name = L["Y_SPACING"],
				min = 4, max = 24, step = 1,
			},
			width = {
				order = inc(1),
				type = "range",
				name = L["WIDTH"],
				min = 8, max = 64, step = 1,
			},
			height = {
				order = inc(1),
				type = "range",
				name = L["HEIGHT"],
				desc = L["HEIGHT_OVERRIDE_DESC"],
				min = 0, max = 64, step = 1,
				softMin = 8,
				set = function(info, value)
					if C.db.profile.bars[barID].height ~= value then
						if value < info.option.softMin then
							value = info.option.min
						end

						C.db.profile.bars[barID].height = value

						BARS:For(barID, "Update")
					end
				end,
			},
			growth_dir = {
				order = inc(1),
				type = "select",
				name = L["GROWTH_DIR"],
				values = GROWTH_DIRS,
				get = function()
					return C.db.profile.bars[barID].x_growth .. "_" .. C.db.profile.bars[barID].y_growth
				end,
				set = function(_, value)
					C.db.profile.bars[barID].x_growth, C.db.profile.bars[barID].y_growth = s_split("_", value)

					BARS:For(barID, "Update")
				end,
			},
			flyout_dir = {
				order = inc(1),
				type = "select",
				name = L["FLYOUT_DIR"],
				values = FLYOUT_DIRS,
				set = function(_, value)
					C.db.profile.bars[barID].flyout_dir = value

					BARS:For(barID, "UpdateConfig")
					BARS:For(barID, "UpdateButtonConfig")
				end,
			},
			spacer_2 = CONFIG:CreateSpacer(inc(1)),
			hotkey = {
				order = inc(1),
				type = "group",
				name = L["KEYBIND_TEXT"],
				inline = true,
				get = function(info)
					return C.db.profile.bars[barID].hotkey[info[#info]]
				end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						name = L["ENABLE"],
						set = function(_, value)
							C.db.profile.bars[barID].hotkey.enabled = value

							BARS:For(barID, "UpdateConfig")
							BARS:For(barID, "UpdateButtonConfig")
							BARS:For(barID, "ForEach", "UpdateHotKey")
						end,
					},
					size = {
						order = 2,
						type = "range",
						name = L["SIZE"],
						min = 8, max = 48, step = 1,
						set = function(_, value)
							if C.db.profile.bars[barID].hotkey.size ~= value then
								C.db.profile.bars[barID].hotkey.size = value

								BARS:For(barID, "UpdateConfig")
								BARS:For(barID, "ForEach", "UpdateHotKeyFont")
							end
						end,
					},
				},
			},
			spacer_3 = CONFIG:CreateSpacer(inc(1)),
			macro = {
				order = inc(1),
				type = "group",
				name = L["MACRO_TEXT"],
				inline = true,
				get = function(info)
					return C.db.profile.bars[barID].macro[info[#info]]
				end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						name = L["ENABLE"],
						set = function(_, value)
							C.db.profile.bars[barID].macro.enabled = value

							BARS:For(barID, "UpdateConfig")
							BARS:For(barID, "UpdateButtonConfig")
						end,
					},
					size = {
						order = 2,
						type = "range",
						name = L["SIZE"],
						min = 8, max = 48, step = 1,
						set = function(_, value)
							if C.db.profile.bars[barID].macro.size ~= value then
								C.db.profile.bars[barID].macro.size = value

								BARS:For(barID, "UpdateConfig")
								BARS:For(barID, "ForEach", "UpdateMacroFont")
							end
						end,
					},
				},
			},
			spacer_4 = CONFIG:CreateSpacer(inc(1)),
			count = {
				order = inc(1),
				type = "group",
				name = L["COUNT_TEXT"],
				inline = true,
				args = {
					size = {
						order = 2,
						type = "range",
						name = L["SIZE"],
						min = 8, max = 48, step = 1,
						get = function()
							return C.db.profile.bars[barID].count.size
						end,
						set = function(_, value)
							if C.db.profile.bars[barID].count.size ~= value then
								C.db.profile.bars[barID].count.size = value

								BARS:For(barID, "UpdateConfig")
								BARS:For(barID, "ForEach", "UpdateCountFont")
							end
						end,
					},
				},
			},
			spacer_5 = CONFIG:CreateSpacer(inc(1)),
			cooldown = {
				order = inc(1),
				type = "group",
				name = L["COOLDOWN_TEXT"],
				inline = true,
				get = function(info)
					return C.db.profile.bars[barID].cooldown.text[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.bars[barID].cooldown.text[info[#info]] ~= value then
						C.db.profile.bars[barID].cooldown.text[info[#info]] = value

						BARS:For(barID, "UpdateConfig")
						BARS:For(barID, "UpdateCooldownConfig")
					end
				end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						name = L["SHOW"],
					},
					size = {
						order = 2,
						type = "range",
						name = L["SIZE"],
						min = 8, max = 48, step = 1,
					},
					v_alignment = {
						order = 4,
						type = "select",
						name = L["TEXT_VERT_ALIGNMENT"],
						values = V_ALIGNMENTS,
					},
				},
			},
			spacer_6 = CONFIG:CreateSpacer(inc(1)),
			fading = CONFIG:CreateBarFadingOptions(inc(1), barID),
		},
	}

	if barID == "bar1" then
		temp.args.reset.disabled = isModuleDisabledOrRestricted
		temp.args.visible.disabled = isModuleDisabledOrRestricted
		if BARS:IsRestricted() then
			temp.args.num.min = 6
			temp.args.num.max = 24
		end
		temp.args.per_row.disabled = isModuleDisabledOrRestricted
		temp.args.x_spacing.disabled = isModuleDisabledOrRestricted
		temp.args.y_spacing.disabled = isModuleDisabledOrRestricted
		temp.args.width.disabled = isModuleDisabledOrRestricted
		temp.args.height.disabled = isModuleDisabledOrRestricted
		temp.args.growth_dir.disabled = isModuleDisabledOrRestricted
		temp.args.flyout_dir.disabled = isModuleDisabledOrRestricted
	elseif barID == "pet" then
		temp.args.grid.set = function(_, value)
			C.db.profile.bars[barID].grid = value

			BARS:For(barID, "UpdateConfig")
			BARS:For(barID, "UpdateButtonConfig")
			BARS:For(barID, "ForEach", "UpdateGrid")
		end
		temp.args.num.max = 10
		temp.args.per_row.max = 10
		temp.args.flyout_dir = nil
		temp.args.macro = nil
		temp.args.spacer_4 = nil
		temp.args.count = nil
		temp.args.spacer_5 = nil
	elseif barID == "stance" then
		temp.args.grid = nil
		temp.args.num.max = 10
		temp.args.per_row.max = 10
		temp.args.flyout_dir = nil
		temp.args.macro = nil
		temp.args.spacer_4 = nil
		temp.args.count = nil
		temp.args.spacer_5 = nil
	elseif barID == "pet_battle" then
		temp.args.enabled = {
			order = 1,
			type = "toggle",
			name = CONFIG:ColorPrivateSetting(L["ENABLE"]),
			disabled = function() return BARS:IsRestricted() end,
			get = function()
				return PrC.db.profile.bars[barID].enabled
			end,
			set = function(_, value)
				PrC.db.profile.bars[barID].enabled = value

				if BARS:HasPetBattleBar() then
					CONFIG:AskToReloadUI("pet_battle.enabled", value)
				else
					if value then
						P:Call(BARS.CreatePetBattleBar, BARS)
					end
				end
			end,
		}
		temp.args.reset.disabled = isPetBattleBarDisabledOrRestricted
		temp.args.visible.disabled = isPetBattleBarDisabledOrRestricted
		temp.args.grid = nil
		temp.args.scale.disabled = isModuleDisabledOrRestricted
		temp.args.num.max = 6
		temp.args.num.disabled = isPetBattleBarDisabledOrRestricted
		temp.args.per_row.max = 6
		temp.args.per_row.disabled = isPetBattleBarDisabledOrRestricted
		temp.args.x_spacing.disabled = isPetBattleBarDisabledOrRestricted
		temp.args.y_spacing.disabled = isPetBattleBarDisabledOrRestricted
		temp.args.width.disabled = isPetBattleBarDisabledOrRestricted
		temp.args.height.disabled = isPetBattleBarDisabledOrRestricted
		temp.args.growth_dir.disabled = isPetBattleBarDisabledOrRestricted
		temp.args.flyout_dir = nil
		temp.args.hotkey.disabled = function() return not BARS:HasPetBattleBar() end
		temp.args.macro = nil
		temp.args.spacer_4 = nil
		temp.args.count = nil
		temp.args.spacer_5 = nil
		temp.args.cooldown = nil
		temp.args.spacer_6 = nil
	end

	return temp
end
