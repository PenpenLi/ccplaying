local FriendAllHeroLayer = class("FriendAllHeroLayer", BaseLayer)

local ZORDER = 2

local LAYERCOLORTAG = 1
local LEFTTAG = LAYERCOLORTAG + 1
local RIGHTTAG = LEFTTAG + 1
local OWNHERONODETAG = RIGHTTAG + 1

local ccSize = cc.size(863, 400)

function FriendAllHeroLayer:ctor(allHero, func)
    FriendAllHeroLayer.super.ctor(self)

    self.data.ownHeroSort = {}
    self.data.allHero = allHero

    if self.data.allHero then
        table.sort(self.data.allHero, Common.heroSort)
        for i=1,#self.data.allHero do
            local heroInfo = self.data.allHero[i]
            self.data.ownHeroSort[tostring(heroInfo.ID)] = i
        end
    end

    self.data.isChooseHero = false
    self.data.func = func

    self:createUI()

    self.listener = application:addEventListener(AppEvent.UI.Hero.UpdateHeroList, function(event)
        self.data.isChooseHero = false
    end)
end

function FriendAllHeroLayer:onClose()
    application:removeEventListener(self.listener)
    if self.data.func then
        self.data.func()
    end
    self:removeFromParent()
    self = nil
end

function FriendAllHeroLayer:createUI()
    local swallowLayer = Common.swallowLayer(SCREEN_WIDTH, SCREEN_HEIGHT, 0, 0)
    self:addChild(swallowLayer)

    local bg = cc.Sprite:create("image/ui/img/bg/bg_037.jpg")
    bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    self:addChild(bg)
    
    self.data.bgSize = cc.size(910, 580)
    self.controls.bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_111.png") 
    self.controls.bg:setContentSize(self.data.bgSize)
    self.controls.bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.47)
    self:addChild(self.controls.bg)

    local fringe = cc.Scale9Sprite:create("image/ui/img/bg/bg_112.png")
    fringe:setContentSize(self.data.bgSize)
    fringe:setPosition(self.data.bgSize.width * 0.5, self.data.bgSize.height * 0.5)
    self.controls.bg:addChild(fringe, ZORDER)

    local baiBG = cc.Scale9Sprite:create("image/ui/img/bg/bg_141.png") 
    baiBG:setContentSize(cc.size(896, 495))
    baiBG:setPosition(self.data.bgSize.width * 0.5, self.data.bgSize.height * 0.43)
    self.controls.bg:addChild(baiBG, ZORDER)

    local heiBG = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
    heiBG:setContentSize(cc.size(845, 452))
    heiBG:setPosition(self.data.bgSize.width * 0.5, self.data.bgSize.height * 0.43)
    self.controls.bg:addChild(heiBG, ZORDER)

    local quan = cc.Sprite:create("image/ui/img/btn/btn_609.png")
    quan:setPosition(self.data.bgSize.width * 0.5, self.data.bgSize.height * 0.45)
    self.controls.bg:addChild(quan, ZORDER)

    local currPageName = createMixSprite("image/ui/img/bg/bg_142.png", nil, "image/ui/img/btn/btn_617.png")
    currPageName:setTouchEnable(false)
    currPageName:setChildPos(0.52, 0.55)
    currPageName:setPosition(self.data.bgSize.width * 0.1, self.data.bgSize.height)
    self.controls.bg:addChild(currPageName, ZORDER)

    local tishi = Common.finalFont("小提示:查看时只显示4★以上星将", 1, 1, 25, cc.c3b(238,205,142), 1)
    tishi:setPosition(self.data.bgSize.width * 0.5, self.data.bgSize.height * 0.91)
    self.controls.bg:addChild(tishi, ZORDER)

    local viewPosX, viewPosY = 25, 50
    if (not self.data.allHero) or (#self.data.allHero == 0) then
        local warning  = cc.Node:create()
        warning:setPosition(self.data.bgSize.width * 0.5, self.data.bgSize.height * 0.5)
        self.controls.bg:addChild(warning, ZORDER)
        local spri = cc.Sprite:create("image/ui/img/btn/btn_989.png")
        spri:setPosition(-80, 0)
        warning:addChild(spri)
        local desc = Common.finalFont("没有四星以上星将", 1, 1, 22, cc.c3b(61, 131, 172))
        desc:setPosition(50, 0)
        warning:addChild(desc)
    else
        self.controls.tableView = self:createHeroView()
        self.controls.tableView:setPosition(viewPosX, viewPosY)
        self.controls.bg:addChild(self.controls.tableView, ZORDER)
    end

    local layer = Common.createClickLayer(ccSize.width, ccSize.height, viewPosX, viewPosY)
    self.controls.bg:addChild(layer, ZORDER)

    local btn_close = createMixSprite("image/ui/img/btn/btn_598.png")
    btn_close:setPosition(self.data.bgSize.width * 0.98, self.data.bgSize.height * 0.98)
    self.controls.bg:addChild(btn_close, ZORDER)
    btn_close:addTouchEventListener(function( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            self:onClose()
        end
    end)
end

function FriendAllHeroLayer:createHeroView()
    local widthConstant = ccSize.width
    local heightConstant = 130

    local function scrollViewDidScroll(view)
    end
    local function scrollViewDidZoom(view)
    end
    local function tableCellTouched(table,cell)
        CCLog("cell touched at index: ",cell:getIdx())
    end
    local function cellSizeForTable(table,idx) 
        return heightConstant,100
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        local isRepeatCell = false
        --[[ 更新左右节点中的星将面板信息 ]]
        local function updateHeroPanel(isLeftNode, node, heroInfo, layerColorSize)
            local ownNode = nil
            if node then
                ownNode = node:getChildByTag(OWNHERONODETAG)
            else
                return 
            end
            -- 更新星将面板中星将信息
            local function updateOwnOrUnownInfo(panelNode)
                if not panelNode then
                    panelNode = require("scene.main.hero.widget.HeroPanel").new(heroInfo, true)
                    panelNode:setTag(OWNHERONODETAG)
                    node:addChild(panelNode)
                end
                if isLeftNode then
                    panelNode:setPosition(layerColorSize.width * 0.272, layerColorSize.height * 0.5)
                else
                    panelNode:setPosition(layerColorSize.width * 0.728, layerColorSize.height * 0.5)
                end
                panelNode:setVisible(true)
                panelNode:setScale(1)
                panelNode:updateHeroInfo(heroInfo)
                panelNode:addTouchEventListener(function()
                    if not self.controls.tableView:isTouchMoved() then
                        if not self.data.isChooseHero then
                            self.data.isChooseHero = true
                            local heroSort = self.data.ownHeroSort[tostring(heroInfo.ID)]
                            local layer = require("scene.main.hero.FriendHeroMainLayer").new(heroSort, self.data.allHero)
                            local scene = cc.Director:getInstance():getRunningScene()
                            scene:addChild(layer)
                        end
                    end
                end)
                -- 播放放缩动作
                if (not isRepeatCell) and (idx < 4) then
                    panelNode:playAction(0.1)
                end

            end
            updateOwnOrUnownInfo(ownNode)
        end
        --[[ layerColor左边节点必定要显示 ]]
        local function refreshLeftNode(layerColor, heroInfo)
            local layerColorSize = layerColor:getContentSize()
            local node = layerColor:getChildByTag(LEFTTAG)
            if not node then
                node = cc.Node:create()
                node.isPlayAnim = true
                node:setTag(LEFTTAG)
                layerColor:addChild(node)
            end
            if node then
                node:setPosition(0, 0)
            end
            updateHeroPanel(true, node, heroInfo, layerColorSize)
        end
        --[[ layerColor右边节点可能隐藏 ]]
        local function refreshRightNode(layerColor, heroInfo, isShow)
            local layerColorSize = layerColor:getContentSize()
            local node = layerColor:getChildByTag(RIGHTTAG)
            if isShow then
                if not node then
                    node = cc.Node:create()
                    node.isPlayAnim = true
                    node:setTag(RIGHTTAG)
                    layerColor:addChild(node)
                end
                node:setPosition(0, 0)
                updateHeroPanel(false, node, heroInfo, layerColorSize)
            else
                if node then
                    node:setPosition(SCREEN_WIDTH * 2, SCREEN_HEIGHT * 2)
                end
            end
        end

        local function getLayout()
            heightConstant = 130
            local layerColor = cc.LayerColor:create(cc.c4b(255,255,0,0), widthConstant, heightConstant - 10)
            layerColor:setAnchorPoint(0, 0)
            layerColor:setTag(LAYERCOLORTAG)
            return layerColor
        end

        local layerColor = nil
        if nil == cell then
            cell = cc.TableViewCell:new()
            layerColor = getLayout()
            cell:addChild(layerColor)
        else
            isRepeatCell = true
            layerColor = cell:getChildByTag(LAYERCOLORTAG)
        end

        for i=idx * 2 + 1,(idx + 1) * 2 do
            local ownIdx = i
            if ownIdx <= (#self.data.allHero) then
                if (i % 2) == 1 then
                    refreshLeftNode(layerColor, self.data.allHero[ownIdx])
                else
                    refreshRightNode(layerColor, self.data.allHero[ownIdx], true)
                end
            else
                -- 占位
                refreshRightNode(layerColor, nil, false)
            end
        end
        return cell
    end

    local function numberOfCellsInTableView(table)
        self.data.ownLayoutRow = math.ceil((#self.data.allHero) / 2)
        self.data.splitInRow = self.data.ownLayoutRow
        self.data.totalRow = self.data.ownLayoutRow
        return self.data.totalRow
    end

    local tableView = cc.TableView:create(ccSize)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
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

return FriendAllHeroLayer
