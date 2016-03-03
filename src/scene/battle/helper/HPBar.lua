


local HPBar = class("HPBar", function() return cc.Node:create() end)

function HPBar:ctor(isBoss, teamSide)
    if isBoss then
        local iconBoss = cc.Sprite:create("image/ui/img/btn/btn_363.png")
        iconBoss:setPosition(cc.p(-50, 185))
        iconBoss:setScale(0.5)
        self:addChild(iconBoss)
        self.iconBoss = iconBoss
    end

    local hpBgSprite = cc.Sprite:create(isBoss and "image/ui/img/btn/btn_222.png" or "image/ui/img/btn/btn_232.png")
    hpBgSprite:setPosition(cc.p(0, 185))
    hpBgSprite:setScale(0.8)
    self:addChild(hpBgSprite)
    self.hpBg = hpBgSprite

    local hpBarShadow = cc.ProgressTimer:create(cc.Sprite:create(isBoss and "image/ui/img/btn/btn_224.png" or "image/ui/img/btn/btn_223.png"))
    hpBarShadow:setPosition(cc.p(0, 185))
    hpBarShadow:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    hpBarShadow:setScale(0.8)
    hpBarShadow:setMidpoint(cc.p(0, 1))
    hpBarShadow:setBarChangeRate(cc.p(1, 0))
    hpBarShadow:setPercentage(100)
    self:addChild(hpBarShadow)
    self.hpBarShadow = hpBarShadow

    local bgImage = "image/ui/img/btn/btn_231.png"
    if teamSide == "right" then
        if isBoss then
            bgImage = "image/ui/img/btn/btn_221.png"
        else
            bgImage = "image/ui/img/btn/btn_230.png"
        end
    end

    local hpBar = cc.ProgressTimer:create(cc.Sprite:create(bgImage))
    hpBar:setPosition(cc.p(0, 185))
    hpBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    hpBar:setScale(0.8)
    hpBar:setMidpoint(cc.p(0, 1))
    hpBar:setBarChangeRate(cc.p(1, 0))
    hpBar:setPercentage(100)
    self:addChild(hpBar)
    self.hpBar = hpBar
end

function HPBar:updatePercent(percent)
    self.hpBar:runAction(cc.Sequence:create({
        cc.ProgressTo:create(0.5, percent),
        cc.CallFunc:create(function()
            self.hpBarShadow:runAction(cc.ProgressTo:create(0.1, percent))
        end),
    }))

    if percent > 0 then
        self.hpBg:setVisible(true)
        self.hpBarShadow:setVisible(true)
        self.hpBar:setVisible(true)

        if self._autoHideHpBar then
            self.hpBg:runAction(cc.Sequence:create({
                cc.DelayTime:create(3),
                cc.Hide:create(),
            }))
            self.hpBar:runAction(cc.Sequence:create({
                cc.DelayTime:create(3),
                cc.CallFunc:create(function() self.hpBarShadow:setVisible(false) end),
                cc.Hide:create(),
            }))
        end
    else
        self.hpBg:setVisible(false)
        self.hpBarShadow:setVisible(false)
        self.hpBar:setVisible(false)
    end
end

return HPBar
