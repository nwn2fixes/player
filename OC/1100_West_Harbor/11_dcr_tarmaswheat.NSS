// '11_dcr_tarmaswheat'
/*
	DetermineCombatRound() for Tarmas in the field.
*/
// kevL 2019 apr 15 - tidy
// kevL 2019 apr 15 - try to determine Tarmas' targets effectively; now that he
//					  has spells he has only so many of them

#include "nw_i0_generic"

object LastHostile();

//
void main()
{
	ClearCreatureOverrideAIScriptTarget();

	if (GetLocalInt(OBJECT_SELF, "X2_SPECIAL_COMBAT_AI_SCRIPT_OK"))
	{
		DeleteLocalInt(OBJECT_SELF, "X2_SPECIAL_COMBAT_AI_SCRIPT_OK");
	}
	else if (!__InCombatRound())
	{
		object oTarget = LastHostile();
		if (GetIsObjectValid(oTarget))
		{
			SetCreatureOverrideAIScriptFinished();
			DetermineCombatRound(oTarget);
			SetCreatureOverrideAIScriptFinished();
		}
	}
}


// Gets the nearest hostile creature to a friendly who is below half health.
object LastHostile()
{
	object oFirstPC = GetFirstPC();
	object oActor;

	int i = 1;
	object oFriend = GetNearestObject(OBJECT_TYPE_CREATURE, OBJECT_SELF, i);
	while (GetIsObjectValid(oFriend))
	{
		if (!GetIsDead(oFriend)
			&& !GetIsEnemy(oFriend, oFirstPC)
			&& GetCurrentHitPoints(oFriend) < GetMaxHitPoints(oFriend) / 2
			&& GetIsObjectValid(oActor = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY,
															oFriend, 1,
															CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN,
															CREATURE_TYPE_IS_ALIVE, CREATURE_ALIVE_TRUE))
			&& GetObjectSeen(oActor))
		{
			return oActor;
		}
		oFriend = GetNearestObject(OBJECT_TYPE_CREATURE, OBJECT_SELF, ++i);
	}
	return OBJECT_INVALID;
}
