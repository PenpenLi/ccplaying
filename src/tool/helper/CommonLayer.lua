
local M =  {}

function M.ToBuyVIP( text ,  callFunc)

    local tovipLayer = cc.LayerColor:create(cc.c4b(0,0,0,150))

    local label = Common.systemFont(text , 0,0, 20)
    local label_size = label:getContentSize()
    local h = (math.ceil(label_size.width / 350)+1) * label_size.height

    label:setDimensions(350, h)

    local morebgsize = cc.size(450,h+160)
    local morebg = ccui.ImageView:create("image/ui/img/bg/bg_139.png")
    morebg:setScale9Enabled(true)
    morebg:setContentSize(morebgsize)
    morebg:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)
    tovipLayer:addChild(morebg)

    label:setAnchorPoint(0.5,1)
    label:setPosition(morebgsize.width*0.5, morebgsize.height-55)
    morebg:addChild(label)

    local title = cc.Sprite:create("image/ui/img/bg/bg_174.png")
    title:setPosition(morebgsize.width * 0.5, morebgsize.height - 10)
    morebg:addChild(title)
    local dian = cc.Sprite:create("image/ui/img/btn/btn_996.png")
    dian:setPosition(morebgsize.width * 0.5, morebgsize.height - 10)
    morebg:addChild(dian)

    local sprite = cc.Sprite:create("image/ui/img/btn/btn_811.png")
    sprite:setAnchorPoint(0.5,0)
    sprite:setPosition(morebgsize.width*0.5, 10)
    morebg:addChild(sprite)

    local ssize = sprite:getContentSize()

    local line = cc.Sprite:create("image/ui/img/btn/btn_810.png")
    line:setPosition(ssize.width*0.5, ssize.height)
    sprite:addChild(line)

    -- local btn = ccui.MixButton:create("image/ui/img/btn/btn_818.png")
    -- btn:setScale9Size(cc.size(135,55))
    -- btn:setTitle("算了",22,cc.c3b(238,205,142),1)
    -- btn:addTouchEventListener(function ( sender, eventType )
    --     if eventType == ccui.TouchEventType.ended then
    --         tovipLayer:removeFromParent()
    --         tovipLayer = nil
    --     end
    -- end)
    -- btn:setPosition(morebgsize.width*0.25, 45)
    -- morebg:addChild(btn)

    local btn_sure = ccui.MixButton:create("image/ui/img/btn/btn_818.png")
    btn_sure:setScale9Size(cc.size(135,55))
    btn_sure:setTitle("提升VIP",22,cc.c3b(238,205,142),1)
    btn_sure:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            application:pushScene("main.recharge.RechargeScene")
            tovipLayer:removeFromParent()
            tovipLayer = nil
            if callFunc then
                callFunc()
            end
        end
    end)
    btn_sure:setPosition(morebgsize.width*0.5, 45)
    morebg:addChild(btn_sure)

    local unuse = BaseConfig.getVipExp(1)
    if GameCache.Avatar.VIP == #BaseConfig.vipConfig then
        btn_sure:setStateEnabled(false)
    end


    local function onTouchBegan(touch, event)
        return true
    end
    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = morebg:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)
        
        if not cc.rectContainsPoint(rect, locationInNode) then
            tovipLayer:removeFromParent()
            tovipLayer = nil
        end     
    end
    local listener1 = cc.EventListenerTouchOneByOne:create()
    listener1:setSwallowTouches(true)
    listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener1:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = tovipLayer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, tovipLayer)

    return tovipLayer
end

