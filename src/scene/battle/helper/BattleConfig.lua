--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 14-9-29
-- Time: 上午11:04
-- To change this template use File | Settings | File Templates.
--

-- local HERO_ANI_DEF_SCALE = 0.75
-- local HERO_ANI_DEF_POS = cc.p(0, 0)
local HERO_BUFF_DEF_POS = cc.p(0, 0)
-- local __heroAniScaleMap = {
--     [1007] = 0.3, -- 蚩尤
--     [1016] = 0.60, -- 牛魔王
--     [1028] = 0.60, -- 沙悟净
--     [1037] = 0.55, -- 白象精
--     [1049] = 0.60, -- 巨灵神
--     [1052] = 0.60, -- 黑熊精

-- }

-- local __heroPosMap = {
--     [1018] = cc.p(0, 20), -- 孙悟空
--     [1047] = cc.p(0, 20), -- 彩衣
--     [1009] = cc.p(0, 20), -- 观音
--     [1030] = cc.p(0, 20), -- 王母
--     [1006] = cc.p(0, 20), -- 女娲
-- }

-- local __heroHPBarPosMap = {

-- }

local __heroBuffPos = {
    [9] = cc.p(0, 80),
    [35] = cc.p(0, 150),
    -- [1237] = cc.p(0, 80),
    -- [1252] = cc.p(0, 100),
    [1254] = cc.p(0, 160),
    [4003] = cc.p(0, 100),
    [1323] = cc.p(0, 80),
}

local AttributeMethods = {}
local BattleConfig = {}
setmetatable(BattleConfig, {__index = function(t, idx) 
        local attrMethod = AttributeMethods[idx]
        if attrMethod then
            return attrMethod()
        else
            return nil
        end
    end})

BattleConfig.attrs = AttributeMethods

-- function BattleConfig.getHeroAniScale(heroID)
--     return __heroAniScaleMap[heroID]  or HERO_ANI_DEF_SCALE
-- end

-- function BattleConfig.getHeroPos(heroID)
--     return __heroPosMap[heroID]  or HERO_ANI_DEF_POS
-- end

function BattleConfig.getHeroBuffPos(heroID, buffID)
    return __heroBuffPos[buffID]  or HERO_BUFF_DEF_POS
end

-- 英雄技能为子弹类型
local __bulletSkillList = {
    ["All"] = {[1002] = true, [1003] = true },
    [1010] = {[1210] = true, },
    [1034] = {[1244] = true, },
    [1040] = {[1259] = true, },
}

function BattleConfig.heroSkillIsBulletAttack(heroID, skillID)
    if __bulletSkillList["All"][skillID] then
        return true
    end

    local heroBullet = __bulletSkillList[heroID]
    if heroBullet then
        if heroBullet[skillID] then
            return true
        end
    end

    return false
end

function BattleConfig.getAttackImg(heroRes, skillID)
    -- 普攻
    if skillID == 1002 or skillID == 1003 then
        local path = string.format("image/spine/skill_effect/bullet/bullet_%s.png", heroRes)
        if cc.FileUtils:getInstance():isFileExist(path) then
            return path
        end
    else
        local path = string.format("image/spine/skill_effect/bullet/bullet_%s_%d.png", heroRes, skillID)
        if cc.FileUtils:getInstance():isFileExist(path) then
            return path
        end
    end

    return nil
end

function BattleConfig.getAttackImgName(heroRes, skillID)
    -- 普攻
    if skillID == 1002 or skillID == 1003 then
        local name = string.format("bullet_%s.png", heroRes)
        if cc.SpriteFrameCache:getInstance():getSpriteFrameByName(name) then
            return name
        end
    else
        local name = string.format("bullet_%s_%d.png", heroRes, skillID)
        if cc.SpriteFrameCache:getInstance():getSpriteFrameByName(name) then
            return name
        end
    end

    return nil
end

