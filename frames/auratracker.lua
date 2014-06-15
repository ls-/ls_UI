local _, ns = ...
local C, M = ns.C, ns.M

local auraTracker = CreateFrame("Frame", "oUF_LSAuraTackerBar", UIParent, "SecureHandlerStateTemplate")
auraTracker:SetSize(220, 44)
auraTracker:SetPoint("CENTER", 0, 0)

ns.DebugTexture(auraTracker)