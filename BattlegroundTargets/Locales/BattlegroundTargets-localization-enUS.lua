-- -------------------------------------------------------------------------- --
-- BattlegroundTargets DEFAULT (english) Localization                         --
-- Please make sure to save this file as UTF-8. ¶                             --
-- -------------------------------------------------------------------------- --

BattlegroundTargets_Localization = {
["Open Configuration"] = true,

["Configuration"] = true,
["10 vs 10"] = true,
["15 vs 15"] = true,
["40 vs 40"] = true,
["Enable"] = true,
["Independent Positioning"] = true,
["Layout"] = true,
["Summary"] = true,
["Copy this settings to '%s'"] = true,
["Show Role"] = true,
["Show Specialization"] = true,
["Show Class Icon"] = true,
["Hide Realm"] = true,
["Show Leader"] = true,
["Show Healer"] = true,
["Show Guild Groups"] = true,
["Show Target"] = true,
["Show Focus"] = true,
["Show Flag Carrier"] = true,
["Show Main Assist Target"] = true,
["Show Target Count"] = true,
["Show Health Bar"] = true,
["Show Percent"] = true,
["Show Range"] = true,
 ["This option uses the CombatLog to check range."] = true,
 ["This option uses a pre-defined spell to check range:"] = true,
 ["Mix"] = true,
 ["if you are attacked only"] = true,
 ["(class dependent)"] = true,
 ["Disable this option if you have CPU/FPS problems in combat."] = true,
["Sort By"] = true,
["Text Size"] = true,
["Scale"] = true,
["Width"] = true,
["Height"] = true,

["General Settings"] = true,
["Show Minimap-Button"] = true,

["click & move"] = true,
["BattlegroundTargets does not update if this Tab is opened."] = true,

["Close Configuration"] = true,


["Show roles on the right"] = true,
["Show roles on the left"]  = true,
["Don't show roles"]        = true,

["To log healer detections while you are in a BG."] = true,
["Available commands:"] = true,
["To enable permanent healer detection mode while you are in BG. After that, you don't need to enter /bgt hdlog every time"] = true,
["To show full info about all healers detects."] = true,
["GET or SET (if the number exists) retention period of the data in months, after which the obsolete data about healer will be deleted. If <number> is set up to 0 then DataBase will be disabled."] = true,

["Logging of healers detection is enabled.\nType |cff55c912/bgt hdlog|r again to disable."] = true
, ["Logging of healers detection is disabled."] = true
, ["Something is wrong! Not possible to prepare info for the report. The option: 'Show roles' should be enabled. Or try to get report later."] = true
, ["You should be in some battleground to call reports."] = true
, ["Unable to set this period. You must use values in the range of 0 to 11."] = true
, ["Healers data will now be deleted from the database after "] = true, ["months. You need to re-login to save settings."] = true
, ["Current storage period of data is: "] = true, [" months. Max period is 11 months."] = true
, ["Permanent logging of healers detection is enabled. Type |cff55c912/bgt hdlogAlways|r again to disable."] = true
, ["Permanent logging of healers detection is disabled."] = true
, ["[Warning]: To use that command you have to pick 'Show roles' option in the settings panel of BattlegroundTargets."] = true
, ["DB is disabled. You need to re-login to save settings."] = true
}

function BattlegroundTargets_Localization:CreateLocaleTable(t)
	for k,v in pairs(t) do
		self[k] = (v == true and k) or v
	end
end

BattlegroundTargets_Localization:CreateLocaleTable(BattlegroundTargets_Localization)