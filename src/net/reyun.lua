-- reyun

local ReyunLog = {}
ReyunLog.channel = GAME_BASE_INFO.channel
ReyunLog.addr = "http://log.reyun.com"
ReyunLog.isEnable = false

if device.platform == "ios" then
	ReyunLog.appId = "8337c8b90746600889531da46b652fc5"
elseif device.platform == "android" then
	ReyunLog.appId = "8f52392c0e60d74734cb165ebab8cd3e"
end

if ReyunLog.appId ~= nil then
	ReyunLog.isEnable = true
end

function ReyunLog.post(url, data)
	local xhr = cc.XMLHttpRequest:new()
    xhr.verbose = false
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_BLOB
    xhr.timeout = 30 
    xhr:setRequestHeader("Content-Type", "application/json")

    xhr:open("POST", url, true)

    local function _onReadyStateChange()
        local errMsg = xhr.error
        if xhr.readyState == 4 and xhr.status == 200 then
            CCLog("ok (", url, ") ----------------> ", xhr.readyState, ", ", xhr.status, ", ", xhr.response)
        else
            CCLogf("error (", url, ") ----------------> ", xhr.readyState, ", ", xhr.status)
        end
    end
    xhr:registerScriptHandler(_onReadyStateChange)
    xhr:send(data)
end

-- 首次启动游戏
function ReyunLog.install()
	if not ReyunLog.isEnable then
		return
	end

	local url = ReyunLog.addr .. "/receive/rest/install"
	local ctx = {deviceid = CurrentDevice.deviceId, idfa = CurrentDevice.idfa, idfv = CurrentDevice.idfv, channelid = ReyunLog.channel}
	local body = {appid = ReyunLog.appId, context = ctx}
	local data = json.encode(body)
	CCLog("ReyunLog.install: ", url, "\n", data)
	ReyunLog.post(data)
end

-- 启动游戏
function ReyunLog.startUp()
	if not ReyunLog.isEnable then
		return
	end

	local url = ReyunLog.addr .. "/receive/rest/startup"
	local ctx = {deviceid = CurrentDevice.deviceId, idfa = CurrentDevice.idfa, idfv = CurrentDevice.idfv, channelid = ReyunLog.channel, 
	tz = "", devicetype = CurrentDevice.deviceModel,  op = "", network = "", os = CurrentDevice.os, resolution = CurrentDevice.resolution}
	local body = {appid = ReyunLog.appId, context = ctx}
	local data = json.encode(body)
	CCLog("ReyunLog.startUp: ", url, "\n", data)
	ReyunLog.post(url, data)
	scheduleHeartbeat()
end

-- 在线心跳
function heartbeat(rid, sid, lvl)
	if not ReyunLog.isEnable then
		return
	end

	local url = ReyunLog.addr .. "/receive/rest/heartbeat"
	local ctx = {deviceid = CurrentDevice.deviceId, serverid = sid, channelid = ReyunLog.channel, level = lvl}
	local body = {appid = ReyunLog.appId, who = rid, context = ctx}
	local data = json.encode(body)
	CCLog("ReyunLog.heartbeat: ", url, "\n", data)
	ReyunLog.post(url, data)
end

function scheduleHeartbeat()
	local scheduler = cc.Director:getInstance():getScheduler()
    scheduler:scheduleScriptFunc(function ()
    	if GameCache.Avatar ~= nil then
			heartbeat(GameCache.Avatar.RID, GameCache.Avatar.SID, GameCache.Avatar.Level)
		end
    end, 5, false)
end

-- 注册角色
function ReyunLog.register(rid, sid)
	if not ReyunLog.isEnable then
		return
	end

	local url = ReyunLog.addr .. "/receive/rest/register"
	local ctx = {deviceid = CurrentDevice.deviceId, idfa = CurrentDevice.idfa, idfv = CurrentDevice.idfv, channelid = ReyunLog.channel, serverid = sid}
	local body = {appid = ReyunLog.appId, who = rid, context = ctx}
	local data = json.encode(body)
	CCLog("ReyunLog.register: ", url, "\n", data)
	ReyunLog.post(url, data)
end

