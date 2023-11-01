//::///////////////////////////////////////////////
//:: Mass Heal
//:: 'nw_s0_masheal'
//:: Copyright (c) 2005 Obisidian Entertainment
//:://////////////////////////////////////////////
/*
	Caster Level(s): Cleric 9
	Innate Level: 9
	School: Conjuration
	Descriptor(s):
	Component(s): Verbal, Somatic
	Range: Touch
	Area of Effect / Target: Large
	Duration: Instant
	Save: None
	Spell Resistance: Yes

	All allies within the area of effect regain 10 hit points per caster level
	(maximum 150) and are cured of the following status effects: blinded,
	confused, dazzled, deafened, diseased, feebleminded, insane, nauseated,
	poisoned, and stunned. Healing spells have a reverse effect on undead,
	harming instead of healing them.
*/
//:://////////////////////////////////////////////
//:: Created By: Brock Heinz - OEI
//:: Created On: 10/06/05
//:://////////////////////////////////////////////
// ChazM 5/15/07 - modified CureObject()
// ChazM 6/7/07 - fixed, renamed and moved funcs to nwn2_inc_spells - HealHarm*()
// kevL 2023 oct 21 - change description at the top of this script to Dialog.Tlk #6211
//                  - remove bad effects per description
//                  - #include "n2f_curehurt_inc"

#include "x2_inc_spellhook"
#include "n2f_curehurt_inc"

//
void main()
{
	if (!X2PreSpellCastCode())
		return;


	effect eVisarea = EffectVisualEffect(VFX_FNF_LOS_HOLY_20); // Warpriest MassHeal uses VFX_HIT_CURE_AOE
	ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVisarea, GetSpellTargetLocation());

	_iSpellId = SPELL_UNDEFINED; // script-vars will be determined later

	int iCount = GetCasterLevel(_oCaster = OBJECT_SELF);
	if ((iCount -= n2f_HealFaction(iCount)) > 0)
		n2f_HealNearby(iCount);
}
