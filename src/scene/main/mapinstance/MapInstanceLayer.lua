--
-- Author: keyring
-- Date: 2014-09-19 11:13:11
--
local MapInstanceLayer = class("MapInstanceLayer", BaseLayer)
local scheduler = cc.Director:getInstance():getScheduler()
local commonLayer = require("tool.helper.CommonLayer")
local EffectManager = require("tool.helper.Effects")


function MapInstanceLayer:ctor( nodeid,diff)
    MapInstanceLayer.super.ctor(self)


    self.ratingTexture1 = { -- C,B,A,S,SS
        "image/ui/img/btn/btn_631.png",
        "image/ui/img/btn/btn_630.png",    
        "image/ui/img/btn/btn_629.png",    
        "image/ui/img/btn/btn_628.png",    
        "image/ui/img/btn/btn_802.png",
    }
    
    self.ratingTexture2 = {
        "image/ui/img/btn/btn_1054.png",
        "image/ui/img/btn/btn_1053.png", 
        "image/ui/img/btn/btn_1052.png",    
        "image/ui/img/btn/btn_1051.png",    
        "image/ui/img/btn/btn_1050.png",
    }

    self.boxTexture = {
        ["easy_sliver_box"]         = "image/ui/img/btn/btn_1034.png",
        ["easy_gold_box"]           = "image/ui/img/btn/btn_1033.png",
        ["easy_sliver_opened_box"]  = "image/ui/img/btn/btn_1125.png",
        ["easy_gold_opened_box"]    = "image/ui/img/btn/btn_1126.png",

        ["hard_sliver_box"]         = "image/ui/img/btn/btn_1127.png",
        ["hard_gold_box"]           = "image/ui/img/btn/btn_1129.png",
        ["hard_sliver_opened_box"]  = "image/ui/img/btn/btn_1128.png",
        ["hard_gold_opened_box"]    = "image/ui/img/btn/btn_1130.png",
    }

    self.backTexture = {
        ["easy_back"] = "image/ui/img/bg/bg_270.png",
        ["hard_back"] = "image/ui/img/bg/bg_281.png",
        ["easy_geban"] = "image/ui/img/bg/bg_268.png",
        ["hard_geban"] = "image/ui/img/bg/bg_282.png",
        ["easy_top"]  = "image/ui/img/bg/bg_196.png",
        ["hard_top"] =  "image/ui/img/bg/bg_295.png",
        ["easy_title"] = "image/ui/img/btn/btn_976.png",
        ["hard_title"] = "image/ui/img/btn/btn_1239.png",
        ["easy_start"] = "image/ui/img/btn/btn_1035.png",
        ["hard_start"] = "image/ui/img/btn/btn_1240.png",
    }


    --receive needed data

    self.last = {
        chapterid = nil,
        nodeid = nil,
        diff =  nil,
    }
    self.curr = {
        chapterid = nil,
        nodeid = nil,
        diff = nil,
    }


    self.curr.diff = diff or 1
    local currNodeID = Common.getInstanceCurrNode(self.curr.diff)
    self.curr.nodeid = nodeid or currNodeID
    self.curr.nodeid = (self.curr.nodeid > currNodeID) and currNodeID or self.curr.nodeid
    
    self.curr.chapterid = BaseConfig.GetInstanceNode(self.curr.nodeid, self.curr.diff).ChapterID

    -- CCLog(self.curr.chapterid,self.curr.nodeid, self.curr.diff)

    local easyChapterProgress = BaseConfig.GetInstanceNode(GameCache.InstProgress[1], 1).ChapterID

    local hardChapterProgress = 1
    if GameCache.InstProgress[2] ~= 0 then
         hardChapterProgress = BaseConfig.GetInstanceNode(GameCache.InstProgress[2], 2).ChapterID
     end 

    self.progress = {
        easyChapterProgress,
        hardChapterProgress,
    }

    if self.curr.diff == 1 then
        self.choiceNode = {
            self.curr.nodeid,
            GameCache.InstProgress[2],
        }
        if self.choiceNode[2] == 0 then
            self.choiceNode[2] = 10101
        end
    elseif self.curr.diff == 2 then
        self.choiceNode = {
            GameCache.InstProgress[1],
            self.curr.nodeid,
        }
    end


    self:createBackgroup()
    self:createSwitchLayer()
    self:createFlexUI()
    self:createFixedUI()

    --
    self.ChapterPanelCreated = false
    
end

function MapInstanceLayer:onExit()
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:removeEventListener(self._listener)
end


function MapInstanceLayer:onEnterTransitionFinish()
    MapInstanceLayer.super.onEnterTransitionFinish(self)
    self:updateChapterPanel()
    Common.OpenGuideLayer({1,2,3,8})
end

function MapInstanceLayer:createBackgroup(  )

    local background = cc.Sprite:create()
    background:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)
    background:setScale(2)
    self:addChild(background)

    self.background = background
end

function MapInstanceLayer:createFixedUI()
	local fixedLayer = cc.Layer:create()
    self:addChild(fixedLayer)

    local pay = require("scene.main.PayListNode").new(GameCache.Avatar.PhyPower, GameCache.Avatar.MaxPhyPower,
        GameCache.Avatar.Endurance, GameCache.Avatar.MaxEndurance,
        GameCache.Avatar.Coin, GameCache.Avatar.Gold)
    local size = pay:getContentSize()
    pay:setPosition(SCREEN_WIDTH*0.5 - size.width * 0.5, SCREEN_HEIGHT - 60)
    fixedLayer:addChild(pay)

    local btn_close = createMixSprite("image/ui/img/btn/btn_598.png")
    btn_close:setPosition(SCREEN_WIDTH*0.95, SCREEN_HEIGHT*0.93)
    btn_close:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            Common.CloseGuideLayer({3})
			application:popScene()
        end
    end)
    fixedLayer:addChild(btn_close)

end

function MapInstanceLayer:createSwitchLayer(  )
    local layer = cc.LayerColor:create(cc.c4b(0,0,0,0), SCREEN_WIDTH, SCREEN_HEIGHT-100)
    layer:setPosition(0, 100)
    self:addChild(layer)


    local function onTouchBegan(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0,0,s.width, s.height)

        if cc.rectContainsPoint(rect, locationInNode) then
            return true
        end
        
    end

    local function onTouchEnded(touch, event)
        local startpos = touch:getStartLocationInView()
        local currpos = touch:getLocationInView()
        local x = currpos.x - startpos.x

        if x < -150 then
            --todo 向左 章节 ＋1
            if self.curr.chapterid + 1 > self.progress[self.curr.diff] then
                return
            end
           self.curr.chapterid = self.curr.chapterid + 1
           self:updateChapterPanel()
        elseif x > 150 then
            --todo 向右 章节－1
            if self.curr.chapterid - 1 <= 0 then
                return
            end
           self.curr.chapterid = self.curr.chapterid - 1
           self:updateChapterPanel()
        end
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)

end

function MapInstanceLayer:showAward( goods )

    local panel = cc.Layer:create()
    self:addChild(panel)

    local bgColor = cc.LayerColor:create(cc.c4b(0,0,0,180))
    panel:addChild(bgColor)

    local bgsize = cc.size(570,370)

    local bg = ccui.ImageView:create("image/ui/img/bg/bg_139.png")
    bg:setPosition(SCREEN_WIDTH*0.5,SCREEN_HEIGHT*0.5)
    bg:setScale9Enabled(true)
    bg:setContentSize(bgsize)
    panel:addChild(bg)

    local swallowLayer = cc.LayerColor:create(cc.c4b(255,255,255,0),bgsize.width, bgsize.height)
    swallowLayer:setPosition(SCREEN_WIDTH*0.5-285,SCREEN_HEIGHT*0.5-185)
    panel:addChild(swallowLayer)

    local listView = ccui.ListView:create()
    bg:addChild(listView)

    listView:setDirection(ccui.ScrollViewDir.vertical)
    listView:setBounceEnabled(false)
    listView:setContentSize(cc.size(570,350))
    listView:setPosition(0,10)

    local function createItem(listdata )
        local itemsize = cc.size(570,210)
        local default_item = ccui.Layout:create()
        default_item:setTouchEnabled(false)
        default_item:setContentSize(itemsize)

        local tip = ccui.ImageView:create("image/ui/img/btn/btn_362.png")
        tip:setPosition(itemsize.width*0.5, itemsize.height*0.8)
        tip:setScale9Enabled(true)
        tip:setContentSize(560,40)
        default_item:addChild(tip)
    
        local label = Common.finalFont("通关奖励", itemsize.width*0.5, itemsize.height*0.8,24,cc.c3b(255,231,148), 2)
        default_item:addChild(label)

        local dropsbg = cc.LayerColor:create(cc.c4b(21,27,33,180),560,100)
        dropsbg:setPosition(5, 0)
        default_item:addChild(dropsbg)

        local size = dropsbg:getContentSize()

        local function liebiaoFun ()
            local size1 = cc.size(570,140)
            local wancheng = ccui.Layout:create()
            wancheng:setTouchEnabled(false)
            wancheng:setContentSize(size1)
            local icon = Common.finalFont("恭喜通关",size1.width*0.5, size1.height*0.5,50,cc.c3b(255,231,148),2)
            icon:setScale(0.1)
            icon:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 1.2),cc.ScaleTo:create(0.1, 1.0)))
            wancheng:addChild(icon)
            listView:pushBackCustomItem(wancheng)
            listView:refreshView()
            listView:scrollToBottom(0.1,true) 
            local btn_close = createMixSprite("image/ui/img/btn/btn_598.png")
            btn_close:setPosition(bgsize.width-10, bgsize.height-10)
            btn_close:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    panel:removeFromParent()
                    panel = nil
                end
            end)
            swallowLayer:addChild(btn_close)
        end
        
        for i=1,#listdata do
            local delay = cc.DelayTime:create(0.1*i)
            local event = cc.CallFunc:create(function ( )
                local drop = Common.getGoods(listdata[i],true,2)
                drop:setPosition(74+(i-1)*100, size.height*0.5)   
                drop:setScale(0.1)
                if i ~= #listdata then
                    drop:runAction(cc.Sequence:create(cc.ScaleTo:create(0.05, 1.2),cc.ScaleTo:create(0.05, 1.0)))
                else
                    drop:runAction(cc.Sequence:create(cc.ScaleTo:create(0.05, 1.2),cc.ScaleTo:create(0.05, 1.0),cc.DelayTime:create(0.2),cc.CallFunc:create(liebiaoFun)))
                end
                dropsbg:addChild(drop)
            end)
            default_item:runAction(cc.Sequence:create(delay,event))
        end

        return default_item
    end


    listView:pushBackCustomItem(createItem(goods))
    listView:refreshView()
    listView:scrollToBottom(0.1,true) 
    
    local function onTouchBegan(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if cc.rectContainsPoint(rect, locationInNode) then
            return false
        end
        return true
    end

    local function onTouchEnded(touch, event)

    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, swallowLayer)

end

function MapInstanceLayer:updateShowUI(  )
    if self.curr.diff == 1 then
        self.btn_start:loadTextureNormal(self.backTexture.easy_start)
        self.panel_top:setTexture(self.backTexture.easy_top)
        self.title:setTexture(self.backTexture.easy_title)
        self.panel_left:setTexture(self.backTexture.easy_back)
        self.panel_right:setTexture(self.backTexture.easy_back)
        self.geban1:setTexture(self.backTexture.easy_geban)
        self.geban2:setTexture(self.backTexture.easy_geban)
        self.geban3:setTexture(self.backTexture.easy_geban)
        self.geban4:setTexture(self.backTexture.easy_geban)
        self.geban5:setTexture(self.backTexture.easy_geban)
        self.geban6:setTexture(self.backTexture.easy_geban)
        self.geban7:setTexture(self.backTexture.easy_geban)

    elseif self.curr.diff == 2 then
        self.btn_start:loadTextureNormal(self.backTexture.hard_start)
        self.panel_top:setTexture(self.backTexture.hard_top)
        self.title:setTexture(self.backTexture.hard_title)
        self.panel_left:setTexture(self.backTexture.hard_back)
        self.panel_right:setTexture(self.backTexture.hard_back)
        self.geban1:setTexture(self.backTexture.hard_geban)
        self.geban2:setTexture(self.backTexture.hard_geban)
        self.geban3:setTexture(self.backTexture.hard_geban)
        self.geban4:setTexture(self.backTexture.hard_geban)
        self.geban5:setTexture(self.backTexture.hard_geban)
        self.geban6:setTexture(self.backTexture.hard_geban)
        self.geban7:setTexture(self.backTexture.hard_geban)

    end
end


function MapInstanceLayer:updateNodePanel()

    if not self.curr.nodeid then
        return
    end    

    if BaseConfig.GetInstanceNode(self.curr.nodeid, self.curr.diff).ChallengeCount >= 0 then
        self.shengyuCount:setVisible(true)
        self.shengyuCount:setString("今日剩余次数:"..(BaseConfig.GetInstanceNode(self.curr.nodeid, self.curr.diff).ChallengeCount-GameCache.InstNode[self.curr.nodeid..","..self.curr.diff].Count) .. "/".. BaseConfig.GetInstanceNode(self.curr.nodeid, self.curr.diff).ChallengeCount )
        local c = BaseConfig.GetInstanceNode(self.curr.nodeid, self.curr.diff).ChallengeCount - GameCache.InstNode[self.curr.nodeid..","..self.curr.diff].Count
        if c > 10 then
            c = 10
        end
        self.btn_saodang10:setTitleText("扫"..c.."次")
    else
        self.shengyuCount:setVisible(false)
        self.btn_saodang10:setTitleText("扫10次")
    end

    self.panel_nodeDrops:removeAllChildren()

    local node = BaseConfig.GetInstanceNode(self.curr.nodeid, self.curr.diff)
    local drops = node.DropPreview
    local nodename = node.Name


    if self.curr.nodeid == GameCache.InstProgress[self.curr.diff] and (GameCache.InstNode[self.curr.nodeid..","..self.curr.diff].Rating == 0 or GameCache.InstNode[self.curr.nodeid..","..self.curr.diff].Rating == nil) then
        self.wupin1:setVisible(false)
        self.wupin2:setVisible(true)
        drops = node.FirstPassAwardsPreview

    else
        self.wupin1:setVisible(true)
        self.wupin2:setVisible(false)
    end

    local panelsize = self.panel_nodeDrops:getContentSize()
    for i=0,#drops-1 do
        local ico = Common.getGoods(drops[i+1],false,BaseConfig.GOODS_SMALLTYPE)

        local x = (i%2)*70 + 40
        local y = math.floor(i/2)*80 + 40

        ico:setPosition(x, panelsize.height-y)
        self.panel_nodeDrops:addChild(ico)
    end

    if self.last.nodeid == self.curr.nodeid and self.last.diff == self.curr.diff then
        return
    end    

    if self.curr.diff == 1 then
        local easylist = BaseConfig.GetInstanceChapter(self.curr.chapterid).NodeList
        for i=1,#easylist do
            if self.curr.nodeid == easylist[i] then
                self.label_title:setString(string.format("第%d集-%s", i, nodename))
            end
        end
    elseif self.curr.diff == 2 then
        local hardlist = BaseConfig.GetInstanceChapter(self.curr.chapterid).HardNodeList
        for i=1,#hardlist do
            if self.curr.nodeid == hardlist[i] then
                self.label_title:setString(string.format("第%d集-%s", i, nodename))
            end
        end
    end
    

    local mapname = node.MapID
    local _ = string.find(mapname, "_")
    if _ then
        mapname = string.sub(mapname, 1, _-1)
    end
    
    -- print(mapname)
    local path = "image/instance/"..mapname .. ".jpg"
    self.background:setTexture(path)

    local parentsize = self.sprite_costbg:getParent():getContentSize()
    local action = cc.Sequence:create( cc.MoveBy:create(0.15, cc.p(0,-50)), cc.MoveBy:create(0.05, cc.p(0,10)),  cc.MoveBy:create(0.05, cc.p(0,-5)) )
    self.sprite_costbg:setPosition(parentsize.width*0.5, 15)
    self.sprite_costbg:stopAllActions()
    self.sprite_costbg:runAction( action )
    -- self.label_exp:setString("+60")

    self.last.nodeid = self.curr.nodeid
    self.last.diff = self.curr.diff

