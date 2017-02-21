local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)
local string = _G.string
local unpack = _G.unpack

function E:HandleStatusBar(bar, cascade)
	local children = {bar:GetChildren()}
	local regions = {bar:GetRegions()}

	local sbt = bar.GetStatusBarTexture and bar:GetStatusBarTexture()

	-- print("====", bar:GetName(), #children, #regions, "====")

	local texture, layer, background, text, sb

	for _, region in next, regions do
		if region:IsObjectType("Texture") then
			texture, layer = region:GetTexture(), region:GetDrawLayer()
			if layer == "BACKGROUND" then
				if texture and string.find(texture, "Color") then
					background = region
				elseif texture and string.find(texture, "Background") then
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
			tbackground, ttext, tsbt = E:HandleStatusBar(child, true)
		end
	end

	background = background or tbackground
	text = text or ttext
	sbt = sbt or tsbt
	sb = sbt:GetParent()

	-- print(cascade and "CASCADE!!" or "")
	-- print("|cffffff7fBG|r", not not background, "|cffffff7fTEXT|r", not not text, "|cffffff7fSBT|r", not not sbt, "|cffffff7fSB|r", not not sb)

	if not cascade then
		bar.ignoreFramePositionManager = true
		bar:SetSize(166, 12)

		if not background then
			background = bar:CreateTexture(nil, "BACKGROUND")
		end
		background:SetColorTexture(M.COLORS.DARK_GRAY:GetRGB())
		background:SetAllPoints()
		bar.Bg = background

		if not text then
			text = E:CreateFontString(bar, 12, "$parentText", true)
		else
			text:SetFontObject("LS12Font_Shadow")
			text:SetWordWrap(false)
			text:SetJustifyV("MIDDLE")
		end

		text:SetDrawLayer("ARTWORK")
		text:ClearAllPoints()
		text:SetPoint("TOPLEFT", 1, 0)
		text:SetPoint("BOTTOMRIGHT", -1, 0)
		bar.Text = text

		sbt:SetTexture("Interface\\BUTTONS\\WHITE8X8")
		bar.Texture = sbt

		if sb ~= bar then
			sb:SetAllPoints()
		end

		local gloss = bar:CreateTexture(nil, "ARTWORK", nil, 6)
		gloss:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar_horizontal")
		gloss:SetTexCoord(0 / 64, 64 / 64, 0 / 64, 20 / 64)
		gloss:SetAllPoints()
		bar.Gloss = gloss

		bar.styled = true
	else
		return background, text, sbt
	end
end

function E:CreateStatusBar(parent, name, orientation)
	local bar = _G.CreateFrame("StatusBar", name, parent)
	bar:SetOrientation(orientation)
	bar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")

	local bg = bar:CreateTexture(nil, "BACKGROUND")
	bg:SetColorTexture(M.COLORS.DARK_GRAY:GetRGB())
	bg:SetAllPoints()
	bar.Bg = bg

	local gloss = bar:CreateTexture(nil, "ARTWORK", nil, 6)
	gloss:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar_horizontal")
	gloss:SetTexCoord(0 / 64, 64 / 64, 0 / 64, 20 / 64)
	gloss:SetAllPoints()
	bar.Gloss = gloss

	local text = E:CreateFontString(bar, 12, "$parentText", true)
	bar.Text = text

	bar.styled = true

	return bar
end

function E:AddTooltipStatusBar(tooltip, index)
	local bar = E:CreateStatusBar(tooltip, "GameTooltipStatusBar"..index, "HORIZONTAL")
	bar:SetStatusBarColor(M.COLORS.GREEN:GetRGB())
	bar:SetHeight(10)

	bar.Text:SetPoint("CENTER", 0, 0)

	tooltip.numStatusBars = index

	return bar
end

function E:ShowTooltipStatusBar(tooltip, min, max, value, ...)
	tooltip:AddLine(" ")

	local index = (tooltip.shownStatusBars or 0) + 1
	local bar = _G["GameTooltipStatusBar"..index] or E:AddTooltipStatusBar(tooltip, index)

	if not bar.styled then
		E:HandleStatusBar(bar)
		E:CreateBorder(bar)
	end

	bar:SetMinMaxValues(min, max)
	bar:SetValue(value)
	bar:SetStatusBarColor(...)
	bar:SetPoint("TOPLEFT", tooltip:GetName().."TextLeft"..tooltip:NumLines(), "TOPLEFT", 0, -2)
	bar:SetPoint("RIGHT", tooltip, "RIGHT", -10, 0)
	bar:Show()

	bar.Text:SetText(value.." / "..max)

	tooltip.shownStatusBars = index
	tooltip:SetMinimumWidth(140)
end

-- flags: "HORIZONTAL-M", "HORIZONTAL-L", "VERTICAL-M", "VERTICAL-L", "VERTICAL-GLASS", "NONE"
function E:SetStatusBarSkin_new(object, flag)
	P.argcheck(1, object, "table")
	P.argcheck(2, flag, "string")

	local s, v = string.split("-", flag)

	object.Tube = object.Tube or {
		[1] = object:CreateTexture(nil, "ARTWORK", nil, 7), -- left/top
		[2] = object:CreateTexture(nil, "ARTWORK", nil, 7), -- mid
		[3] = object:CreateTexture(nil, "ARTWORK", nil, 7), -- right/bottom
		[4] = object.Glass or object:CreateTexture(nil, "ARTWORK", nil, 6), -- glass
	}

	if s == "HORIZONTAL" then
		local glass = object.Tube[4]
		glass:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar-horizontal")
		glass:SetTexCoord(0 / 128, 128 / 128, 1 / 256, 25 / 256)
		glass:SetAllPoints()

		if v == "GLASS" then
			object.Tube[1]:SetTexture(nil)
			object.Tube[2]:SetTexture(nil)
			object.Tube[3]:SetTexture(nil)
		elseif v == "M" or v == "L" then
			local left = object.Tube[1]
			left:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar-horizontal")
			left:ClearAllPoints()
			left:SetPoint("RIGHT", object, "LEFT", 10 / 2, 0)

			local right = object.Tube[3]
			right:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar-horizontal")
			right:ClearAllPoints()
			right:SetPoint("LEFT", object, "RIGHT", -10 / 2, 0)

			local mid = object.Tube[2]
			mid:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar-horizontal", true)
			mid:SetHorizTile(true)
			mid:ClearAllPoints()
			mid:SetPoint("TOPLEFT", left, "TOPRIGHT")
			mid:SetPoint("BOTTOMRIGHT", right, "BOTTOMLEFT")

			if v == "M" then
				left:SetTexCoord(1 / 128, 29 / 128, 108 / 256, 144 / 256)
				left:SetSize(14.0, 18.0)

				right:SetTexCoord(30 / 128, 58 / 128, 108 / 256, 144 / 256)
				right:SetSize(14.0, 18.0)

				mid:SetTexCoord(0 / 128, 128 / 128, 26 / 256, 62 / 256)
			elseif v == "L" then
				left:SetTexCoord(59 / 128, 89 / 128, 108 / 256, 152 / 256)
				left:SetSize(15.0, 22.0)

				right:SetTexCoord(90 / 128, 120 / 128, 108 / 256, 152 / 256)
				right:SetSize(15.0, 22.0)

				mid:SetTexCoord(0 / 128, 128 / 128, 63 / 256, 107 / 256)
			end
		else
			P.print("Invalid flag:", flag)
		end
	elseif s == "VERTICAL" then
		local glass = object.Tube[4]
		glass:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar-vertical")
		glass:SetTexCoord(1 / 256, 25 / 256, 0 / 128, 128 / 128)
		glass:SetAllPoints()

		if v == "GLASS" then
			object.Tube[1]:SetTexture(nil)
			object.Tube[2]:SetTexture(nil)
			object.Tube[3]:SetTexture(nil)
		elseif v == "M" or v == "L" then
			local top = object.Tube[1]
			top:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar-vertical")
			top:ClearAllPoints()
			top:SetPoint("BOTTOM", object, "TOP", 0, -10 / 2)

			local bottom = object.Tube[3]
			bottom:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar-vertical")
			bottom:ClearAllPoints()
			bottom:SetPoint("TOP", object, "BOTTOM", 0, 10 / 2)

			local mid = object.Tube[2]
			mid:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar-vertical", true)
			mid:SetVertTile(true)
			mid:ClearAllPoints()
			mid:SetPoint("TOPLEFT", top, "BOTTOMLEFT")
			mid:SetPoint("BOTTOMRIGHT", bottom, "TOPRIGHT")

			if v == "M" then
				top:SetTexCoord(108 / 256, 144 / 256, 1 / 128, 29 / 128)
				top:SetSize(36 / 2, 28 / 2)

				bottom:SetTexCoord(108 / 256, 144 / 256, 30 / 128, 58 / 128)
				bottom:SetSize(36 / 2, 28 / 2)

				mid:SetTexCoord(26 / 256, 62 / 256, 0 / 128, 128 / 128)
			elseif v == "L" then
				top:SetTexCoord(108 / 256, 152 / 256, 58 / 128, 88 / 128)
				top:SetSize(44 / 2, 30 / 2)

				bottom:SetTexCoord(108 / 256, 152 / 256, 89 / 128, 119 / 128)
				bottom:SetSize(44 / 2, 30 / 2)

				mid:SetTexCoord(63 / 256, 107 / 256, 0 / 128, 128 / 128)
			end
		else
			P.print("Invalid flag:", flag)
		end
	elseif s == "NONE" then
		object.Tube[1]:SetTexture(nil)
		object.Tube[2]:SetTexture(nil)
		object.Tube[3]:SetTexture(nil)
		object.Tube[4]:SetTexture(nil)
	else
		P.print("Invalid flag:", flag)
	end
end

-- skinType: "HORIZONTAL-S", "HORIZONTAL-M", "HORIZONTAL-L", "VERTICAL-S", "VERTICAL-M", "VERTICAL-L"
function E:SetStatusBarSkin(bar, skinType)
	local orientation, size = strsplit("-", skinType or "")

	bar.Tube = bar.Tube or {
		[1] = bar:CreateTexture(nil, "ARTWORK", nil, 7), -- left
		[2] = bar:CreateTexture(nil, "ARTWORK", nil, 7), -- right
		[3] = bar:CreateTexture(nil, "ARTWORK", nil, 7), -- top
		[4] = bar:CreateTexture(nil, "ARTWORK", nil, 7), -- bottom
		[5] = bar.Gloss or bar:CreateTexture(nil, "ARTWORK", nil, 6), -- gloss
	}

	if orientation == "HORIZONTAL" then
		local leftTexture = bar.Tube[1]
		leftTexture:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar_horizontal")
		leftTexture:SetPoint("RIGHT", bar, "LEFT", 3, 0)

		local rightTexture = bar.Tube[2]
		rightTexture:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar_horizontal")
		rightTexture:SetPoint("LEFT", bar, "RIGHT", -3, 0)

		local topTexture = bar.Tube[3]
		topTexture:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar_horizontal", true)
		topTexture:SetTexCoord(0 / 64, 64 / 64, 21 / 64, 24 / 64)
		topTexture:SetHeight(3)
		topTexture:SetHorizTile(true)
		topTexture:SetPoint("BOTTOMLEFT", bar, "TOPLEFT", 0, 0)
		topTexture:SetPoint("BOTTOMRIGHT", bar, "TOPRIGHT", 0, 0)

		local bottomTexture = bar.Tube[4]
		bottomTexture:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar_horizontal", true)
		bottomTexture:SetTexCoord(0 / 64, 64 / 64, 24 / 64, 21 / 64)
		bottomTexture:SetHeight(3)
		bottomTexture:SetHorizTile(true)
		bottomTexture:SetPoint("TOPLEFT", bar, "BOTTOMLEFT", 0, 0)
		bottomTexture:SetPoint("TOPRIGHT", bar, "BOTTOMRIGHT", 0, 0)

		local gloss = bar.Tube[5]
		gloss:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar_horizontal")
		gloss:SetTexCoord(0 / 64, 64 / 64, 0 / 64, 20 / 64)
		gloss:SetAllPoints()

		if size == "SMALL" or size == "S" then
			leftTexture:SetTexCoord(0 / 64, 10 / 64, 25 / 64, 35 / 64)
			leftTexture:SetSize(10, 10)

			rightTexture:SetTexCoord(0 / 64, 10 / 64, 36 / 64, 46 / 64)
			rightTexture:SetSize(10, 10)
		elseif size == "M" then
			leftTexture:SetTexCoord(33 / 64, 42 / 64, 25 / 64, 41 / 64)
			leftTexture:SetSize(9, 16)

			rightTexture:SetTexCoord(43 / 64, 52 / 64, 25 / 64, 41 / 64)
			rightTexture:SetSize(9, 16)
		elseif size == "BIG" or size == "L" then
			leftTexture:SetTexCoord(11 / 64, 21 / 64, 25 / 64, 45 / 64)
			leftTexture:SetSize(10, 20)

			rightTexture:SetTexCoord(22 / 64, 32 / 64, 25 / 64, 45 / 64)
			rightTexture:SetSize(10, 20)
		end
	elseif orientation == "VERTICAL" then
		local leftTexture = bar.Tube[1]
		leftTexture:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar_vertical", true)
		leftTexture:SetTexCoord(21 / 64, 24 / 64, 0 / 64, 64 / 64)
		leftTexture:SetWidth(3)
		leftTexture:SetVertTile(true)
		leftTexture:SetPoint("TOPRIGHT", bar, "TOPLEFT", 0, 0)
		leftTexture:SetPoint("BOTTOMRIGHT", bar, "BOTTOMLEFT", 0, 0)

		local rightTexture = bar.Tube[2]
		rightTexture:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar_vertical", true)
		rightTexture:SetTexCoord(24 / 64, 21 / 64, 0 / 64, 64 / 64)
		rightTexture:SetWidth(3)
		rightTexture:SetVertTile(true)
		rightTexture:SetPoint("TOPLEFT", bar, "TOPRIGHT", 0, 0)
		rightTexture:SetPoint("BOTTOMLEFT", bar, "BOTTOMRIGHT", 0, 0)

		local topTexture = bar.Tube[3]
		topTexture:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar_vertical")
		topTexture:SetPoint("BOTTOM", bar, "TOP", 0, -3)

		local bottomTexture = bar.Tube[4]
		bottomTexture:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar_vertical")
		bottomTexture:SetPoint("TOP", bar, "BOTTOM", 0, 3)

		local gloss = bar.Tube[5]
		gloss:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar_vertical")
		gloss:SetTexCoord(0 / 64, 20 / 64, 0 / 64, 64 / 64)
		gloss:SetAllPoints()

		if size == "S" then
			topTexture:SetTexCoord(25 / 64, 35 / 64, 0 / 64, 10 / 64)
			topTexture:SetSize(10, 10)

			bottomTexture:SetTexCoord(36 / 64, 46 / 64, 0 / 64, 10 / 64)
			bottomTexture:SetSize(10, 10)
		elseif size == "M" then
			topTexture:SetTexCoord(25 / 64, 41 / 64, 33 / 64, 42 / 64)
			topTexture:SetSize(16, 9)

			bottomTexture:SetTexCoord(25 / 64, 41 / 64, 43 / 64, 52 / 64)
			bottomTexture:SetSize(16, 9)
		elseif size == "L" then
			topTexture:SetTexCoord(25 / 64, 45 / 64, 11 / 64, 21 / 64)
			topTexture:SetSize(20, 10)

			bottomTexture:SetTexCoord(25 / 64, 45 / 64, 22 / 64, 32 / 64)
			bottomTexture:SetSize(20, 10)
		end
	elseif orientation == "NONE" then
		bar.Tube[1]:SetTexture(nil)
		bar.Tube[2]:SetTexture(nil)
		bar.Tube[3]:SetTexture(nil)
		bar.Tube[4]:SetTexture(nil)
		bar.Tube[5]:SetTexture(nil)
	end
end

E.SetBarSkin = E.SetStatusBarSkin
E.SetBarSkin_new = E.SetStatusBarSkin_new

for i = 1, 6 do
	E:AddTooltipStatusBar(_G.GameTooltip, i)
end
