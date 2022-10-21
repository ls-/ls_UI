local _, ns = ...
local E, C, PrC, M, L, P = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)
local assert = _G.assert
local hooksecurefunc = _G.hooksecurefunc
local m_atan2 = _G.math.atan2
local m_cos = _G.math.cos
local m_floor = _G.math.floor
local m_rad = _G.math.rad
local m_sin = _G.math.sin
local m_sqrt = _G.math.sqrt
local next = _G.next
local s_format = _G.string.format
local setmetatable = _G.setmetatable
local t_insert = _G.table.insert
local t_remove = _G.table.remove
local t_wipe = _G.table.wipe
local tostring = _G.tostring
local type = _G.type
local unpack = _G.unpack

-- Mine
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local TOOLTIP_ANCHORS = {
	["BOTTOM"] = {"ANCHOR_TOP", 0, 4},
	["BOTTOMLEFT"] = {"ANCHOR_RIGHT", 4, 4},
	["BOTTOMRIGHT"] = {"ANCHOR_LEFT", -4, 4},
	["LEFT"] = {"ANCHOR_BOTTOMRIGHT", 4, -4},
	["RIGHT"] = {"ANCHOR_BOTTOMLEFT", -4, -4},
	["TOP"] = {"ANCHOR_BOTTOM", 0, -4},
	["TOPLEFT"] = {"ANCHOR_BOTTOMRIGHT", 4, -4},
	["TOPRIGHT"] = {"ANCHOR_BOTTOMLEFT", -4, -4},
}

local moverParent = CreateFrame("Frame", nil, UIParent)
moverParent:SetFrameStrata("HIGH")
moverParent:SetFrameLevel(1000)
moverParent:SetSize(0.0001, 0.0001)

local defaultPoints = {}
local currentPoints = {}
local disabledMovers = {}
local enabledMovers = {}
local trackedMovers = {}
local dirtyObjects = {}
local highlightIndex = 0
local isDragging = false
local areToggledOn = false
local showLabels = false

local controller = CreateFrame("Frame", "LSMoverTracker", UIParent)
controller:SetPoint("TOPLEFT", 0, 0)
controller:SetSize(1, 1)
controller:Hide()
controller:SetScript("OnKeyDown", function(self, key)
	if self.mover then
		self:SetPropagateKeyboardInput(false)
		if key == "LEFT" then
			self.mover:UpdatePosition(-1, 0)
		elseif key == "RIGHT" then
			self.mover:UpdatePosition(1, 0)
		elseif key == "UP" then
			self.mover:UpdatePosition(0, 1)
		elseif key == "DOWN" then
			self.mover:UpdatePosition(0, -1)
		else
			self:SetPropagateKeyboardInput(true)
		end

		if GameTooltip:IsOwned(self.mover) then
			self.mover:OnEnter()
		end
	else
		self:SetPropagateKeyboardInput(true)
	end
end)
controller:SetScript("OnUpdate", function(self, elapsed)
	if not isDragging then
		local isAltKeyDown = IsAltKeyDown()
		if isAltKeyDown ~= self.isAltKeyDown then
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
						if mover ~= self.mover then
							mover:Raise()
							mover:GetScript("OnEnter")(mover)

							self.mover = mover
						end
					else
						trackedMovers[i]:EnableMouse(false)
					end
				end

				for _, mover in next, enabledMovers do
					if not mover.isSimple then
						if mover == self.mover then
							E:FadeIn(mover, 0.15, 0.5)
						else
							E:FadeOut(mover, 0, 0.15, 0.5)
						end
					end
				end
			else
				self.mover = nil

				for _, mover in next, enabledMovers do
					if not mover.isSimple then
						E:FadeIn(mover, 0.15, 0.5)
					end
				end
			end

			self.elapsed = 0
		end
	else
		self.elapsed = 0
	end
end)

