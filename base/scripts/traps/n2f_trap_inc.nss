// 'n2f_trap_inc'
/*
	Routines for traps
*/
// kevL 2024 jan 18

#include "nw_i0_spells"

/**
 * Function declarations
 */

void n2f_TrapDoElectrical(int iHp, int iDc, int iExtraTargets);
void n2f_TrapDoFire(int iDice, int iDc, float fRadius = RADIUS_SIZE_MEDIUM);
void n2f_TrapDoTarget(object oTarget, effect eVishit, int iDc, int iHp, int iType);
void n2f_TrapDoSonic(int iDice, int iDc, int iDur, int iVisdur = VFX_DUR_SPELL_DAZE);
void n2f_TrapDoFrost(int iDice, int iDc, int iDur, int iVisdur = VFX_DUR_PARALYZED);
void n2f_TrapDoAcidBlob(int iDice, int iDc, int iDur);
void n2f_TrapDoHoly(int iDiceUndead, int iDiceNonundead);
void n2f_TrapDoSpike(int iHp);
void n2f_TrapDoNegative(int iDice, int iDc, int iPenalty, int bLevelDecrease = FALSE);
void n2f_TrapDoAcidSplash(int iDice, int iDc);
void n2f_TrapDoGas(string sScript);
void n2f_TrapDoGasAoeEnter(int iPoisonType);
void n2f_TrapDoTangle(int iDc, int iDur, float fRadius = RADIUS_SIZE_MEDIUM);


/**
 * Function definitions
 */

// Applies a specified # of electrical damage to a specified count of targets
// that are within range of the target that enters the trap-trigger.
// - based on TrapDoElectricalDamage() in "nw_i0_spells"
// - kL_change: attach the lightning stream to creatures even if they avoid damage
// - kL_change: correct the count of extra targets
// - iHp           : # electrical damage
// - iDc           : the Reflex Save DC
// - iExtraTargets : # of extra targets (not incl/ triggering creature)
void n2f_TrapDoElectrical(int iHp, int iDc, int iExtraTargets)
{
	object oEnter = GetEnteringObject();

	effect eVishit = EffectVisualEffect(VFX_IMP_LIGHTNING_S);
	n2f_TrapDoTarget(oEnter, eVishit, iDc, iHp, DAMAGE_TYPE_ELECTRICAL);

	// start for the lightning stream
	effect eLightning = EffectBeam(VFX_BEAM_LIGHTNING, oEnter, BODY_NODE_CHEST);


	object oCreator = GetTrapCreator(OBJECT_SELF);
	if (!GetIsObjectValid(oCreator))
		oCreator = OBJECT_SELF; // pre-placed traps have no creator

	location loc = GetLocation(oEnter);
	object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, loc);
	while (GetIsObjectValid(oTarget) && --iExtraTargets >= 0)
	{
		if (oTarget != oEnter && !GetIsReactionTypeFriendly(oTarget, oCreator))
		{
			n2f_TrapDoTarget(oTarget, eVishit, iDc, iHp, DAMAGE_TYPE_ELECTRICAL);

			// connect the lightning stream from one target to another
			ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLightning, oTarget, 0.75f);
			// set the this target as the new start for the lightning stream
			eLightning = EffectBeam(VFX_BEAM_LIGHTNING, oTarget, BODY_NODE_CHEST);
		}
		oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, loc);
	}
}

// Applies a specified #dice of fire damage to all targets that are within range
// of the target that enters the trap-trigger.
// - iDice   : #d6 dice of fire damage
// - iDc     : the Reflex Save DC
// - fRadius : radius of the AoE (default RADIUS_SIZE_MEDIUM)
void n2f_TrapDoFire(int iDice, int iDc, float fRadius = RADIUS_SIZE_MEDIUM)
{
	effect eVishit = EffectVisualEffect(VFX_IMP_FLAME_M);

	object oCreator = GetTrapCreator(OBJECT_SELF);
	if (!GetIsObjectValid(oCreator))
		oCreator = OBJECT_SELF; // pre-placed traps have no creator

	location loc = GetLocation(GetEnteringObject());
	object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, fRadius, loc);
	while (GetIsObjectValid(oTarget))
	{
		if (spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, oCreator))
		{
			n2f_TrapDoTarget(oTarget, eVishit, iDc, d6(iDice), DAMAGE_TYPE_FIRE);
		}
		oTarget = GetNextObjectInShape(SHAPE_SPHERE, fRadius, loc);
	}
}

