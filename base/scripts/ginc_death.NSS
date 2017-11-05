// ginc_death.nss
/*
	NWN2 Knock Out/Wake Up death system functions
*/
// BMA-OEI 12/19/05
// BMA-OEI 12/22/05 added ResurrectParty(), ShowPartyDefeatedGUI()
// BMA-OEI 1/16/06 removed comments, ForceRest() on respawn
// BMA-OEI 2/28/06 modified KnockSelfOut(), ShowPartyDefeatedGUI() for death GUI
// BMA-OEI 3/15/06 reduced wake up retry delay, added getisdead check to ShowPartyDefeatedGUI
// BMA-OEI 4/17/06 cleaned up various functions, add support for GetIsCompanionPossessionBlocked()
// BMA-OEI 8/22/06 -- Merged with kinc_death
// JWR-OEI 10/07/08 -- removed respawn button from multiplayer.
// kevL's 2016.09.09 fix mismatch prototype/definition for ShowProperDeathScreen().
// kevL's 2017.11.04 merge this with the SoZ Campaign 'ginc_death' so it's suitable for /Override.


#include "ginc_debug"	
#include "x0_i0_henchman"


const string GUI_DEATH 						= "SCREEN_PARTY_DEATH";
const string GUI_DEATH_WAIT_FOR_HELP 		= "BUTTON_WAIT_FOR_HELP";
const string GUI_DEATH_RESPAWN 				= "BUTTON_RESPAWN";
const string GUI_DEATH_LOAD_GAME			= "BUTTON_LOAD_GAME";
const string GUI_DEATH_HIDDEN				= "SCREEN_HIDDEN_DEATH";
const float KNOCKOUT_WAKE_UP_DELAY 			= 3.0f; 						// Delay between AttemptToWakeUpCreature()
const float KNOCKOUT_WAKE_UP_SAFE_DISTANCE 	= 15.0f;						// Hostiles within distance prevent WakeUp()
const string KNOCKOUT_POPUP_DISPLAYED 		= "__bKnockOutPopUpDisplayed"; 	// Set if Death Screen is visible
const int KNOCKOUT_CRYFORHELP 				= 183382; 						// StringRef for "... groan ..."


//*********************************************************
// FUNCTION PROTOTYPES
//*********************************************************

// kL_funct. Gets if this is SoZ.
int GetIsSoZ();

// Determine if oMember is a party member (either a PC, owned by a PC, or a roster member)
int GetIsPartyMember( object oMember=OBJECT_SELF );

// Determine if oMember's faction has at least one member that is in combat
// - bPartyOnly: If TRUE, only check members that are PC, owned by a PC, or a roster member
int GetIsFactionInCombat( object oMember=OBJECT_SELF, int bPartyOnly=TRUE );

// Determine if oMember's faction has at least one member that is valid
// - bPartyOnly: If TRUE, only check members that are PC, owned by a PC, or a roster member
// - bNotDying: If TRUE, member must additionally be not dying ( HP>0 )
int GetIsFactionValid( object oMember=OBJECT_SELF, int bPartyOnly=TRUE, int bNotDying=TRUE );

// Determine if oObject can be possessed by oPossessor (owned char or an unblocked companion)
int GetIsObjectPossessible( object oPossessor, object oObject );

// Determine if there is at least one object that can be validly possessed by oPartyMember
int GetIsPartyPossessible( object oPartyMember=OBJECT_SELF );

// Determine if oPC is the host of the game
int GetIsPCHost( object oPC );

// Determine if it is safe for oCreature to wake up
// ( faction not in combat, no hostile creatures nearby, at least one member alive )
int GetIsSafeToWakeUp( object oCreature=OBJECT_SELF );

// Full resurrection, no penalty
void ResurrectCreature( object oCreature );

// Resurrect entire faction ( PC party )
void ResurrectFaction( object oFactionMember );

