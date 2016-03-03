-- 玩家数据缓存
local CalHeroAttr = require("tool.helper.CalHeroAttr")

local GameCache = {}
GameCache.Passport = nil 
GameCache.PurchaseGiftStatus = 2 -- 0:未充值, 1:未领取, 2:不显示
GameCache.Avatar = nil
GameCache.AllEquip = {}
GameCache.AllProps = {}
GameCache.AllFrag = {}
GameCache.AllSoul = {}
GameCache.AllHero = {}
GameCache.InstProgress = {}
GameCache.InstChapter = {}
GameCache.InstNode = {}
GameCache.AllFairy = {}
GameCache.HeroApartmentBuff = {0,0,0,0,0,0,0,0} -- 星将公寓8种不同加成
GameCache.NewbieGuide = {SavePoint = 0, Step = 0, CurrPage = "", SStep = 1, State = false}
GameCache.OpenSystem = {Step = 0, CurrPage = "", SStep = 1, State = false}
GameCache.AutoBattle = false
GameCache.BattleSpeedX2 = false

GameData = {}
GameCache.FriendInfo = nil
GameData.ExchangeList = nil
GameCache.ChatRecord = nil
-- 审核
GameCache.isExamine = false

function GameCache.updateAvatar(avt)
    GameCache.Avatar = avt
    GameCache.Avatar.EnergeAttrTab = Common.getAvatarAttr(GameCache.Avatar.EnergyStep, GameCache.Avatar.EnergyAttrNum)
    GameCache.Avatar.MaxPhyPower = CalHeroAttr.calMaxPhyPower(GameCache.Avatar.EnergyStep, GameCache.Avatar.EnergyAttrNum)
    GameCache.Avatar.MaxEndurance = CalHeroAttr.calMaxEndurance(GameCache.Avatar.EnergyStep, GameCache.Avatar.EnergyAttrNum)

    if device.platform == "ios" or device.platform == "android" then
        buglyPutUserData("RID", avt.RID)
    end
end

function GameCache.updateEquipList(val)
    local list = val or {}
    for _, v in ipairs(list) do
        v.Type = BaseConfig.GT_EQUIP
        GameCache.AllEquip[tostring(v.ID .. ":" .. v.StarLevel)] = v
    end
end

function GameCache.updatePropsList(val)
    local list = val or {}
    for _, v in ipairs(list) do
        v.Type = BaseConfig.GT_PROPS
        local cf = BaseConfig.GetProps(v.ID)
        if (cf.type == 1) or (cf.type == 4) then
            GameCache.AllFrag[v.ID] = v
        elseif (cf.type ~= 2) then
            GameCache.AllProps[v.ID] = v
        end
    end
end

function GameCache.updateSoulList(val)
    local list = val or {}
    for _, v in ipairs(list) do
        v.Type = BaseConfig.GT_SOUL
        GameCache.AllSoul[v.ID] = v
    end
end

function GameCache.updateHeroList(val)
    local list = val or {}
    for _, v in ipairs(list) do
        GameCache.AllHero[v.ID] = v
    end
end

function GameCache.updateFairyList(val)
    local list = val or {}
    for _, v in ipairs(list) do
        v.Name = BaseConfig.GetFairy(v.ID).Name
        GameCache.AllFairy[v.ID] = v
    end
end

function GameCache.updateFriendInfo(friendInfo)
    GameCache.FriendInfo = friendInfo
    local friendList = friendInfo.FriendList or {}
    GameCache.FriendInfo.FriendList = {}
    for _, v in ipairs(friendList) do
        GameCache.FriendInfo.FriendList[v.RID] = v
    end
    GameCache.FriendInfo.AddRequest = GameCache.FriendInfo.AddRequest or {}
    GameCache.FriendInfo.SuggestList = GameCache.FriendInfo.SuggestList or {}
end

