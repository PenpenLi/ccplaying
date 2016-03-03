local ActivityPanel = class("ActivityPanel", function()
    local node = cc.Node:create()
    node.controls = {}
    node.data = {}
    return node
end)
local scheduler = cc.Director:getInstance():getScheduler()

local panelRestrictDescTab = {"仅限男性星将", "仅限女性星将", "全体星将"}
local smallPanelPathTab = {"image/ui/img/bg/bg_342.png", "image/ui/img/bg/bg_340.png", "image/ui/img/bg/bg_343.png"}
local logoTab = {"image/ui/img/btn/btn_218.png", "image/ui/img/btn/btn_220.png", "image/ui/img/btn/btn_219.png"}

local EQUIPTOKEN_MODEL = 1
local COINBOSS_MODEL = 2
local FORGESTONE_MODEL = 3

local TOTAL_USE_COUNT = 2
local COST_POWER = 6

function ActivityPanel:ctor(info)
    self.data.panelInfo = info
    local configInfo = BaseConfig.getInstanceDaily(self.data.panelInfo.panelIdx, 1) 
    self.data.isViewScroll = false

    self.controls.bg = cc.Sprite:create("image/ui/img/bg/bg_339.png")
    self:addChild(self.controls.bg)
    local bgSize = self.controls.bg:getContentSize()

    local nameBg = cc.Sprite:create("image/ui/img/btn/btn_950.png")
    nameBg:setPosition(bgSize.width * 0.5, bgSize.height * 0.9)
    self.controls.bg:addChild(nameBg)

    local name = Common.finalFont(configInfo.Name, bgSize.width * 0.5, bgSize.height * 0.9, 25, cc.c3b(249, 250, 130), 1)
    self.controls.bg:addChild(name)

    local bgImg = cc.Sprite:create(smallPanelPathTab[self.data.panelInfo.panelIdx])
    bgImg:setPosition(bgSize.width * 0.5, bgSize.height * 0.58)
    self.controls.bg:addChild(bgImg)

    local countBg = cc.Sprite:create("image/ui/img/btn/btn_1420.png")
    countBg:setPosition(bgSize.width * 0.5, bgSize.height * 0.79)
    self.controls.bg:addChild(countBg)
    self.controls.useCount = Common.finalFont("", bgSize.width * 0.5, bgSize.height * 0.79, 20, nil, 1)
    self.controls.bg:addChild(self.controls.useCount)
    self.controls.useCount:setString("挑战次数:"..self.data.panelInfo.count.."/"..TOTAL_USE_COUNT)

    local join = cc.Sprite:create("image/ui/img/btn/btn_1416.png")
    join:setPosition(bgSize.width * 0.5, bgSize.height * 0.33)
    self.controls.bg:addChild(join)
    join = cc.Sprite:create("image/ui/img/btn/btn_947.png")
    join:setPosition(bgSize.width * 0.5, bgSize.height * 0.33)
    self.controls.bg:addChild(join)
    join:setScale(0.4)
    local rep = cc.RepeatForever:create(cc.RotateBy:create(4, 360))
    join:runAction(rep)
    join = Common.finalFont("进入", bgSize.width * 0.5, bgSize.height * 0.33, 30, cc.c3b(248, 216, 136), 1)
    join:setAdditionalKerning(-2)
    join:enableOutline(cc.c4b(70, 50, 14, 255), 2)
    self.controls.bg:addChild(join)

    local restrictBg = cc.Sprite:create("image/ui/img/btn/btn_1418.png")
    restrictBg:setPosition(bgSize.width * 0.5, bgSize.height * 0.16)
    restrictBg:setScaleX(2.5)
    self.controls.bg:addChild(restrictBg)
    local restrictDesc = Common.finalFont(panelRestrictDescTab[configInfo.HeroRestrict], bgSize.width * 0.5, bgSize.height * 0.16, 20, cc.c3b(143, 255, 99), 1)
    self.controls.bg:addChild(restrictDesc)

    local awardsDesc = Common.finalFont(configInfo.AwardDesc, 1, 1, 20, cc.c3b(0, 240, 250), 1)
    awardsDesc:setPosition(bgSize.width * 0.5 - 20, bgSize.height * 0.08)
    self.controls.bg:addChild(awardsDesc)
    local logoSpri = cc.Sprite:create(logoTab[self.data.panelInfo.panelIdx])
    logoSpri:setPosition(awardsDesc:getPositionX() + awardsDesc:getContentSize().width * 0.5 + 22, bgSize.height * 0.08)
    self.controls.bg:addChild(logoSpri)

    self.data.configInfo = configInfo
    local function onTouchBegan(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if cc.rectContainsPoint(rect, locationInNode) then
            Common.addTopSwallowLayer()
            self.data.isViewScroll = false
            return true
        end
        return false
    end
    local function onTouchMoved(touch, event)
        local deltaPos = touch:getDelta()
        if math.abs(deltaPos.y) > 5 then
            self.data.isViewScroll = true
        end
    end
    local function onTouchEnd(touch, event)
        Common.removeTopSwallowLayer()
        if self.data.isViewScroll then
            return
        end

        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)
        if cc.rectContainsPoint(rect, locationInNode) then
            self:showBossPanel(touch:getLocation().x)
        end
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnd,cc.Handler.EVENT_TOUCH_ENDED)
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.controls.bg)
end

