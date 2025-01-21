/*
	*| Сторожевые пушки от Shadow_Collider ft. MrArni: vk.com/slime_code (vk.com/id206739351)
	*| Counter-Strinke Sentry Mod - CSSM
	*| Группа разработчика: vk.com/amxxcoder (vk.com/club200156025)
	*| Сайт: http://cgfrom.great-site.net/
	
	Версия: 0.8.1-b
	Снапшот: 1.1
	
	Примечания:
	*| Поменять в серверном файле ./cstrike/delta.lst значение body с 8 на 18(минимум)!
	
	Что нового:
	*| Полностью переписанные пушки, с более понятным кодом
	*| Квары наконец-то заехали
	*| Обновленная модель
	
	Огромная благодарность следующим людям:
	*| Александр Мишуткин - vk.com/almy_cs16 (vk.com/id242971261) - идеи, предложения, фикс, поддержка
	*| Владислав Верхогляд - vk.com/trojanranson (vk.com/id91783239) - идеи, предложения, фикс, поддержка, - нервные клетки
	*| Евгений Крестов - vk.com/evgexakrest (vk.com/id340104502) - крутые идеи, предложения, и предложения на будущие обновления
	*| Алексей Пармененков - vk.com/pariarx (vk.com/id8458823)- полная поддержка с выделенным сервером, краш-тест сервера, контроль статистики используемых ресурсов пушками
	
	Отдельная благодарность:
	*| BiZa Je - Поиск ошибок на линукс, тестирование, краштест
	
	Примечания:
	*| Герой, Раздатчик, Лазеры не в этой версии
	*| Следующее обновление начнется с новой модели пушки, лично полностью сделанной мною.
	*| Скудные нативы пока что... В новых версиях, некоторые вещи уйдут в форварды и отдельные плагины...
	*| Возможно, будет инклуд, пушки медленно превращаются в отдельный мод.
	*| Если этот комментарий присутствует, то Вы соблюдаете правила распространения исходным кодом.
	*| Авторство принадлежит Shadow_Collider, ссылка на него должна быть указана в коде.
	*| Если вы изменяете исходный код, то это не делает вас автором пушек, менять автора или дописывать себя - неприемлемо, используйте теги, характерные *Edit*.
	*| Нарушитель будет заблокирован на всех платформах, связанных со мной.
	*| Для получения полной информации о лицензии см. LICENSE.txt.
	*| CGFROM - 2023.
	
	*| Да будут пушки с открытым исходным кодом!
	*| Если есть идеи для дальнейших обновлений, то пишите в личку группы.
	
	Вы можете отблагодарить скриптера за его труды, и мотивировать на скорое написание новой версии
	*| BitCoin
	*| 3QXh3XaMakNTd3o9CJCEyei3pqW5Z2ykYH
	
	*| Card (RUS)
	*| 2202 2015 4748 9472
	
	*| QIWI
	*| SHADOWCOLLIDER
	
*/

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fakemeta_util>
#include <hamsandwich>
#include <cgfrom>
#include <cgfrom_sentry>

// #pragma compress 1

#define PLUGIN_NAME				"[CSSM] Ultimate Sentry Guns"
#define PLUGIN_VERSION			"0.8.1-b"
#define PLUGIN_SNAPSHOT			"1.1"
#define PLUGIN_AUTOR			"Shadow_Collider"

#define WEAPON_CROSSHAIR 		(1<<6)

// #define OFFSET_LINUXWEAPON	4
#define OFFSET_LINUX			5
#define OFFSET_LINUX_STEP		20
// #define OFFSET_ID			43
#define OFFSET_CLIPAMMO			51
// #define OFFSET_ACTIVITY		73
// #define OFFSET_IDEALACTIVITY	74
#define OFFSET_LASTHIT			75
#define OFFSET_PAINSHOCK		108
#define OFFSET_HASPRIMARY		116
#define OFFSET_HUD				361
#define OFFSET_ACTIVEITEM		373
#define OFFSET_HASPRIMARYX		464
#define OFFSET_SHIELDUSES		2042
#define OFFSET_SHIELDHAS		2043

#define SENTRY_VERT_STEP_1 		pev_controller_0
#define SENTRY_VERT_STEP_2 		pev_controller_1
#define SENTRY_HOR		 		pev_controller_2
#define SENTRY_GUNS		 		pev_controller_3


// Псевдоклассы
new 
model_list[class_model], sprite_list[class_sprite], sound_list[class_sound],
attr_damage[class_damage], attr_aura[class_aura_attr], attr_force[class_force],
message_list[message_event], setting[class_settings], sentry_health[class_health_sentry]

// Форварды
new
forward_aiming

// Подмодели
new 
submodel_sentry[13] = { 
	class_sentry_tower, 
	class_sentry_legs, 
	class_sentry_socket,
	class_sentry_aim, 
	class_sentry_rockets, 
	class_sentry_gun, 
	class_sentry_guns, 
	class_sentry_addone, 
	class_sentry_under, 
	class_sentry_holder, 
	class_sentry_icon_frame, 
	class_sentry_icon_up, 
	class_sentry_icon_down 
}
new submodel_message[2] = { class_message_alert, class_message_healthbar }

// Массивы
static Trie:sentry_list, Trie:rocket_list, Trie:weapon_list, Trie:any_list, access_set[class_access_sentry]

// Переменные
static user_equip[33][class_user], bool:bot_register, a1, a2, a3

// Главный метод
public plugin_init() {
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTOR)
	
	// События
	register_forward(FM_PlayerPreThink, "think_player_pre")
	register_forward(FM_CmdStart, "cmd_init")
	register_forward(FM_Think, "think_init")
	register_forward(FM_Touch, "touch_init")
	
	RegisterHam(Ham_Spawn, "player", "user_spawn_pre")
	RegisterHam(Ham_Spawn, "player", "user_spawn_post", true)
	RegisterHam(Ham_Killed, "player", "user_killed_pre")
	RegisterHam(Ham_Killed, "player", "user_killed_post", true)
	RegisterHam(Ham_TraceAttack, "func_breakable", "trace_damage_ent", true)
	RegisterHam(Ham_TakeDamage, "player", "take_damage_player_pre")
	RegisterHam(Ham_TakeDamage, "player", "take_damage_player_post", true)
	RegisterHam(Ham_TakeDamage, "func_breakable", "take_damage_ent")
	RegisterHam(Ham_Touch, "func_breakable", "touch_entity")
	
	// Команды
	register_srvcmd("cssm version", "cssm_version", _, "- cssm version")
	register_concmd("sentry_build", "build_init_sentry", _, "- build sentry")
	register_concmd("size_sentry_list", "size_sentry_list")
	register_concmd("sentry_build_any", "build_init_sentry_any", ADMIN_IMMUNITY, "<level> <module> <aura>")
	
	// Меню
	register_menu("show_sentry_menu", _sentry_menu_full, "set_sentry_menu")
	
	//
	forward_aiming =  CreateMultiForward("forward_aiming", ET_CONTINUE, FP_CELL, FP_CELL)
	
	// Сообщения
	message_list[_msg_money] = get_user_msgid("Money")
	message_list[_msg_saytext] = get_user_msgid("SayText")
	// message_list[_msg_death] = get_user_msgid("DeathMsg")
	// message_list[_msg_damage] = get_user_msgid("Damage")
	// message_list[_msg_score] = get_user_msgid("ScoreInfo")
	message_list[_msg_crosshair] = get_user_msgid("Crosshair")
	message_list[_msg_screen_shake] = get_user_msgid("ScreenShake")
	message_list[_msg_screen_fade] = get_user_msgid("ScreenFade")
	
	a1 = register_cvar("a1", "0")
	a2 = register_cvar("a2", "0")
	a3 = register_cvar("a3", "0")
	get_pcvar_num(a1)
	get_pcvar_num(a2)
	get_pcvar_num(a3)
}

// Вывод данных
public cssm_version() {
	server_print("%s - %s (%s) - %s", PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_SNAPSHOT, PLUGIN_AUTOR)
}

//Прекеш
public plugin_precache() {
	// Файлы
	register_dictionary("ultimate_sentry_guns.txt")
	
	// Загрузка cfg
	plugin_cfg_default()
	plugin_cfg_load()
	
	// Обработка моделей
	engfunc(EngFunc_PrecacheModel, "sprites/arrow1.spr")
	engfunc(EngFunc_PrecacheModel, model_list[_model_build])
	engfunc(EngFunc_PrecacheModel, model_list[_model_alert])
	engfunc(EngFunc_PrecacheModel, model_list[_model_ice])
	engfunc(EngFunc_PrecacheModel, model_list[_model_rocket_nuclear])
	engfunc(EngFunc_PrecacheModel, model_list[_model_rocket_fire])
	engfunc(EngFunc_PrecacheModel, model_list[_model_rocket_gas])
	engfunc(EngFunc_PrecacheModel, model_list[_model_plasma_fire])
	model_list[_model_shield_break_id] = engfunc(EngFunc_PrecacheModel, model_list[_model_shield_break])
	model_list[_model_sentry_break_id_1] = engfunc(EngFunc_PrecacheModel, model_list[_model_sentry_break_1])
	model_list[_model_sentry_break_id_2] = engfunc(EngFunc_PrecacheModel, model_list[_model_sentry_break_2])
	model_list[_model_sentry_break_id_3] = engfunc(EngFunc_PrecacheModel, model_list[_model_sentry_break_3])
	
	// Обработка спрайтов
	sprite_list[_sprite_destroy] = engfunc(EngFunc_PrecacheModel, sprite_list[_sprite_destroy])
	// sprite_list[_sprite_blood] = engfunc(EngFunc_PrecacheModel, sprite_list[_sprite_blood])
	// sprite_list[_sprite_bloodspray] = engfunc(EngFunc_PrecacheModel, sprite_list[_sprite_bloodspray])
	sprite_list[_sprite_aura_beam] = engfunc(EngFunc_PrecacheModel, sprite_list[_sprite_aura_beam])
	sprite_list[_sprite_rocket_follow] = engfunc(EngFunc_PrecacheModel, sprite_list[_sprite_rocket_follow])
	sprite_list[_sprite_nuclear_small] = engfunc(EngFunc_PrecacheModel, sprite_list[_sprite_nuclear_small])
	sprite_list[_sprite_nuclear_big] = engfunc(EngFunc_PrecacheModel, sprite_list[_sprite_nuclear_big])
	sprite_list[_sprite_fire_small] = engfunc(EngFunc_PrecacheModel, sprite_list[_sprite_fire_small])
	sprite_list[_sprite_fire_big] = engfunc(EngFunc_PrecacheModel, sprite_list[_sprite_fire_big])
	sprite_list[_sprite_gas_small] = engfunc(EngFunc_PrecacheModel, sprite_list[_sprite_gas_small])
	sprite_list[_sprite_gas_big] = engfunc(EngFunc_PrecacheModel, sprite_list[_sprite_gas_big])
	sprite_list[_sprite_plase_shot] = engfunc(EngFunc_PrecacheModel, sprite_list[_sprite_plase_shot])
	sprite_list[_sprite_beam_laser] = engfunc(EngFunc_PrecacheModel, sprite_list[_sprite_beam_laser])
	sprite_list[_sprite_beam_electric] = engfunc(EngFunc_PrecacheModel, sprite_list[_sprite_beam_electric])
	sprite_list[_sprite_plase_exp] = engfunc(EngFunc_PrecacheModel, sprite_list[_sprite_plase_exp])
	sprite_list[_sprite_muzzleflash] = engfunc(EngFunc_PrecacheModel, sprite_list[_sprite_muzzleflash])
	sprite_list[_sprite_laser] = engfunc(EngFunc_PrecacheModel, sprite_list[_sprite_laser])
	sprite_list[_sprite_electric] = engfunc(EngFunc_PrecacheModel, sprite_list[_sprite_electric])
	
	// Обработка звуков
	engfunc(EngFunc_PrecacheSound, "debris/bustglass1.wav")
	engfunc(EngFunc_PrecacheSound, "debris/bustglass2.wav")
	engfunc(EngFunc_PrecacheSound, "debris/bustglass3.wav")
	engfunc(EngFunc_PrecacheSound, "debris/bustmetal1.wav")
	engfunc(EngFunc_PrecacheSound, "debris/bustmetal2.wav")
	engfunc(EngFunc_PrecacheSound, "debris/glass1.wav")
	engfunc(EngFunc_PrecacheSound, "debris/glass2.wav")
	engfunc(EngFunc_PrecacheSound, "debris/glass3.wav")
	engfunc(EngFunc_PrecacheSound, "debris/glass4.wav")
	engfunc(EngFunc_PrecacheSound, "debris/metal1.wav")
	engfunc(EngFunc_PrecacheSound, "debris/metal2.wav")
	engfunc(EngFunc_PrecacheSound, "debris/metal3.wav")
	engfunc(EngFunc_PrecacheSound, "debris/metal4.wav")
	engfunc(EngFunc_PrecacheSound, "debris/metal5.wav")
	engfunc(EngFunc_PrecacheSound, "debris/metal6.wav")
	engfunc(EngFunc_PrecacheSound, sound_list[_sound_build])
	engfunc(EngFunc_PrecacheSound, sound_list[_sound_upgrade])
	engfunc(EngFunc_PrecacheSound, sound_list[_sound_wave])
	engfunc(EngFunc_PrecacheSound, sound_list[_sound_repair])
	engfunc(EngFunc_PrecacheSound, sound_list[_sound_breaking])
	engfunc(EngFunc_PrecacheSound, sound_list[_sound_alert])
	engfunc(EngFunc_PrecacheSound, sound_list[_sound_shot])
	engfunc(EngFunc_PrecacheSound, sound_list[_sound_plasma_shot])
	engfunc(EngFunc_PrecacheSound, sound_list[_sound_plasma_exp])
	engfunc(EngFunc_PrecacheSound, sound_list[_sound_missile_rocket])
	engfunc(EngFunc_PrecacheSound, sound_list[_sound_rocket_explosion])
	engfunc(EngFunc_PrecacheSound, sound_list[_sound_rocket_fly])
	engfunc(EngFunc_PrecacheSound, sound_list[_sound_laser])
	engfunc(EngFunc_PrecacheSound, sound_list[_sound_electric])
	engfunc(EngFunc_PrecacheSound, sound_list[_sound_ice_use])
	engfunc(EngFunc_PrecacheSound, sound_list[_sound_ice_break])
}

// Регистрация нативов
public plugin_natives() {
	register_native("get_sentry_list", "native_get_sentry_list", 1)
	register_native("get_sentry_setting", "native_get_sentry_setting", 1)
	register_native("get_sentry_health", "native_get_sentry_health", 1)
	register_native("get_sentry_count", "native_get_sentry_count", 1)
	register_native("get_sentry_count_max", "native_get_sentry_count_max", 1)
	register_native("set_user_clear", "native_set_user_clear", 1)
	register_native("set_sentry_clear", "native_set_sentry_clear", 1)
}

// Натив получения количества пушек у пользователя
public Trie:native_get_sentry_list() {	
	return sentry_list
}

// Натив получения количества пушек у пользователя
public native_get_sentry_setting(attr) {	
	return setting[attr]
}

// Натив получения количества пушек у пользователя
public Float:native_get_sentry_health(ent, type) {
	static data[class_sentry]
	
	data_get(sentry_list, ent, data, sizeof data)	
	
	return sentry_health_get(data[_sentry_level] - 1, type)
}

// Натив получения количества пушек у пользователя
public native_get_sentry_count(id) {
	if (!is_user_connected(id))
	return 0
	
	return sentry_user_count(id)
}

// Натив получения максимально возможного количества пушек у игрока
public native_get_sentry_count_max(id) {
	if (!is_user_connected(id))
	return 0
	
	static data_access[class_access]
	
	return data_user_clamp(id, access_set[_access_sentry_count], data_access, sizeof data_access, true)
}

// Натив очисти данных игрока
public native_set_user_clear(id) {
	user_clear(id)
}

// Натив удаления всех пушек игрока
public native_set_sentry_clear(id) {
	sentry_user_destroy(id)
}

// Настойка кфг
public plugin_cfg_default() {
	// setting[_sentry_cost_module] = ArrayCreate(1, 1)
	setting[_sentry_sprite_module] = ArrayCreate(64, 1)
	setting[_sentry_sprite_aura] = ArrayCreate(64, 1)
	setting[_sentry_sprite_aura_color] = ArrayCreate(class_color)
	setting[_sentry_sprite_module_damage_color] = ArrayCreate(class_color)
	
	// Обработка переменных
	sentry_list = TrieCreate()
	rocket_list = TrieCreate()
	weapon_list = TrieCreate()
	any_list = TrieCreate()
	
	access_set[_access_sentry_count] = TrieCreate()
	access_set[_access_sentry_reward] = TrieCreate()
	access_set[_access_sentry_reward_broker] = TrieCreate()
	
	// Айди обработки запроса к оружию
	static weap_name[32], i
	
	for (i = CSW_P228; i <= CSW_P90; i++) {
		get_weaponname(i, weap_name, charsmax(weap_name))
		
		if (weap_name[0] == EOS)
		continue
		
		RegisterHam(Ham_Item_GetItemInfo, weap_name, "ham_item_getiteminfo", true)
	}
}

// Загрузка кфг
public plugin_cfg_load() {
	new path[64]
	get_configsdir(path, charsmax(path))
	format(path, charsmax(path), "%s/%s", path, "ultimate_sentry_guns.ini")
	
	if (!file_exists(path)) {
		server_print("%L %L", LANG_SERVER, "USG_TAG_CONSOLE", LANG_SERVER, "USG_ERROR_LOADCONFIG")
		return PLUGIN_CONTINUE
	}
	
	// Если не хватит, сами добавите
	new line[512], category, key[256], attr[256], file = fopen(path, "rt")
	
	while (file && !feof(file)) {
		fgets(file, line, charsmax(line))
		
		if (line[0] == '[') {
			category++
			continue
		}
		
		strtok(line, key, charsmax(key), attr, charsmax(attr), '=')
		trim(key)
		trim(attr)
		plugin_cfg_change(category, key, attr)
	}
	
	fclose(file)
	
	return PLUGIN_CONTINUE
}

