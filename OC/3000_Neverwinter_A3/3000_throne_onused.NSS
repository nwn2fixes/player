//::///////////////////////////////////////////////////////////////////////////
//::
//::	3000_throne_onused.nss
//::
//::	This is the OnUsed handler for the Throne "door" in 3000.
//::
//::	kL ->
//::	It's also the OnClick, OnClosed, OnConversation, OnDamaged, OnDeath,
//::	OnDisarm, OnFailToOpen, OnMeleeAttacked, OnOpen, OnSpellCastAt,
//::	OnTrapTriggered, and OnUnlock handlers ....
//::
//::	ironically it might not even fire for OnUsed. So keep it as the
//::	OnOpen script exclusively. And ensure that it can run only after the PC
//::	has emerged from the Underneath - and that it is in fact closed when
//::	the PC emerges from the Underneath.
//::
//::///////////////////////////////////////////////////////////////////////////
//::
//::	Created by: Brian Fox
//::	Created on: 8/23/06
//::
//::///////////////////////////////////////////////////////////////////////////

#include "30_constants"
#include "ginc_param_const"
#include "nw_i0_generic"
#include "ginc_vars"
#include "ginc_journal"

void main()
{
	if (!IsMarkedAsDone())
	{
		object oLeaderPc = GetOwnedCharacter(GetFactionLeader(GetFirstPC()));						// GetFirstPC() is likely sufficient.
		if (GetJournalQuestEntry(DEFEND_CASTLE_NEVER_TAG, oLeaderPc) >= TRAVEL_NEVERNEATH_QUEST_ID)	// <- is set when PC enters 3001 the Underneath.
		{
			// kL_notes: Don't use GetLastOpenedBy() above; this has to run even if a guard or another
			// NPC opens the door. This door will close itself (if it was open) when the PC emerges
			// from the Underneath; only then should the JournalQuest therefore be found TRUE and the
			// Battle of the Rod will then necessarily happen. At that point it no longer matters
			// what opens the door and causes the body of this script to run - as long as it does.

			MarkAsDone();

			object oReaver = GetTarget(TAG_REAVER_1);

			int nCounter = 1;
			object oGuard = GetNearestObjectByTag(TAG_3000_GUARD_INTERIOR, oReaver, nCounter);
			while (GetIsObjectValid(oGuard))
			{
//				SetPlotFlag(oGuard, FALSE); // kL_changed: the Guards are NOT plot ...
				SetImmortal(oGuard, FALSE); // -> allow Nasher's guards to be killed by the reaver.
				oGuard = GetNearestObjectByTag(TAG_3000_GUARD_INTERIOR, oReaver, ++nCounter);
			}

//			if (GetIsObjectValid(oReaver)) // kL_note: Reaver IS valid.
//			{
			SetLocalInt(oReaver, "bHasEscaped3000", FALSE);	// kL_add: cf. '3000_cliententer' and '3000_reaver_udef' - allow Reaver to port away at 50% health.
//			SetPlotFlag(oReaver, FALSE);					// kL_changed: done in '3000_cliententer'
			ForceRest(oReaver);								// full heal
//			}
//			else PrettyError("ERROR: I can't find the Reaver!");
	
			object oNasher = GetTarget(TAG_NASHER);
			ForceRest(oNasher);												// kL_add. (full heal)
			ChangeToStandardFaction(oNasher, STANDARD_FACTION_DEFENDER);	// kL_add.
			AssignCommand(oNasher, DetermineCombatRound(oReaver));			// kL_add.
		}
	}
}
