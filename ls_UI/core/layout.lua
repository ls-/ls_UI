local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF, Profiler = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF, ns.Profiler

-- Lua
local _G = getfenv(0)
local collectgarbage = _G.collectgarbage
local debugprofilestop = _G.debugprofilestop
local m_ceil = _G.math.ceil
local m_floor = _G.math.floor
local m_min = _G.math.min
local next = _G.next

-- Mine
E.Layout = {}

function E.Layout:Update(frame, config)
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	config = config or frame._config
	local children = frame._buttons or frame._children

	local childLevel = frame:GetFrameLevel() + 1
	local xDir = config.x_growth == "RIGHT" and 1 or -1
	local yDir = config.y_growth == "UP" and 1 or -1
	local num = m_min(config.num, #children)
	local width = config.width or config.size
	local widthMult = m_min(num, config.per_row)
	local height = config.height or config.size
	local heightMult = m_ceil(num / config.per_row)

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

	frame:SetSize(widthMult * width + (widthMult - 1) * config.spacing + 4,
		heightMult * height + (heightMult - 1) * config.spacing + 4)

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
				xDir * (2 + col * (config.spacing + width)),
				yDir * (2 + row * (config.spacing + height)))
		else
			child:SetParent(E.HIDDEN_PARENT)
		end
	end

	if Profiler:IsLogging() then
		Profiler:Log("E.Layout", "Update", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end
