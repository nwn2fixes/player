//::///////////////////////////////////////////////
//:: Bolt: Dominated
//:: NW_S1_BltDomn
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
	Creature must make a ranged touch attack to hit
	the intended target.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 11 , 2001
//:: Updated On: July 15, 2003 Georg Zoeller - Removed saving throws
//:://////////////////////////////////////////////
// kevL 20.02.25 - refactor and cut unused chaff

#include "nw_i0_spells"

void main()
{
	object oTarget = GetSpellTargetObject();

	SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_BOLT_DOMINATE));

	if (TouchAttackRanged(oTarget)) // kL_signal the event and do the touch attack first.
	{
		effect eBolt = EffectDominated();
		eBolt = GetScaledEffect(eBolt, oTarget);

		effect eVis2 = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DOMINATED);
		effect eDur  = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
		effect eLink = EffectLinkEffects(eBolt, eDur);
		eLink = EffectLinkEffects(eLink, eVis2);

		int nHD = GetHitDice(OBJECT_SELF);
//		int nDC = 10 + (nHD/2); // kL_removed.
		int nCount = (nHD + 1) / 2;
		nCount = GetScaledDuration(nCount, oTarget);

		ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(nCount));

		effect eVis = EffectVisualEffect(VFX_IMP_DOMINATE_S);
		ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
	}
}
