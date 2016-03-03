
local EmailLayer = class("EmailLayer", BaseLayer)
local ColorLabel = require("tool.helper.ColorLabel")



function EmailLayer:ctor(emaillist)
    EmailLayer.super.ctor(self)

    self.emailTable = {}

    self.lastidx = nil
    self.emailList = {}
    self.emailList = emaillist
    self.unreadEmailNum = 0
    self.manyAttach = false
    self.attachEmailNum = 0
    for k,v in pairs(self.emailList) do
        if not v.IsRead then
            self.unreadEmailNum = self.unreadEmailNum + 1
        end
        if v.Type == 1 then
            self.attachEmailNum = self.attachEmailNum+1
        end
    end

    if self.attachEmailNum > 1 then
        self.manyAttach = true
    end
end

function EmailLayer:onEnter()
    self:createUI()
end

function EmailLayer:onExit()
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:removeEventListener(self._listener)
end

function EmailLayer:createUI()

    local panel = cc.Layer:create()
    self:addChild(panel)

    local background = cc.Sprite:create("image/ui/img/bg/bg_037.jpg")
    background:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)
    panel:addChild(background)

    local bgsize = cc.size(885,558)
    local bg = ccui.ImageView:create("image/ui/img/bg/bg_111.png")
    bg:setPosition(SCREEN_WIDTH*0.5, 20)
    bg:setAnchorPoint(0.5,0)
    bg:setScale9Enabled(true)
    bg:setContentSize(bgsize)
    panel:addChild(bg)

    local light = cc.Sprite:create("image/ui/img/bg/bg_112.png")
    light:setAnchorPoint(0.5,1)
    light:setPosition(bgsize.width*0.5, bgsize.height-2)
    bg:addChild(light)


    light = cc.Sprite:create("image/ui/img/bg/bg_113.png")
    light:setAnchorPoint(0.5,1)
    light:setPosition(bgsize.width*0.5, bgsize.height-2)
    bg:addChild(light)

    -- local itembg = cc.Sprite:create("image/ui/img/bg/bg_110.png")
    -- itembg:setAnchorPoint(0.5,0)
    -- itembg:setPosition(bgsize.width*0.5, 25)
    -- bg:addChild(itembg)

    local leftSize = cc.size(512,490)
    local leftPanel = ccui.ImageView:create("image/ui/img/bg/bg_139.png")
    leftPanel:setPosition(10, 5)
    leftPanel:setAnchorPoint(0,0)
    leftPanel:setScale9Enabled(true)
    leftPanel:setContentSize(leftSize)
    bg:addChild(leftPanel)

    local rightSize = cc.size(362,490)
    local rightPanel = ccui.ImageView:create("image/ui/img/bg/bg_141.png")
    rightPanel:setPosition(bgsize.width-5, 5)
    rightPanel:setAnchorPoint(1,0)
    rightPanel:setScale9Enabled(true)
    rightPanel:setContentSize(rightSize)
    bg:addChild(rightPanel)

    local btn_close = createMixSprite("image/ui/img/btn/btn_598.png")
    btn_close:setPosition(bgsize.width-5, bgsize.height-5)
    btn_close:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            -- self:removeFromParent()
            -- self = nil
            application:popScene()
        end
    end)
    bg:addChild(btn_close)



    local titlebg = cc.Sprite:create("image/ui/img/bg/bg_142.png")
    titlebg:setPosition(100, bgsize.height-5)
    bg:addChild(titlebg)

    local title = cc.Sprite:create("image/ui/img/btn/btn_474.png")
    title:setPosition(100, bgsize.height)
    bg:addChild(title)

    local sp = cc.Sprite:create("image/ui/img/btn/btn_609.png")
    sp:setPosition(235,260)
    leftPanel:addChild(sp)

    local btn_clear = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(146,62))  
    btn_clear:setCircleFont("全部清空",1,1,22, cc.c3b(226,204,169))
    btn_clear:setFontOutline(cc.c4b(65,26,1,255),2 )
    btn_clear:setFontPos(0.5, 0.5)
    btn_clear:setPosition(95, 60)
    btn_clear:setName("clear")
    btn_clear:addTouchEventListener(handler(self, self.clearEmail))
    leftPanel:addChild(btn_clear)

    local btn_delete = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(146,62))
    btn_delete:setCircleFont("删除已读",1,1,22, cc.c3b(226,204,169))
    btn_delete:setFontOutline(cc.c4b(65,26,1,255),2 )
    btn_delete:setFontPos(0.5, 0.5)
    btn_delete:setPosition(390,60)
    btn_delete:setName("delete")
    btn_delete:addTouchEventListener(handler(self, self.clearEmail))
    leftPanel:addChild(btn_delete)



    -- email list
    local function createEmailList(  )
        
        local function scrollViewDidScroll(view)
    
        end
    
        local function scrollViewDidZoom( view )
    
        end
    
        local function tableCellTouched( table, cell )
            local idx = cell:getIdx()
    
            -- recive the emails' information from cell
            local emailId = self.emailList[idx + 1].ID
            if not self.emailList[idx+1].IsRead then
                self.emailList[idx+1].IsRead = true
                self.unreadEmailNum = self.unreadEmailNum - 1
                self.labelEmailNum:setString(self.unreadEmailNum.."/"..#self.emailList)
            end
            self.currEmailID = emailId
            self.currEmailIdx = idx + 1
    
            self:readEmail(emailId)
    
            local s = cell:getChildByTag(34)

            if self.emailList[idx+1].Type == 1 then
                s:setTexture("image/ui/img/btn/btn_1150.png")

            else
                s:setTexture("image/ui/img/btn/btn_476.png")
            end

            local s = cell:getChildByTag(56)
            s:loadTexture("image/ui/img/btn/btn_496.png")
    
            local s = cell:getChildByTag(12)
            s:setVisible(true)        
    
            -- dump(self.lastidx)
            if self.lastidx ~= idx and self.lastidx ~= nil then
                local c = table:cellAtIndex(self.lastidx)
                if c~=nil then
                    local s = c:getChildByTag(12)
                    s:setVisible(false)
                end
            end
    
            self.lastidx = idx
    
        end
    
        local function cellSizeForTable( table, idx )
            return 70, 456
        end
    
        local function tableCellAtIndex( table, idx )
            local title = self.emailList[idx+1].Title
            -- local date =  string.sub(self.emailList[idx+1].DateTime, 6,10) å
            local date = self.emailList[idx+1].DateTime
            local isRead = self.emailList[idx+1].IsRead
            local emailType = self.emailList[idx+1].Type
    
            local cell = cc.TableViewCell:new()
            cell:removeAllChildren()
    
            local itemsize = cc.size(450,60)
            local itembg = nil
            
    
          
            local icon = nil
            if isRead == true then
                if emailType == 1 then
                    icon = cc.Sprite:create("image/ui/img/btn/btn_1150.png")
                else

                    icon = cc.Sprite:create("image/ui/img/btn/btn_476.png")
                end
                
                itembg = ccui.ImageView:create("image/ui/img/btn/btn_496.png")
                -- itembg:setScale9Enabled(true)
                -- itembg:setContentSize(itemsize)
                -- itembg:setAnchorPoint(0.5,0)
                itembg:setPosition(228, 35)
                cell:addChild(itembg)
            else
                if emailType == 1 then
                    icon = cc.Sprite:create("image/ui/img/btn/btn_1149.png")
                else

                    icon = cc.Sprite:create("image/ui/img/btn/btn_475.png")
                end
                itembg = ccui.ImageView:create("image/ui/img/btn/btn_478.png")
                -- itembg:setScale9Enabled(true)
                -- itembg:setContentSize(itemsize)
                -- itembg:setAnchorPoint(0.5,0)
                itembg:setPosition(228, 35)
                cell:addChild(itembg)
                
            end
            itembg:setTag(56)
            icon:setTag(34)
            icon:setAnchorPoint(0, 0.5)
            icon:setPosition(20, 35)
            cell:addChild(icon)
    
            local itembg1 = cc.Sprite:create("image/ui/img/btn/btn_480.png")
            -- itembg1:setAnchorPoint(0.5,0)
            itembg1:setPosition(228, 37)
            itembg1:setTag(12)
            itembg1:setVisible(false)
            cell:addChild(itembg1)  
    
            local labelTitle = Common.finalFont(title,  1, 1, 22)
            labelTitle:setPosition(80,35)
            labelTitle:setAnchorPoint(cc.p(0,0.5))
            labelTitle:setColor(cc.c3b(0,0,0))
            cell:addChild(labelTitle)
            local labelDate = Common.systemFont(date,  1, 1, 18)
            labelDate:setAnchorPoint(cc.p(1,0.5))
            labelDate:setPosition(cc.p(430,35))
            labelDate:setColor(cc.c3b(24,81,166))
            cell:addChild(labelDate)
    
            return cell
        end
    
        local function numberOfCellsInTableView(table)
            return #self.emailList
        end
    
        local tableView = cc.TableView:create(cc.size(456, 350))
        tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        tableView:setPosition(cc.p(25, 100))
        tableView:setDelegate()
        tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    
        tableView:registerScriptHandler(scrollViewDidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL)
        tableView:registerScriptHandler(scrollViewDidZoom,cc.SCROLLVIEW_SCRIPT_ZOOM)
        tableView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
        tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
        tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
        tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        tableView:reloadData()
    
        return tableView
    
    end

    local emailView = createEmailList()
    leftPanel:addChild(emailView)
    self.controls.tableView = emailView

    local btn_getAllAttach = ccui.MixButton:create("image/ui/img/btn/btn_593.png")
    btn_getAllAttach:setVisible(false)
    btn_getAllAttach:setScale9Size(cc.size(146,62))
    btn_getAllAttach:setPosition(390,500)
    btn_getAllAttach:setTitle("收取全部", 20)
    leftPanel:addChild(btn_getAllAttach)
    btn_getAllAttach:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            rpc:call("Mail.DrawAttachment", "", function ( event )
                if event.status == Exceptions.Nil and event.result ~= nil then
        
                    local alertShow = require("scene.main.ReceiveGoods").new(event.result, "image/ui/img/btn/btn_815.png")
                    self:addChild(alertShow)            
        
                end
        
                self.attachEmailNum = 0
                local remove = {}
                for key, var in pairs(self.emailList) do
                    if var.Type == 1 then
                        table.insert(remove, key)
                        if not var.IsRead then
                            self.unreadEmailNum = self.unreadEmailNum - 1
                        end
                    end

                end

                table.sort(remove, function(a,b)
                    return a>b
                end)

                for key, var in pairs(remove) do
                    table.remove(self.emailList, var)

                end
                remove = nil

                self.controls.tableView:reloadData()
                self.labelEmailNum:setString(self.unreadEmailNum.."/"..#self.emailList)
                if nil ~= self.controls.contentLayer then
                    self.controls.contentLayer:removeAllChildren()
                end
        
                if #self.emailList ~= 0 then
                    self.noemail_label:setVisible(false)
                    self.noemail_sprite:setVisible(false)
                else
                    self.noemail_label:setVisible(true)
                    self.noemail_sprite:setVisible(true)
                end
        
                btn_getAllAttach:setVisible(false)
            end)
        end
    end)

    self.btn_getAllAttach = btn_getAllAttach
    if self.manyAttach then
        self.btn_getAllAttach:setVisible(true)
    end

    local sp = cc.Sprite:create("image/ui/img/btn/btn_989.png")
    sp:setPosition(130,300)
    sp:setVisible(false)
    leftPanel:addChild(sp)
    self.noemail_sprite = sp

    local label = Common.finalFont("您目前没有邮件", 1, 1, 22, cc.c3b(61,131,172))
    label:setPosition(250, 300)
    label:setVisible(false)
    leftPanel:addChild(label)    
    self.noemail_label = label  
      
    if #self.emailList ~= 0 then
        self.noemail_label:setVisible(false)
        self.noemail_sprite:setVisible(false)
    else
        self.noemail_label:setVisible(true)
        self.noemail_sprite:setVisible(true)


    end


    local wen = cc.Sprite:create("image/ui/img/btn/btn_592.png")
    wen:setPosition(bgsize.width*0.55, bgsize.height-40)
    bg:addChild(wen)
    
    local wen = cc.Sprite:create("image/ui/img/btn/btn_592.png")
    wen:setPosition(bgsize.width*0.85, bgsize.height-40)
    wen:setFlippedX(true)
    bg:addChild(wen)

    local label = Common.finalFont("邮件数：", 1, 1, 22)
    label:setPosition(bgsize.width*0.7, bgsize.height-40)
    label:setColor(cc.c3b(214,221,232))
    label:enableOutline(cc.c4b(27,38,64,255), 2)
    bg:addChild(label)

    local label = Common.finalFont(self.unreadEmailNum.."/"..#self.emailList, 1, 1, 22)
    label:setAnchorPoint(0,0.5)
    label:setPosition(bgsize.width*0.75, bgsize.height-40)
    label:setColor(cc.c3b(142,239,109))
    label:enableOutline(cc.c4b(27,38,64,255), 2)
    self.labelEmailNum = label
    bg:addChild(label)


    local sprite = cc.Sprite:create("image/ui/img/btn/btn_477.png")
    sprite:setPosition(225, 435)
    rightPanel:addChild(sprite)    

    local content = cc.Sprite:create("image/ui/img/bg/bg_140.png")
    content:setAnchorPoint(0.5,0)
    content:setPosition(rightSize.width*0.5, 105)
    rightPanel:addChild(content)  

    -- email content
    local label = Common.finalFont("发信人", 1, 1, 24)
    label:setPosition(60, 435)
    label:setColor(cc.c3b(23,32,47))
    rightPanel:addChild(label)

    local contentLayer = cc.Layer:create()
    rightPanel:addChild(contentLayer)
    self.controls.contentLayer = contentLayer



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
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, panel)

end

function EmailLayer:createReplayLayer()

    local layer = cc.Layer:create()
    layer:setTag(100)
    self:addChild(layer)

    local bgsize = cc.size(590,280)

    local bg = ccui.ImageView:create("image/ui/img/bg/bg_141.png")
    bg:setPosition(SCREEN_WIDTH*0.5,SCREEN_HEIGHT*0.5)
    bg:setScale9Enabled(true)
    bg:setContentSize(bgsize)
    layer:addChild(bg)

    local function onTouchBegan(touch, event)
        return true
    end

    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
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
    local eventDispatcher = layer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, bg)    

    local label = Common.finalFont("收件人：", 1, 1, 18)
    label:setPosition(bgsize.width*0.13, bgsize.height*0.8)
    bg:addChild(label)


    label = Common.finalFont(self.emailInfo.FromName, 1, 1, 18, cc.c3b(24, 81, 166))
    label:setAnchorPoint(0,0.5)
    label:setPosition(bgsize.width*0.18, bgsize.height*0.8)
    bg:addChild(label)

    local size = cc.size(bgsize.width*0.85,bgsize.height*0.4)

    local bg1 = cc.Sprite:create("image/ui/img/bg/bg_274.png")
    bg1:setPosition(bgsize.width * 0.5, bgsize.height * 0.55)
    bg:addChild(bg1)
    
    local function textFieldEvent(sender, eventType)
        if eventType == ccui.TextFiledEventType.attach_with_ime then

        elseif eventType == ccui.TextFiledEventType.detach_with_ime then

        elseif eventType == ccui.TextFiledEventType.insert_text then

        elseif eventType == ccui.TextFiledEventType.delete_backward then

        end
    end

    local inputsize = cc.size(size.width-20, size.height -20)
    local textinput = ccui.TextField:create()
    textinput:setTouchEnabled(true)
    textinput:ignoreContentAdaptWithSize(false)
    textinput:setPlaceHolder("请输入您的邮件内容（120字以内）")
    textinput:setContentSize(inputsize)
    textinput:setColor(cc.c3b(0,0,0))
    textinput:setMaxLengthEnabled(true)
    textinput:setMaxLength(120)
    -- textinput:setFontSize(16)
    textinput:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    textinput:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    textinput:setPosition(bgsize.width*0.5, bgsize.height*0.53)
    textinput:addEventListener(textFieldEvent)

    bg:addChild(textinput)
   
    local btn = createMixSprite("image/ui/img/btn/btn_591.png")
    btn:setPosition(bgsize.width*0.8,bgsize.height*0.2)
    btn:setCircleFont("发送",1,1,24)
    btn:setFontPos(0.5, 0.5)
    btn:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended   then
            local content = textinput:getStringValue()
            content = string.trim(content)
            if content == "" then
                application:showFlashNotice("邮件内容不能为空噢")
                return
            end
            rpc:call("Mail.ReplyMail", {To = self.emailInfo.From, Content=content}, function ( event )
                if event.status == Exceptions.Nil then
                    layer:removeFromParent()
                    layer = nil 
                end
            end)
        end
    end)

    bg:addChild(btn)

    btn = createMixSprite("image/ui/img/btn/btn_591.png")
    btn:setPosition(bgsize.width*0.2,bgsize.height*0.2)
    btn:setCircleFont("取消",1,1,24)
    btn:setFontPos(0.5, 0.5)
    btn:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            layer:removeFromParent()
            layer = nil            
        end
    end)
    bg:addChild(btn)

