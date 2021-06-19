local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)
local assert = _G.assert
local hooksecurefunc = _G.hooksecurefunc
local m_floor = _G.math.floor
local next = _G.next
local s_format = _G.string.format
local s_upper = _G.string.upper
local t_insert = _G.table.insert
local t_remove = _G.table.remove
local t_wipe = _G.table.wipe
local type = _G.type
local unpack = _G.unpack

-- Blizz
local IsAltKeyDown = _G.IsAltKeyDown

--[[ luacheck: globals
	CreateFrame GameTooltip InCombatLockdown IsShiftKeyDown SquareButton_SetIcon
	UIParent
]]

-- Mine
-- Grid
local grid = CreateFrame("Frame", nil, UIParent)
grid:SetFrameStrata("BACKGROUND")
grid:Hide()

local linePool = {}
local activeLines = {}
local gridSize = 32

local function getGridLine()
	if not next(linePool) then
		t_insert(linePool, grid:CreateTexture())
	end

	local line = t_remove(linePool, 1)
	line:ClearAllPoints()
	line:Show()

	t_insert(activeLines, line)

	return line
end

local function releaseGridLines()
	while next(activeLines) do
		local line = t_remove(activeLines, 1)
		line:ClearAllPoints()
		line:Hide()

		t_insert(linePool, line)
	end
end

local function hideGrid()
	grid:Hide()
end

local function showGrid()
	releaseGridLines()

	local screenWidth, screenHeight = UIParent:GetRight(), UIParent:GetTop()
	local screenCenterX, screenCenterY = UIParent:GetCenter()

	grid:SetSize(screenWidth, screenHeight)
	grid:SetPoint("CENTER")
	grid:Show()

	local yAxis = getGridLine()
	yAxis:SetDrawLayer("BACKGROUND", 1)
	yAxis:SetColorTexture(0.9, 0.1, 0.1, 0.6)
	yAxis:SetPoint("TOPLEFT", grid, "TOPLEFT", screenCenterX - 1, 0)
	yAxis:SetPoint("BOTTOMRIGHT", grid, "BOTTOMLEFT", screenCenterX + 1, 0)

	local xAxis = getGridLine()
	xAxis:SetDrawLayer("BACKGROUND", 1)
	xAxis:SetColorTexture(0.9, 0.1, 0.1, 0.6)
	xAxis:SetPoint("TOPLEFT", grid, "BOTTOMLEFT", 0, screenCenterY + 1)
	xAxis:SetPoint("BOTTOMRIGHT", grid, "BOTTOMRIGHT", 0, screenCenterY - 1)

	local l = getGridLine()
	l:SetDrawLayer("BACKGROUND", 2)
	l:SetColorTexture(0.8, 0.8, 0.1, 0.6)
	l:SetPoint("TOPLEFT", grid, "TOPLEFT", screenWidth / 3 - 1, 0)
	l:SetPoint("BOTTOMRIGHT", grid, "BOTTOMLEFT", screenWidth / 3 + 1, 0)

	local r = getGridLine()
	r:SetDrawLayer("BACKGROUND", 2)
	r:SetColorTexture(0.8, 0.8, 0.1, 0.6)
	r:SetPoint("TOPRIGHT", grid, "TOPRIGHT", - screenWidth / 3 + 1, 0)
	r:SetPoint("BOTTOMLEFT", grid, "BOTTOMRIGHT", - screenWidth / 3 - 1, 0)

	-- horiz lines
	local tex
	for i = 1, m_floor(screenHeight / 2 / gridSize) do
		tex = getGridLine()
		tex:SetDrawLayer("BACKGROUND", 0)
		tex:SetColorTexture(0, 0, 0, 0.6)
		tex:SetPoint("TOPLEFT", grid, "BOTTOMLEFT", 0, screenCenterY + 1 + gridSize * i)
		tex:SetPoint("BOTTOMRIGHT", grid, "BOTTOMRIGHT", 0, screenCenterY - 1 + gridSize * i)

		tex = getGridLine()
		tex:SetDrawLayer("BACKGROUND", 0)
		tex:SetColorTexture(0, 0, 0, 0.6)
		tex:SetPoint("BOTTOMLEFT", grid, "BOTTOMLEFT", 0, screenCenterY - 1 - gridSize * i)
		tex:SetPoint("TOPRIGHT", grid, "BOTTOMRIGHT", 0, screenCenterY + 1 - gridSize * i)
	end

	-- vert lines
	for i = 1, m_floor(screenWidth / 2 / gridSize) do
		tex = getGridLine()
		tex:SetDrawLayer("BACKGROUND", 0)
		tex:SetColorTexture(0, 0, 0, 0.6)
		tex:SetPoint("TOPLEFT", grid, "TOPLEFT", screenCenterX - 1 - gridSize * i, 0)
		tex:SetPoint("BOTTOMRIGHT", grid, "BOTTOMLEFT", screenCenterX + 1 - gridSize * i, 0)

		tex = getGridLine()
		tex:SetDrawLayer("BACKGROUND", 0)
		tex:SetColorTexture(0, 0, 0, 0.6)
		tex:SetPoint("TOPRIGHT", grid, "TOPLEFT", screenCenterX + 1 + gridSize * i, 0)
		tex:SetPoint("BOTTOMLEFT", grid, "BOTTOMLEFT", screenCenterX - 1 + gridSize * i, 0)
	end
