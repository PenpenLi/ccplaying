local Recharge = class("Recharge", BaseLayer)
local ColorLabel = require("tool.helper.ColorLabel")

local bgZOrder = 2
local btnZOrder = bgZOrder + 1

local rechargePanel = 1
local vipPanel = rechargePanel + 1
local LAYERCOLORTAG = 10

local vipTotal = 15

function Recharge:ctor()
    BaseConfig.getPurchaseConfig()
    self.data.currPanel = rechargePanel
    self.data.currShowVipLevel = 1

    self:addListener()
    self:createTitleUI()
    self:rechargeUI()
    self:vipDescUI()

    self:updateVipDesc(self.data.currShowVipLevel)
end

function Recharge:onClose()
    for _,listener in pairs(self.listeners) do
        application:removeEventListener(listener)
    end
    cc.Director:getInstance():popScene()
end

function Recharge:addListener()
    self.listeners = {}
    local listener = application:addEventListener(AppEvent.UI.Avatar.VIPExp, function(event)
        self.controls.currVipLevel:setString(GameCache.Avatar.VIP)
        if GameCache.Avatar.VIP < vipTotal then
            self.controls.nextVipLevel:setString(GameCache.Avatar.VIP + 1)
            local vipExp = BaseConfig.getVipExp(GameCache.Avatar.VIP + 1)
            self.controls.addMoney:setString(vipExp - GameCache.Avatar.VIPExp)
            self.controls.exp:setString(GameCache.Avatar.VIPExp.."/"..vipExp)
            self.controls.vipExp:setPercent((GameCache.Avatar.VIPExp/vipExp) * 100)
        else
            local vipExp = BaseConfig.getVipExp(vipTotal)
            self.controls.exp:setString(vipExp.."/"..vipExp)
            self.controls.vipExp:setPercent(100)
            if self.controls.nextVipLevel then
                self.controls.nextVipLevel:setVisible(false)
            end
            if self.controls.addMoney then
                self.controls.addMoney:setVisible(false)
            end
        end
    end)
    table.insert(self.listeners, listener)
end

