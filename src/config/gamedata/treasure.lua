
local _M = { }

function _M:Init()
    for key, item in pairs(self.Data) do
        item.__index = item
        for subKey, subItem in pairs(item.Seat_List) do
            setmetatable(subItem, item)
        end
    end
end

function _M:Get(ID, Seat)
    local item = self.Data[ID]
    local subItem = nil 
    if item then
        subItem = item.Seat_List[Seat]
    end

    return subItem
end

_M.Data = 
{
	[1122] = 
	{
		ID        = 1122,
		Seat_List = 
		{
			[1] = 
			{
				EnergyID = 150,
				Name     = "思想政治碎片一",
				Icon     = "baowu_001",
				UID      = 11221,
				Seat     = 1
			},
			[2] = 
			{
				EnergyID = 150,
				Name     = "思想政治碎片二",
				Icon     = "baowu_001",
				UID      = 11222,
				Seat     = 2
			},
			[3] = 
			{
				EnergyID = 150,
				Name     = "思想政治碎片三",
				Icon     = "baowu_001",
				UID      = 11223,
				Seat     = 3
			},
			[4] = 
			{
				EnergyID = 150,
				Name     = "思想政治碎片四",
				Icon     = "baowu_001",
				UID      = 11224,
				Seat     = 4
			},
			[5] = 
			{
				EnergyID = 150,
				Name     = "思想政治碎片五",
				Icon     = "baowu_001",
				UID      = 11225,
				Seat     = 5
			}
		}
	},
	[1123] = 
	{
		ID        = 1123,
		Seat_List = 
		{
			[1] = 
			{
				EnergyID = 138,
				Name     = "托福词汇碎片一",
				Icon     = "baowu_002",
				UID      = 11231,
				Seat     = 1
			},
			[2] = 
			{
				EnergyID = 138,
				Name     = "托福词汇碎片二",
				Icon     = "baowu_002",
				UID      = 11232,
				Seat     = 2
			},
			[3] = 
			{
				EnergyID = 138,
				Name     = "托福词汇碎片三",
				Icon     = "baowu_002",
				UID      = 11233,
				Seat     = 3
			},
			[4] = 
			{
				EnergyID = 138,
				Name     = "托福词汇碎片四",
				Icon     = "baowu_002",
				UID      = 11234,
				Seat     = 4
			},
			[5] = 
			{
				EnergyID = 138,
				Name     = "托福词汇碎片五",
				Icon     = "baowu_002",
				UID      = 11235,
				Seat     = 5
			}
		}
	},
	[1124] = 
	{
		ID        = 1124,
		Seat_List = 
		{
			[1] = 
			{
				EnergyID = 120,
				Name     = "黄冈密卷碎片一",
				Icon     = "baowu_003",
				UID      = 11241,
				Seat     = 1
			},
			[2] = 
			{
				EnergyID = 120,
				Name     = "黄冈密卷碎片二",
				Icon     = "baowu_003",
				UID      = 11242,
				Seat     = 2
			},
			[3] = 
			{
				EnergyID = 120,
				Name     = "黄冈密卷碎片三",
				Icon     = "baowu_003",
				UID      = 11243,
				Seat     = 3
			},
			[4] = 
			{
				EnergyID = 120,
				Name     = "黄冈密卷碎片四",
				Icon     = "baowu_003",
				UID      = 11244,
				Seat     = 4
			},
			[5] = 
			{
				EnergyID = 120,
				Name     = "黄冈密卷碎片五",
				Icon     = "baowu_003",
				UID      = 11245,
				Seat     = 5
			}
		}
	},
	[1125] = 
	{
		ID        = 1125,
		Seat_List = 
		{
			[1] = 
			{
				EnergyID = 114,
				Name     = "高考真题碎片一",
				Icon     = "baowu_004",
				UID      = 11251,
				Seat     = 1
			},
			[2] = 
			{
				EnergyID = 114,
				Name     = "高考真题碎片二",
				Icon     = "baowu_004",
				UID      = 11252,
				Seat     = 2
			},
			[3] = 
			{
				EnergyID = 114,
				Name     = "高考真题碎片三",
				Icon     = "baowu_004",
				UID      = 11253,
				Seat     = 3
			},
			[4] = 
			{
				EnergyID = 114,
				Name     = "高考真题碎片四",
				Icon     = "baowu_004",
				UID      = 11254,
				Seat     = 4
			},
			[5] = 
			{
				EnergyID = 114,
				Name     = "高考真题碎片五",
				Icon     = "baowu_004",
				UID      = 11255,
				Seat     = 5
			}
		}
	},
	[1126] = 
	{
		ID        = 1126,
		Seat_List = 
		{
			[1] = 
			{
				EnergyID = 96,
				Name     = "高中历史碎片一",
				Icon     = "baowu_005",
				UID      = 11261,
				Seat     = 1
			},
			[2] = 
			{
				EnergyID = 96,
				Name     = "高中历史碎片二",
				Icon     = "baowu_005",
				UID      = 11262,
				Seat     = 2
			},
			[3] = 
			{
				EnergyID = 96,
				Name     = "高中历史碎片三",
				Icon     = "baowu_005",
				UID      = 11263,
				Seat     = 3
			},
			[4] = 
			{
				EnergyID = 96,
				Name     = "高中历史碎片四",
				Icon     = "baowu_005",
				UID      = 11264,
				Seat     = 4
			}
		}
	},
	[1127] = 
	{
		ID        = 1127,
		Seat_List = 
		{
			[1] = 
			{
				EnergyID = 84,
				Name     = "高中物理碎片一",
				Icon     = "baowu_006",
				UID      = 11271,
				Seat     = 1
			},
			[2] = 
			{
				EnergyID = 84,
				Name     = "高中物理碎片二",
				Icon     = "baowu_006",
				UID      = 11272,
				Seat     = 2
			},
			[3] = 
			{
				EnergyID = 84,
				Name     = "高中物理碎片三",
				Icon     = "baowu_006",
				UID      = 11273,
				Seat     = 3
			},
			[4] = 
			{
				EnergyID = 84,
				Name     = "高中物理碎片四",
				Icon     = "baowu_006",
				UID      = 11274,
				Seat     = 4
			}
		}
	},
	[1128] = 
	{
		ID        = 1128,
		Seat_List = 
		{
			[1] = 
			{
				EnergyID = 66,
				Name     = "初中化学碎片一",
				Icon     = "baowu_007",
				UID      = 11281,
				Seat     = 1
			},
			[2] = 
			{
				EnergyID = 66,
				Name     = "初中化学碎片二",
				Icon     = "baowu_007",
				UID      = 11282,
				Seat     = 2
			},
			[3] = 
			{
				EnergyID = 66,
				Name     = "初中化学碎片三",
				Icon     = "baowu_007",
				UID      = 11283,
				Seat     = 3
			}
		}
	},
	[1129] = 
	{
		ID        = 1129,
		Seat_List = 
		{
			[1] = 
			{
				EnergyID = 48,
				Name     = "生理卫生碎片一",
				Icon     = "baowu_008",
				UID      = 11291,
				Seat     = 1
			},
			[2] = 
			{
				EnergyID = 48,
				Name     = "生理卫生碎片二",
				Icon     = "baowu_008",
				UID      = 11292,
				Seat     = 2
			},
			[3] = 
			{
				EnergyID = 48,
				Name     = "生理卫生碎片三",
				Icon     = "baowu_008",
				UID      = 11293,
				Seat     = 3
			}
		}
	},
	[1130] = 
	{
		ID        = 1130,
		Seat_List = 
		{
			[1] = 
			{
				EnergyID = 18,
				Name     = "九九乘法碎片一",
				Icon     = "baowu_009",
				UID      = 11301,
				Seat     = 1
			},
			[2] = 
			{
				EnergyID = 18,
				Name     = "九九乘法碎片二",
				Icon     = "baowu_009",
				UID      = 11302,
				Seat     = 2
			}
		}
	},
	[1131] = 
	{
		ID        = 1131,
		Seat_List = 
		{
			[1] = 
			{
				EnergyID = 0,
				Name     = "汉语拼音碎片一",
				Icon     = "baowu_0010",
				UID      = 11311,
				Seat     = 1
			},
			[2] = 
			{
				EnergyID = 0,
				Name     = "汉语拼音碎片二",
				Icon     = "baowu_0010",
				UID      = 11312,
				Seat     = 2
			}
		}
	},
	[1132] = 
	{
		ID        = 1132,
		Seat_List = 
		{
			[1] = 
			{
				EnergyID = 156,
				Name     = "土豪任性符碎片一",
				Icon     = "baowu_0011",
				UID      = 11321,
				Seat     = 1
			},
			[2] = 
			{
				EnergyID = 156,
				Name     = "土豪任性符碎片二",
				Icon     = "baowu_0011",
				UID      = 11322,
				Seat     = 2
			},
			[3] = 
			{
				EnergyID = 156,
				Name     = "土豪任性符碎片三",
				Icon     = "baowu_0011",
				UID      = 11323,
				Seat     = 3
			},
			[4] = 
			{
				EnergyID = 156,
				Name     = "土豪任性符碎片四",
				Icon     = "baowu_0011",
				UID      = 11324,
				Seat     = 4
			},
			[5] = 
			{
				EnergyID = 156,
				Name     = "土豪任性符碎片五",
				Icon     = "baowu_0011",
				UID      = 11325,
				Seat     = 5
			}
		}
	},
	[1133] = 
	{
		ID        = 1133,
		Seat_List = 
		{
			[1] = 
			{
				EnergyID = 144,
				Name     = "人生赢家符碎片一",
				Icon     = "baowu_0012",
				UID      = 11331,
				Seat     = 1
			},
			[2] = 
			{
				EnergyID = 144,
				Name     = "人生赢家符碎片二",
				Icon     = "baowu_0012",
				UID      = 11332,
				Seat     = 2
			},
			[3] = 
			{
				EnergyID = 144,
				Name     = "人生赢家符碎片三",
				Icon     = "baowu_0012",
				UID      = 11333,
				Seat     = 3
			},
			[4] = 
			{
				EnergyID = 144,
				Name     = "人生赢家符碎片四",
				Icon     = "baowu_0012",
				UID      = 11334,
				Seat     = 4
			},
			[5] = 
			{
				EnergyID = 144,
				Name     = "人生赢家符碎片五",
				Icon     = "baowu_0012",
				UID      = 11335,
				Seat     = 5
			}
		}
	},
	[1134] = 
	{
		ID        = 1134,
		Seat_List = 
		{
			[1] = 
			{
				EnergyID = 126,
				Name     = "买房脱单符碎片一",
				Icon     = "baowu_0013",
				UID      = 11341,
				Seat     = 1
			},
			[2] = 
			{
				EnergyID = 126,
				Name     = "买房脱单符碎片二",
				Icon     = "baowu_0013",
				UID      = 11342,
				Seat     = 2
			},
			[3] = 
			{
				EnergyID = 126,
				Name     = "买房脱单符碎片三",
				Icon     = "baowu_0013",
				UID      = 11343,
				Seat     = 3
			},
			[4] = 
			{
				EnergyID = 126,
				Name     = "买房脱单符碎片四",
				Icon     = "baowu_0013",
				UID      = 11344,
				Seat     = 4
			},
			[5] = 
			{
				EnergyID = 126,
				Name     = "买房脱单符碎片五",
				Icon     = "baowu_0013",
				UID      = 11345,
				Seat     = 5
			}
		}
	},
	[1135] = 
	{
		ID        = 1135,
		Seat_List = 
		{
			[1] = 
			{
				EnergyID = 120,
				Name     = "宅腐双修符碎片一",
				Icon     = "baowu_0014",
				UID      = 11351,
				Seat     = 1
			},
			[2] = 
			{
				EnergyID = 120,
				Name     = "宅腐双修符碎片二",
				Icon     = "baowu_0014",
				UID      = 11352,
				Seat     = 2
			},
			[3] = 
			{
				EnergyID = 120,
				Name     = "宅腐双修符碎片三",
				Icon     = "baowu_0014",
				UID      = 11353,
				Seat     = 3
			},
			[4] = 
			{
				EnergyID = 120,
				Name     = "宅腐双修符碎片四",
				Icon     = "baowu_0014",
				UID      = 11354,
				Seat     = 4
			},
			[5] = 
			{
				EnergyID = 120,
				Name     = "宅腐双修符碎片五",
				Icon     = "baowu_0014",
				UID      = 11355,
				Seat     = 5
			}
		}
	},
	[1136] = 
	{
		ID        = 1136,
		Seat_List = 
		{
			[1] = 
			{
				EnergyID = 102,
				Name     = "节操神符碎片一",
				Icon     = "baowu_0015",
				UID      = 11361,
				Seat     = 1
			},
			[2] = 
			{
				EnergyID = 102,
				Name     = "节操神符碎片二",
				Icon     = "baowu_0015",
				UID      = 11362,
				Seat     = 2
			},
			[3] = 
			{
				EnergyID = 102,
				Name     = "节操神符碎片三",
				Icon     = "baowu_0015",
				UID      = 11363,
				Seat     = 3
			},
			[4] = 
			{
				EnergyID = 102,
				Name     = "节操神符碎片四",
				Icon     = "baowu_0015",
				UID      = 11364,
				Seat     = 4
			}
		}
	},
	[1137] = 
	{
		ID        = 1137,
		Seat_List = 
		{
			[1] = 
			{
				EnergyID = 90,
				Name     = "查水表符碎片一",
				Icon     = "baowu_0016",
				UID      = 11371,
				Seat     = 1
			},
			[2] = 
			{
				EnergyID = 90,
				Name     = "查水表符碎片二",
				Icon     = "baowu_0016",
				UID      = 11372,
				Seat     = 2
			},
			[3] = 
			{
				EnergyID = 90,
				Name     = "查水表符碎片三",
				Icon     = "baowu_0016",
				UID      = 11373,
				Seat     = 3
			},
			[4] = 
			{
				EnergyID = 90,
				Name     = "查水表符碎片四",
				Icon     = "baowu_0016",
				UID      = 11374,
				Seat     = 4
			}
		}
	},
	[1138] = 
	{
		ID        = 1138,
		Seat_List = 
		{
			[1] = 
			{
				EnergyID = 72,
				Name     = "剩女咒碎片一",
				Icon     = "baowu_0017",
				UID      = 11381,
				Seat     = 1
			},
			[2] = 
			{
				EnergyID = 72,
				Name     = "剩女咒碎片二",
				Icon     = "baowu_0017",
				UID      = 11382,
				Seat     = 2
			},
			[3] = 
			{
				EnergyID = 72,
				Name     = "剩女咒碎片三",
				Icon     = "baowu_0017",
				UID      = 11383,
				Seat     = 3
			}
		}
	},
	[1139] = 
	{
		ID        = 1139,
		Seat_List = 
		{
			[1] = 
			{
				EnergyID = 54,
				Name     = "吊丝咒碎片一",
				Icon     = "baowu_0018",
				UID      = 11391,
				Seat     = 1
			},
			[2] = 
			{
				EnergyID = 54,
				Name     = "吊丝咒碎片二",
				Icon     = "baowu_0018",
				UID      = 11392,
				Seat     = 2
			},
			[3] = 
			{
				EnergyID = 54,
				Name     = "吊丝咒碎片三",
				Icon     = "baowu_0018",
				UID      = 11393,
				Seat     = 3
			}
		}
	},
	[1140] = 
	{
		ID        = 1140,
		Seat_List = 
		{
			[1] = 
			{
				EnergyID = 24,
				Name     = "卖萌咒碎片一",
				Icon     = "baowu_0019",
				UID      = 11401,
				Seat     = 1
			},
			[2] = 
			{
				EnergyID = 24,
				Name     = "卖萌咒碎片二",
				Icon     = "baowu_0019",
				UID      = 11402,
				Seat     = 2
			}
		}
	},
	[1141] = 
	{
		ID        = 1141,
		Seat_List = 
		{
			[1] = 
			{
				EnergyID = 0,
				Name     = "酱油咒碎片一",
				Icon     = "baowu_0020",
				UID      = 11411,
				Seat     = 1
			},
			[2] = 
			{
				EnergyID = 0,
				Name     = "酱油咒碎片二",
				Icon     = "baowu_0020",
				UID      = 11412,
				Seat     = 2
			}
		}
	}
}

_M:Init()

return _M
