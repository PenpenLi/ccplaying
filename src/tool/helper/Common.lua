local Common = {}

local function createFont(ttfPath, text , x , y, size, color, outline)
    x , y = x or 0 , y or 0
    size = size or 20
    color = color or cc.c3b(255, 255, 255 )
    outline = outline or false
    local label = cc.Label:createWithTTF(text, ttfPath, size)
    label:setPosition(x , y)
    label:setColor( color)
    if outline then
        label:enableOutline(cc.c4b(0,0,0,255), outline)
    end

    label.playChangeAction = function(self)
        self:stopAllActions()
        self:setScale(1)
        local scale1 = cc.ScaleTo:create(0.2, 1.8)
        local scale2 = cc.ScaleTo:create(0.05, 1)
        self:runAction(cc.Sequence:create(scale1, scale2))
    end

    return label
end

function Common.finalFont(text , x , y, size, color, outline)
    return createFont("fonts/DFYuanW7-GBK.ttf", text , x , y, size, color, outline)
end

-- 系统
function Common.systemFont(text, x , y, size, color, outline)
    x , y = x or 0 , y or 0
    size = size or 20
    color = color or cc.c3b(255, 255, 255 )
    outline = outline or false
    local label = cc.Label:createWithSystemFont(text, BaseConfig.fontname, size)
    label:setPosition(x , y)
    label:setColor( color)
    if outline then
        label:enableOutline(cc.c4b(0,0,0,255), outline)
    end
    return label
end

function Common.CreateStoryLayer(storyid, callback)
    local story = "scene.story.Story"..storyid
    local success, Layer = pcall(require, story)

    if success then
        local layer = Layer.new(callback)
        return layer
    else
        callback()
        return nil
    end
end

-- 新手指引
function Common.OpenGuideLayer( steps )
    local steptable = steps or {}
    for i=1,#steptable do
        if GameCache.NewbieGuide.Step == steptable[i] then
            Common._isGuideOpen = true

            application:dispatchCustomEvent(AppEvent.UI.NewbieGuide.OpenGuide, {})
        end
    end
end

function Common.ResetGuideLayer( data )
    local step = data or {}
    if GameCache.NewbieGuide.Step == step.big then
        CCLog(GameCache.NewbieGuide.Step)
        application:dispatchCustomEvent(AppEvent.UI.NewbieGuide.ResetGuide, {jump = step.small})
    end
end

function Common.SaveGuideLayer(  )
    application:dispatchCustomEvent(AppEvent.UI.NewbieGuide.SaveGuide, {})
end

function Common.CloseGuideLayer( steps )
    local steptable = steps or {}
    for i=1,#steptable do
        if GameCache.NewbieGuide.Step == steptable[i] then
            Common._isGuideOpen = false

            application:dispatchCustomEvent(AppEvent.UI.NewbieGuide.CloseGuide, {})
        end
    end
end


-- 系统开放指引
function Common.OpenSystemLayer( steps )
    local steptable = steps or {}
    for i=1,#steptable do
        if GameCache.OpenSystem.Step == steptable[i] then
            application:dispatchCustomEvent(AppEvent.UI.NewbieGuide.OpenSystem, {})
        end
    end
end

function Common.CloseSystemLayer( steps )
    local steptable = steps or {}
    for i=1,#steptable do
        if GameCache.OpenSystem.Step == steptable[i] then
            application:dispatchCustomEvent(AppEvent.UI.NewbieGuide.CloseSystem, {})
        end
    end
end

--[[
获取地图节点是否锁住
--]]
function Common.isInstanceNodeLock( nodeid, difficulty )
    if  not GameCache.InstNode[nodeid..","..difficulty] then
        return true
    end
    return not GameCache.InstNode[nodeid..","..difficulty].NodeUnlock
end

--[[
章节名
--]]
function Common.getInstanceName( nodeid, difficulty )
    local node = BaseConfig.GetInstanceNode(nodeid, difficulty)
    local chapterid = node.ChapterID

    if difficulty == 1 then
        local easylist = BaseConfig.GetInstanceChapter(chapterid).NodeList
        for i=1,#easylist do
            if nodeid == easylist[i] then
                return "第"..chapterid.."季","第"..i.."集","普通"
            end
        end
    elseif difficulty == 2 then
        local hardlist = BaseConfig.GetInstanceChapter(chapterid).HardNodeList
        for i=1,#hardlist do
            if nodeid == hardlist[i] then
                return "第"..chapterid.."季","第"..index.."集","困难"
            end
        end
    end
    return nil
end

function Common.calculateRating( score )
    if score <= 0 then
        return 0
    elseif score < 70 then
        return 1
    elseif score < 80 then
        return 2
    elseif score < 90 then
        return 3
    elseif score < 100 then
        return 4
    else
        return 5
    end
end

--[[
当前地图进度
--]]
function Common.getInstanceCurrNode(diff)
    local diff = diff or 1
       return GameCache.InstProgress[diff]
end

--[[
获取章节节点数
--]]
function Common.getInstanceCount( chapterid, diff )
    local chapter = BaseConfig.GetInstanceChapter(chapterid)
    local difficulty = diff or 1
    if difficulty == 1 then
        return #chapter.NodeList
    elseif difficulty == 2 then
        return #chapter.HardNodeList
    end
    
    return 0
end

--[[
    创建飘飞的字
]]
function Common.flyFont(text, x, y, delay)
    local font = Common.finalFont(text, x, y, nil, cc.c3b(0, 255, 0), 2)
    font:setOpacity(0)
    local func1 = cc.CallFunc:create(function()
        font:setOpacity(255)
    end)
    local scale1 = cc.ScaleTo:create(0.1,1.6)
    local scale2 = cc.ScaleTo:create(0.07,1)
    local scale3 = cc.ScaleTo:create(0.07,1.3)
    local scale4 = cc.ScaleTo:create(0.06,1)
    local moveby = cc.MoveBy:create(0.8,cc.p(0, 150))
    local delay1 = cc.DelayTime:create(0.5)  
    local fadeout = cc.FadeOut:create(0.3) 
    local seqFade = cc.Sequence:create(delay1, fadeout)  
    local seqScale = cc.Sequence:create(scale1, scale2, scale3, scale4, delay1)  
    local spAct = cc.Spawn:create(seqFade, seqScale, moveby)
    local remove = cc.RemoveSelf:create()

    local delay = cc.DelayTime:create(delay)  
    font:runAction(cc.Sequence:create(delay, func1, spAct, remove))
    return font
