// '2017_cliententer'
/*
	OnClientEnter script for area: {1017}axle.
*/
// Created by: Brian Fox
// Created on: 9/24/05
// kevL 2023 aug 12 - destealth Moire [travus fix]

#include "20_inc"

//
int GetIsReadyForEdmundIntro(object oPc)
{
	if (!GetGlobalInt("gbWatch"))
	{
		int iQuestState = GetJournalQuestEntry("20_squiring", oPc);
		return iQuestState == 12 || iQuestState == 21;
	}
	return FALSE;
}


//
void main()
{
	object oLeader = GetFactionLeader(GetFirstEnteringPC());
	if (FiredFromPartyTransition())
	{
		if (GetIsReadyForEdmundIntro(oLeader))
		{
			ShowSponsor(oLeader); // Edmund cutscene (first entry into this area when gbWatch==FALSE)
		}
		else
			HideSponsor(oLeader); // just populate Axle as normal
	}

	object oMoire = GetNearestObjectByTag("10_moire", oLeader); // travus fix ->
	SetActionMode(oMoire, ACTION_MODE_STEALTH, FALSE);
}
