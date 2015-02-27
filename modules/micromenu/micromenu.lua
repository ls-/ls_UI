local _, ns = ...
local E, M = ns.E, ns.M

E.MM = {}

local MM = E.MM

local MICRO_BUTTON_LAYOUT = {
	["CharacterMicroButton"] = {
		point = {"LEFT", "lsMBHolderLeft", "LEFT", 3, 0},
		parent = "lsMBHolderLeft",
		icon = "character",
	},
	["SpellbookMicroButton"] = {
		point = {"LEFT", "CharacterMicroButton", "RIGHT", 6, 0},
		parent = "lsMBHolderLeft",
		icon = "spellbook",
	},
	["TalentMicroButton"] = {
		point = {"LEFT", "SpellbookMicroButton", "RIGHT", 6, 0},
		parent = "lsMBHolderLeft",
		icon = "talents",
	},
	["AchievementMicroButton"] = {
		point = {"LEFT", "TalentMicroButton", "RIGHT", 6, 0},
		parent = "lsMBHolderLeft",
		icon = "achievement",
	},
	["QuestLogMicroButton"] = {
		point = {"LEFT", "AchievementMicroButton", "RIGHT", 6, 0},
		parent = "lsMBHolderLeft",
		icon = "quest",
	},
	["GuildMicroButton"] = {
		point = {"LEFT", "lsMBHolderRight", "LEFT", 3, 0},
		parent = "lsMBHolderRight",
		icon = "guild",
	},
	["LFDMicroButton"] = {
		point = {"LEFT", "GuildMicroButton", "RIGHT", 6, 0},
		parent = "lsMBHolderRight",
		icon = "lfg",
	},
	["CollectionsMicroButton"] = {
		point = {"LEFT", "LFDMicroButton", "RIGHT", 6, 0},
		parent = "lsMBHolderRight",
		icon = "pet",
	},
	["EJMicroButton"] = {
		point = {"LEFT", "CollectionsMicroButton", "RIGHT", 6, 0},
		parent = "lsMBHolderRight",
		icon = "ej",
	},
	["MainMenuMicroButton"] = {
		point = {"LEFT", "EJMicroButton", "RIGHT", 6, 0},
		parent = "lsMBHolderRight",
		icon = "mainmenu",
	},
}

local function MicroButton_OnLeave(self)
	GameTooltip:Hide()
end

local function HandleMicroButton(name)
	local button = _G[name]

	local normal = button:GetNormalTexture()
	local pushed = button:GetPushedTexture()
	local highlight = button:GetHighlightTexture()
	local disabled = button:GetDisabledTexture()
	local flash = button.Flash

	button:SetSize(18, 24)
	button:SetFrameStrata("LOW")
	button:SetFrameLevel(2)
	button:SetHitRectInsets(0, 0, 0, 0)

	if normal then normal:SetTexture(nil) end

	if pushed then
		pushed:SetTexture("Interface\\AddOns\\oUF_LS\\media\\microbutton")
		pushed:SetTexCoord(0.7734375, 0.9140625, 0.3125, 0.6875)
		pushed:SetSize(18, 24)
		pushed:ClearAllPoints()
		pushed:SetPoint("CENTER")
	end

	if highlight then
		highlight:SetTexture("Interface\\AddOns\\oUF_LS\\media\\microbutton")
		highlight:SetTexCoord(0.40625, 0.59375, 0.265625, 0.734375)
		highlight:SetSize(24, 30)
		highlight:ClearAllPoints()
		highlight:SetPoint("CENTER")
	end

	if disabled then disabled:SetTexture(nil) end

	if flash then
		flash:SetSize(58, 58)
		flash:ClearAllPoints()
		flash:SetPoint("CENTER", 14, -10)
	end

	local bg = button:CreateTexture(nil, "BACKGROUND", nil, 0)
	bg:SetTexture(M.textures.statusbar)
	bg:SetVertexColor(0.15, 0.15, 0.15)
	bg:SetAllPoints()

	local icon = button:CreateTexture(nil, "BACKGROUND", nil, 1)
	icon:SetTexture("Interface\\AddOns\\oUF_LS\\media\\microicon\\"..MICRO_BUTTON_LAYOUT[name].icon)
	icon:SetVertexColor(0.52, 0.46, 0.36)
	icon:SetSize(24, 24)
	icon:SetPoint("CENTER")

	local border = button:CreateTexture(nil, "BORDER", nil, 0)
	border:SetTexture("Interface\\AddOns\\oUF_LS\\media\\microbutton")
	border:SetTexCoord(0.0625, 0.28125, 0.234375, 0.765625)
	border:SetSize(28, 34)
	border:SetPoint("CENTER")

	button:SetScript("OnLeave", MicroButton_OnLeave)
	button:SetScript("OnUpdate", nil)
end

local function ResetMicroButtonsParent()
	for _, b in next, MICRO_BUTTONS do
		local button = _G[b]

		if MICRO_BUTTON_LAYOUT[b] then
			button:SetParent(MICRO_BUTTON_LAYOUT[b].parent)
		else
			button:SetParent(M.hiddenParent)
		end
	end
end

local function ResetMicroButtonsPosition()
	for _, b in next, MICRO_BUTTONS do
		local button = _G[b]

		if MICRO_BUTTON_LAYOUT[b] then
			button:ClearAllPoints()
			button:SetPoint(unpack(MICRO_BUTTON_LAYOUT[b].point))
		end
	end
end

function MM:Initialize()
	local MM_CONFIG = ns.C.micromenu

	local holder1 = CreateFrame("Frame", "lsMBHolderLeft", UIParent)
	holder1:SetFrameStrata("LOW")
	holder1:SetFrameLevel(1)
	holder1:SetSize(18 * 5 + 6 * 5, 24 + 6)
	holder1:SetPoint(unpack(MM_CONFIG.holder1.point))

	local holder2 = CreateFrame("Frame", "lsMBHolderRight", UIParent)
	holder2:SetFrameStrata("LOW")
	holder2:SetFrameLevel(1)
	holder2:SetSize(18 * 5 + 6 * 5, 24 + 6)
	holder2:SetPoint(unpack(MM_CONFIG.holder2.point))

	for _, b in next, MICRO_BUTTONS do
		local button = _G[b]
		if MICRO_BUTTON_LAYOUT[b] then
			HandleMicroButton(b)

			button:SetParent(MICRO_BUTTON_LAYOUT[b].parent)
			button:ClearAllPoints()
			button:SetPoint(unpack(MICRO_BUTTON_LAYOUT[b].point))
		else
			button:UnregisterAllEvents()
			button:SetParent(M.hiddenParent)
		end

		if b == "CharacterMicroButton" then
			E:AlwaysHide(MicroButtonPortrait)
		elseif b == "MainMenuMicroButton" then
			E:AlwaysHide(MainMenuBarPerformanceBar)
			E:AlwaysHide(MainMenuBarDownload)

			button:SetScript("OnEnter", MicroButton_OnEnter)
		end
	end

	TalentMicroButtonAlert:SetPoint("BOTTOM", "TalentMicroButton", "TOP", 0, 12)

	CollectionsMicroButtonAlert:SetPoint("BOTTOM", "CollectionsMicroButton", "TOP", 0, 12)

	LFDMicroButtonAlert:SetPoint("BOTTOM", "LFDMicroButton", "TOP", 0, 12)

	hooksecurefunc("UpdateMicroButtonsParent", ResetMicroButtonsParent)
	hooksecurefunc("MoveMicroButtons", ResetMicroButtonsPosition)
end
