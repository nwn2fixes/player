// ginc_group
/*
	Framework and functions for working with groups of objects (usually creatures)

	How to use:
	1. use ResetGroup() to clear out/delete a group before use to avoid side effects
	2. add creatures to your group using the functions under the label *** Group creation ***
	3. set up formations, noise and events to fire -- under *** Group Formation and Noise setup ***
	4. give group actions -- under *** Group Actions ***

	Notes:
	When creating groups, a creature already in a group will not join another.  Some functions have params
	to overide this, but it is not recommended and can have odd side effects.

*/
// ChazM 5/26/05
// ChazM 6/1/05 Changed ObjectGroups to use Globals instead of structs
// ChazM 6/2/05 added ResetGroup, IsGroupEmpty, and SetObject.
// ChazM 6/6/05	now includes ginc_actions, added prototypes, moved constants to top,
//				added RandomDelta(), RandomFloat(), GetNearbyLocation(), GroupAttack(),
//				GroupPlayAnimation(), GroupActionWait, modified GetMoveToWP()
// EPF 6/7/05 Added support for a rectangular formation.
// ChazM 6/7/05 Added support for additional formation types with variable sets of params.
//			Added GroupSetBMAFormation(), GroupSetCircleFormation(), GroupSetRectangleFormation(), GroupSetNoise(),
//			modified GroupMoveToWP(), removed GetFormationLocationByIndex().  Added and modified some of the base funcs.
// ChazM 6/7/05 Added support for running in formation, added GroupClearAllActions()
// ChazM 6/8/05 modified FactionToGroup(), GetBMALocation(), GetHuddleLocation(), GroupMoveToWP(), added constants, numerous comments
// ChazM 6/15/05 added GetPartyGroup(), modified ResetGroup(), added constants, added comments, added prototypes,
//			modified GroupMoveToWP to work better w/ defualts.  added GroupActionOrientToTag().
// ChazM 6/16/05 added GroupSetLocalString(), GroupOnDeathBeginConversation(), SetGroupString(), GetGroupString(),
//			modified AddToGroup()
// ChazM 6/18/05 added EncounterToGroup(), modified AddToGroup()
// ChazM 6/18/05 added GroupSetSpawnInCondition(), modified EncounterToGroup()
// ChazM 6/20/05 added GroupWander()
// ChazM 6/21/05 added SpawnCreaturesInGroupAtWP()
// ChazM 6/27/05 modified ResetGroup(), renamed bunch of "private" functions and all references, modified AddToGroup(), added InsertIntoGroup()
//				added some "how to use" comments, modified GetPartyGroup()
// ChazM 6/28/05 added DeleteGlobalObject(), modified GroupDeleteObjectIndex()
//  			added GroupActionForceExit(), GroupChangeFaction, GroupChangeToStandardFaction
// ChazM 7/1/05 added AddNearestWithTagToGroup(), GroupMoveToFormationLocation(), GroupActionMoveToObject(),
//				modified GroupMoveToWP()
// ChazM 7/5/05 added GetFirstValidInGroupFromCurrent(), modified GetNextInGroup() and GetFirstInGroup()
// BMA 7/07/05 added GroupSetFacingPoint(), modified GroupActionOrientToTag()
// ChazM 7/11/05 shortened prefixes/postfixes
// ChazM 7/26/05 Fixed SpawnCreaturesInGroupAtWP(), changed FORMATION_NONE constant, added FORMATION_DEFAULT constant
// ChazM 7/26/05 added DestroyObjectsInGroup()
// ChazM 7/27/05 added prototype, modified print strings for InsertIntoGroup()
// BMA-OEI 7/29/05 added GroupJumpToObject(), MOVE_JUMP_INSTANT
// BMA-OEI 8/06/05 added debug prints to SpawnCreaturesInGroupAtWP, GroupSetLocalString
// BMA-OEI 8/25/05 added GroupAddXXX, MOVE_FORCE_WALK, MOVE_FORCE_RUN, GroupSetImmortal/PlotFlag
// BMA-OEI 8/26/05 added GroupSpawnAtLocation,GroupForceMoveToLocation
// BDF-OEI 9/2/05 added GroupOnDeathSetLocalInt, GroupOnDeathSetLocalFloat, GroupOnDeathSetLocalString
// ChazM 9/8/05	added GroupActionForceFollowObject()
// ChazM 9/8/05 formatting changes, added GroupAddNearestTag(), GroupDetermineCombatRound(), GroupGoHostile();
//				modified GroupAddTag(); fixed FactionToGroup(), AddNearestWithTagToGroup(), GroupActionForceFollowObject()
// ChazM 9/12/05 added param bOverridePrevGroup to GroupAddMember, GroupAddTag, GroupAddNearestTag, and GroupAddEncounter
//				added GroupSetLocalObject(), GroupFollowLeader()
// ChazM 9/13/05 added GroupSurrenderToEnemies()
// ChazM 9/14/05 added GroupSetLocalInt(), GroupSetLocalFloat(), GroupStartFollowLeader(), GroupStopFollowLeader()
//				GroupActionMoveAwayFromObject(), GroupSurrenderToEnemies();
//				modified GroupActionForceFollowObject(); removed GroupFollowLeader()
// ChazM 9/15/05 added GroupMoveToObject(), GroupActionCastFakeSpellAtObject(), SendDebugMessage();
//				changed GroupJumpToObject() to GroupJumpToWP; modified AddToGroup(), FactionToGroup(), EncounterToGroup(), AddNearestWithTagToGroup()
// ChazM 9/15/05 added GroupApplyEffectToObject() and GroupRemoveEffectOfType()
// ChazM 9/29/05 added 3 new includes, removed SendDebugMessage, moved out GetGlobalObject(), SetGlobalObject(), DeleteGlobalObject() to ginc_vars;
//				RandomDelta(), RandomFloat(), GetNearbyLocation() to ginc_math
// BMA-OEI 10/26/05 added GroupSetLineFormation(), GetLineLocation(), modified GroupForceMoveToLocation(), GroupSpawnAtLocation(), GroupMoveToFormationLocation()
// BMA-OEI 11/06/05 added GroupSignalEvent()
// BMA-OEI 11/21/05 added GroupGetNumValidObjects(), GetIsGroupValid()
// BMA-OEI 11/29/05 updated GroupPlayAnimation() to check min float time
// BMA-OEI 11/29/05 updated GroupGetNumValidObjects(), GetIsGroupValid() parameter check HP > 0
// BMA-OEI 12/01/05 updated GroupGetNumValidObjects(), GetIsGroupValid() parameter check IsDead
// EPF 12/5/05 -- Added GroupOnDeathSetJournalEntry()
// EPF 1/12/06 -- added GroupSetSemicircleFormation and support for a new Semicircle formation.
// EPF 1/13/06 -- Fixed an off-by-one error in GroupAddNearestTag().
// EPF 1/30/06 -- missed a spot in the last fix, so GroupAddNearestTag was adding one too many.  Fixed.
// EPF 1/30/06 -- GroupAddTag() has a completely different off-by-one error.  Fixing.
// DBR 2/01/06 -- Added GetGroupName(), for retrieving the group that a creature is in (wrapper function)
// BMA-OEI 2/8/06 -- Added bFadeOut param to GroupOnDeathConversation()
// BMA-OEI 2/14/06 -- Removed bFadeOut param
// EPF 2/18/06 -- Added GroupSetScriptHidden().
// BMA-OEI 2/27/06 -- Added GroupFleeToExit()
// BMA-OEI 2/27/06 -- Added GroupResurrect()
// ChazM 3/16/06 modified SpawnCreaturesInGroupAtWP(), modified AddToGroup() - no longer marked as old.
// ChazM 4/19/06 Added GroupOnDeathExecuteCustomScript()
// BMA-OEI 5/23/06 -- Added IncGroupNumKilled(), GetGroupNumKiled(), GROUP_VAR_NUM_KILLED
// BMA-OEI 6/20/06 -- Added GroupSetIsDestroyable()
// BMA-OEI 7/04/06 -- Added GetIsGroupDominated()
// BMA-OEI 8/02/06 -- Update ResetGroup() to check if still in group
// ChazM 9/21/06 -- added nw_i0_generic
// ChazM 5/10/07 -- added param bSetToHostile to GroupAttackGroup() and GroupAttack()
// ChazM 5/18/07 -- comment changes
// ChazM 5/30/07 -- modified GroupDetermineCombatRound() - decoupled DCR
// ChazM 5/30/07 -- GetGroupNumKiled -> GetGroupNumKilled.  Some OC module scripts might not compile, but the NCS will remain, so this shouldn't pose a problem.
// ChazM 5/31/07 -- modified GroupDetermineCombatRound() - now uses AssignDCR() in nw_i0_generic
// ChazM 6/6/07 -- added ListMembersOfGroup()
// ChazM 6/27/07 -- Added function DoMoveType()
// ChazM 6/29/07 -- added fForceMoveTimeout param to DoMoveType()

#include "ginc_actions"
#include "ginc_effect"
#include "ginc_utility"
#include "x0_i0_petrify"
#include "ginc_vars"
#include "ginc_math"
#include "nw_i0_generic"

//void main() {}

//-------------------------------------------------
// Public constants
//-------------------------------------------------
const int FORMATION_DEFAULT 			= 0;
const int FORMATION_BMA 				= 1;
const int FORMATION_HUDDLE_FACE_IN 		= 2;
const int FORMATION_HUDDLE_FACE_OUT 	= 3;
const int FORMATION_HUDDLE_FACE_FORWARD = 4;
const int FORMATION_RECTANGLE 			= 5;
const int FORMATION_NONE 				= 6;
const int FORMATION_LINE				= 7;
const int FORMATION_SEMICIRCLE_FACE_OUT	= 8;
const int FORMATION_SEMICIRCLE_FACE_IN 	= 9;

const int MOVE_WALK 					= 1;
const int MOVE_RUN 						= 2;
const int MOVE_JUMP 					= 3;
const int MOVE_JUMP_INSTANT 			= 4;
const int MOVE_FORCE_WALK 				= 5;
const int MOVE_FORCE_RUN 				= 6;

const int GROUP_LEADER_FIRST 			= -1;
const int GROUP_LEADER_LAST 			= -2;
const int GROUP_LEADER_EXCLUDE 			= -3;

const string PARTY_GROUP_NAME 			= "theParty";

const int TYPE_INT 						= 1;
const int TYPE_FLOAT 					= 2;
const int TYPE_STRING 					= 3;

