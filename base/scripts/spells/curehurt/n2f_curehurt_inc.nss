// 'n2f_curehurt_inc'
/*
	Functions for cure/heal and harm/inflict spells.

	Taken and adapted from 'nw_i0_spells' and 'nwn2_inc_spells'.
*/
// kevL 2023 oct 21
// kevL 2024 nov 28 - n2f_GetCureDamageTotal() is changed to add casterlevel
//                    bonus before metamagic; also fixed to allow clerics with
//                    the Healing Domain to auto-empower Maximized cures
//                  - n2f_CureObject(), n2f_MassInflict(), n2f_spellsInflictTouchAttack()
//                    have been changed to add casterlevel bonus before metamagic

#include "nw_i0_spells"
#include "nwn2_inc_metmag"

const int SPELLABILITY_WARPRIEST_MASS_HEAL = 965;
const int SPELL_UNDEFINED = -1;

// Cure Wounds functions
void n2f_spellsCure(int iVariable, int iMaximized, int iCasterlevelCap, int iVisheal, int iVishurt, int iSpellId);
int  n2f_GetCureDamageTotal(int iVariable, int iMaximized, int iCasterlevelCap);

// Mass Heal functions
int  n2f_HealFaction(int iCount);
void n2f_HealNearby(int iCount);
int  n2f_HealObject();

// Heal/Harm functions (incl. Mass Heal)
void n2f_HealHarmTarget(int bHeal, int bTouch = FALSE);
void n2f_Restore();

// General functions (Cure Heal/Harm Mass Heal)
void n2f_spellsHealOrHarmTarget(int bHeal, int bTouch);
void n2f_DoHealing();
void n2f_DoHarming(int iType, effect eVis, int bTouch);
void n2f_RemoveWounding();

// Mass Cure functions
int  n2f_CureFaction(int iCount);
void n2f_CureNearby(int iCount);
int  n2f_CureObject();

// Mass Inflict Wounds function
void n2f_MassInflict(int iCount);

// Inflict Wounds function
void n2f_spellsInflictTouchAttack(int iVisinfl, int iVisheal);


// Script variables
object _oCaster,
	   _oTarget;

int _iSpellId,
	_iSaveDc;
int _iHealHurt;
int _iDice,
	_iBonus;

effect _eVisheal, // cure or heal on nonundead; inflict or harm on undead
	   _eVishurt, // cure or heal on undead
	   _eVisinfl; // inflict or harm on nonundead


/**
 * Cure Wounds functions
 */

// called by
// - nw_s0_curminw - Cure Minor Wounds
// - nw_s0_curlgtw - Cure Light Wounds
// - nw_s0_curmodw - Cure Moderate Wounds
// - nw_s0_curserw - Cure Serious Wounds
// - nw_s0_curcrwn - Cure Critical Wounds
void n2f_spellsCure(int iVariable, int iMaximized, int iCasterlevelCap, int iVisheal, int iVishurt, int iSpellId)
{
	_oCaster = OBJECT_SELF;
	_oTarget = GetSpellTargetObject();

	_iHealHurt = n2f_GetCureDamageTotal(iVariable, iMaximized, iCasterlevelCap);

	_eVisheal = EffectVisualEffect(iVisheal);
	_eVishurt = EffectVisualEffect(iVishurt);

	_iSpellId = iSpellId;

	_iSaveDc = GetSpellSaveDC();

	n2f_spellsHealOrHarmTarget(TRUE, TRUE);
}

