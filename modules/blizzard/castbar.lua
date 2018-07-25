local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Blizzard")

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local m_min = _G.math.min

--[[ luacheck: globals
	CastingBarFrame CastingBarFrame_OnEvent CreateFrame GetNetStats PetCastingBarFrame UIParent UnitIsPossessed
	CastingBarFrame_SetStartCastColor CastingBarFrame_SetStartChannelColor CastingBarFrame_SetFinishedCastColor
	CastingBarFrame_SetNonInterruptibleCastColor CastingBarFrame_SetFailedCastColor

	UIPARENT_MANAGED_FRAME_POSITIONS
]]

-- Mine
local isInit = false

local function bar_OnUpdate(self)
	if self.fadeOut or self.maxValue > 600 then
		self.Time:SetText(" ")
		return
	end

	self.Time:SetFormattedText("%.1f ", self.casting and (self.maxValue - self.value) or self.value)
end

local function playerBar_OnShow(self)
	local safeZone = self.SafeZone
	if safeZone then
		safeZone:ClearAllPoints()
		safeZone:SetPoint("TOP")
		safeZone:SetPoint("BOTTOM")

		if self.casting then
			safeZone:SetPoint(self:GetReverseFill() and "LEFT" or "RIGHT")
		else
			safeZone:SetPoint(self:GetReverseFill() and "RIGHT" or "LEFT")
		end

		local _, _, _, ms = GetNetStats()
		safeZone:SetWidth(self:GetWidth() * m_min(ms / 1e3 / self.maxValue, 1))
	end
end

local function petBar_OnEvent(self, event, ...)
	local arg1 = ...
	if event == "UNIT_PET" then
		if arg1 == "player" then
			local showPet = C.db.profile.blizzard.castbar.show_pet
			if showPet == 1 then
				self.showCastbar = true
			elseif showPet == 0 then
				self.showCastbar = false
			else
				self.showCastbar = UnitIsPossessed("pet")
			end

			if not self.showCastbar then
				self:Hide()
			elseif self.casting or self.channeling then
				self:Show()
			end
		end

		return
	end

	CastingBarFrame_OnEvent(self, event, ...)
end

local function bar_SetAttribute(self, attr, value)
	if attr == "ignoreFramePositionManager" and value then
		self.ignoreFramePositionManager = nil
		self:SetAttribute("ignoreFramePositionManager", false)
	end
end

local function bar_SetPoint(self, _, anchor)
	if anchor ~= self.Holder then
		local config = C.db.profile.blizzard.castbar

		self:SetSize(0, 0)
		self:ClearAllPoints()

		if config.icon.enabled then
			self.Icon:Show()

			if config.icon.position == "LEFT" then
				self:SetPoint("TOPLEFT", self.Holder, "TOPLEFT", 5 + config.height * 1.5, 0)
				self:SetPoint("BOTTOMRIGHT", self.Holder, "BOTTOMRIGHT", -3, 0)
			elseif config.icon.position == "RIGHT" then
				self:SetPoint("TOPLEFT", self.Holder, "TOPLEFT", 3, 0)
				self:SetPoint("BOTTOMRIGHT", self.Holder, "BOTTOMRIGHT", -5 - config.height * 1.5, 0)
			end
		else
			self.Icon:Hide()

			self:SetPoint("TOPLEFT", self.Holder, "TOPLEFT", 3, 0)
			self:SetPoint("BOTTOMRIGHT", self.Holder, "BOTTOMRIGHT", -3, 0)
		end
	end
end

