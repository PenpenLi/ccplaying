local TransportLayer = class("TransportLayer", BaseLayer)
local scheduler = cc.Director:getInstance():getScheduler()
local messagebox = require("tool.helper.MessageBoxLayer")
local EffectManager = require("tool.helper.Effects")
local commonLayer = require("tool.helper.CommonLayer")

local horseName = {
    "白龙马",
    "沙僧",
    "猪八戒",
    "孙悟空",
    "唐僧",
}

local horseTexture = {
    "image/ui/img/btn/btn_1216.png",
    "image/ui/img/btn/btn_1217.png",
    "image/ui/img/btn/btn_1218.png",
    "image/ui/img/btn/btn_1219.png",
    "image/ui/img/btn/btn_1220.png",
}

local horseBackTexture = {
    "image/ui/img/btn/btn_799.png",
    "image/ui/img/btn/btn_798.png",
    "image/ui/img/btn/btn_797.png",
    "image/ui/img/btn/btn_796.png",
    "image/ui/img/btn/btn_795.png",
}

local dstName = {
    "锁仙岛",
    "离火岛",
}


function TransportLayer:ctor()
    TransportLayer.super.ctor(self)

    --receive needed data
    self.constance = {}
    self.curDst = 1
    self.curDstGain = nil
    -- self.curCostEndur = 5
    self.curFriendRID = ""
    self.curFriendName = ""
    self.vehicles = {}
    self.vehiclesBtn = {}
    self.vehicleLayerTimer = {}
    self.transportInfo = {}
    self.recordInfo = {}
    self.friendTable = {}

    self.showAllVehicle = false
    
    self:receiveConstance()
    

    self:createFixedUI()

    self.flexLayer = nil

    local function onTouchBegan(touch, event)
        return true
    end
    local function onTouchEnded(touch, event)

    end
    local listener1 = cc.EventListenerTouchOneByOne:create()
    listener1:setSwallowTouches(true)
    listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener1:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, self)
end

function TransportLayer:createFixedUI()

    local fixedLayer = cc.Layer:create()
    self:addChild(fixedLayer)


    -- local bg1 = cc.Sprite:create("dummy/yunbiao.jpg")
    -- bg1:setAnchorPoint(0,0)
    -- fixedLayer:addChild(bg1)


    -- local bgsize = bg1:getContentSize()
    -- local bg2 = cc.Sprite:create("dummy/yunbiao.jpg")
    -- bg2:setAnchorPoint(0,0)
    -- bg2:setPosition(bgsize.width, 0)
    -- fixedLayer:addChild(bg2)

    
    local scrollview = ccui.ScrollView:create()
    scrollview:setTouchEnabled(true)
    scrollview:setContentSize(cc.size(SCREEN_WIDTH, SCREEN_HEIGHT))    
    scrollview:setDirection(ccui.ScrollViewDir.horizontal)
    scrollview:setInnerContainerSize(cc.size(SCREEN_WIDTH*2, SCREEN_HEIGHT)) 
    fixedLayer:addChild(scrollview)
    self.scrollview = scrollview

    local bg1 = cc.Sprite:create("dummy/yunbiao.jpg")
    bg1:setAnchorPoint(0,0)
    scrollview:addChild(bg1)


    local bgsize = bg1:getContentSize()
    local bg2 = cc.Sprite:create("dummy/yunbiao.jpg")
    bg2:setAnchorPoint(0,0)
    bg2:setPosition(bgsize.width, 0)
    scrollview:addChild(bg2)
    

    local dstItem1 = cc.Sprite:create("image/ui/img/bg/in_02.png")
    dstItem1:setAnchorPoint(1,0.5)
    dstItem1:setPosition(SCREEN_WIDTH-100,SCREEN_HEIGHT*0.5)
    scrollview:addChild(dstItem1)
    local label = Common.finalFont("锁仙岛",1,1,20,nil,1)
    label:setPosition(dstItem1:getPositionX(),dstItem1:getPositionY()-40)
    scrollview:addChild(label)

    local dstItem2 = cc.Sprite:create("image/ui/img/bg/in_01.png")
    dstItem2:setAnchorPoint(1,0.5)
    dstItem2:setPosition(SCREEN_WIDTH*2-100,SCREEN_HEIGHT*0.5)
    scrollview:addChild(dstItem2)
    local label = Common.finalFont("离火岛",1,1,20,nil,1)
    label:setPosition(dstItem2:getPositionX(),dstItem2:getPositionY()-40)
    scrollview:addChild(label)

    local container = scrollview:getInnerContainer()

    local function bgmove( delta )

        bg1:setPosition(bg1:getPositionX()-1, 0)
        bg2:setPosition(bg2:getPositionX()-1, 0)

        local x = container:getPositionX()

        if bg1:getPositionX()+x <= -bgsize.width then
            bg1:setPosition(bg2:getPositionX()+bgsize.width, 0)
        end
        if bg2:getPositionX()+x <= -bgsize.width then
            bg2:setPosition(bg1:getPositionX()+bgsize.width, 0)
        end

        if bg1:getPositionX()+x > bgsize.width then
            bg1:setPosition(bg2:getPositionX()-bgsize.width, 0)
        end
        if bg2:getPositionX()+x > bgsize.width then
            bg2:setPosition(bg1:getPositionX()-bgsize.width, 0)
        end
    end

    self:scheduleUpdateWithPriorityLua(bgmove,0)


    local topBack = cc.Sprite:create("image/ui/img/bg/bg_196.png")
    topBack:setAnchorPoint(0.5,1)
    topBack:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT)
    fixedLayer:addChild(topBack)

    local bottomBack = cc.Sprite:create("image/ui/img/bg/bg_196.png")
    bottomBack:setFlippedY(true)
    bottomBack:setAnchorPoint(0.5,0)
    bottomBack:setPosition(SCREEN_WIDTH*0.5, 0)
    fixedLayer:addChild(bottomBack)

    local pay = require("scene.main.PayListNode").new(GameCache.Avatar.PhyPower, GameCache.Avatar.MaxPhyPower,
        GameCache.Avatar.Endurance, GameCache.Avatar.MaxEndurance,
        GameCache.Avatar.Coin, GameCache.Avatar.Gold)
    local size = pay:getContentSize()
    pay:setPosition(SCREEN_WIDTH*0.5 - size.width * 0.5, SCREEN_HEIGHT - 60)
    fixedLayer:addChild(pay)

    local btn_close = createMixSprite("image/ui/img/btn/btn_598.png")
    btn_close:setPosition(SCREEN_WIDTH*0.95, SCREEN_HEIGHT*0.9)
    btn_close:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            cc.Director:getInstance():popScene()
        end
    end)
    fixedLayer:addChild(btn_close)

    local btnsize = cc.size(135,60)
    local btn_adjust = ccui.MixButton:create("image/ui/img/btn/btn_1244.png")
    -- btn_adjust:setScale9Size(btnsize)
    btn_adjust:setTitle("防守阵容",20, cc.c3b(243,207,137),2,cc.c3b(77,36,0))
    btn_adjust:setTitlePos(0.5,0)
    btn_adjust:setPosition(SCREEN_WIDTH*0.7, 100)
    btn_adjust:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            rpc:call("Vehicle.GetDefFormation", {}, function(event)
                if event.status == Exceptions.Nil then
                    application:pushScene("form.BattleFormScene", GameCache.FORM_TYPE_VEHICLE_DEFENSE, {attackerForm = event.result})
                end
            end)
        end
    end)
    fixedLayer:addChild(btn_adjust)

    local btn_hide = ccui.MixButton:create("image/ui/img/btn/btn_1246.png")
    -- btn_hide:setScale9Size(btnsize)
    btn_hide:setTitlePos(0.5,0)
    btn_hide:setTitle("隐藏低级",20, cc.c3b(243,207,137),2,cc.c3b(77,36,0))
    btn_hide:setPosition(SCREEN_WIDTH*0.15, 80)
    btn_hide:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if self.showAllVehicle then
                for k,v in pairs(self.vehiclesBtn) do
                    v:setVisible(true)
                end
                btn_hide:setTitleText("隐藏低级")
                self.showAllVehicle = false
            else
                for k,v in pairs(self.vehiclesBtn) do
                    if v.quality == 1 then
                        v:setVisible(false)
                    end
                end
                btn_hide:setTitleText("全部显示")
                self.showAllVehicle = true                
            end
        end
    end)
    self.btn_hide = btn_hide
    fixedLayer:addChild(btn_hide)


    local btn_change = ccui.MixButton:create("image/ui/img/btn/btn_1245.png")
    -- btn_change:setScale9Size(btnsize)
    btn_change:setTitlePos(0.5,0)
    btn_change:setTitle("换一批",20, cc.c3b(243,207,137),2,cc.c3b(77,36,0))
    btn_change:setPosition(SCREEN_WIDTH*0.3, 100)
    btn_change:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:receiveTransportInfo()
        end
    end)
    fixedLayer:addChild(btn_change)



    local btn_bless = ccui.MixButton:create("image/ui/img/btn/btn_1243.png")
    btn_bless:setTitle("菩萨保佑",20, cc.c3b(243,207,137),2,cc.c3b(77,36,0))
    btn_bless:setTitlePos(0.5,0)
    btn_bless:setPosition(SCREEN_WIDTH*0.85, 80)
    btn_bless:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:addChild(self:createBlessUI())
        end
    end)
    fixedLayer:addChild(btn_bless)
    -- local label = Common.finalFont("菩萨保佑",1,1,16,nil,1)
    -- label:setPosition(btn_bless:getPositionX(),btn_bless:getPositionY()-40)
    -- fixedLayer:addChild(label)



    local btn_record = ccui.MixButton:create("image/ui/img/btn/btn_818.png")
    btn_record:setScale9Size(cc.size(155,60))
    btn_record:setPosition(SCREEN_WIDTH*0.15, SCREEN_HEIGHT*0.8)
    btn_record:setChild("image/ui/img/btn/btn_1076.png", 0.2, 0.5)
    btn_record:setTitle("取经日志", 20, cc.c3b(243,207,137))
    btn_record:setTitlePos(0.65,0.5)
    btn_record:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:receiveHistory()
        end
    end)
    fixedLayer:addChild(btn_record)
    -- local label = Common.finalFont("日志", 1, 1,16,nil,1)
    -- label:setPosition(btn_record:getPositionX(),btn_record:getPositionY()-40)
    -- fixedLayer:addChild(label)

end

