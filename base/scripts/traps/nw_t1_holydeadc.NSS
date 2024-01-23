//::///////////////////////////////////////////////
//:: Holy Trap Deadly
//:: 'nw_t1_holydeadc'
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
	Strikes the entering creature with holy damage.
	- undead take 12d10
	- nonundead take 8d4
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: July 4th, 2001
//:://////////////////////////////////////////////
// kevL 2023 jan 20 - use funct in "n2f_trap_inc"

#include "n2f_trap_inc"

void main()
{
	n2f_TrapDoHoly(12, 8); // iDiceUndead, iDiceNonundead
}
