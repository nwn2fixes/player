/*	Overland Map include file
	JH/EF-OEI: 01/16/08
	NLC: 2/4/08 - added tons of new functions and reformatted
	NLC: 6/29/08 - adding goodie system, moving constants to ginc_overland_constants
	JSH-OEI 7/11/08 - Commented out line in SpawnSpecialEncounter which was breaking stuff.
*/
// kevL's 2019.02.14 - merge this with the SoZ Campaign 'ginc_overland' so it's suitable for /Override.
// - functions affected:
//   SetPartyActor()
//   InitializeEncounter()
//   ExitOverlandMap()
//   GerminateGoodies()
//   ActivateOLMapUI()
// Aqvilinus 2019.02.14 - fix EffectShaken() and EffectOffGuard() by changing negative
//                        effect-decrease args to pos.


#include "ginc_debug"
#include "ginc_math"
#include "ginc_group"
#include "ginc_cutscene"
#include "ginc_item"
#include "ginc_vars"
#include "ginc_2da"
#include "ginc_overland_constants"
#include "ginc_param_const"
#include "ginc_combat"
#include "ginc_time"

//Function Prototypes------------------------------

// kL_funct. Gets if this is SoZ.
int GetIsSoZ();

//Terrain
int GetCurrentPCTerrain();
int GetNumTerrainMaps(int nTerrain);
int GetTerrainType(object oTrigger);
int GetTerrainAtLocation(location lLocation);
float GetTerrainMovementRate(int nTerrainType);
float GetTerrainModifiedRate(object oCreature, int nTerrainType);
string GetTerrainWPPrefix(int nTerrain);
string GetTerrainAudioTrack(int nTerrainType);
object GetNearestTerrainTrigger(object oPC);

//Encounters
int GetNumValidRows(string sTable);
int GetEncounterRow(string sTable);
int GetNumHostileEncounters(object oArea = OBJECT_SELF);
int GetEncounterXP(int nPartyCR, int nEncEL);
void AwardEncounterXP(int nXP);
string GetEncounterConversation();
string GetEncounterRR(string sTable, int nRow);
string GetEncounterTable(object oEncounterSource);	//EncounterSource can be a trigger or an area
int SetEncounterBribeValue(object oEncounter);
int ModEncounterBribeValue(float fModPercent);

//Special Encounters
string GetSpecialEncounterTable(object oArea = OBJECT_SELF);
int GetSpecialEncounterRow(string sTable);
object SpawnSpecialEncounter(string sTable, location lLocation);

//PartyActorFunctions
object SetPartyActor(object oNewActor, object oCurrentOverride = OBJECT_INVALID);
void DisplayChallengeRating(object oPC, object oCreature);
int GetPartyChallengeRating();

//Player Location Functions
void StorePlayerMapLocation(object oPC);
void RestorePlayerMapLocation(object oPC);
location GetGlobalLocation(string sVar);
void SetGlobalLocation(string sVar, location lTarget);
void SetCurrentPCTerrain(int nTerrain);

//Random Encounter Setup Functions
void BeginRandomWalk();
void MoveEncounterToSpawnLocation(object oEncounter, object oPC);
int InitializeEncounter(object oPC);
location GetEncounterSpawnLocation(object oPC, float fSpotDistance);
location CreateTestEncounterSpawnLocation(object oPC, float fDist = 8.0f);
object CreateEncounterNearPC(object oPC);
void SetEncounterLocalVariables(object oEncounter, string sEncounterTable, int nRow);

//Neutral Encounter Setup Functions
void InitializeNeutralEncounter(object oPC, object oArea = OBJECT_SELF);
int GetCurrentEncounterPopulation(object oPC, string sEncounterTag);
int GetEncounterMaxPopulation(string sTable, int nRow);

//Special Encounter Setup Functions
void InitializeSpecialEncounter(object oPC);
void ResetSpecialEncounterTimer(object oArea = OBJECT_SELF);
void SetSEStartLocation(location lLocation, object oSE = OBJECT_SELF);
location GetSEStartLocation(object oSE = OBJECT_SELF);

//Secret Location Tag Parsing Functions
string GetTravelPlaceableResRef(object oIpoint = OBJECT_SELF);
string GetDestWPTag(object oPlaceable = OBJECT_SELF);
string GetExitWPTag(object oPlaceable = OBJECT_SELF);

//Random Encounter Dialog Skill Use Effects
effect EffectShaken();
effect EffectOffGuard();

//OLMap Transition Functions
void ExitOverlandMap(object oPC);

//Goodie Functions

void GerminateGoodies( int nTotal, object oArea = OBJECT_SELF);
string GetGoodieTable(object oSeed);
int GetIsGoodieValidForTerrain(string sGoodieTable, int nRow, int nTerrain);
location GetGoodieLocation(object oSeed);
int CreateGoodie(object oSeed);
void SetGoodieData(object oGoodie, string sGoodieTable, int nRow);
int GetGoodieRow(string sTable);

//OLMap UI Functions

//Activates the OL Map UI for oPC. This closes the default UI Elements that are intended to be hidden 
//on the OL Map and opens the new OL UI objects for the pc.
void ActivateOLMapUI(object oPC);

//Deactivates the OL Map UI for oPC. This closes the OL Map UI Elements 
//and re-opens the default UI objects for the PC.
void DeactivateOLMapUI(object oPC);

//Function Declarations------------------------------

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


/*----------------------\
|	Terrain Functions	|
\----------------------*/
int GetCurrentPCTerrain()
{
	return GetGlobalInt(VAR_PC_TERRAIN);
}

int GetNumTerrainMaps(int nTerrain)
{
	switch(nTerrain)
	{
	case TERRAIN_FOREST:
		return 1;
	case TERRAIN_DESERT:
		return 1;
	case TERRAIN_BEACH:
		return 1;
	case TERRAIN_ROAD:
		return 1;		
	case TERRAIN_PLAINS:
		return 1;
	case TERRAIN_JUNGLE:
		return 1;
	case TERRAIN_HILLS:
		return 1;
	case TERRAIN_SWAMP:
		return 1;
	}
	PrettyDebug("No terrain maps for terrain type " + IntToString(nTerrain));
	return 0;
}

int GetTerrainType(object oTrigger)
{
	return GetLocalInt(oTrigger,"nTerrain");
}

int GetTerrainAtLocation(location lLocation)
{
	object oArea = GetAreaFromLocation(lLocation);
	object oTrigger = GetFirstSubArea(oArea, GetPositionFromLocation(lLocation));
	int i=0;
	while ( GetTag(oTrigger) != "nx2_tr_terrain" && GetIsObjectValid(oTrigger))
	{
		oTrigger = GetNextSubArea(oArea);
	}
	
	int nResult = GetLocalInt(oTrigger,"nTerrain");
	return nResult;
}

