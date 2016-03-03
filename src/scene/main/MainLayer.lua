local http = require("net.http")
local AccountHelper = require("tool.helper.AccountHelper")
local libmd5 = require("md5")

local MainLayer = class("MainLayer", BaseLayer)
-- local LoadingWaitLayer = require("tool.helper.LoadingWaitLayer")
local targetPlatform = cc.Application:getInstance():getTargetPlatform()
local HeroManager = require("tool.helper.HeroAction")
local scheduler = cc.Director:getInstance():getScheduler()
local EffectManager = require("tool.helper.Effects")
local YVHANDLER = {
    ["LOGIN_HANDLER"] = 1,
    ["RECONNECT_HANDLER"] = 2,
    ["STOP_RECORDE_HANDLER"] = 3,
    ["FINISH_SPEECH_HANDLER"] = 4,
    ["FINISH_PLAY_HANDLER"] = 5,
    ["UPLOAD_FILE_HANDLER"] = 6,
    ["DOWNLOAD_FILE_HANDLER"] = 7,
    ["NETWORK_STATE_HANDLER"] = 8,
    ["RECORD_VOICE_HANDLER"] = 9,
    ["CPUSER_INFO_HANDLER"] = 10,
    ["DOWNLOAD_VOICE_HANDLER"] = 11,
    ["CHANNEL_CHAT_HANDLER"] = 12,
    ["CHANNEL_LOGIN_HANDLER"] = 13,
    ["CHANNEL_MODIFY_HANDLER"] = 14,
    ["CHANNEL_STATE_HANDLER"] = 15,
    ["CHANNEL_HISTORY_HANDLER"] = 16,
    ["FRIEND_CHAT_HANDLER"] = 17,
    ["FRIEND_STATE_HANDLER"] = 18,
}

local YV_CHANNEL_NAME = {"世界"}
local YV_WILDCARD_NAME = {}
for k,v in pairs(YV_CHANNEL_NAME) do
    YV_WILDCARD_NAME[GameCache.ServerName..v] = false
end

local Head_Texture_VIP = { "image/ui/img/bg/head.png", "image/ui/img/bg/head2.png", "image/ui/img/bg/head3.png" }

local effectAnimationZOrder = 10000
local isTouch = false

function MainLayer:ctor(isShowActivity)
    MainLayer.super.ctor(self)  
    
    self.entryText = {}
    self.heroPosition = {x=1251, y=100}
    self.bgPosition = {x=SCREEN_WIDTH*0.5-1140, y=0}
    self.isCreateOther = false
    self.othersData = {}

    self:createFixedUI()
    self:createTimer()

    self.updateTime = 30
    self.isEnterScene = false
    self.firstEnterScene = true
    self:updateFinger()

    self.eventListeners = {}
    self:addEventListeners()
    if not GameCache.isExamine then
        self.activity = isShowActivity
    else
        self.activity = false
    end
    -- if BaseConfig.targetPlatform == cc.PLATFORM_OS_IPHONE or BaseConfig.targetPlatform == cc.PLATFORM_OS_IPAD or BaseConfig.targetPlatform == cc.PLATFORM_OS_ANDROID then
    --     --todo  init chat sdk
    --     self:initChatSystem()
    -- end

    Common.stopMusic(true)
end

function MainLayer:updateFinger()
    local effectAnimation = EffectManager:CreateAnimation(self,SCREEN_WIDTH-110,70, nil, 1, true)
    effectAnimation:setVisible(false)
    effectAnimation:setLocalZOrder(effectAnimationZOrder)

    local function updateFingerGuide()
        if GameCache.Avatar.Level > 20 or GameCache.Avatar.Level < 4 then
            return
        end
        if self.isEnterScene == false then
            if self.updateTime > 0 then
                self.updateTime = self.updateTime - 1
                if self.updateTime == 0 then
                    effectAnimation:setVisible(true)
                end
            end
        else
            self.updateTime = 30
            effectAnimation:setVisible(false)       
        end
    end
    local quickGuidScheduler = scheduler:scheduleScriptFunc(updateFingerGuide, 1, false)
end

function MainLayer:createBackgroup()
    local bg = cc.ParallaxNode:create()
    local map = nil
    local scene_count = nil
    local scene_width = nil
    local scene_height = nil
    local function createMap(res)
        local image_prefix_path = "image/map/image/"
        local effect_prefix_path = "image/map/"
        if "json" == string.sub(res, -4) then
            local js = cc.FileUtils:getInstance():getStringFromFile(res)
            map = json.decode(js)
            scene_count = map.Header.sceneCount
            scene_width = map.Header.sceneSize.width
            scene_height = map.Header.sceneSize.height
            for i = 1, scene_count do
                for j = 1, #map.Body.scenes[i].regions do
                    local view = cc.Node:create()
                    view:setName(map.Body.scenes[i].regions[j].name)
                    local zorder = map.Body.scenes[i].regions[j].z
                    view:setLocalZOrder(zorder)
                    local velocity = map.Body.scenes[i].regions[j].velocity
                    if map.Body.scenes[i].regions[j].isEffect then
                        for k = 1, #map.Body.scenes[i].regions[j].components do
                            local scale = map.Body.scenes[i].regions[j].components[k].scale
                            local offx = map.Body.scenes[i].regions[j].components[k].position.x
                            local offy = map.Body.scenes[i].regions[j].components[k].position.y
                            local image = map.Body.scenes[i].regions[j].components[k].image
                            local effect = sp.SkeletonAnimation:create(effect_prefix_path..image.."/skeleton.skel",
                                                                        effect_prefix_path..image.."/skeleton.atlas",
                                                                        scale)
                            effect:setPosition(cc.p(offx, offy))
                            effect:setAnimation(0,"animation",true)
                            view:addChild(effect) 
                        end
                    else
                        for k = 1, #map.Body.scenes[i].regions[j].components do
                            local sprite = cc.Sprite:create(image_prefix_path .. map.Body.scenes[i].regions[j].components[k].image)
                            local offx = map.Body.scenes[i].regions[j].components[k].position.x
                            local offy = map.Body.scenes[i].regions[j].components[k].position.y
                            local flipx = map.Body.scenes[i].regions[j].components[k].flipX
                            local flipy = map.Body.scenes[i].regions[j].components[k].flipY
                            local scale = map.Body.scenes[i].regions[j].components[k].scale                     
                            sprite:setPosition(cc.p(offx, offy))
                            sprite:setFlippedX(flipx)
                            sprite:setFlippedY(flipy)
                            sprite:setScale(scale)
                            view:addChild(sprite)
                        end
                    end
                    bg:addChild(view, 0, cc.p(velocity, 1), cc.p(0,0))
                end
            end
        else
            map = require(res)
            scene_count = map.Header.sceneCount
            scene_width = map.Header.sceneSize.width
            scene_height = map.Header.sceneSize.height
            local layers = map.Body.scenes[1].regions
            for _,layer in pairs(layers) do
                local view = cc.Node:create()
                view:setName(layer.name)
                view:setLocalZOrder(layer.z)
                local velocity = layer.velocity
                if layer.isEffect then
                     --加载场景特效
                    for i,effect in pairs(layer.components) do
                        local scale = effect.scale
                        local offx = effect.position.x
                        local offy = effect.position.y
                        local effectAnimation = sp.SkeletonAnimation:create(effect_prefix_path..effect.image.."/skeleton.skel",
                                                    effect_prefix_path..effect.image.."/skeleton.atlas",
                                                    scale)
                        effectAnimation:setPosition(cc.p(offx, offy))
                        effectAnimation:setAnimation(0, "animation", true)
                        view:addChild(effectAnimation)
                    end
                else
                    --加载地图背景
                    for i,sprite in pairs(layer.components) do
                        local scale = sprite.scale
                        local offx = sprite.position.x
                        local offy = sprite.position.y
                        local flipx = sprite.flipX
                        local flipy = sprite.flipY
                        local sp = cc.Sprite:create(image_prefix_path..sprite.image)
                        sp:setPosition(offx, offy)
                        sp:setScale(scale)
                        sp:setFlippedX(flipx)
                        sp:setFlippedY(flipy)
                        view:addChild(sp)
                    end
                end
                bg:addChild(view, 0, cc.p(velocity, 1), cc.p(0,0))
            end
        end
    end
    --createMap("image/map/json/zhuchengxin.json")
    createMap("image/map/lua/zhuchengxin.lua")
    self.data.globalMap = map
    local bgsize = cc.size(scene_count * scene_width, scene_height)  -- 地图的宽度影响，人物的站位，和其他玩家的行走区域
    self.bgsize = bgsize
    bg:setContentSize(self.bgsize)
    self.map = bg:getChildByName("mid")

    self.controls.globalScrollview = ccui.ScrollView:create()
    self.controls.globalScrollview:setTouchEnabled(true)
    self.controls.globalScrollview:setContentSize(cc.size(SCREEN_WIDTH,SCREEN_HEIGHT))
    self.controls.globalScrollview:setDirection(ccui.ScrollViewDir.horizontal)
    self.controls.globalScrollview:setInnerContainerSize(self.bgsize)
    self:addChild(self.controls.globalScrollview)

    local scrollViewContainer = self.controls.globalScrollview:getInnerContainer()
    scrollViewContainer:addChild(bg)
    self.bg = scrollViewContainer
    self.bg:setPosition(self.bgPosition.x, self.bgPosition.y)

    self.controls.avatar_figure = HeroManager.new(self.heroPosition.x, self.heroPosition.y, GameCache.Avatar.Figure)
    self.controls.avatar_figure:setScale(0.7)
    self.map:addChild(self.controls.avatar_figure, SCREEN_HEIGHT-self.heroPosition.y)
    self.controls.avatar_figure:setTouchEnabled(false)

    local x,y = self.controls.avatar_figure:getPosition()
    self.touchPos = cc.p(x,y)
    
    local bgoffx = SCREEN_WIDTH-bgsize.width
    local leftBound = SCREEN_WIDTH * 0.5
    local rightBound = bgsize.width-SCREEN_WIDTH*0.5

    self.dirX = 1
    self.dirY = 1
    self.velocity = 4
    self.heroState = "idle"

    local isMoved = false     --标记是否是拖动操作
    local startPos = nil

    local updateMove = function (  )

        if self.heroState == "idle" then
            return
        end
 
        local playerPosX, playerPosY = self.controls.avatar_figure:getPosition()
        local mapPosX, mapPosY = self.bg:getPosition()
    
        if math.abs(playerPosX - self.touchPos.x) < 4 then
            self.heroState = "idle"
            self.controls.avatar_figure:setAnimation(0, "idle", true)
            return
        end
    
        if playerPosX < rightBound and playerPosX > leftBound then
            mapMoveX = -self.velocityX * self.dirX
            playerMoveX = self.velocityX * self.dirX
            playerMoveY = self.velocityY * self.dirY
        else
            mapMoveX = 0
            playerMoveX = self.velocityX * self.dirX
            playerMoveY = self.velocityY * self.dirY
        end   

         local x = mapPosX + mapMoveX

        if x > 0 then
            x = 0
            playerMoveX = self.velocityX * self.dirX
            playerMoveY = self.velocityY * self.dirY
        elseif x < bgoffx then
            x = bgoffx
            playerMoveX = self.velocityX * self.dirX
            playerMoveY = self.velocityY * self.dirY
        end   
        
        self.controls.avatar_figure:setPosition(playerPosX + playerMoveX, playerPosY + playerMoveY)
        self.controls.avatar_figure:setLocalZOrder(SCREEN_HEIGHT-( playerPosY + playerMoveY))

        local point = self.map:convertToWorldSpace(cc.p(playerPosX,playerPosY))
        if self.dirX > 0 then
            if point.x < SCREEN_WIDTH/2 then                   
                self.bg:setPosition(mapPosX,mapPosY)
            else
                self.bg:setPosition(x, mapPosY)
            end
        else
            if point.x > SCREEN_WIDTH/2 then
                self.bg:setPosition(mapPosX,mapPosY)
            else
                self.bg:setPosition(x, mapPosY)
            end
        end
    end
    
    self:scheduleUpdateWithPriorityLua(updateMove,0)      

    local function onTouchBegan(touch, event)
        if isTouch == false then
            startPos = touch:getLocation()
            isTouch = true
            return true
        else
            return false
        end
    end

    local function onTouchMoved(touch, event)
        local location = touch:getLocation()
        if math.abs(location.x - startPos.x) > 5 then
            isMoved = true
        end
    end

    local function onTouchEnded(touch, event)
        local playerPosX, playerPosY = self.controls.avatar_figure:getPosition()
        if isMoved == false then
            self.touchPos = self.bg:convertToNodeSpace(touch:getLocation())
            self.touchPos.x = math.floor(self.touchPos.x)
            self.touchPos.y = math.floor(self.touchPos.y)
            if self.touchPos.y < 300 and self.touchPos.y > 50 then
                local point = cc.Sprite:create("image/ui/img/btn/btn_1118.png")
                point:setPosition(self.touchPos.x, self.touchPos.y)
                self.map:addChild(point)
                point:runAction(cc.Sequence:create( 
                    cc.ScaleTo:create(0.2, 1.1), 
                    cc.Spawn:create( cc.ScaleTo:create(0.2, 1.1), cc.FadeOut:create(0.2) ), 
                    cc.RemoveSelf:create() ))
            end
        else
            self.touchPos = self.bg:convertToNodeSpace(cc.p(SCREEN_WIDTH/2, playerPosY))
            self.touchPos.x = math.floor(self.touchPos.x)
            self.touchPos.y = math.floor(self.touchPos.y)
            isMoved = false
        end

        if self.touchPos.y > 220 then
            self.touchPos.y = 220
        end

        if self.touchPos.y < 50 then
            self.touchPos.y = 50
        end
        
        local offsetX = self.touchPos.x - playerPosX
        local offsetY = self.touchPos.y - playerPosY

        local off = math.sqrt(offsetX*offsetX + offsetY*offsetY)
        local time = off/self.velocity
        self.velocityX = math.abs(offsetX/time)
        self.velocityY = math.abs(offsetY/time)

        if offsetX > 0 then
            self.controls.avatar_figure:setRotationSkewY(0)
            self.dirX = 1
        else
            self.controls.avatar_figure:setRotationSkewY(180)
            self.dirX = -1
        end

        if offsetY > 0 then
            self.dirY = 1
        else
            self.dirY = -1
        end

        if self.heroState == "idle" then
            self.heroState = "move"
            self.controls.avatar_figure:setAnimation(0, "move", true)
        end
        isTouch = false
    end

    local function onTouchCancelled()
        isTouch = false
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    -- listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchCancelled,cc.Handler.EVENT_TOUCH_CANCELLED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, bg)
end

