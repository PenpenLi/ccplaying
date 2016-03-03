--
-- Author: keyring
-- Date: 2015-11-09 15:49:11
--

local RankList = class("RankList", BaseLayer)
local HeroAction = require("tool.helper.HeroAction")


function RankList:ctor(typeid,func)

    self.callback = func

    self.rankTypeid = typeid or 1
    self.switchBtn = {}
    self.rankForms = {}
    self.wxTexture = {
        "image/ui/img/btn/btn_385.png",
        "image/ui/img/btn/btn_383.png",
        "image/ui/img/btn/btn_386.png",
        "image/ui/img/btn/btn_384.png",
        "image/ui/img/btn/btn_387.png",
    }

    self.atkAttr = {
        "image/ui/img/btn/btn_650.png",
        "image/ui/img/btn/btn_649.png",
        "image/ui/img/btn/btn_648.png",
    }

	self.BTN_LABEL = {"总战力", "最高队伍战力", "星将总星数","竞技场","等级"  }
	self.TOP_LABEL = {"总战力", "最强队伍战力", "星将总星数", "奖励", "最高战力"}
	self.RANKLAYER_ID = {total_tfp = 1, max_tfp = 2, total_star = 3, arena = 4, level = 5}
	self.IS_LAYER_CREATE = {false, false, false, false, false}

    self:createFixedUI()

    self:receiveRankInfo()

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

