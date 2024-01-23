//::///////////////////////////////////////////////
//:: Fire Trap Minor
//:: 'nw_t1_fireminoc'
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
	Does 5d6 fire damage to all within 5 ft.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: July 4th, 2001
//:://////////////////////////////////////////////
//:: Update Pass By - Preston W on July 27, 2001
// RPGplayer1 12/30/2008 - patched faction check to support Set Traps skill better
// kevL 2023 jan 18 - use functs in "n2f_trap_inc"

#include "n2f_trap_inc"

void main()
{
	n2f_TrapDoFire(5, 18, RADIUS_SIZE_SMALL); // iDice, iDc, fRadius
}
