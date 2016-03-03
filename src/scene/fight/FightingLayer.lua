
--战斗 布局模块 本模块涉及界面的布局 包括敌我双方布局 背景布局 可控制布局 测试网格布局
--其中最重要的是人物布局 从dummydata里面取出需要的人物数据 进行模型和视图的创建 
--最后调用controller功能 完成人物布局 做到 模型 视图 和 控制的关联
local FightingLayer = class("FightingLayer", BaseLayer)


local gridSwitch = true

local MAX_SCREEN_GRID_X = 21
local MAX_SCREEN_GRID_Y = 14

local MAX_ACTIVE_GRID_X = 21
local MAX_ACTIVE_GRID_Y = 10

local wGrid = display.widthInPixels / MAX_SCREEN_GRID_X
local hGrid = display.heightInPixels / MAX_SCREEN_GRID_Y

local visibleSize = cc.Director:getInstance():getVisibleSize()
local origin = cc.Director:getInstance():getVisibleOrigin()
local x = origin.x + visibleSize.width / 2
local y = origin.y + visibleSize.height / 2

function FightingLayer:ctor()
    FightingLayer.super.ctor(self)

   self.container = cc.Node:create()
   local bgdata = require("app.scenes.common.BackGround")
   self.bg = bgdata.new("Map/map.json",self)
   self.bg:setPosition(x,y)
   self.container:addChild(self.bg) 

   self.sceneOrder = 0
   self.sceneCount = 2
   self.count = 0
   
   self.bzList = {

         { x = 2, y = 3 }, { x = 2, y = 6 }, { x = 2, y = 9},
         { x = 5, y = 3 }, { x = 5, y = 6 }, { x = 5, y = 9},
         { x = 8, y = 3 }, { x = 8, y = 6 }, { x = 8, y = 9},

         { x = 14, y = 3 }, { x = 14, y = 6 }, { x = 14, y = 9},
         { x = 17, y = 3 }, { x = 17, y = 6 }, { x = 17, y = 9},
         { x = 20, y = 3 }, { x = 20, y = 6 }, { x = 20, y = 9},
  }
  
   if gridSwitch then
      for i = 1, MAX_ACTIVE_GRID_Y do
      
          for j = 1, MAX_ACTIVE_GRID_X do
              if i >= 1 and i <= MAX_ACTIVE_GRID_Y and (i + j) % 2 ~= 0 then
                 local x = (j - 1) * wGrid 
                 local y = (i - 1) * hGrid
                 local rect = {cc.p(0,hGrid),cc.p(wGrid,hGrid),cc.p(wGrid,0), cc.p(0,0)}
                 local draw = cc.DrawNode:create()
                 local color = cc.c4f(0.0,0.0,0.0,0.4)
                 draw:drawPolygon(rect,4,color,0,color)
                 draw:setPosition(x,y)
                 self.container:addChild(draw)
              end
          end
      end
  
  for i, v in ipairs(self.bzList) do
      local bx = v.x
      local by = v.y
      local x = (bx - 1) * wGrid
      local y = (by - 1) * hGrid
      local rect = {cc.p(0,hGrid),cc.p(wGrid,hGrid),cc.p(wGrid,0), cc.p(0,0)}
      local draw = cc.DrawNode:create()
      local color = cc.c4f(1.0, 0.0, 0.0, 0.6)
      draw:drawPolygon(rect,4,color,0,color)
      draw:setPosition(x,y)
      self.container:addChild(draw)
  end
  
  local color = cc.c4f(0.0, 0.0, 0.0, 0.0)
  local draw = cc.DrawNode:create()
  local borderColor = cc.c4f(1.0, 1.0, 0.0, 0.8)
  local rect = {cc.p(0,hGrid * 10),cc.p(wGrid,hGrid * 10),cc.p(wGrid,0), cc.p(0,0)}
  draw:drawPolygon(rect,4,color,0.5,borderColor)
  draw:setPosition(10 * wGrid,0)
  self.container:addChild(draw)
  
  local rect = {cc.p(0,hGrid),cc.p(wGrid * 21,hGrid),cc.p(wGrid * 21,0), cc.p(0,0)}
  local draw = cc.DrawNode:create()
  draw:drawPolygon(rect,4,color,0.5,borderColor)
  draw:setPosition(0,0)
  self.container:addChild(draw)
  
  for i = 1, MAX_ACTIVE_GRID_X do
      local x = (i - 1) * wGrid + wGrid / 2
      local y = hGrid / 2
      local label = CCLabelAtlas:_create(i .. "","images/fortune/fortune_number.png", 34, 50, string.byte("0"))
      label:setPosition(cc.p(x,y))
      label:setAnchorPoint(0.5, 0.5)
      label:setScale(0.6)
      self.container:addChild(label)
  end

  for i = 2, MAX_ACTIVE_GRID_Y do
      local x = wGrid / 2
      local y = hGrid / 2 + (i - 1) * hGrid
      local label = CCLabelAtlas:_create(i .. "","images/fortune/fortune_number.png", 34, 50, string.byte("0"))
      label:setPosition(cc.p(x,y))
      label:setAnchorPoint(0.5, 0.5)
      label:setScale(0.6)
      self.container:addChild(label)
  end