// Go unconscious, queue AttemptToWakeUpCreature()
void KnockOutCreature( object oCreature );

// Random audio/visual feedback for knock out
void VoiceCryForHelp( object oCreature );

// Recursive function to Wake Up, Show and Hide Death Pop-up
void AttemptToWakeUpCreature( object oCreature );

// Get Up after KnockOut
void WakeUpCreature( object oCreature );

// Determine if Death screen is visible
int GetIsDeathPopUpDisplayed( object oPC=OBJECT_SELF );

// Set var to identify Death screen as visible
void SetIsDeathPopUpDisplayed( object oPC, int bDisplayed );

// Show appropriate Death screen for Single & Multiplayer
void ShowProperDeathScreen( object oPC=OBJECT_SELF ); // kL

// Hide & Reset Death-related GUI screens
void RemoveDeathScreens( object oPC=OBJECT_SELF );

// Displays Death Screen to oPC
// - bModal: T/F, Display window modally
// - bRespawn: T/F, Enables Respawn button
// - bLoadGame: T/F, Enables Load Game button
// - bWaitForHelp: T/F, Enables Wait For Help button
void ShowDeathScreen( object oPC, int bModal=TRUE, int bRespawn=FALSE, int bLoadGame=FALSE, int bWaitForHelp=FALSE );

// Hides Death Screen for oPC
void HideDeathScreen( object oPC );

// Displays Hidden Death Screen ( full screen button ) to oPC
void ShowHiddenDeathScreen( object oPC );

// Hides Hidden Death Screen for oPC
void HideHiddenDeathScreen( object oPC );


//*********************************************************
// FUNCTION DEFINITIONS
//*********************************************************

// kL_funct. Gets if this is SoZ.
int GetIsSoZ()
{
	string sModuleTag = GetTag(GetModule());
	return sModuleTag == "F_X2"
		|| sModuleTag == "G_X2"
		|| sModuleTag == "M_X2"
		|| sModuleTag == "N_X2"
		|| sModuleTag == "O_X2"
		|| sModuleTag == "S_X2"
		|| sModuleTag == "T_X2"
		|| sModuleTag == "X_X2";
}


// Determine if oMember is a party member (either a PC, owned by a PC, or a roster member)
int GetIsPartyMember( object oMember=OBJECT_SELF )
{
	return ( GetIsPC( oMember ) || GetIsOwnedByPlayer( oMember ) || GetIsRosterMember( oMember ) );
}

// Determine if oMember's faction has at least one member that is in combat
// - bPartyOnly: If TRUE, only check members that are PC, owned by a PC, or a roster member
int GetIsFactionInCombat( object oMember=OBJECT_SELF, int bPartyOnly=TRUE )
{
	object oTemp = GetFirstFactionMember( oMember, FALSE );

	// For each faction member
	while ( GetIsObjectValid( oTemp ) == TRUE )
	{
 		// Check if they are in combat 
		if ( GetIsInCombat( oTemp ) == TRUE )
		{
			// They are, but do we care? 
			if ( ( bPartyOnly == FALSE ) || ( GetIsPartyMember(oTemp) == TRUE ) )
			{
				return ( TRUE );
			}
		}
	
		// Check next faction member
		oTemp = GetNextFactionMember( oMember, FALSE );
	}

	return ( FALSE );
}

