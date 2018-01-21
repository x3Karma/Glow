#define PLUGIN_AUTHOR "x3Karma"
#define PLUGIN_VERSION "1.0"

#include <sourcemod>
#include <sdktools>
#include <tf2_stocks>
#include <adminmenu>

public Plugin myinfo = 
{
	name = "Glow", 
	author = PLUGIN_AUTHOR, 
	description = "Make players glow.", 
	version = PLUGIN_VERSION, 
	url = "https://titan.tf"
};

int PlayerGlowed[MAXPLAYERS + 1];
new Handle:g_hAdminMenu;

public void OnPluginStart()
{
	RegAdminCmd("sm_glow", Command_Glow, ADMFLAG_SLAY, "[SM] /glow <target>");
	
	HookEvent("teamplay_round_start", Event_RoundStart);
	HookEvent("player_death", Event_PlayerDeath);
	
	new Handle:topmenu;
	if (LibraryExists("adminmenu") && ((topmenu = GetAdminTopMenu()) != INVALID_HANDLE))
	{
		OnAdminMenuReady(topmenu);
		AttachAdminMenu();
	}
}

public Action Event_RoundStart(Handle hEvent, const char[] sName, bool bDontBroadcast)
{
	for (new client = 1; client <= MaxClients; client++)
	PlayerGlowed[client] = -1;
}

public Action Event_PlayerDeath(Handle hEvent, const char[] sName, bool bDontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	if (client == PlayerGlowed[client])
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

public OnLibraryRemoved(const String:name[])
{
	if (StrEqual(name, "adminmenu"))
	{
		g_hAdminMenu = INVALID_HANDLE;
	}
}

public OnAdminMenuReady(Handle:topmenu)
{
	/* Block us from being called twice */
	if (topmenu == g_hAdminMenu)
	{
		return;
	}
	g_hAdminMenu = topmenu;
	AttachAdminMenu();
}

AttachAdminMenu()
{
	/* If the category is third party, it will have its own unique name. */
	new TopMenuObject:player_commands = FindTopMenuCategory(g_hAdminMenu, ADMINMENU_PLAYERCOMMANDS);
	
	if (player_commands == INVALID_TOPMENUOBJECT)
	{
		/* Error! */
		return;
	}
	
	AddToTopMenu(g_hAdminMenu, 
		"sm_glow", 
		TopMenuObject_Item, 
		AdminMenu_Glow, 
		player_commands, 
		"sm_glow", 
		ADMFLAG_SLAY);
}

public AdminMenu_Glow(Handle:topmenu, 
	TopMenuAction:action, 
	TopMenuObject:object_id, 
	param, 
	String:buffer[], 
	maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "Glow");
	}
	else if (action == TopMenuAction_SelectOption)
	{
		DisplayGlowMenu(param);
	}
}

DisplayGlowMenu(client)
{
	new Handle:hMenu = CreateMenu(MenuHandler_Glow);
	
	SetMenuTitle(hMenu, "Glow player");
	SetMenuExitBackButton(hMenu, true);
	
	AddTargetsToMenu(hMenu, client);
	
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}

public MenuHandler_Glow(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && g_hAdminMenu != INVALID_HANDLE)
		{
			DisplayTopMenu(g_hAdminMenu, param1, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		decl String:info[32];
		new userid, target;
		new bool:glowed = false;
		GetMenuItem(menu, param2, info, sizeof(info));
		userid = StringToInt(info);
		
		if ((target = GetClientOfUserId(userid)) == 0)
		{
			PrintToChat(param1, "[SM] %t", "Player is no longer available.");
		}
		else if (!CanUserTarget(param1, target))
		{
			PrintToChat(param1, "[SM] %t", "Unable to target this player.");
		}
		else
		{
			if (target == PlayerGlowed[target])
				glowed = true;
			Make_Glow(target, glowed, param1);
		}
	}
} 