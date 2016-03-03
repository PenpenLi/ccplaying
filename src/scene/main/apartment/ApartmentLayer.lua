--
-- Author: keyring
-- Date: 2015-10-15 12:15:10
--
local ApartmentLayer = class("ApartmentLayer", BaseLayer)
local HeroManager = require("tool.helper.HeroAction")
local CommonLayer = require("tool.helper.CommonLayer")

function ApartmentLayer:ctor( initdata )
	self.apartmentConfig = clone(BaseConfig.GetHeroApartmentConfig())

	for k,v in pairs(initdata) do
		self.apartmentConfig[v.ID].Positions = v.Positions
	end

	self.homes = {}

	-- dump(self.apartmentConfig)

	self:createBackgroup()
	self:createFixedUI()


    local function onTouchBegan(touch, event)
        return true
    end
    local function onTouchEnded(touch, event)

    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function ApartmentLayer:createBackgroup( )

    local background = cc.Sprite:create("image/ui/img/bg/bg_037.jpg")
    background:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)
    self:addChild(background)
end


function ApartmentLayer:createFixedUI(  )
	local layer = cc.Layer:create()
	self:addChild(layer)

   	local bgsize = cc.size(890,545)
    local bg = ccui.ImageView:create("image/ui/img/bg/bg_139.png")
    bg:setPosition(SCREEN_WIDTH*0.5, 40)
    bg:setAnchorPoint(0.5,0)
    bg:setScale9Enabled(true)
    bg:setContentSize(bgsize)
    layer:addChild(bg)

    local bgimage = ccui.ImageView:create("image/ui/img/bg/bg_209.png")
    bgimage:setScale9Enabled(true)
    bgimage:setContentSize(cc.size(864,510))
    bgimage:setPosition(bgsize.width*0.5, bgsize.height*0.5)
    bg:addChild(bgimage)

    local scrollview = ccui.ScrollView:create()
    scrollview:setTouchEnabled(true)
    scrollview:setPosition(cc.p(0,45))
    scrollview:setContentSize(cc.size(bgsize.width, bgsize.height-100))
    bg:addChild(scrollview)

    local fangding = cc.Sprite:create("image/ui/img/btn/btn_1336.png")
    fangding:setPosition(bgsize.width*0.5, bgsize.height-30)
    bg:addChild(fangding)

    local titlebg = cc.Sprite:create("image/ui/img/bg/bg_174.png")
    titlebg:setPosition(bgsize.width*0.5, bgsize.height)
    bg:addChild(titlebg)

    local title = cc.Sprite:create("image/ui/img/btn/btn_1335.png")
    title:setPosition(bgsize.width*0.5, bgsize.height)
    bg:addChild(title)

    local btn_close = ccui.MixButton:create("image/ui/img/btn/btn_598.png")
    btn_close:setPosition(bgsize.width-15, bgsize.height-10)
    btn_close:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            application:popScene()
        end
    end)
    bg:addChild(btn_close)


    
    local lines = math.ceil(#self.apartmentConfig/4)

    local innersize = cc.size(bgsize.width, lines*285)
    scrollview:setInnerContainerSize(innersize)

    for i=1,lines do
    	local geban = cc.Sprite:create("image/ui/img/btn/btn_1337.png")
    	geban:setPosition(innersize.width*0.5, innersize.height-(i*285)+35)
    	scrollview:addChild(geban)
    end

    for i=0,#self.apartmentConfig-1 do

    	if GameCache.Avatar.Level < self.apartmentConfig[i+1].Level then
    		--lock
    		local house = ccui.MixButton:create("image/ui/img/btn/btn_1334.png")
    		house:setPosition(innersize.width*(0.14+(i%4)*0.24), innersize.height-140-(math.floor(i/4)*285) )
    		house:setTouchEnabled(false)
    		scrollview:addChild(house)

    		local size = house:getContentSize()

	    	local label = Common.systemFont(self.apartmentConfig[i+1].Name, 0,0, 22, cc.c3b(222,208,168))
	    	label:setPosition(size.width*0.5, 205)
	    	house:addChild(label)


	    	local label = Common.systemFont(self.apartmentConfig[i+1].Level.."级开启", 0,0, 20, cc.c3b(255,234,221))
	    	label:setPosition(size.width*0.5, 80)
	    	house:addChild(label)

	    	-- local label = Common.systemFont("0/0", 0,0, 20, cc.c3b(222,208,168))
	    	-- label:setPosition(size.width*0.5, -20)
	    	-- house:addChild(label)
    	else
    		local house = ccui.MixButton:create("image/ui/img/btn/btn_1333.png")
    		house:setPosition(innersize.width*(0.14+(i%4)*0.24), innersize.height-140-(math.floor(i/4)*285) )
    		scrollview:addChild(house)
    		house:addTouchEventListener(function ( sender, eventType )
    			if eventType == ccui.TouchEventType.ended then
    				self:createHouse(i+1)
    			end
    		end)

    		local size = house:getContentSize()

    		local icon = cc.Sprite:create("image/ui/img/btn/btn_947.png")
    		icon:setPosition(size.width*0.5, size.height*0.5)
    		icon:setScale(0.4)
    		house:addChild(icon)
    		icon:runAction(cc.RepeatForever:create(cc.RotateBy:create(2, 360)))

	    	local label = Common.systemFont(self.apartmentConfig[i+1].Name, 0,0, 22, cc.c3b(222,208,168))
	    	label:setPosition(size.width*0.5-2, 205)
	    	house:addChild(label)

	    	local str = 0

    		for k,v in pairs(self.apartmentConfig[i+1].Positions) do
    			if v.HeroID > 0 then
    				str = str + 1
    			end
    		end

			self.apartmentConfig[i+1].UsedPositions = str

			local label_bg = cc.Sprite:create("image/ui/img/btn/btn_1044.png")
			label_bg:setPosition(size.width*0.5, 30)
			house:addChild(label_bg)

	    	local label = Common.systemFont(str.."/5", 0,0, 20, cc.c3b(222,208,168))
	    	label:setPosition(label_bg:getContentSize().width*0.5, label_bg:getContentSize().height*0.5)
	    	label_bg:addChild(label)

	    	self.apartmentConfig[i+1].label_used = label

    	end

    end

end

function ApartmentLayer:createHouse( houseid )

	local housedata = self.apartmentConfig[houseid]
	-- dump(housedata)

	-- if not housedata.filterheros then
		housedata.filterheros = self:filterHouseHeros(houseid)

		-- for i=1,#housedata.Positions do
		-- 	if housedata.Positions[i].Opened and housedata.Positions[i].HeroID > 0 then
		-- 		local id = housedata.Positions[i].HeroID
				-- housedata.filterheros[id] = false
		-- 	end
		-- end
		-- dump(self.apartmentConfig[houseid])
	-- end



	local layer = cc.LayerColor:create(cc.c4b(0,0,0,180))
	self:addChild(layer)

   	local bgsize = cc.size(890,545)
    local bg = ccui.ImageView:create("image/ui/img/bg/bg_139.png")
    bg:setPosition(SCREEN_WIDTH*0.5, 40)
    bg:setAnchorPoint(0.5,0)
    bg:setScale9Enabled(true)
    bg:setContentSize(bgsize)
    layer:addChild(bg)

    local bgimage = ccui.ImageView:create("image/ui/img/bg/bg_209.png")
    bgimage:setScale9Enabled(true)
    bgimage:setContentSize(cc.size(864,510))
    bgimage:setPosition(bgsize.width*0.5, bgsize.height*0.5)
    bg:addChild(bgimage)

    local btn_close = ccui.MixButton:create("image/ui/img/btn/btn_598.png")
    btn_close:setPosition(bgsize.width-15, bgsize.height-10)
    btn_close:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
        	self.homes = {}
        	housedata.filterheros = nil
            layer:removeFromParent()
            layer = nil
        end
    end)
    bg:addChild(btn_close)


	local ss = ccui.ImageView:create("image/ui/img/btn/btn_811.png")
	ss:setAnchorPoint(0.5,0)
    ss:setScale9Enabled(true)
    ss:setContentSize(cc.size(850,75))
    ss:setPosition(bgsize.width*0.5, 15)
	bg:addChild(ss)

	local label = Common.systemFont(housedata.EffectDesc, 0,0, 20, cc.c3b(151,255,74))
	label:setPosition(bgsize.width*0.5, 105)
	bg:addChild(label)

    local jiantou = cc.Sprite:create("image/ui/img/btn/btn_809.png")
    jiantou:setPosition(bgsize.width*0.5,50)
    bg:addChild(jiantou)

	local jiacheng = Common.systemFont("加成:", 0,0, 24)
	jiacheng:setAnchorPoint(0,0.5)
	jiacheng:setPosition(bgsize.width*0.5+35, 50)
	bg:addChild(jiacheng)

	local jiacheng_label = Common.systemFont("", 0,0, 24, cc.c3b(253,214,0))
	jiacheng_label:setAnchorPoint(0,0.5)
	jiacheng_label:setPosition(jiacheng:getPositionX()+jiacheng:getContentSize().width+10, 50)
	bg:addChild(jiacheng_label)

	local pingfen_label = Common.systemFont("", 0,0, 24, cc.c3b(151,255,74))
	-- pingfen_label:setAnchorPoint(1,0.5)
	pingfen_label:setPosition(bgsize.width*0.5-65, 50)
	bg:addChild(pingfen_label)

	local pingfen = Common.systemFont("总评分:", 0,0, 24)
	pingfen:setAnchorPoint(1,0.5)
	pingfen:setPosition(bgsize.width*0.5-135, 50)
	bg:addChild(pingfen)

	local pingfen_data = 0
	local jiacheng_data = 0

	local function updateHome( homeid )

		local i = homeid
		if self.homes[i] then
			self.homes[i]:removeAllChildren()
		else
			local j = i-1
			self.homes[i] = cc.Node:create()
	    	self.homes[i]:setPosition(bgsize.width*(0.12+(j%5)*0.19), 210 )
	    	bg:addChild(self.homes[i])
		end

    	local dipan = ccui.Button:create("image/ui/img/btn/btn_973.png")
    	dipan:setScale(0.5)
    	dipan:setTouchEnabled(false)
    	self.homes[i]:addChild(dipan)

    	local size = dipan:getContentSize()


    	if housedata.Positions[i].Opened then
			local guang = cc.Sprite:create("image/ui/img/btn/btn_979.png")
			-- guang:setScale(0.5)
			guang:setAnchorPoint(0.5,0)
			guang:setPosition(size.width*0.5, 50)
			dipan:addChild(guang,1)
			guang:runAction(cc.RepeatForever:create(cc.Sequence:create(
		                                                 cc.FadeIn:create(1),
		                                                 cc.FadeOut:create(1))))
		    if housedata.Positions[i].HeroID > 0 then

		    	housedata.Positions[i].Score = GameCache.GetHero(housedata.Positions[i].HeroID).Score

		    	local hero = HeroManager.new(0, 0, housedata.Positions[i].HeroID)
		    	self.homes[i]:addChild(hero)	
		    	-- dump(hero.animation:getBoundingBox())
		    	local btn_cancel = ccui.MixButton:create("image/ui/img/btn/btn_157.png")
		    	btn_cancel:setPosition(hero.animation:getBoundingBox().width, hero:getBoundingBox().height)	 
		    	hero:addChild(btn_cancel)
		    	btn_cancel:addTouchEventListener(function ( sender, eventType )
		    		if eventType == ccui.TouchEventType.ended then
		    			-- 网路请求然后移除该星将，修改与之关联的数据
		    			-- 
				        rpc:call("Apartment.HeroExitRoom", {RoomID = houseid, PositionID = homeid}, function(event)
				            if event.status == Exceptions.Nil then
								hero:removeFromParent()
								-- housedata.filterheros[housedata.Positions[i].HeroID] = true
								GameCache.GetHero(housedata.Positions[i].HeroID).isCanJoin = true
								GameCache.GetHero(housedata.Positions[i].HeroID).ApartmentType = 0
								pingfen_data = pingfen_data - GameCache.GetHero(housedata.Positions[i].HeroID).Score
								housedata.Positions[i].HeroID = 0
								housedata.UsedPositions = housedata.UsedPositions - 1
								housedata.label_used:setString(housedata.UsedPositions.."/5")
								updateHome(homeid)
				            end
				            
				        end)
		    		end
		    	end) 



		    else
		    	dipan:setTouchEnabled(true)
		    	housedata.Positions[i].Score = 0
		    	dipan:addTouchEventListener(function ( sender, eventType )
		    		if eventType == ccui.TouchEventType.ended then
		    			-- 筛选符合条件的星将
		    			self:showFilteredHeroList(houseid, homeid, function ( heroid )
		    				application:showFlashNotice("入住成功")
		    				-- 更新数据
		    				housedata.Positions[i].HeroID = heroid
		    				-- housedata.filterheros[heroid] = false
		    				GameCache.GetHero(housedata.Positions[i].HeroID).isCanJoin = false
		    				GameCache.GetHero(housedata.Positions[i].HeroID).ApartmentType = houseid

		    				housedata.UsedPositions = housedata.UsedPositions + 1
							housedata.label_used:setString(housedata.UsedPositions.."/5")
		    				updateHome(homeid)
		    			end)
		    		end
		    	end) 
		    end  

	    	local pingfen_bg = ccui.Scale9Sprite:create("image/ui/img/btn/btn_1181.png")
	    	pingfen_bg:setContentSize(cc.size(135,45))
	    	pingfen_bg:setPosition(0, -50)
	    	self.homes[i]:addChild(pingfen_bg)

	    	local label = Common.systemFont("评分:", 40, 22, 20)
	    	pingfen_bg:addChild(label)

	    	local label_pingfen = Common.systemFont(""..housedata.Positions[i].Score, 70, 22, 20, cc.c3b(151,255,74))
	    	label_pingfen:setAnchorPoint(0,0.5)
	    	pingfen_bg:addChild(label_pingfen)

	    	pingfen_data = pingfen_data + housedata.Positions[i].Score

    	else
    		dipan:setBright(false)

    		if GameCache.Avatar.Level >= housedata.UnlockConditions[i].Level or GameCache.Avatar.VIP >= housedata.UnlockConditions[i].VIPLevel then
		    	
		    	local label = Common.systemFont(housedata.UnlockConditions[i].Cost.."", 0, -50, 22 )
    			self.homes[i]:addChild(label)

    			dipan:setTouchEnabled(true)
		    	dipan:addTouchEventListener(function ( sender, eventType )
		    		if eventType == ccui.TouchEventType.ended then

		    			if not Common.isCostMoney(1001, housedata.UnlockConditions[i].Cost)  then
		    				return
		    			end 

		    			self:createNoteLayer(housedata.UnlockConditions[i].Cost, function (  )
			    			rpc:call("Apartment.BuyRoomPosition", {RoomID = houseid, PositionID = homeid}, function(event)
			    				if event.status == Exceptions.Nil then
			    					-- 购买房间
				    				housedata.Positions[i].Opened = true
				    				housedata.Positions[i].HeroID = 0
				    				updateHome(homeid)
				    			end
			    			end)		    				
		    			end) 


		    		end
		    	end) 

		    	local yuanbao_bg = ccui.Scale9Sprite:create("image/ui/img/btn/btn_1181.png")
		    	yuanbao_bg:setContentSize(cc.size(135,45))
		    	yuanbao_bg:setPosition(0, -50)
		    	self.homes[i]:addChild(yuanbao_bg)

		    	local yuanbao = cc.Sprite:create("image/ui/img/btn/btn_060.png")
		    	yuanbao:setPosition(40, 22)
		    	yuanbao_bg:addChild(yuanbao)

		    	local label_yuanbao = Common.systemFont(""..housedata.UnlockConditions[i].Cost, 70, 22, 20, cc.c3b(253,214,0))
		    	label_yuanbao:setAnchorPoint(0,0.5)
		    	yuanbao_bg:addChild(label_yuanbao)

    		else

    			dipan:setTouchEnabled(true)
		    	dipan:addTouchEventListener(function ( sender, eventType )
		    		if eventType == ccui.TouchEventType.ended then
				        local viplayer = CommonLayer.ToBuyVIP("升级太慢？提升至VIP"..housedata.UnlockConditions[i].VIPLevel.."即可马上开放该位置噢，心动不如行动吧！", function (  )
				        	self.homes = {}
				        	housedata.filterheros = nil
				            layer:removeFromParent()
				            layer = nil
				        end)
				        self:addChild(viplayer)
		    		end
		    	end)

		    	local tiaojian_bg = ccui.Scale9Sprite:create("image/ui/img/btn/btn_1181.png")
		    	tiaojian_bg:setContentSize(cc.size(146,45))
		    	tiaojian_bg:setPosition(0, -50)
		    	tiaojian_bg:setState(1)
		    	self.homes[i]:addChild(tiaojian_bg)

		    	local label_tiaojian = Common.systemFont(housedata.UnlockConditions[i].Level.."级或VIP"..housedata.UnlockConditions[i].VIPLevel.."开放", 73, 20, 16)
		    	-- label_tiaojian:setAnchorPoint(0,0.5)
		    	tiaojian_bg:addChild(label_tiaojian)
    		end
    	end


    	pingfen_label:setString(pingfen_data.."")
    	GameCache.HeroApartmentBuff[houseid] = pingfen_data

    	-- jiacheng_data = string.format("%2f", pingfen_data/100)
    	jiacheng_label:setString(string.format("%.2f%%", pingfen_data/100))

	end


    -- create 5 cell
    for i=1,#housedata.Positions do

    	updateHome(i)

    end



    local descbg = cc.Sprite:create("image/ui/img/bg/bg_311.png")
    descbg:setPosition(bgsize.width*0.5, 460)
    bg:addChild(descbg)

    local descbgsize = descbg:getContentSize()

	local label = Common.systemFont("入住规则", 0,0, 28, cc.c3b(251,156,54))
	label:setPosition(bgsize.width*0.5, 505)
	bg:addChild(label)

	for i=0,#housedata.ConditionDesc-1 do
		local label = Common.systemFont(housedata.ConditionDesc[i+1], 0,0, 20, nil, 2)
		label:setAnchorPoint(0,0.5)
		label:setPosition(30+descbgsize.width*0.5*(i%2), descbgsize.height-35- math.floor(i/2)*30)
		descbg:addChild(label)
	end



    local function onTouchBegan(touch, event)
        return true
    end
    local function onTouchEnded(touch, event)

    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)
