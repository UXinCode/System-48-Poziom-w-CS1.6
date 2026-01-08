#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <cstrike>
#include <fun>
#include <sqlx>
#include <engine>
#include <basebuilder>

#define PLUGIN "System Poziomów"
#define VERSION "1.0"
#define AUTHOR "Amator/SkyDev"

#define MAX_PLAYERS 32
#define MAX_LEVELS 48 // Levels 0-47
#define MAX_WEAPONS 24
#define XP_KILL 10
#define XP_HEADSHOT 15
#define GOLD_LEVEL 24
#define HUD_CHANNEL 3 // HUD channel
#define ADMIN_FLAG ADMIN_BAN
#define MIN_LONG_WEAPON_LEVEL 6

#define WEAPON_GLOCK 0
#define WEAPON_USP 1
#define WEAPON_P228 2
#define WEAPON_FIVESEVEN 3
#define WEAPON_DEAGLE 4
#define WEAPON_ELITE 5
#define WEAPON_TMP 6
#define WEAPON_SCOUT 7
#define WEAPON_MAC10 8
#define WEAPON_AWP 9
#define WEAPON_UMP45 10
#define WEAPON_MP5 11
#define WEAPON_P90 12
#define WEAPON_M3 13
#define WEAPON_XM1014 14
#define WEAPON_FAMAS 15
#define WEAPON_GALIL 16
#define WEAPON_M4A1 17
#define WEAPON_AK47 18
#define WEAPON_AUG 19
#define WEAPON_SG552 20
#define WEAPON_M249 21
#define WEAPON_G3SG1 22
#define WEAPON_SG550 23

new const g_LevelXP[MAX_LEVELS + 1] = {
0, 50, 100, 200, 400, 800, 1600, 3200, 6400, 12800, 25600, 51200,
102400, 204800, 409600, 819200, 1638400, 3276800, 6553600, 13107200,
26214400, 52428800, 104857600, 209715200, 419430400, 838860800,
1677721600, 3355443200, 6710886400, 13421772800, 26843545600, 53687091200,
107374182400, 214748364800, 429496729600, 858993459200, 1717986918400,
3435973836800, 6871947673600, 13743895347200, 27487790694400, 54975581388800,
109951162777600, 219902325555200, 439804651110400, 879609302220800,
1759218604441600, 3518437208883200, 7036874417766400
}; // Extended exponentially

new const g_WeaponIds[MAX_WEAPONS] = {
CSW_GLOCK18, CSW_USP, CSW_P228, CSW_FIVESEVEN, CSW_DEAGLE, CSW_ELITE,
CSW_TMP, CSW_SCOUT, CSW_MAC10, CSW_AWP, CSW_UMP45, CSW_MP5NAVY,
CSW_P90, CSW_M3, CSW_XM1014, CSW_FAMAS, CSW_GALIL, CSW_M4A1,
CSW_AK47, CSW_AUG, CSW_SG552, CSW_M249, CSW_G3SG1, CSW_SG550
};

new const g_WeaponBoxNames[MAX_WEAPONS][32] = {
"weapon_glock18", "weapon_usp", "weapon_p228", "weapon_fiveseven", "weapon_deagle", "weapon_elite",
"weapon_tmp", "weapon_scout", "weapon_mac10", "weapon_awp", "weapon_ump45", "weapon_mp5navy",
"weapon_p90", "weapon_m3", "weapon_xm1014", "weapon_famas", "weapon_galil", "weapon_m4a1",
"weapon_ak47", "weapon_aug", "weapon_sg552", "weapon_m249", "weapon_g3sg1", "weapon_sg550"
};

new const g_DisplayNames[MAX_WEAPONS][32] = {
"Glock", "USP", "P228", "Five-Seven", "Deagle", "Elite",
"TMP", "Scout", "MAC-10", "AWP", "UMP45", "MP5 Navy",
"P90", "M3", "XM1014", "Famas", "Galil", "M4A1",
"AK47", "AUG", "SG552", "M249", "G3SG1", "SG550"
};

new g_VModels[MAX_WEAPONS][2][64];
new g_PModels[MAX_WEAPONS][2][64];

new g_Level[MAX_PLAYERS + 1];
new g_XP[MAX_PLAYERS + 1];
new g_LastPistol[MAX_PLAYERS + 1];
new g_LastPrimary[MAX_PLAYERS + 1];

new Handle:g_SqlTuple;
new g_SpriteLevelUp;

new g_LevelupTarget[MAX_PLAYERS + 1];
new bool:g_WaitingForAmount[MAX_PLAYERS + 1];
new bool:g_RoundStarted = false;
new bool:g_InBuildPhase = false;
new bool:g_InPrepPhase = false;
new bool:g_bronWybrana[MAX_PLAYERS + 1];
new g_WeaponSelectCount[MAX_PLAYERS + 1];
new bool:g_IsZombie[MAX_PLAYERS + 1]; // Cache dla bb_is_user_zombie

