local _, ns = ...
local E, M = ns.E, ns.M

E.Movers = {}

local MOVERS_CONFIG

local DEFAULTS = {}

local function SavePosition(self, p, anchor, rP, x, y)
	MOVERS_CONFIG[self:GetName()].current = {p, anchor, rP, x, y}
end

local function ResetPosition(self)
	if InCombatLockdown() then return end

	local p, anchor, rP, x, y = unpack(DEFAULTS[self:GetName()])

	self:ClearAllPoints()
	self:SetPoint(p, anchor, rP, x, y)

	self.parent:ClearAllPoints()
	self.parent:SetPoint(p, anchor, rP, x, y)

	MOVERS_CONFIG[self:GetName()].current = nil

	self.buttons[5]:Hide()
end

local function SetPosition(self, xOffset, yOffset)
	if InCombatLockdown() then return end

	local p, anchor, rP, x, y = E:GetCoords(self)

	if not x then
		if MOVERS_CONFIG[self:GetName()].current then
			p, anchor, rP, x, y = unpack(MOVERS_CONFIG[self:GetName()].current)
		end

		if not x then ResetPosition(self) return end
	end

	self:ClearAllPoints()
	self:SetPoint(p, anchor, rP, x + (xOffset or 0), y + (yOffset or 0))

	self.parent:ClearAllPoints()
	self.parent:SetPoint(p, anchor, rP, x + (xOffset or 0), y + (yOffset or 0))

	SavePosition(self, p, anchor, rP, x, y)

	self.buttons[5]:Show()
end

local function Button_OnEnter(self)
	local mover = self:GetParent()

	GameTooltip:SetOwner(mover, cursor, 0, 0)
	GameTooltip:AddLine(mover:GetName())

	if self:GetName() == "lsMoverReset" then
		GameTooltip:AddLine("Restore frame position", 1, 1, 1)
	else
		local _, anchor, _, x, y = E:GetCoords(mover)

		GameTooltip:AddLine("|cffffd100Attached to:|r "..anchor, 1, 1, 1)
		GameTooltip:AddLine("|cffffd100X:|r "..x..", |cffffd100Y:|r "..y, 1, 1, 1)
	end

	GameTooltip:Show()
end

local function Frame_OnLeave(self)
	GameTooltip:Hide()
end

local function MoveUpOnClick(self)
	local mover = self:GetParent()

	SetPosition(mover, 0, 1)

	if GameTooltip:IsOwned(mover) then
		Button_OnEnter(self)
	end
end

local function MoveDownOnClick(self)
	local mover = self:GetParent()

	SetPosition(mover, 0, -1)

	if GameTooltip:IsOwned(mover) then
		Button_OnEnter(self)
	end
end

local function MoveLeftOnClick(self)
	local mover = self:GetParent()

	SetPosition(mover, -1, 0)

	if GameTooltip:IsOwned(mover) then
		Button_OnEnter(self)
	end
end

local function MoveRightOnClick(self)
	local mover = self:GetParent()

	SetPosition(mover, 1, 0)

	if GameTooltip:IsOwned(mover) then
		Button_OnEnter(self)
	end
end

local function ResetOnClick(self)
	if InCombatLockdown() then return end

	ResetPosition(self:GetParent())
end

local function CreateMoverButton(self, option)
	local anchor = option == "Up" and "TOP" or option == "Down" and "BOTTOM"
		or option == "Left" and "LEFT" or option == "Right" and "RIGHT"
		or option == "Reset" and "TOPRIGHT"

	local click = option == "Up" and MoveUpOnClick or option == "Down" and MoveDownOnClick
		or option == "Left" and MoveLeftOnClick or option == "Right" and MoveRightOnClick
		or option == "Reset" and ResetOnClick

	local button = CreateFrame("Button", "lsMover"..option, self, "UIPanelSquareButton")
	button:SetPoint("CENTER", self, anchor, 0, 0)
	button:SetSize(10, 10)
	button:Hide()

	button:SetScript("OnClick", click)
	button:SetScript("OnEnter", Button_OnEnter)
	button:SetScript("OnLeave", Frame_OnLeave)

	SquareButton_SetIcon(button, strupper(option))

	E:SkinSquareButton(button)

	return button
end

local function Mover_OnEnter(self)
	local _, anchor, _, x, y = E:GetCoords(self)

	GameTooltip:SetOwner(self, cursor, 0, 0)
	GameTooltip:AddLine(self:GetName())
	GameTooltip:AddLine("|cffffd100Attached to:|r "..anchor, 1, 1, 1)
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
	if InCombatLockdown() then return end

	self:StartMoving()
	self:SetScript("OnUpdate", Mover_OnUpdate)
end

local function Mover_OnDragStop(self)
	if InCombatLockdown() then return end

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
	for _, mover in next, E.Movers do
		ResetPosition(mover)
	end
end

function E:ToggleAllMovers()
	if InCombatLockdown() then return end

	for _, mover in next, E.Movers do
		if mover:IsShown() then
			mover:Hide()
		else
			mover:Show()
		end
	end
end

function E:ToggleMover(object)
	local mover = E.Movers[object:GetName().."Mover"]

	if InCombatLockdown() then
		if mover then
			return mover:IsShown()
		else
			return
		end
	end

	if mover then
		if mover:IsShown() then
			mover:Hide()

			return false
		else
			mover:Show()

			return true
		end
	end
end

function E:CreateMover(object)
	MOVERS_CONFIG = ns.C.movers

	local name = object:GetName().."Mover"

	local mover = CreateFrame("Button", name, UIParent)
	mover:SetFrameLevel(object:GetFrameLevel() + 4)
	mover:SetWidth(object:GetWidth())
	mover:SetHeight(object:GetHeight())
	mover:SetClampedToScreen(true)
	mover:RegisterForDrag("LeftButton")
	mover:SetMovable(true)
	mover:Hide()
	
	E:CreateBorder(mover, 5, -1)

	local bg = mover:CreateTexture(nil, "BACKGROUND", nil, 0)
	bg:SetTexture(0.41, 0.8, 0.94, 0.6)
	bg:SetPoint("TOPLEFT", 1, -1)
	bg:SetPoint("BOTTOMRIGHT", -1, 1)

	mover:SetScript("OnEnter", Mover_OnEnter)
	mover:SetScript("OnLeave", Frame_OnLeave)
	mover:SetScript("OnMouseDown", Frame_OnMouseDown)
	mover:SetScript("OnDragStart", Mover_OnDragStart)
	mover:SetScript("OnDragStop", Mover_OnDragStop)
	mover:SetScript("OnClick", Mover_OnClick)

	mover.parent = object

	local up = CreateMoverButton(mover, "Up")
	local down = CreateMoverButton(mover, "Down")
	local left = CreateMoverButton(mover, "Left")
	local right = CreateMoverButton(mover, "Right")
	local reset = CreateMoverButton(mover, "Reset")

	mover.buttons = {up, down, left, right, reset}

	if not MOVERS_CONFIG[name] then
		MOVERS_CONFIG[name] = {}
	end

	DEFAULTS[name] = {E:GetCoords(object)}

	SetPosition(mover)

	E.Movers[name] = mover
end

SLASH_LSMOVERS1 = "/lsmovers"
SlashCmdList["LSMOVERS"] = function()
	E:ToggleAllMovers()
end
