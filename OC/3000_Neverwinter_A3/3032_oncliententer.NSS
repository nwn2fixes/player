// Area OnClientEnter Bare Bones.nss

// Modified by Brendan Bellina, Dec 2009 for OC Makeover SoZ Edition
// - added Nasher's Cloak of Protection to Tholapsyx chest "traplock3"
/*
	Area OnClientEnter event handler template.
	Bare bones, useful to setup cutscene(s) to fire when the party enters via a party transition.
*/
// BMA-OEI 8/08/06

#include "ginc_cutscene"

int StartingConditional()
{
	// Event fired via non-party transition (Load Game, Client Join, etc.)
	if ( FiredFromPartyTransition() == FALSE )
	{
		return ( FALSE );
	}

	// add Nasher's Cloak of Protection to the chest one time only
	object oFEPC = GetFirstEnteringPC();
	object oContainer = GetNearestObjectByTag("traplock3", oFEPC);	
    if (GetLocalInt(oContainer,"BB_DO_ONCE") != 1)
    {
		CreateItemOnObject("x2_nash_cloak", oContainer);
		SetLocalInt(oContainer, "BB_DO_ONCE", 1);
	}
	
	object o3031 = GetObjectByTag("3031_mgalardrym");
	
	if (GetLocalInt(o3031, "fighting_tholapsyx") == 1)
	{	
		object oTholapsyx = GetObjectByTag("3031_tholapsyx");
		object oWP = GetObjectByTag("3032_wp_tholap_move1");
		
		AssignCommand(oTholapsyx, ClearAllActions(TRUE));
		AssignCommand(oTholapsyx, JumpToObject(oWP));
		ForceRest(oTholapsyx);
		SetLocalInt(oTholapsyx, "Spell_Queue_Complete", 0);
	}

	if (GetLocalInt(o3031, "Tholap_Has_Treasure") == 1)
	{	
		object oTholapsyx = GetObjectByTag("3031_tholapsyx");
		object oWP = GetObjectByTag("3032_wp_tholap_move1");
		
		AssignCommand(oTholapsyx, ClearAllActions(TRUE));
		AssignCommand(oTholapsyx, JumpToObject(oWP));
		ForceRest(oTholapsyx);
		SetLocalInt(oTholapsyx, "Spell_Queue_Complete", 0);
	}
	
	// Get party leader, force control of owned PC
	object oPC = GetFirstEnteringPC();
	object oLeader = GetFactionLeader( oPC );
	oPC = SetOwnersControlledCompanion( oLeader );
	
	object oSpeaker;
	string sDialog;
	
	// *** CUTSCENES START ***
	
	// Cutscene: TITLE_GOES_HERE
	// Uncomment and replace ( FALSE ) with condition to play cutscene
/*	
	if ( FALSE )
	{
		// Pre-cutscene setup
		// 
		oSpeaker = GetNearestObjectByTag( "TAG_OF_OWNER", oPC );	// Conversation owner
		sDialog = "DIALOG_GOES_HERE";								// Conversation file
		FireAndForgetConversation( oSpeaker, oPC, sDialog );
		return ( TRUE );
	}
*/
	
	//  *** CUTSCENES END ***
	
	// No cutscene pending, revert control to original character
	SetOwnersControlledCompanion( oPC, oLeader );
	return ( FALSE );
}