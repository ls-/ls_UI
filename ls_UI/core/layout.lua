local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF

-- Lua
local _G = getfenv(0)
local m_ceil = _G.math.ceil
local m_floor = _G.math.floor
local m_min = _G.math.min
local next = _G.next

-- Mine
E.Layout = {}

function E.Layout:Update(frame, config)
	config = config or frame._config
	local children = frame._buttons or frame._children

	local childLevel = frame:GetFrameLevel() + 1
	local xDir = config.x_growth == "RIGHT" and 1 or -1
	local yDir = config.y_growth == "UP" and 1 or -1
	local num = m_min(config.num, #children)
	local width = config.width or config.size
	local widthMult = m_min(num, config.per_row)
	local xSpacing = config.x_spacing or config.spacing
	local height = config.height or config.size
	local heightMult = m_ceil(num / config.per_row)
	local ySpacing = config.y_spacing or config.spacing

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

	frame:SetSize(widthMult * width + (widthMult - 1) * xSpacing + 4,
		heightMult * height + (heightMult - 1) * ySpacing + 4)

	frame:SetScale(config.scale or 1)

	local mover = E.Movers:Get(frame, true)
	if mover then
		mover:UpdateSize()
	end

	for i, child in next, children do
		child:ClearAllPoints()

		if i <= num then
			local col = (i - 1) % config.per_row
			local row = m_floor((i - 1) / config.per_row)

			child:SetParent(child._parent)
			child:SetFrameLevel(childLevel)
			child:SetSize(width, height)
			child:SetPoint(initialAnchor, frame, initialAnchor,
				xDir * (2 + col * (xSpacing + width)),
				yDir * (2 + row * (ySpacing + height))
			)
		else
			child:SetParent(E.HIDDEN_PARENT)
		end
	end
end
