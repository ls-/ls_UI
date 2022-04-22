local _, CONFIG = ...

-- Lua
local _G = getfenv(0)
local unpack = _G.unpack

-- Mine
local E, M, L, C, D, PrC, PrD, P, oUF = unpack(ls_UI)

function CONFIG:GetGeneralOptions(order)
	self.options.args.general = {
		order = order,
		type = "group",
		childGroups = "tab",
		name = L["GENERAL"],
		args = {},
	}

	self:GetColorsOptions(1)
	self:GetFontsOptions(2)
	self:GetTagsOptions(3)
	self:GetTagVarsOptions(4)
	self:GetAuraFiltersOptions(5)
end
