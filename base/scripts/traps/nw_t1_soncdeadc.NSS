//::///////////////////////////////////////////////
//:: Sonic Trap Deadly
//:: 'nw_t1_soncdeadc'
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
/*
	8d4 sonic damage and the creature is stunned for 4 rounds on a failed Will
	save.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 31, 2001
//:://////////////////////////////////////////////
// RPGplayer1 08/16/2008 - patched faction check to support Set Traps skill better
// RPGplayer1 12/30/2008 - improved faction check to pass creator for crafted traps properly
// kevL 2023 jan 20 - use funct in "n2f_trap_inc"

#include "n2f_trap_inc"

void main()
{
	n2f_TrapDoSonic(8, 20, 4); // iDice, iDc, iDur
}
