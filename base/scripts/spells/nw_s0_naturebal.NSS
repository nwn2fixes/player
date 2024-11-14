//::///////////////////////////////////////////////
//:: Natures Balance
//:: NW_S0_NatureBal.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
	Reduces the SR of all enemies by 1d4 per 5 caster
	levels for 1 round per 3 caster levels. Also heals
	all friends for 3d8 + Caster Level
	Radius is 15 feet from the caster.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: June 22, 2001
//:://////////////////////////////////////////////
//:: VFX Pass By: Preston W, On: June 22, 2001
// 2024 nov 13 kevL - do NOT alter nCasterLevel inside the STANDARDHOSTILE loop
//                  - refactor

#include "X0_I0_SPELLS"
#include "x2_inc_spellhook"

void main()
{

/*	Spellcast Hook Code
	Added 2003-06-20 by Georg
	If you want to make changes to all spells,
	check x2_inc_spellhook.nss to find out more */
	if (!X2PreSpellCastCode())
	{
		// If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
		return;
	}
	// End of Spell Cast Hook


	object oCaster = OBJECT_SELF;

	int nCasterLevel = GetCasterLevel(oCaster);
	int nMetaMagic = GetMetaMagicFeat();

	int nDuration = nCasterLevel / 3;
	if (nMetaMagic == METAMAGIC_EXTEND)
		nDuration *= 2;

	float fDuration = RoundsToSeconds(nDuration);

	location lCaster = GetLocation(oCaster);

	effect eNature = EffectVisualEffect(VFX_FNF_NATURES_BALANCE);
	ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eNature, lCaster);

	float fDelay; int nRand;

	effect eHeal, eSR, eLink;
	effect eVis = EffectVisualEffect(VFX_IMP_HEALING_L);
	effect eVis2 = EffectVisualEffect(VFX_IMP_BREACH);
	effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);


	object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, lCaster);
	while (GetIsObjectValid(oTarget))
	{
		fDelay = GetRandomDelay();

		if (spellsIsTarget(oTarget, SPELL_TARGET_ALLALLIES, oCaster))
		{
			SignalEvent(oTarget, EventSpellCastAt(oCaster, SPELL_NATURES_BALANCE, FALSE));

			nRand = d8(3) + nCasterLevel;

			if (nMetaMagic == METAMAGIC_MAXIMIZE)
			{
				nRand = 24 + nCasterLevel;
			}
			else if (nMetaMagic == METAMAGIC_EMPOWER)
			{
				nRand += nRand / 2;
			}

			eHeal = EffectHeal(nRand);

			DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, oTarget));
			DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
		}
		else if (spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster))
		{
			SignalEvent(oTarget, EventSpellCastAt(oCaster, SPELL_NATURES_BALANCE));

			if (!GetIsReactionTypeFriendly(oTarget)
				&& !MySavingThrow(SAVING_THROW_WILL, oTarget, GetSpellSaveDC()))
			{
				nRand = nCasterLevel / 5; // Nwn2Fix: do NOT change the value of nCasterLevel here (use nRand variable instead)
				if (nRand == 0)
					nRand = 1;

				nRand = d4(nRand);

				if (nMetaMagic == METAMAGIC_MAXIMIZE)
				{
					nRand = 4 * nCasterLevel;
				}
				else if (nMetaMagic == METAMAGIC_EMPOWER)
				{
					nRand += nRand / 2;
				}

				eSR = EffectSpellResistanceDecrease(nRand);
				eLink = EffectLinkEffects(eSR, eDur);

				DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, fDuration));
				DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, oTarget));
			}
		}
		oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, lCaster);
	}
}
