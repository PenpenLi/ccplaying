-- 策划配置

local __tostring = tostring
local tostring = function(val)
	if type(val) == "number" then
		return string.format("%d", val)
	else
		return __tostring(val)
	end
end

local json = require("tool.lib.json")
local CF = import(".cf")

local CONFIG_FORMAT_RAW = 1
local CONFIG_FORMAT_ZIP = 2

local ConfigFormat = CONFIG_FORMAT_RAW

local BaseConfig = {}

-- 资质范围
BaseConfig.MIN_TALENT = 10
BaseConfig.MAX_TALENT = 15

-- 星将星级范围
BaseConfig.MIN_HERO_STAR_LEVEL = 0
BaseConfig.MAX_HERO_STAR_LEVEL = 12

-- 缘分搭配类型
BaseConfig.HERO_FATE_TYPE = 1 -- 星将搭配缘分
BaseConfig.EQUIP_FATE_TYPE = 2 -- 装备搭配缘分

-- 法宝（包含符咒和天书）的最高等级
BaseConfig.MAX_TREASURE_LEVEL = 20

BaseConfig.WX_NAME = {"金", "木", "水", "火", "土"}
BaseConfig.ARM_TYPE_NAME = {"长柄", "短柄", "法宝"}
BaseConfig.EQUIP_TYPE_NAME = {"武器", "头盔", "戒指", "衣服", "符咒", "天书"}
BaseConfig.BATTLE_TYPE_NAME = {"近战", "远程", "超远"}

BaseConfig.OpenSystemLevel = {["gamble"] = 4, ["heroSkill"] = 8, ["task"] = 10, ["energy"] = 12, ["loot"] = 14,
						 ["fairy"] = 15, ["arena"] = 16, ["home"] = 18, ["instanceDaily"] = 20,
						 ["transport"] = 25, ["tower"] = 30, ["apartment"] = 40 }

BaseConfig.ApartmentType = {["atk_near"] = 1, ["atk_far"] = 2, ["atk_sfar"] = 3, ["gender_male"] = 4, ["gender_female"] = 5,
							["move_foot"] = 6, ["move_fly"] = 7, ["all"] = 8}

-- 装备类型定义
BaseConfig.ET_ARM   = 1 -- 武器
BaseConfig.ET_HAT   = 2 -- 头盔
BaseConfig.ET_RING  = 3 -- 戒指
BaseConfig.ET_COAT  = 4 -- 衣服
BaseConfig.ET_MAGIC = 5 -- 符咒
BaseConfig.ET_BOOK  = 6 -- 天书

-- 物品类型定义
BaseConfig.GT_HERO = 1 -- 星将
BaseConfig.GT_SOUL = 2 -- 将魂
BaseConfig.GT_FAIRY = 3 -- 仙女
BaseConfig.GT_MONEY = 4 -- 货币
BaseConfig.GT_EQUIP = 5 -- 装备
BaseConfig.GT_PROPS = 6 -- 道具
BaseConfig.GT_WORK = 7 -- 工事
BaseConfig.GT_STONE = 8 -- 灵石
BaseConfig.GT_TREASURE_FRAG = 9 -- 宝物碎片
BaseConfig.GT_HEROSKIN = 10 -- 时装
BaseConfig.GT_AVATAR = 11 -- 角色属性值
BaseConfig.GT_VALUE = 12 -- 倍率

-- 兑换商店类型定义
BaseConfig.MALL_TYPE_STORE = 1 --综合商店
BaseConfig.MALL_TYPE_EQUIP_RECYCLE = 2 --装备商店
BaseConfig.MALL_TYPE_ARENA = 3 --竞技场商店
BaseConfig.MALL_TYPE_HOME = 4 --功勋商店
BaseConfig.MALL_TYPE_CONSUME = 5 -- 消费积分商店
BaseConfig.MALL_TYPE_FRIEND = 6 --侠义值商店
BaseConfig.MALL_TYPE_LEAGUE_DEVOTE = 7 --帮会商店

-- 公共ICON类型定义
BaseConfig.GOODS_HERO = 1
BaseConfig.GOODS_SOUL = 2
BaseConfig.GOODS_EQUIP = 3
BaseConfig.GOODS_PROPS = 4
BaseConfig.GOODS_FRAG = 5
BaseConfig.GOODS_SKILL = 6
-- 公共ICON大小类型定义
BaseConfig.GOODS_BIGTYPE = 1
BaseConfig.GOODS_MIDDLETYPE = 2
BaseConfig.GOODS_SMALLTYPE = 3
BaseConfig.GOODS_LEASTTYPE = 4
-- 音乐
BaseConfig.isPlayMusic = true
-- 音效
BaseConfig.isPlaySound = true

BaseConfig.isShowOthers = false

-- 升星丹ID
BaseConfig.upgradeStarPillID = nil

-- 神仙学院加成属性类型枚举
BaseConfig.ENERGYATTR_TYPE_ADDNORSKILLLEVEL = 11
BaseConfig.ENERGYATTR_TYPE_ADDTFSKILLLEVEL = 12
BaseConfig.ENERGYATTR_TYPE_ADDRPSKILLLEVEL = 13


local app = cc.Application:getInstance()
BaseConfig.targetPlatform = app:getTargetPlatform()
if BaseConfig.targetPlatform == cc.PLATFORM_OS_IPHONE or BaseConfig.targetPlatform == cc.PLATFORM_OS_IPAD  then
	BaseConfig.fontname = "DFYuanW7-GBK"
else
	BaseConfig.fontname = "fonts/DFYuanW7-GBK.ttf"
end


-- 公式格式化字符串
BaseConfig.FORMULA_FORMAT_STR = [[
    local __formula__function__ = function (params)
        local A = params.A
        local D = params.D
        local restraint = params.restraint
        local comboHit = params.combHit
        local skillLV = params.skillLV
        local dist = params.dist
        local MIN = params.MIN
        local MAX = params.MAX
        return %s
    end
    return __formula__function__
]]