function ActivityPanel:showBossPanel(initPosX)
    local configInfo = self.data.configInfo
    local panelInfo = self.data.panelInfo

    local node = cc.Node:create()
    local swallowLayer = Common.swallowLayer(SCREEN_WIDTH, SCREEN_HEIGHT, 0, 0)
    node:addChild(swallowLayer)
    local runningScene = cc.Director:getInstance():getRunningScene()
    runningScene:addChild(node)

    local bgSize = cc.size(712, 480)
    local bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_346.png")
    bg:setContentSize(bgSize)
    bg:setPosition(initPosX, SCREEN_HEIGHT * 0.5)
    bg:setScale(0.05)
    node:addChild(bg)

    local time = 0.2
    local scale = cc.ScaleTo:create(time, 1)
    local jump = cc.JumpTo:create(time, cc.p(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5), 100, 1)
    local spawn = cc.Spawn:create(scale, jump)
    bg:runAction(cc.Sequence:create({spawn}))

    local nameBg = cc.Sprite:create("image/ui/img/btn/btn_950.png")
    nameBg:setPosition(bgSize.width * 0.5, bgSize.height * 0.98)
    bg:addChild(nameBg)
    local panelName = Common.finalFont(configInfo.Name, bgSize.width * 0.5, bgSize.height * 0.98, 25, cc.c3b(249, 250, 130), 1)
    bg:addChild(panelName)

    local bossBg = cc.Sprite:create("image/ui/img/bg/bg_344.png")
    bossBg:setPosition(bgSize.width * 0.24, bgSize.height * 0.59)
    bg:addChild(bossBg)
    local logo = cc.Sprite:create("image/ui/img/btn/btn_363.png")
    logo:setPosition(bgSize.width * 0.12, bgSize.height * 0.85)
    bg:addChild(logo)
    logo:setScale(0.5)

    local bossConfig = BaseConfig.GetMonster(configInfo.BossID)
    local bossName = Common.finalFont(bossConfig.Name, bgSize.width * 0.26, bgSize.height * 0.85, 25, cc.c3b(158, 185, 230))
    bg:addChild(bossName)

    if COINBOSS_MODEL == panelInfo.panelIdx then
        local player =  sp.SkeletonAnimation:create("image/spine/monster/"..bossConfig.Res.."/skeleton.skel", 
                                                "image/spine/monster/"..bossConfig.Res.."/skeleton.atlas")
        player:setAnimation(0,"idle",true)
        player:setPosition(bgSize.width * 0.25, bgSize.height * 0.38)
        player:setScaleX(-0.5)
        player:setScaleY(0.5)
        bg:addChild(player)
    else
        local res = tonumber(string.sub(bossConfig.Res, 4, string.len(bossConfig.Res)))

        local player = require("tool.helper.HeroAction").new(bgSize.width * 0.25, bgSize.height * 0.38, res)
        player:setAnimation(0,"idle",true)
        bg:addChild(player)
    end

    local descBg = cc.Scale9Sprite:create("image/ui/img/bg/bg_345.png")
    descBg:setContentSize(cc.size(346, 270))
    descBg:setPosition(bgSize.width * 0.7, bgSize.height * 0.61)
    bg:addChild(descBg)

    local line = cc.Sprite:create("image/ui/img/btn/btn_781.png")
    line:setPosition(bgSize.width * 0.7, bgSize.height * 0.84)
    bg:addChild(line)
    line = cc.Sprite:create("image/ui/img/btn/btn_786.png")
    line:setPosition(bgSize.width * 0.58, bgSize.height * 0.84)
    bg:addChild(line)
    line = cc.Sprite:create("image/ui/img/btn/btn_786.png")
    line:setScaleX(-1)
    line:setPosition(bgSize.width * 0.82, bgSize.height * 0.84)
    bg:addChild(line)
    line = cc.Sprite:create("image/ui/img/btn/btn_781.png")
    line:setPosition(bgSize.width * 0.7, bgSize.height * 0.58)
    bg:addChild(line)
    line = cc.Sprite:create("image/ui/img/btn/btn_786.png")
    line:setPosition(bgSize.width * 0.58, bgSize.height * 0.58)
    bg:addChild(line)
    line = cc.Sprite:create("image/ui/img/btn/btn_786.png")
    line:setScaleX(-1)
    line:setPosition(bgSize.width * 0.82, bgSize.height * 0.58)
    bg:addChild(line)

    local title1 = Common.finalFont("简介", 1, 1, 22, cc.c3b(19, 59, 98))
    title1:setPosition(bgSize.width * 0.7, bgSize.height * 0.84)
    bg:addChild(title1)
    local title2 = Common.finalFont("攻略", 1, 1, 22, cc.c3b(19, 59, 98))
    title2:setPosition(bgSize.width * 0.7, bgSize.height * 0.58)
    bg:addChild(title2)

    local desc1 = Common.finalFont(configInfo.Desc, 1, 1, 20, cc.c3b(72,106,167))
    desc1:setAnchorPoint(0, 1)
    desc1:setPosition(bgSize.width * 0.47, bgSize.height * 0.8)
    bg:addChild(desc1)
    desc1:setDimensions(320, 100)
    
    local desc2 = Common.finalFont(configInfo.Strategy, 1, 1, 20, cc.c3b(72,106,167))
    desc2:setAnchorPoint(0, 1)
    desc2:setPosition(bgSize.width * 0.47, bgSize.height * 0.54)
    bg:addChild(desc2)
    desc2:setDimensions(320, 100)

    local bottomBg = cc.Scale9Sprite:create("image/ui/img/bg/bg_347.png")
    bottomBg:setContentSize(cc.size(684, 110))
    bottomBg:setPosition(bgSize.width * 0.5, bgSize.height * 0.2)
    bg:addChild(bottomBg)

    local desc = Common.finalFont("今日剩余挑战次数:", bgSize.width * 0.06, bgSize.height * 0.24, 18, nil, 1)
    desc:setAnchorPoint(0, 0.5)
    desc:setAdditionalKerning(-2)
    bg:addChild(desc)
    local countDesc = Common.finalFont("", desc:getPositionX() + desc:getContentSize().width, bgSize.height * 0.24, 18, nil, 1)
    countDesc:setAnchorPoint(0, 0.5)
    bg:addChild(countDesc)
    countDesc:setString(panelInfo.count.."/"..TOTAL_USE_COUNT)

    desc = Common.finalFont("副本限制:", bgSize.width * 0.06, bgSize.height * 0.17, 18, nil, 1)
    desc:setAnchorPoint(0, 0.5)
    desc:setAdditionalKerning(-2)
    bg:addChild(desc)
    local restrictDesc = Common.finalFont(panelRestrictDescTab[configInfo.HeroRestrict], 1, 1, 18, cc.c3b(143, 255, 99), 1)
    restrictDesc:setAnchorPoint(0, 0.5)
    restrictDesc:setAdditionalKerning(-2)
    restrictDesc:setPosition(desc:getPositionX() + desc:getContentSize().width, bgSize.height * 0.17)
    bg:addChild(restrictDesc)

    desc = Common.finalFont("副本掉落:", bgSize.width * 0.06, bgSize.height * 0.1, 18, nil, 1)
    desc:setAnchorPoint(0, 0.5)
    desc:setAdditionalKerning(-2)
    bg:addChild(desc)
    local awardsDesc = Common.finalFont(configInfo.AwardDesc, 1, 1, 18, cc.c3b(0, 240, 250), 1)
    awardsDesc:setAnchorPoint(0, 0.5)
    awardsDesc:setAdditionalKerning(-2)
    awardsDesc:setPosition(desc:getPositionX() + desc:getContentSize().width, bgSize.height * 0.1)
    bg:addChild(awardsDesc)
    local logoSpri = cc.Sprite:create(logoTab[panelInfo.panelIdx])
    logoSpri:setPosition(awardsDesc:getPositionX() + awardsDesc:getContentSize().width + 20, bgSize.height * 0.1)
    bg:addChild(logoSpri)

    local btnBgPathTab = {"image/ui/img/btn/btn_957.png", "image/ui/img/btn/btn_956.png", "image/ui/img/btn/btn_955.png"}
    local btnNamePathTab = {"image/ui/img/btn/btn_954.png", "image/ui/img/btn/btn_953.png", "image/ui/img/btn/btn_952.png"}
    local buttonTab = {}
    for i=1,3 do
        local btn = createMixSprite(btnBgPathTab[i], nil, btnNamePathTab[i])
        btn:setButtonBounce(false)
        bg:addChild(btn)
        btn:setScale(0.8)
        btn:setPosition(bgSize.width * 0.53 + (i - 1) * 120, bgSize.height * 0.2)
        buttonTab[i] = btn
        btn:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                self:battleBigen(self.data.panelInfo.panelIdx, i, function( ... )
                    countDesc:setString(self.data.panelInfo.count.."/"..TOTAL_USE_COUNT)
                end)
            end
        end)

        local restrict = createMixSprite("image/ui/img/btn/btn_958.png")
        restrict:setTouchEnable(false)
        restrict:setCircleFont("", 1, 1, 20, cc.c3b(252, 255, 0), 1)
        bg:addChild(restrict)
        restrict:setPosition(bgSize.width * 0.53 + (i - 1) * 120, bgSize.height * 0.13)

        local configLevel = tonumber(BaseConfig.getInstanceDaily(panelInfo.panelIdx, i).Level)
        restrict:setString("限"..configLevel.."级")
        if GameCache.Avatar.Level >= configLevel then
            btn:setTouchEnable(true)
            restrict:setScale(0)
        else
            btn:setTouchEnable(false)
            btn:setNorGLProgram(false)
            restrict:setScale(1)
        end
    end
    
    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)
        local startpos = bg:convertToNodeSpace(touch:getStartLocationInView())

        if (not cc.rectContainsPoint(rect, locationInNode)) and (not cc.rectContainsPoint(rect, startpos)) then
            node:removeFromParent()
            node = nil
        end
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(function()
        return true
    end,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, bg)
