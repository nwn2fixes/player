//::///////////////////////////////////////////////////////////////////////////
//::
//::	3000_cliententer.nss
//::
//::	This is the OnClientEnter handler for area 3000.
//::	Please refer to 3000_onenter for more details.
//::
//::///////////////////////////////////////////////////////////////////////////
//::
//::	Created by: Brian Fox
//::	Created on: 10/11/05
//::
//::///////////////////////////////////////////////////////////////////////////

#include "30_constants"
#include "ginc_object"
#include "ginc_journal"
//#include "ginc_debug"
#include "ginc_cutscene"
#include "nw_i0_generic"

//::///////////////////////////////////////////////////////////////////////////

int GetIs3000ReadyForModuleIntro();
int GetIs3000ReadyForReaverBattle();
void Populate3000ForReaverBattle();

//::///////////////////////////////////////////////////////////////////////////

int StartingConditional()
{
	// Do not execute if OnClientEnter was not fired from a group area transition
	if (FiredFromPartyTransition() == FALSE) return (FALSE);

	// Get party leader, force control of owned PC
	object oPC = GetFirstEnteringPC();
	object oLeader = GetFactionLeader(oPC);
	oPC = SetOwnersControlledCompanion(oLeader);

	// Initialize temp CutsceneInfo
	struct CutsceneInfo stCI;
	stCI = ResetCutsceneInfo(stCI);

	int bCutsceneCondition;
	string sSpeakerTag;
	string sDialogName;

	// *** START CLIENT ENTER CUTSCENES ***

	// MODULE INTRO
	if (GetIsCutscenePending(stCI) == FALSE)
	{
		bCutsceneCondition = GetIs3000ReadyForModuleIntro();
		sSpeakerTag = TAG_NEVALLE;
		sDialogName = CONVO_NEVALLE;

		stCI = SetupCutsceneInfo(stCI, sSpeakerTag, oPC, sDialogName, bCutsceneCondition);
	}

	// REAVER BATTLE
	if (GetIsCutscenePending(stCI) == FALSE)
	{
		if (GetIs3000ReadyForReaverBattle() == TRUE)
		{
			Populate3000ForReaverBattle();
		}
	}

	// *** END CLIENT ENTER CUTSCENES ***

	// Cue cutscene or revert control to original character
	if (GetIsCutscenePending(stCI) == TRUE)
	{
		FireAndForgetConversation(stCI.oSpeaker, oPC, stCI.sDialog);
	}
	else
	{
		SetOwnersControlledCompanion(oPC, oLeader);
	}

	// If cutscene is pending, fade to black
	return GetIsCutscenePending(stCI);
}

//::///////////////////////////////////////////////////////////////////////////

int GetIs3000ReadyForModuleIntro()
{
	return !(GetIsJournalQuestAssigned(DEFEND_CASTLE_NEVER_TAG, GetFirstEnteringPC()) || GetGlobalInt("30b_Neverneath_Entered") == 1);
}

int GetIs3000ReadyForReaverBattle()
{
	return (GetJournalQuestEntry(DEFEND_CASTLE_NEVER_TAG, GetFirstEnteringPC()) == TRAVEL_NEVERNEATH_QUEST_ID);
//		&& GetIsItemPossessedByParty(GetFirstEnteringPC(), TAG_ROD_OF_NEVER); // NOTE: Could break the plot if the Rod was dropped. Assume the Rod has been found as a "done deed".
}

