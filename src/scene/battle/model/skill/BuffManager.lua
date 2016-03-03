--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 14-8-11
-- Time: 下午8:32
-- To change this template use File | Settings | File Templates.
--
--local BuffAffectType = {
--    DamageOverTime  = 1, --	持续伤害（值为公式ID）
--    ContinuesIncHP  = 2, --	持续回血（值为公式ID）
--    Vertigo         = 3, --	眩晕
--    Charm           = 4, --	魅惑
--    AddHit          = 5, --	增加命中
--    AddMiss         = 6, --	增加闪避
--    AddCri          = 7, --	增加暴击
--    AddTen          = 8, --	增加韧性
--    AddATK          = 9, --	增加攻击
--    AddDEF          = 10, --	增加防御
--    AddATKRatio     = 11, --	增加攻击万分比
--    AddDEFRatio     = 12, --	增加防御万分比
--    AntiInjuryRatio = 13, --	反弹伤害万分比
--    KillBackHPRatio = 14, --	击杀敌人回血（按目标的血量上限的万分比）
--    AddTreatment    = 15, --	增加治疗效果
--    AddTreated      = 16, --	增加被治疗效果
--    AddRatioATKByTeammateDie   = 17, --	己方每次阵亡一个单位，增加一定攻击万分比
--    AddNormATKRatio             = 18, --	增加普通攻击伤害（万分比）
--    DecNormATKRatio     = 19, --	减免普通攻击伤害（万分比）
--    AddSkillATKRatio    = 20, --	增加技能攻击伤害（万分比）
--    DecSkillATKRatio    = 21, --	减免技能攻击伤害（万分比）
--    AddExtraElemDamage  = 22, --	额外五行伤害加成
--    DecExtraElemDamage  = 23, --	额外五行伤害减免
--    Slow                = 24, --	迟缓（降低Name = 50, --%的攻击速度和移动速度）
--    Blinding            = 25, --	致盲（降低Name = 50, --%命中率）
--    AddAttckSpeedRatio = 26, --	增加攻击速度万分比
--    Hide            = 27, --	隐身（只有五行对其克制的角色才能攻击他）
--    MetalShield     = 28, --	金属性护盾 能吸收火属性以外的所有伤害 （作用值需要调用公式）
--    WoodShield      = 29, --	木属性护盾 能吸收金属性以外的所有伤害
--    WaterShield     = 30, --	水属性护盾 能吸收土属性以外的所有伤害
--    FireShield      = 31, --	火属性护盾 能吸收水属性以外的所有伤害
--    EarthShield     = 32, --	土属性护盾 能吸收木属性以外的所有伤害
--    Entangled       = 33, --	缠绕状态（无法移动，可以攻击，持续掉血,该buff的值表示每秒的掉血量的公式）
--    DamageReduction = 34, --	伤害减免（降低Name = 20, --%攻击，减免受到的普通攻击伤害和技能攻击伤害,值为公式）
--    Silence         = 35, --	沉默（无法释放技能）
--    Poisoning       = 36, --	中毒(持续掉血,值为公式;降低Name = 30, --%移动速度,攻击速度)
--    AddMissRatio    = 37, --	增加闪避值万分比
--    FixedBody       = 38, --	定身（无法移动，可以攻击使用技能）
--    SpellShield     = 39, --	法术盾：抵消N次技能伤害（普通技能和怒气技能，N为所填的值）
--}

local BuffModel = require("scene.battle.model.skill.BuffModel")
-------------------------------------------------------------------------------

local BuffManager = class("BuffManager")

function BuffManager:ctor(fighter)
    self.fighter = fighter
    self.activeBuffList = {}

    self.cache = {}
    self.affectCache = {}
end

function BuffManager:toString()
    local buffList = {}
    for _, buff in ipairs(self.activeBuffList) do
        table.insert(buffList, buff.buffData)
    end
    return vardump(buffList, "BuffList")
end

