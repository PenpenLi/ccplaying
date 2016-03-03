-- rpc client
-- author: caojun

-- local zlib = require("zlib")
local json = require("tool.lib.json")
local http = require("net.http")
local RPCMETHODS = require("net.methods")
RPCMETHODS["heartbeat"] = 0
local RPCCODES = {}
for name, code in pairs(RPCMETHODS) do
    RPCCODES[code] = name
end

CCLog("methods: ", dump(RPCMETHODS))
CCLog("codes: ", dump(RPCCODES))

local useMethodCode = false

require("net.rc4")

local RC4_KEY = "D#099rerdc"

local function marshal(val)
    local data = json.encode(val)
    local encryptData = RC4(RC4_KEY, data)
    return encryptData 
end

local function unmarshal(data)
    if data then
        local decryptData = RC4(RC4_KEY, data)
        return json.decode(decryptData)
    end
    return nil 
end

local RPC = class("RPC", function() 
    local dispatcher = cc.EventDispatcher:new()
    dispatcher:retain()
    dispatcher:setEnabled(true) 
    return dispatcher
end)

function RPC:ctor()
    self.loading = 0
    self.handlers = {} -- 记录事件和回调映射，回调后移除，防止重入
    self.hasCheckedVersion = false
end

function RPC:addEventListener(name, cbRsp, priority)
    priority = priority or 1
    local listener = cc.EventListenerCustom:create(name, cbRsp)
    self:addEventListenerWithFixedPriority(listener, priority)
    return listener
end

function RPC:setRemoteAddr(addr)
    self.remoteAddr = addr
end

function RPC:getRemoteAddr()
    return self.remoteAddr
end

function RPC:send(req, params)
    if useMethodCode then
        req.Method = RPCMETHODS[req.Method]
    end

    local data = marshal(req)

    if params.debug then
        local debugInfo = string.format("\nrpc.request:\n%s\n", vardump(req))
        CCLog(debugInfo)
    end

    local function _isValidPassport(status) 
            return (status ~= Exceptions.EPassportInvalid and status ~= Exceptions.EPassportExpired and status ~= Exceptions.ELoginOnOtherDevice)
    end

    local function _invalidPassportDesc(status) 
            if status == Exceptions.EPassportInvalid then
                return "上仙，您的通行证无效，请重新登录!"
            end

            if status == Exceptions.EPassportExpired then
                return "上仙，您的通行证已过期，请重新登录!"
            end

            if status == Exceptions.ELoginOnOtherDevice then
                return "上仙，你的帐号已经在其它设备上登录，请确\n保帐号安全！"
            end
    end


    local function _cbRsp(rspData)
        -- CCLog("rspData: ", rspData)
        local response = unmarshal(rspData)

        if params.debug then
            local debugInfo = string.format("\nrpc.response:\n%s\n", vardump(response))
            CCLog(debugInfo)
        end

        if type(response) == "table" then
            if not _isValidPassport(response.Status) then
                local desc = _invalidPassportDesc(response.Status)
                require("tool.helper.CommonLayer").AlertPanel(desc, function() RestartGame() end, false, nil)
            else            
                if self and not tolua.isnull(self) then
                    xpcall(function()
                        self:syncHeartbeat(response.Sync)
                        end, __G__TRACKBACK__)

                    xpcall(function() 
                        local name = response.Method
                        if useMethodCode then
                            name = RPCCODES[name]
                        end

                        local event = cc.EventCustom:new(name)
                        event.status = response.Status
                        event.result = response.Result
                        event.name = name
                        event.desc = response.Desc
                        -- 分发响应事件
                        self:dispatchEvent(event)
                        local handler = self.handlers[name]
                        if handler then
                            self:removeEventListener(handler)
                            self.handlers[name] = nil
                        end
                    end, __G__TRACKBACK__)
                end
            end
        end
    end

    local ok = xpcall(function ()
        return http.post(self.remoteAddr, data, _cbRsp, nil, params)
    end, __G__TRACKBACK__)
end

