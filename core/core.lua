local an, ns = ...

-- Lua
local _G = _G
local table = _G.table
local string = _G.string
local debugstack = _G.debugstack
local error = _G.error
local next = _G.next
local pairs = _G.pairs
local type = _G.type
local assert = _G.assert

-- Mine
local E, C, D, M, L, P = {}, {}, {}, {}, {}, {} -- engine, config, defaults, media, locales, private
ns.E, ns.C, ns.D, ns.M, ns.L, ns.P = E, C, D, M, L, P

------------
-- PUBLIC --
------------

local exportTable = {
	[1] = ns.E,
	[2] = ns.C,
	[3] = ns.M
}

_G[an] = exportTable

-----------
-- DEBUG --
-----------

local function print(...)
	_G.print("|cff1a9fc0ls:|r |cffffd200UI:|r", ...)
end

P.print = print

local function argcheck(varNum, varValue, ...)
	assert(type(varNum) == "number", string.format("Bad argument #1 to 'argcheck' ('number' expected, got '%s')", type(varNum)))

	for _, varType in pairs({...}) do
		if type(varValue) == varType then return end
	end

	local varTypes = string.join("', '", ...)
	local funcName = debugstack(2, 2, 0):match(": in function [`'<](.-)[`'>]"):match("("..an..".+)")

	error(string.format("Bad argument #%d to '%s' ('%s' expected, got '%s')", varNum, funcName, varTypes, type(varValue)), 4)
end

P.argcheck = argcheck

function P:DebugHighlight(object)
	if not object.CreateTexture then
		object.tex = object:GetParent():CreateTexture(nil, "BACKGROUND", nil, -8)
	else
		object.tex = object:CreateTexture(nil, "BACKGROUND", nil, -8)
	end
	object.tex:SetAllPoints(object)
	object.tex:SetColorTexture(1, 0, 0.5, 0.4)
end

------------
-- EVENTS --
------------

local dispatcher = _G.CreateFrame("Frame")
local oneTimeEvents = {ADDON_LOADED = false, PLAYER_LOGIN = false}
local registeredEvents = {}

local function OnEvent(_, event, ...)
	for func in pairs(registeredEvents[event]) do
		func(...)
	end

	if oneTimeEvents[event] == false then
		oneTimeEvents[event] = true
	end
end

dispatcher:SetScript("OnEvent", OnEvent)

local function Register(event, func, unit1, unit2)
	argcheck(1, event, "string")
	argcheck(2, func, "function")
	argcheck(3, unit1, "string", "nil")
	argcheck(4, unit2, "string", "nil")

	if oneTimeEvents[event] then
		error(string.format("Failed to register for '%s' event, already fired!", event), 3)
	end

	if not registeredEvents[event] then
		registeredEvents[event] = {}

		if unit1 then
			dispatcher:RegisterUnitEvent(event, unit1, unit2)
		else
			dispatcher:RegisterEvent(event)
		end
	end

	registeredEvents[event][func] = true
end

local function Unregister(event, func)
	argcheck(1, event, "string")
	argcheck(2, func, "function")

	local funcs = registeredEvents[event]

	if funcs and funcs[func] then
		funcs[func] = nil

		if not next(funcs) then
			registeredEvents[event] = nil

			dispatcher:UnregisterEvent(event)
		end
	end
end

function E.RegisterEvent(_, ...)
	Register(...)
end

function E.UnregisterEvent(_, ...)
	Unregister(...)
end

-----------
-- UTILS --
-----------

function E:CreateFontString(parent, size, name, shadow, outline)
	local object = parent:CreateFontString(name, "ARTWORK", "LS"..size..(shadow and "Font_Shadow" or (outline and "Font_Outline" or "Font")))
	object:SetWordWrap(false)

	return object
end

function E:ForceShow(object)
	if not object then return end

	object:Show()

	object.Hide = object.Show
end

function E:ForceHide(object)
	if not object then return end

	if object.UnregisterAllEvents then
		object:UnregisterAllEvents()

		if object:GetName() then
			_G.UIPARENT_MANAGED_FRAME_POSITIONS[object:GetName()] = nil
		end
	end

	object:SetParent(self.HIDDEN_PARENT)
	object:Hide()
end

function E:GetCoords(object)
	local p, anchor, rP, x, y = object:GetPoint()

	if not x then
		return p, anchor, rP, x, y
	else
		return p, anchor and anchor:GetName() or "UIParent", rP, self:Round(x), self:Round(y)
	end