end


function ApartmentLayer:filterHouseHeros( houseid )
	local filterHeros = {}
	local filterType = {"atkSkill", "atkSkill", "atkSkill", "gender", "gender", "move", "move", "all"}
	local heros = GameCache.GetAllHero()
	local herotype = self.apartmentConfig[houseid].HeroType

	local key = filterType[herotype]

	if herotype == 1 then
		for k,v in pairs(heros) do
			if BaseConfig.GetHero(v.ID,0)[key] == 1001 then --and 
				-- v.Level >= self.apartmentConfig[houseid].HeroLevel and 
				-- v.StarLevel >= self.apartmentConfig[houseid].HeroStarLevel and 
				-- ( not v.ApartmentType or v.ApartmentType == 0 ) then
				
				-- filterHeros[v.ID] = true
				if v.Level >= self.apartmentConfig[houseid].HeroLevel and 
					v.StarLevel >= self.apartmentConfig[houseid].HeroStarLevel and 
					( not v.ApartmentType or v.ApartmentType == 0 ) then
					v.isCanJoin = true
				else
					v.isCanJoin = false
				end
				table.insert(filterHeros, v)
			end
		end
	elseif herotype == 2 then
		for k,v in pairs(heros) do
			if BaseConfig.GetHero(v.ID,0)[key] == 1002 then --and 
				-- v.Level >= self.apartmentConfig[houseid].HeroLevel and 
				-- v.StarLevel >= self.apartmentConfig[houseid].HeroStarLevel and 
				-- ( not v.ApartmentType or v.ApartmentType == 0 ) then

				-- filterHeros[v.ID] = true
				if v.Level >= self.apartmentConfig[houseid].HeroLevel and 
					v.StarLevel >= self.apartmentConfig[houseid].HeroStarLevel and 
					( not v.ApartmentType or v.ApartmentType == 0 ) then
					v.isCanJoin = true
				else
					v.isCanJoin = false
				end
				table.insert(filterHeros, v)
			end
		end
	elseif herotype == 3 then
		for k,v in pairs(heros) do
			if BaseConfig.GetHero(v.ID,0)[key] == 1003 then --and 
				-- v.Level >= self.apartmentConfig[houseid].HeroLevel and 
				-- v.StarLevel >= self.apartmentConfig[houseid].HeroStarLevel and 
				-- ( not v.ApartmentType or v.ApartmentType == 0 ) then

				-- filterHeros[v.ID] = true
				if v.Level >= self.apartmentConfig[houseid].HeroLevel and 
					v.StarLevel >= self.apartmentConfig[houseid].HeroStarLevel and 
					( not v.ApartmentType or v.ApartmentType == 0 ) then
					v.isCanJoin = true
				else
					v.isCanJoin = false
				end
				table.insert(filterHeros, v)
			end
		end
	elseif herotype == 4 then
		for k,v in pairs(heros) do
			if BaseConfig.GetHero(v.ID,0)[key] == 1 then --and 
				-- v.Level >= self.apartmentConfig[houseid].HeroLevel and 
				-- v.StarLevel >= self.apartmentConfig[houseid].HeroStarLevel and 
				-- ( not v.ApartmentType or v.ApartmentType == 0 ) then
				-- filterHeros[v.ID] = true
				if v.Level >= self.apartmentConfig[houseid].HeroLevel and 
					v.StarLevel >= self.apartmentConfig[houseid].HeroStarLevel and 
					( not v.ApartmentType or v.ApartmentType == 0 ) then
					v.isCanJoin = true
				else
					v.isCanJoin = false
				end
				table.insert(filterHeros, v)
			end
		end
	elseif herotype == 5 then
		for k,v in pairs(heros) do
			if BaseConfig.GetHero(v.ID,0)[key] == 2 then --and 
				-- v.Level >= self.apartmentConfig[houseid].HeroLevel and 
				-- v.StarLevel >= self.apartmentConfig[houseid].HeroStarLevel and 
				-- ( not v.ApartmentType or v.ApartmentType == 0 ) then
				-- filterHeros[v.ID] = true
				if v.Level >= self.apartmentConfig[houseid].HeroLevel and 
					v.StarLevel >= self.apartmentConfig[houseid].HeroStarLevel and 
					( not v.ApartmentType or v.ApartmentType == 0 ) then
					v.isCanJoin = true
				else
					v.isCanJoin = false
				end
				table.insert(filterHeros, v)
			end
		end
	elseif herotype == 6 then
		for k,v in pairs(heros) do
			if BaseConfig.GetHero(v.ID,0)[key] == 1 then --and 
				-- v.Level >= self.apartmentConfig[houseid].HeroLevel and 
				-- v.StarLevel >= self.apartmentConfig[houseid].HeroStarLevel and 
				-- ( not v.ApartmentType or v.ApartmentType == 0 ) then
				-- filterHeros[v.ID] = true
				if v.Level >= self.apartmentConfig[houseid].HeroLevel and 
					v.StarLevel >= self.apartmentConfig[houseid].HeroStarLevel and 
					( not v.ApartmentType or v.ApartmentType == 0 ) then
					v.isCanJoin = true
				else
					v.isCanJoin = false
				end
				table.insert(filterHeros, v)
			end
		end
	elseif herotype == 7 then
		for k,v in pairs(heros) do
			if BaseConfig.GetHero(v.ID,0)[key] > 1  then --and 
				-- v.Level >= self.apartmentConfig[houseid].HeroLevel and 
				-- v.StarLevel >= self.apartmentConfig[houseid].HeroStarLevel and 
				-- ( not v.ApartmentType or v.ApartmentType == 0 ) then
				-- filterHeros[v.ID] = true
				if v.Level >= self.apartmentConfig[houseid].HeroLevel and 
					v.StarLevel >= self.apartmentConfig[houseid].HeroStarLevel and 
					( not v.ApartmentType or v.ApartmentType == 0 ) then
					v.isCanJoin = true
				else
					v.isCanJoin = false
				end
				table.insert(filterHeros, v)
			end
		end
	elseif herotype == 8 then
		for k,v in pairs(heros) do
				if v.Level >= self.apartmentConfig[houseid].HeroLevel and 
					v.StarLevel >= self.apartmentConfig[houseid].HeroStarLevel and 
					( not v.ApartmentType or v.ApartmentType == 0 ) then
					v.isCanJoin = true
				else
					v.isCanJoin = false
				end
				table.insert(filterHeros, v)
		end
	end


	return filterHeros
