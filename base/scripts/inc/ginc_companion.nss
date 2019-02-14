// ginc_companion
/*

Helper functions for companions.



Basic info on using companions:

Initialization:
The function AddCompanionsToRoster() will get called when a module loads by the k_mod_load() script
When game first starts, we add all companions to the roster.
The Campaign NPC flag is set to true for all of them so that they will not show in the party selection screen.  


Module Transitions:
ga_load_module()
When a module transition occurs, party members are automatically carried over.
Roster members not in the party are despawned and saved.by the function SaveRosterLoadModule() which is called by the script ga_load_module()


Companion Spawns:
ga_roster_spawn(string sRosterName, string sTargetLocationTag)
Use this when you want to have the companion appear, but not be put into the party just yet.  
Instances of companions should be spawned in from the roster.  
They should not be placed as instances via the toolset or created in script using CreateObject().
Since all companions are initialized at the beginning of the game to be in the roster, this script allows us to create or move the companion as necessary with a single call.


Companion Joins Party:
ga_roster_party_add(string sRosterName)
This will add the companion to the party, and will automatically cause the companion to appear nearby if he isnt already.  It isnt necessary to spawn the companion first.
This does not affect whether they will display on the party selection screen.  Use this function to manipulate whether they appear on the party selection screen:
ga_roster_campaignnpc(string sRosterName, int nCampaignNPC)
nCampaignNPC = 0 means companion will appear on party selection window.


Companion Leaves Party:
ga_roster_party_remove(string sRosterName, string sTarget)
The companion will leave the party and immediately despawn.


Finding Despawned Companions:
Companions will gather at certain locations. This generally requires custom On Client Enter scripts such as those like 1001_cliententer and 2110_client_enter used in the OC.

*/

// ChazM 8/24/06 - split from ginc_companions, added SetInfluence()
// BMA-OEI 9/12/06 -- Added PLAYER_QUEUED_ACTION, Get/SetHasPlayerQueuedAction(), PlayerControlPossessed/Unpossessed(), HandlePlayerControlChanged()
// DBR 9/12/06 - Replaced an ActionAttack with a Move and Attack during a de-possession. Also modified GetHasPlayerQueuedAction to discount ActionAttacks as well.
// BMA-OEI 9/13/06 -- Set Preferred Attack Target (Checked in HenchmenCombatRound)
// ChazM 9/13/06 - Added execute gr_pc_spawn when unpossessing owned character
// BMA-OEI 9/13/06 -- Added Get/Set/StorePlayerQueuedTarget() (x0_inc_henai, ginc_cutscene)
// ChazM 9/20/06 - ginc_misc, ginc_henchman removed - not dependent
// ChazM 5/1/07 - added GUI_SCRIPT_SCREEN_PARTYSELECT, additional comments
// ChazM 5/4/07 - Added various HangOut related funcitons
// ChazM 5/29/07 - comment
// ChazM 5/30/07 - added GetIsRosterNameInParty(), modified IsInParty()
// ChazM 6/25/07 - GoToHangOutSpot() - clear actions bfore moving/jumping
// void main(){}

//#include "ginc_henchman"
//#include "ginc_misc"
#include "nw_i0_generic"	// has SetAssociateState()
#include "x0_i0_petrify"	// has RemoveEffectOfType()
#include "ginc_debug"

//-------------------------------------------------
// Constants
//-------------------------------------------------
const string INFLUENCE_PREFIX	= "00_nInfluence";
const int INFLUENCE_MIN = -100; // Companion Influence cap
const int INFLUENCE_MAX = 100;
const string PLAYER_QUEUED_ACTION = "N2_PLAYER_QUEUED_ACTION";
const string PLAYER_QUEUED_TARGET = "N2_PLAYER_QUEUED_TARGET";

const string GUI_SCRIPT_SCREEN_PARTYSELECT = "SCRIPT_SCREEN_PARTYSELECT";

// Prefix for the companion spawnpoints.  For example, bishop will
// spawn at waypoint w/ tag "spawn_bishop"
const string COMPANION_SPAWN_WP_PREFIX = "spawn_";


