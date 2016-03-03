local ElemType = require("config.ElemType")
local CommonTool = require("tool.helper.Common")
--local HeroDataManager = require("data.HeroDataManager")
-------------------------------------------------------------------------------

local HeroHeadNode = class("HeroHeadNode", function() return cc.Node:create() end)

function HeroHeadNode:ctor(heroData, disabled)
    self.heroData = heroData
    self.heroBaseData = BaseConfig.GetHero(heroData.ID, heroData.StarLevel)

    self:setContentSize(cc.size(104, 95))
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self.controls = {}
    self.handlers = {}

    self._isDisabled = disabled or false
    self.heroTowerHP = 0
    self._isInForm = false
    self._isLocked = false
    self.isInClinic = false

    self:setupUI()

    local function onNodeEvent(event)
        if event == "enter" then
            self:onEnter()
        elseif event == "exit" then
            self:onExit()
        elseif event == "cleanup" then
            self:onCleanup()
        elseif event == "enterTransitionFinish" then
            self:onEnterTransitionFinish()
        elseif event == "exitTransitionStart" then
            self:onExitTransitionStart()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

function HeroHeadNode:onEnter()
end

function HeroHeadNode:onExit()
end

function HeroHeadNode:onCleanup()
--    for _, handler in ipairs(self.handlers) do
--        self:getEventDispatcher():removeEventListener(handler)
--    end
end

function HeroHeadNode:getHeroID()
    return self.heroData.ID
end

function HeroHeadNode:getHeroType()
    local attackSkillID = self.heroBaseData.atkSkill

    if attackSkillID == 1001 then
        return "near"
    elseif attackSkillID == 1002 then
        return "far"
    elseif attackSkillID == 1003 then
        return "veryFar"
    else
        assert(false, string.format("unknown hero type of skillID", attackSkillID))
    end
end

function HeroHeadNode:isLocked()
    return self._isLocked
end

function HeroHeadNode:isTowerEnabled()
    if self.heroData.Level < 30 then 
        return false, "等级未满30级"
    end 

    if self.heroTowerHP <= 0 then 
        return false, "已经阵亡"
    end  

    if self.isInClinic then
        return false, "正在治疗"
    end

    -- TODO:在仙盟中当佣兵的不能上阵
    if false then
        return false, "正在仙盟当佣兵"
    end

    return true
end

function HeroHeadNode:onEnterTransitionFinish()
end

function HeroHeadNode:onExitTransitionStart()
end

function HeroHeadNode:removeHandlerOnCleanup(handler)
    table.insert(self.handlers, handler)
end

function HeroHeadNode:getHeroIcon()
    local res = self.heroBaseData.res

    local fileUtils = cc.FileUtils:getInstance()
    local path = fileUtils:fullPathForFilename(string.format("res/image/icon/head/%s.png", res))
    if not fileUtils:isFileExist(path) then
        CCLog(string.format("file '%s' not exists, use default", path))
        path = "res/image/icon/head/xj_1000.png"
    end
    return path
end

function HeroHeadNode:getBorderIcon()
    local borderPath = "image/icon/border/props_border.png"
    if self.heroData.StarLevel then
        borderPath = string.format("image/icon/border/border_star_%d.png", self.heroData.StarLevel)
    end

    return borderPath
end

function HeroHeadNode:getBorderIconName()
    local borderPath = "props_border.png"
    if self.heroData.StarLevel then
        borderPath = string.format("border_star_%d.png", self.heroData.StarLevel)
    end

    return borderPath
end

function HeroHeadNode:getElemTypeIcon()
    local wx = self.heroBaseData.wx
    local iconPath = string.format("res/image/icon/wx/wx_%d.png", wx)
    return iconPath
end

function HeroHeadNode:getElemTypeName()
    return ElemType.typeName(self.heroBaseData.wx)
end

function HeroHeadNode:getElemTypeColor()
    local colors = {
        cc.c3b(255, 255, 255),
        cc.c3b(0x66, 0xCD, 0),
        cc.c3b(50, 50, 50),
        cc.c3b(255, 0, 0),
        cc.c3b(0xFF, 0xB9, 0x0F),
    }
    return colors[self.heroBaseData.wx]
end

function HeroHeadNode:getName()
    return self.heroBaseData.name
end

function HeroHeadNode:getLevel()
    return self.heroData.Level
end

