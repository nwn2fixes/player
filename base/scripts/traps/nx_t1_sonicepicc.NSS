//::///////////////////////////////////////////////
//:: Sonic Trap Epic
//:: 'nx_t1_sonicepicc'
//:: Copyright (c) 2007 Obsidian Ent.
//:://////////////////////////////////////////////
/*
	18d4 sonic damage and the creature is stunned for 4 rounds on a failed Will
	save.
*/
//:://////////////////////////////////////////////
//:: Created By: Ryan Young
//:: Created On: 1.22.2007
//:://////////////////////////////////////////////
// RPGplayer1 08/16/2008 - added faction check to avoid hitting neutrals
// kevL 2023 jan 20 - use funct in "n2f_trap_inc"
//                  - change duration from 2 to 4 rounds

#include "n2f_trap_inc"

void main()
{
	n2f_TrapDoSonic(18, 30, 4); // iDice, iDc, iDur // note less duration than Strong type
}
