--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 14-11-25
-- Time: 下午3:47
-- To change this template use File | Settings | File Templates.
--
local ElemType = require("config.ElemType")
-------------------------------------------------------------------------------
local BattleFormData = class("BattleFormData")

local function SNAME(x, y)
    return string.format("%d:%d", x, y)
end

function BattleFormData:ctor()
    self.slots = {
        [SNAME(1, 1)] = {heroData = nil, used = true  },
        [SNAME(1, 2)] = {heroData = nil, used = false },
        [SNAME(1, 3)] = {heroData = nil, used = true  },
        [SNAME(2, 1)] = {heroData = nil, used = true  },
        [SNAME(2, 2)] = {heroData = nil, used = false },
        [SNAME(2, 3)] = {heroData = nil, used = true  },
        [SNAME(3, 1)] = {heroData = nil, used = false },
        [SNAME(3, 2)] = {heroData = nil, used = true  },
        [SNAME(3, 3)] = {heroData = nil, used = false },
    }

    self.fairyList = {}
    self.playFairyID = nil
end

function BattleFormData:setFairyList(faiyList)
    self.fairyList = faiyList
end

function BattleFormData:setPlayFairyID(fairyID)
    self.playFairyID = fairyID
end

function BattleFormData:getPlayFairyID()
    local fairyID = self.playFairyID
    if fairyID == 0 then
        fairyID = nil
    end
    return fairyID
end

function BattleFormData:getFairyData(fairyID)
    local fairyList = self.fairyList or {}
    for _, fairy in ipairs(fairyList) do
       if fairy.ID == fairyID then
           return fairy
       end
    end
end

function BattleFormData:getPlayFairyData()
    if self.playFairyID ~= nil and self.playFairyID > 0 then
        local fairyData = assert(self:getFairyData(self.playFairyID), "invalid fairy: " .. self.playFairyID)
        return fairyData
    end
    return nil
end

function BattleFormData:clear()
    for x = 1, 3 do
        for y = 1, 3 do
            local slot = self.slots[SNAME(x, y)]
            slot.used = false
            slot.heroData = nil
        end
    end
end

function BattleFormData:setForm(form)
    CCLog(vardump(form, "Form"))

    self:clear()

    if form and form.Hero then
        for _, unit in ipairs(form.Hero) do
            local heroID = unit.ID
            local npcID = unit.NPC
            local x = unit.X
            local y = unit.Y

            if heroID then
                self:setHeroID(x, y, heroID)
            elseif npcID then
                self:setNpcID(x, y, npcID)
            end
        end
    end

    CCLog(vardump(self.slots, "Before Adjust"))
    self:adjustHeroSlots()
    CCLog(vardump(self.slots, "After Adjust"))
end

function BattleFormData:getForm()
    local form = {}
    for x = 1, 3 do
        for y = 1, 3 do
            local slot = self.slots[SNAME(x, y)]
            if slot.heroData ~= nil then
                if slot.heroData.heroID then
                    table.insert(form, {ID = slot.heroData.heroID, X = x, Y = y})
                elseif slot.heroData.npcID then
                    table.insert(form, {NPC = slot.heroData.npcID, X = x, Y = y})
                end
            end
        end
    end

    return form
end

function BattleFormData:getHeroID(x, y)
    local slot = self.slots[SNAME(x, y)]
    if slot.heroData then
        return slot.heroData.heroID
    else
        return nil
    end
end

function BattleFormData:getNpcID(x, y)
    local slot = self.slots[SNAME(x, y)]
    if slot.heroData then
        return slot.heroData.npcID
    else
        return nil
    end
end

function BattleFormData:setHeroID(x, y, heroID)
    if type(heroID) ~= "number" then
        heroID = 0
    end

    local slot = self.slots[SNAME(x, y)]
    if heroID ~= 0 then
        slot.heroData = {heroID = heroID}
        slot.used = true
    else
        slot.heroData = nil     
    end
end

