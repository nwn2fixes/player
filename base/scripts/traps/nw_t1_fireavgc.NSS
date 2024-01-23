//::///////////////////////////////////////////////
//:: Fire Trap Average
//:: 'nw_t1_fireavgc'
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
	Does 8d6 fire damage to all within 5 ft.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: July 4th, 2001
//:://////////////////////////////////////////////
//:: Update Pass By - unspecified
// RPGplayer1 12/30/2008 - patched faction check to support Set Traps skill better
// kevL 2023 jan 18 - use functs in "n2f_trap_inc"

#include "n2f_trap_inc"

void main()
{
	n2f_TrapDoFire(8, 20, RADIUS_SIZE_SMALL); // iDice, iDc, fRadius
}
