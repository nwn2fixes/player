//::///////////////////////////////////////////////
//:: Acid Blob Trap Epic
//:: 'nx_t1_acidepicc'
//:: Copyright (c) 2007 Obsidian Ent.
//:://////////////////////////////////////////////
/*
	Target is hit with a blob of acid that does 30d6 damage and holds the target
	for 5 rounds. Can make a Reflex save to avoid the hold effect.
*/
//:://////////////////////////////////////////////
//:: Created By: Ryan Young
//:: Created On: 1.22.2007
//:://////////////////////////////////////////////
// kevL 2023 jan 20 - use funct in "n2f_trap_inc"

#include "n2f_trap_inc"

void main()
{
	n2f_TrapDoAcidBlob(30, 35, 5); // iDice, iDc, iDur
}