local grid = {}
do
	local lines = {}
	local activeLines = {}
	local size = 32

	local parent = CreateFrame("Frame", nil, UIParent)
	parent:SetFrameStrata("BACKGROUND")
	parent:Hide()

	local bg = parent:CreateTexture(nil, "BACKGROUND", nil, -7)
	bg:SetAllPoints(UIParent)
	bg:SetColorTexture(0, 0, 0, 0.33)

	local function acquireLine()
		if not next(lines) then
			t_insert(lines, parent:CreateTexture())
		end

		local line = t_remove(lines, 1)
		line:ClearAllPoints()
		line:Show()

		t_insert(activeLines, line)

		return line
	end

	local function releaseLines()
		while next(activeLines) do
			local line = t_remove(activeLines, 1)
			line:ClearAllPoints()
			line:Hide()

			t_insert(lines, line)
		end
	end

	function grid:SetSize(s)
		size = s
	end

	function grid:GetSize()
		return size
	end

	function grid:Hide()
		parent:Hide()
	end

	function grid:Show()
		releaseLines()

		local screenWidth, screenHeight = UIParent:GetRight(), UIParent:GetTop()
		local screenCenterX, screenCenterY = UIParent:GetCenter()

		parent:SetSize(screenWidth, screenHeight)
		parent:SetPoint("CENTER")
		parent:Show()

		local yAxis = acquireLine()
		yAxis:SetDrawLayer("BACKGROUND", 1)
		yAxis:SetColorTexture(0.9, 0.1, 0.1)
		yAxis:SetPoint("TOPLEFT", parent, "TOPLEFT", screenCenterX - 1, 0)
		yAxis:SetPoint("BOTTOMRIGHT", parent, "BOTTOMLEFT", screenCenterX + 1, 0)

		local xAxis = acquireLine()
		xAxis:SetDrawLayer("BACKGROUND", 1)
		xAxis:SetColorTexture(0.9, 0.1, 0.1)
		xAxis:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 0, screenCenterY + 1)
		xAxis:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, screenCenterY - 1)

		local l = acquireLine()
		l:SetDrawLayer("BACKGROUND", 2)
		l:SetColorTexture(0.8, 0.8, 0.1)
		l:SetPoint("TOPLEFT", parent, "TOPLEFT", screenWidth / 3 - 1, 0)
		l:SetPoint("BOTTOMRIGHT", parent, "BOTTOMLEFT", screenWidth / 3 + 1, 0)

		local r = acquireLine()
		r:SetDrawLayer("BACKGROUND", 2)
		r:SetColorTexture(0.8, 0.8, 0.1)
		r:SetPoint("TOPRIGHT", parent, "TOPRIGHT", - screenWidth / 3 + 1, 0)
		r:SetPoint("BOTTOMLEFT", parent, "BOTTOMRIGHT", - screenWidth / 3 - 1, 0)

		-- horiz lines
		local tex
		for i = 1, m_floor(screenHeight / 2 / size) do
			tex = acquireLine()
			tex:SetDrawLayer("BACKGROUND", 0)
			tex:SetColorTexture(0, 0, 0)
			tex:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 0, screenCenterY + 1 + size * i)
			tex:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, screenCenterY - 1 + size * i)

			tex = acquireLine()
			tex:SetDrawLayer("BACKGROUND", 0)
			tex:SetColorTexture(0, 0, 0)
			tex:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, screenCenterY - 1 - size * i)
			tex:SetPoint("TOPRIGHT", parent, "BOTTOMRIGHT", 0, screenCenterY + 1 - size * i)
		end

		-- vert lines
		for i = 1, m_floor(screenWidth / 2 / size) do
			tex = acquireLine()
			tex:SetDrawLayer("BACKGROUND", 0)
			tex:SetColorTexture(0, 0, 0)
			tex:SetPoint("TOPLEFT", parent, "TOPLEFT", screenCenterX - 1 - size * i, 0)
			tex:SetPoint("BOTTOMRIGHT", parent, "BOTTOMLEFT", screenCenterX + 1 - size * i, 0)

			tex = acquireLine()
			tex:SetDrawLayer("BACKGROUND", 0)
			tex:SetColorTexture(0, 0, 0)
			tex:SetPoint("TOPRIGHT", parent, "TOPLEFT", screenCenterX + 1 + size * i, 0)
			tex:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", screenCenterX - 1 + size * i, 0)
		end
	end
end

