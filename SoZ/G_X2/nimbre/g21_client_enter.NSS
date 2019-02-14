//	g21_client_enter
/*
	On Client Enter for G21 Loremaster's House.
*/
//	JSH-OEI 4/15/08

#include "ginc_misc"
#include "ginc_group"


void SpawnHaldric(string sResRef)
{
	string sWPTag = "sp_" + sResRef;
	object oWP = GetObjectByTag(sWPTag);
	int i = 0;
	
	while(GetIsObjectValid(oWP))
	{
		PrettyDebug ("Spawning in " + sResRef);
		if(GetObjectType(oWP) == OBJECT_TYPE_WAYPOINT 
			&& GetArea(oWP) == OBJECT_SELF
			&& !IsMarkedAsDone(oWP))
		{
			location lLoc = GetLocation(oWP);
			object oCreature = CreateObject(OBJECT_TYPE_CREATURE, sResRef, lLoc);
			GroupAddMember("Haldric", oCreature);
			MarkAsDone(oWP);
			//create "Blood-Spattered Scroll" on Haldric
			DelayCommand(0.1f, VoidCreateItemOnObject("g_yuanti_scroll", oCreature));
		}
		
		i++;		
		oWP = GetObjectByTag(sWPTag, i);
	}	
}


void SpawnCultist(string sResRef)
{
	string sWPTag = "sp_" + sResRef;
	object oWP = GetObjectByTag(sWPTag);
	int i = 0;
	
	while(GetIsObjectValid(oWP))
	{
		PrettyDebug ("Spawning in " + sResRef);
		if(GetObjectType(oWP) == OBJECT_TYPE_WAYPOINT 
			&& GetArea(oWP) == OBJECT_SELF
			&& !IsMarkedAsDone(oWP))
		{
			location lLoc = GetLocation(oWP);
			object oCreature = CreateObject(OBJECT_TYPE_CREATURE, sResRef, lLoc);
			GroupAddMember("Haldric", oCreature);
			MarkAsDone(oWP);
			SetScriptHidden(oCreature, TRUE);
		}
		
		i++;		
		oWP = GetObjectByTag(sWPTag, i);
	}
}


void CreateLoot(object oPC)
{
	object oChest 		= GetNearestObjectByTag("g21_loremaster_chest", oPC);
	object oBookcase	= GetNearestObjectByTag("g21_bookcase", oPC);

	//potion of antidote, drum of haunting, raise dead scroll, emerald//
	CreateItemOnObject("nw_it_mpotion006", oChest);
	CreateItemOnObject("nw_it_mmidmisc02", oChest);
	CreateItemOnObject("nw_it_gem012", oChest);
	
	CreateItemOnObject("nw_it_spdvscr501", oBookcase);
	CreateItemOnObject("nx1_it_sparscr029", oBookcase);
	CreateItemOnObject("NW_IT_SPARSCR401", oBookcase);
	
}

void main()
{
	object oPC			= GetFirstEnteringPC();
	
	SpawnHaldric("g21_haldric");
	
	SpawnCultist("g21_cultist_1");
	SpawnCultist("g21_cultist_2");
	
	if (!IsMarkedAsDone())
	{
		CreateLoot(oPC);
		MarkAsDone();
	}
}
