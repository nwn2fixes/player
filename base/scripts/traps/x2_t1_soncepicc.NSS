//::///////////////////////////////////////////////
//:: Sonic Trap Epic
//:: 'x2_t1_soncepicc'
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
/*
	40d4 sonic damage and the creature is stunned for 4 rounds on a failed Will
	save.

	kL_Note: a version of "nx_t1_sonicepicc" with much more damage
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: June 09, 2003
//:://////////////////////////////////////////////
// kevL 2023 jan 20 - use funct in "n2f_trap_inc"
//                  - improved faction check to pass creator for crafted traps properly

#include "n2f_trap_inc"

void main()
{
	n2f_TrapDoSonic(40, 30, 4, VFX_DUR_STUN); // iDice, iDc, iDur, iVisdur
}