end


function MapInstanceLayer:updateChapterPanel()

    -- 创建与更新， 初始创建两个tableview， 然后根据当前难度当前章节进行reload数据
    if self.ChapterPanelCreated then
        if self.last.chapterid ~= self.curr.chapterid and self.last.diff == self.curr.diff then
            -- 换章
            local nodelist = {} 

            if self.curr.diff ==1 then
                nodelist = BaseConfig.GetInstanceChapter(self.curr.chapterid).NodeList
            elseif self.curr.diff == 2 then
                nodelist = BaseConfig.GetInstanceChapter(self.curr.chapterid).HardNodeList
            end

            if self.curr.chapterid == self.progress[self.curr.diff] then
                self.choiceNode[self.curr.diff] = GameCache.InstProgress[self.curr.diff]
            else
                self.choiceNode[self.curr.diff] = nodelist[1]
            end

            if self.curr.diff ==1 then
               self.easytableview:removeFromParent()
               self.easytableview = nil
               self.easytableview = self:createNodeTableview(self.curr.chapterid, nodelist, 1)
               self.panel_nodesList:addChild(self.easytableview)
            elseif self.curr.diff == 2 then
               self.hardtableview:removeFromParent()
               self.hardtableview = nil
               self.hardtableview = self:createNodeTableview(self.curr.chapterid, nodelist, 2)
               self.panel_nodesList:addChild(self.hardtableview)
               
            end


            self.curr.nodeid =  self.choiceNode[self.curr.diff]
            self.last.chapterid = self.curr.chapterid
            
        elseif self.last.diff ~= self.curr.diff then
            -- 换难度
            if self.curr.diff == 1 then
                self.easytableview:setVisible(true)
                self.hardtableview:setVisible(false)
            elseif self.curr.diff == 2 then
                self.easytableview:setVisible(false)
                self.hardtableview:setVisible(true)
            end

            self.curr.nodeid =  self.choiceNode[self.curr.diff]
            self.curr.chapterid =  BaseConfig.GetInstanceNode(self.curr.nodeid, self.curr.diff).ChapterID
            self.last.chapterid = self.curr.chapterid

        elseif self.last.chapterid == self.curr.chapterid and self.last.diff == self.curr.diff then

            if self.curr.diff == 1 then
                self.easytableview.lastChoice = nil
                self.easytableview:reloadData()
                if tonumber(string.sub(self.curr.nodeid, -2)) > self.easytableview.cellCount/2 then
                    local offset = self.easytableview:minContainerOffset()
                    self.easytableview:setContentOffset(offset)
                end
                if self.hardtableview.lastChoice then
                    self.hardtableview:updateCellAtIndex(self.hardtableview.lastChoice)
                end
                
            elseif self.curr.diff == 2 then
                self.hardtableview.lastChoice = nil
                self.hardtableview:reloadData()
                -- print(self.hardtableview.lastChoice,self.hardtableview.cellCount/2)
                if tonumber(string.sub(self.curr.nodeid, -2)) > self.hardtableview.cellCount/2 then
                    local offset = self.hardtableview:minContainerOffset()
                    self.hardtableview:setContentOffset(offset)
                end
            end
            -- self.easytableview:updateCellAtIndex(self.easytableview.lastChoice)
            -- self.hardtableview:updateCellAtIndex(self.hardtableview.lastChoice)
        end
    end

    self.ChapterPanelCreated = true
    -- 难度变化，界面展示变化
    self:updateShowUI()

    self.label_pingfen:setString(""..GameCache.Avatar.AccInstanceScore)
    self.btn_zhangjieming:setTitle("第"..self.curr.chapterid.."季", 26, cc.c3b(245,227,129))
    self:updateAwardBoxDisplay()
    self:updateNodePanel()

    if GameCache.Avatar.Level < BaseConfig.GetInstanceChapter(self.curr.chapterid).OpenLevel then
        self.sprite_lock:setVisible(true)
        self.label_lock:setVisible(true)
        self.label_lock:setString(BaseConfig.GetInstanceChapter(self.curr.chapterid).OpenLevel.."级解锁")
    else
        self.sprite_lock:setVisible(false)
        self.label_lock:setVisible(false)
        self.label_lock:setString("")
    end


    if self.curr.chapterid ~= self.progress[self.curr.diff] then
        self.btn_next:setVisible(true)
    else
        self.btn_next:setVisible(false)

    end
    if self.curr.chapterid ~= 1 then
        self.btn_prev:setVisible(true)
    else
        self.btn_prev:setVisible(false)
    end



end

function MapInstanceLayer:createNodeTableview(chapterid, nodelist, diff )

    local function chapterView( chapterid, nodelist, diff )
        
    
        local function tableCellTouched( table, cell )
            local idx = cell:getIdx()

            -- if not  GameCache.InstNode[nodelist[idx+1]..","..diff] or not GameCache.InstNode[nodelist[idx+1]..","..diff].NodeUnlock then
            --     return
            -- end

            if table.lastChoice == idx then
                return
            end

            local c = table:cellAtIndex(table.lastChoice)
            if c then
                local s = c:getChildByName("bg"):getChildByName("choice")
                s:setVisible(false)
            end

            local s = cell:getChildByName("bg"):getChildByName("choice")
            s:setVisible(true)

            
            self.choiceNode[diff] = nodelist[idx+1]
            self.curr.nodeid = self.choiceNode[diff]

            self:updateNodePanel()

            table.lastChoice = idx
        end
    
        local function cellSizeForTable( table, idx )
            return 65, 110
        end
    
        local function tableCellAtIndex( table, idx )
            local cell = table:dequeueCell()
            if cell then
                cell:removeAllChildren()
            else
                cell = cc.TableViewCell:new()
            end


            local node = {}
            node.ID = nodelist[idx+1]
            if not GameCache.InstNode[nodelist[idx+1]..","..diff] then
                GameCache.InstNode[nodelist[idx+1]..","..diff] = {}
                GameCache.InstNode[nodelist[idx+1]..","..diff].NodeUnlock = false
                GameCache.InstNode[nodelist[idx+1]..","..diff].Rating = 0
                GameCache.InstNode[nodelist[idx+1]..","..diff].Score = 0
                GameCache.InstNode[nodelist[idx+1]..","..diff].Count = 0
                GameCache.InstNode[nodelist[idx+1]..","..diff].ResetCount = 0
                node.NodeUnlock = false
                node.Rating = 0
                node.Score = 0
            else
                node.NodeUnlock = GameCache.InstNode[nodelist[idx+1]..","..diff].NodeUnlock
                node.Rating = GameCache.InstNode[nodelist[idx+1]..","..diff].Rating
                node.Score = GameCache.InstNode[nodelist[idx+1]..","..diff].Score
            end

            local itembg = cc.Sprite:create()
            itembg:setName("bg")
            if not node.NodeUnlock then
                itembg:setTexture("image/ui/img/btn/btn_1032.png")
            elseif node.ID == GameCache.InstProgress[diff] then
                itembg:setTexture("image/ui/img/btn/btn_1031.png")
                EffectManager:CreateAnimation(itembg, itembg:getContentSize().width*0.5, itembg:getContentSize().height*0.5, nil, 10, true)

            else
                itembg:setTexture("image/ui/img/btn/btn_1030.png")
            end

            itembg:setAnchorPoint(0,0)
            itembg:setPosition(5, 2)
            cell:addChild(itembg)
    
            local size = itembg:getContentSize()

            if node.ID == GameCache.InstProgress[diff] and (node.Rating == 0 or node.Rating == nil) then
                local back = cc.Sprite:create("image/ui/img/btn/btn_1287.png")
                back:setAnchorPoint(0,1)
                back:setPosition(0, size.height)
                itembg:addChild(back)             
            end

            local choice = cc.Sprite:create("image/ui/img/btn/btn_1029.png")
            choice:setPosition(size.width*0.5, size.height*0.5)
            choice:setName("choice")
            choice:setVisible(false)
            itembg:addChild(choice)

            if node.Rating == 0 and BaseConfig.GetInstanceNode(node.ID, diff).SpecialAwards then
                local award = BaseConfig.GetInstanceNode(node.ID, diff).SpecialAwards
                local award_back = cc.Sprite:create("image/ui/img/btn/btn_1286.png")
                award_back:setAnchorPoint(0.5, 0)
                award_back:setPosition(size.width*0.5, size.height-13)
                itembg:addChild(award_back)
                local icon = Common.getGoods({ID = award.GoodsID, Type = award.GoodsType, num = award.Num}, false)
                icon:setScale(0.5)
                --icon:setTouchEnable(false)
                icon:setPosition(35,45)
                award_back:addChild(icon)
                local label = Common.systemFont(award.Des,0,0,20)
                label:setAnchorPoint(0,0.5)
                label:setPosition(70,28)
                award_back:addChild(label)
            end

            if node.Rating ~= 0 and node.Rating ~= nil then
                local rating = node.Rating
                local score = node.Score

                local icon = cc.Sprite:create(self.ratingTexture2[rating])
                icon:setName("rating")
                icon:setPosition(30, size.height)
                itembg:addChild(icon)

                local label_fenshu = cc.Label:createWithCharMap("image/ui/img/btn/btn_627.png",44,52,string.byte("0"))
                label_fenshu:setPosition(75,size.height)
                label_fenshu:setAdditionalKerning(-9)
                label_fenshu:setName("score")
                label_fenshu:setScale(0.35)
                label_fenshu:setString(score)
                itembg:addChild(label_fenshu)
            end

            -- if node.NodeUnlock then
                local label = Common.finalFont(""..idx+1 , size.width*0.5, size.height*0.5, 30,nil,1)
                itembg:addChild(label)
            -- end

            if BaseConfig.GetInstanceNode(node.ID, diff).ChallengeCount >= 0 then
                local boss = cc.Sprite:create("image/ui/img/btn/btn_363.png")
                boss:setPosition(80,15)
                boss:setScale(0.5)
                itembg:addChild(boss)
            end

            if self.choiceNode[diff] == node.ID then
                choice:setVisible(true)
                table.lastChoice = idx
            end
            return cell
        end
    
        local function numberOfCellsInTableView(table)
            table.cellCount = #nodelist
            return #nodelist
        end
    
        local tableView = cc.TableView:create(cc.size(SCREEN_WIDTH-280, 125))
        tableView.lastChoice = nil

        tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
        tableView:setPosition(cc.p(10, 10))
        tableView:setDelegate()

        tableView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
        tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
        tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
        tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        tableView:reloadData()



        -- print(tableView.lastChoice)


        return tableView

    end

    local view = chapterView( chapterid, nodelist, diff )

    if tonumber(string.sub(self.choiceNode[diff], -2)) > #nodelist/2 then
        local offset = view:minContainerOffset()
        view:setContentOffset(offset)
    end   

    return view    
end

function MapInstanceLayer:enterBattle( node, isreplace )

    if not GameCache.InstNode[node.ID..","..node.DiffLevel] or not GameCache.InstNode[node.ID..","..node.DiffLevel].NodeUnlock then
        application:showFlashNotice("本集未解锁，还需继续努力")
        BaseConfig.isCanClick = true
        return
    end

    if BaseConfig.GetInstanceNode(self.curr.nodeid, self.curr.diff).ChallengeCount >= 0 and 
        GameCache.InstNode[node.ID..","..node.DiffLevel].Count >= BaseConfig.GetInstanceNode(node.ID, node.DiffLevel).ChallengeCount then

        -- application:showFlashNotice("没有挑战次数了")
        local str = BaseConfig.GetInstanceNode(self.curr.nodeid, self.curr.diff).ChallengeCount .. "/".. BaseConfig.GetInstanceNode(self.curr.nodeid, self.curr.diff).ChallengeCount
        commonLayer.InstanceCountLayer(node.ID, node.DiffLevel, GameCache.InstNode[node.ID..","..node.DiffLevel].ResetCount, str ,function (  )
            GameCache.InstNode[node.ID..","..node.DiffLevel].Count = 0
            GameCache.InstNode[node.ID..","..node.DiffLevel].ResetCount = GameCache.InstNode[node.ID..","..node.DiffLevel].ResetCount + 1
            self.shengyuCount:setVisible(true)
            self.shengyuCount:setString("今日剩余次数:"..(BaseConfig.GetInstanceNode(self.curr.nodeid, self.curr.diff).ChallengeCount-GameCache.InstNode[self.curr.nodeid..","..self.curr.diff].Count) .. "/".. BaseConfig.GetInstanceNode(self.curr.nodeid, self.curr.diff).ChallengeCount )
            local c = BaseConfig.GetInstanceNode(self.curr.nodeid, self.curr.diff).ChallengeCount - GameCache.InstNode[self.curr.nodeid..","..self.curr.diff].Count
            if c > 10 then
                c = 10
            end
            self.btn_saodang10:setTitleText("扫"..c.."次")
        end)
        BaseConfig.isCanClick = true
        return
    end

    if GameCache.Avatar.PhyPower - 6 < 0 then
        application:showFlashNotice("体力不够哦")
        commonLayer.NeedPower()
        BaseConfig.isCanClick = true
        return
    end 


    local cid = BaseConfig.GetInstanceNode(node.ID, 1).ChapterID
    if GameCache.Avatar.Level < BaseConfig.GetInstanceChapter(cid).OpenLevel then
        application:showFlashNotice(""..BaseConfig.GetInstanceChapter(cid).OpenLevel.."级解锁")
        BaseConfig.isCanClick = true
        return
    end

    rpc:call("Instance.BeforeF", { NodeID = node.ID, DiffLevel = node.DiffLevel}, function ( event )
        BaseConfig.isCanClick = true
        if event.status == Exceptions.Nil and event.result ~= nil then
            local dropList = event.result.DropPreview
            local form = event.result.Form
            local sessionID  = event.result.SessionID
            local battletype = "PVE"

            local isFirst =  (GameCache.InstNode[node.ID..","..node.DiffLevel].Rating == nil or GameCache.InstNode[node.ID..","..node.DiffLevel].Rating == 0) 
            if (node.ID == 10101 or node.ID == 10102 or node.ID == 10103) and node.DiffLevel == 1 and isFirst then
                battletype = "GUIDE"
            end
            if isreplace then
                application:replaceScene("form.BattleFormScene", GameCache.FORM_TYPE_DEFAULT, 
                    {
                        battleType = battletype, 
                        battleSystem = enums.BattleSystem.Instance,
                        map = node.MapID, 
                        nodeSequence = node.NodeSeq, 
                        nodeInfo = {
                            story = BaseConfig.GetInstanceChapter(cid).Story,
                            chapterID = cid,
                            nodeName = node.Name,
                            map = node.MapID, 
                            NodeID = node.ID, 
                            DiffLevel = node.DiffLevel,
                            IsFirst = isFirst
                        },
                        droplist = dropList, 
                        sessionID = sessionID,
                        attackerForm = form,
                        callback = handler(self, self.battleResult)
                    }
                ) 
            else
                application:pushScene("form.BattleFormScene", GameCache.FORM_TYPE_DEFAULT, 
                    {
                        battleType = battletype, 
                        battleSystem = enums.BattleSystem.Instance,
                        map = node.MapID, 
                        nodeSequence = node.NodeSeq, 
                        nodeInfo = {
                            story = BaseConfig.GetInstanceChapter(cid).Story,
                            chapterID = cid,
                            nodeName = node.Name,
                            map = node.MapID, 
                            NodeID = node.ID, 
                            DiffLevel = node.DiffLevel,
                            IsFirst = isFirst
                        },
                        droplist = dropList, 
                        sessionID = sessionID,
                        attackerForm = form,
                        callback = handler(self, self.battleResult)
                    }
                )                
            end


            Common.CloseGuideLayer({1,2,3,8})
        else
            application:showFlashNotice("本集未解锁")
        end        
    end)