//-------------------------------------------------
// Prototypes
//-------------------------------------------------
void SetAssociatesState(int nAssociateType, object oPC, int nCondition, int bValid = TRUE);
void SetAllAssociatesState(object oMaster, int nCondition, int bValid = TRUE);
void ClearAssociatesActions(int nAssociateType, object oPC, int nClearCombatState = FALSE);
void ClearAllAssociatesActions(object oMaster, int nClearCombatState = FALSE);
void SetAllAssociatesFollow(object oMaster, int bValid=TRUE);
int IsHenchman(object oThisHenchman, object oPC);
int IsHenchmanByTag(object oPC, string sHenchmanTag="");
object GetHenchmanByTag(object oPC, string sHenchmanTag="");
int RemoveHenchmanByTag(object oPC, string sHenchmanTag="");
void ApplyHenchmanModifier(object oHenchman = OBJECT_SELF);
void RemoveHenchmanModifier(object oHenchman = OBJECT_SELF);
void AddHenchmanToCompanion(object oCompanionMaster, object oHenchman = OBJECT_SELF);
void RemoveHenchmanFromCompanion(object oCompanionMaster, object oHenchman = OBJECT_SELF);
object GetPCLeader(object oPC=OBJECT_SELF);
int GetIsInRoster(string sRosterName);
int GetIsRosterNameInParty(object oPC, string sRosterName);
void PrintRosterList();
void ClearRosterList();
void TestAddRosterMemberByTemplate(string sRosterName, string sTemplate);
void TestRemoveRosterMember(string sRosterName);
int GetIsObjectInParty(object oMember);
void DespawnAllRosterMembers(int bExcludeParty=FALSE);

// Remove all selectable roster members from oPC's party
// - bIgnoreSelectable: If TRUE, also despawn non-Selectable roster members
void RemoveRosterMembersFromParty( object oPC, int bDespawnNPC=TRUE, int bIgnoreSelectable=FALSE );

// Return the number of roster members in oPC's party
int GetNumRosterMembersInParty( object oPC );
	
// Despawn non-party roster members and save module state before transitioning to a new module
// - sModuleName: Name of module to load
// - sWaypoint: Optional starting point for party
void SaveRosterLoadModule( string sModuleName, string sWaypoint="" );

// ForceRest() oPC's party
void ForceRestParty( object oPC );

int GetInfluence(object oCompanion);
void SetInfluence(object oCompanion, int nInfluence); // kL

// User defined event handler for possessing a party member
// Forces unpossessed, non-associates to follow the new leader
void PlayerControlPossessed( object oCreature );

// User defined event handler for unpossessing a party member
// Queue player queued action lock to circumvent DetermineCombatRound()
void PlayerControlUnpossessed( object oCreature );

// User defined event handler for EVENT_PLAYER_CONTROL_CHANGED (2052)
void HandlePlayerControlChanged( object oCreature );

// Return value of player queued action local var
// Used to prevent DetermineCombatRound() clearing actions queued during player possession
int GetHasPlayerQueuedAction( object oCreature );

// Set player queued action local var to bQueued
void SetHasPlayerQueuedAction( object oCreature, int bQueued );

// Return's oCreature's preferred attack target
// Used in HenchmenCombatRound() to prevent smashing player queued attacks
object GetPlayerQueuedTarget( object oCreature );

// Sets oCreature's preferred attack target to oTarget
void SetPlayerQueuedTarget( object oCreature, object oTarget );

// Stores attempted attack target as preferred attack target
// Used for HenchmenCombatRound() to prevent smashing player queued attacks
// * GetAttemptedAttackTarget() returns caller's ACTION_ATTACKOBJECT target
void StorePlayerQueuedTarget();

//-------------------------------------------------
// prototypes to avoid using
//-------------------------------------------------
int IsInParty(string sRosterName); // use GetIsRosterNameInParty() instead


//-------------------------------------------------
// Function Definitions
//-------------------------------------------------
/*
string GetMyRosterName()
{
	object oSelf = OBJECT_SELF;
	string sRosterName = GetRosterNameFromObject(oSelf);
	if (sRosterName == "")
	{
		PrettyError("ga_set_hangout failed - couldn't get Roster Name for " + GetName(oSelf));
	}
	return (sRosterName);
}
*/