// Private constants
const string GROUP_VAR_NUM_KILLED		= "NumKilled";
const string OBJ_GROUP_MY_GROUP			= "MyGroup"; // var name stored on objects (so object can identify the group he's in)
const string OBJ_GROUP_PREFIX 			= "_OG";
const string OBJ_GROUP_NUM				= "_Num";
const string OBJ_GROUP_INDEX			= "_Indx";
const string OBJ_GROUP_FORMATION_TYPE 	= "Fmn";
const string OBJ_GROUP_FORMATION_RADIUS = "Rad";
const string OBJ_GROUP_FORMATION_COLS 	= "Col";
const string OBJ_GROUP_FORMATION_SPACING = "Spc";
const string OBJ_GROUP_NOISE_START 		= "StN";
const string OBJ_GROUP_NOISE_FACING 	= "FcN";
const string OBJ_GROUP_NOISE_LOCATION 	= "LcN";

const float DEFAULT_SPACING				= 1.8f;


//-------------------------------------------------
// Public function Prototypes
//-------------------------------------------------

void ResetGroup(string sGroupName);	// Reset a group for re-use
int IsGroupEmpty(string sGroupName);	// used to see if the group already contains creatures in it.
int GroupGetNumValidObjects(string sGroupName, int bIsDead=FALSE);	// return number of valid creatures in group
int	GetIsGroupValid(string sGroupName, int bNotDying=FALSE);		// check if group has any valid creatures in it
string GetGroupName(object oMember);	//Retrieves the group a creature is in

// Return TRUE, if all remaining members are dominated
int GetIsGroupDominated( string sGroupName );

// **********************
// *** Group creation ***
// **********************
string GetPartyGroup(object oPC);	// creates group for the party and returns name.

void GroupAddMember(string sGroupName, object oMember, int bOverridePrevGroup=FALSE);
void GroupAddFaction(string sGroupName, object oFactionMember, int nLeaderPos=GROUP_LEADER_FIRST, int bOverridePrevGroup=FALSE);
void GroupAddTag(string sGroupName, string sTag, int iMax=20, int bOverridePrevGroup=FALSE);
void GroupAddNearestTag(string sGroupName, string sTag, object oTarget=OBJECT_SELF, int iMax=20, int bOverridePrevGroup=FALSE);
void GroupAddEncounter(string sGroupName, int bWander=2, int bOverridePrevGroup=FALSE);
void GroupSpawnAtLocation(string sGroupName, string sTemplate, location lLocation, int nNum);
void GroupSpawnAtWaypoint(string sGroupName, string sTemplate, string sWaypoint, int nNum);


// ***************************************
// *** Group Formation and Noise setup ***
// ***************************************
void GroupSetNoFormation(string sGroupName);	// single base destination for group
void GroupSetBMAFormation(string sGroupName, float fSpacing=DEFAULT_SPACING);	// a staggered marching formation
void GroupSetCircleFormation(string sGroupName, int iFacing=FORMATION_HUDDLE_FACE_IN , float fRadius=5.0f);	// a circle or huddle formation
void GroupSetSemicircleFormation(string sGroupName, int iFacing = FORMATION_SEMICIRCLE_FACE_OUT, float fRadius = 5.f);
void GroupSetLineFormation(string sGroupName, float fSpacing=DEFAULT_SPACING); // single row formation, leader in middle
void GroupSetRectangleFormation(string sGroupName, float fSpacing=1.8f, int nColumns=2);	// a rectangular or single line formation

void GroupSetNoise(string sGroupName, float fStartNoise=1.0f, float fFacingNoise=10.0f, float fLocationNoise=1.0f);	// use to add noise to the group and make them appear less synchronized

//  Only 1 of the GroupOnDeath functions can be applied per group - a previous GroupOnDeath function will be "overwritten" when a new one is applied.
void GroupOnDeathBeginConversation(string sGroupName, string sTalkerTag, string sConversation);	// use to have a convo begin after everyone in the group dies
void GroupOnDeathSetLocalInt( string sGroupName, object oTargetObject, string sVariableName, int nNewValue );	// Used for setting a local integer on a target object upon the death of the specified group
void GroupOnDeathSetLocalFloat( string sGroupName, object oTargetObject, string sVariableName, float fNewValue );	// Used for setting a local float on a target object upon the death of the specified group
void GroupOnDeathSetLocalString( string sGroupName, object oTargetObject, string sVariableName, string sNewValue );	// Used for setting a local string on a target object upon the death of the specified group
void GroupOnDeathSetJournalEntry(string sGroup, string sQuestTag, int nEntry, int bAllowOverride = FALSE);
void GroupOnDeathExecuteCustomScript(string sGroupName, string sScriptName);


// *********************
// *** Group Actions ***
// *********************
void GroupForceMoveToLocation(string sGroupName, location lDestination, int bRun=FALSE, float fTimeout=30.0f);
void GroupMoveToFormationLocation(string sGroupName, location lDestination, int iMoveType=MOVE_WALK);	// locomote a group to a specified location (formation and noise should be set first)
void GroupMoveToWP(string sGroupName, string sWaypoint, int iMoveType=MOVE_WALK); // locomote a group to a specified waypoint (formation and noise should be set first)
void GroupMoveToObject(string sGroupName, object oTarget, int iMoveType=MOVE_WALK); // locomote a group to a specified object (formation and noise should be set first)
void GroupFleeToExit(string sGroupName, string sWaypoint, int iMoveType=MOVE_WALK);
void GroupJumpToWP(string sGroupName, string sWaypoint);
void GroupAttack(string sGroupName, object oTarget, int bSetToHostile=TRUE);
void GroupClearAllActions(string sGroupName, int nClearCombatState = FALSE);
void GroupPlayAnimation(string sGroupName, int nAnimation, float fStartNoise=1.0f, float fSpeedBase=1.0f, float fSpeedRange=1.0f, float fDurationSectondsBase=0.0f, float fDurationSectondsRange=0.0f);
void GroupActionWait(string sGroupName, float fSeconds=0.0f);
void GroupActionOrientToTag(string sGroupName, string sTag, int iOrientation=ORIENT_FACE_TARGET, int bIgnoreWait=FALSE);
void GroupResurrect(string sGroupName, int bIgnoreWait=FALSE);

void GroupSetLocalString (string sGroupName, string sVarName, string sValue);
void GroupSetLocalObject (string sGroupName, string sVarName, object oValue);
void GroupSetLocalInt (string sGroupName, string sVarName, int iValue);
void GroupSetLocalFloat (string sGroupName, string sVarName, float fValue);

void GroupSetSpawnInCondition(string sGroupName, int nCondition, int bValid=TRUE);
void GroupWander(string sGroupName, int bValid = TRUE);
void GroupActionForceExit(string sGroupName, string sWPTag = "WP_EXIT", int bRun=FALSE); 	// forces all in group to go to destination and then destroy self.
void GroupChangeFaction(string sGroupName, string sTargetFactionMember);	// Changes everyone in group to join faction of given creature
void GroupChangeToStandardFaction(string sGroupName, int iFaction);		// Changes everyone in group to join one of the standard factions

void GroupActionMoveToObject(string sGroupName, object oTarget, int bRun=FALSE, float fRange=1.0f);	// does action move to object for all in group (doesn't use formation/noise)
void GroupAttackGroup(string sAttackerGroupName, string sAttackedGroupName, int bSetToHostile=TRUE); // have group attak targets in another group
void GroupDetermineCombatRound(string sGroupName);
void GroupSetFacingPoint(string sGroupName, vector vPoint);	// assign SetFacingPoint(vPoint) to each member, no delay
void DestroyObjectsInGroup(string sGroupName, float fDelay=0.0f);

void GroupSetImmortal(string sGroupName, int bImmortal);
void GroupSetPlotFlag(string sGroupName, int bPlotFlag);
void GroupActionForceFollowObject(string sGroupName, object oMaster, float fFollowDistance = 5.0f);
void GroupStartFollowLeader(string sGroupName, object oMaster, float fFollowDistance = 5.0f);
void GroupStopFollowLeader(string sGroupName);

void GroupGoHostile(string sGroupName);
void GroupSurrenderToEnemies(string sGroupName);
void GroupActionMoveAwayFromObject(string sGroupName, object oFleeFrom, int bRun = FALSE, float fMoveAwayRange = 40.0f);
void GroupActionCastFakeSpellAtObject(string sGroupName, int nSpell, object oTarget, int nProjectilePathType = PROJECTILE_PATH_TYPE_DEFAULT);

void GroupSignalEvent(string sGroupName, event eEvent);
void GroupSetScriptHidden(string sGroupName, int bHidden = TRUE);

int IncGroupNumKilled( string sGroupName );
int GetGroupNumKilled( string sGroupName );

void GroupSetIsDestroyable( string sGroupName, int bDestroyable, int bRaisable=TRUE, int bSelectableWhenDead=FALSE );


//-------------------------------------------------
// Private function prototypes
//-------------------------------------------------
// debug functions
void ListMembersOfGroup(string sGroupName);

// Helper funcs
//void SendDebugMessage(string sMessage);
location GetWPLocation(string sWayPoint);

// Prototypes - Group Base functions
object GroupGetObjectIndex(string sGroupName, int iIndex);
void GroupSetObjectIndex(string sGroupName, int iIndex, object oObject);
void GroupDeleteObjectIndex(string sGroupName, int iIndex);
int GroupGetNumObjects(string sGroupName);
void GroupSetNumObjects(string sGroupName, int iNumObjects);
int GroupGetCurrentIndex(string sGroupName);
void GroupSetCurrentIndex(string sGroupName, int iIndex);
object GroupGetCurrentObject(string sGroupName);
int GroupIncrementIndex(string sGroupName);

object GetFirstValidInGroupFromCurrent(string sGroupName); // return first valid object in group starting w/ current.
object GetFirstInGroup(string sGroupName);
object GetNextInGroup(string sGroupName);

// add a new a creature to a group
int InsertIntoGroup(string sGroupName, object oObject, int bOverridePrevGroup = FALSE);

void SetGroupInt(string sGroupName, string sVarName, int iValue);
int GetGroupInt(string sGroupName, string sVarName);
void DeleteGroupInt(string sGroupName, string sVarName);
void SetGroupFloat(string sGroupName, string sVarName, float fValue);
float GetGroupFloat(string sGroupName, string sVarName);
void DeleteGroupFloat(string sGroupName, string sVarName);
void SetGroupString(string sGroupName, string sVarName, string sValue);
string GetGroupString(string sGroupName, string sVarName);
void DeleteGroupString(string sGroupName, string sVarName);
void SetGroupObject( string sGroupName, string sVarName, object oValue );
object GetGroupObject( string sGroupName, string sVarName );

vector GetBMAFormationStartPosition(vector vPosition, int nIndex, float fSpacing, float fFacing);
location GetBMALocation(location lToJumpTo, int nIndex, float fSpacing);
location GetHuddleLocation(location lDestination, int iMemberIndex, int iNumObjects, float fRadius=10.0f, int iFaceType=FORMATION_HUDDLE_FACE_IN);
location GetLineLocation(location lDestination, int iMemberIndex, float fSpacing);
location GetRectangleLocation(location lDestination, int nMemberIndex, int nColumns, float fSpacing);

