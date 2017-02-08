local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = _G
local table = _G.table
local unpack = _G.unpack

-- Mine
local CLASS_POWER_LAYOUT = {
	[1] = {
		[1] = {
			size = 128,
			point = {"BOTTOM", 0, 0},
			glow = {190 / 512, 206 / 512, 1 / 256, 129 / 256},
		},
	},
	[2] = {
		[1] = {
			size = 64,
			point = {"BOTTOM", 0, 0},
			glow = {207 / 512, 223 / 512, 65 / 256, 129 / 256},
		},
		[2] = {
			size = 64,
			point = {"BOTTOM", 0, 64},
			glow = {207 / 512, 223 / 512, 1 / 256, 65 / 256},
		},
	},
	[3] = {
		[1] = {
			size = 42,
			point = {"BOTTOM", 0, 0},
			glow = {224 / 512, 240 / 512, 87 / 256, 129 / 256},
		},
		[2] = {
			size = 44,
			point = {"BOTTOM", 0, 42},
			glow = {224 / 512, 240 / 512, 43 / 256, 87 / 256},
		},
		[3] = {
			size = 42,
			point = {"BOTTOM", 0, 86},
			glow = {224 / 512, 240 / 512, 1 / 256, 43 / 256},
		},
	},
	[4] = {
		[1] = {
			size = 32,
			point = {"BOTTOM", 0, 0},
			glow = {241 / 512, 257 / 512, 97 / 256, 129 / 256},
		},
		[2] = {
			size = 32,
			point = {"BOTTOM", 0, 32},
			glow = {241 / 512, 257 / 512, 65 / 256, 97 / 256},
		},
		[3] = {
			size = 32,
			point = {"BOTTOM", 0, 64},
			glow = {241 / 512, 257 / 512, 33 / 256, 65 / 256},
		},
		[4] = {
			size = 32,
			point = {"BOTTOM", 0, 96},
			glow = {241 / 512, 257 / 512, 1 / 256, 33 / 256},
		},
	},
	[5] = {
		[1] = {
			size = 25,
			point = {"BOTTOM", 0, 0},
			glow = {258 / 512, 274 / 512, 104 / 256, 129 / 256},
		},
		[2] = {
			size = 25,
			point = {"BOTTOM", 0, 25},
			glow = {258 / 512, 274 / 512, 79 / 256, 104 / 256},
		},
		[3] = {
			size = 28,
			point = {"BOTTOM", 0, 50},
			glow = {258 / 512, 274 / 512, 51 / 256, 79 / 256},
		},
		[4] = {
			size = 25,
			point = {"BOTTOM", 0, 78},
			glow = {258 / 512, 274 / 512, 26 / 256, 51 / 256},
		},
		[5] = {
			size = 25,
			point = {"BOTTOM", 0, 103},
			glow = {258 / 512, 274 / 512, 1 / 256, 26 / 256},
		},
	},
	[6] = {
		[1] = {
			size = 21,
			point = {"BOTTOM", 0, 0},
			glow = {275 / 512, 291 / 512, 108 / 256, 129 / 256},
		},
		[2] = {
			size = 21,
			point = {"BOTTOM", 0, 21},
			glow = {275 / 512, 291 / 512, 87 / 256, 108 / 256},
		},
		[3] = {
			size = 22,
			point = {"BOTTOM", 0, 42},
			glow = {275 / 512, 291 / 512, 65 / 256, 87 / 256},
		},
		[4] = {
			size = 22,
			point = {"BOTTOM", 0, 64},
			glow = {275 / 512, 291 / 512, 43 / 256, 65 / 256},
		},
		[5] = {
			size = 21,
			point = {"BOTTOM", 0, 86},
			glow = {275 / 512, 291 / 512, 22 / 256, 43 / 256},
		},
		[6] = {
			size = 21,
			point = {"BOTTOM", 0, 107},
			glow = {275 / 512, 291 / 512, 1 / 256, 22 / 256},
		},
	},
	[7] = {
		[1] = {
			size = 18,
			point = {"BOTTOM", 0, 0},
			glow = {292 / 512, 308 / 512, 111 / 256, 129 / 256}
		},
		[2] = {
			size = 18,
			point = {"BOTTOM", 0, 18},
			glow = {292 / 512, 308 / 512, 93 / 256, 111 / 256}
		},
		[3] = {
			size = 18,
			point = {"BOTTOM", 0, 36},
			glow = {292 / 512, 308 / 512, 75 / 256, 93 / 256}
		},
		[4] = {
			size = 20,
			point = {"BOTTOM", 0, 54},
			glow = {292 / 512, 308 / 512, 55 / 256, 75 / 256}
		},
		[5] = {
			size = 18,
			point = {"BOTTOM", 0, 74},
			glow = {292 / 512, 308 / 512, 37 / 256, 55 / 256}
		},
		[6] = {
			size = 18,
			point = {"BOTTOM", 0, 92},
			glow = {292 / 512, 308 / 512, 19 / 256, 37 / 256}
		},
		[7] = {
			size = 18,
			point = {"BOTTOM", 0, 110},
			glow = {292 / 512, 308 / 512, 1 / 256, 19 / 256}
		},
	},
	[8] = {
		[1] = {
			size = 16,
			point = {"BOTTOM", 0, 0},
			glow = {309 / 512, 325 / 512, 113 / 256, 129 / 256}
		},
		[2] = {
			size = 16,
			point = {"BOTTOM", 0, 16},
			glow = {309 / 512, 325 / 512, 97 / 256, 113 / 256}
		},
		[3] = {
			size = 16,
			point = {"BOTTOM", 0, 32},
			glow = {309 / 512, 325 / 512, 81 / 256, 97 / 256}
		},
		[4] = {
			size = 16,
			point = {"BOTTOM", 0, 48},
			glow = {309 / 512, 325 / 512, 65 / 256, 81 / 256}
		},
		[5] = {
			size = 16,
			point = {"BOTTOM", 0, 64},
			glow = {309 / 512, 325 / 512, 49 / 256, 65 / 256}
		},
		[6] = {
			size = 16,
			point = {"BOTTOM", 0, 80},
			glow = {309 / 512, 325 / 512, 33 / 256, 49 / 256}
		},
		[7] = {
			size = 16,
			point = {"BOTTOM", 0, 96},
			glow = {309 / 512, 325 / 512, 17 / 256, 33 / 256}
		},
		[8] = {
			size = 16,
			point = {"BOTTOM", 0, 112},
			glow = {309 / 512, 325 / 512, 1 / 256, 17 / 256}
		},
	},
	[9] = {
		[1] = {
			size = 14,
			point = {"BOTTOM", 0, 0},
			glow = {326 / 512, 342 / 512, 115 / 256, 129 / 256}
		},
		[2] = {
			size = 14,
			point = {"BOTTOM", 0, 14},
			glow = {326 / 512, 342 / 512, 101 / 256, 115 / 256}
		},
		[3] = {
			size = 14,
			point = {"BOTTOM", 0, 28},
			glow = {326 / 512, 342 / 512, 101 / 256, 115 / 256}
		},
		[4] = {
			size = 14,
			point = {"BOTTOM", 0, 42},
			glow = {326 / 512, 342 / 512, 73 / 256, 87 / 256}
		},
		[5] = {
			size = 16,
			point = {"BOTTOM", 0, 56},
			glow = {326 / 512, 342 / 512, 57 / 256, 73 / 256}
		},
		[6] = {
			size = 14,
			point = {"BOTTOM", 0, 72},
			glow = {326 / 512, 342 / 512, 43 / 256, 57 / 256}
		},
		[7] = {
			size = 14,
			point = {"BOTTOM", 0, 86},
			glow = {326 / 512, 342 / 512, 29 / 256, 43 / 256}
		},
		[8] = {
			size = 14,
			point = {"BOTTOM", 0, 100},
			glow = {326 / 512, 342 / 512, 15 / 256, 29 / 256}
		},
		[9] = {
			size = 14,
			point = {"BOTTOM", 0, 114},
			glow = {326 / 512, 342 / 512, 1 / 256, 15 / 256}
		},
	},
	[10] = {
		[1] = {
			size = 13,
			point = {"BOTTOM", 0, 0},
			glow = {364 / 512, 380 / 512, 116 / 256, 129 / 256}
		},
		[2] = {
			size = 13,
			point = {"BOTTOM", 0, 13},
			glow = {364 / 512, 380 / 512, 103 / 256, 116 / 256}
		},
		[3] = {
			size = 13,
			point = {"BOTTOM", 0, 26},
			glow = {364 / 512, 380 / 512, 90 / 256, 103 / 256}
		},
		[4] = {
			size = 13,
			point = {"BOTTOM", 0, 39},
			glow = {364 / 512, 380 / 512, 77 / 256, 90 / 256}
		},
		[5] = {
			size = 12,
			point = {"BOTTOM", 0, 52},
			glow = {364 / 512, 380 / 512, 65 / 256, 77 / 256}
		},
		[6] = {
			size = 12,
			point = {"BOTTOM", 0, 64},
			glow = {364 / 512, 380 / 512, 53 / 256, 65 / 256}
		},
		[7] = {
			size = 13,
			point = {"BOTTOM", 0, 76},
			glow = {364 / 512, 380 / 512, 40 / 256, 53 / 256}
		},
		[8] = {
			size = 13,
			point = {"BOTTOM", 0, 89},
			glow = {364 / 512, 380 / 512, 27 / 256, 40 / 256}
		},
		[9] = {
			size = 13,
			point = {"BOTTOM", 0, 102},
			glow = {364 / 512, 380 / 512, 14 / 256, 27 / 256}
		},
		[10] = {
			size = 13,
			point = {"BOTTOM", 0, 115},
			glow = {364 / 512, 380 / 512, 1 / 256, 14 / 256}
		},
	},
}