// Return faction leader of oPC. If faction leader is not a PC, return OBJECT_INVALID.
object GetPCLeader(object oPC=OBJECT_SELF)
{
	object oMaster = GetFactionLeader(oPC);

	if (GetIsPC(oMaster) == FALSE)
	{
		oMaster = OBJECT_INVALID;
	}

	return (oMaster);
}

// Check if sRosterName is a valid RosterID
int GetIsInRoster(string sRosterName)
{
	string sRosterID = GetFirstRosterMember();
	
	while (sRosterID != "")
	{
		if (sRosterID == sRosterName) 
		{
			return (TRUE);
		}

		sRosterID = GetNextRosterMember();
	}

	return (FALSE);
}

// Add specified companion to roster using either an instance found or else the Template
void AddCompanionToRoster(string sRosterName, string sTagName, string sResRef)
{
	string WP_Prefix = "spawn_";

	object oCompanion 	= GetObjectByTag(sTagName);
	int bInRoster		= GetIsInRoster(sRosterName);

	// check if companion already in roster.
	if (bInRoster)
	{
		// already in roster	
		// shouldn't need to do anything?
	}		
	else
	{
		// not in roster.
		if (GetIsObjectValid(oCompanion))
		{
			
			// instance of companion is in world - add him to roster
			AddRosterMemberByCharacter(sRosterName, oCompanion);
		}
		else
		{
			// Add companion Blueprint instead
				AddRosterMemberByTemplate(sRosterName, sResRef);
		}
	}
}

int GetIsRosterNameInParty(object oPC, string sRosterName)
{
    object oCompanion = GetObjectFromRosterName(sRosterName);
	return (GetFactionEqual(oPC, oCompanion));
}

// This function should only be used to check if roster members are in the party
// This function is unfortunately named (generic name for a specific funtion), 
// but is to entrenched to rename.
int IsInParty(string sRosterName)
{
	object oPC = GetFirstPC();
	return (GetIsRosterNameInParty(oPC, sRosterName));
	
/*
	object oFM = GetFirstFactionMember(oPC, FALSE);
    object oCompanion = GetObjectFromRosterName(sRosterName);
    
	while(GetIsObjectValid(oFM))
	{
		if(oFM == oCompanion)
		{
			return 1;
		}
		oFM = GetNextFactionMember(oPC, FALSE);
	}
	return 0;
*/
}


// returns true or false
int IsHenchman(object oThisHenchman, object oPC)
{
	if (!GetIsPC(oPC)) 
		return FALSE;

	object oHenchman;
	int i;
	for (i=1; i<=GetMaxHenchmen(); i++)
   	{
		oHenchman = GetHenchman(oPC, i);
	   	if (GetIsObjectValid(oHenchman))
			if (oHenchman == oThisHenchman)
	   			return TRUE;
	}
	return FALSE;
}

// returns true or false
int IsHenchmanByTag(object oPC, string sHenchmanTag="")
{
	return (GetIsObjectValid(GetHenchmanByTag( oPC, sHenchmanTag)));
}


// Returns henchman with specified tag if found
object GetHenchmanByTag(object oPC, string sHenchmanTag="")
{
	if (sHenchmanTag == "")
		sHenchmanTag = GetTag(OBJECT_SELF);

	object oHenchman;
	int i;
	for (i=1; i<=GetMaxHenchmen(); i++)
   	{
		oHenchman = GetHenchman(oPC, i);
		//PrintString ("Henchman [" + IntToString(i) + "] = " + GetName(oHenchman));
	   	if (GetIsObjectValid(oHenchman))
		{
			//PrintString ("Henchman [" + IntToString(i) + "] = " + GetName(oHenchman));
			if (sHenchmanTag == GetTag(oHenchman))
	   			return oHenchman;
		}
	}
	return OBJECT_INVALID;
}

// Removes henchman with specified tag if found
int RemoveHenchmanByTag(object oPC, string sHenchmanTag = "")
{
    object oHenchman = GetHenchmanByTag(oPC, sHenchmanTag);

    if (GetIsObjectValid(oHenchman))
    {
        RemoveHenchman(oPC, oHenchman);
		AssignCommand(oHenchman, ClearAllActions(TRUE)); // needed to get rid of autofollow
		return TRUE;
    }
	return FALSE;
}		


