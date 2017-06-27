local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)
local unpack = _G.unpack
local next = _G.next

-- Blizz
local GameTooltip = _G.GameTooltip
local IsShiftKeyDown = _G.IsShiftKeyDown
local InCombatLockdown = _G.InCombatLockdown

if not _G.DevTools_Dump then
	_G.LoadAddOn("Blizzard_DebugTools")
end

-- Mine
local defaults = {}
local disabledMovers = {}
local enabledMovers = {}

local function CalculatePosition(self)
	local moverCenterX, moverCenterY = self:GetCenter()
	local p, x, y

	if moverCenterX and moverCenterY then
		local screenWidth = _G.UIParent:GetRight()
		local screenHeight = _G.UIParent:GetTop()
		local screenCenterX, screenCenterY = _G.UIParent:GetCenter()
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

local function SavePosition(self, p, anchor, rP, x, y)
	C.db.profile.movers[E.UI_LAYOUT][self:GetName()].point = {p, anchor, rP, x, y}
end

local function ResetPosition(self)
	if not self.isSimple and InCombatLockdown() then return end

	local p, anchor, rP, x, y = unpack(defaults[self:GetName()].point)

	self:ClearAllPoints()
	self:SetPoint(p, anchor, rP, x, y)

	self.parent:ClearAllPoints()
	self.parent:SetPoint(p, anchor, rP, x, y)

	C.db.profile.movers[E.UI_LAYOUT][self:GetName()].point = nil

	if not self.isSimple then
		self.Bg:SetColorTexture(M.COLORS.BLUE:GetRGBA(0.6))
	end
end

local function SetPosition(self, xOffset, yOffset)
	if not self.isSimple and InCombatLockdown() then return end

	local p, rP, x, y = CalculatePosition(self)
	local anchor = "UIParent"

	if not x then
		if C.db.profile.movers[E.UI_LAYOUT][self:GetName()].point then
			p, anchor, rP, x, y = unpack(C.db.profile.movers[E.UI_LAYOUT][self:GetName()].point)
			anchor = anchor or "UIParent"
		end

		if not x then
			ResetPosition(self)

			return
		end
	end

	self:ClearAllPoints()
	self:SetPoint(p, anchor, rP, x + (xOffset or 0), y + (yOffset or 0))

	self.parent:ClearAllPoints()
	self.parent:SetPoint(p, anchor, rP, x + (xOffset or 0), y + (yOffset or 0))

	SavePosition(self, p, anchor, rP, x + (xOffset or 0), y + (yOffset or 0))

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

local function Mover_OnEnter(self)
	local p, anchor, rP, x, y = E:GetCoords(self)

	if anchor == "UIParent" then
		p, rP, x, y = CalculatePosition(self)
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

local function Mover_OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed

	if self.elapsed > 0.1 then
		if GameTooltip:IsOwned(self) then
			Mover_OnEnter(self)
		end

		self.elapsed = 0
	end
end

local function Mover_OnDragStart(self)
	if not self.isSimple and InCombatLockdown() then return end

	self:StartMoving()

	if self.isSimple then
		self.parent:ClearAllPoints()
		self.parent:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)
	else
		self:SetScript("OnUpdate", Mover_OnUpdate)
	end
end

local function Mover_OnDragStop(self)
	if not self.isSimple and InCombatLockdown() then return end

	self:StopMovingOrSizing()
	self:SetScript("OnUpdate", nil)

	SetPosition(self)

	self:SetUserPlaced(false)
end

local function Mover_OnClick(self)
	if IsShiftKeyDown() then
		ResetPosition(self)
	else
		if self.buttons[1]:IsShown() then
			for i = 1, #self.buttons do
				self.buttons[i]:Hide()
			end
		else
			for i = 1, #self.buttons do
				self.buttons[i]:Show()
			end
		end
	end
end

local function Button_OnEnter(self)
	Mover_OnEnter(self:GetParent())
end

local MOVER_BUTTONS = {
	UP = {
		anchor = "TOP",
		func = function(self)
			local mover = self:GetParent()

			SetPosition(mover, 0, 1)

			if GameTooltip:IsOwned(mover) then
				Mover_OnEnter(mover)
			end
		end
	},
	DOWN = {
		anchor = "BOTTOM",
		func = function(self)
			local mover = self:GetParent()

			SetPosition(mover, 0, -1)

			if GameTooltip:IsOwned(mover) then
				Mover_OnEnter(mover)
			end
		end
	},
	LEFT = {
		anchor = "LEFT",
		func = function(self)
			local mover = self:GetParent()

			SetPosition(mover, -1, 0)

			if GameTooltip:IsOwned(mover) then
				Mover_OnEnter(mover)
			end
		end
	},
	RIGHT = {
		anchor = "RIGHT",
		func = function(self)
			local mover = self:GetParent()

			SetPosition(mover, 1, 0)

			if GameTooltip:IsOwned(mover) then
				Mover_OnEnter(mover)
			end
		end
	},
}

local function CreateMoverButton(mover, type)
	local button = _G.CreateFrame("Button", nil, mover, "UIPanelSquareButton")
	button:SetPoint("CENTER", mover, MOVER_BUTTONS[type].anchor, 0, 0)
	button:SetSize(10, 10)
	button:SetScript("OnClick", MOVER_BUTTONS[type].func)
	button:SetScript("OnEnter", Button_OnEnter)
	button:SetScript("OnLeave", Mover_OnLeave)
	button:Hide()
	mover[type] = button

	_G.SquareButton_SetIcon(button, type)

	E:SkinSquareButton(button)

	return button
