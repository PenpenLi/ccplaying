
local _M = { }

function _M:Init()
    for key, item in pairs(self.Data) do
        item.__index = item
        for subKey, subItem in pairs(item.Difficulty_List) do
            setmetatable(subItem, item)
        end
    end
end

function _M:Get(ID, Difficulty)
    local item = self.Data[ID]
    local subItem = nil 
    if item then
        subItem = item.Difficulty_List[Difficulty]
    end

    return subItem
end

_M.Data = 
{
	[1] = 
	{
		ID              = 1,
		Name            = "洗浴中心",
		Difficulty_List = 
		{
			[1] = 
			{
				Level        = 16,
				NodeSeqList  = {
					2110001,2110002
				},
				MapID        = "LG_1_map",
				AwardDesc    = "掉落大量魂玉",
				Award        = {
					2001,3004
				},
				Strategy     = "千万不可怜香惜玉。",
				Difficulty   = 1,
				HeroRestrict = 1,
				BigBgRes     = "bg_242",
				SmallBgRes   = "bg_246",
				BossID       = 21100004,
				Desc         = "据传是中洗浴中心老板的干女儿！"
			},
			[2] = 
			{
				Level        = 40,
				NodeSeqList  = {
					2120001,2120002,2120003
				},
				MapID        = "LG_1_map",
				AwardDesc    = "掉落大量魂玉",
				Award        = {
					2001,3005
				},
				Strategy     = "需要治疗型星将上场。",
				Difficulty   = 2,
				HeroRestrict = 1,
				BigBgRes     = "bg_242",
				SmallBgRes   = "bg_246",
				BossID       = 21200007,
				Desc         = "这可是洗浴中心老板的小姨子！据说吹拉弹唱样样都会，特别是下得一手好毒。"
			},
			[3] = 
			{
				Level        = 60,
				NodeSeqList  = {
					2130001,2130002,2130003
				},
				MapID        = "LG_1_map",
				AwardDesc    = "掉落大量魂玉",
				Award        = {
					2001,3006
				},
				Strategy     = "尽量上土属性的星将揍他~",
				Difficulty   = 3,
				HeroRestrict = 1,
				BigBgRes     = "bg_242",
				SmallBgRes   = "bg_246",
				BossID       = 21300006,
				Desc         = "洗浴中心的大老板！"
			}
		}
	},
	[2] = 
	{
		ID              = 2,
		Name            = "银币仓库",
		Difficulty_List = 
		{
			[1] = 
			{
				Level        = 16,
				NodeSeqList  = {
					2000001
				},
				MapID        = "SYQ_map",
				AwardDesc    = "根据伤害掉落大量银币",
				Award        = {
					2001
				},
				Strategy     = "把这小胖猪往死里打！",
				Difficulty   = 1,
				HeroRestrict = 3,
				BigBgRes     = "bg_241",
				SmallBgRes   = "bg_248",
				BossID       = 20000001,
				Desc         = "这是一头欢快的小金猪！"
			},
			[2] = 
			{
				Level        = 40,
				NodeSeqList  = {
					2000002
				},
				MapID        = "SYQ_map",
				AwardDesc    = "根据伤害掉落大量银币",
				Award        = {
					2001
				},
				Strategy     = "把这小胖猪往死里打！",
				Difficulty   = 2,
				HeroRestrict = 3,
				BigBgRes     = "bg_241",
				SmallBgRes   = "bg_248",
				BossID       = 20000001,
				Desc         = "这是一头欢快的小金猪！"
			},
			[3] = 
			{
				Level        = 60,
				NodeSeqList  = {
					2000003
				},
				MapID        = "SYQ_map",
				AwardDesc    = "根据伤害掉落大量银币",
				Award        = {
					2001
				},
				Strategy     = "把这小胖猪往死里打！",
				Difficulty   = 3,
				HeroRestrict = 3,
				BigBgRes     = "bg_241",
				SmallBgRes   = "bg_248",
				BossID       = 20000001,
				Desc         = "这是一头欢快的小金猪！"
			}
		}
	},
	[3] = 
	{
		ID              = 3,
		Name            = "美容院",
		Difficulty_List = 
		{
			[1] = 
			{
				Level        = 16,
				NodeSeqList  = {
					2210001,2210002
				},
				MapID        = "XJ_1_map",
				AwardDesc    = "掉落大量锻造石",
				Award        = {
					2001,3007
				},
				Strategy     = "打吧，打吧，放心打。",
				Difficulty   = 1,
				HeroRestrict = 2,
				BigBgRes     = "bg_243",
				SmallBgRes   = "bg_247",
				BossID       = 22100006,
				Desc         = "美容院的前台小妹！"
			},
			[2] = 
			{
				Level        = 40,
				NodeSeqList  = {
					2220001,2220002,2220003
				},
				MapID        = "XJ_1_map",
				AwardDesc    = "掉落大量锻造石",
				Award        = {
					2001,3008
				},
				Strategy     = "小心一点。",
				Difficulty   = 2,
				HeroRestrict = 2,
				BigBgRes     = "bg_243",
				SmallBgRes   = "bg_247",
				BossID       = 22200007,
				Desc         = "美容院的人事主管，后台挺硬的！"
			},
			[3] = 
			{
				Level        = 60,
				NodeSeqList  = {
					2230001,2230002,2230003
				},
				MapID        = "XJ_1_map",
				AwardDesc    = "掉落大量锻造石",
				Award        = {
					2001,3009
				},
				Strategy     = "需要强力的输出或者带上蝎子精。",
				Difficulty   = 3,
				HeroRestrict = 2,
				BigBgRes     = "bg_243",
				SmallBgRes   = "bg_247",
				BossID       = 22300008,
				Desc         = "美容院的大姐头，拥有很强的治疗能力！"
			}
		}
	}
}

_M:Init()

return _M
