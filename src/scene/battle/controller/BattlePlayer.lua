--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 15/3/26
-- Time: 上午10:00
-- To change this template use File | Settings | File Templates.
--
local BattleConfig = require("scene.battle.helper.BattleConfig")
local BattleUtils = require("scene.battle.helper.Utils")
local BattleMapManager = require("scene.battle.view.BattleMapManager")
-------------------------------------------------------------------------------

local BattlePlayer = class("BattlePlayer", function() return cc.Node:create() end)

function BattlePlayer:ctor()
    self.backgroupNode = cc.Node:create()
    self:addChild(self.backgroupNode, 1)

    self.farMapNode = cc.Node:create()
    self.backgroupNode:addChild(self.farMapNode, -1)

    self.middleNode = cc.Node:create()
    self:addChild(self.middleNode, 2)

    self.middleMapNode = cc.Node:create()
    self.middleNode:addChild(self.middleMapNode, -1)

    self.battleNode = cc.Node:create() -- cc.LayerColor:create(cc.c4b(100, 0, 0, 100))
    self.middleMapNode:addChild(self.battleNode, 1)
    self.battleNode:setRotationSkewX(BattleConfig.BEVEL_ANGLE)
    self.battleNode:setPosition(BattleConfig.BATTLE_POS)
    self.battleNode:setContentSize(BattleConfig.BATTLE_SIZE)

    local battleTopPos = self.battleNode:convertToWorldSpace(cc.p(0, BattleConfig.BATTLE_SIZE.height))
    local battleBottomPos = self.battleNode:convertToWorldSpace(cc.p(0, 0))
    local battleHeight = battleTopPos.y - battleBottomPos.y
    local battleScaleY = BattleConfig.BATTLE_SIZE.height / battleHeight

    self.battleNode:setScaleY(battleScaleY)

    -- 调试用的网络
    if false then
        -- 网络显示调度用
        local gridRect = cc.rect(0, 0, BattleConfig.BATTLE_SIZE.width, BattleConfig.BATTLE_SIZE.height)
        local color1 = cc.c4f(1.0, 1.0, 0.0, 0.2)
        local color2 = cc.c4f(0.0, 1.0, 1.0, 0.2)
        local gridLayer = GridLayer.new(gridRect, BattleConfig.X_CELL_COUNT, BattleConfig.Y_CELL_COUNT, color1, color2, 0)
        self.battleNode:addChild(gridLayer)
    end

    self.foregroundNode = cc.Node:create()
    self:addChild(self.foregroundNode, 3)

    self.nearMapNode = cc.Node:create()
    self.foregroundNode:addChild(self.nearMapNode, -1)

    self.fighterViewMap = {}    -- fighterID:fighterView
    self.magicCircleVewMap = {} -- magicCircleSerialID:magicCiricleView
    self.fighterRegionNodeMap = {} -- fighterID:regionNode
    self.fighterAreaNodeMap = {} -- fighterID:areaNode

    self.commandHandlerMap = nil
end

function BattlePlayer:checkViewMap()
    local fighterIDList = table.keys(self.fighterViewMap)
    for _, id in ipairs(fighterIDList) do
        if tolua.isnull(self.fighterViewMap[id]) then
            self.fighterViewMap[id] = nil
        end
    end

    local magicIdList = table.keys(self.magicCircleVewMap)
    for _, id in ipairs(magicIdList) do
        if tolua.isnull(self.magicCircleVewMap[id]) then
            self.magicCircleVewMap[id] = nil
        end
    end
end

function BattlePlayer:setFighterView(fighterID, fighterVew)
    assert(fighterID and type(fighterID) == "string", tostring(fighterID))
    self.fighterViewMap[fighterID] = fighterVew
end

function BattlePlayer:getFighterView(fighterID)
    local fighterVew = self.fighterViewMap[fighterID]

    if fighterVew and tolua.isnull(fighterVew) then
        self.fighterViewMap[fighterID] = nil
        fighterVew = nil
    end

    return fighterVew
end

function BattlePlayer:setMagicCircleView(serialID, magicCircleView)
    self.magicCircleVewMap[serialID] = magicCircleView
end

function BattlePlayer:getMagicCircleView(serialID)
    local magicCircleView = self.magicCircleVewMap[serialID]

    if magicCircleView and tolua.isnull(magicCircleView) then
        self.magicCircleVewMap[serialID] = nil
        magicCircleView = nil
    end

    return magicCircleView
end

function BattlePlayer:_cmd_loadMap()
    local map = BattleMapManager.new(self.params.map, self.nearMapNode, self.middleMapNode, self.farMapNode)
    self.mapMgr = map

    if self.params.battleType == "PVP" or self.params.battleType == "Tower" then
        map:setRoundOffsetPercent(1, 1.0)
    end
end

function BattlePlayer:doCommand(cmd, params)
    local handler = BattlePlayer["_cmd__" .. cmd]
    if handler then
        handler(self, params)
    else
        CCLog("cmd:", cmd, "has no handler")
    end
end

function BattlePlayer:loadMap(map)
    local map = BattleMapManager.new(self.params.map, self.nearMapNode, self.middleMapNode, self.farMapNode)
    self.mapMgr = map

    if self.params.battleType == "PVP" or self.params.battleType == "Tower" then
        map:setRoundOffsetPercent(1, 1.0)
    end
end

return BattlePlayer