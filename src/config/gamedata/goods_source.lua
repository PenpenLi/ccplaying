
local _M = { }

function _M:Init()
    for key, item in pairs(self.Data) do
        item.__index = item
        for subKey, subItem in pairs(item.GoodsID_List) do
            setmetatable(subItem, item)
        end
    end
end

function _M:Get(GoodsType, GoodsID)
    local item = self.Data[GoodsType]
    local subItem = nil 
    if item then
        subItem = item.GoodsID_List[GoodsID]
    end

    return subItem
end

_M.Data = 
{
	[5] = 
	{
		GoodsType    = 5,
		GoodsID_List = 
		{
			[1001] = 
			{
				ComposeID    = 1001,
				InstanceList = {
					
				},
				GoodsID      = 1001,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 0
			},
			[1002] = 
			{
				ComposeID    = 1002,
				InstanceList = {
					
				},
				GoodsID      = 1002,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1003] = 
			{
				ComposeID    = 1003,
				InstanceList = {
					
				},
				GoodsID      = 1003,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1004] = 
			{
				ComposeID    = 1004,
				InstanceList = {
					
				},
				GoodsID      = 1004,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1005] = 
			{
				ComposeID    = 1005,
				InstanceList = {
					
				},
				GoodsID      = 1005,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1006] = 
			{
				ComposeID    = 1006,
				InstanceList = {
					
				},
				GoodsID      = 1006,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1007] = 
			{
				ComposeID    = 1007,
				InstanceList = {
					
				},
				GoodsID      = 1007,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1008] = 
			{
				ComposeID    = 1008,
				InstanceList = {
					
				},
				GoodsID      = 1008,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1009] = 
			{
				ComposeID    = 1009,
				InstanceList = {
					
				},
				GoodsID      = 1009,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1010] = 
			{
				ComposeID    = 1010,
				InstanceList = {
					
				},
				GoodsID      = 1010,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1011] = 
			{
				ComposeID    = 1011,
				InstanceList = {
					
				},
				GoodsID      = 1011,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1012] = 
			{
				ComposeID    = 1012,
				InstanceList = {
					
				},
				GoodsID      = 1012,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 4
			},
			[1013] = 
			{
				ComposeID    = 1013,
				InstanceList = {
					
				},
				GoodsID      = 1013,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1014] = 
			{
				ComposeID    = 1014,
				InstanceList = {
					
				},
				GoodsID      = 1014,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1015] = 
			{
				ComposeID    = 1015,
				InstanceList = {
					
				},
				GoodsID      = 1015,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 0
			},
			[1016] = 
			{
				ComposeID    = 1016,
				InstanceList = {
					
				},
				GoodsID      = 1016,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1017] = 
			{
				ComposeID    = 1017,
				InstanceList = {
					
				},
				GoodsID      = 1017,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 0
			},
			[1018] = 
			{
				ComposeID    = 1018,
				InstanceList = {
					
				},
				GoodsID      = 1018,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1019] = 
			{
				ComposeID    = 1019,
				InstanceList = {
					
				},
				GoodsID      = 1019,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1020] = 
			{
				ComposeID    = 1020,
				InstanceList = {
					
				},
				GoodsID      = 1020,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 4
			},
			[1021] = 
			{
				ComposeID    = 1021,
				InstanceList = {
					
				},
				GoodsID      = 1021,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 4
			},
			[1022] = 
			{
				ComposeID    = 1022,
				InstanceList = {
					
				},
				GoodsID      = 1022,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1023] = 
			{
				ComposeID    = 1023,
				InstanceList = {
					
				},
				GoodsID      = 1023,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1024] = 
			{
				ComposeID    = 1024,
				InstanceList = {
					
				},
				GoodsID      = 1024,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1025] = 
			{
				ComposeID    = 1025,
				InstanceList = {
					
				},
				GoodsID      = 1025,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1026] = 
			{
				ComposeID    = 1026,
				InstanceList = {
					
				},
				GoodsID      = 1026,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1027] = 
			{
				ComposeID    = 1027,
				InstanceList = {
					
				},
				GoodsID      = 1027,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1028] = 
			{
				ComposeID    = 1028,
				InstanceList = {
					
				},
				GoodsID      = 1028,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1029] = 
			{
				ComposeID    = 1029,
				InstanceList = {
					
				},
				GoodsID      = 1029,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 0
			},
			[1030] = 
			{
				ComposeID    = 1030,
				InstanceList = {
					
				},
				GoodsID      = 1030,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1031] = 
			{
				ComposeID    = 1031,
				InstanceList = {
					
				},
				GoodsID      = 1031,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1032] = 
			{
				ComposeID    = 1032,
				InstanceList = {
					
				},
				GoodsID      = 1032,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1033] = 
			{
				ComposeID    = 1033,
				InstanceList = {
					
				},
				GoodsID      = 1033,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 0
			},
			[1034] = 
			{
				ComposeID    = 1034,
				InstanceList = {
					
				},
				GoodsID      = 1034,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1035] = 
			{
				ComposeID    = 1035,
				InstanceList = {
					
				},
				GoodsID      = 1035,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1036] = 
			{
				ComposeID    = 1036,
				InstanceList = {
					
				},
				GoodsID      = 1036,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1037] = 
			{
				ComposeID    = 1037,
				InstanceList = {
					
				},
				GoodsID      = 1037,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1038] = 
			{
				ComposeID    = 1038,
				InstanceList = {
					
				},
				GoodsID      = 1038,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1039] = 
			{
				ComposeID    = 1039,
				InstanceList = {
					
				},
				GoodsID      = 1039,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1040] = 
			{
				ComposeID    = 1040,
				InstanceList = {
					
				},
				GoodsID      = 1040,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1041] = 
			{
				ComposeID    = 1041,
				InstanceList = {
					
				},
				GoodsID      = 1041,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1042] = 
			{
				ComposeID    = 1042,
				InstanceList = {
					
				},
				GoodsID      = 1042,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1043] = 
			{
				ComposeID    = 1043,
				InstanceList = {
					
				},
				GoodsID      = 1043,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1044] = 
			{
				ComposeID    = 1044,
				InstanceList = {
					
				},
				GoodsID      = 1044,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1045] = 
			{
				ComposeID    = 1045,
				InstanceList = {
					
				},
				GoodsID      = 1045,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1046] = 
			{
				ComposeID    = 1046,
				InstanceList = {
					
				},
				GoodsID      = 1046,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1047] = 
			{
				ComposeID    = 1047,
				InstanceList = {
					
				},
				GoodsID      = 1047,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 0
			},
			[1048] = 
			{
				ComposeID    = 1048,
				InstanceList = {
					
				},
				GoodsID      = 1048,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 0
			},
			[1049] = 
			{
				ComposeID    = 1049,
				InstanceList = {
					
				},
				GoodsID      = 1049,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 2
			},
			[1050] = 
			{
				ComposeID    = 1050,
				InstanceList = {
					
				},
				GoodsID      = 1050,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 2
			},
			[1051] = 
			{
				ComposeID    = 1051,
				InstanceList = {
					
				},
				GoodsID      = 1051,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 2
			},
			[1052] = 
			{
				ComposeID    = 1052,
				InstanceList = {
					
				},
				GoodsID      = 1052,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1053] = 
			{
				ComposeID    = 1053,
				InstanceList = {
					
				},
				GoodsID      = 1053,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1054] = 
			{
				ComposeID    = 1054,
				InstanceList = {
					
				},
				GoodsID      = 1054,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1055] = 
			{
				ComposeID    = 1055,
				InstanceList = {
					
				},
				GoodsID      = 1055,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1056] = 
			{
				ComposeID    = 1056,
				InstanceList = {
					
				},
				GoodsID      = 1056,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1057] = 
			{
				ComposeID    = 1057,
				InstanceList = {
					
				},
				GoodsID      = 1057,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1058] = 
			{
				ComposeID    = 1058,
				InstanceList = {
					
				},
				GoodsID      = 1058,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1059] = 
			{
				ComposeID    = 1059,
				InstanceList = {
					
				},
				GoodsID      = 1059,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1060] = 
			{
				ComposeID    = 1060,
				InstanceList = {
					
				},
				GoodsID      = 1060,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1061] = 
			{
				ComposeID    = 1061,
				InstanceList = {
					
				},
				GoodsID      = 1061,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1062] = 
			{
				ComposeID    = 1062,
				InstanceList = {
					
				},
				GoodsID      = 1062,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1063] = 
			{
				ComposeID    = 1063,
				InstanceList = {
					
				},
				GoodsID      = 1063,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1064] = 
			{
				ComposeID    = 1064,
				InstanceList = {
					
				},
				GoodsID      = 1064,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1065] = 
			{
				ComposeID    = 1065,
				InstanceList = {
					
				},
				GoodsID      = 1065,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1066] = 
			{
				ComposeID    = 1066,
				InstanceList = {
					
				},
				GoodsID      = 1066,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1067] = 
			{
				ComposeID    = 1067,
				InstanceList = {
					
				},
				GoodsID      = 1067,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1068] = 
			{
				ComposeID    = 1068,
				InstanceList = {
					
				},
				GoodsID      = 1068,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1069] = 
			{
				ComposeID    = 1069,
				InstanceList = {
					
				},
				GoodsID      = 1069,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1071] = 
			{
				ComposeID    = 1071,
				InstanceList = {
					
				},
				GoodsID      = 1071,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1072] = 
			{
				ComposeID    = 1072,
				InstanceList = {
					
				},
				GoodsID      = 1072,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 2
			},
			[1073] = 
			{
				ComposeID    = 1073,
				InstanceList = {
					
				},
				GoodsID      = 1073,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 0
			},
			[1074] = 
			{
				ComposeID    = 1074,
				InstanceList = {
					
				},
				GoodsID      = 1074,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 2
			},
			[1075] = 
			{
				ComposeID    = 1075,
				InstanceList = {
					
				},
				GoodsID      = 1075,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 2
			},
			[1076] = 
			{
				ComposeID    = 1076,
				InstanceList = {
					
				},
				GoodsID      = 1076,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 2
			},
			[1077] = 
			{
				ComposeID    = 1077,
				InstanceList = {
					
				},
				GoodsID      = 1077,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1078] = 
			{
				ComposeID    = 1078,
				InstanceList = {
					
				},
				GoodsID      = 1078,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1079] = 
			{
				ComposeID    = 1079,
				InstanceList = {
					
				},
				GoodsID      = 1079,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1080] = 
			{
				ComposeID    = 1080,
				InstanceList = {
					
				},
				GoodsID      = 1080,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1081] = 
			{
				ComposeID    = 1081,
				InstanceList = {
					
				},
				GoodsID      = 1081,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1082] = 
			{
				ComposeID    = 1082,
				InstanceList = {
					
				},
				GoodsID      = 1082,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1083] = 
			{
				ComposeID    = 1083,
				InstanceList = {
					
				},
				GoodsID      = 1083,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1084] = 
			{
				ComposeID    = 1084,
				InstanceList = {
					
				},
				GoodsID      = 1084,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1085] = 
			{
				ComposeID    = 1085,
				InstanceList = {
					
				},
				GoodsID      = 1085,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1086] = 
			{
				ComposeID    = 1086,
				InstanceList = {
					
				},
				GoodsID      = 1086,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1087] = 
			{
				ComposeID    = 1087,
				InstanceList = {
					
				},
				GoodsID      = 1087,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1088] = 
			{
				ComposeID    = 1088,
				InstanceList = {
					
				},
				GoodsID      = 1088,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1089] = 
			{
				ComposeID    = 1089,
				InstanceList = {
					
				},
				GoodsID      = 1089,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1090] = 
			{
				ComposeID    = 1090,
				InstanceList = {
					
				},
				GoodsID      = 1090,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1091] = 
			{
				ComposeID    = 1091,
				InstanceList = {
					
				},
				GoodsID      = 1091,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1092] = 
			{
				ComposeID    = 1092,
				InstanceList = {
					
				},
				GoodsID      = 1092,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1093] = 
			{
				ComposeID    = 1093,
				InstanceList = {
					
				},
				GoodsID      = 1093,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1094] = 
			{
				ComposeID    = 1094,
				InstanceList = {
					
				},
				GoodsID      = 1094,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1096] = 
			{
				ComposeID    = 1096,
				InstanceList = {
					
				},
				GoodsID      = 1096,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1097] = 
			{
				ComposeID    = 1097,
				InstanceList = {
					
				},
				GoodsID      = 1097,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 2
			},
			[1098] = 
			{
				ComposeID    = 1098,
				InstanceList = {
					
				},
				GoodsID      = 1098,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 2
			},
			[1099] = 
			{
				ComposeID    = 1099,
				InstanceList = {
					
				},
				GoodsID      = 1099,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 2
			},
			[1100] = 
			{
				ComposeID    = 1100,
				InstanceList = {
					
				},
				GoodsID      = 1100,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 2
			},
			[1101] = 
			{
				ComposeID    = 1101,
				InstanceList = {
					
				},
				GoodsID      = 1101,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 2
			},
			[1102] = 
			{
				ComposeID    = 1102,
				InstanceList = {
					
				},
				GoodsID      = 1102,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1103] = 
			{
				ComposeID    = 1103,
				InstanceList = {
					
				},
				GoodsID      = 1103,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1104] = 
			{
				ComposeID    = 1104,
				InstanceList = {
					
				},
				GoodsID      = 1104,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1105] = 
			{
				ComposeID    = 1105,
				InstanceList = {
					
				},
				GoodsID      = 1105,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1106] = 
			{
				ComposeID    = 1106,
				InstanceList = {
					
				},
				GoodsID      = 1106,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1107] = 
			{
				ComposeID    = 1107,
				InstanceList = {
					
				},
				GoodsID      = 1107,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1108] = 
			{
				ComposeID    = 1108,
				InstanceList = {
					
				},
				GoodsID      = 1108,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1109] = 
			{
				ComposeID    = 1109,
				InstanceList = {
					
				},
				GoodsID      = 1109,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1110] = 
			{
				ComposeID    = 1110,
				InstanceList = {
					
				},
				GoodsID      = 1110,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1111] = 
			{
				ComposeID    = 1111,
				InstanceList = {
					
				},
				GoodsID      = 1111,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1112] = 
			{
				ComposeID    = 1112,
				InstanceList = {
					
				},
				GoodsID      = 1112,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1113] = 
			{
				ComposeID    = 1113,
				InstanceList = {
					
				},
				GoodsID      = 1113,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1114] = 
			{
				ComposeID    = 1114,
				InstanceList = {
					
				},
				GoodsID      = 1114,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1115] = 
			{
				ComposeID    = 1115,
				InstanceList = {
					
				},
				GoodsID      = 1115,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1116] = 
			{
				ComposeID    = 1116,
				InstanceList = {
					
				},
				GoodsID      = 1116,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1117] = 
			{
				ComposeID    = 1117,
				InstanceList = {
					
				},
				GoodsID      = 1117,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1118] = 
			{
				ComposeID    = 1118,
				InstanceList = {
					
				},
				GoodsID      = 1118,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1119] = 
			{
				ComposeID    = 1119,
				InstanceList = {
					
				},
				GoodsID      = 1119,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1121] = 
			{
				ComposeID    = 1121,
				InstanceList = {
					
				},
				GoodsID      = 1121,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1142] = 
			{
				ComposeID    = 1142,
				InstanceList = {
					
				},
				GoodsID      = 1142,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			}
		}
	},
	[6] = 
	{
		GoodsType    = 6,
		GoodsID_List = 
		{
			[1001] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1001,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 2
			},
			[1002] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1002,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1003] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1003,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1004] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 11212
					},
					{
						Type = 1,
						ID   = 12012
					}
				},
				GoodsID      = 1004,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1005] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1005,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1006] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1006,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1007] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1007,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1008] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10608
					},
					{
						Type = 1,
						ID   = 11804
					}
				},
				GoodsID      = 1008,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1009] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10912
					},
					{
						Type = 1,
						ID   = 11408
					}
				},
				GoodsID      = 1009,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1010] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1010,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1011] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10308
					},
					{
						Type = 1,
						ID   = 11808
					}
				},
				GoodsID      = 1011,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1012] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1012,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 4
			},
			[1013] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10312
					}
				},
				GoodsID      = 1013,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1014] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10504
					},
					{
						Type = 1,
						ID   = 11008
					}
				},
				GoodsID      = 1014,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1015] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10212
					}
				},
				GoodsID      = 1015,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 0
			},
			[1016] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10106
					}
				},
				GoodsID      = 1016,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1017] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1017,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 0
			},
			[1018] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1018,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1019] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1019,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1020] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1020,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 4
			},
			[1021] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1021,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 4
			},
			[1022] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10612
					},
					{
						Type = 1,
						ID   = 11504
					}
				},
				GoodsID      = 1022,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1023] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10708
					},
					{
						Type = 1,
						ID   = 11908
					}
				},
				GoodsID      = 1023,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1024] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 11004
					},
					{
						Type = 1,
						ID   = 11708
					}
				},
				GoodsID      = 1024,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1025] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10904
					},
					{
						Type = 1,
						ID   = 11704
					}
				},
				GoodsID      = 1025,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1026] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10604
					},
					{
						Type = 1,
						ID   = 11308
					}
				},
				GoodsID      = 1026,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1027] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10212
					}
				},
				GoodsID      = 1027,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1028] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10404
					},
					{
						Type = 1,
						ID   = 11812
					}
				},
				GoodsID      = 1028,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1029] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10102
					}
				},
				GoodsID      = 1029,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 0
			},
			[1030] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10204
					}
				},
				GoodsID      = 1030,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1031] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1031,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 2
			},
			[1032] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1032,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 2
			},
			[1033] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1033,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 0
			},
			[1034] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1034,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1035] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1035,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1036] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 11208
					},
					{
						Type = 1,
						ID   = 11908
					}
				},
				GoodsID      = 1036,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1037] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 11108
					},
					{
						Type = 1,
						ID   = 11812
					}
				},
				GoodsID      = 1037,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1038] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10812
					},
					{
						Type = 1,
						ID   = 12004
					}
				},
				GoodsID      = 1038,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1039] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10412
					},
					{
						Type = 1,
						ID   = 11604
					}
				},
				GoodsID      = 1039,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1040] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 11208
					},
					{
						Type = 1,
						ID   = 11612
					}
				},
				GoodsID      = 1040,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1041] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1041,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1042] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 11008
					},
					{
						Type = 1,
						ID   = 11808
					}
				},
				GoodsID      = 1042,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1043] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10308
					},
					{
						Type = 1,
						ID   = 11404
					}
				},
				GoodsID      = 1043,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1044] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10608
					},
					{
						Type = 1,
						ID   = 11312
					}
				},
				GoodsID      = 1044,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1045] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10508
					},
					{
						Type = 1,
						ID   = 11704
					}
				},
				GoodsID      = 1045,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1046] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10110
					}
				},
				GoodsID      = 1046,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1047] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10208
					}
				},
				GoodsID      = 1047,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 0
			},
			[1048] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1048,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 2
			},
			[1049] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1049,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 2
			},
			[1050] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1050,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 2
			},
			[1051] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1051,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 2
			},
			[1052] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1052,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1053] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1053,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1054] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 11112
					},
					{
						Type = 1,
						ID   = 11508
					}
				},
				GoodsID      = 1054,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1055] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10412
					},
					{
						Type = 1,
						ID   = 11012
					}
				},
				GoodsID      = 1055,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1056] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1056,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1057] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1057,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1058] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1058,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1059] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1059,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1060] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 11204
					},
					{
						Type = 1,
						ID   = 11412
					}
				},
				GoodsID      = 1060,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1061] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1061,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1062] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10704
					},
					{
						Type = 1,
						ID   = 11112
					}
				},
				GoodsID      = 1062,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1063] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10612
					},
					{
						Type = 1,
						ID   = 11608
					}
				},
				GoodsID      = 1063,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1064] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1064,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1065] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10808
					},
					{
						Type = 1,
						ID   = 12012
					}
				},
				GoodsID      = 1065,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1066] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10708
					},
					{
						Type = 1,
						ID   = 11612
					}
				},
				GoodsID      = 1066,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1067] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10604
					},
					{
						Type = 1,
						ID   = 11508
					}
				},
				GoodsID      = 1067,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1068] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10504
					}
				},
				GoodsID      = 1068,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1069] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10208
					}
				},
				GoodsID      = 1069,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1071] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10102
					}
				},
				GoodsID      = 1071,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1072] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1072,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 2
			},
			[1073] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1073,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 0
			},
			[1074] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1074,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 2
			},
			[1075] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1075,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 2
			},
			[1076] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1076,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 2
			},
			[1077] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 11012
					},
					{
						Type = 1,
						ID   = 11912
					}
				},
				GoodsID      = 1077,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1078] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1078,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1079] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1079,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1080] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 11004
					},
					{
						Type = 1,
						ID   = 12008
					}
				},
				GoodsID      = 1080,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1081] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1081,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1082] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10512
					},
					{
						Type = 1,
						ID   = 11608
					}
				},
				GoodsID      = 1082,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1083] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10312
					},
					{
						Type = 1,
						ID   = 12004
					}
				},
				GoodsID      = 1083,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1084] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 11104
					},
					{
						Type = 1,
						ID   = 11304
					}
				},
				GoodsID      = 1084,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1085] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 11204
					},
					{
						Type = 1,
						ID   = 11804
					}
				},
				GoodsID      = 1085,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1086] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10704
					},
					{
						Type = 1,
						ID   = 11404
					}
				},
				GoodsID      = 1086,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1087] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10804
					},
					{
						Type = 1,
						ID   = 11412
					}
				},
				GoodsID      = 1087,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1088] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10908
					},
					{
						Type = 1,
						ID   = 11712
					}
				},
				GoodsID      = 1088,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1089] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10712
					},
					{
						Type = 1,
						ID   = 11304
					}
				},
				GoodsID      = 1089,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1090] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10712
					},
					{
						Type = 1,
						ID   = 11312
					}
				},
				GoodsID      = 1090,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1091] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10508
					},
					{
						Type = 1,
						ID   = 11708
					}
				},
				GoodsID      = 1091,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1092] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10808
					},
					{
						Type = 1,
						ID   = 11512
					}
				},
				GoodsID      = 1092,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1093] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10204
					}
				},
				GoodsID      = 1093,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1094] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10404
					}
				},
				GoodsID      = 1094,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1096] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10106
					}
				},
				GoodsID      = 1096,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1097] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1097,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 2
			},
			[1098] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1098,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 2
			},
			[1099] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1099,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 2
			},
			[1100] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1100,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 2
			},
			[1101] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1101,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 2
			},
			[1102] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1102,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1103] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10908
					},
					{
						Type = 1,
						ID   = 11904
					}
				},
				GoodsID      = 1103,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1104] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10812
					},
					{
						Type = 1,
						ID   = 12008
					}
				},
				GoodsID      = 1104,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1105] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1105,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1106] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1106,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1107] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 11308
					},
					{
						Type = 1,
						ID   = 11604
					}
				},
				GoodsID      = 1107,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1108] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 11212
					},
					{
						Type = 1,
						ID   = 11512
					}
				},
				GoodsID      = 1108,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 4
			},
			[1109] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1109,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1110] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10912
					},
					{
						Type = 1,
						ID   = 11904
					}
				},
				GoodsID      = 1110,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1111] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1111,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1112] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10904
					},
					{
						Type = 1,
						ID   = 11408
					}
				},
				GoodsID      = 1112,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1113] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1113,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1114] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10408
					},
					{
						Type = 1,
						ID   = 11104
					}
				},
				GoodsID      = 1114,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1115] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 11108
					},
					{
						Type = 1,
						ID   = 11712
					}
				},
				GoodsID      = 1115,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1116] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10804
					},
					{
						Type = 1,
						ID   = 11504
					}
				},
				GoodsID      = 1116,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1117] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10512
					},
					{
						Type = 1,
						ID   = 11912
					}
				},
				GoodsID      = 1117,
				Tower        = 0,
				ExchangeType = 2,
				BuyType      = 1
			},
			[1118] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10408
					}
				},
				GoodsID      = 1118,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1119] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10304
					}
				},
				GoodsID      = 1119,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1121] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10110
					}
				},
				GoodsID      = 1121,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1142] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10304
					}
				},
				GoodsID      = 1142,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[2001] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10102
					},
					{
						Type = 1,
						ID   = 10204
					},
					{
						Type = 1,
						ID   = 10304
					},
					{
						Type = 1,
						ID   = 10404
					},
					{
						Type = 1,
						ID   = 10504
					},
					{
						Type = 1,
						ID   = 10604
					},
					{
						Type = 1,
						ID   = 10704
					},
					{
						Type = 1,
						ID   = 10804
					},
					{
						Type = 1,
						ID   = 10904
					},
					{
						Type = 1,
						ID   = 11004
					},
					{
						Type = 1,
						ID   = 11104
					},
					{
						Type = 1,
						ID   = 11204
					},
					{
						Type = 1,
						ID   = 11304
					},
					{
						Type = 1,
						ID   = 11404
					},
					{
						Type = 1,
						ID   = 11504
					},
					{
						Type = 1,
						ID   = 11604
					},
					{
						Type = 1,
						ID   = 11704
					},
					{
						Type = 1,
						ID   = 11804
					},
					{
						Type = 1,
						ID   = 11904
					},
					{
						Type = 1,
						ID   = 12004
					},
					{
						Type = 1,
						ID   = 10106
					},
					{
						Type = 1,
						ID   = 10208
					},
					{
						Type = 1,
						ID   = 10308
					},
					{
						Type = 1,
						ID   = 10408
					},
					{
						Type = 1,
						ID   = 10508
					},
					{
						Type = 1,
						ID   = 10608
					},
					{
						Type = 1,
						ID   = 10708
					},
					{
						Type = 1,
						ID   = 10808
					},
					{
						Type = 1,
						ID   = 10908
					},
					{
						Type = 1,
						ID   = 11008
					},
					{
						Type = 1,
						ID   = 11108
					},
					{
						Type = 1,
						ID   = 11208
					},
					{
						Type = 1,
						ID   = 11308
					},
					{
						Type = 1,
						ID   = 11408
					},
					{
						Type = 1,
						ID   = 11508
					},
					{
						Type = 1,
						ID   = 11608
					},
					{
						Type = 1,
						ID   = 11708
					},
					{
						Type = 1,
						ID   = 11808
					},
					{
						Type = 1,
						ID   = 11908
					},
					{
						Type = 1,
						ID   = 12008
					},
					{
						Type = 1,
						ID   = 10110
					},
					{
						Type = 1,
						ID   = 10212
					},
					{
						Type = 1,
						ID   = 10312
					},
					{
						Type = 1,
						ID   = 10412
					},
					{
						Type = 1,
						ID   = 10512
					},
					{
						Type = 1,
						ID   = 10612
					},
					{
						Type = 1,
						ID   = 10712
					},
					{
						Type = 1,
						ID   = 10812
					},
					{
						Type = 1,
						ID   = 10912
					},
					{
						Type = 1,
						ID   = 11012
					},
					{
						Type = 1,
						ID   = 11112
					},
					{
						Type = 1,
						ID   = 11212
					},
					{
						Type = 1,
						ID   = 11312
					},
					{
						Type = 1,
						ID   = 11412
					},
					{
						Type = 1,
						ID   = 11512
					},
					{
						Type = 1,
						ID   = 11612
					},
					{
						Type = 1,
						ID   = 11712
					},
					{
						Type = 1,
						ID   = 11812
					},
					{
						Type = 1,
						ID   = 11912
					},
					{
						Type = 1,
						ID   = 12012
					}
				},
				GoodsID      = 2001,
				Tower        = 0,
				ExchangeType = 1,
				BuyType      = 0
			},
			[2002] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10102
					},
					{
						Type = 1,
						ID   = 10204
					},
					{
						Type = 1,
						ID   = 10304
					},
					{
						Type = 1,
						ID   = 10404
					},
					{
						Type = 1,
						ID   = 10504
					},
					{
						Type = 1,
						ID   = 10604
					},
					{
						Type = 1,
						ID   = 10704
					},
					{
						Type = 1,
						ID   = 10804
					},
					{
						Type = 1,
						ID   = 10904
					},
					{
						Type = 1,
						ID   = 11004
					},
					{
						Type = 1,
						ID   = 11104
					},
					{
						Type = 1,
						ID   = 11204
					},
					{
						Type = 1,
						ID   = 11304
					},
					{
						Type = 1,
						ID   = 11404
					},
					{
						Type = 1,
						ID   = 11504
					},
					{
						Type = 1,
						ID   = 11604
					},
					{
						Type = 1,
						ID   = 11704
					},
					{
						Type = 1,
						ID   = 11804
					},
					{
						Type = 1,
						ID   = 11904
					},
					{
						Type = 1,
						ID   = 12004
					},
					{
						Type = 1,
						ID   = 10106
					},
					{
						Type = 1,
						ID   = 10208
					},
					{
						Type = 1,
						ID   = 10308
					},
					{
						Type = 1,
						ID   = 10408
					},
					{
						Type = 1,
						ID   = 10508
					},
					{
						Type = 1,
						ID   = 10608
					},
					{
						Type = 1,
						ID   = 10708
					},
					{
						Type = 1,
						ID   = 10808
					},
					{
						Type = 1,
						ID   = 10908
					},
					{
						Type = 1,
						ID   = 11008
					},
					{
						Type = 1,
						ID   = 11108
					},
					{
						Type = 1,
						ID   = 11208
					},
					{
						Type = 1,
						ID   = 11308
					},
					{
						Type = 1,
						ID   = 11408
					},
					{
						Type = 1,
						ID   = 11508
					},
					{
						Type = 1,
						ID   = 11608
					},
					{
						Type = 1,
						ID   = 11708
					},
					{
						Type = 1,
						ID   = 11808
					},
					{
						Type = 1,
						ID   = 11908
					},
					{
						Type = 1,
						ID   = 12008
					},
					{
						Type = 1,
						ID   = 10110
					},
					{
						Type = 1,
						ID   = 10212
					},
					{
						Type = 1,
						ID   = 10312
					},
					{
						Type = 1,
						ID   = 10412
					},
					{
						Type = 1,
						ID   = 10512
					},
					{
						Type = 1,
						ID   = 10612
					},
					{
						Type = 1,
						ID   = 10712
					},
					{
						Type = 1,
						ID   = 10812
					},
					{
						Type = 1,
						ID   = 10912
					},
					{
						Type = 1,
						ID   = 11012
					},
					{
						Type = 1,
						ID   = 11112
					},
					{
						Type = 1,
						ID   = 11212
					},
					{
						Type = 1,
						ID   = 11312
					},
					{
						Type = 1,
						ID   = 11412
					},
					{
						Type = 1,
						ID   = 11512
					},
					{
						Type = 1,
						ID   = 11612
					},
					{
						Type = 1,
						ID   = 11712
					},
					{
						Type = 1,
						ID   = 11812
					},
					{
						Type = 1,
						ID   = 11912
					},
					{
						Type = 1,
						ID   = 12012
					}
				},
				GoodsID      = 2002,
				Tower        = 0,
				ExchangeType = 1,
				BuyType      = 0
			},
			[2003] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10102
					},
					{
						Type = 1,
						ID   = 10204
					},
					{
						Type = 1,
						ID   = 10304
					},
					{
						Type = 1,
						ID   = 10404
					},
					{
						Type = 1,
						ID   = 10504
					},
					{
						Type = 1,
						ID   = 10604
					},
					{
						Type = 1,
						ID   = 10704
					},
					{
						Type = 1,
						ID   = 10804
					},
					{
						Type = 1,
						ID   = 10904
					},
					{
						Type = 1,
						ID   = 11004
					},
					{
						Type = 1,
						ID   = 11104
					},
					{
						Type = 1,
						ID   = 11204
					},
					{
						Type = 1,
						ID   = 11304
					},
					{
						Type = 1,
						ID   = 11404
					},
					{
						Type = 1,
						ID   = 11504
					},
					{
						Type = 1,
						ID   = 11604
					},
					{
						Type = 1,
						ID   = 11704
					},
					{
						Type = 1,
						ID   = 11804
					},
					{
						Type = 1,
						ID   = 11904
					},
					{
						Type = 1,
						ID   = 12004
					},
					{
						Type = 1,
						ID   = 10106
					},
					{
						Type = 1,
						ID   = 10208
					},
					{
						Type = 1,
						ID   = 10308
					},
					{
						Type = 1,
						ID   = 10408
					},
					{
						Type = 1,
						ID   = 10508
					},
					{
						Type = 1,
						ID   = 10608
					},
					{
						Type = 1,
						ID   = 10708
					},
					{
						Type = 1,
						ID   = 10808
					},
					{
						Type = 1,
						ID   = 10908
					},
					{
						Type = 1,
						ID   = 11008
					},
					{
						Type = 1,
						ID   = 11108
					},
					{
						Type = 1,
						ID   = 11208
					},
					{
						Type = 1,
						ID   = 11308
					},
					{
						Type = 1,
						ID   = 11408
					},
					{
						Type = 1,
						ID   = 11508
					},
					{
						Type = 1,
						ID   = 11608
					},
					{
						Type = 1,
						ID   = 11708
					},
					{
						Type = 1,
						ID   = 11808
					},
					{
						Type = 1,
						ID   = 11908
					},
					{
						Type = 1,
						ID   = 12008
					},
					{
						Type = 1,
						ID   = 10110
					},
					{
						Type = 1,
						ID   = 10212
					},
					{
						Type = 1,
						ID   = 10312
					},
					{
						Type = 1,
						ID   = 10412
					},
					{
						Type = 1,
						ID   = 10512
					},
					{
						Type = 1,
						ID   = 10612
					},
					{
						Type = 1,
						ID   = 10712
					},
					{
						Type = 1,
						ID   = 10812
					},
					{
						Type = 1,
						ID   = 10912
					},
					{
						Type = 1,
						ID   = 11012
					},
					{
						Type = 1,
						ID   = 11112
					},
					{
						Type = 1,
						ID   = 11212
					},
					{
						Type = 1,
						ID   = 11312
					},
					{
						Type = 1,
						ID   = 11412
					},
					{
						Type = 1,
						ID   = 11512
					},
					{
						Type = 1,
						ID   = 11612
					},
					{
						Type = 1,
						ID   = 11712
					},
					{
						Type = 1,
						ID   = 11812
					},
					{
						Type = 1,
						ID   = 11912
					},
					{
						Type = 1,
						ID   = 12012
					}
				},
				GoodsID      = 2003,
				Tower        = 0,
				ExchangeType = 1,
				BuyType      = 0
			},
			[1143] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 0
					}
				},
				GoodsID      = 1143,
				Tower        = 1,
				ExchangeType = 3,
				BuyType      = 1
			},
			[1155] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10102
					},
					{
						Type = 1,
						ID   = 10204
					},
					{
						Type = 1,
						ID   = 10304
					},
					{
						Type = 1,
						ID   = 10404
					},
					{
						Type = 1,
						ID   = 10504
					},
					{
						Type = 1,
						ID   = 10604
					},
					{
						Type = 1,
						ID   = 10704
					},
					{
						Type = 1,
						ID   = 10804
					},
					{
						Type = 1,
						ID   = 10904
					},
					{
						Type = 1,
						ID   = 11004
					},
					{
						Type = 1,
						ID   = 11104
					},
					{
						Type = 1,
						ID   = 11204
					},
					{
						Type = 1,
						ID   = 11304
					},
					{
						Type = 1,
						ID   = 11404
					},
					{
						Type = 1,
						ID   = 11504
					},
					{
						Type = 1,
						ID   = 11604
					},
					{
						Type = 1,
						ID   = 11704
					},
					{
						Type = 1,
						ID   = 11804
					},
					{
						Type = 1,
						ID   = 11904
					},
					{
						Type = 1,
						ID   = 12004
					},
					{
						Type = 1,
						ID   = 10106
					},
					{
						Type = 1,
						ID   = 10208
					},
					{
						Type = 1,
						ID   = 10308
					},
					{
						Type = 1,
						ID   = 10408
					},
					{
						Type = 1,
						ID   = 10508
					},
					{
						Type = 1,
						ID   = 10608
					},
					{
						Type = 1,
						ID   = 10708
					},
					{
						Type = 1,
						ID   = 10808
					},
					{
						Type = 1,
						ID   = 10908
					},
					{
						Type = 1,
						ID   = 11008
					},
					{
						Type = 1,
						ID   = 11108
					},
					{
						Type = 1,
						ID   = 11208
					},
					{
						Type = 1,
						ID   = 11308
					},
					{
						Type = 1,
						ID   = 11408
					},
					{
						Type = 1,
						ID   = 11508
					},
					{
						Type = 1,
						ID   = 11608
					},
					{
						Type = 1,
						ID   = 11708
					},
					{
						Type = 1,
						ID   = 11808
					},
					{
						Type = 1,
						ID   = 11908
					},
					{
						Type = 1,
						ID   = 12008
					},
					{
						Type = 1,
						ID   = 10110
					},
					{
						Type = 1,
						ID   = 10212
					},
					{
						Type = 1,
						ID   = 10312
					},
					{
						Type = 1,
						ID   = 10412
					},
					{
						Type = 1,
						ID   = 10512
					},
					{
						Type = 1,
						ID   = 10612
					},
					{
						Type = 1,
						ID   = 10712
					},
					{
						Type = 1,
						ID   = 10812
					},
					{
						Type = 1,
						ID   = 10912
					},
					{
						Type = 1,
						ID   = 11012
					},
					{
						Type = 1,
						ID   = 11112
					},
					{
						Type = 1,
						ID   = 11212
					},
					{
						Type = 1,
						ID   = 11312
					},
					{
						Type = 1,
						ID   = 11412
					},
					{
						Type = 1,
						ID   = 11512
					},
					{
						Type = 1,
						ID   = 11612
					},
					{
						Type = 1,
						ID   = 11712
					},
					{
						Type = 1,
						ID   = 11812
					},
					{
						Type = 1,
						ID   = 11912
					},
					{
						Type = 1,
						ID   = 12012
					}
				},
				GoodsID      = 1155,
				Tower        = 0,
				ExchangeType = 1,
				BuyType      = 0
			},
			[1156] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10102
					},
					{
						Type = 1,
						ID   = 10204
					},
					{
						Type = 1,
						ID   = 10304
					},
					{
						Type = 1,
						ID   = 10404
					},
					{
						Type = 1,
						ID   = 10504
					},
					{
						Type = 1,
						ID   = 10604
					},
					{
						Type = 1,
						ID   = 10704
					},
					{
						Type = 1,
						ID   = 10804
					},
					{
						Type = 1,
						ID   = 10904
					},
					{
						Type = 1,
						ID   = 11004
					},
					{
						Type = 1,
						ID   = 11104
					},
					{
						Type = 1,
						ID   = 11204
					},
					{
						Type = 1,
						ID   = 11304
					},
					{
						Type = 1,
						ID   = 11404
					},
					{
						Type = 1,
						ID   = 11504
					},
					{
						Type = 1,
						ID   = 11604
					},
					{
						Type = 1,
						ID   = 11704
					},
					{
						Type = 1,
						ID   = 11804
					},
					{
						Type = 1,
						ID   = 11904
					},
					{
						Type = 1,
						ID   = 12004
					},
					{
						Type = 1,
						ID   = 10106
					},
					{
						Type = 1,
						ID   = 10208
					},
					{
						Type = 1,
						ID   = 10308
					},
					{
						Type = 1,
						ID   = 10408
					},
					{
						Type = 1,
						ID   = 10508
					},
					{
						Type = 1,
						ID   = 10608
					},
					{
						Type = 1,
						ID   = 10708
					},
					{
						Type = 1,
						ID   = 10808
					},
					{
						Type = 1,
						ID   = 10908
					},
					{
						Type = 1,
						ID   = 11008
					},
					{
						Type = 1,
						ID   = 11108
					},
					{
						Type = 1,
						ID   = 11208
					},
					{
						Type = 1,
						ID   = 11308
					},
					{
						Type = 1,
						ID   = 11408
					},
					{
						Type = 1,
						ID   = 11508
					},
					{
						Type = 1,
						ID   = 11608
					},
					{
						Type = 1,
						ID   = 11708
					},
					{
						Type = 1,
						ID   = 11808
					},
					{
						Type = 1,
						ID   = 11908
					},
					{
						Type = 1,
						ID   = 12008
					},
					{
						Type = 1,
						ID   = 10110
					},
					{
						Type = 1,
						ID   = 10212
					},
					{
						Type = 1,
						ID   = 10312
					},
					{
						Type = 1,
						ID   = 10412
					},
					{
						Type = 1,
						ID   = 10512
					},
					{
						Type = 1,
						ID   = 10612
					},
					{
						Type = 1,
						ID   = 10712
					},
					{
						Type = 1,
						ID   = 10812
					},
					{
						Type = 1,
						ID   = 10912
					},
					{
						Type = 1,
						ID   = 11012
					},
					{
						Type = 1,
						ID   = 11112
					},
					{
						Type = 1,
						ID   = 11212
					},
					{
						Type = 1,
						ID   = 11312
					},
					{
						Type = 1,
						ID   = 11412
					},
					{
						Type = 1,
						ID   = 11512
					},
					{
						Type = 1,
						ID   = 11612
					},
					{
						Type = 1,
						ID   = 11712
					},
					{
						Type = 1,
						ID   = 11812
					},
					{
						Type = 1,
						ID   = 11912
					},
					{
						Type = 1,
						ID   = 12012
					}
				},
				GoodsID      = 1156,
				Tower        = 0,
				ExchangeType = 1,
				BuyType      = 0
			},
			[1157] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10102
					},
					{
						Type = 1,
						ID   = 10204
					},
					{
						Type = 1,
						ID   = 10304
					},
					{
						Type = 1,
						ID   = 10404
					},
					{
						Type = 1,
						ID   = 10504
					},
					{
						Type = 1,
						ID   = 10604
					},
					{
						Type = 1,
						ID   = 10704
					},
					{
						Type = 1,
						ID   = 10804
					},
					{
						Type = 1,
						ID   = 10904
					},
					{
						Type = 1,
						ID   = 11004
					},
					{
						Type = 1,
						ID   = 11104
					},
					{
						Type = 1,
						ID   = 11204
					},
					{
						Type = 1,
						ID   = 11304
					},
					{
						Type = 1,
						ID   = 11404
					},
					{
						Type = 1,
						ID   = 11504
					},
					{
						Type = 1,
						ID   = 11604
					},
					{
						Type = 1,
						ID   = 11704
					},
					{
						Type = 1,
						ID   = 11804
					},
					{
						Type = 1,
						ID   = 11904
					},
					{
						Type = 1,
						ID   = 12004
					},
					{
						Type = 1,
						ID   = 10106
					},
					{
						Type = 1,
						ID   = 10208
					},
					{
						Type = 1,
						ID   = 10308
					},
					{
						Type = 1,
						ID   = 10408
					},
					{
						Type = 1,
						ID   = 10508
					},
					{
						Type = 1,
						ID   = 10608
					},
					{
						Type = 1,
						ID   = 10708
					},
					{
						Type = 1,
						ID   = 10808
					},
					{
						Type = 1,
						ID   = 10908
					},
					{
						Type = 1,
						ID   = 11008
					},
					{
						Type = 1,
						ID   = 11108
					},
					{
						Type = 1,
						ID   = 11208
					},
					{
						Type = 1,
						ID   = 11308
					},
					{
						Type = 1,
						ID   = 11408
					},
					{
						Type = 1,
						ID   = 11508
					},
					{
						Type = 1,
						ID   = 11608
					},
					{
						Type = 1,
						ID   = 11708
					},
					{
						Type = 1,
						ID   = 11808
					},
					{
						Type = 1,
						ID   = 11908
					},
					{
						Type = 1,
						ID   = 12008
					},
					{
						Type = 1,
						ID   = 10110
					},
					{
						Type = 1,
						ID   = 10212
					},
					{
						Type = 1,
						ID   = 10312
					},
					{
						Type = 1,
						ID   = 10412
					},
					{
						Type = 1,
						ID   = 10512
					},
					{
						Type = 1,
						ID   = 10612
					},
					{
						Type = 1,
						ID   = 10712
					},
					{
						Type = 1,
						ID   = 10812
					},
					{
						Type = 1,
						ID   = 10912
					},
					{
						Type = 1,
						ID   = 11012
					},
					{
						Type = 1,
						ID   = 11112
					},
					{
						Type = 1,
						ID   = 11212
					},
					{
						Type = 1,
						ID   = 11312
					},
					{
						Type = 1,
						ID   = 11412
					},
					{
						Type = 1,
						ID   = 11512
					},
					{
						Type = 1,
						ID   = 11612
					},
					{
						Type = 1,
						ID   = 11712
					},
					{
						Type = 1,
						ID   = 11812
					},
					{
						Type = 1,
						ID   = 11912
					},
					{
						Type = 1,
						ID   = 12012
					}
				},
				GoodsID      = 1157,
				Tower        = 0,
				ExchangeType = 1,
				BuyType      = 0
			},
			[1158] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10102
					},
					{
						Type = 1,
						ID   = 10204
					},
					{
						Type = 1,
						ID   = 10304
					},
					{
						Type = 1,
						ID   = 10404
					},
					{
						Type = 1,
						ID   = 10504
					},
					{
						Type = 1,
						ID   = 10604
					},
					{
						Type = 1,
						ID   = 10704
					},
					{
						Type = 1,
						ID   = 10804
					},
					{
						Type = 1,
						ID   = 10904
					},
					{
						Type = 1,
						ID   = 11004
					},
					{
						Type = 1,
						ID   = 11104
					},
					{
						Type = 1,
						ID   = 11204
					},
					{
						Type = 1,
						ID   = 11304
					},
					{
						Type = 1,
						ID   = 11404
					},
					{
						Type = 1,
						ID   = 11504
					},
					{
						Type = 1,
						ID   = 11604
					},
					{
						Type = 1,
						ID   = 11704
					},
					{
						Type = 1,
						ID   = 11804
					},
					{
						Type = 1,
						ID   = 11904
					},
					{
						Type = 1,
						ID   = 12004
					},
					{
						Type = 1,
						ID   = 10106
					},
					{
						Type = 1,
						ID   = 10208
					},
					{
						Type = 1,
						ID   = 10308
					},
					{
						Type = 1,
						ID   = 10408
					},
					{
						Type = 1,
						ID   = 10508
					},
					{
						Type = 1,
						ID   = 10608
					},
					{
						Type = 1,
						ID   = 10708
					},
					{
						Type = 1,
						ID   = 10808
					},
					{
						Type = 1,
						ID   = 10908
					},
					{
						Type = 1,
						ID   = 11008
					},
					{
						Type = 1,
						ID   = 11108
					},
					{
						Type = 1,
						ID   = 11208
					},
					{
						Type = 1,
						ID   = 11308
					},
					{
						Type = 1,
						ID   = 11408
					},
					{
						Type = 1,
						ID   = 11508
					},
					{
						Type = 1,
						ID   = 11608
					},
					{
						Type = 1,
						ID   = 11708
					},
					{
						Type = 1,
						ID   = 11808
					},
					{
						Type = 1,
						ID   = 11908
					},
					{
						Type = 1,
						ID   = 12008
					},
					{
						Type = 1,
						ID   = 10110
					},
					{
						Type = 1,
						ID   = 10212
					},
					{
						Type = 1,
						ID   = 10312
					},
					{
						Type = 1,
						ID   = 10412
					},
					{
						Type = 1,
						ID   = 10512
					},
					{
						Type = 1,
						ID   = 10612
					},
					{
						Type = 1,
						ID   = 10712
					},
					{
						Type = 1,
						ID   = 10812
					},
					{
						Type = 1,
						ID   = 10912
					},
					{
						Type = 1,
						ID   = 11012
					},
					{
						Type = 1,
						ID   = 11112
					},
					{
						Type = 1,
						ID   = 11212
					},
					{
						Type = 1,
						ID   = 11312
					},
					{
						Type = 1,
						ID   = 11412
					},
					{
						Type = 1,
						ID   = 11512
					},
					{
						Type = 1,
						ID   = 11612
					},
					{
						Type = 1,
						ID   = 11712
					},
					{
						Type = 1,
						ID   = 11812
					},
					{
						Type = 1,
						ID   = 11912
					},
					{
						Type = 1,
						ID   = 12012
					}
				},
				GoodsID      = 1158,
				Tower        = 0,
				ExchangeType = 1,
				BuyType      = 0
			}
		}
	},
	[2] = 
	{
		GoodsType    = 2,
		GoodsID_List = 
		{
			[1006] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1006,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1008] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1008,
				Tower        = 0,
				ExchangeType = 5,
				BuyType      = 1
			},
			[1009] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1009,
				Tower        = 0,
				ExchangeType = 5,
				BuyType      = 1
			},
			[1011] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1011,
				Tower        = 0,
				ExchangeType = 4,
				BuyType      = 1
			},
			[1012] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1012,
				Tower        = 0,
				ExchangeType = 3,
				BuyType      = 1
			},
			[1013] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1013,
				Tower        = 0,
				ExchangeType = 4,
				BuyType      = 1
			},
			[1015] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1015,
				Tower        = 0,
				ExchangeType = 3,
				BuyType      = 1
			},
			[1016] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 2,
						ID   = 11206
					},
					{
						Type = 2,
						ID   = 11512
					},
					{
						Type = 2,
						ID   = 118122
					},
					{
						Type = 2,
						ID   = 11512
					}
				},
				GoodsID      = 1016,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1018] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 2,
						ID   = 10806
					},
					{
						Type = 2,
						ID   = 11412
					},
					{
						Type = 2,
						ID   = 117122
					},
					{
						Type = 2,
						ID   = 11412
					}
				},
				GoodsID      = 1018,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1019] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 2,
						ID   = 11006
					},
					{
						Type = 2,
						ID   = 11508
					},
					{
						Type = 2,
						ID   = 117062
					},
					{
						Type = 2,
						ID   = 11508
					}
				},
				GoodsID      = 1019,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1020] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 2,
						ID   = 10312
					},
					{
						Type = 2,
						ID   = 10612
					},
					{
						Type = 2,
						ID   = 107062
					},
					{
						Type = 2,
						ID   = 10612
					}
				},
				GoodsID      = 1020,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1021] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 2,
						ID   = 10904
					},
					{
						Type = 2,
						ID   = 11304
					},
					{
						Type = 2,
						ID   = 118062
					},
					{
						Type = 2,
						ID   = 11304
					}
				},
				GoodsID      = 1021,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1022] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1022,
				Tower        = 0,
				ExchangeType = 3,
				BuyType      = 1
			},
			[1026] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 2,
						ID   = 10504
					},
					{
						Type = 2,
						ID   = 10708
					},
					{
						Type = 2,
						ID   = 111122
					},
					{
						Type = 2,
						ID   = 10708
					},
					{
						Type = 2,
						ID   = 11612
					}
				},
				GoodsID      = 1026,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1027] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 2,
						ID   = 10101
					},
					{
						Type = 2,
						ID   = 10206
					},
					{
						Type = 2,
						ID   = 106012
					},
					{
						Type = 2,
						ID   = 10206
					},
					{
						Type = 2,
						ID   = 11410
					}
				},
				GoodsID      = 1027,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1028] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 2,
						ID   = 10512
					},
					{
						Type = 2,
						ID   = 10604
					},
					{
						Type = 2,
						ID   = 110102
					},
					{
						Type = 2,
						ID   = 10604
					},
					{
						Type = 2,
						ID   = 11601
					}
				},
				GoodsID      = 1028,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1029] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1029,
				Tower        = 0,
				ExchangeType = 3,
				BuyType      = 1
			},
			[1030] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1030,
				Tower        = 0,
				ExchangeType = 4,
				BuyType      = 1
			},
			[1031] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1031,
				Tower        = 0,
				ExchangeType = 4,
				BuyType      = 1
			},
			[1032] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 2,
						ID   = 10406
					},
					{
						Type = 2,
						ID   = 10508
					},
					{
						Type = 2,
						ID   = 112122
					},
					{
						Type = 2,
						ID   = 10508
					},
					{
						Type = 2,
						ID   = 11608
					}
				},
				GoodsID      = 1032,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1033] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 2,
						ID   = 10212
					},
					{
						Type = 2,
						ID   = 10606
					},
					{
						Type = 2,
						ID   = 107122
					},
					{
						Type = 2,
						ID   = 10606
					},
					{
						Type = 2,
						ID   = 12004
					}
				},
				GoodsID      = 1033,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1034] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1034,
				Tower        = 0,
				ExchangeType = 3,
				BuyType      = 1
			},
			[1035] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1035,
				Tower        = 0,
				ExchangeType = 3,
				BuyType      = 1
			},
			[1036] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 2,
						ID   = 10301
					},
					{
						Type = 2,
						ID   = 10610
					},
					{
						Type = 2,
						ID   = 109012
					},
					{
						Type = 2,
						ID   = 10610
					},
					{
						Type = 2,
						ID   = 11801
					}
				},
				GoodsID      = 1036,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1039] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 2,
						ID   = 10506
					},
					{
						Type = 2,
						ID   = 10906
					},
					{
						Type = 2,
						ID   = 111102
					},
					{
						Type = 2,
						ID   = 10906
					},
					{
						Type = 2,
						ID   = 11904
					}
				},
				GoodsID      = 1039,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1040] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 2,
						ID   = 10104
					},
					{
						Type = 2,
						ID   = 10412
					},
					{
						Type = 2,
						ID   = 110122
					},
					{
						Type = 2,
						ID   = 10412
					},
					{
						Type = 2,
						ID   = 11704
					}
				},
				GoodsID      = 1040,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1042] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 2,
						ID   = 10910
					},
					{
						Type = 2,
						ID   = 11001
					},
					{
						Type = 2,
						ID   = 117082
					},
					{
						Type = 2,
						ID   = 11001
					},
					{
						Type = 2,
						ID   = 11912
					}
				},
				GoodsID      = 1042,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1043] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 2,
						ID   = 10210
					},
					{
						Type = 2,
						ID   = 10306
					},
					{
						Type = 2,
						ID   = 105102
					},
					{
						Type = 2,
						ID   = 10306
					},
					{
						Type = 2,
						ID   = 11201
					}
				},
				GoodsID      = 1043,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1044] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 2,
						ID   = 10208
					},
					{
						Type = 2,
						ID   = 10404
					},
					{
						Type = 2,
						ID   = 111042
					},
					{
						Type = 2,
						ID   = 10404
					},
					{
						Type = 2,
						ID   = 11610
					}
				},
				GoodsID      = 1044,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1045] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 2,
						ID   = 10801
					},
					{
						Type = 2,
						ID   = 11210
					},
					{
						Type = 2,
						ID   = 118082
					},
					{
						Type = 2,
						ID   = 11210
					},
					{
						Type = 2,
						ID   = 12001
					}
				},
				GoodsID      = 1045,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1046] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1046,
				Tower        = 0,
				ExchangeType = 4,
				BuyType      = 1
			},
			[1047] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 2,
						ID   = 10701
					},
					{
						Type = 2,
						ID   = 11408
					},
					{
						Type = 2,
						ID   = 115012
					},
					{
						Type = 2,
						ID   = 11408
					},
					{
						Type = 2,
						ID   = 12010
					}
				},
				GoodsID      = 1047,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1048] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
				},
				GoodsID      = 1048,
				Tower        = 0,
				ExchangeType = 4,
				BuyType      = 1
			},
			[1049] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 2,
						ID   = 10304
					},
					{
						Type = 2,
						ID   = 10912
					},
					{
						Type = 2,
						ID   = 113082
					},
					{
						Type = 2,
						ID   = 10912
					},
					{
						Type = 2,
						ID   = 11504
					}
				},
				GoodsID      = 1049,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1050] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 2,
						ID   = 10106
					},
					{
						Type = 2,
						ID   = 10401
					},
					{
						Type = 2,
						ID   = 108102
					},
					{
						Type = 2,
						ID   = 10401
					},
					{
						Type = 2,
						ID   = 11908
					}
				},
				GoodsID      = 1050,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1052] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 2,
						ID   = 10108
					},
					{
						Type = 2,
						ID   = 10501
					},
					{
						Type = 2,
						ID   = 106082
					},
					{
						Type = 2,
						ID   = 10501
					},
					{
						Type = 2,
						ID   = 11804
					}
				},
				GoodsID      = 1052,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1053] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 2,
						ID   = 10110
					},
					{
						Type = 2,
						ID   = 10310
					},
					{
						Type = 2,
						ID   = 108122
					},
					{
						Type = 2,
						ID   = 10310
					},
					{
						Type = 2,
						ID   = 11406
					}
				},
				GoodsID      = 1053,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1054] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 2,
						ID   = 10204
					},
					{
						Type = 2,
						ID   = 10408
					},
					{
						Type = 2,
						ID   = 109082
					},
					{
						Type = 2,
						ID   = 10408
					},
					{
						Type = 2,
						ID   = 11510
					}
				},
				GoodsID      = 1054,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1055] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 2,
						ID   = 10201
					},
					{
						Type = 2,
						ID   = 10410
					},
					{
						Type = 2,
						ID   = 107102
					},
					{
						Type = 2,
						ID   = 10410
					},
					{
						Type = 2,
						ID   = 11404
					}
				},
				GoodsID      = 1055,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			},
			[1056] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 2,
						ID   = 10102
					},
					{
						Type = 2,
						ID   = 10308
					},
					{
						Type = 2,
						ID   = 108042
					},
					{
						Type = 2,
						ID   = 10308
					},
					{
						Type = 2,
						ID   = 11101
					}
				},
				GoodsID      = 1056,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 1
			}
		}
	},
	[4] = 
	{
		GoodsType    = 4,
		GoodsID_List = 
		{
			[1008] = 
			{
				ComposeID    = 0,
				InstanceList = {
					
					{
						Type = 1,
						ID   = 10102
					},
					{
						Type = 1,
						ID   = 10204
					},
					{
						Type = 1,
						ID   = 10304
					},
					{
						Type = 1,
						ID   = 10404
					},
					{
						Type = 1,
						ID   = 10504
					},
					{
						Type = 1,
						ID   = 10604
					},
					{
						Type = 1,
						ID   = 10704
					},
					{
						Type = 1,
						ID   = 10804
					},
					{
						Type = 1,
						ID   = 10904
					},
					{
						Type = 1,
						ID   = 11004
					},
					{
						Type = 1,
						ID   = 11104
					},
					{
						Type = 1,
						ID   = 11204
					},
					{
						Type = 1,
						ID   = 11304
					},
					{
						Type = 1,
						ID   = 11404
					},
					{
						Type = 1,
						ID   = 11504
					},
					{
						Type = 1,
						ID   = 11604
					},
					{
						Type = 1,
						ID   = 11704
					},
					{
						Type = 1,
						ID   = 11804
					},
					{
						Type = 1,
						ID   = 11904
					},
					{
						Type = 1,
						ID   = 12004
					},
					{
						Type = 1,
						ID   = 10106
					},
					{
						Type = 1,
						ID   = 10208
					},
					{
						Type = 1,
						ID   = 10308
					},
					{
						Type = 1,
						ID   = 10408
					},
					{
						Type = 1,
						ID   = 10508
					},
					{
						Type = 1,
						ID   = 10608
					},
					{
						Type = 1,
						ID   = 10708
					},
					{
						Type = 1,
						ID   = 10808
					},
					{
						Type = 1,
						ID   = 10908
					},
					{
						Type = 1,
						ID   = 11008
					},
					{
						Type = 1,
						ID   = 11108
					},
					{
						Type = 1,
						ID   = 11208
					},
					{
						Type = 1,
						ID   = 11308
					},
					{
						Type = 1,
						ID   = 11408
					},
					{
						Type = 1,
						ID   = 11508
					},
					{
						Type = 1,
						ID   = 11608
					},
					{
						Type = 1,
						ID   = 11708
					},
					{
						Type = 1,
						ID   = 11808
					},
					{
						Type = 1,
						ID   = 11908
					},
					{
						Type = 1,
						ID   = 12008
					},
					{
						Type = 1,
						ID   = 10110
					},
					{
						Type = 1,
						ID   = 10212
					},
					{
						Type = 1,
						ID   = 10312
					},
					{
						Type = 1,
						ID   = 10412
					},
					{
						Type = 1,
						ID   = 10512
					},
					{
						Type = 1,
						ID   = 10612
					},
					{
						Type = 1,
						ID   = 10712
					},
					{
						Type = 1,
						ID   = 10812
					},
					{
						Type = 1,
						ID   = 10912
					},
					{
						Type = 1,
						ID   = 11012
					},
					{
						Type = 1,
						ID   = 11112
					},
					{
						Type = 1,
						ID   = 11212
					},
					{
						Type = 1,
						ID   = 11312
					},
					{
						Type = 1,
						ID   = 11412
					},
					{
						Type = 1,
						ID   = 11512
					},
					{
						Type = 1,
						ID   = 11612
					},
					{
						Type = 1,
						ID   = 11712
					},
					{
						Type = 1,
						ID   = 11812
					},
					{
						Type = 1,
						ID   = 11912
					},
					{
						Type = 1,
						ID   = 12012
					},
					{
						Type = 2,
						ID   = 10102
					},
					{
						Type = 2,
						ID   = 10204
					},
					{
						Type = 2,
						ID   = 10304
					},
					{
						Type = 2,
						ID   = 10404
					},
					{
						Type = 2,
						ID   = 10504
					},
					{
						Type = 2,
						ID   = 10604
					},
					{
						Type = 2,
						ID   = 10704
					},
					{
						Type = 2,
						ID   = 10804
					},
					{
						Type = 2,
						ID   = 10904
					},
					{
						Type = 2,
						ID   = 11004
					},
					{
						Type = 2,
						ID   = 11104
					},
					{
						Type = 2,
						ID   = 11204
					},
					{
						Type = 2,
						ID   = 11304
					},
					{
						Type = 2,
						ID   = 11404
					},
					{
						Type = 2,
						ID   = 11504
					},
					{
						Type = 2,
						ID   = 11604
					},
					{
						Type = 2,
						ID   = 11704
					},
					{
						Type = 2,
						ID   = 11804
					},
					{
						Type = 2,
						ID   = 11904
					},
					{
						Type = 2,
						ID   = 12004
					},
					{
						Type = 2,
						ID   = 10106
					},
					{
						Type = 2,
						ID   = 10208
					},
					{
						Type = 2,
						ID   = 10308
					},
					{
						Type = 2,
						ID   = 10408
					},
					{
						Type = 2,
						ID   = 10508
					},
					{
						Type = 2,
						ID   = 10608
					},
					{
						Type = 2,
						ID   = 10708
					},
					{
						Type = 2,
						ID   = 10808
					},
					{
						Type = 2,
						ID   = 10908
					},
					{
						Type = 2,
						ID   = 11008
					},
					{
						Type = 2,
						ID   = 11108
					},
					{
						Type = 2,
						ID   = 11208
					},
					{
						Type = 2,
						ID   = 11308
					},
					{
						Type = 2,
						ID   = 11408
					},
					{
						Type = 2,
						ID   = 11508
					},
					{
						Type = 2,
						ID   = 11608
					},
					{
						Type = 2,
						ID   = 11708
					},
					{
						Type = 2,
						ID   = 11808
					},
					{
						Type = 2,
						ID   = 11908
					},
					{
						Type = 2,
						ID   = 12008
					},
					{
						Type = 2,
						ID   = 10110
					},
					{
						Type = 2,
						ID   = 10212
					},
					{
						Type = 2,
						ID   = 10312
					},
					{
						Type = 2,
						ID   = 10412
					},
					{
						Type = 2,
						ID   = 10512
					},
					{
						Type = 2,
						ID   = 10612
					},
					{
						Type = 2,
						ID   = 10712
					},
					{
						Type = 2,
						ID   = 10812
					},
					{
						Type = 2,
						ID   = 10912
					},
					{
						Type = 2,
						ID   = 11012
					},
					{
						Type = 2,
						ID   = 11112
					},
					{
						Type = 2,
						ID   = 11212
					},
					{
						Type = 2,
						ID   = 11312
					},
					{
						Type = 2,
						ID   = 11412
					},
					{
						Type = 2,
						ID   = 11512
					},
					{
						Type = 2,
						ID   = 11612
					},
					{
						Type = 2,
						ID   = 11712
					},
					{
						Type = 2,
						ID   = 11812
					},
					{
						Type = 2,
						ID   = 11912
					},
					{
						Type = 2,
						ID   = 12012
					}
				},
				GoodsID      = 1008,
				Tower        = 0,
				ExchangeType = 0,
				BuyType      = 0
			}
		}
	}
}

_M:Init()

return _M