function BuffManager:resetCache()
    self.cache = {}
    self.affectCache = {}
end

function BuffManager:getActiveBuffList()
    return self.activeBuffList
end

function BuffManager:clear()
    local buffList = self.activeBuffList

    self.activeBuffList = {}
    for _, buff in ipairs(buffList) do
        self:onBuffRemoved(buff)
    end

    self:resetCache()
end

function BuffManager:clearDebuff()
    local buffList = self.activeBuffList

    local debuffList = {}
    local leftBuffList = {}

    for _, buff in ipairs(buffList) do
        if buff:isDebuff() then
            table.insert(debuffList, buff)
        else
            table.insert(leftBuffList, buff)
        end
    end

    self.activeBuffList = leftBuffList
    for _, buff in ipairs(debuffList) do
        self:onBuffRemoved(buff)
    end

    self:resetCache()

    return debuffList
end

function BuffManager:addBuff(buffModel)
    assert(iskindof(buffModel, "BuffModel"))
    local buffData = buffModel:getBuffData()

    local idx = self:find(buffData.id)

    if idx == nil then
        table.insert(self.activeBuffList, buffModel)
        self:onBuffAdded(buffModel)
    else
        -- CCLog("替换")
        local oldBuff = self.activeBuffList[idx]
        self.activeBuffList[idx] = buffModel

        self:onBuffReplaced(oldBuff, buffModel)
    end

    self:resetCache()
end

function BuffManager:addRawBuff(buffModel)
    assert(iskindof(buffModel, "BuffModel"))
    table.insert(self.activeBuffList, buffModel)
    self:resetCache()
end

function BuffManager:removeRawBuff(buffModel)
    for idx, buff in ipairs(self.activeBuffList) do
        if buff.buffID == buffModel.buffID then
            table.remove(self.activeBuffList, idx)
            self:resetCache()
            break
        end
    end
end

function BuffManager:update()
    for _, buff in ipairs(self.activeBuffList) do
        buff:update()
    end

    for i = #self.activeBuffList, 1, -1 do
        local buff = self.activeBuffList[i]

        if buff:isFinish() then
            table.remove(self.activeBuffList, i)

            self:onBuffRemoved(buff)

            self:resetCache()
        end
    end    
end

function BuffManager:onHit()
    for _, buff in ipairs(self.activeBuffList) do
        buff:onHit()
    end
end

function BuffManager:onBuffAdded(buff)
    self.fighter:onBuffAdded(buff)
end

function BuffManager:onBuffRemoved(buff)
    self.fighter:onBuffRemoved(buff)
end

function BuffManager:onBuffReplaced(oldBuff, newBuff)
    self.fighter:onBuffReplaced(oldBuff, newBuff)
end

function BuffManager:onAttack(attackData)

end

function BuffManager:onKilledEnemy(enemyModel)

end

function BuffManager:getAffectValue(affectType, add)
    if add == nil then
        add = true
    end

    local affectValue = 0
    for _, buffModel in ipairs(self.activeBuffList) do
        if buffModel.buffData.affect == affectType then
            if add then
                affectValue = affectValue + buffModel.buffData.value
            else
                return buffModel.buffData.value
            end
        end
    end
    return affectValue
end

function BuffManager:useMagicShieldValue(affectType, maxValue)
    local total = 0
    for _, buffModel in ipairs(self.activeBuffList) do
        if buffModel.buffData.affect == affectType then
            local usedValue = buffModel:useMagicShieldValue(maxValue)
            total = total + usedValue
            maxValue = maxValue - usedValue
            if maxValue <= 0 then
                break
            end
        end
    end
    return total
end

function BuffManager:getCachedAffectValue(affectType)
    local affectValue = self.cache[affectType]

    if affectValue == nil then
        affectValue = self:getAffectValue(affectType)
        self.cache[affectType] = affectValue
    end

    return affectValue
end

