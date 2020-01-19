// 2330_cli_enter
/*
	on enter for basement
*/
// ChazM 9/15/05
// EPF 1/13/06 -- the three named MSC are preplaced now, so they're not all jumping in.
// EPF 1/16/06 -- adding the garius opening cutscene
// kevL 2020 jan 18 - flag Vale,Sevann,Nathe as immortal and Vale as plot

#include "ginc_misc"
#include "ginc_group"
#include "inc_ckadv"
#include "kinc_worldmap"


void InitiateBrotherhoodHeartbeats(object oNear, int bValid = TRUE)
{
	object oBrotherhood = GetNearestObjectByTag(TAG_ARCANE_LIEUTENANT,oNear,1);
	int i = 1;

	while(GetIsObjectValid(oBrotherhood))
	{
		AssignCommand(oBrotherhood, SetSpawnInCondition(NW_FLAG_HEARTBEAT_EVENT,bValid));
		i++;
		oBrotherhood = GetNearestObjectByTag(TAG_ARCANE_LIEUTENANT,oNear,i);
	}
}

// area enter cutscene
int StartingConditional()
{
	if(!FiredFromPartyTransition())
		return FALSE;

// when player first enters, get all the guys down there asap so they will be available for the blade golem
	if (IsMarkedAsDone())
		return FALSE;

	object oPC = GetFirstEnteringPC();
	object oModule = GetModule();

	//intro cutscene where garius starts the ritual
	if(!GetLocalInt(oModule,"bGariusSceneFired"))
	{
		AssignCommand(GetObjectByTag("23_bgarius"), ActionStartConversation(oPC, "23_cs_ritual_begin", FALSE,FALSE,TRUE,FALSE));
		SetLocalInt(oModule, "bGariusSceneFired",TRUE);
		SetDefaultDestination("2300CKAdventure","wp_2300_start");	//world map now redirects to 2300 farm.
		ShowCutsceneBrotherhood(TRUE);
		ShowNonCutsceneBrotherhood(FALSE);
		return TRUE;
	}
	else
	{

		ShowCutsceneBrotherhood(FALSE);
		ShowNonCutsceneBrotherhood(TRUE);

		CreateObject(OBJECT_TYPE_PLACED_EFFECT, "23_fx_garius_forcefield", GetLocation(GetNearestObjectByTag(TAG_BLACK_GARIUS,oPC)));
		object oVale = GetNearestObjectByTag(TAG_VALE,oPC);
		AssignCommand(oVale, SetIsDestroyable(FALSE,TRUE,TRUE));

		object oSevann = GetNearestObjectByTag(TAG_SEVANN,oPC);
		AssignCommand(oSevann, SetIsDestroyable(FALSE,TRUE,TRUE));

		object oNathe = GetNearestObjectByTag(TAG_NATHE,oPC);
		AssignCommand(oNathe, SetIsDestroyable(FALSE,TRUE,TRUE));

		// kL_fix -> These values mirror those of their blueprints (the group upstairs).
//		SetPlotFlag(oVale, TRUE); // that might not be a good idea
		SetImmortal(oVale, TRUE);
		SetImmortal(oSevann, TRUE);
		SetImmortal(oNathe, TRUE);
		// kL_end

		InitiateBrotherhoodHeartbeats(oPC);

		//upstairs msc -- to remove the force follow
		GroupStopFollowLeader(GROUP_MSC);

		//use downstairs msc instead
		ResetGroup(GROUP_MSC);
		GroupAddMSCs(GROUP_MSC, oPC);
		ShowNearestMSCs(oPC);

		GroupMoveToObject(GROUP_MSC, GetTarget("2330_wp_msc"), MOVE_JUMP_INSTANT);

		MarkAsDone();
	}
	return FALSE;
}
