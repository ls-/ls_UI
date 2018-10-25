local _, ns = ...
local E, C, M, L, P, D = ns.E, ns.C, ns.M, ns.L, ns.P, ns.D
local CONFIG = P:GetModule("Config")

-- Lua
local _G = getfenv(0)
local tonumber = _G.tonumber

--[[ luacheck: globals
	GetText UnitSex
]]

-- Mine
function CONFIG:CreateGeneralPanel(order)
	C.options.args.general = {
		order = order,
		type = "group",
		childGroups = "tab",
		name = "[WIP] General",
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
					gain = {
						order = 1,
						type = "color",
						name = L["RESOURCE_GAIN"]
					},
					loss = {
						order = 2,
						type = "color",
						name = L["RESOURCE_LOSS"]
					},
					health = {
						order = 1,
						type = "group",
						name = L["HEALTH"],
						args = {
							health = {
								order = 1,
								type = "color",
								name = L["HEALTH"],
							},
							disconnected = {
								order = 2,
								type = "color",
								name = L["DISCONNECTED"],
							},
							tapped = {
								order = 3,
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
						args = {
							MANA = {
								order = 1,
								type = "color",
								name = L["MANA"],
							},
							RAGE = {
								order = 2,
								type = "color",
								name = L["RAGE"],
							},
							FOCUS = {
								order = 3,
								type = "color",
								name = L["FOCUS"],
							},
							ENERGY = {
								order = 4,
								type = "color",
								name = L["ENERGY"],
							},
							COMBO_POINTS = {
								order = 5,
								type = "color",
								name = L["COMBO_POINTS"],
							},
							RUNES = {
								order = 6,
								type = "color",
								name = L["RUNES"],
							},
							RUNES_BLOOD = {
								order = 7,
								type = "color",
								name = L["RUNES_BLOOD"],
								get = function()
									return E:GetRGB(C.db.profile.colors.rune[1])
								end,
							},
							RUNES_FROST = {
								order = 8,
								type = "color",
								name = L["RUNES_FROST"],
								get = function()
									return E:GetRGB(C.db.profile.colors.rune[2])
								end,
							},
							RUNES_UNHOLY = {
								order = 9,
								type = "color",
								name = L["RUNES_UNHOLY"],
								get = function()
									return E:GetRGB(C.db.profile.colors.rune[3])
								end,
							},
							RUNIC_POWER = {
								order = 10,
								type = "color",
								name = L["RUNIC_POWER"],
							},
							SOUL_SHARDS = {
								order = 11,
								type = "color",
								name = L["SOUL_SHARDS"],
							},
							LUNAR_POWER = {
								order = 12,
								type = "color",
								name = L["LUNAR_POWER"],
							},
							HOLY_POWER = {
								order = 13,
								type = "color",
								name = L["HOLY_POWER"],
							},
							MAELSTROM = {
								order = 14,
								type = "color",
								name = L["MAELSTROM"],
							},
							INSANITY = {
								order = 15,
								type = "color",
								name = L["INSANITY"],
							},
							CHI = {
								order = 16,
								type = "color",
								name = L["CHI"],
							},
							ARCANE_CHARGES = {
								order = 17,
								type = "color",
								name = L["ARCANE_CHARGES"],
							},
							FURY = {
								order = 18,
								type = "color",
								name = L["FURY"],
							},
							PAIN = {
								order = 19,
								type = "color",
								name = L["PAIN"],
							},
							STAGGER_LOW = {
								order = 20,
								type = "color",
								name = L["STAGGER_LOW"],
								get = function()
									return E:GetRGB(C.db.profile.colors.power.STAGGER[1])
								end,
							},
							STAGGER_MEDIUM = {
								order = 21,
								type = "color",
								name = L["STAGGER_MEDIUM"],
								get = function()
									return E:GetRGB(C.db.profile.colors.power.STAGGER[2])
								end,
							},
							STAGGER_HIGH = {
								order = 22,
								type = "color",
								name = L["STAGGER_HIGH"],
								get = function()
									return E:GetRGB(C.db.profile.colors.power.STAGGER[3])
								end,
							},
							ALT_POWER = {
								order = 23,
								type = "color",
								name = L["ALTERNATIVE_POWER"],
							},
						},
					},
					prediction = {
						order = 3,
						type = "group",
						name = L["PREDICTION"],
						get = function(info)
							return E:GetRGBA(C.db.profile.colors.prediction[info[#info]])
						end,
						args = {
							my_heal = {
								order = 1,
								type = "color",
								name = L["PERSONAL"],
								hasAlpha = true,
							},
							other_heal = {
								order = 2,
								type = "color",
								name = L["OTHERS"],
								hasAlpha = true,
							},
							damage_absorb = {
								order = 3,
								type = "color",
								name = L["DAMAGE_ABSORB"],
								hasAlpha = true,
							},
							heal_absorb = {
								order = 4,
								type = "color",
								name = L["HEAL_ABSORB"],
								hasAlpha = true,
							},
							power_cost = {
								order = 5,
								type = "color",
								name = L["POWER_COST"],
								hasAlpha = true,
							},
						},
					},
					selection = {
						order = 4,
						type = "group",
						name = L["SELECTION"],
						get = function(info)
							return E:GetRGB(C.db.profile.colors.selection[tonumber(info[#info])])
						end,
						args = {
							["1"] = {
								order = 1,
								type = "color",
								name = [[[WIP] Personal]],
								desc = [[Used for your character while in combat.]],
							},
							["7"] = {
								order = 2,
								type = "color",
								name = [[[WIP] Players]],
								desc = [[Used for players in dungeons, raids, sanctuaries.]],
							},
							["4"] = {
								order = 3,
								type = "color",
								name = [[[WIP] Hostile]],
							},
							["3"] = {
								order = 4,
								type = "color",
								name = [[[WIP] Unfriendly]],
							},
							["2"] = {
								order = 5,
								type = "color",
								name = [[[WIP] Neutral]],
							},
							["6"] = {
								order = 6,
								type = "color",
								name = [[[WIP] Friendly]],
							},
							["5"] = {
								order = 7,
								type = "color",
								name = [[[WIP] Dead]],
							},
						},
					},
					reaction = {
						order = 5,
						type = "group",
						name = L["REACTION"],
						get = function(info)
							return E:GetRGB(C.db.profile.colors.reaction[tonumber(info[#info])])
						end,
						args = {
							["1"] = {
								order = 1,
								type = "color",
								name = GetText("FACTION_STANDING_LABEL1", UnitSex("player")),
							},
							["2"] = {
								order = 2,
								type = "color",
								name = GetText("FACTION_STANDING_LABEL2", UnitSex("player")),
							},
							["3"] = {
								order = 3,
								type = "color",
								name = GetText("FACTION_STANDING_LABEL3", UnitSex("player")),
							},
							["4"] = {
								order = 4,
								type = "color",
								name = GetText("FACTION_STANDING_LABEL4", UnitSex("player")),
							},
							["5"] = {
								order = 5,
								type = "color",
								name = GetText("FACTION_STANDING_LABEL5", UnitSex("player")),
							},
							["6"] = {
								order = 6,
								type = "color",
								name = GetText("FACTION_STANDING_LABEL6", UnitSex("player")),
							},
							["7"] = {
								order = 7,
								type = "color",
								name = GetText("FACTION_STANDING_LABEL7", UnitSex("player")),
							},
							["8"] = {
								order = 8,
								type = "color",
								name = GetText("FACTION_STANDING_LABEL8", UnitSex("player")),
							},
						},
					},
					faction = {
						order = 6,
						type = "group",
						name = L["FACTION"],
						get = function(info)
							return E:GetRGB(C.db.profile.colors.faction[info[#info]])
						end,
						args = {
							Alliance = {
								order = 1,
								type = "color",
								name = L["FACTION_ALLIANCE"],
							},
							Horde = {
								order = 2,
								type = "color",
								name = L["FACTION_HORDE"],
							},
							Neutral = {
								order = 3,
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
							return E:GetRGB(C.db.profile.colors.xp[tonumber(info[#info])])
						end,
						args = {
							["1"] = {
								order = 1,
								type = "color",
								name = L["EXPERIENCE_RESTED"],
							},
							["2"] = {
								order = 2,
								type = "color",
								name = L["EXPERIENCE_NORMAL"],
							},
							artifact = {
								order = 3,
								type = "color",
								name = L["ARTIFACT_POWER"],
								get = function()
									return E:GetRGB(C.db.profile.colors.artifact)
								end,
							},
							honor = {
								order = 3,
								type = "color",
								name = L["HONOR"],
								get = function()
									return E:GetRGB(C.db.profile.colors.honor)
								end,
							},
						},
					},
					difficulty = {
						order = 8,
						type = "group",
						name = L["DIFFICULTY"],
						get = function(info)
							return E:GetRGB(C.db.profile.colors.difficulty[info[#info]])
						end,
						args = {
							trivial = {
								order = 1,
								type = "color",
								name = L["TRIVIAL"],
							},
							standard = {
								order = 2,
								type = "color",
								name = L["STANDARD"],
							},
							difficult = {
								order = 3,
								type = "color",
								name = L["DIFFICULT"],
							},
							very_difficult = {
								order = 4,
								type = "color",
								name = L["VERY_DIFFICULT"],
							},
							impossible = {
								order = 5,
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
							return E:GetRGB(C.db.profile.colors.castbar[info[#info]])
						end,
						args = {
							casting = {
								order = 1,
								type = "color",
								name = L["SPELL_CAST"],
							},
							channeling = {
								order = 2,
								type = "color",
								name = L["SPELL_CHANNELED"],
							},
							failed = {
								order = 3,
								type = "color",
								name = L["SPELL_FAILED"],
							},
							notinterruptible = {
								order = 4,
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
							return E:GetRGB(C.db.profile.colors.debuff[info[#info]])
						end,
						args = {
							None = {
								order = 1,
								type = "color",
								name = L["DEBUFF"],
							},
							Magic = {
								order = 2,
								type = "color",
								name = L["MAGIC"],
							},
							Curse = {
								order = 3,
								type = "color",
								name = L["CURSE"],
							},
							Disease = {
								order = 4,
								type = "color",
								name = L["DISEASE"],
							},
							Poison = {
								order = 5,
								type = "color",
								name = L["POISON"],
							},
							Enchant = {
								order = 6,
								type = "color",
								name = L["TEMP_ENCHANT"],
								get = function(info)
									return E:GetRGB(C.db.profile.colors.buff[info[#info]])
								end,
							},
						},
					},
					button = {
						order = 11,
						type = "group",
						name = L["BUTTON"],
						get = function(info)
							return E:GetRGB(C.db.profile.colors.button[info[#info]])
						end,
						args = {
							normal = {
								order = 1,
								type = "color",
								name = L["USABLE"],
							},
							unusable = {
								order = 2,
								type = "color",
								name = L["UNUSABLE"],
							},
							mana = {
								order = 3,
								type = "color",
								name = L["OOM"],
							},
							range = {
								order = 4,
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
							return E:GetRGB(C.db.profile.colors.cooldown[info[#info]])
						end,
						args = {
							expiration = {
								order = 1,
								type = "color",
								name = L["EXPIRATION"],
							},
							second = {
								order = 2,
								type = "color",
								name = L["SECONDS"],
							},
							minute = {
								order = 3,
								type = "color",
								name = L["MINUTES"],
							},
							hour = {
								order = 4,
								type = "color",
								name = L["HOURS"],
							},
							day = {
								order = 5,
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
							return E:GetRGB(C.db.profile.colors.zone[info[#info]])
						end,
						args = {
							contested = {
								order = 1,
								type = "color",
								name = L["CONTESTED_TERRITORY"],
							},
							friendly = {
								order = 2,
								type = "color",
								name = L["FRIENDLY_TERRITORY"],
							},
							hostile = {
								order = 3,
								type = "color",
								name = L["HOSTILE_TERRITORY"],
							},
							sanctuary = {
								order = 4,
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
