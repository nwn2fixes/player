//::///////////////////////////////////////////////
//:: Jagged Tooth
//:: 'nw_s0_jagtooth'
//:: Copyright (c) 2006 Obsidian Entertainment
//:://////////////////////////////////////////////
/*
	This spell doubles the critical threat range of one natural weapon
	that deals either slashing or peircing damage. Multiple spell effects
	that increase a weapon's threat range don't stack. This spell is
	typically cast on animal companions.

	Changes 2020.02.23
	- target must be an Animal Companion. Other creatures could lose the
	  delayed-check for removal but keep the feat after a module transition;
	  since Animal Companions are automatically unsummoned before a module
	  transition that will never happen to them.
	- increased chance for a threat-roll affects all unarmed attacks incl/
	  bludgeoning (although the initial check must still find a non-bludgeoning
	  creature weapon)
*/
//:://////////////////////////////////////////////
//:: Created By: Patrick Mills
//:: Created On: Oct 19, 2006
//:://////////////////////////////////////////////
// kevL 2020.02.23 - rewrite. Apply Keen as a feat on a temporary item in
//                   target's inventory instead of as an itemproperty on one of
//                   its creature weapons (which doesn't appear to work for
//                   whatever reason).
// Clangeddin 2020.02.23 - rewrite. Grant Improved Crit feat directly.
// kevL 2020.02.23 - target must be an Animal Companion
//                 - allow refresh
//                 - run the recursive check on the target-object
//                 - safety check that target is a valid creature
//                 - signal the OnSpellCastAt event for target

#include "nw_i0_spells"
#include "x2_inc_spellhook"
#include "x2_inc_itemprop"
#include "nwn2_inc_metmag"

void CheckEffectValid(int iSpellId);


void main()
{
	if (!X2PreSpellCastCode())
		return;


	object oTarget = GetSpellTargetObject();
	if (GetIsObjectValid(oTarget) && GetObjectType(oTarget) == OBJECT_TYPE_CREATURE)
	{
		object oCaster = OBJECT_SELF;

		if (GetAssociateType(oTarget) != ASSOCIATE_TYPE_ANIMALCOMPANION)
		{
			SendMessageToPC(oCaster, "<c=red>Jagged Tooth failed - target must be an Animal Companion.</c>");
			return;
		}

		if (!spellsIsTarget(oTarget, SPELL_TARGET_ALLALLIES, oCaster))
		{
			SendMessageToPC(oCaster, "<c=red>Jagged Tooth failed - target must be an ally.</c>");
			return;
		}


		int bTooth = FALSE;

		object oWeapon;
		int iSlot = INVENTORY_SLOT_CWEAPON_L;
		while (iSlot <= INVENTORY_SLOT_CWEAPON_B)
		{
			oWeapon = GetItemInSlot(iSlot, oTarget);
			if (GetIsObjectValid(oWeapon) && !IPGetIsBludgeoningWeapon(oWeapon))
			{

				bTooth = TRUE;
				break;
			}
			++iSlot;
		}

		if (!bTooth)
		{
			SendMessageToPC(oCaster, "<c=red>Jagged Tooth failed - target does not have a non-bludgeoning creature weapon.</c>");
			return;
		}


		int iSpellId = GetSpellId();
		SignalEvent(oTarget, EventSpellCastAt(oCaster, iSpellId, FALSE));

		// allow refresh
		RemoveEffectsFromSpell(oTarget, iSpellId);

		float fDur = IntToFloat(GetCasterLevel(oCaster) * 600);
		fDur = ApplyMetamagicDurationMods(fDur);

		effect eDur = EffectVisualEffect(VFX_SPELL_DUR_JAGGED_TOOTH);
		ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDur, oTarget, fDur);

		// don't mess with the feat if target already has it
		if (!GetHasFeat(FEAT_IMPROVED_CRITICAL_UNARMED_STRIKE, oTarget, TRUE))
		{
			FeatAdd(oTarget, FEAT_IMPROVED_CRITICAL_UNARMED_STRIKE, FALSE);

			// delay +0.1 results in a more accurate total duration
			AssignCommand(oTarget, DelayCommand(6.1f, CheckEffectValid(iSpellId)));
		}
	}
}


// OBJECT_SELF is Target
// note: If an Animal Companions dies it gets destroyed and this pseudo-
// heartbeat stops automatically.
void CheckEffectValid(int iSpellId)
{
	if (!GetHasSpellEffect(iSpellId))
	{
		FeatRemove(OBJECT_SELF, FEAT_IMPROVED_CRITICAL_UNARMED_STRIKE);
	}
	else
	{
		if (!GetHasFeat(FEAT_IMPROVED_CRITICAL_UNARMED_STRIKE, OBJECT_SELF, TRUE))
			FeatAdd(OBJECT_SELF, FEAT_IMPROVED_CRITICAL_UNARMED_STRIKE, FALSE); // just in case keep it up.

		DelayCommand(6.f, CheckEffectValid(iSpellId));
	}
}