end

function E:GetScreenQuadrant(frame)
	local x, y = frame:GetCenter()

	if not (x and y) then
		return "UNKNOWN"
	end

	local screenWidth = _G.UIParent:GetRight()
	local screenHeight = _G.UIParent:GetTop()
	local screenLeft = screenWidth / 3
	local screenRight = screenWidth * 2 / 3

	if y >= screenHeight * 2 / 3 then
		if x <= screenLeft then
			return "TOPLEFT"
		elseif x >= screenRight then
			return "TOPRIGHT"
		else
			return "TOP"
		end
	elseif y <= screenHeight / 3 then
		if x <= screenLeft then
			return "BOTTOMLEFT"
		elseif x >= screenRight then
			return "BOTTOMRIGHT"
		else
			return "BOTTOM"
		end
	else
		if x <= screenLeft then
			return "LEFT"
		elseif x >= screenRight then
			return "RIGHT"
		else
			return "CENTER"
		end
	end
end

_G.SLASH_RELOADUI1 = "/rl"
_G.SlashCmdList["RELOADUI"] = _G.ReloadUI

-------------
-- MODULES --
-------------

local modules = {}

function P:AddModule(name)
	modules[name] = {}

	return modules[name]
end

function P:GetModule(name)
	if not modules[name] then
		print("Module "..name.." doesn't exist!")
	else
		return modules[name]
	end
end

function P:InitModules()
	for name, module in next, modules do
		if not module.Init then
			print("Module "..name.." doesn\'t have initializer.")
		else
			module:Init()
		end
	end
end

--------------------------
-- ADDON SPECIFIC STUFF --
--------------------------

local onLoadTasks = {}

_G.hooksecurefunc("LoadAddOn", function(addonName)
	local tasks = onLoadTasks[addonName]

	if tasks then
		if not _G.IsAddOnLoaded(addonName) then return end

		for i = 1, #tasks do
			tasks[i]()
		end
	end
end)

function E:AddOnLoadTask(addonName, func)
	onLoadTasks[addonName] = onLoadTasks[addonName] or {}

	table.insert(onLoadTasks[addonName], func)
end

-----------------
-- FRAME QUEUE --
-----------------

local queue = {} -- frame = {state = "string, condition = "string" or "nil"}
local frames = {}

local function Process(frame, state, condition)
	if condition then
		_G.RegisterStateDriver(frame, state, condition)
	else
		frame[state](frame)
	end
end

local function ManageQueue()
	for frame, t in pairs(queue) do
		Process(frame, t.state, t.condition)

		queue[frame] = nil
	end
end

E:RegisterEvent("PLAYER_REGEN_ENABLED", ManageQueue)

function E:SaveFrameState(frame, state, condition)
	if not frames[frame] then
		frames[frame] = {}
	end

	frames[frame][state] = condition
end

function E:ResetFrameState(frame, state)
	if frames[frame] and frames[frame][state] then
		return self:SetFrameState(frame, state, frames[frame][state])
	end

	return nil
end

function E:SetFrameState(frame, state, condition)
	if frame then
		P.argcheck(2, state, "string")
		P.argcheck(3, condition, "string", "nil")

		if _G.InCombatLockdown() and frame:IsProtected() then
			queue[frame] = {state = state, condition = condition}

			return false, frame, state, condition
		else
			Process(frame, state, condition)

			return true, frame, state, condition
		end
	end
end

--------------------
-- SLASH COMMANDS --
--------------------

local commands = {}

_G.SLASH_LSUI1 = "/lsui"
_G.SlashCmdList["LSUI"] = function(msg)
	msg = string.gsub(msg, "^ +", "")
	local command, arg = string.split(" ", msg, 2)
	arg = arg and string.gsub(arg, " ", "")

	if commands[command] then
		commands[command].func(arg)
	else
		P.print("Unknown command:", command)
	end
end

function P:AddCommand(command, handler, desc)
	commands[command] = {func = handler, desc = desc or "no description"}
end

P:AddCommand("help", function()
	P.print(L["LIST_OF_COMMANDS_COLON"])

	for k, v in pairs(commands) do
		if k ~= "help" and k ~= "" then
			P.print("/lsui", k, v.desc)
		end
	end
end)