function Recharge:createTitleUI()
	local bg = cc.Sprite:create("image/ui/img/bg/bg_037.jpg")
    bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    self:addChild(bg)

    local pay = require("scene.main.PayListNode").new(GameCache.Avatar.PhyPower, GameCache.Avatar.MaxPhyPower,
        GameCache.Avatar.Endurance, GameCache.Avatar.MaxEndurance,
        GameCache.Avatar.Coin, GameCache.Avatar.Gold)
    local paySize = pay:getContentSize()
    pay:setPosition(SCREEN_WIDTH * 0.5 - paySize.width * 0.5, SCREEN_HEIGHT * 0.92)
    self:addChild(pay)

    local bgLayer = cc.LayerColor:create(cc.c4b(0,0,0,150), SCREEN_WIDTH, SCREEN_HEIGHT)
    bgLayer:setPosition(0, 0)
    self:addChild(bgLayer)
    local swallowLayer = Common.swallowLayer(SCREEN_WIDTH, SCREEN_HEIGHT, 0, 0)
    self:addChild(swallowLayer)

    self.controls.bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_205.png") 
    self.controls.bg:setContentSize(cc.size(942, 535))
    self.controls.bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.43)
    self:addChild(self.controls.bg)
    local size = self.controls.bg:getContentSize()

    local timuBg = createMixScale9Sprite("image/ui/img/bg/bg_305.png", nil, nil, cc.size(930, 80)) 
    timuBg:setTouchEnable(false)
    timuBg:setPosition(size.width * 0.5, size.height * 0.9)
    self.controls.bg:addChild(timuBg, bgZOrder)

    self.controls.title = createMixSprite("image/ui/img/btn/btn_851.png", nil, "image/ui/img/btn/btn_860.png")
    self.controls.title:setTouchEnable(false)
    self.controls.title:setChildPos(0.48, 0.5)
    self.controls.title:setPosition(size.width * 0.5, size.height)
    self.controls.bg:addChild(self.controls.title, bgZOrder)

    self.controls.titleNode = cc.Node:create()
    self.controls.bg:addChild(self.controls.titleNode, bgZOrder)

    local vipSpri = cc.Sprite:create("image/ui/img/btn/btn_856.png")
    vipSpri:setPosition(size.width * 0.08, size.height * 0.88)
    self.controls.titleNode:addChild(vipSpri)
    self.controls.currVipLevel = cc.Label:createWithCharMap("image/ui/img/btn/btn_627.png", 44, 52,  string.byte("0"))
    self.controls.currVipLevel:setAdditionalKerning(-10)
    self.controls.currVipLevel:setPosition(size.width * 0.12, size.height * 0.88)
    self.controls.titleNode:addChild(self.controls.currVipLevel)
    self.controls.currVipLevel:setString(GameCache.Avatar.VIP)
    self.controls.currVipLevel:setScale(0.5)
    local bar_BG = cc.Sprite:create("image/ui/img/btn/btn_857.png")
    bar_BG:setPosition(size.width * 0.28, size.height * 0.88)
    self.controls.titleNode:addChild(bar_BG)
    self.controls.vipExp = ccui.LoadingBar:create("image/ui/img/btn/btn_853.png")
    self.controls.vipExp:setPosition(size.width * 0.28, size.height * 0.88)
    self.controls.titleNode:addChild(self.controls.vipExp)
    self.controls.exp = Common.finalFont("", size.width * 0.25, size.height * 0.92, 20, cc.c3b(126, 135, 141))
    self.controls.titleNode:addChild(self.controls.exp)

    if GameCache.Avatar.VIP < vipTotal then
        local vipDesc = Common.finalFont("再充", size.width * 0.45, size.height * 0.88, 20, nil, 1)
        self.controls.titleNode:addChild(vipDesc)
        vipDesc = Common.finalFont("可升级为", size.width * 0.66, size.height * 0.88, 20, nil, 1)
        self.controls.titleNode:addChild(vipDesc)

        local goldSpri = cc.Sprite:create("image/ui/img/btn/btn_060.png")
        goldSpri:setPosition(size.width * 0.5, size.height * 0.88)
        self.controls.titleNode:addChild(goldSpri)
        vipSpri = cc.Sprite:create("image/ui/img/btn/btn_856.png")
        vipSpri:setPosition(size.width * 0.73, size.height * 0.88)
        self.controls.titleNode:addChild(vipSpri)

        self.controls.addMoney = Common.finalFont("", size.width * 0.56, size.height * 0.88, 25, cc.c3b(255, 246, 0))
        self.controls.addMoney:setAdditionalKerning(-2)
        self.controls.titleNode:addChild(self.controls.addMoney)

        self.controls.nextVipLevel = cc.Label:createWithCharMap("image/ui/img/btn/btn_627.png", 44, 52,  string.byte("0"))
        self.controls.nextVipLevel:setAdditionalKerning(-10)
        self.controls.nextVipLevel:setPosition(size.width * 0.77, size.height * 0.88)
        self.controls.titleNode:addChild(self.controls.nextVipLevel)
        self.controls.nextVipLevel:setString(GameCache.Avatar.VIP + 1)
        self.controls.nextVipLevel:setScale(0.5)
        
        local vipExp = BaseConfig.getVipExp(GameCache.Avatar.VIP + 1)
        self.controls.exp:setString(GameCache.Avatar.VIPExp.."/"..vipExp)
        self.controls.vipExp:setPercent((GameCache.Avatar.VIPExp/vipExp) * 100)
        self.controls.addMoney:setString(vipExp - GameCache.Avatar.VIPExp)
    else
        local vipExp = BaseConfig.getVipExp(vipTotal)
        self.controls.exp:setString(vipExp.."/"..vipExp)
        self.controls.vipExp:setPercent(100)
    end
    
    local btn_vip = createMixScale9Sprite("image/ui/img/btn/btn_818.png", nil, nil, cc.size(140, 60)) 
    btn_vip:setCircleFont("VIP特权", 1, 1, 25, cc.c3b(238, 205, 142))
    btn_vip:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
    btn_vip:setPosition(size.width * 0.88, size.height * 0.9)
    self.controls.titleNode:addChild(btn_vip)
    btn_vip:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if rechargePanel == self.data.currPanel then
                self.data.currPanel = vipPanel
                btn_vip:setString("充值")
                self.controls.title:setChildTexture("image/ui/img/btn/btn_859.png")

                self.controls.rechargeNode:setPosition(-SCREEN_WIDTH * 2, -SCREEN_HEIGHT * 2)
                self.controls.vipNode:setPosition(0, 0)
                CCLog("===========vip特权==============")
            elseif vipPanel == self.data.currPanel then
                self.data.currPanel = rechargePanel
                btn_vip:setString("VIP特权")
                self.controls.title:setChildTexture("image/ui/img/btn/btn_860.png")

                self.controls.vipNode:setPosition(-SCREEN_WIDTH * 2, -SCREEN_HEIGHT * 2)
                self.controls.rechargeNode:setPosition(0, 0)
                CCLog("===========充值==============")
            end
            
        end
    end)

    local btn_close = createMixSprite("image/ui/img/btn/btn_598.png")
    btn_close:setPosition(size.width * 0.96, size.height * 1.1)
    btn_close:setLocalZOrder(btnZOrder)
    self.controls.bg:addChild(btn_close)
    btn_close:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:onClose()
        end
    end)