end

function MapInstanceLayer:showSweepingResult( result )
    canExit = false

        --获取扫荡结果，存入缓存
    for i=1,#result do
        for k,v in pairs(result[i].DropList) do
            Common.getGoods(v,true,2)
        end
    end
    
    local panel = cc.Layer:create()
    self:addChild(panel)

    local bgColor = cc.LayerColor:create(cc.c4b(0,0,0,180))
    panel:addChild(bgColor)

    local bgsize = cc.size(580,430)

    local bg = ccui.ImageView:create("image/ui/img/bg/bg_139.png")
    bg:setPosition(SCREEN_WIDTH*0.5,SCREEN_HEIGHT*0.5)
    bg:setScale9Enabled(true)
    bg:setContentSize(bgsize)
    panel:addChild(bg)




    --扫荡结果使用 tableview 展示
    local function createSweepResultTableview( animate )
        local tableView = cc.TableView:create(cc.size(570, 350))

        local tableview_height = 140
        for i=1,#result do
            if #result[i].DropList <= 5 then
                tableview_height = tableview_height + 210
            else
                tableview_height = tableview_height + 310
            end
        end

        local item_posy_offset = 0


        local function createItem(cell, idx, listdata )
            local itemsize = cc.size(570,210)
            if #listdata.DropList > 5 then
                itemsize = cc.size(570,310)
            end

            item_posy_offset = item_posy_offset+itemsize.height
            local default_item = ccui.Layout:create()
            default_item:setTouchEnabled(false)
            default_item:setContentSize(itemsize)
            default_item:setPosition(5, tableview_height-item_posy_offset)
            cell:addChild(default_item)

            if animate then
                tableView:setContentOffsetInDuration(cc.p(0,(item_posy_offset+140)-tableview_height), 0.1)        
            end
            
           

            local tip = ccui.ImageView:create("image/ui/img/btn/btn_362.png")
            tip:setPosition(itemsize.width*0.5, itemsize.height-42)
            tip:setScale9Enabled(true)
            tip:setContentSize(560,40)
            default_item:addChild(tip)
        
            local label = Common.finalFont("第   战", itemsize.width*0.5, itemsize.height-42,24, cc.c3b(255,231,148), 2)
            default_item:addChild(label)

            local label_idx = Common.finalFont(""..idx, itemsize.width*0.5, itemsize.height-42,24, cc.c3b(255,231,148), 2)
            default_item:addChild(label_idx)   


            local icon = cc.Sprite:create("image/ui/img/btn/btn_671.png")
            icon:setPosition(itemsize.width*0.2, itemsize.height-84)
            default_item:addChild(icon)
        
            local label = Common.finalFont("+"..listdata.Exp, itemsize.width*0.33, itemsize.height-84,22, nil, 2)
            default_item:addChild(label)

            -- GameCache.Avatar.Exp = GameCache.Avatar.Exp + listdata.Exp
        
            icon = cc.Sprite:create("image/ui/img/btn/btn_035.png")
            icon:setPosition(itemsize.width*0.65, itemsize.height-84)
            default_item:addChild(icon)
        
            label = Common.finalFont("+"..listdata.Coin, itemsize.width*0.78, itemsize.height-84,22, nil, 2)
            default_item:addChild(label)


            local dropsbg = cc.LayerColor:create(cc.c4b(21,27,33,180),560,100)
            if #listdata.DropList > 5 then
                dropsbg = cc.LayerColor:create(cc.c4b(21,27,33,180),560,200)
            end
            dropsbg:setPosition(5, 0)
            default_item:addChild(dropsbg)

            local size = dropsbg:getContentSize()

            local function liebiaoFun (sender,table )
                if table[1] == #result+1 then
                    local size1 = cc.size(570,140)
                    local wancheng = ccui.Layout:create()
                    wancheng:setTouchEnabled(false)
                    wancheng:setContentSize(size1)
                    local icon = cc.Sprite:create("image/ui/img/btn/btn_373.png")
                    icon:setPosition(size1.width*0.5, size1.height*0.5)
                    icon:setScale(0.1)
                    icon:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 1.2),cc.ScaleTo:create(0.1, 1.0)))
                    wancheng:addChild(icon)

                    cell:addChild(wancheng)

                    canExit = true
                    -- local btn_close = createMixSprite("image/ui/img/btn/btn_598.png")
                    -- btn_close:setPosition(bgsize.width-10, bgsize.height-15)
                    -- btn_close:addTouchEventListener(function (sender, eventType)
                    --     if eventType == ccui.TouchEventType.ended then
                    --         panel:removeFromParent()
                    --         panel = nil
                    --     end
                    -- end)
                    -- bg:addChild(btn_close)
                    return
                end

                createItem(cell, table[1], table[2])

            end
            
            if animate then
                for i=1,#listdata.DropList do
                    local delay = cc.DelayTime:create(0.1*i)

                    local event = cc.CallFunc:create(function ( )
                        local drop = Common.getGoods(listdata.DropList[i],false,2)
                        drop:setPosition(74+((i-1)%5)*100, size.height - (math.floor((i-1)/5)*100+50))
                        drop:setScale(0.1)
                        if i ~= #listdata.DropList then
                            drop:runAction(cc.Sequence:create(cc.ScaleTo:create(0.05, 1.2),cc.ScaleTo:create(0.05, 1.0)))
                        else
                            drop:runAction(cc.Sequence:create(cc.ScaleTo:create(0.05, 1.2),cc.ScaleTo:create(0.05, 1.0),
                                -- cc.CallFunc:create(function (  )    end),
                                cc.DelayTime:create(0.2),
                                
                                cc.CallFunc:create(liebiaoFun, {idx+1,result[idx+1]})))
                        end
                        dropsbg:addChild(drop)
                    end)
                    default_item:runAction(cc.Sequence:create(delay,event))
                end 
            else
                for i=1,#listdata.DropList do
                    local drop = Common.getGoods(listdata.DropList[i],false,2)
                    drop:setPosition(74+((i-1)%5)*100, size.height - (math.floor((i-1)/5)*100+50))
                    if i == #listdata.DropList then
                        drop:runAction(cc.Sequence:create(cc.CallFunc:create(liebiaoFun, {idx+1,result[idx+1]})))
                    end
                    dropsbg:addChild(drop)
                end              
            end

        end

        local function cellSizeForTable( table, index )
            return tableview_height, 570
        end

        local function tableCellAtIndex( table, index )

            local cell = cc.TableViewCell:new()

            createItem(cell, 1, result[1])


            return cell
        end

        local function numberOfCellsInTableView(table)
            return 1
        end

        tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        tableView:setDelegate()
        tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
        tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
        tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        tableView:reloadData()  
        -- tableView:setContentOffsetInDuration(cc.p(0,-210), 0.1)
        
        return tableView
    end



    local tableView_animate = createSweepResultTableview(true)
    tableView_animate:setPosition(0,40)
    bg:addChild(tableView_animate)

    local function onTouchBegan(touch, event)

        return true
    end

    local function onTouchEnded(touch, event)
        if not canExit then
            if tableView_animate then
                tableView_animate:removeFromParent()
                tableView_animate = nil
            end
            local tableView_noanimate = createSweepResultTableview(false)
            tableView_noanimate:setPosition(0,40)
            bg:addChild(tableView_noanimate)
            tableView_noanimate:setContentOffset(tableView_noanimate:maxContainerOffset())
            canExit = true
            return
        end
        local target = event:getCurrentTarget()
        local locationInNode = bg:convertToNodeSpace(touch:getLocation())
        local startpos = bg:convertToNodeSpace(touch:getStartLocationInView())
        local s = bg:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if not cc.rectContainsPoint(rect, startpos) and not cc.rectContainsPoint(rect, locationInNode) then

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

function MapInstanceLayer:showStoryBoard(  )

    local layer = cc.LayerColor:create(cc.c4b(0,0,0,180))
    self:addChild(layer)

    local spriteBoard = cc.Sprite:create("image/ui/img/btn/btn_1078.png")
    spriteBoard:setPosition(display.cx, display.cy + 175)
    layer:addChild(spriteBoard)

    local bg = cc.Sprite:create("image/ui/img/btn/btn_1079.png")
    bg:setPosition(display.cx, display.cy)
    layer:addChild(bg)

    local bgsize = bg:getContentSize()

    local labelStory = Common.systemFont(BaseConfig.GetInstanceChapter(self.curr.chapterid).Story, 0 , 0 , 19, cc.c3b(123, 132, 134))
    labelStory:setAlignment(cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    labelStory:setDimensions(400, 200)
    labelStory:setPosition(cc.p(display.cx + 8, display.cy - 40))
    layer:addChild(labelStory)

    local btn_close = ccui.MixButton:create("image/ui/img/btn/btn_598.png")
    btn_close:setPosition(bgsize.width-15, bgsize.height-15)
    btn_close:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            layer:removeFromParent()
            layer = nil
        end
    end)
    bg:addChild(btn_close)

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