end
  local back_btn = ccui.Button:create("Game/GUI/button.png")
  back_btn:setPosition(display.cx - 150,display.cy + 250)
  back_btn:setTitleFontSize(18)
  back_btn:setTitleText("返回")
  back_btn:addTouchEventListener(widget_click_listener(function(sender)
      application:enterScene("main.MainScene")
  end))
  self.container:addChild(back_btn)
  
  local upData_btn = ccui.Button:create("Game/GUI/button.png")
  upData_btn:setPosition(display.cx + 150,display.cy + 250)
  upData_btn:setTitleFontSize(18)
  upData_btn:setTitleText("刷新")
  upData_btn:addTouchEventListener(widget_click_listener(function(sender)

       for k, v in pairs(package.loaded) do
           package.loaded[k] = nil
       end
       package.preload = {}
       application:enterScene("fight.FightingScene")
  end))
  self.container:addChild(upData_btn)
 
  
  self.heros = {}
  self.devils = {}
  local model = require("app.scenes.fight.FightingModel")
  local view = require("app.scenes.fight.FightingView")

  --TODO:这里的一级属性值没有赋入
  for eid = 2,DummyData.OpenSlotCount do
      local heroData = DummyData.getHero(eid)
      if DummyData.isHeroUsed(eid) then
         local pos = {x = self.bzList[eid + 5].x,y = self.bzList[eid + 5].y}
         local heroModel = model.new()
         heroModel:create(heroData.eid,heroData.id,heroData.level,heroData.enhance,pos,heroData.lv1Attr)
         local heroView = view.new(self,heroModel)
         local x = wGrid / 2 + (pos.x - 1) * wGrid
         local y = hGrid / 2 + (pos.y - 1) * hGrid
         heroView:setPosition(x,y)
         heroView:setLocalZOrder(10 - eid)
         self.container:addChild(heroView)
         local hero = {model = heroModel,view = heroView}
         table.insert(self.heros,hero)
      end
     -- CCLog("-----heroHP TEST-----" .. heroData.lv1Attr.hp)
  end
 
  self:nextScene()

  self:addChild(self.container)
  
end

function FightingLayer:nextScene() --@return typeOrObject
  local model = require("app.scenes.fight.FightingModel")
  local view = require("app.scenes.fight.FightingView")
  self.sceneOrder = self.sceneOrder + 1
  self.devils = self.devils or {}
  if #self.devils > 0 then
     for i = 1, #self.devils do
         table.remove(self.devils,i)
     end
     self.devils = {}
  end

  for i = 1,#DummyData.FuBenBaseConfig[self.sceneOrder] do
      local devilData = DummyData.getDevil(DummyData.FuBenBaseConfig[self.sceneOrder][i])
      local pos = {x = self.bzList[(i - 1) + 10].x,y = self.bzList[(i - 1) + 10].y}
      local devilModel = model.new()
      devilModel:create(DummyData.FuBenBaseConfig[1][i],devilData.id,devilData.level,devilData.enhance,pos,devilData.lv1BaseAttr)
      local devilView = view.new(self,devilModel)
      local x = wGrid / 2 + (pos.x - 1) * wGrid
      local y = hGrid / 2 + (pos.y - 1) * hGrid
      devilView:setPosition(x,y)
      devilView:setLocalZOrder(10 -i)
      self.container:addChild(devilView)
      local devil = {model = devilModel, view = devilView}
      table.insert(self.devils,devil)
     -- devilView = 
  end
  --TODO:控制模块的调用要重新修改 这里会加入推图的因素
  local controller = require("app.scenes.fight.FightingController")
  if #self.devils > 0 then
     for i = 1,#self.devils do
         controller.new(self.devils[i],self.heros)
     end
  end
  if #self.heros >0 then
     for i = 1,#self.heros do
         controller.new(self.heros[i],self.devils)
     end
  end
end


return FightingLayer