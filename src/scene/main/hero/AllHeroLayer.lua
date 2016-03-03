local AllHeroLayer = class("AllHeroLayer", BaseLayer)
local ALL_VIEW = "全部"
local JIN_VIEW = "金"
local MU_VIEW = "木"
local SHUI_VIEW = "水"
local HUO_VIEW = "火"
local TU_VIEW = "土"
local ZORDER = 2

-- 在cell中加入layerColor
-- 在layerColor中加入左、右、提示这3个节点
-- 左右节点分别添加已拥有星将面板、未拥有星将面板这2个节点
local LAYERCOLORTAG = 10
local LEFTTAG = 1
local RIGHTTAG = LEFTTAG + 1
local SPLITTAG = RIGHTTAG + 1
local OWNHERONODETAG = 1
local UNOWNHERONODETAG = OWNHERONODETAG + 1

local ccSize = cc.size(863, 400)

function AllHeroLayer:ctor()
    AllHeroLayer.super.ctor(self)
    self.controls.chooseBtns = {}
    self.data.isChooseHero = false -- 防止连续点击星将弹出多个星将界面
    self.data.isGoodsSourceTips = false
    self.data.currView = ALL_VIEW

    self:getAllHero()
    self:createUI()

    self.listener = application:addEventListener(AppEvent.UI.Hero.UpdateHeroList, function(event)
        self.data.isChooseHero = false
        self:getAllHero()
        self.controls.tableView:reloadData()
        Common.OpenGuideLayer({7})
    end)

    BaseConfig.filtrateEquipConfig()
end

function AllHeroLayer:onEnter()
    if self.data.isGoodsSourceTips then
        self.data.isGoodsSourceTips = false
        self:getAllHero()
        self.controls.tableView:reloadData()
    end
end

function AllHeroLayer:onEnterTransitionFinish()
    AllHeroLayer.super.onEnterTransitionFinish(self)
    Common.OpenGuideLayer({6,7})
    Common.OpenSystemLayer( {2} )
end

function AllHeroLayer:onCleanup()
    BaseConfig.cleanFiltrateEquipConfig()
    application:removeEventListener(self.listener)
end

