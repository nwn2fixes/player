//::///////////////////////////////////////////////
//:: Mass Inflict Light Wounds
//:: 'nw_s0_mainfligt'
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
/*
	Caster Level(s): Cleric 5
	Innate Level: 5
	School: Necromancy
	Descriptor(s): Negative
	Component(s): Verbal, Somatic
	Range: Medium
	Area of Effect / Target: Huge
	Duration: Instant
	Save: Fortitude 1/2
	Spell Resistance: Yes

	All enemies within the area of effect are struck with negative energy that
	causes 1d8 points of damage, +1 point per caster level. Negative energy
	spells have a reverse effect on undead, healing them instead of harming
	them.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk and Keith Soleski
//:: Created On: Jan 31, 2001
//:://////////////////////////////////////////////
//:: VFX Pass By: Preston W, On: June 20, 2001
//:: Update Pass By: Preston W, On: July 25, 2001
//:://////////////////////////////////////////////
// Updated JLR - OEI 08/01/05 NWN2 3.5 - metamagic cleanup and name change
// JLR - OEI 08/23/05 - metamagic changes
//:://////////////////////////////////////////////
//:: Modified By: Brian Fox
//:: Modified On: 9/05/06
/*
	Added a spellsIsTarget check to the undead target case to make sure that
	non-allied undead do not receive healing effects.
*/
//:://////////////////////////////////////////////
// Akhacha 2023/09/21 - limit count of creatures affected
//                    - raise bonus cap to from +20 to +25 per 3.5e PnP description
// kevL 2023 oct 12 - tidy and refactor
//                  - change description at the top of this script to that in Dialog.Tlk #6115
//                  - do not Empower the constant bonus
//                  - remove the early return that stopped the loop when a non-allied
//                    undead is found
//                  - remove unused GetMetaMagicFeat()
//                  - apply VFX at spell location
//                  - #include "n2f_curehurt_inc"

#include "x2_inc_spellhook"
#include "n2f_curehurt_inc"

//
void main()
{
	if (!X2PreSpellCastCode())
		return;


	int iCount = GetCasterLevel(_oCaster = OBJECT_SELF); // Akhacha_fix: track the count of affected creatures

	_iBonus = iCount;
	if (_iBonus > 25) _iBonus = 25; // Akhacha_fix: raise bonus cap from 20 to 25 per 3.5e PnP

	_iDice = 1;

	_eVisinfl = EffectVisualEffect(VFX_HIT_SPELL_INFLICT_2);
	_eVisheal = EffectVisualEffect(VFX_IMP_HEALING_M);

	n2f_MassInflict(iCount);
}
