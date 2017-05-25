local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)
local unpack = _G.unpack
local pairs = _G.pairs
local string = _G.string

-- Blizz
local GameTooltip = _G.GameTooltip

-- Mine
local movers = {}
local defaults = {}
local CFG

local function SavePosition(self, p, anchor, rP, x, y)
	CFG[self:GetName()].point = {p, anchor, rP, x, y}
end

local function ResetPosition(self)
	if not self.isSimple and _G.InCombatLockdown() then return end

	local p, anchor, rP, x, y = unpack(defaults[self:GetName()].point)

	self:ClearAllPoints()
	self:SetPoint(p, anchor, rP, x, y)

	self.parent:ClearAllPoints()
	self.parent:SetPoint(p, anchor, rP, x, y)

	CFG[self:GetName()].point = nil

	if not self.isSimple then
		self.Reset:Hide()
	end
end

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

local function SetPosition(self, xOffset, yOffset)
	if not self.isSimple and _G.InCombatLockdown() then return end

	local anchor = "UIParent"

	local p, rP, x, y = CalculatePosition(self)

	if not x then
		if CFG[self:GetName()].point then
			p, anchor, rP, x, y = unpack(CFG[self:GetName()].point)
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

	if not (self.isSimple or E:IsEqualTable(defaults[self:GetName()], CFG[self:GetName()])) then
		self.Reset:Show()
	end
end

local function Button_OnEnter(self)
	local mover = self:GetParent()

	GameTooltip:SetOwner(mover, _G.cursor, 0, 0)
	GameTooltip:AddLine(mover:GetName())

	if self == mover.Reset then
		GameTooltip:AddLine("Reset frame position", 1, 1, 1)
	else
		local p, anchor, rP, x, y = E:GetCoords(mover)

		if anchor == "UIParent" then
			p, rP, x, y = CalculatePosition(mover)
		end

		GameTooltip:AddLine("|cffffd100Point:|r "..p, 1, 1, 1)
		GameTooltip:AddLine("|cffffd100Attached to:|r "..rP.." |cffffd100of|r "..anchor, 1, 1, 1)
		GameTooltip:AddLine("|cffffd100X:|r "..x..", |cffffd100Y:|r "..y, 1, 1, 1)
	end

	GameTooltip:Show()
end

local function Frame_OnLeave()
	GameTooltip:Hide()
end

local function UpOnClick(self)
	local mover = self:GetParent()

	SetPosition(mover, 0, 1)

	if GameTooltip:IsOwned(mover) then
		Button_OnEnter(self)
	end
end

local function DownOnClick(self)
	local mover = self:GetParent()

	SetPosition(mover, 0, -1)

	if GameTooltip:IsOwned(mover) then
		Button_OnEnter(self)
	end
end

local function LeftOnClick(self)
	local mover = self:GetParent()

	SetPosition(mover, -1, 0)

	if GameTooltip:IsOwned(mover) then
		Button_OnEnter(self)
	end
end

local function RightOnClick(self)
	local mover = self:GetParent()

	SetPosition(mover, 1, 0)

	if GameTooltip:IsOwned(mover) then
		Button_OnEnter(self)
	end
end

local function ResetOnClick(self)
	if _G.InCombatLockdown() then return end

	ResetPosition(self:GetParent())
end

local MOVER_BUTTONS = {
	Up = {anchor = "TOP", func = UpOnClick},
	Down = {anchor = "BOTTOM", func = DownOnClick},
	Left = {anchor = "LEFT", func = LeftOnClick},
	Right = {anchor = "RIGHT", func = RightOnClick},
	Reset = {anchor = "TOPRIGHT", func = ResetOnClick}
}

local function CreateMoverButton(mover, type)
	local button = _G.CreateFrame("Button", nil, mover, "UIPanelSquareButton")
	button:SetPoint("CENTER", mover, MOVER_BUTTONS[type].anchor, 0, 0)
	button:SetSize(10, 10)
	button:Hide()
	button:SetScript("OnClick", MOVER_BUTTONS[type].func)
	button:SetScript("OnEnter", Button_OnEnter)
	button:SetScript("OnLeave", Frame_OnLeave)
	mover[type] = button

	_G.SquareButton_SetIcon(button, string.upper(type))

	E:SkinSquareButton(button)

	return button
end

