local PackageLayer = class("PackageLayer", BaseLayer)

local scheduler = cc.Director:getInstance():getScheduler()
local ColorLabel = require("tool.helper.ColorLabel")

local EQUIP_VIEW, FRAG_VIEW, PROP_VIEW = 1, 2, 3 -- 1-装备,2-碎片,3-道具
local POWERTYPE = 11
local ENDURANCETYPE = 12
--[[
    层次关系：从上往下
    显示层
    屏蔽layer层
    tableview层
    bg层
]]--
local bgZOrder = 2
local SCROLLVIEW_ZOrder = bgZOrder + 1
local LAYER_ZOrder = SCROLLVIEW_ZOrder + 1
local TOP_ZOrder = LAYER_ZOrder + 1

-- 道具枚举定义
local PT_EquipFrag = 1 -- 装备碎片
local PT_TreasureFrag = 2 -- 宝物碎片
local PT_OmnipotentHeroFrag = 3 -- 万能星将碎片
local PT_OmnipotentEquipFrag = 4 -- 万能装备碎片
local PT_UpgradeStarPill = 5 -- 升星丹
local PT_EquipUpgradePill = 6 -- 装备锻造石
local PT_EquipUpgradeMaterial = 7 -- 玄晶
local PT_UpgradePill = 8 -- 经验丹
local PT_FairyGift = 9 -- 仙女礼物
local PT_SkillPoint = 10 -- 技能点
local PT_PowerPill = 11 -- 体力丹
local PT_EndurancePill = 12 -- 耐力丹
local PT_Sundries = 13 -- 杂物
local PT_LootTools = 14 -- 偷袭令
local PT_LootProtect = 15 -- 免战牌

function PackageLayer:ctor()
    PackageLayer.super.ctor(self)
    self.data.touchChange = {}
    self.data.currView = PROP_VIEW
    self.data.tabSize = cc.size(560, 435)
    self.data.tabPos = {345, 28}
    self.data.chooseGoodsInfo = {} -- 被选中的物品信息
    self.data.isOpenStep = false
    self.data.stepNum = 0
    self.data.isFirstJoin = true -- 初次进入装备View不能及时刷新，否则不会出现打开效果
    self:createUI()

    self.controls.propView = require("scene.main.package.widget.GoodsView").new(self.data.currView, self.data.tabSize,
                                                                            self.data.tabPos[1], self.data.tabPos[2], handler(self, self.updateShowData))
                    self.controls.propView:setTag(PROP_VIEW)
                    self.controls.bg:addChild(self.controls.propView, SCROLLVIEW_ZOrder)

    self.scheduler_updateStep = scheduler:scheduleScriptFunc(handler(self, self.updateStep), 0.1, false)
    self.data.FragListener = application:addEventListener(AppEvent.UI.Package.isFragCompound, function(event)
        local isShowAlert = false
        local allFrag = GameCache.GetAllFrag()
        for k,v in pairs(allFrag) do
            if (Common.isFragCompound(v)) then
                isShowAlert = true
                break
            end
        end
        self.controls.btn_frag:setChildTextureVisible(isShowAlert)
    end)
end