function BattleFormData:setNpcID(x, y, npcID)
    if type(npcID) ~= "number" then
        npcID = 0
    end

    local slot = self.slots[SNAME(x, y)]
    if npcID ~= 0 then
        slot.heroData = {npcID = npcID}
        slot.used = true
    else
        slot.heroData = nil     
    end
end

function BattleFormData:findByHeroID(heroID)
    for x = 1, 3 do
        for y = 1, 3 do
            local slot = self.slots[SNAME(x, y)]
            if slot.heroData and slot.heroData.heroID == heroID then
                return {x = x, y = y }
            end
        end
    end
    return nil
end

function BattleFormData:findFreeSlot(heroType)
    if heroType == "near" then
        for _, x in ipairs({3, 2, 1}) do
            for y = 1, 3 do
                local slot = self.slots[SNAME(x, y)]
                if slot.used and slot.heroData == nil then
                    return {x = x, y = y }
                end
            end
        end
    elseif heroType == "far" then
        for _, x in ipairs({2, 1, 3}) do
            for y = 1, 3 do
                local slot = self.slots[SNAME(x, y)]
                if slot.used and slot.heroData == nil then
                    return {x = x, y = y }
                end
            end
        end
    elseif heroType == "veryFar" then
        for _, x in ipairs({1, 2, 3}) do
            for y = 1, 3 do
                local slot = self.slots[SNAME(x, y)]
                if slot.used and slot.heroData == nil then
                    return {x = x, y = y }
                end
            end
        end
    else
        CCLog("error: unkown heroType", heroType)
    end
    return nil
end

function BattleFormData:isHero(x, y)
    local slot = self.slots[SNAME(x, y)]
    return slot.heroData ~= nil
end

function BattleFormData:isUsed(x, y)
    local slot = self.slots[SNAME(x, y)]
    return slot.used or slot.heroData ~= nil
end

function BattleFormData:move(from, to)
    local fromSlot = self.slots[SNAME(from.x, from.y)]
    local heroData = fromSlot.heroData
    local used = fromSlot.used

    local toSlot = self.slots[SNAME(to.x, to.y)]

    toSlot.heroData = heroData
    toSlot.used = used

    fromSlot.heroData = nil
    fromSlot.used = false
end

function BattleFormData:use(x, y)
    self.slots[SNAME(x, y)].used = true
end

function BattleFormData:unset(x, y)
    local slot = self.slots[SNAME(x, y)]
    slot.used = false
    slot.heroData = nil
end

function BattleFormData:count()
    local count = 0
    for x = 1, 3 do
        for y = 1, 3 do
            if self:isUsed(x, y) then
                count = count + 1
            end
        end
    end
    return count
end

function BattleFormData:add(movable)
    movable = movable or false
    for x = 1, 3 do
        if self:colCount(x) == 0 then
            self:use(x, 2)
            return true
        elseif self:colCount(x) == 1 then
            if self:isUsed(x, 1) then
                self:use(x, 3)
                return true
            elseif self:isUsed(x, 2) then
                if self:isHero(x, 2) then
                    if movable then
                        self:move({x = x, y = 2}, {x = x, y = 1})
                        self:use(x, 3)
                        return true
                    end
                else
                    self:move({x = x, y = 2}, {x = x, y = 1})
                    self:use(x, 3)
                    return true
                end
            elseif self:isUsed(x, 3) then
                self:use(x, 1)
                return true
            end
        end
    end
    return false
end

function BattleFormData:swap(from, to)
    local fromSlot = self.slots[SNAME(from.x, from.y)]
    local fromHeroData = fromSlot.heroData
    local fromUsed = fromSlot.used

    local toSlot = self.slots[SNAME(to.x, to.y)]
    local toHeroData = toSlot.heroData
    local toUsed = toSlot.used

    toSlot.heroData = fromHeroData
    toSlot.used = fromUsed

    fromSlot.heroData = toHeroData
    fromSlot.used = toUsed
end

function BattleFormData:colCount(x)
    local count = 0
    for y = 1, 3 do
        if self:isUsed(x, y) then
            count = count + 1
        end
    end

    return count
end

