//::///////////////////////////////////////////////
//:: Rejuvination Cocoon
//:: 'nw_s0_rejuvcocoon'
//:: Copyright (c) 2006 Obsidian Entertainment
//:://////////////////////////////////////////////
/*
	When you cast the spell, the rejuvination cocoon forms
	around the subject.  While inside the cocoon, the subject
	cannot move or act in any way.

	The cocoon heals the subject every second, restoring a
	number of hit points equal to the caster's level (maximum
	of 15/second). It also immediately purges the subject of
	poison and disease effects, and makes the subject immune to
	similar effects for the duration.

	While enveloped in the cocoon, the subject has DR 10/-. Once
	the damage reduction has absorbed damage equal to 10 per caster
	level, the cocoon is the destroyed. Such destruction halts any
	health and protective effects offered by the cocoon.
*/
//:://////////////////////////////////////////////
//:: Created By: Patrick Mills
//:: Created On: Oct 20, 2006
//:://////////////////////////////////////////////
// kevL 2023 nov 27 - tidy and refactor
//                  - recompile with fixed RemoveEffectOfType()

#include "x2_inc_spellhook"
#include "x2_i0_spells"

//
void main()
{
	if (!X2PreSpellCastCode())
		return;


	object oTarget = GetSpellTargetObject();
	if (GetIsObjectValid(oTarget) && GetObjectType(oTarget) == OBJECT_TYPE_CREATURE)
	{
		object oCaster = OBJECT_SELF;
		if (spellsIsTarget(oTarget, SPELL_TARGET_ALLALLIES, oCaster))
		{
			RemoveEffectOfType(oTarget, EFFECT_TYPE_POISON);
			RemoveEffectOfType(oTarget, EFFECT_TYPE_DISEASE);

			int iCasterlevel = GetCasterLevel(oCaster);

			int iDRLimit = iCasterlevel * 10;

			if (iCasterlevel > 15) iCasterlevel = 15;

			effect ePoisonImmune  = EffectImmunity(IMMUNITY_TYPE_POISON);
			effect eDiseaseImmune = EffectImmunity(IMMUNITY_TYPE_DISEASE);
			effect eVis           = EffectVisualEffect(VFX_SPELL_DUR_COCOON);
			effect eImmobile      = EffectCutsceneImmobilize();
			effect eDR            = EffectDamageReduction(10, 0, iDRLimit, DR_TYPE_NONE);
			effect eRegen         = EffectRegenerate(iCasterlevel, 1.0);
			effect eFailure       = EffectSpellFailure(100);

			effect eDuration = EffectLinkEffects(ePoisonImmune, eDiseaseImmune);
				   eDuration = EffectLinkEffects(eDuration, eVis);
				   eDuration = EffectLinkEffects(eDuration, eImmobile);
				   eDuration = EffectLinkEffects(eDuration, eDR);
				   eDuration = EffectLinkEffects(eDuration, eRegen);
				   eDuration = EffectLinkEffects(eDuration, eFailure);

			float fDuration = ApplyMetamagicDurationMods(12.0);
			ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDuration, oTarget, fDuration);
		}
	}
}