local function handleCastBar(self)
	self.Border:SetTexture(nil)
	self.BorderShield:SetTexture(nil)
	self.Flash:SetTexture(nil)
	self.Spark:SetTexture(nil)

	self.Icon_ = self.Icon
	self.Icon_:Hide()

	local holder = CreateFrame("Frame", self:GetName() .. "Holder", UIParent)
	self.Holder = holder

	self:SetParent(holder)
	self:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
	self:SetFrameLevel(holder:GetFrameLevel())
	self:HookScript("OnUpdate", bar_OnUpdate)
	hooksecurefunc(self, "SetPoint", bar_SetPoint)
	hooksecurefunc(self, "SetAttribute", bar_SetAttribute)

	local bg = self:CreateTexture(nil, "BACKGROUND", nil, -7)
	bg:SetAllPoints(holder)
	bg:SetColorTexture(M.COLORS.DARK_GRAY:GetRGB())

	local icon = self:CreateTexture(nil, "BACKGROUND", nil, 0)
	icon:SetPoint("TOPLEFT", holder, "TOPLEFT", 3, 0)
	icon:SetTexCoord(8 / 64, 56 / 64, 9 / 64, 41 / 64)
	self.LeftIcon = icon

	local sep = self:CreateTexture(nil, "OVERLAY")
	sep:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-sep", "REPEAT", "REPEAT")
	sep:SetPoint("LEFT", icon, "RIGHT", -5, 0)
	self.LeftSep = sep

	icon = self:CreateTexture(nil, "BACKGROUND", nil, 0)
	icon:SetTexCoord(8 / 64, 56 / 64, 9 / 64, 41 / 64)
	icon:SetPoint("TOPRIGHT", holder, "TOPRIGHT", -3, 0)
	self.RightIcon = icon

	sep = self:CreateTexture(nil, "OVERLAY")
	sep:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-sep", "REPEAT", "REPEAT")
	sep:SetPoint("RIGHT", icon, "LEFT", 5, 0)
	self.RightSep = sep

	local safeZone = self:CreateTexture(nil, "ARTWORK", nil, 1)
	safeZone:SetTexture("Interface\\BUTTONS\\WHITE8X8")
	safeZone:SetVertexColor(M.COLORS.RED:GetRGBA(0.6))
	self.SafeZone_ = safeZone

	local texParent = CreateFrame("Frame", nil, self)
	texParent:SetPoint("TOPLEFT", holder, "TOPLEFT", 3, 0)
	texParent:SetPoint("BOTTOMRIGHT", holder, "BOTTOMRIGHT", -3, 0)
	self.TexParent = texParent

	local time = texParent:CreateFontString(nil, "ARTWORK", "LSFont12_Shadow")
	time:SetWordWrap(false)
	time:SetPoint("RIGHT", self, "RIGHT", 0, 0)
	self.Time = time

	local text = self.Text
	text:SetParent(texParent)
	text:SetWordWrap(false)
	text:SetJustifyH("LEFT")
	text:SetSize(0, 0)
	text:ClearAllPoints()
	text:SetPoint("LEFT", self, "LEFT", 2, 0)
	text:SetPoint("RIGHT", time, "LEFT", -2, 0)

	CastingBarFrame_SetStartCastColor(self, M.COLORS.YELLOW:GetRGB())
	CastingBarFrame_SetStartChannelColor(self, M.COLORS.YELLOW:GetRGB())
	CastingBarFrame_SetFinishedCastColor(self, M.COLORS.YELLOW:GetRGB())
	CastingBarFrame_SetNonInterruptibleCastColor(self, M.COLORS.GRAY:GetRGB())
	CastingBarFrame_SetFailedCastColor(self, M.COLORS.RED:GetRGB())
end