// Adjusts the base diceroll 'iVariable' taking into account
// - game difficulty (player only)
// - metamagic
// - Healing Domain power
// - Augment Healing feat
// called by
// - n2f_spellsCure()
// kevL 2024 nov 28 - changed to add casterlevel bonus before metamagic
//                  - fixed to allow clerics with the Healing Domain to
//                    auto-empower Maximized cures
int n2f_GetCureDamageTotal(int iVariable, int iMaximized, int iCasterlevelCap)
{
	int iBonus = GetCasterLevel(_oCaster);
	if (iBonus > iCasterlevelCap)
		iBonus = iCasterlevelCap;


	int bEasy = GetIsObjectValid(GetFactionLeader(_oTarget))
			 && GetGameDifficulty() < GAME_DIFFICULTY_CORE_RULES;

	if (bEasy)
	{
		iVariable = iMaximized + iBonus; // low or normal difficulty is treated as Maximized
	}
	else
		iVariable += iBonus;


	int iMeta = GetMetaMagicFeat();

	if (iMeta == METAMAGIC_MAXIMIZE)
	{
		iVariable = iMaximized + iBonus;

		if (bEasy)
			iVariable += iMaximized; // if low or normal difficulty then base Maximized is doubled
	}

	if (iMeta == METAMAGIC_EMPOWER
		// clerics with Healing Domain
		// - treat standard and Maximized meta as Empowered
		// - note that the NwN wiki states that clerics with Healing Domain
		//   shall empower item-casts also (not implemented)
		|| (GetHasFeat(FEAT_HEALING_DOMAIN_POWER) && !GetIsObjectValid(GetSpellCastItem())))
	{
		iVariable += iVariable / 2;
	}


	// the Augment Healing bonus is NOT affected by metamagic
	if (GetHasFeat(FEAT_AUGMENT_HEALING) && !GetIsObjectValid(GetSpellCastItem()))
	{
		iVariable += GetSpellLevel(_iSpellId) * 2;
	}

	return iVariable;
}


/**
 * Mass Heal functions
 */

// Loops over the faction (in the area) excluding undead.
// - exits early if count reaches total # targets
// - returns the # cured
// kL_change: Checking VAR_IMMUNE_TO_HEAL here optimizes the code at the expense
// that SignalEvent() does not fire for an otherwise valid target.
// called by
// - nw_s0_masheal   - Mass Heal
// - nw_s2_wpmasheal - Warpriest Mass Heal (feat)
int n2f_HealFaction(int iCount)
{
	object oArea = GetArea(_oCaster);

	_oTarget = GetFirstFactionMember(_oCaster, FALSE);
	while (GetIsObjectValid(_oTarget) && iCount > 0)
	{
		if (GetArea(_oTarget) == oArea
			&& !GetLocalInt(_oTarget, VAR_IMMUNE_TO_HEAL)
			&& GetRacialType(_oTarget) != RACIAL_TYPE_UNDEAD // do not affect undead in the faction (yet)
			&& n2f_HealObject())
		{
			--iCount;
			n2f_Restore();
		}
		_oTarget = GetNextFactionMember(_oCaster, FALSE);
	}
	return iCount;
}

// Loops over nonfaction and (any) undead in a 15' radius.
// - exits early if count reaches total # targets
// kL_change: Checking VAR_IMMUNE_TO_HEAL here optimizes the code at the expense
// that SignalEvent() does not fire for an otherwise valid target.
// - nw_s0_masheal   - Mass Heal
// - nw_s2_wpmasheal - Warpriest Mass Heal (feat)
void n2f_HealNearby(int iCount)
{
	location lSpell = GetSpellTargetLocation();
	_oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, lSpell);
	while (GetIsObjectValid(_oTarget) && iCount > 0)
	{
		if (!GetLocalInt(_oTarget, VAR_IMMUNE_TO_HEAL) // abort for creatures immune to heal
			&& (!GetFactionEqual(_oTarget, _oCaster) || GetRacialType(_oTarget) == RACIAL_TYPE_UNDEAD) // can affect undead in any faction
			&& n2f_HealObject())
		{
			--iCount;
			if (GetRacialType(_oTarget) != RACIAL_TYPE_UNDEAD)
				n2f_Restore();
		}
		_oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, lSpell);
	}
}

