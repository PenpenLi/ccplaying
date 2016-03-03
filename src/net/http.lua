-- http client
-- author: caojun

local LoadingWaitLayer = require("tool.helper.LoadingWaitLayer")

local RETRY_MAX_COUNT = 5

local HttpClient = {}
HttpClient.loading = 0
HttpClient.loadingLayer = nil
HttpClient.failCount = 0
HttpClient.retryCount = 0

function HttpClient.showLoading()
    -- HttpClient.loading = HttpClient.loading + 1
    local runningScene = cc.Director:getInstance():getRunningScene()
    if runningScene == nil then
        return 
    end

    if not HttpClient.loadingLayer or tolua.isnull(HttpClient.loadingLayer) then
        HttpClient.loadingLayer = LoadingWaitLayer.new()
        runningScene:addChild(HttpClient.loadingLayer)
    end
end

function HttpClient.hideLoading()
    -- HttpClient.loading = HttpClient.loading - 1
    if HttpClient.loadingLayer and not tolua.isnull(HttpClient.loadingLayer) then
        HttpClient.loadingLayer:removeFromParent()
        HttpClient.loadingLayer = nil
    end
end

function showErrMsg(rsp, errMsg)
    if errMsg then
        if rsp and rsp.status then
            local msg = string.format("status: %d\nmessage: %s\n", rsp.status, errMsg)
            application:showFlashNotice(msg)
        else
            application:showFlashNotice("网络异常:" .. errMsg)
        end
    end
end

-- url: 服务器地址
-- data: 数据
-- cbRsp: 正常响应回调
-- cbErr: 错误回调
-- params: 控制参数
function HttpClient.post(url, data, cbRsp, cbErr, _params)
    local params = _params or {show=true, debug=true}

    local xhr = cc.XMLHttpRequest:new()
    xhr.verbose = false
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_BLOB
    xhr.timeout = params.timeout or 30 -- default set to 30 seconds
    local dev = CurrentDevice
    xhr:setRequestHeader("deviceid", dev.deviceId)
    xhr:setRequestHeader("idfa", dev.idfa)
    xhr:setRequestHeader("idfv", dev.idfv)
    xhr:setRequestHeader("model", dev.model)
    xhr:setRequestHeader("system", dev.system)
    xhr:setRequestHeader("version", dev.version)
    xhr:setRequestHeader("resolution", dev.resolution)
    xhr:open("POST", url, true)

    local function _onReadyStateChange()
        local errMsg = xhr.error
        if xhr.readyState == 4 and xhr.status == 200 then
            -- CCLog("ok----------------> ", xhr.readyState, ", ", xhr.status)
            HttpClient.failCount = 0
            HttpClient.retryCount = 0

            if cbRsp then cbRsp(xhr.response) end
        else
            -- CCLog("error----------------> ", xhr.readyState, ", ", xhr.status)
            HttpClient.failCount = HttpClient.failCount + 1
            if cbErr then cbErr(xhr.response, errMsg) end

            if params.retryOnError and HttpClient.retryCount < RETRY_MAX_COUNT then    
                HttpClient.retryCount = HttpClient.retryCount + 1   
                CCLog("失败重连" .. HttpClient.retryCount)         

                application:scheduleAction(function() 
                    HttpClient.post(url, data, cbRsp, cbErr, _params) 
                end)
            else
                HttpClient.retryCount = 0
                --CCLog(vardump(params))
                local alertError = params.alertError or params.alertError == nil
                if alertError then
                    showErrMsg(rsp, errMsg)
                end
            end
        end

        HttpClient.hideLoading()
    end

    if params.show then
        HttpClient.showLoading()
    end

    xhr:registerScriptHandler(_onReadyStateChange)
    xhr:send(data)
end

-- url: 服务器地址
-- cbRsp: 正常响应回调
-- cbErr: 错误回调
-- params: 控制参数
function HttpClient.get(url, cbRsp, cbErr, _params)
    local params = _params or {show=true, debug=true}
    
    if params.debug then
        CCLog("url: ", url)
    end

    local xhr = cc.XMLHttpRequest:new()
    xhr.verbose = false
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_BLOB
    xhr.timeout = params.timeout or 30 -- default set to 30 seconds
    local dev = CurrentDevice
    xhr:setRequestHeader("deviceid", dev.deviceId)
    xhr:setRequestHeader("idfa", dev.idfa)
    xhr:setRequestHeader("idfv", dev.idfv)
    xhr:setRequestHeader("model", dev.model)
    xhr:setRequestHeader("system", dev.system)
    xhr:setRequestHeader("version", dev.version)
    xhr:setRequestHeader("resolution", dev.resolution)
    xhr:open("GET", url)

    local function _onReadyStateChange()
        local errMsg = xhr.error
        if xhr.readyState == 4 and xhr.status == 200 then            
            if cbRsp then cbRsp(xhr.response) end
        else       
            if cbErr then cbErr(rsp, errMsg) end
            showErrMsg(rsp, errMsg)
        end

        HttpClient.hideLoading()
    end
 
    if params.show then
        HttpClient.showLoading()
    end

    xhr:registerScriptHandler(_onReadyStateChange)
    xhr:send()
end

return HttpClient
