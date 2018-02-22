local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local next = _G.next
local s_upper = _G.string.upper
local type = _G.type
local unpack = _G.unpack

-- Mine
local defaults = {}
local disabledMovers = {}
local enabledMovers = {}

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
			p = p.."RIGHT"
			x = self:GetRight() - screenWidth
		elseif moverCenterX <= screenLeft then
			p = p.."LEFT"
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
		self.Bg:SetColorTexture(M.COLORS.BLUE:GetRGBA(0.6))
	end
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
		if E:IsEqualTable(defaults[self:GetName()], C.db.profile.movers[E.UI_LAYOUT][self:GetName()]) then
			self.Bg:SetColorTexture(M.COLORS.BLUE:GetRGBA(0.6))
		else
			self.Bg:SetColorTexture(M.COLORS.ORANGE:GetRGBA(0.6))
		end
	end
end

local function mover_OnEnter(self)
	local p, anchor, rP, x, y = E:GetCoords(self)

	if anchor == "UIParent" then
		p, rP, x, y = calculatePosition(self)
	end

	GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
	GameTooltip:AddLine(self:GetName())
	GameTooltip:AddLine("|cffffd100Point:|r "..p, 1, 1, 1)
	GameTooltip:AddLine("|cffffd100Attached to:|r "..rP.." |cffffd100of|r "..anchor, 1, 1, 1)
	GameTooltip:AddLine("|cffffd100X:|r "..x..", |cffffd100Y:|r "..y, 1, 1, 1)
	GameTooltip:AddLine(L["MOVER_RESET_DESC"])
	GameTooltip:Show()
end

local function Mover_OnLeave()
	GameTooltip:Hide()
end

local function mover_OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed

	if self.elapsed > 0.1 then
		if GameTooltip:IsOwned(self) then
			mover_OnEnter(self)
		end

		self.elapsed = 0
	end
end

local function mover_OnDragStart(self)
	if not self.isSimple and InCombatLockdown() then return end

	if not self.IsDragKeyDown or self:IsDragKeyDown() then
		self:StartMoving()

		if not self.isSimple then
			self:SetScript("OnUpdate", mover_OnUpdate)
		end
	end
end

local function mover_OnDragStop(self)
	if not self.isSimple and InCombatLockdown() then return end

	self:StopMovingOrSizing()
	self:SetScript("OnUpdate", nil)
	self:UpdatePosition()
end

local function mover_OnClick(self)
	if IsShiftKeyDown() then
		self:ResetPosition()
	else
		local isShown = self.buttons[1]:IsShown()

		for i = 1, #self.buttons do
			self.buttons[i]:SetShown(not isShown)
		end
	end
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

function E.HasMover(_, object)
	if type(object) == "table" then
		object = object:GetName()
	end

	local name = object.."Mover"

	return enabledMovers[name] or disabledMovers[name]
end

function E.GetMover(_, object)
	if type(object) == "table" then
		object = object:GetName()
	end

	return enabledMovers[object.."Mover"]
end

do
	local state = false

	function E.ToggleAllMovers()
		if InCombatLockdown() then return end
		state = not state

		for _, mover in next, enabledMovers do
			if not mover.isSimple then
				mover:SetShown(state)
			end
		end
	end
end

function E.UpdateMoverSize(_, object, width, height)
	local mover = E:GetMover(object)

	if mover then
		mover:SetWidth(width or object:GetWidth())
		mover:SetHeight(height or object:GetHeight())
	end
end

function E.EnableMover(_, object)
	if type(object) == "table" then
		object = object:GetName()
	end

	local name = object.."Mover"

	if enabledMovers[name] then return end

	if not disabledMovers[name] then
		P.print(name, "doesn't exist!")
	end

	enabledMovers[name] = disabledMovers[name]
	disabledMovers[name] = nil

	enabledMovers[name]:UpdatePosition()
end

