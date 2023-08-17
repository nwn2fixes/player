// 1616_center
/*
	OnClientEnter for 1616
*/
// JYL 11/11/05
// DBR 5/21/6 - Standardized onClientEnter start cutscene.
// kevL 2023.08.17 - destroy rogue candle flame placed effects (there are no
//                   candles and it looks wonky). by travus

#include "ginc_cutscene"


int StartingConditional()
{
	if (!GetLocalInt(OBJECT_SELF, "CandleFlamesDestroyed")) // travus_fix ->
	{
		SetLocalInt(OBJECT_SELF, "CandleFlamesDestroyed", TRUE);

		object o = GetFirstObjectInArea();
		while (GetIsObjectValid(o))
		{
			if (GetObjectType(o) == OBJECT_TYPE_PLACED_EFFECT)
			{
				// Don't destroy chimney smoke placed effects.
				// They are above position.z 3.0 - candles are below 3.0.
				if (GetPosition(o).z < 3.f)
					DestroyObject(o);
			}
			o = GetNextObjectInArea();
		}
	}
	// travus_fix.end


	// Do not execute if OnClientEnter was not fired from a group area transition
	if (!FiredFromPartyTransition())
		return FALSE;

	// Get party leader, force control of owned PC
	object oPC = GetFirstEnteringPC();
	object oLeader = GetFactionLeader(oPC);
	object oMember = GetFirstFactionMember(oPC, FALSE);
	oPC = SetOwnersControlledCompanion(oLeader);

	// Initialize temp CutsceneInfo
	struct CutsceneInfo stCI;
	stCI = ResetCutsceneInfo(stCI);
	int bCutsceneCondition;
	string sSpeakerTag;
	string sDialogName;

	// *** START CLIENT ENTER CUTSCENES ***

	// Cutscene: 1. Bishop thinks it's an ambush
	if (GetIsCutscenePending(stCI) == FALSE)
	{
		while (GetIsObjectValid(oMember))
		{
			ForceRest(oMember);
			oMember = GetNextFactionMember(oPC, FALSE);
		}
		bCutsceneCondition = (GetLocalInt(GetModule(),"1616_entered")==0); // 2. Replace (FALSE) with condition to play
		sSpeakerTag = "bishop"; // 3. Specify Speaker and Dialog
		sDialogName = "16_bishop_emb";

		stCI = SetupCutsceneInfo(stCI, sSpeakerTag, oPC, sDialogName, bCutsceneCondition);

		if (GetIsCutscenePending(stCI) == TRUE)
		{
			// 4. Additional cutscene setup
		}
	}

	// *** END CLIENT ENTER CUTSCENES ***

	// Cue cutscene or revert control to original character
	if (GetIsCutscenePending(stCI) == TRUE)
	{
		FireAndForgetConversation(stCI.oSpeaker, oPC, stCI.sDialog);
	}
	else
	{
		SetOwnersControlledCompanion(oPC, oLeader);
	}

	// If cutscene is pending, fade to black
	return GetIsCutscenePending(stCI);
}
