//::///////////////////////////////////////////////
//:: Death Ward
//:: NW_S0_DeaWard.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    The target creature is protected from the instant
    death effects for the duration of the spell
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: July 27, 2001
//:://////////////////////////////////////////////
//:: Update Pass By: Preston W, On: July 27, 2001

// (Updated JLR - OEI 07/11/05 NWN2 3.5)


// JLR - OEI 08/24/05 -- Metamagic changes
#include "nwn2_inc_spells"

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
    object oTarget = GetSpellTargetObject();
    effect eDeath = EffectImmunity(IMMUNITY_TYPE_DEATH);
    // JLR - OEI NWN2 3.5 Update: Merged from Negative Energy Protection
    effect eNeg = EffectDamageResistance(DAMAGE_TYPE_NEGATIVE, 9999);
    effect eLevel = EffectImmunity(IMMUNITY_TYPE_NEGATIVE_LEVEL);
    effect eAbil = EffectImmunity(IMMUNITY_TYPE_ABILITY_DECREASE);
    //effect eVis = EffectVisualEffect(VFX_IMP_DEATH_WARD);	// no longer using NWN1 VFX
	//effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);	// NWN1 VFX
	effect eDur = EffectVisualEffect( VFX_DUR_SPELL_DEATH_WARD );	// NWN2 VFX
    effect eLink = EffectLinkEffects(eDeath, eDur);
    eLink = EffectLinkEffects(eLink, eNeg);
    eLink = EffectLinkEffects(eLink, eLevel);
    eLink = EffectLinkEffects(eLink, eAbil);

	object oPC  = OBJECT_SELF;
    float fDuration = HoursToSeconds(GetCasterLevel(oPC));

    //Fire cast spell at event for the specified target
    SignalEvent(oTarget, EventSpellCastAt(oPC, SPELL_DEATH_WARD, FALSE));

    //Enter Metamagic conditions
    fDuration = ApplyMetamagicDurationMods(fDuration);
    int nDurType = ApplyMetamagicDurationTypeMods(DURATION_TYPE_TEMPORARY);

    //Apply VFX impact and death immunity effect
    ApplyEffectToObject(nDurType, eLink, oTarget, fDuration);
    //ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);	// NWN1 VFX
}