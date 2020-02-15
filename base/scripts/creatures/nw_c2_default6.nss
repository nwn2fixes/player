//::///////////////////////////////////////////////
//:: Default On Damaged
//:: NW_C2_DEFAULT6
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    If already fighting then ignore, else determine
    combat round
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Oct 16, 2001
//:: Clangeddin 2020 - Code refactor and slightly improved performance.
//:://////////////////////////////////////////////

#include "hench_i0_ai"
#include "ginc_behavior"

void main()
{
	object oNPC = OBJECT_SELF;
    int iFocused = GetIsFocused(oNPC);
	
	// I've been damaged so no longer partially focused
	if (iFocused == FOCUSED_PARTIAL)
	{
		SetLocalInt(oNPC, VAR_FOCUSED, FOCUSED_STANDARD); // no longer focused
	}
	
    if (iFocused == FOCUSED_FULL)
	{
        // remain focused
    }
	else if(GetFleeToExit())
	{
        // We're supposed to run away, do nothing
    }
    else if (GetSpawnInCondition(NW_FLAG_SET_WARNINGS))
    {
        // don't do anything?
    }
    else
    {
        object oDamager = GetLastDamager(oNPC);
        if (!GetIsObjectValid(oDamager))
        {
        // don't do anything, we don't have a valid damager
        }
        else if (!GetIsFighting(oNPC))
        {
            if ((GetLocalInt(oNPC, HENCH_HEAL_SELF_STATE) == HENCH_HEAL_SELF_WAIT) &&
                (GetPercentageHPLoss(oNPC) < 30))
            {
                // force heal
                HenchDetermineCombatRound(OBJECT_INVALID, TRUE);
            }
            else if (!GetIsObjectValid(GetAttemptedAttackTarget()) && !GetIsObjectValid(GetAttemptedSpellTarget()))
            {
//    Jug_Debug(GetName(OBJECT_SELF) + " responding to damage");
                if (GetBehaviorState(NW_FLAG_BEHAVIOR_SPECIAL))
                {
                    HenchDetermineSpecialBehavior(oDamager);
                }
                else
                {
                    HenchDetermineCombatRound(oDamager);
                }
            }
        }
    }
	
    if(GetSpawnInCondition(NW_FLAG_DAMAGED_EVENT))
    {
        SignalEvent(oNPC, EventUserDefined(EVENT_DAMAGED));
    }
}