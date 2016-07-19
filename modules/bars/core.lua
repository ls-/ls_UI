local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local B = E:AddModule("Bars", true)

-- Lua
local pairs = pairs

-- Mine

function B:IsEnabled()
	return B.isRunning
end

function B:ShowHotKeyText()
	for button in pairs(E:GetButtons()) do
		if button.HotKey then
			button.HotKey:Show()
		end
	end

	return true, "|cff26a526Success!|r Binding text is now shown."
end

function B:HideHotKeyText()
	for button in pairs(E:GetButtons()) do
		if button.HotKey then
			button.HotKey:Hide()
		end
	end

	return true, "|cff26a526Success!|r Binding text is now hidden."
end

function B:ShowMacroNameText()
	for button in pairs(E:GetButtons()) do
		if button.Name then
			button.Name:Show()
		end
	end

	return true, "|cff26a526Success!|r Macro text is now shown."
end

function B:HideMacroNameText()
	for button in pairs(E:GetButtons()) do
		if button.Name then
			button.Name:Hide()
		end
	end

	return true, "|cff26a526Success!|r Macro text is now hidden."
end

function B:Initialize()
	if C.bars.enabled then
		B:ActionBarController_Initialize()
		B:HandleActionBars()
		B:HandlePetBattleBar()
		B:HandleExtraActionButton()
		B:HandleGarrisonButton()
		B:HandleVehicleExitButton()
		B:HandleMicroMenu()
		B:HandleBags()

		B.isRunning = true
	end
end
