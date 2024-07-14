-- Lua
local _G = getfenv(0)
local unpack = _G.unpack

-- Mine
local E, M, L, C, D, PrC, PrD, P, oUF, CONFIG = unpack(ls_UI)

local orders = {}

local function reset(order)
	orders[order] = 1
	return orders[order]
end

local function inc(order)
	orders[order] = orders[order] + 1
	return orders[order]
end

local DESC_FORMAT = "|cffffd200%s v|r%s"

function CONFIG:CreateAboutPanel(order)
	local options = {
		order = order,
		type = "group",
		name = "|cff1a9fc0" .. L["INFORMATION"] .. "|r",
		args = {
			desc = {
				order = reset(1),
				type = "description",
				name = DESC_FORMAT:format(L["LS_UI"], E.VER.string),
				width = "full",
				fontSize = "medium",
			},
			spacer_1 = CONFIG:CreateSpacer(inc(1)),
			support = {
				order = inc(1),
				type = "group",
				name = L["SUPPORT"],
				inline = true,
				args = {
					discord = {
						order = reset(2),
						type = "execute",
						name = L["DISCORD"],
						func = function()
							CONFIG:ShowLinkCopyPopup("https://discord.gg/7QcJgQkDYD")
						end,
					},
					github = {
						order = inc(2),
						type = "execute",
						name = L["GITHUB"],
						func = function()
							CONFIG:ShowLinkCopyPopup("https://github.com/ls-/ls_UI/issues")
						end,
					},
				},
			},
			spacer_2 = CONFIG:CreateSpacer(inc(1)),
			downloads = {
				order = inc(1),
				type = "group",
				name = L["DOWNLOADS"],
				inline = true,
				args = {
					wowi = {
						order = reset(2),
						type = "execute",
						name = L["WOWINTERFACE"],
						func = function()
							CONFIG:ShowLinkCopyPopup("https://www.wowinterface.com/downloads/info22662.html")
						end,
					},
					cf = {
						order = inc(2),
						type = "execute",
						name = L["CURSEFORGE"],
						func = function()
							CONFIG:ShowLinkCopyPopup("https://www.curseforge.com/wow/addons/ls-ui")
						end,
					},
					wago = {
						order = inc(2),
						type = "execute",
						name = L["WAGO"],
						func = function()
							CONFIG:ShowLinkCopyPopup("https://addons.wago.io/addons/ls-ui")
						end,
					},
				},
			},
			spacer_3 = CONFIG:CreateSpacer(inc(1)),
			CHANGELOG = {
				order = inc(1),
				type = "group",
				name = L["CHANGELOG"],
				inline = true,
				args = {
					latest = {
						order = reset(2),
						type = "description",
						name = E.CHANGELOG,
						width = "full",
						fontSize = "medium",
					},
					spacer_1 = CONFIG:CreateSpacer(inc(2)),
					cf = {
						order = inc(2),
						type = "execute",
						name = L["FULL_CHANGELOG"],
						func = function()
							CONFIG:ShowLinkCopyPopup("https://github.com/ls-/ls_UI/blob/master/CHANGELOG.md")
						end,
					},
				},
			},
		},
	}

	return options
end
