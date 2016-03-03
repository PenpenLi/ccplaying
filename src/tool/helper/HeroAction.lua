--
-- Author: keyring
-- Date: 2014-09-28 18:30:06
--
local libpath = require("tool.lib.path")
local writablePath = cc.FileUtils:getInstance():getWritablePath() 

local HeroAction = class("HeroAction", function()
    return cc.Node:create()
end)

local scheduler = cc.Director:getInstance():getScheduler()


local HeroAct = {"move", "atk1", "atk2", "atk3", "atk_ko","victory"}
local SkinType = {["ARM"] = 1, ["HAT"] = 2, ["COAT"] = 4}

local function get_arm_skin_res(heroid, skinid)
    local default = "image/spine/hero/xj_"..heroid.."/arm/skeleton.atlas"
    if not cc.FileUtils:getInstance():isFileExist(default) then
        return nil
    end        

    local file = "image/spine/hero/arm/".. skinid .."/skeleton.atlas"     
    if not cc.FileUtils:getInstance():isFileExist(file) then
        file = "image/spine/hero/xj_".. heroid .."/arm/0/skeleton.atlas"
    end

    return file
end

local function get_hat_skin_res(heroid, skinid)
    local file = "image/spine/hero/xj_"..heroid.."/hat/".. skinid .."/skeleton.atlas"
    if not cc.FileUtils:getInstance():isFileExist(file) then
        file = "image/spine/hero/xj_".. heroid .."/hat/0/skeleton.atlas"
    end

    return file
end

local function get_coat_skin_res(heroid, skinid)
    local file = "image/spine/hero/xj_"..heroid.."/coat/".. skinid .."/skeleton.atlas"
    if not cc.FileUtils:getInstance():isFileExist(file) then
        file = "image/spine/hero/xj_".. heroid .."/coat/0/skeleton.atlas"
    end 

    return file
end

local function get_effect_skin_res(res)
    local file = "image/spine/hero/"..res.."/effect/skeleton.atlas"
    if cc.FileUtils:getInstance():isFileExist(file) then
        return file
    end
    return nil 
end

function ChangeSkins( heroid, hero, skinTypeIdMap)
    local heroRes = "xj_" .. heroid
    local resMap = {
        arm = get_arm_skin_res(heroid, skinTypeIdMap[SkinType.ARM]),
        hat = get_hat_skin_res(heroid, skinTypeIdMap[SkinType.HAT]),
        coat = get_coat_skin_res(heroid, skinTypeIdMap[SkinType.COAT]),
        effect = get_effect_skin_res(heroRes),
    }
    hero:replaceSkinsInAtlas(libpath.join(writablePath, "skins", tostring(heroid)), resMap)
end

function ChangeSkin( heroid, hero, skintype, skinid )

    --   无换装，给初始装

    if skintype == SkinType.ARM then
        local default = "image/spine/hero/xj_"..heroid.."/arm/skeleton.atlas"
        if not cc.FileUtils:getInstance():isFileExist(default) then
            return
        end        
        hero:resetAllAttachmentInAtlas(default)
        local file = "image/spine/hero/arm/".. skinid .."/skeleton.atlas"     
        if not cc.FileUtils:getInstance():isFileExist(file) then
            file = "image/spine/hero/xj_".. heroid .."/arm/0/skeleton.atlas"
        end
        hero:replaceAllAttachmentInAtlas(file)
    elseif skintype == SkinType.HAT then
        hero:resetAllAttachmentInAtlas("image/spine/hero/xj_"..heroid.."/hat/skeleton.atlas")
        local file = "image/spine/hero/xj_"..heroid.."/hat/".. skinid .."/skeleton.atlas"
        if not cc.FileUtils:getInstance():isFileExist(file) then
            file = "image/spine/hero/xj_".. heroid .."/hat/0/skeleton.atlas"
        end
        hero:replaceAllAttachmentInAtlas(file)        
    elseif skintype == SkinType.COAT then
        hero:resetAllAttachmentInAtlas("image/spine/hero/xj_"..heroid.."/coat/skeleton.atlas")
        local file = "image/spine/hero/xj_"..heroid.."/coat/".. skinid .."/skeleton.atlas"
        if not cc.FileUtils:getInstance():isFileExist(file) then
            file = "image/spine/hero/xj_".. heroid .."/coat/0/skeleton.atlas"
        end        
        hero:replaceAllAttachmentInAtlas(file)  
    end
end