end

-- Movers
local defaults = {}
local disabledMovers = {}
local enabledMovers = {}
local trackedMovers = {}
local highlightIndex = 0
local isDragging = false
local areToggledOn = false

local function tracker_OnUpdate(self, elapsed)
	if not isDragging then
		local isAltKeyDown = IsAltKeyDown()

		if self.isAltKeyDown ~= isAltKeyDown then
			if isAltKeyDown and #trackedMovers > 0 then
				highlightIndex = highlightIndex + 1
			end

			self.isAltKeyDown = isAltKeyDown
		end

		self.elapsed = (self.elapsed or 0) + elapsed

		if self.elapsed > 0.1 then
			t_wipe(trackedMovers)

			for _, mover in next, enabledMovers do
				if not mover.isSimple then
					if mover:IsMouseOver(4, -4, -4, 4) then
						t_insert(trackedMovers, mover)
					end

					mover:EnableMouse(true)
				end
			end

			if #trackedMovers > 0 then
				if highlightIndex > #trackedMovers or #trackedMovers == 1 then
					highlightIndex = 1
				end

				for i = 1, #trackedMovers do
					if i == highlightIndex then
						local mover = trackedMovers[highlightIndex]

						if self.mover ~= mover then
							mover:Raise()
							mover:GetScript("OnEnter")(mover)

							self.mover = mover
						end
					else
						trackedMovers[i]:EnableMouse(false)
					end
				end
			end

			self.elapsed = 0
		end
	else
		self.elapsed = 0
	end
end

local tracker = CreateFrame("Frame", "LSMoverTracker", UIParent)

local function calculatePosition(self)
	local moverCenterX, moverCenterY = self:GetCenter()
	local p, x, y

	if moverCenterX and moverCenterY then
		local screenWidth = UIParent:GetRight()
		local screenHeight = UIParent:GetTop()
		local screenCenterX, screenCenterY = UIParent:GetCenter()
		local screenLeft = screenWidth / 3
		local screenRight = screenWidth * 2 / 3

		if moverCenterY >= screenCenterY then
			p = "TOP"
			y = self:GetTop() - screenHeight
		else
			p = "BOTTOM"
			y = self:GetBottom()
		end

		if moverCenterX >= screenRight then
			p = p .. "RIGHT"
			x = self:GetRight() - screenWidth
		elseif moverCenterX <= screenLeft then
			p = p .. "LEFT"
			x = self:GetLeft()
		else
			x = moverCenterX - screenCenterX
		end
	end

	return p, p, E:Round(x), E:Round(y)
end

local function updatePosition(self, p, anchor, rP, x, y, xOffset, yOffset)
	if not x then
		if C.db.profile.movers[E.UI_LAYOUT][self:GetName()].point then
			p, anchor, rP, x, y = unpack(C.db.profile.movers[E.UI_LAYOUT][self:GetName()].point)
			anchor = anchor or "UIParent"
		end

		if not x then
			self:ResetPosition()
			return
		end
	end

	x = x + (xOffset or 0)
	y = y + (yOffset or 0)

	self:ClearAllPoints()
	self:SetPoint(p, anchor, rP, x, y)

	return p, anchor, rP, x, y
end