// old versions of functions - don't use but kept for compatibility
int AddToGroup(string sGroupName, object oObject);	// add a new a creature to a group (fails if object is already in another group)
void FactionToGroup(object oFactionMember, string sGroupName, int iLeaderPos=GROUP_LEADER_FIRST, int bOverridePrevGroup = FALSE);	// add an entire faction to a goup
void AddNearestWithTagToGroup(string sGroupName, string sTag, int iMax=20);	// adds all in the area w/ tag to a group up to specified max.
void EncounterToGroup(string sGroupName, int bWander = 2);	// adds all encounter creatures to a group
void SpawnCreaturesInGroupAtWP(int iNum, string sTemplate, string sGroupName, string sWayPoint="SPAWN_POINT");	// spawns in creatures and adds them to a group


//-------------------------------------------------
// Function Definitions
//-------------------------------------------------

//-------------------------------------------------
// Helper functions

void ListMembersOfGroup(string sGroupName)
{
	PrettyDebug("Number of objects in Group " + sGroupName + ": " + IntToString(GroupGetNumObjects(sGroupName)));
	PrettyDebug("Members of Group " + sGroupName + ": ");
	object oMember = GetFirstInGroup(sGroupName);
	int nCount = 0;

	while (GetIsObjectValid(oMember) == TRUE)
	{
		nCount++;
		PrettyDebug(" Member " + IntToString(nCount) + ": " + GetName(oMember) + " tag: " + GetTag(oMember));
		oMember = GetNextInGroup(sGroupName);
	}
}

location GetWPLocation(string sWayPoint)
{
	object oWaypoint = GetWaypointByTag(sWayPoint);
 	return (GetLocation(oWaypoint));
}

// Returns number of valid objects in a group
int GroupGetNumValidObjects(string sGroupName, int bIsDead = FALSE)
{
	int nCount = 0;
	int nPossible = GroupGetNumObjects(sGroupName);
	object oMember;
	int nHP;

	int i;
	for (i=0; i<=nPossible; i++)
	{
		oMember = GroupGetObjectIndex(sGroupName, i);

		if (GetIsObjectValid(oMember) == TRUE)
		{
			if (bIsDead == TRUE)
			{
				if (GetIsDead(oMember) == FALSE)
				{
					nCount = nCount + 1;
				}
			}
			else
			{
				nCount = nCount + 1;
			}
		}
	}

	return (nCount);
}

// Returns true if at least one group member reference is valid
// If bNotDying is TRUE, only check members that are HP>0
int	GetIsGroupValid(string sGroupName, int bNotDying = FALSE)
{
	int nPossible = GroupGetNumObjects(sGroupName);

	object oMember;

	int i;
	for (i = 0; i <= nPossible; i++)
	{
		oMember = GroupGetObjectIndex(sGroupName, i);

		if (GetIsObjectValid(oMember) == TRUE)
		{
			if (bNotDying == FALSE)
			{
				return (TRUE);
			}
			else
			{
				if (GetIsDead(oMember) == FALSE)
				{
					return (TRUE);
				}
			}
		}
	}

	return (FALSE);
}

//Retrieves the group a creature is in
//returns the string of the group name, or "" if creature is not in a group
//		NOTE: may be some problem with creatures who were formerly in a group having the residual variable
string GetGroupName(object oMember)
{
	return GetLocalString(oMember,OBJ_GROUP_MY_GROUP);
}

// Return TRUE, if all remaining members are dominated
int GetIsGroupDominated( string sGroupName )
{
	int nMax = GroupGetNumObjects( sGroupName );

	object oGM;
	int i;
	for ( i = 0; i <= nMax; i++ )
	{
		oGM = GroupGetObjectIndex( sGroupName, i );

		// If member is valid, alive, and not dominated
		if ( ( GetIsObjectValid(oGM) == TRUE ) &&
			 ( GetIsDead(oGM) == FALSE ) &&
			 ( GetHasEffectType(oGM, EFFECT_TYPE_DOMINATED) == FALSE ) )
		{
			return ( FALSE );
		}
	}

	return ( TRUE );
}

//---------------------------------------------------------------
// Group Objects

object GroupGetObjectIndex(string sGroupName, int iIndex)
{
	string sThisObj = OBJ_GROUP_PREFIX + sGroupName + IntToString(iIndex);
	return (GetGlobalObject(sThisObj));
}

void GroupSetObjectIndex(string sGroupName, int iIndex, object oObject)
{
	string sThisObj = OBJ_GROUP_PREFIX + sGroupName + IntToString(iIndex);
	SetGlobalObject (sThisObj, oObject);
}

void GroupDeleteObjectIndex(string sGroupName, int iIndex)
{
	string sThisObj = OBJ_GROUP_PREFIX + sGroupName + IntToString(iIndex);
	DeleteGlobalObject (sThisObj);
}


//---------------------------------------------------------------
// Group INTs

int GetGroupInt(string sGroupName, string sVarName)
{
	string sThisInt = OBJ_GROUP_PREFIX + sGroupName + sVarName;
	return (GetGlobalInt(sThisInt));
}

void SetGroupInt(string sGroupName, string sVarName, int iValue)
{
	string sThisInt = OBJ_GROUP_PREFIX + sGroupName + sVarName;
	SetGlobalInt(sThisInt, iValue);
}

void DeleteGroupInt(string sGroupName, string sVarName)
{
	string sThisInt = OBJ_GROUP_PREFIX + sGroupName + sVarName;
	SetGlobalInt(sThisInt, 0);
}

//---------------------------------------------------------------
// Group FLOATs

float GetGroupFloat(string sGroupName, string sVarName)
{
	string sThisVar = OBJ_GROUP_PREFIX + sGroupName + sVarName;
	return (GetGlobalFloat(sThisVar));
}

void SetGroupFloat(string sGroupName, string sVarName, float fValue)
{
	string sThisVar = OBJ_GROUP_PREFIX + sGroupName + sVarName;
	SetGlobalFloat(sThisVar, fValue);
}

void DeleteGroupFloat(string sGroupName, string sVarName)
{
	string sThisVar = OBJ_GROUP_PREFIX + sGroupName + sVarName;
	SetGlobalFloat(sThisVar, 0.0f);
}

//---------------------------------------------------------------
// Group Strings

string GetGroupString(string sGroupName, string sVarName)
{
	string sThisVar = OBJ_GROUP_PREFIX + sGroupName + sVarName;
	return (GetGlobalString(sThisVar));
}

void SetGroupString(string sGroupName, string sVarName, string sValue)
{
	string sThisVar = OBJ_GROUP_PREFIX + sGroupName + sVarName;
	SetGlobalString(sThisVar, sValue);
}


//---------------------------------------------------------------
// Group Objects

object GetGroupObject(string sGroupName, string sVarName)
{
	string sThisVar = OBJ_GROUP_PREFIX + sGroupName + sVarName;
	return (GetGlobalObject(sThisVar));
}

void SetGroupObject(string sGroupName, string sVarName, object oValue)
{
	string sThisVar = OBJ_GROUP_PREFIX + sGroupName + sVarName;
	SetGlobalObject(sThisVar, oValue);
}


// returns current index
int GroupGetCurrentIndex(string sGroupName)
{
	return (GetGroupInt(sGroupName, OBJ_GROUP_INDEX));
}

void GroupSetCurrentIndex(string sGroupName, int iIndex)
{
	SetGroupInt(sGroupName, OBJ_GROUP_INDEX, iIndex);
}

// returns number of objects currently stored
int GroupGetNumObjects(string sGroupName)
{
	return (GetGroupInt(sGroupName, OBJ_GROUP_NUM));
}

void GroupSetNumObjects(string sGroupName, int iNumObjects)
{
	SetGroupInt(sGroupName, OBJ_GROUP_NUM, iNumObjects);
}


// return current object
object GroupGetCurrentObject(string sGroupName)
{
	return (GroupGetObjectIndex(sGroupName, GroupGetCurrentIndex(sGroupName)));
}

// increments index if possible
int GroupIncrementIndex(string sGroupName)
{
	int iCurrentIndex = GroupGetCurrentIndex(sGroupName);
	int iNumObjects = GroupGetNumObjects(sGroupName);

	if (iCurrentIndex >= iNumObjects)
	{
		return (0);
	}

	iCurrentIndex = iCurrentIndex + 1;
	GroupSetCurrentIndex(sGroupName, iCurrentIndex);

	PrintString("IncrementIndex: iCurrentIndex = " + IntToString (iCurrentIndex));
	return (iCurrentIndex);
}

// return first valid object in group starting w/ current.
// if no more in group, return OBJECT_INVALID
object GetFirstValidInGroupFromCurrent(string sGroupName)
{
	object oCurrent = GroupGetCurrentObject(sGroupName);
	// keep incrementing until we get valid object or reach end of list.
	while (!GetIsObjectValid(oCurrent))
	{
		if (!GroupIncrementIndex(sGroupName))
			return (OBJECT_INVALID);

		oCurrent = GroupGetCurrentObject(sGroupName);
	}
	return oCurrent;

}

// resets index and returns first object
object GetFirstInGroup(string sGroupName)
{
	GroupSetCurrentIndex(sGroupName, 1);
	return (GetFirstValidInGroupFromCurrent(sGroupName));
	//return GroupGetCurrentObject(sGroupName);
}

// increments index to next valid object and returns current object
object GetNextInGroup(string sGroupName)
{
	if (!GroupIncrementIndex(sGroupName))
		return (OBJECT_INVALID);

	return (GetFirstValidInGroupFromCurrent(sGroupName));

}

// bOverridePrevGroup - add someone already in another group?
int InsertIntoGroup(string sGroupName, object oObject, int bOverridePrevGroup = FALSE)
{
	if (!GetIsObjectValid(oObject)) {
		PrintString ("ginc_group: InsertIntoGroup - failed - invalid object!");
		return 0;
	}
	// if not ok to override, then check if already in group.
	if (!bOverridePrevGroup)
	{
		if (GetLocalString(oObject, OBJ_GROUP_MY_GROUP) != ""){
			PrintString ("ginc_group: InsertIntoGroup - failed - " + GetName(oObject) + " already in another group");
			return 0;
		}
	}
	// track num object?
	int iNumObjects = GroupGetNumObjects(sGroupName);
	iNumObjects = iNumObjects + 1;
	GroupSetNumObjects (sGroupName, iNumObjects);
	PrintString("InsertIntoGroup - iNumObjects: " + IntToString(iNumObjects));

	// assign object
	GroupSetObjectIndex(sGroupName, iNumObjects, oObject);

	// let object know what group he is in.
	SetLocalString(oObject, OBJ_GROUP_MY_GROUP, sGroupName);

	return (iNumObjects);
}


//-------------------------------------------------
// Functions that do things with Groups
//-------------------------------------------------

