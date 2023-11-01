//::///////////////////////////////////////////////
//:: Heal
//:: 'nw_s0_heal'
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 12, 2001
//:://////////////////////////////////////////////
//:: Update Pass By: Preston W, On: Aug 1, 2001
//:: Update Pass By: Brock H. - OEI - 08/17/05
/*
	Caster Level(s): Cleric 6, Druid 7, Healing 5
	Innate Level: 6
	School: Conjuration
	Descriptor(s):
	Component(s): Verbal, Somatic
	Range: Touch
	Area of Effect / Target: Single
	Duration: Instant
	Save: Will 1/2
	Spell Resistance: Yes

	The target recovers 10 hit points per caster level (maximum 150) and is
	cured of the following status effects: blinded, confused, dazzled, deafened,
	diseased, feebleminded, insane, nauseated, poisoned, and stunned. Healing
	spells have a reverse effect when used on undead, harming instead of healing
	them. A successful touch attack must first be made when this spell is used
	against undead.
*/
// ChazM 5/15/07 - now calls HealHarmTarget()
// kevL 2023 oct 21 - change description at the top of this script to Dialog.Tlk #6176
//                  - remove bad effects per description
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
		&& !GetLocalInt(_oTarget, VAR_IMMUNE_TO_HEAL)) // abort for creatures immune to heal
	{
		_iSpellId = SPELL_UNDEFINED; // script-vars will be determined later

		_oCaster = OBJECT_SELF;

		n2f_HealHarmTarget(TRUE, TRUE);

		// kL_begin ->
		if (GetRacialType(_oTarget) != RACIAL_TYPE_UNDEAD)
			n2f_Restore();
		// kL_end
	}
}
