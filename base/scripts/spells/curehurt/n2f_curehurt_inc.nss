// 'n2f_curehurt_inc'
/*
	Functions for cure/heal and harm/inflict spells.

	Taken and adapted from 'nw_i0_spells' and 'nwn2_inc_spells'.
*/
// kevL 2023 oct 21

#include "nw_i0_spells"
#include "nwn2_inc_metmag"

const int SPELLABILITY_WARPRIEST_MASS_HEAL = 965;
const int SPELL_UNDEFINED = -1;

// Cure Wounds functions
void n2f_spellsCure(int iHeal, int iMaxBonus, int iMaximized, int iVisheal, int iVishurt, int iSpellId);
int  n2f_GetCureDamageTotal(int iHeal, int iMaxBonus, int iMaximized);

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

// Mass Inflict function
void n2f_MassInflict(int iCount);


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

//
void n2f_spellsCure(int iHeal, int iMaxBonus, int iMaximized, int iVisheal, int iVishurt, int iSpellId)
{
	_oCaster = OBJECT_SELF;
	_oTarget = GetSpellTargetObject();

	_iHealHurt = n2f_GetCureDamageTotal(iHeal, iMaxBonus, iMaximized);

	_eVisheal = EffectVisualEffect(iVisheal);
	_eVishurt = EffectVisualEffect(iVishurt);

	_iSpellId = iSpellId;

	_iSaveDc = GetSpellSaveDC();

	n2f_spellsHealOrHarmTarget(TRUE, TRUE);
}

// Adjusts the base variable heal 'iHeal' taking into account
// - game difficulty
// - metamagic
// - Healing Domain power
// - Augment Healing feat
int n2f_GetCureDamageTotal(int iHeal, int iMaxBonus, int iMaximized)
{
	int iMeta = GetMetaMagicFeat();

	if (GetIsObjectValid(GetFactionLeader(_oTarget))
		&& GetGameDifficulty() < GAME_DIFFICULTY_CORE_RULES)
	{
		iHeal = iMaximized; // low or normal difficulty is treated as Maximized

		if (iMeta == METAMAGIC_MAXIMIZE)
		{
			iHeal += iMaximized; // if low or normal difficulty then base Maximized is doubled
		}
		else if (iMeta == METAMAGIC_EMPOWER
			|| (GetHasFeat(FEAT_HEALING_DOMAIN_POWER) && !GetIsObjectValid(GetSpellCastItem())))
		{
			iHeal += iHeal / 2;
		}
	}
	else if (iMeta == METAMAGIC_MAXIMIZE)
	{
		iHeal = iMaximized;
	}
	else if (iMeta == METAMAGIC_EMPOWER
		|| (GetHasFeat(FEAT_HEALING_DOMAIN_POWER) && !GetIsObjectValid(GetSpellCastItem())))
	{
		iHeal += iHeal / 2;
	}


	if (GetHasFeat(FEAT_AUGMENT_HEALING) && !GetIsObjectValid(GetSpellCastItem()))
	{
		iHeal += GetSpellLevel(_iSpellId) * 2;
	}


	int iBonus = GetCasterLevel(_oCaster);
	if (iBonus > iMaxBonus)
		iBonus = iMaxBonus;

	return iHeal + iBonus;
}


/**
 * Mass Heal functions
 */

// Loops over the faction (in the area) excluding undead.
// - exits early if count reaches total # targets
// - returns the # cured
// kL_change: Checking VAR_IMMUNE_TO_HEAL here optimizes the code at the expense
// that SignalEvent() does not fire for an otherwise valid target.
int n2f_HealFaction(int iCount) // returns the # HealHarmed
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
void n2f_HealNearby(int iCount) // returns the # HealHarmed
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

// This won't effect 'oTarget' unless it is a nonhostile nonundead or hostile
// undead (affects nonhostile undead if Hardcore+ difficulty).
// - returns TRUE if 'oTarget' is affected
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
				int iPositive = ApplyMetamagicVariableMods(d8(_iDice), _iDice * 8) + _iBonus; // kL_fix: the constant bonus should not be modified
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

		int iPositive = ApplyMetamagicVariableMods(d8(_iDice), _iDice * 8) + _iBonus;
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
 * Mass Inflict function
 */

// - used by Mass Inflict 'nw_s0_mainf*' scripts
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

				iNegative = ApplyMetamagicVariableMods(d8(_iDice), _iDice * 8) + _iBonus; // kL_fix: the constant bonus should not be modified

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
				iNegative = ApplyMetamagicVariableMods(d8(_iDice), _iDice * 8) + _iBonus; // kL_fix: the constant bonus should not be modified
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

//void main(){}