function BattleFormData:colHeroCount(x)
    local count = 0
    for y = 1, 3 do
        if self:isUsed(x, y) and self:isHero(x, y) then
            count = count + 1
        end
    end

    return count
end

function BattleFormData:adjustHeroSlots()
    local TOTAL_SLOT = 5

    local time = 0
    while self:count() < TOTAL_SLOT do
        self:add(false)

        --CCLog(vardump({time = time, slots = self.slots, count = self:count()}, "adjustSlots"))

        time = time + 1
        if time > TOTAL_SLOT then
            CCLog("adjust too many times", time)
            break
        end
    end

    time = 0
    while self:count() < TOTAL_SLOT do
        self:add(true)

        --CCLog(vardump({time = time, slots = self.slots, count = self:count()}, "adjustSlots"))

        time = time + 1
        if time > TOTAL_SLOT then
            CCLog("adjust too many times", time)
            break
        end
    end

    time = 0
    while self:count() > TOTAL_SLOT do
        time = time + 1
        if time > 20 then
            CCLog("adjust too many times", time)
            break
        end

        for x = 1, 3 do
            for y = 1, 3 do
                if self:isUsed(x, y) and not self:isHero(x, y)  then
                    self:unset(x, y)
                end
            end
        end
    end

    -- 单列未在中间的，把两边调到两边
    time = 0
    for x = 1, 3 do
        time = time + 1
        if time > 20 then
            CCLog("adjust too many times", time)
            break
        end

        if self:colCount(x) == 1 then
            if not self:isUsed(x, 2) then
                if self:isUsed(x, 1) then
                    self:move({x = x, y = 1}, {x = x, y = 2})
                else
                    self:move({x = x, y = 3}, {x = x, y = 2})
                end
            end
        end

        if self:colCount(x) == 2 then
            if self:isUsed(x, 2) then
                if not self:isUsed(x, 3) then
                    self:move({x = x, y = 2}, {x = x, y = 3})
                elseif not self:isUsed(x, 1) then
                    self:move({x = x, y = 2}, {x = x, y = 1})
                end
            end
        end
    end
end

function BattleFormData:getHeroElemType(x, y)
    local heroID = self:getHeroID(x, y)
    if heroID and heroID ~= 0 then
        --CCLog("heroID:", heroID)
        local heroData = BaseConfig.GetHero(heroID, 1)
        return heroData and heroData.wx or nil
    else
        return nil
    end
end

function BattleFormData:getAllNames()
    return {
        "锐金阵",
        "次金阵",
        "青木阵",
        "次木阵",
        "癸水阵",
        "次水阵",
        "烈火阵",
        "次火阵",
        "厚土阵",
        "次土阵",
        "金水阵",
        "水木阵",
        "木火阵",
        "火土阵",
        "土金阵",
        "五行阵",
    }
end

function BattleFormData:getName()
    return BattleFormData.getFormName(self:getForm())
end

function BattleFormData:getIcon(name)
    if name == nil then
        name = self:getName()
    end

    local name_index_map = {
        ["锐金阵"] = 1,
        ["次金阵"] = 2,
        ["青木阵"] = 3,
        ["次木阵"] = 4,
        ["癸水阵"] = 5,
        ["次水阵"] = 6,
        ["烈火阵"] = 7,
        ["次火阵"] = 8,
        ["厚土阵"] = 9,
        ["次土阵"] = 10,
        ["金水阵"] = 11,
        ["水木阵"] = 12,
        ["木火阵"] = 13,
        ["火土阵"] = 14,
        ["土金阵"] = 15,
        ["五行阵"] = 16,
    }

    local index = name_index_map[name]
    if index then
        return string.format("image/icon/form/zf_%0d.png", index)
    end
    return nil
end

