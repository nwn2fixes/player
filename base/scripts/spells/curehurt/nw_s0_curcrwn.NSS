//::///////////////////////////////////////////////
//:: Cure Critical Wounds
//:: 'nw_s0_curcrwn'
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
	Caster Level(s): Bard 4, Cleric 4, Druid 5
	Innate Level: 4
	School: Conjuration
	Descriptor(s):
	Component(s): Verbal, Somatic
	Range: Touch
	Area of Effect / Target: Single
	Duration: Instant
	Save: Will 1/2
	Spell Resistance: Yes

	The target creature is healed of 4d8 points of damage, + 1 point per caster
	level to a maximum of +20. Healing spells have a reverse effect when used on
	undead, causing the targeted undead to take an amount of damage equal to
	what the spell normally heals. A successful touch attack must first be made
	when this spell is used against undead.
*/
//:://////////////////////////////////////////////
//:: Created By: Noel Borstad
//:: Created On: Oct 18, 2000
//:://////////////////////////////////////////////
//:: VFX Pass By: Preston W, On: June 20, 2001
//:: Update Pass By: Preston W, On: July 26, 2001
// kevL 2023 nov 30 - do not Empower the constant bonus
//                  - change description at the top of this script to that in Dialog.Tlk #6127
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


	n2f_spellsCure(d8(4), 32, 20, VFX_IMP_HEALING_G, VFX_IMP_SUNSTRIKE, GetSpellId());
}
