// '2430_fix_statue'
//
// kevL's 160907 - based on 'gtr_speak_node'
// - prevents the associated plot-critical dialog from starting unless entered
//   by a player-controlled character. Conversations in the stock OC are setup
//   to automatically switch player-control the his/her Owned PC, and the issue
//   seems to be that if the latter is too far away then that switch simply
//   won't happen, yet the trigger will be marked as done anyway.

#include "ginc_trigger"

void main()
{
	object oPC = GetEnteringObject();
	if (GetIsPC(oPC) && StandardSpeakTriggerConditions(oPC))
	{
		DoSpeakTrigger(oPC);
	}
}