function BattleFormData.getFormName(form)
   local Metal = 1
   local Wood  = 2
   local Water = 3
   local Fire  = 4
   local Earth = 5

    local name = "无阵型"

    local elemTypeList = {}
    local elemTypeCountMap = {}

   local formSlotMap = {}
   for _, unit in ipairs(form) do
       local heroID = unit.ID

       if heroID and heroID ~= 0 then
           local x = unit.X
           local y = unit.Y

           local heroData = BaseConfig.GetHero(heroID, 1)
           formSlotMap[x .. ":" .. y] = {heroID = unit.ID, Wx = heroData.wx }
       end
   end

    for x = 1, 3 do
        for y = 1, 3 do
            local slotInfo = formSlotMap[x .. ":" .. y]
            local elemType = slotInfo and slotInfo.Wx or nil
            if elemType then
                table.insert(elemTypeList, elemType)
                if elemTypeCountMap[elemType] then
                    elemTypeCountMap[elemType] = elemTypeCountMap[elemType] + 1
                else
                    elemTypeCountMap[elemType] = 1
                end
            end
        end
    end

    local elemTypes = table.keys(elemTypeCountMap)
    if #elemTypes == 5 then
        return "五行阵"
    end

    if #elemTypes == 1 and #elemTypeList == 5 then
        local names = {[1] = "锐金阵", [2] = "青木阵", [3] = "癸水阵", [4] = "烈火阵", [5] = "厚土阵" }
        return names[elemTypes[1]]
    end

    local function genFormName(elemType1, elemType2)
        local count1 = elemTypeCountMap[elemType1]
        local count2 = elemTypeCountMap[elemType2]
        if count1 and count2 and count1 >= 2 and count2 >= 2 and ElemType.generate(elemType1, elemType2) then
            return ElemType.typeName(elemType1) .. ElemType.typeName(elemType2) .. "阵"
        else
            return nil
        end
    end

    for _, elems in ipairs({{Metal, Water}, {Water, Wood}, {Wood, Fire}, {Fire, Earth}, {Earth, Metal}}) do
        local name = genFormName(elems[1], elems[2])
        if name then
            return name
        end
    end

    for elemType, count in pairs(elemTypeCountMap) do
        if count >= 3 then
            local names = {[1] = "次金阵", [2] = "次木阵", [3] = "次水阵", [4] = "次火阵", [5] = "次土阵" }
            return names[elemType]
        end
    end

    return name
end

function BattleFormData.getFormAdditionByName(name)
    local All   = 0
    local Metal = 1
    local Wood  = 2
    local Water = 3
    local Fire  = 4
    local Earth = 5

    local additionMap = {
        ["锐金阵"] = {Wx = All  , Atk = 0.05 , Def = 0    , Hit = 0.05 , Miss = 0   , Crit = 0   , Ten = 0   , HP = 0    },
        ["次金阵"] = {Wx = Metal, Atk = 0    , Def = 0    , Hit = 0.05 , Miss = 0   , Crit = 0   , Ten = 0   , HP = 0    },
        ["青木阵"] = {Wx = All  , Atk = 0.05 , Def = 0.1  , Hit = 0    , Miss = 0   , Crit = 0   , Ten = 0   , HP = 0    },
        ["次木阵"] = {Wx = Wood , Atk = 0    , Def = 0.1  , Hit = 0    , Miss = 0   , Crit = 0   , Ten = 0   , HP = 0    },
        ["癸水阵"] = {Wx = All  , Atk = 0    , Def = 0    , Hit = 0    , Miss = 0.05, Crit = 0   , Ten = 0   , HP = 0.1  },
        ["次水阵"] = {Wx = Water, Atk = 0    , Def = 0    , Hit = 0    , Miss = 0.05, Crit = 0   , Ten = 0   , HP = 0    },
        ["烈火阵"] = {Wx = All  , Atk = 0.05 , Def = 0    , Hit = 0    , Miss = 0   , Crit = 0.05, Ten = 0   , HP = 0    },
        ["次火阵"] = {Wx = Fire , Atk = 0    , Def = 0    , Hit = 0    , Miss = 0   , Crit = 0.05, Ten = 0   , HP = 0    },
        ["厚土阵"] = {Wx = All  , Atk = 0    , Def = 0    , Hit = 0    , Miss = 0   , Crit = 0   , Ten = 0.05, HP = 0.1  },
        ["次土阵"] = {Wx = Earth, Atk = 0    , Def = 0    , Hit = 0    , Miss = 0   , Crit = 0   , Ten = 0.05, HP = 0    },
        ["金水阵"] = {Wx = All  , Atk = 0    , Def = 0    , Hit = 0.03 , Miss = 0.03, Crit = 0   , Ten = 0   , HP = 0    },
        ["水木阵"] = {Wx = All  , Atk = 0    , Def = 0.05 , Hit = 0    , Miss = 0.03, Crit = 0   , Ten = 0   , HP = 0    },
        ["木火阵"] = {Wx = All  , Atk = 0    , Def = 0.05 , Hit = 0    , Miss = 0   , Crit = 0.03, Ten = 0   , HP = 0    },
        ["火土阵"] = {Wx = All  , Atk = 0    , Def = 0    , Hit = 0    , Miss = 0   , Crit = 0.03, Ten = 0.03, HP = 0    },
        ["土金阵"] = {Wx = All  , Atk = 0    , Def = 0    , Hit = 0.03 , Miss = 0   , Crit = 0.03, Ten = 0   , HP = 0    },
        ["五行阵"] = {Wx = All  , Atk = 0.05 , Def = 0    , Hit = 0.05 , Miss = 0   , Crit = 0.03, Ten = 0   , HP = 0.08 },
    }

    local addition = additionMap[name]
    return addition or {}
