--
-- Author: keyring
-- Date: 2015-04-13 17:34:00
--

local HeroNode = require("tool.helper.HeroAction")
local EffectManager = require("tool.helper.Effects")
local EventDispatcher = require("scene.story.StoryEventDispatcher")



local BaseStory = class("BaseStory", function (  )
	return cc.Layer:create()
end)

function BaseStory:ctor( callback )
	self.idx = 1
	self.istouch = false
	self.lasticon = nil
	self.message = {}
	_callback = callback

	self.dispatcher = EventDispatcher:newDispatcher()

	self.event_init_ended = "INIT_ENDED"
	self.event_dialog_ended = "DIALOG_ENDED"

    local box = ccui.ImageView:create("dummy/dialog_bg.jpg")
    box:setPosition(SCREEN_WIDTH*0.5,SCREEN_HEIGHT*0.1)
    box:setScale9Enabled(true)
    box:setContentSize(SCREEN_WIDTH,193)
    box:setVisible(false)
    self:addChild(box,1)

    self.box = box
    self.boxsize = box:getContentSize()

    local namebg = cc.Scale9Sprite:create("image/ui/img/btn/btn_801.png")
    namebg:setContentSize(cc.size(150,55))
    box:addChild(namebg, 1)
    self.sprite_name = namebg

    local label_name = Common.systemFont("", 1, 1 ,22)
    label_name:setPosition(75, 27)
    label_name:setColor(cc.c3b(255,255,0))
    label_name:setLineBreakWithoutSpace(false)
    namebg:addChild(label_name)
    self.label_name = label_name


    local content = Common.systemFont("", 1, 1 ,25)
    content:setAnchorPoint(0,0.5)
    content:setLineBreakWithoutSpace(false)
    content:setDimensions(self.boxsize.width*0.4, self.boxsize.height*0.9)
    content:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    content:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    box:addChild(content,1)
    self.label_content = content


    -- self.jiantou = EffectManager:CreateAnimation(box, 0, 0, nil, 2, true)
    local jiantou = sp.SkeletonAnimation:create("image/spine/ui_effect/17/skeleton.skel", "image/spine/ui_effect/17/skeleton.atlas", 1.0)
    jiantou:setAnimation(0,"animation",true)
    box:addChild(jiantou, 1)
    self.jiantou = jiantou

    local tiaoguo = ccui.MixButton:create("image/ui/img/btn/btn_553.png")
    tiaoguo:setScale9Size(cc.size(125,55))
    tiaoguo:setTitle("跳过",24, cc.c3b(255,231,148))
    tiaoguo:setPosition(SCREEN_WIDTH*0.9 , SCREEN_HEIGHT*0.9) 
    tiaoguo:addTouchEventListener(function (sender, eventType) 
        if eventType == ccui.TouchEventType.ended then
            self:StoryEnd()
        end
    end)
    self:addChild(tiaoguo)


    local function onTouchBegan(touch, event)
        return true
    end
    local function onTouchEnded(touch, event)
        if self.istouch then
            self.dispatcher:dispatch(self.event_dialog_ended, self.message[self.idx-1].msg)
        else
            self:DialogBoxVisible(false)
        end 
    end
    
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self) 

end

function BaseStory:AddDialogEndEvent( fun )
	self.dispatcher:listenEvent(self.event_dialog_ended, fun)
end

function BaseStory:AddInitEndEvent( fun )
	self.dispatcher:listenEvent(self.event_init_ended, fun)
end

function BaseStory:SendEvent( eventname )
	self.dispatcher:dispatch(eventname)
end

function BaseStory:CreateEffect( x, y, id )
	EffectManager:CreateAnimation(self, x, y, nil, id)
end

function BaseStory:CreatePerson(x,y, id, skins )
	local person = HeroNode.new(x,y,id, skins)
	person:setVisible(false)
    person:setTouchEnabled(false)
	self:addChild(person)
	return person
end

function BaseStory:CreateProp(x,y, path )
    local skel = path .."/skeleton.skel"
    local atlas = path .."/skeleton.atlas"

    local animation = sp.SkeletonAnimation:create(skel, atlas, 1)
    animation:setPosition(x,y)

    animation:setVisible(false)
    animation:setAnimation(0, "idle", true)

    self:addChild(animation)
    return animation
end

function BaseStory:CreateMonster(x,y, name )
    local monster = cc.Node:create()

    local shadow = cc.Sprite:create("image/ui/img/btn/btn_249.png")
    shadow:setScale(0.24)
    monster:addChild(shadow)

    local skel = "image/spine/monster/"..name .. "/skeleton.skel"
    local   json = "image/spine/monster/"..name .. "/skeleton.json"
    local   atlas = "image/spine/monster/" .. name .."/skeleton.atlas"
    local scale = 1

    local animation = nil
    if cc.FileUtils:getInstance():isFileExist(skel) then
        animation = sp.SkeletonAnimation:create(skel, atlas, scale)
    elseif cc.FileUtils:getInstance():isFileExist(json) then
        animation = sp.SkeletonAnimation:create(json, atlas, scale)
    else
        json = "image/spine/monster/xj_1000/skeleton.json"
        atlas = "image/spine/monster/xj_1000/skeleton.atlas"
        animation = sp.SkeletonAnimation:create(json, atlas, scale)
    end

    animation:setAnimation(0, "idle", true)

    monster:addChild(animation)
    monster:setVisible(false)
    monster:setPosition(x, y)  

    self:addChild(monster)


    -- fun 
    monster.setAnimation = function (self,track, name, loop )
        animation:setAnimation(track, name, loop)
    end
    monster.addAnimation = function ( self, track, name, loop )
        animation:addAnimation(track, name, loop)
    end


    return monster
