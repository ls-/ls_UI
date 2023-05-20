-- Lua
local _G = getfenv(0)
local s_trim = _G.string.trim
local t_insert = _G.table.insert
local t_removemulti = _G.table.removemulti
local t_wipe = _G.table.wipe

-- Mine
local PROFILER = ls_UI.Profiler

local ntoi = {} -- name to id
local rawData = {}

local TIME_ID = 1
local MEM_ID = 2
local TICK_ID = 3

local function updateEntry(entry, time, mem)
	-- if it's < 0, then it got hit by gc, ignore it
	mem = mem > 0 and mem or 0

	t_insert(entry.log, {
		timestamp = GetTime(),
		[TIME_ID] = time,
		[MEM_ID ] = mem,
		[TICK_ID] = GetTickTime() * 1000,
	})
end

local NAME_FORMAT = "|cfff8f8f2%s:|r|cff66d9ef%s|r"

function PROFILER:Log(obj, method, time, mem)
	local name = NAME_FORMAT:format(obj, method)
	local id = ntoi[name]
	if not id then
		t_insert(rawData, {
			name = name,
			range = method == "OnUpdate" and 300 or 600, -- 5 vs 10 mins
			log = {},
		})

		id = #rawData
		ntoi[name] = id
	end

	updateEntry(rawData[id], time, mem)
end

local function purgeOldData()
	local timestamp = GetTime()
	local cutoff, to
	local c = 0

	for i = 1, #rawData do
		cutoff = timestamp - rawData[i].range
		to = nil

		for j = 1, #rawData[i].log do
			if rawData[i].log[j].timestamp <= cutoff then
				to = j
			else
				break
			end
		end

		if to then
			-- don't ever use standard table.remove
			t_removemulti(rawData[i].log, 1, to)
			c = c + 1
		end

		if c >= 750 then
			break
		end
	end
end

-- continiously purge older entires
local purgerTicker = C_Timer.NewTicker(5, purgeOldData)

-------------------------
-- FILTERING & SORTING --
-------------------------

local filteredData = {}
local dataProvider

local SORT_NAME = 1
local SORT_TIME_CUR = 2
local SORT_TIME_AVG = 3
local SORT_MEM_CUR = 4
local SORT_MEM_AVG = 5
local SORT_CALLS = 6

local ORDER_ASC = 1
local ORDER_DESC = -1

local SORT_METHODS = {
	[SORT_NAME] = {
		[ORDER_ASC] = function(a, b)
			return rawData[a.id].name < rawData[b.id].name
		end,
		[ORDER_DESC] = function(a, b)
			return rawData[a.id].name > rawData[b.id].name
		end,
	},
	[SORT_TIME_CUR] = {
		[ORDER_ASC] = function(a, b)
			return a.curTime < b.curTime
				or a.curTime == b.curTime
				and rawData[a.id].name < rawData[b.id].name
		end,
		[ORDER_DESC] = function(a, b)
			return a.curTime > b.curTime
				or a.curTime == b.curTime
				and rawData[a.id].name < rawData[b.id].name
		end,
	},
	[SORT_TIME_AVG] = {
		[ORDER_ASC] = function(a, b)
			return a.avgTime < b.avgTime
				or a.avgTime == b.avgTime
				and rawData[a.id].name < rawData[b.id].name
		end,
		[ORDER_DESC] = function(a, b)
			return a.avgTime > b.avgTime
				or a.avgTime == b.avgTime
				and rawData[a.id].name < rawData[b.id].name
		end,
	},
	[SORT_MEM_CUR] = {
		[ORDER_ASC] = function(a, b)
			return a.curMem < b.curMem
				or a.curMem == b.curMem
				and rawData[a.id].name < rawData[b.id].name
		end,
		[ORDER_DESC] = function(a, b)
			return a.curMem > b.curMem
				or a.curMem == b.curMem
				and rawData[a.id].name < rawData[b.id].name
		end,
	},
	[SORT_MEM_AVG] = {
		[ORDER_ASC] = function(a, b)
			return a.avgMem < b.avgMem
				or a.avgMem == b.avgMem
				and rawData[a.id].name < rawData[b.id].name
		end,
		[ORDER_DESC] = function(a, b)
			return a.avgMem > b.avgMem
				or a.avgMem == b.avgMem
				and rawData[a.id].name < rawData[b.id].name
		end,
	},
	[SORT_CALLS] = {
		[ORDER_ASC] = function(a, b)
			return a.entries < b.entries
				or a.entries == b.entries
				and rawData[a.id].name < rawData[b.id].name
		end,
		[ORDER_DESC] = function(a, b)
			return a.entries > b.entries
				or a.entries == b.entries
				and rawData[a.id].name < rawData[b.id].name
		end,
	},
}

