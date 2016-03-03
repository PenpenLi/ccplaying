local ColiseumLayer = class("ColiseumLayer", BaseLayer)
local HeroAction = require("tool.helper.HeroAction")
local scheduler = cc.Director:getInstance():getScheduler()
local ExchangeMall = require("scene.main.ExchangeMall")
local CommonLayer = require("tool.helper.CommonLayer")


function ColiseumLayer:ctor(arenainfo)
    ColiseumLayer.super.ctor(self)

    --receive needed data
    self.ArenaInfo = {}
    self.rankInfo = {}
    self.recordInfo = {}
    self.messageTable = {}
    self.currChallenger = {}
    self.rankForms = {}
    self.selectIdx = nil
    self.heroFormLayer = nil
    self.lastRank = nil
    self.lastTFP = nil
    self.Arena_endurance_cost = 2
    self.wxTexture = {
        "image/ui/img/btn/btn_385.png",
        "image/ui/img/btn/btn_383.png",
        "image/ui/img/btn/btn_386.png",
        "image/ui/img/btn/btn_384.png",
        "image/ui/img/btn/btn_387.png",
    }

    self.atkAttr = {
        "image/ui/img/btn/btn_650.png",
        "image/ui/img/btn/btn_649.png",
        "image/ui/img/btn/btn_648.png",
    }

    self.ArenaInfo = arenainfo
    self:CreateFixedUI()

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
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

end

