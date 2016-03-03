local TaskLayer = class("TaskLayer", BaseLayer)
local ColorLabel = require("tool.helper.ColorLabel")

local bgZOrder = 2
local btnZOrder = bgZOrder + 1

local LAYERCOLORTAG = 10
local TASKPANELTAG = 100

local TASKPANEL = 1
local ACHIEVEMENTPANEL = TASKPANEL + 1

function TaskLayer:ctor(taskInfoTabs, achievementInfoTabs)
	self.data.taskInfoTabs = taskInfoTabs
	self.data.achievementInfoTabs = achievementInfoTabs

	self.data.currTaskID = nil
	self.data.currTaskType = nil
	self.data.currPanel = TASKPANEL

    self:updateTask()
    self:updateAchievement()
    self:createUI()
end

function TaskLayer:onEnter()
	if self.data.currTaskID then
		if TASKPANEL == self.data.currPanel then
			self:QueryTaskStatus(self.data.currTaskID)
		elseif ACHIEVEMENTPANEL == self.data.currPanel then
			self:QueryStatus(self.data.currTaskType, self.data.currTaskID)
		end
	end
    self:addListener()
end

function TaskLayer:onEnterTransitionFinish( )
    Common.OpenSystemLayer({3})
    TaskLayer.super.onEnterTransitionFinish(self)
end

function TaskLayer:onExit()
	for _,listener in pairs(self.listeners) do
        application:removeEventListener(listener)
    end
end

function TaskLayer:addListener()
    self.listeners = {}
	local listener = application:addEventListener(AppEvent.UI.Task.GetCurrTaskID, function(event)
        local result = event.data
        local taskID = result.TaskID
        local taskType = result.TaskType
        local isRefurbishView = result.IsRefurbish
        self.data.currTaskID = taskID
        self.data.currTaskType = taskType
        if isRefurbishView then
        	if TASKPANEL == self.data.currPanel then
        		self:QueryTaskStatus(self.data.currTaskID)
        	elseif ACHIEVEMENTPANEL == self.data.currPanel then
        		self:QueryStatus(self.data.currTaskType, self.data.currTaskID)
        	end
        end
    end)
    table.insert(self.listeners, listener)
    local listener = application:addEventListener(AppEvent.UI.Task.DrawAward, function(event)
        local result = event.data
        local taskID = result.TaskID
        local awardInfo = result.Award
        local taskInfo = result.TaskInfo

		if TASKPANEL == self.data.currPanel then
    		for k,v in pairs(self.data.taskInfoTabs) do
				if v.ID == taskID then
					table.remove(self.data.taskInfoTabs, k)
					v = nil
					break
				end
			end
			self:updateTask()

            if next(self.data.taskInfoTabs) then
                self.controls.finishTaskAlert:setVisible(false)
            else
                self.controls.finishTaskAlert:setVisible(true)
            end
    	elseif ACHIEVEMENTPANEL == self.data.currPanel then
            self.controls.finishTaskAlert:setVisible(false)
    		for k,v in pairs(self.data.achievementInfoTabs) do
				if v.ID == taskID then
					table.remove(self.data.achievementInfoTabs, k)
					v = nil
					break
				end
			end
			if 0 ~= taskInfo.ID then
				table.insert(self.data.achievementInfoTabs, taskInfo)
			end
			self:updateAchievement()
    	end
		local alertShow = require("scene.main.ReceiveGoods").new(awardInfo, "image/ui/img/btn/btn_815.png")
        self:addChild(alertShow, btnZOrder)
    end)
    table.insert(self.listeners, listener)
end

