//:://///////////////////////////////////////////////
//:: Warlock Lesser Invocation: Charm
//:: nw_s0_icharm.nss
//:: Copyright (c) 2005 Obsidian Entertainment Inc.
//::////////////////////////////////////////////////
//:: Created By: Brock Heinz
//:: Created On: 08/12/05
//::////////////////////////////////////////////////
/*
        Charm
        Complete Arcane, pg. 132
        Spell Level:	4
        Class: 		Misc

        You can beguile a creature within 60 feet. If the target fails a Will 
        save theysuffer the effects of the Charm Monster spell (4th level wizard) 
        except only one target can be affected at a given time.

        [Rules Note] In the rules this is a language dependent ability, but 
        there is no concept of languages in NWN2.
*/

#include "NW_I0_SPELLS"    
#include "x2_inc_spellhook" 

void main()
{

    if (!X2PreSpellCastCode())
    {
	// If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }



    //Declare major variables
    object oTarget  = GetSpellTargetObject();
    int nRacial     = GetRacialType(oTarget);
    effect eVis;     //= EffectVisualEffect(VFX_HIT_SPELL_ENCHANTMENT);
    effect eCharm   = GetScaledEffect( EffectCharmed(), oTarget);
    //effect eMind  = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_NEGATIVE);	// NWN1 VFX
    //effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);	// NWN1 VFX
	
	// The eVis VFX will depend on the racial type of oTarget
	if ( nRacial == RACIAL_TYPE_DWARF ||
		 nRacial == RACIAL_TYPE_ELF ||
		 nRacial == RACIAL_TYPE_GNOME ||
		 nRacial == RACIAL_TYPE_HALFELF ||
		 nRacial == RACIAL_TYPE_HALFLING ||
		 nRacial == RACIAL_TYPE_HALFORC ||
		 nRacial == RACIAL_TYPE_HUMAN ||
		 nRacial == RACIAL_TYPE_HUMANOID_GOBLINOID ||
		 nRacial == RACIAL_TYPE_HUMANOID_MONSTROUS ||
		 nRacial == RACIAL_TYPE_HUMANOID_ORC ||
		 nRacial == RACIAL_TYPE_HUMANOID_REPTILIAN )
	{
		eVis = EffectVisualEffect( VFX_DUR_SPELL_CHARM_PERSON );
	}
	else eVis = EffectVisualEffect( VFX_DUR_SPELL_CHARM_MONSTER );
		 
		 

    //Link effects
    effect eLink = EffectLinkEffects(eVis, eCharm);
    //eLink = EffectLinkEffects(eLink, eDur);	 // NWN1 VFX

    int nMetaMagic      = GetMetaMagicFeat();
    int nCasterLevel    = GetCasterLevel(OBJECT_SELF);
    int nDuration       = 3 + nCasterLevel/2;
    nDuration = GetScaledDuration(nDuration, oTarget);


    //Metamagic extend check
    if (nMetaMagic == METAMAGIC_EXTEND)
    {
        nDuration = nDuration * 2;
    }

	if (spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, OBJECT_SELF))
	{
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELL_CHARM_MONSTER, FALSE));
        // Make SR Check
        if (!MyResistSpell(OBJECT_SELF, oTarget))
    	{
            // Make Will save vs Mind-Affecting
            if (!/*Will Save*/ MySavingThrow(SAVING_THROW_WILL, oTarget, GetSpellSaveDC(), SAVING_THROW_TYPE_MIND_SPELLS))
            {
                //Apply impact and linked effect
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(nDuration));
                //ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget); 	// NWN1 VFX
            }
        }
    }

}