function ColiseumLayer:CreateFixedUI()
    self.lastidx = 0
    local fixedLayer = cc.Layer:create()
    self:addChild(fixedLayer)

    local bg = cc.Sprite:create("image/ui/img/bg/bg_037.jpg")
    bg:setAnchorPoint(0,0)
    fixedLayer:addChild(bg)

    local pay = require("scene.main.PayListNode").new(GameCache.Avatar.PhyPower, GameCache.Avatar.MaxPhyPower,
        GameCache.Avatar.Endurance, GameCache.Avatar.MaxEndurance,
        GameCache.Avatar.Coin, GameCache.Avatar.Gold)
    local size = pay:getContentSize()
    pay:setPosition(SCREEN_WIDTH*0.5 - size.width * 0.5, SCREEN_HEIGHT - 50)
    fixedLayer:addChild(pay)

    local panelsize = cc.size(934, 560)
    local panel = ccui.ImageView:create("image/ui/img/bg/bg_111.png")
    panel:setPosition(SCREEN_WIDTH*0.5, 10)
    panel:setAnchorPoint(0.5,0)
    panel:setScale9Enabled(true)
    panel:setContentSize(panelsize)
    fixedLayer:addChild(panel)

    local light = cc.Sprite:create("image/ui/img/bg/bg_112.png")
    light:setAnchorPoint(0,1)
    light:setPosition(2, panelsize.height-2)
    panel:addChild(light)

    light = cc.Sprite:create("image/ui/img/bg/bg_113.png")
    light:setAnchorPoint(0,1)
    light:setPosition(2, panelsize.height-2)
    panel:addChild(light)


    local leftsize = cc.size(303,518)
    local leftPanel = ccui.ImageView:create("image/ui/img/bg/bg_139.png")
    leftPanel:setPosition(5, 5)
    leftPanel:setAnchorPoint(0,0)
    leftPanel:setScale9Enabled(true)
    leftPanel:setContentSize(leftsize)
    panel:addChild(leftPanel)
    self.leftPanel = leftPanel


    local huawen = cc.Sprite:create("image/ui/img/btn/btn_609.png")
    huawen:setPosition(leftsize.width*0.5, leftsize.height*0.6)
    leftPanel:addChild(huawen)

    local line = cc.Sprite:create("image/ui/img/btn/btn_810.png")
    line:setPosition(leftsize.width*0.5, 315)
    leftPanel:addChild(line)

    local line1 = cc.Sprite:create("image/ui/img/btn/btn_658.png")
    line1:setRotation(90)
    line1:setPosition(leftsize.width*0.5, 315)
    leftPanel:addChild(line1)


    local rightsize = cc.size(635,522)
    local rightPanel = ccui.ImageView:create("image/ui/img/bg/bg_141.png")
    rightPanel:setPosition(panelsize.width+2, 2 )
    rightPanel:setAnchorPoint(1,0)
    rightPanel:setScale9Enabled(true)
    rightPanel:setContentSize(rightsize)
    panel:addChild(rightPanel)
    self.rightPanel = rightPanel

    local sprite = cc.Sprite:create("image/ui/img/bg/bg_232.png")
    sprite:setPosition(rightsize.width*0.5, rightsize.height*0.55)
    rightPanel:addChild(sprite)



    local message = cc.Sprite:create("image/ui/img/btn/btn_930.png")
    message:setPosition(600,panelsize.height*0.95)
    panel:addChild(message)
    local size = message:getContentSize()

    -- local label = require("tool.helper.NewColorLabel").new("",20, 700, true)
    local label = Common.systemFont("", 1 , 1, 20, cc.c3b(0,13,21))
    label:setPosition(size.width*0.5,size.height*0.5)
    -- label:setColor(cc.c3b(255,231,148))
    -- label:enableOutline(cc.c4b(0,0,0,255),2)
    message:addChild(label)
    self.controls.message = label


    local btn_close = ccui.MixButton:create("image/ui/img/btn/btn_598.png")
    btn_close:setPosition(panelsize.width-15, panelsize.height-15)
    btn_close:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            cc.Director:getInstance():popScene()
            self.lastidx = nil
        end
    end)
    panel:addChild(btn_close)

    local sprite = cc.Sprite:create("image/ui/img/btn/btn_060.png")
    sprite:setVisible(false)
    sprite:setPosition(415,35)
    rightPanel:addChild(sprite)

    local label = Common.finalFont("50", 1,1,20,nil,1)
    label:setVisible(false)
    label:setPosition(435,35)
    label:setAnchorPoint(0,0.5)
    rightPanel:addChild(label)

    local btn_refresh = ccui.MixButton:create("image/ui/img/btn/btn_593.png" )
    btn_refresh:setScale9Size(cc.size(135,62))
    btn_refresh:setPosition(rightsize.width*0.5,45)
    -- btn_refresh:setTitle("换一批" , 26, cc.c3b(243,207,137), 2, cc.c4b(70,50,14,255))
    btn_refresh:addTouchEventListener(function ( sender,eventType )
        if eventType == ccui.TouchEventType.ended then
            if self.ArenaInfo.IsFreeRefresh or Common.isCostMoney(1001, 50) then
                self:refreshChalenger()
            end
            if self.ArenaInfo.IsFreeRefresh then
                self.ArenaInfo.IsFreeRefresh = false
                btn_refresh:setTitle("换一批" , 26, cc.c3b(243,207,137), 2, cc.c4b(70,50,14,255))
                sprite:setVisible(true)
                label:setVisible(true)
            end
        end
    end)
    rightPanel:addChild(btn_refresh)



   if self.ArenaInfo.IsFreeRefresh then
        btn_refresh:setTitle("免费换一批" , 22, cc.c3b(243,207,137))
   else
        sprite:setVisible(true)
        label:setVisible(true)
        btn_refresh:setTitle("换一批" , 26, cc.c3b(243,207,137), 2, cc.c4b(70,50,14,255))
   end



    local titlebg = cc.Sprite:create("image/ui/img/bg/bg_142.png")
    titlebg:setPosition(80, panelsize.height-15)
    panel:addChild(titlebg)

    local title = cc.Sprite:create("image/ui/img/btn/btn_927.png")
    title:setPosition(80, panelsize.height-10)
    panel:addChild(title)


    local imageview = cc.Sprite:create("image/ui/img/bg/bg_231.png")
    imageview:setAnchorPoint(0.5, 0)
    imageview:setPosition(leftsize.width*0.5, 20)
    leftPanel:addChild(imageview)

    local size = imageview:getContentSize()

    local btn_form = ccui.Button:create("image/ui/img/btn/btn_466.png")
    btn_form:setPosition(size.width*0.25, size.height*0.75)
    btn_form:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            rpc:call("Arena.GetDefFormation", {}, function(event)
                application:pushScene("form.BattleFormScene", GameCache.FORM_TYPE_ARENA_DEFENSE, { attackerForm = event.result })
            end)
        end
    end)
    imageview:addChild(btn_form)
    local x,y = btn_form:getPosition()
    local label_zhenrong = Common.finalFont("防守阵容",1,1,20)
    label_zhenrong:setPosition(x,y-40)
    imageview:addChild(label_zhenrong)



    local btn_rank = ccui.Button:create("image/ui/img/btn/btn_188.png")
    btn_rank:setPosition(size.width*0.75, size.height*0.75)
    btn_rank:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local layer = require("scene.main.RankList").new(4)
            self:addChild(layer)
            -- self:receiveRankInfo()
        end
    end)
    imageview:addChild(btn_rank)
    local x,y = btn_rank:getPosition()
    local label_paihang = Common.finalFont("排行榜",1,1,20)
    label_paihang:setPosition(x,y-40)
    imageview:addChild(label_paihang)


    local btn_exchange = ccui.Button:create("image/ui/img/btn/btn_069.png")
    btn_exchange:setPosition(size.width*0.25, size.height*0.25)
    btn_exchange:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local shop = ExchangeMall.new(BaseConfig.MALL_TYPE_ARENA)
            if shop == nil then
                return
            end
            local runningScene = cc.Director:getInstance():getRunningScene()
            runningScene:addChild(shop)
        end
    end)
    imageview:addChild(btn_exchange)
    local x,y = btn_exchange:getPosition()
    local label_duihuan = Common.finalFont("兑换商店",1,1,20)
    label_duihuan:setPosition(x,y-30)
    imageview:addChild(label_duihuan)



    local btn_record = ccui.Button:create("image/ui/img/btn/btn_200.png")
    btn_record:setPosition(size.width*0.75, size.height*0.25)
    btn_record:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:receiveRecordInfo()
        end
    end)
    imageview:addChild(btn_record)
    local x,y = btn_record:getPosition()
    local label_jilu = Common.finalFont("对战记录",1,1,20)
    label_jilu:setPosition(x,y-30)
    imageview:addChild(label_jilu)

    -- local infobg = cc.Sprite:create("image/ui/img/btn/btn_928.png")
    -- infobg:setPosition(leftsize.width*0.5, leftsize.height*0.8)
    -- leftPanel:addChild(infobg)



    -- local info = {ID = GameCache.Avatar.Icon}
    -- local item = GoodsInfoNode.new(BaseConfig.GOODS_HERO, info)
    -- item:setTouchEnable(false)
    -- item:setPosition(65, 95)
    -- infobg:addChild(item)
    -- self.icon = item

    local btn_kuafu = ccui.MixButton:create("image/ui/img/btn/btn_831.png")
    btn_kuafu:setScale9Size(cc.size(203,82))
    btn_kuafu:setPosition(leftsize.width*0.5, 440)
    btn_kuafu:setChild("image/ui/img/btn/btn_1430.png")
    leftPanel:addChild(btn_kuafu)
    btn_kuafu:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            application:showFlashNotice("功能暂未开放，敬请期待！")
        end
    end)


    local label = Common.finalFont("排名", 1,1,20)
    label:setPosition(leftsize.width*0.25, 375)
    leftPanel:addChild(label)

    label = cc.Label:createWithCharMap("image/ui/img/btn/btn_627.png",44,52,string.byte("0"))
    label:setPosition(leftsize.width*0.25, 345)
    label:setScale(0.75)
    label:setAdditionalKerning(-9)
    leftPanel:addChild(label)
    self.label_paiming = label

    label = Common.finalFont("未上榜", 1,1,30,cc.c3b(220,12,10))
    label:setVisible(false)
    label:setPosition(leftsize.width*0.25, 345)
    leftPanel:addChild(label)
    self.label_paiming2 = label

    -- local sprite = cc.Sprite:create("image/ui/img/btn/btn_929.png")
    -- sprite:setAnchorPoint(0,0.5)
    -- sprite:setPosition(115,65)
    -- leftPanel:addChild(sprite)

    -- local str = ""..GameCache.Avatar.Name
    -- label = Common.systemFont(str, 1,1,24,cc.c3b(10,51,91))
    -- label:setAnchorPoint(0,0.5)
    -- label:setPosition(125,65)
    -- leftPanel:addChild(label)

    label = Common.finalFont("积分", 1,1,20)
    label:setPosition(leftsize.width*0.75, 375)
    leftPanel:addChild(label)


    sprite = cc.Sprite:create("image/ui/img/btn/btn_1121.png")
    sprite:setPosition(leftsize.width*0.6, 345)
    leftPanel:addChild(sprite)

    label = Common.finalFont("", 1,1,26)
    label:setPosition(leftsize.width*0.7, 345+2)
    label:setColor(cc.c3b(151,255,74))
    label:setAnchorPoint(0,0.5)
    leftPanel:addChild(label)
    self.label_credit = label

    label = Common.finalFont("战力", 1,1,20)
    label:setPosition(leftsize.width*0.25, 295)
    -- label:setColor(cc.c3b(73,131,178))
    leftPanel:addChild(label)

    label = Common.finalFont("", 1,1,28)
    label:setPosition(leftsize.width*0.25, 260)
    -- label:setAnchorPoint(0,0.5)
    label:enableOutline(cc.c4b(0,0,0,255),1)
    label:setColor(cc.c3b(151,255,74))
    leftPanel:addChild(label)
    self.label_zhanli = label

    label = Common.finalFont("连胜", 1,1,20)
    label:setPosition(leftsize.width*0.75, 295)
    -- label:setColor(cc.c3b(73,131,178))
    leftPanel:addChild(label)

    label = Common.finalFont("", 1,1,28,cc.c3b(151,255,74),1)
    label:setAnchorPoint(1,0.5)
    label:setPosition(leftsize.width*0.75-5, 260)
    leftPanel:addChild(label)
    self.label_liansheng = label

    label = Common.finalFont("次", 1,1,20)
    label:setAnchorPoint(0,0.5)
    label:setPosition(leftsize.width*0.75+5, 260)
    label:setColor(cc.c3b(73,131,178))
    leftPanel:addChild(label)


    -- local sprite = cc.Sprite:create("image/ui/img/btn/btn_811.png")
    -- sprite:setPosition(leftsize.width*0.5, leftsize.height*0.59)
    -- leftPanel:addChild(sprite)
    -- sprite:setScale(0.55)

    -- local ssize = sprite:getContentSize()






