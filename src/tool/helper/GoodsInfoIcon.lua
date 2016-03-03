local GoodsInfo = class("GoodsInfo", function()
    local self = cc.Node:create()
    self.controls = {}
    self.handlers = {}
    self.data = {}

    local function onNodeEvent(event)
        if event == "cleanup" then
            if self.data.isShowTips and (not tolua.isnull(self.controls.tips)) then
                if self.data.isTouchDown then
                    self.controls.tips:hide()
                    self.controls.tips:removeFromParent()
                    self.controls.tips = nil
                end
            end
        end
    end
    self:registerScriptHandler(onNodeEvent)

    return self
end)

local HEROTYPE = BaseConfig.GOODS_HERO
local EQUIPTYPE = BaseConfig.GOODS_EQUIP
local PROPSTYPE = BaseConfig.GOODS_PROPS
local FRAGTYPE = BaseConfig.GOODS_FRAG
local SOULTYPE = BaseConfig.GOODS_SOUL

local BIGSIZETYPE = BaseConfig.GOODS_BIGTYPE
local MIDDLESIZETYPE = BaseConfig.GOODS_MIDDLETYPE
local SMALLSIZETYPE = BaseConfig.GOODS_SMALLTYPE

local sizeTab = {cc.size(100, 100), cc.size(88, 88), cc.size(60, 60), cc.size(25, 25)}
local scaleValueTab = {1, 0.88, 0.6, 0.25}

--[[
    goodsType -- 用在区分星将[头像]、[装备]、[道具]、[碎片]、[魂魄]
    sizeType -- 图片大小 [100*100]、[88*88]、[60*60]
]]
function GoodsInfo:ctor(goodsType, goodsInfo, sizeType)
    self.data.goodsType = goodsType
    self.data.sizeType = sizeType or BIGSIZETYPE
    self.data.size = sizeTab[self.data.sizeType]

    self:updateGoodsInfo(goodsInfo)
    self:createUI()
    self:setListener()
    self:changeGoodsInfoIcon()

    self.data.isTouchEnable = true
    self:setChooseBorderVisible(false)
end

function GoodsInfo:setListener()
    local function onTouchBegan(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)
        
        if self.data.isTouchDown then
            return false
        end
        self.data.scaleValue = self:getScale()
        if cc.rectContainsPoint(rect, locationInNode) then
            if self.data.isTouchEnable then
                if not self.data.isTouchDown then
                    self.data.isTouchDown = true
                end
                
                self:setScale(self.data.scaleValue * 0.95)
                if self.data.func then
                    self.data.func(self, ccui.TouchEventType.began)
                end
                if self.data.isShowTips then
                    if self.data.isAlwaysShowTips then
                        self:showTipsBox()
                    elseif tolua.isnull(self:getTipsNode()) then
                        self:showTips()
                    end
                end
            end
            return true
        end
        return false
    end

    local function onTouchMoved(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if cc.rectContainsPoint(rect, locationInNode) then
            if self.data.isTouchDown then
                return 
            end
            if self.data.isTouchEnable then
                self:setScale(self.data.scaleValue * 0.95)
                if self.data.func then
                    self.data.func(self, ccui.TouchEventType.moved, true)
                end
            end
        else
            self:setScale(self.data.scaleValue * 1)
            if self.data.func then
                self.data.func(self, ccui.TouchEventType.moved, false)
            end
        end
    end

    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        self.data.isTouchDown = false
        self:setScale(self.data.scaleValue * 1)
        if self.data.isShowTips then
            if not self.data.isAlwaysShowTips then
                if not tolua.isnull(self.controls.tips) then
                    self.controls.tips:hide()
                end
            end
        end
        if cc.rectContainsPoint(rect, locationInNode) then
            if self.data.isTouchEnable then
                if self.data.func then
                    self.data.func(self, ccui.TouchEventType.ended)
                end
            end
        end
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.controls.head)
end

