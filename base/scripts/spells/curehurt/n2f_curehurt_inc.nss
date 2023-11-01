// 'n2f_curehurt_inc'
/*
	Functions for cure/heal and harm/hurt spells.

	Taken and adapted from 'nw_i0_spells' and 'nwn2_inc_spells'.
*/
// kevL 2023 oct 21

#include "nw_i0_spells"
#include "nwn2_inc_metmag"

const int SPELLABILITY_WARPRIEST_MASS_HEAL = 965;
const int SPELL_UNDEFINED = -1;

// Mass Heal functions
int  n2f_HealFaction(int iCount);
void n2f_HealNearby(int iCount);
int  n2f_HealObject();

// Heal/Harm functions (incl. Mass Heal)
void n2f_HealHarmTarget(int bHeal, int bDoHurtTouch);
void n2f_spellsHealOrHarmTarget(int bHeal, int bDoHurtTouch);
void n2f_DoHealing();
void n2f_DoHarming(int iType, effect eVis, int bDoHurtTouch);
void n2f_Restore();

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

effect _eVisheal,
	   _eVishurt,
	   _eVisinfl;


/**
 * Mass Heal functions
 */

// Loops over the faction (in the area) excluding undead.
// - exits early if count reaches total # targets
// - returns the # cured
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
// undead (affects nonhostile undead if Hardcore+ difficulty)
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
		n2f_HealHarmTarget(TRUE, FALSE);
		return TRUE;
	}
	return FALSE;
}

/**
 * Heal/Harm functions (incl. Mass Heal)
 */

// Heal and Harm calls this function directly.
// 'nw_s0_heal' - n2f_HealHarmTarget(TRUE,  TRUE)
// 'nw_s0_harm' - n2f_HealHarmTarget(FALSE, FALSE)
// - bDoHurtTouch: TRUE only for Heal - not for Harm or MassHeal
void n2f_HealHarmTarget(int bHeal, int bDoHurtTouch)
{
	if (_iSpellId == SPELL_UNDEFINED) // this prevents recalculating/reconstructing these values (for Mass effects) ->
	{
		_iHealHurt = GetCasterLevel(_oCaster) * 10;

		switch (_iSpellId = GetSpellId())
		{
			default:
			case SPELL_HEAL:
			case SPELL_HARM:
				if (_iHealHurt > 150) _iHealHurt = 150;
				break;

			case SPELLABILITY_WARPRIEST_MASS_HEAL:
				_iHealHurt = GetLevelByClass(CLASS_TYPE_WARPRIEST, _oCaster) * 10; // AFW-OEI 05/20/2006: only difference w/ Mass Heal
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

	n2f_spellsHealOrHarmTarget(bHeal, bDoHurtTouch);
}

// This spell routes Heal, MassHeal, and Harm out depending on whether 'oTarget'
// is undead or not.
// - bDoHurtTouch: TRUE forces a MeleeTouchAttack if heal on undead or hurt on non-undead
//                 - in practice only Heal against undead requires a TouchAttack
//                 - Harm against non-undead should perhaps require a TouchAttack also
void n2f_spellsHealOrHarmTarget(int bHeal, int bDoHurtTouch)
{
	int bHostile = FALSE;

	if (GetRacialType(_oTarget) != RACIAL_TYPE_UNDEAD)
	{
		if (bHeal) // heal on non-undead heals
		{
			n2f_DoHealing();
		}
		else // harm on non-undead harms
		{
			n2f_DoHarming(DAMAGE_TYPE_NEGATIVE, _eVisinfl, bDoHurtTouch);
			bHostile = TRUE;
		}
	}
	else if (bHeal) // heal on undead harms
	{
		n2f_DoHarming(DAMAGE_TYPE_POSITIVE, _eVishurt, bDoHurtTouch);
		bHostile = TRUE;
	}
	else // harm on undead heals
	{
		n2f_DoHealing();
	}

	SignalEvent(_oTarget, EventSpellCastAt(_oCaster, _iSpellId, bHostile));
}

// This could be a heal spell cast on nonundead or a harm spell cast on undead.
void n2f_DoHealing()
{
	// cure spells remove the wounding effect which causes targets to bleed out - PKM-OEI 09.06.06
	RemoveEffectOfType(_oTarget, EFFECT_TYPE_WOUNDING);

	effect eHeal = EffectHeal(_iHealHurt);
	eHeal = EffectLinkEffects(eHeal, _eVisheal);
	ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, _oTarget);
}

// This could be a heal spell cast on undead a harm spell cast on nonundead.
void n2f_DoHarming(int iType, effect eVis, int bDoHurtTouch)
{
	if (spellsIsTarget(_oTarget, SPELL_TARGET_STANDARDHOSTILE, _oCaster)
		&& (!bDoHurtTouch || TouchAttackMelee(_oTarget) != TOUCH_ATTACK_RESULT_MISS)
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
		if (MySavingThrow(SAVING_THROW_WILL, _oTarget, _iSaveDc, iSaveType) == SAVING_THROW_CHECK_SUCCEEDED) // kL_changed: used to be WillSave()
			iHurt /= 2;

		if (iHurt > 0)
		{
			effect eHurt = EffectDamage(iHurt, iType);
			DelayCommand(1.f, ApplyEffectToObject(DURATION_TYPE_INSTANT, eHurt, _oTarget));
		}
	}
}

// Removes the harmful effects that are listed in the description.
// Note that the list of bad effects that should be removed varies depending on
// what source you read. AbilityDecreased and Fatigued eg. should probably be
// removed but they aren't listed in Dialog.Tlk - effects like Fatigued,
// Nauseated, Sickened can't be strictly removed because they have no standard
// EFFECT_TYPE; they are constructed as linked effects instead. Removing the
// ability decreases for Fatigued or Exhausted would remove the linked movement
// speed decrease also, and Sickened (Nauseated) has no SPELL constant either.
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

// Heals (nonundead) SPELL_TARGET_ALLALLIES or damages
// (SPELL_TARGET_STANDARDHOSTILE) undead.
// - returns TRUE if 'oTarget' is affected
int n2f_CureObject()
{
	if (GetRacialType(_oTarget) == RACIAL_TYPE_UNDEAD)
	{
		// can hurt allied undead if difficulty is Hardcore+
		// note that spellsIsTarget() returns FALSE if 'oTarget' is deaddead (not just dying)
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
	else if (spellsIsTarget(_oTarget, SPELL_TARGET_ALLALLIES, _oCaster)
		&& GetCurrentHitPoints(_oTarget) < GetMaxHitPoints(_oTarget)) // kL_add: dont heal (or count) unhurt targets
	{
		SignalEvent(_oTarget, EventSpellCastAt(_oCaster, _iSpellId, FALSE));

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
					eEffect = EffectLinkEffects(eEffect, _eVishurt);

					DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eEffect, _oTarget));
				}
			}
		}
		_oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_MEDIUM, lSpell);
	}
}

//void main(){}