end

function ColiseumLayer:CreateOrUpdateFlexUI()
    --  dynamic create or update UI

    local _s = "" .. self.ArenaInfo.SelfRank
    if self.ArenaInfo.SelfRank > 0 then
        self.label_paiming:setVisible(true)
        self.label_paiming2:setVisible(false)
        self.label_paiming:setString(_s)

    else
        self.label_paiming:setVisible(false)
        self.label_paiming2:setVisible(true)
    end
    
    self.label_liansheng:setString(""..self.ArenaInfo.SteakCount)
    self.label_credit:setString(""..GameCache.Avatar.ArenaCredits)
    -- self.label_gold:setString(""..self.ArenaInfo.RankGold)
    local TFP = GameCache.Avatar.ArenaAtkTFP
    local str_tfp = tostring(TFP)
    if #str_tfp > 5 then
        local scale = 1-(#str_tfp - 5)*0.1
        if scale <= 0 then
            scale = 0.1
        end
        self.label_zhanli:setScale(scale)
    else
        self.label_zhanli:setScale(1)
    end
    self.label_zhanli:setString(str_tfp)
    -- self.icon:setLevel("center", GameCache.Avatar.Level)

    if not self.EnemtyList then
        self.EnemtyList = self:createEnemyCard()
        self.rightPanel:addChild(self.EnemtyList)
    end

    self.EnemtyList:reloadData()
end

function ColiseumLayer:showEnemyForm( player , hide)

    local panel = cc.LayerColor:create(cc.c4b(0,0,0,200))
    self:addChild(panel)


    local bgsize = cc.size(604,567)
    local bg = ccui.ImageView:create("image/ui/img/bg/bg_139.png")
    bg:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5-10)
    bg:setScale9Enabled(true)
    bg:setContentSize(bgsize)
    panel:addChild(bg)


    local center = cc.Sprite:create("image/ui/img/bg/bg_291.png")
    center:setPosition(bgsize.width*0.5, bgsize.height*0.5)
    bg:addChild(center)

    if not hide then
        local bottom = ccui.Scale9Sprite:create("image/ui/img/bg/bg_253.png")
        bottom:setContentSize(cc.size(585,85))
        bottom:setAnchorPoint(0.5,0)
        bottom:setPosition(bgsize.width*0.5, 10)
        bg:addChild(bottom)



        local btn_chalenge = ccui.MixButton:create("image/ui/img/btn/btn_818.png")
        btn_chalenge:setScale9Size(cc.size(135,60))
        btn_chalenge:setTitle("挑战" , 24, cc.c3b(223,183,109),1, cc.c4b(70,50,14,255))
        btn_chalenge:setTitlePos(0.65,0.5)
        btn_chalenge:setChild("image/ui/img/btn/btn_670.png",0.25, 0.5)
        btn_chalenge:setPosition(bgsize.width*0.5, 50)
        btn_chalenge:addTouchEventListener(function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                if GameCache.Avatar.Endurance - self.Arena_endurance_cost >= 0 then
                    rpc:call("Arena.BeforeF", { Enemy = player.RID}, function(event)
                        if event.status == Exceptions.Nil then
                            
                            application:pushScene("form.BattleFormScene", GameCache.FORM_TYPE_ARENA, {battleType = "PVP", map = "BW_map",
                                sessionID    = event.result.SessionID,
                                attackerForm = event.result.Form,
                                callback     = handler(self, self.battleResult),
                                rtn = {
                                    { rank = self.ArenaInfo.SelfRank, icon = GameCache.Avatar.Icon, name = GameCache.Avatar.Name },
                                    { rank = player.Rank, icon = player.Icon, name = player.Name, zhanli = player.TFP }
                                }
                            } )
                        end
                    end)

                    self.currChallengerRID = player.RID
                    panel:removeFromParent()
                    panel = nil
                else
                    CommonLayer.NeedEndurance()
                end

            end
        end)
        bg:addChild(btn_chalenge)
    end


    local fairyBg = cc.Sprite:create("image/ui/img/btn/btn_643.png")
    fairyBg:setPosition(bgsize.width-35, bgsize.height-25)
    bg:addChild(fairyBg)

    if player.Form.Fairy ~= 0 then
        local path = "image/ui/fairy/xn_"..string.sub(player.Form.Fairy,2).."_head.png"
        local fairy = cc.Sprite:create(path)
        fairy:setPosition(bgsize.width-35, bgsize.height-15)
        bg:addChild(fairy)
    end

    local x = cc.Sprite:create("image/ui/img/btn/btn_647.png")
    x:setPosition(bgsize.width-35, bgsize.height-65)
    bg:addChild(x)

    local form = {}
    local herolist = {}
    form = player.Form.Hero


    if form == nil then
        return
    end
    herolist = player.HeroList


    for i = #form, 1, -1 do
        local x = form[i].X*(-0.25)*bgsize.width+bgsize.width      -- 翻转阵容    (1-(-0.25*form[i].X))*bgsize.width
        local y = 50+form[i].Y*0.14*bgsize.height

        local wx = BaseConfig.GetHero(form[i].ID,0).wx
        local texture = self.wxTexture[wx]

        local shadow = cc.Sprite:create(texture)
        shadow:setPosition(x, y)
        -- shadow:setScale(0.3)
        bg:addChild(shadow)

        local hero = HeroAction.new(x, y, form[i].ID, herolist[i])
        hero:setTouchEnabled(false)
        hero:setAnimation(0,"idle",true)
        hero:setRotationSkewY(180)
        hero:setScale(0.8)
        bg:addChild(hero)

        local attr = BaseConfig.GetHero(form[i].ID,0).atkSkill - 1000
        -- local str = self.atkAttr[attr]
        -- local label = Common.finalFont(str,1,1,20)
        -- label:setPosition(x,y)
        -- label:enableOutline(cc.c4b(0,0,0,255),2)
        -- -- label:setColor(cc.c3b(143,26,20))
        -- bg:addChild(label)

        local tex = self.atkAttr[attr]
        local icon = cc.Sprite:create(tex)
        icon:setPosition(x,y)
        bg:addChild(icon)

    end

    local zhanlibg = cc.Sprite:create("image/ui/img/bg/bg_276.png")
    zhanlibg:setPosition(bgsize.width*0.5-20, bgsize.height*0.9)
    bg:addChild(zhanlibg)

    local zhanlisize = zhanlibg:getContentSize()

    label = Common.systemFont(""..player.Name.." 的队伍",1,1,22)
    label:setAnchorPoint(0,0.5)
    label:setPosition(15, zhanlisize.height*0.5)
    -- label:setColor(cc.c3b(143,26,20))
    zhanlibg:addChild(label)

    label = Common.finalFont("战力",1,1,20)
    label:setAnchorPoint(0,0.5)
    label:setPosition(275, zhanlisize.height*0.5)
    -- label:setColor(cc.c3b(143,26,20))
    zhanlibg:addChild(label)

    label = Common.finalFont(""..player.TFP,330, zhanlisize.height*0.5,32)
    label:setAnchorPoint(0,0.5)
    label:setColor(cc.c3b(151,255,74))
    zhanlibg:addChild(label)

    local function onTouchBegan(touch, event)
        return true
    end
    local function onTouchEnded(touch, event)

        local locationInNode = bg:convertToNodeSpace(touch:getLocation())
        local s = bg:getContentSize()
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
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, panel)
end

