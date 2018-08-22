local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Bars")

-- Lua
local _G = getfenv(0)

--[[ luacheck: globals
	CreateFrame ExtraActionBarFrame ExtraActionButton1 LibStub UIParent

	UIPARENT_MANAGED_FRAME_POSITIONS
]]

-- Mine
local LibKeyBound = LibStub("LibKeyBound-1.0-ls")
local isInit = false

local function button_UpdateHotKey(self, state)
	if state ~= nil then
		self._parent._config.hotkey.enabled = state
	end

	if self._parent._config.hotkey.enabled then
		self.HotKey:SetParent(self)
		self.HotKey:SetFormattedText("%s", self:GetHotkey())
		self.HotKey:Show()
	else
		self.HotKey:SetParent(E.HIDDEN_PARENT)
	end
end

local function button_UpdateHotKeyFont(self)
	local config = self._parent._config.hotkey
	self.HotKey:SetFontObject("LSFont" .. config.size .. config.flag)
	self.HotKey:SetWordWrap(false)
end

local function button_OnEnter(self)
	if LibKeyBound then
		LibKeyBound:Set(self)
	end
end

function MODULE.CreateExtraButton()
	if not isInit then
		local bar = CreateFrame("Frame", "LSExtraActionBar", UIParent, "SecureHandlerStateTemplate")
		bar._id = "extra"
		bar._buttons = {}

		MODULE:AddBar("extra", bar)

		bar.Update = function(self)
			self:UpdateConfig()
			self:UpdateVisibility()
			self:UpdateButtons("UpdateHotKey")
			self:UpdateButtons("UpdateHotKeyFont")
			self:UpdateCooldownConfig()
			self:UpdateFading()

			ExtraActionBarFrame:SetAllPoints()

			self:SetSize(self._config.size + 4, self._config.size + 4)
			E.Movers:Get(self):UpdateSize()
		end

		ExtraActionBarFrame.ignoreFramePositionManager = true
		UIPARENT_MANAGED_FRAME_POSITIONS["ExtraActionBarFrame"] = nil

		ExtraActionBarFrame:EnableMouse(false)
		ExtraActionBarFrame:SetParent(bar)
		ExtraActionBarFrame:SetAllPoints()

		ExtraActionButton1:SetPoint("TOPLEFT", 2, -2)
		ExtraActionButton1:SetPoint("BOTTOMRIGHT", -2, 2)
		ExtraActionButton1:HookScript("OnEnter", button_OnEnter)
		ExtraActionButton1._parent = bar
		ExtraActionButton1._command = "EXTRAACTIONBUTTON1"
		E:SkinExtraActionButton(ExtraActionButton1)
		bar._buttons[1] = ExtraActionButton1

		ExtraActionButton1.UpdateHotKey = button_UpdateHotKey
		ExtraActionButton1.UpdateHotKeyFont = button_UpdateHotKeyFont

		local point = C.db.profile.bars.extra.point
		bar:SetPoint(point.p, point.anchor, point.rP, point.x, point.y)
		E.Movers:Create(bar)

		bar:Update()

		isInit = true
	end
end