end

--[[
    str 需要换行的字符串
    len 一行需要显示的字数

    row 总行数
    ret 换行后的字符串
]]
function Common.StringLinefeed(str, len)
    if "" == str then
        return 0, str
    end
    local pos = 1
    local row = 1
    local ret = ""
    while true do
        if (pos + len) > utf8.len(str) then
            ret = ret..utf8.sub(str, pos, utf8.len(str))
            break
        else
            ret = ret..utf8.sub(str, pos, pos + len - 1).."\n"
            pos = pos + len
            row = row + 1
        end
    end
    return row, ret
end

--[[
    上万、上亿的数值都转换成文字
    超过99999的值转化成万
    超过999999999的值转化成亿
]]
local PRICE_CHANGE_VALUE_1 = 99999
local PRICE_CHANGE_VALUE_2 = 999999999
local TEN_THOUSAND = 10000
local ONE_HUNDRED_MILLION = 100000000
function Common.numConvert(number)
    local resultNumber = ""
    if number > PRICE_CHANGE_VALUE_1 then
        if number > PRICE_CHANGE_VALUE_2 then
            local num = math.floor(number/ONE_HUNDRED_MILLION)
            resultNumber = num.."亿"
        else
            local num = math.floor(number/TEN_THOUSAND)
            resultNumber = num.."万"
        end
    else
        resultNumber = number
    end
    return resultNumber
end

--[[
    倒计时格式
]]
function Common.timeFormat(time)
    if time < 0 then
        return string.format("%02d:%02d", 0, 0)
    end
    local hour = math.floor(time  / 3600)
    local minute = math.floor((time  - hour * 3600) / 60)
    local sec = time  % 60
    if hour > 24 then
        local day = math.floor(hour / 24)
        return "大于"..day.."天"
    else
        if hour == 0 then
            return string.format("%02d:%02d", minute, sec)
        end
        return string.format("%02d:%02d:%02d", hour, minute, sec)
    end
end

--[[
    创建一个可点击区域
]]--
function Common.createClickLayer(width, height, posX, posY)
    local layer = cc.LayerColor:create(cc.c4b(255,255,0,0), width, height)
    layer:setPosition(posX, posY)

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

    local listener1 = cc.EventListenerTouchOneByOne:create()
    listener1:setSwallowTouches(true)
    listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    local eventDispatcher = layer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, layer)
    return layer
end

--[[
    创建一个屏蔽区域
]]
function Common.swallowLayer(width, height, posX, posY)
    local layer = cc.LayerColor:create(cc.c4b(0,0,0,0), width, height)
    layer:setPosition(posX, posY)

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(function()
        return true
    end,cc.Handler.EVENT_TOUCH_BEGAN )
    local eventDispatcher = layer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)
    return layer
end

local SWALLOWTAG = 10000
function Common.addTopSwallowLayer()
    local swallowLayer = Common.swallowLayer(SCREEN_WIDTH, SCREEN_HEIGHT, 0, 0)
    local runningScene = cc.Director:getInstance():getRunningScene()
    runningScene:addChild(swallowLayer, SWALLOWTAG)
    swallowLayer:setTag(SWALLOWTAG)
end

function Common.removeTopSwallowLayer()
    local runningScene = cc.Director:getInstance():getRunningScene()
    local swallowLayer = runningScene:getChildByTag(SWALLOWTAG)
    if swallowLayer then
        swallowLayer:removeFromParent()
        swallowLayer = nil
    end
end

--[[
    复制table
]]
function Common.copyTab(t)
    local tab = {}
    for k, v in pairs(t or {}) do
        if type(v) ~= "table" then
            tab[k] = v
        else
            tab[k] = Common.copyTab(v)
        end
    end
    return tab
end

--[[
    星将排序
]]
function Common.heroSort(a, b)
    local aConfig = BaseConfig.GetHero(a.ID, a.StarLevel)
    local bConfig = BaseConfig.GetHero(b.ID, b.StarLevel)
    if a.TFP == b.TFP then
        if a.Level == b.Level then
            if a.StarLevel == b.StarLevel then
                if aConfig.talent == bConfig.talent then
                    if aConfig.wx == bConfig.wx then
                        return a.ID > b.ID
                    else
                        return aConfig.wx < bConfig.wx
                    end
                else
                    return aConfig.talent > bConfig.talent
                end
            else
                return a.StarLevel > b.StarLevel
            end
        else
            return a.Level > b.Level
        end
    else
        return a.TFP > b.TFP
    end
end

--[[
    装备排序
]]
function Common.equipSort(a, b)
    local aConfig = BaseConfig.GetEquip(a.ID, a.StarLevel)
    local bConfig = BaseConfig.GetEquip(b.ID, b.StarLevel)
    if aConfig.type == bConfig.type then
        if aConfig.starLevel == bConfig.starLevel then
            if aConfig.talent == bConfig.talent then
                return a.ID < b.ID
            else
                return aConfig.talent > bConfig.talent
            end
        else
            return aConfig.starLevel > bConfig.starLevel
        end
    else
        return aConfig.type < bConfig.type
    end
end

--[[
    道具排序
]]
function Common.propsSort(a, b)
    local aConfig = BaseConfig.GetProps(a.ID)
    local bConfig = BaseConfig.GetProps(b.ID)
    if aConfig.type == bConfig.type then
        if aConfig.quality == bConfig.quality then
            return a.ID < b.ID
        else
            return aConfig.quality < bConfig.quality
        end
    else
        return aConfig.type < bConfig.type
    end
end

--[[
    时装排序
]]--
function Common.skinSort(a, b)
    local aConfig = BaseConfig.GetEquip(a.ID, 0)
    local bConfig = BaseConfig.GetEquip(b.ID, 0)
    local aStarLevel = BaseConfig.GetFragToEquip(a.ID).starLevel
    local bStarLevel = BaseConfig.GetFragToEquip(b.ID).starLevel
    if aConfig.type == bConfig.type then
        if aStarLevel == bStarLevel then
            return a.ID < b.ID
        else
            return aStarLevel > bStarLevel
        end
    else
        return aConfig.type < bConfig.type
    end
