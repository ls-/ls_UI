local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local MODULE = P:AddModule("Auras")

-- Lua
local _G = getfenv(0)
local next = _G.next

-- Blizz
local CreateFrame = _G.CreateFrame
local GetInventoryItemTexture = _G.GetInventoryItemTexture
local GetTime = _G.GetTime
local GetWeaponEnchantInfo = _G.GetWeaponEnchantInfo
local RegisterAttributeDriver = _G.RegisterAttributeDriver
local TemporaryEnchantFrame = _G.TemporaryEnchantFrame
local UnitAura = _G.UnitAura

local DEBUFF_TYPE_COLORS = _G.DebuffTypeColor

-- Mine
local isInit = false
local buffs = {}
local debuffs = {}
local headers = {}

local function Button_OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	self.timeLeft = self.timeLeft - elapsed

	if self.elapsed >= 0.1 then
		if self.timeLeft >= 0.1 then
			local time, color = E:TimeFormat(self.timeLeft)
			self.Duration:SetFormattedText("|cff%s%s|r", color, time)
		else
			self.Duration:SetText("")
			self:SetScript("OnUpdate", nil)
		end

		self.elapsed = 0
	end
end

local function UpdateAura(button, index)
	local filter = button:GetParent():GetAttribute("filter")

	if filter == "HELPFUL" then
		if not buffs[button] then
			return
		end
	else
		if not debuffs[button] then
			return
		end
	end

	local unit = button:GetParent():GetAttribute("unit")
	local name, texture, count, debuffType, duration, expirationTime = UnitAura(unit, index, filter)

	if name then
		button.Icon:SetTexture(texture)
		button.Count:SetText(count > 1 and count)

		if duration > 0 and expirationTime then
			button.elapsed = 0.1
			button.timeLeft = expirationTime - GetTime()
			button:SetScript("OnUpdate", Button_OnUpdate)
		else
			button.elapsed = 0
			button.timeLeft = nil
			button:SetScript("OnUpdate", nil)

			button.Duration:SetText("")
		end

		if filter == "HARMFUL" then
			local color = DEBUFF_TYPE_COLORS[debuffType] or DEBUFF_TYPE_COLORS.none

			button.Border:SetVertexColor(color.r, color.g, color.b)
		else
			button.Border:SetVertexColor(1, 1, 1)
		end
	end
end

local function UpdateTempEnchant(button, index)
	if not buffs[button] then
		return
	end

	local hasEnchant, duration, count, _

	if index == 16 then
		hasEnchant, duration, count = GetWeaponEnchantInfo()
	else
		_, _, _, _, hasEnchant, duration, count = GetWeaponEnchantInfo()
	end

	if hasEnchant then
		button.Icon:SetTexture(GetInventoryItemTexture("player", index))
		button.Count:SetText(count > 1 and count)

		if duration > 0 then
			button.elapsed = 0.1
			button.timeLeft = duration / 1000
			button:SetScript("OnUpdate", Button_OnUpdate)
		else
			button.elapsed = 0
			button.timeLeft = nil
			button:SetScript("OnUpdate", nil)

			button.Duration:SetText("")
		end

		button.Border:SetVertexColor(M.COLORS.PURPLE:GetRGB())
	end
end

local function Button_OnAttributeChanged(self, attr, value)
	if attr == "index" then
		UpdateAura(self, value)
	elseif attr == "target-slot" then
		UpdateTempEnchant(self, value)
	end
end

