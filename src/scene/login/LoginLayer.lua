local LoginLayer = class("LoginLayer", BaseLayer)
local http = require("net.http")
local EffectManager = require("tool.helper.Effects")
local AccountHelper = require("tool.helper.AccountHelper")
local libmd5 = require("md5")

local center = {x = SCREEN_WIDTH * 0.5, y = SCREEN_HEIGHT * 0.5}

local KEY = ""
local KEY_ACCOUNT = "accountName"

local GUIDE_INITHERO = 1

local SERVER_STATUS_TEXT = {
    online = "流畅",
    full = "爆满",
    maintain = "维护",
    stop = "停止"
}
local SERVER_STATUS_IMAGE = {
    online = "image/ui/img/btn/btn_1007.png",
    full = "image/ui/img/btn/btn_1008.png",
    maintain = "image/ui/img/btn/btn_1261.png",
    stop = "image/ui/img/btn/btn_1330.png"
}
local SERVER_STATUS_COLOR = {
    online = cc.c3b(46,253,139),
    full = cc.c3b(255,78,0),
    maintain = cc.c3b(184,184,184),
    stop = cc.c3b(184,184,184)
}

-- 未签到状态
local NOTCHECKSTATUS = 0

function LoginLayer:ctor()
    LoginLayer.super.ctor(self)
    self:createLoginGameLayer()
end

function LoginLayer:onEnter(  )
    Common.playMusic("res/audio/music/login.mp3", true)

    local function checkGameVersion()
        local gameID  = GAME_BASE_INFO.gameID
        local channel = GAME_BASE_INFO.channel
        local majorv = GetAppVersion()
        local patchv = GetUpdatedVersion()
        local param = {Game = gameID, Channel = channel, Major = majorv, Patch = patchv}
        CCLog("param: ", vardump(param))

        application:setVersionCheckResult(nil)
        rpc:call("Game.CheckVersion", param, function(event)
            if event.status == Exceptions.Nil then
                local resp = event.result                

                if resp.Status == 0 then
                    -- 已经是最新版本，啥都不做
                    -- application:setVersionCheckResult(resp) 
                else
                    application:setVersionCheckResult(resp)
                    application:enterGame()
                end
            else
                require("tool.helper.CommonLayer").AlertPanel("上仙，貌似您的网络不太给力，\n检测游戏版本失败，请重新尝试", function() 
                    checkGameVersion()
                end)
            end
        end)
    end

    local function onLoginOK(login_result, account, recentServer)
        GameCache.LoginAccount = account
        GameCache.LoginKey = KEY
        
        AccountHelper.updateLastLoginAccount(account)
        self.data.recentServer = recentServer

        self.label_account:setString(account.displayName)
        self.label_servername:setString(self.data.recentServer.Name)
        self.label_servername:setColor(SERVER_STATUS_COLOR[self.data.recentServer.Status])
        self.label_state:setString(SERVER_STATUS_TEXT[self.data.recentServer.Status])
        self.label_state:setColor(SERVER_STATUS_COLOR[self.data.recentServer.Status])
        local enable = (self.data.recentServer.Status ~= "maintain" and self.data.recentServer.Status ~= "stop")
        self.btn_start:setStateEnabled(enable)
        self.btn_changeserver:setTouchEnabled(true)
        self.btn_switch:setVisible(true)

        checkGameVersion()
    end

    local function doSDKUserLogin(name, token, uid)
        local password = name
        local url, data = AccountHelper.SDK_LOGIN_URL(name, token, uid)
        CCLog(url, data)
        http.post(url, data, function ( response )
            CCLog(response)
            local rep = json.decode(response)
            if rep.Code ~= 0 then
                application:showFlashNotice("请重试")
                self.btn_switch:setVisible(true)
                return
            end

            recentServer = rep.Result.Suggest
            KEY = rep.Result.Key
            login_result = true
            login_account = account

            GameCache.Passport = rep.Result.Passport
            rpc:setRemoteAddr("http://" .. rep.Result.ServerAddr)

            CCLog(vardump(rep.Result))

            onLoginOK(login_result, {name = name, displayName = name, password = password, guest = false}, recentServer)
        end,
       function()
            require("tool.helper.CommonLayer").AlertPanel("上仙，貌似您的网络不太给力，\n连接不到服务器，请重新尝试", function() 
                switchLoginServerAddress()
                doSDKUserLogin(name, token, uid)
            end)
        end)
    end

    local function onSDKLoginOK(result)
        self.btn_changeserver:setTouchEnabled(true)
        self.btn_switch:setVisible(true)

        CCLog("doSDKUserLogin", result.userName)
        doSDKUserLogin(result.userName, result.token, result.uid)
    end

    local function doQuickRegister()
        local name = AccountHelper.randomName()
        local password = libmd5.hex(AccountHelper.randomPassword())

        local url = AccountHelper.REGISTER_URL({name = name, password = password, guest = true})
        CCLog(url)
        http.get(url, function ( resp )
            local reply = json.decode(resp)
            if reply.Code ~= 0 then
                application:showFlashNotice("请重试")
                self.btn_switch:setVisible(true)
            end

            local url = AccountHelper.LOGIN_URL({name = name, password = password, guest = true})
            CCLog(url)
            http.get(url, function ( response )
                local rep = json.decode(response)
                if rep.Code ~= 0 then
                    application:showFlashNotice("请重试")
                    self.btn_switch:setVisible(true)
                    return
                end

                recentServer = rep.Result.Suggest
                KEY = rep.Result.Key
                login_result = true
                login_account = account

                GameCache.Passport = rep.Result.Passport
                rpc:setRemoteAddr("http://" .. rep.Result.ServerAddr)

                CCLog(vardump(rep.Result))

                onLoginOK(login_result, {name = name, displayName = AccountHelper.genGuestAccountName(name), password = password, guest = true}, recentServer)
            end,
           function()
                require("tool.helper.CommonLayer").AlertPanel("上仙，貌似您的网络不太给力，\n连接不到服务器，请重新尝试", function() 
                    switchLoginServerAddress()
                    doQuickRegister()
                end)
            end)
        end,
        function()
            require("tool.helper.CommonLayer").AlertPanel("上仙，貌似您的网络不太给力，\n连接不到服务器，请重新尝试", function()
                switchLoginServerAddress() 
                doQuickRegister()
            end)
        end)
    end

    local function doUserLogin(account)
        local url = AccountHelper.LOGIN_URL(account)
        CCLog(url)
        http.get(url, function ( response )
            local rep = json.decode(response)
            if rep.Code ~= 0 then
                application:showFlashNotice("登录失败，请重新登录")
                self.btn_switch:setVisible(true)
                return
            end

            CCLog(vardump(rep.Result))

            recentServer = rep.Result.Suggest
            KEY = rep.Result.Key
            login_result = true
            login_account = account

            GameCache.Passport = rep.Result.Passport
            rpc:setRemoteAddr("http://" .. rep.Result.ServerAddr)

            onLoginOK(login_result, account, recentServer)
        end,
        function()
            require("tool.helper.CommonLayer").AlertPanel("上仙，貌似您的网络不太给力，\n连接不到服务器，请重新尝试", function() 
                switchLoginServerAddress()
                doUserLogin(account)
            end)
        end
        )
    end

    if GAME_BASE_INFO.SDK then
        local function doSDKLogin()
            SDK_doLogin(function(jsonStr)
                CCLog(jsonStr)
                local result = json.decode(jsonStr)

                CCLog("SDK_doLogin callback:", vardump(result))
                if result.status == "success" then
                    CCLog("login success")
                    onSDKLoginOK(result)
                else
                    CCLog("login fail, retry")
                    require("tool.helper.CommonLayer").AlertPanel("上仙，貌似您的网络不太给力，\n连接不到服务器，请重新尝试", function() 
                        doSDKLogin()
                    end)
                end
            end)
        end

        self.doSDKLogin = doSDKLogin

        doSDKLogin()
    else
        local lastLoginAccount = AccountHelper.getLastLoginAccount()
        if lastLoginAccount == nil then
            doQuickRegister()
        else
            doUserLogin(lastLoginAccount)
        end
    end
end

function LoginLayer:onEnterTransitionFinish( ... )
-- body
end

