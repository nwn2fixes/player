//::///////////////////////////////////////////////
//:: Negative Energy Trap Minor
//:: 'nw_t1_negminc'
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
	Does 2d6 negative energy damage and the target must make a Fortitude save or
	permanently lose 1 strength.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Nov 16, 2001
//:://////////////////////////////////////////////
// kevL 2023 jan 20 - use funct in "n2f_trap_inc"

#include "n2f_trap_inc"

void main()
{
	n2f_TrapDoNegative(2, 12, 1); // iDice, iDc, iPenalty
}
