local _, CONFIG = ...

-- Lua
local _G = getfenv(0)
local unpack = _G.unpack

-- Mine
local E, M, L, C, D, PrC, PrD, P, oUF = unpack(ls_UI)
local BARS = P:GetModule("Bars")

local orders = {}

local function reset(order)
	orders[order] = 1
	return orders[order]
end

local function inc(order)
	orders[order] = orders[order] + 1
	return orders[order]
end

local V_ALIGNMENTS = {
	["BOTTOM"] = "BOTTOM",
	["MIDDLE"] = "MIDDLE",
	["TOP"] = "TOP",
}

local function isModuleDisabled()
	return not BARS:IsInit()
end

function CONFIG:CreateExtraBarOptions(order, barID, name)
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
				order = reset(1),
				name = L["RESTORE_DEFAULTS"],
				confirm = CONFIG.ConfirmReset,
				func = function()
					CONFIG:CopySettings(D.profile.bars[barID], C.db.profile.bars[barID], {visible = true, point = true})
					BARS:For(barID, "Update")
				end,
			},
			spacer_1 = {
				order = inc(1),
				type = "description",
				name = " ",
			},
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
			artwork = {
				order = inc(1),
				type = "toggle",
				name = L["SHOW_ARTWORK"],
				set = function(_, value)
					C.db.profile.bars[barID].artwork = value

					BARS:For(barID, "UpdateConfig")
					BARS:For(barID, "UpdateArtwork")
				end,
			},
			spacer_2 = {
				order = inc(1),
				type = "description",
				name = " ",
			},
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
						order = reset(2),
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
						order = inc(2),
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
			spacer_3 = {
				order = inc(1),
				type = "description",
				name = " ",
			},
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
						order = reset(2),
						type = "toggle",
						name = L["SHOW"],
					},
					size = {
						order = inc(2),
						type = "range",
						name = L["SIZE"],
						min = 8, max = 48, step = 1,
					},
					v_alignment = {
						order = inc(2),
						type = "select",
						name = L["TEXT_VERT_ALIGNMENT"],
						values = V_ALIGNMENTS,
					},
				},
			},
			spacer_4 = {
				order = inc(1),
				type = "description",
				name = " ",
			},
			fading = CONFIG:CreateBarFadingOptions(inc(1), barID),
		},
	}

	if barID == "zone" then
		temp.args.spacer_2 = nil
		temp.args.hotkey = nil
	end

	return temp
end