function BaseConfig.purgeMemory()
	--BaseConfig.equipConfig = nil
	--BaseConfig.heroConfig = nil
	BaseConfig.soulConfig = nil
	-- BaseConfig.propsConfig = nil
	-- BaseConfig.heroSkillConfig = nil
	BaseConfig.soulToHeroConfig = nil
	BaseConfig.fragToEquipConfig = nil
	BaseConfig.heroExpConfig = nil
	BaseConfig.heroUpstarConfig = nil
	BaseConfig.heroRPSkillExpConfig = nil
	BaseConfig.equipUpgradeConfig = nil
	BaseConfig.equipUpstarCommonConfig = nil
	BaseConfig.equipUpstarSpecialConfig = nil
	BaseConfig.fateConfig = nil
	BaseConfig.treasureConfig = nil
	BaseConfig.trumpUpgradeConfig = nil
	BaseConfig.fairyConfig = nil
	BaseConfig.godConfig = nil
	BaseConfig.vehicleConfig = nil
	BaseConfig.nodeSequenceConfig = nil
	BaseConfig.instanceChapterConfig = nil
	BaseConfig.instanceNodeConfig = nil
	BaseConfig.trapConfig = nil
	BaseConfig.obstacleConfig = nil
	BaseConfig.turretConfig = nil
	BaseConfig.monsterConfig = nil
	BaseConfig.buffConfig = nil
	BaseConfig.formulaConfig = nil
	BaseConfig.formulaFunc = nil
	BaseConfig.AIConfig = nil
	BaseConfig.GoodsSourceConfig = nil
	BaseConfig.skinConfig = nil
	BaseConfig.dropsConfig = nil
	BaseConfig.energyConfig = nil
	BaseConfig.fairySkillConfig = nil
	BaseConfig.fairyExpConfig = nil
	BaseConfig.taskConfig = nil
	BaseConfig.achievementConfig = nil
	BaseConfig.vipConfig = nil
	BaseConfig.purchaseConfig = nil
	BaseConfig.activityLevelConfig = nil
	BaseConfig.activityLoginConfig = nil
	BaseConfig.activityBarAwards = nil
	BaseConfig.activityBarPrice = nil
	BaseConfig.vipPrivilegeConfig = nil
	BaseConfig.vipDescConfig = nil
	BaseConfig.instanceDailyConfig = nil
	BaseConfig.cointreeConfig = nil
	BaseConfig.roleExp = nil
	BaseConfig.heroScale = nil
	BaseConfig.soundHero = nil
	BaseConfig.buyPriceConfig = nil
	BaseConfig.home_metal = nil
	BaseConfig.home_wood = nil
	BaseConfig.home_pill = nil
	BaseConfig.home_stone = nil
	BaseConfig.home_decoration = nil
	BaseConfig.home_heroSoul = nil
	BaseConfig.currencyConfig = nil
	BaseConfig.loot_draw = nil
	BaseConfig.tower = nil
	BaseConfig.system_open = nil
	BaseConfig.bee = nil
	BaseConfig.hero_upgrade_cost = nil
	BaseConfig.introduceConfig = nil
	BaseConfig.battleConsume = nil
	BaseConfig.dialogue = nil
	BaseConfig.firstName = nil
	BaseConfig.liastName = nil
	BaseConfig.fairyCrit = nil
	BaseConfig.fairy_buySkillpoint = nil
	BaseConfig.fighting_NPC = nil
	BaseConfig.name_award = nil
	BaseConfig.hero_apartment = nil
	BaseConfig.hero_apartment_rule = nil
	BaseConfig.first_recharge_gift = nil
	BaseConfig.energy_upgrade = nil
	BaseConfig.recommend_hero = nil
	BaseConfig.discount_purchase = nil
	BaseConfig.growth_fund = nil
	BaseConfig.accumulate_purchase = nil
	BaseConfig.level_limit = nil
	BaseConfig.seven_recharge = nil
	BaseConfig.seven_quest = nil
	BaseConfig.seven_sale = nil
	BaseConfig.fairy_property = nil
end

function BaseConfig.preLoad()
	BaseConfig.heroSkillConfig = BaseConfig.readConfigData(CF.HERO_SKILL)

	if BaseConfig.fairyExpConfig == nil then
		BaseConfig.getFairyExpConfig()
	end

	if BaseConfig.purchaseConfig == nil then
		BaseConfig.purchaseConfig = BaseConfig.readConfigData(CF.PURCHASE)
	end

	if BaseConfig.propsConfig == nil then
		BaseConfig.AllPropsConfig()
	end

	BaseConfig.AllEquipConfig()

	local isBeginGame = cc.UserDefault:getInstance():getBoolForKey("init")
	if not isBeginGame then
		cc.UserDefault:getInstance():setBoolForKey("init", true)
		cc.UserDefault:getInstance():setBoolForKey("music", BaseConfig.isPlayMusic)
		cc.UserDefault:getInstance():setBoolForKey("sound", BaseConfig.isPlaySound)
		cc.UserDefault:getInstance():setBoolForKey("morePerformance", true)
		cc.UserDefault:getInstance():setBoolForKey("morePeople", false)
		cc.UserDefault:getInstance():flush()
	else
		BaseConfig.isPlayMusic = cc.UserDefault:getInstance():getBoolForKey("music")
		BaseConfig.isPlaySound = cc.UserDefault:getInstance():getBoolForKey("sound")
	end

	if cc.UserDefault:getInstance():getBoolForKey("morePeople") then
		BaseConfig.isShowOthers = true
	else
		BaseConfig.isShowOthers = false
	end
	if cc.UserDefault:getInstance():getBoolForKey("morePerformance") then
		cc.Director:getInstance():setAnimationInterval(1.0 / 60.0)
	else
		cc.Director:getInstance():setAnimationInterval(1.0 / 40.0)
	end
end
--------------------------------  获取所有配置 --------------------------------
function BaseConfig.AllTreasureConfig()
	if BaseConfig.treasureConfig == nil then
		BaseConfig.treasureConfig = BaseConfig.readConfigData(CF.TREASURE)
	end

	return BaseConfig.treasureConfig
end

function BaseConfig.AllEquipConfig()
	if BaseConfig.equipConfig == nil then
		BaseConfig.equipConfig = BaseConfig.readConfigData(CF.EQUIP)
	end

	return BaseConfig.equipConfig
end

function BaseConfig.AllPropsConfig()
	if BaseConfig.propsConfig == nil then
		BaseConfig.propsConfig = BaseConfig.readConfigData(CF.PROPS)
		for _, v in pairs(BaseConfig.propsConfig) do
			if v.type == 5 then
				BaseConfig.upgradeStarPillID = v.id
				break
	        end
		end
	end
	return BaseConfig.propsConfig
end