function BattleConfig.getAttackAniPath(heroRes, skillID)
    -- 普攻
    if skillID == 1002 or skillID == 1003 then
        local path = string.format("image/spine/skill_effect/bullet/%s/", heroRes)
        local fileUtils = cc.FileUtils:getInstance()
        if fileUtils:isFileExist(path .. "skeleton.skel") or fileUtils:isFileExist(path .. "skeleton.atlas") then
            return path
        end
    else
        local path = string.format("image/spine/skill_effect/bullet/%s_%d/", heroRes, skillID)
        local fileUtils = cc.FileUtils:getInstance()
        if fileUtils:isFileExist(path .. "skeleton.skel") or fileUtils:isFileExist(path .. "skeleton.atlas") then
            return path
        end
    end

    return "image/spine/skill_effect/bullet/xj_1000/"
end

-- 英雄怒气特效配置
local __heroRageEffectConfig = {
    -- 移动到目标位置，结束后返回
    HeroMove = {
        
        [1027] = { delay = 0.5, offset = cc.p(0, 0), moveTime = 0, shake = false, },-- 猪八戒
        --[1029] = { delay = 0.5, offset = cc.p(0, 0), moveTime = 0, shake = false, },-- 龟丞相
        [1037] = { delay = 0.3, offset = cc.p(0, 0), moveTime = 0, shake = false, },-- 白象精
    },

    -- 在英雄上直接播放特效
    HeroEffect = {
        [1044] = { delay = 1.0, offset = cc.p(30, 90), moveTime = 0, shake = false, },-- 小青
        [1046] = { delay = 0.2, offset = cc.p(30, 90), moveTime = 0, shake = false, },-- 红孩儿
        [1033] = { delay = 0.4, offset = cc.p(30, 90), moveTime = 0, shake = false, },-- 紫霞仙子
        [1049] = { delay = 0.4, offset = cc.p(0, 0), moveTime = 0, shake = true, shake_time = 0.1, shake_strength = 40, },-- 巨灵神
        
        [1029] = { delay = 0.5, offset = cc.p(0, 0), moveTime = 0, shake = false, },
    },

    -- 在英雄上播放特效，并向远方移动
    HeroEffectMove = {

    },

    -- 直接在目标位置播放特效
    TargetEffect = {
        [1006] = { delay = 0.5, offset = cc.p(0, 0), moveTime = 0, shake = true, },-- 女娲
        [1010] = { delay = 0.3, offset = cc.p(0, 0), moveTime = 0, shake = true, },-- 菩提
        [1016] = { delay = 0.8, offset = cc.p(0, 0), moveTime = 0, shake = true , shake_time = 0.1, shake_strength = 40, },-- 牛魔王
        [1047] = { delay = 0.8, offset = cc.p(0, 0), moveTime = 0, shake = false, }, -- 彩衣
        [1014] = { delay = 0.3, offset = cc.p(0, 0), moveTime = 0, shake = false, },-- 大鹏
        [1051] = { delay = 0.3, offset = cc.p(0, 0), moveTime = 0, shake = true, },-- 地涌夫人
        [1013] = { delay = 0.3, offset = cc.p(0, 0), moveTime = 0, shake = true, },-- 孔雀大明王
        [1035] = { delay = 0.5, offset = cc.p(0, 0), moveTime = 0, shake = false, },-- 白骨精
        [1036] = { delay = 0.5, offset = cc.p(0, 0), moveTime = 0, shake = false, },-- 苏妲己
        [1050] = { delay = 0.5, offset = cc.p(0, 0), moveTime = 0, shake = true, },-- 蝎子精
        [1023] = { delay = 0.5, offset = cc.p(0, 0), moveTime = 0, shake = false, },-- 黄眉妖王
        [1007] = { delay = 0.5, offset = cc.p(0, 0), moveTime = 0, shake = true, },-- 蚩尤
        [1040] = { delay = 0.5, offset = cc.p(0, 0), moveTime = 0, shake = true, },-- 龙女
        -- [1037] = { delay = 0.8, offset = cc.p(0, 0), moveTime = 0, shake = true , shake_time = 0.1, shake_strength = 40, },-- 白象精
        [1038] = { delay = 0.8, offset = cc.p(0, 0), moveTime = 0, shake = true, },-- 青狮怪
        [1032] = { delay = 1.0, offset = cc.p(0, 0), moveTime = 0, shake = true, },-- 东海龙王


        -- 怪物
        [10603103] = { delay = 0.5, offset = cc.p(0, 90), moveTime = 0, shake = false, },-- 狙击手
        [10000011] = { delay = 0.5, offset = cc.p(0, 0), moveTime = 0, shake = false, },-- 蜘蛛精
        [10108104]= { delay = 0.5, offset = cc.p(0, 0), moveTime = 0, shake = false, },-- 太丙真人
    },

    -- 在目标位置播放特效并向远方移动
    TargetEffectMove = {
        [1042] = { delay = 1.6, offset = cc.p(30, 90), moveTime = 0.5, shake = false, }, -- 铁扇公主
        [1039] = { delay = 0.9, offset = cc.p(30, 90), moveTime = 0.6, shake = false, }, -- 哪吒
    },

    -- 在屏幕中心播放特效
    Center = {
        [1020] = { delay = 0.5, offset = cc.p(0, 0), moveTime = 0, shake = false, },-- 白蛇
        
    },
}

