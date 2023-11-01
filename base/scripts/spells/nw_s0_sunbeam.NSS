//::///////////////////////////////////////////////
//:: Sunbeam
//:: 'nw_s0_sunbeam'
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
	Caster Level(s): Cleric 8, Druid 7, Sun 7
	Innate Level: 8
	School: Evocation
	Descriptor(s):
	Component(s): Verbal, Somatic
	Range: Medium
	Area of Effect / Target: Colossal
	Duration: Instantaneous
	Save: Reflex Negates
	Spell Resistance: Yes

	You summon a globe of divine radiance to blind and burn those within the
	area of effect. Undead take 1d6 points of divine damage per caster level, to
	a maximum of 20d6. All other monster types take 3d6 points of divine damage,
	and are blinded for 3 rounds. A successful Reflex save halves the damage for
	undead and voids blindness for others.
*/
//:://////////////////////////////////////////////
//:: Created By: Keith Soleski
//:: Created On: Feb 22, 2001
//:://////////////////////////////////////////////
//:: Last Modified By: Keith Soleski, On: March 21, 2001
//:: VFX Pass By: Preston W, On: June 25, 2001
//:://////////////////////////////////////////////
// kevL 2023 oct 30 - tidy and refactor
//                  - change description at the top of this script to Dialog.Tlk #6515
//                  - fix 'iDice' for Maximize and use ApplyMetamagicVariableMods()
//                  - conform 'fDelay' for resist and the application of blindness
//                  - blindness affects nonundead only

#include "x2_inc_spellhook"
#include "nw_i0_spells"
#include "nwn2_inc_metmag"

//
void main()
{
	if (!X2PreSpellCastCode())
		return;


	object oCaster = OBJECT_SELF;

	effect eVisholy = EffectVisualEffect(VFX_HIT_SPELL_HOLY);

	effect eDivine;

	effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
	effect eBlind = EffectBlindness();
	eBlind = EffectLinkEffects(eBlind, eDur);

	int iDc = GetSpellSaveDC();
	int iDivine, iDivine0, iDice, bUndead;

	float fDur = RoundsToSeconds(3);
	float fDelay;

	int iCasterlevel= GetCasterLevel(oCaster);
	if (iCasterlevel > 20) iCasterlevel = 20;


	location lSpell = GetSpellTargetLocation();
	object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, lSpell);
	while (GetIsObjectValid(oTarget))
	{
		if (spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster))
		{
			SignalEvent(oTarget, EventSpellCastAt(oCaster, SPELL_SUNBEAM));

			fDelay = GetRandomDelay(1.f, 2.f);

			if (MyResistSpell(oCaster, oTarget, fDelay) == SPELL_RESISTANCE_FAILURE)
			{
				if (GetRacialType(oTarget) == RACIAL_TYPE_UNDEAD)
				{
					bUndead = TRUE;
					iDice = iCasterlevel;
				}
				else
				{
					bUndead = FALSE;
					iDice = 4; // 3.5e agrees (description is incorrect)
				}

				iDivine = ApplyMetamagicVariableMods(d6(iDice), iDice * 6);

				iDivine0 = iDivine;
				iDivine = GetReflexAdjustedDamage(iDivine, oTarget, iDc, SAVING_THROW_TYPE_DIVINE);
				if (iDivine > 0)
				{
					eDivine = EffectDamage(iDivine, DAMAGE_TYPE_DIVINE);
					eDivine = EffectLinkEffects(eDivine, eVisholy);

					DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDivine, oTarget));

					if (!bUndead // kL_add: description says that only nonundead get blinded
						&& (iDivine == iDivine0 || GetHasFeat(FEAT_IMPROVED_EVASION, oTarget)))
					{
						DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eBlind, oTarget, fDur));
					}
				}
			}
		}
		oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, lSpell);
	}
}
