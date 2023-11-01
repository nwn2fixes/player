//::///////////////////////////////////////////////
//:: Warpriest Mass Heal
//:: 'nw_s2_wpmasheal'
//:: Copyright (c) 2006 Obisidian Entertainment, Inc.
//:://////////////////////////////////////////////
/*
	Type of Feat: Class
	Prerequisite: Warpriest level 9
	Specifics: Upon reaching 9th level, a warpriest may cast <i>mass heal</i>
	once per day as a spell-like ability. The warpriest's class level is used to
	determine the caster level of this spell.
	Use: Selected, usable once per day.
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Woo (AFW-OEI)
//:: Created On: 05/20/2006
//:://////////////////////////////////////////////
//:: PKM-OEI 07.11.06 - VFX Pass
// kevL 2023 oct 21 - change description at the top of this script to Dialog.Tlk #181190
//                  - remove bad effects per description
//                  - #include "n2f_curehurt_inc"

#include "x2_inc_spellhook"
#include "n2f_curehurt_inc"

//
void main()
{
	if (!X2PreSpellCastCode())
		return;


	effect eVisarea = EffectVisualEffect(VFX_HIT_CURE_AOE); // MassHeal uses VFX_FNF_LOS_HOLY_20
	ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVisarea, GetSpellTargetLocation());

	_iSpellId = SPELL_UNDEFINED; // script-vars will be determined later

	int iCount = GetCasterLevel(_oCaster = OBJECT_SELF);
	if ((iCount -= n2f_HealFaction(iCount)) > 0)
		n2f_HealNearby(iCount);
}
