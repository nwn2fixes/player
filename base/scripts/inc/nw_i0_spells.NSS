//::///////////////////////////////////////////////
//:: Spells Include
//:: NW_I0_SPELLS
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 2, 2002
//:: Updated By: 2003/20/10 Georg Zoeller
//:: Updated By: 6/21/06 BDF-OEI: updated to use NWN2 VFX
//:://////////////////////////////////////////////
// 8/9/06 - BDF-OEI: in spellsCure, added the GetSpellCastItem() check to the GetHasFeat() check to make sure that
// 	clerics with the healing domain power don't get a bonus when using a healin potion
// 8/28/06 - BDF-OEI: modified all the Remove*() functions to start back at the beginning of the effects list
// 	in the event that a desired effect is removed; this helps ensure that effects that are linked to other
// 	effects are removed safely
// ChazM 8/29/06 Fix compile error in RemoveSpellEffects()
// ChazM 8/29/06 moved spellsIsTarget() from x0_i0_spells.
// DBR 9/08/06 - Added override ability for spellsIsTarget() filter. Added the IgnoreTargetRules* functions.
// BDF 9/13/06 - Added a bail out to spellsIsTarget() for when the target is ScriptHidden
// BDF 9/19/06 - modified spellsIsTarget() to use GetCurrentMaster(), which accounts for companions (roster members)
// BDF 9/25/06 - Added a conditional to end of spellsIsTarget() to limit to damaging spells
// BDF 10/03/06 - Added a conditional to end of spellsIsTarget() to better enforce associate vs associate spell damage
// BDF 10/20/06 - modified spellsIsTarget to ignore the deprecated MODULE_SWITCH_ENABLE_MULTI_HENCH_AOE_DAMAGE check
//					which was disabling inter-party AOE spell damage; Hardcore difficulty is now aptly named;
//					also modified to only escape early when the target is the caster when game difficulty is lower
//					than hardcore; also made accommodations for companions to damage inter-party PC's (non-master)
//					in hardcore
// 10/23/06 - BDF(OEI): added GetIsReactionTypeHostile to the SELECTIVEHOSTILE case of spellsIsTarget since
//					GetIsEnemy may not capture all cases in game modes that don't use personal reputation (OC)
// DBR 11/09/06 - fixed minor logic error in RemoveProtections()
// 11/09/06 - BDF(OEI): modified spellsIsTarget to check for master object validity in the 1st and 3rd "Hardcore" checks;
//	in 1st check, NPC casters could hurt themselves and in the 3rd check, NPCs of non-hostile factions could damage each other.
//	In the 3rd check, one-to-one object comparison was insufficient since GetCurrentMaster() would return OBJECT_INVALID
//	for non-PC-party NPC targets and sources, causing the function to return TRUE even if they were non-hostile to one another.
// 	These changes may confound rules pundits, but the heart of the issue here is difficulty, not rules loyalty.
// ChazM 2/8/07 - modified spellsCure to observe IMMUNE_TO_HEAL local var
// ChazM 2/27/07 - split out GetIsStandardHostileTarget()
// ChazM 5/15/07 - Added new functions for unified Harming & Healing
// ChazM 6/7/07 - Added prototypes
// RPGplayer1 12/30/08 - Modified TrapDoElectricalDamage(), so that reaction check has proper arguments, and passes trap creator for crafted traps
// Aqvilinus 2019.feb.14 - GetScaledEffect() change negative args for effect-decreases to pos.

#include "x0_i0_match"
#include "x2_inc_switches"
#include "x2_inc_itemprop"
#include "x0_i0_petrify"
#include "x0_i0_assoc"

//=========================================================================
// * Constants
//=========================================================================
// * see spellsIsTarget for a definition of these constants
const int SPELL_TARGET_ALLALLIES = 1;
const int SPELL_TARGET_STANDARDHOSTILE = 2;
const int SPELL_TARGET_SELECTIVEHOSTILE = 3;
const int SAVING_THROW_NONE = 4;
// * used by the IgnoreTargetRules functions
const string ITR_NUM_ENTRIES = "ITR_NUM_ENTRIES"; //number of stored targets to ignore the check.
const string ITR_ENTRY_PREFIX = "ITR_TARGET_ENTRY"; //prefix for stored targets (ITR_TARGET_ENTRY1, ITR_TARGET_ENTRY15, etc)

// GZ: Number of spells in GetSpellBreachProtections
const int NW_I0_SPELLS_MAX_BREACH = 33;

const string VAR_IMMUNE_TO_HEAL = "IMMUNE_TO_HEAL";

 
//=========================================================================
// Prototypes
//=========================================================================

// * Generic reputation wrapper
// * definition of constants:
// * SPELL_TARGET_ALLALLIES = Will affect all allies, even those in my faction who don't like me
// * SPELL_TARGET_STANDARDHOSTILE: 90% of offensive area spells will work
//   this way. They will never hurt NEUTRAL or FRIENDLY NPCs.
//   They will never hurt FRIENDLY PCs
//   They WILL hurt NEUTRAL PCs
// * SPELL_TARGET_SELECTIVEHOSTILE: Will only ever hurt enemies
int spellsIsTarget(object oTarget, int nTargetType, object oSource);


// * Function for doing electrical traps
void TrapDoElectricalDamage(int ngDamageMaster, int nSaveDC, int nSecondary);

// * Used to route the resist magic checks into this function to check for spell countering by SR, Globes or Mantles.
//   Return value if oCaster or oTarget is an invalid object: FALSE
//   Return value if spell cast is not a player spell: - 1
//   Return value if spell resisted: 1
//   Return value if spell resisted via magic immunity: 2
//   Return value if spell resisted via spell absorption: 3
int MyResistSpell(object oCaster, object oTarget, float fDelay = 0.0);

// * Used to route the saving throws through this function to check for spell countering by a saving throw.
//   Returns: 0 if the saving throw roll failed
//   Returns: 1 if the saving throw roll succeeded
//   Returns: 2 if the target was immune to the save type specified
//   Note: If used within an Area of Effect Object Script (On Enter, OnExit, OnHeartbeat), you MUST pass
//   GetAreaOfEffectCreator() into oSaveVersus!!    \
int MySavingThrow(int nSavingThrow, object oTarget, int nDC, int nSaveType=SAVING_THROW_TYPE_NONE, object oSaveVersus = OBJECT_SELF, float fDelay = 0.0);

// * Will pass back a linked effect for all the protection from alignment spells.  The power represents the multiplier of strength.
// * That is instead of +3 AC and +2 Saves a  power of 2 will yield +6 AC and +4 Saves.
effect CreateProtectionFromAlignmentLink(int nAlignment, int nPower = 1);

// * Will pass back a linked effect for all of the doom effects.
effect CreateDoomEffectsLink();

// * Searchs through a persons effects and removes those from a particular spell by a particular caster.
void RemoveSpellEffects(int nSpell_ID, object oCaster, object oTarget);

// * Searchs through a persons effects and removes all those of a specific type.
void RemoveSpecificEffect(int nEffectTypeID, object oTarget);

// * Returns the time in seconds that the effect should be delayed before application.
float GetSpellEffectDelay(location SpellTargetLocation, object oTarget);

// * This allows the application of a random delay to effects based on time parameters passed in.  Min default = 0.4, Max default = 1.1
float GetRandomDelay(float fMinimumTime = 0.4, float MaximumTime = 1.1);

// * Get Difficulty Duration
int GetScaledDuration(int nActualDuration, object oTarget);

// * Get Scaled Effect
effect GetScaledEffect(effect eStandard, object oTarget);

// * Remove all spell protections of a specific type
int RemoveProtections(int nSpell_ID, object oTarget, int nCount);

