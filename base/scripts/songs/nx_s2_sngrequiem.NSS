//:://////////////////////////////////////////////////////////////////////////
//:: Bard Song: Song/Hymn of Requiem
//:: 'nx_s2_sngrequiem'
//:: Created By: Andrew Woo (AFW-OEI)
//:: Created On: 02/23/2007
//:: Copyright (c) 2007 Obsidian Entertainment Inc.
//:://////////////////////////////////////////////////////////////////////////
/*
	Song of Requiem:
	This song damages all enemies within 20 feet for 5 rounds.
	The total sonic damage caused is equal to 2*Perform skill but is divided by
	the count of targets (up to a maximum of 6 although all targets in the AoE
	will still be affected). This ability has a cooldown of 20 rounds.

	Hymn of Requiem:
	The character's Song of Requiem now also heals all allied creatures within
	30 feet for 5 rounds. The amount healed is the same as the damage caused by
	the Song.
*/
// ChazM 5/31/07 renamed DoHealing() to DoPartyHealing() (DoHealing() is declared in nw_i0_spells)
// AFW-OEI 07/20/2007: NX1 VFX.
// RPGplayer1 11/16/2008: modified DoPartyHealing() to work with non-player faction
// RPGplayer1 12/29/2008: modified DoPartyHealing() to limit effects to single area
// kevL 2023 jan 24 - refactor
//                  - add back in GetCanBardSing()
//                  - remove RemoveBardSongSingingEffect() [this is not an Inspiration]
//                  - remove ExtraordinaryEffect() for VFX_DUR_BARD_SONG
//                  - add !GetIsDead() check to RunSongEffects()
//                  - renamed DoPartyHealing() to DoAllyHealing()
//                  - change recursive delay from 5.5 to 5.9
//                  - in DoAllyHealing() conform counted targets w/ affected targets -> canheal()
//                    [note: setting/deleting local flags could optimize counted/affected]
//                  - clear ACTION_MODE_STEALTH even if no targets are hit
//                  - use current Perform rank (not base) for the check in RunSongEffects()
//                  - add a check for Perform rank in main()
//                  - add an effecticon
//                  - check for and/or cancel RunSongEffects() when resting

#include "nwn2_inc_spells"

void RunSongEffects(int iDur, object oBard, int iSpellId);
void DoDamage(object oBard, int iSpellId, int iPerf);
void DoAllyHealing(object oBard, int iSpellId, int iPerf);
int  canheal(object oTarget, object oBard);

void applyicon(object oBard);
int  checkicon(object oBard, int iSpellId, int bClear = FALSE);

//
void main()
{
	object oBard = OBJECT_SELF;

	if (GetCanBardSing(oBard))
	{
		if (!GetHasFeat(FEAT_BARD_SONGS, oBard))
		{
			FloatingTextStrRefOnCreature(STR_REF_FEEDBACK_NO_MORE_BARDSONG_ATTEMPTS, oBard);
		}
		else if (GetSkillRank(SKILL_PERFORM, oBard) < 24)
		{
			FloatingTextStrRefOnCreature(182800, oBard); // nOOb
		}
		else
		{
			DecrementRemainingFeatUses(oBard, FEAT_BARD_SONGS);

			effect eFnf = EffectVisualEffect(VFX_DUR_BARD_SONG);
			ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eFnf, GetLocation(oBard));

			int iDur = ApplySongDurationFeatMods(5, oBard);
			DelayCommand(0.1f, RunSongEffects(iDur, oBard, GetSpellId()));

//			if (GetIsObjectValid(GetFactionLeader(oBard)))
			applyicon(oBard);
		}
	}
}

// recursive function
void RunSongEffects(int iDur, object oBard, int iSpellId)
{
	if (checkicon(oBard, iSpellId))
	{
		if (GetCanBardSing(oBard) && !GetIsDead(oBard)
			&& GetCurrentAction(oBard) != ACTION_REST)
		{
			int iPerf = GetSkillRank(SKILL_PERFORM, oBard);
			if (iPerf >= 24)
			{
				effect eHit = EffectVisualEffect(VFX_HIT_BARD_REQUIEM);
				ApplyEffectToObject(DURATION_TYPE_INSTANT, eHit, oBard);

				if (GetActionMode(oBard, ACTION_MODE_STEALTH))
					SetActionMode(oBard, ACTION_MODE_STEALTH, FALSE);

				// note: Invisibility and/or Sanctuary ought be removed by EventSpellCastAt (hostile)

				iPerf *= 2;
				DoDamage(oBard, iSpellId, iPerf);

				if (GetHasFeat(FEAT_EPIC_HYMN_OF_REQUIEM, oBard))
					DoAllyHealing(oBard, iSpellId, iPerf);

				if (--iDur != 0)
				{
					DelayCommand(5.9f, RunSongEffects(iDur, oBard, iSpellId));
					return;
				}
			}
		}
		checkicon(oBard, iSpellId, TRUE); // remove the effecticon if this Song fails to reschedule
	}
}

