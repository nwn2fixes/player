// 'nx2_ol_client_enter'
/*
	On Client Enter script for an overland map area.
*/
// JH/EF-OEI: 01/17/08

#include "ginc_overland"
#include "ginc_overland_constants"
#include "kinc_trade"
#include "ginc_cutscene"

// Disables actionmodes that hurt movement on the overland map - JWR-OEI
void StripOLMapModes(object oPC)
{
	if (GetActionMode(oPC, ACTION_MODE_STEALTH))
		SetActionMode(oPC, ACTION_MODE_STEALTH, 0);

	if (GetActionMode(oPC, ACTION_MODE_HELLFIRE_BLAST))
		SetActionMode(oPC, ACTION_MODE_HELLFIRE_BLAST, 0);

	if (GetActionMode(oPC, ACTION_MODE_HELLFIRE_SHIELD))
		SetActionMode(oPC, ACTION_MODE_HELLFIRE_SHIELD, 0);

	if (GetActionMode(oPC, ACTION_MODE_DETECT))
		DelayCommand(0.1f, SetActionMode(oPC, ACTION_MODE_DETECT, 0));
}

//
void DisplayOLMapTutorial()
{
	SetPause(TRUE);

	object oPlayer = GetFirstFactionMember(GetFirstPC(), TRUE);

	// Add the Tutorial Journal Entries
	AddJournalQuestEntry("tut_olmap", 900, oPlayer);
	AddJournalQuestEntry("tut_olmap_dialog", 900, oPlayer);
	AddJournalQuestEntry("tut_olmap_skills", 900, oPlayer);

	while (GetIsObjectValid(oPlayer))
	{
		DisplayMessageBox(oPlayer, 234265, "", "gui_olmap_tutorial_2", "gui_tutorial_close", TRUE, "SCREEN_MESSAGEBOX_TUTORIAL", 181415);
		oPlayer = GetNextFactionMember(GetFirstPC(), TRUE);
	}
}


