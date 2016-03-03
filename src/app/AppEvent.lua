--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 14-3-4
-- Time: 上午10:54
-- To change this template use File | Settings | File Templates.
--

--[[
把 AppEvent.Network["login"] 映射到 AppEvent.Network.Login
把 AppEvent.Network["user.login"] 映射到AppEvent.Network.User.Login
]]

local Event_mt = {
    __index = function(t, name)
        if #name > 2 then
            if string.find(name, ".") then
                local _t = t
                for name in string.gmatch(name, "([%w_]+)") do
                    _t = rawget(_t, string.ucfirst(name))
                end

                if not _t then
                    error(string.format("event key:[%s] not found!", name))
                end

                return _t
            else
                local value = rawget(t, string.ucfirst(name))
                return value
            end
        end
    end
}

local AppEvent = {
    UI = {
        Avatar = {
            LevelUp = "升级",
            VIPExp = "VIP经验",
        },
        Formations = {
            --            DragAdjust = "拖动调整",
            --            AutoAdjust = "自动调整",
            --            SlotAjust = "英雄插座",
            DragBegin = "拖动开始",
            DragEnd = "拖放结束",
            --DragMove = "拖动事件",
            DragCancel = "拖放取消",
            FormChanged = "当前阵容发生了变化",
            SelectHero = "选择了英雄",
            HeroTouched = "点击上阵英雄",
        },
        Battle = {
            Enter = "进入",
            Wait = "等待",
            Match = "寻找对手",
            MoveBy = "移动",
            Ready = "准备战斗",
            AttackBegin = "开始攻击动作",
            AttackBreakOff = "攻击动作中断",
            AttackComplete = "攻击动作完成",
            AttackInterval = "阵法间隔攻击",
            Hit = "被攻击",
            --RageSkill = "怒气技能攻击",
            RegionRageSkill = "需要手动选择区域的怒气技能",
            HeroChoiceRageSkill = "需要点击英雄头像进行选择的怒气技能",
            HPChange = "英雄血量变化",
            FighterDie = "英雄死亡",
            AttackScopeChange = "攻击范围变化",
            HeroStateChange = "状态改变",
            BattleStateChange = "战场状态变化",
            HeroDirectionChange = "英雄朝向变化",
            Walk = "走的动画",
            HeroEnterCell = "英雄到达单元格",
            HeroToCell = "英雄到达单元格中间",
            BuffAdded = "新加BUFF",
            BuffRemoved = "移除BUFF",
            BuffReplaced = "不能重复的BUFF被后来的替换",
            RageChanged = "怒气变化",
            RageComboHit = "五行技能连击",
            HitBuffAffect = "被攻击时的BUFF效果",
            MISS = "英雄闪避",
            CRIT = "暴击",
            HeroLineup = "英雄布阵完成",
            TeamLineup = "队伍布阵完成",
            TeamRelineup = "重新整理阵形完成",
            HeroRelineup = "英雄重新布阵完成",
            RegionRageSkillDrop = "范围选择怒气技能拖放结束",
            RegionRageSkillCancel = "范围选择怒气技能拖放取消",
            Kill = "杀死一个人",
            Timeout = "战斗超时",
            FollowMagicCircleAdded = "新加魔法阵",
            FollowMagicCircleReplaced = "替换魔法阵",
            FollowMagicCircleRemoved = "移除魔法阵",
            FixedMagicCircleAdded = "新加魔法阵",
            FixedMagicCircleReplaced = "替换魔法阵",
            FixedMagicCircleRemoved = "移除魔法阵",
            ContinuousSkillBegin = "持续技能开始",
            ContinuousSkillEnd = "持续技能结束",
            AITriggered = "触发AI",
            TrapSkill = "陷阱技能",
            TrapAdded = "陷阱增加",
            TrapRemoved = "陷阱移除",
            ObstacleAdded = "障碍增加",
            ObstacleRemoved = "障碍移除",
            TurretAdded = "炮台增加",
            Resurrection = "英雄复活",
            Resurrecting = "有英雄可以被复活",
            Treated = "英雄被治疗",
            FairyCool = "女神技能冷却",
            Knockedback = "被击退",
            Suction = "吸到中间",
            Immune = "免疫",
            HeroStuck = "卡死了",
            Obstacle = "障碍破碎前",
            RandomDialogue = "随机说话",
            Dialogue = "说话",
            MonsterSkill = "怪物使用技能",
            Summoning = "召唤",
            HeroCellChanged = "英雄位置(Cell)变化",
            RemoveFixedMagicCircle = "移除固定魔法阵",
            ResurrectionMonster = "复活怪物",
            Replication = "分身",
            FighterExpired = "召唤物超时",
            TurnIntoEgg = "死后成蛋",
            EggExpired = "不死鸟蛋超时（复活）",
            ProtectByturret = "受到炮台保护",
            LoseProtectionOfTurret = "失去炮台保护",
            SetHeroPos = "更新英雄的位置",
            FairyCoolPercentChange = "仙女的冷却时间变化",
            FairySkillCommand = "仙女技能释放命令",
            SummonTarget = "召唤仇恨目标",
            FriendGuard = "江湖豪杰来相助",
            TimerStart = "计时器开始",
            TimerEnd = "计时器结束",
            TeleportToCell = "瞬移到",
            Transfiguration = "变身",
        },
        Hero = {
            UpgradeLevelAndStar = "星将升级、升星",
            UpdateHeroInfo = "更新星将信息",
            UpdateHeroList = "更新星将列表信息",
            UpdateAttribute = "更新星将属性",
            UpdateWearEquip = "更新穿戴装备",
            UpdateWearSkin = "更新穿戴时装",
            UpdateEquipListView = "更新装备列表",
            UpdateFateCircle = "更新显示缘分圆圈",
            UpdateEquipIntensify = "更新装备强化显示",
            ChangeEquipOrSkin = "改变装备显示或者时装显示",
            ChangeSkin = "换肤",
            UpgradeEffect = "升级特效",
            IsShowAlert = "显示专属装备、升星的提示",
            RefreshEquipMent = "刷新装备列表",
            RefreshTrump = "刷新法宝列表",
            RefreshSkin = "刷新时装列表",
            AddChildNode = "添加子节点",
            CloseEquipTips = "关闭tips",
        },
        Tips = {
            HeroUpgradeStar = "星将升星",
            EquipUpgradeStar = "装备升星",
        },
        Friend = {
            UpgradeFriend = "更新好友拥有数",
            Hint = "提示可领取体力和好友申请",
        },
        Box = {
            MiddleToBig = "面板由中等变为最大",
            SmallToBig = "面板由最小变为最大",
            IsTouchEnable = "是否允许点击",
        },
        Pay = {
            UpdatePayNode = "更新主界面付费栏",
        },
        Heartbeat = {
            Bee = "小蜜蜂",
            Heart = "更新信息提示",
            Chat = "更新聊天信息"
        },
        MainLayer = {
            updateAlert = "更新主界面的提示",
            OpenSystem = "开新功能",
            RefreshOthers = "刷新主界面其他玩家",
        },
        Task = {
            GetCurrTaskID = "获取前往的任务ID",
            DrawAward = "领取奖励",
        },
        Activity = {
            DrawAward = "领取成长基金奖励",
            BuyFund = "购买成长基金", 
            LoginAward = "领取登录目标奖励",
        },
        Cache = {
            FormChanged = "阵容变化",
            HeroChanged = "英雄变化",
        },
        Home = {
            SyncHomeData = "同步家园数据", 
            ExchangeBuild = "变换建筑造型",
            UpdateAvatar = "更新玩家信息",
            CountDown = "掠夺倒计时",
            IsLoot = "是否正处于掠夺中",
        },
        Recycle = {
            isShowTips = "点击装备时是否显示tips",
        },
        Package = {
            isFragCompound = "包裹中是否有可合成的碎片",
        },
        Tips = {
            UpdateInfo = "更新Tips信息",
        },
        NewbieGuide = {
            CreateGuide = "创建指引",
            OpenGuide = "打开指引",
            ResetGuide = "重置指引",
            CloseGuide = "关闭指引",
            SaveGuide = "保存点",
            CreateSystem = "创建指引",
            OpenSystem = "打开指引",
            ResetSystem = "重置指引",
            CloseSystem = "关闭指引",
        },
        Fairy = {
            UpdateFairyInfo = "刷新仙女信息",
            UpdateGiftView = "更新礼物列表",
            Upgrade = "仙女升级",
        },
        Message = {
            Message = "滚动消息",
        },
    }
}

-- 初始化程序运行时事件名(初始值只起注释作用)
function InitializeEvents(p, t)
    local _p = p or ""
    if type(t) == "table" then
        setmetatable(t, Event_mt)
        for k, v in pairs(t) do
            local evtName = _p .. "." .. k
            if type(v) ~= "table" then
                if type(k) ~= "number" then
                    t[k] = evtName
                end
            else
                InitializeEvents(evtName, v)
            end
        end
    end
end

return AppEvent