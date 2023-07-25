//:://////////////////////////////////////////////////
//:: '3033_ds_fgking'
/*
	Fire Giant King's deathscript
*/
//:://////////////////////////////////////////////////
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Created On: 12/22/2002
//:://////////////////////////////////////////////////
// chazm 5/6/05 added DeathScript
// ChazM 7/28/05 removed call to user defined event for onDeath
// kevL 2023.7.24 - refactor bits
//                - travus' fix for RemoveJournalQuestEntry()

#include "x2_inc_compon" // craft_drop_items()
//#include "x0_i0_spawncond"
#include "ginc_misc"


void main()
{
	object o3033 = GetObjectByTag("3033_fgcanyon");
	SetLocalInt(o3033, "GiantsKilled", GetLocalInt(o3033, "GiantsKilled") + 1);

	if (GetLocalInt(o3033, "GiantsKilled") == 15)
	{
		SetLocalInt(o3033, "AllGiantsDead", 1);
		DestroyObject(GetTarget("3033_treasure_wall"));
	}

	string sDeathScript = GetLocalString(OBJECT_SELF, "DeathScript");
	if (sDeathScript != "")
		ExecuteScript(sDeathScript, OBJECT_SELF);

	object oKiller = GetLastKiller();

	// If we're a good/neutral commoner adjust the killer's alignment evil
	if (GetLevelByClass(CLASS_TYPE_COMMONER) > 0)
	{
		int iAlign = GetAlignmentGoodEvil(OBJECT_SELF);
		if (iAlign == ALIGNMENT_GOOD || iAlign == ALIGNMENT_NEUTRAL)
		{
			AdjustAlignment(oKiller, ALIGNMENT_EVIL, 5);
		}
	}

	// Call to allies to let them know we're dead
	SpeakString("NW_I_AM_DEAD", TALKVOLUME_SILENT_TALK);

	// Shout Attack my target, only works with the On Spawn In setup
	SpeakString("NW_ATTACK_MY_TARGET", TALKVOLUME_SILENT_TALK);

	craft_drop_items(oKiller);

	object o3031 = GetObjectByTag("3031_mgalardrym");
	SetLocalInt(o3031, "fgking_dead", 1);

	object oFirstPc = GetFirstPC();

	if (GetLocalInt(o3031, "tholap_dead") == 1)
	{
		if (GetIsSinglePlayer()) RemoveJournalQuestEntry("30_galadrym", oFirstPc); // travus_fix ->
		else                     RemoveJournalQuestEntry("30_galadrym", oFirstPc, TRUE, TRUE);

		AddJournalQuestEntry("30_galadrym", 100, oFirstPc, TRUE, TRUE);

		if (GetGlobalInt("31_nIvarrPathHoly") == 1)
		{
			AddJournalQuestEntry("30_path_holy", 35, oFirstPc, TRUE, TRUE);
		}

		if (GetGlobalInt("31_nIvarrAtonement") == 1)
		{
			AddJournalQuestEntry("30_atonement", 30, oFirstPc, TRUE, TRUE);
		}
	}
	else
	{
		AddJournalQuestEntry("30_galadrym", 90, oFirstPc, TRUE, TRUE);
	}

	object oRegulator = GetTarget("3033_regulator");
	SetLocalInt(oRegulator, "Go_Regulator_Go", 1);
}