end

function Recharge:rechargeUI()
    local bgSize = self.controls.bg:getContentSize()
    self.controls.rechargeNode = cc.Node:create()
    self.controls.bg:addChild(self.controls.rechargeNode, bgZOrder)

    local month = cc.Sprite:create("image/ui/img/bg/bg_307.png")
    month:setPosition(bgSize.width * 0.17, bgSize.height * 0.35)
    self.controls.rechargeNode:addChild(month)

    if not GameCache.isExamine then
        local fairyAnim = sp.SkeletonAnimation:create("image/spine/fairy/1006/skeleton.skel", "image/spine/fairy/1006/skeleton.atlas")
        fairyAnim:setPosition(bgSize.width * 0.17, bgSize.height * 0.1)
        self.controls.rechargeNode:addChild(fairyAnim)
        fairyAnim:setAnimation(0, "idl_1", true)

        local ding = cc.Sprite:create("image/ui/img/bg/bg_308.png")
        ding:setPosition(bgSize.width * 0.17, bgSize.height * 0.73)
        self.controls.rechargeNode:addChild(ding, bgZOrder)
    else
        local leftSpri = cc.Sprite:create("image/ui/img/bg/bg_322.png")
        leftSpri:setPosition(bgSize.width * 0.17, bgSize.height * 0.425)
        self.controls.rechargeNode:addChild(leftSpri)
        leftSpri:setScaleX(0.95)
    end

    -- local monthBg = cc.Sprite:create("image/ui/img/bg/bg_309.png")
    -- monthBg:setPosition(bgSize.width * 0.17, bgSize.height * 0.16)
    -- self.controls.rechargeNode:addChild(monthBg)
    -- local monthSize = monthBg:getContentSize()

    -- local monthLogo = cc.Sprite:create("image/ui/img/btn/btn_844.png") 
    -- monthLogo:setPosition(bgSize.width * 0.08, bgSize.height * 0.17)
    -- self.controls.rechargeNode:addChild(monthLogo)
    -- self.controls.residualDay = Common.finalFont("剩余20天", bgSize.width * 0.24, bgSize.height * 0.17, 20, nil, 1)
    -- self.controls.rechargeNode:addChild(self.controls.residualDay)
    -- local monthPrice = Common.finalFont("RMB1", bgSize.width * 0.25, bgSize.height * 0.1, 30, nil, 1)
    -- self.controls.rechargeNode:addChild(monthPrice)

    -- local song1 = cc.Sprite:create("image/ui/img/btn/btn_840.png") 
    -- song1:setScale(0.8)
    -- song1:setPosition(monthSize.width * 0.84, monthSize.height)
    -- monthBg:addChild(song1, bgZOrder)
    -- self:presentAction(song1)
    -- local song2 = cc.Sprite:create("image/ui/img/btn/btn_841.png") 
    -- song2:setPosition(monthSize.width * 0.84, monthSize.height * 1.1)
    -- monthBg:addChild(song2, bgZOrder)
    -- local song3 = cc.Sprite:create("image/ui/img/btn/btn_060.png") 
    -- song3:setPosition(monthSize.width * 0.8, monthSize.height * 0.88)
    -- monthBg:addChild(song3, bgZOrder)
    -- local song4 = Common.finalFont("1", monthSize.width * 0.88, monthSize.height * 0.88, 20, nil, 1)
    -- song4:setAdditionalKerning(-4)
    -- song4:enableOutline(cc.c3b(180, 80, 0), 2)
    -- monthBg:addChild(song4, bgZOrder)

    -- local function onTouchBegan(touch, event)
    --     local target = event:getCurrentTarget()
    --     local locationInNode = target:convertToNodeSpace(touch:getLocation())
    --     local s = target:getContentSize()
    --     local rect = cc.rect(0, 0, s.width, s.height)

    --     if cc.rectContainsPoint(rect, locationInNode) then
    --         return true
    --     end
    --     return false
    -- end
    -- local function onTouchEnd(touch, event)
    --     CCLog("=================================")
    -- end

    -- local eventDispatcher = self:getEventDispatcher()
    -- local listener1 = cc.EventListenerTouchOneByOne:create()
    -- listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
    -- listener1:registerScriptHandler(onTouchEnd,cc.Handler.EVENT_TOUCH_ENDED)
    -- eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, monthBg)

    local eventDispatcher = self:getEventDispatcher()
    for i=1,6 do
        local bg = cc.Sprite:create("image/ui/img/bg/bg_198.png")
        if (i == 5) or (i == 6) then
            bg:setTexture("image/ui/img/bg/bg_306.png")
        end
        local size = bg:getContentSize()
        bg:setPosition(bgSize.width * 0.435 + ((i - 1) % 3) * size.width * 1.08, 
                        bgSize.height * 0.62 - math.floor((i - 1) / 3) * size.height * 1.05)
        self.controls.rechargeNode:addChild(bg)

        local restrict1 = cc.Sprite:create("image/ui/img/btn/btn_855.png")
        restrict1:setPosition(size.width * 0.18, size.height * 0.83)
        bg:addChild(restrict1)

        local monthMoney = createMixSprite("image/ui/img/bg/bg_199.png", nil, "image/ui/img/btn/btn_060.png") 
        monthMoney:setTouchEnable(false)
        monthMoney:setPosition(size.width * 0.65, size.height * 0.92)
        bg:addChild(monthMoney)
        monthMoney:setCircleFont(BaseConfig.purchaseConfig[i].Money * 10, 1, 1, 25, cc.c3b(255, 246, 0))
        monthMoney:setChildPos(0.25, 0.5)
        monthMoney:setFontPos(0.65, 0.5)

        local logoPath = string.format("image/ui/img/btn/btn_%3d.png", 844 + i)
        local monthLogo = createMixSprite(logoPath) 
        monthLogo:setTouchEnable(false)
        monthLogo:setPosition(size.width * 0.5, size.height * 0.55)
        bg:addChild(monthLogo)

        local song1 = cc.Sprite:create("image/ui/img/btn/btn_840.png") 
        song1:setScale(0.6)
        song1:setPosition(size.width * 0.75, size.height * 0.36)
        bg:addChild(song1, bgZOrder)
        self:presentAction(song1)
        local song2 = cc.Sprite:create("image/ui/img/btn/btn_842.png") 
        song2:setPosition(size.width * 0.75, size.height * 0.42)
        bg:addChild(song2, bgZOrder)
        local song3 = cc.Sprite:create("image/ui/img/btn/btn_060.png") 
        song3:setPosition(size.width * 0.65, size.height * 0.3)
        bg:addChild(song3, bgZOrder)
        local restrict2 = Common.finalFont(BaseConfig.purchaseConfig[i].Present, size.width * 0.73, size.height * 0.3, 20, nil, 1)
        restrict2:setAnchorPoint(0, 0.5)
        restrict2:setAdditionalKerning(-4)
        restrict2:enableOutline(cc.c3b(180, 80, 0), 2)
        bg:addChild(restrict2, bgZOrder)

        local priceSpri = cc.Sprite:create("image/ui/img/btn/btn_858.png")
        priceSpri:setPosition(size.width * 0.43, size.height * 0.12)
        bg:addChild(priceSpri)
        local price = Common.finalFont(BaseConfig.purchaseConfig[i].Money, 
                                    size.width * 0.5, size.height * 0.12, 25, nil, 1)
        price:setAnchorPoint(0, 0.5)
        bg:addChild(price)
        
        local function onTouchBegan(touch, event)
            local target = event:getCurrentTarget()
            local locationInNode = target:convertToNodeSpace(touch:getLocation())
            local s = target:getContentSize()
            local rect = cc.rect(0, 0, s.width, s.height)

            if cc.rectContainsPoint(rect, locationInNode) then
                return true
            end
            return false
        end
        local function onTouchEnd(touch, event)
            -- 充值价格
            CCLog("=============price=", BaseConfig.purchaseConfig[i].Money)
        
            if GAME_BASE_INFO.SDK then
                local purchaseItem = BaseConfig.purchaseConfig[i]        
                rpc:call("Game.CreatePurchaseOrder", purchaseItem.IAPID, function(event)        
                    if event.status == Exceptions.Nil then        
                        local orderID = event.result        
                        SDK_doPay(orderID, purchaseItem)        
                      end        
                end)
            end
        end

        local listener = cc.EventListenerTouchOneByOne:create()
        listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
        listener:registerScriptHandler(onTouchEnd,cc.Handler.EVENT_TOUCH_ENDED)
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, bg)
    end