// This won't effect '_oTarget' unless it is a nonhostile nonundead or hostile
// undead (affects nonhostile undead if Hardcore+ difficulty).
// - returns TRUE if '_oTarget' is affected
// called by
// - n2f_HealFaction()
// - n2f_HealNearby()
int n2f_HealObject()
{
	int iTargetType;
	if (GetRacialType(_oTarget) == RACIAL_TYPE_UNDEAD)
		iTargetType = SPELL_TARGET_STANDARDHOSTILE;	// hurt nonhostile undead on Hardcore+ only
	else
		iTargetType = SPELL_TARGET_ALLALLIES;		// heal allied nonundead only

	if (spellsIsTarget(_oTarget, iTargetType, _oCaster))
	{
		n2f_HealHarmTarget(TRUE);
		return TRUE;
	}
	return FALSE;
}


/**
 * Heal/Harm functions (incl. Mass Heal)
 */

// Heal and Harm calls this function directly as does Heal Animal (companion).
// - bHeal  : TRUE if a heal spell; FALSE if a harm spell
// - bTouch : TRUE to force a TouchAttack in the hurt routines
// called by
// - nw_s0_heal       - Heal
// - nw_s0_harm       - Harm
// - nx_s0_healanimal - Heal Animal
// - n2f_HealObject()
void n2f_HealHarmTarget(int bHeal, int bTouch = FALSE)
{
	if (_iSpellId == SPELL_UNDEFINED) // this prevents recalculating/reconstructing these values (for Mass effects) ->
	{
		_iHealHurt = GetCasterLevel(_oCaster) * 10;

		switch (_iSpellId = GetSpellId())
		{
			default:
//			case SPELL_HEAL:
//			case SPELL_HARM:
//			case SPELL_HEAL_ANIMAL_COMPANION: // note: Kaedrin's PrC Pack defines casterlevel w/ GetPalRngCasterLevel()
				if (_iHealHurt > 150) _iHealHurt = 150;
				break;

			case SPELLABILITY_WARPRIEST_MASS_HEAL:
				_iHealHurt = GetLevelByClass(CLASS_TYPE_WARPRIEST, _oCaster) * 10;
				// no break;

			case SPELL_MASS_HEAL:
				if (_iHealHurt > 250) _iHealHurt = 250;
				break;
		}

		_iSaveDc = GetSpellSaveDC();

		_eVisheal = EffectVisualEffect(VFX_IMP_HEALING_G); // kL_changed: used to be VFX_IMP_HEALING_X
		_eVishurt = EffectVisualEffect(VFX_IMP_SUNSTRIKE); // kL_changed: used to be VFX_IMP_HEALING_G
		_eVisinfl = EffectVisualEffect(VFX_HIT_SPELL_INFLICT_6);
	}

	n2f_spellsHealOrHarmTarget(bHeal, bTouch);
}

// Removes the harmful effects that are listed in the Tlk descriptions.
// Note that the list of bad effects that should be removed varies depending on
// what source you read. AbilityDecreased and Fatigued eg. should probably be
// removed but they aren't listed in Dialog.Tlk - effects like Fatigued,
// Nauseated, Sickened can't be easily removed because they have no standard
// EFFECT_TYPE; they are constructed as linked effects instead. Removing the
// ability decreases for Fatigued or Exhausted would remove the linked movement
// speed decrease also, and Sickened (Nauseated) has no SPELL_* constant either.
// See 'nwn2_inc_spells'
// - EffectFatigue()
// - EffectExhausted()
// - EffectSickened()
// If AbilityDecreased is implemented care should be taken to not remove buffs
// by using GetIsPositiveBuffSpellWithNegativeEffect() in 'x0_i0_talent' (note
// that the stock version of that function does not contain a complete list of
// relevant buff spells).
// called by
// - nw_s0_heal - Heal
// - n2f_HealFaction()
// - n2f_HealNearby()
void n2f_Restore()
{
	int bRestore;

	effect eEffect = GetFirstEffect(_oTarget);
	while (GetIsEffectValid(eEffect))
	{
		bRestore = FALSE;

		if (GetEffectSpellId(eEffect) == SPELL_FEEBLEMIND)
			bRestore = TRUE;
		else
		{
			switch (GetEffectType(eEffect))
			{
				case EFFECT_TYPE_BLINDNESS:
				case EFFECT_TYPE_CONFUSED:
				case EFFECT_TYPE_DAZED:
				case EFFECT_TYPE_DEAF:
				case EFFECT_TYPE_DISEASE:
				case EFFECT_TYPE_INSANE:
//				case EFFECT_TYPE_: // nauseated - can't do.
				case EFFECT_TYPE_POISON:
				case EFFECT_TYPE_STUNNED:
					bRestore = TRUE;
					break;
			}
		}

		if (bRestore)
		{
			RemoveEffect(_oTarget, eEffect);
			eEffect = GetFirstEffect(_oTarget); // restart the loop
		}
		else
			eEffect = GetNextEffect(_oTarget);
	}
}


