local FormDescNode = class("FormDescNode", function() return cc.Node:create() end)

function FormDescNode:ctor(formData)
	self.formData = formData

    self:setupUI()
end

function FormDescNode:setupUI()
    local size = cc.size(600, 400)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setPosition(cc.p(display.cx, display.cy))
    self:setContentSize(size)

    local function onTouchBegan(touch, event)
        local rect = self:getBoundingBox()
        local location = touch:getLocation()

        CCLog(vardump(rect, location), "onTouchBegan")

        if  cc.rectContainsPoint(rect, location) then
            return true
        else
            self:removeFromParent()
            return false
        end
    end

    local function onTouchEnded(touch, event)

    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)

    local bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
    bg:setContentSize(size)
    bg:setPosition(cc.p(size.width / 2, size.height / 2))
    self:addChild(bg)

    local titleBG = cc.Sprite:create("image/ui/img/bg/bg_174.png")
    titleBG:setPosition(cc.p(size.width / 2, size.height - 5))
    self:addChild(titleBG)

    local title = cc.Sprite:create("image/ui/img/btn/btn_1173.png")
    title:setPosition(cc.p(size.width / 2, size.height - 5))
    self:addChild(title, 1)


    local formData = self.formData
    local nameList = formData:getAllNames()

	local function scrollViewDidScroll(view)
    end

    local function scrollViewDidZoom(view)
    end

    local function tableCellTouched(table, cell)
    end

    local function cellSizeForTable(table,idx)
        return 160, 580
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()
        else
            cell:removeAllChildren()
        end

        local size = cc.size(500, 160)
        local name = nameList[idx + 1]
        local desc = formData:getFormDesc(name)
        local icon = formData:getIcon(name)

        local formIcon = cc.Sprite:create(icon)
        formIcon:setPosition(cc.p(50, size.height / 2))
        formIcon:setScale(2)
        cell:addChild(formIcon, 1)

        local labelName = Common.finalFont("【" .. name .. "】", 0, 0, 25, cc.c3b(unpack(desc.color)), 0)
        labelName:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
        labelName:setDimensions(size.width, size.height / 2)
        labelName:setPosition(cc.p(110, 90))
        labelName:setAnchorPoint(cc.p(0, 0.5))
        cell:addChild(labelName)

        local richTextCond = ccui.RichText:create()
        richTextCond:ignoreContentAdaptWithSize(false)
        richTextCond:setContentSize(cc.size(420, 60))
        richTextCond:setPosition(cc.p(size.width / 2 + 80, 70))
        cell:addChild(richTextCond)

        richTextCond:pushBackElement(ccui.RichElementText:create(1, cc.c3b(239, 209, 158), 255, "激活条件:", BaseConfig.fontname, 20))
        richTextCond:pushBackElement(ccui.RichElementText:create(2, cc.c3b(unpack(desc.color)), 255, desc.condition[1], BaseConfig.fontname, 20))
        richTextCond:pushBackElement(ccui.RichElementText:create(3, cc.c3b(255, 255, 255), 255, desc.condition[2], BaseConfig.fontname, 20))
        richTextCond:pushBackElement(ccui.RichElementText:create(5, cc.c3b(255, 255, 255), 255, desc.condition[3], BaseConfig.fontname, 20))

        local richTextEffect = ccui.RichText:create()
        richTextEffect:ignoreContentAdaptWithSize(false)
        richTextEffect:setContentSize(cc.size(420, 40))
        richTextEffect:setPosition(cc.p(size.width / 2 + 80, 35))
        cell:addChild(richTextEffect)

        richTextEffect:pushBackElement(ccui.RichElementText:create(1, cc.c3b(239, 209, 158), 255, "加成效果:", BaseConfig.fontname, 20))
        richTextEffect:pushBackElement(ccui.RichElementText:create(2, cc.c3b(255, 255, 255), 255, desc.effect[1], BaseConfig.fontname, 20))
        richTextEffect:pushBackElement(ccui.RichElementText:create(2, cc.c3b(255, 255, 255), 255, "  ", BaseConfig.fontname, 20))
        richTextEffect:pushBackElement(ccui.RichElementText:create(3, cc.c3b(239, 209, 158), 255, desc.effect[2], BaseConfig.fontname, 20))

        return cell
    end

    local function numberOfCellsInTableView(table)
        return #nameList
    end

    local tableView = cc.TableView:create(cc.size(580, 350))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(10, 20))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)

    tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom,cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()

    self:addChild(tableView)
end

return FormDescNode
