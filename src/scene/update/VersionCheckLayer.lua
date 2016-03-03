--
-- Created by IntelliJ IDEA.
-- User: lqefn
-- Date: 15/3/2
-- Time: 下午4:41
-- To change this template use File | Settings | File Templates.
--

local http = require("net.http")
local lfs = require("lfs")
local lpath = require("tool.lib.path")

local function listDir(path)
    local dirList = {}

    for item in lfs.dir(path) do
        if item ~= "." and item ~= ".." then
            local attr = lfs.attributes(lpath.join(path, item))
            if attr and attr.mode == "directory" then
                table.insert(dirList, item)
            end
        end
    end

    return dirList
end

function removeSubDirExcept(path, except)
    local dirList = listDir(path)
    CCLog(vardump(dirList, "dirList"))
    for _, p in ipairs(dirList) do
        if p ~= except then
            local dir = lpath.join(path, p) .. "/"
            CCLog("remove dir " .. dir)
            cc.FileUtils:getInstance():removeDirectory(dir)
        end
    end
end

-------------------------------------------------------------------------------
local VersionCheckLayer = class("BattleFormLayer", BaseLayer)

function VersionCheckLayer:ctor(verCheckResult)
    VersionCheckLayer.super.ctor(self)

    self.verCheckResult = verCheckResult

    self:setupUI()
end

function VersionCheckLayer:onEnterTransitionFinish( ... )
    -- body
end

function VersionCheckLayer:setupUI()
    -- local bg = cc.Sprite:create("image/ui/img/bg/denglu.jpg")
    -- bg:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT * 0.5)
    -- self:addChild(bg)

    local bg_ani = load_animation("image/spine/ui_effect/51", 1)
    bg_ani:setAnimation(0,"animation", true)
    bg_ani:setTimeScale(0.5)
    bg_ani:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)
    self:addChild(bg_ani)

    local gameTitle = cc.Sprite:create("image/ui/img/bg/bg_06_logo.png")
    -- gameTitle:setScale(0.8)
    gameTitle:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5+140)
    self:addChild(gameTitle)

    local progressBarPos = cc.p(SCREEN_WIDTH*0.5, 190)

    local updateTitle = cc.Sprite:create("image/ui/img/btn/btn_1158.png")
    updateTitle:setPosition(cc.pAdd(progressBarPos, cc.p(0, 40)))
    self:addChild(updateTitle)
    self.updateTitle = updateTitle
    self.updateTitle:setVisible(false)

    local progressBarBG = cc.Sprite:create("image/ui/img/btn/btn_1157.png")
    progressBarBG:setPosition(progressBarPos)
    self:addChild(progressBarBG)
    self.progressBG = progressBarBG
    self.progressBG:setVisible(false)

    local progressImage = "image/ui/img/btn/btn_1156.png"
    local progressBar = cc.ProgressTimer:create(cc.Sprite:create(progressImage))
    progressBar:setPosition(progressBarPos)
    progressBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    progressBar:setMidpoint(cc.p(0, 1))
    progressBar:setBarChangeRate(cc.p(1, 0))
    progressBar:setPercentage(0)
    self:addChild(progressBar)
    self.progressBar = progressBar
    self.progressBar:setVisible(false)

    local desc = "版本检测中..."

    if self.verCheckResult then
        desc = "准备更新..."
    end

    local progressLabel = cc.LabelTTF:create(desc, "Arial", 26)
    progressLabel:setAnchorPoint(cc.p(0.5, 0.5))
    progressLabel:setPosition(progressBarPos)
    self:addChild(progressLabel, 1)
    self.progressLabel = progressLabel

    local version = GetUpdatedVersion()
    local labelVersion = Common.finalFont("版本号:" .. version, 0 , 0 , 18, cc.c3b(255, 255, 255), 1)
    labelVersion:setAnchorPoint(cc.p(1, 0.5))
    labelVersion:setColor(cc.c3b(223, 188, 30))
    labelVersion:setPosition(SCREEN_WIDTH - 5, 40)
    self:addChild(labelVersion, 1)
    self.labelVersion = labelVersion

    --self.progressLabel:setString("正在检测游戏版本")


    -- local function onTouchBegan(touch, event)
    --     return true
    -- end

    -- local function onTouchEnded(touch, event)
    -- end

    -- local listener = cc.EventListenerTouchOneByOne:create()
    -- listener:setSwallowTouches(false)
    -- listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    -- listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    -- self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

