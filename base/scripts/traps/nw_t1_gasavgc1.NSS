//::///////////////////////////////////////////////
//:: Gas Trap Average - AoE OnEnter script
//:: 'nw_t1_gasavgc1'
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
	Applies Death Blade poison to entering object.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: July 30, 2001
//:://////////////////////////////////////////////
// RPGplayer1 12/30/2008 - patched faction check to support Set Traps skill better
//                       - not a heartbeat script -> while loop removed
// kevL 2023 jan 20 - use funct in "n2f_trap_inc"

#include "n2f_trap_inc"

void main()
{
	n2f_TrapDoGasAoeEnter(POISON_DEATHBLADE); // iPoisonType
}
