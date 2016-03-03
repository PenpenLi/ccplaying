--[[
    Inspired by SocketTCP lua for quick-cocos2d-x (author: zengrong.net)
]]

local SOCKET_TICK_TIME = 0.1 -- check socket data interval
local SOCKET_RECONNECT_TIME = 5 -- socket reconnect try interval
local SOCKET_CONNECT_FAIL_TIMEOUT = 3 -- socket failure timeout

local STATUS_CLOSED = "closed"
local STATUS_NOT_CONNECTED = "Socket is not connected"
local STATUS_ALREADY_CONNECTED = "already connected"
local STATUS_ALREADY_IN_PROGRESS = "Operation already in progress"
local STATUS_TIMEOUT = "timeout"

local DATA_HEAD_LENGTH = 4 -- 4 bytes for data head

local socket = require("socket")


local TCPClient = class("TCPClient", function() 
    local dispatcher = cc.EventDispatcher:new()
    dispatcher:retain()
    dispatcher:setEnabled(true) 
    return dispatcher
end)

--[[
Event define
]]


TCPClient.EVENT_DATA = "SOCKET_TCP_DATA"
TCPClient.EVENT_CLOSE = "SOCKET_TCP_CLOSE"
TCPClient.EVENT_CLOSED = "SOCKET_TCP_CLOSED"
TCPClient.EVENT_CONNECTED = "SOCKET_TCP_CONNECTED"
TCPClient.EVENT_CONNECT_FAILURE = "SOCKET_TCP_CONNECT_FAILURE"


function TCPClient:ctor( __host, __port, __retryConnectWhenFailure )
    CCLog("TCPClient:ctor()")
    self.host = __host
    self.port = __port
    self.tickScheduler = nil -- timer for data
    self.reconnectScheduler = nil -- timer for reconnect
    self.connectTimeTickScheduler = nil -- timer for connect timeout
    self.name = "TCPClient"
    self.tcp = nil
    self.isRetryConnect = __retryConnectWhenFailure
    self.isConnected = false
    self.buffer = nil
    self.seq = 0 -- 请求流水号
    self.loadingHintCount = 0 -- 网络请求指示器计数
end

function TCPClient:setName( __name )
    self.name = __name
    return self
end

function TCPClient:setTickTime( __time )
    SOCKET_TICK_TIME = __time
    return self
end
    
function TCPClient:setReconnTime( __time )
    SOCKET_RECONNECT_TIME = __time
    return self    
end

function TCPClient:setConnFailTime( __time )
    SOCKET_CONNECT_FAIL_TIMEOUT = __time
    return self
end

function TCPClient:connect( __host, __port, __retryConnectWhenFailure )
    if __host then self.host = __host end
    if __port then self.port = __port end
    if __retryConnectWhenFailure ~= nil then self.isRetryConnect = __retryConnectWhenFailure end
    assert(self.host and self.port, "Host and port are necessary!")
    self.tcp = socket.tcp()
    self.tcp:settimeout(0)
    
    local function __checkConnect()
        print("__checkConnect()")
        local __succ = self:_connect()
        if __succ then self:_onConnected() end
        return __succ
    end
        
    if not __checkConnect() then
        -- check whether connection is success
        -- the connection is failure if socket isn't connected after SOCKET_CONNECT_FAIL_TIMEOUT seconds
        local __connectTimeTick = function()
            print("__connectTimeTick")
            if self.isConnected then return end
            self.waitConnect = self.waitConnect or 0
            self.waitConnect = self.waitConnect + SOCKET_TICK_TIME
            if self.waitConnect >= SOCKET_CONNECT_FAIL_TIMEOUT then
                self.waitConnect = nil
                self:close()
                self:_connectFailure()
            end
            __checkConnect()
        end
        local scheduler = cc.Director:getInstance():getScheduler()
        self.connectTimeTickScheduler = scheduler:scheduleScriptFunc(__connectTimeTick, SOCKET_TICK_TIME, false)
    end
end
       
function TCPClient:close()
    self.tcp:close()
    local scheduler = cc.Director:getInstance():getScheduler()
    
    if self.connectTimeTickScheduler then scheduler:unscheduleScriptEntry(self.connectTimeTickScheduler) end 
    if self.tickScheduler then scheduler:unscheduleScriptEntry(self.tickScheduler) end
    if self.connectTimeTickScheduler then scheduler:unscheduleScriptEntry(self.connectTimeTickScheduler) end
    -- TODO: 分发连接关闭事件
    local event = cc.EventCustom:new(TCPClient.EVENT_CLOSE)
    self:dispatchEvent(event)
end

function TCPClient:disconnect()
    self:_disconnect()
    self.isRetryConnect = false -- initiative to disconnect, no reconnect
end

function TCPClient:addEventListener(name, callback)
    local listener = cc.EventListenerCustom:create(name, callback)
    self:addEventListenerWithFixedPriority(listener, 1)
    return listener
end

-- action: {seq, method, param}
function TCPClient:send( __action, __callback )
    assert(self.isConnected, self.name .. " is not connected.")
    if __callback then
        local _eventName = AppEvent.Network[__action.method]
        local _event = cc.EventCustom:new(_eventName)
        print("_eventName:", _eventName)
        self:addEventListener(_eventName, __callback)
    end
    
    local _request = {}
    
    -- 通行证
    _request.passport = GameCache.Auth["passport"] or ""
    
    -- 流水号
    __action.seq = __action.seq or self.seq + 1
    self.seq = __action.seq

    -- 序列化
    _request.actions = {__action}
    local _jsonData = json.encode(_request)
    dump(_jsonData)
    local _data = string.pack("IA", string.len(_jsonData), _jsonData)
    
    -- 发送
    self.tcp:send(_data)
