local LootRecordLayer = class("LootRecordLayer", BaseLayer)
local ColorLabel = require("tool.helper.ColorLabel")

local bgZOrder = 2

function LootRecordLayer:ctor(recordInfo)
    LootRecordLayer.super.ctor(self)
    self.data.recordInfo = recordInfo

    self:createUI()
end

function LootRecordLayer:createUI()
    local layerColor = cc.LayerColor:create(cc.c4b(0, 0, 0, 200), display.width, display.height)
    layerColor:setPosition(display.width/2 - layerColor:getContentSize().width / 2, 
                            display.height/2 - layerColor:getContentSize().height / 2)
    self:addChild(layerColor)
    
    self.controls.bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png") 
    self.controls.bg:setContentSize(cc.size(650, 470))
    self.controls.bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.46)
    self:addChild(self.controls.bg)
    local size = self.controls.bg:getContentSize()

    local timu = createMixSprite("image/ui/img/bg/bg_174.png", nil, "image/ui/img/btn/btn_874.png") 
    timu:setPosition(size.width * 0.5, size.height * 0.98)
    self.controls.bg:addChild(timu, bgZOrder)
    timu:setTouchEnable(false)

    local function createTable(size)
        local dateTag = 1
        local descTag = dateTag + 1
        local winTag = descTag + 1
        local lookTag = winTag + 1

        function cellSizeForTable(table,idx) 
            return 90, 100
        end
        function tableCellAtIndex(table, idx)
            local cell = table:dequeueCell()
            local recordInfo = self.data.recordInfo[(#self.data.recordInfo) - idx]

            local winSpri = nil
            local dateLab = nil
            local descLab = nil
            local btn_look = nil
            if nil == cell then
                cell = cc.TableViewCell:new()
                local bg = cc.Sprite:create("image/ui/img/bg/bg_173.png")
                local bgSize = bg:getContentSize()
                bg:setPosition(bgSize.width * 0.5, bgSize.height * 0.5)
                cell:addChild(bg)

                winSpri = cc.Sprite:create("image/ui/img/btn/btn_621.png")
                winSpri:setTag(winTag)
                winSpri:setPosition(bgSize.width * 0.12, bgSize.height * 0.5)
                cell:addChild(winSpri)

                dateLab = Common.finalFont("", bgSize.width * 0.8, bgSize.height * 0.5, 20, cc.c3b(45,41,91))
                dateLab:setTag(dateTag)
                cell:addChild(dateLab)

                descLab = ColorLabel.new("", 20, nil, true)
                descLab:setTag(descTag)
                descLab:setAnchorPoint(0, 1)
                descLab:setPosition(bgSize.width * 0.25, bgSize.height * 0.75)
                cell:addChild(descLab)

                btn_look = ccui.Button:create("image/ui/img/btn/btn_1084.png")
                btn_look:setTag(lookTag)
                btn_look:setPosition(bgSize.width * 0.93, bgSize.height * 0.5)
                cell:addChild(btn_look)
            else
                winSpri = cell:getChildByTag(winTag)
                dateLab = cell:getChildByTag(dateTag)
                descLab = cell:getChildByTag(descTag)
                btn_look = cell:getChildByTag(lookTag)
            end
            dateLab:setString(recordInfo.DateTime)
            local isWin = recordInfo.IsWin
            local treasureName = BaseConfig.GetTreasure(recordInfo.TreasureID, recordInfo.Seat).Name
            local winDesc = nil
            if recordInfo.IsWin then
                winSpri:setTexture("image/ui/img/btn/btn_621.png")
                winDesc = "[45,41,91]你击败了[=][114,42,1]"..recordInfo.EnemyName.."[=]"
            else
                winSpri:setTexture("image/ui/img/btn/btn_622.png")
                winDesc = "[114,42,1]"..recordInfo.EnemyName.."[=][45,41,91]击败了你[=]"
            end
            local atkDesc = nil
            if recordInfo.IsAtk then
                if recordInfo.IsGetFrag then
                    atkDesc = "[42,87,124]\n夺走"..treasureName.."成功[=]"
                else
                    atkDesc = "[42,87,124]\n夺走"..treasureName.."失败[=]"
                end
            else
                if recordInfo.IsGetFrag then
                    atkDesc = "[42,87,124]\n守护"..treasureName.."失败[=]"
                else
                    atkDesc = "[42,87,124]\n守护"..treasureName.."成功[=]"
                end
            end
            descLab:setString(winDesc..atkDesc)
            btn_look:addTouchEventListener(function(sender, eventType)
                if (eventType == ccui.TouchEventType.ended) and (not table:isTouchMoved()) then
                    CCLog("=====查看视频ID====", recordInfo.TreasureID)
                end
            end)

            return cell
        end

        function numberOfCellsInTableView(table)
           return (#self.data.recordInfo)
        end

        local tableView = cc.TableView:create(size)
        tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        tableView:setPosition(cc.p(20, 30))
        tableView:setDelegate()
        tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
        tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
        tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
        tableView:reloadData()
        return tableView
    end
    if self.data.recordInfo then
        self.controls.bg:addChild(createTable(cc.size(size.width * 0.98, size.height * 0.85)), bgZOrder)
    else
        self.controls.noReceiveAlert = cc.Node:create()
        self.controls.noReceiveAlert:setPosition(size.width * 0.46, size.height * 0.5)
        self.controls.bg:addChild(self.controls.noReceiveAlert, bgZOrder)
        local spri = cc.Sprite:create("image/ui/img/btn/btn_989.png")
        spri:setPosition(-40, 0)
        self.controls.noReceiveAlert:addChild(spri)
        local desc = Common.finalFont("暂无记录", 1, 1, 22, cc.c3b(61, 131, 172))
        desc:setPosition(60, 0)
        self.controls.noReceiveAlert:addChild(desc)
        if self.data.isHaveRecord then
            self.controls.noReceiveAlert:setScale(0)
        end
    end

    local function onTouchBegan(touch, event)
        return true
    end
    local function onTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        local startpos = target:convertToNodeSpace(touch:getStartLocation())
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if (not cc.rectContainsPoint(rect, startpos)) and (not cc.rectContainsPoint(rect, locationInNode)) then
            self:removeFromParent()
            self = nil
        end
    end
    local listener1 = cc.EventListenerTouchOneByOne:create()
    listener1:setSwallowTouches(true)
    listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener1:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, self.controls.bg)
end

--[[
    抢夺记录
]]--
function LootRecordLayer:RecordList(id)
    rpc:call("Loot.RecordList", {RID = id}, function(event)
        if event.status == Exceptions.Nil then
            self.data.recordList = event.result
        end
    end)
end

return LootRecordLayer




