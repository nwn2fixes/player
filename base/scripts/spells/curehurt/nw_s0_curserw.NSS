//::///////////////////////////////////////////////
//:: Cure Serious Wounds
//:: 'nw_s0_curserw'
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
	Caster Level(s): Bard 3, Cleric 3, Druid 4, Paladin 4, Ranger 4, Healing 2
	Innate Level: 4
	School: Conjuration
	Descriptor(s):
	Component(s): Verbal, Somatic
	Range: Touch
	Area of Effect / Target: Single
	Duration: Instant
	Save: Will 1/2
	Spell Resistance: Yes

	The target creature is healed for 3d8 points of damage, +1 point per caster
	level (to a maximum of +15). Healing spells have a reverse effect on undead,
	harming instead of healing them. A successful touch attack must first be
	made when this spell is used against undead.
*/
//:://////////////////////////////////////////////
//:: Created By: Noel Borstad
//:: Created On: Oct 18, 2000
//:://////////////////////////////////////////////
//:: Update Pass By: Preston W, On: July 25, 2001
// kevL 2023 nov 30 - do not Empower the constant bonus
//                  - change description at the top of this script to that in Dialog.Tlk #6131
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


	n2f_spellsCure(d8(3), 24, 15, VFX_IMP_HEALING_X, VFX_IMP_SUNSTRIKE, GetSpellId());
}