function MapInstanceLayer:createFlexUI()

    local layer = cc.Layer:create()
    self:addChild(layer)

    -- 顶部条
    local topBack = cc.Sprite:create(self.backTexture.easy_top)
    topBack:setAnchorPoint(0.5,1)
    topBack:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT-40)
    layer:addChild(topBack, 1)
    self.panel_top = topBack

    local topbackSize = topBack:getContentSize()
   
    --
    local leftBack = cc.Sprite:create(self.backTexture.easy_back)
    leftBack:setAnchorPoint(0,0)
    leftBack:setPosition(40, 105)
    layer:addChild(leftBack, 1)
    self.panel_left = leftBack

    local leftbackSize = leftBack:getContentSize()


    local rightBack = cc.Sprite:create(self.backTexture.easy_back)
    rightBack:setAnchorPoint(1,0)
    rightBack:setPosition(SCREEN_WIDTH-40, 105)
    layer:addChild(rightBack, 1)
    self.panel_right = rightBack

    local rightbackSize = rightBack:getContentSize()


    local bottomBack = ccui.ImageView:create("image/ui/img/bg/bg_358.png")
    bottomBack:setScale9Enabled(true)
    bottomBack:setContentSize(SCREEN_WIDTH,100)
    bottomBack:setAnchorPoint(0.5,0)
    bottomBack:setPosition(SCREEN_WIDTH*0.5, 0)
    layer:addChild(bottomBack, 1)

    local bottombackSize = bottomBack:getContentSize()

    local line = ccui.ImageView:create("image/ui/img/btn/btn_658.png")
    line:setScale9Enabled(true)
    line:setContentSize(SCREEN_WIDTH,5)
    line:setPosition(bottombackSize.width*0.5, bottombackSize.height)
    bottomBack:addChild(line)


    local btn_start = ccui.MixButton:create()
    btn_start:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)
    layer:addChild(btn_start)
    btn_start:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended and BaseConfig.isCanClick then
            BaseConfig.isCanClick = false
            if not  GameCache.InstNode[self.curr.nodeid..","..self.curr.diff] or not GameCache.InstNode[self.curr.nodeid..","..self.curr.diff].NodeUnlock then
                application:showFlashNotice("未解锁")
                BaseConfig.isCanClick = true
                return
            end
            local node = BaseConfig.GetInstanceNode(self.curr.nodeid, self.curr.diff)
            self:enterBattle(node, false)
        end
    end)
    self.btn_start = btn_start

    EffectManager:CreateAnimation(layer, SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5, nil, 11, true)

    local sprite_lock = cc.Sprite:create("image/ui/img/btn/btn_258.png")
    sprite_lock:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)
    sprite_lock:setVisible(false)
    layer:addChild(sprite_lock)
    self.sprite_lock = sprite_lock

    local label_lock = Common.finalFont("", SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.4, 30, nil, 1)
    label_lock:setVisible(false)
    layer:addChild(label_lock)
    self.label_lock = label_lock


    local btn_next = ccui.MixButton:create("image/ui/img/btn/btn_875.png")
    btn_next:setPosition(SCREEN_WIDTH-240, SCREEN_HEIGHT*0.5)
    btn_next:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if self.curr.chapterid + 1 > self.progress[self.curr.diff] then
                return
            end
           self.curr.chapterid = self.curr.chapterid + 1
           self:updateChapterPanel()
        end
    end)
    layer:addChild(btn_next)
    self.btn_next = btn_next

    local btn_prev = ccui.MixButton:create("image/ui/img/btn/btn_875.png")
    btn_prev:setFlippedX(true)
    btn_prev:setPosition(240, SCREEN_HEIGHT*0.5)
    btn_prev:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if self.curr.chapterid - 1 <= 0 then
                return
            end
           self.curr.chapterid = self.curr.chapterid - 1
           self:updateChapterPanel()
        end
    end)
    layer:addChild(btn_prev)
    self.btn_prev = btn_prev


    -- TOP

    local costsize = cc.size(260,40)
    local costbg = ccui.Scale9Sprite:create("image/ui/img/btn/btn_1010.png")
    -- costbg:setScale9Enabled(true)
    costbg:setContentSize(costsize)
    topBack:addChild(costbg)
    self.sprite_costbg = costbg


    local image_exp = cc.Sprite:create("image/ui/img/btn/btn_671.png")
    image_exp:setPosition(45, costsize.height*0.5)
    costbg:addChild(image_exp)

    local exp = Common.finalFont("+60", 80, costsize.height*0.5, 26, cc.c3b(255,255,0),1)
    exp:setAnchorPoint(0,0.5)
    costbg:addChild(exp)
    self.label_exp = exp

    local tili = cc.Sprite:create("image/ui/img/bg/tili.png")
    tili:setPosition(175, costsize.height*0.5)
    costbg:addChild(tili)

    local label_tili = Common.finalFont("-6",200, costsize.height*0.5, 26, cc.c3b(255,255,0),1)
    label_tili:setAnchorPoint(0,0.5)
    costbg:addChild(label_tili)
    -- self.label_tili = label_tili

    local titlebg = cc.Sprite:create()
    titlebg:setPosition(topbackSize.width*0.5, 15)
    topBack:addChild(titlebg)
    self.title = titlebg

    local title = Common.finalFont("", topbackSize.width*0.5, 15, 24, cc.c3b(245,227,129))
    topBack:addChild(title)
    self.label_title = title



    -- LEFT

    local geban = cc.Sprite:create(self.backTexture.easy_geban)
    geban:setPosition(leftbackSize.width*0.5, 410)
    leftBack:addChild(geban)
    self.geban1 = geban

    geban = cc.Sprite:create(self.backTexture.easy_geban)
    geban:setPosition(leftbackSize.width*0.5, 290)
    leftBack:addChild(geban)
    self.geban2 = geban

    geban = cc.Sprite:create(self.backTexture.easy_geban)
    geban:setPosition(leftbackSize.width*0.5, 170)
    leftBack:addChild(geban)
    self.geban3 = geban

    local baoxiang = ccui.MixButton:create("image/ui/img/bg/bg_271.png")
    baoxiang:setScale9Size(cc.size(143,38))
    baoxiang:setTitle("本季宝箱",20,cc.c3b(245,227,129))
    baoxiang:setTouchEnabled(false)
    baoxiang:setPosition(leftbackSize.width*0.5, 420)
    leftBack:addChild(baoxiang)


    -- local goldeffect = cc.Sprite:create("image/ui/img/btn/btn_839.png")
    -- goldeffect:setPosition(leftbackSize.width*0.5, 310)
    -- goldeffect:setVisible(false)
    --  leftBack:addChild(goldeffect) 
     -- self.goldboxEffect =  goldeffect



    --  local slivereffect = cc.Sprite:create("image/ui/img/btn/btn_839.png")
    -- slivereffect:setPosition(leftbackSize.width*0.5, 190)
    -- slivereffect:setVisible(false)
    --  leftBack:addChild(slivereffect) 
    --  self.sliverboxEffect =  slivereffect    




    local goldBox = ccui.MixButton:create()
    goldBox:setPosition(leftbackSize.width*0.5, 310)
    leftBack:addChild(goldBox)    
    self.goldBox = goldBox
    goldBox:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            self:showAwardInfo(1, self.curr.gold)
        end
    end)



    local sliverBox = ccui.MixButton:create()
    sliverBox:setPosition(leftbackSize.width*0.5, 190)
    leftBack:addChild(sliverBox)    
    self.sliverBox = sliverBox
    sliverBox:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            self:showAwardInfo(2, self.curr.sliver)
        end
    end)  

     self.goldboxEffect = EffectManager:CreateAnimation(leftBack, leftbackSize.width*0.5, 310, nil, 38, true)
     self.goldboxEffect:setVisible(false)  

    self.sliverboxEffect = EffectManager:CreateAnimation(leftBack, leftbackSize.width*0.5, 190, nil, 38, true)
    self.sliverboxEffect:setVisible(false)

    -- right

    local geban = cc.Sprite:create("image/ui/img/bg/bg_268.png")
    geban:setPosition(leftbackSize.width*0.5, 410)
    rightBack:addChild(geban)
    self.geban4 = geban

    geban = cc.Sprite:create("image/ui/img/bg/bg_268.png")
    geban:setPosition(rightbackSize.width*0.5, 330)
    rightBack:addChild(geban)
    self.geban5 = geban

    geban = cc.Sprite:create("image/ui/img/bg/bg_268.png")
    geban:setPosition(rightbackSize.width*0.5, 250)
    rightBack:addChild(geban)
    self.geban6 = geban

    geban = cc.Sprite:create("image/ui/img/bg/bg_268.png")
    geban:setPosition(rightbackSize.width*0.5, 170)
    rightBack:addChild(geban)
    self.geban7 = geban

    local wupin = ccui.MixButton:create("image/ui/img/bg/bg_271.png")
    wupin:setScale9Size(cc.size(143,38))
    wupin:setTitle("概率掉落物品",20,cc.c3b(245,227,129))
    wupin:setTouchEnabled(false)
    wupin:setPosition(rightbackSize.width*0.5, 420)
    wupin:setVisible(false)
    rightBack:addChild(wupin)
    self.wupin1 = wupin

    local wupin2 = EffectManager:CreateAnimation(rightBack, rightbackSize.width*0.5, 420, nil, 37, true)
    wupin2:setVisible(false)
    self.wupin2 = wupin2


    local btn_saodang = ccui.MixButton:create("image/ui/img/btn/btn_818.png")
    btn_saodang:setScale9Size(cc.size(135,55))
    btn_saodang:setTitle("扫荡",24,cc.c3b(238,205,142),1)
    btn_saodang:setPosition(rightbackSize.width*0.5, 115)
    rightBack:addChild(btn_saodang)
    btn_saodang:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended and BaseConfig.isCanClick then
            BaseConfig.isCanClick = false
            local nodeid = self.curr.nodeid
            local diff = self.curr.diff

            if GameCache.InstNode[nodeid..","..diff].Rating == nil or GameCache.InstNode[nodeid..","..diff].Rating < 3 then
                application:showFlashNotice("亲，A级以上通关才能扫荡哦")
                BaseConfig.isCanClick = true
                return
            end


            if BaseConfig.GetInstanceNode(nodeid, diff).ChallengeCount >= 0 and 
                GameCache.InstNode[nodeid..","..diff].Count >= BaseConfig.GetInstanceNode(nodeid, diff).ChallengeCount then
        
                -- application:showFlashNotice("没有挑战次数了")
                local str = BaseConfig.GetInstanceNode(nodeid, diff).ChallengeCount .. "/".. BaseConfig.GetInstanceNode(nodeid, diff).ChallengeCount
                commonLayer.InstanceCountLayer(nodeid, diff, GameCache.InstNode[nodeid..","..diff].ResetCount, str, function (  )
                    GameCache.InstNode[nodeid..","..diff].Count = 0
                    GameCache.InstNode[nodeid..","..diff].ResetCount = GameCache.InstNode[nodeid..","..diff].ResetCount + 1
                    self.shengyuCount:setVisible(true)
                    self.shengyuCount:setString("今日剩余次数:"..(BaseConfig.GetInstanceNode(nodeid, diff).ChallengeCount-GameCache.InstNode[nodeid..","..diff].Count) .. "/".. BaseConfig.GetInstanceNode(nodeid, diff).ChallengeCount )
                    local c = BaseConfig.GetInstanceNode(nodeid, diff).ChallengeCount - GameCache.InstNode[nodeid..","..diff].Count
                    if c > 10 then
                        c = 10
                    end
                    self.btn_saodang10:setTitleText("扫"..c.."次")
                end)

                BaseConfig.isCanClick = true
                return
            end


            if GameCache.Avatar.PhyPower - 6 < 0 then
                application:showFlashNotice("体力不够哦")
                commonLayer.NeedPower()
                BaseConfig.isCanClick = true
                return
            end 

            rpc:call("Instance.Sweep", { NodeID = nodeid, DiffLevel = diff, Count = 1}, function ( event )
                if event.status == Exceptions.Nil and event.result ~= nil then
                    -- 展示扫荡成果
                    self:showSweepingResult(event.result)
                    if BaseConfig.GetInstanceNode(nodeid, diff).ChallengeCount >= 0 then
                        GameCache.InstNode[nodeid..","..diff].Count = GameCache.InstNode[nodeid..","..diff].Count + 1
                        self.shengyuCount:setString("今日剩余次数:"..(BaseConfig.GetInstanceNode(nodeid, diff).ChallengeCount-GameCache.InstNode[nodeid..","..diff].Count) .. "/".. BaseConfig.GetInstanceNode(nodeid, diff).ChallengeCount )
                        local shengyu = BaseConfig.GetInstanceNode(nodeid, diff).ChallengeCount - GameCache.InstNode[nodeid..","..diff].Count
                        if shengyu > 10 then
                            shengyu = 10
                        end
                        self.btn_saodang10:setTitleText("扫"..shengyu.."次")
                    end
                elseif event.status == Exceptions.EInstanceUnableToSweep then
                    application:showFlashNotice("亲，A级以上通关才能扫荡哦")
                end   

                BaseConfig.isCanClick = true             
            end)
        end
    end)


    self.panel_nodeDrops = cc.LayerColor:create(cc.c4b(0,0,0,0),150,250)
    self.panel_nodeDrops:setPosition(0,145)
    rightBack:addChild(self.panel_nodeDrops)


    local btn_saodang10 = ccui.MixButton:create("image/ui/img/btn/btn_818.png")
    btn_saodang10:setScale9Size(cc.size(135,55))
    btn_saodang10:setTitle("扫10次",24,cc.c3b(238,205,142),1)
    btn_saodang10:setPosition(rightbackSize.width*0.5, 55)
    rightBack:addChild(btn_saodang10)
    self.btn_saodang10 = btn_saodang10
    btn_saodang10:addTouchEventListener(function (sender, eventType)

        if eventType == ccui.TouchEventType.ended and BaseConfig.isCanClick then
            BaseConfig.isCanClick = false
            local c = 10

            local nodeid = self.curr.nodeid
            local diff = self.curr.diff

            if GameCache.InstNode[nodeid..","..diff].Rating == nil or GameCache.InstNode[nodeid..","..diff].Rating < 3 then
                application:showFlashNotice("亲，A级以上通关才能扫荡哦")
                BaseConfig.isCanClick = true
                return
            end

            if BaseConfig.getVipPrivilege( GameCache.Avatar.VIP ).OpenSweep10 == 0 then
                local layer = commonLayer.ToBuyVIP("达到VIP 2 才可扫荡多次噢～")
                self:addChild(layer)
                BaseConfig.isCanClick = true
                return
            end


            if BaseConfig.GetInstanceNode(nodeid, diff).ChallengeCount >= 0 then
                if GameCache.InstNode[nodeid..","..diff].Count >= BaseConfig.GetInstanceNode(nodeid, diff).ChallengeCount then
        
                    -- application:showFlashNotice("没有挑战次数了")
                    local str = BaseConfig.GetInstanceNode(nodeid, diff).ChallengeCount .. "/".. BaseConfig.GetInstanceNode(nodeid, diff).ChallengeCount
                    commonLayer.InstanceCountLayer(nodeid, diff, GameCache.InstNode[nodeid..","..diff].ResetCount, str, function (  )
                        GameCache.InstNode[nodeid..","..diff].Count = 0
                        GameCache.InstNode[nodeid..","..diff].ResetCount = GameCache.InstNode[nodeid..","..diff].ResetCount + 1
                        self.shengyuCount:setVisible(true)
                        self.shengyuCount:setString("今日剩余次数:"..(BaseConfig.GetInstanceNode(nodeid, diff).ChallengeCount-GameCache.InstNode[nodeid..","..diff].Count) .. "/".. BaseConfig.GetInstanceNode(nodeid, diff).ChallengeCount )
                        local c = BaseConfig.GetInstanceNode(nodeid, diff).ChallengeCount - GameCache.InstNode[nodeid..","..diff].Count
                        if c > 10 then
                            c = 10
                        end
                        self.btn_saodang10:setTitleText("扫"..c.."次")
                        end)
                    BaseConfig.isCanClick = true
                    return
                else
                    local shengyu = BaseConfig.GetInstanceNode(nodeid, diff).ChallengeCount - GameCache.InstNode[nodeid..","..diff].Count
                    if shengyu < 10 then
                        c = shengyu
                    end
                end
            end
                    
            if GameCache.Avatar.PhyPower - 60 < 0 then
                application:showFlashNotice("体力不够哦")
                commonLayer.NeedPower()
                BaseConfig.isCanClick = true
                return
            end 



            rpc:call("Instance.Sweep", { NodeID = nodeid, DiffLevel = diff, Count = c}, function ( event )
                if event.status == Exceptions.Nil and event.result ~= nil then
                    -- 展示扫荡成果
                    self:showSweepingResult(event.result)
                    if BaseConfig.GetInstanceNode(nodeid, diff).ChallengeCount >= 0 then
                        GameCache.InstNode[nodeid..","..diff].Count = GameCache.InstNode[nodeid..","..diff].Count + c
                         local shengyu = BaseConfig.GetInstanceNode(nodeid, diff).ChallengeCount - GameCache.InstNode[nodeid..","..diff].Count

                        self.shengyuCount:setString("今日剩余次数:".. shengyu .. "/".. BaseConfig.GetInstanceNode(nodeid, diff).ChallengeCount )
                       
                        if shengyu > 10 then
                            shengyu = 10
                        end
                        self.btn_saodang10:setTitleText("扫"..shengyu.."次")
                    end
                elseif event.status == Exceptions.ERoleVIPLevelNotReach then
                    local layer = commonLayer.ToBuyVIP("达到VIP 2 才可扫荡多次噢～")
                    self:addChild(layer)
                elseif event.status == Exceptions.EInstanceUnableToSweep then
                    application:showFlashNotice("亲，A级以上通关才能扫荡哦")
                end 

                BaseConfig.isCanClick = true               
            end)
        end
    end)



    -- down

    local label = Common.systemFont("今日剩余次数:", 0 , 0, 22)
    label:setAnchorPoint(1,0)
    label:setVisible(false)
    label:setPosition(0,0)
    rightBack:addChild(label)
    self.shengyuCount = label


    --[[
    local function showBook(  )
        local layer = cc.Layer:create()
        self:addChild(layer)
        local bg = cc.Sprite:create("dummy/story_01.png")
        bg:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)
        bg:setScale(0.001)
        layer:addChild(bg)

        local action = cc.Sequence:create({cc.ScaleTo:create(0.05, 1.1),cc.ScaleTo:create(0.08, 1.0)})
        bg:runAction(action)

        local function onTouchBegan(touch, event)
            return true
        end
        local function onTouchEnded(touch, event)
            layer:removeFromParent()
            layer = nil
        end

        local listener = cc.EventListenerTouchOneByOne:create()
        listener:setSwallowTouches(true)
        listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
        listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
        local eventDispatcher = self:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)

    end

    local book = createMixSprite("image/ui/img/btn/btn_831.png", nil, "image/ui/img/btn/btn_833.png")
    book:setPosition(topbackSize.width*0.8, topbackSize.height*0.3)
    book:setChildPos(0.5, 0.5)
    topBack:addChild(book)
    book:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            showBook()
        end
    end)       

    --]]
    -- 选择章节

    local function createChapterTableLayer(  )
        local chapterTableLayer = cc.Layer:create()
        layer:addChild(chapterTableLayer, 3)

    
        local temp = {"一","二","三","四","五","六","七", "八", "九" ,"十" ,"十一" ,"十二", "十三", "十四" ,"十五" , 
        "十六",  "十七",  "十八",  "十九", "二十" ,"二十一" ,"二十二", "二十三", "二十四", "二十五" ,"二十六", "二十七",
         "二十八", "二十九" ,"三十"}
    
        local function createChapterTableView(  )
            local function tableCellTouched( table, cell )
                local idx = cell:getIdx()
                if cell.lock then
                    local str = BaseConfig.GetInstanceChapter(idx + 1).OpenLevel
                    if GameCache.Avatar.Level < str then
                        application:showFlashNotice("需要玩家达到"..str.."级方可解锁本季")
                    end
                    return
                end
                table.lastchoice = self.curr.chapterid - 1
                if table.lastchoice == idx then
                   return
                end

                self.curr.chapterid = idx + 1

                if self.curr.chapterid == self.progress[self.curr.diff] then
                    self.choiceNode[self.curr.diff] = GameCache.InstProgress[self.curr.diff]
                    self.curr.nodeid = self.choiceNode[self.curr.diff]
                else
                    if self.curr.diff == 1 then
                        self.choiceNode[self.curr.diff] = BaseConfig.GetInstanceChapter(idx + 1).NodeList[1]
                    elseif self.curr.diff == 2 then
                        self.choiceNode[self.curr.diff] = BaseConfig.GetInstanceChapter(idx + 1).HardNodeList[1]
                    end
                    self.curr.nodeid = self.choiceNode[self.curr.diff]

                end

                self:updateChapterPanel()
                table.lastchoice = idx
            end
        
            local function cellSizeForTable( table, idx )
                return 95, 230
            end
        
            local function tableCellAtIndex( table, idx )
                local cell = cc.TableViewCell:new()
                local itembg = cc.Sprite:create("image/ui/img/bg/bg_212.png")
                itembg:setAnchorPoint(0,0)
                itembg:setPosition(10, 2)
                cell:addChild(itembg)
        
                local size = itembg:getContentSize()

                local icon = cc.Sprite:create("image/ui/img/btn/btn_1242.png")
                icon:setPosition(45, size.height*0.5)
                itembg:addChild(icon)

                local number = cc.Label:createWithCharMap("image/ui/img/btn/btn_1241.png",39,58,string.byte("0"))
                number:setString(""..idx+1)
                number:setPosition(45, size.height*0.5)
                number:setAdditionalKerning(-5)
                itembg:addChild(number)
    
                if self.progress[self.curr.diff] < idx+1 then
                    local shadow = cc.Sprite:create("image/ui/img/btn/btn_926.png")
                    shadow:setAnchorPoint(0, 0)
                    -- shadow:setPosition(13, 13)
                    itembg:addChild(shadow)
                    cell.lock = true

                    if GameCache.Avatar.Level < BaseConfig.GetInstanceChapter(idx+1).OpenLevel then
                        local label = Common.finalFont(BaseConfig.GetInstanceChapter(idx+1).OpenLevel.."级解锁", size.width*0.6, size.height*0.36,18, cc.c3b(10,51,91))
                        itembg:addChild(label)
                    else
                        local label = Common.finalFont("前一季未通关", size.width*0.65, size.height*0.36,18, cc.c3b(10,51,91))
                        itembg:addChild(label)
                    end
                end
    
                local label = Common.finalFont("第"..temp[idx+1].."季", size.width*0.6, size.height*0.66,18, cc.c3b(10,51,91))
                itembg:addChild(label)


    
                -- local label = Common.finalFont(BaseConfig.GetInstanceChapter(idx+1).ChapterName, size.width*0.6, size.height*0.3,22,cc.c3b(73,131,178))
                -- itembg:addChild(label)
    
                return cell
            end
        
            local function numberOfCellsInTableView(table)
                return BaseConfig.GetInstanceChapterCount()
            end
        
            local tableView = cc.TableView:create(cc.size(250, 375))
            tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
            tableView:setPosition(cc.p(5, 25))
            tableView:setDelegate()
            tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    
            tableView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
            tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
            tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
            tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
            tableView:reloadData()
        
            return tableView
        end
    
        local tableViewSize = cc.size(260, 420)
        local tableViewBack = ccui.ImageView:create()
        -- tableViewBack:setFlippedY(true)
        tableViewBack:setScale9Enabled(true)
        tableViewBack:loadTexture("image/ui/img/bg/bg_213.png")
        tableViewBack:setScale(0.01)
        -- tableViewBack:setVisible(false)
        tableViewBack:setAnchorPoint(0.5,0)
        tableViewBack:setContentSize(tableViewSize)
        tableViewBack:setPosition(150, 165)
        chapterTableLayer:addChild(tableViewBack,3)
    
        local chapterView = createChapterTableView()
    
        tableViewBack:addChild(chapterView)

        tableViewBack:runAction( cc.Sequence:create( cc.ScaleTo:create(0.08, 1.2),cc.ScaleTo:create(0.08, 1))) 
    
        local function onTouchBegan(touch, event)
            -- local target = event:getCurrentTarget()
            -- local locationInNode = target:convertToNodeSpace(touch:getLocation())
            -- local s = target:getContentSize()
            -- local rect = cc.rect(0,0,s.width,s.height)
           
            -- if cc.rectContainsPoint(rect, locationInNode) then
            --     return true
            -- end
    
            return true
        end
    
        local function onTouchEnded( touch, event )
            local target = event:getCurrentTarget()
            local locationInNode = tableViewBack:convertToNodeSpace(touch:getLocation())
            local startpos = touch:getStartLocationInView()
            local s = tableViewBack:getContentSize()
            local rect = cc.rect(0,0,s.width,s.height)
           
            if not cc.rectContainsPoint(rect, startpos) and not cc.rectContainsPoint(rect, locationInNode) then
                chapterTableLayer:removeFromParent()
                chapterTableLayer = nil
            end
    
        end
    
        
        local listener = cc.EventListenerTouchOneByOne:create()
        listener:setSwallowTouches(true)
        listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
        listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
        local eventDispatcher = self:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, chapterTableLayer)
    end
    


    local switch = true
    local btn_zhangjie = ccui.MixButton:create("image/ui/img/btn/btn_831.png") -- 832
    btn_zhangjie:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            createChapterTableLayer()
            -- if switch then
                -- tableViewBack:runAction( cc.Sequence:create( cc.ScaleTo:create(0.08, 1.2),cc.ScaleTo:create(0.08, 1)))             
            -- else
                -- tableViewBack:runAction(cc.ScaleTo:create(0.1, 0.01))
            -- end
            -- chapterTableLayer:setVisible(true)
            -- switch = not switch
        end
        
    end)
    btn_zhangjie:setPosition(115, 135)    
    self.btn_zhangjieming = btn_zhangjie
    layer:addChild(btn_zhangjie)

    local btn_juqing = ccui.MixButton:create("image/ui/img/btn/btn_831.png") -- 832
    btn_juqing:setTitle("剧情梗概", 22, cc.c3b(245,227,129))
    btn_juqing:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            self:showStoryBoard()
        end
    end)
    btn_juqing:setPosition(115, 205)    
    layer:addChild(btn_juqing)



    -- local label = Common.finalFont("选季" , 115, 175, 18, cc.c3b(245,227,129), 1)
    -- layer:addChild(label)

    local label = Common.finalFont("冒险累计得分:", 200, 120, 22)
    label:setAnchorPoint(0,0.5)
    layer:addChild(label)

    local pingfen = Common.finalFont("", 360,120, 34, cc.c3b(151,255,74),1)
    pingfen:setAnchorPoint(0,0.5)
    layer:addChild(pingfen)
    self.label_pingfen = pingfen



    -- local label = Common.finalFont("选难度" , 115 , 85, 18, cc.c3b(245,227,129), 1)
    -- bottomBack:addChild(label)


    local easy = true
    local easytexture = "image/ui/img/btn/btn_1038.png"
    local hardtexture = "image/ui/img/btn/btn_1037.png"

    -- local btn_selectDiff = ccui.MixButton:create(easytexture) -- 832
    -- if self.curr.diff == 1 then
    --     btn_selectDiff:loadTextureNormal(easytexture)
    --     easy = true
    -- elseif self.curr.diff == 2 then
    --     btn_selectDiff:loadTextureNormal(hardtexture)
    --     easy = false
    -- end

    -- btn_selectDiff:setPosition(115, 38)
    -- bottomBack:addChild(btn_selectDiff)
    -- btn_selectDiff:addTouchEventListener(function ( sender, eventType )
    --     if eventType == ccui.TouchEventType.ended then
    --         if easy then
    --             self.curr.diff = 2
    --             btn_selectDiff:loadTextureNormal(hardtexture)
    --         else
    --             self.curr.diff = 1
    --             btn_selectDiff:loadTextureNormal(easytexture)
    --         end
    --         self:updateChapterPanel()
    --         easy = not easy
    --     end
        
    -- end)

    local btn_selectEasy = ccui.MixButton:create(easytexture)
    local btn_selectHard = ccui.MixButton:create(hardtexture)

    btn_selectEasy:setPosition(65, 50)
    bottomBack:addChild(btn_selectEasy)
    btn_selectEasy:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            if easy then
                return
            else
                btn_selectEasy:setBright(true)
                btn_selectHard:setBright(false)
                self.curr.diff = 1
            end
            self:updateChapterPanel()
            easy = not easy
        end
    end)

    
    btn_selectHard:setPosition(165, 50)
    bottomBack:addChild(btn_selectHard)
    btn_selectHard:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            if not easy then
                return
            else
                btn_selectEasy:setBright(false)
                btn_selectHard:setBright(true)
                self.curr.diff = 2
            end
            self:updateChapterPanel()
            easy = not easy
        end
    end)

    if self.curr.diff == 1 then
        btn_selectEasy:setBright(true)
        btn_selectHard:setBright(false)
        easy = true
    elseif self.curr.diff == 2 then
        btn_selectEasy:setBright(false)
        btn_selectHard:setBright(true)
        easy = false
    end

    -- local layercolor = cc.LayerColor:create(cc.c4b(0,0,0,0), SCREEN_WIDTH-250, 180)
    -- layercolor:setPosition(220,0)
    -- bottomBack:addChild(layercolor)
    -- self.panel_nodesList = layercolor

    local panel_nodesList = ccui.ImageView:create("image/ui/img/bg/bg_357.png")
    panel_nodesList:setScale9Enabled(true)
    panel_nodesList:setContentSize(SCREEN_WIDTH-250,90)
    panel_nodesList:setAnchorPoint(0,0)
    panel_nodesList:setPosition(220,5)
    bottomBack:addChild(panel_nodesList)
    self.panel_nodesList = panel_nodesList

    self:CreateChapterPanel()

