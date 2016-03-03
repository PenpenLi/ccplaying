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

local FollowMagicCircleModel = class("FollowMagicCircleModel", MagicCircleModel)

function FollowMagicCircleModel:ctor(attackData)
    self.attackData = attackData
    self.timeLeft = attackData.skillData.durationTime
    self.intervalLeft = attackData.skillData.interval
end

function FollowMagicCircleModel:getTargetFighterList()
    local cell = self.attackData.attacker:getCell()
    self.attackData:setDestCell(cell)

--    local cellPos = self.attackData.attacker:getCellPos()
--    local regionRect = self.attackData.attacker:getAbsSkillRegionRect(self.attackData.skillData.type)
--    CCLog(vardump({cell = cell, cellPos = cellPos, regionRect = regionRect}, "Follow Magic rect"))

    return self.attackData:calcHeroTargetFighterList()
end

function FollowMagicCircleModel:encode()
    return json.encode({destCell = self.destCell, attackData = self.attackData:encode()})
end

function FollowMagicCircleModel.decode(jsonStr, battleModel)
    local jsData = json.decode(jsonStr)
    local attackData = AttackDataModel.decode(jsData.attackData, battleModel)

    --CCLog(vardump({jsData = jsData, heroModel = heroModel, attackerModel = attackerModel, buffID = buffID}, "BuffModel:decode"))
    return FollowMagicCircleModel.new(attackData)
end

return FollowMagicCircleModel