// Determine starting positions for "U6" formation columns: 2,3,4,5,6 indices
//  2 3
// 5 4 6
vector GetBMAFormationStartPosition(vector vPosition, int nIndex, float fSpacing, float fFacing)
{
	int nCase = nIndex % 5;	// determine starting position if index > 6

	if ((nIndex == 0) || (nIndex == 1))
	{
		nCase = 4;
	}

	vector vNewPosition = vPosition;
	switch (nCase)
	{
		case 0: // column 1 (left most)
			vNewPosition = GetChangedPosition(vPosition, fSpacing * 2, fFacing + 180.0);
			break;

		case 2: // column 2 (left)
			fSpacing = sqrt(pow(fSpacing, 2.0) * 2);
			vNewPosition = GetChangedPosition(vPosition, fSpacing, fFacing + 225.0);
			break;

		case 4: // column 3 (center)
			fSpacing = sqrt(pow(fSpacing, 2.0) * 2) * 2;
			vNewPosition = GetChangedPosition(vPosition, fSpacing, fFacing + 225.0);
			break;

		case 3: // column 4 (right)
			fSpacing = sqrt(pow(fSpacing, 2.0) * 2);
			vNewPosition = GetChangedPosition(vPosition, fSpacing, fFacing + 135.0);
			break;

		case 1: // column 5 (right most)
			fSpacing = sqrt(pow(fSpacing, 2.0) * 2) * 2;
			vNewPosition = GetChangedPosition(vPosition, fSpacing, fFacing + 135.0);
			break;
	}

	return vNewPosition;
}


// Determine location for "U6" formation:
//       1        fSpacing = distance between each row
//      2 3       first member of faction should jump to lToJumpTo
//     5 4 6      but does that
//      7 8  etc.
location GetBMALocation(location lToJumpTo, int nIndex, float fSpacing)
{
	PrintString("GetBMALocation(" + IntToString(nIndex));
	object oArea = GetAreaFromLocation(lToJumpTo);
	vector vPosition = GetPositionFromLocation(lToJumpTo);
	float fFacing = GetFacingFromLocation(lToJumpTo);

	int nOffset = (nIndex - 2) / 5; // round to floor, determines row offset for indices > 6

	if (nIndex >= 2)
	{
		vPosition = GetBMAFormationStartPosition(vPosition, nIndex, fSpacing, fFacing);

		// Pushes the location back per row (indicies 7,8,9, etc.)
		if (nOffset >= 0)
		{
			vPosition = GetChangedPosition(vPosition, IntToFloat(nOffset) * fSpacing * 2, fFacing + 180.0);
		}
	}

	location lNewLocation = Location(oArea, vPosition, fFacing);

	return lNewLocation;
}


location GetRectangleLocation(location lDestination, int nMemberIndex, int nColumns, float fSpacing)
{
	object oArea = GetAreaFromLocation(lDestination);
	vector vPosition = GetPositionFromLocation(lDestination);
	float fFacing = GetFacingFromLocation(lDestination);
	int nRow, nCol;
	nMemberIndex -= 1;	//Convert to 0-indexing for the math we're doing below

	nCol = (nMemberIndex % nColumns);

	//No divide by 0!
	if(nColumns == 0)
	{
		nColumns = 1;
		PrintString("Error: Invalid parameter value for nColumns in rectangle formation");
	}
	nRow = nMemberIndex / nColumns;

	if(nCol != 0)
	{
		vPosition = GetChangedPosition(vPosition, fSpacing * nCol, fFacing - 90.f);
	}
	if(nRow != 0)
	{
		vPosition = GetChangedPosition(vPosition, fSpacing * nRow, fFacing + 180.f);
	}

	location lNewLocation = Location(oArea, vPosition, fFacing);

	return lNewLocation;
}


location GetHuddleLocation(location lDestination, int iMemberIndex, int iNumObjects, float fRadius=10.0f, int iFaceType=FORMATION_HUDDLE_FACE_IN)
{
	//avoid divide-by-0 errors
	if(iNumObjects == 0)
		iNumObjects = 1;
	iMemberIndex -= 1;	//Convert to 0-indexing so first in group goes direction of waypoint.

	float fIncrement;

	if(iFaceType == FORMATION_SEMICIRCLE_FACE_OUT || iFaceType == FORMATION_SEMICIRCLE_FACE_IN)
	{
		if(iNumObjects == 1) iNumObjects == 2;	//hack fix for divide-by-0
		fIncrement = 180.f / IntToFloat(iNumObjects - 1);
	}
	else
	{
		fIncrement = 360.f / IntToFloat(iNumObjects);
	}

	float fAngle = fIncrement * iMemberIndex;

	//for a semicircle, it matters at what angle the semicircle begins.  We will use the
	//base location's facing value (usually a waypoint), and start the semicircle 90 degrees
	//prior, so the midpoint on the semicircle arc is in the direction the waypoint points.
	if(iFaceType == FORMATION_SEMICIRCLE_FACE_OUT || iFaceType == FORMATION_SEMICIRCLE_FACE_IN)
	{
		fAngle += GetFacingFromLocation(lDestination) - 90.f;

	}

	// location lRet = GetHuddleLocation(lDestination, fAngle, fRadius);
	object oArea = GetAreaFromLocation(lDestination);
    float fFacing;
    vector vPos = fRadius * AngleToVector(fAngle); // create vector starting on origin
	switch (iFaceType)
	{
		case FORMATION_HUDDLE_FACE_IN:
		case FORMATION_SEMICIRCLE_FACE_IN:
    		fFacing = VectorToAngle(-1.0 * vPos);
			break;

		case FORMATION_HUDDLE_FACE_OUT:
		case FORMATION_SEMICIRCLE_FACE_OUT:
    		fFacing = VectorToAngle(vPos);
			break;

		case FORMATION_HUDDLE_FACE_FORWARD:
    		fFacing = GetFacingFromLocation(lDestination);
			break;

		default:
    		fFacing = VectorToAngle(-1.0 * vPos);
			break;
	}

    vector vCenter = GetPositionFromLocation(lDestination);
    vPos = vPos + vCenter;	// move vector to offset

    return Location(oArea, vPos, fFacing);
}

// Get new line location from center of row
// 6 4 2 0 1 3 5
location GetLineLocation(location lDestination, int iMemberIndex, float fSpacing)
{
	object oNewArea = GetAreaFromLocation(lDestination);
	vector vNewPosition = GetPositionFromLocation(lDestination);
	float fNewFacing = GetFacingFromLocation(lDestination);

	// if leader then use target destination
	if (iMemberIndex <= 0)
		return lDestination;

	int bOddIndex = (iMemberIndex % 2);

	if (bOddIndex == TRUE)
	{
		// if odd add right
		vNewPosition = GetChangedPosition(vNewPosition, ((iMemberIndex + 1) / 2) * fSpacing, fNewFacing - 90.0f);
	}
	else
	{
		// if even add left
		vNewPosition = GetChangedPosition(vNewPosition, ((iMemberIndex + 1) / 2) * fSpacing, fNewFacing + 90.0f);
	}

	return Location(oNewArea, vNewPosition, fNewFacing);
}


//-------------------------------------------------
// Group Base Functions
//-------------------------------------------------


// removes everything from the group, resets all the group's vars to init values of 0,
// and removes local string indicating group from all objects in group
void ResetGroup(string sGroupName)
{
	int i;
	int iNumObjects = GroupGetNumObjects(sGroupName);
	string sThisObj;
	object oObject;

	// set objects to invalid
	for (i=1; i <= iNumObjects; i++)
	{
		oObject = GroupGetObjectIndex(sGroupName, i);
		if ( GetIsObjectValid(oObject) )
		{
			if ( GetGroupName(oObject) == sGroupName )
			{
				DeleteLocalString( oObject, OBJ_GROUP_MY_GROUP );
			}
		}
		GroupDeleteObjectIndex(sGroupName, i);
	}
	GroupSetNumObjects(sGroupName, 0);
	GroupSetCurrentIndex(sGroupName, 0);

	// clear out noise
	DeleteGroupFloat(sGroupName, OBJ_GROUP_NOISE_START);
	DeleteGroupFloat(sGroupName, OBJ_GROUP_NOISE_FACING);
	DeleteGroupFloat(sGroupName, OBJ_GROUP_NOISE_LOCATION);

	// clear out formation info
	DeleteGroupFloat(sGroupName, OBJ_GROUP_FORMATION_RADIUS);
	DeleteGroupFloat(sGroupName, OBJ_GROUP_FORMATION_SPACING);
	DeleteGroupInt(sGroupName, OBJ_GROUP_FORMATION_TYPE);
	DeleteGroupInt(sGroupName, OBJ_GROUP_FORMATION_COLS);
}

int IsGroupEmpty(string sGroupName)
{
	int iRet = FALSE;
	if (GroupGetNumObjects(sGroupName) == 0)
		iRet = TRUE;
	return (iRet);
}

//---------------------------------------------------------------
// Group creation
//---------------------------------------------------------------

// Make party a group using all standard stuff
// This will put all party members in party group even if they are currently in another group.
string GetPartyGroup(object oPC)
{
	string sGroupName = PARTY_GROUP_NAME;
	ResetGroup(sGroupName);
	//FactionToGroup(oPC, sGroupName, GROUP_LEADER_FIRST, TRUE);
	GroupAddFaction(sGroupName, oPC, GROUP_LEADER_FIRST, TRUE);
	GroupSetBMAFormation(sGroupName);
	return (sGroupName);
}

// Add creature to group sGroupName
void GroupAddMember(string sGroupName, object oMember, int bOverridePrevGroup=FALSE)
{
	InsertIntoGroup(sGroupName, oMember, bOverridePrevGroup);
}

// Add creatures with factions matching oFactionMember to group sGroupName
void GroupAddFaction(string sGroupName, object oFactionMember, int nLeaderPos=GROUP_LEADER_FIRST, int bOverridePrevGroup=FALSE)
{
	object oLeader = GetFactionLeader(oFactionMember);
	if (!GetIsObjectValid(oLeader))
	{
		oLeader = oFactionMember;
	}

	object oMember = GetFirstFactionMember(oFactionMember, FALSE);

	if (nLeaderPos == GROUP_LEADER_FIRST)	// add Leader first
	{
		InsertIntoGroup(sGroupName, oLeader, bOverridePrevGroup);
	}

	while (GetIsObjectValid(oMember))
	{
		if (oMember != oLeader)				// skip Leader
		{
			InsertIntoGroup(sGroupName, oMember, bOverridePrevGroup);
		}
		oMember = GetNextFactionMember(oFactionMember, FALSE);
	}

	if (nLeaderPos == GROUP_LEADER_LAST)	// add Leader last
	{
		InsertIntoGroup(sGroupName, oLeader, bOverridePrevGroup);
	}
}