// Applies damage to a single target in a trap's AoE. Reflex save for half
// damage. Evasion feats are respected.
// kL_note: This should probably just use GetReflexAdjustedDamage().
// - helper for
//   n2f_TrapDoFire()
//   n2f_TrapDoElectrical()
// - oTarget : the target
// - eVishit : visual hit effect
// - iDc     : the Reflex Save DC vs damage
// - iHp     : # damage
// - iType   : DAMAGE_TYPE
void n2f_TrapDoTarget(object oTarget, effect eVishit, int iDc, int iHp, int iType)
{
	if (MySavingThrow(SAVING_THROW_REFLEX, oTarget, iDc, SAVING_THROW_TYPE_TRAP) != SAVING_THROW_CHECK_FAILED)
	{
		if (GetHasFeat(FEAT_EVASION, oTarget) || GetHasFeat(FEAT_IMPROVED_EVASION, oTarget))
			return;

		iHp /= 2;
	}
	else if (GetHasFeat(FEAT_IMPROVED_EVASION, oTarget))
	{
		iHp /= 2;
	}

	if (iHp > 0)
	{
		ApplyEffectToObject(DURATION_TYPE_INSTANT, eVishit, oTarget);

		effect eHp = EffectDamage(iHp, iType);
		DelayCommand(0.f, ApplyEffectToObject(DURATION_TYPE_INSTANT, eHp, oTarget));
	}
}

// Applies a specified #dice of sonic damage to the target that enters the
// trap-trigger. No save vs damage. Target is temporarily stunned on a failed
// Will save.
// - iDice   : #d4 dice of sonic damage
// - iDc     : the Will Save DC vs stun
// - iDur    : # rounds that target is stunned if the save fails
// - iVisdur : visual hit effect id (default VFX_DUR_SPELL_DAZE)
void n2f_TrapDoSonic(int iDice, int iDc, int iDur, int iVisdur = VFX_DUR_SPELL_DAZE)
{
	location loc = GetLocation(GetEnteringObject());

	effect eVisaoe = EffectVisualEffect(VFX_HIT_SPELL_SONIC); // kL_note: perhaps that should be applied to each target
	ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVisaoe, loc);

	effect eStun = EffectStunned();
	effect eDur  = EffectVisualEffect(iVisdur);
		   eDur  = EffectLinkEffects(eStun, eDur);

	effect eHp;

	float fDur = RoundsToSeconds(iDur);

	object oCreator = GetTrapCreator(OBJECT_SELF);
	if (oCreator == OBJECT_INVALID)
		oCreator = OBJECT_SELF; // pre-placed traps have no creator

	object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_MEDIUM, loc);
	while (GetIsObjectValid(oTarget))
	{
		if (spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, oCreator))
		{
			eHp = EffectDamage(d4(iDice), DAMAGE_TYPE_SONIC);
			DelayCommand(0.f, ApplyEffectToObject(DURATION_TYPE_INSTANT, eHp, oTarget));

			if (MySavingThrow(SAVING_THROW_WILL, oTarget, iDc, SAVING_THROW_TYPE_TRAP) == SAVING_THROW_CHECK_FAILED)
			{
				ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDur, oTarget, fDur);
			}
		}
		oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_MEDIUM, loc);
	}
}

// Applies a specified #dice of cold damage to the target that enters the
// trap-trigger. No save vs damage. Target is temporarily paralyzed on a failed
// Fortitude save.
// - iDice   : #d4 dice of cold damage
// - iDc     : the Fortitude Save DC vs paralysis
// - iDur    : # rounds that target is paralyzed if the save fails
// - iVisdur : visual hit effect id (default VFX_DUR_PARALYZED)
void n2f_TrapDoFrost(int iDice, int iDc, int iDur, int iVisdur = VFX_DUR_PARALYZED)
{
	object oTarget = GetEnteringObject();

	effect e1, e2;

	e1 = EffectVisualEffect(VFX_IMP_FROST_S);
	e2 = EffectDamage(d4(iDice), DAMAGE_TYPE_COLD);
	e2 = EffectLinkEffects(e1, e2);
	ApplyEffectToObject(DURATION_TYPE_INSTANT, e2, oTarget);

	if (MySavingThrow(SAVING_THROW_FORT, oTarget, iDc, SAVING_THROW_TYPE_TRAP) == SAVING_THROW_CHECK_FAILED)
	{
		e1 = EffectVisualEffect(iVisdur);
		e2 = EffectParalyze(iDc, SAVING_THROW_FORT);
		e2 = EffectLinkEffects(e1, e2);
		ApplyEffectToObject(DURATION_TYPE_TEMPORARY, e2, oTarget, RoundsToSeconds(iDur));
	}
}