end   

function TCPClient:sendMulti( __actionList, __callbackList )
    assert(self.isConnected, self.name .. " is not connected.")
    assert(__callbackList == nil or #__actionList == #__callbackList, "__callbackList should be nil or the same length as __actionList")
    if __callbackList then
        for _i, _action in ipairs(__actionList) do
            local _eventName = AppEvent.Network[_action.method]
            local _event = cc.EventCustom:new(_eventName)
            self:addEventListener(_eventName, __callbackList[_i])
        end
    end
    
    local _request = {}

    -- 通行证
    _request.passport = GameCache.Auth["passport"] or ""
    
    -- 流水号
    self.seq = self.seq + 1
    for _i, _action in ipairs(__actionList) do 
        _action.seq = _action.seq or self.seq  
    end
    
    _request.actions = __actionList
    
    -- 序列化
    local _jsonData = json.encode(_request)
    dump(_jsonData)
    local _data = string.pack("IA", string.len(_jsonData), _jsonData)

    -- 发送
    self.tcp:send(_data)
end

-------------------------------------------- private --------------------------------------------

function TCPClient:_connect()
    local __succ, __status = self.tcp:connect(self.host, self.port)
    print("_connect()", __succ, __status)
    return __succ == 1 or __status == STATUS_ALREADY_CONNECTED
end

function TCPClient:_disconnect()
    print("_disconnect()")
    self.isConnected = false
    -- TODO: 分发连接断开事件
    local event = cc.EventCustom:new(TCPClient.EVENT_CLOSED)
    event.name = TCPClient.EVENT_CLOSED
    self:dispatchEvent(event)
    
    self:_reconnect()
end

function TCPClient:_onDisconnect()
    self.isConnected = false
    local event = cc.EventCustom:new(TCPClient.EVENT_CLOSED)
    event.name = TCPClient.EVENT_CLOSED
    self:dispatchEvent(event)
    self:_reconnect()
end

function TCPClient:_onConnected()
    print("_onConnected()")
    self.isConnected = true
    -- TDOO: 分发连接成功事件
    local event = cc.EventCustom:new(TCPClient.EVENT_CONNECTED)
    event.name = TCPClient.EVENT_CONNECTED
    self:dispatchEvent(event)
    
    local scheduler = cc.Director:getInstance():getScheduler()
    if self.connectTimeTickScheduler then scheduler:unscheduleScriptEntry(self.connectTimeTickScheduler) end
    
    local __tick = function()
        while true do
            local __body, __status, __partial = self.tcp:receive("*a")
            if __status == STATUS_CLOSED or __status == STATUS_NOT_CONNECTED then
                self:close()
                if self.isConnected then
                    self:_onDisconnect()
                else
                    self:_connectFailure()
                end
                return
            end
            
            if __body then
                if self.buffer then 
                    self.buffer = self.buffer .. __body
                else
                    self.buffer = __body
                end
            end
            
            if __partial then
                if self.buffer then
                    self.buffer = self.buffer .. __partial
                else
                    self.buffer = __partial
                end
            end
            
            if string.len(self.buffer) > DATA_HEAD_LENGTH then
                local _headData = string.sub(self.buffer, 1, DATA_HEAD_LENGTH)
                _next, _val = string.unpack(_headData, "<I")
                local _dataLen = tonumber(_val)
--                print("_headData:", hex(_headData), "_dataLen:", _dataLen)
                
                if string.len(self.buffer) >= (DATA_HEAD_LENGTH + _dataLen) then
                    local _bodyData = string.sub(self.buffer, DATA_HEAD_LENGTH + 1, DATA_HEAD_LENGTH + _dataLen)
                    local _responseList = json.decode(_bodyData)
--                    dump(_responseList)

                    if #self.buffer > DATA_HEAD_LENGTH + _dataLen + 1 then
                        self.buffer = string.sub(self.buffer, DATA_HEAD_LENGTH + _dataLen + 1, #self.buffer)
                    else
                        self.buffer = nil
                    end
                    
                    for _i, _response in ipairs(_responseList) do
                        local _eventName = AppEvent.Network[_response.method]
                        local _event = cc.EventCustom:new(_eventName)
                        _event.name = _eventName
                        _event.status = _response.status
                        _event.result = _response.result
                        _event.last = (_i == #_responseList)
                        print("dispatchEvent:", _event.name)
                        self:dispatchEvent(_event)
                    end
                    
                    return
                end
            end        
        end
    end
    
    -- start to read TCP data
    self.tickScheduler = scheduler:scheduleScriptFunc(__tick, SOCKET_TICK_TIME, false)
end

function TCPClient:_connectFailure()
    -- TODO: 分发连接失败事件
    local event = cc.EventCustom:new(TCPClient.EVENT_CONNECT_FAILURE)
    self:dispatchEvent(event)
    self:_reconnect()
end         

function TCPClient:_reconnect( __immediately )
    if not self.isRetryConnect then return end
    printf("%s._reconnect", self.name)
    local scheduler = cc.Director:getInstance():getScheduler()
    if __immediately then self:connect() return end
    if self.reconnectScheduler then scheduler:unscheduleScriptEntry(self.reconnectScheduler) end
    local __doReconnect = function()
        self:connect()
    end
    self.reconnectScheduler = scheduler:scheduleScriptFunc(__doReconnect, SOCKET_RECONNECT_TIME, false)
end

function TCPClient:test()
    CCLog("TCPClient:test()")
end
    
return TCPClient
