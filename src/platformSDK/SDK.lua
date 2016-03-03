local luaj = require("cocos.cocos2d.luaj")
local json = require("tool.lib.json")
local sdkConfig = import(".config")

local function isSandbox()
    return GameCache.isExamine
end

function SDK_init()
	CCLog("SDK_init")	

	local args = {}
    local sigs = "()V"
    
    local className = "org/cocos2dx/lua/SDKAdapter"
    local ok,ret  = luaj.callStaticMethod(className,"initLua", args, sigs)
    if not ok then
        print("luaj error:", ret)
    else
        print("The ret is:", ret)
    end
end

function SDK_doLogin(callback)
	assert(type(callback) == "function", "SDK_doLogin callback must be function")
	CCLog("SDK_doLogin")

	local callInfo = json.encode({method = "sdkDoLogin"})
	print(callInfo)
	local args = {callback , callInfo}
    local sigs = "(ILjava/lang/String;)V"
    
    local className = "org/cocos2dx/lua/SDKAdapter"
    local ok,ret  = luaj.callStaticMethod(className,"invoke", args, sigs)
    if not ok then
        print("luaj error:", ret)
    else
        print("The ret is:", ret)
    end
end

function SDK_doLogout(callback)
	assert(type(callback) == "function", "SDK_doLogin callback must be function")
	CCLog("SDK_doLogin")

	local callInfo = json.encode({method = "sdkDoLogout"})
	print(callInfo)
	local args = {callback , callInfo}
    local sigs = "(ILjava/lang/String;)V"
    
    local className = "org/cocos2dx/lua/SDKAdapter"
    local ok,ret  = luaj.callStaticMethod(className,"invoke", args, sigs)
    if not ok then
        print("luaj error:", ret)
    else
        print("The ret is:", ret)
    end
end

-- String order = json.getString("order");
-- String attach = json.optString("attach", "");
-- int amount = json.getInt("amount");
-- String productName = json.getString("productName");
-- String productDesc = json.optString("productDesc", "");
-- String callbackUrl = json.getString("callbackUrl");

	-- {
	-- 	ID      = 5,
	-- 	Money   = 328,
	-- 	Gold    = 3280,
	-- 	Present = 4980,
	-- 	IAPID   = "com.ccplaying.d1.iap328"
	-- },

function SDK_doPay(orderID, item, payCallBack)
	CCLog("SDK_doPay", vardump(item))
	local base64 = require("tool.lib.base64")

	-- local serverId    = tostring(GameCache.Avatar.SID)
 --    local roleId      = tostring(GameCache.Avatar.RID)

    local order       = tostring(orderID)
    local attach      = base64.encode(orderID)
    local amount      = item.Money * 100 -- 元 * 100 = 分
    local productName = string.format("%d元宝", item.Gold)
    local productDesc = string.format("充%d元宝，赠送%d元宝", item.Gold, item.Present)
    local callbackUrl = sdkConfig.PayCallback

    -- TODO:充值测试
	if isSandbox() then
		amount = 1
	end

    local params = {
    	method      = "sdkDoPay",
		order 		= order,
		attach		= attach,
		amount 		= amount,
		productName = productName,
		productDesc = productDesc,
		callbackUrl = callbackUrl,
	}

	local function callback(jsonStr)
		print(jsonStr)
		if payCallBack then
			xpcall(function()
				local info = json.decode(jsonStr)
				payCallBack(info and info.status or "failure")
			end, __G__TRACKBACK__)
		end
		--application:hideLoading()
	end

	local callInfo = json.encode(params)
	print(callInfo)
	local args = {callback , callInfo}
    local sigs = "(ILjava/lang/String;)V"
    
    local className = "org/cocos2dx/lua/SDKAdapter"
    local ok,ret  = luaj.callStaticMethod(className,"invoke", args, sigs)
    if not ok then
        print("luaj error:", ret)
    else
        print("The ret is:", ret)
        --application:showLoading()
    end
end