end

--[[
    返回物品描述
]]
function Common.getGoodsDesc(goodsTabs, symbol)
    local goodsConfigInfo = nil
    local returnStr = ""
    for k,v in pairs(goodsTabs) do
        if v.Type == 1 then
            goodsConfigInfo = BaseConfig.GetHero(v.ID, 0)
            returnStr = returnStr..goodsConfigInfo.name.." x "..v.Num
        elseif v.Type == 2 then
            goodsConfigInfo = BaseConfig.GetHero(v.ID, 0)
            returnStr = returnStr..goodsConfigInfo.name.."魂魄 x "..v.Num
        elseif v.Type == 3 then
            returnStr = returnStr.."仙女 x "..v.Num
        elseif v.Type == 4 then
            if v.ID == 1001 then
                returnStr = returnStr.."元宝 x "..v.Num
            elseif v.ID == 1002 then
                returnStr = returnStr.."银币 x "..v.Num
            elseif v.ID == 1003 then
                returnStr = returnStr.."竞技场积分 x "..v.Num
            elseif v.ID == 1004 then
                returnStr = returnStr.."帮贡 x "..v.Num
            elseif v.ID == 1005 then
                returnStr = returnStr.."侠义值 x "..v.Num
            elseif v.ID == 1006 then
                returnStr = returnStr.."魂玉 x "..v.Num
            elseif v.ID == 1007 then
                returnStr = returnStr.."爬塔积分 x "..v.Num
            elseif v.ID == 1008 then
                returnStr = returnStr.."技能点 x "..v.Num
            elseif v.ID == 1009 then
                returnStr = returnStr.."仙女技能点 x "..v.Num 
            end
        elseif v.Type == 5 then
            goodsConfigInfo = BaseConfig.GetEquip(v.ID, 0)
            returnStr = returnStr..goodsConfigInfo.name.." x "..v.Num
        elseif v.Type == 6 then
            goodsConfigInfo = BaseConfig.GetProps(v.ID)
            returnStr = returnStr..goodsConfigInfo.name.." x "..v.Num
        elseif v.Type == 10 then
            goodsConfigInfo = BaseConfig.GetSkin(v.ID)
            returnStr = returnStr..goodsConfigInfo.Name.." x "..v.Num
        end

        if k ~= (#goodsTabs) then
            returnStr = returnStr..symbol
        end
    end    

    return returnStr
end

--[[
    装备额外属性描述
]]
function Common.getEquipExtraDesc(config, level, descColor, valueColor)
    local equipConfig = config
    local equipLevel = level
    local descColor = descColor or "[255,255,255]"
    local valueColor = valueColor or "[255,220,20]"
    local extraDesc = {}
    if equipConfig.type == 1 then
        if equipConfig.atkSpeedRatio ~= 0 then
            local result = math.floor(equipConfig.atkSpeedRatio / 100)
            local descInfo = descColor.."攻击速度+[=]"..valueColor..result.."%[=]"
            table.insert(extraDesc, descInfo)
        end 
        if equipConfig.rpSkillUp ~= 0 then
            local descInfo = descColor.."怒气技能等级+[=]"..valueColor..equipConfig.rpSkillUp.."[=]"
            table.insert(extraDesc, descInfo)
        end
        if equipConfig.atkRatio ~= 0 then
            local result = (equipConfig.atkRatio + equipConfig.atkRatioGrow * (equipLevel - 1)) / 100
            result = string.format("%.1f", result)
            local descInfo = descColor.."攻击+[=]"..valueColor..result.."%[=]"
            table.insert(extraDesc, descInfo)
        end
    elseif equipConfig.type == 2 then
        if equipConfig.treatedAddition ~= 0 then
            local result = math.floor(equipConfig.treatedAddition / 100)
            local descInfo = descColor.."被治疗效果+[=]"..valueColor..result.."%[=]"
            table.insert(extraDesc, descInfo)
        end
        if equipConfig.skillReduction ~= 0 then
            local result = math.floor(equipConfig.skillReduction / 100)
            local descInfo = descColor.."减少技能伤害+[=]"..valueColor..result.."%[=]"
            table.insert(extraDesc, descInfo)
        end
        if equipConfig.defRatio ~= 0 then
            local result = (equipConfig.defRatio + equipConfig.defRatioGrow * (equipLevel - 1)) / 100
            result = string.format("%.1f", result)
            local descInfo = descColor.."防御+[=]"..valueColor..result.."%[=]"
            table.insert(extraDesc, descInfo)
        end
    elseif equipConfig.type == 3 then
        if equipConfig.atkHpRecover ~= 0 then
            local result = math.floor(equipConfig.atkHpRecover / 100)
            local descInfo = descColor.."普通攻击回血+[=]"..valueColor..result.."%[=]"
            table.insert(extraDesc, descInfo)
        end
        if equipConfig.tfSkillUp ~= 0 then
            local descInfo = descColor.."天赋技能等级+[=]"..valueColor..equipConfig.tfSkillUp.."[=]"
            table.insert(extraDesc, descInfo)
        end
        if equipConfig.mpRatio ~= 0 then
            local result = (equipConfig.mpRatio + equipConfig.mpRatioGrow * (equipLevel - 1)) / 100
            result = string.format("%.1f", result)
            local descInfo = descColor.."法力+[=]"..valueColor..result.."%[=]"
            table.insert(extraDesc, descInfo)
        end
    elseif equipConfig.type == 4 then
        if equipConfig.hpRecover ~= 0 then
            local descInfo = descColor.."生命回复+[=]"..valueColor..equipConfig.hpRecover.."[=]"
            table.insert(extraDesc, descInfo)
        end
        if equipConfig.norSkillUp ~= 0 then
            local descInfo = descColor.."普通技能等级+[=]"..valueColor..equipConfig.norSkillUp.."[=]"
            table.insert(extraDesc, descInfo)
        end
        if equipConfig.hpRatio ~= 0 then
            local result = (equipConfig.hpRatio + equipConfig.hpRatioGrow * (equipLevel - 1)) / 100
            result = string.format("%.1f", result)
            local descInfo = descColor.."生命+[=]"..valueColor..result.."%[=]"
            table.insert(extraDesc, descInfo)
        end
    elseif equipConfig.type == 5 then
        if equipConfig.atkRatio ~= 0 then
            local result = (equipConfig.atkRatio + equipConfig.atkRatioGrow * (equipLevel - 1)) / 100
            result = string.format("%.1f", result)
            local descInfo = descColor.."攻击+[=]"..valueColor..result.."%[=]"
            table.insert(extraDesc, descInfo)
        end
        if equipConfig.mpRatio ~= 0 then
            local result = (equipConfig.mpRatio + equipConfig.mpRatioGrow * (equipLevel - 1)) / 100
            result = string.format("%.1f", result)
            local descInfo = descColor.."法力+[=]"..valueColor..result.."%[=]"
            table.insert(extraDesc, descInfo)
        end

    elseif equipConfig.type == 6 then
        if equipConfig.defRatio ~= 0 then
            local result = (equipConfig.defRatio + equipConfig.defRatioGrow * (equipLevel - 1)) / 100
            result = string.format("%.1f", result)
            local descInfo = descColor.."防御+[=]"..valueColor..result.."%[=]"
            table.insert(extraDesc, descInfo)
        end
        if equipConfig.hpRatio ~= 0 then
            local result = (equipConfig.hpRatio + equipConfig.hpRatioGrow * (equipLevel - 1)) / 100
            result = string.format("%.1f", result)
            local descInfo = descColor.."生命+[=]"..valueColor..result.."%[=]"
            table.insert(extraDesc, descInfo)
        end
    end
    return extraDesc
end

-- 元宝不足提示
local function alertPanel()
    local panel = cc.Scale9Sprite:create("image/ui/img/bg/bg_139.png")
    panel:setContentSize(cc.size(520, 250))
    panel:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    local panelSize = panel:getContentSize()

    local title = cc.Sprite:create("image/ui/img/bg/bg_174.png")
    title:setPosition(panelSize.width * 0.5, panelSize.height * 0.95)
    panel:addChild(title)
    local dian = cc.Sprite:create("image/ui/img/btn/btn_996.png")
    dian:setPosition(panelSize.width * 0.5, panelSize.height * 0.95)
    panel:addChild(dian)

    local desc = Common.finalFont("亲亲,元宝不够了哟～现在就去充值吗？", 1, 1, 20, nil, 1)
    desc:setPosition(panelSize.width * 0.5, panelSize.height * 0.7)
    desc:setAnchorPoint(0.5, 1)
    panel:addChild(desc)

     local function buttonFunc(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local name = sender:getName()
            if name == "sure" then
                application:pushScene("main.recharge.RechargeScene") 
            end
            panel:removeFromParent()
            panel = nil
        end
    end
    local cancel = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(130, 56))
    cancel:setButtonBounce(false)
    cancel:setCircleFont("暂时不充" , 1, 1, 25, cc.c3b(248, 216, 136))
    cancel:setName("cancel")
    cancel:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
    cancel:setPosition(panelSize.width * 0.3,panelSize.height * 0.28)
    panel:addChild(cancel)
    cancel:addTouchEventListener(buttonFunc)
    local sure = createMixScale9Sprite("image/ui/img/btn/btn_593.png", nil, nil, cc.size(130, 56))
    sure:setButtonBounce(false)
    sure:setCircleFont("这就去充" , 1, 1, 25, cc.c3b(248, 216, 136))
    sure:setName("sure")
    sure:setFontOutline(cc.c4b(70, 50, 14, 255), 1)
    sure:setPosition(panelSize.width * 0.7,panelSize.height * 0.28)
    panel:addChild(sure)
    sure:addTouchEventListener(buttonFunc)

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
    local eventDispatcher = panel:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, panel)
    return panel
