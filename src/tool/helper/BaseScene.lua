local TAG_QUIT_MSG_BOX = 0x12344321

local BaseScene = class("BaseScene", function()
    local self = cc.Scene:create()

    local function onKeyReleased(keyCode, event)
        CCLog(keyCode, cc.KeyCodeKey[keyCode], event)
        if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then
            local label = event:getCurrentTarget()
            if keyCode == cc.KeyCode.KEY_BACK then
                CCLog("back")
                local CommonLayer = require("tool.helper.CommonLayer")
                local quitMsgBox = cc.Director:getInstance():getRunningScene():getChildByTag(TAG_QUIT_MSG_BOX)
                if quitMsgBox == nil then                   
                    quitMsgBox = CommonLayer.AlertPanel("确定要退出游戏？", function()                             
                            cc.Director:getInstance():endToLua()
                            os.exit(0) end,
                        true, 
                        function() end, 
                        "退出"
                    )
                    quitMsgBox:setTag(TAG_QUIT_MSG_BOX)
                else
                    quitMsgBox:removeFromParent()
                    quitMsgBox = nil
                end
            elseif keyCode == cc.KeyCode.KEY_MENU  then
                CCLog("menu")
            end
        end
    end

    local listener = nil

    local function onEnter()
        CCLogf("enter %s", self.__cname)
  
        listener = cc.EventListenerKeyboard:create()
        listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED)
        self:getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)
    end

    local function onEnterTransitionFinish(  )
        BaseConfig.isCanClick = true
    end 

    local function onExit()
        CCLogf("leave %s", self.__cname)
        self:getEventDispatcher():removeEventListener(listener)
    end

    local function onCleanup( )
        -- self:removeAllChildren()
        -- self:removeFromParent()
        -- self = nil
    end 

    local function onNodeEvent(event)
         CCLog("scene event:", event)
        if event == "enter" then
            onEnter()
        elseif event == "enterTransitionFinish" then
            onEnterTransitionFinish()
            
        elseif event == "exit" then
            onExit()
        elseif event == "cleanup" then
            onCleanup()
        end
    end

    self:registerScriptHandler(onNodeEvent)
    return self
end)

return BaseScene