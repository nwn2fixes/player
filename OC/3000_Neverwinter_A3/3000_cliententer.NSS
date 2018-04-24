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
#include "ginc_debug"
#include "ginc_cutscene"

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
	return !(GetIsJournalQuestAssigned( DEFEND_CASTLE_NEVER_TAG, GetFirstEnteringPC() ) || GetGlobalInt("30b_Neverneath_Entered") == 1 );
}

int GetIs3000ReadyForReaverBattle()
{
	return ( GetJournalQuestEntry(DEFEND_CASTLE_NEVER_TAG, GetFirstEnteringPC()) == TRAVEL_NEVERNEATH_QUEST_ID );
}

void Populate3000ForReaverBattle()
{
	PlaceCreatureAtTag( TAG_NEVALLE, "wp_3000_nev_jump", RR_NEVALLE );
	PlaceCreatureAtTag( TAG_REAVER_1, REAVER_SP_TAG, RR_REAVER_1 );
	PlaceCreatureAtTag( TAG_NASHER, "wp_3000_nasher", RR_NASHER );

	object oNasher = GetTarget( TAG_NASHER );
	object oReaver = GetTarget( TAG_REAVER_1 );

	SetScriptHidden( oReaver, FALSE );
	ChangeToStandardFaction( oReaver, STANDARD_FACTION_HOSTILE );
	AssignCommand( oReaver, ClearAllActions(TRUE) );
	AssignCommand( oReaver, ActionAttack( oNasher ) );

	int nNPCCounter = 1;
	int nWPCounter = 1;
	object oNPC = GetNearestObjectByTag( TAG_3000_AUDIENCE, oNasher, nNPCCounter );
	object oWP = GetNearestObjectByTag( TAG_3000_AUDIENCE_WP, oNasher, nWPCounter );

	while ( GetIsObjectValid(oNPC) )
	{
		if ( !GetIsObjectValid(oWP) )
		{
			nWPCounter = 1;
			oWP = GetNearestObjectByTag( TAG_3000_AUDIENCE_WP, oNasher, nWPCounter );
		}
		AssignCommand( oNPC, ClearAllActions(TRUE) );
		AssignCommand( oNPC, JumpToObject(oWP) );
		oNPC = GetNearestObjectByTag( TAG_3000_AUDIENCE, oNasher, ++nNPCCounter );
		oWP = GetNearestObjectByTag( TAG_3000_AUDIENCE_WP, oNasher, ++nWPCounter );
	}

	nNPCCounter = 1;
	nWPCounter = 1;
	oNPC = GetNearestObjectByTag( TAG_3000_GUARD_INTERIOR, oNasher, nNPCCounter );
	oWP = GetNearestObjectByTag( TAG_3000_GUARD_WP, oNasher, nWPCounter );

	while ( GetIsObjectValid(oNPC) )
	{
		if ( !GetIsObjectValid(oWP) )
		{
			nWPCounter = 1;
			oWP = GetNearestObjectByTag( TAG_3000_GUARD_WP, oNasher, nWPCounter );
		}
		AssignCommand( oNPC, ClearAllActions(TRUE) );
		AssignCommand( oNPC, JumpToObject(oWP) );
		AssignCommand( oNPC, ActionAttack( oReaver ) );
		oNPC = GetNearestObjectByTag( TAG_3000_GUARD_INTERIOR, oNasher, ++nNPCCounter );
		oWP = GetNearestObjectByTag( TAG_3000_GUARD_WP, oNasher, ++nWPCounter );
	}
}