function CreateHero( x,y,id,skininfo)


    local res = BaseConfig.GetHero(id, 0).res
    
    local skins = nil
    if skininfo then
        skins = skininfo
    else
        local info = GameCache.GetHero( id ) 
        if info then
            skins = { ["Arm"] = info.Equip[SkinType.ARM].SkinID, 
                    ["Hat"] = info.Equip[SkinType.HAT].SkinID, 
                    ["Coat"] = info.Equip[SkinType.COAT].SkinID
                }
        end
    end

    return CreatePlayer( x,y,res,skins)
end

function CreatePlayer( x,y,res,skins)
    local skel = nil
    local json = nil
    local atlas = nil
    local animation = nil
    local scale = 1
    
    if string.sub(res,1,3) == "xj_" then   -- 星将资源

        local info = skins

        local id = tonumber(string.sub(res, 4))
        -- print(id)

        skel = "image/spine/hero/"..res .. "/skeleton.skel"
        json = "image/spine/hero/"..res .. "/skeleton.json"
        atlas = "image/spine/hero/" .. res .."/skeleton.atlas"
        if cc.FileUtils:getInstance():isFileExist(skel) then
            animation = sp.SkeletonAnimation:create(skel, atlas, scale, false)
        else
            animation = sp.SkeletonAnimation:create(json, atlas, scale, false)
        end
        
        animation:setPosition(x, y)
        
        if info == nil then
            ChangeSkin(id, animation, SkinType.ARM, 0)
            ChangeSkin(id, animation, SkinType.HAT, 0)
            ChangeSkin(id, animation, SkinType.COAT, 0)

            --ChangeSkins(id, animation, {[SkinType.HAT] = 0, [SkinType.COAT] = 0, [SkinType.ARM] = 0})
        else            
            ChangeSkin(id, animation, SkinType.HAT, info.Hat or 0)
            ChangeSkin(id, animation, SkinType.COAT, info.Coat or 0)
            ChangeSkin(id, animation, SkinType.ARM, info.Arm or 0)

            --ChangeSkins(id, animation, {[SkinType.HAT] = info.Hat or 0, [SkinType.COAT] = info.Coat or 0, [SkinType.ARM] = info.Arm or 0})
        end

        

        local file = "image/spine/hero/"..res.."/effect/skeleton.atlas"
        if cc.FileUtils:getInstance():isFileExist(file) then
            animation:replaceAllAttachmentInAtlas(file)
        end    

    else
        skel = "image/spine/monster/"..res .. "/skeleton.skel"
        json = "image/spine/monster/"..res .. "/skeleton.json"
        atlas = "image/spine/monster/" .. res .."/skeleton.atlas"

        if cc.FileUtils:getInstance():isFileExist(skel) then
            animation = sp.SkeletonAnimation:create(skel, atlas, scale)
        elseif cc.FileUtils:getInstance():isFileExist(json) then
            animation = sp.SkeletonAnimation:create(json, atlas, scale)
        else
            json = "image/spine/monster/xj_1000/skeleton.json"
            atlas = "image/spine/monster/xj_1000/skeleton.atlas"
            animation = sp.SkeletonAnimation:create(json, atlas, scale)
        end

        animation:setPosition(x, y)  
    end

    return animation
end


