// 'b11_client_enter'
/*
	On Client Enter script for B11 - The Sloop.
*/
// TDE 5/27/07
// kevL 2023 dec 20 - refactor bits
//                  - correct the script ref that fires to grant xp when the
//                    fatal electrical trap is disarmed

#include "kinc_spirit_eater"

//
void CreateLootOnObject (string sTarg, string sLoot)
{
	object oTarg = GetObjectByTag(sTarg);
	object oLoot = CreateItemOnObject(sLoot, oTarg);
	SetDroppableFlag(oLoot, TRUE);

	//PrettyDebug("Placing " + GetName(oLoot) + " on " + GetName(oTarg));
}

//
void SpawnIt(string sTag)
{
	location lLoc = GetLocation(GetObjectByTag("sp_" + sTag));
	CreateObject(OBJECT_TYPE_CREATURE, sTag, lLoc);
}

//
void SpawnShelvedar()
{
	SpawnIt("b11_shelvedar");
	SpawnIt("b11_gullen");
	SpawnIt("b11_vinck");

	// Spawn Placed loot
	CreateLootOnObject("b11_shelvedar", "nx1_mandolin01"); // Finch's Subtle Loot
}

//
void SpawnTavern()
{
	SpawnIt("b11_vladek");
	SpawnIt("b11_zorah");
	SpawnIt("b11_clive");
	SpawnIt("b11_colrodin");
	SpawnIt("b11_fyldrin");
	SpawnIt("b11_pirate1");
	SpawnIt("b11_pirate2");
	SpawnIt("b11_pirate3");
	SpawnIt("b11_actor");

	// Spawn Placed loot
	CreateLootOnObject("b11_fyldrin", "nx1_halfplate01"); // Deep Guardian's Plate
}


//
void main()
{
	object oSe = GetSpiritEater();

	if (GetGlobalInt("00_nStoryStep") > 1)
	{
		object oArea = GetArea(oSe); // aka OBJECT_SELF
		if (!GetLocalInt(oArea, "bShelvedarSpawned"))
		{
			SetLocalInt(oArea, "bShelvedarSpawned", TRUE);
			SpawnShelvedar();
		}
	}

	if (!IsMarkedAsDone())
	{
		MarkAsDone();

		// Spawn everyone who should be here in the beginning
		SpawnTavern();

		// n2f_start ->
		object oTrap = GetNearestObjectByTag("nx_felectrap001", oSe);
		SetEventHandler(oTrap, SCRIPT_TRIGGER_ON_DISARMED, "go_xp_trap");
		// n2f_end.
	}
}
