#include <sourcemod>
#include <sdktools>
#include <tf2jail>
#include <tf2_stocks>

public Plugin myinfo = 
{
	name = "BLUCrits", 
	author = "x3Karma", 
	description = "Grant critcals to BLU players correctly.", 
	version = "1.0", 
	url = "https://titan.tf"
};

public void OnPluginStart()
{
	HookEvent("teamplay_round_start", Event_RoundStart);
}

public Action Event_RoundStart(Handle hEvent, const char[] sName, bool bDontBroadcast)
{
	CreateTimer(0.2, ClientTimer, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public Action ClientTimer(Handle timer)
{
	new String:wepclassname[32];
	if (TF2Jail_WardenActive()) {
		for (new client = 1; client <= MaxClients; client++)
		{
			new weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			if (weapon <= MaxClients || !IsValidEntity(weapon) || !GetEntityClassname(weapon, wepclassname, sizeof(wepclassname)))strcopy(wepclassname, sizeof(wepclassname), "");
			new bool:validwep = (strncmp(wepclassname, "tf_wea", 6, false) == 0);			new index = (validwep ? GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex") : -1);

			new TFCond:cond = TFCond_HalloweenCritCandy;
			new bool:addthecrit = false;
			new bool:addminicrit = false;
			if (GetClientTeam(client) == view_as<int>(TFTeam_Blue)) {
				if (validwep && weapon == GetPlayerWeaponSlot(client, TFWeaponSlot_Melee))
				{
					addthecrit = true;
				} else {
					addminicrit = true;
					cond = TFCond_Buffed;
				}
			}
			if (addthecrit) {
				TF2_AddCondition(client, cond, 0.3);
				if (addminicrit && cond != TFCond_Buffed)TF2_AddCondition(client, TFCond_Buffed, 0.3);
			}
		}
	}
	return Plugin_Continue;
}
