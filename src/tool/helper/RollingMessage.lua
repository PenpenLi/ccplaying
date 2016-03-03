local heap = require("tool.lib.heap")

-------------------------------------------------------------------------------
local PANEL_WIDTH = display.width * 0.8
local PANEL_HEIGHT = 25
local FONT_SIZE = 24
local PANEL_SIZE = cc.size(PANEL_WIDTH, PANEL_HEIGHT)

local NODE_NAME = "roll_message_node"
local RollingMessage = class("QuickGuide")

function RollingMessage:getInstance()
    if not RollingMessage.__sharedInstance then
        RollingMessage.__sharedInstance = RollingMessage.new()
    end
    return RollingMessage.__sharedInstance
end

function RollingMessage:ctor(...)
 	self.messageQueue = heap(function(msg1, msg2)
 		return msg1.Priority < msg2.Priority
 	end)

 	self.node = nil
 end 

 function RollingMessage:pushMessage(message)
 	if message.StartTime == nil then
	 	message.StartTime = os.time()
	 end

 	self.messageQueue:insert(message)

 	if self.node and not tolua.isnull(self.node) then
 		if self.node:numberOfRunningActions() == 0 then
	 		RollingMessage.startUIAction(self.node)
	 	end
 	end
 end

 function RollingMessage:popMessage()
 	if self.messageQueue:empty() then
 		return nil
 	else
 		while not self.messageQueue:empty() do
 			local message = self.messageQueue:pop()
 			CCLog(vardump({message = message, time =  os.time(), endTime = message.StartTime + message.Duration, valid = message.StartTime + message.Duration > os.time()}))
 			local endTime = message.StartTime + message.Duration 
	 		if endTime > os.time() then
	 			local newMessage = clone(message)
	 			newMessage.Priority = message.Priority + 1
	 			self:pushMessage(message)

	 			return message 
	 		end
 		end
 	end
 	return nil
 end

 function RollingMessage.startUIAction(node)
    local createAction = nil
	createAction = function()
		return cc.CallFunc:create(function() 
			local message = RollingMessage:getInstance():popMessage()
			if message == nil then
				node:runAction(cc.Sequence:create({cc.DelayTime:create(0.1), cc.MoveTo:create(0.5, cc.p(display.width / 2, display.top + PANEL_HEIGHT))}))
			else
				CCLog(vardump(message, "Message"))
				node:runAction(cc.Sequence:create({
					cc.DelayTime:create(0.1), 
					cc.MoveTo:create(0.5, cc.p(display.width / 2, display.top - PANEL_HEIGHT / 2)),
					cc.CallFunc:create(function() 						
						local labelMessage = Common.finalFont(message.Content, 0, 0, FONT_SIZE, cc.c3b(20, 250, 20), 0)
		                labelMessage:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
		                --labelMessage:setDimensions(PANEL_WIDTH, PANEL_HEIGHT)
		                labelMessage:setPosition(cc.p(PANEL_WIDTH, PANEL_HEIGHT / 2 + 1))
		                labelMessage:setAnchorPoint(cc.p(0, 0.5))
						node:addChild(labelMessage)

		                local contentSize = labelMessage:getContentSize()
		                CCLog(vardump(contentSize, "contentSize"))
		                local distance = PANEL_WIDTH + contentSize.width
		                local useTime = distance / (PANEL_WIDTH / 8.0)						

						labelMessage:runAction(cc.Sequence:create({cc.MoveBy:create(useTime, cc.p(-distance, 0)), cc.RemoveSelf:create()}))
						node:runAction(cc.Sequence:create({cc.DelayTime:create(useTime + 0.5), createAction(),}))
					end),					
				}))			

			end
		end)
	end

    node:runAction(createAction())
 end

 function RollingMessage.createUI(...)
 	local node = ccui.Layout:create()
 	node:setPosition(cc.p(display.width / 2, display.top + PANEL_HEIGHT))
 	node:setAnchorPoint(cc.p(0.5, 0.5))
 	node:setContentSize(cc.size(PANEL_WIDTH, PANEL_HEIGHT * 2))
 	--node:setBackGroundImage("image/ui/img/bg/bg_151.png")
 	node:setClippingEnabled(true)

 	local spriteBg = cc.Scale9Sprite:create("image/ui/img/bg/bg_151.png")
    spriteBg:setContentSize(PANEL_SIZE)
    spriteBg:setAnchorPoint(cc.p(0, 0))
    spriteBg:setPosition(cc.p(0, 0))
    node:addChild(spriteBg)

    RollingMessage.startUIAction(node)

    RollingMessage:getInstance().node = node
 	
 	node:setName(NODE_NAME)

 	return node
 end

 return RollingMessage