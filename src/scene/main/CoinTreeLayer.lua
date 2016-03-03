--
-- Author: keyring
-- Date: 2015-03-03 15:12:00
--
local EffectManager = require("tool.helper.Effects")

local CoinTreeLayer = class("CoinTreeLayer", BaseLayer)
local CommonLayer = require("tool.helper.CommonLayer")

function CoinTreeLayer:ctor(taskID, updateFunc)
    self.taskID = taskID
    self.updateFunc = updateFunc
	rpc:call("Avatar.GetBuyCoinInfo",nil,handler(self,self.createCoinTreeLayer))
    -- rpc:call("Avatar.GetBuyCoinInfo",nil,function ( event )
    --     self.createCoinTreeLayer(self,event)
    -- end)

end

function CoinTreeLayer:createCoinTreeLayer( event )
    if event.status ~= Exceptions.Nil then
        return
    end
	self.controls = {}
    coinTreeUse = {}
    local vipnode = BaseConfig.getVipPrivilege( GameCache.Avatar.VIP )
    coinTreeUse.UseCount = event.result
    coinTreeUse.TotalCount = vipnode.CoinTreeCount

    local scene = cc.Director:getInstance():getRunningScene()
    local layer = cc.LayerColor:create(cc.c4b(0,0,0,180))
    scene:addChild(layer)

    local bgsize = cc.size(565,230)    
    local bg = ccui.ImageView:create("image/ui/img/bg/bg_175.png")
    bg:setPosition(SCREEN_WIDTH*0.5,SCREEN_HEIGHT*0.6)
    bg:setScale9Enabled(true)
    bg:setContentSize(bgsize)
    layer:addChild(bg)

    -- local btn_close = createMixSprite("image/ui/img/btn/btn_598.png")
    -- btn_close:setPosition(bgsize.width-10, bgsize.height-10)
    -- btn_close:addTouchEventListener(function ( sender, eventType )
    --     if eventType == ccui.TouchEventType.ended then

    --     end
    -- end)
    -- bg:addChild(btn_close)



    local cointree_animation = EffectManager:CreateAnimation( bg, 90, -20, nil, 12 , false)

    local label = Common.finalFont("今日已用" .. coinTreeUse.UseCount .."/".. coinTreeUse.TotalCount, 1, 1, 20, cc.c3b(120,246,103))
    label:setAnchorPoint(0.5,0)
    label:setPosition(450,bgsize.height)
    bg:addChild(label)
    self.controls.countlabel = label

    label = Common.finalFont("用少量元宝换取大量银币", 1, 1, 20)
    label:setPosition(410,bgsize.height*0.75)
    bg:addChild(label)


    local layerColor = cc.LayerColor:create(cc.c4b(0,0,0,0), bgsize.width, bgsize.height *0.3)
    layerColor:setPosition(0,80)
    bg:addChild(layerColor)
    local size = layerColor:getContentSize()
    self.controls.layerColor = layerColor



    -- 如果次数不够了或者元宝不够了，需要更改界面
    if coinTreeUse.UseCount == coinTreeUse.TotalCount then
        layerColor:removeAllChildren()
        local label = Common.finalFont("今日摇钱次数已经用完，提升\nVIP等级可以增加摇钱次数", 1, 1, 18, cc.c3b(238,205,142))
        label:setPosition(410,size.height*0.5)
        layerColor:addChild(label)
    else
        local icon = cc.Sprite:create("image/ui/img/btn/btn_060.png")
        icon:setPosition(305,size.height*0.5)
        layerColor:addChild(icon)
    
        local str = BaseConfig.GetCointreeNode(coinTreeUse.UseCount+1).gold
        local label = Common.finalFont(str, 1, 1, 22,cc.c3b(120,246,103))
        label:setAnchorPoint(0,0.5)
        label:setPosition(330,size.height*0.5)
        layerColor:addChild(label)
        self.controls.goldlabel = label
    
        icon = cc.Sprite:create("image/ui/img/btn/btn_809.png")
        icon:setPosition(390,size.height*0.5)
        layerColor:addChild(icon)
    
        icon = cc.Sprite:create("image/ui/img/btn/btn_035.png")
        icon:setPosition(435,size.height*0.5)
        layerColor:addChild(icon)
    
        local str = BaseConfig.GetCointreeNode(coinTreeUse.UseCount+1).coin
        label = Common.finalFont(str, 1, 1, 22,cc.c3b(120,246,103))
        label:setAnchorPoint(0,0.5)
        label:setPosition(465,size.height*0.5)
        layerColor:addChild(label)
        self.controls.coinlabel = label        



        if GameCache.Avatar.Gold < BaseConfig.GetCointreeNode(coinTreeUse.UseCount+1).gold then
            self.controls.goldlabel:setColor(cc.c3b(230,40,30))
            -- self.controls.buttonshake:setStateEnabled(false)
            
        end
    end



    local sprite = cc.Sprite:create("image/ui/img/btn/btn_811.png")
    sprite:setAnchorPoint(1,0)
    sprite:setPosition(bgsize.width, 0)
    bg:addChild(sprite)

    local ssize = sprite:getContentSize()

    local line = cc.Sprite:create("image/ui/img/btn/btn_810.png")
    line:setPosition(ssize.width*0.5, ssize.height)
    sprite:addChild(line)


    local size1 = cc.size(565,150)    
    local infopanel = ccui.ImageView:create("image/ui/img/bg/bg_175.png")
    infopanel:setAnchorPoint(0.5,1)
    infopanel:setPosition(bgsize.width*0.5, 0)
    infopanel:setVisible(false)
    infopanel:setScale9Enabled(true)
    infopanel:setContentSize(size1) 
    bg:addChild(infopanel)
    self.infopanel = infopanel


    local listview = ccui.ListView:create()
    infopanel:addChild(listview)

    listview:setDirection(ccui.ScrollViewDir.vertical)
    listview:setBounceEnabled(false)
    listview:setContentSize(size1.width, size1.height-25)
    listview:setPosition(0,9)


    local function onTouchBegan(touch, event)
        return true
    end

    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = bg:convertToNodeSpace(touch:getLocation())
        local s = bg:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)
        local s1 = infopanel:getContentSize()
        local rect1 = cc.rect(0, 0, s1.width, s1.height)

        if not cc.rectContainsPoint(rect, locationInNode) and not cc.rectContainsPoint(rect1, locationInNode) then
            if self.taskID then
                application:dispatchCustomEvent(AppEvent.UI.Task.GetCurrTaskID, 
                                                {TaskID = self.taskID, IsRefurbish = true})
            end
            layer:removeFromParent()
            layer = nil
        end

    end

    local listener1 = cc.EventListenerTouchOneByOne:create()
    listener1:setSwallowTouches(true)
    listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener1:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = layer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, layer)


    local function updateTreePanel(event)
    
        if event.status ~= Exceptions.Nil then
            if event.status == Exceptions.EBuyCountOverflow then
                self.controls.layerColor:removeAllChildren()
                local label = Common.finalFont("今日摇钱次数已经用完，提升\nVIP等级可以增加摇钱次数", 1, 1, 18, cc.c3b(238,205,142))
                local size = self.controls.layerColor:getContentSize()
                label:setPosition(410,size.height*0.5)
                self.controls.layerColor:addChild(label)
                return
            elseif event.status == Exceptions.ERoleGoldNotEnough then
            --元宝不够
                
            end
            return
        end

        self.infopanel:setVisible(true)     
        local size = listview:getContentSize()   

        coinTreeUse.CritTimes = {}
        coinTreeUse.CritTimes = event.result

        local function createListItem( count, times )
            local itembg = cc.LayerColor:create(cc.c4b(0,0,0,0), size.width, size.height/5)
            local bgsize = itembg:getContentSize()
        
            local label = Common.finalFont("使用", 1, 1, 20)
            label:setPosition(bgsize.width*0.1, bgsize.height*0.5)
            itembg:addChild(label)
        
            local icon = cc.Sprite:create("image/ui/img/btn/btn_060.png")
            icon:setPosition(bgsize.width*0.18,bgsize.height*0.5)
            itembg:addChild(icon)
        
            label = Common.finalFont(BaseConfig.GetCointreeNode(count).gold, 1, 1, 20)
            label:setPosition(bgsize.width*0.25, bgsize.height*0.5)
            itembg:addChild(label)
        
            label = Common.finalFont("，获得", 1, 1, 20)
            label:setPosition(bgsize.width*0.35, bgsize.height*0.5)
            itembg:addChild(label)
        
            icon = cc.Sprite:create("image/ui/img/btn/btn_035.png")
            icon:setPosition(bgsize.width*0.46,bgsize.height*0.5)
            itembg:addChild(icon)
        
            --有需要才有暴击
            local string = ""..BaseConfig.GetCointreeNode(count).coin
            if times > 1 then
                local baoji = cc.Sprite:create("image/ui/img/btn/btn_1059.png")
                baoji:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.7)
                baoji:setScale(3)
                layer:addChild(baoji)
    
                local action = cc.Sequence:create( cc.ScaleTo:create(0.1, 0.9), cc.ScaleTo:create(0.05, 1.1), cc.FadeOut:create(1) )
                baoji:runAction(action)
    
    
                label = Common.finalFont("暴击x "..times, 1, 1, 20, cc.c3b(255,138,239))
                label:setPosition(bgsize.width*0.85, bgsize.height*0.5)
                itembg:addChild(label)
                string = ""..BaseConfig.GetCointreeNode(count).coin * times
            end
        
            label = Common.finalFont(string, 1, 1, 20)
            label:setPosition(bgsize.width*0.59, bgsize.height*0.5)
            itembg:addChild(label)
        
            -- application:showFlashNotice("获得："..string)
        
            local default_item = ccui.Layout:create()
            default_item:setTouchEnabled(false)
            default_item:setContentSize(bgsize)
            -- itembg:setPosition(cc.p(default_item:getContentSize().width / 2.0, default_item:getContentSize().height / 2.0))
            default_item:addChild(itembg)

            listview:pushBackCustomItem(default_item)
            listview:refreshView()
            listview:scrollToBottom(0.1,true)  
               
        end

        -- 更新 摇钱树信息
        for i=1,#coinTreeUse.CritTimes do
            coinTreeUse.UseCount = coinTreeUse.UseCount + 1
            createListItem(coinTreeUse.UseCount, coinTreeUse.CritTimes[i])
            EffectManager:RepeatAnimation(cointree_animation)
        end

        -- 五次赠送一次
        if #coinTreeUse.CritTimes == 5 then
            local count = coinTreeUse.UseCount + 1
            if coinTreeUse.UseCount == coinTreeUse.TotalCount then
                count = coinTreeUse.TotalCount
            end
                
           local itembg = cc.LayerColor:create(cc.c4b(0,0,0,0), size.width, size.height/5)
           local bgsize = itembg:getContentSize()
       
           local label = Common.finalFont("获得", 1, 1, 20,cc.c3b(255,138,239))
           label:setPosition(bgsize.width*0.25, bgsize.height*0.5)
           itembg:addChild(label)
       
           icon = cc.Sprite:create("image/ui/img/btn/btn_035.png")
           icon:setPosition(bgsize.width*0.36,bgsize.height*0.5)
           itembg:addChild(icon)
       
           local string = ""..BaseConfig.GetCointreeNode(count).coin            
           label = Common.finalFont(string, 1, 1, 20,cc.c3b(255,138,239))
           label:setPosition(bgsize.width*0.49, bgsize.height*0.5)
           itembg:addChild(label) 

           label = Common.finalFont("赠送！", 1, 1, 20, cc.c3b(255,138,239))
           label:setPosition(bgsize.width*0.85, bgsize.height*0.5)
           itembg:addChild(label)

           -- application:showFlashNotice("获得："..string)
       
           local default_item = ccui.Layout:create()
           default_item:setTouchEnabled(false)
           default_item:setContentSize(bgsize)
           -- itembg:setPosition(cc.p(default_item:getContentSize().width / 2.0, default_item:getContentSize().height / 2.0))
           default_item:addChild(itembg)
       
           -- self.controls.listview:insertCustomItem(default_item,0)
           -- 
           listview:pushBackCustomItem(default_item)
           listview:refreshView()
           listview:scrollToBottom(0.1,true)  
          
        end

        -- 更新下次信息

        self.controls.countlabel:setString("今日已用" .. coinTreeUse.UseCount .."/".. coinTreeUse.TotalCount)

        if coinTreeUse.UseCount == coinTreeUse.TotalCount then
            self.controls.layerColor:removeAllChildren()
            local label = Common.finalFont("今日摇钱次数已经用完，提升\nVIP等级可以增加摇钱次数", 1, 1, 18, cc.c3b(238,205,142))
            local size = self.controls.layerColor:getContentSize()
            label:setPosition(410,size.height*0.5)
            self.controls.layerColor:addChild(label)
        else
            local nexttreenode = BaseConfig.GetCointreeNode(coinTreeUse.UseCount+1)
            if nexttreenode then
                self.controls.goldlabel:setString("".. nexttreenode.gold)
                self.controls.coinlabel:setString("".. nexttreenode.coin)
                if GameCache.Avatar.Gold < nexttreenode.gold then
                    self.controls.goldlabel:setColor(cc.c3b(230,40,30))
                    -- self.controls.buttonshake:setStateEnabled(false)
                    -- Common.isCostMoney(1001, BaseConfig.GetCointreeNode(coinTreeUse.UseCount+1).gold)
                end
            end
        end

        if self.updateFunc then
            self.updateFunc()
        end
    
    end


    local function showMoreBuy( gold, coin )

        local moreLayer = cc.LayerColor:create(cc.c4b(0,0,0,150))


        local morebgsize = cc.size(405,215)
        local morebg = ccui.ImageView:create("image/ui/img/bg/bg_139.png")
        morebg:setScale9Enabled(true)
        morebg:setContentSize(morebgsize)
        morebg:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)
        moreLayer:addChild(morebg)
    
        local label = Common.finalFont("连续使用5次摇钱树" , 50 , 175, 20)
        label:setAnchorPoint(0,0.5)
        morebg:addChild(label)
    
        local label1 = Common.finalFont("（额外赠送1次）" , label:getContentSize().width+50 , 175, 20, cc.c3b(120,246,103))
        label1:setAnchorPoint(0,0.5)
        morebg:addChild(label1)
    
        local label = Common.finalFont("消耗：" , 50 , 140, 20)
        label:setAnchorPoint(0,0.5)
        morebg:addChild(label)
    
        local icon = cc.Sprite:create("image/ui/img/btn/btn_060.png")
        icon:setPosition(125,140)
        morebg:addChild(icon)



        local goldlabel = Common.finalFont(""..gold, 150,140, 26,cc.c3b(120,246,103))
        goldlabel:setAnchorPoint(0,0.5)
        morebg:addChild(goldlabel)
    
        local label = Common.finalFont("至少获得：" , 50 , 105, 20)
        label:setAnchorPoint(0,0.5)
        morebg:addChild(label)
    
        local icon = cc.Sprite:create("image/ui/img/btn/btn_035.png")
        icon:setPosition(160,105)
        morebg:addChild(icon)
    
        local label = Common.finalFont(""..coin, 190,105, 26,cc.c3b(120,246,103))
        label:setAnchorPoint(0,0.5)
        morebg:addChild(label) 
    
        local sprite = cc.Sprite:create("image/ui/img/btn/btn_811.png")
        sprite:setAnchorPoint(0.5,0)
        sprite:setPosition(morebgsize.width*0.5, 10)
        morebg:addChild(sprite)
    
        local ssize = sprite:getContentSize()
    
        local line = cc.Sprite:create("image/ui/img/btn/btn_810.png")
        line:setPosition(ssize.width*0.5, ssize.height)
        sprite:addChild(line)
    
        local btn = ccui.MixButton:create("image/ui/img/btn/btn_818.png")
        btn:setScale9Size(cc.size(135,55))
        btn:setTitle("取消",26,cc.c3b(238,205,142))
        btn:addTouchEventListener(function ( sender, eventType )
            if eventType == ccui.TouchEventType.ended then
                moreLayer:removeFromParent()
                moreLayer = nil
            end
        end)
        btn:setPosition(morebgsize.width*0.25, 45)
        morebg:addChild(btn)
    
        local btn_sure = ccui.MixButton:create("image/ui/img/btn/btn_818.png")
        btn_sure:setScale9Size(cc.size(135,55))
        btn_sure:setTitle("确定",26,cc.c3b(238,205,142))
        btn_sure:addTouchEventListener(function ( sender, eventType )
            if eventType == ccui.TouchEventType.ended then
                rpc:call("Avatar.BuyCoin", 5, updateTreePanel)
                moreLayer:removeFromParent()
                moreLayer = nil
            end
        end)
        btn_sure:setPosition(morebgsize.width*0.75, 45)
        morebg:addChild(btn_sure)

        -- if GameCache.Avatar.Gold < gold then
        --     goldlabel:setColor(cc.c3b(230,40,30))
        --     btn_sure:setStateEnabled(false)
        --     -- Common.isCostMoney(1001, gold)

        -- end


        local function onTouchBegan(touch, event)
            return true
        end
        local function onTouchEnded(touch, event)
    
        end
        local listener1 = cc.EventListenerTouchOneByOne:create()
        listener1:setSwallowTouches(true)
        listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
        listener1:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
        local eventDispatcher = moreLayer:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, moreLayer)
    
        return moreLayer
    end


    local function ToBuyVIP(  )

        local tovipLayer = cc.LayerColor:create(cc.c4b(0,0,0,150))


        local morebgsize = cc.size(405,215)
        local morebg = ccui.ImageView:create("image/ui/img/bg/bg_139.png")
        morebg:setScale9Enabled(true)
        morebg:setContentSize(morebgsize)
        morebg:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)
        tovipLayer:addChild(morebg)
    
        local label = Common.finalFont("亲，好遗憾呀，次数不够摇不动了。\n提升VIP等级就能获得更多摇钱次数噢~~" , morebgsize.width*0.5 , morebgsize.height*0.7, 20)
        -- label:setAnchorPoint(0,0.5)
        morebg:addChild(label)
    
    
        local sprite = cc.Sprite:create("image/ui/img/btn/btn_811.png")
        sprite:setAnchorPoint(0.5,0)
        sprite:setPosition(morebgsize.width*0.5, 10)
        morebg:addChild(sprite)
    
        local ssize = sprite:getContentSize()
    
        local line = cc.Sprite:create("image/ui/img/btn/btn_810.png")
        line:setPosition(ssize.width*0.5, ssize.height)
        sprite:addChild(line)
    
        local btn = ccui.MixButton:create("image/ui/img/btn/btn_818.png")
        btn:setScale9Size(cc.size(135,55))
        btn:setTitle("算了",22,cc.c3b(238,205,142),1)
        btn:addTouchEventListener(function ( sender, eventType )
            if eventType == ccui.TouchEventType.ended then
                tovipLayer:removeFromParent()
                tovipLayer = nil
            end
        end)
        btn:setPosition(morebgsize.width*0.25, 45)
        morebg:addChild(btn)
    
        local btn_sure = ccui.MixButton:create("image/ui/img/btn/btn_818.png")
        btn_sure:setScale9Size(cc.size(135,55))
        btn_sure:setTitle("提升VIP",22,cc.c3b(238,205,142),1)
        btn_sure:addTouchEventListener(function ( sender, eventType )
            if eventType == ccui.TouchEventType.ended then
                application:pushScene("main.recharge.RechargeScene")
                layer:removeFromParent()
                layer = nil
            end
        end)
        btn_sure:setPosition(morebgsize.width*0.75, 45)
        morebg:addChild(btn_sure)

        local unuse = BaseConfig.getVipExp(1)
        if GameCache.Avatar.VIP == #BaseConfig.vipConfig then
            btn_sure:setStateEnabled(false)
        end


        local function onTouchBegan(touch, event)
            return true
        end
        local function onTouchEnded(touch, event)
    
        end
        local listener1 = cc.EventListenerTouchOneByOne:create()
        listener1:setSwallowTouches(true)
        listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
        listener1:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
        local eventDispatcher = tovipLayer:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, tovipLayer)
    
        return tovipLayer
    end


    local btn_shake = ccui.MixButton:create("image/ui/img/btn/btn_818.png")
    btn_shake:setScale9Size(cc.size(135,60))
    btn_shake:setTitle("摇一摇",26,cc.c3b(238,205,142),2)
    btn_shake:setPosition(bgsize.width*0.55, 40)
    btn_shake:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            if coinTreeUse.UseCount < coinTreeUse.TotalCount and GameCache.Avatar.Gold >= BaseConfig.GetCointreeNode(coinTreeUse.UseCount+1).gold then   -- 次数够，钱够
                rpc:call("Avatar.BuyCoin", 1, updateTreePanel) 
            elseif coinTreeUse.UseCount < coinTreeUse.TotalCount and GameCache.Avatar.Gold < BaseConfig.GetCointreeNode(coinTreeUse.UseCount+1).gold then   -- 次数够，钱不够
                Common.isCostMoney(1001, BaseConfig.GetCointreeNode(coinTreeUse.UseCount+1).gold)
            else
                layer:addChild(CommonLayer.ToBuyVIP("亲，好遗憾呀，次数不够摇不动了。提升VIP等级就能获得更多摇钱次数噢~~"))
            end
        end
    end)
    bg:addChild(btn_shake)
    self.controls.buttonshake = btn_shake


    local btn_shake5 = ccui.MixButton:create("image/ui/img/btn/btn_818.png")
    btn_shake5:setScale9Size(cc.size(135,60))
    btn_shake5:setTitle("摇五次",26,cc.c3b(238,205,142),2)
    btn_shake5:setPosition(bgsize.width*0.83, 40)
    btn_shake5:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then

            local gold = 0
            local coin = 0

            if coinTreeUse.UseCount == coinTreeUse.TotalCount then
                layer:addChild(ToBuyVIP())
                return
            elseif coinTreeUse.UseCount+5 > coinTreeUse.TotalCount then
                application:showFlashNotice("次数不足，还是一次次点吧。。")
                return
            end

            for i=coinTreeUse.UseCount+1 ,coinTreeUse.UseCount+5 do
                gold = gold + BaseConfig.GetCointreeNode(i).gold
                coin = coin + BaseConfig.GetCointreeNode(i).coin
            end

            if GameCache.Avatar.Gold >= gold then   -- 次数够，钱够
                layer:addChild(showMoreBuy(gold, coin))
            elseif GameCache.Avatar.Gold < gold then
                application:showFlashNotice("没有足够的元宝摇5次噢～")
                Common.isCostMoney(1001, gold)       
            end
        end
    end)
    bg:addChild(btn_shake5)
    self.controls.buttonshake5 = btn_shake5

    local song = cc.Sprite:create("image/ui/img/btn/btn_1028.png")
    song:setAnchorPoint(0,1)
    song:setPosition(0,btn_shake5:getContentSize().height)
    btn_shake5:addChild(song)


end

function CoinTreeLayer:onEnterTransitionFinish(  )
    
end

return CoinTreeLayer