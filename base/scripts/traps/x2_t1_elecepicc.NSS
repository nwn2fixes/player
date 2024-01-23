//::///////////////////////////////////////////////
//:: Electrical Trap Epic
//:: 'x2_t1_elecepicc'
//:: Copyright (c) 2007 Obsidian Ent.
//:://////////////////////////////////////////////
/*
	The creature setting off the trap is struck by a strong electrical current
	that arcs to 6 other targets doing 60d6 damage. Can make a Reflex save for
	half damage.

	kL_Note: a version of "nx_t1_elecepicc" with more damage
*/
//:://////////////////////////////////////////////
//:: Created By: andrew Nobbs
//:: Created On: June 09, 2003
//:://////////////////////////////////////////////
// kevL 2023 jan 18 - use refactored functs in "n2f_trap_inc"

#include "n2f_trap_inc"

void main()
{
	n2f_TrapDoElectrical(d6(60), 35, 6); // iHp, iDc, iExtraTargets
}
