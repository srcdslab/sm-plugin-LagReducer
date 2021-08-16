#if defined _LagReducer_included
 #endinput
#endif
#define _LagReducer_included

/**
 * Called at the start of every game frame
 */
forward void LagReducer_OnStartGameFrame();

/**
 * Called every game frame according to the current server performances
 *
 * @param client		Client index.
 */
forward void LagReducer_OnClientGameFrame(int client);

/**
 * Called at the end of every game frame
 */
forward void LagReducer_OnEndGameFrame();


public SharedPlugin __pl_LagReducer= 
{
	name = "LagReducer",
	file = "LagReducer.smx",
#if defined REQUIRE_PLUGIN
	required = 1
#else
	required = 0
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_LagReducer_SetNTVOptional()
{
	// MarkNativeAsOptional("LagReducer_OnClientGameFrame");
}
#endif