local function updateCastBar(self)
	local config = C.db.profile.blizzard.castbar
	local holder = self.Holder
	local height = config.height

	holder:SetSize(config.width, height)

	local mover = E.Movers:Get(holder, true)
	if mover then
		mover:UpdateSize()

		if not C.db.char.blizzard.castbar.enabled then
			mover:Disable()
		end
	end

	if config.icon.enabled then
		if config.icon.position == "LEFT" then
			self.Icon = self.LeftIcon
			self.Icon:Show()

			self.Icon_:Hide()
			self.LeftIcon:SetSize(height * 1.5, height)
			self.RightIcon:SetSize(0.0001, height)

			self.LeftSep:SetSize(12, height)
			self.LeftSep:SetTexCoord(1 / 32, 25 / 32, 0 / 8, height / 4)
			self.RightSep:SetSize(0.0001, height)

			self:SetSize(0, 0)
			self:ClearAllPoints()
			self:SetPoint("TOPLEFT", holder, "TOPLEFT", 5 + height * 1.5, 0)
			self:SetPoint("BOTTOMRIGHT", holder, "BOTTOMRIGHT", -3, 0)
		elseif config.icon.position == "RIGHT" then
			self.Icon = self.RightIcon
			self.Icon:Show()

			self.Icon_:Hide()
			self.LeftIcon:SetSize(0.0001, height)
			self.RightIcon:SetSize(height * 1.5, height)

			self.LeftSep:SetSize(0.0001, height)
			self.RightSep:SetSize(12, height)
			self.RightSep:SetTexCoord(1 / 32, 25 / 32, 0 / 8, height / 4)

			self:SetSize(0, 0)
			self:ClearAllPoints()
			self:SetPoint("TOPLEFT", holder, "TOPLEFT", 3, 0)
			self:SetPoint("BOTTOMRIGHT", holder, "BOTTOMRIGHT", -5 - height * 1.5, 0)
		end
	else
		self.Icon = self.Icon_
		self.Icon:Hide()

		self.LeftIcon:SetSize(0.0001, height)
		self.RightIcon:SetSize(0.0001, height)

		self.LeftSep:SetSize(0.0001, height)
		self.RightSep:SetSize(0.0001, height)

		self:SetSize(0, 0)
		self:ClearAllPoints()
		self:SetPoint("TOPLEFT", holder, "TOPLEFT", 3, 0)
		self:SetPoint("BOTTOMRIGHT", holder, "BOTTOMRIGHT", -3, 0)
	end

	if config.latency then
		self.SafeZone = self.SafeZone_
		self.SafeZone_:Show()
	else
		self.SafeZone = nil
		self.SafeZone_:Hide()
	end

	E:SetStatusBarSkin(self.TexParent, "HORIZONTAL-" .. height)

	self.Text:SetFontObject("LSFont" .. config.text.size .. config.text.flag)
	self.Time:SetFontObject("LSFont" .. config.text.size .. config.text.flag)
end

local function bar_SetLook(self)
	if self == CastingBarFrame or self == PetCastingBarFrame then
		self.Border:SetTexture(nil)
		self.BorderShield:SetTexture(nil)
		self.Flash:SetTexture(nil)
		self.Icon_:Hide()
		self.Spark:SetTexture(nil)

		local text = self.Text
		text:SetSize(0, 0)
		text:ClearAllPoints()
		text:SetPoint("LEFT", self, "LEFT", 2, 0)
		text:SetPoint("RIGHT", self.Time, "LEFT", -2, 0)
	end
end

local function bar_AttachDetach()
	updateCastBar(CastingBarFrame)
	updateCastBar(PetCastingBarFrame)
end

function MODULE:HasCastBars()
	return isInit
end

function MODULE:SetUpCastBars()
	if P:GetModule("UnitFrames"):HasPlayerFrame() then
		C.db.char.blizzard.castbar.enabled = false
	end

	if not isInit and C.db.char.blizzard.castbar.enabled then
		local config = C.db.profile.blizzard.castbar

		CastingBarFrame.ignoreFramePositionManager = true
		CastingBarFrame:SetAttribute("ignoreFramePositionManager", true)
		UIPARENT_MANAGED_FRAME_POSITIONS["CastingBarFrame"] = nil

		handleCastBar(CastingBarFrame)
		CastingBarFrame:SetScript("OnShow", playerBar_OnShow)

		CastingBarFrame.Holder:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 190)
		E.Movers:Create(CastingBarFrame.Holder)

		PetCastingBarFrame.ignoreFramePositionManager = true
		PetCastingBarFrame:SetAttribute("ignoreFramePositionManager", true)
		UIPARENT_MANAGED_FRAME_POSITIONS["PetCastingBarFrame"] = nil

		handleCastBar(PetCastingBarFrame)
		PetCastingBarFrame:SetScript("OnEvent", petBar_OnEvent)

		PetCastingBarFrame.Holder:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 190 + config.height + 8)
		E.Movers:Create(PetCastingBarFrame.Holder)

		hooksecurefunc("CastingBarFrame_SetLook", bar_SetLook)
		hooksecurefunc("PlayerFrame_AttachCastBar", bar_AttachDetach)
		hooksecurefunc("PlayerFrame_DetachCastBar", bar_AttachDetach)

		isInit = true

		self:UpdateCastBars()
	end
end

function MODULE:UpdateCastBars()
	if P:GetModule("UnitFrames"):HasPlayerFrame() then
		C.db.char.blizzard.castbar.enabled = false
	end

	if isInit then
		updateCastBar(CastingBarFrame)
		updateCastBar(PetCastingBarFrame)
	end
end
