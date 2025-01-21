
enum _:class_sentry_tower {
	_blank,
	_sentry_tower
}

enum _:class_sentry_legs {
	_blank,
	_sentry_legs
}

enum _:class_sentry_socket {
	_blank,
	_sentry_tower_socket
}

enum _:class_sentry_aim {
	_blank,
	_sentry_tower_aim
}

enum _:class_sentry_rockets {
	_blank,
	_sentry_tower_rockets
}

enum _:class_sentry_gun {
	_blank,
	_sentry_gun_core
}

enum _:class_sentry_guns {
	_blank,
	_sentry_guns_shotgun,
	_sentry_guns_energy,
	_sentry_guns_tesla
}

enum _:class_sentry_addone {
	_blank,
	_sentry_gun_ammo
}

enum _:class_sentry_under {
	_blank,
	_sentry_gun_rocket
}

enum _:class_sentry_holder {
	_blank,
	_sentry_gun_holder
}

enum _:class_sentry_icon_frame {
	_blank,
	_sentry_frame
}

enum _:class_sentry_icon_up {
	_blank,
	_sentry_icon_nuclear,
	_sentry_icon_fire,
	_sentry_icon_gas,
	_sentry_icon_shotgun,
	_sentry_icon_plasma,
	_sentry_icon_laser,
	_sentry_icon_energy
}

enum _:class_sentry_icon_down {
	_blank,
	_sentry_icon_vampirism,
	_sentry_icon_ricoshet,
	_sentry_icon_critical,
	_sentry_icon_frozen,
	_sentry_icon_clip,
	_sentry_icon_eye,
	_sentry_icon_deafen
}

enum _:class_sentry_subs {
	_sentry_sub_tower,
	_sentry_sub_legs, 
	_sentry_sub_socket, 
	_sentry_sub_aim, 
	_sentry_sub_rockets, 
	_sentry_sub_gun, 
	_sentry_sub_guns,  
	_sentry_sub_addone, 
	_sentry_sub_under, 
	_sentry_sub_holder,
	_sentry_sub_icon_frame, 
	_sentry_sub_icon_up, 
	_sentry_sub_icon_down
}

/* Подмодели пушки: Конец */
/* Подмодели сообщения: Начало */

enum _:class_message_alert {
	_blank,
	_alert_repair_need,
	_alert_repair_start,
}

enum _:class_message_healthbar {
	_blank,
	_healthbar_health
}

/* Подмодели сообщения: Конец */

// Скины пушки
enum {
	_skin_sentry_tt,
	_skin_sentry_ct,
	_skin_sentry,
	_skin_sentry_vip_tt,
	_skin_sentry_vip_ct,
	_skin_sentry_vip,
}

// Анимации пушки
enum {
	_anime_idle1,
	_anime_idle2,
	_anime_spawn_down,
	_anime_spawn_up,
	_anime_fire1, 
	_anime_fire2,
	_anime_fire3, 
	_anime_scan_area,
	_anime_scan_loop,
	_anime_upgrade_gun,
	_anime_upgrade_aim,
	_anime_upgrade_rockets,
	_anime_upgrade_gun_rockets,
	_anime_break,
	_anime_repair_break,
	_anime_destroy,
}

// Анимации льда
enum {
	_anime_ice_idle,
	_anime_ice_spawn,
	_anime_ice_leave,
	_anime_ice_break
}

// Хитбоксы пушки
enum _:class_sentry_hit {
	_sentry_hit_link,
	_sentry_hit_head,
	_sentry_hit_base,
	_sentry_hit_trunk
}

// Здоровье пушки
enum _:class_sentry_health {
	Float:_sentry_health_head,
	Float:_sentry_health_base
}

// Модули пушки
enum _:class_module_sentry {
	_module_nuclear,
	_module_fire,
	_module_gas,
	_module_eshotgun,
	_module_plasma,
	_module_laser,
	_module_electry
}

// Ауры пушки
enum _:class_aura_sentry {
	_aura_vampirism,
	_aura_mirror,
	_aura_critical,
	_aura_froze,
	_aura_ammo,
	_aura_vanish,
	_aura_shake
}

// Группы кфг
enum {
	_cfg_empty,
	_cfg_setting,
	_cfg_health,
	_cfg_force,
	_cfg_attack_module_stats,
	_cfg_aura_stats,
	_cfg_bone,
	_cfg_access_addition,
	_cfg_access_count,
	_cfg_access_reward,
	_cfg_access_reward_broker,
	_cfg_cost_items,
	_cfg_attr_sprite_items,
	_cfg_model,
	_cfg_sprite,
	_cfg_sound,
}

// Псевдокласс цветов
enum _:class_color {
	_red,
	_green,
	_blue
}

// Псевдокласс ракеты
enum class_rocket {
	_rocket_target,
	_rocket_ent,
	_rocket_owner,
	_rocket_type,
	
	Float:_rocket_life_end,
	Float:_rocket_sound_loop,
	
	bool:tochet
}

// Псевдокласс оружия
enum class_weapon {
	_weapon_max_clip
}

