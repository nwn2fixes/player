//::///////////////////////////////////////////////
//:: Acid Blob Trap Average
//:: 'nw_t1_acidavgc'
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
	Target is hit with a blob of acid that does 5d6 damage and holds the target
	for 3 rounds. Can make a Reflex save to avoid the hold effect.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: July 4th, 2001
//:://////////////////////////////////////////////
// kevL 2023 jan 20 - use funct in "n2f_trap_inc"

#include "n2f_trap_inc"

void main()
{
	n2f_TrapDoAcidBlob(5, 20, 3); // iDice, iDc, iDur
}
