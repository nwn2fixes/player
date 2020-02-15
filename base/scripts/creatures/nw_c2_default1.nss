//::///////////////////////////////////////////////
//:: Default On Heartbeat
//:: NW_C2_DEFAULT1
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    This script will have people perform default
    animations.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Nov 23, 2001
//:: Clangeddin 2020 - Code refactor and slightly improved performance.
//:://////////////////////////////////////////////
#include "hench_i0_ai"

void main()
{
	object oNPC = OBJECT_SELF;
	
	//  Jug_Debug(GetName(oNPC) + " faction leader " + GetName(GetFactionLeader(oNPC)));
    // * if not running normal or better AI then exit for performance reasons
    if (GetAILevel(oNPC) == AI_LEVEL_VERY_LOW) return;

//	if (GetIsObjectValid(GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR,PLAYER_CHAR_IS_PC, oNPC, 1, CREATURE_TYPE_PERCEPTION,  PERCEPTION_HEARD)))
//	{
//		Jug_Debug("*****" + GetName(oNPC) + " heartbeat action " + IntToString(GetCurrentAction(oNPC)));
//	}

    if(GetSpawnInCondition(NW_FLAG_FAST_BUFF_ENEMY))
    {
        if(HenchTalentAdvancedBuff(40.0))
        {
            SetSpawnInCondition(NW_FLAG_FAST_BUFF_ENEMY, FALSE);
            // TODO evaluate continue with combat
            return;
        }
    }

	if (HenchCheckHeartbeatCombat())
	{
	    HenchResetCombatRound();
	}
	
    if(GetHasEffect(EFFECT_TYPE_SLEEP))
    {
        if(GetSpawnInCondition(NW_FLAG_SLEEPING_AT_NIGHT))
        {
            effect eVis = EffectVisualEffect(VFX_IMP_SLEEP);
            if(d10() > 6)
            {
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oNPC);
            }
        }
    }

    // If we have the 'constant' waypoints flag set, walk to the next
    // waypoint.
    else if (!GetIsObjectValid(GetNearestSeenOrHeardEnemyNotDead(HENCH_MONSTER_DONT_CHECK_HEARD_MONSTER)))
    {
        CleanCombatVars();
        if (GetBehaviorState(NW_FLAG_BEHAVIOR_SPECIAL))
        {
            HenchDetermineSpecialBehavior();
        }
        else if (GetLocalInt(oNPC, sHenchLastHeardOrSeen))
        {
            // continue to move to target
            MoveToLastSeenOrHeard();
        }
        else
        {
            SetLocalInt(oNPC, HENCH_AI_SCRIPT_POLL, FALSE);
            if (DoStealthAndWander())
            {
                // nothing to do here
            }
            // sometimes waypoints are not initialized
            else if (GetWalkCondition(NW_WALK_FLAG_CONSTANT))
            {
                WalkWayPoints();
            }
            else
            {
                if(!IsInConversation(oNPC))
                {
                    if(GetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS) ||
                        GetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS_AVIAN))
                    {
                        PlayMobileAmbientAnimations();
                    }
                    else if(GetSpawnInCondition(NW_FLAG_IMMOBILE_AMBIENT_ANIMATIONS))
                    {
                        PlayImmobileAmbientAnimations();
                    }
                }
            }
        }
    }
    else if (GetUseHeartbeatDetect())
    {
//      Jug_Debug(GetName(oNPC) + " starting combat round in heartbeat");
//      Jug_Debug("*****" + GetName(oNPC) + " heartbeat action " + IntToString(GetCurrentAction(oNPC)));
        HenchDetermineCombatRound();
    }
    if(GetSpawnInCondition(NW_FLAG_HEARTBEAT_EVENT))
    {
        SignalEvent(oNPC, EventUserDefined(EVENT_HEARTBEAT));
    }
}