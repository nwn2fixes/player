//::///////////////////////////////////////////////
//:: Acid Blob Trap Strong
//:: 'nw_t1_acidstrc'
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
	Target is hit with a blob of acid that does 12d6 damage and holds the target
	for 4 rounds. Can make a Reflex save to avoid the hold effect.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: July 4th, 2001
//:://////////////////////////////////////////////
// kevL 2023 jan 20 - use funct in "n2f_trap_inc"

#include "n2f_trap_inc"

void main()
{
	n2f_TrapDoAcidBlob(12, 25, 4); // iDice, iDc, iDur // note DC is equal to Deadly type
}
