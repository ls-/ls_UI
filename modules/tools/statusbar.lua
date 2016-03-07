local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local COLORS = M.colors

local unpack = unpack

local PRESETS = {
	HORIZONTAL = {
		texture = "Interface\\AddOns\\oUF_LS\\media\\statusbar_horizontal",
		caps = {
			["2"] = {
				size = {11, 10},
				first = {1 / 64, 12 / 64, 25 / 64, 35 / 64},
				second= {1 / 64, 12 / 64, 36 / 64, 46 / 64},
			},
			["12"] = {
				size = {12, 20},
				first = {13 / 64, 27 / 64, 25 / 64, 47 / 64},
				second= {28 / 64, 42 / 64, 25 / 64, 47 / 64},
			},
			["14"] = {
				size = {14, 22},
				first = {13 / 64, 27 / 64, 25 / 64, 47 / 64},
				second= {28 / 64, 42 / 64, 25 / 64, 47 / 64},
			},
			first_point = {"RIGHT", "$parent", "LEFT", 3, 0},
			second_point = {"LEFT", "$parent", "RIGHT", -3, 0},
		},
		gloss = {0 / 64, 64 / 64, 0 / 64, 20 / 64},
		middle = {
			first = {0 / 64, 64 / 64, 21 / 64, 24 / 64},
			first_point1 = {"TOPLEFT", 0, 3},
			first_point2 = {"TOPRIGHT", 0, 3},
			second = {0 / 64, 64 / 64, 24 / 64, 21 / 64},
			second_point1 = {"BOTTOMLEFT", 0, -3},
			second_point2 = {"BOTTOMRIGHT", 0, -3},
		},
		text_size = {
			["2"] = 10,
			["12"] = 10,
			["14"] = 12,
		},
	},
	VERTICAL = {
		texture = "Interface\\AddOns\\oUF_LS\\media\\statusbar_vertical",
		caps = {
			["2"] = {
				size = {10, 11},
				first = {25 / 64, 35 / 64, 1 / 64, 12 / 64},
				second= {36 / 64, 46 / 64, 1 / 64, 12 / 64},
			},
			["12"] = {
				size = {20, 12},
				first = {25 / 64, 47 / 64, 13 / 64, 27 / 64},
				second= {25 / 64, 47 / 64, 28 / 64, 42 / 64},
			},
			["14"] = {
				size = {22, 14},
				first = {25 / 64, 47 / 64, 13 / 64, 27 / 64},
				second= {25 / 64, 47 / 64, 28 / 64, 42 / 64},
			},
			first_point = {"BOTTOM", "$parent", "TOP", 0, -3},
			second_point = {"TOP", "$parent", "BOTTOM", 0, 3},
		},
		gloss = {0 / 64, 20 / 64, 0 / 64, 64 / 64},
		middle = {
			first = {21 / 64, 24 / 64, 0 / 64, 64 / 64},
			first_point1 = {"TOPRIGHT", "$parent", "TOPLEFT", 0, 0},
			first_point2 = {"BOTTOMRIGHT", "$parent", "BOTTOMLEFT", 0, 0},
			second = {24 / 64, 21 / 64, 0 / 64, 64 / 64},
			second_point1 = {"TOPLEFT", "$parent", "TOPRIGHT", 0, 0},
			second_point2 = {"BOTTOMLEFT", "$parent", "BOTTOMRIGHT", 0, 0},
		},
		text_size = {
			["2"] = 10,
			["12"] = 10,
			["14"] = 12,
		},
	},
}