end

local __form_colors = {
    metal = {255, 228, 0},
    wood = {0, 255, 65},
    water = {53, 177, 255},
    fire = {255, 0, 0},
    earth = {157, 157, 109},
}

local __form_desc_map = {
    --    （1）锐金阵
    --    激活条件：有5名金属性的星将同时上阵
    --    加成效果：上阵所有星将攻击+5%，命中+5%
    --
    --    （2）次金阵
    --    激活条件：有3-4名金属性的星将同时上阵
    --    加成效果：所有金属性星将命中+5%
    --
    --    （3）青木阵
    --    激活条件：有5名木属性的星将同时上阵
    --    加成效果：上阵所有星将攻击+5%，防御+10%
    --
    --    （4）次木阵
    --    激活条件：有3-4名木属性的星将同时上阵
    --    加成效果：所有木属性星将防御+10%
    --
    --    （5）癸水阵
    --    激活条件：有5名水属性的星将同时上阵
    --    加成效果：上阵所有星将生命+10%，闪避+5%
    --
    --    （6）次水阵
    --    激活条件：有3-4名水属性的星将同时上阵
    --    加成效果：所有水属性星将闪避+5%
    --
    --    （7）烈火阵
    --    激活条件：有5名火属性的星将同时上阵
    --    加成效果：上阵的所有火属性星将攻击+5%，暴击+5%
    --
    --    （8）次火阵
    --    激活条件：有3-4名火属性的星将同时上阵
    --    加成效果：所有火属性星将暴击+5%
    --
    --    （9）厚土阵
    --    激活条件：有5名土属性的星将同时上阵
    --    加成效果：上阵的所有火属性星将生命+10%，韧性+5%
    --
    --    （10）次土阵
    --    激活条件：有3-4名土属性的星将同时上阵
    --    加成效果：所有土属性星将韧性+5%
    --
    --    （11）金水阵
    --    激活条件：有2名金属性和2名水属性的星将同时上阵
    --    加成效果：所有上阵星将命中+3%，3%闪避
    --
    --    （12）水木阵
    --    激活条件：有2名水属性和2名木属性的星将同时上阵
    --    加成效果：所有上阵星将3%闪避，5%防御
    --
    --    （13）木火阵
    --    激活条件：有2名木属性和2名火属性的星将同时上阵
    --    加成效果：所有上阵星将5%防御，3%暴击
    --
    --    （14）火土阵
    --    激活条件：有2名火属性和2名土属性的星将同时上阵
    --    加成效果：所有上阵星将3%暴击，3%韧性
    --
    --    （15）土金阵
    --    激活条件：有2名土属性和2名金属性的星将同时上阵
    --    加成效果：所有上阵星将3%韧性，3%命中
    --
    --
    --    （16）五行阵
    --    激活条件：有金木水火土五种属性的星将同时上阵
    --    加成效果：上阵的所有星将攻击+5%，8%的血量，命中+5%，暴击+5%。


    ["锐金阵"] = {
        condition = {"5名金属性", "的星将同时上阵"},
        effect = {"上阵的所有星将", "攻击+5% 命中+5%"},
        color = __form_colors.metal,
    },

    ["次金阵"] = {
        condition = {"3至4名金属性", "的星将同时上阵"},
        effect = {"上阵的所有金属性星将", "命中+5%"},
        color = __form_colors.metal,
    },

    ["青木阵"] = {
        condition = {"5名木属性", "的星将同时上阵"},
        effect = {"上阵的所有星将", "攻击+5% 防御+10%"},
        color = __form_colors.wood,
    },

    ["次木阵"] = {
        condition = {"3至4名木属性", "的星将同时上阵"},
        effect = {"上阵的所有木属性星将", "防御+10%"},
        color = __form_colors.wood,
    },

    ["癸水阵"] = {
        condition = {"5名水属性", "的星将同时上阵"},
        effect = {"上阵的所有星将", "生命+10% 闪避+5%"},
        color = __form_colors.water,
    },

    ["次水阵"] = {
        condition = {"3至4名水属性", "的星将同时上阵"},
        effect = {"上阵的所有水属性星将", "闪避+5%"},
        color = __form_colors.water,
    },

    ["烈火阵"] = {
        condition = {"5名火属性", "的星将同时上阵"},
        effect = {"上阵的所有星将", "攻击+5% 暴击+5%"},
        color = __form_colors.fire,
    },

    ["次火阵"] = {
        condition = {"3至4名火属性", "的星将同时上阵"},
        effect = {"上阵的所有火属性星将", "暴击+5%"},
        color = __form_colors.fire,
    },

    ["厚土阵"] = {
        condition = {"5名土属性", "的星将同时上阵"},
        effect = {"上阵的所有星将", "生命+10% 韧性+5%"},
        color = __form_colors.earth,
    },

    ["次土阵"] = {
        condition = {"3至4名土属性", "的星将同时上阵"},
        effect = {"上阵的所有土属性星将", "韧性+5%"},
        color = __form_colors.earth,
    },

    ["金水阵"] = {
        condition = {"2名金属性和2名水属性", "的星将同时上阵"},
        effect = {"上阵的所有星将", "命中+3% 闪避+3%"},
        color = __form_colors.water,
    },

    ["水木阵"] = {
        condition = {"2名水属性和2名木属性", "的星将同时上阵"},
        effect = {"上阵的所有星将", "闪避+3% 防御+5%"},
        color = __form_colors.wood,
    },

    ["木火阵"] = {
        condition = {"2名木属性和2名火属性", "的星将同时上阵"},
        effect = {"上阵的所有星将", "防御+5% 暴击+3%"},
        color = __form_colors.fire,
    },

    ["火土阵"] = {
        condition = {"2名火属性和2名土属性", "的星将同时上阵"},
        effect = {"上阵的所有星将", "暴击+3% 韧性+3%"},
        color = __form_colors.earth,
    },

    ["土金阵"] = {
        condition = {"2名土属性和2名金属性", "的星将同时上阵"},
        effect = {"上阵的所有星将", "韧性+3% 命中+3%"},
        color = __form_colors.metal,
    },

    ["五行阵"] = {
        condition = {"金木水火土五种属性", "的星将同时上阵"},
        effect = {"上阵的所有星将", "攻击+5% 血量+8% 命中+5% 暴击+5%"},
        color = {220, 220, 220},
    }
}

function BattleFormData:getFormDesc(name)
    return __form_desc_map[name]
end

function BattleFormData.getFormAddition(form)
    if form == nil then
        return {}
    end

    local name = BattleFormData.getFormName(form)
    CCLog("BattleFormData.getFormAddition:name", name)
    local addition = BattleFormData.getFormAdditionByName(name)
    CCLog("BattleFormData.getFormAddition:addition", vardump(addition))
    return addition
end

return BattleFormData