function RankList:createFixedUI()

    local layer = cc.LayerColor:create(cc.c4b(0,0,0,200))
    self:addChild(layer)

    local bgsize = cc.size(920,555)
    local bg = ccui.ImageView:create("image/ui/img/bg/bg_139.png")
    bg:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5-20)
    bg:setScale9Enabled(true)
    bg:setContentSize(bgsize)
    layer:addChild(bg)

    local huawen = cc.Sprite:create("image/ui/img/btn/btn_609.png")
    huawen:setPosition(bgsize.width*0.6, bgsize.height*0.5)
    bg:addChild(huawen)

    local image_list = ccui.ImageView:create("image/ui/img/btn/btn_1381.png")
    image_list:setAnchorPoint(0.5,1)
    image_list:setPosition(bgsize.width*0.5, bgsize.height-15)
    image_list:setScale9Enabled(true)
    image_list:setContentSize(cc.size(905,63))
    bg:addChild(image_list)

    local image_title = cc.Sprite:create("image/ui/img/bg/bg_233.png")
    image_title:setPosition(bgsize.width*0.5+10, bgsize.height-5)
    bg:addChild(image_title)

    local title = cc.Sprite:create("image/ui/img/btn/btn_940.png")
    title:setPosition(bgsize.width*0.5, bgsize.height-10)
    bg:addChild(title)

    local line = cc.Sprite:create("image/ui/img/bg/bg_304.png")
    line:setPosition(230, 245)
    bg:addChild(line)

    local label_paiming = Common.finalFont("排行榜类型",1,1,20)
    label_paiming:setPosition(125,25)
    image_list:addChild(label_paiming)

    local label_paiming = Common.finalFont("排名",1,1,20)
    label_paiming:setPosition(290,25)
    image_list:addChild(label_paiming)

    local label_juese = Common.finalFont("角色",1,1,20)
    label_juese:setPosition(440,25)
    image_list:addChild(label_juese)

    local label_dengji = Common.finalFont("等级",1,1,20)
    label_dengji:setPosition(590,25)
    image_list:addChild(label_dengji)

    local label_jiangli = Common.finalFont("",1,1,20)
    label_jiangli:setPosition(770,25)
    image_list:addChild(label_jiangli)
    self.toplabel = label_jiangli


    local layerMultiplex = cc.Node:create() --cc.LayerColor:create(cc.c4b(255,0,0,200), 670, 450)
    layerMultiplex:setPosition(240, 0)
    bg:addChild(layerMultiplex)
	self.LayerMultiplex = layerMultiplex
	layerMultiplex.switchTo = function (self, n )
	 	if layerMultiplex.lastIdx then
			local l = layerMultiplex:getChildByTag(layerMultiplex.lastIdx)
			l:setVisible(false)
		end
		layerMultiplex.lastIdx = n
		local l = layerMultiplex:getChildByTag(n)
		l:setVisible(true)
	end
	layerMultiplex.addLayer = function (self, layer, idx )
		layer:setTag(idx)
		layerMultiplex:addChild(layer)
	end

    local btn_close = ccui.MixButton:create("image/ui/img/btn/btn_598.png")
    btn_close:setPosition(bgsize.width-15, bgsize.height-10)
    btn_close:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if self.callback ~= nil then
                self.callback()
            end
            self:removeFromParent()
            self = nil
        end
    end)
    bg:addChild(btn_close)

    local function createSwitchBtnTable()
        local tableViewsize = cc.size(260, #self.BTN_LABEL*100)

	    local function cellSizeForTable(table,idx) 
	        return tableViewsize.height, tableViewsize.width
	    end
	    local function tableCellAtIndex(tableView, idx)

	        local cell = cc.TableViewCell:new()

	        for i=1,#self.BTN_LABEL do
	            local btn = createMixSprite("image/ui/img/btn/btn_1283.png", "image/ui/img/btn/btn_1284.png")
	            btn:setPosition(tableViewsize.width * 0.5, tableViewsize.height-50-(i-1)*100)
	            btn:setButtonBounce(false)
	            btn:setTouchEnable(false)
	            btn:setTag(i)
	            btn:setFont(self.BTN_LABEL[i], 1, 1, 25, cc.c3b(177, 174, 170), 1)
	            btn:setFontOutline(cc.c4b(52, 58, 82, 255), 2)
	            btn:setFontPos(0.5, 0.5)
	            table.insert(self.switchBtn, btn)
	            btn:addTouchEventListener(function ( sender, eventType )
	                if (eventType == ccui.TouchEventType.ended) and (not tableView:isTouchMoved()) then
	                    local idx = btn:getTag()
	                    if self.lastIdx == idx then
	                        return
	                    end
	                    self.switchBtn[self.lastIdx]:setNormalStatus()
	                    self.switchBtn[self.lastIdx]:setFontColor(cc.c3b(177, 174, 170))
	                    self.switchBtn[self.lastIdx]:setFontOutline(cc.c4b(52, 58, 82, 255), 2)

	                    btn:setTouchStatus()
	                    btn:setFontColor(cc.c3b(253, 230, 154))
	                    btn:setFontOutline(cc.c4b(46, 46, 46, 255), 2)
	                    self.lastIdx = idx
	                    self.toplabel:setString(self.TOP_LABEL[idx])
	                    self:createOrShowRank(idx)
	                end
	            end)

	            cell:addChild(btn)

	            if i == self.rankTypeid then
	                btn:setTouchStatus()
	                btn:setFontColor(cc.c3b(253, 230, 154))
	                btn:setFontOutline(cc.c4b(46, 46, 46, 255), 2)
	                self.toplabel:setString(self.TOP_LABEL[i])
	                self.lastIdx = i
	            end
	        end

	        return cell
	    end

	    local function numberOfCellsInTableView(table)
	       return 1
	    end

	    local tableView = cc.TableView:create(cc.size(260, 430))
	    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	    tableView:setDelegate()
	    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	    tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
	    tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
	    tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	    tableView:reloadData()




        return tableView
    end

    local btnview = createSwitchBtnTable()
    btnview:setPosition(-10,40)
    bg:addChild(btnview)


end

function RankList:createRankLayer( rankindex )

	local ranklist = self.rankInfo.Ranks[rankindex]

    local function tableCellTouched( table, cell )

        local idx = cell:getIdx()
        local rid = cell.id


        if table.lastidx ~= idx then

            local cellbg = cell:getChildByName("bg")
            cellbg:setTexture("image/ui/img/btn/btn_982.png")

            local level = cellbg:getChildByName("level")
            level:setColor(cc.c3b(91,61,10))

            local sbg = cellbg:getChildByName("sbg")
            sbg:setTexture("image/ui/img/btn/btn_1075.png")

            local name = cellbg:getChildByName("name")
            name:setColor(cc.c3b(91,61,10))


            if table.lastidx and  table.lastidx ~= idx then
                table:updateCellAtIndex(table.lastidx)
            end
            table.lastidx = idx
        end

        if rankindex ~= self.RANKLAYER_ID["arena"] then
        	return
        end

        if not self.rankForms[rid] then
            --请求网络
            self.rankForms[rid] = {}
            rpc:call("Ranks.GetChallengerInfo",rid,function ( event )
                if event.status == Exceptions.Nil then
                    self.rankForms[rid] = event.result
                    self:showEnemyForm(self.rankForms[rid])
                end
            end)
        else
            --  直接展示
            self:showEnemyForm(self.rankForms[rid])
        end

    end


    local function cellSizeForTable( table, idx )

        return 85, 100
    end

    local function tableCellAtIndex( table, idx )
            local cell = table:dequeueCell()
            if not cell then
                cell = cc.TableViewCell:new()
            else
                cell:removeAllChildren()
            end

            local itembg = cc.Sprite:create("image/ui/img/btn/btn_981.png")
            itembg:setName("bg")
            itembg:setFlippedX(true)
            itembg:setAnchorPoint(0,0)
            cell:addChild(itembg)

            local size = itembg:getContentSize()

            if idx == 0 then
                local icon = cc.Sprite:create("image/ui/img/btn/btn_932.png")
                icon:setPosition(50, size.height*0.5)
                itembg:addChild(icon)
            elseif idx == 1 then
                local icon = cc.Sprite:create("image/ui/img/btn/btn_933.png")
                icon:setPosition(50, size.height*0.5)
                itembg:addChild(icon)
            elseif idx == 2 then
                local icon = cc.Sprite:create("image/ui/img/btn/btn_931.png")
                icon:setPosition(50, size.height*0.5)
                itembg:addChild(icon)
            end

            local id = ranklist[idx+1]
            local info = {}
            info = self.rankInfo.Roles[id]

            local num = cc.Label:createWithCharMap("image/ui/img/btn/btn_627.png",44,52,string.byte("0"))
            num:setString(""..idx+1)
            num:setPosition(50,size.height*0.5)
            num:setScale(0.8)
            itembg:addChild(num)

            cell.id = info.RID

            local touxiang = {ID = info.Icon}
            local icon = GoodsInfoNode.new(BaseConfig.GOODS_HERO, touxiang, BaseConfig.GOODS_SMALLTYPE)
            icon:setTouchEnable(false)
            icon:setPosition(155, size.height*0.5)
            itembg:addChild(icon)

            local str = info.Name
            local label_name = Common.systemFont(str,1,1, 22,cc.c3b(10,51,91))
            label_name:setName("name")
            label_name:setAnchorPoint(0,0.5)
            label_name:setPosition(195, size.height*0.5)
            itembg:addChild(label_name)
 
            if string.sub(info.RID, 1,1) == "R" then
            	label_name:setColor(cc.c3b(171,174,172))
            end

            str = ""..info.Level
            local label_level = Common.finalFont(str,1,1, 26,cc.c3b(10,51,91))
            label_level:setName("level")
            label_level:setPosition(365, size.height*0.5)
            itembg:addChild(label_level)

            local award = cc.Sprite:create("image/ui/img/btn/btn_1074.png")
            award:setName("sbg")
            award:setPosition(550, size.height*0.5)
            itembg:addChild(award)

            local awardsize = award:getContentSize()

	        if rankindex ~= self.RANKLAYER_ID["arena"] then
	            
	            if rankindex == self.RANKLAYER_ID["total_tfp"] then
	            	str = ""..info.TotalTFP
	            elseif rankindex == self.RANKLAYER_ID["total_star"] then
	            	str = ""..info.Stars
	            else
	            	str = ""..info.MaxTFP
	            end


	            if rankindex == self.RANKLAYER_ID["level"] then
	            	label_level:setColor(cc.c3b(151,255,74))
	            	label_level:enableOutline(cc.c4b(0,0,0,255), 1)

		            local label_award1 = Common.finalFont(str,1,1, 20,cc.c3b(10,51,91))
		            label_award1:setPosition(awardsize.width*0.5, awardsize.height*0.5)
		            award:addChild(label_award1)
	            else
		            local label_award1 = Common.finalFont(str,1,1, 20,cc.c3b(151,255,74),1)
		            label_award1:setPosition(awardsize.width*0.5, awardsize.height*0.5)
		            award:addChild(label_award1)
	            end
	        else
	            -- award
	            local award1 = cc.Sprite:create("image/ui/img/btn/btn_1121.png")
	            award1:setPosition(25,awardsize.height*0.5)
	            award:addChild(award1)

	            str = ""..info.ArenaCredits
	            local label_award1 = Common.finalFont(str,1,1, 20,cc.c3b(151,255,74),1)
	            label_award1:setPosition(73,awardsize.height*0.5)
	            award:addChild(label_award1)

	            local award2 = cc.Sprite:create("image/ui/img/btn/btn_060.png")
	            award2:setPosition(140,awardsize.height*0.5)
	            award:addChild(award2)

	            str = ""..info.ArenaGold
	            local label_award2 = Common.finalFont(str,1,1, 20,cc.c3b(151,255,74),1)
	            label_award2:setPosition(180,awardsize.height*0.5)
	            award:addChild(label_award2)

			end
        return cell
    end

    local function numberOfCellsInTableView(table)

        return #ranklist
    end

    local tableHeight = 430
    local tableY = 30
    -- if self.ArenaInfo.SelfRank == 0 then 
    --     tableHeight = 360+72
    --     tableY = 32
    -- end
    local tableView = cc.TableView:create(cc.size(720, tableHeight))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(0, tableY))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)

    table.lastidx = nil

    tableView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:reloadData()

    return tableView