end
--[[
    花费货币
]]
function Common.isCostMoney(moneyType, value)
    if moneyType == 1001 then
        CCLog("------------------元宝")
        if value > GameCache.Avatar.Gold then
            local upgradePanel = alertPanel()
            local runningScene = cc.Director:getInstance():getRunningScene()
            runningScene:addChild(upgradePanel)
            return false
        else
            return true
        end
    elseif moneyType == 1002 then
        CCLog("------------------银币")
        if value > GameCache.Avatar.Coin then
            application:showFlashNotice("银币不足~!")
            return false
        else
            return true
        end
    elseif moneyType == 1003 then
        CCLog("------------------竞技场")
        if value > GameCache.Avatar.ArenaCredits then
            return false
        else
            return true
        end
    elseif moneyType == 1004 then
        CCLog("------------------帮贡")
        if value > GameCache.Avatar.LeagueDevote then
            application:showFlashNotice("帮贡不足~!")
            return false
        else
            return true
        end
    elseif moneyType == 1005 then
        CCLog("------------------侠义值")
        if value > GameCache.Avatar.Errantry then
            return false
        else
            return true
        end
    elseif moneyType == 1006 then
        CCLog("------------------精元")
        if value > GameCache.Avatar.EquipToken then
            return false
        else
            return true
        end
    elseif moneyType == 1007 then
        CCLog("------------------爬塔")
        if value > GameCache.Avatar.TowerCredits then
            return false
        else
            return true
        end
    elseif moneyType == 1008 then
        CCLog("------------------技能点")
        if value > GameCache.Avatar.SkillPoint then
            application:showFlashNotice("技能点不足~!")
            return false
        else
            return true
        end
    elseif moneyType == 1009 then
        CCLog("------------------仙女红心")
        if value > GameCache.Avatar.FairySkillPoint then
            application:showFlashNotice("仙女红心不足~!")
            return false
        else
            return true
        end
    elseif moneyType == 1010 then
        CCLog("------------------勋章")
        if value > GameCache.Avatar.Medal then
            return false
        else
            return true
        end
    end
end

