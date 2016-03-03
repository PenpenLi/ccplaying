local LootListLayer = class("LootListLayer", BaseLayer)

local bgZOrder = 2 

function LootListLayer:ctor(info)
    self.data.goodsInfo = info
    self.controls.itemTab = {}

    self:createUI()
end

function LootListLayer:createUI()
    local layerColor = cc.LayerColor:create(cc.c4b(0, 0, 0, 200), display.width, display.height)
    layerColor:setPosition(display.width/2 - layerColor:getContentSize().width / 2, 
                            display.height/2 - layerColor:getContentSize().height / 2)
    self:addChild(layerColor)

    self.controls.bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png") 
    self.controls.bg:setContentSize(cc.size(730, 590))
    self.controls.bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    self:addChild(self.controls.bg)
    self.data.size = self.controls.bg:getContentSize()
    local size = self.controls.bg:getContentSize()

    local quanBg = cc.Sprite:create("image/ui/img/btn/btn_609.png")
    quanBg:setPosition(size.width * 0.5, size.height * 0.6)
    self.controls.bg:addChild(quanBg, bgZOrder)

    local timuBg = createMixScale9Sprite("image/ui/img/bg/bg_278.png", nil, nil, cc.size(715, 75)) 
    timuBg:setTouchEnable(false)
    timuBg:setPosition(size.width * 0.5, size.height * 0.9)
    self.controls.bg:addChild(timuBg, bgZOrder)

    local timu = createMixSprite("image/ui/img/btn/btn_608.png") 
    timu:setTouchEnable(false)
    timu:setCircleFont(self.data.goodsInfo.Name, 1, 1, 25, cc.c3b(255, 215, 107))
    timu:setPosition(size.width * 0.3, size.height * 0.96)
    self.controls.bg:addChild(timu, bgZOrder)

    for i=1,4 do
        local item = require("scene.main.loot.widget.LootPlayerInfo").new({ID = 1001}, self.data.goodsInfo.ID, self.data.goodsInfo.Seat)
        item:setPosition(size.width * 0.5, size.height * 0.73 - (i - 1) * 120)
        item:setScale(0)
        self.controls.bg:addChild(item, bgZOrder)
        table.insert(self.controls.itemTab, item)
    end
    
    local update = createMixScale9Sprite("image/ui/img/btn/btn_818.png", nil, "image/ui/img/btn/btn_830.png", cc.size(170, 60)) 
    update:setChildPos(0.2, 0.5)
    update:setCircleFont("换一批", 1, 1, 25, cc.c3b(238, 205, 142))
    update:setFontPos(0.6, 0.5)
    update:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
    update:setPosition(size.width * 0.8, size.height * 0.9)
    self.controls.bg:addChild(update, bgZOrder)
    update:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:RefreshOwnerList(self.data.goodsInfo.ID, self.data.goodsInfo.Seat)
        end
    end)

    local function onTouchBegan(touch, event)
        return true
    end
    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        local startpos = target:convertToNodeSpace(touch:getStartLocation())
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if (not cc.rectContainsPoint(rect, startpos)) and (not cc.rectContainsPoint(rect, locationInNode)) then
            local parent = self:getParent()
            parent:UpdateFragList()
            self:removeFromParent()
            self = nil
        end
    end
    local listener1 = cc.EventListenerTouchOneByOne:create()
    listener1:setSwallowTouches(true)
    listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener1:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, self.controls.bg)
end

