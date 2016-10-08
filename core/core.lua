local _, ns = ...

-- Lua
local _G = _G
local table = _G.table

-- Mine
local E, C, D, M, L, P = _G.CreateFrame("Frame", "LSEngine"), {}, {}, {}, {}, {} -- engine(event handler), config, defaults, media, locales, private
ns.E, ns.C, ns.D, ns.M, ns.L, ns.P = E, C, D, M, L, P

local modules = {}
local delayedModules = {}

function P.print(...)
	print("|cff1a9fc0ls:|r |cffffd200UI:|r", ...)
end

local print = P.print

function E:CreateFontString(parent, size, name, shadow, outline)
	local object = parent:CreateFontString(name, "ARTWORK", "LS"..size..(shadow and "Font_Shadow" or (outline and "Font_Outline" or "Font")))
	object:SetWordWrap(false)

	return object
end

function E:DebugHighlight(object)
	if not object.CreateTexture then
		object.tex = object:GetParent():CreateTexture(nil, "BACKGROUND", nil, -8)
	else
		object.tex = object:CreateTexture(nil, "BACKGROUND", nil, -8)
	end
	object.tex:SetAllPoints(object)
	object.tex:SetColorTexture(1, 0, 0.5, 0.4)
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

	object:SetParent(E.HIDDEN_PARENT)
	object:Hide()
end

function E:GetCoords(object)
	local p, anchor, rP, x, y = object:GetPoint()

	if not x then
		return p, anchor, rP, x, y
	else
		return p, anchor and anchor:GetName() or "UIParent", rP, E:Round(x), E:Round(y)
	end
end

local function EventHandler(self, event, ...)
	self[event](self, ...)
end

E:SetScript("OnEvent", EventHandler)

-- Some authors like to disable blizzard addons my UI utilises
function E:ForceLoadAddOn(name)
	local loaded, reason = _G.LoadAddOn(name)

	if not loaded then
		if reason == "DISABLED" then
			_G.EnableAddOn(name)

			E:ForceLoadAddOn(name)
		else
			print(_G.ADDON_LOAD_FAILED:format(name, _G["ADDON_"..reason]))
		end
	end
end

function E:AddModule(name, addEventHandler, isDelayed)
	local module = _G.CreateFrame("Frame", "LS"..name.."Module")

	if addEventHandler then
		module:SetScript("OnEvent", EventHandler)
	end

	if isDelayed then
		delayedModules[name] = module
	else
		modules[name] = module
	end

	return module
end

function E:GetModule(name)
	if not modules[name] and not delayedModules[name] then
		error("Module "..name.." doesn't exist!")
	end

	return modules[name] or delayedModules[name]
end

function E:InitializeModules()
	for name, module in next, modules do
		if not module.Initialize then
			print("Module "..name.." doesn\'t have initializer.")
		else
			module:Initialize()
		end
	end
end

function E:InitializeDelayedModules()
	for name, module in next, delayedModules do
		if not module.Initialize then
			print("Module "..name.." doesn\'t have initializer.")
		else
			module:Initialize()
		end
	end
end

_G.SLASH_RELOADUI1 = "/rl"
_G.SlashCmdList["RELOADUI"] = _G.ReloadUI

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