/**
 * General functions (Cure Heal/Harm Mass Heal)
 */

// This spell routes Heal, MassHeal, and Harm out depending on whether 'oTarget'
// is undead or not.
// - bHeal  : TRUE if a heal spell; FALSE if a harm spell
// - bTouch : TRUE to force a TouchAttack in the hurt routines
// called by
// - n2f_spellsCure()
// - n2f_HealHarmTarget()
void n2f_spellsHealOrHarmTarget(int bHeal, int bTouch)
{
	int bUndead = GetRacialType(_oTarget) == RACIAL_TYPE_UNDEAD;

	if ((bHeal && !bUndead) || (!bHeal && bUndead)) // heal on nonundead or hurt on undead
	{
		n2f_DoHealing();
	}
	else if (bHeal && bUndead) // heal on undead
	{
		n2f_DoHarming(DAMAGE_TYPE_POSITIVE, _eVishurt, bTouch);
	}
	else // (!bHeal && !bUndead) // hurt on nonundead
	{
		n2f_DoHarming(DAMAGE_TYPE_NEGATIVE, _eVisinfl, bTouch);
	}
}

// This could be a heal spell cast on nonundead or a hurt spell cast on undead.
// - clears EFFECT_TYPE_WOUNDING
// called by
// - n2f_spellsHealOrHarmTarget()
void n2f_DoHealing()
{
	SignalEvent(_oTarget, EventSpellCastAt(_oCaster, _iSpellId, FALSE));

	n2f_RemoveWounding();

	effect eHeal = EffectHeal(_iHealHurt);
		   eHeal = EffectLinkEffects(eHeal, _eVisheal);
	ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, _oTarget);
}

// This could be a hurt spell cast on nonundead or a heal spell cast on undead.
// - bTouch : TRUE to force a TouchAttack
// called by
// - n2f_spellsHealOrHarmTarget()
void n2f_DoHarming(int iType, effect eVis, int bTouch)
{
	if (spellsIsTarget(_oTarget, SPELL_TARGET_STANDARDHOSTILE, _oCaster))
	{
		SignalEvent(_oTarget, EventSpellCastAt(_oCaster, _iSpellId)); // kL_change: SignalEvent() after spellsIsTarget()

		if ((!bTouch || TouchAttackMelee(_oTarget) != TOUCH_ATTACK_RESULT_MISS)
			&& MyResistSpell(_oCaster, _oTarget) == SPELL_RESISTANCE_FAILURE)
		{
			ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, _oTarget);

			int iSaveType = SAVING_THROW_TYPE_NONE; // kL_add: base the savetype on 'iType' ->
			switch (iType)
			{
				case DAMAGE_TYPE_POSITIVE: iSaveType = SAVING_THROW_TYPE_POSITIVE; break;
				case DAMAGE_TYPE_NEGATIVE: iSaveType = SAVING_THROW_TYPE_NEGATIVE; break;
			}

			int iHurt = _iHealHurt;
			if (WillSave(_oTarget, _iSaveDc, iSaveType, _oCaster) == SAVING_THROW_CHECK_SUCCEEDED) // do not use MySavingThrow() <-
				iHurt /= 2;

			if (iHurt > 0)
			{
				effect eHurt = EffectDamage(iHurt, iType);
				DelayCommand(1.f, ApplyEffectToObject(DURATION_TYPE_INSTANT, eHurt, _oTarget)); // kL_TODO: shorten that delay
			}
		}
	}
}