// Add up to iMax creatures with tag sTag to group sGroupName
void GroupAddTag(string sGroupName, string sTag, int iMax=20, int bOverridePrevGroup=FALSE)
{
	int iCount = 0;
	object oMember = GetObjectByTag(sTag, iCount);
	while (GetIsObjectValid(oMember) && (iCount < iMax))
	{
		InsertIntoGroup(sGroupName, oMember, bOverridePrevGroup);
		iCount++;
		oMember = GetObjectByTag(sTag, iCount);
	}
}

// Add up to iMax creatures with tag sTag to group sGroupName
void GroupAddNearestTag(string sGroupName, string sTag, object oTarget = OBJECT_SELF, int iMax=20, int bOverridePrevGroup=FALSE)
{
	int iCount = 0;

	//the + 1 is because GetNearestObjectByTag is 1-indexed, rather than 0-indexed like GetObjectByTag(). -EPF
	object oMember = GetNearestObjectByTag(sTag, oTarget, iCount + 1);
	while (GetIsObjectValid(oMember) && (iCount < iMax))
	{
		InsertIntoGroup(sGroupName, oMember, bOverridePrevGroup);
		iCount++;
		oMember = GetNearestObjectByTag(sTag, oTarget, iCount + 1);
	}
}


// Add encounter spawned creatures to group sGroupName
// bWander 0 - no wander
//			1 - wander
//			2 - don't set (ude default - currently wander)
void GroupAddEncounter(string sGroupName, int bWander=2, int bOverridePrevGroup=FALSE)
{
	//SpawnScriptDebugger();
	//PrettyDebug("Examining all the creatures in the area");
	object oMember = GetFirstObjectInArea();
	//int iIsEncounter;
	//int iIsValid = GetIsObjectValid(oMember);
	//PrettyDebug("First Obj oin area : " + GetTag(oMember) + " and valid: " + IntToString(iIsValid));
	while (GetIsObjectValid(oMember))
	{
		if (GetObjectType(oMember) == OBJECT_TYPE_CREATURE)
		{
			//iIsEncounter = GetIsEncounterCreature(oMember);
			//PrettyDebug(GetName(oMember) + " encounter status is : " + IntToString(iIsEncounter));
			if (GetIsEncounterCreature(oMember))
			{
				InsertIntoGroup(sGroupName, oMember, bOverridePrevGroup);	// adds
			}
		}
		oMember = GetNextObjectInArea();
	}
	if (bWander != 2)
	{
		GroupSetSpawnInCondition(sGroupName, NW_FLAG_AMBIENT_ANIMATIONS, bWander);
	}
}

// Note this will only properly place creatures in formation if the group was previously empty.
void GroupSpawnAtWaypoint(string sGroupName, string sTemplate, string sWaypoint, int nNum)
{
	object oPC = GetObjectByTag(sWaypoint);
	location lLoc = GetLocation(oPC);
	GroupSpawnAtLocation(sGroupName, sTemplate, lLoc, nNum);
}

// Spawn in iNum sTemplate's into a group using formation & noise at lLocation
// Note this will only properly place creatures in formation if the group was previously empty.
void GroupSpawnAtLocation(string sGroupName, string sTemplate, location lLocation, int nNum)
{
	object oMember;
	location lDestination;
	int nCount;

	float fFacingNoise = GetGroupFloat(sGroupName, OBJ_GROUP_NOISE_FACING);
	float fLocationNoise = GetGroupFloat(sGroupName, OBJ_GROUP_NOISE_LOCATION);

	int nFormation = GetGroupInt(sGroupName, OBJ_GROUP_FORMATION_TYPE);
	int nFormCols = GetGroupInt(sGroupName, OBJ_GROUP_FORMATION_COLS);
	float fFormSpacing = GetGroupFloat(sGroupName, OBJ_GROUP_FORMATION_SPACING);

	for (nCount = 1; nCount <= nNum; nCount++)
	{
		switch (nFormation)
		{
			case FORMATION_NONE:
				lDestination = lLocation;
				break;
			case FORMATION_HUDDLE_FACE_IN:
			case FORMATION_HUDDLE_FACE_OUT:
			case FORMATION_HUDDLE_FACE_FORWARD:
				lDestination = GetHuddleLocation(lLocation, nCount, nNum, fFormSpacing, nFormation);
				break;
			case FORMATION_RECTANGLE:
				lDestination = GetRectangleLocation(lLocation, nCount, nFormCols, fFormSpacing);
				break;
			case FORMATION_BMA:
				lDestination = GetBMALocation(lLocation, nCount, fFormSpacing);
				break;
			case FORMATION_LINE:
				// 0-based index
				lDestination = GetLineLocation(lLocation, nCount - 1, fFormSpacing);
				break;
			case FORMATION_SEMICIRCLE_FACE_IN:
			case FORMATION_SEMICIRCLE_FACE_OUT:
				lDestination = GetHuddleLocation(lLocation, nCount, nNum, fFormSpacing, nFormation);
				break;
			default:
				lDestination = lLocation;
				break;
		}
		lDestination = GetNearbyLocation(lDestination, fLocationNoise, fFacingNoise);
		oMember = UT_CreateObjectAtLocation(sTemplate, lDestination, "", FALSE);
		GroupAddMember(sGroupName, oMember);
	}
}

// *** old versions
// add a new a creature to a group (fails if object is already in another group)
int AddToGroup(string sGroupName, object oObject)
{
	//OldFunctionMessage("AddToGroup", "GroupAddMember");
	return (InsertIntoGroup(sGroupName, oObject, FALSE));
}

// adds all members of a faction to the specified Group
void FactionToGroup(object oFactionMember, string sGroupName, int iLeaderPos=GROUP_LEADER_FIRST, int bOverridePrevGroup = FALSE)
{
	OldFunctionMessage("FactionToGroup", "GroupAddFaction");
	GroupAddFaction(sGroupName, oFactionMember, iLeaderPos, bOverridePrevGroup);
}

// add all encounter creatures in area to specified group
// bWander 0 - no wander
//			1 - wander
//			2 - don't set (ude default - currently wander)
void EncounterToGroup(string sGroupName, int bWander=2)
{
	OldFunctionMessage("EncounterToGroup", "GroupAddEncounter");
	GroupAddEncounter(sGroupName, bWander);
}

// spawn creatures in - in BMA formation - and add them to a group
// if there are creatures already in the group, the new ones will be tacked on to the end and placed
// in formation accordingly.
void SpawnCreaturesInGroupAtWP(int iNum, string sTemplate, string sGroupName, string sWayPoint="SPAWN_POINT")
{
	int i;
	object oCreature;
	location lThisDest;
	location lDestination = GetWPLocation(sWayPoint);
	int iIndex;

	for (i=1; i<=iNum; i++)
	{
		iIndex = GroupGetNumObjects(sGroupName)+1; // GroupGetCurrentIndex(sGroupName) + 1;
		lThisDest = GetBMALocation(lDestination, iIndex, DEFAULT_SPACING);
		oCreature = CreateObject(OBJECT_TYPE_CREATURE, sTemplate, lThisDest); //, bUseAppearAnimation, sNewTag);
		//AddToGroup(sGroupName, oCreature);
		InsertIntoGroup(sGroupName, oCreature, FALSE);
	}

	return;
}

// adds all in the area w/ tag to a group up to specified max.
void AddNearestWithTagToGroup(string sGroupName, string sTag, int iMax=20)
{
	OldFunctionMessage("AddNearestWithTagToGroup", "GroupAddNearestTag");
	GroupAddNearestTag(sGroupName, sTag, OBJECT_SELF, iMax);
}


//--------------------------------------------------
// Formations
//--------------------------------------------------

// Use single base destination for group, does NOT ignore noise
void GroupSetNoFormation(string sGroupName)
{
	SetGroupInt(sGroupName, OBJ_GROUP_FORMATION_TYPE, FORMATION_NONE);
}

// Creates a standard party group formations:
//       1        fSpacing = distance between each row
//      2 3
//     5 4 6
//      7 8  etc.
void GroupSetBMAFormation(string sGroupName, float fSpacing=1.8f)
{
	SetGroupInt(sGroupName, OBJ_GROUP_FORMATION_TYPE, FORMATION_BMA);
	SetGroupFloat(sGroupName, OBJ_GROUP_FORMATION_SPACING, fSpacing); // to be implemented
}

// creates a circle, fRadius out from the waypoint.  First in group will go in direction of waypoints arrow.
// int iFormation 	- Formation to use
// float fRadius	- radius for huddles
void GroupSetCircleFormation(string sGroupName, int iFacing=FORMATION_HUDDLE_FACE_IN , float fRadius=5.0f)
{
	SetGroupInt(sGroupName, OBJ_GROUP_FORMATION_TYPE, iFacing);
	SetGroupFloat(sGroupName, OBJ_GROUP_FORMATION_SPACING, fRadius);
}

// Just like GroupSetCircleFormation, but we only cover the first half of the circle.
void GroupSetSemicircleFormation(string sGroupName, int nFacing = FORMATION_SEMICIRCLE_FACE_OUT, float fRadius = 5.f)
{
	SetGroupInt(sGroupName, OBJ_GROUP_FORMATION_TYPE, nFacing);
	SetGroupFloat(sGroupName, OBJ_GROUP_FORMATION_SPACING, fRadius);
}

// Create standard single row formation, leader in middle
// 6 4 2 0 1 3 5
void GroupSetLineFormation(string sGroupName, float fSpacing=DEFAULT_SPACING)
{
	SetGroupInt(sGroupName, OBJ_GROUP_FORMATION_TYPE, FORMATION_LINE);
	SetGroupFloat(sGroupName, OBJ_GROUP_FORMATION_SPACING, fSpacing);
}


// creates a rectangle with creatures facing direction of waypoint.  Waypoint indicates top left most
// corner of the rectangle.
// float fSpacing - spacing in units between creatures.  There are 10 units in a single tile square
// int nColumns - number of columns to form.
void GroupSetRectangleFormation(string sGroupName, float fSpacing=1.8f, int nColumns=2)
{
	SetGroupInt(sGroupName, OBJ_GROUP_FORMATION_TYPE, FORMATION_RECTANGLE);
	SetGroupFloat(sGroupName, OBJ_GROUP_FORMATION_SPACING, fSpacing);
	SetGroupInt(sGroupName, OBJ_GROUP_FORMATION_COLS, nColumns);
}

// Sets the noise to be used with formations to make them less synchronized.
// fStartNoise		- delay in start time for creatures to move
// fFacingNoise		- max degrees to turn from facing
// fLocationNoise	- max x and y units to deviate from location
void GroupSetNoise(string sGroupName, float fStartNoise=1.0f, float fFacingNoise=10.0f, float fLocationNoise=1.0f)
{
	SetGroupFloat(sGroupName, OBJ_GROUP_NOISE_START, fStartNoise);
	SetGroupFloat(sGroupName, OBJ_GROUP_NOISE_FACING, fFacingNoise);
	SetGroupFloat(sGroupName, OBJ_GROUP_NOISE_LOCATION, fLocationNoise);
}

