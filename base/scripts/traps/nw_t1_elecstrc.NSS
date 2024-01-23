//::///////////////////////////////////////////////
//:: Electrical Trap Strong
//:: 'nw_t1_elecstrc'
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
	The creature setting off the trap is struck by a strong electrical current
	that arcs to 5 other targets doing 20d6 damage. Can make a Reflex save for
	half damage.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: July 30, 2001
//:://////////////////////////////////////////////
// kevL 2023 jan 18 - use refactored functs in "n2f_trap_inc"

#include "n2f_trap_inc"

void main()
{
	n2f_TrapDoElectrical(d6(20), 26, 5); // iHp, iDc, iExtraTargets
}