--[[
    返回物品
]]
function Common.getGoods(goodsInfo, isReceive, sizeType)
    local scaleValue = BaseConfig.GOODS_BIGTYPE
    if sizeType == BaseConfig.GOODS_MIDDLETYPE then
        scaleValue = 0.88
    elseif sizeType == BaseConfig.GOODS_SMALLTYPE then
        scaleValue = 0.6
    elseif sizeType == BaseConfig.GOODS_LEASTTYPE then
        scaleValue = 0.25
    end
    if goodsInfo.Type == BaseConfig.GT_HERO then
        CCLog("==============星将")
        local goodsItem = GoodsInfoNode.new(BaseConfig.GOODS_HERO, goodsInfo, sizeType)
        goodsItem:setTips(true)
        if isReceive then
            GameCache.addNewHero(goodsInfo.ID, goodsInfo.StarLevel)
            local summonLayer = require("scene.main.gamble.SummonHero").new(goodsInfo, true)
            local scene = cc.Director:getInstance():getRunningScene()
            scene:addChild(summonLayer,3) -- 设置zorder，使之位于新手指引层之上
        end
        return goodsItem
    elseif goodsInfo.Type == BaseConfig.GT_SOUL then
        CCLog("==============魂石")
        local goodsItem = GoodsInfoNode.new(BaseConfig.GOODS_SOUL, goodsInfo, sizeType)
        goodsItem:setTips(true)
        goodsItem:setNum()
        if isReceive then
            GameCache.addSoul(goodsInfo)
            if goodsInfo.IsHeroToSoul then
                local summonLayer = require("scene.main.gamble.SummonHero").new(goodsInfo, false)
                local scene = cc.Director:getInstance():getRunningScene()
                scene:addChild(summonLayer,3)
            end
        end   
        return goodsItem
    elseif goodsInfo.Type == BaseConfig.GT_FAIRY then
        CCLog("==============仙女")
        local goodsItem = require("tool.helper.FairyIcon").new(goodsInfo, sizeType)
        goodsItem:setTips(true)

        if isReceive then
            local summonLayer = require("scene.main.gamble.SummonFairy").new(goodsInfo)
            local scene = cc.Director:getInstance():getRunningScene()
            scene:addChild(summonLayer)
        end
        return goodsItem
    elseif goodsInfo.Type == BaseConfig.GT_MONEY then
        CCLog("==============货币")
        local goodsItem = require("tool.helper.CurrencyIcon").new(goodsInfo, sizeType)
        goodsItem:setNum()
        goodsItem:setTips(true)
        return goodsItem
    elseif goodsInfo.Type == BaseConfig.GT_EQUIP then
        CCLog("============装备")
        if isReceive then
            GameCache.addEquip(goodsInfo.ID, goodsInfo.StarLevel, goodsInfo.Num)
        end
        local goodsItem = GoodsInfoNode.new(BaseConfig.GOODS_EQUIP, goodsInfo, sizeType)
        goodsItem:setNum()
        goodsItem:setTips(true)
        return goodsItem
    elseif goodsInfo.Type == BaseConfig.GT_PROPS then
        if isReceive then
            GameCache.addProps(goodsInfo)
        end
        local propsConfigInfo = BaseConfig.GetProps(goodsInfo.ID)
        local goodsItem = nil
        if (propsConfigInfo.type == 1) or (propsConfigInfo.type == 2) or  (propsConfigInfo.type == 4) then
            CCLog("============碎片")
            goodsItem = GoodsInfoNode.new(BaseConfig.GOODS_FRAG, goodsInfo, sizeType)
        else
            CCLog("============道具")
            goodsItem = GoodsInfoNode.new(BaseConfig.GOODS_PROPS, goodsInfo, sizeType)
        end
        goodsItem:setTips(true)
        goodsItem:setNum()
        return goodsItem
    elseif goodsInfo.Type == BaseConfig.GT_TREASURE_FRAG then
        CCLog("============宝物碎片")
        local goodsItem = GoodsInfoNode.new(BaseConfig.GOODS_FRAG, goodsInfo, sizeType)
        goodsItem:setTips(true)
        goodsItem:setNum()
        return goodsItem
    elseif goodsInfo.Type == BaseConfig.GT_HEROSKIN then
        CCLog("============时装")
        local goodsItem = GoodsInfoNode.new(BaseConfig.GOODS_SKIN, goodsInfo, sizeType)
        goodsItem:setNum()
        return goodsItem
    elseif goodsInfo.Type == BaseConfig.GT_AVATAR then
        CCLog("============体力")
        local goodsItem = nil
        if goodsInfo.ID == 1 then
            goodsItem = cc.Sprite:create("image/icon/props/exp.png")
        elseif goodsInfo.ID == 2 then
            goodsItem = cc.Sprite:create("image/icon/props/power.png")
        elseif goodsInfo.ID == 3 then
            goodsItem = cc.Sprite:create("image/icon/props/endurance.png")
        elseif goodsInfo.ID == 4 then
            goodsItem = cc.Sprite:create("image/icon/props/vip.png")
        end
        if goodsInfo.Num then
            local num = Common.finalFont(goodsInfo.Num, 0, 0, 18, nil, 1)
            num:setPosition(goodsItem:getContentSize().width * 0.95, 10) 
            num:setAnchorPoint(1, 0)
            num:setName("num")
            goodsItem:setScale(goodsItem:getScale() * scaleValue)
            num:setScale(1 / scaleValue)
            goodsItem:addChild(num)
        end
        return goodsItem
    elseif goodsInfo.Type == BaseConfig.GT_VALUE then
        local goodsItem = createMixSprite("image/icon/border/head_bg.png", nil, "image/icon/border/border_star_3.png")
        goodsItem:setTouchEnable(false)

        local sheng = Common.finalFont("X", -20, -15, 20, cc.c3b(255, 247, 0), 1)
        goodsItem:addChild(sheng)

        local num = cc.Label:createWithCharMap("image/ui/img/btn/btn_627.png", 44, 52,  string.byte("0"))
        num:setPosition(10, 0)
        num:setString(goodsInfo.ID)
        goodsItem:addChild(num)
        return goodsItem
    end
end

function Common.heroIconImgPath(_heroID)
    local path = string.format("image/icon/head/xj_%s.png", _heroID)
    if not cc.FileUtils:getInstance():isFileExist(path) then
        CCLog(string.format("file '%s' not exists, use default", path))
        path = "image/icon/head/xj_1000.png"
    end
    return path
end

