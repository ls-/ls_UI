local _, ns = ...

local DEFAULT_CONFIG = {
	units = {
		player = {
			enabled = true,
			point = {"BOTTOM", "UIParent", "BOTTOM", -306 , 80},
		},
		pet = {
			enabled = true,
			point = {"RIGHT", "lsPlayerFrame" , "LEFT"},
		},
		target = {
			enabled = true,
			point = {"BOTTOMLEFT", "UIParent", "BOTTOM", 166, 336},
			long = true,
		},
		targettarget = {
			enabled = true,
			point = { "LEFT", "lsTargetFrame", "RIGHT", 14, 0 },
		},
		focus = {
			enabled = true,
			point = { "BOTTOMRIGHT", "UIParent", "BOTTOM", -166, 336},
			long = true,
		},
		focustarget = {
			enabled = true,
			point = { "RIGHT", "lsFocusFrame", "LEFT", -14, 0 },
		},
		party = {
			enabled = true,
			point = {"TOPLEFT", "CompactRaidFrameManager", "TOPRIGHT", 6, 0},
			attributes = {"showPlayer", true, "showParty", true, "showRaid", false, "point", "BOTTOM", "yOffset", 40},
			visibility = "party",
		},
		boss1 = {
			enabled = true,
			point = {"TOPRIGHT", "UIParent", "TOPRIGHT", -84, -240},
		},	
		boss2 = {
			enabled = true,
			point = {"TOP", "lsBoss1Frame", "BOTTOM", 0, -46},
		},
		boss3 = {
			enabled = true,
			point = {"TOP", "lsBoss2Frame", "BOTTOM", 0, -46},
		},
		boss4 = {
			enabled = true,
			point = {"TOP", "lsBoss3Frame", "BOTTOM", 0, -46},
		},
		boss5 = {
			enabled = true,
			point = {"TOP", "lsBoss4Frame", "BOTTOM", 0, -46},
		},
	},
	auratracker = {
		enabled = true,
		locked = false,
		showHeader = true,
		buffList = {},
		debuffList = {},
		point = {"CENTER", "UIParent", "CENTER", 0, 0},
	},
	minimap = {
		enabled = true,
		point = {"BOTTOM", "UIParent", "BOTTOM", 306, 86},
	},
	objectivetracker = {
		point = {"RIGHT", "UIParent", "RIGHT", -100, 0},
		locked = false,
	},
	infobars = {
		enabled = true,
		location = {
			enabled = true,
			point = {"TOPLEFT", "UIParent", "TOPLEFT", 6, -6},
		},
		memory = {
			enabled = true,
			point = {"LEFT", "lsLocationInfoBar", "RIGHT", 24, 0},
		},
		fps = {
			enabled = true,
			point = {"LEFT", "lsMemoryInfoBar", "RIGHT", 6, 0},
		},
		latency = {
			enabled = true,
			point = {"LEFT", "lsFPSInfoBar", "RIGHT", 6, 0},
		},
		bag = {
			enabled = true,
			point = {"LEFT", "lsLatencyInfoBar", "RIGHT", 24, 0},
		},
		clock = {
			enabled = true,
			point = {"TOPRIGHT", "UIParent", "TOPRIGHT", -6, -6},
		},
		mail = {
			enabled = true,
			point = {"RIGHT", "lsClockInfoBar", "LEFT", -6, 0},
		},
	},
	width = 0, 
	height = 0,
	playerclass = "",
}

local ConfigLoader = CreateFrame("Frame")
ConfigLoader:RegisterEvent("ADDON_LOADED")
ConfigLoader:RegisterEvent("PLAYER_LOGOUT")

local function lsConfigLoader_OnEvent(...)
	local _, event, arg3 = ...
	if event == "ADDON_LOADED" then
		if arg3 ~= "oUF_LS" then return end

		local function initDB(db, defaults)
			if type(db) ~= "table" then db = {} end
			if type(defaults) ~= "table" then return db end
			for k, v in pairs(defaults) do
				if type(v) == "table" then
					db[k] = initDB(db[k], v)
				elseif type(v) ~= type(db[k]) then
					db[k] = v
				end
			end
			return db
		end

		oUF_LS_CONFIG = initDB(oUF_LS_CONFIG, DEFAULT_CONFIG)
		ns.C = oUF_LS_CONFIG

		ns.C.width, ns.C.height = string.match((({GetScreenResolutions()})[GetCurrentResolution()] or ""), "(%d+).-(%d+)")
		ns.C.playerclass = select(2, UnitClass("player"))

		-- Minimap 
		LoadAddOn("Blizzard_TimeManager")
		lsMinimap_Initialize()

		-- Infobars
		lsInfobars_Initialize()
		
		-- Actionbars
		lsActionBars_Initialize()

		-- MicroMenu
		lsMicroMenu_Initialize()

		-- AuraTracker
		lsAuraTracker_Initialize()
		
		-- ObjectiveTracker
		lsOTDragHeader_Initialize()

		oUF:Factory(lsFactory)
	elseif event == "PLAYER_LOGOUT" then
		local function cleanDB(db, defaults)
			if type(db) ~= "table" then return {} end
			if type(defaults) ~= "table" then return db end
			for k, v in pairs(db) do
				if type(v) == "table" then
					if not next(cleanDB(v, defaults[k])) then
						db[k] = nil
					end
				elseif v == defaults[k] then
					db[k] = nil
				end
			end
			return db
		end

		oUF_LS_CONFIG = cleanDB(oUF_LS_CONFIG, DEFAULT_CONFIG)
	end
end

ConfigLoader:SetScript("OnEvent", lsConfigLoader_OnEvent)