function GameCache.updateInstanceInfo(instInfo)
    GameCache.InstProgress[1] = instInfo.CurEasyNodeID
    GameCache.InstProgress[2] = instInfo.CurHardNodeID

    instInfo.ChapterChest = instInfo.ChapterChest or {}
    for i=1,#instInfo.ChapterChest do   -- 每章宝箱状态
        GameCache.InstChapter[i] = {}
        GameCache.InstChapter[i].EasyStatus = instInfo.ChapterChest[i][1]
        GameCache.InstChapter[i].EasySStatus = instInfo.ChapterChest[i][2]
        GameCache.InstChapter[i].HardStatus = instInfo.ChapterChest[i][3]
        GameCache.InstChapter[i].HardSStatus = instInfo.ChapterChest[i][4]
    end

    instInfo.EasyNodePassList = instInfo.EasyNodePassList or {}
    for k,v in pairs(instInfo.EasyNodePassList) do
        GameCache.InstNode[v.NodeID..",1"] = {}
        GameCache.InstNode[v.NodeID..",1"] = v
        GameCache.InstNode[v.NodeID..",1"].Rating = Common.calculateRating( v.Score )
        GameCache.InstNode[v.NodeID..",1"].Score = v.Score
        GameCache.InstNode[v.NodeID..",1"].NodeUnlock = true

    end

    instInfo.HardNodePassList = instInfo.HardNodePassList or {}
    for k,v in pairs(instInfo.HardNodePassList) do
        GameCache.InstNode[v.NodeID..",2"] = {}
        GameCache.InstNode[v.NodeID..",2"] = v
        GameCache.InstNode[v.NodeID..",2"].Rating = Common.calculateRating( v.Score )
        GameCache.InstNode[v.NodeID..",2"].Score = v.Score
        GameCache.InstNode[v.NodeID..",2"].NodeUnlock = true
    end
end

-- 更新计算出来的属性
function GameCache.updateHeroAttr(hero)
    hero.Vampire = CalHeroAttr.CalHeroVampire( hero )
    hero.HpRecover = CalHeroAttr.CalHeroHpRecover( hero )
    hero.TreatedAddition = CalHeroAttr.CalHeroTreatedAddition( hero )
    hero.SkillReduction = CalHeroAttr.CalHeroSkillReduction( hero )
    hero.MaxExp = CalHeroAttr.HeroMaxExp(hero)
    hero.TFSkillLevel = CalHeroAttr.HeroTFSkillLevel(hero)
    hero.NorSkillLevel = CalHeroAttr.HeroNorSkillLevel(hero)
    hero.RPLevelAdd = CalHeroAttr.HeroAddRPSkillLevel(hero)
    hero.MaxRPSkillLevel = CalHeroAttr.HeroRPSkillMaxLevel(hero)
    hero.MaxRPSkillExp = CalHeroAttr.HeroRPSkillMaxExp(hero)
    hero.AtkInterval = CalHeroAttr.HeroAtkInterval(hero)
    hero.Score = CalHeroAttr.CalHeroScore( hero )
    hero.Atk = CalHeroAttr.CalHeroAtk(hero)
    hero.Def = CalHeroAttr.CalHeroDef(hero)
    hero.HP = CalHeroAttr.CalHeroHP(hero)
    hero.MP = CalHeroAttr.CalHeroMP(hero)
    hero.Hit = CalHeroAttr.CalHeroHit(hero)
    hero.Miss = CalHeroAttr.CalHeroMiss(hero)
    hero.Crit = CalHeroAttr.CalHeroCrit(hero)
    hero.Ten = CalHeroAttr.CalHeroTen(hero)
    hero.TFP = CalHeroAttr.CalHeroTFP(hero)
    hero.SkinList = hero.SkinList or {}
    hero.SkinStatus = hero.SkinStatus or {}
    if #hero.SkinStatus == 0 then
        hero.SkinStatus = {{ID = 0}, {ID = 0}}
    end
end

-- 星将公寓
function GameCache.updateApartment(val)
    local roomList = val or {}
    for _, room in ipairs(roomList) do
        GameCache.HeroApartmentBuff[room.ID] = 0
        for _, v in pairs(room.Positions) do
            if v.HeroID > 0 then
                GameCache.GetHero(v.HeroID).ApartmentType = room.ID  
                GameCache.HeroApartmentBuff[room.ID] = GameCache.HeroApartmentBuff[room.ID] + GameCache.GetHero(v.HeroID).Score
            end
        end
    end
end

-------------------------------------------------------------------------------------------
function GameCache.updateFriendSuggestList(list)
    GameCache.FriendInfo.SuggestList = list or {}
end
--[[
-----------------------------------------------------------------
-----------------------------装备相关-----------------------------
]]--
function GameCache.GetAllEquip()
	return GameCache.AllEquip