function M.BattleFailLayer ( result )
    Common.playSound("audio/effect/SDE_UI_Dungeon_Lose.mp3")
    local layer = cc.LayerColor:create(cc.c4b(0,0,0,150))

    local bg1 = cc.Sprite:create("image/ui/img/bg/bg_163.png")
    bg1:setAnchorPoint(0,0)
    bg1:setPosition(0, 50)
    layer:addChild(bg1)

    local light = cc.Sprite:create("image/ui/img/btn/btn_332.png")
    light:setPosition(SCREEN_WIDTH*0.35, SCREEN_HEIGHT*0.8)
    layer:addChild(light)
    local rep = cc.RepeatForever:create(cc.RotateBy:create(3.0, 360))
    light:runAction(rep)


    local sprite = cc.Sprite:create("image/ui/img/btn/btn_333.png")
    sprite:setPosition(SCREEN_WIDTH*0.35, SCREEN_HEIGHT*0.8)
    layer:addChild(sprite)

    local icon = cc.Sprite:create("image/ui/img/btn/btn_633.png")
    icon:setPosition(SCREEN_WIDTH*0.35, SCREEN_HEIGHT*0.82)
    layer:addChild(icon)

    local iconbg = cc.Sprite:create("image/ui/img/bg/bg_159.png")
    iconbg:setPosition(SCREEN_WIDTH*0.35, SCREEN_HEIGHT*0.70)
    layer:addChild(iconbg)

    if result then
        local size = cc.size(200,60)
        if result.ArenaCredits or result.Medal then
            size = cc.size(330,60)
        end
        
        local hehe = ccui.ImageView:create("image/ui/img/bg/bg_x_111.png")
        hehe:setScale9Enabled(true)
        hehe:setContentSize(size)
        hehe:setPosition(SCREEN_WIDTH*0.35, SCREEN_HEIGHT*0.6)
        layer:addChild(hehe)
    
        local icon_exp = cc.Sprite:create("image/ui/img/btn/btn_671.png")
        icon_exp:setPosition(size.width*0.5-40, size.height*0.5)
        hehe:addChild(icon_exp)
    
        -- 经验
        local label_exp = Common.systemFont("+"..result.Exp, size.width*0.5, size.height*0.5,22, nil, 1)
        label_exp:setAnchorPoint(0,0.5)
        hehe:addChild(label_exp)    

        if result.ArenaCredits then
            label_exp:setPosition(100, size.height*0.5)
            icon_exp:setPosition(70, size.height*0.5)

            local icon = cc.Sprite:create("image/ui/img/btn/btn_1121.png")
            icon:setPosition(220, size.height*0.5)
            hehe:addChild(icon)

            local label_credit = Common.systemFont("+"..result.ArenaCredits, 240, size.height*0.5,26, nil, 1)
            label_credit:setAnchorPoint(0,0.5)
            hehe:addChild(label_credit)

        elseif result.Medal then
            label_exp:setPosition(100, size.height*0.5)
            icon_exp:setPosition(70, size.height*0.5)

            local icon = cc.Sprite:create("image/ui/img/btn/btn_1061.png")
            icon:setPosition(220, size.height*0.5)
            hehe:addChild(icon)

            local label_medal = Common.systemFont("+"..result.Medal, 240, size.height*0.5,26, nil, 1)
            label_medal:setAnchorPoint(0,0.5)
            hehe:addChild(label_medal)
        end
    end


    ---
    local texture = "image/ui/img/bg/bg_165.png"
    -- iconbg = cc.Sprite:create(texture)
    iconbg = createMixSprite(texture)
    iconbg:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            cc.Director:getInstance():popToRootScene()
            application:pushScene("main.hero.AllHeroScene")
        end
    end)    
    iconbg:setPosition(SCREEN_WIDTH*0.18, SCREEN_HEIGHT*0.43)
    layer:addChild(iconbg)

    local size = iconbg:getContentSize()

    local iconbg = iconbg:getBg()

    icon = cc.Sprite:create("dummy/qhxj.png")
    icon:setPosition(size.width*0.2, size.height*0.5)
    iconbg:addChild(icon)
    label = Common.systemFont("强化星将",size.width*0.4, size.height*0.62, 24, cc.c3b(255,237,135))
    label:setAnchorPoint(0,0.5)
    iconbg:addChild(label)
    label = Common.systemFont("升级/升星/法术",size.width*0.4, size.height*0.35, 20, cc.c3b(217,238,250))
    label:setAnchorPoint(0,0.5)
    iconbg:addChild(label)
    --




    -- iconbg = cc.Sprite:create(texture)
    iconbg = createMixSprite(texture)
    iconbg:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            cc.Director:getInstance():popToRootScene()
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
                application:pushScene("main.hero.EquipIntensifyScene")
            else
                application:showFlashNotice("没有星将穿戴有装备～！")
            end
        end
    end)        
    iconbg:setPosition(SCREEN_WIDTH*0.53, SCREEN_HEIGHT*0.43)
    layer:addChild(iconbg)

    local iconbg = iconbg:getBg()

    icon = cc.Sprite:create("dummy/qhzb.png")
    icon:setPosition(size.width*0.2, size.height*0.5)
    iconbg:addChild(icon)
    label = Common.systemFont("强化装备",size.width*0.4, size.height*0.62, 24, cc.c3b(255,237,135))
    label:setAnchorPoint(0,0.5)
    iconbg:addChild(label)
    label = Common.systemFont("升级/升星",size.width*0.4, size.height*0.35, 20, cc.c3b(217,238,250))
    label:setAnchorPoint(0,0.5)
    iconbg:addChild(label)
    --




    -- iconbg = cc.Sprite:create(texture)
    iconbg = createMixSprite(texture)
    iconbg:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            cc.Director:getInstance():popToRootScene()
            local handler = function(event)
                if event.status == Exceptions.Nil and event.result ~= nil then                    
                    local value = event.result
                    local infoTab = {}
                    local allInfo = {}
                    infoTab[1] = allInfo
                    local vipInfo = {}
                    infoTab[2] = vipInfo
                    local heroInfo = {}
                    infoTab[3] = heroInfo
                    local equipInfo = {}
                    infoTab[4] = equipInfo
                    
                    allInfo.AllBuyFreeCount = value.AllBuyFreeCount
                    allInfo.AllTotalFreeCount = value.AllTotalFreeCount
                    allInfo.AllNextFreeTime = value.AllNextFreeTime
                    allInfo.AllBuyCost = value.AllBuyCost
    
                    vipInfo.VipWeekHot = value.VipWeekHot
                    vipInfo.VipDailyHot = value.VipDailyHot
                    vipInfo.VipBuyCost = value.VipBuyCost
    
                    heroInfo.HeroNextFreeTime = value.HeroNextFreeTime
                    heroInfo.HeroBuyCost = value.HeroBuyCost
    
                    equipInfo.EquipNextFreeTime = value.EquipNextFreeTime
                    equipInfo.EquipBuyCost = value.EquipBuyCost
    
                    application:pushScene("main.gamble.GambleScene", infoTab) 
                end
            end
            rpc:call("Gamble.GetGambleInfo", nil, handler)
        end
    end)    
    iconbg:setPosition(SCREEN_WIDTH*0.18, SCREEN_HEIGHT*0.23)
    layer:addChild(iconbg)

    local iconbg = iconbg:getBg()

    icon = cc.Sprite:create("dummy/hqxj.png")
    icon:setPosition(size.width*0.2, size.height*0.5)
    iconbg:addChild(icon)
    label = Common.systemFont("获取更牛星将",size.width*0.4, size.height*0.62, 24, cc.c3b(255,237,135))
    label:setAnchorPoint(0,0.5)
    iconbg:addChild(label)
    label = Common.systemFont("打副本/开灵石",size.width*0.4, size.height*0.35, 20, cc.c3b(217,238,250))
    label:setAnchorPoint(0,0.5)
    iconbg:addChild(label)
    --



    -- iconbg = cc.Sprite:create(texture)
    iconbg = createMixSprite(texture)
    iconbg:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            cc.Director:getInstance():popToRootScene()
            local handler = function(event)
                if event.status == Exceptions.Nil and event.result ~= nil then                    
                    local value = event.result
                    local infoTab = {}
                    local allInfo = {}
                    infoTab[1] = allInfo
                    local vipInfo = {}
                    infoTab[2] = vipInfo
                    local heroInfo = {}
                    infoTab[3] = heroInfo
                    local equipInfo = {}
                    infoTab[4] = equipInfo
                    
                    allInfo.AllBuyFreeCount = value.AllBuyFreeCount
                    allInfo.AllTotalFreeCount = value.AllTotalFreeCount
                    allInfo.AllNextFreeTime = value.AllNextFreeTime
                    allInfo.AllBuyCost = value.AllBuyCost
    
                    vipInfo.VipWeekHot = value.VipWeekHot
                    vipInfo.VipDailyHot = value.VipDailyHot
                    vipInfo.VipBuyCost = value.VipBuyCost
    
                    heroInfo.HeroNextFreeTime = value.HeroNextFreeTime
                    heroInfo.HeroBuyCost = value.HeroBuyCost
    
                    equipInfo.EquipNextFreeTime = value.EquipNextFreeTime
                    equipInfo.EquipBuyCost = value.EquipBuyCost
    
                    application:pushScene("main.gamble.GambleScene", infoTab) 
                end
            end
            rpc:call("Gamble.GetGambleInfo", nil, handler)
        end
    end)    
    iconbg:setPosition(SCREEN_WIDTH*0.53, SCREEN_HEIGHT*0.23)
    layer:addChild(iconbg)

    local iconbg = iconbg:getBg()

    icon = cc.Sprite:create("dummy/hqzb.png")
    icon:setPosition(size.width*0.2, size.height*0.5)
    iconbg:addChild(icon)
    label = Common.systemFont("获取更强装备",size.width*0.4, size.height*0.62, 24, cc.c3b(255,237,135))
    label:setAnchorPoint(0,0.5)
    iconbg:addChild(label)
    label = Common.systemFont("打副本/开灵石",size.width*0.4, size.height*0.35, 20, cc.c3b(217,238,250))
    label:setAnchorPoint(0,0.5)
    iconbg:addChild(label)
    --

    local function onTouchBegan(touch, event)
        return true
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    local eventDispatcher = layer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)
    return layer