end

function MapInstanceLayer:CreateChapterPanel(  )

        self.easytableview = nil
        self.hardtableview = nil 

        local nodelist = {}

        if self.curr.diff == 1 then
            -- 普通难度，创建所选章节的tableview
            nodelist = BaseConfig.GetInstanceChapter(self.curr.chapterid).NodeList
            self.easytableview = self:createNodeTableview(self.curr.chapterid, nodelist, 1)
            self.easytableview:setVisible(false)
            self.panel_nodesList:addChild(self.easytableview)

            -- 困难难度，创建最新进度的tableview
            nodelist = BaseConfig.GetInstanceChapter(self.progress[2]).HardNodeList
            self.hardtableview = self:createNodeTableview(self.progress[2], nodelist, 2)
            self.hardtableview:setVisible(false)
            self.panel_nodesList:addChild(self.hardtableview)

            self.easytableview:setVisible(true)

        elseif self.curr.diff == 2 then
            -- 普通难度，创建最新进度的tableview
            nodelist = BaseConfig.GetInstanceChapter(self.progress[1]).NodeList
            self.easytableview = self:createNodeTableview(self.progress[1], nodelist, 1)
            self.easytableview:setVisible(false)
            self.panel_nodesList:addChild(self.easytableview)

            -- 困难难度，创建所选章节的tableview
            nodelist = BaseConfig.GetInstanceChapter(self.curr.chapterid).HardNodeList
            self.hardtableview = self:createNodeTableview(self.curr.chapterid, nodelist, 2)
            self.hardtableview:setVisible(false)
            self.panel_nodesList:addChild(self.hardtableview)   

            self.hardtableview:setVisible(true)
        end
        self.last.diff = self.curr.diff
        self.last.chapterid = self.curr.chapterid
end

function MapInstanceLayer:updateAwardBoxDisplay(  )

    if self.curr.diff == 1 then
        self.curr.gold = GameCache.InstChapter[self.curr.chapterid].EasySStatus
        self.curr.sliver = GameCache.InstChapter[self.curr.chapterid].EasyStatus
    elseif self.curr.diff == 2 then
        self.curr.gold = GameCache.InstChapter[self.curr.chapterid].HardSStatus
        self.curr.sliver = GameCache.InstChapter[self.curr.chapterid].HardStatus
    end

    if self.curr.gold == 0 then

        -- self.goldboxEffect:stopAllActions()
        self.goldboxEffect:setVisible(false)
        if self.curr.diff == 1 then
            self.goldBox:loadTextureNormal(self.boxTexture.easy_gold_box)
        elseif self.curr.diff == 2 then
            self.goldBox:loadTextureNormal(self.boxTexture.hard_gold_box)
        end
        
    elseif self.curr.gold == 1 then
        -- self.goldboxEffect:stopAllActions()
        self.goldboxEffect:setVisible(true)
            -- local rep = cc.RepeatForever:create(cc.RotateBy:create(3.0, 360))
            -- self.goldboxEffect:runAction(rep)

        if self.curr.diff == 1 then
            self.goldBox:loadTextureNormal(self.boxTexture.easy_gold_box)
        elseif self.curr.diff == 2 then
            self.goldBox:loadTextureNormal(self.boxTexture.hard_gold_box)
        end
        
    elseif self.curr.gold == 2 then
        -- self.goldboxEffect:stopAllActions()
        self.goldboxEffect:setVisible(false)
        if self.curr.diff == 1 then
            self.goldBox:loadTextureNormal(self.boxTexture.easy_gold_opened_box)
        elseif self.curr.diff == 2 then
            self.goldBox:loadTextureNormal(self.boxTexture.hard_gold_opened_box)
        end
     end

    if self.curr.sliver == 0 then
        -- self.sliverboxEffect:stopAllActions()
        self.sliverboxEffect:setVisible(false)
        if self.curr.diff == 1 then
            self.sliverBox:loadTextureNormal(self.boxTexture.easy_sliver_box)
        elseif self.curr.diff == 2 then
            self.sliverBox:loadTextureNormal(self.boxTexture.hard_sliver_box)
        end
    elseif self.curr.sliver == 1 then
        -- self.sliverboxEffect:stopAllActions()
        self.sliverboxEffect:setVisible(true)
            -- local rep = cc.RepeatForever:create(cc.RotateBy:create(3.0, 360))
            -- self.sliverboxEffect:runAction(rep)

        if self.curr.diff == 1 then
            self.sliverBox:loadTextureNormal(self.boxTexture.easy_sliver_box)
        elseif self.curr.diff == 2 then
            self.sliverBox:loadTextureNormal(self.boxTexture.hard_sliver_box)
        end
       
    elseif self.curr.sliver == 2 then
        -- self.sliverboxEffect:stopAllActions()
        self.sliverboxEffect:setVisible(false)
        if self.curr.diff == 1 then
            self.sliverBox:loadTextureNormal(self.boxTexture.easy_sliver_opened_box)
        elseif self.curr.diff == 2 then
            self.sliverBox:loadTextureNormal(self.boxTexture.hard_sliver_opened_box)
        end
    end 

