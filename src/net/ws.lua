
-- TODO:
local function test()
	local inspect = require("tool.lib.inspect")
	ws = cc.WebSocket:create("ws://localhost:8001/")

    local function WS_onOpen(strData)
        print("WebSocket open", strData)

        ws:sendString("Hello, \0\1中华人民共和国")
		print("WebSocket test")
    end

    local function WS_onMessage(paramTable)
    	print("WebSocket message:", type(paramTable), hex(paramTable))
    end

    local function WS_onClose(strData)
        print("WebSocket instance closed.", strData)
    end

    local function WS_onError(strData)
        print("WebSocket Error was fired", strData)
    end

	ws:registerScriptHandler(WS_onOpen, cc.WEBSOCKET_OPEN)
	ws:registerScriptHandler(WS_onMessage, cc.WEBSOCKET_MESSAGE)
	ws:registerScriptHandler(WS_onClose, cc.WEBSOCKET_CLOSE)
	ws:registerScriptHandler(WS_onError, cc.WEBSOCKET_ERROR)


end