function BaseConfig.AllFairyConfig()
	if BaseConfig.fairyConfig == nil then
		BaseConfig.fairyConfig = BaseConfig.readConfigData(CF.FAIRY)
	end

	return BaseConfig.fairyConfig
end

function BaseConfig.getFairySkillUpgradePrice(level)
	if BaseConfig.fairySkillConfig == nil then
		BaseConfig.fairySkillConfig = BaseConfig.readConfigData(CF.FAIRY_SKILL)
	end

	local result = assert(BaseConfig.fairySkillConfig[level])
	return result
end

function BaseConfig.getFairyExpConfig()
	if BaseConfig.fairyExpConfig == nil then
		BaseConfig.fairyExpConfig = BaseConfig.readConfigData(CF.FAIRY_EXP)
	end
	return BaseConfig.fairyExpConfig
end

function BaseConfig.getFairyExp(level)
	if BaseConfig.fairyExpConfig == nil then
		BaseConfig.fairyExpConfig = BaseConfig.readConfigData(CF.FAIRY_EXP)
	end

	local result = assert(BaseConfig.fairyExpConfig[level])
	return result
end

-- 仙女暴击
function BaseConfig.getFairyCritConfig()
	if BaseConfig.fairyCrit == nil then
		BaseConfig.fairyCrit = BaseConfig.readConfigData(CF.FAIRYCRIT)
	end
	return BaseConfig.fairyCrit
end

-- 仙女红心连续购买
function BaseConfig.getFairyBuySkillpointConfig(count)
	if BaseConfig.fairy_buySkillpoint == nil then
		BaseConfig.fairy_buySkillpoint = {}
		local fairy_buySkillpoint = BaseConfig.readConfigData(CF.BUY_FAIRY_SKILLPOINT)
		for k,v in pairs(fairy_buySkillpoint) do
			BaseConfig.fairy_buySkillpoint[v.Count] = v
		end
	end
	local result = assert(BaseConfig.fairy_buySkillpoint[count], string.format("error %d", count))
	return result
end

-- 仙女升级增加的属性
function BaseConfig.getFairyPropertyConfig(level)
	if BaseConfig.fairy_property == nil then
		BaseConfig.fairy_property = BaseConfig.readConfigData(CF.FAIRY_PROPERTY)
	end
	local result = assert(BaseConfig.fairy_property[level], string.format("error %d", level))
	return result
end

function BaseConfig.AllFateConfig()
	if BaseConfig.fateConfig == nil then
		BaseConfig.fateConfig = BaseConfig.readConfigData(CF.FATE)
	end

	return BaseConfig.fateConfig
end

function BaseConfig.AllMonsterConfig()
	if BaseConfig.monsterConfig == nil then
		BaseConfig.monsterConfig = BaseConfig.readConfigData(CF.MONSTER)
	end

	return BaseConfig.monsterConfig
end

function BaseConfig.readData(cf)
	if ConfigFormat == CONFIG_FORMAT_ZIP then
		local dataPath = cc.FileUtils:getInstance():fullPathForFilename("script/G.data") 
		local str = cc.FileUtils:getInstance():getFileDataFromZip(dataPath , tostring(cf .. ".json"))
		local v = json.decode(str)
		return v
	else
		local dataPath = cc.FileUtils:getInstance():fullPathForFilename(tostring("script/json/" .. cf .. ".json")) 
		local str = cc.FileUtils:getInstance():getStringFromFile(dataPath)
		local v = json.decode(str)
		return v
	end
end

function BaseConfig.readConfigData(cf)
	local packageName = "config.gamedata." .. cf
	local config = require(packageName)

	-- 不缓存在这里
	package.loaded[packageName] = nil

	return config
end

-------------------------------- 获取指定配置项  --------------------------------
function BaseConfig.GetEquip(id, star_level)
	-- if id == 1002 then CCLog("-------------------->") end
	if not star_level then
		-- if id == 1002 then CCLog("1") end
        local fragToEquipConfig = BaseConfig.GetFragToEquip(id)
        star_level = fragToEquipConfig.starLevel
    end
    -- if id == 1002 then CCLog("2") end
    if BaseConfig.equipConfig == nil then
		BaseConfig.AllEquipConfig()
	end

	local result
	local item = BaseConfig.equipConfig.Data[id]
	if item then
		if item.type > 4 then
			_, result = next(item.starLevel_List)
		else
			-- if id == 1002 then CCLog("3") end
			result = item.starLevel_List[star_level]
			-- if id == 1002 then CCLog(star_level, ", ", vardump(result), ", ", vardump(item)) end
		end
		-- if id == 1002 then CCLog("4") end
		if nil == result then
			-- if id == 1002 then CCLog("5") end
			result = item.starLevel_List[0]
		end
	end
	-- if id == 1002 then CCLog("<--------------------") end
	return result
end

function BaseConfig.filtrateEquipConfig()
	BaseConfig.AllEquipConfig()

	if not BaseConfig.isFiltrateEquip then
		BaseConfig.isFiltrateEquip = true
		BaseConfig.filtrateEquipConfigTab = {}
		BaseConfig.filtrateEquipConfigTab[BaseConfig.ET_ARM] = {}
		BaseConfig.filtrateEquipConfigTab[BaseConfig.ET_HAT] = {}
		BaseConfig.filtrateEquipConfigTab[BaseConfig.ET_RING] = {}
		BaseConfig.filtrateEquipConfigTab[BaseConfig.ET_COAT] = {}
		BaseConfig.filtrateEquipConfigTab[BaseConfig.ET_MAGIC] = {}
		BaseConfig.filtrateEquipConfigTab[BaseConfig.ET_BOOK] = {}

		for k,equipConfig in pairs(BaseConfig.equipConfig.Data) do
	        local equipmentType = equipConfig.type 
	        if equipmentType == BaseConfig.ET_ARM then
	            table.insert(BaseConfig.filtrateEquipConfigTab[BaseConfig.ET_ARM], equipConfig)
	        elseif equipmentType == BaseConfig.ET_HAT then
	            table.insert(BaseConfig.filtrateEquipConfigTab[BaseConfig.ET_HAT], equipConfig)
	        elseif equipmentType == BaseConfig.ET_RING then
	            table.insert(BaseConfig.filtrateEquipConfigTab[BaseConfig.ET_RING], equipConfig)
	        elseif equipmentType == BaseConfig.ET_COAT then
	            table.insert(BaseConfig.filtrateEquipConfigTab[BaseConfig.ET_COAT], equipConfig)
	        elseif equipmentType == BaseConfig.ET_MAGIC then
	            table.insert(BaseConfig.filtrateEquipConfigTab[BaseConfig.ET_MAGIC], equipConfig)
	        elseif equipmentType == BaseConfig.ET_BOOK then
	            table.insert(BaseConfig.filtrateEquipConfigTab[BaseConfig.ET_BOOK], equipConfig)
	        end
	    end
	end