end


function M.PowerLayer(callFunc)

    local function createLayer( count , limit)

        local layer = cc.LayerColor:create(cc.c4b(0,0,0,180))
        local scene = cc.Director:getInstance():getRunningScene()
        scene:addChild(layer)
    
        local bgsize = cc.size(540,300)    
        local bg = ccui.ImageView:create("image/ui/img/bg/bg_175.png")
        bg:setPosition(SCREEN_WIDTH*0.5,SCREEN_HEIGHT*0.6)
        bg:setScale9Enabled(true)
        bg:setContentSize(bgsize)
        layer:addChild(bg)
    
        local icon = cc.Sprite:create("image/icon/props/power.png")
        icon:setPosition(75,bgsize.height*0.75)
        bg:addChild(icon)
    
        local label = Common.systemFont("今日已用" .. count .."/".. limit, 1, 1, 20, cc.c3b(120,246,103))
        label:setAnchorPoint(0.5,1)
        label:setPosition(bgsize.width*0.8,bgsize.height-20)
        bg:addChild(label)

    
        -- 上仙，花费50元宝回复50体力吧！
        local label1 = Common.systemFont("上仙，花费" , 1 , 1, 22)
        label1:setAnchorPoint(0,0.5)
        label1:setPosition(130, bgsize.height*0.75)
        bg:addChild(label1)
        


        local price = BaseConfig.GetBuyPriceNode( count+1 ).PowerPrice
        local label2 = Common.systemFont( price.."元宝" , 1 , 1, 22, cc.c3b(255,207,17))
        label2:setAnchorPoint(0,0.5)
        label2:setPosition(label1:getContentSize().width+label1:getPositionX(), bgsize.height*0.75)
        bg:addChild(label2)
    
        local label3 = Common.systemFont("回复" , 1 , 1, 22)
        label3:setAnchorPoint(0,0.5)
        label3:setPosition(label2:getContentSize().width+label2:getPositionX(), bgsize.height*0.75)
        bg:addChild(label3)
    
    
        local label4 = Common.systemFont(GameCache.Avatar.MaxPhyPower .. "体力" , 1 , 1, 22,cc.c3b(120,246,103))
        label4:setAnchorPoint(0,0.5)
        label4:setPosition(label3:getContentSize().width+label3:getPositionX(), bgsize.height*0.75)
        bg:addChild(label4)
    
         local label5 = Common.systemFont("吧！" , 1 , 1, 22)
        label5:setAnchorPoint(0,0.5)
        label5:setPosition(label4:getContentSize().width+label4:getPositionX(), bgsize.height*0.75)
        bg:addChild(label5)
    
    
        local sprite = cc.Sprite:create("image/ui/img/btn/btn_811.png")
        sprite:setPosition(bgsize.width*0.5, bgsize.height*0.5)
        bg:addChild(sprite)
        sprite:setScale(0.7)
    
        local ssize = sprite:getContentSize()
    
        local line1 = cc.Sprite:create("image/ui/img/btn/btn_810.png")
        line1:setPosition(ssize.width*0.5, ssize.height)
        sprite:addChild(line1)
        local line = cc.Sprite:create("image/ui/img/btn/btn_810.png")
        line:setPosition(ssize.width*0.5, 0)
        sprite:addChild(line)
    
    

        local jiantou = cc.Sprite:create("image/ui/img/btn/btn_809.png")
        jiantou:setPosition(275,bgsize.height*0.5)
        bg:addChild(jiantou)

    
        local label_price = Common.systemFont(price.."", 1, 1, 26,cc.c3b(120,246,103))
        label_price:setAnchorPoint(1,0.5)
        label_price:setPosition(230,bgsize.height*0.5)
        bg:addChild(label_price)    

        local icon_gold = cc.Sprite:create("image/ui/img/btn/btn_060.png")
        icon_gold:setPosition(label_price:getPositionX()-label_price:getContentSize().width-30,bgsize.height*0.5)
        bg:addChild(icon_gold)

        icon = cc.Sprite:create("image/ui/img/bg/tili.png")
        icon:setPosition(325,bgsize.height*0.5)
        bg:addChild(icon)
    
        label = Common.systemFont(GameCache.Avatar.MaxPhyPower .. "", 1, 1, 26,cc.c3b(120,246,103))
        label:setAnchorPoint(0,0.5)
        label:setPosition(350,bgsize.height*0.5)
        bg:addChild(label)
    
    
        local sprite = cc.Sprite:create("image/ui/img/btn/btn_811.png")
        sprite:setAnchorPoint(0.5,0)
        sprite:setPosition(bgsize.width*0.5, 10)
        bg:addChild(sprite)
    
        local ssize = sprite:getContentSize()
    
        local line = cc.Sprite:create("image/ui/img/btn/btn_810.png")
        line:setPosition(ssize.width*0.5, ssize.height)
        sprite:addChild(line)
    
    
        local btn = createMixScale9Sprite("image/ui/img/btn/btn_818.png", nil, nil, cc.size(135,60))
        btn:setCircleFont("取消",1,1,26,cc.c3b(238,205,142))
        btn:addTouchEventListener(function ( sender, eventType )
            if eventType == ccui.TouchEventType.ended then
                layer:removeFromParent()
                layer = nil
            end
        end)
        btn:setPosition(bgsize.width*0.25, 45)
        bg:addChild(btn)
    
        btn = createMixScale9Sprite("image/ui/img/btn/btn_818.png", nil, nil, cc.size(135,60))
        btn:setCircleFont("确定",1,1,26,cc.c3b(238,205,142))
        btn:addTouchEventListener(function ( sender, eventType )
            if eventType == ccui.TouchEventType.ended then

                if Common.isCostMoney(1001, price) then
                    rpc:call("Avatar.BuyPower", nil, function ( event )
                        if callFunc then
                            callFunc()
                        end
                    end)
                end
                layer:removeFromParent()
                layer = nil
            end
        end)
        btn:setPosition(bgsize.width*0.75, 45)
        bg:addChild(btn)
    
    
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
        local eventDispatcher = layer:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)

    end

    rpc:call("Avatar.GetBuyPowerInfo", nil, function ( event )
        if event.status == Exceptions.Nil and event.result ~= nil then
            local powerLimit = BaseConfig.getVipPrivilege(GameCache.Avatar.VIP).PowerCount
            
            if event.result >= powerLimit then
                local layer = M.ToBuyVIP("壕，今日体力购买次数已经用完了。提升VIP可获得更多购买次数噢")
                local scene = cc.Director:getInstance():getRunningScene()
                scene:addChild(layer)
                return
            end
            createLayer(event.result, powerLimit)
        end
    end)