end


function MapInstanceLayer:showAwardInfo( awardtype, awardstatue, callback )

    -- awardtype : 1 -- gold, 2 -- sliver

    local dropgroup = {}
    local dropsdata = {}
    local groupid = nil
    local getaward = nil
    if awardtype == 1 then
        -- S 级通关
        if self.curr.diff == 1 then
            -- 普通 S 级通关
            groupid = BaseConfig.GetInstanceChapter(self.curr.chapterid).PassAward[2]
            getaward = 2
        elseif self.curr.diff == 2 then
            -- 困难 S 级通关
            groupid = BaseConfig.GetInstanceChapter(self.curr.chapterid).PassAward[4]
            getaward = 4

        end
    elseif awardtype == 2 then
        -- 通关
        if self.curr.diff == 1 then
            -- 普通 通关
            groupid = BaseConfig.GetInstanceChapter(self.curr.chapterid).PassAward[1]
            getaward = 1

        elseif self.curr.diff == 2 then
            -- 困难 通关
            groupid = BaseConfig.GetInstanceChapter(self.curr.chapterid).PassAward[3]
            getaward = 3

        end        
    end

    dropgroup = BaseConfig.GetDrops(groupid)

    local scene = cc.Director:getInstance():getRunningScene()
    local panel = cc.Layer:create()
    scene:addChild(panel)

    local goodsTotal = (#dropgroup)
    local blackBgHeight = math.ceil(goodsTotal / 5) * 100

    local bgLayer = cc.LayerColor:create(cc.c4b(0,0,0,200), SCREEN_WIDTH, SCREEN_HEIGHT)
    panel:addChild(bgLayer)

    local bg = cc.Sprite:create("image/ui/img/bg/bg_189.png")
    bg:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)
    panel:addChild(bg)
    local bgsize = bg:getContentSize()

    local blackBg = cc.Scale9Sprite:create("image/ui/img/bg/bg_190.png")
    local blackBgSize = cc.size(bgsize.width * 0.9, blackBgHeight)  
    blackBg:setContentSize(blackBgSize)
    if goodsTotal > 5 then
        blackBg:setPosition(bgsize.width * 0.5, bgsize.height * 0.52)
    else
        blackBg:setPosition(bgsize.width * 0.5, bgsize.height * 0.5)
    end
    bg:addChild(blackBg)

    local tishiBg = cc.Sprite:create("image/ui/img/btn/btn_816.png")
    tishiBg:setPosition(bgsize.width * 0.52, bgsize.height * 0.9)
    bg:addChild(tishiBg)

    local function onTouchBegan(touch, event)
        return true
    end

    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
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
    
    local itemWidth = 60
    local initWidth = bgsize.width * 0.5 - itemWidth * (goodsTotal - 1)
    for k,v in pairs(dropgroup) do
        dropsdata = {}
        dropsdata.ID = v.dropID 
        dropsdata.Type = v.dropType 
        dropsdata.Num = v.num
        if goodsTotal > 5 then
            local goodsItem = Common.getGoods(dropsdata, false, BaseConfig.GOODS_MIDDLETYPE)
            goodsItem:setPosition(bgsize.width * 0.14 + ((k - 1)%5) * itemWidth * 2, bgsize.height * 0.64 - math.floor((k - 1) / 5) * 95)
            bg:addChild(goodsItem)
            goodsItem:setScale(0)
            local scale1 = cc.ScaleTo:create(0.08, 1.2)
            local scale2 = cc.ScaleTo:create(0.05, 1)
            local delay = cc.DelayTime:create((k - 1) * 0.1)
            goodsItem:runAction(cc.Sequence:create(delay, scale1, scale2))
        else
            local goodsItem = Common.getGoods(dropsdata, false, BaseConfig.GOODS_MIDDLETYPE)
            goodsItem:setPosition(initWidth + (k - 1) * itemWidth * 2, bgsize.height * 0.5)
            bg:addChild(goodsItem)
            if goodsTotal > 1 then
                goodsItem:setPosition(initWidth, bgsize.height * 0.5)
                local delayTime = 0.2 + (k - 1) * 0.1
                local moveTime = 0.2
                local delay = cc.DelayTime:create(delayTime)
                local move = cc.EaseBounceOut:create(cc.MoveTo:create(moveTime, cc.p(initWidth + (k - 1) * itemWidth * 2, bgsize.height * 0.5)))
                local sequence = cc.Sequence:create(delay, move)
                goodsItem:runAction(sequence)
            end 
        end
    end
    

    if awardstatue == 0 then    -- 不可领取
        local btn_lingqu = ccui.MixButton:create("image/ui/img/btn/btn_593.png")
        btn_lingqu:setPosition(bgsize.width*0.5, bgsize.height*0.2)
        btn_lingqu:setStateEnabled(false)
        btn_lingqu:setTitle("未通关", 30,cc.c3b(255,231,148) )
        bg:addChild(btn_lingqu)

    elseif awardstatue == 1 then    -- 领取

        local btn_lingqu = ccui.MixButton:create("image/ui/img/btn/btn_593.png")
        btn_lingqu:setPosition(bgsize.width*0.5, bgsize.height*0.2)
        btn_lingqu:setTitle("领取", 30,cc.c3b(255,231,148) )
        bg:addChild(btn_lingqu)
        btn_lingqu:addTouchEventListener(function ( sender, eventType )
            if eventType == ccui.TouchEventType.ended then
                rpc:call("Instance.OpenChest", {ChapterID = self.curr.chapterid, Type = getaward-1}, function ( event )
                  if event.status == Exceptions.Nil and event.result ~= nil then

                        Common.playSound("audio/effect/award.mp3")
                        for k,v in pairs(event.result) do
                            Common.getGoods(v, true, BaseConfig.GOODS_MIDDLETYPE)
                        end

                        btn_lingqu:setStateEnabled(false)
                        btn_lingqu:setTitle("已领取", 30,cc.c3b(255,231,148) )

                        if getaward == 1 then
                            GameCache.InstChapter[self.curr.chapterid].EasyStatus = 2
                        elseif getaward == 2 then
                            GameCache.InstChapter[self.curr.chapterid].EasySStatus = 2 
        
                        elseif getaward == 3 then
                            GameCache.InstChapter[self.curr.chapterid].HardStatus = 2
        
                        elseif getaward == 4 then
                            GameCache.InstChapter[self.curr.chapterid].HardSStatus = 2
        
                        end

                        if callback then
                            callback()
                        end

                        self:updateAwardBoxDisplay()  
                        panel:removeFromParent()
                        panel = nil
                    end
                    
                end)                
            end
        end)

    elseif awardstatue == 2 then    -- 已领取

        local btn_lingqu = ccui.MixButton:create("image/ui/img/btn/btn_593.png")
        btn_lingqu:setPosition(bgsize.width*0.5, bgsize.height*0.2)
        btn_lingqu:setStateEnabled(false)
        btn_lingqu:setTitle("已领取", 30,cc.c3b(255,231,148) )
        bg:addChild(btn_lingqu)

        -- local icon = Common.finalFont("已领取", bgsize.width*0.5, bgsize.height*0.2,50, cc.c3b(255,231,148), 2)
        -- bg:addChild(icon)
    end
end

function MapInstanceLayer:showFinishLevelBox( chapterid, diff, goldstatus, sliverstatus )
    local layer = cc.LayerColor:create(cc.c4b(0,0,0,100), SCREEN_WIDTH, SCREEN_HEIGHT)

    local bg = cc.Sprite:create("image/ui/img/bg/bg_189.png")
    bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    layer:addChild(bg)

    local bgsize = bg:getContentSize()

    local gongxi = cc.Sprite:create("image/ui/img/btn/btn_873.png")
    gongxi:setPosition(bgsize.width*0.5, bgsize.height-50)
    bg:addChild(gongxi)

    local bg2size = cc.size(605,200)
    local bg2 = cc.Scale9Sprite:create("image/ui/img/bg/bg_261.png")
    bg2:setContentSize(bg2size)
    bg2:setPosition(bgsize.width*0.5, bgsize.height*0.4)
    bg:addChild(bg2)

    local nandu = {"普通", "困难"}
    local colorLabel = require("tool.helper.ColorLabel")
    local label = colorLabel.new("[255,255,255]第[=][84,255,0]"..chapterid.."[=][255,255,255]季[=][84,255,0]"..nandu[diff].."[=][255,255,255]难度成功通关，点击领取通关宝箱[=]", 24, nil, true)
    label:setPosition(bgsize.width*0.5, bgsize.height*0.7)
    bg:addChild(label)

    local sliverBox = ccui.MixButton:create()
    sliverBox:setPosition(bg2size.width*0.3, bg2size.height*0.5)
    bg2:addChild(sliverBox)   

    local goldBox = ccui.MixButton:create()
    goldBox:setPosition(bg2size.width*0.7, bg2size.height*0.5)
    bg2:addChild(goldBox)  

    local slivereffect = EffectManager:CreateAnimation(bg2, bg2size.width*0.3, bg2size.height*0.5, nil, 38, true)
    slivereffect:setVisible(false)
    local goldeffect = EffectManager:CreateAnimation(bg2, bg2size.width*0.7, bg2size.height*0.5, nil, 38, true)
     goldeffect:setVisible(false)     

 
    sliverBox:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            self:showAwardInfo(2, sliverstatus, function (  )
                slivereffect:removeFromParent()
                sliverstatus = 2
                if diff  == 1 then
                    sliverBox:loadTextureNormal(self.boxTexture.easy_sliver_opened_box)
                elseif diff == 2 then
                    sliverBox:loadTextureNormal(self.boxTexture.hard_sliver_opened_box)
                end
                
            end)
        end
    end)   
  
    goldBox:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            self:showAwardInfo(1, goldstatus, function (  )
                goldeffect:removeFromParent()
                goldstatus = 2
                if diff  == 1 then
                    goldBox:loadTextureNormal(self.boxTexture.easy_gold_opened_box)
                elseif diff == 2 then
                    goldBox:loadTextureNormal(self.boxTexture.hard_gold_opened_box)
                end
            end)
        end
    end)

 
    if diff == 1 then
        if goldstatus == 0 then
            goldBox:loadTextureNormal(self.boxTexture.easy_gold_box)
        elseif goldstatus == 1 then
            goldBox:loadTextureNormal(self.boxTexture.easy_gold_box)
            goldeffect:setVisible(true)
            -- local repAction = cc.RepeatForever:create(cc.RotateBy:create(3.0, 360))
            -- goldeffect:runAction(repAction)
        elseif goldstatus == 2 then
            goldBox:loadTextureNormal(self.boxTexture.easy_gold_opened_box)
        end

        if sliverstatus == 0 then
            sliverBox:loadTextureNormal(self.boxTexture.easy_sliver_box)
        elseif sliverstatus == 1 then
            sliverBox:loadTextureNormal(self.boxTexture.easy_sliver_box)
            slivereffect:setVisible(true)
            -- local repAction = cc.RepeatForever:create(cc.RotateBy:create(3.0, 360))
            -- slivereffect:runAction(repAction)
        elseif sliverstatus == 2 then
            sliverBox:loadTextureNormal(self.boxTexture.easy_sliver_opened_box)
        end


    elseif diff == 2 then
        if goldstatus == 0 then
            goldBox:loadTextureNormal(self.boxTexture.hard_gold_box)
        elseif goldstatus == 1 then
            goldBox:loadTextureNormal(self.boxTexture.hard_gold_box)
            goldeffect:setVisible(true)
            -- local repAction = cc.RepeatForever:create(cc.RotateBy:create(3.0, 360))
            -- goldeffect:runAction(repAction)
        elseif goldstatus == 2 then
            goldBox:loadTextureNormal(self.boxTexture.hard_gold_opened_box)
        end

        if sliverstatus == 0 then
            sliverBox:loadTextureNormal(self.boxTexture.hard_sliver_box)
        elseif sliverstatus == 1 then
            sliverBox:loadTextureNormal(self.boxTexture.hard_sliver_box)
            slivereffect:setVisible(true)
            -- local repAction = cc.RepeatForever:create(cc.RotateBy:create(3.0, 360))
            -- slivereffect:runAction(repAction)
        elseif sliverstatus == 2 then
            sliverBox:loadTextureNormal(self.boxTexture.hard_sliver_opened_box)
        end  

    end


    local function onTouchBegan(touch, event)
        return true
    end

    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = bg:convertToNodeSpace(touch:getLocation())
        local s = bg:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if not cc.rectContainsPoint(rect, locationInNode) then
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

    return layer
end