// * Performs a spell breach up to nTotal spells are removed and nSR spell
// * resistance is lowered.
int GetSpellBreachProtection(int nLastChecked);

//* Assigns a debug string to the Area of Effect Creator
void AssignAOEDebugString(string sString);

// * Plays a random dragon battlecry based on age.
void PlayDragonBattleCry();

// * Returns true if Target is a humanoid
int AmIAHumanoid(object oTarget);

int GetCureDamageTotal(object oTarget, int nDamage, int nMaxExtraDamage, int nMaximized, int nSpellID);
void spellsCure(int nDamage, int nMaxExtraDamage, int nMaximized, int vfx_impactHurt, int vfx_impactHeal, int nSpellID);
void DoHealing(object oTarget, int nDamageTotal, int vfx_impactHeal);
void DoHarming (object oTarget, int nDamageTotal, int nDamageType, int vfx_impactHurt, int bTouchAttack);
void spellsHealOrHarmTarget(object oTarget, int nDamageTotal, int vfx_impactNormalHurt, int vfx_impactUndeadHurt, int vfx_impactHeal, int nSpellID, int bIsHealingSpell=TRUE, int bHarmTouchAttack=TRUE);


// * Performs a spell breach up to nTotal spell are removed and
// * nSR spell resistance is  lowered. nSpellId can be used to override
// * the originating spell ID. If not specified, SPELL_GREATER_SPELL_BREACH
// * is used
void DoSpellBreach(object oTarget, int nTotal, int nSR, int nSpellId = -1);


// Iterates through the list of objects on oCaster. Returns the index of the first occurance of oTarget.
// Returns 1 or higher if a matching object was found.
// Returns -1 if the entry is not in the list.
int IgnoreTargetRulesGetFirstIndex(object oCaster, object oTarget);

// Regarding the list of objects on oCaster - this removes the entry with index nEntry from the list.
// side affect is that it changes the order of the list. But order is not important with the ITR object list.
void IgnoreTargetRulesRemoveEntry(object oCaster, int nEntry);

//Enqueues a target on a spell caster as an acceptable target to bypass the spellsIsTarget() check on.
// oCaster - the creature casting the spell.
// oTarget - the spell target.
void IgnoreTargetRulesEnqueueTarget(object oCaster, object oTarget);


// Enqueues a spell that will ignore the spellsIsTarget logic.
// Does so by storing temporary variables on the caster of OK targets to bypass on.
// Parameters the same as ActionCastSpellAtObject() in nwscript.nss
void IgnoreTargetRulesActionCastSpellAtObject(int nSpell, object oTarget, int nMetaMagic=METAMAGIC_ANY, int bCheat=FALSE, int nDomainLevel=0, int nProjectilePathType=PROJECTILE_PATH_TYPE_DEFAULT, int bInstantSpell=FALSE);

// Enqueues a spell that will ignore the spellsIsTarget logic. 
// Variation: this will target all within the nShapeType and fShapeSize parameters. (ex SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL)
//   try to match the nShapeType and fShapeSize parameters to prevent lingerings ITR variables.
// Other parameters are the same as ActionCastSpellAtObject() in nwscript.nss
void IgnoreTargetRulesActionCastSpellAtObjectArea(int nShapeType, float fShapeSize, int nSpell, object oTarget, int nMetaMagic=METAMAGIC_ANY, int bCheat=FALSE, int nDomainLevel=0, int nProjectilePathType=PROJECTILE_PATH_TYPE_DEFAULT, int bInstantSpell=FALSE);

// Enqueues a spell that will ignore the spellsIsTarget logic. 
// Variation: this will target all within the nShapeType and fShapeSize parameters. (ex SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL)
//   try to match the nShapeType and fShapeSize parameters to prevent lingerings ITR variables.
// Other parameters are the same as ActionCastSpellAtLocation() in nwscript.nss
void IgnoreTargetRulesActionCastSpellAtLocationArea(int nShapeType, float fShapeSize, int nSpell, location lTargetLocation, int nMetaMagic=METAMAGIC_ANY, int bCheat=FALSE, int nProjectilePathType=PROJECTILE_PATH_TYPE_DEFAULT, int bInstantSpell=FALSE);

//=========================================================================
// Functions
//=========================================================================

int GetIsStandardHostileTarget(object oTarget, object oSource)
{
    int nReturnValue = FALSE;

    int bTargetIsPC = GetIsPC(oTarget);
    int bNotAFriend = FALSE;
    int bReactionTypeFriendly = GetIsReactionTypeFriendly(oTarget, oSource);
    int bInSameFaction = GetFactionEqual(oTarget, oSource);
    if (bReactionTypeFriendly == FALSE && bInSameFaction == FALSE)
    {
        bNotAFriend = TRUE;
    }

    // * Local Override is just an out for end users who want
    // * the area effect spells to hurt 'neutrals'
    if (GetLocalInt(GetModule(), "X0_G_ALLOWSPELLSTOHURT") == 10)
    {
        bTargetIsPC = TRUE;
    }

    int bSelfTarget = FALSE;
    object oTargetMaster = GetCurrentRealMaster(oTarget); 	// 9/19/06 - BDF: changed to GetCurrentMaster() for companion consideration
    object oSourceMaster = GetCurrentRealMaster( oSource );	// GetCurrentMaster() will return OBJECT_INVALID when the queried object is not in a PC party.

    // March 25 2003. The player itself can be harmed
    // by their own area of effect spells if in Hardcore mode...
    if (GetGameDifficulty() > GAME_DIFFICULTY_NORMAL)
    {
        // Have I hit myself with my spell?
        // 11/10/06 - BDF(OEI): non-PC-party NPCs should not be able to hurt themselves in Hardcore+ difficulty;
        //	it may not please the rules purist, but this is a difficulty consideration, not a rules consideration,
        //	and allowing a hostile NPC to kill itself with its own AOEs does not make the game more difficult.
        if ( oTarget == oSource && GetIsObjectValid(oSourceMaster) )
        {
            bSelfTarget = TRUE;
        }
        else
        // * Is the target an associate of the spellcaster
        if (oTargetMaster == oSource)
        {
            bSelfTarget = TRUE;
        }
        // 11/10/06 - BDF(OEI): GetCurrentMaster() will return OBJECT_INVALID when the queried object is not in a PC party.
        //	This causes non-PC-party NPCs to affect one another even if they are not hostile to one another.  Bad.
        else if (oTargetMaster == oSourceMaster 
                && GetIsObjectValid(oSourceMaster) 
                && GetIsObjectValid(oTargetMaster)  )	// This will also ensure that PC party members in multiplayer are affected
        {
            bSelfTarget = TRUE;
        }
    }

    // April 9 2003
    // Hurt the associates of a hostile player
    if (bSelfTarget == FALSE && GetIsObjectValid(oTargetMaster) == TRUE)
    {
        // * I am an associate
        // * of someone
        
        
        // For associates, check target's master (instead of target)
        if ( GetIsReactionTypeHostile(oTargetMaster, oSource) == TRUE )
        {
            bSelfTarget = TRUE;
        }

        // 8/17/06 - BDF-OEI: NWN2 doesn't use personal reputation, so PCs in the same party
        // will consider one another neutral by default; therefore, only hurt associates of HOSTILE PCs
        // Otherwise, we are using personal reputation and neutrality is not a consideration
		// AWD-OEI only do the following check if we are playing hardcore
	    if (GetGameDifficulty() > GAME_DIFFICULTY_NORMAL)
		{
			if (GetGlobalInt(CAMPAIGN_SWITCH_USE_PERSONAL_REPUTATION) )
			{
				if (GetIsReactionTypeFriendly(oTargetMaster,oSource) == FALSE && GetIsPC(oTargetMaster) == TRUE)
				{
				   bSelfTarget = TRUE;
				}        
			}
		}
    }


    // Assumption: In Full PvP players, even if in same party, are Neutral
    // * GZ: 2003-08-30: Patch to make creatures hurt each other in hardcore mode...

    if (GetIsReactionTypeHostile(oTarget,oSource))
    {
        nReturnValue = TRUE;         // Hostile creatures are always a target
    }
    else if (bSelfTarget == TRUE)
    {
        nReturnValue = TRUE;         // Targetting Self (set above)?
    }
    else if (bTargetIsPC && bNotAFriend)
    {
        nReturnValue = TRUE;         // Enemy PC
    }
	else if(bInSameFaction && (GetGameDifficulty() > GAME_DIFFICULTY_NORMAL))
	{
		nReturnValue = TRUE;
	}
    else if (bNotAFriend && (GetGameDifficulty() > GAME_DIFFICULTY_NORMAL))
    {
        if (GetModuleSwitchValue(MODULE_SWITCH_ENABLE_NPC_AOE_HURT_ALLIES) == TRUE)
        {
            nReturnValue = TRUE;        // Hostile Creature and Difficulty > Normal
        }                               // note that in hardcore mode any creature is hostile
    }
    return (nReturnValue);
}