// Парсинг данных с файла
public plugin_cfg_change(category, key[256], attr[256]) {
	new i = 0, buffer[128], color[9]
	
	if (key[0] == EOS || key[0] == ';')
	return
	
	switch (category) {
		case _cfg_setting: {
			if (equal(key, "SENTRY UPGRADE TOUCH"))
			setting[_sentry_upgrade_touch] = bool:str_to_num(attr)
			else if (equal(key, "SENTRY SHOT COMPLEX"))
			setting[_sentry_shot_complex] = bool:str_to_num(attr)
			else if (equal(key, "SENTRY COMMON SOLID"))
			setting[_sentry_common_solid] = bool:str_to_num(attr)
			else if (equal(key, "SENTRY AIM SENTRY"))
			setting[_sentry_aim_sentry] = bool:str_to_num(attr)
			else if (equal(key, "SENTRY SHOT BREAK"))
			setting[_sentry_shot_break] = bool:str_to_num(attr)
			else if (equal(key, "SENTRY DAMAGE MULTI"))
			setting[_sentry_damage_multi] = str_to_float(attr)
			else if (equal(key, "SENTRY DAMAGE USER"))
			setting[_sentry_damage_user] = str_to_float(attr)
			else if (equal(key, "SENTRY DAMAGE SENTRY"))
			setting[_sentry_damage_sentry] = str_to_float(attr)
			else if (equal(key, "SENTRY SHOT TIME"))
			setting[_sentry_shot_time] = str_to_float(attr)
			else if (equal(key, "SENTRY ROCKET AI"))
			setting[_sentry_rocket_ai] = bool:str_to_num(attr)
			else if (equal(key, "SENTRY ROCKET COUNT"))
			setting[_sentry_rocket_count] = str_to_num(attr)
			else if (equal(key, "SENTRY ROCKET LIFE"))
			setting[_sentry_rocket_lifetime] = str_to_float(attr)
			else if (equal(key, "SENTRY ROCKET SPEED"))
			setting[_sentry_rocket_speed] = str_to_float(attr)
			else if (equal(key, "SENTRY ROCKET TIME"))
			setting[_sentry_rocket_time] = str_to_float(attr)
			else if (equal(key, "SENTRY ROCKET CLAMP"))
			setting[_sentry_rocket_clamp] = str_to_float(attr)
			else if (equal(key, "SENTRY ROCKET TIME BETWEEN"))
			setting[_sentry_rocket_between_time] = str_to_float(attr)
			else if (equal(key, "SENTRY REPAIR TIME"))
			setting[_sentry_repair_time] = str_to_float(attr)
			else if (equal(key, "SENTRY CRASH LEVEL"))
			setting[_sentry_crash_level] = str_to_num(attr)
			else if (equal(key, "SENTRY REPAIR VALUE"))
			setting[_sentry_repair_value] = str_to_num(attr)
			else if (equal(key, "SENTRY COST DAMAGE"))
			setting[_sentry_cost_damage] = str_to_num(attr)
			else if (equal(key, "SENTRY COST REPAIR"))
			setting[_sentry_cost_repair] = str_to_num(attr)
			else if (equal(key, "SENTRY MULTI DAMAGE"))
			setting[_sentry_multi_damage] = str_to_float(attr)
			else if (equal(key, "SENTRY EXPLOSION DAMAGE"))
			setting[_sentry_explosion_damage] = str_to_float(attr)
			else if (equal(key, "SENTRY VERTICAL LIMIT"))
			setting[_sentry_vertical_limit] = str_to_float(attr)
			else if (equal(key, "SENTRY INVISIBLE LIMIT"))
			setting[_sentry_invisible_limit] = str_to_float(attr)
		}
		case _cfg_health: {
			if (equal(key, "SENTRY HITBOX DAMAGE"))
			while (attr[0] != 0 && strtok(attr, key, charsmax(key), attr, charsmax(attr), ',')) {
				trim(key)
				trim(attr)
				sentry_health[_sentry_hitbox_damage][i] = str_to_float(key)
				i++
			}
			else if (equal(key, "SENTRY HEALTH HEAD MULTI"))
			sentry_health[_sentry_health_head_multi] = str_to_float(attr)
			else if (equal(key, "SENTRY HEALTH BASE MULTI"))
			sentry_health[_sentry_health_base_multi] = str_to_float(attr)
			else if (equal(key, "SENTRY HEALTH LEVEL"))
			while (attr[0] != 0 && strtok(attr, key, charsmax(key), attr, charsmax(attr), ',')) {
				trim(key)
				trim(attr)
				sentry_health[_sentry_health_level][i] = str_to_float(key)
				i++
			}
			else if (equal(key, "SENTRY HITS HEAD"))
			while (attr[0] != 0 && strtok(attr, key, charsmax(key), attr, charsmax(attr), ',')) {
				trim(key)
				trim(attr)
				sentry_health[_sentry_hits_head] |=  (1 << str_to_num(key))
				i++
			}
			else if (equal(key, "SENTRY HITS BASE"))
			while (attr[0] != 0 && strtok(attr, key, charsmax(key), attr, charsmax(attr), ',')) {
				trim(key)
				trim(attr)
				sentry_health[_sentry_hits_base] |= (1 << str_to_num(key))
				i++
			}
		}
		case _cfg_force: {
			if (equal(key, "SENTRY RADIUS NUCLEAR"))
			attr_force[_force_sentry_radius_nuclear] = str_to_float(attr)
			else if (equal(key, "SENTRY RADIUS FIRE"))
			attr_force[_force_sentry_radius_fire] = str_to_float(attr)
			else if (equal(key, "SENTRY RADIUS GAS"))
			attr_force[_force_sentry_radius_gas] = str_to_float(attr)
			else if (equal(key, "SENTRY RADIUS PLASMA"))
			attr_force[_force_sentry_radius_plasma] = str_to_float(attr)
			else if (equal(key, "SENTRY RADIUS EXP"))
			attr_force[_force_sentry_radius_exp] = str_to_float(attr)
			else if (equal(key, "SENTRY EXP FORCE"))
			attr_force[_force_sentry_exp_force] = str_to_float(attr)
		}
		case _cfg_attack_module_stats: {
			if (equal(key, "NUCLEAR TIME"))
			attr_damage[_dmg_nuc_time] = str_to_float(attr)
			else if (equal(key, "NUCLEAR DAMAGE EXPLOSION"))
			attr_damage[_dmg_nuc_damage_explosion] = str_to_float(attr)
			else if (equal(key, "NUCLEAR INTERVAL DAMAGE"))
			attr_damage[_dmg_nuc_interval_damage] = str_to_float(attr)
			else if (equal(key, "NUCLEAR INTERVAL TIME"))
			attr_damage[_dmg_nuc_interval_time] = str_to_float(attr)
			else if (equal(key, "FIRE TIME"))
			attr_damage[_dmg_fire_time] = str_to_float(attr)
			else if (equal(key, "FIRE DAMAGE EXPLOSION"))
			attr_damage[_dmg_fire_damage_explosion] = str_to_float(attr)
			else if (equal(key, "FIRE INTERVAL DAMAGE"))
			attr_damage[_dmg_fire_interval_damage] = str_to_float(attr)
			else if (equal(key, "FIRE INTERVAL TIME"))
			attr_damage[_dmg_fire_interval_time] = str_to_float(attr)
			else if (equal(key, "GAS TIME"))
			attr_damage[_dmg_gas_time] = str_to_float(attr)
			else if (equal(key, "GAS DAMAGE EXPLOSION"))
			attr_damage[_dmg_gas_damage_explosion] = str_to_float(attr)
			else if (equal(key, "GAS INTERVAL DAMAGE"))
			attr_damage[_dmg_gas_interval_damage] = str_to_float(attr)
			else if (equal(key, "GAS INTERVAL TIME"))
			attr_damage[_dmg_gas_interval_time] = str_to_float(attr)
			else if (equal(key, "SHOTGUN DAMAGE"))
			attr_damage[_dmg_shotgun_damage] = str_to_float(attr)
			else if (equal(key, "PLASMA DAMAGE"))
			attr_damage[_dmg_plasm_damage] = str_to_float(attr)
			else if (equal(key, "PLASMA INTERVAL SHOT"))
			attr_damage[_dmg_plasm_interval_shot] = str_to_float(attr)
			else if (equal(key, "PLASMA SPEED SHOT"))
			attr_damage[_dmg_plasm_speed_shot] = str_to_float(attr)
			else if (equal(key, "LASER DAMAGE"))
			attr_damage[_dmg_laser_damage] = str_to_float(attr)
			else if (equal(key, "LASER INTERVAL SHOT"))
			attr_damage[_dmg_laser_interval_shot] = str_to_float(attr)
			else if (equal(key, "ELECTRIC DAMAGE"))
			attr_damage[_dmg_electric_damage] = str_to_float(attr)
			else if (equal(key, "ELECTRIC INTERVAL SHOT"))
			attr_damage[_dmg_electric_interval_shot] = str_to_float(attr)
			else if (equal(key, "ELECTRIC DIST SCAN"))
			attr_damage[_dmg_electric_dist_scan] = str_to_float(attr)
			else if (equal(key, "ELECTRIC COUNT TRACE"))
			attr_damage[_dmg_electric_count_trace] = str_to_num(attr)
			else if (equal(key, "HOOK INTERVAL"))
			attr_damage[_dmg_hook_interval] = str_to_float(attr)
			else if (equal(key, "DAMAGE FROZE EXP"))
			attr_damage[_dmg_damage_froze_exp] = str_to_float(attr)
			else if (equal(key, "SHIELD DURABILITY"))
			attr_damage[_dmg_shield_durability] = str_to_float(attr)
		}
		case _cfg_aura_stats: {
			if (equal(key, "SENTRY AURA TIME"))
			attr_aura[_aura_time] = str_to_float(attr)
			else if (equal(key, "SENTRY AURA DIST"))
			attr_aura[_aura_dist] = str_to_float(attr)
			else if (equal(key, "VAMPIRISM MAX VALUE"))
			attr_aura[_aura_vampirism_max_value] = str_to_float(attr)
			else if (equal(key, "VAMPIRISM CHANCE"))
			attr_aura[_aura_vampirism_chance] = str_to_num(attr)
			else if (equal(key, "VAMPIRISM MAX CLAMP"))
			attr_aura[_aura_vampirism_max_clamp] = str_to_float(attr)
			else if (equal(key, "MIRROR CHANCE"))
			attr_aura[_aura_mirror_chance] = str_to_num(attr)
			else if (equal(key, "MIRROR MAX CLAMP"))
			attr_aura[_aura_mirror_max_clamp] = str_to_float(attr)
			else if (equal(key, "CRITICAL CHANCE"))
			attr_aura[_aura_critical_chance] = str_to_num(attr)
			else if (equal(key, "FROZE CHANCE"))
			attr_aura[_aura_froze_chance] = str_to_num(attr)
			else if (equal(key, "FROZE DURABILITY"))
			attr_aura[_aura_froze_durability] = str_to_float(attr)
			else if (equal(key, "AMMO CHANCE"))
			attr_aura[_aura_ammo_chance] = str_to_num(attr)
			else if (equal(key, "AMMO COUNT ADD"))
			attr_aura[_aura_ammo_count_add] = str_to_num(attr)
			else if (equal(key, "VANISH AMOUNT"))
			attr_aura[_aura_vanish_amount] = str_to_float(attr)
			else if (equal(key, "SHAKE CHANCE"))
			attr_aura[_aura_shake_chance] = str_to_num(attr)
		}
		case _cfg_bone: {
			if (equal(key, "SENTRY BONE AIM"))
			setting[_sentry_bone_aim] = str_to_num(attr)
			else if (equal(key, "SENTRY BONE HEAD"))
			setting[_sentry_bone_head] = str_to_num(attr)
			else if (equal(key, "SENTRY BONE MAIN"))
			setting[_sentry_bone_main] = str_to_num(attr)
			else if (equal(key, "SENTRY BONE LEFT"))
			setting[_sentry_bone_left] = str_to_num(attr)
			else if (equal(key, "SENTRY BONE RIGHT"))
			setting[_sentry_bone_right] = str_to_num(attr)
			else if (equal(key, "SENTRY BONE ROCKET LEFT"))
			setting[_sentry_bone_rocket_left] = str_to_num(attr)
			else if (equal(key, "SENTRY BONE ROCKET RIGHT"))
			setting[_sentry_bone_rocket_right] = str_to_num(attr)
			else if (equal(key, "SENTRY BONE LASER LEFT"))
			setting[_sentry_bone_laser_left] = str_to_num(attr)
			else if (equal(key, "SENTRY BONE LASER RIGHT"))
			setting[_sentry_bone_laser_right] = str_to_num(attr)
		}
		case _cfg_access_addition: {
			if (equal(key, "SENTRY LEVEL MODULE"))
			while (attr[0] != 0 && strtok(attr, key, charsmax(key), attr, charsmax(attr), ',')) {
				trim(key)
				trim(attr)
				access_set[_access_module][i] = read_flags(key)
				i++
			}
			else if (equal(key, "SENTRY LEVEL AURA"))
			while (attr[0] != 0 && strtok(attr, key, charsmax(key), attr, charsmax(attr), ',')) {
				trim(key)
				trim(attr)
				access_set[_access_aura][i] = read_flags(key)
				i++  
			}
			else if (equal(key, "SENTRY RESET"))
			access_set[_access_sentry_reset] = read_flags(attr)
			else if (equal(key, "SENTRY UPDATE SELF"))
			access_set[_access_sentry_update_self] = read_flags(attr)
			else if (equal(key, "SENTRY VIP SKIN"))
			access_set[_access_sentry_vip_skin] = read_flags(attr)
		}
		case _cfg_access_count: {
			static data[class_access]
			data[_value] = str_to_num(attr) 
			
			data_set_s(access_set[_access_sentry_count], key, data, sizeof data)
		}
		case _cfg_access_reward: {
			static data[class_access]
			
			data[_value] = str_to_num(attr)
			data_set_s(access_set[_access_sentry_reward], key, data, sizeof data)
		}
		case _cfg_access_reward_broker: {
			static data[class_access]
			
			data[_value] = str_to_num(attr)
			data_set_s(access_set[_access_sentry_reward_broker], key, data, sizeof data)
			
		}
		case _cfg_cost_items: {
			if (equal(key, "COST LEVEL 1"))
			setting[_sentry_cost_1] = str_to_num(attr)
			else if (equal(key, "COST LEVEL 2"))
			setting[_sentry_cost_2] = str_to_num(attr)
			else if (equal(key, "COST LEVEL 3"))
			setting[_sentry_cost_3] = str_to_num(attr)
			else if (equal(key, "COST MODULE"))
			while (attr[0] != 0 && strtok(attr, key, charsmax(key), attr, charsmax(attr), ',')) {
				trim(key)
				trim(attr)
				setting[_sentry_cost_module][i] = str_to_num(key)
				i++
			}
			else if (equal(key, "COST AURA"))
			while (attr[0] != 0 && strtok(attr, key, charsmax(key), attr, charsmax(attr), ',')) {
				trim(key)
				trim(attr)
				setting[_sentry_cost_aura][i] = str_to_num(key)
				i++
			}
			else if (equal(key, "COST RESET"))
			setting[_sentry_cost_reset] = str_to_num(attr)
		}
		case _cfg_attr_sprite_items: {
			if (equal(key, "COLOR SPRITE AURA"))
			while (attr[0] != 0 && strtok(attr, key, charsmax(key), attr, charsmax(attr), ',')) {
				new j, colors[class_color]
				trim(key)
				trim(attr)
				while (key[0] != 0 && strtok(key, color, charsmax(color), key, charsmax(key), ' ')) {
					colors[j] = str_to_num(color)
					j++
				}
				ArrayPushArray(setting[_sentry_sprite_aura_color], colors)
			}
			else if (equal(key, "COLOR SPRITE MODULE DAMAGE"))
			while (attr[0] != 0 && strtok(attr, key, charsmax(key), attr, charsmax(attr), ',')) {
				new j, colors[class_color]
				trim(key)
				trim(attr)
				while (key[0] != 0 && strtok(key, color, charsmax(color), key, charsmax(key), ' ')) {
					colors[j] = str_to_num(color)
					j++
				}
				ArrayPushArray(setting[_sentry_sprite_module_damage_color], colors)
			}
			else if (equal(key, "SIZE BEAM LASER"))
			setting[_sentry_size_beam_laser] = str_to_num(attr)
			else if (equal(key, "SIZE BEAM ELECTRIC"))
			setting[_sentry_size_beam_electric] = str_to_num(attr)
			else if (equal(key, "FLUCT BEAM LASER"))
			setting[_sentry_fluct_beam_laser] = str_to_num(attr)
			else if (equal(key, "FLUCT BEAM ELECTRIC"))
			setting[_sentry_fluct_beam_electric] = str_to_num(attr)
		}
		case _cfg_model: {
			if (equal(key, "MODEL SENTRY"))
			copy(model_list[_model_build], charsmax(model_list[_model_build]), attr)
			else if (equal(key, "MODEL ALERT"))
			copy(model_list[_model_alert], charsmax(model_list[_model_alert]), attr)
			else if (equal(key, "MODEL ICE"))
			copy(model_list[_model_ice], charsmax(model_list[_model_ice]), attr)
			else if (equal(key, "MODEL ROCKET NUCLEAR"))
			copy(model_list[_model_rocket_nuclear], charsmax(model_list[_model_rocket_nuclear]), attr)
			else if (equal(key, "MODEL ROCKET FIRE"))
			copy(model_list[_model_rocket_fire], charsmax(model_list[_model_rocket_fire]), attr)
			else if (equal(key, "MODEL ROCKET GAS"))
			copy(model_list[_model_rocket_gas], charsmax(model_list[_model_rocket_gas]), attr)
			else if (equal(key, "MODEL PLASMA FIRE"))
			copy(model_list[_model_plasma_fire], charsmax(model_list[_model_plasma_fire]), attr)
			else if (equal(key, "MODEL SHIELD BREAK"))
			copy(model_list[_model_shield_break], charsmax(model_list[_model_shield_break]), attr)
			else if (equal(key, "MODEL SENTRY BREAK 1"))
			copy(model_list[_model_sentry_break_1], charsmax(model_list[_model_sentry_break_1]), attr)
			else if (equal(key, "MODEL SENTRY BREAK 2"))
			copy(model_list[_model_sentry_break_2], charsmax(model_list[_model_sentry_break_2]), attr)
			else if (equal(key, "MODEL SENTRY BREAK 3"))
			copy(model_list[_model_sentry_break_3], charsmax(model_list[_model_sentry_break_3]), attr)
		}
		case _cfg_sprite: {
			if (equal(key, "SPRITE DESTROY"))
			copy(sprite_list[_sprite_destroy], charsmax(sprite_list[_sprite_destroy]), attr)
			// else if (equal(key, "SPRITE BLOOD"))
			// copy(sprite_list[_sprite_blood], charsmax(sprite_list[_sprite_blood]), attr)
			// else if (equal(key, "SPRITE BLOODSPRAY"))
			// copy(sprite_list[_sprite_bloodspray], charsmax(sprite_list[_sprite_bloodspray]), attr)
			else if (equal(key, "SPRITE AURA BEAM"))
			copy(sprite_list[_sprite_aura_beam], charsmax(sprite_list[_sprite_aura_beam]), attr)
			else if (equal(key, "SPRITE ROCKET FOLLOW"))
			copy(sprite_list[_sprite_rocket_follow], charsmax(sprite_list[_sprite_rocket_follow]), attr)
			else if (equal(key, "SPRITE NUCLEAR SMALL"))
			copy(sprite_list[_sprite_nuclear_small], charsmax(sprite_list[_sprite_nuclear_small]), attr)
			else if (equal(key, "SPRITE NUCLEAR BIG"))
			copy(sprite_list[_sprite_nuclear_big], charsmax(sprite_list[_sprite_nuclear_big]), attr)
			else if (equal(key, "SPRITE FIRE SMALL"))
			copy(sprite_list[_sprite_fire_small], charsmax(sprite_list[_sprite_fire_small]), attr)
			else if (equal(key, "SPRITE FIRE BIG"))
			copy(sprite_list[_sprite_fire_big], charsmax(sprite_list[_sprite_fire_big]), attr)
			else if (equal(key, "SPRITE GAS SMALL"))
			copy(sprite_list[_sprite_gas_small], charsmax(sprite_list[_sprite_gas_small]), attr)
			else if (equal(key, "SPRITE GAS BIG"))
			copy(sprite_list[_sprite_gas_big], charsmax(sprite_list[_sprite_gas_big]), attr)
			else if (equal(key, "SPRITE PLASMA SHOT"))
			copy(sprite_list[_sprite_plase_shot], charsmax(sprite_list[_sprite_plase_shot]), attr)
			else if (equal(key, "SPRITE BEAM LASER"))
			copy(sprite_list[_sprite_beam_laser], charsmax(sprite_list[_sprite_beam_laser]), attr)
			else if (equal(key, "SPRITE BEAM ELECTRIC"))
			copy(sprite_list[_sprite_beam_electric], charsmax(sprite_list[_sprite_beam_electric]), attr)
			else if (equal(key, "SPRITE PLASMA EXP"))
			copy(sprite_list[_sprite_plase_exp], charsmax(sprite_list[_sprite_plase_exp]), attr)
			else if (equal(key, "SPRITE MUZZLEFLASH"))
			copy(sprite_list[_sprite_muzzleflash], charsmax(sprite_list[_sprite_muzzleflash]), attr)
			else if (equal(key, "SPRITE ELECTRIC"))
			copy(sprite_list[_sprite_electric], charsmax(sprite_list[_sprite_electric]), attr)
			else if (equal(key, "SPRITE LASER"))
			copy(sprite_list[_sprite_laser], charsmax(sprite_list[_sprite_laser]), attr)
			else if (equal(key, "SPRITE MODULE"))
			while (attr[0] != 0 && strtok(attr, key, charsmax(key), attr, charsmax(attr), ',')) {
				trim(key)
				trim(attr)
				format(buffer, charsmax(buffer), "sprites/cgfrom/%s", key)
				engfunc(EngFunc_PrecacheModel, buffer)
				ArrayPushString(setting[_sentry_sprite_module], buffer)
			}
			else if (equal(key, "SPRITE AURA"))
			while (attr[0] != 0 && strtok(attr, key, charsmax(key), attr, charsmax(attr), ',')) {
				trim(key)
				trim(attr)
				format(buffer, charsmax(buffer), "sprites/cgfrom/%s", key)
				engfunc(EngFunc_PrecacheModel, buffer)
				ArrayPushString(setting[_sentry_sprite_aura], buffer)
			}
		}
		case _cfg_sound: {
			if (equal(key, "SOUND BUILD"))
			copy(sound_list[_sound_build], charsmax(sound_list[_sound_build]), attr)
			else if (equal(key, "SOUND UPGRADE"))
			copy(sound_list[_sound_upgrade], charsmax(sound_list[_sound_upgrade]), attr)
			else if (equal(key, "SOUND WAVE"))
			copy(sound_list[_sound_wave], charsmax(sound_list[_sound_wave]), attr)
			else if (equal(key, "SOUND REPAIR"))
			copy(sound_list[_sound_repair], charsmax(sound_list[_sound_repair]), attr)
			else if (equal(key, "SOUND BREAKING"))
			copy(sound_list[_sound_breaking], charsmax(sound_list[_sound_breaking]), attr)
			else if (equal(key, "SOUND ALERT"))
			copy(sound_list[_sound_alert], charsmax(sound_list[_sound_alert]), attr)
			else if (equal(key, "SOUND SHOT"))
			copy(sound_list[_sound_shot], charsmax(sound_list[_sound_shot]), attr)
			else if (equal(key, "SOUND PLASMA SHOT"))
			copy(sound_list[_sound_plasma_shot], charsmax(sound_list[_sound_plasma_shot]), attr)
			else if (equal(key, "SOUND PLASMA EXP"))
			copy(sound_list[_sound_plasma_exp], charsmax(sound_list[_sound_plasma_exp]), attr)
			else if (equal(key, "SOUND MISSILE ROCKET"))
			copy(sound_list[_sound_missile_rocket], charsmax(sound_list[_sound_missile_rocket]), attr)
			else if (equal(key, "SOUND ROCKET EXPLOSION"))
			copy(sound_list[_sound_rocket_explosion], charsmax(sound_list[_sound_rocket_explosion]), attr)
			else if (equal(key, "SOUND ROCKET FLY"))
			copy(sound_list[_sound_rocket_fly], charsmax(sound_list[_sound_rocket_fly]), attr)
			else if (equal(key, "SOUND LASER"))
			copy(sound_list[_sound_laser], charsmax(sound_list[_sound_laser]), attr)
			else if (equal(key, "SOUND ELECTRIC"))
			copy(sound_list[_sound_electric], charsmax(sound_list[_sound_electric]), attr)
			else if (equal(key, "SOUND ICE USE"))
			copy(sound_list[_sound_ice_use], charsmax(sound_list[_sound_ice_use]), attr)
			else if (equal(key, "SOUND ICE BREAK"))
			copy(sound_list[_sound_ice_break], charsmax(sound_list[_sound_ice_break]), attr)
		}
	}
}

