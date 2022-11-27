#include <sourcemod>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name         = "Lag Reducer",
	author       = "maxime1907",
	description  = "Adds control over sourcemod callbacks to prevent lags",
	version      = "1.0.0"
};

GlobalForward g_gf_OnClientGameFrame;
GlobalForward g_gf_OnStartGameFrame;
GlobalForward g_gf_OnEndGameFrame;

ConVar g_cv_ProcessRate;

bool g_bEnabled = true;

int g_iProcessRate = 0;
int g_iFrameCount = 1;
int g_iClientCount = 1;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    RegPluginLibrary("LagReducer");

    g_gf_OnStartGameFrame = CreateGlobalForward("LagReducer_OnStartGameFrame", ET_Ignore);
    g_gf_OnClientGameFrame = CreateGlobalForward("LagReducer_OnClientGameFrame", ET_Ignore, Param_Cell);
    g_gf_OnEndGameFrame = CreateGlobalForward("LagReducer_OnEndGameFrame", ET_Ignore);

    return APLRes_Success;
}

public void OnPluginStart()
{
	g_cv_ProcessRate = CreateConVar("sm_lagreducer_process_rate", "10", "Determines the number of players processed per frame.", 0, true, 0.0, true, 255.0);
	g_cv_ProcessRate.AddChangeHook(OnCvarChanged);

	HookEvent("round_end", OnRoundEnd);

	AddCommandListener(Command_ChangeMap, "sm_map");

	AutoExecConfig(true);
}

public void OnCvarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	g_iProcessRate = g_cv_ProcessRate.IntValue;
}

public void OnConfigsExecuted()
{
	g_iProcessRate = g_cv_ProcessRate.IntValue;
}

public void OnPluginEnd()
{
	g_bEnabled = false;
	UnhookEvent("round_end", OnRoundEnd);
}

public void OnMapStart()
{
	g_bEnabled = true;
}

public void OnMapEnd()
{
	g_bEnabled = false;
}

public void OnRoundEnd(Event hEvent, const char[] sEvent, bool bDontBroadcast)
{
	int timeleft;
	GetMapTimeLeft(timeleft);
	if (timeleft <= 0)
	{
		g_bEnabled = false;
	}
}

stock Action Command_ChangeMap(int client, const char[] command, int argc)
{
	g_bEnabled = false;
	return Plugin_Continue;
}

public void OnGameFrame()
{
	if (!g_bEnabled)
		return;

	CreateForward_OnStartGameFrame();

	int iMaxClientsPerFrame = GetMaxClientsPerFrame();
	int iMaxClientsAtFrame = g_iClientCount + iMaxClientsPerFrame;

	if (iMaxClientsAtFrame > MaxClients)
		iMaxClientsAtFrame = MaxClients + 1;

	while (g_iClientCount < iMaxClientsAtFrame)
	{
		CreateForward_OnClientGameFrame(g_iClientCount);
		g_iClientCount++;
	}

	if (g_iClientCount > MaxClients)
	{
		g_iClientCount = 1;
	}

	// TODO: Adapt to current tickrate
	float fTickrate = GetTickRate();
	g_iFrameCount++;
	if (g_iFrameCount > RoundToZero(fTickrate))
		g_iFrameCount = 1;

	CreateForward_OnEndGameFrame();
}

stock float GetTickRate()
{
    return 1.0 / GetTickInterval();
}

stock int GetMaxClientsPerFrame()
{
    return g_iProcessRate;
}

stock void CreateForward_OnClientGameFrame(int iClient)
{
	Call_StartForward(g_gf_OnClientGameFrame);
	Call_PushCell(iClient);
	Call_Finish();
}

stock void CreateForward_OnStartGameFrame()
{
	Call_StartForward(g_gf_OnStartGameFrame);
	Call_Finish();
}

stock void CreateForward_OnEndGameFrame()
{
	Call_StartForward(g_gf_OnEndGameFrame);
	Call_Finish();
}