end

function M.EnduranceLayer(callFunc)

    local function createLayer( count, limit )
        
        local layer = cc.LayerColor:create(cc.c4b(0,0,0,180))
        local scene = cc.Director:getInstance():getRunningScene()
        scene:addChild(layer)
    
        local bgsize = cc.size(540,300)    
        local bg = ccui.ImageView:create("image/ui/img/bg/bg_175.png")
        bg:setPosition(SCREEN_WIDTH*0.5,SCREEN_HEIGHT*0.6)
        bg:setScale9Enabled(true)
        bg:setContentSize(bgsize)
        layer:addChild(bg)
    
        local icon = cc.Sprite:create("image/icon/props/endurance.png")
        icon:setPosition(75,bgsize.height*0.75)
        bg:addChild(icon)

        local label = Common.systemFont("今日已用" .. count .."/".. limit, 1, 1, 20, cc.c3b(120,246,103))
        label:setAnchorPoint(0.5,1)
        label:setPosition(bgsize.width*0.8,bgsize.height-20)
        bg:addChild(label)
    
        local label1 = Common.systemFont("上仙，花费" , 1 , 1, 22)
        label1:setAnchorPoint(0,0.5)
        label1:setPosition(130, bgsize.height*0.75)
        bg:addChild(label1)
    
            local price = BaseConfig.GetBuyPriceNode( count+1 ).EndurancePrice
        local label2 = Common.systemFont(price.."元宝" , 1 , 1, 22, cc.c3b(255,207,17))
        label2:setAnchorPoint(0,0.5)
        label2:setPosition(label1:getContentSize().width+label1:getPositionX(), bgsize.height*0.75)
        bg:addChild(label2)
    
        local label3 = Common.systemFont("回复" , 1 , 1, 22)
        label3:setAnchorPoint(0,0.5)
        label3:setPosition(label2:getContentSize().width+label2:getPositionX(), bgsize.height*0.75)
        bg:addChild(label3)
    
    
        local label4 = Common.systemFont(GameCache.Avatar.MaxEndurance .. "耐力" , 1 , 1, 22,cc.c3b(120,246,103))
        label4:setAnchorPoint(0,0.5)
        label4:setPosition(label3:getContentSize().width+label3:getPositionX(), bgsize.height*0.75)
        bg:addChild(label4)
    
         local label5 = Common.systemFont("吧！" , 1 , 1, 22)
        label5:setAnchorPoint(0,0.5)
        label5:setPosition(label4:getContentSize().width+label4:getPositionX(), bgsize.height*0.75)
        bg:addChild(label5)
    
    
        local sprite = cc.Sprite:create("image/ui/img/btn/btn_811.png")
        sprite:setPosition(bgsize.width*0.5, bgsize.height*0.5)
        bg:addChild(sprite)
        sprite:setScale(0.7)
    
        local ssize = sprite:getContentSize()
    
        local line1 = cc.Sprite:create("image/ui/img/btn/btn_810.png")
        line1:setPosition(ssize.width*0.5, ssize.height)
        sprite:addChild(line1)
        local line = cc.Sprite:create("image/ui/img/btn/btn_810.png")
        line:setPosition(ssize.width*0.5, 0)
        sprite:addChild(line)
    
    
        local jiantou = cc.Sprite:create("image/ui/img/btn/btn_809.png")
        jiantou:setPosition(275,bgsize.height*0.5)
        bg:addChild(jiantou)

    
        local label_price = Common.systemFont(price.."", 1, 1, 26,cc.c3b(120,246,103))
        label_price:setAnchorPoint(1,0.5)
        label_price:setPosition(230,bgsize.height*0.5)
        bg:addChild(label_price)    

        local icon_gold = cc.Sprite:create("image/ui/img/btn/btn_060.png")
        icon_gold:setPosition(label_price:getPositionX()-label_price:getContentSize().width-30,bgsize.height*0.5)
        bg:addChild(icon_gold)
    
        icon = cc.Sprite:create("image/ui/img/bg/naili.png")
        icon:setPosition(325,bgsize.height*0.5)
        bg:addChild(icon)
    
        label = Common.systemFont(GameCache.Avatar.MaxEndurance .. "" , 1, 1, 26,cc.c3b(120,246,103))
        label:setAnchorPoint(0,0.5)
        label:setPosition(350,bgsize.height*0.5)
        bg:addChild(label)
    
    
        local sprite = cc.Sprite:create("image/ui/img/btn/btn_811.png")
        sprite:setAnchorPoint(0.5,0)
        sprite:setPosition(bgsize.width*0.5, 10)
        bg:addChild(sprite)
    
        local ssize = sprite:getContentSize()
    
        local line = cc.Sprite:create("image/ui/img/btn/btn_810.png")
        line:setPosition(ssize.width*0.5, ssize.height)
        sprite:addChild(line)
    
    
        local btn = createMixScale9Sprite("image/ui/img/btn/btn_818.png", nil, nil, cc.size(135,60))
        btn:setCircleFont("取消",1,1,26,cc.c3b(238,205,142))
        btn:addTouchEventListener(function ( sender, eventType )
            if eventType == ccui.TouchEventType.ended then
                layer:removeFromParent()
                layer = nil
            end
        end)
        btn:setPosition(bgsize.width*0.25, 45)
        bg:addChild(btn)
    
        btn = createMixScale9Sprite("image/ui/img/btn/btn_818.png", nil, nil, cc.size(135,60))
        btn:setCircleFont("确定",1,1,26,cc.c3b(238,205,142))
        btn:addTouchEventListener(function ( sender, eventType )
            if eventType == ccui.TouchEventType.ended then
                if Common.isCostMoney(1001, price) then
                    rpc:call("Avatar.BuyEndurance", nil, function ( event )
                        if callFunc then
                            callFunc()
                        end
                    end)
                end
                layer:removeFromParent()
                layer = nil
            end
        end)
        btn:setPosition(bgsize.width*0.75, 45)
        bg:addChild(btn)
    
    
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
        local eventDispatcher = layer:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)
    
    end

    rpc:call("Avatar.GetBuyEnduranceInfo", nil, function ( event )
        if event.status == Exceptions.Nil and event.result ~= nil then
            local enduranceLimit = BaseConfig.getVipPrivilege(GameCache.Avatar.VIP).EnduranceCount
            if event.result >= enduranceLimit then
                local layer = M.ToBuyVIP("壕，今日体力购买次数已经用完了。提升VIP可获得更多购买次数噢")
                local scene = cc.Director:getInstance():getRunningScene()
                scene:addChild(layer)
                return
            end
            createLayer(event.result, enduranceLimit)
        end
    end)