end


function ActivityPanel:battleBigen(panelIdx, difficulty, callback)
    if GameCache.Avatar.PhyPower < COST_POWER then
        require("tool.helper.CommonLayer").NeedPower()
        return
    end

    if self.data.panelInfo.count >= TOTAL_USE_COUNT then
        application:showFlashNotice("挑战次数已用完~!")
    else
        CCLog("--------Difficulty--------", difficulty)
        local config = BaseConfig.getInstanceDaily(panelIdx, difficulty)
        local nodeSequenceTab = {}
        for k,v in pairs(config.NodeSeqList) do
            local InstanceChapter = BaseConfig.GetNodeSequenceByID(v)
            table.insert(nodeSequenceTab, InstanceChapter)
        end
        local goodsInfo = {}
        goodsInfo.ID = config.Award.GoodsID
        goodsInfo.Type = config.Award.GoodsType
        goodsInfo.Num = config.Award.Num

        local battleEndCallback = function(result)
            local iswin = result.result == "win" and true or false     
            rpc:call("InstanceDaily.EndF", {SessionID = result.sessionID, IsWin = iswin, EnemyHp = result.climbEnemy, BossHurt = result.enemyFullHP - result.enemyLeftHP}, function(event)
                if event.status == Exceptions.Nil then
                    local function setCountNum()
                        if self.data.panelInfo.count < TOTAL_USE_COUNT then
                            self.data.panelInfo.count = self.data.panelInfo.count + 1
                            self.controls.useCount:setString("挑战次数:"..self.data.panelInfo.count.."/"..TOTAL_USE_COUNT)
                            callback()
                        end
                    end
                    if panelIdx == COINBOSS_MODEL then
                        setCountNum()
                    elseif iswin then
                        setCountNum()
                    end

                    local goodsTabs = event.result.AwardList
                    self:battleEnd(iswin, goodsTabs)
                end
            end, {show=false, debug=false, retryOnError = true} )
        end         

        local beforeFCallback = function(event)
            if event.status == Exceptions.Nil then
                local params = {
                    nodeID = panelIdx, 
                    sessionID = event.result.SessionID,
                    attackerForm = event.result.Form,
                    battleType = "PVE",
                    battleSystem = enums.BattleSystem.Activity,
                    map = config.MapID,
                    HeroRestrict = config.HeroRestrict,
                    nodeSequence = nodeSequenceTab,
                    droplist = goodsInfo,
                    callback = battleEndCallback
                }

                application:pushScene("form.BattleFormScene", GameCache.FORM_TYPE_DAILY, params)
            end
        end   
        rpc:call("InstanceDaily.BeforeF",  { ID = panelIdx, DiffLevel = difficulty }, beforeFCallback)
    end