function MainLayer:createEntry(  )

    local unused_texture = "dummy/kb.png"
    --点击效果
    local fairyBg = cc.Sprite:create("image/ui/img/bg/bg_313.png")
    fairyBg:setOpacity(60)
    fairyBg:setPosition(cc.p(478.5,404))
    self.map:addChild(fairyBg)
    fairyBg:setVisible(false)

    local apartmentBg = cc.Sprite:create("image/ui/img/bg/bg_314.png")
    apartmentBg:setOpacity(60)
    apartmentBg:setPosition(cc.p(198,414))
    self.map:addChild(apartmentBg)
    apartmentBg:setVisible(false)

    local xueyuanBg = cc.Sprite:create("image/ui/img/bg/bg_315.png")
    xueyuanBg:setOpacity(60)
    xueyuanBg:setPosition(cc.p(785.5,416))
    self.map:addChild(xueyuanBg)
    xueyuanBg:setVisible(false)

    local shopBg = cc.Sprite:create("image/ui/img/bg/bg_316.png")
    shopBg:setOpacity(60)
    shopBg:setPosition(cc.p(1133,376))
    self.map:addChild(shopBg)
    shopBg:setVisible(false)

    local coliseumBg = cc.Sprite:create("image/ui/img/bg/bg_317.png")
    coliseumBg:setOpacity(60)
    coliseumBg:setPosition(cc.p(1410.5,370))
    self.map:addChild(coliseumBg)
    coliseumBg:setVisible(false)

    local dailyBg = cc.Sprite:create("image/ui/img/bg/bg_318.png")
    dailyBg:setOpacity(60)
    dailyBg:setPosition(cc.p(2565.5,352.5))
    self.map:addChild(dailyBg)
    dailyBg:setVisible(false)

    local mailBg = cc.Sprite:create("image/ui/img/bg/bg_319.png")
    mailBg:setOpacity(60)
    mailBg:setPosition(cc.p(1180,355))
    self.map:addChild(mailBg)
    mailBg:setVisible(false)

    local rankingBg = cc.Sprite:create("image/ui/img/bg/bg_320.png")
    rankingBg:setOpacity(80)
    rankingBg:setPosition(cc.p(1654,339))
    self.map:addChild(rankingBg)
    rankingBg:setVisible(false)

    local towerBg = cc.Sprite:create("image/ui/img/bg/bg_321.png")
    towerBg:setOpacity(80)
    towerBg:setPosition(cc.p(2025,555))
    self.map:addChild(towerBg)
    towerBg:setVisible(false)

    --竞技场
    local btn_coliseum = ccui.MixButton:create(unused_texture)
    btn_coliseum:setScale9Size(cc.size(200,250))
    btn_coliseum:setPressedActionEnabled(false)
    btn_coliseum:setPosition(cc.p(1420,400))
    self.map:addChild(btn_coliseum)
    btn_coliseum:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.began then
            coliseumBg:setVisible(true) 
        end
        if eventType == ccui.TouchEventType.canceled then
            BaseConfig.isCanClick = true
            coliseumBg:setVisible(false) 
        end
        if eventType == ccui.TouchEventType.ended and BaseConfig.isCanClick then
            BaseConfig.isCanClick = false
            coliseumBg:setVisible(false) 
            Common.playSound("audio/effect/common_click_feedback.mp3")
            if GameCache.Avatar.Level < BaseConfig.OpenSystemLevel.arena then
                Common.openLevelDesc(BaseConfig.OpenSystemLevel.arena)
                BaseConfig.isCanClick = true
                return
            end
            rpc:call("Arena.Info", nil, function (event)
                if event.status == Exceptions.Nil and event.result ~= nil then
                    table.sort(event.result.List, function (a,b) return a.Rank < b.Rank end)
                    application:pushScene("main.coliseum.ColiseumScene", event.result)
                    Common.CloseSystemLayer({7})
                else
                    BaseConfig.isCanClick = true
                end
            end)
    
        end
    end)
    local coliseum_text = cc.Sprite:create("image/ui/img/btn/btn_1143.png")
    coliseum_text:setScale(1.1)
    coliseum_text:setPosition(1510,400)
    self.map:addChild(coliseum_text)
    self.entryText["arena"] = coliseum_text
    --排行榜
    local btn_ranking = ccui.MixButton:create(unused_texture)
    btn_ranking:setScale9Size(cc.size(150,150))
    btn_ranking:setPressedActionEnabled(false)
    btn_ranking:setPosition(cc.p(1720,360))
    self.map:addChild(btn_ranking)
    btn_ranking:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.began then
            rankingBg:setVisible(true) 
        end
        if eventType == ccui.TouchEventType.canceled then
            BaseConfig.isCanClick = true
            rankingBg:setVisible(false)
        end
        if eventType == ccui.TouchEventType.ended and BaseConfig.isCanClick then
            BaseConfig.isCanClick = false
            Common.playSound("audio/effect/common_click_feedback.mp3")
            rankingBg:setVisible(false)
            local layer = require("scene.main.RankList").new(1,function ()
                self.isEnterScene = false
                BaseConfig.isCanClick = true
            end)
            local scene = cc.Director:getInstance():getRunningScene()
            scene:addChild(layer)
            self.isEnterScene = true
        end
    end)
    local ranking_text = cc.Sprite:create("image/ui/img/btn/btn_1385.png")
    ranking_text:setScale(1.1)
    ranking_text:setPosition(1770,380)
    self.map:addChild(ranking_text)


    --每日副本(娱乐城)
    local btn_daily = ccui.MixButton:create(unused_texture)
    btn_daily:setScale9Size(cc.size(300,300))
    btn_daily:setPressedActionEnabled(false)
    btn_daily:setPosition(cc.p(2650,410))
    self.map:addChild(btn_daily)
    btn_daily:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            dailyBg:setVisible(true) 
        end
        if eventType == ccui.TouchEventType.canceled then
            BaseConfig.isCanClick = true
            dailyBg:setVisible(false) 
        end
        if eventType == ccui.TouchEventType.ended and BaseConfig.isCanClick then
            BaseConfig.isCanClick = false
            dailyBg:setVisible(false) 
            if GameCache.Avatar.Level < BaseConfig.OpenSystemLevel.instanceDaily then
                Common.openLevelDesc(BaseConfig.OpenSystemLevel.instanceDaily)
                BaseConfig.isCanClick = true 
                return
            end
            rpc:call("InstanceDaily.Info", nil, function(event)
                if event.status == Exceptions.Nil then
                    local info = event.result
                    application:pushScene("main.instanceDaily.InstanceDailyScene", info) 
                    Common.CloseSystemLayer({9})
                else
                    BaseConfig.isCanClick = true
                end
            end)
        end
    end)
    local daily_text = cc.Sprite:create("image/ui/img/btn/btn_1141.png")
    daily_text:setScale(1.1)
    daily_text:setPosition(2650,340)
    self.map:addChild(daily_text)   
    self.entryText["instanceDaily"] = daily_text
    --电视塔
    local btn_tower = ccui.MixButton:create(unused_texture)
    btn_tower:setScale9Size(cc.size(150,250))
    btn_tower:setPressedActionEnabled(false)
    btn_tower:setPosition(1985,460)
    self.map:addChild(btn_tower)
    btn_tower:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            towerBg:setVisible(true) 
        end
        if eventType == ccui.TouchEventType.canceled then
            BaseConfig.isCanClick = true
            towerBg:setVisible(false)
        end
        if eventType == ccui.TouchEventType.ended and BaseConfig.isCanClick then
            BaseConfig.isCanClick = false
            towerBg:setVisible(false)
            Common.playSound("audio/effect/common_click_feedback.mp3")
            if GameCache.Avatar.Level < BaseConfig.OpenSystemLevel.tower then
                Common.openLevelDesc(BaseConfig.OpenSystemLevel.tower)
                BaseConfig.isCanClick = true          
                return
            end
            rpc:call("Tower.Info", nil, function (event)
                if event.status == Exceptions.Nil and event.result ~= nil then
                    application:pushScene("main.tower.TowerScene", event.result)
                    Common.CloseSystemLayer({11})
                else
                    BaseConfig.isCanClick = true
                end
            end)
        end
    end)
    local tower_text = cc.Sprite:create("image/ui/img/btn/btn_1140.png")
    tower_text:setScale(1.1)
    tower_text:setPosition(2070,510)
    self.map:addChild(tower_text)
    self.entryText["tower"] = tower_text
    --邮箱
    local btn_mail = ccui.MixButton:create(unused_texture)
    btn_mail:setScale9Size(cc.size(100,170))
    btn_mail:setPressedActionEnabled(false)
    btn_mail:setPosition(cc.p(1260,370))
    self.map:addChild(btn_mail)
    btn_mail:addTouchEventListener(function (sender,eventType)
        if eventType == ccui.TouchEventType.began then
            mailBg:setVisible(true) 
        end
        if eventType == ccui.TouchEventType.canceled then
            BaseConfig.isCanClick = true
            mailBg:setVisible(false)
        end
        if eventType == ccui.TouchEventType.ended and BaseConfig.isCanClick then
            BaseConfig.isCanClick = false
            Common.playSound("audio/effect/common_click_feedback.mp3")
            mailBg:setVisible(false)
            rpc:call("Mail.MailList", nil, function(event)
                if event.status == Exceptions.Nil then
                    local list = event.result or {}
                    application:pushScene("main.email.EmailScene", list)
                else
                    BaseConfig.isCanClick = true        
                end
            end)
        end
    end)
    local mail_text = cc.Sprite:create("image/ui/img/btn/btn_1309.png")
    mail_text:setScale(1.1)
    mail_text:setPosition(cc.p(1275,400))
    self.map:addChild(mail_text)
    self.controls.mailAlert = cc.Sprite:create("image/ui/img/btn/btn_398.png")
    self.controls.mailAlert:setPosition(mail_text:getContentSize().width, mail_text:getContentSize().height * 0.8)
    mail_text:addChild(self.controls.mailAlert)
    self.controls.mailAlert:setVisible(false)
    if self.data.showMail then
        self.controls.mailAlert:setVisible(true)
    end 
    --取经引路人
    local skins = { ["Arm"] = 1034, 
        ["Hat"] = 1075, 
        ["Coat"] = 1067,
    }
    local btn_transport = HeroManager.new(2385,260,1009, skins)
    btn_transport:setRotationSkewY(180)
    btn_transport:setSwallowTouches(true)
    btn_transport:setScale(0.7)
    self.map:addChild(btn_transport)
    btn_transport:addTouchEvent(function ( sender, eventType )
        if eventType == ccui.TouchEventType.began then
            btn_transport:setScale(0.75)
        end
        if eventType == ccui.TouchEventType.canceled then
            BaseConfig.isCanClick = true
            btn_transport:setScale(0.7)
        end
        if eventType == ccui.TouchEventType.ended and BaseConfig.isCanClick then
            BaseConfig.isCanClick = false
            Common.playSound("audio/effect/common_click_feedback.mp3")
            btn_transport:setScale(0.7)
            if GameCache.Avatar.Level < BaseConfig.OpenSystemLevel.transport then
                Common.openLevelDesc(BaseConfig.OpenSystemLevel.transport)
                BaseConfig.isCanClick = true        
                return
            end
            application:pushScene("main.transport.TransportScene") 
            Common.CloseSystemLayer({10})  
        end
    end)
    local transport_text = cc.Sprite:create("image/ui/img/btn/btn_1145.png")
    transport_text:setScale(1.1)
    transport_text:setPosition(2415,330)
    self.map:addChild(transport_text)
    self.entryText["transport"] = transport_text


    --夺宝大师
    local skins = { ["Arm"] = 1036, 
        ["Hat"] = 0, 
        ["Coat"] = 1069,
    }
    local btn_loot = HeroManager.new(2185,280,1022, skins)
    btn_loot:setRotationSkewY(180)
    btn_loot:setSwallowTouches(true)
    btn_loot:setScale(0.7)
    self.map:addChild(btn_loot)
    btn_loot:addTouchEvent(function(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            btn_loot:setScale(0.75)
        end
        if eventType == ccui.TouchEventType.canceled then
            BaseConfig.isCanClick = true
            btn_loot:setScale(0.7)
        end
        if eventType == ccui.TouchEventType.ended and BaseConfig.isCanClick then
            Common.playSound("audio/effect/common_click_feedback.mp3")
            BaseConfig.isCanClick = false
            btn_loot:setScale(0.7)
            if GameCache.Avatar.Level < BaseConfig.OpenSystemLevel.loot then
                Common.openLevelDesc(BaseConfig.OpenSystemLevel.loot)
                BaseConfig.isCanClick = true     
                return
            end
            local treasureTabs = nil
            local winInfo = nil
            rpc:call("Loot.Init", nil, function(event)
                if event.status == Exceptions.Nil then
                    treasureTabs = event.result.FragList or {}
                    winInfo = event.result.WinInfo or {}
                    application:pushScene("main.loot.LootScene", treasureTabs, winInfo) 
                    Common.CloseSystemLayer({5})
                else
                    BaseConfig.isCanClick = true
                end
            end)    
        end
    end)
    local loot_text = cc.Sprite:create("image/ui/img/btn/btn_1144.png")
    loot_text:setScale(1.1)
    loot_text:setPosition(2225,325)
    self.map:addChild(loot_text)
    self.entryText["loot"] = loot_text


    --神仙学院
    local btn_xueyuan = ccui.MixButton:create(unused_texture)
    btn_xueyuan:setScale9Size(cc.size(250,250))
    btn_xueyuan:setPressedActionEnabled(false)
    btn_xueyuan:setPosition(785,420)
    self.map:addChild(btn_xueyuan)
    btn_xueyuan:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            xueyuanBg:setVisible(true) 
        end
        if eventType == ccui.TouchEventType.canceled then
            BaseConfig.isCanClick = true
            xueyuanBg:setVisible(false) 
        end
        if eventType == ccui.TouchEventType.ended and BaseConfig.isCanClick then
            BaseConfig.isCanClick = false
            xueyuanBg:setVisible(false) 
            Common.playSound("audio/effect/common_click_feedback.mp3")
            if GameCache.Avatar.Level < BaseConfig.OpenSystemLevel.energy then
                Common.openLevelDesc(BaseConfig.OpenSystemLevel.energy)
                BaseConfig.isCanClick = true     
                return
            end
            rpc:call("Avatar.EnergyInfo", nil, function (event)
                if event.status == Exceptions.Nil then
                    Common.playSound("audio/effect/common_click_feedback.mp3")
                    application:pushScene("main.energy.EnergyScene", event.result)
                    Common.CloseSystemLayer({4})
                else
                    BaseConfig.isCanClick = true
                end
            end)
        end
    end)
    local xueyuan_text = cc.Sprite:create("image/ui/img/btn/btn_1147.png")
    xueyuan_text:setScale(1.1)
    xueyuan_text:setPosition(900,400)
    self.map:addChild(xueyuan_text)   
    self.entryText["energy"] = xueyuan_text
    self.controls.energyAlert = cc.Sprite:create("image/ui/img/btn/btn_398.png")
    self.controls.energyAlert:setPosition(xueyuan_text:getContentSize().width, xueyuan_text:getContentSize().height * 0.9)
    xueyuan_text:addChild(self.controls.energyAlert)
    self.controls.energyAlert:setVisible(false)


    --仙女
    local btn_fairy = ccui.MixButton:create(unused_texture)
    btn_fairy:setScale9Size(cc.size(175,250))
    btn_fairy:setPressedActionEnabled(false)
    btn_fairy:setPosition(495,415)
    self.map:addChild(btn_fairy)
    btn_fairy:addTouchEventListener(function ( sender, eventType)
        if eventType == ccui.TouchEventType.began then
            fairyBg:setVisible(true)  
        end
        if eventType == ccui.TouchEventType.canceled then
            BaseConfig.isCanClick = true
            fairyBg:setVisible(false)
        end
        if eventType == ccui.TouchEventType.ended and  BaseConfig.isCanClick then
            BaseConfig.isCanClick = false
            Common.playSound("audio/effect/common_click_feedback.mp3")
            fairyBg:setVisible(false)
            if GameCache.Avatar.Level < BaseConfig.OpenSystemLevel.fairy then
                Common.openLevelDesc(BaseConfig.OpenSystemLevel.fairy)
                BaseConfig.isCanClick = true             
                return
            end
            rpc:call("Fairy.Info", {}, function(event)
                if (event.status == Exceptions.Nil) and (event.result) then
                    GameCache.AllFairy = {}
                    local result = event.result
                    local allFairy = result.FairyList or {}
                    for _, v in ipairs(allFairy) do
                        v.Name = BaseConfig.GetFairy(v.ID).Name
                    end
                    for _, v in ipairs(allFairy) do
                        GameCache.AllFairy[v.ID] = v
                    end
                    application:pushScene("main.fairy.FairyScene", result) 
                    Common.CloseSystemLayer({6})
                else
                    BaseConfig.isCanClick = true
                end
            end)
        end
    end)
    local fairy_text = cc.Sprite:create("image/ui/img/btn/btn_1146.png")
    fairy_text:setScale(1.1)
    fairy_text:setPosition(575,400)
    self.map:addChild(fairy_text)
    self.entryText["fairy"] = fairy_text


    --大咖商店
    local btn_shop = ccui.MixButton:create(unused_texture)
    btn_shop:setScale9Size(cc.size(180,250))
    btn_shop:setPressedActionEnabled(false)
    btn_shop:setPosition(cc.p(1115,430))
    self.map:addChild(btn_shop)
    btn_shop:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            shopBg:setVisible(true) 
        end
        if eventType == ccui.TouchEventType.canceled then
            BaseConfig.isCanClick = true
            shopBg:setVisible(false) 
        end
        if eventType == ccui.TouchEventType.ended  and  BaseConfig.isCanClick then
            BaseConfig.isCanClick = false
            Common.playSound("audio/effect/common_click_feedback.mp3")
            shopBg:setVisible(false)  
            local layer = require("scene.main.ExchangeMall").new(BaseConfig.MALL_TYPE_STORE, function()
                application:dispatchCustomEvent(AppEvent.UI.Home.SyncHomeData, {})
                self.isEnterScene = false
                BaseConfig.isCanClick = true
            end)
            local scene = cc.Director:getInstance():getRunningScene()
            scene:addChild(layer)
            self.isEnterScene = true
        end
    end)
    local shop_text = cc.Sprite:create("image/ui/img/btn/btn_1310.png")
    shop_text:setScale(1.1)
    shop_text:setPosition(cc.p(1050,400))
    self.map:addChild(shop_text)


    --星将公寓
    local btn_apartment = ccui.MixButton:create(unused_texture)
    btn_apartment:setScale9Size(cc.size(250,300))
    btn_apartment:setPressedActionEnabled(false)
    btn_apartment:setPosition(cc.p(220,405))
    self.map:addChild(btn_apartment)
    btn_apartment:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            apartmentBg:setVisible(true)
        end
        if eventType == ccui.TouchEventType.canceled then
            BaseConfig.isCanClick = true
            apartmentBg:setVisible(false)
        end
        if eventType == ccui.TouchEventType.ended and BaseConfig.isCanClick then
            BaseConfig.isCanClick = false
            apartmentBg:setVisible(false)
            Common.playSound("audio/effect/common_click_feedback.mp3")
            if GameCache.Avatar.Level < BaseConfig.OpenSystemLevel.apartment then
                Common.openLevelDesc(BaseConfig.OpenSystemLevel.apartment)
                BaseConfig.isCanClick = true          
                return
            end
            rpc:call("Apartment.Info", nil, function(event)
                if event.status == Exceptions.Nil and event.result ~= nil then
                    for _,house in pairs(event.result) do
                        GameCache.HeroApartmentBuff[house.ID] = 0
                        for k,v in pairs(house.Positions) do
                            if v.HeroID > 0 then
                                GameCache.GetHero(v.HeroID).ApartmentType = house.ID
                                GameCache.HeroApartmentBuff[house.ID] = GameCache.HeroApartmentBuff[house.ID] + GameCache.GetHero(v.HeroID).Score
                            end
                        end
                    end
                    application:pushScene("main.apartment.ApartmentScene", event.result)
                    Common.CloseSystemLayer({12})
                else
                    BaseConfig.isCanClick = true
                end               
            end) 
        end
    end)
    local  apartment_text = cc.Sprite:create("image/ui/img/btn/btn_1370.png")
    apartment_text:setScale(1.1)
    apartment_text:setPosition(cc.p(145,400))
    self.map:addChild(apartment_text)
    self.entryText["apartment"] = apartment_text

    application:dispatchCustomEvent(AppEvent.UI.MainLayer.updateAlert, {}) 

    if GameCache.Avatar.Level <= 40 then
        for k,v in pairs(self.entryText) do
            if GameCache.Avatar.Level < BaseConfig.OpenSystemLevel[k] then
                v:setState(1)
            else
                v:setState(0)
            end
        end
    end

    --仙盟
    local btn_league = ccui.MixButton:create(unused_texture)
    btn_league:setScale9Size(cc.size(180,200))
    btn_league:setPressedActionEnabled(false)
    btn_league:setPosition(cc.p(2280,580))
    self.map:addChild(btn_league)
    btn_league:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended  and  BaseConfig.isCanClick then
            Common.playSound("audio/effect/common_click_feedback.mp3")

            application:showFlashNotice("暂未开放~!")
        end
    end)
    local shop_league = cc.Sprite:create("image/ui/img/btn/btn_1431.png")
    shop_league:setScale(1.1)
    shop_league:setPosition(cc.p(2350,540))
    self.map:addChild(shop_league)
    shop_league:setState(1)
end