local relationLines = {}
do
	local segments = {}
	local lines = {}

	local function acquireSegment()
		if not next(segments) then
			t_insert(segments, moverParent:CreateTexture(nil, "OVERLAY"))
		end

		local segment = t_remove(segments, 1)
		segment:SetAtlas("minimap-deadarrow")
		-- segment:SetAtlas("minimap-questarrow")
		-- segment:SetAtlas("minimap-vignettearrow")
		segment:SetSize(16, 16)
		segment:SetAlpha(0.75)
		segment:ClearAllPoints()
		segment:SetShown(areToggledOn)

		return segment
	end

	local function releaseSegment(segment)
		segment:ClearAllPoints()
		segment:Hide()

		t_insert(segments, segment)
	end

	function relationLines:Remove(hive, drone)
		if not lines[hive] then return end
		if not lines[hive][drone] then return end

		for _, segment in next, lines[hive][drone] do
			releaseSegment(segment)
		end

		t_wipe(lines[hive][drone])
	end

	function relationLines:Hide()
		for _, mover in next, enabledMovers do
			for drone in next, mover:GetDrones() do
				if drone:IsEnabled() then
					relationLines:Remove(mover, drone)
				end
			end
		end
	end

	local function lerp(v1, v2, perc)
		return v1 + (v2 - v1) * perc
	end

	function relationLines:Add(hive, drone)
		relationLines:Remove(hive, drone)

		local hiveX, hiveY = hive:GetCenter()
		hiveX, hiveY = hiveX or 0, hiveY or 0

		local droneX, droneY = drone:GetCenter()
		droneX, droneY = droneX or 0, droneY or 0

		local dX = droneX - hiveX
		local dY = droneY - hiveY
		local distance = m_sqrt(dX ^ 2 + dY ^ 2)
		local angle = m_atan2(dY, dX)
		local rotation = angle + m_rad(90)
		local space = lerp(8, 48, distance / 1024)
		local padding = space / 4
		local num = m_floor(distance / space)

		if not lines[hive] then
			lines[hive] = {
				[drone] = {}
			}
		elseif not lines[hive][drone] then
			lines[hive][drone] = {}
		end

		local relationLine = lines[hive][drone]

		for i = 1, num do
			local x = (i * space - padding) * m_cos(angle)
			local y = (i * space - padding) * m_sin(angle)

			relationLine[i] = acquireSegment()
			relationLine[i]:SetPoint("CENTER", hive, "CENTER", x, y)
			relationLine[i]:SetRotation(rotation)
		end
	end

	function relationLines:Show()
		for _, mover in next, enabledMovers do
			for drone in next, mover:GetDrones() do
				if drone:IsEnabled() then
					relationLines:Add(mover, drone)
				end
			end
		end
	end
end

local lasso
do
	lasso = CreateFrame("Frame", nil, moverParent)
	lasso:SetSize(16, 16)
	lasso:SetScript("OnUpdate", function(self)
		local x, y = GetCursorPosition()
		local scale = UIParent:GetEffectiveScale()
		self:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x / scale - 8, y / scale - 8)

		if self.mover then
			relationLines:Add(self, self.mover)
		end
	end)
	lasso:Hide()

	local texture = lasso:CreateTexture()
	texture:SetSize(32, 32)
	texture:SetPoint("CENTER", 0, 0)
	texture:SetTexture("Interface\\Cursor\\Crosshairs")
end

