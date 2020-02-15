//::///////////////////////////////////////////////
//:: Default On Perceive
//:: NW_C2_DEFAULT2
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Checks to see if the perceived target is an
    enemy and if so fires the Determine Combat
    Round function
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Oct 16, 2001
//:: Clangeddin 2020 - Code refactor and slight performance increase
//:://////////////////////////////////////////////

#include "hench_i0_ai"
#include "ginc_behavior"

void main()
{
	object oNPC = OBJECT_SELF;
// * if not running normal or better Ai then exit for performance reasons
    // * if not running normal or better Ai then exit for performance reasons
    if (GetAILevel(oNPC) == AI_LEVEL_VERY_LOW) return;

        // script hidden object shouldn't react (for cases where AI not turned off)
    if (GetScriptHidden(oNPC)) return;

    int iFocused = GetIsFocused(oNPC);

    object oLastPerceived = GetLastPerceived();
    int bSeen = GetLastPerceptionSeen();
    if (iFocused <= FOCUSED_STANDARD)
    {
        //This is the equivalent of a force conversation bubble, should only be used if you want an NPC
        //to say something while he is already engaged in combat.
        if(GetSpawnInCondition(NW_FLAG_SPECIAL_COMBAT_CONVERSATION) && GetIsPC(oLastPerceived) &&
            bSeen)
        {
            SpeakOneLinerConversation();
        }

        //If the last perception event was hearing based or if someone vanished then go to search mode
        if (GetLastPerceptionVanished() || GetLastPerceptionInaudible())
        {
//          Jug_Debug(GetName(OBJECT_SELF) + " lost perceived " + GetName(oLastPerceived) + " seen " + IntToString(GetObjectSeen(oLastPerceived)) + " heard " + IntToString(GetObjectHeard(oLastPerceived)));
            if (!GetObjectSeen(oLastPerceived) && !GetObjectHeard(oLastPerceived) &&
                !GetIsDead(oLastPerceived, TRUE) && GetArea(oLastPerceived) == GetArea(oNPC) &&
                GetIsEnemy(oLastPerceived) && (!HENCH_MONSTER_DONT_CHECK_HEARD_MONSTER || GetIsPCGroup(oLastPerceived)))
            {
//              Jug_Debug(GetName(OBJECT_SELF) + " move to last heard or seen");
                if (GetLastPerceptionVanished() || !GetLocalInt(oNPC, sHenchScoutMode))
                {
//                  Jug_Debug(GetName(OBJECT_SELF) + " setting enemy location");
                    SetEnemyLocation(oLastPerceived);
                }
                // add check if target - prevents creature from following the target
                // due to ActionAttack without actually perceiving them
                if (GetLocalObject(oNPC, sHenchLastTarget) == oLastPerceived)
                {
//                  Jug_Debug(GetName(OBJECT_SELF) + " calling det combat round, doing clearallactions");
                    ClearAllActions();
                    DeleteLocalObject(oNPC, sHenchLastTarget);
                    HenchDetermineCombatRound(oLastPerceived, TRUE);
                }
            }
        }
        //Do not bother checking the last target seen if already fighting
        else if (bSeen && !GetIsObjectValid(GetAttemptedAttackTarget()) && !GetIsObjectValid(GetAttemptedSpellTarget()))
        {
//          Jug_Debug(GetName(OBJECT_SELF) + " checking perceived " + GetName(oLastPerceived) + " " + IntToString(GetObjectSeen(oLastPerceived)));
            // note : hearing is disabled and is only done in heartbeat. Calling GetIsEnemy with hearing causes
            // a noticeable lag to machine
            if (GetBehaviorState(NW_FLAG_BEHAVIOR_SPECIAL))
            {
                HenchDetermineSpecialBehavior();
            }
            else if (GetIsEnemy(oLastPerceived) && !GetIsDead(oLastPerceived, TRUE))
            {
                if(!GetHasEffect(EFFECT_TYPE_SLEEP))
                {
//                  Jug_Debug(GetName(OBJECT_SELF) + " starting combat round in percep");
                    SetFacingPoint(GetPosition(oLastPerceived));
                    HenchDetermineCombatRound(oLastPerceived);
                }
            }
            //Linked up to the special conversation check to initiate a special one-off conversation
            //to get the PCs attention
            else if (bSeen && GetSpawnInCondition(NW_FLAG_SPECIAL_CONVERSATION) && GetIsPC(oLastPerceived))
            {
                ActionStartConversation(oNPC);
            }
            // activate ambient animations or walk waypoints if appropriate
            if (!IsInConversation(oNPC))
            {
                if (GetIsPC(oLastPerceived) &&
                   (GetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS)
                    || GetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS_AVIAN)
                    || GetSpawnInCondition(NW_FLAG_IMMOBILE_AMBIENT_ANIMATIONS)
                    || GetIsEncounterCreature()))
                {
                    SetAnimationCondition(NW_ANIM_FLAG_IS_ACTIVE);
                }
            }
        }
        else if(GetBehaviorState(NW_FLAG_BEHAVIOR_SPECIAL) && bSeen)
        {
            HenchDetermineSpecialBehavior();
        }
    }
    if(GetSpawnInCondition(NW_FLAG_PERCIEVE_EVENT) && bSeen)
    {
        SignalEvent(oNPC, EventUserDefined(EVENT_PERCEIVE));
    }
}