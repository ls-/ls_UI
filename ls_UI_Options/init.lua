-- Lua
local _G = getfenv(0)
local unpack = _G.unpack

-- Libs
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local LibKeyBound = LibStub("LibKeyBound-1.0")

-- Mine
local E, M, L, C, D, PrC, PrD, P, oUF, CONFIG, PROFILER = unpack(ls_UI)

local isInit = false

function CONFIG:Open()
	if not isInit then
		self.options = {
			type = "group",
			name = L["LS_UI"],
			disabled = function()
				return InCombatLockdown()
			end,
			args = {
				toggle_anchors = {
					order = 2,
					type = "execute",
					name = L["TOGGLE_ANCHORS"],
					width = 1.25,
					func = function()
						E.Movers:ToggleAll(true)

						AceConfigDialog:Close("ls_UI")
					end,
				},
				keybind_mode = {
					order = 3,
					type = "execute",
					name = LibKeyBound.L.BindingMode,
					width = 1.25,
					func = function()
						LibKeyBound:Toggle()
					end,
				},
				profiler = {
					order = 4,
					type = "execute",
					name = L["PERFORMANCE"],
					width = 1.25,
					func = function()
						if not PROFILER:IsLoaded() then
							LoadAddOn("ls_UI_Profiler")

							if not PROFILER:IsLoaded() then return end
						end

						PROFILER:Open()

						AceConfigDialog:Close("ls_UI")
					end,
				},
				reload_ui = {
					order = 5,
					type = "execute",
					name = L["RELOAD_UI"],
					width = 1.25,
					func = function()
						ReloadUI()
					end,
				},
				profiles = CONFIG:CreateProfilesPanel(100),
				about = CONFIG:CreateAboutPanel(101),
			},
		}

		CONFIG:GetGeneralOptions(5)
		CONFIG:CreateActionBarsOptions(6)
		CONFIG:CreateAuraTrackerOptions(7)
		CONFIG:CreateBlizzardOptions(8)
		CONFIG:CreateAurasOptions(9)
		CONFIG:CreateMinimapOptions(11)
		-- TODO: remove me in 10.0.2
		if TooltipDataProcessor then
			CONFIG:GetTooltipsOptions(12)
		end
		CONFIG:CreateUnitFramesOptions(13)

		AceConfig:RegisterOptionsTable("ls_UI", self.options)
		AceConfigDialog:SetDefaultSize("ls_UI", 1228, 768)

		P:AddCommand("kb", function()
			if not InCombatLockdown() then
				LibKeyBound:Toggle()
			end
		end)

		E:RegisterEvent("PLAYER_REGEN_DISABLED", function()
			AceConfigDialog:Close("ls_UI")
		end)

		CONFIG:RunCallbacks()

		isInit = true
	end

	AceConfigDialog:Open("ls_UI")
end

function CONFIG:IsLoaded()
	return true
end