local settings
do
	settings = CreateFrame("Frame", "LSMoverSettings", UIParent)
	settings:SetSize(320, 320)
	settings:SetPoint("CENTER")
	settings:SetMovable(true)
	settings:EnableMouse(true)
	settings:RegisterForDrag("LeftButton")
	settings:SetClampedToScreen(true)
	settings:SetScript("OnDragStart", settings.StartMoving)
	settings:SetScript("OnDragStop", settings.StopMovingOrSizing)
	settings:SetScript("OnShow", function(self)
		self.NameToggle.Text:SetText(L["MOVER_NAMES"])
		self.GridDropdown:SetText(L["MOVER_GRID"])
		self.UsageText:SetText(L["MOVER_MOVE_DESC"]
			.. "\n\n"
			.. L["MOVER_RESET_DESC"]
			.. "\n\n"
			.. L["MOVER_CYCLE_DESC"]
			.. "\n\n"
			.. L["MOVER_RELATION_CREATE_DESC"]
			.. "\n\n"
			.. L["MOVER_RELATION_DESTROY_DESC"])
		self.LockButton.Text:SetText(L["LOCK"])
		self:SetHeight(m_floor(self.UsageText:GetStringHeight() + 50))
	end)
	settings:Hide()

	local bg = settings:CreateTexture(nil, "BACKGROUND", nil, -7)
	bg:SetAllPoints()
	bg:SetTexture("Interface\\HELPFRAME\\DarkSandstone-Tile", "REPEAT", "REPEAT")
	bg:SetHorizTile(true)
	bg:SetVertTile(true)

	local border = E:CreateBorder(settings)
	border:SetTexture("Interface\\AddOns\\ls_UI\\assets\\border-thick")
	settings.Border = border

	local nameToggle = CreateFrame("CheckButton", "$parentNameToggle", settings, "UICheckButtonTemplate")
	nameToggle:SetPoint("TOPLEFT", 1, 0)
	nameToggle:SetScript("OnClick", function()
		showLabels = not showLabels

		for _, mover in next, enabledMovers do
			if not mover.isSimple then
				mover.Text:SetShown(showLabels)
			end
		end
	end)
	settings.NameToggle = nameToggle

	nameToggle.Text = _G[nameToggle:GetName() .. "Text"]

	local gridDropdown = LibStub("LibDropDown"):NewButtonStretch(settings, "$parentGridDropdown")
	gridDropdown:SetPoint("TOPRIGHT", -3, -3)
	gridDropdown:SetSize(120, 20)
	gridDropdown:SetFrameLevel(3)
	gridDropdown:SetText(L["MOVER_GRID"])
	settings.GridDropdown = gridDropdown

	local info = {
		isRadio = true,
		func = function(_, _, value)
			grid:SetSize(value)
			grid:Show()
		end,
		checked = function(self)
			return grid:GetSize() == self.args[1]
		end,
	}

	local GRID_SIZES = {4, 8, 16, 32}
	for i = 1, #GRID_SIZES do
		info.text = tostring(GRID_SIZES[i])
		info.args = {GRID_SIZES[i]}

		gridDropdown:Add(info)
	end

	local usageText = settings:CreateFontString(nil, "OVERLAY")
	usageText:SetFontObject("GameFontNormal")
	usageText:SetPoint("TOPLEFT", 4, -24)
	usageText:SetPoint("BOTTOMRIGHT", -4, 26)
	usageText:SetJustifyH("LEFT")
	usageText:SetJustifyV("MIDDLE")
	settings.UsageText = usageText

	local lockButton = CreateFrame("Button", "$parentLockButton", settings, "UIPanelButtonTemplate")
	lockButton:SetHeight(21)
	lockButton:SetPoint("LEFT", 2, 0)
	lockButton:SetPoint("RIGHT", -2, 0)
	lockButton:SetPoint("BOTTOM", 0, 3)
	lockButton:SetScript("OnClick", function()
		E.Movers:ToggleAll()
	end)
	settings.LockButton = lockButton
end

local function getPoint(self)
	local p, anchor, rP, x, y = self:GetPoint()
	if not x then
		return p, anchor, rP, x, y
	else
		return p, anchor and anchor:GetName() or "UIParent", rP, E:Round(x), E:Round(y)
	end
end

local function calculatePosition(self, xOffset, yOffset, forceUIParent)
	local moverCenterX, moverCenterY = self:GetCenter()
	local parent = forceUIParent and UIParent or self:GetHive() and self:GetHive():GetObject() or UIParent
	local p, rP, x, y

	if moverCenterX and moverCenterY then
		xOffset, yOffset = xOffset or 0, yOffset or 0
		moverCenterX, moverCenterY = E:Round(moverCenterX + xOffset), E:Round(moverCenterY + yOffset)
		local moverLeftX = self:GetLeft()
		moverLeftX = E:Round(moverLeftX + xOffset)
		local moverRightX = self:GetRight()
		moverRightX = E:Round(moverRightX + xOffset)
		local moverTopY = self:GetTop()
		moverTopY = E:Round(moverTopY + yOffset)
		local moverBottomY = self:GetBottom()
		moverBottomY = E:Round(moverBottomY + yOffset)

		local parentWidth = parent:GetWidth()
		parentWidth = E:Round(parentWidth)
		local parentCenterX, parentCenterY = parent:GetCenter()
		parentCenterX, parentCenterY = E:Round(parentCenterX), E:Round(parentCenterY)
		local parentLeftX = parentCenterX - parentWidth / 6
		local parentRightX = parentCenterX + parentWidth / 6

		if moverCenterY >= parentCenterY then
			if moverBottomY >= parent:GetTop() then
				p = "BOTTOM"
				rP = "TOP"
				y = moverBottomY - parent:GetTop()
			else
				p = "TOP"
				rP = "TOP"
				y = moverTopY - parent:GetTop()
			end
		else
			if moverTopY <= parent:GetBottom() then
				p = "TOP"
				rP = "BOTTOM"
				y = moverTopY - parent:GetBottom()
			else
				p = "BOTTOM"
				rP = "BOTTOM"
				y = moverBottomY - parent:GetBottom()
			end
		end

		if moverCenterX >= parentRightX then
			if moverLeftX >= parent:GetRight() then
				p = p .. "LEFT"
				rP = rP .. "RIGHT"
				x = moverLeftX - parent:GetRight()
			else
				p = p .. "RIGHT"
				rP = rP .. "RIGHT"
				x = moverRightX - parent:GetRight()
			end
		elseif moverCenterX <= parentLeftX then
			if moverRightX <= parent:GetLeft() then
				p = p .. "RIGHT"
				rP = rP .. "LEFT"
				x = moverRightX - parent:GetLeft()
			else
				p = p .. "LEFT"
				rP = rP .. "LEFT"
				x = moverLeftX - parent:GetLeft()
			end
		else
			x = moverCenterX - parentCenterX
		end

		x, y = E:Round(x), E:Round(y)

		-- jic we got out of screen bounds because of offsets
		if parent == UIParent then
			local l, r, t, b = self:GetClampRectInsets()
			l, r, t, b = E:Round(-l), E:Round(-r), E:Round(-t), E:Round(-b)

			if p == "BOTTOM" then
				if y < b then
					y = b
				end
			elseif p == "BOTTOMLEFT" then
				if x < l then
					x = l
				end

				if y < b then
					y = b
				end
			elseif p == "BOTTOMRIGHT" then
				if x > r then
					x = r
				end

				if y < b then
					y = b
				end
			elseif p == "TOP" then
				if y > t then
					y = t
				end
			elseif p == "TOPLEFT" then
				if x < l then
					x = l
				end

				if y > t then
					y = t
				end
			elseif p == "TOPRIGHT" then
				if x > r then
					x = r
				end

				if y > t then
					y = t
				end
			end
		end
	end


	return p, parent:GetName(), rP, x, y