function PackageLayer:createUI()
    local bg = cc.Sprite:create("image/ui/img/bg/bg_037.jpg")
    bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    self:addChild(bg)
    
    self.controls.bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_111.png") 
    self.controls.bg:setContentSize(cc.size(925, 560))
    self.controls.bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.48)
    self:addChild(self.controls.bg)
    self.data.bgSize = self.controls.bg:getContentSize()

    local fringe = cc.Scale9Sprite:create("image/ui/img/bg/bg_112.png")
    fringe:setContentSize(self.data.bgSize)
    fringe:setAnchorPoint(0.5, 1)
    fringe:setPosition(self.data.bgSize.width * 0.5, self.data.bgSize.height)
    self.controls.bg:addChild(fringe, bgZOrder)

    local leftPanel = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png") 
    leftPanel:setContentSize(cc.size(320, 478))
    leftPanel:setPosition(self.data.bgSize.width * 0.19, self.data.bgSize.height * 0.44)
    self.controls.bg:addChild(leftPanel, bgZOrder)

    local rightPanel = cc.Scale9Sprite:create("image/ui/img/bg/bg_141.png") 
    rightPanel:setContentSize(cc.size(595, 484))
    rightPanel:setPosition(self.data.bgSize.width * 0.675, self.data.bgSize.height * 0.44)
    self.controls.bg:addChild(rightPanel, bgZOrder)

    local clickLayer = Common.createClickLayer(self.data.tabSize.width, self.data.tabSize.height, self.data.tabPos[1], self.data.tabPos[2])
    self.controls.bg:addChild(clickLayer, LAYER_ZOrder)

    local currPageName = createMixSprite("image/ui/img/bg/bg_142.png", "image/ui/img/bg/bg_142.png", "image/ui/img/btn/btn_493.png")
    currPageName:setTouchEnable(false)
    currPageName:setChildPos(0.52, 0.55)
    currPageName:setPosition(self.data.bgSize.width * 0.1, self.data.bgSize.height)
    self.controls.bg:addChild(currPageName, bgZOrder)

    local btn_close = createMixSprite("image/ui/img/btn/btn_598.png")
    btn_close:setPosition(self.data.bgSize.width * 0.98, self.data.bgSize.height * 0.98)
    btn_close:setZOrder(TOP_ZOrder)
    self.controls.bg:addChild(btn_close)
    btn_close:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            cc.Director:getInstance():popScene()
        end
    end)

    self.controls.tabBtns = {}
    function btnTouchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local name = sender:getName()
            for k,v in pairs(self.controls.tabBtns) do
                if name == v:getName() then
                    v:setTouchStatus()
                    v:setFontColor(cc.c3b(253, 230, 154))
                    v:setFontOutline(cc.c4b(46, 46, 46, 255), 1)
                else
                    v:setNormalStatus()
                    v:setFontColor(cc.c3b(177, 174, 170))
                    v:setFontOutline(cc.c4b(52, 58, 82, 255), 1)
                end
            end
            if name ==  "equip" then
                self.data.currView = EQUIP_VIEW
                if self.controls.fragView then
                    self.controls.fragView:runAction(cc.Sequence:create(cc.Hide:create()))
                    self.controls.fragView:setScale(0.01)
                end
                if self.controls.propView then
                    self.controls.propView:runAction(cc.Sequence:create(cc.Hide:create()))
                    self.controls.propView:setScale(0.01)
                end
                if self.controls.equipView then
                    self.controls.equipView:runAction(cc.Sequence:create(cc.Show:create()))
                    self.controls.equipView:setScale(1)
                    self.controls.equipView:updateView()
                else
                    self.controls.equipView = require("scene.main.package.widget.GoodsView").new(self.data.currView, self.data.tabSize,
                                                                            self.data.tabPos[1], self.data.tabPos[2], handler(self, self.updateShowData))
                    self.controls.equipView:setTag(EQUIP_VIEW)
                    self.controls.bg:addChild(self.controls.equipView, SCROLLVIEW_ZOrder)
                end
            elseif name ==  "frag" then
                self.data.currView = FRAG_VIEW
                if self.controls.equipView then
                    self.controls.equipView:runAction(cc.Sequence:create(cc.Hide:create()))
                    self.controls.equipView:setScale(0.01)
                end
                if self.controls.propView then
                    self.controls.propView:runAction(cc.Sequence:create(cc.Hide:create()))
                    self.controls.propView:setScale(0.01)
                end
                if self.controls.fragView then
                    self.controls.fragView:runAction(cc.Sequence:create(cc.Show:create()))
                    self.controls.fragView:setScale(1)
                    self.controls.fragView:updateView()
                else
                    self.controls.fragView = require("scene.main.package.widget.GoodsView").new(self.data.currView, self.data.tabSize,
                                                                            self.data.tabPos[1], self.data.tabPos[2], handler(self, self.updateShowData))
                    self.controls.fragView:setTag(FRAG_VIEW)
                    self.controls.bg:addChild(self.controls.fragView, SCROLLVIEW_ZOrder)
                end
            elseif name == "prop" then
                self.data.currView = PROP_VIEW
                if self.controls.fragView then
                    self.controls.fragView:runAction(cc.Sequence:create(cc.Hide:create()))
                    self.controls.fragView:setScale(0.01)
                end
                if self.controls.equipView then
                    self.controls.equipView:runAction(cc.Sequence:create(cc.Hide:create()))
                    self.controls.equipView:setScale(0.01)
                end
                if self.controls.propView then
                    self.controls.propView:runAction(cc.Sequence:create(cc.Show:create()))
                    self.controls.propView:setScale(1)
                    self.controls.propView:updateView()
                end
            end
        end
    end

    local size = self.controls.bg:getContentSize()
    local btn_equip = createMixSprite("image/ui/img/btn/btn_600.png", "image/ui/img/btn/btn_599.png")
    btn_equip:setAnchorPoint(0.5, 0)
    btn_equip:setBgTouchAnchorPoint(0.5, 0)
    btn_equip:setCircleFont("装备" , 1, 1, 30, cc.c3b(177, 174, 170))
    btn_equip:setFontOutline(cc.c4b(52, 58, 82, 255), 1)
    btn_equip:setFontPos(0.5, 0.8)
    btn_equip:setPosition(size.width * 0.85, size.height * 0.852)
    btn_equip:setName("equip")
    btn_equip:addTouchEventListener(btnTouchEvent)
    self.controls.bg:addChild(btn_equip,TOP_ZOrder)
    table.insert(self.controls.tabBtns , btn_equip)

    self.controls.btn_frag = createMixSprite("image/ui/img/btn/btn_600.png", "image/ui/img/btn/btn_599.png", "image/ui/img/btn/btn_398.png")
    self.controls.btn_frag:setChildPos(0.9, 1.2)
    self.controls.btn_frag:setAnchorPoint(0.5, 0)
    self.controls.btn_frag:setBgTouchAnchorPoint(0.5, 0)
    self.controls.btn_frag:setCircleFont("碎片" , 1, 1, 30, cc.c3b(177, 174, 170))
    self.controls.btn_frag:setFontOutline(cc.c4b(52, 58, 82, 255), 1)
    self.controls.btn_frag:setFontPos(0.5, 0.8)
    self.controls.btn_frag:setPosition(size.width * 0.67, size.height * 0.852)
    self.controls.btn_frag:setName("frag")
    self.controls.btn_frag:addTouchEventListener(btnTouchEvent)
    self.controls.bg:addChild(self.controls.btn_frag, TOP_ZOrder)
    table.insert(self.controls.tabBtns , self.controls.btn_frag)
    self.controls.btn_frag:setChildTextureVisible(false)

    local btn_prop = createMixSprite("image/ui/img/btn/btn_600.png", "image/ui/img/btn/btn_599.png")
    btn_prop:setTouchStatus()
    btn_prop:setAnchorPoint(0.5, 0)
    btn_prop:setBgTouchAnchorPoint(0.5, 0)
    btn_prop:setCircleFont("道具" , 1, 1, 30, cc.c3b(253, 230, 154))
    btn_prop:setFontOutline(cc.c4b(46, 46, 46, 255), 1)
    btn_prop:setPosition(size.width * 0.49, size.height * 0.852)
    btn_prop:setFontPos(0.5, 0.8)
    btn_prop:setName("prop")
    btn_prop:addTouchEventListener(btnTouchEvent)
    self.controls.bg:addChild(btn_prop, TOP_ZOrder)
    table.insert(self.controls.tabBtns , btn_prop)

    self.controls.goodsGetWay = createMixSprite("image/ui/img/btn/btn_1172.png")
    self.controls.goodsGetWay:setPosition(self.data.bgSize.width * 0.08, self.data.bgSize.height * 0.75)
    self.controls.bg:addChild(self.controls.goodsGetWay, TOP_ZOrder)

    local bigGoodsBg = cc.Sprite:create("image/ui/img/btn/btn_601.png")
    bigGoodsBg:setPosition(self.data.bgSize.width * 0.19, self.data.bgSize.height * 0.65)
    self.controls.bg:addChild(bigGoodsBg, bgZOrder)

    self.controls.goodsBG = cc.Sprite:create("image/ui/img/btn/btn_412.png")
    self.controls.goodsBG:setPosition(self.data.bgSize.width * 0.19, self.data.bgSize.height * 0.68)
    self.controls.bg:addChild(self.controls.goodsBG, bgZOrder)

    self.controls.goodsName = Common.finalFont("", self.controls.goodsBG:getPositionX(), self.data.bgSize.height * 0.55, 22, cc.c3b(230, 191, 124))
    self.controls.bg:addChild(self.controls.goodsName, bgZOrder)
    
    self.controls.desc = Common.finalFont("", 1, 1, 20, cc.c3b(247, 241, 230))
    self.controls.desc:setAnchorPoint(0.5, 1)
    self.controls.desc:setPosition(self.data.bgSize.width * 0.19, self.data.bgSize.height * 0.5)
    self.controls.bg:addChild(self.controls.desc, bgZOrder)

    local btnBG = cc.Scale9Sprite:create("image/ui/img/bg/bg_253.png")
    btnBG:setContentSize(cc.size(300, 90))
    btnBG:setPosition(self.data.bgSize.width * 0.19, self.data.bgSize.height * 0.12)
    self.controls.bg:addChild(btnBG, bgZOrder)

    self.controls.price_tishi = Common.finalFont("出售单价:", self.data.bgSize.width * 0.1, self.data.bgSize.height * 0.26, 20, cc.c3b(230, 191, 124))
    self.controls.bg:addChild(self.controls.price_tishi, bgZOrder)

    self.controls.priceBg = cc.Sprite:create("image/ui/img/btn/btn_602.png")
    self.controls.priceBg:setPosition(self.data.bgSize.width * 0.25, self.data.bgSize.height * 0.26)
    self.controls.bg:addChild(self.controls.priceBg, bgZOrder)
    self.controls.priceSpri = cc.Sprite:create("image/ui/img/btn/btn_035.png")
    self.controls.priceSpri:setPosition(self.data.bgSize.width * 0.21, self.data.bgSize.height * 0.258)
    self.controls.bg:addChild(self.controls.priceSpri, bgZOrder)

    self.controls.goodsPrice = Common.finalFont("0", 1, 1, 20, cc.c3b(230, 191, 124))
    self.controls.goodsPrice:setPosition(self.data.bgSize.width * 0.28, self.data.bgSize.height * 0.258)
    self.controls.bg:addChild(self.controls.goodsPrice, bgZOrder)

    self.controls.specialDesc = Common.finalFont("", 1, 1, 20, cc.c3b(247, 241, 230))
    self.controls.specialDesc:setAnchorPoint(0.5, 1)
    self.controls.specialDesc:setPosition(self.data.bgSize.width * 0.19, self.data.bgSize.height * 0.4)
    self.controls.specialDesc:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    self.controls.bg:addChild(self.controls.specialDesc, bgZOrder)

    self.controls.talent = ColorLabel.new("", 20)
    self.controls.talent:setAnchorPoint(0.5, 1)
    self.controls.bg:addChild(self.controls.talent, bgZOrder)

    self.controls.attribute = ColorLabel.new("", 20)
    self.controls.attribute:setAnchorPoint(0.5, 1)
    self.controls.bg:addChild(self.controls.attribute, bgZOrder)

    self.controls.extraDesc = ColorLabel.new("", 20)
    self.controls.extraDesc:setAnchorPoint(0.5, 1)
    self.controls.bg:addChild(self.controls.extraDesc, bgZOrder)

    local function onBtnTouchEvent(sender, eventType, isInButton)
        local name = sender:getName()
        local beganFunc = nil
        local moveFunc = nil
        local endedFunc = nil
        local saleFunc = nil
        if self.data.currView == EQUIP_VIEW then
            beganFunc = function()
                
            end
            endedFunc = function()
                application:pushScene("main.equipRecycle.EquipRecycleScene")
            end
        elseif self.data.currView  == FRAG_VIEW then
            beganFunc = function()
            end

            endedFunc = function()
                if self.data.chooseGoodsInfo.data.goodsConfigInfo.type == 1 then
                    local view = self.controls.bg:getChildByTag(self.data.currView)
                    local frag = require("scene.main.package.widget.FragCompound").new(self.data.chooseGoodsInfo, view)
                    local size = self.controls.bg:getContentSize()
                    self:addChild(frag, TOP_ZOrder)
                end
            end
        elseif self.data.currView == PROP_VIEW then
            beganFunc = function()
            end

            endedFunc = function()
                self:UseProps(self.data.chooseGoodsInfo.data.goodsConfigInfo.id)
            end
        end

        if self.data.currView  == EQUIP_VIEW then
            saleFunc = function()
                -- 分解
                local view = self.controls.bg:getChildByTag(self.data.currView)
                local frag = require("scene.main.package.widget.EquipDecompose").new(self.data.chooseGoodsInfo, view)
                local size = self.controls.bg:getContentSize()
                self:addChild(frag, TOP_ZOrder)
            end
        elseif (self.data.currView  == FRAG_VIEW) or (self.data.currView == PROP_VIEW) then
            saleFunc = function()
                local view = self.controls.bg:getChildByTag(self.data.currView)
                local dialog = require("scene.main.package.widget.SaleDialog").new(self.data.currGoods, self.data.chooseGoodsInfo, self.data.currView, view)
                local size = self.controls.bg:getContentSize()
                self:addChild(dialog, TOP_ZOrder)
            end
        end

        if eventType == ccui.TouchEventType.began then
            if name == "use" then
                beganFunc()
            end
            
        end
        if eventType == ccui.TouchEventType.moved then
            if name == "use" then
                if moveFunc and (not isInButton) then
                    moveFunc()
                end
            end
        end
        if (eventType == ccui.TouchEventType.ended) and isInButton then
            if name == "use" then
                endedFunc()
            elseif name == "sale" then
                saleFunc()
            end
        end
        
    end

    self.controls.use = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(120, 62))
    self.controls.use:setCircleFont("使用", 1, 1, 25, cc.c3b(226, 204, 169), 1)
    self.controls.use:setFontOutline(cc.c4b(65, 26, 1, 255), 1)
    self.controls.use:setPosition(self.data.bgSize.width * 0.115, self.data.bgSize.height * 0.12)
    self.controls.use:setName("use")
    self.controls.use:addTouchEventListener(onBtnTouchEvent)
    self.controls.bg:addChild(self.controls.use, TOP_ZOrder)
    self.controls.use:setButtonBounce(false)

    self.controls.sale = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(120, 62))
    self.controls.sale:setCircleFont("出售", 1, 1, 25, cc.c3b(226, 204, 169), 1)
    self.controls.sale:setFontOutline(cc.c4b(65, 26, 1, 255), 1)
    self.controls.sale:setPosition(self.data.bgSize.width * 0.27, self.data.bgSize.height * 0.12)
    self.controls.sale:setName("sale")
    self.controls.sale:addTouchEventListener(onBtnTouchEvent)
    self.controls.bg:addChild(self.controls.sale, TOP_ZOrder)
    self.controls.sale:setButtonBounce(false)
