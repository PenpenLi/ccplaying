local InstanceDailyLayer = class("InstanceDailyLayer", BaseLayer)
local ActivityPanel = require("scene.main.instanceDaily.widget.ActivityPanel")
local HeroManager = require("tool.helper.HeroAction")

function InstanceDailyLayer:ctor(info)
    self.data.dailyUseCountInfo = info
    self.data.openPanelIdx = {COINBOSSMODEL, EQUIPTOKENMODEL, FORGESTONEMODEL} -- 这里控制界面显示

    self.data.isOpenLimitPanel = false
    self:createFixedUI()
end

function InstanceDailyLayer:createFixedUI()
    local bg = cc.Sprite:create("image/ui/img/bg/bg_037.jpg")
    bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    self:addChild(bg)

    local bgSize = cc.size(946, 552)
    self.controls.bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
    self.controls.bg:setContentSize(bgSize)
    self.controls.bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.46)
    self:addChild(self.controls.bg)

    local title = createMixSprite("image/ui/img/bg/bg_174.png", nil, "image/ui/img/btn/btn_949.png")
    title:setTouchEnable(false)
    title:setPosition(bgSize.width * 0.5, bgSize.height * 0.98)
    self.controls.bg:addChild(title)

    local pay = require("scene.main.PayListNode").new(GameCache.Avatar.PhyPower, GameCache.Avatar.MaxPhyPower,
        GameCache.Avatar.Endurance, GameCache.Avatar.MaxEndurance,
        GameCache.Avatar.Coin, GameCache.Avatar.Gold)
    local size = pay:getContentSize()
    pay:setPosition(SCREEN_WIDTH*0.5 - size.width * 0.5, SCREEN_HEIGHT - 50)
    self:addChild(pay)

    local view = self:createPanelView(cc.size(900, 530))
    view:setPosition(25, 0)
    self.controls.bg:addChild(view)

    local btn_close = createMixSprite("image/ui/img/btn/btn_598.png")
    btn_close:setPosition(bgSize.width*0.96, bgSize.height*1.04)
    btn_close:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            cc.Director:getInstance():popScene()
        end
    end)
    self.controls.bg:addChild(btn_close)
end

function InstanceDailyLayer:createPanelView(viewSize)
    local viewWidth = nil
    local function cellSizeForTable(table,idx) 
        if self.data.isOpenLimitPanel then
            viewWidth = viewSize.width + 300
        else
            viewWidth = viewSize.width
            table:setTouchEnabled(false)
        end
        return viewSize.height,viewWidth
    end

    local function tableCellAtIndex(viewTable, idx)
        local cell = viewTable:dequeueCell()

        local function getPanel()
            self.data.panelTab = {}
            local initPosX = 150

            -- 如果有限时就改变initPosX值

            for i=1,3 do
                local panelInfo = {panelIdx = i, count = self.data.dailyUseCountInfo[i]}
                local panel = ActivityPanel.new(panelInfo)
                panel:setPosition(initPosX + (i - 1) * 300, viewSize.height * 0.5)
                cell:addChild(panel)
                self.data.panelTab[i] = panel
            end
        end

        if cell then
            cell:removeFromParent()
            cell = nil
        end
        cell = cc.TableViewCell:new()
        getPanel()
        return cell
    end

    local function numberOfCellsInTableView(table)
       return 1
    end

    local tableView = cc.TableView:create(viewSize)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:reloadData()
    return tableView    
end

function InstanceDailyLayer:onEnterTransitionFinish( )
    Common.OpenSystemLayer({9})
    InstanceDailyLayer.super.onEnterTransitionFinish(self)

end

return InstanceDailyLayer