function VersionCheckLayer:onEnter()
    self:checkUpdate()
end

function VersionCheckLayer:onCleanup()
    if self.assetsManager then
       self.assetsManager:release()
       self.assetsManager = nil
    end
end

function VersionCheckLayer:onUpdateComplete()
    CheckPatchPaths()
    RestartGame()
    -- local fileUtils = cc.FileUtils:getInstance()

    -- local info = self:readLastPackageInfo()
    -- if info then
    --     local appVer = GetAppVersion()

    --     CCLog(vardump(info, "Version Info"))
    --     local build = info.Build
    --     if build == nil then
    --         local version = info.Version
    --         _, _, build = string.match(version, "(%d+)%.(%d+)%.(%d+)")
    --     end

    --     local rootPath =  cc.FileUtils:getInstance():getWritablePath() .. "update"
    --     local rootAttrs = lfs.attributes(rootPath)
    --     if rootAttrs  then
    --         local major, minor, _ = string.match(appVer, "(%d+)%.(%d+)%.(%d+)")
    --         local path = lpath.join(rootPath, string.format("%s.%s", major, minor), build)
    --         CCLog("last update path:", path)
    --         local pathAttrs = lfs.attributes(path)
    --         if pathAttrs and pathAttrs.mode == "directory" then               
    --             -- 删除除了当前大小版本号的目录
    --             removeSubDirExcept(rootPath, string.format("%s.%s", major, minor))               
    --             local searchPaths = fileUtils:getSearchPaths()

    --             local minorPath = lpath.join(rootPath, string.format("%s.%s", major, minor))
    --             local dirList = listDir(minorPath)
    --             table.sort(dirList, function(a, b) return tonumber(a) < tonumber(b) end)
                
    --             for _, path in ipairs(dirList) do
    --                 local fullPath = lpath.join(minorPath, path)
    --                 table.insert(searchPaths, 1, fullPath .. "/res")
    --                 table.insert(searchPaths, 1, fullPath .. "/src")
    --                 table.insert(searchPaths, 1, fullPath)
    --             end
    --             fileUtils:setSearchPaths(searchPaths)
    --         end
    --     end

    --     CCLog(vardump(fileUtils:getSearchPaths(), "search paths"))
    -- end

    -- --application:enterScene("login.LoginScene")
    -- RestartGame()
end

function VersionCheckLayer:readLastPackageInfo()
    local fileUtils = cc.FileUtils:getInstance()
    local path = fileUtils:getWritablePath() .. "update/package.json"
    local data = fileUtils:getStringFromFile(path)

    if data then
        local info = json.decode(data)
        return info
    end

    return nil
end

function VersionCheckLayer:writeLastPackageInfo(info)
    local fileUtils = cc.FileUtils:getInstance()
    local path = fileUtils:getWritablePath() .. "update/package.json"
    local data = json.encode(info)
    local f = io.open(path, "w")
    f:write(data)
    f:close()
end

--[[
检查是否有更新 url: http://server/patch/check/

参数：

游戏id (game: string)
发行渠道id (channel: string)
游戏版本号（version: int）
响应： 1. 是否有更新（update: bool） 2. 更新包 (patch: object)

字节大小（size: int）
校验值 (md5: string)
下载地址 (url: string)
--]]

local function urlencode(data)
    local cache = {}
    for k, v in pairs(data) do
        table.insert(cache, k .. "=" .. v)
    end

    return table.concat(cache, "&")
end

local function getPackageBuildNum(pkgInfo)
    local build = pkgInfo.Build
    if build == nil then
        local version = pkgInfo.Version
        _, _, build = string.match(version, "(%d+)%.(%d+)%.(%d+)")
    end
    return build
