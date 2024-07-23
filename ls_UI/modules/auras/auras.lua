local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF
local MODULE = P:AddModule("Auras")

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local next = _G.next
local type = _G.type
local unpack = _G.unpack

-- Mine
local isInit = false
local buffs = {}
local debuffs = {}
local headers = {}

local function updateAura(button, index)
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
	local data = C_UnitAuras.GetAuraDataByIndex(unit, index, filter)
	if data then
		button.Icon:SetTexture(data.icon)
		button.Count:SetText(data.applications > 1 and data.applications or "")

		if data.duration and data.duration > 0 and data.expirationTime then
			button.Cooldown:SetCooldown(data.expirationTime - data.duration, data.duration)
			button.Cooldown:Show()
		else
			button.Cooldown:Hide()
		end

		if filter == "HARMFUL" then
			button.Border:SetVertexColor((C.db.global.colors.debuff[data.dispelName] or C.db.global.colors.debuff.None):GetRGB())

			if data.dispelName and button.showDebuffType then
				button.AuraType:SetTexCoord(unpack(M.textures.aura_icons[data.dispelName] or M.textures.aura_icons.Debuff))
				button.AuraType:Show()
			else
				button.AuraType:Hide()
			end
		else
			button.Border:SetVertexColor(1, 1, 1)
			button.AuraType:Hide()
		end
	end
end

local function updateTempEnchant(button, index)
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
		button.Count:SetText(count > 1 and count or "")

		if duration and duration > 0 then
			duration = duration / 1000
			button.Cooldown:SetCooldown(GetTime(), duration)
			button.Cooldown:Show()
		else
			button.Cooldown:Hide()
		end

		button.Border:SetVertexColor(C.db.global.colors.buff.Enchant:GetRGB())
	end
end

local button_proto = {}

do
	function button_proto:OnAttributeChanged(attr, value)
		if attr == "index" then
			updateAura(self, value)
		elseif attr == "target-slot" then
			updateTempEnchant(self, value)
		end
	end

	function button_proto:OnEnter()
		local p, rP, x, y = E:GetTooltipPoint(self)

		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:SetPoint(p, self, rP, x, y)
		GameTooltip:SetFrameLevel(self:GetFrameLevel() + 2)

		if self:GetAttribute("index") then
			GameTooltip:SetUnitAura(self:GetParent():GetAttribute("unit"), self:GetID(), self:GetAttribute("filter"))
		else
			GameTooltip:SetInventoryItem("player", self:GetID())
		end
	end

	function button_proto:OnLeave()
		GameTooltip:Hide()
	end

	function button_proto:OnSizeChanged(width, height)
		local icon = self.icon or self.Icon
		if icon then
			if width > height then
				local offset = 0.875 * (1 - height / width) / 2
				icon:SetTexCoord(0.0625, 0.9375, 0.0625 + offset, 0.9375 - offset)
			elseif width < height then
				local offset = 0.875 * (1 - width / height) / 2
				icon:SetTexCoord(0.0625 + offset, 0.9375 - offset, 0.0625, 0.9375)
			else
				icon:SetTexCoord(0.0625, 0.9375, 0.0625, 0.9375)
			end
		end
	end

	function button_proto:UpdateAuraTypeIcon()
		local config = self._parent._config.type

		self.AuraType:ClearAllPoints()
		self.AuraType:SetPoint(config.position, 0, 0)
		self.AuraType:SetSize(config.size, config.size)

		self.showDebuffType = self._parent._config.type.enabled
	end

	function button_proto:UpdateCountFont()
		local config = self._parent._config.count

		self.Count:UpdateFont(config.size)
		self.Count:SetJustifyH(config.h_alignment)
		self.Count:SetJustifyV(config.v_alignment)
	end
end

