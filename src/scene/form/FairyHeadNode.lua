--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 14-11-28
-- Time: 下午5:03
-- To change this template use File | Settings | File Templates.
--
local CommonTool = require("tool.helper.Common")

local FairyHeadNode = class("FairyHeadNode", function() return cc.Node:create() end)

function FairyHeadNode:ctor(fairyData)
    CCLog(vardump(fairyData, "FairyHeadNode:ctor"))
    self.fairyData = fairyData
    self.fairyConfig = BaseConfig.GetFairy(fairyData.ID)
    self.controls = {}

    self._isInForm = false

    self:setContentSize(cc.size(104, 95))
    self:setAnchorPoint(cc.p(0.5, 0.5))

    self:setupUI()
end

function FairyHeadNode:getFairyData()
    return self.fairyData
end

function FairyHeadNode:setupUI()
    local centerPos = cc.p(104 / 2, 95 / 2 + 18)

    cc.SpriteFrameCache:getInstance():addSpriteFrames("image/icon/border.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("image/icon/head.plist")

--    local headBG = cc.Sprite:create("image/icon/border/border_circle_03.png")
--    headBG:setPosition(centerPos)
--    self:addChild(headBG)

    --local headBG = cc.Sprite:create("image/icon/border/border_circle_01.png")
    local headBG = cc.Sprite:createWithSpriteFrameName("border_circle_01.png")    
    headBG:setPosition(centerPos)
    self:addChild(headBG)
    self.controls.headBG = headBG

    -- local stencil = cc.Sprite:create("image/icon/border/border_circle_01.png")
    -- local clippingNode = cc.ClippingNode:create()
    -- clippingNode:setPosition(centerPos)
    -- clippingNode:setInverted(false)
    -- clippingNode:setAlphaThreshold(0.5)
    -- clippingNode:setStencil(stencil)
    -- self:addChild(clippingNode)

    --local border = cc.Sprite:create("image/icon/border/border_circle_02.png")
    local border = cc.Sprite:createWithSpriteFrameName("border_circle_02.png")
    border:setPosition(centerPos)
    self:addChild(border)
    self.controls.border = border

    local head = cc.Sprite:create(string.format("res/image/ui/fairy/%s_head.png", self.fairyConfig.Res))
    head:setPosition(cc.pAdd(centerPos, cc.p(0, 12)))
    head:setScale(1)
    --clippingNode:addChild(head)
    self:addChild(head)
    self.controls.head = head

    local labelName = CommonTool.finalFont(self.fairyConfig.Name, 0 , 0 , 18, cc.c3b(8,39,63), 0) -- cc.LabelTTF:create("lv." .. self:getLevel(), "Arial", 20)
    labelName:setPosition(cc.pAdd(centerPos, cc.p(0, -62)))
    self:addChild(labelName)
    self.controls.level = labelName

    local levelBg = cc.Sprite:create("image/ui/img/btn/btn_1044.png")
    levelBg:setPosition(cc.pAdd(centerPos, cc.p(0, -35)))
    self:addChild(levelBg)

    local labelLevel = Common.finalFont("Lv.".. self.fairyData.Level, 0, 0, nil, nil, 1)
    --CommonTool.createFont("Lv." .. self:getLevel(), 0 , 0 , 22, cc.c3b(255, 255, 255), 1) -- cc.LabelTTF:create("lv." .. self:getLevel(), "Arial", 20)
    labelLevel:setPosition(cc.pAdd(centerPos, cc.p(0, -35)))
    self:addChild(labelLevel)
    self.controls.level = labelLevel

    local spriteInForm = cc.Sprite:create("image/ui/img/btn/btn_502.png")
    spriteInForm:setPosition(cc.pAdd(centerPos, cc.p(0, -33)))
    self:addChild(spriteInForm)
    self.controls.inForm = spriteInForm
    spriteInForm:setVisible(false)
end

function FairyHeadNode:setInForm(inForm)
    self._isInForm = inForm
    self.controls.inForm:setVisible(inForm)

    --self.controls.border:setTexture(inForm and "image/icon/border/border_circle_02.png" or "image/icon/border/border_circle_03.png")
    self.controls.border:setSpriteFrame(inForm and "border_circle_02.png" or "border_circle_03.png")
end

return FairyHeadNode