public plugin_precache() {
	// Standard models
	formatex(g_VModels[WEAPON_GLOCK][0], 63, "models/v_glock18.mdl");
	formatex(g_PModels[WEAPON_GLOCK][0], 63, "models/p_glock18.mdl");
	formatex(g_VModels[WEAPON_USP][0], 63, "models/v_usp.mdl");
	formatex(g_PModels[WEAPON_USP][0], 63, "models/p_usp.mdl");
	formatex(g_VModels[WEAPON_P228][0], 63, "models/v_p228.mdl");
	formatex(g_PModels[WEAPON_P228][0], 63, "models/p_p228.mdl");
	formatex(g_VModels[WEAPON_FIVESEVEN][0], 63, "models/v_fiveseven.mdl");
	formatex(g_PModels[WEAPON_FIVESEVEN][0], 63, "models/p_fiveseven.mdl");
	formatex(g_VModels[WEAPON_DEAGLE][0], 63, "models/v_deagle.mdl");
	formatex(g_PModels[WEAPON_DEAGLE][0], 63, "models/p_deagle.mdl");
	formatex(g_VModels[WEAPON_ELITE][0], 63, "models/v_elite.mdl");
	formatex(g_PModels[WEAPON_ELITE][0], 63, "models/p_elite.mdl");
	formatex(g_VModels[WEAPON_TMP][0], 63, "models/v_tmp.mdl");
	formatex(g_PModels[WEAPON_TMP][0], 63, "models/p_tmp.mdl");
	formatex(g_VModels[WEAPON_SCOUT][0], 63, "models/v_scout.mdl");
	formatex(g_PModels[WEAPON_SCOUT][0], 63, "models/p_scout.mdl");
	formatex(g_VModels[WEAPON_MAC10][0], 63, "models/v_mac10.mdl");
	formatex(g_PModels[WEAPON_MAC10][0], 63, "models/p_mac10.mdl");
	formatex(g_VModels[WEAPON_AWP][0], 63, "models/v_awp.mdl");
	formatex(g_PModels[WEAPON_AWP][0], 63, "models/p_awp.mdl");
	formatex(g_VModels[WEAPON_UMP45][0], 63, "models/v_ump45.mdl");
	formatex(g_PModels[WEAPON_UMP45][0], 63, "models/p_ump45.mdl");
	formatex(g_VModels[WEAPON_MP5][0], 63, "models/v_mp5.mdl");
	formatex(g_PModels[WEAPON_MP5][0], 63, "models/p_mp5.mdl");
	formatex(g_VModels[WEAPON_P90][0], 63, "models/v_p90.mdl");
	formatex(g_PModels[WEAPON_P90][0], 63, "models/p_p90.mdl");
	formatex(g_VModels[WEAPON_M3][0], 63, "models/v_m3.mdl");
	formatex(g_PModels[WEAPON_M3][0], 63, "models/p_m3.mdl");
	formatex(g_VModels[WEAPON_XM1014][0], 63, "models/v_xm1014.mdl");
	formatex(g_PModels[WEAPON_XM1014][0], 63, "models/p_xm1014.mdl");
	formatex(g_VModels[WEAPON_FAMAS][0], 63, "models/v_famas.mdl");
	formatex(g_PModels[WEAPON_FAMAS][0], 63, "models/p_famas.mdl");
	formatex(g_VModels[WEAPON_GALIL][0], 63, "models/v_galil.mdl");
	formatex(g_PModels[WEAPON_GALIL][0], 63, "models/p_galil.mdl");
	formatex(g_VModels[WEAPON_M4A1][0], 63, "models/v_m4a1.mdl");
	formatex(g_PModels[WEAPON_M4A1][0], 63, "models/p_m4a1.mdl");
	formatex(g_VModels[WEAPON_AK47][0], 63, "models/v_ak47.mdl");
	formatex(g_PModels[WEAPON_AK47][0], 63, "models/p_ak47.mdl");
	formatex(g_VModels[WEAPON_AUG][0], 63, "models/v_aug.mdl");
	formatex(g_PModels[WEAPON_AUG][0], 63, "models/p_aug.mdl");
	formatex(g_VModels[WEAPON_SG552][0], 63, "models/v_sg552.mdl");
	formatex(g_PModels[WEAPON_SG552][0], 63, "models/p_sg552.mdl");
	formatex(g_VModels[WEAPON_M249][0], 63, "models/v_m249.mdl");
	formatex(g_PModels[WEAPON_M249][0], 63, "models/p_m249.mdl");
	formatex(g_VModels[WEAPON_G3SG1][0], 63, "models/v_g3sg1.mdl");
	formatex(g_PModels[WEAPON_G3SG1][0], 63, "models/p_g3sg1.mdl");
	formatex(g_VModels[WEAPON_SG550][0], 63, "models/v_sg550.mdl");
	formatex(g_PModels[WEAPON_SG550][0], 63, "models/p_sg550.mdl");
	// Gold models
	formatex(g_VModels[WEAPON_GLOCK][1], 63, "models/MDLClassicBB/v_glock18.mdl");
	formatex(g_PModels[WEAPON_GLOCK][1], 63, "models/MDLClassicBB/p_glock18.mdl");
	formatex(g_VModels[WEAPON_USP][1], 63, "models/MDLClassicBB/v_usp.mdl");
	formatex(g_PModels[WEAPON_USP][1], 63, "models/MDLClassicBB/p_usp.mdl");
	formatex(g_VModels[WEAPON_P228][1], 63, "models/MDLClassicBB/v_p228.mdl");
	formatex(g_PModels[WEAPON_P228][1], 63, "models/MDLClassicBB/p_p228.mdl");
	formatex(g_VModels[WEAPON_FIVESEVEN][1], 63, "models/MDLClassicBB/v_fiveseven.mdl");
	formatex(g_PModels[WEAPON_FIVESEVEN][1], 63, "models/MDLClassicBB/p_fiveseven.mdl");
	formatex(g_VModels[WEAPON_DEAGLE][1], 63, "models/MDLClassicBB/v_deagle.mdl");
	formatex(g_PModels[WEAPON_DEAGLE][1], 63, "models/MDLClassicBB/p_deagle.mdl");
	formatex(g_VModels[WEAPON_ELITE][1], 63, "models/MDLClassicBB/v_elite.mdl");
	formatex(g_PModels[WEAPON_ELITE][1], 63, "models/MDLClassicBB/p_elite.mdl");
	formatex(g_VModels[WEAPON_TMP][1], 63, "models/MDLClassicBB/v_tmp.mdl");
	formatex(g_PModels[WEAPON_TMP][1], 63, "models/MDLClassicBB/p_tmp.mdl");
	formatex(g_VModels[WEAPON_SCOUT][1], 63, "models/MDLClassicBB/v_scout.mdl");
	formatex(g_PModels[WEAPON_SCOUT][1], 63, "models/MDLClassicBB/p_scout.mdl");
	formatex(g_VModels[WEAPON_MAC10][1], 63, "models/MDLClassicBB/v_mac10.mdl");
	formatex(g_PModels[WEAPON_MAC10][1], 63, "models/MDLClassicBB/p_mac10.mdl");
	formatex(g_VModels[WEAPON_AWP][1], 63, "models/MDLClassicBB/v_awp.mdl");
	formatex(g_PModels[WEAPON_AWP][1], 63, "models/MDLClassicBB/p_awp.mdl");
	formatex(g_VModels[WEAPON_UMP45][1], 63, "models/MDLClassicBB/v_ump45.mdl");
	formatex(g_PModels[WEAPON_UMP45][1], 63, "models/MDLClassicBB/p_ump45.mdl");
	formatex(g_VModels[WEAPON_MP5][1], 63, "models/MDLClassicBB/v_mp5.mdl");
	formatex(g_PModels[WEAPON_MP5][1], 63, "models/MDLClassicBB/p_mp5.mdl");
	formatex(g_VModels[WEAPON_P90][1], 63, "models/MDLClassicBB/v_p90.mdl");
	formatex(g_PModels[WEAPON_P90][1], 63, "models/MDLClassicBB/p_p90.mdl");
	formatex(g_VModels[WEAPON_M3][1], 63, "models/MDLClassicBB/v_m3.mdl");
	formatex(g_PModels[WEAPON_M3][1], 63, "models/MDLClassicBB/p_m3.mdl");
	formatex(g_VModels[WEAPON_XM1014][1], 63, "models/MDLClassicBB/v_xm1014.mdl");
	formatex(g_PModels[WEAPON_XM1014][1], 63, "models/MDLClassicBB/p_xm1014.mdl");
	formatex(g_VModels[WEAPON_FAMAS][1], 63, "models/MDLClassicBB/v_famas.mdl");
	formatex(g_PModels[WEAPON_FAMAS][1], 63, "models/MDLClassicBB/p_famas.mdl");
	formatex(g_VModels[WEAPON_GALIL][1], 63, "models/MDLClassicBB/v_galil.mdl");
	formatex(g_PModels[WEAPON_GALIL][1], 63, "models/MDLClassicBB/p_galil.mdl");
	formatex(g_VModels[WEAPON_M4A1][1], 63, "models/MDLClassicBB/v_m4a1.mdl");
	formatex(g_PModels[WEAPON_M4A1][1], 63, "models/MDLClassicBB/p_m4a1.mdl");
	formatex(g_VModels[WEAPON_AK47][1], 63, "models/MDLClassicBB/v_ak47.mdl");
	formatex(g_PModels[WEAPON_AK47][1], 63, "models/MDLClassicBB/p_ak47.mdl");
	formatex(g_VModels[WEAPON_AUG][1], 63, "models/MDLClassicBB/v_aug.mdl");
	formatex(g_PModels[WEAPON_AUG][1], 63, "models/MDLClassicBB/p_aug.mdl");
	formatex(g_VModels[WEAPON_SG552][1], 63, "models/MDLClassicBB/v_sg552.mdl");
	formatex(g_PModels[WEAPON_SG552][1], 63, "models/MDLClassicBB/p_sg552.mdl");
	formatex(g_VModels[WEAPON_M249][1], 63, "models/MDLClassicBB/v_m249.mdl");
	formatex(g_PModels[WEAPON_M249][1], 63, "models/MDLClassicBB/p_m249.mdl");
	formatex(g_VModels[WEAPON_G3SG1][1], 63, "models/MDLClassicBB/v_g3sg1.mdl");
	formatex(g_PModels[WEAPON_G3SG1][1], 63, "models/MDLClassicBB/p_g3sg1.mdl");
	formatex(g_VModels[WEAPON_SG550][1], 63, "models/MDLClassicBB/v_sg550.mdl");
	formatex(g_PModels[WEAPON_SG550][1], 63, "models/MDLClassicBB/p_sg550.mdl");
	// Precache all
	for (new i = 0; i < MAX_WEAPONS; i++) {
		for (new j = 0; j < 2; j++) {
			precache_model(g_VModels[i][j]);
			precache_model(g_PModels[i][j]);
		}
	}
	precache_sound("umbrella/levelup.wav");
	g_SpriteLevelUp = precache_model("sprites/xfire.spr");
}

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);
	g_SqlTuple = SQL_MakeStdTuple();
	new create_query[512];
	formatex(create_query, 511, "CREATE TABLE IF NOT EXISTS gunxpmod_players (authid VARCHAR(32) PRIMARY KEY, name VARCHAR(32), level INT NOT NULL DEFAULT 0, xp INT NOT NULL DEFAULT 0, last_pistol INT NOT NULL DEFAULT -1, last_primary INT NOT NULL DEFAULT -1)");
	SQL_ThreadQuery(g_SqlTuple, "QueryHandlerIgnore", create_query);
	register_event("DeathMsg", "event_death", "a");
	register_clcmd("say /bronie", "cmd_show_main_menu");
	register_clcmd("say /levelup", "cmd_show_levelup_menu");
	register_clcmd("say /topxp", "show_top");
	register_clcmd("say", "handle_levelup_amount");
	RegisterHam(Ham_Spawn, "player", "fwd_spawn", 1);
	for (new i = 0; i < MAX_WEAPONS; i++) {
		RegisterHam(Ham_Item_Deploy, g_WeaponBoxNames[i], "fwd_item_deploy", 1);
	}
	register_message(get_user_msgid("SayText"), "fwd_SayText");
	register_event("HLTV", "event_new_round", "a", "1=0", "2=0");
	register_forward(FM_PlayerPreThink, "fwd_PlayerPreThink_Post", 1); // Do update cache zombie
}