end

function BaseConfig.cleanFiltrateEquipConfig()
	BaseConfig.isFiltrateEquip = false
	BaseConfig.filtrateEquipConfigTab = nil
end

function BaseConfig.GetHero(id, star_level)
	if BaseConfig.heroConfig == nil then	
		BaseConfig.heroConfig = BaseConfig.readConfigData(CF.HERO)
	end

	if star_level == nil then
		-- 读取初始星级
		local cfSoul = BaseConfig.GetSoul(id)
		star_level = cfSoul.starLevel
	end

	local result = assert(BaseConfig.heroConfig:Get(id, star_level), string.format("%d, %d", id, star_level))
	return result
end

function BaseConfig.GetSoul(id)
	if BaseConfig.soulConfig == nil then
		BaseConfig.soulConfig = BaseConfig.readConfigData(CF.SOUL)
	end

	local result = assert(BaseConfig.soulConfig[id], string.format("error %d", id))
	return result
end

function BaseConfig.GetHeroScale(id)
	if BaseConfig.heroScale == nil then
		BaseConfig.heroScale = BaseConfig.readConfigData(CF.HERO_SCALE)
	end

	local result = assert(BaseConfig.heroScale[id], string.format("error %d", id))
	return result
end

function BaseConfig.GetSoundHero(id)
	if BaseConfig.soundHero == nil then
		BaseConfig.soundHero = BaseConfig.readConfigData(CF.SOUND_HERO)
	end

	local result =  BaseConfig.soundHero[id]
	if result == nil then 
		CCLog(string.format("GetSoundHero(%d) return nil", id))
	end

	return result
end

function BaseConfig.GetProps(id)
	BaseConfig.AllPropsConfig()
	local result = assert(BaseConfig.propsConfig[id], string.format("error %d", id))
	return result
end

function BaseConfig.GetHeroSkill(skill_id, skill_level)
	if BaseConfig.heroSkillConfig == nil then
		BaseConfig.heroSkillConfig = BaseConfig.readConfigData(CF.HERO_SKILL)
	end
	local result = BaseConfig.heroSkillConfig:Get(skill_id, skill_level)
	return result
end

-- 星将召唤需要的魂数量
function BaseConfig.GetHeroNeedSoulCount(star_level)
	if BaseConfig.soulToHeroConfig == nil then
		BaseConfig.soulToHeroConfig = BaseConfig.readConfigData(CF.SOUL_TO_HERO)
	end

	local result = assert(BaseConfig.soulToHeroConfig[star_level])
	return result
end

-- 装备碎片合成装备(参数：合成id)
function BaseConfig.GetFragToEquip(compoud_id)
	if BaseConfig.fragToEquipConfig == nil then
		BaseConfig.fragToEquipConfig =  BaseConfig.readConfigData(CF.FRAG_TO_EQUIP)
	end

	local result = assert(BaseConfig.fragToEquipConfig[compoud_id], string.format("%d", compoud_id))
	return result
end

-- 星将升级所需经验
-- key: talent, value: exp 1 ~ 99
function BaseConfig.GetHeroUpgradeExp(hero_talent, cur_level)
	if BaseConfig.heroExpConfig == nil then
		BaseConfig.heroExpConfig = BaseConfig.readConfigData(CF.HERO_EXP)
	end
	
	local result = assert(BaseConfig.heroExpConfig[hero_talent][cur_level])
	return result
end

-- 星将升级花费
function BaseConfig.GetHeroUpgradeCost(propsID)
	if BaseConfig.hero_upgrade_cost == nil then
		BaseConfig.hero_upgrade_cost = BaseConfig.readConfigData(CF.HERO_UPGRADE_COST)
	end

	local result = assert(BaseConfig.hero_upgrade_cost[propsID])
	return result
end

-- 星将升星配置
function BaseConfig.GetHeroUpstar(star_level)
	if BaseConfig.heroUpstarConfig == nil then
		BaseConfig.heroUpstarConfig = BaseConfig.readConfigData(CF.HERO_STAR)
	end

	local result = BaseConfig.heroUpstarConfig[star_level]
	return result
end

-- 星将怒气技能升级经验（参数为当前等级，返回值为当前等级满经验)
function BaseConfig.GetHeroRPSkillExp(rpskill_level)
	if BaseConfig.heroRPSkillExpConfig == nil then
		BaseConfig.heroRPSkillExpConfig = {}
		BaseConfig.heroRPSkillExpConfig = BaseConfig.readConfigData(CF.RPSKILL_EXP)
	end
	
	local result = assert(BaseConfig.heroRPSkillExpConfig[rpskill_level], string.format("%d", rpskill_level))
	return result
end

-- 装备升级 (参数为当前等级，返回值为当前等级满经验)
function BaseConfig.GetEquipUpgrade(level)
	if BaseConfig.equipUpgradeConfig == nil then
		BaseConfig.equipUpgradeConfig = BaseConfig.readConfigData(CF.EQUIP_UPGRADE)
	end

	local result = assert(BaseConfig.equipUpgradeConfig[level])
	return result
end

-- 装备升星 (参数为目标星级，返回值为升星到目标星级的配置)
function BaseConfig.GetEquipUpstarCommon(star_level)
	if BaseConfig.equipUpstarCommonConfig == nil then
		BaseConfig.equipUpstarCommonConfig = BaseConfig.readConfigData(CF.EQUIP_UPSTAR_COMMON)
	end

	local result = assert(BaseConfig.equipUpstarCommonConfig[star_level], string.format("%d", star_level))
	return result
end

function BaseConfig.GetEquipUpstarSpecial(id, star_level)
	if BaseConfig.equipUpstarSpecialConfig == nil then
		BaseConfig.equipUpstarSpecialConfig = BaseConfig.readConfigData(CF.EQUIP_UPSTAR_SPECIAL)
	end

	local result = assert(BaseConfig.equipUpstarSpecialConfig:Get(id, star_level), string.format("error %d : %d", id, star_level))
	return result
