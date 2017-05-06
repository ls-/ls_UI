local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

-- Mine
function UF:ConstructTargetTargetFrame(frame)
	local level = frame:GetFrameLevel()

	frame._config = C.units.targettarget
	frame._mouseovers = {}

	local bg = frame:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture("Interface\\AddOns\\ls_UI\\media\\unit-frame-bg", true)
	bg:SetHorizTile(true)

	local fg_parent = _G.CreateFrame("Frame", nil, frame)
	fg_parent:SetFrameLevel(level + 7)
	fg_parent:SetAllPoints()
	frame.FGParent = fg_parent

	local text_parent = _G.CreateFrame("Frame", nil, frame)
	text_parent:SetFrameLevel(level + 9)
	text_parent:SetAllPoints()
	frame.TextParent = text_parent

	frame.Insets = UF:CreateInsets(frame, fg_parent, level)

	local health = UF:CreateHealth(frame)
	health:SetFrameLevel(level + 1)
	health:SetPoint("LEFT", frame, "LEFT", 0, 0)
	health:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
	health:SetPoint("TOP", frame.Insets.Top, "BOTTOM", 0, 0)
	health:SetPoint("BOTTOM", frame.Insets.Bottom, "TOP", 0, 0)
	health:SetClipsChildren(true)
	frame.Health = health

	frame.HealthPrediction = UF:CreateHealthPrediction(health)

	frame.RaidTargetIndicator = UF:CreateRaidTargetIndicator(text_parent)

	frame.Name = UF:CreateName(text_parent, "LS12Font_Shadow")

	E:CreateBorder(fg_parent, true)

	local glass = fg_parent:CreateTexture(nil, "OVERLAY")
	glass:SetAllPoints(health)
	glass:SetTexture("Interface\\AddOns\\ls_UI\\media\\unit-frame-glass", true)
	glass:SetHorizTile(true)
end

function UF:UpdateTargetTargetFrame(frame)
	local config = frame._config

	frame:SetSize(config.width, config.height)

	self:UpdateInsets(frame)
	self:UpdateHealth(frame)
	self:UpdateHealthPrediction(frame)
	self:UpdateName(frame)
	self:UpdateRaidTargetIndicator(frame)

	frame:UpdateAllElements("LSUI_ToTFrameUpdate")
end
