﻿-- Contributors: aenerv7@GitHub a.k.a. aenerv7@Curse, sylvanas54@Curse

local _, ns = ...
local E, L = ns.E, ns.L

-- Lua
local _G = getfenv(0)
local m_modf = _G.math.modf
local s_format = _G.string.format

if GetLocale() ~= "zhCN" then return end

-- Mine
do
	local BreakUpLargeNumbers = _G.BreakUpLargeNumbers
	local SECOND_NUMBER_CAP = "%s.%d" .. _G.SECOND_NUMBER_CAP_NO_SPACE
	local FIRST_NUMBER_CAP = "%s.%d" .. _G.FIRST_NUMBER_CAP_NO_SPACE

	function E:FormatNumber(v)
		if v >= 1E8 then
			local i, f = m_modf(v / 1E8)
			return s_format(SECOND_NUMBER_CAP, BreakUpLargeNumbers(i), f * 10)
		elseif v >= 1E4 then
			local i, f = m_modf(v / 1E4)
			return s_format(FIRST_NUMBER_CAP, BreakUpLargeNumbers(i), f * 10)
		elseif v >= 0 then
			return BreakUpLargeNumbers(v)
		else
			return 0
		end
	end
end

L["ADVENTURE_JOURNAL_DESC"] = "显示团队副本锁定信息"
L["ALTERNATIVE_POWER"] = "第二资源"
L["ALTERNATIVE_POWER_FORMAT_DESC"] = [=[通过格式化字符串来修改文本显示，留空表示禁用此功能

格式化文本
- |cffffd200[ls:altpower:cur]|r - 当前值
- |cffffd200[ls:altpower:max]|r - 最大值
- |cffffd200[ls:altpower:perc]|r - 百分比
- |cffffd200[ls:altpower:cur-max]|r - 当前值和最大值
- |cffffd200[ls:altpower:cur-perc]|r - 当前值和百分比
- |cffffd200[ls:color:altpower]|r - 着色

如果当前值和最大值一样，那么只会显示最大值

使用 |cffffd200||r|r 来表示着色格式化文本结束
使用 |cffffd200[nl]|r 来换行]=]
L["ALWAYS_SHOW"] = "总是显示"
L["ANCHOR"] = "锚点"
L["ARTIFACT_LEVEL_TOOLTIP"] = "神器等级：|cffffffff%s|r"
L["ARTIFACT_POWER"] = "神器能量"
L["ASCENDING"] = "升序"
L["AURA"] = "光环"
L["AURA_FILTERS"] = "光环过滤器"
L["AURA_TRACKER"] = "光环追踪器"
L["AURA_TYPE"] = "光环类型"
L["AUTO"] = "自动"
L["BAG_TOOLTIP_DESC"] = "显示货币信息"
L["BAR_COLOR"] = "生命条颜色"
L["BAR_TEXT"] = "动作条文字"
L["BLACKLIST"] = "黑名单"
L["BLIZZARD"] = "暴雪默认 UI"
L["BONUS_XP_TOOLTIP"] = "奖励经验：|cffffffff%s|r"
L["BORDER"] = "边框"
L["BORDER_COLOR"] = "边框颜色"
L["BOSS"] = "首领"
L["BOSS_BUFFS"] = "首领增益效果"
L["BOSS_BUFFS_DESC"] = "显示首领施放的增益效果"
L["BOSS_DEBUFFS"] = "首领减益效果"
L["BOSS_DEBUFFS_DESC"] = "显示首领施放的减益效果"
L["BOSS_FRAMES"] = "首领框架"
L["BOTTOM_INSET_SIZE"] = "底部插页尺寸"
L["BOTTOM_INSET_SIZE_DESC"] = "被资源条使用"
L["BUFFS"] = "增益效果"
L["BUFFS_AND_DEBUFFS"] = "增益和减益"
L["BUTTON"] = "按键"
L["BUTTON_GRID"] = "按钮边框"
L["BUTTONS"] = "按钮"
L["CASTABLE_BUFFS"] = "可施放增益效果"
L["CASTABLE_BUFFS_DESC"] = "显示你施放的增益效果"
L["CASTABLE_BUFFS_PERMA"] = "可施放的永久增益效果"
L["CASTABLE_BUFFS_PERMA_DESC"] = "显示你施放的永久增益效果"
L["CASTABLE_DEBUFFS"] = "可施放的减益效果"
L["CASTABLE_DEBUFFS_DESC"] = "显示你施放的减益效果"
L["CASTABLE_DEBUFFS_PERMA"] = "可施放的永久减益效果"
L["CASTABLE_DEBUFFS_PERMA_DESC"] = "显示你施放的永久减益效果"
L["CASTBAR"] = "施法条"
L["CHANGELOG"] = "更新日志"
L["CHARACTER_BUTTON_DESC"] = "显示装备耐久度信息"
L["CHARACTER_FRAME"] = "角色框架"
L["CLASS_POWER"] = "职业能量"
L["CLEAN_UP"] = "清理"
L["CLEAN_UP_MAIL_DESC"] = "移除所有没有附件的邮件。"
L["COLOR_BY_SPEC"] = "按照专精着色"
L["COLORS"] = "着色"
L["COMBO_POINTS_CHARGED"] = "充能连击点数"
L["COMMAND_BAR"] = "命令条"
L["CONFIRM_DELETE"] = "确定要删除“%s”？"
L["CONFIRM_RESET"] = "确认要重置“%s”？"
L["COOLDOWN"] = "CD"
L["COOLDOWN_SWIPE"] = "CD 结束显示"
L["COOLDOWN_TEXT"] = "CD 文本"
L["COOLDOWNS"] = "冷却计时"
L["COORDS"] = "坐标"
L["COPY_FROM"] = "复制自"
L["COPY_FROM_DESC"] = "选择一份配置文件复制"
L["COST_PREDICTION"] = "花费预测"
L["COST_PREDICTION_DESC"] = "显示法术将要花费的资源，对瞬发法术不生效"
L["COUNT_TEXT"] = "数量文字"
L["CURSE"] = "诅咒"
L["CUSTOM_TEXTS"] = "自定义文本"
L["DAILY_QUEST_RESET_TIME_TOOLTIP"] = "日常任务重置时间：|cffffffff%s|r"
L["DAMAGE_ABSORB"] = "伤害吸收"
L["DATA_FORMAT_STRING"] = "字符串"
L["DATA_FORMAT_TABLE"] = "表格"
L["DAYS"] = "天"
L["DEBUFF"] = "减益效果"
L["DEBUFFS"] = "减益效果"
L["DESATURATION"] = "褪色"
L["DESCENDING"] = "降序"
L["DETACH_FROM_FRAME"] = "从框架脱离"
L["DIFFICULT"] = "困难"
L["DIFFICULTY"] = "难度"
L["DIFFICULTY_FLAG"] = "难度标记"
L["DISABLE_MOUSE"] = "禁用鼠标"
L["DISABLE_MOUSE_DESC"] = "忽略鼠标事件"
L["DISEASE"] = "疾病"
L["DISPELLABLE_DEBUFF_ICONS"] = "可驱散的减益效果图标"
L["DISPELLABLE_DEBUFFS"] = "可驱散的减益效果"
L["DISPELLABLE_DEBUFFS_DESC"] = "显示目标身上你可以驱散的减益效果"
L["DOWN"] = "下"
L["DOWNLOADS"] = "下载"
L["DRAG_KEY"] = "拖动键"
L["DUNGEONS_BUTTON_DESC"] = "显示随机稀缺职业奖励信息"
L["ENABLE_BLIZZARD_CASTBAR"] = "启用暴雪施法条"
L["ENDCAPS"] = "美化"
L["ENDCAPS_BOTH"] = "两个都"
L["ENDCAPS_LEFT"] = "左边"
L["ENDCAPS_RIGHT"] = "右边"
L["ENEMY_UNITS"] = "敌对单位"
L["ENHANCED_TOOLTIPS"] = "鼠标提示增强"
L["EVENTS"] = "事件"
L["EXP_THRESHOLD"] = "小数显示阈值"
L["EXPERIENCE_NORMAL"] = "正常经验收益"
L["EXPERIENCE_RESTED"] = "精力充沛收益"
L["EXPIRATION"] = "即将结束"
L["EXPORT"] = "导出"
L["EXPORT_TARGET"] = "选择需要导出的内容"
L["EXTRA_ACTION_BUTTON"] = "额外动作按钮"
L["FACTION_NEUTRAL"] = "中立"
L["FADE_IN_DURATION"] = "淡入时长"
L["FADE_OUT_DELAY"] = "延迟淡出"
L["FADE_OUT_DURATION"] = "淡出时长"
L["FADING"] = "渐隐"
L["FILTER_SETTINGS"] = "过滤器设置"
L["FILTERS"] = "过滤器"
L["FLYOUT_DIR"] = "弹出方向"
L["FOCUS_FRAME"] = "焦点目标框架"
L["FOCUS_TOF"] = "焦点目标 & 焦点目标的目标"
L["FONTS"] = "字体"
L["FORMAT"] = "格式"
L["FRAME"] = "框架"
L["FRIENDLY_TERRITORY"] = "友方区域"
L["FRIENDLY_UNITS"] = "友好单位"
L["FULL_CHANGELOG"] = "完整"
L["FUNC"] = "功能"
L["GLOSS"] = "高光"
L["GM_FRAME"] = "申请状态框架"
L["GROWTH_DIR"] = "增长方向"
L["HEAL_ABSORB"] = "吸收治疗"
L["HEAL_PREDICTION"] = "治疗预测"
L["HEALER_BUFFS"] = "治疗者增益效果"
L["HEALER_BUFFS_DESC"] = "显示来自治疗者的增益效果。"
L["HEALER_DEBUFFS"] = "治疗者减益效果"
L["HEALER_DEBUFFS_DESC"] = "显示来自治疗者的减益效果。"
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
L["HEIGHT_OVERRIDE_DESC"] = "当设置为 0 时，将会自动计算高度。"
L["HOSTILE_TERRITORY"] = "敌方区域"
L["HOURS"] = "小时"
L["ICON"] = "图标"
L["IMPORT"] = "导入"
L["IMPOSSIBLE"] = "不可能"
L["INDEX"] = "索引"
L["INSPECT_INFO"] = "玩家信息"
L["INVALID_EVENTS_ERR"] = "尝试使用无效事件：%s。"
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
L["LOCK_BUTTONS"] = "锁定按钮"
L["M_SS_THRESHOLD"] = "M:SS 显示阈值"
L["M_SS_THRESHOLD_DESC"] = "低于此秒数的时间将会以 4:01 的格式显示，设置成 0 表示禁用此格式"
L["MACRO_TEXT"] = "宏文字"
L["MAGIC"] = "魔法"
L["MAINMENU_BUTTON_DESC"] = "显示性能信息"
L["MAX_ALPHA"] = "最大透明度"
L["MICRO_BUTTONS"] = "微型菜单按钮"
L["MIN_ALPHA"] = "最小透明度"
L["MINUTES"] = "分"
L["MIRROR_WIDGETS"] = "镜像翻转组件"
L["MIRROR_WIDGETS_DESC"] = "修改状态图标，施法条和 PVP 图标的顺序"
L["MOUNT_AURAS"] = "坐骑光环"
L["MOUNT_AURAS_DESC"] = "显示坐骑光环"
L["MOVER_CYCLE_DESC"] = "按 |cffffffffAlt|r 键切换位于鼠标位置的不同组件"
L["MOVER_GRID"] = "网格"
L["MOVER_MOVE_DESC"] = "|cffffffffShift/Ctrl + 鼠标滚轮|r 或 |cffffffff方向键|r 来进行 1px 精度的调整。"
L["MOVER_NAMES"] = "名称"
L["MOVER_RELATION_CREATE_DESC"] = "|cffffffff拖拽|r 锚点 (|A:UI-Taxi-Icon-Nub:12:12|a) 来创建一个新的链接。"
L["MOVER_RELATION_DESTROY_DESC"] = "|cffffffff按住 Shift 点击|r 锚点 (|A:UI-Taxi-Icon-Nub:12:12|a) 来销毁已有的链接。"
L["MOVER_RESET_DESC"] = "|cffffffffShift 加点击|r 来重置位置"
L["NAME"] = "名称"
L["NAME_FORMAT_DESC"] = [=[通过格式化字符串来修改文本显示，留空表示禁用此功能

格式化文本
- |cffffd200[ls:name]|r - 名称
- |cffffd200[ls:name(N)]|r - the name shortened to N characters, for instance, [ls:name(5)] will show only 5 characters;
- |cffffd200[ls:server]|r - (*) 标记表示玩家是来自其他服务器
- |cffffd200[ls:color:class]|r - 职业着色
- |cffffd200[ls:color:reaction]|r - 阵营着色
- |cffffd200[ls:color:difficulty]|r - 难度着色

使用 |cffffd200||r|r 来表示着色格式化文本结束
使用 |cffffd200[nl]|r 来换行]=]
L["NAME_TAKEN_ERR"] = "名称已被使用。"
L["NO_SEPARATION"] = "不分隔"
L["NOTHING_TO_SHOW"] = "不展示"
L["NUM_BUTTONS"] = "按钮数量"
L["NUM_ROWS"] = "行数量"
L["NUMERIC"] = "数值"
L["NUMERIC_PERCENTAGE"] = "数值和百分比"
L["OOM"] = "法力不足"
L["OOM_INDICATOR"] = "法力不足指示器"
L["OOR"] = "超出距离"
L["OOR_INDICATOR"] = "超出距离指示器"
L["OPEN_CONFIG"] = "打开设置"
L["OTHERS_FIRST"] = "他人优先"
L["OTHERS_HEALING"] = "来自他人的治疗"
L["OUTLINE"] = "轮廓"
L["OVERWRITE_CURRENT_PROFILE"] = "覆盖当前档案"
L["PER_ROW"] = "每行"
L["PET_BAR"] = "宠物条"
L["PET_BATTLE_BAR"] = "宠物对战条"
L["PET_FRAME"] = "宠物框架"
L["PLAYER_FRAME"] = "玩家框架"
L["PLAYER_PET"] = "玩家 & 宠物"
L["PLAYER_TITLE"] = "玩家头衔"
L["POINT"] = "锚点"
L["POINT_DESC"] = "对象的锚点"
L["POISON"] = "中毒"
L["PORTRAIT"] = "头像"
L["POSITION"] = "位置"
L["POWER"] = "资源"
L["POWER_COST"] = "能量消耗"
L["POWER_FORMAT_DESC"] = [=[通过格式化字符串来修改文本显示，留空表示禁用此功能

格式化文本
- |cffffd200[ls:power:cur]|r - 当前值
- |cffffd200[ls:power:max]|r - 最大值
- |cffffd200[ls:power:perc]|r - 百分比
- |cffffd200[ls:power:cur-max]|r - 当前值和最大值
- |cffffd200[ls:power:cur-perc]|r - 当前值和百分比
- |cffffd200[ls:power:deficit]|r - 剩余值
- |cffffd200[ls:color:power]|r - 着色

如果当前值和最大值一样，那么只会显示最大值

使用 |cffffd200||r|r 来表示着色格式化文本结束
使用 |cffffd200[nl]|r 来换行]=]
L["POWER_TEXT"] = "资源文字"
L["PREDICTION"] = "预估"
L["PREVIEW"] = "预览"
L["PROFILE_GLOBAL"] = "全局档案"
L["PROFILE_GLOBAL_UPDATE_WARNING"] = "|cffF6C442全局|r 档案 |cffE6762F%s|r v|cff888987%.2f|r 中存在过期数据，档案数据结构将会更新到最新版本，但强烈建议重置该档案。"
L["PROFILE_PRIVATE"] = "本地档案"
L["PROFILE_PRIVATE_UPDATE_WARNING"] = "|cffF6C442本地|r 档案 |cffE6762F%s|r v|cff888987%.2f|r 中存在过期数据，档案数据结构将会更新到最新版本，但强烈建议重置该档案。"
L["PROFILE_RELOAD_WARNING"] = "需要重载 UI 来使修改生效。"
L["PROFILES"] = "档案"
L["PROGRESS_BAR_SMOOTH"] = "平滑"
L["PROGRESS_BARS"] = "进度条"
L["PVP_ICON"] = "PvP 图标"
L["QUESTLOG_BUTTON_DESC"] = "显示每日任务重置计时器"
L["RAID_ICON"] = "团队图标"
L["RCLICK_SELFCAST"] = "右击自我施法"
L["REACTION"] = "关系"
L["RELATIVE_POINT"] = "相对锚点"
L["RELATIVE_POINT_DESC"] = "对象依附的区域的锚点"
L["RELOAD_NOW"] = "立刻重载"
L["RESTRICTED_MODE_DESC"] = [=[启用主动作条的装饰，动画和动态缩放功能

|cffdc4436注意|r，一些动作条自定义选项将在此模式下不可用！|r]=]
L["REVERSE"] = "反向"
L["RIGHT"] = "右"
L["RIGHT_DOWN"] = "右下"
L["RIGHT_UP"] = "右上"
L["ROWS"] = "行"
L["RUNES"] = "符文"
L["RUNES_BLOOD"] = "鲜血符文"
L["RUNES_FROST"] = "冰霜符文"
L["RUNES_UNHOLY"] = "邪恶符文"
L["S_MS_THRESHOLD"] = "毫秒阈值"
L["S_MS_THRESHOLD_DESC"] = "低于阈值的秒数将以秒:毫秒格式显示"
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
L["SHOW_ARTWORK"] = "显示装饰"
L["SHOW_ON_MOUSEOVER"] = "鼠标经过时显示"
L["SIZE"] = "尺寸"
L["SORT_DIR"] = "排序方向"
L["SORT_METHOD"] = "排序方法"
L["SPACING"] = "间距"
L["SPELL_CAST"] = "释放法术"
L["SPELL_CHANNELED"] = "引导法术"
L["SPELL_FAILED"] = "释放法术失败"
L["SPELL_UNINTERRUPTIBLE"] = "不可打断"
L["STAGGER_HIGH"] = "高化劲"
L["STAGGER_LOW"] = "低化劲"
L["STAGGER_MEDIUM"] = "中化劲"
L["STANCE_BAR"] = "姿态条"
L["STANDARD"] = "标准"
L["STYLE"] = "样式"
L["TAG_VARS"] = "标签变量"
L["TAGS"] = "标签"
L["TANK_BUFFS"] = "坦克增益效果"
L["TANK_BUFFS_DESC"] = "显示来自坦克的增益效果"
L["TANK_DEBUFFS"] = "坦克减益效果"
L["TANK_DEBUFFS_DESC"] = "显示来自坦克的减益效果"
L["TAPPED"] = "归属权已丢失"
L["TARGET_FRAME"] = "目标框架"
L["TARGET_INFO"] = "目标信息"
L["TARGET_INFO_DESC"] = "显示单位的目标"
L["TARGET_TOT"] = "目标 & 目标的目标"
L["TEMP_ENCHANT"] = "临时附魔"
L["TEXT"] = "文本"
L["TEXT_HORIZ_ALIGNMENT"] = "水平对齐"
L["TEXT_VERT_ALIGNMENT"] = "垂直对齐"
L["THREAT_GLOW"] = "仇恨目标边框高亮"
L["TIME"] = "时间"
L["TOF_FRAME"] = "焦点目标的目标框架"
L["TOGGLE_ANCHORS"] = "激活锚点"
L["TOOLTIP_IDS"] = "法术和物品 ID"
L["TOOLTIPS"] = "鼠标提示"
L["TOP_INSET_SIZE"] = "额外资源尺寸"
L["TOP_INSET_SIZE_DESC"] = "职业资源，职业第二资源以及职业其他资源尺寸"
L["TOT_FRAME"] = "目标的目标框架"
L["TOTEMS"] = "图腾"
L["TRIVIAL"] = "弱小"
L["UNITS"] = "单位"
L["UNUSABLE"] = "不可用"
L["UP"] = "上"
L["USABLE"] = "可用"
L["USE_BLIZZARD_VEHICLE_UI"] = "使用暴雪载具 UI"
L["USER_CREATED"] = "用户创建的"
L["VALIDATE"] = "验证"
L["VALUE"] = "值"
L["VAR"] = "变量"
L["VEHICLE_EXIT_BUTTON"] = "离开载具按钮"
L["VERY_DIFFICULT"] = "非常困难"
L["VISIBILITY"] = "可见性"
L["WIDTH"] = "宽度"
L["WIDTH_OVERRIDE"] = "覆盖原有宽度"
L["WIDTH_OVERRIDE_DESC"] = "当设置为 0 时，将会自动计算宽度。"
L["WORD_WRAP"] = "文字换行"
L["X_OFFSET"] = "X 轴偏移"
L["XP_BAR"] = "经验条"
L["Y_OFFSET"] = "Y 轴偏移"
L["YOUR_HEALING"] = "玩家的治疗"
L["YOURS_FIRST"] = "玩家优先"
L["ZONE_ABILITY_BUTTON"] = "区域特殊能力按钮"