end

-- 缘分搭配
function BaseConfig.GetFate(hero_id, fate_type)
	BaseConfig.AllFateConfig()
	local result = assert(BaseConfig.fateConfig[hero_id][fate_type])
	return result
end

-- 法宝
function BaseConfig.GetTreasure(treasure_id, frag_seat)
	BaseConfig.AllTreasureConfig()
	local result = assert(BaseConfig.treasureConfig:Get(treasure_id ,frag_seat), string.format("error %d : %d", treasure_id, frag_seat))
	return result
end

-- 法宝升级 (参数为当前等级，返回值为当前等级满经验)
function BaseConfig.GetTrumpUpgrade(level)
	if BaseConfig.trumpUpgradeConfig == nil then
		BaseConfig.trumpUpgradeConfig = BaseConfig.readConfigData(CF.TRUMP_EXP)
	end

	local result = assert(BaseConfig.trumpUpgradeConfig[level])
	return result
end

-- 获取物品途径
function BaseConfig.GetGoodsSource(goodsType, goodsID)
	if BaseConfig.GoodsSourceConfig == nil then
		BaseConfig.GoodsSourceConfig = BaseConfig.readConfigData(CF.GOODS_SOURCE)
	end

	local result = assert(BaseConfig.GoodsSourceConfig:Get(goodsType, goodsID), string.format("error %d : %d", goodsType, goodsID))
	return result
end

-- 法宝升级消耗法宝获取的经验值
function BaseConfig.GetConsumeTrumpGainExp(talent)
	local exp = { [10] = 130, [11] = 170, [12] = 200, [13] = 220, [14] = 240, [15] = 260 }
	local result = assert(exp[talent])
	return result
end

-- 元神
function BaseConfig.getEnergyInfo(id)
	if BaseConfig.energyConfig == nil then
		BaseConfig.energyConfig = BaseConfig.readConfigData(CF.ENERGY)
	end
	local result = assert(BaseConfig.energyConfig[id], string.format("error %d", id))
	return result
end

function BaseConfig.getEnergyUpgrade(id)
	if BaseConfig.energy_upgrade == nil then
		BaseConfig.energy_upgrade = BaseConfig.readConfigData(CF.ENERGY_UPGRADE)
	end
	local result = assert(BaseConfig.energy_upgrade[id], string.format("error %d", id))
	return result
end

-- 仙女
function BaseConfig.GetFairy(fairy_id)
	if BaseConfig.fairyConfig == nil then
		BaseConfig.fairyConfig = BaseConfig.readConfigData(CF.FAIRY)
	end

	local result = assert(BaseConfig.fairyConfig[fairy_id])
	return result
end

-- 每日副本
function BaseConfig.getInstanceDaily(id, difficulty)
	if BaseConfig.instanceDailyConfig == nil then
		BaseConfig.instanceDailyConfig = BaseConfig.readConfigData(CF.INSTANCE_DAILY)
	end
	local result = assert(BaseConfig.instanceDailyConfig:Get(id, difficulty), string.format("error %d: %d", id, difficulty))
	return result
end

-- 每日任务
function BaseConfig.getTask(taskID)
	if BaseConfig.taskConfig == nil then
		BaseConfig.taskConfig = BaseConfig.readConfigData(CF.TASK)
	end
	local result = assert(BaseConfig.taskConfig[taskID], string.format("error %d", taskID))
	return result
end

-- 成就
function BaseConfig.getAchievement(id)
	if BaseConfig.achievementConfig == nil then
		BaseConfig.achievementConfig = BaseConfig.readConfigData(CF.ACHIEVEMENT)
	end
	local result = assert(BaseConfig.achievementConfig[id], string.format("error %d", id))
	return result
end

-- vip经验
function BaseConfig.getVipExp(level)
	if BaseConfig.vipConfig == nil then
		BaseConfig.vipConfig = BaseConfig.readConfigData(CF.VIPEXP)
	end

	local result = assert(BaseConfig.vipConfig[level])
	return result
end

-- vip特权
function BaseConfig.getVipPrivilege(vipLevel)
	if BaseConfig.vipPrivilegeConfig == nil then
		BaseConfig.vipPrivilegeConfig = BaseConfig.readConfigData(CF.VIP_PRIVILEGE)
	end
	local result = assert(BaseConfig.vipPrivilegeConfig[vipLevel], string.format("error %d", vipLevel))
	return result
end

-- vip特权描述
function BaseConfig.getVipDesc(id)
	if BaseConfig.vipDescConfig == nil then
		BaseConfig.vipDescConfig = BaseConfig.readConfigData(CF.VIP_DESC)
	end
	local result = assert(BaseConfig.vipDescConfig[id], string.format("error %d", id))
	return result
end
-----------活动中心--------------
-- 角色升级奖励
function BaseConfig.getActivityLevelAward(level)
	if BaseConfig.activityLevelConfig == nil then
		BaseConfig.activityLevelConfig = BaseConfig.readConfigData(CF.ACTIVITY_AVATAR_LEVEL)
	end
	local result = assert(BaseConfig.activityLevelConfig[level], string.format("error %d", level))
	return result
end

-- 连续登录奖励
function BaseConfig.getActivityLoginAward(day)
	if BaseConfig.activityLoginConfig == nil then
		BaseConfig.activityLoginConfig = BaseConfig.readConfigData(CF.ACTIVITY_WEEK_LOGIN)
	end
	local result = assert(BaseConfig.activityLoginConfig[day], string.format("error %d", day))
	return result
end

function BaseConfig.getLoginPurchaseConfig(day)
	if BaseConfig.seven_recharge == nil then
		BaseConfig.seven_recharge = BaseConfig.readConfigData(CF.SEVEN_RECHARGE)
	end
	local result = assert(BaseConfig.seven_recharge[day], string.format("error %d", day))
	return result
end

function BaseConfig.getLoginTaskConfig(id)
	if BaseConfig.seven_quest == nil then
		BaseConfig.seven_quest = BaseConfig.readConfigData(CF.SEVEN_QUEST)
	end
	local result = assert(BaseConfig.seven_quest[id], string.format("error %d", id))
	return result
end

