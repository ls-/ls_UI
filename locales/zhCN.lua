﻿-- Contributors: aenerv7@GitHub

local _, ns = ...
local E, L = ns.E, ns.L

-- Lua
local _G = getfenv(0)
local m_modf = _G.math.modf
local s_format = _G.string.format

--[[ luacheck: globals
	GetLocale
]]

if GetLocale() ~= "zhCN" then return end

-- Mine
do
	local BreakUpLargeNumbers = _G.BreakUpLargeNumbers
	local SECOND_NUMBER_CAP_NO_SPACE = _G.SECOND_NUMBER_CAP_NO_SPACE
	local FIRST_NUMBER_CAP_NO_SPACE = _G.FIRST_NUMBER_CAP_NO_SPACE

	function E:NumberFormat(v, mod)
		if v >= 1E8 then
			local i, f = m_modf(v / 1E8)

			if mod and mod > 0 then
				return s_format("%s.%d"..SECOND_NUMBER_CAP_NO_SPACE, BreakUpLargeNumbers(i), f * 10 ^ mod)
			else
				return s_format("%s"..SECOND_NUMBER_CAP_NO_SPACE, BreakUpLargeNumbers(i))
			end
		elseif v >= 1E4 then
			local i, f = m_modf(v / 1E4)

			if mod and mod > 0 then
				return s_format("%s.%d"..FIRST_NUMBER_CAP_NO_SPACE, BreakUpLargeNumbers(i), f * 10 ^ mod)
			else
				return s_format("%s"..FIRST_NUMBER_CAP_NO_SPACE, BreakUpLargeNumbers(i))
			end
		elseif v >= 0 then
			return BreakUpLargeNumbers(v)
		else
			return 0
		end
	end
end