//------------------------
// Group On Death
//------------------------

// When group dies, start a conversation.  Works with gg_death_talk
// Do not add to a group after calling this (as the object's death script will not get assigned).
// Only 1 of the GroupOnDeath functions can be applied per group - a previous GroupOnDeath function will be "overwritten" when a new one is applied.
void GroupOnDeathBeginConversation(string sGroupName, string sTalkerTag, string sConversation)
{
	// set groups death script
	GroupSetLocalString (sGroupName, "DeathScript", "gg_death_talk");

	// set vars for later use
	SetGroupString(sGroupName, "TalkerTag", sTalkerTag);
	SetGroupString(sGroupName, "Conversation", sConversation);

	// reset num killed (in case group name was used before)
	SetGroupInt(sGroupName, "NumKilled", 0);
}


// When group dies, set a Local Int on the specified target.  Works with gg_death_l_var
// Do not add to a group after calling this (as the object's death script will not get assigned).
// Only 1 of the GroupOnDeath functions can be applied per group - a previous GroupOnDeath function will be "overwritten" when a new one is applied.
void GroupOnDeathSetLocalInt( string sGroupName, object oTargetObject, string sVariableName, int nNewValue )
{
	// set groups death script
	GroupSetLocalString ( sGroupName, "DeathScript", "gg_death_l_var" );

	// set vars for later use
	SetGroupObject( sGroupName, "TargetObject", oTargetObject );
	SetGroupString( sGroupName, "VarName", sVariableName );
	SetGroupInt( sGroupName, "VarValue", nNewValue );
	SetGroupInt( sGroupName, "VarType", TYPE_INT );

	// reset num killed (in case group name was used before)
	SetGroupInt( sGroupName, "NumKilled", 0 );
}

// When group dies, set a Local Float on the specified target.  Works with gg_death_l_var
// do not add to a group after calling this (as the object's death script will not get assigned).
// Only 1 of the GroupOnDeath functions can be applied per group - a previous GroupOnDeath function will be "overwritten" when a new one is applied.
void GroupOnDeathSetLocalFloat( string sGroupName, object oTargetObject, string sVariableName, float fNewValue )
{
	// set groups death script
	GroupSetLocalString (sGroupName, "DeathScript", "gg_death_l_var" );

	// set vars for later use
	SetGroupObject( sGroupName, "TargetObject", oTargetObject );
	SetGroupString( sGroupName, "VarName", sVariableName );
	SetGroupFloat( sGroupName, "VarValue", fNewValue );
	SetGroupInt( sGroupName, "VarType", TYPE_FLOAT );

	// reset num killed (in case group name was used before)
	SetGroupInt(sGroupName, "NumKilled", 0);
}

// When group dies, set a Local String on the specified target.  Works with gg_death_l_var
// do not add to a group after calling this (as the object's death script will not get assigned).
// Only 1 of the GroupOnDeath functions can be applied per group - a previous GroupOnDeath function will be "overwritten" when a new one is applied.
void GroupOnDeathSetLocalString( string sGroupName, object oTargetObject, string sVariableName, string sNewValue )
{
	// set groups death script
	GroupSetLocalString (sGroupName, "DeathScript", "gg_death_l_var" );

	// set vars for later use
	SetGroupObject( sGroupName, "TargetObject", oTargetObject );
	SetGroupString( sGroupName, "VarName", sVariableName );
	SetGroupString( sGroupName, "VarValue", sNewValue );
	SetGroupInt( sGroupName, "VarType", TYPE_STRING );

	// reset num killed (in case group name was used before)
	SetGroupInt(sGroupName, "NumKilled", 0);
}

// When group dies, Add a Journal Quest Entry.  Works with gg_death_journal
// Do not add to a group after calling this (as the object's death script will not get assigned).
// Only 1 of the GroupOnDeath functions can be applied per group - a previous GroupOnDeath function will be "overwritten" when a new one is applied.
void GroupOnDeathSetJournalEntry(string sGroup, string sQuestTag, int nEntry, int bAllowOverride = FALSE)
{
	GroupSetLocalString(sGroup, "DeathScript", "gg_death_journal");
	SetGroupString(sGroup, "sQuestTag", sQuestTag);
	SetGroupInt(sGroup, "nEntry", nEntry);
	SetGroupInt(sGroup, "bOverride", bAllowOverride);
}

// When group dies, execute a custom script.  Works with gg_death_custom_script
// Do not add to a group after calling this (as the object's death script will not get assigned).
// Only 1 of the GroupOnDeath functions can be applied per group - a previous GroupOnDeath function will be "overwritten" when a new one is applied.
void GroupOnDeathExecuteCustomScript(string sGroupName, string sScriptName)
{
	// set groups death script
	GroupSetLocalString ( sGroupName, "DeathScript", "gg_death_custom_script" );

	// set vars for later use
	SetGroupString( sGroupName, "CustomScript", sScriptName );

	// reset num killed (in case group name was used before)
	SetGroupInt( sGroupName, "NumKilled", 0 );
}


//----------------------------------------------------
// Group Commands

//
void GroupForceMoveToLocation(string sGroupName, location lDestination, int bRun=FALSE, float fTimeout=30.0f)
{
	int nNumMembers = GroupGetNumObjects(sGroupName);

	object oMember = GetFirstInGroup(sGroupName);
	location lNewDest;

	float fFacingNoise = GetGroupFloat(sGroupName, OBJ_GROUP_NOISE_FACING);
	float fLocationNoise = GetGroupFloat(sGroupName, OBJ_GROUP_NOISE_LOCATION);

	int nFormation = GetGroupInt(sGroupName, OBJ_GROUP_FORMATION_TYPE);
	int nFormCols = GetGroupInt(sGroupName, OBJ_GROUP_FORMATION_COLS);
	float fFormSpacing = GetGroupFloat(sGroupName, OBJ_GROUP_FORMATION_SPACING);

	int nCount;
	for (nCount = 1; nCount <= nNumMembers; nCount++)
	{
		switch (nFormation)
		{
			case FORMATION_NONE:
				lNewDest = lDestination;
				break;
			case FORMATION_HUDDLE_FACE_IN:
			case FORMATION_HUDDLE_FACE_OUT:
			case FORMATION_HUDDLE_FACE_FORWARD:
				lDestination = GetHuddleLocation(lDestination, nCount, nNumMembers, fFormSpacing, nFormation);
				break;
			case FORMATION_RECTANGLE:
				lNewDest = GetRectangleLocation(lDestination, nCount, nFormCols, fFormSpacing);
				break;
			case FORMATION_BMA:
				lNewDest = GetBMALocation(lDestination, nCount, fFormSpacing);
				break;
			case FORMATION_LINE:
				// 0-based index
				lNewDest = GetLineLocation(lDestination, nCount - 1, fFormSpacing);
				break;
			case FORMATION_SEMICIRCLE_FACE_IN:
			case FORMATION_SEMICIRCLE_FACE_OUT:
				lDestination = GetHuddleLocation(lDestination, nCount, nNumMembers, fFormSpacing, nFormation);
				break;

			default:
				lNewDest = lDestination;
				break;
		}
		lNewDest = GetNearbyLocation(lNewDest, fLocationNoise, fFacingNoise);
		PrettyMessage("ginc_group: force moving " + GetName(oMember));
		AssignCommand(oMember, ActionForceMoveToLocation(lNewDest, bRun, fTimeout));
		oMember = GetNextInGroup(sGroupName);
	}
}

// locomote a group to a specified waypoint (formation and noise should be set first)
// string sGroupName - name of group to move (created using AddToGroup())
// string sWayPoint - Tag of the Base waypoint for the formation
// int iMoveType	- specifies type of locomotion - MOVE_WALK, MOVE_JUMP, etc.
void GroupMoveToWP(string sGroupName, string sWayPoint, int iMoveType=MOVE_WALK)
{
	location lDestination = GetWPLocation(sWayPoint);
	GroupMoveToFormationLocation(sGroupName, lDestination, iMoveType);
}

void GroupMoveToObject(string sGroupName, object oTarget, int iMoveType=MOVE_WALK)
{
	location lDestination = GetLocation(oTarget);
	GroupMoveToFormationLocation(sGroupName, lDestination, iMoveType);
}

void GroupFleeToExit(string sGroupName, string sWaypoint, int iMoveType=MOVE_WALK)
{
	GroupMoveToWP(sGroupName, sWaypoint, iMoveType);

	object oMember = GetFirstInGroup(sGroupName);
	while (GetIsObjectValid(oMember) == TRUE)
	{
		AssignCommand(oMember, ActionDoCommand(DestroyObject(oMember)));
		oMember = GetNextInGroup(sGroupName);
	}
}

// wrapper for MOVE_JUMP_INSTANT - clear actions and jump to location
void GroupJumpToWP(string sGroupName, string sWaypoint)
{
	GroupMoveToWP(sGroupName, sWaypoint, MOVE_JUMP_INSTANT);
	//location lDestination = GetWPLocation(sWaypoint);
	//GroupMoveToFormationLocation(sGroupName, lDestination, MOVE_JUMP_INSTANT);
}


// move to the specified destination in the specified way.
void DoMoveType(object oMember, location lThisDest, int iMoveType=MOVE_WALK, float fStartNoise=0.0f, float fForceMoveTimeout=30.0f)
{
	switch (iMoveType)
	{
		case MOVE_WALK:
			AssignCommand(oMember, ActionWait(RandomFloat(fStartNoise)));
			AssignCommand(oMember, ActionMoveToLocation(lThisDest));
			break;

		case MOVE_RUN:
			AssignCommand(oMember, ActionWait(RandomFloat(fStartNoise)));
			AssignCommand(oMember, ActionMoveToLocation(lThisDest, TRUE));
			break;

		case MOVE_JUMP:
			AssignCommand(oMember, ActionJumpToLocation(lThisDest));
			break;

		case MOVE_JUMP_INSTANT:
			AssignCommand(oMember, ClearAllActions());
			AssignCommand(oMember, JumpToLocation(lThisDest));
			break;

		case MOVE_FORCE_WALK:
			AssignCommand(oMember, ActionWait(RandomFloat(fStartNoise)));
			AssignCommand(oMember, ActionForceMoveToLocation(lThisDest, FALSE, fForceMoveTimeout));

		case MOVE_FORCE_RUN:
			AssignCommand(oMember, ActionWait(RandomFloat(fStartNoise)));
			AssignCommand(oMember, ActionForceMoveToLocation(lThisDest, TRUE, fForceMoveTimeout));

		default:
			PrintString("ginc_group: invalid iMoveType case");
			AssignCommand(oMember, ActionMoveToLocation(lThisDest));
			break;
	}
}

