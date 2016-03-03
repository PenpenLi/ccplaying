--
-- Author: keyring
-- Date: 2016-02-24 09:56:02
--
function RevivePanel( callback )
	local layer = cc.Layer:create()
	local scene = cc.Director:getInstance():getRunningScene()
	scene:addChild(panel)

	local time_second = 15
	local Timer = cc.Director:getInstance():getScheduler()

    local bgsize = cc.size(480,320)
    local bg = ccui.ImageView:create("image/ui/img/bg/bg_139.png")
    bg:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)
    bg:setScale9Enabled(true)
    bg:setContentSize(bgsize)
    layer:addChild(bg)

    local title_label = Common.systemFont("复活提示", bgsize.width*0.5, bgsize.height+5, 30)
    bg:addChild(title_label)

    local label = Common.systemFont("上仙，请等待时间以复活", bgsize.width*0.5, bgsize.height-30, 22)
    bg:addChild(label)


    local time_label = Common.systemFont("", bgsize.width*0.5, bgsize.height*0.5, 22)
    bg:addChild(time_label)

    local miao = Common.systemFont("秒", bgsize.width*0.5+30, bgsize.height*0.5, 22)
    bg:addchild(miao)

    local scheduler = Timer:scheduleScriptFunc(function (  )
    	time_label:setString(time_second)
    	time_second = time_second - 1
    	if time_second <= 0 and scheduler then
    		Timer:unscheduleScriptEntry(scheduler)
    		layer:removeFromParent()
    		layer = nil
    		-- 回调通知
    		callback()
    	end
    end, 1, false)


    local btnsize = cc.size(200,65)
    local btn_revive = ccui.MixButton:create("image/ui/img/btn/btn_593.png")
    btn_revive:setScale9Size(btnsize)
    btn_revive:setPosition(bgsize.width*0.5, bgsize.height*0.5-80)
    bg:addChild(btn_revive)
    btn_revive:addTouchEventListener(function ( sender, eventType )
    	if eventType == ccui.TouchEventType.ended then
    		if scheduler then
    			Timer:unscheduleScriptEntry(scheduler)
    		end
    		
    		layer:removeFromParent()
    		layer = nil
    		-- 回调通知
    		callback()
    	end
    end)

    local label = Common.systemFont("立即复活", btnsize.width*0.25, btnsize.height*0.5, 22)
    btn_revive:addChild(label)

    local icon = cc.Sprite:create("image/ui/img/btn/btn_060.png")
    icon:setPosition(btnsize.width*0.6, btnsize.height*0.5)
    btn_revive:addChild(icon)

    local label = Common.systemFont("100", btnsize.width*0.8, btnsize.height*0.5, 22)
    btn_revive:addChild(label)


    local label = Common.systemFont("VIP10 无限复活", bgsize.width*0.5, 50, 22)
    bg:addChild(label)

    local function onTouchBegan(touch, event)
        return true
    end

    local function onTouchEnded(touch, event)

    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = layer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)  

end