//::///////////////////////////////////////////////
//:: spellsIsTarget
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    This is the reputation wrapper.
    It performs the check to see if, based on the
    constant provided
    it is okay to target this target with the
    spell effect.


    MODIFIED APRIL 2003
    - Other player's associates will now be harmed in
       Standard Hostile mode
    - Will ignore dead people in all target attempts

    MODIFIED AUG 2003 - GZ
    - Multiple henchmen support: made sure that
      AoE spells cast by one henchmen do not
      affect other henchmen in the party

*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: March 6 2003
//:://////////////////////////////////////////////

int spellsIsTarget(object oTarget, int nTargetType, object oSource)
{
	// If the target is a ScriptHidden creature, we do not want to affect it.
	if ( GetScriptHidden(oTarget) == TRUE )
	{
		return FALSE;
	}
	
	// If we want to ignore the rules of target selection for this spell, always return true.
	int nEntry = IgnoreTargetRulesGetFirstIndex(oSource, oTarget);	
	if (nEntry != -1)
	{
		IgnoreTargetRulesRemoveEntry(oSource, nEntry);
		return TRUE;	
	}		
	
    // * if dead, not a valid target
	// JWR-OEI DEAD is invalid, but DYING is valid!
    if (GetIsDead(oTarget, TRUE) == TRUE)
    {
        return FALSE;
    }

	// early out if the targets are the same...
	if ( oTarget == oSource ) 
	{
		if ( nTargetType == SPELL_TARGET_ALLALLIES )	return TRUE; 			
		//else											return FALSE;
	}


    int nReturnValue = FALSE;

    switch (nTargetType)
    {
        // * this kind of spell will affect all friendlies and anyone in my
        // * party, even if we are upset with each other currently.
        case SPELL_TARGET_ALLALLIES:
        {

            if(GetIsReactionTypeFriendly(oTarget,oSource) || GetFactionEqual(oTarget,oSource))
            {
                nReturnValue = TRUE;
            }
            break;
        }
        case SPELL_TARGET_STANDARDHOSTILE:
        {
            nReturnValue = GetIsStandardHostileTarget(oTarget, oSource);
            break;
        }
        // * only harms enemies, ever
        // * current list:call lightning, isaac missiles, firebrand, chain lightning, dirge, Nature's balance,
        // * Word of Faith, bard songs that should never affect friendlies
        case SPELL_TARGET_SELECTIVEHOSTILE:
        {
			// 10/23/06 - BDF(OEI): added GetIsReactionTypeHostile() since GetIsEnemy may not capture all cases
            if( GetIsEnemy(oTarget,oSource) || GetIsReactionTypeHostile(oTarget, oSource) )	
            {
                nReturnValue = TRUE;
            }
            break;
        }
    }

	/*	10/20/06 - BDF(OEI): this block of code is now deprecated.  It essentially prevents companions from damaging the
								party in Hardcore difficulty, which isn't very hardcore at all
    // GZ: Creatures with the same master will never damage each other
	if ( nTargetType != SPELL_TARGET_ALLALLIES )	// 9/25/06 - BDF: Added this conditional to limit this filter to damaging spells
	{
		if ( !GetIsPC(oTarget) && !GetIsPC(oSource) )	// 10/03/06 - BDF: this further reinforces that this block
		{												// will only run when the target and source are NOT PC's
	    	//if (GetMaster(oTarget) != OBJECT_INVALID && GetMaster(oSource) != OBJECT_INVALID )
			if (GetCurrentMaster(oTarget) != OBJECT_INVALID && GetCurrentMaster(oSource) != OBJECT_INVALID )	// 9/19/06 - BDF: changed to GetCurrentMaster() for companion consideration
		    {
		        //if (GetMaster(oTarget) == GetMaster(oSource))
		        if (GetCurrentMaster(oTarget) == GetCurrentMaster(oSource))	// 9/19/06 - BDF: changed to GetCurrentMaster() for companion consideration
		        {
		            if (GetModuleSwitchValue(MODULE_SWITCH_ENABLE_MULTI_HENCH_AOE_DAMAGE) == 0 )
		            {
		                nReturnValue = FALSE;
		            }
		        }
		    }
		}	
	}
	*/	

    return nReturnValue;
}

// * Returns true if Target is a humanoid
int AmIAHumanoid(object oTarget)
{
   int nRacial = GetRacialType(oTarget);

   if((nRacial == RACIAL_TYPE_DWARF) ||
      (nRacial == RACIAL_TYPE_HALFELF) ||
      (nRacial == RACIAL_TYPE_HALFORC) ||
      (nRacial == RACIAL_TYPE_ELF) ||
      (nRacial == RACIAL_TYPE_GNOME) ||
      (nRacial == RACIAL_TYPE_HUMANOID_GOBLINOID) ||
      (nRacial == RACIAL_TYPE_HALFLING) ||
      (nRacial == RACIAL_TYPE_HUMAN) ||
      (nRacial == RACIAL_TYPE_HUMANOID_MONSTROUS) ||
      (nRacial == RACIAL_TYPE_HUMANOID_ORC) ||
      (nRacial == RACIAL_TYPE_HUMANOID_REPTILIAN))
   {
    return TRUE;
   }
   return FALSE;
}


int GetCureDamageTotal(object oTarget, int nDamage, int nMaxExtraDamage, int nMaximized, int nSpellID)
{
    int nMetaMagic = GetMetaMagicFeat();
    int nExtraDamage = GetCasterLevel(OBJECT_SELF); // * figure out the bonus damage
       
    if (nExtraDamage > nMaxExtraDamage)
    {
        nExtraDamage = nMaxExtraDamage;
    }
    
	// * if low or normal difficulty is treated as MAXIMIZED
    if( GetIsPC(GetFactionLeader(oTarget)) &&
       (GetGameDifficulty() < GAME_DIFFICULTY_CORE_RULES) )
    {
        nDamage = nMaximized + nExtraDamage;
    }
    else
    {
        nDamage = nDamage + nExtraDamage;
    }


    //Make metamagic checks
    if (nMetaMagic == METAMAGIC_MAXIMIZE)
    {
        // nDamage = 8 + nExtraDamage;
        nDamage = nMaximized + nExtraDamage;
        // * if low or normal difficulty then MAXMIZED is doubled.
        if(GetIsPC(GetFactionLeader(oTarget)) && GetGameDifficulty() < GAME_DIFFICULTY_CORE_RULES)
        {
            nDamage = nDamage + nMaximized;
        }
    }
	
	// 8/9/06 - BDF-OEI: added the GetSpellCastItem() check to the GetHasFeat() check to make sure that 
	// 	clerics with the healing domain power don't get a bonus when using a healin potion
    if ( nMetaMagic == METAMAGIC_EMPOWER || (GetHasFeat( FEAT_HEALING_DOMAIN_POWER ) && !GetIsObjectValid( GetSpellCastItem() )) )
    {
        nDamage = nDamage + (nDamage/2);
    }


    // JLR - OEI 06/06/05 NWN2 3.5
    if ( GetHasFeat(FEAT_AUGMENT_HEALING) && !GetIsObjectValid(GetSpellCastItem()) )
    {
        int nSpellLvl = GetSpellLevel(nSpellID);
        nDamage = nDamage + (2 * nSpellLvl);
    }
	
	return (nDamage);
}