// locomote a group to a specified location (formation and noise should be set first)
// string sGroupName - name of group to move (created using AddToGroup())
// location lDestination - Base location for the formation
// int iMoveType	- specifies type of locomotion - MOVE_WALK, MOVE_JUMP, etc.
void GroupMoveToFormationLocation(string sGroupName, location lDestination, int iMoveType=MOVE_WALK)
{
	object oMember = GetFirstInGroup(sGroupName);
	location lThisDest;
	float fFacing;
	int iMemberIndex;

	// get stored noise
	float fStartNoise = GetGroupFloat(sGroupName, OBJ_GROUP_NOISE_START);
	float fFacingNoise = GetGroupFloat(sGroupName, OBJ_GROUP_NOISE_FACING);
	float fLocationNoise = GetGroupFloat(sGroupName, OBJ_GROUP_NOISE_LOCATION);

	// get formation vars
	int iFormation 	= GetGroupInt(sGroupName, OBJ_GROUP_FORMATION_TYPE);
	int iNumObjects = GroupGetNumObjects(sGroupName);
	int iCols		= GetGroupInt(sGroupName, OBJ_GROUP_FORMATION_COLS);
	float fSpacing 	= GetGroupFloat(sGroupName, OBJ_GROUP_FORMATION_SPACING);

	while (GetIsObjectValid(oMember))
	{
		iMemberIndex = GroupGetCurrentIndex(sGroupName);
		//lThisDest = GetFormationLocationByIndex(lDestination, sGroupName, iFormation, fRadius);
		//lThisDest = GetFormationLocationByIndex(lDestination, sGroupName);
		switch (iFormation)
		{
			case FORMATION_NONE:
				lThisDest = lDestination;
				break;
			case FORMATION_HUDDLE_FACE_IN: // do a huddle
			case FORMATION_HUDDLE_FACE_OUT: // do a backward huddle
			case FORMATION_HUDDLE_FACE_FORWARD: // forward moving circle
				lThisDest = GetHuddleLocation(lDestination, iMemberIndex, iNumObjects, fSpacing, iFormation);
				break;
			case FORMATION_RECTANGLE:
				lThisDest = GetRectangleLocation(lDestination, iMemberIndex, iCols, fSpacing);
				break;
			case FORMATION_BMA:
				lThisDest = GetBMALocation(lDestination, iMemberIndex, fSpacing);
				break;
			case FORMATION_LINE:
				// 0-based index what val does iMemberIndex start at?
				lThisDest = GetLineLocation(lDestination, iMemberIndex - 1, fSpacing);
				break;
			case FORMATION_SEMICIRCLE_FACE_IN:
			case FORMATION_SEMICIRCLE_FACE_OUT:
				lThisDest = GetHuddleLocation(lDestination, iMemberIndex, iNumObjects, fSpacing, iFormation);
				break;
			default:
				lThisDest = GetBMALocation(lDestination, iMemberIndex, DEFAULT_SPACING);
				break;
		}
		PrintString("ginc_group: GroupMoveToWP() object " + GetName(oMember) + " type " + IntToString(iMoveType));
		lThisDest = GetNearbyLocation(lThisDest, fLocationNoise);
		DoMoveType(oMember, lThisDest, iMoveType, fStartNoise);

		/*
		switch (iMoveType)
		{
			case MOVE_WALK:
				AssignCommand(oMember, ActionWait(RandomFloat(fStartNoise)));
				AssignCommand(oMember, ActionMoveToLocation(lThisDest));
				break;

			case MOVE_RUN:
				AssignCommand(oMember, ActionWait(RandomFloat(fStartNoise)));
				AssignCommand(oMember, ActionMoveToLocation(lThisDest, TRUE));
				break;

			case MOVE_JUMP:
				AssignCommand(oMember, ActionJumpToLocation(lThisDest));
				break;

			case MOVE_JUMP_INSTANT:
				AssignCommand(oMember, ClearAllActions());
				AssignCommand(oMember, JumpToLocation(lThisDest));
				break;

			case MOVE_FORCE_WALK:
				AssignCommand(oMember, ActionWait(RandomFloat(fStartNoise)));
				AssignCommand(oMember, ActionForceMoveToLocation(lThisDest));

			case MOVE_FORCE_RUN:
				AssignCommand(oMember, ActionWait(RandomFloat(fStartNoise)));
				AssignCommand(oMember, ActionForceMoveToLocation(lThisDest, TRUE));

			default:
				PrintString("ginc_group: invalid iMoveType case");
				AssignCommand(oMember, ActionMoveToLocation(lThisDest));
				break;
		}
		*/
		// face the same way as the location destination + some noise
		fFacing = GetNormalizedDirection(GetFacingFromLocation(lThisDest) + RandomDelta(fFacingNoise));
		AssignCommand(oMember, ActionDoCommand(SetFacing(fFacing)));
		AssignCommand(oMember, ActionWait(0.5f)); // wait for facing
		oMember = GetNextInGroup(sGroupName);
	}
}

// have group attak target
// string sGroupName - name of group
// object oTarget - target to attack
void GroupAttack(string sGroupName, object oTarget, int bSetToHostile=TRUE)
{
	object oMember = GetFirstInGroup(sGroupName);

	while (GetIsObjectValid(oMember))
	{
		StandardAttack(oMember, oTarget, bSetToHostile);
		oMember = GetNextInGroup(sGroupName);
	}
}

// all in group clear their actions
// string sGroupName - name of group
// int nClearCombatState
void GroupClearAllActions(string sGroupName, int nClearCombatState = FALSE)
{
	object oMember = GetFirstInGroup(sGroupName);

	while (GetIsObjectValid(oMember))
	{
		AssignCommand(oMember, ClearAllActions(nClearCombatState));
		//PrintString (GetName(oMember) + " - Actions Cleared");
		oMember = GetNextInGroup(sGroupName);
	}
}


// makes a group play an animation
void GroupPlayAnimation(string sGroupName, int nAnimation, float fStartNoise=1.0f, float fSpeedBase=1.0f, float fSpeedRange=1.0f, float fDurationSectondsBase=0.0f, float fDurationSectondsRange=0.0f)
{
	object oMember = GetFirstInGroup(sGroupName);
	float fSpeed;
	float fDurationSectonds;

	while (GetIsObjectValid(oMember))
	{
		if (fStartNoise > EPSILON)
			AssignCommand(oMember, ActionWait(RandomFloat(fStartNoise)));

		fSpeed = fSpeedBase;
		if (fSpeedRange > EPSILON)
			fSpeed = fSpeed + RandomFloat(fStartNoise);

		fDurationSectonds = fDurationSectondsBase;
		if (fDurationSectondsRange > EPSILON)
			fDurationSectonds = fDurationSectonds + RandomFloat(fDurationSectondsRange);

		AssignCommand(oMember, ActionPlayAnimation(nAnimation, fSpeed, fDurationSectonds));

		oMember = GetNextInGroup(sGroupName);
	}
}

// all in group wait
void GroupActionWait(string sGroupName, float fSeconds=0.0f)
{
	object oMember = GetFirstInGroup(sGroupName);

	while (GetIsObjectValid(oMember))
	{
		AssignCommand(oMember, ActionWait(fSeconds));
		oMember = GetNextInGroup(sGroupName);
	}
}

// causes all in group to change facing
// uses start noise
void GroupActionOrientToTag(string sGroupName, string sTag, int iOrientation=ORIENT_FACE_TARGET, int bIgnoreWait=FALSE)
{
	object oMember = GetFirstInGroup(sGroupName);
	float fStartNoise = GetGroupFloat(sGroupName, OBJ_GROUP_NOISE_START);

	while (GetIsObjectValid(oMember))
	{
		if (bIgnoreWait == FALSE) AssignCommand(oMember, ActionWait(RandomFloat(fStartNoise)));
		AssignCommand(oMember, ActionOrientToTag(sTag, iOrientation));
		oMember = GetNextInGroup(sGroupName);
	}
}

void GroupResurrect(string sGroupName, int bIgnoreWait=FALSE)
{
	object oMember = GetFirstInGroup(sGroupName);
	float fStartNoise = GetGroupFloat(sGroupName, OBJ_GROUP_NOISE_START);
	float fDelay = 0.0f;
	while (GetIsObjectValid(oMember) == TRUE)
	{
		if (bIgnoreWait == FALSE)
		{
			fDelay = RandomFloat(fStartNoise);
		}

		AssignCommand(oMember, DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectResurrection(), oMember)));
		oMember = GetNextInGroup(sGroupName);
	}
}

// sets a string on all in the group
void GroupSetLocalString (string sGroupName, string sVarName, string sValue)
{
	object oMember = GetFirstInGroup(sGroupName);

	while (GetIsObjectValid(oMember))
	{
		PrintString("ginc_group: GroupSetLocalString() group " + sGroupName + " object " + GetName(oMember) + " var " + sVarName + " = " + sValue);
		SetLocalString(oMember, sVarName, sValue);
		oMember = GetNextInGroup(sGroupName);
	}
}


// sets an object on all in the group
void GroupSetLocalObject (string sGroupName, string sVarName, object oValue)
{
	object oMember = GetFirstInGroup(sGroupName);

	while (GetIsObjectValid(oMember))
	{
		//PrintString("ginc_group: GroupSetLocalObject() group " + sGroupName + " object " + GetName(oMember) + " var " + sVarName + " = " + GetName(oValue));
		SetLocalObject(oMember, sVarName, oValue);
		oMember = GetNextInGroup(sGroupName);
	}
}

// sets an object on all in the group
void GroupSetLocalInt (string sGroupName, string sVarName, int iValue)
{
	object oMember = GetFirstInGroup(sGroupName);

	while (GetIsObjectValid(oMember))
	{
		//PrintString("ginc_group: GroupSetLocalObject() group " + sGroupName + " object " + GetName(oMember) + " var " + sVarName + " = " + GetName(oValue));
		SetLocalInt(oMember, sVarName, iValue);
		oMember = GetNextInGroup(sGroupName);
	}
}


// sets an object on all in the group
void GroupSetLocalFloat (string sGroupName, string sVarName, float fValue)
{
	object oMember = GetFirstInGroup(sGroupName);

	while (GetIsObjectValid(oMember))
	{
		//PrintString("ginc_group: GroupSetLocalFloat() group " + sGroupName + " object " + GetName(oMember) + " var " + sVarName + " = " + GetName(oValue));
		SetLocalFloat(oMember, sVarName, fValue);
		oMember = GetNextInGroup(sGroupName);
	}
}



// sets specified spawn in condition for all in group
void GroupSetSpawnInCondition(string sGroupName, int nCondition, int bValid = TRUE)
{
	object oMember = GetFirstInGroup(sGroupName);

	while (GetIsObjectValid(oMember))
	{
        AssignCommand(oMember, SetSpawnInCondition(nCondition, bValid)); // Aqvilinus fix - AssignCommand()
		oMember = GetNextInGroup(sGroupName);
	}
}

