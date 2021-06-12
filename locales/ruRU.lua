-- Contributors: Biowoolf@WoWInterface

local _, ns = ...
local E, L = ns.E, ns.L

-- Lua
local _G = getfenv(0)

--[[ luacheck: globals
	GetLocale
]]

if GetLocale() ~= "ruRU" then return end

L["ACTION_BARS"] = "Панели команд"
L["ADDITIONAL_BAR"] = "Дополнительная панель"
L["ADVENTURE_JOURNAL_DESC"] = "Показывать информацию о сохраненных рейдах."
L["ALT_POWER_BAR"] = "Полоса альт. энергии"
L["ALT_POWER_FORMAT_DESC"] = [=[Введите строку для изменения текста. Для отключения оставьте поле пустым.

Теги:
- |cffffd200[ls:altpower:cur]|r - текущее значение;
- |cffffd200[ls:altpower:max]|r - максимальное значение;
- |cffffd200[ls:altpower:perc]|r - значение в процентах;
- |cffffd200[ls:altpower:cur-max]|r - текущее значение, за которым идет максимальное значение;
- |cffffd200[ls:altpower:cur-perc]|r - текущее значение, за которым идет значение в процентах;
- |cffffd200[ls:color:altpower]|r - цвет.

Если актуальное значение равно максимальному, то только максимальное значение будет показано.

Используйте |cffffd200||r|r для закрытия цветовых тегов.
Используйте |cffffd200[nl]|r для разрыва строки.]=]
L["ALTERNATIVE_POWER"] = "Альт. энергия"
L["ALWAYS_SHOW"] = "Всегда показывать"
L["ANCHOR"] = "Прикрепить к"
L["ANCHOR_TO_CURSOR"] = "Прикрепить к курсору"
L["ARTIFACT_LEVEL_TOOLTIP"] = "Уровень артефакта: |cffffffff%s|r"
L["ARTIFACT_POWER"] = "Сила артефакта"
L["ASCENDING"] = "По возрастанию"
L["AURA"] = "Аура"
L["AURA_FILTERS"] = "Фильтры аур"
L["AURA_TRACKER"] = "Отслеживание аур"
L["AURA_TYPE"] = "Тип ауры"
L["AURAS"] = "Ауры"
L["AUTO"] = "Авто"
L["BAG_SLOTS"] = "Ячейки сумок"
L["BAR"] = "Панель"
L["BAR_1"] = "Панель 1"
L["BAR_2"] = "Панель 2"
L["BAR_3"] = "Панель 3"
L["BAR_4"] = "Панель 4"
L["BAR_5"] = "Панель 5"
L["BAR_COLOR"] = "Цвет полосы"
L["BAR_TEXT"] = "Текст полосы"
L["BLACKLIST"] = "Черный список"
L["BLIZZARD"] = "Blizzard"
L["BONUS_XP_TOOLTIP"] = "Дополнительный опыт: |cffffffff%s|r"
L["BORDER"] = "Граница"
L["BORDER_COLOR"] = "Цвет границы"
L["BOSS"] = "Босс"
L["BOSS_BUFFS"] = "Баффы босса"
L["BOSS_BUFFS_DESC"] = "Показывать баффы, наложенные боссом."
L["BOSS_DEBUFFS"] = "Дебаффы босса"
L["BOSS_DEBUFFS_DESC"] = "Показывать дебаффы, наложенные боссом."
L["BOSS_FRAMES"] = "Рамки боссов"
L["BOTTOM"] = "Снизу"
L["BOTTOM_INSET_SIZE"] = "Размер нижней вставки"
L["BOTTOM_INSET_SIZE_DESC"] = "Используется полосой ресурса."
L["BUFFS"] = "Баффы"
L["BUFFS_AND_DEBUFFS"] = "Баффы и дебаффы"
L["BUTTON"] = "Кнопка"
L["BUTTON_GRID"] = "Сетка кнопок"
L["BUTTONS"] = "Кнопки"
L["CALENDAR"] = "Календарь"
L["CAST_ON_KEY_DOWN"] = "Применять при нажатии"
L["CASTABLE_BUFFS"] = "Наложенные баффы"
L["CASTABLE_BUFFS_DESC"] = "Показывать баффы, наложенные вами."
L["CASTABLE_BUFFS_PERMA"] = "Наложенные постоянные баффы"
L["CASTABLE_BUFFS_PERMA_DESC"] = "Показывать постоянные баффы, наложенные вами."
L["CASTABLE_DEBUFFS"] = "Наложенные дебаффы"
L["CASTABLE_DEBUFFS_DESC"] = "Показывать дебаффы, наложенные вами."
L["CASTABLE_DEBUFFS_PERMA"] = "Наложенные постоянные дебаффы"
L["CASTABLE_DEBUFFS_PERMA_DESC"] = "Показывать постоянные дебаффы, наложенные вами."
L["CASTBAR"] = "Полоса заклинаний"
L["CHANGE"] = "Изменение"
L["CHARACTER_BUTTON_DESC"] = "Показывать информацию о прочности экипировки."
L["CHARACTER_FRAME"] = "Окно персонажа"
L["CLASS_POWER"] = "Классовый ресурс"
L["CLASSIC"] = "Классическое"
L["CLEAN_UP"] = "Очистить"
L["CLEAN_UP_MAIL_DESC"] = "Удаляет все пустые сообщения."
L["CLOCK"] = "Часы"
L["COLLECT_BUTTONS"] = "Собирать кнопки"
L["COLOR_BY_SPEC"] = "Окрашивать в цвет специализации"
L["COLORS"] = "Цвета"
L["COMMAND_BAR"] = "Панель оплота класса"
L["CONFIRM_DELETE"] = "Хотите удалить \"%s\"?"
L["CONFIRM_RESET"] = "Хотите сбросить \"%s\"?"
L["COOLDOWN"] = "Восстановление"
L["COOLDOWN_TEXT"] = "Текст восстановления"
L["COOLDOWNS"] = "Время восстановления"
L["COPY_FROM"] = "Скопировать из"
L["COPY_FROM_DESC"] = "Выберете откуда скопировать настройки."
L["COST_PREDICTION"] = "Прогноз затрат"
L["COST_PREDICTION_DESC"] = "Показывать полосу, представляющую собой затраты на произнесение заклинания. Не работает с мгновенными способностями."
L["COUNT_TEXT"] = "Текст кол-ва стаков"
L["CURSE"] = "Проклятие"
L["CUSTOM_TEXTS"] = "Свой текст"
L["DAILY_QUEST_RESET_TIME_TOOLTIP"] = "Время восстановления ежедневных заданий: |cffffffff%s|r"
L["DAMAGE_ABSORB"] = "Поглощение урона"
L["DAMAGE_ABSORB_FORMAT_DESC"] = [=[Введите строку для изменения текста. Для отключения оставьте поле пустым.

Теги:
- |cffffd200[ls:absorb:damage]|r - текущее значение;
- |cffffd200[ls:color:absorb-damage]|r - цвет.

Используйте |cffffd200||r|r для закрытия цветовых тегов.
Используйте |cffffd200[nl]|r для разрыва строки.]=]
L["DAMAGE_ABSORB_TEXT"] = "Текст поглощения урона"
L["DAYS"] = "Days"
L["DEAD"] = "Мертвый"
L["DEBUFF"] = "Дебафф"
L["DEBUFF_TYPE"] = "Тип дебаффа"
L["DEBUFFS"] = "Дебаффы"
L["DESATURATION"] = "Обесцвечивание"
L["DESCENDING"] = "По убыванию"
L["DETACH_FROM_FRAME"] = "Отсоединить от рамки"
L["DIFFICULT"] = "Сложный"
L["DIFFICULTY"] = "Сложность"
L["DIFFICULTY_FLAG"] = "Флаг режима сложности"
L["DIGSITE_BAR"] = "Полоса прогресса раскопок"
L["DISABLE_MOUSE"] = "Отключить мышь"
L["DISABLE_MOUSE_DESC"] = "Игнорировать мышь."
L["DISEASE"] = "Болезнь"
L["DISPELLABLE_BUFFS"] = "Рассеиваемые баффы"
L["DISPELLABLE_BUFFS_DESC"] = "Показывать баффы, которые вы можете украсть или рассеять со своей цели."
L["DISPELLABLE_DEBUFF_ICONS"] = "Иконки рассеиваемых дебаффов"
L["DISPELLABLE_DEBUFFS"] = "Рассеиваемые дебаффы"
L["DISPELLABLE_DEBUFFS_DESC"] = "Показывать дебаффы, которые вы можете рассеять со своей цели."
L["DOWN"] = "Вниз"
L["DRAG_KEY"] = "Кнопка для перетаскивания"
L["DUNGEONS_BUTTON_DESC"] = "Показывать информацию о 'Призыве к оружию'."
L["DURABILITY_FRAME"] = "Рамка прочности"
L["ENEMY_UNITS"] = "Вражеские юниты"
L["ENHANCED_TOOLTIPS"] = "Подробные подсказки"
L["EVENTS"] = "События"
L["EXP_THRESHOLD"] = "Порог истечения"
L["EXPERIENCE"] = "Опыт"
L["EXPERIENCE_NORMAL"] = "Нормальный"
L["EXPERIENCE_RESTED"] = "Отдохнувший"
L["EXPIRATION"] = "Истечение"
L["EXTRA_ACTION_BUTTON"] = "Кнопка доп. действия"
L["FACTION_NEUTRAL"] = "Нейтральный"
L["FADE_IN_DURATION"] = "Продолжительность появления"
L["FADE_OUT_DELAY"] = "Задержка исчезновения"
L["FADE_OUT_DURATION"] = "Продолжительность исчезновения"
L["FADING"] = "Затухание"
L["FILTER_SETTINGS"] = "Настройки фильтра"
L["FILTERS"] = "Фильтры"
L["FLAG"] = "Флаг"
L["FLYOUT_DIR"] = "Направление раскрытия"
L["FOCUS_FRAME"] = "Рамка фокуса"
L["FOCUS_TOF"] = "Фокус и цель фокуса"
L["FONT"] = "Шрифт"
L["FONTS"] = "Шрифты"
L["FORMAT"] = "Формат"
L["FRAME"] = "Рамка"
L["FREE_BAG_SLOTS_TOOLTIP"] = "Свободные ячейки: |cffffffff%s|r"
L["FRIENDLY_TERRITORY"] = "Дружелюбная территория"
L["FRIENDLY_UNITS"] = "Дружественные юниты"
L["FUNC"] = "Функция"
L["GAIN"] = "Получение"
L["GAIN_LOSS_THRESHOLD"] = "Порог изменения"
L["GAIN_LOSS_THRESHOLD_DESC"] = "Если изменение ресурса выше данного значения (в процентах), то оно будет анимировано. Установите на 100, чтобы отключить."
L["GLOSS"] = "Глянец"
L["GM_FRAME"] = "Панель статуса запроса к ГМ"
L["GOLD"] = "Золото"
L["GROWTH_DIR"] = "Направление роста"
L["HEAL_ABSORB"] = "Поглощение исцеления"
L["HEAL_ABSORB_FORMAT_DESC"] = [=[Введите строку для изменения текста. Для отключения оставьте поле пустым.

Теги:
- |cffffd200[ls:absorb:heal]|r - текущее значение;
- |cffffd200[ls:color:absorb-heal]|r - цвет.

Используйте |cffffd200||r|r для закрытия цветовых тегов.
Используйте |cffffd200[nl]|r для разрыва строки.]=]
L["HEAL_ABSORB_TEXT"] = "Текст поглощения исцеления"
L["HEAL_PREDICTION"] = "Поступающее исцеление"
L["HEALER_BUFFS"] = "Баффы лекаря"
L["HEALER_BUFFS_DESC"] = "Показывать баффы, наложенные лекарем."
L["HEALER_DEBUFFS"] = "Дебаффы лекаря"
L["HEALER_DEBUFFS_DESC"] = "Показывать дебаффы, наложенные лекарем."
L["HEALTH"] = "Здоровье"
L["HEALTH_FORMAT_DESC"] = [=[Введите строку для изменения текста. Для отключения оставьте поле пустым.

Теги:
- |cffffd200[ls:health:cur]|r - текущее значение;
- |cffffd200[ls:health:perc]|r - значение в процентах;
- |cffffd200[ls:health:cur-perc]|r - текущее значение, за которым идет значение в процентах;
- |cffffd200[ls:health:deficit]|r - нехватка.

Если актуальное значение равно максимальному, то только максимальное значение будет показано.

Используйте |cffffd200[nl]|r для разрыва строки.]=]
L["HEALTH_TEXT"] = "Текст здоровья"
L["HEIGHT"] = "Высота"
L["HONOR"] = "Честь"
L["HONOR_LEVEL_TOOLTIP"] = "Уровень чести: |cffffffff%d|r"
L["HOSTILE_TERRITORY"] = "Враждебная территория"
L["HOURS"] = "Часы"
L["ICON"] = "Иконка"
L["IMPOSSIBLE"] = "Невозможный"
L["INDEX"] = "Индекс"
L["INSPECT_INFO"] = "Информация осмотра"
L["INSPECT_INFO_DESC"] = "Отображение специализации и уровня предметов игрока. Эти данные могут быть доступны не сразу."
L["INVALID_EVENTS_ERR"] = "Попытка использовать недопустимые события: %s."
L["INVALID_TAGS_ERR"] = "Попытка использовать недопустимые теги: %s."
L["INVENTORY_BUTTON"] = "Инвентарь"
L["INVENTORY_BUTTON_DESC"] = "Показывать информацию о валютах."
L["INVENTORY_BUTTON_RCLICK_TOOLTIP"] = "|cffffffffЩелкните ПКМ|r, чтобы отобразить ячейки сумок."
L["ITEM_COUNT"] = "Кол-во предметов"
L["ITEM_COUNT_DESC"] = "Отображать количество предметов в вашем банке и сумках."
L["KEYBIND_TEXT"] = "Текст клавиш"
L["LATENCY"] = "Задержка"
L["LATENCY_HOME"] = "Локальная"
L["LATENCY_WORLD"] = "Глобальная"
L["LATER"] = "Позже"
L["LEFT"] = "Влево"
L["LEFT_DOWN"] = "Влево и вниз"
L["LEFT_UP"] = "Влево и вверх"
L["LEVEL_TOOLTIP"] = "Уровень: |cffffffff%d|r"
L["LOCK"] = "Заблокировать"
L["LOCK_BUTTONS"] = "Заблокировать кнопки"
L["LOCK_BUTTONS_DESC"] = "Предотвращает случайное перемещение или удаление способностей с панелей команд."
L["LOOT_ALL"] = "Забрать всю добычу"
L["LOSS"] = "Потеря"
L["M_SS_THRESHOLD"] = "Порог М:СС"
L["M_SS_THRESHOLD_DESC"] = "Если оставшееся время восстановления ниже данного значения (в секундах), то оно будет показано в формате М:СС. Установите на 0, чтобы отключить."
L["MACRO_TEXT"] = "Текст макросов"
L["MAGIC"] = "Магия"
L["MAIN_BAR"] = "Главная панель"
L["MAINMENU_BUTTON_DESC"] = "Показывать информацию о производительности."
L["MAINMENU_BUTTON_HOLD_TOOLTIP"] = "|cffffffffЗажмите Shift|r, чтобы показать статистику используемой памяти."
L["MAX_ALPHA"] = "Макс. прозрачность"
L["MEMORY"] = "Память"
L["MICRO_BUTTONS"] = "Микроменю"
L["MIN_ALPHA"] = "Мин. прозрачность"
L["MINIMAP_BUTTONS"] = "Кнопки мини-карты"
L["MINIMAP_BUTTONS_TOOLTIP"] = "Щелкните, чтобы показать кнопки мини-карты."
L["MINUTES"] = "Минуты"
L["MIRROR_TIMER"] = "Таймеры"
L["MIRROR_TIMER_DESC"] = "Индикаторы дыхания, усталости и прочего."
L["MIRROR_WIDGETS"] = "Отразить виджеты"
L["MIRROR_WIDGETS_DESC"] = "Изменяет порядок иконок статуса, полосы заклинаний и PvP иконки."
L["MODE"] = "Режим"
L["MOUNT_AURAS"] = "Ауры средств передвижений"
L["MOUNT_AURAS_DESC"] = "Показывать ауры средств передвижений."
L["MOVER_BUTTONS_DESC"] = "|cffffffffЩелкните|r, чтобы отобразить кнопки."
L["MOVER_CYCLE_DESC"] = "|cffffffffНажмите Alt|r, чтобы переключиться между рамками под курсором."
L["MOVER_RESET_DESC"] = "|cffffffffЗажмите Shift и щелкните|r, чтобы сбросить позицию."
L["NAME"] = "Название"
L["NAME_FORMAT_DESC"] = [=[Введите строку для изменения текста. Для отключения оставьте поле пустым.

Теги:
- |cffffd200[ls:name]|r - имя;
- |cffffd200[ls:name:5]|r - имя, сокращенное до 5 символов;
- |cffffd200[ls:name:10]|r - имя, сокращенное до 10 символов;
- |cffffd200[ls:name:15]|r - имя, сокращенное до 15 символов;
- |cffffd200[ls:name:20]|r - имя, сокращенное до 20 символов;
- |cffffd200[ls:server]|r - (*) тег для игроков с других миров;
- |cffffd200[ls:color:class]|r - цвет класса;
- |cffffd200[ls:color:reaction]|r - цвет отношения;
- |cffffd200[ls:color:difficulty]|r - цвет сложности.

Используйте |cffffd200||r|r для закрытия цветовых тегов.
Используйте |cffffd200[nl]|r для разрыва строки.]=]
L["NAME_TAKEN_ERR"] = "Имя занято."
L["NO_SEPARATION"] = "Без разделения"
L["NOTHING_TO_SHOW"] = "Нечего показать."
L["NUM_BUTTONS"] = "Количество кнопок"
L["NUM_ROWS"] = "Количество строк"
L["NUMERIC"] = "Цифры"
L["NUMERIC_PERCENTAGE"] = "Цифры и проценты"
L["OBJECTIVE_TRACKER"] = "Список заданий"
L["OOM"] = "Нехватка ресурса"
L["OOM_INDICATOR"] = "Индикатор нехватки ресурса"
L["OOR"] = "Вне зоны досягаемости"
L["OOR_INDICATOR"] = "Индикатор недосягаемости цели"
L["OPEN_CONFIG"] = "Настройки"
L["ORBS"] = "Шары"
L["OTHER"] = "Другое"
L["OTHERS_FIRST"] = "Чужие в первую очередь"
L["OTHERS_HEALING"] = "Чужое исцеление"
L["OUTLINE"] = "Контур"
L["PER_ROW"] = "Количество в строке"
L["PET_BAR"] = "Панель питомца"
L["PET_BATTLE_BAR"] = "Панель битвы питомцев"
L["PET_CASTBAR"] = "Полоса заклинаний питомца"
L["PET_FRAME"] = "Рамка питомца"
L["PLAYER_FRAME"] = "Рамка игрока"
L["PLAYER_PET"] = "Игрок и питомец"
L["PLAYER_TITLE"] = "Звание игрока"
L["POINT"] = "Точка"
L["POINT_DESC"] = "Точка фиксации объекта."
L["POISON"] = "Яд"
L["PORTRAIT"] = "Портрет"
L["POSITION"] = "Расположение"
L["POWER"] = "Ресурс"
L["POWER_COST"] = "Затраты энергии"
L["POWER_FORMAT_DESC"] = [=[Введите строку для изменения текста. Для отключения оставьте поле пустым.

Теги:
- |cffffd200[ls:power:cur]|r - текущее значение;
- |cffffd200[ls:power:max]|r - максимальное значение;
- |cffffd200[ls:power:perc]|r - значение в процентах;
- |cffffd200[ls:power:cur-max]|r - текущее значение, за которым идет максимальное значение;
- |cffffd200[ls:power:cur-perc]|r - текущее значение, за которым идет значение в процентах;
- |cffffd200[ls:power:deficit]|r - нехватка;
- |cffffd200[ls:color:power]|r - цвет.

Если актуальное значение равно максимальному, то только максимальное значение будет показано.

Используйте |cffffd200||r|r для закрытия цветовых тегов.
Используйте |cffffd200[nl]|r для разрыва строки.]=]
L["POWER_TEXT"] = "Текст ресурса"
L["PREDICTION"] = "Прогноз"
L["PREVIEW"] = "Предпросмотр"
L["PROGRESS_BAR_ANIMATED"] = "Анимированные"
L["PROGRESS_BAR_SMOOTH"] = "Плавные"
L["PROGRESS_BARS"] = "Полосы прогресса"
L["PVP_ICON"] = "PvP иконка"
L["QUESTLOG_BUTTON_DESC"] = "Показывать время восстановления ежедневных заданий."
L["QUEUE"] = "Очередь"
L["RAID_ICON"] = "Метка цели"
L["RCLICK_SELFCAST"] = "Применять к себе через ПКМ"
L["REACTION"] = "Реакция"
L["RELATIVE_POINT"] = "Относительная точка"
L["RELATIVE_POINT_DESC"] = "Точка, к которой объект будет присоединён."
L["RELOAD_NOW"] = "Перезагрузить сейчас"
L["RELOAD_UI_ON_CHAR_SETTING_CHANGE_POPUP"] = "Вы только что изменили настройку, используемую только этим персонажем. Эти параметры независимы от ваших профилей. Чтобы изменения вступили в силу, необходимо перезагрузить интерфейс."
L["RELOAD_UI_WARNING"] = "Перезагрузите интерфейс после завершения настройки аддона."
L["RESTORE_DEFAULTS"] = "Сбросить настройки"
L["RESTRICTED_MODE"] = "Ограниченный режим"
L["RESTRICTED_MODE_DESC"] = [=[Включает оформление, анимацию и динамическое изменение размера главной панели команд.

|cffdc4436Внимание!|r Многие настройки панелей команд будут не доступны в этом режиме.|r]=]
L["RIGHT"] = "Право"
L["RIGHT_DOWN"] = "Направо и вниз"
L["RIGHT_UP"] = "Вправо и вверх"
L["ROWS"] = "Строки"
L["RUNES"] = "Руны"
L["RUNES_BLOOD"] = "Руны крови"
L["RUNES_FROST"] = "Руны льда"
L["RUNES_UNHOLY"] = "Руны нечестивости"
L["S_MS_THRESHOLD"] = "Порог С:МС"
L["S_MS_THRESHOLD_DESC"] = "Если оставшееся время восстановления ниже данного значения (в секундах), то оно будет показано в формате С:МС"
L["SECOND_ANCHOR"] = "Вторая точка привязки"
L["SECONDS"] = "Секунды"
L["SELF_BUFFS"] = "Собственные баффы"
L["SELF_BUFFS_DESC"] = "Показывать баффы, наложенные юнитом на самого себя."
L["SELF_BUFFS_PERMA"] = "Постоянные собственные баффы"
L["SELF_BUFFS_PERMA_DESC"] = "Показывать постоянные баффы, наложенные юнитом на самого себя."
L["SELF_DEBUFFS"] = "Собственные дебаффы"
L["SELF_DEBUFFS_DESC"] = "Показывать дебаффы, наложенные юнитом на самого себя."
L["SELF_DEBUFFS_PERMA"] = "Постоянные собственные дебаффы"
L["SELF_DEBUFFS_PERMA_DESC"] = "Показывать постоянные дебаффы, наложенные юнитом на самого себя."
L["SEPARATION"] = "Разделение"
L["SHADOW"] = "Тень"
L["SHIFT_CLICK_TO_SHOW_AS_XP"] = "|cffffffffЗажмите Shift и щелкните|r, чтобы показывать как панель опыта."
L["SHOW_ON_MOUSEOVER"] = "Показывать при наведении"
L["SHOW_TOOLTIP"] = "Показывать подсказку"
L["SIZE"] = "Размер"
L["SIZE_OVERRIDE"] = "Регулировка размера"
L["SIZE_OVERRIDE_DESC"] = "Если установлено на 0, то размер элемента будет рассчитан автоматически."
L["SORT_DIR"] = "Направление сортировки"
L["SORT_METHOD"] = "Способ сортировки"
L["SPACING"] = "Отступ"
L["SPELL_CAST"] = "Применяемые"
L["SPELL_CHANNELED"] = "Поддерживаемые"
L["SPELL_FAILED"] = "Неудачные"
L["SPELL_UNINTERRUPTIBLE"] = "Непрерываемые"
L["SQUARE_MINIMAP"] = "Квадратная мини-карта"
L["STAGGER_HIGH"] = "Пошатывание (высокое)"
L["STAGGER_LOW"] = "Пошатывание (низкое)"
L["STAGGER_MEDIUM"] = "Пошатывание (среднее)"
L["STANCE_BAR"] = "Панель стоек"
L["STANDARD"] = "Стандартный"
L["STYLE"] = "Стиль"
L["TAG_VARS"] = "Переменные тегов"
L["TAGS"] = "Теги"
L["TALKING_HEAD_FRAME"] = "Рамка говорящего NPC"
L["TANK_BUFFS"] = "Баффы танка"
L["TANK_BUFFS_DESC"] = "Показывать баффы, наложенные танком."
L["TANK_DEBUFFS"] = "Дебаффы танка"
L["TANK_DEBUFFS_DESC"] = "Показывать дебаффы, наложенные танком."
L["TAPPED"] = "Чужая цель"
L["TARGET_FRAME"] = "Рамка цели"
L["TARGET_INFO"] = "Информация о цели"
L["TARGET_INFO_DESC"] = "Показывать цель текущей цели в подсказке."
L["TARGET_TOT"] = "Цель и цель цели"
L["TEMP_ENCHANT"] = "Временное улучшение"
L["TEXT"] = "Текст"
L["TEXT_HORIZ_ALIGNMENT"] = "Горизонтальное выравнивание"
L["TEXT_VERT_ALIGNMENT"] = "Вертикальное выравнивание"
L["THREAT_GLOW"] = "Подсветка уровня угрозы"
L["TIME"] = "Время"
L["TOF_FRAME"] = "Рамка цели фокуса"
L["TOGGLE_ANCHORS"] = "Показать/скрыть фиксаторы"
L["TOOLTIP_IDS"] = "ID способностей и предметов"
L["TOOLTIPS"] = "Подсказки"
L["TOP"] = "Сверху"
L["TOP_INSET_SIZE"] = "Размер верхней вставки"
L["TOP_INSET_SIZE_DESC"] = "Используется классовой, альтернативной и дополнительной полосами ресурса."
L["TOT_FRAME"] = "Рамка цели цели"
L["TOTEMS"] = "Тотемы"
L["TRIVIAL"] = "Тривиальный"
L["UI_LAYOUT"] = "Расположение интерфейса"
L["UI_LAYOUT_DESC"] = "Изменяет внешний вид рамок игрока и питомца. Также изменится расположение элементов интерфейса."
L["UNITS"] = "Юниты"
L["UNSPENT_TRAIT_POINTS_TOOLTIP"] = "Неиспользованные очки артефакта: |cffffffff%s|r"
L["UNUSABLE"] = "Невозможно использовать"
L["UP"] = "Вверх"
L["USABLE"] = "Возможно использовать"
L["USE_BLIZZARD_VEHICLE_UI"] = "Использовать интерфейса транспорта от Blizzard"
L["USER_CREATED"] = "Пользовательский"
L["VALUE"] = "Значение"
L["VAR"] = "Переменная"
L["VEHICLE_EXIT_BUTTON"] = "Кнопка спешивания"
L["VEHICLE_SEAT_INDICATOR"] = "Индикатор сидений транспорта"
L["VERY_DIFFICULT"] = "Очень сложный"
L["VISIBILITY"] = "Видимость"
L["WIDTH"] = "Ширина"
L["WIDTH_OVERRIDE"] = "Регулировка ширины"
L["WORD_WRAP"] = "Перенос слов"
L["X_OFFSET"] = "Смещение по X"
L["XP_BAR"] = "Полоса опыта"
L["Y_OFFSET"] = "Смещение по Y"
L["YOUR_HEALING"] = "Ваше исцеление"
L["YOURS_FIRST"] = "Ваши в первую очередь"
L["ZONE_ABILITY_BUTTON"] = "Кнопка доп. способности в зоне"
L["ZONE_TEXT"] = "Название зоны"