// Determine if oMember's faction has at least one member that is valid
// - bPartyOnly: If TRUE, only check members that are PC, owned by a PC, or a roster member
// - bNotDying: If TRUE, member must additionally be not dying ( HP>0 )
int GetIsFactionValid( object oMember=OBJECT_SELF, int bPartyOnly=TRUE, int bNotDying=TRUE )
{
	object oTemp = GetFirstFactionMember( oMember, FALSE );
	
	// For each faction member
	while ( GetIsObjectValid( oTemp ) == TRUE )
	{
		// Check if we only want party members
		if ( bPartyOnly == TRUE )
		{
			// Are they in the party?
			if ( GetIsPartyMember( oTemp ) == TRUE )
			{
				// Check if they must be alive
				if ( ( bNotDying == FALSE ) || ( GetIsDead(oTemp) == FALSE ) )
				{
					return ( TRUE );
				}
			}
		}
		else
		{
			// Check if they must be alive
			if ( ( bNotDying == FALSE ) || ( GetIsDead(oTemp) == FALSE ) )
			{
				return ( TRUE );
			}
		}

		// Check next faction member
		oTemp = GetNextFactionMember( oMember, FALSE );
	}

	return ( FALSE );
}

// Determine if oObject can be possessed by oPossessor (owned char or an unblocked companion)
// Assumes PC faction
int GetIsObjectPossessible( object oPossessor, object oObject )
{
	if ( ( GetOwnedCharacter( oPossessor) == oObject ) || ( ( GetIsRosterMember( oObject ) == TRUE ) && ( GetIsCompanionPossessionBlocked( oObject ) == FALSE ) ) )
	{
		return ( TRUE );
	}
	
	return ( FALSE );
}

// Determine if there is at least one object that can be validly possessed by oPartyMember
int GetIsPartyPossessible( object oPartyMember=OBJECT_SELF )
{
	int bIsSoZ = GetIsSoZ(); // kL_add.

	object oMember = GetFirstFactionMember( oPartyMember, FALSE );

	while ( GetIsObjectValid( oMember ) == TRUE )
	{
		// If oMember is not dead, not possessed, and possessible by oPartyMember
		if ( GetIsDead( oMember ) == FALSE )
			if ( GetIsPC( oMember ) == FALSE || (bIsSoZ && GetPartyMembersDyingFlag()) ) // kL_add.
				if ( GetIsObjectPossessible( oPartyMember, oMember ) == TRUE  || (bIsSoZ && GetIsOwnedByPlayer(oMember)) ) // kL_add.
					return ( TRUE );

		oMember = GetNextFactionMember( oPartyMember, FALSE );
	}

	return ( FALSE );
}

int GetIsPCHost( object oPC )
{
	string sIP = GetPCIPAddress( oPC );
	return ( sIP == "127.0.0.1" );
}

// Determine if it is "safe" for oCreature to wake up
// ( at least one PC or possessible companion alive, party not in combat, and no hostiles nearby )
int GetIsSafeToWakeUp( object oCreature=OBJECT_SELF )
{
	int bPartyAlive = FALSE;

	// For each faction member
	object oFM = GetFirstFactionMember( oCreature, FALSE );
	while ( GetIsObjectValid(oFM) == TRUE )
	{
		if ( GetIsDead(oFM) == FALSE )
		{
			if ( ( GetIsOwnedByPlayer(oFM) == TRUE ) ||
				 ( ( GetIsRosterMember(oFM) == TRUE ) && ( GetIsCompanionPossessionBlocked(oFM) == FALSE ) ) )
			{
				if ( GetIsInCombat(oFM) == FALSE )
				{
					// At least one member alive and not in combat
					bPartyAlive = TRUE;
				}
				else
				{
					// "safe" conditions failed
					return ( FALSE );
				}
			}
		}
		
		oFM = GetNextFactionMember( oCreature, FALSE );
	}
	
	// Check if at least one member is alive and not in combat
	if ( bPartyAlive == FALSE )
	{
		return ( FALSE );
	}

	// Nearest valid, living, hostile, non-scripthidden creature
	object oHostile = GetNearestCreature( CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, oCreature, 1 );

	if ( ( GetIsObjectValid( oHostile ) == TRUE ) && 
		 ( LineOfSightObject( oCreature, oHostile ) == TRUE ) && 
		 ( GetDistanceBetween( oCreature, oHostile ) < KNOCKOUT_WAKE_UP_SAFE_DISTANCE ) )
	{
		return ( FALSE );
	}
	else
	{	
		// It's safe enough
		return ( TRUE );
	}
}

