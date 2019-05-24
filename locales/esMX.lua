-- Contributors: Gotxiko@GitHub a.k.a. Gotzon@Curse
-- NOTE: Copied from esES

local _, ns = ...
local E, L = ns.E, ns.L

-- Lua
local _G = getfenv(0)

--[[ luacheck: globals
	GetLocale
]]

if GetLocale() ~= "esMX" then return end

L["ACTION_BARS"] = "Barras de acción"
L["ADDITIONAL_BAR"] = "Barra adicional"
L["ADVENTURE_JOURNAL_DESC"] = "Mostrar información de registros de banda."
L["ALT_POWER_BAR"] = "Barra de poder alternativo"
L["ALT_POWER_FORMAT_DESC"] = [=[Escribe un "String" para cambiar el texto. Para desactivarlo, deja el campo en blanco.

Etiquetas:
- |cffffd200[ls:altpower:cur]|r - el valor actual;
- |cffffd200[ls:altpower:max]|r - el valor máximo;
- |cffffd200[ls:altpower:perc]|r - el porcentaje;
- |cffffd200[ls:altpower:cur-max]|r - el valor actual seguido del valor máximo;
- |cffffd200[ls:altpower:cur-perc]|r - el valor actual seguido del porcentaje;
- |cffffd200[ls:color:altpower]|r - color.

Si el valor actual es igual al valor máximo, solo se mostrará el valor máximo.

Utiliza |cffffd200||r|r para cerrar las etiquetas de color.
Utiliza |cffffd200[nl]|r para saltos de línea.]=]
L["ALTERNATIVE_POWER"] = "Poder alternativo"
L["ALWAYS_SHOW"] = "Mostrar siempre"
L["ANCHOR"] = "Adjuntar a"
L["ANCHOR_TO_CURSOR"] = "Anclar al cursor"
L["ARTIFACT_LEVEL_TOOLTIP"] = "Nivel de artefacto: |cffffffff%s|r"
L["ARTIFACT_POWER"] = "Poder de artefacto"
L["ASCENDING"] = "Ascendente"
L["AURA"] = "Aura"
--[[ L["AURA_FILTERS"] = "Aura Filters" ]]
L["AURA_TRACKER"] = "Seguidor de auras"
L["AURA_TYPE"] = "Tipo de Aura"
L["AURAS"] = "Auras"
L["AUTO"] = "Auto"
L["BAG_SLOTS"] = "Huecos de bolsas"
L["BAR"] = "Barra"
L["BAR_1"] = "Barra 1"
L["BAR_2"] = "Barra 2"
L["BAR_3"] = "Barra 3"
L["BAR_4"] = "Barra 4"
L["BAR_5"] = "Barra 5"
L["BAR_COLOR"] = "Color de la barra"
L["BAR_TEXT"] = "Texto de la barra"
--[[ L["BLACKLIST"] = "Blacklist" ]]
L["BLIZZARD"] = "Blizzard"
L["BONUS_XP_TOOLTIP"] = "Bonus de EXP: |cffffffff%s|r"
L["BORDER"] = "Borde"
L["BORDER_COLOR"] = "Color del borde"
L["BOSS"] = "Jefe"
L["BOSS_BUFFS"] = "Beneficios del Jefe"
L["BOSS_BUFFS_DESC"] = "Muestra los beneficios lanzados por el Jefe."
L["BOSS_DEBUFFS"] = "Perjuicios del Jefe"
L["BOSS_DEBUFFS_DESC"] = "Muestra los perjuicios lanzados por el Jefe."
L["BOSS_FRAMES"] = "Marco de Jefe"
L["BOTTOM"] = "Abajo"
L["BOTTOM_INSET_SIZE"] = "Tamaño del inset inferior"
L["BOTTOM_INSET_SIZE_DESC"] = "Utilizado por la barra de recursos."
L["BUFFS"] = "Beneficios"
L["BUFFS_AND_DEBUFFS"] = "Beneficios y perjuicios"
L["BUTTON"] = "Botón"
L["BUTTON_GRID"] = "Cuadrícula de botones"
L["CALENDAR"] = "Calendario"
L["CAST_ON_KEY_DOWN"] = "Lanzar al presionar tecla"
L["CASTABLE_BUFFS"] = "Beneficios lanzables"
L["CASTABLE_BUFFS_DESC"] = "Muestra los beneficios lanzados por ti."
L["CASTABLE_BUFFS_PERMA"] = "Beneficios permanentes lanzables"
L["CASTABLE_BUFFS_PERMA_DESC"] = "Muestra los beneficios permanentes lanzados por ti."
L["CASTABLE_DEBUFFS"] = "Perjuicios lanzables"
L["CASTABLE_DEBUFFS_DESC"] = "Muestra los perjuicios lanzados por ti."
L["CASTABLE_DEBUFFS_PERMA"] = "Perjuicios permanentes lanzables"
L["CASTABLE_DEBUFFS_PERMA_DESC"] = "Muestra los perjuicios permanentes lanzados por ti."
L["CASTBAR"] = "Barra de lanzamiento"
L["CHANGE"] = "Cambio"
L["CHARACTER_BUTTON_DESC"] = "Muestra la durabilidad del equipo."
--[[ L["CHARACTER_FRAME"] = "Character Frame" ]]
L["CLASS_POWER"] = "Poder de clase"
L["CLASSIC"] = "Clásico"
--[[ L["CLEAN_UP"] = "Clean Up" ]]
--[[ L["CLEAN_UP_MAIL_DESC"] = "Removes all empty messages." ]]
L["CLOCK"] = "Reloj"
L["COLOR_BY_SPEC"] = "Color por Especialización"
L["COLORS"] = "Colores"
L["COMMAND_BAR"] = "Barra de comandos"
--[[ L["CONFIRM_DELETE"] = "Do you wish to delete \"%s\"?" ]]
--[[ L["CONFIRM_RESET"] = "Do you wish to reset \"%s\"?" ]]
L["COOLDOWN"] = "Enfriamiento"
L["COOLDOWN_TEXT"] = "Texto de enfriamiento"
L["COPY_FROM"] = "Copiar de"
L["COPY_FROM_DESC"] = "Selecciona una unidad de la que copiar la configuración."
L["COST_PREDICTION"] = "Predicción de coste"
L["COST_PREDICTION_DESC"] = "Muestra una barra que representa el coste de un hechizo. No funciona con hechizos de lanzamiento instantáneo."
L["COUNT_TEXT"] = "Texto de conteo"
L["CURSE"] = "Maldición"
L["DAILY_QUEST_RESET_TIME_TOOLTIP"] = "Reinicio de misión diaria: |cffffffff%s|r"
L["DAMAGE_ABSORB"] = "Absorción de daño"
L["DAMAGE_ABSORB_FORMAT_DESC"] = [=[Provide a string to change the text. To disable, leave the field blank.
Escribe un 'String' para cambiar el texto. Para desactivarlo, deja el campo vacío.

Etiquetas:
- |cffffd200[ls:absorb:damage]|r - el valor actual;
- |cffffd200[ls:color:absorb-damage]|r - el color.

Utiliza |cffffd200||r|r para cerrar las etiquetas de color.
Utiliza |cffffd200[nl]|r para insertar un salto de línea.]=]
L["DAMAGE_ABSORB_TEXT"] = "Texto de absorción de daño"
L["DAYS"] = "Días"
L["DEAD"] = "Muerto"
L["DEBUFF"] = "Perjuicio"
L["DEBUFF_TYPE"] = "Tipo de perjuicio"
L["DEBUFFS"] = "Perjuicios"
L["DESATURATION"] = "Desaturación"
L["DESCENDING"] = "Descendiente"
L["DETACH_FROM_FRAME"] = "Despegar del cuadro."
L["DIFFICULT"] = "Difícil"
L["DIFFICULTY"] = "Dificultad"
L["DIFFICULTY_FLAG"] = "Bandera de dificultad"
L["DIGSITE_BAR"] = "Barra de progreso de excavaciones"
L["DISABLE_MOUSE"] = "Desactivar ratón"
L["DISABLE_MOUSE_DESC"] = "Ignorar eventos de ratón."
L["DISEASE"] = "Enfermedad"
L["DISPELLABLE_BUFFS"] = "Beneficios disipables"
L["DISPELLABLE_BUFFS_DESC"] = "Muestra los beneficios que puedes robar o purgar del objetivo."
L["DISPELLABLE_DEBUFF_ICONS"] = "Iconos de perjucios disipables."
L["DISPELLABLE_DEBUFFS"] = "Perjuicios disipables"
L["DISPELLABLE_DEBUFFS_DESC"] = "Muestra perjuicios que puedes disipar del objetivo."
L["DOWN"] = "Abajo"
L["DRAG_KEY"] = "Tecla de arrastre"
L["DUNGEONS_BUTTON_DESC"] = "Mostrar información de \"Llamada a las armas\""
L["DURABILITY_FRAME"] = "Marco de durabilidad"
L["ENEMY_UNITS"] = "Unidades enemigas"
L["ENHANCED_TOOLTIPS"] = "Descripciones emergentes mejoradas"
--[[ L["EVENTS"] = "Events" ]]
L["EXP_THRESHOLD"] = "Límite de expiración"
L["EXP_THRESHOLD_DESC"] = "El límite (en segundos) bajo el que el tiempo mínimo será mostrado como número decimal."
L["EXPERIENCE"] = "Experiencia"
L["EXPERIENCE_NORMAL"] = "Normal"
L["EXPERIENCE_RESTED"] = "Descansado"
L["EXPIRATION"] = "Expiración"
L["EXTRA_ACTION_BUTTON"] = "Botón de acción extra"
L["FACTION_NEUTRAL"] = "Neutral"
L["FADE_IN_DELAY"] = "Retraso de aparición"
L["FADE_IN_DURATION"] = "Duración de aparición"
L["FADE_OUT_DELAY"] = "Retraso de desvanecimiento"
L["FADE_OUT_DURATION"] = "Duración de desvanecimiento"
L["FADING"] = "Desvanecimiento"
L["FILTER_SETTINGS"] = "Configuración de filtros"
L["FILTERS"] = "Filtros"
L["FLAG"] = "Bandera"
L["FLYOUT_DIR"] = "Dirección"
L["FOCUS_FRAME"] = "Marco de foco"
L["FOCUS_TOF"] = "Foco & OdF"
L["FORMAT"] = "Formato"
L["FRAME"] = "Marco"
L["FREE_BAG_SLOTS_TOOLTIP"] = "Huecos de bolsa libres: |cffffffff%s|r"
L["FRIENDLY_TERRITORY"] = "Territorio amistoso"
L["FRIENDLY_UNITS"] = "Unidades amistosas"
--[[ L["FUNC"] = "Function" ]]
L["GAIN"] = "Ganancia"
L["GAIN_LOSS_THRESHOLD"] = "Umbral de ganancia/pérdida"
L["GAIN_LOSS_THRESHOLD_DESC"] = "El umbral (en porcentaje) sobre el que la ganancia o pérdida de recursos contará con animación. Establecer en 100 para desactivar."
L["GM_FRAME"] = "Indicador del estado del tíquet."
L["GOLD"] = "Oro"
L["GROWTH_DIR"] = "Dirección de crecimiento"
L["HEAL_ABSORB"] = "Absorción de sanación"
L["HEAL_ABSORB_FORMAT_DESC"] = [=[Escribe un "string" para cambiar el texto. Para desactivarlo, deja el campo en blanco.

Etiquetas:
- |cffffd200[ls:absorb:heal]|r - el valor máximo;
- |cffffd200[ls:color:absorb-heal]|r - el color.

Utiliza |cffffd200||r|r para cerrar las etiquetas de color.
Utiliza |cffffd200[nl]|r para saltos de línea.]=]
L["HEAL_ABSORB_TEXT"] = "Texto de absorción de sanación"
L["HEAL_PREDICTION"] = "Predicción de sanaciones"
--[[ L["HEALER_BUFFS"] = "Healer Buffs" ]]
--[[ L["HEALER_BUFFS_DESC"] = "Show buffs applied by healers." ]]
--[[ L["HEALER_DEBUFFS"] = "Healer Debuffs" ]]
--[[ L["HEALER_DEBUFFS_DESC"] = "Show debuffs applied by healers." ]]
L["HEALTH"] = "Salud"
L["HEALTH_FORMAT_DESC"] = [=[Escribe un "string" para cambiar el texto. Para desactivarlo, deja el campo en blanco.

Etiquetas:
- |cffffd200[ls:health:cur]|r - el valor máximo;
- |cffffd200[ls:health:perc]|r - el porcentaje;
- |cffffd200[ls:health:cur-perc]|r - el valora actual seguido del porcentaje;
- |cffffd200[ls:health:deficit]|r - el valor de déficit.

Si el valor actual es igual al máximo, sólo se mostrará el valor máximo.

Utiliza |cffffd200[nl]|r para saltos de línea.]=]
L["HEALTH_TEXT"] = "Texto de salud"
L["HEIGHT"] = "Altura"
L["HONOR"] = "Honor"
L["HONOR_LEVEL_TOOLTIP"] = "Nivel de Honor: |cffffffff%d|r"
L["HOSTILE_TERRITORY"] = "Territorio hostil"
L["HOURS"] = "Horas"
L["ICON"] = "Icono"
L["IMPOSSIBLE"] = "Imposible"
L["INDEX"] = "Índice"
L["INSPECT_INFO"] = "Información de inspección"
L["INSPECT_INFO_DESC"] = "Muestra la especialización y nivel de objeto del objetivo actual en la descripción emergente. La información puede tardar."
--[[ L["INVALID_EVENTS_ERR"] = "Attempted to use invalid events: %s." ]]
L["INVALID_TAGS_ERR"] = "Intento de uso de etiquetas no válidas: %s."
L["INVENTORY_BUTTON"] = "Inventario"
L["INVENTORY_BUTTON_DESC"] = "Mostrar información de monedas."
L["INVENTORY_BUTTON_RCLICK_TOOLTIP"] = "|cffffffffRight-Click|r para mostrar bolsas."
L["ITEM_COUNT"] = "Cantidad"
L["ITEM_COUNT_DESC"] = "Muestra la cantidad del objeto que posees en el banco y bolsas."
L["KEYBIND_TEXT"] = "Texto de keybinds"
L["LATENCY"] = "Latencia"
L["LATENCY_HOME"] = "Casa"
L["LATENCY_WORLD"] = "Mundo"
L["LATER"] = "Después"
L["LEFT"] = "Izquierda"
L["LEFT_DOWN"] = "Izquierda y abajo"
L["LEFT_UP"] = "Izquierda y arriba"
L["LEVEL_TOOLTIP"] = "Nivel: |cffffffff%d|r"
L["LOCK"] = "Bloquear"
L["LOCK_BUTTONS"] = "Bloquear botones"
L["LOCK_BUTTONS_DESC"] = "Impide el movimiento de hechizos y habilidades de las barras de acción."
L["LOOT_ALL"] = "Despojar todo"
L["LOSS"] = "Pérdida"
L["M_SS_THRESHOLD"] = "M:SS Límite"
L["M_SS_THRESHOLD_DESC"] = "El límite (en segundos) bajo el que el tiempo restante se mostrará en formato M:SS. Establecer en 0 para desactivar."
L["MACRO_TEXT"] = "Texto de macro"
L["MAGIC"] = "Magia"
L["MAIN_BAR"] = "Barra principal"
L["MAINMENU_BUTTON_DESC"] = "Mostrar información de rendimiento."
L["MAINMENU_BUTTON_HOLD_TOOLTIP"] = "|cffffffffMantén Shift|r para mostrar uso de memoria."
L["MAX_ALPHA"] = "Alpha máx."
L["MEMORY"] = "Memoria"
L["MICRO_BUTTONS"] = "Micromenú"
L["MIN_ALPHA"] = "Alpha mín."
L["MINUTES"] = "Minutos"
L["MIRROR_TIMER"] = "Mirror Timers"
L["MIRROR_TIMER_DESC"] = "Respiración, fatiga y otros indicadores."
L["MODE"] = "Modo"
L["MOUNT_AURAS"] = "Auras de montura"
L["MOUNT_AURAS_DESC"] = "Mostrar auras de montura."
L["MOVER_BUTTONS_DESC"] = "|cffffffffClick|r para alternar botones."
L["MOVER_CYCLE_DESC"] = "Presiona |cffffffffAlt|r para alternar entre los marcos bajo el cursor."
L["MOVER_RESET_DESC"] = "|cffffffffShift-Click|r para reiniciar la posición."
L["NAME"] = "Nombre"
L["NAME_FORMAT_DESC"] = [=[Escribe un 'String' para cambiar el texto. Para desactivarlo, deja el campo en blanco.

Etiquetas:
- |cffffd200[ls:name]|r - el nombre;
- |cffffd200[ls:name:5]|r - el nombre (máx. 5 caracteres);
- |cffffd200[ls:name:10]|r - el nombre (máx. 10 caracteres);
- |cffffd200[ls:name:15]|r - el nombre (máx. 15 caracteres);
- |cffffd200[ls:name:20]|r - el nombre (máx. 20 caracteres);
- |cffffd200[ls:server]|r - la etiqueta (*) para jugadores de otros reinos;
- |cffffd200[ls:color:class]|r - el color de clase;
- |cffffd200[ls:color:reaction]|r - color de reacción;
- |cffffd200[ls:color:difficulty]|r - color de dificultad.

Utiliza |cffffd200||r|r para cerrar las etiquetas de color.
Utiliza |cffffd200[nl]|r para saltos de línea.]=]
--[[ L["NAME_TAKEN_ERR"] = "The name is taken." ]]
L["NO_SEPARATION"] = "Sin separación"
L["NOTHING_TO_SHOW"] = "Nada que mostrar."
L["NPE_FRAME"] = "Tutorial marco NPE"
L["NUM_BUTTONS"] = "Número de botones"
L["NUM_ROWS"] = "Número de filas"
L["NUMERIC"] = "Numérico"
L["NUMERIC_PERCENTAGE"] = "Numérico y porcentaje"
L["OBJECTIVE_TRACKER"] = "Seguimiento de objetivos"
L["OOM"] = "Sin Poder"
L["OOM_INDICATOR"] = "Indicador de poder"
L["OOR"] = "Fuera de rango"
L["OOR_INDICATOR"] = "Indicador \"Fuera de rango\""
L["OPEN_CONFIG"] = "Abrir config."
L["ORBS"] = "Orbes"
L["OTHER"] = "Otro"
L["OTHERS_FIRST"] = "Otros primero"
L["OTHERS_HEALING"] = "Sanación de otros"
L["OUTLINE"] = "Contorno"
L["PER_ROW"] = "Por fila"
L["PET_BAR"] = "Barra de mascota"
L["PET_BATTLE_BAR"] = "Barra de batalla de mascotas"
L["PET_CASTBAR"] = "Barra de lanzamiento de mascota"
L["PET_FRAME"] = "Marco de mascota"
L["PLAYER_FRAME"] = "Marco de jugador"
L["PLAYER_PET"] = "Jugador & mascota"
L["PLAYER_TITLE"] = "Título de Jugador"
L["POINT"] = "Apuntar"
L["POINT_DESC"] = "Apunta al objeto."
L["POISON"] = "Veneno"
L["POSITION"] = "Posición"
L["POWER"] = "Poder alternativo"
L["POWER_COST"] = "Coste de Poder"
L["POWER_FORMAT_DESC"] = [=[Escribe un 'String' para cambiar el texto. Para desactivarlo, deja el campo en blanco.

Etiquetas:
- |cffffd200[ls:power:cur]|r - valor actual;
- |cffffd200[ls:power:max]|r - valor máximo;
- |cffffd200[ls:power:perc]|r - porcentaje;
- |cffffd200[ls:power:cur-max]|r - el valor actual seguido del valor máximo;
- |cffffd200[ls:power:cur-perc]|r - el valor actual seguido por el porcentaje;
- |cffffd200[ls:power:deficit]|r - valor de déficit;
- |cffffd200[ls:color:power]|r - el color.

If the current value is equal to the max value, only the max value will be displayed.


Utiliza |cffffd200||r|r para cerrar las etiquetas de color.
Utiliza |cffffd200[nl]|r para saltos de línea.]=]
L["POWER_TEXT"] = "Texto de Poder alternativo"
L["PREDICTION"] = "Predicción"
L["PREVIEW"] = "Previsualizar"
L["PVP_ICON"] = "Icono JcJ"
L["QUESTLOG_BUTTON_DESC"] = "Muestra el tiempo de reinicio de misiones diarias."
L["RAID_ICON"] = "Icono de Banda"
L["RCLICK_SELFCAST"] = "Lanzar sobre uno mismo con Clic Derecho"
L["REACTION"] = "Reacción"
L["RELATIVE_POINT"] = "Punto relativo"
L["RELATIVE_POINT_DESC"] = "Punto de la zona a la que anclar el objeto."
L["RELOAD_NOW"] = "Reiniciar interfaz ahora"
L["RELOAD_UI_ON_CHAR_SETTING_CHANGE_POPUP"] = "Has cambiado una opción de \"sólo personaje\". Éstas opciones son independientes entre tus perfiles. Para que los cambios surtan efecto, debes reiniciar la interfaz."
L["RELOAD_UI_WARNING"] = "Reinicia la interfaz cuando acabes de configurar el addon."
L["RESTORE_DEFAULTS"] = "Restaurar predeterminados"
L["RESTRICTED_MODE"] = "Modo restringido"
L["RESTRICTED_MODE_DESC"] = [=[Activa las ilustraciones, animaciones y tamaño dinámico de la barra principal.

|cffdc4436¡Cuidado!|r Muchas opciones de personalización de las barras no estarán disponibles en este modo.|r]=]
L["RIGHT"] = "Derecha"
L["RIGHT_DOWN"] = "Derecha y abajo"
L["RIGHT_UP"] = "Derecha y arriba"
L["ROWS"] = "Filas"
L["RUNES"] = "Runas"
L["RUNES_BLOOD"] = "Runas de Sangre"
L["RUNES_FROST"] = "Runas de Escarcha"
L["RUNES_UNHOLY"] = "Runas Profanas"
L["SECOND_ANCHOR"] = "Segundo anclaje"
L["SECONDS"] = "Segundos"
L["SELF_BUFFS"] = "Beneficios propios"
L["SELF_BUFFS_DESC"] = "Muestra los beneficios lanzados por la unidad."
L["SELF_BUFFS_PERMA"] = "Beneficios permanentes propios"
L["SELF_BUFFS_PERMA_DESC"] = "Muestra los beneficios permanentes lanzados por la unidad."
L["SELF_DEBUFFS"] = "Perjuicios propios."
L["SELF_DEBUFFS_DESC"] = "Muestra los perjuicios lanzados por la unidad."
L["SELF_DEBUFFS_PERMA"] = "Perjuicios permanentes propios."
L["SELF_DEBUFFS_PERMA_DESC"] = "Muestra los perjuicios permanentes lanzados por la unidad."
L["SEPARATION"] = "Separación"
L["SHADOW"] = "Sombra"
L["SHIFT_CLICK_TO_SHOW_AS_XP"] = "|cffffffffShift-Click|r para mostrar como Barra de Experiencia"
L["SHOW_ON_MOUSEOVER"] = "Mostrar al pasar el ratón."
L["SIZE"] = "Tamaño"
L["SIZE_OVERRIDE"] = "Ignorar tamaño"
L["SIZE_OVERRIDE_DESC"] = "Si es 0, el tamaño del elemento se calculará automáticamente."
L["SORT_DIR"] = "Orden"
L["SORT_METHOD"] = "Método de ordenado"
L["SPACING"] = "Espaciado"
L["SPELL_CAST"] = "Lanzamiento"
L["SPELL_CHANNELED"] = "Canalizado"
L["SPELL_FAILED"] = "Fallido"
L["SPELL_UNINTERRUPTIBLE"] = "Ininterrumpible"
L["STAGGER_HIGH"] = "Escalonado Alto"
L["STAGGER_LOW"] = "Escalonado Bajo"
L["STAGGER_MEDIUM"] = "Escalonado Medio"
L["STANCE_BAR"] = "Barra de actitudes"
L["STANDARD"] = "Estándar"
--[[ L["TAG_VARS"] = "Tag Variables" ]]
--[[ L["TAGS"] = "Tags" ]]
L["TALKING_HEAD_FRAME"] = "Marco de cabeza flotante"
--[[ L["TANK_BUFFS"] = "Tank Buffs" ]]
--[[ L["TANK_BUFFS_DESC"] = "Show buffs applied by tanks." ]]
--[[ L["TANK_DEBUFFS"] = "Tank Debuffs" ]]
--[[ L["TANK_DEBUFFS_DESC"] = "Show debuffs applied by tanks." ]]
L["TAPPED"] = "Golpeado"
L["TARGET_FRAME"] = "Marco de objetivo"
L["TARGET_INFO"] = "Información de objetivo"
L["TARGET_INFO_DESC"] = "Muestra la descripción emergente del objetivo."
L["TARGET_TOT"] = "Objetivo & OdO"
L["TEMP_ENCHANT"] = "Encantamiento temporal"
L["TEXT"] = "Texto"
L["TEXT_HORIZ_ALIGNMENT"] = "Alineamiento horizontal"
L["TEXT_VERT_ALIGNMENT"] = "Alineamiento vertical"
L["THREAT_GLOW"] = "Brillo de Amenaza"
L["TIME"] = "Tiempo"
L["TOF_FRAME"] = "Marco de Objetivo de Foco"
L["TOGGLE_ANCHORS"] = "Mostrar/ocultar anclajes"
L["TOOLTIP_IDS"] = "ID de hechizos y objetos"
L["TOOLTIPS"] = "Descripciones emergentes"
L["TOP"] = "Parte superior"
L["TOP_INSET_SIZE"] = "Tamaño inset superior"
L["TOP_INSET_SIZE_DESC"] = "Utilizado por las barras de clase, recursos y poder alternativos."
L["TOT_FRAME"] = "Marco de Objetivo de Objetivo"
L["TOTEMS"] = "Tótems"
L["TRIVIAL"] = "Trivial"
L["UI_LAYOUT"] = "Diseño de interfaz"
L["UI_LAYOUT_DESC"] = "Cambia la apariencia de los marcos de jugador y mascotas. Ésto también cambiará el diseño de la interfaz."
L["UNITS"] = "Unidades"
L["UNSPENT_TRAIT_POINTS_TOOLTIP"] = "Puntos de rasgo sin gastar: |cffffffff%s|r"
L["UNUSABLE"] = "No utilizable"
L["UP"] = "Arriba"
L["USABLE"] = "Utilizable"
L["USE_BLIZZARD_VEHICLE_UI"] = "Utilizar la interfaz de Blizzard de vehículos"
--[[ L["USER_CREATED"] = "User-created" ]]
--[[ L["VALUE"] = "Value" ]]
--[[ L["VAR"] = "Variable" ]]
L["VEHICLE_EXIT_BUTTON"] = "Botón para salir de vehículo"
L["VEHICLE_SEAT_INDICATOR"] = "Indicador de asiento de vehículo"
L["VERY_DIFFICULT"] = "Muy difícil"
L["VISIBILITY"] = "Visibilidad"
L["WIDTH"] = "Ancho"
L["WIDTH_OVERRIDE"] = "Ignorar ancho"
L["WORD_WRAP"] = "Ajuste de línea"
L["X_OFFSET"] = "xOffset"
L["XP_BAR"] = "Barra de experiencia"
L["Y_OFFSET"] = "yOffset"
L["YOUR_HEALING"] = "Tu sanación"
L["YOURS_FIRST"] = "El tuyo primero"
L["ZONE_ABILITY_BUTTON"] = "Botón de habilidad de zona"
L["ZONE_TEXT"] = "Texto de zona"