end

function Recharge:vipDescUI()
    local bgSize = self.controls.bg:getContentSize()
    self.controls.vipNode = cc.Node:create()
    self.controls.bg:addChild(self.controls.vipNode, bgZOrder)
    self.controls.vipNode:setPosition(-SCREEN_WIDTH * 2, -SCREEN_HEIGHT * 2)

    local btnBg = cc.Sprite:create("image/ui/img/bg/bg_310.png")
    btnBg:setPosition(bgSize.width * 0.145, bgSize.height * 0.43)
    self.controls.vipNode:addChild(btnBg)

    self.data.vipBtnTab = {}
    local btnViewSize = cc.size(btnBg:getContentSize().width, btnBg:getContentSize().height * 0.92)
    self.controls.btnView = self:createVipBtnView(btnViewSize)
    self.controls.btnView:setPosition(20, 30)
    self.controls.vipNode:addChild(self.controls.btnView)

    self.controls.vipDescView = self:createDescView(cc.size(bgSize.width * 0.5, bgSize.height * 0.6))
    self.controls.vipDescView:setPosition(bgSize.width * 0.38, bgSize.height * 0.08)
    self.controls.vipNode:addChild(self.controls.vipDescView)

    local title1 = createMixSprite("image/ui/img/btn/btn_837.png", nil, "image/ui/img/btn/btn_856.png") 
    title1:setTouchEnable(false)
    title1:setCircleFont("特权", 1, 1, 20, cc.c3b(255, 246, 0), 1)
    title1:setFontOutline(cc.c3b(88, 15, 0), 1)
    title1:setChildPos(0.3, 0.6)
    title1:setFontPos(0.7, 0.6)
    title1:setPosition(bgSize.width * 0.62, bgSize.height * 0.75)
    self.controls.vipNode:addChild(title1)

    self.controls.currVipSpecial = Common.finalFont("12", 1, 1, 25, cc.c3b(255, 246, 0))
    self.controls.currVipSpecial:setPosition(bgSize.width * 0.62, bgSize.height * 0.762)
    self.controls.vipNode:addChild(self.controls.currVipSpecial)

    self.controls.VipSpecialDesc = ColorLabel.new("[255,255,255]累计充值[=][255,246,0]".."1000".."[=][255,255,255]元宝即可享受该级特权[=]", 20)
    self.controls.VipSpecialDesc:setAdditionalKerning(-5)
    self.controls.VipSpecialDesc:setPosition(bgSize.width * 0.62, bgSize.height * 0.67)
    self.controls.vipNode:addChild(self.controls.VipSpecialDesc)

    local line = cc.Sprite:create("image/ui/img/btn/btn_1314.png")
    line:setPosition(bgSize.width * 0.6, bgSize.height * 0.64)
    line:setScaleX(1.5)
    self.controls.vipNode:addChild(line)

    local function moveTouchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local name = sender:getName()
            if name == "left" then
                if self.data.currShowVipLevel > 1 then
                    self.data.currShowVipLevel = self.data.currShowVipLevel - 1
                end
            elseif name == "right" then
                if self.data.currShowVipLevel < vipTotal then
                    self.data.currShowVipLevel = self.data.currShowVipLevel + 1
                end
            end
            self.controls.vipDescView:scrollToPage(self.data.currShowVipLevel - 1)
            self:updateVipDesc(self.data.currShowVipLevel)
        end
    end
    self.controls.left_btn = createMixSprite("image/ui/img/btn/btn_875.png") 
    self.controls.left_btn:setName("left")
    local btnBg = self.controls.left_btn:getBg()
    btnBg:setScaleX(-1)
    self.controls.left_btn:setPosition(bgSize.width * 0.34, bgSize.height * 0.4)
    self.controls.vipNode:addChild(self.controls.left_btn)
    self.controls.left_btn:addTouchEventListener(moveTouchEvent)
    self.controls.right_btn = createMixSprite("image/ui/img/btn/btn_875.png")
    self.controls.right_btn:setName("right")
    self.controls.right_btn:setPosition(bgSize.width * 0.92, bgSize.height * 0.4)
    self.controls.vipNode:addChild(self.controls.right_btn)
    self.controls.right_btn:addTouchEventListener(moveTouchEvent)
    if self.data.currShowVipLevel <= 1 then
        self.controls.left_btn:setVisible(false)
    end
    if self.data.currShowVipLevel >= vipTotal then
        self.controls.right_btn:setVisible(false)
    end
    local move1 = cc.MoveBy:create(1, cc.p(-5, 0))
    local move1_reverse = move1:reverse()
    local move2 = cc.MoveBy:create(1, cc.p(5, 0))
    local move2_reverse = move2:reverse()
    self.controls.left_btn:runAction(cc.RepeatForever:create(cc.Sequence:create(move1, move1_reverse)))
    self.controls.right_btn:runAction(cc.RepeatForever:create(cc.Sequence:create(move2, move2_reverse)))