function LoginLayer:showAccountList(accountList, selectedCallback, clearCallback)
    local size = cc.size(489, 200)

    local layer = cc.LayerColor:create(cc.c4b(20, 20, 20, 255), size.width, size.height)
    layer:setPosition(cc.p((display.width - size.width) / 2, (display.height - size.height) / 2 + 20))
    layer:setName("account_list_layer")
    self:addChild(layer)

    local drawNode = cc.DrawNode:create()
    layer:addChild(drawNode)
    local bl, br, tr, tl  = cc.p(1, 1), cc.p(size.width - 1, 1), cc.p(size.width - 1, size.height - 1), cc.p(1, size.height - 1)
    drawNode:drawPolygon({bl, br, tr, tl}, 4, cc.c4f(1, 1, 1, 1), 1, cc.c4f(0, 0, 0, 0.15))

    local function onTouchBegan(touch, event)
        local target = layer
        local pos = target:getParent():convertToNodeSpace(touch:getLocation())
        local box = target:getBoundingBox()

        --CCLog(vardump({box = box, pos = pos}))
        if cc.rectContainsPoint(box, pos) then
            return true
        else
            layer:runAction(cc.Sequence:create({cc.DelayTime:create(0.01), cc.RemoveSelf:create()}))
            return false
        end
    end

    local function onTouchEnded(touch, event)
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)

    local tableSelectedIndex = nil
    local function scrollViewDidScroll(view)
        print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        print("scrollViewDidZoom")
    end

    local function tableCellTouched(tableView, cell)
        print("cell touched at index: " .. cell:getIdx())
    end

    local function cellSizeForTable(tableView,idx)
        return 50, size.width
    end

    local function registerTouchHandler(node, handler)
        local function onTouchBegan(touch, event)
            local target = node
            local pos = target:getParent():convertToNodeSpace(touch:getLocation())
            local box = target:getBoundingBox()

            --CCLog(vardump({box = box, pos = pos}))
            if target:isVisible() and cc.rectContainsPoint(box, pos) then
                return true
            else
                return false
            end
        end

        local function onTouchEnded(touch, event)
            local target = node
            local pos = target:getParent():convertToNodeSpace(touch:getLocation())
            local box = target:getBoundingBox()

            --CCLog(vardump({box = box, pos = pos}))
            if cc.rectContainsPoint(box, pos) then
                handler()
            end
        end

        local listener = cc.EventListenerTouchOneByOne:create()
        listener:setSwallowTouches(true)
        listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
        listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
        local eventDispatcher = self:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, node)
    end

    local function tableCellAtIndex(tableView, idx)
        local cell = tableView:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()
        else
            cell:removeAllChildren()
        end

        local account = accountList[idx + 1]

        local label_account = Common.finalFont(account.displayName, 80, 20, 24)
        label_account:setAlignment(cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        label_account:setColor(cc.c4b(0, 0, 0, 255))
        label_account:setDimensions(300, 40)
        label_account:setAnchorPoint(cc.p(0, 0.5))
        cell:addChild(label_account)

        registerTouchHandler(label_account, function()
            local account = accountList[idx + 1]
            CCLog(account)
            selectedCallback(account)
            layer:runAction(cc.Sequence:create({cc.DelayTime:create(0.01), cc.RemoveSelf:create()}))
        end)

        local label_delete = Common.finalFont("删除", size.width - 80, 20, 24)
        label_delete:setAnchorPoint(cc.p(0, 0.5))
        label_delete:setColor(cc.c4b(255, 0, 0, 255))
        label_delete:setName("label_delete")
        cell:addChild(label_delete)

        registerTouchHandler(label_delete, function()
            table.remove(accountList, idx + 1)
            AccountHelper.saveAccountList(accountList)
            tableView:reloadData()

            if #accountList == 0 and clearCallback then
                clearCallback()
            end            
        end)

        local label_size = label_delete:getContentSize()
        local drawNodeUnderLine = cc.DrawNode:create()
        drawNodeUnderLine:setName("draw_node_under_line")
        cell:addChild(drawNodeUnderLine)
        drawNodeUnderLine:drawLine(cc.p(size.width - 80, 5), cc.p(size.width - 80 + label_size.width, 5), cc.c4f(1, 0, 0, 0.6));
        drawNodeUnderLine:setVisible(false)

        local drawNode = cc.DrawNode:create()
        cell:addChild(drawNode)
        drawNode:drawLine(cc.p(25, 0), cc.p(size.width - 25, 0), cc.c4f(0, 0, 0, 0.1));

        return cell
    end

    local function numberOfCellsInTableView(tableView)
        local count = #accountList
        return count
    end

    local function tableCellHighlight(tableView, heightCell)
    end

    local tableView = cc.TableView:create(size)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(0, 0))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)

    tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom,cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(tableCellHighlight,cc.TABLECELL_HIGH_LIGHT)
    tableView:reloadData()

    layer:addChild(tableView)
end

function LoginLayer:showRetrievePassword(accountName, closeCallback)
    local layer = cc.Layer:create()
    self:addChild(layer)

    local function onTouchBegan(touch, event)
        local target = layer
        local pos = target:getParent():convertToNodeSpace(touch:getLocation())
        local box = target:getBoundingBox()

        --CCLog(vardump({box = box, pos = pos}))
        if cc.rectContainsPoint(box, pos) then
            return true
        else
            return false
        end
    end

    local function onTouchEnded(touch, event)
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)

    local bgsize = cc.size(569, 400)

    local bg = cc.Node:create()
    bg:setAnchorPoint(cc.p(0.5, 0.5))
    bg:setContentSize(bgsize)
    bg:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)
    layer:addChild(bg)

    local bgSprite = cc.Scale9Sprite:create("image/ui/img/btn/btn_1357.png")
    bgSprite:setContentSize(bgsize)
    bgSprite:setPosition(bgsize.width / 2, bgsize.height / 2)
    bg:addChild(bgSprite)

    local titleBgSize = cc.size(569, 54)
    local titleBg = cc.Scale9Sprite:create("image/ui/img/btn/btn_1362.png")
    titleBg:setContentSize(titleBgSize)
    titleBg:setPosition(cc.p(bgsize.width / 2, bgsize.height - titleBgSize.height / 2))
    bg:addChild(titleBg)

    local title = Common.finalFont("找回密码",bgsize.width*0.5, bgsize.height - 30, 24)
    bg:addChild(title)

    local accountNode = cc.Node:create()
    accountNode:setAnchorPoint(cc.p(0.5, 0.5))
    accountNode:setContentSize(cc.size(569, 59))
    accountNode:setPosition(cc.p(bgsize.width / 2, bgsize.height * 0.7))
    bg:addChild(accountNode)

    local labelAccountTitle = Common.finalFont("确定帐号",bgsize.width*0.2, 59 / 2,24)
    labelAccountTitle:setColor(cc.c4b(0, 0, 0, 255))
    accountNode:addChild(labelAccountTitle)

    local accountBg = cc.Scale9Sprite:create("image/ui/img/btn/btn_1360.png")
    accountBg:setContentSize(cc.size(350, 59))
    accountBg:setPosition(cc.p(bgsize.width * 0.62, 59 / 2))
    accountNode:addChild(accountBg)

    local labelAccount = Common.finalFont(accountName, bgsize.width*0.35, 59 / 2, 24)
    labelAccount:setAnchorPoint(cc.p(0, 0.5))
    accountNode:addChild(labelAccount)

    local labelDesc = Common.finalFont("击出找回密码，系统将发送一组新的密码至\n您的邮箱，登录成功后请及时更新密码", bgsize.width * 0.5, bgsize.height * 0.5, 24)
    labelDesc:setColor(cc.c4b(0, 0, 0, 255))
    bg:addChild(labelDesc)

     local btn_return = ccui.MixButton:create("image/ui/img/btn/btn_1358.png")
    btn_return:setTitleText("返回")
    btn_return:setTitleFontSize(27)
    btn_return:setPosition(bgsize.width*0.25, bgsize.height * 0.2)
    bg:addChild(btn_return)
    btn_return:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            layer:removeFromParent()
            closeCallback()
        end
    end)

    local btn_retrieve = ccui.MixButton:create("image/ui/img/btn/btn_1359.png")
    btn_retrieve:setTitleText("找回密码")
    btn_retrieve:setTitleFontSize(27)   
    btn_retrieve:setPosition(bgsize.width*0.75, bgsize.height * 0.2)
    bg:addChild(btn_retrieve)

    local btn_close = ccui.MixButton:create("image/ui/img/btn/btn_1361.png")
    btn_close:setTitleText("确定")
    btn_close:setTitleFontSize(27)
    btn_close:setPosition(bgsize.width*0.5, bgsize.height * 0.2)
    bg:addChild(btn_close)
    btn_close:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            layer:removeFromParent()
            closeCallback()
        end
    end)
    btn_close:setVisible(false)

    local function onSuccess()
        btn_return:setVisible(false)
        btn_retrieve:setVisible(false)
        btn_close:setVisible(true)

        accountNode:removeAllChildren()
        local successIcon = cc.Sprite:create("image/ui/img/btn/btn_1368.png")
        successIcon:setPosition(cc.p(90, 30))
        accountNode:addChild(successIcon)

        local title = Common.finalFont("密码发送成功，请及时登录邮箱", 120, 30, 25)
        title:setAnchorPoint(cc.p(0, 0.5))
        title:setColor(cc.c4b(0, 0, 0, 255))
        accountNode:addChild(title)

        labelDesc:setString("官方QQ群：308381121")
    end

    local function onFail()
        btn_return:setVisible(false)
        btn_retrieve:setVisible(false)
        btn_close:setVisible(true)
        accountNode:removeAllChildren()
        local failIcon = cc.Sprite:create("image/ui/img/btn/btn_1369.png")
        failIcon:setPosition(cc.p(90, 30))
        accountNode:addChild(failIcon)

        local title = Common.finalFont("密码发送失败，请及联系客服MM！",120, 30, 25)
        title:setAnchorPoint(cc.p(0, 0.5))
        title:setColor(cc.c4b(0, 0, 0, 255))
        accountNode:addChild(title)

        labelDesc:setString("官方QQ群：308381121")
    end

    btn_retrieve:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            CCLog("发送邮件")

            local account = AccountHelper.getAccountByDisplayName(accountName)
            if account then
                accountName = account.name
            end

            local url = AccountHelper.RETRIEVE_PASSWORD_URL(accountName)
            http.get(url, function ( resp )
                local reply = json.decode(resp)
                if reply.Code ~= 0 then
                    application:showFlashNotice(reply.Desc)
                    onFail()
                else
                    onSuccess()
                end
            end)
        end
    end)
end