end

function VersionCheckLayer:checkUpdate()
    local function checkResult(event)
        if event.status == Exceptions.Nil then
            self:onCheckResponse(event.result)
        else
            self:onCheckError(event.result)
        end
    end

    if self.verCheckResult == nil then
        local gameID  = GAME_BASE_INFO.gameID
        local channel = GAME_BASE_INFO.channel
        local majorv = GetAppVersion()
        local patchv = GetUpdatedVersion()
        local param = {Game = gameID, Channel = channel, Major = majorv, Patch = patchv}
        CCLog("param: ", vardump(param))
        
        rpc:call("Game.CheckVersion", param, checkResult)
    else
        self:onCheckResponse(self.verCheckResult)
    end
end

    -- Result = {
    --     Pkg = {
    --         MD5 = "e9e513411203da7e79ace64357251241",
    --         Size = 6749892,
    --         URL = "http://7xpb9d.dl1.z0.glb.clouddn.com/0/v1.0.14-e9e513411203da7e79ace64357251241.zip",
    --         Version = "1.0.14",
    --     },
    --     Status = 1,
    -- },
function VersionCheckLayer:onCheckResponse(data)
    CCLog("VersionCheckLayer:onCheckResponse", vardump(data))

    local resp = data
    if resp and type(resp) == "table" then
        if resp.Status == 0 then
            -- 已经是最新版本
            self.progressLabel:setString("加载资源中，请稍候...")
            --application:enterScene("login.LoginScene")

            rpc.hasCheckedVersion = true
            application:initGameAndEnterMainScene()
        elseif resp.Status == 1 then
            local url = resp.Pkg.URL
            local build = getPackageBuildNum(resp.Pkg)

            self.pkg = resp.Pkg

            -- TODO:临时代码
            if self.pkg.Build == nil then
                self.pkg.Build = build
            end
            local version = GetUpdatedVersion()
            local major, minor, _ = string.match(version, "(%d+)%.(%d+)%.(%d+)")
            version = string.format("%s.%s.%s", major, minor, build)

            if network.getInternetConnectionStatus() == 1 then -- 0:无， 1：WIFI 2：3G
                self:download(url, version)
            else
                local sizeMB = self.pkg.Size / (1024 * 1024)
                local msg = string.format("    亲，检查到有新版本，更新包大小为%.1fMB\n但现在没WiFi哦~~  是否要下载？", sizeMB)

                require("tool.helper.CommonLayer").HintPanel(msg, 
                    function() self:download(url, version) end, 
                    true, 
                    function() 
                        cc.Director:getInstance():endToLua()
                        os.exit(0)
                    end
                )

                -- application:dialog("确认更新", msg, {"下载", "退出"}, function(index, data, buttonText)
                --     CCLog(vardump{index, data, buttonText})
                --     if index == 2 then
                --         self:download(url, version)
                --     else
                --         cc.Director:getInstance():endToLua()
                --     end
                -- end)
            end
        elseif resp.Status == 2 then
            self.progressLabel:setString("请下载新的游戏包")
            CCLog("下载新的游戏包去")

            local url = resp.Pkg.URL
            cc.Application:getInstance():openURL(url)
        elseif resp.Status == 3 then
            CCLog("版本回退到", resp.Pkg.Version)
            self.progressLabel:setString("版本回退")
            RemoveOverflowPatch(resp.Pkg.Version)
            self:writeLastPackageInfo(resp.Pkg)
            RestartGame()
        else
            self.progressLabel:setString("未知版本")

            require("tool.helper.CommonLayer").HintPanel("检测版本异常，不能进入游戏", 
                function() 
                    cc.Director:getInstance():endToLua()
                    os.exit(0)
                end
            )
        end
    else
        self.progressLabel:setString("未知异常")

        require("tool.helper.CommonLayer").HintPanel("检测版本失败，不能进入游戏", 
            function() 
                cc.Director:getInstance():endToLua()
                os.exit(0)
            end
        )
    end
end