/* Returns the terrain movement penalty applied to the party's movement*/
float GetTerrainMovementRate(int nTerrainType)
{
	string sRate = Get2DAString(TABLE_MOVEMENT_RATE, "Movement_Rate", nTerrainType);
	float fRate = StringToFloat(sRate);
	
	/*(switch(nTerrainType)
	{
	case TERRAIN_ROAD:
		return TERRAIN_RATE_ROAD;
	case TERRAIN_JUNGLE:
		return TERRAIN_RATE_JUNGLE;
	case TERRAIN_DESERT:
		return TERRAIN_RATE_DESERT;
	case TERRAIN_PLAINS:
		return TERRAIN_RATE_PLAINS;
	case TERRAIN_FOREST:
		return TERRAIN_RATE_FOREST;
	case TERRAIN_HILLS:
		return TERRAIN_RATE_HILLS;
	case TERRAIN_MOUNTAINS:
		return TERRAIN_RATE_MOUNTAINS;
	case TERRAIN_SWAMP:
		return TERRAIN_RATE_SWAMP;
	}*/
	
	return fRate;
}
float GetTerrainModifiedRate(object oCreature, int nTerrainType)
{
	float fNewRate	= GetTerrainMovementRate(nTerrainType);
	if(GetIsPC(oCreature))
		PrettyDebug("fNewRate:" + FloatToString(fNewRate));

	//	For every 1 rank of Survival, the entering character/creature gets a
	//	+0.01 bonus to his movement rate.
	float fSurvivalMod	= NX2_TERRAIN_SPD_SURVIVAL_MOD * IntToFloat(GetSkillRank(SKILL_SURVIVAL, oCreature));
	
	if(GetIsPC(oCreature))
		PrettyDebug("fSurvivalMod:" + FloatToString(fSurvivalMod));
	
	fNewRate += fSurvivalMod;
	
	//	Cap the maximum move rate at Road speed (set in om_terrain_rate.2da)
	if (fNewRate > GetTerrainMovementRate(TERRAIN_ROAD))
		fNewRate = GetTerrainMovementRate(TERRAIN_ROAD);
	
	if (GetHasFeat(FEAT_EPITHET_FAV_OF_THE_ROAD, oCreature, TRUE))
	{
		fNewRate += NX2_TERRAIN_SPD_FAV_ROAD_BONUS;
	}
	
	if (GetLocalInt(oCreature, "bHostile") && !GetLocalInt(oCreature, "bAfraid") )
	{
		fNewRate *= NX2_TERRAIN_SPD_HOSTILE_MULT;
	}
	
	/*	Neutral encounters move slightly slower than the party.	*/
	if (GetLocalInt(oCreature, "bNeutral"))
	{
		fNewRate *= NX2_TERRAIN_SPD_NEUTRAL_MULT;
	}
	
	if (GetLocalInt(oCreature, "bAfraid"))
	{
		fNewRate *= NX2_TERRAIN_SPD_AFRAID_MULT;
	}

	if(GetIsPC(oCreature))		
		PrettyDebug("New movement rate: " + FloatToString(fNewRate));
		
	return fNewRate;
}
int GetTerrainBGM(int nTerrainType)
{
	int nResult = Get2DAInt(TABLE_MOVEMENT_RATE, "Music_Track", nTerrainType);
	return nResult;
}

string GetTerrainAudioTrack(int nTerrainType)
{
	switch(nTerrainType)
	{
	case TERRAIN_ROAD:
	//	return 152;
		return "sfx_road";
	case TERRAIN_JUNGLE:
		//return 149;
		return "sfx_forest";
	case TERRAIN_DESERT:
		//return 151;
		return "sfx_desert";
	case TERRAIN_BEACH:
		//return 148;
		return "sfx_sea";
	case TERRAIN_PLAINS:
		//return 150;
		return "sfx_plains";
	}
	return "";
}

string GetTerrainWPPrefix(int nTerrain)
{
	switch(nTerrain)
	{
	case TERRAIN_FOREST:
		return WP_PREFIX_FOREST;
	case TERRAIN_DESERT:
		return WP_PREFIX_DESERT;
	case TERRAIN_BEACH:
		return WP_PREFIX_BEACH;
	case TERRAIN_ROAD:
		return WP_PREFIX_ROAD;	
	case TERRAIN_HILLS:
		return WP_PREFIX_HILLS;
	case TERRAIN_JUNGLE:
		return WP_PREFIX_JUNGLE;
	case TERRAIN_SWAMP:
		return WP_PREFIX_SWAMP;
	case TERRAIN_PLAINS:
		return WP_PREFIX_PLAINS;	
	}
	PrettyDebug("Unable to find Terrain WP prefix for terrain " + IntToString(nTerrain));
	return "";
}

/*	Get number of valid rows in the Encounter List 2DA. This will allow
	use to randomly pick a valid row from the list when it's time to 
	spawn the encounter on the overland map.	*/
int GetNumValidRows(string sTable)
{
	int nCurrentRow			= 1;
	int nMaxRows			= 0;
	string sColumn			= "Label";
	string sEncounterName	= Get2DAString(sTable, sColumn, nCurrentRow);
	
	while (sEncounterName != "")
	{
		nMaxRows++;
		nCurrentRow++;
		sEncounterName	= Get2DAString(sTable, sColumn, nCurrentRow);
	}
		
	//PrettyDebug("Found " + IntToString(nMaxRows) + " valid rows.");
	return nMaxRows;
}


/*	Get the row in which the encounter resref is listed.	*/
int GetEncounterRow(string sTable)
{
	string sShutoffVariable;
	int nEncounterRow;
	int nEncounterShutoff;
	
	nEncounterRow = Random(GetNumValidRows(sTable))+1;
	sShutoffVariable = Get2DAString(sTable, SHUTOFF_COLUMN, nEncounterRow);
	nEncounterShutoff = GetGlobalInt(sShutoffVariable);
	if(nEncounterShutoff)
		return FALSE;
	
	else return nEncounterRow;
}

/*	Check the row of the Encounter List 2DA to see what encounter spawns.	*/
string GetEncounterRR(string sTable, int nEncounterRow)
{
	//string sTable			= "wm_encounters";
	//int nEncounterRow		= Random(GetNumValidRows(sTable))+1;
	
	string sCol 			= "ENC_RESREF";	
	string sEncounterRR		= Get2DAString(sTable, sCol, nEncounterRow);	
		
	return sEncounterRR;
}

/*	Check to see which Encounter List Table 2DA to pull monsters from.	*/
string GetEncounterTable(object oEncounterSource)
{
	int nRow		= GetLocalInt(oEncounterSource, "nEncounterTable");
	string sCol		= ENC_2DA;
	
	string sTable 	= Get2DAString(ENCOUNTER_AREAS_2DA, sCol, nRow);
	
	PrettyDebug("Encounter Table: " + sTable);

	return sTable;		
}

int GetEncounterXP(int nPartyCR, int nEncEL)
{
	string sELColumn = "EL";
	sELColumn += IntToString(nEncEL);	//EL Columns are in the format ELX where X is the EL of the encounter.
	int nXP = Get2DAInt(ENC_XP_2DA, sELColumn, nPartyCR);	//The Party's CR determines the Row of the 2DA.
	string sMessage = IntToString(nXP);
	return nXP;
}

void AwardEncounterXP(int nXP)
{
	SendMessageToAllPlayersByStrRef(STRREF_ENC_XP_AWARD);
	object oPC = GetFirstPC();
	object oTarg = GetFirstFactionMember(oPC, FALSE);
	int nPartyMembers = 0;
	while(GetIsObjectValid(oTarg))
    {
		if(GetIsRosterMember(oTarg) || GetIsOwnedByPlayer(oTarg))
			nPartyMembers++;
			
     	oTarg = GetNextFactionMember(oPC, FALSE);
	}
	
	nXP /= nPartyMembers;
	
	oTarg = GetFirstFactionMember(oPC);
    while(GetIsObjectValid(oTarg))
    {
		if(GetIsRosterMember(oTarg) || GetIsOwnedByPlayer(oTarg))
			GiveXPToCreature( oTarg,nXP );
		
		oTarg = GetNextFactionMember(oPC);
    }
}

int SetEncounterBribeValue(object oEncounter)
{
	float fCR = GetChallengeRating(oEncounter);
	float fValue = 2*fCR;
	fValue = pow(fValue, 2.0f);
	
	int nResult = FloatToInt(fValue);
	if(nResult < 10)
		nResult = 10;
	
	SetCustomToken( 1000, IntToString(nResult));
	SetGlobalInt("BRIBE_AMOUNT", nResult);
	
	return nResult;
}

int ModEncounterBribeValue(float fModPercent)
{
	int nCurrentAmount = GetGlobalInt("BRIBE_AMOUNT");
	float fCurrentAmount = IntToFloat(nCurrentAmount);
	PrettyDebug(FloatToString(fModPercent) + " percent of " + FloatToString(fCurrentAmount));			
	float fResult = (fCurrentAmount * fModPercent * 0.01f);
	int nResult = FloatToInt(fResult);
	PrettyDebug("New Bribe Value:" + IntToString(nResult));
	SetCustomToken( 1000, IntToString(nResult));
	SetGlobalInt("BRIBE_AMOUNT", nResult);
	
	return nResult;
}

/*--------------------------\
|	Party Actor Functions	|
\--------------------------*/
object SetPartyActor(object oNewActor, object oCurrentOverride = OBJECT_INVALID)
{
	object oCurrentActor;
	int bOverride;
	if(oCurrentOverride == OBJECT_INVALID)
	{
		oCurrentActor = GetLocalObject(GetModule(), "oPartyLeader");
		bOverride = FALSE;
	}	
	
