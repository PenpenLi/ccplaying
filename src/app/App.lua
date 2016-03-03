local utf8 = require("tool.lib.utf8")
require("app.config")

if GAME_BASE_INFO.SDK then
    require("platformSDK.SDK")
end

local GUIDE_STEP_DATA = require("scene.guide.NewbieGuideConfig")
local NEW_SYSTEM_DATA = require("scene.guide.OpenSysConfig")
-------------------------------------------------------------------------------

local App = class("App", function()
    local self = cc.EventDispatcher:new()
    self:retain()
    self:setEnabled(true)
    return self
end)

function App:ctor(appName)
    self.name = appName
    self.director = cc.Director:getInstance()
    self.director:setDisplayStats(CC_SHOW_FPS)

    self.funcQueue = {}
    self.messageQueue = {}
    self.rollingExpire = nil
    self.verCheckResult = nil
    self.threads = {}
    self.threadScheduleEntryID = nil

    local listener = cc.EventListenerCustom:create("applicationDidReceiveMemoryWarning", handler(self, self.onMemoryWarning))
    self.director:getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)
end

function App:runInThread(callback, func, ...)
    local thread = Threads.new(func, ...)
    thread:start()
    table.insert(self.threads, {thread = thread, callback = callback})

    self:scheduleThread()
end

function App:scheduleThreadFunc()
    local count = #self.threads

    if count > 0 then
        for idx = count, 1, -1 do
            local threadInfo = self.threads[idx]
            local thread = threadInfo.thread
            local callback = threadInfo.callback
            if thread:started() and not thread:alive() then
                table.remove(self.threads, idx)
                
                local status, result = thread:join()

                if callback then
                    callback(status, result)
                end
            end
        end
    else
        self:unscheduleThread()
    end
end

function App:scheduleThread()
    if self.threadScheduleEntryID == nil then
        local scheduler = cc.Director:getInstance():getScheduler()
        local scheduleEntryID = scheduler:scheduleScriptFunc(handler(self, self.scheduleThreadFunc), 0, false)

        self.threadScheduleEntryID = scheduleEntryID
    end
end

function App:unscheduleThread()
    if self.threadScheduleEntryID then
        local scheduler = cc.Director:getInstance():getScheduler()
        scheduler:unscheduleScriptEntry(self.threadScheduleEntryID)
        self.threadScheduleEntryID = nil
    end
end

function App:clearRollingMessage()
    CCLog("App:clearRollingMessage")
    self.messageQueue = {}
end

function App:pushRollingMessage(message)
    CCLog(vardump(message, "App:pushRollingMessage"))
    local timeNow = os.time()
    
    self.rollingExpire = timeNow + 0.5
    table.insert(self.messageQueue, message)
    table.sort(self.messageQueue, function(msg1, msg2) return msg1.Priority < msg2.Priority end)
end


function App:scheduleAction(action)
    table.insert(self.funcQueue, action)
end