function ColiseumLayer:createEnemyCard()


    local function tableCellTouched( table, cell )
        local idx = cell:getIdx()
        self:showEnemyForm(self.ArenaInfo.List[idx+1])
    end

    local function cellSizeForTable( table, idx )

        return 102, 100
    end

    local function tableCellAtIndex( table, idx )
        local cell = cc.TableViewCell:new()

        local itemTable = {}
        itemTable = self.ArenaInfo.List[idx+1]

        local itembg = cc.Sprite:create()

        itembg:setAnchorPoint(0,0)
        if idx%2 == 1 then
            itembg:setTexture("image/ui/img/bg/bg_230.png")
        else
            itembg:setTexture("image/ui/img/bg/bg_229.png")
        end
        cell:addChild(itembg)


        local size = itembg:getContentSize()

        local label = cc.Label:createWithCharMap("image/ui/img/btn/btn_627.png",44,52,string.byte("0"))
        label:setPosition(65, size.height*0.5)
        label:setString(""..itemTable.Rank)
        label:setScale(0.6)
        label:setAdditionalKerning(-9)
        cell:addChild(label)

        local info = {ID = itemTable.Icon}
        local item = GoodsInfoNode.new(BaseConfig.GOODS_HERO, info, BaseConfig.GOODS_MIDDLETYPE)
        item:setTouchEnable(false)
        -- item:setScale(0.9)
        item:setPosition(168, size.height*0.5)
        cell:addChild(item)

        local sprite = cc.Sprite:create("image/ui/img/btn/btn_929.png")
        sprite:setAnchorPoint(0,0.5)
        sprite:setPosition(220,65)
        cell:addChild(sprite)

        local str = "" .. itemTable.Name
        label = Common.systemFont(str,1,1,26,cc.c3b(10,51,91))
        label:setPosition(230, 65)
        label:setAnchorPoint(0,0.5)
        cell:addChild(label)

        label = Common.finalFont("战力",1,1,20,cc.c3b(73,131,178))
        label:setAnchorPoint(0,0)
        label:setPosition(230,15)
        cell:addChild(label)


        local str = "" .. itemTable.TFP
        label = Common.finalFont(str,1,1,32,cc.c3b(151,251,74),1)
        label:setAnchorPoint(0,0)
        label:setPosition(280,6)
        cell:addChild(label)

        -- local str = "" .. itemTable.Level
        -- label = Common.finalFont(str,1,1,22)
        -- label:setPosition(size.width*0.66,size.height*0.7)
        -- label:enableOutline(cc.c4b(0,0,0,255),2)
        -- -- label:setAnchorPoint(0,0.5)
        -- -- label:setColor(cc.c3b(143,26,20))
        -- cell:addChild(label)

        -- label = Common.finalFont("级",1,1,20)
        -- label:setPosition(size.width*0.69,size.height*0.7)
        -- label:enableOutline(cc.c4b(0,0,0,255),2)
        -- label:setAnchorPoint(0,0.5)
        -- -- label:setColor(cc.c3b(143,26,20))
        -- cell:addChild(label)


        local btn_chalenge = ccui.MixButton:create("image/ui/img/btn/btn_818.png")
        btn_chalenge:setScale9Size(cc.size(125,60))
        btn_chalenge:setPosition(size.width*0.86,size.height*0.5)
        btn_chalenge:setTitle("挑战" , 24, cc.c3b(223,183,109),1, cc.c4b(70,50,14,255))
        btn_chalenge:setTitlePos(0.65,0.5)
        btn_chalenge:setChild("image/ui/img/btn/btn_670.png",0.25, 0.5)
        btn_chalenge:addTouchEventListener(function ( sender,eventType )
            if eventType == ccui.TouchEventType.ended then
                if GameCache.Avatar.Endurance - self.Arena_endurance_cost >= 0 then
                    rpc:call("Arena.BeforeF", { Enemy = itemTable.RID}, function(event)
                        if event.status == Exceptions.Nil then
                            application:pushScene("form.BattleFormScene", GameCache.FORM_TYPE_ARENA, {battleType = "PVP", map = "BW_map",
                                sessionID    = event.result.SessionID,
                                attackerForm = event.result.Form,
                                callback     = handler(self, self.battleResult),
                                rtn = {
                                    { rank = self.ArenaInfo.SelfRank, icon = GameCache.Avatar.Icon, name = GameCache.Avatar.Name },
                                    { rank = itemTable.Rank, icon = itemTable.Icon, name = itemTable.Name, zhanli = itemTable.TFP }
                                    },
                                } )
                        end
                    end)

                    self.currChallengerRID = itemTable.RID
                else
                    CommonLayer.NeedEndurance()
                end
            end
        end)
        cell:addChild(btn_chalenge)

        return cell
    end

    local function numberOfCellsInTableView(table)
        return #self.ArenaInfo.List
    end

    local tableView = cc.TableView:create(cc.size(580, 405))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(35, 85))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)

    tableView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    -- tableView:reloadData()

    return tableView