// Full resurrection, no penalty
void ResurrectCreature( object oCreature )
{
	ApplyEffectToObject( DURATION_TYPE_INSTANT, EffectResurrection(), oCreature );
	ApplyEffectToObject( DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_HEALING_G), oCreature );
	AssignCommand( oCreature, ForceRest(oCreature) );
}

// Resurrect entire faction ( PC party )
void ResurrectFaction( object oFactionMember )
{
	object oFM = GetFirstFactionMember( oFactionMember, FALSE );
	while ( GetIsObjectValid(oFM) == TRUE )
	{
		ResurrectCreature( oFM );
		oFM = GetNextFactionMember( oFactionMember, FALSE );
	}	
}

// Go unconscious, queue AttemptToWakeUpCreature()
void KnockOutCreature( object oCreature )
{
	AssignCommand( oCreature, SetCommandable(TRUE) );
	AssignCommand( oCreature, ClearAllActions(TRUE) );
	AssignCommand( oCreature, DelayCommand( KNOCKOUT_WAKE_UP_DELAY, AttemptToWakeUpCreature(oCreature) ) );
}

// Random audio/visual feedback for knock out
void VoiceCryForHelp( object oCreature )
{
	int nCry = d3();
	switch ( nCry )
	{
		case 1:
			nCry = VOICE_CHAT_PAIN1; break;
		case 2:
			nCry = VOICE_CHAT_PAIN2; break;
		default:
			nCry = VOICE_CHAT_PAIN3;
	}
	
	AssignCommand( oCreature, PlayVoiceChat( nCry, oCreature ) );
	AssignCommand( oCreature, SpeakString( GetStringByStrRef( KNOCKOUT_CRYFORHELP ), TALKVOLUME_TALK ) );
}

// Recursive function to Wake Up, Show and Hide Death Pop-up
void AttemptToWakeUpCreature( object oCreature )
{
	//PrintString( "ginc_death: " + GetName(oCreature) + " executing AttemptToWakeUpCreature()" );	

	// Abort if oCreature is no longer dead
	if ( GetIsDead(oCreature) == FALSE )
	{
		//PrintString( "** ginc_death: " + GetName(oCreature) + " is no longer dead (" + IntToString(GetCurrentHitPoints(oCreature)) + " HP)" );
		RemoveDeathScreens( oCreature );
		return;
	}
	
	// Check if it's safe to wake up
	if ( GetIsSafeToWakeUp(oCreature) == TRUE )
	{
		//PrintString( "** ginc_death: " + GetName(oCreature) + " is waking up" );
		WakeUpCreature( oCreature );
		RemoveDeathScreens( oCreature );
		return;
	}
	
	// Check if there are any members left for PC to possess
	if ( GetIsPC(oCreature) == TRUE )
	{
		if ( GetIsDeathPopUpDisplayed(oCreature) == FALSE )
		{
			if ( GetIsPartyPossessible(oCreature) == FALSE )
			{
				//PrintString( "** ginc_death: " + GetName(oCreature) + "'s party wiped. displaying death screen" );	
				ShowProperDeathScreen( oCreature );
			}
		}
	}
	
	// BMA-OEI 8/15/06 -- Knock out feedback
	if ( d6() == 1 )
	{
		//PrintString( "** ginc_death: " + GetName(oCreature) + " cries for help" );
		VoiceCryForHelp( oCreature );
	}

	//PrintString( "** ginc_death: " + GetName(oCreature) + " still dead. next AttemptToWakeUpCreature() in 3s" );
	DelayCommand( KNOCKOUT_WAKE_UP_DELAY, AttemptToWakeUpCreature(oCreature) );
}

