local TEN_THOUSAND = 10000
local FATE_TYPE_HERO = 1
local FATE_TYPE_EQUIP = 2

local FATE_EXTRA_EFFECT_TYPE_ATK = 1
local FATE_EXTRA_EFFECT_TYPE_DEF = 2
local FATE_EXTRA_EFFECT_TYPE_HP = 3
local FATE_EXTRA_EFFECT_TYPE_MP = 4

local ENERGY_ATK = 1
local ENERGY_DEF = 2
local ENERGY_HP = 3
local ENERGY_MP = 4
local ENERGY_HIT = 5
local ENERGY_MISS = 6
local ENERGY_CRIT = 7
local ENERGY_TEN = 8
local ENERGY_PHYPOWER = 9
local ENERGY_ENDURANCE = 10

local APARTMENT_EXTRA_TYPE_ATK = 1
local APARTMENT_EXTRA_TYPE_DEF = 2
local APARTMENT_EXTRA_TYPE_HP = 3
local APARTMENT_EXTRA_TYPE_MP = 4
local APARTMENT_EXTRA_TYPE_VAMPIRE = 5


local CalHeroAttr = {}

function CalHeroAttr.calEnergyAdd(step, num, typ)
	local tab = Common.getAvatarAttr(step, num)
	return tab[typ]
end

-- 计算体力上限
function CalHeroAttr.calMaxPhyPower(energyStep, energyAttrNum)
	local max = 100 + CalHeroAttr.calEnergyAdd(energyStep, energyAttrNum, ENERGY_PHYPOWER)
    return max
end

-- 计算耐力上限
function CalHeroAttr.calMaxEndurance(energyStep, energyAttrNum)
	local max = 20 + CalHeroAttr.calEnergyAdd(energyStep, energyAttrNum, ENERGY_ENDURANCE)
    return max
end


-- 计算缘分搭配加成
function CalHeroAttr.fateExtraPerAdd( hero, fateType, effectType )
	local cfList = BaseConfig.GetFate(hero.ID, fateType)
	if cfList == nil then
		return 0
	end

	local result = 0
	for idx1, cf in ipairs(cfList) do
		if cf.extraEffectType == effectType then
			local match = true
			if fateType == FATE_TYPE_HERO then
				-- 星将缘分
				for idx2, id in ipairs(cf.matchList) do
					if GameCache.IsOwnHero(id) == false then
						match = false
						break
					end
				end
			elseif fateType == FATE_TYPE_EQUIP then
				-- 装备缘分
				for idx2, id in ipairs(cf.matchList) do
					local installed = false
					for idx3, ep in ipairs(hero.Equip) do
						if id == ep.ID then
							installed = true
							break
						end
					end

					if installed == false then
						match = false
						break
					end
				end
			end

			if match then
				result = result + cf.extraEffectValue
			end
		end
	end

	return math.floor(result)
end

-- 计算装备攻击
function CalHeroAttr.CalEquipAtk(id, level, starLevel)
	local cfEquip = BaseConfig.GetEquip(id, starLevel)
	local atk =  math.floor(cfEquip.atk + (level-1) *cfEquip.atkGrow / TEN_THOUSAND)
	return atk
end

