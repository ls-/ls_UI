local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)
local next = _G.next
local t_insert = _G.table.insert
local t_remove = _G.table.remove
local t_wipe = _G.table.wipe

-- Mine
local element_proto = {}

function element_proto:UpdateConfig(k)
	local unit = self.__owner.__unit

	if k then
		if not C.db.profile.units[unit].custom_texts[k] then
			self._config[k] = nil
		else
			self._config[k] = t_wipe(self._config[k] or {})
			self._config[k] = E:CopyTable(C.db.profile.units[unit].custom_texts[k], self._config[k])
		end
	else
		self._config = t_wipe(self._config or {})
		self._config = E:CopyTable(C.db.profile.units[unit].custom_texts, self._config)
	end
end

function element_proto:UpdatePoint(k)
	local config = self._config[k]
	if not config or not config.enabled then
		self:Release(k)
	elseif config.enabled then
		local text = self.active[k] or self:Acquire(k)
		text:ClearAllPoints()
		text:SetPoint(
			config.point1.p,
			E:ResolveAnchorPoint(self.__owner, config.point1.anchor),
			config.point1.rP,
			config.point1.x,
			config.point1.y
		)
	end
end

function element_proto:UpdateFonts(k)
	local text = self.active[k]
	if text then
		local config = self._config[k]

		text:UpdateFont(config.size)
		text:SetJustifyH(config.h_alignment)
		text:SetJustifyV(config.v_alignment)
	end
end

function element_proto:UpdateTags(k)
	local text = self.active[k]
	if text then
		local config = self._config[k]

		if config.tag ~= "" then
			self.__owner:Tag(text, config.tag)
			text:UpdateTag()
		else
			self.__owner:Untag(text)
			text:SetText()
		end
	end
end

function element_proto:ForEach(method)
	for k in next, self._config do
		if self[method] then
			self[method](self, k)
		end
	end
end

function element_proto:Acquire(k)
	local text = t_remove(self.cache, 1)
	if not text then
		text = self.__parent:CreateFontString(nil, "ARTWORK")
		E.FontStrings:Capture(text, "unit")
		text:SetWordWrap(false)
	end

	self.active[k] = text

	return text
end

function element_proto:Release(k)
	local text = self.active[k]
	if text then
		self.__owner:Untag(text)
		text:ClearAllPoints()
		text:SetText()

		self.active[k] = nil

		t_insert(self.cache, text)
	end
end

local frame_proto = {}

function frame_proto:UpdateCustomTexts()
	local element = self.CustomTexts
	element:UpdateConfig()
	element:ForEach("UpdatePoint")
	element:ForEach("UpdateFonts")
	element:ForEach("UpdateTags")
end

function UF:CreateCustomTexts(frame, textParent)
	local element = {
		__owner =  frame,
		__parent = textParent or frame,
		active = {},
		cache = {},
	}

	for k, v in next, element_proto do
		element[k] = v
	end

	for k, v in next, frame_proto do
		frame[k] = v
	end

	return element
end