void SetHangOutSpot(string sRMRosterName, string sHangOutWPTag)
{
	string sVarName = sRMRosterName + "HangOut";
	SetGlobalString(sVarName, sHangOutWPTag);
}

string GetHangOutSpot(string sRMRosterName)
{
	string sVarName = sRMRosterName + "HangOut";
	string sHangOutWPTag = GetGlobalString(sVarName);
	return (sHangOutWPTag);
}

// set up a companion.
void InitializeCompanion(string sRosterName, string sTag, string sResRef)
{
	AddCompanionToRoster( sRosterName, sTag, sResRef );
	SetIsRosterMemberCampaignNPC( sRosterName, TRUE );
	SetHangOutSpot(sTag, COMPANION_SPAWN_WP_PREFIX + sTag);
}

object GetHangoutObject(string sRMRosterName)
{
	object oHangOut;
	// is current hang out spot to be found in this module?
	string sHangOutWPTag = GetHangOutSpot(sRMRosterName);
	if (sHangOutWPTag != "")
	{
		PrettyDebug(" - sHangOutWPTag =" + sHangOutWPTag);
		oHangOut = GetObjectByTag(sHangOutWPTag);
	}		
	return (oHangOut);
}


// makes RosterMember appear at his designated hangout
void SpawnNonPartyRosterMemberAtHangout(string sRMRosterName)
{
	PrettyDebug("SpawnNonPartyRosterMemberAtHangout(" + sRMRosterName + ")");
	// if RM doesn't exist (will exist if in party)
	if (GetIsObjectValid(GetObjectFromRosterName(sRMRosterName)) == FALSE)
	{
		PrettyDebug(" - Object deosn't exist");
		// is current hang out spot to be found in this module?
		object oHangOut = GetHangoutObject(sRMRosterName);
		if (GetIsObjectValid(oHangOut) == TRUE)
		{
			PrettyDebug(" - Hangout location found, spawning " + sRMRosterName);
			location lHangOut = GetLocation(oHangOut);
			object oRM = SpawnRosterMember(sRMRosterName, lHangOut);
			if (!GetIsObjectValid(oRM))
			{
				PrettyError("Failed in spawn " + sRMRosterName + " from roster." );
			}
			return;
		}
	}
	PrettyDebug(" - " + sRMRosterName + " not spawned from roster." );

}

// 
void GoToHangOutSpot(string sRosterName)
{
	object oRM = GetObjectFromRosterName(sRosterName);
	string sName = GetName(oRM);
	if (!GetIsObjectValid(oRM))	
	{ // no roster member instance available, so attempt to spawn in.
		PrettyDebug("GoToHangOutSpot(" + sName + "): no roster member instance available, so attempt to spawn in");
		SpawnNonPartyRosterMemberAtHangout(sRosterName);
		return;
	}
	
	// remove RM from party.
	object oPC = GetCurrentMaster(oRM);
	int bDespawnNPC=FALSE; // wait till later to determine whether we should despawn.
	PrettyDebug("GoToHangOutSpot(" + sName + "): RemoveRosterMemberFromParty - " + GetName(oRM));
	RemoveRosterMemberFromParty( sRosterName, oPC, bDespawnNPC);
	
	
	// move or despawn RM as needed to go to hangout.
	object oHangOut = GetHangoutObject(sRosterName);
	if (!GetIsObjectValid(oHangOut))	
	{ // hangout is not in this module, despawn and let module load take care of it.
		PrettyDebug("GoToHangOutSpot(" + sName + "): hangout is not in this module, despawn and let module load take care of it");

		DespawnRosterMember( sRosterName );
	} 
	else if (GetArea(oHangOut) == GetArea(oRM))
	{	// if in same area, walk to spot
		PrettyDebug("GoToHangOutSpot(" + sName + "): if in same area, walk to spot ");
    	AssignCommand(oRM, ClearAllActions(TRUE));
    	AssignCommand(oRM, ActionForceMoveToObject(oHangOut));
	}
	else
	{ // jump to hang out spot in another area.
		PrettyDebug("GoToHangOutSpot(" + sName + "): jump to hang out spot in another area.");
    	AssignCommand(oRM, ClearAllActions(TRUE));
    	AssignCommand(oRM, ActionJumpToObject(oHangOut));
	}
}	