-- 计算星将攻击
-- 参数：hero: 当前计算星将
function CalHeroAttr.CalHeroAtk( hero )
	-- 星将基础配置
	local cfHero = BaseConfig.GetHero(hero.ID, hero.StarLevel)
	-- 人物<攻击>
	local heroAtk = math.floor(cfHero.atk + (hero.Level-1) * cfHero.atkGrow / TEN_THOUSAND)
	-- 百分比<攻击>（装备百分比＋缘份（装备、星将）百分比
	local heroFate = CalHeroAttr.fateExtraPerAdd(hero, FATE_TYPE_HERO, FATE_EXTRA_EFFECT_TYPE_ATK)
	local equipFate = CalHeroAttr.fateExtraPerAdd(hero, FATE_TYPE_EQUIP, FATE_EXTRA_EFFECT_TYPE_ATK)
	local apartmentPer = CalHeroAttr.calApartmentBuff(hero, APARTMENT_EXTRA_TYPE_ATK) / TEN_THOUSAND
	local heroAtkPer = (heroFate + equipFate) / TEN_THOUSAND
	-- 装备附加<攻击>
	local equipExtraAtk = 0
	-- 其它系统附加<攻击>
	local otherExtraAtk = 0

	for i, v in ipairs(hero.Equip) do
		if v.ID ~= 0 then
			local cfEquip = BaseConfig.GetEquip(v.ID, v.StarLevel)
			local per = cfEquip.atkRatio / TEN_THOUSAND + (v.Level-1) * cfEquip.atkRatioGrow / TEN_THOUSAND
			heroAtkPer = heroAtkPer + per

			local atk = CalHeroAttr.CalEquipAtk(v.ID, v.Level, v.StarLevel)
			equipExtraAtk = equipExtraAtk + atk
		end
	end

	equipExtraAtk = math.floor(equipExtraAtk)
	otherExtraAtk = math.floor(otherExtraAtk)
	local totalAtk = math.floor((heroAtk * (1+heroAtkPer) + equipExtraAtk + otherExtraAtk) * (1+apartmentPer))
	local step = GameCache.Avatar.EnergyStep
	local num = GameCache.Avatar.EnergyAttrNum
	local energyAdd = CalHeroAttr.calEnergyAdd(step, num, ENERGY_ATK)
	return totalAtk + energyAdd
end

-- 计算装备防御
function CalHeroAttr.CalEquipDef(id, level, starLevel)
	local cfEquip = BaseConfig.GetEquip(id, starLevel)
	local def = math.floor(cfEquip.def + (level-1) * cfEquip.defGrow / TEN_THOUSAND)
	return def
end

-- 计算星将防御
-- 参数：hero: 当前计算星将
function CalHeroAttr.CalHeroDef( hero )
	-- 星将基础配置
	local cfHero = BaseConfig.GetHero(hero.ID, hero.StarLevel)
	-- 人物<防御>
	local heroDef = math.floor(cfHero.def + (hero.Level-1) * cfHero.defGrow / TEN_THOUSAND)
	-- 百分比<防御>（装备百分比＋缘份（装备、星将）百分比
	local heroFate = CalHeroAttr.fateExtraPerAdd(hero, FATE_TYPE_HERO, FATE_EXTRA_EFFECT_TYPE_DEF)
	local equipFate = CalHeroAttr.fateExtraPerAdd(hero, FATE_TYPE_EQUIP, FATE_EXTRA_EFFECT_TYPE_DEF)
	local apartmentPer = CalHeroAttr.calApartmentBuff(hero, APARTMENT_EXTRA_TYPE_DEF) / TEN_THOUSAND
	local heroDefPer = (heroFate + equipFate) / TEN_THOUSAND
	-- 装备附加<防御>
	local equipExtraDef = 0
	-- 其它系统附加<防御>
	local otherExtraDef = 0

	for i, v in ipairs(hero.Equip) do
		if v.ID ~= 0 then
			local cfEquip = BaseConfig.GetEquip(v.ID, v.StarLevel)
			local per = cfEquip.defRatio / TEN_THOUSAND + (v.Level-1) * cfEquip.defRatioGrow / TEN_THOUSAND
			heroDefPer = heroDefPer + per

			local def = CalHeroAttr.CalEquipDef(v.ID, v.Level, v.StarLevel)
			equipExtraDef = equipExtraDef + def
		end
	end

	equipExtraDef = math.floor(equipExtraDef)
	otherExtraDef = math.floor(otherExtraDef)
	local totalDef = math.floor((heroDef * (1+heroDefPer) + equipExtraDef + otherExtraDef)* (1+apartmentPer))  
	local step = GameCache.Avatar.EnergyStep
	local num = GameCache.Avatar.EnergyAttrNum
	local energyAdd = CalHeroAttr.calEnergyAdd(step, num, ENERGY_DEF)
	return totalDef + energyAdd
end

