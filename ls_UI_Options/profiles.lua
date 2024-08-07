-- Lua
local _G = getfenv(0)
local next = _G.next
local t_concat = _G.table.concat
local t_insert = _G.table.insert
local t_wipe = _G.table.wipe
local unpack = _G.unpack

-- Libs
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local LibDualSpec = LibStub("LibDualSpec-1.0")

-- Mine
local E, M, L, C, D, PrC, PrD, P, oUF, CONFIG = unpack(ls_UI)

local PROFILE_TYPE_FORMAT = "%s |cff888987(id: %s)|r"
local IMPORT_RESULT_FORMAT = "|A:auctionhouse-icon-checkmark:0:0|a %s |cff888987(%s)|r"
local IMPORT_RESULT_FORMAT_NAMELESS = "|A:auctionhouse-icon-checkmark:0:0|a %s"

local TITLES = {
	["export"] = L["EXPORT"],
	["import"] = L["IMPORT"],
}

local PROFILES = {
	["global-colors"] = L["COLORS"],
	["global-tags"] = L["TAGS"],
	["profile"] = L["PROFILE_GLOBAL"],
	["private"] = L["PROFILE_PRIVATE"],
}

local PROFILE_TYPES = {
	["global-colors"] = PROFILE_TYPE_FORMAT:format(L["COLORS"], "global-colors"),
	["global-tags"] = PROFILE_TYPE_FORMAT:format(L["TAGS"], "global-tags"),
	["profile-private"] = PROFILE_TYPE_FORMAT:format(L["PROFILE_GLOBAL"], "profile") .. " + " .. PROFILE_TYPE_FORMAT:format(L["PROFILE_PRIVATE"], "private"),
}

local PROFILE_TYPES_ORDER = {
	"global-colors",
	"global-tags",
	"profile-private",
}

local EXPORT_FORMATS = {
	["string"] = L["DATA_FORMAT_STRING"],
	["table"] = L["DATA_FORMAT_TABLE"],
}

local EXPORT_FORMATS_ORDER = {
	"string",
	"table",
}

local REQUIRE_RELOAD = {
	[true] = {
		["global-colors"] = true,
		["global-tags"] = true,
		["private"] = true,
	},
	[false] = {
		["global-colors"] = true,
		["global-tags"] = true,
		["private"] = false,
	},
}

local curMode = ""