end

local function updatePosition(self, p, anchor, rP, x, y)
	if not x then
		if currentPoints[self:GetName()] then
			p, anchor, rP, x, y = self:GetCurrentPosition()
			anchor = anchor or "UIParent"
		end

		if not x then
			self:ResetPosition()
			return
		end
	end

	self:ClearAllPoints()
	self:SetPoint(p, anchor, rP, x, y)

	return p, anchor, rP, x, y
end

local function resetObjectPoint(self, _, _, _, _, _, shouldIgnore)
	local mover = E.Movers:Get(self)
	if mover and not shouldIgnore then
		if not InCombatLockdown() then
			self:ClearAllPoints()

			local p, anchor, rP, x, y = mover:GetCurrentPosition()
			if anchor ~= "UIParent" then
				p, anchor, rP, x, y = calculatePosition(mover, 0, 0, true)
			end

			if p then
				dirtyObjects[self] = nil

				self:SetPoint(p, anchor, rP, x - mover.offsetX, y - mover.offsetY, true)
			else
				-- I need to do this because some of the frames I move around are managed by Blizz
				-- layout manager, so I can't have my movers as anchors since they're created after
				-- their layout manager positions the frames, so I want all frames to be anchored to
				-- UIParent
				dirtyObjects[self] = true

				self:SetPoint("TOPRIGHT", mover, "TOPRIGHT", -mover.offsetX, -mover.offsetY, true)
			end
		else
			dirtyObjects[self] = true
		end
	end
end

local mover_proto = {
	["PostSaveUpdatePosition"] = E.NOOP,
}

function mover_proto:SavePosition(p, anchor, rP, x, y)
	currentPoints[self:GetName()] = {p, anchor, rP, x, y}
end

function mover_proto:GetCurrentPosition()
	return unpack(currentPoints[self:GetName()])
end

function mover_proto:GetDefaultPosition()
	return unpack(defaultPoints[self:GetName()])
end

function mover_proto:ResetPosition()
	if not self.isSimple and InCombatLockdown() then return end

	local p, anchor, rP, x, y = self:GetDefaultPosition()

	self:RemoveRelationLines()
	self:RemoveFromHive()

	if anchor ~= "UIParent" then
		local hive = enabledMovers[anchor .. "Mover"]
		if hive then
			-- might be a bit counterproductive
			local oldDrones = self:RemoveDrones()
			for drone in next, oldDrones do
				drone:UpdatePosition()
			end

			if not hive:HasInHierarchy(self) then
				self:AddToHive(hive)
			end
		end
	end

	self:ClearAllPoints()
	self:SetPoint(p, anchor, rP, x, y)
	self:SavePosition(p, anchor, rP, x, y)

	resetObjectPoint(self.object)

	self:AddRelationLines()

	if not self.isSimple then
		self.Bg:SetColorTexture(E:GetRGBA(C.db.global.colors.black, 0.6))
	end

	self:PostSaveUpdatePosition()
end

