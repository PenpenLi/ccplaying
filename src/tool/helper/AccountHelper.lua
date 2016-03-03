local KEY_ACCOUNT = "accountName"

local function getAccountFullKeyList()
    local keyList = {}

    for idx, addr in ipairs(LOGING_SERVERS) do
        local k = addr .. '@' .. KEY_ACCOUNT
        table.insert(keyList, k)
    end
    return keyList
end

local function saveAccountKeyListData(str)
    local keyList = getAccountFullKeyList()

    for idx, key in ipairs(keyList) do
        cc.UserDefault:getInstance():setStringForKey(key, str)
    end
end

-- 获取帐号映射
local function getAccountMap()
    local function getOneAccountMap(k)
        local jsonStr = cc.UserDefault:getInstance():getStringForKey(k)

        CCLog("account map", jsonStr)

        local accountMap
        if jsonStr then
            accountMap = json.decode(jsonStr)
        end

        if type(accountMap) ~= "table" then
            accountMap = {}
        end

        return accountMap
    end

    local allAccountMap = {}

    local keyList = getAccountFullKeyList()
    for idx, key in ipairs(keyList) do
        local oneMap = getOneAccountMap(key)

        for k, v in pairs(oneMap) do
            allAccountMap[k] = v
        end
    end

    return allAccountMap
end

-- 获取帐号列表
local function getAccountList()
    local accountMap = getAccountMap()

    local accountList = {}

    for name, account in pairs(accountMap) do
        table.insert(accountList, account)
    end
    table.sort(accountList, function(a, b) return a.lastLoginTime > b.lastLoginTime end)

    CCLog("account list", vardump(accountList))

    return accountList
end

-- 通过显示名获取帐号信息
local function getAccountByDisplayName(displayName)
    local accountList = getAccountList()
    for idx, account in ipairs(accountList) do
        if account.displayName == displayName then
            return account
        end
    end
    return nil
end

-- 获取最后登录的帐号
local function getLastLoginAccount()
    local accountList = getAccountList()
    if #accountList == 0 then
        return nil
    else
        return accountList[1]
    end
end

-- 生成显示用的游客名
local function genGuestAccountName(name)
    return "游客" .. name
end

-- 更新最近登录的帐号
local function updateLastLoginAccount(newAccount)
    local accountMap = getAccountMap()

    if newAccount.guest then
        if newAccount.displayName == nil then
            newAccount.displayName = genGuestAccountName(newAccount.name)
        end
    else
        newAccount.displayName = newAccount.name
    end
    newAccount.lastLoginTime = os.time()
    accountMap[newAccount.name] = newAccount

    local jsonStr = json.encode(accountMap)

    CCLog("update account list", jsonStr)

    saveAccountKeyListData(jsonStr)
end

local function deleteAccount(account)
    local accountMap = getAccountMap()

    accountMap[account.name] = nil

    local jsonStr = json.encode(accountMap)

    CCLog("update account list", jsonStr)

    saveAccountKeyListData(jsonStr)
end

-- 保存帐号列表
local function saveAccountList(accountList)
    local accountMap = {}

    for idx, account in ipairs(accountList) do
        accountMap[account.name] = account
    end

    local jsonStr = json.encode(accountMap)

    CCLog("save account list", jsonStr)

    saveAccountKeyListData(jsonStr)
end

-- 邮箱地址是否合法
local function isRightEmail(str)
    if string.len(str or "") < 6 then return false end
    local b,e = string.find(str or "", '@')
    local bstr = ""
    local estr = ""
    if b then
        bstr = string.sub(str, 1, b-1)
        estr = string.sub(str, e+1, -1)
    else
        return false
    end

    -- check the string before '@'
    local p1,p2 = string.find(bstr, "[%w_.]+")
    if (p1 ~= 1) or (p2 ~= string.len(bstr)) then return false end

    -- check the string after '@'
    if string.find(estr, "^[%.]+") then return false end
    if string.find(estr, "%.[%.]+") then return false end
    if string.find(estr, "@") then return false end
    if string.find(estr, "[%.]+$") then return false end

    _,count = string.gsub(estr, "%.", "")
    if (count < 1 ) or (count > 3) then
        return false
    end

    return true
end

local function url_escape(str)
    if type(str) ~= "string" then
        return ""
    end
    local pattern = "^A-Za-z0-9%-%._~"
    str = str:gsub("[" .. pattern .. "]",function(c) return string.format("%%%02X",string.byte(c)) end)
    return str
end

-- 生成注册URL
local function REGISTER_URL(account)
    local name = assert(account.name, "account name")
    local password = assert(account.password, "account password")
    local guest = account.guest
    local email = account.email or ""
    local major = GetAppVersion()
    local patch = GetUpdatedVersion()

    local url = LOGIN_SERVER_ADDR .. "/regist?"
    url = string.format("%susername=%s&password=%s&channel=%s&guest=%s&email=%s&major=%s&patch=%s", url, name, password, GAME_BASE_INFO.channel, tostring(guest), email, major, patch)
    return url