end

function ApartmentLayer:showFilteredHeroList( houseid, homeid, callback )
	local herolist = self.apartmentConfig[houseid].filterheros

	-- for k,v in pairs(self.apartmentConfig[houseid].filterheros) do
	-- 	-- if v then
	-- 		-- local hero = GameCache.GetHero(k)
	-- 		table.insert(herolist, hero)
	-- 	-- end

	-- end

	-- if #herolist == 0 then
	-- 	application:showFlashNotice("找不到符合条件的星将，快去努力培养吧!")
	-- 	return
	-- end


	table.sort(herolist, function ( a, b )
		if a.isCanJoin == b.isCanJoin then
			return a.TFP > b.TFP
		end
		return a.isCanJoin
	end)


	local layer = cc.Layer:create()
	self:addChild(layer)

    local bgsize = cc.size(415,600)
    local bg = ccui.ImageView:create("image/ui/img/bg/bg_139.png")
    bg:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)
    bg:setScale9Enabled(true)
    bg:setContentSize(bgsize)
    layer:addChild(bg)


    local function tableCellTouched( table, cell )
		if cell.isCanJoin then

	    	-- 直接进行网络请求
	        rpc:call("Apartment.HeroEnterRoom", {RoomID = houseid, PositionID = homeid, HeroID = cell.heroid}, function(event)
	            if event.status == Exceptions.Nil then
	                callback(cell.heroid)
	                layer:removeFromParent()
	                layer = nil
	            end
	            
	        end)	
	    else
	     	application:showFlashNotice("不符合条件")
		end

    end

    local function cellSizeForTable( table, idx )

        return 120, 384
    end

    local function tableCellAtIndex( table, idx )
        -- local cell = table:dequeueCell()
        -- CCLog(idx)
        local cell = cc.TableViewCell:new()

        local info = herolist[idx+1]

        cell.heroid = info.ID
        cell.isCanJoin = info.isCanJoin
        cell.ApartmentType = info.ApartmentType

        local itembg = cc.Sprite:create("image/ui/img/bg/bg_144.png")
        itembg:setAnchorPoint(0.5,0)
        itembg:setPosition(bgsize.width*0.5,2)
        cell:addChild(itembg)

        local size = itembg:getContentSize()

	    local headBorder = GoodsInfoNode.new(BaseConfig.GOODS_HERO, info)
	    headBorder:setTouchEnable(false)
	    headBorder:setPosition(58, size.height*0.5)
	    itembg:addChild(headBorder)
	    headBorder:setWx()
	    headBorder:setLevel("center")

        local starData = Common.getHeroStarLevelColor(info.StarLevel)

        local name = Common.finalFont(BaseConfig.GetHero(info.ID,0).name..starData.Additional, 1, 1, 25, cc.c3b(9, 51, 98))
        name:setPosition(135, 75)
        -- name:setAdditionalKerning(-2)
        name:setAnchorPoint(0, 0.5)
        itembg:addChild(name)
        

        local starLevel = cc.LabelAtlas:_create("1", "image/ui/img/btn/btn_607.png", 29, 32,  string.byte("1"))
        starLevel:setAnchorPoint(1, 0.5)
        starLevel:setPosition(size.width-75, 75)
        itembg:addChild(starLevel)
        starLevel:setString(starData.StarNum)

        local controls_talent = Common.finalFont("类型", 1, 1, 20, cc.c3b(70, 106, 166))
        controls_talent:setPosition(135, 35)
        controls_talent:setAnchorPoint(0, 0.5)
        itembg:addChild(controls_talent)

        local talent = Common.finalFont(BaseConfig.BATTLE_TYPE_NAME[(BaseConfig.GetHero(info.ID,0).atkSkill - 1000)], 1, 1, 20, cc.c3b(243, 118, 54))
        talent:setPosition(185, 35)
        talent:setAnchorPoint(0, 0.5)
        itembg:addChild(talent)

        local controls_tfp = Common.finalFont("战力", 1, 1, 20, cc.c3b(70, 106, 166))
        controls_tfp:setPosition(245,35)
        controls_tfp:setAnchorPoint(0, 0.5)
        itembg:addChild(controls_tfp)

        local tfp = Common.finalFont(info.TFP, 1, 1, 20, cc.c3b(243, 118, 54))
        tfp:setAnchorPoint(0,0.5)
        tfp:setPosition(290,35)
        itembg:addChild(tfp)

        if not cell.isCanJoin then
	        local shadow = cc.Scale9Sprite:create("image/ui/img/btn/btn_926.png")
	        shadow:setContentSize(size)
	        shadow:setPosition(size.width*0.5, size.height*0.5)
	        itembg:addChild(shadow)

	        if cell.ApartmentType and cell.ApartmentType ~= 0 then
	        	local gou = cc.Sprite:create("image/ui/img/btn/btn_502.png")
			    gou:setPosition(58, size.height*0.5)
			    itembg:addChild(gou)
	        end
        end


        return cell
    end

    local function numberOfCellsInTableView(table)
        return #herolist
    end

    local tableView = cc.TableView:create(cc.size(bgsize.width, bgsize.height-60))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(0, 30))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)

    tableView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:reloadData()

    bg:addChild(tableView)



    local function onTouchBegan(touch, event)
        return true
    end
    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = bg:convertToNodeSpace(touch:getLocation())
        local startpos = bg:convertToNodeSpace(touch:getStartLocationInView())
        local s = bg:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if not cc.rectContainsPoint(rect, startpos) and not cc.rectContainsPoint(rect, locationInNode) then
            layer:removeFromParent()
            layer = nil
        end

    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)

