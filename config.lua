local _, ns = ...

local DEFAULT_CONFIG = {
	units = {
		player = {
			point = { "BOTTOM", "UIParent", "BOTTOM", -306 , 80 },
		},
		pet = {
			point = {"RIGHT", "oUF_LSPlayerFrame" , "LEFT"},
		},
		target = {
			point = {"BOTTOMLEFT", "UIParent", "BOTTOM", 166, 336},
			long = true,
		},
		targettarget = {
			point = { "LEFT", "oUF_LSTargetFrame", "RIGHT", 14, 0 },
		},
		focus = {
			point = { "BOTTOMRIGHT", "UIParent", "BOTTOM", -166, 336},
			long = true,
		},
		focustarget = {
			point = { "RIGHT", "oUF_LSFocusFrame", "LEFT", -14, 0 },
		},
		party = {
			point = {"TOPLEFT", "CompactRaidFrameManager", "TOPRIGHT", 6, 0},
			attributes = {"showPlayer", true, "showParty", true, "showRaid", false, "point", "BOTTOM", "yOffset", 40},
			visibility = "party",
		},
		boss1 = {
			point = {"TOPRIGHT", "UIParent", "TOPRIGHT", -84, -240},
		},	
		boss2 = {
			point = {"TOP", "oUF_LSBoss1Frame", "BOTTOM", 0, -46},
		},
		boss3 = {
			point = {"TOP", "oUF_LSBoss2Frame", "BOTTOM", 0, -46},
		},
		boss4 = {
			point = {"TOP", "oUF_LSBoss3Frame", "BOTTOM", 0, -46},
		},
		boss5 = {
			point = {"TOP", "oUF_LSBoss4Frame", "BOTTOM", 0, -46},
		},
	},
	auratracker = {
		buffList = {},
		trackerPoint = {"CENTER", UIParent, "CENTER", 0, 0},
		trackerLocked = false,
		isUsed = true,
	},
	minimap = {
		[1] = {"Minimap", "BOTTOM", "UIParent", "BOTTOM", 306, 80},
		[2] = {"MiniMapTracking", "CENTER", "Minimap",	"CENTER", 72, 30},
		[3] = {"GameTimeFrame", "CENTER",	"Minimap", "CENTER", 55, 55},
		[4] = {"MiniMapInstanceDifficulty", "BOTTOM", "Minimap", "BOTTOM", -1, -38},
		[5] = {"GuildInstanceDifficulty", "BOTTOM", "Minimap", "BOTTOM", -6, -38},
		[6] = {"QueueStatusMinimapButton", "CENTER", "Minimap", "CENTER", 55, -55},
	},
	objectivetracker = {
		trackerPoint = {"CENTER", UIParent, "CENTER", 0, 0},
		trackerLocked = false,
	},
	width = 0, 
	height = 0,
	playerclass = "",
}

local ConfigLoader = CreateFrame("FRAME")
ConfigLoader:RegisterEvent("ADDON_LOADED")
ConfigLoader:RegisterEvent("PLAYER_LOGOUT")

local function oUF_LSConfigLoader_OnEvent(...)
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
		oUF_LSMinimap_Initialize()

		-- Actionbars
		oUF_LSActionBar_Initialize()
		
		-- ObjectiveTracker
		CreateOTDragHeader()
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

ConfigLoader:SetScript("OnEvent", oUF_LSConfigLoader_OnEvent)