function BuffManager:exists(buffID)
    for _, buff in ipairs(self.activeBuffList) do
        if buff.buffID == buffID then
            return true
        end
    end

    return false
end

function BuffManager:hasAffect(affect)
    if self.affectCache[affect] then
        return true
    end

    for _, buffModel in ipairs(self.activeBuffList) do
        if buffModel.buffData.affect == affect then
            self.affectCache[affect] = true
            return true
        end
    end

    return false
end

function BuffManager:getAffectValueLeft(affect)
    local affectValueLeft = 0
    for _, buffModel in ipairs(self.activeBuffList) do
        if buffModel.buffData.affect == affect then
            affectValueLeft = affectValueLeft + buffModel.affectValueLeft
        end
    end

    return affectValueLeft
end

function BuffManager:hasAffectValueLeft(affect)
    for _, buffModel in ipairs(self.activeBuffList) do
        if buffModel.buffData.affect == affect then
            if buffModel.affectValueLeft > 0 then
                return true
            end
        end
    end

    return false
end

function BuffManager:decAffectValueLeft(affect)
    for _, buffModel in ipairs(self.activeBuffList) do
        if buffModel.buffData.affect == affect and buffModel.affectValueLeft > 0 then
            buffModel.affectValueLeft = buffModel.affectValueLeft - 1

            if buffModel.affectValueLeft <= 0 then
                buffModel.timeLeft = 0
            end

            return true
        end
    end

    return false
end


function BuffManager:find(buffID)
    for idx, buff in ipairs(self.activeBuffList) do
        if buff.buffID == buffID then
            return idx
        end
    end

    return nil
end

function BuffManager:heroCanAttack()
    local disableList = {
        enums.BuffAffectType.Vertigo,
        enums.BuffAffectType.Sleep,
    }

    for _, buff in ipairs(self.activeBuffList) do
        if table.find(disableList, buff.affect) then
            return false
        end
    end

    return true
end

function BuffManager:heroCanMove()
    local disableList = {
        enums.BuffAffectType.FixedBody,
        enums.BuffAffectType.Sleep,
    }

    for _, buff in ipairs(self.activeBuffList) do
        if table.find(disableList, buff.affect) then
            return false
        end
    end

    return true
end

function BuffManager:heroCanHit()
    local disableList = {
        [enums.BuffAffectType.Hide] = true,
        [enums.BuffAffectType.Shackle] = true,
    }

    for _, buff in ipairs(self.activeBuffList) do
        if disableList[buff.affect] then
            return false
        end
    end

    return true
end

function BuffManager:heroCanReleaseSkill()
    local disableList = {
        enums.BuffAffectType.Silence,
        enums.BuffAffectType.Sleep,
    }

    for _, buff in ipairs(self.activeBuffList) do
        if table.find(disableList, buff.affect) then
            return false
        end
    end

    return true
end

function BuffManager:getMoveSpeedAddition()
    if self.cache.moveSpeedAddition == nil then
        local speedAdd = 0

        -- 中毒(持续掉血,值为公式;降低30%移动速度,攻击速度)
        if self:hasAffect(enums.BuffAffectType.Poisoning) then
            speedAdd = speedAdd -3000
        end

        --迟缓（降低50%的攻击速度和移动速度）
        if self:hasAffect(enums.BuffAffectType.Slow) then
            speedAdd = speedAdd -5000
        end

        self.cache.moveSpeedAddition = math.max(speedAdd, -10000 + 1)
    end

    return self.cache.moveSpeedAddition
end

