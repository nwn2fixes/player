// s04_tr_respawn_army
/*
	Description: Respawns undead army as they march out of Gothaldreum
	
*/
// BN - OEI 11/18/08 - Fixed respawn bug

#include "ginc_debug"

void SpawnArmy(string sTag, string sTemplate = "", int nInstance = 0)
{
	object oWP = GetObjectByTag("sp_" + sTag, nInstance);

	{
		if (!GetIsObjectValid(oWP) )
			PrettyDebug("kinc_spawn: ERROR - waypoint sp_" + sTag + " is NOT valid");
		
		location lLoc = GetLocation(oWP);
		
		object oSpawn;
		
		if ( sTemplate == "" )
			oSpawn = CreateObject(OBJECT_TYPE_CREATURE, sTag, lLoc);
		else
			oSpawn = CreateObject(OBJECT_TYPE_CREATURE, sTemplate, lLoc, FALSE, sTag);
			
		
		PrettyDebug("kinc_spawn: Spawned " + GetName(oSpawn) + " (" + sTag + ")");
	}
}

void main()
{
	object oCreature = GetEnteringObject();
	string sCreatureTag = GetTag(oCreature);
	int bLuskansGone = GetGlobalInt("S_bLuskansGone");
	
	if ( GetIsPC(oCreature) )
		return;
		
	if ( GetIsOwnedByPlayer (oCreature) )
		return;
			
	DestroyObject(oCreature);
	PrettyDebug("Destroying Skeleton");
	if (!bLuskansGone)
	{
		SpawnArmy(sCreatureTag);
		PrettyDebug("Spawning New Skeleton");	
	}
}