	else
	{
		oCurrentActor = oCurrentOverride;
		bOverride = TRUE;
	}
	PrettyDebug("Current Actor:" + GetName(oCurrentActor));
	PrettyDebug("New Actor:" + GetName(oNewActor));
	AssignCommand(oCurrentActor, ClearAllActions(TRUE));
	AssignCommand(oNewActor, ClearAllActions(TRUE));
	
	SetScriptHidden(oCurrentActor, TRUE, FALSE);
	SetScriptHidden(oNewActor, FALSE);
	
	location lLocation = GetLocation(oCurrentActor);
	if(bOverride == FALSE)		//If we are aborting a selection don't jump.
		AssignCommand(oNewActor, JumpToLocation(lLocation));
	
	DelayCommand(0.1f, SetFactionLeader(oNewActor));
	SetOwnersControlledCompanion( oCurrentActor, oNewActor );
	SetLocalObject(GetModule(), "oPartyLeader", oNewActor);

	if (GetIsSoZ())
	{
		object oTerrain = GetNearestTerrainTrigger(oNewActor);
		int nTerrain = GetTerrainType(oTerrain);
		float fNewRate = GetTerrainModifiedRate(oNewActor, nTerrain);
		SetMovementRateFactor(oNewActor, fNewRate);
	}

	return oNewActor;
}

int GetPartyChallengeRating()
{
	object oPartyMember = GetFirstFactionMember(GetFirstPC(), FALSE);
	int nHD;
	int nTotalPartyLevels;
	int nPartySize;
	float fPartyCR;
	
	while (GetIsObjectValid(oPartyMember))
	{
		nHD = GetTotalLevels(oPartyMember, FALSE);
		nTotalPartyLevels = nTotalPartyLevels + nHD;
		nPartySize++;
		oPartyMember = GetNextFactionMember(GetFirstPC(), FALSE);
	}
	
	fPartyCR = IntToFloat(nTotalPartyLevels) / IntToFloat(nPartySize);
	
	return FloatToInt(fPartyCR);
}

/*	Update spawned creature with CR info and color code him
	appropriately based on the party's CR vs. creature CR.	*/
void DisplayChallengeRating(object oPC, object oCreature)
{
	string sName	= GetName(oCreature);
	string sCR		= GetStringByStrRef(234257); // "CR "
	int nEnemyCR	= FloatToInt(GetChallengeRating(oCreature));
	int nPartyCR	= GetPartyChallengeRating();
	int nCRDiff		= nEnemyCR - nPartyCR;
	
	PrettyDebug(sName + "CR: " + IntToString(nEnemyCR));
	PrettyDebug("Party CR: " + IntToString(nPartyCR));
	
	//	Impossible - CR +5
	if (nCRDiff >= 5)
		SetFirstName(oCreature, sName + "\n" + "(" + "<color=FUCHSIA>" + sCR + IntToString(nEnemyCR) + "</color>" + ")");
	
	//	Overpowering - CR +4/+3
	else if (nCRDiff == 4 || nCRDiff == 3)
		SetFirstName(oCreature, sName + "\n" + "(" + "<color=RED>" + sCR + IntToString(nEnemyCR) + "</color>" +")");
	
	//	Very Difficult - CR +2/+1
	else if (nCRDiff == 2 || nCRDiff == 1)
		SetFirstName(oCreature, sName + "\n" + "(" + "<color=ORANGE>" + sCR + IntToString(nEnemyCR) + "</color>" +")");	
	
	//	Challenging - CR +0/-1
	else if (nCRDiff == 0 || nCRDiff == -1)
		SetFirstName(oCreature, sName + "\n" + "(" + "<color=YELLOW>" + sCR + IntToString(nEnemyCR) + "</color>" + ")");
	
	//	Moderate - CR -2/-3
	else if (nCRDiff == -2 || nCRDiff == -3)
		SetFirstName(oCreature, sName + "\n" + "(" + "<color=DEEPSKYBLUE>" + sCR + IntToString(nEnemyCR) + "</color>" + ")");
	
	//	Easy - CR -4/-5
	else if (nCRDiff == -4 || nCRDiff == -5)
		SetFirstName(oCreature, sName + "\n" + "(" + "<color=LIME>" + sCR + IntToString(nEnemyCR) + "</color>" + ")");
							
	//	Effortless - CR -6
	else
		SetFirstName(oCreature, sName + "\n" + "(" + "<color=WHITE>" + sCR + IntToString(nEnemyCR) + "</color>" + ")");
}

/*------------------------------\
|	Special Encounter Functions	|
\------------------------------*/
string GetSpecialEncounterTable(object oArea = OBJECT_SELF)
{
	string sTable 	= GetLocalString(oArea, VAR_SE_TABLE);
	
	PrettyDebug("Special Encounter Table: " + sTable);

	return sTable;	
}


object SpawnSpecialEncounter(string sTable, location lLocation)
{
	int nEncounterRow = Random(GetNumValidRows(sTable))+1;
	string sResRef = Get2DAString(sTable, "ENC_RESREF", nEncounterRow);
	
	int nValidTerrain = StringToInt(Get2DAString(sTable, "nTerrain", nEncounterRow));
	int bSEFired = GetGlobalInt(sResRef + "_FIRED");
	
	if( GetTerrainAtLocation(lLocation) == nValidTerrain && !bSEFired)
	{
		SetGlobalInt(sResRef + "_FIRED", TRUE);
		PrettyDebug("Spawning sEncounterRR:"+sResRef);
		object oSE = CreateObject(OBJECT_TYPE_CREATURE, sResRef, lLocation);
		
		//if(Get2DAInt(sTable, "bHostile", nEncounterRow))
			SetEncounterLocalVariables(oSE, sTable, nEncounterRow);
		
		SetSEStartLocation(lLocation, oSE);
		SetLocalInt(OBJECT_SELF, VAR_SE_FLAG, TRUE);
		return oSE;
	}
	
	else return OBJECT_INVALID;
}

void SetSEStartLocation(location lLocation, object oSE = OBJECT_SELF)
{
	SetLocalLocation(oSE, VAR_SE_START_LOC, lLocation);
}
location GetSEStartLocation(object oSE = OBJECT_SELF)
{
	return GetLocalLocation(oSE, VAR_SE_START_LOC);
}

/*------------------------------\
|	Player Location Functions	|
\------------------------------*/
void SetCurrentPCTerrain(int nTerrain)
{
//	PrettyDebug("PC terrain type = " + IntToString(nTerrain));
	SetGlobalInt(VAR_PC_TERRAIN, nTerrain);
}

void SetGlobalLocation(string sVar, location lTarget)
{
	object oArea = GetAreaFromLocation(lTarget);
	vector vTarg = GetPositionFromLocation(lTarget);
	float fFace = GetFacingFromLocation(lTarget);
	
	SetGlobalFloat(sVar + "x", vTarg.x);
	SetGlobalFloat(sVar + "y", vTarg.y);
	SetGlobalFloat(sVar + "z", vTarg.z);
	SetGlobalFloat(sVar + "f", fFace);
	SetGlobalString(sVar + "a", GetTag(oArea));
}

location GetGlobalLocation(string sVar)
{
	float x = GetGlobalFloat(sVar + "x");
	float y = GetGlobalFloat(sVar + "y");
	float z = GetGlobalFloat(sVar + "z");
	float fFace = GetGlobalFloat(sVar + "f");
	object oArea = GetObjectByTag(GetGlobalString(sVar + "a"));
	
	return Location(oArea,Vector(x,y,z),fFace);
}

/*	Stores the party's current location on the Overland Map.	*/
void StorePlayerMapLocation(object oPC)
{
	PrettyDebug("Storing Overland Map location.");
	SetGlobalLocation(VAR_PARTY_LOCATION, GetLocation(oPC));
	object oPlayerMarker = GetObjectByTag(TAG_PLAYER_MARKER);
	
	/*	Remove the previous marker.	*/		
	if(GetIsObjectValid(oPlayerMarker))
	{
		DestroyObject(oPlayerMarker);
	}
}