end

function GameCache.GetEquipTotal()
	local totalNum = 0
	for k,v in pairs(GameCache.AllEquip) do
		totalNum = totalNum + 1
	end
	return assert(totalNum, string.format("error %d", totalNum))
end

function GameCache.GetEquipment()
	local equipInfoTab = {}
	for k,v in pairs(GameCache.AllEquip) do
        local equipConfigInfo = BaseConfig.GetEquip(v.ID, v.StarLevel)
        if equipConfigInfo.type < 5 then
            table.insert(equipInfoTab, v)
        end
    end
    table.sort(equipInfoTab, Common.equipSort)
    return equipInfoTab
end

function GameCache.GetTrump()
	local trumpInfoTab = {}
	for k,v in pairs(GameCache.AllEquip) do
        local equipConfigInfo = BaseConfig.GetEquip(v.ID, v.StarLevel)
        if equipConfigInfo.type > 4 then
            table.insert(trumpInfoTab, v)
        end
    end
    table.sort(trumpInfoTab, Common.equipSort)
    return trumpInfoTab
end

function GameCache.GetEquipTabsByType(equipType)
    local equipInfoTab = {}
    for k,v in pairs(GameCache.AllEquip) do
        local equipConfigInfo = BaseConfig.GetEquip(v.ID, v.StarLevel)
        if equipType == equipConfigInfo.type then
            table.insert(equipInfoTab, v)
        end
    end
    table.sort(equipInfoTab, Common.equipSort)
    return equipInfoTab
end

function GameCache.GetEquip(id, star_level)
	local result = GameCache.AllEquip[tostring(id .. ":" .. star_level)]
	return result
end

function GameCache.addEquip(id, starLevel, addNum)
    if not starLevel then
        local fragToEquipConfig = BaseConfig.GetFragToEquip(id)
        starLevel = fragToEquipConfig.starLevel
    end

	local isHave = false
    local value = GameCache.AllEquip[tostring(id..":"..starLevel)]
    if value then
    	isHave = true
        value.Num = value.Num + addNum
    end

    if not isHave then
        local equipInfo = {}
        equipInfo.Type = BaseConfig.GT_EQUIP 
        equipInfo.ID = id
        equipInfo.StarLevel = starLevel
        equipInfo.Num = addNum
        GameCache.AllEquip[tostring(id .. ":" .. starLevel)] = equipInfo
        table.sort(GameCache.AllEquip, Common.equipSort)
    end
end

function GameCache.minusEquip(id, starLevel, minusNum)
    local value = GameCache.AllEquip[tostring(id..":"..starLevel)]
    if value then
    	value.Num = value.Num - minusNum
        if value.Num < 1 then
            GameCache.AllEquip[tostring(id..":"..starLevel)] = nil
        end
    end
end

function GameCache.resetEquip(equipInfo)
	local isHave = false
    local value = GameCache.AllEquip[tostring(equipInfo.ID..":"..equipInfo.StarLevel)]
    if value then
    	isHave = true
        value.Num = equipInfo.Num
    end

    if not isHave then
        equipInfo.Type = BaseConfig.GT_EQUIP 
        GameCache.AllEquip[tostring(equipInfo.ID .. ":" .. equipInfo.StarLevel)] = equipInfo
        table.sort(GameCache.AllEquip, Common.equipSort)
    end
end

--[[
-----------------------------------------------------------------
-----------------------------道具相关-----------------------------
]]--
function GameCache.GetAllProps()
	return GameCache.AllProps
end

function GameCache.GetAllFrag()
	return GameCache.AllFrag
end

function GameCache.getPropsTotal()
	local totalNum = 0
	for k,v in pairs(GameCache.AllProps) do
		totalNum = totalNum + 1
	end
	return assert(totalNum, string.format("error %d", totalNum))
end

function GameCache.getFragTotal()
	local totalNum = 0
	for k,v in pairs(GameCache.AllFrag) do
		totalNum = totalNum + 1
	end
	return assert(totalNum, string.format("error %d", totalNum))
end

function GameCache.GetProps(id)
	return GameCache.AllProps[id]
end

function GameCache.GetFrag(id)
	return GameCache.AllFrag[id]
end

