local LoadingWaitLayer = class("LoadingWaitLayer", BaseLayer)

--加载界面布局函数
function LoadingWaitLayer:ctor()
    LoadingWaitLayer.super.ctor(self)
    
    self.data.clickCount = 0      --设置点击次数为0
    self.data.cancelCount = 10    --设置取消网络链接点击次数
   
    local function onTouchBegan(touch, event)
        return true
    end
    
    local function onTouchEnded(touch, event)
        CCLog("click count:", self.data.clickCount)
        self.data.clickCount = self.data.clickCount + 1
        if self.data.clickCount > self.data.cancelCount then
            self.data.clickCount = 0
            self:removeFromParent()
        end
    end
    
    local function onTouchMoved(touch, event)
    end
    
    local function onTouchCanelled(touch, event)
    end    
    
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(onTouchCanelled, cc.Handler.EVENT_TOUCH_CANCELLED)
    
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
       
    local loadingBg = cc.Sprite:create("image/ui/img/btn/btn_1055.png") --贴加载图片
    -- loadingBg:setVisible(false)                                                --设置其为不可见
    loadingBg:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)
    self:addChild(loadingBg)                                                   --添加控件                                               --赋值
    loadingBg:setFlipX(true)

    -- local action = cc.Sequence:create(cc.DelayTime:create(0.25), cc.Show:create())
    -- loadingBg:runAction(action)
    loadingBg:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.3, 180)))
end

function LoadingWaitLayer:onEnterTransitionFinish( ... )
    -- body
end

return LoadingWaitLayer