local function Button_OnEnter(self)
	local quadrant = E:GetScreenQuadrant(self)
	local p, rP = "TOPRIGHT", "BOTTOMLEFT"

	if quadrant == "TOPLEFT" or quadrant == "LEFT" then
		p, rP = "TOPLEFT", "BOTTOMRIGHT"
	elseif quadrant == "BOTTOMRIGHT" or quadrant == "BOTTOM" then
		p, rP = "BOTTOMRIGHT", "TOPLEFT"
	elseif quadrant == "BOTTOMLEFT" then
		p, rP = "BOTTOMLEFT", "TOPRIGHT"
	end

	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint(p, self, rP, 0, 0)
	GameTooltip:SetFrameLevel(self:GetFrameLevel() + 2)

	if self:GetAttribute("index") then
		GameTooltip:SetUnitAura(self:GetParent():GetAttribute("unit"), self:GetID(), self:GetAttribute("filter"))
	elseif self:GetAttribute("totem-slot") then
		GameTooltip:SetTotem(self:GetID())
	else
		GameTooltip:SetInventoryItem("player", self:GetID())
	end
end

local function Button_OnLeave()
	GameTooltip:Hide()
end

local function HandleButton(button)
	button:HookScript("OnAttributeChanged", Button_OnAttributeChanged)
	button:SetScript("OnEnter", Button_OnEnter)
	button:SetScript("OnLeave", Button_OnLeave)
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp")

	button.Icon = E:SetIcon(button, [[Interface\ICONS\INV_Misc_QuestionMark]])

	local border = E:CreateBorder(button)
	border:SetTexture("Interface\\AddOns\\ls_UI\\assets\\border-thin")
	border:SetSize(16)
	border:SetOffset(-4)
	button.Border = border

	local duration = button:CreateFontString(nil, "ARTWORK", "LSFont12_Outline")
	duration:SetJustifyV("CENTER")
	duration:SetJustifyV("BOTTOM")
	duration:SetPoint("TOPLEFT", -4, 0)
	duration:SetPoint("BOTTOMRIGHT", 4, 0)
	button.Duration = duration

	local count = button:CreateFontString(nil, "ARTWORK", "LSFont10_Outline")
	count:SetJustifyH("RIGHT")
	count:SetPoint("TOPRIGHT", 2, 0)
	button.Count = count
end

local function Header_OnAttributeChanged(self, attr, value)
	-- Gotta catch 'em all!
	if (attr:match("^child") or attr:match("^temp[Ee]nchant")) and not (buffs[value] or debuffs[value])then
		HandleButton(value)

		if self:GetAttribute("filter") == "HELPFUL" then
			buffs[value] = true
		else
			debuffs[value] = true
		end
	end
end

local function UpdateHeader(filter)
	local header = headers[filter]

	if not header then
		return
	end

	if filter == "TOTEM" then
		header._config = C.db.profile.auras[E.UI_LAYOUT][filter]

		if not E.Movers:Get(header, true) then
			E.Movers:Create(header)
		end

		E:UpdateBarLayout(header)
	else
		local config = C.db.profile.auras[E.UI_LAYOUT][filter]
		local initialAnchor

		if config.y_growth == "UP" then
			if config.x_growth == "RIGHT" then
				initialAnchor = "BOTTOMLEFT"
			else
				initialAnchor = "BOTTOMRIGHT"
			end
		else
			if config.x_growth == "RIGHT" then
				initialAnchor = "TOPLEFT"
			else
				initialAnchor = "TOPRIGHT"
			end
		end

		for _, button in next, {header:GetChildren()} do
			button:SetSize(config.size, config.size)
		end

		header:Hide()
		header:SetAttribute("filter", filter)
		header:SetAttribute("initialConfigFunction", ([[
			self:SetAttribute("type2", "cancelaura")
			self:SetWidth(%1$d)
			self:SetHeight(%1$d)
		]]):format(config.size))
		header:SetAttribute("maxWraps", config.num_rows)
		header:SetAttribute("minHeight", config.num_rows * config.size + (config.num_rows - 1) * config.spacing)
		header:SetAttribute("minWidth", config.per_row * config.size + (config.per_row - 1) * config.spacing)
		header:SetAttribute("point", initialAnchor)
		header:SetAttribute("separateOwn", config.sep_own)
		header:SetAttribute("sortDirection", config.sort_dir)
		header:SetAttribute("sortMethod", config.sort_method)
		header:SetAttribute("wrapAfter", config.per_row)
		header:SetAttribute("wrapXOffset", 0)
		header:SetAttribute("wrapYOffset", (config.y_growth == "UP" and 1 or -1) * (config.size + config.spacing))
		header:SetAttribute("xOffset", (config.x_growth == "RIGHT" and 1 or -1) * (config.size + config.spacing))
		header:SetAttribute("yOffset", 0)
		header:Show()

		local mover = E.Movers:Get(header, true)
		if mover then
			mover:UpdateSize()
		else
			mover = E.Movers:Create(header)
			mover:SetClampRectInsets(-6, 6, 6, -6)
		end
	end