end

function M.PowerFromProps(  )

    local usedProps = false
    local layer = cc.LayerColor:create(cc.c4b(0,0,0,180))
    local scene = cc.Director:getInstance():getRunningScene()
    scene:addChild(layer)

    local bgsize = cc.size(480,300)    
    local bg = ccui.ImageView:create("image/ui/img/bg/bg_175.png")
    bg:setPosition(SCREEN_WIDTH*0.5,SCREEN_HEIGHT*0.5)
    bg:setScale9Enabled(true)
    bg:setContentSize(bgsize)
    layer:addChild(bg)


    local label1 = Common.systemFont("上仙，快使用" , 1 , 1, 22)
    label1:setAnchorPoint(0,0.5)
    label1:setPosition(100, bgsize.height*0.8)
    bg:addChild(label1)

    local label2 = Common.systemFont("人参果" , 1 , 1, 22, cc.c3b(255,207,17))
    label2:setAnchorPoint(0,0.5)
    label2:setPosition(label1:getContentSize().width+label1:getPositionX(), bgsize.height*0.8)
    bg:addChild(label2)

    local label3 = Common.systemFont("回复" , 1 , 1, 22)
    label3:setAnchorPoint(0,0.5)
    label3:setPosition(label2:getContentSize().width+label2:getPositionX(), bgsize.height*0.8)
    bg:addChild(label3)

    local label4 = Common.systemFont("体力" , 1 , 1, 22, cc.c3b(120,246,103))
    label4:setAnchorPoint(0,0.5)
    label4:setPosition(label3:getContentSize().width+label3:getPositionX(), bgsize.height*0.8)
    bg:addChild(label4)


    for i=1,3 do
        local id = i+1161
        local goodsInfo = GameCache.GetProps(id)
        if not goodsInfo then
            goodsInfo = {ID = id, Type = BaseConfig.GT_PROPS, Num = 0 }
        end

        local name = BaseConfig.GetProps(id).name
        local value =  BaseConfig.GetProps(id).useValue

        local goodsItem = Common.getGoods(goodsInfo, false, BaseConfig.GOODS_BIGTYPE)
        goodsItem:setTips(false)
        goodsItem:setPosition(bgsize.width*i*0.25, bgsize.height*0.5)
        bg:addChild(goodsItem)
        goodsItem:addTouchEventListener(function ( sender, eventType )
            if eventType == ccui.TouchEventType.ended then
                goodsItem:setTouchEnable(false)
                if goodsInfo.Num == 0 then
                    application:showFlashNotice("木有"..name)
                    goodsItem:setTouchEnable(true)
                    return
                end
                rpc:call("Props.Use", {ID = id}, function ( event )
                    goodsItem:setTouchEnable(true)

                    if event.status == Exceptions.Nil and event.result then

                        GameCache.GetProps(id).Num = GameCache.GetProps(id).Num - 1
                        goodsItem:setNum(GameCache.GetProps(id).Num)

                        usedProps = true
                        application:showFlashNotice("上仙，您食用"..name.."后，神清气爽，体力+"..value)
                    end
                end)
            end
        end)


        local label_name = Common.systemFont(name , 1 , 1, 18, cc.c3b(120,246,103))
        label_name:setPosition(0, -75)
        goodsItem:addChild(label_name)

        local icon = cc.Sprite:create("image/ui/img/bg/tili.png")
        icon:setAnchorPoint(1,0.5)
        icon:setPosition(-5, -110)
        goodsItem:addChild(icon)

        local label_value = Common.systemFont("+"..value , 1 , 1, 18, cc.c3b(120,246,103))
        label_value:setAnchorPoint(0,0.5)
        label_value:setPosition(5, -110)
        goodsItem:addChild(label_value)


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
            if not usedProps then
                M.PowerLayer()
            end
        end
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = layer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)


end

function M.NeedPower(  )
    local x = false
    for id=1162,1164 do
        x = GameCache.GetProps(id)
        if x and x.Num > 0 then
            M.PowerFromProps()
            return
        end
    end

    M.PowerLayer()

end