function TransportLayer:refreshVehicleLayer(  )
    local function vehicleLayer(  )
        for k,v in pairs(self.vehicleLayerTimer) do
            scheduler:unscheduleScriptEntry(v)
        end
        self.vehiclesBtn = {}
        self.showAllVehicle = false
        self.btn_hide:setTitleText("隐藏低级")
        if self.vehicles ~= nil then
            for i=1,#self.vehicles do
                local btn = nil
                if self.vehicles[i].RID ~= "" then
                    btn = ccui.Button:create(horseTexture[self.vehicles[i].Quality])
                    btn.quality = self.vehicles[i].Quality

                    local yun = cc.Sprite:create("image/ui/img/btn/btn_051.png")
                    yun:setPosition(btn:getContentSize().width*0.5, 10)
                    btn:addChild(yun)

                    table.insert(self.vehiclesBtn, btn)
                    
                else
                    btn = ccui.Button:create(horseTexture[self.vehicles[i].Quality])
                    local yun = cc.Sprite:create("image/ui/img/btn/btn_052.png")
                    yun:setPosition(btn:getContentSize().width*0.5, 10)
                    btn:addChild(yun)
                end

                local x = 50
                local y = math.random(150,350)

                local distance = 0
                if self.vehicles[i].Dst == 1 then
                    local total_time = self.constance.DST1_TRANSPORT_TIME or 600
                    local percent = self.vehicles[i].CountDown / total_time
                    distance = percent * (SCREEN_WIDTH - 200)
                    x = x + (SCREEN_WIDTH - 200) - distance
                    
                elseif self.vehicles[i].Dst == 2 then
                    local total_time = self.constance.DST2_TRANSPORT_TIME or 1800
                    local percent = self.vehicles[i].CountDown / total_time
                    distance = percent * (SCREEN_WIDTH*2 - 200)
                    x = x + (SCREEN_WIDTH*2 - 200) - distance
                end

                btn.timer = scheduler:scheduleScriptFunc(function (  )
                    btn.count_down = btn.count_down - 1
                end, 1, false)

                table.insert(self.vehicleLayerTimer, btn.timer)

                local action = cc.MoveBy:create(self.vehicles[i].CountDown, cc.p(distance, 0))
                btn:setPosition(x,y)
                btn:runAction(cc.Sequence:create(action, cc.FadeOut:create(0.5) ))
                btn.count_down = self.vehicles[i].CountDown


                -- 

                btn:addTouchEventListener(function ( sender,eventType )
                    if eventType == ccui.TouchEventType.ended then
                        if btn.count_down < 120  then
                            application:showFlashNotice("已到达保护区，不能偷看人家的经书了哦")
                            return
                        end
                        self:addChild(self:createMessageUI(self.vehicles[i]))
                    end
                end)    
                self.vehicleLayer:addChild(btn, SCREEN_HEIGHT - btn:getPositionY())
            end
        end

    end

    if self.vehicleLayer ~= nil then
        self.vehicleLayer:removeAllChildren()
        vehicleLayer()

    else
        self.vehicleLayer = cc.Layer:create()
        vehicleLayer()
        self.scrollview:addChild(self.vehicleLayer)
    end    
end

function TransportLayer:createFlexUI()
    if self.flexLayer ~= nil then
        self.flexLayer:removeAllChildren()
    else
        self.flexLayer = cc.Layer:create()
        self:addChild(self.flexLayer)
    end    

    local function acceptGain(gains)
        local layer = cc.Layer:create()

        local panel = ccui.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
        panel:setContentSize(cc.size(520, 300))
        panel:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
        layer:addChild(panel)
        local panelSize = panel:getContentSize()
    
        local title = cc.Sprite:create("image/ui/img/bg/bg_174.png")
        title:setPosition(panelSize.width * 0.5, panelSize.height-5)
        panel:addChild(title)
        -- local dian = cc.Sprite:create("image/ui/img/btn/btn_652.png")
        -- dian:setPosition(panelSize.width * 0.3, panelSize.height-20)
        -- panel:addChild(dian)
        -- dian = cc.Sprite:create("image/ui/img/btn/btn_652.png")
        -- dian:setPosition(panelSize.width * 0.7, panelSize.height-20)
        -- panel:addChild(dian)
        local dian = cc.Sprite:create("image/ui/img/btn/btn_996.png")
        dian:setPosition(panelSize.width * 0.5, panelSize.height-5)
        panel:addChild(dian)
    
        local label = Common.finalFont("取经成功，获得奖励",panelSize.width * 0.5, panelSize.height-70, 26 )
        panel:addChild(label)

        -- local icon_coin = cc.Sprite:create("image/ui/img/btn/btn_035.png")
        -- icon_coin:setPosition(panelSize.width*0.35, panelSize.height*0.6)
        -- panel:addChild(icon_coin)

        -- local label_coin = Common.finalFont(""..gains.Coin, panelSize.width*0.45, panelSize.height*0.6)
        -- label_coin:setAnchorPoint(0,0.5)
        -- panel:addChild(label_coin)

        -- local icon_honor = cc.Sprite:create("image/ui/img/btn/btn_357.png")
        -- icon_honor:setPosition(panelSize.width*0.35, panelSize.height*0.45)
        -- panel:addChild(icon_honor)

        -- local label_honor = Common.finalFont(""..gains.Honor, panelSize.width*0.45, panelSize.height*0.45)
        -- label_honor:setAnchorPoint(0,0.5)
        -- panel:addChild(label_honor)
        local goodsCoin = {
            Type = 4,
            ID = 1002,
            Num = gains.Coin
        }

        local icon_coin = Common.getGoods(goodsCoin,true,BaseConfig.GOODS_MIDDLETYPE)
        icon_coin:setPosition(panelSize.width*0.5, panelSize.height*0.5)
        panel:addChild(icon_coin)

        if gains.Surprise and #gains.Surprise ~= 0 then

            local x = panelSize.width*0.5 - 50 * #gains.Surprise
            icon_coin:setPosition(x, panelSize.height*0.5)

            for i=1, #gains.Surprise do
                local icon = Common.getGoods(gains.Surprise[i],true,BaseConfig.GOODS_MIDDLETYPE)
                icon:setPosition(x+100*i,panelSize.height*0.5)
                icon:setScale(0.1)
                panel:addChild(icon)
                icon:runAction(cc.Sequence:create( cc.DelayTime:create(i*0.1), cc.ScaleTo:create(0.05, 1.2), cc.ScaleTo:create(0.05, 1) ))
            end
            EffectManager:CreateAnimation(panel, panelSize.width*0.5, panelSize.height*0.5, nil, 48, false)
        end
    
        local btnBG = cc.Sprite:create("image/ui/img/btn/btn_811.png")
        btnBG:setPosition(panelSize.width * 0.5, 50)
        panel:addChild(btnBG)

        local btn_sure = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(120, 60))
        btn_sure:setCircleFont("确定", 1, 1, 25, cc.c3b(248, 216, 136), 1)
        btn_sure:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
        btn_sure:setPosition(panelSize.width * 0.5, 50)
        panel:addChild(btn_sure)
        btn_sure:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                self:receiveTransportInfo()
                layer:removeFromParent()
                layer = nil
            end
        end)
    
        local function onTouchBegan(touch, event)
            return true
        end
        local function onTouchEnded(touch, event)
            -- local target = event:getCurrentTarget()
            -- local locationInNode = target:convertToNodeSpace(touch:getLocation())
            -- local s = panel:getContentSize()
            -- local rect = cc.rect(0, 0, s.width, s.height)
    
            -- if not cc.rectContainsPoint(rect, locationInNode) then
            --     layer:removeFromParent()
            --     layer = nil
            -- end
        end
        local listener = cc.EventListenerTouchOneByOne:create()
        listener:setSwallowTouches(true)
        listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
        listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
        local eventDispatcher = self:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)
        return layer
    end


    local function receiveTransportGain(  )

        rpc:call("Vehicle.AcceptGain",nil, function ( event )
            if event.status == Exceptions.Nil and event.result ~= nil then
                local gainShow = acceptGain(event.result)
                self:addChild(gainShow)
                -- messagebox.show("收益","获得经书一大箱\n大乘小乘皆是佛\n幻化泡影终成梦\n唯有饮者留其名", {"领取"}, function (a, b, c)
                --     self:receiveTransportInfo()
                --     return
                -- end)
            end
        end)
    end

    if not self.transportInfo.InTrans.IsValid then
        local btn_start = ccui.MixButton:create("image/ui/img/btn/btn_970.png")
        btn_start:setChild("image/ui/img/btn/btn_1247.png", 0.5, 0.6)
        btn_start:setPosition(SCREEN_WIDTH*0.5, 110)
        btn_start:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                self:addChild(self:createOptionUI())
            end
        end)
        self.flexLayer:addChild(btn_start)

        local start_texiao = EffectManager:CreateAnimation(self.flexLayer,SCREEN_WIDTH*0.5, 110,nil, 3, true )
    else
        local vehicleConfig = BaseConfig.GetVehicle(self.transportInfo.InTrans.Quality)
        -- CCLog("-----",self.transportInfo.CurQuality)

        local iconbg = cc.Sprite:create("image/ui/img/bg/bg_290.png")
        iconbg:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.8)
        self.flexLayer:addChild(iconbg)

        local iconbgsize = iconbg:getContentSize()

        -- 展示运镖收益
        local label_coin = Common.finalFont("",1,1,18, cc.c3b(245,228,208))
        label_coin:setString("预计收益：")
        label_coin:setAnchorPoint(0,0.5)
        label_coin:setPosition(30, iconbgsize.height*0.7)
        iconbg:addChild(label_coin)

        local icon = cc.Sprite:create("image/ui/img/btn/btn_035.png")
        icon:setAnchorPoint(0,0.5)
        icon:setPosition(110, iconbgsize.height*0.7)
        iconbg:addChild(icon)

        local label_coin = Common.finalFont("",1,1,18, cc.c3b(251,156,54))
        label_coin:setString("".. self.transportInfo.InTrans.Coin)
        label_coin:setAnchorPoint(0,0.5)
        label_coin:setPosition(150, iconbgsize.height*0.7)
        iconbg:addChild(label_coin)

        -- local label_honor = Common.finalFont("",1,1,18,cc.c3b(251,229,192),1)   
        -- label_honor:setAnchorPoint(0,0.5)     
        -- label_honor:setString("荣誉：")
        -- label_honor:setPosition(255, iconbgsize.height*0.7)
        -- iconbg:addChild(label_honor)

        -- local label_honor = Common.finalFont("",1,1,18,cc.c3b(251,156,54),1)    
        -- label_honor:setAnchorPoint(0,0.5)                 
        -- label_honor:setString("".. self.transportInfo.InTrans.Honor)
        -- label_honor:setPosition(320, iconbgsize.height*0.7)
        -- iconbg:addChild(label_honor)

        local label_surprise = Common.finalFont("惊喜收益：",1,1,18,cc.c3b(245,228,208))  
        label_surprise:setAnchorPoint(0,0.5)     
        label_surprise:setPosition(255, iconbgsize.height*0.7)    
        iconbg:addChild(label_surprise)

        local label_surprise = Common.finalFont("",1,1,18,cc.c3b(229,150,0))    
        label_surprise:setAnchorPoint(0,0.5)
        label_surprise:setPosition(355, iconbgsize.height*0.7)    
        iconbg:addChild(label_surprise)
        
        if vehicleConfig.surprise ~= 0 then
            label_surprise:setString("可能有")
        else
            label_surprise:setString("无")
        end
        
        local label_protect = Common.finalFont("",1,1,18,cc.c3b(245,228,208))    
        label_protect:setAnchorPoint(0,0.5)    
        label_protect:setString("护送仙友：")
        label_protect:setPosition(30, iconbgsize.height*0.25)
        iconbg:addChild(label_protect)

        local label_protect = Common.systemFont("",1,1,18,cc.c3b(229,150,0))     
        label_protect:setAnchorPoint(0,0.5)   
        label_protect:setString("".. self.transportInfo.InTrans.FriendName)
        label_protect:setPosition(135, iconbgsize.height*0.25)
        iconbg:addChild(label_protect)


        local label_bg1 = cc.Sprite:create("image/ui/img/btn/btn_1116.png")
        label_bg1:setOpacity(150)
        label_bg1:setPosition(SCREEN_WIDTH*0.5, 110)
        self.flexLayer:addChild(label_bg1)

         local label_bg2 = cc.Sprite:create("image/ui/img/btn/btn_1116.png")
         label_bg2:setOpacity(150)
        label_bg2:setPosition(SCREEN_WIDTH*0.5, 65)
        self.flexLayer:addChild(label_bg2)
       
       local label_size = label_bg1:getContentSize()

        local label = Common.finalFont("被劫数",1,1,20)
        -- label:enableOutline(cc.c4b(65,26,1,255), 1)
        label:setAnchorPoint(0,0.5)
        label:setPosition(40, label_size.height*0.5)
        label_bg2:addChild(label)

        local icon = cc.Sprite:create("image/ui/img/btn/btn_670.png")
        icon:setPosition(label_size.width*0.5, label_size.height*0.5)
        label_bg2:addChild(icon)
    
        local label = Common.finalFont(""..self.transportInfo.InTrans.AtkedCount,1,1,22, cc.c3b(229,150,0))
        -- label:enableOutline(cc.c4b(65,26,1,255), 1)
        -- label:setAnchorPoint(0,0.5)
        label:setPosition(200, label_size.height*0.5)
        label_bg2:addChild(label)


        local label = Common.finalFont("倒计时",1,1,20)
        -- label:enableOutline(cc.c4b(65,26,1,255), 1)
        label:setAnchorPoint(0,0.5)
        label:setPosition(40, label_size.height*0.5)
        label_bg1:addChild(label)

        local icon = cc.Sprite:create("image/ui/img/btn/btn_1123.png")
        icon:setPosition(label_size.width*0.5, label_size.height*0.5)
        label_bg1:addChild(icon)
    
        local label_time = Common.finalFont("",1,1,22, cc.c3b(229,150,0))
        label_time:setPosition(200, label_size.height*0.5)
        label_bg1:addChild(label_time)

        if self.transportInfo.InTrans.CountDown > 0 then
            if self.scheduler_timer ~= nil then
                scheduler:unscheduleScriptEntry(self.scheduler_timer)
            end
            local str_time = Common.timeFormat(self.transportInfo.InTrans.CountDown)
            self.scheduler_timer = scheduler:scheduleScriptFunc(function (  )
                local str_time = Common.timeFormat(self.transportInfo.InTrans.CountDown)
                label_time:setString(""..str_time)
                self.transportInfo.InTrans.CountDown = self.transportInfo.InTrans.CountDown - 1
                if self.transportInfo.InTrans.CountDown == -1 then
                    scheduler:unscheduleScriptEntry(self.scheduler_timer)
                    receiveTransportGain()
                end
            end, 1, false)
        
        else
            receiveTransportGain()

        end
    end