local __heroRageEffectDefConfigType = "TargetEffect"
local __heroRageEffectDefConfig =  { delay = 0.5, offset = cc.p(0, 0), moveTime = 0, shake = true, }

local __ContinuousSkillConfig = {
    [1031] = {
        [1331] = {

        }
    }
}

function BattleConfig.getRageAniType(heroID)
    for k, v in pairs(__heroRageEffectConfig) do
        local config = v[heroID]
        if config then
            return k
        end
    end
    return __heroRageEffectDefConfigType
end

function BattleConfig.getRageAniConfig(heroID)
    for k, v in pairs(__heroRageEffectConfig) do
        local config = v[heroID]
        if config then
            return config
        end
    end
    return __heroRageEffectDefConfig
end

-- 分身的存在时间
BattleConfig.REPLICATION_MODEL_TIME = 6
BattleConfig.COPY_MODEL_TIME = 10  -- 复制人存在 时间
BattleConfig.EGG_MODEL_TIME = 6    -- 不死鸟 蛋复活时间
BattleConfig.FAIRY_COOL_TIME = 15  -- 仙女技能冷却时间
BattleConfig.FRIEND_GUARD_TIME = 10 -- 仙友护守时间
BattleConfig.RAGE_INC_INTERVAL = 1.0 / 3 -- 怒气增长时间间隔(秒)

-- 加速倍速
BattleConfig.SPEED_RATIO = 1

BattleConfig.TIME_UNIT = (1.0 / 20)
BattleConfig.ROUND_TIME = 90 / BattleConfig.TIME_UNIT  -- 一回合的时间(tick)

BattleConfig.BATTLE_WIDTH  = 900  --BattleConfig.CELL_WIDTH * BattleConfig.X_CELL_COUNT
BattleConfig.BATTLE_HEIGHT = 250 -- BattleConfig.CELL_HEIGHT * BattleConfig.Y_CELL_COUNT

BattleConfig.DESGIN_X_CELL_COUNT = 18
BattleConfig.DESGIN_Y_CELL_COUNT = 5

BattleConfig.DESIGN_RATIO = 1
BattleConfig.BEVEL_ANGLE = 15    -- 战斗格子斜度
BattleConfig.X_CELL_COUNT = BattleConfig.DESGIN_X_CELL_COUNT * BattleConfig.DESIGN_RATIO
BattleConfig.Y_CELL_COUNT = BattleConfig.DESGIN_Y_CELL_COUNT * BattleConfig.DESIGN_RATIO

BattleConfig.CELL_WIDTH = BattleConfig.BATTLE_WIDTH / BattleConfig.X_CELL_COUNT   -- 45
BattleConfig.CELL_HEIGHT = BattleConfig.BATTLE_HEIGHT / BattleConfig.Y_CELL_COUNT -- 45

--BattleConfig.BATTLE_WIDTH = BattleConfig.CELL_WIDTH * BattleConfig.X_CELL_COUNT
--BattleConfig.BATTLE_HEIGHT = BattleConfig.CELL_HEIGHT * BattleConfig.Y_CELL_COUNT

BattleConfig.BATTLE_SIZE = cc.size(BattleConfig.BATTLE_WIDTH, BattleConfig.BATTLE_HEIGHT)

-- 单元格之间的距离
function BattleConfig.cellDistance(cellA, cellB)
    return math.abs(cellB.x - cellA.x) + math.abs(cellB.y - cellA.y)
end

