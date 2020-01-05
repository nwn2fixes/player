//::///////////////////////////////////////////////
//:: Immunity to Electricity
//:: nx_s2_immunityelectricity.nss
//:: Copyright (c) 2007 Obsidian Entertainment, Inc.
//:://////////////////////////////////////////////
/*
    At 9th level, a stormlord gains immunity to
    electricity.
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Woo (AFW-OEI)
//:: Created On: 03/21/2007
//:://////////////////////////////////////////////

#include "nwn2_inc_spells"
#include "x2_inc_spellhook"

void main()
{
    if (!X2PreSpellCastCode())
    {   // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }
    
    //Declare major variables
    object oTarget = GetSpellTargetObject();

    // Does not stack with itself
    if (!GetHasSpellEffect(GetSpellId(), oTarget))
    {
        effect eImmune = EffectDamageResistance(DAMAGE_TYPE_ELECTRICAL, 9999);
        eImmune = ExtraordinaryEffect(eImmune); // Make it not dispellable.
    
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, GetSpellId(), FALSE));
    
        //Apply the effects
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eImmune, oTarget);
    }
}