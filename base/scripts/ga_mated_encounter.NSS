//	ga_mated_encounter
/*
    Transitions the party to the encounter map and destroys the overland version
	of the creature.
*/
// JH/EF-OEI: 01/16/08
// NLC: 03/08 - Updated to use new Dialog Skills and to add Parameters for Forcing groups hostile.

#include "ginc_overland"
#include "ginc_group"

void main(int nDialogSkill, int nSkillDC)
{
	object oPC = GetFactionLeader(GetFirstPC());
	object oCombatant1 = GetLocalObject(OBJECT_SELF, "oCombatant1");
	object oCombatant2 = GetLocalObject(OBJECT_SELF, "oCombatant2");
	
	int nTerrain		= GetCurrentPCTerrain();
	int nSkillRanks	= GetSkillRank(nDialogSkill, oPC);
	int nSkillMargin = nSkillRanks - nSkillDC;
	int nRand			= Random(GetNumTerrainMaps(nTerrain)) + 1;
	
	string sPrefix		= GetTerrainWPPrefix(nTerrain);

	if(nRand < 10)
	{
		sPrefix += "0";
	}			
	string sPartyWP, sEnemyWP;
	
	sPrefix += IntToString(nRand);
		
	sPartyWP += sPrefix;
	sEnemyWP += sPrefix;
	sPartyWP += GetEncounterWPSuffix();
	sEnemyWP += GetEncounterWPSuffix(TRUE);
	
	object oPartyWP = GetObjectByTag(sPartyWP);
	object oEnemyWP = GetObjectByTag(sEnemyWP);
	
	//Failsafe - if the waypoint is invalid you'll now go to plains.
	if(GetIsObjectValid(oPartyWP) == FALSE || GetIsObjectValid(oEnemyWP) == FALSE )
	{
		PrettyDebug("The Party and/or Enemy Destination waypoints are invalid! Rerouting to plains01. This is a bug.", PRETTY_DURATION, POST_COLOR_ERROR);
		oPartyWP = GetObjectByTag(WP_PARTY_FAILSAFE);
		oEnemyWP = GetObjectByTag(WP_ENEMY_FAILSAFE);
	}
	
	RemoveAllEffects(oPC,FALSE);
	
	StorePlayerMapLocation(oPC);
	object oEncArea = GetArea(oPartyWP);
	SetLocalObject(oEncArea, "oCombatant2", oCombatant2);
	SetLocalInt(oEncArea, "nEncounterEL", FloatToInt(GetChallengeRating(oCombatant1)));
	SetLocalInt(oEncArea, "bMated", TRUE);
	JumpPartyToArea(oPC, oPartyWP);
	AssignCommand(oCombatant1, SpawnEncounterCreatures(oEnemyWP, nDialogSkill, nSkillMargin));
	AssignCommand(oCombatant1, SpawnEncounterCreatures(oEnemyWP, nDialogSkill, nSkillMargin));
	
	AssignCommand(oCombatant2, SpawnEncounterCreatures(oEnemyWP, nDialogSkill, nSkillMargin, FALSE, FALSE, 
															FALSE, FALSE, FALSE, "COMBATANT_2"));
	/*	Removes the overland map version of the creature.	*/
	if (GetIsObjectValid(OBJECT_SELF))
	{
		DestroyObject(OBJECT_SELF, 0.2f);
		DestroyObject(oCombatant1, 0.2f);
	}
}