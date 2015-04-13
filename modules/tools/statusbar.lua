local AddOn, ns = ...
local E, M = ns.E, ns.M

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
				if texture and strfind(texture, "Color") then
					background = region
				elseif texture and strfind(texture, "Background") then
					background = region
				else
					E:AlwaysHide(region)
				end
			else
				if region ~= sbt then
					E:AlwaysHide(region)
				end
			end
		elseif region:IsObjectType("FontString") then
			text = region
		end
	end

	local tbackground, ttext, tstatusbar

	for _, child in next, children do
		if child:IsObjectType("StatusBar") then
			tbackground, ttext, tsbt = self:HandleStatusBar(child, true)
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
		bar:SetSize(188, 18)

		if not background then
			background = bar:CreateTexture(nil, "BACKGROUND", nil, 0)
		end

		background:SetTexture(M.textures.statusbar)
		background:SetVertexColor(0.15, 0.15, 0.15, 1)
		background:SetAllPoints()

		if text then
			text:SetFont(M.font, 12)
			text:SetWordWrap(false)
			text:ClearAllPoints()
			text:SetPoint("LEFT", 2, 0)
			text:SetPoint("RIGHT", -2, 0)
			bar.Text = text
		end

		sbt:SetDrawLayer("BACKGROUND", 1)
		sbt:SetTexture(M.textures.statusbar)
		bar.Texture = sbt

		if sb ~= bar then
			sb:SetAllPoints()
		end

		E:CreateBorder(bar, 8)
	else
		return background, text, sbt
	end

end