local function openExportImportFrame(info)
	local mode = info[#info]
	if mode == curMode then return end

	local frame = AceGUI:Create("Frame")
	frame:SetTitle(TITLES[mode])
	frame:EnableResize(false)
	frame:SetWidth(800)
	frame:SetHeight(600)
	frame.frame:SetFrameStrata("FULLSCREEN_DIALOG")
	frame:SetLayout("flow")

	local closeButton
	for _, child in next, {frame.frame:GetChildren()} do
		if child:GetObjectType() == "Button" and child.GetText and child:GetText() == CLOSE then
			closeButton = child

			break
		end
	end

	local exportImportBox = AceGUI:Create("MultiLineEditBox")
	exportImportBox:SetNumLines(30)
	exportImportBox:DisableButton(true)
	exportImportBox:SetWidth(800)
	exportImportBox:SetLabel("")
	frame:AddChild(exportImportBox)

	-- Remove OnCursorChanged script as it causes weird behaviour with long text
	exportImportBox.editBox.OnCursorChanged_ = exportImportBox.editBox:GetScript("OnCursorChanged")
	exportImportBox.editBox:SetScript("OnCursorChanged", nil)
	exportImportBox.scrollFrame:UpdateScrollChildRect()

	if mode == "export" then
		local data = ""

		local profileTypeDropdown = AceGUI:Create("Dropdown")
		profileTypeDropdown:SetMultiselect(false)
		profileTypeDropdown:SetLabel(L["EXPORT_TARGET"])
		profileTypeDropdown:SetList(PROFILE_TYPES, PROFILE_TYPES_ORDER)
		profileTypeDropdown:SetValue("profile-private")
		profileTypeDropdown:SetWidth(profileTypeDropdown.pullout.items[3].text:GetStringWidth() + 40)
		frame:AddChild(profileTypeDropdown)

		local exportFormatDropdown = AceGUI:Create("Dropdown")
		exportFormatDropdown:SetMultiselect(false)
		exportFormatDropdown:SetLabel(L["FORMAT"])
		exportFormatDropdown:SetList(EXPORT_FORMATS, EXPORT_FORMATS_ORDER)
		exportFormatDropdown:SetValue("string")
		frame:AddChild(exportFormatDropdown)

		local exportButton = AceGUI:Create("Button")
		exportButton:SetText(L["EXPORT"])
		exportButton:SetFullWidth(true)
		exportButton:SetCallback("OnClick", function()
			local profileType, exportFormat = profileTypeDropdown:GetValue(), exportFormatDropdown:GetValue()
			if profileType == "profile-private" then
				data = E.Profiles:Export("profile", exportFormat)
				data = data .. "\n" .. E.Profiles:Export("private", exportFormat)
			else
				data = E.Profiles:Export(profileType, exportFormat)
			end

			exportImportBox:SetText(data)
			exportImportBox:HighlightText()
			exportImportBox:SetFocus()
		end)
		frame:AddChild(exportButton)

		exportImportBox.editBox.OnTextChanged_ = exportImportBox.editBox:GetScript("OnTextChanged")
		exportImportBox.editBox:SetScript("OnTextChanged", function(self)
			self:SetText(data)
			self:HighlightText()
		end)
		exportImportBox.editBox:SetScript("OnMouseUp", function(self)
			self:HighlightText()
			self:SetFocus()
		end)

		exportImportBox:SetText(data)
		exportImportBox:HighlightText()
	elseif mode == "import" then
		local data = {}
		local shouldValidate = true

		local overwriteButton = AceGUI:Create("CheckBox")
		overwriteButton:SetLabel(L["OVERWRITE_CURRENT_PROFILE"])
		frame:AddChild(overwriteButton)

		local validateImportButton = AceGUI:Create("Button")
		validateImportButton:SetText(L["VALIDATE"])
		validateImportButton:SetDisabled(true)
		validateImportButton:SetRelativeWidth(1)
		validateImportButton:SetCallback("OnClick", function()
			if shouldValidate then
				local result = {}
				for _, v in next, data do
					v = E.Profiles:Recode(v, "table")
					if v then
						local shouldAdd = true
						for _, v_ in next, result do
							shouldAdd = shouldAdd and v_ ~= v
						end

						if shouldAdd then
							t_insert(result, v)
						end
					end
				end

				shouldValidate = false

				-- make sure that OnTextChanged fires
				exportImportBox:SetText("")
				exportImportBox:SetText(t_concat(result, "\n"))
			else
				local result = {}
				local overwrite = overwriteButton:GetValue()
				local shouldReload = false

				for _, v in next, data do
					local profileName, profileType = E.Profiles:Import(v, overwrite)
					if profileType then
						if profileName then
							t_insert(result, IMPORT_RESULT_FORMAT:format(profileName, PROFILES[profileType]))
						else
							t_insert(result, IMPORT_RESULT_FORMAT_NAMELESS:format(PROFILES[profileType]))
						end

						shouldReload = shouldReload or REQUIRE_RELOAD[overwrite][profileType]
					end
				end

				exportImportBox:SetText(t_concat(result, "\n"))

				frame:SetStatusText(L["DONE"])

				if shouldReload then
					closeButton:SetText(L["RELOAD_UI"])
					closeButton:SetScript("OnClick", ReloadUI)
				end
			end
		end)
		frame:AddChild(validateImportButton)

		exportImportBox.editBox:SetText("")
		exportImportBox:SetFocus()

		exportImportBox.editBox.OnTextChanged_ = exportImportBox.editBox:GetScript("OnTextChanged")
		exportImportBox.editBox:SetScript("OnTextChanged", function(self, userInput)
			if userInput then
				shouldValidate = true

				frame:SetStatusText("")
			end

			t_wipe(data)
			for parsed in self:GetText():gmatch("::lsui.-::") do
				local shouldAdd = true
				for _, v in next, data do
					shouldAdd = shouldAdd and parsed ~= v
				end

				if shouldAdd then
					t_insert(data, parsed)
				end
			end

			if shouldValidate then
				validateImportButton:SetText(L["VALIDATE"])
				validateImportButton:SetDisabled(#data == 0)
			else
				validateImportButton:SetText(L["IMPORT"])
				validateImportButton:SetDisabled(#data == 0)
			end
		end)
	end

	frame:SetCallback("OnClose", function(widget)
		exportImportBox.editBox:SetScript("OnCursorChanged", exportImportBox.editBox.OnCursorChanged_)
		exportImportBox.editBox.OnCursorChanged_ = nil

		if exportImportBox.editBox.OnTextChanged_ then
			exportImportBox.editBox:SetScript("OnTextChanged", exportImportBox.editBox.OnTextChanged_)
			exportImportBox.editBox.OnTextChanged_ = nil
		end

		exportImportBox.editBox:SetScript("OnMouseUp", nil)

		curMode = ""

		AceGUI:Release(widget)
		AceConfigDialog:Open("ls_UI")
	end)

	curMode = mode

	AceConfigDialog:Close("ls_UI")
end

function CONFIG:CreateProfilesPanel(order)
	local options = {
		order = order,
		type = "group",
		name = L["PROFILES"],
		childGroups = "tab",
		args = {
			export = {
				order = 1,
				type = "execute",
				name = L["EXPORT"],
				func = openExportImportFrame,
			},
			import = {
				order = 2,
				type = "execute",
				name = L["IMPORT"],
				func = openExportImportFrame,
			},
			spacer_1 = CONFIG:CreateSpacer(3),
		},
	}

	options.args.global = AceDBOptions:GetOptionsTable(C.db, true)
	options.args.global.order = 4
	options.args.global.name = L["PROFILE_GLOBAL"]
	options.args.global.desc = L["PROFILE_GLOBAL_DESC"]

	LibDualSpec:EnhanceOptions(options.args.global, C.db)

	if not options.args.global.plugins then
		options.args.global.plugins = {}
	end

	options.args.global.plugins.ls_UI = {
		warning = {
			order = 0.1,
			type = "description",
			fontSize = "medium",
			name = L["PROFILE_GLOBAL_DESC"],
			image = "Interface\\DialogFrame\\UI-Dialog-Icon-AlertNew",
		},
		spacer = CONFIG:CreateSpacer(0.2),
	}

	options.args.private = AceDBOptions:GetOptionsTable(PrC.db, true)
	options.args.private.order = 5
	options.args.private.name = CONFIG:ColorPrivateSetting(L["PROFILE_PRIVATE"])
	options.args.private.desc = L["PROFILE_PRIVATE_DESC"]

	if not options.args.private.plugins then
		options.args.private.plugins = {}
	end

	options.args.private.plugins.ls_UI = {
		warning = {
			order = 0.1,
			type = "description",
			fontSize = "medium",
			name = L["PROFILE_PRIVATE_DESC"] .. "\n" .. L["PROFILE_RELOAD_WARNING"],
			image = "Interface\\DialogFrame\\UI-Dialog-Icon-AlertNew",
		},
		spacer = CONFIG:CreateSpacer(0.2),
	}

	return options
end