/*	Restores the party to its last location on the Overland Map.	*/
void RestorePlayerMapLocation(object oPC)
{
	PrettyDebug("Overland Map location restored.");
	location lPC = GetGlobalLocation(VAR_PARTY_LOCATION);
	object oPlayerMarker = CreateObject(OBJECT_TYPE_WAYPOINT, TAG_PLAYER_MARKER, lPC);
	object oFailSafe = GetObjectByTag(TAG_HOSTILE_SPAWN);
	
	object oFM = GetFirstFactionMember( oPC, FALSE );
	while ( GetIsObjectValid( oFM ) == TRUE )
	{
		effect eEffect = GetFirstEffect(oFM);
		while(GetIsEffectValid(eEffect))
		{
			if(GetEffectType(eEffect) == EFFECT_TYPE_HITPOINT_CHANGE_WHEN_DYING)
			{
				if(GetEffectInteger(eEffect, 0) != TRUE)
				{
					effect eDeath = EffectDeath(FALSE,FALSE,TRUE,TRUE);
					DelayCommand(1.0f, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oFM));
				}
			}
			
			eEffect = GetNextEffect(oFM);
		}
		oFM = GetNextFactionMember( oPC, FALSE );
	}
	if (!GetIsObjectValid(oPlayerMarker))
	{
		PrettyDebug("Error! No restore point found!");
		JumpPartyToArea(oPC, oFailSafe);
	}
	
	JumpPartyToArea(oPC, oPlayerMarker);
}

string GetEncounterConversation()
{
	PrettyDebug(GetLocalString(OBJECT_SELF, "sConv"));
	return GetLocalString(OBJECT_SELF, "sConv");
}


/*	Randomly determine how many creatures in the subgroup show up in total. Min
	and max values are drawn from the relevant Encounter List 2DA.	*/
int GetTotalCreatures(int nMin, int nMax)
{
	int nTotal;

	if (nMax > nMin)
	{ 
		nTotal = Random(nMax - nMin + 1) + nMin;
	}
	
	else if (nMin == nMax)
	{
		nTotal = nMax;							// Min = Max, so always spawn that number of creatures.
	}
	
	else if (nMin > nMax)
	{
		PrettyDebug ("Minimum creatures is higher than maximum! This is an error in the encounter 2da");
	}	 
	
	return nTotal;
}

void ApplyDialogSkillEffect(object oEncCreature, int nDialogSkill, int nSkillMargin)
{
	switch (nDialogSkill)
	{
		case SKILL_DIPLOMACY:
		break;
						
		case SKILL_BLUFF:
		{
			if(nSkillMargin > 10)
				nSkillMargin = 10;
			
			int nRoundsOffGuard = nSkillMargin;
			
			float fSecondsOffGuard = IntToFloat(nRoundsOffGuard) * 6.0f;
			PrettyDebug("Applying Offguard Effect for " + FloatToString(fSecondsOffGuard) + " seconds to" + GetName(oEncCreature));
			ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectOffGuard(), oEncCreature, fSecondsOffGuard);
		}
		break;
						
		case SKILL_INTIMIDATE:
		{
			if(nSkillMargin > 10)
				nSkillMargin = 10;
			
			int nRoundsFrightened = nSkillMargin - 5;				//Maximum 5 rounds frightened
			
			float fSecondsFrightened = IntToFloat(nRoundsFrightened) * 6.0f;
			PrettyDebug("Applying Frightened Effect for " + FloatToString(fSecondsFrightened) + " seconds.");
			if(fSecondsFrightened > 0.0f)
			{
				PrettyDebug("Applying Frightened Effect");
				nSkillMargin -= 5;
				ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectFrightened(), oEncCreature, fSecondsFrightened);
			}
						
			
			float fSecondsShaken = IntToFloat(nSkillMargin) * 6.0f;
			PrettyDebug("Applying Shaken Effect for " + FloatToString(fSecondsShaken) + " seconds.");
			ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectShaken(), oEncCreature, fSecondsShaken);
		}			
		break;

	}
}

void SpawnEncounterSubgroup(object oWP, string sCreatureRR, int nNumCreatures, int bForceHostile, int nDialogSkill, int nSkillMargin, string sGroupName)
{
	location lSpawn;
	location lWP		= GetLocation(oWP);
	float fFacing		= GetFacing(oWP);
	int nRR 			= 1; // Always a minimum of 1 creature

	while(nRR <= nNumCreatures)
	{
		lSpawn = GetBMALocation(lWP, nRR, 3.0f);
		PrettyDebug("Spawning " + sCreatureRR + " at waypoint " + GetTag(oWP) + " at position " + VectorToString(GetPositionFromLocation(lSpawn)));
		object oEncCreature = CreateObject(OBJECT_TYPE_CREATURE, sCreatureRR, lSpawn);
		
		if(bForceHostile)
			ChangeToStandardFaction(oEncCreature, STANDARD_FACTION_HOSTILE);
			
		if(nDialogSkill)
		{
			ApplyDialogSkillEffect(oEncCreature, nDialogSkill, nSkillMargin);
			PrettyDebug("Applying Dialog Skill:" + IntToString(nDialogSkill) + " to " + GetName(oEncCreature));
		}
		
		GroupAddMember(sGroupName, oEncCreature);
		nRR++;
	}
}


void SpawnEncounterCreatures(object oWP, int nDialogSkill, int nSkillMargin, int bGroup1ForceHostile = FALSE, int bGroup2ForceHostile = FALSE, 
							int bGroup3ForceHostile = FALSE, int bGroup4ForceHostile = FALSE, int bGroup5ForceHostile = FALSE, string sGroupNamePrefix = "")
{
	/*	Retrieve the values of the Encounter List 2DA and row stored on the
		overland map creature.	*/
	string sEncounterList2DA	= GetLocalString(OBJECT_SELF, "sEncounterList2DA");
	int nEncounterIndex			= GetLocalInt(OBJECT_SELF, "nRow");
	
	string sCreatureCol	= "CREATURE_RESREF_";
	string sMinCol 		= "MIN_RR_";
	string sMaxCol 		= "MAX_RR_";
	
	string sCreature1	= Get2DAString(sEncounterList2DA, sCreatureCol + "1", nEncounterIndex);
	string sCreature2	= Get2DAString(sEncounterList2DA, sCreatureCol + "2", nEncounterIndex);
	string sCreature3	= Get2DAString(sEncounterList2DA, sCreatureCol + "3", nEncounterIndex);
	string sCreature4	= Get2DAString(sEncounterList2DA, sCreatureCol + "4", nEncounterIndex);
	string sCreature5	= Get2DAString(sEncounterList2DA, sCreatureCol + "5", nEncounterIndex);
	
	string sMinRR1 = Get2DAString(sEncounterList2DA, sMinCol + "1", nEncounterIndex);
	string sMinRR2 = Get2DAString(sEncounterList2DA, sMinCol + "2", nEncounterIndex);
	string sMinRR3 = Get2DAString(sEncounterList2DA, sMinCol + "3", nEncounterIndex);
	string sMinRR4 = Get2DAString(sEncounterList2DA, sMinCol + "4", nEncounterIndex);
	string sMinRR5 = Get2DAString(sEncounterList2DA, sMinCol + "5", nEncounterIndex);
	
	string sMaxRR1 = Get2DAString(sEncounterList2DA, sMaxCol + "1", nEncounterIndex);
	string sMaxRR2 = Get2DAString(sEncounterList2DA, sMaxCol + "2", nEncounterIndex);
	string sMaxRR3 = Get2DAString(sEncounterList2DA, sMaxCol + "3", nEncounterIndex);
	string sMaxRR4 = Get2DAString(sEncounterList2DA, sMaxCol + "4", nEncounterIndex);
	string sMaxRR5 = Get2DAString(sEncounterList2DA, sMaxCol + "5", nEncounterIndex);
	
	int nMinRR1 = StringToInt(sMinRR1); 
	int nMaxRR1 = StringToInt(sMaxRR1);
		
	int nMinRR2 = StringToInt(sMinRR2); 
	int nMaxRR2 = StringToInt(sMaxRR2); 
		
	int nMinRR3 = StringToInt(sMinRR3); 
	int nMaxRR3 = StringToInt(sMaxRR3); 
		
	int nMinRR4 = StringToInt(sMinRR4); 
	int nMaxRR4 = StringToInt(sMaxRR4); 
		
	int nMinRR5 = StringToInt(sMinRR5); 
	int nMaxRR5 = StringToInt(sMaxRR5); 
	
	int nTotal;
		
	/*	Check to see if there's a valid resref entered, and if so, spawn
		the randomly generated number of creatures.	*/
	if (sCreature1 != "")
	{
		nTotal = GetTotalCreatures(nMinRR1, nMaxRR1);
		PrettyDebug("Spawning creature group 1.");
		SpawnEncounterSubgroup(oWP, sCreature1, nTotal, bGroup1ForceHostile, nDialogSkill, nSkillMargin, sGroupNamePrefix + ENC_GROUP_NAME_1);
	}
	
	if (sCreature2 != "")
	{
		nTotal = GetTotalCreatures(nMinRR2, nMaxRR2);
		PrettyDebug("Spawning creature group 2.");
		SpawnEncounterSubgroup(oWP, sCreature2, nTotal, bGroup2ForceHostile, nDialogSkill, nSkillMargin, sGroupNamePrefix + ENC_GROUP_NAME_2);
	}
	
	if (sCreature3 != "")
	{
		nTotal = GetTotalCreatures(nMinRR3, nMaxRR3);
		PrettyDebug("Spawning creature group 3.");
		SpawnEncounterSubgroup(oWP, sCreature3, nTotal, bGroup3ForceHostile, nDialogSkill, nSkillMargin, sGroupNamePrefix + ENC_GROUP_NAME_3);
	}
	
	if (sCreature4 != "")
	{
		nTotal = GetTotalCreatures(nMinRR4, nMaxRR4);
		PrettyDebug("Spawning creature group 4.");
		SpawnEncounterSubgroup(oWP, sCreature4, nTotal, bGroup4ForceHostile, nDialogSkill, nSkillMargin, sGroupNamePrefix + ENC_GROUP_NAME_4);
	}
	
	if (sCreature5 != "")
	{
		nTotal = GetTotalCreatures(nMinRR5, nMaxRR5);
		PrettyDebug("Spawning creature group 5.");
		SpawnEncounterSubgroup(oWP, sCreature5, nTotal, bGroup5ForceHostile, nDialogSkill, nSkillMargin, sGroupNamePrefix + ENC_GROUP_NAME_5);
	}
}		



