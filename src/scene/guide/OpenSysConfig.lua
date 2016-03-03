local OpenSysTable = {

--  1 开灵石
nil,
{  -- 2 技能引导
	mapx = SCREEN_WIDTH*0.5-965, mapy = 0, personx = 965, persony = 150,
	pages = { ["MainLayer"] = true, ["AllHeroLayer"] = true, ["NewHeroLayer"] = true },
	steps = {
		{ -- 星将入口
			x = SCREEN_WIDTH-44, y = SCREEN_HEIGHT - 50, width = 75, height = 65, 
			guide = {guide_type = "click",   x1 = SCREEN_WIDTH-44, y1 = SCREEN_HEIGHT - 50 },
			text_box = { text = "[255,255,255]打开星将列表界面，升级\n星将的[=][255,0,0]怒气技能[=][255,255,255]。[=]", icon_dir = "right",
						picX = SCREEN_WIDTH-140, picY = 100,
						},
			audio = "new_skill",
		},
		{ -- 选择八戒
			x = SCREEN_WIDTH*0.5-200, y =  SCREEN_HEIGHT*0.5+65, width = 380, height = 125, 
			guide = {guide_type = "click",   x1 = SCREEN_WIDTH*0.5-200, y1 =  SCREEN_HEIGHT*0.5+55 },
			text_box = nil,
		},	
		{ -- 点击技能按钮
			x = SCREEN_WIDTH*0.5-148, y =  SCREEN_HEIGHT*0.5-230, width = 110, height = 65,
			guide = {guide_type = "click",    x1 = SCREEN_WIDTH*0.5-148, y1 =  SCREEN_HEIGHT*0.5-230 },
			text_box = nil,
			-- audio = "new_28",
		},	
		{ -- 升级
			x = SCREEN_WIDTH*0.5+408, y =  SCREEN_HEIGHT*0.5+128, width = 60, height = 60, 
			guide = {guide_type = "click",  x1 = SCREEN_WIDTH*0.5+408, y1 =  SCREEN_HEIGHT*0.5+128 },
			text_box = { text = "[255,255,255]消耗[=][255,0,0]技能点[=][255,255,255]为星将的怒气\n技能升级。[=]", icon_dir = "left",
						picX = SCREEN_WIDTH*0.5-60, picY = SCREEN_HEIGHT*0.5-150,
						} ,
		},
		{ -- 升级
			x = SCREEN_WIDTH*0.5+408, y =  SCREEN_HEIGHT*0.5+128, width = 60, height = 60, 
			guide = {guide_type = "click",  x1 = SCREEN_WIDTH*0.5+408, y1 =  SCREEN_HEIGHT*0.5+128 },
			text_box = { text = "[255,255,255]技能等级越高，消耗的技能点越多。[=]", icon_dir = "left",
						picX = SCREEN_WIDTH*0.5-60, picY = SCREEN_HEIGHT*0.5-150,
						} ,
			audio = "new_29",
			justshow = true,
		},	
	}

},

{  -- 3 日常任务
	mapx = SCREEN_WIDTH*0.5-965, mapy = 0, personx = 965, persony = 150,
	pages = { ["MainLayer"] = true, ["TaskLayer"] = true},
	steps = {
		{ -- 日常任务入口
			x = SCREEN_WIDTH*0.15+239, y = SCREEN_HEIGHT-105, width = 75, height = 60,  
			guide = {guide_type = "click",  x1 = SCREEN_WIDTH*0.15+239, y1 = SCREEN_HEIGHT-105 },
			text_box = { text = "[255,255,255]完成日常任务可获得[=][255,0,0]大量\n经验[=][255,255,255]，升级so easy![=]", icon_dir = "left",
						picX = SCREEN_WIDTH*0.5-70, picY = SCREEN_HEIGHT*0.5-132,
						 },
			audio = "new_mission",		 
		},
		{ 
			x = SCREEN_WIDTH*0.5, y =  SCREEN_HEIGHT*0.5, width = SCREEN_WIDTH, height = SCREEN_HEIGHT,
			guide = {guide_type = "click",  x1 = SCREEN_WIDTH*0.5+230, y1 = SCREEN_HEIGHT*0.5+110 },
			justshow = true,
		},
	}

},


{  -- 4  神仙学院
	mapx = SCREEN_WIDTH*0.5-785, mapy = 0, personx = 785, persony = 150,
	pages = { ["MainLayer"] = true, ["EnergyLayer"] = true},
	steps = {
		{-- 学院入口
			x = SCREEN_WIDTH*0.5, y = 385, width = 230, height = 160, 
			guide = {guide_type = "click", x1 = SCREEN_WIDTH*0.5, y1 = 380},
			text_box ={ text = "[255,255,255]用冒险剧场积分提升上阵星将属性。[=]", icon_dir = "left",
						picX = SCREEN_WIDTH*0.5-320, picY = SCREEN_HEIGHT*0.5-200,
						},
			audio = "new_school"
		},
		{ 
			x = SCREEN_WIDTH*0.5, y =  SCREEN_HEIGHT*0.5, width = SCREEN_WIDTH, height = SCREEN_HEIGHT,
			guide = {guide_type = "click",  x1 = SCREEN_WIDTH*0.5+46, y1 = SCREEN_HEIGHT*0.4-170 },
			justshow = true,
		},
	}

},


{  -- 5 夺宝
	mapx = SCREEN_WIDTH*0.5-2185, mapy = 0, personx = 2185, persony = 150,
	pages = { ["MainLayer"] = true, ["LootLayer"] = true, ["LootListLayer"] = true, ["BattleFormLayer"] = true },
	steps = {
		{ -- 夺宝入口
			x = SCREEN_WIDTH*0.5, y = 330, width = 70, height = 120,
			guide = {guide_type = "click", x1 = SCREEN_WIDTH*0.5, y1 = 325},
			text_box = { text = "[255,255,255]快去抢夺其他玩家的[=][255,0,0]符咒\n和天书[=][255,255,255]吧[=]", icon_dir = "left",
						picX = SCREEN_WIDTH*0.5-240, picY = SCREEN_HEIGHT*0.5-300,
						},
			audio = "new_rob",
		},
		{ -- 选择碎片
			x = SCREEN_WIDTH*0.5+180, y =  SCREEN_HEIGHT*0.5+25, width = 80, height = 80, 
			guide = {guide_type = "click",   x1 = SCREEN_WIDTH*0.5+180, y1 =  SCREEN_HEIGHT*0.5+20 },
			text_box = { text = "[255,0,0]集齐碎片[=][255,255,255]后合成符咒或天书！[=]", icon_dir = "left",
						picX = SCREEN_WIDTH*0.5-240, picY = SCREEN_HEIGHT*0.5-280,
						} ,
			audio = "new_rob_2",

		},	
		{ -- 点击抢夺按钮
			x = SCREEN_WIDTH*0.5+226, y =  SCREEN_HEIGHT*0.5+120, width = 136, height = 60,
			guide = {guide_type = "click",    x1 = SCREEN_WIDTH*0.5+226, y1 =  SCREEN_HEIGHT*0.5+110 },
			text_box = nil,
		},	
		{ -- 布阵开抢
			x = SCREEN_WIDTH*0.5-260, y =  SCREEN_HEIGHT*0.5, width = 220, height = 620, 
			guide = nil,
			text_box = { text = "[255,255,255]别忘了让星将们[=][255,0,0]上阵[=][255,255,255]哟![=]", icon_dir = "right",
						picX = SCREEN_WIDTH*0.5+77, picY = SCREEN_HEIGHT*0.5-195,
						} ,
			justshow = true,
		},
	}

},

{  -- 6 温泉浴场
	mapx = 0, mapy = 0, personx = SCREEN_WIDTH*0.5, persony = 150,
	pages = { ["MainLayer"] = true, ["FairyLayer"] = true},
	steps = {
		{ -- 仙女入口
			x = 495, y = 390, width = 160, height = 200, 
			guide = {guide_type = "click", x1 = 495, y1 = 390},
			text_box = { text = "[255,255,255]想和漂亮的[=][255,0,0]仙女们[=][255,255,255]一起泡\n温泉么，千万别舔屏哟！[=]", icon_dir = "left",
						picX = SCREEN_WIDTH*0.5-240, picY = SCREEN_HEIGHT*0.5-200,
						},
			audio = "new_fairy"
		},
		{ -- 选择礼物
			x = SCREEN_WIDTH*0.5+260, y =  75, width = 90, height = 90, 
			guide = {guide_type = "click",   x1 = SCREEN_WIDTH*0.5+260, y1 = 70 },
			text_box = { text = "[255,0,0]赠送礼物[=][255,255,255]可以提升仙女的\n等级，还能获得红心哟[=]", icon_dir = "left",
						picX = SCREEN_WIDTH*0.5, picY = SCREEN_HEIGHT*0.5-255,
						} ,
			audio = "new_fairy_2"
		},	
		{ -- 点击技能
			x = SCREEN_WIDTH*0.5+210, y =  215, width = 90, height = 90,
			guide = {guide_type = "click",    x1 = SCREEN_WIDTH*0.5+210, y1 = 215 },
			text_box = { text = "[255,255,255]仙女等级提升后，就可以\n升级仙女的[=][255,0,0]技能[=][255,255,255]了[=]", icon_dir = "right",
						picX = SCREEN_WIDTH*0.5+140, picY = SCREEN_HEIGHT*0.5-100,
						} ,
		},	
		{ -- 升级技能
			x = SCREEN_WIDTH*0.5, y =  SCREEN_HEIGHT*0.5-108, width = 145, height = 60, 
			guide = {guide_type = "click",    x1 = SCREEN_WIDTH*0.5, y1 =  SCREEN_HEIGHT*0.5-108 },

		},
	}
	
},
{  -- 7 竞技场
	mapx = SCREEN_WIDTH*0.5-1420, mapy = 0, personx = 1420, persony = 150,
	pages = { ["MainLayer"] = true, ["ColiseumLayer"] = true},
	steps = {
		{-- 竞技场入口
			x = SCREEN_WIDTH*0.5, y = 400, width = 160, height = 180,
			guide = {guide_type = "click", x1 = SCREEN_WIDTH*0.5, y1 = 400},
			text_box ={ text = "[255,255,255]快来展现强悍的战斗力，\n[=][255,0,0]称霸服务器[=][255,255,255]吧！[=]", icon_dir = "left",
						picX = SCREEN_WIDTH*0.5-150, picY = SCREEN_HEIGHT*0.5-200,
						},
			audio = "new_jjc"
		},
		{ 
			x = SCREEN_WIDTH*0.5, y =  SCREEN_HEIGHT*0.5, width = SCREEN_WIDTH, height = SCREEN_HEIGHT,
			guide = {guide_type = "click", x1 = SCREEN_WIDTH*0.5+350, y1 = 140},
			justshow = true,
		},
	}
},
{  -- 8 家园
	mapx = SCREEN_WIDTH*0.5-745, mapy = 0, personx = 745, persony = 150,
	pages = { ["MainLayer"] = true, ["HomeLayer"] = true},
	steps = {
		{-- 家园入口
			x = SCREEN_WIDTH-270, y = 70, width = 100, height = 90, 
			guide = {guide_type = "click", x1 = SCREEN_WIDTH-270, y1 = 70},
			text_box ={ text = "[255,255,255]开公司建工厂当上CEO，\n从此走上人生巅峰！[=]", icon_dir = "left",
						picX = SCREEN_WIDTH*0.5-100, picY = SCREEN_HEIGHT*0.5-215,
						},
			audio = "new_jiayuan"

		},
		{ 
			x = SCREEN_WIDTH*0.5, y =  SCREEN_HEIGHT*0.5, width = SCREEN_WIDTH, height = SCREEN_HEIGHT,
			guide = {guide_type = "click",  x1 = SCREEN_WIDTH*0.5, y1 = SCREEN_HEIGHT*0.5 },
			justshow = true,
		},
	}

},

{  -- 9 每日副本
	mapx = SCREEN_WIDTH-2964, mapy = 0, personx = 2964-SCREEN_WIDTH*0.5, persony = 150,
	pages = { ["MainLayer"] = true, ["InstanceDailyLayer"] = true},
	steps = {
		{-- 每日副本入口
			x = 270, y = 156, width = 280, height = 250, 
			guide = {guide_type = "click", x1 = 270, y1 = 156},
			text_box ={ text = "[255,0,0]每天一种[=][255,255,255]创意玩法，还有\n好东西掉落哟！[=]", icon_dir = "left",
						picX = SCREEN_WIDTH*0.5-200, picY = SCREEN_HEIGHT*0.5-200,
						},
			audio = "new_yule"
		},
		{ 
			x = SCREEN_WIDTH*0.5, y =  SCREEN_HEIGHT*0.5, width = SCREEN_WIDTH, height = SCREEN_HEIGHT,
			guide = {guide_type = "click",  x1 = SCREEN_WIDTH*0.5+360, y1 = 450},
			justshow = true,
		},
	}

},


{  -- 10 西天取经
	mapx = SCREEN_WIDTH-2964, mapy = 0, personx = 2964-SCREEN_WIDTH*0.5, persony = 150,
	pages = { ["MainLayer"] = true, ["TransportLayer"] = true},
	steps = {
		{-- 取经入口
			x = SCREEN_WIDTH-579, y = 330, width = 130, height = 150,
			guide = {guide_type = "click",  x1 = SCREEN_WIDTH-580, y1 = 330},
			text_box ={ text = "[255,0,0]护送[=][255,255,255]唐僧师徒去取经，还\n能“[=][255,0,0]打劫[=][255,255,255]”哦！[=]", icon_dir = "left",
						picX = SCREEN_WIDTH*0.5-250, picY = SCREEN_HEIGHT*0.5-250,
						},
			audio = "new_qujing"

		},
		{ 
			x = SCREEN_WIDTH*0.5, y =  SCREEN_HEIGHT*0.5, width = SCREEN_WIDTH, height = SCREEN_HEIGHT,
			guide = {guide_type = "click",  x1 = SCREEN_WIDTH*0.5, y1 = 110 },
			justshow = true,
		},
	}

},

{  -- 11 电视塔
	mapx = SCREEN_WIDTH*0.5-1985, mapy = 0, personx = 1985, persony = 150,
	pages = { ["MainLayer"] = true, ["TowerLayer"] = true},
	steps = {
		{-- 爬塔入口
			x = SCREEN_WIDTH*0.5, y = 400, width = 130, height = 125, 
			guide = {guide_type = "click",  x1 = SCREEN_WIDTH*0.5, y1 = 400},
			text_box ={ text = "[255,255,255]每天爬一次电视塔，既能\n健身还能[=][255,0,0]得宝贝[=][255,255,255]哟！[=]", icon_dir = "left",
						picX = SCREEN_WIDTH*0.5-150, picY = SCREEN_HEIGHT*0.5-200,
						},
			audio = "new_ta"

		},
		{ 
			x = SCREEN_WIDTH*0.5, y =  SCREEN_HEIGHT*0.5, width = SCREEN_WIDTH, height = SCREEN_HEIGHT,
			guide = {guide_type = "click",  x1 = SCREEN_WIDTH*0.5, y1 = SCREEN_HEIGHT*0.5-30 },
			justshow = true,
		},
	}

	
	
},

{  -- 12 星将公寓
	mapx = 0, mapy = 0, personx = SCREEN_WIDTH*0.5, persony = 150,
	pages = { ["MainLayer"] = true, ["ApartmentLayer"] = true},
	steps = {
		{-- 爬塔入口
			x = 220, y = 375, width = 230, height = 220, 
			guide = {guide_type = "click",  x1 = 220, y1 = 375},
			text_box ={ text = "[255,255,255]顶级服务，奢华享受，入\n住星将[=][255,0,0]提升大量属性[=][255,255,255]哟！[=]", icon_dir = "left",
						picX = SCREEN_WIDTH*0.5, picY = SCREEN_HEIGHT*0.5-132,
						},

		},
		{ 
			x = SCREEN_WIDTH*0.5, y =  SCREEN_HEIGHT*0.5, width = SCREEN_WIDTH, height = SCREEN_HEIGHT,
			guide = {guide_type = "click",  x1 = SCREEN_WIDTH*0.5-300, y1 = SCREEN_HEIGHT*0.5+50 },
			justshow = true,
		},
	}

	
	
},

}

return OpenSysTable