-- 计算装备生命
function CalHeroAttr.CalEquipHP(id, level, starLevel)
	local cfEquip = BaseConfig.GetEquip(id, starLevel)
	local hp = math.floor(cfEquip.hp + (level-1) * cfEquip.hpGrow / TEN_THOUSAND)
	return hp
end


-- 计算星将生命
-- 参数：hero: 当前计算星将
function CalHeroAttr.CalHeroHP( hero )
	-- 星将基础配置
	local cfHero = BaseConfig.GetHero(hero.ID, hero.StarLevel)
	-- 人物<生命>
	local heroHP = math.floor(cfHero.hp + (hero.Level-1) * cfHero.hpGrow / TEN_THOUSAND)
	-- 百分比<生命>（装备百分比＋缘份（装备、星将）百分比
	local heroFate = CalHeroAttr.fateExtraPerAdd(hero, FATE_TYPE_HERO, FATE_EXTRA_EFFECT_TYPE_HP)
	local equipFate = CalHeroAttr.fateExtraPerAdd(hero, FATE_TYPE_EQUIP, FATE_EXTRA_EFFECT_TYPE_HP)
	local apartmentPer = CalHeroAttr.calApartmentBuff(hero, APARTMENT_EXTRA_TYPE_HP) / TEN_THOUSAND
	local heroHPPer = (heroFate + equipFate) / TEN_THOUSAND
	-- 装备附加<生命>
	local equipExtraHP = 0
	-- 其它系统附加<生命>
	local otherExtraHP = 0

	for i, v in ipairs(hero.Equip) do
		if v.ID ~= 0 then
			local cfEquip = BaseConfig.GetEquip(v.ID, v.StarLevel)
			local per = cfEquip.hpRatio / TEN_THOUSAND + (v.Level-1) * cfEquip.hpRatioGrow / TEN_THOUSAND
			heroHPPer = heroHPPer + per

			local hp = CalHeroAttr.CalEquipHP(v.ID, v.Level, v.StarLevel)
			equipExtraHP = equipExtraHP + hp
		end
	end

	equipExtraHP = math.floor(equipExtraHP)
	otherExtraHP = math.floor(otherExtraHP)
	local totalHP = math.floor((heroHP * (1+heroHPPer) + equipExtraHP + otherExtraHP)* (1+apartmentPer))
	local step = GameCache.Avatar.EnergyStep
	local num = GameCache.Avatar.EnergyAttrNum
	local energyAdd = CalHeroAttr.calEnergyAdd(step, num, ENERGY_HP)
	local result = totalHP + energyAdd
	
	return result
end

-- 计算装备法力
function CalHeroAttr.CalEquipMP(id, level, starLevel)
	local cfEquip = BaseConfig.GetEquip(id, starLevel)
	local mp = math.floor(cfEquip.mp + (level-1) * cfEquip.mpGrow / TEN_THOUSAND)
	return mp
end

-- 计算星将法力
-- 参数：hero: 当前计算星将
function CalHeroAttr.CalHeroMP( hero )
	-- 星将基础配置
	local cfHero = BaseConfig.GetHero(hero.ID, hero.StarLevel)
	-- 人物<法力>
	local heroMP = math.floor(cfHero.mp + (hero.Level-1) * cfHero.mpGrow / TEN_THOUSAND)
	-- 百分比<法力>（装备百分比＋缘份（装备、星将）百分比
	local heroFate = CalHeroAttr.fateExtraPerAdd(hero, FATE_TYPE_HERO, FATE_EXTRA_EFFECT_TYPE_MP)
	local equipFate = CalHeroAttr.fateExtraPerAdd(hero, FATE_TYPE_EQUIP, FATE_EXTRA_EFFECT_TYPE_MP)
	local apartmentPer = CalHeroAttr.calApartmentBuff(hero, APARTMENT_EXTRA_TYPE_MP) / TEN_THOUSAND
	local heroMPPer = (heroFate + equipFate) / TEN_THOUSAND
	-- 装备附加<法力>
	local equipExtraMP = 0
	-- 其它系统附加<法力>
	local otherExtraMP = 0

	for i, v in ipairs(hero.Equip) do
		if v.ID ~= 0 then
			local cfEquip = BaseConfig.GetEquip(v.ID, v.StarLevel)
			local per = cfEquip.mpRatio / TEN_THOUSAND + (v.Level-1) * cfEquip.mpRatioGrow / TEN_THOUSAND
			heroMPPer = heroMPPer + per

			local mp = CalHeroAttr.CalEquipMP(v.ID, v.Level, v.StarLevel)
			equipExtraMP = equipExtraMP + mp
		end
	end

	equipExtraMP = math.floor(equipExtraMP)
	otherExtraMP = math.floor(otherExtraMP)
	local totalMP = math.floor((heroMP * (1+heroMPPer) + equipExtraMP + otherExtraMP)* (1+apartmentPer))
	local step = GameCache.Avatar.EnergyStep
	local num = GameCache.Avatar.EnergyAttrNum
	local energyAdd = CalHeroAttr.calEnergyAdd(step, num, ENERGY_MP)

	return totalMP + energyAdd
