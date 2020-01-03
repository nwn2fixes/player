//::///////////////////////////////////////////////
//:: Death Ward, Mass
//:: NX_s0_massdeaward.nss
//:: Copyright (c) 2007 Obsidian Entertainment
//:://////////////////////////////////////////////
/*
	Death Ward, Mass
	Necromancy
	Level: Cleric 8, druid 9
	Components: V, S
	Range: Close
	Duration: 1 minute/level
	Targets: One creature/level within 30ft of initial target
	 
	Subjects are immune to all death spells, magical 
	death effects, energy drain, and any negative energy effects.
*/
//:://////////////////////////////////////////////
//:: Created By: Patrick Mills
//:: Created On: 11.30.06
//:://////////////////////////////////////////////
//:: Updates to scripts go here.

#include "nw_i0_spells" 
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

	//Declare major variables
	location lTarget = GetSpellTargetLocation();
	object oCaster = OBJECT_SELF;
	float fDuration = TurnsToSeconds(GetCasterLevel(oCaster));
	effect eDeath = EffectImmunity(IMMUNITY_TYPE_DEATH);
    effect eNeg = EffectDamageResistance(DAMAGE_TYPE_NEGATIVE, 9999);
    effect eLevel = EffectImmunity(IMMUNITY_TYPE_NEGATIVE_LEVEL);
    effect eAbil = EffectImmunity(IMMUNITY_TYPE_ABILITY_DECREASE);
	effect eDur = EffectVisualEffect( VFX_DUR_SPELL_DEATH_WARD );
    effect eLink = EffectLinkEffects(eDeath, eDur);
    eLink = EffectLinkEffects(eLink, eNeg);
    eLink = EffectLinkEffects(eLink, eLevel);
    eLink = EffectLinkEffects(eLink, eAbil);
	
	//Enter Metamagic conditions
    fDuration = ApplyMetamagicDurationMods(fDuration);
    int nDurType = ApplyMetamagicDurationTypeMods(DURATION_TYPE_TEMPORARY);
	object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_HUGE, lTarget, TRUE, OBJECT_TYPE_CREATURE);
	while (GetIsObjectValid(oTarget))
	{
		if (spellsIsTarget(oTarget, SPELL_TARGET_ALLALLIES, oCaster))
		{
			//Signal spell cast at event
			SignalEvent(oTarget, EventSpellCastAt(oCaster, 1018, FALSE));
			
			//if (!MyResistSpell(oCaster, oTarget))
			{
				//disease resistance and saves are handled by the EffectDisease function automatically
				effect eHit = EffectVisualEffect( VFX_DUR_SPELL_DEATH_WARD );
				ApplyEffectToObject(nDurType, eLink, oTarget, fDuration);
			}
		}
		//find my next victim
		oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_HUGE, lTarget, TRUE, OBJECT_TYPE_CREATURE);
	}
}