function GoodsInfo:createUI()
    cc.SpriteFrameCache:getInstance():addSpriteFrames("image/icon/border.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("image/icon/head.plist")

    if (self.data.goodsType == HEROTYPE) or (self.data.goodsType == PROPSTYPE) then
        self.controls.headBG = cc.Sprite:createWithSpriteFrameName("head_bg.png")
        self.controls.headBG:setScale(scaleValueTab[self.data.sizeType])
        self:addChild(self.controls.headBG)
    end

    local pathTab = self:getTexturePath()
    if (self.data.goodsType == FRAGTYPE) or (self.data.goodsType == SOULTYPE) then
        self:setFragHead(pathTab.Head)
    else
        self.controls.head = cc.Sprite:create(pathTab.Head)
        self.controls.head:setScale(scaleValueTab[self.data.sizeType])
        self:addChild(self.controls.head)
    end

    self.controls.wxBG = cc.Sprite:create("image/ui/img/btn/btn_382.png")
    self.controls.wxBG:setAnchorPoint(0, 0.5)
    self.controls.wxBG:setPosition(-self.data.size.width * 0.46, 0)
    self:addChild(self.controls.wxBG)

    self.controls.wx = cc.Label:createWithCharMap("image/ui/img/btn/btn_394.png", 24, 19,  string.byte("1"))
    self.controls.wx:setAnchorPoint(0.5, 0.5)
    self.controls.wx:setPosition(self.controls.wxBG:getContentSize().width * 0.5, self.controls.wxBG:getContentSize().height * 0.5)
    self.controls.wxBG:addChild(self.controls.wx)
    self.controls.wxBG:setVisible(false)

    -------测试所用-------
    -- if (self.data.goodsType == EQUIPTYPE) or (self.data.goodsType == FRAGTYPE) then
    --     self.controls.headName = Common.finalFont(self.data.goodsConfigInfo.name, 0, 0, 18, cc.c3b(255, 255, 255))
    --     self:addChild(self.controls.headName)
    -- end
    ---------------------
    self.controls.starLevel = cc.Sprite:create(pathTab.Border)
    self.controls.starLevel:setScale(scaleValueTab[self.data.sizeType])
    self:addChild(self.controls.starLevel)

    self.controls.chooseBorder = cc.Sprite:create(pathTab.ChooseBorder)
    self.controls.chooseBorder:setScale(scaleValueTab[self.data.sizeType])
    self:addChild(self.controls.chooseBorder)

    if self.data.goodsType == PROPSTYPE then
        self.controls.essence = cc.Sprite:createWithSpriteFrameName("equip_essence.png")
        self.controls.essence:setPosition(-self.data.size.width * 0.35, self.data.size.height * 0.35)
        self:addChild(self.controls.essence)
    end
end

-- local textureTabs = {"image/icon/equip/equip_1001.png", "image/icon/equip/equip_1002.png", "image/icon/equip/equip_1003.png",
--                     "image/icon/equip/equip_1004.png", "image/icon/equip/equip_1005.png", "image/icon/equip/equip_1006.png"}

function GoodsInfo:getTexturePath()
    local headPath = nil
    local borderPath = nil
    local chooseBorderPath = nil

    if (self.data.goodsType == HEROTYPE) or (self.data.goodsType == SOULTYPE) then
        headPath = "image/icon/head/"..self.data.goodsConfigInfo.res..".png"
    elseif self.data.goodsType == EQUIPTYPE then
        headPath = "image/icon/equip/"..self.data.goodsConfigInfo.res..".png"
        if not cc.FileUtils:getInstance():isFileExist(headPath) then
            headPath = string.format("image/icon/equip/equip_%d.png", self.data.goodsConfigInfo.type)
        end
    elseif self.data.goodsType == PROPSTYPE then
        local res = self.data.goodsConfigInfo.res
        headPath = "image/icon/props/"..res..".png"
        if string.sub(res, 1, 5) == "equip" then
            headPath = "image/icon/equip/"..res..".png"
        end
        if not cc.FileUtils:getInstance():isFileExist(headPath) then
            headPath = "image/icon/props/props_0.png"
        end
    elseif self.data.goodsType == FRAGTYPE then
        headPath = "image/icon/equip/"..self.data.goodsConfigInfo.res..".png"
        if not cc.FileUtils:getInstance():isFileExist(headPath) then
            headPath = string.format("image/icon/equip/equip_%d.png", self.data.goodsConfigInfo.type)
        end
    end

    if (self.data.goodsType == HEROTYPE) or (self.data.goodsType == EQUIPTYPE) then
        if self.data.goodsInfo.StarLevel then
            borderPath = string.format("image/icon/border/border_star_%d.png", self.data.goodsInfo.StarLevel)
        else
            borderPath = "image/icon/border/props_border.png"
        end
    elseif (self.data.goodsType == PROPSTYPE) then
        local borderLevel = self.data.goodsConfigInfo.quality
        if borderLevel < 2 then
            borderPath = "image/icon/border/border_star_0.png"
        elseif borderLevel < 3 then
            borderPath = "image/icon/border/border_star_1.png"
        elseif borderLevel < 4 then
            borderPath = "image/icon/border/border_star_3.png"
        elseif borderLevel < 5 then
            borderPath = "image/icon/border/border_star_5.png"
        elseif borderLevel < 6 then
            borderPath = "image/icon/border/border_star_8.png"
        else
            borderPath = "image/icon/border/border_star_12.png"
        end
    elseif self.data.goodsType == FRAGTYPE then
        borderPath = string.format("image/icon/border/frag_border_%d.png", self.data.goodsConfigInfo.quality)
    elseif self.data.goodsType == SOULTYPE then
        local soulConfig = BaseConfig.GetSoul(self.data.goodsInfo.ID)
        local starData = Common.getHeroStarLevelColor(soulConfig.starLevel)
        local starNum = starData.StarNum
        borderPath = string.format("image/icon/border/frag_border_%d.png", starNum)
    end

    if (self.data.goodsType == FRAGTYPE) or (self.data.goodsType == SOULTYPE) then
        chooseBorderPath = "image/icon/border/frag_selected.png"
    else
        chooseBorderPath = "image/icon/border/border_selected.png"
    end
    
    return {Head = headPath, Border = borderPath, ChooseBorder = chooseBorderPath}
end

function GoodsInfo:setFragHead(headPath)
    local mode = cc.Sprite:create("image/icon/border/frag_clip.png")
    mode:setScale(scaleValueTab[self.data.sizeType])

    local clippingNode = cc.ClippingNode:create()
    clippingNode:setAlphaThreshold(0.5)
    clippingNode:setStencil(mode)
    self:addChild(clippingNode)

    self.controls.headBG = cc.Sprite:create("image/icon/border/head_bg.png")
    self.controls.headBG:setScale(scaleValueTab[self.data.sizeType])
    clippingNode:addChild(self.controls.headBG)

    self.controls.head = cc.Sprite:create(headPath)
    self.controls.head:setScale(scaleValueTab[self.data.sizeType])
    clippingNode:addChild(self.controls.head)
end

function GoodsInfo:updateGoodsInfo(goodsInfo)
    self.data.goodsInfo = goodsInfo

    if not self.data.goodsInfo.StarLevel then
        if self.data.goodsType == EQUIPTYPE then
            local fragToEquipConfig = BaseConfig.GetFragToEquip(self.data.goodsInfo.ID)
            self.data.goodsInfo.StarLevel = fragToEquipConfig.starLevel
        elseif self.data.goodsType == HEROTYPE then
            self.data.goodsInfo.StarLevel = BaseConfig.GetSoul(self.data.goodsInfo.ID).starLevel
        end
    end

    if (self.data.goodsType == HEROTYPE) or (self.data.goodsType == SOULTYPE) then
        self.data.goodsConfigInfo = BaseConfig.GetHero(self.data.goodsInfo.ID, self.data.goodsInfo.StarLevel)
    elseif self.data.goodsType == EQUIPTYPE then
        self.data.goodsConfigInfo = BaseConfig.GetEquip(self.data.goodsInfo.ID, self.data.goodsInfo.StarLevel)
    elseif (self.data.goodsType == PROPSTYPE) or (self.data.goodsType == FRAGTYPE) then
        if self.data.goodsInfo.Type == BaseConfig.GT_TREASURE_FRAG then
            -- 判断是配置读取的宝物信息还是服务器传过来的
            local goodsID = nil
            local seat = nil
            if self.data.goodsInfo.Seat then
                goodsID = self.data.goodsInfo.ID
                seat = self.data.goodsInfo.Seat
            else
                goodsID = tonumber(string.sub(self.data.goodsInfo.ID, 1, 4))
                seat = tonumber(string.sub(self.data.goodsInfo.ID, 5, 5))
            end
            local fragConfig = BaseConfig.GetTreasure(goodsID, seat)
            self.data.goodsConfigInfo = BaseConfig.GetProps(goodsID)
            self.data.goodsConfigInfo.name = fragConfig.Name
        else
            self.data.goodsConfigInfo = BaseConfig.GetProps(self.data.goodsInfo.ID)
        end
    end
end

function GoodsInfo:setGoodsInfo(goodsInfo, goodsType)
    self.data.goodsType = goodsType or self.data.goodsType
    self:updateGoodsInfo(goodsInfo)
    self:changeGoodsInfoIcon()
    if self.data.isShowFragAlert then
        self:setFragAlert()
    end
    if self.controls.level then
        self:setLevel()
    end
    self:setWx()
end

function GoodsInfo:changeGoodsInfoIcon()
    local pathTab = self:getTexturePath()
    if self.controls.headBG then
        self.controls.headBG:setScale(scaleValueTab[self.data.sizeType])
    end

    local libpath = require("tool.lib.path")
    local _, name = libpath.split(pathTab.Head)
    local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrameByName(name)
    if spriteFrame then
        self.controls.head:setSpriteFrame(spriteFrame)
    else
        self.controls.head:setTexture(pathTab.Head)
    end
    self.controls.head:setScale(scaleValueTab[self.data.sizeType])

    local _, name = libpath.split(pathTab.Border)
    local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrameByName(name)
    if spriteFrame then
        self.controls.starLevel:setSpriteFrame(spriteFrame)
    else
        self.controls.starLevel:setTexture(pathTab.Border)
    end    
    
    self.controls.starLevel:setScale(scaleValueTab[self.data.sizeType])
    ------测试所用---------
    -- if (self.data.goodsType == EQUIPTYPE) or (self.data.goodsType == FRAGTYPE) then
    --     self.controls.headName:setString(self.data.goodsConfigInfo.name)
    -- end
    ----------------------
    if self.data.goodsType == PROPSTYPE then
        if self.data.goodsConfigInfo.type == 7 then
            self.controls.essence:setVisible(true)
        else
            self.controls.essence:setVisible(false)
        end
    end
end

function GoodsInfo:setNum(num)
    local num = num or self.data.goodsInfo.Num
    if num then
        local newNum = Common.numConvert(num)
        if self.controls.num then
            self.controls.num:setString(newNum)
        else
            self.controls.num = Common.finalFont(newNum, self.data.size.width * 0.46, -self.data.size.height * 0.48, 18, nil, 1)
            self.controls.num:setAnchorPoint(1, 0)
            self:addChild(self.controls.num)
        end
    end
end

function GoodsInfo:setNumVisible(visible)
    if self.controls.num then
        self.controls.num:setVisible(visible)
    end
end

function GoodsInfo:setLevel(align, level)
    local align = align or "center"
    local level = level or self.data.goodsInfo.Level
    if level then
        if self.controls.level then
            self.controls.level:setString("Lv."..level)
        else
            if (self.data.goodsType == HEROTYPE) or (self.data.goodsType == EQUIPTYPE) then
                local levelBg = cc.Sprite:create("image/ui/img/btn/btn_1044.png")
                self:addChild(levelBg)
                levelBg:setPosition(0, -self.data.size.height * 0.38)
            end
            self.controls.level = Common.finalFont("Lv."..level, 0, 0, nil, nil, 1)
            self:addChild(self.controls.level)
        end

        if align == "left" then
            self.controls.level:setAnchorPoint(0, 0)
            self.controls.level:setPosition(-self.data.size.width * 0.5, -self.data.size.height * 0.5)
        elseif align == "center" then
            self.controls.level:setAnchorPoint(0.5, 0)
            self.controls.level:setPosition(0, -self.data.size.height * 0.5)
        elseif align == "right" then
            self.controls.level:setAnchorPoint(1, 0)
            self.controls.level:setPosition(self.data.size.width * 0.5, -self.data.size.height * 0.5)
        end
    end
end

function GoodsInfo:setWx(wx)
    local wx = wx or self.data.goodsConfigInfo.wx
    if wx then
        self.controls.wxBG:setVisible(true)
        self.controls.wx:setString(wx)
    end
end

function GoodsInfo:setGoodsName(name)
    local name = name or self.data.goodsConfigInfo.name
    if name then
        if self.controls.name then
            self.controls.name:setString(name)
        else
            local color = Common.getHeroStarLevelColor(self.data.goodsInfo.StarLevel).Color
            self.controls.name = Common.finalFont(name, 0, -self.data.size.height * 0.75, 20, color)
            self:addChild(self.controls.name)
        end
    end
end

function GoodsInfo:setTips(visible)
    self.data.isShowTips = visible
end

function GoodsInfo:showTips()
    self.controls.tips = require("tool.helper.CommonTips").new(self.data.goodsType, 
                                                            self.data.goodsInfo,
                                                            self)
    self.controls.tips:setName("hero_tip")
    local scene = cc.Director:getInstance():getRunningScene()
    scene:addChild(self.controls.tips,3)
end

function GoodsInfo:setTipsBox(visible)
    self.data.isAlwaysShowTips = visible
end

function GoodsInfo:showTipsBox()
    self.controls.tips = require("scene.main.hero.widget.GetGoodsWayBox").new(self.data.goodsType, 
                                                            self.data.goodsInfo,
                                                            self)
    self.controls.tips:setBgPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    local scene = cc.Director:getInstance():getRunningScene()
    scene:addChild(self.controls.tips)
end

function GoodsInfo:getTipsNode()
    local scene = cc.Director:getInstance():getRunningScene()
    return scene:getChildByName("hero_tip")
end

function GoodsInfo:updateGetSource()
    if self.controls.tips then
        if self.controls.tips.updateGoods then
            self.controls.tips:updateGoods()
        end
    end
end

function GoodsInfo:setTouchEnable(value)
    self.data.isTouchEnable = value
end

function GoodsInfo:setChooseBorderVisible(visible)
    self.data.isShowBorder = visible
    self.controls.chooseBorder:setVisible(visible)
end

function GoodsInfo:setFragAlert()
    self.data.isShowFragAlert = true
    if (self.data.goodsType == FRAGTYPE) then
        if not self.controls.fragAlert then
            self.controls.fragAlert = cc.Sprite:create("image/ui/img/btn/btn_398.png")
            self.controls.fragAlert:setScale(0.5)
            self:addChild(self.controls.fragAlert)
            self.controls.fragAlert:setPosition(-self.data.size.width * 0.35, self.data.size.height * 0.35)
        end
        self.controls.fragAlert:setVisible(Common.isFragCompound(self.data.goodsInfo))
    end
end

function GoodsInfo:getContentSize()
    return self.data.size
end

function GoodsInfo:getGoodsInfo()
    return self.data.goodsInfo
end

function GoodsInfo:getGoodsConfigInfo()
    return self.data.goodsConfigInfo
end

function GoodsInfo:addTouchEventListener(event)
    self.data.func = event
end

return GoodsInfo