-- 登陆角色
function ReyunLog.login(rid, sid, lvl)
	if not ReyunLog.isEnable then
		return
	end

	local url = ReyunLog.addr .. "/receive/rest/loggedin"
	local ctx = {deviceid = CurrentDevice.deviceId, idfa = CurrentDevice.idfa, idfv = CurrentDevice.idfv, channelid = ReyunLog.channel, serverid = sid, level = lvl}
	local body = {appid = ReyunLog.appId, who = rid, context = ctx}
	local data = json.encode(body)
	CCLog("ReyunLog.login: ", url, "\n", data)
	ReyunLog.post(url, data)
end

-- -- 内购(充值)
-- function ReyunLog.payment(rid, sid, lvl, payinfo)
-- 	if not ReyunLog.isEnable then
-- 		return
-- 	end

-- 	local url = ReyunLog.addr .. "/receive/rest/payment"
-- 	CCLog("url:", url)
-- 	local ctx = {deviceid = ReyunLog.deviceId, idfa = ReyunLog.idfa, idfv = ReyunLog.idfv, channelid = ReyunLog.channel, serverid = sid, level = lvl, 
-- 		transactionid = payinfo.transId,  -- 交易流水号
-- 		paymenttype = payinfo.payType, -- 支付类型
-- 		currencytype = payinfo.currencyType, -- 货币类型
-- 		currencyamount = payinfo.price, -- 货币金额
-- 		virtualcoinamount = payinfo.gold, -- 元宝数量
-- 		iapname = payinfo.name, -- 内购项名称
-- 		iapamount = payinfo.num --  内购项数量
-- 	}
-- 	local body = {appid = ReyunLog.appId, who = rid, context = ctx}
-- 	local data = json.encode(body)
-- 	CCLog("ReyunLog.payment param: ", data)
-- 	ReyunLog.post(url, data)
-- end

-- -- 虚拟货币交易（货币类型物品）
-- function ReyunLog.economy(rid, sid, lvl, costInfo)
-- 	if not ReyunLog.isEnable then
-- 		return
-- 	end

-- 	local url = ReyunLog.addr .. "/receive/rest/economy"
-- 	CCLog("url:", url)
-- 	local ctx = {deviceid = ReyunLog.deviceId, idfa = ReyunLog.idfa, idfv = ReyunLog.idfv, channelid = ReyunLog.channel, serverid = sid, level = lvl, 
-- 		itemname = costInfo.name,  -- 虚拟物品名称
-- 		itemamount = costInfo.num, -- 虚拟物品数量
-- 		itemtotalprice = itemamount, -- 交易总价
-- 	}
-- 	local body = {appid = ReyunLog.appId, who = rid, context = ctx}
-- 	local data = json.encode(body)
-- 	CCLog("ReyunLog.economy param: ", data)
-- 	ReyunLog.post(url, data)
-- end

-- ReyunLog.STATUS_BEGIN = "a"
-- ReyunLog.STATUS_END = "c"
-- ReyunLog.STATUS_FAIL = "f"

-- -- 副本状态
-- function ReyunLog.quest(rid, sid, lvl, questInfo)
-- 	if not ReyunLog.isEnable then
-- 		return
-- 	end

-- 	local url = ReyunLog.addr .. "/receive/rest/quest"
-- 	CCLog("url:", url)
-- 	local ctx = {deviceid = ReyunLog.deviceId, idfa = ReyunLog.idfa, idfv = ReyunLog.idfv, channelid = ReyunLog.channel, serverid = sid, level = lvl, 
-- 		questid = questInfo.name,  -- 当前任务/关卡/副本的名称
-- 		queststatus = questInfo.status, -- 当前任务/关卡/副本的状态，有如下三种类型：开始：a 完成：c 失败：f
-- 		questtype = questInfo.type, -- 当前任务/关卡/副本的类型，例如： 新手任务：new 主线任务：main 支线任务：sub 开发者也可以根据自己游戏的特点自定义类型
-- 	}
-- 	local body = {appid = ReyunLog.appId, who = rid, context = ctx}
-- 	local data = json.encode(body)
-- 	CCLog("ReyunLog.quest param: ", data)
-- 	ReyunLog.post(url, data)
-- end

return ReyunLog
