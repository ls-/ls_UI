﻿-- Contributors: Daniel8513@Curse, cybern4ut@Curse, Brainc3ll@Curse

local _, ns = ...
local E, L = ns.E, ns.L

-- Lua
local _G = getfenv(0)

if GetLocale() ~= "frFR" then return end

L["ADVENTURE_JOURNAL_DESC"] = "Afficher les informations de verrouillage du raid"
L["ALTERNATIVE_POWER"] = "Puissance alternative"
L["ALTERNATIVE_POWER_FORMAT_DESC"] = [=[Fournissez une chaîne de caractères pour changer le texte. Pour désactiver, laissez le champ vide.

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
L["ALWAYS_SHOW"] = "Toujours afficher"
L["ANCHOR"] = "Attacher à"
L["ARTIFACT_LEVEL_TOOLTIP"] = "Niveau d'artéfact : |cffffffff%s|r"
L["ARTIFACT_POWER"] = "Puissance d'artéfact"
L["ASCENDING"] = "Ascendant"
L["AURA"] = "Aura"
L["AURA_FILTERS"] = "Filtres d'aura"
L["AURA_TRACKER"] = "Suivi d'auras"
L["AURA_TYPE"] = "Type d'auras"
L["AUTO"] = "Auto"
L["BAG_TOOLTIP_DESC"] = "Afficher les informations sur les monnaies."
L["BAR_COLOR"] = "Couleur de la barre"
L["BAR_TEXT"] = "Texte de la barre"
L["BLACKLIST"] = "Liste noire"
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
L["BOTTOM_INSET_SIZE"] = "Taille de l'encart inférieur"
L["BOTTOM_INSET_SIZE_DESC"] = "Utilisé par la barre de puissance"
L["BUFFS"] = "Buffs"
L["BUFFS_AND_DEBUFFS"] = "Buffs et Debuffs"
L["BUTTON"] = "Bouton"
L["BUTTON_GRID"] = "Grille de boutons"
L["BUTTONS"] = "Boutons"
L["CASTABLE_BUFFS"] = "Buffs lançables"
L["CASTABLE_BUFFS_DESC"] = "Afficher les buffs lancés par vous."
L["CASTABLE_BUFFS_PERMA"] = "Buffs permanents lançables"
L["CASTABLE_BUFFS_PERMA_DESC"] = "Afficher les buffs permanents lancés par vous."
L["CASTABLE_DEBUFFS"] = "Deuffs lançables"
L["CASTABLE_DEBUFFS_DESC"] = "Afficher les debuffs lancés par vous."
L["CASTABLE_DEBUFFS_PERMA"] = "Debuffs permanents lançables"
L["CASTABLE_DEBUFFS_PERMA_DESC"] = "Afficher les debuffs permanents lancés par vous."
L["CASTBAR"] = "Barre d'incantation"
L["CHANGELOG"] = "Note de patch"
L["CHARACTER_BUTTON_DESC"] = "Afficher la durabilité de l'équipement"
L["CHARACTER_FRAME"] = "Fenêtre du personnage"
L["CLASS_POWER"] = "Puissance de classe"
L["CLEAN_UP"] = "Nettoyage"
L["CLEAN_UP_MAIL_DESC"] = "Supprime tout les messages vides"
L["COLOR_BY_SPEC"] = "Colorer par Spécialisation"
L["COLORS"] = "Couleurs"
L["COMBO_POINTS_CHARGED"] = "Points de combo chargés"
L["COMMAND_BAR"] = "Barre de commande"
L["CONFIRM_DELETE"] = "Voulez-vous supprimer \"%s\"?"
L["CONFIRM_RESET"] = "Voulez-vous réinitialiser \"%s\"?"
L["COOLDOWN"] = "Temps de recharge"
L["COOLDOWN_TEXT"] = "Texte du temps de recharge"
L["COPY_FROM"] = "Copier de"
L["COPY_FROM_DESC"] = "Sélectionnez un profil pour copier ses paramètres."
L["COST_PREDICTION"] = "Prédiction de coût"
L["COST_PREDICTION_DESC"] = "Afficher une barre qui représente le coût en puissance d'un sort. Ne fonctionne pas avec les techniques instantanées"
L["COUNT_TEXT"] = "Texte d'énumération"
L["CURSE"] = "Malédiction"
L["CUSTOM_TEXTS"] = "Textes personnalisé "
L["DAILY_QUEST_RESET_TIME_TOOLTIP"] = "Réinitialisation des quêtes journalières : |cffffffff%s|r"
L["DAMAGE_ABSORB"] = "Absorption des dommages"
L["DAYS"] = "Jours"
L["DEBUFF"] = "Affaiblissement"
L["DEBUFFS"] = "Debuffs"
L["DESATURATION"] = "Désaturation"
L["DESCENDING"] = "Descendant"
L["DETACH_FROM_FRAME"] = "Détacher du cadre"
L["DIFFICULT"] = "Difficile"
L["DIFFICULTY"] = "Difficulté"
L["DIFFICULTY_FLAG"] = "Drapeau de difficulté"
L["DISABLE_MOUSE"] = "Désactiver la souris"
L["DISABLE_MOUSE_DESC"] = "Ignorer les évènements de souris."
L["DISEASE"] = "Maladie"
L["DISPELLABLE_DEBUFF_ICONS"] = "Icônes des debuffs désactivables"
L["DISPELLABLE_DEBUFFS"] = "Debuffs désactivables"
L["DISPELLABLE_DEBUFFS_DESC"] = "Afficher les debuffs que vous pouvez soigner sur la cible."
L["DOWN"] = "Bas"
L["DOWNLOADS"] = "Téléchargements"
L["DRAG_KEY"] = "Touche pour glisser"
L["DUNGEONS_BUTTON_DESC"] = "Afficher \"Appel aux armes\""
L["ENEMY_UNITS"] = "Unités ennemies"
L["ENHANCED_TOOLTIPS"] = "Info-bulles améliorées"
L["EVENTS"] = "Evènements "
L["EXPERIENCE_NORMAL"] = "Expérience normale"
L["EXPERIENCE_RESTED"] = "Expérience reposé"
L["EXPIRATION"] = "Expiration"
L["EXTRA_ACTION_BUTTON"] = "Boutons d'action supplémentaires"
L["FACTION_NEUTRAL"] = "Faction neutre"
L["FADE_IN_DURATION"] = "Durée d'apparition en fondu"
L["FADE_OUT_DELAY"] = "Délai de disparition en fondu"
L["FADE_OUT_DURATION"] = "Durée de disparition en fondu"
L["FADING"] = "Fondu"
L["FILTER_SETTINGS"] = "Paramètres des filtres"
L["FILTERS"] = "Filtres"
L["FLYOUT_DIR"] = "Direction déroulement"
L["FOCUS_FRAME"] = "Cadre du focus"
L["FOCUS_TOF"] = "Focus & Cible du focus"
L["FONTS"] = "Polices"
L["FORMAT"] = "Format"
L["FRAME"] = "Cadre"
L["FRIENDLY_UNITS"] = "Unités amies"
L["GM_FRAME"] = "Cadre des statuts des requêtes"
L["GROWTH_DIR"] = "Direction de la croissance"
L["HEAL_PREDICTION"] = "Prédiction de soin"
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
L["ICON"] = "Icône"
L["INDEX"] = "Index"
L["INSPECT_INFO"] = "Inspecter les infos"
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
L["LOCK_BUTTONS"] = "Bloquer les boutons"
L["MACRO_TEXT"] = "Texte de macro"
L["MAINMENU_BUTTON_DESC"] = "Afficher les performances"
L["MAX_ALPHA"] = "Alpha max"
L["MICRO_BUTTONS"] = "Micro boutons"
L["MIN_ALPHA"] = "Alpha min"
L["MOUNT_AURAS"] = "Auras de monture"
L["MOUNT_AURAS_DESC"] = "Afficher les auras de monture"
L["MOVER_CYCLE_DESC"] = "Appuyez sur la touche |cffffffffAlt|r pour faire défiler les cadres sous le curseur"
L["MOVER_RESET_DESC"] = "|cffffffffClic Maj|r pour réinitialiser la position"
L["NAME"] = "Nom"
L["NAME_FORMAT_DESC"] = [=[Fournissez une chaîne de caractères pour changer le texte. Pour désactiver, laissez le champ vide.

Tags:
- |cffffd200[ls:name]|r - le nom;
- |cffffd200[ls:name(N)]|r - the name shortened to N characters, for instance, [ls:name(5)] will show only 5 characters;
- |cffffd200[ls:server]|r - le tag (*) pour les joueurs venant d'autres royames;
- |cffffd200[ls:color:class]|r - la couleur de la classe;
- |cffffd200[ls:color:reaction]|r - la couleur de réaction;
- |cffffd200[ls:color:difficulty]|r - la couleur de difficulté.

Utilisez |cffffd200||r|r pour fermer les balises des couleurs.
Utilisez |cffffd200[nl]|r pour faire un saut de ligne.]=]
L["NO_SEPARATION"] = "Aucune séparation"
L["NUM_BUTTONS"] = "Nombre de boutons"
L["NUM_ROWS"] = "Nombre de lignes"
L["OOR_INDICATOR"] = "Indicateur hors de portée"
L["OPEN_CONFIG"] = "Ouvrir configuration"
L["OTHERS_FIRST"] = "Les autres en premier"
L["OUTLINE"] = "Conteur"
L["PER_ROW"] = "Par ligne"
L["PET_BAR"] = "Barre du familier"
L["PET_BATTLE_BAR"] = "Barre de mascotte de combat"
L["PET_FRAME"] = "Cadre du familier"
L["PLAYER_FRAME"] = "Cadre du joueur"
L["PLAYER_PET"] = "Joueur & Familier"
L["PLAYER_TITLE"] = "Titre du joueur"
L["POINT"] = "Point"
L["POINT_DESC"] = "Point de l'objet"
L["POSITION"] = "Position"
L["POWER"] = "Puissance"
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
L["PREVIEW"] = "Aperçu"
L["PVP_ICON"] = "Icône JcJ"
L["QUESTLOG_BUTTON_DESC"] = "Afficher le temps de réinitialisation des quêtes journalières"
L["RAID_ICON"] = "Icône de raid"
L["RCLICK_SELFCAST"] = "Lancer sur soi avec le clic droit"
L["REACTION"] = "Réaction"
L["RELATIVE_POINT"] = "Point relatif"
L["RELATIVE_POINT_DESC"] = "Le point auquel attacher l'objet."
L["RELOAD_NOW"] = "Recharger maintenant"
L["RESTRICTED_MODE_DESC"] = [=[Active l'illustration, les animations et le redimensionnement dynamique de la barre d'action principale.
|cffdc4436Attention !|r Certaines options de personnalisation des barres d'action ne seront pas disponibles dans ce mode.|r]=]
L["RIGHT"] = "Droite"
L["RIGHT_DOWN"] = "Droite et vers le bas"
L["RIGHT_UP"] = "Droite et vers le haut"
L["ROWS"] = "Lignes"
L["SECOND_ANCHOR"] = "Deuxième point d'attache"
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
L["SORT_DIR"] = "Direction de tri"
L["SORT_METHOD"] = "Méthode de tri"
L["SPACING"] = "Espacement"
L["STANCE_BAR"] = "Barre de posture"
L["TARGET_FRAME"] = "Cadre de la cible"
L["TARGET_INFO"] = "Info de la cible"
L["TARGET_INFO_DESC"] = "Afficher l'info-bulle de la cible actuelle."
L["TARGET_TOT"] = "Cible & Cible de la cible"
L["TEXT"] = "Texte"
L["TEXT_HORIZ_ALIGNMENT"] = "Alignement horizontal"
L["TEXT_VERT_ALIGNMENT"] = "Alignement vertical"
L["THREAT_GLOW"] = "Lueur de menace"
L["TIME"] = "Temps"
L["TOF_FRAME"] = "Cadre de la cible du focus"
L["TOGGLE_ANCHORS"] = "Basculer les points d'attache"
L["TOOLTIP_IDS"] = "ID des sorts et des objets"
L["TOOLTIPS"] = "Info-bulles"
L["TOP_INSET_SIZE"] = "Taille de l'encart supérieur"
L["TOP_INSET_SIZE_DESC"] = "Utilisé par barre de puissance de la classe, alternative et supplémentaire."
L["TOT_FRAME"] = "Cadre de la cible de la cible"
L["TOTEMS"] = "Totems"
L["UNITS"] = "Unité"
L["UP"] = "Haut"
L["USE_BLIZZARD_VEHICLE_UI"] = "Utiliser l'IU de Blizzard pour le véhicule"
L["VALUE"] = "Valeur"
L["VAR"] = "Variable"
L["VEHICLE_EXIT_BUTTON"] = "Bouton de sortie de véhicule"
L["VERY_DIFFICULT"] = "Très difficile"
L["VISIBILITY"] = "Visibilité"
L["WIDTH"] = "Largeur"
L["WIDTH_OVERRIDE"] = "Régler la largeur"
L["WORD_WRAP"] = "Retour à la ligne automatique"
L["X_OFFSET"] = "Décalage X"
L["XP_BAR"] = "Barre d'XP"
L["Y_OFFSET"] = "Décalage Y"
L["YOURS_FIRST"] = "Les vôtres en premier"
L["ZONE_ABILITY_BUTTON"] = "Zone de bouton d'abilité"