end

function ApartmentLayer:createNoteLayer( price, callback )
        local layer = cc.LayerColor:create(cc.c4b(0,0,0,180))
        local scene = cc.Director:getInstance():getRunningScene()
        scene:addChild(layer)
    
        local bgsize = cc.size(540,200)    
        local bg = ccui.ImageView:create("image/ui/img/bg/bg_175.png")
        bg:setPosition(SCREEN_WIDTH*0.5,SCREEN_HEIGHT*0.6)
        bg:setScale9Enabled(true)
        bg:setContentSize(bgsize)
        layer:addChild(bg)
    
        local label1 = Common.finalFont("上仙，是否花费" , 1 , 1, 24)
        label1:setAnchorPoint(0,0.5)
        label1:setPosition(50, bgsize.height*.7)
        bg:addChild(label1)

        local icon = cc.Sprite:create("image/ui/img/btn/btn_060.png")
        icon:setPosition(240,bgsize.height*0.7)
        bg:addChild(icon)
    
        local price_label1 = Common.finalFont(""..price, 1, 1, 30,cc.c3b(120,246,103))
        price_label1:setAnchorPoint(0,0.5)
        price_label1:setPosition(260,bgsize.height*0.7+2)
        bg:addChild(price_label1)

        local label1 = Common.finalFont("开启该位置？" , 1 , 1, 24)
        label1:setAnchorPoint(0,0.5)
        label1:setPosition(price_label1:getPositionX()+price_label1:getContentSize().width+5, bgsize.height*.7)
        bg:addChild(label1)    

        local sprite = cc.Sprite:create("image/ui/img/btn/btn_811.png")
        sprite:setAnchorPoint(0.5,0)
        sprite:setPosition(bgsize.width*0.5, 5)
        bg:addChild(sprite)

    
        local ssize = sprite:getContentSize()
    
        local line = cc.Sprite:create("image/ui/img/btn/btn_810.png")
        line:setPosition(ssize.width*0.5, ssize.height)
        sprite:addChild(line)
    
    
        local btn = ccui.MixButton:create("image/ui/img/btn/btn_818.png" )
        btn:setScale9Size(cc.size(135,60))
        btn:setTitle("取消",26,cc.c3b(238,205,142))
        btn:addTouchEventListener(function ( sender, eventType )
            if eventType == ccui.TouchEventType.ended then
                layer:removeFromParent()
                layer = nil

            end
        end)
        btn:setPosition(bgsize.width*0.25, 45)
        bg:addChild(btn)
    
        btn = ccui.MixButton:create("image/ui/img/btn/btn_818.png")
        btn:setScale9Size(cc.size(135,60))
        btn:setTitle("确定",26,cc.c3b(238,205,142))
        btn:addTouchEventListener(function ( sender, eventType )
            if eventType == ccui.TouchEventType.ended then
                callback()
                layer:removeFromParent()
                layer = nil
            end
        end)
        btn:setPosition(bgsize.width*0.75, 45)
        bg:addChild(btn)
    
    
        local function onTouchBegan(touch, event)
            return true
        end
    
        local listener = cc.EventListenerTouchOneByOne:create()
        listener:setSwallowTouches(true)
        listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
        local eventDispatcher = layer:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)
end

function ApartmentLayer:onEnterTransitionFinish(  )
	ApartmentLayer.super.onEnterTransitionFinish(self)
	Common.OpenSystemLayer( {12} )
end


return ApartmentLayer