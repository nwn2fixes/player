// i_mortar_ac
/*
	when the mortar and pestle is used on an item, new items may be distilled!
	is used on an item, new items may be distilled!
*/
// ChazM 1/31/06
// ChazM 3/23/06 added fairy dust and shadow reaver bones special cases
// ChazM 3/28/06 Crafting call interface change
// ChazM 6/7/06 fix - assigned DoAlchemyCrafting() to workbench
// ChazM 8/8/06 added ERROR_UNRECOGNIZED_MORTAR_USAGE, added additional tags and local var setting for alchemy bench.
// ChazM 8/16/06 moved stuff to ginc_crafting
// ChazM 9/10/06 fix - was comparing tag of mortat instead of target

#include "ginc_crafting"
	


const string FIRE 	= "cft_ess_fire";
const string WATER 	= "cft_ess_water";
const string AIR 	= "cft_ess_air";
const string EARTH 	= "cft_ess_earth";
const string POWER	= "cft_ess_power";
const string POWER3	= "cft_ess_power3";

const string FAIRY_DUST				= "NW_IT_MSMLMISC19";
const string SHADOW_REAVER_BONES	= "N2_CRFT_DIST028";



// Fairy Dust should always yield one Essence of random type (Power, Air, Earth, Fire, or Water) and power level (1-4).
void DistillFairyDust(object oDistilledItem, object oPC)
{
	string sRandomEssence;
 	int nType = Random(5)+1;	// 1-5
	int nPower = Random(4)+1;	// 1-4

	switch(nType)
	{
		case 1:
		     sRandomEssence = FIRE;
		     break;
		case 2:
		     sRandomEssence = WATER;
		     break;
		case 3:
		     sRandomEssence = AIR;
		     break;
		case 4:
		     sRandomEssence = EARTH;
		     break;
		case 5:
		     sRandomEssence = POWER;
		     break;
	}

	sRandomEssence += IntToString(nPower);
	string sOutputList = MakeList(sRandomEssence);
	ExecuteDistillation(8, oDistilledItem, oPC, sOutputList);

}
	
// Shadow Reaver Bones should always yield one Glowing (Level 3) Power Essence 
// AND one random elemental (Air, Earth, Fire, or Water) Essence of either level 3 or 4 (random). 
void DistillShadowReaverBones(object oDistilledItem, object oPC)
{
	//PrettyDebug("DistillShadowReaverBones()");
	string sRandomEssence;
 	int nType = Random(4)+1;	// 1-4
	int nPower = Random(2)+3;	// 3-4

	switch(nType)
	{
		case 1:
		     sRandomEssence = FIRE;
		     break;
		case 2:
		     sRandomEssence = WATER;
		     break;
		case 3:
		     sRandomEssence = AIR;
		     break;
		case 4:
		     sRandomEssence = EARTH;
		     break;
	}

	sRandomEssence += IntToString(nPower);
	string sOutputList = MakeList(POWER3, sRandomEssence);
	ExecuteDistillation(8, oDistilledItem, oPC, sOutputList);
}


void main()
{
	PrettyDebug("i_mortar_ac : started");
    // * This code runs when the Unique Power property of the item is used
    object oPC      = GetItemActivator();
    object oItem    = GetItemActivated();
    object oTarget  = GetItemActivatedTarget();
    location lTarget = GetItemActivatedTargetLocation();
    string sTargetTag  = GetTag(oTarget);
/*	
	PrettyDebug("oPC = " + GetName(oPC));
	PrettyDebug("oItem = " + GetName(oItem));
	PrettyDebug("oTarget = " + GetName(oTarget));
	
	PrettyDebug("sTargetTag = " + sTargetTag);
	PrettyDebug("SHADOW_REAVER_BONES = " + SHADOW_REAVER_BONES);
*/	
	int iObjType = GetObjectType(oTarget);

	//PrettyDebug("iObjType = " + IntToString(iObjType));

	if (IsAlchemyWorkbench(oTarget))
	{
		// must be run on the workbench with pc as param
    	AssignCommand(oTarget, DoAlchemyCrafting(oPC));

	}
	else if (iObjType == OBJECT_TYPE_ITEM)
	{
		if (sTargetTag == FAIRY_DUST)
			DistillFairyDust(oTarget, oPC);
		else if (sTargetTag == SHADOW_REAVER_BONES)
			DistillShadowReaverBones(oTarget, oPC);
		else
			DoDistillation(oTarget, oPC);
	}
	else // some other object type
	{
		ErrorNotify(oPC, ERROR_UNRECOGNIZED_MORTAR_USAGE);
	}
	PrettyDebug("i_mortar_ac : completed");
}		