end

-- logic--

--- 阅读邮件
function EmailLayer:readEmail(emailId)

    if self.emailTable[emailId..""] == nil then
        rpc:call("Mail.ReadMail", emailId, function ( event )
            if event.status == Exceptions.Nil and event.result ~= nil then
                self.emailTable[emailId..""] = event.result
                self.emailInfo = {}
                self.emailInfo = self.emailTable[emailId..""]
                self:updateEmailContent()
            end
        end)
    else
        self.emailInfo = {}
        self.emailInfo = self.emailTable[emailId..""]
        self:updateEmailContent()
    end

end

-- 更新相应邮件展示信息
function EmailLayer:updateEmailContent()
    if nil ~= self.controls.contentLayer then
        self.controls.contentLayer:removeAllChildren()
    end

    local senderName = Common.finalFont(self.emailInfo.FromName,  1, 1, 20)
    senderName:setAnchorPoint(0,0.5)
    senderName:setPosition(120, 435)  --应该对齐 text_name
    senderName:setColor(cc.c3b(24, 81, 166))
    self.controls.contentLayer:addChild(senderName)

    local viewsize = cc.size(295,260)
    local scrollview = ccui.ScrollView:create()
    scrollview:setTouchEnabled(true)
    scrollview:setPosition(cc.p(35,125))


    local function createColorLabel( str, font, fontsize )
        local function getColorAndText( text )
            local contentTab = {}
            for v in string.gfind(str, "%b]=") do 
                table.insert(contentTab, string.sub(v, 2, string.len(v) - 2))
            end

            local rgbTabs = {}
            for w in string.gfind(str, "%b[]") do 
                if  string.sub(w,2,2) ~= "=" then --把rgb值表取出来 --[0,0,0]
                    local rgbTab = {}
                    local rgbs = string.sub(w, 2, string.len(w) - 1) --去掉中括号 --0,0,0
                    for rgb in string.gmatch(rgbs, "%d+") do -- 把3个值分别取出来 --0 0 0
                        table.insert(rgbTab, rgb)
                    end
                    table.insert(rgbTabs, rgbTab)
                end
            end
            return rgbTabs, contentTab
        end


        local colorTable, textTable = getColorAndText(str)

        local richText = ccui.RichText:create()
        richText:ignoreContentAdaptWithSize(false)

        for i=1,#textTable do
            local re = ccui.RichElementText:create(i, cc.c3b(colorTable[i][1], colorTable[i][2], colorTable[i][3]), 255, textTable[i], font, fontsize)
            richText:pushBackElement(re)            
        end

        return richText, textTable
    end

    -- local content, strTable = createColorLabel("[0,13,21]"..self.emailInfo.Content.."[=]",  "fonts/DFYuanW7-GBK.ttf", 20)
    -- local content = ccui.RichText:create(self.emailInfo.Content,"DFYuanW7-GBK", 22, cc.size(300,300))
    -- content:ignoreContentAdaptWithSize(false)
    local content = Common.systemFont(self.emailInfo.Content,  1, 1, 20, cc.c3b(0,13,21))
    local label = Common.systemFont(self.emailInfo.Content,  1, 1, 20, cc.c3b(0,13,21))


    content:setAnchorPoint(cc.p(0.5,1))
    local size = label:getContentSize()
    label:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    label:setLineBreakWithoutSpace(false)
    local h = math.ceil(size.width/viewsize.width) * size.height 

    -- print(viewsize.width, h)
    content:setDimensions(viewsize.width, h)
    scrollview:addChild(content)

    if h<260 then
        -- content:setPosition(viewsize.width*0.5,viewsize.height+h*0.5)
        content:setPosition(viewsize.width*0.5,viewsize.height)
        scrollview:setInnerContainerSize(viewsize)
    else
        -- content:setPosition(viewsize.width*0.5,h*1.5)
        content:setPosition(viewsize.width*0.5,h)

        scrollview:setInnerContainerSize(cc.size(viewsize.width, h))
    end

    scrollview:setContentSize(viewsize)    
    scrollview:setDirection(ccui.ScrollViewDir.vertical)
    self.controls.contentLayer:addChild(scrollview)


    local emailtype = self.emailInfo.Type
    if emailtype == 0 then
        -- 放一个 删除 button
        -- local btn_deleteCur = createMixSprite("image/ui/img/btn/btn_591.png")
        -- btn_deleteCur:setPosition(270,60)
        -- btn_deleteCur:setCircleFont("删除",1,1,24)
        -- btn_deleteCur:setFontPos(0.5,0.5)
        -- btn_deleteCur:setName("deleteCurr")
        -- btn_deleteCur:addTouchEventListener(handler(self, self.clearEmail))
        -- self.controls.contentLayer:addChild(btn_deleteCur)
    elseif emailtype == 1 then

        local offsetX = 0
        local offsetY = 0

        for i=0,#self.emailInfo.Attachment-1 do
            offsetX = i%5
            offsetY = math.floor(i/5)
            local posx = offsetX * 60+ 60
            local posy = 140 + offsetY * 50
            local goods = Common.getGoods(self.emailInfo.Attachment[i+1],false)
            goods:setScale(0.5)
            goods:setPosition(posx, posy)
            self.controls.contentLayer:addChild(goods)
        end

        local newHeight = viewsize.height - 50*(offsetY+1)

        scrollview:setPosition(35,50*(offsetY+1)+125)
        scrollview:setContentSize(cc.size(viewsize.width, newHeight)) 

        -- 放一个 收附件 button
        local btn_recvAttach = createMixSprite("image/ui/img/btn/btn_591.png")
        btn_recvAttach:setPosition(180,60)
        btn_recvAttach:setCircleFont("收附件",1,1,24)
        btn_recvAttach:setFontPos(0.5,0.5)
        btn_recvAttach:setName("recive_attach")
        btn_recvAttach:addTouchEventListener(function ( sender, eventType )
            if eventType == ccui.TouchEventType.ended then
                self:reciveAttach()
            end
        end)
        self.controls.contentLayer:addChild(btn_recvAttach)        
    elseif emailtype == 2 then
        -- 放一个 删除 button ，一个回复  button
        local btn_deleteCur = createMixSprite("image/ui/img/btn/btn_591.png")
        btn_deleteCur:setPosition(275,60)
        btn_deleteCur:setCircleFont("删除",1,1,24)
        btn_deleteCur:setFontPos(0.5,0.5)
        btn_deleteCur:setName("deleteCurr")
        btn_deleteCur:addTouchEventListener(handler(self, self.clearEmail))
        self.controls.contentLayer:addChild(btn_deleteCur)

        local btn_replay = createMixSprite("image/ui/img/btn/btn_591.png")
        btn_replay:setPosition(90,60)
        btn_replay:setCircleFont("回复",1,1,24)
        btn_replay:setFontPos(0.5,0.5)
        btn_replay:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                self:createReplayLayer()
            end
            
        end)
        self.controls.contentLayer:addChild(btn_replay)
    end

