//::///////////////////////////////////////////////
//:: Fire Trap Epic
//:: 'nx_t1_fireepicc'
//:: Copyright (c) 2007 Obsidian Ent.
//:://////////////////////////////////////////////
/*
	Does 36d6 fire damage to all within 10 ft.
*/
//:://////////////////////////////////////////////
//:: Created By: Ryan Young
//:: Created On: 1.22.2007
//:://////////////////////////////////////////////
// kevL 2023 jan 18 - use functs in "n2f_trap_inc"

#include "n2f_trap_inc"

void main()
{
	n2f_TrapDoFire(36, 45); // iDice, iDc
}