local activeSort, activeOrder = SORT_TIME_AVG, ORDER_DESC

local UPDATE_INTERVAL = 1
local continuousUpdate = true

local HISTORY_RANGES = {5, 15, 30, 60, 120, 300, 600}
local curHistoryRange = 30
local oldHistoryRange = 0

local curMatch = ".+"
local oldMatch = ""

local curTimestamp = 0
local oldTimestamp = 0

local oldRawDataSize = 0

local function prepairFilteredData()
	curTimestamp = GetTime()
	if oldRawDataSize ~= #rawData or oldMatch ~= curMatch or oldHistoryRange ~= curHistoryRange or curTimestamp - oldTimestamp >= UPDATE_INTERVAL then

		-- idc about recycling here, just wipe it
		t_wipe(filteredData)
		dataProvider = nil

		local data
		for i = 1, #rawData do
			if rawData[i].name:match(curMatch) then
				data = {id = i, entries = 0}

				for j = 1, #rawData[i].log do
					if rawData[i].log[j].timestamp >= curTimestamp - curHistoryRange then
						data.entries = data.entries + 1

						data.curTime = rawData[i].log[j][TIME_ID]
						data.avgTime = (data.avgTime or 0) + data.curTime
						data.maxTime = (data.maxTime or 0) > data.curTime and (data.maxTime or 0) or data.curTime

						data.curMem = rawData[i].log[j][MEM_ID]
						data.avgMem = (data.avgMem or 0) + data.curMem
						data.maxMem = (data.maxMem or 0) > data.curMem and (data.maxMem or 0) or data.curMem

						data.curTick = rawData[i].log[j][TICK_ID]
						data.avgTick = (data.avgTick or 0) + data.curTick
					end
				end

				if data.entries > 0 then
					data.avgTime = data.avgTime / data.entries
					data.avgMem = data.avgMem / data.entries
					data.avgTick = data.avgTick / data.entries

					t_insert(filteredData, data)
				end
			end
		end

		dataProvider = CreateDataProvider(filteredData)

		oldRawDataSize = #rawData
		oldMatch = curMatch
		oldHistoryRange = curHistoryRange
		oldTimestamp = curTimestamp
	end
end

local function sortFilteredData()
	if dataProvider then
		dataProvider:SetSortComparator(SORT_METHODS[activeSort][activeOrder])
	end
end

-------------
-- DISPLAY --
-------------

local display_proto = {}

