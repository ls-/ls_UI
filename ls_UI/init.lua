local addonName, ns = ...
local E, C, PrC, D, PrD, M, L, P = ns.E, ns.C, ns.PrC, ns.D, ns.PrD, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local next = _G.next

-- Mine
local function addRefs()
	C.db.profile.units.player = C.db.profile.units[E.UI_LAYOUT].player
	C.db.profile.units.pet = C.db.profile.units[E.UI_LAYOUT].pet

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
end

local function removeRefs()
	C.db.profile.units.player = nil
	C.db.profile.units.pet = nil

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

	if C.db.profile.version < E.VER.number then
		print(L["LOGIN_MSG"]:format(L["LS_UI"], E.VER.string, M.textures.icons_inline.DISCORD_32, L["INFORMATION"]))
	end

	-- layout type change shouldn't affect anything after SVs are loaded
	E.UI_LAYOUT = PrC.db.profile.layout

	D.profile.units.player = D.profile.units[E.UI_LAYOUT].player
	D.profile.units.pet = D.profile.units[E.UI_LAYOUT].pet

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

		E.Movers:SaveConfig()
	end)

	C.db:RegisterCallback("OnProfileShutdown", function()
		C.db.profile.version = E.VER.number

		removeRefs()

		E.Movers:SaveConfig()
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
		LoadAddOn("ls_UI_Options")
		if not ls_UI.Config then return end

		ls_UI.Config:Open()
	end

	P:AddCommand("", function()
		if not InCombatLockdown() then
			openConfig()
		end
	end)

	local panel = CreateFrame("Frame", "LSUIConfigPanel", InterfaceOptionsFramePanelContainer)
	panel.name = L["LS_UI"]
	panel:Hide()

	local button = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	button:SetText(L["OPEN_CONFIG"])
	button:SetWidth(button:GetTextWidth() + 18)
	button:SetPoint("TOPLEFT", 16, -16)
	button:SetScript("OnClick", function()
		if not InCombatLockdown() then
			InterfaceOptionsFrame_Show()

			openConfig()
		end
	end)

	InterfaceOptions_AddCategory(panel, true)
end)
