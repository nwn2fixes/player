//::///////////////////////////////////////////////
//:: Tangle Trap Deadly
//:: 'nw_t1_tangdeadc'
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
	Targets within 10ft of the entering character are slowed unless they make a
	reflex save with a DC of 35. Effect lasts for 5 rounds.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: July 4th, 2001
//:://////////////////////////////////////////////
// kevL 2023 jan 20 - use funct in "n2f_trap_inc"

#include "n2f_trap_inc"

void main()
{
	n2f_TrapDoTangle(35, 5); // iDc, iDur
}
