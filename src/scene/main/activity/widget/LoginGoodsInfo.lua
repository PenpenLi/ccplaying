local LoginGoodsInfo = class("LoginGoodsInfo", require("scene.main.activity.widget.LevelGoodsInfo"))

function LoginGoodsInfo:ctor(goodsInfo)
    LoginGoodsInfo.super.ctor(self, goodsInfo)

    local path = nil
    if self.UnFinishStatus == self.goodsInfo.Status then
        path = "image/ui/img/btn/btn_863.png"
    elseif self.ReceiveStatus == self.goodsInfo.Status then
        path = "image/ui/img/btn/btn_821.png"
    elseif self.FinishStatus == self.goodsInfo.Status then
        path = "image/ui/img/btn/btn_864.png"
    end
    self.statusSpri = cc.Sprite:create(path)
    self.statusSpri:setPosition(0, -130)
    self:addChild(self.statusSpri)
end

function LoginGoodsInfo:getAwardConfig()
    return BaseConfig.getActivityLoginAward(self.goodsInfo.Days)
end

function LoginGoodsInfo:getStatus()
    LoginGoodsInfo.super.getStatus(self)

    self.statusSpri:setTexture("image/ui/img/btn/btn_864.png")
end

return LoginGoodsInfo


