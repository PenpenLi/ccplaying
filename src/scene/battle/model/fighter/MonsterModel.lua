--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 15/1/29
-- Time: 下午4:27
-- 怪物
--

local BattleHeroModel = require("scene.battle.model.fighter.BattleHeroModel")
-------------------------------------------------------------------------------

local MonsterModel = class("MonsterModel", BattleHeroModel)

function MonsterModel:ctor(monsterData, team)
    local heroCreateData = {type = "monster", data = monsterData}
    MonsterModel.super.ctor(self, heroCreateData, team)
end

return MonsterModel