local function resetObjectPoint(self, _, _, _, _, _, shouldIgnore)
	if not shouldIgnore and E.Movers:Get(self) then
		self:ClearAllPoints()
		self:SetPoint("TOPRIGHT", E.Movers:Get(self), "TOPRIGHT", 0, 0, true)
	end
end

local function mover_SavePosition(self, p, anchor, rP, x, y)
	C.db.profile.movers[E.UI_LAYOUT][self:GetName()].point = {p, anchor, rP, x, y}
end

local function mover_ResetPosition(self)
	if not self.isSimple and InCombatLockdown() then return end

	local p, anchor, rP, x, y = unpack(defaults[self:GetName()].point)

	self:ClearAllPoints()
	self:SetPoint(p, anchor, rP, x, y)

	C.db.profile.movers[E.UI_LAYOUT][self:GetName()].point = nil

	if not self.isSimple then
		self.Bg:SetColorTexture(E:GetRGBA(C.db.global.colors.blue, 0.6))
	end

	self:PostSaveUpdatePosition()
end

local function mover_UpdatePosition(self, xOffset, yOffset)
	if not self.isSimple and InCombatLockdown() then return end

	local p, rP, x, y = calculatePosition(self)
	local anchor = "UIParent"

	p, anchor, rP, x, y = updatePosition(self, p, anchor, rP, x, y, xOffset, yOffset)

	self:SavePosition(p, anchor, rP, x, y)

	if self.isSimple then
		self:Show()
	else
		if self:WasMoved() then
			self.Bg:SetColorTexture(E:GetRGBA(C.db.global.colors.orange, 0.6))
		else
			self.Bg:SetColorTexture(E:GetRGBA(C.db.global.colors.blue, 0.6))
		end
	end

	self:PostSaveUpdatePosition()
end

local mover_OnUpdate

local function mover_OnEnter(self)
	if not self:GetScript("OnUpdate") then
		self:SetScript("OnUpdate", mover_OnUpdate)
	end

	local p, anchor, rP, x, y = E:GetCoords(self)

	if isDragging or self:WasMoved() then
		p, rP, x, y = calculatePosition(self)
	end

	GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
	GameTooltip:AddLine(self:GetName())
	GameTooltip:AddLine("|cffffd100Point:|r " .. p, 1, 1, 1)
	GameTooltip:AddLine("|cffffd100Attached to:|r " .. rP .. " |cffffd100of|r " .. anchor, 1, 1, 1)
	GameTooltip:AddLine("|cffffd100X:|r " .. x .. ", |cffffd100Y:|r " .. y, 1, 1, 1)
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(L["MOVER_BUTTONS_DESC"])
	GameTooltip:AddLine(L["MOVER_RESET_DESC"])
	GameTooltip:AddLine(L["MOVER_CYCLE_DESC"])
	GameTooltip:Show()
end

local function mover_OnLeave(self)
	self:SetScript("OnUpdate", nil)

	GameTooltip:Hide()
end

function mover_OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed

	if self.elapsed > 0.1 then
		if GameTooltip:IsOwned(self) then
			if self:IsMouseOver() then
				mover_OnEnter(self)
			else
				mover_OnLeave(self)
			end
		end

		self.elapsed = 0
	end
end

local function mover_OnDragStart(self)
	if not self.isSimple and InCombatLockdown() then return end

	if self:IsDragKeyDown() then
		self:StartMoving()

		isDragging = true
	end
end

local function mover_OnDragStop(self)
	if not self.isSimple and InCombatLockdown() then return end

	self:StopMovingOrSizing()
	self:UpdatePosition()

	isDragging = false
end

local function mover_OnClick(self)
	if IsShiftKeyDown() then
		self:ResetPosition()

		if GameTooltip:IsOwned(self) then
			mover_OnEnter(self)
		end
	else
		local isShown = self.buttons[1]:IsShown()

		for i = 1, #self.buttons do
			self.buttons[i]:SetShown(not isShown)
		end
	end
end

local function mover_IsEnabled(self)
	return not not enabledMovers[self:GetName()]
end

local function mover_IsDragKeyDown()
	return true
end

local function mover_WasMoved(self)
	local dest = C.db.profile.movers[E.UI_LAYOUT][self:GetName()]
	if not (dest and next(dest)) then
		return false
	end

	return not E:IsEqualTable(defaults[self:GetName()], dest)
