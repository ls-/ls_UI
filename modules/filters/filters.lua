local _, ns = ...
local E, C, PrC, M, L, P = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P
local MODULE = P:AddModule("Filters")

-- Lua
local _G = getfenv(0)
local next = _G.next
local t_wipe = _G.table.wipe

-- Mine
local isInit = false

local filters = {
	["Blacklist"] = {
		state = false,
		[  8326] = true, -- Ghost
		[ 26013] = true, -- Deserter
		[ 39953] = true, -- A'dal's Song of Battle
		[ 57819] = true, -- Argent Champion
		[ 57820] = true, -- Ebon Champion
		[ 57821] = true, -- Champion of the Kirin Tor
		[ 71041] = true, -- Dungeon Deserter
		[ 72968] = true, -- Precious's Ribbon
		[ 85612] = true, -- Fiona's Lucky Charm
		[ 85613] = true, -- Gidwin's Weapon Oil
		[ 85614] = true, -- Tarenar's Talisman
		[ 85615] = true, -- Pamela's Doll
		[ 85616] = true, -- Vex'tul's Armbands
		[ 85617] = true, -- Argus' Journal
		[ 85618] = true, -- Rimblat's Stone
		[ 85619] = true, -- Beezil's Cog
		[ 93337] = true, -- Champion of Ramkahen
		[ 93339] = true, -- Champion of the Earthen Ring
		[ 93341] = true, -- Champion of the Guardians of Hyjal
		[ 93347] = true, -- Champion of Therazane
		[ 93368] = true, -- Champion of the Wildhammer Clan
		[ 93795] = true, -- Stormwind Champion
		[ 93805] = true, -- Ironforge Champion
		[ 93806] = true, -- Darnassus Champion
		[ 93811] = true, -- Exodar Champion
		[ 93816] = true, -- Gilneas Champion
		[ 93821] = true, -- Gnomeregan Champion
		[ 93825] = true, -- Orgrimmar Champion
		[ 93827] = true, -- Darkspear Champion
		[ 93828] = true, -- Silvermoon Champion
		[ 93830] = true, -- Bilgewater Champion
		[ 94158] = true, -- Champion of the Dragonmaw Clan
		[ 94462] = true, -- Undercity Champion
		[ 94463] = true, -- Thunder Bluff Champion
		[ 97340] = true, -- Guild Champion
		[ 97341] = true, -- Guild Champion
		[126434] = true, -- Tushui Champion
		[126436] = true, -- Huojin Champion
		[143625] = true, -- Brawling Champion
		[170616] = true, -- Pet Deserter
		[182957] = true, -- Treasures of Stormheim
		[182958] = true, -- Treasures of Azsuna
		[185719] = true, -- Treasures of Val'sharah
		[186401] = true, -- Sign of the Skirmisher
		[186403] = true, -- Sign of Battle
		[186404] = true, -- Sign of the Emissary
		[186406] = true, -- Sign of the Critter
		[188741] = true, -- Treasures of Highmountain
		[199416] = true, -- Treasures of Suramar
		[225787] = true, -- Sign of the Warrior
		[225788] = true, -- Sign of the Emissary
		[227723] = true, -- Mana Divining Stone
		[231115] = true, -- Treasures of Broken Shore
		[233641] = true, -- Legionfall Commander
		[237137] = true, -- Knowledgeable
		[237139] = true, -- Power Overwhelming
		[239966] = true, -- War Effort
		[239967] = true, -- Seal Your Fate
		[239968] = true, -- Fate Smiles Upon You
		[239969] = true, -- Netherstorm
		[240979] = true, -- Reputable
		[240980] = true, -- Light As a Feather
		[240985] = true, -- Reinforced Reins
		[240986] = true, -- Worthy Champions
		[240987] = true, -- Well Prepared
		[240989] = true, -- Heavily Augmented
		[245686] = true, -- Fashionable!
		[264408] = true, -- Soldier of the Horde
		[264420] = true, -- Soldier of the Alliance
		[269083] = true, -- Enlisted
	},
	["M+ Affixes"] = {
		state = true,
		[178658] = true, -- Raging
		[196376] = true, -- Grievous Tear
		[209858] = true, -- Necrotic
		[209859] = true, -- Bolster
		[226510] = true, -- Sanguine
		[226512] = true, -- Sanguine
		[240443] = true, -- Bursting
		[240559] = true, -- Grievous
		[277242] = true, -- Symbiote of G'huun (Infested)
		[288388] = true, -- Reap Soul
		[288694] = true, -- Shadow Smash
		[290026] = true, -- Queen's Decree: Blowback
		[290027] = true, -- Queen's Decree: Blowback
		[302417] = true, -- Queen's Decree: Unstoppable
		[302419] = true, -- Void Sight
		[302421] = true, -- Queen's Decree: Hide
		[303632] = true, -- Enchanted
	}
}

function MODULE:IsInit()
	return isInit
end

function MODULE:Init()
	if not isInit then
		for filter, v in next, filters do
			if not C.db.global.aura_filters[filter].is_init then
				E:CopyTable(v, C.db.global.aura_filters[filter])

				C.db.global.aura_filters[filter].is_init = true
			end
		end

		isInit = true
	end
end

function MODULE:Reset(filter)
	if filters[filter] then
		t_wipe(C.db.global.aura_filters[filter])

		E:CopyTable(filters[filter], C.db.global.aura_filters[filter])

		C.db.global.aura_filters[filter].is_init = true
	end
end