L["ACTION_BARS"] = "动作条"
L["ADDITIONAL_BAR"] = "额外菜单栏"
L["ADVENTURE_JOURNAL_DESC"] = "显示团队副本锁定信息"
L["ALT_POWER_BAR"] = "第二资源条"
L["ALT_POWER_FORMAT_DESC"] = [=[通过格式化字符串来修改文本显示，留空表示禁用此功能

格式化文本
- |cffffd200[ls:altpower:cur]|r - 当前值
- |cffffd200[ls:altpower:max]|r - 最大值
- |cffffd200[ls:altpower:perc]|r - 百分比
- |cffffd200[ls:altpower:cur-max]|r - 当前值和最大值
- |cffffd200[ls:altpower:cur-color-max]|r - 当前值和着色后的最大值
- |cffffd200[ls:altpower:cur-perc]|r - 当前值和百分比
- |cffffd200[ls:altpower:cur-color-perc]|r - 当前值和着色后的百分比
- |cffffd200[ls:color:altpower]|r - 着色

如果当前值和最大值一样，那么只会显示最大值

使用 |cffffd200||r|r 来表示着色格式化文本结束
使用 |cffffd200[nl]|r 来换行]=]
L["ALTERNATIVE_POWER"] = "第二资源"
L["ALWAYS_SHOW"] = "总是显示"
L["ANCHOR"] = "锚点"
L["ANCHOR_TO_CURSOR"] = "依附于鼠标"
L["ARTIFACT_LEVEL_TOOLTIP"] = "神器等级：|cffffffff%s|r"
L["ARTIFACT_POWER"] = "神器能量"
L["ASCENDING"] = "升序"
L["AURA_TRACKER"] = "光环追踪器"
L["AURAS"] = "光环"
L["AUTO"] = "自动"
L["BAG_SLOTS"] = "背包栏位"
L["BAR"] = "菜单栏"
L["BAR_1"] = "动作条 1"
L["BAR_2"] = "动作条 2"
L["BAR_3"] = "动作条 3"
L["BAR_4"] = "动作条 4"
L["BAR_5"] = "动作条 5"
L["BAR_COLOR"] = "生命条颜色"
L["BAR_TEXT"] = "动作条文字"
L["BLIZZARD"] = "暴雪默认 UI"
L["BONUS_HONOR_TOOLTIP"] = "奖励荣誉：|cffffffff%s|r"
L["BONUS_XP_TOOLTIP"] = "奖励经验：|cffffffff%s|r"
L["BORDER"] = "边框"
L["BORDER_COLOR"] = "边框颜色"
L["BOSS"] = "首领"
L["BOSS_BUFFS"] = "首领增益效果"
L["BOSS_BUFFS_DESC"] = "显示首领施放的增益效果"
L["BOSS_DEBUFFS"] = "首领减益效果"
L["BOSS_DEBUFFS_DESC"] = "显示首领施放的减益效果"
L["BOSS_FRAMES"] = "首领框架"
L["BOTTOM"] = "底部"
L["BOTTOM_INSET_SIZE"] = "底部插页尺寸"
L["BOTTOM_INSET_SIZE_DESC"] = "被资源条使用"
L["BUFFS"] = "增益效果"
L["BUFFS_AND_DEBUFFS"] = "增益和减益"
L["BUTTON_GRID"] = "按钮边框"
L["CALENDAR"] = "日历"
L["CAST_ON_KEY_DOWN"] = "按下时施法"
L["CASTABLE_BUFFS"] = "可施放增益效果"
L["CASTABLE_BUFFS_DESC"] = "显示你施放的增益效果"
L["CASTABLE_BUFFS_PERMA"] = "可施放的永久增益效果"
L["CASTABLE_BUFFS_PERMA_DESC"] = "显示你施放的永久增益效果"
L["CASTABLE_DEBUFFS"] = "可施放的减益效果"
L["CASTABLE_DEBUFFS_DESC"] = "显示你施放的减益效果"
L["CASTABLE_DEBUFFS_PERMA"] = "可施放的永久减益效果"
L["CASTABLE_DEBUFFS_PERMA_DESC"] = "显示你施放的永久减益效果"
L["CASTBAR"] = "施法条"
L["CHARACTER_BUTTON_DESC"] = "显示装备耐久度信息"
L["CLASS_POWER"] = "职业能量"
L["CLASSIC"] = "经典"
L["CLOCK"] = "时钟"
L["COLOR_BY_SPEC"] = "按照专精着色"
L["COLORS"] = "着色"
L["COMMAND_BAR"] = "命令条"
L["COOLDOWN"] = "CD"
L["COOLDOWN_TEXT"] = "CD 文本"
L["COPY_FROM"] = "复制自"
L["COPY_FROM_DESC"] = "选择一份配置文件复制"
L["COST_PREDICTION"] = "花费预测"
L["COST_PREDICTION_DESC"] = "显示法术将要花费的资源，对瞬发法术不生效"
L["COUNT_TEXT"] = "数量文字"
L["DAILY_QUEST_RESET_TIME_TOOLTIP"] = "日常任务重置时间：|cffffffff%s|r"
L["DAMAGE_ABSORB_FORMAT_DESC"] = [=[通过格式化字符串来修改文本显示，留空表示禁用此功能

格式化文本
- |cffffd200[ls:absorb:damage]|r - 当前值
- |cffffd200[ls:color:absorb-damage]|r - 着色

使用 |cffffd200||r|r 来表示着色格式化文本结束
使用 |cffffd200[nl]|r 来换行]=]
L["DAMAGE_ABSORB_TEXT"] = "伤害吸收文字"
L["DAYS"] = "天"
L["DEAD"] = "死亡"
L["DEBUFFS"] = "减益效果"
L["DESATURATION"] = "褪色"
L["DESCENDING"] = "降序"
L["DETACH_FROM_FRAME"] = "从框架脱离"
L["DIFFICULTY_FLAG"] = "难度标记"
L["DIGSITE_BAR"] = "考古进度条"
L["DISABLE_MOUSE"] = "禁用鼠标"
L["DISABLE_MOUSE_DESC"] = "忽略鼠标事件"
L["DISPELLABLE_BUFFS"] = "可驱散的增益效果"
L["DISPELLABLE_BUFFS_DESC"] = "显示目标身上你可以偷取或是驱散的增益效果"
L["DISPELLABLE_DEBUFF_ICONS"] = "可驱散的减益效果图标"
L["DISPELLABLE_DEBUFFS"] = "可驱散的减益效果"
L["DISPELLABLE_DEBUFFS_DESC"] = "显示目标身上你可以驱散的减益效果"
L["DOWN"] = "下"
L["DRAG_KEY"] = "拖动键"
L["DRAW_COOLDOWN_BLING"] = "显示冷却完成闪烁"
L["DRAW_COOLDOWN_BLING_DESC"] = "在冷却完成时显示闪烁动画"
L["DUNGEONS_BUTTON_DESC"] = "显示随机稀缺职业奖励信息"
L["DURABILITY_FRAME"] = "耐久度框架"
L["ELITE"] = "精英"
L["ENEMY_UNITS"] = "敌对单位"
L["ENHANCED_TOOLTIPS"] = "鼠标提示增强"
L["ENTER_SPELL_ID"] = "输入法术 ID"
L["EXP_THRESHOLD"] = "小数显示阈值"
L["EXP_THRESHOLD_DESC"] = "小于这个阈值的秒数将以小数点后两位的小数显示"
L["EXPERIENCE"] = "经验值"
L["EXPIRATION"] = "即将结束"
L["EXTRA_ACTION_BUTTON"] = "额外动作按钮"
L["FADE_IN_DELAY"] = "延迟淡入"
L["FADE_IN_DURATION"] = "淡入时长"
L["FADE_OUT_DELAY"] = "延迟淡出"
L["FADE_OUT_DURATION"] = "淡出时长"
L["FADING"] = "渐隐"
L["FCF"] = "浮动战斗反馈"
L["FILTER_SETTINGS"] = "过滤器设置"
L["FILTERS"] = "过滤器"
L["FLAG"] = "字体样式"
L["FLYOUT_DIR"] = "弹出方向"
L["FOCUS_FRAME"] = "焦点目标框架"
L["FOCUS_TOF"] = "焦点目标 & 焦点目标的目标"
L["FONT"] = "字体"
L["FORMAT"] = "格式"
L["FRAME"] = "框架"
L["FREE_BAG_SLOTS_TOOLTIP"] = "剩余背包空间：|cffffffff%s|r"
L["FRIENDLY_UNITS"] = "友好单位"
L["GM_FRAME"] = "申请状态框架"
L["GOLD"] = "金币"
L["GROWTH_DIR"] = "增长方向"
L["HEAL_ABSORB_FORMAT_DESC"] = [=[通过格式化字符串来修改文本显示，留空表示禁用此功能

格式化文本
- |cffffd200[ls:absorb:heal]|r - 当前值
- |cffffd200[ls:color:absorb-heal]|r - 着色

使用 |cffffd200||r|r 来表示着色格式化文本结束
使用 |cffffd200[nl]|r 来换行]=]
L["HEAL_ABSORB_TEXT"] = "治疗吸收文本"
L["HEAL_PREDICTION"] = "治疗预测"
L["HEALTH"] = "生命值"
L["HEALTH_FORMAT_DESC"] = [=[通过格式化字符串来修改文本显示，留空表示禁用此功能

格式化文本
- |cffffd200[ls:health:cur]|r - 当前值
- |cffffd200[ls:health:perc]|r - 百分比
- |cffffd200[ls:health:cur-perc]|r - 当前值和百分比
- |cffffd200[ls:health:deficit]|r - 剩余值

如果当前值和最大值一样，那么只会显示最大值

使用 |cffffd200[nl]|r 来换行]=]
L["HEALTH_TEXT"] = "生命值文本"
L["HEIGHT"] = "高度"
L["HONOR"] = "荣誉"
L["HONOR_LEVEL_TOOLTIP"] = "荣誉等级：|cffffffff%d|r"
L["HORIZ_GROWTH_DIR"] = "水平增长"
L["HOURS"] = "小时"
L["ICON"] = "图标"
L["INDEX"] = "索引"
L["INSPECT_INFO"] = "玩家信息"
L["INSPECT_INFO_DESC"] = "显示当前单位的专精和装备等级，这些数据可能不是马上就能显示"
L["INVENTORY_BUTTON"] = "背包"
L["INVENTORY_BUTTON_DESC"] = "显示货币信息"
L["INVENTORY_BUTTON_RCLICK_TOOLTIP"] = "|cffffffff右键点击|r 来显示背包栏位"
L["ITEM_COUNT"] = "物品计数"
L["ITEM_COUNT_DESC"] = "显示银行和背包中该物品的总数"
L["KEYBIND_TEXT"] = "快捷键绑定文字"
L["LATENCY"] = "延迟"
L["LATENCY_HOME"] = "本地"
L["LATENCY_WORLD"] = "世界"
L["LATER"] = "稍后"
L["LEFT"] = "左"
L["LEFT_DOWN"] = "左下"
L["LEFT_UP"] = "左上"
L["LEVEL_TOOLTIP"] = "等级：|cffffffff%d|r"
L["LOCK"] = "锁定"
L["LOCK_BUTTONS"] = "锁定按钮"
L["LOCK_BUTTONS_DESC"] = "防止图标被拖离动作条"
L["LOOT_ALL"] = "全部拾取"
L["M_SS_THRESHOLD"] = "M:SS 显示阈值"
L["M_SS_THRESHOLD_DESC"] = "低于此秒数的时间将会以 4:01 的格式显示，设置成 0 表示禁用此格式"
L["MACRO_TEXT"] = "宏文字"
L["MAIN_BAR"] = "主菜单"
L["MAINMENU_BUTTON_DESC"] = "显示性能信息"
L["MAINMENU_BUTTON_HOLD_TOOLTIP"] = "|cffffffff按住 Shift|r 来显示内存占用"
L["MAX_ALPHA"] = "最大透明度"
L["MEMORY"] = "内存"
L["MICRO_BUTTONS"] = "微型菜单按钮"
L["MIN_ALPHA"] = "最小透明度"
L["MINUTES"] = "分"
L["MIRROR_TIMER"] = "镜像计时器"
L["MIRROR_TIMER_DESC"] = "呼吸和疲劳以及其他进度条"
L["MODE"] = "模式"
L["MOUNT_AURAS"] = "坐骑光环"
L["MOUNT_AURAS_DESC"] = "显示坐骑光环"
L["MOUSEOVER_SHOW"] = "鼠标经过时显示"
L["MOVER_BUTTONS_DESC"] = "|cffffffff点击|r 激活按钮"
L["MOVER_CYCLE_DESC"] = "按 |cffffffffAlt|r 键切换位于鼠标位置的不同组件"
L["MOVER_RESET_DESC"] = "|cffffffffShift 加点击|r 来重置位置"
L["NAME"] = "名称"
L["NAME_FORMAT_DESC"] = [=[通过格式化字符串来修改文本显示，留空表示禁用此功能

格式化文本
- |cffffd200[ls:name]|r - 名称
- |cffffd200[ls:name:5]|r - 只显示名称的前五个字
- |cffffd200[ls:name:10]|r - 只显示名称的前十个字
- |cffffd200[ls:name:15]|r - 只显示名称的前十五个字
- |cffffd200[ls:name:20]|r - 只显示名称的前二十个字
- |cffffd200[ls:server]|r - (*) 标记表示玩家是来自其他服务器
- |cffffd200[ls:color:class]|r - 职业着色
- |cffffd200[ls:color:reaction]|r - 阵营着色
- |cffffd200[ls:color:difficulty]|r - 难度着色

使用 |cffffd200||r|r 来表示着色格式化文本结束
使用 |cffffd200[nl]|r 来换行]=]
L["NO_SEPARATION"] = "不分隔"
L["NOTHING_TO_SHOW"] = "不展示"
L["NPC_CLASSIFICATION"] = "NPC 类型"
L["NPE_FRAME"] = "新手引导框架"
L["NUM_BUTTONS"] = "按钮数量"
L["NUM_ROWS"] = "行数量"
L["OBJECTIVE_TRACKER"] = "目标追踪器"
L["ON_COOLDOWN"] = "冷却中"
L["OOM"] = "法力不足"
L["OOM_INDICATOR"] = "法力不足指示器"
L["OOR"] = "超出距离"
L["OOR_INDICATOR"] = "超出距离指示器"
L["OPEN_CONFIG"] = "打开设置"
L["ORBS"] = "球形"
L["OTHER"] = "其他"
L["OTHERS_FIRST"] = "他人优先"
L["OUTLINE"] = "轮廓"
L["PER_ROW"] = "每行"
L["PET_BAR"] = "宠物条"
L["PET_BATTLE_BAR"] = "宠物对战条"
L["PET_CAST_BAR"] = "宠物施法条"
L["PET_FRAME"] = "宠物框架"
L["PLAYER_CLASS"] = "玩家职业"
L["PLAYER_FRAME"] = "玩家框架"
L["PLAYER_PET"] = "玩家 & 宠物"
L["PLAYER_TITLE"] = "玩家头衔"
L["POINT"] = "锚点"
L["POINT_DESC"] = "对象的锚点"
L["POSITION"] = "位置"
L["POWER"] = "资源"
L["POWER_FORMAT_DESC"] = [=[通过格式化字符串来修改文本显示，留空表示禁用此功能

格式化文本
- |cffffd200[ls:power:cur]|r - 当前值
- |cffffd200[ls:power:max]|r - 最大值
- |cffffd200[ls:power:perc]|r - 百分比
- |cffffd200[ls:power:cur-max]|r - 当前值和最大值
- |cffffd200[ls:power:cur-color-max]|r - 当前值和着色后的最大值
- |cffffd200[ls:power:cur-perc]|r - 当前值和百分比
- |cffffd200[ls:power:cur-color-perc]|r - 当前值和着色后的百分比
- |cffffd200[ls:power:deficit]|r - 剩余值
- |cffffd200[ls:color:power]|r - 着色

如果当前值和最大值一样，那么只会显示最大值

使用 |cffffd200||r|r 来表示着色格式化文本结束
使用 |cffffd200[nl]|r 来换行]=]
L["POWER_TEXT"] = "资源文字"
L["PRESTIGE_LEVEL_TOOLTIP"] = "威望等级：|cffffffff%s|r"
L["PREVIEW"] = "预览"
L["PVP_ICON"] = "PvP 图标"
L["QUESTLOG_BUTTON_DESC"] = "显示每日任务重置计时器"
L["RAID_ICON"] = "团队图标"
L["RCLICK_SELFCAST"] = "右击自我施法"
L["REACTION"] = "关系"
L["RELATIVE_POINT"] = "相对锚点"
L["RELATIVE_POINT_DESC"] = "对象依附的区域的锚点"
L["RELOAD_NOW"] = "立刻重载"
L["RELOAD_UI_ON_CHAR_SETTING_CHANGE_POPUP"] = "你刚刚修改了特定角色的设置，这些设置独立于你账号的设置，想让这些设置生效你需要重载界面"
L["RELOAD_UI_WARNING"] = "设置完插件后重载 UI"
L["RESTORE_DEFAULTS"] = "恢复默认"
L["RESTRICTED_MODE"] = "限制模式"
L["RESTRICTED_MODE_DESC"] = [=[启用主动作条的装饰，动画和动态缩放功能

|cffdc4436注意|r，一些动作条自定义选项将在此模式下不可用！|r]=]
L["RIGHT"] = "右"
L["RIGHT_DOWN"] = "右下"
L["RIGHT_UP"] = "右上"
L["ROWS"] = "行"
L["RUNES"] = "符文"
L["SECOND_ANCHOR"] = "第二锚点"
L["SECONDS"] = "秒"
L["SELF_BUFFS"] = "自我增益"
L["SELF_BUFFS_DESC"] = "显示单位施放的增益效果"
L["SELF_BUFFS_PERMA"] = "永久自我增益"
L["SELF_BUFFS_PERMA_DESC"] = "显示单位施放的永久性增益效果"
L["SELF_DEBUFFS"] = "自我减益"
L["SELF_DEBUFFS_DESC"] = "显示单位施放的减益效果"
L["SELF_DEBUFFS_PERMA"] = "永久自我减益"
L["SELF_DEBUFFS_PERMA_DESC"] = "显示单位施放的永久性减益效果"
L["SEPARATION"] = "分隔"
L["SHADOW"] = "阴影"
L["SHIFT_CLICK_TO_SHOW_AS_XP"] = "|cffffffffShift 加点击|r 来显示经验条"
L["SIZE"] = "尺寸"
L["SIZE_OVERRIDE"] = "覆盖原有尺寸"
L["SIZE_OVERRIDE_DESC"] = "如果设置为 0 的话，UI 元素的尺寸将会被自动计算"
L["SORT_DIR"] = "排序方向"
L["SORT_METHOD"] = "排序方法"
L["SPACING"] = "间距"
L["STANCE_BAR"] = "姿态条"
L["TALKING_HEAD_FRAME"] = "剧情动画框架"
L["TARGET_FRAME"] = "目标框架"
L["TARGET_INFO"] = "目标信息"
L["TARGET_INFO_DESC"] = "显示单位的目标"
L["TARGET_TOT"] = "目标 & 目标的目标"
L["TEXT"] = "文本"
L["TEXT_HORIZ_ALIGNMENT"] = "水平对齐"
L["TEXT_VERT_ALIGNMENT"] = "垂直对齐"
L["THREAT_GLOW"] = "仇恨目标边框高亮"
L["TIME"] = "时间"
L["TOF_FRAME"] = "焦点目标的目标框架"
L["TOGGLE_ANCHORS"] = "激活锚点"
L["TOOLTIP_IDS"] = "法术和物品 ID"
L["TOOLTIPS"] = "鼠标提示"
L["TOP"] = "顶部"
L["TOP_INSET_SIZE"] = "额外资源尺寸"
L["TOP_INSET_SIZE_DESC"] = "职业资源，职业第二资源以及职业其他资源尺寸"
L["TOT_FRAME"] = "目标的目标框架"
L["TOTEMS"] = "图腾"
L["UI_LAYOUT"] = "UI 布局"
L["UI_LAYOUT_DESC"] = "修改玩家和宠物框架外观，与此同时也会修改 UI 布局"
L["UNITS"] = "单位"
L["UNSPENT_TRAIT_POINTS_TOOLTIP"] = "未使用的神器点数：|cffffffff%s|r"
L["UNUSABLE"] = "不可用"
L["UP"] = "上"
L["USABLE"] = "可用"
L["USE_BLIZZARD_VEHICLE_UI"] = "使用暴雪载具 UI"
L["VEHICLE_EXIT_BUTTON"] = "离开载具按钮"
L["VEHICLE_SEAT_INDICATOR"] = "载具座位指示器"
L["VERT_GROWTH_DIR"] = "垂直增长"
L["VISIBILITY"] = "可见性"
L["WIDTH"] = "宽度"
L["WIDTH_OVERRIDE"] = "覆盖原有宽度"
L["WORD_WRAP"] = "文字换行"
L["X_OFFSET"] = "X 轴偏移"
L["XP_BAR"] = "经验条"
L["Y_OFFSET"] = "Y 轴偏移"
L["YOURS_FIRST"] = "玩家优先"
L["ZONE_ABILITY_BUTTON"] = "区域特殊能力按钮"
L["ZONE_TEXT"] = "区域文字"
