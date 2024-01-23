//::///////////////////////////////////////////////
//:: Acid Blob Trap Minor
//:: 'nw_t1_acidminoc'
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
	Target is hit with a blob of acid that does 3d6 damage and holds the target
	for 2 rounds. Can make a Reflex save to avoid the hold effect.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: July 4th, 2001
//:://////////////////////////////////////////////
// kevL 2023 jan 20 - use funct in "n2f_trap_inc"

#include "n2f_trap_inc"

void main()
{
	n2f_TrapDoAcidBlob(3, 15, 2); // iDice, iDc, iDur
}