// Запись данных базовых оружий в базу
public ham_item_getiteminfo(weap, item_info) {
	
	if (!item_info) {
		//
		return HAM_IGNORED
	}
	
	static data[class_weapon]
	
	data[_weapon_max_clip] = GetHamItemInfo(item_info, Ham_ItemInfo_iMaxClip)
	data_set(weapon_list, GetHamItemInfo(item_info, Ham_ItemInfo_iId), data, sizeof data)
	
	return HAM_IGNORED
}

// Команда для установки пушки с параметрами
public build_init_sentry_any(id) {
	if (!is_user_connected(id))
	return PLUGIN_CONTINUE
	
	new arg_level[2], arg_module[2], arg_aura[2]
	
	read_argv(1, arg_level, 1)
	read_argv(2, arg_module, 1)
	read_argv(3, arg_aura, 1)
	
	build_init_sentry(id, str_to_num(arg_level), str_to_num(arg_module) - 1, str_to_num(arg_aura) - 1)
	return PLUGIN_HANDLED
}

public size_sentry_list(id) {
	server_print("[SIZE] %d , %d", sizeof sentry_list, TrieGetSize(sentry_list))
}

// Команда для установки пушки без параметров
public build_init_sentry(id, level, module, aura) {
	if (!is_user_alive(id))
	return PLUGIN_CONTINUE
	
	static cost
	
	cost = standart_cost(0)
	
	if (cost > cs_get_user_money(id)) {
		client_chat(id, "%L %L", LANG_PLAYER, "USG_TAG", LANG_PLAYER, "USG_BLOCK_COST", cost - cs_get_user_money(id))
		return PLUGIN_CONTINUE
	}
	
	static data_access[class_access], Float:velocity[3], count, count_max
	
	pev(id, pev_velocity, velocity)
	count = sentry_user_count(id)
	count_max = data_user_clamp(id, access_set[_access_sentry_count], data_access, sizeof data_access, true)
	
	if (vector_length(velocity) > 140.0) {
		client_chat(id, "%L", LANG_PLAYER, "USG_BLOCK_MOVE")
		return PLUGIN_CONTINUE
	}
	if (count_max <= count) {
		client_chat(id, "%L %L", LANG_PLAYER, "USG_TAG", LANG_PLAYER, "USG_BLOCK_MAX", count, count_max)
		return PLUGIN_CONTINUE
	}
	
	build_sentry(id, level, module, aura)
	return PLUGIN_HANDLED
}

// Установка пушки
public build_sentry(id, level, module, aura) {
	static data[class_sentry], Float:pos_user[3], Float:angles_user[3], Float:pos_ent[3], Float:slant[3],
	Float:move[2], Float:min[3] = { -35.0, -35.0, 0.0 }, Float:max[3] = { 35.0, 35.0, 45.0 }
	
	pev(id, pev_origin, pos_user)
	pev(id, pev_angles, angles_user)
	
	user_arrow_move(id, move, 100.0)
	pos_ent[0] = pos_user[0] + move[0]
	pos_ent[1] = pos_user[1] + move[1]
	pos_ent[2] = pos_user[2]
	angles_user[0] = 0.0
	
	if (fm_trace_normal(id, pos_user, pos_ent, slant) || entity_hull(id, pos_ent, min, max, slant, 1.25)) {
		client_chat(id, "%L %L", LANG_PLAYER, "USG_TAG", LANG_PLAYER, "USG_BLOCK_NEAR")
		return PLUGIN_CONTINUE
	}
	
	new ent = fm_create_entity("func_breakable")
	
	if (!pev_valided(ent))
	return PLUGIN_CONTINUE
	
	fm_set_kvd(ent, "material", "6")
	
	min = Float:{ -15.0, -15.0, 0.0 }
	max = Float:{ 15.0, 15.0, 45.0 }
	
	engfunc(EngFunc_SetModel, ent, model_list[_model_build])
	engfunc(EngFunc_SetSize, ent, min, max)
	engfunc(EngFunc_SetOrigin, ent, pos_ent)
	
	if (entity_search_radius(sentry_list, id, ent, 100.0) || entity_solid_fly(id, ent)) {
		entity_kill(ent)
		return PLUGIN_CONTINUE
	}
	if (entity_solid_enter(id, pos_ent, HULL_HUMAN, -1, 0) || entity_solid_enter(id, pos_ent, HULL_LARGE, -1, 0)) {
		entity_kill(ent)
		return PLUGIN_CONTINUE
	}
	
	// data[_sentry_pos] = pos_ent
	data[_sentry_level] = clamp(level, 1, 5)
	data[_sentry_module] = clamp(module, 0, 6)
	data[_sentry_aura] = clamp(aura, 0, 6)
	data[_sentry_health][_sentry_health_head] = sentry_health_get(data[_sentry_level] - 1, _sentry_health_head_multi)
	data[_sentry_health][_sentry_health_base] = sentry_health_get(data[_sentry_level] - 1, _sentry_health_base_multi)
	data[_sentry_angles] = angles_user
	data[_sentry_owner] = id
	data[_sentry_self] = ent
	data[_sentry_update_several][data[_sentry_level]] = id
	data_set(sentry_list, ent, data, sizeof data)
	switch_sentry_skin(ent, id)
	
	set_pev(ent, pev_angles, angles_user)
	set_pev(ent, pev_movetype, MOVETYPE_TOSS)
	set_pev(ent, pev_solid, SOLID_BBOX)
	set_pev(ent, pev_classname, CLASSNAME_SENTRY)
	set_pev(ent, pev_team, get_user_team(id))
	set_pev(ent, pev_gravity, 3.0)
	set_pev(ent, pev_health, float(0xFFFF))
	set_pev(ent, pev_takedamage, DAMAGE_YES)
	set_pev(ent, SENTRY_VERT_STEP_1, 0)
	set_pev(ent, SENTRY_VERT_STEP_2, 0)
	set_pev(ent, SENTRY_HOR, 127)
	set_pev(ent, SENTRY_GUNS, 255)
	set_pev(ent, pev_nextthink, get_gametime() + 0.1)
	cs_set_user_money(id, cs_get_user_money(id) - standart_cost(0))
	
	engfunc(EngFunc_DropToFloor, ent)
	pev(ent, pev_origin, pos_ent)
	
	// static name[32]
	
	// get_user_name(id, name, charsmax(name))
	// server_print(">>> USER [%s] BUILD SENTRY: %d, LEVEL: %d, MODULE: %d, AURA: %d", name, ent, data[_sentry_level], data[_sentry_module], data[_sentry_aura])
	
	return PLUGIN_HANDLED
}

// Выбор скина пушек
public switch_sentry_skin(ent, id) {
	switch(cs_get_user_team(id)) {
		case CS_TEAM_CT: set_pev(ent, pev_skin, access_status(id, access_set[_access_sentry_vip_skin]) ? _skin_sentry_vip_ct : _skin_sentry_ct)
		case CS_TEAM_T: set_pev(ent, pev_skin, access_status(id, access_set[_access_sentry_vip_skin]) ? _skin_sentry_vip_tt : _skin_sentry_tt)
	}
}

// Отработка нажатий
public cmd_init(id, uc) {
	if (!pev_valided(id))
	return FMRES_IGNORED
	if (!is_user_alive(id))
	return FMRES_IGNORED
	if (user_equip[id][_user_time_key] + 0.1 > get_gametime())
	return FMRES_IGNORED
	
	static buttons[5], i
	
	user_equip[id][_user_time_key] = get_gametime()
	
	for (i = 1; i < sizeof buttons; i++)
	buttons[i - 1] = user_equip[id][_user_buttons][i]
	
	buttons[sizeof buttons - 1] = pev(id, pev_button)
	
	for (i = 0; i < sizeof buttons; i++)
	user_equip[id][_user_buttons][i] = buttons[i]
	
	if (cmd_clipped(buttons))
	cmd_use_down(id)
	else if (buttons[3] & IN_USE && ~buttons[4] & IN_USE)
	cmd_use_up(id)
	
	return FMRES_IGNORED
}

// Отработка зажатия клавиши Е
public cmd_use_down(id) {
	if (user_equip[id][_user_time_hold] > get_gametime())
	return
	
	static ent
	
	user_equip[id][_user_time_hold] = get_gametime() + 0.1
	get_user_aiming(id, ent, _, 100)
	
	if (pev(ent, pev_team) != get_user_team(id))
	return
	
	if (fm_is_ent_classname(ent, CLASSNAME_SENTRY))
	think_sentry_repair(id, ent)
}

// Отработка нажатия клавиши Е
public cmd_use_up(id) {
	static ent
	
	get_user_aiming(id, ent, _, 100)
	
	if (pev(ent, pev_team) != get_user_team(id))
	return
	
	if (fm_is_ent_classname(ent, CLASSNAME_SENTRY))
	menu_sentry(id, ent)
}

// Меню пушек
public menu_sentry(id, ent) {
	if (!is_user_alive(id))
	return PLUGIN_CONTINUE
	if (!pev_valided(ent))
	return PLUGIN_CONTINUE
	
	static menu[512], name[32], len, data[class_sentry], keys, balance, bool:status
	
	len = 0
	keys = 0
	status = false
	balance = cs_get_user_money(id)
	data_get(sentry_list, ent, data, sizeof data)
	user_equip[id][_user_select_ent] = ent
	
	if (data[_sentry_repairtime] + 0.5 >= get_gametime())
	return PLUGIN_CONTINUE
	if (data[_sentry_upgrade])
	return PLUGIN_CONTINUE
	
	data[_sentry_owner] == id ? formatex(name, charsmax(name), "%L", LANG_PLAYER, "USG_YOU") : get_user_name(data[_sentry_owner], name, charsmax(name))
	len += formatex(menu[len], charsmax(menu) - len, "%L", LANG_PLAYER, "USG_MENU_TITLE", name)
	
	switch(data[_sentry_level]) {
		case 3: {
			keys |= _sentry_menu_module
			len += formatex(menu[len], charsmax(menu) - len, "%s^n", menu_context(4, id, class_module_sentry))
		}
		case 4: {
			keys |= _sentry_menu_aura | _sentry_menu_reset
			status = menu_status(id, balance, setting[_sentry_cost_reset], access_set[_access_sentry_reset])
			
			len += formatex(menu[len], charsmax(menu) - len, "%s^n", menu_context(5, id, class_aura_sentry))
			len += formatex(menu[len], charsmax(menu) - len, "%s%L^n",
				menu_number(9),
				LANG_PLAYER, status ? "USG_MENU_RESET" : "USG_MENU_RESET_CANT",
				menu_price(status, setting[_sentry_cost_reset])
			)
		}
		case 5: {
			keys |= _sentry_menu_reset
			status = menu_status(id, balance, setting[_sentry_cost_reset], access_set[_access_sentry_reset])
			
			len += formatex(menu[len], charsmax(menu) - len, "%s%L^n",
				menu_number(9),
				LANG_PLAYER, status ? "USG_MENU_RESET" : "USG_MENU_RESET_CANT",
				menu_price(status, setting[_sentry_cost_reset])
			)
		}
		default: {
			keys |= _sentry_menu_standard
			status = menu_status(id, balance, standart_cost(data[_sentry_level]))
			
			len += formatex(menu[len], charsmax(menu) - len, "%s%L^n^n",
				menu_number(1),
				LANG_PLAYER, status ? "USG_MENU_UPGRADE" : "USG_MENU_UPGRADE_CANT",
				menu_price(status, standart_cost(data[_sentry_level]))
			)
		}
	}
	
	len += formatex(menu[len], charsmax(menu) - len, "%s%L^n^n", menu_number(0), LANG_PLAYER, "USG_MENU_EXIT")
	len += formatex(menu[len], charsmax(menu) - len, "%L", LANG_PLAYER, "USG_VER")
	
	user_equip[id][_user_select_key] = keys
	user_equip[id][_user_touch_time] = get_gametime()
	keys |= _sentry_menu_navigate
	
	show_menu(id, keys, menu, 10, "show_sentry_menu")
	
	return PLUGIN_CONTINUE
}

// Обработка нажатия в меню пушек
public set_sentry_menu(id, key) {
	if (!is_user_alive(id))
	return PLUGIN_CONTINUE
	
	static data[class_sentry], ent, Float:pos_ent[3], Float:pos_user[3]
	
	ent = user_equip[id][_user_select_ent]
	
	if (!pev_valided(ent))
	return PLUGIN_CONTINUE
	
	pev(ent, pev_origin, pos_ent)
	pev(id, pev_origin, pos_user)
	
	data_get(sentry_list, ent, data, sizeof data)
	
	if (get_distance_f(pos_ent, pos_user) > 100.0) {
		client_chat(id, "%L %L", LANG_PLAYER, "USG_TAG", LANG_PLAYER, "USG_BLOCK_FOR_AWAY")
		return PLUGIN_CONTINUE
	}	
	if (data[_sentry_upgrade] || data[_sentry_death] || data[_sentry_breaked])
	return PLUGIN_CONTINUE
	
	static bool:is_reset, access_user, mess_owner[191], mess_id[191], span[64], name[32], cost, level
	
	get_user_name(id, name, sizeof name)
	is_reset = false
	cost = 0
	access_user = 0
	level = data[_sentry_level]
	
	switch (key) {
		case 8: {
			if (data[_sentry_level] < 4)
			return PLUGIN_CONTINUE
			if (data[_sentry_owner] != id) {
				client_chat(id, "%L %L", LANG_PLAYER, "USG_TAG", LANG_PLAYER, "USG_BLOCK_RESET_ANY")
				return PLUGIN_CONTINUE
			}
			
			formatex(mess_owner, charsmax(mess_owner), "%L", LANG_PLAYER, "USG_ALERT_RESET", level - 1)
			cost = setting[_sentry_cost_reset]
			access_user = access_set[_access_sentry_reset]
			data[_sentry_level]--
			is_reset = true
		}
		case 9: {
			user_equip[id][_user_select_ent] = 0
			return PLUGIN_CONTINUE
		}
		default: {
			if (data[_sentry_level] == 5)
			return PLUGIN_CONTINUE
			if (level == 3) {
				key = clamp(key, 0, class_module_sentry - 1)
				formatex(span, charsmax(span), "USG_LVL_4_%d_CHAT", key)
				access_user = access_set[_access_module][key]
				cost = setting[_sentry_cost_module][key]
				data[_sentry_module] = key
			}
			else if (level == 4) {
				key = clamp(key, 0, class_aura_sentry - 1)
				formatex(span, charsmax(span), "USG_LVL_5_%d_CHAT", key)
				access_user = access_set[_access_aura][key]
				cost = setting[_sentry_cost_aura][key]
				data[_sentry_aura] = key
			}
			else {
				cost = standart_cost(data[_sentry_level])
				formatex(mess_owner, charsmax(mess_owner), "%L", LANG_PLAYER, "USG_ALERT_UPDATE_SELF", level + 1)
				formatex(mess_id, charsmax(mess_id), "%L", LANG_PLAYER, "USG_ALERT_UPDATE_ANY", name, level + 1)
			}
			if (level == 3 || level == 4) {
				formatex(mess_owner, charsmax(mess_owner), "%L", LANG_PLAYER, "USG_ALERT_UPDATE_SELF_ADDITION", level + 1, LANG_PLAYER, span)
				formatex(mess_id, charsmax(mess_id), "%L", LANG_PLAYER, "USG_ALERT_UPDATE_ANY_ADDITION", name, level + 1, LANG_PLAYER, span)
			}
			data[_sentry_level]++
		}
	}
	
	if (is_reset && !access_status(id, access_user)) {
		client_chat(id, "%L %L", LANG_PLAYER, "USG_TAG", LANG_PLAYER, "USG_BLOCK_RESET")
		return PLUGIN_CONTINUE
	}
	if (!is_reset && data[_sentry_update_several][level] == id && !access_status(id, access_set[_access_sentry_update_self])) {
		client_chat(id, "%L %L", LANG_PLAYER, "USG_TAG", LANG_PLAYER, "USG_BLOCK_UPGRADE_SELF")
		return PLUGIN_CONTINUE
	}
	if (!is_reset && !access_status(id, access_user)) {
		client_chat(id, "%L %L", LANG_PLAYER, "USG_TAG", LANG_PLAYER, "USG_BLOCK_UPGRADE")
		return PLUGIN_CONTINUE
	}
	if (cost > cs_get_user_money(id)) {
		client_chat(id, "%L %L", LANG_PLAYER, "USG_TAG", LANG_PLAYER, "USG_BLOCK_COST", cost - cs_get_user_money(id))
		return PLUGIN_CONTINUE
	}
	if (mess_owner[0] != EOS )
	client_chat(id, "%L %s", LANG_PLAYER, "USG_TAG", mess_owner)
	if (mess_id[0] != EOS && data[_sentry_owner] != id)
	client_chat(data[_sentry_owner], "%L %s", LANG_PLAYER, "USG_TAG", mess_id)
	
	data[_sentry_update_several][data[_sentry_level]] = id
	sentry_update_post(ent, data)
	cs_set_user_money(id, cs_get_user_money(id) - cost)
	
	data_set(sentry_list, ent, data, sizeof data)
	
	return PLUGIN_CONTINUE
}

// Запуск начала улучшений пушек
public sentry_update_post(ent, data[class_sentry]) {
	if (!pev_valided(ent))
	return
	
	static anime
	
	sentry_default(ent)
	
	switch (data[_sentry_level]) {
		case 3: 
		anime = _anime_upgrade_aim
		case 4:
		anime = _anime_upgrade_rockets
		case 5:
		anime = _anime_upgrade_gun_rockets
		default:
		anime = _anime_upgrade_gun
	}
	
	animate_set(ent, anime, 1.0)
	animate_set(data[_sentry_foot], anime, 1.0)
	
	data[_sentry_upgrade] = true
	data[_sentry_health_step] = 20
	data[_sentry_aura_timeleft] = get_gametime()
	data[_sentry_upgrade_switched] = false
	data[_sentry_upgrade_switch] = get_gametime() + 0.1
	data[_sentry_upgrade_end] = get_gametime() + 2.6
	
	set_pev(ent, pev_nextthink, get_gametime() + 0.15)	
	play_sound(ent, sound_list[_sound_upgrade])
}