//
int StartingConditional()
{
	object oPC = GetFirstEnteringPC();
	while (GetIsObjectValid(oPC))
	{
		if (GetIsPC(oPC))
		{
			PrettyDebug("Swapping UI for " + GetName(oPC));
			ActivateOLMapUI(oPC);
		}
		oPC = GetNextEnteringPC();
	}
	oPC = GetFirstEnteringPC(); // Resetting this for the rest of the script :)

	if (GetGlobalInt("bOLMapTutorialDone") != TRUE)
	{
		DisplayOLMapTutorial();
		SetGlobalInt("bOLMapTutorialDone", TRUE);
	}

	object oLeader = GetLocalObject(GetModule(), "oPartyLeader");								// First try to set the leader to the old actor...
	int bValidLeader = (GetIsRosterMember(oLeader) || GetIsOwnedByPlayer(oLeader))
					&& GetCommandable(oLeader) && !GetIsDead(oLeader) && GetIsObjectValid(oLeader);

	// Disabled because it was causing player confusion about who
	// was supposed to be leading the party when transition to OL.
/*	if (bValidLeader == TRUE)																	// If that leader is now invalid, try the first faction member.
	{
		SetPartyActor(oLeader, oPC);
	}
	else
	{
		object oNewLeader = GetFirstFactionMember(oPC, FALSE);
		bValidLeader = (GetIsRosterMember(oNewLeader) || GetIsOwnedByPlayer(oNewLeader))
					&& GetCommandable(oNewLeader) && !GetIsDead(oNewLeader) && GetIsObjectValid(oNewLeader);

		while(bValidLeader != TRUE && GetIsObjectValid(oNewLeader))								// Then try everyone else in the faction until we find someone.
		{
			oNewLeader = GetNextFactionMember(oPC, FALSE);										// You should never have nobody valid...
			bValidLeader = (GetIsRosterMember(oNewLeader) || GetIsOwnedByPlayer(oNewLeader))	// but if you do you'll just get the first faction member.
						&& GetCommandable(oNewLeader) && !GetIsDead(oNewLeader) && GetIsObjectValid(oNewLeader);
		}

		SetPartyActor(oNewLeader, oPC);
	} */

	if (GetJournalEntry("m_q10_associates", oPC) == 800)
	{
		SetGlobalInt("00_bCueMurder", TRUE);
	}

	object oParty = GetFirstFactionMember(oPC, FALSE);
	while (GetIsObjectValid(oParty))
	{
		PrettyDebug(GetName(oParty));

		if (GetIsDead(oParty) && !GetIsDead(oParty, FALSE)) // If you are dying but not dead
		{
			effect eEffect = GetFirstEffect(oParty);
			while (GetIsEffectValid(eEffect))
			{
				if (GetEffectType(eEffect) == EFFECT_TYPE_HITPOINT_CHANGE_WHEN_DYING)
				{
					if (GetEffectInteger(eEffect, 0) != TRUE)
					{
						effect eDeath = EffectDeath(FALSE, FALSE, TRUE);
						DelayCommand(1.0f, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oParty));
					}
				}
				eEffect = GetNextEffect(oParty);
			}
		}

		if (GetLocalInt(oParty, "pcshrunk") == FALSE)
		{
			RemoveAllEffects(oParty, FALSE);
			ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectSetScale(0.5, 0.5, 0.5),oParty);
			SetLocalInt(oParty, "pcshrunk", TRUE);
		}

		// JWR-OEI Changing this per Nathaniel's request
		// DON'T HIT ME!!!!!
		if (GetLocalInt(oParty, "bLoaded") != TRUE)
		{
			SetLocalInt(oParty, "bLoaded", TRUE);
		}

		if (oParty != GetFactionLeader(oParty))
			SetScriptHidden(oParty, TRUE, FALSE);

		// strip "bad" modes for OL map travel
		StripOLMapModes(oParty);
		oParty = GetNextFactionMember(oPC, FALSE);
	}

	string sSpawnScript = GetLocalString(OBJECT_SELF, "sSpawnScript");
	if (sSpawnScript != "")
	{
		ExecuteScript(sSpawnScript, OBJECT_SELF);
	}

	if (!IsMarkedAsDone())
	{
		InitializeNeutralEncounter(oPC);

		PrettyDebug("I'm in the client enter!");

		int nDay = GetCalendarDay();
		int nMonth = GetCalendarMonth();
		int nYear = GetCalendarYear();

		SetGlobalInt(VAR_CURRENT_DAY, nDay);
		SetGlobalInt(VAR_CURRENT_MONTH, nMonth);
		SetGlobalInt(VAR_CURRENT_YEAR, nYear);

		int nGoodiesTotal = GetLocalInt(OBJECT_SELF, VAR_GOODIES_TOTAL);
		int nGoodiesPerSpawn = nGoodiesTotal / 10;

		float fDelay = 0.0f;
		DelayCommand(fDelay, GerminateGoodies(nGoodiesPerSpawn));
		fDelay += 1.0f;
		DelayCommand(fDelay, GerminateGoodies(nGoodiesPerSpawn));
		fDelay += 1.0f;
		DelayCommand(fDelay, GerminateGoodies(nGoodiesPerSpawn));
		fDelay += 1.0f;
		DelayCommand(fDelay, GerminateGoodies(nGoodiesPerSpawn));
		fDelay += 1.0f;
		DelayCommand(fDelay, GerminateGoodies(nGoodiesPerSpawn));
		fDelay += 1.0f;
		DelayCommand(fDelay, GerminateGoodies(nGoodiesPerSpawn));
		fDelay += 1.0f;
		DelayCommand(fDelay, GerminateGoodies(nGoodiesPerSpawn));
		fDelay += 1.0f;
		DelayCommand(fDelay, GerminateGoodies(nGoodiesPerSpawn));
		fDelay += 1.0f;
		DelayCommand(fDelay, GerminateGoodies(nGoodiesPerSpawn));
		fDelay += 1.0f;
		DelayCommand(fDelay, GerminateGoodies(nGoodiesPerSpawn));


		ResetSpecialEncounterTimer();

		MarkAsDone();
	}

	ProcessCaravansOnEnter();

	return FALSE;
}
