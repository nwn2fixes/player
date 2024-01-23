//::///////////////////////////////////////////////
//:: Holy Trap Fatal
//:: 'nx_t1_holyfatalc'
//:: Copyright (c) 2007 Obsidian Ent.
//:://////////////////////////////////////////////
/*
	Strikes the entering creature with holy damage.
	- undead take 16d10
	- nonundead take 12d4
*/
//:://////////////////////////////////////////////
//:: Created By: Ryan Young
//:: Created On: 1.22.2007
//:://////////////////////////////////////////////
// kevL 2023 jan 20 - use funct in "n2f_trap_inc"

#include "n2f_trap_inc"

void main()
{
	n2f_TrapDoHoly(16, 12); // iDiceUndead, iDiceNonundead
}