function MapInstanceLayer:battleWin( result, heroDamage, enemyDamage )
    Common.playSound("audio/effect/map_battle_win.mp3")

  
    local nextEasyNodeID = result.NextEasyNode 
    local nextHardNodeID = result.NextHardNode 
    local chestStatus = result.ChapterChest
    local score = result.Score
    local rating = Common.calculateRating(score)
    local exp = result.Exp
    local coin = result.Coin
    local drops = result.AwardList
    local herolist_exp = result.HeroExpList
    local isLastNode = result.IsCurLastNode

    local cid = self.curr.chapterid
    local nid = self.curr.nodeid 
    local diff = self.curr.diff

    local function updateGameDate()
        -- 更新关卡数据

        -- 更新当前节点分数和评级
        -- print(cid, nid, diff, score)
        if GameCache.InstNode[nid..","..diff].Score < score then
            GameCache.InstNode[nid..","..diff].Score = score
        end

        local rating = Common.calculateRating(GameCache.InstNode[nid..","..diff].Score)

        GameCache.InstNode[nid..","..diff].Rating = rating

        if BaseConfig.GetInstanceNode(nid, diff).ChallengeCount >= 0 then
            GameCache.InstNode[nid..","..diff].Count = GameCache.InstNode[nid..","..diff].Count + 1
        end

        -- 更新当前章节宝箱状态
        GameCache.InstChapter[cid].EasyStatus = chestStatus[1]
        GameCache.InstChapter[cid].EasySStatus = chestStatus[2]
        GameCache.InstChapter[cid].HardStatus = chestStatus[3]
        GameCache.InstChapter[cid].HardSStatus = chestStatus[4]

        -- 更新最新进度
        if GameCache.InstProgress[1] < nextEasyNodeID  then   -- 解锁新节点
            GameCache.InstProgress[1] = nextEasyNodeID
            GameCache.InstNode[nextEasyNodeID..",1"] = {}
            GameCache.InstNode[nextEasyNodeID..",1"].NodeUnlock = true
            GameCache.InstNode[nextEasyNodeID..",1"].Rating = 0
            GameCache.InstNode[nextEasyNodeID..",1"].Score = 0
            GameCache.InstNode[nextEasyNodeID..",1"].Count = 0
            GameCache.InstNode[nextEasyNodeID..",1"].ResetCount = 0

            local offset = self.easytableview:getContentOffset()
            self.easytableview:reloadData()
            self.easytableview:setContentOffset(offset)


            local tempcid = BaseConfig.GetInstanceNode(nextEasyNodeID, 1).ChapterID

            if self.progress[1] < tempcid then   -- 开启新章
                self.progress[1] = tempcid
                    -- 更新下一章宝箱信息
                GameCache.InstChapter[tempcid] = GameCache.InstChapter[tempcid] or {}
                GameCache.InstChapter[tempcid].EasySStatus = GameCache.InstChapter[tempcid].EasySStatus or 0
                GameCache.InstChapter[tempcid].EasyStatus = GameCache.InstChapter[tempcid].EasyStatus or 0
                GameCache.InstChapter[tempcid].HardSStatus = GameCache.InstChapter[tempcid].HardSStatus or 0
                GameCache.InstChapter[tempcid].HardStatus = GameCache.InstChapter[tempcid].HardStatus or 0
                
            end


        end
    
        if GameCache.InstProgress[2] < nextHardNodeID  then   -- 解锁新节点
            GameCache.InstProgress[2] = nextHardNodeID
            GameCache.InstNode[nextHardNodeID..",2"] = {}
            GameCache.InstNode[nextHardNodeID..",2"].NodeUnlock = true
            GameCache.InstNode[nextHardNodeID..",2"].Rating = 0
            GameCache.InstNode[nextHardNodeID..",2"].Score = 0
            GameCache.InstNode[nextHardNodeID..",2"].Count = 0
            GameCache.InstNode[nextHardNodeID..",2"].ResetCount = 0

            local offset = self.hardtableview:getContentOffset()
            self.hardtableview:reloadData()
            self.hardtableview:setContentOffset(offset)


            local tempcid = BaseConfig.GetInstanceNode(nextHardNodeID, 2).ChapterID

            if self.progress[2] < tempcid then   -- 开启新章
                self.progress[2] = tempcid
                    -- 更新下一章宝箱信息
                GameCache.InstChapter[tempcid] = GameCache.InstChapter[tempcid] or {}
                GameCache.InstChapter[tempcid].EasySStatus = GameCache.InstChapter[tempcid].EasySStatus or 0
                GameCache.InstChapter[tempcid].EasyStatus = GameCache.InstChapter[tempcid].EasyStatus or 0
                GameCache.InstChapter[tempcid].HardSStatus = GameCache.InstChapter[tempcid].HardSStatus or 0
                GameCache.InstChapter[tempcid].HardStatus = GameCache.InstChapter[tempcid].HardStatus or 0
                
            end
        end


        -- 更新玩家数据（物品，经验的获取）
        
        for i=1,#drops do
            Common.getGoods(drops[i],true)   -- 物品加入包裹
        end 

        for i=1, #herolist_exp do            -- 星将经验 
            local id = herolist_exp[i].ID
            local prev_level = herolist_exp[i].PrevLevel
            local prev_exp = herolist_exp[i].PrevExp
            local curr_level = herolist_exp[i].Level
            local curr_exp = herolist_exp[i].Exp
            if prev_level < curr_level then
                GameCache.AllHero[id].Exp = curr_exp 
                GameCache.AllHero[id].Level = curr_level
            else
                GameCache.AllHero[id].Exp = curr_exp 
            end
        end
    end

    updateGameDate()


    local scene = cc.Director:getInstance():getRunningScene()

    local MapBattleWinLayer = class("MapBattleWinLayer", function (  )
        local winlayer = cc.Layer:create()
        local function onNodeEvent(event)
            if event == "enterTransitionFinish" then
                if GameCache.NewbieGuide.Step < 12 then
                    application:dispatchCustomEvent(AppEvent.UI.NewbieGuide.CreateGuide, {page = self.__cname})
                    Common.OpenGuideLayer({1,2,3})
                end

            end
        end
        winlayer:registerScriptHandler(onNodeEvent)

        return winlayer
    end).new()

    scene:addChild(MapBattleWinLayer)


    
    local layer = cc.LayerColor:create(cc.c4b(0,0,0,180))
    MapBattleWinLayer:addChild(layer)

    local light = cc.Sprite:create("image/ui/img/btn/btn_343.png")
    light:setPosition(SCREEN_WIDTH*0.4, 500)
    layer:addChild(light)
    -- light:setVisible(false)
    local rep = cc.RepeatForever:create(cc.RotateBy:create(3.0, 360))
    light:runAction(rep)
    -- light:runAction(cc.Sequence:create( cc.DelayTime:create(0.15), cc.Show:create(),  rep))

    -- 评级放最上面

    local jian1 = cc.Sprite:create("image/ui/img/btn/btn_1328.png")
    jian1:setPosition(SCREEN_WIDTH*0.4+100, 450)
    layer:addChild(jian1)
    jian1:setOpacity(0)
    jian1:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.FadeIn:create(0.1), cc.MoveBy:create(0.05, cc.p(-90,-50)), cc.MoveBy:create(0.3, cc.p(0,80))))

    local jian2 = cc.Sprite:create("image/ui/img/btn/btn_1328.png")
    jian2:setPosition(SCREEN_WIDTH*0.4-100, 450)
    jian2:setFlippedX(true)
    layer:addChild(jian2)
    jian2:setOpacity(0)
    jian2:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.FadeIn:create(0.12), cc.MoveBy:create(0.03, cc.p(90,-50)), cc.MoveBy:create(0.3, cc.p(0,80))))


    local yuanpan = cc.Sprite:create("image/ui/img/btn/btn_1327.png")
    yuanpan:setPosition(SCREEN_WIDTH*0.4, 400)
    layer:addChild(yuanpan)
    yuanpan:setScale(1.5)
    yuanpan:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1), cc.DelayTime:create(0.2), cc.MoveBy:create(0.3, cc.p(0,80))))

    local yuanpan_size = yuanpan:getContentSize()

    local sidai = cc.Sprite:create("image/ui/img/btn/btn_1325.png")
    sidai:setPosition(yuanpan_size.width*0.5, 60)
    yuanpan:addChild(sidai)
    sidai:setVisible(false)
    sidai:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.Show:create()))

    local icon = cc.Sprite:create("image/ui/img/btn/btn_632.png")
    icon:setPosition(yuanpan_size.width*0.5, 100)
    yuanpan:addChild(icon)
    icon:setVisible(false)
    icon:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.Show:create()))

    local layer_event = cc.CallFunc:create(function ( )    
     
        -- local scene = cc.Director:getInstance():getRunningScene()
        -- scene:runAction(cc.Shake:create(0.1, 10))
    end)

    local fenbg = cc.Sprite:create("image/ui/img/bg/bg_162.png")
    fenbg:setPosition(SCREEN_WIDTH*0.8, 480)
    layer:addChild(fenbg)
    fenbg:setScale(3)
    fenbg:setVisible(false)
    local action = cc.Sequence:create({ cc.DelayTime:create(1), cc.Show:create(), cc.ScaleTo:create(0.1, 0.8),cc.ScaleTo:create(0.05, 1.0), layer_event})
    fenbg:runAction(action)

    local fenbgsize = fenbg:getContentSize()

    -- local fen_sprite = cc.Sprite:create("image/ui/img/btn/btn_626.png")
    -- fen_sprite:setPosition(fenbgsize.width*0.5, fenbgsize.height*0.2)
    -- fenbg:addChild(fen_sprite)

    local label_fenshu = cc.Label:createWithCharMap("image/ui/img/btn/btn_627.png",44,52,string.byte("0"))
    label_fenshu:setString(""..score)
    label_fenshu:setScale(0.5)
    label_fenshu:setPosition(fenbgsize.width*0.5, fenbgsize.height*0.2)
    label_fenshu:setAdditionalKerning(-9)
    fenbg:addChild(label_fenshu)


    local rating = cc.Sprite:create(self.ratingTexture1[rating])
    rating:setPosition(fenbgsize.width*0.5, fenbgsize.height*0.9)
    rating:setScale(0.8)
    fenbg:addChild(rating)

     -- 背景   
    local bgsize = cc.size(930,360)
    local bg = ccui.ImageView:create("image/ui/img/bg/bg_163.png")
    bg:setScale9Enabled(true)
    bg:setContentSize(bgsize)
    bg:setAnchorPoint(0,0)
    bg:setPosition(0, 50)
    layer:addChild(bg)
    bg:setOpacity(0)
    bg:runAction(cc.Sequence:create( cc.DelayTime:create(1), cc.FadeIn:create(0.5), cc.CallFunc:create(function (  )

        local blankbg = cc.LayerColor:create(cc.c4b(0,0,0,0), bgsize.width, bgsize.height)
        blankbg:setPosition(-bgsize.width,50)
        layer:addChild(blankbg)
        blankbg:runAction(cc.MoveTo:create(0.3, cc.p(0,50)))

        local function hero_exp( id, prev_level, prev_exp, curr_level, curr_exp )

            local ico = GoodsInfoNode.new(BaseConfig.GOODS_HERO, {ID = id, StarLevel = GameCache.GetHero(id).StarLevel}, BaseConfig.GOODS_MIDDLETYPE)
            ico:setTouchEnable(false)
            ico:setLevel("center", curr_level)

            local iconsize = ico:getContentSize()

            local back = cc.Sprite:create("image/ui/img/btn/btn_1275.png")
            back:setPosition(0, -(iconsize.height*0.5+10))
            ico:addChild(back)

            local talent = BaseConfig.GetHero(id, 0).talent
            local total_exp = BaseConfig.GetHeroUpgradeExp(talent, curr_level)
        
            local expbar = ccui.LoadingBar:create("image/ui/img/btn/btn_1276.png")
            expbar:setPosition(0, -(iconsize.height*0.5+10))
            ico:addChild(expbar)

            local curr_percent = curr_exp / BaseConfig.GetHeroUpgradeExp(talent, curr_level) * 100

            if prev_level < curr_level then
                --升级的经验条动画 按百分比变化
                
                local exp = BaseConfig.GetHeroUpgradeExp(talent, prev_level)
                local offx = 100
                local x = math.floor(prev_exp / exp * 100) - 100

                expbar:setPercent(math.floor(prev_exp / exp*100))

                local function update(  )
                    
                    if x == 0 then
                        offx = 0
                    end
                    if x > curr_percent then
                        ico:unscheduleUpdate()
                        return
                    end
                    x = x + 1
                    expbar:setPercent(x+offx)
                end

                ico:runAction(cc.Sequence:create( cc.DelayTime:create(0.5), cc.CallFunc:create(function (  )
                    ico:scheduleUpdateWithPriorityLua(update, 0)
                end) ))  

            else
                local x = prev_exp/total_exp*100

                local function update(  )
                    
                    if x > curr_percent then
                        ico:unscheduleUpdate()
                        return
                    end
                    x = x + 1
                    expbar:setPercent(x)
                end

                ico:runAction(cc.Sequence:create( cc.DelayTime:create(0.5), cc.CallFunc:create(function (  )
                    ico:scheduleUpdateWithPriorityLua(update, 0)
                end) )) 

            end


            if prev_level < curr_level then
                -- 升级了

                local label = Common.systemFont("升级了!",  0, -(iconsize.height*0.5+40), 18, cc.c3b(10,255,17))
                ico:addChild(label)
                local  go = cc.MoveBy:create(0.15, cc.p(0,15) )
                local go1 = cc.MoveBy:create(0.15, cc.p(0,15) )
                local  goBack = go:reverse()
                local goBack1 = go1:reverse()
                local  seq = cc.Sequence:create( go, goBack, go1, goBack1)
                label:runAction( seq)

                local effect = EffectManager:CreateAnimation(ico, 0, 0, nil, 20, false)
                effect:setTimeScale(0.8)

            else
                local add_exp = curr_exp - prev_exp
                local label = Common.systemFont("经验+"..add_exp,  0, -(iconsize.height*0.5+30), 16, cc.c3b(234,255,171))
                ico:addChild(label)    

            end
            
            return ico
        end

        local offx = SCREEN_WIDTH*0.4 - (#herolist_exp-1)*60
        for i=1, #herolist_exp do
            local sprite = hero_exp(herolist_exp[i].ID, herolist_exp[i].PrevLevel, herolist_exp[i].PrevExp, herolist_exp[i].Level, herolist_exp[i].Exp)
            sprite:setPosition(offx+(i-1)*120, 210)
            blankbg:addChild(sprite)

        end

        local function droplist( items)
            
            local function cellSizeForTable( table, idx )
                return 60, 75
            end
        
            local function tableCellAtIndex( table, idx )
                local cell = cc.TableViewCell:new()
        
                local drop = Common.getGoods(items[idx+1],false,BaseConfig.GOODS_SMALLTYPE)
                drop:setPosition(35, 30)

        
                cell:addChild(drop)
        
                return cell
            end
        
            local function numberOfCellsInTableView(table)
                return #items
            end
            local width = #items * 73
            if width > 580 then
                width = 580
            end
            local tableView = cc.TableView:create(cc.size(width, 80))
            tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
            -- tableView:setPosition(cc.p(SCREEN_WIDTH*0.1+offsetX, SCREEN_HEIGHT*0.35))
            tableView:setDelegate()

            tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
            tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
            tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
            tableView:reloadData()
            
            return tableView
        
        end


        local dropListTableView = droplist(drops)    -- 展示掉落
        dropListTableView:setPosition(SCREEN_WIDTH*0.4-dropListTableView:getContentSize().width*0.5, 25)
        blankbg:addChild(dropListTableView)



    end) ))


    -- local bgsize = bg:getContentSize()

    local function createMoreLayer(  )
        local panelsize = cc.size(666,538)
        local panel = ccui.ImageView:create("image/ui/img/bg/bg_139.png")
        panel:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)
        panel:setScale9Enabled(true)
        panel:setContentSize(panelsize)
        scene:addChild(panel)

        local top = cc.Sprite:create("image/ui/img/bg/bg_259.png")
        top:setAnchorPoint(0.5,1)
        top:setPosition(panelsize.width*0.5, panelsize.height-15)
        panel:addChild(top)

        local bg = cc.Sprite:create("image/ui/img/bg/bg_260.png")
        bg:setAnchorPoint(0.5,0)
        bg:setPosition(panelsize.width*0.5, 20)
        panel:addChild(bg)

        local bgsize  = bg:getContentSize()


        local function onTouchBegan(touch, event)
            return true
        end
        local function onTouchEnded(touch, event)
            local target = event:getCurrentTarget()
            local locationInNode = target:convertToNodeSpace(touch:getLocation())
            local s = target:getContentSize()
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


        local label = Common.finalFont("我方输出", panelsize.width*0.3, panelsize.height-45 , 24)
        panel:addChild(label)

        local s = cc.Sprite:create("image/ui/img/btn/btn_670.png")
        s:setPosition(panelsize.width*0.5, panelsize.height-45)
        panel:addChild(s)

        label = Common.finalFont("敌方输出", panelsize.width*0.7, panelsize.height-45 , 24)
        panel:addChild(label)

        local heroDamageMax = 0
        for _, hd in ipairs(heroDamage) do
            local k = hd.heroID
            local v = hd.damage

            if v > heroDamageMax then
                heroDamageMax = v
            end
        end

        local enemyDamageMax = 0
        for _, hd in ipairs(enemyDamage) do
            local k = hd.heroID
            local v = hd.damage
            if v > enemyDamageMax then
                enemyDamageMax = v
            end
        end

        local total_hang = #enemyDamage
        if total_hang < #heroDamage then
            total_hang = #heroDamage
        end

        local scrollview_size = cc.size(bgsize.width, total_hang*85)
        if scrollview_size.height < 430 then
            scrollview_size.height = 430
        end

        local scrollview = ccui.ScrollView:create()
        scrollview:setTouchEnabled(true)
        scrollview:setContentSize(cc.size(bgsize.width, bgsize.height-20))    
        scrollview:setDirection(ccui.ScrollViewDir.vertical)
        scrollview:setInnerContainerSize(scrollview_size)    
        scrollview:setPosition(0,20)
        bg:addChild(scrollview)

        -- dump(heroDamage)

        local i = 0
        for _, hd in pairs(heroDamage) do
            local k = hd.heroID
            local v = hd.damage

            local hero = GameCache.GetHero(k)
            if hero then
                local ico = GoodsInfoNode.new(BaseConfig.GOODS_HERO, {ID = k, StarLevel = hero.StarLevel}, BaseConfig.GOODS_SMALLTYPE)
                ico:setPosition(scrollview_size.width * 0.07, scrollview_size.height-50-(i*85))
                ico:setTouchEnable(false)
                scrollview:addChild(ico)

                local back = cc.Sprite:create("image/ui/img/btn/btn_998.png")
                back:setPosition(150, -15)
                ico:addChild(back)
            
                local damagebar = ccui.LoadingBar:create("image/ui/img/btn/btn_997.png")
                damagebar:setPosition(150,-15)
                damagebar:setPercent(v / heroDamageMax * 100)
                ico:addChild(damagebar)
                
                local label = Common.finalFont(v.."",  150,10, 22, cc.c3b(234,255,171))
                ico:addChild(label)
            else
                local monster = BaseConfig.GetMonster(k)
                local res = monster.Res
                -- local id = string.sub(monster.Res, 4, -1)            
                -- local ico = GoodsInfoNode.new(BaseConfig.GOODS_HERO, {ID = id}, BaseConfig.GOODS_SMALLTYPE)
                local ico = cc.Sprite:create("image/icon/head/"..res..".png")
                ico:setScale(0.6)
                -- ico:setTouchEnable(false)
                ico:setPosition(scrollview_size.width * 0.07, scrollview_size.height-50-(i*85))
                scrollview:addChild(ico)

                local border = cc.Sprite:create()
                ico:addChild(border)
                border:setPosition(ico:getContentSize().width*0.5, ico:getContentSize().height*0.5)
                border:setTexture("image/icon/border/border_star_3.png")

                local back = cc.Sprite:create("image/ui/img/btn/btn_998.png")
                back:setPosition(150 + scrollview_size.width * 0.07, scrollview_size.height-50-(i*85)-15)
                scrollview:addChild(back)
            
                local damagebar = ccui.LoadingBar:create("image/ui/img/btn/btn_997.png")
                damagebar:setPosition(150 + scrollview_size.width * 0.07, scrollview_size.height-50-(i*85)-15)
                damagebar:setPercent(v / heroDamageMax * 100)
                damagebar:setDirection(ccui.LoadingBarDirection.RIGHT)
                scrollview:addChild(damagebar)

                local label = Common.finalFont(v.."",  150, scrollview_size.height-50-(i*85)+10, 22, cc.c3b(234,255,171))
                scrollview:addChild(label)
            end

            i = i + 1
        end

        local j = 0
        for _, hd in pairs(enemyDamage) do
            local k = hd.heroID
            local v = hd.damage
            local monster = BaseConfig.GetMonster(k)
            local res = monster.Res
            -- local id = string.sub(monster.Res, 4, -1)            
            -- local ico = GoodsInfoNode.new(BaseConfig.GOODS_HERO, {ID = id}, BaseConfig.GOODS_SMALLTYPE)
            local ico = cc.Sprite:create("image/icon/head/"..res..".png")
            ico:setScale(0.6)
            -- ico:setTouchEnable(false)
            ico:setPosition(scrollview_size.width * 0.93, scrollview_size.height-50-(j*85))
            scrollview:addChild(ico)

            local border = cc.Sprite:create()
            ico:addChild(border)
            border:setPosition(ico:getContentSize().width*0.5, ico:getContentSize().height*0.5)
            if monster.IsBoss == 1 then
                border:setTexture("image/icon/border/border_star_5.png")
            else
                border:setTexture("image/icon/border/border_star_3.png")
            end

            local back = cc.Sprite:create("image/ui/img/btn/btn_998.png")
            back:setPosition(scrollview_size.width * 0.93-150, scrollview_size.height-50-(j*85)-15)
            scrollview:addChild(back)
        
            local damagebar = ccui.LoadingBar:create("image/ui/img/btn/btn_997.png")
            damagebar:setPosition(scrollview_size.width * 0.93-150, scrollview_size.height-50-(j*85)-15)
            damagebar:setPercent(v / enemyDamageMax * 100)
            damagebar:setDirection(ccui.LoadingBarDirection.RIGHT)
            scrollview:addChild(damagebar)

            local label = Common.finalFont(v.."",  scrollview_size.width * 0.93-150, scrollview_size.height-50-(j*85)+10, 22, cc.c3b(234,255,171))
            scrollview:addChild(label)

            j = j + 1
        end


    end

    local btn_more = createMixScale9Sprite("image/ui/img/btn/btn_610.png", nil, "image/ui/img/btn/btn_625.png", cc.size(110,55))
    btn_more:setPosition(SCREEN_WIDTH*0.8, SCREEN_HEIGHT*0.58)
    btn_more:setCircleFont("统计" , 1,1, 26, cc.c3b(255,231,148), 1, cc.c4b(65,26,1,255))
    btn_more:setChildPos(0.2,0.5)
    btn_more:setFontPos(0.6, 0.5)
    btn_more:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            createMoreLayer()
        end
    end)
    layer:addChild(btn_more)

    local size = cc.size(360,60)
    local iconbg = ccui.ImageView:create("image/ui/img/bg/bg_161.png")
    -- iconbg:setAnchorPoint(0.5,0)
    iconbg:setScale9Enabled(true)
    iconbg:setContentSize(size)
    iconbg:setPosition(SCREEN_WIDTH*0.4, bgsize.height)
    iconbg:setVisible(false)
    bg:addChild(iconbg)

    local action = cc.Sequence:create( cc.DelayTime:create(1.2), cc.Show:create(), cc.MoveBy:create(0.15, cc.p(0,-50)), cc.MoveBy:create(0.05, cc.p(0,10)),  cc.MoveBy:create(0.05, cc.p(0,-5)) )
    iconbg:runAction(action)  

    local icon = cc.Sprite:create("image/ui/img/btn/btn_671.png")
    icon:setPosition(65, size.height*0.5)
    iconbg:addChild(icon)


    -- 经验
    local label = Common.finalFont("+"..exp, 135, size.height*0.5,22, nil, 1)
    iconbg:addChild(label)

    icon = cc.Sprite:create("image/ui/img/btn/btn_035.png")
    icon:setPosition(240, size.height*0.5)
    iconbg:addChild(icon)

    -- 银币
    label = Common.finalFont("+"..coin, 305, size.height*0.5,22, nil, 1)
    iconbg:addChild(label)


    local btnImage = "image/ui/img/btn/btn_553.png"

    local nextnodeid = 0
    local nextchapterid = cid

    if diff == 1 then
        nextnodeid = nextEasyNodeID
    elseif diff == 2 then
        nextnodeid = nextHardNodeID
    else
        return
    end

    if nextnodeid == 0 then
        -- 下场未解锁
        local btnBackToMap = ccui.MixButton:create(btnImage)
        btnBackToMap:setTitle("返回剧场" , 26, cc.c3b(226,204,169),1,cc.c4b(65,26,1,255))
        btnBackToMap:setPosition(SCREEN_WIDTH*0.8,SCREEN_HEIGHT*0.3)
        layer:addChild(btnBackToMap)
        btnBackToMap:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.began then
                Common.addTopSwallowLayer()
            end
            if eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
                Common.removeTopSwallowLayer()
            end
            if eventType == ccui.TouchEventType.ended then
                application:popScene()
                -- application:popScene()
            end
        end)

        if not isLastNode then
            local btnNextMap = ccui.MixButton:create(btnImage)
            btnNextMap:setTitle("下集未解锁", 26, cc.c3b(226,204,169),1,cc.c4b(65,26,1,255))
            btnNextMap:setPosition(SCREEN_WIDTH*0.8,SCREEN_HEIGHT*0.15)
            btnNextMap:setStateEnabled(false)
            layer:addChild(btnNextMap)
        else
            btnBackToMap:setPosition(SCREEN_WIDTH*0.8,SCREEN_HEIGHT*0.22)
        end

    else
        
        nextchapterid = BaseConfig.GetInstanceNode(nextnodeid, diff).ChapterID
        
        local btnBackToMap = ccui.MixButton:create(btnImage)
        btnBackToMap:setTitle("返回剧场" , 26, cc.c3b(226,204,169),1,cc.c4b(65,26,1,255))
        btnBackToMap:setPosition(SCREEN_WIDTH*0.8,SCREEN_HEIGHT*0.3)
        layer:addChild(btnBackToMap)
        btnBackToMap:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.began then
                Common.addTopSwallowLayer()
            end
            if eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
                Common.removeTopSwallowLayer()
            end
            if eventType == ccui.TouchEventType.ended then
                Common.CloseGuideLayer({3})
                application:popScene()
                -- application:popScene()
            end
        end)

        if nextchapterid == cid then
            -- 当前章 下一场

            local btnNextMap = ccui.MixButton:create(btnImage)
            btnNextMap:setTitle("下一集", 26, cc.c3b(226,204,169),1,cc.c4b(65,26,1,255))
            btnNextMap:setPosition(SCREEN_WIDTH*0.8,SCREEN_HEIGHT*0.15)
            layer:addChild(btnNextMap)
            btnNextMap:addTouchEventListener(function ( sender , eventType)
                if eventType == ccui.TouchEventType.began then
                    Common.addTopSwallowLayer()
                end
                if eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
                    Common.removeTopSwallowLayer()
                end
                if eventType == ccui.TouchEventType.ended and BaseConfig.isCanClick then
                    BaseConfig.isCanClick = false
                    Common.CloseGuideLayer({1,2})
                    Common.ResetGuideLayer({big = GameCache.NewbieGuide.Step, small = 2})
                    self.choiceNode[diff] = nextnodeid
                    self.curr.nodeid = self.choiceNode[diff]

                    local nextnode = BaseConfig.GetInstanceNode(nextnodeid, diff)
                    -- application:popScene()
                    -- application:popScene()
                    self:enterBattle(nextnode, true)
                    -- self:createBattltIntro(result.ChapterID, result.NodeID, result.Difficulty)
                end
            end)

        else
            -- 下一章已解锁
            
            local btnNextMap = ccui.MixButton:create(btnImage)
            btnNextMap:setTitle("下一季" ,26, cc.c3b(226,204,169),1,cc.c4b(65,26,1,255))
            btnNextMap:setPosition(SCREEN_WIDTH*0.8,SCREEN_HEIGHT*0.15)
            layer:addChild(btnNextMap)
            btnNextMap:addTouchEventListener(function ( sender, eventType )
                if eventType == ccui.TouchEventType.began then
                    Common.addTopSwallowLayer()
                end
                if eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
                    Common.removeTopSwallowLayer()
                end
                if eventType == ccui.TouchEventType.ended and BaseConfig.isCanClick then
                    BaseConfig.isCanClick = false
                    self.curr.chapterid = nextchapterid
                    self.choiceNode[diff] = nextnodeid
                    self.curr.nodeid = self.choiceNode[diff]
                    application:popScene()
                    -- application:popScene()
                end
            end)
        end
    end


    if diff == 1 then
        if GameCache.InstChapter[cid].EasyStatus == 1 or GameCache.InstChapter[cid].EasySStatus == 1 then
            scene:addChild(self:showFinishLevelBox( cid, diff, GameCache.InstChapter[cid].EasySStatus, GameCache.InstChapter[cid].EasyStatus ))
        end
    elseif diff == 2 then
        if GameCache.InstChapter[cid].HardStatus == 1 or GameCache.InstChapter[cid].HardSStatus == 1 then
            scene:addChild(self:showFinishLevelBox( cid, diff, GameCache.InstChapter[cid].HardSStatus, GameCache.InstChapter[cid].HardStatus ))
        end
    end

    if result.SpecialAwards and #result.SpecialAwards > 0 then
        local alertShow = require("scene.main.ReceiveGoods").new(result.SpecialAwards, "image/ui/img/btn/btn_815.png")
        scene:addChild(alertShow,2)    
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