end

function TransportLayer:createBlessUI()
    local layer = cc.Layer:create()
    local layerColor = cc.LayerColor:create(cc.c4b(0,0,0,125))
    layer:addChild(layerColor)


    local panelsize = cc.size(732,490)
    local panel = ccui.ImageView:create("image/ui/img/bg/bg_139.png")
    panel:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)
    -- panel:setAnchorPoint(0.5,0)
    panel:setScale9Enabled(true)
    panel:setContentSize(panelsize)
    layer:addChild(panel)

    local titlebg = cc.Sprite:create("image/ui/img/bg/bg_174.png")
    titlebg:setPosition(panelsize.width*0.5, panelsize.height-10)
    panel:addChild(titlebg)

    local title = cc.Sprite:create("image/ui/img/btn/btn_659.png")
    title:setPosition(panelsize.width*0.5, panelsize.height-10)
    panel:addChild(title)

    local btn_close = createMixSprite("image/ui/img/btn/btn_598.png")
    btn_close:setPosition(panelsize.width-10, panelsize.height-10)
    btn_close:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            layer:removeFromParent()
            layer = nil
        end
    end)
    panel:addChild(btn_close)

    local iconbg = cc.Sprite:create("image/ui/img/bg/bg_157.png")
    iconbg:setAnchorPoint(0.5,1)
    iconbg:setPosition(140, panelsize.height-25)
    panel:addChild(iconbg)

    local iconbgsize = iconbg:getContentSize()

    local guang = cc.Sprite:create("image/ui/img/btn/btn_1175.png")
    guang:setPosition(iconbgsize.width*0.45, iconbgsize.height*0.7)
    guang:setScale(0.8)
    iconbg:addChild(guang)
    guang:runAction( cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(1, 125), cc.FadeTo:create(1, 255))))

    local icon = cc.Sprite:create("image/ui/img/btn/btn_1176.png")
    icon:setPosition(iconbgsize.width*0.5, iconbgsize.height*0.5)
    icon:setScale(0.9)
    iconbg:addChild(icon)

    local label = Common.finalFont("观音菩萨", 1, 1,22)
    label:setColor(cc.c3b(247,241,230))
    label:setPosition(iconbgsize.width*0.5, 300)
    iconbg:addChild(label)

    local str = "香火等级  "..self.transportInfo.God.Level
    local label_praylevel = Common.finalFont(str, 1, 1,18)
    label_praylevel:setColor(cc.c3b(247,241,230))
    label_praylevel:setPosition(iconbgsize.width*0.5, 35)
    iconbg:addChild(label_praylevel)   

    -- 进度条
    local barbgsize = cc.size(182,18)
    local barbg = ccui.ImageView:create("image/ui/img/btn/btn_618.png")
    barbg:setPosition(140,105)
    barbg:setScale9Enabled(true)
    barbg:setContentSize(barbgsize)
    panel:addChild(barbg)


    local maxExp = BaseConfig.GetGodExp(self.transportInfo.God.Level)
    local currExp = self.transportInfo.God.Exp
    -- local bar = ccui.LoadingBar:create("image/ui/img/btn/btn_243.png")3
    -- bar:setPosition(barbgsize.width*0.5, barbgsize.height*0.5)
    -- bar:setPercent(currExp/maxExp*100)
    -- iconbg:addChild(bar)
    local bar = ccui.ImageView:create("image/ui/img/btn/btn_619.png")
    bar:setScale9Enabled(true)
    bar:setContentSize(barbgsize)
    bar:setAnchorPoint(0,0.5)
    bar:setPosition(0, barbgsize.height*0.5)
    bar:setScale((currExp/maxExp), 1)
    barbg:addChild(bar) 

    local label_prayexp = Common.finalFont(currExp.."/"..maxExp, 1, 1,12)
    label_prayexp:setPosition(barbgsize.width*0.5, barbgsize.height*0.5)
    barbg:addChild(label_prayexp)   

    local buttombg = cc.Sprite:create("image/ui/img/bg/bg_155.png")
    buttombg:setAnchorPoint(0,0)
    buttombg:setPosition(10,10)
    panel:addChild(buttombg)

    local buttombgsize = buttombg:getContentSize()

    local str = "运送的收益加成+"..self.transportInfo.God.Level.."%"
    label_addition = Common.finalFont(str, 1, 1,20)
    label_addition:setPosition(buttombgsize.width*0.5, buttombgsize.height*0.5)
    buttombg:addChild(label_addition)

    local line = cc.Sprite:create("image/ui/img/bg/bg_158.png")
    line:setPosition(271, panelsize.height*0.5)
    panel:addChild(line)


    -- 上香

    local function pray( type )
        rpc:call("Vehicle.Pray",type, function ( event )
            if event.status == Exceptions.Nil then
                if event.result == nil then
                    return
                end
                local str = "香火等级  "..event.result.Level
                label_praylevel:setString(str)

                local maxExp = BaseConfig.GetGodExp(event.result.Level)
                local currExp = event.result.Exp
                bar:setScale((currExp/maxExp), 1)

                label_prayexp:setString(currExp.."/"..maxExp)

                str = "运送的收益加成+"..event.result.Level.."%"
                label_addition:setString(str)

                -- if type == 1 then
                --     -- GameCache.Avatar.Coin = GameCache.Avatar.Coin - 5000
                -- elseif type == 2 then
                --     -- GameCache.Avatar.Gold = GameCache.Avatar.Gold - 20
                -- elseif type == 3 then
                --     -- GameCache.Avatar.Gold = GameCache.Avatar.Gold - 50
                -- end
                self.transportInfo.PrayCount[type] = self.transportInfo.PrayCount[type]-1
                self.transportInfo.God.Level = event.result.Level
                self.transportInfo.God.Exp = event.result.Exp
            end
        end)
    end


    local itembg1 = cc.Sprite:create("image/ui/img/bg/bg_156.png")
    itembg1:setPosition(500,panelsize.height*0.20)
    panel:addChild(itembg1)


    local itembg2 = cc.Sprite:create("image/ui/img/bg/bg_156.png")
    itembg2:setPosition(500,panelsize.height*0.5)
    panel:addChild(itembg2)


    local itembg3 = cc.Sprite:create("image/ui/img/bg/bg_156.png")
    itembg3:setPosition(500,panelsize.height*0.8)
    panel:addChild(itembg3)    

    local itembgsize = itembg3:getContentSize()
    local btnsize = cc.size(138,63)

    icon = cc.Sprite:create("image/ui/img/btn/btn_1163.png")
    icon:setPosition(itembgsize.width*0.15, itembgsize.height*0.5)
    itembg1:addChild(icon)
    icon = cc.Sprite:create("image/icon/border/border_star_3.png")
    icon:setPosition(itembgsize.width*0.15, itembgsize.height*0.5)
    itembg1:addChild(icon)
    label = Common.finalFont("十里香", 1, 1,24)
    label:setColor(cc.c3b(72,106,167))
    label:setAnchorPoint(0,0.5)
    label:setPosition(itembgsize.width*0.37, itembgsize.height*0.7)
    label:setColor(cc.c3b(72,106,167))
    itembg1:addChild(label)
    label = Common.finalFont("香火值+500", 1, 1,20)
    label:setColor(cc.c3b(72,106,167))
    label:setAnchorPoint(0,0.5)
    label:setPosition(itembgsize.width*0.3, itembgsize.height*0.37)
    itembg1:addChild(label)
    -- label = Common.finalFont("荣誉值+10", 1, 1,20)
    -- label:setColor(cc.c3b(72,106,167))
    -- label:setAnchorPoint(0,0.5)
    -- label:setPosition(itembgsize.width*0.3, itembgsize.height*0.2)
    -- itembg1:addChild(label)
    local btn = ccui.MixButton:create("image/ui/img/btn/btn_610.png")
    btn:setScale9Size(btnsize)
    btn:setPosition(itembgsize.width*0.8, itembgsize.height*0.32)
    btn:setTitle("上香保佑",26,cc.c3b(226,204,269))
    btn:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            if Common.isCostMoney(1002, 5000) and self.transportInfo.PrayCount[1]-1 >= 0 then
                pray(1)
                btn:setStateEnabled(false)
                EffectManager:CreateAnimation(itembg1, itembgsize.width*0.15, itembgsize.height*0.5, nil, 20 , false)
            end
        end
    end)
    if self.transportInfo.PrayCount[1]-1 < 0 then
        btn:setStateEnabled(false)
    else
        btn:setStateEnabled(true)
    end
    itembg1:addChild(btn)

    local icon_gold = cc.Sprite:create("image/ui/img/btn/btn_035.png")
    icon_gold:setPosition(itembgsize.width*0.75, itembgsize.height*0.7)
    itembg1:addChild(icon_gold)

    label = Common.finalFont("5000", 1, 1,20)
    label:setColor(cc.c3b(72,106,167))
    label:setPosition(itembgsize.width*0.87,itembgsize.height*0.7)
    itembg1:addChild(label)

    icon = cc.Sprite:create("image/ui/img/btn/btn_1164.png")
    icon:setPosition(itembgsize.width*0.15, itembgsize.height*0.5)
    itembg2:addChild(icon)
    icon = cc.Sprite:create("image/icon/border/border_star_3.png")
    icon:setPosition(itembgsize.width*0.15, itembgsize.height*0.5)
    itembg2:addChild(icon)
    label = Common.finalFont("百里香", 1, 1,24)
    label:setColor(cc.c3b(72,106,167))
    label:setAnchorPoint(0,0.5)
    label:setPosition(itembgsize.width*0.37, itembgsize.height*0.7)
    itembg2:addChild(label)
    label = Common.finalFont("香火值+1000", 1, 1,20)
    label:setColor(cc.c3b(72,106,167))
    label:setAnchorPoint(0,0.5)
    label:setPosition(itembgsize.width*0.3, itembgsize.height*0.37)
    itembg2:addChild(label)
    -- label = Common.finalFont("荣誉值+20", 1, 1,20)
    -- label:setColor(cc.c3b(72,106,167))
    -- label:setAnchorPoint(0,0.5)
    -- label:setPosition(itembgsize.width*0.3, itembgsize.height*0.2)
    -- itembg2:addChild(label)
    local btn = ccui.MixButton:create("image/ui/img/btn/btn_610.png")
    btn:setScale9Size(btnsize)
    btn:setPosition(itembgsize.width*0.8, itembgsize.height*0.32)
    btn:setTitle("上香保佑",26,cc.c3b(226,204,269))
    btn:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            if Common.isCostMoney(1001, 20) and self.transportInfo.PrayCount[2]-1 >= 0 then
                pray(2)
                btn:setStateEnabled(false)
                EffectManager:CreateAnimation(itembg2, itembgsize.width*0.15, itembgsize.height*0.5, nil, 20 , false)
            end
        end
    end)
    if self.transportInfo.PrayCount[2]-1 < 0 then
        btn:setStateEnabled(false)
    else
        btn:setStateEnabled(true)
    end    
    itembg2:addChild(btn)

    local icon_gold = cc.Sprite:create("image/ui/img/btn/btn_060.png")
    icon_gold:setPosition(itembgsize.width*0.8, itembgsize.height*0.7)
    itembg2:addChild(icon_gold)

    label = Common.finalFont("20", 1, 1,20)
    label:setColor(cc.c3b(72,106,167))
    label:setPosition(itembgsize.width*0.87,itembgsize.height*0.7)
    itembg2:addChild(label)

    icon = cc.Sprite:create("image/ui/img/btn/btn_1165.png")
    icon:setPosition(itembgsize.width*0.15, itembgsize.height*0.5)
    itembg3:addChild(icon)
    icon = cc.Sprite:create("image/icon/border/border_star_3.png")
    icon:setPosition(itembgsize.width*0.15, itembgsize.height*0.5)
    itembg3:addChild(icon)
    label = Common.finalFont("千里香", 1, 1,24)
    label:setColor(cc.c3b(72,106,167))
    label:setAnchorPoint(0,0.5)
    label:setPosition(itembgsize.width*0.37, itembgsize.height*0.7)
    itembg3:addChild(label)
    label = Common.finalFont("香火值+3000", 1, 1,20)
    label:setColor(cc.c3b(72,106,167))
    label:setAnchorPoint(0,0.5)
    label:setPosition(itembgsize.width*0.3, itembgsize.height*0.37)
    itembg3:addChild(label)
    -- label = Common.finalFont("荣誉值+50", 1, 1,20)
    -- label:setColor(cc.c3b(72,106,167))
    -- label:setAnchorPoint(0,0.5)
    -- label:setPosition(itembgsize.width*0.3, itembgsize.height*0.2)
    -- itembg3:addChild(label)
    local btn = ccui.MixButton:create("image/ui/img/btn/btn_610.png")
    btn:setScale9Size(btnsize)
    btn:setPosition(itembgsize.width*0.8, itembgsize.height*0.32)
    btn:setTitle("上香保佑",26,cc.c3b(226,204,269))
    btn:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            if Common.isCostMoney(1001, 50) and self.transportInfo.PrayCount[3]-1 >= 0 then
                pray(3)
                btn:setStateEnabled(false)
                EffectManager:CreateAnimation(itembg3, itembgsize.width*0.15, itembgsize.height*0.5, nil, 20 , false)
            end
        end
    end)  
    if self.transportInfo.PrayCount[3]-1 < 0 then
        btn:setStateEnabled(false)
    else
        btn:setStateEnabled(true)
    end  
    itembg3:addChild(btn)

    local icon_gold = cc.Sprite:create("image/ui/img/btn/btn_060.png")
    icon_gold:setPosition(itembgsize.width*0.8, itembgsize.height*0.7)
    itembg3:addChild(icon_gold)

    label = Common.finalFont("50", 1, 1,20)
    label:setColor(cc.c3b(72,106,167))
    label:setPosition(itembgsize.width*0.87,itembgsize.height*0.7)
    itembg3:addChild(label)


    local function onTouchBegan(touch, event)
        return true
    end
    local function onTouchEnded(touch, event)

    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)

    return layer
