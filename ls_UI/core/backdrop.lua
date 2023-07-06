local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF

-- Lua
local _G = getfenv(0)

-- Mine
function E:CreateBackdrop(parent)
	local backdrop = CreateFrame("Frame", nil, parent, "BackdropTemplate")
	backdrop:SetBackdrop({
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile = "Interface\\AddOns\\ls_Glass\\assets\\border",
		tile = true,
		tileEdge = true,
		tileSize = 8,
		edgeSize = 8,
		-- insets = {left = 4, right = 4, top = 4, bottom = 4},
	})

	-- the way Blizz position it creates really weird gaps, so fix it
	backdrop.Center:ClearAllPoints()
	backdrop.Center:SetPoint("TOPLEFT", backdrop.TopLeftCorner, "BOTTOMRIGHT", 0, 0)
	backdrop.Center:SetPoint("BOTTOMRIGHT", backdrop.BottomRightCorner, "TOPLEFT", 0, 0)

	backdrop:SetBackdropColor(0, 0, 0, 0.6)
	backdrop:SetBackdropBorderColor(0, 0, 0, 0.6)

	return backdrop
end
