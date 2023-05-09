local _, CONFIG = ...

-- Lua
local _G = getfenv(0)
local next = _G.next
local tonumber = _G.tonumber
local type = _G.type
local unpack = _G.unpack

-- Mine
local E, M, L, C, D, PrC, PrD, P, oUF = unpack(ls_UI)
local BARS = P:GetModule("Bars")
local BLIZZARD = P:GetModule("Blizzard")
local MINIMAP = P:GetModule("Minimap")
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

function CONFIG:GetColorsOptions(order)
	self.options.args.general.args.colors = {
		order = order,
		type = "group",
		childGroups = "tree",
		name = L["COLORS"],
		get = function(info)
			return C.db.global.colors[info[#info]]:GetRGB()
		end,
		args = {
			health = {
				order = reset(1),
				type = "group",
				name = L["HEALTH"],
				set = function(info, r, g, b)
					if r ~= nil then
						info = info[#info]

						local color = C.db.global.colors[info]
						if color.r ~= r or color.g ~= g or color.g ~= b then
							color:SetRGB(r, g, b)

							UNITFRAMES:UpdateHealthColors()
							UNITFRAMES:ForEach("For", "Health", "UpdateColors")
							UNITFRAMES:ForEach("For", "Health", "UpdateTags")
						end
					end
				end,
				args = {
					reset = {
						type = "execute",
						order = reset(2),
						name = L["RESTORE_DEFAULTS"],
						confirm = CONFIG.ConfirmReset,
						func = function()
							C.db.global.colors.health:SetRGB(D.global.colors.health:GetRGB())
							C.db.global.colors.disconnected:SetRGB(D.global.colors.disconnected:GetRGB())
							C.db.global.colors.tapped:SetRGB(D.global.colors.tapped:GetRGB())

							UNITFRAMES:UpdateHealthColors()
							UNITFRAMES:ForEach("For", "Health", "UpdateColors")
							UNITFRAMES:ForEach("For", "Health", "UpdateTags")
						end,
					},
					spacer_1 = {
						order = inc(2),
						type = "description",
						name = " ",
					},
					health = {
						order = inc(2),
						type = "color",
						name = L["HEALTH"],
					},
					disconnected = {
						order = inc(2),
						type = "color",
						name = L["OFFLINE"],
					},
					tapped = {
						order = inc(2),
						type = "color",
						name = L["TAPPED"],
					},
				},
			},
			power = {
				order = inc(1),
				type = "group",
				name = L["POWER"],
				get = function(info)
					return C.db.global.colors.power[info[#info]]:GetRGB()
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
							color:SetRGB(r, g, b)

							UNITFRAMES:UpdatePowerColors()
							UNITFRAMES:ForEach("For", "AdditionalPower", "UpdateColors")
							UNITFRAMES:ForEach("For", "AlternativePower", "UpdateColors")
							UNITFRAMES:ForEach("For", "Power", "UpdateColors")
							UNITFRAMES:ForEach("For", "ClassPower", "UpdateColors")
							UNITFRAMES:ForEach("For", "Runes", "UpdateColors")
							UNITFRAMES:ForEach("For", "Stagger", "UpdateColors")
							UNITFRAMES:ForEach("For", "AlternativePower", "UpdateTags")
							UNITFRAMES:ForEach("For", "Power", "UpdateTags")
						end
					end
				end,
				args = {
					reset = {
						type = "execute",
						order = reset(2),
						name = L["RESTORE_DEFAULTS"],
						confirm = CONFIG.ConfirmReset,
						func = function()
							for k, v in next, D.global.colors.power do
								if type(k) == "string" then
									if type(v[1]) == "table" then
										for i, v_ in next, v do
											C.db.global.colors.power[k][i]:SetRGB(v_:GetRGB())
										end
									else
										C.db.global.colors.power[k]:SetRGB(v:GetRGB())
									end
								end
							end

							for k, v in next, D.global.colors.rune do
								C.db.global.colors.rune[k]:SetRGB(v:GetRGB())
							end

							UNITFRAMES:UpdatePowerColors()
							UNITFRAMES:ForEach("For", "AdditionalPower", "UpdateColors")
							UNITFRAMES:ForEach("For", "AlternativePower", "UpdateColors")
							UNITFRAMES:ForEach("For", "Power", "UpdateColors")
							UNITFRAMES:ForEach("For", "ClassPower", "UpdateColors")
							UNITFRAMES:ForEach("For", "Runes", "UpdateColors")
							UNITFRAMES:ForEach("For", "Stagger", "UpdateColors")
							UNITFRAMES:ForEach("For", "AlternativePower", "UpdateTags")
							UNITFRAMES:ForEach("For", "Power", "UpdateTags")
						end,
					},
					spacer_1 = {
						order = inc(2),
						type = "description",
						name = " ",
					},
					MANA = {
						order = inc(2),
						type = "color",
						name = L["MANA"],
					},
					RAGE = {
						order = inc(2),
						type = "color",
						name = L["RAGE"],
					},
					FOCUS = {
						order = inc(2),
						type = "color",
						name = L["FOCUS"],
					},
					ENERGY = {
						order = inc(2),
						type = "color",
						name = L["ENERGY"],
					},
					COMBO_POINTS = {
						order = inc(2),
						type = "color",
						name = L["COMBO_POINTS"],
					},
					COMBO_POINTS_CHARGED = {
						order = inc(2),
						type = "color",
						name = L["COMBO_POINTS_CHARGED"],
					},
					RUNES = {
						order = inc(2),
						type = "color",
						name = L["RUNES"],
					},
					RUNES_BLOOD = {
						order = inc(2),
						type = "color",
						name = L["RUNES_BLOOD"],
						get = function()
							return C.db.global.colors.rune[1]:GetRGB()
						end,
					},
					RUNES_FROST = {
						order = inc(2),
						type = "color",
						name = L["RUNES_FROST"],
						get = function()
							return C.db.global.colors.rune[2]:GetRGB()
						end,
					},
					RUNES_UNHOLY = {
						order = inc(2),
						type = "color",
						name = L["RUNES_UNHOLY"],
						get = function()
							return C.db.global.colors.rune[3]:GetRGB()
						end,
					},
					RUNIC_POWER = {
						order = inc(2),
						type = "color",
						name = L["RUNIC_POWER"],
					},
					SOUL_SHARDS = {
						order = inc(2),
						type = "color",
						name = L["SOUL_SHARDS"],
					},
					LUNAR_POWER = {
						order = inc(2),
						type = "color",
						name = L["LUNAR_POWER"],
					},
					HOLY_POWER = {
						order = inc(2),
						type = "color",
						name = L["HOLY_POWER"],
					},
					ALTERNATE = {
						order = inc(2),
						type = "color",
						name = L["ALTERNATIVE_POWER"],
					},
					MAELSTROM = {
						order = inc(2),
						type = "color",
						name = L["MAELSTROM_POWER"],
					},
					INSANITY = {
						order = inc(2),
						type = "color",
						name = L["INSANITY"],
					},
					CHI = {
						order = inc(2),
						type = "color",
						name = L["CHI"],
					},
					ARCANE_CHARGES = {
						order = inc(2),
						type = "color",
						name = L["ARCANE_CHARGES"],
					},
					FURY = {
						order = inc(2),
						type = "color",
						name = L["FURY"],
					},
					PAIN = {
						order = inc(2),
						type = "color",
						name = L["PAIN"],
					},
					STAGGER_LOW = {
						order = inc(2),
						type = "color",
						name = L["STAGGER_LOW"],
						get = function()
							return C.db.global.colors.power.STAGGER[1]:GetRGB()
						end,
					},
					STAGGER_MEDIUM = {
						order = inc(2),
						type = "color",
						name = L["STAGGER_MEDIUM"],
						get = function()
							return C.db.global.colors.power.STAGGER[2]:GetRGB()
						end,
					},
					STAGGER_HIGH = {
						order = inc(2),
						type = "color",
						name = L["STAGGER_HIGH"],
						get = function()
							return C.db.global.colors.power.STAGGER[3]:GetRGB()
						end,
					},
				},
			},
			prediction = {
				order = inc(1),
				type = "group",
				name = L["PREDICTION"],
				get = function(info)
					return C.db.global.colors.prediction[info[#info]]:GetRGB()
				end,
				set = function(info, r, g, b)
					if r ~= nil then
						local color = C.db.global.colors.prediction[info[#info]]
						if color.r ~= r or color.g ~= g or color.g ~= b then
							color:SetRGB(r, g, b)

							UNITFRAMES:ForEach("For", "HealthPrediction", "UpdateColors")
							UNITFRAMES:ForEach("For", "PowerPrediction", "UpdateColors")
						end
					end
				end,
				args = {
					reset = {
						type = "execute",
						order = reset(2),
						name = L["RESTORE_DEFAULTS"],
						confirm = CONFIG.ConfirmReset,
						func = function()
							for k, v in next, D.global.colors.prediction do
								C.db.global.colors.prediction[k]:SetRGB(v:GetRGB())
							end

							UNITFRAMES:ForEach("For", "HealthPrediction", "UpdateColors")
							UNITFRAMES:ForEach("For", "PowerPrediction", "UpdateColors")
						end,
					},
					spacer_1 = {
						order = inc(2),
						type = "description",
						name = " ",
					},
					my_heal = {
						order = inc(2),
						type = "color",
						name = L["YOUR_HEALING"],
						hasAlpha = true,
					},
					other_heal = {
						order = inc(2),
						type = "color",
						name = L["OTHERS_HEALING"],
						hasAlpha = true,
					},
					damage_absorb = {
						order = inc(2),
						type = "color",
						name = L["DAMAGE_ABSORB"],
						hasAlpha = true,
					},
					heal_absorb = {
						order = inc(2),
						type = "color",
						name = L["HEAL_ABSORB"],
						hasAlpha = true,
					},
					power_cost = {
						order = inc(2),
						type = "color",
						name = L["POWER_COST"],
						hasAlpha = true,
					},
				},
			},
			reaction = {
				order = inc(1),
				type = "group",
				name = L["REACTION"],
				get = function(info)
					return C.db.global.colors.reaction[tonumber(info[#info])]:GetRGB()
				end,
				set = function(info, r, g, b)
					if r ~= nil then
						local color = C.db.global.colors.reaction[tonumber(info[#info])]
						if color.r ~= r or color.g ~= g or color.g ~= b then
							color:SetRGB(r, g, b)

							UNITFRAMES:UpdateReactionColors()
							UNITFRAMES:ForEach("For", "Health", "UpdateColors")
							UNITFRAMES:ForEach("For", "ClassIndicator", "ForceUpdate")

							BARS:For("xpbar", "UpdateSegments")
						end
					end
				end,
				args = {
					reset = {
						type = "execute",
						order = reset(2),
						name = L["RESTORE_DEFAULTS"],
						confirm = CONFIG.ConfirmReset,
						func = function()
							for k, v in next, D.global.colors.reaction do
								C.db.global.colors.reaction[k]:SetRGB(v:GetRGB())
							end

							UNITFRAMES:UpdateReactionColors()
							UNITFRAMES:ForEach("For", "Health", "UpdateColors")
							UNITFRAMES:ForEach("For", "ClassIndicator", "ForceUpdate")

							BARS:For("xpbar", "UpdateSegments")
						end,
					},
					spacer_1 = {
						order = inc(2),
						type = "description",
						name = " ",
					},
					["1"] = {
						order = inc(2),
						type = "color",
						name = FACTION_STANDING_LABEL1,
					},
					["2"] = {
						order = inc(2),
						type = "color",
						name = FACTION_STANDING_LABEL2,
					},
					["3"] = {
						order = inc(2),
						type = "color",
						name = FACTION_STANDING_LABEL3,
					},
					["4"] = {
						order = inc(2),
						type = "color",
						name = FACTION_STANDING_LABEL4,
					},
					["5"] = {
						order = inc(2),
						type = "color",
						name = FACTION_STANDING_LABEL5,
					},
					["6"] = {
						order = inc(2),
						type = "color",
						name = FACTION_STANDING_LABEL6,
					},
					["7"] = {
						order = inc(2),
						type = "color",
						name = FACTION_STANDING_LABEL7,
					},
					["8"] = {
						order = inc(2),
						type = "color",
						name = FACTION_STANDING_LABEL8,
					},
					["9"] = {
						order = inc(2),
						type = "color",
						name = L["RENOWN"],
					},
				},
			},
			faction = {
				order = inc(1),
				type = "group",
				name = L["FACTION"],
				get = function(info)
					return C.db.global.colors.faction[info[#info]]:GetRGB()
				end,
				set = function(info, r, g, b)
					if r ~= nil then
						local color = C.db.global.colors.faction[info[#info]]
						if color.r ~= r or color.g ~= g or color.g ~= b then
							color:SetRGB(r, g, b)

							if BARS:HasXPBar() then
								BARS:For("xpbar", "UpdateSegments")
							end
						end
					end
				end,
				args = {
					reset = {
						type = "execute",
						order = reset(2),
						name = L["RESTORE_DEFAULTS"],
						confirm = CONFIG.ConfirmReset,
						func = function()
							for k, v in next, D.global.colors.faction do
								C.db.global.colors.faction[k]:SetRGB(v:GetRGB())
							end

							if BARS:HasXPBar() then
								BARS:For("xpbar", "UpdateSegments")
							end
						end,
					},
					spacer_1 = {
						order = inc(2),
						type = "description",
						name = " ",
					},
					Alliance = {
						order = inc(2),
						type = "color",
						name = L["FACTION_ALLIANCE"],
					},
					Horde = {
						order = inc(2),
						type = "color",
						name = L["FACTION_HORDE"],
					},
					Neutral = {
						order = inc(2),
						type = "color",
						name = L["FACTION_NEUTRAL"],
					},
				},
			},
			xp = {
				order = inc(1),
				type = "group",
				name = L["EXPERIENCE"],
				get = function(info)
					return C.db.global.colors.xp[tonumber(info[#info])]:GetRGB()
				end,
				set = function(info, r, g, b)
					if r ~= nil then
						local color = C.db.global.colors.xp[tonumber(info[#info])]
						if color.r ~= r or color.g ~= g or color.g ~= b then
							color:SetRGB(r, g, b)

							if BARS:HasXPBar() then
								BARS:For("xpbar", "UpdateSegments")
							end
						end
					end
				end,
				args = {
					reset = {
						type = "execute",
						order = reset(2),
						name = L["RESTORE_DEFAULTS"],
						confirm = CONFIG.ConfirmReset,
						func = function()
							for k, v in next, D.global.colors.xp do
								C.db.global.colors.xp[k]:SetRGB(v:GetRGB())
							end

							C.db.global.colors.honor:SetRGB(D.global.colors.honor:GetRGB())

							if BARS:HasXPBar() then
								BARS:For("xpbar", "UpdateSegments")
							end
						end,
					},
					spacer_1 = {
						order = inc(2),
						type = "description",
						name = " ",
					},
					["1"] = {
						order = inc(2),
						type = "color",
						name = L["EXPERIENCE_RESTED"],
					},
					["2"] = {
						order = inc(2),
						type = "color",
						name = L["EXPERIENCE_NORMAL"],
					},
					honor = {
						order = inc(2),
						type = "color",
						name = L["HONOR"],
						get = function()
							return C.db.global.colors.honor:GetRGB()
						end,
						set = function(_, r, g, b)
							if r ~= nil then
								local color = C.db.global.colors.honor
								if color.r ~= r or color.g ~= g or color.g ~= b then
									color:SetRGB(r, g, b)

									if BARS:HasXPBar() then
										BARS:For("xpbar", "UpdateSegments")
									end
								end
							end
						end,
					},
				},
			},
			difficulty = {
				order = inc(1),
				type = "group",
				name = L["DIFFICULTY"],
				get = function(info)
					return C.db.global.colors.difficulty[info[#info]]:GetRGB()
				end,
				set = function(info, r, g, b)
					if r ~= nil then
						local color = C.db.global.colors.difficulty[info[#info]]
						if color.r ~= r or color.g ~= g or color.g ~= b then
							color:SetRGB(r, g, b)
						end

						UNITFRAMES:ForEach("For", "Name", "UpdateTags")
					end
				end,
				args = {
					reset = {
						type = "execute",
						order = reset(2),
						name = L["RESTORE_DEFAULTS"],
						confirm = CONFIG.ConfirmReset,
						func = function()
							for k, v in next, D.global.colors.difficulty do
								C.db.global.colors.difficulty[k]:SetRGB(v:GetRGB())
							end

							UNITFRAMES:ForEach("For", "Name", "UpdateTags")
						end,
					},
					spacer_1 = {
						order = inc(2),
						type = "description",
						name = " ",
					},
					trivial = {
						order = inc(2),
						type = "color",
						name = L["TRIVIAL"],
					},
					standard = {
						order = inc(2),
						type = "color",
						name = L["STANDARD"],
					},
					difficult = {
						order = inc(2),
						type = "color",
						name = L["DIFFICULT"],
					},
					very_difficult = {
						order = inc(2),
						type = "color",
						name = L["VERY_DIFFICULT"],
					},
					impossible = {
						order = inc(2),
						type = "color",
						name = L["IMPOSSIBLE"],
					},
				}
			},
			castbar = {
				order = inc(1),
				type = "group",
				name = L["CASTBAR"],
				get = function(info)
					return C.db.global.colors.castbar[info[#info]]:GetRGB()
				end,
				set = function(info, r, g, b)
					if r ~= nil then
						local color = C.db.global.colors.castbar[info[#info]]
						if color.r ~= r or color.g ~= g or color.g ~= b then
							color:SetRGB(r, g, b)
						end

						BLIZZARD:UpdateCastBarColors()
					end
				end,
				args = {
					reset = {
						type = "execute",
						order = reset(2),
						name = L["RESTORE_DEFAULTS"],
						confirm = CONFIG.ConfirmReset,
						func = function()
							for k, v in next, D.global.colors.castbar do
								C.db.global.colors.castbar[k]:SetRGB(v:GetRGB())
							end

							BLIZZARD:UpdateCastBarColors()
						end,
					},
					spacer_1 = {
						order = inc(2),
						type = "description",
						name = " ",
					},
					casting = {
						order = inc(2),
						type = "color",
						name = L["SPELL_CAST"],
					},
					channeling = {
						order = inc(2),
						type = "color",
						name = L["SPELL_CHANNELED"],
					},
					empowering = {
						order = inc(2),
						type = "color",
						name = L["SPELL_EMPOWERED"],
					},
					failed = {
						order = inc(2),
						type = "color",
						name = L["SPELL_FAILED"],
					},
					notinterruptible = {
						order = inc(2),
						type = "color",
						name = L["SPELL_UNINTERRUPTIBLE"],
					},
				},
			},
			aura = {
				order = inc(1),
				type = "group",
				name = L["AURA"],
				get = function(info)
					return C.db.global.colors.debuff[info[#info]]:GetRGB()
				end,
				set = function(info, r, g, b)
					if r ~= nil then
						local color = C.db.global.colors.debuff[info[#info]]
						if color.r ~= r or color.g ~= g or color.g ~= b then
							color:SetRGB(r, g, b)
						end

						UNITFRAMES:ForEach("For", "Auras", "UpdateColors")
					end
				end,
				args = {
					reset = {
						type = "execute",
						order = reset(2),
						name = L["RESTORE_DEFAULTS"],
						confirm = CONFIG.ConfirmReset,
						func = function()
							for k, v in next, D.global.colors.debuff do
								C.db.global.colors.debuff[k]:SetRGB(v:GetRGB())
							end

							for k, v in next, D.global.colors.buff do
								C.db.global.colors.buff[k]:SetRGB(v:GetRGB())
							end

							UNITFRAMES:ForEach("For", "Auras", "UpdateColors")
						end,
					},
					spacer_1 = {
						order = inc(2),
						type = "description",
						name = " ",
					},
					None = {
						order = inc(2),
						type = "color",
						name = L["DEBUFF"],
					},
					Magic = {
						order = inc(2),
						type = "color",
						name = L["MAGIC"],
					},
					Curse = {
						order = inc(2),
						type = "color",
						name = L["CURSE"],
					},
					Disease = {
						order = inc(2),
						type = "color",
						name = L["DISEASE"],
					},
					Poison = {
						order = inc(2),
						type = "color",
						name = L["POISON"],
					},
					Enrage = {
						order = inc(2),
						type = "color",
						name = L["ENRAGE"],
						get = function()
							return C.db.global.colors.buff[""]:GetRGB()
						end,
						set = function(_, r, g, b)
							if r ~= nil then
								local color = C.db.global.colors.buff[""]
								if color.r ~= r or color.g ~= g or color.g ~= b then
									color:SetRGB(r, g, b)
								end
							end
						end,
					},
					Enchant = {
						order = inc(2),
						type = "color",
						name = L["TEMP_ENCHANT"],
						get = function()
							return C.db.global.colors.buff.Enchant:GetRGB()
						end,
						set = function(_, r, g, b)
							if r ~= nil then
								local color = C.db.global.colors.buff.Enchant
								if color.r ~= r or color.g ~= g or color.g ~= b then
									color:SetRGB(r, g, b)
								end
							end
						end,
					},
				},
			},
			button = {
				order = inc(1),
				type = "group",
				name = L["BUTTON"],
				get = function(info)
					return C.db.global.colors.button[info[#info]]:GetRGB()
				end,
				set = function(info, r, g, b)
					if r ~= nil then
						local color = C.db.global.colors.button[info[#info]]
						if color.r ~= r or color.g ~= g or color.g ~= b then
							color:SetRGB(r, g, b)
						end

						BARS:ForEach("UpdateButtonConfig")
					end
				end,
				args = {
					reset = {
						type = "execute",
						order = reset(2),
						name = L["RESTORE_DEFAULTS"],
						confirm = CONFIG.ConfirmReset,
						func = function()
							for k, v in next, D.global.colors.button do
								C.db.global.colors.button[k]:SetRGB(v:GetRGB())
							end

							BARS:ForEach("UpdateButtonConfig")
						end,
					},
					spacer_1 = {
						order = inc(2),
						type = "description",
						name = " ",
					},
					normal = {
						order = inc(2),
						type = "color",
						name = L["USABLE"],
					},
					unusable = {
						order = inc(2),
						type = "color",
						name = L["UNUSABLE"],
					},
					mana = {
						order = inc(2),
						type = "color",
						name = L["OOM"],
					},
					range = {
						order = inc(2),
						type = "color",
						name = L["OOR"],
					},
					equipped = {
						order = inc(2),
						type = "color",
						name = L["EQUIPMENT"],
					},
				},
			},
			cooldown = {
				order = inc(1),
				type = "group",
				name = L["COOLDOWN"],
				get = function(info)
					return C.db.global.colors.cooldown[info[#info]]:GetRGB()
				end,
				set = function(info, r,g, b)
					if r ~= nil then
						local color = C.db.global.colors.cooldown[info[#info]]
						if color.r ~= r or color.g ~= g or color.g ~= b then
							color:SetRGB(r, g, b)
						end
					end
				end,
				args = {
					reset = {
						type = "execute",
						order = reset(2),
						name = L["RESTORE_DEFAULTS"],
						confirm = CONFIG.ConfirmReset,
						func = function()
							for k, v in next, D.global.colors.cooldown do
								C.db.global.colors.cooldown[k]:SetRGB(v:GetRGB())
							end
						end,
					},
					spacer_1 = {
						order = inc(2),
						type = "description",
						name = " ",
					},
					expiration = {
						order = inc(2),
						type = "color",
						name = L["EXPIRATION"],
					},
					second = {
						order = inc(2),
						type = "color",
						name = L["SECONDS"],
					},
					minute = {
						order = inc(2),
						type = "color",
						name = L["MINUTES"],
					},
					hour = {
						order = inc(2),
						type = "color",
						name = L["HOURS"],
					},
					day = {
						order = inc(2),
						type = "color",
						name = L["DAYS"],
					},
				},
			},
			zone = {
				order = inc(1),
				type = "group",
				name = L["ZONE"],
				get = function(info)
					return C.db.global.colors.zone[info[#info]]:GetRGB()
				end,
				set = function(info, r, g, b)
					if r ~= nil then
						local color = C.db.global.colors.zone[info[#info]]
						if color.r ~= r or color.g ~= g or color.g ~= b then
							color:SetRGB(r, g, b)

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
						order = reset(2),
						name = L["RESTORE_DEFAULTS"],
						confirm = CONFIG.ConfirmReset,
						func = function()
							for k, v in next, D.global.colors.zone do
								C.db.global.colors.zone[k]:SetRGB(v:GetRGB())
							end

							if MINIMAP:IsInit() then
								MINIMAP:GetMinimap():UpdateBorderColor()
								MINIMAP:GetMinimap():UpdateZoneColor()
							end
						end,
					},
					spacer_1 = {
						order = inc(2),
						type = "description",
						name = " ",
					},
					contested = {
						order = inc(2),
						type = "color",
						name = L["CONTESTED_TERRITORY"],
					},
					friendly = {
						order = inc(2),
						type = "color",
						name = L["FRIENDLY_TERRITORY"],
					},
					hostile = {
						order = inc(2),
						type = "color",
						name = L["HOSTILE_TERRITORY"],
					},
					sanctuary = {
						order = inc(2),
						type = "color",
						name = L["SANCTUARY"],
					},
				},
			},
		},
	}
end