function RPC:call(method, arg, handler, _params)
    local params = _params or { show = true, debug = true }
    assert(GameCache.Passport)
    local request = { Passport = GameCache.Passport, Method = method, Param = arg, Seq = 1 }
    if handler then
        local name = method
        local h = self:addEventListener(name, handler)
        self.handlers[name] = h
    end

    self:send(request, params)
end

function RPC:heartbeat()
    rpc:call("heartbeat", nil, nil, { show = false, debug = false, alertError = false })
end

function RPC:syncHeartbeat(sync)

    if sync == nil then
        return
    end

    if GameCache.Avatar == nil then
        if sync.Chat ~= nil then
            -- 保存离线聊天记录到GameCache
            GameCache.ChatRecord = sync.Chat
        end
        return
    else
        if GameCache.ChatRecord ~= nil then      
            self:writeRecord(GameCache.ChatRecord)
            GameCache.ChatRecord = nil
        end
    end

    -- Sync.Avatar
    local oldAvt = clone(GameCache.Avatar)
    if sync.Avatar and GameCache.Avatar ~= nil then
        local newAvt = sync.Avatar
        -- 更新Avatar信息
        for k, v in pairs(newAvt) do
            GameCache.Avatar[k] = v
            application:dispatchCustomEvent(AppEvent.UI.Pay.UpdatePayNode, k)
        end

        -- 更新体力和耐力上限
        if newAvt.EnergyStep ~= nil or newAvt.EnergyAttrNum ~= nil then
            local CalHeroAttr = require("tool.helper.CalHeroAttr")
            local step = newAvt.EnergyStep or GameCache.Avatar.EnergyStep
            local attrNum = newAvt.EnergyAttrNum or GameCache.Avatar.EnergyAttrNum
            GameCache.Avatar.MaxPhyPower = CalHeroAttr.calMaxPhyPower(step, attrNum)
            GameCache.Avatar.MaxEndurance = CalHeroAttr.calMaxEndurance(step, attrNum)
            if GameCache.Avatar.MaxPhyPower ~= oldAvt.MaxPhyPower then
                application:dispatchCustomEvent(AppEvent.UI.Pay.UpdatePayNode, "MaxPhyPower")
            end

            if GameCache.Avatar.MaxEndurance ~= oldAvt.MaxEndurance then
                application:dispatchCustomEvent(AppEvent.UI.Pay.UpdatePayNode, "MaxEndurance")
            end
        end

        -- 更新充值
        if newAvt.VIPExp then
            application:dispatchCustomEvent(AppEvent.UI.Avatar.VIPExp)
        end

        -- 派发角色升级事件
        if oldAvt ~= nil and GameCache.Avatar.Level > oldAvt.Level then
            local name = "Avatar.LevelUp"	
            local event = cc.EventCustom:new(name)
            event.name = name
            event.result = {oldAvatar = oldAvt, newAvatar = GameCache.Avatar}
            self:dispatchEvent(event)
        end
    end

    -- Sync.Tips
    if sync.Tips then
        local _tipsMail = sync.Tips[TIPS_MAIL]
        local _tipsFriend = sync.Tips[TIPS_FRIEND]
        local _tipsGamble = sync.Tips[TIPS_GAMBLE]
        local _tipsTask = sync.Tips[TIPS_TASK]
        local _tipsActivity = sync.Tips[TIPS_ACTIVITY]
        local _tipsSyncFriend = sync.Tips[TIPS_SYNC_FRIEND]
        local _tipsHome = sync.Tips[TIPS_HOME]
        local _tipsEnergy = sync.Tips[TIPS_ENERGY]

        local data = { showMail = _tipsMail, showFriend = _tipsFriend
        , showGamble = _tipsGamble, showTask = _tipsTask
        , showActivity = _tipsActivity, showHome = _tipsHome, showEnergy = _tipsEnergy }

        application:dispatchCustomEvent(AppEvent.UI.Heartbeat.Heart, data)

        if _tipsSyncFriend then
            self:call("Friend.Info", nil, function(event)
                -- CCLog("------------> friend: ", vardump(event))
                if event.status == Exceptions.Nil then
                    GameCache.updateFriendInfo(event.result)
                end
            end, {show=false, debug=false})
        end
    end

    -- Sync.Bee
    if sync.Bee then
        application:dispatchCustomEvent(AppEvent.UI.Heartbeat.Bee, sync.Bee) 
    end

    if sync.AccPurchase then
        GameCache.Avatar.AccPurchase = sync.AccPurchase
    end

    -- Sync.Message
    if sync.Message then
        application:clearRollingMessage()
        CCLog("Message: ", vardump(sync.Message))
        for typ, msgList in pairs(sync.Message) do
            for idx, msg in ipairs(msgList) do
                application:pushRollingMessage(msg)
            end
        end                    
    end

    -- purchase count
    if sync.Purchase then
        -- 显示首充礼包 
        GameCache.PurchaseGiftStatus = sync.Purchase
    end

    -- check new version
    if sync.Version then
        if self.hasCheckedVersion then
            CCLog("Version: ", vardump(sync.Version))
            local major = GetAppVersion()
            local patch = GetUpdatedVersion()
            if #sync.Version == 2 then
                if sync.Version[1] ~= "" and sync.Version[1] ~= major or sync.Version[2] ~= "" and sync.Version[2] ~= patch then
                    RestartGame()
                end
            end
        end
    end

    if sync.Recover then
        rpc:call("Game.Init", nil, function(event)
            if event.status == Exceptions.EDisabledRole then
                application:showFlashNotice("你已被禁号！")
                return
            end
            GameCache.updateEquipList(event.result.EquipList) 
            GameCache.updatePropsList(event.result.PropsList) 
            GameCache.updateHeroList(event.result.HeroList) 
            GameCache.updateSoulList(event.result.SoulList) 
            GameCache.updateFairyList(event.result.FairyList) 
            GameCache.updateAvatar(event.result.Avatar)
            GameCache.updateFriendInfo(event.result.Friend) 
            GameCache.updateInstanceInfo(event.result.Instance) 
            GameCache.updateApartment(event.result.Apartment) 

        end)
    end
    -- sync.Chat
    if sync.Chat then
        CCLog("sync.Chat", vardump(sync.Chat))
        self:writeRecord(sync.Chat)
        application:dispatchCustomEvent(AppEvent.UI.Heartbeat.Chat, sync.Chat) 
    end
