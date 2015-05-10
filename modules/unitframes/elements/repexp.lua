local _, ns = ...
local E, C, M = ns.E, ns.C, ns.M

local UF = E.UF

local function Bar_OnEnter(self)
	self.Value:SetAlpha(1)
end

local function Bar_OnLeave(self)
	self.Value:SetAlpha(0)
end

local function PostUpdateBar(self)
	self.Value:UpdateTag()
end

function UF:CreateRepExpBar(parent, type)
	local bar = CreateFrame("StatusBar", "LS"..type.."Bar", parent)
	bar:SetStatusBarTexture(M.textures.statusbar)
	bar:SetFrameLevel(4)
	bar:SetSize(378, 8)
	bar:SetScript("OnEnter", Bar_OnEnter)
	bar:SetScript("OnLeave", Bar_OnLeave)

	local bg = bar:CreateTexture(nil, "BACKGROUND", nil, 0)
	bg:SetTexture(0.25, 0.25, 0.25, 0.5)
	bg:SetAllPoints()

	local border = bar:CreateTexture(nil, "ARTWORK", nil, 1)
	border:SetTexture("Interface\\AddOns\\oUF_LS\\media\\exp_rep_border")
	border:SetPoint("CENTER")

	local value = E:CreateFontString(bar, 10, "$parentValue", true)
	value:SetAllPoints()
	value:SetAlpha(0)
	bar.Value = value

	if type == "Exp" then
		bar:SetStatusBarColor(0.11, 0.75, 0.95)

		local rest = CreateFrame("StatusBar", nil, bar)
		rest:SetStatusBarTexture(M.textures.statusbar)
		rest:SetStatusBarColor(0.1, 0.4, 1, 0.7)
		rest:SetAllPoints()
		bar.Rested = rest

		parent:Tag(value, COMBAT_XP_GAIN.." [curxp] / [maxxp]")
	else
		border:SetVertexColor(0.4, 0.4, 0.4)
		border:SetTexCoord(0, 1, 1, 0)

		parent:Tag(value, "[reputation] [currep] / [maxrep]")

		bar.colorStanding = true
	end

	bar.PostUpdate = PostUpdateBar

	return bar
end
