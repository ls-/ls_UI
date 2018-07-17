local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)
local m_ceil = _G.math.ceil
local m_floor = _G.math.floor
local m_min = _G.math.min
local next = _G.next

-- Mine
function E:UpdateBarLayout(bar)
	local config = bar._config
	local xDir = config.x_growth == "RIGHT" and 1 or -1
	local yDir = config.y_growth == "UP" and 1 or -1
	local level = bar:GetFrameLevel() + 1
	local num = m_min(config.num, #bar._buttons)
	local width = config.width or config.size
	local height = config.height or config.size
	local wMult = m_min(num, config.per_row)
	local hMult = m_ceil(num / config.per_row)
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

	bar:SetSize(wMult * width + (wMult - 1) * config.spacing + 4, hMult * height + (hMult - 1) * config.spacing + 4)

	local mover = E.Movers:Get(bar, true)
	if mover then
		mover:UpdateSize()
	end

	for i, button in next, bar._buttons do
		button:ClearAllPoints()

		if i <= num then
			local col = (i - 1) % config.per_row
			local row = m_floor((i - 1) / config.per_row)

			button:SetParent(button._parent)
			button:SetFrameLevel(level)
			button:SetSize(width, height)
			button:SetPoint(initialAnchor, bar, initialAnchor, xDir * (2 + col * (config.spacing + width)), yDir * (2 + row * (config.spacing + height)))
		else
			button:SetParent(E.HIDDEN_PARENT)
		end
	end
end