end

-- 计算星将命中
function CalHeroAttr.CalHeroHit( hero )
	local cfHero = BaseConfig.GetHero(hero.ID, hero.StarLevel)
	local hit = cfHero.hit

	local step = GameCache.Avatar.EnergyStep
	local num = GameCache.Avatar.EnergyAttrNum
	local energyAdd = CalHeroAttr.calEnergyAdd(step, num, ENERGY_HIT)
	return hit + energyAdd
end

-- 计算星将闪避
function CalHeroAttr.CalHeroMiss( hero )
	local cfHero = BaseConfig.GetHero(hero.ID, hero.StarLevel)
	local miss = cfHero.miss

	local step = GameCache.Avatar.EnergyStep
	local num = GameCache.Avatar.EnergyAttrNum
	local energyAdd = CalHeroAttr.calEnergyAdd(step, num, ENERGY_MISS)
	return miss + energyAdd
end

-- 计算星将暴击
function CalHeroAttr.CalHeroCrit( hero )
	local cfHero = BaseConfig.GetHero(hero.ID, hero.StarLevel)
	local crit = cfHero.crit

	local step = GameCache.Avatar.EnergyStep
	local num = GameCache.Avatar.EnergyAttrNum
	local energyAdd = CalHeroAttr.calEnergyAdd(step, num, ENERGY_CRIT)
	return crit + energyAdd
end

-- 计算星将韧性
function CalHeroAttr.CalHeroTen( hero )
	local cfHero = BaseConfig.GetHero(hero.ID, hero.StarLevel)
	local ten = cfHero.ten

	local step = GameCache.Avatar.EnergyStep
	local num = GameCache.Avatar.EnergyAttrNum
	local energyAdd = CalHeroAttr.calEnergyAdd(step, num, ENERGY_TEN)
	return ten + energyAdd
end

-- 计算星将总战力
function CalHeroAttr.CalHeroTFP( hero )
	local cfHero = BaseConfig.GetHero(hero.ID, hero.StarLevel)
	local atk = hero.Atk
	if atk == nil then atk = CalHeroAttr.CalHeroAtk(hero) end
	local def = hero.Def
	if def == nil then def = CalHeroAttr.CalHeroDef(hero) end
	local hp = hero.HP
	if hp == nil then hp = CalHeroAttr.CalHeroHP(hero) end
	local mp = hero.MP
	if mp == nil then mp = CalHeroAttr.CalHeroMP(hero) end
	local hit = hero.Hit
	if hit == nil then hit = CalHeroAttr.CalHeroHit(hero) end
	local miss = hero.Miss
	if miss == nil then miss = CalHeroAttr.CalHeroMiss(hero) end
	local crit = hero.Crit
	if crit == nil then crit = CalHeroAttr.CalHeroCrit(hero) end
	local ten = hero.Ten
	if ten == nil then ten = CalHeroAttr.CalHeroTen(hero) end

	local norSkillLevel = hero.NorSkillLevel
	if norSkillLevel == nil then norSkillLevel = CalHeroAttr.HeroNorSkillLevel(hero) end

	local RPLevelAdd = hero.RPLevelAdd
	if RPLevelAdd == nil then RPLevelAdd = CalHeroAttr.HeroAddRPSkillLevel(hero) end

	local rpSkillLevel = hero.RPSkillLevel + RPLevelAdd

	local atkInterval = hero.AtkInterval
	if atkInterval == nil then atkInterval = CalHeroAttr.HeroAtkInterval(hero) end

	-- 更新总战力

	local heroTFP = (atk *0.5 + mp *0.2) * (1+rpSkillLevel*0.01) * 2000 / atkInterval
	heroTFP = heroTFP + def * 0.5
	heroTFP = heroTFP + hp * 0.1
	heroTFP = heroTFP + hit * 2
	heroTFP = heroTFP + miss * 2
	heroTFP = heroTFP + crit * 2
	heroTFP = heroTFP + ten * 2
	heroTFP = heroTFP + norSkillLevel * 30

	return math.floor( heroTFP)
