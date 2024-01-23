//::///////////////////////////////////////////////
//:: Spike Trap Minor
//:: 'nw_t1_spikeminoc'
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
	Strikes the entering object with a spike for 2d6 damage.
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
	n2f_TrapDoSpike(d6(2)); // iHp
}
