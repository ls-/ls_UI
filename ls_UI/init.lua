local addonName, ns = ...
local E, C, PrC, D, PrD, M, L, P = ns.E, ns.C, ns.PrC, ns.D, ns.PrD, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local next = _G.next

-- Mine
local function addRefs()
	C.db.global.colors.power[ 0] = C.db.global.colors.power.MANA
	C.db.global.colors.power[ 1] = C.db.global.colors.power.RAGE
	C.db.global.colors.power[ 2] = C.db.global.colors.power.FOCUS
	C.db.global.colors.power[ 3] = C.db.global.colors.power.ENERGY
	C.db.global.colors.power[ 4] = C.db.global.colors.power.CHI
	C.db.global.colors.power[ 5] = C.db.global.colors.power.RUNES
	C.db.global.colors.power[ 6] = C.db.global.colors.power.RUNIC_POWER
	C.db.global.colors.power[ 7] = C.db.global.colors.power.SOUL_SHARDS
	C.db.global.colors.power[ 8] = C.db.global.colors.power.LUNAR_POWER
	C.db.global.colors.power[ 9] = C.db.global.colors.power.HOLY_POWER
	C.db.global.colors.power[10] = C.db.global.colors.power.ALTERNATE
	C.db.global.colors.power[11] = C.db.global.colors.power.MAELSTROM
	C.db.global.colors.power[13] = C.db.global.colors.power.INSANITY
	C.db.global.colors.power[17] = C.db.global.colors.power.FURY
	C.db.global.colors.power[18] = C.db.global.colors.power.PAIN
	C.db.global.colors.power[19] = C.db.global.colors.power.ESSENCE
end

local function removeRefs()
	C.db.global.colors.power[ 0] = nil
	C.db.global.colors.power[ 1] = nil
	C.db.global.colors.power[ 2] = nil
	C.db.global.colors.power[ 3] = nil
	C.db.global.colors.power[ 4] = nil
	C.db.global.colors.power[ 5] = nil
	C.db.global.colors.power[ 6] = nil
	C.db.global.colors.power[ 7] = nil
	C.db.global.colors.power[ 8] = nil
	C.db.global.colors.power[ 9] = nil
	C.db.global.colors.power[10] = nil
	C.db.global.colors.power[11] = nil
	C.db.global.colors.power[13] = nil
	C.db.global.colors.power[17] = nil
	C.db.global.colors.power[18] = nil
	C.db.global.colors.power[19] = nil

	E.Movers:SaveConfig()
end

local function updateAll()
	addRefs()

	P:UpdateModules()
	E.Movers:ApplyConfig()
	E.Movers:UpdateAll()
end

