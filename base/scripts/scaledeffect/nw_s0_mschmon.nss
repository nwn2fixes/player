//:://///////////////////////////////////////////////////
//:: Level 8 Arcane Spell: Mass Charm Monster
//:: nw_s0_mschmon.nss
//:: Created By: Brock Heinz - OEI
//:: Created On: 08/29/05
//:: Copyright (c) 2005 Obsidian Entertainment Inc.
//:://///////////////////////////////////////////////////
/*
    The caster attempts to charm a group of individuals
    who's HD can be no more than his level combined.
    The spell starts checking the area and those that
    fail a will save are charmed.  The affected persons
    are Charmed for 1 round per 2 caster levels.
*/
//:://///////////////////////////////////////////////////
// 11/09/06 - BDF(OEI): added GetScaledEffect() to modify final effect; same as all other charm spells
// AFW-OEI 05/22/2007: Use total character levels if using the racial version.

#include "X0_I0_SPELLS"
#include "x2_inc_spellhook" 

void main()
{

    if (!X2PreSpellCastCode())
    {
		// If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }


    object oTarget;
    effect eCharm = EffectCharmed();

    effect eVis = EffectVisualEffect(VFX_DUR_SPELL_CHARM_MONSTER);
    int nMetaMagic = GetMetaMagicFeat();
    int nCasterLevel = GetCasterLevel(OBJECT_SELF);
	
	if (GetSpellId() == SPELLABILITY_MASS_CHARM_MONSTER)
	{	// If using the racial version, use total HD for caster level.
		nCasterLevel = GetHitDice(OBJECT_SELF);
	}
	
    int nDuration = nCasterLevel/2;
    int nHD = nCasterLevel;
    int nCnt = 0;
    int nRacial;
    float fDelay;
    int nAmount = nHD * 2;
    //Check for metamagic extend
    if (nMetaMagic == METAMAGIC_EXTEND)
    {
        nDuration = nCasterLevel;
    }

    oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, GetSpellTargetLocation());
    while (GetIsObjectValid(oTarget) && nAmount > 0)
    {
        if (spellsIsTarget(oTarget, SPELL_TARGET_SELECTIVEHOSTILE, OBJECT_SELF))
    	{
            //nRacial = GetRacialType(oTarget);	// the target can be any creature; this check is not relevant
            //Check that the target is humanoid or animal
            {
                //SpeakString(IntToString(nAmount) + " and HD of " + IntToString(GetHitDice(oTarget)));
                if(nAmount >= GetHitDice(oTarget))
                {
                    //Fire cast spell at event for the specified target
                    SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELL_MASS_CHARM, FALSE));
                    //Make an SR check
                    if (!MyResistSpell(OBJECT_SELF, oTarget))
                	{
                        //Make a Will save to negate
                        if (!MySavingThrow(SAVING_THROW_WILL, oTarget, GetSpellSaveDC(), SAVING_THROW_TYPE_MIND_SPELLS))
                        {
							eCharm = GetScaledEffect( EffectCharmed(), oTarget );	// 11/09/06 - BDF(OEI): this line was missing, causing PCs to get charmed
                            //Apply the linked effects and the VFX impact
                            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eCharm, oTarget, RoundsToSeconds(nDuration)));
                            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                        }
                    }
                    //Add the creatures HD to the count of affected creatures
                    //nCnt = nCnt + GetHitDice(oTarget);
                    nAmount = nAmount - GetHitDice(oTarget);
                }
            }
        }
        //Get next target in spell area
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, GetSpellTargetLocation());
    }
}