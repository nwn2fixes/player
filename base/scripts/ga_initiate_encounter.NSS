//	ga_initiate_encounter
/*
    Transitions the party to the encounter map and destroys the overland version
	of the creature.
*/
// JH/EF-OEI: 01/16/08
// NLC: 03/08 - Updated to use new Dialog Skills and to add Parameters for Forcing groups hostile.
// NLC 10/10/08 - Finalized Rest System.
// kevL's 2019.02.14 - merge this with the SoZ Campaign 'ga_initiate_encounter' so it's suitable for /Override.

#include "ginc_overland"
#include "ginc_restsys"

void main(int nDialogSkill, int nSkillDC, int bGroup1ForceHostile, int bGroup2ForceHostile,
			int bGroup3ForceHostile, int bGroup4ForceHostile, int bGroup5ForceHostile)
{
	object oPC = GetFactionLeader(GetFirstPC());

	if (GetIsSoZ())
	{
		object oArea = GetArea(oPC);
		ModifyLocalInt(oArea, VAR_WM_ENC_CUM_TOTAL, -20);
	}

	InitiateEncounter(nDialogSkill, nSkillDC, bGroup1ForceHostile, bGroup2ForceHostile, bGroup3ForceHostile, bGroup4ForceHostile, bGroup5ForceHostile, oPC);
	
	/*	Removes the overland map version of the creature.	*/
	if (GetIsObjectValid(OBJECT_SELF))
	{
		DestroyObject(OBJECT_SELF, 0.2f);
	}
}