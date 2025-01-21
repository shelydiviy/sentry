
native Trie:get_sentry_list()
native get_sentry_setting(attr)
native Float:get_sentry_health(ent, type)

#define CLASSNAME_TESLA 		"tesla_ent"
#define CLASSNAME_SENTRY 		"sentry_ent"
#define CLASSNAME_FOOT			"sentry_foot"
#define CLASSNAME_ALERT			"sentry_alert"
#define CLASSNAME_SPRITE		"sentry_sprite"
#define CLASSNAME_ROCKET 		"sentry_rocket"
#define CLASSNAME_ICE 			"ice_ent"


// Псевдокласс прав дсотупа
enum class_access {
	// _access,
	_value
}

// Подсчет индекса подмодели
stock select_subs(keys[], maxs[], size, &key = 0, rise = 1) {
	static i
	
	key = 0
	rise = 1
	
	for (i = 0; i < size; i++) {
		key += rise * keys[i]
		rise = rise * maxs[i]
	}
	
	return key + 1
}

// Проверка доступа
bool:access_status(id, access_user) {
	if (!is_user_connected(id))
	return false
	if (access_user == ADMIN_ALL || access_user == ADMIN_USER)
	return true
	
	return (get_user_flags(id) & access_user) ? true : false
}

// Нахождение пределов базы
stock data_user_clamp(id, any:core, any:data[], size, bool:pow = false) {
	static Snapshot:snaps, key_string[5], count, i
	
	count = 0
	snaps = TrieSnapshotCreate(core)
	
	for (i = 0; i < TrieGetSize(core); i++) {
		TrieSnapshotGetKey(snaps, i, key_string, charsmax(key_string))		
		data_get_s(core, key_string, data, size)
		
		if (!access_status(id, read_flags(key_string)))
		continue
		if (pow && count >= data[_value])
		continue
		if (!pow && count <= data[_value])
		continue
		
		count = data[_value]
	}
	
	TrieSnapshotDestroy(snaps)
	return count
}

// Получение данных массива
stock data_get(any:list, key, any:output[], size) {
	if (!TrieKeyExists(list, int_to_str(key)))
	return
	
	TrieGetArray(list, int_to_str(key), output, size)
}

// Получение данных массива
stock data_get_s(any:list, key[], any:output[], size) {
	if (!TrieKeyExists(list, key))
	return
	
	TrieGetArray(list, key, output, size)
}

// Получение данных массива
stock data_set(any:list, key, any:buffer[], size) {
	TrieSetArray(list, int_to_str(key), buffer, size)
}

stock data_set_s(any:list, key[], any:buffer[], size) {
	TrieSetArray(list, key, buffer, size)
}

// Установка анимации
stock animate_set(ent, anim, Float:speed) {
	if (!pev_valided(ent))
	return
	
	set_pev(ent, pev_sequence, anim)
	set_pev(ent, pev_animtime, get_gametime())
	set_pev(ent, pev_framerate, speed)
}

// Цифру в текст (Именно этот, а не из fakemeta num_to_str)
stock int_to_str(ent) {
	static string_ent[32]
	
	num_to_str(ent, string_ent, charsmax(string_ent))
	return string_ent
}

stock pev_valided(id) {
	if (id == 0)
	return 0
	
	return pev_valid(id) == 2
}

// Вывод сообщений в чат
stock client_chat(id, const input[], any:...) {
	static msg[191], i
	vformat(msg, 190, input, 3)
	replace_all(msg, 190, "!g", "^4")
	replace_all(msg, 190, "!t", "^1")
	replace_all(msg, 190, "!n", "^3")
	replace_all(msg, 190, "!w", "^0")
	
	for (i = 1; i <= MaxClients; i++) {
		if (id != 0)
		i = id
		
		if (!is_user_connected(i) && id != 0)
		break
		if (!is_user_connected(i))
		continue
		
		engfunc(EngFunc_MessageBegin, MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), { 0, 0, 0 }, i)
		write_byte(i)
		write_string(msg)
		message_end()
		
		if (id != 0)
		break
	}
}		


// Проверка на пригодность области при установке пушки, с указанной дальностю обхвата территории
bool:entity_hull(ignore, Float:start[3], Float:mins[3], Float:maxs[3], Float:slant[3], Float:multi = 1.0) {
	static Float:min[3], Float:max[3]
	
	xs_vec_add_scaled(start, mins, multi, min)
	xs_vec_add_scaled(start, maxs, multi, max)
	
	if (fm_trace_fix(ignore, start, min[0], min[1], min[2], slant))
	return true
	if (fm_trace_fix(ignore, start, min[0], min[1], max[2], slant))
	return true
	if (fm_trace_fix(ignore, start, min[0], max[1], min[2], slant))
	return true
	if (fm_trace_fix(ignore, start, min[0], max[1], max[2], slant))
	return true
	if (fm_trace_fix(ignore, start, max[0], max[1], max[2], slant))
	return true
	if (fm_trace_fix(ignore, start, max[0], max[1], min[2], slant))
	return true
	if (fm_trace_fix(ignore, start, max[0], min[1], max[2], slant))
	return true
	if (fm_trace_fix(ignore, start, max[0], min[1], min[2], slant))
	return true
	
	return false
}

