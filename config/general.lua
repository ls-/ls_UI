local _, ns = ...
local E, C, M, L, P, D = ns.E, ns.C, ns.M, ns.L, ns.P, ns.D
local CONFIG = P:GetModule("Config")
local BARS = P:GetModule("Bars")
local MINIMAP = P:GetModule("Minimap")
local UNITFRAMES = P:GetModule("UnitFrames")
local BLIZZARD = P:GetModule("Blizzard")

-- Lua
local _G = getfenv(0)
local tonumber = _G.tonumber
local next = _G.next
local type = _G.type

--[[ luacheck: globals
	GetText UnitSex
]]

-- Mine
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
					return E:GetRGB(C.db.profile.colors[info[#info]])
				end,
				args = {
					health = {
						order = 1,
						type = "group",
						name = L["HEALTH"],
						set = function(info, r, g, b)
							if r ~= nil then
								info = info[#info]

								local color = C.db.profile.colors[info]
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
								func = function()
									E:SetRGB(C.db.profile.colors.health, E:GetRGB(D.profile.colors.health))
									E:SetRGB(C.db.profile.colors.disconnected, E:GetRGB(D.profile.colors.disconnected))
									E:SetRGB(C.db.profile.colors.tapped, E:GetRGB(D.profile.colors.tapped))

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
								name = L["DISCONNECTED"],
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
							return E:GetRGB(C.db.profile.colors.power[info[#info]])
						end,
						set = function(info, r, g, b)
							if r ~= nil then
								info = info[#info]

								local color
								if info == "RUNES_BLOOD" then
									color = C.db.profile.colors.rune[1]
								elseif info == "RUNES_FROST" then
									color = C.db.profile.colors.rune[2]
								elseif info == "RUNES_UNHOLY" then
									color = C.db.profile.colors.rune[3]
								elseif info == "STAGGER_LOW" then
									color = C.db.profile.colors.power.STAGGER[1]
								elseif info == "STAGGER_MEDIUM" then
									color = C.db.profile.colors.power.STAGGER[2]
								elseif info == "STAGGER_HIGH" then
									color = C.db.profile.colors.power.STAGGER[3]
								else
									color = C.db.profile.colors.power[info]
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
								func = function()
									for k, v in next, D.profile.colors.power do
										if type(k) == "string" then
											if type(v[1]) == "table" then
												for i, v_ in next, v do
													E:SetRGB(C.db.profile.colors.power[k][i], E:GetRGB(v_))
												end
											else
												E:SetRGB(C.db.profile.colors.power[k], E:GetRGB(v))
											end
										end
									end

									for k, v in next, D.profile.colors.rune do
										E:SetRGB(C.db.profile.colors.rune[k], E:GetRGB(v))
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
									return E:GetRGB(C.db.profile.colors.rune[1])
								end,
							},
							RUNES_FROST = {
								order = 17,
								type = "color",
								name = L["RUNES_FROST"],
								get = function()
									return E:GetRGB(C.db.profile.colors.rune[2])
								end,
							},
							RUNES_UNHOLY = {
								order = 18,
								type = "color",
								name = L["RUNES_UNHOLY"],
								get = function()
									return E:GetRGB(C.db.profile.colors.rune[3])
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
							MAELSTROM = {
								order = 23,
								type = "color",
								name = L["MAELSTROM"],
							},
							INSANITY = {
								order = 24,
								type = "color",
								name = L["INSANITY"],
							},
							CHI = {
								order = 25,
								type = "color",
								name = L["CHI"],
							},
							ARCANE_CHARGES = {
								order = 26,
								type = "color",
								name = L["ARCANE_CHARGES"],
							},
							FURY = {
								order = 27,
								type = "color",
								name = L["FURY"],
							},
							PAIN = {
								order = 28,
								type = "color",
								name = L["PAIN"],
							},
							STAGGER_LOW = {
								order = 29,
								type = "color",
								name = L["STAGGER_LOW"],
								get = function()
									return E:GetRGB(C.db.profile.colors.power.STAGGER[1])
								end,
							},
							STAGGER_MEDIUM = {
								order = 30,
								type = "color",
								name = L["STAGGER_MEDIUM"],
								get = function()
									return E:GetRGB(C.db.profile.colors.power.STAGGER[2])
								end,
							},
							STAGGER_HIGH = {
								order = 31,
								type = "color",
								name = L["STAGGER_HIGH"],
								get = function()
									return E:GetRGB(C.db.profile.colors.power.STAGGER[3])
								end,
							},
							ALT_POWER = {
								order = 32,
								type = "color",
								name = L["ALTERNATIVE_POWER"],
							},
						},
					},
					change = {
						order = 3,
						type = "group",
						name = L["GAIN_LOSS"],
						set = function(info, r, g, b)
							if r ~= nil then
								local color = C.db.profile.colors[info[#info]]
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
								func = function()
									E:SetRGB(C.db.profile.colors.gain, E:GetRGB(D.profile.colors.gain))
									E:SetRGB(C.db.profile.colors.loss, E:GetRGB(D.profile.colors.loss))

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
							return E:GetRGBA(C.db.profile.colors.prediction[info[#info]])
						end,
						set = function(info, r, g, b)
							if r ~= nil then
								local color = C.db.profile.colors.prediction[info[#info]]
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
								func = function()
									for k, v in next, D.profile.colors.prediction do
										E:SetRGB(C.db.profile.colors.prediction[k], E:GetRGB(v))
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
								name = L["PERSONAL"],
								hasAlpha = true,
							},
							other_heal = {
								order = 11,
								type = "color",
								name = L["OTHERS"],
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
					selection = {
						order = 5,
						type = "group",
						name = L["SELECTION"],
						get = function(info)
							return E:GetRGB(C.db.profile.colors.selection[tonumber(info[#info])])
						end,
						set = function(info, r, g, b)
							if r ~= nil then
								local color = C.db.profile.colors.selection[tonumber(info[#info])]
								if color.r ~= r or color.g ~= g or color.g ~= b then
									E:SetRGB(color, r, g, b)

									UNITFRAMES:UpdateSelectionColors()
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
								func = function()
									for k, v in next, D.profile.colors.selection do
										E:SetRGB(C.db.profile.colors.selection[k], E:GetRGB(v))
									end

									UNITFRAMES:UpdateSelectionColors()
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
								name = L["PERSONAL"],
								desc = L["PERSONAL_DESC"],
							},
							["4"] = {
								order = 11,
								type = "color",
								name = GetText("FACTION_STANDING_LABEL2", 2),
							},
							["3"] = {
								order = 12,
								type = "color",
								name = GetText("FACTION_STANDING_LABEL3", 2),
							},
							["2"] = {
								order = 13,
								type = "color",
								name = GetText("FACTION_STANDING_LABEL4", 2),
							},
							["6"] = {
								order = 14,
								type = "color",
								name = GetText("FACTION_STANDING_LABEL5", 2),
							},
							["5"] = {
								order = 15,
								type = "color",
								name = L["DEAD"],
							},
							["7"] = {
								order = 16,
								type = "color",
								name = L["DEFAULT"],
								desc = L["SELECTION_DEFAULT_DESC"],
							},
						},
					},
					reaction = {
						order = 6,
						type = "group",
						name = L["REACTION"],
						get = function(info)
							return E:GetRGB(C.db.profile.colors.reaction[tonumber(info[#info])])
						end,
						set = function(info, r, g, b)
							if r ~= nil then
								local color = C.db.profile.colors.reaction[tonumber(info[#info])]
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
								func = function()
									for k, v in next, D.profile.colors.reaction do
										E:SetRGB(C.db.profile.colors.reaction[k], E:GetRGB(v))
									end

									UNITFRAMES:UpdateSelectionColors()
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
								name = GetText("FACTION_STANDING_LABEL1", 2),
							},
							["2"] = {
								order = 11,
								type = "color",
								name = GetText("FACTION_STANDING_LABEL2", 2),
							},
							["3"] = {
								order = 12,
								type = "color",
								name = GetText("FACTION_STANDING_LABEL3", 2),
							},
							["4"] = {
								order = 13,
								type = "color",
								name = GetText("FACTION_STANDING_LABEL4", 2),
							},
							["5"] = {
								order = 14,
								type = "color",
								name = GetText("FACTION_STANDING_LABEL5", 2),
							},
							["6"] = {
								order = 15,
								type = "color",
								name = GetText("FACTION_STANDING_LABEL6", 2),
							},
							["7"] = {
								order = 16,
								type = "color",
								name = GetText("FACTION_STANDING_LABEL7", 2),
							},
							["8"] = {
								order = 17,
								type = "color",
								name = GetText("FACTION_STANDING_LABEL8", 2),
							},
						},
					},
					faction = {
						order = 7,
						type = "group",
						name = L["FACTION"],
						get = function(info)
							return E:GetRGB(C.db.profile.colors.faction[info[#info]])
						end,
						set = function(info, r, g, b)
							if r ~= nil then
								local color = C.db.profile.colors.faction[info[#info]]
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
								func = function()
									for k, v in next, D.profile.colors.faction do
										E:SetRGB(C.db.profile.colors.faction[k], E:GetRGB(v))
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
						order = 8,
						type = "group",
						name = L["EXPERIENCE"],
						get = function(info)
							return E:GetRGB(C.db.profile.colors.xp[tonumber(info[#info])])
						end,
						set = function(info, r, g, b)
							if r ~= nil then
								local color = C.db.profile.colors.xp[tonumber(info[#info])]
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
								func = function()
									for k, v in next, D.profile.colors.xp do
										E:SetRGB(C.db.profile.colors.xp[k], E:GetRGB(v))
									end

									E:SetRGB(C.db.profile.colors.artifact, E:GetRGB(D.profile.colors.artifact))
									E:SetRGB(C.db.profile.colors.honor, E:GetRGB(D.profile.colors.honor))

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
									return E:GetRGB(C.db.profile.colors.artifact)
								end,
								set = function(_, r, g, b)
									if r ~= nil then
										local color = C.db.profile.colors.artifact
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
									return E:GetRGB(C.db.profile.colors.honor)
								end,
								set = function(_, r, g, b)
									if r ~= nil then
										local color = C.db.profile.colors.honor
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
						order = 9,
						type = "group",
						name = L["DIFFICULTY"],
						get = function(info)
							return E:GetRGB(C.db.profile.colors.difficulty[info[#info]])
						end,
						set = function(info, r, g, b)
							if r ~= nil then
								local color = C.db.profile.colors.difficulty[info[#info]]
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
								func = function()
									for k, v in next, D.profile.colors.difficulty do
										E:SetRGB(C.db.profile.colors.difficulty[k], E:GetRGB(v))
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
						order = 10,
						type = "group",
						name = L["CASTBAR"],
						get = function(info)
							return E:GetRGB(C.db.profile.colors.castbar[info[#info]])
						end,
						set = function(info, r, g, b)
							if r ~= nil then
								local color = C.db.profile.colors.castbar[info[#info]]
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
								func = function()
									for k, v in next, D.profile.colors.castbar do
										E:SetRGB(C.db.profile.colors.castbar[k], E:GetRGB(v))
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
						order = 11,
						type = "group",
						name = L["AURA"],
						get = function(info)
							return E:GetRGB(C.db.profile.colors.debuff[info[#info]])
						end,
						set = function(info, r, g, b)
							if r ~= nil then
								local color = C.db.profile.colors.debuff[info[#info]]
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
								func = function()
									for k, v in next, D.profile.colors.debuff do
										E:SetRGB(C.db.profile.colors.debuff[k], E:GetRGB(v))
									end

									for k, v in next, D.profile.colors.buff do
										E:SetRGB(C.db.profile.colors.buff[k], E:GetRGB(v))
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
									return E:GetRGB(C.db.profile.colors.buff.Enchant)
								end,
								set = function(_, r, g, b)
									if r ~= nil then
										local color = C.db.profile.colors.buff.Enchant
										if color.r ~= r or color.g ~= g or color.g ~= b then
											E:SetRGB(color, r, g, b)
										end
									end
								end,
							},
						},
					},
					button = {
						order = 12,
						type = "group",
						name = L["BUTTON"],
						get = function(info)
							return E:GetRGB(C.db.profile.colors.button[info[#info]])
						end,
						set = function(info, r, g, b)
							if r ~= nil then
								local color = C.db.profile.colors.button[info[#info]]
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
								func = function()
									for k, v in next, D.profile.colors.button do
										E:SetRGB(C.db.profile.colors.button[k], E:GetRGB(v))
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
						order = 13,
						type = "group",
						name = L["COOLDOWN"],
						get = function(info)
							return E:GetRGB(C.db.profile.colors.cooldown[info[#info]])
						end,
						set = function(info, r,g, b)
							if r ~= nil then
								local color = C.db.profile.colors.cooldown[info[#info]]
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
								func = function()
									for k, v in next, D.profile.colors.cooldown do
										E:SetRGB(C.db.profile.colors.cooldown[k], E:GetRGB(v))
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
						order = 14,
						type = "group",
						name = L["ZONE"],
						get = function(info)
							return E:GetRGB(C.db.profile.colors.zone[info[#info]])
						end,
						set = function(info, r, g, b)
							if r ~= nil then
								local color = C.db.profile.colors.zone[info[#info]]
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
								func = function()
									for k, v in next, D.profile.colors.zone do
										E:SetRGB(C.db.profile.colors.zone[k], E:GetRGB(v))
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
		},
	}
end