// Нормальные векторы поворотов пушки
public sentry_default(ent) {
	if (!pev_valided(ent))
	return
	
	static Float:vec[3]
	
	set_pev(ent, pev_avelocity, vec)
	// set_pev(ent, pev_controller_1, 127)
}

// Игрок зашел
public client_putinserver(id) {
	if (!bot_register && is_user_bot(id))
	set_task(0.1, "register_bots", id)
}

// Игрок выходит
public client_disconnected(id) {
	sentry_user_destroy(id)
	user_clear(id)
}

// Регистрация хуков для бота
public register_bots(id) {
	if (bot_register || !is_user_connected(id))
	return
	
	RegisterHamFromEntity(Ham_Spawn, id, "user_spawn_pre")
	RegisterHamFromEntity(Ham_Spawn, id, "user_spawn_post", true)
	RegisterHamFromEntity(Ham_Killed, id, "user_killed_pre")
	RegisterHamFromEntity(Ham_Killed, id, "user_killed_post", true)
	RegisterHamFromEntity(Ham_TakeDamage, id, "take_damage_player_pre")
	RegisterHamFromEntity(Ham_TakeDamage, id, "take_damage_player_post", true)
	
	bot_register = true
}

// Обработка перед спавном игрока
public user_spawn_pre(id) {
	if (!is_user_connected(id))
	return
	
	user_equip[id][_user_frozen] = false
	user_equip[id][_user_vanish] = false
	// user_equip[id][_user_effect_vanish_other] = 255.0
	user_equip[id][_user_damage_effect] = 0
	user_equip[id][_user_damage_effect_time] = 0.0
	user_equip[id][_user_shield_durability] = attr_damage[_dmg_shield_durability]
}

// Обработка после спавна игрока
public user_spawn_post(id) {
	if (!is_user_connected(id))
	return
	
	shot_shell_shake_effect(id, 0, 0, 0)
	user_equip[id][_user_death] = false
	set_pev(id, pev_renderamt, 255.0)
	// user_equip[id][_user_aura_timeleft][3] = get_gametime() + 10000
}

// Обработка касаний
public touch_init(ent, target) {
	if (!pev_valided(ent))
	return FMRES_IGNORED
	if (fm_is_ent_classname(ent, CLASSNAME_SENTRY))
	return touch_sentry(ent, target)
	if (fm_is_ent_classname(ent, CLASSNAME_ROCKET))
	return touch_rocket(ent, target)
	
	return FMRES_IGNORED
}

// Обработка касания пушки ботом
public touch_sentry(ent, id) {
	if (!is_user_connected(id))
	return FMRES_IGNORED
	if (!is_user_bot(id))
	return FMRES_IGNORED
	if (user_equip[id][_user_touch_time] + 0.9 > get_gametime())
	return FMRES_IGNORED
	if (pev(ent, pev_team) != get_user_team(id))
	return FMRES_IGNORED
	
	// Вызываем меню боту
	menu_sentry(id, ent)
	
	// Получаем кейсы меню пушки
	static keys, key
	
	keys = user_equip[id][_user_select_key]
	
	// Проверяем, что в кейсах, не считая (1 << 9) - закрытие меню, есть и другие кнопки
	// if ((keys & ~_sentry_menu_reset) == 0)
	// return FMRES_IGNORED	
	
	// Проверяем, что в кейсах, есть и другие кнопки
	if ((keys & ~_sentry_menu_reset) == 0)
	return FMRES_IGNORED
	
	// Создаем рандомное число от 0 до 6 (1 .. 7), а потом проверяем, что клавиша есть в меню
	do key = random_num(0, 6)
	// log_to_file("menu_fix", "KEYS [%d] KEY [%d]", keys, key)
	while (~keys & (1 << key))
	
	// Имитируем нажатие меню по кейсу
	set_sentry_menu(id, key)
	
	return FMRES_IGNORED
}

// Обработка касания ракеты
public touch_rocket(ent, target) {
	if (!pev_valided(target)) {
		set_pev(ent, pev_movetype, MOVETYPE_NOCLIP)
		engfunc(EngFunc_SetModel, ent, "")
		rocket_defence(ent)
		return FMRES_IGNORED
	}
	
	if (fm_is_ent_classname(target, CLASSNAME_ROCKET) && pev(ent, pev_team) == pev(target, pev_team))
	return FMRES_IGNORED
	if (is_user_alive(target) && pev(ent, pev_team) == get_user_team(target))
	return FMRES_IGNORED
	
	static data[class_sentry], data_rocket[class_rocket], Float:pos_touch[3]
	
	data_get(rocket_list, ent, data_rocket, sizeof data_rocket)
	
	if (!pev_valided(data_rocket[_rocket_ent]))
	return rocket_defence(ent)
	
	data_get(sentry_list, data_rocket[_rocket_ent], data, sizeof data)
	pev(ent, pev_origin, pos_touch)
	
	set_pev(ent, pev_movetype, MOVETYPE_NOCLIP)
	engfunc(EngFunc_SetModel, ent, "")
	
	switch (data_rocket[_rocket_type]) {
		case _module_nuclear: {
			shot_shell_exp_effect(pos_touch, sprite_list[_sprite_nuclear_big], random_num(5, 8), TE_EXPLFLAG_NOSOUND)
			play_sound(ent, sound_list[_sound_rocket_explosion])
			sentry_damage_touch_search(ent, data, data_rocket, pos_touch, attr_force[_force_sentry_radius_nuclear])
		}
		case _module_fire: {
			shot_shell_exp_effect(pos_touch, sprite_list[_sprite_fire_big], random_num(5, 8), TE_EXPLFLAG_NOSOUND)
			play_sound(ent, sound_list[_sound_rocket_explosion])
			sentry_damage_touch_search(ent, data, data_rocket, pos_touch, attr_force[_force_sentry_radius_fire])
		}
		case _module_gas: {
			shot_shell_exp_effect(pos_touch, sprite_list[_sprite_gas_big], random_num(5, 8), TE_EXPLFLAG_NOSOUND)
			play_sound(ent, sound_list[_sound_rocket_explosion])
			sentry_damage_touch_search(ent, data, data_rocket, pos_touch, attr_force[_force_sentry_radius_gas])
		}
		case _module_plasma: {
			shot_shell_sprite_effect(sprite_list[_sprite_plase_exp], pos_touch, 4, 200)
			play_sound(ent, sound_list[_sound_plasma_exp])
			sentry_damage_touch_search(ent, data, data_rocket, pos_touch, attr_force[_force_sentry_radius_plasma])
		}
	}
	
	return rocket_defence(ent)
}

// Поиск целей после касания
public sentry_damage_touch_search(ent, data[class_sentry], data_rocket[class_rocket], Float:pos_touch[3], Float:dist) {
	static Snapshot:snaps, Float:shield_multi, sentry, owner, damage_type, Float:target_dist, Float:pos_target[3], i
	
	sentry = data_rocket[_rocket_ent]
	owner = data_rocket[_rocket_owner]
	
	if (!pev_valided(sentry) || !is_user_connected(owner)) {		
		TrieSnapshotDestroy(snaps)
		return
	}
	
	shield_multi = data[_sentry_trace_touch_shield] ? 1.0 - attr_damage[_dmg_damage_froze_exp] / 100.0 : 1.0
	damage_type = data_rocket[_rocket_type]
	snaps = TrieSnapshotCreate(sentry_list)
	
	for (i = 0; i < TrieGetSize(sentry_list); i++) {
		static target_string[32], target
		
		TrieSnapshotGetKey(snaps, i, target_string, charsmax(target_string))
		target = str_to_num(target_string)
		
		if (!pev_valided(target))
		continue
		if (pev(target, pev_team) == pev(ent, pev_team))
		continue
		
		pev(target, pev_origin, pos_target)
		target_dist = get_distance_f(pos_touch, pos_target)
		
		if (target_dist > dist)
		continue
		
		sentry_damage_module_post(sentry, target, owner, damage_type, (1 - target_dist / dist) * shield_multi)
	}
	
	// while (i++ < MaxClients) {
	for (i = 1; i <= MaxClients; i++) {
		if (!is_user_alive(i) || get_user_team(i) == get_user_team(owner))
		continue
		
		pev(i, pev_origin, pos_target)
		target_dist = get_distance_f(pos_touch, pos_target)
		
		if (target_dist > dist)
		continue
		if (!data[_sentry_trace_touch_shield])
		sentry_damage_player_post(sentry, i, owner, damage_type)
		
		sentry_damage_module_post(sentry, i, owner, damage_type, (1 - target_dist / dist) * shield_multi)
		shot_shell_shake_effect(i, 12, 3, 12)
	}
	
	TrieSnapshotDestroy(snaps)
}

// Накладывание эффектов от урона игроку
public sentry_damage_player_post(ent, target, owner, damage_type) {
	switch (damage_type) {
		case _module_nuclear: {
			user_equip[target][_user_damage_effect_time] = get_gametime() + attr_damage[_dmg_nuc_time]
			user_equip[target][_user_damage_effect_interval] = attr_damage[_dmg_nuc_interval_time]
		}
		case _module_fire:{
			user_equip[target][_user_damage_effect_time] = get_gametime() + attr_damage[_dmg_fire_time]
			user_equip[target][_user_damage_effect_interval] = attr_damage[_dmg_fire_interval_time]
		}
		case _module_gas:{
			user_equip[target][_user_damage_effect_time] = get_gametime() + attr_damage[_dmg_gas_time]
			user_equip[target][_user_damage_effect_interval] = attr_damage[_dmg_gas_interval_time]
		}
	}
	
	user_equip[target][_user_damage_effect] = damage_type
	user_equip[target][_user_attacker_ent] = ent
	user_equip[target][_user_attacker_owner] = owner
}

// Нанесение урона в зависимости от модуля
public sentry_damage_module_post(ent, target, owner, damage_type, Float:damage) {
	switch (damage_type) {
		case _module_nuclear: ExecuteHamB(Ham_TakeDamage, target, ent, owner, attr_damage[_dmg_nuc_damage_explosion] * damage, DMG_RADIATION)
		case _module_fire: ExecuteHamB(Ham_TakeDamage, target, ent, owner, attr_damage[_dmg_fire_damage_explosion] * damage, DMG_BURN)
		case _module_gas: ExecuteHamB(Ham_TakeDamage, target, ent, owner, attr_damage[_dmg_gas_damage_explosion] * damage, DMG_NERVEGAS)
		case _module_plasma: ExecuteHamB(Ham_TakeDamage, target, ent, owner, attr_damage[_dmg_plasm_damage] * damage, DMG_ENERGYBEAM)
		case _module_laser: ExecuteHamB(Ham_TakeDamage, target, ent, owner, attr_damage[_dmg_laser_damage] * damage, DMG_ENERGYBEAM)
		case _module_electry: ExecuteHamB(Ham_TakeDamage, target, ent, owner, attr_damage[_dmg_electric_damage] * damage, DMG_SHOCK)
	}
}

// Обработка игрока
public think_player_pre(id) {
	if (!pev_valided(id))
	return FMRES_IGNORED
	if (!is_user_connected(id))
	return FMRES_IGNORED
	if (user_equip[id][_user_nextthink] > get_gametime())
	return FMRES_IGNORED
	
	user_equip[id][_user_nextthink] = get_gametime() + 0.1
	
	// set_hudmessage(55, 255, 255, 0.8, -1.0, 0, 0.0, 0.0, 0.0, 0.25, 0)
	// show_hudmessage(id, "ENTITY COUNT ALL >> [%d]^nENTITY COUNT YOU [%d / %d]", fm_entity_count(), native_get_sentry_count(id), native_get_sentry_count_max(id))
	
	if (!is_user_alive(id))
	return FMRES_IGNORED
	
	think_player_pre_effect_clear(id)
	think_player_pre_shield(id)
	think_player_pre_aura(id)
	think_player_pre_effect(id)
	think_player_pre_aiming(id, 0)
	
	return FMRES_HANDLED
}

// Снятие эффектов (Пока только льда)
public think_player_pre_effect_clear(id) {
	if (!user_equip[id][_user_frozen])
	return
	if (user_equip[id][_user_effect_frozen_timeleft] > get_gametime())
	return
	
	set_pev(id, pev_flags, pev(id, pev_flags) & ~FL_FROZEN)
	user_equip[id][_user_frozen] = false
}

// Состояние щита на руке
public think_player_pre_shield(id) {
	if (!is_user_connected(id))
	return
	
	static text = 32, line[32], i
	
	if (!get_pdata_bool(id, OFFSET_SHIELDHAS, OFFSET_LINUX_STEP))
	return
	
	i = 0
	user_equip[id][_user_shield_durability] = floatclamp(user_equip[id][_user_shield_durability] + 0.1, 0.0, attr_damage[_dmg_shield_durability])
	text = floatround(text * user_equip[id][_user_shield_durability] / attr_damage[_dmg_shield_durability], floatround_floor)
	
	while (i++ < text)
	add(line, charsmax(line), "#")
	
	set_hudmessage(255, 250, 0, -1.0, 0.85, 0, 0.0, 0.0, 0.0, 0.25, 3)
	show_hudmessage(id, "SHIELD^n[%s]", line)
}

// Вывод худа активных аур, наложенных на игрока от пушки
public think_player_pre_aura(id) {
	static text[196], attr_name[32], Float:timeleft, len, Float:pos[3], bool:effect_use, i
	
	pev(id, pev_origin, pos)
	len = 0
	timeleft = 0.0
	effect_use = false
	
	for (i = 0; i < class_aura_sentry; i++) {
		timeleft = Float:user_equip[id][_user_aura_timeleft][i]
		
		if (timeleft < get_gametime()) {
			aura_passive_init(id, i, false)
			continue
		}
		
		effect_use = true
		timeleft-= get_gametime()
		formatex(attr_name, charsmax(attr_name), "USG_AURA_NAME_%d", i)
		len += formatex(text[len], charsmax(text) - len, "%L | %.1f^t^n", LANG_PLAYER, attr_name, timeleft)
	}
	
	if (!effect_use)
	return
	
	if (user_equip[id][_user_effect_aura_time] < get_gametime()) {
		user_equip[id][_user_effect_aura_time] = get_gametime() + 1.0
		shot_implosion_effect(pos)
	}
	
	short_hud(id, text, 0.02, 0.2, 50, 255, 50, 255, 0, 0.0, 1.0, 1.0, 2)
}

// Накладывание пассивных аур на игрока от пушки
public aura_passive_init(id, aura, bool:status) {
	static colors[3]
	
	ArrayGetArray(setting[_sentry_sprite_aura_color], aura, colors)
	
	switch(aura) {
		case _aura_vanish: {			
			if (user_equip[id][_user_vanish] && !status) {
				fm_set_user_rendering(id, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 255)
				user_equip[id][_user_vanish] = false
				return PLUGIN_CONTINUE
			}
			if (!user_equip[id][_user_vanish] && pev(id, pev_renderamt) != 255)
			return PLUGIN_CONTINUE
			if (!status)
			return PLUGIN_CONTINUE
			if (!user_equip[id][_user_vanish])
			shot_screenfade_effect(id, colors, 30, 30, 100)
			
			user_equip[id][_user_vanish] = true
			fm_set_user_rendering(id, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, floatround(255.0 / 100.0 * attr_aura[_aura_vanish_amount], floatround_floor))
		}
	}
	return PLUGIN_CONTINUE
}

// Нанесение урона игроку в зависимости от наложенных эффектов
public think_player_pre_effect(id) {
	if (user_equip[id][_user_damage_effect_time] < get_gametime())
	return
	if (user_equip[id][_user_damage_effect_interval_next] > get_gametime())
	return
	
	static ent, owner, Float:pos_target[3]
	
	ent = user_equip[id][_user_attacker_ent]
	owner = user_equip[id][_user_attacker_owner]
	
	if (!pev_valided(ent) || !is_user_connected(owner))
	return
	
	pev(id, pev_origin, pos_target)
	user_equip[id][_user_damage_effect_interval_next] = get_gametime() + user_equip[id][_user_damage_effect_interval]
	
	switch (user_equip[id][_user_damage_effect]) {
		case _module_nuclear: {
			shot_shell_sprite_effect(sprite_list[_sprite_nuclear_small], pos_target, 3, 100)
			ExecuteHamB(Ham_TakeDamage, id, ent, owner, attr_damage[_dmg_nuc_interval_damage], DMG_RADIATION)
		}
		case _module_fire: {
			shot_shell_sprite_effect(sprite_list[_sprite_fire_small], pos_target, 3, 100)
			ExecuteHamB(Ham_TakeDamage, id, ent, owner, attr_damage[_dmg_fire_interval_damage], DMG_BURN)
		}
		case _module_gas: {
			shot_shell_sprite_effect(sprite_list[_sprite_gas_small], pos_target, 3, 100)
			ExecuteHamB(Ham_TakeDamage, id, ent, owner, attr_damage[_dmg_gas_interval_damage], DMG_NERVEGAS)
		}
	}
}

// Игрок наводится на что-то (Пока только пушки)
public think_player_pre_aiming(id, ent) {
	static put
	
	get_user_aiming(id, ent, _, cs_get_user_zoom(id) == 1 ? 150 : (cs_get_user_zoom(id) == 4 ? 500 : 9999))
	
	if (user_equip[id][_user_aiming_time] + 0.1 > get_gametime())
	return
	if (!pev_valided(ent))
	return
	
	ExecuteForward(forward_aiming, put, id, ent)
	
	if (!fm_is_ent_classname(ent, CLASSNAME_SENTRY))
	return
	
	user_equip[id][_user_aiming_time] = get_gametime()	
	
	// if (!fm_is_ent_classname(ent, CLASSNAME_SENTRY)) {
	// set_dhudmessage(255, 0, 0, -1.0, 0.7, 0, 0.0, 0.0, 0.5, 1.0)
	// show_dhudmessage(id, "Игрок: %d - HP: %d", ent, pev(ent, pev_health))
	// return
	// }
	
	static data[class_sentry], message[196], span[196], name[64], name_post[64], module[64], aura[64]
	
	data_get(sentry_list, ent, data, sizeof data)
	
	if (!is_user_connected(data[_sentry_owner]))
	return
	
	get_user_name(data[_sentry_owner], name, charsmax(name))
	formatex(module, charsmax(module), "USG_LVL_4_%d_CHAT", data[_sentry_module])
	formatex(aura, charsmax(aura), "USG_LVL_5_%d_CHAT", data[_sentry_aura])
	formatex(name_post, charsmax(name_post), data[_sentry_owner] == id ? "%L" : "%L %s",
		LANG_PLAYER, data[_sentry_owner] == id ? "USG_SPAN_INSTALL_SELF" : "USG_SPAN_INSTALL", name
	)
	
	if (setting[_sentry_common_solid]) {
		switch(data[_sentry_level]) {
			case 4:
			span = "%s^n%L: %d | %L: %.0f / %.0f HP^n%L"
			case 5:
			span = "%s^n%L: %d | %L: %.0f / %.0f HP^n%L | %L"
			default:
			span = "%s^n%L: %d | %L: %.0f / %.0f HP"
		}
		formatex(message, charsmax(message), span, name_post,
			LANG_PLAYER, "USG_SPAN_LVL", data[_sentry_level],
			LANG_PLAYER, "USG_SPAN_DURABILITY", data[_sentry_health][_sentry_health_head],
			sentry_health_get(data[_sentry_level] - 1, _sentry_health_head_multi),
			LANG_PLAYER, module, LANG_PLAYER, aura
		)
	}
	else {
		switch(data[_sentry_level]) {
			case 4:
			span = "%s^n%L: %d | %L: %.0f HP | %L: %.0f HP^n%L"
			case 5:
			span = "%s^n%L: %d | %L: %.0f HP | %L: %.0f HP^n%L | %L"
			default:
			span = "%s^n%L: %d | %L: %.0f HP | %L: %.0f HP"
		}
		formatex(message, charsmax(message), span, name_post,
			LANG_PLAYER, "USG_SPAN_LVL", data[_sentry_level],
			LANG_PLAYER, "USG_SPAN_HEAD", data[_sentry_health][_sentry_health_head],
			LANG_PLAYER, "USG_SPAN_BASE", data[_sentry_health][_sentry_health_base],
			LANG_PLAYER, module, LANG_PLAYER, aura
		)
	}
	
	short_hud(id, message, -1.0, 0.85, 255, 255, 255, 200, 0, 0.0, 1.0, 1.0, 1)
}