// 
int GetIsInHangOutArea(string sRosterName)
{
	object oRM = GetObjectFromRosterName(sRosterName);
	if (!GetIsObjectValid(oRM))	
	{ // no roster member instance available
		return FALSE;
	}
	
	// move or despawn RM as needed to go to hangout.
	object oHangOut = GetHangoutObject(sRosterName);
	if (!GetIsObjectValid(oHangOut))	
	{ // hangout is not in this module
		return FALSE;
	} 
	
	return (GetArea(oHangOut) == GetArea(oRM));
}

// Despawn all companions in oPC's party (faction)
void DespawnAllCompanions(object oPC)
{
	object oFM = GetFirstFactionMember(oPC, FALSE);
	string sRosterName;
	while (GetIsObjectValid(oFM) == TRUE)
	{
		PrintString("DespawnAllCompanions: "+GetName(oFM));
		if (GetIsRosterMember(oFM) == TRUE)
		{
			sRosterName = GetRosterNameFromObject(oFM);
			DespawnRosterMember(sRosterName);
			oFM = GetFirstFactionMember(oPC, FALSE);
		}
		else
		{
			oFM = GetNextFactionMember(oPC, FALSE);
		}
	}
}

void SetAssociatesState(int nAssociateType, object oPC, int nCondition, int bValid = TRUE)
{
	int i = 1;
	object oAssoc = GetAssociate(nAssociateType, oPC, i);
	while (GetIsObjectValid(oAssoc))
	{
		AssignCommand(oAssoc, SetAssociateState(nCondition, bValid));
		//PrintString("" + GetName(oAssoc) + " - state set to not follow - " + IntToString(bValid));
		i++;
		oAssoc = GetAssociate(nAssociateType, oPC, i);

	}
	return;
}

void SetAllAssociatesState(object oMaster, int nCondition, int bValid = TRUE)
{
 	SetAssociatesState(ASSOCIATE_TYPE_ANIMALCOMPANION, oMaster, nCondition, bValid);
 	SetAssociatesState(ASSOCIATE_TYPE_DOMINATED, oMaster, nCondition, bValid);
 	SetAssociatesState(ASSOCIATE_TYPE_FAMILIAR, oMaster, nCondition, bValid);
 	SetAssociatesState(ASSOCIATE_TYPE_HENCHMAN, oMaster, nCondition, bValid);
 	SetAssociatesState(ASSOCIATE_TYPE_SUMMONED, oMaster, nCondition, bValid);
	return;
}

void ClearAssociatesActions(int nAssociateType, object oPC, int nClearCombatState = FALSE)
{
	int i = 1;
	object oAssoc = GetAssociate(nAssociateType, oPC, i);
	while (GetIsObjectValid(oAssoc))
	{
		AssignCommand(oAssoc, ClearAllActions(nClearCombatState));
		i++;
		oAssoc = GetAssociate(nAssociateType, oPC, i);

	}
	return;

}

void ClearAllAssociatesActions(object oMaster, int nClearCombatState = FALSE)
{
 	ClearAssociatesActions(ASSOCIATE_TYPE_ANIMALCOMPANION, oMaster, nClearCombatState);
 	ClearAssociatesActions(ASSOCIATE_TYPE_DOMINATED, oMaster, nClearCombatState);
 	ClearAssociatesActions(ASSOCIATE_TYPE_FAMILIAR, oMaster, nClearCombatState);
 	ClearAssociatesActions(ASSOCIATE_TYPE_HENCHMAN, oMaster, nClearCombatState);
 	ClearAssociatesActions(ASSOCIATE_TYPE_SUMMONED, oMaster, nClearCombatState);

}

void SetAllAssociatesFollow(object oMaster, int bValid=TRUE)
{
	// followers use ActionForceFollowObject to follow PC.  This can only be stopped with a
	// Clear all actions.
	if (bValid == FALSE)
		ClearAllAssociatesActions(oMaster);

	SetAllAssociatesState(oMaster, NW_ASC_MODE_STAND_GROUND, !bValid);
}