end

local function mover_Enable(self)
	local name = self:GetName()

	if enabledMovers[name] or not disabledMovers[name] then return end

	enabledMovers[name] = disabledMovers[name]
	disabledMovers[name] = nil

	enabledMovers[name]:UpdatePosition()
	resetObjectPoint(self.object)

	if areToggledOn then
		enabledMovers[name]:Show()
	end
end

local function mover_Disable(self)
	local name = self:GetName()

	if disabledMovers[name] or not enabledMovers[name] then return end

	enabledMovers[name]:Hide()

	disabledMovers[name] = enabledMovers[name]
	enabledMovers[name] = nil
end

local function mover_UpdateSize(self, width, height)
	self:SetWidth(width or self.object:GetWidth())
	self:SetHeight(height or self.object:GetHeight())
end

local MOVER_BUTTONS = {
	Up = {
		anchor = "TOP",
		point1 = {"TOPLEFT", "TOPLEFT", 0, 8},
		point2 = {"BOTTOMRIGHT", "TOPRIGHT", 0, 0},
		offset_x = 0,
		offset_y = 1,
	},
	Down = {
		point1 = {"BOTTOMLEFT", "BOTTOMLEFT", 0, -8},
		point2 = {"TOPRIGHT", "BOTTOMRIGHT", 0, 0},
		anchor = "BOTTOM",
		offset_x = 0,
		offset_y = -1,
	},
	Left = {
		point1 = {"TOPLEFT", "TOPLEFT", -8, 0},
		point2 = {"BOTTOMRIGHT", "BOTTOMLEFT", 0, 0},
		anchor = "LEFT",
		offset_x = -1,
		offset_y = 0,
	},
	Right = {
		point1 = {"TOPRIGHT", "TOPRIGHT", 8, 0},
		point2 = {"BOTTOMLEFT", "BOTTOMRIGHT", 0, 0},
		anchor = "RIGHT",
		offset_x = 1,
		offset_y = 0,
	},
}

local function button_OnClick(self)
	local mover = self:GetParent()

	mover:UpdatePosition(self.offset_x, self.offset_y)

	if GameTooltip:IsOwned(mover) then
		mover_OnEnter(mover)
	end
end

local function button_OnEnter(self)
	mover_OnEnter(self:GetParent())
end

local function button_OnLeave()
	GameTooltip:Hide()
end

local function createMoverButton(mover, dir)
	local data = MOVER_BUTTONS[dir]

	local button = CreateFrame("Button", "$parentButton"..dir, mover, "UIPanelSquareButton")
	button:GetHighlightTexture():SetColorTexture(0.9, 0.9, 0.9, 0.3)
	button:GetNormalTexture():SetColorTexture(0.6, 0.6, 0.6, 0.8)
	button:GetPushedTexture():SetColorTexture(0.1, 0.1, 0.1, 0.6)
	button:SetFlattensRenderLayers(true)
	button:SetPoint(data.point1[1], mover, data.point1[2], data.point1[3], data.point1[4])
	button:SetPoint(data.point2[1], mover, data.point2[2], data.point2[3], data.point2[4])
	button:SetScript("OnClick", button_OnClick)
	button:SetScript("OnEnter", button_OnEnter)
	button:SetScript("OnLeave", button_OnLeave)
	button:SetSize(10, 10)
	button:Hide()

	button.offset_x = data.offset_x
	button.offset_y = data.offset_y

	SquareButton_SetIcon(button, s_upper(dir))

	return button
end

E.Movers = {}