end

--计算星将评分
function CalHeroAttr.CalHeroScore( hero )
	local ScoreRule = BaseConfig.GetHeroApartmentRuleConfig(  )
	local score = 0
	score  = score + ScoreRule.HeroStarsCore[hero.StarLevel+1]
	score  = score + hero.Level * 0.6
	score  = score + (hero.RPSkillLevel + hero.RPLevelAdd) * 2
	for k,equip in pairs(hero.Equip) do
		if equip.ID ~= 0 then
			if k < 5 then
				score  = score + ScoreRule.EquipStarsCore[equip.StarLevel+1]
				score  = score + equip.Level * 0.06
			elseif k >= 5 then
				score  = score + ScoreRule.TreasureStarsCore[equip.StarLevel+1]
				score  = score + equip.Level * 1.5
			end
		end

	end

	score = math.floor(score)

	if not hero.Score or hero.Score < 0 then
		hero.Score = 0
	end

	if hero.ApartmentType and hero.ApartmentType > 0 then
		local offset = score - hero.Score
		GameCache.HeroApartmentBuff[hero.ApartmentType] = GameCache.HeroApartmentBuff[hero.ApartmentType] + offset
	end

	return score
end

function CalHeroAttr.calApartmentBuff( hero, additionType )
	local percent = 0
	local apartment = BaseConfig.GetHeroApartmentConfig()
	local _hero = BaseConfig.GetHero(hero.ID, hero.StarLevel)

	local apartmentType = nil

	if _hero.atkSkill == 1001 then

		apartmentType = BaseConfig.ApartmentType.atk_near
	elseif _hero.atkSkill == 1002 then

		apartmentType = BaseConfig.ApartmentType.atk_far
	elseif _hero.atkSkill == 1003 then

		apartmentType = BaseConfig.ApartmentType.atk_sfar
	end

	if apartmentType then
		for k,v in pairs(apartment[apartmentType].Property) do
			if additionType == v then
				percent = percent + GameCache.HeroApartmentBuff[apartmentType]
			end
		end
	end

	local apartmentType = nil
	if _hero.gender == 1 then
		apartmentType = BaseConfig.ApartmentType.gender_male
	elseif _hero.gender == 2 then
		apartmentType = BaseConfig.ApartmentType.gender_female
		
	end

	if apartmentType then
		for k,v in pairs(apartment[apartmentType].Property) do
			if additionType == v then
				percent = percent + GameCache.HeroApartmentBuff[apartmentType]
			end
		end
	end

	local apartmentType = nil
	if _hero.move == 1 then
		apartmentType = BaseConfig.ApartmentType.move_foot
	elseif _hero.move > 1 then
		apartmentType = BaseConfig.ApartmentType.move_fly
	end

	if apartmentType then
		for k,v in pairs(apartment[apartmentType].Property) do
			if additionType == v then
				percent = percent + GameCache.HeroApartmentBuff[apartmentType]
			end
		end
	end

	local apartmentType = BaseConfig.ApartmentType.all
	for k,v in pairs(apartment[apartmentType].Property) do
		if additionType == v then
			percent = percent + GameCache.HeroApartmentBuff[apartmentType]
		end
	end

	return percent

end

