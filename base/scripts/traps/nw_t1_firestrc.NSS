//::///////////////////////////////////////////////
//:: Fire Trap Strong
//:: 'nw_t1_firestrc'
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
	Does 15d6 fire damage to all within 10 ft.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: July 4th, 2001
//:://////////////////////////////////////////////
//:: Update Pass By - Preston W on July 25, 2001
// RPGplayer1 12/30/2008 - patched faction check to support Set Traps skill better
// kevL 2023 jan 18 - use functs in "n2f_trap_inc"

#include "n2f_trap_inc"

void main()
{
	n2f_TrapDoFire(15, 23); // iDice, iDc
}