local TOTEM_LAYOUT = {
	[1] = {"TOP", -43, 20},
	[2] = {"TOP", -15, 30},
	[3] = {"TOP", 15, 30},
	[4] = {"TOP", 43, 20},
}

function UF:ConstructPlayerFrame(frame)
	local level = frame:GetFrameLevel()

	frame.mouseovers = {}
	frame:SetSize(332 / 2, 332 / 2)

	-- Note: can't touch this
	-- 1: frame
		-- 2: health_bar_parent
			-- 2: frame.Health
				-- 3: frame.HealPrediction
		-- 2: frame.AdditionalPower
			-- 3: frame.PowerPrediction.altBar
		-- 2: indicator_parent
			-- 3: frame.LeftIndicator, frame.RightIndicator
		-- 4: border_parent
		-- 5: frame.Power
			-- 6: frame.PowerPrediction.mainBar
		-- 5: frame.Stagger, frame.Runes, frame.ClassIcons
		-- 7: class_power_tube, power_tube
		-- 8: fg_parent
		-- 9: text_parent
		-- 10: fcf

	-- bg
	local texture = frame:CreateTexture(nil, "BACKGROUND", nil, -7)
	texture:SetAllPoints()
	texture:SetTexture("Interface\\AddOns\\ls_UI\\media\\frame-player")
	texture:SetTexCoord(667 / 1024, 999 / 1024, 1 / 512, 333 / 512)

	-- health_bar_parent a.k.a. ghetto
	local scroll_frame = _G.CreateFrame("ScrollFrame", nil, frame)
	scroll_frame:SetFrameLevel(level)
	scroll_frame:SetSize(140 / 2, 280 / 2)
	scroll_frame:SetPoint("CENTER")

	local health_bar_parent = _G.CreateFrame("Frame", nil, scroll_frame)
	health_bar_parent:SetAllPoints()

	-- indicators
	local indicator_parent = _G.CreateFrame("Frame", nil, frame)
	indicator_parent:SetFrameLevel(level + 1)
	indicator_parent:SetSize(90, 118)
	indicator_parent:SetPoint("CENTER")

	frame.LeftIndicator = self:CreateIndicator(indicator_parent, true)
	frame.LeftIndicator:SetFrameLevel(level + 2)
	frame.LeftIndicator:SetPoint("LEFT", 0, 0)
	frame.LeftIndicator:SetSize(8, 118)

	frame.RightIndicator = self:CreateIndicator(indicator_parent, true)
	frame.RightIndicator:SetFrameLevel(level + 2)
	frame.RightIndicator:SetPoint("RIGHT", 0, 0)
	frame.RightIndicator:SetSize(8, 118)

	local function RefreshIndicators()
		if frame.LeftIndicator:IsFree() then
			frame.LeftIndicator:Refresh()
		end

		if frame.RightIndicator:IsFree() then
			frame.RightIndicator:Refresh()
		end
	end

	frame:RegisterEvent("PLAYER_REGEN_ENABLED", RefreshIndicators)
	frame:RegisterEvent("PLAYER_REGEN_DISABLED", RefreshIndicators)
	frame:RegisterEvent("UNIT_THREAT_LIST_UPDATE", RefreshIndicators)
	frame:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", RefreshIndicators)

	-- border
	local border_parent = _G.CreateFrame("Frame", nil, frame)
	border_parent:SetFrameLevel(level + 3)
	border_parent:SetAllPoints()

	texture = border_parent:CreateTexture(nil, "BACKGROUND")
	texture:SetAllPoints()
	texture:SetTexture("Interface\\AddOns\\ls_UI\\media\\frame-player")
	texture:SetTexCoord(1 / 1024, 333 / 1024, 1 / 512, 333 / 512)

	-- class power textures
	local class_power_tube = _G.CreateFrame("Frame", nil, frame)
	class_power_tube:SetFrameLevel(level + 6)
	class_power_tube:SetSize(12, 128)
	class_power_tube:SetPoint("LEFT", 23, 0)
	E:SetBarSkin_new(class_power_tube, "VERTICAL-L")

	class_power_tube.Seps = {}

	for i = 1, 9 do
		local sep = class_power_tube:CreateTexture(nil, "ARTWORK", nil, 1)
		sep:SetSize(24 / 2, 24 / 2)
		sep:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar-seps")
		sep:SetTexCoord(26 / 64, 50 / 64, 26 / 64, 50 / 64)
		class_power_tube.Seps[i] = sep
	end

	class_power_tube.Refresh = function(_, slots, visible, sender)
		if (slots == class_power_tube.slots and visible == class_power_tube.visible)
			or (not visible and sender ~= class_power_tube.sender) then return end

		class_power_tube.slots = slots
		class_power_tube.visible = visible
		class_power_tube.sender = sender

		if visible then
			class_power_tube:Show()

			for i = 1, 9 do
				if i < slots then
					class_power_tube.Seps[i]:SetPoint("CENTER", class_power_tube, unpack(CLASS_POWER_LAYOUT[slots][i + 1].point))
					class_power_tube.Seps[i]:Show()
				else
					class_power_tube.Seps[i]:Hide()
				end
			end
		else
			class_power_tube:Hide()
		end
	end

	class_power_tube:Refresh(0, false)

	-- power textures
	local power_tube = _G.CreateFrame("Frame", nil, frame)
	power_tube:SetFrameLevel(level + 6)
	power_tube:SetSize(12, 128)
	power_tube:SetPoint("RIGHT", -23, 0)
	E:SetBarSkin_new(power_tube, "VERTICAL-L")

	-- foreground
	local fg_parent = _G.CreateFrame("Frame", "$parentCover", frame)
	fg_parent:SetFrameLevel(level + 7)
	fg_parent:SetAllPoints()
	frame.Cover = fg_parent

	texture = fg_parent:CreateTexture(nil, "ARTWORK", nil, 2)
	texture:SetAllPoints()
	texture:SetTexture("Interface\\AddOns\\ls_UI\\media\\frame-player")
	texture:SetTexCoord(334 / 1024, 666 / 1024, 1 / 512, 333 / 512)

	local text_parent = _G.CreateFrame("Frame", nil, frame)
	text_parent:SetFrameLevel(level + 8)
	text_parent:SetAllPoints()

	-- health bar
	frame.Health = self:CreateHealthBar_new(health_bar_parent, "LS16Font_Shadow", {
		is_vertical = true,
		text_parent = text_parent
	})
	frame.Health:SetFrameLevel(level + 1)
	frame.Health:SetSize(140 / 2, 280 / 2)
	frame.Health:SetPoint("CENTER")
	table.insert(frame.mouseovers, frame.Health)

	frame.Health.Text:SetPoint("BOTTOM", frame, "CENTER", 0, 1)

	-- heal prediction
	frame.HealPrediction = self:CreateHealPrediction_new(frame.Health, {
		is_vertical = true
	})

	-- local absrobGlow = fg_parent:CreateTexture(nil, "ARTWORK", nil, 1)
	-- absrobGlow:SetTexture("Interface\\AddOns\\ls_UI\\media\\frame-player-absorb")
	-- absrobGlow:SetTexCoord(1 / 128, 103 / 128, 1 / 64, 41 / 64)
	-- absrobGlow:SetVertexColor(0.35, 1, 1)
	-- absrobGlow:SetSize(102, 40)
	-- absrobGlow:SetPoint("CENTER", 0, 54)
	-- absrobGlow:SetAlpha(0)
	-- frame.AbsorbGlow = absrobGlow

	-- damage absorb text
	local damage_absorb = text_parent:CreateFontString(nil, "ARTWORK", "LS12Font_Shadow")
	damage_absorb:SetWordWrap(false)
	damage_absorb:SetPoint("BOTTOM", frame.Health.Text, "TOP", 0, 1)
	E:ResetFontStringHeight(damage_absorb)
	frame:Tag(damage_absorb, "[ls:damageabsorb]")

	-- heal absorb text
	local heal_absorb = text_parent:CreateFontString(nil, "ARTWORK", "LS12Font_Shadow")
	heal_absorb:SetPoint("BOTTOM", damage_absorb, "TOP", 0, 1)
	E:ResetFontStringHeight(heal_absorb)
	frame:Tag(heal_absorb, "[ls:healabsorb]")

	-- power bar
	frame.Power = self:CreatePowerBar_new(frame, "LS14Font_Shadow", {
		is_vertical = true,
		text_parent = text_parent,
		tube = power_tube
	})
	frame.Power:SetFrameLevel(level + 4)
	frame.Power:SetSize(12, 128)
	frame.Power:SetPoint("RIGHT", -23, 0)
	table.insert(frame.mouseovers, frame.Power)

	frame.Power.Text:SetPoint("TOP", frame, "CENTER", 0, -1)

	-- additional power bar
	frame.AdditionalPower = self:CreateAdditionalPowerBar(frame, {
		is_vertical = true,
		indicator =  frame.RightIndicator,
	})
	frame.AdditionalPower:SetFrameLevel(level + 1)
	frame.AdditionalPower:SetSize(8, 118)
	frame.AdditionalPower:SetPoint("RIGHT", -38, 0)

	-- power cost prediction
	frame.PowerPrediction = {}

	frame.PowerPrediction.mainBar = _G.CreateFrame("StatusBar", "$parentPowerCostPrediction", frame.Power)
	frame.PowerPrediction.mainBar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
	frame.PowerPrediction.mainBar:SetStatusBarColor(0.55, 0.75, 0.95) -- MOVE TO CONSTANTS!
	frame.PowerPrediction.mainBar:SetOrientation("VERTICAL")
	frame.PowerPrediction.mainBar:SetReverseFill(true)
	frame.PowerPrediction.mainBar:SetPoint("LEFT")
	frame.PowerPrediction.mainBar:SetPoint("RIGHT")
	frame.PowerPrediction.mainBar:SetPoint("TOP", frame.Power:GetStatusBarTexture(), "TOP")
	frame.PowerPrediction.mainBar:SetHeight(128)
	E:SmoothBar(frame.PowerPrediction.mainBar)

	frame.PowerPrediction.altBar = _G.CreateFrame("StatusBar", "$parentPowerCostPrediction", frame.AdditionalPower)
	frame.PowerPrediction.altBar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
	frame.PowerPrediction.altBar:SetStatusBarColor(0.55, 0.75, 0.95) -- MOVE TO CONSTANTS!
	frame.PowerPrediction.altBar:SetOrientation("VERTICAL")
	frame.PowerPrediction.altBar:SetReverseFill(true)
	frame.PowerPrediction.altBar:SetPoint("LEFT")
	frame.PowerPrediction.altBar:SetPoint("RIGHT")
	frame.PowerPrediction.altBar:SetPoint("TOP", frame.AdditionalPower:GetStatusBarTexture(), "TOP")
	frame.PowerPrediction.altBar:SetHeight(118)
	E:SmoothBar(frame.PowerPrediction.altBar)

	-- class powers
	if E.PLAYER_CLASS == "MONK" then
		local function OnShow()
			class_power_tube:Refresh(1, true, "STAGGER")
		end

		local function OnHide()
			class_power_tube:Refresh(0, false, "STAGGER")
		end

		frame.Stagger = _G.CreateFrame("StatusBar", "$parentStaggerBar", frame)
		frame.Stagger:SetFrameLevel(level + 4)
		frame.Stagger:SetOrientation("VERTICAL")
		frame.Stagger:SetPoint("LEFT", 23, 0)
		frame.Stagger:SetSize(12, 128)
		frame.Stagger:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		frame.Stagger:Hide()
		frame.Stagger:HookScript("OnHide", OnHide)
		frame.Stagger:HookScript("OnShow", OnShow)
		E:SmoothBar(frame.Stagger)
		table.insert(frame.mouseovers, frame.Stagger)

		frame.Stagger.Text = text_parent:CreateFontString(nil, "ARTWORK", "LS12Font_Shadow")
		frame.Stagger.Text:SetWordWrap(false)
		frame.Stagger.Text:SetPoint("TOP", frame.Power.Text, "BOTTOM", 0, -1)
		E:ResetFontStringHeight(frame.Stagger.Text)

		frame.Stagger.Override = function(_, _, unit)
			if unit and unit ~= frame.unit then return end

			local max = _G.UnitHealthMax("player")
			local cur = _G.UnitStagger("player")
			local r, g, b, hex = M.COLORS.POWER.STAGGER:GetRGBHEX(cur / max)

			frame.Stagger:SetMinMaxValues(0, max)
			frame.Stagger:SetValue(cur)
			frame.Stagger:SetStatusBarColor(r, g, b)

			if cur == 0 then
				return frame.Stagger.Text:SetText(nil)
			end

			frame.Stagger.Text:SetFormattedText("|cff%s%s|r", hex, E:NumberFormat(cur))
		end
	elseif E.PLAYER_CLASS == "DEATHKNIGHT" then
		frame.Runes = _G.CreateFrame("Frame", "$parentRuneBar", frame)
		frame.Runes:SetFrameLevel(level + 4)
		frame.Runes:SetPoint("LEFT", 23, 0)
		frame.Runes:SetSize(12, 128)

		for i = 1, 6 do
			local element = _G.CreateFrame("StatusBar", "$parentRune"..i, frame.Runes)
			element:SetFrameLevel(frame.Runes:GetFrameLevel())
			element:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
			element:SetOrientation("VERTICAL")
			element:SetSize(12, CLASS_POWER_LAYOUT[6][i].size)
			element:SetPoint(unpack(CLASS_POWER_LAYOUT[6][i].point))
			element:SetStatusBarColor(M.COLORS.POWER.RUNES:GetRGB())
			frame.Runes[i] = element

			texture = fg_parent:CreateTexture(nil, "ARTWORK", nil, 3)
			texture:SetSize(16, CLASS_POWER_LAYOUT[6][i].size)
			texture:SetPoint("BOTTOM", element, "BOTTOM", 0, 0)
			texture:SetTexture("Interface\\AddOns\\ls_UI\\media\\frame-player-classpower")
			texture:SetVertexColor(M.COLORS.POWER.GLOW.RUNES:GetRGB())
			texture:SetTexCoord(unpack(CLASS_POWER_LAYOUT[6][i].glow))
			texture:SetAlpha(0)
			element.Glow = texture

			local ag = texture:CreateAnimationGroup()
			element.InAnim = ag

			local anim = ag:CreateAnimation("Alpha")
			anim:SetOrder(1)
			anim:SetDuration(0.25)
			anim:SetFromAlpha(0)
			anim:SetToAlpha(1)

			anim = ag:CreateAnimation("Alpha")
			anim:SetOrder(2)
			anim:SetDuration(0.25)
			anim:SetFromAlpha(1)
			anim:SetToAlpha(0)

			anim = ag:CreateAnimation("Scale")
			anim:SetOrder(1)
			anim:SetDuration(0.33)
			anim:SetFromScale(0.1, 0.1)
			anim:SetToScale(1.1, 1.1)
		end

		frame.Runes.PostUpdate = function(_, rune, _, _, _, runeReady)
			if runeReady then
				rune.InAnim:Play()
			end

			if _G.UnitHasVehicleUI("player") then
				frame.Runes:Hide()
				class_power_tube:Refresh(0, false, "RUNES")
			else
				frame.Runes:Show()
				class_power_tube:Refresh(6, true, "RUNES")
			end
		end
	end

	local function Element_OnShow(self)
		self.OutAnim:Stop()

		if not self.active and not self.InAnim:IsPlaying() then
			self.InAnim:Play()
			self.active = true
		end
	end

	local function Element_OnHide(self)
		self.InAnim:Stop()

		if self.active and not self.OutAnim:IsPlaying() then
			self.OutAnim:Play()
			self.active = false
		end
	end

	frame.ClassIcons = _G.CreateFrame("Frame", "$parentClassPowerBar", frame)
	frame.ClassIcons:SetFrameLevel(level + 4)
	frame.ClassIcons:SetPoint("LEFT", 23, 0)
	frame.ClassIcons:SetSize(12, 128)

	for i = 1, 10 do
		local element = _G.CreateFrame("Frame", "$parentElement"..i, frame.ClassIcons)
		element:SetFrameLevel(frame.ClassIcons:GetFrameLevel())
		element:Hide()
		element:SetScript("OnShow", Element_OnShow)
		element:SetScript("OnHide", Element_OnHide)
		frame.ClassIcons[i] = element

		texture = element:CreateTexture(nil, "BACKGROUND", nil, 3)
		texture:SetTexture("Interface\\BUTTONS\\WHITE8X8")
		texture:SetAllPoints()
		element.Texture = texture

		texture = fg_parent:CreateTexture(nil, "ARTWORK", nil, 3)
		texture:SetTexture("Interface\\AddOns\\ls_UI\\media\\frame-player-classpower")
		texture:SetPoint("CENTER", element, "CENTER", 0, 0)
		texture:SetAlpha(0)
		element.Glow = texture

		local ag = texture:CreateAnimationGroup()
		element.InAnim = ag

		local anim = ag:CreateAnimation("Alpha")
		anim:SetOrder(1)
		anim:SetDuration(0.35)
		anim:SetFromAlpha(0)
		anim:SetToAlpha(1)

		anim = ag:CreateAnimation("Alpha")
		anim:SetOrder(2)
		anim:SetDuration(0.15)
		anim:SetFromAlpha(1)
		anim:SetToAlpha(0)

		anim = ag:CreateAnimation("Scale")
		anim:SetOrder(1)
		anim:SetDuration(0.35)
		anim:SetFromScale(0.9, 0.9)
		anim:SetToScale(1.1, 1.1)

		ag = texture:CreateAnimationGroup()
		element.OutAnim = ag

		anim = ag:CreateAnimation("Alpha")
		anim:SetOrder(1)
		anim:SetDuration(0.2)
		anim:SetFromAlpha(0)
		anim:SetToAlpha(1)

		anim = ag:CreateAnimation("Alpha")
		anim:SetOrder(2)
		anim:SetDuration(0.2)
		anim:SetFromAlpha(1)
		anim:SetToAlpha(0)

		anim = ag:CreateAnimation("Scale")
		anim:SetOrder(1)
		anim:SetDuration(0.2)
		anim:SetFromScale(1.1, 1.1)
		anim:SetToScale(0.9, 0.9)
	end

	frame.ClassIcons.PostUpdate = function(_, _, max, changed, powerType, event)
		if event == "ClassPowerDisable" then
			frame.ClassIcons:Hide()
			class_power_tube:Refresh(0, false, "CP")
		else
			if event == "ClassPowerEnable" or event == "RefreshUnit" or changed then
				frame.ClassIcons:Show()
				class_power_tube:Refresh(max or 10, true, "CP")

				for i = 1, max do
					local element = frame.ClassIcons[i]
					element:SetSize(12, CLASS_POWER_LAYOUT[max][i].size)
					element:SetPoint(unpack(CLASS_POWER_LAYOUT[max][i].point))

					element.Texture:SetVertexColor(M.COLORS.POWER[powerType]:GetRGB())

					element.Glow:SetSize(16, CLASS_POWER_LAYOUT[max][i].size)
					element.Glow:SetTexCoord(unpack(CLASS_POWER_LAYOUT[max][i].glow))
					element.Glow:SetVertexColor(M.COLORS.POWER.GLOW[powerType]:GetRGB())
				end
			end
		end
	end

	-- pvp
	frame.PvP = self:CreatePvPIcon_new(frame, "ARTWORK", 6)
	frame.PvP:SetPoint("TOP", fg_parent, "BOTTOM", 0, 10)
	frame:RegisterEvent("PLAYER_FLAGS_CHANGED", frame.PvP.Override)

	frame.Castbar = self:CreateCastBar(frame, 202, true, true)
	frame.Castbar.Holder:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 190)
	E:CreateMover(frame.Castbar.Holder)

	-- status icons
	local status = text_parent:CreateFontString(nil, "OVERLAY", "LSStatusIcon16Font")
	status:SetWidth(18)
	status:SetPoint("LEFT", frame, "LEFT", 5, 0)
	frame:Tag(status, "[ls:leadericon][ls:lfdroleicon]")

	status = text_parent:CreateFontString(nil, "OVERLAY", "LSStatusIcon16Font")
	status:SetWidth(18)
	status:SetPoint("RIGHT", frame, "RIGHT", -5, 0)
	frame:Tag(status, "[ls:combatresticon]")

	status = text_parent:CreateFontString(nil, "OVERLAY", "LSStatusIcon12Font")
	status:SetWidth(14)
	status:SetPoint("LEFT", frame.Health, "LEFT", 0, 0)
	frame:Tag(status, "[ls:debuffstatus]")

	-- floating combat text
	frame.FloatingCombatFeedback = _G.CreateFrame("Frame", "$parentFeedbackFrame", frame)
	frame.FloatingCombatFeedback:SetFrameLevel(level + 9)
	frame.FloatingCombatFeedback:SetSize(32, 32)
	frame.FloatingCombatFeedback:SetPoint("CENTER", 0, 0)

	for i = 1, 6 do
		frame.FloatingCombatFeedback[i] = frame.FloatingCombatFeedback:CreateFontString(nil, "OVERLAY", "CombatTextFont")
	end

	frame.FloatingCombatFeedback.mode = "Fountain"
	frame.FloatingCombatFeedback.xOffset = 15
	frame.FloatingCombatFeedback.yOffset = 20
	frame.FloatingCombatFeedback.abbreviateNumbers = true

	-- totems
	local function Totem_OnEnter(self)
		local quadrant = E:GetScreenQuadrant(self)
		local p, rP, sign = "BOTTOMLEFT", "CENTER", 1

		if quadrant == "TOPLEFT" or quadrant == "TOP" or quadrant == "TOPRIGHT" then
			p, sign = "TOPLEFT", -1
		end

		_G.GameTooltip:SetOwner(self, "ANCHOR_NONE")
		_G.GameTooltip:SetPoint(p, self, rP, 0, sign * 2)
		_G.GameTooltip:SetTotem(self.slot)
	end

	for i = 1, _G.MAX_TOTEMS do
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

		totem:SetParent(frame)
		totem:SetSize(72 / 2, 72 / 2)
		totem:ClearAllPoints()
		totem:SetPoint(unpack(TOTEM_LAYOUT[i]))
		totem:SetScript("OnEnter", Totem_OnEnter)

		border = totem:CreateTexture(nil, "OVERLAY")
		border:SetTexture("Interface\\AddOns\\ls_UI\\media\\minimap-buttons")
		border:SetTexCoord(90 / 256, 162 / 256, 1 / 256, 73 / 256)
		border:SetAllPoints()

		icon:SetParent(totem)
		icon:SetMask("Interface\\Minimap\\UI-Minimap-Background")
		icon:ClearAllPoints()
		icon:SetPoint("TOPLEFT", 6, -6)
		icon:SetPoint("BOTTOMRIGHT", -6, 6)

		cd:SetParent(totem)
		cd:SetSwipeTexture("Interface\\PlayerFrame\\ClassOverlay-RuneCooldown")
		cd:SetReverse(false)
		cd:ClearAllPoints()
		cd:SetPoint("TOPLEFT", 6, -6)
		cd:SetPoint("BOTTOMRIGHT", -6, 6)

		E:HandleCooldown(cd, 10)

		if cd.Timer then
			cd.Timer:SetJustifyV("BOTTOM")
		end
	end
end
