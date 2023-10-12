//::///////////////////////////////////////////////
//:: Mass Cure Light Wounds
//:: 'nw_s0_macurligt'
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
	Caster Level(s): Bard 5, Cleric 5, Druid 6
	Innate Level: 5
	School: Conjuration
	Descriptor(s):
	Component(s): Verbal, Somatic
	Range: Close
	Area of Effect / Target: One creature / level
	Duration: Instant
	Save: Will 1/2
	Spell Resistance: Yes

	This spell heals 1d8 points of damage +1 point per caster level
	(maximum +25). First, all party members are healed regardless of range, then
	random targets within the targeted location are affected. Healing spells
	have a reverse effect when used on undead, harming instead of healing them.
	This spell can be spontaneously cast.
*/
//:://////////////////////////////////////////////
//:: Created By: Jesse Reynolds (JLR - OEI)
//:: Created On: August 01, 2005
//:://////////////////////////////////////////////
// JLR - OEI 08/01/05 NWN2 3.5 - Metamagic cleanup, Name change
// JLR - OEI 08/23/05 - Metamagic changes
// Brock H. - OEI 10/06/05 - Added code to heal faction, then nearby, and cap based on level
// AFW-OEI 06/18/2007 - Will save for 1/2
// Akhacha 2023/09/21 - Raised amount cured based on level to +25 per description
// kevL 2023 oct 8 - tidy and refactor
//                 - change description at the top of this script to that in Dialog.Tlk
//                 - remove unused GetMetaMagicFeat() and args
//                 - remove int_return from CureNearby() (unused)
//                 - pass 'iBonus' instead of 'iCasterlevel' to subfunctions
//                 - do not Empower the constant bonus (fixed only for undead;
//                   already correct for healing allies)
//                 - add a bool_return to CureObject() so that nonallies and
//                   unaffected undead are not counted
//                 - add remarked code to bypass allies at full health from the
//                   count (if desired)
//                 - restrict affected factionmembers to the area of the caster
//                 - undead save vs SAVING_THROW_TYPE_POSITIVE rather than _NONE

#include "x2_inc_spellhook"
#include "nwn2_inc_spells"

int CureFaction(int iCurable, effect eVishurt, effect eVisheal, int iBonus);
void CureNearby(int iCurable, effect eVishurt, effect eVisheal, int iBonus);
int CureObject(object oTarget, effect eVishurt, effect eVisheal, int iBonus);

object _oCaster;
int _iSpellId;

//
void main()
{
	if (!X2PreSpellCastCode())
	{
		// If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
		return;
	}

	_iSpellId = GetSpellId();

	effect eHit = EffectVisualEffect(VFX_HIT_CURE_AOE);
	ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eHit, GetSpellTargetLocation());


	effect eVishurt = EffectVisualEffect(VFX_IMP_SUNSTRIKE);
	effect eVisheal = EffectVisualEffect(VFX_IMP_HEALING_M);

	int iCurable = GetCasterLevel(_oCaster = OBJECT_SELF);

	int iBonus = iCurable;
	if (iBonus > 25) iBonus = 25; // Akhacha_fix

	if ((iCurable -= CureFaction(iCurable, eVishurt, eVisheal, iBonus)) > 0) // kL_add safety
		CureNearby(iCurable, eVishurt, eVisheal, iBonus);
}


// Loops over the faction (in the area) excluding any party-undead.
// - exits early if count reaches total # targets
// - returns the # cured
int CureFaction(int iCurable, effect eVishurt, effect eVisheal, int iBonus)
{
	int iCured = 0;

	object oArea = GetArea(_oCaster);

	object oTarget = GetFirstFactionMember(_oCaster, FALSE);
	while (GetIsObjectValid(oTarget) && iCured < iCurable)
	{
		if (GetArea(oTarget) == oArea && GetRacialType(oTarget) != RACIAL_TYPE_UNDEAD // do not affect undead in the faction (yet)
			&& CureObject(oTarget, eVishurt, eVisheal, iBonus))
		{
			++iCured;
		}
		oTarget = GetNextFactionMember(_oCaster, FALSE);
	}
	return iCured;
}

// Loops over non-faction and (any) undead in a 15' radius.
// - exits early if count reaches total # targets
void CureNearby(int iCurable, effect eVishurt, effect eVisheal, int iBonus)
{
	int iCured = 0;

	location lSpell = GetSpellTargetLocation();
	object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, lSpell);
	while (GetIsObjectValid(oTarget) && iCured < iCurable)
	{
		if ((!GetFactionEqual(oTarget, _oCaster) || GetRacialType(oTarget) == RACIAL_TYPE_UNDEAD) // can affect undead in any faction
			&& CureObject(oTarget, eVishurt, eVisheal, iBonus))
		{
			++iCured;
		}
		oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, lSpell);
	}
}

// Heals (not undead) SPELL_TARGET_ALLALLIES or damages (SPELL_TARGET_STANDARDHOSTILE) undead.
// - returns TRUE if 'oTarget' is affected
int CureObject(object oTarget, effect eVishurt, effect eVisheal, int iBonus)
{
	if (GetRacialType(oTarget) == RACIAL_TYPE_UNDEAD)
	{
		// can hurt allied undead if difficulty is Hardcore+
		// note that spellsIsTarget() returns FALSE if 'oTarget' is deaddead (not just dying)
		if (spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, _oCaster))
		{
			SignalEvent(oTarget, EventSpellCastAt(_oCaster, _iSpellId));

			float fDelay = GetRandomDelay();
			if (MyResistSpell(_oCaster, oTarget, fDelay) == SPELL_RESISTANCE_FAILURE)
			{
				int iPositive = ApplyMetamagicVariableMods(d8(), 8) + iBonus; // kL_fix: the constant bonus should not be modified
				if (MySavingThrow(SAVING_THROW_WILL,
								  oTarget,
								  GetSpellSaveDC(),
								  SAVING_THROW_TYPE_POSITIVE,
								  _oCaster,
								  fDelay) != SAVING_THROW_CHECK_FAILED)
				{
					iPositive /= 2;
				}

				if (iPositive > 0) // kL_add safety
				{
					effect ePositive = EffectDamage(iPositive, DAMAGE_TYPE_POSITIVE);
					ePositive = EffectLinkEffects(ePositive, eVishurt);
					DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, ePositive, oTarget));
				}
			}
			return TRUE;
		}
	}
	else if (spellsIsTarget(oTarget, SPELL_TARGET_ALLALLIES, _oCaster))
//		&& GetCurrentHitPoints(oTarget) < GetMaxHitPoints(oTarget)) // kL_add: dont heal (or count) unhurt targets
	{
		SignalEvent(oTarget, EventSpellCastAt(_oCaster, _iSpellId, FALSE));

		int iPositive = ApplyMetamagicVariableMods(d8(), 8) + iBonus;
		if (GetHasFeat(FEAT_AUGMENT_HEALING) && !GetIsObjectValid(GetSpellCastItem()))
		{
			iPositive += GetSpellLevel(_iSpellId) * 2;
		}

		effect eHeal = EffectHeal(iPositive);
		eHeal = EffectLinkEffects(eHeal, eVisheal);
		DelayCommand(GetRandomDelay(), ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, oTarget));

		return TRUE;
	}

	return FALSE;
}