end

function Recharge:createVipBtnView(viewSize)
    local btnHeight = 70 
    local function cellSizeForTable(table,idx) 
        return btnHeight * vipTotal,viewSize.width
    end
    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()

        local function getLayer()
            local layerColor = cc.LayerColor:create(cc.c4b(255,255,0,0), viewSize.width, btnHeight * vipTotal)
            layerColor:setTag(LAYERCOLORTAG)

            for i=1,vipTotal do
                local vipBtn = createMixSprite("image/ui/img/bg/bg_201.png", "image/ui/img/bg/bg_200.png", "image/ui/img/btn/btn_856.png")
                vipBtn:setButtonBounce(false)
                vipBtn:setChildPos(0.35, 0.5)
                vipBtn:setPosition(viewSize.width * 0.5, btnHeight * vipTotal - btnHeight * 0.5 - (i - 1) * btnHeight)
                layerColor:addChild(vipBtn)
                vipBtn:addTouchEventListener(function(sender, eventType)
                    if (eventType == ccui.TouchEventType.ended) and (not table:isTouchMoved()) then
                        self.data.currShowVipLevel = i
                        self.controls.vipDescView:scrollToPage(self.data.currShowVipLevel - 1)
                        self:updateVipDesc(self.data.currShowVipLevel)
                    end
                end)
                self.data.vipBtnTab[i] = vipBtn

                local vipLevel = cc.Label:createWithCharMap("image/ui/img/btn/btn_627.png", 44, 52,  string.byte("0"))
                vipLevel:setAdditionalKerning(-6)
                vipLevel:setPosition(20, 0)
                vipBtn:addChild(vipLevel)
                vipLevel:setString(i)
                vipLevel:setScale(0.4)
            end

            return layerColor
        end

        if nil == cell then
            cell = cc.TableViewCell:new()
            cell:addChild(getLayer())
        end

        return cell
    end
    local function numberOfCellsInTableView(table)
       return 1
    end
    local tableView = cc.TableView:create(viewSize)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:reloadData()
    return tableView      