// Turns ambient animations flag on/off for all in group
void GroupWander(string sGroupName, int bValid = TRUE)
{
	object oMember = GetFirstInGroup(sGroupName);

	while (GetIsObjectValid(oMember))
	{
        AssignCommand(oMember, SetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS, bValid)); // Aqvilinus fix - AssignCommand()
		if (bValid)
			AssignCommand(oMember, PlayMobileAmbientAnimations());
		else
			AssignCommand(oMember, ClearAllActions());

		oMember = GetNextInGroup(sGroupName);
	}
}

// forces all in group to go to destination and then destroy self.
void GroupActionForceExit(string sGroupName, string sWPTag = "WP_EXIT", int bRun=FALSE)
{
	object oMember = GetFirstInGroup(sGroupName);

	while (GetIsObjectValid(oMember))
	{
		AssignCommand(oMember, ActionForceExit(sWPTag, bRun));
		oMember = GetNextInGroup(sGroupName);
	}
}



// Changes everyone in group to join faction of given creature
// Note on use: mod should contain an isolated area with a faction pig for
// each faction in use w/ tag same as faction name.
// (faction pigs have no scripts and thus can be placed peacefully together)
void GroupChangeFaction(string sGroupName, string sTargetFactionMember)
{
	object oTargetFactionMember = GetObjectByTag(sTargetFactionMember);
	object oMember = GetFirstInGroup(sGroupName);

	while (GetIsObjectValid(oMember))
	{
 		ChangeFaction(oMember, oTargetFactionMember);
		//PrintString ("Changed to same faction as " + GetName(oTarget));
		oMember = GetNextInGroup(sGroupName);
	}
}

// Changes everyone in group to join one of the standard factions
// STANDARD_FACTION_COMMONER;
// STANDARD_FACTION_DEFENDER;
// STANDARD_FACTION_HOSTILE;
// STANDARD_FACTION_MERCHANT;
void GroupChangeToStandardFaction(string sGroupName, int iFaction)
{
	object oMember = GetFirstInGroup(sGroupName);

	while (GetIsObjectValid(oMember))
	{
		ChangeToStandardFaction(oMember, iFaction);
		//PrintString ("Changed to standard faction");
		oMember = GetNextInGroup(sGroupName);
	}
}

// does action move to object for all in group
void GroupActionMoveToObject(string sGroupName, object oTarget, int bRun = FALSE, float fRange = 1.0f)
{
	object oMember = GetFirstInGroup(sGroupName);

	while (GetIsObjectValid(oMember))
	{
		AssignCommand(oMember, ActionMoveToObject( oTarget, bRun, fRange));
		oMember = GetNextInGroup(sGroupName);
	}
}


// have group attak targets in another group
// string sAttackerGroupName - name of attacking group
// string sAttackedGroupName - name of attacked group
void GroupAttackGroup(string sAttackerGroupName, string sAttackedGroupName, int bSetToHostile=TRUE)
{
	object oMember = GetFirstInGroup(sAttackerGroupName);
	object oTarget = GetFirstInGroup(sAttackedGroupName);

	while (GetIsObjectValid(oMember))
	{
		StandardAttack(oMember, oTarget, bSetToHostile);
		oMember = GetNextInGroup(sAttackerGroupName);
		oTarget = GetNextInGroup(sAttackedGroupName);
		if (oTarget == OBJECT_INVALID)
			oTarget = GetFirstInGroup(sAttackedGroupName);
	}
}


// assign SetFacingPoint() to each member in group, ignore noise
void GroupSetFacingPoint(string sGroupName, vector vPoint)
{
	object oMember = GetFirstInGroup(sGroupName);
	while (GetIsObjectValid(oMember) == TRUE)
	{
		AssignCommand(oMember, SetFacingPoint(vPoint));
		oMember = GetNextInGroup(sGroupName);
	}
}


// Destroys all objects in the group
void DestroyObjectsInGroup(string sGroupName, float fDelay = 0.0f)
{
	object oMember = GetFirstInGroup(sGroupName);

	while (GetIsObjectValid(oMember))
	{
		PrintString("ginc_group: DestroyObjectsInGroup() destroying " + GetName(oMember) + " of group " + sGroupName);
		DestroyObject(oMember, fDelay);
		oMember = GetNextInGroup(sGroupName);
	}
}

void GroupSetImmortal(string sGroupName, int bImmortal)
{
	object oMember = GetFirstInGroup(sGroupName);
	while (GetIsObjectValid(oMember) == TRUE)
	{
		SetImmortal(oMember, bImmortal);
		oMember = GetNextInGroup(sGroupName);
	}
}

void GroupSetPlotFlag(string sGroupName, int bPlotFlag)
{
	object oMember = GetFirstInGroup(sGroupName);
	while (GetIsObjectValid(oMember) == TRUE)
	{
		SetPlotFlag(oMember, bPlotFlag);
		oMember = GetNextInGroup(sGroupName);
	}
}

// use GroupClearAllActions() to cancel follow.
// this will cause group to follow leader around for a while - eventually an event will
// clear their actions and they will go do their own thing.
void GroupActionForceFollowObject(string sGroupName, object oMaster, float fFollowDistance = 5.0f)
{
	object oMember = GetFirstInGroup(sGroupName);
	while (GetIsObjectValid(oMember) == TRUE)
	{
		AssignCommand(oMember, ActionForceFollowObject(oMaster, fFollowDistance));
		PrintString(GetName(oMember) + " following " + GetName(oMaster));
		oMember = GetNextInGroup(sGroupName);
	}
}

// Cuases group to follow master
// the prospective followers must use heartbeat script "gb_follow_hb" for the effect to persist.
void GroupStartFollowLeader(string sGroupName, object oMaster, float fFollowDistance = 5.0f)
{
		GroupSetLocalObject (sGroupName, "Leader", oMaster);
		GroupSetLocalFloat (sGroupName, "FollowDistance", fFollowDistance);
		GroupActionForceFollowObject(sGroupName, oMaster, fFollowDistance);
}

// cuases group to stop following master
void GroupStopFollowLeader(string sGroupName)
{
		GroupSetLocalObject (sGroupName, "Leader", OBJECT_INVALID);
		GroupClearAllActions(sGroupName);
}


// figure out for selves what to do.
void GroupDetermineCombatRound(string sGroupName)
{
	object oMember = GetFirstInGroup(sGroupName);
	while (GetIsObjectValid(oMember) == TRUE)
	{
		//AssignCommand(oMember, DetermineCombatRound());
		//ExecuteScript(SCRIPT_DCR, oMember);
		AssignDCR(oMember);
		oMember = GetNextInGroup(sGroupName);
	}
}

// puts creatures in hostile faction and has them DetermineCombatRound()
void GroupGoHostile(string sGroupName)
{
	GroupChangeToStandardFaction(sGroupName, STANDARD_FACTION_HOSTILE);
	GroupDetermineCombatRound(sGroupName);
}

// note: testing on 9/14/05 indicates SurrenderToEnemies() is unreliable.
void GroupSurrenderToEnemies(string sGroupName)
{
	object oMember = GetFirstInGroup(sGroupName);
	while (GetIsObjectValid(oMember) == TRUE)
	{
		AssignCommand(oMember, SurrenderToEnemies());
		oMember = GetNextInGroup(sGroupName);
	}
}

void GroupActionMoveAwayFromObject(string sGroupName, object oFleeFrom, int bRun = FALSE, float fMoveAwayRange = 40.0f)
{
	object oMember = GetFirstInGroup(sGroupName);
	while (GetIsObjectValid(oMember) == TRUE)
	{
		AssignCommand(oMember, ActionMoveAwayFromObject(oFleeFrom, bRun, fMoveAwayRange));
		oMember = GetNextInGroup(sGroupName);
	}
}

// everyone in group casts same fake spell
void GroupActionCastFakeSpellAtObject(string sGroupName, int nSpell, object oTarget, int nProjectilePathType = PROJECTILE_PATH_TYPE_DEFAULT)
{
	object oMember = GetFirstInGroup(sGroupName);
	while (GetIsObjectValid(oMember) == TRUE)
	{
		AssignCommand(oMember, ActionCastFakeSpellAtObject(nSpell, oTarget, nProjectilePathType));
		oMember = GetNextInGroup(sGroupName);
	}
}

void GroupApplyEffectToObject(string sGroupName, int nDurationType, effect eEffect, float fDuration = 0.0f)
{
	object oMember = GetFirstInGroup(sGroupName);
	while (GetIsObjectValid(oMember) == TRUE)
	{
		ApplyEffectToObject(nDurationType, eEffect, oMember, fDuration);
		oMember = GetNextInGroup(sGroupName);
	}
}

void GroupRemoveEffectOfType(string sGroupName, int nEffectType)
{
	object oMember = GetFirstInGroup(sGroupName);
	while (GetIsObjectValid(oMember) == TRUE)
	{
		RemoveEffectOfType(oMember, nEffectType);
		oMember = GetNextInGroup(sGroupName);
	}
}

void GroupSignalEvent(string sGroupName, event eEvent)
{
	object oMember = GetFirstInGroup(sGroupName);
	while (GetIsObjectValid(oMember) == TRUE)
	{
		SignalEvent(oMember, eEvent);
		oMember = GetNextInGroup(sGroupName);
	}
}

void GroupSetScriptHidden(string sGroupName, int bHidden)
{
	object oMember = GetFirstInGroup(sGroupName);
	while (GetIsObjectValid(oMember))
	{
		SetScriptHidden(oMember, bHidden);
		oMember = GetNextInGroup(sGroupName);
	}
}

int IncGroupNumKilled( string sGroupName )
{
	int nNumKilled = GetGroupInt( sGroupName, GROUP_VAR_NUM_KILLED ) + 1;
	SetGroupInt( sGroupName, GROUP_VAR_NUM_KILLED, nNumKilled );
	return ( nNumKilled );
}

int GetGroupNumKilled( string sGroupName )
{
	int nNumKilled = GetGroupInt( sGroupName, GROUP_VAR_NUM_KILLED );
	return ( nNumKilled );
}

// Sets destroyable status of members in sGroupName
// - bDestroyable: If FALSE, members do not fade out and stick around as corpses.
// - bRaisable: If TRUE, members can be raised via resurrection.
// - bSelectableWhenDead: If TRUE, members are selectable after death.
void GroupSetIsDestroyable( string sGroupName, int bDestroyable, int bRaisable=TRUE, int bSelectableWhenDead=FALSE )
{
	object oGM = GetFirstInGroup( sGroupName );
	while ( GetIsObjectValid( oGM ) == TRUE )
	{
		AssignCommand( oGM, SetIsDestroyable( bDestroyable, bRaisable, bSelectableWhenDead ) );
		oGM = GetNextInGroup( sGroupName );
	}
}
