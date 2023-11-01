//::///////////////////////////////////////////////
//:: Harm
//:: 'nw_s0_harm'
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
//:: Created By: Keith Soleski
//:: Created On: Jan 18, 2001
//:://////////////////////////////////////////////
//:: VFX Pass By: Preston W, On: June 20, 2001
//:: Update Pass By: Preston W, On: Aug 1, 2001
//:: Last Update: Georg Zoeller On: Oct 10, 2004
//:://////////////////////////////////////////////
//:: Update Pass By: Brock H. - OEI - 08/17/05
/*
	Caster Level(s): Cleric 6, Druid 7
	Innate Level: 6
	School: Necromancy
	Descriptor(s): Negative
	Component(s): Verbal, Somatic
	Range: Touch
	Area of Effect / Target: Single
	Duration: Instant
	Save: Will 1/2
	Spell Resistance: Yes

	Your touch inflicts 10 points of negative energy damage per caster level
	(maximum 150). If the target passes its Will save, it takes only half damage
	and cannot be reduced below 1 hp by this spell. This spell has a reverse
	effect on undead, healing the targeted undead to full health instead of
	harming it.
*/
// ChazM 5/15/07 - now calls HealHarmTarget()
// kevL 2023 oct 21 - change description at the top of this script to Dialog.Tlk #6174
//                  - ensure that 'oTarget' is valid and a creature
//                  - #include "n2f_curehurt_inc"

#include "x2_inc_spellhook"
#include "n2f_curehurt_inc"

//
void main()
{
	if (!X2PreSpellCastCode())
		return;


	_oTarget = GetSpellTargetObject();
	if (GetIsObjectValid(_oTarget) && GetObjectType(_oTarget) == OBJECT_TYPE_CREATURE // kL_safety
		&& !GetLocalInt(_oTarget, VAR_IMMUNE_TO_HEAL)) // abort for creatures immune to heal (yes the stock script does that)
	{
		_iSpellId = SPELL_UNDEFINED; // script-vars will be determined later

		_oCaster = OBJECT_SELF;

		n2f_HealHarmTarget(FALSE, FALSE);
	}
}
