--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 14-10-21
-- Time: 上午10:55
-- To change this template use File | Settings | File Templates.
--

local SkillScopeInfo = require("scene.battle.helper.SkillScopeInfo")

local _M = {}

--[[
怪物
{
    "ID": 1002,
    "Name": "远程小弟",
    "StarLv": 3,
    "Res": "gw_1002",
    "WX": 1,
    "Gender": 1,
    "Scale": 10000,
    "IsBoss": 0,
    "Atk": 411,
    "Def": 146,
    "Hp": 2220,
    "Mp": 274,
    "Hit": 30,
    "Miss": 20,
    "Cit": 30,
    "Ten": 26,
    "AtkSpeed": 2400,
    "AtkSkill": 1002,
    "TfSkill": 0,
    "TfSkillLv": 0,
    "NorSkillLevel": 0,
    "NorSkillLv": 0,
    "RpSkill": 0,
    "RpSkillLv": 0
},

英雄基础数据
  {
    "id": 1001,
    "name": "元始天尊",
    "res": "xj_1001",
    "talent": 15,
    "gender": 1,
    "wx": 3,
    "scale": 10000,
    "armType": 2,
    "starLevel": 0,
    "move": 1,
    "atkSpeed": 2300,
    "atkSkill": 1002,
    "atk": 310,
    "def": 102,
    "hp": 1781,
    "mp": 224,
    "hit": 40,
    "miss": 15,
    "crit": 28,
    "ten": 24,
    "atkGrow": 224000,
    "defGrow": 72000,
    "hpGrow": 1092000,
    "mpGrow": 145000,
    "tfSkill": 1101,
    "norSkill": 1201,
    "rpSkill": 1301,
    "desc": "哇哈哈哈哈"
  },

英雄实例数据
    {
    "UID": "58",
    "ID": 1003,
    "Level": 1,
    "StarLevel": 4,
    "Exp": 0,
    "MaxExp": 220,
    "HP": 9162,
    "Atk": 90,
    "Def": 90,
    "MP": 90,
    "Mood": 0,
    "TFP": 2166,
    "TFSkillLevel": 1,
    "NorSkillLevel": 1,
    "RPSkillLevel": 1,
    "MaxRPSkillLevel": 11,
    "RPSkillExp": 0,
    "MaxRPSkillExp": 50
  },
--]]

function _M.monsterToHeroData(monsterData)
    return {
        ["ID"           ] = monsterData.ID,
        --["Level"        ] = monsterData.xxx,
        ["StarLevel"    ] = monsterData.StarLv,
        --["Exp"          ] = monsterData.xxx,
        --["MaxExp"       ] = monsterData.xxx,
        ["HP"           ] = math.max(monsterData.Hp, 1),
        ["Atk"          ] = monsterData.Atk,
        ["Def"          ] = monsterData.Def,
        ["MP"           ] = monsterData.Mp,
        ["Mood"         ] = enums.HeroMood.Normal,
        --["TFP"          ] = monsterData.xxx,
        ["TFSkillLevel"      ] = monsterData.TfSkillLv,
        ["NorSkillLevel"     ] = monsterData.NorSkillLv,
        ["TFSkillLevel"      ] = monsterData.TfSkillLv,
        ["RPSkillLevel"      ] = monsterData.RpSkillLv,
        --["MaxRPSkillLevel"   ] = monsterData.xxx,
        --["RPSkillExp"   ] = monsterData.xxx,
        --["MaxRPSkillExp"] = monsterData.xxx
        ["equip"] = monsterData.equip,
        ["IsBoss"] = monsterData.IsBoss,
    }

end

function _M.monsterToHeroBaseData(monsterData)
    return {
        ["ID"       ] = monsterData.ID,
        ["name"     ] = monsterData.Name,
        ["res"      ] = monsterData.Res,
        --["talent"   ] = monsterData.xxx,
        ["gender"   ] = monsterData.Gender,
        ["wx"       ] = monsterData.WX,
        ["scale"    ] = monsterData.Scale,
        --["armType"  ] = monsterData.xxx,
        ["starLevel"] = monsterData.StarLv,
        ["move"     ] = monsterData.Move,
        ["atkSpeed" ] = monsterData.AtkSpeed,
        ["atkSkill" ] = monsterData.AtkSkill,
        ["atk"      ] = monsterData.Atk,
        ["def"      ] = monsterData.Def,
        ["hp"       ] = math.max(monsterData.Hp, 1),
        ["mp"       ] = monsterData.Mp,
        ["hit"      ] = monsterData.Hit,
        ["miss"     ] = monsterData.Miss,
        ["crit"     ] = monsterData.Crit,
        ["ten"      ] = monsterData.Ten,
        --["atkGrow"  ] = monsterData.xxx,
        --["defGrow"  ] = monsterData.xxx,
        --["hpGrow"   ] = monsterData.xxx,
        --["mpGrow"   ] = monsterData.xxx,
        ["tfSkill"  ] = monsterData.TfSkill,
        ["norSkill" ] = monsterData.NorSkill,
        ["rpSkill"  ] = monsterData.RpSkill,
        ["Bulk"     ] = monsterData.Bulk,
        ["desc"     ] = "怪物",
    }
end

