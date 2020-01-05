//::///////////////////////////////////////////////
//:: Immunity to Fire
//:: nx_s2_immunityfire.nss
//:: Copyright (c) 2007 Obsidian Entertainment, Inc.
//:://////////////////////////////////////////////
/*
    
*/
//:://////////////////////////////////////////////
//:: Created By: Justin Reynard (AFW-OEI)
//:: Created On: 09/16/2008
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
        effect eImmune = EffectDamageResistance(DAMAGE_TYPE_FIRE, 9999);
        eImmune = ExtraordinaryEffect(eImmune); // Make it not dispellable.
    
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, GetSpellId(), FALSE));
    
        //Apply the effects
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eImmune, oTarget);
    }
}