end

function TransportLayer:createRecordUI()
    local layer = cc.Layer:create()
    local layerColor = cc.LayerColor:create(cc.c4b(0,0,0,125))
    layer:addChild(layerColor)


    local bgsize = cc.size(667,470)
    local bg = ccui.ImageView:create("image/ui/img/bg/bg_139.png")
    bg:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)
    bg:setScale9Enabled(true)
    bg:setContentSize(bgsize)
    layer:addChild(bg)

    local huawen = cc.Sprite:create("image/ui/img/btn/btn_609.png")
    huawen:setPosition(bgsize.width*0.5, bgsize.height*0.5)
    bg:addChild(huawen)
    
    local titlebg = cc.Sprite:create("image/ui/img/bg/bg_174.png")
    titlebg:setPosition(bgsize.width*0.5, bgsize.height-10)
    bg:addChild(titlebg)

    local title = cc.Sprite:create("image/ui/img/btn/btn_620.png")
    title:setPosition(bgsize.width*0.5, bgsize.height-10)
    bg:addChild(title)



    -- local btn_close = createMixSprite("image/ui/img/btn/btn_598.png")
    -- btn_close:setPosition(bgsize.width-10, bgsize.height-10)
    -- btn_close:addTouchEventListener(function (sender, eventType)
    --     if eventType == ccui.TouchEventType.ended then
    --         layer:removeFromParent()
    --         layer = nil
    --     end
    -- end)
    -- bg:addChild(btn_close)

    if #self.recordInfo == 0 then
        local sp = cc.Sprite:create("image/ui/img/btn/btn_989.png")
        sp:setPosition(bgsize.width*0.5-70, bgsize.height*0.5)
        bg:addChild(sp)

        local label = Common.finalFont("您目前没有记录",0,0,22, cc.c3b(61,131,172))
        label:setAnchorPoint(0,0.5)
        label:setPosition(bgsize.width*0.5-20, bgsize.height*0.5)
        bg:addChild(label)
    end

    local function tableCellTouched( table, cell )

    end

    local function cellSizeForTable( table, idx )

        return 87, 100
    end

    local function tableCellAtIndex( table, idx )
        -- local cell = table:dequeueCell()
        -- CCLog(idx)
        local cell = cc.TableViewCell:new()

        local info = self.recordInfo[idx+1]

        local itembg = cc.Sprite:create("image/ui/img/bg/bg_173.png")
        itembg:setAnchorPoint(0.5,0)
        itembg:setPosition(bgsize.width*0.5,0)
        cell:addChild(itembg)

        local size = itembg:getContentSize()


        local label_time = Common.finalFont(info.Time, 460, size.height*0.5,16,cc.c3b(0,0,0))
        label_time:setAnchorPoint(0,0.5)
        itembg:addChild(label_time)

        if info.type == 1 then

            local label_content = Common.systemFont(info.EnemyName.."攻击了您",1,1, 20,cc.c3b(10,51,91))
            label_content:setAnchorPoint(0,0.5)
            label_content:setPosition(40, 50)
            itembg:addChild(label_content)


            local label = Common.finalFont("夺走了您"..info.Coin.."两银子", 1,1, 16,cc.c3b(42,87,124))
            label:setAnchorPoint(0,0.5)
            label:setPosition(40, 23)
            itembg:addChild(label)

        elseif info.type == 2 then

            local label_content = Common.systemFont(info.EnemyName.."攻击了您",1,1, 20,cc.c3b(10,51,91))
            label_content:setAnchorPoint(0,0.5)
            label_content:setPosition(40, 50)
            itembg:addChild(label_content)


            local label = Common.finalFont("被你暴打一顿，灰溜溜逃走了", 1,1, 16,cc.c3b(42,87,124))
            label:setAnchorPoint(0,0.5)
            label:setPosition(40, 23)
            itembg:addChild(label)


        elseif info.type == 3 then
            local label_content = Common.systemFont(""..horseName[info.Quality].."安全抵达"..dstName[info.Dst] .. ",顺利取得经书",1,1, 20,cc.c3b(10,51,91))
            label_content:setAnchorPoint(0,0.5)
            label_content:setPosition(40, 50)
            itembg:addChild(label_content)

            local label = Common.finalFont("获得", 1,1, 16,cc.c3b(42,87,124))
            label:setAnchorPoint(0,0.5)
            label:setPosition(40, 23)
            itembg:addChild(label)

            local sprite_coin = cc.Sprite:create("image/ui/img/btn/btn_035.png")
            sprite_coin:setAnchorPoint(0,0.5)
            sprite_coin:setPosition(80, 23)
            itembg:addChild(sprite_coin)

            local label_coin = Common.finalFont(""..info.Coin, 1,1, 18,cc.c3b(42,87,124))
            label_coin:setAnchorPoint(0,0.5)
            label_coin:setPosition(120,23)
            itembg:addChild(label_coin)

            -- local sprite_honor = cc.Sprite:create("image/ui/img/btn/btn_357.png")
            -- sprite_honor:setAnchorPoint(0,0.5)
            -- sprite_honor:setPosition(label_coin:getPositionX()+label_coin:getContentSize().width+10, 23)
            -- itembg:addChild(sprite_honor)

            -- local label_honor = Common.finalFont(""..info.Honor, 1,1, 18,cc.c3b(42,87,124))
            -- label_honor:setAnchorPoint(0,0.5)
            -- label_honor:setPosition(sprite_honor:getPositionX()+sprite_honor:getContentSize().width+10,23)
            -- itembg:addChild(label_honor) 
            local x = label_coin:getPositionX()+label_coin:getContentSize().width+30
            if info.Surprise and #info.Surprise ~= 0 then
                for i=1, #info.Surprise do
                    local icon = Common.getGoods(info.Surprise[i],false,BaseConfig.GOODS_LEASTTYPE)
                    icon:setNumVisible(false)
                    icon:setAnchorPoint(0,0.5)
                    icon:setPosition(x,23)
                    itembg:addChild(icon)

                    local label = Common.finalFont(""..info.Surprise[i].Num, x+20, 23, 18, cc.c3b(42,87,124) )
                    label:setAnchorPoint(0,0.5)
                    itembg:addChild(label)

                    x = x + 10 + label:getContentSize().width
                end
                
            end

        end

        return cell
    end

    local function numberOfCellsInTableView(table)
        return #self.recordInfo
    end

    local tableView = cc.TableView:create(cc.size(bgsize.width, bgsize.height*0.85))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(0, 20))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)

    tableView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:reloadData()

    bg:addChild(tableView)



    local function onTouchBegan(touch, event)
        return true
    end
    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = bg:convertToNodeSpace(touch:getLocation())
        local startpos = bg:convertToNodeSpace(touch:getStartLocationInView())
        local s = bg:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if not cc.rectContainsPoint(rect, startpos) and not cc.rectContainsPoint(rect, locationInNode) then
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


    return layer
