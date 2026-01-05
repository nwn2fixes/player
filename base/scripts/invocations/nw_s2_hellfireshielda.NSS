//::///////////////////////////////////////////////
//:: Hellfire Shield HEARTBEAT
//:: 'nw_s2_hellfireshielda'
//:: Copyright (c) 2008 Obsidian Entertainment, Inc.
//:://////////////////////////////////////////////
/*
	Hellfire Warlock aura. Hits everyone in melee
	range on heartbeat with a Heallfire Blast in
	exchange for 1 Con per hit.  HEARTBEAT SCRIPT
*/
//:://////////////////////////////////////////////
//:: Created By: Justin Reynard (JWR-OEI)
//:: Created On: 06/20/2008
//:://////////////////////////////////////////////

#include "nw_i0_invocatns"
#include "NW_I0_SPELLS"

void main()
{
	object oCaster = GetAreaOfEffectCreator();

	// JWR-OEI 10/06/2008
	// Exit out if the player is dying! don't want to be a
	// dead guy killing all the mobs!
	if (GetIsDead(oCaster, FALSE))
	{
		return;
	}

	//SpeakString("DEBUG MESSAGE (JWR-OEI 08.22.08): HellfireShield Heartbeat");
	int bIsShieldActive = GetActionMode(oCaster, ACTION_MODE_HELLFIRE_SHIELD);
	if (!bIsShieldActive)
	{
		return;
	}

	//SpeakString("DEBUG MESSAGE(JWR-OEI 08.22.08): HellfireShield GOOOOOOOOOOOOOOOOOOOOOOOOOO");
	int nLevels = GetLevelByClass(CLASS_TYPE_HELLFIRE_WARLOCK, oCaster) + GetLevelByClass(CLASS_TYPE_WARLOCK, oCaster);
	int nChrMod = GetAbilityModifier(ABILITY_CHARISMA, oCaster);
	int nDC = 10 + (nLevels/2) + nChrMod;
	int nTotal = 0; // number of creatures we hit.
	int nDice = GetEldritchBlastLevel(oCaster) + GetHellfireBlastDiceBonus(oCaster); // number of dice to roll
	int nDmg = 0; // amount to damage
	effect eDmg; // damage effect
	effect eHit = EffectVisualEffect(VFX_HIT_SPELL_FIRE); // hit vfx VFX_HIT_SPELL_FIRE
	effect eLink; // linked effect

	// make sure we have valid const to cast this
	int nCurrCon = GetAbilityScore(oCaster, ABILITY_CONSTITUTION);
	if (nCurrCon < 1)
	{
		//Display Stopping Text
		FloatingTextStringOnCreature(GetStringByStrRef(STRREF_HELLFIRE_SHIELD_NO_CON), oCaster);
		SetActionMode(oCaster, ACTION_MODE_HELLFIRE_SHIELD, 0);
		return;
	}

	object oTarget = GetFirstInPersistentObject();
	while (GetIsObjectValid(oTarget))
	{
//		if (oTarget != oCaster && GetIsEnemy(oTarget, oCaster))
		if (oTarget != oCaster && spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)) // n2f
		{
			if (!MyResistSpell(oCaster, oTarget))
			{
				nDmg = d6(nDice);
				// Relex Throw chance to halve the damage
				if (!MySavingThrow(SAVING_THROW_REFLEX, oTarget, nDC, SAVING_THROW_TYPE_NONE))
				{
					nDmg /= 2;
				}
			}

			eDmg = EffectDamage(nDmg, DAMAGE_TYPE_MAGICAL);
			eLink = EffectLinkEffects(eHit, eDmg);
			ApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, oTarget);
			nTotal++;
		}
		oTarget = GetNextInPersistentObject();
	}

	// Apply CON Damage
	if (nTotal > 0)
	{
		effect eConst = EffectAbilityDecrease(ABILITY_CONSTITUTION, nTotal);
		eConst = SetEffectSpellId(eConst, -1); // set to invalid spell ID to allow stacking.
		ApplyEffectToObject(DURATION_TYPE_PERMANENT, eConst, oCaster);
		HellfireShieldFeedbackMsg(nTotal, STRREF_HELLFIRE_SHIELD_NAME, oCaster);
	}
}