end

function RPC:callMulti()
    assert(false, "invalid call")
end

function RPC:writeRecord(record)
    local privateMessage = {}
    for _,m in pairs(record) do
        local message = json.decode(m)
        if message.To ~= "all" then
            -- 私聊
            local sendInfo = {}
            for data in string.gmatch(message.Info, "%w+") do
                table.insert(sendInfo, data)
            end
            local id = sendInfo[1]
            local level = sendInfo[2]
            local vip = sendInfo[3]
            local icon = sendInfo[4]

            local copy = false
            for _,mess in pairs(privateMessage) do
                -- 如果有重复的Id
                if mess.Id == id then
                    copy = true
                    mess.isNotice = true
                    table.insert(mess.Message, message)
                end
            end
            if not copy then
                local m = {["Id"]=id, ["Level"]=level, ["Vip"]=vip,
                        ["Icon"]=icon, ["Message"]={}, ["isShow"]=false, ["isNotice"]=true}
                table.insert(m.Message, 1, message)
                table.insert(privateMessage, 1, m)
            end
        end
    end
    -- 存取私聊记录在本地
    local fileName = "chatRecord_"..GameCache.Avatar.RID..".lua"
    local localChatRecord = Common.readFile(fileName)
    if localChatRecord then
        for _,mess in pairs(privateMessage) do
            local id  = mess.Id
            local copy = false
            for _,localMessage in pairs(localChatRecord) do
                -- 如果有重复Id
                if localMessage.Id == id then
                    copy = true
                    for _,m in pairs(mess.Message) do
                        if #localMessage.Message >= 50 then
                            table.remove(localMessage.Message, 50)
                        end
                        -- 插入聊天信息
                        table.insert(localMessage.Message, 1, m)
                    end
                end 
            end
            if not copy then
                table.insert(localChatRecord, 1, mess)
            end
        end
        Common.writeFile(localChatRecord, fileName)
    else
        Common.writeFile(privateMessage, fileName)
    end
end

return RPC
