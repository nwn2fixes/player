//::///////////////////////////////////////////////
//:: Frost Trap Epic
//:: 'x2_t1_coldepicc'
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
	Strikes the entering object with a blast of cold for 40d4 damage.
	Fortitude save to avoid being paralyzed for 4 rounds.

	kL_Note: this is a very strong epic trap ... compared to the other frost
	traps.
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: June 09, 2003
//:://////////////////////////////////////////////
// kevL 2023 jan 18 - use funct in "n2f_trap_inc"
//                  - change SAVING_THROW_TYPE_COLD to SAVING_THROW_TYPE_TRAP

#include "n2f_trap_inc"

void main()
{
	n2f_TrapDoFrost(40, 30, 4, VFX_DUR_BLUR); // iDice, iDc, iDur, iVisdur
}
