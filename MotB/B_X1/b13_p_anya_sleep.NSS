// 'b13_p_anya_sleep'
/*
	Make Anya sleep and wake up at certain times.
*/
// TDE 5/3/07
// kL 2017 oct 18 - refactor. +face hearth.
//				  - replace GetObjectByTag() w/ GetNearestObjectByTag() to get
//					Anya, since the first is failing.

#include "ginc_wp"


//
void AnyaSleep(object oAnya)
{
	SetLocalInt(oAnya, "Asleep", TRUE);
	SetWalkCondition(NW_WALK_FLAG_PAUSED, TRUE, oAnya);
	SetOrientOnDialog(oAnya, FALSE);

	// waypoint for Anya to walk to when she goes to sleep
	object oWP = GetObjectByTag("b13_wp_anya_sleep");
	AssignCommand(oAnya, ActionForceMoveToObject(oWP));

	// face the hearth
	vector vHearth = GetPosition(GetNearestObjectByTag("PLC_MC_FIREPL01"));	// kL
	AssignCommand(oAnya, ActionDoCommand(SetFacingPoint(vHearth)));			// kL


	// play a barkstring when she goes to sleep
	AssignCommand(oAnya, SpeakOneLinerConversation("b10_bk_anya"));
}

//
void AnyaAwake(object oAnya)
{
 	SetLocalInt(oAnya, "Asleep", FALSE);
	SetWalkCondition(NW_WALK_FLAG_PAUSED, FALSE, oAnya);
	SetOrientOnDialog(oAnya, TRUE);

	// play a barkstring when she wakes up
	AssignCommand(oAnya, SpeakOneLinerConversation("b10_bk_anya"));
}

//
int CheckSleepHours()
{
	int iHour = GetTimeHour();
	if (iHour != 6 && iHour != 18)
	{
		return TRUE;
	}
	return FALSE;
}


// ___________
// ** MAIN ***
// -----------
void main()
{
	if (GetGlobalInt("B_nAnya_State") < 3)
	{
		object oAnya = GetNearestObjectByTag("b10_anya");	// kL
		if (GetIsObjectValid(oAnya))						// kL
		{
			int bSleepyTime = CheckSleepHours();

			if (!GetLocalInt(oAnya, "Asleep"))
			{
				if (bSleepyTime)
					AnyaSleep(oAnya);
			}
			else if (!bSleepyTime)
				AnyaAwake(oAnya);
		}
	}
}