// Applies a specified #dice of acid damage to the target that enters the
// trap-trigger. No save vs damage. Target is temporarily paralyzed on a failed
// Reflex save.
// - iDice : #d6 dice of acid damage
// - iDc   : the Reflex Save DC vs paralysis
// - iDur  : # rounds that target is paralyzed if the save fails
void n2f_TrapDoAcidBlob(int iDice, int iDc, int iDur)
{
	object oTarget = GetEnteringObject();

	effect e1, e2;

	e1 = EffectVisualEffect(VFX_IMP_ACID_S); // #44 is the same SEF as #43 'VFX_IMP_ACID_L' in "visualeffects.2da"
	e2 = EffectDamage(d6(iDice), DAMAGE_TYPE_ACID);
	e2 = EffectLinkEffects(e1, e2);
	ApplyEffectToObject(DURATION_TYPE_INSTANT, e2, oTarget);

	if (MySavingThrow(SAVING_THROW_REFLEX, oTarget, iDc, SAVING_THROW_TYPE_TRAP) == SAVING_THROW_CHECK_FAILED)
	{
		e1 = EffectVisualEffect(VFX_DUR_PARALYZED);
		e2 = EffectParalyze(iDc, SAVING_THROW_FORT);
		e2 = EffectLinkEffects(e1, e2);
		ApplyEffectToObject(DURATION_TYPE_TEMPORARY, e2, oTarget, RoundsToSeconds(iDur));
	}
}

// Applies a specified #dice of divine damage to the target that enters the
// trap-trigger. No save vs damage.
// - iDiceUndead    : #d10 dice of divine damage vs undead
// - iDiceNonundead : #d4 dice of divine damage vs nonundead
void n2f_TrapDoHoly(int iDiceUndead, int iDiceNonundead)
{
	object oTarget = GetEnteringObject();

	int iHp;
	if (GetRacialType(oTarget) == RACIAL_TYPE_UNDEAD)
		iHp = d10(iDiceUndead);
	else
		iHp = d4(iDiceNonundead);

	effect eVishit = EffectVisualEffect(VFX_IMP_SUNSTRIKE);
	effect eHp     = EffectDamage(iHp, DAMAGE_TYPE_DIVINE);
		   eHp     = EffectLinkEffects(eVishit, eHp);
	ApplyEffectToObject(DURATION_TYPE_INSTANT, eHp, oTarget);
}

// Applies a specified # of piercing damage to the target that enters the
// trap-trigger. Reflex save for half damage. Evasion feats are respected.
// - based on DoTrapSpike() in "x0_i0_spells"
// - iHp : # piercing damage
void n2f_TrapDoSpike(int iHp)
{
	object oTarget = GetEnteringObject();

	effect eVishit = EffectVisualEffect(VFX_IMP_SPIKE_TRAP);
	ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVishit, GetLocation(oTarget));

	iHp = GetReflexAdjustedDamage(iHp, oTarget, 15, SAVING_THROW_TYPE_TRAP, OBJECT_SELF);
	if (iHp > 0) // kL_fix: check vs adjusted damage (not vs raw damage)
	{
		effect ePierce = EffectDamage(iHp, DAMAGE_TYPE_PIERCING);
		ApplyEffectToObject(DURATION_TYPE_INSTANT, ePierce, oTarget);
	}
}

