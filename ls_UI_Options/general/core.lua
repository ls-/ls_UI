-- Lua
local _G = getfenv(0)
local unpack = _G.unpack

-- Mine
local E, M, L, C, D, PrC, PrD, P, oUF, CONFIG = unpack(ls_UI)

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
	self:GetTexturesOptions(3)
	self:GetTagsOptions(4)
	self:GetTagVarsOptions(5)
	self:GetAuraFiltersOptions(6)
end
