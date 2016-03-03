
local HeroTip = class("HeroTip", function() return cc.Node:create() end)

function HeroTip:ctor(heroID)
	self.heroID = heroID

	local heroData = assert(GameCache.GetHero(heroID), heroID)
	local starLevel = heroData.StarLevel
	local heroBaseData = assert(BaseConfig.GetHero(heroID, starLevel), string.format("%d:%d", heroID, starLevel))

	self.heroData = heroData
	self.heroBaseData = heroBaseData

	self:setupUI()
end

function HeroTip:setupUI()
	local heroData = self.heroData
	local heroBaseData = self.heroBaseData

	local name = heroBaseData.name
	local starLevel = heroData.StarLevel	
	local heroLevel = heroData.Level
	local HP  = heroData.HP
	local DEF = heroData.Def
	local ATK = heroData.Atk
	local MP  = heroData.MP
	local RPSkill      = heroBaseData.rpSkill
	local RPSkillLevel = heroData.RPSkillLevel

	local skillData  = BaseConfig.GetHeroSkill(RPSkill, RPSkillLevel)
	local skillRes   = skillData.Res
	local skillName  = skillData.name
	local skillLevel = RPSkillLevel
	local skillDesc  = skillData.Desc
	local skillDesc2 = skillData.Desc2

	local heroSpec   = ""
    if heroBaseData.atkSkill == 1001 then
        heroSpec   = "前排肉盾"
	elseif heroBaseData.atkSkill == 1002 then
		heroSpec = "中排输出"
	else
		heroSpec = "后排辅助"
	end

	local lineHeight = 25

	local baseHeight = 115
	local headHeight = 27
	local skillBaseHeight = 170
	local skillExtraHeight = lineHeight * #skillDesc2

	local height = baseHeight + headHeight + skillBaseHeight + skillExtraHeight

	local size = cc.size(520, height)
    self.size = size
	self:setContentSize(size)

	local bg = cc.Scale9Sprite:create("res/image/ui/img/bg/bg_139.png")
	bg:setContentSize(size)
	bg:setAnchorPoint(cc.p(0, 0))
	self:addChild(bg)

	local colorTable = {
		[0] = { plus = "", color = cc.c3b(255, 255, 255), },

		[1] = { plus = "", color = cc.c3b(20, 200, 20), },
		[2] = { plus = "+1", color = cc.c3b(20, 200, 20), },

		[3] = { plus = "", color = cc.c3b(20, 20, 200), },
		[4] = { plus = "+1", color = cc.c3b(20, 20, 200), },

		[5] = { plus = "", color = cc.c3b(138, 42, 222), },
		[6] = { plus = "+1", color = cc.c3b(138, 42, 225), },
		[7] = { plus = "+2", color = cc.c3b(138, 42, 225), },

		[8]  = { plus = "", color = cc.c3b(200, 20, 20), },
		[9]  = { plus = "+1", color = cc.c3b(200, 20, 20), },
		[10] = { plus = "+2", color = cc.c3b(200, 20, 20), },
		[11] = { plus = "+3", color = cc.c3b(200, 20, 20), },

		[12] = { plus = "", color = cc.c3b(255, 152, 20), }
	}
	local plus = colorTable[starLevel].plus
	local color = colorTable[starLevel].color

	local heroPanel = cc.Node:create()
	heroPanel:setContentSize(cc.size(500, 110))
	heroPanel:setPosition(cc.p(0, height - 110))
	self:addChild(heroPanel)

    local labelHeroName = Common.finalFont(name .. plus, 55, 60, 24, color, 0)
    labelHeroName:setAnchorPoint(cc.p(0, 0.5))
    heroPanel:addChild(labelHeroName)

    local labelHeroLevel = Common.finalFont("" .. heroLevel, 241, 60, 22, cc.c3b(255, 185, 15), 0)
    labelHeroLevel:setAlignment(cc.TEXT_ALIGNMENT_RIGHT, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    labelHeroLevel:setAnchorPoint(cc.p(1, 0.5))
    heroPanel:addChild(labelHeroLevel)

    local labelLevel = Common.finalFont("级", 245, 60, 20, cc.c3b(255, 185, 15), 0)
    labelLevel:setAlignment(cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    labelLevel:setAnchorPoint(cc.p(0, 0.5))
    heroPanel:addChild(labelLevel)

    local labelHeroSpec = Common.finalFont("专长:", 300, 60, 22, cc.c3b(255, 185, 15), 0)
    labelHeroSpec:setAnchorPoint(cc.p(0, 0.5))
    heroPanel:addChild(labelHeroSpec)

     local labelHeroSpecVal = Common.finalFont(heroSpec, 355, 60, 22, cc.c3b(255, 255, 255), 0)
    labelHeroSpecVal:setAnchorPoint(cc.p(0, 0.5))
    heroPanel:addChild(labelHeroSpecVal)

    local iconHeroHP = cc.Sprite:create("image/ui/img/btn/btn_673.png")
    iconHeroHP:setPosition(cc.p(52 + 110 * 0, 20))
    heroPanel:addChild(iconHeroHP)

    local labelHeroHP = Common.finalFont("" .. HP, 80 + 110 * 0, 20, 22, cc.c3b(255, 255, 255), 0)
    labelHeroHP:setAnchorPoint(cc.p(0, 0.5))
    heroPanel:addChild(labelHeroHP)

    local iconHeroATK = cc.Sprite:create("image/ui/img/btn/btn_674.png")
    iconHeroATK:setPosition(cc.p(52 + 110 * 1, 20))
    heroPanel:addChild(iconHeroATK)

    local labelHeroATK = Common.finalFont("" .. ATK, 80 + 110 * 1, 20, 22, cc.c3b(255, 255, 255), 0)
    labelHeroATK:setAnchorPoint(cc.p(0, 0.5))
    heroPanel:addChild(labelHeroATK)

    local iconHeroDEF = cc.Sprite:create("image/ui/img/btn/btn_676.png")
    iconHeroDEF:setPosition(cc.p(52 + 110 * 2, 20))
    heroPanel:addChild(iconHeroDEF)

    local labelHeroDEF = Common.finalFont("" .. DEF, 80 + 110 * 2, 20, 22, cc.c3b(255, 255, 255), 0)
    labelHeroDEF:setAnchorPoint(cc.p(0, 0.5))
    heroPanel:addChild(labelHeroDEF)

    local iconHeroMP = cc.Sprite:create("image/ui/img/btn/btn_675.png")
    iconHeroMP:setPosition(cc.p(52 + 110 * 3, 20))
    heroPanel:addChild(iconHeroMP)

    local labelHeroMP = Common.finalFont("" .. MP, 80 + 110 * 3, 20, 22, cc.c3b(255, 255, 255), 0)
    labelHeroMP:setAnchorPoint(cc.p(0, 0.5))
    heroPanel:addChild(labelHeroMP)

    local lineBG = cc.Sprite:create("image/ui/img/btn/btn_781.png")
    lineBG:setPosition(cc.p(250, height - 120))
    self:addChild(lineBG)
    local size = lineBG:getContentSize()

    local line = cc.Sprite:create("image/ui/img/btn/btn_786.png")
    line:setPosition(size.width * 0.25, size.height * 0.5)
    lineBG:addChild(line)

    local line = cc.Sprite:create("image/ui/img/btn/btn_786.png")
    line:setScaleX(-1)
    line:setPosition(size.width * 0.75, size.height * 0.5)
    lineBG:addChild(line)

     local labelTitleSkill = Common.finalFont("法术技能", 200, height - 120, 22, cc.c3b(255, 185, 15), 0)
    labelTitleSkill:setAnchorPoint(cc.p(0, 0.5))
    self:addChild(labelTitleSkill)

    local skillPanel = cc.Node:create()
    skillPanel:setPosition(cc.p(0, 8))
    skillPanel:setContentSize(cc.size(500, skillBaseHeight + skillExtraHeight))
    self:addChild(skillPanel)

    local skillIconBorder = cc.Sprite:create("image/icon/border/border_star_3.png")
    skillIconBorder:setPosition(cc.p(80, 120 + skillExtraHeight))
    skillIconBorder:setScale(0.92)
    skillPanel:addChild(skillIconBorder)

    local skillIcon = cc.Sprite:create(string.format("image/icon/skill/%s.png", skillRes))
    skillIcon:setPosition(cc.p(80, 120 + skillExtraHeight))
    skillPanel:addChild(skillIcon)

    local labelSkillName = Common.finalFont(string.format("【%s】", skillName), 200, 120 + skillExtraHeight, 24, cc.c3b(255, 185, 15), 0)
    skillPanel:addChild(labelSkillName)

    local labelSkillLevel = Common.finalFont(string.format("LV.%d", skillLevel), 330, 120 + skillExtraHeight, 24, cc.c3b(255, 185, 15), 0)
    skillPanel:addChild(labelSkillLevel)

    local labelSkillDesc = Common.finalFont(skillDesc, 50, 70 + skillExtraHeight, 20, cc.c3b(255, 255, 255), 0)
    labelSkillDesc:setAlignment(cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_TOP)
    labelSkillDesc:setDimensions(450, 50)
    labelSkillDesc:setAnchorPoint(cc.p(0, 1.0))
    skillPanel:addChild(labelSkillDesc) 

    for idx, desc in ipairs(skillDesc2) do
		local labelSkillExtraDesc = Common.finalFont(desc, 50, skillExtraHeight - (idx - 1.5) * lineHeight, 20, cc.c3b(255, 185, 15), 0)
		labelSkillExtraDesc:setAlignment(cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		labelSkillExtraDesc:setAnchorPoint(cc.p(0, 0.5))
		skillPanel:addChild(labelSkillExtraDesc) 
    end
end

function HeroTip:getContentSize()
    return self.size
end

return HeroTip