function TaskLayer:createUI()
	local bg = cc.Sprite:create("image/ui/img/bg/bg_037.jpg")
    bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    self:addChild(bg)

    local pay = require("scene.main.PayListNode").new(GameCache.Avatar.PhyPower, GameCache.Avatar.MaxPhyPower,
        GameCache.Avatar.Endurance, GameCache.Avatar.MaxEndurance,
        GameCache.Avatar.Coin, GameCache.Avatar.Gold)
    local size = pay:getContentSize()
    pay:setPosition(SCREEN_WIDTH * 0.5 - size.width * 0.5 + 30, SCREEN_HEIGHT * 0.91)
    self:addChild(pay)
    
    self.controls.bg = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png") 
    self.controls.bg:setContentSize(cc.size(710, 500))
    self.controls.bg:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.48)
    self:addChild(self.controls.bg)
    local size = self.controls.bg:getContentSize()

    local tishi = createMixSprite("image/ui/img/bg/bg_174.png", nil, "image/ui/img/btn/btn_822.png")
    tishi:setTouchEnable(false)
    tishi:setLocalZOrder(bgZOrder)
    tishi:setPosition(size.width * 0.5, size.height * 0.97)
    self.controls.bg:addChild(tishi)

    self.controls.taskView = self:createTaskView(cc.size(size.width * 0.95, size.height * 0.85), TASKPANEL)
    self.controls.taskView:setPosition(30, 30)
    self.controls.bg:addChild(self.controls.taskView, bgZOrder)

    self.controls.achievementView = self:createTaskView(cc.size(size.width * 0.95, size.height * 0.85), ACHIEVEMENTPANEL)
    self.controls.achievementView:setPosition(30, 30)
    self.controls.bg:addChild(self.controls.achievementView, -bgZOrder)
    self.controls.achievementView:setScale(0)

    local swallowLayer = Common.createClickLayer(size.width * 0.95, size.height * 0.85, 20, 30)
    self.controls.bg:addChild(swallowLayer, btnZOrder)

    self.controls.tabBtns = {}
    function btnTouchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local name = sender:getName()
            for k,v in pairs(self.controls.tabBtns) do
                if name == v:getName() then
                    v:setTouchStatus()
                    v:setFontColor(cc.c3b(253, 230, 154))
                    v:setFontOutline(cc.c4b(46, 46, 46, 255), 1)
                else
                    v:setNormalStatus()
                    v:setFontColor(cc.c3b(177, 174, 170))
                    v:setFontOutline(cc.c4b(52, 58, 82, 255), 1)
                end
            end
            if name ==  "task" then
            	if self.data.currPanel ~= TASKPANEL then
            		self.controls.achievementView:setLocalZOrder(-bgZOrder)
    				self.controls.achievementView:setScale(0)

            		self:updateTask()
            		self.controls.taskView:setLocalZOrder(bgZOrder)
    				self.controls.taskView:setScale(1)
            	end
                tishi:setChildTexture("image/ui/img/btn/btn_822.png")
                self.data.currPanel = TASKPANEL

                if next(self.data.taskInfoTabs) then
                    self.controls.finishTaskAlert:setVisible(false)
                else
                    self.controls.finishTaskAlert:setVisible(true)
                end
            elseif name == "achievement" then
            	if self.data.currPanel ~= ACHIEVEMENTPANEL then
            		self.controls.taskView:setLocalZOrder(-bgZOrder)
    				self.controls.taskView:setScale(0)

    				self:updateAchievement()
            		self.controls.achievementView:setLocalZOrder(bgZOrder)
    				self.controls.achievementView:setScale(1)
            	end
                tishi:setChildTexture("image/ui/img/btn/btn_1171.png")
                self.data.currPanel = ACHIEVEMENTPANEL

                self.controls.achievementAlert:setVisible(false)
                self.controls.finishTaskAlert:setVisible(false)
            end
        end
    end

    local btn_task = createMixSprite("image/ui/img/btn/btn_642.png", "image/ui/img/btn/btn_641.png")
    btn_task:setAnchorPoint(1, 0.5)
    btn_task:setBgTouchAnchorPoint(1, 0.5)
    btn_task:setTouchStatus()
    btn_task:setCircleFont("任\n务" , 1, 1, 30, cc.c3b(253, 230, 154))
    btn_task:setFontPos(0.2, 0.5)
    btn_task:setFontOutline(cc.c4b(46, 46, 46, 255), 1)
    btn_task:setPosition(size.width * 0.01, size.height * 0.78)
    btn_task:setName("task")
    btn_task:addTouchEventListener(btnTouchEvent)
    self.controls.bg:addChild(btn_task, btnZOrder)
    table.insert(self.controls.tabBtns , btn_task)

    local btn_achievement = createMixSprite("image/ui/img/btn/btn_642.png", "image/ui/img/btn/btn_641.png")
    btn_achievement:setAnchorPoint(1, 0.5)
    btn_achievement:setBgTouchAnchorPoint(1, 0.5)
    btn_achievement:setCircleFont("成\n就" , 1, 1, 30, cc.c3b(177, 174, 170))
    btn_achievement:setFontOutline(cc.c4b(52, 58, 82, 255), 1)
    btn_achievement:setFontPos(0.2, 0.5)
    btn_achievement:setPosition(size.width * 0.01, size.height * 0.52)
    btn_achievement:setName("achievement")
    btn_achievement:addTouchEventListener(btnTouchEvent)
    self.controls.bg:addChild(btn_achievement, btnZOrder)
    table.insert(self.controls.tabBtns , btn_achievement)

    self.controls.achievementAlert = cc.Sprite:create("image/ui/img/btn/btn_398.png")
    self.controls.achievementAlert:setPosition(-size.width * 0.07, size.height * 0.6)
    self.controls.bg:addChild(self.controls.achievementAlert, btnZOrder)
    self.controls.achievementAlert:setVisible(self.data.isUnFinishAchievement)

    local btn_close = createMixSprite("image/ui/img/btn/btn_598.png")
    btn_close:setPosition(size.width * 0.98, size.height * 0.98)
    btn_close:setLocalZOrder(btnZOrder)
    self.controls.bg:addChild(btn_close)
    btn_close:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            cc.Director:getInstance():popScene()
        end
    end)

    self.controls.finishTaskAlert = cc.Node:create()
    self.controls.finishTaskAlert:setPosition(size.width * 0.5, size.height * 0.45)
    self.controls.bg:addChild(self.controls.finishTaskAlert, btnZOrder)
    local spri = cc.Sprite:create("image/ui/img/btn/btn_989.png")
    spri:setPosition(-90, 0)
    self.controls.finishTaskAlert:addChild(spri)
    local desc = Common.finalFont("恭喜！全部完成！", 1, 1, 22, cc.c3b(61, 131, 172))
    desc:setPosition(50, 0)
    self.controls.finishTaskAlert:addChild(desc)

    if next(self.data.taskInfoTabs) then
        self.controls.finishTaskAlert:setVisible(false)
    else
        self.controls.finishTaskAlert:setVisible(true)
    end