function M.EnduranceFromProps(  )

    local usedProps = false
    local layer = cc.LayerColor:create(cc.c4b(0,0,0,180))
    local scene = cc.Director:getInstance():getRunningScene()
    scene:addChild(layer)

    local bgsize = cc.size(480,300)    
    local bg = ccui.ImageView:create("image/ui/img/bg/bg_175.png")
    bg:setPosition(SCREEN_WIDTH*0.5,SCREEN_HEIGHT*0.5)
    bg:setScale9Enabled(true)
    bg:setContentSize(bgsize)
    layer:addChild(bg)


    local label1 = Common.systemFont("上仙，快使用" , 1 , 1, 22)
    label1:setAnchorPoint(0,0.5)
    label1:setPosition(100, bgsize.height*0.8)
    bg:addChild(label1)

    local label2 = Common.systemFont("蟠桃" , 1 , 1, 22, cc.c3b(255,207,17))
    label2:setAnchorPoint(0,0.5)
    label2:setPosition(label1:getContentSize().width+label1:getPositionX(), bgsize.height*0.8)
    bg:addChild(label2)

    local label3 = Common.systemFont("回复" , 1 , 1, 22)
    label3:setAnchorPoint(0,0.5)
    label3:setPosition(label2:getContentSize().width+label2:getPositionX(), bgsize.height*0.8)
    bg:addChild(label3)

    local label4 = Common.systemFont("耐力" , 1 , 1, 22, cc.c3b(120,246,103))
    label4:setAnchorPoint(0,0.5)
    label4:setPosition(label3:getContentSize().width+label3:getPositionX(), bgsize.height*0.8)
    bg:addChild(label4)


    for i=1,3 do
        local id = i+1164
        local goodsInfo = GameCache.GetProps(id)
        if not goodsInfo then
            goodsInfo = {ID = id, Type = BaseConfig.GT_PROPS, Num = 0 }
        end

        local name = BaseConfig.GetProps(id).name
        local value =  BaseConfig.GetProps(id).useValue

        local goodsItem = Common.getGoods(goodsInfo, false, BaseConfig.GOODS_BIGTYPE)
        goodsItem:setTips(false)
        goodsItem:setPosition(bgsize.width*i*0.25, bgsize.height*0.5)
        bg:addChild(goodsItem)
        goodsItem:addTouchEventListener(function ( sender, eventType )
            if eventType == ccui.TouchEventType.ended then
                goodsItem:setTouchEnable(false)
                if goodsInfo.Num == 0 then
                    application:showFlashNotice("木有"..name)
                    goodsItem:setTouchEnable(true)
                    return
                end
                rpc:call("Props.Use", {ID = id}, function ( event )
                    goodsItem:setTouchEnable(true)

                    if event.status == Exceptions.Nil and event.result then

                        GameCache.GetProps(id).Num = GameCache.GetProps(id).Num - 1
                        goodsItem:setNum(GameCache.GetProps(id).Num)

                        usedProps = true
                        application:showFlashNotice("上仙，您食用"..name.."后，身轻体健，耐力+"..value)
                    end
                end)
            end
        end)


        local label_name = Common.systemFont(name , 1 , 1, 18, cc.c3b(120,246,103))
        label_name:setPosition(0, -75)
        goodsItem:addChild(label_name)

        local icon = cc.Sprite:create("image/ui/img/bg/naili.png")
        icon:setAnchorPoint(1,0.5)
        icon:setPosition(-5, -110)
        goodsItem:addChild(icon)

        local label_value = Common.systemFont("+"..value , 1 , 1, 18, cc.c3b(120,246,103))
        label_value:setAnchorPoint(0,0.5)
        label_value:setPosition(5, -110)
        goodsItem:addChild(label_value)


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
            if not usedProps then
                M.EnduranceLayer()
            end
        end
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = layer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)


end

function M.NeedEndurance(  )
    local x = false
    for id=1165,1167 do
        x = GameCache.GetProps(id)
        if x and x.Num > 0 then
            M.EnduranceFromProps()
            return
        end
    end

    M.EnduranceLayer()

end

function M.InstanceCountLayer(nodeid, diff, usedCount, reset_str , callFunc)

    local function createLayer( count , limit, resetstr)

        local layer = cc.LayerColor:create(cc.c4b(0,0,0,180))
        local scene = cc.Director:getInstance():getRunningScene()
        scene:addChild(layer)
    
        local bgsize = cc.size(540,300)    
        local bg = ccui.ImageView:create("image/ui/img/bg/bg_175.png")
        bg:setPosition(SCREEN_WIDTH*0.5,SCREEN_HEIGHT*0.6)
        bg:setScale9Enabled(true)
        bg:setContentSize(bgsize)
        layer:addChild(bg)
    
        -- local icon = cc.Sprite:create("image/icon/props/power.png")
        -- icon:setPosition(75,bgsize.height*0.75)
        -- bg:addChild(icon)
    
        local label = Common.systemFont("今日已用" .. count .."/".. limit, 1, 1, 20, cc.c3b(120,246,103))
        label:setAnchorPoint(0.5,1)
        label:setPosition(bgsize.width*0.8,bgsize.height-20)
        bg:addChild(label)

    
        -- 上仙，花费50元宝回复50体力吧！
        local label1 = Common.systemFont("上仙，花费" , 1 , 1, 24)
        label1:setAnchorPoint(0,0.5)
        label1:setPosition(55, bgsize.height*0.75)
        bg:addChild(label1)
        


        local price = math.ldexp(20,math.floor(count/2))
        local label2 = Common.systemFont( price.."元宝" , 1 , 1, 24, cc.c3b(255,207,17))
        label2:setAnchorPoint(0,0.5)
        label2:setPosition(label1:getContentSize().width+label1:getPositionX(), bgsize.height*0.75)
        bg:addChild(label2)
    
        local label3 = Common.systemFont("重置" , 1 , 1, 24,cc.c3b(120,246,103))
        label3:setAnchorPoint(0,0.5)
        label3:setPosition(label2:getContentSize().width+label2:getPositionX(), bgsize.height*0.75)
        bg:addChild(label3)
    
    
        local label4 = Common.systemFont("当前关卡挑战次数" , 1 , 1, 24)
        label4:setAnchorPoint(0,0.5)
        label4:setPosition(label3:getContentSize().width+label3:getPositionX(), bgsize.height*0.75)
        bg:addChild(label4)
    
        --  local label5 = Common.systemFont("通关次数吧!" , 1 , 1, 24)
        -- label5:setAnchorPoint(0,0.5)
        -- label5:setPosition(label4:getContentSize().width+label4:getPositionX(), bgsize.height*0.75)
        -- bg:addChild(label5)
    
    
        local sprite = cc.Sprite:create("image/ui/img/btn/btn_811.png")
        sprite:setPosition(bgsize.width*0.5, bgsize.height*0.5)
        bg:addChild(sprite)
        sprite:setScale(0.7)
    
        local ssize = sprite:getContentSize()
    
        local line1 = cc.Sprite:create("image/ui/img/btn/btn_810.png")
        line1:setPosition(ssize.width*0.5, ssize.height)
        sprite:addChild(line1)
        local line = cc.Sprite:create("image/ui/img/btn/btn_810.png")
        line:setPosition(ssize.width*0.5, 0)
        sprite:addChild(line)
    
    
        icon = cc.Sprite:create("image/ui/img/btn/btn_060.png")
        icon:setPosition(180,bgsize.height*0.5)
        bg:addChild(icon)
    
        label = Common.systemFont(price.."", 1, 1, 26,cc.c3b(120,246,103))
        label:setAnchorPoint(0,0.5)
        label:setPosition(205,bgsize.height*0.5)
        bg:addChild(label)
    
    
        icon = cc.Sprite:create("image/ui/img/btn/btn_809.png")
        icon:setPosition(275,bgsize.height*0.5)
        bg:addChild(icon)
    
        -- icon = cc.Sprite:create("image/ui/img/bg/tili.png")
        -- icon:setPosition(325,bgsize.height*0.5)
        -- bg:addChild(icon)

        -- label = Common.systemFont("通关次数", 1, 1, 26)
        -- label:setAnchorPoint(0,0.5)
        -- label:setPosition(300,bgsize.height*0.5)
        -- bg:addChild(label)     
    
        label = Common.systemFont(resetstr, 1, 1, 26,cc.c3b(120,246,103))
        label:setAnchorPoint(0,0.5)
        label:setPosition(320,bgsize.height*0.5)
        bg:addChild(label)
    
    
        local sprite = cc.Sprite:create("image/ui/img/btn/btn_811.png")
        sprite:setAnchorPoint(0.5,0)
        sprite:setPosition(bgsize.width*0.5, 10)
        bg:addChild(sprite)
    
        local ssize = sprite:getContentSize()
    
        local line = cc.Sprite:create("image/ui/img/btn/btn_810.png")
        line:setPosition(ssize.width*0.5, ssize.height)
        sprite:addChild(line)
    
    
        local btn = createMixScale9Sprite("image/ui/img/btn/btn_818.png", nil, nil, cc.size(135,60))
        btn:setCircleFont("取消",1,1,26,cc.c3b(238,205,142))
        btn:addTouchEventListener(function ( sender, eventType )
            if eventType == ccui.TouchEventType.ended then
                layer:removeFromParent()
                layer = nil
            end
        end)
        btn:setPosition(bgsize.width*0.25, 45)
        bg:addChild(btn)
    
        btn = createMixScale9Sprite("image/ui/img/btn/btn_818.png", nil, nil, cc.size(135,60))
        btn:setCircleFont("确定",1,1,26,cc.c3b(238,205,142))
        btn:addTouchEventListener(function ( sender, eventType )
            if eventType == ccui.TouchEventType.ended then

                if Common.isCostMoney(1001, price) then
                    rpc:call("Instance.ResetChallengeCount", {DiffLevel = diff, NodeID = nodeid}, function ( event )
                        if event.result and callFunc then
                            callFunc()
                        end
                    end)
                end
                layer:removeFromParent()
                layer = nil
            end
        end)
        btn:setPosition(bgsize.width*0.75, 45)
        bg:addChild(btn)
    
    
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
        local eventDispatcher = layer:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)

    end


    local InstanceCountLimit = BaseConfig.getVipPrivilege(GameCache.Avatar.VIP).ResetInstanceCount

    if InstanceCountLimit <= 0 then
        local layer = M.ToBuyVIP("今日本场通关次数已用完，提升VIP可获得更多重置机会")
        local scene = cc.Director:getInstance():getRunningScene()
        scene:addChild(layer)
        return
    end

    if usedCount >= InstanceCountLimit then
        application:showFlashNotice("壕，今日本场重置次数已经买完了，换一场如何？")
        return
    end
    createLayer(usedCount, InstanceCountLimit, reset_str)