public sentry_death_set(ent, data[class_sentry]) {
	data[_sentry_destroyed] = get_gametime() + 1.6		
	data[_sentry_death] = true
	data_set(sentry_list, ent, data, sizeof data)
	
	set_pev(ent, pev_avelocity, Float:{ 0.0, 0.0, 0.0 })	
	animate_set(ent, _anime_destroy, 1.0)
	animate_set(data[_sentry_foot], _anime_destroy, 1.0)
	play_sound(ent, sound_list[_sound_breaking])
}

// Обработка сущностей
public think_init(ent) {
	if (!pev_valided(ent))
	return FMRES_IGNORED
	if (fm_is_ent_classname(ent, CLASSNAME_SENTRY))
	return think_sentry(ent)
	if (fm_is_ent_classname(ent, CLASSNAME_ROCKET))
	return think_rocket(ent)
	if (fm_is_ent_classname(ent, CLASSNAME_ICE))
	return think_ice(ent)
	
	return FMRES_IGNORED
}

// Обработка пушки
public think_sentry(ent) {
	if (Float:pev(ent, pev_nextthink) > get_gametime())
	return FMRES_IGNORED
	
	static data[class_sentry]
	
	data_get(sentry_list, ent, data, sizeof data)
	
	if (data[_sentry_destroyed] > get_gametime()) {
		sentry_think_timer(ent, data)
		return FMRES_IGNORED	
	}
	if (data[_sentry_death]) {
		sentry_death(data)
		return FMRES_IGNORED
	}
	if (/*get_user_team(data[_sentry_owner]) != pev(ent, pev_team) ||*/ !is_user_alive(data[_sentry_owner]))
	{
		sentry_death_set(ent, data)
		sentry_think_timer(ent, data)
		data_set(sentry_list, ent, data, sizeof data)
		return FMRES_IGNORED	
	}
	if (data[_sentry_spawn_start] && !data[_sentry_spawn_end] && data[_sentry_defence_end] < get_gametime()) {
		sentry_defence(data)
		data_set(sentry_list, ent, data, sizeof data)
	}
	
	sentry_think_timer(ent, data)
	
	if (data[_sentry_breaked] && data[_sentry_repairtime] + setting[_sentry_repair_time] < get_gametime()) {
		data[_sentry_death] = true
		data_set(sentry_list, ent, data, sizeof data)
		return FMRES_IGNORED
	}
	if (!data[_sentry_spawn_start]) {
		static foot, alert, Float:angles_ent[3], Float:pos_ent[3]
		
		foot = fm_create_entity("func_breakable")
		alert = fm_create_entity("func_breakable")
		
		if (!pev_valided(foot))
		return FMRES_IGNORED
		if (!pev_valided(alert))
		return FMRES_IGNORED
		
		pev(ent, pev_angles, angles_ent)
		pev(ent, pev_origin, pos_ent)
		
		engfunc(EngFunc_SetModel, foot, model_list[_model_build])
		engfunc(EngFunc_SetModel, alert, model_list[_model_alert])
		
		engfunc(EngFunc_SetSize, ent, Float:{ -15.0, -15.0, 0.0 }, Float:{ 15.0, 15.0, 45.0 })
		engfunc(EngFunc_SetOrigin, foot, pos_ent)
		engfunc(EngFunc_SetOrigin, alert, pos_ent)
		
		set_pev(ent, pev_gravity, 1.0)
		set_pev(foot, pev_body, 2)
		set_pev(foot, pev_skin, pev(data[_sentry_self], pev_skin))
		set_pev(foot, pev_classname, CLASSNAME_FOOT)
		set_pev(foot, pev_nextthink, get_gametime() + 0.1)
		set_pev(alert, pev_classname, CLASSNAME_ALERT)
		
		// Крутить аллерт?
		set_pev(alert, pev_avelocity, Float:{ 0.0, -25.0, 0.0 })
		
		set_pev(foot, pev_angles, angles_ent)
		set_pev(alert, pev_angles, angles_ent)
		
		data[_sentry_spawn_start] = true
		data[_sentry_foot] = foot
		data[_sentry_alert] = alert
		data[_sentry_defence_end] = get_gametime() + 1.8
		
		animate_set(ent, _anime_spawn_up, 1.0)
		animate_set(foot, _anime_spawn_up, 1.0)
		animate_set(alert, 0, 1.0)
		
		switch_sentry_level(data)
		
		sentry_movetype(ent, data[_sentry_foot], data[_sentry_alert], MOVETYPE_NONE)
		play_sound(ent, sound_list[_sound_build])
	}
	if (!data[_sentry_spawn_end]) {
		data_set(sentry_list, ent, data, sizeof data)
		return FMRES_IGNORED
	}
	if (data[_sentry_upgrade] && !data[_sentry_upgrade_switched] && data[_sentry_upgrade_switch] <= get_gametime()) {
		data[_sentry_upgrade_switched] = true
		switch_sentry_level(data)
		data_set(sentry_list, ent, data, sizeof data)
		return FMRES_IGNORED
	}
	if (data[_sentry_health_step] > 0) {
		sentry_upgrade_health(data)
		data_set(sentry_list, ent, data, sizeof data)
	}
	if (data[_sentry_upgrade] && data[_sentry_upgrade_end] > get_gametime())
	return FMRES_IGNORED
	else if (data[_sentry_upgrade]) {
		data[_sentry_upgrade] = false
		data_set(sentry_list, ent, data, sizeof data)
	}
	if (!data[_sentry_repair_ended] && data[_sentry_repair_end] < get_gametime()) {
		data[_sentry_breaked] = false
		data[_sentry_repair] = false
		data[_sentry_repair_ended] = true
		data_set(sentry_list, ent, data, sizeof data)
	}
	
	static models_message[sizeof submodel_message], key_message
	
	models_message = { _alert_repair_start, _healthbar_health }
	
	if (data[_sentry_repairtime2] + 0.45 < get_gametime())
	models_message = { 0, 0 }
	if (data[_sentry_repairtime2] + 0.45 < get_gametime() && data[_sentry_breaked])
	models_message = { _alert_repair_need, 0 }
	if ((data[_sentry_personal_sound] + 0.45 < get_gametime()) && (data[_sentry_repairtime2] + 0.45 > get_gametime())) {
		play_sound(data[_sentry_alert], sound_list[_sound_repair])
		data[_sentry_personal_sound] = get_gametime()
		data_set(sentry_list, ent, data, sizeof data)
	}
	
	select_subs(models_message, submodel_message, sizeof submodel_message, key_message)
	
	if (pev_valided(data[_sentry_alert]))
	set_pev(data[_sentry_alert], pev_body, key_message)
	if (data[_sentry_breaked]) {
		sentry_default(ent)
		return FMRES_IGNORED
	}
	// if (entity_fly(ent, data)) {
	// sentry_movetype(0, data[_sentry_foot], 0, MOVETYPE_TOSS)
	// data_set(sentry_list, ent, data, sizeof data)
	// return FMRES_IGNORED
	// }
	if (fm_distance_to_floor(ent) > 0.0) {
		static Float:pos_ent[3]
		
		engfunc(EngFunc_DropToFloor, ent)
		pev(ent, pev_origin, pos_ent)
		
		if (pev_valided(data[_sentry_foot]))
		set_pev(data[_sentry_foot], pev_origin, pos_ent)
		if (pev_valided(data[_sentry_alert]))
		set_pev(data[_sentry_alert], pev_origin, pos_ent)
	}
	
	// else
	// sentry_movetype(ent, data[_sentry_foot], data[_sentry_alert], MOVETYPE_NOCLIP)
	
	sentry_think_aura(ent, data)
	sentry_search(ent, data)
	sentry_target(ent, data)
	sentry_scan(ent, data)
	sentry_think_timer(ent, data)
	data_set(sentry_list, ent, data, sizeof data)
	
	return FMRES_IGNORED
}

// Установка таймера пушки
public sentry_think_timer(ent, data[class_sentry]) {
	set_pev(ent, pev_nextthink, get_gametime() + (!data[_sentry_spawn_start] || data[_sentry_target] || data[_sentry_upgrade] ? 0.1 : 0.5))
}

// Предсмертная агония пушки, имитация взрыва и урона от него
public sentry_death(data[class_sentry]) {
	static Float:pos[3], Float:pos_target[3], Float:velocity[3], Float:target_dist, Float:dist, i
	
	dist = attr_force[_force_sentry_radius_exp]
	
	if (!pev_valided(data[_sentry_self])) {
		sentry_death_clear(data)
		return
	}
	
	set_pev(data[_sentry_self], pev_avelocity, Float:{ 0.0, 0.0, 0.0 })
	pev(data[_sentry_self], pev_origin, pos)
	
	// while (i++ < MaxClients) {
	for (i = 1; i <= MaxClients; i++)
	{
		if (!is_user_alive(i))
		continue
		
		pev(i, pev_origin, pos_target)
		target_dist = get_distance_f(pos, pos_target)
		
		if (target_dist > dist)
		continue
		
		angles_velocity(velocity, pos, pos_target, attr_force[_force_sentry_exp_force])
		set_pev(i, pev_velocity, velocity)
		ExecuteHamB(Ham_TakeDamage, i, 0, 0, (1 - target_dist / dist) * setting[_sentry_explosion_damage], DMG_GENERIC)
	}
	
	pos[2] += 50
	
	break_model_effect(pos, 200.0, model_list[_model_sentry_break_id_1], 4, 50)
	break_model_effect(pos, 200.0, model_list[_model_sentry_break_id_2], 1, 50)
	break_model_effect(pos, 200.0, model_list[_model_sentry_break_id_3], random_num(5, 9), 50)
	
	// engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, pos, 0)
	// write_byte(TE_TAREXPLOSION)
	// engfunc(EngFunc_WriteCoord, pos[0])
	// engfunc(EngFunc_WriteCoord, pos[1])
	// engfunc(EngFunc_WriteCoord, pos[2])
	// message_end()
	
	sentry_death_clear(data)
}

// Уничтожение пушки после смерти (без эффектов)
public sentry_death_clear(data[class_sentry]) {
	sentry_default(data[_sentry_self])
	entity_kill(data[_sentry_self])
	entity_kill(data[_sentry_foot])
	entity_kill(data[_sentry_alert])
	
	// server_print(">>> BUILD REMOVE LEVEL: %d, MODULE: %d, AURA: %d", data[_sentry_level], data[_sentry_module], data[_sentry_aura])
	data_remove(sentry_list, data[_sentry_self])
}

// Прибавление здоровья пушки, учитывающий шаг, количество повторений и уровень (При установке не используется)
public sentry_upgrade_health(data[class_sentry]) {
	static Float:head_health, Float:base_health, Float:head_health_max, Float:base_health_max,
	Float:head_health_preview, Float:base_health_preview, paths
	
	data[_sentry_health_step]--
	head_health = head_health_max = sentry_health_get(data[_sentry_level] - 1, _sentry_health_head_multi)
	base_health = base_health_max = sentry_health_get(data[_sentry_level] - 1, _sentry_health_base_multi)
	head_health_preview = base_health_preview = 0.0
	paths = data[_sentry_health_step]
	
	if (data[_sentry_level] > 1) {
		head_health_preview = sentry_health_get(data[_sentry_level] - 2, _sentry_health_head_multi)
		base_health_preview = sentry_health_get(data[_sentry_level] - 2, _sentry_health_base_multi)
	}
	
	head_health -= head_health_preview
	base_health -= base_health_preview
	data[_sentry_health][_sentry_health_head] += head_health / paths
	data[_sentry_health][_sentry_health_base] += base_health / paths
	data[_sentry_health][_sentry_health_head] = floatclamp(data[_sentry_health][_sentry_health_head], 0.0, head_health_max)
	data[_sentry_health][_sentry_health_base] = floatclamp(data[_sentry_health][_sentry_health_base], 0.0, base_health_max)
}

// Выбор подмодели пушки
public switch_sentry_level(data[class_sentry]) {
	static models_sentry[sizeof submodel_sentry], key, module
	
	switch (data[_sentry_module]) {
		case 4: module = _sentry_guns_tesla
		case 5: module = _sentry_guns_energy
		case 6: module = _sentry_guns_tesla
		default: module = _sentry_guns_shotgun
	}
	
	switch (data[_sentry_level]) {
		case 1: models_sentry = { 
			_sentry_tower, 
			_blank, 
			_blank, 
			_blank, 
			_blank, 
			_blank, 
			_blank,  
			_blank,  
			_blank,  
			_blank,  
			_blank,
			_blank,
			_blank
		}		
		case 2: {
			models_sentry = { 
				_sentry_tower, 
				_blank, 
				_blank, 
				_blank, 
				_blank, 
				_sentry_gun_core, 
				_blank,  
				_sentry_gun_ammo,  
				_blank,  
				_sentry_gun_holder,  
				_blank,
				_blank,
				_blank
			}
			
			models_sentry[_sentry_sub_guns] = module
		}
		case 3: {
			models_sentry = { 
				_sentry_tower, 
				_blank, 
				_sentry_tower_socket, 
				_sentry_tower_aim, 
				_blank, 
				_sentry_gun_core, 
				_blank,  
				_sentry_gun_ammo,  
				_blank,  
				_sentry_gun_holder,  
				_sentry_frame,
				_blank,
				_blank
			}
			
			models_sentry[_sentry_sub_guns] = module
		}
		case 4: {
			models_sentry = { 
				_sentry_tower, 
				_blank, 
				_sentry_tower_socket, 
				_sentry_tower_aim, 
				_sentry_tower_rockets, 
				_sentry_gun_core, 
				_blank,  
				_sentry_gun_ammo,  
				_blank,  
				_sentry_gun_holder,  
				_sentry_frame,
				_blank,
				_blank
			}
			
			models_sentry[_sentry_sub_guns] = module
			models_sentry[_sentry_sub_icon_up] = data[_sentry_module] + 1
		}
		case 5:  {
			models_sentry = { 
				_sentry_tower, 
				_blank, 
				_sentry_tower_socket, 
				_sentry_tower_aim, 
				_sentry_tower_rockets, 
				_sentry_gun_core, 
				_blank,  
				_sentry_gun_ammo,  
				_sentry_gun_rocket,  
				_sentry_gun_rocket,  
				_sentry_frame,
				_blank,
				_blank
			}
			
			models_sentry[_sentry_sub_guns] = module
			models_sentry[_sentry_sub_icon_up] = data[_sentry_module] + 1
			models_sentry[_sentry_sub_icon_down] = data[_sentry_aura] + 1
		}
	}
	
	
	select_subs(models_sentry, submodel_sentry, sizeof submodel_sentry, key)
	set_pev(data[_sentry_self], pev_body, key)
	// fm_set_rendering(ent, kRenderFxNone, 0, 0, 0, kRenderTransTexture, 100)
}

// Обработка накладывания аур
public sentry_think_aura(ent, data[class_sentry]) {
	if (data[_sentry_level] != 5 || data[_sentry_aura_timeleft] > get_gametime())
	return
	
	static Float:pos_ent[3], colors[3]
	
	ArrayGetArray(setting[_sentry_sprite_aura_color], data[_sentry_aura], colors)
	pev(ent, pev_origin, pos_ent)
	data[_sentry_aura_timeleft] = get_gametime() + attr_aura[_aura_time] - 0.5
	sentry_think_aura_add(pos_ent, pev(ent, pev_team), data[_sentry_aura])
	
	if (!pev_valided(data[_sentry_foot]))
	return
	
	engfunc(EngFunc_EmitAmbientSound, data[_sentry_foot], pos_ent, sound_list[_sound_wave], 0.1, ATTN_NORM, 0, PITCH_NORM)
	color_rand(colors)
	
	// engfunc(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, { 0, 0, 0 }, 0)
	// write_byte(TE_BEAMCYLINDER)
	// engfunc(EngFunc_WriteCoord, pos_ent[0])
	// engfunc(EngFunc_WriteCoord, pos_ent[1])
	// engfunc(EngFunc_WriteCoord, pos_ent[2])
	// engfunc(EngFunc_WriteCoord, pos_ent[0])
	// engfunc(EngFunc_WriteCoord, pos_ent[1])
	// engfunc(EngFunc_WriteCoord, pos_ent[2] + 150.0)
	// write_short(sprite_list[_sprite_aura_beam])
	// write_byte(0)
	// write_byte(0)
	// write_byte(10)
	// write_byte(25)
	// write_byte(0)
	// write_byte(colors[_red])
	// write_byte(colors[_green])
	// write_byte(colors[_blue])
	// write_byte(200)
	// write_byte(0)
	// message_end()
}

// Накладывание ауры
public sentry_think_aura_add(Float:pos_ent[3], team, aura) {
	static Float:pos_user[3], i
	
	// while (i++ < MaxClients) {
	for (i = 1; i <= MaxClients; i++) {
		if (!is_user_alive(i) || get_user_team(i) != team)
		continue
		
		pev(i, pev_origin, pos_user)
		
		if (get_distance_f(pos_ent, pos_user) > attr_aura[_aura_dist])
		continue
		
		user_equip[i][_user_aura_timeleft][aura] = get_gametime() + attr_aura[_aura_time]
		aura_passive_init(i, aura, true)
	}
}

// Поиск целей пушкой
public sentry_search(ent, data[class_sentry]) {
	static Snapshot:snaps, Float:eye_ent[3], Float:previous_dist, empty,
	Float:near_radius, Float:dist, target_aim, bool:target_status, i
	
	previous_dist = 0.0
	near_radius = 300.0
	dist = 0.0
	target_aim = 0
	target_status = false
	
	engfunc(EngFunc_GetBonePosition, ent, setting[_sentry_bone_aim], eye_ent, empty)
	
	// while (i++ < MaxClients)
	for (i = 1; i <= MaxClients; i++)
	sentry_search_dist(i, ent, target_aim, target_status, previous_dist, eye_ent)
	
	if (setting[_sentry_aim_sentry] && !target_status) {
		static data_victim[class_sentry], ent_string[32], victim_ent
		snaps = TrieSnapshotCreate(sentry_list)
		previous_dist = 0.0
		
		for (i = 0; i < TrieGetSize(sentry_list); i++) {
			TrieSnapshotGetKey(snaps, i, ent_string, charsmax(ent_string))
			victim_ent = str_to_num(ent_string)
			
			if (!pev_valided(victim_ent))
			continue
			
			data_get(sentry_list, victim_ent, data_victim, sizeof data_victim)
			
			if (!pev_valided(data_victim[_sentry_self]))
			continue
			if (!data_victim[_sentry_spawn_end])
			continue
			if (data_victim[_sentry_death])
			continue
			if (data_victim[_sentry_breaked] && !setting[_sentry_shot_break])
			continue
			
			sentry_search_dist(victim_ent, ent, target_aim, target_status, previous_dist, eye_ent)
		}
	}
	
	if (is_user_alive(data[_sentry_aim]) && fm_is_visible(data[_sentry_aim], eye_ent, 1) && dist > near_radius || target_aim == 0) {
		data[_sentry_target] = false
		TrieSnapshotDestroy(snaps)
		return
	}
	
	if (target_aim != data[_sentry_aim])
	play_sound(ent, sound_list[_sound_alert])
	
	data[_sentry_aim] = target_aim
	data[_sentry_target] = target_status
	TrieSnapshotDestroy(snaps)
	// data[_sentry_aim_undo] = target_aim
}