function GameCache.addProps(propsInfo, isTotalNum, addNum)
	local propsConfigInfo = BaseConfig.GetProps(propsInfo.ID)
    if (propsConfigInfo.type == 1) or (propsConfigInfo.type == 4) then
        local isHave = false
	    local value = GameCache.AllFrag[propsInfo.ID]
	    if value then
	    	isHave = true
	    	if isTotalNum then
	    		value.Num = propsInfo.Num
	    	else
                if addNum then
                    value.Num = value.Num + addNum
                else
                    value.Num = value.Num + propsInfo.Num
                end
	    	end
	    end

	    if not isHave then
            if addNum then
                propsInfo.Num = addNum
            end
            GameCache.AllFrag[propsInfo.ID] = propsInfo
   			table.sort(GameCache.AllFrag, Common.propsSort)
	    end
    elseif (propsConfigInfo.type ~= 2) then
        local isHave = false
	    local value = GameCache.AllProps[propsInfo.ID]
	    if value then
	    	isHave = true
	    	if isTotalNum then
	    		value.Num = propsInfo.Num
	    	else
	    		if addNum then
                    value.Num = value.Num + addNum
                else
                    value.Num = value.Num + propsInfo.Num
                end
	    	end
	    end

	    if not isHave then
            if addNum then
                propsInfo.Num = addNum
            end
	        GameCache.AllProps[propsInfo.ID] = propsInfo
   			table.sort(GameCache.AllProps, Common.propsSort)
	    end
    end
end

function GameCache.minusProps(id, minusNum)
    local value = GameCache.AllProps[id]
    if value then
    	value.Num = value.Num - minusNum
        if value.Num < 1 then
            GameCache.AllProps[id] = nil
        end
    end
end

function GameCache.minusFrag(id, minusNum)
    local value = GameCache.AllFrag[id]
    if value then
    	value.Num = value.Num - minusNum
        if value.Num < 1 then
            GameCache.AllFrag[id] = nil
        end
    end
end

--[[
-----------------------------------------------------------------
-----------------------------星将相关-----------------------------
]]--
function GameCache.GetAllHero()
    for k, v in pairs(GameCache.AllHero) do
        GameCache.updateHeroAttr(v)
    end
    return GameCache.AllHero
end

function GameCache.GetAllSoul()
    return GameCache.AllSoul
end

function GameCache.getHeroTotal()
    local totalNum = 0
    for k,v in pairs(GameCache.AllHero) do
        totalNum = totalNum + 1
    end
    return totalNum
end

function GameCache.GetHero(id)
    local hero = GameCache.AllHero[id]
    if hero then
        GameCache.updateHeroAttr(hero)
    end
    return hero
end

function GameCache.IsOwnHero(id)
    local hero = GameCache.AllHero[id]
    if hero ~= nil then return true end
    return false
end

function GameCache.GetSoul(id)
    return GameCache.AllSoul[id]
end

function GameCache.addNewHero(id, starLevel)
    local hero = {}
    hero.ID = id
    hero.StarLevel = starLevel or 0
    hero.Level = 1
    hero.Exp = 0
    hero.RPSkillLevel = 1
    hero.RPSkillExp = 0
    hero.Equip = {}
    for i=BaseConfig.ET_ARM,BaseConfig.ET_BOOK do
        local ep = {}
        ep.ID = 0
        ep.SkinID = 0
        ep.Level = 0
        ep.StarLevel = 0
        ep.Exp = 0
        hero.Equip[i] = ep
    end
    hero.SkinList = {}
    hero.SkinStatus = {{ID = 0}, {ID = 0}}

    if hero then
        GameCache.updateHeroAttr(hero)
    end
    
    GameCache.AllHero[id] = hero
    return hero
end

function GameCache.addSoul(soulInfo, isTotalNum)
    local isHave = false
    local value = GameCache.AllSoul[soulInfo.ID]
    if value then
        isHave = true
        if isTotalNum then
            value.Num = soulInfo.Num
        else
            value.Num = value.Num + soulInfo.Num
        end
    end

    if not isHave then
        GameCache.AllSoul[soulInfo.ID] = soulInfo
    end
end

function GameCache.minusSoul(id, minusNum)
    local value = GameCache.AllSoul[id]
    if value then
        value.Num = value.Num - minusNum
        if value.Num < 1 then
            GameCache.AllSoul[id] = nil
        end
    end
end

------------------------------------ 好友相关 ------------------------------------