end

function ColiseumLayer:onEnter()
    self:receiveArenaInfo()
    self:CreateOrUpdateFlexUI()
    scheduler_refreshMessage = scheduler:scheduleScriptFunc(handler(self, self.refreshMessage), 2, false)
    -- self:refreshMessage()
end

function ColiseumLayer:onEnterTransitionFinish()
    Common.OpenSystemLayer({7})
    ColiseumLayer.super.onEnterTransitionFinish(self)
end

function ColiseumLayer:onExit()
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:removeEventListener(self._listener)

end

function ColiseumLayer:onCleanup()

end

function ColiseumLayer:onExitTransitionStart()
    self.controls.message:setString("")
    scheduler:unscheduleScriptEntry(scheduler_refreshMessage)
end

function ColiseumLayer:createRankLayer()

    local layer = cc.LayerColor:create(cc.c4b(0,0,0,200))
    self:addChild(layer)

    local bgsize = cc.size(720,560)
    local bg = ccui.ImageView:create("image/ui/img/bg/bg_139.png")
    bg:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)
    bg:setScale9Enabled(true)
    bg:setContentSize(bgsize)
    layer:addChild(bg)


    local image_list = cc.Sprite:create("image/ui/img/btn/btn_934.png")
    image_list:setAnchorPoint(0.5,1)
    image_list:setPosition(bgsize.width*0.5, bgsize.height-15)
    bg:addChild(image_list)

    local image_title = cc.Sprite:create("image/ui/img/bg/bg_233.png")
    image_title:setPosition(bgsize.width*0.5+10, bgsize.height-5)
    bg:addChild(image_title)


    local title = cc.Sprite:create("image/ui/img/btn/btn_940.png")
    title:setPosition(bgsize.width*0.5, bgsize.height-10)
    bg:addChild(title)


    local label_paiming = Common.finalFont("排名",1,1,20)
    label_paiming:setPosition(70,25)
    image_list:addChild(label_paiming)

    local label_juese = Common.finalFont("角色",1,1,20)
    label_juese:setPosition(240,25)
    image_list:addChild(label_juese)

    local label_dengji = Common.finalFont("等级",1,1,20)
    label_dengji:setPosition(390,25)
    image_list:addChild(label_dengji)

    local label_jiangli = Common.finalFont("奖励",1,1,20)
    label_jiangli:setPosition(570,25)
    image_list:addChild(label_jiangli)



    local function tableCellTouched( table, cell )
        local idx = cell:getIdx()


        if table.lastidx ~= idx then

            local cellbg = cell:getChildByName("bg")
            cellbg:setTexture("image/ui/img/btn/btn_982.png")

            local level = cellbg:getChildByName("level")
            level:setColor(cc.c3b(91,61,10))

            local sbg = cellbg:getChildByName("sbg")
            sbg:setTexture("image/ui/img/btn/btn_1075.png")

            local name = cellbg:getChildByName("name")
            name:setColor(cc.c3b(91,61,10))


            if table.lastidx and  table.lastidx ~= idx then
                table:updateCellAtIndex(table.lastidx)
            end
            table.lastidx = idx
        end


        if not self.rankForms[cell.id] then
            --请求网络
            self.rankForms[cell.id] = {}
            rpc:call("Ranks.GetChallengerInfo",cell.id,function ( event )
                if event.status == Exceptions.Nil then


                    self.rankForms[cell.id] = event.result
                    self:showEnemyForm(self.rankForms[cell.id], true)
                end
            end)
        else
            --  直接展示
            self:showEnemyForm(self.rankForms[cell.id], true)
        end

    end


    local function cellSizeForTable( table, idx )

        return 85, 100
    end

    local function tableCellAtIndex( table, idx )
            local cell = table:dequeueCell()
            if not cell then
                cell = cc.TableViewCell:new()
            else
                cell:removeAllChildren()
            end



            local itembg = cc.Sprite:create("image/ui/img/btn/btn_981.png")
            itembg:setName("bg")
            itembg:setFlippedX(true)
            itembg:setAnchorPoint(0,0)
            -- itembg:setPosition(bgsize.width*0.5,0)
            cell:addChild(itembg)

            local size = itembg:getContentSize()

            if idx == 0 then
                local icon = cc.Sprite:create("image/ui/img/btn/btn_931.png")
                icon:setPosition(50, size.height*0.5)
                itembg:addChild(icon)
            elseif idx == 1 then
                local icon = cc.Sprite:create("image/ui/img/btn/btn_932.png")
                icon:setPosition(50, size.height*0.5)
                itembg:addChild(icon)
            elseif idx == 2 then
                local icon = cc.Sprite:create("image/ui/img/btn/btn_933.png")
                icon:setPosition(50, size.height*0.5)
                itembg:addChild(icon)
            end

            local info = {}
            info = self.rankInfo[idx+1]

            local num = cc.Label:createWithCharMap("image/ui/img/btn/btn_627.png",44,52,string.byte("0"))
            num:setString(""..info.Rank)
            num:setPosition(50,size.height*0.5)
            num:setScale(0.8)
            itembg:addChild(num)

            cell.id = info.RID

            local touxiang = {ID = info.Icon}
            local icon = GoodsInfoNode.new(BaseConfig.GOODS_HERO, touxiang, BaseConfig.GOODS_SMALLTYPE)
            icon:setTouchEnable(false)
            icon:setPosition(155, size.height*0.5)
            itembg:addChild(icon)

            local str = info.Name
            local label_name = Common.systemFont(str,1,1, 22,cc.c3b(10,51,91))
            label_name:setName("name")
            label_name:setAnchorPoint(0,0.5)
            label_name:setPosition(195, size.height*0.5)
            itembg:addChild(label_name)

            str = ""..info.Level
            local label_level = Common.finalFont(str,1,1, 26,cc.c3b(10,51,91))
            label_level:setName("level")
            label_level:setPosition(365, size.height*0.5)
            itembg:addChild(label_level)

            -- award
            local award = cc.Sprite:create("image/ui/img/btn/btn_1074.png")
            award:setName("sbg")
            award:setPosition(550, size.height*0.5)
            local awardsize = award:getContentSize()

            local award1 = cc.Sprite:create("image/ui/img/btn/btn_1121.png")
            award1:setPosition(25,awardsize.height*0.5)
            award:addChild(award1)

            str = ""..info.Credits
            local label_award1 = Common.finalFont(str,1,1, 20,cc.c3b(151,255,74),1)
            label_award1:setPosition(70,awardsize.height*0.5)
            award:addChild(label_award1)

            local award2 = cc.Sprite:create("image/ui/img/btn/btn_060.png")
            award2:setPosition(140,awardsize.height*0.5)
            award:addChild(award2)

            str = ""..info.Gold
            local label_award2 = Common.finalFont(str,1,1, 20,cc.c3b(151,255,74),1)
            label_award2:setPosition(180,awardsize.height*0.5)
            award:addChild(label_award2)

            itembg:addChild(award)

        return cell
    end

    local function numberOfCellsInTableView(table)
        local n = #self.rankInfo
        if self.ArenaInfo.SelfRank > 0 then n = n-1 end
        return n
    end

    local tableHeight = 360
    local tableY = 110
    if self.ArenaInfo.SelfRank == 0 then 
        tableHeight = 360+72
        tableY = 32
    end
    local tableView = cc.TableView:create(cc.size(720, tableHeight))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(25, tableY))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)

    table.lastidx = nil

    tableView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:reloadData()

    bg:addChild(tableView)

    self.controls.rankview = tableView


    local function createYourself( info  )
            local itembg = cc.Sprite:create("image/ui/img/btn/btn_982.png")
            itembg:setFlippedX(true)
            -- itembg:setAnchorPoint(0,0)

            local size = itembg:getContentSize()

            if idx == 0 then
                local icon = cc.Sprite:create("image/ui/img/btn/btn_931.png")
                icon:setPosition(50, size.height*0.5)
                itembg:addChild(icon)
            elseif idx == 1 then
                local icon = cc.Sprite:create("image/ui/img/btn/btn_932.png")
                icon:setPosition(50, size.height*0.5)
                itembg:addChild(icon)
            elseif idx == 2 then
                local icon = cc.Sprite:create("image/ui/img/btn/btn_933.png")
                icon:setPosition(50, size.height*0.5)
                itembg:addChild(icon)
            end

            local len = #tostring(info.Rank)
            local scale = 0.9-len*0.1
            local num = cc.Label:createWithCharMap("image/ui/img/btn/btn_627.png",44,52,string.byte("0"))
            num:setString(""..info.Rank)
            num:setAdditionalKerning(-5)
            num:setPosition(50,size.height*0.5)
            num:setScale(scale)
            itembg:addChild(num)

            local touxiang = {ID = info.Icon}
            local icon = GoodsInfoNode.new(BaseConfig.GOODS_HERO, touxiang, BaseConfig.GOODS_SMALLTYPE)
            icon:setTouchEnable(false)
            icon:setPosition(155, size.height*0.5)
            itembg:addChild(icon)

            local str = info.Name
            local label_name = Common.systemFont(str,1,1, 22,cc.c3b(91,61,10))
            label_name:setAnchorPoint(0,0.5)
            label_name:setPosition(195, size.height*0.5)
            itembg:addChild(label_name)

            str = ""..info.Level
            local label_level = Common.finalFont(str,1,1, 26,cc.c3b(91,61,10))
            label_level:setPosition(365, size.height*0.5)
            itembg:addChild(label_level)

            -- award
            local award = cc.Sprite:create("image/ui/img/btn/btn_1075.png")
            award:setPosition(550, size.height*0.5)
            local awardsize = award:getContentSize()

            local award1 = cc.Sprite:create("image/ui/img/btn/btn_1121.png")
            award1:setPosition(25,awardsize.height*0.5)
            award:addChild(award1)

            str = ""..info.Credits
            local label_award1 = Common.finalFont(str,1,1, 20,cc.c3b(151,255,74),1)
            label_award1:setPosition(70,awardsize.height*0.5)
            award:addChild(label_award1)

            local award2 = cc.Sprite:create("image/ui/img/btn/btn_060.png")
            award2:setPosition(140,awardsize.height*0.5)
            award:addChild(award2)

            str = ""..info.Gold
            local label_award2 = Common.finalFont(str,1,1, 20,cc.c3b(151,255,74),1)
            label_award2:setPosition(180,awardsize.height*0.5)
            award:addChild(label_award2)

            itembg:addChild(award)

        return itembg
    end

    if self.ArenaInfo.SelfRank > 0 then
        local myself = createYourself( self.rankInfo[#self.rankInfo]  )
        myself:setPosition(bgsize.width*0.5, 60)
        bg:addChild(myself)
    end

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
end

function ColiseumLayer:createRecordLayer()
    local layer = cc.LayerColor:create(cc.c4b(0,0,0,200))
    self:addChild(layer)

    local bgsize = cc.size(667,473)
    local bg = ccui.ImageView:create("image/ui/img/bg/bg_139.png")
    bg:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)
    bg:setScale9Enabled(true)
    bg:setContentSize(bgsize)
    layer:addChild(bg)

    local huawen = cc.Sprite:create("image/ui/img/btn/btn_609.png")
    huawen:setPosition(bgsize.width*0.5, bgsize.height*0.5)
    bg:addChild(huawen)

    local image_title = cc.Sprite:create("image/ui/img/bg/bg_174.png")
    image_title:setPosition(bgsize.width*0.5, bgsize.height-5)
    bg:addChild(image_title)


    local title = cc.Sprite:create("image/ui/img/btn/btn_941.png")
    title:setPosition(bgsize.width*0.5, bgsize.height-5)
    bg:addChild(title)

    local function createRecordView(  )


        local function cellSizeForTable( table, idx )

            return 87, 100
        end

        local function tableCellAtIndex( table, idx )
            --                local cell = table:dequeueCell()
            local cell = cc.TableViewCell:new()

            local info = {}
            info = self.recordInfo[idx+1]

            local itembg = cc.Sprite:create("image/ui/img/bg/bg_173.png")
            itembg:setAnchorPoint(0,0)
            cell:addChild(itembg)

            local size = itembg:getContentSize()

            -- local str = string.sub(string.gsub(info.DateTime, '-', '/'),1, 10)
            local label_time = Common.finalFont(info.DateTime,1,1, 20,cc.c3b(10,51,91))
            label_time:setAnchorPoint(0,0.5)
            label_time:setPosition(470, size.height*0.5)
            itembg:addChild(label_time)

            if info.IsWinSide then
                -- 您赢了
                local icon = cc.Sprite:create("image/ui/img/btn/btn_621.png")
                icon:setPosition(60,size.height*0.5)
                itembg:addChild(icon)
                
                local label_content = Common.systemFont("您击败了 "..info.FailSide,1,1, 22,cc.c3b(10,51,91))
                label_content:setAnchorPoint(0,0.5)
                label_content:setPosition(130, 55)
                itembg:addChild(label_content)

                local rankPosX = 325
                local res_icon = "btn_624.png"
                local str_desc = "勇冠三军，排名上升至"
                local color_rank = cc.c3b(15,142,2)
                if info.WinSideNewRank == info.WinSideOldRank then 
                    str_desc = "排名保持在" 
                    rankPosX = 245
                    res_icon = "btn_1323.png"
                    color_rank = cc.c3b(10,51,91)
                end
                 
                local icon = cc.Sprite:create("image/ui/img/btn/" .. res_icon)
                icon:setAnchorPoint(0,0.5)
                icon:setPosition(130,25)
                itembg:addChild(icon)

                
                local label = Common.finalFont(str_desc, 1,1, 16,cc.c3b(10,51,91))
                label:setAnchorPoint(0,0.5)
                label:setPosition(155, 23)
                itembg:addChild(label)

                local label1 = Common.finalFont(""..info.WinSideNewRank, 1,1, 22,color_rank)
                label1:setAnchorPoint(0,0.5)
                label1:setPosition(rankPosX, 23)
                itembg:addChild(label1)
            else
                -- 你输了
                local icon = cc.Sprite:create("image/ui/img/btn/btn_622.png")
                icon:setPosition(60,size.height*0.5)
                itembg:addChild(icon)

                local str_title = info.WinSide .. " 击败了您"
                if info.FailSideNewRank == info.FailSideOldRank then str_title = "您未击败 " .. info.WinSide end
                local label_content = Common.systemFont(str_title,1,1, 22,cc.c3b(10,51,91))
                label_content:setAnchorPoint(0,0.5)
                label_content:setPosition(130, 55)
                itembg:addChild(label_content)

                local rankPosX = 325
                local res_icon = "btn_623.png"
                local str_desc = "惜败于此，排名下滑至"
                local color_rank = cc.c3b(231,49,0)
                if info.FailSideNewRank == info.FailSideOldRank then 
                    str_desc = "排名保持在" 
                    rankPosX = 245
                    res_icon = "btn_1323.png"
                    color_rank = cc.c3b(10,51,91)
                end

                if info.FailSideNewRank == 0 then
                    str_desc = "遗憾跌出排行榜"
                end

                local icon = cc.Sprite:create("image/ui/img/btn/" .. res_icon)
                icon:setAnchorPoint(0,0.5)
                icon:setPosition(130,25)
                itembg:addChild(icon)
                
                local label = Common.finalFont(str_desc, 1,1, 16,cc.c3b(10,51,91))
                label:setAnchorPoint(0,0.5)
                label:setPosition(155, 23)
                itembg:addChild(label)

                if info.FailSideNewRank > 0 then
                    local label1 = Common.finalFont(""..info.FailSideNewRank, 1,1, 22,color_rank)
                    label1:setAnchorPoint(0,0.5)
                    label1:setPosition(rankPosX, 23)
                    itembg:addChild(label1)
                end
            end



            -- if idx < 5 then
            --     local icon = ccui.Button:create("image/ui/img/btn/btn_197.png")
            --     icon:setPosition(size.width*0.9, size.height*0.5)
            --     itembg:addChild(icon)
            -- end

            return cell
        end

        local function numberOfCellsInTableView(table)
            return #self.recordInfo
        end

        local tableView = cc.TableView:create(cc.size(605, 405))
        tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        tableView:setPosition(cc.p(30, 30))
        tableView:setDelegate()
        tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)

        tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
        tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
        tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        tableView:reloadData()

        return tableView
    end

    if self.recordInfo and #self.recordInfo ~= 0 then
        local view = createRecordView()
        bg:addChild(view)
        self.controls.recordview = view
    else
        local sp = cc.Sprite:create("image/ui/img/btn/btn_989.png")
        sp:setPosition(bgsize.width*0.5-70, bgsize.height*0.5)
        bg:addChild(sp)

        local label = Common.finalFont("您目前没有记录",0,0,22, cc.c3b(61,131,172))
        label:setAnchorPoint(0,0.5)
        label:setPosition(bgsize.width*0.5-20, bgsize.height*0.5)
        bg:addChild(label)
    end

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

