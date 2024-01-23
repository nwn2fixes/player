//::///////////////////////////////////////////////
//:: Tangle Trap Minor
//:: 'nw_t1_tangminoc'
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
	Targets within 5ft of the entering character are slowed unless they make a
	reflex save with a DC of 20. Effect lasts for 3 rounds.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: July 4th, 2001
//:://////////////////////////////////////////////
// kevL 2023 jan 20 - use funct in "n2f_trap_inc"

#include "n2f_trap_inc"

void main()
{
	n2f_TrapDoTangle(20, 3, RADIUS_SIZE_SMALL); // iDc, iDur, fRadius
}