function MainLayer:createOtherPlayer( create )
    -- just refresh
    if not create then
        if BaseConfig.isShowOthers then   -- show all
            if #self.othersData == #self.otherplayers then
                return
            end
            local cellWidth = (self.bgsize.width)/(#self.othersData)
            for i=math.floor( #self.othersData/2 )+1,#self.othersData do
                local x = math.random(i*cellWidth,(i+1)*cellWidth)
                local y = math.random(200,350)
                self:createOnePerson(x, y, self.othersData[i])
            end
        else
            if math.floor( #self.othersData/2 ) == #self.otherplayers or #self.othersData <=5 then
                return
            end
            for i=#self.otherplayers , math.floor( #self.othersData/2 )+1, -1 do
                local v = self.otherplayers[i]
                scheduler:unscheduleScriptEntry(v.scheduler)
                v:removeFromParent()
                table.remove(self.otherplayers, i)
                v = nil
            end
        end
    else
        if self.updateOthersScheduler then
            scheduler:unscheduleScriptEntry(self.updateOthersScheduler)
        end
        self.otherplayers = {}
        rpc:call("Avatar.RandomRoleList", nil, function ( event )
            if event.status == Exceptions.Nil and event.result ~= nil then
                self.othersData = {}
                self.othersData = event.result
                if self.firstEnterScene and #self.othersData ~= 0 then
                    self:updateOthers()
                end
            end
        end)
    end
end

function MainLayer:createOnePerson(x, y, persondata )
    if persondata == nil then
        return
    end
    local id = persondata.Figure
    local player = HeroManager.new(x, y, id, persondata.Skin)
    player:setScale(0.7)
    player.rid = persondata.RID
    player.name = persondata.Name
    player.icon = persondata.Icon
    player:setLongPressEnabled(true)
    player:setClickEnabled(false)
    -- player:setSwallowTouches(true)
    player.state = "idle"
    player:setAnimation(0,"idle",true)
    player.movex = 0
    player.movey = 0
    player.velocityX = 0
    player.velocityY = 0
    player.dirX = 1
    player.dirY = 1
    self.map:addChild(player,SCREEN_HEIGHT-y)

    table.insert(self.otherplayers, player)
    -- player:setVisible(false)
    local boxsize = player:getBoundingBox()
    local label_name = Common.systemFont(player.name, boxsize.width*0.5, boxsize.height, 24, nil, 2)
    player:addChild(label_name)
    player:addTouchEvent(function ( sender, eventType )
        if eventType == ccui.TouchEventType.began then
            BaseConfig.isCanClick = false
            for k,v in pairs(self.otherplayers) do
                v:setTouchEnabled(false)           
            end
        end

        if eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
            for k,v in pairs(self.otherplayers) do
                v:setTouchEnabled(true)
            end
            BaseConfig.isCanClick = true
        end
    end)
    player:addLongPressEvent(function (  )
        self:createOthersPanel(player.rid, player.name, player.icon)
        for k,v in pairs(self.otherplayers) do
            v:setTouchEnabled(true)
        end
        BaseConfig.isCanClick = true
    end)

    local t = math.random(5, 20)

    player.scheduler = scheduler:scheduleScriptFunc(function (  )
        if player.state == "move" then
            return
        end

        player.movex = math.random(100,self.bgsize.width-100)   
        player.movey = math.random(80,220)

        local posx, posy = player:getPosition()

        local offsetX = player.movex - posx
        local offsetY = player.movey - posy


        local off = math.sqrt(offsetX*offsetX + offsetY*offsetY)
        local time = off/4
        player.velocityX = math.abs(offsetX/time)
        player.velocityY = math.abs(offsetY/time)
    
        if offsetX > 0 then
            player.animation:setRotationSkewY(0)
            player.dirX = 1
        else
            player.animation:setRotationSkewY(180)
            player.dirX = -1
        end
    
        if offsetY > 0 then
            player.dirY = 1
        else
            player.dirY = -1
        end

        if player.state == "idle" then
            player.state = "move"
            player:setAnimation(0, "move", true)
        end

    end, t, false)
end

function MainLayer:updateOthers()
    local personnum = 0
    if BaseConfig.isShowOthers then
        personnum = #self.othersData
    else
        if #self.othersData > 5 then
            personnum = math.floor( #self.othersData/2 )
        else
            personnum = #self.othersData
        end
    end
    local cellWidth = (self.bgsize.width - 200)/personnum
    local beginX = 100  -- 初始位置
    local startNum = 1
    local loadingPlayerNum =3
    local function updateLoadingPalyer()
        if startNum > personnum then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.updateloadingScheduler)
            return
        end
        if loadingPlayerNum >= personnum then
            loadingPlayerNum = personnum
        end
        for i=startNum, loadingPlayerNum do
            local x = math.random(beginX,cellWidth*i)
            local y = math.random(80,220)
            self:createOnePerson(x, y, self.othersData[i])
            -- 更新初始位置
            beginX = beginX + cellWidth
        end
        startNum = startNum + 3
        loadingPlayerNum = loadingPlayerNum + 3
    end
    self.updateloadingScheduler = scheduler:scheduleScriptFunc(updateLoadingPalyer, 2, false)

    local updatePlayerMove = function (  )
        for k,v in pairs(self.otherplayers) do
            if v.state == "move" then
                local posx, posy = v:getPosition()                
                if math.abs(posx - v.movex) < 4 then
                    v.state = "idle"
                    v:setAnimation(0, "idle", true)
                    return
                end                
                local dx = v.velocityX * v.dirX
                local dy = v.velocityY * v.dirY                
                v:setPosition(posx+dx, posy+dy)
                v:setLocalZOrder(SCREEN_HEIGHT-(posy+dy))
            end  
        end
    end              
    self.updateOthersScheduler = scheduler:scheduleScriptFunc(updatePlayerMove, 0, false)
end

function MainLayer:createFixedUI(  )

    local unused_texture = "dummy/kb.png"
    local layer = cc.Layer:create()
    self:addChild(layer, 2)
    local sp = cc.Sprite:create("image/icon/border/head_bg.png")
    sp:setPosition(70, SCREEN_HEIGHT-70)
    layer:addChild(sp)

    local icon = ccui.MixButton:create(Common.heroIconImgPath(GameCache.Avatar.Icon))
    icon:setPressedActionEnabled(false)
    icon:setPosition(71, SCREEN_HEIGHT-70)
    layer:addChild(icon)
    icon:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            self:showAvatarInfo()
        end
    end)
    self.controls.avatar_icon1 = icon

    local head_panel = cc.Sprite:create()
    head_panel:setPosition(64, SCREEN_HEIGHT-85)
    layer:addChild(head_panel)

    if GameCache.Avatar.VIP < 15 then
        head_panel:setTexture(Head_Texture_VIP[math.floor(GameCache.Avatar.VIP/5)+1])
    else
        head_panel:setTexture("image/ui/img/bg/head4.png")
    end

    self.controls.avatar_head = head_panel
    
    --name
    local str = GameCache.Avatar.Name
    local name = Common.systemFont(str, 1, 1, 18)
    name:setPosition(66,20)
    head_panel:addChild(name)
    self.controls.avatar_name = name

    --level
    local str = GameCache.Avatar.Level
    local level = Common.finalFont(str, 1, 1, 20, nil, 1)
    level:setPosition(25,47)
    head_panel:addChild(level)
    self.controls.avatar_level = level

    --vip level
    local sprite_vip = cc.Sprite:create("image/ui/img/btn/btn_1139.png")
    sprite_vip:setPosition(57,130)
    head_panel:addChild(sprite_vip)

    local str = GameCache.Avatar.VIP
    local viplevel = Common.finalFont(""..str, 1, 1, 20, cc.c3b(255,201,60),1)
    viplevel:setPosition(90,130)
    head_panel:addChild(viplevel)
    self.controls.avatar_viplevel = viplevel

    local pay = require("scene.main.PayListNode").new(GameCache.Avatar.PhyPower, GameCache.Avatar.MaxPhyPower,
        GameCache.Avatar.Endurance, GameCache.Avatar.MaxEndurance,
        GameCache.Avatar.Coin, GameCache.Avatar.Gold)
    pay:setPosition(SCREEN_WIDTH*0.15, SCREEN_HEIGHT - 60)
    layer:addChild(pay)
    self.pay = pay

    -- 创建聊天界面
    local btn_chatsys = ccui.MixButton:create("image/ui/img/btn/btn_1375.png")
    btn_chatsys:setAnchorPoint(0,0)
    btn_chatsys:setPosition(0, 0)
    layer:addChild(btn_chatsys)
    btn_chatsys:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended and BaseConfig.isCanClick then
            if  self.controls.chatLayer then
                self.controls.chatLayer:setVisible(true)
                if self.controls.chatLayer.listener then
                    self.controls.chatLayer.listener:setSwallowTouches(true)
                end
            else
                -- 创建聊天界面
                 local chatLayer = require("scene.main.ChatLayer").new(function()
                    self.isEnterScene = false
                 end)
                layer:addChild(chatLayer, 5)
                self.controls.chatLayer = chatLayer
            end
            self.isEnterScene = true
        end
    end)

    --公告
    local btn_notice = createMixSprite("image/ui/img/btn/btn_1379.png")
    btn_notice:setScale(0.8)
    btn_notice:setSwallowTouches(true)
    btn_notice:setPosition(cc.p(55,380))
    layer:addChild(btn_notice)
    btn_notice:addTouchEventListener(function(sender, eventType)
        if (eventType == ccui.TouchEventType.ended) and (BaseConfig.isCanClick) then
            self:createNoticePanel()
        end
    end)
    local notice_text = cc.Sprite:create("image/ui/img/btn/btn_1380.png")
    notice_text:setPosition(cc.p(btn_notice:getContentSize().width/2,352))
    layer:addChild(notice_text)
    --家园
    local btn_jiayuan = ccui.MixButton:create("image/ui/img/btn/btn_1131.png")
    btn_jiayuan:setPosition(SCREEN_WIDTH-270,70)
    layer:addChild(btn_jiayuan)
    btn_jiayuan:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended and BaseConfig.isCanClick then
            BaseConfig.isCanClick = false
            Common.playSound("audio/effect/common_click_feedback.mp3")
            -- 家园
            if GameCache.Avatar.Level < BaseConfig.OpenSystemLevel.home then
                Common.openLevelDesc(BaseConfig.OpenSystemLevel.home)
                BaseConfig.isCanClick = true
                return
            end
            rpc:call("Home.Info", nil, function (event)
                if event.status == Exceptions.Nil and event.result ~= nil then
                    local homeInfo = event.result
                    application:pushScene("main.home.HomeScene", homeInfo, true, GameCache.Avatar) 
                    Common.CloseSystemLayer({8})
                else
                    BaseConfig.isCanClick = true
                end
            end) 
        end
    end)
    if GameCache.Avatar.Level < BaseConfig.OpenSystemLevel.home then
        btn_jiayuan:setVisible(false)
    end
    self.btn_jiayuan = btn_jiayuan
    self.controls.homeAlert = cc.Sprite:create("image/ui/img/btn/btn_398.png")
    self.controls.homeAlert:setPosition(btn_jiayuan:getContentSize().width * 0.8, btn_jiayuan:getContentSize().height * 0.8)
    btn_jiayuan:addChild(self.controls.homeAlert)
    self.controls.homeAlert:setVisible(false)
    -- 冒险剧场
    local quick_mapinstance = ccui.MixButton:create(unused_texture)
    quick_mapinstance:setScale9Size(cc.size(150,140))
    quick_mapinstance:setPressedActionEnabled(false)
    quick_mapinstance:setPosition(cc.p(SCREEN_WIDTH-110,70))
    quick_mapinstance:setScale(1.2)
    layer:addChild(quick_mapinstance)
    quick_mapinstance:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended and BaseConfig.isCanClick then
            BaseConfig.isCanClick = false
            Common.playSound("audio/effect/common_click_feedback.mp3")
            application:pushScene("main.mapinstance.MapInstanceScene")
            Common.CloseGuideLayer({1,2,3,8})
        end
    end)    
    EffectManager:CreateAnimation(layer,SCREEN_WIDTH-110,70, nil, 47, true)

    --顶部条
    local topPanel = cc.Node:create()
    topPanel:setContentSize(cc.size(530,90))
    topPanel:setPosition(cc.p(SCREEN_WIDTH*0.15,SCREEN_HEIGHT-65))
    topPanel:setAnchorPoint(0,1)
    layer:addChild(topPanel)
    local topPanelSize = topPanel:getContentSize()
    --灵石
    local btn_box = ccui.MixButton:create("image/ui/img/btn/btn_972.png")
    btn_box:setPosition(topPanelSize.width*0.05, topPanelSize.height*0.55)
    topPanel:addChild(btn_box)
    self.controls.btn_box = btn_box
    btn_box:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended and BaseConfig.isCanClick then
            BaseConfig.isCanClick = false
            Common.playSound("audio/effect/common_click_feedback.mp3")
            if GameCache.Avatar.Level < BaseConfig.OpenSystemLevel.gamble then
                Common.openLevelDesc(BaseConfig.OpenSystemLevel.gamble)
                BaseConfig.isCanClick = true
                return
            end
            rpc:call("Gamble.GetGambleInfo", nil, function(event)
               if event.status == Exceptions.Nil and event.result ~= nil then                    
                    local value = event.result
                    self.data.infoTab = {}
                    self.data.allInfo = {}
                    self.data.infoTab[1] = self.data.allInfo
                    self.data.vipInfo = {}
                    self.data.infoTab[2] = self.data.vipInfo
                    self.data.heroInfo = {}
                    self.data.infoTab[3] = self.data.heroInfo
                    self.data.equipInfo = {}
                    self.data.infoTab[4] = self.data.equipInfo

                    self.data.allInfo.AllBuyFreeCount = value.AllBuyFreeCount
                    self.data.allInfo.AllTotalFreeCount = value.AllTotalFreeCount
                    self.data.allInfo.AllNextFreeTime = value.AllNextFreeTime
                    self.data.allInfo.AllBuyCost = value.AllBuyCost
    
                    self.data.vipInfo.VipWeekHot = value.VipWeekHot
                    self.data.vipInfo.VipDailyHot = value.VipDailyHot
                    self.data.vipInfo.VipBuyCost = value.VipBuyCost
    
                    self.data.heroInfo.HeroNextFreeTime = value.HeroNextFreeTime
                    self.data.heroInfo.HeroBuyCost = value.HeroBuyCost
    
                    self.data.equipInfo.EquipNextFreeTime = value.EquipNextFreeTime
                    self.data.equipInfo.EquipBuyCost = value.EquipBuyCost

                    application:pushScene("main.gamble.GambleScene", self.data.infoTab) 
                    Common.CloseGuideLayer({4,5})
                else
                    BaseConfig.isCanClick = true
                end
            end)
        end
    end)
    local x,y = btn_box:getPosition()
    boxlabel = cc.Sprite:create("image/ui/img/bg/lingshi.png")
    boxlabel:setPosition(cc.p(btn_box:getContentSize().width * 0.5, 5))
    btn_box:addChild(boxlabel)
    self.controls.gambleAlert = cc.Sprite:create("image/ui/img/btn/btn_398.png")
    self.controls.gambleAlert:setPosition(btn_box:getContentSize().width * 0.8, btn_box:getContentSize().height * 0.8)
    btn_box:addChild(self.controls.gambleAlert)
    self.controls.gambleAlert:setVisible(false)
    --活动中心
    if not GameCache.isExamine then
        local btn_huodong = ccui.MixButton:create("image/ui/img/btn/btn_1384.png")
        btn_huodong:setPosition(topPanelSize.width*0.25, topPanelSize.height*0.55)
        topPanel:addChild(btn_huodong)
        local x,y = btn_huodong:getPosition()
        local hudonglabel = cc.Sprite:create("image/ui/img/bg/huodong.png")
        hudonglabel:setPosition(cc.p(btn_huodong:getContentSize().width*0.5, 5))
        btn_huodong:addChild(hudonglabel) 
        self.controls.activityAlert = cc.Sprite:create("image/ui/img/btn/btn_398.png")
        self.controls.activityAlert:setPosition(btn_huodong:getContentSize().width * 0.8, btn_huodong:getContentSize().height * 0.8)
        btn_huodong:addChild(self.controls.activityAlert)    
        self.controls.activityAlert:setVisible(false)
        btn_huodong:addTouchEventListener(function(sender, eventType)
            if (eventType == ccui.TouchEventType.ended) and (BaseConfig.isCanClick) then
                BaseConfig.isCanClick = false
                local isOpenActivity = self:createActivityScene()
                if not isOpenActivity then
                    BaseConfig.isCanClick = true
                end
            end
        end)
    end
    --日常任务
    local btn_task = ccui.MixButton:create("image/ui/img/btn/btn_068.png")
    btn_task:setPosition(topPanelSize.width*0.45, topPanelSize.height*0.55)
    topPanel:addChild(btn_task)
    btn_task:addTouchEventListener(function(sender, eventType)
        if (eventType == ccui.TouchEventType.ended) and (BaseConfig.isCanClick) then
            BaseConfig.isCanClick = false
            if GameCache.Avatar.Level < BaseConfig.OpenSystemLevel.task then
                Common.openLevelDesc(BaseConfig.OpenSystemLevel.task)
                BaseConfig.isCanClick = true
                return
            end
            local taskInfoTabs = nil
            local achievementInfoTabs = nil
            rpc:call("Game.GetMultiSysInfo", {"Task", "Achievement"}, function(event)
                if event.status == Exceptions.Nil and event.result ~= nil then
                    taskInfoTabs = event.result.Task
                    achievementInfoTabs = event.result.Achievement
                    application:pushScene("main.task.TaskScene", taskInfoTabs, achievementInfoTabs) 
                    Common.CloseSystemLayer({3})
                else
                    BaseConfig.isCanClick = true
                end
            end)
        end
    end)
    self.controls.taskAlert = cc.Sprite:create("image/ui/img/btn/btn_398.png")
    self.controls.taskAlert:setPosition(btn_task:getContentSize().width * 0.8, btn_task:getContentSize().height * 0.8)
    btn_task:addChild(self.controls.taskAlert)    
    self.controls.taskAlert:setVisible(false)
    local tasklabel = cc.Sprite:create("image/ui/img/bg/renwu.png")
    tasklabel:setPosition(cc.p(btn_task:getContentSize().width*0.5,5))
    btn_task:addChild(tasklabel)
    --首冲礼包   
    if GameCache.PurchaseGiftStatus ~= 2 and not GameCache.isExamine then 
        local btn_gift = ccui.MixButton:create(unused_texture)
        btn_gift:setScale9Size(cc.size(80,67))
        btn_gift:setPosition(cc.p(topPanelSize.width*0.65, topPanelSize.height*0.55))
        topPanel:addChild(btn_gift)
        local giftEffect = EffectManager:CreateAnimation(btn_gift,40, 30, nil, 50, true)
        self.controls.giftEffect = giftEffect
        local giftlabel = cc.Sprite:create("image/ui/img/bg/shouchong.png")
        giftlabel:setPosition(cc.p(btn_gift:getContentSize().width*0.5, 5))
        btn_gift:addChild(giftlabel)
        btn_gift:addTouchEventListener(function(sender, eventType)
            if (eventType == ccui.TouchEventType.ended) and (BaseConfig.isCanClick) then

                local layer = require("scene.main.firstGift.FirstGift").new(function()
                    btn_gift:setVisible(false)
                    giftEffect:setVisible(false)
                    giftlabel:setVisible(false)
                end)
                local scene = cc.Director:getInstance():getRunningScene()
                scene:addChild(layer)

            end
        end)
    end

    --右边栏
    local panel = cc.Sprite:create("image/ui/img/bg/bg_312.png")
    panel:setAnchorPoint(1,1)
    panel:setPosition(cc.p(SCREEN_WIDTH,SCREEN_HEIGHT))
    layer:addChild(panel)
    local panelSize = panel:getContentSize()
    local btn_panel = ccui.MixButton:create("image/ui/img/btn/btn_1374.png")
    btn_panel:setAnchorPoint(0.5,0.5)
    btn_panel:setPosition(cc.p(30,panelSize.height*0.4+17))
    btn_panel:setRotationSkewY(180)
    panel:addChild(btn_panel,0)
    self.controls.panelAlert = cc.Sprite:create("image/ui/img/btn/btn_398.png")
    self.controls.panelAlert:setPosition(cc.p(2,panelSize.height*0.4+35))
    panel:addChild(self.controls.panelAlert)
    self.controls.panelAlert:setVisible(false)

    self.switch = false  -- 打开状态
    local isclick = true  -- 防止连续点击
    btn_panel:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended and isclick then
            isclick = false
            if not self.switch then
                panel:runAction(cc.Sequence:create(cc.MoveBy:create(0.1,cc.p(panelSize.width-40,0)),cc.MoveBy:create(0.1,cc.p(-20,0)),
                    cc.MoveBy:create(0.1,cc.p(10,0)),cc.CallFunc:create(function()
                           isclick = true 
                           btn_panel:setRotationSkewY(0)
                    end)))
                self.switch = true
                
            else
                panel:runAction(cc.Sequence:create(cc.MoveBy:create(0.2,cc.p(-(panelSize.width-50),0)),cc.CallFunc:create(function()
                            isclick = true
                            btn_panel:setRotationSkewY(180)
                    end)))
                self.switch = false
                
            end
        end
    end)

    --星将
    local btn_hero = ccui.MixButton:create("image/ui/img/btn/btn_071.png")
    btn_hero:setPosition(panelSize.width*0.7, panelSize.height*0.9)
    panel:addChild(btn_hero)
    btn_hero:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if BaseConfig.isCanClick then
                BaseConfig.isCanClick = false
                application:pushScene("main.hero.AllHeroScene")
                Common.CloseGuideLayer({6,7})
                Common.CloseSystemLayer({2})

                if self.controls.heroAlert then
                    self.controls.heroAlert:removeFromParent()
                    self.controls.heroAlert = nil
                end
            end
        end
    end)
    local x,y = btn_hero:getPosition()
    herolabel = cc.Sprite:create("image/ui/img/bg/hero.png")
    herolabel:setPosition(cc.p(x, y-30))
    panel:addChild(herolabel)    
    self.controls.heroAlert = cc.Sprite:create("image/ui/img/btn/btn_398.png")
    self.controls.heroAlert:setPosition(btn_hero:getContentSize().width * 0.8, btn_hero:getContentSize().height * 0.8)
    btn_hero:addChild(self.controls.heroAlert)
    self.controls.heroAlert:setVisible(false)
    --强化
    local btn_embattle = ccui.MixButton:create("image/ui/img/btn/btn_269.png")
    btn_embattle:setPosition(panelSize.width*0.7, panelSize.height*0.7)
    panel:addChild(btn_embattle)
    btn_embattle:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            local allHero = GameCache.GetAllHero()
            local isHaveEquip = false
            for k,v in pairs(allHero) do
                for i=1,6 do
                    local equipInfo = v.Equip[i]
                    if equipInfo.ID ~= 0 then
                        isHaveEquip = true
                        break
                    end
                end
                if isHaveEquip then
                    break
                end
            end   
            if isHaveEquip then
                if BaseConfig.isCanClick then
                    BaseConfig.isCanClick = false
                    application:pushScene("main.hero.EquipIntensifyScene")
                end
            else
                application:showFlashNotice("没有星将穿戴有装备～！")
            end
        end
    end)
    local x,y = btn_embattle:getPosition()
    local embattlelabel = cc.Sprite:create("image/ui/img/bg/qianghua.png")
    embattlelabel:setPosition(cc.p(x, y-30))
    panel:addChild(embattlelabel)
    --装备炉
    local btn_equipRecycle = ccui.MixButton:create("image/ui/img/btn/btn_073.png")
    btn_equipRecycle:setPosition(panelSize.width*0.7, panelSize.height*0.5)
    panel:addChild(btn_equipRecycle)
    btn_equipRecycle:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            if BaseConfig.isCanClick then
                BaseConfig.isCanClick = false
                application:pushScene("main.equipRecycle.EquipRecycleScene")
            end
        end
    end)
    local x,y = btn_equipRecycle:getPosition()
    local equiplabel = cc.Sprite:create("image/ui/img/bg/zblu.png")
    equiplabel:setPosition(cc.p(x, y-30))
    panel:addChild(equiplabel) 
    --包裹
    local btn_package = ccui.MixButton:create("image/ui/img/btn/btn_043.png")
    btn_package:setPosition(panelSize.width*0.7, panelSize.height*0.3)
    panel:addChild(btn_package)
    btn_package:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then

            if (0 == GameCache.getPropsTotal()) and ( 0 == GameCache.getFragTotal()) and (0 == GameCache.GetEquipTotal()) then
                application:showFlashNotice("包裹空空，不要看了")
                return
            end
    
            if BaseConfig.isCanClick then
                if self.controls.packageAlert then
                    self.controls.packageAlert:removeFromParent()
                    self.controls.packageAlert = nil
                end

                BaseConfig.isCanClick = false
                application:pushScene("main.package.PackageScene")
            end
        end
    end)
    local x,y = btn_package:getPosition()
    local packagelabel = cc.Sprite:create("image/ui/img/bg/bag.png")
    packagelabel:setPosition(cc.p(x, y-30))
    panel:addChild(packagelabel)
    self.controls.packageAlert = cc.Sprite:create("image/ui/img/btn/btn_398.png")
    self.controls.packageAlert:setPosition(btn_package:getContentSize().width * 0.8, btn_package:getContentSize().height * 0.8)
    btn_package:addChild(self.controls.packageAlert)
    self.controls.packageAlert:setVisible(false)
    --仙友
    local btn_friends = ccui.MixButton:create("image/ui/img/btn/btn_077.png")
    btn_friends:setPosition(cc.p(panelSize.width*0.7,panelSize.height*0.1))
    panel:addChild(btn_friends)
    btn_friends:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if BaseConfig.isCanClick then
                BaseConfig.isCanClick = false
                application:pushScene("main.friend.FriendScene")
            end
        end
    end)
    local x,y = btn_friends:getPosition()
    local friendlabel = cc.Sprite:create("image/ui/img/bg/friend.png")
    friendlabel:setPosition(cc.p(x, y-30))
    panel:addChild(friendlabel)  
    self.controls.friendsAlert = cc.Sprite:create("image/ui/img/btn/btn_398.png")
    self.controls.friendsAlert:setPosition(btn_friends:getContentSize().width * 0.8, btn_friends:getContentSize().height * 0.8)
    btn_friends:addChild(self.controls.friendsAlert)    
    self.controls.friendsAlert:setVisible(false)

    local function updatePanelAlert()
        local friendsAlertVisiable = self.controls.friendsAlert:isVisible()
        if friendsAlertVisiable  then
            self.controls.panelAlert:setVisible(true)
        else
            self.controls.panelAlert:setVisible(false)
        end
        if not self.switch then
            self.controls.panelAlert:setVisible(false)
        end
    end
    local panelScheduler = scheduler:scheduleScriptFunc(updatePanelAlert, 0.1, false)

    -- 底部经验条
    local expSprite = cc.Sprite:create("image/ui/img/btn/btn_671.png")
    expSprite:setAnchorPoint(0,0)
    expSprite:setScale(0.5)
    expSprite:setPosition(3, -3)
    layer:addChild(expSprite)

    local exp = GameCache.Avatar.Exp
    local maxexp = BaseConfig.GetRoleExp(GameCache.Avatar.Level)
    local back = ccui.ImageView:create("image/ui/img/bg/bg_014.png")
    back:setScale9Enabled(true)
    back:setContentSize(cc.size(SCREEN_WIDTH-35,20))
    back:setScaleY(0.5)
    back:setAnchorPoint(1,0)
    back:setPosition(SCREEN_WIDTH, 0)
    layer:addChild(back)

    local color = cc.c4f(1,1,1,1)
    local avgLength = (SCREEN_WIDTH-35)/10
    local beginLength = avgLength
    while beginLength < SCREEN_WIDTH-35 do
        local line = cc.Sprite:create("image/ui/img/btn/btn_001.png")
        line:setPosition(cc.p(SCREEN_WIDTH - beginLength-35,0))
        line:setScaleX(1)
        line:setScaleY(3.6)
        back:addChild(line,1)
        beginLength = beginLength + avgLength
    end

    local expbar = ccui.ImageView:create("image/ui/img/bg/line_04.png")
    expbar:setScale9Enabled(true)
    expbar:setContentSize(cc.size(SCREEN_WIDTH-35,18))
    expbar:setAnchorPoint(0,0)
    expbar:setPosition(0, 0)
    expbar:setScaleX(exp / maxexp)
    self.expbar = expbar
    back:addChild(expbar)

    local exp_label = Common.finalFont(exp.."/".. maxexp, 50, 5, 12, nil, 1)
    exp_label:setAnchorPoint(0,0.5)
    layer:addChild(exp_label)
    self.exp_label = exp_label
end