end

function ColiseumLayer:requestInitData()
    rpc:call("Arena.Init", nil, function(event)
        if event.status == Exceptions.Nil then
            self.ArenaInfo = event.result.Info
            table.sort(self.ArenaInfo.List, function (a,b) return a.Rank < b.Rank end)
            application:popScene()
            -- application:popScene()

            self.messageTable = event.result.MsgList or {""}
        end
    end)
end

function ColiseumLayer:battleWin( result, rtn )
    Common.playSound("audio/effect/map_battle_win.mp3")

    local myself = rtn[1]
    local enemy = rtn[2]

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

    local bg = cc.Sprite:create("image/ui/img/bg/bg_163.png")
    bg:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.4)
    layer:addChild(bg)

    local label = cc.Label:createWithCharMap("image/ui/img/btn/btn_627.png",44,52,string.byte("0"))
    label:setPosition(250,245)
    label:setAnchorPoint(0,0.5)
    label:setString(""..enemy.rank)
    label:setScale(0.75)
    label:setAdditionalKerning(-9)
    bg:addChild(label)

    local label = cc.Label:createWithCharMap("image/ui/img/btn/btn_627.png",44,52,string.byte("0"))
    label:setPosition(250,140)
    label:setAnchorPoint(0,0.5)
    local _s = "" .. myself.rank
    if myself.rank == 0 then _s = "" end
    label:setString(_s)
    label:setScale(0.75)
    label:setAdditionalKerning(-9)
    bg:addChild(label)

    local layerbg1 = cc.LayerColor:create(cc.c4b(0,0,0,0), 245,90)
    layerbg1:setPosition(390,195)
    bg:addChild(layerbg1)

    if myself.rank == 0 or myself.rank > enemy.rank then
    --todo
        layerbg1:runAction(cc.Sequence:create( cc.DelayTime:create(0.5), cc.Spawn:create( cc.MoveBy:create(0.2, cc.p(0, -50)), cc.ScaleTo:create(0.2, 0.8) ),
        cc.Spawn:create( cc.MoveBy:create(0.2, cc.p(0, -50)), cc.ScaleTo:create(0.2, 1.0) )  ))
    end
    local info = {ID = enemy.icon}
    local icon1 = GoodsInfoNode.new(BaseConfig.GOODS_HERO, info, BaseConfig.GOODS_MIDDLETYPE)
    icon1:setTouchEnable(false)
    icon1:setPosition(45, 45)
    layerbg1:addChild(icon1)

    local name1 = Common.systemFont(enemy.name, 105, 65, 22, cc.c3b(255,21,21))
    name1:setAnchorPoint(0,0.5)
    layerbg1:addChild(name1)

    local label_zhanli = Common.finalFont("战力：", 105, 25, 22)
    label_zhanli:setAnchorPoint(0,0.5)
    layerbg1:addChild(label_zhanli)

    local zhanli1 = Common.finalFont(enemy.zhanli, 160, 25, 28, cc.c3b(151,255,74))
    zhanli1:setAnchorPoint(0,0.5)
    layerbg1:addChild(zhanli1)

    local layerbg2 = cc.LayerColor:create(cc.c4b(0,0,0,0), 245,90)
    layerbg2:setPosition(390,95)
    bg:addChild(layerbg2)

    if myself.rank == 0 or myself.rank > enemy.rank then
        layerbg2:runAction( cc.Sequence:create( cc.DelayTime:create(0.5), cc.Spawn:create( cc.MoveBy:create(0.2, cc.p(0, 50)), cc.ScaleTo:create(0.2, 1.2) ),
         cc.Spawn:create( cc.MoveBy:create(0.2, cc.p(0, 50)), cc.ScaleTo:create(0.2, 1.0) )  ) )
    end
    local info = {ID = myself.icon}
    local icon2 = GoodsInfoNode.new(BaseConfig.GOODS_HERO, info, BaseConfig.GOODS_MIDDLETYPE)
    icon2:setTouchEnable(false)
    icon2:setPosition(45, 45)
    layerbg2:addChild(icon2)

    local name2 = Common.systemFont(myself.name, 105, 65, 22, cc.c3b(245,235,14))
    name2:setAnchorPoint(0,0.5)
    layerbg2:addChild(name2)

    local label_zhanli = Common.finalFont("战力：", 105, 25, 22)
    label_zhanli:setAnchorPoint(0,0.5)
    layerbg2:addChild(label_zhanli)

    local tfp = GameCache.Avatar.ArenaAtkTFP
    local zhanli2 = Common.finalFont(tfp, 160, 25, 28, cc.c3b(151,255,74))
    zhanli2:setAnchorPoint(0,0.5)
    layerbg2:addChild(zhanli2)



    local size = cc.size(380,80)
    local iconbg = ccui.ImageView:create("image/ui/img/bg/bg_161.png")
    iconbg:setScale9Enabled(true)
    iconbg:setContentSize(size)
    iconbg:setPosition(SCREEN_WIDTH*0.5, 155)
    layer:addChild(iconbg)


    local exp = cc.Sprite:create("image/ui/img/btn/btn_671.png")
    exp:setPosition(70, size.height*0.5)
    iconbg:addChild(exp)

    local label = Common.finalFont("+"..result.Exp, 130, size.height*0.5,26)
    iconbg:addChild(label)

    icon = cc.Sprite:create("image/ui/img/btn/btn_1121.png")
    icon:setPosition(255, size.height*0.5)
    iconbg:addChild(icon)

    label = Common.finalFont("+"..result.ArenaCredits, 310, size.height*0.5,26)
    iconbg:addChild(label)


    local btnImage = "image/ui/img/btn/btn_553.png"
    local btnBackToMap = ccui.MixButton:create(btnImage)
    btnBackToMap:setTitle("确定" , 26, cc.c3b(226,204,169), 1, cc.c4b(65,26,1,255))
    -- btnBackToMap:setVisible(false)
    btnBackToMap:setOpacity(0)
    btnBackToMap:setPosition(SCREEN_WIDTH*0.5,70)
    layer:addChild(btnBackToMap)
    btnBackToMap:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            self:requestInitData()
        end
    end)
    btnBackToMap:runAction(cc.Sequence:create( cc.DelayTime:create(1), cc.FadeIn:create(0.2) ))

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