local function handleButton(button, header)
	Mixin(button, button_proto)
	button:HookScript("OnAttributeChanged", button.OnAttributeChanged)
	button:SetScript("OnEnter", button.OnEnter)
	button:SetScript("OnLeave", button.OnLeave)
	button:SetScript("OnSizeChanged", button.OnSizeChanged)
	button:RegisterForClicks("RightButtonDown", "RightButtonUp")

	button.Icon = E:SetIcon(button, QUESTION_MARK_ICON)

	local border = E:CreateBorder(button)
	border:SetTexture("Interface\\AddOns\\ls_UI\\assets\\border-thin")
	border:SetSize(16)
	border:SetOffset(-4)
	button.Border = border

	button.Cooldown = E.Cooldowns.Create(button)

	if button.Cooldown.UpdateConfig then
		button.Cooldown:UpdateConfig(header.cooldownConfig or {})
		button.Cooldown:UpdateFont()
		button.Cooldown:UpdateSwipe()
	end

	local textParent = CreateFrame("Frame", nil, button)
	textParent:SetFrameLevel(button:GetFrameLevel() + 2)
	textParent:SetAllPoints()
	button.TextParent = textParent

	local auraType = textParent:CreateTexture(nil, "ARTWORK", nil, 3)
	auraType:SetTexture("Interface\\AddOns\\ls_UI\\assets\\unit-frame-aura-icons")
	auraType:Hide()
	button.AuraType = auraType

	local count = textParent:CreateFontString(nil, "ARTWORK")
	E.FontStrings:Capture(count, "button")
	count:SetWordWrap(false)
	count:SetAllPoints()
	button.Count = count

	button._parent = header

	button:UpdateAuraTypeIcon()
	button:UpdateCountFont()
end

local header_proto = {}

do
	function header_proto:OnAttributeChanged(attr, value)
		-- Gotta catch 'em all!
		if attr:match("^frameref%-child") or attr:match("^temp[Ee]nchant") then
			if type(value) == "userdata" then
				value = GetFrameHandleFrame(value)
			end

			if not (buffs[value] or debuffs[value]) then
				handleButton(value, self)

				if self:GetAttribute("filter") == "HELPFUL" then
					buffs[value] = true
				else
					debuffs[value] = true
				end
			end
		end
	end

	function header_proto:Update()
		self:UpdateConfig()

		local config = self._config
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

		self:Hide()
		self:ForEach("Hide")
		self:ForEach("UpdateAuraTypeIcon")
		self:ForEach("UpdateCountFont")
		self:ForEach("SetSize", config.width, config.height)
		self:UpdateCooldownConfig()
		self:SetAttribute("filter", self._filter)
		self:SetAttribute("initialConfigFunction", ([[
			self:SetAttribute("type2", "cancelaura")
			self:SetWidth(%d)
			self:SetHeight(%d)
		]]):format(config.width, config.height))
		self:SetAttribute("maxWraps", config.num_rows)
		self:SetAttribute("minHeight", config.num_rows * config.width + (config.num_rows - 1) * config.spacing)
		self:SetAttribute("minWidth", config.per_row * config.height + (config.per_row - 1) * config.spacing)
		self:SetAttribute("point", initialAnchor)
		self:SetAttribute("separateOwn", config.sep_own)
		self:SetAttribute("sortDirection", config.sort_dir)
		self:SetAttribute("sortMethod", config.sort_method)
		self:SetAttribute("wrapAfter", config.per_row)
		self:SetAttribute("wrapXOffset", 0)
		self:SetAttribute("wrapYOffset", (config.y_growth == "UP" and 1 or -1) * (config.height + config.spacing))
		self:SetAttribute("xOffset", (config.x_growth == "RIGHT" and 1 or -1) * (config.width + config.spacing))
		self:SetAttribute("yOffset", 0)
		self:Show()

		local mover = E.Movers:Get(self, true)
		if mover then
			mover:UpdateSize()
		else
			E.Movers:Create(self, false, 2, 2)
		end
	end

	function header_proto:ForEach(method, ...)
		local buttons = self._buttons or {self:GetChildren()}
		for _, button in next, buttons do
			if button[method] then
				button[method](button, ...)
			end
		end
	end

	function header_proto:UpdateConfig()
		self._config = E:CopyTable(C.db.profile.auras[self._filter], self._config)
		self._config.height = self._config.height ~= 0 and self._config.height or self._config.width
		self._config.cooldown = E:CopyTable(C.db.profile.auras.cooldown, self._config.cooldown)
	end

	function header_proto:UpdateCooldownConfig()
		if not self.cooldownConfig then
			self.cooldownConfig = {
				swipe = {},
				text = {},
			}
		end

		self.cooldownConfig = E:CopyTable(self._config.cooldown, self.cooldownConfig)

		local buttons = self._buttons or {self:GetChildren()}
		for _, button in next, buttons do
			if not button.Cooldown.UpdateConfig then
				break
			end

			button.Cooldown:UpdateConfig(self.cooldownConfig)
			button.Cooldown:UpdateFont()
			button.Cooldown:UpdateSwipe()
		end
	end
