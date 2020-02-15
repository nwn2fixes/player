//::///////////////////////////////////////////////
//:: SetListeningPatterns
//:: NW_C2_DEFAULT4
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Determines the course of action to be taken
    by the generic script after dialogue or a
    shout is initiated.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Oct 24, 2001
//:: Clangeddin 2020 - Code refactor and optimization
//:://////////////////////////////////////////////

#include "hench_i0_monsho"
#include "ginc_behavior"

void main()
{
	object oNPC = OBJECT_SELF;
	
    // * if petrified, jump out
    if (GetHasEffect(EFFECT_TYPE_PETRIFY, oNPC) == TRUE)
    {
        return;
    }

    // * If dead, exit directly.
    if (GetIsDead(oNPC))
    {
        return;
    }

    // notify walkwaypoints that we've been stopped and need to restart.
    SetLocalInt(oNPC, VAR_KICKSTART_REPEAT_COUNT, 100);

    int nMatch = GetListenPatternNumber();
    object oShouter = GetLastSpeaker();
    object oIntruder;
    int iFocused = GetIsFocused();

    if (nMatch == -1 && GetCommandable(oNPC))
    {
        if (GetCommandable(oNPC))
        {
            ClearAllActions();
            BeginConversation();
        }
        else
        // * July 31 2004
        // * If only charmed then allow conversation
        // * so you can have a better chance of convincing
        // * people of lowering prices
        if (GetHasEffect(EFFECT_TYPE_CHARMED) == TRUE)
        {
            ClearActions(CLEAR_NW_C2_DEFAULT4_29);
            BeginConversation();
        }

    }
    else if(nMatch != -1 && GetIsObjectValid(oShouter) && !GetIsPC(oShouter) &&
		GetIsFriend(oShouter) && (iFocused <= FOCUSED_STANDARD) &&
		GetIsValidRetaliationTarget(oIntruder))
    {
        if(nMatch == 4)
        {
            oIntruder = GetLocalObject(oShouter, "NW_BLOCKER_INTRUDER");
        }
        else if (nMatch == 5 || nMatch == 1)
        {
            oIntruder = GetLocalObject(oShouter, sHenchLastTarget);
            if(!GetIsObjectValid(oIntruder))
            {
                oIntruder = GetLastHostileActor(oShouter);
                if(!GetIsObjectValid(oIntruder))
                {
                    oIntruder = GetAttemptedAttackTarget();
                    if(!GetIsObjectValid(oIntruder))
                    {
                        oIntruder = GetAttemptedSpellTarget();
                        if(!GetIsObjectValid(oIntruder))
                        {
                            oIntruder = OBJECT_INVALID;
                        }
                    }
                }
            }
        }
//		Jug_Debug(GetName(OBJECT_SELF) + " respond to shout " + GetName(oShouter) + " match " + IntToString(nMatch) + " intruder " + GetName(oIntruder));
        HenchMonRespondToShout(oShouter, nMatch, oIntruder);
    }

    if(GetSpawnInCondition(NW_FLAG_ON_DIALOGUE_EVENT))
    {
        SignalEvent(oNPC, EventUserDefined(EVENT_DIALOGUE));
    }
}