function BaseConfig.getLoginSaleConfig(day)
	if BaseConfig.seven_sale == nil then
		BaseConfig.seven_sale = BaseConfig.readConfigData(CF.SEVEN_SALE)
	end
	local result = assert(BaseConfig.seven_sale[day], string.format("error %d", day))
	return result
end

-- 拉吧奖励列表
function BaseConfig.getActivityBarAwards()
	if BaseConfig.activityBarAwards == nil then
		BaseConfig.activityBarAwards = BaseConfig.readConfigData(CF.ACTIVITY_BAR_AWARDS)
	end
	return BaseConfig.activityBarAwards
end

-- 拉吧费用
function BaseConfig:getActivityBarPrice(count)
	if BaseConfig.activityBarPrice == nil then
		BaseConfig.activityBarPrice = {}
		local activityBarPrice = BaseConfig.readConfigData(CF.ACTIVITY_BAR_PRICE)
		for k,v in pairs(activityBarPrice) do
			BaseConfig.activityBarPrice[v.Count] = v
		end
	end
	local result = assert(BaseConfig.activityBarPrice[count], string.format("error %d", count))
	return result
end

-- 推荐星将
function BaseConfig.getRecommendHeroConfig(id)
	if BaseConfig.recommend_hero == nil then
		BaseConfig.recommend_hero = {}
		BaseConfig.recommend_hero = BaseConfig.readConfigData(CF.RECOMMEND_HERO)
	end
	local result = assert(BaseConfig.recommend_hero[id], string.format("error %d", id))
	return result
end

-- 折扣
function BaseConfig.getDiscountConfig()
	if BaseConfig.discount_purchase == nil then
		BaseConfig.discount_purchase = {}
		BaseConfig.discount_purchase = BaseConfig.readConfigData(CF.DISCOUNT_PURCHASE)
	end
	return BaseConfig.discount_purchase
end

-- 基金
function BaseConfig.getFundConfig(level)
	if BaseConfig.growth_fund == nil then
		BaseConfig.growth_fund = {}
		BaseConfig.growth_fund = BaseConfig.readConfigData(CF.GROWTH_FUND)
	end
	if not level then
		return 
	end
	local result = assert(BaseConfig.growth_fund[level], string.format("error %d", level))
	return result
end
-- 累计充值
function BaseConfig.getAccumulatePurchaseConfig(gold)
	if BaseConfig.accumulate_purchase == nil then
		BaseConfig.accumulate_purchase = {}
		BaseConfig.accumulate_purchase = BaseConfig.readConfigData(CF.ACTIVITY_ACCUMULATE_PURCHASE)
	end
	if not gold then
		return 
	end
	local result = assert(BaseConfig.accumulate_purchase[gold], string.format("error %d", gold))
	return result
end
-- 等级限时礼包
function BaseConfig.getLevelLimitConfig(level)
	if BaseConfig.level_limit == nil then
		BaseConfig.level_limit = {}
		BaseConfig.level_limit = BaseConfig.readConfigData(CF.ACTIVITY_LEVEL_LIMIT)
	end
	if not level then
		return 
	end
	local result = assert(BaseConfig.level_limit[level], string.format("error %d", level))
	return result
end

-------------------------------


-- 家园(CEO工厂)
function BaseConfig.getHomeDecoration(level)
	if BaseConfig.home_decoration == nil then
		BaseConfig.home_decoration = BaseConfig.readConfigData(CF.HOME_DECORSTION)
		local maxLevel = 0
		for level, _ in pairs(BaseConfig.home_decoration) do			
			if level > maxLevel then
				maxLevel = level
			end
		end
		BaseConfig.homeDecorationMaxLevel = maxLevel
	end

	local result = assert(BaseConfig.home_decoration[level], string.format("error %d", level))
	return result
end

-- 家园(炼金工厂)
function BaseConfig.getHomeMetal(level)
	if BaseConfig.home_metal == nil then
		BaseConfig.home_metal = BaseConfig.readConfigData(CF.HOME_METAL)
		local maxLevel = 0
		for level, _ in pairs(BaseConfig.home_metal) do			
			if level > maxLevel then
				maxLevel = level
			end
		end
		BaseConfig.homeMetalMaxLevel = maxLevel
	end

	local result = assert(BaseConfig.home_metal[level], string.format("error %d", level))
	return result
end
-- 家园(木料工厂)
function BaseConfig.getHomeWood(level)
	if BaseConfig.home_wood == nil then
		BaseConfig.home_wood = BaseConfig.readConfigData(CF.HOME_WOOD)
		local maxLevel = 0
		for level, _ in pairs(BaseConfig.home_wood) do			
			if level > maxLevel then
				maxLevel = level
			end
		end
		BaseConfig.homeWoodMaxLevel = maxLevel
	end

	local result = assert(BaseConfig.home_wood[level], string.format("error %d", level))
	return result
end
-- 家园(丹药工厂)
function BaseConfig.getHomePill(level)
	if BaseConfig.home_pill == nil then
		BaseConfig.home_pill = BaseConfig.readConfigData(CF.HOME_PILL)
		local maxLevel = 0
		for level, _ in pairs(BaseConfig.home_pill) do			
			if level > maxLevel then
				maxLevel = level
			end
		end
		BaseConfig.homePillMaxLevel = maxLevel
	end

	local result = assert(BaseConfig.home_pill[level], string.format("error %d", level))
	return result
end

-- 家园(锻造石工厂)
function BaseConfig.getHomeStone(level)
	if BaseConfig.home_stone == nil then
		BaseConfig.home_stone = BaseConfig.readConfigData(CF.HOME_STONE)
		local maxLevel = 0
		for level, _ in pairs(BaseConfig.home_stone) do			
			if level > maxLevel then
				maxLevel = level
			end
		end
		BaseConfig.homeStoneMaxLevel = maxLevel
	end
	local result = assert(BaseConfig.home_stone[level], string.format("error %d", level))
	return result
end
-- 家园(将魂研究院)
function BaseConfig.getHomeSoul(level)
	if BaseConfig.home_heroSoul == nil then
		BaseConfig.home_heroSoul = BaseConfig.readConfigData(CF.HOME_HEROSOUL)
		local maxLevel = 0
		for level, _ in pairs(BaseConfig.home_heroSoul) do			
			if level > maxLevel then
				maxLevel = level
			end
		end
		BaseConfig.homeSoulMaxLevel = maxLevel
	end
	local result = assert(BaseConfig.home_heroSoul[level], string.format("error %d", level))
	return result