void Populate3000ForReaverBattle()
{
	PlaceCreatureAtTag(TAG_NEVALLE, "wp_3000_nev_jump", RR_NEVALLE); // get Nevalle ready to run down the great hall when the battle ends.
	PlaceCreatureAtTag(TAG_NASHER, "wp_3000_nasher", RR_NASHER);
	PlaceCreatureAtTag(TAG_REAVER_1, REAVER_SP_TAG, RR_REAVER_1);

	object oNasher = GetTarget(TAG_NASHER);				// NOTE: Nasher waits till the PC opens the door behind the throne before engaging the reaver - '3000_throne_onused'.
	SetPlotFlag(oNasher, FALSE);						// kL_add. Let Nasher be attackable ....
	SetImmortal(oNasher, TRUE); 						// kL_add.
	SetCombatOverrides(oNasher, OBJECT_INVALID,			// kL_add
					   -1, -1,
					   OVERRIDE_ATTACK_RESULT_DEFAULT, 0, 0,
					   FALSE, FALSE,
					   FALSE, TRUE);
	AssignCommand(oNasher, ClearAllActions(TRUE));		// kL_add.

	location lLoc = GetBehindLocation(oNasher, 3.5f);	// kL_add: step Nasher back a bit ...
	AssignCommand(oNasher, JumpToLocation(lLoc));		// kL_add. Ie - his guards fight the reaver alone until PC opens the door-behind-the-throne


	object oGate = GetNearestObjectByTag("30_castle_gate3", oNasher);	// open the gate to the throneroom to let the nobles out
	SetLocked(oGate, FALSE);											// otherwise they look silly standing there staring out
	AssignCommand(oGate, ActionOpenDoor(oGate));						// yes i know they're supposed to stay shut until '30a_nasher' runs ...
																		// but in addition to looking silly during the fight they would leave
																		// the throne room during the PC's knighting ... which is even sillier
	// handle the Reaver ->												// since that is what nobles love to stand around and watch.
	object oReaver = GetTarget(TAG_REAVER_1);
	SetScriptHidden(oReaver, FALSE);				// kL_note: is reaver currently hidden ....
	SetPlotFlag(oReaver, FALSE);					// kL_add. Let reaver be attackable ... is still Immortal.
	SetLocalInt(oReaver, "bHasEscaped3000", TRUE);	// kL_add: use this (cf. '3000_reaver_udef') to stop the reaver from porting-out before PC arrives;
													// ie. set it here but toggle it off when PC opens the door behind the throne in '3000_throne_onused'
													// NOTE: This could be unnecessary now that SetCombatOverrides() should prevent Nasher
													// and his guards from damaging the reaver at all (I think they actually do still).
	ChangeToStandardFaction(oReaver, STANDARD_FACTION_HOSTILE);
	AssignCommand(oReaver, ClearAllActions(TRUE));

	// handle Nasher's guards ->
	int nWPCounter = 1;
	object oWP = GetNearestObjectByTag(TAG_3000_GUARD_WP, oNasher, nWPCounter);

	int nNPCCounter = 1;
	object oNPC = GetNearestObjectByTag(TAG_3000_GUARD_INTERIOR, oNasher, nNPCCounter);
	while (GetIsObjectValid(oNPC))
	{
		if (!GetIsObjectValid(oWP))
		{
			nWPCounter = 1;
			oWP = GetNearestObjectByTag(TAG_3000_GUARD_WP, oNasher, nWPCounter);
		}
		ChangeToStandardFaction(oNPC, STANDARD_FACTION_DEFENDER);				// kL_add. (I do it this way because I don't trust AdjustReputation() between non-player factions)
		AssignCommand(oNPC, ClearAllActions(TRUE));
		AssignCommand(oNPC, JumpToObject(oWP));
		ForceRest(oNPC);														// kL_add. (full heal)
		SetCombatOverrides(oNPC, OBJECT_INVALID,								// kL_add
						   -1, -1,
						   OVERRIDE_ATTACK_RESULT_DEFAULT, 0, 0,
						   FALSE, FALSE,
						   FALSE, TRUE);
		AssignCommand(oNPC, DelayCommand(1.f, DetermineCombatRound(oReaver)));	// kL_add.

		oNPC = GetNearestObjectByTag(TAG_3000_GUARD_INTERIOR, oNasher, ++nNPCCounter);
		oWP = GetNearestObjectByTag(TAG_3000_GUARD_WP, oNasher, ++nWPCounter);
	}

	// handle the nobles ->
	nWPCounter = 1;
	oWP = GetNearestObjectByTag(TAG_3000_AUDIENCE_WP, oNasher, nWPCounter);

	nNPCCounter = 1;
	oNPC = GetNearestObjectByTag(TAG_3000_AUDIENCE, oNasher, nNPCCounter);
	while (GetIsObjectValid(oNPC))
	{
		if (!GetIsObjectValid(oWP))
		{
			nWPCounter = 1;
			oWP = GetNearestObjectByTag(TAG_3000_AUDIENCE_WP, oNasher, nWPCounter);
		}
		AssignCommand(oNPC, ClearAllActions(TRUE));
		AssignCommand(oNPC, JumpToObject(oWP));

		oNPC = GetNearestObjectByTag(TAG_3000_AUDIENCE, oNasher, ++nNPCCounter);
		oWP = GetNearestObjectByTag(TAG_3000_AUDIENCE_WP, oNasher, ++nWPCounter);
	}
}