function display_proto:OnUpdate(elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed >= UPDATE_INTERVAL then
		prepairFilteredData()
		sortFilteredData()

		local perc = self.ScrollBox:GetScrollPercentage()
		self.ScrollBox:Flush()

		if dataProvider then
			self.ScrollBox:SetDataProvider(dataProvider)
			self.ScrollBox:SetScrollPercentage(perc)
		end

		self.Stats:Update()

		self.elapsed = 0
	end
end

function display_proto:OnShow()
	self.elapsed = UPDATE_INTERVAL

	if continuousUpdate then
		self:SetScript("OnUpdate", self.OnUpdate)
	end
end

function display_proto:OnHide()
	self:SetScript("OnUpdate", nil)
end

local display = Mixin(CreateFrame("Frame", "LSUIProfiler", UIParent, "ButtonFrameTemplate"), display_proto)
display:SetSize(862, 651)
display:SetPoint("CENTER", 0, 0)
display:SetMovable(true)
display:EnableMouse(true)
display:SetScript("OnShow", display.OnShow)
display:SetScript("OnHide", display.OnHide)
display:Hide()

ButtonFrameTemplate_HidePortrait(display)

display:SetTitle("LS: |cff1a9fc0UI|r |cff75715eProfiler|r")

local titleBar = CreateFrame("Frame", nil, display, "PanelDragBarTemplate")
titleBar:SetPoint("TOPLEFT", 0, 0)
titleBar:SetPoint("BOTTOMRIGHT", display, "TOPRIGHT", 0, -32)
titleBar:Init(display)
display.TitleBar = titleBar

display.Inset:SetPoint("TOPLEFT", 8, -86)
display.Inset:SetPoint("BOTTOMRIGHT", -4, 30)

local historyMenu = LibStub("LibDropDown-ls"):NewButtonStretch(display, "parentHistoryDropdown")
historyMenu:SetPoint("TOPRIGHT", -11, -32)
historyMenu:SetSize(120, 20)
historyMenu:SetFrameLevel(3)
historyMenu:SetText("History Range")
display.HistoryDropdown = historyMenu

for i = 1, #HISTORY_RANGES do
	historyMenu:Add({
		isRadio = true,
		func = function(_, _, value)
			curHistoryRange = value

			prepairFilteredData()
			sortFilteredData()

			local perc = display.ScrollBox:GetScrollPercentage()
			display.ScrollBox:Flush()

			if dataProvider then
				display.ScrollBox:SetDataProvider(dataProvider)
				display.ScrollBox:SetScrollPercentage(perc)
			end

			display.Stats:Update()
		end,
		checked = function(self)
			return curHistoryRange == self.args[1]
		end,
		text = SecondsToTime(HISTORY_RANGES[i], false, true),
		args = {HISTORY_RANGES[i]},
	})
end

local search = CreateFrame("EditBox", "$parentSearchBox", display, "SearchBoxTemplate")
search:SetFrameLevel(3)
search:SetPoint("TOPLEFT", 16, -31)
search:SetSize(288, 22)
search:SetAutoFocus(false)
search:SetHistoryLines(1)
search:SetMaxBytes(64)
search:HookScript("OnTextChanged", function(self)
	local text = s_trim(self:GetText())
	curMatch = text == "" and ".+" or text

	prepairFilteredData()
	sortFilteredData()

	local perc = display.ScrollBox:GetScrollPercentage()
	display.ScrollBox:Flush()

	if dataProvider then
		display.ScrollBox:SetDataProvider(dataProvider)
		display.ScrollBox:SetScrollPercentage(perc)
	end

	display.Stats:Update()
end)

local COLUMN_INFO = {
	[SORT_NAME] = {
		title = "Name",
		width = 384,
		order = ORDER_DESC,
	},
	[SORT_TIME_CUR] = {
		title = "Time (Last)",
		width = 96,
		order = ORDER_DESC,
	},
	[SORT_TIME_AVG] = {
		title = "Time (Avg)",
		width = 96,
		order = ORDER_DESC,
	},
	[SORT_MEM_CUR] = {
		title = "Memory (Last)",
		width = 96,
		order = ORDER_DESC,
	},
	[SORT_MEM_AVG] = {
		title = "Memory (Avg)",
		width = 96,
		order = ORDER_DESC,
	},
	[SORT_CALLS] = {
		title = "Calls",
		width = 64,
		order = ORDER_DESC,
	},
}

local headers = CreateFrame("Button", "$parentHeaders", display, "ColumnDisplayTemplate")
headers:SetPoint("BOTTOMLEFT", display.Inset, "TOPLEFT", 1, -1)
headers:SetPoint("BOTTOMRIGHT", display.Inset, "TOPRIGHT", 0, -1)
headers:LayoutColumns(COLUMN_INFO)

for header in headers.columnHeaders:EnumerateActive() do
	local arrow = header:CreateTexture("OVERLAY")
	arrow:SetAtlas("auctionhouse-ui-sortarrow", true)
	arrow:SetPoint("LEFT", header:GetFontString(), "RIGHT", 0, 0)
	arrow:Hide()
	header.Arrow = arrow
end

function headers:UpdateArrow(index)
	for header in headers.columnHeaders:EnumerateActive() do
		if header:GetID() == index then
			header.Arrow:Show()

			if activeOrder == ORDER_ASC then
				header.Arrow:SetTexCoord(0, 1, 1, 0)
			else
				header.Arrow:SetTexCoord(0, 1, 0, 1)
			end
		else
			header.Arrow:Hide()
		end
	end
end

function headers:OnClick(index)
	activeSort = index

	COLUMN_INFO[index].order = COLUMN_INFO[index].order * -1
	activeOrder = COLUMN_INFO[index].order

	sortFilteredData()

	self:UpdateArrow(index)
end

headers:UpdateArrow(activeSort)
headers.Background:Hide()
headers.TopTileStreaks:Hide()

local TIME_FORMAT = "|cfff8f8f2%.3f|r|cfff92672ms|r"
local MEM_FORMAT = "|cfff8f8f2%.1f|r|cfff92672kB|r"
local CALLS_FORMAT = "|cffae81ff%s|r"

local button_proto = {}

function button_proto:OnEnter()
	if self.id and filteredData[self.id] then
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", 26, 2)
		GameTooltip:AddLine(self.Name:GetText())
		GameTooltip:AddDoubleLine("Frametime (Cur):", TIME_FORMAT:format(filteredData[self.id].curTick), 1, 0.92, 0, 1, 1, 1)
		GameTooltip:AddDoubleLine("Frametime (Avg):", TIME_FORMAT:format(filteredData[self.id].avgTick), 1, 0.92, 0, 1, 1, 1)
		GameTooltip:AddDoubleLine("Time (Max):", TIME_FORMAT:format(filteredData[self.id].maxTime), 1, 0.92, 0, 1, 1, 1)
		GameTooltip:AddDoubleLine("Memory (Max):", MEM_FORMAT:format(filteredData[self.id].maxMem), 1, 0.92, 0, 1, 1, 1)
		GameTooltip:Show()
	end
end

function button_proto:OnLeave()
	GameTooltip:Hide()
end

local scrollBox = CreateFrame("Frame", "$parentScrollBox", display, "WowScrollBoxList")
scrollBox:SetPoint("TOPLEFT", display.Inset, "TOPLEFT", 4, -3)
scrollBox:SetPoint("BOTTOMRIGHT", display.Inset, "BOTTOMRIGHT", -22, 2)
display.ScrollBox = scrollBox

local scrollBar = CreateFrame("EventFrame", "$parentScrollBar", display, "MinimalScrollBar")
scrollBar:SetPoint("TOPLEFT", scrollBox, "TOPRIGHT", 4, -4)
scrollBar:SetPoint("BOTTOMLEFT", scrollBox, "BOTTOMRIGHT", 4, 4)

local view = CreateScrollBoxListLinearView()
view:SetElementExtent(20)
view:SetElementInitializer("Button", function(button, data)
	if not button.created then
		Mixin(button, button_proto)
		button:SetSize(1000, 20)
		button:SetHighlightTexture("Interface\\BUTTONS\\WHITE8X8")
		button:GetHighlightTexture():SetVertexColor(0.1, 0.1, 0.1, 0.5)
		button:SetScript("OnEnter", button.OnEnter)
		button:SetScript("OnLeave", button.OnLeave)

		local name = button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		name:SetPoint("LEFT", 2, 0)
		name:SetSize(382, 0)
		name:SetJustifyH("LEFT")
		name:SetWordWrap(false)
		button.Name = name

		local curTime = button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		curTime:SetPoint("LEFT", 384, 0)
		curTime:SetSize(94, 0)
		curTime:SetJustifyH("LEFT")
		button.CurTime = curTime

		local avgTime = button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		avgTime:SetPoint("LEFT", 478, 0)
		avgTime:SetSize(94, 0)
		avgTime:SetJustifyH("LEFT")
		button.AvgTime = avgTime

		local curMem = button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		curMem:SetPoint("LEFT", 572, 0)
		curMem:SetSize(94, 0)
		curMem:SetJustifyH("LEFT")
		button.CurMemory = curMem

		local avgMem = button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		avgMem:SetPoint("LEFT", 666, 0)
		avgMem:SetSize(94, 0)
		avgMem:SetJustifyH("LEFT")
		button.AvgMemory = avgMem

		local calls = button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		calls:SetPoint("LEFT", 760, 0)
		calls:SetSize(64, 0)
		calls:SetJustifyH("LEFT")
		button.Calls = calls

		local bg = button:CreateTexture(nil, "BACKGROUND")
		bg:SetPoint("TOPLEFT")
		bg:SetPoint("BOTTOMRIGHT")
		button.BG = bg

		button.created = true
	end

	button.id = data.id
	button.Name:SetText(rawData[data.id].name)
	button.CurTime:SetFormattedText(TIME_FORMAT, data.curTime)
	button.AvgTime:SetFormattedText(TIME_FORMAT, data.avgTime)
	button.CurMemory:SetFormattedText(MEM_FORMAT, data.curMem)
	button.AvgMemory:SetFormattedText(MEM_FORMAT, data.avgMem)
	button.Calls:SetFormattedText(CALLS_FORMAT, data.entries)
end)

view:SetPadding(2, 0, 2, 2, 2)

ScrollUtil.InitScrollBoxListWithScrollBar(scrollBox, scrollBar, view)

local function alternateBG()
	local index = scrollBox:GetDataIndexBegin()
	scrollBox:ForEachFrame(function(button)
		if index % 2 == 0 then
			button.BG:SetColorTexture(0.1, 0.1, 0.1, 1)
		else
			button.BG:SetColorTexture(0.14, 0.14, 0.14, 1)
		end

		index = index + 1
	end)
end

scrollBox:RegisterCallback("OnDataRangeChanged", alternateBG, display)

local STATS_FORMAT = "|cfff8f8f2%s |cff75715e-|r %d |cff75715e/ %d|r"

local stats = display:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
stats:SetPoint("BOTTOMRIGHT", -8, 4)
stats:SetPoint("TOP", display.Inset, "BOTTOM", 0, -2)
stats:SetSize(0, 20)
stats:SetJustifyH("RIGHT")
stats:SetWordWrap(false)
display.Stats = stats

function stats:Update()
	self:SetFormattedText(STATS_FORMAT, continuousUpdate and "Updating" or "Paused", #filteredData, #rawData)
end

local playButton = CreateFrame("Button", nil, display)
playButton:SetPoint("BOTTOMLEFT", 4, 0)
playButton:SetSize(32, 32)
playButton:SetHitRectInsets(4, 4, 4, 4)
playButton:SetNormalTexture("Interface\\Buttons\\UI-SquareButton-Up")
playButton:SetPushedTexture("Interface\\Buttons\\UI-SquareButton-Down")
playButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
display.PlayButton = playButton

local playIcon = playButton:CreateTexture("OVERLAY")
playIcon:SetSize(11, 15)
playIcon:SetPoint("CENTER")
playIcon:SetBlendMode("ADD")
playIcon:SetTexCoord(10 / 32, 21 / 32, 9 / 32, 24 / 32)
playButton.Icon = playIcon

playButton:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -6, -4)
	GameTooltip:AddLine(continuousUpdate and "Pause" or "Resume")
	GameTooltip:Show()
end)

