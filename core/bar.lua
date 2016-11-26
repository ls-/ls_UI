local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P

-- Lua
local _G = _G
local math = _G.math
local pairs = _G.pairs

-- Mine
function E:UpdateBarLayout(bar, buttons, bSize, bGap, initialAnchor, columns)
	local level = bar:GetFrameLevel() + 1
	local growthX = (initialAnchor == "TOPLEFT" or initialAnchor == "BOTTOMLEFT") and 1 or -1
	local growthY = (initialAnchor == "BOTTOMLEFT" or initialAnchor == "BOTTOMRIGHT") and 1 or -1
	columns = columns or #buttons

	bar:SetSize(columns * (bSize + bGap), math.ceil(#buttons / columns) * (bSize + bGap))

	for i = 1, #buttons do
		local button = buttons[i]
		button:ClearAllPoints()
		button:SetSize(bSize, bSize)

		local column = (i - 1) % columns
		local row = math.floor((i - 1) / columns)

		button:SetFrameLevel(level)
		button:SetPoint(initialAnchor, bar, initialAnchor,
			growthX * ((0.5 + column) * bGap + column * bSize),
			growthY * ((0.5 + row) * bGap + row * bSize))
	end
end