function ColiseumLayer:battleFail( result )

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
            self:requestInitData()
        end
    end)
end

-- communicate with Server
function ColiseumLayer:battleResult( result )
    local rtn = result.params.rtn
    local iswin = false

    if result.result == "win" then
        iswin = true
    end

    rpc:call("Arena.EndF", {SessionID = result.sessionID, IsWin = iswin}, function ( event )
        if event.status == Exceptions.Nil then
            if iswin then
                self:battleWin(event.result, rtn)
            else
                self:battleFail(event.result)
            end
        end
    end, {show = false, debug = false, retryOnError = true})
end

function ColiseumLayer:receiveArenaInfo()
    rpc:call("Arena.RefreshRollMessage", nil, function ( event )
        if event.status == Exceptions.Nil then
            self.messageTable = event.result
        end
    end)
end

function ColiseumLayer:refreshMessage()
    if self.messageTable == nil or self.controls.message==nil then
        return
    end
    local idx = math.random(1,#self.messageTable)
    self.controls.message:setString(self.messageTable[idx])
end

function ColiseumLayer:receiveRankInfo()

    rpc:call("Arena.Billboard", nil, function ( event )
        if event.status == Exceptions.Nil then
            self.rankInfo = event.result
            self:createRankLayer()
        end
    end)
end

function ColiseumLayer:receiveRecordInfo()
    rpc:call("Arena.History", nil, function ( event )
        if event.status == Exceptions.Nil then
            self.recordInfo = event.result
            self:createRecordLayer()
        end
    end)
end

function ColiseumLayer:refreshChalenger(  )
    rpc:call("Arena.RefreshChallenger", nil, function ( event )
        if event.status == Exceptions.Nil and event.result ~= nil then
            self.ArenaInfo.List = {}
            self.ArenaInfo.List = event.result

            self.EnemtyList:reloadData()

        end
    end)
end

return ColiseumLayer
