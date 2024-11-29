//::///////////////////////////////////////////////
//:: Cure Minor Wounds
//:: 'nw_s0_curminw'
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
	Caster Level(s): Bard 0, Cleric 0, Druid 0
	Innate Level: 0
	School: Conjuration
	Descriptor(s):
	Component(s): Verbal, Somatic
	Range: Touch
	Area of Effect / Target: Single
	Duration: Instant
	Save: Will 1/2
	Spell Resistance: Yes

	The target creature is healed for 4 points of damage. Healing spells have a
	reverse effect on undead, harming instead of healing them. A successful
	touch attack must first be made when this spell is used against undead.
*/
//:://////////////////////////////////////////////
//:: Created By: Noel Borstad
//:: Created On: Oct 18, 2000
//:://////////////////////////////////////////////
//:: Last Updated By: Preston Watamaniuk, On: Feb 22, 2001
//:: Last Updated By: Preston Watamaniuk, On: April 6, 2001
// kevL 2023 nov 30 - do not Empower the constant bonus
//                  - change description at the top of this script to that in Dialog.Tlk #6129
//                  - #include "n2f_curehurt_inc"
// kevL 2024 nov 28 - changed to add casterlevel bonus before metamagic
//                  - allow clerics with Healing Domain to auto-empower Maximized cures

#include "x2_inc_spellhook"
#include "n2f_curehurt_inc"

//
void main()
{
	if (!X2PreSpellCastCode())
		return;


	n2f_spellsCure(4, 4, 0, VFX_IMP_HEALING_S, VFX_IMP_SUNSTRIKE, GetSpellId());
}
