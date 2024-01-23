//::///////////////////////////////////////////////
//:: Spike Trap Deadly
//:: 'nw_t1_spikedeadc'
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
	Strikes the entering object with a spike for 25d6 damage.

	kL_Note: This is a hugely powerful Spike trap.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: July 4th, 2001
//:://////////////////////////////////////////////
// kevL 2023 jan 20 - use funct in "n2f_trap_inc"
//                  - check vs adjusted damage (not vs raw damage)

#include "n2f_trap_inc"

void main()
{
	n2f_TrapDoSpike(d6(25)); // iHp
}