// Damages enemies per Song of Requiem.
void DoDamage(object oBard, int iSpellId, int iPerf)
{
	int iTargetCount = 0;

	location lBard = GetLocation(oBard);
	object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_HUGE, lBard); // 20'
	while (GetIsObjectValid(oTarget))
	{
		if (GetIsObjectValidSongTarget(oTarget) && GetIsEnemy(oTarget)
			&& ++iTargetCount == 6)
		{
			break; // limit damage divisor to 6 (or less)
		}
		oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_HUGE, lBard);
	}

	if (iTargetCount != 0)
	{
		effect eSonic = EffectDamage(iPerf / iTargetCount, DAMAGE_TYPE_SONIC);
		effect eHit = EffectVisualEffect(VFX_HIT_SPELL_SONIC);
		eHit = EffectLinkEffects(eHit, eSonic);

		float fDelay;

		oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_HUGE, lBard);
		while (GetIsObjectValid(oTarget))
		{
			if (GetIsObjectValidSongTarget(oTarget) && GetIsEnemy(oTarget, oBard))
			{
				SignalEvent(oTarget, EventSpellCastAt(oBard, iSpellId));

				fDelay = GetDistanceToObject(oTarget) * 0.15f;
				DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eHit, oTarget));
			}
			oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_HUGE, lBard);
		}
	}
}

// Heals allies per Hymn of Requiem.
void DoAllyHealing(object oBard, int iSpellId, int iPerf)
{
	int iTargetCount = 0;

	location lBard = GetLocation(oBard);
	object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, lBard); // 30'
	while (GetIsObjectValid(oTarget))
	{
		if (canheal(oTarget, oBard) && ++iTargetCount == 6)
			break; // limit healing divisor to 6 (or less)

		oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, lBard);
	}

	if (iTargetCount != 0)
	{
		effect eHeal = EffectHeal(iPerf / iTargetCount);
		effect eHit = EffectVisualEffect(VFX_IMP_HEALING_M);
		eHit = EffectLinkEffects(eHit, eHeal);

		float fDelay;

		oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, lBard);
		while (GetIsObjectValid(oTarget))
		{
			if (canheal(oTarget, oBard))
			{
				SignalEvent(oTarget, EventSpellCastAt(oBard, iSpellId, FALSE));

				fDelay = GetDistanceToObject(oTarget) * 0.15f;
				DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eHit, oTarget));
			}
			oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, lBard);
		}
	}
}

// - helper for DoAllyHealing()
int canheal(object oTarget, object oBard)
{
	return GetIsObjectValidSongTarget(oTarget)
		&& spellsIsTarget(oTarget, SPELL_TARGET_ALLALLIES, oBard)
		&& GetCurrentHitPoints(oTarget) < GetMaxHitPoints(oTarget);
}

// Applies an effecticon that lasts for the duration of this Song.
void applyicon(object oBard)
{
	int iIcon;
	if (GetHasFeat(FEAT_EPIC_HYMN_OF_REQUIEM, oBard)) iIcon = 137; // 137 HYMN_OF_REQUIEM ife_hymnofrequiem 185798
	else                                              iIcon = 136; // 136 SONG_OF_REQIUEM ife_songofrequiem 185796

	effect eIcon = EffectEffectIcon(iIcon);
	eIcon = ExtraordinaryEffect(eIcon);

	ApplyEffectToObject(DURATION_TYPE_PERMANENT, eIcon, oBard);
}

// Checks if the effecticon is valid.
// bClear - true to remove the effecticon (if this Song fails to recurse)
// - returns true if 'bClear' is false and the effecticon is found
// - note: Resting shall cancel this Song but Bard could do a rest between ticks
//   of RunSongEffects(). Since the (extraordinary)effecticon won't be removed
//   until a rest finishes check for ACTION_REST at the start of each tick also.
//   But don't use the effecticon as a duration-timer because the duration is
//   more accurately tracked by 'iDur' rounds than by the duration of an effect.
int checkicon(object oBard, int iSpellId, int bClear = FALSE)
{
	effect e = GetFirstEffect(oBard);
	while (GetIsEffectValid(e))
	{
		if (GetEffectType(e) == EFFECT_TYPE_EFFECT_ICON
			&& GetEffectSpellId(e) == iSpellId)
		{
			if (!bClear) return TRUE;

			RemoveEffect(oBard, e);
			e = GetFirstEffect(oBard);
		}
		else
			e = GetNextEffect(oBard);
	}
	return FALSE;
}