//	spellsCure
//    Used by the 'cure' series of spells.
//    Will do max heal/damage if at normal or low difficulty.  Random rolls occur at higher difficulties.
// 8/9/06 - BDF-OEI: added the GetSpellCastItem() check to the GetHasFeat() check to make sure that 
// 	clerics with the healing domain power don't get a bonus when using a healin potion
//
//	Heal spells typically do a random amount +1/level up to a max.
//
// Parameters:
//	int nDamage 		- base amount of damage to heal (or cause)
//	int nMaxExtraDamage - an extra amount equal to the Caster's Level is applied, cappen by nMaxExtraDamage
//	int nMaximized 		- This is the max base amount.  (Do not include nMaxExtraDamage)
//  int vfx_impactHurt	- Impact effect to use for when a creature is harmed
// 	int vfx_impactHeal	- Impact effect to use for when a creature is healed
// 	int nSpellID		- The SpellID that is being cast (Spell cast event will be triggered on target).
void spellsCure(int nDamage, int nMaxExtraDamage, int nMaximized, int vfx_impactHurt, int vfx_impactHeal, int nSpellID)
{
    object oTarget = GetSpellTargetObject();
	int nDamageTotal = GetCureDamageTotal(oTarget, nDamage, nMaxExtraDamage, nMaximized, nSpellID);
 	int bIsHealingSpell=TRUE;
	int bHarmTouchAttack=TRUE;
	spellsHealOrHarmTarget(oTarget, nDamageTotal, vfx_impactHurt, vfx_impactHurt, vfx_impactHeal, nSpellID, bIsHealingSpell, bHarmTouchAttack);

}

// this could be a harm spell cast on undead or a heal spell cast on non-undead
void DoHealing(object oTarget, int nDamageTotal, int vfx_impactHeal)
{
	//Set the heal effect
	//eWound- Cure spells now remove the wounding effect, which causes targets to bleed out - PKM-OEI 09.06.06
	effect eHeal = EffectHeal(nDamageTotal);
	RemoveEffectOfType(oTarget, EFFECT_TYPE_WOUNDING);
	//Apply heal effect and VFX impact
	ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, oTarget);
	effect eVis2 = EffectVisualEffect(vfx_impactHeal);
	ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, oTarget);
}

// this could be a harm spell cast on non-undead or a heal spell cast on undead
void DoHarming (object oTarget, int nDamageTotal, int nDamageType, int vfx_impactHurt, int bTouchAttack)
{
	if (bTouchAttack)
	{
		// Returns 0 on a miss, 1 on a hit, and 2 on a critical hit.
		int nTouch = TouchAttackMelee(oTarget);
		if (nTouch == 0)
			return;
	}			

	if (spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, OBJECT_SELF))
	{
		if (!MyResistSpell(OBJECT_SELF, oTarget))
		{
			// Returns 0 if the saving throw roll failed, 1 if the saving throw roll succeeded and 2 if the target was immune 
			int nSave = WillSave(oTarget, GetSpellSaveDC(), SAVING_THROW_TYPE_NONE, OBJECT_SELF);
			if	(nSave != 2)
			{
				// successful save = half damage 
				if  (nSave == 1)
					nDamageTotal = nDamageTotal/2;
				
				effect eDam = EffectDamage(nDamageTotal, nDamageType);
				//Apply the VFX impact and effects
				DelayCommand(1.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
				effect eVis = EffectVisualEffect(vfx_impactHurt);
				ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
			}						
		}
	}
}


// This spell routes healing and harming out depending on whether we are undead or not.
void spellsHealOrHarmTarget(object oTarget, int nDamageTotal, int vfx_impactNormalHurt, int vfx_impactUndeadHurt, int vfx_impactHeal, int nSpellID, int bIsHealingSpell=TRUE, int bHarmTouchAttack=TRUE)
{
	int bHarmful = FALSE;
	
    // abort for creatures immune to heal.
    if (GetLocalInt(oTarget, VAR_IMMUNE_TO_HEAL))
        return;
		
		
	int bIsUndead = (GetRacialType(oTarget) == RACIAL_TYPE_UNDEAD);
    if (!bIsUndead) // target is normal folks.
    {
		if (bIsHealingSpell) // healing spell 
			DoHealing(oTarget, nDamageTotal, vfx_impactHeal);
		else // harming spell
		{
			DoHarming (oTarget, nDamageTotal, DAMAGE_TYPE_NEGATIVE, vfx_impactNormalHurt, bHarmTouchAttack);
			bHarmful = TRUE;
		}			
    }
    else // target is undead
    {
		if (bIsHealingSpell) // heal spell on undead harms
		{
			DoHarming (oTarget, nDamageTotal, DAMAGE_TYPE_POSITIVE, vfx_impactUndeadHurt, bHarmTouchAttack);
			bHarmful = TRUE;
		}			
		else // harming spell on undead heals!
			DoHealing(oTarget, nDamageTotal, vfx_impactHeal);
		
    }

	SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, nSpellID, bHarmful));
}

//::///////////////////////////////////////////////
//:: DoSpelLBreach
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Performs a spell breach up to nTotal spells
    are removed and nSR spell resistance is
    lowered.
*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: September 2002
//:: Modified  : Georg, Oct 31, 2003
//:://////////////////////////////////////////////
void DoSpellBreach(object oTarget, int nTotal, int nSR, int nSpellId = -1)
{
    if (nSpellId == -1)
    {
        nSpellId =  SPELL_GREATER_SPELL_BREACH;
    }
    effect eSR = EffectSpellResistanceDecrease(nSR);
    effect eDur;
	
	if ( nSpellId == SPELL_LESSER_SPELL_BREACH )	eDur = EffectVisualEffect( VFX_DUR_SPELL_LESSER_SPELL_BREACH );
	else											eDur = EffectVisualEffect( VFX_DUR_SPELL_GREATER_SPELL_BREACH );

    //effect eVis = EffectVisualEffect(VFX_HIT_SPELL_ABJURATION);
    int nCnt, nIdx;
    if(!GetIsReactionTypeFriendly(oTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, nSpellId ));
        //Search through and remove protections.
        while(nCnt <= NW_I0_SPELLS_MAX_BREACH && nIdx < nTotal)
        {
            nIdx = nIdx + RemoveProtections(GetSpellBreachProtection(nCnt), oTarget, nCnt);
            nCnt++;
        }
        effect eLink = EffectLinkEffects(eDur, eSR);
        //--------------------------------------------------------------------------
        // This can not be dispelled
        //--------------------------------------------------------------------------
        eLink = ExtraordinaryEffect(eLink);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(10));
    }
    //ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
}

//::///////////////////////////////////////////////
//:: GetDragonFearDC
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Adding a function, we were using two different
    sets of numbers before. Standardizing it to be
    closer to 3e.
    nAge - hit dice