E:RegisterEvent("ADDON_LOADED", function(arg1)
	if arg1 ~= addonName then return end

	LS_UI_CHAR_CONFIG = nil

	if LS_UI_GLOBAL_CONFIG then
		--> 90105.04
		if LS_UI_GLOBAL_CONFIG.char then
			if not LS_UI_PRIVATE_CONFIG then
				LS_UI_PRIVATE_CONFIG = {
					profileKeys = {},
					profiles = {},
				}
			end

			E:CopyTable(LS_UI_GLOBAL_CONFIG.char, LS_UI_PRIVATE_CONFIG.profiles)

			LS_UI_GLOBAL_CONFIG.char = nil
		end

		if LS_UI_GLOBAL_CONFIG.global then
			P:Modernize(LS_UI_GLOBAL_CONFIG.global, "Account Data", "global")
		end

		if LS_UI_GLOBAL_CONFIG.profiles then
			for profile, data in next, LS_UI_GLOBAL_CONFIG.profiles do
				P:Modernize(data, profile, "profile")
			end
		end
	end

	if LS_UI_PRIVATE_CONFIG then
		if LS_UI_PRIVATE_CONFIG.profiles then
			for profile, data in next, LS_UI_PRIVATE_CONFIG.profiles do
				P:Modernize(data, profile, "private")
			end
		end
	end

	C.db = LibStub("AceDB-3.0"):New("LS_UI_GLOBAL_CONFIG", D)
	LibStub("LibDualSpec-1.0"):EnhanceDatabase(C.db, "LS_UI_GLOBAL_CONFIG")

	PrC.db = LibStub("AceDB-3.0"):New("LS_UI_PRIVATE_CONFIG", PrD)

	addRefs()

	if AdiButtonAuras and AdiButtonAuras.RegisterLAB then
		AdiButtonAuras:RegisterLAB("LibActionButton-1.0-ls")
	end

	if MaxDps then
		if MaxDps.RegisterLibActionButton then
			MaxDps:RegisterLibActionButton("LibActionButton-1.0-ls")
		else
			local LAB = LibStub("LibActionButton-1.0-ls")

			if MaxDps.FetchLibActionButton then
				hooksecurefunc(MaxDps, "FetchLibActionButton", function(self)
					for button in next, LAB:GetAllButtons() do
						self:AddButton(button:GetSpellId(), button)
					end
				end)
			end

			if MaxDps.UpdateButtonGlow then
				hooksecurefunc(MaxDps, "UpdateButtonGlow", function(self)
					if self.db.global.disableButtonGlow then
						LAB.eventFrame:UnregisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW")
					else
						LAB.eventFrame:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW")
					end
				end)
			end
		end
	end

	if MinimapButtonFrame then
		C.db.profile.minimap.collect.enabled = false
	end

	PrC.db.profile.version = E.VER.number

	C.db:RegisterCallback("OnDatabaseShutdown", function()
		C.db.global.version = E.VER.number
		C.db.profile.version = E.VER.number

		removeRefs()
	end)

	C.db:RegisterCallback("OnProfileShutdown", function()
		C.db.profile.version = E.VER.number

		removeRefs()
	end)

	C.db:RegisterCallback("OnProfileChanged", updateAll)
	C.db:RegisterCallback("OnProfileCopied", updateAll)
	C.db:RegisterCallback("OnProfileReset", updateAll)

	PrC.db:RegisterCallback("OnDatabaseShutdown", function()
		PrC.db.profile.version = E.VER.number
	end)

	PrC.db:RegisterCallback("OnProfileShutdown", function()
		PrC.db.profile.version = E.VER.number
	end)

	E:RegisterEvent("PLAYER_LOGIN", function()
		E:UpdateConstants()

		P:InitModules()
	end)

	local function openConfig()
		if not ls_UI.Config:IsLoaded() then
			LoadAddOn("ls_UI_Options")

			if not ls_UI.Config:IsLoaded() then return end
		end

		ls_UI.Config:Open()
	end

	P:AddCommand("", function()
		if not InCombatLockdown() then
			openConfig()
		end
	end)

	local function openProfiler()
		if not ls_UI.Profiler:IsLoaded() then
			LoadAddOn("ls_UI_Profiler")

			if not ls_UI.Profiler:IsLoaded() then return end
		end

		ls_UI.Profiler:Open()
	end

	P:AddCommand("profiler", function()
		if not InCombatLockdown() then
			openProfiler()
		end
	end)

	local panel = CreateFrame("Frame", "LSUIConfigPanel")
	panel:Hide()

	local button1 = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	button1:SetText(L["OPEN_CONFIG"])
	button1:SetWidth(button1:GetTextWidth() + 18)
	button1:SetPoint("TOPLEFT", 16, -16)
	button1:SetScript("OnClick", function()
		if not InCombatLockdown() then
			HideUIPanel(SettingsPanel)

			openConfig()
		end
	end)

	local button2 = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	button2:SetText(L["PERFORMANCE"])
	button2:SetWidth(button2:GetTextWidth() + 18)
	button2:SetPoint("TOPLEFT", button1, "BOTTOMLEFT", 0, -8)
	button2:SetScript("OnClick", function()
		if not InCombatLockdown() then
			HideUIPanel(SettingsPanel)

			openProfiler()
		end
	end)

	Settings.RegisterAddOnCategory(Settings.RegisterCanvasLayoutCategory(panel, L["LS_UI"]))
end)