function mover_proto:UpdatePosition(xOffset, yOffset)
	if not self.isSimple and InCombatLockdown() then return end

	local p, anchor, rP, x, y = calculatePosition(self, xOffset, yOffset)
	p, anchor, rP, x, y = updatePosition(self, p, anchor, rP, x, y)

	self:SavePosition(p, anchor, rP, x, y)

	resetObjectPoint(self.object)

	for drone in next, self:GetDrones() do
		if drone:IsEnabled() then
			resetObjectPoint(drone.object)
		end
	end

	self:AddRelationLines()

	if self.isSimple then
		self:Show()
	else
		if self:WasMoved() then
			self.Bg:SetColorTexture(E:GetRGBA(C.db.global.colors.orange, 0.6))
		else
			self.Bg:SetColorTexture(E:GetRGBA(C.db.global.colors.black, 0.6))
		end
	end

	self:PostSaveUpdatePosition()
end

function mover_proto:OnEnter()
	local p, anchor, rP, x, y = calculatePosition(self)

	GameTooltip:SetOwner(self, unpack(TOOLTIP_ANCHORS[p]))
	GameTooltip:AddLine(self:GetName())
	GameTooltip:AddLine("|cffffd100Point:|r " .. p, 1, 1, 1)
	GameTooltip:AddLine("|cffffd100Attached to:|r " .. rP .. " |cffffd100of|r " .. anchor, 1, 1, 1)
	GameTooltip:AddLine("|cffffd100X:|r " .. x .. ", |cffffd100Y:|r " .. y, 1, 1, 1)
	GameTooltip:Show()
end

function mover_proto:OnLeave()
	GameTooltip:Hide()
end

