//::///////////////////////////////////////////////
//:: Gas Trap Average
//:: 'nw_t1_gasavgc'
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
	Creates a 5m radius poison gas cloud that lasts for 2 rounds and poisons all
	creatures entering the area with Death Blade poison.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: July 30, 2001
//:://////////////////////////////////////////////
// kevL 2023 jan 20 - use funct in "n2f_trap_inc"

#include "n2f_trap_inc"

void main()
{
	n2f_TrapDoGas("nw_t1_gasavgc1"); // sScript
}
