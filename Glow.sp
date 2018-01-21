#define PLUGIN_AUTHOR "x3Karma"
#define PLUGIN_VERSION "1.0"

#include <sourcemod>
#include <sdktools>
#include <tf2_stocks>

public Plugin myinfo = 
{
	name = "Glow", 
	author = PLUGIN_AUTHOR, 
	description = "Make players glow.", 
	version = PLUGIN_VERSION, 
	url = "https://titan.tf"
};

int PlayerGlowed[MAXPLAYERS + 1];

public void OnPluginStart()
{
	RegAdminCmd("sm_glow", Command_Glow, ADMFLAG_SLAY, "[SM] /glow <target>");
	
	HookEvent("teamplay_round_start", Event_RoundStart);
}

public Action Event_RoundStart(Handle hEvent, const char[] sName, bool bDontBroadcast)
{
	for (new client = 1; client <= MaxClients; client++)
	PlayerGlowed[client] = -1;
}

public Action Command_Glow(int client, args)
{
	if (args == 1)
	{
		new String:arg[MAX_NAME_LENGTH];
		GetCmdArg(1, arg, sizeof(arg));
		if (StrEqual(arg, "@red"))
		{
			Make_GlowRed(client);
			return Plugin_Handled;
		} else if (StrEqual(arg, "@blue"))
		{
			Make_GlowBlue(client);
			return Plugin_Handled;
		} else if (StrEqual(arg, "@all"))
		{
			Make_GlowAll(client);
			return Plugin_Handled;
		}
		new target = FindTarget(client, arg);
		new bool:adyGlow = false;
		if (!CanUserTarget(client, target))
		{
			PrintToChat(client, "[SM] You cannot target this player.");
			return Plugin_Handled;
		}
		if (target == PlayerGlowed[target])
				adyGlow = true;
		Make_Glow(target, adyGlow, client);
	}
	return Plugin_Handled;
}

public void Make_Glow(client, bool glowed, request)
{
	if (IsPlayerAlive(client)) {
		if (!glowed) {
			PlayerGlowed[client] = client;
			SetEntProp(client, Prop_Send, "m_bGlowEnabled", 1);
		} else {
			PlayerGlowed[client] = -1;
			SetEntProp(client, Prop_Send, "m_bGlowEnabled", 0);
		}
	} else {
		PrintToChat(request, "[SM] This command only works on alive players.");
	}
}

public void Make_GlowRed(request)
{
	new bool:glowed = false;
	for (new client = 1; client <= MaxClients; client++)
	{
		if (IsPlayerAlive(client) && GetClientTeam(client) == view_as<int>(TFTeam_Red))
		{
			if (!CanUserTarget(request, client))
				continue;
			if (client == PlayerGlowed[client])
				glowed = true;
			if (!glowed) {
				SetEntProp(client, Prop_Send, "m_bGlowEnabled", 1);
				PlayerGlowed[client] = client;
			} else {
				SetEntProp(client, Prop_Send, "m_bGlowEnabled", 0);
				PlayerGlowed[client] = -1;
			}
		}
	}
}

public void Make_GlowBlue(request)
{
	new bool:glowed = false;
	for (new client = 1; client <= MaxClients; client++)
	{
		if (IsPlayerAlive(client) && GetClientTeam(client) == view_as<int>(TFTeam_Blue))
		{
			if (!CanUserTarget(request, client))
				continue;
			if (client == PlayerGlowed[client])
				glowed = true;
			if (!glowed) {
				SetEntProp(client, Prop_Send, "m_bGlowEnabled", 1);
				PlayerGlowed[client] = client;
			} else {
				SetEntProp(client, Prop_Send, "m_bGlowEnabled", 0);
				PlayerGlowed[client] = -1;
			}
		}
	}
}

public void Make_GlowAll(request)
{
	new bool:glowed = false;
	for (new client = 1; client <= MaxClients; client++)
	{
		if (IsPlayerAlive(client))
		{
			if (!CanUserTarget(request, client))
				continue;
			if (client == PlayerGlowed[client])
				glowed = true;
			if (!glowed) {
				SetEntProp(client, Prop_Send, "m_bGlowEnabled", 1);
				PlayerGlowed[client] = client;
			} else {
				SetEntProp(client, Prop_Send, "m_bGlowEnabled", 0);
				PlayerGlowed[client] = -1;
			}
		}
	}
} 