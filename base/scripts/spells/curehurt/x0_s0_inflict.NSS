//::///////////////////////////////////////////////
//:: Inflict Wounds
//:: 'x0_s0_inflict'
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
	This script is used by all the inflict spells.
*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: July 2002
//:://////////////////////////////////////////////
// kevL 2023 dec 18 - #include "n2f_curehurt_inc"
//                  - signal SpellCastAt event even if touchattack misses
//                  - allow critical hit for the touchattack
//                  - do not apply Empower to a constant bonus
//                  - use (hopefully) more appropriate VFX
//                  - do Save vs SAVING_THROW_TYPE_NEGATIVE
// kevL 2024 nov 28 - changed to add casterlevel bonus before metamagic

#include "x2_inc_spellhook"
#include "n2f_curehurt_inc"

//
void main()
{
	if (!X2PreSpellCastCode())
		return;


	_oCaster = OBJECT_SELF;

	int iMaximized, iCasterlevelCap, iVisinfl, iVisheal;

	switch (_iSpellId = GetSpellId())
	{
		case SPELL_INFLICT_MINOR_WOUNDS:
			_iHealHurt      = 1;
			iMaximized      = 1;
			iCasterlevelCap = 0;
			iVisinfl        = VFX_HIT_SPELL_INFLICT_1;
			iVisheal        = VFX_IMP_HEALING_S;
			break;

		case SPELL_INFLICT_LIGHT_WOUNDS:
			_iHealHurt      = d8();
			iMaximized      = 8;
			iCasterlevelCap = 5;
			iVisinfl        = VFX_HIT_SPELL_INFLICT_2;
			iVisheal        = VFX_IMP_HEALING_M;
			break;

		case SPELL_INFLICT_MODERATE_WOUNDS:
			_iHealHurt      = d8(2);
			iMaximized      = 16;
			iCasterlevelCap = 10;
			iVisinfl        = VFX_HIT_SPELL_INFLICT_3;
			iVisheal        = VFX_IMP_HEALING_L;
			break;

		case SPELL_INFLICT_SERIOUS_WOUNDS:
		case SPELLABILITY_BG_INFLICT_SERIOUS_WOUNDS:
//		case SPELL_BG_InflictSerious: // kPrC
			_iHealHurt      = d8(3);
			iMaximized      = 24;
			iCasterlevelCap = 15;
			iVisinfl        = VFX_HIT_SPELL_INFLICT_4;
			iVisheal        = VFX_IMP_HEALING_X;
			break;

		case SPELL_INFLICT_CRITICAL_WOUNDS:
		case SPELLABILITY_BG_INFLICT_CRITICAL_WOUNDS:
//		case SPELL_BG_InflictCritical: // kPrC
			_iHealHurt      = d8(4);
			iMaximized      = 32;
			iCasterlevelCap = 20;
			iVisinfl        = VFX_HIT_SPELL_INFLICT_5;
			iVisheal        = VFX_IMP_HEALING_G;
			break;

		default:
			SendMessageToPC(GetFirstPC(FALSE), "x0_s0_inflict <c=red>ERROR</c> : unrecognized Spell ID for Inflict Wounds");
			return;
	}

	switch (_iSpellId)
	{
		case SPELLABILITY_BG_INFLICT_SERIOUS_WOUNDS:
		case SPELLABILITY_BG_INFLICT_CRITICAL_WOUNDS:
//		case SPELL_BG_InflictSerious:  // kPrC
//		case SPELL_BG_InflictCritical: // kPrC
			_iBonus = GetLevelByClass(CLASS_TYPE_BLACKGUARD, _oCaster);
//			_iBonus = GetBlackguardCasterLevel(_oCaster); // kPrC
			break;

		default:
			_iBonus = GetCasterLevel(_oCaster);
			break;
	}

	if (_iBonus > iCasterlevelCap)
		_iBonus = iCasterlevelCap;

	_iHealHurt = ApplyMetamagicVariableMods(_iHealHurt + _iBonus, iMaximized + _iBonus);

/*	// kPrC ->
	// Use this instead of GetMeleeTouchSpecDamage() in "cmi_ginc_caster"
	if (GetHasFeat(FEAT_MELEE_TOUCH_SPELL_SPECIALIZATION))
	{
		switch (_iSpellId)
		{
			case SPELL_INFLICT_LIGHT_WOUNDS:
				_iHealHurt += 2;
				break;

			case SPELL_INFLICT_MODERATE_WOUNDS:
				_iHealHurt += 4;
				break;

			case SPELL_INFLICT_SERIOUS_WOUNDS:
			case SPELLABILITY_BG_INFLICT_SERIOUS_WOUNDS:
			case SPELL_BG_InflictSerious:
				_iHealHurt += 6;
				break;

			case SPELL_INFLICT_CRITICAL_WOUNDS:
			case SPELLABILITY_BG_INFLICT_CRITICAL_WOUNDS:
			case SPELL_BG_InflictCritical:
				_iHealHurt += 8;
				break;
		}
	} */

	n2f_spellsInflictTouchAttack(iVisinfl, iVisheal);
}
