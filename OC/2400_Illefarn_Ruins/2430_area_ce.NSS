// 2430_area_ce.nss
// 2430_temple OnClientEnter handler
// BMA-OEI 9/21/05
// kevL 160907
// - changed the OnEnter script for the final statue-dialog.
// - raised the unlock DC for the return door from 18 to 99.

#include "ginc_misc"


// kL: Fix for non-controlled characters triggering the final dialog and
// raises the UnlockDC of the door to the final statue room from 18 to 99.
void TwoFixes()
{
	string sTag;

	object oArea = GetArea(GetFirstEnteringPC());
	object oObject = GetFirstObjectInArea(oArea);
	while (GetIsObjectValid(oObject))
	{
		sTag = GetTag(oObject);
		if (sTag == "SpeakTrigger") // fortunately only one of these in the Temple complex
		{
			SetEventHandler(oObject, SCRIPT_TRIGGER_ON_OBJECT_ENTER, "2430_fix_statue");
		}
		else if (sTag == "24_dr_temple_return")
		{
			SetLockUnlockDC(oObject, 99); // DC 18 in stock OC.
		}
		oObject = GetNextObjectInArea(oArea);
	}
}


int StartingConditional()
{
	if(!FiredFromPartyTransition())
		return FALSE;
	// First time entering
	if (IsMarkedAsDone() == FALSE)
	{
		MarkAsDone();

		TwoFixes(); // kL

		// Play Zhjaeve cutscene
		object oPC = GetFirstEnteringPC();
		object oZhjaeve = GetObjectByTag("zhjaeve");
		AssignCommand(oZhjaeve, JumpToObject(oPC));
		AssignCommand(oZhjaeve, ActionWait(0.5));
		AssignCommand(oZhjaeve, ActionStartConversation(oPC, "2430_cs_enter", FALSE, FALSE, TRUE, FALSE));

		// Fade out
		//return TRUE;
		return FALSE;
	}

	return FALSE;
}