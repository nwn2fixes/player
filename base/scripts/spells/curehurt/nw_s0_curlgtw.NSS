//::///////////////////////////////////////////////
//:: Cure Light Wounds
//:: 'nw_s0_curlgtw'
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
	Caster Level(s): Bard 1, Cleric 1, Druid 1, Paladin 1, Ranger 1
	Innate Level: 1
	School: Conjuration
	Descriptor(s):
	Component(s): Verbal, Somatic
	Range: Touch
	Area of Effect / Target: Single
	Duration: Instant
	Save: Will 1/2
	Spell Resistance: Yes

	The target creature is healed for 1d8 points of damage, +1 point per caster
	level (to a maximum of +5). Healing spells have a reverse effect on undead,
	harming instead of healing them. A successful touch attack must first be
	made when this spell is used against undead.
*/
//:://////////////////////////////////////////////
//:: Created By: Brennon Holmes
//:: Created On: Oct 12, 2000
//:://////////////////////////////////////////////
//:: Update Pass By: Preston W, On: July 26, 2001
// kevL 2023 nov 30 - do not Empower the constant bonus
//                  - change description at the top of this script to that in Dialog.Tlk #6128
//                  - #include "n2f_curehurt_inc"
// kevL 2024 nov 28 - changed to add casterlevel bonus before metamagic
//                  - allow clerics with Healing Domain to auto-empower Maximized cures

// also used by #277 Lesser_Body_Adjustment

#include "x2_inc_spellhook"
#include "n2f_curehurt_inc"

//
void main()
{
	if (!X2PreSpellCastCode())
		return;


	n2f_spellsCure(d8(), 8, 5, VFX_IMP_HEALING_M, VFX_IMP_SUNSTRIKE, GetSpellId());
}