public client_connect(id) {
	load_data(id);
	update_hud(id);
	g_WaitingForAmount[id] = false;
	g_LevelupTarget[id] = 0;
	g_WeaponSelectCount[id] = 0;
}

public client_disconnected(id) {
	save_data(id);
}

public event_new_round() {
	g_RoundStarted = true;
	for (new id = 1; id <= MAX_PLAYERS; id++) {
		g_WeaponSelectCount[id] = 0;
	}
	new players[32], num;
	get_players(players, num, "ach");
	for (new i = 0; i < num; i++) {
		new id = players[i];
		if (cs_get_user_team(id) == CS_TEAM_CT) {
			cmd_show_main_menu(id);
		}
	}
}

public fwd_spawn(id) {
	if (is_user_alive(id)) {
		equip_weapons(id);
		update_hud(id);
		if (cs_get_user_team(id) == CS_TEAM_CT) {
			cmd_show_main_menu(id);
		}
	}
}

public event_death() {
	new attacker = read_data(1);
	new victim = read_data(2);
	new headshot = read_data(3);
	if (attacker == victim || !is_user_connected(attacker) || get_user_team(attacker) == get_user_team(victim) || g_IsZombie[attacker] || !g_IsZombie[victim]) {
		return;
	}
	new xp_gain = headshot ? XP_HEADSHOT : XP_KILL;
	if (g_Level[attacker] < MAX_LEVELS - 1) {
		g_XP[attacker] += xp_gain;
	}
	update_hud(attacker);
	check_level_up(attacker);
	show_exp_hud(attacker, xp_gain);
}