// Наведение на цель пушкой
public sentry_target(ent, data[class_sentry]) {
	if (data[_sentry_aim] == 0 || !pev_valided(data[_sentry_aim]) || !data[_sentry_target] || !is_user_alive(data[_sentry_aim]) && entity_player(data[_sentry_aim])) {
		set_pev(ent, SENTRY_VERT_STEP_1, 0)
		set_pev(ent, SENTRY_VERT_STEP_2, 0)
		set_pev(ent, SENTRY_GUNS, 255)
		sentry_idle_fix(ent, data)
		return
	}
	
	static Float:start[3], Float:angles_ent[3], Float:end[3], Float:angles_target[3], Float:deg_amount, Float:empty[3],
	Float:deg_vertic, Float:vec[3], Float:deg_target, Float:deg_near_amount, anime, vertical
	
	engfunc(EngFunc_GetBonePosition, ent, setting[_sentry_bone_head], start, empty)
	pev(ent, pev_angles, angles_ent)
	pev(data[_sentry_aim], pev_origin, end)
	
	if (is_user_alive(data[_sentry_aim]))
	end[2] += 5
	
	if (fm_is_ent_classname(data[_sentry_aim], CLASSNAME_SENTRY))
	engfunc(EngFunc_GetBonePosition, data[_sentry_aim], setting[_sentry_bone_aim], end, empty)
	
	deg_target = deg_normal(deg_hor(start, end))
	deg_amount = deg_normal(angles_ent[1] - deg_target)
	
	vec[1] = 0.0
	
	if (floatabs(deg_amount) > 12.5) {
		vec[1] = deg_normal(angles_ent[1] - deg_target) < 0 ? 220.0 : -220.0
		set_pev(ent, pev_avelocity, vec)
		return
	}
	
	switch (data[_sentry_level]) {
		case 1: anime = _anime_fire2
		default: 
		switch (data[_sentry_module]) {
			case 4..6: anime = !setting[_sentry_shot_complex] ? _anime_fire1 : _anime_fire2
			default: anime = _anime_fire3
		}
	}
	
	
	animate_set(ent, anime, 1.0)
	
	deg_vertic = deg_normal(degress_vertical(start, end))
	deg_near_amount = floatasin(17.5 / get_distance_f(end, start), degrees)
	
	// angles_target[0] = 0.0
	angles_target[1] = deg_target
	vertical = floatround(deg_vertic / 180.0 * 512.0, floatround_floor)
	
	// angles_target[2] = 0.0
	set_pev(ent, pev_avelocity, vec)
	set_pev(ent, pev_angles, angles_target)
	set_pev(ent, SENTRY_VERT_STEP_1, start[2] < end[2] ? clamp(vertical, 0, 255) : 0)
	set_pev(ent, SENTRY_VERT_STEP_2, start[2] > end[2] ? clamp(-vertical, 0, 255) : 0)
	set_pev(ent, SENTRY_GUNS, 255 - floatround(deg_near_amount / 90.0 * 255.0, floatround_ceil))
	
	sentry_trace_attack(ent, data)
	
	if (data[_sentry_level] < 4)
	return
	
	switch (data[_sentry_module]) {
		case _module_nuclear: sentry_rocket_attack(ent, data)
		case _module_fire: sentry_rocket_attack(ent, data)
		case _module_gas: sentry_rocket_attack(ent, data)
		// case _module_eshotgun:
		case _module_plasma: sentry_barrel_attack(ent, data)
		case _module_laser: sentry_barrel_hook_attack(ent, data)
		case _module_electry: sentry_barrel_hook_attack(ent, data)
	}
}

// Анимация ожидания с учетом уровня
stock sentry_idle_fix(ent, data[class_sentry]) {
	switch(data[_sentry_level]) {
		case 1: animate_set(ent, _anime_idle2, 1.0)
		default: animate_set(ent, _anime_idle1, 1.0)
	}
}

// Атака пушки с помощью луча трассировки
public sentry_trace_attack(ent, data[class_sentry]) {
	if (data[_sentry_shot_timeleft] > get_gametime())
	return
	if (!is_user_connected(data[_sentry_owner]))
	return
	
	data[_sentry_shot_timeleft] = get_gametime() + setting[_sentry_shot_time]
	data[_sentry_trace_touch_ent] = 0
	data[_sentry_trace_touch_shield] = false
	
	static Float:start[3], Float:end[3], Float:empty[3], Float:move[2],
	trace_target, trace_hit, trace, Float:spread
	
	trace_target = ent
	trace = create_tr2()
	spread = random_float(-15.0, 15.0)
	visible_target_pos(data[_sentry_aim], end)
	engfunc(EngFunc_GetBonePosition, ent, setting[_sentry_bone_aim], start, empty)
	
	if (is_user_alive(data[_sentry_aim]))
	start[2] += 5
	
	engfunc(EngFunc_EmitAmbientSound, data[_sentry_foot], end, sound_list[_sound_shot], 0.5, ATTN_NORM, 0, PITCH_NORM)
	
	while (trace_target > 0) {
		engfunc(EngFunc_TraceLine, start, end, DONT_IGNORE_MONSTERS, trace_target, trace)
		engfunc(EngFunc_TraceHull, start, end, HULL_HEAD, trace_target, trace)
		
		trace_target = get_tr2(trace, TR_pHit)
		trace_hit = get_tr2(trace, TR_iHitgroup)
		get_tr2(trace, TR_vecEndPos, start)
		
		data[_sentry_trace_touch_pos] = start
		
		if (trace_hit == HIT_SHIELD) {
			sentry_shield_trace(trace_target, data)
			data[_sentry_trace_touch_shield] = true
			trace_target = 0
			user_arrow_move(ent, move, spread, 90.0)
			
			// engfunc(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, { 0, 0, 0 }, 0)
			// write_byte(TE_ARMOR_RICOCHET)
			// engfunc(EngFunc_WriteCoord, start[0] + move[0])
			// engfunc(EngFunc_WriteCoord, start[1] + move[1])
			// engfunc(EngFunc_WriteCoord, start[2] + spread)
			// write_byte(random_num(2, 5))
			// message_end()
		}
		else if (!pev_valided(trace_target)) {
			trace_target = 0
			continue
		}
		else if (fm_is_ent_classname(trace_target, CLASSNAME_SENTRY)) {
			if (pev(ent, pev_team) == pev(trace_target, pev_team))
			continue
			
			if (pev(trace_target, pev_health) < 0)
			continue
			
			data[_sentry_trace_touch_ent] = trace_target
			data[_sentry_lasthit] = trace_hit
			// set_pdata_int(trace_target, OFFSET_LASTHIT, trace_hit, OFFSET_LINUX)
			ExecuteHamB(Ham_TakeDamage, trace_target, ent, data[_sentry_owner], sentry_damage_level(setting[_sentry_damage_sentry], data[_sentry_level], data[_sentry_module]), DMG_BULLET)
			
			// engfunc(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, { 0, 0, 0 }, 0)
			// write_byte(TE_SPARKS)
			// engfunc(EngFunc_WriteCoord, start[0] + spread)
			// engfunc(EngFunc_WriteCoord, start[1] + spread)
			// engfunc(EngFunc_WriteCoord, start[2] + spread)
			// message_end()
		}
		else if (entity_player(trace_target)) {
			if (!is_user_alive(trace_target))
			continue
			if (pev(ent, pev_team) == get_user_team(trace_target))
			continue
			
			set_pdata_int(trace_target, OFFSET_LASTHIT, trace_hit, OFFSET_LINUX)
			data[_sentry_trace_touch_ent] = trace_target
			ExecuteHamB(Ham_TakeDamage, trace_target, ent, data[_sentry_owner], sentry_damage_level(setting[_sentry_damage_user], data[_sentry_level], data[_sentry_module]), DMG_SHOCK)
		}
		else {
			ExecuteHamB(Ham_TakeDamage, trace_target, ent, data[_sentry_owner], sentry_damage_level(setting[_sentry_damage_user], data[_sentry_level], data[_sentry_module]), DMG_SHOCK)
		}
	}
	
	if (setting[_sentry_shot_complex])
	switch (data[_sentry_level]) {
		case 1: sentry_trace_create_bone(ent, setting[_sentry_bone_main], end, spread)
		case 2..3: {
			sentry_trace_create_bone(ent, setting[_sentry_bone_left], end, spread)
			sentry_trace_create_bone(ent, setting[_sentry_bone_right], end, spread)	
		}
		default: 
		switch (data[_sentry_module]) {
			case 4..6: sentry_trace_create_bone(ent, setting[_sentry_bone_main], end, spread) 
			default: {
				sentry_trace_create_bone(ent, setting[_sentry_bone_left], end, spread)
				sentry_trace_create_bone(ent, setting[_sentry_bone_right], end, spread)	
			}
		}
	}
	
	free_tr2(trace)
}

// Трассировка пушки наткнулась на щит
public sentry_shield_trace(target, data[class_sentry]) {
	if (!pev_valided(target))
	return
	
	switch (data[_sentry_module]) {
		case _module_eshotgun: shield_durability_status(target)
		case _module_laser: shield_durability_status(target)
		case _module_electry: shield_durability_status(target)
	}
}

// Снижение прочности щита от урона определенных модулей
public shield_durability_status(id) {
	user_equip[id][_user_shield_durability] = floatclamp(user_equip[id][_user_shield_durability] - 0.4, 0.0, attr_damage[_dmg_shield_durability])
	
	if (user_equip[id][_user_shield_durability] > 0.0)
	return
	if (!pev_valided(id))
	return
	if (!get_pdata_bool(id, OFFSET_SHIELDHAS, OFFSET_LINUX_STEP))
	return
	
	static Float:pos[3], user_hud
	
	pev(id, pev_origin, pos)
	user_hud = get_pdata_int(id, OFFSET_HUD, OFFSET_LINUX)
	set_pdata_bool(id, OFFSET_SHIELDHAS, false, OFFSET_LINUX_STEP)
	set_pdata_bool(id, OFFSET_HASPRIMARY, false, OFFSET_LINUX_STEP)
	set_pdata_bool(id, OFFSET_HASPRIMARYX, false, OFFSET_LINUX_STEP)
	set_pdata_bool(id, OFFSET_SHIELDUSES, false, OFFSET_LINUX_STEP)
	
	user_hud &= ~WEAPON_CROSSHAIR
	set_pdata_int(id, OFFSET_HUD, user_hud, OFFSET_LINUX)
	
	// engfunc(EngFunc_MessageBegin, MSG_ONE_UNRELIABLE, message_list[_msg_crosshair], { 0, 0, 0 }, id)
	// write_byte(user_hud)
	// message_end()
	
	set_pev(id, pev_gamestate, 1)
	ExecuteHamB(Ham_Item_Deploy, get_pdata_cbase(id, OFFSET_ACTIVEITEM, OFFSET_LINUX))
	break_model_effect(pos, 1000.0, model_list[_model_shield_break_id], random_num(5, 15), 100)
}

// Эффект поломки
stock break_model_effect(Float:pos[3], Float:velocity, model, count, life) {
	engfunc(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, { 0, 0, 0 }, 0)
	write_byte(TE_EXPLODEMODEL)
	engfunc(EngFunc_WriteCoord, pos[0])
	engfunc(EngFunc_WriteCoord, pos[1])
	engfunc(EngFunc_WriteCoord, pos[2])
	engfunc(EngFunc_WriteCoord, velocity)
	write_short(model)
	write_short(count)
	write_byte(life)
	message_end()
}

// Пушка имитирует сканирование области
public sentry_scan(ent, data[class_sentry]) {
	if (data[_sentry_target]) {
		data[_sentry_scantime] = 0.0
		data[_sentry_scanrevety] = false
		return
	}
	if (data[_sentry_scantime] > get_gametime())
	return
	
	static Float:vec[3], bool:status
	
	pev(ent, pev_avelocity, vec)
	status = data[_sentry_scanrevety]
	vec[1] = status ? 30.0 : -30.0
	vec[1] = data[_sentry_scantime] == 0.0 ? -15.0 : vec[1]
	data[_sentry_scanrevety] = !status
	data[_sentry_scantime] = get_gametime() + 3.0
	set_pev(ent, pev_avelocity, vec)
}

// Уничтожение пушки после смерти (без эффектов)
public sentry_defence(data[class_sentry]) {
	data[_sentry_spawn_end] = true
	sentry_idle_fix(data[_sentry_self], data)
	sentry_idle_fix(data[_sentry_foot], data)
	sentry_movetype(data[_sentry_self], data[_sentry_foot], data[_sentry_alert], MOVETYPE_NOCLIP)
	
	return PLUGIN_CONTINUE
}

// Обработка ремонта пушки
public think_sentry_repair(id, ent) {
	if (!pev_valided(ent))
	return
	if (!is_user_alive(id))
	return
	if (cs_get_user_money(id) < setting[_sentry_cost_repair])
	return
	
	static data[class_sentry]
	data_get(sentry_list, ent, data, sizeof data)
	
	if (!is_user_connected(data[_sentry_owner]))
	return
	if (get_user_team(data[_sentry_owner]) != get_user_team(id))
	return
	
	static Float:head, Float:base, Float:head_max, Float:base_max, bool:repair
	
	head = data[_sentry_health][_sentry_health_head]
	base = data[_sentry_health][_sentry_health_base]
	head_max = sentry_health_get(data[_sentry_level] - 1, _sentry_health_head_multi)
	base_max = sentry_health_get(data[_sentry_level] - 1, _sentry_health_base_multi)
	repair = true
	
	if (setting[_sentry_common_solid]) {
		if (head == head_max)
		return
		
		data[_sentry_health][_sentry_health_head] = floatclamp(head + setting[_sentry_repair_value], 0.0, head_max)
	}
	else {
		if (head == head_max && base == base_max)
		return
		
		if (base / base_max > head / head_max)
		data[_sentry_health][_sentry_health_head] = head = floatclamp(head + setting[_sentry_repair_value], 0.0, head_max)
		else
		data[_sentry_health][_sentry_health_base] = base = floatclamp(base + setting[_sentry_repair_value], 0.0, base_max)
		
		set_pev(data[_sentry_alert], pev_frame, 360.0 - (base / base_max + head / head_max) / 2.0 * 360.0)
		// set_pev(data[_sentry_alert], pev_controller_0, floatround((base / base_max + head / head_max) / 2.0 * 255.0))
	}
	
	static Float:speed = 1.0, anime/* , models_message[sizeof submodel_message], key_message */
	
	speed = 1.0
	anime = 0
	
	switch (data[_sentry_anime]) {
		case _anime_break: {
			speed = 2.5
			anime = _anime_repair_break
		}
	}
	if (head < setting[_sentry_crash_level])
	repair = false
	if (base < setting[_sentry_crash_level] && !setting[_sentry_common_solid])
	repair = false
	if (data[_sentry_breaked] && !data[_sentry_repair] && repair) {
		data[_sentry_repair] = true
		animate_set(ent, anime, 1.0)
		animate_set(data[_sentry_foot], anime, 1.0)
		data[_sentry_repair_end] = get_gametime() + speed
		data[_sentry_repair_ended] = false
	}
	
	// models_message = { _alert_repair_start, _healthbar_health }
	// select_subs(models_message, submodel_message, sizeof submodel_message, key_message)
	// set_pev(data[_sentry_alert], pev_body, key_message)
	cs_set_user_money(id, cs_get_user_money(id) - setting[_sentry_cost_repair])
	data[_sentry_repairtime] = get_gametime()
	data[_sentry_repairtime2] = get_gametime()
	data_set(sentry_list, ent, data, sizeof data)
}

// Обработка ракет
public think_rocket(ent) {
	static data[class_rocket]
	
	data_get(rocket_list, ent, data, sizeof data)
	
	if (!pev_valided(data[_rocket_ent]))
	return FMRES_IGNORED
	if (data[_rocket_life_end] < get_gametime())
	return rocket_defence(ent)
	if (data[_rocket_sound_loop] < get_gametime()) {
		switch (data[_rocket_type]) {
			case _module_plasma : {}
			default: play_sound(ent, sound_list[_sound_rocket_fly])
		}
		data[_rocket_sound_loop] = get_gametime() + 1.0
	}
	
	rocket_ai(ent, data)
	set_pev(ent, pev_nextthink, get_gametime() + 0.1)
	data_set(rocket_list, ent, data, sizeof data)
	
	return FMRES_IGNORED
}

// Уничтожение ракеты после смерти
public rocket_defence(ent) {
	entity_kill(ent)
	data_remove(rocket_list, ent)
	return FMRES_IGNORED
}

// Авто наводка ракет
public rocket_ai(ent, data_rocket[class_rocket]) {
	if (!setting[_sentry_rocket_ai])
	return
	
	static data[class_sentry], Float:pos_rocket[3], Float:pos_target[3], Float:angles_ent[3], Float:angles_target[3], Float:velocity[3], Float:empty[3]
	
	data_get(sentry_list, data_rocket[_rocket_ent], data, sizeof data)
	
	if (!pev_valided(data[_sentry_aim]))
	return
	if (!is_user_alive(data[_sentry_aim]) && entity_player(data[_sentry_aim]))
	return
	
	pev(ent, pev_origin, pos_rocket)
	pev(ent, pev_angles, angles_ent)
	visible_target_pos(data[_sentry_aim], pos_target)
	
	if (fm_is_ent_classname(data[_sentry_aim], CLASSNAME_SENTRY)) {
		engfunc(EngFunc_GetBonePosition, data[_sentry_aim], setting[_sentry_bone_aim], pos_target, empty)
	}
	
	switch (data[_sentry_module]) {
		case _module_plasma: shell_trajectory_velocity(
			pos_rocket, pos_target, angles_ent, angles_target, velocity,
			attr_damage[_dmg_plasm_speed_shot], setting[_sentry_rocket_clamp]
		)
		
		default: shell_trajectory_velocity(
			pos_rocket, pos_target, angles_ent, angles_target, velocity,
			setting[_sentry_rocket_speed], setting[_sentry_rocket_clamp]
		)
	}
	
	set_pev(ent, pev_angles, angles_target)
	set_pev(ent, pev_velocity, velocity)
}

// Обработка льда
public think_ice(ent) {
	static data[class_any]
	
	data_get(any_list, ent, data, sizeof data)
	
	if (data[_any_replaced] && data[_any_end] < get_gametime()) {
		set_pev(ent, pev_takedamage, DAMAGE_NO)
		entity_kill(ent)
		data_remove(any_list, ent)
		
		return FMRES_IGNORED
	}
	
	set_pev(ent, pev_nextthink, get_gametime() + 0.1)
	
	if (!data[_any_replaced] && data[_any_end] < get_gametime()) {
		data[_any_end] = get_gametime() + 1.0
		animate_set(ent, _anime_ice_leave, 1.0)
		data[_any_replaced] = true
	}
	
	data_set(any_list, ent, data, sizeof data)
	
	return FMRES_IGNORED
}

// Обработка атаки пушки ракетами
public sentry_rocket_attack(ent, data[class_sentry]) {
	if (!pev_valided(data[_sentry_aim]))
	return
	if (fm_is_ent_classname(data[_sentry_aim], CLASSNAME_SENTRY))
	switch (data[_sentry_module]) {
		case _module_nuclear: return
		case _module_fire: return
		case _module_gas: return
		case _module_plasma: return
	}
	
	if (data[_sentry_shell_timeleft] > get_gametime())
	return
	if (data[_sentry_rocket_between_timeleft] > get_gametime())
	return
	
	if (data[_sentry_rocket_move] <= 0)
	data[_sentry_rocket_move] = setting[_sentry_rocket_count]
	
	data[_sentry_rocket_between_timeleft] = get_gametime() + setting[_sentry_rocket_between_time]
	data[_sentry_rocket_move]--
	
	play_sound(ent, sound_list[_sound_missile_rocket])
	sentry_rocket_fire(ent, data, setting[_sentry_bone_rocket_left])
	sentry_rocket_fire(ent, data, setting[_sentry_bone_rocket_right])
	
	if (data[_sentry_rocket_move] <= 0)
	data[_sentry_shell_timeleft] = get_gametime() + setting[_sentry_rocket_time]
}

// Обработка атаки из подствольника пушки (снаряды)
public sentry_barrel_attack(ent, data[class_sentry]) {
	if (data[_sentry_shell_timeleft] > get_gametime())
	return
	
	static Float:next_shot
	
	next_shot = 0.0
	
	switch (data[_sentry_module]) {
		case _module_plasma: {
			play_sound(ent, sound_list[_sound_plasma_shot])
			next_shot = attr_damage[_dmg_plasm_interval_shot]
		}
	}
	
	sentry_rocket_fire(ent, data, setting[_sentry_bone_laser_left])
	sentry_rocket_fire(ent, data, setting[_sentry_bone_laser_right])
	data[_sentry_shell_timeleft] = get_gametime() + next_shot
}

