--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 14-10-27
-- Time: 下午6:10
-- To change this template use File | Settings | File Templates.
--

--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 14-10-23
-- Time: 下午6:15
-- 魔法阵
--
local BattleConfig = require("scene.battle.helper.BattleConfig")
local AttackDataModel = require("scene.battle.model.attack.AttackDataModel")
local MagicCircleModel = require("scene.battle.model.skill.MagicCircleModel")
-------------------------------------------------------------------------------

local FixedMagicCircleModel = class("FixedMagicCircleModel", MagicCircleModel)

function FixedMagicCircleModel:ctor(ID, attackData, battleModel)
    FixedMagicCircleModel.super.ctor(self, attackData)

    assert(ID and type(ID) == "number", "ID is nil or not number")
    self.ID = ID
    self.battleModel = battleModel
    self.destCell = assert(attackData:getDestCell())
    self.view = nil
    CCLog(vardump({cell = self.destCell}, "FixedMagicCircleModel:ctor"))

    self.isPrison = false
    if attackData.skillData.affect == enums.SkillAffectType.Prison then
        self.isPrison = true
        self.targetFighterList = self:getTargetFighterList()

        local prisonArea = bitarray2d.new(BattleConfig.X_CELL_COUNT, BattleConfig.Y_CELL_COUNT)
        self.prisonArea = prisonArea

        local skillAreaBitmap = attackData:absArea()
        local getCellPos = BattleConfig.getCellPos
        prisonArea:fill()
        for y = 0, BattleConfig.Y_CELL_COUNT - 1 do
            for x = 0, BattleConfig.X_CELL_COUNT - 1 do
                local pos = getCellPos(x, y)
                if skillAreaBitmap:get(pos.x, pos.y) then
                    prisonArea:set(x, y, false)
                end
            end
        end    

        if DEBUG > 0 then
            local nameList = {}
            for _, fighter in ipairs(self.targetFighterList) do
                table.insert(nameList, fighter:getName())
            end

            CCLog(vardump({prisonArea = prisonArea, fighterList = nameList}))
        end
    end
end

function FixedMagicCircleModel:getPrisonArea(fighter)
    for _, fighterModel in ipairs(self.targetFighterList) do
        if fighter:getFighterID() == fighterModel:getFighterID() then
           return self.prisonArea
        end
    end
    return nil
end

function FixedMagicCircleModel:getCell()
    return self.destCell
end

function FixedMagicCircleModel:setView(view)
    self.view = view
end

function FixedMagicCircleModel:getView()
    return self.view
end

function FixedMagicCircleModel:getTargetFighterList()
    CCLog("FixedMagicCircleModel:getTargetFighterList()")
    if self.attackData:attackerIsHero() then
        self.attackData:setDestCell(self.destCell)
        return self.attackData:calcHeroTargetFighterList()
    elseif self.attackData:attackerIsInstance() then
       return self.attackData:calcInstanceTargetFighterList()
    else
        CCLog("TODO:", self.attackData:getAttackerType())
    end
end

function FixedMagicCircleModel:encode()
    return json.encode({destCell = self.destCell, attackData = self.attackData:encode()})
end

function FixedMagicCircleModel.decode(jsonStr, battleModel)
    local jsData = json.decode(jsonStr)
    local attackData = AttackDataModel.decode(jsData.attackData, battleModel)
    attackData:setDestCell(jsData.destCell)

    return FixedMagicCircleModel.new(attackData)
end

return FixedMagicCircleModel
