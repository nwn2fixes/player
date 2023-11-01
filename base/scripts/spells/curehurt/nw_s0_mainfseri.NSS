//::///////////////////////////////////////////////
//:: Mass Inflict Serious Wounds
//:: 'nw_s0_mainfseri'
//:://////////////////////////////////////////////
/*
	Caster Level(s): Cleric 7
	Innate Level: 7
	School: Necromancy
	Descriptor(s):
	Component(s): Verbal, Somatic
	Range: Short
	Area of Effect/Target: One creature / level
	Duration: Instantaneous
	Save: Will half
	Spell Resistance: Yes

	This spell deals 3d8 points of negative energy damage +1 point per caster
	level (maximum +35) to one hostile creature per caster level. The effect is
	centered on you, and affects targets in order of their distance from you.
	This spell can be spontaneously cast.
*/
//:://////////////////////////////////////////////
//:: Created By: Jesse Reynolds (JLR - OEI)
//:: Created On: August 01, 2005
//:://////////////////////////////////////////////
//:: VFX Pass By: Preston W, On: June 20, 2001
//:: Update Pass By: Preston W, On: July 25, 2001
//:://////////////////////////////////////////////
// JLR - OEI 08/23/05 - metamagic changes
// Akhacha 2023/09/21 - limit count of creatures affected
// kevL 2023 oct 12 - tidy and refactor
//                  - change description at the top of this script to that in Dialog.Tlk #113202
//                  - do not Empower the constant bonus
//                  - remove the early return that stopped the loop when a non-allied
//                    undead is found
//                  - remove unused GetMetaMagicFeat()
//                  - change VFX_IMP_HEALING_G (critical) to VFX_IMP_HEALING_X (serious)
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
	if (_iBonus > 35) _iBonus = 35;

	_iDice = 3;

	_eVishurt = EffectVisualEffect(VFX_HIT_SPELL_INFLICT_4);
	_eVisheal = EffectVisualEffect(VFX_IMP_HEALING_X); // kL_fix

	n2f_MassInflict(iCount);
}