// Applies a specified #dice of negative damage to the target that enters the
// trap-trigger. No save vs damage. Target's strength or level is permanently
// decreased on a failed Fortitude save.
// - iDice          : #d6 dice of negative damage
// - iDc            : the Fortitude Save DC vs reduction
// - iPenalty       : # strength or level reduction
// - bLevelDecrease : TRUE if level reduction; FALSE if strength reduction (default FALSE)
void n2f_TrapDoNegative(int iDice, int iDc, int iPenalty, int bLevelDecrease = FALSE)
{
	object oTarget = GetEnteringObject();

	effect eVishit = EffectVisualEffect(VFX_IMP_REDUCE_ABILITY_SCORE);
	effect eHp     = EffectDamage(d6(iDice), DAMAGE_TYPE_NEGATIVE);
		   eHp     = EffectLinkEffects(eVishit, eHp);
	ApplyEffectToObject(DURATION_TYPE_INSTANT, eHp, oTarget);

	if (MySavingThrow(SAVING_THROW_FORT, oTarget, iDc, SAVING_THROW_TYPE_TRAP) == SAVING_THROW_CHECK_FAILED)
	{
		effect ePenalty;
		if (bLevelDecrease)
			ePenalty = EffectNegativeLevel(iPenalty);
		else
			ePenalty = EffectAbilityDecrease(ABILITY_STRENGTH, iPenalty);

		ePenalty = SupernaturalEffect(ePenalty);
		ApplyEffectToObject(DURATION_TYPE_PERMANENT, ePenalty, oTarget);
	}
}

// Applies a specified #dice of acid damage to the target that enters the
// trap-trigger. Reflex save for half damage. Evasion feats are respected.
// - iDice : #d8 dice of acid damage
// - iDc   : the Reflex Save DC
void n2f_TrapDoAcidSplash(int iDice, int iDc)
{
	object oTarget = GetEnteringObject();

	effect eVishit = EffectVisualEffect(VFX_IMP_ACID_S);
	ApplyEffectToObject(DURATION_TYPE_INSTANT, eVishit, oTarget);

	int iHp = GetReflexAdjustedDamage(d8(iDice), oTarget, iDc, SAVING_THROW_TYPE_TRAP);
	if (iHp > 0) // kL_fix: don't try to apply 0 damage
	{
		effect eHp = EffectDamage(iHp, DAMAGE_TYPE_ACID);
		ApplyEffectToObject(DURATION_TYPE_INSTANT, eHp, oTarget);
	}
}

// Creates a poisonous AoE at the location of the target that enters the
// trap-trigger.
// - sScript : AoE OnEnter script
void n2f_TrapDoGas(string sScript)
{
	location loc = GetLocation(GetEnteringObject());
	effect eAoe = EffectAreaOfEffect(AOE_PER_FOGACID, sScript, "****", "****");
	ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eAoe, loc, RoundsToSeconds(2));
}

// Applies poison to a target that enters the AoE.
// - iPoisonType : the type of poison
void n2f_TrapDoGasAoeEnter(int iPoisonType)
{
	object oTarget = GetEnteringObject();

	object oCreator = GetTrapCreator(GetAreaOfEffectCreator());
	if (!GetIsObjectValid(oCreator))
		oCreator = OBJECT_SELF; // pre-placed traps have no creator

	if (spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, oCreator))
	{
		effect ePoison = EffectPoison(iPoisonType);
		ApplyEffectToObject(DURATION_TYPE_INSTANT, ePoison, oTarget);
	}
}

// Slows all targets that are within range of the target that enters the
// trap-trigger. A Reflex save is allowed.
// - iDc     : the Reflex Save DC vs slow
// - iDur    : # rounds that target is slowed if the save fails
// - fRadius : radius of the AoE (default RADIUS_SIZE_MEDIUM)
void n2f_TrapDoTangle(int iDc, int iDur, float fRadius = RADIUS_SIZE_MEDIUM)
{
	effect eVishit = EffectVisualEffect(VFX_DUR_SPELL_SLOW);
	effect eSlow   = EffectSlow();

	float fDur = RoundsToSeconds(iDur);

	location loc = GetLocation(GetEnteringObject());
	object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, fRadius, loc);
	while (GetIsObjectValid(oTarget))
	{
		if (MySavingThrow(SAVING_THROW_REFLEX, oTarget, iDc, SAVING_THROW_TYPE_TRAP) == SAVING_THROW_CHECK_FAILED)
		{
			ApplyEffectToObject(DURATION_TYPE_INSTANT, eVishit, oTarget);
			ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eSlow, oTarget, fDur);
		}
		oTarget = GetNextObjectInShape(SHAPE_SPHERE, fRadius, loc);
	}
}

//void main(){}