// apply an AttackIncrease or Decrease effect to henchman of a companion based on the influence 
// the PC has with the companion
void ApplyHenchmanModifier(object oHenchman = OBJECT_SELF)
{
	object oCompanionMaster = GetMaster(oHenchman);
	int iInfluence = GetInfluence(oCompanionMaster);
	int iModifier = iInfluence/10;
	effect eAttack;

	if (iModifier > 0)
		eAttack = EffectAttackIncrease(iModifier);
	else if (iModifier < 0)
		eAttack = EffectAttackDecrease(abs(iModifier));

	if (iModifier != 0)
		ApplyEffectToObject(DURATION_TYPE_PERMANENT, eAttack, oHenchman);
}

// Remove the effect applied with ApplyHenchmanModifier().  Note that all effects of given types are removed 
// (including those derived from other sources such as spells).
void RemoveHenchmanModifier(object oHenchman = OBJECT_SELF)
{
	RemoveEffectOfType(oHenchman, EFFECT_TYPE_ATTACK_DECREASE);
	RemoveEffectOfType(oHenchman, EFFECT_TYPE_ATTACK_INCREASE);
}

// Adds a henchman and applies modifiers
void AddHenchmanToCompanion(object oCompanionMaster, object oHenchman = OBJECT_SELF)
{
	AddHenchman (oCompanionMaster, oHenchman);
	ApplyHenchmanModifier(oHenchman);
}

// Removes a henchman and modifiers
void RemoveHenchmanFromCompanion(object oCompanionMaster, object oHenchman = OBJECT_SELF)
{
	RemoveHenchmanModifier(oHenchman);
	RemoveHenchman(oCompanionMaster, oHenchman);
}

// List roster member names on screen
void PrintRosterList()
{
	int nCount = 0;
	string sRosterName = GetFirstRosterMember();

	PrettyMessage("Printing Roster List...");

	while (sRosterName != "")
	{
		nCount = nCount + 1;
		PrettyMessage(" Member " + IntToString(nCount) + ": " + sRosterName);
		sRosterName = GetNextRosterMember();
	}
	
	PrettyMessage("Roster List finished (" + IntToString(nCount) + " members).");
}

// Remove all members from roster
void ClearRosterList()
{
	int nCount = 0;
	int bSuccess = 0;
	string sMember = GetFirstRosterMember();
	
	while (sMember != "")
	{
		nCount++;
		bSuccess = RemoveRosterMember(sMember);
		if (bSuccess == TRUE)
		{
			PrettyMessage("ginc_roster: ClearRosterList() successfully removed " + sMember);
		}	
		else
		{
			PrettyError("ginc_roster: ClearRosterList() could not find " + sMember);
		}
	
		// Reset iterator
		sMember = GetFirstRosterMember();
	}
}

// Attempt AddRosterMemberByTemplate()
void TestAddRosterMemberByTemplate(string sRosterName, string sTemplate)
{
	int bResult = AddRosterMemberByTemplate(sRosterName, sTemplate);
	if (bResult == TRUE)
	{
		PrettyMessage("ginc_roster: successfully added " + sRosterName + " (" + sTemplate + ")");	
	}
	else
	{
		PrettyError( "ginc_roster: failed to add " + sRosterName + " (" + sTemplate + ")");
	}
}

// Attempt RemoveRosterMember()
void TestRemoveRosterMember(string sMember)
{
	int bResult = RemoveRosterMember(sMember);
	if (bResult == TRUE)
	{
		PrettyMessage("ginc_roster: successfully removed " + sMember);
	}
	else
	{
		PrettyError("ginc_error: failed to remove " + sMember);	
	}
}

// Check if oMember is in first PC's party (faction)
int GetIsObjectInParty(object oMember)
{
	return (GetFactionEqual(oMember, GetFirstPC()));
}