end

function TransportLayer:createOptionUI()
    self.horses = {}
    local layer = cc.Layer:create()

    local layerColor = cc.LayerColor:create(cc.c4b(0,0,0,125))
    layer:addChild(layerColor)

    local bgsize = cc.size(890,534)
    local bg = ccui.ImageView:create("image/ui/img/bg/bg_111.png")
    bg:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)
    -- bg:setAnchorPoint(0.5,0)
    bg:setScale9Enabled(true)
    bg:setContentSize(bgsize)
    layer:addChild(bg)

    local light = cc.Sprite:create("image/ui/img/bg/bg_112.png")
    light:setAnchorPoint(0,1)
    light:setPosition(0, bgsize.height-2)
    bg:addChild(light)

    -- light = cc.Sprite:create("image/ui/img/bg/bg_113.png")
    -- light:setAnchorPoint(0.5,1)
    -- light:setPosition(bgsize.width*0.5, bgsize.height-2)
    -- bg:addChild(light)

    local panelsize = cc.size(882,512)
    local panel = ccui.ImageView:create("image/ui/img/bg/bg_139.png")
    panel:setPosition(bgsize.width*0.5, 5)
    panel:setAnchorPoint(0.5,0)
    panel:setScale9Enabled(true)
    panel:setContentSize(panelsize)
    bg:addChild(panel)

    local btn_close = createMixSprite("image/ui/img/btn/btn_598.png")
    btn_close:setPosition(bgsize.width-5, bgsize.height-5)
    btn_close:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            layer:removeFromParent()
            layer = nil
        end
    end)
    bg:addChild(btn_close)

    -- local wen = cc.Sprite:create("image/ui/img/btn/btn_592.png")
    -- wen:setPosition(bgsize.width*0.15, bgsize.height-30)
    -- bg:addChild(wen)
    
    -- local wen = cc.Sprite:create("image/ui/img/btn/btn_592.png")
    -- wen:setPosition(bgsize.width*0.35, bgsize.height-30)
    -- wen:setFlippedX(true)
    -- bg:addChild(wen)

    local buttombg = cc.Sprite:create("image/ui/img/bg/bg_152.png")
    buttombg:setAnchorPoint(0.5, 0)
    buttombg:setPosition(panelsize.width*0.5, 5)
    panel:addChild(buttombg)
    local buttombgsize = buttombg:getContentSize()

    local leftbg = cc.Sprite:create("image/ui/img/bg/bg_151.png")
    leftbg:setAnchorPoint(0, 0.5)
    leftbg:setPosition(10, buttombgsize.height*0.57)
    buttombg:addChild(leftbg)
    local leftbgsize = leftbg:getContentSize()

    local midbg = cc.Sprite:create("image/ui/img/bg/bg_151.png")
    -- midbg:setAnchorPoint(0.5, 0)
    midbg:setPosition(buttombgsize.width*0.5, buttombgsize.height*0.57)
    buttombg:addChild(midbg)
    local midbgsize = midbg:getContentSize()

    local rightbg = cc.Sprite:create("image/ui/img/bg/bg_151.png")
    rightbg:setAnchorPoint(1, 0.5)
    rightbg:setPosition(buttombgsize.width - 10, buttombgsize.height*0.57)
    buttombg:addChild(rightbg)
    local rightbgsize = rightbg:getContentSize()    

    local iconbg = cc.LayerColor:create(cc.c4b(0,0,0,0),860, 230)
    iconbg:ignoreAnchorPointForPosition(false)
    iconbg:setAnchorPoint(0.5, 1)
    iconbg:setPosition(panelsize.width*0.5, panelsize.height-5)
    panel:addChild(iconbg)
    local size = iconbg:getContentSize()

    local icon = cc.Sprite:create("image/ui/img/btn/btn_799.png")
    self.horses[1] = icon
    icon:setPosition(size.width*0.1,size.height*0.55)
    iconbg:addChild(icon)
    icon = cc.Sprite:create("image/ui/img/btn/btn_1216.png")
    icon:setPosition(size.width*0.1,size.height*0.55)
    iconbg:addChild(icon)
    local label = Common.finalFont("白龙马", 1, 1,20)
    label:setPosition(size.width*0.1,size.height*0.1)
    label:setColor(cc.c3b(255,255,255))
    iconbg:addChild(label)

    icon = cc.Sprite:create("image/ui/img/btn/btn_798.png")
    self.horses[2] = icon
    icon:setPosition(size.width*0.3,size.height*0.55)
    iconbg:addChild(icon)
    icon = cc.Sprite:create("image/ui/img/btn/btn_1217.png")
    icon:setPosition(size.width*0.3,size.height*0.55)
    iconbg:addChild(icon)
    label = Common.finalFont("沙僧", 1, 1,20)
    label:setPosition(size.width*0.3,size.height*0.1)
    label:setColor(cc.c3b(79,240,130))
    iconbg:addChild(label)

    icon = cc.Sprite:create("image/ui/img/btn/btn_797.png")
    self.horses[3] = icon
    icon:setPosition(size.width*0.5,size.height*0.55)
    iconbg:addChild(icon)
    icon = cc.Sprite:create("image/ui/img/btn/btn_1218.png")
    icon:setPosition(size.width*0.5,size.height*0.55)
    iconbg:addChild(icon)
    label = Common.finalFont("猪八戒", 1, 1,20)
    label:setPosition(size.width*0.5,size.height*0.1)
    label:setColor(cc.c3b(119,187,239))
    iconbg:addChild(label)

    icon = cc.Sprite:create("image/ui/img/btn/btn_796.png")
    self.horses[4] = icon
    icon:setPosition(size.width*0.7,size.height*0.55)
    iconbg:addChild(icon)
    icon = cc.Sprite:create("image/ui/img/btn/btn_1219.png")
    icon:setPosition(size.width*0.7,size.height*0.55)
    iconbg:addChild(icon)
    label = Common.finalFont("孙悟空", 1, 1,20)
    label:setPosition(size.width*0.7,size.height*0.1)
    label:setColor(cc.c3b(222,78,238))
    iconbg:addChild(label)


    icon = cc.Sprite:create("image/ui/img/btn/btn_795.png")
    self.horses[5] = icon
    icon:setPosition(size.width*0.9,size.height*0.55)
    iconbg:addChild(icon)
    icon = cc.Sprite:create("image/ui/img/btn/btn_1220.png")
    icon:setPosition(size.width*0.9,size.height*0.55)
    iconbg:addChild(icon)

    local function callBestHorse(  )
        rpc:call("Vehicle.CallBestQuality", nil, function ( event )
            if event.status == Exceptions.Nil and event.result == true then
                for i=1,5 do
                    self.horses[i]:setTexture(horseBackTexture[i])
                end
                self.transportInfo.CurQuality = 5
                local vehicleConfig = BaseConfig.GetVehicle(self.transportInfo.CurQuality)
                self.horses[self.transportInfo.CurQuality]:setTexture("image/ui/img/btn/btn_615.png")
                self.label_coin:setString("".. math.floor(vehicleConfig.coin * self.curDstGain / 100))
                -- self.label_honor:setString("".. math.floor(vehicleConfig.honor * self.curDstGain / 100))

                if vehicleConfig.surprise ~= 0 then
                    self.label_surprise:setString("可能有")
                else
                    self.label_surprise:setString("无")
                end

                -- GameCache.Avatar.Gold = GameCache.Avatar.Gold-self.constance.CallVehicleBestQualityCost
            elseif event.status == Exceptions.EVehicleQualityOverflow then
                application:showFlashNotice("已经是最潮的唐僧了，没法换了。")
            end
        end)
    end 

    local function createNoteLayer(  )

        local layer = cc.LayerColor:create(cc.c4b(0,0,0,180))
        local scene = cc.Director:getInstance():getRunningScene()
        scene:addChild(layer)
    
        local bgsize = cc.size(540,200)    
        local bg = ccui.ImageView:create("image/ui/img/bg/bg_175.png")
        bg:setPosition(SCREEN_WIDTH*0.5,SCREEN_HEIGHT*0.6)
        bg:setScale9Enabled(true)
        bg:setContentSize(bgsize)
        layer:addChild(bg)
    
    
        local label1 = Common.finalFont("上仙，要VIP2以上的玩家才能召唤唐僧噢。" , 1 , 1, 24)
        label1:setPosition(bgsize.width*0.5, bgsize.height*0.7)
        bg:addChild(label1)  
    
        local sprite = cc.Sprite:create("image/ui/img/btn/btn_811.png")
        sprite:setAnchorPoint(0.5,0)
        sprite:setPosition(bgsize.width*0.5, 5)
        bg:addChild(sprite)
    
        local ssize = sprite:getContentSize()
    
        local line = cc.Sprite:create("image/ui/img/btn/btn_810.png")
        line:setPosition(ssize.width*0.5, ssize.height)
        sprite:addChild(line)
    
    
        local btn = ccui.MixButton:create("image/ui/img/btn/btn_818.png" )
        btn:setScale9Size(cc.size(155,60))
        btn:setTitle("成为VIP2",26,cc.c3b(238,205,142))
        btn:addTouchEventListener(function ( sender, eventType )
            if eventType == ccui.TouchEventType.ended then
                layer:removeFromParent()
                layer = nil
                application:pushScene("main.recharge.RechargeScene")
            end
        end)
        btn:setPosition(bgsize.width*0.25, 45)
        bg:addChild(btn)
    
        btn = ccui.MixButton:create("image/ui/img/btn/btn_818.png")
        btn:setScale9Size(cc.size(135,60))
        btn:setTitle("取消",26,cc.c3b(238,205,142))
        btn:addTouchEventListener(function ( sender, eventType )
            if eventType == ccui.TouchEventType.ended then
                layer:removeFromParent()
                layer = nil
            end
        end)
        btn:setPosition(bgsize.width*0.75, 45)
        bg:addChild(btn)
    
    
        local function onTouchBegan(touch, event)
            return true
        end
    
        local listener = cc.EventListenerTouchOneByOne:create()
        listener:setSwallowTouches(true)
        listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
        local eventDispatcher = layer:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)

    end

    local function createSureLayer(  )

        local layer = cc.LayerColor:create(cc.c4b(0,0,0,180))
        local scene = cc.Director:getInstance():getRunningScene()
        scene:addChild(layer)
    
        local bgsize = cc.size(540,200)    
        local bg = ccui.ImageView:create("image/ui/img/bg/bg_175.png")
        bg:setPosition(SCREEN_WIDTH*0.5,SCREEN_HEIGHT*0.6)
        bg:setScale9Enabled(true)
        bg:setContentSize(bgsize)
        layer:addChild(bg)
    
        local label1 = Common.finalFont("上仙，是否花费" , 1 , 1, 24)
        label1:setAnchorPoint(0,0.5)
        label1:setPosition(50, bgsize.height*.7)
        bg:addChild(label1)

        local icon = cc.Sprite:create("image/ui/img/btn/btn_060.png")
        icon:setPosition(240,bgsize.height*0.7)
        bg:addChild(icon)
    
        label1 = Common.finalFont("100", 1, 1, 30,cc.c3b(120,246,103))
        label1:setAnchorPoint(0,0.5)
        label1:setPosition(260,bgsize.height*0.7+2)
        bg:addChild(label1)

        local label1 = Common.finalFont("立刻召唤唐僧？" , 1 , 1, 24)
        label1:setAnchorPoint(0,0.5)
        label1:setPosition(315, bgsize.height*.7)
        bg:addChild(label1)    

        local sprite = cc.Sprite:create("image/ui/img/btn/btn_811.png")
        sprite:setAnchorPoint(0.5,0)
        sprite:setPosition(bgsize.width*0.5, 5)
        bg:addChild(sprite)

    
        local ssize = sprite:getContentSize()
    
        local line = cc.Sprite:create("image/ui/img/btn/btn_810.png")
        line:setPosition(ssize.width*0.5, ssize.height)
        sprite:addChild(line)
    
    
        local btn = ccui.MixButton:create("image/ui/img/btn/btn_818.png" )
        btn:setScale9Size(cc.size(135,60))
        btn:setTitle("取消",26,cc.c3b(238,205,142))
        btn:addTouchEventListener(function ( sender, eventType )
            if eventType == ccui.TouchEventType.ended then
                layer:removeFromParent()
                layer = nil

            end
        end)
        btn:setPosition(bgsize.width*0.25, 45)
        bg:addChild(btn)
    
        btn = ccui.MixButton:create("image/ui/img/btn/btn_818.png")
        btn:setScale9Size(cc.size(135,60))
        btn:setTitle("确定",26,cc.c3b(238,205,142))
        btn:addTouchEventListener(function ( sender, eventType )
            if eventType == ccui.TouchEventType.ended then
                callBestHorse()
                layer:removeFromParent()
                layer = nil
            end
        end)
        btn:setPosition(bgsize.width*0.75, 45)
        bg:addChild(btn)
    
    
        local function onTouchBegan(touch, event)
            return true
        end
    
        local listener = cc.EventListenerTouchOneByOne:create()
        listener:setSwallowTouches(true)
        listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
        local eventDispatcher = layer:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)

    end

    local btn = ccui.MixButton:create("image/ui/img/btn/btn_800.png")
    btn:setPosition(icon:getContentSize().width*0.9,0)
    btn:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            if self.transportInfo.CurQuality == 5 then
                application:showFlashNotice("已经是最潮的唐僧了，没法换了。")
                return
            end
            if GameCache.Avatar.VIP < 2 then
                -- 弹出充值vip界面
                createNoteLayer()
                return
            end
            local cost = self.constance.CALL_BEST_QUALITY_COST or 100
            if Common.isCostMoney(1001, cost) then
                -- 弹出确认界面
                createSureLayer()
                
            end
        end
    end)
    icon:addChild(btn)   

    label = Common.finalFont("唐僧", 1, 1,20)
    label:setPosition(size.width*0.9,size.height*0.1)
    label:setColor(cc.c3b(228,42,100))
    iconbg:addChild(label)

    self.horses[self.transportInfo.CurQuality]:setTexture("image/ui/img/btn/btn_615.png")


    label = Common.finalFont("选择取经目的地", 1, 1,18)
    label:setPosition(leftbgsize.width*0.5,leftbgsize.height*0.91)
    leftbg:addChild(label)

    label = Common.finalFont("锁仙岛", 1, 1,24)
    label:setPosition(leftbgsize.width*0.3,leftbgsize.height*0.62)
    leftbg:addChild(label)

    label = Common.finalFont("离火岛", 1, 1,24)
    label:setPosition(leftbgsize.width*0.3,leftbgsize.height*0.25)
    leftbg:addChild(label)

    local iconbg0 = cc.Sprite:create("image/ui/img/btn/btn_616.png")
    iconbg0:setPosition(leftbgsize.width*0.5, leftbgsize.height*0.62)
    leftbg:addChild(iconbg0)
    local iconbg1 = cc.Sprite:create("image/ui/img/btn/btn_616.png")
    iconbg1:setPosition(leftbgsize.width*0.5, leftbgsize.height*0.25)
    leftbg:addChild(iconbg1)
    iconbg1:setVisible(false)

    size = iconbg0:getContentSize()

    label = Common.finalFont("锁仙岛", 1, 1,22)
    label:setPosition(size.width*0.3, size.height*0.7)
    label:setColor(cc.c3b(232,127,14))
    iconbg0:addChild(label)


    label = Common.finalFont("离火岛", 1, 1,22)
    label:setPosition(size.width*0.3, size.height*0.7)
    label:setColor(cc.c3b(232,127,14))
    iconbg1:addChild(label)
    -- label = Common.finalFont("耗费耐力："..self.constance.DST2_ENDURANCE_COST, 1, 1,18)
    -- label:setPosition(size.width*0.3, size.height*0.3)
    -- label:setColor(cc.c3b(182,111,35))
    -- iconbg1:addChild(label)
    

    midbg = midbg
    size = midbg:getContentSize()

    label = Common.finalFont("运送时间：", 1, 1,18)
    label:setPosition(midbgsize.width*0.2, midbgsize.height*0.8)
    midbg:addChild(label)

    label = Common.finalFont("基础收益：", 1, 1,18)
    label:setPosition(midbgsize.width*0.2, midbgsize.height*0.6)
    midbg:addChild(label)

    local sp_coin = cc.Sprite:create("image/ui/img/btn/btn_035.png")
    sp_coin:setAnchorPoint(0,0.5)
    sp_coin:setPosition(midbgsize.width*0.38, midbgsize.height*0.6)
    midbg:addChild(sp_coin)

    -- local sp_honor = cc.Sprite:create("image/ui/img/btn/btn_357.png")
    -- sp_honor:setAnchorPoint(0,0.5)
    -- sp_honor:setPosition(midbgsize.width*0.74, midbgsize.height*0.6)
    -- midbg:addChild(sp_honor)

    label = Common.finalFont("拜佛加成：", 1, 1,18)
    label:setPosition(midbgsize.width*0.2, midbgsize.height*0.4)
    midbg:addChild(label)

    label = Common.finalFont("惊喜收益：", 1, 1,18)
    label:setPosition(midbgsize.width*0.2, midbgsize.height*0.2)
    midbg:addChild(label)

    local str = (self.constance.DST1_TRANSPORT_TIME/60).."分钟"
    local label_time = Common.finalFont(str, 1, 1,18)
    label_time:setAnchorPoint(0,0.5)
    label_time:setPosition(midbgsize.width*0.4, midbgsize.height*0.8)
    label_time:setColor(cc.c3b(230,191,124))
    midbg:addChild(label_time)

    local vehicleConfig = BaseConfig.GetVehicle(self.transportInfo.CurQuality)
    str = "" .. vehicleConfig.coin
    local label_coin = Common.finalFont(str, 1, 1,18)
    label_coin:setAnchorPoint(0,0.5)
    label_coin:setPosition(midbgsize.width*0.53, midbgsize.height*0.6)
    label_coin:setColor(cc.c3b(230,191,124))
    midbg:addChild(label_coin)
    self.label_coin = label_coin

    -- str = "" .. vehicleConfig.honor
    -- local label_honor = Common.finalFont(str, 1, 1,18)
    -- label_honor:setAnchorPoint(0,0.5)
    -- label_honor:setPosition(midbgsize.width*0.88, midbgsize.height*0.6)
    -- label_honor:setColor(cc.c3b(230,191,124))
    -- midbg:addChild(label_honor)
    -- self.label_honor = label_honor


    label = Common.finalFont("＋"..self.transportInfo.God.Level .. "％", 1, 1,18)
    label:setAnchorPoint(0,0.5)
    label:setPosition(midbgsize.width*0.4, midbgsize.height*0.4)
    label:setColor(cc.c3b(230,191,124))
    midbg:addChild(label)

    label = Common.finalFont("", 1, 1,18)
    label:setAnchorPoint(0,0.5)
    if vehicleConfig.surprise ~= 0 then
        label:setString("可能有")
    else
        label:setString("无")
    end
    label:setPosition(midbgsize.width*0.4, midbgsize.height*0.2)
    label:setColor(cc.c3b(230,191,124))
    midbg:addChild(label)
    self.label_surprise = label


    label = Common.finalFont("剩余免费刷新次数：", 1, 1,18)
    label:setPosition(rightbgsize.width*0.5, rightbgsize.height*0.8)
    rightbg:addChild(label)

    local str = ""..self.transportInfo.FreeRefreshCount
    label_count = Common.finalFont(str, 1, 1,22)
    label_count:setPosition(rightbgsize.width*0.85, rightbgsize.height*0.8)
    label_count:setColor(cc.c3b(230,191,124))
    rightbg:addChild(label_count)

    local label_costgold = Common.finalFont( "", 1, 1,22)
    label_costgold:setPosition(rightbgsize.width*0.65, rightbgsize.height*0.15)
    rightbg:addChild(label_costgold)

    if self.transportInfo.FreeRefreshCount > 0 then
        label_costgold:setString("免费")
    else
        str = ""..self.constance.REFRESH_QUALITY_COST
        label_costgold:setString(str)
    end

    local function refreshHorse()
        rpc:call( "Vehicle.RefreshQuality", nil, function ( event )
            if event.status == Exceptions.Nil and event.result~= nil then
                self.transportInfo.CurQuality = event.result
                for i=1,5 do
                    self.horses[i]:setTexture(horseBackTexture[i])
                end
                local vehicleConfig = BaseConfig.GetVehicle(self.transportInfo.CurQuality)
                self.horses[self.transportInfo.CurQuality]:setTexture("image/ui/img/btn/btn_615.png")
                self.label_coin:setString("" .. math.floor(vehicleConfig.coin * self.curDstGain / 100))
                -- self.label_honor:setString("" .. math.floor(vehicleConfig.honor * self.curDstGain / 100))
    
                if vehicleConfig.surprise ~= 0 then
                    self.label_surprise:setString("可能有")
                else
                    self.label_surprise:setString("无")
                end

                if self.transportInfo.FreeRefreshCount > 0 then
                    self.transportInfo.FreeRefreshCount = self.transportInfo.FreeRefreshCount - 1
                    label_count:setString(""..self.transportInfo.FreeRefreshCount)
                    if self.transportInfo.FreeRefreshCount == 0 then
                        str = ""..self.constance.REFRESH_QUALITY_COST
                        label_costgold:setString(str)
                    end
                else
                    str = ""..self.constance.REFRESH_QUALITY_COST
                    label_costgold:setString(str)
                    -- GameCache.Avatar.Gold = GameCache.Avatar.Gold-self.constance.RefreshVehicleQualityCost
                end
            elseif event.status == Exceptions.EVehicleQualityOverflow then
                application:showFlashNotice("已经是最潮的唐僧了，没法换了。")
            end
        end)
    end

    local btn = createMixScale9Sprite("image/ui/img/btn/btn_610.png", nil, nil, cc.size(135,60))
    btn:setCircleFont("刷新品质", 1, 1, 26, cc.c3b(223,184,109))
    btn:setFontOutline(cc.c4b(65,26,1,255),1)
    btn:setFontPos(0.5,0.5)
    btn:setPosition(rightbgsize.width*0.5,rightbgsize.height*0.45)
    rightbg:addChild(btn)
    btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if self.transportInfo.FreeRefreshCount-1 >=0 or Common.isCostMoney(1001, self.constance.REFRESH_QUALITY_COST) then
                if self.transportInfo.CurQuality == 5 then
                    application:showFlashNotice("已经是最潮的唐僧了，没法换了。")
                return
            end
                refreshHorse()
            end
        end
    end)


    local sp_cost = cc.Sprite:create("image/ui/img/btn/btn_060.png")
    sp_cost:setPosition(rightbgsize.width*0.5, rightbgsize.height*0.15)
    rightbg:addChild(sp_cost)



    local btn = createMixSprite("image/ui/img/btn/btn_610.png")
    btn:setPosition(leftbgsize.width*0.8, leftbgsize.height*0.62)
    btn:setCircleFont("选定", 1, 1, 26, cc.c3b(223,184,109))
    btn:setFontOutline(cc.c4b(65,26,1,255),1)
    btn:setFontPos(0.5,0.5)
    leftbg:addChild(btn)
    btn:addTouchEventListener(function ()
        iconbg0:setVisible(true)
        iconbg1:setVisible(false)
        self.curDst = 1
        self.curDstGain = self.constance.DST1_EXTRA_GAIN
        -- self.curCostEndur = self.constance.DST1_ENDURANCE_COST
        label_time:setString((self.constance.DST1_TRANSPORT_TIME/60).."分钟")
        local vehicleConfig = BaseConfig.GetVehicle(self.transportInfo.CurQuality)
        self.label_coin:setString("" .. math.floor(vehicleConfig.coin * self.curDstGain / 100))
        -- self.label_honor:setString("" .. math.floor(vehicleConfig.honor * self.curDstGain / 100))    
    end)
  

    local btn = createMixSprite("image/ui/img/btn/btn_610.png")
    btn:setPosition(leftbgsize.width*0.8, leftbgsize.height*0.25)
    btn:setCircleFont("选定", 1, 1, 26, cc.c3b(223,184,109))
    btn:setFontOutline(cc.c4b(65,26,1,255),1)
    btn:setFontPos(0.5,0.5)
    leftbg:addChild(btn)
    btn:addTouchEventListener(function ()
        iconbg0:setVisible(false)
        iconbg1:setVisible(true)
        self.curDst = 2
        self.curDstGain = self.constance.DST2_EXTRA_GAIN
        -- self.curCostEndur = self.constance.DST2_ENDURANCE_COST
        label_time:setString((self.constance.DST2_TRANSPORT_TIME/60).."分钟")
        local vehicleConfig = BaseConfig.GetVehicle(self.transportInfo.CurQuality)
        self.label_coin:setString("".. math.floor(vehicleConfig.coin * self.curDstGain / 100))
        -- self.label_honor:setString("".. math.floor(vehicleConfig.honor * self.curDstGain / 100))    
    end)

    local label_transcount = Common.systemFont("今日剩余次数:"..(self.constance.MAX_DAILY_TRANS_COUNT-self.transportInfo.TransCount) .."/" ..self.constance.MAX_DAILY_TRANS_COUNT, 1, 1, 24)
    label_transcount:setAnchorPoint(0,0.5)
    label_transcount:setPosition(50, 40)
    buttombg:addChild(label_transcount)

    local function startTransport()
        rpc:call("Vehicle.StartTransport",{Dst = self.curDst, FriendRID = self.curFriendRID}, function ( event )
            if event.status == Exceptions.Nil and event.result == true then
                --- 更改运镖主界面
                layer:removeFromParent()
                self:receiveTransportInfo()

            end
        end)
    end

    local btn = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(165,70))
    btn:setCircleFont("开始取经", 1,1,30,cc.c3b(226,204,169))
    btn:setFontPos(0.5, 0.5)
    btn:setFontOutline(cc.c4b(65,26,1,255),1)
    btn:setPosition(buttombgsize.width*0.5, 40)
    btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            -- if (self.curDst == 1 and GameCache.Avatar.Endurance < self.constance.DST1_ENDURANCE_COST) or (self.curDst == 2 and GameCache.Avatar.Endurance < self.constance.DST2_ENDURANCE_COST) then
            --     commonLayer.NeedEndurance()
            --     return
            -- end
            if self.transportInfo.TransCount >= self.constance.MAX_DAILY_TRANS_COUNT then
                application:showFlashNotice("今日取经次数已用完")
                return
            end
            startTransport()
        end
    end)
    buttombg:addChild(btn)
 

    local function friendsInfo(  )
    rpc:call("Vehicle.GetGuardFriendList",{}, function ( event )
            if event.status == Exceptions.Nil then
                self.friendTable = event.result or {}
                -- if #self.friendTable > 1 then
                --     table.sort(self.friendTable, function ( a,b )
                --         return a.TFP > b.TFP
                --     end)
                -- end
                self:addChild(self:createFriendProtectUI())
            end
        end)
    end


    local btn = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(165,70))
    btn:setCircleFont("仙友护卫", 1,1,30,cc.c3b(226,204,169))
    btn:setFontPos(0.5, 0.5)
    btn:setFontOutline(cc.c4b(65,26,1,255),1)
    btn:setPosition(buttombgsize.width*0.85, 40)
    btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            friendsInfo()
        end
    end)
    buttombg:addChild(btn)   


    local function onTouchBegan(touch, event)
        return true
    end
    local function onTouchEnded(touch, event)

    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)

    return layer