end

local function BIND_GUEST_URL(account, key)
    local name = assert(account.name, "account name")
    local password = assert(account.password, "account password")
    local email = account.email or ""
    local major = GetAppVersion()
    local patch = GetUpdatedVersion()
    local url = LOGIN_SERVER_ADDR .. "/binding?"
    url = string.format("%susername=%s&password=%s&channel=%s&email=%s&key=%s&major=%s&patch=%s", url, name, password, GAME_BASE_INFO.channel, email, key, major, patch)

    return url
end

local function RETRIEVE_PASSWORD_URL(accountName)
    local accountName = assert(accountName, "account name")
    local major = GetAppVersion()
    local patch = GetUpdatedVersion()
    local url = LOGIN_SERVER_ADDR .. "/password/forget?"
    url = string.format("%susername=%s&channel=%s", url, accountName, GAME_BASE_INFO.channel)

    return url
end

local function MODIFY_PASSWORD_URL(account, old_password, new_password, new_email, key)
    local name = assert(account.name, "account name")
    local major = GetAppVersion()
    local patch = GetUpdatedVersion()
    local url = LOGIN_SERVER_ADDR .. "/password/modify?"
    url = string.format("%susername=%s&oldpassword=%s&newpassword=%s&channel=%s&email=%s&key=%s&major=%s&patch=%s",
                         url, name, old_password, new_password, GAME_BASE_INFO.channel, new_email, key, major, patch)

    return url
end

-- 生成 登录URL
local function LOGIN_URL(account)
    local name = account.name
    local password = account.password
    local guest = account.guest

    local major = GetAppVersion()
    local patch = GetUpdatedVersion()

    -- local _E = url_escape

    local url = LOGIN_SERVER_ADDR .. "/login?"
    url = string.format("%susername=%s&password=%s&channel=%s&guest=%s&major=%s&patch=%s"
        , url, name, password, GAME_BASE_INFO.channel, tostring(guest), major, patch)

    return url
end

-- 生成 登录URL
local function SDK_LOGIN_URL(name, token, uid)
    local major = GetAppVersion()
    local patch = GetUpdatedVersion()

    local url = LOGIN_SERVER_ADDR .. "/login/" .. GAME_BASE_INFO.SDK
    local data  = json.encode({username = name, token = token, uid = uid, channel = GAME_BASE_INFO.channel, major = major, patch = patch})
    return url, data
end

-- 生成 进入游戏URL
local function ENTER_GAME_URL(key, sid, majorv, patchv)
    local url = string.format("%s/start?key=%s&sid=%s&major=%s&patch=%s", LOGIN_SERVER_ADDR, key, sid, majorv, patchv)
    return url
end

-- 生成 随机名字
local function randomName()
    return string.format("%08x%02x%02x%02x", os.time(), math.random(0, 0xff), math.random(0, 0xff), math.random(0, 0xff), math.random(0, 0xff))
end

-- 生成 随机密码
local function randomPassword()
    return string.format("%02x%02x%02x", os.time(), math.random(0, 0xff), math.random(0, 0xff), math.random(0, 0xff))
end

function checkAccountName(str)
    local len = #str
    return len >= 4 and len <= 8 and (string.find(str, "^[%a%d]*$") ~= nil)
end

function checkPassword(str)
    local len = #str
    return len >= 6 and len <= 16 and (string.find(str, "^[%a%d]*$") ~= nil)
end

local AccountHelper = {}

AccountHelper.getAccountFullKeyList = getAccountFullKeyList
AccountHelper.getAccountMap = getAccountMap
AccountHelper.getAccountList = getAccountList
AccountHelper.getAccountByDisplayName = getAccountByDisplayName
AccountHelper.getLastLoginAccount = getLastLoginAccount
AccountHelper.genGuestAccountName = genGuestAccountName
AccountHelper.updateLastLoginAccount = updateLastLoginAccount
AccountHelper.deleteAccount = deleteAccount
AccountHelper.saveAccountList = saveAccountList
AccountHelper.isRightEmail = isRightEmail
AccountHelper.REGISTER_URL = REGISTER_URL
AccountHelper.BIND_GUEST_URL = BIND_GUEST_URL
AccountHelper.RETRIEVE_PASSWORD_URL = RETRIEVE_PASSWORD_URL
AccountHelper.MODIFY_PASSWORD_URL = MODIFY_PASSWORD_URL
AccountHelper.LOGIN_URL = LOGIN_URL
AccountHelper.SDK_LOGIN_URL = SDK_LOGIN_URL
AccountHelper.ENTER_GAME_URL = ENTER_GAME_URL
AccountHelper.randomName = randomName
AccountHelper.randomPassword = randomPassword
AccountHelper.checkAccountName = checkAccountName
AccountHelper.checkPassword = checkPassword

return AccountHelper
