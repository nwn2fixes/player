//::///////////////////////////////////////////////
//:: Frost Trap Minor
//:: 'nw_t1_coldminoc'
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
	Strikes the entering object with a blast of cold for 2d4 damage.
	Fortitude save to avoid being paralyzed for 1 round.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Nov 16th, 2001
//:://////////////////////////////////////////////
// kevL 2023 jan 18 - use funct in "n2f_trap_inc"

#include "n2f_trap_inc"

void main()
{
	n2f_TrapDoFrost(2, 12, 1); // iDice, iDc, iDur
}
