-- Lua
local _G = getfenv(0)
local unpack = _G.unpack

-- Mine
local E, M, L, C, D, PrC, PrD, P, oUF, CONFIG = unpack(ls_UI)
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

local function isModuleDisabledOrRestricted()
	return BARS:IsRestricted() or not BARS:IsInit()
end

local function isPetBattleBarDisabledOrRestricted()
	return BARS:IsRestricted() or not BARS:HasPetBattleBar()
end

local function isXPBarDisabledOrRestricted()
	return BARS:IsRestricted() or not BARS:HasXPBar()
end

local function isFadingDisabled(info)
	return not (BARS:IsInit() and C.db.profile.bars[info[#info - 2]].fade.enabled)
end

function CONFIG:CreateBarFadingOptions(order, barID)
	local temp = {
		order = order,
		type = "group",
		name = L["FADING"],
		inline = true,
		get = function(info)
			return C.db.profile.bars[barID].fade[info[#info]]
		end,
		set = function(info, value)
			C.db.profile.bars[barID].fade[info[#info]] = value

			BARS:For(barID, "UpdateConfig")
			BARS:For(barID, "UpdateFading")
		end,
		args = {
			enabled = {
				order = reset(1),
				type = "toggle",
				name = L["ENABLE"],
			},
			reset = {
				order = inc(1),
				type = "execute",
				name = L["RESET_TO_DEFAULT"],
				disabled = isFadingDisabled,
				confirm = CONFIG.ConfirmReset,
				func = function()
					CONFIG:CopySettings(D.profile.bars[barID].fade, C.db.profile.bars[barID].fade, {enabled = true})

					BARS:For(barID, "UpdateConfig")
					BARS:For(barID, "UpdateFading")
				end,
			},
			spacer_1 = CONFIG:CreateSpacer(inc(1)),
			combat = {
				order = inc(1),
				type = "toggle",
				name = L["COMBAT"],
				disabled = isFadingDisabled,
			},
			target = {
				order = inc(1),
				type = "toggle",
				name = L["TARGET"],
				disabled = isFadingDisabled,
			},
			health = {
				order = inc(1),
				type = "toggle",
				name = L["HEALTH"],
				desc = L["HEALTH_FADING_DESC"],
				disabled = isFadingDisabled,
			},
			in_duration = {
				order = inc(1),
				type = "range",
				name = L["FADE_IN_DURATION"],
				min = 0.05, max = 1, step = 0.05,
				disabled = isFadingDisabled,
			},
			out_delay = {
				order = inc(1),
				type = "range",
				name = L["FADE_OUT_DELAY"],
				min = 0, max = 2, step = 0.05,
				disabled = isFadingDisabled,
			},
			out_duration = {
				order = inc(1),
				type = "range",
				name = L["FADE_OUT_DURATION"],
				min = 0.05, max = 1, step = 0.05,
				disabled = isFadingDisabled,
			},
			min_alpha = {
				order = inc(1),
				type = "range",
				name = L["MIN_ALPHA"],
				min = 0, max = 1, step = 0.05,
				disabled = isFadingDisabled,
			},
			max_alpha = {
				order = inc(1),
				type = "range",
				name = L["MAX_ALPHA"],
				min = 0, max = 1, step = 0.05,
				disabled = isFadingDisabled,
			},
		},
	}

	if barID == "bar1" then
		temp.disabled = isModuleDisabledOrRestricted
	elseif barID == "pet_battle" then
		temp.disabled = isPetBattleBarDisabledOrRestricted
	elseif barID == "xpbar" then
		temp.disabled = isXPBarDisabledOrRestricted
	end

	return temp
end