function App:run()
    cc.FileUtils:getInstance():addSearchPath("res/")
    InitializeEvents("AppEvent", AppEvent)

    self:enterScene("loading.SplashScreenScene")

    rpc:addEventListener("Avatar.LevelUp", function(event)
        self:showLevelUpTips(event)
    end, 2)

    local function checkRollingMessage()
        if self.rollingExpire then
            local timeNow = os.time()
            if timeNow > self.rollingExpire then
                self.rollingExpire = timeNow + 8

                if #self.messageQueue == 0 then
                    self.rollingExpire = nil
                else
                    if #self.messageQueue > 0 and GameCache.Avatar then
                        local msg = table.remove(self.messageQueue, 1)
                        self:dispatchCustomEvent(AppEvent.UI.Message.Message, msg)
                    end
                end
            end
        end
    end

    local scheduler = cc.Director:getInstance():getScheduler()
    scheduler:scheduleScriptFunc(function ()
        -- CCLog("heartbeat")
        while #self.funcQueue > 0 do
            local action = table.remove(self.funcQueue)
            xpcall(action, __G__TRACKBACK__)
        end

        xpcall(checkRollingMessage, __G__TRACKBACK__)

        if (GameCache.Avatar ~= nil) then
            rpc:heartbeat()
        end
    end, 3, false)

    self:addEventListener(AppEvent.UI.NewbieGuide.CreateGuide, function ( event )
        local page = event.data.page
        if  page ~= "LoadingWaitLayer" then
            GameCache.NewbieGuide.CurrPage = page or GameCache.NewbieGuide.CurrPage
        end
        CCLog(page)
        CCLog(GameCache.NewbieGuide.Step)
       local nextstep = GameCache.NewbieGuide.Step + 1
        local GuideData = GUIDE_STEP_DATA[nextstep]--{page = "BattlePlayer", steps = { {x = 200, y = 200, width = 200, height = 200}, {x = 600, y = 300, width = 200, height = 200}, }}
        --        
        if not GuideData then
            return
        end
        CCLog(GuideData.pages[page]) 
        if GuideData.pages[page] then
            local runningScene = cc.Director:getInstance():getRunningScene()
            local guidelayer = runningScene:getChildByName("GUIDE_LAYER")
            if not guidelayer then
                CCLog("--创建guide")
                require("scene.guide.NewbieGuideLayer").new()
            end
        end
    end)

    self:addEventListener(AppEvent.UI.NewbieGuide.SaveGuide, function ( event )
            local save = event.data.save or GameCache.NewbieGuide.Step + 1
            GameCache.NewbieGuide.SavePoint = save
            rpc:call("Guide.SetCurStep", save , function ( event )

            end)
    end)

    self:addEventListener(AppEvent.UI.NewbieGuide.ResetGuide, function ( event )
        CCLog("resetguide ", event.data.jump)
        local jump = event.data.jump
        GameCache.NewbieGuide.SStep = jump or 1
    end)


    self:addEventListener(AppEvent.UI.NewbieGuide.CreateSystem, function ( event )
        local page = event.data.page
        if  page ~= "LoadingWaitLayer" then
            GameCache.OpenSystem.CurrPage = page or GameCache.OpenSystem.CurrPage
        end
        CCLog(page)
        CCLog(GameCache.OpenSystem.Step)
       local nextstep = GameCache.OpenSystem.Step
        local GuideData = NEW_SYSTEM_DATA[nextstep]--{page = "BattlePlayer", steps = { {x = 200, y = 200, width = 200, height = 200}, {x = 600, y = 300, width = 200, height = 200}, }}
        --        
        if not GuideData then
            return
        end
        -- CCLog(GuideData.pages[page]) 
        if GuideData.pages and GuideData.pages[page] then
            local runningScene = cc.Director:getInstance():getRunningScene()
            local guidelayer = runningScene:getChildByName("OPENSYS_LAYER")
            if not guidelayer then
                CCLog("--创建opensystem")
                require("scene.guide.OpenSysLayer").new()
            end
        end
    end)
end

-- callback(cc.EventCustom)
function App:addEventListener(name, callback)
    local listener = cc.EventListenerCustom:create(name, callback)
    self:addEventListenerWithFixedPriority(listener, 1)
    return listener
end

function App:dispatchCustomEvent(eventName, data)
    local event = cc.EventCustom:new(eventName)
    event.data = data
    self:dispatchEvent(event)
end

function App:enterScene(sceneName, ...)
    local scenePackageName = "scene." .. sceneName
    local sceneClass = require(scenePackageName)
    local scene = sceneClass.new(...)

    local director = self.director
    if director:getRunningScene() then
        director:replaceScene(scene)
    else
        director:runWithScene(scene)
    end
    -- cc.Director:getInstance():purgeCachedData()
end

function App:replaceScene(sceneName, ... )
    local scenePackageName = "scene." .. sceneName
    local sceneClass = require(scenePackageName)
    local scene = sceneClass.new(...)

    local director = self.director
    director:replaceScene(scene)
end

function App:pushScene(sceneName, ...)
    local scenePackageName = "scene." .. sceneName
    local sceneClass = require(scenePackageName)
    local scene = sceneClass.new(...)

    local director = self.director
    director:pushScene(scene)
    -- cc.Director:getInstance():getTextureCache():removeUnusedTextures()
end

function App:pushSceneWithLoading(sceneName, ...)
    self:pushScene(sceneName, ...)
--    local sceneClass = require("tool.helper.LoadingScene")
--    local loadingScene = sceneClass.new(sceneName, ...)
--
--    local director = self.director
--    director:pushScene(loadingScene)
    -- cc.Director:getInstance():getTextureCache():removeUnusedTextures()
end

function App:popScene(  )
    local director = self.director
    director:popScene()
    -- cc.Director:getInstance():getTextureCache():removeUnusedTextures()

    sp.SkeletonDataCache:getInstance():trace()
    sp.SkeletonDataCache:getInstance():removeUnusedSkeletonData()
end

function App:dialog(...)
    local MessageBoxLayer = require("tool.helper.MessageBoxLayer")
    return MessageBoxLayer.show(...)
end

