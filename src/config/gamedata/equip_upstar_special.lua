
local _M = { }

function _M:Init()
    for key, item in pairs(self.Data) do
        item.__index = item
        for subKey, subItem in pairs(item.StarLevel_List) do
            setmetatable(subItem, item)
        end
    end
end

function _M:Get(ID, StarLevel)
    local item = self.Data[ID]
    local subItem = nil 
    if item then
        subItem = item.StarLevel_List[StarLevel]
    end

    return subItem
end

_M.Data = 
{
	[1001] = 
	{
		ID             = 1001,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1001,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1001,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1001,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1001,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1001,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1001,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1001,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1001,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1001,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1001,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1001,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1001,
				PropsID   = 2003
			}
		}
	},
	[1002] = 
	{
		ID             = 1002,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1002,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1002,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1002,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1002,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1002,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1002,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1002,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1002,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1002,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1002,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1002,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1002,
				PropsID   = 2003
			}
		}
	},
	[1003] = 
	{
		ID             = 1003,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1003,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1003,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1003,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1003,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1003,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1003,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1003,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1003,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1003,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1003,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1003,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1003,
				PropsID   = 2003
			}
		}
	},
	[1004] = 
	{
		ID             = 1004,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1004,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1004,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1004,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1004,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1004,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1004,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1004,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1004,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1004,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1004,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1004,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1004,
				PropsID   = 2003
			}
		}
	},
	[1005] = 
	{
		ID             = 1005,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1005,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1005,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1005,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1005,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1005,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1005,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1005,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1005,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1005,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1005,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1005,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1005,
				PropsID   = 2003
			}
		}
	},
	[1006] = 
	{
		ID             = 1006,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1006,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1006,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1006,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1006,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1006,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1006,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1006,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1006,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1006,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1006,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1006,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1006,
				PropsID   = 2003
			}
		}
	},
	[1007] = 
	{
		ID             = 1007,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1007,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1007,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1007,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1007,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1007,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1007,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1007,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1007,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1007,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1007,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1007,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1007,
				PropsID   = 2003
			}
		}
	},
	[1008] = 
	{
		ID             = 1008,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1008,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1008,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1008,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1008,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1008,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1008,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1008,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1008,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1008,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1008,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1008,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1008,
				PropsID   = 2003
			}
		}
	},
	[1009] = 
	{
		ID             = 1009,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1009,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1009,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1009,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1009,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1009,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1009,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1009,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1009,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1009,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1009,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1009,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1009,
				PropsID   = 2003
			}
		}
	},
	[1010] = 
	{
		ID             = 1010,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1010,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1010,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1010,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1010,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1010,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1010,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1010,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1010,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1010,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1010,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1010,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1010,
				PropsID   = 2003
			}
		}
	},
	[1011] = 
	{
		ID             = 1011,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1011,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1011,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1011,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1011,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1011,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1011,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1011,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1011,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1011,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1011,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1011,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1011,
				PropsID   = 2003
			}
		}
	},
	[1012] = 
	{
		ID             = 1012,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1012,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1012,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1012,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1012,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1012,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1012,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1012,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1012,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1012,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1012,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1012,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1012,
				PropsID   = 2003
			}
		}
	},
	[1013] = 
	{
		ID             = 1013,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1013,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1013,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1013,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1013,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1013,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1013,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1013,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1013,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1013,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1013,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1013,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1013,
				PropsID   = 2003
			}
		}
	},
	[1014] = 
	{
		ID             = 1014,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1014,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1014,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1014,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1014,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1014,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1014,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1014,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1014,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1014,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1014,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1014,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1014,
				PropsID   = 2003
			}
		}
	},
	[1015] = 
	{
		ID             = 1015,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1015,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1015,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1015,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1015,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1015,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1015,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1015,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1015,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1015,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1015,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1015,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1015,
				PropsID   = 2003
			}
		}
	},
	[1016] = 
	{
		ID             = 1016,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1016,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1016,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1016,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1016,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1016,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1016,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1016,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1016,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1016,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1016,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1016,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1016,
				PropsID   = 2003
			}
		}
	},
	[1017] = 
	{
		ID             = 1017,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1017,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1017,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1017,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1017,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1017,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1017,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1017,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1017,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1017,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1017,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1017,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1017,
				PropsID   = 2003
			}
		}
	},
	[1018] = 
	{
		ID             = 1018,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1018,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1018,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1018,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1018,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1018,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1018,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1018,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1018,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1018,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1018,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1018,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1018,
				PropsID   = 2003
			}
		}
	},
	[1019] = 
	{
		ID             = 1019,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1019,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1019,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1019,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1019,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1019,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1019,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1019,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1019,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1019,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1019,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1019,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1019,
				PropsID   = 2003
			}
		}
	},
	[1020] = 
	{
		ID             = 1020,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1020,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1020,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1020,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1020,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1020,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1020,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1020,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1020,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1020,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1020,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1020,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1020,
				PropsID   = 2003
			}
		}
	},
	[1021] = 
	{
		ID             = 1021,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1021,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1021,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1021,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1021,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1021,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1021,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1021,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1021,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1021,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1021,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1021,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1021,
				PropsID   = 2003
			}
		}
	},
	[1022] = 
	{
		ID             = 1022,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1022,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1022,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1022,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1022,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1022,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1022,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1022,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1022,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1022,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1022,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1022,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1022,
				PropsID   = 2003
			}
		}
	},
	[1023] = 
	{
		ID             = 1023,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1023,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1023,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1023,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1023,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1023,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1023,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1023,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1023,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1023,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1023,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1023,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1023,
				PropsID   = 2003
			}
		}
	},
	[1024] = 
	{
		ID             = 1024,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1024,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1024,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1024,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1024,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1024,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1024,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1024,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1024,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1024,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1024,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1024,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1024,
				PropsID   = 2003
			}
		}
	},
	[1025] = 
	{
		ID             = 1025,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1025,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1025,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1025,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1025,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1025,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1025,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1025,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1025,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1025,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1025,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1025,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1025,
				PropsID   = 2003
			}
		}
	},
	[1026] = 
	{
		ID             = 1026,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1026,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1026,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1026,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1026,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1026,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1026,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1026,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1026,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1026,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1026,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1026,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1026,
				PropsID   = 2003
			}
		}
	},
	[1027] = 
	{
		ID             = 1027,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1027,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1027,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1027,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1027,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1027,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1027,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1027,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1027,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1027,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1027,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1027,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1027,
				PropsID   = 2003
			}
		}
	},
	[1028] = 
	{
		ID             = 1028,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1028,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1028,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1028,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1028,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1028,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1028,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1028,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1028,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1028,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1028,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1028,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1028,
				PropsID   = 2003
			}
		}
	},
	[1029] = 
	{
		ID             = 1029,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1029,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1029,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1029,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1029,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1029,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1029,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1029,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1029,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1029,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1029,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1029,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1029,
				PropsID   = 2003
			}
		}
	},
	[1030] = 
	{
		ID             = 1030,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1030,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1030,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1030,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1030,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1030,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1030,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1030,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1030,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1030,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1030,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1030,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1030,
				PropsID   = 2003
			}
		}
	},
	[1031] = 
	{
		ID             = 1031,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1031,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1031,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1031,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1031,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1031,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1031,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1031,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1031,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1031,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1031,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1031,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1031,
				PropsID   = 2003
			}
		}
	},
	[1032] = 
	{
		ID             = 1032,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1032,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1032,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1032,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1032,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1032,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1032,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1032,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1032,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1032,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1032,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1032,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1032,
				PropsID   = 2003
			}
		}
	},
	[1033] = 
	{
		ID             = 1033,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1033,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1033,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1033,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1033,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1033,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1033,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1033,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1033,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1033,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1033,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1033,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1033,
				PropsID   = 2003
			}
		}
	},
	[1034] = 
	{
		ID             = 1034,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1034,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1034,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1034,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1034,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1034,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1034,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1034,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1034,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1034,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1034,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1034,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1034,
				PropsID   = 2003
			}
		}
	},
	[1035] = 
	{
		ID             = 1035,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1035,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1035,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1035,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1035,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1035,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1035,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1035,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1035,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1035,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1035,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1035,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1035,
				PropsID   = 2003
			}
		}
	},
	[1036] = 
	{
		ID             = 1036,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1036,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1036,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1036,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1036,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1036,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1036,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1036,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1036,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1036,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1036,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1036,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1036,
				PropsID   = 2003
			}
		}
	},
	[1037] = 
	{
		ID             = 1037,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1037,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1037,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1037,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1037,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1037,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1037,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1037,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1037,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1037,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1037,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1037,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1037,
				PropsID   = 2003
			}
		}
	},
	[1038] = 
	{
		ID             = 1038,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1038,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1038,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1038,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1038,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1038,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1038,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1038,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1038,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1038,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1038,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1038,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1038,
				PropsID   = 2003
			}
		}
	},
	[1039] = 
	{
		ID             = 1039,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1039,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1039,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1039,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1039,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1039,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1039,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1039,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1039,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1039,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1039,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1039,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1039,
				PropsID   = 2003
			}
		}
	},
	[1040] = 
	{
		ID             = 1040,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1040,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1040,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1040,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1040,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1040,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1040,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1040,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1040,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1040,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1040,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1040,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1040,
				PropsID   = 2003
			}
		}
	},
	[1041] = 
	{
		ID             = 1041,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1041,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1041,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1041,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1041,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1041,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1041,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1041,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1041,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1041,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1041,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1041,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1041,
				PropsID   = 2003
			}
		}
	},
	[1042] = 
	{
		ID             = 1042,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1042,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1042,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1042,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1042,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1042,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1042,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1042,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1042,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1042,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1042,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1042,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1042,
				PropsID   = 2003
			}
		}
	},
	[1043] = 
	{
		ID             = 1043,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1043,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1043,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1043,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1043,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1043,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1043,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1043,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1043,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1043,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1043,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1043,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1043,
				PropsID   = 2003
			}
		}
	},
	[1044] = 
	{
		ID             = 1044,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1044,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1044,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1044,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1044,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1044,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1044,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1044,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1044,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1044,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1044,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1044,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1044,
				PropsID   = 2003
			}
		}
	},
	[1045] = 
	{
		ID             = 1045,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1045,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1045,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1045,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1045,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1045,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1045,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1045,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1045,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1045,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1045,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1045,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1045,
				PropsID   = 2003
			}
		}
	},
	[1046] = 
	{
		ID             = 1046,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1046,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1046,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1046,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1046,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1046,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1046,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1046,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1046,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1046,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1046,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1046,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1046,
				PropsID   = 2003
			}
		}
	},
	[1047] = 
	{
		ID             = 1047,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1047,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1047,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1047,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1047,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1047,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1047,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1047,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1047,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1047,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1047,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1047,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1047,
				PropsID   = 2003
			}
		}
	},
	[1048] = 
	{
		ID             = 1048,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1048,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1048,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1048,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1048,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1048,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1048,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1048,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1048,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1048,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1048,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1048,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1048,
				PropsID   = 2003
			}
		}
	},
	[1049] = 
	{
		ID             = 1049,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1049,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1049,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1049,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1049,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1049,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1049,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1049,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1049,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1049,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1049,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1049,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1049,
				PropsID   = 2003
			}
		}
	},
	[1050] = 
	{
		ID             = 1050,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1050,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1050,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1050,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1050,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1050,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1050,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1050,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1050,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1050,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1050,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1050,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1050,
				PropsID   = 2003
			}
		}
	},
	[1051] = 
	{
		ID             = 1051,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1051,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1051,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1051,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1051,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1051,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1051,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1051,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1051,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1051,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1051,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1051,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1051,
				PropsID   = 2003
			}
		}
	},
	[1052] = 
	{
		ID             = 1052,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1052,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1052,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1052,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1052,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1052,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1052,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1052,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1052,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1052,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1052,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1052,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1052,
				PropsID   = 2003
			}
		}
	},
	[1053] = 
	{
		ID             = 1053,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1053,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1053,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1053,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1053,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1053,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1053,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1053,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1053,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1053,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1053,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1053,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1053,
				PropsID   = 2003
			}
		}
	},
	[1054] = 
	{
		ID             = 1054,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1054,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1054,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1054,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1054,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1054,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1054,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1054,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1054,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1054,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1054,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1054,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1054,
				PropsID   = 2003
			}
		}
	},
	[1055] = 
	{
		ID             = 1055,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1055,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1055,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1055,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1055,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1055,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1055,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1055,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1055,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1055,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1055,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1055,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1055,
				PropsID   = 2003
			}
		}
	},
	[1056] = 
	{
		ID             = 1056,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1056,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1056,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1056,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1056,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1056,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1056,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1056,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1056,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1056,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1056,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1056,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1056,
				PropsID   = 2003
			}
		}
	},
	[1057] = 
	{
		ID             = 1057,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1057,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1057,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1057,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1057,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1057,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1057,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1057,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1057,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1057,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1057,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1057,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1057,
				PropsID   = 2003
			}
		}
	},
	[1058] = 
	{
		ID             = 1058,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1058,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1058,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1058,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1058,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1058,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1058,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1058,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1058,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1058,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1058,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1058,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1058,
				PropsID   = 2003
			}
		}
	},
	[1059] = 
	{
		ID             = 1059,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1059,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1059,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1059,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1059,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1059,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1059,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1059,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1059,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1059,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1059,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1059,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1059,
				PropsID   = 2003
			}
		}
	},
	[1060] = 
	{
		ID             = 1060,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1060,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1060,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1060,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1060,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1060,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1060,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1060,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1060,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1060,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1060,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1060,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1060,
				PropsID   = 2003
			}
		}
	},
	[1061] = 
	{
		ID             = 1061,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1061,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1061,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1061,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1061,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1061,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1061,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1061,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1061,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1061,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1061,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1061,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1061,
				PropsID   = 2003
			}
		}
	},
	[1062] = 
	{
		ID             = 1062,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1062,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1062,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1062,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1062,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1062,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1062,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1062,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1062,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1062,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1062,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1062,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1062,
				PropsID   = 2003
			}
		}
	},
	[1063] = 
	{
		ID             = 1063,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1063,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1063,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1063,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1063,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1063,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1063,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1063,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1063,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1063,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1063,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1063,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1063,
				PropsID   = 2003
			}
		}
	},
	[1064] = 
	{
		ID             = 1064,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1064,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1064,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1064,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1064,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1064,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1064,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1064,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1064,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1064,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1064,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1064,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1064,
				PropsID   = 2003
			}
		}
	},
	[1065] = 
	{
		ID             = 1065,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1065,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1065,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1065,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1065,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1065,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1065,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1065,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1065,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1065,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1065,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1065,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1065,
				PropsID   = 2003
			}
		}
	},
	[1066] = 
	{
		ID             = 1066,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1066,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1066,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1066,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1066,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1066,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1066,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1066,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1066,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1066,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1066,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1066,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1066,
				PropsID   = 2003
			}
		}
	},
	[1067] = 
	{
		ID             = 1067,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1067,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1067,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1067,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1067,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1067,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1067,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1067,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1067,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1067,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1067,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1067,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1067,
				PropsID   = 2003
			}
		}
	},
	[1068] = 
	{
		ID             = 1068,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1068,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1068,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1068,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1068,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1068,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1068,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1068,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1068,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1068,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1068,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1068,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1068,
				PropsID   = 2003
			}
		}
	},
	[1069] = 
	{
		ID             = 1069,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1069,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1069,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1069,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1069,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1069,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1069,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1069,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1069,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1069,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1069,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1069,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1069,
				PropsID   = 2003
			}
		}
	},
	[1070] = 
	{
		ID             = 1070,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1070,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1070,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1070,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1070,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1070,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1070,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1070,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1070,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1070,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1070,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1070,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1070,
				PropsID   = 2003
			}
		}
	},
	[1071] = 
	{
		ID             = 1071,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1071,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1071,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1071,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1071,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1071,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1071,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1071,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1071,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1071,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1071,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1071,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1071,
				PropsID   = 2003
			}
		}
	},
	[1072] = 
	{
		ID             = 1072,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1072,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1072,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1072,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1072,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1072,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1072,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1072,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1072,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1072,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1072,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1072,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1072,
				PropsID   = 2003
			}
		}
	},
	[1073] = 
	{
		ID             = 1073,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1073,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1073,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1073,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1073,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1073,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1073,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1073,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1073,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1073,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1073,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1073,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1073,
				PropsID   = 2003
			}
		}
	},
	[1074] = 
	{
		ID             = 1074,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1074,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1074,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1074,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1074,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1074,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1074,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1074,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1074,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1074,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1074,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1074,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1074,
				PropsID   = 2003
			}
		}
	},
	[1075] = 
	{
		ID             = 1075,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1075,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1075,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1075,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1075,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1075,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1075,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1075,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1075,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1075,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1075,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1075,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1075,
				PropsID   = 2003
			}
		}
	},
	[1076] = 
	{
		ID             = 1076,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1076,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1076,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1076,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1076,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1076,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1076,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1076,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1076,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1076,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1076,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1076,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1076,
				PropsID   = 2003
			}
		}
	},
	[1077] = 
	{
		ID             = 1077,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1077,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1077,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1077,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1077,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1077,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1077,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1077,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1077,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1077,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1077,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1077,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1077,
				PropsID   = 2003
			}
		}
	},
	[1078] = 
	{
		ID             = 1078,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1078,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1078,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1078,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1078,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1078,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1078,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1078,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1078,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1078,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1078,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1078,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1078,
				PropsID   = 2003
			}
		}
	},
	[1079] = 
	{
		ID             = 1079,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1079,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1079,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1079,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1079,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1079,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1079,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1079,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1079,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1079,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1079,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1079,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1079,
				PropsID   = 2003
			}
		}
	},
	[1080] = 
	{
		ID             = 1080,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1080,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1080,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1080,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1080,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1080,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1080,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1080,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1080,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1080,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1080,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1080,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1080,
				PropsID   = 2003
			}
		}
	},
	[1081] = 
	{
		ID             = 1081,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1081,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1081,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1081,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1081,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1081,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1081,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1081,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1081,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1081,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1081,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1081,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1081,
				PropsID   = 2003
			}
		}
	},
	[1082] = 
	{
		ID             = 1082,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1082,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1082,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1082,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1082,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1082,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1082,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1082,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1082,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1082,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1082,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1082,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1082,
				PropsID   = 2003
			}
		}
	},
	[1083] = 
	{
		ID             = 1083,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1083,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1083,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1083,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1083,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1083,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1083,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1083,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1083,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1083,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1083,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1083,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1083,
				PropsID   = 2003
			}
		}
	},
	[1084] = 
	{
		ID             = 1084,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1084,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1084,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1084,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1084,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1084,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1084,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1084,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1084,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1084,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1084,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1084,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1084,
				PropsID   = 2003
			}
		}
	},
	[1085] = 
	{
		ID             = 1085,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1085,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1085,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1085,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1085,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1085,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1085,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1085,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1085,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1085,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1085,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1085,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1085,
				PropsID   = 2003
			}
		}
	},
	[1086] = 
	{
		ID             = 1086,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1086,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1086,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1086,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1086,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1086,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1086,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1086,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1086,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1086,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1086,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1086,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1086,
				PropsID   = 2003
			}
		}
	},
	[1087] = 
	{
		ID             = 1087,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1087,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1087,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1087,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1087,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1087,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1087,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1087,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1087,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1087,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1087,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1087,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1087,
				PropsID   = 2003
			}
		}
	},
	[1088] = 
	{
		ID             = 1088,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1088,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1088,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1088,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1088,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1088,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1088,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1088,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1088,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1088,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1088,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1088,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1088,
				PropsID   = 2003
			}
		}
	},
	[1089] = 
	{
		ID             = 1089,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1089,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1089,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1089,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1089,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1089,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1089,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1089,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1089,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1089,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1089,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1089,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1089,
				PropsID   = 2003
			}
		}
	},
	[1090] = 
	{
		ID             = 1090,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1090,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1090,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1090,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1090,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1090,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1090,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1090,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1090,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1090,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1090,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1090,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1090,
				PropsID   = 2003
			}
		}
	},
	[1091] = 
	{
		ID             = 1091,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1091,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1091,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1091,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1091,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1091,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1091,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1091,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1091,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1091,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1091,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1091,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1091,
				PropsID   = 2003
			}
		}
	},
	[1092] = 
	{
		ID             = 1092,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1092,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1092,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1092,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1092,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1092,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1092,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1092,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1092,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1092,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1092,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1092,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1092,
				PropsID   = 2003
			}
		}
	},
	[1093] = 
	{
		ID             = 1093,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1093,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1093,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1093,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1093,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1093,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1093,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1093,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1093,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1093,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1093,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1093,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1093,
				PropsID   = 2003
			}
		}
	},
	[1094] = 
	{
		ID             = 1094,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1094,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1094,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1094,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1094,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1094,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1094,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1094,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1094,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1094,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1094,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1094,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1094,
				PropsID   = 2003
			}
		}
	},
	[1095] = 
	{
		ID             = 1095,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1095,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1095,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1095,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1095,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1095,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1095,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1095,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1095,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1095,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1095,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1095,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1095,
				PropsID   = 2003
			}
		}
	},
	[1096] = 
	{
		ID             = 1096,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1096,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1096,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1096,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1096,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1096,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1096,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1096,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1096,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1096,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1096,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1096,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1096,
				PropsID   = 2003
			}
		}
	},
	[1097] = 
	{
		ID             = 1097,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1097,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1097,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1097,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1097,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1097,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1097,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1097,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1097,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1097,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1097,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1097,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1097,
				PropsID   = 2003
			}
		}
	},
	[1098] = 
	{
		ID             = 1098,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1098,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1098,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1098,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1098,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1098,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1098,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1098,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1098,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1098,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1098,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1098,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1098,
				PropsID   = 2003
			}
		}
	},
	[1099] = 
	{
		ID             = 1099,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1099,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1099,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1099,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1099,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1099,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1099,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1099,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1099,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1099,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1099,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1099,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1099,
				PropsID   = 2003
			}
		}
	},
	[1100] = 
	{
		ID             = 1100,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1100,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1100,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1100,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1100,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1100,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1100,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1100,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1100,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1100,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1100,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1100,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1100,
				PropsID   = 2003
			}
		}
	},
	[1101] = 
	{
		ID             = 1101,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1101,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1101,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1101,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1101,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1101,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1101,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1101,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1101,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1101,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1101,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1101,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1101,
				PropsID   = 2003
			}
		}
	},
	[1102] = 
	{
		ID             = 1102,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1102,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1102,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1102,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1102,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1102,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1102,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1102,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1102,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1102,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1102,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1102,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1102,
				PropsID   = 2003
			}
		}
	},
	[1103] = 
	{
		ID             = 1103,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1103,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1103,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1103,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1103,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1103,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1103,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1103,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1103,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1103,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1103,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1103,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1103,
				PropsID   = 2003
			}
		}
	},
	[1104] = 
	{
		ID             = 1104,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1104,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1104,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1104,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1104,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1104,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1104,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1104,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1104,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1104,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1104,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1104,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1104,
				PropsID   = 2003
			}
		}
	},
	[1105] = 
	{
		ID             = 1105,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1105,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1105,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1105,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1105,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1105,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1105,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1105,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1105,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1105,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1105,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1105,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1105,
				PropsID   = 2003
			}
		}
	},
	[1106] = 
	{
		ID             = 1106,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1106,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1106,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1106,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1106,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1106,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1106,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1106,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1106,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1106,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1106,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1106,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1106,
				PropsID   = 2003
			}
		}
	},
	[1107] = 
	{
		ID             = 1107,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1107,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1107,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1107,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1107,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1107,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1107,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1107,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1107,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1107,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1107,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1107,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1107,
				PropsID   = 2003
			}
		}
	},
	[1108] = 
	{
		ID             = 1108,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1108,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1108,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1108,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1108,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1108,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1108,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1108,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1108,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1108,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1108,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1108,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1108,
				PropsID   = 2003
			}
		}
	},
	[1109] = 
	{
		ID             = 1109,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1109,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1109,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1109,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1109,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1109,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1109,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1109,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1109,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1109,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1109,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1109,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1109,
				PropsID   = 2003
			}
		}
	},
	[1110] = 
	{
		ID             = 1110,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1110,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1110,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1110,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1110,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1110,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1110,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1110,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1110,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1110,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1110,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1110,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1110,
				PropsID   = 2003
			}
		}
	},
	[1111] = 
	{
		ID             = 1111,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1111,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1111,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1111,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1111,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1111,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1111,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1111,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1111,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1111,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1111,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1111,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1111,
				PropsID   = 2003
			}
		}
	},
	[1112] = 
	{
		ID             = 1112,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1112,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1112,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1112,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1112,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1112,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1112,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1112,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1112,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1112,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1112,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1112,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1112,
				PropsID   = 2003
			}
		}
	},
	[1113] = 
	{
		ID             = 1113,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1113,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1113,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1113,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1113,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1113,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1113,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1113,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1113,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1113,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1113,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1113,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1113,
				PropsID   = 2003
			}
		}
	},
	[1114] = 
	{
		ID             = 1114,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1114,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1114,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1114,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1114,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1114,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1114,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1114,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1114,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1114,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1114,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1114,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1114,
				PropsID   = 2003
			}
		}
	},
	[1115] = 
	{
		ID             = 1115,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1115,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1115,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1115,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1115,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1115,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1115,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1115,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1115,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1115,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1115,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1115,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1115,
				PropsID   = 2003
			}
		}
	},
	[1116] = 
	{
		ID             = 1116,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1116,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1116,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1116,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1116,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1116,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1116,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1116,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1116,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1116,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1116,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1116,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1116,
				PropsID   = 2003
			}
		}
	},
	[1117] = 
	{
		ID             = 1117,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1117,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1117,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1117,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1117,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1117,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1117,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1117,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1117,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1117,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1117,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1117,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1117,
				PropsID   = 2003
			}
		}
	},
	[1118] = 
	{
		ID             = 1118,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1118,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1118,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1118,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1118,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1118,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1118,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1118,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1118,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1118,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1118,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1118,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1118,
				PropsID   = 2003
			}
		}
	},
	[1119] = 
	{
		ID             = 1119,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1119,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1119,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1119,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1119,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1119,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1119,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1119,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1119,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1119,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1119,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1119,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1119,
				PropsID   = 2003
			}
		}
	},
	[1120] = 
	{
		ID             = 1120,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1120,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1120,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1120,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1120,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1120,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1120,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1120,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1120,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1120,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1120,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1120,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1120,
				PropsID   = 2003
			}
		}
	},
	[1121] = 
	{
		ID             = 1121,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1121,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1121,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1121,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1121,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1121,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1121,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1121,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1121,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1121,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1121,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1121,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1121,
				PropsID   = 2003
			}
		}
	},
	[1142] = 
	{
		ID             = 1142,
		StarLevel_List = 
		{
			[1] = 
			{
				FragNum   = 0,
				PropsNum  = 2,
				StarLevel = 1,
				FragID    = 1142,
				PropsID   = 2001
			},
			[2] = 
			{
				FragNum   = 0,
				PropsNum  = 6,
				StarLevel = 2,
				FragID    = 1142,
				PropsID   = 2001
			},
			[3] = 
			{
				FragNum   = 5,
				PropsNum  = 12,
				StarLevel = 3,
				FragID    = 1142,
				PropsID   = 2001
			},
			[4] = 
			{
				FragNum   = 10,
				PropsNum  = 8,
				StarLevel = 4,
				FragID    = 1142,
				PropsID   = 2002
			},
			[5] = 
			{
				FragNum   = 20,
				PropsNum  = 15,
				StarLevel = 5,
				FragID    = 1142,
				PropsID   = 2002
			},
			[6] = 
			{
				FragNum   = 40,
				PropsNum  = 20,
				StarLevel = 6,
				FragID    = 1142,
				PropsID   = 2002
			},
			[7] = 
			{
				FragNum   = 60,
				PropsNum  = 30,
				StarLevel = 7,
				FragID    = 1142,
				PropsID   = 2002
			},
			[8] = 
			{
				FragNum   = 100,
				PropsNum  = 40,
				StarLevel = 8,
				FragID    = 1142,
				PropsID   = 2002
			},
			[9] = 
			{
				FragNum   = 150,
				PropsNum  = 20,
				StarLevel = 9,
				FragID    = 1142,
				PropsID   = 2003
			},
			[10] = 
			{
				FragNum   = 200,
				PropsNum  = 40,
				StarLevel = 10,
				FragID    = 1142,
				PropsID   = 2003
			},
			[11] = 
			{
				FragNum   = 250,
				PropsNum  = 60,
				StarLevel = 11,
				FragID    = 1142,
				PropsID   = 2003
			},
			[12] = 
			{
				FragNum   = 300,
				PropsNum  = 80,
				StarLevel = 12,
				FragID    = 1142,
				PropsID   = 2003
			}
		}
	}
}

_M:Init()

return _M