end

function RankList:createOrShowRank( idx )
	if self.IS_LAYER_CREATE[idx] then
		self.LayerMultiplex:switchTo(idx)
		return
	end

	local ranklayer = cc.Layer:create()
	ranklayer:addChild(self:createRankLayer(idx))
	self.LayerMultiplex:addLayer(ranklayer, idx)
	self.LayerMultiplex:switchTo(idx)
	self.IS_LAYER_CREATE[idx] = true

end

function RankList:showEnemyForm( player )

    local panel = cc.LayerColor:create(cc.c4b(0,0,0,200))
    self:addChild(panel)


    local bgsize = cc.size(604,567)
    local bg = ccui.ImageView:create("image/ui/img/bg/bg_139.png")
    bg:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5-10)
    bg:setScale9Enabled(true)
    bg:setContentSize(bgsize)
    panel:addChild(bg)


    local center = cc.Sprite:create("image/ui/img/bg/bg_291.png")
    center:setPosition(bgsize.width*0.5, bgsize.height*0.5)
    bg:addChild(center)

    local fairyBg = cc.Sprite:create("image/ui/img/btn/btn_643.png")
    fairyBg:setPosition(bgsize.width-35, bgsize.height-25)
    bg:addChild(fairyBg)

    if player.Form.Fairy ~= 0 then
        local path = "image/ui/fairy/xn_"..string.sub(player.Form.Fairy,2).."_head.png"
        local fairy = cc.Sprite:create(path)
        fairy:setPosition(bgsize.width-35, bgsize.height-15)
        bg:addChild(fairy)
    end

    local x = cc.Sprite:create("image/ui/img/btn/btn_647.png")
    x:setPosition(bgsize.width-35, bgsize.height-65)
    bg:addChild(x)

    local form = {}
    local herolist = {}
    form = player.Form.Hero


    if form == nil then
        return
    end
    herolist = player.HeroList


    for i = #form, 1, -1 do
        local x = form[i].X*(-0.25)*bgsize.width+bgsize.width      -- 翻转阵容    (1-(-0.25*form[i].X))*bgsize.width
        local y = 50+form[i].Y*0.14*bgsize.height

        local wx = BaseConfig.GetHero(form[i].ID,0).wx
        local texture = self.wxTexture[wx]

        local shadow = cc.Sprite:create(texture)
        shadow:setPosition(x, y)
        -- shadow:setScale(0.3)
        bg:addChild(shadow)

        local hero = HeroAction.new(x, y, form[i].ID, herolist[i])
        hero:setTouchEnabled(false)
        hero:setAnimation(0,"idle",true)
        hero:setRotationSkewY(180)
        hero:setScale(0.8)
        bg:addChild(hero)

        local attr = BaseConfig.GetHero(form[i].ID,0).atkSkill - 1000
        -- local str = self.atkAttr[attr]
        -- local label = Common.finalFont(str,1,1,20)
        -- label:setPosition(x,y)
        -- label:enableOutline(cc.c4b(0,0,0,255),2)
        -- -- label:setColor(cc.c3b(143,26,20))
        -- bg:addChild(label)

        local tex = self.atkAttr[attr]
        local icon = cc.Sprite:create(tex)
        icon:setPosition(x,y)
        bg:addChild(icon)

    end

    local zhanlibg = cc.Sprite:create("image/ui/img/bg/bg_276.png")
    zhanlibg:setPosition(bgsize.width*0.5-20, bgsize.height*0.9)
    bg:addChild(zhanlibg)

    local zhanlisize = zhanlibg:getContentSize()

    label = Common.systemFont(""..player.Name.." 的队伍",1,1,22)
    label:setAnchorPoint(0,0.5)
    label:setPosition(15, zhanlisize.height*0.5)
    -- label:setColor(cc.c3b(143,26,20))
    zhanlibg:addChild(label)

    label = Common.finalFont("战力",1,1,20)
    label:setAnchorPoint(0,0.5)
    label:setPosition(275, zhanlisize.height*0.5)
    -- label:setColor(cc.c3b(143,26,20))
    zhanlibg:addChild(label)

    label = Common.finalFont(""..player.TFP,330, zhanlisize.height*0.5,32)
    label:setAnchorPoint(0,0.5)
    label:setColor(cc.c3b(151,255,74))
    zhanlibg:addChild(label)

    local function onTouchBegan(touch, event)
        return true
    end
    local function onTouchEnded(touch, event)

        local locationInNode = bg:convertToNodeSpace(touch:getLocation())
        local s = bg:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if not cc.rectContainsPoint(rect, locationInNode) then
            panel:removeFromParent()
            panel = nil
        end

    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, panel)
end

function RankList:receiveRankInfo( )
	-- 网络请求
    rpc:call("Ranks.Billboard", nil, function ( event )
        if event.status == Exceptions.Nil then
            self.rankInfo = event.result
            self:createOrShowRank(self.rankTypeid)

            for k,v in pairs(self.switchBtn) do
            	v:setTouchEnable(true)
            end
        end
    end)
end


return RankList