local flashNoticeOffsetStack = {}
function App:showFlashNotice(text)
    local width = math.min(math.max(50 + utf8.len(text) * (26 + 2) + 50, 350), 560)
    local height = 40

    if #flashNoticeOffsetStack == 0 then
        local stackCount = 5
        for i = 1, stackCount do
            table.insert(flashNoticeOffsetStack, {used = false, offset = (stackCount - i) * height})
        end
    end

    local node = cc.Node:create()
    node:setPosition(SCREEN_WIDTH*0.5, 50)
    node:setAnchorPoint(0.5, 0.5)
    node:setColor(cc.c3b(200, 200, 200))
    node:setOpacity(50)
    node:setContentSize(width, height)
    cc.Director:getInstance():getRunningScene():addChild(node)

    local bg = ccui.ImageView:create("image/ui/img/btn/btn_1134.png")
    bg:setScale9Enabled(true)
    bg:setContentSize(cc.size(width, height))
    bg:setAnchorPoint(0.5,0.5)
    bg:setPosition(width / 2, height / 2)
    node:addChild(bg)

    local label = ccui.Text:create()
    label:setTextAreaSize(cc.size(width, height))
    label:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    label:setTextVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    label:setFontSize(22)
    label:setText(text)
    label:setColor(cc.c3b(225, 247, 255))
    label:setPosition(width / 2, height / 2)
    label:setSize(cc.size(width, height))
    label:setAnchorPoint(0.5, 0.5)
    node:addChild(label)

    local offset = 0
    local offsetIndex = 0
    for idx, data in ipairs(flashNoticeOffsetStack) do
        if data.used == false then
            offsetIndex = idx
            offset = data.offset
        end
    end

    local pushOffset = cc.CallFunc:create(function()
        if offsetIndex > 0 and offsetIndex <= #flashNoticeOffsetStack then
            flashNoticeOffsetStack[offsetIndex].used = true
        end
    end)

    local moveTime = 0.4
    local delayTime = 0.6
    local outTime = 0.3
    local move = cc.EaseExponentialOut:create(cc.MoveTo:create(moveTime, cc.p(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5 + 50 - offset)))
    local delay = cc.DelayTime:create(moveTime + delayTime + outTime)
    local moveDelay = cc.DelayTime:create(moveTime + delayTime)
    local moveOut = cc.MoveBy:create(outTime, cc.p(0, 80))
    local fadeout = cc.FadeOut:create(outTime)
    local spaOut = cc.Spawn:create(moveOut, fadeout)
    local reomve = cc.RemoveSelf:create()
    local popOffset =  cc.CallFunc:create(function()
        if offsetIndex > 0 and offsetIndex <= #flashNoticeOffsetStack then
            flashNoticeOffsetStack[offsetIndex].used = false
        end
    end)

    local action = cc.Sequence:create({pushOffset, move, delay, reomve, popOffset})
    node:runAction(action)
    local seq = cc.Sequence:create(moveDelay, spaOut)
    bg:runAction(seq)
    label:runAction(seq:clone())
end

function App:showIconNotice(goodsInfoTabs)
    local totalNum = #goodsInfoTabs
    local rows = math.ceil(totalNum / 4)

    local node = cc.Node:create()
    cc.Director:getInstance():getRunningScene():addChild(node)

    local widthSpace = 110
    local heightSpace = 80
    local rowNum = 4
    local bg = cc.Node:create()
    bg:setPosition(SCREEN_WIDTH * 0.5, 0)
    node:addChild(bg)

    for k,v in pairs(goodsInfoTabs) do
        local posX = nil
        local posY = nil
        local currRow = math.ceil(k / 4)
        local beforeRowTotal = rowNum * (currRow - 1)
        if currRow < rows then
            posX = -widthSpace * (rowNum - 1) + (k - 1 - beforeRowTotal) * widthSpace * 2
        else
            local nextRowNum = totalNum - beforeRowTotal
            posX =  -widthSpace * (nextRowNum - 1) + (k - 1 - beforeRowTotal) * widthSpace * 2
        end
        posY = (heightSpace / 2) * (rows - 1) - (currRow - 1) * heightSpace

        local itemBG = cc.Scale9Sprite:create("image/ui/img/btn/btn_1134.png")
        itemBG:setContentSize(cc.size(188, 60))
        itemBG:setPosition(posX, posY)
        bg:addChild(itemBG)
        local item = Common.getGoods(v, true, BaseConfig.GOODS_SMALLTYPE)
        item:setPosition(posX - 50, posY + 15)
        bg:addChild(item)
        if item.setTips then
            item:setTips(false)
        end
        if item.setNumVisible then
            item:setNumVisible(false)
        end
        local numLab = Common.finalFont("x "..v.Num, 1, 1, 22, nil, 1)
        numLab:setAdditionalKerning(-2)
        numLab:setAnchorPoint(0, 0.5)
        numLab:setPosition(posX - 10, posY)
        bg:addChild(numLab)
    end

    local moveTime = 0.4
    local delayTime = 0.4
    local outTime = 0.3
    local move = cc.EaseExponentialOut:create(cc.MoveTo:create(moveTime, cc.p(0, SCREEN_HEIGHT*0.5)))
    local delay = cc.DelayTime:create(moveTime + delayTime + outTime)
    local moveDelay = cc.DelayTime:create(moveTime + delayTime)
    local moveOut = cc.MoveBy:create(outTime, cc.p(0, SCREEN_HEIGHT * 0.8))
    local fadeout = cc.FadeOut:create(outTime)
    local spaOut = cc.Spawn:create(moveOut, fadeout)
    local reomve = cc.RemoveSelf:create()

    local action = cc.Sequence:create({move, delay, reomve})
    node:runAction(action)
    local seq = cc.Sequence:create(moveDelay, spaOut)
    bg:runAction(seq)