function LoginLayer:showBindAccountConfirm(account, okCallback)
    local layer = cc.Layer:create()
    self:addChild(layer)

    local maskLayer = cc.LayerColor:create(cc.c4b(10, 10, 10, 200))
    layer:addChild(maskLayer, -1)

    local function onTouchBegan(touch, event)
        local target = layer
        local pos = target:getParent():convertToNodeSpace(touch:getLocation())
        local box = target:getBoundingBox()

        --CCLog(vardump({box = box, pos = pos}))
        if cc.rectContainsPoint(box, pos) then
            return true
        else
            return false
        end
    end

    local function onTouchEnded(touch, event)
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)

    local bgsize = cc.size(569, 400)

    local bg = cc.Node:create()
    bg:setAnchorPoint(cc.p(0.5, 0.5))
    bg:setContentSize(bgsize)
    bg:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)
    layer:addChild(bg)

    local bgSprite = cc.Scale9Sprite:create("image/ui/img/btn/btn_1357.png")
    bgSprite:setContentSize(bgsize)
    bgSprite:setPosition(bgsize.width / 2, bgsize.height / 2)
    bg:addChild(bgSprite)
    --bgSprite:setBlendFunc(cc.blendFunc(gl.ONE, gl.GL_ONE_MINUS_SRC_ALPHA))

    local titleBgSize = cc.size(569, 54)
    local titleBg = cc.Scale9Sprite:create("image/ui/img/btn/btn_1362.png")
    titleBg:setContentSize(titleBgSize)
    titleBg:setPosition(cc.p(bgsize.width / 2, bgsize.height - titleBgSize.height / 2))
    bg:addChild(titleBg)

    local title = Common.finalFont("找回密码",bgsize.width*0.5, bgsize.height - 30, 24)
    bg:addChild(title)

    local accountName = account.name
    local labelDesc = Common.finalFont("当前帐号为 " .. accountName .. ", 是否与新注册的帐号进行绑定？",bgsize.width*0.5, bgsize.height * 0.6, 25)
    labelDesc:setColor(cc.c4b(0, 0, 0, 255))
    labelDesc:setDimensions(bgsize.width * 0.8, 100)
    bg:addChild(labelDesc)

     local btn_return = ccui.MixButton:create("image/ui/img/btn/btn_818.png")
    btn_return:setTitleText("返回")
    btn_return:setScale9Enabled(true)
    btn_return:setContentSize(cc.size(150, 65))
    btn_return:setTitleFontSize(27)
    btn_return:setPosition(bgsize.width*0.25, bgsize.height * 0.2)
    bg:addChild(btn_return)
    btn_return:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            layer:removeFromParent()
        end
    end)

    local btn_ok = ccui.MixButton:create("image/ui/img/btn/btn_818.png")
    btn_ok:setTitleText("确定")
    btn_ok:setScale9Enabled(true)
    btn_ok:setContentSize(cc.size(150, 65))
    btn_ok:setTitleFontSize(27)   
    btn_ok:setPosition(bgsize.width*0.75, bgsize.height * 0.2)
    bg:addChild(btn_ok)
    btn_ok:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            layer:removeFromParent()
            okCallback()
        end
    end)
end