end

function TaskLayer:createTaskView(viewSize, viewType)
    local function cellSizeForTable(table,idx) 
        return viewSize.height * 0.31 + 8,viewSize.width
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        local isRepeatCell = false

        local function getLayout()
            local layerColor = cc.LayerColor:create(cc.c4b(255,255,0,0), viewSize.width, viewSize.height * 0.31)
            layerColor:setAnchorPoint(0, 0)
            layerColor:setTag(LAYERCOLORTAG)

            local panel = require("scene.main.task.widget.TaskPanel").new(viewType)
            local layerSize = layerColor:getContentSize()
            panel:setPosition(0, layerSize.height * 0.52)
            panel:setTag(TASKPANELTAG)
            layerColor:addChild(panel)
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

        local taskPanel = layerColor:getChildByTag(TASKPANELTAG)
        taskPanel:setScale(1)
        if viewType == TASKPANEL then
        	taskPanel:updatePanelInfo(self.data.taskInfoTabs[idx + 1])
        elseif viewType == ACHIEVEMENTPANEL then
        	taskPanel:updatePanelInfo(self.data.achievementInfoTabs[idx + 1])
        end
        if (not isRepeatCell) and (idx < 3) then
        	taskPanel:playOpenAction(idx * 0.12)
        end

        return cell
    end

    local function numberOfCellsInTableView(table)
        if viewType == TASKPANEL then
        	return (#self.data.taskInfoTabs)
        elseif viewType == ACHIEVEMENTPANEL then
        	return (#self.data.achievementInfoTabs)
        end
    end

    local tableView = cc.TableView:create(viewSize)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:reloadData()
    return tableView   
end

function TaskLayer:filtrateTask(taskInfoTabs)
	local finishTaskTabs = {}
	local unFinishTaskTabs = {}
	local tempTaskTabs = {}
    local isHaveUnFinish = false
	for k,v in pairs(taskInfoTabs) do
        if v.IsFinish then
            isHaveUnFinish = true
        	table.insert(finishTaskTabs, v)
        else
        	table.insert(unFinishTaskTabs, v)
        end
	end
    table.sort(finishTaskTabs, function(a, b)
        return a.ID < b.ID
    end)
    table.sort(unFinishTaskTabs, function(a, b)
        return a.ID < b.ID
    end)
	for k,v in pairs(finishTaskTabs) do
		table.insert(tempTaskTabs, v)
	end
	for k,v in pairs(unFinishTaskTabs) do
		table.insert(tempTaskTabs, v)
	end
	return {TaskTabs = tempTaskTabs, isUnFinish = isHaveUnFinish}
end

function TaskLayer:updateTask()
    local filtrateInfo = self:filtrateTask(self.data.taskInfoTabs)
	self.data.taskInfoTabs = filtrateInfo.TaskTabs
    self.data.isUnFinishTask = filtrateInfo.isUnFinish
	if self.controls.taskView then
		self.controls.taskView:reloadData()
	end
end

function TaskLayer:updateAchievement()
    local filtrateInfo = self:filtrateTask(self.data.achievementInfoTabs)
    self.data.achievementInfoTabs = filtrateInfo.TaskTabs
    self.data.isUnFinishAchievement = filtrateInfo.isUnFinish
    if self.controls.achievementAlert then
        self.controls.achievementAlert:setVisible(self.data.isUnFinishAchievement)
    end
	if self.controls.achievementView then
		self.controls.achievementView:reloadData()
	end
end

--[[
    查询任务
]]
function TaskLayer:QueryTaskStatus(task_id)
    rpc:call("Task.QueryTaskStatus", task_id, function(event)
        if event.status == Exceptions.Nil then
            local taskInfo = event.result
            if self.data then
                for k,v in pairs(self.data.taskInfoTabs) do
                    if v.ID == taskInfo.ID then
                        self.data.taskInfoTabs[k] = taskInfo
                        break
                    end
                end
                self:updateTask()
            end
        end
    end)
end

--[[
    查询成就
]]
function TaskLayer:QueryStatus(achievement_type, achievement_id)
    rpc:call("Achievement.QueryStatus", achievement_type, function(event)
        if event.status == Exceptions.Nil then
            local achievementInfo = event.result
            for k,v in pairs(self.data.achievementInfoTabs) do
				if v.ID == achievementInfo.ID then
					self.data.achievementInfoTabs[k] = achievementInfo
					break
				end
			end
			self:updateAchievement()
        end
    end)
end

return TaskLayer