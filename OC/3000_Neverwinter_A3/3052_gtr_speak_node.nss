// '3052_gtr_speak_node'
/*
	OnEnter script for triggertag 'SpeakTrigger' - the one that has no 'NPC_Tag'
	set.

	Note that 'NPC_Tag' shall be set to "zhjaeve" in the OnClientEnter script
	'3052_cliententer' of areatag '3052_wharbor'.

	OC Act III
	3000_Neverwinter_A3.mod
	areatag '3052_wharbor'

	See script 'gtr_speak_node' for details re trigger-variables.

	- sets party's OrientOnDialog flags FALSE
*/
// kL 2022 apr 17

#include "ginc_trigger"

void party_stop_orient();

//
void main()
{
	if (!GetGlobalInt("30_bSword_Reformed"))
	{
		object oEnter = GetEnteringObject();
		if (StandardSpeakTriggerConditions(oEnter))
		{
			party_stop_orient();
			DoSpeakTrigger(GetFactionLeader(oEnter));
		}
	}
}

// Sets OrientOnDialog FALSE for all pc-faction.
// - are reset TRUE at the end of '3052_cut_scar' dialog in script
// '3052_cut_scar_end'
void party_stop_orient()
{
	object oPc = GetFirstPC();
	object oParty = GetFirstFactionMember(oPc, FALSE);
	while (GetIsObjectValid(oParty))
	{
		SetOrientOnDialog(oParty, FALSE);
		oParty = GetNextFactionMember(oPc, FALSE);
	}
}