function LoginLayer:showSignUp( func )
    -- 直接弹出帐号登陆界面，渣渣用户体验
    -- 这个地方后期应换成第三方平台sdk提供的注册登录界面

    local login_result = false
    local login_account = nil
    local recentServer = nil

    self.btn_switch:setVisible(false)

    local layer = cc.Layer:create()
    self:addChild(layer)

    local bgsize = cc.size(569, 547)

    local bg = cc.Node:create()
    bg:setAnchorPoint(cc.p(0.5, 0.5))
    bg:setContentSize(bgsize)
    bg:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)
    layer:addChild(bg)

    local bgSprite = cc.Scale9Sprite:create("image/ui/img/btn/btn_1357.png")
    bgSprite:setContentSize(bgsize)
    bgSprite:setPosition(bgsize.width / 2, bgsize.height / 2)
    bg:addChild(bgSprite)

    local titleBgSize = cc.size(569, 54)
    local titleBg = cc.Scale9Sprite:create("image/ui/img/btn/btn_1362.png")
    titleBg:setContentSize(titleBgSize)
    titleBg:setPosition(cc.p(bgsize.width / 2, bgsize.height - titleBgSize.height / 2))
    bg:addChild(titleBg)

    local title = Common.finalFont("请选择登录方式",bgsize.width*0.5, 520, 30)
    bg:addChild(title)

    local accountNodeSize = cc.size(489, 59)
    local accountNode = cc.Node:create()
    accountNode:setAnchorPoint(cc.p(0.5, 0.5))
    accountNode:setPosition(cc.p(bgsize.width / 2, 417))
    accountNode:setContentSize(accountNodeSize)
    bg:addChild(accountNode)

    local accountBg = cc.Scale9Sprite:create("image/ui/img/btn/btn_1360.png")
    accountBg:setContentSize(accountNodeSize)
    accountBg:setPosition(cc.p(accountNodeSize.width / 2, accountNodeSize.height / 2))
    accountNode:addChild(accountBg)

    local accountIcon = cc.Sprite:create("image/ui/img/btn/btn_1367.png")
    accountIcon:setPosition(cc.p(25, accountNodeSize.height / 2))
    accountNode:addChild(accountIcon)

    local labelAccountTitle = Common.finalFont("帐号", 80, accountNodeSize.height / 2, 25)
    accountNode:addChild(labelAccountTitle)

    local size = cc.size(280,35)
    local edit_account = ccui.EditBox:create(size, ccui.Scale9Sprite:create())
    -- local edit_account = ccui.TextField:create()
    edit_account:setTouchEnabled(true)
    edit_account:ignoreContentAdaptWithSize(false)
    edit_account:setPlaceHolder("4-8位英文或数字")
    -- edit_account:setContentSize(size)
    edit_account:setFontSize(25)
    -- edit_account:setMaxLengthEnabled(true)
    edit_account:setMaxLength(20)
    edit_account:setFontName("DFYuanW7-GBK")
    -- edit_account:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    -- edit_account:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    edit_account:setPosition(accountNodeSize.width / 2, accountNodeSize.height / 2)
    accountNode:addChild(edit_account)

    local labelAccountStar = Common.finalFont("*", accountNodeSize.width + 10, accountNodeSize.height / 2, 20, cc.c4b(255, 0, 0, 255))
    accountNode:addChild(labelAccountStar)
    labelAccountStar:setVisible(false)

    local size = edit_account:getContentSize()
    local label_listAccount = cc.Sprite:create("image/ui/img/btn/btn_1372.png")
    label_listAccount:setPosition(cc.p(accountNodeSize.width / 2 + 185, accountNodeSize.height / 2))
    accountNode:addChild(label_listAccount, 1)

    local edit_password
    do
        local function onTouchBegan(touch, event)
            local target = label_listAccount
            local pos = target:getParent():convertToNodeSpace(touch:getLocation())
            local box = target:getBoundingBox()

            --CCLog(vardump({box = box, pos = pos}))
            if target:isVisible() and cc.rectContainsPoint(box, pos) and self:getChildByName("account_list_layer") == nil then
                return true
            else
                return false
            end
        end

        local function onTouchEnded(touch, event)
            local accountList = AccountHelper.getAccountList()
            CCLog(vardump(accountList))

            local onItemSelected = function(account)
                edit_account:setText(account.displayName)
                edit_password:setText("")
            end

            local onClearAll = function()
                edit_account:setText("")
                edit_password:setText("")
            end
            self:showAccountList(accountList, onItemSelected, onClearAll)
        end
        local listener = cc.EventListenerTouchOneByOne:create()
        listener:setSwallowTouches(true)
        listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
        listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
        local eventDispatcher = self:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, label_listAccount)
    end

    -- local btn_accountList = ccui.MixButton:create("dummy/signup.png")
    -- btn_accountList:setTouchEnabled(true)
    -- btn_accountList:setPosition(330 + 280,417)
    -- bg:addChild(btn_accountList)
    -- btn_accountList:addTouchEventListener(function ( sender, eventType )
    --     if eventType == ccui.TouchEventType.ended then
    --         local accountList = getAccountList()
    --         CCLog(vardump(accountList))
    --         self:showAccountList(accountList)
    --     end
    -- end)

    local passwordNodeSize = cc.size(489, 59)
    local passwordNode = cc.Node:create()
    passwordNode:setAnchorPoint(cc.p(0.5, 0.5))
    passwordNode:setPosition(cc.p(bgsize.width / 2, 340))
    passwordNode:setContentSize(passwordNodeSize)
    bg:addChild(passwordNode)

    local passwordBg = cc.Scale9Sprite:create("image/ui/img/btn/btn_1360.png")
    passwordBg:setContentSize(passwordNodeSize)
    passwordBg:setPosition(cc.p(passwordNodeSize.width / 2, passwordNodeSize.height / 2))
    passwordNode:addChild(passwordBg)

    local passwordIcon = cc.Sprite:create("image/ui/img/btn/btn_1366.png")
    passwordIcon:setPosition(cc.p(25, passwordNodeSize.height / 2))
    passwordNode:addChild(passwordIcon)

    local labelPasswordTitle = Common.finalFont("密码", 80, passwordNodeSize.height / 2, 25)
    passwordNode:addChild(labelPasswordTitle)

    edit_password = ccui.EditBox:create(size, ccui.Scale9Sprite:create())
    -- local edit_account = ccui.TextField:create()
    edit_password:setTouchEnabled(true)
    edit_password:ignoreContentAdaptWithSize(false)
    edit_password:setPlaceHolder("6-16位英文或数字")
    --edit_password:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    -- edit_account:setContentSize(size)
    edit_password:setFontSize(25)
    -- edit_account:setMaxLengthEnabled(true)
    edit_password:setMaxLength(20)
    edit_password:setFontName("DFYuanW7-GBK")
    -- edit_account:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    -- edit_account:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    edit_password:setPosition(passwordNodeSize.width / 2, passwordNodeSize.height / 2)
    edit_password:setName("edit_password_show")
    passwordNode:addChild(edit_password)

    local labelPasswordStar = Common.finalFont("*", passwordNodeSize.width + 10, passwordNodeSize.height / 2, 20, cc.c4b(255, 0, 0, 255))
    passwordNode:addChild(labelPasswordStar)
    labelPasswordStar:setVisible(false)

    local function switchEditPasswordShow(button)
        if edit_password:getName() == "edit_password_show" then
            button:loadTextureNormal("image/ui/img/btn/btn_1376.png")            

            local text = edit_password:getText()
            edit_password:removeFromParent()

            edit_password = ccui.EditBox:create(size, ccui.Scale9Sprite:create())
            -- local edit_account = ccui.TextField:create()
            edit_password:setTouchEnabled(true)
            edit_password:ignoreContentAdaptWithSize(false)
            edit_password:setPlaceHolder("6-16位英文或数字")
            edit_password:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
            -- edit_account:setContentSize(size)
            edit_password:setFontSize(25)
            -- edit_account:setMaxLengthEnabled(true)
            edit_password:setMaxLength(20)
            edit_password:setFontName("DFYuanW7-GBK")
            -- edit_account:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
            -- edit_account:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
            edit_password:setPosition(passwordNodeSize.width / 2, passwordNodeSize.height / 2)
            edit_password:setName("edit_password_hide")
            edit_password:setText(text)
            passwordNode:addChild(edit_password)
        else
            button:loadTextureNormal("image/ui/img/btn/btn_1364.png")

            local text = edit_password:getText()
            edit_password:removeFromParent()

            edit_password = ccui.EditBox:create(size, ccui.Scale9Sprite:create())
            -- local edit_account = ccui.TextField:create()
            edit_password:setTouchEnabled(true)
            edit_password:ignoreContentAdaptWithSize(false)
            edit_password:setPlaceHolder("6-16位英文或数字")
            --edit_password:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
            -- edit_account:setContentSize(size)
            edit_password:setFontSize(25)
            -- edit_account:setMaxLengthEnabled(true)
            edit_password:setMaxLength(20)
            edit_password:setFontName("DFYuanW7-GBK")
            -- edit_account:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
            -- edit_account:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
            edit_password:setPosition(passwordNodeSize.width / 2, passwordNodeSize.height / 2)
            edit_password:setName("edit_password_show")
            edit_password:setText(text)
            passwordNode:addChild(edit_password)
        end
    end

    local size = edit_password:getContentSize()
    local label_retrievePassword = Common.finalFont("找回密码", 0 , 0 , 24, cc.c3b(255, 255, 255), 1)
    label_retrievePassword:setAnchorPoint(cc.p(0.5, 0.5))
    label_retrievePassword:setColor(cc.c3b(200, 220, 30))
    label_retrievePassword:setPosition(cc.p(passwordNodeSize.width / 2 + 175, -passwordNodeSize.height / 2))
    passwordNode:addChild(label_retrievePassword, 1)

    local btn_show_password = ccui.MixButton:create("image/ui/img/btn/btn_1364.png")
    btn_show_password:setTitleText("")
    btn_show_password:setPosition(cc.p(passwordNodeSize.width / 2 + 185, passwordNodeSize.height / 2))
    passwordNode:addChild(btn_show_password, 1)
    --btn_show_password:setVisible(false)

    btn_show_password:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            CCLog("切换密码显示")
            switchEditPasswordShow(btn_show_password)
        end
    end)

    local mailboxNodeSize = cc.size(489, 59)
    local mailboxNode = cc.Node:create()
    mailboxNode:setAnchorPoint(cc.p(0.5, 0.5))
    mailboxNode:setPosition(cc.p(bgsize.width / 2, 263))
    mailboxNode:setContentSize(mailboxNodeSize)
    bg:addChild(mailboxNode)
    mailboxNode:setVisible(false)

    local mailboxBg = cc.Scale9Sprite:create("image/ui/img/btn/btn_1360.png")
    mailboxBg:setContentSize(cc.size(489, 59))
    mailboxBg:setPosition(cc.p(mailboxNodeSize.width / 2, mailboxNodeSize.height / 2))
    mailboxNode:addChild(mailboxBg)

    local mailboxIcon = cc.Sprite:create("image/ui/img/btn/btn_1365.png")
    mailboxIcon:setPosition(cc.p(25, mailboxNodeSize.height / 2))
    mailboxNode:addChild(mailboxIcon)

    local labelMailboxTitle = Common.finalFont("邮箱", 80, mailboxNodeSize.height / 2, 25)
    mailboxNode:addChild(labelMailboxTitle)

    local edit_mailbox = ccui.EditBox:create(size, ccui.Scale9Sprite:create())
    -- local edit_account = ccui.TextField:create()
    edit_mailbox:setTouchEnabled(true)
    edit_mailbox:ignoreContentAdaptWithSize(false)
    edit_mailbox:setPlaceHolder("邮箱")
    -- edit_account:setContentSize(size)
    edit_mailbox:setFontSize(25)
    -- edit_account:setMaxLengthEnabled(true)
    edit_mailbox:setMaxLength(40)
    edit_mailbox:setFontName("DFYuanW7-GBK")
    -- edit_account:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    -- edit_account:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    edit_mailbox:setPosition(mailboxNodeSize.width / 2, mailboxNodeSize.height / 2)
    mailboxNode:addChild(edit_mailbox)

    self.data.Account = AccountHelper.getLastLoginAccount()
    if self.data.Account ~= nil then
        edit_account:setText(self.data.Account.displayName)
    end

    local labelDesc = Common.finalFont("输入邮箱提升帐号安全，请务必填写真实邮箱！", bgsize.width * 0.5, 170, 20)
    labelDesc:setAnchorPoint(cc.p(0.5, 0.5))
    labelDesc:setColor(cc.c4b(0, 0, 0, 255))
    labelDesc:setDimensions(bgsize.width * 0.8, 100)
    bg:addChild(labelDesc)
    labelDesc:setVisible(false)

    local labelHint = Common.finalFont("带*的内容必须填写", bgsize.width * 0.5, 140, 18)
    labelHint:setAnchorPoint(cc.p(0.5, 0.5))
    labelHint:setColor(cc.c4b(255, 0, 0, 255))
    labelHint:setDimensions(bgsize.width * 0.4, 100)
    bg:addChild(labelHint)
    labelHint:setVisible(false)

    local btn_signup = ccui.MixButton:create("image/ui/img/btn/btn_1358.png")
    btn_signup:setTitleText("注册")
    btn_signup:setTitleFontSize(27)

    local btn_signin = ccui.MixButton:create("image/ui/img/btn/btn_1359.png")
    btn_signin:setTitleText("登录")
    btn_signin:setTitleFontSize(27)

    --local btn_quick = ccui.MixButton:create("dummy/quickstart.png")
    local btn_signup_ok = ccui.MixButton:create("image/ui/img/btn/btn_1361.png")
    btn_signup_ok:setTitleText("确定注册")
    btn_signup_ok:setScale9Enabled(true)
    btn_signup_ok:setContentSize(cc.size(491, 72))
    btn_signup_ok:setTitleFontSize(27)

    local btn_back = ccui.MixButton:create("dummy/back.png")
    local btn_quit = ccui.MixButton:create("dummy/back.png")

    local function switchToSignUp( visible )
        if visible then
            title:setString("注册帐号")
            edit_account:setText("")
            edit_password:setText("")
        else
            title:setString("请选择登录方式")

            if self.data.Account ~= nil then
                edit_account:setText(self.data.Account.displayName)
            end
            edit_password:setText("")
            edit_mailbox:setText("")
        end

        label_listAccount:setVisible(not visible)
        label_retrievePassword:setVisible(not visible)

        btn_signup:setVisible(not visible)
        btn_signin:setVisible(not visible)

        --btn_quick:setVisible(visible)
        btn_signup_ok:setVisible(visible)
        btn_back:setVisible(visible)
        btn_quit:setVisible(not visible)
        mailboxNode:setVisible(visible)
        --btn_show_password:setVisible(visible)
        labelDesc:setVisible(visible)
        labelHint:setVisible(visible)
        labelAccountStar:setVisible(visible)
        labelPasswordStar:setVisible(visible)
    end


    btn_signup_ok:setPosition(bgsize.width*0.5,120)
    btn_signup_ok:setVisible(false)
    bg:addChild(btn_signup_ok)
    btn_signup_ok:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            local accountName = edit_account:getText()
            accountName = string.trim(accountName)
            if not AccountHelper.checkAccountName(accountName) then
                application:showFlashNotice("账号格式错误，请重新输入")
                return
            end

            local password = edit_password:getText()
            if not AccountHelper.checkPassword(password) then
                application:showFlashNotice("密码格式错误，请重新输入")
                return
            end
            password = libmd5.hex(password)

            local email = edit_mailbox:getText()
            if #email > 0 then
                if not AccountHelper.isRightEmail(email) then
                    application:showFlashNotice("邮箱地址格式错误，请重新输入")
                    return
                end
            end
            
            local url 
            local account = GameCache.LoginAccount
            local is_binding_account = false
            if account and account.guest then
                url = AccountHelper.BIND_GUEST_URL({name = accountName, password = password, email = email, guest = account.name}, KEY)
                is_binding_account = true
            else
                url = AccountHelper.REGISTER_URL({name = accountName, password = password, email = email, guest = false})
            end

            CCLog(url)
            http.get(url, function ( resp )
                CCLog("response:", resp)
                local reply = json.decode(resp)
                if reply.Code ~= 0 then
                    application:showFlashNotice("注册失败，请重新输入帐户")
                    return
                end

                -- binding
                if is_binding_account then
                    AccountHelper.deleteAccount(account)
                    AccountHelper.updateLastLoginAccount({name = accountName, password = password, guest = false})
                else
                    AccountHelper.updateLastLoginAccount({name = accountName, password = password, guest = false})
                end

                local url = AccountHelper.LOGIN_URL({name = accountName, password = password, guest = false})
                CCLog(url)
                http.get(url, function ( response )
                    local rep = json.decode(response)
                    if rep.Code ~= 0 then
                        application:showFlashNotice("登录失败，请重新登录")
                        return
                    end

                    recentServer = rep.Result.Suggest
                    KEY = rep.Result.Key
                    login_result = true

                    func(login_result, {name = accountName, password = password, guest = false}, recentServer)

                    layer:removeFromParent()
                    layer = nil
                end)
            end)
        end
    end)

    btn_back:setPosition(bgsize.width*0.15,515)
    btn_back:setVisible(false)
    bg:addChild(btn_back)
    btn_back:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            switchToSignUp(false)
        end
    end)

    btn_quit:setPosition(bgsize.width*0.15,515)
    btn_quit:setVisible(true)
    bg:addChild(btn_quit)
    btn_quit:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            self.btn_switch:setVisible(true)
            layer:removeFromParent()
        end
    end)

    btn_signup:setPosition(bgsize.width*0.25,150)
    bg:addChild(btn_signup)
    btn_signup:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            local accountName = edit_account:getText()
            accountName = string.trim(accountName)     
            local account = AccountHelper.getAccountByDisplayName(accountName)
            if account and account.guest then
                self.data.Account = account
                self:showBindAccountConfirm(account, function() switchToSignUp(true) end)
            else
                self.data.Account = nil
                switchToSignUp(true)
            end
        end
    end)


    btn_signin:setPosition(bgsize.width*0.75,150)
    bg:addChild(btn_signin)
    btn_signin:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            local str = edit_account:getText()
            str = string.trim(str)

            local accountName = str

            local account = AccountHelper.getAccountByDisplayName(accountName)
            if account and account.guest then                
                CCLog(vardump(account))

                local url = AccountHelper.LOGIN_URL(account)
                CCLog(url)
                http.get(url, function ( response )
                    local rep = json.decode(response)
                    if rep.Code ~= 0 then
                        application:showFlashNotice("账号或密码输入错误，请重新输入")
                        return
                    end

                    recentServer = rep.Result.Suggest
                    KEY = rep.Result.Key
                    login_result = true

                    func(login_result, account, recentServer)

                    layer:removeFromParent()
                    layer = nil
                end)

            else
                if not AccountHelper.checkAccountName(accountName) then
                    application:showFlashNotice("账号格式错误，请重新输入")
                    return
                end

                local str = edit_password:getText()
                if not AccountHelper.checkPassword(str) then
                    application:showFlashNotice("密码格式错误，请重新输入")
                    return
                end
                local password = libmd5.hex(str)

                local url = AccountHelper.LOGIN_URL({name = accountName, password = password, guest = false})
                CCLog(url)
                http.get(url, function ( response )
                    local rep = json.decode(response)
                    if rep.Code ~= 0 then
                        application:showFlashNotice("账号或密码输入错误，请重新输入")
                        return
                    end

                    recentServer = rep.Result.Suggest
                    KEY = rep.Result.Key
                    login_result = true
                    login_account = account

                    func(login_result, {name = accountName, password = password, guest = false}, recentServer)

                    layer:removeFromParent()
                    layer = nil
                end)
            end
        end
    end)

    local function onTouchBegan(touch, event)
        return true
    end

    local function onTouchEnded(touch, event)
    -- local target = event:getCurrentTarget()
    -- local locationInNode = bg:convertToNodeSpace(touch:getLocation())
    -- local s = bg:getContentSize()
    -- local rect = cc.rect(0, 0, s.width, s.height)

    -- if not cc.rectContainsPoint(rect, locationInNode) then
    --     layer:removeFromParent()
    --     layer = nil

    -- end
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)

    do 
        local function onTouchBegan(touch, event)
            local target = label_retrievePassword
            local pos = target:getParent():convertToNodeSpace(touch:getLocation())
            local box = target:getBoundingBox()

            if target:isVisible() and cc.rectContainsPoint(box, pos) then
                return true
            else
                return false
            end
        end

        local function onTouchEnded(touch, event)
            CCLog("找回密码")
            local accountName = edit_account:getText()
            accountName = string.trim(accountName)

            local account = AccountHelper.getAccountByDisplayName(accountName)

            if not (account and account.guest) then
                if not AccountHelper.checkAccountName(accountName) then
                    application:showFlashNotice("账号格式错误，请重新输入")
                    return
                end        
            end   

            layer:setVisible(false)
            self:showRetrievePassword(accountName, function()
                layer:setVisible(true)
            end)
        end
        local listener = cc.EventListenerTouchOneByOne:create()
        listener:setSwallowTouches(true)
        listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
        listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
        local eventDispatcher = self:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, label_retrievePassword)
    end
