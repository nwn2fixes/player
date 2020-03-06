// k_mod_player_rest
/*
    Module rest
*/
// ChazM 3/2/06
// ChazM 11/29/06
// ChazM 4/10/07 - added GUI functions (disabled for the time being until fully working)
// ChazM 4/11/07 - Finished and enabled Rest GUI changes. Moved parts to gui_rest
// ChazM 4/13/07 - Added support for rest strings output through script
// ChazM 7/18/07 - Added delay before popping up GUI to prevent multiple rest clicks while paused.
// TDE 6/20/08 - Adapted script for NX2
// NLC 10/10/08 - Finalized NX2 Rest System.
// kevL's 2019.02.14 - merge this with the MotB Campaign 'k_mod_player_rest' so it's suitable for /Override.

#include "ginc_overland" // kL, GetIsSoZ()
#include "ginc_restsys"
#include "x2_inc_switches"
#include "ginc_time"
#include "ginc_transition"

void DoSinglePartyRest(object oPC)
{
	//WMRestEncounterInit(oPC);
	PrettyDebug("Using Single Party Rest System (switch set)!");

	// if you press the rest button, an interface pops up alerting you to the danger level,
	// and asking how long you want to rest.
	if (!GetLocalInt(oPC, VAR_REST_NOW))
	{
		AssignCommand(oPC, ClearAllActions());

		if (!IsPartyGathered(oPC, 20.f))
		{
			//AssignCommand(oPC, ActionSpeakString("Hey, Let's all gather together so we can rest!"));
			FloatingTextStrRefOnCreature(STR_REF_MUST_GATHER_FOR_REST, oPC);
		}
		else
		{
			//AssignCommand(oPC, ActionStartConversation(oPC, "gr_rest_convo", TRUE, FALSE));
			// conversation must set DoRestingNow to TRUE and make player rest
			DelayCommand(0.01f, DisplayRestGUI(oPC));
		}
	}
}

//
void main()
{
	object oPC = GetLastPCRested();

	if (GetIsSoZ())
		AssignCommand(oPC, ClearAllActions());

	PrettyDebug(GetName(oPC) + " is Resting!");

	int bSinglePartyRestSystem = GetModuleSwitchValue(MODULE_SWITCH_USE_NX1_SINGLE_PARTY_RESTSYSTEM);

	switch (GetLastRestEventType())
	{
		case REST_EVENTTYPE_REST_STARTED:
		{
			//RestSendMessage(oPC, STR_REF_REST_STARTED);
			PrettyDebug("this is REST_EVENTTYPE_REST_STARTED - so checking for wandering monsters...");

		    if (bSinglePartyRestSystem)
			{
				DoSinglePartyRest(oPC);
			}
		    else if (GetModuleSwitchValue(MODULE_SWITCH_USE_XP2_RESTSYSTEM))
			{
				RestSendMessage(oPC, STR_REF_REST_STARTED);
				WMRestEncounterInit(oPC);
				WMRestEncounterCheck(oPC);
			}
			else
				RestSendMessage(oPC, STR_REF_REST_STARTED);

			break;
		}

		case REST_EVENTTYPE_REST_CANCELLED:
		{
			if (!bSinglePartyRestSystem || GetLocalInt(oPC, VAR_REST_REPORT_CANCEL))
				RestSendMessage(oPC, STR_REF_REST_CANCELLED);

			// No longer used but left in for the community
//			WMFinishPlayerRest(oPC,TRUE); // removes sleep effect, etc
			break;
		}

		case REST_EVENTTYPE_REST_FINISHED:
		{
			// always indicate rest finished
			RestSendMessage(oPC, STR_REF_REST_FINISHED);

			// No longer used but left in for the community
//			WMFinishPlayerRest(oPC); // removes sleep effect, etc
			break;
		}
	}
}