-- 计算星将吸血
function CalHeroAttr.CalHeroVampire( hero )
	local heroVampire = CalHeroAttr.calApartmentBuff( hero, APARTMENT_EXTRA_TYPE_VAMPIRE )

	-- 策划说，该效果只会出现戒指上
	if hero.Equip[3].ID ~= 0 then
		local equipConfig = BaseConfig.GetEquip(hero.Equip[3].ID, hero.Equip[3].StarLevel)
		heroVampire = heroVampire + equipConfig.atkHpRecover
	end

	return heroVampire / TEN_THOUSAND
end

-- 计算星将生命回复
function CalHeroAttr.CalHeroHpRecover( hero )
	local heroHpRecover = 0

	-- 策划说，该效果只会出现衣服上
	if hero.Equip[4].ID ~= 0 then
		local equipConfig = BaseConfig.GetEquip(hero.Equip[4].ID, hero.Equip[4].StarLevel)
		heroHpRecover = heroHpRecover + equipConfig.hpRecover
	end

	return heroHpRecover
end

-- 计算星将被治疗效果
function CalHeroAttr.CalHeroTreatedAddition( hero )
	local heroTreatedAddition = 0

	-- 策划说，该效果只会出现头盔上
	if hero.Equip[1].ID ~= 0 then
		local equipConfig = BaseConfig.GetEquip(hero.Equip[1].ID, hero.Equip[1].StarLevel)
		heroTreatedAddition = heroTreatedAddition + equipConfig.treatedAddition
	end

	return heroTreatedAddition / TEN_THOUSAND
end

-- 计算星将技能减伤
function CalHeroAttr.CalHeroSkillReduction( hero )
	local heroSkillReduction = 0

	-- 策划说，该效果只会出现头盔上
	if hero.Equip[1].ID ~= 0 then
		local equipConfig = BaseConfig.GetEquip(hero.Equip[1].ID, hero.Equip[1].StarLevel)
		heroSkillReduction = heroSkillReduction + equipConfig.skillReduction
	end

	return heroSkillReduction / TEN_THOUSAND
end


-- 计算星将属性（atk, def, hp, mp, tfp)
-- 参数：hero: 当前计算星将
function CalHeroAttr.calHeroAttr( hero )
	local _hero = hero
	local atk = CalHeroAttr.CalHeroAtk(_hero)
	_hero.Atk = atk
	local def = CalHeroAttr.CalHeroDef(_hero)
	_hero.Def = def
	local hp = CalHeroAttr.CalHeroHP(_hero)
	_hero.HP = hp
	local mp = CalHeroAttr.CalHeroMP(_hero)
	_hero.MP = mp
	local hit = CalHeroAttr.CalHeroHit(_hero)
	_hero.Hit = hit
	local miss = CalHeroAttr.CalHeroMiss(_hero)
	_hero.Miss = miss
	local crit = CalHeroAttr.CalHeroCrit(_hero)
	_hero.Crit = crit
	local ten = CalHeroAttr.CalHeroTen(_hero)
	_hero.Ten = ten

	local tfp = CalHeroAttr.CalHeroTFP(_hero)
	_hero.TFP = tfp

	return {
		Atk = _hero.Atk, Def = _hero.Def, HP = _hero.HP, MP = _hero.MP
		, Hit = _hero.Hit, Miss = _hero.Miss, Crit = _hero.Crit, Ten = _hero.Ten
		, TFP = _hero.TFP
	}
end

-- 星将当前等级最大经验
function CalHeroAttr.HeroMaxExp( hero )
	local cfHero = BaseConfig.GetHero(hero.ID, hero.StarLevel)
	return BaseConfig.GetHeroUpgradeExp(cfHero.talent, hero.Level)
end

-- 普通技能等级
function CalHeroAttr.HeroNorSkillLevel( hero )
	local addLevel = 0
	for k,equip in pairs(hero.Equip) do
        if 0 ~= equip.ID then
            local equipConfig = BaseConfig.GetEquip(equip.ID, equip.StarLevel)
            addLevel = addLevel + equipConfig.norSkillUp
        end
    end
    local step = GameCache.Avatar.EnergyStep
	local num = GameCache.Avatar.EnergyAttrNum
    addLevel = addLevel + CalHeroAttr.calEnergyAdd(step, num, BaseConfig.ENERGYATTR_TYPE_ADDNORSKILLLEVEL)
	local cfMaterial = BaseConfig.GetHeroUpstar(hero.StarLevel)
	return (cfMaterial.NorSkill + addLevel)
