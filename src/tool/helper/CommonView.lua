local TabView = class("TabView", function()
    local self = cc.Node:create()
    self.controls = {}
    self.handlers = {}
    self.data = {}
    return self
end)

local LAYERCOLORTAG = 1000
local LAYERBGTAG = LAYERCOLORTAG + 1
local sizeTab = {cc.size(100, 100), cc.size(88, 88), cc.size(60, 60)}

--[[
    ccSize -- view大小 
    posX, posY -- view坐标 
    goodsInfoTabs -- 需要显示的所有goodsItem集合
    numOneRow -- 一行显示的个数 
    marginWidth -- 列于列的间距 
    marginHeight -- 行与行的间距 
    getGoodsItemEvent -- 返回GoodsItem的方法，参数为GoodsInfo  (GoodsItem必须为GoodsInfoIcon类或其子类)
    touchEvent -- GoodsItem点击事件，参数为返回的GoodsItem
    isShowFirstInfo -- 是否显示第一个goodsItem信息
    sizeType -- goodsItem尺寸大小
]]
function TabView:ctor(ccSize, posX, posY, goodsInfoTabs,numOneRow, marginWidth, marginHeight, getGoodsItemEvent, touchEvent, isShowFirstInfo, sizeType)
    self.data.ccSize = ccSize
    self.data.posX, self.data.posY =  posX, posY
    self.data.goodsInfoTabs = goodsInfoTabs
    self.data.numOneRow = numOneRow
    self.data.goodsWidth = marginWidth
    self.data.goodsHight = marginHeight
    self.data.itemFunc = getGoodsItemEvent
    self.data.updateFunc = touchEvent
    self.data.isShowFirstInfo = isShowFirstInfo
    self.data.sizeType = sizeType

    self.data.itemSize = sizeTab[sizeType]
    self.data.rowCount = math.floor(self.data.ccSize.height / self.data.itemSize.height)
    self.data.isRefreshCell = true
    self.data.isTouchEnabled = true
    self.data.previousGoodsItem = {}
    -- 统计可视区域内的行数
    self.data.isTotalRow = true
    self.data.rowOneView = 0

    self.view = self:createView()
    self:addChild(self.view)
    -- table创建完后就不再统计
    self.data.isTotalRow = false
end

function TabView:playAction(node, time)
    node:setScale(0.01)
    local normalScale = self.data.scaleValue

    local delay = cc.DelayTime:create(time)
    local scale1 = cc.ScaleTo:create(0.2, normalScale * 1.2)
    local scale2 = cc.ScaleTo:create(0.1, normalScale * 0.8)
    local scale3 = cc.ScaleTo:create(0.05, normalScale * 1.1)
    local scale4 = cc.ScaleTo:create(0.03, normalScale)

    node:runAction(cc.Sequence:create(delay, scale1, scale2, scale3, scale4))
end