*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: Sep 13, 2002
//:://////////////////////////////////////////////
int GetDragonFearDC(int nAge)
{
    //hmm... not sure what's up with all these nCount variables, they're not
    //actually used... so I'm gonna comment them out

    int nDC = 13;
//    int nCount = 1;
    //Determine the duration and save DC
    //wyrmling meant no change from default, so we don't need it
/*
    if (nAge <= 6) //Wyrmling
    {
        nDC = 13;
        nCount = 1;
    }
    else
*/
    if (nAge >= 7 && nAge <= 9) //Very Young
    {
        nDC = 15;
//        nCount = 2;
    }
    else if (/*nAge >= 10 &&*/ nAge <= 12) //Young
    {
        nDC = 17;
//        nCount = 3;
    }
    else if (/*nAge >= 13 &&*/ nAge <= 15) //Juvenile
    {
        nDC = 19;
//        nCount = 4;
    }
    else if (/*nAge >= 16 &&*/ nAge <= 18) //Young Adult
    {
        nDC = 21;
//        nCount = 5;
    }
    else if (/*nAge >= 19 &&*/ nAge <= 21) //Adult
    {
        nDC = 24;
//        nCount = 6;
    }
    else if (/*nAge >= 22 &&*/ nAge <= 24) //Mature Adult
    {
        nDC = 27;
//        nCount = 7;
    }
    else if (/*nAge >= 25 &&*/ nAge <= 27) //Old
    {
        nDC = 28;
//        nCount = 8;
    }
    else if (/*nAge >= 28 &&*/ nAge <= 30) //Very Old
    {
        nDC = 30;
//        nCount = 9;
    }
    else if (/*nAge >= 31 &&*/ nAge <= 33) //Ancient
    {
        nDC = 32;
//        nCount = 10;
    }
    else if (/*nAge >= 34 &&*/ nAge <= 37) //Wyrm
    {
        nDC = 34;
//        nCount = 11;
    }
    else if (nAge > 37) //Great Wyrm
    {
        nDC = 37;
//        nCount = 12;
    }

    return nDC;
}

//------------------------------------------------------------------------------
// Kovi function: calculates the appropriate base number of attacks
// for spells that increase this (tensers, divine power)
//------------------------------------------------------------------------------
int CalcNumberOfAttacks()
{
  int n = GetCasterLevel(OBJECT_SELF);
  int nBAB1 = GetLevelByClass(CLASS_TYPE_RANGER)
   + GetLevelByClass(CLASS_TYPE_FIGHTER)
   + GetLevelByClass(CLASS_TYPE_PALADIN)
   + GetLevelByClass(CLASS_TYPE_BARBARIAN);
  int nBAB2 = GetLevelByClass(CLASS_TYPE_DRUID)
   + GetLevelByClass(CLASS_TYPE_MONK)
   + GetLevelByClass(CLASS_TYPE_ROGUE)
   + GetLevelByClass(CLASS_TYPE_BARD);
  int nBAB3 = GetLevelByClass(CLASS_TYPE_WIZARD)
   + GetLevelByClass(CLASS_TYPE_SORCERER);

  int nOldBAB = nBAB1 + (nBAB2 + n) * 3 / 4 + nBAB3 / 2;
  int nNewBAB = nBAB1 + n + nBAB2 * 3 / 4 + nBAB3 / 2;
  if (nNewBAB / 5 > nOldBAB / 5)
    return 2; // additional attack
  else
    return 1; // everything is normal
}

//------------------------------------------------------------------------------
// GZ: gets rids of temporary hit points so that they will not stack
//------------------------------------------------------------------------------
void RemoveTempHitPoints()
{
    effect eProtection;
    int nCnt = 0;

    eProtection = GetFirstEffect(OBJECT_SELF);
    while (GetIsEffectValid(eProtection))
    {
      	if(GetEffectType(eProtection) == EFFECT_TYPE_TEMPORARY_HITPOINTS)
	  	{
       		RemoveEffect(OBJECT_SELF, eProtection);
      		eProtection = GetFirstEffect(OBJECT_SELF);	// 8/28/06 - BDF-OEI: start back at the beginning to ensure that linked effects are removed safely
		}
		else 	eProtection = GetNextEffect(OBJECT_SELF);
	}
}

// * Kovi. removes any effects from this type of spell
// * i.e., used in Mage Armor to remove any previous
// * mage armors
void RemoveEffectsFromSpell(object oTarget, int SpellID)
{
  	effect eLook = GetFirstEffect(oTarget);
  	while (GetIsEffectValid(eLook)) 
	{
    	if (GetEffectSpellId(eLook) == SpellID)
		{
      		RemoveEffect(oTarget, eLook);
			eLook = GetFirstEffect(oTarget);	// 8/28/06 - BDF-OEI: start back at the beginning to ensure that linked effects are removed safely
		}
		else	eLook = GetNextEffect(oTarget);
  	}
}

int MyResistSpell(object oCaster, object oTarget, float fDelay = 0.0)
{
    if (fDelay > 0.5)
    {
        fDelay = fDelay - 0.1;
    }
    int nResist = ResistSpell(oCaster, oTarget);
    //effect eSR = EffectVisualEffect(VFX_IMP_MAGIC_RESISTANCE_USE);	// no longer using NWN1 VFX
    effect eSR = EffectVisualEffect( VFX_DUR_SPELL_SPELL_RESISTANCE );	// uses NWN2 VFX
    //effect eGlobe = EffectVisualEffect(VFX_IMP_GLOBE_USE);	// no longer using NWN1 VFX
    effect eGlobe = EffectVisualEffect( VFX_DUR_SPELL_GLOBE_INV_LESS );	// uses NWN2 VFX
    //effect eMantle = EffectVisualEffect(VFX_IMP_SPELL_MANTLE_USE);	// no longer using NWN1 VFX
    effect eMantle = EffectVisualEffect( VFX_DUR_SPELL_SPELL_MANTLE );	// uses NWN2 VFX
	
    if(nResist == 1) //Spell Resistance
    {
        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eSR, oTarget));
    }
    else if(nResist == 2) //Globe
    {
        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eGlobe, oTarget));
    }
    else if(nResist == 3) //Spell Mantle
    {
        if (fDelay > 0.5)
        {
            fDelay = fDelay - 0.1;
        }
        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eMantle, oTarget));
    }
    return nResist;
}