function MainLayer:createNoticePanel()
    local function getFileContent(path)
        local f = io.open(path, "rb")
        if f then
            local data = f:read("*all")
            f:close()
            return data
        else
            return nil
        end
    end

    local lpath = require("tool.lib.path")
    local lmd5 = require("md5")

    local fileUtils = cc.FileUtils:getInstance()
    local noticeFilePath = lpath.join(fileUtils:getWritablePath(), "notice.lua")
    local fileContent = getFileContent(noticeFilePath)

    xpcall(
        function() 

            setfenv(assert(loadstring(fileContent)), getfenv())(self)
        end, 
        function(errmsg)
            print("show notice fail:", errmsg)
        end
    ) 
end

function MainLayer:createActivityScene()
    local activityDailyCheckInfo = nil
    local activityAccCheckInfo = nil
    local activityInfo = nil
    rpc:call("Game.GetMultiSysInfo", {"DailyCheck", "AccCheck", "ActivityInfo"}, function(event)
        if event.status == Exceptions.Nil and event.result ~= nil then
            activityDailyCheckInfo = event.result.DailyCheck
            activityAccCheckInfo = event.result.AccCheck 
            activityInfo = event.result.ActivityInfo 
            application:pushScene("main.activity.ActivityCenterScene", activityDailyCheckInfo, activityAccCheckInfo, activityInfo)
            return true 
        else
            CCLog("活动中心请求失败！")
            return false     
        end
    end)
end

function MainLayer:createTimer(  )
    if self.scheduler_power_timer ~= nil then
        scheduler:unscheduleScriptEntry(self.scheduler_power_timer)
    end
    self.scheduler_power_timer = scheduler:scheduleScriptFunc(function (  )
        if self.controls.label_power_recover then
            if GameCache.Avatar.PhyPower >= GameCache.Avatar.MaxPhyPower then
                self.controls.label_power_recover:setString("回复已满")
            else
                local str_time = Common.timeFormat(GameCache.Avatar.PowerCD)
                self.controls.label_power_recover:setString(str_time)
            end
        end
        GameCache.Avatar.PowerCD = GameCache.Avatar.PowerCD - 1
        if GameCache.Avatar.PowerCD <= 0 then 
            GameCache.Avatar.PowerCD = 300
            if GameCache.Avatar.PhyPower < GameCache.Avatar.MaxPhyPower then
                GameCache.Avatar.PhyPower = GameCache.Avatar.PhyPower+1
                self.pay:setPower(GameCache.Avatar.PhyPower, GameCache.Avatar.MaxPhyPower)      
                if self.infopanel_power ~= nil then
                    self.infopanel_power:setString(GameCache.Avatar.PhyPower .. "/" .. GameCache.Avatar.MaxPhyPower)
                end                
            end
        end
    end, 1, false)

    if self.scheduler_endurance_timer ~= nil then
        scheduler:unscheduleScriptEntry(self.scheduler_endurance_timer)
    end
    self.scheduler_endurance_timer = scheduler:scheduleScriptFunc(function (  )
        if self.controls.label_endurance_recover then
            if GameCache.Avatar.Endurance >= GameCache.Avatar.MaxEndurance then
                self.controls.label_endurance_recover:setString("回复已满")
            else
                local str_time = Common.timeFormat(GameCache.Avatar.EnduranceCD)
                self.controls.label_endurance_recover:setString(str_time)
            end
        end
        GameCache.Avatar.EnduranceCD = GameCache.Avatar.EnduranceCD - 1
        if GameCache.Avatar.EnduranceCD <= 0 then
            GameCache.Avatar.EnduranceCD = 1800
            if GameCache.Avatar.Endurance < GameCache.Avatar.MaxEndurance then
                GameCache.Avatar.Endurance = GameCache.Avatar.Endurance+1
                self.pay:setEndurance(GameCache.Avatar.Endurance, GameCache.Avatar.MaxEndurance)
                if self.infopanel_endurance ~= nil then
                    self.infopanel_endurance:setString(GameCache.Avatar.Endurance .. "/" .. GameCache.Avatar.MaxEndurance)
                end

            end
        end
    end, 1, false)       

    if GameCache.Avatar.Level < 40 then
        local listener = application:addEventListener(AppEvent.UI.MainLayer.OpenSystem, function ( event )
            local entry = event.data.system
            local entry_level = event.data.level

            if entry_level == BaseConfig.OpenSystemLevel.gamble or 
                entry_level == BaseConfig.OpenSystemLevel.heroSkill or
                 entry_level == BaseConfig.OpenSystemLevel.task then
                return
            end

            if entry_level == BaseConfig.OpenSystemLevel.home then  --家园
                self.btn_jiayuan:setVisible(true)
                return
            end
            local opensysconfig = require("scene.guide.OpenSysConfig")
            local data = opensysconfig[entry]

            self.heroPosition = cc.p(data.personx, data.persony)
            self.bgPosition = cc.p(data.mapx, data.mapy)

        end)
    end

end

function MainLayer:initChatSystem(  )
    local yvtool = yv.YVTool:getInstance()
    yvtool:initSDK(CHAT_SERVER_APPID, cc.FileUtils:getInstance():getWritablePath(), CHAT_SERVER_DEBUG)
    
    self.yvsdkScheduler = scheduler:scheduleScriptFunc(function ( dt )
        yvtool:dispatchMsg(dt)
    end, 0, false)

    yvtool:registerYvListenerHandler(function ( response )
        if response.result > 0 then
            yvtool:cpLogin(GameCache.Avatar.Name, GameCache.Avatar.RID, GameCache.ServerName.."世界", "1")
            return
        end
        self:initChatLayer()
    end, YVHANDLER.LOGIN_HANDLER)

    yvtool:registerYvListenerHandler(function ( response )
        if response.result > 0 then
           return 
        end

        if not YV_WILDCARD_NAME[response.wildCard] then
            YV_WILDCARD_NAME[response.wildCard] = true
            yvtool:getChannalHistoryData(response.wildCard, 0, 5)
        end
        
    end, YVHANDLER.CHANNEL_LOGIN_HANDLER)

    yvtool:registerYvListenerHandler(function ( response )
        if response.result > 0 or response.userid == 0 then
            application:showFlashNotice("对方没有开通聊天服务!")
            return
        end
        self:showChatLayer(response.userid, response.nickName)
    end, YVHANDLER.CPUSER_INFO_HANDLER)

    yvtool:cpLogin(GameCache.Avatar.Name, GameCache.Avatar.RID, GameCache.ServerName.."世界", "1")     
end

function MainLayer:initChatLayer( )

    local yvtool = yv.YVTool:getInstance()
    local voice_text = ""
    local currChatname = ""
    local currChatID = nil
    local chatable = true
    local timer = nil

    local unused_texture = "dummy/kb.png"

    local layerColor = cc.LayerColor:create(cc.c4b(0,0,0,150))
    layerColor:setPosition(-SCREEN_WIDTH,0)
    local scene = cc.Director:getInstance():getRunningScene()
    scene:addChild(layerColor)
    layerColor:setVisible(false)
    self.chatlayer = layerColor


    local function onTouchBegan(touch, event)
        local target = event:getCurrentTarget()
        
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if cc.rectContainsPoint(rect, locationInNode) then

            return true

        end 
        -- return true

    end

    local function onTouchEnded(touch, event)
        -- local target = event:getCurrentTarget()
        
        -- local locationInNode = target:convertToNodeSpace(touch:getLocation())
        -- local s = target:getContentSize()
        -- local rect = cc.rect(0, 0, s.width, s.height)
        
        -- if not cc.rectContainsPoint(rect, locationInNode) then

        --     layerColor:setVisible(false)

        -- end 
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layerColor)

    local bgsize = cc.size(775,490)
    local bg = ccui.ImageView:create("image/ui/img/bg/bg_111.png")
    bg:setPosition(SCREEN_WIDTH*0.5, 55)
    bg:setAnchorPoint(0.5,0)
    bg:setScale9Enabled(true)
    bg:setContentSize(bgsize)
    layerColor:addChild(bg)

    local light = cc.Sprite:create("image/ui/img/bg/bg_112.png")
    light:setAnchorPoint(0,1)
    light:setScale(0.8)
    light:setPosition(5, bgsize.height-2)
    bg:addChild(light)


    light = cc.Sprite:create("image/ui/img/bg/bg_113.png")
    light:setAnchorPoint(0,1)
    light:setScale(0.8)
    light:setPosition(5, bgsize.height-2)
    bg:addChild(light)

    local contentsize = cc.size(745,420)
    local contentbg = ccui.ImageView:create("image/ui/img/bg/bg_139.png")
    contentbg:setScale9Enabled(true)
    contentbg:setContentSize(contentsize)
    contentbg:setAnchorPoint(0.5,0)
    contentbg:setPosition(bgsize.width*0.5, 10)
    bg:addChild(contentbg)

    local btn_close = createMixSprite("image/ui/img/btn/btn_598.png")
    btn_close:setPosition(bgsize.width-5, bgsize.height-5)
    btn_close:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            layerColor:stopAllActions()
            layerColor:runAction(cc.Sequence:create(cc.MoveTo:create(0.05, cc.p(-50,0)), cc.MoveTo:create(0.1, cc.p(SCREEN_WIDTH,0)), cc.Hide:create(), cc.Place:create(cc.p(-SCREEN_WIDTH, 0))))
        end
    end)
    bg:addChild(btn_close)    

    local titlebg = cc.Sprite:create("image/ui/img/bg/bg_142.png")
    titlebg:setPosition(100, bgsize.height-5)
    bg:addChild(titlebg)

    local title = cc.Sprite:create("image/ui/img/btn/btn_1258.png")
    title:setPosition(100, bgsize.height)
    bg:addChild(title)

    local shijie_layer = cc.Layer:create()
    local siliao_layer = cc.Layer:create()
    local currChannel = "shijie"

    local LayerMultiplex = cc.LayerMultiplex:create(shijie_layer, siliao_layer)
    contentbg:addChild(LayerMultiplex)

    local menu = cc.Menu:create()
    menu:setPosition(520, contentsize.height-10)
    contentbg:addChild(menu)

    local shijie = cc.MenuItemImage:create("image/ui/img/btn/btn_606.png", "image/ui/img/btn/btn_605.png")
    shijie:setName("shijie")
    shijie:setAnchorPoint(0.5,0)
    shijie:setPosition(0, 0)
    menu:addChild(shijie)
    
    shijie:selected()

    local shijie_wenzi = Common.finalFont("世界", 0,0,26,cc.c3b(255,255,102))
    shijie_wenzi:setPosition(shijie:getContentSize().width*0.5, shijie:getContentSize().height*0.4)
    shijie_wenzi:setName("shijie_wenzi")
    shijie:addChild(shijie_wenzi)

    local siliao = cc.MenuItemImage:create("image/ui/img/btn/btn_606.png", "image/ui/img/btn/btn_605.png")
    siliao:setName("siliao")
    siliao:setAnchorPoint(0.5,0)
    siliao:setPosition(140, 0)
    menu:addChild(siliao)

    local siliao_wenzi = Common.finalFont("私聊", 0,0,26,cc.c3b(120,120,120))
    siliao_wenzi:setPosition(siliao:getContentSize().width*0.5, siliao:getContentSize().height*0.4)
    siliao_wenzi:setName("siliao_wenzi")
    siliao:addChild(siliao_wenzi)

    local shijie_listView = ccui.ListView:create()
    shijie_layer:addChild(shijie_listView)

    shijie_listView:setDirection(ccui.ScrollViewDir.vertical)
    shijie_listView:setBounceEnabled(false)
    shijie_listView:setContentSize(cc.size(725,310))
    shijie_listView:setPosition(10,20)


    local siliao_listView = ccui.ListView:create()
    siliao_layer:addChild(siliao_listView)

    siliao_listView:setDirection(ccui.ScrollViewDir.vertical)
    siliao_listView:setBounceEnabled(false)
    siliao_listView:setContentSize(cc.size(725,310))
    siliao_listView:setPosition(10,20)

    local editbg = ccui.MixButton:create("image/ui/img/btn/btn_496.png")
    editbg:setTouchEnabled(false)
    editbg:setChild("image/ui/img/btn/btn_480.png")
    -- editbg:setScaleY(0.8)
    editbg:setAnchorPoint(0,0.5)
    editbg:setPosition(150, contentsize.height-55)
    contentbg:addChild(editbg)

    local function editBoxTextEventHandle(strEventName,pSender)
        local edit = pSender
        local strFmt 
        if strEventName == "changed" then
            local text = edit:getText()
            local content = string.trim(text)
            if string.utf8len(content) > 80 then
                content = utf8.sub(content,1,80)
                edit:setText(content)
                application:showFlashNotice("最多80个字符哦")
            end
        end
    end

    local size = cc.size(430,40)
    local edit_content = ccui.EditBox:create(size, unused_texture)
    edit_content:setTouchEnabled(true)
    edit_content:ignoreContentAdaptWithSize(false) 
    edit_content:setFontSize(26)
    edit_content:setFontName(BaseConfig.fontname)
    edit_content:setFontColor(cc.c3b(0,0,0))
    edit_content:setMaxLength(80)
    edit_content:setAnchorPoint(0,0)
    edit_content:setPosition(5, 10)
    edit_content:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    edit_content:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE )
    edit_content:registerScriptEditBoxHandler(editBoxTextEventHandle) 
    editbg:addChild(edit_content)

    edit_content:setPlaceHolder("请输入内容：")

    local function menuSelect(  tag, sender  )
        local select_tag = sender:getName()
        if select_tag == currLayerIdx then
            return
        end
        if select_tag == "shijie" then
            shijie:selected()
            siliao:unselected()
            shijie_wenzi:setColor(cc.c3b(255,255,120))
            siliao_wenzi:setColor(cc.c3b(120,120,120))
            edit_content:setPlaceHolder("请输入内容：")
            LayerMultiplex:switchTo(0)
            shijie_listView:scrollToBottom(0.1,true)
        elseif select_tag == "siliao" then
            shijie:unselected()
            siliao:selected()
            siliao_wenzi:setColor(cc.c3b(255,255,120))
            shijie_wenzi:setColor(cc.c3b(120,120,120))
            edit_content:setPlaceHolder("对"..currChatname.."说:")
            LayerMultiplex:switchTo(1)
            siliao_listView:scrollToBottom(0.1,true) 
        end        
        currChannel = select_tag
    end

    shijie:registerScriptTapHandler(menuSelect)
    siliao:registerScriptTapHandler(menuSelect)

    layerColor.menuSwitch = function (self, cid, cname )
        -- print(cid, cname)
        if not cname then
            menuSelect(0, shijie)
        else
            currChatname = cname
            currChatID = cid
            menuSelect(1, siliao)
        end        
    end

    layerColor.scrollToUpdate = function ( self )
        shijie_listView:scrollToBottom(0.1,true) 
        siliao_listView:scrollToBottom(0.1,true) 
    end

    local btn_voice = ccui.MixButton:create("image/ui/img/btn/btn_818.png")
    btn_voice:setVisible(false)
    btn_voice:setScale9Size(cc.size(450,60))
    btn_voice:setTitle("长按即可语音发言", 22, cc.c3b(245,255,10))
    btn_voice:setPosition(375, contentsize.height-55)
    -- btn_voice:setChild("image/ui/img/btn/btn_1260.png")
    contentbg:addChild(btn_voice)
    btn_voice:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.began then

            -- 录音开始
            if currChannel == "siliao" and currChatname == "" then
                 application:showFlashNotice("没有聊天对象？点一下别人的聊天内容就可以私聊哦")
                return
            end

            if currChannel == "shijie" and not YV_WILDCARD_NAME[GameCache.ServerName.."世界"] then
                application:showFlashNotice("不能在该频道发言!")
                return
            end

            if currChannel == "shijie" and YV_WILDCARD_NAME[GameCache.ServerName.."世界"] and not chatable then
                application:showFlashNotice("该频道10秒可发言一次!")
                return
            end

            local filename = GameCache.Avatar.RID .. "_"..os.time()..".amr"
            local path = cc.FileUtils:getInstance():getWritablePath()..filename
            yvtool:startRecord(path, filename)
        elseif eventType == ccui.TouchEventType.ended then

            if GameCache.Avatar.Level < 10 then
                application:showFlashNotice("10级方可发言哦")
                return
            end

            if currChannel == "siliao" and currChatname == "" then
                 -- application:showFlashNotice("没有聊天对象？点一下别人的聊天内容就可以私聊哦")
                return
            end

            if currChannel == "shijie" and not YV_WILDCARD_NAME[GameCache.ServerName.."世界"] then
                -- application:showFlashNotice("不能在该频道发言!")
                return
            end

            if currChannel == "shijie" and YV_WILDCARD_NAME[GameCache.ServerName.."世界"] and not chatable then
                -- application:showFlashNotice("该频道10秒可发言一次!")
                return
            end
            -- 录音结束并发送
            yvtool:stopRecord()
        elseif eventType == ccui.TouchEventType.canceled then

            -- 录音取消
        end
    end)

    local is_voice = false
    local btn_voiceSwitch = ccui.MixButton:create("image/ui/img/btn/btn_818.png")
    btn_voiceSwitch:setPosition(70, contentsize.height-55)
    btn_voiceSwitch:setChild("image/ui/img/btn/btn_1260.png")
    contentbg:addChild(btn_voiceSwitch)
    btn_voiceSwitch:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then

            if GameCache.Avatar.Level < 10 then
                application:showFlashNotice("10级方可发言哦")
                return
            end

            if is_voice then
                btn_voice:setVisible(false)
                editbg:setVisible(true)
            else
                btn_voice:setVisible(true)
                editbg:setVisible(false)
            end
            is_voice = not is_voice
        end
    end)

    local btn_send = ccui.MixButton:create("image/ui/img/btn/btn_818.png")
    btn_send:setPosition(675, contentsize.height-55)
    btn_send:setChild("image/ui/img/btn/btn_1259.png")
    contentbg:addChild(btn_send)
    btn_send:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then

            if GameCache.Avatar.Level < 10 then
                application:showFlashNotice("10级方可发言哦")
                return
            end

            local msg = edit_content:getText()
            msg = string.trim(msg)
            if msg == "" then
                application:showFlashNotice("请您输入内容")
                return
            end

            if currChannel == "shijie" then
                if not YV_WILDCARD_NAME[GameCache.ServerName.."世界"] then
                    edit_content:setText("")
                    application:showFlashNotice("不能在该频道发言!")
                end
                if not chatable then
                    application:showFlashNotice("发言频率过高，本频道10秒才能说一次哦")
                return
            end
                yvtool:sendChannalText(GameCache.ServerName.."世界", msg, GameCache.Avatar.Icon.."+"..GameCache.Avatar.VIP)
            elseif currChannel == "siliao" then
                if currChatname == "" then
                    edit_content:setText("")
                    application:showFlashNotice("没有聊天对象？点一下别人的头像就可以私聊哦")
                end
                yvtool:sendFriendText(currChatID, msg, GameCache.Avatar.Icon.."+"..GameCache.Avatar.VIP)
            end
            
        end
        
    end)

    local function createChatItem( flag, expand, nickname, msgtype, voicemsg, voiceurl, voicetime, textmsg , flip)
        local default_item = ccui.Layout:create()
        local item_width = 725
        local flag_color = {["世界"] = cc.c3b(10,255,5), ["私聊"] = cc.c3b(0,222,255),}

        local title = "["..flag.."]"
        
        local n = string.find(expand, '+')
        local id = tonumber(string.sub(expand, 1,n-1))
        local starlevel = tonumber(string.sub(expand, n+1))
        if starlevel > 12 then
            starlevel = 12
        end

        local icon = GoodsInfoNode.new(BaseConfig.GOODS_HERO, {ID = id, StarLevel = starlevel}, BaseConfig.GOODS_SMALLTYPE)
        icon:setTouchEnable(false)
        default_item:addChild(icon)

        local label_channel = Common.systemFont(title,120, 10, 16, flag_color[flag])
        label_channel:setAnchorPoint(0,1)
        default_item:addChild(label_channel)

        local label_name = Common.systemFont(nickname,180, 10, 16, cc.c3b(203,242,191))
        label_name:setAnchorPoint(0,1)
        default_item:addChild(label_name)

        if flag == "私聊" then
            label_name:setString(nickname .. " 对你说:")
        end

        local size_name = label_name:getContentSize()

        if msgtype == 1 then

            local voice_time = math.floor(voicetime/1000)
            
            local length = voice_time * 50
            
            if length < 150 then
                length = 150
            elseif length > 600 then
                length = 600
            end

            local size_btn = cc.size(length,50)

            local btn_speak = ccui.MixButton:create("image/ui/img/bg/bg_04.png")
            btn_speak:setScale9Size(size_btn)
            btn_speak:setTouchEnabled(true)
            btn_speak:setAnchorPoint(0,1)   
            btn_speak:addTouchEventListener(function ( sender, eventType )
                if eventType == ccui.TouchEventType.ended then
                    yvtool:playRecord(cc.FileUtils:getInstance():getWritablePath()..voiceurl, voiceurl, "")
                end
            end)

            local sprite_speak = cc.Sprite:create("image/ui/img/btn/btn_1260.png")
            sprite_speak:setPosition(40, size_btn.height*0.5)
            btn_speak:addChild(sprite_speak)

            local time = Common.systemFont("".. voice_time .."''", 80, size.height*0.5, 20, cc.c3b(0,0,0))
            time:setAnchorPoint(0,0.5)
            btn_speak:addChild(time)

            local newsize = cc.size(item_width, size_name.height + size_btn.height + 25)

            if newsize.height < 70 then
                newsize.height = 70
            end

            btn_speak:setPosition(90, newsize.height-25)
            -- textbg:setPosition(80, newsize.height-20)
            icon:setPosition(50, newsize.height-30)
            label_channel:setPosition(90, newsize.height)
            label_name:setPosition(140, newsize.height)

            if starlevel >= 10 then
                label_name:setColor(cc.c3b(255,200,0))
            end

            if flip then
                if flag == "私聊" then
                    label_name:setString( "我对 ".. currChatname .." 说:")
                end
            end

            default_item:addChild(btn_speak) 

            default_item:setContentSize(newsize)

        elseif msgtype == 2 then
            --todo
            -- 文字
            local label_text = Common.systemFont(textmsg, 1, 1, 20)
            label_text:setColor(cc.c3b(192,232,255))
            label_text:setAnchorPoint(0,1)
            label_text:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
            label_text:setLineBreakWithoutSpace(false)

            local size = label_text:getContentSize()
            local h = math.ceil(size.width / 600) * size.height
            if size.width > 600 then
                size.width = 600
            end
            label_text:setDimensions(size.width, h+3)

            default_item:addChild(label_text)
            
            local newsize = cc.size(item_width, h+30+size_name.height)
            if newsize.height < 70 then
                newsize.height = 70
            end
            icon:setPosition(50, newsize.height-30)
            label_channel:setPosition(90, newsize.height)
            label_text:setPosition(90, newsize.height-28)
            label_name:setPosition(140, newsize.height)
            -- textbg:setPosition(80, newsize.height-20)

            if starlevel >= 10 then
                label_name:setColor(cc.c3b(255,200,0))
                label_text:setColor(cc.c3b(255,200,0))

            end

            if flip then
                if flag == "私聊" then
                    label_name:setString( "我对 ".. currChatname .." 说:")
                end

                label_text:setColor(cc.c3b(150,255,0))
            end

            default_item:setContentSize(newsize)
        end

        default_item.addTouchEventListener = function (self, fun )
            icon:setTouchEnable(true)
            icon:addTouchEventListener(fun)
        end
        
        return default_item
    end

    -- 频道历史消息回调
    yvtool:registerYvListenerHandler(function ( response )
        -- print("lua-----------channel history")
        -- dump(response)
        for i=#response,1,-1 do

            if response[i].nickname == GameCache.Avatar.Name then
                local default_item = createChatItem("世界", response[i].ext1, response[i].nickname, response[i].type, response[i].attach, response[i].msg, response[i].time, response[i].msg, true )
                default_item:setTouchEnabled(false)
                shijie_listView:pushBackCustomItem(default_item)
                shijie_listView:refreshView()
                shijie_listView:scrollToBottom(0.1,true) 
            else
                local default_item = createChatItem("世界", response[i].ext1, response[i].nickname, response[i].type, response[i].attach, response[i].msg, response[i].time, response[i].msg )
                default_item:setTouchEnabled(true)
                default_item:addTouchEventListener(function ( sender, eventType )
                    if eventType == ccui.TouchEventType.ended then
                        layerColor:menuSwitch(response[i].userid, response[i].nickname)

                    end
                end)
                shijie_listView:pushBackCustomItem(default_item)
                shijie_listView:refreshView()
                shijie_listView:scrollToBottom(0.1,true)                 
            end
        end
    end, YVHANDLER.CHANNEL_HISTORY_HANDLER)

    -- 频道消息回调
    yvtool:registerYvListenerHandler(function ( response )

        local default_item = createChatItem("世界", response.ext1, response.nickname, response.type, response.attach, response.msg, response.time, response.msg)
        default_item:setTouchEnabled(true)
        default_item:addTouchEventListener(function ( sender, eventType )
            if eventType == ccui.TouchEventType.ended then
                layerColor:menuSwitch(response.userid, response.nickname)

            end
            
        end)

        shijie_listView:pushBackCustomItem(default_item)
        shijie_listView:refreshView()
        shijie_listView:scrollToBottom(0.1,true)  

    end, YVHANDLER.CHANNEL_CHAT_HANDLER)

    -- 频道发送消息回调
    yvtool:registerYvListenerHandler(function ( response )
        -- print("lua-----------channel chat state")
        -- dump(response)

        if response.result > 0 then
            application:showFlashNotice("发送失败，请重新发送!")
            return
        end

        edit_content:setText("")

        chatable = false
        local n = 10
        timer = scheduler:scheduleScriptFunc(function (  )
            n = n - 1
            if n <= 0 then
                chatable = true
                scheduler:unscheduleScriptEntry(timer)
                timer = nil
            end


        end , 1, false)

        local default_item = createChatItem("世界",response.expand, GameCache.Avatar.Name, response.type, voice_text, response.url, response.time, response.textMsg, true)
        default_item:setTouchEnabled(false)
        voice_text = ""

        shijie_listView:pushBackCustomItem(default_item)
        shijie_listView:refreshView()
        shijie_listView:scrollToBottom(0.1,true)

    end, YVHANDLER.CHANNEL_STATE_HANDLER)
 

    -- 好友消息回调
    yvtool:registerYvListenerHandler(function ( response )

        -- print("lua-----------friend chat")
        -- dump(response)
        local default_item = createChatItem("私聊", response.ext1, response.nickname, response.type, response.attach, response.msg, response.time, response.msg)
        default_item:setTouchEnabled(true)
        default_item:addTouchEventListener(function ( sender, eventType )
            if eventType == ccui.TouchEventType.ended then
                layerColor:menuSwitch(response.userid, response.nickname)

            end
            
        end)

        siliao_listView:pushBackCustomItem(default_item)
        siliao_listView:refreshView()
        siliao_listView:scrollToBottom(0.1,true)  

        local default_item1 = createChatItem("私聊", response.ext1, response.nickname, response.type, response.attach, response.msg, response.time, response.msg)
        default_item1:setTouchEnabled(true)
        default_item1:addTouchEventListener(function ( sender, eventType )
            if eventType == ccui.TouchEventType.ended then
                layerColor:menuSwitch(response.userid, response.nickname)

            end
            
        end)

        shijie_listView:pushBackCustomItem(default_item1)
        shijie_listView:refreshView()
        shijie_listView:scrollToBottom(0.1,true)  


    end, YVHANDLER.FRIEND_CHAT_HANDLER)

    -- 好友发送消息回调
    yvtool:registerYvListenerHandler(function ( response )
        -- print("lua-----------friend chat state")
        -- dump(response)
        if response.result > 0 then
            application:showFlashNotice("发送失败，请重新发送!")
            return
        end

        edit_content:setText("")
        
        local default_item = createChatItem("私聊",response.ext1, GameCache.Avatar.Name, response.type, response.textMsg, response.url, response.time, response.textMsg, true)
        default_item:setTouchEnabled(false)
        
        local default_item1 = createChatItem("私聊",response.ext1, GameCache.Avatar.Name, response.type, response.textMsg, response.url, response.time, response.textMsg, true)
        default_item:setTouchEnabled(false)

        siliao_listView:pushBackCustomItem(default_item)
        siliao_listView:refreshView()
        siliao_listView:scrollToBottom(0.1,true)  

        shijie_listView:pushBackCustomItem(default_item1)
        shijie_listView:refreshView()
        shijie_listView:scrollToBottom(0.1,true)  

    end, YVHANDLER.FRIEND_STATE_HANDLER)


    -- 录音结束回调
    yvtool:registerYvListenerHandler(function ( response )
        -- print("lua----------stop record")
        -- dump(response)

        if response.time < 100 then
            application:showFlashNotice("请长按语音按钮，松开即可发送!")
            return
        end

        yvtool:speechVoice(response.path, response.path .. "+" .. response.time, true)
    end, YVHANDLER.STOP_RECORDE_HANDLER)

    -- 录音识别后回调
    yvtool:registerYvListenerHandler(function ( response )
        -- print("lua----------speech end")
        -- dump(response)

        local n = string.find(response.ext, '+')
        local path = string.sub(response.ext, 1,n-1)
        local time = tonumber(string.sub(response.ext, n+1))

        voice_text = response.voice_text

        if currChannel == "shijie" then
            yvtool:sendChannalVoice(GameCache.ServerName.."世界", path, time, response.voice_text, GameCache.Avatar.Icon.."+"..GameCache.Avatar.VIP)

        elseif currChannel == "siliao" then
            yvtool:sendFriendVoice( currChatID, path, time, response.voice_text, GameCache.Avatar.Icon.."+"..GameCache.Avatar.VIP)
        end

    end, YVHANDLER.FINISH_SPEECH_HANDLER)