// Get Up after KnockOut
void WakeUpCreature( object oCreature )
{
	//RemoveEffects( oCreature );
	ApplyEffectToObject( DURATION_TYPE_INSTANT, EffectResurrection(), oCreature );
	ApplyEffectToObject( DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_HEALING_S), oCreature );
	
	event eRes = EventSpellCastAt( oCreature, SPELL_RESURRECTION, FALSE );
	SignalEvent( oCreature, eRes );
}

// Determine if Death screen is visible
int GetIsDeathPopUpDisplayed( object oPC=OBJECT_SELF )
{
	return ( GetLocalInt( oPC, KNOCKOUT_POPUP_DISPLAYED ) );
}

// Set var to identify Death screen as visible
void SetIsDeathPopUpDisplayed( object oPC, int bDisplayed )
{
	SetLocalInt( oPC, KNOCKOUT_POPUP_DISPLAYED, bDisplayed );
}

// Show appropriate Death screen for Single & Multiplayer
void ShowProperDeathScreen( object oPC=OBJECT_SELF )
{
	// Force PC into original character
	int bIsSoZ = GetIsSoZ(); // kL_add ->
	if (!bIsSoZ || GetIsPC(oPC))
	{
		oPC = SetOwnersControlledCompanion( oPC );
	}
	else if (bIsSoZ)
	{
		oPC = GetFirstPC(FALSE);
	}

	int bWaitForHelp = FALSE;
	int bRespawn = FALSE;
	int bLoadGame = FALSE;
	int bMultiplayer = !GetIsSinglePlayer();
	
	// Wait For Help, Respawn options only available in MP
	if ( bMultiplayer == TRUE )
	{
		bWaitForHelp = TRUE;
		bRespawn = !bIsSoZ; // kL_add. <--- JWR-OEI removing respawn from our campaign!! Even in multiplayer.
		bLoadGame = GetIsPCHost(oPC);
	}
	else
	{
		bWaitForHelp = FALSE;
		bRespawn = FALSE;
		bLoadGame = TRUE;
	}

	ShowDeathScreen( oPC, TRUE, bRespawn, bLoadGame, bWaitForHelp );
	SetIsDeathPopUpDisplayed( oPC, TRUE );
}

// Hide & Reset Death-related GUI screens
void RemoveDeathScreens( object oPC=OBJECT_SELF )
{
	HideDeathScreen( oPC );
	HideHiddenDeathScreen( oPC );
	SetIsDeathPopUpDisplayed( oPC, FALSE );
}

// Displays Death Screen to oPC
// - bModal: T/F, Display window modally
// - bRespawn: T/F, Enables Respawn button
// - bLoadGame: T/F, Enables Load Game button
// - bWaitForHelp: T/F, Enables Wait For Help button
void ShowDeathScreen( object oPC, int bModal=TRUE, int bRespawn=FALSE, int bLoadGame=FALSE, int bWaitForHelp=FALSE )
{
	SetGUIObjectHidden( oPC, GUI_DEATH, GUI_DEATH_WAIT_FOR_HELP, !bWaitForHelp );
	SetGUIObjectHidden( oPC, GUI_DEATH, GUI_DEATH_RESPAWN, !bRespawn );
	SetGUIObjectDisabled( oPC, GUI_DEATH, GUI_DEATH_LOAD_GAME, !bLoadGame );
	DisplayGuiScreen( oPC, GUI_DEATH, bModal );
}

// Hides Death Screen for oPC
void HideDeathScreen( object oPC )
{
	CloseGUIScreen( oPC, GUI_DEATH );	
}

// Displays Hidden Death Screen ( full screen button ) to oPC
void ShowHiddenDeathScreen( object oPC )
{
	DisplayGuiScreen( oPC, GUI_DEATH_HIDDEN, FALSE );
}

// Hides Hidden Death Screen for oPC
void HideHiddenDeathScreen( object oPC )
{
	CloseGUIScreen( oPC, GUI_DEATH_HIDDEN );
}