function VersionCheckLayer:onCheckError(data)
    CCLog("VersionCheckLayer:onCheckError", vardump(data))

    self.progressLabel:setString("更新异常")
    require("tool.helper.CommonLayer").HintPanel("更新异常，不能进入游戏", 
        function() 
            cc.Director:getInstance():endToLua()
            os.exit(0)
        end
    )
end

function VersionCheckLayer:onError(errorCode)
    CCLog("VersionCheckLayer:onError", errorCode)
--    cc.ASSETSMANAGER_CREATE_FILE  = 0
--    cc.ASSETSMANAGER_NETWORK = 1
--    cc.ASSETSMANAGER_NO_NEW_VERSION = 2
--    cc.ASSETSMANAGER_UNCOMPRESS     = 3
    if errorCode == cc.ASSETSMANAGER_NO_NEW_VERSION then
        self.progressLabel:setString("没有新版本")
    elseif errorCode == cc.ASSETSMANAGER_NETWORK then
        self.progressLabel:setString("网络异常")
    elseif errorCode == cc.ASSETSMANAGER_CREATE_FILE then
        self.progressLabel:setString("新建文件失败")
    elseif errorCode == cc.ASSETSMANAGER_UNCOMPRESS then
        self.progressLabel:setString("解压更新包失败")
    end

    self.updateTitle:setVisible(false)
    self.progressBG:setVisible(false)
    self.progressBar:setVisible(false)
end

local function pretty_size(num)
    if num < 1024 then
        return string.format("%dB", num)
    elseif num < 1024 * 1024 then
        return string.format("%.1fK", num / 1024)
    elseif num < 1024 * 1024 * 1024 then
        return string.format("%.1fM", num / 1024 / 1024)
    end
end

function VersionCheckLayer:onProgress( percent )
    CCLog("VersionCheckLayer:onProgress", percent)

    if percent < 0 then
        -- 为啥会这样
        return
    end
    
    local size = self.pkg.Size
    local progress = string.format("%s/%s", pretty_size(size * percent / 100), pretty_size(size))

    self.updateTitle:setVisible(true)
    self.progressBG:setVisible(true)
    self.progressBar:setVisible(true)

    self.progressLabel:setString(progress)
    self.progressBar:setPercentage(percent)
end

function VersionCheckLayer:onSuccess()
    CCLog("VersionCheckLayer:onSuccess")
    self.updateTitle:setVisible(false)
    self.progressBG:setVisible(false)
    self.progressBar:setVisible(false)

    self.progressLabel:setVisible(false)

    self:writeLastPackageInfo(self.pkg)

    self:onUpdateComplete()

    rpc.hasCheckedVersion = true
end

function VersionCheckLayer:download(url, version)
    local rootPath =  cc.FileUtils:getInstance():getWritablePath() .. "update"
    local rootAttrs = lfs.attributes(rootPath)
    if rootAttrs == nil then
        lfs.mkdir(rootPath)
    end

    local major, minor, build = string.match(version, "(%d+)%.(%d+)%.(%d+)")

    local path = lpath.join(rootPath, string.format("%s.%s", major, minor), build)
    local pathAttrs = lfs.attributes(path)
    if pathAttrs ~= nil then
        cc.FileUtils:getInstance():removeDirectory(path .. "/")
    end
    cc.FileUtils:getInstance():createDirectory(path)

    local assetsManager = cc.GCAssetsManager:new(url, path)

    assetsManager:retain()
    assetsManager:setDelegate(handler(self, VersionCheckLayer.onError), cc.ASSETSMANAGER_PROTOCOL_ERROR)
    assetsManager:setDelegate(handler(self, VersionCheckLayer.onProgress), cc.ASSETSMANAGER_PROTOCOL_PROGRESS)
    assetsManager:setDelegate(handler(self, VersionCheckLayer.onSuccess), cc.ASSETSMANAGER_PROTOCOL_SUCCESS)
    assetsManager:setConnectionTimeout(3)
    assetsManager:setVersion(version)
    assetsManager:update()
    
    self.assetsManager = assetsManager
end

return VersionCheckLayer
