-- Contributors: Biowoolf@WoWInterface

local _, ns = ...
local E, L = ns.E, ns.L

-- Lua
local _G = getfenv(0)

if _G.GetLocale() ~= "ruRU" then return end

L["ACTION_BARS"] = "Панели действий"
L["ADVENTURE_JOURNAL_DESC"] = "Показать информацию о пройденных рейдах."
L["ALT_POWER_BAR"] = "Альт.панель энергии"
L["ALT_POWER_FORMAT_DESC"] = [=[Provide a string to change the text. To disable, leave the field blank.

Tags:
- |cffffd200[ls:altpower:cur]|r - the current value;
- |cffffd200[ls:altpower:max]|r - the max value;
- |cffffd200[ls:altpower:perc]|r - the percentage;
- |cffffd200[ls:altpower:cur-max]|r - the current value followed by the max value;
- |cffffd200[ls:altpower:cur-color-max]|r - the current value followed by the coloured max value;
- |cffffd200[ls:altpower:cur-perc]|r - the current value followed by the percentage;
- |cffffd200[ls:altpower:cur-color-perc]|r - the current value followed by the coloured percentage;
- |cffffd200[ls:color:altpower]|r - colour.

If the current value is equal to the max value, only the max value will be displayed.

Use |cffffd200||r|r to close colour tags.
Use |cffffd200[nl]|r for line breaking.]=]
L["ALTERNATIVE_POWER"] = "Альт.Энергия"
L["ALWAYS_SHOW"] = "Всегда показывать"
L["ANCHOR"] = "Присоединить к"
L["ARTIFACT_LEVEL_TOOLTIP"] = "Уровень артефакта: |cffffffff%s|r"
L["ARTIFACT_POWER"] = "Сила артефакта"
L["ASCENDING"] = "По возрастанию"
L["AURA_TRACKER"] = "Отслеживание Ауры"
L["AURAS"] = "Ауры"
L["BAGS"] = "Сумки"
L["BAR_1"] = "Панель 1"
L["BAR_2"] = "Панель 2"
L["BAR_3"] = "Панель 3"
L["BAR_4"] = "Панель 4"
L["BAR_5"] = "Панель 5"
L["BAR_COLOR"] = "Цвет панели"
L["BAR_TEXT"] = "Текст панели"
L["BLIZZARD"] = "Blizzard"
L["BONUS_HONOR_TOOLTIP"] = "Бонусная честь: |cffffffff%s|r"
L["BONUS_XP_TOOLTIP"] = "Бонусный опыт: |cffffffff%s|r"
L["BORDER"] = "Край"
L["BORDER_COLOR"] = "Цвет края"
L["BOSS"] = "Босс"
L["BOSS_BUFFS"] = "Баффы босса"
L["BOSS_BUFFS_DESC"] = "Показать баффы наложенные боссом."
L["BOSS_DEBUFFS"] = "Дебаффы босса"
L["BOSS_DEBUFFS_DESC"] = "Показать дебаффы наложенные боссом."
L["BOSS_FRAMES"] = "Рамки босса"
L["BOTTOM"] = "Снизу"
L["BOTTOM_INSET_SIZE"] = "Размер нижней вкладки"
L["BOTTOM_INSET_SIZE_DESC"] = "Используется панелью энергии."
L["BUFFS"] = "Баффы"
L["BUFFS_AND_DEBUFFS"] = "Баффы и Дебаффы"
L["BUTTON_GRID"] = "Скрыть контуры"
L["CALENDAR"] = "Календарь"
L["CAST_ON_KEY_DOWN"] = "Каст при нажатии"
L["CASTABLE_BUFFS"] = "Накладываемые баффы"
L["CASTABLE_BUFFS_DESC"] = "Показать баффы наложенные вами."
L["CASTABLE_BUFFS_PERMA"] = "Накладываемые постоянные баффы"
L["CASTABLE_BUFFS_PERMA_DESC"] = "Показать дебаффы, наложенные вами."
L["CASTABLE_DEBUFFS"] = "Накладываемые дебаффы"
L["CASTABLE_DEBUFFS_DESC"] = "Показать постоянные дебаффы,наложенные вами."
L["CASTABLE_DEBUFFS_PERMA"] = "Накладываемые постоянные дебаффы"
L["CASTABLE_DEBUFFS_PERMA_DESC"] = "Показать постоянные дебаффы, наложенные вами."
L["CASTBAR"] = "Шкала произнесения"
L["CHARACTER_BUTTON_DESC"] = "Показать информацию о прочности экипировки."
L["CLASS_POWER"] = "Энергия класса"
L["CLASSIC"] = "Классический"
L["CLOCK"] = "Часы"
L["COMMAND_BAR"] = "Панель команд"
L["COPY_FROM"] = "Копировать из"
L["COPY_FROM_DESC"] = "Выберите объект для копирования настроек."
L["COST_PREDICTION"] = "Прогноз расхода"
L["COST_PREDICTION_DESC"] = "Показать панель, представляющую стоимость энергии заклинания. Не работает с мгновенными способностями."
L["COUNT_TEXT"] = "Настройка текста"
L["DAILY_QUEST_RESET_TIME_TOOLTIP"] = "Время восстановления ежед.заданий: |cffffffff%s|r"
L["DAMAGE_ABSORB_FORMAT_DESC"] = [=[Provide a string to change the text. To disable, leave the field blank.

Tags:
- |cffffd200[ls:absorb:damage]|r - the current value;
- |cffffd200[ls:color:absorb-damage]|r - the colour.

Use |cffffd200||r|r to close colour tags.
Use |cffffd200[nl]|r for line breaking.]=]
L["DAMAGE_ABSORB_TEXT"] = "Текст поглощения урона"
L["DEAD"] = "Мертвый"
L["DEBUFFS"] = "Дебаффы"
L["DESATURATE_ON_COOLDOWN"] = "Обесцветить при перезарядке"
L["DESCENDING"] = "По убыванию"
L["DETACH_FROM_FRAME"] = "Отсоединить от рамки"
L["DIFFICULTY_FLAG"] = "Флаг режима сложности"
L["DIGSITE_BAR"] = "Панель прогресса раскопок"
L["DISABLE_MOUSE"] = "Отключить мышь"
L["DISABLE_MOUSE_DESC"] = "Игнор.управления мышью."
L["DISPELLABLE_BUFFS"] = "Рассеиваемые баффы"
L["DISPELLABLE_BUFFS_DESC"] = "Показать баффы, которые вы можете украсть или рассеять у своей цели."
L["DISPELLABLE_DEBUFF_ICONS"] = "Иконки рассеиваемых дебаффов"
L["DISPELLABLE_DEBUFFS"] = "Рассеиваемые дебаффы"
L["DISPELLABLE_DEBUFFS_DESC"] = "Показать дебаффы, которые вы можете рассеять у своей цели."
L["DOWN"] = "Вниз"
L["DRAG_KEY"] = "Перетащить ключ"
L["DRAW_COOLDOWN_BLING"] = "Показать мерцание таймера перезарядки"
L["DRAW_COOLDOWN_BLING_DESC"] = "Показать мерцание в конце перезарядки."
L["DUNGEONS_BUTTON_DESC"] = "Показать информацию о Призыве к оружию."
L["DURABILITY_FRAME"] = "Рамка Прочности"
L["ELITE"] = "Элита"
L["ENEMY_UNITS"] = "Враждебные объекты"
L["ENHANCED_TOOLTIPS"] = "Расширенные подсказки"
L["ENTER_SPELL_ID"] = "Введите ID способности"
L["EXPERIENCE"] = "Опыт"
L["EXTRA_ACTION_BUTTON"] = "Кнопка спец.действия"
L["FADE_IN_DELAY"] = "Время появления"
L["FADE_IN_DURATION"] = "Срок появления"
L["FADE_OUT_DELAY"] = "Время исчезновения"
L["FADE_OUT_DURATION"] = "Срок исчезновения"
L["FADING"] = "Затухание"
L["FCF"] = "Обратная связь в бою"
L["FILTER_SETTINGS"] = "Настройки фильтра"
L["FILTERS"] = "Фильтры"
L["FLAG"] = "Флаг"
L["FLYOUT_DIR"] = "Направление вылета"
L["FOCUS_FRAME"] = "Рамка фокуса"
L["FOCUS_TOF"] = "Фокус и Фокус Цели"
L["FORMAT"] = "Формат"
L["FRAME"] = "Рамка"
L["FRIENDLY_UNITS"] = "Дружественные объекты"
L["GM_FRAME"] = "Рамка статуса запроса"
L["GOLD"] = "Золото"
L["GROWTH_DIR"] = "Направление роста"
L["HEAL_ABSORB_FORMAT_DESC"] = [=[Provide a string to change the text. To disable, leave the field blank.

Tags:
- |cffffd200[ls:absorb:heal]|r - the current value;
- |cffffd200[ls:color:absorb-heal]|r - the colour.

Use |cffffd200||r|r to close colour tags.
Use |cffffd200[nl]|r for line breaking.]=]
L["HEAL_ABSORB_TEXT"] = "Текст поглощения лечения"
L["HEAL_PREDICTION"] = "Прогноз лечения"
L["HEALTH"] = "Здоровье"
L["HEALTH_FORMAT_DESC"] = [=[Provide a string to change the text. To disable, leave the field blank.

Tags:
- |cffffd200[ls:health:cur]|r - the current value;
- |cffffd200[ls:health:perc]|r - the percentage;
- |cffffd200[ls:health:cur-perc]|r - the current value followed by the percentage;
- |cffffd200[ls:health:deficit]|r - the deficit value.

If the current value is equal to the max value, only the max value will be displayed.

Use |cffffd200[nl]|r for line breaking.]=]
L["HEALTH_TEXT"] = "Текст здоровья"
L["HEIGHT"] = "Высота"
L["HONOR"] = "Часть"
L["HONOR_LEVEL_TOOLTIP"] = "Уровень чести: |cffffffff%d|r"
L["HORIZ_GROWTH_DIR"] = "Горизонтальное направление роста"
L["ICON"] = "Иконка"
L["INDEX"] = "Индекс"
L["INSPECT_INFO"] = "Осмотреть"
L["INSPECT_INFO_DESC"] = "Отображение специализации и уровня предметов.Эти данные могут быть доступны не сразу."
L["ITEM_COUNT"] = "Кол-во предметов"
L["ITEM_COUNT_DESC"] = "Отображать количество ваших предметов в банке и сумках."
L["KEYBIND_TEXT"] = "Текст клавиш"
L["LATENCY"] = "Задержка"
L["LATENCY_HOME"] = "Home"
L["LATENCY_WORLD"] = "World"
L["LATER"] = "Позже"
L["LEFT"] = "Влево"
L["LEFT_DOWN"] = "Влево и вниз"
L["LEFT_UP"] = "Влево и вверх"
L["LEVEL_TOOLTIP"] = "Уровень: |cffffffff%d|r"
L["LOCK"] = "Заблокировать"
L["LOCK_BUTTONS"] = "Заблокировать кнопки"
L["LOCK_BUTTONS_DESC"] = "Предотвращает перемещение способностей на панелях действий."
L["MACRO_TEXT"] = "Текст макроса"
L["MAINMENU_BUTTON_DESC"] = "Показать информацию о производительности."
L["MAINMENU_BUTTON_HOLD_TOOLTIP"] = "|cffffffffHold Shift|r для показа используемой памяти."
L["MAX_ALPHA"] = "Max Alpha"
L["MEMORY"] = "Память"
L["MICRO_BUTTONS"] = "Кнопки Микроменю"
L["MIN_ALPHA"] = "Min Alpha"
L["MIRROR_TIMER"] = "Зеркальные таймеры"
L["MODE"] = "Режим"
L["MOUNT_AURAS"] = "Mount Auras"
L["MOUNT_AURAS_DESC"] = "Show mount auras."
L["MOUSEOVER_SHOW"] = "Показать при наведении"
L["MOVER_BUTTONS_DESC"] = "|cffffffffClick|r to toggle buttons."
L["MOVER_CYCLE_DESC"] = "Нажми |cffffffffAlt|r для прокрутки под курсором."
L["MOVER_RESET_DESC"] = "|cffffffffShift-Click|r чтобы сбросить позицию."
L["NAME"] = "Название"
L["NAME_FORMAT_DESC"] = [=[Provide a string to change the text. To disable, leave the field blank.

Tags:
- |cffffd200[ls:name]|r - the name;
- |cffffd200[ls:name:5]|r - the name shortened to 5 characters;
- |cffffd200[ls:name:10]|r - the name shortened to 10 characters;
- |cffffd200[ls:name:15]|r - the name shortened to 15 characters;
- |cffffd200[ls:name:20]|r - the name shortened to 20 characters;
- |cffffd200[ls:server]|r - the (*) tag for players from foreign realms;
- |cffffd200[ls:color:class]|r - the class colour;
- |cffffd200[ls:color:reaction]|r - the reaction colour;
- |cffffd200[ls:color:difficulty]|r - the difficulty colour.

Use |cffffd200||r|r to close colour tags.
Use |cffffd200[nl]|r for line breaking.]=]
L["NO_SEPARATION"] = "Без разделения"
L["NPC_CLASSIFICATION"] = "Тип существ"
L["NPE_FRAME"] = "Рамка учебника NPE"
L["NUM_BUTTONS"] = "Количество кнопок"
L["NUM_ROWS"] = "Количество строк"
L["OBJECTIVE_TRACKER"] = "Отслеживание цели"
L["OOM_INDICATOR"] = "Отображение при недоступности ресурса"
L["OOR_INDICATOR"] = "Отображение при недосягаемости цели"
L["OPEN_CONFIG"] = "Настройки"
L["ORBS"] = "Круглый"
L["OTHER"] = "Другое"
L["OTHERS_FIRST"] = "Другие в первую очередь"
L["OUTLINE"] = "Контур"
L["PER_ROW"] = "Размер строки"
L["PET_BAR"] = "Панель питомца"
L["PET_BATTLE_BAR"] = "Боевая панель питомца"
L["PET_FRAME"] = "Рамка питомца"
L["PLAYER_CLASS"] = "Класс игрока"
L["PLAYER_FRAME"] = "Рамка игрока"
L["PLAYER_PET"] = "Игрок и питомец"
L["PLAYER_TITLE"] = "Звание игрока"
L["POINT"] = "Точка"
L["POINT_DESC"] = "Точка объекта."
L["POSITION"] = "Расположение"
L["POWER"] = "Энергия"
L["POWER_FORMAT_DESC"] = [=[Provide a string to change the text. To disable, leave the field blank.

Tags:
- |cffffd200[ls:power:cur]|r - the current value;
- |cffffd200[ls:power:max]|r - the max value;
- |cffffd200[ls:power:perc]|r - the percentage;
- |cffffd200[ls:power:cur-max]|r - the current value followed by the max value;
- |cffffd200[ls:power:cur-color-max]|r - the current value followed by the coloured max value;
- |cffffd200[ls:power:cur-perc]|r - the current value followed by the percentage;
- |cffffd200[ls:power:cur-color-perc]|r - the current value followed by the coloured percentage;
- |cffffd200[ls:power:deficit]|r - the deficit value;
- |cffffd200[ls:color:power]|r - the colour.

If the current value is equal to the max value, only the max value will be displayed.

Use |cffffd200||r|r to close colour tags.
Use |cffffd200[nl]|r for line breaking.]=]
L["POWER_TEXT"] = "Текст энергии"
L["PRESTIGE_LEVEL_TOOLTIP"] = "Уровень престижа: |cffffffff%s|r"
L["PREVIEW"] = "Предпросмотр"
L["PVP_ICON"] = "PvP иконка"
L["QUESTLOG_BUTTON_DESC"] = "Показать время восстановления ежедневных заданий."
L["RAID_ICON"] = "Иконка рейда"
L["RCLICK_SELFCAST"] = "Каст на себя(прав.клав.мыши)"
L["REACTION"] = "Реакция"
L["RELATIVE_POINT"] = "Относительная точка"
L["RELATIVE_POINT_DESC"] = "Точка области для присоединения объекта к."
L["RELOAD_NOW"] = "Перезагрузить сейчас"
L["RELOAD_UI_ON_CHAR_SETTING_CHANGE_POPUP"] = "Вы только что изменили настройки персонажа. Эти параметры не зависят от ваших профилей. Чтобы изменения вступили в силу, необходимо перезагрузить интерфейс."
L["RELOAD_UI_WARNING"] = "Перезагрузите интерфейс после завершения настройки аддона."
L["RESTORE_DEFAULTS"] = "По умолчанию"
L["RESTRICTED_MODE"] = "Ограниченный режим"
L["RESTRICTED_MODE_DESC"] = [=[Включает оформление, анимацию и динамическое изменение размера для главной панели действий.

|cffdc4436Внимание!|r Многие параметры настроек панели действий,будут не доступны в этом режиме.|r]=]
L["RIGHT"] = "Право"
L["RIGHT_DOWN"] = "Направо и вниз"
L["RIGHT_UP"] = "Вправо и вверх"
L["ROWS"] = "Строки"
L["SECOND_ANCHOR"] = "Вторая точка привязки"
L["SELF_BUFFS"] = "Собственные баффы"
L["SELF_BUFFS_DESC"] = "Показать баффы,наложенные самим объектом."
L["SELF_BUFFS_PERMA"] = "Постоянные собственные баффы"
L["SELF_BUFFS_PERMA_DESC"] = "Показать постоянные дебаффы,наложенные самим объектом."
L["SELF_DEBUFFS"] = "Собственные дебаффы"
L["SELF_DEBUFFS_DESC"] = "Показать дебаффы,наложенные самим объектом."
L["SELF_DEBUFFS_PERMA"] = "Постоянные собственные дебаффы"
L["SELF_DEBUFFS_PERMA_DESC"] = "Показывать постоянные баффы, запущенные самим объектом."
L["SEPARATION"] = "Разделение"
L["SHADOW"] = "Тень"
L["SHIFT_CLICK_TO_SHOW_AS_XP"] = "|cffffffffShift-Клик|r показать как панель опыта."
L["SIZE"] = "Размер"
L["SIZE_OVERRIDE"] = "Регулировка размера"
L["SIZE_OVERRIDE_DESC"] = "Если установлено значение 0, то размер элемента будет рассчитываться автоматически."
L["SORT_DIR"] = "Направление сортировки"
L["SORT_METHOD"] = "Способ сортировки"
L["SPACING"] = "Промежуток"
L["STANCE_BAR"] = "Панель стоек"
L["TALKING_HEAD_FRAME"] = "Портрет говорящего NPC"
L["TARGET_FRAME"] = "Рамка цели"
L["TARGET_INFO"] = "Информация о цели"
L["TARGET_INFO_DESC"] = "Отображение подсказки о текущей цели."
L["TARGET_TOT"] = "Цель и Цель-Цели"
L["TEXT_HORIZ_ALIGNMENT"] = "Горизонтальное выравнивание"
L["TEXT_VERT_ALIGNMENT"] = "Вертикальное выравнивание"
L["THREAT_GLOW"] = "Подсветка при угрозе"
L["TIME"] = "Время"
L["TOF_FRAME"] = "Рамка фокуса цели"
L["TOGGLE_ANCHORS"] = "Переместить элементы"
L["TOOLTIP_IDS"] = "ID способностей и предметов"
L["TOOLTIPS"] = "Подсказки"
L["TOP"] = "Сверху"
L["TOP_INSET_SIZE"] = "Размер верхней вкладки"
L["TOP_INSET_SIZE_DESC"] = "Используется классом, альтернативными и дополнительными панелями энергии."
L["TOT_FRAME"] = "Цель и рамка ее цели"
L["TOTEMS"] = "Тотемы"
L["UI_LAYOUT"] = "Оформление интерфейса"
L["UI_LAYOUT_DESC"] = "Изменяет внешний вид рамок игрока и питомца.Также изменится оформление интерфейса."
L["UNITS"] = "Блоки"
L["UNSPENT_TRAIT_POINTS_TOOLTIP"] = "Не использованные очки арта: |cffffffff%s|r"
L["UP"] = "Вверх"
L["USE_BLIZZARD_VEHICLE_UI"] = "Использование интерфейса Blizzard"
L["USE_ICON_AS_INDICATOR"] = "Использовать иконку как индикатор."
L["USE_ICON_AS_INDICATOR_DESC"] = "Цвет и прозрачность иконки будет меняться в зависимости от состояния способности."
L["VEHICLE_EXIT_BUTTON"] = "Кнопка выхода из спец.средства"
L["VEHICLE_SEAT_INDICATOR"] = "Индикатор сиденья транспорт.средства"
L["VERT_GROWTH_DIR"] = "Вертикальное направление роста"
L["VISIBILITY"] = "Видимость"
L["WIDTH"] = "Ширина"
L["WIDTH_OVERRIDE"] = "Регулировка ширины"
L["WORD_WRAP"] = "Перенос слова"
L["X_OFFSET"] = "xСмещение"
L["XP_BAR"] = "Панель опыта"
L["Y_OFFSET"] = "yСмещение"
L["YOURS_FIRST"] = "Ваши в первую очередь"
L["ZONE_ABILITY_BUTTON"] = "Кнопка спец.способности в локации"
L["ZONE_TEXT"] = "Название локации"
