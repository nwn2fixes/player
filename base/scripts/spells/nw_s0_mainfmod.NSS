//::///////////////////////////////////////////////
//:: Mass Inflict Moderate Wounds
//:: 'nw_s0_mainfmod'
//:://////////////////////////////////////////////
/*
	Caster Level(s): Cleric 6
	Innate Level: 6
	School: Necromancy
	Descriptor(s):
	Component(s): Verbal, Somatic
	Range: Short
	Area of Effect/Target: One creature / level
	Duration: Instantaneous
	Save: Will 1/2
	Spell Resistance: Yes

	This spell deals 2d8 points of negative energy damage +1 point per caster
	level (maximum +30) to one hostile creature per caster level. The effect is
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
//                  - change description at the top of this script to that in Dialog.Tlk #113199
//                  - do not Empower the constant bonus
//                  - remove the early return that stopped the loop when a non-allied
//                    undead is found
//                  - remove unused GetMetaMagicFeat()
//                  - use a heal VFX for healing undead (not the inflict VFX)
//                  - apply VFX at spell location

#include "x2_inc_spellhook"
#include "nw_i0_spells"
#include "nwn2_inc_metmag"

//
void main()
{
	if (!X2PreSpellCastCode())
		return;


	location lSpell = GetSpellTargetLocation();

	effect eFnf = EffectVisualEffect(VFX_FNF_LOS_EVIL_10); // kL_fix: apply location VFX ->
	ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eFnf, lSpell);


	object oCaster = OBJECT_SELF;

	int iSpellId = GetSpellId();
	int iDc = GetSpellSaveDC();

	int iInflictable = GetCasterLevel(oCaster); // Akhacha_fix w/ kevL: track the count of affected creatures

	int iBonus = iInflictable;
	if (iBonus > 30) iBonus = 30;

	effect eVishurt = EffectVisualEffect(VFX_HIT_SPELL_INFLICT_3);
	effect eVisheal = EffectVisualEffect(VFX_IMP_HEALING_L);

	effect eHurt, eHeal;
	int iNegative; float fDelay;

	object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_MEDIUM, lSpell);
	while (GetIsObjectValid(oTarget) && iInflictable > 0)
	{
		if (GetRacialType(oTarget) == RACIAL_TYPE_UNDEAD) // if the target is an allied undead it is healed
		{
			if (spellsIsTarget(oTarget, SPELL_TARGET_ALLALLIES, oCaster))
			{
				SignalEvent(oTarget, EventSpellCastAt(oCaster, iSpellId, FALSE));

				--iInflictable;

				iNegative = ApplyMetamagicVariableMods(d8(2), 16) + iBonus; // kL_fix: the constant bonus should not be modified

				eHeal = EffectHeal(iNegative);
				eHeal = EffectLinkEffects(eHeal, eVisheal);

				DelayCommand(GetRandomDelay(), ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, oTarget));
			}
			else
			{
				FloatingTextStrRefOnCreature(184683, oCaster, FALSE); // "Target is immune to that effect."
				// kL_fix: do not return early here.
			}
		}
		else if (spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)) // hurts nonhostile on Hardcore+
		{
			SignalEvent(oTarget, EventSpellCastAt(oCaster, iSpellId));

			--iInflictable;

			fDelay = GetRandomDelay();
			if (MyResistSpell(oCaster, oTarget, fDelay) == SPELL_RESISTANCE_FAILURE)
			{
				iNegative = ApplyMetamagicVariableMods(d8(2), 16) + iBonus; // kL_fix: the constant bonus should not be modified
				if (MySavingThrow(SAVING_THROW_WILL,
								  oTarget,
								  iDc,
								  SAVING_THROW_TYPE_NEGATIVE,
								  oCaster,
								  fDelay) != SAVING_THROW_CHECK_FAILED)
				{
					iNegative /= 2;
				}

				if (iNegative > 0) // kL_add safety
				{
					eHurt = EffectDamage(iNegative, DAMAGE_TYPE_NEGATIVE);
					eHurt = EffectLinkEffects(eHurt, eVishurt);

					DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eHurt, oTarget));
				}
			}
		}
		oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_MEDIUM, lSpell);
	}
}