playButton:SetScript("OnLeave", function()
	GameTooltip:Hide()
end)

playButton:SetScript("OnMouseDown", function(self)
	self.Icon:SetPoint("CENTER", -2, -2)
end)

playButton:SetScript("OnMouseUp", function(self)
	self.Icon:SetPoint("CENTER", 0, 0)
end)

playButton:SetScript("OnClick", function(self)
	continuousUpdate = not continuousUpdate
	if continuousUpdate then
		self.Icon:SetTexture("Interface\\TimeManager\\PauseButton")
		self.Icon:SetVertexColor(0.84, 0.81, 0.52)

		display:SetScript("OnUpdate", display.OnUpdate)
		display.UpdateButton:Disable()
	else
		self.Icon:SetTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
		self.Icon:SetVertexColor(1, 1, 1)

		display:SetScript("OnUpdate", nil)
		display.UpdateButton:Enable()
	end

	if GameTooltip:IsOwned(self) then
		self:GetScript("OnEnter")(self)
	end

	display.Stats:Update()
end)

playButton:SetScript("OnShow", function(self)
	if continuousUpdate then
		self.Icon:SetTexture("Interface\\TimeManager\\PauseButton")
		self.Icon:SetVertexColor(0.84, 0.81, 0.52)
	else
		self.Icon:SetTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
		self.Icon:SetVertexColor(1, 1, 1)
	end

	self.Icon:SetPoint("CENTER")
end)