function HeroHeadNode:setupUI()
    local centerPos = cc.p(104 / 2, 95 / 2)

    cc.SpriteFrameCache:getInstance():addSpriteFrames("image/icon/border.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("image/icon/head.plist")

    -- local headBG = cc.Sprite:create("image/icon/border/head_bg.png")    
    local headBG = cc.Sprite:createWithSpriteFrameName("head_bg.png")
    headBG:setPosition(centerPos)
    self:addChild(headBG)

    --local border = cc.Sprite:create(self:getBorderIcon())
    local border = cc.Sprite:createWithSpriteFrameName(self:getBorderIconName())
    --border:setScale(display.contentScaleFactor)
    border:setPosition(centerPos)
    self:addChild(border)
    self.controls.border = border

    local head = GoodsInfoNode.new(BaseConfig.GOODS_HERO, self.heroData) -- cc.Sprite:create(self:getHeroIcon())
    --:setScale(display.contentScaleFactor)
    head:setPosition(cc.pAdd(centerPos, cc.p(0, 0)))
    self:addChild(head)
    if self._isDisabled then
        head:setOpacity(180)
        head:setOpacityModifyRGB(true)
    end
    self.controls.head = head

    self.controls.wxBG = cc.Sprite:create("image/ui/img/btn/btn_382.png")
    self.controls.wxBG:setAnchorPoint(0, 0.5)
    self.controls.wxBG:setPosition(8, centerPos.y)
    self:addChild(self.controls.wxBG)

    local wxBgSize = self.controls.wxBG:getContentSize()
    self.controls.wx = cc.Label:createWithCharMap("image/ui/img/btn/btn_394.png", 24, 19,  string.byte("1"))
    self.controls.wx:setAnchorPoint(0.5, 0.5)
    self.controls.wx:setPosition(wxBgSize.width / 2, wxBgSize.height / 2)
    local wx = self.heroBaseData.wx
    self.controls.wx:setString(wx)
    self.controls.wxBG:addChild(self.controls.wx)

--    local wxBg = cc.Sprite:create(self:getElemTypeIcon())
--    --wxBg:setScale(display.contentScaleFactor)
--    wxBg:setPosition(cc.pAdd(centerPos, cc.p(-50, -35)))
--    self:addChild(wxBg)
--    self.controls.border = wxBg

--    local labelWx = cc.LabelTTF:create(self:getElemTypeName(), "Arial", 24)
--    labelWx:setPosition(cc.pAdd(centerPos, cc.p(-50, -35)))
--    labelWx:setColor(self:getElemTypeColor())
--    self:addChild(labelWx)
--    self.controls.wx = labelWx

    local levelBg = cc.Sprite:create("image/ui/img/btn/btn_1044.png")
    levelBg:setPosition(cc.pAdd(centerPos, cc.p(0, -35)))
    self:addChild(levelBg)

    local labelLevel = Common.finalFont("Lv."..self:getLevel(), 0, 0, nil, nil, 1)
    --CommonTool.createFont("Lv." .. self:getLevel(), 0 , 0 , 22, cc.c3b(255, 255, 255), 1) -- cc.LabelTTF:create("lv." .. self:getLevel(), "Arial", 20)
    labelLevel:setPosition(cc.pAdd(centerPos, cc.p(0, -35)))
    self:addChild(labelLevel)
    self.controls.level = labelLevel

    local posX = head:getContentSize().width / 2
    local hpBgSprite = cc.Sprite:create("image/ui/img/btn/btn_232.png")
    hpBgSprite:setPosition(cc.p(posX, 82))
    hpBgSprite:setScale(1.1)
    self:addChild(hpBgSprite)
    self.controls.hpBg = hpBgSprite
    hpBgSprite:setVisible(false)

    local bgImage = "image/ui/img/btn/btn_231.png"
    local hpBar = cc.ProgressTimer:create(cc.Sprite:create(bgImage))
    hpBar:setPosition(cc.p(posX, 82))
    hpBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    hpBar:setScale(1.1)
    --hpBar:setReverseDirection(true)
    hpBar:setMidpoint(cc.p(0, 1))
    hpBar:setBarChangeRate(cc.p(1, 0))
    hpBar:setPercentage(100)
    self:addChild(hpBar)
    self.controls.hpBar = hpBar
    hpBar:setVisible(false)

    local spriteInForm = cc.Sprite:create("image/ui/img/btn/btn_502.png")
    --wxBg:setScale(display.contentScaleFactor)
    spriteInForm:setPosition(cc.pAdd(centerPos, cc.p(0, -33)))
    self:addChild(spriteInForm)
    self.controls.inForm = spriteInForm
    spriteInForm:setVisible(false)

    local spriteLock = cc.Sprite:create("image/ui/img/btn/btn_1159.png")
    spriteLock:setPosition(centerPos)
    self:addChild(spriteLock)
    self.controls.iconLock = spriteLock
    spriteLock:setVisible(false)

    local deadIcon= cc.Sprite:create("image/ui/img/btn/btn_1046.png")
    deadIcon:setPosition(centerPos)
    self:addChild(deadIcon)
    self.controls.deadIcon = deadIcon
    deadIcon:setVisible(false)

    local inClinicIcon= cc.Sprite:create("image/ui/img/btn/btn_1045.png")
    inClinicIcon:setPosition(centerPos)
    self:addChild(inClinicIcon)
    self.controls.inClinicIcon = inClinicIcon
    inClinicIcon:setVisible(false)
end

function HeroHeadNode:setInForm(inForm)
    self._isInForm = inForm
    self.controls.inForm:setVisible(inForm)

    if inForm then
        self.controls.head:setOpacity(180)
    else
        self.controls.head:setOpacity(255)
    end
end

function HeroHeadNode:setLocked(locked)
    self._isLocked = locked
    self.controls.iconLock:setVisible(locked)

    if locked then
        self.controls.head.controls.head:setOpacity(150)
        self.controls.head.controls.head:setColor(cc.c3b(150, 150, 150))
    else
        self.controls.head.controls.head:setOpacity(255)
        self.controls.head.controls.head:setColor(cc.c3b(255, 255, 255))
    end
end

function HeroHeadNode:setTowerDisabled(disabled)
    self._isDisabled = disabled
    if disabled then
        self.controls.head:setOpacity(180)
        --self.controls.head:setOpacityModifyRGB(true)
    end
end

function HeroHeadNode:showIsInClinic(isInClinic)
    self.isInClinic = isInClinic
    self.controls.inClinicIcon:setVisible(isInClinic)
end

function HeroHeadNode:showHP(hp)
    self.heroTowerHP = hp

    hp = hp or self.heroData.HP
    local total = self.heroData.HP
    local percent = math.ceil(hp * 100 / total)
    self.controls.hpBar:setPercentage(math.min(100, percent))
    self.controls.hpBg:setVisible(true)
    self.controls.hpBar:setVisible(true)

    if hp <= 0 then
        self.controls.head:setOpacity(150)
        self.controls.head:setOpacityModifyRGB(true)
    end
    self.controls.deadIcon:setVisible(hp <= 0)
end

return HeroHeadNode