// Despawn all roster members in module. Option bExcludeParty=TRUE to ignore party members.
// Useful to update roster state before a module transition.
void DespawnAllRosterMembers(int bExcludeParty=FALSE)
{
	object oMember;
	string sRosterID = GetFirstRosterMember();

	// For each roster ID
	while (sRosterID != "")
	{
		oMember = GetObjectFromRosterName(sRosterID);
		
		// If they're in the game
		if (GetIsObjectValid(oMember) == TRUE)
		{
			// And in my party
			if (GetIsObjectInParty(oMember) == TRUE)
			{
				if (bExcludeParty == FALSE)
				{
					RemoveRosterMemberFromParty(sRosterID, GetFirstPC(), TRUE);
				}
			}
			else
			{
				DespawnRosterMember(sRosterID);
			}
		}
	
		sRosterID = GetNextRosterMember();
	}
}
	
// Remove all selectable roster members from oPC's party
// - bIgnoreSelectable: If TRUE, also despawn non-Selectable roster members
void RemoveRosterMembersFromParty( object oPC, int bDespawnNPC=TRUE, int bIgnoreSelectable=FALSE )
{
	string sRosterName;
		
	// For each party member
	object oMember = GetFirstFactionMember( oPC, FALSE );
	while ( GetIsObjectValid( oMember ) == TRUE )
	{
		sRosterName = GetRosterNameFromObject( oMember );

		// If party member is a roster member	
		if ( sRosterName != "" )
		{
			// And party member is not required
			if ( ( bIgnoreSelectable ) || ( GetIsRosterMemberSelectable( sRosterName ) == TRUE ) )
			{
				// If party member is controlled by a PC
				if ( GetIsPC( oMember ) == TRUE )
				{
					// Force PC into original character
					SetOwnersControlledCompanion( oMember );
				}		
				
				RemoveRosterMemberFromParty( sRosterName, oPC, bDespawnNPC );
				oMember = GetFirstFactionMember( oPC, FALSE );
			}
			else
			{
				oMember = GetNextFactionMember( oPC, FALSE );
			}
		}
		else
		{
			oMember = GetNextFactionMember( oPC, FALSE );
		}
	}	
}
	
// Return the number of roster members in oPC's party
int GetNumRosterMembersInParty( object oPC )
{
	int nCount = 0;

	object oMember = GetFirstFactionMember( oPC, FALSE );

	while ( GetIsObjectValid( oMember ) == TRUE )
	{
		// If party member has a roster name
		if ( GetRosterNameFromObject( oMember ) != "" )
		{
			nCount = nCount + 1;
		}

		oMember = GetNextFactionMember( oPC, FALSE );
	}
	
	return ( nCount );
}
	
// Despawn non-party roster members and save module state before transitioning to a new module
// - sModuleName: Name of module to load
// - sWaypoint: Optional starting point for party
void SaveRosterLoadModule( string sModuleName, string sWaypoint="" )
{
	// Save non-party roster member states
	DespawnAllRosterMembers( TRUE );
	LoadNewModule( sModuleName, sWaypoint );
}


// ForceRest() oPC's party
void ForceRestParty( object oPC )
{
	object oFM = GetFirstFactionMember( oPC, FALSE );
	while ( GetIsObjectValid( oFM ) == TRUE )
	{
		ForceRest( oFM );
		oFM = GetNextFactionMember( oPC, FALSE );
	}
}


////////////////////////////
// Influence
//////////////////////////// 


int GetInfluence(object oCompanion)
{
	string sVarInfluence = INFLUENCE_PREFIX + GetTag(oCompanion);
	int iInfluence = GetGlobalInt(sVarInfluence);
	return (iInfluence);
}

void SetInfluence(object oCompanion, int nInfluence)
{
	string sVarInfluence = INFLUENCE_PREFIX + GetTag(oCompanion);
	if ( nInfluence < INFLUENCE_MIN )
		nInfluence = INFLUENCE_MIN;
	else if ( nInfluence > INFLUENCE_MAX )
		nInfluence = INFLUENCE_MAX;
		
	SetGlobalInt( sVarInfluence, nInfluence);
}

