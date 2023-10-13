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
	if (iBonus > 25) iBonus = 25; // Akhacha_fix: raise bonus cap from 20 to 25 per 3.5e PnP

	effect eVishurt = EffectVisualEffect(VFX_HIT_SPELL_INFLICT_2);
	effect eVisheal = EffectVisualEffect(VFX_IMP_HEALING_M);

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

				iNegative = ApplyMetamagicVariableMods(d8(), 8) + iBonus; // kL_fix: the constant bonus should not be modified

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
				iNegative = ApplyMetamagicVariableMods(d8(), 8) + iBonus; // kL_fix: the constant bonus should not be modified
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