end

function ActivityPanel:battleEnd(isWin, goodsInfos)
    local scene = cc.Director:getInstance():getRunningScene()
    local swallowLayer = Common.swallowLayer(SCREEN_WIDTH, SCREEN_HEIGHT, 0, 0)
    scene:addChild(swallowLayer)

    local isCoinModel = (self.data.panelInfo.panelIdx == COINBOSS_MODEL)

    local function createWinUI()
        Common.playSound("audio/effect/map_battle_win.mp3")
        local layer = cc.LayerColor:create(cc.c4b(0,0,0,150), SCREEN_WIDTH, SCREEN_HEIGHT)
        scene:addChild(layer)
        local light = cc.Sprite:create("image/ui/img/btn/btn_343.png")
        light:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.73)
        layer:addChild(light)
        local rep = cc.RepeatForever:create(cc.RotateBy:create(3.0, 360))
        light:runAction(rep)
    
        local sidai = cc.Sprite:create("image/ui/img/bg/bg_160.png")
        sidai:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.73)
        layer:addChild(sidai)

        local icon = cc.Sprite:create("image/ui/img/btn/btn_632.png")
        icon:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.8)
        icon:setScale(0.1)
        icon:runAction(cc.Sequence:create({cc.ScaleTo:create(0.2, 1.2),cc.ScaleTo:create(0.05, 1.0)}))
        layer:addChild(icon)

        local bg = cc.Sprite:create("image/ui/img/bg/bg_163.png")
        bg:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.4)
        layer:addChild(bg)

        local exp = cc.Sprite:create("image/ui/img/btn/btn_671.png")
        exp:setAnchorPoint(1, 0.5)
        exp:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.52)
        layer:addChild(exp)

        local expValue = Common.finalFont("+60", SCREEN_WIDTH * 0.5 + 2, SCREEN_HEIGHT * 0.52, 20, cc.c3b(151, 255, 74), 1)
        expValue:setAnchorPoint(0, 0.5)
        layer:addChild(expValue)

        local coinScheduler = nil
        if isCoinModel then
            local total = #goodsInfos - 1
            local iconbg = ccui.ImageView:create("image/ui/img/bg/bg_161.png")
            iconbg:setScale9Enabled(true)
            iconbg:setContentSize(cc.size(total * 90,80))
            iconbg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT*0.42)
            layer:addChild(iconbg) 

            local itemWidth = 40
            local initWidth = iconbg:getContentSize().width * 0.5 - itemWidth * (total - 1)
            for k,info in pairs(goodsInfos) do
                if k == #goodsInfos then
                    break
                end
                local goodsItem = Common.getGoods(info, true, BaseConfig.GOODS_SMALLTYPE)
                goodsItem:setPosition(initWidth + (k - 1) * itemWidth * 2 , iconbg:getContentSize().height * 0.5)
                iconbg:addChild(goodsItem)
            end

            local coinSpri = cc.Sprite:create("image/ui/img/btn/btn_1353.png")
            coinSpri:setAnchorPoint(1, 0.5)
            coinSpri:setPosition(SCREEN_WIDTH * 0.5 - 16, SCREEN_HEIGHT * 0.58)
            layer:addChild(coinSpri)
            coinSpri:setScale(0.6)

            local coinLab = Common.finalFont("0", SCREEN_WIDTH * 0.5 - 10, SCREEN_HEIGHT * 0.58, 25, nil, 1)
            coinLab:setAnchorPoint(0, 0.5)
            layer:addChild(coinLab)

            local coinCount = 0
            local coinTotal = goodsInfos[#goodsInfos].Num
            local speed = math.floor(coinTotal / 40)
            coinScheduler = scheduler:scheduleScriptFunc(function()
                if coinCount > coinTotal then
                    coinLab:setString("+"..coinTotal)
                else
                    coinCount = coinCount + speed
                    coinLab:setString("+"..coinCount)
                end
            end, 0, false)
        else
            local total = #goodsInfos
            local iconbg = ccui.ImageView:create("image/ui/img/bg/bg_161.png")
            iconbg:setScale9Enabled(true)
            iconbg:setContentSize(cc.size(total * 90,80))
            iconbg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT*0.42)
            layer:addChild(iconbg) 

            local itemWidth = 40
            local initWidth = iconbg:getContentSize().width * 0.5 - itemWidth * (total - 1)
            for k,info in pairs(goodsInfos) do
                local goodsItem = Common.getGoods(info, true, BaseConfig.GOODS_SMALLTYPE)
                goodsItem:setPosition(initWidth + (k - 1) * itemWidth * 2 , iconbg:getContentSize().height * 0.5)
                iconbg:addChild(goodsItem)
            end
        end

        local btn = createMixSprite("image/ui/img/btn/btn_553.png")
        btn:setCircleFont("确定", 1, 1, 25, cc.c3b(226,204,169), 1)
        btn:setFontOutline(cc.c4b(65,26,1, 255), 1)
        btn:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.25)
        btn:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                if coinScheduler then
                    scheduler:unscheduleScriptEntry(coinScheduler)
                end
                cc.Director:getInstance():popScene()
            end
        end)
        layer:addChild(btn)
    end

    if isCoinModel then
        createWinUI()
    elseif isWin then
        createWinUI()
    else
        local layer = require("tool.helper.CommonLayer").BattleFailLayer()
        local btn_back = createMixSprite("image/ui/img/btn/btn_553.png")
        btn_back:setCircleFont("确定", 1, 1, 25, cc.c3b(238, 205, 142), 1)
        btn_back:setFontOutline(cc.c3b(70, 50, 14), 1)
        btn_back:setPosition(SCREEN_WIDTH * 0.85, SCREEN_HEIGHT * 0.3)
        layer:addChild(btn_back)
        btn_back:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                cc.Director:getInstance():popScene()
            end
        end)
        scene:addChild(layer)
    end
end

return ActivityPanel