// Обработка атаки с трассированными спрайтами из подствольника пушки
public sentry_barrel_hook_attack(ent, data[class_sentry]) {
	if (!pev_valided(ent))
	return
	if (!pev_valided(data[_sentry_aim]))
	return
	if (data[_sentry_shell_timeleft] > get_gametime())
	return
	
	static Float:next_shot, size, sprite, fluct, bool:is_play, Float:damage, damage_type
	
	next_shot = 0.0
	size = 0
	sprite = 0
	fluct = 0
	is_play = false
	damage = 0.0
	damage_type = 0
	
	if (data[_sentry_play_sound_timeleft] < get_gametime()) {
		is_play = true
		data[_sentry_play_sound_timeleft] = get_gametime() + 0.5
	}
	
	switch (data[_sentry_module]) {
		case _module_laser: {
			next_shot = attr_damage[_dmg_laser_interval_shot]
			sprite = sprite_list[_sprite_beam_laser]
			size = setting[_sentry_size_beam_laser]
			fluct = setting[_sentry_fluct_beam_laser]
			damage = attr_damage[_dmg_laser_damage]
			damage_type = DMG_SHOCK
			
			if (is_play)
			play_sound(ent, sound_list[_sound_laser])
		}
		case _module_electry: {
			next_shot = attr_damage[_dmg_electric_interval_shot]
			sprite = sprite_list[_sprite_beam_electric]
			size = setting[_sentry_size_beam_electric]
			fluct = setting[_sentry_fluct_beam_electric]
			damage = attr_damage[_dmg_electric_damage]
			damage_type = DMG_SHOCK
			
			if (is_play)
			play_sound(ent, sound_list[_sound_electric])
		}
	}
	
	sentry_barrel_hook_fire(ent, data, setting[_sentry_bone_laser_left], sprite, size, fluct, damage, damage_type)
	sentry_barrel_hook_fire(ent, data, setting[_sentry_bone_laser_right], sprite, size, fluct, damage, damage_type)
	data[_sentry_shell_timeleft] = get_gametime() + next_shot
	
	if (data[_sentry_effect_timeleft] < get_gametime())
	data[_sentry_effect_timeleft] = get_gametime() + 0.3
	if (data[_sentry_rocket_between_timeleft] < get_gametime())
	data[_sentry_rocket_between_timeleft] = get_gametime() + attr_damage[_dmg_hook_interval]
}

// Атаки пушки ракетами
public sentry_rocket_fire(ent, data[class_sentry], bone) {
	static rocket, data_rocket[class_rocket], colors[3], Float:life_time,
	Float:pos_target[3], Float:pos_rocket[3], Float:empty[3], Float:angles_target[3], Float:velocity[3]
	
	rocket = fm_create_entity("func_breakable")
	
	if (!pev_valided(rocket))
	return PLUGIN_CONTINUE
	if (!pev_valided(data[_sentry_aim]))
	return PLUGIN_CONTINUE
	
	engfunc(EngFunc_GetBonePosition, ent, bone, pos_rocket, empty)
	pev(data[_sentry_aim], pev_origin, pos_target)
	color_rand(colors)
	
	// if (!pev_valided(rocket))
	// return PLUGIN_CONTINUE
	
	life_time = get_distance_f(pos_rocket, pos_target) / (setting[_sentry_rocket_speed] / 2) * setting[_sentry_rocket_lifetime]
	life_time += 1.0
	
	ArrayGetArray(setting[_sentry_sprite_module_damage_color], data[_sentry_module], colors)
	
	switch (data[_sentry_module]) {
		case _module_plasma: shell_trajectory_velocity(
			pos_rocket, pos_target, angles_target, angles_target, velocity,
			attr_damage[_dmg_plasm_speed_shot], setting[_sentry_rocket_clamp]
		)
		default: shell_trajectory_velocity(
			pos_rocket, pos_target, angles_target, angles_target, velocity,
			setting[_sentry_rocket_speed], setting[_sentry_rocket_clamp]
		)
	}
	
	set_pev(rocket, pev_angles, angles_target)
	set_pev(rocket, pev_velocity, velocity)
	set_pev(rocket, pev_movetype, MOVETYPE_FLY)
	set_pev(rocket, pev_solid, SOLID_TRIGGER)
	set_pev(rocket, pev_team, pev(ent, pev_team))
	set_pev(rocket, pev_classname, CLASSNAME_ROCKET)
	set_pev(rocket, pev_nextthink, get_gametime() + 0.1)
	
	switch (data[_sentry_module]) {
		case _module_plasma: {
			set_pev(rocket, pev_rendermode, kRenderTransAdd)
			set_pev(rocket, pev_renderfx, kRenderFxNoDissipation)
			set_pev(rocket, pev_frame, 0.0)
			set_pev(rocket, pev_framerate, 15.0)
			set_pev(rocket, pev_renderamt, 255.0)
			set_pev(rocket, pev_scale, 0.07)
			
			engfunc(EngFunc_SetModel, rocket, model_list[_model_plasma_fire])
			engfunc(EngFunc_SetSize, rocket, Float:{ -1.0, -1.0, -1.0 }, Float:{ 1.0, 1.0, 1.0 })
		}
		default: {
			engfunc(EngFunc_SetModel, rocket, model_list[_model_rocket_nuclear])
			engfunc(EngFunc_SetSize, rocket, Float:{ -4.0, -4.0, -4.0 }, Float:{ 4.0, 4.0, 4.0 })
		}
	}
	
	engfunc(EngFunc_SetOrigin, rocket, pos_rocket)
	
	data_rocket[_rocket_target] = data[_sentry_aim]
	data_rocket[_rocket_ent] = ent
	data_rocket[_rocket_owner] = data[_sentry_owner]
	data_rocket[_rocket_type] = data[_sentry_module]
	data_rocket[_rocket_life_end] = get_gametime() + life_time
	
	// engfunc(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, { 0, 0, 0 }, 0)
	// write_byte(TE_BEAMFOLLOW)
	// write_short(rocket)
	// write_short(sprite_list[_sprite_rocket_follow])
	// write_byte(1)
	// write_byte(10)
	// write_byte(colors[0])
	// write_byte(colors[1])
	// write_byte(colors[2])
	// write_byte(100)
	// message_end()
	
	data_set(rocket_list, rocket, data_rocket, sizeof data_rocket)
	return PLUGIN_CONTINUE
}

// Атака с трассированными спрайтами из подствольника пушки
public sentry_barrel_hook_fire(ent, data[class_sentry], bone, sprite, size, fluct, Float:damage, damage_type) {
	static Float:pos_shell[3], Float:empty[3], Float:pos_target[3], colors[3], target, owner, Float:dist_scan, Float:effect, scan_count
	
	target = data[_sentry_trace_touch_ent]
	owner = data[_sentry_owner]
	dist_scan = attr_damage[_dmg_electric_dist_scan]
	effect = data[_sentry_effect_timeleft]
	scan_count = attr_damage[_dmg_electric_count_trace]
	
	if (!pev_valided(target) || !is_user_connected(owner))
	return
	
	ArrayGetArray(setting[_sentry_sprite_module_damage_color], data[_sentry_module], colors)
	engfunc(EngFunc_GetBonePosition, ent, bone, pos_shell, empty)
	xs_vec_copy(data[_sentry_trace_touch_pos], pos_target)
	color_rand(colors)
	
	ExecuteHamB(Ham_TakeDamage, target, ent, owner, damage, damage_type)
	sentry_barrel_effect_hook(pos_shell, pos_target, colors, sprite, size, fluct)
	
	if (data[_sentry_rocket_between_timeleft] > get_gametime())
	return
	
	switch (data[_sentry_module]) {
		case _module_laser: {
			// shot_shell_sprite_effect(sprite_list[_sprite_laser], pos_target, 3, 50)
			play_sound(target, sound_list[_sound_laser], CHAN_VOICE)
		}
		case _module_electry: {
			// shot_shell_sprite_effect(sprite_list[_sprite_electric], pos_target, 3, 50)
			play_sound(target, sound_list[_sound_electric], CHAN_VOICE)
			sentry_addone_hook_engine_fire(ent, target, dist_scan, scan_count, colors, sprite, size, fluct, owner, damage, damage_type, effect)
		}
	}
}

// Атака с трассированными спрайтами из подствольника пушки, поиск и атака ближних жертв
public sentry_addone_hook_engine_fire(ent, target, Float:dist, count, colors[3], sprite, size, fluct, owner, Float:damage, damage_type, Float:effect) {
	static Float:pos_ent[3], Float:pos_target[3], bool:traced[33], i
	
	if (!pev_valided(target))
	return
	if (fm_is_ent_classname(target, CLASSNAME_SENTRY))
	return
	
	pev(target, pev_origin, pos_ent)
	traced[target] = true
	i = 0
	
	while (i++ < count) {
		search_min_dist(ent, target, pos_ent, traced, dist)
		
		if (traced[target])
		continue
		
		traced[target] = true
		pev(target, pev_origin, pos_target)
		sentry_barrel_effect_hook(pos_ent, pos_target, colors, sprite, size, fluct)
		ExecuteHamB(Ham_TakeDamage, target, ent, owner, damage * (count + 1) / i / (count + 1), damage_type)
		pos_ent = pos_target
		
		if (effect > get_gametime())
		return
		
		// shot_shell_sprite_effect(sprite_list[_sprite_electric], pos_target, 3, 50)
		shot_shell_shake_effect(target, 12, 3, 12)
	}
}

// Трассировка атаки по сущности
public trace_damage_ent(ent, attacker, Float:damage, Float:direction[3], trace) {
	if (!pev_valided(ent) || !is_user_alive(attacker))
	return HAM_IGNORED
	if (!fm_is_ent_classname(ent, CLASSNAME_SENTRY))
	return HAM_IGNORED
	
	static data[class_sentry]
	
	data_get(sentry_list, ent, data, sizeof data)
	data[_sentry_lasthit] = get_tr2(trace, TR_iHitgroup)
	data_set(sentry_list, ent, data, sizeof data)
	// set_pdata_int(ent, OFFSET_LASTHIT, hitbox, OFFSET_LINUX)
	
	return HAM_IGNORED
}

// Отлов перед атакой по игрока
public take_damage_player_pre(victim, broker, attacker, Float:dmg, weap) {
	if (!pev_valided(victim) || !is_user_connected(attacker))
	return HAM_IGNORED
	
	user_equip[victim][_user_damager_broker] = broker
	pev(victim, pev_velocity, user_equip[victim][_user_vector_move])
	
	if (fm_is_ent_classname(broker, CLASSNAME_SENTRY)) {
		// pev(victim, pev_velocity, user_equip[victim][_user_vector_move])
		// Если нужно разнообразие уронов - закоментировать
		SetHamParamInteger(5, 0)
		// user_equip[victim][_user_anime_activity] = get_pdata_int(victim, OFFSET_IDEALACTIVITY, OFFSET_LINUX)
	}
	else
	aura_attack_init(victim, attacker, dmg, weap)
	
	return HAM_IGNORED
}

// Отлов после атаки по игрока
public take_damage_player_post(victim, broker, attacker, Float:dmg, weap) {
	if (!pev_valided(victim) || !is_user_connected(attacker))
	return HAM_IGNORED
	// if (!fm_is_ent_classname(broker, CLASSNAME_SENTRY))
	// return HAM_IGNORED
	
	static Float:velocity[3]
	
	pev(victim, pev_velocity, velocity)
	xs_vec_sub(velocity, user_equip[victim][_user_vector_move], velocity)
	xs_vec_mul_scalar(velocity, 0.0, velocity)
	xs_vec_add(velocity, user_equip[victim][_user_vector_move], velocity)
	set_pev(victim, pev_velocity, velocity)
	
	// set_pdata_int(victim, OFFSET_ACTIVITY, user_equip[victim][_user_anime_activity], OFFSET_LINUX)
	// set_pdata_int(victim, OFFSET_IDEALACTIVITY, user_equip[victim][_user_anime_activity], OFFSET_LINUX)
	
	set_pdata_float(victim, OFFSET_PAINSHOCK, 1.0, OFFSET_LINUX)
	
	if (pev(victim, pev_team) == pev(attacker, pev_team) && victim != attacker && entity_player(attacker))
	return HAM_SUPERCEDE
	
	return HAM_IGNORED
}

// Обработка использования аур игроком при атаке жертв (только игроков)
public aura_attack_init(victim, attacker, Float:dmg, weap) {
	if (!is_user_alive(victim))
	return HAM_IGNORED
	if (!is_user_alive(attacker))
	return HAM_IGNORED
	if (victim == attacker)
	return HAM_IGNORED
	if (get_user_team(victim) == get_user_team(attacker))
	return HAM_IGNORED
	
	static Float:victim_aura_time, Float:attacket_aura_time, Float:time, colors[3], Float:max_vampire, Float:max_vampire_armor, i
	
	victim_aura_time = Float:user_equip[victim][_user_aura_timeleft][_aura_mirror]
	time = get_gametime()
	
	if (chance_complete(victim_aura_time, time, attr_aura[_aura_mirror_chance])) {
		ArrayGetArray(setting[_sentry_sprite_aura_color], _aura_mirror, colors)
		ExecuteHamB(Ham_TakeDamage, attacker, 0, victim, floatclamp(dmg, 0.0, attr_aura[_aura_mirror_max_clamp]), weap)
		SetHamParamFloat(4, 0.0)
		shot_screenfade_effect(victim, colors, 30, 30, 100)
	}
	
	for (i = 0; i < class_aura_sentry; i++) {
		attacket_aura_time = user_equip[attacker][_user_aura_timeleft][i]
		ArrayGetArray(setting[_sentry_sprite_aura_color], i, colors)
		switch(i) {
			case _aura_vampirism: {
				if (!chance_complete(attacket_aura_time, time, attr_aura[_aura_vampirism_chance]))
				continue
				
				max_vampire = floatclamp(dmg, 0.0, attr_aura[_aura_vampirism_max_clamp])
				max_vampire_armor = floatclamp(float(pev(attacker, pev_armorvalue)) + floatround(max_vampire, floatround_floor), 0.0, float(pev(attacker, pev_max_health)))
				// ExecuteHam(Ham_TakeHealth, attacker, max_vampire, DMG_GENERIC)
				shot_screenfade_effect(attacker, colors, 30, 30, 100)
				
				if (pev(attacker, pev_health) < attr_aura[_aura_vampirism_max_value])
				set_pev(attacker, pev_health, floatclamp(max_vampire + pev(attacker, pev_health), 0.0, attr_aura[_aura_vampirism_max_value]))
				
				if (pev(attacker, pev_armorvalue) >= attr_aura[_aura_vampirism_max_value])
				continue
				
				if (pev(attacker, pev_health) >= attr_aura[_aura_vampirism_max_value])
				set_pev(attacker, pev_armorvalue, floatclamp(max_vampire_armor + pev(attacker, pev_armorvalue), 0.0, attr_aura[_aura_vampirism_max_value]))
				
			}
			case _aura_critical: {
				if (!chance_complete(attacket_aura_time, time, attr_aura[_aura_critical_chance]))
				continue
				
				SetHamParamFloat(4, dmg * 2.0)
				shot_screenfade_effect(attacker, colors, 30, 30, 100)
			}
			case _aura_froze: {
				if (user_equip[victim][_user_frozen])
				continue
				if (!chance_complete(attacket_aura_time, time, attr_aura[_aura_froze]))
				continue
				
				create_frozen_entity(victim)
				set_pev(victim, pev_flags, pev(victim, pev_flags) | FL_FROZEN)
				user_equip[victim][_user_frozen] = true
				user_equip[victim][_user_effect_frozen_timeleft] = get_gametime() + attr_aura[_aura_froze_durability]
				shot_screenfade_effect(attacker, colors, 30, 30, 100)
			}
			case _aura_ammo: {
				if (!pev_valided(attacker))
				continue
				if (!chance_complete(attacket_aura_time, time, attr_aura[_aura_shake_chance]))
				continue
				
				static data[class_weapon], weap, weap_ent, clip, ammo
				
				weap = get_user_weapon(attacker, clip, ammo)
				weap_ent = get_pdata_cbase(attacker, OFFSET_ACTIVEITEM, OFFSET_LINUX)
				
				if (weap < CSW_P228 || weap > CSW_P90)
				continue
				
				data_get(weapon_list, weap, data, sizeof data)
				
				if (data[_weapon_max_clip] < 1)
				continue
				
				set_pdata_int(weap_ent, OFFSET_CLIPAMMO, clamp(attr_aura[_aura_ammo_count_add] + clip, 0, data[_weapon_max_clip]), OFFSET_LINUX)
				shot_screenfade_effect(attacker, colors, 30, 30, 100)
			}
			case _aura_shake: {
				if (!chance_complete(attacket_aura_time, time, attr_aura[_aura_shake_chance]))
				continue
				
				shot_shell_shake_effect(victim, 12, 15, 12)
				shot_screenfade_effect(attacker, colors, 30, 30, 100)
			}
		}
	}
	return HAM_IGNORED
}

// Создание сущности заморозки и заморозка игрока
public create_frozen_entity(id) {
	static ent, Float:pos_ent[3], Float:angles_user[3], data[class_any]
	
	ent = fm_create_entity("func_breakable")
	
	if (!pev_valided(ent))
	return PLUGIN_CONTINUE
	
	// fm_set_kvd(ent, "material", "1")
	
	pev(id, pev_origin, pos_ent)
	pev(id, pev_angles, angles_user)
	
	pos_ent[2] -= 20.0
	
	set_pev(ent, pev_angles, angles_user)
	set_pev(ent, pev_movetype, MOVETYPE_TOSS)
	set_pev(ent, pev_solid, SOLID_BBOX)
	set_pev(ent, pev_classname, CLASSNAME_ICE)
	set_pev(ent, pev_skin, 2)
	set_pev(ent, pev_health, float(0x200))
	set_pev(ent, pev_takedamage, DAMAGE_YES)
	set_pev(ent, pev_nextthink, get_gametime() + 0.1)
	// set_pev(ent, pev_rendermode, kRenderNormal)
	// set_pev(ent, pev_renderfx, kRenderFxNone)
	// set_pev(ent, pev_renderamt, 100.0)
	
	engfunc(EngFunc_SetModel, ent, model_list[_model_ice])
	engfunc(EngFunc_SetSize, ent, Float:{ -15.0, 0.0, -15.0 }, Float:{ 15.0, 30.0, 15.0 })
	engfunc(EngFunc_SetOrigin, ent, pos_ent)
	
	animate_set(ent, _anime_ice_spawn, 1.0)
	play_sound(ent, sound_list[_sound_ice_use])
	
	// engfunc(EngFunc_DropToFloor, ent)
	
	// data[_any_spawn] = get_gametime() + 1.0
	data[_any_end] = get_gametime() + attr_aura[_aura_froze_durability]
	data_set(any_list, ent, data, sizeof data)
	
	return PLUGIN_CONTINUE
}

// Отлов перед убийством игрока
public user_killed_pre(victim, attacker, bit) {
	// sentry_user_destroy(victim)
	
	// if (!pev_valided(victim))
	// return HAM_IGNORED
	
	static broker
	
	// broker = user_equip[victim][_user_damager_broker]
	// user_equip[victim][_user_damager_broker] = broker
	
	if (pev_valided(broker))
	return HAM_IGNORED
	if (fm_is_ent_classname(broker, CLASSNAME_SENTRY))
	set_msg_block(message_list[_msg_money], BLOCK_ONCE)
	
	return HAM_IGNORED
}

// Отлов после убийства игрока
public user_killed_post(victim, attacker, bit) {
	sentry_user_destroy(victim)
	
	static ent
	
	ent = user_equip[victim][_user_damager_broker]
	user_clear(victim)
	
	if (!pev_valided(victim) || !is_user_connected(attacker))
	return HAM_IGNORED
	if (!pev_valided(ent))
	return HAM_IGNORED
	
	if (fm_is_ent_classname(ent, CLASSNAME_SENTRY)) {
		cs_set_user_money(attacker, cs_get_user_money(attacker) - 300, 0)
		set_msg_block(message_list[_msg_money], BLOCK_NOT)
		reward_system(ent, attacker)
	}
	// Боты спавнят пушки
	else if (is_user_bot(attacker)) {
		// server_print(">>> BOT CMD BUILD SEND %d", attacker)
		// build_init_sentry(attacker, 1, 0, 0)
		cs_set_user_money(attacker, 160000)
		build_init_sentry(attacker, random_num(1, 5), random_num(1, 7), random_num(1, 7))
	}
	
	// user_equip[victim][_user_damager_broker] = 0
	return HAM_HANDLED
}

// Уничтожение пушек игрока
public sentry_user_destroy(id) {
	static Snapshot:snaps, i
	
	snaps = TrieSnapshotCreate(sentry_list)
	i = 0
	
	for (i = 0; i < TrieGetSize(sentry_list); i++) {
		static ent_string[32], ent, data[class_sentry]
		
		TrieSnapshotGetKey(snaps, i, ent_string, charsmax(ent_string))
		ent = str_to_num(ent_string)
		
		if (!pev_valided(ent))
		continue
		
		data_get(sentry_list, ent, data, sizeof data)
		
		if (data[_sentry_owner] != id)
		continue
		
		sentry_death_set(ent, data)
	}
	
	TrieSnapshotDestroy(snaps)
}

// Очищение данных игрока
public user_clear(id) {
	if (!is_user_connected(id))
	return
	
	static i
	// static data[class_user]
	
	for (i = 0; i < class_user; i++)
	user_equip[id][i] = 0
}

