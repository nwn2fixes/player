//::///////////////////////////////////////////////////////////////////////////
//::
//::	0_center
//::
//::	OnClient Enter for WestHarbor tutorial.
//::
//::///////////////////////////////////////////////////////////////////////////
// DBR 3/3/06
// kevL 2017 mar 12 - fix to get the brawlers brawling again.

int StartingConditional()
{
	if (GetLocalInt(OBJECT_SELF,"Done")!=1)
	{	

		// BMA-OEI 5/18/06 Moved to farlong_center
		/*RemoveRosterMember("npc_bevil");
		AddRosterMemberByTemplate("npc_bevil","npc_bevil");
		SpawnRosterMember("npc_bevil",GetLocation(GetObjectByTag("0_wp_spawn_bevil")));

		RemoveRosterMember("0_amie");
		AddRosterMemberByTemplate("0_amie", "0_amie");
		SpawnRosterMember("0_amie",GetLocation(GetObjectByTag("0_wp_spawn_amie")));

		RemoveRosterMember("0_kipp");
		AddRosterMemberByTemplate("0_kipp", "0_kipp");
		SpawnRosterMember("0_kipp",GetLocation(GetObjectByTag("0_wp_kipp_spawn")));
		*/
		//AssignCommand(GetFirstPC(),SetCameraFacing(0.9f,-1.0f,-1.0f));

		
		ExecuteScript("gui_tutorial_hotkeys",OBJECT_SELF);
		
		SetLocalInt(OBJECT_SELF,"Done",1);
	}

	// kL_begin:
	int i;
	for (i = 1; i != 5; ++i)
	{
		string sBrawler = "0_brawler_generic" + IntToString(i);

		object oBrawler = GetObjectByTag(sBrawler);
		if (GetIsObjectValid(oBrawler))
		{
			SetCombatOverrides(oBrawler, OBJECT_INVALID,
							   -1, -1,
							   OVERRIDE_ATTACK_RESULT_DEFAULT,
							   -1, -1,
							   TRUE, TRUE,
							   TRUE,
							   TRUE);

			SetEventHandler(oBrawler, CREATURE_SCRIPT_ON_HEARTBEAT, "0_brawler_generic_sp"); // set their OnHeartbeats
			SetEventHandler(oBrawler, CREATURE_SCRIPT_ON_NOTICE, "");
			SetEventHandler(oBrawler, CREATURE_SCRIPT_ON_SPELLCASTAT, "");
			SetEventHandler(oBrawler, CREATURE_SCRIPT_ON_MELEE_ATTACKED, "");
			SetEventHandler(oBrawler, CREATURE_SCRIPT_ON_DAMAGED, "");
			SetEventHandler(oBrawler, CREATURE_SCRIPT_ON_DISTURBED, "");
			SetEventHandler(oBrawler, CREATURE_SCRIPT_ON_END_COMBATROUND, "");
			SetEventHandler(oBrawler, CREATURE_SCRIPT_ON_DIALOGUE, "");
//			SetEventHandler(oBrawler, CREATURE_SCRIPT_ON_SPAWN_IN, "");
			SetEventHandler(oBrawler, CREATURE_SCRIPT_ON_RESTED, "");
			SetEventHandler(oBrawler, CREATURE_SCRIPT_ON_DEATH, "");
			SetEventHandler(oBrawler, CREATURE_SCRIPT_ON_USER_DEFINED_EVENT, "");
			SetEventHandler(oBrawler, CREATURE_SCRIPT_ON_BLOCKED_BY_DOOR, "");
		}
	}
	// kL_end.

	return FALSE;
}