function mover_proto:OnUpdate(elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > 0.1 then
		if GameTooltip:IsOwned(self) then
			if self:IsMouseOver() then
				self:OnEnter()
			else
				self:OnLeave()
			end
		end

		self.elapsed = 0
	end

	self:AddRelationLines()
end

function mover_proto:OnDragStart()
	if not self.isSimple and InCombatLockdown() then return end

	if self:IsDragKeyDown() then
		self:StartMoving()

		if not self:GetScript("OnUpdate") then
			self:SetScript("OnUpdate", self.OnUpdate)
		end

		isDragging = true
	end
end

function mover_proto:OnDragStop()
	if not self.isSimple and InCombatLockdown() then return end

	self:SetScript("OnUpdate", nil)
	self:StopMovingOrSizing()
	self:UpdatePosition()

	isDragging = false
end

function mover_proto:OnClick()
	if IsShiftKeyDown() then
		self:ResetPosition()

		if GameTooltip:IsOwned(self) then
			self:OnEnter()
		end
	end
end

function mover_proto:OnMouseWheel(offset)
	if IsShiftKeyDown() then
		self:UpdatePosition(0, offset)
	elseif IsControlKeyDown() then
		self:UpdatePosition(offset, 0)
	end

	if GameTooltip:IsOwned(self) then
		self:OnEnter()
	end
end

function mover_proto:IsEnabled()
	return not not enabledMovers[self:GetName()]
end

-- it's here for other things to override
function mover_proto:IsDragKeyDown()
	return true
end

function mover_proto:WasMoved()
	return not E:IsEqualTable(defaultPoints[self:GetName()], currentPoints[self:GetName()])
end

function mover_proto:AddRelationLines()
	for drone in next, self:GetDrones() do
		if drone:IsEnabled() then
			relationLines:Add(self, drone)
		end
	end

	local hive = self:GetHive()
	if hive then
		relationLines:Add(hive, self)
	end
end

function mover_proto:RemoveRelationLines()
	for drone in next, self:GetDrones() do
		if drone:IsEnabled() then
			relationLines:Remove(self, drone)
		end
	end

	local hive = self:GetHive()
	if hive then
		relationLines:Remove(hive, self)
	end
end

function mover_proto:HasInHierarchy(drone)
	local hive = self:GetHive()
	if hive then
		if hive == drone then
			return true
		else
			return hive:HasInHierarchy(drone)
		end
	else
		return false
	end
end

function mover_proto:GetDrones()
	return self.drones
end

function mover_proto:AddDrone(drone)
	drone.hive = self
	self.drones[drone] = true

	return true
end

function mover_proto:RemoveDrone(drone)
	drone.hive = nil
	self.drones[drone] = nil
end

function mover_proto:RemoveDrones()
	local old = {}

	for drone in next, self:GetDrones() do
		drone.hive = nil
		old[drone] = true
	end

	t_wipe(self:GetDrones())

	return old
end

function mover_proto:GetHive()
	return self.hive
end

function mover_proto:AddToHive(hive)
	self:RemoveFromHive()
	return hive:AddDrone(self)
end

function mover_proto:RemoveFromHive()
	local hive = self:GetHive()
	if hive then
		hive:RemoveDrone(self)
	end

	return hive
end

function mover_proto:Enable()
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

function mover_proto:Disable()
	local name = self:GetName()

	if disabledMovers[name] or not enabledMovers[name] then return end

	enabledMovers[name]:Hide()

	disabledMovers[name] = enabledMovers[name]
	enabledMovers[name] = nil
end

function mover_proto:UpdateSize(width, height)
	self:SetWidth(width or (self.object:GetWidth() + self.offsetX * 2))
	self:SetHeight(height or (self.object:GetHeight() + self.offsetY * 2))
end

function mover_proto:GetObject()
	return self.object
end

local anchor_proto = {}

function anchor_proto:OnClick()
	if IsShiftKeyDown() then
		local mover = self:GetParent()
		mover:RemoveRelationLines()
		mover:RemoveFromHive()

		local oldDrones = mover:RemoveDrones()
		for drone in next, oldDrones do
			drone:UpdatePosition()
		end

		mover:UpdatePosition()
	end
end

function anchor_proto:OnEnter()
	self:SetAlpha(1)
	self.Texture:SetVertexColor(0, 1, 0.92)
end

function anchor_proto:OnLeave()
	self:SetAlpha(0.5)
	self.Texture:SetVertexColor(1, 1, 1)
end

function anchor_proto:OnDragStart()
	lasso.mover = self:GetParent()
	lasso:Show()
end

function anchor_proto:OnDragStop()
	local mover = self:GetParent()

	relationLines:Remove(lasso, mover)
	lasso.mover = nil
	lasso:Hide()

	if controller.mover and controller.mover ~= mover and not controller.mover:HasInHierarchy(mover) then
		mover:RemoveRelationLines()
		mover:AddToHive(controller.mover)
		mover:UpdatePosition()
	end
end

local onCreateCallbacks = {}

local callback_meta = {
	__call = function(callbacks, self, ...)
		for _, callback in next, callbacks do
			callback(self, ...)
		end

		t_wipe(callbacks)
	end,
}

E.Movers = {}

function E.Movers:Create(object, isSimple, offsetX, offsetY)
	if not object then return end

	local objectName = object:GetName()

	assert(objectName, (s_format("Failed to create a mover, object '%s' has no name", object:GetDebugName())))

	hooksecurefunc(object, "SetPoint", resetObjectPoint)

	local name = objectName .. "Mover"
	local info = {
		object = object,
		isSimple = isSimple,
		offsetX = offsetX or 0,
		offsetY = offsetY or 0,
		-- hive = nil,
		drones = {},
	}

	local mover = Mixin(CreateFrame("Button", name, moverParent), mover_proto, info)
	mover:SetFrameStrata(object:GetFrameStrata())
	mover:SetFrameLevel(object:GetFrameLevel() + 4)
	mover:SetWidth(object:GetWidth() + mover.offsetX * 2)
	mover:SetHeight(object:GetHeight() + mover.offsetX * 2)
	mover:SetClampedToScreen(true)
	mover:SetClampRectInsets(-4, 4, 4, -4)
	mover:SetMovable(true)
	mover:SetToplevel(true)
	mover:RegisterForDrag("LeftButton")
	mover:SetScript("OnDragStart", mover.OnDragStart)
	mover:SetScript("OnDragStop", mover.OnDragStop)

	if not isSimple then
		mover:SetScript("OnClick", mover.OnClick)
		mover:SetScript("OnEnter", mover.OnEnter)
		mover:SetScript("OnLeave", mover.OnLeave)
		mover:SetScript("OnMouseWheel", mover.OnMouseWheel)
		mover:SetShown(areToggledOn)

		local bg = mover:CreateTexture(nil, "BACKGROUND", nil, 0)
		bg:SetColorTexture(E:GetRGBA(C.db.global.colors.black, 0.6))
		bg:SetAllPoints()
		mover.Bg = bg

		local text = mover:CreateFontString(nil, "OVERLAY")
		text:SetFontObject("GameFontNormalOutline")
		text:SetPoint("CENTER")
		text:SetText(name)
		text:SetShown(showLabels)
		mover.Text = text

		local anchor = Mixin(CreateFrame("Button", nil, mover), anchor_proto)
		anchor:SetSize(16, 16)
		anchor:SetAlpha(0.5)
		anchor:SetPoint("CENTER", mover, "CENTER", 0, 0)
		anchor:RegisterForDrag("LeftButton")
		anchor:SetScript("OnClick", anchor.OnClick)
		anchor:SetScript("OnEnter", anchor.OnEnter)
		anchor:SetScript("OnLeave", anchor.OnLeave)
		anchor:SetScript("OnDragStart", anchor.OnDragStart)
		anchor:SetScript("OnDragStop", anchor.OnDragStop)
		mover.RelationAnchor = anchor

		local anchorTexture = anchor:CreateTexture()
		anchorTexture:SetSize(12, 12)
		anchorTexture:SetPoint("CENTER", 0, 0)
		anchorTexture:SetAtlas("UI-Taxi-Icon-Nub")
		anchor.Texture = anchorTexture

		local border = E:CreateBorder(mover)
		border:SetTexture({1, 1, 1, 1})
		border:SetVertexColor(E:GetRGB(C.db.global.colors.class[E.PLAYER_CLASS]))
		border:SetSize(1)
		border:SetOffset(0)
		mover.Border = border
	end

	defaultPoints[name] = {getPoint(object)}

	currentPoints[name] = {getPoint(object)}

	if C.db.profile.movers[name] then
		E:CopyTable(C.db.profile.movers[name], currentPoints[name])
	end

	local parentName = currentPoints[name][2]
	if parentName and parentName ~= "UIParent" then
		local hive = enabledMovers[parentName .. "Mover"]
		if hive then
			-- print(mover:GetDebugName(), "|cff00ff00==>|r", parentName)
			if not hive:HasInHierarchy(mover) then
				mover:AddToHive(hive)
			end

			enabledMovers[name] = mover

			mover:UpdatePosition()
		else
			if not onCreateCallbacks[parentName] then
				onCreateCallbacks[parentName] = setmetatable({}, callback_meta)
			end

			-- print(mover:GetDebugName(), "|cffff0000==>|r", parentName)
			t_insert(onCreateCallbacks[parentName], function(self)
				-- print(mover:GetDebugName(), "|cff00ff00==late=>|r", parentName)
				if not self:HasInHierarchy(mover) then
					mover:AddToHive(self)
				end

				enabledMovers[name] = mover

				mover:UpdatePosition()
			end)
		end
	else
		-- print(mover:GetDebugName(), "|cffffd200==>|r", parentName)
		enabledMovers[name] = mover

		mover:UpdatePosition()
	end

	if onCreateCallbacks[objectName] then
		onCreateCallbacks[objectName](mover)
	end

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

local reopenConfig

function E.Movers:ToggleAll(...)
	if InCombatLockdown() then return end
	areToggledOn = not areToggledOn

	for _, mover in next, enabledMovers do
		if not mover.isSimple then
			mover:SetShown(areToggledOn)
		end
	end

	if areToggledOn then
		reopenConfig = ...

		grid:Show()
		relationLines:Show()
		settings:Show()
		controller:Show()
	else
		grid:Hide()
		relationLines:Hide()
		settings:Hide()
		controller:Hide()

		if reopenConfig then
			if AceConfigDialog then
				AceConfigDialog:Open("ls_UI")
			end
		end
	end
end

function E.Movers:UpdateAll()
	for _, mover in next, enabledMovers do
		updatePosition(mover, nil)

		if mover.isSimple then
			mover:Show()
		else
			if mover:WasMoved() then
				mover.Bg:SetColorTexture(E:GetRGBA(C.db.global.colors.orange, 0.6))
			else
				mover.Bg:SetColorTexture(E:GetRGBA(C.db.global.colors.black, 0.6))
			end
		end
	end
end

function E.Movers:SaveConfig()
	E:DiffTable(defaultPoints, E:CopyTable(currentPoints, C.db.profile.movers))
end

function E.Movers:ApplyConfig()
	t_wipe(currentPoints)
	E:CopyTable(defaultPoints, currentPoints)

	for name, point in next, C.db.profile.movers do
		if currentPoints[name] then
			E:CopyTable(point, currentPoints[name])
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
				mover:OnDragStop()
			end

			mover:Hide()
		end
	end

	grid:Hide()
	relationLines:Hide()
	settings:Hide()
	controller:Hide()
end)

E:RegisterEvent("FIRST_FRAME_RENDERED", function()
	if not InCombatLockdown() then
		for object in next, dirtyObjects do
			resetObjectPoint(object)
		end
	end
end)

E:RegisterEvent("PLAYER_REGEN_ENABLED", function()
	for object in next, dirtyObjects do
		resetObjectPoint(object)
	end
end)