function AllHeroLayer:createUI()
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

    local btn_close = createMixSprite("image/ui/img/btn/btn_598.png")
    btn_close:setPosition(self.data.bgSize.width * 0.98, self.data.bgSize.height * 0.98)
    self.controls.bg:addChild(btn_close, 10)
    btn_close:addTouchEventListener(function( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            Common.CloseGuideLayer({7})
            cc.Director:getInstance():popScene()
        end
    end)

    self.data.titleBtnNames = {"全部", "金系", "木系", "水系", "火系", "土系"}
    local function btnTouchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local name = sender:getName()
            for k,v in pairs(self.controls.chooseBtns) do
                if name == v:getName() then
                    v:setTouchStatus()
                else
                    v:setNormalStatus()
                end
            end

            if name ==  self.data.titleBtnNames[1] then
                self.data.currView = ALL_VIEW
            elseif name ==  self.data.titleBtnNames[2] then
                self.data.currView = JIN_VIEW
            elseif name ==  self.data.titleBtnNames[3] then
                self.data.currView = MU_VIEW
            elseif name ==  self.data.titleBtnNames[4] then
                self.data.currView = SHUI_VIEW
            elseif name ==  self.data.titleBtnNames[5] then
                self.data.currView = HUO_VIEW
            elseif name ==  self.data.titleBtnNames[6] then
                self.data.currView = TU_VIEW
            end
            self:getAllHero()
            self.controls.tableView:reloadData()
        end
    end

    for i=1,#self.data.titleBtnNames do
        local button = createMixSprite("image/ui/img/btn/btn_606.png", "image/ui/img/btn/btn_605.png")
        button:setCircleFont(self.data.titleBtnNames[i] , 1, 1, 25, cc.c4b(226, 230, 242, 255), 1)
        button:setFontOutline(cc.c4b(27, 31, 49, 255), 2)
        button:setFontPos(0.5, 0.8)
        button:setAnchorPoint(0.5, 0)
        button:setBgTouchAnchorPoint(0.5, 0)
        local fontLab = button:getFont()
        fontLab:setAdditionalKerning(5)
        if i == 1 then
            button:setTouchStatus()
        else
            button:setNormalStatus()
        end
        button:setPosition(self.data.bgSize.width * 0.12 + (i - 1) * 135 , self.data.bgSize.height * 0.836)
        button:setName(self.data.titleBtnNames[i])
        button:addTouchEventListener(btnTouchEvent)
        self.controls.bg:addChild(button, ZORDER + 1)
        table.insert(self.controls.chooseBtns , button)
    end

    local viewPosX, viewPosY = 25, 50
    self.data.currView = ALL_VIEW
    self.controls.tableView = self:createHeroView()
    self.controls.tableView:setPosition(viewPosX, viewPosY)
    self.controls.bg:addChild(self.controls.tableView, ZORDER)

    local layer = Common.createClickLayer(ccSize.width, ccSize.height, viewPosX, viewPosY)
    self.controls.bg:addChild(layer, ZORDER)
end

function AllHeroLayer:createHeroView()
    local widthConstant = ccSize.width
    local heightConstant = 130
    local function loadPanelRes()
        self.controls.split_bg = cc.Node:create()
        self.controls.split_bg:retain()

        local split_bg = cc.Sprite:create("image/ui/img/btn/btn_608.png")
        local splitFont = Common.finalFont("集齐魂魄后可召唤下列星将", 1, 1, 20, cc.c3b(255, 220, 20), 2)
        local split_left = cc.Sprite:create("image/ui/img/btn/btn_604.png")
        local split_right = cc.Sprite:create("image/ui/img/btn/btn_604.png")
        split_right:setScaleX(-1)

        local bgSize = cc.size(833, 30)
        split_bg:setPosition(0, 0)
        split_left:setPosition(-bgSize.width * 0.35, 0)
        split_right:setPosition(bgSize.width * 0.35, 0)

        self.controls.split_bg:addChild(split_bg)
        self.controls.split_bg:addChild(splitFont)
        self.controls.split_bg:addChild(split_left)
        self.controls.split_bg:addChild(split_right)
    end
    loadPanelRes()

    local function isShowSplit()
        if self.data.splitInRow == self.data.ownLayoutRow then
            return false
        else
            return true
        end
    end

    local function scrollViewDidScroll(view)
    end
    local function scrollViewDidZoom(view)
    end
    local function tableCellTouched(table,cell)
        CCLog("cell touched at index: ",cell:getIdx())
    end
    local function cellSizeForTable(table,idx) 
        -- 根据不同的情况改变cell大小(主要分割图片的大小和星将面板大小不一致)，每次都得重新设置
        heightConstant = 130
        if isShowSplit() then
            if (idx + 1) == self.data.splitInRow then
                heightConstant = 50
            end
        end
        return heightConstant,100
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        local isRepeatCell = false
        --[[ 更新左右节点中的星将面板信息 ]]
        local function updateHeroPanel(isLeftNode, node, isShowOwn, isShowUnOwn, heroInfo, layerColorSize)
            local ownNode = nil
            local unOwnNode = nil
            if node then
                ownNode = node:getChildByTag(OWNHERONODETAG)
                unOwnNode = node:getChildByTag(UNOWNHERONODETAG)
            else
                return 
            end
            -- 更新星将面板中已拥有星将或未拥有星将信息
            local function updateOwnOrUnownInfo(isOwnNode, isShow, panelNode)
                if isShow then
                    if not panelNode then
                        if isOwnNode then
                            panelNode = require("scene.main.hero.widget.HeroPanel").new(heroInfo, true)
                            panelNode:setTag(OWNHERONODETAG)
                        else
                            panelNode = require("scene.main.hero.widget.HeroPanel").new(heroInfo, false)
                            panelNode:setTag(UNOWNHERONODETAG)
                        end
                        node:addChild(panelNode)
                    end
                    if isLeftNode then
                        panelNode:setPosition(layerColorSize.width * 0.272, layerColorSize.height * 0.5)
                    else
                        panelNode:setPosition(layerColorSize.width * 0.728, layerColorSize.height * 0.5)
                    end
                    panelNode:setVisible(true)
                    panelNode:setScale(1)
                    if isOwnNode then
                        panelNode:setCanUpgradeStar(Common.isShowHeroAlert(heroInfo))
                    end
                    panelNode:updateHeroInfo(heroInfo)
                    panelNode:addTouchEventListener(function()
                        if not self.controls.tableView:isTouchMoved() then
                            if not self.data.isChooseHero then
                                self.data.isChooseHero = true
                                Common.addTopSwallowLayer()
                                
                                if isOwnNode then
                                    Common.CloseGuideLayer({6,7})
                                    Common.CloseSystemLayer({2})
                                    local heroSort = self.data.ownHeroSort[tostring(heroInfo.ID)]
                                    local layer = require("scene.main.hero.HeroMainLayer").new(heroSort, self.data.allHero)
                                    local scene = cc.Director:getInstance():getRunningScene()
                                    scene:addChild(layer)
                                    
                                else
                                    if panelNode:isCanCompoundHero() then
                                        self:CompoundSoul(heroInfo.ID)
                                    else
                                        self.data.isGoodsSourceTips = true
                                        local layer = require("scene.main.hero.HeroInfoShowPanel").new(heroInfo.ID)
                                        local scene = cc.Director:getInstance():getRunningScene()
                                        scene:addChild(layer)
                                    end
                                end
                            end
                        end
                    end)
                    -- 播放放缩动作
                    if (not isRepeatCell) and (idx < 4) then
                        local number = idx * 2 + 1
                        if (idx + 1) >= self.data.splitInRow then
                            number = (idx - 1) * 2 + 1
                        end
                        local time = nil
                        if isLeftNode then
                            time = 0.1 * (number - 1)
                        else
                            time = 0.1 * number
                        end
                        panelNode:playAction(time)
                    end
                else
                    if panelNode then
                        panelNode:setPosition(SCREEN_WIDTH * 2, SCREEN_HEIGHT * 2)
                    end
                end
            end
            -- 更新已拥有星将面板
            updateOwnOrUnownInfo(true, isShowOwn, ownNode)
            -- 更新未拥有星将面板
            updateOwnOrUnownInfo(false, isShowUnOwn, unOwnNode)
        end
        --[[ layerColor左边节点必定要显示 ]]
        local function refreshLeftNode(layerColor, isShowOwn, isShowUnOwn, heroInfo)
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
            updateHeroPanel(true, node, isShowOwn, isShowUnOwn, heroInfo, layerColorSize)
        end
        --[[ layerColor右边节点可能隐藏 ]]
        local function refreshRightNode(layerColor, isShowOwn, isShowUnOwn, heroInfo, isShow)
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
            else
                if node then
                    node:setPosition(SCREEN_WIDTH * 2, SCREEN_HEIGHT * 2)
                end
            end
            updateHeroPanel(false, node, isShowOwn, isShowUnOwn, heroInfo, layerColorSize)
        end
        --[[ 显示拥有与未拥有分割图片 ]]
        local function refreshSplit(layerColor, isShow)
            local splitSpri = layerColor:getChildByTag(SPLITTAG)
            if isShow then
                if not splitSpri then
                    if self.controls.split_bg:getParent() then
                        self.controls.split_bg:removeFromParent()
                    end
                    self.controls.split_bg:setTag(SPLITTAG)
                    self.controls.split_bg:setPosition(table:getContentSize().width * 0.5, heightConstant * 0.4)
                    layerColor:addChild(self.controls.split_bg)
                end
                local leftNode = layerColor:getChildByTag(LEFTTAG)
                if leftNode then
                    leftNode:setPosition(SCREEN_WIDTH * 2, SCREEN_HEIGHT * 2)
                end
                local rightNode = layerColor:getChildByTag(RIGHTTAG)
                if rightNode then
                    rightNode:setPosition(SCREEN_WIDTH * 2, SCREEN_HEIGHT * 2)
                end
            else
                if splitSpri then
                    splitSpri:removeFromParent()
                end
            end
        end

        local function getLayout()
            heightConstant = 130
            local isRefreshSplit = false
            if isShowSplit() then
                if (idx + 1) == self.data.splitInRow then
                    heightConstant = 50
                    isRefreshSplit = true
                end
            end
            local layerColor = cc.LayerColor:create(cc.c4b(255,255,0,0), widthConstant, heightConstant - 10)
            layerColor:setAnchorPoint(0, 0)
            layerColor:setTag(LAYERCOLORTAG)
            refreshSplit(layerColor, isRefreshSplit)
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
            heightConstant = 130
            layerColor:changeHeight(heightConstant - 10)
            if isShowSplit() then
                if (idx + 1) == self.data.splitInRow then
                    heightConstant = 50
                    layerColor:changeHeight(heightConstant - 10)
                    refreshSplit(layerColor, true)
                else
                    refreshSplit(layerColor, false)
                end
            else
                refreshSplit(layerColor, false)
            end
        end

        -- 可召唤星将和已拥有星将
        if (idx + 1) <= self.data.ownLayoutRow then
            for i=idx * 2 + 1,(idx + 1) * 2 do
                if i <= (#self.data.canSummonHero) then
                    -- 可召唤
                    if (i % 2) == 1 then
                        refreshLeftNode(layerColor, false, true, self.data.canSummonHero[i])
                    else
                        refreshRightNode(layerColor, false, true, self.data.canSummonHero[i], true)
                    end
                else
                    -- ownIdx 从索引为1开始获取已拥有的星将信息
                    local ownIdx = i - (#self.data.canSummonHero)
                    if ownIdx <= (#self.data.ownHero) then
                        -- 已拥有
                        if (i % 2) == 1 then
                            refreshLeftNode(layerColor, true, false, self.data.ownHero[ownIdx])
                        else
                            refreshRightNode(layerColor, true, false, self.data.ownHero[ownIdx], true)
                        end
                    else
                        -- 占位
                        refreshRightNode(layerColor, false, false, nil, false)
                    end
                end
            end
        end
        -- 未拥有星将
        if (idx + 1) > self.data.splitInRow then
            -- unOwnIdx 从索引为1开始获取未拥有的星将信息
            local unOwnIdx = idx - self.data.splitInRow
            for i=unOwnIdx * 2 + 1,(unOwnIdx + 1) * 2 do
                if i <= (#self.data.unOwnHero) then
                    if (i % 2) == 1 then
                        refreshLeftNode(layerColor, false, true, self.data.unOwnHero[i])
                    else
                        refreshRightNode(layerColor, false, true, self.data.unOwnHero[i], true)
                    end
                else
                    refreshRightNode(layerColor, false, false, nil, false)
                end
            end
        end
        return cell
    end

    local function numberOfCellsInTableView(table)
        --[[
            ownLayoutRow 已拥有星将所占行数
            unownLayoutRow 未拥有星将所占行数
            splitInRow 分隔提示图所在行
            totalRow 总共行数
        ]]
        self.data.ownLayoutRow = math.ceil(((#self.data.canSummonHero) + (#self.data.ownHero)) / 2)
        self.data.unownLayoutRow = math.ceil((#self.data.unOwnHero) / 2)
        local splitRow = 1
        self.data.splitInRow = self.data.ownLayoutRow + 1
        if 0 == self.data.unownLayoutRow then
            splitRow = 0
            self.data.splitInRow = self.data.ownLayoutRow
        end
        self.data.totalRow = self.data.ownLayoutRow + self.data.unownLayoutRow + splitRow
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
    if GameCache.NewbieGuide.State then
        tableView:setTouchEnabled(false)
    else
        tableView:setTouchEnabled(true)
    end
    return tableView   
end

function AllHeroLayer:getAllHero()
    self.data.allHero = {} -- 已拥有的所有星将
    self.data.ownHero = {} -- 按五行划分的已拥有星将
    self.data.unOwnHero = {}
    self.data.canSummonHero = {}
    self.data.ownHeroSort = {}

    local allHero = GameCache.GetAllHero()
    local allSoul = GameCache.GetAllSoul()

    for k,v in pairs(allHero) do
        table.insert(self.data.allHero, v)
    end

    local notShowHeroNum = 1005
    if self.data.currView == ALL_VIEW then
        self.data.ownHero = self.data.allHero
        --筛选出未拥有的星将
        for k,v in pairs(allSoul) do
            local heroConfig = BaseConfig.GetHero(v.ID, 0)
            if heroConfig.isopen then
                local isOwn = false
                for j,k in pairs(self.data.ownHero) do
                    if v.ID == k.ID then
                        isOwn = true
                        break
                    end
                end
                if not isOwn then
                    local needSoulNum = BaseConfig.GetHeroNeedSoulCount(BaseConfig.GetSoul(v.ID).starLevel)
                    if v.Num == 0 then
                        if v.ID > notShowHeroNum then
                            if v.Num >= needSoulNum then
                                table.insert(self.data.canSummonHero, v)
                            else
                                table.insert(self.data.unOwnHero, v)
                            end
                        end
                    else
                        if v.Num >= needSoulNum then
                            table.insert(self.data.canSummonHero, v)
                        else
                            table.insert(self.data.unOwnHero, v)
                        end
                    end
                end
            end
        end
    else
        local wxName = self.data.currView
        for k,v in pairs(self.data.allHero) do
            local heroConfig = BaseConfig.GetHero(v.ID, 0)
            if BaseConfig.WX_NAME[heroConfig.wx] == wxName then
                table.insert(self.data.ownHero, v)
            end
        end
        for k,v in pairs(allSoul) do
            local heroConfig = BaseConfig.GetHero(v.ID, 0)
            if heroConfig.isopen then
                local isOwn = false
                for k1,v1 in pairs(self.data.ownHero) do
                    if v1.ID == v.ID then
                        isOwn = true
                        break
                    end
                end
                if not isOwn then
                    local heroConfig = BaseConfig.GetHero(v.ID, 0)
                    if BaseConfig.WX_NAME[heroConfig.wx] == wxName then
                        local needSoulNum = BaseConfig.GetHeroNeedSoulCount(BaseConfig.GetSoul(v.ID).starLevel)
                        if v.Num == 0 then
                            if v.ID > notShowHeroNum then
                                if v.Num >= needSoulNum then
                                    table.insert(self.data.canSummonHero, v)
                                else
                                    table.insert(self.data.unOwnHero, v)
                                end
                            end
                        else
                            if v.Num >= needSoulNum then
                                table.insert(self.data.canSummonHero, v)
                            else
                                table.insert(self.data.unOwnHero, v)
                            end
                        end
                    end
                end
            end
        end
    end
    table.sort(self.data.allHero, Common.heroSort)
    table.sort(self.data.ownHero, Common.heroSort)
    table.sort(self.data.unOwnHero, handler(self, self.unOwnHeroSort))
    table.sort(self.data.canSummonHero, handler(self, self.unOwnHeroSort))
    for i=1,#self.data.allHero do
        local heroInfo = self.data.allHero[i]
        self.data.ownHeroSort[tostring(heroInfo.ID)] = i
    end
end

function AllHeroLayer:unOwnHeroSort(a, b)
    local aCurrNum = a.Num
    local aTotalNum = BaseConfig.GetHeroNeedSoulCount(BaseConfig.GetSoul(a.ID).starLevel)
    local bCurrNum = b.Num
    local bTotalNum = BaseConfig.GetHeroNeedSoulCount(BaseConfig.GetSoul(b.ID).starLevel)
    if (aCurrNum / aTotalNum) == (bCurrNum / bTotalNum) then
        return a.ID < b.ID
    else
        return (aCurrNum / aTotalNum) > (bCurrNum / bTotalNum)
    end
end

function AllHeroLayer:getHeroSort(heroID)
    return self.data.ownHeroSort[tostring(heroID)]
end

function AllHeroLayer:getHeroTabs()
    return self.data.allHero
end

--[[
    将魂合成星将
]]--
function AllHeroLayer:CompoundSoul(soulID)
    rpc:call("Soul.Compound", soulID, function(event)
        if event.status == Exceptions.Nil then
            local soulNum = event.result
            local starLevel = BaseConfig.GetSoul(soulID).starLevel
            local heroTab = GameCache.addNewHero(soulID, starLevel)
            local soulInfo = {}
            soulInfo.ID = soulID
            soulInfo.Num = soulNum
            GameCache.addSoul(soulInfo, true)
            self:getAllHero()
            self.controls.tableView:reloadData()

            local summonLayer = require("scene.main.gamble.SummonHero").new(heroTab, true)
            local scene = cc.Director:getInstance():getRunningScene()
            scene:addChild(summonLayer)
        end
        self.data.isChooseHero = false
    end)
end

return AllHeroLayer
