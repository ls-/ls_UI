local _, ns = ...
local E, C, M, L, P, D = ns.E, ns.C, ns.M, ns.L, ns.P, ns.D
local CONFIG = P:GetModule("Config")
local UNITFRAMES = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)
local s_split = _G.string.split

local function isModuleDisabled()
	return not UNITFRAMES:IsInit()
end

local function isPlayerFrameDisabled()
	return not UNITFRAMES:HasPlayerFrame()
end

local function isTargetFrameDisabled()
	return not UNITFRAMES:HasTargetFrame()
end

local function isFocusFrameDisabled()
	return not UNITFRAMES:HasFocusFrame()
end

local function isBossFrameDisabled()
	return not UNITFRAMES:HasBossFrame()
end

local function isRoundLayout()
	return E.UI_LAYOUT == "round"
end

local function createUnitFramePanel(order, unit, name)
	local copyIgnoredUnits = {
		["pet"] = E.UI_LAYOUT == "round",
		["player"] = E.UI_LAYOUT == "round",
		[unit] = true,
	}

	local temp = {
		order = order,
		type = "group",
		childGroups = "tab",
		name = name,
		args = {
			enabled = {
				order = 1,
				type = "toggle",
				name = L["ENABLE"],
				get = function()
					return C.db.profile.units[unit].enabled
				end,
				set = function(_, value)
					C.db.profile.units[unit].enabled = value

					UNITFRAMES:For(unit, "Update")
				end,
			}, -- 1
			copy = {
				order = 2,
				type = "select",
				name = L["COPY_FROM"],
				desc = L["COPY_FROM_DESC"],
				values = function()
					return UNITFRAMES:GetUnits(copyIgnoredUnits)
				end,
				get = function() end,
				set = function(_, value)
					CONFIG:CopySettings(C.db.profile.units[value], C.db.profile.units[unit])
					UNITFRAMES:For(unit, "Update")
				end,
			}, -- 2
			reset = {
				order = 3,
				type = "execute",
				name = L["RESTORE_DEFAULTS"],
				confirm = CONFIG.ConfirmReset,
				func = function()
					CONFIG:CopySettings(D.profile.units[unit], C.db.profile.units[unit])
					UNITFRAMES:For(unit, "Update")
				end,
			}, -- 3
			spacer_1 = {
				order = 4,
				type = "description",
				name = " ",
			}, -- 4
			width = {
				order = 5,
				type = "range",
				name = L["WIDTH"],
				min = 96, max = 512, step = 2,
				get = function()
					return C.db.profile.units[unit].width
				end,
				set = function(_, value)
					if C.db.profile.units[unit].width ~= value then
						C.db.profile.units[unit].width = value

						UNITFRAMES:For(unit, "Update")
					end
				end,
			}, -- 5
			height = {
				order = 6,
				type = "range",
				name = L["HEIGHT"],
				min = 28, max = 256, step = 2,
				get = function()
					return C.db.profile.units[unit].height
				end,
				set = function(_, value)
					if C.db.profile.units[unit].height ~= value then
						C.db.profile.units[unit].height = value

						UNITFRAMES:For(unit, "Update")
					end
				end,
			}, -- 6
			top_inset = {
				order = 7,
				type = "range",
				name = L["TOP_INSET_SIZE"],
				desc = L["TOP_INSET_SIZE_DESC"],
				min = 0.01, max = 0.25, step = 0.01,
				isPercent = true,
				get = function()
					return C.db.profile.units[unit].insets.t_size
				end,
				set = function(_, value)
					if C.db.profile.units[unit].insets.t_size ~= value then
						C.db.profile.units[unit].insets.t_size = value

						UNITFRAMES:For(unit, "UpdateLayout")
					end
				end,
			}, -- 7
			bottom_inset = {
				order = 8,
				type = "range",
				name = L["BOTTOM_INSET_SIZE"],
				desc = L["BOTTOM_INSET_SIZE_DESC"],
				min = 0.01, max = 0.5, step = 0.01,
				isPercent = true,
				get = function()
					return C.db.profile.units[unit].insets.b_size
				end,
				set = function(_, value)
					if C.db.profile.units[unit].insets.b_size ~= value then
						C.db.profile.units[unit].insets.b_size = value

						UNITFRAMES:For(unit, "UpdateLayout")
					end
				end,
			}, -- 8
			-- per_row = {}, -- 9
			-- spacing = {}, -- 10
			-- growth_dir = {}, -- 11
			threat = {
				order = 13,
				type = "toggle",
				name = L["THREAT_GLOW"],
				get = function()
					return C.db.profile.units[unit].threat.enabled
				end,
				set = function(_, value)
					C.db.profile.units[unit].threat.enabled = value

					UNITFRAMES:For(unit, "UpdateThreatIndicator")
				end,
			}, -- 13
			pvp = {
				order = 14,
				type = "toggle",
				name = L["PVP_ICON"],
				get = function()
					return C.db.profile.units[unit].pvp.enabled
				end,
				set = function(_, value)
					C.db.profile.units[unit].pvp.enabled = value

					UNITFRAMES:For(unit, "UpdatePvPIndicator")
				end,
			}, -- 14
			mirror_widgets = {
				order = 15,
				type = "toggle",
				name = L["MIRROR_WIDGETS"],
				desc = L["MIRROR_WIDGETS_DESC"],
				get = function()
					return C.db.profile.units[unit].mirror_widgets
				end,
				set = function(_, value)
					C.db.profile.units[unit].mirror_widgets = value

					UNITFRAMES:For(unit, "UpdateConfig")
					UNITFRAMES:For(unit, "AlignWidgets")
				end,
			}, -- 15
			spacer_2 = {
				order = 16,
				type = "description",
				name = " ",
			}, -- 16
			border = {
				order = 17,
				type = "group",
				name = L["BORDER_COLOR"],
				inline = true,
				get = function(info)
					return C.db.profile.units[unit].border.color[info[#info]]
				end,
				set = function(info, value)
					C.db.profile.units[unit].border.color[info[#info]] = value

					UNITFRAMES:For(unit, "UpdateClassIndicator")
				end,
				args = {
					class = {
						order = 1,
						type = "toggle",
						name = L["CLASS"],
					},
					reaction = {
						order = 2,
						type = "toggle",
						name = L["REACTION"],
					},
				},
			}, -- 17
			spacer_4 = {
				order = 18,
				type = "description",
				name = " ",
			}, -- 18
			health = CONFIG:CreateUnitFrameHealthPanel(19, unit),
			power = CONFIG:CreateUnitFramePowerPanel(20, unit),
			-- alt_power = {}, -- 21
			-- class_power = {}, -- 21
			-- castbar = {}, -- 22
			-- auras = {}, -- 23
			portrait = CONFIG:CreateUnitFramePortraitPanel(24, unit),
			raid_target = CONFIG:CreateUnitFrameRaidTargetPanel(25, unit),
			name = CONFIG:CreateUnitFrameNamePanel(26, unit),
			debuff = CONFIG:CreateUnitFrameDebuffIconsPanel(27, unit),
			-- custom_texts = {}, -- 28
			fading = CONFIG:CreateUnitFrameFadingPanel(29, unit)
		},
	}

	if unit == "player" then
		temp.disabled = isPlayerFrameDisabled
		temp.args.class_power = CONFIG:CreateUnitFrameClassPowerPanel(21, unit)
		temp.args.castbar = CONFIG:CreateUnitFrameCastbarPanel(22, unit)
		temp.args.custom_texts = CONFIG:CreateUnitFrameCustomTextsPanel(28, unit)

		if E.UI_LAYOUT == "rect" then
			temp.args.auras = CONFIG:CreateUnitFrameAurasPanel(23, unit)
		else
			temp.args.copy.hidden = isRoundLayout
			temp.args.width.hidden = isRoundLayout
			temp.args.height.hidden = isRoundLayout
			temp.args.top_inset = nil
			temp.args.bottom_inset = nil
			temp.args.mirror_widgets = nil
			temp.args.portrait = nil
			temp.args.name = nil
		end
	elseif unit == "pet" then
		temp.disabled = isPlayerFrameDisabled
		temp.args.castbar = CONFIG:CreateUnitFrameCastbarPanel(22, unit)
		temp.args.auras = CONFIG:CreateUnitFrameAurasPanel(23, unit)
		temp.args.custom_texts = CONFIG:CreateUnitFrameCustomTextsPanel(28, unit)
		temp.args.pvp = nil
		temp.args.mirror_widgets = nil

		if E.UI_LAYOUT == "round" then
			temp.args.copy.hidden = isRoundLayout
			temp.args.width.hidden = isRoundLayout
			temp.args.height.hidden = isRoundLayout
			temp.args.top_inset = nil
			temp.args.bottom_inset = nil
			temp.args.border = nil
			temp.args.portrait = nil
			temp.args.name = nil
		end
	elseif unit == "target" then
		temp.disabled = isTargetFrameDisabled
		temp.args.castbar = CONFIG:CreateUnitFrameCastbarPanel(22, unit)
		temp.args.auras = CONFIG:CreateUnitFrameAurasPanel(23, unit)
		temp.args.custom_texts = CONFIG:CreateUnitFrameCustomTextsPanel(28, unit)
	elseif unit == "targettarget" then
		temp.disabled = isTargetFrameDisabled
		temp.args.debuff = nil
		temp.args.pvp = nil
		temp.args.mirror_widgets = nil
	elseif unit == "focus" then
		temp.disabled = isFocusFrameDisabled
		temp.args.castbar = CONFIG:CreateUnitFrameCastbarPanel(22, unit)
		temp.args.auras = CONFIG:CreateUnitFrameAurasPanel(23, unit)
		temp.args.custom_texts = CONFIG:CreateUnitFrameCustomTextsPanel(28, unit)
	elseif unit == "focustarget" then
		temp.disabled = isFocusFrameDisabled
		temp.args.debuff = nil
		temp.args.pvp = nil
		temp.args.mirror_widgets = nil
	elseif unit == "boss" then
		temp.disabled = isBossFrameDisabled
		temp.args.alt_power = CONFIG:CreateUnitFrameAltPowerPanel(21, unit)
		temp.args.castbar = CONFIG:CreateUnitFrameCastbarPanel(22, unit)
		temp.args.auras = CONFIG:CreateUnitFrameAurasPanel(23, unit)
		temp.args.custom_texts = CONFIG:CreateUnitFrameCustomTextsPanel(28, unit)
		temp.args.pvp = nil
		temp.args.mirror_widgets = nil

		temp.args.per_row = {
			order = 10,
			type = "range",
			name = L["PER_ROW"],
			min = 1, max = 5, step = 1,
			get = function()
				return C.db.profile.units[unit].per_row
			end,
			set = function(_, value)
				if C.db.profile.units[unit].per_row ~= value then
					C.db.profile.units[unit].per_row = value

					UNITFRAMES:UpdateBossHolder()
				end
			end,
		}

		temp.args.spacing = {
			order = 11,
			type = "range",
			name = L["SPACING"],
			min = 8, max = 64, step = 2,
			get = function()
				return C.db.profile.units[unit].spacing
			end,
			set = function(_, value)
				if C.db.profile.units[unit].spacing ~= value then
					C.db.profile.units[unit].spacing = value

					UNITFRAMES:UpdateBossHolder()
				end
			end,
		}

		temp.args.growth_dir = {
			order = 12,
			type = "select",
			name = L["GROWTH_DIR"],
			values = CONFIG.GROWTH_DIRS,
			get = function()
				return C.db.profile.units[unit].x_growth .. "_" .. C.db.profile.units[unit].y_growth
			end,
			set = function(_, value)
				C.db.profile.units[unit].x_growth, C.db.profile.units[unit].y_growth = s_split("_", value)

				UNITFRAMES:UpdateBossHolder()
			end,
		}
	end

	return temp
end

function CONFIG:CreateUnitFramesPanel(order)
	C.options.args.unitframes = {
		order = order,
		type = "group",
		name = L["UNIT_FRAME"],
		childGroups = "tree",
		args = {
			enabled = {
				order = 1,
				type = "toggle",
				name = L["ENABLE"],
				get = function()
					return C.db.char.units.enabled
				end,
				set = function(_, value)
					C.db.char.units.enabled = value

					if UNITFRAMES:IsInit() then
						if not value then
							CONFIG:ShowStaticPopup("RELOAD_UI")
						end
					else
						if value then
							P:Call(UNITFRAMES.Init, UNITFRAMES)
						end
					end
				end,
			}, -- 1
			spacer_1 = {
				order = 2,
				type = "description",
				name = " ",
			}, -- 2
			units = {
				order = 3,
				type = "group",
				name = L["UNITS"],
				inline = true,
				disabled = isModuleDisabled,
				get = function(info)
					return C.db.char.units[info[#info]].enabled
				end,
				set = function(info, value)
					C.db.char.units[info[#info]].enabled = value

					if UNITFRAMES:IsInit() then
						if value then
							if info[#info] == "player" then
								UNITFRAMES:Create("player")
								UNITFRAMES:For("player", "Update")
								UNITFRAMES:Create("pet")
								UNITFRAMES:For("pet", "Update")

								if P:GetModule("Blizzard"):HasCastBars() then
									P:GetModule("Blizzard"):UpdateCastBars()
								end
							elseif info[#info] == "target" then
								UNITFRAMES:Create("target")
								UNITFRAMES:For("target", "Update")
								UNITFRAMES:Create("targettarget")
								UNITFRAMES:For("targettarget", "Update")
							elseif info[#info] == "focus" then
								UNITFRAMES:Create("focus")
								UNITFRAMES:For("focus", "Update")
								UNITFRAMES:Create("focustarget")
								UNITFRAMES:For("focustarget", "Update")
							else
								UNITFRAMES:Create("boss")
								UNITFRAMES:For("boss", "Update")
							end
						else
							CONFIG:ShowStaticPopup("RELOAD_UI")
						end
					end
				end,
				args = {
					player = {
						order = 1,
						type = "toggle",
						name = L["PLAYER_PET"],
					},
					target = {
						order = 2,
						type = "toggle",
						name = L["TARGET_TOT"],
					},
					focus = {
						order = 3,
						type = "toggle",
						name = L["FOCUS_TOF"],
					},
					boss = {
						order = 4,
						type = "toggle",
						name = L["BOSS"],
					},
				},
			}, -- 3
			spacer_2 = {
				order = 4,
				type = "description",
				name = " ",
			}, -- 4
			gloss = {
				order = 5,
				type = "range",
				name = L["GLOSS"],
				disabled = isModuleDisabled,
				min = 0, max = 1, step = 0.05,
				isPercent = true,
				get = function()
					return C.db.profile.units.inlay.alpha
				end,
				set = function(_, value)
					if C.db.profile.units.inlay.alpha ~= value then
						C.db.profile.units.inlay.alpha = value

						UNITFRAMES:ForEach("UpdateInlay")
					end
				end,
			}, -- 5
			spacer_3 = {
				order = 6,
				type = "description",
				name = " ",
			}, -- 6
			change = {
				order = 7,
				type = "group",
				name = L["PROGRESS_BARS"],
				inline = true,
				disabled = isModuleDisabled,
				get = function(info)
					return C.db.profile.units.change[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.units.change[info[#info]] ~= value then
						C.db.profile.units.change[info[#info]] = value

						UNITFRAMES:ForEach("For", "Health", "UpdateConfig")
						UNITFRAMES:ForEach("For", "Health", "UpdateSmoothing")

						UNITFRAMES:ForEach("For", "HealthPrediction", "UpdateSmoothing")
						UNITFRAMES:ForEach("For", "HealthPrediction", "UpdateSmoothing")

						UNITFRAMES:ForEach("For", "Power", "UpdateConfig")
						UNITFRAMES:ForEach("For", "Power", "UpdateSmoothing")

						UNITFRAMES:ForEach("For", "AdditionalPower", "UpdateConfig")
						UNITFRAMES:ForEach("For", "AdditionalPower", "UpdateSmoothing")

						UNITFRAMES:ForEach("For", "AlternativePower", "UpdateConfig")
						UNITFRAMES:ForEach("For", "AlternativePower", "UpdateSmoothing")

						UNITFRAMES:ForEach("For", "Stagger", "UpdateConfig")
						UNITFRAMES:ForEach("For", "Stagger", "UpdateSmoothing")
					end
				end,
				args = {
					animated = {
						order = 1,
						type = "toggle",
						name = L["PROGRESS_BAR_ANIMATED"],
					},
					smooth = {
						order = 2,
						type = "toggle",
						name = L["PROGRESS_BAR_SMOOTH"],
					},
				},
			}, -- 7
			spacer_4 = {
				order = 8,
				type = "description",
				name = " ",
			}, -- 8
			cooldown = {
				order = 9,
				type = "group",
				name = L["COOLDOWN_TEXT"],
				inline = true,
				disabled = isModuleDisabled,
				get = function(info)
					return C.db.profile.units.cooldown[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.units.cooldown[info[#info]] ~= value then
						C.db.profile.units.cooldown[info[#info]] = value

						UNITFRAMES:ForEach("For", "Auras", "UpdateConfig")
						UNITFRAMES:ForEach("For", "Auras", "UpdateCooldownConfig")
					end
				end,
				args = {
					reset = {
						type = "execute",
						order = 1,
						name = L["RESTORE_DEFAULTS"],
						confirm = CONFIG.ConfirmReset,
						func = function()
							CONFIG:CopySettings(D.profile.units.cooldown, C.db.profile.units.cooldown)
							UNITFRAMES:ForEach("For", "Auras", "UpdateConfig")
							UNITFRAMES:ForEach("For", "Auras", "UpdateCooldownConfig")
						end,
					},
					spacer_1 = {
						order = 9,
						type = "description",
						name = " ",
					},
					exp_threshold = {
						order = 10,
						type = "range",
						name = L["EXP_THRESHOLD"],
						min = 1, max = 10, step = 1,
					},
					m_ss_threshold = {
						order = 11,
						type = "range",
						name = L["M_SS_THRESHOLD"],
						desc = L["M_SS_THRESHOLD_DESC"],
						min = 0, max = 3599, step = 1,
						softMin = 91,
						set = function(info, value)
							if C.db.profile.units.cooldown[info[#info]] ~= value then
								if value < info.option.softMin then
									value = info.option.min
								end

								C.db.profile.units.cooldown[info[#info]] = value

								UNITFRAMES:ForEach("For", "Auras", "UpdateConfig")
								UNITFRAMES:ForEach("For", "Auras", "UpdateCooldownConfig")
							end
						end,
					},
					s_ms_threshold = {
						order = 12,
						type = "range",
						name = L["S_MS_THRESHOLD"],
						desc = L["S_MS_THRESHOLD_DESC"],
						min = 1, max = 10, step = 1,
						set = function(info, value)
							if C.db.profile.units.cooldown[info[#info]] ~= value then
								C.db.profile.units.cooldown[info[#info]] = value

								UNITFRAMES:ForEach("For", "Auras", "UpdateConfig")
								UNITFRAMES:ForEach("For", "Auras", "UpdateCooldownConfig")
							end
						end,
					},
				},
			}, -- 9
			player = createUnitFramePanel(10, "player", L["PLAYER_FRAME"]),
			pet = createUnitFramePanel(11, "pet", L["PET_FRAME"]),
			target = createUnitFramePanel(12, "target", L["TARGET_FRAME"]),
			targettarget = createUnitFramePanel(13, "targettarget", L["TOT_FRAME"]),
			focus = createUnitFramePanel(14, "focus", L["FOCUS_FRAME"]),
			focustarget = createUnitFramePanel(15, "focustarget", L["TOF_FRAME"]),
			boss = createUnitFramePanel(16, "boss", L["BOSS_FRAMES"]),
		},
	}

	self:AddCallback(self.CreateUnitFrameAuraFilters)
end