// kL - Removes any Wounding effects.
// called by
// - n2f_DoHealing()
// - n2f_CureObject()
void n2f_RemoveWounding()
{
	effect eEffect = GetFirstEffect(_oTarget);
	while (GetIsEffectValid(eEffect))
	{
		if (GetEffectType(eEffect) == EFFECT_TYPE_WOUNDING)
		{
			RemoveEffect(_oTarget, eEffect);
			eEffect = GetFirstEffect(_oTarget);
		}
		else
			eEffect = GetNextEffect(_oTarget);
	}
}


/**
 * Mass Cure functions
 */

// Loops over the faction (in the area) excluding undead.
// - exits early if count reaches total # targets
// - returns the # cured
// called by
// - nw_s0_macurligt - Mass Cure Light Wounds
// - nw_s0_macurmod  - Mass Cure Moderate Wounds
// - nw_s0_macurseri - Mass Cure Serious Wounds
// - nw_s0_macurcrit - Mass Cure Critical Wounds
// - nw_s2_wpmaclw   - Warpriest Mass Cure Light Wounds
int n2f_CureFaction(int iCount)
{
	object oArea = GetArea(_oCaster);

	_oTarget = GetFirstFactionMember(_oCaster, FALSE);
	while (GetIsObjectValid(_oTarget) && iCount > 0)
	{
		if (GetArea(_oTarget) == oArea && GetRacialType(_oTarget) != RACIAL_TYPE_UNDEAD // do not affect undead in the faction (yet)
			&& n2f_CureObject())
		{
			--iCount;
		}
		_oTarget = GetNextFactionMember(_oCaster, FALSE);
	}
	return iCount;
}

// Loops over nonfaction and (any) undead in a 15' radius.
// - exits early if count reaches total # targets
// called by
// - nw_s0_macurligt - Mass Cure Light Wounds
// - nw_s0_macurmod  - Mass Cure Moderate Wounds
// - nw_s0_macurseri - Mass Cure Serious Wounds
// - nw_s0_macurcrit - Mass Cure Critical Wounds
// - nw_s2_wpmaclw   - Warpriest Mass Cure Light Wounds
void n2f_CureNearby(int iCount)
{
	_iSaveDc = GetSpellSaveDC();

	location lSpell = GetSpellTargetLocation();
	_oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, lSpell);
	while (GetIsObjectValid(_oTarget) && iCount > 0)
	{
		if ((!GetFactionEqual(_oTarget, _oCaster) || GetRacialType(_oTarget) == RACIAL_TYPE_UNDEAD) // can affect undead in any faction
			&& n2f_CureObject())
		{
			--iCount;
		}
		_oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, lSpell);
	}
}

// Cures nonundead (SPELL_TARGET_ALLALLIES) or hurts undead
// (SPELL_TARGET_STANDARDHOSTILE).
// - returns TRUE if 'oTarget' is affected
// called by
// - n2f_CureFaction()
// - n2f_CureNearby()
// kevL 2024 nov 28 - changed to add casterlevel bonus before metamagic
int n2f_CureObject()
{
	if (GetRacialType(_oTarget) == RACIAL_TYPE_UNDEAD)
	{
		// can hurt allied undead if difficulty is Hardcore+
		// note that spellsIsTarget() returns FALSE if 'oTarget' is deaddead
		// (ie dying aka bleeding-out can return TRUE)
		if (spellsIsTarget(_oTarget, SPELL_TARGET_STANDARDHOSTILE, _oCaster))
		{
			SignalEvent(_oTarget, EventSpellCastAt(_oCaster, _iSpellId));

			float fDelay = GetRandomDelay();
			if (MyResistSpell(_oCaster, _oTarget, fDelay) == SPELL_RESISTANCE_FAILURE)
			{
				int iPositive = ApplyMetamagicVariableMods(d8(_iDice) + _iBonus, _iDice * 8 + _iBonus);
				if (MySavingThrow(SAVING_THROW_WILL,
								  _oTarget,
								  _iSaveDc,
								  SAVING_THROW_TYPE_POSITIVE,
								  _oCaster,
								  fDelay) != SAVING_THROW_CHECK_FAILED)
				{
					iPositive /= 2;
				}

				if (iPositive > 0) // kL_add safety
				{
					effect ePositive = EffectDamage(iPositive, DAMAGE_TYPE_POSITIVE);
						   ePositive = EffectLinkEffects(ePositive, _eVishurt);
					DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, ePositive, _oTarget));
				}
			}
			return TRUE;
		}
	}
	else if (spellsIsTarget(_oTarget, SPELL_TARGET_ALLALLIES, _oCaster))
