//::///////////////////////////////////////////////
//:: Acid Splash Trap Average
//:: 'nw_t1_splshavgc'
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
	Strikes the entering object with a blast of cold for 3d8 damage.
	Reflex save to take half damage.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Nov 16th, 2001
//:://////////////////////////////////////////////
// kevL 2023 jan 20 - use funct in "n2f_trap_inc"
//                  - check nonzero damage after save

#include "n2f_trap_inc"

void main()
{
	n2f_TrapDoAcidSplash(3, 14); // iDice, iDc
}
