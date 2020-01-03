//:://///////////////////////////////////////////////
//:: Level 8 Arcane Spell: Iron Body
//:: nw_s0_ironbody.nss
//:: Copyright (c) 2005 Obsidian Entertainment Inc.
//::////////////////////////////////////////////////
//:: Created By: Brock Heinz
//:: Created On: 08/15/05
//::////////////////////////////////////////////////
/*
        5.1.8.3.1	Iron Body
        PHB pg. 245
        School:		    Transmutation
        Components: 	Verbal, Somatic
        Range:		    Personal
        Target:		    You
        Duration:		1 minute / level

        You gain damage reduction 15/adamantine and a +6 enhancement bonus to Strength, 
        but you take a -6 penalty to Dexterity. You move at half speed. You have a 50% 
        arcane failure chance and a -8 armor check penalty. You are also immune to blindness, 
        critical hits, ability score damage, deafness, disease, electricity, poison, and stunning. 
        You take only half damage from acid and fire of all kinds.
        [Art] Same as Stone Body except with gray skin and hopefully iron textures.

*/


// JLR - OEI 08/24/05 -- Metamagic changes
#include "nwn2_inc_spells"

#include "x2_inc_spellhook" 

void main()
{

    if (!X2PreSpellCastCode())
    {
    	// If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

	object oPC 			= OBJECT_SELF;
    object oTarget      = GetSpellTargetObject(); // should be the caster
    int nCasterLevel    = GetCasterLevel(oPC);
    float fDuration     = 60.0*nCasterLevel; // seconds  (1 min per level)

    //Fire cast spell at event for the specified target
    SignalEvent(oTarget, EventSpellCastAt(oPC, SPELL_STONE_BODY, FALSE));

    fDuration = ApplyMetamagicDurationMods(fDuration);
    int nDurType = ApplyMetamagicDurationTypeMods(DURATION_TYPE_TEMPORARY);
	
	//Adding a check to make sure that the player's dex is never reduced to 0.
	int nDex = GetAbilityScore (oTarget, ABILITY_DEXTERITY);
	int nDexMod;
	
	if (nDex <= 6)
	{
		nDexMod = nDex - 1;
	}
	else
	{
		nDexMod = 6;
	}

    //effect eVisTemp     = EffectVisualEffect(VFX_HIT_SPELL_TRANSMUTATION);
    effect eStone       = EffectDamageReduction(15, GMATERIAL_METAL_ADAMANTINE, 0, DR_TYPE_GMATERIAL);	// JLR-OEI 02/14/06: NWN2 3.5 -- New Damage Reduction Rules
    //effect eVis         = EffectVisualEffect(VFX_DUR_PROT_STONESKIN);
    effect eDur         = EffectVisualEffect( VFX_DUR_SPELL_IRON_BODY );
    effect eStrIncr     = EffectAbilityIncrease( ABILITY_STRENGTH, 6 );	
    effect eDexDecr     = EffectAbilityDecrease( ABILITY_DEXTERITY, nDexMod );
    effect eMovDecr     = EffectMovementSpeedDecrease( 50 );
    effect eSpellFail   = EffectArcaneSpellFailure( 50 );	// AFW-OEI 10/19/2006: Use ASF instead of Spell Failure

    effect eArmorCheck  = EffectArmorCheckPenaltyIncrease( oTarget, 8 ); 

    effect eBlindI      = EffectImmunity( IMMUNITY_TYPE_BLINDNESS );
    effect eCritI       = EffectImmunity( IMMUNITY_TYPE_CRITICAL_HIT );
    effect eStatDecI    = EffectImmunity( IMMUNITY_TYPE_ABILITY_DECREASE );
    effect eDeafI       = EffectImmunity( IMMUNITY_TYPE_DEAFNESS );
    effect eDiseaseI    = EffectImmunity( IMMUNITY_TYPE_DISEASE );
    effect eElectricI   = EffectDamageResistance( DAMAGE_TYPE_ELECTRICAL, 9999 );  
    effect ePoison      = EffectImmunity( IMMUNITY_TYPE_POISON );
    effect eStunI       = EffectImmunity( IMMUNITY_TYPE_STUN );
    effect eFireI       = EffectDamageImmunityIncrease( DAMAGE_TYPE_FIRE, 50 ); 
    effect eAcidI       = EffectDamageImmunityIncrease( DAMAGE_TYPE_ACID, 50 ); 
	effect eDrown		= EffectSpellImmunity( 281 );//Immunity to the water elemental pulse drown ability
	effect eDrown2		= EffectSpellImmunity( 437 );//immunity to the drown spell


    // Link the effects together
    effect eLink = EffectLinkEffects(eDur, eStone);
    //eLink = EffectLinkEffects(eLink, eDur);
    eLink = EffectLinkEffects(eLink, eStrIncr);
    eLink = EffectLinkEffects(eLink, eDexDecr);
    eLink = EffectLinkEffects(eLink, eMovDecr);
    eLink = EffectLinkEffects(eLink, eSpellFail);
    eLink = EffectLinkEffects(eLink, eArmorCheck);
    eLink = EffectLinkEffects(eLink, eBlindI);
    eLink = EffectLinkEffects(eLink, eCritI);
    eLink = EffectLinkEffects(eLink, eStatDecI);
    eLink = EffectLinkEffects(eLink, eDeafI);
    eLink = EffectLinkEffects(eLink, eDiseaseI);
    eLink = EffectLinkEffects(eLink, eElectricI);
    eLink = EffectLinkEffects(eLink, ePoison);
    eLink = EffectLinkEffects(eLink, eStunI);
    eLink = EffectLinkEffects(eLink, eFireI);
    eLink = EffectLinkEffects(eLink, eAcidI);
	eLink = EffectLinkEffects(eLink, eDrown);
	eLink = EffectLinkEffects(eLink, eDrown2);


    //Apply the effects
    //ApplyEffectToObject(DURATION_TYPE_INSTANT, eVisTemp, oTarget);

    ApplyEffectToObject(nDurType, eLink, oTarget, fDuration );

}