end


--- 接收附件
function EmailLayer:reciveAttach()
    rpc:call("Mail.DrawAttachment", self.currEmailID, function ( event )
        if event.status == Exceptions.Nil and event.result ~= nil then

            local alertShow = require("scene.main.ReceiveGoods").new(event.result, "image/ui/img/btn/btn_815.png")
            -- alertShow:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
            -- local scene = cc.Director:getInstance():getRunningScene()
            self:addChild(alertShow)            

        end

        self.attachEmailNum = self.attachEmailNum -1

        table.remove(self.emailList, self.currEmailIdx)
        self.controls.tableView:reloadData()
        self.labelEmailNum:setString(self.unreadEmailNum.."/"..#self.emailList)
        if nil ~= self.controls.contentLayer then
            self.controls.contentLayer:removeAllChildren()
        end

        if #self.emailList ~= 0 then
            self.noemail_label:setVisible(false)
            self.noemail_sprite:setVisible(false)
        else
            self.noemail_label:setVisible(true)
            self.noemail_sprite:setVisible(true)
        end

        if self.attachEmailNum < 2 then
            self.btn_getAllAttach:setVisible(false)
        else
            self.btn_getAllAttach:setVisible(true)
        end
        

    end)
end


--- 清空所有邮件0 ，删除已读邮件1， 删除指定邮件 2
function EmailLayer:clearEmail(sender, eventType)
    local emailId, deleteType
    if eventType == ccui.TouchEventType.ended then
        if next(self.emailList) == nil then --邮件列表空
            return
        end

        local name = sender:getName()
        if name == "clear" then
            emailId = ""
            deleteType = 2
            -- 根据是否有附件，判断清空条件
            
        elseif name == "delete" then
            emailId = ""
            deleteType = 1

            local remove = {}
            for key, var in pairs(self.emailList) do
                if var.IsRead == true and var.Type ~= 1 then
                    table.insert(remove, key)
                end
            end
            table.sort(remove, function(a,b)
                return a>b
            end)
            for key, var in pairs(remove) do
                table.remove(self.emailList, var)
            end
            remove = nil
            self.labelEmailNum:setString(self.unreadEmailNum.."/"..#self.emailList)
        elseif name == "deleteCurr" then
            emailId = self.currEmailID
            deleteType = 0
            table.remove(self.emailList, self.currEmailIdx)
            self.labelEmailNum:setString(self.unreadEmailNum.."/"..#self.emailList)
        else
            return nil
        end

        rpc:call("Mail.DeleteMail", {ID = emailId, Type = deleteType}, function ( event )
            if event.status == Exceptions.Nil then
                if deleteType == 2 then
                    self.emailList = event.result or {}
                    self.unreadEmailNum = 0
                    for k,v in pairs(self.emailList) do
                        if not v.IsRead then
                            self.unreadEmailNum = self.unreadEmailNum + 1
                        end
                    end
                    self.labelEmailNum:setString(self.unreadEmailNum.."/"..#self.emailList)
                end
                self.controls.tableView:reloadData()
                if nil ~= self.controls.contentLayer then
                    self.controls.contentLayer:removeAllChildren()
                end
            end
        end)

        if #self.emailList ~= 0 then
            self.noemail_label:setVisible(false)
            self.noemail_sprite:setVisible(false)
        else
            self.noemail_label:setVisible(true)
            self.noemail_sprite:setVisible(true)
        end
    end
end

return EmailLayer