public show_exp_hud(id, exp) {
	set_hudmessage(0, 255, 0, -1.0, 0.55, 0, 6.0, 3.0, 0.1, 0.2, -1);
	show_hudmessage(id, "[+%d EXP]", exp);
}

public check_level_up(id) {
	new level = g_Level[id];
	new old_level = level;
	while (g_XP[id] >= (g_LevelXP[level + 1] - g_LevelXP[level]) && level < MAX_LEVELS - 1) {
		g_XP[id] -= (g_LevelXP[level + 1] - g_LevelXP[level]);
		level = ++g_Level[id];
		client_print(id, print_chat, "^x04---^x01 Awansowales na poziom^x04 %d ^x01poziom ^x04---", level);
	}
	if (g_XP[id] < 0) g_XP[id] = 0;
	if (level > old_level) {
		equip_weapons(id);
		level_up_effect(id);
		update_hud(id);
		if (g_Level[id] > old_level) {
			if (g_IsZombie[id]) {
				// Bonus dla zombie: +10% HP via native BB (jeśli dostępny)
				// bb_set_user_mult(id, ATT_HEALTH, 1.1); // Zakomentowane, jeśli nie chcesz
			}
		}
	}
	if (g_Level[id] >= MAX_LEVELS - 1) {
		g_XP[id] = 0;
	}
}

