//::///////////////////////////////////////////////////////////////////////////
//::
//::	3000_throne_onused.nss
//::
//::	This is the OnUsed handler for the Throne "door" in 3000.
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

void main()
{
	object oReaver = GetTarget(TAG_REAVER_1);

	int nCounter = 1;
	object oGuard = GetNearestObjectByTag(TAG_3000_GUARD_INTERIOR, oReaver, nCounter);
	while (GetIsObjectValid(oGuard))
	{
//		SetPlotFlag(oGuard, FALSE); // kL_changed: the Guards are NOT plot ...
		SetImmortal(oGuard, FALSE); // -> allow Nasher's guards to be killed by the reaver.
		oGuard = GetNearestObjectByTag(TAG_3000_GUARD_INTERIOR, oReaver, ++nCounter);
	}

//	if (GetIsObjectValid(oReaver)) // kL_note: Reaver IS valid.
//	{
	SetLocalInt(oReaver, "bHasEscaped3000", FALSE);	// kL_add: cf. '3000_cliententer' and '3000_reaver_udef' - allow Reaver to port away at 50% health.
//	SetPlotFlag(oReaver, FALSE);					// kL_changed: done in '3000_cliententer'
	ForceRest(oReaver);								// full heal
//	}
//	else PrettyError("ERROR: I can't find the Reaver!");

	object oNasher = GetTarget(TAG_NASHER);
	ForceRest(oNasher);												// kL_add. (full heal)
	ChangeToStandardFaction(oNasher, STANDARD_FACTION_DEFENDER);	// kL_add.
	AssignCommand(oNasher, DetermineCombatRound(oReaver));			// kL_add.
}
