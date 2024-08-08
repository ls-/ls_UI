local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF
local MODULE = P:GetModule("Bars")

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local unpack = _G.unpack

-- Mine
local LibKeyBound = LibStub("LibKeyBound-1.0")

local isInit = false

local button_proto = {}

function button_proto:UpdateHotKey(state)
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

function button_proto:UpdateHotKeyFont()
	self.HotKey:UpdateFont(self._parent._config.hotkey.size)
end

function button_proto:OnEnterHook()
	if LibKeyBound then
		LibKeyBound:Set(self)
	end
end

local bar_proto = {}

function bar_proto:Update()
	self:UpdateConfig()
	self:UpdateVisibility()
	self:ForEach("UpdateHotKey")
	self:ForEach("UpdateHotKeyFont")
	self:UpdateArtwork()
	self:UpdateCooldownConfig()
	self:UpdateFading()

	ExtraActionBarFrame:ClearAllPoints()
	ExtraActionBarFrame:SetPoint("TOPLEFT", self, "TOPLEFT", 2, -2)
	ExtraActionBarFrame:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, 2)

	local width, height = ExtraActionButton1:GetSize()
	self:SetSize((width > 0 and width or 52) + 4, (height > 0 and height or 52) + 4)
	self:SetScale(self._config.scale)

	local mover = E.Movers:Get(self)
	if mover then
		mover:UpdateSize()
	end

	self:ForEach("HandleMasque")
end

function button_proto:HandleMasque()
	if _G.Masque and PrC.db.profile.bars.masque then
		_G.LSUIHandleMasque(self, "extraActionButton")
	end
end

function bar_proto:UpdateArtwork()
	if self._config.artwork then
		ExtraActionButton1.style:Show()
		ExtraActionButton1.style:SetParent(ExtraActionButton1)
	else
		ExtraActionButton1.style:Hide()
		ExtraActionButton1.style:SetParent(E.HIDDEN_PARENT)
	end
end

function MODULE:CreateExtraButton()
	if not isInit then
		local bar = Mixin(self:Create("extra", "LSExtraActionBar"), bar_proto)

		ExtraActionBarFrame.ignoreFramePositionManager = true
		ExtraActionBarFrame:EnableMouse(false)
		ExtraActionBarFrame:SetParent(bar)
		ExtraActionBarFrame.ignoreInLayout = true

		hooksecurefunc(ExtraActionBarFrame, "SetParent", function(self, parent)
			if parent ~= bar then
				self:SetParent(bar)
			end
		end)

		-- ExtraAbilityContainer.ignoreFramePositionManager = true
		-- ExtraAbilityContainer:SetScript("OnShow", nil)
		-- ExtraAbilityContainer:SetScript("OnHide", nil)
		-- ExtraAbilityContainer.SetSize = E.NOOP

		Mixin(ExtraActionButton1, button_proto)

		ExtraActionButton1:HookScript("OnEnter", ExtraActionButton1.OnEnterHook)
		ExtraActionButton1._parent = bar
		ExtraActionButton1._command = "EXTRAACTIONBUTTON1"
		E:SkinExtraActionButton(ExtraActionButton1)
		bar._buttons[1] = ExtraActionButton1

		bar:SetPoint(unpack(C.db.profile.bars.extra.point))
		E.Movers:Create(bar)

		bar:Update()

		isInit = true
	end
end
