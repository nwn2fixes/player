//::///////////////////////////////////////////////
//:: Fire Trap Epic
//:: 'x2_t1_fireepicc'
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
	Does 50d6 fire damage to all within 10 ft.

	kL_Note: a version of "nx_t1_fireepicc" with more damage but lower DC
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: June 09, 2003
//:://////////////////////////////////////////////
// kevL 2023 jan 18 - use functs in "n2f_trap_inc"

#include "n2f_trap_inc"

void main()
{
	n2f_TrapDoFire(50, 33); // iDice, iDc
}