end

function App:showLevelUpTips(event)
    local oldAvt = event.result.oldAvatar
    local newAvt = event.result.newAvatar
    local param = {oldAvt.Level, newAvt.Level, oldAvt.Level, newAvt.Level, oldAvt.PhyPower, newAvt.PhyPower}
    self:pushScene("main.UpLevelScene", param)
end

function App:showLoading()
    -- HttpClient.loading = HttpClient.loading + 1
    local runningScene = cc.Director:getInstance():getRunningScene()
    if runningScene == nil then
        return 
    end

    if not self.loadingLayer or tolua.isnull(HttpClient.loadingLayer) then
        self.loadingLayer = LoadingWaitLayer.new()
        runningScene:addChild(self.loadingLayer)
    end
end

function App:hideLoading()
    -- HttpClient.loading = HttpClient.loading - 1
    if self.loadingLayer and not tolua.isnull(self.loadingLayer) then
        self.loadingLayer:removeFromParent()
        self.loadingLayer = nil
    end
end

function App:onMemoryWarning(event)
    CCLog("onMemoryWarning:", event, vardump({event, event.data}), vardump(getmetatable(event)))
    local inspect = require("tool.lib.inspect")
    CCLog("memory before:", collectgarbage("count"))
    CCLog("AppController::applicationDidReceiveMemoryWarning")

    BaseConfig.purgeMemory()
    collectgarbage("collect")

    CCLog("memory after:", collectgarbage("count"))
end

function App:platformLogin(platform, info)
    CCLog("platfromLogin", vardump({platform, info}))
end

function App:setVersionCheckResult(result)
    self.verCheckResult = result
end

function App:enterGame()
    CCLog("App:enterGame")
    self:enterScene("update.VersionCheckScene", self.verCheckResult)
end

function App:initGameAndEnterMainScene()
    CCLog("App:initGameAndEnterMainScene")
    local finishHandler = function(event)
        if event.status == Exceptions.EDisabledRole then
            application:showFlashNotice("你已被禁号！")
            return
        end

        if event.status ~= Exceptions.Nil then
            application:showFlashNotice("进入游戏失败！")
            return
        end

        -- 创建新角色
        local key = "regist" .. event.result.Avatar.RID
        local isRegisted = cc.UserDefault:getInstance():getBoolForKey(key)
        if not isRegisted then
            cc.UserDefault:getInstance():setBoolForKey(key, true)
            ReyunLog.register(event.result.Avatar.RID, event.result.Avatar.SID)
        end

        ReyunLog.login(event.result.Avatar.RID, event.result.Avatar.SID, event.result.Avatar.Level)

        GameCache.updateEquipList(event.result.EquipList) 
        GameCache.updatePropsList(event.result.PropsList) 
        GameCache.updateHeroList(event.result.HeroList) 
        GameCache.updateSoulList(event.result.SoulList) 
        GameCache.updateFairyList(event.result.FairyList) 
        GameCache.updateAvatar(event.result.Avatar)
        GameCache.updateFriendInfo(event.result.Friend) 
        GameCache.updateInstanceInfo(event.result.Instance) 
        GameCache.updateApartment(event.result.Apartment) 
        local popActivity = event.result.PopActivity
        -- TODO: 活动中心是否弹出处理

        application:enterScene("main.MainScene",popActivity)
        require("tool.helper.QuickGuide"):getInstance()
        application:dispatchCustomEvent(AppEvent.UI.Heartbeat.Bee, event.result.Bee) 
    end
    
    rpc:call("Game.Init", nil, finishHandler)
end

return App