end

function PackageLayer:updateShowData(sender)
    -- 因为view复用cell原因，self.data.chooseGoodsInfo中的item和info都会随view移动而改变
    -- self.data.currGoods记录下当前点击这个goods的信息，主要用来验证和self.data.chooseGoodsInfo是否相同
    if not sender then
        self.controls.goodsGetWay:setScale(0)
        self.controls.goodsName:setString("")
        self.controls.desc:setString("")
        self.controls.priceBg:setVisible(false)
        self.controls.price_tishi:setVisible(false)
        self.controls.priceSpri:setVisible(false)
        self.controls.goodsPrice:setVisible(false)
        self.controls.use:setScale(0)
        self.controls.sale:setScale(0)
        self.controls.goodsBG:setScale(0)
        if self.controls.goodsInfoBG then
            self.controls.goodsInfoBG:setScale(0)
        end
        self:isShowEquipAttribute(false)
        return 
    end

    self.data.chooseGoodsInfo = sender 
    self.data.currGoods = {}
    self.data.currGoods = sender.data.goodsInfo
    self.data.currGoods.price = sender.data.goodsConfigInfo.price

    self.controls.goodsName:setString(sender.data.goodsConfigInfo.name)
    local row1, desc1 = Common.StringLinefeed(sender.data.goodsConfigInfo.desc, 14)
    self.controls.desc:setString(desc1)
    if sender.data.goodsConfigInfo.price then
        self.controls.priceBg:setVisible(true)
        self.controls.price_tishi:setVisible(true)
        self.controls.priceSpri:setVisible(true)
        self.controls.goodsPrice:setVisible(true)
        self.controls.goodsPrice:setString(sender.data.goodsConfigInfo.price)
    else
        self.controls.priceBg:setVisible(false)
        self.controls.price_tishi:setVisible(false)
        self.controls.priceSpri:setVisible(false)
        self.controls.goodsPrice:setVisible(false)
    end

    self.controls.use:setScale(1)
    self.controls.use:setPosition(self.data.bgSize.width * 0.115, self.data.bgSize.height * 0.12)
    self.controls.sale:setScale(1)
    self.controls.sale:setPosition(self.data.bgSize.width * 0.27, self.data.bgSize.height * 0.12)
    self.controls.goodsBG:setScale(0)
    if self.controls.goodsInfoBG then
        self.controls.goodsInfoBG:setScale(1)
    end
    self:updateShowGoodsHead(sender.data.goodsType, sender.data.goodsInfo)
    self.controls.goodsGetWay:setScale(1)
    self.controls.goodsGetWay:addTouchEventListener(function(sender, eventType, inside)
        if (eventType == ccui.TouchEventType.ended) and inside then
            local goodsType = nil
            if self.data.currView == EQUIP_VIEW then
                goodsType = BaseConfig.GOODS_EQUIP
            elseif self.data.currView == FRAG_VIEW then
                goodsType = BaseConfig.GOODS_FRAG
            else
                goodsType = BaseConfig.GOODS_PROPS
            end 
            local tips = require("scene.main.hero.widget.GetGoodsWayBox").new(goodsType, 
                                                            self.data.currGoods,
                                                            sender)
            tips:setBgPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
            local scene = cc.Director:getInstance():getRunningScene()
            scene:addChild(tips)
        end
    end)

    self:isShowEquipAttribute(false)
    if self.data.currView == EQUIP_VIEW then
        self.controls.use:setString("炼化")
        self.controls.sale:setString("分解")

        self:isShowEquipAttribute(true, sender.data.goodsInfo, sender.data.goodsConfigInfo)
        local equipType = sender.data.goodsConfigInfo.type
        if (equipType == 5) or (equipType == 6) then
            self.controls.goodsGetWay:setScale(0)
            self.controls.use:setScale(0)
            self.controls.sale:setScale(0)
        end
    elseif self.data.currView == FRAG_VIEW then
        self.controls.use:setString("合成")
        self.controls.sale:setString("出售")
    elseif self.data.currView == PROP_VIEW then
        self.controls.use:setString("使用")
        self.controls.sale:setString("出售")

        local propsType = sender.data.goodsConfigInfo.type
        if (propsType == PT_PowerPill) or (propsType == PT_EndurancePill) then
            self.controls.use:setScale(1)
        else
            self.controls.use:setScale(0)
            self.controls.sale:setPosition(self.data.bgSize.width * 0.19, self.data.bgSize.height * 0.12)
            if propsType == PT_FairyGift and (GameCache.Avatar.Level < BaseConfig.OpenSystemLevel.fairy) then
                self.controls.sale:setScale(0)
            end
        end

        if (propsType == PT_EquipFrag) or (propsType == PT_UpgradeStarPill) 
            or (propsType == PT_EquipUpgradePill) or (propsType == PT_EquipUpgradeMaterial) then
            self.controls.goodsGetWay:setScale(1)
        else
            self.controls.goodsGetWay:setScale(0)
        end
    end
