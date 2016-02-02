local AddOn, ns = ...
local E, C, D, M, L = CreateFrame("Frame", "LSEngine"), {}, {}, {}, {} -- engine(event handler), config, defaults, media, locales
ns.E, ns.C, ns.D, ns.M, ns.L = E, C, D, M, L

E.width, E.height = string.match(GetCVar("gxResolution"), "(%d+)x(%d+)")
E.playerclass = select(2, UnitClass("player"))

function E:PLAYER_ENTERING_WORLD()
	E.playerspec = tostring(GetSpecialization() or 0)

	E:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function E:PLAYER_SPECIALIZATION_CHANGED()
	E.playerspec = tostring(GetSpecialization() or 0)
end

E:RegisterEvent("PLAYER_ENTERING_WORLD")
E:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")

function E:CreateFontString(parent, size, name, shadow, outline, wrap, ...)
	local r, g, b, a = ...

	local object = parent:CreateFontString(name, "OVERLAY", outline and "LS"..size.."Font_Outline" or "LS"..size.."Font")
	object:SetTextColor(r or 1, g or 1, b or 1, a or 1)
	object:SetWordWrap(wrap or false)

    if shadow then
        object:SetShadowColor(0, 0, 0)
        object:SetShadowOffset(1, -1)
    end

	return object
end

function E:CreateNewFontString(parent, size, name, outline, shadow, sublevel)
	local object = parent:CreateFontString(name, "OVERLAY", outline and "LS"..size.."Font_Outline" or (shadow and "LS"..size.."Font_Shadow" or "LS"..size.."Font"), sublevel or 0)
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
	object.tex:SetTexture(1, 0, 0.5, 0.4)
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
	end

	object:SetParent(M.HiddenParent)

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

-- Some authors like to disable blizzard addons my UI utilises
function E:ForceLoadAddOn(name)
	local loaded, reason = LoadAddOn(name)

	if not loaded then
		if reason == "DISABLED" then
			EnableAddOn(name)

			E:ForceLoadAddOn(name)
		else
			print(format(ADDON_LOAD_FAILED, name, _G["ADDON_"..reason]))
		end
	end
end

function E:EventHandler(event, ...)
	self[event](self, ...)
end

function E:AddModule(name, addEventHandler)
	local module = CreateFrame("Frame", "LS"..name.."Module")

	if addEventHandler then
		module:SetScript("OnEvent", E.EventHandler)
	end

	if not E.Modules then
		E.Modules = {}
	end

	E.Modules[name] = module

	return module
end

function E:GetModule(name)
	if not E.Modules[name] then
		error("Module "..name.." doesn't exist!")
	end

	return E.Modules[name]
end

function E:InitializeModules()
	for name, module in next, E.Modules do
		if not module.Initialize then
			print("Module "..name.." doesn\'t have initializer.")
		else
			module:Initialize()
		end
	end
end

SLASH_RELOADUI1 = "/rl"
SlashCmdList.RELOADUI = ReloadUI
