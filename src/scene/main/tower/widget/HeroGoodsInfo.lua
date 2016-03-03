local HeroGoodsInfo = class("HeroGoodsInfo", require("tool.helper.GoodsInfoIcon"))

function HeroGoodsInfo:ctor(heroInfo)
    HeroGoodsInfo.super.ctor(self, BaseConfig.GOODS_HERO, heroInfo)
    self:setWx()
    self:setLevel("center")

    self.data.currBlood = 0
    self.data.allBlood = 0
    self:setBlood()
end

function HeroGoodsInfo:setBlood(currBlood, allBlood)
    self.data.currBlood = currBlood or self.data.currBlood
    self.data.allBlood = allBlood or self.data.allBlood
    if self.controls.bloodBar then
        self.controls.bloodBar:setPercent(self.data.currBlood/self.data.allBlood * 100)
    else
        local bar_BG = cc.Sprite:create("image/ui/img/btn/btn_232.png")
        bar_BG:setPosition(0, -self.data.size.height * 0.58)
        self:addChild(bar_BG)

        self.controls.bloodBar = ccui.LoadingBar:create("image/ui/img/btn/btn_230.png")
        self.controls.bloodBar:setPosition(bar_BG:getContentSize().width * 0.5, bar_BG:getContentSize().height * 0.5)
        bar_BG:addChild(self.controls.bloodBar)

        self.controls.bloodBar:setPercent(self.data.currBlood/self.data.allBlood * 100)
    end
end

function HeroGoodsInfo:setDeath()
    local size = self:getContentSize()
    local space = 10
    self.controls.layerColor = cc.LayerColor:create(cc.c4b(50,50,50,200), size.width - space, size.height - space)
    self.controls.layerColor:setPosition(-size.width * 0.5 + space * 0.5, -size.height * 0.5 + space * 0.5)
    self:addChild(self.controls.layerColor)

    size = self.controls.layerColor:getContentSize()
    local deathDesc = Common.finalFont("战死", size.width * 0.5, size.height * 0.5, 30, cc.c3b(255, 0, 0))
    deathDesc:setRotation(-45)
    self.controls.layerColor:addChild(deathDesc)
end

function HeroGoodsInfo:setDeathVisible(visible)
    self.controls.layerColor:setVisible(visible)
end

return HeroGoodsInfo