--[[
    根据星将星级获得名字颜色、星星个数
]]
function Common.getHeroStarLevelColor(starLevel)
    local nameColor = cc.c3b(255,255,255)
    if starLevel < 1 then
        nameColor = cc.c3b(217,217,217)
    elseif starLevel < 3 then
        nameColor = cc.c3b(0,255,50)
    elseif starLevel < 5 then
        nameColor = cc.c3b(0,162,255)
    elseif starLevel < 8 then
        nameColor = cc.c3b(255,0,200)
    elseif starLevel < 12 then
        nameColor = cc.c3b(255,0,0)
    else
        nameColor = cc.c3b(255,102,0)
    end

    local starNum = 1
    if starLevel < 1 then
        starNum = 1
    elseif (starLevel < 3) then
        starNum = 2
    elseif (starLevel < 5) then
        starNum = 3
    elseif (starLevel < 8) then
        starNum = 4
    elseif (starLevel < 12) then
        starNum = 5
    else
        starNum = 6
    end

    local additionalTab = {"", "" ,"+1", "", "+1", "", "+1", "+2", "", "+1", "+2", "+3", ""}
    local additional = additionalTab[starLevel + 1]
    return {Color = nameColor, StarNum = starNum, Additional = additional}
end

--[[
    EnergyStep      int    // 元神阶段
    EnergyAttrNum   int    // 当前元神阶段属性点亮属性个数
]]
function Common.getAvatarAttr(EnergyStep, EnergyAttrNum)
    local energeAttrTab = {}
    -- for i=1,10 do
    --     energeAttrTab[i] = 0
    -- end
    for i=1,14 do
        energeAttrTab[i] = 0
    end

    local totalNum = (EnergyStep - 1) * 6 + EnergyAttrNum
    for i=1,totalNum do
        local energyConfig = BaseConfig.getEnergyInfo(i)
        local energyType = energyConfig.PropertyType
        local energyValue = energyConfig.PropertyValue
        energeAttrTab[energyType] = energeAttrTab[energyType] + energyValue
    end

    for i=1,(GameCache.Avatar.EnergyStep - 1) do
        local upgradeConfig = BaseConfig.getEnergyUpgrade(i)
        energeAttrTab[upgradeConfig.PropertyType] = energeAttrTab[upgradeConfig.PropertyType] + upgradeConfig.PropertyValue
    end
    return  energeAttrTab
end

-- 是否有可合成的星将
function Common.isCanCompoundHero()
    local allHero = GameCache.GetAllHero()
    local allSoul = GameCache.GetAllSoul()

    for k1,soulInfo in pairs(allSoul) do
        local heroConfig = BaseConfig.GetHero(soulInfo.ID, 0)
        if heroConfig.isopen then
            local isOwn = false
            for k2,heroInfo in pairs(allHero) do
                if soulInfo.ID == heroInfo.ID then
                    isOwn = true
                    break
                end
            end
            if not isOwn then
                local needSoulNum = BaseConfig.GetHeroNeedSoulCount(BaseConfig.GetSoul(soulInfo.ID).starLevel)
                if soulInfo.Num >= needSoulNum then
                    return true
                end
            end
        end
    end
    return false
end

-- 星将是否能升星
function Common.isHeroCanUpgradeStar(heroInfo)
    local SOULTYPE = 1
    local PROPSTYPE = SOULTYPE + 1
    local function getPropsNumByID(id, propsType)
        if propsType == SOULTYPE then
            local soulInfo = GameCache.GetSoul(id)
            if soulInfo then
                return soulInfo.Num
            else
                return 0
            end
        elseif propsType == PROPSTYPE then
            local propsInfo = GameCache.GetProps(id)
            if propsInfo then
                return propsInfo.Num
            else
                return 0
            end
        end
    end

    if heroInfo.StarLevel >= 12 then
        return false
    end
    local needSoulNum = BaseConfig.GetHeroUpstar(heroInfo.StarLevel + 1).SoulNum
    local needUpStarPillNum = BaseConfig.GetHeroUpstar(heroInfo.StarLevel + 1).PropsNum
    local needCoin = BaseConfig.GetHeroUpstar(heroInfo.StarLevel + 1).Coin
    if (getPropsNumByID(heroInfo.ID, SOULTYPE) >= needSoulNum) and 
        (getPropsNumByID(BaseConfig.upgradeStarPillID, PROPSTYPE) >= needUpStarPillNum) and
        (GameCache.Avatar.Coin >= needCoin) then
        return true
    else
        return false
    end
end

