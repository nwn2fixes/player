//::///////////////////////////////////////////////
//:: Holy Trap Epic
//:: 'nx_t1_holyepicc'
//:: Copyright (c) 2007 Obsidian Ent.
//:://////////////////////////////////////////////
/*
	Strikes the entering creature with holy damage.
	- undead take 20d10
	- nonundead take 16d4
*/
//:://////////////////////////////////////////////
//:: Created By: Ryan Young
//:: Created On: 1.22.2007
//:://////////////////////////////////////////////
// kevL 2023 jan 20 - use funct in "n2f_trap_inc"

#include "n2f_trap_inc"

void main()
{
	n2f_TrapDoHoly(20, 16); // iDiceUndead, iDiceNonundead
}