end

function Recharge:createDescView(ccSize)
    local pageView = ccui.PageView:create()
    pageView:setTouchEnabled(true)
    pageView:setSize(ccSize)

    local function pageViewEvent(sender, eventType)
        if eventType == ccui.PageViewEventType.turning then
            local pageIdx = sender:getCurPageIndex()
            self.data.currShowVipLevel = pageIdx + 1
            self:updateVipDesc(self.data.currShowVipLevel)
        end
    end 

    for i = 1, vipTotal do
        local layout = ccui.Layout:create()
        layout:setSize(ccSize)
        local imageView = ccui.ImageView:create()
        imageView:setScale9Enabled(true)
        imageView:loadTexture("image/ui/img/btn/btn_438.png")
        imageView:setSize(ccSize)
        imageView:setPosition(ccSize.width * 0.5, ccSize.height * 0.4)
        layout:addChild(imageView)
        imageView:setOpacity(0)
        pageView:addPage(layout)
    end
    pageView:addEventListenerPageView(pageViewEvent)
    return pageView
end

function Recharge:updateVipDesc(vipLevel)
    self.controls.left_btn:setVisible(true)
    self.controls.right_btn:setVisible(true)
    if vipLevel <= 1 then
        self.controls.left_btn:setVisible(false)
    end
    if vipLevel >= vipTotal then
        self.controls.right_btn:setVisible(false)
    end
    for k,v in pairs(self.data.vipBtnTab) do
        if k == vipLevel then
            v:setTouchStatus()
        else
            v:setNormalStatus()
        end
    end

    if not self.data.initPosY then
        self.data.initPosY = self.controls.btnView:getContentOffset().y
    end
    if vipLevel > 10 then
        self.controls.btnView:setContentOffset(cc.p(0, 0), true)
    else
        self.controls.btnView:setContentOffset(cc.p(0, self.data.initPosY + (vipLevel - 1) * 70), true)
    end

    local function getVipDesc(pageLayout, idx)
        local pageSize = self.controls.vipDescView:getContentSize()
        if not pageLayout.isHaveDesc then
            local level = idx + 1
            pageLayout.isHaveDesc = true

            local privilegeConfig = BaseConfig.getVipPrivilege(level)

            local listSize = cc.size(pageSize.width * 0.9, 280)
            local listView = ccui.ListView:create()
            listView:setDirection(ccui.ScrollViewDir.vertical)
            listView:setBounceEnabled(true)
            listView:setContentSize(listSize)
            listView:setPosition(pageSize.width * 0.5 - listSize.width * 0.5, -5)
            pageLayout:addChild(listView)
            listView:setBounceEnabled(false)

            if level > 1 then
                local layout = ccui.Layout:create()
                layout:setTouchEnabled(false)
                layout:setContentSize(cc.size(listSize.width, 30))
                local descList = ColorLabel.new("[255,255,255]包含[=][255,246,0]VIP"..(level - 1).."[=][255,255,255]所有特权[=]", 20)
                descList:setPosition(listSize.width* 0.5, 15)
                layout:addChild(descList)
                listView:pushBackCustomItem(layout)
            end

            for k,v in pairs(privilegeConfig.Desc) do
                local layout = ccui.Layout:create()
                layout:setTouchEnabled(false)
                layout:setContentSize(cc.size(listSize.width, 30))
                local descList = ColorLabel.new("", 20)
                descList:setPosition(listSize.width* 0.5, 15)
                layout:addChild(descList)
                listView:pushBackCustomItem(layout)
                local descConfig = BaseConfig.getVipDesc(v)
                if "" == descConfig.Suffix then
                    descList:setString("[255,255,255]"..descConfig.Prefix.."[=]")
                else
                    local descValue = privilegeConfig.DescValue[k]
                    if v == 10 then
                        descValue = descValue.."%"
                    end
                    descList:setString("[255,255,255]"..descConfig.Prefix.."[=][255,246,0]"..descValue.."[=][255,255,255]"..descConfig.Suffix.."[=]")
                end
            end
        end
    end
    local currPageIdx = vipLevel - 1
    local currPageLayout = self.controls.vipDescView:getPage(currPageIdx)
    getVipDesc(currPageLayout, currPageIdx)

    local firstIdx = 0
    local lastIdx = vipTotal - 1
    if currPageIdx ~= firstIdx then
        local idx = currPageIdx - 1
        local beforePageLayout = self.controls.vipDescView:getPage(idx)
        getVipDesc(beforePageLayout, idx)
    end
    if currPageIdx ~= lastIdx then
        local idx = currPageIdx + 1
        local afterPageLayout = self.controls.vipDescView:getPage(idx)
        getVipDesc(afterPageLayout, idx)
    end

    self.controls.currVipSpecial:setString(vipLevel)
    local vipPrice = BaseConfig.getVipExp(vipLevel)
    for i=1,vipTotal do
        if i < vipLevel then
            local beforeVipPrice = BaseConfig.getVipExp(i)
            vipPrice = vipPrice + beforeVipPrice
        end
    end
    self.controls.VipSpecialDesc:setString("[255,255,255]累计充值[=][255,246,0]"..vipPrice.."[=][255,255,255]元宝即可享受该级特权[=]")