end

function M.BuyPropsLayer(propsID, callFunc)
    local propsConfig = BaseConfig.GetProps(propsID)
    local node = cc.Node:create()
    local bgLayer = cc.LayerColor:create(cc.c4b(0,0,0,120), SCREEN_WIDTH, SCREEN_HEIGHT)
    bgLayer:setPosition(0, 0)
    node:addChild(bgLayer)

    local bgSize = cc.size(460, 180)
    local bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
    bg:setContentSize(bgSize)
    bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    node:addChild(bg)

    local zorder = 2
    local costGold = nil
    if propsID == 1204 then
        costGold = 20
    elseif propsID == 1205 then
        costGold = 40
    end
    local desc = Common.systemFont("是否花费"..costGold.."元宝购买"..propsConfig.name, 1, 1, 25, nil, 1)
    desc:setPosition(bgSize.width * 0.5, bgSize.height * 0.68)
    bg:addChild(desc, zorder)

    local function btnTouchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local name = sender:getName()
            if "sure" == name then
                if Common.isCostMoney(1001, costGold) then
                    if callFunc then
                        callFunc()
                    end
                end
            end
            node:removeFromParent()
            node = nil
        end
    end
    local btn_cancel = createMixSprite("image/ui/img/btn/btn_593.png")
    btn_cancel:setCircleFont("取消", 1, 1, 25, cc.c3b(248, 216, 136), 1)
    btn_cancel:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
    btn_cancel:setPosition(bgSize.width * 0.28, bgSize.height * 0.3)
    bg:addChild(btn_cancel, zorder)
    btn_cancel:setName("cancel")
    btn_cancel:addTouchEventListener(btnTouchEvent)
    local btn_sure = createMixSprite("image/ui/img/btn/btn_593.png")
    btn_sure:setCircleFont("购买并使用", 1, 1, 25, cc.c3b(248, 216, 136), 1)
    btn_sure:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
    btn_sure:setPosition(bgSize.width * 0.72, bgSize.height * 0.3)
    bg:addChild(btn_sure, zorder)
    btn_sure:setName("sure")
    btn_sure:addTouchEventListener(btnTouchEvent)

    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)
        if not cc.rectContainsPoint(rect, locationInNode) then
            node:removeFromParent()
            node = nil
        end
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(function()  return true  end,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, bg)
    return node
end