int MySavingThrow(int nSavingThrow, object oTarget, int nDC, int nSaveType=SAVING_THROW_TYPE_NONE, object oSaveVersus = OBJECT_SELF, float fDelay = 0.0)
{
    // -------------------------------------------------------------------------
    // GZ: sanity checks to prevent wrapping around
    // -------------------------------------------------------------------------
    if (nDC<1)
    {
       nDC = 1;
    }
    else if (nDC > 255)
    {
      nDC = 255;
    }

    effect eVis;
    int bValid = FALSE;
    int nSpellID;
    if(nSavingThrow == SAVING_THROW_FORT)
    {
        bValid = FortitudeSave(oTarget, nDC, nSaveType, oSaveVersus);
        if(bValid == 1)
        {
            //eVis = EffectVisualEffect(VFX_IMP_FORTITUDE_SAVING_THROW_USE);	// no longer using NWN1 VFX; there is no analogous NWN2 VFX
        }
    }
    else if(nSavingThrow == SAVING_THROW_REFLEX)
    {
        bValid = ReflexSave(oTarget, nDC, nSaveType, oSaveVersus);
        if(bValid == 1)
        {
            //eVis = EffectVisualEffect(VFX_IMP_REFLEX_SAVE_THROW_USE);	// no longer using NWN1 VFX; there is no analogous NWN2 VFX
        }
    }
    else if(nSavingThrow == SAVING_THROW_WILL)
    {
        bValid = WillSave(oTarget, nDC, nSaveType, oSaveVersus);
        if(bValid == 1)
        {
            //eVis = EffectVisualEffect(VFX_IMP_WILL_SAVING_THROW_USE);	// no longer using NWN1 VFX; there is no analogous NWN2 VFX
        }
    }

    nSpellID = GetSpellId();

    /*
        return 0 = FAILED SAVE
        return 1 = SAVE SUCCESSFUL
        return 2 = IMMUNE TO WHAT WAS BEING SAVED AGAINST
    */
    if(bValid == 0)
    {
        if((nSaveType == SAVING_THROW_TYPE_DEATH
         || nSpellID == SPELL_WEIRD
         || nSpellID == SPELL_FINGER_OF_DEATH) &&
         nSpellID != SPELL_HORRID_WILTING)
        {
            eVis = EffectVisualEffect(VFX_IMP_DEATH);
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
        }
    }
    //redundant comparison on bValid, let's move the eVis line down below
/*    if(bValid == 2)
    {
        eVis = EffectVisualEffect(VFX_IMP_MAGIC_RESISTANCE_USE);
    }*/
    if(bValid == 1 || bValid == 2)
    {
        if(bValid == 2)
        {
            //eVis = EffectVisualEffect(VFX_IMP_MAGIC_RESISTANCE_USE);	// no longer using NWN1 VFX
			eVis = EffectVisualEffect( VFX_DUR_SPELL_SPELL_RESISTANCE );	// makes use of NWN2 VFX
            /*
            If the spell is save immune then the link must be applied in order to get the true immunity
            to be resisted.  That is the reason for returing false and not true.  True blocks the
            application of effects.
            */
            bValid = FALSE;
        }
        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
    }
    return bValid;
}

effect CreateProtectionFromAlignmentLink(int nAlignment, int nPower = 1)
{
    int nFinal = nPower * 2;
    effect eAC = EffectACIncrease(nFinal, AC_DEFLECTION_BONUS);
    eAC = VersusAlignmentEffect(eAC, ALIGNMENT_ALL, nAlignment);
    effect eSave = EffectSavingThrowIncrease(SAVING_THROW_ALL, nFinal);
    eSave = VersusAlignmentEffect(eSave,ALIGNMENT_ALL, nAlignment);
    effect eImmune = EffectImmunity(IMMUNITY_TYPE_MIND_SPELLS);
    eImmune = VersusAlignmentEffect(eImmune,ALIGNMENT_ALL, nAlignment);
    effect eDur;
    if(nAlignment == ALIGNMENT_EVIL)
    {
        //eDur = EffectVisualEffect(VFX_DUR_PROTECTION_GOOD_MINOR);	// no longer using NWN1 VFX
        eDur = EffectVisualEffect( VFX_DUR_SPELL_GOOD_CIRCLE );	// makes use of NWN2 VFX
    }
    else if(nAlignment == ALIGNMENT_GOOD)
    {
        //eDur = EffectVisualEffect(VFX_DUR_PROTECTION_EVIL_MINOR);	// no longer using NWN1 VFX
        eDur = EffectVisualEffect( VFX_DUR_SPELL_EVIL_CIRCLE );	// makes use of NWN2 VFX
    }

    //effect eDur2 = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eLink = EffectLinkEffects(eImmune, eSave);
    eLink = EffectLinkEffects(eLink, eAC);
    eLink = EffectLinkEffects(eLink, eDur);
    //eLink = EffectLinkEffects(eLink, eDur2);
    return eLink;
}

effect CreateDoomEffectsLink()
{
    //Declare major variables
    effect eSaves = EffectSavingThrowDecrease(SAVING_THROW_ALL, 2);
    effect eAttack = EffectAttackDecrease(2);
    effect eDamage = EffectDamageDecrease(2);
    effect eSkill = EffectSkillDecrease(SKILL_ALL_SKILLS, 2);
    //effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);	// NWN1 VFX
    effect eDur = EffectVisualEffect( VFX_DUR_SPELL_DOOM );	// NWN2 VFX

    effect eLink = EffectLinkEffects(eAttack, eDamage);
    eLink = EffectLinkEffects(eLink, eSaves);
    eLink = EffectLinkEffects(eLink, eSkill);
    eLink = EffectLinkEffects(eLink, eDur);

    return eLink;
}

void RemoveSpellEffects(int nSpell_ID, object oCaster, object oTarget)
{
    //Declare major variables
    effect eAOE;
    if(GetHasSpellEffect(nSpell_ID, oTarget))
    {
        //Search through the valid effects on the target.
        eAOE = GetFirstEffect(oTarget);
        while (GetIsEffectValid(eAOE))
        {
            if (GetEffectCreator(eAOE) == oCaster)
            {
                //If the effect was created by the spell then remove it
                if(GetEffectSpellId(eAOE) == nSpell_ID)
                {
                    RemoveEffect(oTarget, eAOE);
					eAOE = GetFirstEffect(oTarget);	// 8/28/06 - BDF-OEI: start back at the beginning to ensure that linked effects are removed safely
                    //bValid = TRUE;
                }
				else
				{
					eAOE = GetNextEffect(oTarget);
				}
            }
			else
			{
            	//Get next effect on the target
            	eAOE = GetNextEffect(oTarget);
			}
        }
    }
}

void RemoveSpecificEffect(int nEffectTypeID, object oTarget)
{
    //Declare major variables
    //Get the object that is exiting the AOE
    effect eAOE;
    //Search through the valid effects on the target.
    eAOE = GetFirstEffect(oTarget);
    while (GetIsEffectValid(eAOE))
    {
        if (GetEffectType(eAOE) == nEffectTypeID)
        {
            //If the effect was created by the spell then remove it
            RemoveEffect(oTarget, eAOE);
			eAOE = GetFirstEffect(oTarget);	// 8/28/06 - BDF-OEI: start back at the beginning to ensure that linked effects are removed safely
        }
		else
		{
        	//Get next effect on the target
        	eAOE = GetNextEffect(oTarget);
		}
    }
}

float GetSpellEffectDelay(location SpellTargetLocation, object oTarget)
{
    float fDelay;
    return fDelay = GetDistanceBetweenLocations(SpellTargetLocation, GetLocation(oTarget))/20;
}

float GetRandomDelay(float fMinimumTime = 0.4, float MaximumTime = 1.1)
{
    float fRandom = MaximumTime - fMinimumTime;
    if(fRandom < 0.0)
    {
        return 0.0;
    }
    else
    {
        int nRandom;
        nRandom = FloatToInt(fRandom  * 10.0);
        nRandom = Random(nRandom) + 1;
        fRandom = IntToFloat(nRandom);
        fRandom /= 10.0;
        return fRandom + fMinimumTime;
    }
}

int GetScaledDuration(int nActualDuration, object oTarget)
{

    int nDiff = GetGameDifficulty();
    int nNew = nActualDuration;
    if(GetIsPC(oTarget) && nActualDuration > 3)
    {
        if(nDiff == GAME_DIFFICULTY_VERY_EASY || nDiff == GAME_DIFFICULTY_EASY)
        {
            nNew = nActualDuration / 4;
        }
        else if(nDiff == GAME_DIFFICULTY_NORMAL)
        {
            nNew = nActualDuration / 2;
        }
        if(nNew == 0)
        {
            nNew = 1;
        }
    }
    return nNew;
}