-- 是否有未穿戴的专属装备
function Common.isWearSpecialEquip(heroInfo)
    local heroConfigInfo = BaseConfig.GetHero(heroInfo.ID, heroInfo.StarLevel)
    local allEquip = GameCache.GetAllEquip()
    for k,v in pairs(allEquip) do
        local equipConfig = BaseConfig.GetEquip(v.ID, v.StarLevel)
        if 0 ~= (#equipConfig.heroList) then
            local isHave = false
            for k1,v1 in pairs(equipConfig.heroList) do
                if v1 == heroInfo.ID then
                    isHave = true
                end
            end
            if isHave then
                if equipConfig.type == BaseConfig.ET_ARM then
                    if heroConfigInfo.armType ~= equipConfig.subType then
                        break
                    end
                end
                if heroInfo.Equip[equipConfig.type].ID ~= v.ID then
                    return true
                end
            end
        end
    end
    return false
end

-- 是否可升级技能
function Common.isCanUpgradeSkill(heroInfo)
    if GameCache.Avatar.Level < BaseConfig.OpenSystemLevel.heroSkill then
        return false
    end

    local rpSkill = heroInfo.RPSkillLevel
    local maxRPSkill = heroInfo.MaxRPSkillLevel
    if rpSkill == maxRPSkill then
        return false
    end
    -- 升1级和升到顶级各所需的技能点数
    local rpSkillExp = heroInfo.RPSkillExp
    local needSkillPointToOne = BaseConfig.GetHeroRPSkillExp(rpSkill) - rpSkillExp
    local needSkillPointToMax = needSkillPointToOne
    for i=(rpSkill + 1),(maxRPSkill - 1) do
        local exp = BaseConfig.GetHeroRPSkillExp(i)
        needSkillPointToMax = needSkillPointToMax + exp
    end
    local haveSkillPoint = GameCache.Avatar.SkillPoint
    if needSkillPointToMax ~= 0 then
        if haveSkillPoint >= needSkillPointToOne then
            return true
        else
            return false
        end
    else
        return false
    end
end

-- 是否提示星将可升星或有未装备的专属装备
function Common.isShowHeroAlert(heroInfo)
    local isHero = Common.isHeroCanUpgradeStar(heroInfo)
    local isEquip = Common.isWearSpecialEquip(heroInfo)
    local isSkill = Common.isCanUpgradeSkill(heroInfo)
    if isHero or isEquip or isSkill then
        return true 
    end
    return false
end

-- 是否碎片可合成装备
function Common.isFragCompound(fragInfo)
    local compoundId = BaseConfig.GetProps(fragInfo.ID).useValue
    local fragToEquipConfig = BaseConfig.GetFragToEquip(compoundId)
    local compoundNum = fragToEquipConfig.num
    if fragInfo.Num >= compoundNum then
        return true
    else
        return false
    end
end

-- 截屏 -返回截图路径 (该方法不能及时返回，故暂时不能用)
local captureFileName = nil
function Common.captureScreen()
    local function afterCaptured(succeed, outputFile)
        if succeed then
            return outputFile
        else
            return nil
        end
    end
    
    if captureFileName then
        cc.Director:getInstance():getTextureCache():removeTextureForKey(captureFileName)
    end
    captureFileName = "CaptureScreen.png"
    cc.utils:captureScreen(afterCaptured, captureFileName)
end

function Common.playMusic(musicPath, loop)
    if BaseConfig.isPlayMusic then
        audio.playMusic(musicPath, loop)
    end
end

function Common.stopMusic(release)
    audio.stopMusic(release)
end

function Common.playSound(soundPath, loop)
    if BaseConfig.isPlaySound then
        return audio.playSound(soundPath, loop)
    end
end

function Common.stopAllSounds()
    audio.stopAllSounds()
end

function Common.stopSound(soundID)
    audio.stopSound(soundID)
end

function Common.stopBackgroundMusic()
    audio.stopMusic()
end

-- 界面中有消耗经验丹的地方所用的特效
function Common.eatPillEffect(parent, x, y)
    local x, y = x or 0, y or 0
    local palyTime = 0.2
    local scale = cc.ScaleTo:create(palyTime, 1.2)
    local fadeout = cc.FadeOut:create(palyTime)
    local spawn = cc.Spawn:create(scale, fadeout)
    local removeSelf = cc.RemoveSelf:create()
    local seq = cc.Sequence:create(spawn, removeSelf)
    local delay = cc.DelayTime:create(palyTime * 0.5)
    local effect = cc.Sprite:create("image/icon/border/border_selected.png")
    parent:addChild(effect)
    effect:setScale(0.92)
    effect:setPosition(x, y)
    effect:runAction(seq)
    effect = cc.Sprite:create("image/icon/border/border_selected.png")
    parent:addChild(effect)
    effect:setScale(0.92)
    effect:setPosition(x, y)
    effect:runAction(cc.Sequence:create(delay, seq:clone()))
end

function Common.jumpToScene(panelID, callFunc, jump2, jump3)
    local HeroListPanel = 101
    local HeroPanel = 102
    local FairyPanel = 103
    local FriendPanel = 104
    local EmailPanel = 105
    local EquipIntensifyPanel = 106
    local EnergyPanel = 107
    local SimpleMapPanel = 201
    local DifficultyMapPanel = 202
    local TowerPanel = 203
    local InstanceDailyPanel = 204
    local ArenaPanel = 301
    local TransportPanel = 302
    local LootPanel = 303
    local HomePanel = 304
    local MoneyPanel = 401
    local VipPanel = 402
    local GamblePanel = 403
    local PowerPanel = 404
    local EndurancePanel = 405
    local CoinTreePanel = 406
    local ActivityCenterLayer = 407

    if HeroListPanel == panelID then
        application:pushScene("main.hero.AllHeroScene")
    elseif HeroPanel == panelID then
        local currScene = require("scene.main.hero.AllHeroScene").new()
        cc.Director:getInstance():pushScene(currScene)
        local allHeroLayer = currScene:getChildByName("layer")
        local heroSort = allHeroLayer:getHeroSort(jump2)
        local allHero = allHeroLayer:getHeroTabs()
        if heroSort then
            local heroLayer = require("scene.main.hero.HeroMainLayer").new(heroSort, allHero)
            currScene:addChild(heroLayer)
            heroLayer:jumpToAppointButton(jump3)
        end
    elseif FairyPanel == panelID then
        rpc:call("Fairy.Info", {}, function(event)
            if (event.status == Exceptions.Nil) and (event.result) then
                GameCache.AllFairy = {}
                local result = event.result
                local allFairy = result.FairyList or {}
                for _, v in ipairs(allFairy) do
                    v.Name = BaseConfig.GetFairy(v.ID).Name
                end

                for _, v in ipairs(allFairy) do
                    GameCache.AllFairy[v.ID] = v
                end
                application:pushScene("main.fairy.FairyScene", result) 
            end
        end)
    elseif FriendPanel == panelID then
        application:pushScene("main.friend.FriendScene")
    elseif EmailPanel == panelID then
        rpc:call("Mail.MailList", nil, function(event)
            if event.status == Exceptions.Nil then
                local list = event.result or {}
                application:pushScene("main.email.EmailScene", list)
            end
        end)
    elseif EquipIntensifyPanel == panelID then
        local allHero = GameCache.GetAllHero()
        local isHaveEquip = false
        for k,v in pairs(allHero) do
            for i=1,6 do
                local equipInfo = v.Equip[i]
                if equipInfo.ID ~= 0 then
                    isHaveEquip = true
                    break
                end
            end
            if isHaveEquip then
                break
            end
        end
        if isHaveEquip then
            local currScene = require("scene.main.hero.EquipIntensifyScene").new()
            cc.Director:getInstance():pushScene(currScene)
            local layer = currScene:getChildByName("layer")
            layer:scrollToHeroByID(jump2, jump3)
        else
            application:showFlashNotice("没有星将穿戴有装备～！")
        end
    elseif EnergyPanel == panelID then
        rpc:call("Avatar.EnergyInfo", nil, function (event)
            if event.status == Exceptions.Nil then
                application:pushScene("main.energy.EnergyScene", event.result)
            end
        end)
    elseif SimpleMapPanel == panelID then
        application:pushScene("main.mapinstance.MapInstanceScene", jump2, 1)
    elseif DifficultyMapPanel == panelID then
        application:pushScene("main.mapinstance.MapInstanceScene", jump2, 2)
    elseif TowerPanel == panelID then
        rpc:call("Tower.Info", nil, function (event)
            if event.status == Exceptions.Nil and event.result ~= nil then
                application:pushScene("main.tower.TowerScene", event.result)
            end
        end)
    elseif InstanceDailyPanel == panelID then
        rpc:call("InstanceDaily.Info", nil, function(event)
            if event.status == Exceptions.Nil then
                local info = event.result
                application:pushScene("main.instanceDaily.InstanceDailyScene", info) 
            end
        end)
    elseif ArenaPanel == panelID then
        rpc:call("Arena.Info", nil, function (event)
            if event.status == Exceptions.Nil and event.result ~= nil then
                table.sort(event.result.List, function (a,b) return a.Rank < b.Rank end)
                application:pushScene("main.coliseum.ColiseumScene", event.result)
            end
        end) 
    elseif TransportPanel == panelID then
        application:pushScene("main.transport.TransportScene") 
    elseif LootPanel == panelID then
        local treasureTabs = nil
        local winInfo = nil
        rpc:call("Loot.Init", nil, function(event)
            if event.status == Exceptions.Nil then
                treasureTabs = event.result.FragList or {}
                winInfo = event.result.WinInfo or {}
                application:pushScene("main.loot.LootScene", treasureTabs, winInfo) 
            end
        end) 
    elseif HomePanel == panelID then
        rpc:call("Home.Info", nil, function (event)
            if event.status == Exceptions.Nil and event.result ~= nil then
                local homeInfo = event.result
                application:pushScene("main.home.HomeScene", homeInfo, true, GameCache.Avatar) 
                Common.CloseSystemLayer({8})
            end
        end)  
    elseif MoneyPanel == panelID then
        application:pushScene("main.recharge.RechargeScene") 
    elseif VipPanel == panelID then
        application:pushScene("main.recharge.RechargeScene") 
    elseif GamblePanel == panelID then
        local handler = function(event)
            if event.status == Exceptions.Nil and event.result ~= nil then                    
                local value = event.result
                local infoTab = {}
                local allInfo = {}
                infoTab[1] = allInfo
                local vipInfo = {}
                infoTab[2] = vipInfo
                local heroInfo = {}
                infoTab[3] = heroInfo
                local equipInfo = {}
                infoTab[4] = equipInfo
                allInfo.AllBuyFreeCount = value.AllBuyFreeCount
                allInfo.AllTotalFreeCount = value.AllTotalFreeCount
                allInfo.AllNextFreeTime = value.AllNextFreeTime
                allInfo.AllBuyCost = value.AllBuyCost
                vipInfo.VipWeekHot = value.VipWeekHot
                vipInfo.VipDailyHot = value.VipDailyHot
                vipInfo.VipBuyCost = value.VipBuyCost
                heroInfo.HeroNextFreeTime = value.HeroNextFreeTime
                heroInfo.HeroBuyCost = value.HeroBuyCost
                equipInfo.EquipNextFreeTime = value.EquipNextFreeTime
                equipInfo.EquipBuyCost = value.EquipBuyCost
                application:pushScene("main.gamble.GambleScene", infoTab) 
            end
        end
        rpc:call("Gamble.GetGambleInfo", nil, handler)
    elseif PowerPanel == panelID then
        require("tool.helper.CommonLayer").PowerLayer(callFunc)
    elseif EndurancePanel == panelID then
        require("tool.helper.CommonLayer").EnduranceLayer(callFunc)
    elseif CoinTreePanel == panelID then
        local coinTree = require("scene.main.CoinTreeLayer").new()
        coinTree:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
        local scene = cc.Director:getInstance():getRunningScene()
        scene:addChild(coinTree)
    elseif ActivityCenterLayer == panelID then
        local activityDailyCheckInfo = nil
        local activityAccCheckInfo = nil
        local activityInfo = nil
        rpc:call("Game.GetMultiSysInfo", {"DailyCheck", "AccCheck", "ActivityInfo"}, function(event)
            if event.status == Exceptions.Nil and event.result ~= nil then
                activityDailyCheckInfo = event.result.DailyCheck
                activityAccCheckInfo = event.result.AccCheck 
                activityInfo = event.result.ActivityInfo 

                application:pushScene("main.activity.ActivityCenterScene", activityDailyCheckInfo, activityAccCheckInfo, activityInfo, jump2)  
            end
        end)
    end
end

function Common.openLevelDesc(openLevel)
    application:showFlashNotice(openLevel.."级开启此功能，努力升级吧！")
end

-- 存取数据
function Common.writeFile(writeTable, fileName)
    local lpath = require("tool.lib.path")

    local fileUtils = cc.FileUtils:getInstance()
    local noticeFilePath = lpath.join(fileUtils:getWritablePath(), fileName)
    local file = io.open(noticeFilePath, "w")
     
    local function SaveTableContent(file, obj)
        local szType = type(obj)
        if szType == "number" then
            file:write(obj)
        elseif szType == "string" then
            file:write(string.format("%q", obj))
        elseif szType == "boolean" then
            if obj then
                file:write("true")
            else
                file:write("false")
            end
        elseif szType == "table" then
            --把table的内容格式化写入文件
            file:write("{\n")
            for i, v in pairs(obj) do
                  file:write("[")
                  SaveTableContent(file, i)
                  file:write("]=\n")
                  SaveTableContent(file, v)
                  file:write(", \n")
             end
            file:write("}\n")
        else
            error("can't serialize a "..szType)
        end
    end

    file:write("local tab =\n")
    SaveTableContent(file, writeTable)
    file:write("return tab\n")

    file:close()
end

function Common.readFile(fileName)
    local lpath = require("tool.lib.path")
    local fileUtils = cc.FileUtils:getInstance()
    local noticeFilePath = lpath.join(fileUtils:getWritablePath(), fileName)

    if not cc.FileUtils:getInstance():isFileExist(noticeFilePath) then
        return nil
    else
        return require(noticeFilePath)
    end
end

return Common