// Проверка присутствия преграды перед установкой пушки
bool:fm_trace_fix(ignore, Float:start[3], Float:end_0, Float:end_1, Float:end_2, Float:slant[3]) {
	static trace, Float:fraction, Float:end[3]
	
	trace = create_tr2()	
	xs_vec_set(end, end_0, end_1, end_2)
	engfunc(EngFunc_TraceLine, start, end, 0, ignore, trace)
	get_tr2(trace, TR_vecPlaneNormal, slant)
	get_tr2(trace, TR_flFraction, fraction)
	free_tr2(trace)
	
	return fraction < 1.0
}


// Проверка присутствия иных пушек рядом с устанавливаемой пушкой
bool:entity_search_radius(Trie:list, id, ent, Float:dist) {
	static Snapshot:snaps, Float:pos_spawn[3], Float:pos_target[3], i
	
	snaps = TrieSnapshotCreate(list)
	pev(ent, pev_origin, pos_spawn)
	
	for (i = 0; i < TrieGetSize(list); i++) {
		static ent_string[32], ent_vict
		
		TrieSnapshotGetKey(snaps, i, ent_string, charsmax(ent_string))
		ent_vict = str_to_num(ent_string)
		
		if (!pev_valided(ent_vict))
		continue
		if (ent == ent_vict)
		continue
		
		pev(ent_vict, pev_origin, pos_target)
		
		if (get_distance_f(pos_target, pos_spawn) > dist)
		continue
		
		client_chat(id, "%L %L", LANG_PLAYER, "USG_TAG", LANG_PLAYER, "USG_BLOCK_SENTRY_NEAR")
		TrieSnapshotDestroy(snaps)
		return true
	}
	
	TrieSnapshotDestroy(snaps)
	return false
}

// Проверка нахождения пушки в воздухе
bool:entity_solid_fly(id, ent) {
	if (fm_distance_to_floor(ent) < 75.0)
	return false
	
	client_chat(id, "%L %L", LANG_PLAYER, "USG_TAG", LANG_PLAYER, "USG_BLOCK_AIR")
	return true
}

// Проверка касания иных сущностей с устанавливаемой пушкой
bool:entity_solid_enter(id, Float:pos_spawn[3], hull, ent, monster) {
	static key
	
	key = fm_trace_hull(pos_spawn, hull, ent, monster)
	
	if (key == 0)
	return false
	
	client_chat(id, "%L %L", LANG_PLAYER, "USG_TAG", LANG_PLAYER, "USG_BLOCK_NEAR")
	return true
}

// Убийство сущности
public entity_kill(ent) {
	if (!pev_valided(ent))
	return
	
	set_pev(ent, pev_flags, pev(ent, pev_flags) | FL_KILLME)
	set_pev(ent, pev_nextthink, get_gametime())
}

// Новая точка по горизонтали в определенную длину от заданной
Float:user_arrow_move(id, Float:move[2], Float:dist, Float:arrow = 0.0) {
	static Float:angles_user[3]
	
	pev(id, pev_angles, angles_user)
	angles_user[1] = angles_user[1] + arrow
	move[0] = dist * floatcos(angles_user[1], degrees)
	move[1] = dist * floatsin(angles_user[1], degrees)
}

// Проигрывание звуков
stock play_sound(id, sound[], channel = CHAN_AUTO) {
	if (!pev_valided(id))
	return
	
	emit_sound(id, channel, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
}		

// Видимость цели по отношению к координатам
stock visible_target_pos(target, Float:point[3]) {
	if (!pev_valided(target))
	return
	
	static Float:view_ofs[3]
	pev(target, pev_origin, point)
	pev(target, pev_view_ofs, view_ofs)
	xs_vec_add(point, view_ofs, point)
}

// Эффект с трассированными спрайтами
stock sentry_barrel_effect_hook(Float:pos_shell[3], Float:pos_target[3], colors[], sprite, size, fluct, time = 2) {
	engfunc(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, { 0, 0, 0 }, 0)
	write_byte(TE_BEAMPOINTS)
	engfunc(EngFunc_WriteCoord, pos_shell[0])
	engfunc(EngFunc_WriteCoord, pos_shell[1])
	engfunc(EngFunc_WriteCoord, pos_shell[2])
	engfunc(EngFunc_WriteCoord, pos_target[0])
	engfunc(EngFunc_WriteCoord, pos_target[1])
	engfunc(EngFunc_WriteCoord, pos_target[2])
	write_short(sprite)
	write_byte(0)
	write_byte(0)
	write_byte(time)
	write_byte(size)
	write_byte(fluct)
	write_byte(colors[0])
	write_byte(colors[1])
	write_byte(colors[2])
	write_byte(255)
	write_byte(200)
	message_end()
}

// Удаление массива данных
stock data_remove(Trie:list, key) {
	if (!TrieKeyExists(list, int_to_str(key))) {
		// Пусть будет, это условие и не будет вовсе работать
		server_print(">>> [ALERT] Попытка удалить несуществующий массив")
		return
	}
	
	TrieDeleteKey(list, int_to_str(key))
}