end

-- 怒气技能额外加成等级
function CalHeroAttr.HeroAddRPSkillLevel(hero)
	local addLevel = 0
	for k,equip in pairs(hero.Equip) do
        if 0 ~= equip.ID then
            local equipConfig = BaseConfig.GetEquip(equip.ID, equip.StarLevel)
            addLevel = addLevel + equipConfig.rpSkillUp
        end
    end
    local step = GameCache.Avatar.EnergyStep
	local num = GameCache.Avatar.EnergyAttrNum
    addLevel = addLevel + CalHeroAttr.calEnergyAdd(step, num, BaseConfig.ENERGYATTR_TYPE_ADDRPSKILLLEVEL)
    return addLevel
end 

-- 天赋技能等级
function CalHeroAttr.HeroTFSkillLevel( hero )
	local addLevel = 0
	for k,equip in pairs(hero.Equip) do
        if 0 ~= equip.ID then
            local equipConfig = BaseConfig.GetEquip(equip.ID, equip.StarLevel)
            addLevel = addLevel + equipConfig.tfSkillUp
        end
    end
    local step = GameCache.Avatar.EnergyStep
	local num = GameCache.Avatar.EnergyAttrNum
    addLevel = addLevel + CalHeroAttr.calEnergyAdd(step, num, BaseConfig.ENERGYATTR_TYPE_ADDTFSKILLLEVEL)
	local cfMaterial = BaseConfig.GetHeroUpstar(hero.StarLevel)
	return (cfMaterial.TfSkill + addLevel)
end

-- 怒气技能等级上限
function CalHeroAttr.HeroRPSkillMaxLevel( hero )
	local cfMaterial = BaseConfig.GetHeroUpstar(hero.StarLevel)
	return cfMaterial.MaxRPSkill
end

-- 怒气技能当前等级最大经验值
function CalHeroAttr.HeroRPSkillMaxExp( hero )
	return BaseConfig.GetHeroRPSkillExp(hero.RPSkillLevel)
end

-- 攻击间隔 (ms)
function CalHeroAttr.HeroAtkInterval( hero )
	local cfHero = BaseConfig.GetHero(hero.ID, hero.StarLevel)
	-- 攻击间隔 = 基础攻击间隔 /（1+攻击速度百分比）
	local atkSpeedRatio = 0
	for _, v in ipairs(hero.Equip) do
		if v.ID ~= 0 then
			local cfEquip = BaseConfig.GetEquip(v.ID, v.StarLevel)
			atkSpeedRatio = atkSpeedRatio + cfEquip.atkSpeedRatio
		end
	end
	local per = atkSpeedRatio / TEN_THOUSAND
	local interval = math.floor(cfHero.atkSpeed / (1 + per))
	return interval
end

-- 仙女战力=仙女技能等级之和*200
function CalHeroAttr.FairyTFP(id)
	local tfp = 0
	local fairy = GameCache.GetFairyInfo(id)
	if fairy ~= nil then
		tfp = (fairy.SkillLevel[1]+fairy.SkillLevel[2]) * 200
	end
	return tfp
end


-- 阵容战力
function CalHeroAttr.FormTFP(form)
	local tfp = 0
	if form.Hero then
		for _, v in ipairs(form.Hero) do
			local hero = GameCache.GetHero(v.ID)
			if hero ~= nil then
				local heroTFP = CalHeroAttr.CalHeroTFP(hero)
				tfp = tfp + heroTFP
			end
		end
	end

	local fairyTFP = 0
	if 0 ~= form.Fairy then
		fairyTFP = CalHeroAttr.FairyTFP(form.Fairy)
	end

	tfp = tfp + fairyTFP
	return tfp
end

return CalHeroAttr
