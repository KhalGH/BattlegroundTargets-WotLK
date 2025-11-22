
BattlegroundTargets_DBUtils = {};

local GetRealmName = _G.GetRealmName;
local UnitName     = _G.UnitName;
local date         = _G.date;

local next     = _G.next;
local ipairs   = _G.ipairs;
local pairs    = _G.pairs;
local type     = _G.type;
local tostring = _G.tostring;
local tonumber = _G.tonumber;
local unpack   = _G.unpack;

local math_modf    = _G.math.modf;

local string_split = _G.string.split;
local string_sub   = _G.string.sub;

local table_insert = _G.table.insert;
local table_remove = _G.table.remove;


local NativeCharRealm = nil;
local PlayerName = UnitName("player");
local PlayerRealm;
local currentDataStamp = tonumber(date("%Y%m%d%H%M%S"));


local function contains(table, element)
	for i, value in pairs(table) do
		if (value == element) then return true, i end
	end
	return false
end


local function Print(...)
	print("|cffffff7fBattlegroundTargets [DB]:|r", ...);
end

local function GetNativeCharRealm()
    if not NativeCharRealm then
        local uRealm = GetRealmName();
        NativeCharRealm = uRealm:match("(%w+)$");
    end
    
    return NativeCharRealm;
end


local function SplitName(name)
    local onlyName, realm = string_split("-", name);
    if not realm then
        realm = NativeCharRealm or GetNativeCharRealm();
    end
    return onlyName, realm;
end


local function DB_initFields(HEALERS_DB)
    HEALERS_DB["PALADIN"] = {};
    HEALERS_DB["PRIEST"]  = {};
    HEALERS_DB["DRUID"]   = {};
    HEALERS_DB["SHAMAN"]  = {};
end


function BattlegroundTargets_DBUtils:CheckHealersDataBase(HEALERS_DB)
    
    _, PlayerRealm = SplitName(PlayerName);
    
    if not BattlegroundTargets_Options.DB then BattlegroundTargets_Options.DB = {}; end;
    if not BattlegroundTargets_Options.DB.outOfDateRange then BattlegroundTargets_Options.DB.outOfDateRange = 6; else BattlegroundTargets_Options.DB.outOfDateRange = BattlegroundTargets_Options.DB.outOfDateRange end; 
        
    if next(HEALERS_DB) then
        BattlegroundTargets_DBUtils:validateDBData(HEALERS_DB)
    else
        DB_initFields(HEALERS_DB)
    end

end


function BattlegroundTargets_DBUtils:insertNewUnit(HEALERS_DB, unit)
    unit.name, unit.realm = SplitName(unit.name);
    if unit.realm then
        -- indexed part
        local stamp = tonumber(date("%Y%m%d%H%M%S"));
        table_insert( HEALERS_DB, #HEALERS_DB+1, {stamp, unit["name"], unit["realm"], unit["class"]} );
    
        -- hash part
        local targetTBL = HEALERS_DB[unit["class"]][unit["realm"]];
        if not targetTBL then
            HEALERS_DB[unit["class"]][unit["realm"]] = {};
            targetTBL = HEALERS_DB[unit["class"]][unit["realm"]];
        end
        table_insert(targetTBL, #targetTBL+1, unit["name"])
    end
end

-----------------------------------------------------------------------------------------

local function splitSearch_getItem(DB,id, name)
    local tStamp,tName = DB[id][1], DB[id][2];
    if tName == name then
        return tStamp, tName, id;
    else 
        return nil 
    end;

end
  
local function splitSearch(DB, name)

    local idblen    = #DB;
    local medianaDB = math_modf(idblen / 2);
    local startSign = idblen % 2 == 0 and 2 or 1;
    local id;
    local tStamp; 
    local iterators = {};
    iterators.fi = nil; 
    iterators.si = nil;

    if startSign == 1 then
        medianaDB = medianaDB + 1;
        iterators.si = medianaDB + 1;
        iterators.fi = medianaDB - 1; 
        tStamp,_, id = splitSearch_getItem(DB, medianaDB, name)
        if tStamp then return id, tStamp  end;

    else
        iterators.fi = medianaDB;
        iterators.si = medianaDB + 1;
    end


    for i = 1, medianaDB do
        for k,v in pairs(iterators) do 

            tStamp,_,id = splitSearch_getItem(DB, v, name);
            if tStamp then return id, tStamp  end;

            if k == "fi" then iterators.fi = iterators.fi - 1; 
            else iterators.si = iterators.si + 1 end;
    
        end

    end

    return
end
  
-------------------------------------------------------------------------

function BattlegroundTargets_DBUtils:checkHealerDB(HEALERS_DB, sUnit)
    if not HEALERS_DB then return end;
    if not sUnit then return end;
        
    local oName, realm = string_split("-",sUnit.name) 
    realm = not realm  and  GetNativeCharRealm()   or   realm;
    if not HEALERS_DB[sUnit.class] then DB_initFields(HEALERS_DB) end;
    
    local targetTBL = HEALERS_DB[sUnit.class][realm];
    if not targetTBL then return; end;

    if contains(targetTBL, oName) then

        local id, tStamp = splitSearch(HEALERS_DB, oName) 
        if id then
            local tmpitem = HEALERS_DB[id];
            tmpitem[1] = tonumber(date("%Y%m%d%H%M%S"));
            table_remove(HEALERS_DB, id);
            table_insert(HEALERS_DB, #HEALERS_DB+1, tmpitem);
            return  true, tmpitem;
        end

    end

    return
end



local function isOutOfDate(dataStamp)
    local curStamp = currentDataStamp;
    local range = BattlegroundTargets_Options.DB.outOfDateRange; 
    local ms = 12;
    local ym = math_modf(dataStamp / 1e8) 
    local expiredYear  = math_modf(ym/100) 
    local expiredMonth = ym % ms; 
    expiredMonth = expiredMonth + range
    
    if expiredMonth / ms > 1 then
       expiredYear  = expiredYear + math_modf(expiredMonth / ms)
       expiredMonth = expiredMonth % 12
    end
    
    expiredMonth = #tostring(expiredMonth) == 1  and  "0"..expiredMonth  or  expiredMonth;
    local elapsedStamp = tonumber(expiredYear..expiredMonth..string_sub(tostring(dataStamp),7));
    
    if (curStamp - elapsedStamp) >= 0 then return true end;
 end
 
 
 local function removeDataDB(DB, link)
    local searchGroup = DB[link[4]][link[3]]
    local unitName = link[2]
    
    local _, pos = contains(searchGroup, unitName);
    table_remove(searchGroup, pos);
 end
 
 
 function BattlegroundTargets_DBUtils:validateDBData(DB)
    local outOfDateIDs = {};
    for i, v in ipairs(DB) do
       if isOutOfDate(v[1]) then
          outOfDateIDs[i] = i;
          removeDataDB(DB, v);
       else break end;
    end
    
    for i = #outOfDateIDs, 1, -1 do 
       table_remove(DB, i); 
    end;
 end