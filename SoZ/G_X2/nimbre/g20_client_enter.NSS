//	g20_client_enter
/*
	On Client Enter script for G20 Nimbre.
*/
//	JSH-OEI 4/11/08
//	Bobby Null-OEI 7/24/08 Added store appending function.

#include "ginc_group"
#include "kinc_collectors"

void SpawnAnimals(string sResRef)
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
			GroupAddMember("G20 Boars", oCreature);
			MarkAsDone(oWP);
		}
		
		i++;		
		oWP = GetObjectByTag(sWPTag, i);
	}
}

void SpawnVillagers(string sResRef)
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
			GroupAddMember("G20 Villagers", oCreature);
			MarkAsDone(oWP);
		}
		
		i++;		
		oWP = GetObjectByTag(sWPTag, i);
	}
}

void SpawnNPC(string sResRef)
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
			MarkAsDone(oWP);
		}
		
		i++;		
		oWP = GetObjectByTag(sWPTag, i);
	}
}

void SpawnSoldiers(string sResRef)
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
			GroupAddMember("Nimbre Soldiers", oCreature);
			MarkAsDone(oWP);
		}
		
		i++;		
		oWP = GetObjectByTag(sWPTag, i);
	}
}

void SpawnStores(string sResRef)
{
	string sWPTag = "sp_" + sResRef;
	string sTargetTag1 = ("g20_store_nimbre");
	string sResRef1 = ("00_campaign_store_general_low");
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
			object oStore = CreateObject(OBJECT_TYPE_STORE, sResRef, lLoc);
			object oStore1 = GetObjectByTag(sTargetTag1);
			AppendStore(oStore1, sResRef1);
			MarkAsDone(oWP);
		}
		
		i++;		
		oWP = GetObjectByTag(sWPTag, i);
	}
}

void HSTSpawnFredegar ()
{
	object oDirtMound = GetObjectByTag("g20_wp_mound");
	if (GetLocalInt(oDirtMound, "HST_DONE"))
		return;
	
	// spawn dirt mound
	location lDirtMound = GetLocation(oDirtMound);
	CreateObject(OBJECT_TYPE_PLACEABLE, "hst_g20_dirtmound", lDirtMound);
	
	// spawn Fredegar somewhat close to dirt mound
	location lNew = GetNearbyLocation(lDirtMound, 2.0f, 0.0f, 1.0f);
	object oPig = CreateObject(OBJECT_TYPE_CREATURE, "g20_pig", lNew);	
	GroupAddMember("G20 Boars", oPig);
	
	SetOrientOnDialog(oPig, FALSE);
	AssignCommand(oPig, SetFacingPoint(GetPosition(oDirtMound), TRUE));
	SetBumpState(oPig, BUMPSTATE_UNBUMPABLE);
	ExecuteScript("HST_fredegar_anim", oPig);
	
	SetLocalInt(oDirtMound, "HST_DONE", 1);
}

void main()
{
	object oPC		= GetFirstEnteringPC();
	object oMound	= GetNearestObjectByTag("g20_dirt_mound", oPC);

	SpawnSoldiers("g20_soldier_1");
	SpawnSoldiers("g20_soldier_2");
	SpawnSoldiers("g20_soldier_3");
	SpawnSoldiers("g20_wizard");
	SpawnSoldiers("g20_cleric");
	SpawnSoldiers("g20_akuma");
	
	SpawnVillagers("g20_villager_1");
	SpawnVillagers("g20_villager_2");
	SpawnVillagers("g20_villager_3");
	
	SpawnNPC("g20_merchant");
	SpawnNPC("g20_villager_4");
	SpawnNPC("g20_villager_5");
	SpawnNPC("g20_boar_farmer");
	
	HSTSpawnFredegar();
	//SpawnAnimals("g20_pig");
	SpawnAnimals("g20_boar");
	
	SpawnStores("g20_store_nimbre");
}