// '2430_fix_statue'
//
// kevL's 160907 - based on 'gtr_speak_node'
// - prevents the associated plot-critical dialog from starting unless
//   entered by a player-controlled character. Also shunts this player
//   to his/her Owned PC.

#include "ginc_trigger"

void main()
{
	object oPC = GetEnteringObject();
	if (GetIsPC(oPC) && StandardSpeakTriggerConditions(oPC))
	{
		DoSpeakTrigger(oPC);
	}
}