end

function E:HasMover(object)
	local name = object:GetName().."Mover"
	return enabledMovers[name] or disabledMovers[name]
end

function E:GetMover(object)
	return enabledMovers[object:GetName().."Mover"]
end

do
	local state = false

	function E:ToggleAllMovers()
		if InCombatLockdown() then return end
		state = not state

		for _, mover in next, enabledMovers do
			if not mover.isSimple then
				mover:SetShown(state)
			end
		end
	end
end

function E:UpdateMoverSize(object, width, height)
	local name = object:GetName().."Mover"
	local mover = enabledMovers[name] or disabledMovers[name]

	if mover then
		mover:SetWidth(width or object:GetWidth())
		mover:SetHeight(height or object:GetHeight())
	end
end

function E:EnableMover(object)
	local name = object:GetName().."Mover"

	if enabledMovers[name] then return end

	if not disabledMovers[name] then
		P.print(name, "doesn't exist!")
	end

	enabledMovers[name] = disabledMovers[name]
	disabledMovers[name] = nil

	SetPosition(enabledMovers[name])
end

function E:DisableMover(object)
	local name = object:GetName().."Mover"

	if disabledMovers[name] then return end

	if not enabledMovers[name] then
		P.print(name, "doesn't exist!")
	end

	enabledMovers[name]:Hide()

	disabledMovers[name] = enabledMovers[name]
	enabledMovers[name] = nil
end

function E:CreateMover(object, isSimple, ...)
	if not object then return end

	local objectName = object:GetName()

	if not objectName then return P.print(object:GetDebugName()) end

	local name = objectName.."Mover"
	local iL, iR, iT, iB = ...

	local mover = _G.CreateFrame("Button", name, _G.UIParent)
	mover:SetFrameLevel(object:GetFrameLevel() + 1)
	mover:SetWidth(object:GetWidth())
	mover:SetHeight(object:GetHeight())
	mover:SetClampedToScreen(true)
	mover:SetClampRectInsets(iL or -4, iR or 4, iT or 4, iB or -4)
	mover:SetMovable(true)
	mover:SetToplevel(true)
	mover:RegisterForDrag("LeftButton")
	mover.parent = object
	mover:SetScript("OnDragStart", Mover_OnDragStart)
	mover:SetScript("OnDragStop", Mover_OnDragStop)

	if isSimple then
		mover.isSimple = true
	else
		mover:SetScript("OnClick", Mover_OnClick)
		mover:SetScript("OnEnter", Mover_OnEnter)
		mover:SetScript("OnLeave", Mover_OnLeave)
		mover:Hide()

		local bg = mover:CreateTexture(nil, "BACKGROUND", nil, 0)
		bg:SetColorTexture(M.COLORS.BLUE:GetRGBA(0.6))
		bg:SetPoint("TOPLEFT", 1, -1)
		bg:SetPoint("BOTTOMRIGHT", -1, 1)
		mover.Bg = bg

		mover.buttons = {
			CreateMoverButton(mover, "UP"),
			CreateMoverButton(mover, "DOWN"),
			CreateMoverButton(mover, "LEFT"),
			CreateMoverButton(mover, "RIGHT"),
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

	SetPosition(mover)

	enabledMovers[name] = mover

	return mover
end

function P:CleanUpMoverConfig()
	C.db.profile.movers[E.UI_LAYOUT] = E:DiffTable(defaults, C.db.profile.movers[E.UI_LAYOUT])
end

function P:UpdateMoverConfig()
	E:UpdateTable(defaults, C.db.profile.movers[E.UI_LAYOUT])

	for _, mover in next, enabledMovers do
		local name = mover:GetName()
		local anchor = "UIParent"
		local p, rP, x, y

		if C.db.profile.movers[E.UI_LAYOUT][name].point then
			p, anchor, rP, x, y = unpack(C.db.profile.movers[E.UI_LAYOUT][name].point)
			anchor = anchor or "UIParent"
		end

		if not x then
			ResetPosition(mover)

			return
		end

		mover:ClearAllPoints()
		mover:SetPoint(p, anchor, rP, x, y)

		mover.parent:ClearAllPoints()
		mover.parent:SetPoint(p, anchor, rP, x, y)

		if mover.isSimple then
			mover:Show()
		else
			if E:IsEqualTable(defaults[name], C.db.profile.movers[E.UI_LAYOUT][name]) then
				mover.Bg:SetColorTexture(M.COLORS.BLUE:GetRGBA(0.6))
			else
				mover.Bg:SetColorTexture(M.COLORS.ORANGE:GetRGBA(0.6))
			end
		end
	end
end

local function HideMovers()
	for _, mover in next, enabledMovers do
		if not mover.isSimple then
			if mover:IsMouseEnabled() then
				Mover_OnDragStop(mover)
			end

			mover:Hide()
		end
	end
end

E:RegisterEvent("PLAYER_REGEN_DISABLED", HideMovers)

P:AddCommand("movers", function()
	E:ToggleAllMovers()
end)