end

function MainLayer:showChatLayer( chatid ,chatname )
    if not self.chatlayer then
        return
    end

    self.chatlayer:stopAllActions()
    self.chatlayer:runAction(cc.Sequence:create(cc.MoveTo:create(0.1, cc.p(50,0)), cc.MoveTo:create(0.05, cc.p(0,0))))
    self.chatlayer:setVisible(true)

    self.chatlayer:menuSwitch(chatid, chatname)
    self.chatlayer:scrollToUpdate()
end

function MainLayer:addEventListeners()
    local listener = application:addEventListener(AppEvent.UI.MainLayer.updateAlert, function(event)
        -- BaseConfig.isCanClick = true
        local function updateHeroAlert()
            local heroTabs = GameCache.GetAllHero()
            local isShowAlert = false
            for k,v in pairs(heroTabs) do
                if Common.isShowHeroAlert(v) then
                    isShowAlert = true
                    break
                end
            end
            if not isShowAlert then
                isShowAlert = Common.isCanCompoundHero()
            end
            if self.controls.heroAlert then
                self.controls.heroAlert:setVisible(isShowAlert)
            end
        end
        local function updatePackageAlert()
            local isShowAlert = false
            local allFrag = GameCache.GetAllFrag()
            for k,v in pairs(allFrag) do
                if (Common.isFragCompound(v)) then
                    isShowAlert = true
                    break
                end
            end
            if self.controls.packageAlert then
                self.controls.packageAlert:setVisible(isShowAlert)
            end
        end
        if not self.controls then
            return 
        end
        updateHeroAlert()
        updatePackageAlert()
    end)
    table.insert(self.eventListeners, listener)

    local listener = application:addEventListener(AppEvent.UI.Heartbeat.Heart, function(event)
        local result = event.data
        self.activity = result.showActivity
        if self.controls.mailAlert then
            self.controls.mailAlert:setVisible(result.showMail)
            self.data.showMail = result.showMail
        end
        self.controls.friendsAlert:setVisible(result.showFriend)
        if GameCache.Avatar.Level >= BaseConfig.OpenSystemLevel.gamble then
            self.controls.gambleAlert:setVisible(result.showGamble)
        end
        if self.controls.activityAlert then
            self.controls.activityAlert:setVisible(result.showActivity) 
        end 
        if GameCache.Avatar.Level >= BaseConfig.OpenSystemLevel.task then
            if self.controls.taskAlert then
                self.controls.taskAlert:setVisible(result.showTask)
            end
        end
        if self.controls.homeAlert then
            self.controls.homeAlert:setVisible(result.showHome)
        end
        if self.controls.energyAlert then
            self.controls.energyAlert:setVisible(result.showEnergy)
        end
    end)
    table.insert(self.eventListeners, listener)

    local listener = application:addEventListener(AppEvent.UI.MainLayer.RefreshOthers, function ( event )
        local iscreate = event.data
        self:createOtherPlayer(iscreate)
    end)
    table.insert(self.eventListeners, listener)
end

function MainLayer:changeAvatarIcon( )
    local scene = cc.Director:getInstance():getRunningScene()
    local layer = cc.LayerColor:create(cc.c4b(0,0,0,180))
    scene:addChild(layer)

    local bgsize = cc.size(768,550)
    local bg = ccui.ImageView:create("image/ui/img/bg/bg_139.png")
    bg:setScale9Enabled(true)
    bg:setContentSize(bgsize)
    bg:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)
    layer:addChild(bg)

    local allId = {}
    for k,v in pairs(GameCache.AllHero) do
        table.insert(allId, v.ID)
    end
    local heronum = #allId
    local height = math.ceil(heronum/5)*140 + 2 * 80

    if height < bgsize.height-40 then
        height = bgsize.height-40
    end

    local scrollview = ccui.ScrollView:create()
    scrollview:setTouchEnabled(true)
    scrollview:setContentSize(cc.size(bgsize.width, bgsize.height-40))    
    scrollview:setDirection(ccui.ScrollViewDir.vertical)
    scrollview:setInnerContainerSize(cc.size(bgsize.width, height))    
    scrollview:setPosition(0,20)
    bg:addChild(scrollview)


    local sprite = cc.Sprite:create("image/ui/img/btn/btn_811.png")
    sprite:setAnchorPoint(0.5,1)
    sprite:setPosition(bgsize.width*0.5, height)
    scrollview:addChild(sprite)

    local ssize = sprite:getContentSize()

    local line1 = cc.Sprite:create("image/ui/img/btn/btn_810.png")
    line1:setPosition(ssize.width*0.5, ssize.height)
    sprite:addChild(line1)
    local line = cc.Sprite:create("image/ui/img/btn/btn_810.png")
    line:setPosition(ssize.width*0.5, 0)
    sprite:addChild(line)

    local label = Common.finalFont("星将头像" , ssize.width*0.5 , ssize.height*0.5, 26, nil, 1)
    sprite:addChild(label)

    local label = Common.finalFont("拥有的星将都可设为头像和形象" , bgsize.width*0.5 , height-100, 22, cc.c3b(120,246,103))
    scrollview:addChild(label)

    local function onIconTouchEvent(x,y, id )

        local layerColor = cc.LayerColor:create(cc.c4b(0,0,0,150),bgsize.width, height)
        scrollview:addChild(layerColor,2)

        local icon = ccui.MixButton:create(string.format("image/icon/head/xj_%s.png", id))
        icon:setChild("image/icon/border/border_star_3.png")
        icon:setTouchEnabled(false)
        icon:setPosition(x,y)
        layerColor:addChild(icon)

        local iconsize = icon:getContentSize()
        local sprite = cc.Sprite:create("image/ui/img/btn/btn_917.png")
        sprite:setPosition(0,iconsize.height*0.5)
        icon:addChild(sprite)
        sprite:runAction(cc.MoveBy:create(0.2, cc.p(90, 0)))

 
        local delay = cc.DelayTime:create(0.3)
        local fadein = cc.FadeIn:create(0.3)
        local move1 = cc.MoveBy:create(0.3, cc.p(40, 70))
        local move2 = cc.MoveBy:create(0.3, cc.p(40, -70))
        local rotate1 = cc.RotateBy:create(0.3, -35)
        local rotate2 = cc.RotateBy:create(0.1, 5)
        local rotate3 = cc.RotateBy:create(0.3, 35)
        local rotate4 = cc.RotateBy:create(0.1, -5)

        local spawn1 = cc.Spawn:create(cc.FadeIn:create(0.3), move1,rotate1)
        local spawn2 = cc.Spawn:create(fadein, move2,rotate3)

        local size = sprite:getContentSize()
        
        local box1 = ccui.MixButton:create("image/ui/img/btn/btn_918.png","image/ui/img/btn/btn_918.png")
        box1:setPressedActionEnabled(false)
        box1:setAnchorPoint(0,0.5)
        box1:setPosition(0,size.height)
        sprite:addChild(box1)
        box1:setOpacity(0)
        box1:setRotation(-30)
        box1:runAction(cc.Sequence:create( delay, spawn2, rotate4 ))

        local gou1 = cc.Sprite:create("image/ui/img/btn/btn_878.png")
        gou1:setPosition(26,31)
        gou1:setVisible(false)
        gou1:setOpacity(0)
        gou1:runAction(cc.Sequence:create( delay, cc.FadeIn:create(0.3)))
        box1:addChild(gou1)
        

        box1:addTouchEventListener(function ( sender, eventType )
            if eventType == ccui.TouchEventType.ended then
                local visible = gou1:isVisible()
                visible = not visible
                gou1:setVisible(visible)
            end
        end)
        local label_touxiang = Common.finalFont("设为头像" , 100 , 31, 22)
        label_touxiang:setOpacity(0)
        label_touxiang:runAction(cc.Sequence:create( delay, cc.FadeIn:create(0.3)))
        box1:addChild(label_touxiang)




        local box2 = ccui.MixButton:create("image/ui/img/btn/btn_918.png","image/ui/img/btn/btn_918.png")       
        box2:setPressedActionEnabled(false)
        box2:setAnchorPoint(0,0.5)
        box2:setPosition(0,0)
        sprite:addChild(box2)
        box2:setOpacity(0)
        box2:setRotation(30)
        box2:runAction( cc.Sequence:create( delay, spawn1, rotate2  ))

        local gou2 = cc.Sprite:create("image/ui/img/btn/btn_878.png")
        gou2:setPosition(26,31)
        gou2:setVisible(false)
        gou2:setOpacity(0)
        gou2:runAction(cc.Sequence:create( delay, cc.FadeIn:create(0.3)))
        box2:addChild(gou2)

        box2:addTouchEventListener(function ( sender, eventType )
            if eventType == ccui.TouchEventType.ended then
                local visible = gou2:isVisible()
                visible = not visible
                gou2:setVisible(visible)
            end
        end)

        local label_xingxiang = Common.finalFont("设为形像" , 100 , 31, 22)
        label_xingxiang:setOpacity(0)
        label_xingxiang:runAction(cc.Sequence:create( delay, cc.FadeIn:create(0.3)))
        box2:addChild(label_xingxiang)


        if GameCache.Avatar.Icon == id then
            gou1:setVisible(true)
            box1:setTouchEnabled(false)
        end

        if GameCache.Avatar.Figure == id then
            gou2:setVisible(true)
            box2:setTouchEnabled(false)
        end

        if x > bgsize.width*0.5 then    -- 右侧的效果翻转
            sprite:setPosition(iconsize.width,iconsize.height*0.5)
            sprite:setFlippedX(true)
            sprite:stopAllActions()
            sprite:runAction(cc.MoveBy:create(0.2, cc.p(-90, 0)))

            local delay = cc.DelayTime:create(0.3)
            local fadein = cc.FadeIn:create(0.3)
            local move1 = cc.MoveBy:create(0.3, cc.p(-40, 70))
            local move2 = cc.MoveBy:create(0.3, cc.p(-40, -70))
            local rotate1 = cc.RotateBy:create(0.3, 35)
            local rotate2 = cc.RotateBy:create(0.1, -5)
            local rotate3 = cc.RotateBy:create(0.3, -35)
            local rotate4 = cc.RotateBy:create(0.1, 5)
    
            local spawn1 = cc.Spawn:create(cc.FadeIn:create(0.3), move1,rotate1)
            local spawn2 = cc.Spawn:create(fadein, move2,rotate3)

            gou1:setPosition(135,31)
            label_touxiang:setPosition(60,31)
            box1:setRotation(30)
            box1:setAnchorPoint(1,0.5)
            box1:setPosition(size.width,size.height)           
            box1:setFlippedX(true)
            box1:stopAllActions()
            box1:runAction(cc.Sequence:create( delay, spawn2, rotate4 ))

            gou2:setPosition(135,31)
            label_xingxiang:setPosition(60,31)
            box2:setRotation(-30)
            box2:setAnchorPoint(1,0.5)
            box2:setPosition(size.width,0)
            box2:setFlippedX(true)
            box2:stopAllActions()
            box2:runAction( cc.Sequence:create( delay, spawn1, rotate2  ))
        end
               


        local function onTouchBegan(touch, event)
            return true
        end
    
        local function onTouchEnded(touch, event)
            local target = event:getCurrentTarget()
            local locationInNode = sprite:convertToNodeSpace(touch:getLocation())
            local s = sprite:getContentSize()
            local rect = cc.rect(0, 0, s.width, s.height)
    
            if not cc.rectContainsPoint(rect, locationInNode) then
                if GameCache.Avatar.Icon ~= id and gou1:isVisible() then
                    rpc:call("Avatar.ModifyIcon", id)
                    self.controls.avatar_icon2:setTexture(string.format("image/icon/head/xj_%s.png", id))
                    self.controls.avatar_icon1:loadTextureNormal(string.format("image/icon/head/xj_%s.png", id))
                    -- self.controls.avatar_icon1:setChild(string.format("image/icon/head/xj_%s.png", id))
                end

                if GameCache.Avatar.Figure ~= id and gou2:isVisible() then
                    rpc:call("Avatar.ModifyFigure", id)

                    self.figure_select:setPosition(x, y-50)

                    local x,y = self.controls.avatar_figure:getPosition()
                    self.controls.avatar_figure:removeFromParent()
                    self.controls.avatar_figure = HeroManager.new(x, y, id)
                    self.controls.avatar_figure:setScale(0.7)
                    self.controls.avatar_figure:setAnimation(0, "idle", true)
                    self.controls.avatar_figure:setTouchEnabled(false)
                    self.map:addChild(self.controls.avatar_figure, SCREEN_HEIGHT-y)
                end   

                layerColor:removeFromParent()
                layerColor = nil
            end
    
        end

        local listener = cc.EventListenerTouchOneByOne:create()
        listener:setSwallowTouches(true)
        listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
        listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
        local eventDispatcher = self:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layerColor) 

    end

    for i=0,heronum-1 do
        local id = allId[i+1]
        local x = (i % 5) *130 + 120
        local y = (math.floor(i/5)+1) * 130 + 50
        local icon = ccui.MixButton:create(string.format("image/icon/head/xj_%s.png", id))
        icon:setChild("image/icon/border/border_star_3.png")
        -- icon:setPressedActionEnabled(false)
        icon:setPosition(x, height-y)
        scrollview:addChild(icon)
        icon:addTouchEventListener(function ( sender, eventType )
            if eventType == ccui.TouchEventType.ended then
                onIconTouchEvent(x, height-y, id )
            end
        end)

        if GameCache.Avatar.Figure == id then
            self.figure_select = cc.Sprite:create("image/ui/img/btn/btn_502.png")
            self.figure_select:setPosition(x, height-y-40)
            scrollview:addChild(self.figure_select,1)
        end

    end


    local function onTouchBegan(touch, event)
        return true
    end

    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = bg:convertToNodeSpace(touch:getLocation())
        local s = bg:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if not cc.rectContainsPoint(rect, locationInNode) then
            layer:removeFromParent()
            layer = nil
        end

    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)    

end

