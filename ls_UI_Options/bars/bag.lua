local _, CONFIG = ...

-- Lua
local _G = getfenv(0)
local t_wipe = _G.table.wipe
local tonumber = _G.tonumber
local unpack = _G.unpack

-- Mine
local E, M, L, C, D, PrC, PrD, P, oUF = unpack(ls_UI)
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

local currencyOptionTables = {
	["error"] = {
		order = 1,
		type = "description",
		name = L["NOTHING_TO_SHOW"],
	},
}

local function updateCurrencyOptions()
	local options = CONFIG.options.args.bars.args.bag.args.currency.args
	local listSize = C_CurrencyInfo.GetCurrencyListSize()
	local info, id, link

	t_wipe(options)

	if listSize > 0 then
		for i = 1, listSize do
			info = C_CurrencyInfo.GetCurrencyListInfo(i)
			if info.isHeader then
				id = info.name:gsub("%s", ""):lower()
				if not currencyOptionTables[id] then
					currencyOptionTables[id] = {
						type = "description",
						name = "|cffffd200" .. info.name .. "|r",
						fontSize = "medium",
					}
				end
			else
				link = C_CurrencyInfo.GetCurrencyListLink(i)
				if link then
					id = link:match("currency:(%d+)")
					if id then
						if not currencyOptionTables[id] then
							currencyOptionTables[id] = {
								type = "toggle",
								name = info.name,
								image = info.iconFileID,
							}
						end
					end
				end
			end

			if id then
				currencyOptionTables[id].order = i

				options[id] = currencyOptionTables[id]
			end
		end
	else
		options.error = currencyOptionTables.error
	end
end

local function isModuleDisabled()
	return not BARS:IsInit()
end

function CONFIG:CreateBagOptions(order)
	self:AddCallback(function()
		updateCurrencyOptions()

		E:RegisterEvent("CURRENCY_DISPLAY_UPDATE", updateCurrencyOptions)
	end)

	return {
		order = order,
		type = "group",
		name = L["BACKPACK"],
		disabled = isModuleDisabled,
		args = {
			reset = {
				type = "execute",
				order = reset(1),
				name = L["RESTORE_DEFAULTS"],
				confirm = CONFIG.ConfirmReset,
				func = function()
					CONFIG:CopySettings(D.profile.bars.bag, C.db.profile.bars.bag, {currency = true, point = true})
					BARS:UpdateBag()
				end,
			},
			spacer_1 = {
				order = inc(1),
				type = "description",
				name = " ",
			},
			tooltip = {
				order = inc(1),
				type = "toggle",
				name = L["ENHANCED_TOOLTIPS"],
				desc = L["BAG_TOOLTIP_DESC"],
				get = function()
					return C.db.profile.bars.bag.tooltip
				end,
				set = function(_, value)
					C.db.profile.bars.bag.tooltip = value

					BARS:For("bag", "UpdateConfig")
				end,
			},
			spacer_2 = {
				order = inc(1),
				type = "description",
				name = " ",
			},
			currency = {
				order = inc(1),
				type = "group",
				name = L["CURRENCY"],
				inline = true,
				get = function(info)
					return C.db.profile.bars.bag.currency[tonumber(info[#info])]
				end,
				set = function(info, value)
					C.db.profile.bars.bag.currency[tonumber(info[#info])] = value and value or nil
				end,
				args = {},
			},
			spacer_3 = {
				order = inc(1),
				type = "description",
				name = " ",
			},
			fading = CONFIG:CreateBarFadingOptions(inc(1), "bag"),
		},
	}
end