effect GetScaledEffect(effect eStandard, object oTarget)
{
    int nDiff = GetGameDifficulty();
    effect eNew = eStandard;
    object oMaster = GetMaster(oTarget);
    if(GetIsPC(oTarget) || (GetIsObjectValid(oMaster) && GetIsPC(oMaster)))
    {
        if(GetEffectType(eStandard) == EFFECT_TYPE_FRIGHTENED && nDiff == GAME_DIFFICULTY_VERY_EASY)
        {
            eNew = EffectAttackDecrease(2); // fix_Aqvilinus
            return eNew;
        }
        if(GetEffectType(eStandard) == EFFECT_TYPE_FRIGHTENED && nDiff == GAME_DIFFICULTY_EASY)
        {
            eNew = EffectAttackDecrease(4); // fix_Aqvilinus
            return eNew;
        }
        if(nDiff == GAME_DIFFICULTY_VERY_EASY &&
            (GetEffectType(eStandard) == EFFECT_TYPE_PARALYZE ||
             GetEffectType(eStandard) == EFFECT_TYPE_STUNNED ||
             GetEffectType(eStandard) == EFFECT_TYPE_CONFUSED))
        {
            eNew = EffectDazed();
            return eNew;
        }
        else if(GetEffectType(eStandard) == EFFECT_TYPE_CHARMED || GetEffectType(eStandard) == EFFECT_TYPE_DOMINATED)
        {
            eNew = EffectDazed();
            return eNew;
        }
    }
    return eNew;
}

int RemoveProtections(int nSpell_ID, object oTarget, int nCount)
{
    //Declare major variables
    effect eProtection;
    int nCnt = 0;
    if(GetHasSpellEffect(nSpell_ID, oTarget))
    {
        //Search through the valid effects on the target.
        eProtection = GetFirstEffect(oTarget);
        while (GetIsEffectValid(eProtection))
        {
            //If the effect was created by the spell then remove it
            if(GetEffectSpellId(eProtection) == nSpell_ID)
            {
                RemoveEffect(oTarget, eProtection);
				eProtection = GetFirstEffect(oTarget);	// 8/28/06 - BDF-OEI: start back at the beginning to ensure that linked effects are removed safely
                //return 1;
                nCnt++;
            }
			else       //Get next effect on the target
            	eProtection = GetNextEffect(oTarget);
        }
    }
    if(nCnt > 0)
    {
        return 1;
    }
    else
    {
        return 0;
    }
}

//------------------------------------------------------------------------------
// Returns the nLastChecked-nth highest spell on the creature for use in
// the spell breach routines
// Please modify the constatn NW_I0_SPELLS_MAX_BREACH at the top of this file
// if you change the number of spells.
//------------------------------------------------------------------------------
int GetSpellBreachProtection(int nLastChecked)
{
    //--------------------------------------------------------------------------
    // GZ: Protections are stripped in the order they appear here
    //--------------------------------------------------------------------------
    if(nLastChecked == 1) {return SPELL_GREATER_SPELL_MANTLE;}
    else if (nLastChecked == 2){return SPELL_PREMONITION;}
    else if(nLastChecked == 3) {return SPELL_SPELL_MANTLE;}
    else if(nLastChecked == 4) {return SPELL_SHADOW_SHIELD;}
    else if(nLastChecked == 5) {return SPELL_GREATER_STONESKIN;}
    else if(nLastChecked == 6) {return SPELL_ETHEREAL_VISAGE;}
    else if(nLastChecked == 7) {return SPELL_GLOBE_OF_INVULNERABILITY;}
    else if(nLastChecked == 8) {return SPELL_ENERGY_BUFFER;}
    else if(nLastChecked == 9) {return 443;} // greater sanctuary
    else if(nLastChecked == 10) {return SPELL_LESSER_GLOBE_OF_INVULNERABILITY;}	// JLR - OEI 07/13/05 -- Name Changed
    else if(nLastChecked == 11) {return SPELL_SPELL_RESISTANCE;}
    else if(nLastChecked == 12) {return SPELL_STONESKIN;}
    else if(nLastChecked == 13) {return SPELL_LESSER_SPELL_MANTLE;}
//    else if(nLastChecked == 14) {return SPELL_MESTILS_ACID_SHEATH;}
    else if(nLastChecked == 14) {return SPELL_LEAST_SPELL_MANTLE;}
    else if(nLastChecked == 15) {return SPELL_MIND_BLANK;}
    else if(nLastChecked == 16) {return SPELL_ELEMENTAL_SHIELD;}
    else if(nLastChecked == 17) {return SPELL_PROTECTION_FROM_SPELLS;}
    else if(nLastChecked == 18) {return SPELL_PROTECTION_FROM_ENERGY;}	// JLR - OEI 07/13/05 -- Name Changed
    else if(nLastChecked == 19) {return SPELL_RESIST_ENERGY;}	// JLR - OEI 07/13/05 -- Name Changed
    else if(nLastChecked == 20) {return SPELL_DEATH_ARMOR;}
    else if(nLastChecked == 21) {return SPELL_GHOSTLY_VISAGE;}
    else if(nLastChecked == 22) {return SPELL_ENDURE_ELEMENTS;}
    else if(nLastChecked == 23) {return SPELL_SHADOW_SHIELD;}
    else if(nLastChecked == 24) {return SPELL_SHADOW_CONJURATION_MAGE_ARMOR;}
//    else if(nLastChecked == 25) {return SPELL_NEGATIVE_ENERGY_PROTECTION;}	// JLR - OEI 07/16/06 -- REMOVED
    else if(nLastChecked == 26) {return SPELL_SANCTUARY;}
    else if(nLastChecked == 27) {return SPELL_MAGE_ARMOR;}
//    else if(nLastChecked == 28) {return SPELL_STONE_BONES;}	// JLR - OEI 07/13/05 -- REMOVED
    else if(nLastChecked == 29) {return SPELL_SHIELD;}
    else if(nLastChecked == 30) {return SPELL_SHIELD_OF_FAITH;}
    else if(nLastChecked == 31) {return SPELL_LESSER_MIND_BLANK;}
//    else if(nLastChecked == 32) {return SPELL_IRONGUTS;}	// JLR - OEI 07/13/05 -- REMOVED
    else if(nLastChecked == 33) {return SPELL_RESISTANCE;}
    return nLastChecked;
}

void AssignAOEDebugString(string sString)
{
    object oTarget = GetAreaOfEffectCreator();
    AssignCommand(oTarget, SpeakString(sString));
}


void PlayDragonBattleCry()
{
    if(d100() > 50)
    {
        PlayVoiceChat(VOICE_CHAT_BATTLECRY1);
    }
    else
    {
        PlayVoiceChat(VOICE_CHAT_BATTLECRY2);
    }
}