end

function LoginLayer:createLoginGameLayer( )
    -- 1.创建登录界面
    -- 2.检测本地帐户，自动登录或者弹出注册即登录界面和快速登录（第三方sdk），并获取最近登录服务器
    -- 3.开始游戏

    local layer = cc.Layer:create()
    self:addChild(layer)

    local bg_ani = load_animation("image/spine/ui_effect/51", 1)
    bg_ani:setAnimation(0,"animation", true)
    bg_ani:setTimeScale(0.5)
    bg_ani:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)
    layer:addChild(bg_ani)

    local VersionCheckLayer = require("scene.update.VersionCheckLayer")
    local progressBarPos = cc.p(SCREEN_WIDTH*0.5, 230)

    local version = GetUpdatedVersion()

    local labelVersion = Common.finalFont("版本号:" .. version, 0 , 0 , 18, cc.c3b(255, 255, 255), 1)
    labelVersion:setAnchorPoint(cc.p(1, 0.5))
    labelVersion:setColor(cc.c3b(223, 188, 30))
    labelVersion:setPosition(SCREEN_WIDTH - 5, 40)
    layer:addChild(labelVersion, 1)

    local codeVer = CodeVersion()
    local labelCodeVersion = Common.systemFont(codeVer, 0, 0, 16)
    -- local labelCodeVersion = Common.systemFont(CodeVersion(), 0 , 0 , 14, cc.c3b(255, 255, 255), 0)
    labelCodeVersion:setAnchorPoint(cc.p(1, 0))
    labelCodeVersion:setColor(cc.c3b(255, 255, 255))
    labelCodeVersion:setPosition(cc.p(SCREEN_WIDTH - 5, 3))
    layer:addChild(labelCodeVersion, 1)

    local title = cc.Sprite:create("image/ui/img/bg/bg_06_logo.png")
    -- title:setScale(0.8)
    title:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5+140)
    layer:addChild(title)

    -- local k = getAccountNameFullKey()
    -- self.data.Account = cc.UserDefault:getInstance():getStringForKey(k)
    local accountName = ""
    self.data.Account = AccountHelper.getLastLoginAccount()
    if self.data.Account then
        accountName = self.data.Account.displayName
    end
    CCLog("account: ", vardump(self.data.Account))

    local label_account = Common.finalFont("" .. accountName , 0, 0, 16, nil, 1)
    label_account:setColor(cc.c3b(255, 234, 0))
    label_account:setPosition(cc.p(SCREEN_WIDTH * 0.5, 280))
    layer:addChild(label_account)
    self.label_account = label_account

    local editbg = ccui.MixButton:create("image/ui/img/btn/btn_969.png")
    editbg:setTouchEnabled(false)
    editbg:setPosition(SCREEN_WIDTH*0.5, 230)
    layer:addChild(editbg)
    editbg:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            local major = GetAppVersion()
            local patch = GetUpdatedVersion()
            local url = string.format("%s/servers?key=%s&major=%s&patch=%s", LOGIN_SERVER_ADDR, KEY, major, patch) 

            local requestServerList
            requestServerList = function()
                http.get(url, 
                function ( resp )
                    release_print(resp)
                    local reply = json.decode(resp)
                    CCLog(resp)

                    if reply.Result then
                        self:showServerList(reply.Result)
                    else
                        require("tool.helper.CommonLayer").AlertPanel("上仙，貌似您的网络不太给力，\n连接不到服务器，请重新尝试", function() 
                            switchLoginServerAddress()
                            requestServerList()
                        end)
                    end
                end, 
                function(err)
                    require("tool.helper.CommonLayer").AlertPanel("上仙，貌似您的网络不太给力，\n连接不到服务器，请重新尝试", function() 
                        switchLoginServerAddress()
                        requestServerList()
                    end)
                end)
            end

            requestServerList()
        end
    end)
    self.btn_changeserver = editbg

    local editsize = editbg:getContentSize()

    local label_state = Common.finalFont("" , editsize.width*0.15 , editsize.height*0.5, 16)
    editbg:addChild(label_state)
    self.label_state = label_state

    local label_servername = Common.finalFont("" , editsize.width*0.5 , editsize.height*0.5, 20)
    editbg:addChild(label_servername)
    self.label_servername = label_servername

    local label = Common.finalFont("点击选区" , editsize.width*0.8 , editsize.height*0.5, 16)
    editbg:addChild(label)

    local agreement = true
    local btn_agreement = ccui.MixButton:create("image/ui/img/btn/btn_1134.png")
    btn_agreement:setChild("image/ui/img/btn/btn_502.png")
    btn_agreement:setStateEnabled(true)
    btn_agreement:setPosition(SCREEN_WIDTH*0.5 - 85, 40)
    btn_agreement:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if agreement then
                btn_agreement:removeAllChildren()
                agreement = false
            else
                btn_agreement:setChild("image/ui/img/btn/btn_502.png")
                agreement = true
            end
        end
    end)
    btn_agreement:setScale(0.8)
    layer:addChild(btn_agreement)

    local function registerTouchHandler(node, handler)
        local function onTouchBegan(touch, event)
            local target = node
            local pos = target:getParent():convertToNodeSpace(touch:getLocation())
            local box = target:getBoundingBox()

            if target:isVisible() and cc.rectContainsPoint(box, pos) then
                return true
            else
                return false
            end
        end

        local function onTouchEnded(touch, event)
            local target = node
            local pos = target:getParent():convertToNodeSpace(touch:getLocation())
            local box = target:getBoundingBox()

            --CCLog(vardump({box = box, pos = pos}))
            if cc.rectContainsPoint(box, pos) then
                handler()
            end
        end

        local listener = cc.EventListenerTouchOneByOne:create()
        listener:setSwallowTouches(true)
        listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
        listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
        local eventDispatcher = self:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, node)
    end

    local label_agreement = Common.finalFont("阅读并同意用户协议", SCREEN_WIDTH*0.5 + 30, 40, 20)
    label_agreement:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    label_agreement:setColor(cc.c4b(255,250,205, 255)) 
    label_agreement:setAnchorPoint(cc.p(0.5, 0.5))
    layer:addChild(label_agreement)
    local lsize = label_agreement:getContentSize()
    local lposX = SCREEN_WIDTH*0.5 + 30
    local drawNode = cc.DrawNode:create()
    layer:addChild(drawNode)
    drawNode:drawLine(cc.p(lposX - lsize.width / 2, 28), cc.p(lposX + lsize.width / 2, 28), cc.c4f(255 / 255, 250 / 255, 205 / 255, 0.6));

    registerTouchHandler(label_agreement, function()
        local agreement = cc.FileUtils:getInstance():getStringFromFile("agreement.txt")
        self:showAgreement({Title = "用户协议", Content = agreement})
    end)

    local btn_start = ccui.MixButton:create("image/ui/img/btn/btn_970.png")
    btn_start:setChild("image/ui/img/btn/btn_971.png")
    btn_start:setStateEnabled(false)
    btn_start:setPosition(SCREEN_WIDTH*0.5, 130)
    btn_start:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if not agreement then
                application:showFlashNotice("必须同意用户协议才能继续！")
                return
            end

            local addr = self.data.recentServer.Addr
            local sid = self.data.recentServer.SID
            CCLog("addr: ", addr)

            GameCache["ServerName"] = self.data.recentServer.Name

            if sid == 500 then
                GameCache.isExamine = true
            end

            self:loginGame(addr, KEY, sid)
            btn_start:setStateEnabled(false)
        end
    end)
    self.btn_start = btn_start
    layer:addChild(btn_start)

    local start_texiao = EffectManager:CreateAnimation(layer,SCREEN_WIDTH*0.5, 130,nil, 3, true )

    local btn_switch = ccui.MixButton:create("image/ui/img/btn/btn_918.png")
    btn_switch:setChild("image/ui/img/btn/btn_1013.png", 0.17, 0.75)
    btn_switch:setTitle("切换帐号", 22, cc.c3b(255,250,205))
    btn_switch:setTitlePos(0.62,0.5)
    btn_switch:setPosition(SCREEN_WIDTH-100, SCREEN_HEIGHT-100)
    layer:addChild(btn_switch)
    btn_switch:setVisible(false)
    self.btn_switch = btn_switch
    btn_switch:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            if GAME_BASE_INFO.SDK then
                self.doSDKLogin()
            else
                self:showSignUp(function ( login_result, login_account, recentServer )
                    if login_result then
                        --local k = getAccountNameFullKey()
                        --cc.UserDefault:getInstance():setStringForKey(k, login_account)
                        GameCache.LoginAccount = login_account
                        GameCache.LoginKey = KEY

                        AccountHelper.updateLastLoginAccount(login_account)
                        self.label_account:setString(login_account.displayName)
                        self.data.recentServer = recentServer
                        label_servername:setString(self.data.recentServer.Name)
                        label_state:setString(SERVER_STATUS_TEXT[self.data.recentServer.Status])
                        label_state:setColor(SERVER_STATUS_COLOR[self.data.recentServer.Status])
                        local stateEnable = (self.data.recentServer.Status ~= "maintain" and self.data.recentServer.Status ~= "stop")
                        btn_start:setStateEnabled(stateEnable)
                        editbg:setTouchEnabled(true)
                        btn_switch:setVisible(true)
                    end
                end)
            end
        end
    end)