end

-- 货币
function BaseConfig.getCurrencyConfig(currencyID)
	if BaseConfig.currencyConfig == nil then
		BaseConfig.currencyConfig = BaseConfig.readConfigData(CF.CURRENCY)
	end
	local result = assert(BaseConfig.currencyConfig[currencyID], string.format("error %d", currencyID))
	return result
end

-- 夺宝奖励
function BaseConfig.getLootDraw()
	if BaseConfig.loot_draw == nil then
		BaseConfig.loot_draw = BaseConfig.readConfigData(CF.LOOT_DRAW)
	end
	return BaseConfig.loot_draw
end

-- 爬塔
function BaseConfig.getTower(floor)
	if BaseConfig.tower == nil then
		BaseConfig.tower =  BaseConfig.readConfigData(CF.TOWER)
	end
	local result = assert(BaseConfig.tower[floor], string.format("error %d", floor))
	return result
end
-- 筋斗云
function BaseConfig.getBeeConfig(id)
	if BaseConfig.bee == nil then
		BaseConfig.bee = BaseConfig.readConfigData(CF.BEE)
	end
	local result = assert(BaseConfig.bee[id], string.format("error %d", id))
	return result
end
function BaseConfig.getBeeCount()
	if BaseConfig.bee == nil then
		BaseConfig.bee = BaseConfig.readConfigData(CF.BEE)
	end
	return (#BaseConfig.bee)
end
-- 充值
function BaseConfig.getPurchaseConfig()
	if BaseConfig.purchaseConfig == nil then
		BaseConfig.purchaseConfig = BaseConfig.readConfigData(CF.PURCHASE)
	end
end
-- 首充
function BaseConfig.getFirstGift(id)
	if BaseConfig.first_recharge_gift == nil then
		BaseConfig.first_recharge_gift = BaseConfig.readConfigData(CF.FIRST_RECHARGE_GIFT)
	end
	local result = assert(BaseConfig.first_recharge_gift[id], string.format("error %d", id))
	return result
end

-- 运镖拜佛经验(参数：当前等级；返回值：当前等级满经验)
function BaseConfig.GetGodExp(level)
	if BaseConfig.godConfig == nil then
		BaseConfig.godConfig = BaseConfig.readConfigData(CF.GOD)
	end

	local result = assert(BaseConfig.godConfig[level])
	return result
end

-- 运镖镖车配置(参数：当前镖车id（品质）)
function BaseConfig.GetVehicle(quality)
	if BaseConfig.vehicleConfig == nil then
		BaseConfig.vehicleConfig = BaseConfig.readConfigData(CF.VEHICLE)
	end

	local result = assert(BaseConfig.vehicleConfig[quality])
	return result
end

-- 掉落组
function BaseConfig.GetDrops( dropid )
	if BaseConfig.dropsConfig == nil then
		BaseConfig.dropsConfig = BaseConfig.readConfigData(CF.DROP_GROUP)
	end

	local result = assert(BaseConfig.dropsConfig[dropid])
	return result
end

-- 副本相关
function BaseConfig.GetNodeSequenceByID(id)
	if BaseConfig.nodeSequenceConfig == nil then
		BaseConfig.nodeSequenceConfig = BaseConfig.readConfigData(CF.NODE_SEQUENCE)
	end

	local result = assert(BaseConfig.nodeSequenceConfig[id])
	return result
end

function BaseConfig.GetInstanceChapter(chapterid)
	if BaseConfig.instanceChapterConfig == nil then
		BaseConfig.instanceChapterConfig = BaseConfig.readConfigData(CF.INSTANCE_CHAPTER)
	end

	local result = assert(BaseConfig.instanceChapterConfig[chapterid])
	return result
end

function BaseConfig.GetInstanceChapterCount()
	if BaseConfig.instanceChapterConfig == nil then
		BaseConfig.instanceChapterConfig = BaseConfig.readConfigData(CF.INSTANCE_CHAPTER)
	end


	return #BaseConfig.instanceChapterConfig
end


function BaseConfig.GetInstanceNode(nodeid, diff)
	if BaseConfig.instanceNodeConfig == nil then
		BaseConfig.instanceNodeConfig = {}
		BaseConfig.instanceNodeConfig = BaseConfig.readConfigData(CF.INSTANCE_NODE)
		-- for i, v in ipairs(raw_config) do
		-- 	BaseConfig.instanceNodeConfig[v.NodeID..","..v.Difficulty] = v
		-- end
	end
	CCLog("BaseConfig.GetInstanceNode:",nodeid, diff)
	local result = assert(BaseConfig.instanceNodeConfig[nodeid..","..diff], string.format("nodeid %d, diff %d", nodeid, diff))
	return result
end

function BaseConfig.GetNameAward()
	if BaseConfig.name_award == nil then
		BaseConfig.name_award = {}
		BaseConfig.name_award = BaseConfig.readConfigData(CF.NAME_AWARD)
	end

	return BaseConfig.name_award
end

function BaseConfig.GetHeroApartmentConfig(  )
	if BaseConfig.hero_apartment == nil then
		BaseConfig.hero_apartment = {}
		local raw_config = BaseConfig.readConfigData(CF.HERO_APARTMENT)
		for i, v in ipairs(raw_config) do
			BaseConfig.hero_apartment[v.ID] = v
		end
	end

	return BaseConfig.hero_apartment
end

function BaseConfig.GetHeroApartmentRuleConfig(  )
	if BaseConfig.hero_apartment_rule == nil then
		BaseConfig.hero_apartment_rule = {}
		BaseConfig.hero_apartment_rule = BaseConfig.readConfigData(CF.HERO_APARTMENT_RULE)
	end

	return BaseConfig.hero_apartment_rule[1]
end


-- 功能开放
function BaseConfig.GetSystemOpen( level )
	if BaseConfig.system_open == nil then
		BaseConfig.system_open = BaseConfig.readConfigData(CF.SYSTEM_OPEN)
	end
	
	return BaseConfig.system_open[level]
end


-- 物品购买价格（体力，耐力）
function BaseConfig.GetBuyPriceNode( count )
	if BaseConfig.buyPriceConfig == nil then
		BaseConfig.buyPriceConfig = BaseConfig.readConfigData(CF.BUY_PRICE)
	end

	local result = assert(BaseConfig.buyPriceConfig[count])
	return result
end

-- 摇钱树
function BaseConfig.GetCointreeNode( count )
	if BaseConfig.cointreeConfig == nil then
		BaseConfig.cointreeConfig = BaseConfig.readConfigData(CF.COINTREE)
	end

	local result = assert(BaseConfig.cointreeConfig[count])
	return result
end


-- 陷阱
function BaseConfig.GetTrap(trap_id)
	if BaseConfig.trapConfig == nil then
		BaseConfig.trapConfig = BaseConfig.readConfigData(CF.TRAP)
	end

	local result = assert(BaseConfig.trapConfig[trap_id])
	return result
end

-- 障碍
function BaseConfig.GetObstacle(obstacle_id)
	if BaseConfig.obstacleConfig == nil then
		BaseConfig.obstacleConfig = BaseConfig.readConfigData(CF.OBSTACLE)
	end

	local result = assert(BaseConfig.obstacleConfig[obstacle_id])
	return result
end

-- 炮台
function BaseConfig.GetTurret(turret_id)
	if BaseConfig.turretConfig == nil then
		BaseConfig.turretConfig = BaseConfig.readConfigData(CF.TURRET)
	end

	local result = assert(BaseConfig.turretConfig[turret_id])
	return result
end

-- 怪物
function BaseConfig.GetMonster(monster_id)
	BaseConfig.AllMonsterConfig()
	return BaseConfig.monsterConfig[monster_id]
end

-- buff
function BaseConfig.GetBuff(buff_id)
	if BaseConfig.buffConfig == nil then
		BaseConfig.buffConfig = BaseConfig.readConfigData(CF.BUFF)
	end
	local result = assert(BaseConfig.buffConfig[buff_id])
	return result
end

-- 战斗公式内容字符串
function BaseConfig.FormulaContent(formula_id)
	if BaseConfig.formulaConfig == nil then
		BaseConfig.formulaConfig = BaseConfig.readConfigData(CF.FORMULA)
	end

	local result = assert(BaseConfig.formulaConfig[formula_id])
	return result
end

-- 战斗公式函数
function BaseConfig.FormulaFunc(formula_id)
	if BaseConfig.formulaFunc == nil then
		BaseConfig.formulaFunc = {}
	end
	local func = BaseConfig.formulaFunc[formula_id]
	if func then
		return func
	else
		local formulaContent = BaseConfig.FormulaContent(formula_id)
		local funcDefine = string.format(BaseConfig.FORMULA_FORMAT_STR, formulaContent)
		local metaFunc = assert(loadstring(funcDefine), funcDefine)
		local func = assert(metaFunc())
		BaseConfig.formulaFunc[formula_id] = func
    	return func
	end
end

-- AI
function BaseConfig.GetAI(id)
	if BaseConfig.AIConfig == nil then
		BaseConfig.AIConfig = BaseConfig.readConfigData(CF.AI)
	end

	local result = assert(BaseConfig.AIConfig[id])
	return result
end

function BaseConfig.GetDialogue(id)
	if BaseConfig.dialogue == nil then
		BaseConfig.dialogue = BaseConfig.readConfigData(CF.DIALOGUE)
	end

	local result = assert(BaseConfig.dialogue[id])
	return result
end

function BaseConfig.GetRoleExp(level)
	if BaseConfig.roleExp == nil then
		BaseConfig.roleExp = BaseConfig.readConfigData(CF.ROLE_EXP)
	end

	local exp = assert(BaseConfig.roleExp[level])
	return exp
end

--CF.BATTLE_CONSUME
function BaseConfig.GetBattleConsume(System)
	if BaseConfig.battleConsume == nil then
		BaseConfig.battleConsume = BaseConfig.readConfigData(CF.BATTLE_CONSUME)
	end

	local consume = BaseConfig.battleConsume[System]
	return consume
end

function BaseConfig.getIntroduce(nodeSeqId)
	if BaseConfig.introduceConfig == nil then
		BaseConfig.introduceConfig = BaseConfig.readConfigData(CF.INTRODUCE)
	end

	local result = BaseConfig.introduceConfig[nodeSeqId]
	return result
end

function BaseConfig.randomName()
	if BaseConfig.firstName == nil then
		BaseConfig.firstName = BaseConfig.readConfigData(CF.FIRST_NAME)
	end

	if BaseConfig.lastName == nil then
		BaseConfig.lastName = BaseConfig.readConfigData(CF.LAST_NAME)
	end

    local firstName = BaseConfig.firstName[math.random(1, #BaseConfig.firstName)]
    local lastName = BaseConfig.lastName[math.random(1, #BaseConfig.lastName)]
    return firstName .. lastName
end

function BaseConfig.isIllegalWord(word)
	if BaseConfig.illegal_word == nil then
		BaseConfig.illegal_word = BaseConfig.readConfigData(CF.ILLEGAL_WORD)
	end

	return BaseConfig.illegal_word[word]
end

function BaseConfig.getFightingNPC(nodeID, diffLV)
	if BaseConfig.fighting_NPC == nil then
		BaseConfig.fighting_NPC = BaseConfig.readConfigData(CF.FIGHTING_NPC)
	end

	local stance2Slot = {
		[1] = {X = 3, Y = 1}, 
		[2] = {X = 3, Y = 2},
		[3] = {X = 3, Y = 3},
		[4] = {X = 2, Y = 1},
		[5] = {X = 2, Y = 2},
		[6] = {X = 2, Y = 3},
		[7] = {X = 1, Y = 1},
		[8] = {X = 1, Y = 2},
		[9] = {X = 1, Y = 3},
	}

	local result = {}

	local fighting_NPC = BaseConfig.fighting_NPC
	for _, node in ipairs(fighting_NPC) do
		if node.SeqList == nodeID and node.DiffLevel == diffLV then
			local slot = stance2Slot[node.Stance]
			table.insert(result, {NPC = node.MonID, X = slot.X, Y = slot.Y})
		end
	end
	
	if #result == 0 then
		return nil
	else
		return result
	end
end

function BaseConfig.GetDead(resID)
	if BaseConfig.deadConfig == nil then
		BaseConfig.deadConfig = BaseConfig.readConfigData(CF.DEAD)
	end

	local deadInfo = BaseConfig.deadConfig[resID]
	if deadInfo then
		return deadInfo.Dead
	else
		CCLog("Dead of Res", resID, "not found")
	end
	
	return 1
end

return BaseConfig