function E.Movers:Create(object, isSimple)
	if not object then return end

	local objectName = object:GetName()

	assert(objectName, (s_format("Failed to create a mover, object '%s' has no name", object:GetDebugName())))

	local name = objectName .. "Mover"

	local mover = CreateFrame("Button", name, UIParent)
	mover:SetFrameLevel(object:GetFrameLevel() + 4)
	mover:SetWidth(object:GetWidth())
	mover:SetHeight(object:GetHeight())
	mover:SetClampedToScreen(true)
	mover:SetClampRectInsets(-4, 4, 4, -4)
	mover:SetMovable(true)
	mover:SetToplevel(true)
	mover:RegisterForDrag("LeftButton")
	mover:SetScript("OnDragStart", mover_OnDragStart)
	mover:SetScript("OnDragStop", mover_OnDragStop)

	mover.object = object

	if isSimple then
		mover.isSimple = true
	else
		mover:SetScript("OnClick", mover_OnClick)
		mover:SetScript("OnEnter", mover_OnEnter)
		mover:SetScript("OnLeave", mover_OnLeave)
		mover:SetShown(areToggledOn)

		mover:SetHighlightTexture("Interface\\BUTTONS\\WHITE8X8")
		mover:GetHighlightTexture():SetAlpha(0.1)

		local bg = mover:CreateTexture(nil, "BACKGROUND", nil, 0)
		bg:SetColorTexture(E:GetRGBA(C.db.global.colors.blue, 0.6))
		bg:SetAllPoints()
		mover.Bg = bg

		mover.buttons = {
			createMoverButton(mover, "Up"),
			createMoverButton(mover, "Down"),
			createMoverButton(mover, "Left"),
			createMoverButton(mover, "Right"),
		}
	end

	if not C.db.profile.movers[E.UI_LAYOUT][name] then
		C.db.profile.movers[E.UI_LAYOUT][name] = {}
	elseif C.db.profile.movers[E.UI_LAYOUT][name].current then
		C.db.profile.movers[E.UI_LAYOUT][name].point = {unpack(C.db.profile.movers[E.UI_LAYOUT][name].current)}
		C.db.profile.movers[E.UI_LAYOUT][name].current = nil
	end

	if not defaults[name] then
		defaults[name] = {}
	end

	defaults[name].point = {E:GetCoords(object)}

	E:UpdateTable(defaults[name], C.db.profile.movers[E.UI_LAYOUT][name])

	mover.Disable = mover_Disable
	mover.Enable = mover_Enable
	mover.IsDragKeyDown = mover_IsDragKeyDown
	mover.IsEnabled = mover_IsEnabled
	mover.PostSaveUpdatePosition = E.NOOP
	mover.ResetPosition = mover_ResetPosition
	mover.SavePosition = mover_SavePosition
	mover.UpdatePosition = mover_UpdatePosition
	mover.UpdateSize = mover_UpdateSize
	mover.WasMoved = mover_WasMoved

	mover:UpdatePosition()

	enabledMovers[name] = mover

	hooksecurefunc(object, "SetPoint", resetObjectPoint)
	resetObjectPoint(object)

	return mover
end

function E.Movers:Get(object, inclDisabled)
	if type(object) == "table" then
		object = object:GetName()
	end

	if not object then return end

	if inclDisabled and disabledMovers[object .. "Mover"] then
		return disabledMovers[object .. "Mover"], true
	end

	return enabledMovers[object .. "Mover"], false
end

function E.Movers:ToggleAll()
	if InCombatLockdown() then return end
	areToggledOn = not areToggledOn

	for _, mover in next, enabledMovers do
		if not mover.isSimple then
			mover:SetShown(areToggledOn)
		end
	end

	if areToggledOn then
		showGrid()

		tracker:SetScript("OnUpdate", tracker_OnUpdate)
	else
		hideGrid()

		tracker:SetScript("OnUpdate", nil)
	end
end

P.Movers = {}

function P.Movers:CleanUpConfig()
	C.db.profile.movers[E.UI_LAYOUT] = E:DiffTable(defaults, C.db.profile.movers[E.UI_LAYOUT])
end

function P.Movers:UpdateConfig()
	E:UpdateTable(defaults, C.db.profile.movers[E.UI_LAYOUT])

	for _, mover in next, enabledMovers do
		updatePosition(mover, nil, "UIParent")

		if mover.isSimple then
			mover:Show()
		else
			if mover:WasMoved() then
				mover.Bg:SetColorTexture(E:GetRGBA(C.db.global.colors.orange, 0.6))
			else
				mover.Bg:SetColorTexture(E:GetRGBA(C.db.global.colors.blue, 0.6))
			end
		end
	end
end

P:AddCommand("movers", function()
	E.Movers:ToggleAll()
end)

E:RegisterEvent("PLAYER_REGEN_DISABLED", function()
	for _, mover in next, enabledMovers do
		if not mover.isSimple then
			if mover:IsMouseEnabled() then
				mover_OnDragStop(mover)
			end

			mover:Hide()
		end
	end

	tracker:SetScript("OnUpdate", nil)

	hideGrid()
end)
