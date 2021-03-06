local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)
local unpack = _G.unpack

--[[ luacheck: globals
	CreateFrame Mixin UIParent
]]

-- Mine
local isInit = false
local holder

function UF:CreateBossHolder()
	holder = CreateFrame("Frame", "LSBossHolder", UIParent)
	holder:SetPoint(unpack(C.db.profile.units.boss.point[E.UI_LAYOUT]))
	E.Movers:Create(holder)
	holder._buttons = {}

	return holder
end

function UF:UpdateBossHolder()
	if not holder._config then
		holder._config = {
			num = 5,
		}
	end

	holder._config.width = C.db.profile.units.boss.width
	holder._config.height = C.db.profile.units.boss.height
	holder._config.per_row = C.db.profile.units.boss.per_row
	holder._config.spacing = C.db.profile.units.boss.spacing
	holder._config.x_growth = C.db.profile.units.boss.x_growth
	holder._config.y_growth = C.db.profile.units.boss.y_growth

	E:UpdateBarLayout(holder)
end

local boss_proto = {}

function boss_proto:Update()
	UF.medium_proto.Update(self)

	if self:IsEnabled() then
		self:UpdateAlternativePower()
	end
end

function UF:HasBossFrame()
	return isInit
end

function UF:CreateBossFrame(frame)
	Mixin(UF:CreateMediumUnitFrame(frame), boss_proto)

	local altPower = self:CreateAlternativePower(frame, frame.TextParent)
	altPower:SetFrameLevel(frame:GetFrameLevel() + 1)
	frame.AlternativePower = altPower

	frame.Insets.Top:Capture(altPower, 0, 0, 0, 2)

	isInit = true

	return frame
end