end

function LoginLayer:showServerList( result )
    if not result then
        return
    end

    -- dump(result)

    local layer = cc.Layer:create()
    self:addChild(layer)

    local bgsize = cc.size(858,584)
    local bg = ccui.ImageView:create("image/ui/img/bg/bg_139.png")
    bg:setPosition(SCREEN_WIDTH*0.5,SCREEN_HEIGHT*0.5)
    bg:setScale9Enabled(true)
    bg:setContentSize(bgsize)
    layer:addChild(bg)

    local huawen = cc.Sprite:create("image/ui/img/btn/btn_609.png")
    huawen:setPosition(bgsize.width*0.5, bgsize.height*0.5)
    bg:addChild(huawen)

    local lastServers = result.Recent or {}
    local allServers = result.All
    local tempAllServers = {}
    for k,v in pairs(allServers) do
        tempAllServers[v.SID] = v
    end


    local height1 = math.ceil(#lastServers/3)*90
    local height2 = math.ceil(#allServers/3)*90

    if #lastServers == 0 then
        height1 = 50
    end

    local height = height1 + height2 + 2 * 95

    if height < bgsize.height-60 then
        height = bgsize.height-60
    end

    local scrollview = ccui.ScrollView:create()
    scrollview:setTouchEnabled(true)
    scrollview:setContentSize(cc.size(bgsize.width, bgsize.height-60))
    scrollview:setDirection(ccui.ScrollViewDir.vertical)
    scrollview:setInnerContainerSize(cc.size(bgsize.width, height))
    scrollview:setPosition(0,30)
    bg:addChild(scrollview)


    local createTitle = function (x,y ,title )
        local ssize = cc.size(837,75)
        local sprite = ccui.ImageView:create("image/ui/img/btn/btn_811.png")
        sprite:setScale9Enabled(true)
        sprite:setContentSize(ssize)
        sprite:setPosition(x,y)
        sprite:setAnchorPoint(0.5,1)

        local line1 = cc.Sprite:create("image/ui/img/btn/btn_810.png")
        line1:setPosition(ssize.width*0.5, ssize.height)
        line1:setScaleX(2)
        sprite:addChild(line1)
        local line = cc.Sprite:create("image/ui/img/btn/btn_810.png")
        line:setPosition(ssize.width*0.5, 0)
        line:setScaleX(2)
        sprite:addChild(line)

        local yunwen1 = cc.Sprite:create("image/ui/img/btn/btn_604.png")
        yunwen1:setPosition(ssize.width*0.15, ssize.height*0.5)
        sprite:addChild(yunwen1)
        local yunwen = cc.Sprite:create("image/ui/img/btn/btn_604.png")
        yunwen:setPosition(ssize.width*0.85, ssize.height*0.5)
        yunwen:setFlippedX(true)
        sprite:addChild(yunwen)

        local title_image = cc.Sprite:create("image/ui/img/btn/btn_608.png")
        title_image:setPosition(ssize.width*0.5, ssize.height*0.5)
        sprite:addChild(title_image)

        local titlesize = title_image:getContentSize()
        local point1 = cc.Sprite:create("image/ui/img/btn/btn_652.png")
        point1:setPosition(titlesize.width*0.25, titlesize.height*0.5)
        title_image:addChild(point1)

        local point2 = cc.Sprite:create("image/ui/img/btn/btn_652.png")
        point2:setPosition(titlesize.width*0.75, titlesize.height*0.5)
        title_image:addChild(point2)

        -- local title = Common.finalFont(title , ssize.width*0.5 , ssize.height*0.5, 22, cc.c3b(245,222,13))
        local title = cc.Sprite:create(title)
        title:setPosition(ssize.width*0.5, ssize.height*0.5)
        sprite:addChild(title)

        return sprite
    end

    local title1 = createTitle(bgsize.width*0.5, height, "image/ui/img/btn/btn_1015.png")
    scrollview:addChild(title1)


    local deltaY = title1:getContentSize().height+50
    local _y = 0
    for i=0,#lastServers-1 do
        local id = lastServers[i+1]
        local x = ((i % 3) *0.32 + 0.18)*bgsize.width
        local y = math.floor(i/3) * 90 + deltaY
        _y = y
        local icon = ccui.MixButton:create("image/ui/img/bg/bg_264.png")
        icon:setPosition(x, height-y)
        scrollview:addChild(icon)
        icon:addTouchEventListener(function ( sender, eventType )
            if eventType == ccui.TouchEventType.ended then
                self.data.recentServer = tempAllServers[id]
                self.label_servername:setString(self.data.recentServer.Name)
                self.label_servername:setColor(SERVER_STATUS_COLOR[self.data.recentServer.Status])
                self.label_state:setString(SERVER_STATUS_TEXT[self.data.recentServer.Status])
                self.label_state:setColor(SERVER_STATUS_COLOR[self.data.recentServer.Status])
                self.btn_start:setStateEnabled(true)
                layer:removeFromParent()
                layer = nil
            end
        end)

        local stateEnable = (tempAllServers[id].Status ~= "maintain" and tempAllServers[id].Status ~= "stop")
        icon:setStateEnabled(stateEnable)

        local iconsize = icon:getContentSize()
        local servername = Common.finalFont(tempAllServers[id].Name , iconsize.width*0.5 , iconsize.height*0.5, 22)
        servername:setColor(SERVER_STATUS_COLOR[tempAllServers[id].Status])
        icon:addChild(servername)

        local serverstate = cc.Sprite:create(SERVER_STATUS_IMAGE[tempAllServers[id].Status])
        serverstate:setAnchorPoint(1,1)
        serverstate:setPosition(iconsize.width , iconsize.height)
        icon:addChild(serverstate)

    end

    if #lastServers == 0 then
        _y = 90
    end
    deltaY =  _y + 50
    local title2 = createTitle(bgsize.width*0.5, height-deltaY, "image/ui/img/btn/btn_1014.png")
    scrollview:addChild(title2)

    deltaY = deltaY + title2:getContentSize().height+50
    for i=0,#allServers-1 do
        local x = ((i % 3) *0.32 + 0.18)*bgsize.width
        local y = math.floor(i/3) * 90 + deltaY
        _y = y
        local icon = ccui.MixButton:create("image/ui/img/bg/bg_264.png")
        icon:setPosition(x, height-y)
        scrollview:addChild(icon)
        icon:addTouchEventListener(function ( sender, eventType )
            if eventType == ccui.TouchEventType.ended then
                self.data.recentServer = allServers[i+1]
                self.label_servername:setString(self.data.recentServer.Name)
                self.label_servername:setColor(SERVER_STATUS_COLOR[self.data.recentServer.Status])
                self.label_state:setString(SERVER_STATUS_TEXT[self.data.recentServer.Status])
                self.label_state:setColor(SERVER_STATUS_COLOR[self.data.recentServer.Status])
                self.btn_start:setStateEnabled(true)
                layer:removeFromParent()
                layer = nil
            end
        end)

        local stateEnable = (allServers[i+1].Status ~= "maintain" and allServers[i+1].Status ~= "stop")
        icon:setStateEnabled(stateEnable)

        local iconsize = icon:getContentSize()
        local servername = Common.finalFont(allServers[i+1].Name , iconsize.width*0.5 , iconsize.height*0.5, 22)
        servername:setColor(SERVER_STATUS_COLOR[allServers[i+1].Status])
        icon:addChild(servername)

        local serverstate = cc.Sprite:create(SERVER_STATUS_IMAGE[allServers[i+1].Status])
        serverstate:setAnchorPoint(1,1)
        serverstate:setPosition(iconsize.width , iconsize.height)
        icon:addChild(serverstate)

    end


    local function onTouchBegan(touch, event)
        return true
    end

    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = bg:convertToNodeSpace(touch:getLocation())
        local s = bg:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if not cc.rectContainsPoint(rect, locationInNode) then
            layer:removeFromParent()
            layer = nil

        end
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)
end

-- local code = [====[
-- local self = (...)
-- local notice = {Title = "Hello", Content = "这是一个测试文件"}
-- local noticePanelName = "login_noticePanel"
-- if self:getChildByName(noticePanelName) then
--     return
-- end

-- local layer = cc.Layer:create()
-- layer:setName(noticePanelName)
-- self:addChild(layer)

-- local bgsize = cc.size(895,540)
-- local bg = ccui.ImageView:create("image/ui/img/bg/bg_139.png")
-- bg:setPosition(SCREEN_WIDTH*0.5,SCREEN_HEIGHT*0.5)
-- bg:setScale9Enabled(true)
-- bg:setContentSize(bgsize)
-- layer:addChild(bg)

-- local wen = cc.Sprite:create("image/ui/img/btn/btn_609.png")
-- wen:setPosition(bgsize.width*0.5, bgsize.height*0.5)
-- bg:addChild(wen)

-- local titlebg = cc.Sprite:create("image/ui/img/bg/bg_174.png")
-- titlebg:setPosition(bgsize.width*0.5, bgsize.height-10)
-- bg:addChild(titlebg)

-- local title_image = cc.Sprite:create("image/ui/img/btn/btn_1088.png")
-- title_image:setPosition(bgsize.width*0.5, bgsize.height-5)
-- bg:addChild(title_image)


-- local listview = ccui.ListView:create()
-- bg:addChild(listview)

-- listview:setDirection(ccui.ScrollViewDir.vertical)
-- listview:setBounceEnabled(false)
-- listview:setContentSize(cc.size(bgsize.width, bgsize.height-130))
-- listview:setPosition(0,90)

-- local createCell = function (celldata)
--     local ssize = cc.size(750,47)
--     local sprite = ccui.ImageView:create("image/ui/img/btn/btn_811.png")
--     sprite:setScale9Enabled(true)
--     sprite:setContentSize(ssize)
--     -- sprite:setPosition(x,y)
--     sprite:setAnchorPoint(0.5,1)

--     -- local line1 = cc.Sprite:create("image/ui/img/btn/btn_810.png")
--     -- line1:setPosition(ssize.width*0.5, ssize.height)
--     -- line1:setScaleX(2)
--     -- sprite:addChild(line1)
--     -- local line = cc.Sprite:create("image/ui/img/btn/btn_810.png")
--     -- line:setPosition(ssize.width*0.5, 0)
--     -- line:setScaleX(2)
--     -- sprite:addChild(line)

--     local yunwen1 = cc.Sprite:create("image/ui/img/btn/btn_604.png")
--     yunwen1:setPosition(ssize.width*0.15, ssize.height*0.5)
--     sprite:addChild(yunwen1)
--     local yunwen = cc.Sprite:create("image/ui/img/btn/btn_604.png")
--     yunwen:setPosition(ssize.width*0.85, ssize.height*0.5)
--     yunwen:setFlippedX(true)
--     sprite:addChild(yunwen)

--     local title_image = cc.Sprite:create("image/ui/img/btn/btn_608.png")
--     title_image:setPosition(ssize.width*0.5, ssize.height*0.5)
--     sprite:addChild(title_image)

--     local label_title = Common.finalFont(""..celldata.Title,ssize.width*0.5, ssize.height*0.5,26,cc.c3b(255,204,125) )
--     sprite:addChild(label_title)

--     local label_content = Common.finalFont(""..celldata.Content,1, 1,22)
--     label_content:setAnchorPoint(0.5,0)


--     local view_width = 800
--     local content_size = label_content:getContentSize()

--     local content_height = content_size.height  --

--     if content_size.width > view_width then
--         content_height = content_size.height * 1.3--math.ceil( content_size.width/view_width) * content_size.height  --  -- fxck 这个高度咋算...
--     end

--     local item_height = 90 + content_height

--     sprite:setPosition(bgsize.width*0.5, item_height-5)
--     label_content:setPosition(bgsize.width*0.5, 5)
--     label_content:setDimensions(view_width, content_height)

--     local default_item = ccui.Layout:create()
--     default_item:setTouchEnabled(false)
--     default_item:setContentSize(cc.size(bgsize.width, item_height))
--     default_item:addChild(sprite)
--     default_item:addChild(label_content)
--     listview:pushBackCustomItem(default_item)
--     listview:refreshView()
--     -- listview:scrollToBottom(0.1,true)

-- end

-- -- commented by caojun
-- -- for i=1,#notice do
-- --     createCell(notice[i])
-- -- end
-- createCell(notice)

-- local bottom = ccui.Scale9Sprite:create("image/ui/img/bg/bg_253.png")
-- bottom:setContentSize(cc.size(870,80))
-- bottom:setAnchorPoint(0.5,0)
-- bottom:setPosition(bgsize.width*0.5, 10)
-- bg:addChild(bottom)

-- local btn_close = ccui.MixButton:create("image/ui/img/btn/btn_593.png")
-- btn_close:setTitle("确定" , 24, cc.c3b(248,216,136),2, cc.c4b(70,38,0,255))
-- btn_close:setPosition(bgsize.width*0.5, 50)
-- btn_close:addTouchEventListener(function ( sender,eventType )
--     if eventType == ccui.TouchEventType.ended then
--         layer:removeFromParent()
--         layer = nil
--         self:checkGuideStep()
--     end
-- end)
-- bg:addChild(btn_close)

-- local function onTouchBegan(touch, event)
--     return true
-- end

-- local listener = cc.EventListenerTouchOneByOne:create()
-- listener:setSwallowTouches(true)
-- listener:registerScriptHandler(function ( touch, event )  return true  end,cc.Handler.EVENT_TOUCH_BEGAN )
-- local eventDispatcher = self:getEventDispatcher()
-- eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)

-- ]====]