end

local totem_header_proto = {}

do
	function totem_header_proto:Update()
		self:UpdateConfig()

		if not E.Movers:Get(self, true) then
			E.Movers:Create(self)
		end

		self:UpdateCooldownConfig()
		E.Layout:Update(self)
	end
end

local function createHeader(filter)
	local header
	if filter == "TOTEM" then
		header = Mixin(CreateFrame("Frame", "LSTotemHeader", UIParent), header_proto, totem_header_proto)
		header:SetPoint(unpack(C.db.profile.auras[filter].point))
		header._buttons = {}

		for i = 1, MAX_TOTEMS do
			local button = Mixin(E:CreateButton(header, "$parentButton" .. i, false, true), button_proto)
			button:SetPushedTexture(0)
			button:SetHighlightTexture(0)
			button:Hide()
			button._parent = header
			header._buttons[i] = button
		end

		hooksecurefunc(TotemFrame, "Update", function()
			local activeTotems = 0

			for i = 1, MAX_TOTEMS do
				local hasTotem, _, startTime, duration, icon = GetTotemInfo(i)
				if hasTotem then
					activeTotems = activeTotems + 1

					local button = header._buttons[activeTotems]
					button.Icon:SetTexture(icon)
					button.slot = i
					button:Show()

					if duration and duration > 0 and startTime then
						button.Cooldown:SetCooldown(startTime, duration)
						button.Cooldown:Show()
					else
						button.Cooldown:Hide()
					end

					-- strangely enough, these buttons aren't protected which means I can use them to handle totem destruction
					for totem in TotemFrame.totemPool:EnumerateActive() do
						if totem.slot == i then
							totem:ClearAllPoints()
							totem:SetParent(button)
							totem:SetAllPoints(button)
							totem:SetAlpha(0)
							totem:SetFrameLevel(button:GetFrameLevel() + 1)
						end
					end
				end
			end

			for i = activeTotems + 1, MAX_TOTEMS do
				header._buttons[i]:Hide()
			end
		end)
	else
		header = Mixin(CreateFrame("Frame", filter == "HELPFUL" and "LSBuffHeader" or "LSDebuffHeader", UIParent, "SecureAuraHeaderTemplate"), header_proto)
		header:SetPoint(unpack(C.db.profile.auras[filter].point))
		header:HookScript("OnAttributeChanged", header.OnAttributeChanged)
		header:SetAttribute("unit", "player")
		header:SetAttribute("template", "SecureActionButtonTemplate")

		-- this prevents SecureAuraHeader_Update spam
		header.vis = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
		SecureHandlerSetFrameRef(header.vis, "AuraHeader", header)
		RegisterStateDriver(header.vis, "vis", "[petbattle] hide; show")
		header.vis:SetAttribute("_onstate-vis", [[
			local header = self:GetFrameRef("AuraHeader")
			local isShown = header:IsShown()
			if isShown and newstate == "hide" then
				header:Hide()
			elseif not isShown and newstate == "show" then
				header:Show()
			end
		]])

		if filter == "HELPFUL" then
			header:SetAttribute("includeWeapons", 1)
			header:SetAttribute("weaponTemplate", "SecureActionButtonTemplate")
		end

		RegisterAttributeDriver(header, "unit", "[vehicleui] vehicle; player")
	end

	header._filter = filter
	headers[filter] = header

	header:Update()
end

function MODULE:IsInit()
	return isInit
end

function MODULE:Init()
	if not isInit and PrC.db.profile.auras.enabled then
		createHeader("HELPFUL")
		createHeader("HARMFUL")
		createHeader("TOTEM")

		-- do it on PEW because numHideableBuffs will be nil otherwise
		E:RegisterEvent("PLAYER_ENTERING_WORLD", function(isLogin, isReload)
			if isLogin or isReload then
				E:ForceHide(BuffFrame)
				E:ForceHide(DebuffFrame)
				E:ForceHide(DeadlyDebuffFrame)
			end
		end)

		isInit = true

		MODULE:ForEach("Update")
	end
end

function MODULE:Update()
	self:ForEach("Update")
end

function MODULE:ForEach(method, ...)
	for _, header in next, headers do
		if header[method] then
			header[method](header, ...)
		end
	end
end

function MODULE:For(header, method, ...)
	if headers[header] and headers[header][method] then
		headers[header][method](headers[header], ...)
	end
end