function MapInstanceLayer:battleFail(  )
    
    local nextnode = BaseConfig.GetInstanceNode(self.curr.nodeid, self.curr.diff)

    local layer = require("tool.helper.CommonLayer").BattleFailLayer()
    
    local scene = cc.Director:getInstance():getRunningScene()
    scene:addChild(layer)

    local btnImage = "image/ui/img/btn/btn_553.png"
    local btnBackToMap = createMixSprite(btnImage)
    btnBackToMap:setCircleFont("返回地图" , 1 , 1, 26, cc.c3b(226,204,169))
    btnBackToMap:setFontOutline(cc.c4b(65,26,1,255), 1)
    btnBackToMap:setFontPos(0.5,0.5)
    -- btnBackToMap:setScale9Enabled(true)
    btnBackToMap:setPosition(SCREEN_WIDTH*0.85,SCREEN_HEIGHT*0.3)
    layer:addChild(btnBackToMap)
    btnBackToMap:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            -- application:popScene()
            application:popScene()
        end
    end)

    local btn_again = createMixSprite(btnImage)
    btn_again:setCircleFont("再次挑战" , 1 , 1, 26, cc.c3b(226,204,169))
    btn_again:setFontOutline(cc.c4b(65,26,1,255), 1)
    btn_again:setFontPos(0.5,0.5)
    -- btn_again:setScale9Enabled(true)
    btn_again:setPosition(SCREEN_WIDTH*0.85,SCREEN_HEIGHT*0.18)
    layer:addChild(btn_again)
    btn_again:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            -- application:popScene()
            -- application:popScene()

            self:enterBattle(nextnode, true)
        end
    end)

end

-- communicate with server

function MapInstanceLayer:battleResult( battleReply )

    local nid = self.curr.nodeid 
    local diff = self.curr.diff

    local sessionID = battleReply.sessionID
    local herolist = battleReply.HeroList
    local costtime = battleReply.CostTime
    local r = battleReply.result
    local iswin = false


    if r == "win" then
        iswin = true
    end


    rpc:call( "Instance.EndF", {SessionID = sessionID, IsWin = iswin, HeroList = herolist , CostTime = costtime, }, function ( event )
        -- dump(event.result)
        if event.status == Exceptions.Nil and event.result.Score > 0 then
            
            self:battleWin(event.result, battleReply.heroDamageStat, battleReply.enemyDamageStat)
            if GameCache.NewbieGuide.Step <= 3 then
                Common.SaveGuideLayer(  )
            end

        else
            self:battleFail()
        end
    end, {show=true, debug=true, retryOnError = true} )
end

return MapInstanceLayer