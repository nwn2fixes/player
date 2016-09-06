// 2430_area_ce.nss
// 2430_temple OnClientEnter handler
// BMA-OEI 9/21/05
// kevL 160906 - changed the OnEnter script for the final statue-dialog.

#include "ginc_misc"

int StartingConditional()
{
	if(!FiredFromPartyTransition())
		return FALSE;
	// First time entering
	if (IsMarkedAsDone() == FALSE)
	{
		MarkAsDone();

		// kL: fix for non-controlled characters triggering the final dialog trigger
		object oTrigger = GetNearestObjectByTag("SpeakTrigger");
		SetEventHandler(oTrigger, SCRIPT_TRIGGER_ON_OBJECT_ENTER, "2430_fix_statue");

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