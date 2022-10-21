local _, ns = ...
local E, C, PrC, M, L, P = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Blizzard")

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc

-- Mine
local isInit = false

function MODULE:HasDigsiteBar()
	return isInit
end

function MODULE:SetUpDigsiteBar()
	if not isInit and PrC.db.profile.blizzard.digsite_bar.enabled then
		local isLoaded = true
		if not IsAddOnLoaded("Blizzard_ArchaeologyUI") then
			isLoaded = LoadAddOn("Blizzard_ArchaeologyUI")
		end

		if isLoaded then
			ArcheologyDigsiteProgressBar.ignoreFramePositionManager = true

			E:HandleStatusBar(ArcheologyDigsiteProgressBar)

			local point = C.db.profile.blizzard.digsite_bar.point
			ArcheologyDigsiteProgressBar:ClearAllPoints()
			ArcheologyDigsiteProgressBar:SetPoint(point.p, point.anchor, point.rP, point.x, point.y)
			E.Movers:Create(ArcheologyDigsiteProgressBar)

			ArcheologyDigsiteProgressBar.Text:SetText("")
			ArcheologyDigsiteProgressBar.Texture:SetVertexColor(E:GetRGB(C.db.global.colors.orange))

			hooksecurefunc("ArcheologyDigsiteProgressBar_OnEvent", function(self, event, num, total)
				if event == "ARCHAEOLOGY_SURVEY_CAST" or event == "ARCHAEOLOGY_FIND_COMPLETE" then
					self.Text:SetText(num .. " / ".. total)
				end
			end)

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

		ArcheologyDigsiteProgressBar.Text:UpdateFont(config.text.size)
	end
end
