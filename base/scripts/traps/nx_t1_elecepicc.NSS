//::///////////////////////////////////////////////
//:: Electrical Trap Epic
//:: 'nx_t1_elecepicc'
//:: Copyright (c) 2007 Obsidian Ent.
//:://////////////////////////////////////////////
/*
	The creature setting off the trap is struck by a strong electrical current
	that arcs to 6 other targets doing 50d6 damage. Can make a Reflex save for
	half damage.
*/
//:://////////////////////////////////////////////
//:: Created By: Ryan Young
//:: Created On: 1.22.2007
//:://////////////////////////////////////////////
// kevL 2023 jan 18 - use refactored functs in "n2f_trap_inc"

#include "n2f_trap_inc"

void main()
{
	n2f_TrapDoElectrical(d6(50), 35, 6); // iHp, iDc, iExtraTargets
}