// Система награждения игрока при атаке по пушке
public reward_system(ent, attacker) {
	static data[class_sentry], owner_reward, broker, broker_reward, data_access[class_access], Trie:several, i
	
	data_get(sentry_list, ent, data, sizeof data)
	i = 0
	
	if (!is_user_connected(data[_sentry_owner]))
	return
	
	several = TrieCreate()
	
	if (data[_sentry_owner] == attacker) {
		owner_reward = data_user_clamp(attacker, access_set[_access_sentry_reward], data_access, sizeof data_access, true)
		cs_set_user_money(attacker, cs_get_user_money(attacker) + owner_reward, 1)
	}
	
	for (i = 0; i <= data[_sentry_level]; i++) {
		broker = data[_sentry_update_several][i]
		
		if (!pev_valided(broker))
		continue
		if (TrieKeyExists(several, int_to_str(broker)))
		continue
		if (data[_sentry_owner] == broker)
		continue
		if (get_user_team(data[_sentry_owner]) != get_user_team(broker))
		continue
		
		broker_reward = data_user_clamp(broker, access_set[_access_sentry_reward_broker], data_access, sizeof data_access, true)
		cs_set_user_money(broker, cs_get_user_money(broker) + broker_reward, 1)
	}
	
	TrieDestroy(several)
}

// Отлов урона по сущности
public take_damage_ent(ent, broker, attacker, Float:dmg, weap, bits) {
	if (!pev_valided(ent) || !is_user_connected(attacker))
	return HAM_IGNORED
	
	if (fm_is_ent_classname(ent, CLASSNAME_SENTRY))
	return take_damage_sentry(ent, attacker, weap, dmg, bits)
	if (fm_is_ent_classname(ent, CLASSNAME_ICE))
	return take_damage_ice(ent, attacker, weap, dmg)
	
	return HAM_IGNORED
}

public touch_entity(ent, id) {
	if (!is_user_alive(id))
	return FMRES_IGNORED
	if (user_equip[id][_user_nexttouch] > get_gametime())
	return FMRES_IGNORED
	
	user_equip[id][_user_nexttouch] = get_gametime() + 0.1
	
	if (fm_is_ent_classname(ent, CLASSNAME_SENTRY))
	return touch_entity_sentry(ent, id)
	
	return HAM_IGNORED	
}

public touch_entity_sentry(ent, id) {	
	if (pev(ent, pev_team) != get_user_team(id))
	return HAM_IGNORED
	if (!setting[_sentry_upgrade_touch])
	return HAM_IGNORED

	static data[class_sentry]
	
	data_get(sentry_list, ent, data, sizeof data)

	if (data[_sentry_upgrade] || data[_sentry_death] || data[_sentry_breaked])
	return HAM_IGNORED
	if (!data[_sentry_spawn_start])
	return HAM_IGNORED
	if (data[_sentry_spawn_start] && !data[_sentry_spawn_end])
	return HAM_IGNORED
	if (data[_sentry_repairtime] + 0.5 >= get_gametime())
	return HAM_IGNORED
	
	user_equip[id][_user_select_ent] = ent
	
	switch(data[_sentry_level]) {
		case 1:
		set_sentry_menu(id, 0)
		case 2:
		set_sentry_menu(id, 0)
		default:
		menu_sentry(id, ent)
	}	
	
	return HAM_IGNORED	
}

// Отлов урона по пушке
public take_damage_sentry(&ent, &attacker, &weap, &Float:dmg, &bits) {
	static data[class_sentry], animation, bool:breaking, hitbox
	
	breaking = false
	data_get(sentry_list, ent, data, sizeof data)
	hitbox = clamp(data[_sentry_lasthit], 0, class_sentry_hit - 1)
	// hitbox = clamp(get_pdata_int(ent, OFFSET_LASTHIT, OFFSET_LINUX), 0, class_sentry_hit - 1)
	dmg *= sentry_health[_sentry_hitbox_damage][hitbox] * setting[_sentry_multi_damage]
	SetHamParamFloat(4, dmg)
	
	if (data[_sentry_death])
	return HAM_SUPERCEDE
	if (!is_user_connected(data[_sentry_owner]))
	return HAM_SUPERCEDE
	if (data[_sentry_owner] != attacker && get_user_team(data[_sentry_owner]) == get_user_team(attacker))
	return HAM_SUPERCEDE
	
	if (sentry_health[_sentry_hits_head] & (1 << hitbox) || setting[_sentry_common_solid])
	data[_sentry_health][_sentry_health_head] -= dmg
	if (sentry_health[_sentry_hits_base] & (1 << hitbox) && !setting[_sentry_common_solid])
	data[_sentry_health][_sentry_health_base] -= dmg
	if (data[_sentry_health][_sentry_health_head] <= 0.0) {
		data[_sentry_health][_sentry_health_head] = 0.0
		animation = _anime_break
		breaking = true
	}
	else if (data[_sentry_health][_sentry_health_base] <= 0.0) {
		data[_sentry_health][_sentry_health_base] = 0.0
		animation = _anime_destroy
		breaking = true
	}
	if (breaking && !data[_sentry_breaked]) {
		data[_sentry_repairtime] = get_gametime()
		// set_pev(ent, pev_avelocity, Float:{ 0.0, 0.0, 0.0 })
		animate_set(ent, animation, 1.0)
		animate_set(data[_sentry_foot], animation, 1.0)
	}
	if (is_user_alive(attacker) && !data[_sentry_breaked] && attacker != data[_sentry_owner])
	cs_set_user_money(attacker, cs_get_user_money(attacker) + floatround(dmg * setting[_sentry_cost_damage] / 10))
	
	data[_sentry_anime] = animation
	data[_sentry_breaked] = breaking
	data_set(sentry_list, ent, data, sizeof data)
	
	return HAM_SUPERCEDE
}

// Отлов атаки по льду
public take_damage_ice(ent, attacker, weap, Float:dmg) {
	static  Float:pos_ent[3], data[class_any]
	
	pev(ent, pev_origin, pos_ent)
	
	if (pev(ent, pev_health) - dmg > 0.0) {
		engfunc(EngFunc_EmitAmbientSound, ent, pos_ent, sound_list[_sound_ice_break], 0.5, ATTN_NORM, 0, PITCH_NORM)
		return HAM_IGNORED
	}
	
	set_pev(ent, pev_takedamage, DAMAGE_NO)
	data_get(any_list, ent, data, sizeof data)
	data[_any_end] = get_gametime() + 1.0
	data[_any_replaced] = true
	animate_set(ent, _anime_ice_break, 1.0)
	data_set(any_list, ent, data, sizeof data)
	
	return HAM_SUPERCEDE
}

// Проверка зажатия клавишы E (В новых версиях изменится)
bool:cmd_clipped(buttons[5]) {
	static i
	
	for (i = 0 ; i < sizeof buttons; i++)
	if (~buttons[i] & IN_USE)
	return false
	
	return true
}

// Проверка доступа к пункту меню
bool:menu_status(id, balance, cost, access_user = 0) {
	return (access_status(id, access_user) && balance >= cost)
}

// Проверка и шанс того, что на жертву наложится эффект
bool:chance_complete(Float:aura_time, Float:time, chance) {
	if (aura_time < time)
	return false
	if (random_num(0, 100) > chance)
	return false
	
	return true
}

// Проверка сущности на игрока
bool:entity_player(id) {
	return 0 < id <= MaxClients
}

// Вертикальный угол к позиции от первоначальной позиции
Float:degress_vertical(Float:pos_ent[3], Float:pos_target[3]) {
	static Float:dist_vertic, Float:deg_vertic
	dist_vertic = floatabs(pos_ent[2] - pos_target[2])
	deg_vertic = floatasin(dist_vertic / get_distance_f(pos_target, pos_ent), degrees)
	return pos_ent[2] > pos_target[2] ? -deg_vertic : deg_vertic
}

// Урон пулемёта пушки в зависимости от уровня
Float:sentry_damage_level(Float:damage, level, module) {
	static Float:multi
	
	multi = 0.0
	
	switch (module) {
		case _module_eshotgun: {
			multi = 3.0
			damage = attr_damage[_dmg_shotgun_damage]
		}
		default: {
			multi = level > 3 ? 1.05 : level - 1.0
		}
	}
	return (1 + (multi * setting[_sentry_damage_multi])) * damage
}

// Нормализация углов
Float:deg_normal(Float:deg) {
	return floatmod(deg + 180.0, 360.0) - 180.0
}

// Остаток от числа
Float:floatmod(Float:count, Float:div = 180.0) {
	return count - div * floatround(count / div, floatround_floor)
}

// Горизонтальный угол к позиции от первоначальной позиции
Float:deg_hor(Float:pos1[3], Float:pos2[3]) {
	return ((pos1[1] > pos2[1] ? 180.0 : -180.0) - floatatan2(pos1[1] - pos2[1], pos1[0] - pos2[0], degrees)) * -1.0
}

// Направление угла
Float:get_grade_arrow(Float:deg) {
	return deg < 0.0 ? deg - 180.0 : 180.0 - deg
}

// Разница углов между двумя направлениями
Float:get_grade_diff(Float:victim, Float:attacker) {
	return floatmod(floatmin(180.0 - (victim - attacker), floatabs(victim - attacker) + 180.0), 360.0)
}

// Переход одного угла к значению второго с определенным шагом
Float:get_grade_step(Float:from, &Float:to, Float:step) {
	static Float:diff
	
	diff = to - from
	
	if (diff > 180.0)
	diff -= 360.0
	if (diff < -180.0)
	diff += 360.0
	
	to = from + floatmin(step, floatabs(diff)) * (diff < 0 ? -1.0 : 1.0)
	to = get_grade_arrow(get_grade_diff(to, 360.0))
}

// Поиск ближайшей цели
stock search_min_dist(ent, &target, Float:pos_ent[3], bool:traced[33], Float:dist) {
	static Float:pos_target_active[3], Float:ret_dist, Float:dist_ent, i
	
	ret_dist = 0.0
	
	// while (i++ < MaxClients) {
	for (i = 1; i <= MaxClients; i++) {
		if (traced[i] || !is_user_alive(i) || pev(ent, pev_team) == get_user_team(i))
		continue
		
		pev(i, pev_origin, pos_target_active)
		dist_ent = get_distance_f(pos_ent, pos_target_active)
		
		if (dist < dist_ent)
		continue
		if (ret_dist == 0.0 || dist_ent < ret_dist) {
			ret_dist = dist_ent
			target = i
		}
	}
}

// Количество пушек игрока
public sentry_user_count(id) {
	static Snapshot:snaps, count, ent_string[5], ent, data[class_sentry], i
	
	count = 0
	snaps = TrieSnapshotCreate(sentry_list)
	
	for (i = 0; i < TrieGetSize(sentry_list); i++) {
		TrieSnapshotGetKey(snaps, i, ent_string, charsmax(ent_string))
		ent = str_to_num(ent_string)
		data_get(sentry_list, ent, data, sizeof data)
		
		if (data[_sentry_owner] != id)
		continue
		
		count++
	}
	
	TrieSnapshotDestroy(snaps)
	return count
}

// Номер меню
stock menu_number(key) {
	static item[16]
	formatex(item, charsmax(item), "%L", LANG_PLAYER, "USG_MENU_NUMBER", key)
	return item
}

// Стоимость обычных уровней пушки
stock standart_cost(level) {
	switch(level) {
		case 1:
		return setting[_sentry_cost_2]
		case 2:
		return setting[_sentry_cost_3]
		default:
		return setting[_sentry_cost_1]
	}
	return 0
}

// Текст цены
stock menu_price(bool:status, cost) {
	static price[32]
	formatex(price, charsmax(price), "%s%d$", status ? "\y" : "", cost)
	return price
}

// Обработка перед выводом текста в меню
stock menu_context(level, id, size) {
	static context[512], item[32], price[32], len, cost, access_user, bool:success, balance, i
	
	balance = cs_get_user_money(id)
	len = 0
	
	for (i = 0; i < size; i++) {
		switch (level) {
			case 4: {
				access_user = access_set[_access_module][i]
				cost = setting[_sentry_cost_module][i]
			}
			case 5: {
				access_user = access_set[_access_aura][i]
				cost = setting[_sentry_cost_aura][i]
			}
		}
		
		success = access_status(id, access_user) && balance >= cost
		formatex(price, charsmax(price), "%s%d$", success ? "\y" : "", cost)
		formatex(item, charsmax(item), success ? "USG_LVL_%d_%d" : "USG_LVL_%d_%d_CANT", level, i)
		len += formatex(context[len], charsmax(context) - len, "%s%L^n", menu_number(i + 1), LANG_PLAYER, item, price)
	}
	
	return context
}

// Эффект тряски
stock shot_shell_shake_effect(target, amplitude, duration, frequency) {
	engfunc(EngFunc_MessageBegin, MSG_ONE_UNRELIABLE, message_list[_msg_screen_shake], { 0, 0, 0 }, target)
	write_short((1<<12) * amplitude)
	write_short((1<<12) * duration)
	write_short((1<<8) * frequency)
	message_end()
}

// Рисование трассировки атаки
stock sentry_trace_create_bone(ent, bone, Float:pos_target[3], Float:spread) {
	static Float:pos_bone[3], Float:empty[3], Float:move[2]
	
	engfunc(EngFunc_GetBonePosition, ent, bone, pos_bone, empty)
	
	engfunc(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, { 0, 0, 0 }, 0)
	write_byte(TE_TRACER)
	engfunc(EngFunc_WriteCoord, pos_bone[0])
	engfunc(EngFunc_WriteCoord, pos_bone[1])
	engfunc(EngFunc_WriteCoord, pos_bone[2])
	engfunc(EngFunc_WriteCoord, pos_target[0] + spread)
	engfunc(EngFunc_WriteCoord, pos_target[1] + spread)
	engfunc(EngFunc_WriteCoord, pos_target[2] + spread)
	message_end()
	
	user_arrow_move(ent, move, 3.0)
	pos_bone[0] += move[0]
	pos_bone[1] += move[1]
	
	shot_shell_sprite_effect(sprite_list[_sprite_muzzleflash], pos_bone, 5, 255)
}

// Эффект снаряда
stock shot_shell_sprite_effect(sprite, Float:pos[3], size, blure) {
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, pos, 0)
	write_byte(TE_SPRITE)
	engfunc(EngFunc_WriteCoord, pos[0])
	engfunc(EngFunc_WriteCoord, pos[1])
	engfunc(EngFunc_WriteCoord, pos[2])
	write_short(sprite)
	write_byte(size)
	write_byte(blure)
	message_end()
}

// Эффект взрыва
stock shot_shell_exp_effect(Float:pos[3], sprite, size, flags) {
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, { 0, 0, 0 }, 0)
	write_byte(TE_EXPLOSION)
	engfunc(EngFunc_WriteCoord, pos[0])
	engfunc(EngFunc_WriteCoord, pos[1])
	engfunc(EngFunc_WriteCoord, pos[2])
	write_short(sprite)
	write_byte(size)
	write_byte(0)
	write_byte(flags)
	message_end()
}

// Эффект экрана
stock shot_screenfade_effect(target, color[3], fadetime, holdtime, alpha) {
	engfunc(EngFunc_MessageBegin, MSG_ONE_UNRELIABLE, message_list[_msg_screen_fade], { 0, 0, 0 }, target)
	write_short((1<<6) * fadetime)
	write_short((1<<6) * holdtime)
	write_short(0x0000)
	write_byte(color[0])
	write_byte(color[1])
	write_byte(color[2])
	write_byte(alpha)
	message_end()
}

// Эффект частиц
stock shot_implosion_effect(Float:pos[3]) {
	engfunc(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, pos, 0)
	write_byte(TE_IMPLOSION)
	engfunc(EngFunc_WriteCoord, pos[0])
	engfunc(EngFunc_WriteCoord, pos[1])
	engfunc(EngFunc_WriteCoord, pos[2])
	write_byte(25)
	write_byte(10)
	write_byte(2)
	message_end()
}

// Проверка на расстояние к цели
stock sentry_search_dist(victim, attacker, &target_aim, &bool:target_status, &Float:previous_dist, Float:start[3]) {
	if (!pev_valided(victim) || !pev_valided(attacker))
	return
	if (!is_user_connected(victim) && entity_player(victim))
	return
	if (!is_user_alive(victim) && entity_player(victim))
	return
	if (pev(attacker, pev_team) == get_user_team(victim) && entity_player(victim))
	return
	if (pev(attacker, pev_team) == pev(victim, pev_team) && !entity_player(victim))
	return
	if (!fm_is_visible(victim, start, 1))
	return
	
	static Float:dist, Float:deg, Float:end[3], Float:render 
	
	pev(victim, pev_origin, end)
	pev(victim, pev_renderamt, render)
	
	dist = fm_entity_range(attacker, victim)
	deg = deg_normal(degress_vertical(start, end))
	
	
	
	if (floatabs(deg) > setting[_sentry_vertical_limit])
	return
	// if (render < setting[_sentry_invisible_limit])
	// return
	if (previous_dist > 0.0 && dist > previous_dist)
	return
	
	target_aim = victim
	target_status = true
	previous_dist = dist
}

// Угол вектора
stock angles_velocity(Float:velocity[3], Float:pos_start[3], Float:pos_end[3], Float:multi) {
	static Float:angles[3]
	
	angles[0] = deg_normal(degress_vertical(pos_start, pos_end))
	angles[1] = deg_normal(deg_hor(pos_start, pos_end))
	angles[2] = 0.0
	
	angle_vector(angles, ANGLEVECTOR_FORWARD, velocity)
	
	velocity[0] *= multi
	velocity[1] *= multi
	velocity[2] *= -multi
}

// Направление снаряда к цели с ограничением максимального поворота
stock shell_trajectory_velocity(Float:pos_start[3], Float:pos_end[3], Float:angles_ent[3], Float:angles[3], Float:velocity[3], Float:multi, Float:clamp = 30.0) {
	angles[0] = deg_normal(degress_vertical(pos_start, pos_end))
	angles[1] = deg_normal(deg_hor(pos_start, pos_end))
	angles[2] = 0.0
	
	get_grade_step(angles_ent[0], angles[0], clamp)
	get_grade_step(angles_ent[1], angles[1], clamp)
	
	angle_vector(angles, ANGLEVECTOR_FORWARD, velocity)
	
	velocity[0] *= multi
	velocity[1] *= multi
	velocity[2] *= -multi
}

// Смена типа перемещения
stock sentry_movetype(ent, foot, alert, movetype) {
	if (pev_valided(ent))
	set_pev(ent, pev_movetype, movetype)
	if (pev_valided(foot))
	set_pev(foot, pev_movetype, movetype)
	if (pev_valided(alert))
	set_pev(alert, pev_movetype, movetype)
}

// Случайные цвета, если значение = -1
stock color_rand(color[3]) {
	static i
	
	for (i = 0; i < sizeof color; i++)
	color[i] = color[i] == -1 ? random_num(0, 255) : color[i]
}

// Цифра с плавающей точкой в HEX
stock float_fix_16(Float:value, Float:min, Float:max, scale) {
	return floatround(floatclamp(value * scale, min, max), floatround_ceil)
}

// Рисование худа (потому что обычный show_hudmessage режет сообщение и переносит на новую строку там, где не надо))
stock short_hud(id, message[], Float:x, Float:y, r, g, b, a, effect, Float:fdi, Float:hd, Float:fdo, channel) {
	engfunc(EngFunc_MessageBegin, MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, { 0, 0, 0 }, id)
	write_byte(TE_TEXTMESSAGE)
	write_byte(channel)
	write_short(float_fix_16(x, -32768.0, 32768.0, 1 << 13))
	write_short(float_fix_16(y, -32768.0, 32768.0, 1 << 13))
	write_byte(effect)
	write_byte(r)
	write_byte(g)
	write_byte(b)
	write_byte(a)
	write_byte(r)
	write_byte(g)
	write_byte(b)
	write_byte(a)
	write_short(float_fix_16(fdi, 0.0, 65535.0, 1 << 8))
	write_short(float_fix_16(fdo, 0.0, 65535.0, 1 << 8))
	write_short(float_fix_16(hd,  0.0, 65535.0, 1 << 8))
	write_string(message)
	message_end()
}

// Получение здоровья пушки из переменной в зависимости от уровня
Float:sentry_health_get(level, multi) {
	return sentry_health[_sentry_health_level][level] * Float:sentry_health[multi]
}	

