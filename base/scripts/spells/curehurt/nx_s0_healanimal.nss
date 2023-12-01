//::///////////////////////////////////////////////
//:: Heal Animal Companion
//:: 'nx_s0_healanimal'
//:: Copyright (c) 2007 Obsidian Entertainment
//:://////////////////////////////////////////////
/*
	Caster Level(s): Druid 5, Ranger 3
	Innate Level: 5
	School: Conjuration
	Descriptor(s): Healing
	Component(s): Verbal, Somatic
	Range: Touch
	Area of Effect / Target: One animal companion touched
	Duration: Instant
	Save: Will negates (harmless)
	Spell Resistance: Yes (harmless)

	Heals an animal companion of 10 points per caster level (max 150) and
	removes any wounding effects.
*/
//:://////////////////////////////////////////////
//:: Created By: Patrick Mills
//:: Created On: 12.06.2006
//:://////////////////////////////////////////////
// ChazM 5/31/07 - updated to use HealHarmTarget() in nwn2_inc_spells
// kevL 2023 nov 25 - tidy and refactor
//                  - change description at the top of this script to that in Dialog.Tlk #184831
//                  - #include "n2f_curehurt_inc"
//                  - prevent this spell against potentially undead AnimalCompanions

#include "x2_inc_spellhook"
#include "n2f_curehurt_inc"

//
void main()
{
	if (!X2PreSpellCastCode())
		return;


	_oTarget = GetSpellTargetObject();
	if (GetIsObjectValid(_oTarget) && GetObjectType(_oTarget) == OBJECT_TYPE_CREATURE) // kL_safety
	{
		if (_oTarget == GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION)
			&& !GetLocalInt(_oTarget, VAR_IMMUNE_TO_HEAL) // abort for creatures immune to heal
			&& GetRacialType(_oTarget) != RACIAL_TYPE_UNDEAD) // kL_add
		{
			_iSpellId = SPELL_UNDEFINED; // script-vars will be determined later

			_oCaster = OBJECT_SELF;

			n2f_HealHarmTarget(TRUE);
		}
		else
			FloatingTextStrRefOnCreature(184683, OBJECT_SELF, FALSE); // "Target is immune to that effect."
	}
}