public get_weapon_unlock_level(level, index) {
	if (level < GOLD_LEVEL) {
		return index;
	}
	return GOLD_LEVEL + index;
}

public get_default_primary_index(level) {
	if (level < MIN_LONG_WEAPON_LEVEL) return -1;
	new num_primaries = MAX_WEAPONS - MIN_LONG_WEAPON_LEVEL;
	return ((level - MIN_LONG_WEAPON_LEVEL) % num_primaries) + MIN_LONG_WEAPON_LEVEL;
}

public equip_weapons(id) {
	if (!is_user_alive(id) || g_IsZombie[id] || (!bb_is_build_phase() && !bb_is_prep_phase())) {
		return; // Nie dawaj broni zombie lub poza fazą
	}
	strip_user_weapons(id);
	give_item(id, "weapon_knife");
	new level = g_Level[id];
	new gold = (level >= GOLD_LEVEL) ? 1 : 0;
	// Pistolet
	new pistol_index = (g_LastPistol[id] != -1 && level >= get_weapon_unlock_level(level, g_LastPistol[id])) ? g_LastPistol[id] : 0;
	new pistol_name[32];
	copy(pistol_name, 31, g_WeaponBoxNames[pistol_index]);
	new pistol_ent = give_item(id, pistol_name);
	if (pistol_ent) {
		cs_set_user_bpammo(id, g_WeaponIds[pistol_index], 200);
	}
	set_pev(id, pev_viewmodel2, g_VModels[pistol_index][gold]);
	set_pev(id, pev_weaponmodel2, g_PModels[pistol_index][gold]);
	// Broń główna
	new primary_index = (g_LastPrimary[id] != -1 && level >= get_weapon_unlock_level(level, g_LastPrimary[id])) ? g_LastPrimary[id] : get_default_primary_index(level);
	if (primary_index != -1 && level >= get_weapon_unlock_level(level, primary_index)) {
		new primary_name[32];
		copy(primary_name, 31, g_WeaponBoxNames[primary_index]);
		new primary_ent = give_item(id, primary_name);
		if (primary_ent) {
			cs_set_user_bpammo(id, g_WeaponIds[primary_index], 200);
		}
		client_cmd(id, primary_name); // Wybierz broń główną
		set_pev(id, pev_viewmodel2, g_VModels[primary_index][gold]);
		set_pev(id, pev_weaponmodel2, g_PModels[primary_index][gold]);
	}
}

public fwd_item_deploy(ent) {
	if (!pev_valid(ent)) return HAM_IGNORED;
	new id = pev(ent, pev_owner);
	if (!is_user_alive(id) || g_IsZombie[id]) return HAM_IGNORED;
	new csw = cs_get_weapon_id(ent);
	new index = -1;
	for (new i = 0; i < MAX_WEAPONS; i++) {
		if (g_WeaponIds[i] == csw) {
			index = i;
			break;
		}
	}
	if (index == -1) return HAM_IGNORED;
	new level = g_Level[id];
	new gold = (level >= GOLD_LEVEL) ? 1 : 0;
	set_pev(id, pev_viewmodel2, g_VModels[index][gold]);
	set_pev(id, pev_weaponmodel2, g_PModels[index][gold]);
	return HAM_IGNORED;
}