local updateButton = CreateFrame("Button", nil, display)
updateButton:SetPoint("LEFT", playButton, "RIGHT", -6, 0)
updateButton:SetSize(32, 32)
updateButton:SetHitRectInsets(4, 4, 4, 4)
updateButton:SetNormalTexture("Interface\\Buttons\\UI-SquareButton-Up")
updateButton:SetPushedTexture("Interface\\Buttons\\UI-SquareButton-Down")
updateButton:SetDisabledTexture("Interface\\Buttons\\UI-SquareButton-Disabled")
updateButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
display.UpdateButton = updateButton

local updateIcon = updateButton:CreateTexture("OVERLAY")
updateIcon:SetSize(16, 16)
updateIcon:SetPoint("CENTER", -1, -1)
updateIcon:SetBlendMode("ADD")
updateIcon:SetTexture("Interface\\Buttons\\UI-RefreshButton")
updateButton.Icon = updateIcon

updateButton:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -6, -4)
	GameTooltip:AddLine("Update")
	GameTooltip:Show()
end)

updateButton:SetScript("OnLeave", function()
	GameTooltip:Hide()
end)

updateButton:SetScript("OnMouseDown", function(self)
	if self:IsEnabled() then
		self.Icon:SetPoint("CENTER", -3, -3)
	end
end)