end

function TransportLayer:createFriendProtectUI( )

    self.lastidx = nil
    self.curridx = nil

    local layer = cc.LayerColor:create(cc.c4b(0,0,0,125))

    local bgsize = cc.size(720,505)
    local bg = ccui.ImageView:create("image/ui/img/bg/bg_139.png")
    bg:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)
    bg:setScale9Enabled(true)
    bg:setContentSize(bgsize)
    layer:addChild(bg)

    local image_title = cc.Sprite:create("image/ui/img/btn/btn_608.png")
    image_title:setPosition(bgsize.width*0.5, bgsize.height-15)
    bg:addChild(image_title)


    local title = cc.Sprite:create("image/ui/img/btn/btn_988.png")
    title:setPosition(bgsize.width*0.5, bgsize.height-15)
    bg:addChild(title)



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



    local function tableCellTouched( table, cell )
        local idx = cell:getIdx()
        self.curridx = idx

        if self.lastidx == self.curridx then
            return
        end

        local cellbg = cell:getChildByName("bg")
        cellbg:setTexture("image/ui/img/btn/btn_982.png")

        local level = cellbg:getChildByName("level")
        level:setColor(cc.c3b(91,61,10))

        local sbg = cellbg:getChildByName("sbg")
        sbg:loadTexture("image/ui/img/btn/btn_987.png")

        local name = cellbg:getChildByName("name")
        name:setColor(cc.c3b(91,61,10))

        local zhanli = cellbg:getChildByName("zhanli")
        zhanli:setColor(cc.c3b(91,61,10))

        local check = cellbg:getChildByName("check")
        check:setSelectedState(true)
        check:setHighlighted(true)

        if self.lastidx ~= idx and self.lastidx then
            table:updateCellAtIndex(self.lastidx)
        end
        self.lastidx = idx
        
    end

    local function cellSizeForTable( table, idx )

        return 85, 675
    end

    local function tableCellAtIndex( table, idx )

        local cell = cc.TableViewCell:new()

        local itembg = cc.Sprite:create("image/ui/img/btn/btn_981.png")
        itembg:setAnchorPoint(0,0)
        -- itembg:setPosition(bgsize.width*0.5,0)
        -- itembg:setVisible(false)
        itembg:setName("bg")
        cell:addChild(itembg)

        local size = itembg:getContentSize()

        local str = "Lv."..self.friendTable[idx+1].Level
        local label = Common.finalFont(str, 1, 1, 24, cc.c3b(10,51,91))
        label:setPosition(60, size.height*0.5)
        label:setName("level")
        itembg:addChild(label)

        local info = {ID = self.friendTable[idx+1].Icon}
        local icon = GoodsInfoNode.new(BaseConfig.GOODS_HERO, info, BaseConfig.GOODS_SMALLTYPE)
        icon:setTouchEnable(false)
        icon:setPosition(135, size.height*0.5)
        itembg:addChild(icon)

        local ss = ccui.ImageView:create("image/ui/img/btn/btn_986.png")
        ss:setScale9Enabled(true)
        ss:setContentSize(cc.size(365,50))
        ss:setPosition(370, size.height*0.5)
        ss:setName("sbg")
        itembg:addChild(ss)

        str = ""..self.friendTable[idx+1].Name
        label = Common.systemFont(str, 1, 1, 20, cc.c3b(10,51,91))
        label:setAnchorPoint(0,0.5)
        label:setName("name")
        label:setPosition(197, size.height*0.5)
        itembg:addChild(label)


        label = Common.finalFont("战力：", 1, 1, 20, cc.c3b(10,51,91))
        label:setPosition(385, size.height*0.5)
        label:setName("zhanli")
        itembg:addChild(label)

        str = ""..self.friendTable[idx+1].TFP
        label = Common.finalFont(str, 1, 1, 26, cc.c3b(151,255,74))
        label:setAnchorPoint(0,0.5)
        label:setPosition(420, size.height*0.5)
        itembg:addChild(label)

        -- local function selectedEvent(sender,eventType)
            -- if eventType == ccui.CheckBoxEventType.selected then
            -- elseif eventType == ccui.CheckBoxEventType.unselected then
            -- end
        -- end

        local checkBox = ccui.CheckBox:create()
        checkBox:setTouchEnabled(false)
        checkBox:setName("check")
        checkBox:loadTextures("image/ui/img/btn/btn_983.png",
            "image/ui/img/btn/btn_983.png",
            "image/ui/img/btn/btn_984.png",
            "image/ui/img/btn/btn_984.png",
            "image/ui/img/btn/btn_984.png")
        checkBox:setPosition(623, size.height*0.5)

        -- checkBox:addEventListener(selectedEvent)

        itembg:addChild(checkBox)

        return cell
    end

    local function numberOfCellsInTableView(table)
        
        return #self.friendTable
    end

    if #self.friendTable > 0 then
        local tableView = cc.TableView:create(cc.size(680,350))
        tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        tableView:setPosition(cc.p(20, 105))
        tableView:setDelegate()
        tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)

        tableView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
        tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
        tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
        tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        tableView:reloadData()

        bg:addChild(tableView)

    else
        local sp = cc.Sprite:create("image/ui/img/btn/btn_989.png")
        sp:setPosition(bgsize.width*0.5-70, bgsize.height*0.5)
        bg:addChild(sp)

        local label = Common.finalFont("您目前没有仙友",0,0,22, cc.c3b(61,131,172))
        label:setAnchorPoint(0,0.5)
        label:setPosition(bgsize.width*0.5-20, bgsize.height*0.5)
        bg:addChild(label)
    end



    local icon = ccui.ImageView:create("image/ui/img/bg/bg_253.png")
    icon:setAnchorPoint(0.5,0)
    icon:setPosition(bgsize.width*0.5, 15)
    icon:setScale9Enabled(true)
    icon:setContentSize(cc.size(700,84))
    bg:addChild(icon)


    local btn = createMixScale9Sprite("image/ui/img/btn/btn_593.png",nil, nil, cc.size(185,70))
    btn:setCircleFont("确定",1,1,26, cc.c3b(243,207,137))
    btn:setPosition(bgsize.width*0.5, 50)
    btn:setFontPos(0.5,0.5)
    btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if #self.friendTable ~= 0 then
                if self.friendTable[self.curridx+1].InvitedCount >= self.constance.MAX_INVITED_GUARD_COUNT then
                    application:showFlashNotice("你的基友已被邀请护卫10次了，不能再出手了")
                    return
                end
                self.curFriendRID = self.friendTable[self.curridx+1].FriendRID
                self.curFriendName = self.friendTable[self.curridx+1].Name
            end
            layer:removeFromParent()
            layer = nil
        end
    end)
    bg:addChild(btn)

    return layer