// User defined event handler for possessing a party member
// Forces unpossessed, non-associates to follow the new leader
void PlayerControlPossessed( object oCreature )
{
	//PrettyDebug( "ginc_companion: " + GetName( oCreature ) + " has been possessed (EVENT_PLAYER_CONTROL_CHANGED)." );
	
	object oLeader = GetFactionLeader( oCreature );
	if ( oLeader == oCreature )
	{
		//PrettyDebug ( "ginc_companion: " + GetName( oCreature ) + " is the new party leader!" );
		
		object oPM = GetFirstFactionMember( oCreature, FALSE );
		while ( GetIsObjectValid( oPM ) == TRUE )
		{
			// If I'm currently following somebody
			if ( GetCurrentAction( oPM ) == ACTION_FOLLOW )
			{
				// But I'm not possessed, not myself, and not an associate
				if ( ( GetIsPC( oPM ) == FALSE ) && 
				 	 ( oPM != oLeader ) &&
				 	 ( GetAssociateType( oPM ) == ASSOCIATE_TYPE_NONE ) )
				{
					AssignCommand( oPM, ClearAllActions() );
					AssignCommand( oPM, ActionForceFollowObject( oLeader, GetFollowDistance( oPM ) ) );
				}
			}
			
			oPM = GetNextFactionMember( oCreature, FALSE );
		}
	}
}

// User defined event handler for unpossessing a party member
// Queue player queued action lock to circumvent DetermineCombatRound()
void PlayerControlUnpossessed( object oCreature )
{
	//PrettyDebug( "ginc_companion: " + GetName( oCreature ) + " has been unpossessed (EVENT_PLAYER_CONTROL_CHANGED)." );

 	if (GetIsOwnedByPlayer(oCreature))  
	{
		ExecuteScript("gr_pc_spawn", oCreature);
	}

	if ( GetCommandable( oCreature ) == TRUE )
	{
		// BMA-OEI 9/13/06: Clear or save preferred attack target
		AssignCommand( oCreature, StorePlayerQueuedTarget() );
	
		SetHasPlayerQueuedAction( oCreature, TRUE );
		AssignCommand( oCreature, ActionDoCommand( SetHasPlayerQueuedAction( oCreature, FALSE ) ) );		
	}	
	
}

// User defined event handler for EVENT_PLAYER_CONTROL_CHANGED (2052)
void HandlePlayerControlChanged( object oCreature )
{
	if ( GetIsPC( oCreature ) == TRUE )
	{
		PlayerControlPossessed( oCreature );
	}
	else
	{
		PlayerControlUnpossessed( oCreature );
	}
}

// Return value of player queued action local var
// Used to prevent DetermineCombatRound() clearing actions queued during player possession
int GetHasPlayerQueuedAction( object oCreature )
{
	int bQueued = GetLocalInt( oCreature, PLAYER_QUEUED_ACTION );
	int nAction = GetCurrentAction( oCreature );
		
	// Safety: If following, attacking, or no more actions in queue
	if ( ( nAction == ACTION_FOLLOW ) || ( nAction == ACTION_ATTACKOBJECT ) || ( GetNumActions( oCreature ) == 0 ) )
	{
		bQueued = FALSE;
	}

	return ( bQueued );
}

// Set player queued action local var to bQueued
void SetHasPlayerQueuedAction( object oCreature, int bQueued )
{
	SetLocalInt( oCreature, PLAYER_QUEUED_ACTION, bQueued );
}

// Return's oCreature's preferred attack target
// Used in HenchmenCombatRound() to prevent smashing player queued attacks
object GetPlayerQueuedTarget( object oCreature )
{
	object oTarget = GetLocalObject( oCreature, PLAYER_QUEUED_TARGET );
	return ( oTarget );
}

// Sets oCreature's preferred attack target to oTarget
void SetPlayerQueuedTarget( object oCreature, object oTarget )
{
	SetLocalObject( oCreature, PLAYER_QUEUED_TARGET, oTarget );
}

// Stores attempted attack target as preferred attack target
// Used for HenchmenCombatRound() to prevent smashing player queued attacks
// * GetAttemptedAttackTarget() returns caller's ACTION_ATTACKOBJECT target
void StorePlayerQueuedTarget()
{
	object oTarget = GetAttemptedAttackTarget();
	SetPlayerQueuedTarget( OBJECT_SELF, oTarget );
}