function M.HintPanel(descStr, callFunc, isCancel, cancelFunc, goDesc, sureName, cancelName)
    local panel = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
    panel:setContentSize(cc.size(550, 250))
    panel:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    local panelSize = panel:getContentSize()

    local title = cc.Sprite:create("image/ui/img/bg/bg_174.png")
    title:setPosition(panelSize.width * 0.5, panelSize.height * 0.95)
    panel:addChild(title)
    local dian = cc.Sprite:create("image/ui/img/btn/btn_996.png")
    dian:setPosition(panelSize.width * 0.5, panelSize.height * 0.95)
    panel:addChild(dian)

    local desc = Common.systemFont(descStr, 1, 1, 22, nil, 1)
    desc:setPosition(panelSize.width * 0.5, panelSize.height * 0.75)
    desc:setAnchorPoint(0.5, 1)
    panel:addChild(desc)

    local btnBG = cc.Sprite:create("image/ui/img/btn/btn_811.png")
    btnBG:setPosition(panelSize.width * 0.5, panelSize.height * 0.2)
    panel:addChild(btnBG)
    local btn_sure = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(140, 60))
    btn_sure:setName("btn_sure")
    btn_sure:setCircleFont(sureName or "确定", 1, 1, 25, cc.c3b(248, 216, 136), 1)
    btn_sure:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
    btn_sure:setPosition(panelSize.width * 0.5, panelSize.height * 0.2)
    panel:addChild(btn_sure)
    btn_sure:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if callFunc then
                callFunc()
            end
            panel:removeFromParent()
            panel = nil
        end
    end)
    if goDesc then
        local lab = btn_sure:getFont()
        lab:setString(goDesc)
        lab:setAdditionalKerning(-3)
    end

    if isCancel then
        btn_sure:setPosition(panelSize.width * 0.7, panelSize.height * 0.2)

        local btn_cancel = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(140, 60))
        btn_cancel:setName("btn_cancel")
        btn_cancel:setCircleFont(cancelName or "取消", 1, 1, 25, cc.c3b(248, 216, 136), 1)
        btn_cancel:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
        btn_cancel:setPosition(panelSize.width * 0.3, panelSize.height * 0.2)
        panel:addChild(btn_cancel)
        btn_cancel:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                if cancelFunc then
                    cancelFunc()
                end
                panel:removeFromParent()
                panel = nil
            end
        end)
    end

    local function onTouchBegan(touch, event)
        return true
    end
    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if not cc.rectContainsPoint(rect, locationInNode) then
            panel:removeFromParent()
            panel = nil
        end
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = panel:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, panel)
    
    local runningScene = cc.Director:getInstance():getRunningScene()
    runningScene:addChild(panel, 999999)

    return panel
end

function M.AlertPanel(descStr, callFunc, isCancel, cancelFunc, goDesc)
    local panel = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
    panel:setContentSize(cc.size(550, 250))
    panel:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    local panelSize = panel:getContentSize()

    local title = cc.Sprite:create("image/ui/img/bg/bg_174.png")
    title:setPosition(panelSize.width * 0.5, panelSize.height * 0.95)
    panel:addChild(title)
    local dian = cc.Sprite:create("image/ui/img/btn/btn_996.png")
    dian:setPosition(panelSize.width * 0.5, panelSize.height * 0.95)
    panel:addChild(dian)

    local desc = Common.systemFont(descStr, 1, 1, 22, nil, 1)
    desc:setPosition(panelSize.width * 0.5, panelSize.height * 0.75)
    desc:setAnchorPoint(0.5, 1)
    panel:addChild(desc)

    local btnBG = cc.Sprite:create("image/ui/img/btn/btn_811.png")
    btnBG:setPosition(panelSize.width * 0.5, panelSize.height * 0.2)
    panel:addChild(btnBG)
    local btn_sure = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(140, 60))
    btn_sure:setCircleFont("确定", 1, 1, 25, cc.c3b(248, 216, 136), 1)
    btn_sure:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
    btn_sure:setPosition(panelSize.width * 0.5, panelSize.height * 0.2)
    panel:addChild(btn_sure)
    btn_sure:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if callFunc then
                callFunc()
            end
            panel:removeFromParent()
            panel = nil
        end
    end)
    if goDesc then
        local lab = btn_sure:getFont()
        lab:setString(goDesc)
        lab:setAdditionalKerning(-3)
    end

    if isCancel then
        btn_sure:setPosition(panelSize.width * 0.7, panelSize.height * 0.2)

        local btn_cancel = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(140, 60))
        btn_cancel:setCircleFont("取消", 1, 1, 25, cc.c3b(248, 216, 136), 1)
        btn_cancel:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
        btn_cancel:setPosition(panelSize.width * 0.3, panelSize.height * 0.2)
        panel:addChild(btn_cancel)
        btn_cancel:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                if cancelFunc then
                    cancelFunc()
                end
                panel:removeFromParent()
                panel = nil
            end
        end)
    end

    local function onTouchBegan(touch, event)
        return true
    end
    local function onTouchEnded(touch, event)

    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = panel:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, panel)
    
    local runningScene = cc.Director:getInstance():getRunningScene()
    runningScene:addChild(panel, 999999)

    return panel
end

function M.buyGoldAlert(goldCost, useDesc, callFunc)
    local panel = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
    panel:setContentSize(cc.size(520, 250))
    panel:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    local panelSize = panel:getContentSize()

    local title = cc.Sprite:create("image/ui/img/bg/bg_174.png")
    title:setPosition(panelSize.width * 0.5, panelSize.height * 0.95)
    panel:addChild(title)
    local dian = cc.Sprite:create("image/ui/img/btn/btn_996.png")
    dian:setPosition(panelSize.width * 0.5, panelSize.height * 0.95)
    panel:addChild(dian)

    local desc = Common.systemFont("是否花费", 1, 1, 20, nil, 1)
    desc:setPosition(panelSize.width * 0.3, panelSize.height * 0.65)
    panel:addChild(desc)
    local goldSpri = cc.Sprite:create("image/ui/img/btn/btn_060.png")
    goldSpri:setPosition(panelSize.width * 0.42, panelSize.height * 0.65)
    panel:addChild(goldSpri)
    local goldCostLab = Common.finalFont(goldCost, 1, 1, 20, cc.c3b(255, 240, 0), 1)
    goldCostLab:setAnchorPoint(0, 0.5)
    goldCostLab:setPosition(panelSize.width * 0.45, panelSize.height * 0.65)
    panel:addChild(goldCostLab)
    local desc = Common.systemFont(useDesc, 1, 1, 20, nil, 1)
    desc:setAnchorPoint(0, 0.5)
    desc:setPosition(panelSize.width * 0.55, panelSize.height * 0.65)
    panel:addChild(desc)
    desc:setPositionX(goldCostLab:getPositionX() + goldCostLab:getContentSize().width + 5)

    local btnBG = cc.Sprite:create("image/ui/img/btn/btn_811.png")
    btnBG:setPosition(panelSize.width * 0.5, panelSize.height * 0.2)
    panel:addChild(btnBG)
    local btn_sure = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(120, 60))
    btn_sure:setCircleFont("确定", 1, 1, 25, cc.c3b(248, 216, 136), 1)
    btn_sure:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
    btn_sure:setPosition(panelSize.width * 0.5, panelSize.height * 0.2)
    panel:addChild(btn_sure)
    btn_sure:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if callFunc then
                callFunc()
            end
            panel:removeFromParent()
            panel = nil
        end
    end)

    local function onTouchBegan(touch, event)
        return true
    end
    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if not cc.rectContainsPoint(rect, locationInNode) then
            panel:removeFromParent()
            panel = nil
        end
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = panel:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, panel)
    
    local runningScene = cc.Director:getInstance():getRunningScene()
    runningScene:addChild(panel)
end

return M