function LootListLayer:updatePlayerInfo(playerTab)
    local totalPlayer = (#playerTab)
    for i=1,4 do
        if i > totalPlayer then
            self.controls.itemTab[i]:setScale(0)
        else
            self.controls.itemTab[i]:setScale(1)
            self.controls.itemTab[i]:updateInfo(playerTab[i])
        end
    end
end

function LootListLayer:onEnter()
    self:RefreshOwnerList(self.data.goodsInfo.ID, self.data.goodsInfo.Seat)
end

function LootListLayer:onExit()

end

--[[
    刷新碎片持有者列表
]]--
function LootListLayer:RefreshOwnerList(id, seat)
    rpc:call("Loot.RefreshOwnerList", {TreasureID = id, Seat = seat}, function(event)
        if event.status == Exceptions.Nil then
            self.data.playerTabs = event.result or {}
            self:updatePlayerInfo(self.data.playerTabs)
        end
    end)
end

--[[
    抢夺
]]--
function LootListLayer:Loot(treasureID, seat, playerInfo)
    local p = {
        Enemy = playerInfo.RID,
        ID = treasureID,
        Seat = seat
    }

    rpc:call("Loot.BeforeF", p, function(event)
        if event.status == Exceptions.Nil then
            application:pushScene("form.BattleFormScene",
                GameCache.FORM_TYPE_LOOT,
                {
                    sessionID = event.result.SessionID,
                    battleType = "PVP", 
                    map = "BW_XD_map",                                
                    attackerForm = event.result.Form,
                    callback = function(data)
                        local isWin = false 
                        if data.result == "win" then
                            isWin = true
                            Common.playSound("audio/effect/map_battle_win.mp3")
                        else
                            isWin = false
                        end
                        self:SubmitLootResult(data.sessionID, isWin, playerInfo)
                    end
                }
            )
            Common.CloseSystemLayer({5})
        elseif event.status == Exceptions.ELootInProtect then
            application:showFlashNotice("对方处于免战中!")
        end
    end)
end

--[[
    抢夺五次
]]--
function LootListLayer:sweep(treasureID, seat, playerInfo)
    local p = {
        ID = treasureID,
        Seat = seat,
        Enemy = playerInfo.RID
    }
    rpc:call("Loot.Sweep", p, function(event)
        if event.status == Exceptions.Nil then
            local sweepInfo = event.result
            local box = require("scene.main.loot.widget.DrawBoxFive").new(treasureID, seat, sweepInfo)
            self:addChild(box)
        elseif event.status == Exceptions.ELootInProtect then
            application:showFlashNotice("对方处于免战中!")
        end
    end)
end

--[[
    提交战斗结果
]]
function LootListLayer:SubmitLootResult(sessionID, isWin, playerInfo)
    local p = {
        SessionID = sessionID,
        IsWin = isWin,
    }

    rpc:call("Loot.EndF", p, function(event)
        if event.status == Exceptions.Nil then
            local winInfo = event.result.WinInfo or {}
            local isGetFrag = event.result.IsGetFrag
            local info = nil

            if 0 ~= #winInfo then
                info = winInfo[1]
            else
                info = {}
                info.AtkIcon = GameCache.Avatar.Icon
                info.AtkName = GameCache.Avatar.Name
                info.AtkTFP = GameCache.Avatar.LootAtkTFP
                info.DefIcon = playerInfo.Icon
                info.DefName = playerInfo.Name
                info.DefTFP = playerInfo.TFP
                info.Seat = seat
                info.TreasureID = treasureID
            end

            if p.IsWin then
                local scene = cc.Director:getInstance():getRunningScene()
                local box = require("scene.main.loot.widget.DrawBox").new(isGetFrag, info, true)
                scene:addChild(box)
            else
                local layer = require("tool.helper.CommonLayer").BattleFailLayer(event.result)
                local btn_back = createMixSprite("image/ui/img/btn/btn_593.png")
                btn_back:setCircleFont("确定", 1, 1, 25, cc.c3b(238, 205, 142), 1)
                btn_back:setFontOutline(cc.c3b(70, 50, 14), 1)
                btn_back:setPosition(SCREEN_WIDTH * 0.85, SCREEN_HEIGHT * 0.2)
                layer:addChild(btn_back)
                btn_back:addTouchEventListener(function(sender, eventType)
                    if eventType == ccui.TouchEventType.ended then
                        application:popScene()
                        -- application:popScene()
                    end
                end)
                local scene = cc.Director:getInstance():getRunningScene()
                scene:addChild(layer)
            end
        else
            application:popScene()
            -- application:popScene()
            application:showFlashNotice("战斗结果异常~")
        end
    end, {show=false, debug=false, retryOnError = true} )
end

function LootListLayer:onEnterTransitionFinish(  )
    Common.OpenSystemLayer({5})
    LootListLayer.super.onEnterTransitionFinish(self)
    
end

return LootListLayer