public cmd_show_levelup_menu(id) {
	if (!(get_user_flags(id) & ADMIN_FLAG)) {
		client_print(id, print_chat, "Nie masz dostepu do tej komendy!");
		return PLUGIN_HANDLED;
	}
	new menu = menu_create("Wybierz gracza do levelup", "levelup_player_handler");
	new players[32], num, player_name[32], info[8];
	get_players(players, num);
	for (new i = 0; i < num; i++) {
		new pid = players[i];
		get_user_name(pid, player_name, 31);
		num_to_str(pid, info, 7);
		menu_additem(menu, player_name, info);
	}
	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public levelup_player_handler(id, menu, item) {
	if (item == MENU_EXIT) {
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	new access, info[8];
	menu_item_getinfo(menu, item, access, info, 7);
	new target = str_to_num(info);
	client_print(id, print_chat, "Wpisz ilosc poziomow do dodania/odejmowania (np. 5 lub -3):");
	g_WaitingForAmount[id] = true;
	g_LevelupTarget[id] = target;
	menu_destroy(menu);
	return PLUGIN_CONTINUE;
}

public handle_levelup_amount(id) {
	if (!g_WaitingForAmount[id]) return PLUGIN_CONTINUE;
	new said[192];
	read_args(said, 191);
	remove_quotes(said);
	new amount = str_to_num(said);
	if (amount == 0) {
		client_print(id, print_chat, "Nieprawidlowa ilosc!");
		return PLUGIN_HANDLED;
	}
	new target = g_LevelupTarget[id];
	if (!target || !is_user_connected(target)) {
		client_print(id, print_chat, "Gracz nie jest podlaczony!");
		g_WaitingForAmount[id] = false;
		return PLUGIN_HANDLED;
	}
	new old_level = g_Level[target];
	g_Level[target] += amount;
	if (g_Level[target] < 0) g_Level[target] = 0;
	if (g_Level[target] > MAX_LEVELS - 1) g_Level[target] = MAX_LEVELS - 1;
	g_XP[target] = 0;
	if (g_Level[target] > old_level) level_up_effect(target);
	equip_weapons(target);
	update_hud(target);
	client_print(id, print_chat, "Zmieniono poziom graczowi %s o %d!", target_name(target), amount);
	g_WaitingForAmount[id] = false;
	return PLUGIN_HANDLED;
}

stock target_name(id) {
	new name[32];
	get_user_name(id, name, 31);
	return name;
}

public level_up_effect(id) {
	// Sound
	client_cmd(id, "spk umbrella/levelup.wav");
	// Sprite
	new Float:origin[3];
	pev(id, pev_origin, origin);
	origin[2] += 50.0;
	message_begin(MSG_ALL, SVC_TEMPENTITY);
	write_byte(TE_SPRITE);
	write_coord_f(origin[0]);
	write_coord_f(origin[1]);
	write_coord_f(origin[2]);
	write_short(g_SpriteLevelUp);
	write_byte(10); // scale
	write_byte(255); // brightness
	message_end();
}

public cmd_show_main_menu(id) {
	if (g_WeaponSelectCount[id] >= 2) {
		client_print(id, print_chat, "Nie mozesz wybrac broni wiecej niz 2 razy na runde!");
		return PLUGIN_HANDLED;
	}
	// Kompatybilność z BB: Tylko dla builderów (nie zombie) i w prep/build phase
	if (g_IsZombie[id] || (!bb_is_build_phase() && !bb_is_prep_phase())) {
		client_print(id, print_chat, "Menu broni dostepne tylko w fazie budowania lub przygotowania jako builder!");
		return PLUGIN_HANDLED;
	}
	g_WeaponSelectCount[id]++;
	new menu = menu_create("\dSystem GunXpMod by \rSkyDev^n\r[BaseBuilder]\y Menu Broni", "main_menu_handler");
	menu_additem(menu, "Wybierz Bron");
	menu_additem(menu, "Wybierz Ostatni zestaw");
	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public main_menu_handler(id, menu, item) {
	if (item == MENU_EXIT) {
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	switch(item) {
		case 0: show_pistols_menu(id);
		case 1: load_last_set(id);
	}
	menu_destroy(menu);
	return PLUGIN_CONTINUE;
}

public show_pistols_menu(id) {
	new level = g_Level[id];
	new gold = (level >= GOLD_LEVEL) ? 1 : 0;
	new menu = menu_create("Wybierz pistolet", "pistol_menu_handler");
	for (new i = 0; i <= 5; i++) {
		new unlock_level = get_weapon_unlock_level(level, i);
		new name[64];
		new info[8];
		num_to_str(i, info, 7);
		if (level >= unlock_level) {
			formatex(name, 63, "%s%s \y[Odblokowano]", gold ? "Gold " : "", g_DisplayNames[i]);
		} else {
			formatex(name, 63, "\r[Zablokowana – od %d lvl'a]", unlock_level);
		}
		menu_additem(menu, name, info);
	}
	menu_display(id, menu, 0);
}

public pistol_menu_handler(id, menu, item) {
	if (item == MENU_EXIT) {
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	new access, info[8];
	menu_item_getinfo(menu, item, access, info, 7);
	new pistol_index = str_to_num(info);
	new unlock_level = get_weapon_unlock_level(g_Level[id], pistol_index);
	if (g_Level[id] < unlock_level) {
		client_print(id, print_chat, "Nie masz dostepu do tej broni. Wybierz inna bron.");
		show_pistols_menu(id);
		return PLUGIN_CONTINUE;
	}
	g_LastPistol[id] = pistol_index;
	if (g_Level[id] < get_weapon_unlock_level(g_Level[id], MIN_LONG_WEAPON_LEVEL)) {
		equip_weapons(id);
		update_hud(id);
	} else {
		show_long_menu(id);
	}
	menu_destroy(menu);
	return PLUGIN_CONTINUE;
}

public show_long_menu(id) {
	new level = g_Level[id];
	new gold = (level >= GOLD_LEVEL) ? 1 : 0;
	new menu = menu_create("Wybierz bron dluga", "primary_menu_handler");
	for (new i = 6; i < MAX_WEAPONS; i++) {
		new unlock_level = get_weapon_unlock_level(level, i);
		new name[64];
		new info[8];
		num_to_str(i, info, 7);
		if (level >= unlock_level) {
			formatex(name, 63, "%s%s \y[Odblokowano]", gold ? "Gold " : "", g_DisplayNames[i]);
		} else {
			formatex(name, 63, "\r[Zablokowana – od %d lvl'a]", unlock_level);
		}
		menu_additem(menu, name, info);
	}
	menu_display(id, menu, 0);
}

public primary_menu_handler(id, menu, item) {
	if (item == MENU_EXIT) {
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	new access, info[8];
	menu_item_getinfo(menu, item, access, info, 7);
	new primary_index = str_to_num(info);
	new unlock_level = get_weapon_unlock_level(g_Level[id], primary_index);
	if (g_Level[id] < unlock_level) {
		client_print(id, print_chat, "Nie masz dostepu do tej broni. Wybierz inna bron.");
		show_long_menu(id);
		return PLUGIN_CONTINUE;
	}
	g_LastPrimary[id] = primary_index;
	equip_weapons(id);
	update_hud(id);
	menu_destroy(menu);
	return PLUGIN_CONTINUE;
}

public load_last_set(id) {
	if (g_LastPistol[id] == -1 || g_LastPrimary[id] == -1) {
		client_print(id, print_chat, "Nie wybrano jeszcze zadnego zestawu!");
		return;
	}
	new level = g_Level[id];
	new pistol_unlock = get_weapon_unlock_level(level, g_LastPistol[id]);
	new primary_unlock = get_weapon_unlock_level(level, g_LastPrimary[id]);
	if (level < pistol_unlock || level < primary_unlock) {
		client_print(id, print_chat, "Ostatni zestaw jest zablokowany na twoim poziomie!");
		return;
	}
	equip_weapons(id);
	update_hud(id);
}

public update_hud(id) {
	if (!is_user_connected(id)) return;
	new level = g_Level[id];
	new xp = g_XP[id];
	new next_xp = (level < MAX_LEVELS - 1) ? (g_LevelXP[level + 1] - g_LevelXP[level]) : 0;
	set_hudmessage(255, 255, 255, -1.0, 0.85, 0, 6.0, 999999.0, 0.1, 0.2, HUD_CHANNEL);
	if (level >= MAX_LEVELS - 1) {
		show_hudmessage(id, "Poziom: %d^nExp: Maksymalny", level);
	} else {
		show_hudmessage(id, "Poziom: %d^nExp: %d / %d", level, xp, next_xp);
	}
}

public load_data(id) {
	new authid[35];
	get_user_authid(id, authid, 34);
	new data[1];
	data[0] = id;
	new query[256];
	formatex(query, 255, "SELECT level, xp, last_pistol, last_primary FROM gunxpmod_players WHERE authid = '%s'", authid);
	SQL_ThreadQuery(g_SqlTuple, "LoadDataHandler", query, data, 1);
}

public LoadDataHandler(failstate, Handle:query, error[], errcode, data[], datasize, Float:queuetime) {
	new id = data[0];
	if (failstate) {
		log_amx("SQL Error: %s (%d)", error, errcode);
		return;
	}
	if (SQL_NumResults(query) > 0) {
		g_Level[id] = SQL_ReadResult(query, 0);
		g_XP[id] = SQL_ReadResult(query, 1);
		g_LastPistol[id] = SQL_ReadResult(query, 2);
		g_LastPrimary[id] = SQL_ReadResult(query, 3);
	} else {
		new authid[35], name[32];
		get_user_authid(id, authid, 34);
		get_user_name(id, name, 31);
		replace_all(name, 31, "'", "\'");
		new ins_query[256];
		formatex(ins_query, 255, "INSERT INTO gunxpmod_players (authid, name, level, xp, last_pistol, last_primary) VALUES ('%s', '%s', 0, 0, -1, -1)", authid, name);
		SQL_ThreadQuery(g_SqlTuple, "QueryHandlerIgnore", ins_query);
		g_Level[id] = 0;
		g_XP[id] = 0;
		g_LastPistol[id] = -1;
		g_LastPrimary[id] = -1;
	}
	SQL_FreeHandle(query);
	save_data(id); // Aktualizuj z nazwą jeśli potrzeba
}

public save_data(id) {
	new authid[35], name[32];
	get_user_authid(id, authid, 34);
	get_user_name(id, name, 31);
	replace_all(name, 31, "'", "\'");
	new query[256];
	formatex(query, 255, "REPLACE INTO gunxpmod_players (authid, name, level, xp, last_pistol, last_primary) VALUES ('%s', '%s', %d, %d, %d, %d)", authid, name, g_Level[id], g_XP[id], g_LastPistol[id], g_LastPrimary[id]);
	SQL_ThreadQuery(g_SqlTuple, "QueryHandlerIgnore", query);
}

public QueryHandlerIgnore(failstate, Handle:query, error[], errcode, data[], datasize, Float:queuetime) {
	if (failstate) {
		log_amx("SQL Error: %s (%d)", error, errcode);
	}
	SQL_FreeHandle(query);
}

public show_top(id) {
	new data[1];
	data[0] = id;
	new query[128] = "SELECT name, level, xp FROM gunxpmod_players ORDER BY level DESC, xp DESC LIMIT 10";
	SQL_ThreadQuery(g_SqlTuple, "TopHandler", query, data, 1);
}

public TopHandler(failstate, Handle:query, error[], errcode, data[], datasize, Float:queuetime) {
	new id = data[0];
	if (failstate) {
		log_amx("SQL Error: %s (%d)", error, errcode);
		client_print(id, print_chat, "Nie mozna pobrac rankingu.");
		SQL_FreeHandle(query);
		return;
	}
	new num_results = SQL_NumResults(query);
	if (num_results == 0) {
		client_print(id, print_chat, "Brak danych w rankingu.");
		SQL_FreeHandle(query);
		return;
	}
	new motd[2048], len = 0;
	new pink[] = "#ff69b4";
	len += formatex(motd[len], 2047 - len, "<head><link href=^"https://fonts.googleapis.com/css?family=Montserrat:100,200,300,400,500,600,700^" rel=^"stylesheet^"></head>");
	len += formatex(motd[len], 2047 - len, "<style>*{ font-size: 16px; font-family: Montserrat; color: %s; text-align: center; padding: 0; margin: 0;} body{border: 1px solid %s; background: #111} b{color:%s; text-shadow: 0 0 5px %s;}</style>", pink, pink, pink, pink);
	len += formatex(motd[len], 2047 - len, "<p>TOP 10 Graczy</p><hr size=1 color=%s>", pink);
	len += formatex(motd[len], 2047 - len, "<table style=^"margin-top: 20px;margin-left: auto;margin-right: auto;width:710px^">");
	len += formatex(motd[len], 2047 - len, "<tr><td><b>#</b></td><td><b>Nazwa</b></td><td><b>Poziom</b></td><td><b>Exp</b></td></tr>");
	new i = 1;
	while (SQL_MoreResults(query)) {
		new szName[32];
		SQL_ReadResult(query, 0, szName, 31);
		new level = SQL_ReadResult(query, 1);
		new xp = SQL_ReadResult(query, 2);
		// Sanitizacja znaków dla HTML
		replace_all(szName, 31, "&", "&amp;");
		replace_all(szName, 31, "<", "&lt;");
		replace_all(szName, 31, ">", "&gt;");
		replace_all(szName, 31, "%", "&#37;");
		len += formatex(motd[len], 2047 - len, "<tr><td>%d</td><td>%s</td><td>%d</td><td>%d</td></tr>", i, szName, level, xp);
		SQL_NextRow(query);
		i++;
	}
	len += formatex(motd[len], 2047 - len, "</table>");
	show_motd(id, motd, "Top XP");
	SQL_FreeHandle(query);
}

public plugin_end() {
	SQL_FreeHandle(g_SqlTuple);
}

public fwd_SayText(msgid, msg_dest, receiver) {
	new id = get_msg_arg_int(1);
	if (id > 0 && id <= MaxClients && is_user_connected(id)) {
		new message[192];
		get_msg_arg_string(2, message, 191);
		if (contain(message, "#Cstrike_Chat") != -1) {
			set_msg_arg_string(2, fmt("^4[Lvl: %d]^3 %s", g_Level[id], message));
		}
	}
	return PLUGIN_CONTINUE;
}

public fwd_PlayerPreThink_Post(id) {
	if (is_user_alive(id)) {
		g_IsZombie[id] = bb_is_user_zombie(id) ? true : false;
	}
}