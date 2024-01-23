//::///////////////////////////////////////////////
//:: Sonic Trap Strong
//:: 'nw_t1_soncstrc'
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
/*
	5d4 sonic damage and the creature is stunned for 3 rounds on a failed Will
	save.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Nov 16, 2001
//:://////////////////////////////////////////////
// RPGplayer1 08/16/2008 - added faction check to avoid hitting neutrals
// RPGplayer1 12/30/2008 - improved faction check to pass creator for crafted traps properly
// kevL 2023 jan 20 - use funct in "n2f_trap_inc"

#include "n2f_trap_inc"

void main()
{
	n2f_TrapDoSonic(5, 17, 3); // iDice, iDc, iDur
}