//		&& GetCurrentHitPoints(_oTarget) < GetMaxHitPoints(_oTarget) // kL_add: don't heal (or count) unhurt targets
		// note that enabling this bypasses n2f_RemoveWounding() on targets that
		// have EFFECT_TYPE_WOUNDING even though they can currently be at full HP
		// So let's bypass that check and let any Wounding effects get removed
	{
		SignalEvent(_oTarget, EventSpellCastAt(_oCaster, _iSpellId, FALSE));

		n2f_RemoveWounding(); // kL_add: clear bleedout effect for Mass Cure(s)

		int iPositive = ApplyMetamagicVariableMods(d8(_iDice) + _iBonus, _iDice * 8 + _iBonus);
		if (GetHasFeat(FEAT_AUGMENT_HEALING) && !GetIsObjectValid(GetSpellCastItem()))
		{
			iPositive += GetSpellLevel(_iSpellId) * 2;
		}

		effect eHeal = EffectHeal(iPositive);
			   eHeal = EffectLinkEffects(eHeal, _eVisheal);
		DelayCommand(GetRandomDelay(), ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, _oTarget));

		return TRUE;
	}

	return FALSE;
}


/**
 * Mass Inflict Wounds function
 */

// Used by Mass Inflict scripts.
// called by
// - nw_s0_mainfligt - Mass Inflict Light Wounds
// - nw_s0_mainfmod  - Mass Inflict Moderate Wounds
// - nw_s0_mainfseri - Mass Inflict Serious Wounds
// - nw_s0_mainfcrit - Mass Inflict Critical Wounds
// kevL 2024 nov 28 - changed to add casterlevel bonus before metamagic
void n2f_MassInflict(int iCount)
{
	_iSpellId = GetSpellId();

	location lSpell = GetSpellTargetLocation();

	effect eVisAoe = EffectVisualEffect(VFX_FNF_LOS_EVIL_10); // kL_fix: apply location VFX ->
	ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVisAoe, lSpell);

	_iSaveDc = GetSpellSaveDC();

	effect eEffect;
	int iNegative;
	float fDelay;

	_oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_MEDIUM, lSpell);
	while (GetIsObjectValid(_oTarget) && iCount > 0)
	{
		if (GetRacialType(_oTarget) == RACIAL_TYPE_UNDEAD) // if the target is an allied undead it is healed
		{
			if (spellsIsTarget(_oTarget, SPELL_TARGET_ALLALLIES, _oCaster))
			{
				SignalEvent(_oTarget, EventSpellCastAt(_oCaster, _iSpellId, FALSE));

				--iCount;

				iNegative = ApplyMetamagicVariableMods(d8(_iDice) + _iBonus, _iDice * 8 + _iBonus);

				eEffect = EffectHeal(iNegative);
				eEffect = EffectLinkEffects(eEffect, _eVisheal);

				DelayCommand(GetRandomDelay(), ApplyEffectToObject(DURATION_TYPE_INSTANT, eEffect, _oTarget));
			}
			else
			{
				FloatingTextStrRefOnCreature(184683, _oCaster, FALSE); // "Target is immune to that effect."
				// kL_fix: do not return early here.
			}
		}
		else if (spellsIsTarget(_oTarget, SPELL_TARGET_STANDARDHOSTILE, _oCaster)) // hurts nonhostile on Hardcore+
		{
			SignalEvent(_oTarget, EventSpellCastAt(_oCaster, _iSpellId));

			--iCount;

			fDelay = GetRandomDelay();
			if (MyResistSpell(_oCaster, _oTarget, fDelay) == SPELL_RESISTANCE_FAILURE)
			{
				iNegative = ApplyMetamagicVariableMods(d8(_iDice) + _iBonus, _iDice * 8 + _iBonus);
				if (MySavingThrow(SAVING_THROW_WILL,
								  _oTarget,
								  _iSaveDc,
								  SAVING_THROW_TYPE_NEGATIVE,
								  _oCaster,
								  fDelay) != SAVING_THROW_CHECK_FAILED)
				{
					iNegative /= 2;
				}

				if (iNegative > 0) // kL_add safety
				{
					eEffect = EffectDamage(iNegative, DAMAGE_TYPE_NEGATIVE);
					eEffect = EffectLinkEffects(eEffect, _eVisinfl);

					DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eEffect, _oTarget));
				}
			}
		}
		_oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_MEDIUM, lSpell);
	}
}


