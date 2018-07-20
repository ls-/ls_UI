local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Blizzard")

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc

-- Blizz
local IsAddOnLoaded = _G.IsAddOnLoaded
local LoadAddOn = _G.LoadAddOn

--[[ luacheck: globals
	ArcheologyDigsiteProgressBar ArcheologyDigsiteProgressBar_OnUpdate

	UIPARENT_MANAGED_FRAME_POSITIONS
]]

-- Mine
local isInit = false

local function bar_OnEvent(self, event, num, total)
	if event == "ARCHAEOLOGY_SURVEY_CAST" or event == "ARCHAEOLOGY_FIND_COMPLETE" then
		self.Text:SetText(num .. " / ".. total)
	end
end

function MODULE:HasDigsiteBar()
	return isInit
end

function MODULE:SetUpDigsiteBar()
	if not isInit and C.db.char.blizzard.digsite_bar.enabled then
		local isLoaded = true

		if not IsAddOnLoaded("Blizzard_ArchaeologyUI") then
			isLoaded = LoadAddOn("Blizzard_ArchaeologyUI")
		end

		if isLoaded then
			ArcheologyDigsiteProgressBar.ignoreFramePositionManager = true
			UIPARENT_MANAGED_FRAME_POSITIONS["ArcheologyDigsiteProgressBar"] = nil

			E:HandleStatusBar(ArcheologyDigsiteProgressBar)
			ArcheologyDigsiteProgressBar:ClearAllPoints()
			ArcheologyDigsiteProgressBar:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 250)
			E.Movers:Create(ArcheologyDigsiteProgressBar)

			ArcheologyDigsiteProgressBar.Text:SetText("")
			ArcheologyDigsiteProgressBar.Texture:SetVertexColor(M.COLORS.ORANGE:GetRGB())

			hooksecurefunc("ArcheologyDigsiteProgressBar_OnEvent", bar_OnEvent)

			isInit = true

			self:UpdateDigsiteBar()
		end
	end
end

function MODULE:UpdateDigsiteBar()
	if isInit then
		local config = C.db.profile.blizzard.digsite_bar

		ArcheologyDigsiteProgressBar:SetSize(config.width, config.height)

		local mover = E.Movers:Get(ArcheologyDigsiteProgressBar, true)
		if mover then
			mover:UpdateSize()
		end

		E:SetStatusBarSkin(ArcheologyDigsiteProgressBar, "HORIZONTAL-" .. config.height)

		ArcheologyDigsiteProgressBar.Text:SetFontObject("LSFont" .. config.text.height .. "_Shadow")
	end
end
