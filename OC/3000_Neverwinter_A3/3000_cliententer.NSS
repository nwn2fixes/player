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

	// kL_add: Wipe a bunch of handlers from the throne-door ('3000_throne_onused').
	if (!GetLocalInt(OBJECT_SELF, "kL_bThroneHandlersCleared"))
	{
		SetLocalInt(OBJECT_SELF, "kL_bThroneHandlersCleared", TRUE);

		object oThroneDoor = GetNearestObjectByTag("3000_throne_door", oPC);

//		SetEventHandler(oThroneDoor, SCRIPT_DOOR_ON_OPEN, "");				// keep only this.
		SetEventHandler(oThroneDoor, SCRIPT_DOOR_ON_CLOSE, "");				// who cares (throne sinks into the floor and can't be targeted for closure)
		SetEventHandler(oThroneDoor, SCRIPT_DOOR_ON_DAMAGE, "");			// throne can't be damaged
		SetEventHandler(oThroneDoor, SCRIPT_DOOR_ON_DEATH, "");				// note: Throne-door is plot and can't be bashed to death.
		SetEventHandler(oThroneDoor, SCRIPT_DOOR_ON_DISARM, "");			// throne is not trapped
		SetEventHandler(oThroneDoor, SCRIPT_DOOR_ON_MELEE_ATTACKED, "");	// not good enough
		SetEventHandler(oThroneDoor, SCRIPT_DOOR_ON_SPELLCASTAT, "");		// not good enough
		SetEventHandler(oThroneDoor, SCRIPT_DOOR_ON_TRAPTRIGGERED, "");		// throne is not trapped
		SetEventHandler(oThroneDoor, SCRIPT_DOOR_ON_UNLOCK, "");			// throne is not locked
		SetEventHandler(oThroneDoor, SCRIPT_DOOR_ON_CLICKED, "");			// clicked doesn't appear to do anything.
		SetEventHandler(oThroneDoor, SCRIPT_DOOR_ON_DIALOGUE, "");			// has no dialog.
		SetEventHandler(oThroneDoor, SCRIPT_DOOR_ON_FAIL_TO_OPEN, "");		// throne is not locked.

		// NOTE: There doesn't appear to be a constant for ON_USED. (note: It doesn't appear to even work.)
		//
		// These are not set (see the door in the toolset):
		// SCRIPT_DOOR_ON_HEARTBEAT
		// SCRIPT_DOOR_ON_LOCK
		// SCRIPT_DOOR_ON_USERDEFINED

//		int i = 0;				// note: only 15 are defined in nwscript.nss but
//		for (; i != 20; ++i)	// there are 16 event-slots in a door's Properties.
//		{
//			SendMessageToPC(GetFirstPC(FALSE), "script " + IntToString(i) + " : "
//											  + GetEventHandler(oThroneDoor, i));
//		}
	}
	// kL_end.


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

//	location lLoc = GetBehindLocation(oNasher, 3.5f);	// kL_add: step Nasher back a bit ...
	object oWpNasher = GetNearestObjectByTag("wp_3000_nasher", oNasher);
	location lLoc = GetBehindLocation(oWpNasher, 3.f);	// kL_add: step Nasher back a bit ... but use his WP since he might be bumped when placed above.
	AssignCommand(oNasher, JumpToLocation(lLoc));		// kL_add. Ie - his guards fight the reaver alone until PC opens the door-behind-the-throne


	object oGate = GetNearestObjectByTag("30_castle_gate3", oNasher);	// open the gate to the throneroom to let the nobles out
	SetLocked(oGate, FALSE);											// otherwise they look silly standing there staring out
	AssignCommand(oGate, ActionOpenDoor(oGate));						// yes i know they're supposed to stay shut until '30a_nasher' runs ...
																		// but in addition to looking silly during the fight they would leave
																		// the throne room during the PC's knighting ... which is even sillier
																		// since that is what nobles love to stand around and watch.

	oGate = GetNearestObjectByTag("3000_throne_door", oNasher);			// and ensure that the throne-door is closed
	if (GetIsOpen(oGate))												// so its OnUsed script is forced to fire when PC enters the throne room.
		AssignCommand(oGate, ActionCloseDoor(oGate));

	// handle the Reaver ->
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
		AssignCommand(oNPC, DelayCommand(1.f, DetermineCombatRound(oReaver)));	// kL_add. NOTE: Guards are immortal until the throne-door opens.

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