function MainLayer:showBindAccountConfirm(account, okCallback)
    local layer = cc.Layer:create()

    local scene = cc.Director:getInstance():getRunningScene()
    scene:addChild(layer)

    local bgsize = cc.size(569, 350)

    local bg = cc.Node:create()
    bg:setAnchorPoint(cc.p(0.5, 0.5))
    bg:setContentSize(bgsize)
    bg:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)
    layer:addChild(bg)

    local function onTouchBegan(touch, event)
        return true         
    end

    local function onTouchEnded(touch, event)
        local target = bg
        local pos = target:getParent():convertToNodeSpace(touch:getLocation())
        local box = target:getBoundingBox()

        --CCLog(vardump({box = box, pos = pos}))
        if not cc.rectContainsPoint(box, pos) then
            layer:removeFromParent()            
        end
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, bg)

    local bgSprite = cc.Scale9Sprite:create("image/ui/img/bg/bg_141.png")
    bgSprite:setContentSize(bgsize)
    bgSprite:setPosition(bgsize.width / 2, bgsize.height / 2)
    bg:addChild(bgSprite)


    local accountNode = cc.Node:create()
    accountNode:setAnchorPoint(cc.p(0.5, 0.5))
    accountNode:setContentSize(cc.size(569, 59))
    accountNode:setPosition(cc.p(bgsize.width / 2, bgsize.height * 0.8))
    bg:addChild(accountNode)

    local labelAccountTitle = Common.finalFont("确定帐号",bgsize.width*0.2, 59 / 2,27)
    labelAccountTitle:setColor(cc.c4b(0, 0, 0, 255))
    accountNode:addChild(labelAccountTitle)

    local accountBg = cc.Scale9Sprite:create("image/ui/img/btn/btn_1355.png")
    accountBg:setContentSize(cc.size(350, 50))
    accountBg:setPosition(cc.p(bgsize.width * 0.62, 59 / 2))
    accountNode:addChild(accountBg)

    local labelAccount = Common.finalFont(account.name, bgsize.width*0.35, 59 / 2, 24)
    labelAccount:setAnchorPoint(cc.p(0, 0.5))
    accountNode:addChild(labelAccount)

    local accountName = account.name
    local labelDesc = Common.finalFont("游客帐号可能存在帐号丢失后无法找回的风险！\n点击 “注册帐号” 立即升级为正式帐号。",bgsize.width*0.5, bgsize.height * 0.6, 20)
    labelDesc:setAnchorPoint(cc.p(0.5, 0.5))
    labelDesc:setColor(cc.c4b(0, 0, 0, 255))
    labelDesc:setDimensions(bgsize.width * 0.8, 100)
    labelDesc:setPosition(cc.p(bgsize.width * 0.5, bgsize.height *0.5))
    bg:addChild(labelDesc)

    local btn_ok = ccui.MixButton:create("image/ui/img/btn/btn_818.png")
    btn_ok:setTitleText("注册帐号")
    btn_ok:setScale9Enabled(true)
    btn_ok:setContentSize(cc.size(180, 60))
    btn_ok:setTitleFontSize(27)   
    btn_ok:setPosition(bgsize.width*0.5, bgsize.height * 0.2)
    bg:addChild(btn_ok)
    btn_ok:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            layer:removeFromParent()
            okCallback()
        end
    end)
end

function MainLayer:showBindAccount(account)
    local layer = cc.Layer:create()
    local scene = cc.Director:getInstance():getRunningScene()
    scene:addChild(layer)

    local bgsize = cc.size(500, 400)

    local bg = cc.Node:create()
    bg:setAnchorPoint(cc.p(0.5, 0.5))
    bg:setContentSize(bgsize)
    bg:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)
    layer:addChild(bg)

    local function onTouchBegan(touch, event)
        return true         
    end

    local function onTouchEnded(touch, event)
        local target = bg
        local pos = target:getParent():convertToNodeSpace(touch:getLocation())
        local box = target:getBoundingBox()

        --CCLog(vardump({box = box, pos = pos}))
        if not cc.rectContainsPoint(box, pos) then
            layer:removeFromParent()            
        end
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, bg)

    local bgSprite = cc.Scale9Sprite:create("image/ui/img/bg/bg_141.png")
    bgSprite:setContentSize(bgsize)
    bgSprite:setPosition(bgsize.width / 2, bgsize.height / 2)
    bg:addChild(bgSprite)

    local accountNodeSize = cc.size(489, 59)
    local accountNode = cc.Node:create()
    accountNode:setAnchorPoint(cc.p(0.5, 0.5))
    accountNode:setPosition(cc.p(bgsize.width / 2, 337))
    accountNode:setContentSize(accountNodeSize)
    bg:addChild(accountNode)

    local labelAccountTitle = Common.finalFont("帐号:", 150, accountNodeSize.height / 2, 25)
    labelAccountTitle:setColor(cc.c4b(10, 51, 91, 255))
    labelAccountTitle:setAnchorPoint(cc.p(1, 0.5))
    accountNode:addChild(labelAccountTitle)

    local size = cc.size(280,35)
    local edit_account = ccui.EditBox:create(size, ccui.Scale9Sprite:create("image/ui/img/btn/btn_1355.png"))
    -- local edit_account = ccui.TextField:create()
    edit_account:setTouchEnabled(true)
    edit_account:ignoreContentAdaptWithSize(false)
    edit_account:setPlaceHolder("4-8英文或数字")
    -- edit_account:setContentSize(size)
    edit_account:setFontSize(26)
    -- edit_account:setMaxLengthEnabled(true)
    edit_account:setMaxLength(15)
    edit_account:setFontName(BaseConfig.fontname)
    -- edit_account:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    -- edit_account:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    edit_account:setPosition(accountNodeSize.width / 2 + 60, accountNodeSize.height / 2)
    accountNode:addChild(edit_account)

    local passwordNodeSize = cc.size(489, 59)
    local passwordNode = cc.Node:create()
    passwordNode:setAnchorPoint(cc.p(0.5, 0.5))
    passwordNode:setPosition(cc.p(bgsize.width / 2, 280))
    passwordNode:setContentSize(passwordNodeSize)
    bg:addChild(passwordNode)

    local labelPasswordTitle = Common.finalFont("密码:", 150, passwordNodeSize.height / 2, 25)
    labelPasswordTitle:setColor(cc.c4b(10, 51, 91, 255))
    labelPasswordTitle:setAnchorPoint(cc.p(1, 0.5))
    passwordNode:addChild(labelPasswordTitle)

    local edit_passwordBg = ccui.Scale9Sprite:create("image/ui/img/btn/btn_1355.png")
    edit_passwordBg:setPosition(passwordNodeSize.width / 2 + 60, passwordNodeSize.height / 2)
    edit_passwordBg:setContentSize(size)
    passwordNode:addChild(edit_passwordBg)

    local edit_password = ccui.EditBox:create(cc.size(size.width - 60, size.height), ccui.Scale9Sprite:create())
    -- local edit_account = ccui.TextField:create()
    edit_password:setTouchEnabled(true)
    edit_password:ignoreContentAdaptWithSize(false)
    edit_password:setPlaceHolder("6-16英文或数字")
    --edit_password:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    -- edit_account:setContentSize(size)
    edit_password:setFontSize(26)
    -- edit_account:setMaxLengthEnabled(true)
    edit_password:setMaxLength(20)
    edit_password:setFontName(BaseConfig.fontname)
    -- edit_account:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    -- edit_account:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    edit_password:setPosition(passwordNodeSize.width / 2 + 30, passwordNodeSize.height / 2)
    edit_password:setName("edit_password_show")
    passwordNode:addChild(edit_password)

    local function switchEditPasswordShow(button)
        if edit_password:getName() == "edit_password_show" then
            button:loadTextureNormal("image/ui/img/btn/btn_1377.png")      

            local text = edit_password:getText()
            edit_password:removeFromParent()

            edit_password = ccui.EditBox:create(cc.size(size.width - 60, size.height), ccui.Scale9Sprite:create())
            -- local edit_account = ccui.TextField:create()
            edit_password:setTouchEnabled(true)
            edit_password:ignoreContentAdaptWithSize(false)
            edit_password:setPlaceHolder("6-16英文或数字")
            edit_password:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
            -- edit_account:setContentSize(size)
            edit_password:setFontSize(26)
            -- edit_account:setMaxLengthEnabled(true)
            edit_password:setMaxLength(20)
            edit_password:setFontName(BaseConfig.fontname)
            -- edit_account:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
            -- edit_account:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
            edit_password:setPosition(passwordNodeSize.width / 2 + 30, passwordNodeSize.height / 2)
            edit_password:setName("edit_password_hide")
            passwordNode:addChild(edit_password)

            edit_password:setText(text)
        else
            button:loadTextureNormal("image/ui/img/btn/btn_1364.png")    

            local text = edit_password:getText()
            edit_password:removeFromParent()

            edit_password = ccui.EditBox:create(cc.size(size.width - 60, size.height), ccui.Scale9Sprite:create())
            -- local edit_account = ccui.TextField:create()
            edit_password:setTouchEnabled(true)
            edit_password:ignoreContentAdaptWithSize(false)
            edit_password:setPlaceHolder("6-16英文或数字")
            --edit_password:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
            -- edit_account:setContentSize(size)
            edit_password:setFontSize(26)
            -- edit_account:setMaxLengthEnabled(true)
            edit_password:setMaxLength(20)
            edit_password:setFontName(BaseConfig.fontname)
            -- edit_account:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
            -- edit_account:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
            edit_password:setPosition(passwordNodeSize.width / 2 + 30, passwordNodeSize.height / 2)
            edit_password:setName("edit_password_show")
            passwordNode:addChild(edit_password)

            edit_password:setText(text)
        end
    end

    local btn_show_password = ccui.MixButton:create("image/ui/img/btn/btn_1364.png")
    btn_show_password:setTitleText("")
    btn_show_password:setPosition(cc.p(passwordNodeSize.width / 2 + 180, passwordNodeSize.height / 2))
    passwordNode:addChild(btn_show_password, 1)

    btn_show_password:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            CCLog("切换密码显示")

            switchEditPasswordShow(btn_show_password)
        end
    end)

    local mailboxNodeSize = cc.size(489, 59)
    local mailboxNode = cc.Node:create()
    mailboxNode:setAnchorPoint(cc.p(0.5, 0.5))
    mailboxNode:setPosition(cc.p(bgsize.width / 2, 213))
    mailboxNode:setContentSize(mailboxNodeSize)
    bg:addChild(mailboxNode)

    local labelMailboxTitle = Common.finalFont("邮箱:", 150, mailboxNodeSize.height / 2, 25)
    labelMailboxTitle:setColor(cc.c4b(10, 51, 91, 255))
    labelMailboxTitle:setAnchorPoint(cc.p(1, 0.5))
    mailboxNode:addChild(labelMailboxTitle)

    local edit_mailbox = ccui.EditBox:create(size, ccui.Scale9Sprite:create("image/ui/img/btn/btn_1355.png"))
    -- local edit_account = ccui.TextField:create()
    edit_mailbox:setTouchEnabled(true)
    edit_mailbox:ignoreContentAdaptWithSize(false)
    edit_mailbox:setPlaceHolder("邮箱")
    -- edit_account:setContentSize(size)
    edit_mailbox:setFontSize(26)
    -- edit_account:setMaxLengthEnabled(true)
    edit_mailbox:setMaxLength(40)
    edit_mailbox:setFontName(BaseConfig.fontname)
    -- edit_account:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    -- edit_account:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    edit_mailbox:setPosition(mailboxNodeSize.width / 2 + 60, mailboxNodeSize.height / 2)
    mailboxNode:addChild(edit_mailbox)

    local labelDesc = Common.finalFont("输入邮箱提升帐号安全，请务必填写真实邮箱！",bgsize.width*0.5, bgsize.height * 0.6, 20)
    labelDesc:setAnchorPoint(cc.p(0.5, 0.5))
    labelDesc:setColor(cc.c4b(0, 0, 0, 255))
    labelDesc:setDimensions(bgsize.width * 0.8, 100)
    labelDesc:setPosition(cc.p(bgsize.width * 0.5, bgsize.height *0.28))
    bg:addChild(labelDesc)

    local btn_signup = ccui.MixButton:create("image/ui/img/btn/btn_818.png")
    btn_signup:setTitleText("确定注册")
    btn_signup:setTitleFontSize(27)
    btn_signup:setScale9Enabled(true)
    btn_signup:setContentSize(cc.size(180, 60))

    btn_signup:setPosition(bgsize.width*0.5, 80)
    bg:addChild(btn_signup)
    btn_signup:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            local accountName = edit_account:getText()
            accountName = string.trim(accountName)
            if not AccountHelper.checkAccountName(accountName) then
                application:showFlashNotice("帐号格式错误，请重新输入")
                return
            end

            local password = edit_password:getText()
            if not AccountHelper.checkPassword(password) then
                application:showFlashNotice("密码格式错误，请重新输入")
                return
            end
            password = libmd5.hex(password)

            local email = edit_mailbox:getText()
            if #email > 0 then
                if not AccountHelper.isRightEmail(email) then
                    application:showFlashNotice("邮箱地址格式错误，请重新输入")
                    return
                end
            end

            local url = AccountHelper.BIND_GUEST_URL({name = accountName, password = password, email = email, guest = account.name}, GameCache.LoginKey)
            http.get(url, function ( resp )
                CCLog("response", resp)
                local reply = json.decode(resp)
                if reply.Code ~= 0 then
                    application:showFlashNotice("绑定帐号失败！")
                else
                    AccountHelper.deleteAccount(account)
                    AccountHelper.updateLastLoginAccount({name = accountName, displayName = accountName, password = password, guest = false})
                    GameCache.LoginAccount = {name = accountName, displayName = accountName, password = password, guest = false}

                    layer:removeFromParent()
                    application:showFlashNotice("绑定帐号成功！")
                end
            end)
        end
    end)
end

function MainLayer:showChangeAccountPassword(account)
    local layer = cc.Layer:create()
    local scene = cc.Director:getInstance():getRunningScene()
    scene:addChild(layer)

    local bgsize = cc.size(500, 400)

    local bg = cc.Node:create()
    bg:setAnchorPoint(cc.p(0.5, 0.5))
    bg:setContentSize(bgsize)
    bg:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)
    layer:addChild(bg)

    local function onTouchBegan(touch, event)
        return true        
    end

    local function onTouchEnded(touch, event)
        local target = bg
        local pos = target:getParent():convertToNodeSpace(touch:getLocation())
        local box = target:getBoundingBox()

        --CCLog(vardump({box = box, pos = pos}))
        if not cc.rectContainsPoint(box, pos) then
            layer:removeFromParent()            
        end
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, bg)

    local bgSprite = cc.Scale9Sprite:create("image/ui/img/bg/bg_141.png")
    bgSprite:setContentSize(bgsize)
    bgSprite:setPosition(bgsize.width / 2, bgsize.height / 2)
    bg:addChild(bgSprite)

    local accountNodeSize = cc.size(489, 59)
    local accountNode = cc.Node:create()
    accountNode:setAnchorPoint(cc.p(0.5, 0.5))
    accountNode:setPosition(cc.p(bgsize.width / 2, 337))
    accountNode:setContentSize(accountNodeSize)
    bg:addChild(accountNode)

    local labelAccountTitle = Common.finalFont("帐号:", 150, accountNodeSize.height / 2, 25)
    labelAccountTitle:setColor(cc.c4b(10, 51, 91, 255))
    labelAccountTitle:setAnchorPoint(cc.p(1, 0.5))
    accountNode:addChild(labelAccountTitle)

    local size = cc.size(280,35)
    local edit_account = ccui.EditBox:create(size, ccui.Scale9Sprite:create("image/ui/img/btn/btn_1355.png"))
    -- local edit_account = ccui.TextField:create()
    edit_account:setTouchEnabled(false)
    edit_account:setEnabled(false)
    edit_account:ignoreContentAdaptWithSize(false)
    edit_account:setPlaceHolder("4-8英文或数字")
    -- edit_account:setContentSize(size)
    edit_account:setFontSize(26)
    -- edit_account:setMaxLengthEnabled(true)
    edit_account:setMaxLength(15)
    edit_account:setFontName(BaseConfig.fontname)
    -- edit_account:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    -- edit_account:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    edit_account:setPosition(accountNodeSize.width / 2 + 60, accountNodeSize.height / 2)
    accountNode:addChild(edit_account)

    local passwordNodeSize = cc.size(489, 59)
    local passwordNode = cc.Node:create()
    passwordNode:setAnchorPoint(cc.p(0.5, 0.5))
    passwordNode:setPosition(cc.p(bgsize.width / 2, 280))
    passwordNode:setContentSize(passwordNodeSize)
    bg:addChild(passwordNode)

    local labelPasswordTitle = Common.finalFont("原密码:", 150, passwordNodeSize.height / 2, 25)
    labelPasswordTitle:setColor(cc.c4b(10, 51, 91, 255))
    labelPasswordTitle:setAnchorPoint(cc.p(1, 0.5))
    passwordNode:addChild(labelPasswordTitle)

    local edit_passwordBg = ccui.Scale9Sprite:create("image/ui/img/btn/btn_1355.png")
    edit_passwordBg:setPosition(passwordNodeSize.width / 2 + 60, passwordNodeSize.height / 2)
    edit_passwordBg:setContentSize(size)
    passwordNode:addChild(edit_passwordBg)

    local edit_password = ccui.EditBox:create(cc.size(size.width - 60, size.height), ccui.Scale9Sprite:create())
    -- local edit_account = ccui.TextField:create()
    edit_password:setTouchEnabled(true)
    edit_password:ignoreContentAdaptWithSize(false)
    edit_password:setPlaceHolder("6-16英文或数字")
    
    -- edit_account:setContentSize(size)
    edit_password:setFontSize(26)
    -- edit_account:setMaxLengthEnabled(true)
    edit_password:setMaxLength(20)
    edit_password:setFontName(BaseConfig.fontname)
    -- edit_account:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    -- edit_account:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    edit_password:setPosition(passwordNodeSize.width / 2 + 30, passwordNodeSize.height / 2)
    --edit_password:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    edit_password:setName("edit_password_show")
    passwordNode:addChild(edit_password)

    local function switchEditPasswordShow(button)
        if edit_password:getName() == "edit_password_show" then
            button:loadTextureNormal("image/ui/img/btn/btn_1377.png")      

            local text = edit_password:getText()
            edit_password:removeFromParent()

            edit_password = ccui.EditBox:create(cc.size(size.width - 60, size.height), ccui.Scale9Sprite:create())
            -- local edit_account = ccui.TextField:create()
            edit_password:setTouchEnabled(true)
            edit_password:ignoreContentAdaptWithSize(false)
            edit_password:setPlaceHolder("6-16英文或数字")
            
            -- edit_account:setContentSize(size)
            edit_password:setFontSize(26)
            -- edit_account:setMaxLengthEnabled(true)
            edit_password:setMaxLength(20)
            edit_password:setFontName(BaseConfig.fontname)
            -- edit_account:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
            -- edit_account:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
            edit_password:setPosition(passwordNodeSize.width / 2 + 30, passwordNodeSize.height / 2)
            edit_password:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
            edit_password:setName("edit_password_hide")
            passwordNode:addChild(edit_password)

            edit_password:setText(text)
        else
            button:loadTextureNormal("image/ui/img/btn/btn_1364.png")      

            local text = edit_password:getText()
            edit_password:removeFromParent()

            edit_password = ccui.EditBox:create(cc.size(size.width - 60, size.height), ccui.Scale9Sprite:create())
            -- local edit_account = ccui.TextField:create()
            edit_password:setTouchEnabled(true)
            edit_password:ignoreContentAdaptWithSize(false)
            edit_password:setPlaceHolder("6-16英文或数字")
            
            -- edit_account:setContentSize(size)
            edit_password:setFontSize(26)
            -- edit_account:setMaxLengthEnabled(true)
            edit_password:setMaxLength(20)
            edit_password:setFontName(BaseConfig.fontname)
            -- edit_account:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
            -- edit_account:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
            edit_password:setPosition(passwordNodeSize.width / 2 + 30, passwordNodeSize.height / 2)
            --edit_password:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
            edit_password:setName("edit_password_show")
            passwordNode:addChild(edit_password)

            edit_password:setText(text)
        end
    end

    local btn_show_password = ccui.MixButton:create("image/ui/img/btn/btn_1364.png")
    btn_show_password:setTitleText("")
    btn_show_password:setPosition(cc.p(passwordNodeSize.width / 2 + 180, passwordNodeSize.height / 2))
    passwordNode:addChild(btn_show_password, 1)

    btn_show_password:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            CCLog("切换密码显示")

            switchEditPasswordShow(btn_show_password)
        end
    end)

    local newPasswordNodeSize = cc.size(489, 59)
    local newPasswordNode = cc.Node:create()
    newPasswordNode:setAnchorPoint(cc.p(0.5, 0.5))
    newPasswordNode:setPosition(cc.p(bgsize.width / 2, 213))
    newPasswordNode:setContentSize(newPasswordNodeSize)
    bg:addChild(newPasswordNode)

    local labelnewPasswordTitle = Common.finalFont("新密码:", 150, passwordNodeSize.height / 2, 25)
    labelnewPasswordTitle:setColor(cc.c4b(10, 51, 91, 255))
    labelnewPasswordTitle:setAnchorPoint(cc.p(1, 0.5))
    newPasswordNode:addChild(labelnewPasswordTitle)

    local edit_newPasswordBg = ccui.Scale9Sprite:create("image/ui/img/btn/btn_1355.png")
    edit_newPasswordBg:setPosition(passwordNodeSize.width / 2 + 60, newPasswordNodeSize.height / 2)
    edit_newPasswordBg:setContentSize(size)
    newPasswordNode:addChild(edit_newPasswordBg)

    local edit_newPassword = ccui.EditBox:create(cc.size(size.width - 60, size.height), ccui.Scale9Sprite:create())
    -- local edit_account = ccui.TextField:create()
    edit_newPassword:setTouchEnabled(true)
    edit_newPassword:ignoreContentAdaptWithSize(false)
    edit_newPassword:setPlaceHolder("6-16英文或数字")
    --edit_newPassword:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    -- edit_account:setContentSize(size)
    edit_newPassword:setFontSize(26)
    -- edit_account:setMaxLengthEnabled(true)
    edit_newPassword:setMaxLength(20)
    edit_newPassword:setFontName(BaseConfig.fontname)
    -- edit_account:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    -- edit_account:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    edit_newPassword:setPosition(newPasswordNodeSize.width / 2 + 30, newPasswordNodeSize.height / 2)
    edit_newPassword:setName("edit_new_password_show")
    newPasswordNode:addChild(edit_newPassword)

    local function switchEditNewPasswordShow(button)
        if edit_newPassword:getName() == "edit_new_password_show" then
            button:loadTextureNormal("image/ui/img/btn/btn_1377.png")      

            local text = edit_newPassword:getText()
            edit_newPassword:removeFromParent()

            edit_newPassword = ccui.EditBox:create(cc.size(size.width - 60, size.height), ccui.Scale9Sprite:create())
            -- local edit_account = ccui.TextField:create()
            edit_newPassword:setTouchEnabled(true)
            edit_newPassword:ignoreContentAdaptWithSize(false)
            edit_newPassword:setPlaceHolder("6-16英文或数字")
            
            -- edit_account:setContentSize(size)
            edit_newPassword:setFontSize(26)
            -- edit_account:setMaxLengthEnabled(true)
            edit_newPassword:setMaxLength(20)
            edit_newPassword:setFontName(BaseConfig.fontname)
            -- edit_account:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
            -- edit_account:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
            edit_newPassword:setPosition(newPasswordNodeSize.width / 2 + 30, newPasswordNodeSize.height / 2)
            edit_newPassword:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
            edit_newPassword:setName("edit_new_password_hide")
            newPasswordNode:addChild(edit_newPassword)

            edit_newPassword:setText(text)
        else
            button:loadTextureNormal("image/ui/img/btn/btn_1364.png")      
            local text = edit_newPassword:getText()
            edit_newPassword:removeFromParent()

            edit_newPassword = ccui.EditBox:create(cc.size(size.width - 60, size.height), ccui.Scale9Sprite:create())
            -- local edit_account = ccui.TextField:create()
            edit_newPassword:setTouchEnabled(true)
            edit_newPassword:ignoreContentAdaptWithSize(false)
            edit_newPassword:setPlaceHolder("6-16英文或数字")
            
            -- edit_account:setContentSize(size)
            edit_newPassword:setFontSize(26)
            -- edit_account:setMaxLengthEnabled(true)
            edit_newPassword:setMaxLength(20)
            edit_newPassword:setFontName(BaseConfig.fontname)
            -- edit_account:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
            -- edit_account:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
            edit_newPassword:setPosition(newPasswordNodeSize.width / 2 + 30, newPasswordNodeSize.height / 2)
            --edit_newPassword:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
            edit_newPassword:setName("edit_new_password_show")
            newPasswordNode:addChild(edit_newPassword)

            edit_newPassword:setText(text)
        end
    end

    local btn_show_password_new = ccui.MixButton:create("image/ui/img/btn/btn_1364.png")
    btn_show_password_new:setTitleText("")
    btn_show_password_new:setPosition(cc.p(passwordNodeSize.width / 2 + 180, passwordNodeSize.height / 2))
    newPasswordNode:addChild(btn_show_password_new, 1)

    btn_show_password_new:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            CCLog("切换密码显示")

            switchEditNewPasswordShow(btn_show_password_new)
        end
    end)

    local mailboxNodeSize = cc.size(489, 59)
    local mailboxNode = cc.Node:create()
    mailboxNode:setAnchorPoint(cc.p(0.5, 0.5))
    mailboxNode:setPosition(cc.p(bgsize.width / 2, 146))
    mailboxNode:setContentSize(mailboxNodeSize)
    bg:addChild(mailboxNode)

    local labelMailboxTitle = Common.finalFont("邮箱:", 150, mailboxNodeSize.height / 2, 25)
    labelMailboxTitle:setColor(cc.c4b(10, 51, 91, 255))
    labelMailboxTitle:setAnchorPoint(cc.p(1, 0.5))
    mailboxNode:addChild(labelMailboxTitle)

    local edit_mailbox = ccui.EditBox:create(size, ccui.Scale9Sprite:create("image/ui/img/btn/btn_1355.png"))
    -- local edit_account = ccui.TextField:create()
    edit_mailbox:setTouchEnabled(true)
    edit_mailbox:ignoreContentAdaptWithSize(false)
    edit_mailbox:setPlaceHolder("邮箱")
    -- edit_account:setContentSize(size)
    edit_mailbox:setFontSize(26)
    -- edit_account:setMaxLengthEnabled(true)
    edit_mailbox:setMaxLength(40)
    edit_mailbox:setFontName(BaseConfig.fontname)
    -- edit_account:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    -- edit_account:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    edit_mailbox:setPosition(mailboxNodeSize.width / 2 + 60, mailboxNodeSize.height / 2)
    mailboxNode:addChild(edit_mailbox)

    edit_account:setText(account.displayName)

    local btn_modify = ccui.MixButton:create("image/ui/img/btn/btn_818.png")
    btn_modify:setTitleText("确定")
    btn_modify:setTitleFontSize(27)
    btn_modify:setScale9Enabled(true)
    btn_modify:setContentSize(cc.size(120, 60))

    btn_modify:setPosition(bgsize.width*0.5, 80)
    bg:addChild(btn_modify)
    btn_modify:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            local old_password = edit_password:getText()
            local new_password = edit_newPassword:getText()
            local new_email = edit_mailbox:getText()

            if not AccountHelper.checkPassword(old_password) then
                application:showFlashNotice("原密码格式错误，请重新输入")
                return
            end

            if not AccountHelper.checkPassword(new_password) then
                application:showFlashNotice("新密码格式错误，请重新输入")
                return
            end

            if #new_email > 0 then
                if not AccountHelper.isRightEmail(new_email) then
                    application:showFlashNotice("邮箱地址格式错误，请重新输入")
                    return
                end
            end

            old_password = libmd5.hex(old_password)
            new_password = libmd5.hex(new_password)
            local url = AccountHelper.MODIFY_PASSWORD_URL(account, old_password, new_password, new_email, GameCache.LoginKey)

            http.get(url, function ( resp )
                local reply = json.decode(resp)
                if reply.Code ~= 0 then
                    application:showFlashNotice("修改密码失败！")
                else
                    local accountName = accountName
                    AccountHelper.deleteAccount(account)
                    AccountHelper.updateLastLoginAccount({name = account.name, displayName = account.name, password = new_password, guest = false})
                    GameCache.LoginAccount = {name = account.name, displayName = account.name, password = new_password, guest = false}

                    layer:removeFromParent()
                    application:showFlashNotice("修改密码成功！")
                end
            end)
        end
    end)