function E.DisableMover(_, object)
	if type(object) == "table" then
		object = object:GetName()
	end

	local name = object.."Mover"

	if disabledMovers[name] then return end

	if not enabledMovers[name] then
		P.print(name, "doesn't exist!")
	end

	enabledMovers[name]:Hide()

	disabledMovers[name] = enabledMovers[name]
	enabledMovers[name] = nil
end

local function resetObjectPoint(self, _, _, _, _, _, shouldIgnore)
	if not shouldIgnore and E:GetMover(self) then
		self:ClearAllPoints()
		self:SetPoint("TOPRIGHT", E:GetMover(self), "TOPRIGHT", 0, 0, true)
	end
end

function E:CreateMover(object, isSimple, isDragKeyDownFunc, ...)
	if not object then return end

	local objectName = object:GetName()

	if not objectName then return P.print(object:GetDebugName()) end

	local name = objectName.."Mover"
	local iL, iR, iT, iB = ...

	local mover = CreateFrame("Button", name, UIParent)
	mover:SetFrameLevel(object:GetFrameLevel() + 1)
	mover:SetWidth(object:GetWidth())
	mover:SetHeight(object:GetHeight())
	mover:SetClampedToScreen(true)
	mover:SetClampRectInsets(iL or -4, iR or 4, iT or 4, iB or -4)
	mover:SetMovable(true)
	mover:SetToplevel(true)
	mover:RegisterForDrag("LeftButton")
	mover:SetScript("OnDragStart", mover_OnDragStart)
	mover:SetScript("OnDragStop", mover_OnDragStop)

	mover.IsDragKeyDown = isDragKeyDownFunc
	mover.object = object

	if isSimple then
		mover.isSimple = true
	else
		mover:SetScript("OnClick", mover_OnClick)
		mover:SetScript("OnEnter", mover_OnEnter)
		mover:SetScript("OnLeave", Mover_OnLeave)
		mover:Hide()

		local bg = mover:CreateTexture(nil, "BACKGROUND", nil, 0)
		bg:SetColorTexture(M.COLORS.BLUE:GetRGBA(0.6))
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
	else
		if C.db.profile.movers[E.UI_LAYOUT][name].current then
			C.db.profile.movers[E.UI_LAYOUT][name].point = {unpack(C.db.profile.movers[E.UI_LAYOUT][name].current)}
			C.db.profile.movers[E.UI_LAYOUT][name].current = nil
		end
	end

	if not defaults[name] then
		defaults[name] = {}
	end

	defaults[name].point = {self:GetCoords(object)}

	self:UpdateTable(defaults[name], C.db.profile.movers[E.UI_LAYOUT][name])

	mover.ResetPosition = mover_ResetPosition
	mover.SavePosition = mover_SavePosition
	mover.UpdatePosition = mover_UpdatePosition

	mover:UpdatePosition()

	enabledMovers[name] = mover

	hooksecurefunc(object, "SetPoint", resetObjectPoint)
	resetObjectPoint(object)

	return mover
end

function P.CleanUpMoverConfig()
	C.db.profile.movers[E.UI_LAYOUT] = E:DiffTable(defaults, C.db.profile.movers[E.UI_LAYOUT])
end

function P.UpdateMoverConfig()
	E:UpdateTable(defaults, C.db.profile.movers[E.UI_LAYOUT])

	for _, mover in next, enabledMovers do
		updatePosition(mover, nil, "UIParent")

		if mover.isSimple then
			mover:Show()
		else
			if E:IsEqualTable(defaults[mover:GetName()], C.db.profile.movers[E.UI_LAYOUT][mover:GetName()]) then
				mover.Bg:SetColorTexture(M.COLORS.BLUE:GetRGBA(0.6))
			else
				mover.Bg:SetColorTexture(M.COLORS.ORANGE:GetRGBA(0.6))
			end
		end
	end
end

E:RegisterEvent("PLAYER_REGEN_DISABLED", function()
	for _, mover in next, enabledMovers do
		if not mover.isSimple then
			if mover:IsMouseEnabled() then
				mover_OnDragStop(mover)
			end

			mover:Hide()
		end
	end
end)

P:AddCommand("movers", function()
	E:ToggleAllMovers()
end)