// Сообщения
enum _:message_event {
	_msg_money,
	_msg_saytext,
	_msg_death,
	_msg_damage,
	_msg_score,
	_msg_crosshair,
	_msg_screen_shake,
	_msg_screen_fade
}

// Псевдокласс физ. сил
enum _:class_force {
	Float:_force_sentry_radius_nuclear,
	Float:_force_sentry_radius_fire,
	Float:_force_sentry_radius_gas,
	Float:_force_sentry_radius_plasma,
	Float:_force_sentry_radius_exp,
	Float:_force_sentry_exp_force,
}

// Псевдокласс атрибута ауры
enum _:class_aura_attr {
	_aura_vampirism_chance,
	_aura_mirror_chance,
	_aura_critical_chance,
	_aura_froze_chance,
	_aura_ammo_chance,
	_aura_shake_chance,
	_aura_ammo_count_add,
	
	Float:_aura_time,
	Float:_aura_dist,
	Float:_aura_vampirism_max_value,
	Float:_aura_vampirism_max_clamp,
	Float:_aura_mirror_max_clamp,
	Float:_aura_froze_durability,
	Float:_aura_vanish_amount,
}

// Псевдокласс игрока
enum _:class_user {
	_user_select_ent,
	_user_select_key,
	_user_damage_effect,
	_user_attacker_ent,
	_user_attacker_owner,
	_user_damager_broker,
	_user_buttons[5],
	_user_anime_activity,
	// _user_anime_gaitsequence,
	
	Float:_user_nextthink,
	Float:_user_nexttouch,
	Float:_user_touch_time,
	Float:_user_aiming_time,
	// Float:_time_personal_sound,
	// Float:_time_personal_effect,
	Float:_user_effect_frozen_timeleft,
	// Float:_user_effect_vanish_other,
	Float:_user_effect_aura_time,
	Float:_user_damage_effect_time,
	Float:_user_damage_effect_interval,
	Float:_user_damage_effect_interval_next,
	Float:_user_shield_durability,
	Float:_user_aura_timeleft[class_aura_sentry],
	Float:_user_time_hold,
	Float:_user_time_key,
	Float:_user_vector_move[3],
	
	bool:_user_hero,
	bool:_user_vanish,
	bool:_user_frozen,
	bool:_user_death
}

// Псевдокласс моделей
enum class_model {
	_model_build[64],
	_model_alert[64],
	_model_ice[64],
	_model_rocket_nuclear[64],
	_model_rocket_fire[64],
	_model_rocket_gas[64],
	_model_plasma_fire[64],
	_model_shield_break[64],
	_model_sentry_break_1[64],
	_model_sentry_break_2[64],
	_model_sentry_break_3[64],
	
	_model_shield_break_id,
	_model_sentry_break_id_1,
	_model_sentry_break_id_2,
	_model_sentry_break_id_3
}

// Псевдокласс спрайтов
enum class_sprite {
	_sprite_destroy[64],
	// _sprite_blood[64],
	// _sprite_bloodspray[64],
	_sprite_aura_beam[64],
	_sprite_rocket_follow[64],
	_sprite_nuclear_small[64],
	_sprite_nuclear_big[64],
	_sprite_fire_small[64],
	_sprite_fire_big[64],
	_sprite_gas_small[64],
	_sprite_gas_big[64],
	_sprite_plase_shot[64],
	_sprite_beam_laser[64],
	_sprite_beam_electric[64],
	_sprite_plase_exp[64],
	_sprite_muzzleflash[64],
	_sprite_laser[64],
	_sprite_electric[64]
}

// Псевдокласс звуков
enum class_sound {
	_sound_build[64],
	_sound_upgrade[64],
	_sound_wave[64],
	_sound_repair[64],
	_sound_breaking[64],
	_sound_alert[64],
	_sound_shot[64],
	_sound_plasma_shot[64],
	_sound_plasma_exp[64],
	_sound_missile_rocket[64],
	_sound_rocket_explosion[64],
	_sound_rocket_fly[64],
	_sound_laser[64],
	_sound_electric[64],
	_sound_ice_use[64],
	_sound_ice_break[64],
}

// Псевдокласс любых данных
enum class_any {
	Float:_any_end,
	Float:_any_replace,
	
	bool:_any_replaced
}

// Псевдокласс урона
enum _:class_damage {
	_dmg_electric_count_trace,
	
	Float:_dmg_nuc_time,
	Float:_dmg_nuc_damage_explosion,
	Float:_dmg_nuc_interval_damage,
	Float:_dmg_nuc_interval_time,
	Float:_dmg_fire_time,
	Float:_dmg_fire_damage_explosion,
	Float:_dmg_fire_interval_damage,
	Float:_dmg_fire_interval_time,
	Float:_dmg_gas_time,
	Float:_dmg_gas_damage_explosion,
	Float:_dmg_gas_interval_damage,
	Float:_dmg_gas_interval_time,
	Float:_dmg_shotgun_damage,
	Float:_dmg_plasm_damage,
	Float:_dmg_plasm_speed_shot,
	Float:_dmg_plasm_interval_shot,
	Float:_dmg_laser_damage,
	Float:_dmg_laser_interval_shot,
	Float:_dmg_electric_damage,
	Float:_dmg_electric_interval_shot,
	Float:_dmg_electric_dist_scan,
	Float:_dmg_hook_interval,
	Float:_dmg_damage_froze_exp,
	Float:_dmg_shield_durability
}