end

function Recharge:presentAction(sprite)
    local initScale = sprite:getScale()
    local scale1 = cc.ScaleTo:create(0.4, initScale * 1.2)
    local scale2 = cc.ScaleTo:create(0.2, initScale * 1.08)
    local scale3 = cc.ScaleTo:create(0.1, initScale * 1.2)
    local scale4 = cc.ScaleTo:create(0.2, initScale * 1.12)
    local scale5 = cc.ScaleTo:create(0.15, initScale * 1.16)
    local scale6 = cc.ScaleTo:create(0.15, initScale * 1.16)
    local scale7 = cc.ScaleTo:create(0.5, initScale)
    local delay = cc.DelayTime:create(3)
    local seq = cc.Sequence:create(delay, scale1, scale2, scale3, scale4, scale3:clone(), scale5, scale3:clone(), scale6, scale3:clone(), scale7)
    local rep = cc.RepeatForever:create(seq)
    sprite:runAction(rep)
end

--[[
    查询任务
]]
function Recharge:QueryTaskStatus(task_id)
    rpc:call("Task.QueryTaskStatus", {ID = task_id}, function(event)
        if event.status == Exceptions.Nil then
            local taskInfo = event.result
            for k,v in pairs(self.data.taskInfoTabs) do
				if v.ID == taskInfo.ID then
					self.data.taskInfoTabs[k] = taskInfo
					break
				end
			end
			self:updateTask()
        end
    end)
end

return Recharge