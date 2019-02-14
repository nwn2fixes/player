//::///////////////////////////////////////////////
//:: [Charm Person]
//:: [NW_S0_CharmPer.nss]
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
//:: Will save or the target is charmed for 1 round
//:: per caster level.
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 29, 2001
//:://////////////////////////////////////////////
//:: Last Updated By: Preston Watamaniuk, On: April 5, 2001
//:: Last Updated By: Preston Watamaniuk, On: April 10, 2001
//:: VFX Pass By: Preston W, On: June 20, 2001
//:: RPGplayer1 12/20/2008:
//::  Use total character level, for racial version
//::  Use charisma based DC, for racial version (per PnP)
//:: RPGplayer1 01/05/2009: Will affect all playable humanoids (Planetouched, Grey Orcs, Yuan-ti)

#include "x0_I0_SPELLS"    
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
    effect eVis = EffectVisualEffect(VFX_DUR_SPELL_CHARM_PERSON);
    effect eCharm = EffectCharmed();
    eCharm = GetScaledEffect(eCharm, oTarget);

    //Link persistant effects
    effect eLink = EffectLinkEffects(eVis, eCharm);

    int nMetaMagic = GetMetaMagicFeat();
    int nCasterLevel = GetCasterLevel(OBJECT_SELF);
    int nDC = GetSpellSaveDC();

	//Has same SpellId as Charm Person, not an item, but returns no valid class -> it's racial ability
	if (GetSpellId() == SPELL_CHARM_PERSON && !GetIsObjectValid(GetSpellCastItem()) && GetLastSpellCastClass() == CLASS_TYPE_INVALID)
	{
		nCasterLevel = GetHitDice(OBJECT_SELF);
		nDC = 10 + GetSpellLevel(SPELL_CHARM_PERSON) + GetAbilityModifier(ABILITY_CHARISMA);
	}

    int nDuration = 2 + nCasterLevel/3;
    nDuration = GetScaledDuration(nDuration, oTarget);
    int nRacial = GetRacialType(oTarget);
    //Make Metamagic check for extend
    if (nMetaMagic == METAMAGIC_EXTEND)
    {
        nDuration = nDuration * 2;
    }
	if (spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, OBJECT_SELF))
	{
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELL_CHARM_PERSON, FALSE));
        //Make SR Check
        if (!MyResistSpell(OBJECT_SELF, oTarget))
    	{
            //Verify that the Racial Type is humanoid
            if  (GetIsPlayableRacialType(oTarget) ||
                (nRacial == RACIAL_TYPE_HUMANOID_GOBLINOID) ||
                (nRacial == RACIAL_TYPE_HUMANOID_MONSTROUS) ||
                (nRacial == RACIAL_TYPE_HUMANOID_ORC) ||
                (nRacial == RACIAL_TYPE_HUMANOID_REPTILIAN))
            {
                //Make a Will Save check
                if (!MySavingThrow(SAVING_THROW_WILL, oTarget, nDC, SAVING_THROW_TYPE_MIND_SPELLS))
                {
                    //Apply impact and linked effects
                    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(nDuration));
                }
            }
         }
     }
}