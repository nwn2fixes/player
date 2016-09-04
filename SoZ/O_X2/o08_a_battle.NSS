//	o08_a_battle
/*
	Alarm is sounded, and the level goes hostile.
*/
//	JSH-OEI 7/21/08
// kevL 160904 - make sure the door shuts before locking it.

#include "ginc_group"

void main()
{
	object oPC		= GetFirstPC();
	object oDoor	= GetNearestObjectByTag("o08_door_lower", oPC);

	//ExecuteScript("o_activate_alarm", OBJECT_SELF);

//	SetLocked(oDoor, TRUE);
	if (GetIsOpen(oDoor)) AssignCommand(oDoor, ActionCloseDoor(oDoor));	// kL
	DelayCommand(0.1f, SetLocked(oDoor, TRUE));							// kL

	SetActionMode(oPC, ACTION_MODE_STEALTH, STEALTH_MODE_DISABLED);
	GroupGoHostile("O08 Enemies");
	GroupChangeToStandardFaction("O08 Zealots", STANDARD_FACTION_HOSTILE);
	SetLocalInt(GetModule(), "o_bFinalBattleBegun", TRUE);
}