function HeroAction:ctor( x, y, id, skinInfo)
    self.touchable = true
    self.callback = nil
    self.longPressEvent = nil
    self.actioncomplete = true
    self.longpressable = false
    self.clickable = true

    -- dump(BaseConfig.GetSoundHero(id))
    self.sound = BaseConfig.GetSoundHero(id).Speak or {}
    self.soundCount = 0

    self:setPosition(x,y)


    local shadow = cc.Sprite:create("image/ui/img/btn/btn_249.png")
    shadow:setScale(0.24)
    self:addChild(shadow)

    if skinInfo and skinInfo.Equip then
         local skins = { ["Arm"] = skinInfo.Equip[SkinType.ARM].SkinID, 
            ["Hat"] = skinInfo.Equip[SkinType.HAT].SkinID, 
            ["Coat"] = skinInfo.Equip[SkinType.COAT].SkinID
        }
        self.animation = CreateHero(0, 0, id, skins)
    else
        self.animation = CreateHero(0, 0, id, skinInfo)
    end

    local rect = self.animation:getBoundingBox()
    self.animation:setAnimation(0, "idle", true)
    self.animation:registerSpineEventHandler(function ( event )
        self.actioncomplete = true
    end, sp.EventType.ANIMATION_COMPLETE)
    self:addChild(self.animation)

    local moveMode = BaseConfig.GetHero(id, 0).move
    if moveMode == 2 then
        local cloud = sp.SkeletonAnimation:create("image/spine/skill_effect/cloud/skeleton.skel", "image/spine/skill_effect/cloud/skeleton.atlas", 1)
        cloud:setAnimation(0, "animation", true)
        cloud:setPosition(0,-5)
        cloud:setScale(0.8)
        self:addChild(cloud)
    end


   	self.id = id

	local function onTouchBegan(touch, event)
        if  not self.touchable or not self.actioncomplete then
            return false
        end
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getBoundingBox()


        if cc.rectContainsPoint(s, locationInNode) then
            if self.callback then
                self.callback(self, ccui.TouchEventType.began)
            end
            if self.longpressable then
                self.longpressScheduler = scheduler:scheduleScriptFunc(function (  ) 

                    if self.longpressScheduler then

                        self.longPressEvent()
                        scheduler:unscheduleScriptEntry(self.longpressScheduler)
                        self.longpressScheduler = nil                        


                    end
    
                  end, 0.5, false)
            end

            return true
        end
        return false
    end

    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getBoundingBox()

        local startpos = touch:getStartLocationInView()
        local currpos = touch:getLocationInView()
        local x = currpos.x - startpos.x
        local y = currpos.y - startpos.y

        -- if not cc.rectContainsPoint(s, locationInNode) then
        --     if self.longpressScheduler then
        --         scheduler:unscheduleScriptEntry(self.longpressScheduler)
        --         self.longpressScheduler = nil
        --     end
        --     return
        -- end

        if math.abs(x) > 10 or math.abs(y) > 10 then
            if self.longpressScheduler then
                scheduler:unscheduleScriptEntry(self.longpressScheduler)
                self.longpressScheduler = nil
            end
            if self.callback then
                if cc.rectContainsPoint(s, locationInNode) then
                    self.callback(self, ccui.TouchEventType.ended)
                else
                    self.callback(self, ccui.TouchEventType.canceled)
                end
            end
            return
        end

        if self.longpressable then
            if self.longpressScheduler then
                scheduler:unscheduleScriptEntry(self.longpressScheduler)
                self.longpressScheduler = nil
                if not self.callback then
                    self:defaultAction()
                else
                    if cc.rectContainsPoint(s, locationInNode) then
                        self.callback(self, ccui.TouchEventType.ended)
                    else
                        self.callback(self, ccui.TouchEventType.canceled)
                    end
                end
            end 
        elseif self.clickable then
            if not self.callback  then

                self:defaultAction()
            else
                if cc.rectContainsPoint(s, locationInNode) then
                    self.callback(self, ccui.TouchEventType.ended)
                else
                    self.callback(self, ccui.TouchEventType.canceled)
                end
            end                       
        end

	end
	
    local listener = cc.EventListenerTouchOneByOne:create()
    -- listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN ) 
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.animation)

    self.listener = listener
end

function HeroAction:addTouchEvent( fun )
    self.callback = fun
end

function HeroAction:setSwallowTouches( enable )
    self.listener:setSwallowTouches(enable)
end

function HeroAction:setLongPressEnabled( enable )
    self.longpressable = enable
end

function HeroAction:setClickEnabled( enable )
    self.clickable = enable
end

function HeroAction:setTouchEnabled(enable)
    self.touchable = enable
end

function HeroAction:addLongPressEvent( fun )
    self.longPressEvent = fun
end

function HeroAction:action_move()
    self.animation:setAnimation(0,"move",true)
end

function HeroAction:action_idle()
    self.animation:setAnimation(0,"idle",true)
end

function HeroAction:addAnimation(flag, name, rep)
    self.animation:addAnimation(flag, name, rep)
end

function HeroAction:setAnimation(flag, name, rep )
    self.animation:setAnimation(flag,name,rep)
end

function HeroAction:setTimeScale( time )
    self.animation:setTimeScale(time)
end

function HeroAction:defaultAction()
    if self.actioncomplete then
        self.actioncomplete = false
        math.randomseed(os.time())
        math.random()
        local n = math.random(1,#HeroAct)
        local act = HeroAct[n]


        self:playSound()
        
         if act == "move" then
             self.animation:setAnimation(0, act, true)
        else
            self.animation:setAnimation(0, act, false)
            self.animation:addAnimation(0, "idle", true)            
         end

    end
end

function HeroAction:playSound(  )
         self.soundCount = (self.soundCount % #self.sound) + 1
         local path = "audio/hero/"..self.sound[self.soundCount]..".mp3"
         if self.currSound then
             Common.stopSound(self.currSound)
         end
         
         self.currSound = Common.playSound(path)
end

function HeroAction:changeSkin(skintype, skinid)
    ChangeSkin(self.id, self.animation, skintype, skinid)
end

return HeroAction