end

function BaseStory:CreateIcon( id, skins )

    local animation = HeroNode.new(0,0,id, skins)
    animation:setTouchEnabled(false)
    animation:setScale(1.5)
    animation:setAnimation(0, "idle", false)

    animation:setVisible(false)
    self.box:addChild(animation)

     return animation   
end

function BaseStory:CreateMonsterIcon( name, scale )
    local skel = "image/spine/monster/"..name .. "/skeleton.skel"
    local   json = "image/spine/monster/"..name .. "/skeleton.json"
    local   atlas = "image/spine/monster/" .. name .."/skeleton.atlas"
    local scale = scale or 1.5

    local animation = nil
    if cc.FileUtils:getInstance():isFileExist(skel) then
        animation = sp.SkeletonAnimation:create(skel, atlas, scale)
    elseif cc.FileUtils:getInstance():isFileExist(json) then
        animation = sp.SkeletonAnimation:create(json, atlas, scale)
    else
        json = "image/spine/monster/xj_1000/skeleton.json"
        atlas = "image/spine/monster/xj_1000/skeleton.atlas"
        animation = sp.SkeletonAnimation:create(json, atlas, scale)
    end

    animation:setAnimation(0, "idle", false)
    animation:setVisible(false)
    self.box:addChild(animation)

    return animation 
end

function BaseStory:CreatePicture( path )
    local icon = cc.Sprite:create(path)
    icon:setVisible(false)
    self.box:addChild(icon)
    return icon
end

function BaseStory:CreateEmoji( path )
	local  emoji = cc.Sprite:create(path)
	emoji:setScale(0.1)
	emoji:setVisible(false)
	self:addChild(emoji)
	return emoji
end


function BaseStory:DialogBoxVisible( visible )
	self.box:setVisible(visible)
end

function BaseStory:SetMessage( msg )
	self.message = msg
end

function BaseStory:Dialog(  )
    if self.idx > #self.message then
        return
    end

    self:DialogBoxVisible(true)

    local speak = self.message[self.idx].speak
    local str = self.message[self.idx].msg
    local icon = self.message[self.idx].icon
    local dir = self.message[self.idx].dir

    if self.lasticon ~= nil then
        self.lasticon:setVisible(false)
    end
    icon:setVisible(true)
    self.lasticon = icon
    self.label_name:setString(speak)
    self.label_content:setString(str)
    if dir == 1 then
        icon:setPosition(self.boxsize.width*0.1, 0)
        icon:setRotationSkewY(0) 
        self.sprite_name:setPosition(self.boxsize.width*0.1, self.boxsize.height*0.35)
        self.label_content:setPosition(self.boxsize.width*0.4, self.boxsize.height*0.55)
        self.jiantou:setPosition( self.boxsize.width*0.9, self.boxsize.height*0.3 )
    else
        icon:setPosition(self.boxsize.width*0.9, 0)
        icon:setRotationSkewY(180) 
        self.sprite_name:setPosition(self.boxsize.width*0.9, self.boxsize.height*0.35)
        self.label_content:setPosition(self.boxsize.width*0.2, self.boxsize.height*0.55)
        -- self.jiantou:setPosition( self.boxsize.width*0.1, self.boxsize.height*0.3 )
        self.jiantou:setPosition(self.label_content:getPositionX()+self.label_content:getContentSize().width, self.boxsize.height*0.3 )
    end

    
    self.idx = self.idx + 1   
    self.istouch = true  
end

function BaseStory:Emoji( person, biaoqing )
    biaoqing:setVisible(true)
    biaoqing:setPosition(person:getPositionX(),person:getPositionY()+200)
    local tanchu = cc.Sequence:create({cc.ScaleTo:create(0.1, 2),cc.ScaleTo:create(0.5, 1),cc.FadeOut:create(2),cc.DelayTime:create(1.5)})
    biaoqing:runAction(tanchu)
end

function BaseStory:WaitToDialog( time )
    local delay = cc.DelayTime:create(time)
    local event = cc.CallFunc:create(function ( )
        self:Dialog()
    end)
    self:runAction(cc.Sequence:create({delay,event}))
end

function BaseStory:StoryEnd(  )
    Common.stopAllSounds()
    local layerColor = cc.LayerColor:create(cc.c4b(0,0,0,0))
    self:addChild(layerColor,2)
        local event = cc.CallFunc:create(function (  )
           self:removeFromParent()
           _callback()
        end)

    layerColor:runAction(cc.Sequence:create( cc.FadeIn:create(0.5), cc.RemoveSelf:create(), event)) 
end

function BaseStory:StoryBegin(  )
    local layerColor = cc.LayerColor:create(cc.c4b(0,0,0,255))
    self:addChild(layerColor,2)
        local event = cc.CallFunc:create(function (  )
            self.dispatcher:dispatch(self.event_init_ended)
        end)

    layerColor:runAction(cc.Sequence:create( cc.FadeOut:create(2), cc.RemoveSelf:create(), event))
end


return BaseStory