string GetEncounterWPSuffix(int bEnemy = FALSE)
{
	string sResult;
	
	if(bEnemy)
		sResult = WP_ENEMY_DESIGNATOR;
		
	else
		sResult = WP_PARTY_DESIGNATOR;
	
	sResult += WP_SUFFIX_DEFAULT;
	
	return sResult;

}

/*	Choose a random map from the appropriate terrain type and spawn in the
	creatures.	*/
void InitiateEncounter(int nDialogSkill, int nSkillDC, int bGroup1ForceHostile = FALSE, int bGroup2ForceHostile = FALSE, 
						int bGroup3ForceHostile = FALSE, int bGroup4ForceHostile = FALSE, int bGroup5ForceHostile = FALSE, object oPC = OBJECT_INVALID)
{
	int nTerrain		= GetCurrentPCTerrain();
	int nSkillRanks	= GetSkillRank(nDialogSkill, oPC);
	int nSkillMargin = nSkillRanks - nSkillDC;
	int nRand			= Random(GetNumTerrainMaps(nTerrain)) + 1;
	
	string sPrefix		= GetTerrainWPPrefix(nTerrain);

	if(nRand < 10)
	{
		sPrefix += "0";
	}			
	string sPartyWP, sEnemyWP;
	
	sPrefix += IntToString(nRand);
		
	sPartyWP += sPrefix;
	sEnemyWP += sPrefix;
	sPartyWP += GetEncounterWPSuffix();
	sEnemyWP += GetEncounterWPSuffix(TRUE);
	
	object oPartyWP = GetObjectByTag(sPartyWP);
	object oEnemyWP = GetObjectByTag(sEnemyWP);
	
	//Failsafe - if the waypoint is invalid you'll now go to plains.
	if(GetIsObjectValid(oPartyWP) == FALSE || GetIsObjectValid(oEnemyWP) == FALSE )
	{
		PrettyDebug("The Party and/or Enemy Destination waypoints are invalid! Rerouting to plains01. This is a bug.", PRETTY_DURATION, POST_COLOR_ERROR);
		oPartyWP = GetObjectByTag(WP_PARTY_FAILSAFE);
		oEnemyWP = GetObjectByTag(WP_ENEMY_FAILSAFE);
	}
	
	RemoveAllEffects(oPC,FALSE);
	
	SpawnEncounterCreatures(oEnemyWP, nDialogSkill, nSkillMargin, bGroup1ForceHostile, bGroup2ForceHostile, 
							bGroup3ForceHostile, bGroup4ForceHostile, bGroup5ForceHostile);
	
	StorePlayerMapLocation(oPC);
	object oEncArea = GetArea(oPartyWP);
	SetCurrentPCTerrain(0);
	SetLocalInt(oEncArea, "nEncounterEL", FloatToInt(GetChallengeRating(OBJECT_SELF)));
	ExitOverlandMap(oPC);
	JumpPartyToArea(oPC, oPartyWP);
}

location GetEncounterSpawnLocation(object oPC, float fSpotDistance)
{
	vector vPC = GetPosition(oPC);
	float fAngle = RandomFloat(360.0);
	
	float iXVariance = cos(fAngle)*fSpotDistance;
	float iYVariance = sin(fAngle)*fSpotDistance;
						
	vPC.x += iXVariance;
	vPC.y += iYVariance;
	
	location lResult = Location(GetArea(oPC), vPC, 180.0);
	return lResult;
}

object GetNearestTerrainTrigger(object oPC)
{
	location lTest = GetLocation(oPC);			//Pick a random encounter point near the player.
	object oArea = GetArea(oPC);
		
	object oTrigger = GetFirstSubArea(oArea, GetPositionFromLocation(lTest));
	
	while( GetIsObjectValid(oTrigger) && ( GetTag(oTrigger) != "nx2_tr_terrain" ) )
	{
		oTrigger = GetNextSubArea(oArea);
	}
	
	if(GetIsObjectValid(oTrigger))
		return oTrigger;
		
	else
		return GetNearestObjectByTag("nx2_tr_terrain", oPC);
}


/*--------------------------\
|	Encounter Functions		|
\--------------------------*/
int InitializeEncounter(object oPC)
{
	if(GetGlobalInt(VAR_ENC_IGNORE))
	{
		return FALSE;
	}
	
	object oEncounter = CreateEncounterNearPC(oPC);
	
	if(GetIsObjectValid(oEncounter))
	{
		effect eSpawn = EffectNWN2SpecialEffectFile(VFX_HOSTILE_ENC_SPAWN);
		effect eHostile = EffectNWN2SpecialEffectFile(VFX_HOSTILE_ENC);
		SetLocalInt(oEncounter, "bHostile", TRUE);
		SetCustomHeartbeat(oEncounter, 6000);		//Initialize the custom heartbeat system... this could cause a weird problem if it failed for whatever reasons...
		DelayCommand(0.1f, ApplyEffectToObject(DURATION_TYPE_INSTANT, eSpawn, oEncounter));
		DelayCommand(0.1f, ApplyEffectToObject(DURATION_TYPE_PERMANENT, eHostile, oEncounter));
		DelayCommand(0.1f, BeginRandomWalk());
		string sFeedback = GetStringByStrRef(233947) + " ";
		sFeedback += GetName(oEncounter);
		
		if (GetIsSoZ())
			FloatingTextStringOnCreature(sFeedback, oPC, FALSE);
		else
			DelayCommand(0.1f, SendMessageToPC(oPC, sFeedback));

		return TRUE;
	}
	
	else
	{
		PrettyDebug("Invalid Encounter.  Please Report this as a bug.");
		return FALSE;
	}
}

void BeginRandomWalk()
{
	ClearAllActions(TRUE);
	ActionRandomWalk();
}

float DetermineEncounterDistance(object oPC)
{
	object oArea = GetArea(oPC);
	
	int nSkillToUse = SKILL_SPOT;
	if( GetSkillRank(SKILL_LISTEN, oPC) > GetSkillRank(SKILL_SPOT, oPC))
		nSkillToUse = SKILL_LISTEN;
	
	int nDC = GetLocalInt(GetNearestTerrainTrigger(oPC), "nDetectDC");
	
	if(nDC == 0)
		nDC = GetLocalInt(oArea, "nDetectDC");
		
	if(GetIsSkillSuccessful(oPC, nSkillToUse, nDC))
		return RandomFloatBetween(9.0f, 12.0f);
		
	else
		return RandomFloatBetween(4.0f, 6.0f);
}

