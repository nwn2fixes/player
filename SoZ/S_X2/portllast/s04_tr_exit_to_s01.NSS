//	s04_tr_exit_to_s01  
/*	Jumps the party to the waypoint whose tag is the same as the
	placeable's sTravelDest variable.
*/
//	Nchap
//	JSH-OEI 5/29/08 - Added autosave.

#include "ginc_debug"
#include "ginc_overland"
#include "ginc_companion"

void main()
{
	object oWP = GetWaypointByTag("s01_wp_from_s04");
	object oPC = GetClickingObject();
		
	if	(!GetIsPC(oPC) && !GetIsOwnedByPlayer(oPC)) 
		return;
		
	if ( GetGlobalInt("S_bGothaladreumDone") && IsInParty("co_septimund") && GetJournalEntry("s_q04_septimund", oPC) < 900 )
	{
		PrettyDebug("s04_tr_exit_to_s01: Starting convo with Septimund");

		object oSeptimund = GetObjectByTag("co_septimund");
		object oPlayer = GetFirstPC();

		if ( GetIsDead(oPlayer) )
			ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectResurrection(), oPlayer);		

		if ( GetIsDead(oSeptimund) )
			ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectResurrection(), oSeptimund);
	
		if ( GetDistanceBetween(oSeptimund, oPC) > 6.0)
			AssignCommand(oSeptimund, JumpToObject(oPC));
			
		if ( GetDistanceBetween(oPlayer, oPC) > 6.0)
			AssignCommand(oPlayer, JumpToObject(oPC));
		
		RemoveRosterMemberFromParty("co_septimund", oPC, FALSE);
		AssignCommand(oPC, ClearAllActions(TRUE));
		AssignCommand(oPlayer, ClearAllActions(TRUE));
		AssignCommand(oSeptimund, ClearAllActions(TRUE));
		AssignCommand(oSeptimund, ActionStartConversation(oPlayer, "co_septimund", FALSE, FALSE, TRUE, TRUE));
	}
		
	else if  ( (GetGlobalInt("S_bArmyofDeadRaised") == 1) && ( !IsMarkedAsDone() ) )
		
	{	
		PrettyDebug("s04_tr_exit_to_s01: The Army of the dead is RAISED");
		DoSinglePlayerAutoSave(); // Autosave
		JumpPartyToArea( oPC, oWP ); //Jumps party to 
		MarkAsDone();
	}
	
	else 
	{
		PrettyDebug("s04_tr_exit_to_s01: The Army of the Dead is NOT raised. Returning to overland map."); 
		ExecuteScript("ka_olmap_visit",OBJECT_SELF);
	}	
}