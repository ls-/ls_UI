local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF
local MODULE = P:GetModule("Blizzard")

-- Lua
local _G = getfenv(0)
local m_ceil = _G.math.ceil
local m_floor = _G.math.floor
local m_min = _G.math.min
local t_insert = _G.table.insert
local t_wipe = _G.table.wipe
local m_rad = _G.math.rad

local pages = 1
local page = 1
local compactFrame

local button_proto = {}
do
	function button_proto:OnClick()
		C_AdventureJournal.SetPrimaryOffset(self.id)
		C_AdventureJournal.ActivateEntry(1)
	end

	function button_proto:OnEnter()
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(self.title, 1, 1, 1, 1, true)
		GameTooltip:AddLine(self.description, nil, nil, nil, true)

		if self.buttonText then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(self.buttonText, 0.1, 1, 0.1, true)
		end

		GameTooltip:Show()
	end

	function button_proto:OnLeave()
		GameTooltip:Hide()
	end
end

local pool = CreateUnsecuredObjectPool(
	function()
		local button = Mixin(CreateFrame("Button", nil, compactFrame), button_proto)
		button:SetSize(64, 64)
		button:SetScript("OnClick", button.OnClick)
		button:SetScript("OnEnter", button.OnEnter)
		button:SetScript("OnLeave", button.OnLeave)

		local icon = button:CreateTexture(nil, "ARTWORK")
		icon:SetAllPoints()
		icon:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask")
		button.Icon = icon

		local iconRing = button:CreateTexture(nil, "OVERLAY")
		iconRing:SetPoint("CENTER")
		iconRing:SetTexelSnappingBias(0)
		iconRing:SetSnapToPixelGrid(false)
		iconRing:SetAtlas("adventureguide-ring")
		iconRing:SetSize(94, 95)
		button.IconRing = iconRing

		return button
	end,
	function(_, obj)
		obj.id = nil
		obj.title = nil
		obj.description = nil
		obj.buttonText = nil

		obj.Icon:SetTexture(QUESTION_MARK_ICON)

		obj.IconRing:SetDesaturated(false)
		obj.IconRing:SetVertexColor(1, 1, 1)

		obj:SetMouseClickEnabled(false)
		obj:ClearAllPoints()
		obj:Hide()
	end
)

local suggestions = {}
local data = {}

local function fetchData()
	local numSuggestions = C_AdventureJournal.GetNumAvailableSuggestions()
	if numSuggestions > 0 then
		t_wipe(suggestions)
		t_wipe(data)

		for offset = 0, numSuggestions - 1 do
			C_AdventureJournal.SetPrimaryOffset(offset)
			C_AdventureJournal.GetSuggestions(suggestions)

			t_insert(data, {offset, suggestions[3].title, suggestions[3].description, suggestions[3].iconPath, suggestions[3].buttonText})
		end

		pages = m_ceil(#data / 16)
	end
end

local function refresh()
	pool:ReleaseAll()

	local index = 0
	for i = 1 + (16 * (page - 1)), m_min(#data, 16 * page) do
		local button = pool:Acquire()
		index = index + 1

		local col = (index - 1) % 4
		local row = m_floor((index - 1) / 4)

		button:SetPoint("TOPLEFT", 28 + col * (64 + 8), -28 + -row * (64 + 8))
		button:Show()

		button.id = data[i][1]
		button.title = data[i][2]
		button.description = data[i][3]

		button.Icon:SetTexture(data[i][4])

		local buttonText = data[i][5]
		if buttonText and #buttonText > 0 then
			button.buttonText = buttonText

			button:SetMouseClickEnabled(true)

			button.IconRing:SetDesaturated(true)
			button.IconRing:SetVertexColor(0.45, 0.9, 0.45)
		end
	end

	compactFrame.PrevButton:SetEnabled(page > 1)
	compactFrame.NextButton:SetEnabled(page < pages)
end

local timer = nil
local function delayedUpdate()
	fetchData()
	refresh()

	timer = nil
end

local isInit = false

local function init()
	if not isInit then
		EncounterJournalSuggestFrame:UnregisterEvent("AJ_REFRESH_DISPLAY")
		EncounterJournalSuggestFrame:EnableMouseWheel(false)
		EncounterJournalSuggestFrame.Suggestion1:Hide()

		-- EJSuggestFrame_RefreshDisplay and C_AdventureJournal.UpdateSuggestions are called from inside EJSuggestFrame_OnShow

		compactFrame = CreateFrame("Frame", nil, UIParent)
		compactFrame:SetSize(335, 337)
		compactFrame:SetParent(EncounterJournalSuggestFrame)
		compactFrame:SetPoint("TOPLEFT", 28, -18)
		compactFrame:SetScript("OnMouseWheel", function(_, delta)
			-- -1 is down
			page = page - delta
			if page > pages then
				page = pages
			elseif page < 1 then
				page = 1
			end

			refresh()
		end)

		local bg = compactFrame:CreateTexture(nil, "BACKGROUND")
		bg:SetAllPoints()
		bg:SetAtlas("adventureguide-pane-large")

		local prevButton = CreateFrame("Button", nil, compactFrame)
		prevButton:SetPoint("BOTTOMLEFT", 2, -6)
		prevButton:SetSize(29, 40)
		prevButton:SetNormalTexture("CovenantSanctum-Renown-Arrow")
		prevButton:SetPushedTexture("CovenantSanctum-Renown-Arrow-Depressed")
		prevButton:SetDisabledTexture("CovenantSanctum-Renown-Arrow-Disabled")
		prevButton:SetHighlightTexture("CovenantSanctum-Renown-Arrow-Hover", "ADD")
		prevButton:RotateTextures(m_rad(45))
		prevButton:SetScript("OnClick", function()
			page = page - 1
			if page > pages then
				page = pages
			elseif page < 1 then
				page = 1
			end

			refresh()
		end)
		compactFrame.PrevButton = prevButton

		local nextButton = CreateFrame("Button", nil, compactFrame)
		nextButton:SetPoint("BOTTOMRIGHT", -2, -6)
		nextButton:SetSize(29, 40)
		nextButton:SetNormalTexture("CovenantSanctum-Renown-Arrow")
		nextButton:SetPushedTexture("CovenantSanctum-Renown-Arrow-Depressed")
		nextButton:SetDisabledTexture("CovenantSanctum-Renown-Arrow-Disabled")
		nextButton:SetHighlightTexture("CovenantSanctum-Renown-Arrow-Hover", "ADD")
		nextButton:RotateTextures(m_rad(135))
		nextButton:SetScript("OnClick", function()
			page = page + 1
			if page > pages then
				page = pages
			elseif page < 1 then
				page = 1
			end

			refresh()
		end)
		compactFrame.NextButton = nextButton

		E:RegisterEvent("AJ_REFRESH_DISPLAY", function()
			if not timer then
				timer = C_Timer.NewTimer(0.25, delayedUpdate)
			end
		end)

		fetchData()
		refresh()

		isInit = true
	end
end

function MODULE:HasSuggestFrame()
	return isInit
end

function MODULE:SetUpSuggestFrame()
	if not isInit and PrC.db.profile.blizzard.suggest_frame.enabled then
		if not EncounterJournalSuggestFrame then
			E:AddOnLoadTask("Blizzard_EncounterJournal", init)
		else
			init()
		end
	end
end
