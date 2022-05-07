// '3052_cliententer'
/*
	OnClientEnter script for 3052 West Harbor.
*/
// kL 2022 apr 1  - flag all camera-tracker creatures Scripthidden
//                - also grant them WeaponProficiency(simple) for compatibility
//                  with the kPrC Pack (and re-equip their invisible gloves)
// kL 2022 apr 17 - change values on the trigger that starts the dialog that
//                  reforges the Silver blade; make Zhjaeve the owner of the
//                  dialog and assign a better OnEnter handler
// kL 2022 apr 22 - set appropriate names ("Zhjaeve" "Shadow Reaver") to the
//                  camera-trackers since they speak dialog in the Scar cutscene

#include "ginc_cutscene"

void FixTrackers(); // kL
void FixSpeakTrigger(object oArea); // kL

//
void main()
{
	object oArea = OBJECT_SELF;

	// kL_fix - this should go inside FiredFromPartyTransition()
	// but keep it here so that it can fire even if player has already entered
	// the area (unless cutscene '3052_cut_scar' is done).
	if (!GetGlobalInt("30_bSword_Reformed") && !GetLocalInt(oArea, "kfix_done"))
	{
		SetLocalInt(oArea, "kfix_done", TRUE);

		DelayCommand(0.35f, FixTrackers());
		DelayCommand(0.50f, FixSpeakTrigger(oArea));
	}

	if (FiredFromPartyTransition())
	{
		object oPc = GetFirstEnteringPC();
		object oLeader = GetFactionLeader(oPc);
		oPc = SetOwnersControlledCompanion(oLeader);

		effect eDrain = EffectAbilityDecrease(ABILITY_CONSTITUTION, 6);
		effect eVis = EffectNWN2SpecialEffectFile("sp_poison");

		if (GetLocalInt(oArea, "PoisonUponEntry") == 1)
		{
			object oParty = GetFirstFactionMember(oLeader, FALSE);
			while (GetIsObjectValid(oParty))
			{
				DelayCommand(2.f, AssignCommand(oArea, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oParty)));
				DelayCommand(2.f, AssignCommand(oArea, ApplyEffectToObject(DURATION_TYPE_PERMANENT, eDrain, oParty)));

				oParty = GetNextFactionMember(oLeader, FALSE);
			}
		}


		struct CutsceneInfo stCI;
		stCI = ResetCutsceneInfo(stCI);

		// *** START CLIENT ENTER CUTSCENES ***

		if (!GetIsCutscenePending(stCI))
		{
			stCI = SetupCutsceneInfo(stCI,
									 "3052_ip_convo_bridge",
									 oPc,
									 "3052_cut_enter",
									 TRUE);

			if (GetIsCutscenePending(stCI))
			{}
		}

		// *** END CLIENT ENTER CUTSCENES ***

		if (GetIsCutscenePending(stCI))
		{
			FireAndForgetConversation(stCI.oSpeaker, oPc, stCI.sDialog);
		}
		else
			SetOwnersControlledCompanion(oPc, oLeader);

		GetIsCutscenePending(stCI);
	}
}


// kL_Fix: Fixes all camera-trackers (unable to equip Gauntlets) and hides em.
// They will be unhidden in cutscene '3052_cut_scar' script '3052a_cut_scar'
// (else the dialog's soundfiles don't play for nodes that use camera-tracking).
// Also assigns appropriate names for the Scar dialog.
void FixTrackers()
{
	object oTracker;

	int i = 0;
	while (++i <= 5)
	{
		oTracker = GetObjectByTag("3052_camera_tracker" + IntToString(i));

		object oIt = GetFirstItemInInventory(oTracker); // 'n2_invis_gloves'
		if (GetIsObjectValid(oIt))
		{
			FeatAdd(oTracker, FEAT_WEAPON_PROFICIENCY_SIMPLE, FALSE);
			AssignCommand(oTracker, ActionEquipItem(oIt, INVENTORY_SLOT_ARMS));
		}

		SetScriptHidden(oTracker, TRUE);

		switch (i) // trackers are assigned dialog nodes ->
		{
			case 2: case 3: case 5:
				SetFirstName(oTracker, "Zhjaeve");
				break;

			case 1: case 4:
				SetFirstName(oTracker, "Shadow Reaver");
				break;
		}
	}
}

// kL_Fix: Makes Zhjaeve the owner of the dialog '3052_cut_scar' in which the
// Silver blade is reforged. Also changes the dialog-trigger's OnEnter script
// from the default 'gtr_speak_node' to '3052_gtr_speak_node' that prepares the
// party-objects for the dialog.
void FixSpeakTrigger(object oArea)
{
	object o = GetFirstObjectInArea(oArea);
	while (GetIsObjectValid(o))
	{
		if (GetObjectType(o) == OBJECT_TYPE_TRIGGER
			&& GetTag(o) == "SpeakTrigger"
			&& GetLocalString(o, "NPC_Tag") == "")
		{
			SetLocalString(o, "NPC_Tag", "zhjaeve");
			SetEventHandler(o, SCRIPT_TRIGGER_ON_OBJECT_ENTER, "3052_gtr_speak_node");
			break;
		}
		o = GetNextObjectInArea(oArea);
	}
}