end

function MainLayer:showAvatarInfo( )
    local scene = cc.Director:getInstance():getRunningScene()
    local layer = cc.LayerColor:create(cc.c4b(0,0,0,180))
    scene:addChild(layer)

    local size = cc.size(615,409)
    local bg = ccui.ImageView:create("image/ui/img/bg/bg_139.png")
    bg:setPosition(SCREEN_WIDTH*0.5,SCREEN_HEIGHT*0.5)
    bg:setScale9Enabled(true)
    bg:setContentSize(size)
    bg:setScale(0.01)
    layer:addChild(bg)

    local action = cc.Sequence:create({cc.ScaleTo:create(0.1, 1.1),cc.ScaleTo:create(0.1, 1.0)})
    bg:runAction(action)

    local huawen = cc.Sprite:create("image/ui/img/btn/btn_609.png")
    huawen:setPosition(size.width*0.5, size.height*0.5)
    bg:addChild(huawen)

    local top = cc.Sprite:create("image/ui/img/btn/btn_1002.png")
    top:setAnchorPoint(0.5,1)
    top:setPosition(size.width*0.5, size.height-15)
    bg:addChild(top)

    local bottom = ccui.Scale9Sprite:create("image/ui/img/bg/bg_253.png")
    bottom:setContentSize(cc.size(595,75))
    bottom:setAnchorPoint(0.5,0)
    bottom:setPosition(size.width*0.5, 13)
    bg:addChild(bottom)


    local function onTouchBegan(touch, event)
        return true
    end

    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = bg:convertToNodeSpace(touch:getLocation())
        local s = bg:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if not cc.rectContainsPoint(rect, locationInNode) then
            layer:removeFromParent()
            layer = nil
            self.controls.label_power_recover = nil
            self.controls.label_endurance_recover = nil
        end

    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)   


    local sp = cc.Sprite:create("image/icon/border/head_bg.png")
    sp:setPosition(75, size.height-85)
    bg:addChild(sp)

    local head = cc.Sprite:create(Common.heroIconImgPath(GameCache.Avatar.Icon))
    head:setPosition(75, size.height-85)
    bg:addChild(head)
    self.controls.avatar_icon2 = head


    local head1 = cc.Sprite:create("image/icon/border/Head-portrait001.png")
    head1:setPosition(75, size.height-85)
    bg:addChild(head1)



    local btn_changeName = ccui.MixButton:create("image/ui/img/btn/btn_818.png")
    btn_changeName:setScale9Size(cc.size(97,56))
    btn_changeName:setTitle("头/形象" , 18, cc.c3b(238,205,142))
    btn_changeName:setPosition(75, size.height-170)
    bg:addChild(btn_changeName)
    btn_changeName:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            self:changeAvatarIcon()
        end
    end)

    if GAME_BASE_INFO.SDK == nil then
        local btn_accountSetting = ccui.MixButton:create("image/ui/img/btn/btn_818.png")
        btn_accountSetting:setScale9Size(cc.size(97,56))
        btn_accountSetting:setTitle("帐号设置" , 18, cc.c3b(238,205,142))
        btn_accountSetting:setPosition(75, size.height-230)
        bg:addChild(btn_accountSetting)
        btn_accountSetting:addTouchEventListener(function ( sender, eventType )
            if eventType == ccui.TouchEventType.ended then
                local account = GameCache.LoginAccount

                CCLog(vardump(account))
                if account then
                    if account.guest then
                        self:showBindAccountConfirm(account, function() 
                            self:showBindAccount(account)
                        end)
                    else
                        self:showChangeAccountPassword(account, function() end)
                    end
                else
                    application:showFlashNotice("获取帐号信息失败！")
                end
            end
        end)
    end

    --level
    
    local label = Common.finalFont("等级：", 1, 1, 24)
    label:setAnchorPoint(0,0.5)
    label:setPosition(150, 300 )
    bg:addChild(label)
        
    local str = GameCache.Avatar.Level
    local label_level = Common.finalFont(str, 1, 1, 24, cc.c3b(21,255,21))
    label_level:setAnchorPoint(0,0.5)
    label_level:setPosition(230, 300)
    bg:addChild(label_level)

    --gender 1-男 2-女
    
    local label = Common.finalFont("性别：", 1, 1, 24)
    label:setAnchorPoint(0,0.5)
    label:setPosition(344, 300 )
    bg:addChild(label)
        
    local str = GameCache.Avatar.Gender
    local g = {"男", "女"}
    local label_gender = Common.finalFont(g[str], 1, 1, 22, cc.c3b(21,255,21))
    label_gender:setAnchorPoint(0,0.5)
    label_gender:setPosition(418, 300)
    bg:addChild(label_gender)

    local gold = GameCache.Avatar.Gold
    local coin = GameCache.Avatar.Coin
    local label_money = Common.finalFont("元宝：", 1, 1, 24)
    label_money:setAnchorPoint(0,0.5)
    label_money:setPosition(150,255 )
    bg:addChild(label_money)

    label_money = Common.finalFont("" .. gold, 1, 1, 24, cc.c3b(255,246,12))
    label_money:setAnchorPoint(0,0.5)
    label_money:setPosition(223, 255 )
    bg:addChild(label_money)

    label_money = Common.finalFont("银币：", 1, 1, 24)
    label_money:setAnchorPoint(0,0.5)
    label_money:setPosition(344, 255 )
    bg:addChild(label_money)

    label_money = Common.finalFont("" .. coin, 1, 1, 24)
    label_money:setAnchorPoint(0,0.5)
    label_money:setPosition(418, 255 )
    bg:addChild(label_money)


   local label = Common.finalFont("帮会：", 1, 1, 24)
   label:setAnchorPoint(0,0.5)
   label:setPosition(150,215 )
   bg:addChild(label)

    local label = Common.finalFont("ID：", 1, 1, 24)
    label:setAnchorPoint(0,0.5)
    label:setPosition(344,215 )
    bg:addChild(label)

    local rid = GameCache.Avatar.RID or ""
    label_money = Common.finalFont("" .. rid, 1, 1, 24, cc.c3b(21,255,21))
    label_money:setAnchorPoint(0,0.5)
    label_money:setPosition(418, 215 )
    bg:addChild(label_money)

    local str = GameCache.Avatar.League
    local label_league = Common.finalFont(str, 1, 1, 20, cc.c3b(21,255,21))
    label_league:setAnchorPoint(0,0.5)
    label_league:setPosition(230,215)
    bg:addChild(label_league)

   local label = Common.finalFont("竞技场：", 1, 1, 24)
   label:setAnchorPoint(0,0.5)
   label:setPosition(150,170 )
   bg:addChild(label)


    local rank = GameCache.Avatar.ArenaRank
    local str = "第"..rank.."名"
    if rank == 0 then
        str = "未上榜"
    end
    local label_rank = Common.finalFont(str, 1, 1, 20, cc.c3b(21,255,21))
    label_rank:setAnchorPoint(0,0.5)
    label_rank:setPosition(250,170)
    bg:addChild(label_rank)



   local label = Common.finalFont("服务器：", 1, 1, 24)
   label:setAnchorPoint(0,0.5)
   label:setPosition(150,125 )
   bg:addChild(label)



    local str = GameCache.ServerName
    local label_server = Common.finalFont(str, 1, 1, 20, cc.c3b(21,255,21))
    label_server:setAnchorPoint(0,0.5)
    label_server:setPosition(250,125)
    bg:addChild(label_server)


    local str = GameCache.Avatar.Name
    local editbg = cc.Sprite:create("image/ui/img/btn/btn_1001.png")
    editbg:setPosition(size.width*0.38, size.height-50)
    bg:addChild(editbg)

    local editsize = editbg:getContentSize()


    local label_name = Common.systemFont(str, editsize.width*0.5, editsize.height*0.5-2, 22)
    editbg:addChild(label_name)


    local function verifyName( name )
        local num = string.find(name,'[^%w\128-\191\194-\239]+') 
        if num ~= nil then
            return false, "名字只应包含中英文和数字"
        end

        local name_table = {}
        local tempname = name
        local lowername = string.lower(name)
        local uppername = string.upper(name)
        local length = utf8.len(tempname)
        for i=1,length do
            for j=i,length do
                name_table[#name_table+1] = utf8.sub(tempname,i,j)
            end
        end
        for i=1,length do
            for j=i,length do
                name_table[#name_table+1] = utf8.sub(lowername,i,j)
            end
        end

        for i=1,length do
            for j=i,length do
                name_table[#name_table+1] = utf8.sub(uppername,i,j)
            end
        end

        for k,v in pairs(name_table) do
            if BaseConfig.isIllegalWord(v) then
                return false, "名字包含敏感字符-"..v
            end
        end

        return true
    end

    local function changeInfo(  )
        local scene = cc.Director:getInstance():getRunningScene()
        local layer = cc.LayerColor:create(cc.c4b(0,0,0,100))
        scene:addChild(layer)

        local size = cc.size(510,265)
        local bg = ccui.ImageView:create("image/ui/img/bg/bg_139.png")
        bg:setPosition(SCREEN_WIDTH*0.5,SCREEN_HEIGHT*0.6)
        bg:setScale9Enabled(true)
        bg:setContentSize(size)
        layer:addChild(bg)

        local label = Common.finalFont("输入您的名字：", 35, 220, 22)
        label:setAnchorPoint(0,0.5)
        bg:addChild(label)

        local label = Common.finalFont("选择您的性别：", 35, 140, 22)
        label:setAnchorPoint(0,0.5)
        bg:addChild(label)

        local editbg = cc.Sprite:create("image/ui/img/btn/btn_1116.png")
        editbg:setAnchorPoint(0,0.5)
        editbg:setPosition(220, 220)
        bg:addChild(editbg)

        local function editBoxTextEventHandle(strEventName,pSender)
            if strEventName == "began" then
                pSender:setText("")
            elseif strEventName == "ended" then
                local text = pSender:getText()
                local name = string.trim(text)
                if string.utf8len(name) > 5 then
                    pSender:setText("")
                    application:showFlashNotice("名字太长了！")
                elseif string.utf8len(name) < 2 then
                    pSender:setText("")
                    application:showFlashNotice("名字太短了！")
                else
                    pSender:setText(name)
                end
            end
        end

        local editsize = editbg:getContentSize()

        -- local edit_account = ccui.TextField:create()
        local edit_account = ccui.EditBox:create(cc.size(editsize.width-40, editsize.height), ccui.Scale9Sprite:create())
        edit_account:setTouchEnabled(true)
        edit_account:ignoreContentAdaptWithSize(false)
        edit_account:setPlaceHolder("输入角色名")
        edit_account:setText(GameCache.Avatar.Name)
        -- edit_account:setContentSize(editsize)
        edit_account:setFontSize(20)
        -- edit_account:setMaxLengthEnabled(true)
        edit_account:setMaxLength(5)
        edit_account:setFontName(BaseConfig.fontname)
        -- edit_account:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
        -- edit_account:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
        edit_account:setPosition(editsize.width*0.5,editsize.height*0.5-2)
        edit_account:registerScriptEditBoxHandler(editBoxTextEventHandle)
        edit_account:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE )
        edit_account:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
        editbg:addChild(edit_account)

        local saizi = ccui.MixButton:create("image/ui/img/btn/btn_975.png")
        saizi:setPosition(editsize.width*0.95, editsize.height*0.55)
        editbg:addChild(saizi)
        saizi:addTouchEventListener(function ( sender, eventType )
            if eventType == ccui.TouchEventType.ended then
                local name = BaseConfig.randomName()
                name = string.trim(name)
                -- edit_account:setString(name)
                edit_account:setText(name)
            end
        end)
    
        local btn_male = ccui.MixButton:create("image/ui/img/btn/btn_1097.png")
        local btn_female = ccui.MixButton:create("image/ui/img/btn/btn_1098.png")

        local gender = GameCache.Avatar.Gender

        btn_male:setPosition(280,145)
        bg:addChild(btn_male)
        btn_male:addTouchEventListener(function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                btn_male:setBright(true)
                btn_female:setBright(false)
                gender = 1
            end
        end)
    
        
        btn_female:setPosition(415,145)
        bg:addChild(btn_female)
        btn_female:addTouchEventListener(function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                btn_male:setBright(false)
                btn_female:setBright(true)
                gender = 2
            end
        end)

        if GameCache.Avatar.Gender == 1 then
            btn_male:setBright(true)
            btn_female:setBright(false)
        else
            btn_male:setBright(false)
            btn_female:setBright(true)
        end
    
        local btn = ccui.MixButton:create("image/ui/img/btn/btn_818.png")
        btn:setScale9Size(cc.size(135,60))
        btn:setTitle("取消",26,cc.c3b(238,205,142))
        btn:addTouchEventListener(function ( sender, eventType )
            if eventType == ccui.TouchEventType.ended then
                layer:removeFromParent()
                layer = nil
            end
        end)
        btn:setPosition(140, 55)
        bg:addChild(btn)
    
        local btn_sure = ccui.MixButton:create("image/ui/img/btn/btn_818.png")
        btn_sure:setScale9Size(cc.size(135,60))
        btn_sure:setTitle("确定",26,cc.c3b(238,205,142))
        btn_sure:addTouchEventListener(function ( sender, eventType )
            if eventType == ccui.TouchEventType.ended then

                local name = edit_account:getText()

                name = string.trim(name)
                if name == "" then
                    application:showFlashNotice("上仙想做无名之辈吗？")
                    return
                end

                if string.utf8len(name) < 2 or string.utf8len(name) > 5 then
                    edit_account:setText(GameCache.Avatar.Name)
                    application:showFlashNotice("名字长度为2～5个字符")
                    return
                end
               

                local verify, msg = verifyName(name)
                if not verify then
                    edit_account:setText(GameCache.Avatar.Name)
                    application:showFlashNotice(msg)
                    return
                end


                if name ~= GameCache.Avatar.Name then
                    rpc:call("Avatar.ModifyName", name, function(event)
                        if event.status == Exceptions.Nil and event.result == true then
                            
                            GameCache.Avatar.Name = name
                            label_name:setString(name)
                            self.controls.avatar_name:setString(name)
                        elseif event.status == Exceptions.ERolePropsNotEnough then
                            application:showFlashNotice("改名换姓需要更名符哦")
                        elseif event.status == Exceptions.ERolePropsNotEnough then
                            application:showFlashNotice("名字已经被人抢注了")

                        elseif event.status == Exceptions.ERoleNameCharset then
                            application:showFlashNotice("名字只应包含中英文和数字")

                        elseif event.status == Exceptions.ERoleNameIllegal then
                            application:showFlashNotice("名字包含非法字符")

                        elseif event.status == Exceptions.ERoleNameLengthInvalid then
                            application:showFlashNotice("名字长度为2～5个字符")

                        end
                    end)
                end


                if gender ~= GameCache.Avatar.Gender then
                    if gender == 1 then
                        label_gender:setString("男")
                    elseif gender == 2 then
                        label_gender:setString("女")
                    end
                    rpc:call("Avatar.ModifyGender", gender, function(event)
                        GameCache.Avatar.Gender = gender
                        if event.status == Exceptions.Nil and event.result == true then
                            GameCache.Avatar.Gender = gender

                        end
                    end)
                end

                layer:removeFromParent()
                layer = nil
            end
        end)
        btn_sure:setPosition(370, 55)
        bg:addChild(btn_sure)
    

        local function onTouchBegan(touch, event)
            return true
        end
    
        local function onTouchEnded(touch, event)
            local target = event:getCurrentTarget()
            local locationInNode = bg:convertToNodeSpace(touch:getLocation())
            local s = bg:getContentSize()
            local rect = cc.rect(0, 0, s.width, s.height)
    
            if not cc.rectContainsPoint(rect, locationInNode) then
                layer:removeFromParent()
                layer = nil

            end
    
        end
    
        local listener = cc.EventListenerTouchOneByOne:create()
        listener:setSwallowTouches(true)
        listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
        listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
        local eventDispatcher = self:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)   
    end


    local btn_change = ccui.MixButton:create("image/ui/img/btn/btn_818.png")
    btn_change:setScale9Size(cc.size(120,56))
    btn_change:setPosition(size.width*0.65, size.height-50)
    btn_change:setTitle("改昵称",18,cc.c3b(238,205,142))
    btn_change:setTitlePos(0.6,0.5)
    btn_change:setChild("image/ui/img/btn/btn_999.png", 0.2, 0.5)
    btn_change:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            changeInfo()
        end
    end)
    bg:addChild(btn_change)

    local btn_settings = ccui.MixButton:create("image/ui/img/btn/btn_818.png")
    btn_settings:setScale9Size(cc.size(120, 56))
    btn_settings:setTitle("设置",18,cc.c3b(238,205,142))
    btn_settings:setPosition(size.width * 0.85, size.height -50)
    btn_settings:setTitlePos(0.6,0.5)
    btn_settings:setChild("image/ui/img/btn/btn_1000.png",0.25, 0.5)
    btn_settings:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local settings = require("scene.main.settings.SettingsLayer")
            local settingsLayer = settings.new()
            local scene = cc.Director:getInstance():getRunningScene()
            scene:addChild(settingsLayer)
        end
    end)
    bg:addChild(btn_settings)




    local sprite = cc.Sprite:create("image/ui/img/bg/tili.png")
    sprite:setPosition(73, 65)
    bg:addChild(sprite)


    local label_phypower = Common.finalFont("体力：", 1, 1, 24)
    label_phypower:setAnchorPoint(0,0.5)
    label_phypower:setPosition(95, 65)
    bg:addChild(label_phypower)

    local power = GameCache.Avatar.PhyPower
    local maxpower = GameCache.Avatar.MaxPhyPower
    label_phypower = Common.finalFont("" .. power .."/" .. maxpower, 1, 1, 24, cc.c3b(21,255,21))
    label_phypower:setAnchorPoint(0,0.5)
    label_phypower:setPosition(160,65)
    bg:addChild(label_phypower)
    self.infopanel_power = label_phypower

    local huifu = Common.finalFont("下一点回复时间：", 1, 1, 16, cc.c3b(205,205,205))
    huifu:setAnchorPoint(0,0.5)
    huifu:setPosition(65, 35)
    bg:addChild(huifu)
    local power_recover = Common.finalFont("", 1, 1, 16, cc.c3b(205,205,205))
    power_recover:setAnchorPoint(0,0.5)
    power_recover:setPosition(200,35)
    bg:addChild(power_recover)
    self.controls.label_power_recover = power_recover

    local sprite = cc.Sprite:create("image/ui/img/bg/naili.png")
    sprite:setPosition(347, 65)
    bg:addChild(sprite)


    local label_endurance = Common.finalFont("耐力：", 1, 1, 24)
    label_endurance:setAnchorPoint(0,0.5)
    label_endurance:setPosition(370,65)
    bg:addChild(label_endurance)

    local endurance = GameCache.Avatar.Endurance
    local maxendurance = GameCache.Avatar.MaxEndurance
    label_endurance = Common.finalFont("" .. endurance .."/" .. maxendurance, 1, 1, 24,cc.c3b(21,255,21))
    label_endurance:setAnchorPoint(0,0.5)
    label_endurance:setPosition(435, 65)
    bg:addChild(label_endurance)
    self.infopanel_endurance = label_endurance

    local huifu = Common.finalFont("下一点回复时间：", 1, 1, 16, cc.c3b(205,205,205) )
    huifu:setAnchorPoint(0,0.5)
    huifu:setPosition(340, 35)
    bg:addChild(huifu)
    local endurence_recover = Common.finalFont("", 1, 1, 16, cc.c3b(205,205,205))
    endurence_recover:setAnchorPoint(0,0.5)
    endurence_recover:setPosition(475, 35)
    bg:addChild(endurence_recover)
    self.controls.label_endurance_recover = endurence_recover

