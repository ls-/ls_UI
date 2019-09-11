-- Contributors: Daniel8513@Curse, edward9mm@Curse

local _, ns = ...
local E, L = ns.E, ns.L

-- Lua
local _G = getfenv(0)

--[[ luacheck: globals
	GetLocale
]]

if GetLocale() ~= "frFR" then return end

L["ACTION_BARS"] = "Barres d'action"
L["ADDITIONAL_BAR"] = "Barre Additionnelle"
L["ADVENTURE_JOURNAL_DESC"] = "Afficher les informations de verrouillage du raid"
L["ALT_POWER_BAR"] = "Barre de puissance alternative"
L["ALT_POWER_FORMAT_DESC"] = [=[Fournissez une chaîne de caractères pour changer le texte. Pour désactiver, laissez le champ vide.

Tags:
- |cffffd200[ls:altpower:cur]|r - la valeur actuelle;
- |cffffd200[ls:altpower:max]|r - la valeur maximale;
- |cffffd200[ls:altpower:perc]|r - le pourcentage;
- |cffffd200[ls:altpower:cur-max]|r - la valeur actuelle suivie de la valeur maximale;
- |cffffd200[ls:altpower:cur-perc]|r - la valeur actuelle suivie du pourcentage;
- |cffffd200[ls:color:altpower]|r - couleur.

Si la valeur actuelle est égale à la valeur maximale, seule la valeur maximale sera affichée.

Utilisez |cffffd200||r|r pour fermer les balises de couleurs.
Utilisez |cffffd200[nl]|r pour un saut de ligne.]=]
L["ALTERNATIVE_POWER"] = "Puissance alternative"
L["ALWAYS_SHOW"] = "Toujours afficher"
L["ANCHOR"] = "Attacher à"
L["ANCHOR_TO_CURSOR"] = "Attacher au Curseur"
L["ARTIFACT_LEVEL_TOOLTIP"] = "Niveau d'artéfact : |cffffffff%s|r"
L["ARTIFACT_POWER"] = "Puissance d'artéfact"
L["ASCENDING"] = "Ascendant"
L["AURA"] = "Aura"
--[[ L["AURA_FILTERS"] = "Aura Filters" ]]
L["AURA_TRACKER"] = "Suivi d'auras"
L["AURA_TYPE"] = "Type d'auras"
L["AURAS"] = "Auras"
--[[ L["AUTO"] = "Auto" ]]
L["BAG_SLOTS"] = "Sac d'emplacements"
L["BAR"] = "Barres"
L["BAR_1"] = "Barre 1"
L["BAR_2"] = "Barre 2"
L["BAR_3"] = "Barre 3"
L["BAR_4"] = "Barre 4"
L["BAR_5"] = "Barre 5"
L["BAR_COLOR"] = "Couleur de la barre"
L["BAR_TEXT"] = "Texte de la barre"
--[[ L["BLACKLIST"] = "Blacklist" ]]
L["BLIZZARD"] = "Blizzard"
L["BONUS_XP_TOOLTIP"] = "Bonus d'XP : |cffffffff%s|r"
L["BORDER"] = "Bordure"
L["BORDER_COLOR"] = "Couleur de bordure"
L["BOSS"] = "Boss"
L["BOSS_BUFFS"] = "Buffs du boss"
L["BOSS_BUFFS_DESC"] = "Afficher les buffs lancés par le boss"
L["BOSS_DEBUFFS"] = "Debuffs du boss"
L["BOSS_DEBUFFS_DESC"] = "Afficher les debuffs lancés par le boss"
L["BOSS_FRAMES"] = "Cadres du/des boss"
L["BOTTOM"] = "Bas"
L["BOTTOM_INSET_SIZE"] = "Taille de l'encart inférieur"
L["BOTTOM_INSET_SIZE_DESC"] = "Utilisé par la barre de puissance"
L["BUFFS"] = "Buffs"
L["BUFFS_AND_DEBUFFS"] = "Buffs et Debuffs"
--[[ L["BUTTON"] = "Button" ]]
L["BUTTON_GRID"] = "Grille de boutons"
L["CALENDAR"] = "Calendrier"
L["CAST_ON_KEY_DOWN"] = "Lancer à l'enfoncement de la touche"
L["CASTABLE_BUFFS"] = "Buffs lançables"
L["CASTABLE_BUFFS_DESC"] = "Afficher les buffs lancés par vous."
L["CASTABLE_BUFFS_PERMA"] = "Buffs permanents lançables"
L["CASTABLE_BUFFS_PERMA_DESC"] = "Afficher les buffs permanents lancés par vous."
L["CASTABLE_DEBUFFS"] = "Deuffs lançables"
L["CASTABLE_DEBUFFS_DESC"] = "Afficher les debuffs lancés par vous."
L["CASTABLE_DEBUFFS_PERMA"] = "Debuffs permanents lançables"
L["CASTABLE_DEBUFFS_PERMA_DESC"] = "Afficher les debuffs permanents lancés par vous."
L["CASTBAR"] = "Barre d'incantation"
--[[ L["CHANGE"] = "Change" ]]
L["CHARACTER_BUTTON_DESC"] = "Afficher la durabilité de l'équipement"
--[[ L["CHARACTER_FRAME"] = "Character Frame" ]]
L["CLASS_POWER"] = "Puissance de classe"
L["CLASSIC"] = "Classique"
--[[ L["CLEAN_UP"] = "Clean Up" ]]
--[[ L["CLEAN_UP_MAIL_DESC"] = "Removes all empty messages." ]]
L["CLOCK"] = "Horloge"
--[[ L["COLLECT_BUTTONS"] = "Collect Buttons" ]]
L["COLOR_BY_SPEC"] = "Colorer par Spécialisation"
L["COLORS"] = "Couleurs"
L["COMMAND_BAR"] = "Barre de commande"
--[[ L["CONFIRM_DELETE"] = "Do you wish to delete \"%s\"?" ]]
--[[ L["CONFIRM_RESET"] = "Do you wish to reset \"%s\"?" ]]
--[[ L["COOLDOWN"] = "Cooldown" ]]
--[[ L["COOLDOWN_TEXT"] = "Cooldown Text" ]]
L["COPY_FROM"] = "Copier de"
L["COPY_FROM_DESC"] = "Sélectionnez un profil pour copier ses paramètres."
L["COST_PREDICTION"] = "Prédiction de coût"
L["COST_PREDICTION_DESC"] = "Afficher une barre qui représente le coût en puissance d'un sort. Ne fonctionne pas avec les techniques instantanées"
L["COUNT_TEXT"] = "Texte d'énumération"
--[[ L["CURSE"] = "Curse" ]]
L["DAILY_QUEST_RESET_TIME_TOOLTIP"] = "Réinitialisation des quêtes journalières : |cffffffff%s|r"
--[[ L["DAMAGE_ABSORB"] = "Damage Absorb" ]]
L["DAMAGE_ABSORB_FORMAT_DESC"] = [=[Fournissez une chaîne de caractères pour changer le texte. Pour désactiver, laissez le champ vide.

Tags:
- |cffffd200[ls:absorb:damage]|r - la valeur actuelle;
- |cffffd200[ls:color:absorb-damage]|r - la couleur.

Utilisez |cffffd200||r|r pour fermer les balises de couleur.
Utilisez |cffffd200[nl]|r pour un saut de ligne.]=]
L["DAMAGE_ABSORB_TEXT"] = "Texte d'absorption des dommages"
L["DAYS"] = "Jours"
L["DEAD"] = "Mort"
--[[ L["DEBUFF"] = "Debuff" ]]
--[[ L["DEBUFF_TYPE"] = "Debuff Type" ]]
L["DEBUFFS"] = "Debuffs"
--[[ L["DESATURATION"] = "Desaturation" ]]
L["DESCENDING"] = "Descendant"
L["DETACH_FROM_FRAME"] = "Détacher du cadre"
--[[ L["DIFFICULT"] = "Difficult" ]]
L["DIFFICULTY"] = "Difficulté"
L["DIFFICULTY_FLAG"] = "Drapeau de difficulté"
L["DIGSITE_BAR"] = "Barre de progression de la fouille"
L["DISABLE_MOUSE"] = "Désactiver la souris"
L["DISABLE_MOUSE_DESC"] = "Ignorer les évènements de souris."
--[[ L["DISEASE"] = "Disease" ]]
L["DISPELLABLE_BUFFS"] = "Buffs désactivables"
L["DISPELLABLE_BUFFS_DESC"] = "Afficher les buffs que vous pouvez retirer de votre cible"
L["DISPELLABLE_DEBUFF_ICONS"] = "Icônes des debuffs désactivables"
L["DISPELLABLE_DEBUFFS"] = "Debuffs désactivables"
L["DISPELLABLE_DEBUFFS_DESC"] = "Afficher les debuffs que vous pouvez soigner sur la cible."
L["DOWN"] = "Bas"
L["DRAG_KEY"] = "Touche pour glisser"
L["DUNGEONS_BUTTON_DESC"] = "Afficher \"Appel aux armes\""
L["DURABILITY_FRAME"] = "Cadre de durabilité"
L["ENEMY_UNITS"] = "Unités ennemies"
L["ENHANCED_TOOLTIPS"] = "Info-bulles améliorées"
--[[ L["EVENTS"] = "Events" ]]
--[[ L["EXP_THRESHOLD"] = "Expiration Threshold" ]]
--[[ L["EXP_THRESHOLD_DESC"] = "The threshold (in seconds) below which the remaining time will be shown as a decimal number." ]]
L["EXPERIENCE"] = "Expérience"
--[[ L["EXPERIENCE_NORMAL"] = "Normal" ]]
--[[ L["EXPERIENCE_RESTED"] = "Rested" ]]
--[[ L["EXPIRATION"] = "Expiration" ]]
L["EXTRA_ACTION_BUTTON"] = "Boutons d'action supplémentaires"
--[[ L["FACTION_NEUTRAL"] = "Neutral" ]]
L["FADE_IN_DELAY"] = "Délai d'apparition en fondu"
L["FADE_IN_DURATION"] = "Durée d'apparition en fondu"
L["FADE_OUT_DELAY"] = "Délai de disparition en fondu"
L["FADE_OUT_DURATION"] = "Durée de disparition en fondu"
L["FADING"] = "Fondu"
L["FILTER_SETTINGS"] = "Paramètres des filtres"
L["FILTERS"] = "Filtres"
L["FLAG"] = "Drapeau"
L["FLYOUT_DIR"] = "Direction déroulement"
L["FOCUS_FRAME"] = "Cadre du focus"
L["FOCUS_TOF"] = "Focus & Cible du focus"
L["FORMAT"] = "Format"
L["FRAME"] = "Cadre"
--[[ L["FREE_BAG_SLOTS_TOOLTIP"] = "Free Bag Slots: |cffffffff%s|r" ]]
--[[ L["FRIENDLY_TERRITORY"] = "Friendly Territory" ]]
L["FRIENDLY_UNITS"] = "Unités amies"
--[[ L["FUNC"] = "Function" ]]
--[[ L["GAIN"] = "Gain" ]]
--[[ L["GAIN_LOSS_THRESHOLD"] = "Gain/Loss Threshold" ]]
--[[ L["GAIN_LOSS_THRESHOLD_DESC"] = "The threshold (in percentages) above which resource gain and loss will be animated. Set to 100 to disable." ]]
L["GM_FRAME"] = "Cadre des statuts des requêtes"
L["GOLD"] = "Or"
L["GROWTH_DIR"] = "Direction de la croissance"
--[[ L["HEAL_ABSORB"] = "Heal Absorb" ]]
L["HEAL_ABSORB_FORMAT_DESC"] = [=[Fournissez une chaîne de caractères pour changer le texte. Pour désactiver, laissez le champ vide.

Tags:
- |cffffd200[ls:absorb:heal]|r - la valeur actuelle;
- |cffffd200[ls:color:absorb-heal]|r - la couleur.

Utilisez |cffffd200||r|r pour fermer les balises de couleur.
Utilisez |cffffd200[nl]|r pour un saut de ligne.]=]
L["HEAL_ABSORB_TEXT"] = "Texte d'absorption des soins"
L["HEAL_PREDICTION"] = "Prédiction de soin"
--[[ L["HEALER_BUFFS"] = "Healer Buffs" ]]
--[[ L["HEALER_BUFFS_DESC"] = "Show buffs applied by healers." ]]
--[[ L["HEALER_DEBUFFS"] = "Healer Debuffs" ]]
--[[ L["HEALER_DEBUFFS_DESC"] = "Show debuffs applied by healers." ]]
L["HEALTH"] = "Santé"
L["HEALTH_FORMAT_DESC"] = [=[Fournissez une chaîne de caractères pour changer le texte. Pour désactiver, laissez le champ vide.

Tags:
- |cffffd200[ls:health:cur]|r - la valeur actuelle;
- |cffffd200[ls:health:perc]|r - le pourcentage;
- |cffffd200[ls:health:cur-perc]|r - la valeur actuelle suivie du pourcentage;
- |cffffd200[ls:health:deficit]|r - la valeur déficitaire.

Si la valeur actuelle est égale à la valeur maximale, seule la valeur maximale sera affichée.

Utilisez |cffffd200[nl]|r pour un saut de ligne.]=]
L["HEALTH_TEXT"] = "Texte de santé"
L["HEIGHT"] = "Hauteur"
L["HONOR"] = "Honneur"
L["HONOR_LEVEL_TOOLTIP"] = "Niveau d'honneur :  |cffffffff%d|r"
--[[ L["HOSTILE_TERRITORY"] = "Hostile Territory" ]]
--[[ L["HOURS"] = "Hours" ]]
L["ICON"] = "Icône"
--[[ L["IMPOSSIBLE"] = "Impossible" ]]
L["INDEX"] = "Index"
L["INSPECT_INFO"] = "Inspecter les infos"
L["INSPECT_INFO_DESC"] = "Afficher la spécialisation et niveau d'objets dans l'info-bulle de l'unité. Ces données peuvent ne pas être disponibles tout de suite."
--[[ L["INVALID_EVENTS_ERR"] = "Attempted to use invalid events: %s." ]]
--[[ L["INVALID_TAGS_ERR"] = "Attempted to use invalid tags: %s." ]]
--[[ L["INVENTORY_BUTTON"] = "Inventory" ]]
--[[ L["INVENTORY_BUTTON_DESC"] = "Show currency information." ]]
--[[ L["INVENTORY_BUTTON_RCLICK_TOOLTIP"] = "|cffffffffRight-Click|r to toggle bag slots." ]]
L["ITEM_COUNT"] = "Nombre d'objet"
L["ITEM_COUNT_DESC"] = "Afficher le nombre d'exemplaire d'un objet que vous avez dans votre banque et vos sacs."
L["KEYBIND_TEXT"] = "Raccourcis"
L["LATENCY"] = "Latence"
L["LATENCY_HOME"] = "Locale"
L["LATENCY_WORLD"] = "Monde"
L["LATER"] = "Plus tard"
L["LEFT"] = "Gauche"
L["LEFT_DOWN"] = "Gauche vers le bas"
L["LEFT_UP"] = "Gauche vers le haut"
L["LEVEL_TOOLTIP"] = "Niveau : |cffffffff%d|r"
L["LOCK"] = "Bloquer"
L["LOCK_BUTTONS"] = "Bloquer les boutons"
L["LOCK_BUTTONS_DESC"] = "Vous empêche de prendre et de déplacer les sorts hors de la barre d'action."
--[[ L["LOOT_ALL"] = "Loot All" ]]
--[[ L["LOSS"] = "Loss" ]]
--[[ L["M_SS_THRESHOLD"] = "M:SS Threshold" ]]
--[[ L["M_SS_THRESHOLD_DESC"] = "The threshold (in seconds) below which the remaining time will be shown in the M:SS format. Set to 0 to disable." ]]
L["MACRO_TEXT"] = "Texte de macro"
--[[ L["MAGIC"] = "Magic" ]]
--[[ L["MAIN_BAR"] = "Main Bar" ]]
L["MAINMENU_BUTTON_DESC"] = "Afficher les performances"
L["MAINMENU_BUTTON_HOLD_TOOLTIP"] = "|cffffffffMaintenir Maj|r pour afficher l'utilisation de la mémoire."
L["MAX_ALPHA"] = "Alpha max"
L["MEMORY"] = "Mémoire"
L["MICRO_BUTTONS"] = "Micro boutons"
L["MIN_ALPHA"] = "Alpha min"
--[[ L["MINIMAP_BUTTONS"] = "Minimap Buttons" ]]
--[[ L["MINIMAP_BUTTONS_TOOLTIP"] = "Click to show minimap buttons." ]]
--[[ L["MINUTES"] = "Minutes" ]]
L["MIRROR_TIMER"] = "Timers des miroirs"
--[[ L["MIRROR_TIMER_DESC"] = "Breath, fatigue and other indicators." ]]
L["MODE"] = "Mode"
L["MOUNT_AURAS"] = "Auras de monture"
L["MOUNT_AURAS_DESC"] = "Afficher les auras de monture"
L["MOVER_BUTTONS_DESC"] = "|cffffffffCliquer|r pour basculer les boutons. "
L["MOVER_CYCLE_DESC"] = "Appuyez sur la touche |cffffffffAlt|r pour faire défiler les cadres sous le curseur"
L["MOVER_RESET_DESC"] = "|cffffffffClic Maj|r pour réinitialiser la position"
L["NAME"] = "Nom"
L["NAME_FORMAT_DESC"] = [=[Fournissez une chaîne de caractères pour changer le texte. Pour désactiver, laissez le champ vide.

 Tags:
- |cffffd200[ls:name]|r - le nom;
- |cffffd200[ls:name:5]|r - le nom raccourci à 5 caractères;
- |cffffd200[ls:name:10]|r - le nom raccourci à 10 caractères;
- |cffffd200[ls:name:15]|r - le nom raccourci à 15 caractères;
- |cffffd200[ls:name:20]|r - le nom raccourci à 20 caractères;
- |cffffd200[ls:server]|r - le tag (*) pour les joueurs venant d'autres royames;
- |cffffd200[ls:color:class]|r - la couleur de la classe;
- |cffffd200[ls:color:reaction]|r - la couleur de réaction;
- |cffffd200[ls:color:difficulty]|r - la couleur de difficulté.

Utilisez |cffffd200||r|r pour fermer les balises des couleurs.
Utilisez |cffffd200[nl]|r pour faire un saut de ligne.]=]
--[[ L["NAME_TAKEN_ERR"] = "The name is taken." ]]
L["NO_SEPARATION"] = "Aucune séparation"
--[[ L["NOTHING_TO_SHOW"] = "Nothing to show." ]]
L["NPE_FRAME"] = "Cadre de tutoriel des nouveaux joueurs"
L["NUM_BUTTONS"] = "Nombre de boutons"
L["NUM_ROWS"] = "Nombre de lignes"
--[[ L["NUMERIC"] = "Numeric" ]]
--[[ L["NUMERIC_PERCENTAGE"] = "Numeric & Percentage" ]]
L["OBJECTIVE_TRACKER"] = "Suivi d'objectif"
--[[ L["OOM"] = "Out of Power" ]]
--[[ L["OOM_INDICATOR"] = "Out-of-Power Indicator" ]]
--[[ L["OOR"] = "Out of Range" ]]
L["OOR_INDICATOR"] = "Indicateur hors de portée"
L["OPEN_CONFIG"] = "Ouvrir configuration"
L["ORBS"] = "Orbes"
L["OTHER"] = "Autre"
L["OTHERS_FIRST"] = "Les autres en premier"
--[[ L["OTHERS_HEALING"] = "Others' Healing" ]]
L["OUTLINE"] = "Conteur"
L["PER_ROW"] = "Par ligne"
L["PET_BAR"] = "Barre du familier"
L["PET_BATTLE_BAR"] = "Barre de mascotte de combat"
--[[ L["PET_CASTBAR"] = "Pet Casting Bar" ]]
L["PET_FRAME"] = "Cadre du familier"
L["PLAYER_FRAME"] = "Cadre du joueur"
L["PLAYER_PET"] = "Joueur & Familier"
L["PLAYER_TITLE"] = "Titre du joueur"
L["POINT"] = "Point"
L["POINT_DESC"] = "Point de l'objet"
--[[ L["POISON"] = "Poison" ]]
--[[ L["PORTRAIT"] = "Portrait" ]]
L["POSITION"] = "Position"
L["POWER"] = "Puissance"
--[[ L["POWER_COST"] = "Power Cost" ]]
L["POWER_FORMAT_DESC"] = [=[Fournissez une chaîne de caractères pour changer le texte. Pour désactiver, laissez le champ vide.

Tags:
- |cffffd200[ls:power:cur]|r - la valeur actuelle;
- |cffffd200[ls:power:max]|r - la valeur maximale;
- |cffffd200[ls:power:perc]|r - le pourcentage;
- |cffffd200[ls:power:cur-max]|r - la valeur actuelle suivie de la valeur maximale;
- |cffffd200[ls:power:cur-perc]|r - la valeur actuelle suivie du pourcentage;
- |cffffd200[ls:power:deficit]|r - la valeur déficitaire;
- |cffffd200[ls:color:power]|r - la couleur.

Si la valeur actuelle est égale à la valeur maximale, seule la valeur maximale sera affichée.

Utilisez |cffffd200||r|r pour fermer les balises de couleur.
Utilisez |cffffd200[nl]|r pour un retour à la ligne.]=]
L["POWER_TEXT"] = "Texte de puissance"
--[[ L["PREDICTION"] = "Prediction" ]]
L["PREVIEW"] = "Aperçu"
L["PVP_ICON"] = "Icône JcJ"
L["QUESTLOG_BUTTON_DESC"] = "Afficher le temps de réinitialisation des quêtes journalières"
--[[ L["QUEUE"] = "Queue" ]]
L["RAID_ICON"] = "Icône de raid"
L["RCLICK_SELFCAST"] = "Lancer sur soi avec le clic droit"
L["REACTION"] = "Réaction"
L["RELATIVE_POINT"] = "Point relatif"
L["RELATIVE_POINT_DESC"] = "Le point auquel attacher l'objet."
L["RELOAD_NOW"] = "Recharger maintenant"
L["RELOAD_UI_ON_CHAR_SETTING_CHANGE_POPUP"] = "Vous venez de changer un paramètre spécifique au personnage. Ces paramètres sont indépendants de vos profils. Pour que les changements fassent effet, vous devrez recharger l'IU."
L["RELOAD_UI_WARNING"] = "Rechargez l'IU dès que vous avez fini de configurer l'add-on."
L["RESTORE_DEFAULTS"] = "Restaurer les valeurs par défaut"
L["RESTRICTED_MODE"] = "Mode restreint"
L["RESTRICTED_MODE_DESC"] = [=[Active l'illustration, les animations et le redimensionnement dynamique de la barre d'action principale.
|cffdc4436Attention !|r Certaines options de personnalisation des barres d'action ne seront pas disponibles dans ce mode.|r]=]
L["RIGHT"] = "Droite"
L["RIGHT_DOWN"] = "Droite et vers le bas"
L["RIGHT_UP"] = "Droite et vers le haut"
L["ROWS"] = "Lignes"
--[[ L["RUNES"] = "Runes" ]]
--[[ L["RUNES_BLOOD"] = "Blood Runes" ]]
--[[ L["RUNES_FROST"] = "Frost Runes" ]]
--[[ L["RUNES_UNHOLY"] = "Unholy Runes" ]]
L["SECOND_ANCHOR"] = "Deuxième point d'attache"
--[[ L["SECONDS"] = "Seconds" ]]
L["SELF_BUFFS"] = "Auto-buffs"
L["SELF_BUFFS_DESC"] = "Afficher les buffs lancés par l'unité elle-même."
L["SELF_BUFFS_PERMA"] = "Auto-buffs parmanents"
L["SELF_BUFFS_PERMA_DESC"] = "Afficher les buffs parmanents lancés par l'unité elle-même."
L["SELF_DEBUFFS"] = "Auto-debuffs"
L["SELF_DEBUFFS_DESC"] = "Afficher les debuffs lancés par l'unité elle-même."
L["SELF_DEBUFFS_PERMA"] = "Auto-debuffs permanents"
L["SELF_DEBUFFS_PERMA_DESC"] = "Afficher les debuffs parmanents lancés par l'unité elle-même."
L["SEPARATION"] = "Séparation"
L["SHADOW"] = "Ombre"
L["SHIFT_CLICK_TO_SHOW_AS_XP"] = "|cffffffffClic-Maj|r pour afficher en tant que barre d'expérience."
L["SHOW_ON_MOUSEOVER"] = "Afficher au passage de la souris"
L["SIZE"] = "Taille"
L["SIZE_OVERRIDE"] = "Régler la taille"
L["SIZE_OVERRIDE_DESC"] = "Si réglé à 0, la taille de l'élément sera automatiquement calculé"
L["SORT_DIR"] = "Direction de tri"
L["SORT_METHOD"] = "Méthode de tri"
L["SPACING"] = "Espacement"
--[[ L["SPELL_CAST"] = "Cast" ]]
--[[ L["SPELL_CHANNELED"] = "Channelled" ]]
--[[ L["SPELL_FAILED"] = "Failed" ]]
--[[ L["SPELL_UNINTERRUPTIBLE"] = "Uninterruptible" ]]
--[[ L["STAGGER_HIGH"] = "High Stagger" ]]
--[[ L["STAGGER_LOW"] = "Low Stagger" ]]
--[[ L["STAGGER_MEDIUM"] = "Medium Stagger" ]]
L["STANCE_BAR"] = "Barre de posture"
--[[ L["STANDARD"] = "Standard" ]]
--[[ L["STYLE"] = "Style" ]]
--[[ L["TAG_VARS"] = "Tag Variables" ]]
--[[ L["TAGS"] = "Tags" ]]
L["TALKING_HEAD_FRAME"] = "Cadre du personnage qui parle"
--[[ L["TANK_BUFFS"] = "Tank Buffs" ]]
--[[ L["TANK_BUFFS_DESC"] = "Show buffs applied by tanks." ]]
--[[ L["TANK_DEBUFFS"] = "Tank Debuffs" ]]
--[[ L["TANK_DEBUFFS_DESC"] = "Show debuffs applied by tanks." ]]
--[[ L["TAPPED"] = "Tapped" ]]
L["TARGET_FRAME"] = "Cadre de la cible"
L["TARGET_INFO"] = "Info de la cible"
L["TARGET_INFO_DESC"] = "Afficher l'info-bulle de la cible actuelle."
L["TARGET_TOT"] = "Cible & Cible de la cible"
--[[ L["TEMP_ENCHANT"] = "Temporary Enchant" ]]
--[[ L["TEXT"] = "Text" ]]
L["TEXT_HORIZ_ALIGNMENT"] = "Alignement horizontal"
L["TEXT_VERT_ALIGNMENT"] = "Alignement vertical"
L["THREAT_GLOW"] = "Lueur de menace"
L["TIME"] = "Temps"
L["TOF_FRAME"] = "Cadre de la cible du focus"
L["TOGGLE_ANCHORS"] = "Basculer les points d'attache"
L["TOOLTIP_IDS"] = "ID des sorts et des objets"
L["TOOLTIPS"] = "Info-bulles"
L["TOP"] = "Haut"
L["TOP_INSET_SIZE"] = "Taille de l'encart supérieur"
L["TOP_INSET_SIZE_DESC"] = "Utilisé par barre de puissance de la classe, alternative et supplémentaire."
L["TOT_FRAME"] = "Cadre de la cible de la cible"
L["TOTEMS"] = "Totems"
--[[ L["TRIVIAL"] = "Trivial" ]]
L["UI_LAYOUT"] = "Disposition de l'IU"
L["UI_LAYOUT_DESC"] = "Change l'apparence des cadres du joueur et des familiers. Cela va aussi changer la disposition de l'IU."
L["UNITS"] = "Unité"
L["UNSPENT_TRAIT_POINTS_TOOLTIP"] = "Points de traits non-dépensés : |cffffffff%s|r"
--[[ L["UNUSABLE"] = "Not Usable" ]]
L["UP"] = "Haut"
--[[ L["USABLE"] = "Usable" ]]
L["USE_BLIZZARD_VEHICLE_UI"] = "Utiliser l'IU de Blizzard pour le véhicule"
--[[ L["USER_CREATED"] = "User-created" ]]
--[[ L["VALUE"] = "Value" ]]
--[[ L["VAR"] = "Variable" ]]
L["VEHICLE_EXIT_BUTTON"] = "Bouton de sortie de véhicule"
L["VEHICLE_SEAT_INDICATOR"] = "Indicateur Siège de véhicule"
--[[ L["VERY_DIFFICULT"] = "Very Difficult" ]]
L["VISIBILITY"] = "Visibilité"
L["WIDTH"] = "Largeur"
L["WIDTH_OVERRIDE"] = "Régler la largeur"
L["WORD_WRAP"] = "Retour à la ligne automatique"
L["X_OFFSET"] = "Décalage X"
L["XP_BAR"] = "Barre d'XP"
L["Y_OFFSET"] = "Décalage Y"
--[[ L["YOUR_HEALING"] = "Your Healing" ]]
L["YOURS_FIRST"] = "Les vôtres en premier"
L["ZONE_ABILITY_BUTTON"] = "Zone de bouton d'abilité"
L["ZONE_TEXT"] = "Zone de texte"
