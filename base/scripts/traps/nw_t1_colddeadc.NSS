//::///////////////////////////////////////////////
//:: Frost Trap Deadly
//:: 'nw_t1_colddeadc'
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
	Strikes the entering object with a blast of cold for 8d4 damage.
	Fortitude save to avoid being paralyzed for 4 rounds.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Nov 16th, 2001
//:://////////////////////////////////////////////
// kevL 2023 jan 18 - use funct in "n2f_trap_inc"

#include "n2f_trap_inc"

void main()
{
	n2f_TrapDoFrost(8, 15, 4); // iDice, iDc, iDur
}
