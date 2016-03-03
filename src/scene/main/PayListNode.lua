
local PayListNode = class("PayListNode", function()
    local self = cc.Node:create()
    self:registerScriptHandler(function ( event )
        if event == "cleanup" then
            self:onCleanup()
        end
    end)
    return self
end)

local commonLayer = require("tool.helper.CommonLayer")


function PayListNode:ctor(currPower, maxPower, currEndurance, maxEndurance, currCoin, currGold)

    self.data = {}
    self.controls = {}
    self.handlers = {}
    self.controls.itemTabs = {}

    self.listener = application:addEventListener(AppEvent.UI.Pay.UpdatePayNode, function ( event )
        self:updateData(event.data)
    end)

    local function onClickBtn(sender, eventType)
        local tag = sender:getTag()
        if eventType == ccui.TouchEventType.ended then

            if tag == 1 then
                commonLayer.PowerLayer()

            elseif tag == 2 then
                commonLayer.EnduranceLayer()

            elseif tag == 3 then

                require("scene.main.CoinTreeLayer").new()

            elseif tag == 4 then        -- VIP充值
                application:pushScene("main.recharge.RechargeScene") 

            end

        end
    end


    local function twoBeforeLayout(x, y, i, icontexture, barBG_texture, bar_texture)
        local size = cc.size(180,40)

        local bg = ccui.MixButton:create("image/ui/img/bg/bg_01.png")
        bg:setScale9Enabled(true)
        bg:setContentSize(size)
        bg:setPosition(x,y)
        self:addChild(bg)
        bg:setTag(i)
        bg:addTouchEventListener(onClickBtn)

        local btn = cc.Sprite:create("image/ui/img/bg/add.png")
        btn:setPosition(size.width - btn:getContentSize().width * 0.5, btn:getContentSize().height * 0.5 - 5)
        bg:addChild(btn)

        local icon = cc.Sprite:create(icontexture)
        icon:setAnchorPoint(0,0.5)
        icon:setPosition(10,size.height*0.5)
        bg:addChild(icon)

        local barbgsize = cc.size(94,22)
        local bar_bg = ccui.ImageView:create(barBG_texture)
        bar_bg:setScale9Enabled(true)
        bar_bg:setContentSize(barbgsize)
        bar_bg:setPosition(size.width * 0.5-5, size.height * 0.5)
        bg:addChild(bar_bg)

        local barsize = cc.size(90,19)
        local bar = ccui.ImageView:create(bar_texture)
        bar:setScale9Enabled(true)
        bar:setContentSize(barsize)
        bar:setAnchorPoint(0, 0.5)
        bar:setPosition(2, barbgsize.height * 0.5)
        bar_bg:addChild(bar)

        local value = Common.finalFont("", 1, 1, 18, nil, 1)
        value:setPosition(barbgsize.width * 0.5, barbgsize.height * 0.5)
        value:setAdditionalKerning(-1)
        bar_bg:addChild(value)

        return bar, value
    end

    local function twoAfterLayout(x,y, i, price_texture)
        local size = cc.size(180,40)
        local bg = ccui.MixButton:create("image/ui/img/bg/bg_01.png")
        bg:setScale9Enabled(true)
        bg:setContentSize(size)
        bg:setPosition(x,y)
        self:addChild(bg)
        bg:setTag(i)
        bg:addTouchEventListener(onClickBtn)
        
        local btn = cc.Sprite:create("image/ui/img/bg/add.png")
        btn:setPosition(size.width - btn:getContentSize().width * 0.5, btn:getContentSize().height * 0.5 - 5)
        bg:addChild(btn)
        -- btn:addTouchEventListener(onClickBtn)

        local price_icon = cc.Sprite:create(price_texture)
        price_icon:setPosition(price_icon:getContentSize().width * 0.5+5, size.height * 0.5)
        bg:addChild(price_icon)

        local value = Common.finalFont("", 1, 1, 18,nil,1)
        value:setPosition(size.width * 0.5-10, size.height * 0.5)
        value:setAdditionalKerning(-1)
        bg:addChild(value)

        return value
    end

    local function powerUI()
        if SCREEN_WIDTH > 960 then          
            self.controls.barPower, self.controls.valuePower = twoBeforeLayout(SCREEN_WIDTH*0.08,20,1,"image/ui/img/bg/tili.png",
                "image/ui/img/bg/bg_02.png", "image/ui/img/bg/line_01.png")
        else
            self.controls.barPower, self.controls.valuePower = twoBeforeLayout(SCREEN_WIDTH*0.08,20,1,"image/ui/img/bg/tili.png",
                "image/ui/img/bg/bg_02.png", "image/ui/img/bg/line_01.png")
        end
        self:setPower(currPower, maxPower)
    end
    local function enduranceUI()
        if SCREEN_WIDTH > 960 then
            self.controls.barEndurance, self.controls.valueEndurance = twoBeforeLayout(SCREEN_WIDTH*0.25,20,2, "image/ui/img/bg/naili.png",
                "image/ui/img/bg/bg_02.png", "image/ui/img/bg/line_02.png")
        else
            self.controls.barEndurance, self.controls.valueEndurance = twoBeforeLayout(SCREEN_WIDTH*0.27,20,2, "image/ui/img/bg/naili.png",
                "image/ui/img/bg/bg_02.png", "image/ui/img/bg/line_02.png")
        end
        self:setEndurance(currEndurance, maxEndurance)
    end
    local function coinUI()
        if SCREEN_WIDTH > 960 then
            self.controls.valueCoin = twoAfterLayout(SCREEN_WIDTH*0.42,20,3, "image/ui/img/btn/btn_035.png")
        else
            self.controls.valueCoin = twoAfterLayout(SCREEN_WIDTH*0.46,20,3, "image/ui/img/btn/btn_035.png")
        end
        self:setCoin(currCoin)
    end
    local function goldUI()
        if SCREEN_WIDTH > 960 then
            self.controls.valueGold = twoAfterLayout(SCREEN_WIDTH*0.59,20,4, "image/ui/img/btn/btn_060.png")
        else
            self.controls.valueGold = twoAfterLayout(SCREEN_WIDTH*0.65,20,4, "image/ui/img/btn/btn_060.png")
        end
        self:setGold(currGold)
    end
    powerUI()
    enduranceUI()
    coinUI()
    goldUI()
