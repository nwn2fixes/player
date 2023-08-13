//::///////////////////////////////////////////////////////////////////////////
//::
//::	2017_cliententer.nss
//::
//::	Insert comment about this file here.
//::
//::///////////////////////////////////////////////////////////////////////////
//::
//::	Created by: Brian Fox
//::	Created on: 9/24/05
//::
//::///////////////////////////////////////////////////////////////////////////
#include "ginc_var_ops"
#include "20_inc"
#include "ginc_journal"
//::///////////////////////////////////////////////////////////////////////////
/* CONSTANT VALUES MAY BE SHARED WITH 2017_onenter!  MAKE SURE THAT CHANGES HERE ARE UPDATED THERE AS WELL! */
const string EDMUND_INTRO_ID_TAG = "12";

const string AXLE_TAG = "20_axle";
const string AXLE_SP_TAG = "sp_2017_axle";
const string AXLE_RESREF = "10axle";

const string EDMUND_SP_TAG = "sp_2017_edmund";
const string EDMUND_RESREF = "20_edmund";

//::///////////////////////////////////////////////////////////////////////////

int GetIsReadyForEdmundIntro(object oPC)
{
	object oEnteringObject = GetFirstEnteringPC();
	int nQuestEntry = GetJournalQuestEntry("20_squiring", oPC);

	return ( (nQuestEntry == 12 || nQuestEntry == 21) && (GetGlobalInt("gbWatch") == 0));
}	
	

//::///////////////////////////////////////////////////////////////////////////

int StartingConditional()
{
	if(!FiredFromPartyTransition())
		return FALSE;
	object oEnteringObject = GetFactionLeader(GetFirstEnteringPC());


	if ( GetIsReadyForEdmundIntro(oEnteringObject) )	// Edmund cutscene (first entry into this area when gbWatch == FALSE)
	{
		ShowSponsor(oEnteringObject);
	}
	else // just populate Axle as normal
	{
		HideSponsor(oEnteringObject);
	}

	return FALSE;
}