-- 范围到一个单元格的最小距离
function BattleConfig.scopeCellDistance(scope, cell)
    local nearest = nil
    for _, scopeCell in ipairs(scope) do
        local distance = BattleConfig.cellDistance(scopeCell, cell)
        if nearest == nil or distance < nearest then
            nearest = distance
        end
    end
    return nearest
end

--local function searchSection(low, high, size, pos)
--    while (low <= high) do
--        local mid = math.floor((low + high) / 2)
--        local left = (mid - 1) * size
--        local right = mid * size
--        if pos >= left and pos <= right then
--            return mid
--        elseif pos > right then
--            low = mid + 1
--        elseif pos < left then
--            high = mid - 1
--        end
--    end
--    return nil
--end

local function isOddNum(num)
    return math.floor(num) % 2 == 1
end

-- 指定位置的Cell
function BattleConfig.getCellOfPos(pointX, pointY)
    local y = math.floor(pointY / BattleConfig.CELL_HEIGHT)
        
    if isOddNum(y) then
        pointX = pointX - BattleConfig.CELL_WIDTH / 2
    end
    local x = math.floor(pointX / BattleConfig.CELL_WIDTH)

    return {x = x, y = y}
end

function BattleConfig.cellOfPos(pointX, pointY)
    local y = math.floor(pointY / BattleConfig.CELL_HEIGHT)

    if isOddNum(y) then
        pointX = pointX - BattleConfig.CELL_WIDTH / 2
    end

    local x = math.floor(pointX / BattleConfig.CELL_WIDTH)
   
    return x, y
end

function BattleConfig.cellsToRanges(cells)
    local ranges = {}
    for idx, cell in ipairs(cells) do
        local x = cell[1]
        local y = cell[2]

        local range = ranges[y]
        if range == nil then
            range = {min = nil, max = nil}
            ranges[y] = range
        end

        if range.min == nil or x < range.min then
            range.min = x
        end
        if range.max == nil or x > range.max then
            range.max = x
        end
    end
    for y, range in pairs(ranges) do
        range.len = range.max - range.min + 1
        range.start = range.min

        range.min = nil
        range.max = nil
    end
    return ranges
end

-- 指定位置最近的Cell
function BattleConfig.nearestCellOfPos(point)
    local cell = BattleConfig.getCellOfPos(point.x, point.y)
    if cell.x < 0 then
        cell.x = 0
    elseif cell.x >= BattleConfig.X_CELL_COUNT then
        cell.x = BattleConfig.X_CELL_COUNT - 1
    end

    if cell.y < 0 then
        cell.y = 0
    elseif cell.y >= BattleConfig.Y_CELL_COUNZT then
        cell.y = BattleConfig.Y_CELL_COUNT - 1
    end

    return cell
end

-- 获取一个单元格的位置
function BattleConfig.getCellPos(x, y)
    local CELL_WIDTH = BattleConfig.CELL_WIDTH
    local CELL_HEIGHT = BattleConfig.CELL_HEIGHT

    local left = x * CELL_WIDTH
    local bottom = y * CELL_HEIGHT

    if isOddNum(y) then
        left = left + BattleConfig.CELL_WIDTH / 2
    end

    local center = cc.p(left + CELL_WIDTH / 2, bottom + CELL_HEIGHT / 2)

    return center
end

function BattleConfig.getHeroCellPos(x, y)
    local pos = BattleConfig.getCellPos(x, y)
    return pos
end

-- 获取一个单元格的矩形区域
function BattleConfig.getCellRect(x, y)
    local CELL_WIDTH = BattleConfig.CELL_WIDTH
    local CELL_HEIGHT = BattleConfig.CELL_HEIGHT

    local left = x * CELL_WIDTH
    local bottom = y * CELL_HEIGHT

    if isOddNum(y) then
        left = left + BattleConfig.CELL_WIDTH / 2
    end

    return cc.rect(left, bottom, CELL_WIDTH, CELL_HEIGHT)
end

function BattleConfig.getCellLeft(x, y)
    local CELL_WIDTH = BattleConfig.CELL_WIDTH

    local left = x * CELL_WIDTH

    if isOddNum(y) then
        left = left + BattleConfig.CELL_WIDTH / 2
    end

    return left
end

function BattleConfig.getCellBottom(x, y)
    local CELL_HEIGHT = BattleConfig.CELL_HEIGHT

    local bottom = y * CELL_HEIGHT
    return bottom