object CreateEncounterNearPC(object oPC)
{
	object oResult;
	int iValidResult = FALSE;
	object oWP = GetNearestObjectByTag(TAG_HOSTILE_SPAWN, oPC);

	object oArea = GetArea(oPC);	
	
	float fDist = DetermineEncounterDistance(oPC);
	PrettyDebug("fDist = " + FloatToString(fDist));

	do{
		location lTest = CreateTestEncounterSpawnLocation(oPC, fDist);			//Pick a random encounter point near the player.
		
		object oTrigger = GetFirstSubArea(oArea, GetPositionFromLocation(lTest));
	
		while( GetIsObjectValid(oTrigger) && ( GetTag(oTrigger) != "nx2_tr_terrain" ) )
		{
			oTrigger = GetNextSubArea(oArea);
		}
		
		//make sure we have an actual valid "terrain" trigger
		if (!GetIsObjectValid(oTrigger))
			return OBJECT_INVALID;
		
		string sEncounterTable = GetEncounterTable(oTrigger);			//Get the encounter data from that trigger.
		
		int nRow = GetEncounterRow(sEncounterTable);
		
		if(!nRow)
			return OBJECT_INVALID;
		
		string sEncounterRR = GetEncounterRR(sEncounterTable, nRow);
	
		PrettyDebug("Encounter resref: " + sEncounterRR);
//		PrettyDebug("Spawning " + sEncounterRR + ".");
	
		oResult = CreateObject( OBJECT_TYPE_CREATURE, sEncounterRR, GetLocation(oWP) );		//Create the appropriate encounter for the trigger
		
		DisplayChallengeRating(oPC, oResult);	
			
		PrettyDebug(GetTag(oResult));
		if( !GetIsObjectValid(oResult) )
		{
			PrettyDebug("Table: " + sEncounterTable + " Row: " + IntToString(nRow) + " is invalid... spawn table is bad");
			return OBJECT_INVALID;
		}

		location lSafe = CalcSafeLocation(oResult, lTest, 1.0, FALSE, FALSE);	//Find out if the test location is valid for the creature
		
		vector vTest = GetPositionFromLocation(lTest);								//Get the vector data from the test and safe locations
		vector vSafe = GetPositionFromLocation(lSafe);
		

		
		if( CompareVectors2D(vTest, vSafe) )							//If we've created a valid object 
		{																//and we're placing it in a safe spot (i.e. vTest and vSafe are equal)
			iValidResult = TRUE;										//Break the loop,
			SetEncounterLocalVariables(oResult, sEncounterTable, nRow);	//Set the proper variables on the object
			AssignCommand(oResult, JumpToLocation(lTest));				//and move the creature to the test/safe spot.
		}
		
		else
			DestroyObject(oResult);
			
	}while(iValidResult == FALSE);
	
	return oResult;
}


void MoveEncounterToSpawnLocation(object oEncounter, object oPC)
{
	location lLocation, lSafe;
	vector vTest, vSafe;
				
	do{
		//PrettyDebug("Generating Random Location");
		lLocation = GetEncounterSpawnLocation(oPC, 12.0f);
		lSafe = CalcSafeLocation(oEncounter, lLocation, 1.0, FALSE, FALSE);
				
		vTest = GetPositionFromLocation(lLocation);
		vSafe = GetPositionFromLocation(lSafe);
	}while (!CompareVectors2D(vTest, vSafe));
			
	
}

void SetEncounterLocalVariables(object oEncounter, string sEncounterTable, int nRow)
{
	string sConv = Get2DAString(sEncounterTable, "sConv", nRow);
	int nLifespan = StringToInt(Get2DAString(sEncounterTable, VAR_ENC_LIFESPAN, nRow));
	float fSearchDist = StringToFloat(Get2DAString(sEncounterTable, "fSearchDist", nRow));
	int nSurvivalDC = StringToInt(Get2DAString(sEncounterTable, "nSurvivalDC", nRow));
	/*	Store the name of the Encounter List 2DA and the row of the
		encounter on the newly spawned overland map creature. When it comes time
		to spawn the encounter on a map, it will reference the correct
		Encounter List 2DA and draw creatures from the appropriate row.	*/
	/* Store the Overland Map Gameplay Variables on the Creature. */
	
	SetLocalString(oEncounter, "sEncounterList2DA", sEncounterTable);
	SetLocalInt(oEncounter, "nRow", nRow);
	SetLocalString(oEncounter, "sConv", sConv);
	
//	PrettyDebug("Encounter Conversation:"+sConv);
//	PrettyDebug("Encounter Lifespan:"+IntToString(nLifespan));
	
	SetLocalInt(oEncounter, VAR_ENC_LIFESPAN, nLifespan);
	SetLocalFloat(oEncounter, "fSearchDist", fSearchDist);
	SetLocalInt(oEncounter, "nSurvivalDC", nSurvivalDC);
}

location CreateTestEncounterSpawnLocation(object oPC, float fDist = 8.0f)
{
	location lLocation, lSafe;
	vector vTest, vSafe;

	do{
		//PrettyDebug("Generating Random Location");
		lLocation = GetEncounterSpawnLocation(oPC, fDist);
		lSafe = CalcSafeLocation(oPC, lLocation, 1.0, FALSE, FALSE);
				
		vTest = GetPositionFromLocation(lLocation);
		vSafe = GetPositionFromLocation(lSafe);
	}while (!CompareVectors2D(vTest, vSafe));

	return lLocation;
}

//This function will repopulate all "always on" encounters, and will also attempt to spawn a random non-always on encounter
void InitializeNeutralEncounter(object oPC, object oArea = OBJECT_SELF)
{

	string sTable = GetEncounterTable(oArea);
	int nNumRows = GetNum2DARows( sTable );
	
	//Spawn all of the "always on" encounters - if we don't already have enough.
	int i = 1;
	for (i = 0; i <= nNumRows; i++)
	{
		if(Get2DAInt(sTable, "bAlwaysOn", i))
		{
			string sEncounterRR = GetEncounterRR(sTable, i);
			
			int nMaxPop = GetEncounterMaxPopulation(sTable, i);
			int nCurrentPop = GetCurrentEncounterPopulation(oPC, sEncounterRR);
			
			if(nCurrentPop <= nMaxPop )
			{
				int j;
				for(j = nCurrentPop; j <= nMaxPop; j++)
				{
					object oWP = GetNearestObjectByTag(TAG_NEUTRAL_SPAWN, oPC);
	
					object oEnc = CreateObject(OBJECT_TYPE_CREATURE, sEncounterRR, GetLocation(oWP));
					
					DisplayChallengeRating(oPC, oEnc);
					SetLocalInt(oEnc, "bNeutral", TRUE);
					SetEncounterLocalVariables(oEnc, sTable, i);
				}
			}
		}
	}
	
	int nRow;
	do{
		nRow = GetEncounterRow(sTable);
	} while( Get2DAInt(sTable, "bAlwaysOn", nRow) != TRUE );
	
	string sEncounterRR = GetEncounterRR(sTable, nRow);
	
	if( GetCurrentEncounterPopulation(oPC, sEncounterRR) >= GetEncounterMaxPopulation(sTable, nRow) )
	{
		PrettyDebug("Too many of " + sEncounterRR);
		return;
	}

	else
	{
		object oWP = GetNearestObjectByTag(TAG_NEUTRAL_SPAWN, oPC);

		object oEnc = CreateObject(OBJECT_TYPE_CREATURE, sEncounterRR, GetLocation(oWP));
		SetLocalInt(oEnc, "bNeutral", TRUE);
		SetEncounterLocalVariables(oEnc, sTable, nRow);
	}
}

int GetCurrentEncounterPopulation(object oPC, string sEncounterTag)
{
	object oCreature = GetNearestObjectByTag(sEncounterTag, oPC);
	
	if (oCreature == OBJECT_INVALID)
		return 0;
		
	else
	{
		int i=1;
		while(GetIsObjectValid(oCreature))
		{
			i++;
			oCreature = GetNearestObjectByTag(sEncounterTag, oPC, i);
		}
		
		return i;
	}
}