end


function PayListNode:setPower(currPower, maxPower)
    local value = nil
    if currPower > maxPower then
        value = 1
    else
        value = currPower / maxPower
    end
    self.controls.valuePower:setString(currPower.."/"..maxPower)
    self.controls.valuePower:playChangeAction()
    self.controls.barPower:setScale(value, 1)
end

function PayListNode:setEndurance(currEndurance, maxEndurance)
    local value = nil
    if currEndurance > maxEndurance then
        value = 1
    else
        value = currEndurance / maxEndurance 
    end
    self.controls.valueEndurance:setString(currEndurance.."/"..maxEndurance)
    self.controls.valueEndurance:playChangeAction()
    self.controls.barEndurance:setScale(value, 1)
end

function PayListNode:setCoin(currCoin)
    local str = currCoin ..""
    if currCoin < 100000 then

    elseif currCoin < 1000000000 then
        local coin = math.floor(currCoin/10000)
        str = coin .. "万"
    else
        local coin = math.floor(currCoin/100000000)
        str = coin .. "亿"
    end

    self.controls.valueCoin:setString(str)

    self.controls.valueCoin:playChangeAction()
end

function PayListNode:setGold(currGold)
    self.controls.valueGold:setString(currGold)
    self.controls.valueGold:playChangeAction()
end

function PayListNode:getContentSize()
    local size = {width = 800, height = 46}
    return size
end

function PayListNode:onCleanup()
    application:removeEventListener(self.listener)
end

function PayListNode:updateData(data)
    -- dump(data)

    if data == "PhyPower" or data == "MaxPhyPower" then
        local currPower = GameCache.Avatar.PhyPower
        local maxPower = GameCache.Avatar.MaxPhyPower       
        self:setPower(currPower, maxPower)
    end
  
    if data == "Endurance" or data == "MaxEndurance" then
        local currEndurance = GameCache.Avatar.Endurance
        local maxEndurance = GameCache.Avatar.MaxEndurance
        self:setEndurance(currEndurance, maxEndurance)
    end

    if data == "Coin" then
        local currCoin = GameCache.Avatar.Coin 
        self:setCoin(currCoin)
    end
    
    if data == "Gold" then
        local currGold = GameCache.Avatar.Gold
        self:setGold(currGold)
    end

end



return PayListNode