function LoginLayer:showLuaNoticePanel(code)    
    xpcall(
        function() 
            setfenv(loadstring(code), getfenv())(self)
        end, 
        function(errmsg)
            print("show notice fail:", errmsg)
            self:checkGuideStep()
        end
    )    
end

function LoginLayer:showNoticePanel( notice )
    local noticePanelName = "login_noticePanel"
    if self:getChildByName(noticePanelName) then
        return
    end

    local layer = cc.Layer:create()
    layer:setName(noticePanelName)
    self:addChild(layer)

    local bgsize = cc.size(895,540)
    local bg = ccui.ImageView:create("image/ui/img/bg/bg_139.png")
    bg:setPosition(SCREEN_WIDTH*0.5,SCREEN_HEIGHT*0.5)
    bg:setScale9Enabled(true)
    bg:setContentSize(bgsize)
    layer:addChild(bg)

    local wen = cc.Sprite:create("image/ui/img/btn/btn_609.png")
    wen:setPosition(bgsize.width*0.5, bgsize.height*0.5)
    bg:addChild(wen)

    local titlebg = cc.Sprite:create("image/ui/img/bg/bg_174.png")
    titlebg:setPosition(bgsize.width*0.5, bgsize.height-10)
    bg:addChild(titlebg)

    local title_image = cc.Sprite:create("image/ui/img/btn/btn_1088.png")
    title_image:setPosition(bgsize.width*0.5, bgsize.height-5)
    bg:addChild(title_image)


    local listview = ccui.ListView:create()
    bg:addChild(listview)

    listview:setDirection(ccui.ScrollViewDir.vertical)
    listview:setBounceEnabled(false)
    listview:setContentSize(cc.size(bgsize.width, bgsize.height-130))
    listview:setPosition(0,90)

    local createCell = function (celldata)
        local ssize = cc.size(750,47)
        local sprite = ccui.ImageView:create("image/ui/img/btn/btn_811.png")
        sprite:setScale9Enabled(true)
        sprite:setContentSize(ssize)
        -- sprite:setPosition(x,y)
        sprite:setAnchorPoint(0.5,1)

        -- local line1 = cc.Sprite:create("image/ui/img/btn/btn_810.png")
        -- line1:setPosition(ssize.width*0.5, ssize.height)
        -- line1:setScaleX(2)
        -- sprite:addChild(line1)
        -- local line = cc.Sprite:create("image/ui/img/btn/btn_810.png")
        -- line:setPosition(ssize.width*0.5, 0)
        -- line:setScaleX(2)
        -- sprite:addChild(line)

        local yunwen1 = cc.Sprite:create("image/ui/img/btn/btn_604.png")
        yunwen1:setPosition(ssize.width*0.15, ssize.height*0.5)
        sprite:addChild(yunwen1)
        local yunwen = cc.Sprite:create("image/ui/img/btn/btn_604.png")
        yunwen:setPosition(ssize.width*0.85, ssize.height*0.5)
        yunwen:setFlippedX(true)
        sprite:addChild(yunwen)

        local title_image = cc.Sprite:create("image/ui/img/btn/btn_608.png")
        title_image:setPosition(ssize.width*0.5, ssize.height*0.5)
        sprite:addChild(title_image)

        local label_title = Common.finalFont(""..celldata.Title,ssize.width*0.5, ssize.height*0.5,26,cc.c3b(255,204,125) )
        sprite:addChild(label_title)

        local label_content = Common.finalFont(""..celldata.Content,1, 1,22)
        label_content:setAnchorPoint(0.5,0)


        local view_width = 800
        local content_size = label_content:getContentSize()

        local content_height = content_size.height  --

        if content_size.width > view_width then
            content_height = content_size.height * 1.3--math.ceil( content_size.width/view_width) * content_size.height  --  -- fxck 这个高度咋算...
        end

        local item_height = 90 + content_height

        sprite:setPosition(bgsize.width*0.5, item_height-5)
        label_content:setPosition(bgsize.width*0.5, 5)
        label_content:setDimensions(view_width, content_height)

        local default_item = ccui.Layout:create()
        default_item:setTouchEnabled(false)
        default_item:setContentSize(cc.size(bgsize.width, item_height))
        default_item:addChild(sprite)
        default_item:addChild(label_content)
        listview:pushBackCustomItem(default_item)
        listview:refreshView()
        -- listview:scrollToBottom(0.1,true)

    end

    -- commented by caojun
    -- for i=1,#notice do
    --     createCell(notice[i])
    -- end
    createCell(notice)

    local bottom = ccui.Scale9Sprite:create("image/ui/img/bg/bg_253.png")
    bottom:setContentSize(cc.size(870,80))
    bottom:setAnchorPoint(0.5,0)
    bottom:setPosition(bgsize.width*0.5, 10)
    bg:addChild(bottom)

    local btn_close = ccui.MixButton:create("image/ui/img/btn/btn_593.png")
    btn_close:setTitle("确定" , 24, cc.c3b(248,216,136),2, cc.c4b(70,38,0,255))
    btn_close:setPosition(bgsize.width*0.5, 50)
    btn_close:addTouchEventListener(function ( sender,eventType )
        if eventType == ccui.TouchEventType.ended then
            layer:removeFromParent()
            layer = nil
            self:checkGuideStep()
        end
    end)
    bg:addChild(btn_close)

    local function onTouchBegan(touch, event)
        return true
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(function ( touch, event )  return true  end,cc.Handler.EVENT_TOUCH_BEGAN )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)
end