/**
 * Inflict Wounds function
 */

// Inflicts wounds vs nonundead (with a touchattack) or heals undead.
// - adapted from spellsInflictTouchAttack() in "x0_i0_spells"
// - note that the kPrC Pack has oei_spellsInflictTouchAttack() in
//   "oei_i0_spells"
// - iVisinfl : vis to play if hurt by spell (vs nonundead)
// - iVisheal : vis to play if healed by spell (vs undead)
// called by
// - x0_s0_inflict - Inflict Wounds (Minor, Light, Moderate, Serious, Critical
//                   and Blackguard feats Serious, Critical)
// kevL 2024 nov 28 - changed to add casterlevel bonus before metamagic
void n2f_spellsInflictTouchAttack(int iVisinfl, int iVisheal)
{
	_oTarget = GetSpellTargetObject();

	// note: Since these spells are flagged "HostileSetting" in Spells.2da
	// it's gonna be kinda hard to target a nonhostile creature.

	if (GetRacialType(_oTarget) == RACIAL_TYPE_UNDEAD)
	{
		SignalEvent(_oTarget, EventSpellCastAt(_oCaster, _iSpellId, FALSE));

		_eVisheal = EffectVisualEffect(iVisheal);
		effect eHeal = EffectHeal(_iHealHurt);
			   eHeal = EffectLinkEffects(eHeal, _eVisheal);

		ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, _oTarget);
	}
	else if (spellsIsTarget(_oTarget, SPELL_TARGET_STANDARDHOSTILE, _oCaster))
	{
		SignalEvent(_oTarget, EventSpellCastAt(_oCaster, _iSpellId)); // kL_change: signalevent before touchattack

		int iTouch = TouchAttackMelee(_oTarget);
		if (iTouch != TOUCH_ATTACK_RESULT_MISS
			&& MyResistSpell(_oCaster, _oTarget) == SPELL_RESISTANCE_FAILURE)
		{
			if (iTouch == TOUCH_ATTACK_RESULT_CRITICAL
				&& !GetIsImmune(_oTarget, IMMUNITY_TYPE_CRITICAL_HIT))
			{
				_iHealHurt *= 2;
			}

			if (MySavingThrow(SAVING_THROW_WILL,
							  _oTarget,
							  GetSpellSaveDC(),
							  SAVING_THROW_TYPE_NEGATIVE,
							  _oCaster) != SAVING_THROW_CHECK_FAILED)
			{
				_iHealHurt /= 2;
			}

			if (_iHealHurt != 0)
			{
				_eVisinfl = EffectVisualEffect(iVisinfl);
				effect eNegative = EffectDamage(_iHealHurt, DAMAGE_TYPE_NEGATIVE);
					   eNegative = EffectLinkEffects(eNegative, _eVisinfl);

				ApplyEffectToObject(DURATION_TYPE_INSTANT, eNegative, _oTarget);
			}
		}
	}
}

//void main(){}
