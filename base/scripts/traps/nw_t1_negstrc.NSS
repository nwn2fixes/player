//::///////////////////////////////////////////////
//:: Negative Energy Trap Strong
//:: 'nw_t1_negstrc'
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
	Does 5d6 negative energy damage and the target must make a Fortitude save or
	permanently lose 2 strength.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Nov 16, 2001
//:://////////////////////////////////////////////
// kevL 2023 jan 20 - use funct in "n2f_trap_inc"

#include "n2f_trap_inc"

void main()
{
	n2f_TrapDoNegative(5, 18, 2); // iDice, iDc, iPenalty
}