function LoginLayer:showAgreement( agreement )
    local noticePanelName = "agreement_Panel"
    if self:getChildByName(noticePanelName) then
        return
    end

    local layer = cc.Layer:create()
    layer:setName(noticePanelName)
    self:addChild(layer)

    local bgsize = cc.size(895,540)
    local bg = ccui.ImageView:create("image/ui/img/bg/bg_139.png")
    bg:setPosition(SCREEN_WIDTH*0.5,SCREEN_HEIGHT*0.5)
    bg:setScale9Enabled(true)
    bg:setContentSize(bgsize)
    layer:addChild(bg)

    local wen = cc.Sprite:create("image/ui/img/btn/btn_609.png")
    wen:setPosition(bgsize.width*0.5, bgsize.height*0.5)
    bg:addChild(wen)

    local titlebg = cc.Sprite:create("image/ui/img/bg/bg_174.png")
    titlebg:setPosition(bgsize.width*0.5, bgsize.height-10)
    bg:addChild(titlebg)

    -- local title_image = cc.Sprite:create("image/ui/img/btn/btn_1088.png")
    -- title_image:setPosition(bgsize.width*0.5, bgsize.height-5)
    -- bg:addChild(title_image)


    local listview = ccui.ListView:create()
    bg:addChild(listview)

    listview:setDirection(ccui.ScrollViewDir.vertical)
    listview:setBounceEnabled(false)
    listview:setContentSize(cc.size(bgsize.width, bgsize.height-130))
    listview:setPosition(0,90)

    local createCell = function (celldata)
        local ssize = cc.size(750,47)
        local sprite = ccui.ImageView:create("image/ui/img/btn/btn_811.png")
        sprite:setScale9Enabled(true)
        sprite:setContentSize(ssize)
        -- sprite:setPosition(x,y)
        sprite:setAnchorPoint(0.5,1)

        -- local line1 = cc.Sprite:create("image/ui/img/btn/btn_810.png")
        -- line1:setPosition(ssize.width*0.5, ssize.height)
        -- line1:setScaleX(2)
        -- sprite:addChild(line1)
        -- local line = cc.Sprite:create("image/ui/img/btn/btn_810.png")
        -- line:setPosition(ssize.width*0.5, 0)
        -- line:setScaleX(2)
        -- sprite:addChild(line)

        local yunwen1 = cc.Sprite:create("image/ui/img/btn/btn_604.png")
        yunwen1:setPosition(ssize.width*0.15, ssize.height*0.5)
        sprite:addChild(yunwen1)
        local yunwen = cc.Sprite:create("image/ui/img/btn/btn_604.png")
        yunwen:setPosition(ssize.width*0.85, ssize.height*0.5)
        yunwen:setFlippedX(true)
        sprite:addChild(yunwen)

        local title_image = cc.Sprite:create("image/ui/img/btn/btn_608.png")
        title_image:setPosition(ssize.width*0.5, ssize.height*0.5)
        sprite:addChild(title_image)

        local label_title = Common.finalFont(""..celldata.Title,ssize.width*0.5, ssize.height*0.5,26,cc.c3b(255,204,125) )
        sprite:addChild(label_title)

        local label_content = Common.finalFont(""..celldata.Content,1, 1,22)
        label_content:setAnchorPoint(0.5,0)


        local view_width = 800
        local content_size = label_content:getContentSize()

        local content_height = content_size.height  --

        if content_size.width > view_width then
            content_height = content_size.height * 1.3--math.ceil( content_size.width/view_width) * content_size.height  --  -- fxck 这个高度咋算...
        end

        local item_height = 90 + content_height

        sprite:setPosition(bgsize.width*0.5, item_height-5)
        label_content:setPosition(bgsize.width*0.5, 5)
        label_content:setDimensions(view_width, content_height)

        local default_item = ccui.Layout:create()
        default_item:setTouchEnabled(false)
        default_item:setContentSize(cc.size(bgsize.width, item_height))
        default_item:addChild(sprite)
        default_item:addChild(label_content)
        listview:pushBackCustomItem(default_item)
        listview:refreshView()
    end

    -- commented by caojun
    -- for i=1,#notice do
    --     createCell(notice[i])
    -- end
    createCell(agreement)

    local bottom = ccui.Scale9Sprite:create("image/ui/img/bg/bg_253.png")
    bottom:setContentSize(cc.size(870,80))
    bottom:setAnchorPoint(0.5,0)
    bottom:setPosition(bgsize.width*0.5, 10)
    bg:addChild(bottom)

    local btn_close = ccui.MixButton:create("image/ui/img/btn/btn_593.png")
    btn_close:setTitle("关闭" , 24, cc.c3b(248,216,136),2, cc.c4b(70,38,0,255))
    btn_close:setPosition(bgsize.width*0.5, 50)
    btn_close:addTouchEventListener(function ( sender,eventType )
        if eventType == ccui.TouchEventType.ended then
            layer:removeFromParent()
        end
    end)
    bg:addChild(btn_close)

    local function onTouchBegan(touch, event)
        return true
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(function ( touch, event )  return true  end,cc.Handler.EVENT_TOUCH_BEGAN )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)
end

function LoginLayer:loginGame(addr,key, sid)
    rpc:setRemoteAddr("http://" .. addr)
    local major = GetAppVersion()
    local patch = GetUpdatedVersion()
    local url = AccountHelper.ENTER_GAME_URL(key, sid, major, patch)
    CCLog("url ----> ", url)

    http.get(url, handler(self, self.handleStartGame), function()
        require("tool.helper.CommonLayer").AlertPanel("上仙，貌似您的网络不太给力，\n连接不到服务器，请重新尝试", function() 
            switchLoginServerAddress()
            self:loginGame(addr, key, sid)
        end)
    end)
end

function LoginLayer:handleStartGame(resp)
    local reply = json.decode(resp)
    CCLog("------------> start: ", vardump(reply))
    if reply.Code ~= 0 then
        self.btn_start:setStateEnabled(true)
        return
    end

    GameCache.Passport = reply.Result
    CCLog("passport ----> ", GameCache.Passport)

    -- rpc:call("Game.GetNotice", nil, function(event)
    --     if event.status == Exceptions.Nil then
    --         local notice = event.result
    --         CCLog("----------------> notice: ", vardump(notice))
    --         self:showNoticePanel(notice)
    --     else
    --         self:checkGuideStep()
    --     end
    -- end)

    local function getFileContent(path)
        local f = io.open(path, "rb")
        if f then
            local data = f:read("*all")
            f:close()
            return data
        else
            return nil
        end
    end

    local lpath = require("tool.lib.path")
    local lmd5 = require("md5")

    local fileUtils = cc.FileUtils:getInstance()
    local noticeFilePath = lpath.join(fileUtils:getWritablePath(), "notice.lua")
    local fileContent = getFileContent(noticeFilePath)
    local md5 = string.upper(lmd5.hex(fileContent or ""))

    rpc:call("Game.GetLuaNotice", md5, function(event)
        if event.status == Exceptions.Nil then
            local notice = event.result
            CCLog("----------------> notice: ", hex(notice), vardump(notice))
            if notice and #notice > 0 then
                code = notice

                local f = io.open(noticeFilePath, "wb")
                f:write(notice)
                f:close()
            else
                code = fileContent
            end

            self:showLuaNoticePanel(code)
        else
            self:checkGuideStep()
        end
    end)    
end

function LoginLayer:checkGuideStep()
    rpc:call("Guide.GetCurStep", nil, function ( event )
        if event.status == Exceptions.Nil and event.result ~= nil then
            GameCache.NewbieGuide.Step =  event.result

            if GameCache.NewbieGuide.Step < 1 then
                CCLog("enterScene main.splash.SplashScene")
                application:enterScene("main.splash.SplashScene")
            else
                CCLog("enterGame")
                application:enterGame()
            end
        end
    end)
end

return LoginLayer