end

function TransportLayer:createMessageUI( horse )

    local layer = cc.Layer:create()

    local layerColor = cc.LayerColor:create(cc.c4b(0,0,0,125))
    layer:addChild(layerColor)

    local bgsize = cc.size(262,255)
    local bg = ccui.ImageView:create("image/ui/img/bg/bg_175.png")
    bg:setPosition(SCREEN_WIDTH*0.5,SCREEN_HEIGHT*0.5)
    bg:setScale9Enabled(true)
    bg:setContentSize(bgsize)
    layer:addChild(bg)

    local line = cc.Sprite:create("image/ui/img/btn/btn_658.png")
    line:setPosition(bgsize.width*0.5, bgsize.height*0.75)
    bg:addChild(line)

    local function onTouchBegan(touch, event)
        return true
    end

    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
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
    local eventDispatcher = layer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, bg)

    local str = horse.Level .. "级 "..horse.Name
    local label = Common.systemFont(str,1,1,26,cc.c3b(251,156,54))
    -- label:setAnchorPoint(0,0.5)
    label:setPosition(bgsize.width*0.5,bgsize.height*0.85)
    bg:addChild(label)

    label = Common.finalFont("总战力：",1,1,20, cc.c3b(251,229,192))
    label:setAnchorPoint(0,0.5)
    label:setPosition(bgsize.width*0.1,bgsize.height*0.66)
    bg:addChild(label)  

    str = ""..horse.TFP
    label = Common.finalFont(str,1,1,20, cc.c3b(151,255,74))
    label:setAnchorPoint(0,0.5)
    label:setPosition(bgsize.width*0.45,bgsize.height*0.66)
    bg:addChild(label)       

    label = Common.finalFont("被劫次数：",1,1,20,cc.c3b(251,229,192))
    label:setAnchorPoint(0,0.5)
    label:setPosition(bgsize.width*0.1,bgsize.height*0.53)
    bg:addChild(label)    

    str = horse.AtkedCount.."/"..horse.MaxAtkedCount.."次"
    label = Common.finalFont(str,1,1,20, cc.c3b(151,255,74))
    label:setAnchorPoint(0,0.5)
    label:setPosition(bgsize.width*0.45,bgsize.height*0.53)
    bg:addChild(label)   

    label = Common.finalFont("拦截可得：",1,1,20,cc.c3b(251,229,192))
    label:setAnchorPoint(0,0.5)
    label:setPosition(bgsize.width*0.1,bgsize.height*0.4)
    bg:addChild(label)

    local icon = cc.Sprite:create("image/ui/img/btn/btn_035.png")
    icon:setAnchorPoint(0,0.5)
    icon:setPosition(bgsize.width*0.45,bgsize.height*0.4)
    bg:addChild(icon)

    str = ""..horse.ExpectCoinGain
    label = Common.finalFont(str,1,1,20,cc.c3b(151,255,74))
    label:setAnchorPoint(0,0.5)
    label:setPosition(bgsize.width*0.6,bgsize.height*0.4)
    bg:addChild(label)    

    local btn = ccui.MixButton:create("image/ui/img/btn/btn_593.png")
    btn:setScale9Size(cc.size(160,55))
    btn:setTitle("拦截他", 26, cc.c3b(226,204,169),1, cc.c4b(65,26,1,255))
    btn:setTitlePos(0.6, 0.5)
    btn:setChild("image/ui/img/btn/btn_670.png",0.2, 0.5)
    btn:setPosition(bgsize.width*0.5, bgsize.height*0.18)
    if horse.RID == "" or horse.FriendRID == GameCache.Avatar.RID then
        btn:setStateEnabled(false)
    end

    btn:addTouchEventListener(function ( sender,eventType )
        if eventType == ccui.TouchEventType.ended then
            local cost = self.constance.HIJACK_ENDURANCE_COST or 2
            
            if GameCache.Avatar.Endurance < cost then
                commonLayer.NeedEndurance()
                return
            end
            if horse.AtkedCount < horse.MaxAtkedCount then
                self:hijackVehicle(horse.RID)
                layer:removeFromParent()
                layer = nil
            else
                application:showFlashNotice("这可怜的娃已被抢的分文不剩了，上仙请放他一马吧！")
            end
            
        end
    end)
    bg:addChild(btn)

    return layer