void TrapDoElectricalDamage(int ngDamageMaster, int nSaveDC, int nSecondary)
{
    //Declare major variables
    object oTarget = GetEnteringObject();
    object o2ndTarget;
    effect eLightning = EffectBeam(VFX_BEAM_LIGHTNING, oTarget, BODY_NODE_CHEST);	// no longer using NWN1 VFX; does this still work?
    //effect eLightning = EffectVisualEffect( VFX_BEAM_LIGHTNING );	// makes use of NWN2 VFX
    int nDamageMaster = ngDamageMaster;
    int nDamage = nDamageMaster;
    effect eDam;
    effect eVis = EffectVisualEffect( VFX_IMP_LIGHTNING_S );
    location lTarget = GetLocation(oTarget);
    int nCount = 0;
    //Adjust the trap damage based on the feats of the target
    if(!MySavingThrow(SAVING_THROW_REFLEX, oTarget, nSaveDC, SAVING_THROW_TYPE_TRAP))
    {
        if (GetHasFeat(FEAT_IMPROVED_EVASION, oTarget))
        {
            nDamage /= 2;
        }
    }
    else if (GetHasFeat(FEAT_EVASION, oTarget) || GetHasFeat(FEAT_IMPROVED_EVASION, oTarget))
    {
        nDamage = 0;
    }
    else
    {
        nDamage /= 2;
    }
    if (nDamage > 0)
    {
        eDam = EffectDamage(nDamage, DAMAGE_TYPE_ELECTRICAL);
        DelayCommand(0.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
    }

    object oCreator = GetTrapCreator(OBJECT_SELF);
    if (oCreator == OBJECT_INVALID)
    {
        oCreator = OBJECT_SELF; //pre-placed traps have no creator
    }

    //Reset the damage;
    nDamage = nDamageMaster;
    o2ndTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, lTarget);
    while (GetIsObjectValid(o2ndTarget) && nCount <= nSecondary)
    {
        if(!GetIsReactionTypeFriendly(o2ndTarget, oCreator))
        {
            //check to see that the original target is not hit again.
            if(o2ndTarget != oTarget)
            {
                //Adjust the trap damage based on the feats of the target
                if(!MySavingThrow(SAVING_THROW_REFLEX, o2ndTarget, nSaveDC, SAVING_THROW_TYPE_ELECTRICITY))
                {
                    if (GetHasFeat(FEAT_IMPROVED_EVASION, o2ndTarget))
                    {
                        nDamage /= 2;
                    }
                }
                else if (GetHasFeat(FEAT_EVASION, o2ndTarget) || GetHasFeat(FEAT_IMPROVED_EVASION, o2ndTarget))
                {
                    nDamage = 0;
                }
                else
                {
                    nDamage /= 2;
                }
                if (nDamage > 0)
                {
                    //Set the damage effect
                    eDam = EffectDamage(nDamage, DAMAGE_TYPE_ELECTRICAL);
                    //Apply the VFX impact and damage effect
                    DelayCommand(0.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, o2ndTarget));
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, o2ndTarget);
                    //Connect the lightning stream from one target to another.
                    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLightning, o2ndTarget, 0.75);
                    //Set the last target as the new start for the lightning stream
                    eLightning = EffectBeam(VFX_BEAM_LIGHTNING, o2ndTarget, BODY_NODE_CHEST);	// no longer using NWN1 VFX; does this still work?
                    //eLightning = EffectVisualEffect( VFX_BEAM_LIGHTNING );	// makes use of NWN2 VFX
                }
            }
            //Reset the damage
            nDamage = nDamageMaster;
            //Increment the count
            nCount++;
        }
        //Get next target in the shape.
        o2ndTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, lTarget);
    }
}

// Iterates through the list of objects on oCaster. Returns the index of the first occurance of oTarget.
// Returns 1 or higher if a matching object was found.
// Returns -1 if the entry is not in the list.
int IgnoreTargetRulesGetFirstIndex(object oCaster, object oTarget)
{
	int nITREntries = GetLocalInt(oCaster, ITR_NUM_ENTRIES), i;
	object oEntry;
	for (i=1; i<=nITREntries; i++)
	{
		oEntry = GetLocalObject(oCaster, ITR_ENTRY_PREFIX + IntToString(i));
		if (oEntry == oTarget)
			return i;
	}
	return -1;
}

// Regarding the list of objects on oCaster - this removes the entry with index nEntry from the list.
// side affect is that it changes the order of the list. But order is not important with the ITR object list.
void IgnoreTargetRulesRemoveEntry(object oCaster, int nEntry)
{
	int nITREntries = GetLocalInt(oCaster, ITR_NUM_ENTRIES);
	if ((nITREntries>0) && (nEntry>0) && (nEntry<=nITREntries))
	{
		object oEntry = GetLocalObject(oCaster, ITR_ENTRY_PREFIX + IntToString(nITREntries));
		SetLocalObject(oCaster, ITR_ENTRY_PREFIX + IntToString(nEntry), GetLocalObject(oCaster, ITR_ENTRY_PREFIX + IntToString(nITREntries))); //replace nEntry with last object in list.
		DeleteLocalObject(oCaster, ITR_ENTRY_PREFIX + IntToString(nITREntries));
		SetLocalInt(oCaster, ITR_NUM_ENTRIES, nITREntries-1); //decrement list total
	}
}

//Enqueues a target on a spell caster as an acceptable target to bypass the spellsIsTarget() check on.
// oCaster - the creature casting the spell.
// oTarget - the spell target.
void IgnoreTargetRulesEnqueueTarget(object oCaster, object oTarget)
{
	int nITREntries = GetLocalInt(oCaster, ITR_NUM_ENTRIES) + 1;
	SetLocalObject(oCaster, ITR_ENTRY_PREFIX + IntToString(nITREntries), oTarget);
	SetLocalInt(oCaster,ITR_NUM_ENTRIES,nITREntries);
}


// Enqueues a spell that will ignore the spellsIsTarget logic.
// Does so by storing temporary variables on the caster of OK targets to bypass on.
// Parameters the same as ActionCastSpellAtObject() in nwscript.nss
void IgnoreTargetRulesActionCastSpellAtObject(int nSpell, object oTarget, int nMetaMagic=METAMAGIC_ANY, int bCheat=FALSE, int nDomainLevel=0, int nProjectilePathType=PROJECTILE_PATH_TYPE_DEFAULT, int bInstantSpell=FALSE)
{
	IgnoreTargetRulesEnqueueTarget(OBJECT_SELF, oTarget);
	ActionCastSpellAtObject(nSpell, oTarget, nMetaMagic,bCheat,nDomainLevel,nProjectilePathType, bInstantSpell);
}

// Enqueues a spell that will ignore the spellsIsTarget logic. 
// Variation: this will target all within the nShapeType and fShapeSize parameters. (ex SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL)
//   try to match the nShapeType and fShapeSize parameters to prevent lingerings ITR variables.
// Other parameters are the same as ActionCastSpellAtObject() in nwscript.nss
void IgnoreTargetRulesActionCastSpellAtObjectArea(int nShapeType, float fShapeSize, int nSpell, object oTarget, int nMetaMagic=METAMAGIC_ANY, int bCheat=FALSE, int nDomainLevel=0, int nProjectilePathType=PROJECTILE_PATH_TYPE_DEFAULT, int bInstantSpell=FALSE)
{
    oTarget = GetFirstObjectInShape(nShapeType, fShapeSize, GetLocation(OBJECT_SELF));
    while(GetIsObjectValid(oTarget))
    {
		IgnoreTargetRulesEnqueueTarget(OBJECT_SELF, oTarget);		
        //Get the next target in the specified area around the caster
        oTarget = GetNextObjectInShape(nShapeType, fShapeSize, GetLocation(OBJECT_SELF));
	}
	ActionCastSpellAtObject(nSpell,oTarget,nMetaMagic,bCheat, nDomainLevel,nProjectilePathType, bInstantSpell);		
}

// Enqueues a spell that will ignore the spellsIsTarget logic. 
// Variation: this will target all within the nShapeType and fShapeSize parameters. (ex SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL)
//   try to match the nShapeType and fShapeSize parameters to prevent lingerings ITR variables.
// Other parameters are the same as ActionCastSpellAtLocation() in nwscript.nss
void IgnoreTargetRulesActionCastSpellAtLocationArea(int nShapeType, float fShapeSize, int nSpell, location lTargetLocation, int nMetaMagic=METAMAGIC_ANY, int bCheat=FALSE, int nProjectilePathType=PROJECTILE_PATH_TYPE_DEFAULT, int bInstantSpell=FALSE)
{
    object oTarget = GetFirstObjectInShape(nShapeType, fShapeSize, lTargetLocation);
    while(GetIsObjectValid(oTarget))
    {
		IgnoreTargetRulesEnqueueTarget(OBJECT_SELF, oTarget);		
        //Get the next target in the specified area around the caster
        oTarget = GetNextObjectInShape(nShapeType, fShapeSize, lTargetLocation);
	}
	ActionCastSpellAtLocation(nSpell,lTargetLocation,nMetaMagic,bCheat,nProjectilePathType, bInstantSpell);
}


//void main() {}