end

function BattleConfig.getCellTop(x, y)
    return BattleConfig.getCellBottom(x, y) + BattleConfig.CELL_HEIGHT
end

function BattleConfig.getCellRight(x, y)
    return BattleConfig.getCellLeft(x, y) + BattleConfig.CELL_WIDTH
end

-- 获取一个英雄插座的单元格位置
function BattleConfig.getSlotCell(slotX, slotY)
    local width = math.floor(BattleConfig.X_CELL_COUNT / 3)
    local height = BattleConfig.Y_CELL_COUNT

    local x = math.floor(width  * slotX / 3 - 1)
    local y = math.floor(height * slotY / 3 - 1)

    -- local x = math.floor((width / 9.0) * (slotX * 3 - 1.5))
    -- local y
    -- if slotY == 1 then
    --     y = math.floor((height / 9.0) * (slotY * 3 - 1.5))
    -- elseif slotY == 2 then
    --     y = math.floor((height / 9.0) * (slotY * 3 - 1.5))
    -- elseif slotY == 3 then
    --     y = math.floor((height / 9.0) * (slotY * 3 - 1.5))
    -- end
    return {x = x, y = y}
end

-- 把以1为起始的位置改为0为起始的
function BattleConfig.configPosToCell(pos)
    local xratio = BattleConfig.X_CELL_COUNT / BattleConfig.X_CELL_COUNT
    local yratio = BattleConfig.Y_CELL_COUNT / BattleConfig.Y_CELL_COUNT

    local x = math.floor((pos.x - 1) * xratio)
    local y = math.floor((pos.y - 1) * yratio)
    return {x = math.min(math.max(x, 0), BattleConfig.X_CELL_COUNT - 1), y = math.min(math.max(y, 0), BattleConfig.Y_CELL_COUNT - 1)}
end

-- 反转一个单元格
function BattleConfig.getFlipCell(cell)
    return {x = BattleConfig.X_CELL_COUNT - cell.x - 1, y = cell.y}
end

--BattleConfig.ENTRANCE_TIME = 1.8 / BattleConfig.SPEED_RATIO -- 战斗过场时间
BattleConfig.attrs.ENTRANCE_TIME = function() return 1.8 / BattleConfig.SPEED_RATIO end
BattleConfig.HERO_MOVE_TIME = 0.36 / BattleConfig.DESIGN_RATIO -- 英雄走一格需要的时间
BattleConfig.HERO_X_SPEED = BattleConfig.CELL_WIDTH / BattleConfig.HERO_MOVE_TIME
BattleConfig.HERO_Y_SPEED = BattleConfig.CELL_HEIGHT / BattleConfig.HERO_MOVE_TIME
--BattleConfig.FIREBALL_SPEED = 30 * BattleConfig.DESIGN_RATIO * BattleConfig.SPEED_RATIO
BattleConfig.attrs.FIREBALL_SPEED = function() return 30 * BattleConfig.DESIGN_RATIO * BattleConfig.SPEED_RATIO end

BattleConfig.REGION_RAGE_PAUSE = true
BattleConfig.RAGE_SKILL_PAUSE = true

local POS_RATIO_X = display.width / 960
local POS_RATIO_Y = 1

BattleConfig.POS_RATIO_X = POS_RATIO_X
BattleConfig.POS_RATIO_Y = POS_RATIO_Y

function BattleConfig.PPOS(x, y)
    if y == nil then
        local _pos = x
        x, y = _pos.x, _pos.y
    end

    return {x = x * POS_RATIO_X, y = y * POS_RATIO_Y}
end

function BattleConfig.BPOS(x, y)
    if y == nil then
        local _pos = x
        x, y = _pos.x, _pos.y
    end

    return {x = x / POS_RATIO_X, y = y / POS_RATIO_Y}
end

BattleConfig.BATTLE_POS = cc.p((display.width - BattleConfig.BATTLE_WIDTH * POS_RATIO_X) / 2 - math.sin(math.rad(BattleConfig.BEVEL_ANGLE)) * BattleConfig.BATTLE_HEIGHT / 2, 120)

CCLog(vardump(BattleConfig, "BattleConfig"))

return BattleConfig