function E:HandleStatusBar(bar, addBorder, height, cascade)
	local children = {bar:GetChildren()}
	local regions = {bar:GetRegions()}

	local sbt = bar.GetStatusBarTexture and bar:GetStatusBarTexture()

	-- print("====", bar:GetName(), #children, #regions, "====")

	local texture, layer, background, text, sb

	for _, region in next, regions do
		if region:IsObjectType("Texture") then
			texture, layer = region:GetTexture(), region:GetDrawLayer()
			if layer == "BACKGROUND" then
				if texture and strfind(texture, "Color") then
					background = region
				elseif texture and strfind(texture, "Background") then
					background = region
				else
					E:ForceHide(region)
				end
			else
				if region ~= sbt then
					E:ForceHide(region)
				end
			end
		elseif region:IsObjectType("FontString") then
			text = region
		end
	end

	local tbackground, ttext, tsbt

	for _, child in next, children do
		if child:IsObjectType("StatusBar") then
			tbackground, ttext, tsbt = self:HandleStatusBar(child, nil, nil, true)
		end
	end

	background = background or tbackground
	text = text or ttext
	sbt = sbt or tsbt
	sb = sbt:GetParent()

	-- print(cascade and "CASCADE!!" or "")
	-- print("|cffffff7fBG|r", not not background, "|cffffff7fTEXT|r", not not text, "|cffffff7fSBT|r", not not sbt, "|cffffff7fSB|r", not not sb)

	if not cascade then
		local PRESET = PRESETS["HORIZONTAL"]
		height = height or "14"

		bar.ignoreFramePositionManager = true
		bar:SetSize(166, tonumber(height))

		if not background then
			background = bar:CreateTexture(nil, "BACKGROUND")
		end

		background:SetTexture(unpack(COLORS.darkgray))
		background:SetAllPoints()
		bar.Bg = background

		if not text then
			text = E:CreateFontString(bar, PRESET.text_size[height], "$parentText", true)
		else
			text:SetFontObject("LS"..PRESET.text_size[height].."Font_Shadow")
			text:SetWordWrap(false)
			text:SetJustifyV("MIDDLE")
		end

		text:SetDrawLayer("OVERLAY", 1)
		text:ClearAllPoints()
		text:SetPoint("TOPLEFT", 1, 0)
		text:SetPoint("BOTTOMRIGHT", -1, 0)
		bar.Text = text

		sbt:SetDrawLayer("BACKGROUND", 1)
		sbt:SetTexture("Interface\\BUTTONS\\WHITE8X8")
		bar.Texture = sbt

		if sb ~= bar then
			sb:SetAllPoints()
		end

		local gloss = bar:CreateTexture(nil, "BORDER", nil, -8)
		gloss:SetTexture(PRESET.texture)
		gloss:SetTexCoord(unpack(PRESET.gloss))
		gloss:SetAllPoints()

		if addBorder then
			local capWidth, capHeight = unpack(PRESET.caps[height].size)

			local firstCap = bar:CreateTexture(nil, "BORDER")
			firstCap:SetTexture(PRESET.texture)
			firstCap:SetTexCoord(unpack(PRESET.caps[height].first))
			firstCap:SetSize(capWidth, capHeight)
			firstCap:SetPoint(unpack(PRESET.caps.first_point))

			local firstMid = bar:CreateTexture(nil, "BORDER")
			firstMid:SetTexture(PRESET.texture)
			firstMid:SetTexCoord(unpack(PRESET.middle.first))
			firstMid:SetHeight(3)
			firstMid:SetPoint(unpack(PRESET.middle.first_point1))
			firstMid:SetPoint(unpack(PRESET.middle.first_point2))

			local secondMid = bar:CreateTexture(nil, "BORDER")
			secondMid:SetTexture(PRESET.texture)
			secondMid:SetTexCoord(unpack(PRESET.middle.second))
			secondMid:SetHeight(3)
			secondMid:SetPoint(unpack(PRESET.middle.second_point1))
			secondMid:SetPoint(unpack(PRESET.middle.second_point2))

			local secondCap = bar:CreateTexture(nil, "BORDER")
			secondCap:SetTexture(PRESET.texture)
			secondCap:SetTexCoord(unpack(PRESET.caps[height].second))
			secondCap:SetSize(capWidth, capHeight)
			secondCap:SetPoint(unpack(PRESET.caps.second_point))

			bar.Tube = {
				[1] = firstCap,
				[2] = firstMid,
				[3] = secondMid,
				[4] = secondCap,
			}
		end

		bar.styled = true
	else
		return background, text, sbt
	end
end

function E:CreateStatusBar(parent, name, orientation, preset, barSize, addBorder)
	local PRESET = PRESETS[orientation]

	local bar = CreateFrame("StatusBar", name, parent)
	bar:SetOrientation(orientation)
	bar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
	bar:GetStatusBarTexture():SetDrawLayer("BACKGROUND", 1)

	local bg = bar:CreateTexture(nil, "BACKGROUND", nil, 0)
	bg:SetTexture(unpack(COLORS.darkgray))
	bg:SetAllPoints()
	bar.Bg = bg

	local text = E:CreateFontString(bar, PRESET.text_size[preset], "$parentText", true)
	bar.Text = text

	local gloss = bar:CreateTexture(nil, "BORDER", nil, -8)
	gloss:SetTexture(PRESET.texture)
	gloss:SetTexCoord(unpack(PRESET.gloss))
	gloss:SetAllPoints()

	if orientation == "HORIZONTAL" then
		bar:SetSize(barSize or 2, tonumber(preset))
		text:SetPoint("TOPLEFT", 1, 0)
		text:SetPoint("BOTTOMRIGHT", -1, 0)
	else
		bar:SetSize(tonumber(preset), barSize or 2)
		text:SetPoint("CENTER", 0, 0)
	end

	if addBorder then
		local capWidth, capHeight = unpack(PRESET.caps[preset].size)

		local firstCap = bar:CreateTexture(nil, "BORDER")
		firstCap:SetTexture(PRESET.texture)
		firstCap:SetTexCoord(unpack(PRESET.caps[preset].first))
		firstCap:SetSize(capWidth, capHeight)
		firstCap:SetPoint(unpack(PRESET.caps.first_point))

		local firstMid = bar:CreateTexture(nil, "BORDER")
		firstMid:SetTexture(PRESET.texture)
		firstMid:SetTexCoord(unpack(PRESET.middle.first))
		firstMid:SetPoint(unpack(PRESET.middle.first_point1))
		firstMid:SetPoint(unpack(PRESET.middle.first_point2))

		local secondMid = bar:CreateTexture(nil, "BORDER")
		secondMid:SetTexture(PRESET.texture)
		secondMid:SetTexCoord(unpack(PRESET.middle.second))
		secondMid:SetPoint(unpack(PRESET.middle.second_point1))
		secondMid:SetPoint(unpack(PRESET.middle.second_point2))

		local secondCap = bar:CreateTexture(nil, "BORDER")
		secondCap:SetTexture(PRESET.texture)
		secondCap:SetTexCoord(unpack(PRESET.caps[preset].second))
		secondCap:SetSize(capWidth, capHeight)
		secondCap:SetPoint(unpack(PRESET.caps.second_point))

		if orientation == "HORIZONTAL" then
			firstMid:SetHeight(3)
			secondMid:SetHeight(3)
		else
			firstMid:SetWidth(3)
			secondMid:SetWidth(3)
		end

		bar.Tube = {
			[1] = firstCap,
			[2] = firstMid,
			[3] = secondMid,
			[4] = secondCap,
		}
	end

	bar.styled = true

	return bar
end

function E:AddTooltipStatusBar(tooltip, index)
	local bar = E:CreateStatusBar(tooltip, "GameTooltipStatusBar"..index, "HORIZONTAL", "12", 0)
	bar:SetStatusBarColor(unpack(COLORS.green))
	E:CreateBorder(bar, 8)
	bar:SetBorderColor(unpack(COLORS.gray))

	tooltip.numStatusBars = index

	return bar
end

function E:ShowTooltipStatusBar(tooltip, min, max, value, ...)
	tooltip:AddLine(" ")

	local index = (tooltip.shownStatusBars or 0) + 1
	local bar = _G["GameTooltipStatusBar"..index] or E:AddTooltipStatusBar(tooltip, index)

	if not bar.styled then
		E:HandleStatusBar(bar)
	end

	bar:SetMinMaxValues(min, max)
	bar:SetValue(value)
	bar:SetStatusBarColor(...)
	bar:SetPoint("LEFT", tooltip:GetName().."TextLeft"..tooltip:NumLines(), "LEFT", 0, -2)
	bar:SetPoint("RIGHT", tooltip, "RIGHT", -9, 0)
	bar:Show()

	bar.Text:SetText(value.." / "..max)

	tooltip.shownStatusBars = index
	tooltip:SetMinimumWidth(140)
end