--[[
    {
        "ID": 1001,
        "Res": "pt_1",
        "Atk": 250,
        "Def": 100,
        "Hp": 5000,
        "Skill": 1002
    }
-- ]]
--function _M.turretToHeroData(turretData)
--    return {
--        ["ID"           ] = turretData.ID,
--        --["Level"        ] = monsterData.xxx,
--        ["StarLevel"    ] = 1,
--        --["Exp"          ] = monsterData.xxx,
--        --["MaxExp"       ] = monsterData.xxx,
--        ["HP"           ] = turretData.Hp,
--        ["Atk"          ] = turretData.Atk,
--        ["Def"          ] = turretData.Def,
--        ["MP"           ] = 0,
--        ["Mood"         ] = enums.HeroMood.Normal,
--        --["TFP"          ] = monsterData.xxx,
--        ["TFSkillLevel"      ] = 1,
--        ["NorSkillLevel"     ] = 1,
--        ["TFSkillLevel"      ] = 1,
--        ["RPSkillLevel"      ] = 1,
--        --["MaxRPSkillLevel"   ] = monsterData.xxx,
--        --["RPSkillExp"   ] = monsterData.xxx,
--        --["MaxRPSkillExp"] = monsterData.xxx
--    }
--
--end
--
--function _M.turretToHeroBaseData(turretData)
--    return {
--        ["ID"       ] = turretData.ID,
--        ["name"     ] = "箭塔",
--        ["res"      ] = turretData.Res,
--        --["talent"   ] = monsterData.xxx,
--        ["gender"   ] = 0,
--        ["wx"       ] = 0,
--        ["scale"    ] = 1,
--        --["armType"  ] = monsterData.xxx,
--        ["starLevel"] = 1,
--        ["move"     ] = 10000,
--        ["atkSpeed" ] = 10000,
--        ["atkSkill" ] = turretData.Skill,
--        ["atk"      ] = turretData.Atk,
--        ["def"      ] = turretData.Def,
--        ["hp"       ] = turretData.Hp,
--        ["mp"       ] = 0,
--        ["hit"      ] = 0,
--        ["miss"     ] = 0,
--        ["crit"     ] = 0,
--        ["ten"      ] = 0,
--        --["atkGrow"  ] = monsterData.xxx,
--        --["defGrow"  ] = monsterData.xxx,
--        --["hpGrow"   ] = monsterData.xxx,
--        --["mpGrow"   ] = monsterData.xxx,
--        ["tfSkill"  ] = 0,
--        ["norSkill" ] = 0,
--        ["rpSkill"  ] = 0,
--        ["desc"     ] = "箭塔",
--    }
--end

function _M.getCellZOrder(cell, dir)
    local y = 5 - (cell.y or 0)
    local x = cell.x or 0
    if dir == "left" then
        x = 20 - cell.x
    end

    return y * 10000 + x * 100
end

function _M.moveNodeContainer(node, containter)
    if node == nil or tolua.isnull(node) or containter == nil or tolua.isnull(containter) then
        CCLog("moveNodeContainer has null node")
        return
    end


    local parent = node:getParent()
    node:retain()
    parent:removeChild(node, false)
    local pos = cc.p(node:getPosition())
    local worldPos = parent:convertToWorldSpace(pos)
    local relPos = containter:convertToNodeSpace(worldPos)
    containter:addChild(node)
    node:setPosition(relPos)
    node:release()
end

local __teammateTarget = {
    [enums.SkillAffectTarget.AllEnemies] = false,
    [enums.SkillAffectTarget.AllTeammates] = false,
    [enums.SkillAffectTarget.Self] = true,
    [enums.SkillAffectTarget.MatchedEnemy] = false,
    [enums.SkillAffectTarget.RandomEnemy] = false,
    [enums.SkillAffectTarget.ScopeEnemies] = false,
    [enums.SkillAffectTarget.ScopeTeammates] = true,
    [enums.SkillAffectTarget.RandomTeamate] = true,
    [enums.SkillAffectTarget.MostWeakEnemy] = false,
    [enums.SkillAffectTarget.MinPercentHPTeammate] = true,
    [enums.SkillAffectTarget.AroundEnemies] = false,
    [enums.SkillAffectTarget.SelectAreaEnemies] = false,
    [enums.SkillAffectTarget.DeadTeammate] = true,
    [enums.SkillAffectTarget.NRandomTeamates] = true,
    [enums.SkillAffectTarget.NRandomEnemies] = false,
    [enums.SkillAffectTarget.NWeakestTeamates] = true,
    [enums.SkillAffectTarget.NWeakestEnemies] = false,
    [enums.SkillAffectTarget.Attacker] = false,
    [enums.SkillAffectTarget.FarEnemy] = false,
}
function _M.skillTargetIsTeammate(skillTarget)
    return __teammateTarget[skillTarget]
end

function _M.getSkillRegion(skillID)
    local strID = string.format("%d", skillID)

    local skillInfo = SkillScopeInfo[strID]

    if skillInfo then
        local region = skillInfo.region
        return region
    else
        return nil
    end
end

function _M.getSkillArea(skillID)
    local strID = string.format("%d", skillID)

    local skillInfo = SkillScopeInfo[strID]

    if skillInfo then
        local area = skillInfo.area
        return area
    else
        return nil
    end
end

return _M
