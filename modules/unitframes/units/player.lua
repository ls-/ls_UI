local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)
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
		-- 2: frame.Health
			-- 3: frame.HealPrediction
		-- 2: frame.AdditionalPower
			-- 3: frame.PowerPrediction.altBar
		-- 2: frame.LeftIndicator, frame.RightIndicator
		-- 4: border_parent
		-- 5: frame.Power
			-- 6: frame.PowerPrediction.mainBar
		-- 5: frame.Stagger, frame.Runes, frame.ClassIcons
		-- 7: frame.LeftTube, frame.RightTube
		-- 8: frame.FGParent
		-- 9: frame.TextParent
		-- 10: frame.FloatingCombatFeedback

	-- bg, border, fg, text parents
	do
		-- bg
		local texture = frame:CreateTexture(nil, "BACKGROUND", nil, -7)
		texture:SetAllPoints()
		texture:SetTexture("Interface\\AddOns\\ls_UI\\media\\frame-player")
		texture:SetTexCoord(667 / 1024, 999 / 1024, 1 / 512, 333 / 512)

		-- border
		local parent = _G.CreateFrame("Frame", nil, frame)
		parent:SetFrameLevel(level + 3)
		parent:SetAllPoints()

		texture = parent:CreateTexture(nil, "BACKGROUND")
		texture:SetAllPoints()
		texture:SetTexture("Interface\\AddOns\\ls_UI\\media\\frame-player")
		texture:SetTexCoord(1 / 1024, 333 / 1024, 1 / 512, 333 / 512)

		-- fg
		parent = _G.CreateFrame("Frame", nil, frame)
		parent:SetFrameLevel(level + 7)
		parent:SetAllPoints()
		frame.FGParent = parent

		texture = parent:CreateTexture(nil, "ARTWORK", nil, 2)
		texture:SetAllPoints()
		texture:SetTexture("Interface\\AddOns\\ls_UI\\media\\frame-player")
		texture:SetTexCoord(334 / 1024, 666 / 1024, 1 / 512, 333 / 512)

		-- text
		parent = _G.CreateFrame("Frame", nil, frame)
		parent:SetFrameLevel(level + 8)
		parent:SetAllPoints()
		frame.TextParent = parent
	end

	-- indicators
	do
		-- left indicator
		local indicator = self:CreateIndicator(frame, {
			is_vertical = true,
		})
		indicator:SetFrameLevel(level + 1)
		indicator:SetPoint("LEFT", 38, 0)
		indicator:SetSize(8, 118)
		frame.LeftIndicator = indicator

		-- right indicator
		indicator = self:CreateIndicator(frame, {
			is_vertical = true,
		})
		indicator:SetFrameLevel(level + 1)
		indicator:SetPoint("RIGHT", -38, 0)
		indicator:SetSize(8, 118)
		frame.RightIndicator = indicator

		local function RefreshIndicators()
			frame.LeftIndicator:Refresh()
			frame.RightIndicator:Refresh()
		end

		frame:RegisterEvent("PLAYER_REGEN_ENABLED", RefreshIndicators)
		frame:RegisterEvent("PLAYER_REGEN_DISABLED", RefreshIndicators)
		frame:RegisterEvent("UNIT_THREAT_LIST_UPDATE", RefreshIndicators)
		frame:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", RefreshIndicators)
	end

	-- class power, power tubes
	do
		-- class power
		local tube = _G.CreateFrame("Frame", nil, frame)
		tube:SetFrameLevel(level + 6)
		tube:SetSize(12, 128)
		tube:SetPoint("LEFT", 23, 0)
		E:SetStatusBarSkin(tube, "VERTICAL-L")
		frame.LeftTube = tube

		local seps = {}

		for i = 1, 9 do
			local sep = tube:CreateTexture(nil, "ARTWORK", nil, 1)
			sep:SetSize(24 / 2, 24 / 2)
			sep:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar-seps")
			sep:SetTexCoord(26 / 64, 50 / 64, 26 / 64, 50 / 64)
			seps[i] = sep
		end

		tube.Refresh = function(self, slots, visible, sender)
			if (slots == self.slots and visible == self.visible)
				or (not visible and sender ~= self.sender) then return end

			self.slots = slots
			self.visible = visible
			self.sender = sender

			if visible then
				self:Show()

				for i = 1, 9 do
					if i < slots then
						seps[i]:SetPoint("CENTER", self, unpack(CLASS_POWER_LAYOUT[slots][i + 1].point))
						seps[i]:Show()
					else
						seps[i]:Hide()
					end
				end
			else
				self:Hide()
			end
		end

		tube:Refresh(0, false)

		-- power
		tube = _G.CreateFrame("Frame", nil, frame)
		tube:SetFrameLevel(level + 6)
		tube:SetSize(12, 128)
		tube:SetPoint("RIGHT", -23, 0)
		E:SetStatusBarSkin(tube, "VERTICAL-L")
		frame.RightTube = tube
	end

	-- health, heal prediction bars
	do
		-- health
		local bar = self:CreateHealthBar_new(frame, "LS16Font_Shadow", {
			is_vertical = true,
			text_parent = frame.TextParent
		})
		bar:SetFrameLevel(level + 1)
		bar:SetSize(140 / 2, 280 / 2)
		bar:SetPoint("CENTER")
		bar:SetClipsChildren(true)
		table.insert(frame.mouseovers, bar)
		frame.Health = bar

		bar.Text:SetPoint("BOTTOM", frame, "CENTER", 0, 1)

		-- heal prediction
		frame.HealPrediction = self:CreateHealPrediction_new(frame.Health, {
			is_vertical = true
		})

		-- local absrobGlow = frame.FGParent:CreateTexture(nil, "ARTWORK", nil, 1)
		-- absrobGlow:SetTexture("Interface\\AddOns\\ls_UI\\media\\frame-player-absorb")
		-- absrobGlow:SetTexCoord(1 / 128, 103 / 128, 1 / 64, 41 / 64)
		-- absrobGlow:SetVertexColor(0.35, 1, 1)
		-- absrobGlow:SetSize(102, 40)
		-- absrobGlow:SetPoint("CENTER", 0, 54)
		-- absrobGlow:SetAlpha(0)
		-- frame.AbsorbGlow = absrobGlow

		-- damage absorb text
		local damage_absorb = frame.TextParent:CreateFontString(nil, "ARTWORK", "LS12Font_Shadow")
		damage_absorb:SetWordWrap(false)
		damage_absorb:SetPoint("BOTTOM", frame.Health.Text, "TOP", 0, 1)
		E:ResetFontStringHeight(damage_absorb)
		frame:Tag(damage_absorb, "[ls:damageabsorb]")

		-- heal absorb text
		local heal_absorb = frame.TextParent:CreateFontString(nil, "ARTWORK", "LS12Font_Shadow")
		heal_absorb:SetPoint("BOTTOM", damage_absorb, "TOP", 0, 1)
		E:ResetFontStringHeight(heal_absorb)
		frame:Tag(heal_absorb, "[ls:healabsorb]")
	end


	-- power, additional power, power cost prediction bars
	do
		-- power bar
		local bar = self:CreatePowerBar_new(frame, "LS14Font_Shadow", {
			is_vertical = true,
			text_parent = frame.TextParent,
			tube = frame.RightTube
		})
		bar:SetFrameLevel(level + 4)
		bar:SetSize(12, 128)
		bar:SetPoint("RIGHT", -23, 0)
		table.insert(frame.mouseovers, bar)
		frame.Power = bar

		bar.Text:SetPoint("TOP", frame, "CENTER", 0, -1)

		-- additional power bar
		bar = self:CreateAdditionalPowerBar(frame, {
			is_vertical = true,
		})
		bar:SetFrameLevel(level + 4)
		bar:SetPoint("LEFT", 23, 0)
		bar:SetSize(12, 128)
		bar:Hide()
		bar:HookScript("OnHide", function()
			frame.LeftTube:Refresh(0, false, "APB")
		end)
		bar:HookScript("OnShow", function()
			frame.LeftTube:Refresh(1, true, "APB")
		end)
		frame.AdditionalPower = bar

		-- power cost prediction
		frame.PowerPrediction = {}

		bar = _G.CreateFrame("StatusBar", "$parentPowerCostPrediction", frame.Power)
		bar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		bar:SetStatusBarColor(0.55, 0.75, 0.95) -- MOVE TO CONSTANTS!
		bar:SetOrientation("VERTICAL")
		bar:SetReverseFill(true)
		bar:SetPoint("LEFT")
		bar:SetPoint("RIGHT")
		bar:SetPoint("TOP", frame.Power:GetStatusBarTexture(), "TOP")
		bar:SetHeight(128)
		E:SmoothBar(bar)
		frame.PowerPrediction.mainBar = bar

		bar = _G.CreateFrame("StatusBar", "$parentPowerCostPrediction", frame.AdditionalPower)
		bar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		bar:SetStatusBarColor(0.55, 0.75, 0.95) -- MOVE TO CONSTANTS!
		bar:SetOrientation("VERTICAL")
		bar:SetReverseFill(true)
		bar:SetPoint("LEFT")
		bar:SetPoint("RIGHT")
		bar:SetPoint("TOP", frame.AdditionalPower:GetStatusBarTexture(), "TOP")
		bar:SetHeight(128)
		E:SmoothBar(bar)
		frame.PowerPrediction.altBar = bar
	end

	-- stagger, rune bars
	if E.PLAYER_CLASS == "MONK" then
		local bar = _G.CreateFrame("StatusBar", "$parentStaggerBar", frame)
		bar:SetFrameLevel(level + 4)
		bar:SetOrientation("VERTICAL")
		bar:SetPoint("LEFT", 23, 0)
		bar:SetSize(12, 128)
		bar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		bar:Hide()
		bar:HookScript("OnHide", function()
			frame.LeftTube:Refresh(0, false, "STAGGER")
		end)
		bar:HookScript("OnShow", function()
			frame.LeftTube:Refresh(1, true, "STAGGER")
		end)
		E:SmoothBar(bar)
		table.insert(frame.mouseovers, bar)
		frame.Stagger = bar

		local text = frame.TextParent:CreateFontString(nil, "ARTWORK", "LS12Font_Shadow")
		text:SetWordWrap(false)
		text:SetPoint("TOP", frame.Power.Text, "BOTTOM", 0, -1)
		E:ResetFontStringHeight(text)
		bar.Text = text

		bar.Override = function(_, _, unit)
			if unit and unit ~= "player" then return end

			local max = _G.UnitHealthMax("player")
			local cur = _G.UnitStagger("player")
			local r, g, b, hex = M.COLORS.POWER.STAGGER:GetRGBHEX(cur / max)

			bar:SetMinMaxValues(0, max)
			bar:SetValue(cur)
			bar:SetStatusBarColor(r, g, b)

			if cur == 0 then
				return bar.Text:SetText(nil)
			end

			bar.Text:SetFormattedText(L["BAR_COLORED_VALUE_TEMPLATE"], E:NumberFormat(cur), hex)
		end
	elseif E.PLAYER_CLASS == "DEATHKNIGHT" then
		local bar = _G.CreateFrame("Frame", "$parentRuneBar", frame)
		bar:SetFrameLevel(level + 4)
		bar:SetPoint("LEFT", 23, 0)
		bar:SetSize(12, 128)
		bar:Hide()
		frame.Runes = bar

		for i = 1, 6 do
			local element = _G.CreateFrame("StatusBar", "$parentRune"..i, bar)
			element:SetFrameLevel(bar:GetFrameLevel())
			element:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
			element:SetOrientation("VERTICAL")
			element:SetSize(12, CLASS_POWER_LAYOUT[6][i].size)
			element:SetPoint(unpack(CLASS_POWER_LAYOUT[6][i].point))
			element:SetStatusBarColor(M.COLORS.POWER.RUNES:GetRGB())
			bar[i] = element

			local texture = frame.FGParent:CreateTexture(nil, "ARTWORK", nil, 3)
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

		bar.PostUpdate = function(self, rune, _, _, _, runeReady)
			if runeReady then
				rune.InAnim:Play()
			end

			if _G.UnitHasVehicleUI("player") then
				self:Hide()
				frame.LeftTube:Refresh(0, false, "RUNES")
			else
				self:Show()
				frame.LeftTube:Refresh(6, true, "RUNES")
			end
		end
	end

	-- class power bars
	do
		local function OnShow(self)
			self.OutAnim:Stop()

			if not self.active and not self.InAnim:IsPlaying() then
				self.InAnim:Play()
				self.active = true
			end
		end

		local function OnHide(self)
			self.InAnim:Stop()

			if self.active and not self.OutAnim:IsPlaying() then
				self.OutAnim:Play()
				self.active = false
			end
		end

		local bar = _G.CreateFrame("Frame", "$parentClassPowerBar", frame)
		bar:SetFrameLevel(level + 4)
		bar:SetPoint("LEFT", 23, 0)
		bar:SetSize(12, 128)
		frame.ClassIcons = bar

		for i = 1, 10 do
			local element = _G.CreateFrame("Frame", "$parentElement"..i, bar)
			element:SetFrameLevel(bar:GetFrameLevel())
			element:Hide()
			element:SetScript("OnShow", OnShow)
			element:SetScript("OnHide", OnHide)
			bar[i] = element

			local texture = element:CreateTexture(nil, "BACKGROUND", nil, 3)
			texture:SetTexture("Interface\\BUTTONS\\WHITE8X8")
			texture:SetAllPoints()
			element.Texture = texture

			texture = frame.FGParent:CreateTexture(nil, "ARTWORK", nil, 3)
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

		bar.PostUpdate = function(self, _, max, changed, powerType, event)
			if event == "ClassPowerDisable" then
				self:Hide()
				frame.LeftTube:Refresh(0, false, "CP")
			else
				if event == "ClassPowerEnable" or event == "RefreshUnit" or changed then
					self:Show()
					frame.LeftTube:Refresh(max or 10, true, "CP")

					for i = 1, max do
						local element = self[i]
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
	end

	-- pvp
	frame.PvP = self:CreatePvPIcon_new(frame.FGParent, "ARTWORK", 6)
	frame.PvP:SetPoint("TOP", frame.FGParent, "BOTTOM", 0, 10)

	-- castbar
	frame.Castbar = self:CreateCastBar(frame, 188, true, true)
	frame.Castbar.Holder:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 190)
	E:CreateMover(frame.Castbar.Holder)

	-- status icons/texts
	local status = frame.TextParent:CreateFontString(nil, "ARTWORK", "LS10Font_Outline")
	status:SetPoint("TOPRIGHT", frame.PvP, "TOPRIGHT", 0, 0)
	status:SetTextColor(1, 0.82, 0)
	status:SetJustifyH("RIGHT")
	status.frequentUpdates = 0.1
	frame:Tag(status, "[ls:pvptimer]")

	status = frame.TextParent:CreateFontString(nil, "OVERLAY", "LSStatusIcon16Font")
	status:SetWidth(18)
	status:SetPoint("LEFT", frame, "LEFT", 5, 0)
	frame:Tag(status, "[ls:leadericon][ls:lfdroleicon]")

	status = frame.TextParent:CreateFontString(nil, "OVERLAY", "LSStatusIcon16Font")
	status:SetWidth(18)
	status:SetPoint("RIGHT", frame, "RIGHT", -5, 0)
	frame:Tag(status, "[ls:combatresticon]")

	status = frame.TextParent:CreateFontString(nil, "OVERLAY", "LSStatusIcon12Font")
	status:SetWidth(14)
	status:SetPoint("LEFT", frame.Health, "LEFT", 0, 0)
	frame:Tag(status, "[ls:debuffstatus]")

	-- floating combat text
	do
		local feeback = _G.CreateFrame("Frame", "$parentFeedbackFrame", frame)
		feeback:SetFrameLevel(level + 9)
		feeback:SetSize(32, 32)
		feeback:SetPoint("CENTER", 0, 0)
		frame.FloatingCombatFeedback = feeback

		for i = 1, 6 do
			feeback[i] = feeback:CreateFontString(nil, "OVERLAY", "CombatTextFont")
		end

		feeback.mode = "Fountain"
		feeback.xOffset = 15
		feeback.yOffset = 20
		feeback.abbreviateNumbers = true
	end

	-- totems
	do
		local function OnEnter(self)
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
			totem:SetScript("OnEnter", OnEnter)

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
end
