--
-- Author: keyring
-- Date: 2015-09-17 11:12:14
--


local GuideStepTable = {
	-- 1
	nil, -- 取名字

	-- 2
	{	
		desc = "指引猪八戒战斗",
		pages = { ["MainLayer"] = true, ["MapInstanceLayer"] = true, ["BattleFormLayer"] = true ,["BattleLayer"] = true, ["MapBattleWinLayer"] = true},
		steps = {
			{-- 副本入口
				x = SCREEN_WIDTH-110, y =  70, width = 140, height = 130,
				guide = {guide_type = "click",  x1 = SCREEN_WIDTH-110, y1 = 70},
				text_box = { text = "[255,255,255]进入冒险剧场，让我们去\n看看[=][255,0,0]八戒的故事[=][255,255,255]吧[=]", icon_dir = "left",
				 			 picX = SCREEN_WIDTH*0.5-266, picY = SCREEN_HEIGHT*0.5-132,
				 			},
				audio = "new_39",
			},

			{ -- 开始副本
				x = 0.5*SCREEN_WIDTH, y =  SCREEN_HEIGHT*0.5, width = 225, height = 225,   
				guide = {guide_type = "click",  x1 = 0.5*SCREEN_WIDTH, y1 = SCREEN_HEIGHT*0.5},
				text_box = { text = "[255,255,255]点击“[=][255,0,0]播放[=][255,255,255]”，看好戏还能得装备碎片哟！[=]", icon_dir = "right",
							 picX = SCREEN_WIDTH-140, picY = 30,
							 },
				audio = "new_11",
			},

			{ -- 选择星将
				x = SCREEN_WIDTH*0.5-310, y = SCREEN_HEIGHT*0.5 + 200, width = 100, height = 100,  
				guide = { guide_type = "click", x1= SCREEN_WIDTH*0.5-310, y1 = SCREEN_HEIGHT*0.5 + 200 },
				text_box = { text = "[255,255,255]点击星将头像让[=][255,0,0]八戒[=][255,255,255]上阵。[=]", icon_dir = "right",
							picX = SCREEN_WIDTH*0.5+100, picY = SCREEN_HEIGHT*0.5-132,
							 },
				audio = "new_12",
			},	
			{	-- 调整站位
				x = SCREEN_WIDTH*0.5+160, y = SCREEN_HEIGHT*0.5 , width = 540, height = 350, 
				guide = { guide_type = "slide1",  x1 = SCREEN_WIDTH*0.5+150, y1 = SCREEN_HEIGHT*0.5 - 70 },
				text_box = { text = "[255,255,255]将八戒拖动到[=][255,0,0]沙僧下面[=][255,255,255]一点，松手即可变换站位[=]", icon_dir = "left",
							picX = 140, picY = SCREEN_HEIGHT-310,
								},
				audio = "new_20",
			},
			{ -- 开始战斗
				x = SCREEN_WIDTH*0.5+340, y = 85 , width = 175, height = 65,  
				guide = { guide_type = "click", x1 = SCREEN_WIDTH*0.5+340, y1 = 85 },
				text_box = nil,
				audio = "new_13",
			},
			{	--	猪八戒可以放技能
				x = SCREEN_WIDTH -140, y = 65, width = 100, height = 114, 
				guide = {guide_type = "click",  x1 = SCREEN_WIDTH -140, y1 = 65,},
				text_box = { text = "[255,255,255]快用[=][255,0,0]怒气技能[=][255,255,255]将后排那几\n只高输出的火精灵秒掉先![=]", icon_dir = "left",
							picX = SCREEN_WIDTH*0.5-270, picY = SCREEN_HEIGHT*0.5-132,
							 },
				audio = "new_38",
			},
			{  --	猪八戒选择放技能
				x = SCREEN_WIDTH*0.5, y = SCREEN_HEIGHT*0.5+55, width = SCREEN_WIDTH, height = SCREEN_HEIGHT-110, 
				guide = {guide_type = "slide2",  x1 = SCREEN_WIDTH*0.5+100, y1 = 230,},
				text_box = { text = "[255,255,255]快把地上的红色框[=][255,0,0]拖到后\n排[=][255,255,255]的怪物身上吧[=]", icon_dir = "left",
							picX = 140, picY = SCREEN_HEIGHT-310,
							 },
				audio = "new_02",
			},

			{  --	猪八戒放出技能
				x = SCREEN_WIDTH*0.5, y = SCREEN_HEIGHT*0.5+55, width = SCREEN_WIDTH, height = SCREEN_HEIGHT-110, 
				guide = nil,
				text_box = { text = "[255,255,255]把红色框[=][255,0,0]拖到[=][255,255,255]怪物身上后就立刻松手哦![=]", icon_dir = "left",
							picX = 140, picY = SCREEN_HEIGHT-310,
							},
				audio = "new_03",
			},
			{	--	沙僧可以放技能
				x = SCREEN_WIDTH -245, y = 65, width = 100, height = 114, 
				guide = {guide_type = "click",  x1 = SCREEN_WIDTH -245, y1 = 65,},
				text_box = { text = "[255,255,255]沙僧的怒气技能可以[=][255,0,0]增加\n自己的防御力[=][255,255,255]。[=]", icon_dir = "left",
							picX = SCREEN_WIDTH*0.5-270, picY = SCREEN_HEIGHT*0.5-132,
							 },
				audio = "new_40",
			},
			{	--	唐僧可以放技能
				x = SCREEN_WIDTH -455, y = 65, width = 100, height = 114, 
				rect2 = {x = 0, y = 0, width = SCREEN_WIDTH - 405 , height = SCREEN_HEIGHT},
				guide = {guide_type = "click",  x1 = SCREEN_WIDTH -455, y1 = 65,},
				text_box = { text = "[255,0,0]双击[=][255,255,255]星将头像，可以快速\n放出大招哟![=]", icon_dir = "left",
							picX = SCREEN_WIDTH*0.5-270, picY = SCREEN_HEIGHT*0.5-132,
							 },
				audio = "new_43",
			},
			-- {  --	唐僧选择放技能
			-- 	x = SCREEN_WIDTH*0.5, y = SCREEN_HEIGHT*0.5+55, width = SCREEN_WIDTH, height = SCREEN_HEIGHT-110, 
			-- 	guide = {guide_type = "slide3",  x1 = SCREEN_WIDTH*0.5+50, y1 = 210,},
			-- 	text_box = { text = "[255,255,255]快把地上的红色框[=][255,0,0]拖到[=][255,255,255]怪\n物身上吧[=]", icon_dir = "left",
			-- 				picX = 140, picY = SCREEN_HEIGHT-310,
			-- 				 },
			-- 	audio = "new_02",
			-- },

			-- {  --	唐僧放出技能
			-- 	x = SCREEN_WIDTH*0.5, y = SCREEN_HEIGHT*0.5+55, width = SCREEN_WIDTH, height = SCREEN_HEIGHT-110, 
			-- 	guide = nil,
			-- 	text_box = { text = "[255,255,255]把红色框[=][255,0,0]拖到[=][255,255,255]怪物身上后就立刻松手哦![=]", icon_dir = "left",
			-- 				picX = 140, picY = SCREEN_HEIGHT-310,
			-- 				},
			-- 	audio = "new_03",
			-- },
			{	--	孙悟空可以放技能
				x = SCREEN_WIDTH -350, y = 65, width = 100, height = 114, 
				guide = {guide_type = "click",  x1 = SCREEN_WIDTH -350, y1 = 65,},
				text_box = { text = "[255,0,0]开大[=][255,255,255]吧，猴哥！[=]", icon_dir = "left",
							picX = SCREEN_WIDTH*0.5-270, picY = SCREEN_HEIGHT*0.5-132,
							 },
				audio = "new_42",
			},
			
			{ --下一集
				x = SCREEN_WIDTH*0.8, y = SCREEN_HEIGHT*0.15, width = 165, height = 65,  
				guide = { guide_type = "click", x1 = SCREEN_WIDTH*0.8, y1 = SCREEN_HEIGHT*0.15 },
				text_box = { text = "[255,255,255]点击[=][255,0,0]下一集[=][255,255,255]，快速开始下一场战斗！[=]", icon_dir = "left",
							picX = SCREEN_WIDTH*0.5, picY = SCREEN_HEIGHT*0.5-230,
							},
			},	
		}
	},	

	-- 3
	{	
		desc = "强化猪八戒战斗",
		pages = { ["MainLayer"] = true, ["MapInstanceLayer"] = true, ["BattleFormLayer"] = true ,["BattleLayer"] = true, ["MapBattleWinLayer"] = true},
		steps = {
			{-- 副本入口
				x = SCREEN_WIDTH-110, y =  70, width = 140, height = 130,
				guide = {guide_type = "click",  x1 = SCREEN_WIDTH-110, y1 = 70},
				text_box = { text = "[255,255,255]进入冒险剧场，让我们去\n看神仙们[=][255,0,0]打怪升级[=][255,255,255]吧[=]", icon_dir = "left",
				 			 picX = SCREEN_WIDTH*0.5-266, picY = SCREEN_HEIGHT*0.5-132,
							},
				audio = "new_10",
			},

			{ -- 开始副本
				x = 0.5*SCREEN_WIDTH, y =  SCREEN_HEIGHT*0.5, width = 225, height = 225,   
				guide = {guide_type = "click",  x1 = 0.5*SCREEN_WIDTH, y1 = SCREEN_HEIGHT*0.5},
				text_box = { text = "[255,255,255]点击“[=][255,0,0]播放[=][255,255,255]”，看好戏还能得装备碎片哟！[=]", icon_dir = "right",
							 picX = SCREEN_WIDTH-140, picY = 30,
							},
				
				-- audio = "new_11",
			},
		
			{ -- 开始战斗
				x = SCREEN_WIDTH*0.5+340, y = 85 , width = 175, height = 65,  
				guide = { guide_type = "click", x1 = SCREEN_WIDTH*0.5+340, y1 = 85 },
				text_box = nil,
				audio = "new_13",
			},
			{	--	猪八戒可以放技能
				x = SCREEN_WIDTH -140, y = 65, width = 100, height = 114, 
				guide = {guide_type = "click",  x1 = SCREEN_WIDTH -140, y1 = 65,},
				text_box = { text = "[255,255,255]再来一次，使用[=][255,0,0]怒气技能\n[=][255,255,255]将后排的火精灵先秒掉![=]", icon_dir = "left",
							picX = SCREEN_WIDTH*0.5-270, picY = SCREEN_HEIGHT*0.5-132,
							},
				audio = "new_38",
			},
			{  --	猪八戒选择放技能
				x = SCREEN_WIDTH*0.5, y = SCREEN_HEIGHT*0.5+55, width = SCREEN_WIDTH, height = SCREEN_HEIGHT-110, 
				guide = {guide_type = "slide2",  x1 = SCREEN_WIDTH*0.5+80, y1 = 250,},
				text_box = { text = "[255,255,255]快把地上的红色框[=][255,0,0]拖到后\n排[=][255,255,255]的怪物身上吧[=]", icon_dir = "left",
							picX = 140, picY = SCREEN_HEIGHT-310,
							 },
				audio = "new_02",
			},

			{  --	猪八戒放出技能
				x = SCREEN_WIDTH*0.5, y = SCREEN_HEIGHT*0.5+55, width = SCREEN_WIDTH, height = SCREEN_HEIGHT-110, 
				guide = nil,
				text_box = { text = "[255,255,255]把红色框[=][255,0,0]拖到[=][255,255,255]怪物身上后就立刻松手哦![=]", icon_dir = "left",
							picX = 140, picY = SCREEN_HEIGHT-310,
							 },
				audio = "new_03",
			},
			{ --下一集
				x = SCREEN_WIDTH*0.8, y = SCREEN_HEIGHT*0.15, width = 165, height = 65,  
				guide = { guide_type = "click", x1 = SCREEN_WIDTH*0.8, y1 = SCREEN_HEIGHT*0.15 },
				text_box = { text = "[255,255,255]点击[=][255,0,0]下一集[=][255,255,255]，快速开始下一场战斗！[=]", icon_dir = "left",
							picX = SCREEN_WIDTH*0.5, picY = SCREEN_HEIGHT*0.5-230,
							},
			},	
		}
	},

	-- 4
	{	
		desc = "龙女上阵战斗",
		pages = { ["MainLayer"] = true, ["MapInstanceLayer"] = true, ["BattleFormLayer"] = true ,["BattleLayer"] = true, ["MapBattleWinLayer"] = true},
		steps = {
			{-- 副本入口
				x = SCREEN_WIDTH-110, y =  70, width = 140, height = 130,
				guide = {guide_type = "click",  x1 = SCREEN_WIDTH-110, y1 = 70},
				text_box = { text = "[255,255,255]进入冒险剧场，让我们去\n看神仙们[=][255,0,0]打怪升级[=][255,255,255]吧[=]", icon_dir = "left",
				 			 picX = SCREEN_WIDTH*0.5-266, picY = SCREEN_HEIGHT*0.5-132,
							},
				audio = "new_10",
			},

			{ -- 开始副本
				x = 0.5*SCREEN_WIDTH, y =  SCREEN_HEIGHT*0.5, width = 225, height = 225,   
				guide = {guide_type = "click",  x1 = 0.5*SCREEN_WIDTH, y1 = SCREEN_HEIGHT*0.5},
				text_box = { text = "[255,255,255]点击“[=][255,0,0]播放[=][255,255,255]”，看好戏还能得装备碎片哟！[=]", icon_dir = "right",
							 picX = SCREEN_WIDTH-140, picY = 30,
							},
				
				-- audio = "new_11",
			},

			{ -- 选择星将
				x = SCREEN_WIDTH*0.5-310, y = SCREEN_HEIGHT*0.5 + 200, width = 100, height = 100,  
				guide = { guide_type = "click", x1= SCREEN_WIDTH*0.5-310, y1 = SCREEN_HEIGHT*0.5 + 200 },
				text_box = { text = "[255,255,255]点击星将头像让[=][255,0,0]龙女[=][255,255,255]上阵。[=]", icon_dir = "right",
							picX = SCREEN_WIDTH*0.5+100, picY = SCREEN_HEIGHT*0.5-132,
							 },
				audio = "new_35",
			},		
			{ -- 开始战斗
				x = SCREEN_WIDTH*0.5+340, y = 85 , width = 175, height = 65,  
				guide = { guide_type = "click", x1 = SCREEN_WIDTH*0.5+340, y1 = 85 },
				text_box = nil,
				audio = "new_13",
			},
			{	--	自动战斗指引
				x = 90, y = SCREEN_HEIGHT - 45, width = 120, height = 70, 
				guide = {guide_type = "click",  x1 = 90, y1 = SCREEN_HEIGHT - 50,},
				text_box = { text = "[255,255,255]切换至[=][255,0,0]自动战斗[=][255,255,255]模式，星\n将会自动施放怒气技能[=]", icon_dir = "right",
							picX = SCREEN_WIDTH*0.5+100, picY = SCREEN_HEIGHT*0.5-32,
							},
				
				audio = "new_36",
			},
			{ --返回地图
				x = SCREEN_WIDTH*0.8, y = SCREEN_HEIGHT*0.3, width = 165, height = 65,  
				guide = { guide_type = "click", x1 = SCREEN_WIDTH*0.8, y1 = SCREEN_HEIGHT*0.3 },
				text_box =  { text = "[255,255,255]新功能开启了，快去试试吧[=]", icon_dir = "left",
							picX = SCREEN_WIDTH*0.5, picY = SCREEN_HEIGHT*0.5-50,
							},
				
			},	

			{ -- 关闭副本
				x = SCREEN_WIDTH*0.95, y = SCREEN_HEIGHT*0.93, width = 70, height = 70,   
				guide = { guide_type = "click", x1 = SCREEN_WIDTH*0.95, y1 = SCREEN_HEIGHT*0.93 },
				text_box = { text = "[255，255，255]点击关闭键，返回主界面。[=]", icon_dir = "left",
							picX = SCREEN_WIDTH*0.5-100, picY = SCREEN_HEIGHT*0.5-30,
							},
				audio = "new_15",
			},	
		}
	},

	-- 5
	{	desc = "开星将灵石",
		pages = { ["MainLayer"] = true, ["GambleLayer"] = true,},
		steps = {
			{ -- 灵石入口
				x = SCREEN_WIDTH*0.15+26, y = SCREEN_HEIGHT-105, width = 65, height = 65,   
				guide = {guide_type = "click",  x1 = SCREEN_WIDTH*0.15+26, y1 = SCREEN_HEIGHT-105 },
				text_box = { text = "[255,255,255]亲，“开灵石”可以获得\n更好的[=][255,0,0]星将[=][255,255,255]和[=][255,0,0]装备[=][255,255,255]哟！[=]", icon_dir = "left",
							picX = SCREEN_WIDTH*0.5-100, picY = SCREEN_HEIGHT-310,
							},
				
				audio = "new_07",
			},

			{ -- 选择
				x = 0.5*SCREEN_WIDTH-221, y =  0.5*SCREEN_HEIGHT-160, width = 442, height = 265, 
				guide = {guide_type = "click",  x1 = 0.5*SCREEN_WIDTH-221, y1 =  0.5*SCREEN_HEIGHT-180 },
				text_box = { text = "[255,0,0]星将灵石[=][255,255,255]里有很多很厉害\n的星将哟！[=]", icon_dir = "left",
							picX = 140, picY = SCREEN_HEIGHT-310,
							},
				audio = "new_16",
			},

			{ -- 抽一次
				x = 0.5*SCREEN_WIDTH-320, y =  0.5*SCREEN_HEIGHT-238, width = 140, height = 65,  
				guide = {guide_type = "click",  x1 = 0.5*SCREEN_WIDTH-320, y1 = 0.5*SCREEN_HEIGHT-240 },
				text_box = nil,
				audio = "new_09",
			},

			{ -- 选择装备灵石快捷入口
				x = 0.5*SCREEN_WIDTH+321, y =  0.5*SCREEN_HEIGHT-210, width = 280, height = 170, 
				guide = {guide_type = "click",  x1 = 0.5*SCREEN_WIDTH+320, y1 =  0.5*SCREEN_HEIGHT-230 },
				text_box = { text = "[255,255,255]想要[=][255,0,0]更好的装备[=][255,255,255]就来开装\n备灵石吧！[=]", icon_dir = "left",
							picX = SCREEN_WIDTH*0.5-100, picY = SCREEN_HEIGHT*0.5-132,
							},
				audio = "new_22",
			},
	
		}
	},	

	-- 6
	{	desc = "开装备灵石",
		pages = { ["MainLayer"] = true, ["GambleLayer"] = true,},
		steps = {
			{ -- 灵石入口
				x = SCREEN_WIDTH*0.15+26, y = SCREEN_HEIGHT-105, width = 65, height = 65,   
				guide = {guide_type = "click",  x1 = SCREEN_WIDTH*0.15+26, y1 = SCREEN_HEIGHT-105 },
				text_box = { text = "[255,255,255]亲，“开灵石”可以获得\n更好的[=][255,0,0]星将[=][255,255,255]和[=][255,0,0]装备[=][255,255,255]哟！[=]", icon_dir = "left",
							picX = SCREEN_WIDTH*0.5-100, picY = SCREEN_HEIGHT-310,
							},
				audio = "new_07",
			},

			{ -- 选择
				x = 0.5*SCREEN_WIDTH+221, y =  0.5*SCREEN_HEIGHT-160, width = 442, height = 265, 
				guide = {guide_type = "click",  x1 = 0.5*SCREEN_WIDTH+221, y1 =  0.5*SCREEN_HEIGHT-180 },
				text_box = { text = "[255,255,255]想要[=][255,0,0]更好的装备[=][255,255,255]就来开装\n备灵石吧！[=]", icon_dir = "left",
							picX = SCREEN_WIDTH*0.5-100, picY = SCREEN_HEIGHT-310,
							},
				audio = "new_22",
			},

			{ -- 抽一次
				x = 0.5*SCREEN_WIDTH-320, y =  0.5*SCREEN_HEIGHT-238, width = 140, height = 65,  
				guide = {guide_type = "click",  x1 = 0.5*SCREEN_WIDTH-320, y1 = 0.5*SCREEN_HEIGHT-240 },
				text_box = nil,
				audio = "new_23",
			},

			{ -- 关闭
				x = 0.5*SCREEN_WIDTH+442, y =  0.5*SCREEN_HEIGHT+276, width = 70, height = 70,
				guide = { guide_type = "click",  x1 = 0.5*SCREEN_WIDTH+442, y1 = 0.5*SCREEN_HEIGHT+276  },
				text_box = nil,
			},				
		}
	},	

	-- 7
	{	desc = "猪八戒穿武器",
		pages = { ["MainLayer"] = true, ["AllHeroLayer"] = true, ["NewHeroLayer"] = true },
		steps = {
			{ -- 装备入口
			x = SCREEN_WIDTH-44, y = SCREEN_HEIGHT - 50, width = 75, height = 65, 
			guide = {guide_type = "click",   x1 = SCREEN_WIDTH-44, y1 = SCREEN_HEIGHT - 50 },
				text_box = { text = "[255,255,255]点击打开星将列表界面，\n给星将[=][255,0,0]穿上装备[=]", icon_dir = "right",
							picX = SCREEN_WIDTH-140, picY = 90,
							 },
				audio = "new_24",

			},

			{ -- 选择八戒
				x = SCREEN_WIDTH*0.5-200, y =  SCREEN_HEIGHT*0.5-55, width = 380, height = 125, 
				guide = {guide_type = "click",   x1 = SCREEN_WIDTH*0.5-190, y1 =  SCREEN_HEIGHT*0.5- 55 },
				text_box = nil,
			},	

			{ -- 点击武器插槽
				x = SCREEN_WIDTH*0.5-395, y =  SCREEN_HEIGHT*0.5+212, width = 105, height = 105,
				guide = {guide_type = "click",    x1 = SCREEN_WIDTH*0.5-395, y1 =  SCREEN_HEIGHT*0.5+212 },
				text_box = { text = "[255,255,255]点击[=][255,0,0]武器栏[=][255,255,255]，可以跳转到武器列表界面。[=]", icon_dir = "right",
							picX = SCREEN_WIDTH-140, picY = 30,
							 },
				audio = "new_25",
			},	

			{ -- 选择武器
				x = SCREEN_WIDTH*0.5+133, y =  SCREEN_HEIGHT*0.5+110, width = 90, height = 85, 
				guide = {guide_type = "click",  x1 = SCREEN_WIDTH*0.5+133, y1 =  SCREEN_HEIGHT*0.5+105 },
				text_box = { text = "[255,255,255]给猪猪换上武器吧，这可\n是他的[=][255,0,0]专属武器[=][255,255,255]噢！[=]", icon_dir = "right",
							picX = SCREEN_WIDTH-140, picY = 30,
							 },
				audio = "new_26",
			},	

			{ -- 装备武器
				x = SCREEN_WIDTH*0.5, y =  SCREEN_HEIGHT*0.5-60, width = 135, height = 75,
				guide = {guide_type = "click", x1 = SCREEN_WIDTH*0.5, y1 =  SCREEN_HEIGHT*0.5-60 },
				text_box = nil,
			},

			-- { -- 展示换装
			-- 	x = SCREEN_WIDTH*0.5, y =  SCREEN_HEIGHT*0.5, width = SCREEN_WIDTH, height = SCREEN_HEIGHT,
			-- 	guide = nil,
			-- 	text_box = { text = "[255,255,255]快看，换了把武器的猪猪是不是更帅啦！[=]", icon_dir = "right" },
			-- 	audio = "new_27",
			-- },
		}
	},	

	-- 8
	{	desc = "猪八戒穿装备",
		pages = { ["MainLayer"] = true, ["AllHeroLayer"] = true, ["NewHeroLayer"] = true },
		steps = {
			{ -- 装备入口
			x = SCREEN_WIDTH-44, y = SCREEN_HEIGHT - 50, width = 75, height = 65, 
			guide = {guide_type = "click",   x1 = SCREEN_WIDTH-44, y1 = SCREEN_HEIGHT - 50 },
				text_box = { text = "[255,255,255]点击打开[=][255,0,0]星将列表[=][255,255,255]界面。[=]", icon_dir = "right",
							picX = SCREEN_WIDTH-140, picY = 90,
							 },
				audio = "new_24",
			},

			{ -- 选择八戒
				x = SCREEN_WIDTH*0.5-200, y =  SCREEN_HEIGHT*0.5+65, width = 380, height = 125, 
				guide = {guide_type = "click",   x1 = SCREEN_WIDTH*0.5-200, y1 =  SCREEN_HEIGHT*0.5+55 },
				text_box = nil,
			},	

			{ -- 点击装备插槽
				x = SCREEN_WIDTH*0.5-20, y =  SCREEN_HEIGHT*0.5+100, width = 105, height = 105,
				guide = {guide_type = "click",    x1 = SCREEN_WIDTH*0.5-20, y1 =  SCREEN_HEIGHT*0.5+100 },
				text_box = { text = "[255,255,255]点击[=][255,0,0]衣服栏[=][255,255,255]，可以跳转到衣服列表界面。[=]", icon_dir = "right",
							picX = SCREEN_WIDTH-140, picY = 30,
							 },
				audio = "new_25",
			},	

			{ -- 选择装备
				x = SCREEN_WIDTH*0.5+132, y =  SCREEN_HEIGHT*0.5-150, width = 90, height = 90, 
				guide = {guide_type = "click",  x1 = SCREEN_WIDTH*0.5+135, y1 =  SCREEN_HEIGHT*0.5-155 },
				text_box = { text = "[255,255,255]再给八戒穿上一件衣服吧。[=]", icon_dir = "right",
							picX = SCREEN_WIDTH-120, picY = 170,
							 },
				audio = "new_37",
			},	

			{ -- 装备衣服
				x = SCREEN_WIDTH*0.5, y =  SCREEN_HEIGHT*0.5-60, width = 135, height = 75,
				guide = {guide_type = "click", x1 = SCREEN_WIDTH*0.5, y1 =  SCREEN_HEIGHT*0.5-60 },
				text_box = nil,
			},

			{ -- 展示换装
				x = SCREEN_WIDTH*0.5, y =  SCREEN_HEIGHT*0.5, width = SCREEN_WIDTH, height = SCREEN_HEIGHT,
				guide = nil,
				text_box = { text = "[255,255,255]快看，换装后的猪猪是不是更帅啦！[=]", icon_dir = "right",
							picX = SCREEN_WIDTH-140, picY = 30,
							 },
				audio = "new_27",
			},

			{ -- 关闭星将界面
				x = SCREEN_WIDTH*0.5+449, y =  SCREEN_HEIGHT*0.5+284, width = 70, height = 70,
				guide = {guide_type = "click",    x1 = SCREEN_WIDTH*0.5+449, y1 =  SCREEN_HEIGHT*0.5+284 },
				text_box = { text = "[255,255,255]你的星将更强大了，快去继续欺负小妖怪们吧！[=]", icon_dir = "left",
							picX = SCREEN_WIDTH*0.5-100, picY = SCREEN_HEIGHT-310,
							},
				audio = "new_33",
			},

			{ -- 关闭星将列表界面
				x = SCREEN_WIDTH*0.5+436, y =  SCREEN_HEIGHT*0.47+278, width = 70, height = 70,
				guide = {guide_type = "click",    x1 = SCREEN_WIDTH*0.5+436, y1 =  SCREEN_HEIGHT*0.47+278 },
				text_box = nil,
			},	
		}
	},

	-- 9

	{	desc = "龙王战斗",
		pages = { ["MainLayer"] = true, ["MapInstanceLayer"] = true, ["BattleFormLayer"] = true , ["MapBattleWinLayer"] = true},
		steps = {
			{-- 副本入口
				x = SCREEN_WIDTH-110, y =  70, width = 140, height = 130,
				guide = {guide_type = "click",  x1 = SCREEN_WIDTH-110, y1 = 70},
				text_box = { text = "[255,255,255]进入冒险剧场，让我们去\n看神仙们[=][255,0,0]打怪升级[=][255,255,255]吧[=]", icon_dir = "left",
							picX = SCREEN_WIDTH*0.5 - 266, picY = SCREEN_HEIGHT*0.5-132,
							},
				audio = "new_10",
			},

			{ -- 开始副本
				x = 0.5*SCREEN_WIDTH, y =  SCREEN_HEIGHT*0.5, width = 225, height = 225,   
				guide = {guide_type = "click",  x1 = 0.5*SCREEN_WIDTH, y1 = SCREEN_HEIGHT*0.5},
				text_box = { text = "[255,255,255]剧场掉落的“[=][255,0,0]升星丹[=][255,255,255]”是星将升星的重要道具哟！[=]", icon_dir = "right",
							picX = SCREEN_WIDTH-140, picY = 30,
							},
				audio = "new_11",
			},

			{ -- 选择星将
				x = SCREEN_WIDTH*0.5-190, y = SCREEN_HEIGHT*0.5 + 200, width = 100, height = 100, 
				guide = { guide_type = "click", x1= SCREEN_WIDTH*0.5-190, y1 = SCREEN_HEIGHT*0.5 + 200  },
				text_box = { text = "[255,255,255]点击星将头像让[=][255,0,0]龙王[=][255,255,255]上阵。[=]", icon_dir = "right",
							picX = SCREEN_WIDTH*0.5+100, picY = SCREEN_HEIGHT*0.5-200
							},
				audio = "new_19",
			},
			-- {	-- 调整站位
			-- 	x = SCREEN_WIDTH*0.5+160, y = SCREEN_HEIGHT*0.5 , width = 540, height = 350, 
			-- 	guide = { guide_type = "slide1",  x1 = SCREEN_WIDTH*0.5+150, y1 = SCREEN_HEIGHT*0.5 + 70 },
			-- 	text_box = { text = "[255,255,255]将龙王拖动到[=][255,0,0]八戒上面[=][255,255,255]一点，松手即可变换站位[=]", icon_dir = "left",
			-- 				picX = 140, picY = SCREEN_HEIGHT-310,
			-- 					},
			-- 	audio = "new_20",
			-- },
			{ -- 开始战斗
				x = SCREEN_WIDTH*0.5+340, y = 85 , width = 175, height = 65,  
				guide = { guide_type = "click", x1 = SCREEN_WIDTH*0.5+340, y1 = 85 },
				text_box = nil,
				audio = "new_13",
			},		
		}
	},	
}


return GuideStepTable