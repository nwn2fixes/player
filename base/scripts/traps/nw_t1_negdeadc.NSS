//::///////////////////////////////////////////////
//:: Negative Energy Trap Deadly
//:: 'nw_t1_negdeadc'
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
	Does 8d6 negative energy damage and the target must make a Fortitude save or
	permanently lose 1 level.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Nov 16, 2001
//:://////////////////////////////////////////////
// kevL 2023 jan 20 - use funct in "n2f_trap_inc"

#include "n2f_trap_inc"

void main()
{
	n2f_TrapDoNegative(8, 21, 1, TRUE); // iDice, iDc, iPenalty, bLevelDecrease
}
