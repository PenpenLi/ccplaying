--
-- Author: keyring
-- Date: 2015-04-07 11:00:42
--
local CreateAvatarLayer = class("CreateAvatarLayer", BaseLayer)
local HeroManager = require("tool.helper.HeroAction")
local utf8 = require("tool.lib.utf8")
-- 未签到状态
local NOTCHECKSTATUS = 0

local INIT_HERO = 1027 -- 猪八戒

function CreateAvatarLayer:ctor(callback)
    self:createBackgroup()
    self:createFixedUI()
    self.callback = callback
    -- self:createFlexUI()

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

function CreateAvatarLayer:createBackgroup()
    local layer = cc.Layer:create()
    self:addChild(layer)

    -- local bg = load_animation("image/spine/ui_effect/45", 1)
    -- bg:setAnimation(0,"animation", true)
    local bg = cc.Sprite:create("image/ui/img/bg/qumingzi.jpg")
    bg:setAnchorPoint(0.5,0)

    bg:setPosition(SCREEN_WIDTH*0.5, 0)
    layer:addChild(bg)
end

function CreateAvatarLayer:onEnterTransitionFinish( ... )
    -- body
end

function CreateAvatarLayer:verifyName( name )
    local num = string.find(name,'[^%w\128-\191\194-\239]+') 
    if num ~= nil then
        return false, "名字只应包含中英文和数字"
    end

    local name_table = {}
    local tempname = name
    local lowername = string.lower(name)
    local uppername = string.upper(name)
    local length = utf8.len(tempname)
    for i=1,length do
        for j=i,length do
            name_table[#name_table+1] = utf8.sub(tempname,i,j)
        end
    end
    for i=1,length do
        for j=i,length do
            name_table[#name_table+1] = utf8.sub(lowername,i,j)
        end
    end

    for i=1,length do
        for j=i,length do
            name_table[#name_table+1] = utf8.sub(uppername,i,j)
        end
    end

    for k,v in pairs(name_table) do
        if BaseConfig.isIllegalWord(v) then
            return false, "名字包含敏感字符-"..v
        end
    end

    return true
end

function CreateAvatarLayer:createFixedUI( )
    local layer = cc.Layer:create()
    self:addChild(layer)

    -- 顶部条
    local topBack = cc.Sprite:create("image/ui/img/bg/bg_196.png")
    topBack:setAnchorPoint(0.5,1)
    topBack:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT)
    layer:addChild(topBack)
    topBack:runAction(cc.MoveBy:create(0.3, cc.p(0,-50)))

    local topbackSize = topBack:getContentSize()
   
    --- 底部条
    local bottomBack = cc.Sprite:create("image/ui/img/bg/bg_196.png")
    bottomBack:setAnchorPoint(0.5,0)
    bottomBack:setFlippedY(true)
    bottomBack:setPosition(SCREEN_WIDTH*0.5, 0)
    layer:addChild(bottomBack)
    bottomBack:runAction(cc.MoveBy:create(0.3, cc.p(0,50)))

    local bottombackSize = bottomBack:getContentSize()

    local title_image = cc.Sprite:create("image/ui/img/btn/btn_976.png")
    title_image:setPosition(topbackSize.width*0.5, topbackSize.height*0.5)
    topBack:addChild(title_image)

    local title = cc.Sprite:create("image/ui/img/btn/btn_974.png")
    title:setPosition(topbackSize.width*0.5, topbackSize.height*0.5+10)
    topBack:addChild(title)


    local editbg = cc.Sprite:create("image/ui/img/btn/btn_969.png")
    editbg:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5+50)
    layer:addChild(editbg)
    editbg:setOpacity(0)
    editbg:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.FadeIn:create(0.5) ))

    local function editBoxTextEventHandle(strEventName,pSender) 
        if strEventName == "began" then
            pSender:setText("")
        elseif strEventName == "ended" then
            local text = pSender:getText()
            local name = string.trim(text)
            if string.utf8len(name) > 5 then
                pSender:setText("")
                application:showFlashNotice("名字太长了！")
            elseif string.utf8len(name) < 2 then
                pSender:setText("")
                application:showFlashNotice("名字太短了！")
            else
                pSender:setText(name)
            end
        end
    end


    local size = editbg:getContentSize()

    local edit_account = ccui.EditBox:create(cc.size(size.width*0.5, size.height*0.4), ccui.Scale9Sprite:create())
    edit_account:setTouchEnabled(true)
    edit_account:ignoreContentAdaptWithSize(false)
    edit_account:setPlaceholderFontName(BaseConfig.fontname)
    edit_account:setPlaceHolder("输入角色名")
    edit_account:setPlaceholderFontSize(18)
    -- edit_account:setContentSize(size)
    -- edit_account:setFontSize(24)
    -- edit_account:setMaxLengthEnabled(true)
    edit_account:setMaxLength(5)
    edit_account:setFontName(BaseConfig.fontname)
    -- edit_account:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    -- edit_account:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    edit_account:setPosition(size.width*0.6,size.height*0.5-5)
    edit_account:registerScriptEditBoxHandler(editBoxTextEventHandle) 
    editbg:addChild(edit_account)

    edit_account:setVisible(false)
    edit_account:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.Show:create() ))

    local name = "" --BaseConfig.randomName()
    -- name = string.trim(name)
    repeat
        name = BaseConfig.randomName()
        name = string.trim(name)
    until self:verifyName(name)
    edit_account:setText(name)

    local saizi = ccui.MixButton:create("image/ui/img/btn/btn_975.png")
    saizi:setPosition(size.width-10, size.height*0.5)
    editbg:addChild(saizi)
    saizi:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            -- local name = BaseConfig.randomName()
            -- warning： 在setString中直接调用string.trim(name)在name为空字符串时会报错
            -- name = string.trim(name)
            local name = ""
            repeat
                name = BaseConfig.randomName()
                name = string.trim(name)
            until self:verifyName(name)
            edit_account:setText(name)
        end
    end)
    saizi:setOpacity(0)
    saizi:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.FadeIn:create(0.5) ))

    local begin = ccui.MixButton:create("image/ui/img/btn/btn_977.png")
    begin:setChild("image/ui/img/btn/btn_978.png")
    begin:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5-50)
    layer:addChild(begin)
    begin:addTouchEventListener(function ( sender,eventType )
        if eventType == ccui.TouchEventType.ended then
            begin:setStateEnabled(false)

            local name = edit_account:getText()
            name = string.trim(name)
            if name == "" then
                application:showFlashNotice("上仙想做无名之辈吗？")
                begin:setStateEnabled(true)
                return
            end

            if string.utf8len(name) < 2 or string.utf8len(name) > 5 then
                edit_account:setText("")
                application:showFlashNotice("名字长度为2～5个字符")
                begin:setStateEnabled(true)
                return
            end
           

            local verify, msg = self:verifyName(name)
            if not verify then
                edit_account:setText("")
                application:showFlashNotice(msg)
                begin:setStateEnabled(true)
                return
            end

            -- HeroID = self.selectHeroID
            rpc:call("Guide.ChooseRole", {HeroID = INIT_HERO, Name = name}, function ( event )
                
                if event.status == Exceptions.Nil and event.result == true then
                    GameCache.NewbieGuide.Step = 1
                    GameCache.NewbieGuide.SavePoint = GameCache.NewbieGuide.Step
                    rpc:call("Guide.SetCurStep", GameCache.NewbieGuide.Step, function (event)
                        
                        if event.status == Exceptions.Nil and event.result == true then
                            local drops = BaseConfig.GetNameAward()[1].Award
                            local alertShow = require("scene.main.ReceiveGoods").new(drops, "image/ui/img/btn/btn_815.png", function (  )
                                if self.callback then
                                    self.callback(name)
                                    application:popScene()
                                else
                                    application:enterGame()
                                end                               
                            end)
                            self:addChild(alertShow)  
                        else
                            begin:setStateEnabled(true)
                        end
                    end)
                elseif event.status == Exceptions.ERoleNameDuplicate then
                    begin:setStateEnabled(true)
                    application:showFlashNotice("名字已经被人抢注了")

                elseif event.status == Exceptions.ERoleNameCharset then
                    application:showFlashNotice("名字只应包含中英文和数字")

                elseif event.status == Exceptions.ERoleNameIllegal then
                    application:showFlashNotice("名字包含非法字符")

                elseif event.status == Exceptions.ERoleNameLengthInvalid then
                    application:showFlashNotice("名字长度为2～5个字符")
                else
                    begin:setStateEnabled(true)
                end
            end)
        end
    end)

    begin:setVisible(false)
    begin:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.Show:create() ))

    local s = cc.Sprite:create("image/ui/img/btn/btn_1332.png")
    s:setPosition(bottombackSize.width*0.5, bottombackSize.height)
    bottomBack:addChild(s)

    local s = cc.Sprite:create("image/ui/img/btn/btn_1331.png")
    s:setPosition(bottombackSize.width*0.5, -20)
    s:setAnchorPoint(0.5,0)
    bottomBack:addChild(s)

    -- local function droplist( items)
        
    --     local function cellSizeForTable( table, idx )
    --         return 60, 75
    --     end
    
    --     local function tableCellAtIndex( table, idx )
    --         local cell = cc.TableViewCell:new()
    
    --         local drop = Common.getGoods(items[idx+1],false,BaseConfig.GOODS_SMALLTYPE)
    --         drop:setPosition(35, 30)
    
    --         cell:addChild(drop)
    
    --         return cell
    --     end
    
    --     local function numberOfCellsInTableView(table)
    --         return #items
    --     end
    --     local width = #items * 73
    --     local tableView = cc.TableView:create(cc.size(width, 80))
    --     tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    --     -- tableView:setPosition(cc.p(SCREEN_WIDTH*0.1+offsetX, SCREEN_HEIGHT*0.35))
    --     tableView:setDelegate()
    --     tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    --     tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    --     tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    --     tableView:reloadData()
        
    --     return tableView
    
    -- end

    local drops = BaseConfig.GetNameAward()[1].Award

    -- local dropListTableView = droplist(drops)    -- 展示掉落
    -- dropListTableView:setPosition(bottombackSize.width*0.5-dropListTableView:getContentSize().width*0.5, 0)
    -- bottomBack:addChild(dropListTableView)

    local offx = bottombackSize.width*0.5 - (#drops-1)*35
    for i=1, #drops do
        local sprite = Common.getGoods(drops[i],false,BaseConfig.GOODS_SMALLTYPE)
        sprite:setPosition(offx+(i-1)*70, 30)
        -- sprite:setNumVisible(false)
        bottomBack:addChild(sprite)
    end
end

function CreateAvatarLayer:createFlexUI(  )
    local layer = cc.Layer:create()
    self:addChild(layer)

    local heroid = {1020,1021} -- 白娘子， 吕洞宾
    local heroTable = {}
    local heroBtn = {}
    local heroIdx = 1

    local heroConfig = {}
    for _, id in ipairs(heroid) do
        heroConfig[id] = BaseConfig.GetHero(id)
        -- 以下两行由于配置字段名与服务器字段名不一致造成，临时处理，最后要统一（生成头像时需要）
        heroConfig[id]["ID"] = id
        heroConfig[id]["StarLevel"] = heroConfig[id].starLevel
    end

    local herobg = cc.Sprite:create("image/ui/img/btn/btn_973.png")
    herobg:setPosition(SCREEN_WIDTH*0.22, SCREEN_HEIGHT*0.43)
    layer:addChild(herobg)

    local size = herobg:getContentSize()

    local guang = cc.Sprite:create("image/ui/img/btn/btn_979.png")
    guang:setAnchorPoint(0.5,0)
    guang:setPosition(size.width*0.5, 50)
    herobg:addChild(guang)
    guang:runAction(cc.RepeatForever:create(cc.Sequence:create(
        cc.FadeIn:create(1),
        cc.FadeOut:create(1))))

    local namebg = cc.Scale9Sprite:create("image/ui/img/btn/btn_801.png")
    namebg:setContentSize(cc.size(141,55))
    namebg:setPosition(size.width*0.5, 10)
    herobg:addChild(namebg)

    local label_name = Common.finalFont("" , size.width*0.5 , 10,22,cc.c3b(252,202,118))
    herobg:addChild(label_name)

    for i=1,#heroid do
        local hero = HeroManager.new(size.width*0.5, size.height*0.5, heroid[i])
        hero:setVisible(false)
        hero:setTouchEnabled(false)
        hero:setAnimation(0,"idle", true)
        herobg:addChild(hero)
        heroTable[heroid[i]..""] = hero
        hero.sound = BaseConfig.GetSoundHero(heroid[i]).Speak or {}
    end

    local iconsize = cc.size(430,160)
    local iconbg = ccui.ImageView:create("image/ui/img/bg/bg_261.png")
    iconbg:setPosition(SCREEN_WIDTH-240, SCREEN_HEIGHT*0.43)
    iconbg:setScale9Enabled(true)
    iconbg:setContentSize(iconsize)
    layer:addChild(iconbg)

    local label_star = cc.Label:createWithCharMap("image/ui/img/btn/btn_627.png",44,52,string.byte("0"))
    label_star:setPosition(iconsize.width*0.5-15, iconsize.height-5)
    label_star:setScale(0.5)
    iconbg:addChild(label_star)

    local star = cc.Sprite:create("image/ui/img/btn/btn_638.png")
    star:setPosition(iconsize.width*0.5+15, iconsize.height-5)
    iconbg:addChild(star)

    local label = Common.finalFont("战斗" , 70,115, 20)
    label:setAnchorPoint(0,0.5)
    iconbg:addChild(label)

    local label_talent = Common.finalFont("" , 125, 115, 20, cc.c3b(255,248,41), 1)
    label_talent:setAnchorPoint(0,0.5)
    iconbg:addChild(label_talent)

    label = Common.finalFont("武器" , 185, 115, 20)
    label:setAnchorPoint(0,0.5)
    iconbg:addChild(label)

    local label_type = Common.finalFont("" , 245,115, 20, cc.c3b(255,248,41), 1)
    label_type:setAnchorPoint(0,0.5)
    iconbg:addChild(label_type)

    local label_wx = cc.Label:createWithCharMap("image/ui/img/btn/btn_410.png",31,31,string.byte("0"))
    label_wx:setPosition(330,115)
    iconbg:addChild(label_wx)

    local label_desc = Common.finalFont("" , iconsize.width*0.5,95, 20, nil, 1)
    label_desc:setDimensions(300,70)
    label_desc:setAnchorPoint(0.5,1)
    iconbg:addChild(label_desc)


    local function selectHero( id )
        for i=1,#heroid do
            heroTable[heroid[i]..""]:setVisible(false)
            heroTable[heroid[i]..""]:setTouchEnabled(false)
            heroBtn[heroid[i]..""]:setChooseBorderVisible(false)
        end

        local x = math.random(#heroTable[id..""].sound)
        local path = "audio/hero/"..heroTable[id..""].sound[x]..".mp3"
        Common.stopAllSounds()
        Common.playSound(path)
        heroTable[id..""]:setVisible(true)
        heroTable[id..""]:setTouchEnabled(true)
        heroBtn[id..""]:setChooseBorderVisible(true)

        label_name:setString(heroConfig[id].name)
        label_star:setString(heroConfig[id].starLevel)
        label_wx:setString(""..heroConfig[id].wx-1)

        local talentDesc = BaseConfig.BATTLE_TYPE_NAME[(heroConfig[id].atkSkill - 1000)]
        label_talent:setString(talentDesc)
        label_desc:setString(heroConfig[id].desc2)

        local armTypeDesc = BaseConfig.ARM_TYPE_NAME[heroConfig[id].armType]
        label_type:setString(armTypeDesc)

        self.selectHeroID = id
    end

    for i=1,#heroid do
        local btn = GoodsInfoNode.new(BaseConfig.GOODS_HERO, heroConfig[heroid[i]], BaseConfig.GOODS_BIGTYPE)
        btn:setPosition(SCREEN_WIDTH-120*(#heroid-i+1), SCREEN_HEIGHT*0.7)
        layer:addChild(btn)
        heroBtn[heroid[i]..""] = btn
        btn:addTouchEventListener(function ( sender, eventType )
            if eventType == ccui.TouchEventType.ended then
                selectHero(heroid[i])
                heroIdx = i
            end
        end)
    end
	
    local btn_next = ccui.MixButton:create("image/ui/img/btn/btn_875.png")
    btn_next:setPosition(size.width, size.height*0.5)
    btn_next:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            heroIdx = heroIdx + 1
            if heroIdx == 3 then
                heroIdx = 1
            end
            selectHero(heroid[heroIdx])
        end
    end)

    herobg:addChild(btn_next)

    local btn_prev = ccui.MixButton:create("image/ui/img/btn/btn_875.png")
    btn_prev:setFlippedX(true)
    btn_prev:setPosition(0, size.height*0.5)
    btn_prev:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            heroIdx = heroIdx - 1
            if heroIdx == 0 then
                heroIdx = 2
            end
            selectHero(heroid[heroIdx])
        end
    end)
    herobg:addChild(btn_prev)
    selectHero(heroid[1])
end

return CreateAvatarLayer