int GetEncounterMaxPopulation(string sTable, int nRow)
{
	int nResult = StringToInt(Get2DAString(sTable, MAX_POP_COLUMN, nRow));
	return nResult;
}

void InitializeSpecialEncounter(object oPC)
{
	if(!GetGlobalInt(VAR_ENC_IGNORE))
	{
		if (GetIsSoZ())
		{
			location lPlayerLocation = GetLocation(oPC);
			location lSavedLocation = GetGlobalLocation("00_lSavedLocation");
			if(lPlayerLocation != lSavedLocation)
			{
				PrettyDebug("Spawning a Special Encounter.");
				string sTable = GetSpecialEncounterTable(GetArea(oPC));
				location lLocation = CreateTestEncounterSpawnLocation(oPC);
				SpawnSpecialEncounter(sTable, lLocation);
				SetGlobalLocation("00_lSavedLocation", lPlayerLocation);
			}
		}
		else
		{
			PrettyDebug("Spawning a Special Encounter.");
			string sTable = GetSpecialEncounterTable(GetArea(oPC));
			location lLocation = CreateTestEncounterSpawnLocation(oPC);
			SpawnSpecialEncounter(sTable, lLocation);
		}
	}
}

void ResetSpecialEncounterTimer(object oArea = OBJECT_SELF)
{
	int nSpecialEncounterCooldown = Random(SE_RATE_VARIANCE) + (SE_RATE_MINIMUM) + 1;
	SetLocalInt(oArea, VAR_ENC_SPECIAL_COOLDOWN, nSpecialEncounterCooldown);
}

string GetTravelPlaceableResRef(object oIpoint = OBJECT_SELF)
{
	string sIpointTag = GetTag(oIpoint);
	string sPrefix = GetStringPrefix(sIpointTag);
	string sSuffix = GetStringSuffix(sIpointTag);
	
	string sResult = sPrefix + PLC_TRAVEL_TAG + sSuffix;
	return sResult;
}

string GetDestWPTag(object oPlaceable = OBJECT_SELF)
{
	string sPlcTag = GetTag(oPlaceable);
	string sSuffix = GetStringPrefix(sPlcTag);	//We need to convert fyy_plc_to_fxx
	string sPrefix = GetStringSuffix(sPlcTag);	//to fxx_wp_from_fyy
	
	string sResult = sPrefix + WP_DEST_TAG + sSuffix;
	return sResult;
}

string GetExitWPTag(object oPlaceable = OBJECT_SELF)
{
	string sPlcTag = GetTag(oPlaceable);
	string sPrefix = GetStringPrefix(sPlcTag);
	string sSuffix = GetStringSuffix(sPlcTag);
	
	string sResult = sPrefix + WP_DEST_TAG + sSuffix;
	return sResult;
}

effect EffectShaken()
{
	effect eLink = EffectLinkEffects(EffectAttackDecrease(2), EffectSavingThrowDecrease(SAVING_THROW_ALL, 2)); // fix_Aqvilinus
	effect eResult = EffectLinkEffects(EffectNWN2SpecialEffectFile("fx_confusion"), eLink);

	return eResult;
}

effect EffectOffGuard()
{
	effect eLink = EffectLinkEffects(EffectACDecrease(2), EffectSavingThrowDecrease(SAVING_THROW_ALL, 2)); // fix_Aqvilinus
	effect eResult = EffectLinkEffects(EffectNWN2SpecialEffectFile("fx_confusion"), eLink);
	
	return eResult;
}

void ExitOverlandMap(object oPC)
{
	object oParty = GetFirstFactionMember(oPC, FALSE); 

	while (GetIsObjectValid(oParty))
	{
		PrettyDebug("Removing all effects from " + GetName(oParty));
		RemoveAllEffects(oParty, FALSE);
		
		if(GetIsPC(oParty))
		{
			DeactivateOLMapUI(oParty);
		}
				
		SetLocalInt(oParty, "bLoaded", FALSE); 
		/* Restore the PC's default movement rate	*/
		//float fCurrentRate = GetMovementRateFactor(oParty);
		//float fRestoredRate = (1.00f - fCurrentRate) + fCurrentRate;
		SetMovementRateFactor(oParty, 1.00f);
		
		if(GetScriptHidden(oParty))
			SetScriptHidden(oParty, FALSE);

		if (GetIsSoZ())
			ClearCombatOverrides(oParty);

		SetCurrentPCTerrain(0);
		SetLocalInt(oParty, "pcshrunk", FALSE);
		oParty = GetNextFactionMember(oPC, FALSE);
	}
}

/*--------------------------\
|		Goodie Functions	|
\--------------------------*/
void GerminateGoodies(int nTotal, object oArea = OBJECT_SELF)
{
	int nGoodiesSpawned = 0;

	int bSoZ = GetIsSoZ();

	object oSeed;
	int i = 0;
	if (bSoZ)
	{
		i = GetGlobalInt("00_nGoodieIterator");
		oSeed = GetObjectByTag(IP_GOODIE_SEED_TAG, i);
	}
	else
	{
		oSeed = GetObjectByTag(IP_GOODIE_SEED_TAG);
	}

	if(!GetIsObjectValid(oSeed))
	{
		PrettyDebug("No object seeds for this area!");
		return;
	}

	while(nGoodiesSpawned <= nTotal)		//Repeat this process until we've hit the cap for total goodies.
	{
		int nWeight = GetLocalInt(oSeed, VAR_GOODIES_WEIGHT);
		int j=0;
		while(j < nWeight)				//Create a number of goodies equal to the seed's weight. This allows us to have some
		{
			PrettyDebug("Starting Goodie Loop. j:" + IntToString(j)+ " nWeight:" + IntToString(nWeight));							//seeds weighted more heavily than others.
			int bGoodieMade = CreateGoodie(oSeed);
			if(bGoodieMade)
			{
				PrettyDebug("Created Goodie");
				j++;
				nGoodiesSpawned++;
			}
		}

		++i;									//After you're done with one seed for this iteration, move to the next seed.
		oSeed = GetObjectByTag(IP_GOODIE_SEED_TAG, i);

		if(!GetIsObjectValid(oSeed))			//If we've hit the end of the seed list, return to the first seed.
		{
			oSeed = GetObjectByTag(IP_GOODIE_SEED_TAG);
			i=0;
		}
	}

	if (bSoZ)
		SetGlobalInt("00_nGoodieIterator", i);
}
									
int CreateGoodie(object oSeed)
{
	object oResult;
	string sGoodieTable = GetLocalString(oSeed, VAR_GOODIES_TABLE);
	PrettyDebug("Creating a goodie from the following table:" + sGoodieTable);
	object oArea = GetArea(oSeed);
	
	location lTest = GetGoodieLocation(oSeed);			//Pick a random encounter point near the player.
		
	object oTrigger = GetFirstSubArea(oArea, GetPositionFromLocation(lTest));
	object oSavedTrigger = OBJECT_INVALID;
	
	while( GetIsObjectValid(oTrigger))	//Search through the triggers at the location,
	{											
		if(GetTag(oTrigger) == "nx2_tr_terrain")									//Save off a terrain trigger if we hit one.
			oSavedTrigger = oTrigger;
			
		else if(GetTag(oTrigger) == "nx2_tr_nogoodies")								//Alternately, if we hit a nogoodie trigger don't spawn anything here.
		{
			PrettyDebug("hitting a nogoodie trigger...");
			return FALSE;
		}
		
		oTrigger = GetNextSubArea(oArea);											//(or we've exhausted the list)
	}
	
	oTrigger = oSavedTrigger;														//Now we copy the saved terrain trigger back to oTrigger.
																					//if we never found one, we abort because it will be OBJECT_INVALID.
	if (!GetIsObjectValid(oTrigger))
	{
		PrettyDebug("Trigger is invalid.");
		return FALSE;
	}	
	int nTerrain = GetTerrainType(oTrigger);
	int nRow;
	do{
		PrettyDebug("Searching the goodie table...");
		nRow = GetGoodieRow(sGoodieTable);
	}while(GetIsGoodieValidForTerrain(sGoodieTable, nRow, nTerrain) == FALSE);
		
	string sGoodieRR = Get2DAString(sGoodieTable, VAR_GOODIES_RR_ROW, nRow);
	PrettyDebug("Creating goodie with RR: " + sGoodieRR);	
	oResult = CreateObject( OBJECT_TYPE_PLACEABLE, "nx2_ip_goodie", lTest);		//Create the appropriate goodie
	
	int nDiscoverySkill = Get2DAInt(sGoodieTable, "DISCOVERY_SKILL", nRow);
	int nDiscoveryDC = Get2DAInt(sGoodieTable, "DISCOVERY_DC", nRow);
	string sDiscovery = GetStringByStrRef(Get2DAInt(sGoodieTable, "DISCOVERY_STRREF", nRow));

	SetLocalInt(oResult, VAR_GOODIES_DISC_SKILL, nDiscoverySkill);
	SetLocalInt(oResult, VAR_GOODIES_DISC_DC, nDiscoveryDC);
	SetLocalInt(oResult, "nRow", nRow);					//Set the proper variables on the object
	SetLocalString(oResult, "sGoodieTable", sGoodieTable);
	
	SetLocalString(oResult, VAR_GOODIES_DISC_STR, sDiscovery);
		
	return TRUE;
}