function BuffManager:getAttackSpeedAddition()
    if self.cache.attackSpeedAddition == nil then
        local speedAdd = 0

        -- 增加攻速
        for _, buffModel in ipairs(self.activeBuffList) do
            if buffModel.buffData.affect == enums.BuffAffectType.AddAttckSpeedRatio then
                speedAdd = speedAdd + buffModel.buffData.value
            end
        end

        -- 中毒(持续掉血,值为公式;降低30%移动速度,攻击速度)
        for _, buffModel in ipairs(self.activeBuffList) do
            if buffModel.buffData.affect == enums.BuffAffectType.Poisoning then
                speedAdd = speedAdd -3000
            end
        end

        --迟缓（降低50%的攻击速度和移动速度）
        for _, buffModel in ipairs(self.activeBuffList) do
            if buffModel.buffData.affect == enums.BuffAffectType.Slow then
                speedAdd = speedAdd -5000
            end
        end

        self.cache.attackSpeedAddition = math.max(speedAdd, -10000)
    end

    return self.cache.attackSpeedAddition
end

function BuffManager:getAttackSpeedVar()
    if self.cache.atkSpeedVar == nil then
        local atkSpeedAdd = self:getAttackSpeedAddition()
        local atkSpeedVar = (atkSpeedAdd + 10000) / 10000

        self.cache.atkSpeedVar = atkSpeedVar
    end

--    if self.cache.atkSpeedVar ~= 1 then
--       CCLog(vardump({speedVar = self.cache.atkSpeedVar}, "BuffManager:getAttackSpeedVar()"))
--    end

    return self.cache.atkSpeedVar
end

-- 普攻加成
function BuffManager:getDamageAddition()
    return self:getCachedAffectValue(enums.BuffAffectType.AddNormATKRatio)
end

-- 普攻减免
function BuffManager:getDamageReduction()
    local MAX_REDUCE_DAMAG = 8000

    local result = self:getCachedAffectValue(enums.BuffAffectType.DecNormATKRatio)

    local formulaID = self:getCachedAffectValue(enums.BuffAffectType.DamageReduction)
    if formulaID and formulaID > 0 then
        local formulaExpr = BaseConfig.FormulaContent(formulaID)
        local formulaFunction = assert(BaseConfig.FormulaFunc(formulaID), string.format("formula[%d]:%s", formulaID, formulaExpr))
        local affectValue = formulaFunction({skillLV = self.skillLevel or 1})
        result = result + affectValue
    end

    -- 减免
    return math.min(result, MAX_REDUCE_DAMAG)
end

function BuffManager:getSkillAddition()
    return self:getCachedAffectValue(enums.BuffAffectType.AddSkillATKRatio)
end

function BuffManager:getSkillReduction()
    local MAX_REDUCE_DAMAG = 8000
    local result = self:getCachedAffectValue(enums.BuffAffectType.DecSkillATKRatio)

    local formulaID = self:getCachedAffectValue(enums.BuffAffectType.DamageReduction)
    if formulaID and formulaID > 0 then
        local formulaExpr = BaseConfig.FormulaContent(formulaID)
        local formulaFunction = assert(BaseConfig.FormulaFunc(formulaID), string.format("formula[%d]:%s", formulaID, formulaExpr))
        local affectValue = formulaFunction({skillLV = self.skillLevel or 1})
        result = result + affectValue
    end

    -- 减免
    return math.min(result, MAX_REDUCE_DAMAG)
end

function BuffManager:getTreatmentAddition()
    return self:getCachedAffectValue(enums.BuffAffectType.AddTreatment)
end

function BuffManager:getTreatedAddition()
    return self:getCachedAffectValue(enums.BuffAffectType.AddTreated)
end

function BuffManager:getTreatmentReduction()
    -- TODO:
    --return self:getCachedAffectValue(enums.BuffAffectType.AddTreatment)
    return 0
end

function BuffManager:getTreatedReduction()
    -- TODO:
    --return self:getCachedAffectValue(enums.BuffAffectType.AddTreated)
    return 0
end

function BuffManager:getSpecDamageAddition()
    return self:getCachedAffectValue(enums.BuffAffectType.AddExtraElemDamage)
end

function BuffManager:getSpecDamageReduction()
    return self:getCachedAffectValue(enums.BuffAffectType.DecExtraElemDamage)
end

return BuffManager