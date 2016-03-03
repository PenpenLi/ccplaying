require("app.ServerConfig")

TIPS_MAIL = 1
TIPS_FRIEND = 2
TIPS_GAMBLE = 3
TIPS_TASK = 4
TIPS_ACTIVITY = 5
TIPS_SYNC_FRIEND = 6
TIPS_HOME = 7
TIPS_ENERGY = 8


math.randomseed(os.time())

require("socket.core")
require("tool.lib.debug")
display = require("tool.lib.display")
require("tool.lib.functions")
json = require("tool.lib.json")
utf8 = require("tool.lib.utf8")
enums = require("app.enums")
inspect = require("tool.lib.inspect")

require("tool.helper.uiHelper")
require("tool.helper.MixSprite")

CurrentDevice = require("app.device")

BaseLayer = require("tool.helper.BaseLayer")   
AppEvent = require("app.AppEvent")
BaseConfig = require("config.BaseConfig")
BaseConfig.preLoad()

GameCache = require("cache.GameCache")
Common = require("tool.helper.Common") 
GoodsInfoNode = require("tool.helper.GoodsInfoIcon")

local fileUtils = cc.FileUtils:getInstance()
fileUtils:addSearchPath("res/dummy")
CCLog("searchPaths:", vardump(fileUtils:getSearchPaths()))

Exceptions = require("net.exceptions")

ReyunLog = require("net.reyun")
print("require reyun")

if rpc and not tolua.isnull(rpc)  then
	CCLog("rpc:refcount:", rpc:getReferenceCount())
	rpc:release()
end

rpc = require("net.rpc").new()
bitarray2d = require("bitarray2d")
Threads = require("tool.lib.llthreads2.ex")

function switchLoginServerAddress()
	CCLog("switchLoginServerAddress")
	CCLog("servers: ", LOGING_SERVERS)
	LOGIN_SERVER_ADDR = LOGING_SERVERS[2] or LOGING_SERVERS[1]
	CCLog("登陆服务器: ", LOGIN_SERVER_ADDR)
end