end

local function CreateHeader(filter)
	local point = C.db.profile.auras[E.UI_LAYOUT][filter].point
	local header

	if filter == "TOTEM" then
		header = CreateFrame("Frame", "LSTotemHeader", UIParent)
		header:SetPoint(point.p, point.anchor, point.rP, point.x, point.y)

		header._buttons = {}

		for i = 1, MAX_TOTEMS do
			local totem = _G["TotemFrameTotem"..i]
			local iconFrame, border = totem:GetChildren()
			local background = _G["TotemFrameTotem"..i.."Background"]
			local duration = _G["TotemFrameTotem"..i.."Duration"]
			local icon = _G["TotemFrameTotem"..i.."IconTexture"]
			local cd = _G["TotemFrameTotem"..i.."IconCooldown"]

			E:ForceHide(background)
			E:ForceHide(border)
			E:ForceHide(duration)
			E:ForceHide(iconFrame)

			totem:ClearAllPoints()
			totem:SetScript("OnEnter", Button_OnEnter)
			totem:SetAttribute("totem-slot", i)
			totem:SetID(i)
			totem._parent = header
			header._buttons[i] = totem

			icon:SetParent(totem)
			icon:SetMask(nil)

			totem.Icon = E:SetIcon(icon)

			border = E:CreateBorder(totem)
			border:SetTexture("Interface\\AddOns\\ls_UI\\assets\\border-thin")
			border:SetSize(16)
			border:SetOffset(-4)
			totem.Border = border

			cd:SetParent(totem)
			cd:SetReverse(false)
			cd:ClearAllPoints()
			cd:SetPoint("TOPLEFT", 1, -1)
			cd:SetPoint("BOTTOMRIGHT", -1, 1)

			totem.CD = E:HandleCooldown(cd, 12, nil, "BOTTOM")
		end
	else
		header = CreateFrame("Frame", filter == "HELPFUL" and "LSBuffHeader" or "LSDebuffHeader", UIParent, "SecureAuraHeaderTemplate")
		header:SetPoint(point.p, point.anchor, point.rP, point.x, point.y)
		header:HookScript("OnAttributeChanged", Header_OnAttributeChanged)
		header:SetAttribute("unit", "player")
		header:SetAttribute("template", "SecureActionButtonTemplate")

		if filter == "HELPFUL" then
			header:SetAttribute("includeWeapons", 1)
			header:SetAttribute("weaponTemplate", "SecureActionButtonTemplate")
		end

		RegisterAttributeDriver(header, "unit", "[vehicleui] vehicle; player")
	end

	headers[filter] = header

	UpdateHeader(filter)
end

function MODULE.IsInit()
	return isInit
end

function MODULE.Init()
	if not isInit and C.db.char.auras.enabled then
		CreateHeader("HELPFUL")
		CreateHeader("HARMFUL")
		CreateHeader("TOTEM")

		E:ForceHide(BuffFrame)
		E:ForceHide(TemporaryEnchantFrame)

		isInit = true
	end
end

function MODULE.Update()
	UpdateHeader("HELPFUL")
	UpdateHeader("HARMFUL")
	UpdateHeader("TOTEM")
end

function MODULE.UpdateHeader(_, ...)
	UpdateHeader(...)
end
