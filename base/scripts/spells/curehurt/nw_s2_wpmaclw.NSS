//::///////////////////////////////////////////////
//:: Warpriest Mass Cure Light Wounds
//:: 'nw_s2_wpmaclw'
//:: Copyright (c) 2006 Obsidian Entertainment, Inc.
//:://////////////////////////////////////////////
/*
	Type of Feat: Class
	Prerequisite: Warpriest level 3
	Specifics: Upon reaching 3rd level, a warpriest may cast <i>mass cure light
	wounds</i> once per day as a spell-like ability. The warpriest's class level
	is used to determine the caster level of this spell.
	Use: Selected, usable once per day.


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

	This spell heals 1d8 points of damage +1 point per caster level (maximum
	+25). First, all party members are healed regardless of range, then random
	targets within the targeted location are affected. Healing spells have a
	reverse effect when used on undead, harming instead of healing them. This
	spell can be spontaneously cast.
*/
//:://////////////////////////////////////////////
//:: Created By: Jesse Reynolds (JLR - OEI)
//:: Created On: August 01, 2005
//:://////////////////////////////////////////////
// AFW-OEI 05/20/2006: Copied from Mass CLW
// kevL 2023 dec 19 - #include "n2f_curehurt_inc" (see listed changes in
//                    "nw_s0_macurligt")
//                  - change description at the top of this script to Dialog.Tlk
//                    #181182 (feat) and #6177 (spell)
//                  - raise maximum amount cured to +25 per description
//                  - was adding the raw casterlevel to the Maximized return vs
//                    undead instead of the capped bonus
//                  - remove redundant GetFactionEqual() check from
//                    SPELL_TARGET_ALLALLIES scope
// kevL 2024 nov 28 - changed to add casterlevel bonus before metamagic

#include "x2_inc_spellhook"
#include "n2f_curehurt_inc"

//
void main()
{
	if (!X2PreSpellCastCode())
		return;


	effect eHit = EffectVisualEffect(VFX_HIT_AOE_CONJURATION); // note: MassCureLight uses VFX_HIT_CURE_AOE
	ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eHit, GetSpellTargetLocation());


	_iSpellId = GetSpellId();

	_eVisheal = EffectVisualEffect(VFX_IMP_HEALING_M);
	_eVishurt = EffectVisualEffect(VFX_HIT_SPELL_INFLICT_2); // note: MassCureLight uses VFX_IMP_SUNSTRIKE

	int iCount = GetLevelByClass(CLASS_TYPE_WARPRIEST, _oCaster = OBJECT_SELF);

	_iBonus = iCount;
	if (_iBonus > 25) _iBonus = 25; // note: WarPriest only goes to 10 levels

	_iDice = 1;

	if ((iCount -= n2f_CureFaction(iCount)) > 0) // kL_add safety
		n2f_CureNearby(iCount);
}