function TabView:createView()
    local function scrollViewDidScroll(view)
        if self.data.isTouchEnabled then
            view:setBounceable(true)
            self.controls.scrollBarBG:setOpacity(255)
            self.controls.scrollBar:setOpacity(255)
            self.controls.scrollBarBG:stopAllActions()
            self.controls.scrollBar:stopAllActions()
            self.controls.scrollBarBG:runAction(cc.Sequence:create(cc.FadeOut:create(2)))
            self.controls.scrollBar:runAction(cc.Sequence:create(cc.FadeOut:create(2)))
            
            local totalHeight = self.data.barHeightest - view:getContentSize().height
            local addHeight = self.data.scrollDistance * (1 - (view:getContentOffset().y / totalHeight))

            if addHeight < self.data.scrollDistance and addHeight > 0 then
                self.controls.scrollBar:setPositionY(self.data.posY + self.data.barHeightest - addHeight)
            elseif addHeight > self.data.scrollDistance then
                -- 在滑到最低边时
                local outDistance = view:getContentOffset().y
                -- 压缩的长度/当前长度 等于 超出的距离/容器的高度
                local tempHeight = outDistance * self.data.currBarHeight / self.data.ccSize.height
                -- 条放大到最长的比值
                local scaleLongestValue = self.data.barHeightest / self.data.barHeight
                -- 当前条压缩后长度
                local currCompressHeight = self.data.currBarHeight * (1 - tempHeight / self.data.currBarHeight)
                -- 压缩后长度与最长长度的比值
                local scaleCompressValue = currCompressHeight / self.data.barHeightest
                self.controls.scrollBar:setScaleY(scaleLongestValue * scaleCompressValue)
                self.controls.scrollBar:setPositionY(self.data.posY + self.data.currBarHeight - tempHeight)
            elseif addHeight < 0 then
                -- 在滑到最高边时
                local outDistance = -view:getContentOffset().y + totalHeight
                local tempHeight = outDistance * self.data.currBarHeight / self.data.ccSize.height
                local scaleLongestValue = self.data.barHeightest / self.data.barHeight
                local currCompressHeight = self.data.currBarHeight * (1 - tempHeight / self.data.currBarHeight)
                local scaleCompressValue = currCompressHeight / self.data.barHeightest
                self.controls.scrollBar:setScaleY(scaleLongestValue * scaleCompressValue)
                self.controls.scrollBar:setPositionY(self.data.posY + self.data.barHeightest)
            end
        else
            view:setBounceable(false)
        end
    end

    local function cellSizeForTable(table,idx) 
        return self.data.goodsHight, 100
    end

    local function tableCellAtIndex(tableview, idx)
        local cell = tableview:dequeueCell()
        if (idx == 0) and (self.data.isRefreshCell) then
            self.data.isRefreshCell = false
            cell = nil
        end

        if self.data.isTotalRow then
            self.data.rowOneView = idx + 1
        end

        local function itemEvent(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                if not tableview:isTouchMoved() then
                    sender:setChooseBorderVisible(true)
                    if self.data.previousGoodsItem.item then
                        if self.data.previousGoodsItem.item ~= sender then
                            self.data.previousGoodsItem.item:setChooseBorderVisible(false)
                        end
                    end
                    self.data.previousGoodsItem.item = sender
                    self.data.previousGoodsItem.id = sender.number

                    if self.data.updateFunc then
                        self.data.updateFunc(sender)
                    end
                end
            end
        end

        local function createGoodsItem(goodsInfo, i, tag)
            local goodsItem = self.data.itemFunc(goodsInfo)
            self.data.scaleValue = goodsItem:getScale()
            local size = goodsItem:getContentSize()
            goodsItem:setPosition(( (i - 1) % self.data.numOneRow) * self.data.goodsWidth + size.width * 0.52,(self.data.goodsHight - 10) - size.height * 0.5)
            goodsItem:setTag(tag)
            goodsItem.number = i
            goodsItem:addTouchEventListener(itemEvent)

            local number = (i - idx * self.data.numOneRow)
            local goodsTotal = (#self.data.goodsInfoTabs)
            if not self.data.isPlayAction then
                self:playAction(goodsItem, number * 0.03)
            end

            if goodsTotal >= (self.data.rowCount * self.data.numOneRow) then
                if i >= (self.data.rowCount * self.data.numOneRow) then
                    self.data.isPlayAction = true
                end
            else
                if i >= goodsTotal then
                    self.data.isPlayAction = true
                end
            end
            return goodsItem
        end

        local function getLayer()
            local layerColor = cc.LayerColor:create(cc.c4b(255,255,255,0), self.data.ccSize.width - 10, self.data.goodsHight - 10)
            layerColor:setAnchorPoint(0 , 0)
            layerColor:setPosition(5 , 5)
            layerColor:setTag(LAYERCOLORTAG)

            for i= idx * self.data.numOneRow + 1,(idx + 1) * self.data.numOneRow do
                local bg = cc.Scale9Sprite:create("image/ui/img/btn/btn_412.png")   
                bg:setContentSize(self.data.itemSize)
                bg:setTag((i - idx * self.data.numOneRow) * 10000)
                bg:setPosition(( (i - 1) % self.data.numOneRow) * self.data.goodsWidth + self.data.itemSize.width * 0.52,layerColor:getContentSize().height - self.data.itemSize.height * 0.5)
                layerColor:addChild(bg)  

                if i <= (#self.data.goodsInfoTabs) then
                    local goodsItem = createGoodsItem(self.data.goodsInfoTabs[i], i, i - idx * self.data.numOneRow)
                    layerColor:addChild(goodsItem)
                    if self.data.isShowFirstInfo then
                        if i == 1 then
                            goodsItem:setChooseBorderVisible(true)
                            self.data.previousGoodsItem.item = goodsItem
                            self.data.previousGoodsItem.id = goodsItem.number
                            if self.data.updateFunc then
                                self.data.updateFunc(goodsItem)
                            end
                        end
                    end
                    bg:setVisible(false)
                else
                    bg:setVisible(true)
                end

                -- 一个数据都没有但是要显示第一个的情况
                if 0 == (#self.data.goodsInfoTabs) then
                    self.data.isPlayAction = true
                    if self.data.isShowFirstInfo then
                        if self.data.updateFunc then
                            self.data.updateFunc(nil)
                        end
                    end
                end
            end
            return layerColor
        end

        if nil == cell then
            cell = cc.TableViewCell:new()
            cell.idx = idx
            cell:addChild(getLayer())
        else
            local layerColor = cell:getChildByTag(LAYERCOLORTAG)
            for i= idx * self.data.numOneRow + 1,(idx + 1) * self.data.numOneRow do
                local goodsItem = layerColor:getChildByTag(i - idx * self.data.numOneRow)
                local bg = layerColor:getChildByTag((i - idx * self.data.numOneRow) * 10000)
                if i <= (#self.data.goodsInfoTabs) then
                    if goodsItem then
                        goodsItem:setScale(self.data.scaleValue)
                        goodsItem:setChooseBorderVisible(false)
                        if self.data.previousGoodsItem.id == i then
                            goodsItem:setChooseBorderVisible(true)
                            self.data.previousGoodsItem.item = goodsItem
                        end
                        goodsItem:setGoodsInfo(self.data.goodsInfoTabs[i])
                        goodsItem:setNum()
                        goodsItem.number = i
                        goodsItem:addTouchEventListener(itemEvent)
                    else
                        local goodsItem = createGoodsItem(self.data.goodsInfoTabs[i], i, i - idx * self.data.numOneRow)
                        layerColor:addChild(goodsItem)
                    end
                    bg:setVisible(false)
                else
                    if goodsItem then
                        goodsItem:setScale(0.001)
                    end
                    bg:setVisible(true)
                end
            end
        end

        return cell
    end

    local function numberOfCellsInTableView(table)
        local totalNum = math.ceil((#self.data.goodsInfoTabs) / self.data.numOneRow)
        local function setScrollBarSize()
            local viewHeight = totalNum * self.data.goodsHight
            local sizeHeight = self.data.ccSize.height
            if viewHeight > sizeHeight then
                self.data.isTouchEnabled = true
                local ratioValue = sizeHeight / viewHeight
                self.data.currBarHeight = self.data.barHeightest * ratioValue
                --先将条放大到最长，再进行比值缩小
                self.controls.scrollBar:setScaleY(sizeHeight / self.data.barHeight * ratioValue) 
                self.data.scrollDistance = self.data.barHeightest - self.data.currBarHeight
            else
                self.data.isTouchEnabled = false
                self.controls.scrollBarBG:setOpacity(0)
                self.controls.scrollBar:setOpacity(0)
                self.data.currBarHeight = self.data.barHeightest
                self.controls.scrollBar:setScaleY(self.data.currBarHeight / self.data.barHeight)
                self.data.scrollDistance = 0
            end
        end
        
        if self.controls.scrollBar then
            if self.data.isRefreshCell then
                setScrollBarSize()
                self.controls.scrollBar:setPosition(self.data.posX, self.data.posY + self.data.barHeightest)
            end
        else
            self.data.barHeightest = self.data.ccSize.height -- 条的最长长度

            self.controls.scrollBarBG = cc.Sprite:create("image/ui/img/btn/btn_354.png")
            self.controls.scrollBarBG:setScaleY(self.data.ccSize.height / self.controls.scrollBarBG:getContentSize().height)
            self.controls.scrollBarBG:setAnchorPoint(0.5, 1)
            self.controls.scrollBarBG:setPosition(self.data.posX, self.data.posY + self.data.barHeightest)
            self:addChild(self.controls.scrollBarBG)

            self.controls.scrollBar = cc.Sprite:create("image/ui/img/btn/btn_353.png")
            self.data.barHeight = self.controls.scrollBar:getContentSize().height
            self.controls.scrollBar:setAnchorPoint(0.5, 1)
            self.controls.scrollBar:setPosition(self.data.posX, self.data.posY + self.data.barHeightest)
            setScrollBarSize()
            self:addChild(self.controls.scrollBar)
        end
        return (totalNum > self.data.rowCount) and totalNum or self.data.rowCount
    end

    local tableView = cc.TableView:create(self.data.ccSize)

    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(self.data.posX, self.data.posY))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:registerScriptHandler(scrollViewDidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:reloadData()

    return tableView
end

function TabView:updateView(goodsTabs)
    self.data.goodsInfoTabs = goodsTabs or self.data.goodsInfoTabs
    self.data.previousGoodsItem = {}
    self.data.isRefreshCell = true
    self.view:reloadData()
end

return TabView