--  添加好友
function GameCache.AddFriend(friend_rid, isAgree)
	for i, v in pairs(GameCache.FriendInfo.AddRequest) do
        if v.RID == friend_rid then
            table.remove(GameCache.FriendInfo.AddRequest, i)
            if isAgree then
                 GameCache.FriendInfo.FriendList[friend_rid] = v
            end
            break
        end
    end
end

-- 改变领取状态
function GameCache:acceptPowerFromFriend(friendID)
    for k,v in pairs(GameCache.FriendInfo.FriendList) do
        if v.RID == friendID then
            v.IsReceivePower = false
            break
        end
    end
end

function GameCache.getFriendsList()
    return GameCache.FriendInfo.FriendList
end

function GameCache.getFriendInfo(rid)
    return GameCache.FriendInfo.FriendList[rid]
end

function GameCache.deletaFriend(rid)
    GameCache.FriendInfo.FriendList[rid] = nil
end

function GameCache.getCurrFriendNum()
    local totalNum = 0
    for k,v in pairs(GameCache.FriendInfo.FriendList) do
        totalNum = totalNum + 1
    end
    return totalNum
end

function GameCache.getMaxFriendNum()
    return GameCache.FriendInfo.MaxFriendNum
end

function GameCache.getAddRequest()
    return GameCache.FriendInfo.AddRequest
end

function GameCache.getSuggestList()
    return GameCache.FriendInfo.SuggestList
end

function GameCache.addDailyPower(powerNum)
    local maxPower = 20
    if GameCache.FriendInfo.DailyAcceptPower >= maxPower then
        GameCache.FriendInfo.DailyAcceptPower = maxPower
        return false
    else
        GameCache.FriendInfo.DailyAcceptPower = GameCache.FriendInfo.DailyAcceptPower + powerNum
        if GameCache.FriendInfo.DailyAcceptPower >= maxPower then
            GameCache.FriendInfo.DailyAcceptPower = maxPower
        end
        return true
    end
end

---------------------------仙女-----------------------
function GameCache.GetFairyInfo(id)
    return GameCache.AllFairy[id]
end

------------------------------------ 战斗阵型相关 ------------------------------------
GameCache.FORM_TYPE_DEFAULT = 1
GameCache.FORM_TYPE_INSTANCE = GameCache.FORM_TYPE_DEFAULT
GameCache.FORM_TYPE_ARENA = 2
GameCache.FORM_TYPE_VEHICLE = 3
GameCache.FORM_TYPE_LOOT = 4
GameCache.FORM_TYPE_TOWER = 5
GameCache.FORM_TYPE_DAILY = 6
GameCache.FORM_TYPE_ARENA_DEFENSE = 7
GameCache.FORM_TYPE_VEHICLE_DEFENSE = 8
GameCache.FORM_TYPE_HOME = 9
GameCache.FORM_TYPE_HOME_DEFENSE = 10
GameCache.FORM_TYPE_LOOT_DEFENSE = 11
GameCache.FORM_TYPE_COUNT = GameCache.FORM_TYPE_LOOT_DEFENSE

GameCache.FormNameTable = {
	[GameCache.FORM_TYPE_INSTANCE] = "副本",
    [GameCache.FORM_TYPE_ARENA] = "竞技场",
    [GameCache.FORM_TYPE_VEHICLE] = "运镖",
    [GameCache.FORM_TYPE_LOOT] = "夺宝",
    [GameCache.FORM_TYPE_TOWER] = "爬塔",
    [GameCache.FORM_TYPE_DAILY] = "每日副本",
    [GameCache.FORM_TYPE_ARENA_DEFENSE] = "竞技场防守",
    [GameCache.FORM_TYPE_VEHICLE_DEFENSE] = "运镖防守",
    [GameCache.FORM_TYPE_HOME] = "家园",
    [GameCache.FORM_TYPE_HOME_DEFENSE] = "家园防守",
    [GameCache.FORM_TYPE_LOOT_DEFENSE] = "夺宝防守",
}

function GameCache.GetFormName(form_type)
    assert(form_type >= GameCache.FORM_TYPE_DEFAULT and form_type <= GameCache.FORM_TYPE_COUNT, string.format("Invalid form type: %d!", form_type))
    local name = GameCache.FormNameTable[form_type] or "未定义"
    return name
end

return GameCache