end


function MainLayer:showOthersInfo( info, rid )
    local scene = cc.Director:getInstance():getRunningScene()
    local layer = cc.LayerColor:create(cc.c4b(0,0,0,0))
    scene:addChild(layer)

    local size = cc.size(615,409)
    local bg = ccui.ImageView:create("image/ui/img/bg/bg_139.png")
    bg:setPosition(SCREEN_WIDTH*0.5,SCREEN_HEIGHT*0.5)
    bg:setScale9Enabled(true)
    bg:setContentSize(size)
    bg:setScale(0.01)
    layer:addChild(bg)

    local action = cc.Sequence:create({cc.ScaleTo:create(0.1, 1.1),cc.ScaleTo:create(0.1, 1.0)})
    bg:runAction(action)

    local huawen = cc.Sprite:create("image/ui/img/btn/btn_609.png")
    huawen:setPosition(size.width*0.5, size.height*0.5)
    bg:addChild(huawen)

    local top = cc.Sprite:create("image/ui/img/btn/btn_1002.png")
    top:setAnchorPoint(0.5,1)
    top:setPosition(size.width*0.5, size.height-15)
    bg:addChild(top)

    local bottom = ccui.Scale9Sprite:create("image/ui/img/bg/bg_253.png")
    bottom:setContentSize(cc.size(595,75))
    bottom:setAnchorPoint(0.5,0)
    bottom:setPosition(size.width*0.5, 13)
    bg:addChild(bottom)

    local btn_hello = ccui.MixButton:create("image/ui/img/btn/btn_818.png")
    btn_hello:setScale9Size(cc.size(120,56))
    btn_hello:setPosition(size.width*0.5, 50)
    btn_hello:setTitle("结识",24,cc.c3b(238,205,142))
    -- btn_hello:setTitlePos(0.6,0.5)
    -- btn_hello:setChild("image/ui/img/btn/btn_999.png", 0.2, 0.5)
    btn_hello:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            rpc:call("Friend.AddFriend", rid, function(event)
                if event.status == Exceptions.Nil then
                    btn_hello:setStateEnabled(false)
                    application:showFlashNotice("交友申请已经发送给"..info.Name.."，请等待对方回应")
                elseif event.status == Exceptions.EFriendRepeatSendRequest then
                    application:showFlashNotice("交友申请已经发送给"..info.Name.."，请勿重复申请")
                elseif event.status == Exceptions.EFriendAlready then
                    application:showFlashNotice("你和"..info.Name.."已经是好盆友了")
                end
            end)
        end
    end)
    bg:addChild(btn_hello)


    local btn_close = ccui.MixButton:create("image/ui/img/btn/btn_598.png")
    btn_close:setPosition(size.width-15, size.height-15)
    bg:addChild(btn_close)
    btn_close:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            layer:removeFromParent()
            layer = nil
        end
    end)

    local function onTouchBegan(touch, event)
        return true
    end

    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = bg:convertToNodeSpace(touch:getLocation())
        local s = bg:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if not cc.rectContainsPoint(rect, locationInNode) then
            layer:removeFromParent()
            layer = nil
        end

    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)   


    local sp = cc.Sprite:create("image/icon/border/head_bg.png")
    sp:setPosition(75, size.height-85)
    bg:addChild(sp)

    local head = cc.Sprite:create(Common.heroIconImgPath(info.Icon))
    head:setPosition(75, size.height-85)
    bg:addChild(head)


    local head1 = cc.Sprite:create("image/icon/border/Head-portrait001.png")
    head1:setPosition(75, size.height-85)
    bg:addChild(head1)

    local headsize = head1:getContentSize()


    --vip level
    local sprite_vip = cc.Sprite:create("image/ui/img/btn/btn_1139.png")
    sprite_vip:setPosition(headsize.width*0.5-20,0)
    head1:addChild(sprite_vip)

    local vip = Common.finalFont(""..info.VIP, 1, 1, 24, cc.c3b(255,201,60),1)
    vip:setPosition(headsize.width*0.5+20, 0)
    head1:addChild(vip)

    local str = info.Name
    local editbg = cc.Sprite:create("image/ui/img/btn/btn_1001.png")
    editbg:setPosition(size.width*0.38, size.height-50)
    bg:addChild(editbg)

    local editsize = editbg:getContentSize()
    local name = Common.systemFont(str, 1, 1, 24)
    name:setPosition(editsize.width*0.5, editsize.height*0.5-2)
    editbg:addChild(name)

    --level
    
    local label = Common.finalFont("等级：", 1, 1, 24)
    label:setAnchorPoint(0,0.5)
    label:setPosition(150, 300 )
    bg:addChild(label)
        
    local str = info.Level
    local label_level = Common.finalFont(str, 1, 1, 24, cc.c3b(21,255,21))
    label_level:setAnchorPoint(0,0.5)
    label_level:setPosition(230, 300)
    bg:addChild(label_level)

    --gender 1-男 2-女
    
    local label = Common.finalFont("性别：", 1, 1, 24)
    label:setAnchorPoint(0,0.5)
    label:setPosition(344, 300 )
    bg:addChild(label)
        
    local str = info.Gender
    local g = {"男", "女"}
    local label_gender = Common.finalFont(g[str], 1, 1, 22, cc.c3b(21,255,21))
    label_gender:setAnchorPoint(0,0.5)
    label_gender:setPosition(418, 300)
    bg:addChild(label_gender)

    --ID
    local label_Id = Common.finalFont("ID：", 1, 1, 24)
    label_Id:setAnchorPoint(cc.p(0,0.5))
    label_Id:setPosition(cc.p(344,240))
    bg:addChild(label_Id)

    local label_id = Common.finalFont("" .. rid, 1, 1, 24, cc.c3b(21,255,21))
    label_id:setAnchorPoint(cc.p(0,0.5))
    label_id:setPosition(cc.p(418,240))
    bg:addChild(label_id)

   local label = Common.finalFont("帮会：", 1, 1, 24)
   label:setAnchorPoint(0,0.5)
   label:setPosition(150,240 )
   bg:addChild(label)

   local label = Common.finalFont("竞技场：", 1, 1, 24)
   label:setAnchorPoint(0,0.5)
   label:setPosition(150,180 )
   bg:addChild(label)


    local str = "第"..info.ArenaRank.."名"
    if info.ArenaRank == 0 then
        str = "未上榜"
    end
    local label_rank = Common.finalFont(str, 1, 1, 20, cc.c3b(21,255,21))
    label_rank:setAnchorPoint(0,0.5)
    label_rank:setPosition(250,180)
    bg:addChild(label_rank)


    local label = Common.finalFont("服务器：", 1, 1, 24)
    label:setAnchorPoint(0,0.5)
    label:setPosition(150,120 )
    bg:addChild(label)

    local str = GameCache.ServerName
    local label_server = Common.finalFont(str, 1, 1, 20, cc.c3b(21,255,21))
    label_server:setAnchorPoint(0,0.5)
    label_server:setPosition(250,120)
    bg:addChild(label_server)

end

function MainLayer:createOthersPanel( rid, name, icon )
    local scene = cc.Director:getInstance():getRunningScene()
    local layer = cc.LayerColor:create(cc.c4b(0,0,0,150))
    scene:addChild(layer)

    local bg = cc.Sprite:create("image/ui/img/btn/btn_1090.png")
    bg:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)
    layer:addChild(bg)
    bg:setScale(0.1)
    bg:runAction(cc.Sequence:create( cc.ScaleTo:create(0.1, 1.2), cc.ScaleTo:create(0.05, 1.0) ))

    local bgsize = bg:getContentSize()

    local info = {ID = icon}
    local icon1 = GoodsInfoNode.new(BaseConfig.GOODS_HERO, info)
    icon1:setTouchEnable(false)
    icon1:setPosition(bgsize.width*0.5, bgsize.height*0.5)
    bg:addChild(icon1)

    local player_name = Common.systemFont(name,bgsize.width*0.5, bgsize.height*0.5-50, 22, nil, 1)
    bg:addChild(player_name)


    local btn_info = ccui.MixButton:create("image/ui/img/btn/btn_1094.png")
    btn_info:setPosition(bgsize.width*0.1, bgsize.height*0.9)
    bg:addChild(btn_info)
    btn_info:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            rpc:call("Avatar.PlayerInfo", rid, function(event)
                if event.status == Exceptions.Nil and event.result ~= nil then
                    self:showOthersInfo(event.result, rid)
                end
            end)
        end
    end)
    btn_info:setScale(0.1)
    btn_info:setVisible(false)
    btn_info:runAction(cc.Sequence:create( cc.DelayTime:create(0.2), cc.Show:create(), cc.ScaleTo:create(0.1, 1.2), cc.ScaleTo:create(0.05, 1.0) ))

    local btn_hehe = ccui.MixButton:create("image/ui/img/btn/btn_1091.png")
    btn_hehe:setPosition(bgsize.width*0.9, bgsize.height*0.9)
    bg:addChild(btn_hehe)
    btn_hehe:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            rpc:call("Friend.AddFriend", rid, function(event)
                if event.status == Exceptions.Nil then
                    application:showFlashNotice("交友申请已经发送给"..name.."，请等待对方回应")
                elseif event.status == Exceptions.EFriendRepeatSendRequest then
                    application:showFlashNotice("交友申请已经发送给"..name.."，请勿重复申请")
                elseif event.status == Exceptions.EFriendAlready then
                    application:showFlashNotice("你和"..name.."已经是好盆友了")

                end
            end)
        end
    end)
    btn_hehe:setScale(0.1)
    btn_hehe:setVisible(false)
    btn_hehe:runAction(cc.Sequence:create( cc.DelayTime:create(0.35), cc.Show:create(), cc.ScaleTo:create(0.1, 1.2), cc.ScaleTo:create(0.05, 1.0) ))

    local btn_chat = ccui.MixButton:create("image/ui/img/btn/btn_1093.png")
    btn_chat:setPosition(bgsize.width*0.9, bgsize.height*0.1)
    bg:addChild(btn_chat)
    btn_chat:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            -- if BaseConfig.targetPlatform == cc.PLATFORM_OS_IPHONE or BaseConfig.targetPlatform == cc.PLATFORM_OS_IPAD or BaseConfig.targetPlatform == cc.PLATFORM_OS_ANDROID  then
            --     -- 还要去取这个人的 sdk ID
            --     -- self:showChatLayer(name,name)
            --     if GameCache.Avatar.IsFobidden then
            --         application:showFlashNotice("你已被禁言！")
            --         return
            --     end

            --     local yvtool = yv.YVTool:getInstance()
            --     yvtool:getCPUserInfo(CHAT_SERVER_APPID, tostring(rid))
            --     layer:removeFromParent()
            --     layer = nil
                
            -- else
                application:showFlashNotice("聊天系统暂时关闭！")
            -- end
        end
    end)
    btn_chat:setScale(0.1)
    btn_chat:setVisible(false)
    btn_chat:runAction(cc.Sequence:create( cc.DelayTime:create(0.5), cc.Show:create(), cc.ScaleTo:create(0.1, 1.2), cc.ScaleTo:create(0.05, 1.0) ))

    local btn_hero = ccui.MixButton:create("image/ui/img/btn/btn_1092.png")
    btn_hero:setPosition(bgsize.width*0.1, bgsize.height*0.1)
    bg:addChild(btn_hero)
    btn_hero:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            rpc:call("Hero.GetFilterLevelHeroEx", {RID = rid, MinStarLevel = 5}, function ( event )
                if event.status == Exceptions.Nil and event.result ~= nil then
                    local herolayer = require("scene.main.hero.FriendAllHeroLayer").new(event.result)
                    scene:addChild(herolayer)
                elseif not event.result then
                    application:showFlashNotice("不好意思，您查看的玩家暂时没有4星及以上星将!")
                end
                
            end)
        end
    end)    
    btn_hero:setScale(0.1)
    btn_hero:setVisible(false)
    btn_hero:runAction(cc.Sequence:create( cc.DelayTime:create(0.65), cc.Show:create(), cc.ScaleTo:create(0.1, 1.2), cc.ScaleTo:create(0.05, 1.0) ))

    local function onTouchBegan(touch, event)
        return true
    end

    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = bg:convertToNodeSpace(touch:getLocation())
        local s = bg:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if not cc.rectContainsPoint(rect, locationInNode) then
            layer:removeFromParent()
            layer = nil
        end

    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)   
end

function MainLayer:onEnterTransitionFinish()
    MainLayer.super.onEnterTransitionFinish(self) 

    if self.isEnterScene == true then
        self.isEnterScene = false
    end
    self:updateGameData()
    if not self.isCreateOther then
        application:dispatchCustomEvent(AppEvent.UI.MainLayer.RefreshOthers,true)
        self.isCreateOther = true
    else
        if #self.othersData ~= 0 then
            self:updateOthers()
        end
    end

    Common.OpenGuideLayer({1,2,3,4,5,6,7,8})
    Common.OpenSystemLayer( {2,3,4,5,6,7,8,9,10,11,12} )

    if self.firstEnterScene and self.activity and not GameCache.NewbieGuide.State then
        Common.addTopSwallowLayer()    -- 创建屏蔽层
        self:createActivityScene()
        Common.removeTopSwallowLayer()   --移除屏蔽层
    end
end

function MainLayer:updateGameData()
    -- 创建地图背景
    self:createBackgroup()
    self:createEntry()

    local exp = GameCache.Avatar.Exp
    local maxexp = BaseConfig.GetRoleExp(GameCache.Avatar.Level)
    self.expbar:setScaleX(exp/maxexp)
    self.exp_label:setString(exp.."/"..maxexp)
    self.controls.avatar_level:setString(""..GameCache.Avatar.Level)
    self.controls.avatar_viplevel:setString(""..GameCache.Avatar.VIP)

    if GameCache.Avatar.VIP < 15 then
        self.controls.avatar_head:setTexture(Head_Texture_VIP[math.floor(GameCache.Avatar.VIP/5)+1])
    else
        self.controls.avatar_head:setTexture("image/ui/img/bg/head4.png")
    end

    if not self.controls.avatar_figure then
        return
    end

    if GameCache.Avatar.Level >= BaseConfig.OpenSystemLevel.home then  --家园
        self.btn_jiayuan:setVisible(true)
    end
end

function MainLayer:onCleanup()
    if self.data.deaccelerateScrollingEntryID ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.data.deaccelerateScrollingEntryID)
        self.data.deaccelerateScrollingEntryID = nil
    end

    for _, l in ipairs(self.eventListeners) do
        application:removeEventListener(l)
    end   
    if self.scheduler_power_timer ~= nil then
        scheduler:unscheduleScriptEntry(self.scheduler_power_timer)
    end
    if self.scheduler_endurance_timer ~= nil then
        scheduler:unscheduleScriptEntry(self.scheduler_endurance_timer)
    end

    if BaseConfig.targetPlatform == cc.PLATFORM_OS_IPHONE or BaseConfig.targetPlatform == cc.PLATFORM_OS_IPAD or BaseConfig.targetPlatform == cc.PLATFORM_OS_ANDROID  then
        local yvtool = yv.YVTool:getInstance()
        yvtool:cpLogout()
        if self.yvsdkScheduler then
            scheduler:unscheduleScriptEntry(self.yvsdkScheduler)
        end
    end
end

function MainLayer:onEnter()
    

    if not audio.isMusicPlaying() then
        Common.playMusic("audio/music/background.mp3", true)
    end

end

function MainLayer:onExitTransitionStart()
     MainLayer.super.onExitTransitionStart(self)
     
    if self.isEnterScene == false then
        self.isEnterScene = true
    end

    if self.otherplayers ~= nil then
        for k,v in pairs(self.otherplayers) do
            scheduler:unscheduleScriptEntry(v.scheduler)
            v:removeFromParent()
            v = nil
        end
        self.otherplayers = {}
    end

    if nil ~= self.updateloadingScheduler then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.updateloadingScheduler)
    end

    if nil ~= self.updateOthersScheduler then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.updateOthersScheduler)
    end

    local heroX,heroY = self.controls.avatar_figure:getPosition()
    local bgX,bgY = self.bg:getPosition()
    self.heroPosition = cc.p(heroX, heroY)
    self.bgPosition = cc.p(bgX, bgY)

    if self.firstEnterScene then
        self.firstEnterScene = false
    end
end

function MainLayer:onExit()
    self.controls.avatar_figure:setAnimation(0, "idle", true)

    self.data.globalMap = nil
    for _,mapChild in ipairs(self.map:getChildren()) do
        mapChild:removeFromParent()
    end

    local mapChildren = self.bg:getChildren()
    local mapChildrenCount = self.bg:getChildrenCount()
    if mapChildrenCount > 0 then
        for _,mapChild in ipairs(mapChildren) do
            mapChild:removeFromParent()
        end
    end

    self.bg:removeFromParent()
    self.bg = nil

    self.controls.globalScrollview:removeFromParent()
    self.controls.globalScrollview = nil

    self.controls.mailAlert = nil
    self.controls.energyAlert = nil
end

return MainLayer