local function Mover_OnEnter(self)
	local p, anchor, rP, x, y = E:GetCoords(self)

	if anchor == "UIParent" then
		p, rP, x, y = CalculatePosition(self)
	end

	GameTooltip:SetOwner(self, _G.cursor, 0, 0)
	GameTooltip:AddLine(self:GetName())
	GameTooltip:AddLine("|cffffd100Point:|r "..p, 1, 1, 1)
	GameTooltip:AddLine("|cffffd100Attached to:|r "..rP.." |cffffd100of|r "..anchor, 1, 1, 1)
	GameTooltip:AddLine("|cffffd100X:|r "..x..", |cffffd100Y:|r "..y, 1, 1, 1)
	GameTooltip:Show()
end

local function Mover_OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed

	if self.elapsed > 0.2 then
		if GameTooltip:IsOwned(self) then
			Mover_OnEnter(self)
		end

		self.elapsed = 0
	end
end

local function Mover_OnDragStart(self)
	if not self.isSimple and _G.InCombatLockdown() then return end

	self:StartMoving()

	if self.isSimple then
		self.parent:ClearAllPoints()
		self.parent:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)
	else
		self:SetScript("OnUpdate", Mover_OnUpdate)
	end
end

local function Mover_OnDragStop(self)
	if not self.isSimple and _G.InCombatLockdown() then return end

	self:StopMovingOrSizing()
	self:SetScript("OnUpdate", nil)

	SetPosition(self)

	self:SetUserPlaced(false)
end

local function Mover_OnClick(self)
	if self.buttons[1]:IsShown() then
		for i = 1, #self.buttons - 1 do
			self.buttons[i]:Hide()
		end
	else
		for i = 1, #self.buttons - 1 do
			self.buttons[i]:Show()
		end
	end
end

function E:ResetMovers()
	for _, mover in pairs(movers) do
		ResetPosition(mover)
	end
end

function E:ToggleAllMovers()
	if _G.InCombatLockdown() then return end

	for _, mover in pairs(movers) do
		if not mover.isSimple then
			if mover:IsShown() then
				mover:Hide()
			else
				mover:Show()
			end
		end
	end
end

function E:ToggleMover(object, state)
	local mover = movers[object:GetName().."Mover"]

	if mover then
		if _G.InCombatLockdown() and not mover.isSimple then
			return mover:IsShown()
		end

		if state ~= nil then
			mover:SetShown(state)

			return state
		else
			local isShown = mover:IsShown()

			mover:SetShown(not isShown)

			return not isShown
		end
	end
end

function E:UpdateMoverSize(object, width, height)
	local mover = movers[object:GetName().."Mover"]

	if mover then
		mover:SetWidth(width or object:GetWidth())
		mover:SetHeight(height or object:GetHeight())
	end
end

function E:GetMover(object)
	return movers[object:GetName().."Mover"]
end

function E:CreateMover(object, isSimple, insets)
	if not object then return end

	CFG = C.db.profile.movers[E.UI_LAYOUT]

	local name = object:GetName().."Mover"
	local iL, iR, iT, iB

	if insets then
		iL, iR, iT, iB = insets[1], insets[2], insets[3], insets[4]
	end

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
		mover:SetScript("OnLeave", Frame_OnLeave)
		mover:Hide()

		local bg = mover:CreateTexture(nil, "BACKGROUND", nil, 0)
		bg:SetColorTexture(M.COLORS.BLUE:GetRGBA(0.6))
		bg:SetPoint("TOPLEFT", 1, -1)
		bg:SetPoint("BOTTOMRIGHT", -1, 1)
		mover.Bg = bg

		mover.buttons = {
			CreateMoverButton(mover, "Up"),
			CreateMoverButton(mover, "Down"),
			CreateMoverButton(mover, "Left"),
			CreateMoverButton(mover, "Right"),
			CreateMoverButton(mover, "Reset")
		}
	end

	if not CFG[name] then
		CFG[name] = {}
	else
		if CFG[name].current then
			CFG[name].point = {unpack(CFG[name].current)}
			CFG[name].current = nil
		end
	end

	if not defaults[name] then
		defaults[name] = {}
	end

	defaults[name].point = {self:GetCoords(object)}

	self:UpdateTable(defaults[name], CFG[name])

	SetPosition(mover)

	movers[name] = mover

	return mover
end

function E:CleanUpMoversConfig()
	C.db.profile.movers[E.UI_LAYOUT] = self:DiffTable(defaults, CFG)
end

local function HideMovers()
	for _, mover in pairs(movers) do
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
