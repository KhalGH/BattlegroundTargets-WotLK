-- -------------------------------------------------------------------------- --
-- BattlegroundTargets by kunda                                               --
-- -------------------------------------------------------------------------- --
--                                                                            --
-- BattlegroundTargets is a 'Enemy Unit Frame' for battlegrounds.             --
-- BattlegroundTargets is not a 'real' (Enemy) Unit Frame.                    --
-- BattlegroundTargets simply generates buttons with target macros.           --
--                                                                            --
-- Features:                                                                  --
-- # Shows all battleground enemies with role, class and name.                --
--   - Left-click : set target                                                --
--   - Right-click: set focus                                                 --
-- # Independent settings for '10 vs 10', '15 vs 15' and '40 vs 40'.          --
-- # Target                                                                   --
-- # Main Assist Target                                                       --
-- # Focus                                                                    --
-- # Enemy Flag Carrier                                                       --
-- # Target Count                                                             --
-- # Health                                                                   --
-- # Range Check                                                              --
--                                                                            --
-- -------------------------------------------------------------------------- --
--                                                                            --
-- These events are always registered:                                        --
-- - PLAYER_REGEN_DISABLED                                                    --
-- - PLAYER_REGEN_ENABLED                                                     --
-- - ZONE_CHANGED_NEW_AREA (to determine if current zone is a battleground)   --
-- - PLAYER_LEVEL_UP (only registered if player level < level cap)            --
--                                                                            --
-- In Battleground:                                                           --
-- # If enabled: ------------------------------------------------------------ --
--   - UPDATE_BATTLEFIELD_SCORE                                               --
--   - PLAYER_DEAD                                                            --
--   - PLAYER_UNGHOST                                                         --
--   - PLAYER_ALIVE                                                           --
--                                                                            --
-- # Range Check: --------------------------------------- VERY HIGH CPU USAGE --
--   - Events:                                                                --
--        1) Combat Log: --- COMBAT_LOG_EVENT_UNFILTERED                      --
--        2) Class: -------- PLAYER_TARGET_CHANGED                            --
--                         - UNIT_HEALTH_FREQUENT                             --
--                         - UPDATE_MOUSEOVER_UNIT                            --
--                         - UNIT_TARGET                                      --
--      3/4) Mix: ---------- COMBAT_LOG_EVENT_UNFILTERED                      --
--                         - PLAYER_TARGET_CHANGED                            --
--                         - UNIT_HEALTH_FREQUENT                             --
--                         - UPDATE_MOUSEOVER_UNIT                            --
--                         - UNIT_TARGET                                      --
--   - The data to determine the distance to an enemy is not always available.--
--     This is restricted by the WoW API.                                     --
--   - This feature is a compromise between CPU usage (FPS), lag/network      --
--     bandwidth (no SendAdd0nMessage), fast and easy visual recognition and  --
--     suitable data.                                                         --
--                                                                            --
-- # Health: ------------------------------------------------- HIGH CPU USAGE --
--   - Events:             - UNIT_TARGET                                      --
--                         - UNIT_HEALTH_FREQUENT                             --
--                         - UPDATE_MOUSEOVER_UNIT                            --
--   - The health from an enemy is not always available.                      --
--     This is restricted by the WoW API.                                     --
--   - A raidmember/raidpet MUST target(focus/mouseover) an enemy OR          --
--     you/yourpet MUST target/focus/mouseover an enemy to get the health.    --
--                                                                            --
-- # Target Count: ------------------------------------ HIGH MEDIUM CPU USAGE --
--   - Event:              - UNIT_TARGET                                      --
--                                                                            --
-- # Main Assist Target: ------------------------------- LOW MEDIUM CPU USAGE --
--   - Events:             - RAID_ROSTER_UPDATE                               --
--                         - UNIT_TARGET                                      --
--                                                                            --
-- # Leader: ------------------------------------------- LOW MEDIUM CPU USAGE --
--   - Event:              - UNIT_TARGET                                      --
--                                                                            --
-- # Level: (only if player level < level cap) ---------------- LOW CPU USAGE --
--   - Event:              - UNIT_TARGET                                      --
--                                                                            --
-- # Target: -------------------------------------------------- LOW CPU USAGE --
--   - Event:              - PLAYER_TARGET_CHANGED                            --
--                                                                            --
-- # Focus: --------------------------------------------------- LOW CPU USAGE --
--   - Event:              - PLAYER_FOCUS_CHANGED                             --
--                                                                            --
-- # Enemy Flag Carrier: --------------------------------- VERY LOW CPU USAGE --
--   - Events:             - CHAT_MSG_BG_SYSTEM_HORDE                         --
--                         - CHAT_MSG_BG_SYSTEM_ALLIANCE                      --
--   Flag detection in case of disconnect, UI reload or mid-battle-joins:     --
--   (temporarily registered until each enemy is scanned)                     --
--                         - UNIT_TARGET                                      --
--                         - UPDATE_MOUSEOVER_UNIT                            --
--                         - PLAYER_TARGET_CHANGED                            --
--                                                                            --
-- # No SendAdd0nMessage(): ------------------------------------------------- --
--   This AddOn does not use/need SendAdd0nMessage(). SendAdd0nMessage()      --
--   increases the available data by transmitting information to other        --
--   players. This has certain pros and cons. I may include (opt-in) such     --
--   functionality in some future release. maybe. dontknow.                   --
--                                                                            --
-- -------------------------------------------------------------------------- --
--                                                                            --
-- slash commands: /bgt - /bgtargets - /battlegroundtargets                   --
-- slash commands for HD (Heals Detection and Cross Faction mod):             --
--      /bgt hdlog    -- Announces of any detection in the chat frame.        --
--      /bgt hdreport -- Shows all current info at that time about detects.   --
--                                                                            --
--      /bgt hdlogAlways                                                      --
--                      To enable permanent healer detection mode while       --
--                      you are in BG. After that, you don't need to enter    --
--                      /bgt hdlog every time                                 --
--                                                                            --
--      /bgt dbStoragePeriod <number>                                         --
--                      "GET or SET (if the <number> exists)                  --
--                      retention period of the data in months, after which   --
--                      the obsolete data about healer will be deleted."      --
--                                                                            --
-- -------------------------------------------------------------------------- --
--                                                                            --
-- Thanks to all who helped with the localization.                            --
--                                                                            --
-- Special thanks to Roma.                                                    --
--                                                                            --
-- -------------------------------------------------------------------------- --
--                                                                            --
-- UPD. Cross-faction (CF) and Heals Detection (HD) support provided          --
-- by Nobraix (aka Splight-Fun) from forum.wowcircle.net                      --
--                                                                            --
-- Special thanks to Jud from forum.wowcircle.net                             -- 
-- for his supports, feedback and quality testing.                            --
--                                                                            --
-- -------------------------------------------------------------------------- --
--                                                                            --
-- Minor adjustments for Warmane's Mercenary Mode.           	              --
-- Integrated combatlog-based Healer Detection from BattleGroundHealers.      --
-- Added Netherstorm Flag carrier tracking                                    --
-- by Khal (https://github.com/KhalGH)                                        --
--                                                                            --
-- -------------------------------------------------------------------------- --

-- ---------------------------------------------------------------------------------------------------------------------
BattlegroundTargets_Options   = {};
BattlegroundTargets_Character = {};
BattlegroundTargets_HealersDB = {};

local BattlegroundTargets = CreateFrame("Frame");
local MOD_VERSION = "v1.2.2";

local L   = BattlegroundTargets_Localization;
local BGN = BattlegroundTargets_BGNames;
local FLG = BattlegroundTargets_Flag;
local RNA = BattlegroundTargets_RaceNames;
local DBUtils = BattlegroundTargets_DBUtils;

local GVAR     = {};
local TEMPLATE = {};
local OPT      = {};

local AddonIcon = "Interface\\AddOns\\BattlegroundTargets\\Textures\\BattlegroundTargets-texture-button";

local _G = _G;
local GetTime = _G.GetTime;
local InCombatLockdown = _G.InCombatLockdown;
local IsInInstance = _G.IsInInstance;
local IsRatedBattleground = _G.IsRatedBattleground;

local GetBattlefieldArenaFaction = _G.GetBattlefieldArenaFaction;
local GetRealZoneText            = _G.GetRealZoneText;
local GetMaxBattlefieldID        = _G.GetMaxBattlefieldID;
local GetBattlefieldStatus       = _G.GetBattlefieldStatus;
local GetNumBattlefieldScores    = _G.GetNumBattlefieldScores;
local GetBattlefieldScore        = _G.GetBattlefieldScore;
local SetBattlefieldScoreFaction = _G.SetBattlefieldScoreFaction;
local UnitName                   = _G.UnitName;
local UnitClass         		 = _G.UnitClass;
local UnitLevel                  = _G.UnitLevel;
local UnitHealthMax              = _G.UnitHealthMax;
local UnitHealth                 = _G.UnitHealth;
local UnitIsPartyLeader          = _G.UnitIsPartyLeader;
local UnitIsEnemy                = _G.UnitIsEnemy;
local UnitBuff                   = _G.UnitBuff;
local UnitDebuff                 = _G.UnitDebuff;
local GetSpellInfo               = _G.GetSpellInfo;
local IsSpellInRange             = _G.IsSpellInRange;
local CheckInteractDistance      = _G.CheckInteractDistance;
local GetNumRaidMembers          = _G.GetNumRaidMembers;
local GetRaidRosterInfo          = _G.GetRaidRosterInfo;
local math_min                   = _G.math.min;
local math_max                   = _G.math.max;
local math_floor                 = _G.math.floor;
local math_random                = _G.math.random;
local string_find                = _G.string.find;
local string_match               = _G.string.match;
local string_format              = _G.string.format;
local table_sort                 = _G.table.sort;
local table_wipe                 = _G.table.wipe;
local pairs                      = _G.pairs;
local tonumber                   = _G.tonumber;
local next 						 = _G.next;
local select					 = _G.select;
local GetPlayerMapPosition		 = _G.GetPlayerMapPosition;
local GetWorldStateUIInfo		 = _G.GetWorldStateUIInfo;

local inWorld;
local inBattleground;
local inCombat;
local reCheckBG;
local reCheckScore;
local reSizeCheck = 0;
local reSetLayout;
local isConfig;
local testDataLoaded;
local isTarget = 0;
local hasFlag;
local isDeadUpdateStop;
local isLeader;
local isHealer; 
local isAssistName;
local isAssistUnitId;
local rangeSpellName, rangeMin, rangeMax;
local isFlagBG = 0;
local flagCHK;
local flagflag;

-- THROTTLE (reduce CPU usage) -----------------------------------------------------------------------------------------
local scoreUpdateThrottle = GetTime();       -- scoreupdate: B.attlefieldScoreUpdate()
local scoreUpdateFrequency = 1;              -- scoreupdate: 0-20 updates = 1 second | 21+ updates = 5 seconds
local scoreUpdateCount = 0;              	 -- scoreupdate: (reason: later score updates are less relevant and 5 seconds is still very high)
local range_SPELL_Frequency = 0.2;       	 -- rangecheck: [class-spell]: the 0.2 second freq is per enemy (variable: ENEMY_Name2Range[enemyname]) 
local range_CL_Throttle = 0;         		 -- rangecheck: [combatlog] C.ombatLogRangeCheck()
local range_CL_Frequency = 3;         		 -- rangecheck: [combatlog] 50/50 or 66/33 or 75/25 (%Yes/%No) => 64/36 = 36% combatlog messages filtered (36% vs overhead: two variables, one addition, one number comparison and if filtered one math_random)
local range_CL_DisplayThrottle = GetTime();  -- rangecheck: [combatlog] display update
local range_CL_DisplayFrequency = 0.33;      -- rangecheck: [combatlog] display update
local leaderThrottle = 0;                    -- leader: C.heckUnitTarget()
local leaderFrequency = 5;                   -- leader: if isLeader is true then pause 5 times(events) until next check (reason: leader does not change often in a bg, irrelevant info anyway)
-- FORCE UPDATE (precise results) --------------------------------------------------------------------------------------
local assistForceUpdate = GetTime();         -- assist: C.heckUnitTarget()
local assistFrequency = 0.5;               	 -- assist: immediate assist target check (reason: target loss and I don't know why... -> brute force)
local targetCountForceUpdate = GetTime();    -- targetcount: C.heckUnitTarget()
local targetCountFrequency = 30;          	 -- targetcount: a complete raid/raidtarget check every 30 seconds (reason: target loss and I don't know why... -> brute force)
-- WARNING -------------------------------------------------------------------------------------------------------------
local latestScoreUpdate = GetTime();         -- scoreupdate: B.attlefieldScoreUpdate()
local latestScoreWarning = 60;               -- scoreupdate: inCombat-warning icon if latest score update is >= 60 seconds
-- MISC ----------------------------------------------------------------------------------------------------------------
local range_DisappearTime = 8;               -- rangecheck: display update - clears range display if an enemy was not seen for 8 seconds

local playerLevel = UnitLevel("player");
local isLowLevel;
local maxLevel = 80;

local playerName = UnitName("player");
local playerClass, playerClassEN = UnitClass("player");
local targetName, targetRealm;
local focusName, focusRealm;
local assistTargetName, assistTargetRealm;

local playerFactionDEF   = 0;  -- player faction (DEFAULT)
local oppositeFactionDEF = 0;  -- opposite faction (DEFAULT)
local playerFactionBG    = 0;  -- player faction (in battleground)
local oppositeFactionBG  = 0;  -- opposite faction (in battleground)
local oppositeFactionREAL;     -- real opposite faction 	
local factionIsValid = false;  -- cross-server faction validate flag

local ENEMY_Data           = {};  -- numerical | all data
local ENEMY_Names          = {};  -- key/value | key = enemyName, value = count
local ENEMY_Names4Flag     = {};  -- key/value | key = enemyName without realm, value = button number
local ENEMY_Name2Button    = {};  -- key/value | key = enemyName, value = button number
local ENEMY_Name2Percent   = {};  -- key/value | key = enemyName, value = health in percent
local ENEMY_Name2Range     = {};  -- key/value | key = enemyName, value = time of last contact
local ENEMY_Name2Level     = {};  -- key/value | key = enemyName, value = level
local ENEMY_FirstFlagCheck = {};  -- key/value | key = enemyName, value = 1
local FRIEND_Names         = {};  -- key/value | key = friendName, value = 1
local TARGET_Names         = {};  -- key/value | key = friendName, value = enemyName
local SPELL_Range          = {};  -- key/value | key = spellID, value = maxRange
local ENEMY_Healers        = {};  -- Hash table. key/value | key = Enemy name, value = table where with options: status, classToken, reason (which spell has been detected)
local UITitle = "BattlegroundTargets [CF-HD "..MOD_VERSION.."]"

local testSize     = 10;
local testIcon1    = 2;
local testIcon2    = 5;
local testIcon3    = 3;
local testIcon4    = 4;
local testHealth   = {};
local testRange    = {};
local testLeader   = 4;
local testHealers  = {};

local healthBarWidth = 0.01;

local sizeOffset    = 5;
local sizeBarHeight = 14;

local fontPath = _G["GameFontNormal"]:GetFont();

local BGStatus = {}
for i = 1, MAX_BATTLEFIELD_QUEUES do
	BGStatus[i] = true
end

local BGNameByID = {
	[444] = "Warsong Gulch",
	[462] = "Arathi Basin",
	[402] = "Alterac Valley",
	[483] = "Eye of the Storm",
	[513] = "Strand of the Ancients",
	[541] = "Isle of Conquest",
}

local currentSize = 10;
local bgSize = {
	["Alterac Valley"] = 40,
	["Warsong Gulch"] = 10,
	["Arathi Basin"] = 15,
	["Eye of the Storm"] = 15,
	["Strand of the Ancients"] = 15,
	["Isle of Conquest"] = 40,
};

local bgSizeINT = {
	[1] = 10,
	[2] = 15,
	[3] = 40
};

------------------------------------------------------------
-- Spec-specific buffs
-- ID's of BUFFS were taken from the next resources:										
-- https://wowroad.info/?spell=47753
-- https://wotlk.evowow.com/?spells=7
-- http://www.wow-game.ru/Wotlktalents335a.htm?lan=ru&class=druid
-----------------------------------------------------------
local HEALER_SpellBase = {
	["Healers"] = {
		"PALADIN",
		"SHAMAN",
		"PRIEST",
		"DRUID"
	},
	["HealerBuffs"] = { 
		------------------------------------------------------------------------------------------
		-- That storage is for only owns buffs of HEALERS, which can't be applied to someone else.
		------------------------------------------------------------------------------------------
		-- DISC PRIEST
		52800, 59891, 59890, 52799 -- Borrowed Time
		,45242, 45241 			   -- Focused Power 
		
		-- HOLY PRIEST
		,63734, 63735, 63731 -- Holy Serendipity
		,20711, 27827 		 -- Spirit of Redemption
		,33151, 33150, 33154 -- Surge of light
		,34754, 63724, 63725 -- Holy Concentration
		,33143 

		-- RESTORATION SHAMAN
		-- ,49284 		     -- Earth Shield (some bug which that id)
		,17116, 16188, 29274 -- Raven Form
		,53390 		  	 	 -- Tidal Wawes
		,55198               -- Tidal Force
		
		-- RESTORATION DRUID
		,33881, 33882, 33883
		,45281, 45283, 45282 -- Natural Perfection
		,48535, 48536, 48537 -- Improved Tree Form
		,29274, 16188, 17116 -- Raven Form
		,63410, 63411 		 -- Stone Claw Totem  

		-- HOLY PALADIN
		,53655, 53656, 53657, 54152, 54153 -- Judgements of the Pure
		,53672, 54149, 53576, 53569 -- Infusion of Light [(?) last 2]

	},
	["aoeHealerBuffs"] = {
		-- Priest
		47753, 54704, 		 -- Divine Aegis [DC]
		27813, 27817, 27818, -- Blessed Recovery [HOLY]
		10060, -- Power Infusion
		33206, -- Pain Sppression

		-- RESTORATION DRUID
		34123, 48371, 5420 ,33891, 48371, -- three of life
		53251, -- Wild Growth

		-- RESTORATION SHAMAN
		61301, -- Riptide
		53390, -- Tidal Waves
		16236, 16237, -- Undying Strength
		49284, 49283, 32594, 32593,	-- Earth Shield
		16177, 16236, 16237, -- Ancestral Fortitude

		-- HOLY PALADIN
		53563, 53651, 53652, 53654 -- Beacon of Light
	},
	["DamageBuffs"] = {
		------------------------------------------------------------------------------------------
		-- That storage is for only owns buffs of DD, which can't be applied to someone else. 
		------------------------------------------------------------------------------------------
		-- SHADOW PRIEST --
    	 15473 -- Shadowform 
		,15286 -- Vampiric Embrace
		,47585, 65544 -- Dispersion

		-- RETRIBUTION PALADIN -- 
		,20375 -- Seal of Command
		,53489, 59578, 53486, 53488 -- The Art of War
		,20050, 20052, 20053 -- Vengeance

		-- PROTO PALADIN
		,66233, 66235 -- Ardent Defender
		,20128, 20128, 20132, 32776 -- Redoubt
		,20178, 32746, 20179, 20180, 20181 -- Reckoning [(?) last 3]    
		
		-- ENHANCEMENT SHAMAN --
		,30824 -- Shamanistic
		,52179 -- Astral Shift
		,58875 -- Spirit Walk
		
		-- ELEMENTAL SHAMAN --
		,64701 -- Wisp Heal
		,53814 ,53816, 53819, 53818, 53817, 65986 -- Maelstrom Weapon
		,64694 ,65263, 65264 -- Lava flow

		-- BALANCE DRUID
		,48391 -- Owlkin Frenzy
		,48516, 48521, 48525 -- Eclipse
		,53201, 53199 --  Starfall 
		,48518 -- Eclipse (Lunar)

		-- FERAL
		,50334  -- Berserk (?)
		,69369, -- Predator's Swiftness
	},
	["aoeDamageBuffs"] = {
		63283, 57663, 30708 -- Totem of Wrath
		,24858,24907  -- Moonkin Aura

		-- Retribution Paladin
		,54203, 53501, 53502, 53503 -- Sanctified Wrath

	},
};

local icoMinimapFactionBG;
local battleFieldIconTextures = {
	[0] = "Interface\\BattlefieldFrame\\Battleground-Horde",		
	[1] = "Interface\\BattlefieldFrame\\Battleground-Alliance",
}
local battleFieldRoleIcons = {
	[0] = "Interface\\AddOns\\BattlegroundTargets\\Textures\\UnknownRoleIco",
	[1] = "Interface\\AddOns\\BattlegroundTargets\\Textures\\DamageDealerIco",
	[2] = "Interface\\AddOns\\BattlegroundTargets\\Textures\\HealDealerIco",
}
local roleLayoutPos = {
	[1] = L["Show roles on the right"],
	[2] = L["Show roles on the left"],
	[3] = L["Don't show roles"],
}; 

local hdlog = BattlegroundTargets_Options  and  BattlegroundTargets_Options.hdlog or false;
local flagBG = {
	["Warsong Gulch"] = 1,
	["Eye of the Storm"] = 1
};

local flagIDs = {
	[23333] = 1, -- Warsong Flag
	[23335] = 1, -- Silverwing Flag
	[34976] = 1  -- Netherstorm Flag
};

local sortBy = {
	[1] = CLASS.."* / "..NAME,
	[2] = NAME,  
	[3] = CLASS.."* / "..NAME.." [healers first]", 
};

local locale = GetLocale();
local sortDetail = {
	[1] = "*"..CLASS.." ("..locale..")",
	[2] = "*"..CLASS.." (english)",
	[3] = "*"..CLASS.." (Blizzard)"
};

local classcolors = {};
for class, color in pairs(RAID_CLASS_COLORS) do
	classcolors[class] = { r = color.r, g = color.g, b = color.b }
end

local classes = {
	DEATHKNIGHT = { 0.265625, 0.484375, 0.515625, 0.734375 },
	DRUID       = { 0.7578125, 0.9765625, 0.015625, 0.234375 },
	HUNTER      = { 0.01953125, 0.23828125, 0.265625, 0.484375 },
	MAGE        = { 0.265625, 0.484375, 0.015625, 0.234375 },
	PALADIN     = { 0.01953125, 0.23828125, 0.515625, 0.734375 },
	PRIEST      = { 0.51171875, 0.73046875, 0.265625, 0.484375 },
	ROGUE       = { 0.51171875, 0.73046875, 0.015625, 0.234375 },
	SHAMAN      = { 0.265625, 0.484375, 0.265625, 0.484375 },
	WARLOCK     = { 0.7578125, 0.9765625, 0.265625, 0.484375 },
	WARRIOR     = { 0.01953125, 0.23828125, 0.015625, 0.234375 },
	ZZZFAILURE  = { 0, 0, 0, 0 }
};

local class_LocaSort = {};
FillLocalizedClassList(class_LocaSort, false);

local class_BlizzSort = {};
for i = 1, #CLASS_SORT_ORDER do
	class_BlizzSort[ CLASS_SORT_ORDER[i] ] = i;
end

local class_IntegerSort = {
	[1]  = { cid = "DEATHKNIGHT", blizz = class_BlizzSort.DEATHKNIGHT or 2,  eng = "Death Knight", loc = class_LocaSort.DEATHKNIGHT or "Death Knight" },
	[2]  = { cid = "DRUID", 	  blizz = class_BlizzSort.DRUID       or 7,  eng = "Druid", 	   loc = class_LocaSort.DRUID or "Druid" },
	[3]  = { cid = "HUNTER", 	  blizz = class_BlizzSort.HUNTER 	  or 10, eng = "Hunter", 	   loc = class_LocaSort.HUNTER or "Hunter" },
	[4]  = { cid = "MAGE",        blizz = class_BlizzSort.MAGE 		  or 9,  eng = "Mage", 		   loc = class_LocaSort.MAGE or "Mage"},
	[5]  = { cid = "PALADIN",     blizz = class_BlizzSort.PALADIN 	  or 3,  eng = "Paladin", 	   loc = class_LocaSort.PALADIN or "Paladin" },
	[6]  = { cid = "PRIEST",      blizz = class_BlizzSort.PRIEST 	  or 5,  eng = "Priest",       loc = class_LocaSort.PRIEST or "Priest" },
	[7]  = { cid = "ROGUE",       blizz = class_BlizzSort.ROGUE 	  or 8,  eng = "Rogue",  	   loc = class_LocaSort.ROGUE or "Rogue" },
	[8]  = { cid = "SHAMAN",      blizz = class_BlizzSort.SHAMAN 	  or 6,  eng = "Shaman", 	   loc = class_LocaSort.SHAMAN or "Shaman" },
	[9]  = { cid = "WARLOCK",     blizz = class_BlizzSort.WARLOCK 	  or 9,  eng = "Warlock",      loc = class_LocaSort.WARLOCK or "Warlock" },
	[10] = { cid = "WARRIOR",     blizz = class_BlizzSort.WARRIOR 	  or 1,  eng = "Warrior",      loc = class_LocaSort.WARRIOR or "Warrior" }
};

local ranges = {
	DEATHKNIGHT = 49895,
	DRUID       = 5176,
	HUNTER      = 75,
	MAGE        = 133,
	PALADIN     = 62124,
	PRIEST      = 589,
	ROGUE       = 6770,
	SHAMAN      = 403,
	WARLOCK     = 686,
	WARRIOR     = 100
};

local rangeTypeName = {
	[1] = "1) CombatLog |cffffff79(0-73)|r",
	[2] = "2) ...",
	[3] = "3) ...",
	[4] = "4) ..."
};

local rangeDisplay = {
	[1]  = "STD 100",
	[2]  = "STD 100 mono",
	[3]  = "STD 50",
	[4]  = "STD 50 mono",
	[5]  = "STD 25",
	[6]  = "STD 25 mono",
	[7]  = "STD 10",
	[8]  = "STD 10 mono",
	[9]  = "X 100 mono",
	[10] = "X 50",
	[11] = "X 50 mono",
	[12] = "X 25",
	[13] = "X 25 mono",
	[14] = "X 10",
	[15] = "X 10 mono"
};

local function rt(H, E, M, P) return E, P, E, M, H, P, H, M; end

local Textures = {
	BattlegroundTargetsIcons = { path = "Interface\\AddOns\\BattlegroundTargets\\Textures\\BattlegroundTargets-texture-icons.tga" },
	SliderKnob = { coords = { 19/64, 30/64,  1/64, 18/64 } },
	SliderBG = {
		coordsL = { 19/64, 24/64, 27/64, 33/64 },
		coordsM = { 25/64, 26/64, 27/64, 33/64 },
		coordsR = { 26/64, 31/64, 27/64, 33/64 },
		coordsLdis = { 19/64, 24/64, 19/64, 25/64 },
		coordsMdis = { 25/64, 26/64, 19/64, 25/64 },
		coordsRdis = { 26/64, 31/64, 19/64, 25/64 }
	},
	Expand   = { coords = { 1/64, 18/64,  1/64, 18/64 } },
	Collapse = { coords = { rt( 1/64, 18/64,  1/64, 18/64) } },
	Close    = { coords = { 1/64,  18/64, 19/64, 36/64 } },
	Healer   = { coords = { 33/64, 47/64, 17/64, 31/64} },
	l40_18   = { coords = { 36/64, 41/64, 37/64, 51/64 },  width =  5*2, height = 14*2 },
	l40_24   = { coords = { 27/64, 36/64, 37/64, 47/64 },  width =  9*2, height = 10*2 },
	l40_42   = { coords = { 14/64, 27/64, 37/64, 44/64 },  width = 13*2, height =  7*2 },
	l40_81   = { coords = { 0/64,  14/64, 37/64, 42/64 },   width = 14*2, height =  5*2 },
	UpdateWarning = {coords = { 0/64, 35/64, 47/64, 63/64 }, width = 35/1.5, height = 16/1.5 }
};

local raidUnitID = {};
for i = 1, 40 do
	raidUnitID["raid"..i]    = 1;
	raidUnitID["raidpet"..i] = 1;
end

local playerUnitID = {};
playerUnitID["target"]    = 1;
playerUnitID["pettarget"] = 1;
playerUnitID["focus"]     = 1;
playerUnitID["mouseover"] = 1;

local startMapCoordsA = {
	["Alterac Valley"]          = { 417, 424, -56,  -26  },
	["Arathi Basin"]            = { 230, 258, -105, -78  },
	["Isle of Conquest"]        = { 300, 419, -429, -385 },
	["Eye of the Storm"]        = { 360, 375, -144, -125 },
	["Warsong Gulch"]           = { 370, 402, -85,  -64  },
	["Strand of the Ancients"]  = { 374, 392, -310, -290 }, -- defending faction start area
}

local function Print(...)
	print("|cffffff7fBattlegroundTargets:|r", ...);
end

local function HDLog(...)
	if hdlog or BattlegroundTargets_Options.hdlog then Print(...) end
end

local function contains(table, element)
	for _, value in pairs(table) do
		if (value == element) then return true end
	end
	return false
end

function GetRealCoords(rawX, rawY)
	local realX, realY = 0, 0;
	realX = rawX * 783; -- X -17
	realY = -rawY * 522; -- Y -78
	return realX, realY;
end

local function inRange(val, min, max)
    if not min or not max then return nil end;
    if min <= val and val <= max then return true;
    else return false end;
end

local function isAllyStartPosition(rx, ry, mapName)
    local cords = startMapCoordsA[mapName];
    local tx, ty;
    for i=1, #cords, 2 do
        if i == 1 then tx = inRange(rx, cords[i], cords[i+1]);
		else ty = inRange(ry, cords[i], cords[i+1]); end
    end
    if tx and ty then return true end
end

local function isSotaDefenderPosition(rx, ry)
    local cords = startMapCoordsA["Strand of the Ancients"];
    local tx, ty;
    for i=1, #cords, 2 do
        if i == 1 then tx = inRange(rx, cords[i], cords[i+1]);
		else ty = inRange(ry, cords[i], cords[i+1]); end
    end
    if tx and ty then return true end
end

local function ClassHexColor(class)
	local hex;
	if(classcolors[class]) then
		hex = string_format("%.2x%.2x%.2x", classcolors[class].r*255, classcolors[class].g*255, classcolors[class].b*255);
	end
	return hex or "cccccc";
end

local function NOOP() end

local function Desaturation(texture, desaturation)
	local shaderSupported = texture:SetDesaturated(desaturation);
	if(not shaderSupported) then
		if(desaturation) then
			texture:SetVertexColor(0.5, 0.5, 0.5);
		else
			texture:SetVertexColor(1.0, 1.0, 1.0);
		end
	end
end

local function SortByPullDownFunc(value)
	BattlegroundTargets_Options.ButtonSortBy[currentSize] = value;
	OPT.ButtonSortBy[currentSize] = value;
	BattlegroundTargets:EnableConfigMode();
end

local function SortDetailPullDownFunc(value)
	BattlegroundTargets_Options.ButtonSortDetail[currentSize] = value;
	OPT.ButtonSortDetail[currentSize] = value;
	BattlegroundTargets:EnableConfigMode();
end

local function RangeCheckTypePullDownFunc(value)
	BattlegroundTargets_Options.ButtonTypeRangeCheck[currentSize] = value;
	OPT.ButtonTypeRangeCheck[currentSize] = value;
end

local function RangeDisplayPullDownFunc(value)
	BattlegroundTargets_Options.ButtonRangeDisplay[currentSize] = value;
	OPT.ButtonRangeDisplay[currentSize] = value;
	BattlegroundTargets:EnableConfigMode();
end

local function RoleLayoutPosPullDownFunc(value)
	BattlegroundTargets_Options.ButtonRoleLayoutPos[currentSize] = value;
	OPT.ButtonRoleLayoutPos[currentSize] = value;
	if (value == 1 or value == 2) then 
		BattlegroundTargets_Options.ButtonShowHealer[currentSize] = true;
		OPT.ButtonShowHealer[currentSize] = true;
	else
		BattlegroundTargets_Options.ButtonShowHealer[currentSize] = false;
		OPT.ButtonShowHealer[currentSize] = false;
	end
	for i = 1, currentSize do 
		GVAR.TargetButton[i].HealersTexture:ClearAllPoints();
	end
	BattlegroundTargets:EnableConfigMode();
end

local function Range_Display(state, GVAR_TargetButton, display, healerState)
	if state or OPT.ButtonRangeCheck[currentSize] == false then
		GVAR_TargetButton.Background:SetAlpha(1)
		GVAR_TargetButton.TargetCountBackground:SetAlpha(1)
		GVAR_TargetButton.ClassColorBackground:SetAlpha(1)
		GVAR_TargetButton.RangeTexture:SetAlpha(1)
		GVAR_TargetButton.HealthBar:SetAlpha(1)
		GVAR_TargetButton.ClassTexture:SetAlpha(1)
		GVAR_TargetButton.ClassColorBackground:SetTexture(GVAR_TargetButton.colR5, GVAR_TargetButton.colG5, GVAR_TargetButton.colB5, 1)
		GVAR_TargetButton.HealthBar:SetTexture(GVAR_TargetButton.colR, GVAR_TargetButton.colG, GVAR_TargetButton.colB, 1)
		if healerState then GVAR_TargetButton.HealersTexture:SetAlpha(1) end
	else
		if display == 1 then -- Default 100
			GVAR_TargetButton.Background:SetAlpha(1)
			GVAR_TargetButton.TargetCountBackground:SetAlpha(1)
			GVAR_TargetButton.ClassColorBackground:SetAlpha(1)
			GVAR_TargetButton.RangeTexture:SetAlpha(0)
			GVAR_TargetButton.HealthBar:SetAlpha(1)
			GVAR_TargetButton.ClassTexture:SetAlpha(1)
			if healerState then GVAR_TargetButton.HealersTexture:SetAlpha(1) end
 		elseif display == 2 then -- Default 100 m
			GVAR_TargetButton.Background:SetAlpha(1)
			GVAR_TargetButton.TargetCountBackground:SetAlpha(1)
			GVAR_TargetButton.ClassColorBackground:SetAlpha(1)
			GVAR_TargetButton.RangeTexture:SetAlpha(0)
			GVAR_TargetButton.HealthBar:SetAlpha(1)
			GVAR_TargetButton.ClassTexture:SetAlpha(1)
			GVAR_TargetButton.ClassColorBackground:SetTexture(0.2, 0.2, 0.2, 1)
			GVAR_TargetButton.HealthBar:SetTexture(0.4, 0.4, 0.4, 1)
			if healerState then GVAR_TargetButton.HealersTexture:SetAlpha(1) end
		elseif display == 3 then -- Default 50
			GVAR_TargetButton.Background:SetAlpha(0.50)
			GVAR_TargetButton.TargetCountBackground:SetAlpha(0.50)
			GVAR_TargetButton.ClassColorBackground:SetAlpha(0.50)
			GVAR_TargetButton.RangeTexture:SetAlpha(0)
			GVAR_TargetButton.HealthBar:SetAlpha(0.50)
			GVAR_TargetButton.ClassTexture:SetAlpha(0.50)
			if healerState then GVAR_TargetButton.HealersTexture:SetAlpha(0.50) end
 		elseif display == 4 then -- Default 50 m
			GVAR_TargetButton.Background:SetAlpha(0.50)
			GVAR_TargetButton.TargetCountBackground:SetAlpha(0.50)
			GVAR_TargetButton.ClassColorBackground:SetAlpha(0.50)
			GVAR_TargetButton.RangeTexture:SetAlpha(0)
			GVAR_TargetButton.HealthBar:SetAlpha(0.50)
			GVAR_TargetButton.ClassTexture:SetAlpha(0.50)
			GVAR_TargetButton.ClassColorBackground:SetTexture(0.2, 0.2, 0.2, 1)
			GVAR_TargetButton.HealthBar:SetTexture(0.4, 0.4, 0.4, 1)
			if healerState then GVAR_TargetButton.HealersTexture:SetAlpha(0.50) end
		elseif display == 5 then -- Default 25
			GVAR_TargetButton.Background:SetAlpha(0.25)
			GVAR_TargetButton.TargetCountBackground:SetAlpha(0.25)
			GVAR_TargetButton.ClassColorBackground:SetAlpha(0.25)
			GVAR_TargetButton.RangeTexture:SetAlpha(0)
			GVAR_TargetButton.HealthBar:SetAlpha(0.25)
			GVAR_TargetButton.ClassTexture:SetAlpha(0.25)
			if healerState then GVAR_TargetButton.HealersTexture:SetAlpha(0.25) end
 		elseif display == 6 then -- Default 25 m
			GVAR_TargetButton.Background:SetAlpha(0.25)
			GVAR_TargetButton.TargetCountBackground:SetAlpha(0.25)
			GVAR_TargetButton.ClassColorBackground:SetAlpha(0.25)
			GVAR_TargetButton.RangeTexture:SetAlpha(0)
			GVAR_TargetButton.HealthBar:SetAlpha(0.25)
			GVAR_TargetButton.ClassTexture:SetAlpha(0.25)
			GVAR_TargetButton.ClassColorBackground:SetTexture(0.2, 0.2, 0.2, 1)
			GVAR_TargetButton.HealthBar:SetTexture(0.4, 0.4, 0.4, 1)
			if healerState then GVAR_TargetButton.HealersTexture:SetAlpha(0.25) end
		elseif display == 7 then -- Default 10
			GVAR_TargetButton.Background:SetAlpha(0.10)
			GVAR_TargetButton.TargetCountBackground:SetAlpha(0.10)
			GVAR_TargetButton.ClassColorBackground:SetAlpha(0.10)
			GVAR_TargetButton.RangeTexture:SetAlpha(0)
			GVAR_TargetButton.HealthBar:SetAlpha(0.10)
			GVAR_TargetButton.ClassTexture:SetAlpha(0.10)
			if healerState then GVAR_TargetButton.HealersTexture:SetAlpha(0.10) end
		elseif display == 8 then -- Default 10 m
			GVAR_TargetButton.Background:SetAlpha(0.10)
			GVAR_TargetButton.TargetCountBackground:SetAlpha(0.10)
			GVAR_TargetButton.ClassColorBackground:SetAlpha(0.10)
			GVAR_TargetButton.RangeTexture:SetAlpha(0)
			GVAR_TargetButton.HealthBar:SetAlpha(0.10)
			GVAR_TargetButton.ClassTexture:SetAlpha(0.10)
			GVAR_TargetButton.ClassColorBackground:SetTexture(0.2, 0.2, 0.2, 1)
			GVAR_TargetButton.HealthBar:SetTexture(0.4, 0.4, 0.4, 1)
			if healerState then GVAR_TargetButton.HealersTexture:SetAlpha(0.10) end
 		elseif display == 9 then -- X 100 m
			GVAR_TargetButton.Background:SetAlpha(1)
			GVAR_TargetButton.TargetCountBackground:SetAlpha(1)
			GVAR_TargetButton.ClassColorBackground:SetAlpha(1)
			GVAR_TargetButton.RangeTexture:SetAlpha(0)
			GVAR_TargetButton.HealthBar:SetAlpha(1)
			GVAR_TargetButton.ClassTexture:SetAlpha(1)
			GVAR_TargetButton.ClassColorBackground:SetTexture(0.2, 0.2, 0.2, 1)
			GVAR_TargetButton.HealthBar:SetTexture(0.4, 0.4, 0.4, 1)
			if healerState then GVAR_TargetButton.HealersTexture:SetAlpha(1) end
		elseif display == 10 then -- X 50
			GVAR_TargetButton.Background:SetAlpha(0.50)
			GVAR_TargetButton.TargetCountBackground:SetAlpha(0.50)
			GVAR_TargetButton.ClassColorBackground:SetAlpha(0.50)
			GVAR_TargetButton.RangeTexture:SetAlpha(0)
			GVAR_TargetButton.HealthBar:SetAlpha(0.50)
			GVAR_TargetButton.ClassTexture:SetAlpha(0.50)
			if healerState then GVAR_TargetButton.HealersTexture:SetAlpha(0.50) end
 		elseif display == 11 then -- X 50 m
			GVAR_TargetButton.Background:SetAlpha(0.50)
			GVAR_TargetButton.TargetCountBackground:SetAlpha(0.50)
			GVAR_TargetButton.ClassColorBackground:SetAlpha(0.50)
			GVAR_TargetButton.RangeTexture:SetAlpha(0)
			GVAR_TargetButton.HealthBar:SetAlpha(0.50)
			GVAR_TargetButton.ClassTexture:SetAlpha(0.50)
			GVAR_TargetButton.ClassColorBackground:SetTexture(0.2, 0.2, 0.2, 1)
			GVAR_TargetButton.HealthBar:SetTexture(0.4, 0.4, 0.4, 1)
			if healerState then GVAR_TargetButton.HealersTexture:SetAlpha(0.50) end
		elseif display == 12 then -- X 25
			GVAR_TargetButton.Background:SetAlpha(0.25)
			GVAR_TargetButton.TargetCountBackground:SetAlpha(0.25)
			GVAR_TargetButton.ClassColorBackground:SetAlpha(0.25)
			GVAR_TargetButton.RangeTexture:SetAlpha(0)
			GVAR_TargetButton.HealthBar:SetAlpha(0.25)
			GVAR_TargetButton.ClassTexture:SetAlpha(0.25)
			if healerState then GVAR_TargetButton.HealersTexture:SetAlpha(0.25) end
 		elseif display == 13 then -- X 25 m
			GVAR_TargetButton.Background:SetAlpha(0.25)
			GVAR_TargetButton.TargetCountBackground:SetAlpha(0.25)
			GVAR_TargetButton.ClassColorBackground:SetAlpha(0.25)
			GVAR_TargetButton.RangeTexture:SetAlpha(0)
			GVAR_TargetButton.HealthBar:SetAlpha(0.25)
			GVAR_TargetButton.ClassTexture:SetAlpha(0.25)
			GVAR_TargetButton.ClassColorBackground:SetTexture(0.2, 0.2, 0.2, 1)
			GVAR_TargetButton.HealthBar:SetTexture(0.4, 0.4, 0.4, 1)
			if healerState then GVAR_TargetButton.HealersTexture:SetAlpha(0.25) end
		elseif display == 14 then -- X 10
			GVAR_TargetButton.Background:SetAlpha(0.10)
			GVAR_TargetButton.TargetCountBackground:SetAlpha(0.10)
			GVAR_TargetButton.ClassColorBackground:SetAlpha(0.10)
			GVAR_TargetButton.RangeTexture:SetAlpha(0)
			GVAR_TargetButton.HealthBar:SetAlpha(0.10)
			GVAR_TargetButton.ClassTexture:SetAlpha(0.10)
			if healerState then GVAR_TargetButton.HealersTexture:SetAlpha(0.10) end;
		else -- X 10 m
			GVAR_TargetButton.Background:SetAlpha(0.10)
			GVAR_TargetButton.TargetCountBackground:SetAlpha(0.10)
			GVAR_TargetButton.ClassColorBackground:SetAlpha(0.10)
			GVAR_TargetButton.RangeTexture:SetAlpha(0)
			GVAR_TargetButton.HealthBar:SetAlpha(0.10)
			GVAR_TargetButton.ClassTexture:SetAlpha(0.10)
			GVAR_TargetButton.ClassColorBackground:SetTexture(0.2, 0.2, 0.2, 1)
			GVAR_TargetButton.HealthBar:SetTexture(0.4, 0.4, 0.4, 1)
			if healerState then GVAR_TargetButton.HealersTexture:SetAlpha(0.10) end
		end
	end
end

--------------------------------------------------------------------------------------------------------

TEMPLATE.BorderTRBL = function(frame)
	frame.FrameBorder = frame:CreateTexture(nil, "BORDER");
	frame.FrameBorder:SetPoint("TOPLEFT", 1, -1);
	frame.FrameBorder:SetPoint("BOTTOMRIGHT", -1, 1);
	frame.FrameBorder:SetTexture(0, 0, 0, 1);
	frame.FrameBackground = frame:CreateTexture(nil, "BACKGROUND");
	frame.FrameBackground:SetPoint("TOPLEFT", 0, 0);
	frame.FrameBackground:SetPoint("BOTTOMRIGHT", 0, 0);
	frame.FrameBackground:SetTexture(0.8, 0.2, 0.2, 1);
end

TEMPLATE.DisableTextButton = function(button)
	button.Border:SetTexture(0.4, 0.4, 0.4, 1);
	button:Disable();
end

TEMPLATE.EnableTextButton = function(button, action)
	local buttoncolor;
	if(action == 1) then
		bordercolor = { 0.73, 0.26, 0.21, 1 };
	elseif(action == 2) then
		bordercolor = { 0.43, 0.32, 0.68, 1 };
	elseif(action == 3) then
		bordercolor = { 0.24, 0.46, 0.21, 1 };
	elseif(action == 4) then
		bordercolor = { 0.73, 0.26, 0.21, 1 };
	else
		bordercolor = { 1, 1, 1, 1 };
	end
	button.Border:SetTexture(bordercolor[1], bordercolor[2], bordercolor[3], bordercolor[4]);
	button:Enable();
end

TEMPLATE.TextButton = function(button, text, action)
	local buttoncolor;
	local bordercolor;

	if(action == 1) then
		button:SetNormalFontObject("GameFontNormal");
		button:SetDisabledFontObject("GameFontDisable");
		buttoncolor = { 0.38, 0, 0, 1 };
		bordercolor = { 0.73, 0.26, 0.21, 1 };
	elseif(action == 2) then
		button:SetNormalFontObject("GameFontNormalSmall");
		button:SetDisabledFontObject("GameFontDisableSmall");
		buttoncolor = { 0, 0, 0.5, 1 };
		bordercolor = { 0.43, 0.32, 0.68, 1 };
	elseif(action == 3) then
		button:SetNormalFontObject("GameFontNormalSmall");
		button:SetDisabledFontObject("GameFontDisableSmall");
		buttoncolor = { 0, 0.2, 0, 1 };
		bordercolor = { 0.24, 0.46, 0.21, 1 };
	elseif(action == 4) then
		button:SetNormalFontObject("GameFontNormalSmall");
		button:SetDisabledFontObject("GameFontDisableSmall");
		buttoncolor = { 0.38, 0, 0, 1 };
		bordercolor = { 0.73, 0.26, 0.21, 1 };
	else
		button:SetNormalFontObject("GameFontNormal");
		button:SetDisabledFontObject("GameFontDisable");
		buttoncolor = { 0, 0, 0, 1 };
		bordercolor = { 1, 1, 1, 1 };
	end
	
	button.Background = button:CreateTexture(nil, "BORDER");
	button.Background:SetPoint("TOPLEFT", 1, -1);
	button.Background:SetPoint("BOTTOMRIGHT", -1, 1);
	button.Background:SetTexture(0, 0, 0, 1);
	
	button.Border = button:CreateTexture(nil, "BACKGROUND");
	button.Border:SetPoint("TOPLEFT", 0, 0);
	button.Border:SetPoint("BOTTOMRIGHT", 0, 0);
	button.Border:SetTexture(bordercolor[1], bordercolor[2], bordercolor[3], bordercolor[4]);
	
	button.Normal = button:CreateTexture(nil, "ARTWORK");
	button.Normal:SetPoint("TOPLEFT", 2, -2);
	button.Normal:SetPoint("BOTTOMRIGHT", -2, 2);
	button.Normal:SetTexture(buttoncolor[1], buttoncolor[2], buttoncolor[3], buttoncolor[4]);
	button:SetNormalTexture(button.Normal);
	
	button.Disabled = button:CreateTexture(nil, "OVERLAY");
	button.Disabled:SetPoint("TOPLEFT", 3, -3);
	button.Disabled:SetPoint("BOTTOMRIGHT", -3, 3);
	button.Disabled:SetTexture(0.6, 0.6, 0.6, 0.2);
	button:SetDisabledTexture(button.Disabled);
	
	button.Highlight = button:CreateTexture(nil, "OVERLAY");
	button.Highlight:SetPoint("TOPLEFT", 3, -3);
	button.Highlight:SetPoint("BOTTOMRIGHT", -3, 3);
	button.Highlight:SetTexture(0.6, 0.6, 0.6, 0.2);
	button:SetHighlightTexture(button.Highlight);
	
	button:SetPushedTextOffset(1, -1);
	button:SetText(text);
end

TEMPLATE.IconButton = function(button, cut)
	button.Back = button:CreateTexture(nil, "BORDER");
	button.Back:SetPoint("TOPLEFT", 1, -1);
	button.Back:SetPoint("BOTTOMRIGHT", -1, 1);
	button.Back:SetTexture(0, 0, 0, 1);
	
	button.Border = button:CreateTexture(nil, "BACKGROUND");
	button.Border:SetPoint("TOPLEFT", 0, 0);
	button.Border:SetPoint("BOTTOMRIGHT", 0, 0);
	button.Border:SetTexture(0.8, 0.2, 0.2, 1);
	
	button.Highlight = button:CreateTexture(nil, "OVERLAY");
	button.Highlight:SetPoint("TOPLEFT", 3, -3);
	button.Highlight:SetPoint("BOTTOMRIGHT", -3, 3);
	button.Highlight:SetTexture(0.6, 0.6, 0.6, 0.2);
	button:SetHighlightTexture(button.Highlight);
	
	button.Normal = button:CreateTexture(nil, "ARTWORK");
	button.Normal:SetPoint("TOPLEFT", 3, -3);
	button.Normal:SetPoint("BOTTOMRIGHT", -3, 3);
	button.Normal:SetTexture(Textures.BattlegroundTargetsIcons.path);
	button.Normal:SetTexCoord(unpack(Textures.Close.coords));
	button:SetNormalTexture(button.Normal);
	
	button.Push = button:CreateTexture(nil, "ARTWORK");
	button.Push:SetPoint("TOPLEFT", 4, -4);
	button.Push:SetPoint("BOTTOMRIGHT", -4, 4);
	button.Push:SetTexture(Textures.BattlegroundTargetsIcons.path);
	button.Push:SetTexCoord(unpack(Textures.Close.coords));
	button:SetPushedTexture(button.Push);
	
	button.Disabled = button:CreateTexture(nil, "ARTWORK");
	button.Disabled:SetPoint("TOPLEFT", 3, -3);
	button.Disabled:SetPoint("BOTTOMRIGHT", -3, 3);
	button.Disabled:SetTexture(Textures.BattlegroundTargetsIcons.path);
	button.Disabled:SetTexCoord(unpack(Textures.Close.coords));
	button:SetDisabledTexture(button.Disabled);
	Desaturation(button.Disabled, true);
end

TEMPLATE.DisableCheckButton = function(button)
	if(button.Text) then
		button.Text:SetTextColor(0.5, 0.5, 0.5);
	elseif(button.Icon) then
		Desaturation(button.Icon, true);
	end
	button.Border:SetTexture(0.4, 0.4, 0.4, 1);
	button:Disable();
end

TEMPLATE.EnableCheckButton = function(button)
	if(button.Text) then
		button.Text:SetTextColor(1, 1, 1);
	elseif(button.Icon) then
		Desaturation(button.Icon, false);
	end
	button.Border:SetTexture(0.8, 0.2, 0.2, 1);
	button:Enable();
end

TEMPLATE.CheckButton = function(button, size, space, text, icon)
	button.Border = button:CreateTexture(nil, "BACKGROUND");
	button.Border:SetWidth(size);
	button.Border:SetHeight(size);
	button.Border:SetPoint("LEFT", 0, 0);
	button.Border:SetTexture(0.4, 0.4, 0.4, 1);
	
	button.Background = button:CreateTexture(nil, "BORDER");
	button.Background:SetPoint("TOPLEFT", button.Border, "TOPLEFT", 1, -1);
	button.Background:SetPoint("BOTTOMRIGHT", button.Border, "BOTTOMRIGHT", -1, 1);
	button.Background:SetTexture(0, 0, 0, 1);
	
	button.Normal = button:CreateTexture(nil, "ARTWORK");
	button.Normal:SetPoint("TOPLEFT", button.Border, "TOPLEFT", 1, -1);
	button.Normal:SetPoint("BOTTOMRIGHT", button.Border, "BOTTOMRIGHT", -1, 1);
	button.Normal:SetTexture(0, 0, 0, 1);
	button:SetNormalTexture(button.Normal);
	
	button.Push = button:CreateTexture(nil, "ARTWORK");
	button.Push:SetPoint("TOPLEFT", button.Border, "TOPLEFT", 4, -4);
	button.Push:SetPoint("BOTTOMRIGHT", button.Border, "BOTTOMRIGHT", -4, 4);
	button.Push:SetTexture(0.4, 0.4, 0.4, 0.5);
	button:SetPushedTexture(button.Push);
	
	button.Disabled = button:CreateTexture(nil, "ARTWORK");
	button.Disabled:SetPoint("TOPLEFT", button.Border, "TOPLEFT", 3, -3);
	button.Disabled:SetPoint("BOTTOMRIGHT", button.Border, "BOTTOMRIGHT", -3, 3);
	button.Disabled:SetTexture(0.4, 0.4, 0.4, 0.5);
	button:SetDisabledTexture(button.Disabled);
	
	button.Checked = button:CreateTexture(nil, "ARTWORK");
	button.Checked:SetWidth(size);
	button.Checked:SetHeight(size);
	button.Checked:SetPoint("LEFT", 0, 0);
	button.Checked:SetTexture("Interface\\Buttons\\UI-CheckBox-Check");
	button:SetCheckedTexture(button.Checked);
	
	if(icon) then
		if(icon == "default") then
			button.Icon = button:CreateTexture(nil, "BORDER");
			button.Icon:SetWidth(20);
			button.Icon:SetHeight(20);
			button.Icon:SetPoint("LEFT", button.Normal, "RIGHT", space, 0);
			button.Icon:SetTexture("Interface\\AddOns\\BattlegroundTargets\\Textures\\Target");
			button:SetWidth(size + space + 20 + space);
			button:SetHeight(size);
		elseif(icon == "bgt") then
			button.Icon = button:CreateTexture(nil, "BORDER");
			button.Icon:SetWidth(20);
			button.Icon:SetHeight(20);
			button.Icon:SetPoint("LEFT", button.Normal, "RIGHT", space, 0);
			button.Icon:SetTexture(AddonIcon);
			button:SetWidth(size + space + 20 + space);
			button:SetHeight(size);
		else
			button.Icon = button:CreateTexture(nil, "BORDER");
			button.Icon:SetWidth(Textures[icon].width);
			button.Icon:SetHeight(Textures[icon].height);
			button.Icon:SetPoint("LEFT", button.Normal, "RIGHT", space, 0);
			button.Icon:SetTexture(Textures.BattlegroundTargetsIcons.path);
			button.Icon:SetTexCoord(unpack(Textures[icon].coords));
			button:SetWidth(size + space + Textures[icon].width + space);
			button:SetHeight(size);
		end
	else
		button.Text = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
		button.Text:SetHeight(size);
		button.Text:SetPoint("LEFT", button.Normal, "RIGHT", space, 0);
		button.Text:SetJustifyH("LEFT");
		button.Text:SetText(text);
		button.Text:SetTextColor(1, 1, 1, 1);
		button:SetWidth(size + space + button.Text:GetStringWidth() + space);
		button:SetHeight(size);
	end
	
	button.Highlight = button:CreateTexture(nil, "OVERLAY");
	button.Highlight:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0);
	button.Highlight:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0);
	button.Highlight:SetTexture(1, 1, 1, 0.1);
	button.Highlight:Hide();

	button:SetScript("OnEnter", function() button.Highlight:Show(); end);
	button:SetScript("OnLeave", function() button.Highlight:Hide(); end);
end

TEMPLATE.SetTabButton = function(button, show)
	if(show) then
		button.TextureBottom:SetTexture(0, 0, 0, 1);
		button.TextureBorder:SetTexture(0.8, 0.2, 0.2, 1);
		button.show = true;
	else
		button.TextureBottom:SetTexture(0.8, 0.2, 0.2, 1);
		button.TextureBorder:SetTexture(0.4, 0.4, 0.4, 0.4);
		button.show = false;
	end
end

TEMPLATE.DisableTabButton = function(button)
	if(button.TabText) then
		button.TabText:SetTextColor(0.5, 0.5, 0.5, 1);
	elseif button.TabTexture then
		Desaturation(button.TabTexture, true);
	end
	button:Disable();
end

TEMPLATE.EnableTabButton = function(button, active)
	if(button.TabText) then
		if(active) then
			button.TabText:SetTextColor(0, 0.75, 0, 1);
		else
			button.TabText:SetTextColor(1, 0, 0, 1);
		end
	elseif(button.TabTexture) then
		Desaturation(button.TabTexture, false);
	end
	button:Enable();
end

TEMPLATE.TabButton = function(button, text, active)
	button.Texture = button:CreateTexture(nil, "BORDER");
	button.Texture:SetPoint("TOPLEFT", 1, -1);
	button.Texture:SetPoint("BOTTOMRIGHT", -1, 1);
	button.Texture:SetTexture(0, 0, 0, 1);
	
	button.TextureBorder = button:CreateTexture(nil, "BACKGROUND");
	button.TextureBorder:SetPoint("TOPLEFT", 0, 0);
	button.TextureBorder:SetPoint("BOTTOMRIGHT", -1, 1);
	button.TextureBorder:SetPoint("TOPRIGHT" ,0, 0);
	button.TextureBorder:SetPoint("BOTTOMLEFT" ,1, 1);
	button.TextureBorder:SetTexture(0.8, 0.2, 0.2, 1);
	
	button.TextureBottom = button:CreateTexture(nil, "ARTWORK");
	button.TextureBottom:SetPoint("TOPLEFT", button, "BOTTOMLEFT" ,1, 2);
	button.TextureBottom:SetPoint("BOTTOMLEFT" ,1, 1);
	button.TextureBottom:SetPoint("TOPRIGHT", button, "BOTTOMRIGHT" ,-1, 2);
	button.TextureBottom:SetPoint("BOTTOMRIGHT" ,-1, 1);
	button.TextureBottom:SetTexture(0.8, 0.2, 0.2, 1);
	
	button.TextureHighlight = button:CreateTexture(nil, "ARTWORK");
	button.TextureHighlight:SetPoint("TOPLEFT", 3, -3);
	button.TextureHighlight:SetPoint("BOTTOMRIGHT", -3, 3);
	button.TextureHighlight:SetTexture(1, 1, 1, 0.1);
	button:SetHighlightTexture(button.TextureHighlight);
	
	if(text) then
		button.TabText = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
		button.TabText:SetText(text);
		button.TabText:SetWidth( button.TabText:GetStringWidth() + 10);
		button.TabText:SetHeight(12);
		button.TabText:SetPoint("CENTER", button, "CENTER", 0, 0);
		button.TabText:SetJustifyH("CENTER");
		button.TabText:SetTextColor(1, 1, 1, 1);
		
		if(active) then
			button.TabText:SetTextColor(0, 0.75, 0, 1);
		else
			button.TabText:SetTextColor(1, 0, 0, 1);
		end
	else
		button.TabTexture = button:CreateTexture(nil, "OVERLAY");
		button.TabTexture:SetPoint("CENTER", 0, 0);
		button.TabTexture:SetWidth(17);
		button.TabTexture:SetHeight(17);
		button.TabTexture:SetTexture(AddonIcon);
	end
	
	button:SetScript("OnEnter", function() if(not button.show) then button.TextureBorder:SetTexture(0.4, 0.4, 0.4, 0.8); end end);
	button:SetScript("OnLeave", function() if(not button.show) then button.TextureBorder:SetTexture(0.4, 0.4, 0.4, 0.4); end end);
end

TEMPLATE.DisableSlider = function(slider)
	slider.textMin:SetTextColor(0.5, 0.5, 0.5, 1);
	slider.textMax:SetTextColor(0.5, 0.5, 0.5, 1);
	slider.sliderBGL:SetTexCoord(unpack(Textures.SliderBG.coordsLdis));
	slider.sliderBGM:SetTexCoord(unpack(Textures.SliderBG.coordsMdis));
	slider.sliderBGR:SetTexCoord(unpack(Textures.SliderBG.coordsRdis));
	slider.thumb:SetTexCoord(0, 0, 0, 0);
	slider.Background:SetTexture(0, 0, 0, 0);
	slider:SetScript("OnEnter", NOOP);
	slider:SetScript("OnLeave", NOOP);
	slider:Disable();
end

TEMPLATE.EnableSlider = function(slider)
	slider.textMin:SetTextColor(0.8, 0.8, 0.8, 1);
	slider.textMax:SetTextColor(0.8, 0.8, 0.8, 1);
	slider.sliderBGL:SetTexCoord(unpack(Textures.SliderBG.coordsL));
	slider.sliderBGM:SetTexCoord(unpack(Textures.SliderBG.coordsM));
	slider.sliderBGR:SetTexCoord(unpack(Textures.SliderBG.coordsR));
	slider.thumb:SetTexCoord(unpack(Textures.SliderKnob.coords))
	slider:SetScript("OnEnter", function() slider.Background:SetTexture(1, 1, 1, 0.1); end);
	slider:SetScript("OnLeave", function() slider.Background:SetTexture(0, 0, 0, 0); end);
	slider:Enable();
end

TEMPLATE.Slider = function(slider, width, step, minVal, maxVal, curVal, func, measure)
	slider:SetWidth(width);
	slider:SetHeight(16);
	slider:SetValueStep(step);
	slider:SetMinMaxValues(minVal, maxVal);
	slider:SetValue(curVal);
	slider:SetOrientation("HORIZONTAL");
	
	slider.Background = slider:CreateTexture(nil, "BACKGROUND");
	slider.Background:SetWidth(width);
	slider.Background:SetHeight(16);
	slider.Background:SetPoint("LEFT", 0, 0);
	slider.Background:SetTexture(0, 0, 0, 0);
	
	slider.textMin = slider:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	slider.textMin:SetPoint("TOP", slider, "BOTTOM", 0, -1);
	slider.textMin:SetPoint("LEFT", slider, "LEFT", 0, 0);
	slider.textMin:SetJustifyH("CENTER");
	slider.textMin:SetTextColor(0.8, 0.8, 0.8, 1);
	
	if(measure == "%") then
		slider.textMin:SetText(minVal.."%");
	elseif(measure == "K") then
		slider.textMin:SetText((minVal/1000).."k");
	elseif(measure == "H") then
		slider.textMin:SetText((minVal/100));
	elseif(measure == "px") then
		slider.textMin:SetText(minVal.."px");
	elseif(measure == "blank") then
		slider.textMin:SetText("");
	else
		slider.textMin:SetText(minVal);
	end
	
	slider.textMax = slider:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	slider.textMax:SetPoint("TOP", slider, "BOTTOM", 0, -1);
	slider.textMax:SetPoint("RIGHT", slider, "RIGHT", 0, 0);
	slider.textMax:SetJustifyH("CENTER");
	slider.textMax:SetTextColor(0.8, 0.8, 0.8, 1);
	
	if(measure == "%") then
		slider.textMax:SetText(maxVal.."%");
	elseif(measure == "K") then
		slider.textMax:SetText((maxVal/1000).."k");
	elseif(measure == "H") then
		slider.textMax:SetText((maxVal/100));
	elseif(measure == "px") then
		slider.textMax:SetText(maxVal.."px");
	elseif(measure == "blank") then
		slider.textMax:SetText("");
	else
		slider.textMax:SetText(maxVal);
	end
	
	slider.sliderBGL = slider:CreateTexture(nil, "BACKGROUND");
	slider.sliderBGL:SetWidth(5);
	slider.sliderBGL:SetHeight(6);
	slider.sliderBGL:SetPoint("LEFT", slider, "LEFT", 0, 0);
	slider.sliderBGL:SetTexture(Textures.BattlegroundTargetsIcons.path);
	slider.sliderBGL:SetTexCoord(unpack(Textures.SliderBG.coordsL));
	slider.sliderBGM = slider:CreateTexture(nil, "BACKGROUND");
	slider.sliderBGM:SetWidth(width - 5 - 5);
	slider.sliderBGM:SetHeight(6);
	slider.sliderBGM:SetPoint("LEFT", slider.sliderBGL, "RIGHT", 0, 0);
	slider.sliderBGM:SetTexture(Textures.BattlegroundTargetsIcons.path);
	slider.sliderBGM:SetTexCoord(unpack(Textures.SliderBG.coordsM));
	slider.sliderBGR = slider:CreateTexture(nil, "BACKGROUND");
	slider.sliderBGR:SetWidth(5);
	slider.sliderBGR:SetHeight(6);
	slider.sliderBGR:SetPoint("LEFT", slider.sliderBGM, "RIGHT", 0, 0);
	slider.sliderBGR:SetTexture(Textures.BattlegroundTargetsIcons.path);
	slider.sliderBGR:SetTexCoord(unpack(Textures.SliderBG.coordsR));
	
	slider.thumb = slider:CreateTexture(nil, "BORDER");
	slider.thumb:SetWidth(11);
	slider.thumb:SetHeight(17);
	slider.thumb:SetTexture(Textures.BattlegroundTargetsIcons.path);
	slider.thumb:SetTexCoord(unpack(Textures.SliderKnob.coords));
	slider:SetThumbTexture(slider.thumb);

	slider:SetScript("OnValueChanged", function(self, value)
		if(not slider:IsEnabled()) then return; end
		
		if(func) then
			func(self, value);
		end
	end);

	slider:SetScript("OnEnter", function() slider.Background:SetTexture(1, 1, 1, 0.1); end);
	slider:SetScript("OnLeave", function() slider.Background:SetTexture(0, 0, 0, 0); end);
end

TEMPLATE.DisablePullDownMenu = function(button)
	button.PullDownMenu:Hide();
	button.PullDownButtonBorder:SetTexture(0.4, 0.4, 0.4, 1);
	button:Disable();
end

TEMPLATE.EnablePullDownMenu = function(button)
	button.PullDownButtonBorder:SetTexture(0.8, 0.2, 0.2, 1);
	button:Enable();
end

TEMPLATE.PullDownMenu = function(button, contentName, buttonText, pulldownWidth, contentNum, func)
	button.PullDownButtonBG = button:CreateTexture(nil, "BORDER");
	button.PullDownButtonBG:SetPoint("TOPLEFT", 1, -1);
	button.PullDownButtonBG:SetPoint("BOTTOMRIGHT", -1, 1);
	button.PullDownButtonBG:SetTexture(0, 0, 0, 1);
	
	button.PullDownButtonBorder = button:CreateTexture(nil, "BACKGROUND");
	button.PullDownButtonBorder:SetPoint("TOPLEFT", 0, 0);
	button.PullDownButtonBorder:SetPoint("BOTTOMRIGHT", 0, 0);
	button.PullDownButtonBorder:SetTexture(0.4, 0.4, 0.4, 1);
	
	button.PullDownButtonExpand = button:CreateTexture(nil, "OVERLAY");
	button.PullDownButtonExpand:SetHeight(14);
	button.PullDownButtonExpand:SetWidth(14);
	button.PullDownButtonExpand:SetPoint("RIGHT", button, "RIGHT", -2, 0);
	button.PullDownButtonExpand:SetTexture(Textures.BattlegroundTargetsIcons.path);
	button.PullDownButtonExpand:SetTexCoord(unpack(Textures.Expand.coords));
	button:SetNormalTexture(button.PullDownButtonExpand);
	
	button.PullDownButtonDisabled = button:CreateTexture(nil, "OVERLAY");
	button.PullDownButtonDisabled:SetPoint("TOPLEFT", 3, -3);
	button.PullDownButtonDisabled:SetPoint("BOTTOMRIGHT", -3, 3);
	button.PullDownButtonDisabled:SetTexture(0.6, 0.6, 0.6, 0.2);
	button:SetDisabledTexture(button.PullDownButtonDisabled);
	
	button.PullDownButtonHighlight = button:CreateTexture(nil, "OVERLAY");
	button.PullDownButtonHighlight:SetPoint("TOPLEFT", 1, -1);
	button.PullDownButtonHighlight:SetPoint("BOTTOMRIGHT", -1, 1);
	button.PullDownButtonHighlight:SetTexture(0.6, 0.6, 0.6, 0.2);
	button:SetHighlightTexture(button.PullDownButtonHighlight);
	
	button.PullDownButtonText = button:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	button.PullDownButtonText:SetHeight(sizeBarHeight);
	button.PullDownButtonText:SetPoint("LEFT", sizeOffset + 2, 0);
	button.PullDownButtonText:SetJustifyH("LEFT");
	button.PullDownButtonText:SetText(buttonText);
	button.PullDownButtonText:SetTextColor(1, 1, 0.49, 1);
	
	button.PullDownMenu = CreateFrame("Frame", nil, button);
	TEMPLATE.BorderTRBL(button.PullDownMenu);
	button.PullDownMenu:EnableMouse(true);
	button.PullDownMenu:SetToplevel(true);
	button.PullDownMenu:SetHeight(sizeOffset + (contentNum * sizeBarHeight) + sizeOffset)
	button.PullDownMenu:SetPoint("TOPLEFT", button, "BOTTOMLEFT", 0, 1);
	button.PullDownMenu:Hide();

	local function OnLeave()
		if(not button:IsMouseOver() and not button.PullDownMenu:IsMouseOver()) then
			button.PullDownMenu:Hide();
			button.PullDownButtonExpand:SetTexCoord(unpack(Textures.Expand.coords));
		end
	end

	local autoWidth = 0;
	for i = 1, contentNum do
		if(not button.PullDownMenu.Button) then button.PullDownMenu.Button = {}; end
		
		button.PullDownMenu.Button[i] = CreateFrame("Button", nil, button.PullDownMenu);
		button.PullDownMenu.Button[i]:SetHeight(sizeBarHeight);
		button.PullDownMenu.Button[i]:SetFrameLevel( button.PullDownMenu:GetFrameLevel() + 5);
		
		if(i == 1) then
			button.PullDownMenu.Button[i]:SetPoint("TOPLEFT", button.PullDownMenu, "TOPLEFT", sizeOffset, -sizeOffset);
		else
			button.PullDownMenu.Button[i]:SetPoint("TOPLEFT", button.PullDownMenu.Button[(i-1)], "BOTTOMLEFT", 0, 0);
		end
		
		button.PullDownMenu.Button[i].Text = button.PullDownMenu.Button[i]:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
		button.PullDownMenu.Button[i].Text:SetHeight(sizeBarHeight);
		button.PullDownMenu.Button[i].Text:SetPoint("LEFT", 2, 0);
		button.PullDownMenu.Button[i].Text:SetJustifyH("LEFT");
		button.PullDownMenu.Button[i].Text:SetTextColor(1, 1, 1, 1);

		button.PullDownMenu.Button[i]:SetScript("OnLeave", OnLeave);
		button.PullDownMenu.Button[i]:SetScript("OnClick", function()
			button.value1 = button.PullDownMenu.Button[i].value1;
			button.PullDownButtonText:SetText(button.PullDownMenu.Button[i].Text:GetText())
			button.PullDownMenu:Hide();
			button.PullDownButtonExpand:SetTexCoord(unpack(Textures.Expand.coords));
			if(func) then
				func(button.value1);
			end
		end);
		
		button.PullDownMenu.Button[i].Highlight = button.PullDownMenu.Button[i]:CreateTexture(nil, "ARTWORK");
		button.PullDownMenu.Button[i].Highlight:SetPoint("TOPLEFT", 0, 0);
		button.PullDownMenu.Button[i].Highlight:SetPoint("BOTTOMRIGHT", 0, 0);
		button.PullDownMenu.Button[i].Highlight:SetTexture(1, 1, 1, 0.2);
		button.PullDownMenu.Button[i]:SetHighlightTexture(button.PullDownMenu.Button[i].Highlight);

		if(contentName == "SortBy") then
			button.PullDownMenu.Button[i].Text:SetText(sortBy[i]);
			button.PullDownMenu.Button[i].value1 = i;
		elseif(contentName == "SortDetail") then
			button.PullDownMenu.Button[i].Text:SetText(sortDetail[i]);
			button.PullDownMenu.Button[i].value1 = i;
		elseif(contentName == "RangeType") then
			button.PullDownMenu.Button[i].Text:SetText(rangeTypeName[i]);
			button.PullDownMenu.Button[i].value1 = i;
		elseif(contentName == "RangeDisplay") then
			button.PullDownMenu.Button[i].Text:SetText(rangeDisplay[i]);
			button.PullDownMenu.Button[i].value1 = i;
		elseif(contentName == "ShowHealer") then
			button.PullDownMenu.Button[i].Text:SetText(roleLayoutPos[i]);
			button.PullDownMenu.Button[i].value1 = i;
		end
		
		button.PullDownMenu.Button[i]:Show();
		
		if(pulldownWidth == 0) then
			local w = button.PullDownMenu.Button[i].Text:GetStringWidth() + 15 + 18;
			if(w > autoWidth) then
				autoWidth = w;
			end
		end
	end
	
	local newWidth = pulldownWidth;
	if(pulldownWidth == 0) then
		newWidth = autoWidth;
	end
	
	button.PullDownButtonText:SetWidth(newWidth - sizeOffset - sizeOffset);
	button.PullDownMenu:SetWidth(newWidth);
	
	for i = 1, contentNum do
		button.PullDownMenu.Button[i]:SetWidth(newWidth - sizeOffset - sizeOffset);
		button.PullDownMenu.Button[i].Text:SetWidth(newWidth - sizeOffset - sizeOffset);
	end
	
	button:SetWidth(newWidth);
	
	button.PullDownMenu:SetScript("OnLeave", OnLeave);
	button.PullDownMenu:SetScript("OnHide", function(self) self:Hide(); end);
	
	button:SetScript("OnLeave", OnLeave);
	button:SetScript("OnClick", function()
		if(button.PullDownMenu:IsShown()) then
			button.PullDownMenu:Hide();
			button.PullDownButtonExpand:SetTexCoord(unpack(Textures.Expand.coords));
		else
			button.PullDownMenu:Show();
			button.PullDownButtonExpand:SetTexCoord(unpack(Textures.Collapse.coords));
		end
	end);
end

--------------------------------------------------------------------------------------------------------

function BattlegroundTargets:InitOptions()

	SLASH_BATTLEGROUNDTARGETS1 = "/bgt";
	SLASH_BATTLEGROUNDTARGETS2 = "/bgtargets";
	SLASH_BATTLEGROUNDTARGETS3 = "/battlegroundtargets";
	
	SlashCmdList["BATTLEGROUNDTARGETS"] = function(arg)

		local text, id = arg:match("(%w+)%s?(%d*)")
		local isShowHealersBtn = OPT.ButtonShowHealer[10] or OPT.ButtonShowHealer[15] or OPT.ButtonShowHealer[40];

		if text and isShowHealersBtn then
			if text == "help" then
				local helpStr = L["Available commands:"].."\n";
				helpStr = helpStr.."  |cff55c912/bgt hdlog|r -- "..L["To log healer detections while you are in a BG."].." \n";
				helpStr = helpStr.."  |cff55c912/bgt hdlogAlways|r -- "..L["To enable permanent healer detection mode while you are in BG. After that, you don't need to enter /bgt hdlog every time"].."\n";
				helpStr = helpStr.."  |cff55c912/bgt hdreport|r -- "..L["To show full info about all healers detects."].."\n";
				helpStr = helpStr.."  |cff55c912/bgt dbStoragePeriod <number>|r -- "..L["GET or SET (if the number exists) retention period of the data in months, after which the obsolete data about healer will be deleted. If <number> is set up to 0 then DataBase will be disabled."].."\n";
				Print(helpStr);

			elseif text == "hdlog" then 
				if not hdlog then
					Print(L["Logging of healers detection is enabled.\nType |cff55c912/bgt hdlog|r again to disable."])
					hdlog = true;
				else
					Print(L["Logging of healers detection is disabled."])
					hdlog = false;
				end
	
			elseif text == "hdreport" then
				local next = next;
				if inBattleground then
					if next(ENEMY_Healers) then 
						BattlegroundTargets:HDreport();
					else
						Print(L["Something is wrong! Not possible to prepare info for the report. The option: 'Show roles' should be enabled. Or try to get report later."])
					end
				else 
					Print(L["You should be in some battleground to call reports."]) 
				end

			elseif text == "dbStoragePeriod" then
				local dbPrefix = "|cffffff7f[DB]|r"
				id = tonumber(id); 
				if id then
					if 0 > id or id > 12  then
						Print(dbPrefix,L["Unable to set this period. You must use values in the range of 0 to 11."]);
					else
						if id > 0 then 
							Print(dbPrefix, L["Healers data will now be deleted from the database after "].."|cffffff7f"..id.."|r"..L["months. You need to re-login to save settings."])
						elseif id == 0 then 
							Print(dbPrefix, L["DB is disabled. You need to re-login to save settings."])
						end 
						BattlegroundTargets_Options.DB.outOfDateRange = id;
					end
				else
					if BattlegroundTargets_Options.DB then
						if BattlegroundTargets_Options.DB.outOfDateRange and BattlegroundTargets_Options.DB.outOfDateRange == 0 then
							Print(dbPrefix, "At now DB is disabled. You can enable it with the following '/bgt dbStoragePeriod <number>' command.")
						else
							if not BattlegroundTargets_Options.DB.outOfDateRange then BattlegroundTargets_Options.DB.outOfDateRange = 3; end
							Print(dbPrefix,L["Current storage period of data is: "].."|cffffff7f"..BattlegroundTargets_Options.DB.outOfDateRange.."|r"..L[" months. Max period is 11 months."])
						end
					else
						Print("Unknown error!") 
					end
				end

			elseif text == "hdlogAlways" then
				if not BattlegroundTargets_Options.hdlog then
					BattlegroundTargets_Options.hdlog = true;
					hdlog = true;
					Print(L["Permanent logging of healers detection is enabled. Type |cff55c912/bgt hdlogAlways|r again to disable."])
				else
					BattlegroundTargets_Options.hdlog = false;
					Print(L["Permanent logging of healers detection is disabled."])
				end;
			end
		elseif text and not isShowHealersBtn then
			Print(L["[Warning]: To use that command you have to pick 'Show roles' option in the settings panel of BattlegroundTargets."])
		else
			BattlegroundTargets:Frame_Toggle(GVAR.OptionsFrame)
		end;
	end
	
	-- BattlegroundTargets_getRealms()();

	if(BattlegroundTargets_Options.version == nil) then
		BattlegroundTargets_Options.version = 14
	end

	if BattlegroundTargets_Options.version == 1 then
		if BattlegroundTargets_Options.ButtonFontSize then
			if BattlegroundTargets_Options.ButtonFontSize[10] then
				if     BattlegroundTargets_Options.ButtonFontSize[10] == 1 then BattlegroundTargets_Options.ButtonFontSize[10] =  9
				elseif BattlegroundTargets_Options.ButtonFontSize[10] == 2 then BattlegroundTargets_Options.ButtonFontSize[10] = 10
				elseif BattlegroundTargets_Options.ButtonFontSize[10] == 3 then BattlegroundTargets_Options.ButtonFontSize[10] = 12
				elseif BattlegroundTargets_Options.ButtonFontSize[10] == 4 then BattlegroundTargets_Options.ButtonFontSize[10] = 14
				elseif BattlegroundTargets_Options.ButtonFontSize[10] == 5 then BattlegroundTargets_Options.ButtonFontSize[10] = 16
				end
			end
			if BattlegroundTargets_Options.ButtonFontSize[15] then
				if     BattlegroundTargets_Options.ButtonFontSize[15] == 1 then BattlegroundTargets_Options.ButtonFontSize[15] =  9
				elseif BattlegroundTargets_Options.ButtonFontSize[15] == 2 then BattlegroundTargets_Options.ButtonFontSize[15] = 10
				elseif BattlegroundTargets_Options.ButtonFontSize[15] == 3 then BattlegroundTargets_Options.ButtonFontSize[15] = 12
				elseif BattlegroundTargets_Options.ButtonFontSize[15] == 4 then BattlegroundTargets_Options.ButtonFontSize[15] = 14
				elseif BattlegroundTargets_Options.ButtonFontSize[15] == 5 then BattlegroundTargets_Options.ButtonFontSize[15] = 16
				end
			end
			if BattlegroundTargets_Options.ButtonFontSize[40] then
				if     BattlegroundTargets_Options.ButtonFontSize[40] == 1 then BattlegroundTargets_Options.ButtonFontSize[40] =  9
				elseif BattlegroundTargets_Options.ButtonFontSize[40] == 2 then BattlegroundTargets_Options.ButtonFontSize[40] = 10
				elseif BattlegroundTargets_Options.ButtonFontSize[40] == 3 then BattlegroundTargets_Options.ButtonFontSize[40] = 12
				elseif BattlegroundTargets_Options.ButtonFontSize[40] == 4 then BattlegroundTargets_Options.ButtonFontSize[40] = 14
				elseif BattlegroundTargets_Options.ButtonFontSize[40] == 5 then BattlegroundTargets_Options.ButtonFontSize[40] = 16
				end
			end
			Print("Fontsize update! Please check Configuration.")
		end
		BattlegroundTargets_Options.version = 2
	end

	if BattlegroundTargets_Options.version == 2 then
		if BattlegroundTargets_Options.ButtonShowCrosshairs then -- rename ButtonShowCrosshairs to ButtonShowTargetIndicator
			BattlegroundTargets_Options.ButtonShowTargetIndicator = {}
			if BattlegroundTargets_Options.ButtonShowCrosshairs[10] then BattlegroundTargets_Options.ButtonShowTargetIndicator[10] = true else BattlegroundTargets_Options.ButtonShowTargetIndicator[10] = false end
			if BattlegroundTargets_Options.ButtonShowCrosshairs[15] then BattlegroundTargets_Options.ButtonShowTargetIndicator[15] = true else BattlegroundTargets_Options.ButtonShowTargetIndicator[15] = false end
			if BattlegroundTargets_Options.ButtonShowCrosshairs[40] then BattlegroundTargets_Options.ButtonShowTargetIndicator[40] = true else BattlegroundTargets_Options.ButtonShowTargetIndicator[40] = false end
			BattlegroundTargets_Options.ButtonShowCrosshairs = nil
		end
		BattlegroundTargets_Options.version = 3
	end

	if BattlegroundTargets_Options.version == 3 then
		if BattlegroundTargets_Options.ButtonShowTargetIndicator then -- rename ButtonShowTargetIndicator to ButtonShowTarget
			BattlegroundTargets_Options.ButtonShowTarget = {}
			if BattlegroundTargets_Options.ButtonShowTargetIndicator[10] then BattlegroundTargets_Options.ButtonShowTarget[10] = true else BattlegroundTargets_Options.ButtonShowTarget[10] = false end
			if BattlegroundTargets_Options.ButtonShowTargetIndicator[15] then BattlegroundTargets_Options.ButtonShowTarget[15] = true else BattlegroundTargets_Options.ButtonShowTarget[15] = false end
			if BattlegroundTargets_Options.ButtonShowTargetIndicator[40] then BattlegroundTargets_Options.ButtonShowTarget[40] = true else BattlegroundTargets_Options.ButtonShowTarget[40] = false end
			BattlegroundTargets_Options.ButtonShowTargetIndicator = nil
		end
		if BattlegroundTargets_Options.ButtonShowFocusIndicator then -- rename ButtonShowFocusIndicator to ButtonShowFocus
			BattlegroundTargets_Options.ButtonShowFocus = {}
			if BattlegroundTargets_Options.ButtonShowFocusIndicator[10] then BattlegroundTargets_Options.ButtonShowFocus[10] = true else BattlegroundTargets_Options.ButtonShowFocus[10] = false end
			if BattlegroundTargets_Options.ButtonShowFocusIndicator[15] then BattlegroundTargets_Options.ButtonShowFocus[15] = true else BattlegroundTargets_Options.ButtonShowFocus[15] = false end
			if BattlegroundTargets_Options.ButtonShowFocusIndicator[40] then BattlegroundTargets_Options.ButtonShowFocus[40] = true else BattlegroundTargets_Options.ButtonShowFocus[40] = false end
			BattlegroundTargets_Options.ButtonShowFocusIndicator = nil
		end
		BattlegroundTargets_Options.version = 4
	end
	
	if BattlegroundTargets_Options.version == 4 then
		if BattlegroundTargets_Options.ButtonShowRealm then -- rename ButtonShowRealm to ButtonHideRealm
			BattlegroundTargets_Options.ButtonHideRealm = {}
			if BattlegroundTargets_Options.ButtonShowRealm[10] then BattlegroundTargets_Options.ButtonHideRealm[10] = false else BattlegroundTargets_Options.ButtonHideRealm[10] = true end
			if BattlegroundTargets_Options.ButtonShowRealm[15] then BattlegroundTargets_Options.ButtonHideRealm[15] = false else BattlegroundTargets_Options.ButtonHideRealm[15] = true end
			if BattlegroundTargets_Options.ButtonShowRealm[40] then BattlegroundTargets_Options.ButtonHideRealm[40] = false else BattlegroundTargets_Options.ButtonHideRealm[40] = true end
			BattlegroundTargets_Options.ButtonShowRealm = nil
		end
		BattlegroundTargets_Options.version = 5
	end

	if BattlegroundTargets_Options.version == 5 then
		if BattlegroundTargets_Options.ButtonSortBySize then -- rename ButtonSortBySize to ButtonSortBy
			BattlegroundTargets_Options.ButtonSortBy = {}
			if BattlegroundTargets_Options.ButtonSortBySize[10] then BattlegroundTargets_Options.ButtonSortBy[10] = BattlegroundTargets_Options.ButtonSortBySize[10] end
			if BattlegroundTargets_Options.ButtonSortBySize[15] then BattlegroundTargets_Options.ButtonSortBy[15] = BattlegroundTargets_Options.ButtonSortBySize[15] end
			if BattlegroundTargets_Options.ButtonSortBySize[40] then BattlegroundTargets_Options.ButtonSortBy[40] = BattlegroundTargets_Options.ButtonSortBySize[40] end
			BattlegroundTargets_Options.ButtonSortBySize = nil
		end
		local x
		if BattlegroundTargets_Options.ButtonTargetScale then
			if BattlegroundTargets_Options.ButtonTargetScale[10] > 2 then x=1 BattlegroundTargets_Options.ButtonTargetScale[10] = 2 end
			if BattlegroundTargets_Options.ButtonTargetScale[15] > 2 then x=1 BattlegroundTargets_Options.ButtonTargetScale[15] = 2 end
			if BattlegroundTargets_Options.ButtonTargetScale[40] > 2 then x=1 BattlegroundTargets_Options.ButtonTargetScale[40] = 2 end
		end
		if BattlegroundTargets_Options.ButtonFocusScale then
			if BattlegroundTargets_Options.ButtonFocusScale[10] > 2 then x=1 BattlegroundTargets_Options.ButtonFocusScale[10] = 2 end
			if BattlegroundTargets_Options.ButtonFocusScale[15] > 2 then x=1 BattlegroundTargets_Options.ButtonFocusScale[15] = 2 end
			if BattlegroundTargets_Options.ButtonFocusScale[40] > 2 then x=1 BattlegroundTargets_Options.ButtonFocusScale[40] = 2 end
		end
		if BattlegroundTargets_Options.ButtonFlagScale then
			if BattlegroundTargets_Options.ButtonFlagScale[10] > 2 then x=1 BattlegroundTargets_Options.ButtonFlagScale[10] = 2 end
			if BattlegroundTargets_Options.ButtonFlagScale[15] > 2 then x=1 BattlegroundTargets_Options.ButtonFlagScale[15] = 2 end
			if BattlegroundTargets_Options.ButtonFlagScale[40] > 2 then x=1 BattlegroundTargets_Options.ButtonFlagScale[40] = 2 end
		end
		if BattlegroundTargets_Options.ButtonAssistScale then
			if BattlegroundTargets_Options.ButtonAssistScale[10] > 2 then x=1 BattlegroundTargets_Options.ButtonAssistScale[10] = 2 end
			if BattlegroundTargets_Options.ButtonAssistScale[15] > 2 then x=1 BattlegroundTargets_Options.ButtonAssistScale[15] = 2 end
			if BattlegroundTargets_Options.ButtonAssistScale[40] > 2 then x=1 BattlegroundTargets_Options.ButtonAssistScale[40] = 2 end
		end
		if x then
			Print("Icon scale update! 200% is now maximum. Please check Configuration.")
		end
		BattlegroundTargets_Options.version = 6
	end

	if BattlegroundTargets_Options.version == 6 then
		if BattlegroundTargets_Options.ButtonShowHealthBar then -- update for health bar and health text independence
			if BattlegroundTargets_Options.ButtonShowHealthText[10] == true and BattlegroundTargets_Options.ButtonShowHealthBar[10] == false then
				BattlegroundTargets_Options.ButtonShowHealthText[10] = false
			end
			if BattlegroundTargets_Options.ButtonShowHealthText[15] == true and BattlegroundTargets_Options.ButtonShowHealthBar[15] == false then
				BattlegroundTargets_Options.ButtonShowHealthText[15] = false
			end
			if BattlegroundTargets_Options.ButtonShowHealthText[40] == true and BattlegroundTargets_Options.ButtonShowHealthBar[40] == false then
				BattlegroundTargets_Options.ButtonShowHealthText[40] = false
			end
		end
		BattlegroundTargets_Options.version = 7
	end

	if BattlegroundTargets_Options.version == 7 then
		if BattlegroundTargets_Options.ButtonEnableBracket then -- rename ButtonEnableBracket to EnableBracket
			BattlegroundTargets_Options.EnableBracket = {}
			if BattlegroundTargets_Options.ButtonEnableBracket[10] == true then BattlegroundTargets_Options.EnableBracket[10] = true else BattlegroundTargets_Options.EnableBracket[10] = false end
			if BattlegroundTargets_Options.ButtonEnableBracket[15] == true then BattlegroundTargets_Options.EnableBracket[15] = true else BattlegroundTargets_Options.EnableBracket[15] = false end
			if BattlegroundTargets_Options.ButtonEnableBracket[40] == true then BattlegroundTargets_Options.EnableBracket[40] = true else BattlegroundTargets_Options.EnableBracket[40] = false end
			BattlegroundTargets_Options.ButtonEnableBracket = nil
		end
		BattlegroundTargets_Options.version = 8
	end

	if BattlegroundTargets_Options.version == 8 then
		if BattlegroundTargets_Options.EnableBracket and BattlegroundTargets_Options.EnableBracket[40] then -- new user: default | old user: old setting
			BattlegroundTargets_Options.Layout40 = 18
		end
		BattlegroundTargets_Options.version = 9
	end

	if BattlegroundTargets_Options.version == 9 then
		BattlegroundTargets_Options.ButtonRangeAlpha = nil
		BattlegroundTargets_Options.version = 10
	end

	if BattlegroundTargets_Options.version == 10 then
		BattlegroundTargets_Options.TargetIcon = "bgt"
		BattlegroundTargets_Options.version = 11
	end

	if BattlegroundTargets_Options.version == 11 then
		if BattlegroundTargets_Options.Layout40 then -- copy old 40s settings to the new variable
			BattlegroundTargets_Options.LayoutTH = {}
			BattlegroundTargets_Options.LayoutTH[40] = BattlegroundTargets_Options.Layout40
			BattlegroundTargets_Options.Layout40 = nil
		end
		if BattlegroundTargets_Options.Layout40space then -- copy old 40s settings to the new variable
			BattlegroundTargets_Options.LayoutSpace = {}
			BattlegroundTargets_Options.LayoutSpace[40] = BattlegroundTargets_Options.Layout40space
			BattlegroundTargets_Options.Layout40space = nil
		end
		BattlegroundTargets_Options.version = 12
	end

	if BattlegroundTargets_Options.version == 13 then -- range check option change
		BattlegroundTargets_Options.ButtonTypeRangeCheck = {}
		if BattlegroundTargets_Options.ButtonAvgRangeCheck then
			if BattlegroundTargets_Options.ButtonAvgRangeCheck[10] == true then BattlegroundTargets_Options.ButtonTypeRangeCheck[10] = 1 else BattlegroundTargets_Options.ButtonTypeRangeCheck[10] = 2 end
			if BattlegroundTargets_Options.ButtonAvgRangeCheck[15] == true then BattlegroundTargets_Options.ButtonTypeRangeCheck[15] = 1 else BattlegroundTargets_Options.ButtonTypeRangeCheck[15] = 2 end
			if BattlegroundTargets_Options.ButtonAvgRangeCheck[40] == true then BattlegroundTargets_Options.ButtonTypeRangeCheck[40] = 1 else BattlegroundTargets_Options.ButtonTypeRangeCheck[40] = 2 end
		elseif BattlegroundTargets_Options.ButtonClassRangeCheck then
			if BattlegroundTargets_Options.ButtonClassRangeCheck[10] == true then BattlegroundTargets_Options.ButtonTypeRangeCheck[10] = 2 else BattlegroundTargets_Options.ButtonTypeRangeCheck[10] = 1 end
			if BattlegroundTargets_Options.ButtonClassRangeCheck[15] == true then BattlegroundTargets_Options.ButtonTypeRangeCheck[15] = 2 else BattlegroundTargets_Options.ButtonTypeRangeCheck[15] = 1 end
			if BattlegroundTargets_Options.ButtonClassRangeCheck[40] == true then BattlegroundTargets_Options.ButtonTypeRangeCheck[40] = 2 else BattlegroundTargets_Options.ButtonTypeRangeCheck[40] = 1 end
		end
		BattlegroundTargets_Options.ButtonAvgRangeCheck = nil
		BattlegroundTargets_Options.ButtonClassRangeCheck = nil
		BattlegroundTargets_Options.version = 14
	end

	local _, instanceType = IsInInstance();
	if ( (BattlegroundTargets_Character.NativeFaction == nil or 
		 BattlegroundTargets_Character.NativeFaction ~= UnitFactionGroup("player")) and instanceType ~= 'pvp') then
		BattlegroundTargets_Character.NativeFaction = UnitFactionGroup("player");
	end
    if BattlegroundTargets_Options.hdlog                      == nil then BattlegroundTargets_Options.hdlog                      = false     end
	if BattlegroundTargets_Options.pos                        == nil then BattlegroundTargets_Options.pos                        = {}        end
	if BattlegroundTargets_Options.DB						  == nil then BattlegroundTargets_Options.DB 						 = {} 	     end
	if BattlegroundTargets_Options.DB.outOfDateRange		  == nil then BattlegroundTargets_Options.DB.outOfDateRange 		 = 3 	     end
	if BattlegroundTargets_Options.MinimapButton              == nil then BattlegroundTargets_Options.MinimapButton              = false     end
	if BattlegroundTargets_Options.MinimapButtonPos           == nil then BattlegroundTargets_Options.MinimapButtonPos           = -90       end
	if BattlegroundTargets_Options.TargetIcon                 == nil then BattlegroundTargets_Options.TargetIcon                 = "default" end
	
	if BattlegroundTargets_Options.EnableBracket              == nil then BattlegroundTargets_Options.EnableBracket              = {}    end
	if BattlegroundTargets_Options.EnableBracket[10]          == nil then BattlegroundTargets_Options.EnableBracket[10]          = true end
	if BattlegroundTargets_Options.EnableBracket[15]          == nil then BattlegroundTargets_Options.EnableBracket[15]          = true end
	if BattlegroundTargets_Options.EnableBracket[40]          == nil then BattlegroundTargets_Options.EnableBracket[40]          = true end
	
	if BattlegroundTargets_Options.IndependentPositioning     == nil then BattlegroundTargets_Options.IndependentPositioning     = {}    end
	if BattlegroundTargets_Options.IndependentPositioning[10] == nil then BattlegroundTargets_Options.IndependentPositioning[10] = false end
	if BattlegroundTargets_Options.IndependentPositioning[15] == nil then BattlegroundTargets_Options.IndependentPositioning[15] = false end
	if BattlegroundTargets_Options.IndependentPositioning[40] == nil then BattlegroundTargets_Options.IndependentPositioning[40] = false end
	
	if BattlegroundTargets_Options.LayoutTH                   == nil then BattlegroundTargets_Options.LayoutTH                   = {}    end
	if BattlegroundTargets_Options.LayoutTH[10]               == nil then BattlegroundTargets_Options.LayoutTH[10]               = 18    end
	if BattlegroundTargets_Options.LayoutTH[15]               == nil then BattlegroundTargets_Options.LayoutTH[15]               = 18    end
	if BattlegroundTargets_Options.LayoutTH[40]               == nil then BattlegroundTargets_Options.LayoutTH[40]               = 24    end
	if BattlegroundTargets_Options.LayoutSpace                == nil then BattlegroundTargets_Options.LayoutSpace                = {}    end
	if BattlegroundTargets_Options.LayoutSpace[10]            == nil then BattlegroundTargets_Options.LayoutSpace[10]            = 0     end
	if BattlegroundTargets_Options.LayoutSpace[15]            == nil then BattlegroundTargets_Options.LayoutSpace[15]            = 0     end
	if BattlegroundTargets_Options.LayoutSpace[40]            == nil then BattlegroundTargets_Options.LayoutSpace[40]            = 0     end
	if BattlegroundTargets_Options.LayoutButtonSpace          == nil then BattlegroundTargets_Options.LayoutButtonSpace          = {}    end
	if BattlegroundTargets_Options.LayoutButtonSpace[10]      == nil then BattlegroundTargets_Options.LayoutButtonSpace[10]      = 0     end
	if BattlegroundTargets_Options.LayoutButtonSpace[15]      == nil then BattlegroundTargets_Options.LayoutButtonSpace[15]      = 0     end
	if BattlegroundTargets_Options.LayoutButtonSpace[40]      == nil then BattlegroundTargets_Options.LayoutButtonSpace[40]      = 0     end
	
    if BattlegroundTargets_Options.ButtonRoleLayoutPos          == nil then BattlegroundTargets_Options.ButtonRoleLayoutPos        = {}      end
	if BattlegroundTargets_Options.ButtonClassIcon              == nil then BattlegroundTargets_Options.ButtonClassIcon            = {}      end
	if BattlegroundTargets_Options.ButtonHideRealm              == nil then BattlegroundTargets_Options.ButtonHideRealm            = {}      end
	if BattlegroundTargets_Options.ButtonShowLeader             == nil then BattlegroundTargets_Options.ButtonShowLeader           = {}      end
	if BattlegroundTargets_Options.ButtonShowTarget             == nil then BattlegroundTargets_Options.ButtonShowTarget           = {}      end
	if BattlegroundTargets_Options.ButtonTargetScale            == nil then BattlegroundTargets_Options.ButtonTargetScale          = {}      end
	if BattlegroundTargets_Options.ButtonTargetPosition         == nil then BattlegroundTargets_Options.ButtonTargetPosition       = {}      end
	if BattlegroundTargets_Options.ButtonShowAssist             == nil then BattlegroundTargets_Options.ButtonShowAssist           = {}      end
	if BattlegroundTargets_Options.ButtonAssistScale            == nil then BattlegroundTargets_Options.ButtonAssistScale          = {}      end
	if BattlegroundTargets_Options.ButtonAssistPosition         == nil then BattlegroundTargets_Options.ButtonAssistPosition       = {}      end
	if BattlegroundTargets_Options.ButtonShowFocus              == nil then BattlegroundTargets_Options.ButtonShowFocus            = {}      end
	if BattlegroundTargets_Options.ButtonFocusScale             == nil then BattlegroundTargets_Options.ButtonFocusScale           = {}      end
	if BattlegroundTargets_Options.ButtonFocusPosition          == nil then BattlegroundTargets_Options.ButtonFocusPosition        = {}      end
	if BattlegroundTargets_Options.ButtonShowFlag               == nil then BattlegroundTargets_Options.ButtonShowFlag             = {}      end
	if BattlegroundTargets_Options.ButtonFlagScale              == nil then BattlegroundTargets_Options.ButtonFlagScale            = {}      end
	if BattlegroundTargets_Options.ButtonFlagPosition           == nil then BattlegroundTargets_Options.ButtonFlagPosition         = {}      end
	if BattlegroundTargets_Options.ButtonShowTargetCount        == nil then BattlegroundTargets_Options.ButtonShowTargetCount      = {}      end
	if BattlegroundTargets_Options.ButtonShowHealthBar          == nil then BattlegroundTargets_Options.ButtonShowHealthBar        = {}      end
	if BattlegroundTargets_Options.ButtonShowHealthText         == nil then BattlegroundTargets_Options.ButtonShowHealthText       = {}      end
	if BattlegroundTargets_Options.ButtonRangeCheck             == nil then BattlegroundTargets_Options.ButtonRangeCheck           = {}      end
	if BattlegroundTargets_Options.ButtonTypeRangeCheck         == nil then BattlegroundTargets_Options.ButtonTypeRangeCheck       = {}      end
	if BattlegroundTargets_Options.ButtonRangeDisplay           == nil then BattlegroundTargets_Options.ButtonRangeDisplay         = {}      end
	if BattlegroundTargets_Options.ButtonSortBy                 == nil then BattlegroundTargets_Options.ButtonSortBy               = {}      end
	if BattlegroundTargets_Options.ButtonSortDetail             == nil then BattlegroundTargets_Options.ButtonSortDetail           = {}      end
	if BattlegroundTargets_Options.ButtonFontSize               == nil then BattlegroundTargets_Options.ButtonFontSize             = {}      end
	if BattlegroundTargets_Options.ButtonScale                  == nil then BattlegroundTargets_Options.ButtonScale                = {}      end
	if BattlegroundTargets_Options.ButtonWidth                  == nil then BattlegroundTargets_Options.ButtonWidth                = {}      end
	if BattlegroundTargets_Options.ButtonHeight                 == nil then BattlegroundTargets_Options.ButtonHeight               = {}      end
	if BattlegroundTargets_Options.ButtonShowHealer             == nil then BattlegroundTargets_Options.ButtonShowHealer           = {}      end  

	if BattlegroundTargets_Options.ButtonShowHealer[10]         == nil then BattlegroundTargets_Options.ButtonShowHealer[10]         = true    end
	if BattlegroundTargets_Options.ButtonRoleLayoutPos[10]      == nil then BattlegroundTargets_Options.ButtonRoleLayoutPos[10]      = 1       end
	if BattlegroundTargets_Options.ButtonClassIcon[10]          == nil then BattlegroundTargets_Options.ButtonClassIcon[10]          = true    end
	if BattlegroundTargets_Options.ButtonHideRealm[10]          == nil then BattlegroundTargets_Options.ButtonHideRealm[10]          = false   end
	if BattlegroundTargets_Options.ButtonShowLeader[10]         == nil then BattlegroundTargets_Options.ButtonShowLeader[10]         = false   end
	if BattlegroundTargets_Options.ButtonShowTarget[10]         == nil then BattlegroundTargets_Options.ButtonShowTarget[10]         = false   end
	if BattlegroundTargets_Options.ButtonTargetScale[10]        == nil then BattlegroundTargets_Options.ButtonTargetScale[10]        = 1.2     end
	if BattlegroundTargets_Options.ButtonTargetPosition[10]     == nil then BattlegroundTargets_Options.ButtonTargetPosition[10]     = 75      end
	if BattlegroundTargets_Options.ButtonShowAssist[10]         == nil then BattlegroundTargets_Options.ButtonShowAssist[10]         = false   end
	if BattlegroundTargets_Options.ButtonAssistScale[10]        == nil then BattlegroundTargets_Options.ButtonAssistScale[10]        = 1.2     end
	if BattlegroundTargets_Options.ButtonAssistPosition[10]     == nil then BattlegroundTargets_Options.ButtonAssistPosition[10]     = 75      end
	if BattlegroundTargets_Options.ButtonShowFocus[10]          == nil then BattlegroundTargets_Options.ButtonShowFocus[10]          = false   end
	if BattlegroundTargets_Options.ButtonFocusScale[10]         == nil then BattlegroundTargets_Options.ButtonFocusScale[10]         = 1       end
	if BattlegroundTargets_Options.ButtonFocusPosition[10]      == nil then BattlegroundTargets_Options.ButtonFocusPosition[10]      = 75      end
	if BattlegroundTargets_Options.ButtonShowFlag[10]           == nil then BattlegroundTargets_Options.ButtonShowFlag[10]           = true    end
	if BattlegroundTargets_Options.ButtonFlagScale[10]          == nil then BattlegroundTargets_Options.ButtonFlagScale[10]          = 1.2     end
	if BattlegroundTargets_Options.ButtonFlagPosition[10]       == nil then BattlegroundTargets_Options.ButtonFlagPosition[10]       = 75      end
	if BattlegroundTargets_Options.ButtonShowTargetCount[10]    == nil then BattlegroundTargets_Options.ButtonShowTargetCount[10]    = false   end
	if BattlegroundTargets_Options.ButtonShowHealthBar[10]      == nil then BattlegroundTargets_Options.ButtonShowHealthBar[10]      = false   end
	if BattlegroundTargets_Options.ButtonShowHealthText[10]     == nil then BattlegroundTargets_Options.ButtonShowHealthText[10]     = false   end
	if BattlegroundTargets_Options.ButtonRangeCheck[10]         == nil then BattlegroundTargets_Options.ButtonRangeCheck[10]         = false   end
	if BattlegroundTargets_Options.ButtonTypeRangeCheck[10]     == nil then BattlegroundTargets_Options.ButtonTypeRangeCheck[10]     = 2       end
	if BattlegroundTargets_Options.ButtonRangeDisplay[10]       == nil then BattlegroundTargets_Options.ButtonRangeDisplay[10]       = 1       end
	if BattlegroundTargets_Options.ButtonSortBy[10]             == nil then BattlegroundTargets_Options.ButtonSortBy[10]             = 3       end
	if BattlegroundTargets_Options.ButtonSortDetail[10]         == nil then BattlegroundTargets_Options.ButtonSortDetail[10]         = 3       end
	if BattlegroundTargets_Options.ButtonFontSize[10]           == nil then BattlegroundTargets_Options.ButtonFontSize[10]           = 10      end
	if BattlegroundTargets_Options.ButtonScale[10]              == nil then BattlegroundTargets_Options.ButtonScale[10]              = 1.1     end
	if BattlegroundTargets_Options.ButtonWidth[10]              == nil then BattlegroundTargets_Options.ButtonWidth[10]              = 150     end
	if BattlegroundTargets_Options.ButtonHeight[10]             == nil then BattlegroundTargets_Options.ButtonHeight[10]             = 20      end
	
	if BattlegroundTargets_Options.ButtonShowHealer[15]         == nil then BattlegroundTargets_Options.ButtonShowHealer[15]         = true    end
	if BattlegroundTargets_Options.ButtonRoleLayoutPos[15]      == nil then BattlegroundTargets_Options.ButtonRoleLayoutPos[15]      = 1       end
	if BattlegroundTargets_Options.ButtonClassIcon[15]          == nil then BattlegroundTargets_Options.ButtonClassIcon[15]          = true    end
	if BattlegroundTargets_Options.ButtonHideRealm[15]          == nil then BattlegroundTargets_Options.ButtonHideRealm[15]          = false   end
	if BattlegroundTargets_Options.ButtonShowLeader[15]         == nil then BattlegroundTargets_Options.ButtonShowLeader[15]         = false   end
	if BattlegroundTargets_Options.ButtonShowTarget[15]         == nil then BattlegroundTargets_Options.ButtonShowTarget[15]         = false   end
	if BattlegroundTargets_Options.ButtonTargetScale[15]        == nil then BattlegroundTargets_Options.ButtonTargetScale[15]        = 1.2     end
	if BattlegroundTargets_Options.ButtonTargetPosition[15]     == nil then BattlegroundTargets_Options.ButtonTargetPosition[15]     = 75      end
	if BattlegroundTargets_Options.ButtonShowAssist[15]         == nil then BattlegroundTargets_Options.ButtonShowAssist[15]         = false   end
	if BattlegroundTargets_Options.ButtonAssistScale[15]        == nil then BattlegroundTargets_Options.ButtonAssistScale[15]        = 1.2     end
	if BattlegroundTargets_Options.ButtonAssistPosition[15]     == nil then BattlegroundTargets_Options.ButtonAssistPosition[15]     = 75      end
	if BattlegroundTargets_Options.ButtonShowFocus[15]          == nil then BattlegroundTargets_Options.ButtonShowFocus[15]          = false   end
	if BattlegroundTargets_Options.ButtonFocusScale[15]         == nil then BattlegroundTargets_Options.ButtonFocusScale[15]         = 1       end
	if BattlegroundTargets_Options.ButtonFocusPosition[15]      == nil then BattlegroundTargets_Options.ButtonFocusPosition[15]      = 75      end
	if BattlegroundTargets_Options.ButtonShowFlag[15]           == nil then BattlegroundTargets_Options.ButtonShowFlag[15]           = true    end
	if BattlegroundTargets_Options.ButtonFlagScale[15]          == nil then BattlegroundTargets_Options.ButtonFlagScale[15]          = 1.2     end
	if BattlegroundTargets_Options.ButtonFlagPosition[15]       == nil then BattlegroundTargets_Options.ButtonFlagPosition[15]       = 75      end
	if BattlegroundTargets_Options.ButtonShowTargetCount[15]    == nil then BattlegroundTargets_Options.ButtonShowTargetCount[15]    = false   end
	if BattlegroundTargets_Options.ButtonShowHealthBar[15]      == nil then BattlegroundTargets_Options.ButtonShowHealthBar[15]      = false   end
	if BattlegroundTargets_Options.ButtonShowHealthText[15]     == nil then BattlegroundTargets_Options.ButtonShowHealthText[15]     = false   end
	if BattlegroundTargets_Options.ButtonRangeCheck[15]         == nil then BattlegroundTargets_Options.ButtonRangeCheck[15]         = false   end
	if BattlegroundTargets_Options.ButtonTypeRangeCheck[15]     == nil then BattlegroundTargets_Options.ButtonTypeRangeCheck[15]     = 2       end
	if BattlegroundTargets_Options.ButtonRangeDisplay[15]       == nil then BattlegroundTargets_Options.ButtonRangeDisplay[15]       = 1       end
	if BattlegroundTargets_Options.ButtonSortBy[15]             == nil then BattlegroundTargets_Options.ButtonSortBy[15]             = 3       end
	if BattlegroundTargets_Options.ButtonSortDetail[15]         == nil then BattlegroundTargets_Options.ButtonSortDetail[15]         = 3       end
	if BattlegroundTargets_Options.ButtonFontSize[15]           == nil then BattlegroundTargets_Options.ButtonFontSize[15]           = 10      end
	if BattlegroundTargets_Options.ButtonScale[15]              == nil then BattlegroundTargets_Options.ButtonScale[15]              = 1.1     end
	if BattlegroundTargets_Options.ButtonWidth[15]              == nil then BattlegroundTargets_Options.ButtonWidth[15]              = 150     end
	if BattlegroundTargets_Options.ButtonHeight[15]             == nil then BattlegroundTargets_Options.ButtonHeight[15]             = 20      end
	
	if BattlegroundTargets_Options.ButtonShowHealer[40]         == nil then BattlegroundTargets_Options.ButtonShowHealer[40]         = true    end
	if BattlegroundTargets_Options.ButtonRoleLayoutPos[40]      == nil then BattlegroundTargets_Options.ButtonRoleLayoutPos[40]      = 1       end
	if BattlegroundTargets_Options.ButtonClassIcon[40]          == nil then BattlegroundTargets_Options.ButtonClassIcon[40]          = false   end
	if BattlegroundTargets_Options.ButtonHideRealm[40]          == nil then BattlegroundTargets_Options.ButtonHideRealm[40]          = true    end
	if BattlegroundTargets_Options.ButtonShowLeader[40]         == nil then BattlegroundTargets_Options.ButtonShowLeader[40]         = false   end
	if BattlegroundTargets_Options.ButtonShowTarget[40]         == nil then BattlegroundTargets_Options.ButtonShowTarget[40]         = false   end
	if BattlegroundTargets_Options.ButtonTargetScale[40]        == nil then BattlegroundTargets_Options.ButtonTargetScale[40]        = 1       end
	if BattlegroundTargets_Options.ButtonTargetPosition[40]     == nil then BattlegroundTargets_Options.ButtonTargetPosition[40]     = 75      end
	if BattlegroundTargets_Options.ButtonShowAssist[40]         == nil then BattlegroundTargets_Options.ButtonShowAssist[40]         = false   end
	if BattlegroundTargets_Options.ButtonAssistScale[40]        == nil then BattlegroundTargets_Options.ButtonAssistScale[40]        = 1       end
	if BattlegroundTargets_Options.ButtonAssistPosition[40]     == nil then BattlegroundTargets_Options.ButtonAssistPosition[40]     = 75      end
	if BattlegroundTargets_Options.ButtonShowFocus[40]          == nil then BattlegroundTargets_Options.ButtonShowFocus[40]          = false   end
	if BattlegroundTargets_Options.ButtonFocusScale[40]         == nil then BattlegroundTargets_Options.ButtonFocusScale[40]         = 1       end
	if BattlegroundTargets_Options.ButtonFocusPosition[40]      == nil then BattlegroundTargets_Options.ButtonFocusPosition[40]      = 75      end
	if BattlegroundTargets_Options.ButtonShowFlag[40]           == nil then BattlegroundTargets_Options.ButtonShowFlag[40]           = false   end
	if BattlegroundTargets_Options.ButtonFlagScale[40]          == nil then BattlegroundTargets_Options.ButtonFlagScale[40]          = 1       end
	if BattlegroundTargets_Options.ButtonFlagPosition[40]       == nil then BattlegroundTargets_Options.ButtonFlagPosition[40]       = 75      end
	if BattlegroundTargets_Options.ButtonShowTargetCount[40]    == nil then BattlegroundTargets_Options.ButtonShowTargetCount[40]    = false   end
	if BattlegroundTargets_Options.ButtonShowHealthBar[40]      == nil then BattlegroundTargets_Options.ButtonShowHealthBar[40]      = false   end
	if BattlegroundTargets_Options.ButtonShowHealthText[40]     == nil then BattlegroundTargets_Options.ButtonShowHealthText[40]     = false   end
	if BattlegroundTargets_Options.ButtonRangeCheck[40]         == nil then BattlegroundTargets_Options.ButtonRangeCheck[40]         = false   end
	if BattlegroundTargets_Options.ButtonTypeRangeCheck[40]     == nil then BattlegroundTargets_Options.ButtonTypeRangeCheck[40]     = 2       end
	if BattlegroundTargets_Options.ButtonRangeDisplay[40]       == nil then BattlegroundTargets_Options.ButtonRangeDisplay[40]       = 9       end
	if BattlegroundTargets_Options.ButtonSortBy[40]             == nil then BattlegroundTargets_Options.ButtonSortBy[40]             = 3       end
	if BattlegroundTargets_Options.ButtonSortDetail[40]         == nil then BattlegroundTargets_Options.ButtonSortDetail[40]         = 3       end
	if BattlegroundTargets_Options.ButtonFontSize[40]           == nil then BattlegroundTargets_Options.ButtonFontSize[40]           = 10      end
	if BattlegroundTargets_Options.ButtonScale[40]              == nil then BattlegroundTargets_Options.ButtonScale[40]              = 1.1     end
	if BattlegroundTargets_Options.ButtonWidth[40]              == nil then BattlegroundTargets_Options.ButtonWidth[40]              = 110     end
	if BattlegroundTargets_Options.ButtonHeight[40]             == nil then BattlegroundTargets_Options.ButtonHeight[40]             = 18      end

	for i = 1, #bgSizeINT do
		local sz = bgSizeINT[i]
		if not OPT.ButtonClassIcon          then OPT.ButtonClassIcon          = {} end OPT.ButtonClassIcon[sz]          = BattlegroundTargets_Options.ButtonClassIcon[sz]
		if not OPT.ButtonRoleLayoutPos      then OPT.ButtonRoleLayoutPos      = {} end OPT.ButtonRoleLayoutPos[sz]      = BattlegroundTargets_Options.ButtonRoleLayoutPos[sz]
		if not OPT.ButtonHideRealm          then OPT.ButtonHideRealm          = {} end OPT.ButtonHideRealm[sz]          = BattlegroundTargets_Options.ButtonHideRealm[sz]
		if not OPT.ButtonShowHealer         then OPT.ButtonShowHealer         = {} end OPT.ButtonShowHealer[sz]         = BattlegroundTargets_Options.ButtonShowHealer[sz]
		if not OPT.ButtonShowLeader         then OPT.ButtonShowLeader         = {} end OPT.ButtonShowLeader[sz]         = BattlegroundTargets_Options.ButtonShowLeader[sz]
		if not OPT.ButtonShowTarget         then OPT.ButtonShowTarget         = {} end OPT.ButtonShowTarget[sz]         = BattlegroundTargets_Options.ButtonShowTarget[sz]
		if not OPT.ButtonTargetScale        then OPT.ButtonTargetScale        = {} end OPT.ButtonTargetScale[sz]        = BattlegroundTargets_Options.ButtonTargetScale[sz]
		if not OPT.ButtonTargetPosition     then OPT.ButtonTargetPosition     = {} end OPT.ButtonTargetPosition[sz]     = BattlegroundTargets_Options.ButtonTargetPosition[sz]
		if not OPT.ButtonShowAssist         then OPT.ButtonShowAssist         = {} end OPT.ButtonShowAssist[sz]         = BattlegroundTargets_Options.ButtonShowAssist[sz]
		if not OPT.ButtonAssistScale        then OPT.ButtonAssistScale        = {} end OPT.ButtonAssistScale[sz]        = BattlegroundTargets_Options.ButtonAssistScale[sz]
		if not OPT.ButtonAssistPosition     then OPT.ButtonAssistPosition     = {} end OPT.ButtonAssistPosition[sz]     = BattlegroundTargets_Options.ButtonAssistPosition[sz]
		if not OPT.ButtonShowFocus          then OPT.ButtonShowFocus          = {} end OPT.ButtonShowFocus[sz]          = BattlegroundTargets_Options.ButtonShowFocus[sz]
		if not OPT.ButtonFocusScale         then OPT.ButtonFocusScale         = {} end OPT.ButtonFocusScale[sz]         = BattlegroundTargets_Options.ButtonFocusScale[sz]
		if not OPT.ButtonFocusPosition      then OPT.ButtonFocusPosition      = {} end OPT.ButtonFocusPosition[sz]      = BattlegroundTargets_Options.ButtonFocusPosition[sz]
		if not OPT.ButtonShowFlag           then OPT.ButtonShowFlag           = {} end OPT.ButtonShowFlag[sz]           = BattlegroundTargets_Options.ButtonShowFlag[sz]
		if not OPT.ButtonFlagScale          then OPT.ButtonFlagScale          = {} end OPT.ButtonFlagScale[sz]          = BattlegroundTargets_Options.ButtonFlagScale[sz]
		if not OPT.ButtonFlagPosition       then OPT.ButtonFlagPosition       = {} end OPT.ButtonFlagPosition[sz]       = BattlegroundTargets_Options.ButtonFlagPosition[sz]
		if not OPT.ButtonShowTargetCount    then OPT.ButtonShowTargetCount    = {} end OPT.ButtonShowTargetCount[sz]    = BattlegroundTargets_Options.ButtonShowTargetCount[sz]
		if not OPT.ButtonShowHealthBar      then OPT.ButtonShowHealthBar      = {} end OPT.ButtonShowHealthBar[sz]      = BattlegroundTargets_Options.ButtonShowHealthBar[sz]
		if not OPT.ButtonShowHealthText     then OPT.ButtonShowHealthText     = {} end OPT.ButtonShowHealthText[sz]     = BattlegroundTargets_Options.ButtonShowHealthText[sz]
		if not OPT.ButtonRangeCheck         then OPT.ButtonRangeCheck         = {} end OPT.ButtonRangeCheck[sz]         = BattlegroundTargets_Options.ButtonRangeCheck[sz]
		if not OPT.ButtonTypeRangeCheck     then OPT.ButtonTypeRangeCheck     = {} end OPT.ButtonTypeRangeCheck[sz]     = BattlegroundTargets_Options.ButtonTypeRangeCheck[sz]
		if not OPT.ButtonRangeDisplay       then OPT.ButtonRangeDisplay       = {} end OPT.ButtonRangeDisplay[sz]       = BattlegroundTargets_Options.ButtonRangeDisplay[sz]
		if not OPT.ButtonSortBy             then OPT.ButtonSortBy             = {} end OPT.ButtonSortBy[sz]             = BattlegroundTargets_Options.ButtonSortBy[sz]
		if not OPT.ButtonSortDetail         then OPT.ButtonSortDetail         = {} end OPT.ButtonSortDetail[sz]         = BattlegroundTargets_Options.ButtonSortDetail[sz]
		if not OPT.ButtonFontSize           then OPT.ButtonFontSize           = {} end OPT.ButtonFontSize[sz]           = BattlegroundTargets_Options.ButtonFontSize[sz]
		if not OPT.ButtonScale              then OPT.ButtonScale              = {} end OPT.ButtonScale[sz]              = BattlegroundTargets_Options.ButtonScale[sz]
		if not OPT.ButtonWidth              then OPT.ButtonWidth              = {} end OPT.ButtonWidth[sz]              = BattlegroundTargets_Options.ButtonWidth[sz]
		if not OPT.ButtonHeight             then OPT.ButtonHeight             = {} end OPT.ButtonHeight[sz]             = BattlegroundTargets_Options.ButtonHeight[sz]
	end	

	IsShowHealers = OPT.ButtonShowHealer[10] or OPT.ButtonShowHealer[15] or OPT.ButtonShowHealer[40];

end

function BattlegroundTargets:LDBcheck()
	if(LibStub and LibStub:GetLibrary("CallbackHandler-1.0", true) and LibStub:GetLibrary("LibDataBroker-1.1", true)) then
		LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("BattlegroundTargets", {
			type = "launcher",
			icon = AddonIcon,
			OnClick = function(self, button)
				BattlegroundTargets:Frame_Toggle(GVAR.OptionsFrame)
			end,
		});
	end
end

function BattlegroundTargets:CreateInterfaceOptions()
	GVAR.InterfaceOptions = CreateFrame("Frame", "BattlegroundTargets_InterfaceOptions");
	GVAR.InterfaceOptions.name = "BattlegroundTargets";
	
	GVAR.InterfaceOptions.Title = GVAR.InterfaceOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
	GVAR.InterfaceOptions.Title:SetText(UITitle);
	GVAR.InterfaceOptions.Title:SetJustifyH("LEFT");
	GVAR.InterfaceOptions.Title:SetJustifyV("TOP");
	GVAR.InterfaceOptions.Title:SetPoint("TOPLEFT", 16, -16);
	
	GVAR.InterfaceOptions.CONFIG = CreateFrame("Button", nil, GVAR.InterfaceOptions);
	TEMPLATE.TextButton(GVAR.InterfaceOptions.CONFIG, L["Open Configuration"], 1);
	GVAR.InterfaceOptions.CONFIG:SetWidth(180);
	GVAR.InterfaceOptions.CONFIG:SetHeight(22);
	GVAR.InterfaceOptions.CONFIG:SetPoint("TOPLEFT", GVAR.InterfaceOptions.Title, "BOTTOMLEFT", 0, -10);
	GVAR.InterfaceOptions.CONFIG:SetScript("OnClick", function()
		InterfaceOptionsFrame_Show();
		HideUIPanel(GameMenuFrame);
		BattlegroundTargets:Frame_Toggle(GVAR.OptionsFrame);
	end);
	
	GVAR.InterfaceOptions.SlashCommandText = GVAR.InterfaceOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	GVAR.InterfaceOptions.SlashCommandText:SetText("/bgt - /bgtargets - /battlegroundtargets");
	GVAR.InterfaceOptions.SlashCommandText:SetNonSpaceWrap(true);
	GVAR.InterfaceOptions.SlashCommandText:SetPoint("LEFT", GVAR.InterfaceOptions.CONFIG, "RIGHT", 10, 0);
	GVAR.InterfaceOptions.SlashCommandText:SetTextColor(1, 1, 0.49, 1);
	
	InterfaceOptions_AddCategory(GVAR.InterfaceOptions);
end

function BattlegroundTargets:CreateFrames()
	GVAR.MainFrame = CreateFrame("Frame", "BattlegroundTargets_MainFrame", UIParent);
	TEMPLATE.BorderTRBL(GVAR.MainFrame);
	GVAR.MainFrame:EnableMouse(true);
	GVAR.MainFrame:SetMovable(true);
	GVAR.MainFrame:SetResizable(true);
	GVAR.MainFrame:SetToplevel(true);
	GVAR.MainFrame:SetClampedToScreen(true);
	GVAR.MainFrame:SetWidth(150);
	GVAR.MainFrame:SetHeight(20);
	GVAR.MainFrame:SetScript("OnShow", function() BattlegroundTargets:MainFrameShow(); end);
	GVAR.MainFrame:SetScript("OnEnter", function() GVAR.MainFrame.Movetext:SetTextColor(1, 1, 1, 1); end);
	GVAR.MainFrame:SetScript("OnLeave", function() GVAR.MainFrame.Movetext:SetTextColor(0.3, 0.3, 0.3, 1) end);
	GVAR.MainFrame:SetScript("OnMouseDown", function()
		if(inCombat or InCombatLockdown()) then return; end
		
		GVAR.MainFrame:StartMoving();
	end)
	GVAR.MainFrame:SetScript("OnMouseUp", function()
		if(inCombat or InCombatLockdown()) then return; end
		
		GVAR.MainFrame:StopMovingOrSizing();
		BattlegroundTargets:Frame_SavePosition("BattlegroundTargets_MainFrame");
	end)
	
	GVAR.MainFrame:Hide();
	
	GVAR.MainFrame.Movetext = GVAR.MainFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	GVAR.MainFrame.Movetext:SetWidth(150);
	GVAR.MainFrame.Movetext:SetHeight(20);
	GVAR.MainFrame.Movetext:SetPoint("CENTER", 0, 0);
	GVAR.MainFrame.Movetext:SetJustifyH("CENTER");
	GVAR.MainFrame.Movetext:SetText(L["click & move"]);
	GVAR.MainFrame.Movetext:SetTextColor(0.3, 0.3, 0.3, 1);
	
	local function OnEnter(self)
		self.HighlightT:SetTexture(1, 1, 0.49, 1);
		self.HighlightR:SetTexture(1, 1, 0.49, 1);
		self.HighlightB:SetTexture(1, 1, 0.49, 1);
		self.HighlightL:SetTexture(1, 1, 0.49, 1);
	end
	
	local function OnLeave(self)
		if(isTarget == self.buttonNum) then
			self.HighlightT:SetTexture(0.5, 0.5, 0.5, 1);
			self.HighlightR:SetTexture(0.5, 0.5, 0.5, 1);
			self.HighlightB:SetTexture(0.5, 0.5, 0.5, 1);
			self.HighlightL:SetTexture(0.5, 0.5, 0.5, 1);
		else
			self.HighlightT:SetTexture(0, 0, 0, 1);
			self.HighlightR:SetTexture(0, 0, 0, 1);
			self.HighlightB:SetTexture(0, 0, 0, 1);
			self.HighlightL:SetTexture(0, 0, 0, 1);
		end
	end
	
	local buttonWidth = 150;
	local buttonHeight = 20;
	
	GVAR.TargetButton = {};
	
	for i = 1, 40 do
		GVAR.TargetButton[i] = CreateFrame("Button", nil, UIParent, "SecureActionButtonTemplate");

		local GVAR_TargetButton = GVAR.TargetButton[i];

		GVAR_TargetButton:SetWidth(buttonWidth);
		GVAR_TargetButton:SetHeight(buttonHeight);
		
		if(i == 1) then
			GVAR_TargetButton:SetPoint("TOPLEFT", GVAR.MainFrame, "BOTTOMLEFT", 0, 0);
		else
			GVAR_TargetButton:SetPoint("TOPLEFT", GVAR.TargetButton[(i-1)], "BOTTOMLEFT", 0, 0);
		end
		
		GVAR_TargetButton:Hide();
		
		GVAR_TargetButton.colR = 0;
		GVAR_TargetButton.colG = 0;
		GVAR_TargetButton.colB = 0;
		GVAR_TargetButton.colR5 = 0;
		GVAR_TargetButton.colG5 = 0;
		GVAR_TargetButton.colB5 = 0;
		
		GVAR_TargetButton.HighlightT = GVAR_TargetButton:CreateTexture(nil, "BACKGROUND");
		GVAR_TargetButton.HighlightT:SetWidth(buttonWidth);
		GVAR_TargetButton.HighlightT:SetHeight(1);
		GVAR_TargetButton.HighlightT:SetPoint("TOP", 0, 0);
		GVAR_TargetButton.HighlightT:SetTexture(0, 0, 0, 1);
		GVAR_TargetButton.HighlightR = GVAR_TargetButton:CreateTexture(nil, "BACKGROUND");
		GVAR_TargetButton.HighlightR:SetWidth(1);
		GVAR_TargetButton.HighlightR:SetHeight(buttonHeight);
		GVAR_TargetButton.HighlightR:SetPoint("RIGHT", 0, 0);
		GVAR_TargetButton.HighlightR:SetTexture(0, 0, 0, 1);
		GVAR_TargetButton.HighlightB = GVAR_TargetButton:CreateTexture(nil, "BACKGROUND");
		GVAR_TargetButton.HighlightB:SetWidth(buttonWidth);
		GVAR_TargetButton.HighlightB:SetHeight(1);
		GVAR_TargetButton.HighlightB:SetPoint("BOTTOM", 0, 0);
		GVAR_TargetButton.HighlightB:SetTexture(0, 0, 0, 1);
		GVAR_TargetButton.HighlightL = GVAR_TargetButton:CreateTexture(nil, "BACKGROUND");
		GVAR_TargetButton.HighlightL:SetWidth(1);
		GVAR_TargetButton.HighlightL:SetHeight(buttonHeight);
		GVAR_TargetButton.HighlightL:SetPoint("LEFT", 0, 0);
		GVAR_TargetButton.HighlightL:SetTexture(0, 0, 0, 1);
		
		GVAR_TargetButton.Background = GVAR_TargetButton:CreateTexture(nil, "BACKGROUND");
		GVAR_TargetButton.Background:SetWidth(buttonWidth - 2);
		GVAR_TargetButton.Background:SetHeight(buttonHeight - 2);
		GVAR_TargetButton.Background:SetPoint("TOPLEFT", 1, -1);
		GVAR_TargetButton.Background:SetTexture(0, 0, 0, 0.25);
		
		GVAR_TargetButton.RangeTexture = GVAR_TargetButton:CreateTexture(nil, "BORDER");
		GVAR_TargetButton.RangeTexture:SetWidth((buttonHeight - 2) / 2);
		GVAR_TargetButton.RangeTexture:SetHeight(buttonHeight - 2);
		GVAR_TargetButton.RangeTexture:SetPoint("LEFT", GVAR_TargetButton, "LEFT", 1, 0);
		GVAR_TargetButton.RangeTexture:SetTexture(0, 0, 0, 0);
		
		GVAR_TargetButton.ClassTexture = GVAR_TargetButton:CreateTexture(nil, "BORDER");
		GVAR_TargetButton.ClassTexture:SetWidth(buttonHeight - 2);
		GVAR_TargetButton.ClassTexture:SetHeight(buttonHeight - 2);
		GVAR_TargetButton.ClassTexture:SetPoint("LEFT", GVAR_TargetButton.RangeTexture, "RIGHT", 0, 0);
		GVAR_TargetButton.ClassTexture:SetTexture("Interface\\WorldStateFrame\\Icons-Classes");
        GVAR_TargetButton.ClassTexture:SetTexCoord(0, 0, 0, 0);
		
		GVAR_TargetButton.LeaderTexture = GVAR_TargetButton:CreateTexture(nil, "ARTWORK");
		GVAR_TargetButton.LeaderTexture:SetWidth((buttonHeight - 2) / 1.5);
		GVAR_TargetButton.LeaderTexture:SetHeight((buttonHeight - 2) / 1.5);
		GVAR_TargetButton.LeaderTexture:SetPoint("RIGHT", GVAR_TargetButton, "LEFT", 0, 0);
		GVAR_TargetButton.LeaderTexture:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon");
		GVAR_TargetButton.LeaderTexture:SetAlpha(0);
		
		GVAR_TargetButton.ClassColorBackground = GVAR_TargetButton:CreateTexture(nil, "BORDER")
		GVAR_TargetButton.ClassColorBackground:SetWidth((buttonWidth - 2) - (buttonHeight - 2) - (buttonHeight - 2));
		GVAR_TargetButton.ClassColorBackground:SetHeight(buttonHeight - 2);
		GVAR_TargetButton.ClassColorBackground:SetPoint("LEFT", GVAR_TargetButton.ClassTexture, "RIGHT", 0, 0);
		GVAR_TargetButton.ClassColorBackground:SetTexture(0, 0, 0, 0);
		
		GVAR_TargetButton.HealthBar = GVAR_TargetButton:CreateTexture(nil, "ARTWORK");
		GVAR_TargetButton.HealthBar:SetWidth((buttonWidth - 2) - (buttonHeight - 2) - (buttonHeight - 2));
		GVAR_TargetButton.HealthBar:SetHeight(buttonHeight - 2);
		GVAR_TargetButton.HealthBar:SetPoint("LEFT", GVAR_TargetButton.ClassColorBackground, "LEFT", 0, 0);
		GVAR_TargetButton.HealthBar:SetTexture(0, 0, 0, 0);
		
		GVAR_TargetButton.HealthTextButton = CreateFrame("Button", nil, GVAR_TargetButton);
		GVAR_TargetButton.HealthText = GVAR_TargetButton.HealthTextButton:CreateFontString(nil, "OVERLAY", "GameFontNormal");
		GVAR_TargetButton.HealthText:SetWidth((buttonWidth - 2) - (buttonHeight - 2) - (buttonHeight - 2) - 2);
		GVAR_TargetButton.HealthText:SetHeight(buttonHeight - 2);
		GVAR_TargetButton.HealthText:SetPoint("RIGHT", GVAR_TargetButton.ClassColorBackground, "RIGHT", 0, 0);
		GVAR_TargetButton.HealthText:SetJustifyH("RIGHT");
		
		GVAR_TargetButton.Name = GVAR_TargetButton:CreateFontString(nil, "OVERLAY", "GameFontNormal");
		GVAR_TargetButton.Name:SetWidth((buttonWidth - 2) - (buttonHeight - 2) - (buttonHeight - 2) - 2)
		GVAR_TargetButton.Name:SetHeight(buttonHeight - 2)
		GVAR_TargetButton.Name:SetPoint("LEFT", GVAR_TargetButton.ClassColorBackground, "LEFT", 2, 0);
		GVAR_TargetButton.Name:SetJustifyH("LEFT");
		
		GVAR_TargetButton.TargetCountBackground = GVAR_TargetButton:CreateTexture(nil, "ARTWORK");
		GVAR_TargetButton.TargetCountBackground:SetWidth(20);
		GVAR_TargetButton.TargetCountBackground:SetHeight(buttonHeight - 2);
		GVAR_TargetButton.TargetCountBackground:SetPoint("RIGHT", GVAR_TargetButton, "RIGHT", -1, 0);
		GVAR_TargetButton.TargetCountBackground:SetTexture(0, 0, 0, 1);
		GVAR_TargetButton.TargetCountBackground:SetAlpha(1);
		
		GVAR_TargetButton.TargetCount = GVAR_TargetButton:CreateFontString(nil, "OVERLAY", "GameFontNormal");
		GVAR_TargetButton.TargetCount:SetWidth(20);
		GVAR_TargetButton.TargetCount:SetHeight(buttonHeight - 4);
		GVAR_TargetButton.TargetCount:SetPoint("CENTER", GVAR_TargetButton.TargetCountBackground, "CENTER", 0, 0);
		GVAR_TargetButton.TargetCount:SetJustifyH("CENTER");
		
		GVAR_TargetButton.TargetTextureButton = CreateFrame("Button", nil, GVAR_TargetButton)
		GVAR_TargetButton.TargetTexture = GVAR_TargetButton.TargetTextureButton:CreateTexture(nil, "OVERLAY");
		GVAR_TargetButton.TargetTexture:SetWidth(buttonHeight - 2);
		GVAR_TargetButton.TargetTexture:SetHeight(buttonHeight - 2);
		GVAR_TargetButton.TargetTexture:SetPoint("LEFT", GVAR_TargetButton, "RIGHT", 0, 0);
		GVAR_TargetButton.TargetTexture:SetTexture(AddonIcon);
		GVAR_TargetButton.TargetTexture:SetAlpha(0);

		GVAR_TargetButton.HealersTexture = GVAR_TargetButton:CreateTexture(nil, "BORDER");
		GVAR_TargetButton.HealersTexture:SetWidth(buttonHeight - 2);
		GVAR_TargetButton.HealersTexture:SetHeight(buttonHeight - 2);
		if OPT.ButtonRoleLayoutPos[currentSize] == 2 then -- LEFT
			GVAR_TargetButton.HealersTexture:SetPoint("LEFT", GVAR_TargetButton.RangeTexture, "RIGHT", buttonHeight, 0);
		end
		GVAR_TargetButton.HealersTexture:SetTexture(battleFieldRoleIcons[1]);
		GVAR_TargetButton.HealersTexture:SetAlpha(0);

		
		GVAR_TargetButton.FocusTextureButton = CreateFrame("Button", nil, GVAR_TargetButton);
		GVAR_TargetButton.FocusTexture = GVAR_TargetButton.FocusTextureButton:CreateTexture(nil, "OVERLAY");
		GVAR_TargetButton.FocusTexture:SetWidth(buttonHeight - 2);
		GVAR_TargetButton.FocusTexture:SetHeight(buttonHeight - 2);
		GVAR_TargetButton.FocusTexture:SetPoint("LEFT", GVAR_TargetButton, "RIGHT", 0, 0);
		GVAR_TargetButton.FocusTexture:SetTexture("Interface\\AddOns\\BattlegroundTargets\\Textures\\Focus");
		GVAR_TargetButton.FocusTexture:SetAlpha(0);
		
		GVAR_TargetButton.FlagTextureButton = CreateFrame("Button", nil, GVAR_TargetButton);
		GVAR_TargetButton.FlagTexture = GVAR_TargetButton.FlagTextureButton:CreateTexture(nil, "OVERLAY");
		GVAR_TargetButton.FlagTexture:SetWidth(buttonHeight - 2);
		GVAR_TargetButton.FlagTexture:SetHeight(buttonHeight - 2);
		GVAR_TargetButton.FlagTexture:SetPoint("LEFT", GVAR_TargetButton, "RIGHT", 0, 0);
		GVAR_TargetButton.FlagTexture:SetTexCoord(0.15625001, 0.84374999, 0.15625001, 0.84374999);
		
		if playerFactionDEF == 0 then GVAR_TargetButton.FlagTexture:SetTexture("Interface\\WorldStateFrame\\HordeFlag");
		else GVAR_TargetButton.FlagTexture:SetTexture("Interface\\WorldStateFrame\\AllianceFlag"); end
		
		GVAR_TargetButton.FlagTexture:SetAlpha(0);
		
		GVAR_TargetButton.AssistTextureButton = CreateFrame("Button", nil, GVAR_TargetButton);
		GVAR_TargetButton.AssistTexture = GVAR_TargetButton.AssistTextureButton:CreateTexture(nil, "OVERLAY");
		GVAR_TargetButton.AssistTexture:SetWidth(buttonHeight - 2);
		GVAR_TargetButton.AssistTexture:SetHeight(buttonHeight - 2);
		GVAR_TargetButton.AssistTexture:SetPoint("LEFT", GVAR_TargetButton, "RIGHT", 0, 0);
		GVAR_TargetButton.AssistTexture:SetTexCoord(0.07812501, 0.92187499, 0.07812501, 0.92187499);
		GVAR_TargetButton.AssistTexture:SetTexture("Interface\\Icons\\Ability_Hunter_SniperShot");
		GVAR_TargetButton.AssistTexture:SetAlpha(0);
		
		GVAR_TargetButton:RegisterForClicks("AnyUp");
		GVAR_TargetButton:SetAttribute("type1", "macro");
		GVAR_TargetButton:SetAttribute("type2", "macro");
		GVAR_TargetButton:SetAttribute("macrotext1", "");
		GVAR_TargetButton:SetAttribute("macrotext2", "");
		GVAR_TargetButton:SetScript("OnEnter", OnEnter);
		GVAR_TargetButton:SetScript("OnLeave", OnLeave);
	end

	GVAR.ScoreUpdateTexture = GVAR.TargetButton[1]:CreateTexture(nil, "OVERLAY");
	GVAR.ScoreUpdateTexture:SetWidth(Textures.UpdateWarning.width);
	GVAR.ScoreUpdateTexture:SetHeight(Textures.UpdateWarning.height);
	GVAR.ScoreUpdateTexture:SetPoint("BOTTOMLEFT", GVAR.TargetButton[1], "TOPLEFT", 1, 1);
	GVAR.ScoreUpdateTexture:SetTexture(Textures.BattlegroundTargetsIcons.path);
	GVAR.ScoreUpdateTexture:SetTexCoord(unpack(Textures.UpdateWarning.coords));
	
	GVAR.WorldStateScoreWarning = CreateFrame("Frame", nil, WorldStateScoreFrame);
	TEMPLATE.BorderTRBL(GVAR.WorldStateScoreWarning);
	GVAR.WorldStateScoreWarning:SetToplevel(true);
	GVAR.WorldStateScoreWarning:SetHeight(30);
	GVAR.WorldStateScoreWarning:SetPoint("BOTTOM", WorldStateScoreFrame, "TOP", 0, 10);
	GVAR.WorldStateScoreWarning:Hide();
	
	GVAR.WorldStateScoreWarning.Texture = GVAR.WorldStateScoreWarning:CreateTexture(nil, "ARTWORK");
	GVAR.WorldStateScoreWarning.Texture:SetWidth(20);
	GVAR.WorldStateScoreWarning.Texture:SetHeight(17.419);
	GVAR.WorldStateScoreWarning.Texture:SetPoint("LEFT", GVAR.WorldStateScoreWarning, "LEFT", 5, 0);
	GVAR.WorldStateScoreWarning.Texture:SetTexture("Interface\\DialogFrame\\UI-Dialog-Icon-AlertNew");
	GVAR.WorldStateScoreWarning.Texture:SetTexCoord(1/64, 63/64, 1/64, 55/64);
	
	GVAR.WorldStateScoreWarning.Text = GVAR.WorldStateScoreWarning:CreateFontString(nil, "ARTWORK", "GameFontNormal");
	GVAR.WorldStateScoreWarning.Text:SetHeight(30);
	GVAR.WorldStateScoreWarning.Text:SetPoint("LEFT", GVAR.WorldStateScoreWarning.Texture, "RIGHT", 5, 0);
	GVAR.WorldStateScoreWarning.Text:SetJustifyH("CENTER");
	GVAR.WorldStateScoreWarning.Text:SetFont(fontPath, 10);
	GVAR.WorldStateScoreWarning.Text:SetText(L["BattlegroundTargets does not update if this Tab is opened."]);
	
	GVAR.WorldStateScoreWarning.Close = CreateFrame("Button", nil, GVAR.WorldStateScoreWarning);
	TEMPLATE.IconButton(GVAR.WorldStateScoreWarning.Close, 1);
	GVAR.WorldStateScoreWarning.Close:SetWidth(20);
	GVAR.WorldStateScoreWarning.Close:SetHeight(20);
	GVAR.WorldStateScoreWarning.Close:SetPoint("TOPRIGHT", GVAR.WorldStateScoreWarning, "TOPRIGHT", 0, 0);
	GVAR.WorldStateScoreWarning.Close:SetScript("OnClick", function() GVAR.WorldStateScoreWarning:Hide(); end);

	local width = GVAR.WorldStateScoreWarning.Text:GetStringWidth() + 20;
	GVAR.WorldStateScoreWarning.Text:SetWidth(width);
	GVAR.WorldStateScoreWarning:SetWidth(30 + width + 30);
end


function BattlegroundTargets:CreateOptionsFrame()
	BattlegroundTargets:DefaultShuffle();

	local heightBase = 58; -- 10+16+10+22
	local heightBracket = 497; -- 10+16+10  +1+  10+16 + 10+16 + 10+24+10 + (14*16) + (14*10)
	local heightTotal = heightBase + heightBracket + 30 + 10;
	
	GVAR.OptionsFrame = CreateFrame("Frame", "BattlegroundTargets_OptionsFrame", UIParent);
	TEMPLATE.BorderTRBL(GVAR.OptionsFrame);
	GVAR.OptionsFrame:EnableMouse(true);
	GVAR.OptionsFrame:SetMovable(true);
	GVAR.OptionsFrame:SetToplevel(true);
	GVAR.OptionsFrame:SetClampedToScreen(true);
	GVAR.OptionsFrame:SetHeight(heightTotal);
	GVAR.OptionsFrame:SetScript("OnShow", function() if(not inWorld) then return; end BattlegroundTargets:OptionsFrameShow(); end);
	GVAR.OptionsFrame:SetScript("OnHide", function() if(not inWorld) then return; end BattlegroundTargets:OptionsFrameHide(); end);
	GVAR.OptionsFrame:SetScript("OnMouseWheel", NOOP);
	GVAR.OptionsFrame:Hide();
	
	GVAR.OptionsFrame.CloseConfig = CreateFrame("Button", nil, GVAR.OptionsFrame);
	TEMPLATE.TextButton(GVAR.OptionsFrame.CloseConfig, L["Close Configuration"], 1);
	GVAR.OptionsFrame.CloseConfig:SetPoint("BOTTOM", GVAR.OptionsFrame, "BOTTOM", 0, 10);
	GVAR.OptionsFrame.CloseConfig:SetPoint("LEFT", GVAR.OptionsFrame, "LEFT", 10, 0);
	GVAR.OptionsFrame.CloseConfig:SetHeight(30);
	GVAR.OptionsFrame.CloseConfig:SetScript("OnClick", function() GVAR.OptionsFrame:Hide(); end);
	
	GVAR.OptionsFrame.Base = CreateFrame("Frame", nil, GVAR.OptionsFrame);
	TEMPLATE.BorderTRBL(GVAR.OptionsFrame.Base);
	GVAR.OptionsFrame.Base:SetHeight(heightBase);
	GVAR.OptionsFrame.Base:SetPoint("TOPLEFT", GVAR.OptionsFrame, "TOPLEFT", 0, 0);
	GVAR.OptionsFrame.Base:EnableMouse(true);
	
	GVAR.OptionsFrame.Title = GVAR.OptionsFrame.Base:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
	GVAR.OptionsFrame.Title:SetPoint("TOPLEFT", GVAR.OptionsFrame.Base, "TOPLEFT", 0, -10);
	GVAR.OptionsFrame.Title:SetJustifyH("CENTER");
	GVAR.OptionsFrame.Title:SetText(UITitle);
	
	GVAR.OptionsFrame.TabGeneral = CreateFrame("Button", nil, GVAR.OptionsFrame.Base);
	TEMPLATE.TabButton(GVAR.OptionsFrame.TabGeneral, nil, BattlegroundTargets_Options.EnableBracket[10]);
	GVAR.OptionsFrame.TabGeneral:SetHeight(22);
	GVAR.OptionsFrame.TabGeneral:SetScript("OnClick", function()
		if(GVAR.OptionsFrame.ConfigGeneral:IsShown()) then
			TEMPLATE.SetTabButton(GVAR.OptionsFrame.TabGeneral, nil);
			GVAR.OptionsFrame.ConfigGeneral:Hide();
			GVAR.OptionsFrame.ConfigBrackets:Show();
			GVAR.OptionsFrame["TabRaidSize"..testSize].TextureBottom:SetTexture(0, 0, 0, 1);
		else
			TEMPLATE.SetTabButton(GVAR.OptionsFrame.TabGeneral, true);
			GVAR.OptionsFrame.ConfigGeneral:Show();
			GVAR.OptionsFrame.ConfigBrackets:Hide();
			GVAR.OptionsFrame["TabRaidSize"..testSize].TextureBottom:SetTexture(0.8, 0.2, 0.2, 1);
		end
	end);
	
	GVAR.OptionsFrame.TabRaidSize10 = CreateFrame("Button", nil, GVAR.OptionsFrame.Base);
	TEMPLATE.TabButton(GVAR.OptionsFrame.TabRaidSize10, L["10 vs 10"], BattlegroundTargets_Options.EnableBracket[10]);
	GVAR.OptionsFrame.TabRaidSize10:SetHeight(22);
	GVAR.OptionsFrame.TabRaidSize10:SetScript("OnClick", function()
		GVAR.OptionsFrame.ConfigGeneral:Hide();
		GVAR.OptionsFrame.ConfigBrackets:Show();
		TEMPLATE.SetTabButton(GVAR.OptionsFrame.TabGeneral, nil);
		TEMPLATE.SetTabButton(GVAR.OptionsFrame.TabRaidSize10, true);
		TEMPLATE.SetTabButton(GVAR.OptionsFrame.TabRaidSize15, nil);
		TEMPLATE.SetTabButton(GVAR.OptionsFrame.TabRaidSize40, nil);
		if(testSize == 10) then return; end
		testSize = 10;
		BattlegroundTargets:CheckForEnabledBracket(testSize);
		if(BattlegroundTargets_Options.EnableBracket[testSize]) then
			BattlegroundTargets:EnableConfigMode();
		else
			BattlegroundTargets:DisableConfigMode();
		end
	end);
	
	GVAR.OptionsFrame.TabRaidSize15 = CreateFrame("Button", nil, GVAR.OptionsFrame.Base);
	TEMPLATE.TabButton(GVAR.OptionsFrame.TabRaidSize15, L["15 vs 15"], BattlegroundTargets_Options.EnableBracket[15]);
	GVAR.OptionsFrame.TabRaidSize15:SetHeight(22);
	GVAR.OptionsFrame.TabRaidSize15:SetScript("OnClick", function()
		GVAR.OptionsFrame.ConfigGeneral:Hide();
		GVAR.OptionsFrame.ConfigBrackets:Show();
		TEMPLATE.SetTabButton(GVAR.OptionsFrame.TabGeneral, nil);
		TEMPLATE.SetTabButton(GVAR.OptionsFrame.TabRaidSize10, nil);
		TEMPLATE.SetTabButton(GVAR.OptionsFrame.TabRaidSize15, true);
		TEMPLATE.SetTabButton(GVAR.OptionsFrame.TabRaidSize40, nil);
		if(testSize == 15) then return; end
		testSize = 15;
		BattlegroundTargets:CheckForEnabledBracket(testSize);
		if(BattlegroundTargets_Options.EnableBracket[testSize]) then
			BattlegroundTargets:EnableConfigMode();
		else
			BattlegroundTargets:DisableConfigMode();
		end
	end);
	
	GVAR.OptionsFrame.TabRaidSize40 = CreateFrame("Button", nil, GVAR.OptionsFrame.Base);
	TEMPLATE.TabButton(GVAR.OptionsFrame.TabRaidSize40, L["40 vs 40"], BattlegroundTargets_Options.EnableBracket[40]);
	GVAR.OptionsFrame.TabRaidSize40:SetHeight(22);
	GVAR.OptionsFrame.TabRaidSize40:SetScript("OnClick", function()
		GVAR.OptionsFrame.ConfigGeneral:Hide();
		GVAR.OptionsFrame.ConfigBrackets:Show();
		TEMPLATE.SetTabButton(GVAR.OptionsFrame.TabGeneral, nil);
		TEMPLATE.SetTabButton(GVAR.OptionsFrame.TabRaidSize10, nil);
		TEMPLATE.SetTabButton(GVAR.OptionsFrame.TabRaidSize15, nil);
		TEMPLATE.SetTabButton(GVAR.OptionsFrame.TabRaidSize40, true);
		if(testSize == 40) then return; end
		testSize = 40;
		BattlegroundTargets:CheckForEnabledBracket(testSize);
		if(BattlegroundTargets_Options.EnableBracket[testSize]) then
			BattlegroundTargets:EnableConfigMode();
		else
			BattlegroundTargets:DisableConfigMode();
		end
	end);
	
	if(testSize == 10) then
		TEMPLATE.SetTabButton(GVAR.OptionsFrame.TabGeneral, nil);
		TEMPLATE.SetTabButton(GVAR.OptionsFrame.TabRaidSize10, true);
		TEMPLATE.SetTabButton(GVAR.OptionsFrame.TabRaidSize15, nil);
		TEMPLATE.SetTabButton(GVAR.OptionsFrame.TabRaidSize40, nil);
	elseif(testSize == 15) then
		TEMPLATE.SetTabButton(GVAR.OptionsFrame.TabGeneral, nil);
		TEMPLATE.SetTabButton(GVAR.OptionsFrame.TabRaidSize10, nil);
		TEMPLATE.SetTabButton(GVAR.OptionsFrame.TabRaidSize15, true);
		TEMPLATE.SetTabButton(GVAR.OptionsFrame.TabRaidSize40, nil);
	elseif(testSize == 40) then
		TEMPLATE.SetTabButton(GVAR.OptionsFrame.TabGeneral, nil);
		TEMPLATE.SetTabButton(GVAR.OptionsFrame.TabRaidSize10, nil);
		TEMPLATE.SetTabButton(GVAR.OptionsFrame.TabRaidSize15, nil);
		TEMPLATE.SetTabButton(GVAR.OptionsFrame.TabRaidSize40, true);
	end
	
	GVAR.OptionsFrame.ConfigBrackets = CreateFrame("Frame", nil, GVAR.OptionsFrame);
	GVAR.OptionsFrame.ConfigBrackets:SetHeight(heightBracket);
	GVAR.OptionsFrame.ConfigBrackets:SetPoint("TOPLEFT", GVAR.OptionsFrame.Base, "BOTTOMLEFT", 0, 1);
	GVAR.OptionsFrame.ConfigBrackets:Hide();
	
	GVAR.OptionsFrame.EnableBracket = CreateFrame("CheckButton", nil, GVAR.OptionsFrame.ConfigBrackets);
	TEMPLATE.CheckButton(GVAR.OptionsFrame.EnableBracket, 16, 4, L["Enable"]);
	GVAR.OptionsFrame.EnableBracket:SetPoint("LEFT", GVAR.OptionsFrame, "LEFT", 10, 0);
	GVAR.OptionsFrame.EnableBracket:SetPoint("TOP", GVAR.OptionsFrame.Base, "BOTTOM", 0, -10);
	GVAR.OptionsFrame.EnableBracket:SetChecked(BattlegroundTargets_Options.EnableBracket[currentSize]);
	GVAR.OptionsFrame.EnableBracket:SetScript("OnClick", function()
		BattlegroundTargets_Options.EnableBracket[currentSize] = not BattlegroundTargets_Options.EnableBracket[currentSize];
		GVAR.OptionsFrame.EnableBracket:SetChecked(BattlegroundTargets_Options.EnableBracket[currentSize]);
		BattlegroundTargets:CheckForEnabledBracket(currentSize);
		
		if(BattlegroundTargets_Options.EnableBracket[currentSize]) then
			BattlegroundTargets:EnableConfigMode();
		else
			BattlegroundTargets:DisableConfigMode();
		end
	end);
	
	GVAR.OptionsFrame.IndependentPos = CreateFrame("CheckButton", nil, GVAR.OptionsFrame.ConfigBrackets);
	TEMPLATE.CheckButton(GVAR.OptionsFrame.IndependentPos, 16, 4, L["Independent Positioning"]);
	GVAR.OptionsFrame.IndependentPos:SetPoint("LEFT", GVAR.OptionsFrame.EnableBracket, "RIGHT", 50, 0);
	GVAR.OptionsFrame.IndependentPos:SetChecked(BattlegroundTargets_Options.IndependentPositioning[currentSize]);
	GVAR.OptionsFrame.IndependentPos:SetScript("OnClick", function()
		BattlegroundTargets_Options.IndependentPositioning[currentSize] = not BattlegroundTargets_Options.IndependentPositioning[currentSize];
		GVAR.OptionsFrame.IndependentPos:SetChecked(BattlegroundTargets_Options.IndependentPositioning[currentSize]);
		if(not BattlegroundTargets_Options.IndependentPositioning[currentSize]) then
			BattlegroundTargets_Options.pos["BattlegroundTargets_MainFrame"..currentSize.."_posX"] = nil;
			BattlegroundTargets_Options.pos["BattlegroundTargets_MainFrame"..currentSize.."_posY"] = nil;
			if(inCombat or InCombatLockdown()) then
				reCheckBG = true;
				return;
			end
			BattlegroundTargets:Frame_SetupPosition("BattlegroundTargets_MainFrame");
		end
	end);
	
	GVAR.OptionsFrame.Dummy1 = CreateFrame("Frame", nil, GVAR.OptionsFrame.ConfigBrackets);
	TEMPLATE.BorderTRBL(GVAR.OptionsFrame.Dummy1);
	GVAR.OptionsFrame.Dummy1:SetHeight(1);
	GVAR.OptionsFrame.Dummy1:SetPoint("LEFT", GVAR.OptionsFrame, "LEFT", 26, 0);
	GVAR.OptionsFrame.Dummy1:SetPoint("TOP", GVAR.OptionsFrame.IndependentPos, "BOTTOM", 0, -10);
	
	GVAR.OptionsFrame.LayoutTHText = GVAR.OptionsFrame.ConfigBrackets:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	GVAR.OptionsFrame.LayoutTHText:SetHeight(16);
	GVAR.OptionsFrame.LayoutTHText:SetPoint("LEFT", GVAR.OptionsFrame, "LEFT", 30, 0);
	GVAR.OptionsFrame.LayoutTHText:SetPoint("TOP", GVAR.OptionsFrame.Dummy1, "BOTTOM", 0, -10);
	GVAR.OptionsFrame.LayoutTHText:SetJustifyH("LEFT");
	GVAR.OptionsFrame.LayoutTHText:SetText(L["Layout"]..":");
	GVAR.OptionsFrame.LayoutTHText:SetTextColor(1, 1, 1, 1);
	
	GVAR.OptionsFrame.LayoutTHx18 = CreateFrame("CheckButton", nil, GVAR.OptionsFrame.ConfigBrackets);
	TEMPLATE.CheckButton(GVAR.OptionsFrame.LayoutTHx18, 16, 4, nil, "l40_18");
	GVAR.OptionsFrame.LayoutTHx18:SetPoint("LEFT", GVAR.OptionsFrame.LayoutTHText, "RIGHT", 10, 0);
	GVAR.OptionsFrame.LayoutTHx18:SetScript("OnClick", function()
		BattlegroundTargets_Options.LayoutTH[currentSize] = 18;
		GVAR.OptionsFrame.LayoutTHx18:SetChecked(true);
		GVAR.OptionsFrame.LayoutTHx24:SetChecked(false);
		GVAR.OptionsFrame.LayoutTHx42:SetChecked(false);
		GVAR.OptionsFrame.LayoutTHx81:SetChecked(false);
		BattlegroundTargets:SetupLayout();
	end);
	
	GVAR.OptionsFrame.LayoutTHx24 = CreateFrame("CheckButton", nil, GVAR.OptionsFrame.ConfigBrackets);
	TEMPLATE.CheckButton(GVAR.OptionsFrame.LayoutTHx24, 16, 4, nil, "l40_24");
	GVAR.OptionsFrame.LayoutTHx24:SetPoint("LEFT", GVAR.OptionsFrame.LayoutTHx18, "RIGHT", 0, 0);
	GVAR.OptionsFrame.LayoutTHx24:SetScript("OnClick", function()
		BattlegroundTargets_Options.LayoutTH[currentSize] = 24;
		GVAR.OptionsFrame.LayoutTHx18:SetChecked(false);
		GVAR.OptionsFrame.LayoutTHx24:SetChecked(true);
		GVAR.OptionsFrame.LayoutTHx42:SetChecked(false);
		GVAR.OptionsFrame.LayoutTHx81:SetChecked(false);
		BattlegroundTargets:SetupLayout();
	end);
	
	GVAR.OptionsFrame.LayoutTHx42 = CreateFrame("CheckButton", nil, GVAR.OptionsFrame.ConfigBrackets);
	TEMPLATE.CheckButton(GVAR.OptionsFrame.LayoutTHx42, 16, 4, nil, "l40_42");
	GVAR.OptionsFrame.LayoutTHx42:SetPoint("LEFT", GVAR.OptionsFrame.LayoutTHx24, "RIGHT", 0, 0);
	GVAR.OptionsFrame.LayoutTHx42:SetScript("OnClick", function()
		BattlegroundTargets_Options.LayoutTH[currentSize] = 42;
		GVAR.OptionsFrame.LayoutTHx18:SetChecked(false);
		GVAR.OptionsFrame.LayoutTHx24:SetChecked(false);
		GVAR.OptionsFrame.LayoutTHx42:SetChecked(true);
		GVAR.OptionsFrame.LayoutTHx81:SetChecked(false);
		BattlegroundTargets:SetupLayout();
	end);
	
	GVAR.OptionsFrame.LayoutTHx81 = CreateFrame("CheckButton", nil, GVAR.OptionsFrame.ConfigBrackets);
	TEMPLATE.CheckButton(GVAR.OptionsFrame.LayoutTHx81, 16, 4, nil, "l40_81");
	GVAR.OptionsFrame.LayoutTHx81:SetPoint("LEFT", GVAR.OptionsFrame.LayoutTHx42, "RIGHT", 0, 0);
	GVAR.OptionsFrame.LayoutTHx81:SetScript("OnClick", function()
		BattlegroundTargets_Options.LayoutTH[currentSize] = 81;
		GVAR.OptionsFrame.LayoutTHx18:SetChecked(false);
		GVAR.OptionsFrame.LayoutTHx24:SetChecked(false);
		GVAR.OptionsFrame.LayoutTHx42:SetChecked(false);
		GVAR.OptionsFrame.LayoutTHx81:SetChecked(true);
		BattlegroundTargets:SetupLayout();
	end);
	
	GVAR.OptionsFrame.LayoutSpace = CreateFrame("Slider", nil, GVAR.OptionsFrame.ConfigBrackets);
	GVAR.OptionsFrame.LayoutSpaceText = GVAR.OptionsFrame.ConfigBrackets:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	TEMPLATE.Slider(GVAR.OptionsFrame.LayoutSpace, 85, 1, 0, 20, BattlegroundTargets_Options.LayoutSpace[currentSize], function(self, value)
		if(value == BattlegroundTargets_Options.LayoutSpace[currentSize]) then return; end
		BattlegroundTargets_Options.LayoutSpace[currentSize] = value;
		GVAR.OptionsFrame.LayoutSpaceText:SetText(value);
		BattlegroundTargets:SetupLayout();
	end, "blank");
	
	GVAR.OptionsFrame.LayoutSpace:SetPoint("LEFT", GVAR.OptionsFrame.LayoutTHx81, "RIGHT", 0, 0);
	GVAR.OptionsFrame.LayoutSpaceText:SetHeight(20);
	GVAR.OptionsFrame.LayoutSpaceText:SetPoint("LEFT", GVAR.OptionsFrame.LayoutSpace, "RIGHT", 5, 0);
	GVAR.OptionsFrame.LayoutSpaceText:SetJustifyH("LEFT");
	GVAR.OptionsFrame.LayoutSpaceText:SetText(BattlegroundTargets_Options.LayoutSpace[currentSize]);
	GVAR.OptionsFrame.LayoutSpaceText:SetTextColor(1, 1, 0.49, 1);
	local layoutW = 30 + GVAR.OptionsFrame.LayoutTHText:GetStringWidth() + 10 +
		GVAR.OptionsFrame.LayoutTHx18:GetWidth() + 0 +
		GVAR.OptionsFrame.LayoutTHx24:GetWidth() + 0 +
		GVAR.OptionsFrame.LayoutTHx42:GetWidth() + 0 +
		GVAR.OptionsFrame.LayoutTHx81:GetWidth() + 0 +
		GVAR.OptionsFrame.LayoutSpace:GetWidth() + 50;
	
	GVAR.OptionsFrame.CopySettings = CreateFrame("Button", nil, GVAR.OptionsFrame.ConfigBrackets);
	TEMPLATE.TextButton(GVAR.OptionsFrame.CopySettings, string_format(L["Copy this settings to '%s'"], L["15 vs 15"]), 4);
	GVAR.OptionsFrame.CopySettings:SetPoint("TOP", GVAR.OptionsFrame.Dummy1, "BOTTOM", 0, -62); -- 10+16+10+16+10
	GVAR.OptionsFrame.CopySettings:SetWidth(GVAR.OptionsFrame.CopySettings:GetTextWidth() + 40);
	GVAR.OptionsFrame.CopySettings:SetHeight(24);
	GVAR.OptionsFrame.CopySettings:SetScript("OnClick", function() BattlegroundTargets:CopySettings(currentSize); end);
	GVAR.OptionsFrame.CopySettings:SetScript("OnEnter", function()
		GVAR.OptionsFrame.LayoutTHx18.Highlight:Show();
		GVAR.OptionsFrame.LayoutTHx24.Highlight:Show();
		GVAR.OptionsFrame.LayoutTHx42.Highlight:Show();
		GVAR.OptionsFrame.LayoutTHx81.Highlight:Show();
		GVAR.OptionsFrame.LayoutSpace.Background:SetTexture(1, 1, 1, 0.1);
		GVAR.OptionsFrame.ClassIcon.Highlight:Show();
		GVAR.OptionsFrame.ShowLeader.Highlight:Show();
		GVAR.OptionsFrame.ShowRealm.Highlight:Show();
		GVAR.OptionsFrame.ShowTargetCount.Highlight:Show();
		GVAR.OptionsFrame.ShowTargetIndicator.Highlight:Show();
		GVAR.OptionsFrame.TargetScaleSlider.Background:SetTexture(1, 1, 1, 0.1);
		GVAR.OptionsFrame.TargetPositionSlider.Background:SetTexture(1, 1, 1, 0.1);
		GVAR.OptionsFrame.ShowFocusIndicator.Highlight:Show();
		GVAR.OptionsFrame.FocusScaleSlider.Background:SetTexture(1, 1, 1, 0.1);
		GVAR.OptionsFrame.FocusPositionSlider.Background:SetTexture(1, 1, 1, 0.1);
		GVAR.OptionsFrame.ShowFlag.Highlight:Show();
		GVAR.OptionsFrame.FlagScaleSlider.Background:SetTexture(1, 1, 1, 0.1);
		GVAR.OptionsFrame.FlagPositionSlider.Background:SetTexture(1, 1, 1, 0.1);
		GVAR.OptionsFrame.ShowAssist.Highlight:Show();
		GVAR.OptionsFrame.AssistScaleSlider.Background:SetTexture(1, 1, 1, 0.1);
		GVAR.OptionsFrame.AssistPositionSlider.Background:SetTexture(1, 1, 1, 0.1);
		GVAR.OptionsFrame.ShowHealthBar.Highlight:Show();
		GVAR.OptionsFrame.ShowHealthText.Highlight:Show();
		GVAR.OptionsFrame.RangeCheck.Highlight:Show();
		GVAR.OptionsFrame.RangeCheckTypePullDown:LockHighlight();
		GVAR.OptionsFrame.RangeDisplayPullDown:LockHighlight();
		GVAR.OptionsFrame.SortByPullDown:LockHighlight();
		GVAR.OptionsFrame.SortDetailPullDown:LockHighlight();
		GVAR.OptionsFrame.FontSlider.Background:SetTexture(1, 1, 1, 0.1);
		GVAR.OptionsFrame.ScaleSlider.Background:SetTexture(1, 1, 1, 0.1);
		GVAR.OptionsFrame.WidthSlider.Background:SetTexture(1, 1, 1, 0.1);
		GVAR.OptionsFrame.HeightSlider.Background:SetTexture(1, 1, 1, 0.1);
	end);
	
	GVAR.OptionsFrame.CopySettings:SetScript("OnLeave", function()
		GVAR.OptionsFrame.LayoutTHx18.Highlight:Hide();
		GVAR.OptionsFrame.LayoutTHx24.Highlight:Hide();
		GVAR.OptionsFrame.LayoutTHx42.Highlight:Hide();
		GVAR.OptionsFrame.LayoutTHx81.Highlight:Hide();
		GVAR.OptionsFrame.LayoutSpace.Background:SetTexture(0, 0, 0, 0);
		GVAR.OptionsFrame.ClassIcon.Highlight:Hide();
		GVAR.OptionsFrame.ShowLeader.Highlight:Hide();  
		GVAR.OptionsFrame.ShowRealm.Highlight:Hide();
		GVAR.OptionsFrame.ShowTargetCount.Highlight:Hide();
		GVAR.OptionsFrame.ShowTargetIndicator.Highlight:Hide();
		GVAR.OptionsFrame.TargetScaleSlider.Background:SetTexture(0, 0, 0, 0);
		GVAR.OptionsFrame.TargetPositionSlider.Background:SetTexture(0, 0, 0, 0);
		GVAR.OptionsFrame.ShowFocusIndicator.Highlight:Hide();
		GVAR.OptionsFrame.FocusScaleSlider.Background:SetTexture(0, 0, 0, 0);
		GVAR.OptionsFrame.FocusPositionSlider.Background:SetTexture(0, 0, 0, 0);
		GVAR.OptionsFrame.ShowFlag.Highlight:Hide();
		GVAR.OptionsFrame.FlagScaleSlider.Background:SetTexture(0, 0, 0, 0);
		GVAR.OptionsFrame.FlagPositionSlider.Background:SetTexture(0, 0, 0, 0);
		GVAR.OptionsFrame.ShowAssist.Highlight:Hide();
		GVAR.OptionsFrame.AssistScaleSlider.Background:SetTexture(0, 0, 0, 0);
		GVAR.OptionsFrame.AssistPositionSlider.Background:SetTexture(0, 0, 0, 0);
		GVAR.OptionsFrame.ShowHealthBar.Highlight:Hide();
		GVAR.OptionsFrame.ShowHealthText.Highlight:Hide();
		GVAR.OptionsFrame.RangeCheck.Highlight:Hide();
		GVAR.OptionsFrame.RangeCheckTypePullDown:UnlockHighlight();
		GVAR.OptionsFrame.RangeDisplayPullDown:UnlockHighlight();
		GVAR.OptionsFrame.SortByPullDown:UnlockHighlight();
		GVAR.OptionsFrame.SortDetailPullDown:UnlockHighlight();
		GVAR.OptionsFrame.FontSlider.Background:SetTexture(0, 0, 0, 0);
		GVAR.OptionsFrame.ScaleSlider.Background:SetTexture(0, 0, 0, 0);
		GVAR.OptionsFrame.WidthSlider.Background:SetTexture(0, 0, 0, 0);
		GVAR.OptionsFrame.HeightSlider.Background:SetTexture(0, 0, 0, 0);
	end);
	
	GVAR.OptionsFrame.ClassIcon = CreateFrame("CheckButton", nil, GVAR.OptionsFrame.ConfigBrackets);
	TEMPLATE.CheckButton(GVAR.OptionsFrame.ClassIcon, 16, 4, L["Show Class Icon"]);
	GVAR.OptionsFrame.ClassIcon:SetPoint("LEFT", GVAR.OptionsFrame, "LEFT", 10, 0);
	GVAR.OptionsFrame.ClassIcon:SetPoint("TOP", GVAR.OptionsFrame.CopySettings, "BOTTOM", 0, -10);
	GVAR.OptionsFrame.ClassIcon:SetChecked(OPT.ButtonClassIcon[currentSize]);
	GVAR.OptionsFrame.ClassIcon:SetScript("OnClick", function()
		BattlegroundTargets_Options.ButtonClassIcon[currentSize] = not BattlegroundTargets_Options.ButtonClassIcon[currentSize];
		OPT.ButtonClassIcon[currentSize] = not OPT.ButtonClassIcon[currentSize];
		GVAR.OptionsFrame.ClassIcon:SetChecked(OPT.ButtonClassIcon[currentSize]);
		BattlegroundTargets:EnableConfigMode();
	end);
	
	GVAR.OptionsFrame.ShowRealm = CreateFrame("CheckButton", nil, GVAR.OptionsFrame.ConfigBrackets);
	TEMPLATE.CheckButton(GVAR.OptionsFrame.ShowRealm, 16, 4, L["Hide Realm"]);
	GVAR.OptionsFrame.ShowRealm:SetPoint("LEFT", GVAR.OptionsFrame, "LEFT", 10, 0);
	GVAR.OptionsFrame.ShowRealm:SetPoint("TOP", GVAR.OptionsFrame.ClassIcon, "BOTTOM", 0, -10);
	GVAR.OptionsFrame.ShowRealm:SetChecked(OPT.ButtonHideRealm[currentSize]);
	GVAR.OptionsFrame.ShowRealm:SetScript("OnClick", function()
		BattlegroundTargets_Options.ButtonHideRealm[currentSize] = not BattlegroundTargets_Options.ButtonHideRealm[currentSize];
		OPT.ButtonHideRealm[currentSize] = not OPT.ButtonHideRealm[currentSize];
		GVAR.OptionsFrame.ShowRealm:SetChecked(OPT.ButtonHideRealm[currentSize]);
		BattlegroundTargets:EnableConfigMode();
	end);
	
	GVAR.OptionsFrame.ShowLeader = CreateFrame("CheckButton", nil, GVAR.OptionsFrame.ConfigBrackets);
	TEMPLATE.CheckButton(GVAR.OptionsFrame.ShowLeader, 16, 4, L["Show Leader"]);
	GVAR.OptionsFrame.ShowLeader:SetPoint("TOP", GVAR.OptionsFrame.ShowRealm, "TOP", 0, 0);
	GVAR.OptionsFrame.ShowLeader:SetChecked(OPT.ButtonShowLeader[currentSize]);
	GVAR.OptionsFrame.ShowLeader:SetScript("OnClick", function()
		BattlegroundTargets_Options.ButtonShowLeader[currentSize] = not BattlegroundTargets_Options.ButtonShowLeader[currentSize];
		OPT.ButtonShowLeader[currentSize] = not OPT.ButtonShowLeader[currentSize];
		GVAR.OptionsFrame.ShowLeader:SetChecked(OPT.ButtonShowLeader[currentSize]);
		BattlegroundTargets:EnableConfigMode();
	end);
	
	GVAR.OptionsFrame.RoleLayoutPosPullDown = CreateFrame("Button", nil, GVAR.OptionsFrame.ConfigBrackets);
	TEMPLATE.PullDownMenu(GVAR.OptionsFrame.RoleLayoutPosPullDown, "ShowHealer", roleLayoutPos, 0, 3, RoleLayoutPosPullDownFunc);
	GVAR.OptionsFrame.RoleLayoutPosPullDown:SetPoint("LEFT", GVAR.OptionsFrame.ClassIcon, "LEFT", 212, 0);
	GVAR.OptionsFrame.RoleLayoutPosPullDown:SetHeight(18);
	TEMPLATE.EnablePullDownMenu(GVAR.OptionsFrame.RoleLayoutPosPullDown);
	
	GVAR.OptionsFrame.ShowTargetCount = CreateFrame("CheckButton", nil, GVAR.OptionsFrame.ConfigBrackets);
	TEMPLATE.CheckButton(GVAR.OptionsFrame.ShowTargetCount, 16, 4, L["Show Target Count"]);
	GVAR.OptionsFrame.ShowTargetCount:SetPoint("LEFT", GVAR.OptionsFrame, "LEFT", 10, 0);
	GVAR.OptionsFrame.ShowTargetCount:SetPoint("TOP", GVAR.OptionsFrame.ShowRealm, "BOTTOM", 0, -10);
	GVAR.OptionsFrame.ShowTargetCount:SetChecked(OPT.ButtonShowTargetCount[currentSize]);
	GVAR.OptionsFrame.ShowTargetCount:SetScript("OnClick", function()
		BattlegroundTargets_Options.ButtonShowTargetCount[currentSize] = not BattlegroundTargets_Options.ButtonShowTargetCount[currentSize];
		OPT.ButtonShowTargetCount[currentSize] = not OPT.ButtonShowTargetCount[currentSize];
		GVAR.OptionsFrame.ShowTargetCount:SetChecked(OPT.ButtonShowTargetCount[currentSize]);
		BattlegroundTargets:EnableConfigMode();
	end);
	
	local equalTextWidthIcons = 0;
	
	GVAR.OptionsFrame.ShowTargetIndicator = CreateFrame("CheckButton", nil, GVAR.OptionsFrame.ConfigBrackets);
	TEMPLATE.CheckButton(GVAR.OptionsFrame.ShowTargetIndicator, 16, 4, L["Show Target"]);
	GVAR.OptionsFrame.ShowTargetIndicator:SetPoint("LEFT", GVAR.OptionsFrame, "LEFT", 10, 0);
	GVAR.OptionsFrame.ShowTargetIndicator:SetPoint("TOP", GVAR.OptionsFrame.ShowTargetCount, "BOTTOM", 0, -10);
	GVAR.OptionsFrame.ShowTargetIndicator:SetChecked(OPT.ButtonShowTarget[currentSize]);
	GVAR.OptionsFrame.ShowTargetIndicator:SetScript("OnClick", function()
		BattlegroundTargets_Options.ButtonShowTarget[currentSize] = not BattlegroundTargets_Options.ButtonShowTarget[currentSize];
		OPT.ButtonShowTarget[currentSize] = not OPT.ButtonShowTarget[currentSize];
		GVAR.OptionsFrame.ShowTargetIndicator:SetChecked(OPT.ButtonShowTarget[currentSize]);
		
		if(OPT.ButtonShowTarget[currentSize]) then
			TEMPLATE.EnableSlider(GVAR.OptionsFrame.TargetScaleSlider);
			TEMPLATE.EnableSlider(GVAR.OptionsFrame.TargetPositionSlider);
		else
			TEMPLATE.DisableSlider(GVAR.OptionsFrame.TargetScaleSlider);
			TEMPLATE.DisableSlider(GVAR.OptionsFrame.TargetPositionSlider);
		end
		
		BattlegroundTargets:EnableConfigMode();
	end);
	
	local iw = GVAR.OptionsFrame.ShowTargetIndicator:GetWidth();
	if(iw > equalTextWidthIcons) then
		equalTextWidthIcons = iw;
	end
	
	GVAR.OptionsFrame.TargetScaleSlider = CreateFrame("Slider", nil, GVAR.OptionsFrame.ConfigBrackets);
	GVAR.OptionsFrame.TargetScaleSliderText = GVAR.OptionsFrame.ConfigBrackets:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	TEMPLATE.Slider(GVAR.OptionsFrame.TargetScaleSlider, 85, 10, 100, 200, OPT.ButtonTargetScale[currentSize]*100, function(self, value)
		local nvalue = value/100;
		
		if(nvalue == BattlegroundTargets_Options.ButtonTargetScale[currentSize]) then return; end
		BattlegroundTargets_Options.ButtonTargetScale[currentSize] = nvalue;
		OPT.ButtonTargetScale[currentSize] = nvalue;
		GVAR.OptionsFrame.TargetScaleSliderText:SetText(value.."%");
		BattlegroundTargets:EnableConfigMode();
	end, "blank");
	GVAR.OptionsFrame.TargetScaleSlider:SetPoint("LEFT", GVAR.OptionsFrame.ShowTargetIndicator, "RIGHT", 10, 0);
	GVAR.OptionsFrame.TargetScaleSliderText:SetHeight(20);
	GVAR.OptionsFrame.TargetScaleSliderText:SetPoint("LEFT", GVAR.OptionsFrame.TargetScaleSlider, "RIGHT", 5, 0);
	GVAR.OptionsFrame.TargetScaleSliderText:SetJustifyH("LEFT");
	GVAR.OptionsFrame.TargetScaleSliderText:SetText((OPT.ButtonTargetScale[currentSize]*100).."%");
	GVAR.OptionsFrame.TargetScaleSliderText:SetTextColor(1, 1, 0.49, 1);
	
	GVAR.OptionsFrame.TargetPositionSlider = CreateFrame("Slider", nil, GVAR.OptionsFrame.ConfigBrackets);
	GVAR.OptionsFrame.TargetPositionSliderText = GVAR.OptionsFrame.ConfigBrackets:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	TEMPLATE.Slider(GVAR.OptionsFrame.TargetPositionSlider, 85, 5, 0, 100, OPT.ButtonTargetPosition[currentSize], function(self, value)
		if(value == BattlegroundTargets_Options.ButtonTargetPosition[currentSize]) then return; end
		BattlegroundTargets_Options.ButtonTargetPosition[currentSize] = value;
		OPT.ButtonTargetPosition[currentSize] = value;
		GVAR.OptionsFrame.TargetPositionSliderText:SetText(value);
		BattlegroundTargets:EnableConfigMode();
	end, "blank");
	GVAR.OptionsFrame.TargetPositionSlider:SetPoint("LEFT", GVAR.OptionsFrame.TargetScaleSlider, "RIGHT", 50, 0);
	GVAR.OptionsFrame.TargetPositionSliderText:SetHeight(20);
	GVAR.OptionsFrame.TargetPositionSliderText:SetPoint("LEFT", GVAR.OptionsFrame.TargetPositionSlider, "RIGHT", 5, 0);
	GVAR.OptionsFrame.TargetPositionSliderText:SetJustifyH("LEFT");
	GVAR.OptionsFrame.TargetPositionSliderText:SetText(OPT.ButtonTargetPosition[currentSize]);
	GVAR.OptionsFrame.TargetPositionSliderText:SetTextColor(1, 1, 0.49, 1);
	
	GVAR.OptionsFrame.ShowFocusIndicator = CreateFrame("CheckButton", nil, GVAR.OptionsFrame.ConfigBrackets);
	TEMPLATE.CheckButton(GVAR.OptionsFrame.ShowFocusIndicator, 16, 4, L["Show Focus"]);
	GVAR.OptionsFrame.ShowFocusIndicator:SetPoint("LEFT", GVAR.OptionsFrame, "LEFT", 10, 0);
	GVAR.OptionsFrame.ShowFocusIndicator:SetPoint("TOP", GVAR.OptionsFrame.ShowTargetIndicator, "BOTTOM", 0, -10);
	GVAR.OptionsFrame.ShowFocusIndicator:SetChecked(OPT.ButtonShowFocus[currentSize])
	GVAR.OptionsFrame.ShowFocusIndicator:SetScript("OnClick", function()
		BattlegroundTargets_Options.ButtonShowFocus[currentSize] = not BattlegroundTargets_Options.ButtonShowFocus[currentSize];
		OPT.ButtonShowFocus[currentSize] = not OPT.ButtonShowFocus[currentSize];
		GVAR.OptionsFrame.ShowFocusIndicator:SetChecked(OPT.ButtonShowFocus[currentSize]);
		
		if(OPT.ButtonShowFocus[currentSize]) then
			TEMPLATE.EnableSlider(GVAR.OptionsFrame.FocusScaleSlider);
			TEMPLATE.EnableSlider(GVAR.OptionsFrame.FocusPositionSlider);
		else
			TEMPLATE.DisableSlider(GVAR.OptionsFrame.FocusScaleSlider);
			TEMPLATE.DisableSlider(GVAR.OptionsFrame.FocusPositionSlider);
		end
		
		BattlegroundTargets:EnableConfigMode();
	end);
	
	local iw = GVAR.OptionsFrame.ShowFocusIndicator:GetWidth();
	if(iw > equalTextWidthIcons) then
		equalTextWidthIcons = iw;
	end
	
	GVAR.OptionsFrame.FocusScaleSlider = CreateFrame("Slider", nil, GVAR.OptionsFrame.ConfigBrackets);
	GVAR.OptionsFrame.FocusScaleSliderText = GVAR.OptionsFrame.ConfigBrackets:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	TEMPLATE.Slider(GVAR.OptionsFrame.FocusScaleSlider, 85, 10, 100, 200, OPT.ButtonFocusScale[currentSize]*100, function(self, value)
		local nvalue = value/100;
		
		if(nvalue == BattlegroundTargets_Options.ButtonFocusScale[currentSize]) then return; end
		BattlegroundTargets_Options.ButtonFocusScale[currentSize] = nvalue;
		OPT.ButtonFocusScale[currentSize] = nvalue;
		GVAR.OptionsFrame.FocusScaleSliderText:SetText(value.."%");
		BattlegroundTargets:EnableConfigMode();
	end, "blank");
	GVAR.OptionsFrame.FocusScaleSlider:SetPoint("LEFT", GVAR.OptionsFrame.ShowFocusIndicator, "RIGHT", 10, 0);
	GVAR.OptionsFrame.FocusScaleSliderText:SetHeight(20);
	GVAR.OptionsFrame.FocusScaleSliderText:SetPoint("LEFT", GVAR.OptionsFrame.FocusScaleSlider, "RIGHT", 5, 0);
	GVAR.OptionsFrame.FocusScaleSliderText:SetJustifyH("LEFT");
	GVAR.OptionsFrame.FocusScaleSliderText:SetText((OPT.ButtonFocusScale[currentSize]*100).."%");
	GVAR.OptionsFrame.FocusScaleSliderText:SetTextColor(1, 1, 0.49, 1);
	
	GVAR.OptionsFrame.FocusPositionSlider = CreateFrame("Slider", nil, GVAR.OptionsFrame.ConfigBrackets);
	GVAR.OptionsFrame.FocusPositionSliderText = GVAR.OptionsFrame.ConfigBrackets:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	TEMPLATE.Slider(GVAR.OptionsFrame.FocusPositionSlider, 85, 5, 0, 100, OPT.ButtonFocusPosition[currentSize], function(self, value)
		if(value == BattlegroundTargets_Options.ButtonFocusPosition[currentSize]) then return; end
		BattlegroundTargets_Options.ButtonFocusPosition[currentSize] = value;
		OPT.ButtonFocusPosition[currentSize] = value;
		GVAR.OptionsFrame.FocusPositionSliderText:SetText(value);
		BattlegroundTargets:EnableConfigMode();
	end, "blank");
	GVAR.OptionsFrame.FocusPositionSlider:SetPoint("LEFT", GVAR.OptionsFrame.FocusScaleSlider, "RIGHT", 50, 0);
	GVAR.OptionsFrame.FocusPositionSliderText:SetHeight(20);
	GVAR.OptionsFrame.FocusPositionSliderText:SetPoint("LEFT", GVAR.OptionsFrame.FocusPositionSlider, "RIGHT", 5, 0);
	GVAR.OptionsFrame.FocusPositionSliderText:SetJustifyH("LEFT");
	GVAR.OptionsFrame.FocusPositionSliderText:SetText(OPT.ButtonFocusPosition[currentSize]);
	GVAR.OptionsFrame.FocusPositionSliderText:SetTextColor(1, 1, 0.49, 1);
	
	GVAR.OptionsFrame.ShowFlag = CreateFrame("CheckButton", nil, GVAR.OptionsFrame.ConfigBrackets);
	TEMPLATE.CheckButton(GVAR.OptionsFrame.ShowFlag, 16, 4, L["Show Flag Carrier"]);
	GVAR.OptionsFrame.ShowFlag:SetPoint("LEFT", GVAR.OptionsFrame, "LEFT", 10, 0);
	GVAR.OptionsFrame.ShowFlag:SetPoint("TOP", GVAR.OptionsFrame.ShowFocusIndicator, "BOTTOM", 0, -10);
	GVAR.OptionsFrame.ShowFlag:SetChecked(OPT.ButtonShowFlag[currentSize]);
	TEMPLATE.EnableCheckButton(GVAR.OptionsFrame.ShowFlag);
	GVAR.OptionsFrame.ShowFlag:SetScript("OnClick", function()
		BattlegroundTargets_Options.ButtonShowFlag[currentSize] = not BattlegroundTargets_Options.ButtonShowFlag[currentSize];
		OPT.ButtonShowFlag[currentSize] = not OPT.ButtonShowFlag[currentSize];
		
		if OPT.ButtonShowFlag[currentSize] then
			TEMPLATE.EnableSlider(GVAR.OptionsFrame.FlagScaleSlider);
			TEMPLATE.EnableSlider(GVAR.OptionsFrame.FlagPositionSlider);
		else
			TEMPLATE.DisableSlider(GVAR.OptionsFrame.FlagScaleSlider);
			TEMPLATE.DisableSlider(GVAR.OptionsFrame.FlagPositionSlider);
		end
		
		BattlegroundTargets:EnableConfigMode();
	end);
	
	local iw = GVAR.OptionsFrame.ShowFlag:GetWidth();
	if(iw > equalTextWidthIcons) then
		equalTextWidthIcons = iw;
	end
	
	GVAR.OptionsFrame.FlagScaleSlider = CreateFrame("Slider", nil, GVAR.OptionsFrame.ConfigBrackets);
	GVAR.OptionsFrame.FlagScaleSliderText = GVAR.OptionsFrame.ConfigBrackets:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	TEMPLATE.Slider(GVAR.OptionsFrame.FlagScaleSlider, 85, 10, 100, 200, OPT.ButtonFlagScale[currentSize]*100, function(self, value)
		local nvalue = value/100;
		if(nvalue == BattlegroundTargets_Options.ButtonFlagScale[currentSize]) then return; end
		BattlegroundTargets_Options.ButtonFlagScale[currentSize] = nvalue;
		OPT.ButtonFlagScale[currentSize] = nvalue;
		GVAR.OptionsFrame.FlagScaleSliderText:SetText(value.."%");
		BattlegroundTargets:EnableConfigMode();
	end, "blank");
	GVAR.OptionsFrame.FlagScaleSlider:SetPoint("LEFT", GVAR.OptionsFrame.ShowFlag, "RIGHT", 10, 0);
	GVAR.OptionsFrame.FlagScaleSliderText:SetHeight(20);
	GVAR.OptionsFrame.FlagScaleSliderText:SetPoint("LEFT", GVAR.OptionsFrame.FlagScaleSlider, "RIGHT", 5, 0);
	GVAR.OptionsFrame.FlagScaleSliderText:SetJustifyH("LEFT");
	GVAR.OptionsFrame.FlagScaleSliderText:SetText((OPT.ButtonFlagScale[currentSize]*100).."%");
	GVAR.OptionsFrame.FlagScaleSliderText:SetTextColor(1, 1, 0.49, 1);
	
	GVAR.OptionsFrame.FlagPositionSlider = CreateFrame("Slider", nil, GVAR.OptionsFrame.ConfigBrackets);
	GVAR.OptionsFrame.FlagPositionSliderText = GVAR.OptionsFrame.ConfigBrackets:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	TEMPLATE.Slider(GVAR.OptionsFrame.FlagPositionSlider, 85, 5, 0, 100, OPT.ButtonFlagPosition[currentSize], function(self, value)
		if(value == BattlegroundTargets_Options.ButtonFlagPosition[currentSize]) then return; end
		BattlegroundTargets_Options.ButtonFlagPosition[currentSize] = value;
		OPT.ButtonFlagPosition[currentSize] = value;
		GVAR.OptionsFrame.FlagPositionSliderText:SetText(value);
		BattlegroundTargets:EnableConfigMode();
	end, "blank");
	GVAR.OptionsFrame.FlagPositionSlider:SetPoint("LEFT", GVAR.OptionsFrame.FlagScaleSlider, "RIGHT", 50, 0);
	GVAR.OptionsFrame.FlagPositionSliderText:SetHeight(20);
	GVAR.OptionsFrame.FlagPositionSliderText:SetPoint("LEFT", GVAR.OptionsFrame.FlagPositionSlider, "RIGHT", 5, 0);
	GVAR.OptionsFrame.FlagPositionSliderText:SetJustifyH("LEFT");
	GVAR.OptionsFrame.FlagPositionSliderText:SetText(OPT.ButtonFlagPosition[currentSize]);
	GVAR.OptionsFrame.FlagPositionSliderText:SetTextColor(1, 1, 0.49, 1);
	
	GVAR.OptionsFrame.ShowAssist = CreateFrame("CheckButton", nil, GVAR.OptionsFrame.ConfigBrackets);
	TEMPLATE.CheckButton(GVAR.OptionsFrame.ShowAssist, 16, 4, L["Show Main Assist Target"]);
	GVAR.OptionsFrame.ShowAssist:SetPoint("LEFT", GVAR.OptionsFrame, "LEFT", 10, 0);
	GVAR.OptionsFrame.ShowAssist:SetPoint("TOP", GVAR.OptionsFrame.ShowFlag, "BOTTOM", 0, -10);
	GVAR.OptionsFrame.ShowAssist:SetChecked(OPT.ButtonShowAssist[currentSize]);
	TEMPLATE.EnableCheckButton(GVAR.OptionsFrame.ShowAssist);
	GVAR.OptionsFrame.ShowAssist:SetScript("OnClick", function()
		BattlegroundTargets_Options.ButtonShowAssist[currentSize] = not BattlegroundTargets_Options.ButtonShowAssist[currentSize];
		OPT.ButtonShowAssist[currentSize] = not OPT.ButtonShowAssist[currentSize];
		if(OPT.ButtonShowAssist[currentSize]) then
			TEMPLATE.EnableSlider(GVAR.OptionsFrame.AssistScaleSlider);
			TEMPLATE.EnableSlider(GVAR.OptionsFrame.AssistPositionSlider);
		else
			TEMPLATE.DisableSlider(GVAR.OptionsFrame.AssistScaleSlider);
			TEMPLATE.DisableSlider(GVAR.OptionsFrame.AssistPositionSlider);
		end
		
		BattlegroundTargets:EnableConfigMode();
	end);
	
	local iw = GVAR.OptionsFrame.ShowAssist:GetWidth();
	if(iw > equalTextWidthIcons) then
		equalTextWidthIcons = iw;
	end
	
	GVAR.OptionsFrame.AssistScaleSlider = CreateFrame("Slider", nil, GVAR.OptionsFrame.ConfigBrackets);
	GVAR.OptionsFrame.AssistScaleSliderText = GVAR.OptionsFrame.ConfigBrackets:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	TEMPLATE.Slider(GVAR.OptionsFrame.AssistScaleSlider, 85, 10, 100, 200, OPT.ButtonAssistScale[currentSize]*100, function(self, value)
		local nvalue = value/100;
		if(nvalue == BattlegroundTargets_Options.ButtonAssistScale[currentSize]) then return; end
		BattlegroundTargets_Options.ButtonAssistScale[currentSize] = nvalue;
		OPT.ButtonAssistScale[currentSize] = nvalue;
		GVAR.OptionsFrame.AssistScaleSliderText:SetText(value.."%");
		BattlegroundTargets:EnableConfigMode();
	end, "blank");
	GVAR.OptionsFrame.AssistScaleSlider:SetPoint("LEFT", GVAR.OptionsFrame.ShowAssist, "RIGHT", 10, 0);
	GVAR.OptionsFrame.AssistScaleSliderText:SetHeight(20);
	GVAR.OptionsFrame.AssistScaleSliderText:SetPoint("LEFT", GVAR.OptionsFrame.AssistScaleSlider, "RIGHT", 5, 0);
	GVAR.OptionsFrame.AssistScaleSliderText:SetJustifyH("LEFT");
	GVAR.OptionsFrame.AssistScaleSliderText:SetText((OPT.ButtonAssistScale[currentSize]*100).."%");
	GVAR.OptionsFrame.AssistScaleSliderText:SetTextColor(1, 1, 0.49, 1);
	
	GVAR.OptionsFrame.AssistPositionSlider = CreateFrame("Slider", nil, GVAR.OptionsFrame.ConfigBrackets);
	GVAR.OptionsFrame.AssistPositionSliderText = GVAR.OptionsFrame.ConfigBrackets:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	TEMPLATE.Slider(GVAR.OptionsFrame.AssistPositionSlider, 85, 5, 0, 100, OPT.ButtonAssistPosition[currentSize], function(self, value)
		if(value == BattlegroundTargets_Options.ButtonAssistPosition[currentSize]) then return; end
		BattlegroundTargets_Options.ButtonAssistPosition[currentSize] = value;
		OPT.ButtonAssistPosition[currentSize] = value;
		GVAR.OptionsFrame.AssistPositionSliderText:SetText(value);
		BattlegroundTargets:EnableConfigMode();
	end, "blank");
	GVAR.OptionsFrame.AssistPositionSlider:SetPoint("LEFT", GVAR.OptionsFrame.AssistScaleSlider, "RIGHT", 50, 0);
	GVAR.OptionsFrame.AssistPositionSliderText:SetHeight(20);
	GVAR.OptionsFrame.AssistPositionSliderText:SetPoint("LEFT", GVAR.OptionsFrame.AssistPositionSlider, "RIGHT", 5, 0);
	GVAR.OptionsFrame.AssistPositionSliderText:SetJustifyH("LEFT");
	GVAR.OptionsFrame.AssistPositionSliderText:SetText(OPT.ButtonAssistPosition[currentSize]);
	GVAR.OptionsFrame.AssistPositionSliderText:SetTextColor(1, 1, 0.49, 1);

	GVAR.OptionsFrame.TargetScaleSlider:SetPoint("LEFT", GVAR.OptionsFrame.ShowTargetIndicator, "LEFT", equalTextWidthIcons + 10, 0);
	GVAR.OptionsFrame.FocusScaleSlider:SetPoint("LEFT", GVAR.OptionsFrame.ShowFocusIndicator, "LEFT", equalTextWidthIcons + 10, 0);
	GVAR.OptionsFrame.FlagScaleSlider:SetPoint("LEFT", GVAR.OptionsFrame.ShowFlag, "LEFT", equalTextWidthIcons + 10, 0);
	GVAR.OptionsFrame.AssistScaleSlider:SetPoint("LEFT", GVAR.OptionsFrame.ShowAssist, "LEFT", equalTextWidthIcons + 10, 0);
	local iconW = 10 + equalTextWidthIcons + 10 + GVAR.OptionsFrame.TargetScaleSlider:GetWidth() + 50 + GVAR.OptionsFrame.TargetPositionSlider:GetWidth() + 50;
	
	GVAR.OptionsFrame.ShowHealthBar = CreateFrame("CheckButton", nil, GVAR.OptionsFrame.ConfigBrackets);
	TEMPLATE.CheckButton(GVAR.OptionsFrame.ShowHealthBar, 16, 4, L["Show Health Bar"]);
	GVAR.OptionsFrame.ShowHealthBar:SetPoint("LEFT", GVAR.OptionsFrame, "LEFT", 10, 0);
	GVAR.OptionsFrame.ShowHealthBar:SetPoint("TOP", GVAR.OptionsFrame.ShowAssist, "BOTTOM", 0, -10);
	GVAR.OptionsFrame.ShowHealthBar:SetChecked(OPT.ButtonShowHealthBar[currentSize]);
	GVAR.OptionsFrame.ShowHealthBar:SetScript("OnClick", function()
		BattlegroundTargets_Options.ButtonShowHealthBar[currentSize] = not BattlegroundTargets_Options.ButtonShowHealthBar[currentSize];
		OPT.ButtonShowHealthBar[currentSize] = not OPT.ButtonShowHealthBar[currentSize];
		GVAR.OptionsFrame.ShowHealthBar:SetChecked(OPT.ButtonShowHealthBar[currentSize]);
		BattlegroundTargets:EnableConfigMode();
	end);
	
	GVAR.OptionsFrame.ShowHealthText = CreateFrame("CheckButton", nil, GVAR.OptionsFrame.ConfigBrackets);
	TEMPLATE.CheckButton(GVAR.OptionsFrame.ShowHealthText, 16, 4, L["Show Percent"]);
	GVAR.OptionsFrame.ShowHealthText:SetPoint("LEFT", GVAR.OptionsFrame.ShowHealthBar.Text, "RIGHT", 20, 0);
	GVAR.OptionsFrame.ShowHealthText:SetChecked(OPT.ButtonShowHealthText[currentSize]);
	GVAR.OptionsFrame.ShowHealthText:SetScript("OnClick", function()
		BattlegroundTargets_Options.ButtonShowHealthText[currentSize] = not BattlegroundTargets_Options.ButtonShowHealthText[currentSize];
		OPT.ButtonShowHealthText[currentSize] = not OPT.ButtonShowHealthText[currentSize];
		GVAR.OptionsFrame.ShowHealthText:SetChecked(OPT.ButtonShowHealthText[currentSize]);
		BattlegroundTargets:EnableConfigMode();
	end);
	
	local rangeW = 0;
	local minRange, maxRange;
	
	if(ranges[playerClassEN]) then
		local _, _, _, _, _, _, _, minR, maxR = GetSpellInfo(ranges[playerClassEN]);
		
		minRange = minR;
		maxRange = maxR;
	end
	
	minRange = minRange or "?";
	maxRange = maxRange or "?";
	rangeTypeName[2] = "2) "..CLASS.." |cffffff79("..minRange.."-"..maxRange..")|r";
	rangeTypeName[3] = "3) "..L["Mix"].." 1 |cffffff79("..minRange.."-"..maxRange..") + (0-45)|r";
	rangeTypeName[4] = "4) "..L["Mix"].." 2 |cffffff79("..minRange.."-"..maxRange..") + ("..minRange.."-"..maxRange..")|r";
	
	local buttonName = rangeTypeName[1];
	if(OPT.ButtonTypeRangeCheck[currentSize] == 2) then
		buttonName = rangeTypeName[2];
	elseif(OPT.ButtonTypeRangeCheck[currentSize] == 3) then
		buttonName = rangeTypeName[3];
	elseif(OPT.ButtonTypeRangeCheck[currentSize] == 4) then
		buttonName = rangeTypeName[4];
	end
	
	local rangeInfoTxt = ""
	rangeInfoTxt = rangeInfoTxt..rangeTypeName[1]..":\n";
	rangeInfoTxt = rangeInfoTxt.."   |cffffffff"..L["This option uses the CombatLog to check range."].."|r\n\n\n";
	rangeInfoTxt = rangeInfoTxt..rangeTypeName[2]..":\n"
	rangeInfoTxt = rangeInfoTxt.."   |cffffffff"..L["This option uses a pre-defined spell to check range:"].."|r\n";
	
	table_sort(class_IntegerSort, function(a, b) if(a.loc < b.loc) then return true; end end);
	
	local playerMClass = "?";
	for i = 1, #class_IntegerSort do
		local classEN = class_IntegerSort[i].cid;
		local name, _, _, _, _, _, _, minRange, maxRange = GetSpellInfo(ranges[classEN])
		local classStr = "|cff"..ClassHexColor(classEN)..class_IntegerSort[i].loc.."|r   "..(minRange or "?").."-"..(maxRange or "?").."   |cffffffff"..(name or UNKNOWN).."|r   |cffbbbbbb(spell ID = "..ranges[classEN]..")|r";
		
		if classEN == playerClassEN then
			playerMClass = "|cff"..ClassHexColor(classEN)..class_IntegerSort[i].loc.."|r";
			rangeInfoTxt = rangeInfoTxt..">>> "..classStr.." <<<";
		else
			rangeInfoTxt = rangeInfoTxt.."     "..classStr;
		end
		
		rangeInfoTxt = rangeInfoTxt.."\n";
	end
	
	rangeInfoTxt = rangeInfoTxt.."\n\n"..rangeTypeName[3]..":\n";
	rangeInfoTxt = rangeInfoTxt.."   |cffffffff"..CLASS..":|r |cffffff79("..minRange.."-"..maxRange..")|r "..playerMClass.."\n";
	rangeInfoTxt = rangeInfoTxt.."   |cffffffffCombatLog:|r |cffffff79(0-45)|r\n";
	rangeInfoTxt = rangeInfoTxt.."   |cffaaaaaa(CombatLog: "..L["if you are attacked only"]..")|r\n";
	rangeInfoTxt = rangeInfoTxt.."\n\n"..rangeTypeName[4]..":\n";
	rangeInfoTxt = rangeInfoTxt.."   |cffffffff"..CLASS..":|r |cffffff79("..minRange.."-"..maxRange..")|r "..playerMClass.."\n";
	rangeInfoTxt = rangeInfoTxt.."   |cffffffffCombatLog|r |cffaaaaaa"..L["(class dependent)"]..":|r |cffffff79("..minRange.."-"..maxRange..")|r "..playerMClass.."\n";
	rangeInfoTxt = rangeInfoTxt.."   |cffaaaaaa(CombatLog: "..L["if you are attacked only"]..")|r\n";
	rangeInfoTxt = rangeInfoTxt.."\n\n\n";
	rangeInfoTxt = rangeInfoTxt.."|TInterface\\DialogFrame\\UI-Dialog-Icon-AlertNew:24|t";
	rangeInfoTxt = rangeInfoTxt.."|cffffffff "..L["Disable this option if you have CPU/FPS problems in combat."].." |r";
	rangeInfoTxt = rangeInfoTxt.."|TInterface\\DialogFrame\\UI-Dialog-Icon-AlertNew:24|t";
	
	GVAR.OptionsFrame.RangeCheck = CreateFrame("CheckButton", nil, GVAR.OptionsFrame.ConfigBrackets);
	TEMPLATE.CheckButton(GVAR.OptionsFrame.RangeCheck, 16, 4, L["Show Range"]);
	GVAR.OptionsFrame.RangeCheck:SetPoint("LEFT", GVAR.OptionsFrame, "LEFT", 10, 0);
	GVAR.OptionsFrame.RangeCheck:SetPoint("TOP", GVAR.OptionsFrame.ShowHealthBar, "BOTTOM", 0, -10);
	GVAR.OptionsFrame.RangeCheck:SetChecked(OPT.ButtonRangeCheck[currentSize]);
	GVAR.OptionsFrame.RangeCheck:SetScript("OnClick", function()
		BattlegroundTargets_Options.ButtonRangeCheck[currentSize] = not BattlegroundTargets_Options.ButtonRangeCheck[currentSize];
		OPT.ButtonRangeCheck[currentSize] = not OPT.ButtonRangeCheck[currentSize];
		GVAR.OptionsFrame.RangeCheck:SetChecked(OPT.ButtonRangeCheck[currentSize]);
		
		if(OPT.ButtonRangeCheck[currentSize]) then
			TEMPLATE.EnablePullDownMenu(GVAR.OptionsFrame.RangeCheckTypePullDown);
			GVAR.OptionsFrame.RangeCheckInfo:Enable() Desaturation(GVAR.OptionsFrame.RangeCheckInfo.Texture, false);
			TEMPLATE.EnablePullDownMenu(GVAR.OptionsFrame.RangeDisplayPullDown);
		else
			TEMPLATE.DisablePullDownMenu(GVAR.OptionsFrame.RangeCheckTypePullDown);
			GVAR.OptionsFrame.RangeCheckInfo:Disable() Desaturation(GVAR.OptionsFrame.RangeCheckInfo.Texture, true);
			TEMPLATE.DisablePullDownMenu(GVAR.OptionsFrame.RangeDisplayPullDown);
		end
		
		BattlegroundTargets:EnableConfigMode();
	end);
	
	rangeW = rangeW + 10 + GVAR.OptionsFrame.RangeCheck:GetWidth();
	
	GVAR.OptionsFrame.RangeCheckInfo = CreateFrame("Button", nil, GVAR.OptionsFrame.ConfigBrackets);
	GVAR.OptionsFrame.RangeCheckInfo:SetWidth(16);
	GVAR.OptionsFrame.RangeCheckInfo:SetHeight(16);
	GVAR.OptionsFrame.RangeCheckInfo:SetPoint("LEFT", GVAR.OptionsFrame.RangeCheck, "RIGHT", 10, 0);
	GVAR.OptionsFrame.RangeCheckInfo.Texture = GVAR.OptionsFrame.RangeCheckInfo:CreateTexture(nil, "ARTWORK");
	GVAR.OptionsFrame.RangeCheckInfo.Texture:SetWidth(16);
	GVAR.OptionsFrame.RangeCheckInfo.Texture:SetHeight(16);
	GVAR.OptionsFrame.RangeCheckInfo.Texture:SetPoint("LEFT", 0, 0)
	GVAR.OptionsFrame.RangeCheckInfo.Texture:SetTexture("Interface\\FriendsFrame\\InformationIcon");
	GVAR.OptionsFrame.RangeCheckInfo.TextFrame = CreateFrame("Frame", nil, GVAR.OptionsFrame.ConfigBrackets);
	TEMPLATE.BorderTRBL(GVAR.OptionsFrame.RangeCheckInfo.TextFrame);
	GVAR.OptionsFrame.RangeCheckInfo.TextFrame:SetToplevel(true);
	GVAR.OptionsFrame.RangeCheckInfo.TextFrame:SetPoint("BOTTOM", GVAR.OptionsFrame.RangeCheckInfo.Texture, "TOP", 0, 0);
	GVAR.OptionsFrame.RangeCheckInfo.TextFrame:Hide();
	GVAR.OptionsFrame.RangeCheckInfo.Text = GVAR.OptionsFrame.RangeCheckInfo.TextFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	GVAR.OptionsFrame.RangeCheckInfo.Text:SetPoint("CENTER", 0, 0);
	GVAR.OptionsFrame.RangeCheckInfo.Text:SetJustifyH("LEFT");
	GVAR.OptionsFrame.RangeCheckInfo.Text:SetText(rangeInfoTxt);
	GVAR.OptionsFrame.RangeCheckInfo.Text:SetTextColor(1, 1, 0.49, 1);
	GVAR.OptionsFrame.RangeCheckInfo:SetScript("OnEnter", function() GVAR.OptionsFrame.RangeCheckInfo.TextFrame:Show(); end);
	GVAR.OptionsFrame.RangeCheckInfo:SetScript("OnLeave", function() GVAR.OptionsFrame.RangeCheckInfo.TextFrame:Hide(); end);
	
	rangeW = rangeW + 10 + 16;
	
	local txtWidth = GVAR.OptionsFrame.RangeCheckInfo.Text:GetStringWidth();
	local txtHeight = GVAR.OptionsFrame.RangeCheckInfo.Text:GetStringHeight();
	GVAR.OptionsFrame.RangeCheckInfo.TextFrame:SetWidth(txtWidth + 30);
	GVAR.OptionsFrame.RangeCheckInfo.TextFrame:SetHeight(txtHeight + 30);
	GVAR.OptionsFrame.RangeCheckInfo.Text:SetWidth(txtWidth + 10);
	GVAR.OptionsFrame.RangeCheckInfo.Text:SetHeight(txtHeight + 10);
	
	GVAR.OptionsFrame.RangeCheckTypePullDown = CreateFrame("Button", nil, GVAR.OptionsFrame.ConfigBrackets);
	TEMPLATE.PullDownMenu(GVAR.OptionsFrame.RangeCheckTypePullDown, "RangeType", buttonName, 0, 4, RangeCheckTypePullDownFunc);
	GVAR.OptionsFrame.RangeCheckTypePullDown:SetPoint("LEFT", GVAR.OptionsFrame.RangeCheckInfo, "RIGHT", 10, 0);
	GVAR.OptionsFrame.RangeCheckTypePullDown:SetHeight(18);
	TEMPLATE.EnablePullDownMenu(GVAR.OptionsFrame.RangeCheckTypePullDown);
	
	rangeW = rangeW + 10 + GVAR.OptionsFrame.RangeCheckTypePullDown:GetWidth();
	
	GVAR.OptionsFrame.RangeDisplayPullDown = CreateFrame("Button", nil, GVAR.OptionsFrame.ConfigBrackets)
	TEMPLATE.PullDownMenu(GVAR.OptionsFrame.RangeDisplayPullDown, "RangeDisplay", rangeDisplay[ BattlegroundTargets_Options.ButtonRangeDisplay[currentSize] ], 0, #rangeDisplay, RangeDisplayPullDownFunc)
	GVAR.OptionsFrame.RangeDisplayPullDown:SetPoint("LEFT", GVAR.OptionsFrame.RangeCheckTypePullDown, "RIGHT", 10, 0);
	GVAR.OptionsFrame.RangeDisplayPullDown:SetHeight(18);
	TEMPLATE.EnablePullDownMenu(GVAR.OptionsFrame.RangeDisplayPullDown);
	
	rangeW = rangeW + 10 + GVAR.OptionsFrame.RangeDisplayPullDown:GetWidth() + 10;
	
	local sortW = 0;
	
	GVAR.OptionsFrame.SortByTitle = GVAR.OptionsFrame.ConfigBrackets:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	GVAR.OptionsFrame.SortByTitle:SetHeight(16);
	GVAR.OptionsFrame.SortByTitle:SetPoint("LEFT", GVAR.OptionsFrame, "LEFT", 10, 0);
	GVAR.OptionsFrame.SortByTitle:SetPoint("TOP", GVAR.OptionsFrame.RangeCheck, "BOTTOM", 0, -10);
	GVAR.OptionsFrame.SortByTitle:SetJustifyH("LEFT");
	GVAR.OptionsFrame.SortByTitle:SetText(L["Sort By"]..":");
	GVAR.OptionsFrame.SortByTitle:SetTextColor(1, 1, 1, 1);
	
	sortW = sortW + 10 + GVAR.OptionsFrame.SortByTitle:GetStringWidth();

	GVAR.OptionsFrame.SortByPullDown = CreateFrame("Button", nil, GVAR.OptionsFrame.ConfigBrackets);
	TEMPLATE.PullDownMenu(GVAR.OptionsFrame.SortByPullDown, "SortBy", sortBy[ OPT.ButtonSortBy[currentSize] ], 0, #sortBy, SortByPullDownFunc);
	GVAR.OptionsFrame.SortByPullDown:SetPoint("LEFT", GVAR.OptionsFrame.SortByTitle, "RIGHT", 10, 0);
	GVAR.OptionsFrame.SortByPullDown:SetHeight(18);
	TEMPLATE.EnablePullDownMenu(GVAR.OptionsFrame.SortByPullDown);
	
	sortW = sortW + 10 + GVAR.OptionsFrame.SortByPullDown:GetWidth();
	
	GVAR.OptionsFrame.SortDetailPullDown = CreateFrame("Button", nil, GVAR.OptionsFrame.ConfigBrackets)
	TEMPLATE.PullDownMenu(GVAR.OptionsFrame.SortDetailPullDown, "SortDetail", sortBy[ OPT.ButtonSortDetail[currentSize] ], 0, #sortDetail, SortDetailPullDownFunc);
	GVAR.OptionsFrame.SortDetailPullDown:SetPoint("LEFT", GVAR.OptionsFrame.SortByPullDown, "RIGHT", 10, 0);
	GVAR.OptionsFrame.SortDetailPullDown:SetHeight(18);
	TEMPLATE.EnablePullDownMenu(GVAR.OptionsFrame.SortDetailPullDown);
	
	sortW = sortW + 10 + GVAR.OptionsFrame.SortDetailPullDown:GetWidth();
	
	local infoTxt1 = sortDetail[1]..":\n";
	table_sort(class_IntegerSort, function(a, b) if(a.loc < b.loc) then return true; end end);
	for i = 1, #class_IntegerSort do
		infoTxt1 = infoTxt1.." |cff"..ClassHexColor(class_IntegerSort[i].cid)..class_IntegerSort[i].loc.."|r";
		if(i <= #class_IntegerSort) then
			infoTxt1 = infoTxt1.."\n";
		end
	end
	
	local infoTxt2 = sortDetail[2]..":\n";
	table_sort(class_IntegerSort, function(a, b) if(a.eng < b.eng) then return true; end end);
	for i = 1, #class_IntegerSort do
		infoTxt2 = infoTxt2.." |cff"..ClassHexColor(class_IntegerSort[i].cid)..class_IntegerSort[i].eng.." ("..class_IntegerSort[i].loc..")|r";
		if(i <= #class_IntegerSort) then
			infoTxt2 = infoTxt2.."\n";
		end
	end
	
	local infoTxt3 = sortDetail[3]..":\n";
	table_sort(class_IntegerSort, function(a, b) if(a.blizz < b.blizz) then return true; end end);
	for i = 1, #class_IntegerSort do
		infoTxt3 = infoTxt3.." |cff"..ClassHexColor(class_IntegerSort[i].cid)..class_IntegerSort[i].loc.."|r";
		if(i <= #class_IntegerSort) then
			infoTxt3 = infoTxt3.."\n";
		end
	end
	
	GVAR.OptionsFrame.SortInfo = CreateFrame("Button", nil, GVAR.OptionsFrame.ConfigBrackets);
	GVAR.OptionsFrame.SortInfo:SetWidth(16);
	GVAR.OptionsFrame.SortInfo:SetHeight(16);
	GVAR.OptionsFrame.SortInfo:SetPoint("LEFT", GVAR.OptionsFrame.SortDetailPullDown, "RIGHT", 10, 0);
	GVAR.OptionsFrame.SortInfo.Texture = GVAR.OptionsFrame.SortInfo:CreateTexture(nil, "ARTWORK");
	GVAR.OptionsFrame.SortInfo.Texture:SetWidth(16);
	GVAR.OptionsFrame.SortInfo.Texture:SetHeight(16);
	GVAR.OptionsFrame.SortInfo.Texture:SetPoint("LEFT", 0, 0);
	GVAR.OptionsFrame.SortInfo.Texture:SetTexture("Interface\\FriendsFrame\\InformationIcon");
	GVAR.OptionsFrame.SortInfo.TextFrame = CreateFrame("Frame", nil, GVAR.OptionsFrame.SortInfo);
	TEMPLATE.BorderTRBL(GVAR.OptionsFrame.SortInfo.TextFrame);
	GVAR.OptionsFrame.SortInfo.TextFrame:SetToplevel(true);
	GVAR.OptionsFrame.SortInfo.TextFrame:SetPoint("BOTTOM", GVAR.OptionsFrame.SortInfo.Texture, "TOP", 0, 0);
	GVAR.OptionsFrame.SortInfo.TextFrame:Hide();
	GVAR.OptionsFrame.SortInfo.Text1 = GVAR.OptionsFrame.SortInfo.TextFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	GVAR.OptionsFrame.SortInfo.Text1:SetPoint("TOPLEFT", GVAR.OptionsFrame.SortInfo.TextFrame, "TOPLEFT", 10, -10);
	GVAR.OptionsFrame.SortInfo.Text1:SetJustifyH("LEFT");
	GVAR.OptionsFrame.SortInfo.Text1:SetText(infoTxt1);
	GVAR.OptionsFrame.SortInfo.Text1:SetTextColor(1, 1, 0.49, 1);
	GVAR.OptionsFrame.SortInfo.Text2 = GVAR.OptionsFrame.SortInfo.TextFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	GVAR.OptionsFrame.SortInfo.Text2:SetPoint("LEFT", GVAR.OptionsFrame.SortInfo.Text1, "RIGHT", 0, 0);
	GVAR.OptionsFrame.SortInfo.Text2:SetJustifyH("LEFT");
	GVAR.OptionsFrame.SortInfo.Text2:SetText(infoTxt2);
	GVAR.OptionsFrame.SortInfo.Text2:SetTextColor(1, 1, 0.49, 1);
	GVAR.OptionsFrame.SortInfo.Text3 = GVAR.OptionsFrame.SortInfo.TextFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	GVAR.OptionsFrame.SortInfo.Text3:SetPoint("LEFT", GVAR.OptionsFrame.SortInfo.Text2, "RIGHT", 0, 0);
	GVAR.OptionsFrame.SortInfo.Text3:SetJustifyH("LEFT");
	GVAR.OptionsFrame.SortInfo.Text3:SetText(infoTxt3);
	GVAR.OptionsFrame.SortInfo.Text3:SetTextColor(1, 1, 0.49, 1);
	GVAR.OptionsFrame.SortInfo:SetScript("OnEnter", function() GVAR.OptionsFrame.SortInfo.TextFrame:Show(); end);
	GVAR.OptionsFrame.SortInfo:SetScript("OnLeave", function() GVAR.OptionsFrame.SortInfo.TextFrame:Hide(); end);
	
	local txtWidth1 = GVAR.OptionsFrame.SortInfo.Text1:GetStringWidth();
	local txtWidth2 = GVAR.OptionsFrame.SortInfo.Text2:GetStringWidth();
	local txtWidth3 = GVAR.OptionsFrame.SortInfo.Text3:GetStringWidth();
	
	GVAR.OptionsFrame.SortInfo.Text1:SetWidth(txtWidth1 + 10);
	GVAR.OptionsFrame.SortInfo.Text2:SetWidth(txtWidth2 + 10);
	GVAR.OptionsFrame.SortInfo.Text3:SetWidth(txtWidth3 + 10);
	GVAR.OptionsFrame.SortInfo.TextFrame:SetWidth(10 + txtWidth1 + 10 + txtWidth2 + 10 + txtWidth3 + 10 + 10);
	
	local txtHeight = GVAR.OptionsFrame.SortInfo.Text1:GetStringHeight();
	
	GVAR.OptionsFrame.SortInfo.Text1:SetHeight(txtHeight + 10);
	GVAR.OptionsFrame.SortInfo.Text2:SetHeight(txtHeight + 10);
	GVAR.OptionsFrame.SortInfo.Text3:SetHeight(txtHeight + 10);
	GVAR.OptionsFrame.SortInfo.TextFrame:SetHeight(10 + txtHeight + 10 + 10);
	
	sortW = sortW + 10 + 16 +10;
	
	local equalTextWidthSliders = 0;
	
	GVAR.OptionsFrame.FontTitle = GVAR.OptionsFrame.ConfigBrackets:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	GVAR.OptionsFrame.FontSlider = CreateFrame("Slider", nil, GVAR.OptionsFrame.ConfigBrackets);
	GVAR.OptionsFrame.FontValue = GVAR.OptionsFrame.ConfigBrackets:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	GVAR.OptionsFrame.FontTitle:SetHeight(16);
	GVAR.OptionsFrame.FontTitle:SetPoint("LEFT", GVAR.OptionsFrame, "LEFT", 10, 0);
	GVAR.OptionsFrame.FontTitle:SetPoint("TOP", GVAR.OptionsFrame.SortByTitle, "BOTTOM", 0, -10);
	GVAR.OptionsFrame.FontTitle:SetJustifyH("LEFT");
	GVAR.OptionsFrame.FontTitle:SetText(L["Text Size"]..":");
	GVAR.OptionsFrame.FontTitle:SetTextColor(1, 1, 1, 1);
	TEMPLATE.Slider(GVAR.OptionsFrame.FontSlider, 150, 1, 5, 20, OPT.ButtonFontSize[currentSize], function(self, value)
		if(value == BattlegroundTargets_Options.ButtonFontSize[currentSize]) then return; end
		BattlegroundTargets_Options.ButtonFontSize[currentSize] = value;
		OPT.ButtonFontSize[currentSize] = value;
		GVAR.OptionsFrame.FontValue:SetText(value);
		BattlegroundTargets:EnableConfigMode();
	end, "blank");
	GVAR.OptionsFrame.FontSlider:SetPoint("LEFT", GVAR.OptionsFrame.FontTitle, "RIGHT", 20, 0);
	GVAR.OptionsFrame.FontValue:SetHeight(20);
	GVAR.OptionsFrame.FontValue:SetPoint("LEFT", GVAR.OptionsFrame.FontSlider, "RIGHT", 5, 0);
	GVAR.OptionsFrame.FontValue:SetJustifyH("LEFT");
	GVAR.OptionsFrame.FontValue:SetText(OPT.ButtonFontSize[currentSize]);
	GVAR.OptionsFrame.FontValue:SetTextColor(1, 1, 0.49, 1);
	
	local sw = GVAR.OptionsFrame.FontTitle:GetStringWidth();
	if(sw > equalTextWidthSliders) then
		equalTextWidthSliders = sw;
	end
	
	GVAR.OptionsFrame.ScaleTitle = GVAR.OptionsFrame.ConfigBrackets:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	GVAR.OptionsFrame.ScaleSlider = CreateFrame("Slider", nil, GVAR.OptionsFrame.ConfigBrackets);
	GVAR.OptionsFrame.ScaleValue = GVAR.OptionsFrame.ConfigBrackets:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	GVAR.OptionsFrame.ScaleTitle:SetHeight(16);
	GVAR.OptionsFrame.ScaleTitle:SetPoint("LEFT", GVAR.OptionsFrame, "LEFT", 10, 0);
	GVAR.OptionsFrame.ScaleTitle:SetPoint("TOP", GVAR.OptionsFrame.FontSlider, "BOTTOM", 0, -10);
	GVAR.OptionsFrame.ScaleTitle:SetJustifyH("LEFT");
	GVAR.OptionsFrame.ScaleTitle:SetText(L["Scale"]..":");
	GVAR.OptionsFrame.ScaleTitle:SetTextColor(1, 1, 1, 1);
	TEMPLATE.Slider(GVAR.OptionsFrame.ScaleSlider, 180, 5, 50, 200, OPT.ButtonScale[currentSize]*100, function(self, value)
		local nvalue = value/100;
		
		if(nvalue == BattlegroundTargets_Options.ButtonScale[currentSize]) then return; end
		
		BattlegroundTargets_Options.ButtonScale[currentSize] = nvalue;
		OPT.ButtonScale[currentSize] = nvalue;
		GVAR.OptionsFrame.ScaleValue:SetText(value.."%");
		
		if(inCombat or InCombatLockdown()) then return; end
		
		for i = 1, currentSize do
			GVAR.TargetButton[i]:SetScale(nvalue);
		end
	end, "blank");
	GVAR.OptionsFrame.ScaleSlider:SetPoint("LEFT", GVAR.OptionsFrame.ScaleTitle, "RIGHT", 20, 0);
	GVAR.OptionsFrame.ScaleValue:SetHeight(20);
	GVAR.OptionsFrame.ScaleValue:SetPoint("LEFT", GVAR.OptionsFrame.ScaleSlider, "RIGHT", 5, 0);
	GVAR.OptionsFrame.ScaleValue:SetJustifyH("LEFT");
	GVAR.OptionsFrame.ScaleValue:SetText((OPT.ButtonScale[currentSize]*100).."%");
	GVAR.OptionsFrame.ScaleValue:SetTextColor(1, 1, 0.49, 1);
	
	local sw = GVAR.OptionsFrame.ScaleTitle:GetStringWidth();
	if(sw > equalTextWidthSliders) then
		equalTextWidthSliders = sw;
	end
	
	GVAR.OptionsFrame.WidthTitle = GVAR.OptionsFrame.ConfigBrackets:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	GVAR.OptionsFrame.WidthSlider = CreateFrame("Slider", nil, GVAR.OptionsFrame.ConfigBrackets);
	GVAR.OptionsFrame.WidthValue = GVAR.OptionsFrame.ConfigBrackets:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	GVAR.OptionsFrame.WidthTitle:SetHeight(16);
	GVAR.OptionsFrame.WidthTitle:SetPoint("LEFT", GVAR.OptionsFrame, "LEFT", 10, 0);
	GVAR.OptionsFrame.WidthTitle:SetPoint("TOP", GVAR.OptionsFrame.ScaleSlider, "BOTTOM", 0, -10);
	GVAR.OptionsFrame.WidthTitle:SetJustifyH("LEFT");
	GVAR.OptionsFrame.WidthTitle:SetText(L["Width"]..":");
	GVAR.OptionsFrame.WidthTitle:SetTextColor(1, 1, 1, 1);
	TEMPLATE.Slider(GVAR.OptionsFrame.WidthSlider, 180, 5, 50, 300, OPT.ButtonWidth[currentSize], function(self, value)
		if(value == BattlegroundTargets_Options.ButtonWidth[currentSize]) then return; end
		BattlegroundTargets_Options.ButtonWidth[currentSize] = value;
		OPT.ButtonWidth[currentSize] = value;
		GVAR.OptionsFrame.WidthValue:SetText(value);
		BattlegroundTargets:EnableConfigMode();
	end, "blank");
	GVAR.OptionsFrame.WidthSlider:SetPoint("LEFT", GVAR.OptionsFrame.WidthTitle, "RIGHT", 20, 0);
	GVAR.OptionsFrame.WidthValue:SetHeight(20);
	GVAR.OptionsFrame.WidthValue:SetPoint("LEFT", GVAR.OptionsFrame.WidthSlider, "RIGHT", 5, 0);
	GVAR.OptionsFrame.WidthValue:SetJustifyH("LEFT");
	GVAR.OptionsFrame.WidthValue:SetText(OPT.ButtonWidth[currentSize]);
	GVAR.OptionsFrame.WidthValue:SetTextColor(1, 1, 0.49, 1);
	
	local sw = GVAR.OptionsFrame.WidthTitle:GetStringWidth();
	if(sw > equalTextWidthSliders) then
		equalTextWidthSliders = sw;
	end
	
	GVAR.OptionsFrame.HeightTitle = GVAR.OptionsFrame.ConfigBrackets:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	GVAR.OptionsFrame.HeightSlider = CreateFrame("Slider", nil, GVAR.OptionsFrame.ConfigBrackets);
	GVAR.OptionsFrame.HeightValue = GVAR.OptionsFrame.ConfigBrackets:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	GVAR.OptionsFrame.HeightTitle:SetHeight(16);
	GVAR.OptionsFrame.HeightTitle:SetPoint("LEFT", GVAR.OptionsFrame, "LEFT", 10, 0);
	GVAR.OptionsFrame.HeightTitle:SetPoint("TOP", GVAR.OptionsFrame.WidthTitle, "BOTTOM", 0, -10);
	GVAR.OptionsFrame.HeightTitle:SetJustifyH("LEFT");
	GVAR.OptionsFrame.HeightTitle:SetText(L["Height"]..":");
	GVAR.OptionsFrame.HeightTitle:SetTextColor(1, 1, 1, 1);
	TEMPLATE.Slider(GVAR.OptionsFrame.HeightSlider, 180, 1, 10, 30, OPT.ButtonHeight[currentSize], function(self, value)
		if(value == BattlegroundTargets_Options.ButtonHeight[currentSize]) then return; end
		BattlegroundTargets_Options.ButtonHeight[currentSize] = value;
		OPT.ButtonHeight[currentSize] = value;
		GVAR.OptionsFrame.HeightValue:SetText(value);
		BattlegroundTargets:EnableConfigMode();
	end, "blank");
	GVAR.OptionsFrame.HeightSlider:SetPoint("LEFT", GVAR.OptionsFrame.HeightTitle, "RIGHT", 20, 0);
	GVAR.OptionsFrame.HeightValue:SetHeight(20);
	GVAR.OptionsFrame.HeightValue:SetPoint("LEFT", GVAR.OptionsFrame.HeightSlider, "RIGHT", 5, 0);
	GVAR.OptionsFrame.HeightValue:SetJustifyH("LEFT");
	GVAR.OptionsFrame.HeightValue:SetText(OPT.ButtonHeight[currentSize]);
	GVAR.OptionsFrame.HeightValue:SetTextColor(1, 1, 0.49, 1);
	
	local sw = GVAR.OptionsFrame.HeightTitle:GetStringWidth();
	if(sw > equalTextWidthSliders) then
		equalTextWidthSliders = sw;
	end
	
	GVAR.OptionsFrame.FontSlider:SetPoint("LEFT", GVAR.OptionsFrame.FontTitle, "LEFT", equalTextWidthSliders + 10, 0);
	GVAR.OptionsFrame.ScaleSlider:SetPoint("LEFT", GVAR.OptionsFrame.ScaleTitle, "LEFT", equalTextWidthSliders + 10, 0);
	GVAR.OptionsFrame.WidthSlider:SetPoint("LEFT", GVAR.OptionsFrame.WidthTitle, "LEFT", equalTextWidthSliders + 10, 0);
	GVAR.OptionsFrame.HeightSlider:SetPoint("LEFT", GVAR.OptionsFrame.HeightTitle, "LEFT", equalTextWidthSliders + 10, 0);
	
	GVAR.OptionsFrame.TestShuffler = CreateFrame("Button", nil, GVAR.OptionsFrame.ConfigBrackets);
	BattlegroundTargets.shuffleStyle = true;
	GVAR.OptionsFrame.TestShuffler:SetPoint("BOTTOM", GVAR.OptionsFrame.HeightSlider, "BOTTOM", 0, 0);
	GVAR.OptionsFrame.TestShuffler:SetPoint("RIGHT", GVAR.OptionsFrame, "RIGHT", -10, 0);
	GVAR.OptionsFrame.TestShuffler:SetWidth(32);
	GVAR.OptionsFrame.TestShuffler:SetHeight(32);
	GVAR.OptionsFrame.TestShuffler:Hide();
	GVAR.OptionsFrame.TestShuffler:SetScript("OnClick", function() BattlegroundTargets:ShufflerFunc("OnClick"); end);
	GVAR.OptionsFrame.TestShuffler:SetScript("OnEnter", function() BattlegroundTargets:ShufflerFunc("OnEnter"); end);
	GVAR.OptionsFrame.TestShuffler:SetScript("OnLeave", function() BattlegroundTargets:ShufflerFunc("OnLeave"); end);
	GVAR.OptionsFrame.TestShuffler:SetScript("OnMouseDown", function(self, button)
		if(button == "LeftButton") then BattlegroundTargets:ShufflerFunc("OnMouseDown"); end
	end);
	GVAR.OptionsFrame.TestShuffler.Texture = GVAR.OptionsFrame.TestShuffler:CreateTexture(nil, "ARTWORK");
	GVAR.OptionsFrame.TestShuffler.Texture:SetWidth(32);
	GVAR.OptionsFrame.TestShuffler.Texture:SetHeight(32);
	GVAR.OptionsFrame.TestShuffler.Texture:SetPoint("CENTER", 0, 0);
	GVAR.OptionsFrame.TestShuffler.Texture:SetTexture("Interface\\Icons\\INV_Sigil_Thorim");
	GVAR.OptionsFrame.TestShuffler:SetNormalTexture(GVAR.OptionsFrame.TestShuffler.Texture);
	GVAR.OptionsFrame.TestShuffler.TextureHighlight = GVAR.OptionsFrame.TestShuffler:CreateTexture(nil, "OVERLAY");
	GVAR.OptionsFrame.TestShuffler.TextureHighlight:SetWidth(32);
	GVAR.OptionsFrame.TestShuffler.TextureHighlight:SetHeight(32);
	GVAR.OptionsFrame.TestShuffler.TextureHighlight:SetPoint("CENTER", 0, 0);
	GVAR.OptionsFrame.TestShuffler.TextureHighlight:SetTexture("Interface\\Buttons\\ButtonHilight-Square");
	GVAR.OptionsFrame.TestShuffler:SetHighlightTexture(GVAR.OptionsFrame.TestShuffler.TextureHighlight);
	
	GVAR.OptionsFrame.ConfigGeneral = CreateFrame("Frame", nil, GVAR.OptionsFrame);
	GVAR.OptionsFrame.ConfigGeneral:SetHeight(heightBracket);
	GVAR.OptionsFrame.ConfigGeneral:SetPoint("TOPLEFT", GVAR.OptionsFrame.Base, "BOTTOMLEFT", 0, 1);
	GVAR.OptionsFrame.ConfigGeneral:Hide();
	
	GVAR.OptionsFrame.GeneralTitle = GVAR.OptionsFrame.ConfigGeneral:CreateFontString(nil, "ARTWORK", "GameFontNormal");
	GVAR.OptionsFrame.GeneralTitle:SetHeight(20);
	GVAR.OptionsFrame.GeneralTitle:SetPoint("LEFT", GVAR.OptionsFrame, "LEFT", 10, 0);
	GVAR.OptionsFrame.GeneralTitle:SetPoint("TOPLEFT", GVAR.OptionsFrame.ConfigGeneral, "TOPLEFT", 10, -10);
	GVAR.OptionsFrame.GeneralTitle:SetJustifyH("LEFT");
	GVAR.OptionsFrame.GeneralTitle:SetText(L["General Settings"]..":");
	
	GVAR.OptionsFrame.Minimap = CreateFrame("CheckButton", nil, GVAR.OptionsFrame.ConfigGeneral);
	TEMPLATE.CheckButton(GVAR.OptionsFrame.Minimap, 16, 4, L["Show Minimap-Button"]);
	GVAR.OptionsFrame.Minimap:SetPoint("LEFT", GVAR.OptionsFrame, "LEFT", 10, 0);
	GVAR.OptionsFrame.Minimap:SetPoint("TOP", GVAR.OptionsFrame.GeneralTitle, "BOTTOM", 0, -10);
	GVAR.OptionsFrame.Minimap:SetChecked(BattlegroundTargets_Options.MinimapButton);
	TEMPLATE.EnableCheckButton(GVAR.OptionsFrame.Minimap);
	GVAR.OptionsFrame.Minimap:SetScript("OnClick", function()
		BattlegroundTargets_Options.MinimapButton = not BattlegroundTargets_Options.MinimapButton;
		BattlegroundTargets:CreateMinimapButton();
	end);
	
	GVAR.OptionsFrame.TargetIconText = GVAR.OptionsFrame.ConfigGeneral:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	GVAR.OptionsFrame.TargetIconText:SetHeight(20);
	GVAR.OptionsFrame.TargetIconText:SetPoint("LEFT", GVAR.OptionsFrame.ConfigGeneral, "LEFT", 10, 0);
	GVAR.OptionsFrame.TargetIconText:SetPoint("TOP", GVAR.OptionsFrame.Minimap, "BOTTOM", 0, -10);
	GVAR.OptionsFrame.TargetIconText:SetJustifyH("LEFT");
	GVAR.OptionsFrame.TargetIconText:SetText("Target:");
	GVAR.OptionsFrame.TargetIconText:SetTextColor(1, 1, 1, 1);
	GVAR.OptionsFrame.TargetIcon1 = CreateFrame("CheckButton", nil, GVAR.OptionsFrame.ConfigGeneral);
	TEMPLATE.CheckButton(GVAR.OptionsFrame.TargetIcon1, 16, 4, nil, "default");
	GVAR.OptionsFrame.TargetIcon1:SetPoint("LEFT", GVAR.OptionsFrame.TargetIconText, "RIGHT", 5, 0);
	TEMPLATE.EnableCheckButton(GVAR.OptionsFrame.TargetIcon1);
	GVAR.OptionsFrame.TargetIcon1:SetScript("OnClick", function()
		BattlegroundTargets_Options.TargetIcon = "default";
		GVAR.OptionsFrame.TargetIcon2:SetChecked(false);
		
		if(BattlegroundTargets_Options.EnableBracket[currentSize]) then
			BattlegroundTargets:EnableConfigMode();
		end
	end);
	GVAR.OptionsFrame.TargetIcon2 = CreateFrame("CheckButton", nil, GVAR.OptionsFrame.ConfigGeneral);
	TEMPLATE.CheckButton(GVAR.OptionsFrame.TargetIcon2, 16, 4, nil, "bgt");
	GVAR.OptionsFrame.TargetIcon2:SetPoint("LEFT", GVAR.OptionsFrame.TargetIcon1, "RIGHT", 5, 0);
	TEMPLATE.EnableCheckButton(GVAR.OptionsFrame.TargetIcon2);
	GVAR.OptionsFrame.TargetIcon2:SetScript("OnClick", function()
		BattlegroundTargets_Options.TargetIcon = "bgt";
		GVAR.OptionsFrame.TargetIcon1:SetChecked(false);
		
		if(BattlegroundTargets_Options.EnableBracket[currentSize]) then
			BattlegroundTargets:EnableConfigMode();
		end
	end);
	
	if(BattlegroundTargets_Options.TargetIcon == "default") then
		GVAR.OptionsFrame.TargetIcon1:SetChecked(true);
		GVAR.OptionsFrame.TargetIcon2:SetChecked(false);
	else
		GVAR.OptionsFrame.TargetIcon1:SetChecked(false);
		GVAR.OptionsFrame.TargetIcon2:SetChecked(true);
	end
	
	GVAR.OptionsFrame.MoverTop = CreateFrame("Frame", nil, GVAR.OptionsFrame);
	TEMPLATE.BorderTRBL(GVAR.OptionsFrame.MoverTop);
	GVAR.OptionsFrame.MoverTop:SetHeight(20);
	GVAR.OptionsFrame.MoverTop:SetPoint("BOTTOM", GVAR.OptionsFrame, "TOP", 0, -1);
	GVAR.OptionsFrame.MoverTop:EnableMouse(true);
	GVAR.OptionsFrame.MoverTop:EnableMouseWheel(true);
	GVAR.OptionsFrame.MoverTop:SetScript("OnMouseWheel", NOOP);
	GVAR.OptionsFrame.MoverTopText = GVAR.OptionsFrame.MoverTop:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	GVAR.OptionsFrame.MoverTopText:SetPoint("CENTER", GVAR.OptionsFrame.MoverTop, "CENTER", 0, 0);
	GVAR.OptionsFrame.MoverTopText:SetJustifyH("CENTER");
	GVAR.OptionsFrame.MoverTopText:SetTextColor(0.3, 0.3, 0.3, 1);
	GVAR.OptionsFrame.MoverTopText:SetText(L["click & move"]);
	
	GVAR.OptionsFrame.Close = CreateFrame("Button", nil, GVAR.OptionsFrame.MoverTop);
	TEMPLATE.IconButton(GVAR.OptionsFrame.Close, 1);
	GVAR.OptionsFrame.Close:SetWidth(20);
	GVAR.OptionsFrame.Close:SetHeight(20);
	GVAR.OptionsFrame.Close:SetPoint("RIGHT", GVAR.OptionsFrame.MoverTop, "RIGHT", 0, 0);
	GVAR.OptionsFrame.Close:SetScript("OnClick", function() GVAR.OptionsFrame:Hide(); end);
	
	GVAR.OptionsFrame.MoverBottom = CreateFrame("Frame", nil, GVAR.OptionsFrame);
	TEMPLATE.BorderTRBL(GVAR.OptionsFrame.MoverBottom);
	GVAR.OptionsFrame.MoverBottom:SetHeight(20);
	GVAR.OptionsFrame.MoverBottom:SetPoint("TOP", GVAR.OptionsFrame, "BOTTOM", 0, 1);
	GVAR.OptionsFrame.MoverBottom:EnableMouse(true);
	GVAR.OptionsFrame.MoverBottom:EnableMouseWheel(true);
	GVAR.OptionsFrame.MoverBottom:SetScript("OnMouseWheel", NOOP);
	GVAR.OptionsFrame.MoverBottomText = GVAR.OptionsFrame.MoverBottom:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	GVAR.OptionsFrame.MoverBottomText:SetPoint("CENTER", GVAR.OptionsFrame.MoverBottom, "CENTER", 0, 0);
	GVAR.OptionsFrame.MoverBottomText:SetJustifyH("CENTER");
	GVAR.OptionsFrame.MoverBottomText:SetTextColor(0.3, 0.3, 0.3, 1);
	GVAR.OptionsFrame.MoverBottomText:SetText(L["click & move"]);
	
	GVAR.OptionsFrame.MoverTop:SetScript("OnEnter", function() GVAR.OptionsFrame.MoverTopText:SetTextColor(1, 1, 1, 1); end);
	GVAR.OptionsFrame.MoverTop:SetScript("OnLeave", function() GVAR.OptionsFrame.MoverTopText:SetTextColor(0.3, 0.3, 0.3, 1); end);
	GVAR.OptionsFrame.MoverTop:SetScript("OnMouseDown", function() GVAR.OptionsFrame:StartMoving(); end);
	GVAR.OptionsFrame.MoverTop:SetScript("OnMouseUp", function() GVAR.OptionsFrame:StopMovingOrSizing(); BattlegroundTargets:Frame_SavePosition("BattlegroundTargets_OptionsFrame"); end);

	GVAR.OptionsFrame.MoverBottom:SetScript("OnEnter", function() GVAR.OptionsFrame.MoverBottomText:SetTextColor(1, 1, 1, 1); end);
	GVAR.OptionsFrame.MoverBottom:SetScript("OnLeave", function() GVAR.OptionsFrame.MoverBottomText:SetTextColor(0.3, 0.3, 0.3, 1); end);
	GVAR.OptionsFrame.MoverBottom:SetScript("OnMouseDown", function() GVAR.OptionsFrame:StartMoving(); end);
	GVAR.OptionsFrame.MoverBottom:SetScript("OnMouseUp", function() GVAR.OptionsFrame:StopMovingOrSizing(); BattlegroundTargets:Frame_SavePosition("BattlegroundTargets_OptionsFrame"); end);
	
	local frameWidth = 400;
	
	if(layoutW > frameWidth) then frameWidth = layoutW; end
	if(iconW > frameWidth) then frameWidth = iconW; end
	if(rangeW > frameWidth) then frameWidth = rangeW; end
	if(sortW > frameWidth) then frameWidth = sortW; end
	if(frameWidth < 400) then frameWidth = 400; end
	if(frameWidth > 650) then frameWidth = 650; end
	
	GVAR.OptionsFrame:SetClampRectInsets((frameWidth - 50) / 2, -((frameWidth - 50) / 2), -(heightTotal - 35), heightTotal - 35);
	GVAR.OptionsFrame:SetWidth(frameWidth);
	GVAR.OptionsFrame.CloseConfig:SetWidth(frameWidth - 20);
	
	GVAR.OptionsFrame.Base:SetWidth(frameWidth);
	GVAR.OptionsFrame.Title:SetWidth(frameWidth);
	
	local spacer = 10;
	local tabWidth1 = 36;
	local tabWidth2 = math_floor((frameWidth - tabWidth1 - tabWidth1 - (6 * spacer)) / 3 );
	
	GVAR.OptionsFrame.TabGeneral:SetWidth(tabWidth1);
	GVAR.OptionsFrame.TabRaidSize10:SetWidth(tabWidth2);
	GVAR.OptionsFrame.TabRaidSize15:SetWidth(tabWidth2);
	GVAR.OptionsFrame.TabRaidSize40:SetWidth(tabWidth2);
	GVAR.OptionsFrame.TabGeneral:SetPoint("BOTTOMLEFT", GVAR.OptionsFrame.Base, "BOTTOMLEFT", spacer, -1);
	GVAR.OptionsFrame.TabRaidSize10:SetPoint("BOTTOMLEFT", GVAR.OptionsFrame.Base, "BOTTOMLEFT", spacer + tabWidth1 + spacer, -1);
	GVAR.OptionsFrame.TabRaidSize15:SetPoint("BOTTOMLEFT", GVAR.OptionsFrame.Base, "BOTTOMLEFT", spacer + tabWidth1 + spacer + ((tabWidth2 + spacer) * 1), -1);
	GVAR.OptionsFrame.TabRaidSize40:SetPoint("BOTTOMLEFT", GVAR.OptionsFrame.Base, "BOTTOMLEFT", spacer + tabWidth1 + spacer + ((tabWidth2 + spacer) * 2), -1);
	GVAR.OptionsFrame.Dummy1:SetWidth(frameWidth-26-26);
	
	GVAR.OptionsFrame.ConfigBrackets:SetWidth(frameWidth);
	GVAR.OptionsFrame.ShowLeader:SetPoint("LEFT", GVAR.OptionsFrame, "LEFT", (frameWidth - 10 - 10) / 2, 0);
	--GVAR.OptionsFrame.ShowHealer:SetPoint("LEFT", GVAR.OptionsFrame, "LEFT", (frameWidth - 10 - 10) / 2, 0);
	
	GVAR.OptionsFrame.ConfigGeneral:SetWidth(frameWidth);
	
	GVAR.OptionsFrame.MoverTop:SetWidth(frameWidth);
	GVAR.OptionsFrame.MoverBottom:SetWidth(frameWidth);
end

function BattlegroundTargets:SetOptions()
	GVAR.OptionsFrame.EnableBracket:SetChecked(BattlegroundTargets_Options.EnableBracket[currentSize]);
	GVAR.OptionsFrame.IndependentPos:SetChecked(BattlegroundTargets_Options.IndependentPositioning[currentSize]);

	if(currentSize == 10) then
		GVAR.OptionsFrame.CopySettings:SetText(string_format(L["Copy this settings to '%s'"], L["15 vs 15"]));
	elseif(currentSize == 15) then
		GVAR.OptionsFrame.CopySettings:SetText(string_format(L["Copy this settings to '%s'"], L["10 vs 10"]));
	end

	local LayoutTH = BattlegroundTargets_Options.LayoutTH[currentSize];
	
	if(LayoutTH == 18) then
		GVAR.OptionsFrame.LayoutTHx18:SetChecked(true);
		GVAR.OptionsFrame.LayoutTHx24:SetChecked(false);
		GVAR.OptionsFrame.LayoutTHx42:SetChecked(false);
		GVAR.OptionsFrame.LayoutTHx81:SetChecked(false);
	elseif(LayoutTH == 24) then
		GVAR.OptionsFrame.LayoutTHx18:SetChecked(false);
		GVAR.OptionsFrame.LayoutTHx24:SetChecked(true);
		GVAR.OptionsFrame.LayoutTHx42:SetChecked(false);
		GVAR.OptionsFrame.LayoutTHx81:SetChecked(false);
	elseif(LayoutTH == 42) then
		GVAR.OptionsFrame.LayoutTHx18:SetChecked(false);
		GVAR.OptionsFrame.LayoutTHx24:SetChecked(false);
		GVAR.OptionsFrame.LayoutTHx42:SetChecked(true);
		GVAR.OptionsFrame.LayoutTHx81:SetChecked(false);
	elseif(LayoutTH == 81) then
		GVAR.OptionsFrame.LayoutTHx18:SetChecked(false);
		GVAR.OptionsFrame.LayoutTHx24:SetChecked(false);
		GVAR.OptionsFrame.LayoutTHx42:SetChecked(false);
		GVAR.OptionsFrame.LayoutTHx81:SetChecked(true);
	end
	
	GVAR.OptionsFrame.LayoutSpace:SetValue(BattlegroundTargets_Options.LayoutSpace[currentSize]);
	GVAR.OptionsFrame.LayoutSpaceText:SetText(BattlegroundTargets_Options.LayoutSpace[currentSize]);
	
	GVAR.OptionsFrame.ClassIcon:SetChecked(OPT.ButtonClassIcon[currentSize]);
	GVAR.OptionsFrame.ShowLeader:SetChecked(OPT.ButtonShowLeader[currentSize]);
	GVAR.OptionsFrame.ShowRealm:SetChecked(OPT.ButtonHideRealm[currentSize]);
	
	GVAR.OptionsFrame.ShowTargetIndicator:SetChecked(OPT.ButtonShowTarget[currentSize]);
	GVAR.OptionsFrame.TargetScaleSlider:SetValue(OPT.ButtonTargetScale[currentSize]*100);
	GVAR.OptionsFrame.TargetScaleSliderText:SetText((OPT.ButtonTargetScale[currentSize]*100).."%");
	GVAR.OptionsFrame.TargetPositionSlider:SetValue(OPT.ButtonTargetPosition[currentSize]);
	GVAR.OptionsFrame.TargetPositionSliderText:SetText(OPT.ButtonTargetPosition[currentSize]);
	
	GVAR.OptionsFrame.ShowFocusIndicator:SetChecked(OPT.ButtonShowFocus[currentSize]);
	GVAR.OptionsFrame.FocusScaleSlider:SetValue(OPT.ButtonFocusScale[currentSize]*100);
	GVAR.OptionsFrame.FocusScaleSliderText:SetText((OPT.ButtonFocusScale[currentSize]*100).."%");
	GVAR.OptionsFrame.FocusPositionSlider:SetValue(OPT.ButtonFocusPosition[currentSize]);
	GVAR.OptionsFrame.FocusPositionSliderText:SetText(OPT.ButtonFocusPosition[currentSize]);
	
	GVAR.OptionsFrame.ShowFlag:SetChecked(OPT.ButtonShowFlag[currentSize]);
	GVAR.OptionsFrame.FlagScaleSlider:SetValue(OPT.ButtonFlagScale[currentSize]*100);
	GVAR.OptionsFrame.FlagScaleSliderText:SetText((OPT.ButtonFlagScale[currentSize]*100).."%");
	GVAR.OptionsFrame.FlagPositionSlider:SetValue(OPT.ButtonFlagPosition[currentSize]);
	GVAR.OptionsFrame.FlagPositionSliderText:SetText(OPT.ButtonFlagPosition[currentSize]);
	
	GVAR.OptionsFrame.ShowAssist:SetChecked(OPT.ButtonShowAssist[currentSize]);
	GVAR.OptionsFrame.AssistScaleSlider:SetValue(OPT.ButtonAssistScale[currentSize]*100);
	GVAR.OptionsFrame.AssistScaleSliderText:SetText((OPT.ButtonAssistScale[currentSize]*100).."%");
	GVAR.OptionsFrame.AssistPositionSlider:SetValue(OPT.ButtonAssistPosition[currentSize]);
	GVAR.OptionsFrame.AssistPositionSliderText:SetText(OPT.ButtonAssistPosition[currentSize]);
	
	GVAR.OptionsFrame.ShowTargetCount:SetChecked(OPT.ButtonShowTargetCount[currentSize]);
	
	GVAR.OptionsFrame.ShowHealthBar:SetChecked(OPT.ButtonShowHealthBar[currentSize]);
	GVAR.OptionsFrame.ShowHealthText:SetChecked(OPT.ButtonShowHealthText[currentSize]);
	
	GVAR.OptionsFrame.RangeCheck:SetChecked(OPT.ButtonRangeCheck[currentSize]);
	GVAR.OptionsFrame.RangeCheckTypePullDown.PullDownButtonText:SetText(rangeTypeName[ OPT.ButtonTypeRangeCheck[currentSize] ]);
	GVAR.OptionsFrame.RangeDisplayPullDown.PullDownButtonText:SetText(rangeDisplay[ OPT.ButtonRangeDisplay[currentSize] ]);

	GVAR.OptionsFrame.SortByPullDown.PullDownButtonText:SetText(sortBy[ OPT.ButtonSortBy[currentSize] ]);
	GVAR.OptionsFrame.SortDetailPullDown.PullDownButtonText:SetText(sortDetail[ OPT.ButtonSortDetail[currentSize] ]);
	
	GVAR.OptionsFrame.RoleLayoutPosPullDown.PullDownButtonText:SetText(roleLayoutPos[OPT.ButtonRoleLayoutPos[currentSize]]);

	local ButtonSortBy = OPT.ButtonSortBy[currentSize];
	if(ButtonSortBy == 1) then
		GVAR.OptionsFrame.SortDetailPullDown:Show();
		GVAR.OptionsFrame.SortInfo:Show();
	else
		GVAR.OptionsFrame.SortDetailPullDown:Hide();
		GVAR.OptionsFrame.SortInfo:Hide();
	end
	
	GVAR.OptionsFrame.FontSlider:SetValue(OPT.ButtonFontSize[currentSize]);
	GVAR.OptionsFrame.FontValue:SetText(OPT.ButtonFontSize[currentSize]);

	GVAR.OptionsFrame.ScaleSlider:SetValue(OPT.ButtonScale[currentSize]*100);
	GVAR.OptionsFrame.ScaleValue:SetText((OPT.ButtonScale[currentSize]*100).."%");
	
	GVAR.OptionsFrame.WidthSlider:SetValue(OPT.ButtonWidth[currentSize]);
	GVAR.OptionsFrame.WidthValue:SetText(OPT.ButtonWidth[currentSize]);

	GVAR.OptionsFrame.HeightSlider:SetValue(OPT.ButtonHeight[currentSize]);
	GVAR.OptionsFrame.HeightValue:SetText(OPT.ButtonHeight[currentSize]);
end

function BattlegroundTargets:CheckForEnabledBracket(bracketSize)
	if(BattlegroundTargets_Options.EnableBracket[bracketSize]) then
		if(bracketSize == 10) then
			GVAR.OptionsFrame.TabRaidSize10.TabText:SetTextColor(0, 0.75, 0, 1);
		elseif(bracketSize == 15) then
			GVAR.OptionsFrame.TabRaidSize15.TabText:SetTextColor(0, 0.75, 0, 1);
		elseif(bracketSize == 40) then
			GVAR.OptionsFrame.TabRaidSize40.TabText:SetTextColor(0, 0.75, 0, 1);
		end

		TEMPLATE.EnableCheckButton(GVAR.OptionsFrame.IndependentPos);

		GVAR.OptionsFrame.LayoutTHText:SetTextColor(1, 1, 1, 1);
		TEMPLATE.EnableCheckButton(GVAR.OptionsFrame.LayoutTHx18);
		
		if(bracketSize == 10 or bracketSize == 15) then
			TEMPLATE.DisableCheckButton(GVAR.OptionsFrame.LayoutTHx24);
			TEMPLATE.DisableCheckButton(GVAR.OptionsFrame.LayoutTHx42);
		else
			TEMPLATE.EnableCheckButton(GVAR.OptionsFrame.LayoutTHx24);
			TEMPLATE.EnableCheckButton(GVAR.OptionsFrame.LayoutTHx42);
		end
		
		TEMPLATE.EnableCheckButton(GVAR.OptionsFrame.LayoutTHx81);
		TEMPLATE.EnableSlider(GVAR.OptionsFrame.LayoutSpace);

		if(bracketSize == 40) then
 			GVAR.OptionsFrame.CopySettings:Hide();
		else
			GVAR.OptionsFrame.CopySettings:Show();
			TEMPLATE.EnableTextButton(GVAR.OptionsFrame.CopySettings, 4);
		end
		
		TEMPLATE.EnableCheckButton(GVAR.OptionsFrame.ClassIcon);
		TEMPLATE.EnableCheckButton(GVAR.OptionsFrame.ShowLeader);
		TEMPLATE.EnableCheckButton(GVAR.OptionsFrame.ShowRealm);
		TEMPLATE.EnableCheckButton(GVAR.OptionsFrame.ShowTargetIndicator);
		
		if(OPT.ButtonShowTarget[bracketSize]) then
			TEMPLATE.EnableSlider(GVAR.OptionsFrame.TargetScaleSlider);
			TEMPLATE.EnableSlider(GVAR.OptionsFrame.TargetPositionSlider);
		else
			TEMPLATE.DisableSlider(GVAR.OptionsFrame.TargetScaleSlider);
			TEMPLATE.DisableSlider(GVAR.OptionsFrame.TargetPositionSlider);
		end
		
		TEMPLATE.EnableCheckButton(GVAR.OptionsFrame.ShowFocusIndicator);
		
		if(OPT.ButtonShowFocus[bracketSize]) then
			TEMPLATE.EnableSlider(GVAR.OptionsFrame.FocusScaleSlider);
			TEMPLATE.EnableSlider(GVAR.OptionsFrame.FocusPositionSlider);
		else
			TEMPLATE.DisableSlider(GVAR.OptionsFrame.FocusScaleSlider);
			TEMPLATE.DisableSlider(GVAR.OptionsFrame.FocusPositionSlider);
		end
		
		if(bracketSize == 40) then
			TEMPLATE.DisableCheckButton(GVAR.OptionsFrame.ShowFlag);
			TEMPLATE.DisableSlider(GVAR.OptionsFrame.FlagScaleSlider);
			TEMPLATE.DisableSlider(GVAR.OptionsFrame.FlagPositionSlider);
		else
			TEMPLATE.EnableCheckButton(GVAR.OptionsFrame.ShowFlag);
			
			if(OPT.ButtonShowFlag[bracketSize]) then
				TEMPLATE.EnableSlider(GVAR.OptionsFrame.FlagScaleSlider);
				TEMPLATE.EnableSlider(GVAR.OptionsFrame.FlagPositionSlider);
			else
				TEMPLATE.DisableSlider(GVAR.OptionsFrame.FlagScaleSlider);
				TEMPLATE.DisableSlider(GVAR.OptionsFrame.FlagPositionSlider);
			end
		end
		
		TEMPLATE.EnableCheckButton(GVAR.OptionsFrame.ShowAssist);
		
		if(OPT.ButtonShowAssist[bracketSize]) then
			TEMPLATE.EnableSlider(GVAR.OptionsFrame.AssistScaleSlider);
			TEMPLATE.EnableSlider(GVAR.OptionsFrame.AssistPositionSlider);
		else
			TEMPLATE.DisableSlider(GVAR.OptionsFrame.AssistScaleSlider);
			TEMPLATE.DisableSlider(GVAR.OptionsFrame.AssistPositionSlider);
		end
		
		TEMPLATE.EnableCheckButton(GVAR.OptionsFrame.ShowTargetCount);
		
		TEMPLATE.EnableCheckButton(GVAR.OptionsFrame.ShowHealthBar);
		TEMPLATE.EnableCheckButton(GVAR.OptionsFrame.ShowHealthText);
		
		TEMPLATE.EnableCheckButton(GVAR.OptionsFrame.RangeCheck);
		
		if(OPT.ButtonRangeCheck[bracketSize]) then
			TEMPLATE.EnablePullDownMenu(GVAR.OptionsFrame.RangeCheckTypePullDown);
			GVAR.OptionsFrame.RangeCheckInfo:Enable() Desaturation(GVAR.OptionsFrame.RangeCheckInfo.Texture, false);
			TEMPLATE.EnablePullDownMenu(GVAR.OptionsFrame.RangeDisplayPullDown);
		else
			TEMPLATE.DisablePullDownMenu(GVAR.OptionsFrame.RangeCheckTypePullDown);
			GVAR.OptionsFrame.RangeCheckInfo:Disable() Desaturation(GVAR.OptionsFrame.RangeCheckInfo.Texture, true);
			TEMPLATE.DisablePullDownMenu(GVAR.OptionsFrame.RangeDisplayPullDown);
		end

		TEMPLATE.EnablePullDownMenu(GVAR.OptionsFrame.SortByPullDown);
		GVAR.OptionsFrame.SortByTitle:SetTextColor(1, 1, 1, 1);
		TEMPLATE.EnablePullDownMenu(GVAR.OptionsFrame.SortDetailPullDown);
		GVAR.OptionsFrame.SortInfo:Enable() Desaturation(GVAR.OptionsFrame.SortInfo.Texture, false);
		
		TEMPLATE.EnablePullDownMenu(GVAR.OptionsFrame.RoleLayoutPosPullDown);

		TEMPLATE.EnableSlider(GVAR.OptionsFrame.FontSlider);
		GVAR.OptionsFrame.FontTitle:SetTextColor(1, 1, 1, 1);
		TEMPLATE.EnableSlider(GVAR.OptionsFrame.ScaleSlider);
		GVAR.OptionsFrame.ScaleTitle:SetTextColor(1, 1, 1, 1);
		TEMPLATE.EnableSlider(GVAR.OptionsFrame.WidthSlider);
		GVAR.OptionsFrame.WidthTitle:SetTextColor(1, 1, 1, 1);
		TEMPLATE.EnableSlider(GVAR.OptionsFrame.HeightSlider);
		GVAR.OptionsFrame.HeightTitle:SetTextColor(1, 1, 1, 1);
		GVAR.OptionsFrame.TestShuffler:Show();
	else
		if(bracketSize == 10) then
			GVAR.OptionsFrame.TabRaidSize10.TabText:SetTextColor(1, 0, 0, 1);
		elseif(bracketSize == 15) then
			GVAR.OptionsFrame.TabRaidSize15.TabText:SetTextColor(1, 0, 0, 1);
		elseif(bracketSize == 40) then
			GVAR.OptionsFrame.TabRaidSize40.TabText:SetTextColor(1, 0, 0, 1);
		end
		
		TEMPLATE.DisableCheckButton(GVAR.OptionsFrame.IndependentPos);
		
		GVAR.OptionsFrame.LayoutTHText:SetTextColor(0.5, 0.5, 0.5, 1);
		TEMPLATE.DisableCheckButton(GVAR.OptionsFrame.LayoutTHx18);
		TEMPLATE.DisableCheckButton(GVAR.OptionsFrame.LayoutTHx24);
		TEMPLATE.DisableCheckButton(GVAR.OptionsFrame.LayoutTHx42);
		TEMPLATE.DisableCheckButton(GVAR.OptionsFrame.LayoutTHx81);
		TEMPLATE.DisableSlider(GVAR.OptionsFrame.LayoutSpace);
		
		if(bracketSize == 40) then
 			GVAR.OptionsFrame.CopySettings:Hide();
		else
			GVAR.OptionsFrame.CopySettings:Show();
			TEMPLATE.DisableTextButton(GVAR.OptionsFrame.CopySettings, 4);
		end
		
		TEMPLATE.DisableCheckButton(GVAR.OptionsFrame.ClassIcon);
		TEMPLATE.DisableCheckButton(GVAR.OptionsFrame.ShowLeader);
		TEMPLATE.DisableCheckButton(GVAR.OptionsFrame.ShowRealm);
		
		TEMPLATE.DisableCheckButton(GVAR.OptionsFrame.ShowTargetIndicator);
		TEMPLATE.DisableSlider(GVAR.OptionsFrame.TargetScaleSlider);
		TEMPLATE.DisableSlider(GVAR.OptionsFrame.TargetPositionSlider);
		TEMPLATE.DisableCheckButton(GVAR.OptionsFrame.ShowFocusIndicator);
		TEMPLATE.DisableSlider(GVAR.OptionsFrame.FocusScaleSlider);
		TEMPLATE.DisableSlider(GVAR.OptionsFrame.FocusPositionSlider);
		TEMPLATE.DisableCheckButton(GVAR.OptionsFrame.ShowFlag);
		TEMPLATE.DisableSlider(GVAR.OptionsFrame.FlagScaleSlider);
		TEMPLATE.DisableSlider(GVAR.OptionsFrame.FlagPositionSlider);
		TEMPLATE.DisableCheckButton(GVAR.OptionsFrame.ShowAssist);
		TEMPLATE.DisableSlider(GVAR.OptionsFrame.AssistScaleSlider);
		TEMPLATE.DisableSlider(GVAR.OptionsFrame.AssistPositionSlider);
		
		TEMPLATE.DisableCheckButton(GVAR.OptionsFrame.ShowTargetCount);
		
		TEMPLATE.DisableCheckButton(GVAR.OptionsFrame.ShowHealthBar);
		TEMPLATE.DisableCheckButton(GVAR.OptionsFrame.ShowHealthText);
		
		TEMPLATE.DisableCheckButton(GVAR.OptionsFrame.RangeCheck);
		TEMPLATE.DisablePullDownMenu(GVAR.OptionsFrame.RangeCheckTypePullDown);
		GVAR.OptionsFrame.RangeCheckInfo:Disable() Desaturation(GVAR.OptionsFrame.RangeCheckInfo.Texture, true);
		TEMPLATE.DisablePullDownMenu(GVAR.OptionsFrame.RangeDisplayPullDown);
		
		TEMPLATE.DisablePullDownMenu(GVAR.OptionsFrame.SortByPullDown);
		GVAR.OptionsFrame.SortByTitle:SetTextColor(0.5, 0.5, 0.5, 1);
		TEMPLATE.DisablePullDownMenu(GVAR.OptionsFrame.SortDetailPullDown);
		GVAR.OptionsFrame.SortInfo:Disable() Desaturation(GVAR.OptionsFrame.SortInfo.Texture, true);
		
		TEMPLATE.DisablePullDownMenu(GVAR.OptionsFrame.RoleLayoutPosPullDown);

		TEMPLATE.DisableSlider(GVAR.OptionsFrame.FontSlider);
		GVAR.OptionsFrame.FontTitle:SetTextColor(0.5, 0.5, 0.5, 1);
		TEMPLATE.DisableSlider(GVAR.OptionsFrame.ScaleSlider);
		GVAR.OptionsFrame.ScaleTitle:SetTextColor(0.5, 0.5, 0.5, 1);
		TEMPLATE.DisableSlider(GVAR.OptionsFrame.WidthSlider);
		GVAR.OptionsFrame.WidthTitle:SetTextColor(0.5, 0.5, 0.5, 1);
		TEMPLATE.DisableSlider(GVAR.OptionsFrame.HeightSlider);
		GVAR.OptionsFrame.HeightTitle:SetTextColor(0.5, 0.5, 0.5, 1);
		GVAR.OptionsFrame.TestShuffler:Hide();
	end
end

function BattlegroundTargets:DisableInsecureConfigWidges()
	TEMPLATE.DisableCheckButton(GVAR.OptionsFrame.Minimap);
	GVAR.OptionsFrame.TargetIconText:SetTextColor(0.5, 0.5, 0.5, 1);
	TEMPLATE.DisableCheckButton(GVAR.OptionsFrame.TargetIcon1);
	TEMPLATE.DisableCheckButton(GVAR.OptionsFrame.TargetIcon2);
	
	TEMPLATE.DisableTabButton(GVAR.OptionsFrame.TabGeneral);
	TEMPLATE.DisableTabButton(GVAR.OptionsFrame.TabRaidSize10);
	TEMPLATE.DisableTabButton(GVAR.OptionsFrame.TabRaidSize15);
	TEMPLATE.DisableTabButton(GVAR.OptionsFrame.TabRaidSize40);
	
	TEMPLATE.DisableCheckButton(GVAR.OptionsFrame.EnableBracket);
	TEMPLATE.DisableCheckButton(GVAR.OptionsFrame.IndependentPos);
	
	TEMPLATE.DisableTextButton(GVAR.OptionsFrame.CopySettings);
	
	GVAR.OptionsFrame.LayoutTHText:SetTextColor(0.5, 0.5, 0.5, 1);
	TEMPLATE.DisableCheckButton(GVAR.OptionsFrame.LayoutTHx18);
	TEMPLATE.DisableCheckButton(GVAR.OptionsFrame.LayoutTHx24);
	TEMPLATE.DisableCheckButton(GVAR.OptionsFrame.LayoutTHx42);
	TEMPLATE.DisableCheckButton(GVAR.OptionsFrame.LayoutTHx81);
	TEMPLATE.DisableSlider(GVAR.OptionsFrame.LayoutSpace);
	
	TEMPLATE.DisableCheckButton(GVAR.OptionsFrame.ClassIcon);
	TEMPLATE.DisableCheckButton(GVAR.OptionsFrame.ShowLeader);
	TEMPLATE.DisableCheckButton(GVAR.OptionsFrame.ShowRealm);
	TEMPLATE.DisableCheckButton(GVAR.OptionsFrame.ShowTargetIndicator);
	TEMPLATE.DisableSlider(GVAR.OptionsFrame.TargetScaleSlider);
	TEMPLATE.DisableSlider(GVAR.OptionsFrame.TargetPositionSlider);
	TEMPLATE.DisableCheckButton(GVAR.OptionsFrame.ShowFocusIndicator);
	TEMPLATE.DisableSlider(GVAR.OptionsFrame.FocusScaleSlider);
	TEMPLATE.DisableSlider(GVAR.OptionsFrame.FocusPositionSlider);
	TEMPLATE.DisableCheckButton(GVAR.OptionsFrame.ShowFlag);
	TEMPLATE.DisableSlider(GVAR.OptionsFrame.FlagScaleSlider);
	TEMPLATE.DisableSlider(GVAR.OptionsFrame.FlagPositionSlider);
	TEMPLATE.DisableCheckButton(GVAR.OptionsFrame.ShowAssist);
	TEMPLATE.DisableSlider(GVAR.OptionsFrame.AssistScaleSlider);
	TEMPLATE.DisableSlider(GVAR.OptionsFrame.AssistPositionSlider);
	
	TEMPLATE.DisableCheckButton(GVAR.OptionsFrame.ShowTargetCount);
	
	TEMPLATE.DisableCheckButton(GVAR.OptionsFrame.ShowHealthBar);
	TEMPLATE.DisableCheckButton(GVAR.OptionsFrame.ShowHealthText);
	
	TEMPLATE.DisableCheckButton(GVAR.OptionsFrame.RangeCheck);
	TEMPLATE.DisablePullDownMenu(GVAR.OptionsFrame.RangeCheckTypePullDown);
	GVAR.OptionsFrame.RangeCheckInfo:Disable() Desaturation(GVAR.OptionsFrame.RangeCheckInfo.Texture, true);
	TEMPLATE.DisablePullDownMenu(GVAR.OptionsFrame.RangeDisplayPullDown);
	
	TEMPLATE.DisablePullDownMenu(GVAR.OptionsFrame.SortByPullDown);
	GVAR.OptionsFrame.SortByTitle:SetTextColor(0.5, 0.5, 0.5, 1);
	TEMPLATE.DisablePullDownMenu(GVAR.OptionsFrame.SortDetailPullDown);
	GVAR.OptionsFrame.SortInfo:Disable() Desaturation(GVAR.OptionsFrame.SortInfo.Texture, true);
	
	TEMPLATE.DisableSlider(GVAR.OptionsFrame.FontSlider);
	GVAR.OptionsFrame.FontTitle:SetTextColor(0.5, 0.5, 0.5, 1);
	TEMPLATE.DisableSlider(GVAR.OptionsFrame.ScaleSlider);
	GVAR.OptionsFrame.ScaleTitle:SetTextColor(0.5, 0.5, 0.5, 1);
	TEMPLATE.DisableSlider(GVAR.OptionsFrame.WidthSlider);
	GVAR.OptionsFrame.WidthTitle:SetTextColor(0.5, 0.5, 0.5, 1);
	TEMPLATE.DisableSlider(GVAR.OptionsFrame.HeightSlider);
	GVAR.OptionsFrame.HeightTitle:SetTextColor(0.5, 0.5, 0.5, 1);
	GVAR.OptionsFrame.TestShuffler:Hide();
end

function BattlegroundTargets:EnableInsecureConfigWidges()
	TEMPLATE.EnableTabButton(GVAR.OptionsFrame.TabGeneral, true);
	TEMPLATE.EnableTabButton(GVAR.OptionsFrame.TabRaidSize10, BattlegroundTargets_Options.EnableBracket[10]);
	TEMPLATE.EnableTabButton(GVAR.OptionsFrame.TabRaidSize15, BattlegroundTargets_Options.EnableBracket[15]);
	TEMPLATE.EnableTabButton(GVAR.OptionsFrame.TabRaidSize40, BattlegroundTargets_Options.EnableBracket[40]);
	
	TEMPLATE.EnableCheckButton(GVAR.OptionsFrame.EnableBracket);
	TEMPLATE.EnableCheckButton(GVAR.OptionsFrame.Minimap);
	
	GVAR.OptionsFrame.TargetIconText:SetTextColor(1, 1, 1, 1);
	TEMPLATE.EnableCheckButton(GVAR.OptionsFrame.TargetIcon1);
	TEMPLATE.EnableCheckButton(GVAR.OptionsFrame.TargetIcon2);
	
	BattlegroundTargets:CheckForEnabledBracket(testSize);
end

function BattlegroundTargets:CreateMinimapButton()
	if(not BattlegroundTargets_Options.MinimapButton) then
		if(BattlegroundTargets_MinimapButton) then
			BattlegroundTargets_MinimapButton:Hide();
		end
		
		return;
	else
		if(BattlegroundTargets_MinimapButton) then
			BattlegroundTargets_MinimapButton:Show();
			
			return;
		end
	end
	
	if(BattlegroundTargets_MinimapButton) then return; end
	
	local function MoveMinimapButton()
		local xpos;
		local ypos;
		local minimapShape = GetMinimapShape and GetMinimapShape() or "ROUND";
		
		if(minimapShape == "SQUARE") then
			xpos = 110 * cos(BattlegroundTargets_Options.MinimapButtonPos or 0);
			ypos = 110 * sin(BattlegroundTargets_Options.MinimapButtonPos or 0);
			xpos = math.max(-82, math.min(xpos, 84));
			ypos = math.max(-86, math.min(ypos, 82));
		else
			xpos = 80 * cos(BattlegroundTargets_Options.MinimapButtonPos or 0);
			ypos = 80 * sin(BattlegroundTargets_Options.MinimapButtonPos or 0);
		end
		
		BattlegroundTargets_MinimapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 54-xpos, ypos-54);
	end
	
	local function DragMinimapButton()
		local xpos, ypos = GetCursorPosition();
		local xmin, ymin = Minimap:GetLeft() or 400, Minimap:GetBottom() or 400;
		local scale = Minimap:GetEffectiveScale();
		
		xpos = xmin-xpos/scale+70;
		ypos = ypos/scale-ymin-70;
		BattlegroundTargets_Options.MinimapButtonPos = math.deg(math.atan2(ypos, xpos));
		MoveMinimapButton();
	end
	
	local MinimapButton = CreateFrame("Button", "BattlegroundTargets_MinimapButton", Minimap);
	MinimapButton:EnableMouse(true);
	MinimapButton:SetMovable(true);
	MinimapButton:SetToplevel(true);
	MinimapButton:SetWidth(32);
	MinimapButton:SetHeight(32);
	MinimapButton:SetPoint("TOPLEFT");
	MinimapButton:SetFrameStrata("LOW");
	MinimapButton:RegisterForClicks("AnyUp");
	MinimapButton:RegisterForDrag("LeftButton");
	
	local texture = MinimapButton:CreateTexture(nil, "ARTWORK");
	texture:SetWidth(54);
	texture:SetHeight(54);
	texture:SetPoint("TOPLEFT");
	texture:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder");
	
	local texture = MinimapButton:CreateTexture(nil, "BACKGROUND");
	texture:SetWidth(24);
	texture:SetHeight(24);
	texture:SetPoint("TOPLEFT", 2, -4);
	texture:SetTexture("Interface\\Minimap\\UI-Minimap-Background");
	
	local NormalTexture = MinimapButton:CreateTexture(nil, "ARTWORK");
	NormalTexture:SetWidth(12);
	NormalTexture:SetHeight(14);
	NormalTexture:SetPoint("TOPLEFT", 10.5, -8.5);
	NormalTexture:SetTexture(AddonIcon);
	NormalTexture:SetTexCoord(2/16, 14/16, 1/16, 15/16);
	MinimapButton:SetNormalTexture(NormalTexture);
	
	local PushedTexture = MinimapButton:CreateTexture(nil, "ARTWORK");
	PushedTexture:SetWidth(10);
	PushedTexture:SetHeight(12);
	PushedTexture:SetPoint("TOPLEFT", 11.5, -9.5);
	PushedTexture:SetTexture(AddonIcon);
	PushedTexture:SetTexCoord(2/16, 14/16, 1/16, 15/16);
	MinimapButton:SetPushedTexture(PushedTexture);
	
	local HighlightTexture = MinimapButton:CreateTexture(nil, "ARTWORK");
	HighlightTexture:SetPoint("TOPLEFT", 0, 0);
	HighlightTexture:SetPoint("BOTTOMRIGHT", 0, 0);
	HighlightTexture:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight");
	MinimapButton:SetHighlightTexture(HighlightTexture);
	MinimapButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:AddLine("BattlegroundTargets", 1, 0.82, 0, 1);
		GameTooltip:Show();
	end);
	MinimapButton:SetScript("OnLeave", function(self) GameTooltip:Hide() end);
	MinimapButton:SetScript("OnClick", function(self, button) BattlegroundTargets:Frame_Toggle(GVAR.OptionsFrame); end);
	MinimapButton:SetScript("OnDragStart", function(self) self:LockHighlight(); self:SetScript("OnUpdate", DragMinimapButton); end);
	MinimapButton:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil); self:UnlockHighlight(); end);
	
	MoveMinimapButton();
end

function BattlegroundTargets:SetupLayout()
	if(inCombat or InCombatLockdown()) then
		reCheckBG = true;
		reSetLayout = true;
		
		return;
	end
	
	local LayoutTH = BattlegroundTargets_Options.LayoutTH[currentSize];
	local LayoutSpace = BattlegroundTargets_Options.LayoutSpace[currentSize];
	
	if(currentSize == 10) then
		for i = 1, currentSize do
			if(LayoutTH == 81) then
				if(i == 6) then
					GVAR.TargetButton[i]:SetPoint("TOPLEFT", GVAR.TargetButton[1], "TOPRIGHT", LayoutSpace, 0);
				elseif(i > 1) then
					GVAR.TargetButton[i]:SetPoint("TOPLEFT", GVAR.TargetButton[(i-1)], "BOTTOMLEFT", 0, 0);
				end
			elseif(LayoutTH == 18) then
				if(i > 1) then
					GVAR.TargetButton[i]:SetPoint("TOPLEFT", GVAR.TargetButton[(i-1)], "BOTTOMLEFT", 0, 0);
				end
			end
		end
	elseif(currentSize == 15) then
		for i = 1, currentSize do
			if(LayoutTH == 81) then
				if(i == 6) then
					GVAR.TargetButton[i]:SetPoint("TOPLEFT", GVAR.TargetButton[1], "TOPRIGHT", LayoutSpace, 0);
				elseif(i == 11) then
					GVAR.TargetButton[i]:SetPoint("TOPLEFT", GVAR.TargetButton[6], "TOPRIGHT", LayoutSpace, 0);
				elseif(i > 1) then
					GVAR.TargetButton[i]:SetPoint("TOPLEFT", GVAR.TargetButton[(i-1)], "BOTTOMLEFT", 0, 0);
				end
			elseif(LayoutTH == 18) then
				if(i > 1) then
					GVAR.TargetButton[i]:SetPoint("TOPLEFT", GVAR.TargetButton[(i-1)], "BOTTOMLEFT", 0, 0);
				end
			end
		end
	elseif(currentSize == 40) then
		for i = 1, currentSize do
			if(LayoutTH == 81) then
				if (i == 6) then
					GVAR.TargetButton[i]:SetPoint("TOPLEFT", GVAR.TargetButton[1], "TOPRIGHT", LayoutSpace, 0);
				elseif (i == 11) then
					GVAR.TargetButton[i]:SetPoint("TOPLEFT", GVAR.TargetButton[6], "TOPRIGHT", LayoutSpace, 0);
				elseif (i == 16) then
					GVAR.TargetButton[i]:SetPoint("TOPLEFT", GVAR.TargetButton[11], "TOPRIGHT", LayoutSpace, 0);
				elseif (i == 21) then
					GVAR.TargetButton[i]:SetPoint("TOPLEFT", GVAR.TargetButton[16], "TOPRIGHT", LayoutSpace, 0);
				elseif (i == 26) then
					GVAR.TargetButton[i]:SetPoint("TOPLEFT", GVAR.TargetButton[21], "TOPRIGHT", LayoutSpace, 0);
				elseif (i == 31) then
					GVAR.TargetButton[i]:SetPoint("TOPLEFT", GVAR.TargetButton[26], "TOPRIGHT", LayoutSpace, 0);
				elseif (i == 36) then
					GVAR.TargetButton[i]:SetPoint("TOPLEFT", GVAR.TargetButton[31], "TOPRIGHT", LayoutSpace, 0);
				elseif (i > 1) then
					GVAR.TargetButton[i]:SetPoint("TOPLEFT", GVAR.TargetButton[(i-1)], "BOTTOMLEFT", 0, 0);
				end
			elseif(LayoutTH == 42) then
				if (i == 11) then
					GVAR.TargetButton[i]:SetPoint("TOPLEFT", GVAR.TargetButton[1], "TOPRIGHT", LayoutSpace, 0);
				elseif(i == 21) then
					GVAR.TargetButton[i]:SetPoint("TOPLEFT", GVAR.TargetButton[11], "TOPRIGHT", LayoutSpace, 0);
				elseif(i == 31) then
					GVAR.TargetButton[i]:SetPoint("TOPLEFT", GVAR.TargetButton[21], "TOPRIGHT", LayoutSpace, 0);
				elseif(i > 1) then
					GVAR.TargetButton[i]:SetPoint("TOPLEFT", GVAR.TargetButton[(i-1)], "BOTTOMLEFT", 0, 0);
				end
			elseif(LayoutTH == 24) then
				if(i == 21) then
					GVAR.TargetButton[i]:SetPoint("TOPLEFT", GVAR.TargetButton[1], "TOPRIGHT", LayoutSpace, 0);
				elseif(i > 1) then
					GVAR.TargetButton[i]:SetPoint("TOPLEFT", GVAR.TargetButton[(i-1)], "BOTTOMLEFT", 0, 0);
				end
			elseif(LayoutTH == 18) then
				if(i > 1) then
					GVAR.TargetButton[i]:SetPoint("TOPLEFT", GVAR.TargetButton[(i-1)], "BOTTOMLEFT", 0, 0);
				end
			end
		end
	end
end

function BattlegroundTargets:SetupButtonLayout()
	if(inCombat or InCombatLockdown()) then
		reCheckBG = true;
		reSetLayout = true;
		
		return;
	end
	BattlegroundTargets:SetupLayout()
	
	local ButtonScale           = OPT.ButtonScale[currentSize];
	local ButtonWidth           = OPT.ButtonWidth[currentSize];
	local ButtonHeight          = OPT.ButtonHeight[currentSize];
	local ButtonFontSize        = OPT.ButtonFontSize[currentSize];
	local ButtonClassIcon       = OPT.ButtonClassIcon[currentSize];
	local ButtonRoleLayoutPos   = OPT.ButtonRoleLayoutPos[currentSize];
	local ButtonShowTargetCount = OPT.ButtonShowTargetCount[currentSize];
	local ButtonShowTarget      = OPT.ButtonShowTarget[currentSize];
	local ButtonTargetScale     = OPT.ButtonTargetScale[currentSize];
	local ButtonTargetPosition  = OPT.ButtonTargetPosition[currentSize];
	local ButtonShowFocus       = OPT.ButtonShowFocus[currentSize];
	local ButtonFocusScale      = OPT.ButtonFocusScale[currentSize];
	local ButtonFocusPosition   = OPT.ButtonFocusPosition[currentSize];
	local ButtonShowFlag        = OPT.ButtonShowFlag[currentSize];
	local ButtonFlagScale       = OPT.ButtonFlagScale[currentSize];
	local ButtonFlagPosition    = OPT.ButtonFlagPosition[currentSize];
	local ButtonShowAssist      = OPT.ButtonShowAssist[currentSize];
	local ButtonAssistScale     = OPT.ButtonAssistScale[currentSize];
	local ButtonAssistPosition  = OPT.ButtonAssistPosition[currentSize];
	local ButtonRangeCheck      = OPT.ButtonRangeCheck[currentSize];
	local ButtonRangeDisplay    = OPT.ButtonRangeDisplay[currentSize];
	local ButtonShowHealer      = OPT.ButtonShowHealer[currentSize];

	local LayoutTH    = BattlegroundTargets_Options.LayoutTH[currentSize];
	local LayoutSpace = BattlegroundTargets_Options.LayoutSpace[currentSize];

	local TargetIcon = BattlegroundTargets_Options.TargetIcon;

	local ButtonWidth_2  = ButtonWidth - 2;
	local ButtonHeight_2 = ButtonHeight - 2;

	local backfallFontSize = ButtonFontSize;
	if(ButtonHeight < ButtonFontSize) then
		backfallFontSize = ButtonHeight;
	end
	
	local withIconWidth;
	
	local iconNum = 0; 
	if ButtonClassIcon and ButtonShowHealer then iconNum = 2;
	elseif ButtonShowHealer or ButtonClassIcon then iconNum = 1 end
	
	if(ButtonRangeCheck and ButtonRangeDisplay < 9) then
		withIconWidth = (ButtonWidth - ( (ButtonHeight_2 * iconNum) + (ButtonHeight_2 / 2) ) ) - 2;
	else
		withIconWidth = (ButtonWidth - (ButtonHeight_2 * iconNum)) - 2;
	end

	for i = 1, currentSize do
		local GVAR_TargetButton = GVAR.TargetButton[i];
		
		local lvl = GVAR_TargetButton:GetFrameLevel();
		GVAR_TargetButton.HealthTextButton:SetFrameLevel(lvl + 2);
		GVAR_TargetButton.TargetTextureButton:SetFrameLevel(lvl + 3);
		GVAR_TargetButton.AssistTextureButton:SetFrameLevel(lvl + 4);
		GVAR_TargetButton.FocusTextureButton:SetFrameLevel(lvl + 5);
		GVAR_TargetButton.FlagTextureButton:SetFrameLevel(lvl + 6);
		
		GVAR_TargetButton:SetScale(ButtonScale);
		
		GVAR_TargetButton:SetWidth(ButtonWidth);
		GVAR_TargetButton:SetHeight(ButtonHeight);
		GVAR_TargetButton.HighlightT:SetWidth(ButtonWidth);
		GVAR_TargetButton.HighlightR:SetHeight(ButtonHeight);
		GVAR_TargetButton.HighlightB:SetWidth(ButtonWidth);
		GVAR_TargetButton.HighlightL:SetHeight(ButtonHeight);
		GVAR_TargetButton.Background:SetWidth(ButtonWidth_2);
		GVAR_TargetButton.Background:SetHeight(ButtonHeight_2);
		
		if(ButtonRangeCheck and ButtonRangeDisplay < 9) then
			GVAR_TargetButton.RangeTexture:Show();
			GVAR_TargetButton.RangeTexture:SetWidth(ButtonHeight_2/2);
			GVAR_TargetButton.RangeTexture:SetHeight(ButtonHeight_2);
		else
			GVAR_TargetButton.RangeTexture:Hide();
		end
		
		GVAR_TargetButton.ClassTexture:SetWidth(ButtonHeight_2);
		GVAR_TargetButton.ClassTexture:SetHeight(ButtonHeight_2);

		GVAR_TargetButton.LeaderTexture:SetWidth(ButtonHeight_2 / 1.5);
		GVAR_TargetButton.LeaderTexture:SetHeight(ButtonHeight_2 / 1.5);
		GVAR_TargetButton.LeaderTexture:ClearAllPoints()
		GVAR_TargetButton.LeaderTexture:SetPoint("LEFT", GVAR_TargetButton, "LEFT", -(ButtonHeight_2 / 1.5) / 2, 0)

		GVAR_TargetButton.ClassColorBackground:SetHeight(ButtonHeight_2);
		GVAR_TargetButton.HealthBar:SetHeight(ButtonHeight_2);

		GVAR_TargetButton.HealersTexture:ClearAllPoints();

		if OPT.ButtonRoleLayoutPos[currentSize] == 2 then
			
			GVAR_TargetButton.HealersTexture:SetWidth(ButtonHeight_2);
			GVAR_TargetButton.HealersTexture:SetHeight(ButtonHeight_2);

			if(ButtonShowHealer) then
				if(ButtonRangeCheck and ButtonRangeDisplay < 9) then
					GVAR_TargetButton.HealersTexture:SetPoint("LEFT", GVAR_TargetButton.RangeTexture, "RIGHT", 0, 0);
				else
					GVAR_TargetButton.HealersTexture:SetPoint("LEFT", GVAR_TargetButton, "LEFT", 1, 0);
				end
				
				GVAR_TargetButton.ClassColorBackground:SetPoint("LEFT", GVAR_TargetButton.HealersTexture, "RIGHT", 0, 0);
			end
	
			if(ButtonClassIcon) then
				GVAR_TargetButton.ClassTexture:Show();
	
				if ButtonShowHealer then
					GVAR_TargetButton.ClassTexture:SetPoint("LEFT", GVAR_TargetButton.HealersTexture, "RIGHT", 0, 0);
					GVAR_TargetButton.ClassColorBackground:SetPoint("LEFT", GVAR_TargetButton.ClassTexture, "RIGHT", 0, 0);
				else
					if(ButtonRangeCheck and ButtonRangeDisplay < 9) then
						GVAR_TargetButton.ClassTexture:SetPoint("LEFT", GVAR_TargetButton.RangeTexture, "RIGHT", 0, 0);
					else
						GVAR_TargetButton.ClassTexture:SetPoint("LEFT", GVAR_TargetButton, "LEFT", 1, 0);
					end
	
					GVAR_TargetButton.ClassColorBackground:SetPoint("LEFT", GVAR_TargetButton.ClassTexture, "RIGHT", 0, 0);
				end
			
			else
				GVAR_TargetButton.ClassTexture:Hide();
			end
	
			if not ButtonShowHealer and not ButtonClassIcon then
				if(ButtonRangeCheck and ButtonRangeDisplay < 9) then
					GVAR_TargetButton.ClassColorBackground:SetPoint("LEFT", GVAR_TargetButton.RangeTexture, "RIGHT", 0, 0);
				else
					GVAR_TargetButton.ClassColorBackground:SetPoint("LEFT", GVAR_TargetButton, "LEFT", 1, 0);
				end
			end

		elseif OPT.ButtonRoleLayoutPos[currentSize] == 1 or OPT.ButtonRoleLayoutPos[currentSize] == 3 then

			if(ButtonClassIcon) then
				GVAR_TargetButton.ClassTexture:Show();

				if(ButtonRangeCheck and ButtonRangeDisplay < 9) then
					GVAR_TargetButton.ClassTexture:SetPoint("LEFT", GVAR_TargetButton.RangeTexture, "RIGHT", 0, 0);
				else
					GVAR_TargetButton.ClassTexture:SetPoint("LEFT", GVAR_TargetButton, "LEFT", 1, 0);
				end
				
				GVAR_TargetButton.ClassColorBackground:SetPoint("LEFT", GVAR_TargetButton.ClassTexture, "RIGHT", 0, 0);
			else
				GVAR_TargetButton.ClassTexture:Hide();
				
				if(ButtonRangeCheck and ButtonRangeDisplay < 9) then
					GVAR_TargetButton.ClassColorBackground:SetPoint("LEFT", GVAR_TargetButton.RangeTexture, "RIGHT", 0, 0);
				else
					GVAR_TargetButton.ClassColorBackground:SetPoint("LEFT", GVAR_TargetButton, "LEFT", 1, 0);
				end
			end
		
		end
		
		GVAR_TargetButton.Name:SetFont(fontPath, ButtonFontSize, "");
		GVAR_TargetButton.Name:SetShadowOffset(0, 0);
		GVAR_TargetButton.Name:SetShadowColor(0, 0, 0, 0);
		GVAR_TargetButton.Name:SetTextColor(0, 0, 0, 1);
		GVAR_TargetButton.Name:SetHeight(backfallFontSize);
		
		GVAR_TargetButton.HealthText:SetFont(fontPath, ButtonFontSize, "OUTLINE");
		GVAR_TargetButton.HealthText:SetShadowOffset(0, 0);
		GVAR_TargetButton.HealthText:SetShadowColor(0, 0, 0, 0);
		GVAR_TargetButton.HealthText:SetTextColor(1, 1, 1, 1);
		GVAR_TargetButton.HealthText:SetHeight(backfallFontSize);
		GVAR_TargetButton.HealthText:SetAlpha(0.6);

		if(ButtonShowTargetCount) then
			healthBarWidth = withIconWidth - 20;
			
			GVAR_TargetButton.ClassColorBackground:SetWidth(withIconWidth - 20);
			GVAR_TargetButton.HealthBar:SetWidth(withIconWidth - 20);

			if OPT.ButtonRoleLayoutPos[currentSize] == 1 then
				GVAR_TargetButton.HealersTexture:SetPoint("RIGHT", GVAR_TargetButton.TargetCountBackground, -OPT.ButtonHeight[currentSize], 0);
			end

			GVAR_TargetButton.Name:SetPoint("LEFT", GVAR_TargetButton.ClassColorBackground, "LEFT", 2, 0);
			GVAR_TargetButton.Name:SetWidth(withIconWidth - 20 - 2);
			GVAR_TargetButton.TargetCountBackground:SetHeight(ButtonHeight_2);
			GVAR_TargetButton.TargetCountBackground:Show();
			GVAR_TargetButton.TargetCount:SetFont(fontPath, ButtonFontSize, "");
			GVAR_TargetButton.TargetCount:SetShadowOffset(0, 0);
			GVAR_TargetButton.TargetCount:SetShadowColor(0, 0, 0, 0);
			GVAR_TargetButton.TargetCount:SetHeight(backfallFontSize);
			GVAR_TargetButton.TargetCount:SetTextColor(1, 1, 1, 1);
			GVAR_TargetButton.TargetCount:SetText("");
			GVAR_TargetButton.TargetCount:Show();

			
		else
			healthBarWidth = withIconWidth;
			
			GVAR_TargetButton.ClassColorBackground:SetWidth(withIconWidth);
			GVAR_TargetButton.HealthBar:SetWidth(withIconWidth);

			if OPT.ButtonRoleLayoutPos[currentSize] == 1 then
				GVAR_TargetButton.HealersTexture:SetPoint("RIGHT", GVAR_TargetButton.TargetCountBackground, 2, 0);
			end
			GVAR_TargetButton.Name:SetPoint("LEFT", GVAR_TargetButton.ClassColorBackground, "LEFT", 2, 0);
			GVAR_TargetButton.Name:SetWidth(withIconWidth - 2);
			
			GVAR_TargetButton.TargetCountBackground:Hide();
			GVAR_TargetButton.TargetCount:Hide();
		end

		if(ButtonShowTarget) then
			if(TargetIcon == "default") then
				GVAR_TargetButton.TargetTexture:SetTexture("Interface\\AddOns\\BattlegroundTargets\\Textures\\Target");
			else
				GVAR_TargetButton.TargetTexture:SetTexture(AddonIcon);
			end
			
			local quad = ButtonHeight_2 * ButtonTargetScale;
			local leftPos = -quad;
			
			GVAR_TargetButton.TargetTexture:SetWidth(quad);
			GVAR_TargetButton.TargetTexture:SetHeight(quad);
			
			if(ButtonTargetPosition >= 100) then
				leftPos = ButtonWidth;
			elseif(ButtonTargetPosition > 0) then
				leftPos = ((quad + ButtonWidth) * (ButtonTargetPosition / 100) ) - quad;
			end
			
			GVAR_TargetButton.TargetTexture:SetPoint("LEFT", GVAR_TargetButton, "LEFT", leftPos, 0);
			GVAR_TargetButton.TargetTexture:Show();
		else
			GVAR_TargetButton.TargetTexture:Hide();
		end

		if(ButtonShowFocus) then
			local quad = ButtonHeight_2 * ButtonFocusScale;
			local leftPos = -quad;
			
			GVAR_TargetButton.FocusTexture:SetWidth(quad);
			GVAR_TargetButton.FocusTexture:SetHeight(quad);
			
			if(ButtonFocusPosition >= 100) then
				leftPos = ButtonWidth;
			elseif(ButtonFocusPosition > 0) then
				leftPos = ( (quad + ButtonWidth) * (ButtonFocusPosition/100) ) - quad;
			end
			
			GVAR_TargetButton.FocusTexture:SetPoint("LEFT", GVAR_TargetButton, "LEFT", leftPos, 0);
			GVAR_TargetButton.FocusTexture:Show();
		else
			GVAR_TargetButton.FocusTexture:Hide();
		end
		
		if(ButtonShowFlag) then
			local quad = ButtonHeight_2 * ButtonFlagScale;
			local leftPos = -quad;
			
			GVAR_TargetButton.FlagTexture:SetWidth(quad);
			GVAR_TargetButton.FlagTexture:SetHeight(quad);
			
			if(ButtonFlagPosition >= 100) then
				leftPos = ButtonWidth
			elseif(ButtonFlagPosition > 0) then
				leftPos = ((quad + ButtonWidth) * (ButtonFlagPosition / 100)) - quad;
			end
			
			GVAR_TargetButton.FlagTexture:SetPoint("LEFT", GVAR_TargetButton, "LEFT", leftPos, 0);
			GVAR_TargetButton.FlagTexture:Show();
		else
			GVAR_TargetButton.FlagTexture:Hide();
		end
		
		if(ButtonShowAssist) then
			local quad = ButtonHeight_2 * ButtonAssistScale;
			local leftPos = -quad;
			
			GVAR_TargetButton.AssistTexture:SetWidth(quad);
			GVAR_TargetButton.AssistTexture:SetHeight(quad);
			
			if(ButtonAssistPosition >= 100) then
				leftPos = ButtonWidth;
			elseif(ButtonAssistPosition > 0) then
				leftPos = ( (quad + ButtonWidth) * (ButtonAssistPosition/100) ) - quad;
			end
			
			GVAR_TargetButton.AssistTexture:SetPoint("LEFT", GVAR_TargetButton, "LEFT", leftPos, 0);
			GVAR_TargetButton.AssistTexture:Show();
		else
			GVAR_TargetButton.AssistTexture:Hide();
		end
	end
	
	reSetLayout = false;
end

function BattlegroundTargets:Frame_Toggle(frame, show)
	if(show) then
		frame:Show();
	else
		if(frame:IsShown()) then
			frame:Hide();
		else
			frame:Show();
		end
	end
end

function BattlegroundTargets:Frame_SetupPosition(frameName)
	if(frameName == "BattlegroundTargets_MainFrame") then
		if(BattlegroundTargets_Options.IndependentPositioning[currentSize] and BattlegroundTargets_Options.pos[frameName..currentSize.."_posX"]) then
			_G[frameName]:ClearAllPoints();
			_G[frameName]:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", BattlegroundTargets_Options.pos[frameName..currentSize.."_posX"], BattlegroundTargets_Options.pos[frameName..currentSize.."_posY"]);
		elseif(BattlegroundTargets_Options.pos[frameName.."_posX"]) then
			_G[frameName]:ClearAllPoints();
			_G[frameName]:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", BattlegroundTargets_Options.pos[frameName.."_posX"], BattlegroundTargets_Options.pos[frameName.."_posY"]);
		else
			_G[frameName]:ClearAllPoints();
			_G[frameName]:SetPoint("TOPRIGHT", GVAR.OptionsFrame, "TOPLEFT", -80, 19);
			BattlegroundTargets_Options.pos[frameName.."_posX"] = _G[frameName]:GetLeft();
			BattlegroundTargets_Options.pos[frameName.."_posY"] = _G[frameName]:GetTop();
			_G[frameName]:ClearAllPoints();
			_G[frameName]:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", BattlegroundTargets_Options.pos[frameName.."_posX"], BattlegroundTargets_Options.pos[frameName.."_posY"]);
		end
	elseif(frameName == "BattlegroundTargets_OptionsFrame") then
		if(BattlegroundTargets_Options.pos[frameName.."_posX"]) then
			_G[frameName]:ClearAllPoints();
			_G[frameName]:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", BattlegroundTargets_Options.pos[frameName.."_posX"], BattlegroundTargets_Options.pos[frameName.."_posY"]);
		else
			_G[frameName]:ClearAllPoints();
			_G[frameName]:SetPoint("CENTER", UIParent, "CENTER", 0, 50);
		end
	end
end

function BattlegroundTargets:Frame_SavePosition(frameName)
	local x,y;
	
	if(frameName == "BattlegroundTargets_MainFrame" and BattlegroundTargets_Options.IndependentPositioning[currentSize]) then
		x = frameName..currentSize.."_posX";
		y = frameName..currentSize.."_posY";
	else
		x = frameName.."_posX";
		y = frameName.."_posY";
	end
	
	BattlegroundTargets_Options.pos[x] = _G[frameName]:GetLeft();
	BattlegroundTargets_Options.pos[y] = _G[frameName]:GetTop();
	_G[frameName]:ClearAllPoints();
	_G[frameName]:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", BattlegroundTargets_Options.pos[x], BattlegroundTargets_Options.pos[y]);
end

function BattlegroundTargets:MainFrameShow()
	if(inCombat or InCombatLockdown()) then return; end
	
	BattlegroundTargets:Frame_SetupPosition("BattlegroundTargets_MainFrame");
end

function BattlegroundTargets:OptionsFrameHide()
	PlaySound("igQuestListClose");
	isConfig = false;
	testDataLoaded = false;
	TEMPLATE.EnableTextButton(GVAR.InterfaceOptions.CONFIG, 1);
	BattlegroundTargets:DisableConfigMode();
end

function BattlegroundTargets:OptionsFrameShow()
	PlaySound("igQuestListOpen");
	isConfig = true;
	TEMPLATE.DisableTextButton(GVAR.InterfaceOptions.CONFIG);
	BattlegroundTargets:Frame_SetupPosition("BattlegroundTargets_OptionsFrame");
	GVAR.OptionsFrame:StartMoving();
	GVAR.OptionsFrame:StopMovingOrSizing();
	
	if(inBattleground) then
		testSize = currentSize;
	end
	
	GVAR.OptionsFrame.ConfigGeneral:Hide();
	GVAR.OptionsFrame.ConfigBrackets:Show();
	
	if(testSize == 10) then
		TEMPLATE.SetTabButton(GVAR.OptionsFrame.TabGeneral, nil);
		TEMPLATE.SetTabButton(GVAR.OptionsFrame.TabRaidSize10, true);
		TEMPLATE.SetTabButton(GVAR.OptionsFrame.TabRaidSize15, nil);
		TEMPLATE.SetTabButton(GVAR.OptionsFrame.TabRaidSize40, nil);
	elseif(testSize == 15) then
		TEMPLATE.SetTabButton(GVAR.OptionsFrame.TabGeneral, nil);
		TEMPLATE.SetTabButton(GVAR.OptionsFrame.TabRaidSize10, nil);
		TEMPLATE.SetTabButton(GVAR.OptionsFrame.TabRaidSize15, true);
		TEMPLATE.SetTabButton(GVAR.OptionsFrame.TabRaidSize40, nil);
	elseif(testSize == 40) then
		TEMPLATE.SetTabButton(GVAR.OptionsFrame.TabGeneral, nil);
		TEMPLATE.SetTabButton(GVAR.OptionsFrame.TabRaidSize10, nil);
		TEMPLATE.SetTabButton(GVAR.OptionsFrame.TabRaidSize15, nil);
		TEMPLATE.SetTabButton(GVAR.OptionsFrame.TabRaidSize40, true);
	end
	
	if(inCombat or InCombatLockdown()) then
		BattlegroundTargets:DisableInsecureConfigWidges();
	else
		BattlegroundTargets:EnableInsecureConfigWidges();
	end
	
	if(BattlegroundTargets_Options.EnableBracket[testSize]) then
		BattlegroundTargets:EnableConfigMode();
	else
		BattlegroundTargets:DisableConfigMode();
	end
end

function BattlegroundTargets:EnableConfigMode()
	if(inCombat or InCombatLockdown()) then
		reCheckBG = true;
		reSetLayout = true;
		
		return;
	end
	
	if(not testDataLoaded) then
		table_wipe(ENEMY_Data);

		ENEMY_Data[1]  = { name = "TargetAa-Realm1", classToken = "DRUID" }
		ENEMY_Data[2]  = { name = "TargetBb-Realm2", classToken = "PRIEST" }
		ENEMY_Data[3]  = { name = "TargetCc-Realm3", classToken = "MAGE" }
		ENEMY_Data[4]  = { name = "TargetDd-Realm4", classToken = "HUNTER" }
		ENEMY_Data[5]  = { name = "TargetEe-Realm3", classToken = "WARRIOR" }
		ENEMY_Data[6]  = { name = "TargetFf-Realm2", classToken = "ROGUE" }
		ENEMY_Data[7]  = { name = "TargetGg-Realm1", classToken = "SHAMAN" }
		ENEMY_Data[8]  = { name = "TargetHh-Realm2", classToken = "PALADIN" } 
		ENEMY_Data[9]  = { name = "TargetIi-Realm1", classToken = "PRIEST" }
		ENEMY_Data[10] = { name = "TargetJj-Realm4", classToken = "DEATHKNIGHT" }
		ENEMY_Data[11] = { name = "TargetKk-Realm3", classToken = "DRUID" }
		ENEMY_Data[12] = { name = "TargetLl-Realm3", classToken = "DEATHKNIGHT" }
		ENEMY_Data[13] = { name = "TargetMm-Realm1", classToken = "PALADIN" }
		ENEMY_Data[14] = { name = "TargetNn-Realm2", classToken = "MAGE" }
		ENEMY_Data[15] = { name = "TargetOo-Realm3", classToken = "SHAMAN" }
		ENEMY_Data[16] = { name = "TargetPp-Realm4", classToken = "ROGUE" }
		ENEMY_Data[17] = { name = "TargetQq-Realm3", classToken = "WARLOCK" }
		ENEMY_Data[18] = { name = "TargetRr-Realm2", classToken = "PRIEST" }
		ENEMY_Data[19] = { name = "TargetSs-Realm1", classToken = "WARRIOR" }
		ENEMY_Data[20] = { name = "TargetTt-Realm2", classToken = "DRUID" } 
		ENEMY_Data[21] = { name = "TargetUu-Realm3", classToken = "PRIEST" } 
		ENEMY_Data[22] = { name = "TargetVv-Realm4", classToken = "MAGE" } 
		ENEMY_Data[23] = { name = "TargetWw-Realm3", classToken = "SHAMAN" }
		ENEMY_Data[24] = { name = "TargetXx-Realm2", classToken = "HUNTER" }
		ENEMY_Data[25] = { name = "TargetYy-Realm1", classToken = "SHAMAN" } 
		ENEMY_Data[26] = { name = "TargetZz-Realm2", classToken = "WARLOCK" }
		ENEMY_Data[27] = { name = "TargetAb-Realm3", classToken = "PRIEST" }
		ENEMY_Data[28] = { name = "TargetCd-Realm4", classToken = "DRUID" } 
		ENEMY_Data[29] = { name = "TargetEf-Realm3", classToken = "ROGUE" }
		ENEMY_Data[30] = { name = "TargetGh-Realm2", classToken = "DRUID" } 
		ENEMY_Data[31] = { name = "TargetIj-Realm1", classToken = "HUNTER" }
		ENEMY_Data[32] = { name = "TargetKl-Realm2", classToken = "WARRIOR" }
		ENEMY_Data[33] = { name = "TargetMn-Realm3", classToken = "PALADIN" }
		ENEMY_Data[34] = { name = "TargetOp-Realm4", classToken = "MAGE" } 
		ENEMY_Data[35] = { name = "TargetQr-Realm3", classToken = "DEATHKNIGHT" }
		ENEMY_Data[36] = { name = "TargetSt-Realm2", classToken = "MAGE" }
		ENEMY_Data[37] = { name = "TargetUv-Realm1", classToken = "HUNTER" }
		ENEMY_Data[38] = { name = "TargetWx-Realm2", classToken = "WARLOCK" }
		ENEMY_Data[39] = { name = "TargetYz-Realm3", classToken = "WARLOCK" }
		ENEMY_Data[40] = { name = "TargetZx-Realm4", classToken = "ROGUE"  }
 
		testHealers["TargetUu-Realm3"] = { class = "PRIEST" , status = 0 } 
		testHealers["TargetIi-Realm1"] = { class = "PRIEST" , status = 1 }
		testHealers["TargetRr-Realm2"] = { class = "PRIEST" , status = 1 } 
		testHealers["TargetBb-Realm2"] = { class = "PRIEST" , status = 1 }
		testHealers["TargetAb-Realm3"] = { class = "PRIEST" , status = 2 } 
		testHealers["TargetMm-Realm1"] = { class = "PALADIN", status = 0 }
		testHealers["TargetHh-Realm2"] = { class = "PALADIN", status = 0 }
		testHealers["TargetMn-Realm3"] = { class = "PALADIN", status = 2 } 
		testHealers["TargetYy-Realm1"] = { class = "SHAMAN" , status = 0 } 
		testHealers["TargetGg-Realm1"] = { class = "SHAMAN" , status = 1 }
		testHealers["TargetWw-Realm3"] = { class = "SHAMAN" , status = 1 }
		testHealers["TargetOo-Realm3"] = { class = "SHAMAN" , status = 2 } 
		testHealers["TargetAa-Realm1"] = { class = "DRUID"  , status = 0 }
		testHealers["TargetKk-Realm3"] = { class = "DRUID"  , status = 0 }
		testHealers["TargetTt-Realm2"] = { class = "DRUID"  , status = 1 } 
		testHealers["TargetCd-Realm4"] = { class = "DRUID"  , status = 2 } 
		testHealers["TargetGh-Realm2"] = { class = "DRUID"  , status = 1 } 

		testDataLoaded = true;
	end
	
	currentSize = testSize;
	BattlegroundTargets:Frame_SetupPosition("BattlegroundTargets_MainFrame");
	BattlegroundTargets:SetOptions();
	
	GVAR.MainFrame:Show();
	GVAR.MainFrame:EnableMouse(true);
	GVAR.MainFrame:SetHeight(20);
	GVAR.MainFrame.Movetext:Show();
	GVAR.TargetButton[1]:SetPoint("TOPLEFT", GVAR.MainFrame, "BOTTOMLEFT", 0, 0);
	GVAR.ScoreUpdateTexture:Hide();
	
	BattlegroundTargets:ShufflerFunc("ShuffleCheck");
	BattlegroundTargets:SetupButtonLayout();
	BattlegroundTargets:MainDataUpdate();
	BattlegroundTargets:SetConfigButtonValues();

	for i = 1, 40 do
		if(i < currentSize + 1) then
			GVAR.TargetButton[i]:Show();
		else
			GVAR.TargetButton[i]:Hide();
		end
	end

	BattlegroundTargets:ScoreWarningCheck();
end


function BattlegroundTargets:DisableConfigMode()
	if(inCombat or InCombatLockdown()) then
		reCheckBG = true;
		reSetLayout = true;
		
		return;
	end

	currentSize = testSize;
	BattlegroundTargets:SetOptions();

	GVAR.MainFrame:Hide();
	
	for i = 1, 40 do
		GVAR.TargetButton[i]:Hide();
	end
	
	isTarget = 0;

	BattlegroundTargets:BattlefieldCheck();

	if(not inBattleground) then return; end

	BattlegroundTargets:CheckPlayerTarget();
	BattlegroundTargets:CheckAssist();
	BattlegroundTargets:CheckPlayerFocus();

	if(OPT.ButtonRangeCheck[currentSize]) then
		BattlegroundTargets:UpdateRange(GetTime());
	end

	if(OPT.ButtonShowFlag[currentSize]) then
		if(hasFlag) then
			local Name2Button = ENEMY_Name2Button[hasFlag];
			
			if(Name2Button) then
				local GVAR_TargetButton = GVAR.TargetButton[Name2Button];
				
				if(GVAR_TargetButton) then
					GVAR_TargetButton.FlagTexture:SetAlpha(1);
				end
			end
		end
	else
		BattlegroundTargets:CheckFlagCarrierEND();
	end

	if(OPT.ButtonShowLeader[currentSize]) then
		if(isLeader) then
			local Name2Button = ENEMY_Name2Button[isLeader];
			
			if(Name2Button) then
				local GVAR_TargetButton = GVAR.TargetButton[Name2Button];
				
				if(GVAR_TargetButton) then
					GVAR_TargetButton.LeaderTexture:SetAlpha(0.75);
				end
			end
		end
	end
	
	BattlegroundTargets:ScoreWarningCheck();
end

function BattlegroundTargets:ScoreWarningCheck()
	if(not inBattleground) then return; end
	
	local wssf = WorldStateScoreFrame;
	
	if(wssf and wssf:IsShown()) then
		if(BattlegroundTargets_Options.EnableBracket[currentSize]) then
			if(wssf.selectedTab and wssf.selectedTab > 1) then
				GVAR.WorldStateScoreWarning:Show();
			else
				GVAR.WorldStateScoreWarning:Hide();
			end
		else
			GVAR.WorldStateScoreWarning:Hide();
		end
	end
end

function BattlegroundTargets:SetConfigButtonValues()
	local ButtonShowHealthBar  = OPT.ButtonShowHealthBar[currentSize];
	local ButtonShowHealthText = OPT.ButtonShowHealthText[currentSize];
	local ButtonRangeCheck     = OPT.ButtonRangeCheck[currentSize];
	local ButtonRangeDisplay   = OPT.ButtonRangeDisplay[currentSize];
	local ButtonShowHealers    = OPT.ButtonShowHealer[currentSize];

	for i = 1, currentSize do
		local GVAR_TargetButton = GVAR.TargetButton[i];
		
		GVAR_TargetButton.TargetTexture:SetAlpha(0);
		GVAR_TargetButton.HighlightT:SetTexture(0, 0, 0, 1);
		GVAR_TargetButton.HighlightR:SetTexture(0, 0, 0, 1);
		GVAR_TargetButton.HighlightB:SetTexture(0, 0, 0, 1);
		GVAR_TargetButton.HighlightL:SetTexture(0, 0, 0, 1);
		GVAR_TargetButton.TargetCount:SetText("0");
		GVAR_TargetButton.FocusTexture:SetAlpha(0);
		GVAR_TargetButton.FlagTexture:SetAlpha(0);
		GVAR_TargetButton.AssistTexture:SetAlpha(0);
		GVAR_TargetButton.LeaderTexture:SetAlpha(0);
		GVAR_TargetButton.HealersTexture:SetAlpha(0);
		
		if(ButtonShowHealthBar) then
			local width = healthBarWidth * (testHealth[i] / 100);
			
			width = math_max(0.01, width);
			width = math_min(healthBarWidth, width);
			GVAR_TargetButton.HealthBar:SetWidth(width);
		else
			GVAR_TargetButton.HealthBar:SetWidth(healthBarWidth);
		end
		
		if(ButtonShowHealthText) then
			GVAR_TargetButton.HealthText:SetText(testHealth[i]);
		else
			GVAR_TargetButton.HealthText:SetText("");
		end
		
		local healerState = ButtonShowHealers and true;

		if(ButtonRangeCheck) then
			if(testRange[i] < 40) then
				Range_Display(true, GVAR_TargetButton, ButtonRangeDisplay, healerState);
			else
				Range_Display(false, GVAR_TargetButton, ButtonRangeDisplay, healerState);
			end
		else
			Range_Display(true, GVAR_TargetButton, ButtonRangeDisplay, healerState);
		end
		
		if(OPT.ButtonShowHealer[currentSize]) then
			local status = battleFieldRoleIcons[1];
			if (contains(HEALER_SpellBase["Healers"], ENEMY_Data[i].classToken)) then
				local qname = ENEMY_Data[i].name;
				if testHealers[qname] then
					status = battleFieldRoleIcons[testHealers[qname].status];
				end
			end
			GVAR_TargetButton.HealersTexture:SetTexture(status);
		end
	end
	
	isTarget = 0;
	
	if(OPT.ButtonShowTarget[currentSize]) then
		local GVAR_TargetButton = GVAR.TargetButton[testIcon1];
		
		GVAR_TargetButton.TargetTexture:SetAlpha(1);
		GVAR_TargetButton.HighlightT:SetTexture(0.5, 0.5, 0.5, 1);
		GVAR_TargetButton.HighlightR:SetTexture(0.5, 0.5, 0.5, 1);
		GVAR_TargetButton.HighlightB:SetTexture(0.5, 0.5, 0.5, 1);
		GVAR_TargetButton.HighlightL:SetTexture(0.5, 0.5, 0.5, 1);
		isTarget = testIcon1;
	end
	
	if(OPT.ButtonShowFocus[currentSize]) then
		GVAR.TargetButton[testIcon2].FocusTexture:SetAlpha(1);
	end
	
	if(OPT.ButtonShowFlag[currentSize]) then
		if(currentSize == 10 or currentSize == 15) then
			GVAR.TargetButton[testIcon3].FlagTexture:SetAlpha(1);
		end
	end
	
	if(OPT.ButtonShowAssist[currentSize]) then
		GVAR.TargetButton[testIcon4].AssistTexture:SetAlpha(1);
	end
	
	if(OPT.ButtonShowLeader[currentSize]) then
		GVAR.TargetButton[testLeader].LeaderTexture:SetAlpha(0.75);
	end
end

function BattlegroundTargets:ClearConfigButtonValues(GVAR_TargetButton, clearRange)
	GVAR_TargetButton.colR = 0;
	GVAR_TargetButton.colG = 0;
	GVAR_TargetButton.colB = 0;
	GVAR_TargetButton.colR5 = 0;
	GVAR_TargetButton.colG5 = 0;
	GVAR_TargetButton.colB5 = 0;
	
	GVAR_TargetButton.TargetTexture:SetAlpha(0);
	GVAR_TargetButton.HighlightT:SetTexture(0, 0, 0, 0.6);
	GVAR_TargetButton.HighlightR:SetTexture(0, 0, 0, 0.6);
	GVAR_TargetButton.HighlightB:SetTexture(0, 0, 0, 0.6);
	GVAR_TargetButton.HighlightL:SetTexture(0, 0, 0, 0.6);
	GVAR_TargetButton.TargetCount:SetText("");
	GVAR_TargetButton.FocusTexture:SetAlpha(0);
	GVAR_TargetButton.FlagTexture:SetAlpha(0);
	GVAR_TargetButton.AssistTexture:SetAlpha(0);
	GVAR_TargetButton.LeaderTexture:SetAlpha(0);
	GVAR_TargetButton.HealersTexture:SetTexture(0, 0, 0, 0);
	
	GVAR_TargetButton.HealthBar:SetTexture(0, 0, 0, 0);
	GVAR_TargetButton.HealthBar:SetWidth(healthBarWidth);
	GVAR_TargetButton.HealthText:SetText("");
	
	GVAR_TargetButton.RangeTexture:SetTexture(0, 0, 0, 0);
	
	GVAR_TargetButton.Name:SetText("");
	GVAR_TargetButton.ClassTexture:SetTexCoord(0, 0, 0, 0);
	GVAR_TargetButton.ClassColorBackground:SetTexture(0, 0, 0, 0);
	local healerState = OPT.ButtonShowHealer[currentSize] and true;

	if clearRange then
		Range_Display(false, GVAR_TargetButton, OPT.ButtonRangeDisplay[currentSize], healerState);
	end
end

function BattlegroundTargets:DefaultShuffle()
	for i = 1, 40 do
		testHealth[i] = math_random(0, 100);
		testRange[i]  = math_random(0, 100);
	end
	
	testIcon1 = math_random(1, 10);
	testIcon2 = math_random(1, 10);
	testIcon3 = math_random(1, 10);
	testIcon4 = math_random(1, 10);
	testLeader = math_random(1, 10);
end

function BattlegroundTargets:ShufflerFunc(what)
	if(what == "OnLeave") then
		GVAR.OptionsFrame:SetScript("OnUpdate", nil);
		GVAR.OptionsFrame.TestShuffler.Texture:SetWidth(32);
		GVAR.OptionsFrame.TestShuffler.Texture:SetHeight(32);
		GVAR.OptionsFrame.TestShuffler.TextureHighlight:SetWidth(32);
		GVAR.OptionsFrame.TestShuffler.TextureHighlight:SetHeight(32);
	elseif(what == "OnEnter") then
		BattlegroundTargets.elapsed = 1;
		BattlegroundTargets.progBit = true;
		
		if(not BattlegroundTargets.progNum) then BattlegroundTargets.progNum = 0; end
		if(not BattlegroundTargets.progMod) then BattlegroundTargets.progMod = 0; end
		
		GVAR.OptionsFrame:SetScript("OnUpdate", function(self, elap)
			if(inCombat) then GVAR.OptionsFrame:SetScript("OnUpdate", nil); return; end
			
			BattlegroundTargets.elapsed = BattlegroundTargets.elapsed + elap;
			
			if(BattlegroundTargets.elapsed < 0.4) then return; end
			
			BattlegroundTargets.elapsed = 0;
			BattlegroundTargets:Shuffle(BattlegroundTargets.shuffleStyle);
		end);
	elseif(what == "OnClick") then
		GVAR.OptionsFrame.TestShuffler.Texture:SetWidth(32);
		GVAR.OptionsFrame.TestShuffler.Texture:SetHeight(32);
		GVAR.OptionsFrame.TestShuffler.TextureHighlight:SetWidth(32);
		GVAR.OptionsFrame.TestShuffler.TextureHighlight:SetHeight(32);
		BattlegroundTargets.shuffleStyle = not BattlegroundTargets.shuffleStyle;
		
		if(BattlegroundTargets.shuffleStyle) then
			GVAR.OptionsFrame.TestShuffler.Texture:SetTexture("Interface\\Icons\\INV_Sigil_Thorim");
		else
			GVAR.OptionsFrame.TestShuffler.Texture:SetTexture("Interface\\Icons\\INV_Sigil_Mimiron");
		end
	elseif(what == "OnMouseDown") then
		GVAR.OptionsFrame.TestShuffler.Texture:SetWidth(30);
		GVAR.OptionsFrame.TestShuffler.Texture:SetHeight(30);
		GVAR.OptionsFrame.TestShuffler.TextureHighlight:SetWidth(30);
		GVAR.OptionsFrame.TestShuffler.TextureHighlight:SetHeight(30);
	elseif(what == "ShuffleCheck") then
		local num = 0;
		
		if(OPT.ButtonShowLeader[currentSize]) then num = num + 1; end
		if(OPT.ButtonShowTarget[currentSize]) then num = num + 1; end
		if(OPT.ButtonShowFocus[currentSize]) then num = num + 1; end
		if(OPT.ButtonShowFlag[currentSize]) then num = num + 1; end
		if(OPT.ButtonShowAssist[currentSize]) then num = num + 1; end
		if(OPT.ButtonShowHealthBar[currentSize]) then num = num + 1; end
		if(OPT.ButtonShowHealthText[currentSize]) then num = num + 1; end
		if(OPT.ButtonRangeCheck[currentSize]) then num = num + 1; end
		
		if(num > 0) then
			GVAR.OptionsFrame.TestShuffler:Show();
		else
			GVAR.OptionsFrame.TestShuffler:Hide();
		end
	end
end

function BattlegroundTargets:Shuffle(shuffleStyle)
	BattlegroundTargets.progBit = not BattlegroundTargets.progBit;
	
	if(BattlegroundTargets.progBit) then
		GVAR.OptionsFrame.TestShuffler.TextureHighlight:SetAlpha(0);
	else
		GVAR.OptionsFrame.TestShuffler.TextureHighlight:SetAlpha(0.5);
	end	

	if(shuffleStyle) then
		BattlegroundTargets:DefaultShuffle();
	else
		if(BattlegroundTargets.progMod == 0) then
			BattlegroundTargets.progNum = BattlegroundTargets.progNum + 1;
		else
			BattlegroundTargets.progNum = BattlegroundTargets.progNum - 1;
		end
		
		if(BattlegroundTargets.progNum >= 10) then
			BattlegroundTargets.progNum = 10;
			BattlegroundTargets.progMod = 1;
		elseif(BattlegroundTargets.progNum <= 1) then
			BattlegroundTargets.progNum = 1;
			BattlegroundTargets.progMod = 0;
		end
		
		testIcon1 = BattlegroundTargets.progNum;
		testIcon2 = BattlegroundTargets.progNum;
		testIcon3 = BattlegroundTargets.progNum;
		testIcon4 = BattlegroundTargets.progNum;
		testLeader = BattlegroundTargets.progNum;
		
		local num = BattlegroundTargets.progNum * 10;
		
		for i = 1, 40 do
			testHealth[i] = num;
			testRange[i] = 100;
		end
		
		testRange[BattlegroundTargets.progNum] = 30;
	end
	
	BattlegroundTargets:SetConfigButtonValues();
end

function BattlegroundTargets:CopySettings(sourceSize)
	local destinationSize = 10;
	
	if(sourceSize == 10) then
		destinationSize = 15;
	end

	BattlegroundTargets_Options.LayoutTH[destinationSize] = BattlegroundTargets_Options.LayoutTH[sourceSize];
	BattlegroundTargets_Options.LayoutSpace[destinationSize] = BattlegroundTargets_Options.LayoutSpace[sourceSize];
	
	BattlegroundTargets_Options.ButtonClassIcon[destinationSize] = BattlegroundTargets_Options.ButtonClassIcon[sourceSize];
	OPT.ButtonClassIcon[destinationSize] = OPT.ButtonClassIcon[sourceSize];
	BattlegroundTargets_Options.ButtonRoleLayoutPos[destinationSize] = BattlegroundTargets_Options.ButtonRoleLayoutPos[sourceSize];
	OPT.ButtonRoleLayoutPos[destinationSize] = OPT.ButtonRoleLayoutPos[sourceSize];
	BattlegroundTargets_Options.ButtonShowLeader[destinationSize] = BattlegroundTargets_Options.ButtonShowLeader[sourceSize];
	OPT.ButtonShowLeader[destinationSize] = OPT.ButtonShowLeader[sourceSize];
	BattlegroundTargets_Options.ButtonHideRealm[destinationSize] = BattlegroundTargets_Options.ButtonHideRealm[sourceSize];
	OPT.ButtonHideRealm[destinationSize] = OPT.ButtonHideRealm[sourceSize];
	BattlegroundTargets_Options.ButtonShowTarget[destinationSize] = BattlegroundTargets_Options.ButtonShowTarget[sourceSize];
	OPT.ButtonShowTarget[destinationSize]  = OPT.ButtonShowTarget[sourceSize];
	BattlegroundTargets_Options.ButtonTargetScale[destinationSize] = BattlegroundTargets_Options.ButtonTargetScale[sourceSize];
	OPT.ButtonTargetScale[destinationSize] = OPT.ButtonTargetScale[sourceSize];
	BattlegroundTargets_Options.ButtonTargetPosition[destinationSize] = BattlegroundTargets_Options.ButtonTargetPosition[sourceSize];
	OPT.ButtonTargetPosition[destinationSize] = OPT.ButtonTargetPosition[sourceSize];
	BattlegroundTargets_Options.ButtonShowTargetCount[destinationSize] = BattlegroundTargets_Options.ButtonShowTargetCount[sourceSize];
	OPT.ButtonShowTargetCount[destinationSize] = OPT.ButtonShowTargetCount[sourceSize];
	BattlegroundTargets_Options.ButtonShowFocus[destinationSize] = BattlegroundTargets_Options.ButtonShowFocus[sourceSize];
	OPT.ButtonShowFocus[destinationSize] = OPT.ButtonShowFocus[sourceSize];
	BattlegroundTargets_Options.ButtonFocusScale[destinationSize] = BattlegroundTargets_Options.ButtonFocusScale[sourceSize];
	OPT.ButtonFocusScale[destinationSize] = OPT.ButtonFocusScale[sourceSize];
	BattlegroundTargets_Options.ButtonFocusPosition[destinationSize] = BattlegroundTargets_Options.ButtonFocusPosition[sourceSize];
	OPT.ButtonFocusPosition[destinationSize] = OPT.ButtonFocusPosition[sourceSize];
	BattlegroundTargets_Options.ButtonShowFlag[destinationSize] = BattlegroundTargets_Options.ButtonShowFlag[sourceSize];
	OPT.ButtonShowFlag[destinationSize]  = OPT.ButtonShowFlag[sourceSize];
	BattlegroundTargets_Options.ButtonFlagScale[destinationSize] = BattlegroundTargets_Options.ButtonFlagScale[sourceSize];
	OPT.ButtonFlagScale[destinationSize] = OPT.ButtonFlagScale[sourceSize];
	BattlegroundTargets_Options.ButtonFlagPosition[destinationSize] = BattlegroundTargets_Options.ButtonFlagPosition[sourceSize];
	OPT.ButtonFlagPosition[destinationSize] = OPT.ButtonFlagPosition[sourceSize];
	BattlegroundTargets_Options.ButtonShowAssist[destinationSize] = BattlegroundTargets_Options.ButtonShowAssist[sourceSize];
	OPT.ButtonShowAssist[destinationSize] = OPT.ButtonShowAssist[sourceSize];
	BattlegroundTargets_Options.ButtonAssistScale[destinationSize] = BattlegroundTargets_Options.ButtonAssistScale[sourceSize];
	OPT.ButtonAssistScale[destinationSize] = OPT.ButtonAssistScale[sourceSize];
	BattlegroundTargets_Options.ButtonAssistPosition[destinationSize] = BattlegroundTargets_Options.ButtonAssistPosition[sourceSize];
	OPT.ButtonAssistPosition[destinationSize] = OPT.ButtonAssistPosition[sourceSize];
	BattlegroundTargets_Options.ButtonShowHealthBar[destinationSize] = BattlegroundTargets_Options.ButtonShowHealthBar[sourceSize];
	OPT.ButtonShowHealthBar[destinationSize] = OPT.ButtonShowHealthBar[sourceSize];
	BattlegroundTargets_Options.ButtonShowHealthText[destinationSize] = BattlegroundTargets_Options.ButtonShowHealthText[sourceSize];
	OPT.ButtonShowHealthText[destinationSize] = OPT.ButtonShowHealthText[sourceSize];
	BattlegroundTargets_Options.ButtonRangeCheck[destinationSize] = BattlegroundTargets_Options.ButtonRangeCheck[sourceSize];
	OPT.ButtonRangeCheck[destinationSize] = OPT.ButtonRangeCheck[sourceSize];
	BattlegroundTargets_Options.ButtonTypeRangeCheck[destinationSize] = BattlegroundTargets_Options.ButtonTypeRangeCheck[sourceSize];
	OPT.ButtonTypeRangeCheck[destinationSize] = OPT.ButtonTypeRangeCheck[sourceSize];
	BattlegroundTargets_Options.ButtonRangeDisplay[destinationSize] = BattlegroundTargets_Options.ButtonRangeDisplay[sourceSize];
	OPT.ButtonRangeDisplay[destinationSize] = OPT.ButtonRangeDisplay[sourceSize];
	BattlegroundTargets_Options.ButtonSortBy[destinationSize] = BattlegroundTargets_Options.ButtonSortBy[sourceSize];
	OPT.ButtonSortBy[destinationSize]  = OPT.ButtonSortBy[sourceSize];
	BattlegroundTargets_Options.ButtonSortDetail[destinationSize] = BattlegroundTargets_Options.ButtonSortDetail[sourceSize];
	OPT.ButtonSortDetail[destinationSize] = OPT.ButtonSortDetail[sourceSize];
	BattlegroundTargets_Options.ButtonFontSize[destinationSize] = BattlegroundTargets_Options.ButtonFontSize[sourceSize];
	OPT.ButtonFontSize[destinationSize] = OPT.ButtonFontSize[sourceSize];
	BattlegroundTargets_Options.ButtonScale[destinationSize] = BattlegroundTargets_Options.ButtonScale[sourceSize];
	OPT.ButtonScale[destinationSize] = OPT.ButtonScale[sourceSize];
	BattlegroundTargets_Options.ButtonWidth[destinationSize] = BattlegroundTargets_Options.ButtonWidth[sourceSize];
	OPT.ButtonWidth[destinationSize] = OPT.ButtonWidth[sourceSize];
	BattlegroundTargets_Options.ButtonHeight[destinationSize] = BattlegroundTargets_Options.ButtonHeight[sourceSize];
	OPT.ButtonHeight[destinationSize] = OPT.ButtonHeight[sourceSize];

	if(destinationSize == 10) then
		testSize = 10;
		
		TEMPLATE.SetTabButton(GVAR.OptionsFrame.TabRaidSize10, true);
		TEMPLATE.SetTabButton(GVAR.OptionsFrame.TabRaidSize15, nil);
		TEMPLATE.SetTabButton(GVAR.OptionsFrame.TabRaidSize40, nil);
		BattlegroundTargets:CheckForEnabledBracket(testSize);
		
		if(BattlegroundTargets_Options.EnableBracket[testSize]) then
			BattlegroundTargets:EnableConfigMode();
		else
			BattlegroundTargets:DisableConfigMode();
		end
	else
		testSize = 15;
		
		TEMPLATE.SetTabButton(GVAR.OptionsFrame.TabRaidSize10, nil);
		TEMPLATE.SetTabButton(GVAR.OptionsFrame.TabRaidSize15, true);
		TEMPLATE.SetTabButton(GVAR.OptionsFrame.TabRaidSize40, nil);
		BattlegroundTargets:CheckForEnabledBracket(testSize);
		
		if(BattlegroundTargets_Options.EnableBracket[testSize]) then
			BattlegroundTargets:EnableConfigMode();
		else
			BattlegroundTargets:DisableConfigMode();
		end
	end
end

local sortfunc13 = function(a, b) --  Class/Name | 13
	if(class_BlizzSort[ a.classToken ] == class_BlizzSort[ b.classToken ]) then
		if(a.name < b.name) then
			return true;
		end
	elseif(class_BlizzSort[ a.classToken ] < class_BlizzSort[ b.classToken ]) then
		return true;
	end
end

local sortfunc11 = function(a, b) -- Class/Name | 11
	if(class_LocaSort[ a.classToken ] == class_LocaSort[ b.classToken ]) then
		if(a.name < b.name) then
			return true;
		end
	elseif(class_LocaSort[ a.classToken ] < class_LocaSort[ b.classToken ]) then
		return true;
	end
end

local sortfunc12 = function(a, b) -- Class/Name | 12
	if(a.classToken == b.classToken) then
		if(a.name < b.name) then
			return true;
		end
	elseif a.classToken < b.classToken then
		return true;
	end
end

local sortfunc2 = function(a, b) -- Class/Name | 2
	if(a.name < b.name) then
		return true;
	end
end

local sortfunc33 = function(a, b) --  Class/Name | 33
	local Healers = isConfig and testHealers or ENEMY_Healers;
	local aStatus = Healers[a.name] and Healers[a.name].status or 1;
	local bStatus = Healers[b.name] and Healers[b.name].status or 1;

	if aStatus == bStatus then
		if(class_BlizzSort[ a.classToken ] == class_BlizzSort[ b.classToken ]) then
			if(a.name < b.name) then
				return true;
			end
		elseif(class_BlizzSort[ a.classToken ] < class_BlizzSort[ b.classToken ]) then
			return true;
		end
	elseif aStatus > bStatus then
		return true;
	end
end

----------------------------------------------------------
-- BG EVENT HANDLERS									--
----------------------------------------------------------
function BattlegroundTargets:MainDataUpdate()
	local ButtonSortBy = OPT.ButtonSortBy[currentSize];
	local ButtonSortDetail = OPT.ButtonSortDetail[currentSize];
	
	if ButtonSortBy == 1 then
		if ButtonSortDetail == 3 then
			table_sort(ENEMY_Data, sortfunc13); -- Class/Name | 13
		elseif ButtonSortDetail == 1 then
			table_sort(ENEMY_Data, sortfunc11); -- Class/Name | 11
		else
			table_sort(ENEMY_Data, sortfunc12); -- Class/Name | 12
		end
	elseif ButtonSortBy == 2 then
		table_sort(ENEMY_Data, sortfunc2); -- Name | 2

	elseif ButtonSortBy == 3 then -- Heals First + Class/Name
		table_sort(ENEMY_Data, sortfunc33); -- Heals First + Class/Name | 33
	end
	
	local ButtonClassIcon       = OPT.ButtonClassIcon[currentSize];
	local ButtonRoleLayoutPos   = OPT.ButtonRoleLayoutPos[currentSize];
	local ButtonShowLeader      = OPT.ButtonShowLeader[currentSize];
	local ButtonShowHealer      = OPT.ButtonShowHealer[currentSize]; 
	local ButtonHideRealm       = OPT.ButtonHideRealm[currentSize];
	local ButtonShowTargetCount = OPT.ButtonShowTargetCount[currentSize];
	local ButtonShowHealthBar   = OPT.ButtonShowHealthBar[currentSize];
	local ButtonShowHealthText  = OPT.ButtonShowHealthText[currentSize];
	local ButtonShowTarget      = OPT.ButtonShowTarget[currentSize];
	local ButtonShowFocus       = OPT.ButtonShowFocus[currentSize];
	local ButtonShowFlag        = OPT.ButtonShowFlag[currentSize];
	local ButtonShowAssist      = OPT.ButtonShowAssist[currentSize];
	local ButtonRangeCheck      = OPT.ButtonRangeCheck[currentSize];
	
	table_wipe(ENEMY_Name2Button);
	table_wipe(ENEMY_Names4Flag);

	for i = 1, currentSize do
		if ENEMY_Data[i] then
			local GVAR_TargetButton = GVAR.TargetButton[i];
			
			local qname       = ENEMY_Data[i].name
			local qclassToken = ENEMY_Data[i].classToken
			ENEMY_Name2Button[qname] = i;
			GVAR_TargetButton.buttonNum = i;
			
			local colR = classcolors[qclassToken].r;
			local colG = classcolors[qclassToken].g;
			local colB = classcolors[qclassToken].b;
			
			GVAR_TargetButton.colR = colR;
			GVAR_TargetButton.colG = colG;
			GVAR_TargetButton.colB = colB;
			GVAR_TargetButton.colR5 = colR*0.5;
			GVAR_TargetButton.colG5 = colG*0.5;
			GVAR_TargetButton.colB5 = colB*0.5;
			GVAR_TargetButton.ClassColorBackground:SetTexture(GVAR_TargetButton.colR5, GVAR_TargetButton.colG5, GVAR_TargetButton.colB5, 1);
			GVAR_TargetButton.HealthBar:SetTexture(colR, colG, colB, 1);
			
			local onlyname = qname;
			if(ButtonShowFlag or ButtonHideRealm) then
				if(string_find(qname, "-", 1, true)) then
					onlyname = string_match(qname, "(.-)%-(.*)$");
				end
				
				ENEMY_Names4Flag[onlyname] = i;
			end

			if(ButtonHideRealm) then
				if(isLowLevel) then
					GVAR_TargetButton.name4button = onlyname;
				end
				
				if(isLowLevel and ENEMY_Name2Level[qname]) then
					GVAR_TargetButton.Name:SetText(ENEMY_Name2Level[qname].." "..onlyname);
				else
					GVAR_TargetButton.Name:SetText(onlyname);
				end
			else
				if(isLowLevel) then
					GVAR_TargetButton.name4button = qname;
				end
				
				if(isLowLevel and ENEMY_Name2Level[qname]) then
					GVAR_TargetButton.Name:SetText(ENEMY_Name2Level[qname].." "..qname);
				else
					GVAR_TargetButton.Name:SetText(qname);
				end
			end
			
			if(not inCombat or not InCombatLockdown()) then
				GVAR_TargetButton:SetAttribute("macrotext1", "/targetexact "..qname);
				GVAR_TargetButton:SetAttribute("macrotext2", "/targetexact "..qname.."\n/focus\n/targetlasttarget");
			end
			
			if(ButtonRangeCheck) then
				GVAR_TargetButton.RangeTexture:SetTexture(colR, colG, colB, 1);
			end
			
			if(ButtonClassIcon) then
				GVAR_TargetButton.ClassTexture:SetTexCoord(classes[qclassToken][1], classes[qclassToken][2], classes[qclassToken][3], classes[qclassToken][4]);
			end
			
			local nameE = ENEMY_Names[qname];
			local percentE = ENEMY_Name2Percent[qname];
			
			if(ButtonShowTargetCount) then
				if(nameE) then
					GVAR_TargetButton.TargetCount:SetText(nameE);
				else
					GVAR_TargetButton.TargetCount:SetText("0");
				end
			end

			if(ButtonShowHealthBar or ButtonShowHealthText) then
				if(nameE and percentE) then
					if(ButtonShowHealthBar) then
						local width = healthBarWidth * (percentE / 100);
						
						width = math_max(0.01, width);
						width = math_min(healthBarWidth, width);
						GVAR_TargetButton.HealthBar:SetWidth(width);
					end
					
					if(ButtonShowHealthText) then
						GVAR_TargetButton.HealthText:SetText(percentE);
					end
				end
			end
			
			if(ButtonShowTarget and targetName) then
				if(qname == targetName) then
					GVAR_TargetButton.HighlightT:SetTexture(0.5, 0.5, 0.5, 1);
					GVAR_TargetButton.HighlightR:SetTexture(0.5, 0.5, 0.5, 1);
					GVAR_TargetButton.HighlightB:SetTexture(0.5, 0.5, 0.5, 1);
					GVAR_TargetButton.HighlightL:SetTexture(0.5, 0.5, 0.5, 1);
					GVAR_TargetButton.TargetTexture:SetAlpha(1);
				else
					GVAR_TargetButton.HighlightT:SetTexture(0, 0, 0, 1);
					GVAR_TargetButton.HighlightR:SetTexture(0, 0, 0, 1);
					GVAR_TargetButton.HighlightB:SetTexture(0, 0, 0, 1);
					GVAR_TargetButton.HighlightL:SetTexture(0, 0, 0, 1);
					GVAR_TargetButton.TargetTexture:SetAlpha(0);
				end
			end
			
			if(ButtonShowFocus and focusName) then
				if(qname == focusName) then
					GVAR_TargetButton.FocusTexture:SetAlpha(1);
				else
					GVAR_TargetButton.FocusTexture:SetAlpha(0);
				end
			end
			
			if(ButtonShowFlag and hasFlag) then
				if(qname == hasFlag) then
					GVAR_TargetButton.FlagTexture:SetAlpha(1);
				else
					GVAR_TargetButton.FlagTexture:SetAlpha(0);
				end
			end
			
			if(ButtonShowAssist and assistTargetName) then
				if(qname == assistTargetName) then
					GVAR_TargetButton.AssistTexture:SetAlpha(1);
				else
					GVAR_TargetButton.AssistTexture:SetAlpha(0);
				end
			end

			if(ButtonShowLeader and isLeader) then
				if(qname == isLeader) then
					GVAR_TargetButton.LeaderTexture:SetAlpha(0.75);
				else
					GVAR_TargetButton.LeaderTexture:SetAlpha(0);
				end
			end

			if(ButtonShowHealer) then
			
				BattlegroundTargets:initHealersTable(qname, qclassToken);

				local healerStatus = BattlegroundTargets:GetHealerStatus(qname, qclassToken);
				
				if not healerStatus then healerStatus = 0;
				elseif healerStatus == 3 then healerStatus = 2 end;
				GVAR_TargetButton.HealersTexture:SetTexture(battleFieldRoleIcons[healerStatus]);

			end
		else
			local GVAR_TargetButton = GVAR.TargetButton[i];
			
			BattlegroundTargets:ClearConfigButtonValues(GVAR_TargetButton);
			
			if(not inCombat or not InCombatLockdown()) then
				GVAR_TargetButton:SetAttribute("macrotext1", "");
				GVAR_TargetButton:SetAttribute("macrotext2", "");
			end
		end
	end
	
	if(isConfig) then
		if(isLowLevel) then
			for i = 1, currentSize do
				local GVAR_TargetButton = GVAR.TargetButton[i];
				
				GVAR_TargetButton.Name:SetText(playerLevel.." "..GVAR_TargetButton.name4button);
			end
		end
		
		return;
	end
	
	if(ButtonRangeCheck) then
		local curTime = GetTime();
		
		if(range_CL_DisplayThrottle + range_CL_DisplayFrequency > curTime) then return; end
		
		range_CL_DisplayThrottle = curTime;
		BattlegroundTargets:UpdateRange(curTime);
	end
end

function BattlegroundTargets:NameFactionToNumber(faction)
	if (faction == "Horde") then return 0;
	elseif (faction == "Alliance") then return 1 end;
end

function BattlegroundTargets:ValidateFactionBG(faction)
	BattlegroundTargets:CheckNativeFaction();
	if (faction == oppositeFactionBG) then 
		if (faction == 0) then
			oppositeFactionBG  = 1;
			playerFactionBG    = 0
		else
			oppositeFactionBG  = 0;
			playerFactionBG    = 1;
		end
	end

	BattlegroundTargets_Character.TempFaction = faction;
	
	icoMinimapFactionBG = battleFieldIconTextures[playerFactionBG];
	MiniMapBattlefieldIcon:SetTexture(icoMinimapFactionBG)
	MiniMapBattlefieldFrame:SetNormalTexture(icoMinimapFactionBG)

	factionIsValid = true;
end

function BattlegroundTargets:initHealersTable(name, class)
	if(isConfig) then return; end
	if not ENEMY_Healers[name] and contains(HEALER_SpellBase["Healers"], class) then
		ENEMY_Healers[name]          = {};
		ENEMY_Healers[name].status   = 0;
		ENEMY_Healers[name].class    = class;
		ENEMY_Healers[name].reason   = "UNKNOWN";
		ENEMY_Healers[name].tries    = 0; 
		ENEMY_Healers[name].DBstatus = 0; 
	end
end 

function BattlegroundTargets:CheckEnemyHealer(name, class, enemyID)
	if isConfig then return end
	if name and contains(HEALER_SpellBase["Healers"], class) then 
		BattlegroundTargets:initHealersTable(name, class)
		local status = ENEMY_Healers[name].status
		local reason
		if status == 0 or status == 3 then
			status, reason = BattlegroundTargets:GetHealerStatusByBuff(enemyID, name, class, status)
			if status == 1 or status == 2 then
				ENEMY_Healers[name].status = status
				ENEMY_Healers[name].reason = reason
			end
			ENEMY_Healers[name].tries  = ENEMY_Healers[name].tries + 1
		end	
		return status
	end
	return nil
end

local coloredLOG = {
	log    = "|cffffff7f[TARGET_SCAN_LOG]|r",
	reason = "|cfff4db49Reason:|r",
	name   = "|cfff4db49Name:|r",
	target = "|cfff4db49Target:|r",
	source = "|cfff4db49Source:|r",
	tries  = "|cfff4db49Tries:|r",
	dd     = "|cffff0000DD|r",
	heal   = "|cff55c912HEALER|r"
}

local function coloredClass(class)
	return "|cff"..ClassHexColor(class)..class.."|r";
end

function BattlegroundTargets:GetHealerStatusByBuff(enemyID, name, class, prevStatus)
	local i = 1
	local buffOwnerID, spellID
	local reason
	if class == "PALADIN" or class == "DRUID" then
		local maxpower = UnitPowerMax(enemyID, 0) -- Check Mana.
		if maxpower and maxpower ~= 0 then
			local tpl
			local status
			if class == "PALADIN" then
				status = tonumber(maxpower) > 16000 and 2 or 1
				tpl = status == 1 and coloredLOG.dd or coloredLOG.heal;
			else -- druid
				status = tonumber(maxpower) < 12000 and 1 or 0
				tpl = status == 1 and coloredLOG.dd
			end
			if status > 0 then
				HDLog(coloredLOG.log.." "..coloredClass(class).." "..tpl.." detected. "..coloredLOG.reason.." max-mana is "..maxpower, coloredLOG.name, name, coloredLOG.target, enemyID, coloredLOG.tries, ENEMY_Healers[name].tries+1,"\n\n")
				reason = "Max mana: "..maxpower
				return status, reason
			end
		else 
			return prevStatus
		end
	end
	local buff = UnitBuff(enemyID, i)
	while buff do
		buff,_,_,_,_,_,_,buffOwnerID,_,_,spellID = UnitBuff(enemyID, i)
		for _,val in ipairs(HEALER_SpellBase["HealerBuffs"]) do
			if GetSpellInfo(val) == buff then
				local owner = buffOwnerID or "-"
				HDLog(coloredLOG.log.." "..coloredClass(class).." "..coloredLOG.heal.." detected. "..coloredLOG.reason.." "..buff,val.." "..coloredLOG.name, name, coloredLOG.target, enemyID,"|cfff4db49OWNER:|r "..owner, coloredLOG.tries, ENEMY_Healers[name].tries+1,"\n\n")
				return 2, "buff: "..buff.." spellID: "..val
			end
		end
		for _, val in ipairs(HEALER_SpellBase["DamageBuffs"]) do
			if GetSpellInfo(val) == buff then
				local owner = buffOwnerID or "-"
				HDLog(coloredLOG.log.." "..coloredClass(class).." "..coloredLOG.dd.." detected. "..coloredLOG.reason.." "..buff,val.." "..coloredLOG.name, name, coloredLOG.target, enemyID,"|cfff4db49OWNER:|r "..owner, coloredLOG.tries, ENEMY_Healers[name].tries+1,"\n\n")
				return 1, "buff: "..buff.." spellID: "..val
			end
		end
		i = i + 1
	end;
	return prevStatus
end

function BattlegroundTargets:GetHealerStatus(name, class) 
	if(isConfig) then return; end
	local status = nil;
	local isHealerClass = contains(HEALER_SpellBase["Healers"], class);
	local DBisEnable = BattlegroundTargets_Options.DB and BattlegroundTargets_Options.DB.outOfDateRange and BattlegroundTargets_Options.DB.outOfDateRange > 0;
	if name then
		if isHealerClass and 
		ENEMY_Healers[name].status == 0 and ENEMY_Healers[name].DBstatus == 0 then 
			local sUnit = {}
			local isExists = false;
			sUnit.name  = name;
			sUnit.class = class;
			if DBisEnable then isExists = BattlegroundTargets_DBUtils:checkHealerDB(BattlegroundTargets_HealersDB, sUnit) end
			if isExists then
				ENEMY_Healers[name].status 	 = 3;
				ENEMY_Healers[name].reason 	 = "Received from the database";
				ENEMY_Healers[name].tries  	 = ENEMY_Healers[name].tries + 1;
				ENEMY_Healers[name].class  	 = class;
				ENEMY_Healers[name].DBstatus = 1;
				HDLog("[DB]: "..coloredClass(class), coloredLOG.heal, name.." was found in DB!")
			else 
				ENEMY_Healers[name].DBstatus = -1;
			end
		elseif not isHealerClass then
			status = 1;
		end
	end
	local rStatus = ENEMY_Healers[name]  and  ENEMY_Healers[name].status  or  status;
	return rStatus;
end

function BattlegroundTargets:DetectHealerByAOEBuffs(...)
	if isConfig or not inBattleground then return; end
	if OPT.ButtonShowHealer[currentSize] then
		local trackingEvents = {"SPELL_AURA_APPLIED", "SPELL_AURA_REMOVED", "SPELL_AURA_REFRESH"}
		local _,event,_,ownerName,_,_,targetName,_,spellID,spellName,_,spellType = ...;
		if contains(trackingEvents, event) then
			if ENEMY_Healers[ownerName] and (ENEMY_Healers[ownerName].status == 0 or ENEMY_Healers[ownerName].status == 3) then
				local successDetect;
				if contains(HEALER_SpellBase["aoeHealerBuffs"], spellID) or 
				   contains(HEALER_SpellBase["HealerBuffs"], spellID) then
						ENEMY_Healers[ownerName].status = 2;
						successDetect = true;
				elseif 
					contains(HEALER_SpellBase["aoeDamageBuffs"], spellID) or 
				    contains(HEALER_SpellBase["DamageBuffs"], spellID) then
						ENEMY_Healers[ownerName].status = 1;
						successDetect = true;
				end
				if successDetect then
					local tpl = ENEMY_Healers[ownerName].status == 1  and  coloredLOG.dd  or  coloredLOG.heal;
					ENEMY_Healers[ownerName].reason = spellType..": "..spellName.." spellID: "..spellID;
					ENEMY_Healers[ownerName].tries  = ENEMY_Healers[ownerName].tries  + 1;
					HDLog("[COMBAT_LOG] "..coloredClass(ENEMY_Healers[ownerName].class).." "..tpl.." detected. "..coloredLOG.reason.." "..spellName,spellID.." "..coloredLOG.name, ownerName, coloredLOG.tries, ENEMY_Healers[ownerName].tries,"\n\n")
				end
			end
		end 
	end
end

--------- Integrates CombatLog-based detection from BattleGroundHealers, by Khal ---------
function BattlegroundTargets:DetectHealerByBGH(name, class)
	if isConfig or not inBattleground then return end
	if not name or not class then return end
	BattlegroundTargets:initHealersTable(name, class)
	if ENEMY_Healers[name] and (ENEMY_Healers[name].status == 0 or ENEMY_Healers[name].status == 3) then
		ENEMY_Healers[name].status = 2
		ENEMY_Healers[name].reason = "BGH callback"
		ENEMY_Healers[name].tries  = ENEMY_Healers[name].tries + 1
		HDLog("[BGH] "..coloredClass(class).." "..coloredLOG.heal.." detected. "..coloredLOG.name, name, coloredLOG.reason, ENEMY_Healers[name].reason, coloredLOG.tries, ENEMY_Healers[name].tries, "\n\n")
	end
end

local function RegisterBGH_Notifier()
	if not BGH_Notifier then return end
	--Print("BGH loaded, detection method added.")
	BGH_Notifier.OnHealerDetected = function(name, class)
		BattlegroundTargets:DetectHealerByBGH(name, class)
	end
end
-------------------------------------------------------------------------------------------

function BattlegroundTargets:HDreport()
	local next = next;
	if next(ENEMY_Healers) then
		Print("\nHEALER DETECTION. REPORT:")
		local report   = {};
		report.healers = {};
		report.dd      = {};
		report.unk     = {};
		local report_title_HEALERS = "\n==================\n|cff55c912HEALERS|r DETECTED: \n";
		local report_title_DD      = "\n==================\n|cffff0000DD|r DETECTED: \n";
		local report_title_UNKNOWN = "\n==================\n|cff969696UNKNOWN|r ROLE: \n";
		for name, data in pairs(ENEMY_Healers) do
			if (type(data) == "table") then
				local str = "" 
				str  = str.."   NAME: "..name.."\n"
				str  = str.."      CLASS: "..coloredClass(data.class).."\n"
				str  = str.."      REASON: "..(data.reason or "... no data ...").."\n"
				str  = str.."      Total attempts to detect: "..data.tries.."\n"
				if data.status >= 2 then report.healers[name] = str;	
				elseif data.status == 1 then report.dd[name]  = str;
				elseif data.status == 0 then
					str = str.."      status: "..data.status.."\n";
					report.unk[name] = str;
				end
			end
		end
		for role, tbl in pairs(report) do
			if role == "healers"  and   next(report.healers)  then print(report_title_HEALERS);
			elseif role == "dd"   and   next(report.dd)       then print(report_title_DD);
			elseif role == "unk"  and   next(report.unk)      then print(report_title_UNKNOWN); end;
			for _, str in pairs(tbl) do print(str) end
		end
	end
end
----------------------------------------------------------

function BattlegroundTargets:BattlefieldScoreUpdate()
	if not factionIsValid then return end

	local curTime = GetTime();
	local diff = curTime - latestScoreUpdate;
	if(diff < 1) then return end

	local queueStatus, queueMapName, bgName;
	for i=1, MAX_BATTLEFIELD_QUEUES do
		queueStatus, queueMapName = GetBattlefieldStatus(i);
		if(queueStatus == "active") then
			bgName = BGN[queueMapName];
			break;
		end
	end

	if(inCombat or InCombatLockdown()) then
		if(curTime - latestScoreWarning) then
			GVAR.ScoreUpdateTexture:Show();
		else
			GVAR.ScoreUpdateTexture:Hide();
		end
		reCheckScore = true;
		return;
	end

	local wssf = WorldStateScoreFrame;
	if(wssf and wssf:IsShown() and wssf.selectedTab and wssf.selectedTab > 1) then return; end

	scoreUpdateCount = scoreUpdateCount + 1;
	if(scoreUpdateCount > 20) then
		scoreUpdateFrequency = 5;
	end
	reCheckScore = nil;
	latestScoreUpdate = curTime;
	GVAR.ScoreUpdateTexture:Hide();

	table_wipe(ENEMY_Data);
	table_wipe(FRIEND_Names);

	local x = 1;
	for index = 1, GetNumBattlefieldScores() do
		local name, _, _, _, _, iFaction, _, _, _, classToken = GetBattlefieldScore(index);
		
		if (name and name ~= playerName) then
			
			if (iFaction == oppositeFactionBG) then
				
				if (oppositeFactionREAL == nil and race) then
					local n = RNA[race];
					
					if (n == 0) then
						oppositeFactionREAL = n;
					elseif (n == 1) then
						oppositeFactionREAL = n;
					end
				end
				
				local class = "ZZZFAILURE";
				if (classToken) then
					class = classToken;
				end
				
				ENEMY_Data[x] = {};
				ENEMY_Data[x].name = name;
				ENEMY_Data[x].classToken = class;
				
				x = x + 1;

				if(not ENEMY_Names[name]) then
					ENEMY_Names[name] = 0;
				end
			else
				FRIEND_Names[name] = 1;
				
				local class = "ZZZFAILURE";
				if(classToken) then
					class = classToken;
				end
			end
		end
	end
	
	if(ENEMY_Data[1]) then
		BattlegroundTargets:MainDataUpdate();
		
		if(not flagflag and isFlagBG > 0) then
			if(OPT.ButtonShowFlag[currentSize]) then
				BattlegroundTargets:CheckFlagCarrierSTART();
			end
		end
	end
	
	if(reSizeCheck >= 10) then return; end
	
	if(bgName) then
		BattlegroundTargets:BattlefieldCheck();
	else
		local zone = GetRealZoneText();
		
		if BGN[zone] then
			BattlegroundTargets:BattlefieldCheck();
		else
			reSizeCheck = reSizeCheck + 1;
		end
	end
end

function BattlegroundTargets:CheckFlagCarrierCHECK(unit, targetName)
	if(not ENEMY_FirstFlagCheck[targetName]) then return; end
	for i = 1, 40 do
		local _,_,_,_,_,_,_,_,_,_,spellID = UnitBuff(unit, i);
		if(not spellID) then break; end
		if(flagIDs[spellID]) then
			hasFlag = targetName;
			for j = 1, currentSize do
				local GVAR_TargetButton = GVAR.TargetButton[j];
				
				GVAR_TargetButton.FlagTexture:SetAlpha(0);
			end
			local button = ENEMY_Name2Button[targetName];
			if(button) then
				local GVAR_TargetButton = GVAR.TargetButton[button];
				if(GVAR_TargetButton) then
					GVAR_TargetButton.FlagTexture:SetAlpha(1);
				end
			end
			BattlegroundTargets:CheckFlagCarrierEND();
			return;
		end
	end
	ENEMY_FirstFlagCheck[targetName] = nil;
	local x = 0;
	for k in pairs(ENEMY_FirstFlagCheck) do
		x = x + 1;
	end
	if(x == 0) then
		BattlegroundTargets:CheckFlagCarrierEND();
	end
end

function BattlegroundTargets:CheckFlagCarrierSTART()
	flagCHK = true;
	flagflag = true;
	table_wipe(ENEMY_FirstFlagCheck);
	for i = 1, #ENEMY_Data do
		ENEMY_FirstFlagCheck[ENEMY_Data[i].name] = 1;
	end
	for num = 1, GetNumRaidMembers() do
		local unitID = "raid"..num;
		for i = 1, 40 do
			local _,_,_,_,_,_,_,_,_,_,spellID = UnitBuff(unitID, i);
			if not spellID then break end
			if flagIDs[spellID] then return end
		end
	end
	BattlegroundTargets:RegisterEvent("UNIT_TARGET");
	BattlegroundTargets:RegisterEvent("UPDATE_MOUSEOVER_UNIT");
	BattlegroundTargets:RegisterEvent("PLAYER_TARGET_CHANGED");
end

function BattlegroundTargets:CheckFlagCarrierEND() -- FLAGSPY
	flagCHK = nil;
	flagflag = true;
	wipe(ENEMY_FirstFlagCheck);
	if not OPT.ButtonShowHealthBar[currentSize] and
	   not OPT.ButtonShowHealthText[currentSize] and
	   not OPT.ButtonShowTargetCount[currentSize] and
	   not OPT.ButtonShowAssist[currentSize] and
	   not OPT.ButtonShowLeader[currentSize] and
	   not OPT.ButtonShowHealer[currentSize] and
	   (not OPT.ButtonRangeCheck[currentSize] or OPT.ButtonTypeRangeCheck[currentSize] < 2) and
	   not isLowLevel -- LVLCHK
	then
		BattlegroundTargets:UnregisterEvent("UNIT_TARGET")
	end
	if not OPT.ButtonShowHealthBar[currentSize] and
	   not OPT.ButtonShowHealthText[currentSize] and
	   (not OPT.ButtonRangeCheck[currentSize] or OPT.ButtonTypeRangeCheck[currentSize] < 2)
	then
		BattlegroundTargets:UnregisterEvent("UPDATE_MOUSEOVER_UNIT")
	end
	if not OPT.ButtonShowTarget[currentSize] and
	   (not OPT.ButtonRangeCheck[currentSize] or OPT.ButtonTypeRangeCheck[currentSize] < 2) and 
	   not OPT.ButtonShowHealer[currentSize]
	then
		BattlegroundTargets:UnregisterEvent("PLAYER_TARGET_CHANGED")
	end
end

function BattlegroundTargets:BattlefieldCheck()
	if(not inWorld) then return; end
	local _, instanceType = IsInInstance();
	if instanceType == "pvp" then
		BattlegroundTargets:IsBattleground();
	else
		BattlegroundTargets:IsNotBattleground();
	end
end

function BattlegroundTargets:IsBattleground()
	inBattleground = true;
	isFlagBG = 0;
	if hdlog and not BattlegroundTargets_Options.hdlog then
		HDLog(L["Logging of healers detection is enabled.\nType |cff55c912/bgt hdlog|r again to disable."]);
	elseif not hdlog and BattlegroundTargets_Options.hdlog then
		HDLog(L["Permanent logging of healers detection is enabled. Type |cff55c912/bgt hdlogAlways|r again to disable."]);
	end

	local queueStatus, queueMapName, bgName;
	for i = 1, MAX_BATTLEFIELD_QUEUES do
		queueStatus, queueMapName = GetBattlefieldStatus(i);
		if(queueStatus == "active") then
			bgName = BGN[queueMapName]
			break
		end
	end
	if not bgName then
		bgName = BGN[GetRealZoneText()]
		if not bgName then
			SetMapToCurrentZone()
			bgName = BGNameByID[GetCurrentMapAreaID()]
			if not bgName then
				Print("ERROR: Unknown Battleground Name")
			end
		end
	end

	if not BattlegroundTargets_Character.TempFaction then
		local faction = BattlegroundTargets:NameFactionToNumber(BattlegroundTargets_Character.NativeFaction) or 1
		if bgName then
			-- Detects faction from starting coords to support any cross-faction system
			local rawx, rawy = GetPlayerMapPosition("player");
			if rawx and rawy then
				local rx, ry = GetRealCoords(rawx, rawy)
				if bgName == "Strand of the Ancients" then -- by Khal
					if select(2, GetWorldStateUIInfo(2)) == 0 then
						-- Ally Defending SotA
						if isSotaDefenderPosition(rx, ry) then
							faction = 1
						else
							faction = 0
						end
					else
						-- Ally Attacking SotA
						if isSotaDefenderPosition(rx, ry) then
							faction = 0
						else
							faction = 1
						end
					end
				else
					if isAllyStartPosition(rx, ry, bgName) then 	
						faction = 1
					else 
						faction = 0
					end
				end
			end
			if faction == 0 then
				Print(bgName, "- |cffcc1a1aHorde|r ")
			elseif faction == 1 then
				Print(bgName, "- |cff3060ffAlliance|r ")
			end
		end
		BattlegroundTargets:ValidateFactionBG(faction)
	else
		BattlegroundTargets:ValidateFactionBG(BattlegroundTargets_Character.TempFaction);
	end

	if bgName then
		currentSize = bgSize[bgName]
		reSizeCheck = 10
		local flagBGnum = flagBG[bgName]
		if flagBGnum then
			isFlagBG = flagBGnum
		end
	else
		currentSize = 10
		reSizeCheck = reSizeCheck + 1
	end
	
	if playerLevel >= maxLevel then
		isLowLevel = nil
	else
		isLowLevel = true
	end

	if(inCombat or InCombatLockdown()) then
		reCheckBG = true;
	else
		reCheckBG = false;
		if(BattlegroundTargets_Options.EnableBracket[currentSize]) then
			GVAR.MainFrame:Show();
			GVAR.MainFrame:EnableMouse(false);
			GVAR.MainFrame:SetHeight(0.001);
			GVAR.MainFrame.Movetext:Hide();
			GVAR.TargetButton[1]:SetPoint("TOPLEFT", GVAR.MainFrame, "BOTTOMLEFT", 0, -(20 / OPT.ButtonScale[currentSize]));
			GVAR.ScoreUpdateTexture:Hide();
			for i = 1, 40 do
				local GVAR_TargetButton = GVAR.TargetButton[i]
				if(i < currentSize + 1) then
					BattlegroundTargets:ClearConfigButtonValues(GVAR_TargetButton, 1);
					GVAR_TargetButton:Show();
				else
					GVAR_TargetButton:Hide();
				end
			end
			BattlegroundTargets:SetupButtonLayout();
			if(OPT.ButtonShowFlag[currentSize]) then
				if bgName == "Warsong Gulch" then
					local flagIcon;
					if(playerFactionBG == 0) then
						flagIcon = "Interface\\WorldStateFrame\\HordeFlag";
					else
						flagIcon = "Interface\\WorldStateFrame\\AllianceFlag";
					end
					for i = 1, currentSize do
						GVAR.TargetButton[i].FlagTexture:SetTexture(flagIcon);
					end
				elseif bgName == "Eye of the Storm" then
					local flagIcon;
					if(playerFactionBG == 0) then
						flagIcon = "Interface\\WorldStateFrame\\AllianceFlag";
					else
						flagIcon = "Interface\\WorldStateFrame\\HordeFlag";
					end
					for i = 1, currentSize do
						GVAR.TargetButton[i].FlagTexture:SetTexture(flagIcon);
					end					
				end
			end
		else
			GVAR.MainFrame:Hide();
			for i = 1, 40 do
				GVAR.TargetButton[i]:Hide();
			end
		end
	end
	
	BattlegroundTargets:UnregisterEvent("PLAYER_DEAD");
	BattlegroundTargets:UnregisterEvent("PLAYER_UNGHOST");
	BattlegroundTargets:UnregisterEvent("PLAYER_ALIVE");
	BattlegroundTargets:UnregisterEvent("UNIT_HEALTH_FREQUENT");
	BattlegroundTargets:UnregisterEvent("UPDATE_MOUSEOVER_UNIT");
	BattlegroundTargets:UnregisterEvent("UNIT_TARGET");
	BattlegroundTargets:UnregisterEvent("PLAYER_TARGET_CHANGED");
	BattlegroundTargets:UnregisterEvent("PLAYER_FOCUS_CHANGED");
	BattlegroundTargets:UnregisterEvent("CHAT_MSG_BG_SYSTEM_HORDE");
	BattlegroundTargets:UnregisterEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE");
	BattlegroundTargets:UnregisterEvent("RAID_ROSTER_UPDATE");
	BattlegroundTargets:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	BattlegroundTargets:UnregisterEvent("UPDATE_BATTLEFIELD_SCORE");
	
	if(BattlegroundTargets_Options.EnableBracket[currentSize]) then
		BattlegroundTargets:RegisterEvent("PLAYER_DEAD");
		BattlegroundTargets:RegisterEvent("PLAYER_UNGHOST");
		BattlegroundTargets:RegisterEvent("PLAYER_ALIVE");
		
		if(isLowLevel) then
			BattlegroundTargets:RegisterEvent("UNIT_TARGET");
		end
		
		if(OPT.ButtonShowHealthBar[currentSize] or OPT.ButtonShowHealthText[currentSize]) then
			BattlegroundTargets:RegisterEvent("UNIT_TARGET");
			BattlegroundTargets:RegisterEvent("UNIT_HEALTH_FREQUENT");
			BattlegroundTargets:RegisterEvent("UPDATE_MOUSEOVER_UNIT");
		end
		
		if(OPT.ButtonShowTargetCount[currentSize]) then
			BattlegroundTargets:RegisterEvent("UNIT_TARGET");
		end
		
		if(OPT.ButtonShowTarget[currentSize]) then
			BattlegroundTargets:RegisterEvent("PLAYER_TARGET_CHANGED");
		end

		if(OPT.ButtonShowFocus[currentSize]) then
			BattlegroundTargets:RegisterEvent("PLAYER_FOCUS_CHANGED");
		end

		if(OPT.ButtonShowFlag[currentSize]) then
			if(currentSize == 10 or currentSize == 15) then
				BattlegroundTargets:RegisterEvent("CHAT_MSG_BG_SYSTEM_HORDE");
				BattlegroundTargets:RegisterEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE");
			end
		end
		
		if(OPT.ButtonShowAssist[currentSize]) then
			BattlegroundTargets:RegisterEvent("RAID_ROSTER_UPDATE");
			BattlegroundTargets:RegisterEvent("UNIT_TARGET");
		end
		
		if OPT.ButtonShowLeader[currentSize] then
			BattlegroundTargets:RegisterEvent("UNIT_TARGET")
		end
		
		if OPT.ButtonShowHealer[currentSize] then
			BattlegroundTargets:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
			BattlegroundTargets:RegisterEvent("RAID_ROSTER_UPDATE");
			BattlegroundTargets:RegisterEvent("UNIT_TARGET");
			BattlegroundTargets:RegisterEvent("PLAYER_TARGET_CHANGED");
		end

		rangeSpellName = nil;
		rangeMin = nil;
		rangeMax = nil;
		
		if(OPT.ButtonRangeCheck[currentSize]) then
			if(OPT.ButtonTypeRangeCheck[currentSize] == 1) then
				BattlegroundTargets:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
			elseif(OPT.ButtonTypeRangeCheck[currentSize] >= 2) then
				if(ranges[playerClassEN]) then
					if(IsSpellKnown(ranges[playerClassEN])) then
						rangeSpellName, _, _, _, _, _, _, rangeMin, rangeMax = GetSpellInfo(ranges[playerClassEN]);
						if(not rangeSpellName) then
							Print("ERROR", "unknown spell (rangecheck)", locale, playerClassEN, "id:", ranges[playerClassEN]);
						elseif (not rangeMin or not rangeMax) or (rangeMin <= 0 and rangeMax <= 0) then
							Print("ERROR", "spell min/max fail (rangecheck)", locale, rangeSpellName, rangeMin, rangeMax);
						else
							BattlegroundTargets:RegisterEvent("UNIT_HEALTH_FREQUENT");
							BattlegroundTargets:RegisterEvent("UPDATE_MOUSEOVER_UNIT");
							BattlegroundTargets:RegisterEvent("PLAYER_TARGET_CHANGED");
							BattlegroundTargets:RegisterEvent("UNIT_TARGET");
							
							if(OPT.ButtonTypeRangeCheck[currentSize] >= 3) then
								BattlegroundTargets:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
							end
						end
					elseif playerClassEN == "PALADIN" and playerLevel < 14 then
						Print("WARNING", playerClassEN, "Required level for class-spell based rangecheck is 14.");
					elseif playerClassEN == "ROGUE" and playerLevel < 12 then
						Print("WARNING", playerClassEN, "Required level for class-spell based rangecheck is 12.");
					else
						Print("ERROR", "unknown spell (rangecheck)", locale, playerClassEN, "id:", ranges[playerClassEN]);
					end
				else
					Print("ERROR", "unknown class (rangecheck)", locale, playerClassEN);
				end
			end
		end
		
		BattlegroundTargets:RegisterEvent("UPDATE_BATTLEFIELD_SCORE");
		BattlegroundTargets:BattlefieldScoreRequest();
		
		local frequency = 1;   --   0-20 updates = 1 second
		local elapsed 	= 0 ;  --   21-60 updates = 2 seconds
		local count 	= 0;   --   61+   updates = 5 seconds
		
		GVAR.MainFrame:SetScript("OnUpdate", function(self, elap)
			elapsed = elapsed + elap;
			if(elapsed < frequency) then return; end
			
			elapsed = 0;
			if(count > 60) then
				frequency = 5;
			elseif(count > 20) then
				frequency = 2;
				count = count + 1;
			else
				count = count + 1;
			end
			
			BattlegroundTargets:BattlefieldScoreRequest();
		end);
	end
end

local function ResetBattlegroundFlags()
	reSizeCheck         = 0;
	oppositeFactionREAL = nil;
	isFlagBG            = 0;
	flagCHK             = nil;
	flagflag            = nil;
	scoreUpdateCount    = 0;
	isLeader            = nil;
	isHealer            = nil;
	hasFlag             = nil;
	reCheckBG           = nil;
	reCheckScore        = nil;
	factionIsValid      = false;
	icoMinimapFactionBG = nil;
	BattlegroundTargets_Character.TempFaction = nil;
end

function BattlegroundTargets:IsNotBattleground()
	if not (inBattleground or reCheckBG or BattlegroundTargets_Character.TempFaction) then return end
	inBattleground      = false;
	ResetBattlegroundFlags()
	local factionID = BattlegroundTargets:NameFactionToNumber(BattlegroundTargets_Character.NativeFaction);
	MiniMapBattlefieldIcon:SetTexture(battleFieldIconTextures[factionID])
	MiniMapBattlefieldFrame:SetNormalTexture(battleFieldIconTextures[factionID])
	if OPT.ButtonShowHealer[10] or OPT.ButtonShowHealer[15] or OPT.ButtonShowHealer[40] then
		if hdlog or BattlegroundTargets_Options.hdlog then BattlegroundTargets:HDreport() end;
		local DBisEnable = BattlegroundTargets_Options.DB and BattlegroundTargets_Options.DB.outOfDateRange and BattlegroundTargets_Options.DB.outOfDateRange > 0;
		if DBisEnable and next(ENEMY_Healers) then
			for name, data in pairs(ENEMY_Healers) do
				if (type(data) == "table") then
					if ENEMY_Healers[name].DBstatus <= 0 and ENEMY_Healers[name].status == 2 then 
						local unit = {};
						unit.name  = name;
						unit.class = data.class;
						DBUtils:insertNewUnit(BattlegroundTargets_HealersDB, unit)
					end

				end
			end
		end
	end

	BattlegroundTargets:CheckPlayerLevel();
	
	BattlegroundTargets:UnregisterEvent("PLAYER_DEAD");
	BattlegroundTargets:UnregisterEvent("PLAYER_UNGHOST");
	BattlegroundTargets:UnregisterEvent("PLAYER_ALIVE");
	BattlegroundTargets:UnregisterEvent("UNIT_HEALTH_FREQUENT");
	BattlegroundTargets:UnregisterEvent("UPDATE_MOUSEOVER_UNIT");
	BattlegroundTargets:UnregisterEvent("UNIT_TARGET");
	BattlegroundTargets:UnregisterEvent("PLAYER_TARGET_CHANGED");
	BattlegroundTargets:UnregisterEvent("PLAYER_FOCUS_CHANGED");
	BattlegroundTargets:UnregisterEvent("CHAT_MSG_BG_SYSTEM_HORDE");
	BattlegroundTargets:UnregisterEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE");
	BattlegroundTargets:UnregisterEvent("RAID_ROSTER_UPDATE");
	BattlegroundTargets:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	BattlegroundTargets:UnregisterEvent("UPDATE_BATTLEFIELD_SCORE");
	
	if(not isConfig) then
		table_wipe(ENEMY_Data);
	end
	
	table_wipe(ENEMY_Names);
	table_wipe(ENEMY_Names4Flag);
	table_wipe(ENEMY_Name2Button);
	table_wipe(ENEMY_Name2Percent);
	table_wipe(ENEMY_Name2Range);
	table_wipe(ENEMY_Name2Level);
	table_wipe(TARGET_Names);
	table_wipe(ENEMY_Healers);
	
	GVAR.MainFrame:SetScript("OnUpdate", nil);
	
	if(inCombat or InCombatLockdown()) then
		reCheckBG = true;
	else
		reCheckBG = false;
		GVAR.MainFrame:Hide();
		local flagIcon = "Interface\\WorldStateFrame\\AllianceFlag";
		if(playerFactionDEF == 0) then
			flagIcon = "Interface\\WorldStateFrame\\HordeFlag";
		end
		for i = 1, 40 do
			local GVAR_TargetButton = GVAR.TargetButton[i];
			GVAR_TargetButton.FlagTexture:SetTexture(flagIcon);
			GVAR_TargetButton:Hide();
		end
	end
end

function BattlegroundTargets:CheckPlayerTarget()
	if(isConfig) then return; end
	targetName, targetRealm = UnitName("target");
	if targetRealm and targetRealm ~= "" then
		targetName = targetName.."-"..targetRealm;
	end
	for i = 1, currentSize do
		local GVAR_TargetButton = GVAR.TargetButton[i];
		GVAR_TargetButton.TargetTexture:SetAlpha(0);
		GVAR_TargetButton.HighlightT:SetTexture(0, 0, 0, 1);
		GVAR_TargetButton.HighlightR:SetTexture(0, 0, 0, 1);
		GVAR_TargetButton.HighlightB:SetTexture(0, 0, 0, 1);
		GVAR_TargetButton.HighlightL:SetTexture(0, 0, 0, 1);
	end
	isTarget = 0;
	if(not targetName) then return; end
	local targetButton = ENEMY_Name2Button[targetName];
	if(not targetButton) then return; end
	local GVAR_TargetButton = GVAR.TargetButton[targetButton];
	if(not GVAR_TargetButton) then return; end
	if OPT.ButtonShowTarget[currentSize] then
		GVAR_TargetButton.TargetTexture:SetAlpha(1);
		GVAR_TargetButton.HighlightT:SetTexture(0.5, 0.5, 0.5, 1);
		GVAR_TargetButton.HighlightR:SetTexture(0.5, 0.5, 0.5, 1);
		GVAR_TargetButton.HighlightB:SetTexture(0.5, 0.5, 0.5, 1);
		GVAR_TargetButton.HighlightL:SetTexture(0.5, 0.5, 0.5, 1);
		isTarget = targetButton;
	end
	if(isDeadUpdateStop) then return; end
	BattlegroundTargets:CheckUnitTarget("player", targetName);
end

function BattlegroundTargets:CheckAssist()
	if(isConfig) then return; end
	isAssistUnitId = nil;
	isAssistName = nil;
	for i = 1, GetNumRaidMembers() do
		local name, _, _, _, _, _, _, _, _, role = GetRaidRosterInfo(i);
		if(name and role and role == "MAINASSIST") then
			isAssistName = name;
			isAssistUnitId = "raid"..i.."target";
			
			break;
		end
	end
	for i = 1, currentSize do
		GVAR.TargetButton[i].AssistTexture:SetAlpha(0);
	end
	if(not isAssistName) then return; end
	assistTargetName, assistTargetRealm = UnitName(isAssistUnitId);
	if(assistTargetRealm and assistTargetRealm ~= "") then
		assistTargetName = assistTargetName.."-"..assistTargetRealm;
	end
	if(not assistTargetName) then return; end
	local assistButton = ENEMY_Name2Button[assistTargetName];
	if(not assistButton) then return; end
	if(not GVAR.TargetButton[assistButton]) then return; end
	if(OPT.ButtonShowAssist[currentSize]) then
		GVAR.TargetButton[assistButton].AssistTexture:SetAlpha(1);
	end
end

function BattlegroundTargets:CheckPlayerFocus()
	if(isConfig) then return; end
	focusName, focusRealm = UnitName("focus");
	if(focusRealm and focusRealm ~= "") then
		focusName = focusName.."-"..focusRealm;
	end
	for i = 1, currentSize do
		GVAR.TargetButton[i].FocusTexture:SetAlpha(0);
	end
	if(not focusName) then return; end
	local focusButton = ENEMY_Name2Button[focusName];
	if(not focusButton) then return; end
	local GVAR_TargetButton = GVAR.TargetButton[focusButton];
	if(not GVAR_TargetButton) then return; end
	if(OPT.ButtonShowFocus[currentSize]) then
		GVAR_TargetButton.FocusTexture:SetAlpha(1);
	end
	if(rangeSpellName and OPT.ButtonTypeRangeCheck[currentSize] >= 2) then
		local curTime = GetTime();
		local Name2Range = ENEMY_Name2Range[focusName];
		if(Name2Range) then
			if(Name2Range + range_SPELL_Frequency > curTime) then return; end
		end
		local healerState = OPT.ButtonShowHealer[currentSize] and true;
		if(IsSpellInRange(rangeSpellName, "focus") == 1) then
			ENEMY_Name2Range[focusName] = curTime;
			Range_Display(true, GVAR_TargetButton, OPT.ButtonRangeDisplay[currentSize], healerState);
		else
			ENEMY_Name2Range[focusName] = nil;
			Range_Display(false, GVAR_TargetButton, OPT.ButtonRangeDisplay[currentSize], healerState);
		end
	end
end

function BattlegroundTargets:CheckUnitTarget(unitID, unitName)
	if(isConfig) then return; end

	local friendName, friendRealm, enemyID, enemyName, enemyRealm;
	if(not unitName) then
		enemyID = unitID.."target";
		
		friendName, friendRealm = UnitName(unitID);
		if(friendRealm and friendRealm ~= "") then
			friendName = friendName.."-"..friendRealm
		end
		
		enemyName, enemyRealm = UnitName(enemyID);
		if(enemyRealm and enemyRealm ~= "") then
			enemyName = enemyName.."-"..enemyRealm;
		end
	else
		enemyID    = "target";
		friendName = playerName;
		enemyName  = unitName;
	end
	
	local curTime = GetTime();
	
	if(flagCHK and isFlagBG > 0) then
		if(OPT.ButtonShowFlag[currentSize]) then
			BattlegroundTargets:CheckFlagCarrierCHECK(enemyID, enemyName);
		end
	end
	
	if(OPT.ButtonShowTargetCount[currentSize]) then
		if(curTime > targetCountForceUpdate + targetCountFrequency) then
			targetCountForceUpdate = curTime;
			table_wipe(TARGET_Names);
			
			for num = 1, GetNumRaidMembers() do
				local uID = "raid"..num;
				
				local fName, fRealm = UnitName(uID);
				if(fName) then
					if(fRealm and fRealm ~= "") then
						fName = fName.."-"..fRealm;
					end
					
					local eName, eRealm = UnitName(uID.."target");
					if(eName) then
						if(eRealm and eRealm ~= "") then
							eName = eName.."-"..eRealm;
						end
						
						if(ENEMY_Names[eName]) then
							TARGET_Names[fName] = eName;
						end
					end
				end
			end
		else
			if(friendName) then
				if(ENEMY_Names[enemyName]) then
					TARGET_Names[friendName] = enemyName;
				else
					TARGET_Names[friendName] = nil;
				end
			end
		end
		
		for eName in pairs(ENEMY_Names) do
			ENEMY_Names[eName] = 0;
		end
		
		for _, eName in pairs(TARGET_Names) do
			if(ENEMY_Names[eName]) then
				ENEMY_Names[eName] = ENEMY_Names[eName] + 1;
			end
		end
		
		for i = 1, currentSize do
			if(ENEMY_Data[i]) then
				local count = ENEMY_Names[ ENEMY_Data[i].name ];
				if count then
					GVAR.TargetButton[i].TargetCount:SetText(count);
				end
			else
				GVAR.TargetButton[i].TargetCount:SetText("");
			end
		end
	end
	
	if(not ENEMY_Names[enemyName]) then return; end

	local GVAR_TargetButton;
	if(enemyName) then
		local enemyButton = ENEMY_Name2Button[enemyName];
		if(enemyButton) then
			GVAR_TargetButton = GVAR.TargetButton[enemyButton];
		end
	end
	
	if(OPT.ButtonShowHealthBar[currentSize] or OPT.ButtonShowHealthText[currentSize]) then
		if(enemyID and enemyName) then
			BattlegroundTargets:CheckUnitHealth(enemyID, enemyName, 1);
		end
	end
	
	if(isAssistName and OPT.ButtonShowAssist[currentSize]) then
		if(curTime > assistForceUpdate + assistFrequency) then
			assistForceUpdate = curTime;
			
			assistTargetName, assistTargetRealm = UnitName(isAssistUnitId);
			if(assistTargetRealm and assistTargetRealm ~= "") then
				assistTargetName = assistTargetName.."-"..assistTargetRealm;
			end
			
			for i = 1, currentSize do
				GVAR.TargetButton[i].AssistTexture:SetAlpha(0);
			end
			
			if(assistTargetName) then
				local assistButton = ENEMY_Name2Button[assistTargetName];
				if(assistButton) then
					local button = GVAR.TargetButton[assistButton];
					if(button) then
						button.AssistTexture:SetAlpha(1);
					end
				end
			end
		elseif(friendName and isAssistName == friendName) then
			for i = 1, currentSize do
				GVAR.TargetButton[i].AssistTexture:SetAlpha(0);
			end
			
			if(GVAR_TargetButton) then
				assistTargetName = enemyName;
				GVAR_TargetButton.AssistTexture:SetAlpha(1);
			end
		end
	end
	
	if(OPT.ButtonShowLeader[currentSize]) then
		if(GVAR_TargetButton) then
			if(isLeader) then
				leaderThrottle = leaderThrottle + 1;
				
				if(leaderThrottle > leaderFrequency) then
					leaderThrottle = 0
					
					if(UnitIsPartyLeader(enemyID)) then
						isLeader = enemyName;
						
						for i = 1, currentSize do
							GVAR.TargetButton[i].LeaderTexture:SetAlpha(0);
						end
						GVAR_TargetButton.LeaderTexture:SetAlpha(0.75);
					else
						GVAR_TargetButton.LeaderTexture:SetAlpha(0);
					end
				end
			else
				if(UnitIsPartyLeader(enemyID)) then
					isLeader = enemyName;
					
					for i = 1, currentSize do
						GVAR.TargetButton[i].LeaderTexture:SetAlpha(0);
					end
					
					GVAR_TargetButton.LeaderTexture:SetAlpha(0.75);
				else
					GVAR_TargetButton.LeaderTexture:SetAlpha(0);
				end
			end
		end
	end

	if (OPT.ButtonShowHealer[currentSize]) then
		if(enemyID and enemyName) then
			local _, uClass = UnitClass(enemyID);
			BattlegroundTargets:CheckEnemyHealer(enemyName, uClass, enemyID);
		end
	end
	
	if(isLowLevel) then
		local level = UnitLevel(enemyID) or 0;
		
		if level > 0 then
			ENEMY_Name2Level[enemyName] = level;
			
			if GVAR_TargetButton then
				GVAR_TargetButton.Name:SetText(level.." "..GVAR_TargetButton.name4button);
			end
		end
	end
	
	if(rangeSpellName and OPT.ButtonTypeRangeCheck[currentSize] >= 2) then
		if(GVAR_TargetButton) then
			local Name2Range = ENEMY_Name2Range[enemyName];
			
			if(Name2Range) then
				if(Name2Range + range_SPELL_Frequency > curTime) then return; end
			end
			
			if(IsSpellInRange(rangeSpellName, enemyID) == 1) then
				ENEMY_Name2Range[enemyName] = curTime;
				Range_Display(true, GVAR_TargetButton, OPT.ButtonRangeDisplay[currentSize], OPT.ButtonShowHealer[currentSize]);
			else
				ENEMY_Name2Range[enemyName] = nil;
				Range_Display(false, GVAR_TargetButton, OPT.ButtonRangeDisplay[currentSize], OPT.ButtonShowHealer[currentSize]);
			end
		end
	end
end

function BattlegroundTargets:CheckUnitHealth(unitID, unitName, healthonly)
	if(isConfig) then return; end

	local targetID, targetName, targetRealm;
	if(not unitName) then
		if(raidUnitID[unitID]) then
			targetID = unitID.."target";
		elseif(playerUnitID[unitID]) then
			targetID = unitID;
		else
			return;
		end
		
		targetName, targetRealm = UnitName(targetID);
		if(targetRealm and targetRealm ~= "") then
			targetName = targetName.."-"..targetRealm;
		end
	else
		targetID = unitID;
		targetName = unitName;
	end
	
	if(not targetName) then return; end
	
	local targetButton = ENEMY_Name2Button[targetName];
	if(not targetButton) then return; end
	
	local GVAR_TargetButton = GVAR.TargetButton[targetButton];
	if(not GVAR_TargetButton) then return; end
	
	local ButtonShowHealthBar  = OPT.ButtonShowHealthBar[currentSize];
	local ButtonShowHealthText = OPT.ButtonShowHealthText[currentSize];
	
	if(ButtonShowHealthBar or ButtonShowHealthText) then
		local maxHealth = UnitHealthMax(targetID);
		
		if(maxHealth) then
			local health = UnitHealth(targetID);
			
			if(health) then
				local width = 0.01;
				local percent = 0;
				
				if(maxHealth > 0 and health > 0) then
					local hvalue = maxHealth / health;
					width = healthBarWidth / hvalue;
					width = math_max(0.01, width);
					width = math_min(healthBarWidth, width);
					percent = math_floor( (100/hvalue) + 0.5 );
					percent = math_max(0, percent);
					percent = math_min(100, percent);
				end
				
				ENEMY_Name2Percent[targetName] = percent;
				
				if(ButtonShowHealthBar) then
					GVAR_TargetButton.HealthBar:SetWidth(width);
				end
				
				if(ButtonShowHealthText) then
					GVAR_TargetButton.HealthText:SetText(percent);
				end
			end
		end
	end
	
	if(healthonly) then return; end
	
	if(flagCHK and isFlagBG > 0) then
		if(OPT.ButtonShowFlag[currentSize]) then
			BattlegroundTargets:CheckFlagCarrierCHECK(targetID, targetName);
		end
	end
	
	if(rangeSpellName and OPT.ButtonTypeRangeCheck[currentSize] >= 2) then
		local curTime = GetTime();
		local Name2Range = ENEMY_Name2Range[targetName];
		
		if(Name2Range) then
			if(Name2Range + range_SPELL_Frequency > curTime) then return; end
		end
		
		if(IsSpellInRange(rangeSpellName, targetID) == 1) then
			ENEMY_Name2Range[targetName] = curTime;
			Range_Display(true, GVAR_TargetButton, OPT.ButtonRangeDisplay[currentSize], OPT.ButtonShowHealer[currentSize]);
		else
			ENEMY_Name2Range[targetName] = nil;
			Range_Display(false, GVAR_TargetButton, OPT.ButtonRangeDisplay[currentSize], OPT.ButtonShowHealer[currentSize]);
		end
	end
end

function BattlegroundTargets:FlagCheck(message, messageFaction)
	if messageFaction == playerFactionBG then
		if string_match(message, FLG["WSG_TP_MATCH_CAPTURED"]) or message == FLG["EOTS_STRING_CAPTURED_BY_ALLIANCE"] or message == FLG["EOTS_STRING_CAPTURED_BY_HORDE"] then
			for i = 1, currentSize do GVAR.TargetButton[i].FlagTexture:SetAlpha(0) end
			hasFlag = nil
			if flagCHK then BattlegroundTargets:CheckFlagCarrierEND() end
		elseif string_match(message, FLG["WSG_TP_MATCH_DROPPED"]) then
			for i = 1, currentSize do GVAR.TargetButton[i].FlagTexture:SetAlpha(0) end
			hasFlag = nil
		end
	else
		local efc = string_match(message, FLG["WSG_TP_REGEX_PICKED1"]) or string_match(message, FLG["WSG_TP_REGEX_PICKED2"]) or string_match(message, FLG["EOTS_REGEX_PICKED"])
		if efc then
			for i = 1, currentSize do GVAR.TargetButton[i].FlagTexture:SetAlpha(0) end
			if flagCHK then BattlegroundTargets:CheckFlagCarrierEND() end
			for name, button in pairs(ENEMY_Names4Flag) do
				if name == efc then
					local GVAR_TargetButton = GVAR.TargetButton[button];
					if GVAR_TargetButton then
						GVAR_TargetButton.FlagTexture:SetAlpha(1)
						for fullname, fullnameButton in pairs(ENEMY_Name2Button) do
							if button == fullnameButton then
								hasFlag = fullname
								return
							end
						end
					end
					return
				end
			end
		elseif string_match(message, FLG["WSG_TP_MATCH_CAPTURED"]) or message == FLG["EOTS_STRING_CAPTURED_BY_ALLIANCE"] or message == FLG["EOTS_STRING_CAPTURED_BY_HORDE"] then
			for i = 1, currentSize do GVAR.TargetButton[i].FlagTexture:SetAlpha(0) end
			hasFlag = nil
			if flagCHK then BattlegroundTargets:CheckFlagCarrierEND() end
		elseif string_match(message, FLG["EOTS_STRING_DROPPED"]) then
			for i = 1, currentSize do GVAR.TargetButton[i].FlagTexture:SetAlpha(0) end
			hasFlag = nil		
		end
	end
end

local function CombatLogRangeCheck(sourceName, destName, spellID)
	if not SPELL_Range[spellID] then
		local name, _, _, _, _, _, _, _, maxRange = GetSpellInfo(spellID) -- local name, rank, icon, cost, isFunnel, powerType, castTime, minRange, maxRange = GetSpellInfo(spellID)
		if not maxRange then return end
		SPELL_Range[spellID] = maxRange
	end

	if OPT.ButtonTypeRangeCheck[currentSize] == 4 then
		
		if SPELL_Range[spellID] > rangeMax then return end
		if SPELL_Range[spellID] < rangeMin then return end

		-- enemy attack player
		if ENEMY_Names[sourceName] then
			if destName == playerName then

				if ENEMY_Name2Percent[sourceName] == 0 then
					ENEMY_Name2Range[sourceName] = nil
					local sourceButton = ENEMY_Name2Button[sourceName]
					if sourceButton then
						local GVAR_TargetButton = GVAR.TargetButton[sourceButton]
						if GVAR_TargetButton then
							Range_Display(false, GVAR_TargetButton, OPT.ButtonRangeDisplay[currentSize], OPT.ButtonShowHealer[currentSize])
						end
					end
					return
				end

				local curTime = GetTime()
				ENEMY_Name2Range[sourceName] = curTime
				local sourceButton = ENEMY_Name2Button[sourceName]
				if sourceButton then
					local GVAR_TargetButton = GVAR.TargetButton[sourceButton]
					if GVAR_TargetButton then
						Range_Display(true, GVAR_TargetButton, OPT.ButtonRangeDisplay[currentSize], OPT.ButtonShowHealer[currentSize])
					end
				end
				if range_CL_DisplayThrottle + range_CL_DisplayFrequency > curTime then return end
				range_CL_DisplayThrottle = curTime
				BattlegroundTargets:UpdateRange(curTime)
			end
		end

	elseif OPT.ButtonTypeRangeCheck[currentSize] == 3 then

		if SPELL_Range[spellID] > 45 then return end

		-- enemy attack player
		if ENEMY_Names[sourceName] then
			if destName == playerName then

				if ENEMY_Name2Percent[sourceName] == 0 then
					ENEMY_Name2Range[sourceName] = nil
					local sourceButton = ENEMY_Name2Button[sourceName]
					if sourceButton then
						local GVAR_TargetButton = GVAR.TargetButton[sourceButton]
						if GVAR_TargetButton then
							Range_Display(false, GVAR_TargetButton, OPT.ButtonRangeDisplay[currentSize], OPT.ButtonShowHealer[currentSize])
						end
					end
					return
				end

				local curTime = GetTime()
				ENEMY_Name2Range[sourceName] = curTime
				local sourceButton = ENEMY_Name2Button[sourceName]
				if sourceButton then
					local GVAR_TargetButton = GVAR.TargetButton[sourceButton]
					if GVAR_TargetButton then
						Range_Display(true, GVAR_TargetButton, OPT.ButtonRangeDisplay[currentSize], OPT.ButtonShowHealer[currentSize])
					end
				end
				if range_CL_DisplayThrottle + range_CL_DisplayFrequency > curTime then return end
				range_CL_DisplayThrottle = curTime
				BattlegroundTargets:UpdateRange(curTime)
			end
		end

	else--if OPT.ButtonTypeRangeCheck[currentSize] == 1 then
		if SPELL_Range[spellID] > 45 then return end

		-- enemy attack friend
		if ENEMY_Names[sourceName] then
			
			if destName == playerName then
				ENEMY_Name2Range[sourceName] = GetTime()
				local sourceButton = ENEMY_Name2Button[sourceName]
				if sourceButton then
					local GVAR_TargetButton = GVAR.TargetButton[sourceButton]
					if GVAR_TargetButton then
						Range_Display(true, GVAR_TargetButton, OPT.ButtonRangeDisplay[currentSize], OPT.ButtonShowHealer[currentSize])
					end
				end
			elseif FRIEND_Names[destName] then
				local curTime = GetTime()
				if CheckInteractDistance(destName, 1) then -- 1:Inspect=28
					ENEMY_Name2Range[sourceName] = curTime
				end
				if range_CL_DisplayThrottle + range_CL_DisplayFrequency > curTime then return end
				range_CL_DisplayThrottle = curTime
				BattlegroundTargets:UpdateRange(curTime)
			end
		-- friend attack enemy
		elseif ENEMY_Names[destName] then
			if sourceName == playerName then
				ENEMY_Name2Range[destName] = GetTime()
				local destButton = ENEMY_Name2Button[destName]
				if destButton then
					local GVAR_TargetButton = GVAR.TargetButton[destButton]
					if GVAR_TargetButton then
						Range_Display(true, GVAR_TargetButton, OPT.ButtonRangeDisplay[currentSize], OPT.ButtonShowHealer[currentSize])
					end
				end
			elseif FRIEND_Names[sourceName] then
				local curTime = GetTime()
				if CheckInteractDistance(sourceName, 1) then -- 1:Inspect=28
					ENEMY_Name2Range[destName] = curTime
				end
				if range_CL_DisplayThrottle + range_CL_DisplayFrequency > curTime then return end
				range_CL_DisplayThrottle = curTime
				BattlegroundTargets:UpdateRange(curTime)
			end
		end

	end

end

function BattlegroundTargets:UpdateRange(curTime)
	if(isDeadUpdateStop) then
		BattlegroundTargets:ClearRangeData();
		return;
	end
	local healerState = OPT.ButtonShowHealer[currentSize] and true;
	local ButtonRangeDisplay = OPT.ButtonRangeDisplay[currentSize];
	for i = 1, currentSize do
		Range_Display(false, GVAR.TargetButton[i], ButtonRangeDisplay, healerState);
	end
	for name, timeStamp in pairs(ENEMY_Name2Range) do
		local button = ENEMY_Name2Button[name]
		if not button then
			ENEMY_Name2Range[name] = nil
		elseif ENEMY_Name2Percent[name] == 0 then
			ENEMY_Name2Range[name] = nil
		elseif timeStamp + range_DisappearTime < curTime then
			ENEMY_Name2Range[name] = nil
		else
			local GVAR_TargetButton = GVAR.TargetButton[button]
			if GVAR_TargetButton then
				Range_Display(true, GVAR_TargetButton, ButtonRangeDisplay, healerState)
			end
		end
	end
end

function BattlegroundTargets:ClearRangeData()
	if(OPT.ButtonRangeCheck[currentSize]) then
		table_wipe(ENEMY_Name2Range);
		local ButtonRangeDisplay = OPT.ButtonRangeDisplay[currentSize];
		for i = 1, currentSize do
			Range_Display(false, GVAR.TargetButton[i], ButtonRangeDisplay, OPT.ButtonShowHealer[currentSize]);
		end
	end
end

function BattlegroundTargets:CheckPlayerLevel()
	if(playerLevel == maxLevel) then
		isLowLevel = nil;
		BattlegroundTargets:UnregisterEvent("PLAYER_LEVEL_UP");
	elseif(playerLevel < maxLevel) then
		isLowLevel = true;
		BattlegroundTargets:RegisterEvent("PLAYER_LEVEL_UP");
	else
		isLowLevel = nil;
		BattlegroundTargets:UnregisterEvent("PLAYER_LEVEL_UP");
	end
end

function BattlegroundTargets:CheckNativeFaction()
	if(BattlegroundTargets_Character.NativeFaction == "Horde") then
		playerFactionDEF = 0;
		oppositeFactionDEF = 1;
	else
		playerFactionDEF = 1;
		oppositeFactionDEF = 0;
	end
	playerFactionBG   = playerFactionDEF;
	oppositeFactionBG = oppositeFactionDEF;
end

function BattlegroundTargets:CheckIfPlayerIsGhost()
	if(not inBattleground) then return end
	if UnitIsGhost("player") then
		isDeadUpdateStop = true	
		BattlegroundTargets:ClearRangeData()
	else
		isDeadUpdateStop = false
	end
end

function BattlegroundTargets:BattlefieldScoreRequest()
	local wssf = WorldStateScoreFrame
	if wssf and wssf:IsShown() then
		return
	end
	SetBattlefieldScoreFaction()
	RequestBattlefieldScoreData()
end

local function OnEvent(self, event, ...)
	if event == "PLAYER_REGEN_DISABLED" then
		inCombat = true
		if isConfig then
			if not inWorld then return end
			BattlegroundTargets:DisableInsecureConfigWidges()
		end

	elseif event == "PLAYER_REGEN_ENABLED" then
		inCombat = false
		if reCheckScore or reCheckBG then
			if not inWorld then return end
			BattlegroundTargets:BattlefieldScoreRequest()
		end
		if reSetLayout then
			if not inWorld then return; end
			BattlegroundTargets:SetupButtonLayout()
		end
		if isConfig then
			if not inWorld then return end
			BattlegroundTargets:EnableInsecureConfigWidges()
			if BattlegroundTargets_Options.EnableBracket[currentSize] then
				BattlegroundTargets:EnableConfigMode()
			else
				BattlegroundTargets:DisableConfigMode()
			end
		end

	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
		if isConfig or isDeadUpdateStop then return end
		--local timestamp, subevent, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellID, spellName, spellSchool = ...	
		local _, _, _, sourceName, _, _, destName, _, spellID = ...
		if not sourceName or not destName or not spellID then return end
		BattlegroundTargets:DetectHealerByAOEBuffs(...)
		if not OPT.ButtonRangeCheck[currentSize] then return end
		if sourceName == destName then return end
		range_CL_Throttle = range_CL_Throttle + 1
		if range_CL_Throttle > range_CL_Frequency then
			range_CL_Throttle = 0
			range_CL_Frequency = math_random(1,3)
			return
		end
		CombatLogRangeCheck(sourceName, destName, spellID)

	elseif event == "UNIT_HEALTH_FREQUENT" then
		if isDeadUpdateStop then return end
		local arg1 = ...
		BattlegroundTargets:CheckUnitHealth(arg1)

	elseif event == "UNIT_TARGET" then
		if isDeadUpdateStop then return end
		local arg1 = ...
		if not raidUnitID[arg1] then return end
		BattlegroundTargets:CheckUnitTarget(arg1)

	elseif event == "UPDATE_MOUSEOVER_UNIT" then
		if isDeadUpdateStop then return end
		BattlegroundTargets:CheckUnitHealth("mouseover")

	elseif event == "PLAYER_TARGET_CHANGED" then
		BattlegroundTargets:CheckPlayerTarget()

	elseif event == "PLAYER_FOCUS_CHANGED" then
		BattlegroundTargets:CheckPlayerFocus()

	elseif event == "UPDATE_BATTLEFIELD_SCORE" then
		if isConfig then return end
		BattlegroundTargets:BattlefieldScoreUpdate()

	elseif event == "RAID_ROSTER_UPDATE" then
		if OPT.ButtonShowAssist[currentSize] then
			BattlegroundTargets:CheckAssist()
		end

	elseif event == "CHAT_MSG_BG_SYSTEM_HORDE" then
		local arg1 = ...
		BattlegroundTargets:FlagCheck(arg1, 0)

	elseif event == "CHAT_MSG_BG_SYSTEM_ALLIANCE" then
		local arg1 = ...
		BattlegroundTargets:FlagCheck(arg1, 1)

	elseif event == "PLAYER_DEAD" then
		if not inBattleground then return end
		isDeadUpdateStop = false

	elseif event == "PLAYER_UNGHOST" then
		if not inBattleground then return end
		isDeadUpdateStop = false

	elseif event == "PLAYER_ALIVE" then
		BattlegroundTargets:CheckIfPlayerIsGhost()

	elseif event == "ZONE_CHANGED_NEW_AREA" then
		if not inWorld then return end
		if isConfig then return end
		BattlegroundTargets:BattlefieldCheck()

	elseif event == "PLAYER_LEVEL_UP" then
		local arg1 = ...
		if arg1 then
			playerLevel = arg1
			BattlegroundTargets:CheckPlayerLevel()
		end

	elseif event == "PLAYER_LOGIN" then
		BattlegroundTargets:CheckNativeFaction()
		BattlegroundTargets:InitOptions()
		BattlegroundTargets:CreateInterfaceOptions()
		BattlegroundTargets:LDBcheck()
		BattlegroundTargets:CreateFrames()
		BattlegroundTargets:CreateOptionsFrame()
		RegisterBGH_Notifier() -- by Khal
		if IsShowHealers then
			if BattlegroundTargets_Options.hdlog then
				Print(L["Permanent logging of healers detection is enabled. Type |cff55c912/bgt hdlogAlways|r again to disable."])
			end
			if BattlegroundTargets_Options.DB and BattlegroundTargets_Options.DB.outOfDateRange and BattlegroundTargets_Options.DB.outOfDateRange > 0 then
				DBUtils:CheckHealersDataBase(BattlegroundTargets_HealersDB)
			end
		end
		hooksecurefunc("PanelTemplates_SetTab", function(frame)
			if frame and frame == WorldStateScoreFrame then
				BattlegroundTargets:ScoreWarningCheck()
			end
		end)
		table.insert(UISpecialFrames, "BattlegroundTargets_OptionsFrame")
		BattlegroundTargets:UnregisterEvent("PLAYER_LOGIN")

	elseif event == "PLAYER_ENTERING_WORLD" then 
		inWorld = true
		BattlegroundTargets:CheckPlayerLevel()
		BattlegroundTargets:BattlefieldCheck()
		BattlegroundTargets:CheckIfPlayerIsGhost()
		BattlegroundTargets:CreateMinimapButton()
		if not BattlegroundTargets_Options.FirstRun then
			BattlegroundTargets:Frame_Toggle(GVAR.OptionsFrame)
			BattlegroundTargets_Options.FirstRun = true
		end
		BattlegroundTargets:UnregisterEvent("PLAYER_ENTERING_WORLD");
	elseif event == "UPDATE_BATTLEFIELD_STATUS" then -- by Khal
		local bgIndex = ...
		local status = GetBattlefieldStatus(bgIndex)
		if status == "active" then
			if not BGStatus[bgIndex] then
				ResetBattlegroundFlags()
			end
			BGStatus[bgIndex] = true
		else
			BGStatus[bgIndex] = false
		end
	end
end

BattlegroundTargets:RegisterEvent("PLAYER_REGEN_DISABLED")
BattlegroundTargets:RegisterEvent("PLAYER_REGEN_ENABLED")
BattlegroundTargets:RegisterEvent("ZONE_CHANGED_NEW_AREA")
BattlegroundTargets:RegisterEvent("PLAYER_LOGIN")
BattlegroundTargets:RegisterEvent("PLAYER_ENTERING_WORLD")
BattlegroundTargets:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
BattlegroundTargets:SetScript("OnEvent", OnEvent)