// Псевдокласс здоровья пушки
enum _:class_health_sentry {
	Float:_sentry_hitbox_damage[class_sentry_hit],
	Float:_sentry_health_head_multi,
	Float:_sentry_health_base_multi,
	Float:_sentry_health_level[5],
	
	_sentry_hits_head,
	_sentry_hits_base
}

// Псевдокласс прав пушки
enum class_access_sentry {
	_access_module[class_module_sentry],
	_access_aura[class_aura_sentry],
	_access_sentry_reset,
	_access_sentry_update_self,
	_access_sentry_vip_skin,
	
	Trie:_access_sentry_count,
	Trie:_access_sentry_reward,
	Trie:_access_sentry_reward_broker
}

// Псевдокласс настроек
enum _:class_settings {
	bool:_sentry_common_solid,
	bool:_sentry_aim_sentry,
	bool:_sentry_upgrade_touch,
	bool:_sentry_shot_complex,
	bool:_sentry_shot_break,
	bool:_sentry_rocket_ai,
	
	Float:_sentry_damage_multi,
	Float:_sentry_damage_user,
	Float:_sentry_damage_sentry,
	Float:_sentry_shot_time,
	Float:_sentry_rocket_lifetime,
	Float:_sentry_rocket_time,
	Float:_sentry_rocket_clamp,
	Float:_sentry_rocket_speed,
	Float:_sentry_rocket_between_time,
	Float:_sentry_repair_time,
	Float:_sentry_multi_damage,
	Float:_sentry_explosion_damage,
	Float:_sentry_vertical_limit,
	Float:_sentry_invisible_limit,
	
	_sentry_rocket_count,
	_sentry_cost_1,
	_sentry_cost_2,
	_sentry_cost_3,
	_sentry_size_beam_laser,
	_sentry_size_beam_electric,
	_sentry_fluct_beam_laser,
	_sentry_fluct_beam_electric,
	_sentry_cost_module[class_module_sentry],
	_sentry_cost_aura[class_aura_sentry],
	_sentry_cost_reset,
	_sentry_crash_level,
	_sentry_repair_value,
	_sentry_cost_damage,
	_sentry_cost_repair,
	
	Array:_sentry_sprite_module,
	Array:_sentry_sprite_aura,
	Array:_sentry_sprite_aura_color,
	Array:_sentry_sprite_module_damage_color,
	
	_sentry_bone_aim,
	_sentry_bone_head,
	_sentry_bone_main,
	_sentry_bone_left,
	_sentry_bone_right,
	_sentry_bone_rocket_left,
	_sentry_bone_rocket_right,
	_sentry_bone_laser_left,
	_sentry_bone_laser_right,
	
	_sentry_menu_navigate = (1<<9),
	_sentry_menu_reset = (1<<8),
	_sentry_menu_standard = (1<<0),
	_sentry_menu_module = (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6),
	_sentry_menu_aura = (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6),
	_sentry_menu_full = (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<7)|(1<<8)|(1<<9)
}

// Псевдокласс пушки
enum class_sentry {
	_sentry_aim,
	// _sentry_aim_undo,
	_sentry_anime,
	_sentry_level,
	_sentry_owner,
	_sentry_module,
	_sentry_aura,
	_sentry_rocket_move,
	_sentry_trace_touch_ent,
	_sentry_update_several[6],
	_sentry_self,
	_sentry_foot,
	_sentry_alert,
	_sentry_health_step,
	_sentry_lasthit,
	
	bool:_sentry_trace_touch_shield,
	bool:_sentry_death,
	bool:_sentry_spawn_start,
	bool:_sentry_spawn_end,
	bool:_sentry_target,
	bool:_sentry_upgrade,
	bool:_sentry_repair_ended,
	bool:_sentry_upgrade_switched,
	bool:_sentry_scanrevety,
	bool:_sentry_breaked,
	bool:_sentry_repair,
	
	Float:_sentry_health[class_sentry_health],
	Float:_sentry_scantime,
	Float:_sentry_repairtime,
	Float:_sentry_repairtime2,
	Float:_sentry_defence_end,
	Float:_sentry_repair_end,
	Float:_sentry_destroyed, // 0.6
	Float:_sentry_upgrade_switch, // 0.6
	Float:_sentry_upgrade_end, // 2.6
	// Float:_sentry_upgrade_health, // 0.1
	Float:_sentry_personal_sound,
	Float:_sentry_effect_timeleft,
	Float:_sentry_shot_timeleft,
	Float:_sentry_aura_timeleft,
	Float:_sentry_shell_timeleft,
	Float:_sentry_play_sound_timeleft,
	Float:_sentry_rocket_between_timeleft,
	Float:_sentry_pos[3],
	Float:_sentry_angles[3],
	Float:_sentry_trace_touch_pos[3]
}