end

function PackageLayer:updateShowGoodsHead(type, info)
    if self.controls.goodsInfoBG then
        self.controls.goodsInfoBG:removeFromParent()
        self.controls.goodsInfoBG = nil
    end
    local posX, posY = self.controls.goodsBG:getPosition()
    self.controls.goodsInfoBG = GoodsInfoNode.new(type, info)
    self.controls.goodsInfoBG:setPosition(posX, posY)
    self.controls.bg:addChild(self.controls.goodsInfoBG, bgZOrder)
    self.controls.goodsInfoBG:setTouchEnable(false)
end

function PackageLayer:isShowEquipAttribute(visible, goodsInfo, goodsConfig)
    self.controls.specialDesc:setVisible(visible)
    self.controls.talent:setVisible(visible)
    self.controls.attribute:setVisible(visible)
    self.controls.extraDesc:setVisible(visible)

    if visible then
        local fontHeight = 28
        local starDta = Common.getHeroStarLevelColor(goodsInfo.StarLevel)
        local herolist = goodsConfig.heroList
        local desc = ""
        for k,v in pairs(herolist) do
            local heroName = BaseConfig.GetHero(v, 0).name
            if k == (#herolist) then
                desc = desc..heroName.."的专属装备"
            else
                desc = desc..heroName.."，"
            end
        end
        local row1, desc1 = Common.StringLinefeed(desc, 14)
        -- 获得额外属性集合
        local extraDesc = Common.getEquipExtraDesc(goodsConfig, 1)

        self.controls.specialDesc:setString(desc1)
        self.controls.talent:setString("[255,255,255]资质:[=]".."[255,220,20]"..goodsConfig.talent.."[=]")
        if goodsConfig.type < 5 then
            self.controls.attribute:setString(self:getAttribute(goodsConfig, 1))
            self.controls.attribute:setPosition(self.data.bgSize.width * 0.26, self.controls.specialDesc:getPositionY() - row1 * fontHeight)
            self.controls.talent:setPosition(self.data.bgSize.width * 0.12, self.controls.specialDesc:getPositionY() - row1 * fontHeight)
        else
            self.controls.attribute:setVisible(false)
            self.controls.talent:setPosition(self.data.bgSize.width * 0.2, self.controls.specialDesc:getPositionY())
        end

        if next(extraDesc) then
            for k,v in pairs(extraDesc) do
                if v then
                    self.controls.extraDesc:setString(v)
                    self.controls.extraDesc:setPosition(self.data.bgSize.width * 0.2, self.controls.talent:getPositionY() - k * fontHeight)
                end
            end
        else
            self.controls.extraDesc:setVisible(false)
        end
    end
end

function PackageLayer:getAttribute(config, level)
    local attribute = nil
    if config.type == 1 then
        local lastAtk = config.atk + math.floor(((level - 1) * config.atkGrow)/10000)
        attribute = "[255,255,255]攻击:[=]".."[255,220,20]"..lastAtk.."[=]"
    elseif config.type == 2 then
        local lastDef = config.def + math.floor(((level - 1) * config.defGrow)/10000)
        attribute = "[255,255,255]防御:[=]".."[255,220,20]"..lastDef.."[=]"
    elseif config.type == 3 then
        local lastMp = config.mp + math.floor(((level - 1) * config.mpGrow)/10000)
        attribute = "[255,255,255]法力:[=]".."[255,220,20]"..lastMp.."[=]"
    elseif config.type == 4 then
        local lastHp = config.hp + math.floor(((level - 1) * config.hpGrow)/10000)
        attribute = "[255,255,255]生命:[=]".."[255,220,20]"..lastHp.."[=]"
    end
    return attribute
end

function PackageLayer:onEnter()
    application:dispatchCustomEvent(AppEvent.UI.Package.isFragCompound, {})
    if not self.data.isFirstJoin then
        if self.data.currView == EQUIP_VIEW then
            self.controls.equipView:updateView()
        elseif self.data.currView == FRAG_VIEW then
            self.controls.fragView:updateView()
        elseif self.data.currView == PROP_VIEW then
            self.controls.propView:updateView()
        end
    end
    self.data.isFirstJoin = false
end

function PackageLayer:onCleanup()
    application:removeEventListener(self.data.FragListener)
    scheduler:unscheduleScriptEntry(self.scheduler_updateStep)
    PackageLayer.super.onCleanup(self)
end

function PackageLayer:updateStep(dt)
    if tolua.isnull(self) then
        CCLog("self is null, scheduler")
        return
    end

    if self.data.isOpenStep then
        if math.ceil(self.data.stepNum) < self.data.chooseGoodsInfo.data.goodsInfo.Num then
            self.data.stepNum = self.data.stepNum + 0.4
            if self.data.stepNum >= 2 then
            end
        else
            self.data.stepNum = self.data.chooseGoodsInfo.data.goodsInfo.Num
        end
        self.data.chooseGoodsInfo:setNum(self.data.chooseGoodsInfo.data.goodsInfo.Num 
                                                                    - math.ceil(self.data.stepNum))
    end
end

--[[
    使用道具
]]-- 
function PackageLayer:UseProps(id)
    local propsConfig = self.data.chooseGoodsInfo:getGoodsConfigInfo()
    local rpcTab = nil
    if (POWERTYPE == propsConfig.type) or (ENDURANCETYPE == propsConfig.type) then
        rpcTab = {ID = id}
    end
    rpc:call("Props.Use", rpcTab, function ( event )
        if event.status == Exceptions.Nil and event.result then
            local allProps = GameCache.GetAllProps()
            for k,v in pairs(allProps) do
                if id == v.ID then
                    v.Num = v.Num - 1
                    self.data.chooseGoodsInfo:setNum(v.Num)
                    if v.Num <= 0 then
                        GameCache.minusProps(v.ID, 0)
                        local view = self.controls.bg:getChildByTag(self.data.currView)
                        view:updateView()
                    end
                    break
                end
            end

            local typeName = nil
            if POWERTYPE == propsConfig.type then
                typeName = "神清气爽，体力+"
            elseif ENDURANCETYPE == propsConfig.type then
                typeName = "身轻体健，耐力+"
            end
            application:showFlashNotice("上仙，您食用"..propsConfig.name.."后，"..typeName..propsConfig.useValue)
        end
    end)
end

return PackageLayer