updateButton:SetScript("OnMouseUp", function(self)
	if self:IsEnabled() then
		self.Icon:SetPoint("CENTER", -1, -1)
	end
end)

updateButton:SetScript("OnClick", function()
	prepairFilteredData()
	sortFilteredData()

	local perc = display.ScrollBox:GetScrollPercentage()
	display.ScrollBox:Flush()

	if dataProvider then
		display.ScrollBox:SetDataProvider(dataProvider)
		display.ScrollBox:SetScrollPercentage(perc)
	end

	display.Stats:Update()
end)

updateButton:SetScript("OnDisable", function(self)
	self.Icon:SetDesaturated(true)
	self.Icon:SetVertexColor(0.6, 0.6, 0.6)
end)

updateButton:SetScript("OnEnable", function(self)
	self.Icon:SetDesaturated(false)
	self.Icon:SetVertexColor(1, 1, 1)
end)

updateButton:SetScript("OnShow", function(self)
	if continuousUpdate then
		self:Disable()
	else
		self:Enable()
	end

	self.Icon:SetPoint("CENTER", -1, -1)
end)

local toggleButton = CreateFrame("Button", "$parentToggle", display, "UIPanelButtonTemplate, UIButtonTemplate")
toggleButton:SetPoint("BOTTOM", 0, 6)
toggleButton:SetText("Disable")
DynamicResizeButton_Resize(toggleButton)

toggleButton:SetOnClickHandler(function(self)
	if PROFILER:IsLogging() then
		self:SetText("Enable")
		DynamicResizeButton_Resize(self)

		PROFILER:DisableLogging()
	else
		self:SetText("Disable")
		DynamicResizeButton_Resize(self)

		PROFILER:EnableLogging()
	end
end)

---------
-- API --
---------

function PROFILER:IsLoaded()
	return true
end

local isLogging = true

function PROFILER:IsLogging()
	return isLogging
end

function PROFILER:EnableLogging()
	isLogging = true

	if purgerTicker then
		purgerTicker:Cancel()
	end

	purgerTicker = C_Timer.NewTicker(5, purgeOldData)
end

function PROFILER:DisableLogging()
	isLogging = false

	if purgerTicker then
		purgerTicker:Cancel()
	end

	t_wipe(ntoi)
	t_wipe(rawData)
	t_wipe(filteredData)
	dataProvider = nil

	display.ScrollBox:Flush()
end

function PROFILER:Open()
	display:SetShown(not display:IsShown())
end
