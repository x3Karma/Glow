#include <sourcemod>
#include <sdktools>
#include <tf2jail>
#include <tf2_stocks>

public Plugin myinfo = 
{
	name = "BLUCrits", 
	author = "x3Karma", 
	description = "Grant critcals to BLU players correctly.", 
	version = "1.1", 
	url = "https://titan.tf"
};

new BlueTeam = 3;
new Handle:g_CTimer;

public void OnPluginStart()
{
	HookEvent("teamplay_round_start", Event_RoundStart);
	RegAdminCmd("critzreload", Command_Reload, ADMFLAG_SLAY, "Reload crits for Guards.");
}

public Action Event_RoundStart(Handle hEvent, const char[] sName, bool bDontBroadcast)
{
	g_CTimer = CreateTimer(0.2, ClientTimer, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

stock ClearTimer(&Handle:hTimer)
{
    if (hTimer != INVALID_HANDLE)
    {
        KillTimer(hTimer);
        hTimer = INVALID_HANDLE;
    }
}

public Action Command_Reload(int client, int args)
{
	ClearTimer(g_CTimer);
	g_CTimer = CreateTimer(0.2, ClientTimer, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	
	PrintToChat(client, "[SM] Crits reloaded.");
	return Plugin_Handled;
}

public Action ClientTimer(Handle timer)
{
	new String:wepclassname[32];
	if (TF2Jail_WardenActive()) {
		for (new client = 1; client <= MaxClients; client++)
		{
			new weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			if (weapon <= MaxClients || !IsValidEntity(weapon) || !GetEntityClassname(weapon, wepclassname, sizeof(wepclassname)))
				strcopy(wepclassname, sizeof(wepclassname), "");
			new bool:validwep = (strncmp(wepclassname, "tf_wea", 6, false) == 0);
			new TFCond:cond = TFCond_HalloweenCritCandy;
			new bool:addthecrit = false;
			if (GetEntityTeamNum(client) == BlueTeam) {
				if (validwep && weapon == GetPlayerWeaponSlot(client, TFWeaponSlot_Melee))
				{
					addthecrit = true;
				}
				if (validwep && weapon == GetPlayerWeaponSlot(client, TFWeaponSlot_Primary)) {
					addthecrit = true;
					cond = TFCond_Buffed;
				}
				if (validwep && weapon == GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary)) {
					addthecrit = true;
					cond = TFCond_Buffed;
				}
			}
			if (addthecrit) {
				TF2_AddCondition(client, cond, 0.3);
			}
		}
	}
	return Plugin_Continue;
}

stock GetEntityTeamNum(iEnt)
{
    return GetEntProp(iEnt, Prop_Send, "m_iTeamNum");
}