end

function TransportLayer:onEnter()
    self:receiveTransportInfo()
end

function TransportLayer:onEnterTransitionFinish( )

    Common.OpenSystemLayer({10})
    TransportLayer.super.onEnterTransitionFinish(self)
end

function TransportLayer:onExit()
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:removeEventListener(self._listener)
    if self.scheduler_timer ~= nil then
        scheduler:unscheduleScriptEntry(self.scheduler_timer)
    end

    for k,v in pairs(self.vehicleLayerTimer) do
        scheduler:unscheduleScriptEntry(v)
    end
end


function TransportLayer:battleWin( result)
    Common.playSound("audio/effect/map_battle_win.mp3")

    local scene = cc.Director:getInstance():getRunningScene()
    local layer = cc.LayerColor:create(cc.c4b(0,0,0,150))
    scene:addChild(layer)

    local light = cc.Sprite:create("image/ui/img/btn/btn_343.png")
    light:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.8)
    layer:addChild(light)
    local rep = cc.RepeatForever:create(cc.RotateBy:create(3.0, 360))
    light:runAction(rep)
    -- 评分级别

    local sidai = cc.Sprite:create("image/ui/img/bg/bg_160.png")
    sidai:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.73)
    layer:addChild(sidai)

    local icon = cc.Sprite:create("image/ui/img/btn/btn_632.png")
    icon:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.8)
    icon:setScale(0.1)
    icon:runAction(cc.Sequence:create({cc.ScaleTo:create(0.1, 1.2),cc.ScaleTo:create(0.05, 1.0)}))
    layer:addChild(icon)

    local bg = cc.Sprite:create("image/ui/img/bg/bg_164.png")
    bg:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.4)
    layer:addChild(bg)

    local bgsize = bg:getContentSize()


    local label = Common.finalFont("打劫成功！！东风吹战鼓擂，我是流氓我怕谁！", bgsize.width*0.5, bgsize.height*0.8,26, cc.c3b(239,255,39))
    bg:addChild(label)


    local size = cc.size(380,80)
    local iconbg = ccui.ImageView:create("image/ui/img/bg/bg_161.png")
    iconbg:setScale9Enabled(true)
    iconbg:setContentSize(size)
    iconbg:setPosition(bgsize.width*0.5, bgsize.height*0.5)
    bg:addChild(iconbg)


    local exp = cc.Sprite:create("image/ui/img/btn/btn_671.png")
    exp:setPosition(70, size.height*0.5)
    iconbg:addChild(exp)

    local label = Common.finalFont("+"..result.Exp, 100, size.height*0.5,26, nil, 1)
    label:setAnchorPoint(0,0.5)
    iconbg:addChild(label)

    icon = cc.Sprite:create("image/ui/img/btn/btn_035.png")
    icon:setPosition(220, size.height*0.5)
    iconbg:addChild(icon)

    label = Common.finalFont("+"..result.Coin, 250, size.height*0.5,26,nil, 1)
    label:setAnchorPoint(0,0.5)
    iconbg:addChild(label)



    local btnImage = "image/ui/img/btn/btn_553.png"
    local btnBackToMap = ccui.MixButton:create(btnImage)
    btnBackToMap:setTitle("确定" , 26, cc.c3b(226,204,169), 1, cc.c4b(65,26,1,255))
    -- btnBackToMap:setVisible(false)
    btnBackToMap:setOpacity(0)
    btnBackToMap:setPosition(bgsize.width*0.5,60)
    bg:addChild(btnBackToMap)
    btnBackToMap:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            application:popScene()
            -- application:popScene()
        end
    end)
    btnBackToMap:runAction(cc.Sequence:create( cc.DelayTime:create(0.5), cc.FadeIn:create(0.2) ))

    local function onTouchBegan(touch, event)
        return true
    end
    local function onTouchEnded(touch, event)

    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)
end

function TransportLayer:battleFail( result )

    local layer = require("tool.helper.CommonLayer").BattleFailLayer(result)

    local scene = cc.Director:getInstance():getRunningScene()
    scene:addChild(layer)

    local btnImage = "image/ui/img/btn/btn_553.png"
    local btn_again = createMixSprite(btnImage)
    btn_again:setCircleFont("确定" , 1 , 1, 26, cc.c3b(226,204,169))
    btn_again:setFontOutline(cc.c4b(65,26,1,255), 1)
    btn_again:setFontPos(0.5,0.5)
    -- btn_again:setScale9Enabled(true)
    btn_again:setPosition(SCREEN_WIDTH*0.85,SCREEN_HEIGHT*0.18)
    layer:addChild(btn_again)
    btn_again:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            application:popScene()
            -- application:popScene()
        end
    end)
end



--- communicate with server

function TransportLayer:battleResult( result )
    local sessionID = result.sessionID
    local action = nil
    local iswin = false
    if result.result == "win" then
        iswin = true
    end
    rpc:call("Vehicle.EndF", {SessionID = sessionID, IsWin = iswin}, function ( event )
        if event.status == Exceptions.Nil then
            if iswin then
                self:battleWin(event.result)
            else
                self:battleFail(event.result)
            end

        end
    end, {show=false, debug=false, retryOnError = true} )
end


function TransportLayer:receiveConstance(  )
    rpc:call("Vehicle.GetConstDefine", nil, function ( event )
        if event.status == Exceptions.Nil and event.result ~= nil then
            self.constance = event.result
            self.curDstGain = self.constance.DST1_EXTRA_GAIN
        end
    end)
end

function TransportLayer:receiveTransportInfo()
    rpc:call("Vehicle.Init", nil, function(event)
        if event.status == Exceptions.Nil then
                self.transportInfo = event.result.Info
                self:createFlexUI()

                self.vehicles  = event.result.ShowList or {}
                if self.transportInfo == nil then
                    return
                end
                self:refreshVehicleLayer()
        end
    end)
end

function TransportLayer:receiveHistory(  )
    rpc:call("Vehicle.History", nil, function ( event )
        if event.status == Exceptions.Nil and event.result ~= nil then
            self.recordInfo = {}
            local hijackhis = event.result.AtkedHistory or {}
            local transhis = event.result.TransHistory or {}

            for i=1,#hijackhis do
                local record = {}
                record = hijackhis[i]
                if hijackhis[i].IsAtkWin then
                    record.type = 1
                else
                    record.type = 2
                end
                table.insert(self.recordInfo, record)
            end

            for i=1,#transhis do
                local record = {}
                record = transhis[i]
                record.type = 3
                table.insert(self.recordInfo, record)
            end

            table.sort(self.recordInfo,function ( a,b )
                return a.Order > b.Order
            end)
            self:addChild(self:createRecordUI())
        end
    end) 
end

function TransportLayer:hijackVehicle( vehicleId )
    rpc:call("Vehicle.BeforeF", { Enemy = vehicleId, }, function ( event )
        if event.status == Exceptions.Nil then
            local sessionID = event.result.SessionID
            local form = event.result.Form

            application:pushScene("form.BattleFormScene", GameCache.FORM_TYPE_VEHICLE, {
                battleType = "PVP", 
                battleSystem = enums.BattleSystem.Transport, 
                map = "YB_map", 
                sessionID = sessionID, 
                attackerForm = event.result.Form,   
                callback = handler(self, self.battleResult)
            } )
        end
    end)
end

return TransportLayer
