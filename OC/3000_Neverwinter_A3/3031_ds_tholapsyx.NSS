//:://////////////////////////////////////////////////
//:: '3031_ds_tholapsyx''
/*
	Tholapsyx' deathscript
*/
//:://////////////////////////////////////////////////
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Created On: 12/22/2002
//:://////////////////////////////////////////////////
// chazm 5/6/05 added DeathScript
// ChazM 7/28/05 removed call to user defined event for onDeath
// kevL 2023.7.24 - remove debug and refactor bits
//                - travus' fix for RemoveJournalQuestEntry()

#include "x2_inc_compon" // craft_drop_items()
//#include "x0_i0_spawncond"
//#include "ginc_misc"
#include "ginc_group" // Group*()
//#include "nw_i0_henchman"
//#include "ginc_ipspeaker"
#include "ginc_journal" // AwardXP()
//#include "ginc_debug"

const string FGIANT_GROUP = "3033_giant_group";
const string GALARDRYM_FIRE_GIANT_GROUP = "GalardrymFireGiantsGroup";


void main()
{
	//PrettyDebug("DEBUG: Tholapsyx is dead!");
	SetGlobalInt("30_bTholapsyxDead", 1);

	object oLeader = GetFactionLeader(GetFirstPC());

	// Give quest XP
	AwardXP(oLeader, 42); // row #42 in k_xp_awards.2da

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

	SetLocalInt(o3031, "fighting_tholapsyx", 0);

	AddJournalQuestEntry("30_galadrym", 70, oLeader, TRUE, TRUE);

	if (GetGlobalInt("31_nIvarrPathHoly") == 1)
	{
		//PrettyDebug("DEBUG: Path of the Holy Quest is set to 35");
		AddJournalQuestEntry("30_path_holy", 30, oLeader, TRUE, TRUE);
	}

	if (GetGlobalInt("31_nIvarrAtonement") == 1)
	{
		//PrettyDebug("DEBUG: Atonement is set to 30");
		AddJournalQuestEntry("30_atonement", 30, oLeader, TRUE, TRUE);
	}

	SetLocalInt(o3031, "tholap_dead", 1);

	// TDE: Give Dragonslayer Epithet Feat to all TruePCs if they don't have it already
	//PrettyDebug("DEBUG: PC gets the Dragonslayer Ephithet Feat!");

	object oPc = GetFirstPC();
	while (GetIsObjectValid(oPc))
	{
		if (!GetHasFeat(FEAT_EPITHET_DRAGONSLAYER, oPc, TRUE))
			FeatAdd(oPc, FEAT_EPITHET_DRAGONSLAYER, FALSE);

		oPc = GetNextPC();
	}

	if (GetLocalInt(o3031, "fgking_dead") == 1)
	{
		object o3033 = GetObjectByTag("3033_fgcanyon");
		if (GetLocalInt(o3033, "Allied_FGiants") == 1)
		{
			GroupChangeToStandardFaction(FGIANT_GROUP, STANDARD_FACTION_HOSTILE);
			GroupDetermineCombatRound(FGIANT_GROUP);

			GroupChangeToStandardFaction(GALARDRYM_FIRE_GIANT_GROUP, STANDARD_FACTION_HOSTILE);

			if (GetIsSinglePlayer()) RemoveJournalQuestEntry("30_galadrym", oLeader); // travus_fix ->
			else                     RemoveJournalQuestEntry("30_galadrym", oLeader, TRUE, TRUE);

			AddJournalQuestEntry("30_galadrym", 100, oLeader, TRUE, TRUE);
		}
	}

	string sDeathScript = GetLocalString(OBJECT_SELF, "DeathScript");
	if (sDeathScript != "")
		ExecuteScript(sDeathScript, OBJECT_SELF);

/*	if (GetMyArea(oLeader) == "3032_tcanyon")
	{
		string sSpeakerTag = "3032_ip_convo";
		string sConversation = "3031_cut_tholap_dead";
		location lLoc = GetLocation(OBJECT_SELF);
		CreateIPSpeaker(sSpeakerTag, sConversation, lLoc);
	} */
}
