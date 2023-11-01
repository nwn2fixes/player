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
//                 - change description at the top of this script to that in Dialog.Tlk #6177
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
//                 - #include "n2f_curehurt_inc"

#include "x2_inc_spellhook"
#include "n2f_curehurt_inc"

//
void main()
{
	if (!X2PreSpellCastCode())
		return;


	effect eHit = EffectVisualEffect(VFX_HIT_CURE_AOE);
	ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eHit, GetSpellTargetLocation());


	_iSpellId = GetSpellId();

	_eVisheal = EffectVisualEffect(VFX_IMP_HEALING_M);
	_eVishurt = EffectVisualEffect(VFX_IMP_SUNSTRIKE);

	int iCount = GetCasterLevel(_oCaster = OBJECT_SELF);

	_iBonus = iCount;
	if (_iBonus > 25) _iBonus = 25; // Akhacha_fix

	_iDice = 1;

	if ((iCount -= n2f_CureFaction(iCount)) > 0) // kL_add safety
		n2f_CureNearby(iCount);
}
