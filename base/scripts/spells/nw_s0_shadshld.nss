//::///////////////////////////////////////////////
//:: Shadow Shield
//:: NW_S0_ShadShld.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Grants the caster +5 AC and 10 / +3 Damage
    Reduction and immunity to death effects
    and negative energy damage for 3 Turns per level.
    Makes the caster immune Necromancy Spells  
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 22, 2001
//:://////////////////////////////////////////////

#include "x2_inc_spellhook" 

void main()
{

/* 
  Spellcast Hook Code 
  Added 2003-06-23 by GeorgZ
  If you want to make changes to all spells,
  check x2_inc_spellhook.nss to find out more
  
*/

    if (!X2PreSpellCastCode())
    {
	// If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

// End of Spell Cast Hook


    //Declare major variables
	object oPC = OBJECT_SELF;
    object oTarget = GetSpellTargetObject();
    int nDuration = GetCasterLevel(oPC);
    int nMetaMagic = GetMetaMagicFeat();
    //Do metamagic extend check
	if (nMetaMagic == METAMAGIC_EXTEND)
    {
	   nDuration *= 2;	//Duration is +100%
    }
    //effect eStone = EffectDamageReduction(10, DAMAGE_POWER_PLUS_THREE);	// 3.0 DR rules
    effect eStone = EffectDamageReduction( 10, GMATERIAL_METAL_ADAMANTINE, 0, DR_TYPE_GMATERIAL );	// 3.5 DR approximation
    effect eAC = EffectACIncrease(5, AC_NATURAL_BONUS);
    effect eShadow = EffectVisualEffect(VFX_DUR_PROT_SHADOW_ARMOR);
    effect eSpell = EffectSpellLevelAbsorption(9, 0, SPELL_SCHOOL_NECROMANCY);
    effect eImmDeath = EffectImmunity(IMMUNITY_TYPE_DEATH);
    effect eImmNeg = EffectDamageResistance(DAMAGE_TYPE_NEGATIVE, 9999);
    //effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    //Link major effects
    effect eLink = EffectLinkEffects(eStone, eAC);
    eLink = EffectLinkEffects(eLink, eShadow);
    eLink = EffectLinkEffects(eLink, eImmDeath);
    eLink = EffectLinkEffects(eLink, eImmNeg);
    eLink = EffectLinkEffects(eLink, eSpell);
    //eLink = EffectLinkEffects(eLink, eDur);

	effect eHit = EffectVisualEffect(VFX_HIT_SPELL_EVIL);

    //Fire cast spell at event for the specified target
    SignalEvent(oTarget, EventSpellCastAt(oPC, SPELL_SHADOW_SHIELD, FALSE));
    //Apply linked effect
	ApplyEffectToObject(DURATION_TYPE_INSTANT, eHit, oTarget);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, TurnsToSeconds(nDuration));
}