void SetGoodieData(object oGoodie, string sGoodieTable, int nRow)
{
	string sName = GetStringByStrRef(Get2DAInt(sGoodieTable, "NAME_STRREF", nRow));

	string sActivate = GetStringByStrRef(Get2DAInt(sGoodieTable, "ACTIVATE_STRREF", nRow));
	
	int nRewardGold = Get2DAInt(sGoodieTable, "REWARD_GOLD", nRow);
	int nRewardXP = Get2DAInt(sGoodieTable, "REWARD_XP", nRow);
	string sRewardItems = Get2DAString(sGoodieTable, "REWARD_ITEMS", nRow);
	string sRewardGoods = Get2DAString(sGoodieTable, "REWARD_GOODS", nRow);
	string sRewardRareRes = Get2DAString(sGoodieTable, "REWARD_RARERES", nRow);
	
	SetLocalString(oGoodie, VAR_GOODIES_NAME, sName);	
		
	SetLocalString(oGoodie, VAR_GOODIES_AC_STR, sActivate);
	
	SetLocalInt(oGoodie, VAR_GOODIES_GOLD, nRewardGold);
	SetLocalInt(oGoodie, VAR_GOODIES_XP, nRewardXP);
	SetLocalString(oGoodie, VAR_GOODIES_ITEMS, sRewardItems);
	SetLocalString(oGoodie, VAR_GOODIES_GOODS, sRewardGoods);
	SetLocalString(oGoodie, VAR_GOODIES_RARERES, sRewardRareRes);
}

int GetIsGoodieValidForTerrain(string sGoodieTable, int nRow, int nTerrain)
{
	string sTerrainList = Get2DAString(sGoodieTable, VAR_GOODIES_TERRAIN_ROW, nRow);
	int i = 0;
	int nValidTerrain = GetIntParam(sTerrainList, i);
	
	while(nValidTerrain)
	{
		//PrettyDebug("Checking the terrain type...");
		if (nTerrain == nValidTerrain)						//If the terrain we are searching for matches one of the listed types
			return TRUE;									//Return TRUE.
		
		else												//Otherwise move to the next element.
		{
			++i;
			nValidTerrain = GetIntParam(sTerrainList, i);
		}
	}
	
	return FALSE;											//If we parsed the entire list without returning TRUE, then nTerrain 
}															//is not valid for the current Goodie we are testing, so return FALSE.

void AwardGoodieItems(object oUser, string sItems)
{
	string sParam = GetStringParam(sItems, 0);
	int i=0;
	
	while(sParam != "")
	{
		int nNum = StringToInt( GetStringParam(sItems, i+1) );	//The NEXT parameter we are setting equal to the number to create.
		
		if ( nNum != 0 )										//if nNum is a valid int, we are going to use it as an iterator.
		{
			int j;
			for( j = 0; j < nNum; j++)
			{
				CreateItemOnObject(sParam, oUser);
			}
			
			i += 2;												//We want to increment i by 2 in this case to skip the iterator.
		}
		
		else
		{
			CreateItemOnObject(sParam, oUser);
			++i;
		}
		
		sParam = GetStringParam(sItems, i);
	}
}

location GetGoodieLocation(object oSeed)
{
	location lLocation, lSafe;
	vector vTest, vSafe;
	float fRadius = GetLocalFloat(oSeed, VAR_GOODIES_RADIUS);		
	do{
		lLocation = GetRandomLocationAroundObject(fRadius, oSeed, FALSE);
		lSafe = CalcSafeLocation(GetFirstPC(), lLocation, 1.0, FALSE, FALSE);
		//PrettyDebug("TestingVectors...");		
		vTest = GetPositionFromLocation(lLocation);
		vSafe = GetPositionFromLocation(lSafe);
	}while (!CompareVectors2D(vTest, vSafe));

	return lSafe;
}

int GetGoodieRow(string sTable)
{
	int nRow;
		
	nRow = Random(GetNumValidRows(sTable))+1;	
	return nRow;
}

/*--------------------------\
|	OL Map UI Functions		|
\--------------------------*/

//Activates the OL Map UI for oPC. This closes the default UI Elements that are intended to be hidden 
//on the OL Map and opens the new OL UI objects for the pc.
void ActivateOLMapUI(object oPC)
{
	//Close all of the Ingame UI elements we want hidden.
	CloseGUIScreen(oPC, GUI_SCREEN_DEFAULT_PARTY_BAR);
	CloseGUIScreen(oPC, GUI_SCREEN_DEFAULT_HOTBAR);
	CloseGUIScreen(oPC, GUI_SCREEN_DEFAULT_HOTBAR_2);
	CloseGUIScreen(oPC, GUI_SCREEN_DEFAULT_HOTBAR_V1);
	CloseGUIScreen(oPC, GUI_SCREEN_DEFAULT_HOTBAR_V2);
	CloseGUIScreen(oPC, GUI_SCREEN_DEFAULT_MODEBAR);
	CloseGUIScreen(oPC, GUI_SCREEN_DEFAULT_PLAYERMENU);
	CloseGUIScreen(oPC, GUI_SCREEN_DEFAULT_ACTIONQUEUE);

	if (GetIsSoZ())
		CloseGUIScreen(oPC, "SCREEN_VOICEMENU");

	//Open the new Custom UI Elements for the OL Map.
	DisplayGuiScreen(oPC, GUI_SCREEN_OL_PARTY_BAR, FALSE, XML_OL_PARTY_BAR);
	DisplayGuiScreen(oPC, GUI_SCREEN_OL_FRAME, FALSE, XML_OL_FRAME);
	DisplayGuiScreen(oPC, GUI_SCREEN_OL_MENU, FALSE, XML_OL_MENU);
	UpdateClockForAllPlayers();
}

//Deactivates the OL Map UI for oPC. This closes the OL Map UI Elements 
//and re-opens the default UI objects for the PC.
void DeactivateOLMapUI(object oPC)
{
	//Close all of the Ingame UI elements we want hidden.
	CloseGUIScreen(oPC, GUI_SCREEN_OL_PARTY_BAR);
	CloseGUIScreen(oPC, GUI_SCREEN_OL_FRAME);
	CloseGUIScreen(oPC, GUI_SCREEN_OL_MENU);
	
	//Open the new Custom UI Elements for the OL Map.
	DisplayGuiScreen(oPC, GUI_SCREEN_DEFAULT_PARTY_BAR, FALSE);
	DisplayGuiScreen(oPC, GUI_SCREEN_DEFAULT_HOTBAR, FALSE);
	DisplayGuiScreen(oPC, GUI_SCREEN_DEFAULT_HOTBAR_2, FALSE);
	DisplayGuiScreen(oPC, GUI_SCREEN_DEFAULT_HOTBAR_V1, FALSE);
	DisplayGuiScreen(oPC, GUI_SCREEN_DEFAULT_HOTBAR_V2, FALSE);
	DisplayGuiScreen(oPC, GUI_SCREEN_DEFAULT_MODEBAR, FALSE);
	DisplayGuiScreen(oPC, GUI_SCREEN_DEFAULT_PLAYERMENU, FALSE);
	DisplayGuiScreen(oPC, GUI_SCREEN_DEFAULT_ACTIONQUEUE, FALSE);
	//UpdateClockForAllPlayers(); // Commented out as a test
}