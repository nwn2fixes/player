// ginc_restsys
/*
	Based on x2_inc_restsys Created By: Georg Zoeller

    Wandering Monster Restsystem Include
*/
// ChazM 4/5/07 added constants and WMGetRestStringRef()
// ChazM 4/11/07 Moved GUI related constants and functions here.
// ChazM 4/12/07 Removed sleep effect
// ChazM 4/13/07 added RestSendMessage(), GetDawnHour(), GetDuskHour(), added some constants
// ChazM 5/8/07 Day/night encounters now set up independently.
// ChazM 5/9/07 various fixes
// ChazM 5/9/07 disabled wm will now report as safe. changed a var name.
// ChazM 6/14/07 added increasing threat, pre-generated rolls, min threshold, and new levels of imminent and extremely dangerous
// ChazM 6/29/07 updated WMRestEncounterCheck(), added SinglePartyWMRestEncounterCheck()
// kevL's 2019.02.14 - merge this with the SoZ Campaign 'ginc_overland' so it's suitable for /Override.

#include "ginc_debug"
#include "ginc_math"
#include "ginc_2da"
#include "ginc_vars"
#include "ginc_overland"
#include "x2_inc_switches"

// void main(){}

//------------------------------------------------------------------------------
//  Structs
//------------------------------------------------------------------------------

struct wm_struct
{
    string sTable;
    string sEncounter1;
    string sEncounter2;
    string sEncounter3;
    int    nEnc1Prob;
    int    nEnc2Prob;
    int    nFeedBackStrRefSuccess;
    int    nFeedBackStrRefFail;
    int    nRowNumber;
};

//------------------------------------------------------------------------------
//  Constants
//------------------------------------------------------------------------------
//================================================================================
// Default values 
const float WM_DEFAULT_SPAWN_POINT_MAX_DIST 		= 25.0f;
const float WM_DEFAULT_SPAWN_POINT_PREFERRED_DIST	= 0.0f;

const float WM_DEFAULT_SPAWN_DOOR_MAX_DIST 			= 20.0f;

const float WM_DEFAULT_SPAWN_LOC_MIN_DIST 			= 5.0f;
const float WM_DEFAULT_SPAWN_LOC_MAX_DIST 			= 20.0f;

const int WM_DEFAULT_LISTEN_CHECK 					= 15;

// * Default 2DA Name to look data up. Can be overwritten with a global variable
// * named WM_2DA_NAME on the module to point to a different 2da
const string WM_DEFAULT_2DA_FILE 				= "restsys_wm_tables";

//================================================================================
// Variable names on the area
const string VAR_WM_ENC_TABLE_DAY 				= "WM_ENC_TABLE_DAY";		// encounter table to use during the day
const string VAR_WM_ENC_TABLE_NIGHT				= "WM_ENC_TABLE_NIGHT";		// encounter table to use at night
const string VAR_WM_ENC_PROB_DAY 				= "WM_ENC_PROB_DAY";		// % chance of day encounter (these default to 2da entry if blank)
const string VAR_WM_ENC_PROB_NIGHT 				= "WM_ENC_PROB_NIGHT";		// % chance of night encounter

const string VAR_WM_DISABLED					= "WM_DISABLED";			// TRUE = disable all WM encounters in the area.  Also works on modules and globally for the campaign
const string VAR_WM_AREA_LISTENCHECK 			= "WM_AREA_LISTENCHECK";
const string VAR_WM_USE_APPEAR_ANIMATIONS		= "WM_USE_APPEAR_ANIMATIONS";

// Conrolling where to spawn encounters - If not filled, these all default to reasonable values.
// These define how we should use any placed spawn points
const string VAR_WM_SPAWN_POINTS_DISABLED		= "WM_SPAWN_POINTS_DISABLED"; 	// TRUE = don't use spawn points
const string VAR_WM_SPAWN_POINT_MAX_DIST		= "WM_SPAWN_POINT_MAX_DIST"; 	// Max dist spawn point can be to be used for encounter
const string VAR_WM_SPAWN_POINT_PREFERRED_DIST	= "WM_SPAWN_POINT_PREFERRED_DIST"; // distance to shoot for when creating encounter

// These define how doors should be used for spawning wandering monsters.
const string VAR_WM_SPAWN_DOORS_DISABLED		= "WM_SPAWN_DOORS_DISABLED"; 	// TRUE = don't use doors
const string VAR_WM_SPAWN_DOOR_MAX_DIST			= "WM_SPAWN_DOOR_MAX_DIST";		// Max dist door can be to be used for encounter

// When spawn points and doors are not used, we then try to spawn at some distance away.
const string VAR_WM_SPAWN_LOC_MIN_DIST			= "WM_SPAWN_LOC_MAX_DIST";
const string VAR_WM_SPAWN_LOC_MAX_DIST			= "WM_SPAWN_LOC_MAX_DIST";

const string VAR_WM_ENC_CUM_INCREASE_L			= "WM_ENC_CUM_INCREASE_L";	// low amount to increase
const string VAR_WM_ENC_CUM_INCREASE_H			= "WM_ENC_CUM_INCREASE_H";	// high amount to increase
const string VAR_WM_ENC_CUM_TOTAL				= "WM_ENC_CUM_TOTAL";		// amount increased so far

// (Not yet implemented)
// Changes the encounter size by the specified % for all encounters in the area.  Defaults to 0.
// This is calculated in terms of the number of monsters in the particular encounter.  
// example: 4 monsters in encounter. WM_ENC_SIZE_CHANGE% = 50 will create 6 monsters, WM_ENC_SIZE_CHANGE% = -25 will create 3 monsters
// negative values won't reduce the number of creatures in encounter below 1.
const string VAR_WM_ENC_SIZE_CHANGE_PERCENT		= "WM_ENC_SIZE_CHANGE%";	


//================================================================================
// * Variable that holds the wandering monster 2da filename
const string MODULE_VAR_WANDERING_MONSTER_2DA 	= "WM_2DA_NAME";


//================================================================================
// variable names on the area used internally

const string VAR_WM_AREA_TABLE					= "WM_ENC_TABLE"; // require suffixes - must math the vars above.
const string VAR_WM_AREA_PROB	 				= "WM_ENC_PROB";

const string VAR_WM_DAY_SUFFIX					= "_DAY";
const string VAR_WM_NIGHT_SUFFIX				= "_NIGHT";

const string VAR_WM_ROW_SCAN_PTR				= "WM_ROWSCANPTR";

//const string VAR_WM_INITIALIZED					= "WM_INIT";	
const string VAR_WM_AREA_FLOODPROTECTION 		= "WM_AREA_FLOODPROTECTION";

const string VAR_WM_AMBUSH						= "WM_AMBUSH"; // on pc

//================================================================================
// 2da fields
const string RSWMT_TABLE_NAME_COL 		= "TableName";
const string RSWMT_COMMENT_COL 			= "Comment";
//const string RSWMT_LISTEN_DC_COL		= "ListenCheckDC";
const string RSWMT_SUCCESS_COL 			= "FeedBackStrRefSuccess";
const string RSWMT_FAIL_COL 			= "FeedBackStrRefFail";
//const string RSWMT_BASE_PROBABILITY_COL = "BaseProbability";
const string RSWMT_ENC1_RESREFS_COL 	= "Enc1_ResRefs";
const string RSWMT_ENC1_PROB_COL 		= "Enc1_Prob";
const string RSWMT_ENC2_RESREFS_COL 	= "Enc2_ResRefs";
const string RSWMT_ENC2_PROB_COL 		= "Enc2_Prob";
const string RSWMT_ENC3_RESREFS_COL 	= "Enc3_ResRefs";


//================================================================================
// Misc
// * If an object with this tag is found, monsters will spawn from there
// * if they cannot find a door or the door system is disabled
const string WM_SPAWNSPOT_TAG 			= "restsys_spawn";

const string WM_AMBUSH_SCRIPT_NAME		= "gb_restsys_ambush";

// * This event is sent to the spawnspot placeable to allow it to play a
// * certain animation when monsters spawn in
const int WM_SPAWNSPOT_EVENTID 			= 2011;

// * Minimum time between spawns in seconds (default = 60.0f)
const float WM_FLOOD_PROTECTION_PERIOD 	= 10.0f;

const int WMT_INVALID_TABLE 			= 0;        // Row number of NO_TABLE_SETTable

const int WMT_DEFAULT_FEEDBACK_FAIL 	= 83306;	// Default StrRef when failing listen check check
const int WMT_DEFAULT_FEEDBACK_SUCCESS 	= 83307;   	// Default StrRef when succeeding listen check

//================================================================================
// CheckWanderingMonster results:
const int WM_CHECK_CANT_REST 	= -1;
const int WM_CHECK_NO_AMBUSH 	= 0;
const int WM_CHECK_AMBUSH 		= 1;


const int STR_REF_REST_IMMINENT_DANGER		= 206063;	// "This place is in imminent danger."
const int STR_REF_REST_EXTREME_DANGER		= 206064;	// "This is an extremely dangerous place to rest."
const int STR_REF_REST_VERY_DANGEROUS		= 186202;	// "This is a very dangerous place to rest."	
const int STR_REF_REST_DANGEROUS			= 186203;	// "This is a dangerous place to rest."
const int STR_REF_REST_SOMEWHAT_DANGEROUS 	= 186204;	// "This is a somewhat dangerous place to rest."
const int STR_REF_REST_RELATIVELY_SAFE		= 186205;	// "This is a relatively safe place to rest."
const int STR_REF_REST_SAFE					= 186206;	// "This is a safe place to rest."


// percentages corresponding to the level of safety
const int REST_IMMINENT_DANGER			= 100;	
const int REST_EXTREME_DANGER			= 80;
const int REST_VERY_DANGEROUS			= 60;	
const int REST_DANGEROUS				= 40;
const int REST_SOMEWHAT_DANGEROUS 		= 20;
const int REST_RELATIVELY_SAFE			= 1;
const int REST_SAFE						= 0;


//================================================================================
// === GUI Related ===

const string sSCREEN_GUI_REST 			= "SCREEN_MESSAGEBOX_REST"; // The name by which we will refer to the GUI panel
const string sFILE_NAME_GUI_REST		= "rest.xml";  // the XML file
const string REST_BUTTON 				= "REST_GUI_STATE_BUTTON_REST";
const string WAIT_BUTTON 				= "REST_GUI_STATE_BUTTON_WAIT";
const string REST_LABEL 				= "REST_GUI_TEXT_BUTTON_REST";
const string WAIT_LABEL 				= "REST_GUI_TEXT_BUTTON_WAIT";

const string GUI_REST_SCRIPT_NAME		= "gui_rest"; // script to run if rest selected
const int STR_REF_REST 					= 186216; // Set up camp and rest for 8 hours.
const int STR_REF_WAIT_DUSK 			= 186217; // Wait here until dusk.
const int STR_REF_WAIT_DAWN 			= 186218; // Wait here until dawn.

const int STR_REF_MUST_GATHER_FOR_REST 	= 186230; // You must gather the party before stopping to rest.
const int STR_REF_REST_STARTED			= 7952;
const int STR_REF_REST_CANCELLED		= 7957;
const int STR_REF_REST_FINISHED			= 7953;

const string VAR_REST_CHOICE  			= "N2_REST_CHOICE"; // name of local storing the rest choice.
const string VAR_REST_NOW				= "N2_REST_NOW";
const string VAR_REST_REPORT_CANCEL		= "N2_REST_REPORT_CANCEL";


//------------------------------------------------------------------------------
//                    * * *   P R O T O T Y P E S * * *
//------------------------------------------------------------------------------

// * Change the probability of encountering a wandering monster for an area
//   oArea - the Area
//   sTableName - The name of the encounter table (TableName Column in 2da)
//
// * NOTE: You can call WMSetAreaProbability later to change the probability
//       of having an encounter
void WMSetAreaProbability(object oArea, int nDayPercent, int nNightPercent);

// *  Call this to define the encounter table to use with the wandering monster
// *  system.
//  oArea - the Area
//  sTableName - The name of the encounter table (TableName Column in 2da)
//  bUseDoors -  Monsters will spawn behind the next not-locked door, open them
//               and move onto the pc (default = TRUE )
//  nListenCheckDC - The DC to beat in an listen check in order to wake up early.
//                  (default = -1, use value in 2da)
//
// *  NOTE: You can call WMSetAreaProbability later to change the probability
//    of having an encounter
//void WMSetAreaTable(object oArea, string sSuffix, string sTableName, int bUseDoors = FALSE, int nListenCheckDC = -1);

// * Returns TRUE if oArea has a wandering monster table set. Use WMSetAreaTable to
// * set a wandering monster table on an area
// int WMGetAreaHasTable(object oArea);
//int WMGetAreaHasTable(object oArea, string sSuffix="");


// * Returns TRUE if a WM_USE_APPEAR_ANIMATIONS has been set to TRUE on the area
// * making all creatures appearing within use their appear animations
int WMGetUseAppearAnimation(object oArea);

// * Returns TRUE if oArea has the Wandering Monster System disabled
int WMGetWanderingMonstersDisabled(object oArea);

// * Sets if oArea has the Wandering Monster System disabled
void WMSetWanderingMonstersDisabled(object oArea, int bDisabled = FALSE );

// * Wandering Monster System, Check for wandering monster
//   oPC - the player who triggered the check
//
// * This will check if the player has triggered a wandering monster
// * and return TRUE if yes.
//
// * To be used in the OnRest event handler.  It will also setup the
// * encounter so if ExecuteScript (DoWanderingMonster) is called on
// * a PC, the encounter will start.
int WMCheckForWanderingMonster(object oPC);

// *  Reads all encounter tables from 2da specified in WM_2DA_NAME and caches them
// *  to LocalVariables to speed up access to them. This function is intended to be used
// *  in an OnModuleLoad event script
void WMBuild2DACache();

// * Setup the necessary variables for the restsys_ambus script
// * You probably won't ever need this function as it is used internally by the system, but you could
// * use it to build your own monster ambush (just call WMRunAmbush() to execute)
//     oPC - The player to be ambushed
//     sMonsters - one or more monster ResRefs, comma seperated with no whitespaces in between
// * Examples:
//     WMSetupAmbush(GetEnteringObject(), "nw_dog,nw_dog") for multiple enemies
//     WMSetupAmbush(GetEnteringObject(), "nw_badger") for a single enemy
void WMSetupAmbush(object oPC, string sMonsters);

// * This command runs the actual wandering monster ambush on the pc, using the data stored
// * by WMSetupAmbush. It is called by restsys_ambus.nss.
void WMRunAmbush(object oPC);

// new! returns probability set for this area.
int WMGetWanderingMonsterProbability(object oPC);

// * Placeholder at the moment - handles sleep and multiplayer code
// * If an ambush is in progress it will return FALSE so resting can be disabled
// * Fades Screen to Black for PC
int WMStartPlayerRest(object oPC);

// * Removes the cutscene blackness, etc
// * Called after a rest is done from OnPlayerRest Event
void WMFinishPlayerRest(object oPC, int bRestCanceled = FALSE)   ;

// * Returns the DC to beat in a listen check to wake up. Its defined in the 2da
// * but can be overwritten in WMSetAreaTable)
int WMGetAreaListenCheck(object oArea);

// * Do a listen check against the designer defined DC for waking up in that area
// * See WMSetAreaTable() on how to set the DC.
// * Returns TRUE if check was successful
int WMDoListenCheck(object oPC);

// * Define the name of the 2da file which is used for the wandering monster
// * system
void WMSet2DAFileName(string s2DAName);

// get the wandering monster 2DA file name
string WMGet2DAFileName();


int WMGetRestStringRef(int nDangerLevel);


// === GUI Related ===
void SetWaitTextStringRef(object oPC);
void SetRestOptionState(object oPlayerObject, int iState);
int GetRestMessageStrRef(object oPC);
void DisplayRestGUI(object oPC);


//------------------------------------------------------------------------------
//                  * * *   I M P L E M E N T A T I O N * * *
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
//                           Private Functions
//------------------------------------------------------------------------------
void TimedCumTotalDecay(object oArea, int nDecay)
{
	int nTimer = GetLocalInt(oArea, "bDecayTriggered");
	if(nTimer)
	{
		return;
	}
	
	else
	{
		ModifyLocalInt(oArea, VAR_WM_ENC_CUM_TOTAL, nDecay);
		SetLocalInt(oArea,  "bDecayTriggered", TRUE);
		DelayCommand(30.0f, SetLocalInt(oArea, "bDecayTriggered", FALSE));
	}
}

float GetDefaultedLocalFloat(object oObject, string sVarName, float fDefaultValue)
{
	float fRet = GetLocalFloat(oObject, sVarName);
	if (fRet == 0.0f)
		fRet = fDefaultValue;
	return (fRet);		
}

// DayTime is either Day or Dawn while NightTime is Night & Dusk
int GetIsDayTime()
{
	if (GetIsDay() || GetIsDawn())
		return TRUE;
	else
		return FALSE;		
}

//------------------------------------------------------------------------------
// Debug Output, remove all calls to this for version
//------------------------------------------------------------------------------
void WMDebug (string sWrite)
{
   // WriteTimestampedLogEntry("***WM Debug: "+sWrite);
}


//----------------------------------------------------------------------------
// Define the name of the 2da file which is used for the wandering monster system
void WMSet2DAFileName(string s2DAName)
{
    SetLocalString(OBJECT_SELF, MODULE_VAR_WANDERING_MONSTER_2DA, s2DAName);
}

//------------------------------------------------------------------------------
// Retrieve the 2da to use for the system
string WMGet2DAFileName()
{
    //Check if the user has overwritten the 2da to use
    string s2DA = GetLocalString(GetModule(), MODULE_VAR_WANDERING_MONSTER_2DA);
    if (s2DA == "")
    {
       s2DA = WM_DEFAULT_2DA_FILE;     // Not overwritten, take default (defined in the header of this file)
    }
    return s2DA;
}


struct wm_struct GetWMTableEntry(int nCurRow, int bAllData = FALSE)
{
    // Determine which 2da to load
    string s2DA = WMGet2DAFileName();

    struct wm_struct stRet;
	// PrettyDebug("GetNextWMTableEntry() nCurRow=" + IntToString(nCurRow));
    //stRet.sTable = GetStringLowerCase(Get2DAString(s2DA, RSWMT_TABLE_NAME_COL, nCurRow));
    stRet.sTable = Get2DAString(s2DA, RSWMT_TABLE_NAME_COL, nCurRow);
	// PrettyDebug("GetNextWMTableEntry() stRet.sTable=" + stRet.sTable);

    if (stRet.sTable == "") // last record, end
    {
        stRet.nRowNumber = -1 ;
        return stRet;
    }
    //stRet.nProbability = StringToInt(Get2DAString(s2DA, RSWMT_BASE_PROBABILITY_COL, nCurRow));
    //stRet.nListenCheckDC = StringToInt(Get2DAString(s2DA, RSWMT_LISTEN_DC_COL, nCurRow));
	
    if (bAllData) // if requested, return all other lines in the struct as well ... slooow
    {
        stRet.sEncounter1 = Get2DAString(s2DA, RSWMT_ENC1_RESREFS_COL, nCurRow);
        stRet.sEncounter2 = Get2DAString(s2DA, RSWMT_ENC2_RESREFS_COL, nCurRow);
        stRet.sEncounter3 = Get2DAString(s2DA, RSWMT_ENC3_RESREFS_COL, nCurRow);
		// PrettyDebug("GetNextWMTableEntry() stRet.sEncounter1=" + stRet.sEncounter1);
 
        // Get the probability for monster type 1 and 2, if not supplied take 33%
        stRet.nEnc1Prob = StringToInt(Get2DAStringOrDefault(s2DA, RSWMT_ENC1_PROB_COL, nCurRow, "33"));
        stRet.nEnc2Prob = StringToInt(Get2DAStringOrDefault(s2DA, RSWMT_ENC2_PROB_COL, nCurRow, "33"));

        // Listen Check Notices
        stRet.nFeedBackStrRefSuccess = StringToInt(Get2DAStringOrDefault(s2DA, RSWMT_SUCCESS_COL, nCurRow,IntToString(WMT_DEFAULT_FEEDBACK_SUCCESS))); ;
        stRet.nFeedBackStrRefFail = StringToInt(Get2DAStringOrDefault(s2DA, RSWMT_FAIL_COL, nCurRow,IntToString(WMT_DEFAULT_FEEDBACK_FAIL))); ;

    }
    stRet.nRowNumber = nCurRow;
    return stRet;
}

//------------------------------------------------------------------------------
// This function returns a wm_struct of the row number currently set in LocalInt
// WM_ROWSCANPTR
// on the Module. if bAllData is true, it will read all columns of the 2da, if not,
// it will just return the RowNumber and Probability columns.
// This is the place where data gets read from the 2da... the only place
//
// Use after GetFirstWMTableEntry until wm_struct.nRowNumber = -1
//------------------------------------------------------------------------------
struct wm_struct GetNextWMTableEntry(int bAllData = FALSE)
{
    // Which row to start from...
    int nCurRow = GetLocalInt(GetModule(), "WM_ROWSCANPTR");
	
	struct wm_struct stRet = GetWMTableEntry(nCurRow, bAllData);
	
    nCurRow++;
    SetLocalInt(GetModule(),"WM_ROWSCANPTR",nCurRow); // point to the next row
    return stRet;
}

struct wm_struct GetFirstWMTableEntry(int bAllData = FALSE)
{
  SetLocalInt(GetModule(),"WM_ROWSCANPTR",0); // set the pointer to the first row
  return  GetNextWMTableEntry(bAllData);
}

//------------------------------------------------------------------------------
// returns a FULL Data wm_struct of row nNo from the wandering monster 2da file
//------------------------------------------------------------------------------
struct wm_struct GetWMTableEntryByIndex(int nRow)
{
  SetLocalInt(GetModule(),"WM_ROWSCANPTR", nRow);
  return  GetNextWMTableEntry(TRUE);
}

/*
//------------------------------------------------------------------------------
// return a wm_struct of the data in the row with TableName sName in the 2da
//------------------------------------------------------------------------------
struct wm_struct GetWMStructByName(string sName, int bAllData = FALSE)
{
    string s2DA = WMGet2DAFileName();
    struct wm_struct stRet;
    //sName = GetStringLowerCase(sName);
    // check if there is a cached 2da row with this name
	int nRow = GetCached2DAIndex(s2DA, RSWMT_TABLE_NAME_COL, sName);

    if (nRow != WMT_INVALID_TABLE)
    {
        stRet.nRowNumber = nRow;
        stRet.nProbability = StringToInt(GetCached2DAEntry(s2DA, RSWMT_BASE_PROBABILITY_COL, nRow));

        // in case all data is requested, read them from the 2da
        if (bAllData)
        {
             stRet = GetWMTableEntryByIndex(nRow); // fetch full data from 2da
        }
    }
    else
    {
        stRet.nRowNumber = WMT_INVALID_TABLE;
        stRet.nProbability = 0;
    }
    return stRet;
}
*/

//------------------------------------------------------------------------------
// Georg Zoeller, 2003-05-29
// Reads all encounter tables from 2da specified in WM_2DA_NAME and caches
// them to LocalVariables to speed up access to them.
// This function is intended to be used an OnModuleLoad event script
//------------------------------------------------------------------------------
void WMBuild2DACache()
{
	//SpawnScriptDebugger();
	string s2DA = WMGet2DAFileName();
	Build2DAIndexCache(s2DA, RSWMT_TABLE_NAME_COL); // allows fast lookup of row index on tablename.

    //WMDebug("WMBuild2DACache() cached " + IntToString(nCount)+ " area names ");
}

int GetIntTimeOfDayValue(int nDayValue, int nNightValue)
{
	if (GetIsDayTime())
		return (nDayValue);
	else
		return (nNightValue);		
}

string GetStringTimeOfDayValue(string sDayValue, string sNightValue)
{
	if (GetIsDayTime())
		return (sDayValue);
	else
		return (sNightValue);		
}

// This suffix is appened to variable names
string GetTimeOfDaySuffix(string sSuffix="")
{
	if (sSuffix == "")
		sSuffix = GetStringTimeOfDayValue(VAR_WM_DAY_SUFFIX, VAR_WM_NIGHT_SUFFIX);
	return (sSuffix);
}		

// returns the variable storing the table name for day or night
// if sSuffix is blank, the current time will be used for returning the var
string GetTableNameVar(string sSuffix="")
{
	return (VAR_WM_AREA_TABLE + GetTimeOfDaySuffix(sSuffix));
}

string GetProbabilityVar(string sSuffix="")
{
	return (VAR_WM_AREA_PROB + GetTimeOfDaySuffix(sSuffix));
}

/*
int GetIsInitialized(object oArea, string sSuffix="")
{
	int iInit = GetLocalInt(oArea, VAR_WM_INITIALIZED + GetTimeOfDaySuffix(sSuffix));
	return (iInit);
}

void SetIsInitialized(object oArea, string sSuffix="", int bInit=TRUE)
{
	SetLocalInt(oArea, VAR_WM_INITIALIZED + GetTimeOfDaySuffix(sSuffix), bInit);
}
*/

//------------------------------------------------------------------------------
// Returns a wm_struct containing the full wandering monster table
// for the selected area.
//------------------------------------------------------------------------------
struct wm_struct WMGetAreaMonsterTable(object oArea)
{
	// SpawnScriptDebugger();
    string s2DA = WMGet2DAFileName();
   	string sTableName	= GetLocalString(oArea, GetTableNameVar());
	int nRow = GetCached2DAIndex(s2DA, RSWMT_TABLE_NAME_COL, sTableName);

    struct wm_struct stTable = GetWMTableEntryByIndex(nRow);
    return stTable;
}

//--------------------------------------------------------------------------
// Get the probability for a wandering monster depending on the time of day
//--------------------------------------------------------------------------
int WMGetWanderingMonsterProbability(object oPC)
{
	object oArea = GetArea(oPC);

	if (GetIsSoZ())
	{
		object oTrigger = GetNearestTerrainTrigger(oPC);
		int nEncounterChance	= GetLocalInt(oTrigger, VAR_ENC_CHANCE);
		int nGameDifficulty		= GetGameDifficulty();
		
		//Encounter chance modifiers:
		//Easy: -5% chance.
		//D&D Harcore: +5% Chance.
		//Difficult: +10% Chance.
		if( nGameDifficulty <= GAME_DIFFICULTY_EASY )
		{
			nEncounterChance -= 5;
		}
		
		else if (nGameDifficulty == GAME_DIFFICULTY_CORE_RULES )
		{
			nEncounterChance += 5;
		}
		
		else if ( nGameDifficulty == GAME_DIFFICULTY_DIFFICULT )
		{
			nEncounterChance += 10;
		}
		
		nEncounterChance *= 2;	//Weighting terrain more heavily for random encounters.
		int nCumTotal = GetLocalInt(oArea, VAR_WM_ENC_CUM_TOTAL);
		if(GetIsNight())
		{
			nEncounterChance += 10;
		}
		int nRet = (nEncounterChance + nCumTotal);
		
		return nRet;
	}
	else
	{
	    int nProb = GetLocalInt(oArea, GetProbabilityVar());
		int nCumProb = GetLocalInt(oArea, VAR_WM_ENC_CUM_TOTAL);
		nProb += nCumProb;
		return (nProb);
	}
}

//------------------------------------------------------------------------------
// Returns a string containing or more wandering monsters
// from the encounter table currently active for oPC's area
//------------------------------------------------------------------------------
string WMGetWanderingMonsterFrom2DA(object oPC)
{
    struct wm_struct stTable = WMGetAreaMonsterTable(GetArea(oPC));
    string sEncounter;
 
	int nEnc1Prob   = stTable.nEnc1Prob;
	int nEnc2Prob   = stTable.nEnc2Prob;
	
	// determine which monster to spawn based on the probablility
	int nRoll = d100();
	if(nRoll <= nEnc1Prob)
	    sEncounter = stTable.sEncounter1;
	else if (nRoll <= nEnc1Prob + nEnc2Prob)
	    sEncounter = stTable.sEncounter2;
	else
	    sEncounter = stTable.sEncounter3;
		
	// PrettyDebug("WMGetWanderingMonsterFrom2DA() sEncounter=" + sEncounter);
	
    return sEncounter;
}

// find object by tag from oPC closest to preferred distance and within fMinDist and fMaxDist
object GetPreferredObjectInRange(object oPC, string sTag, float fPreferredDist, float fMinDist, float fMaxDist)
{
	int i = 1;
	object oSpot = GetNearestObjectByTag(sTag, oPC, i);
	object oPrevSpot;
	float fDist, fPrevDist;
	float fDistFromPrefferred, fPrevDistFromPrefferred;
	int bSpotFound = FALSE;
	
	// while we have a spot to look at and haven't yet found our preferred spot...
	while ((oSpot!= OBJECT_INVALID) && (bSpotFound == FALSE))
	{
		fPrevDist = fDist;
		fDist = GetDistanceBetween(oSpot,oPC);
		// PrettyDebug("Dist from spot " + GetName(oSpot) + " to PC is " + FloatToString(fDist));
		
		// we are beyond Max distance, so stop looking, and set spot to the previous spot
		if (fDist > fMaxDist)
		{
			oSpot = oPrevSpot;
			bSpotFound = TRUE;
		}
		// We've exceeded the preferred distance, so use either this or the previous one,
		// whichever is closer.
		else if (fDist > fPreferredDist)
		{
			// was the previous spot better than this one?
			if (oPrevSpot != OBJECT_INVALID)
			{
				fDistFromPrefferred 	= fabs(fDist - fPreferredDist);
				fPrevDistFromPrefferred = fabs(fPrevDist - fPreferredDist);
				if (fPrevDistFromPrefferred < fDistFromPrefferred)
					oSpot = oPrevSpot;
			}
			bSpotFound = TRUE;
		}
		else
		{			
			// Save this spot and get the Next Spot
			oPrevSpot = oSpot;
			i++;
			oSpot = GetNearestObjectByTag(sTag, oPC, i);
		}
	}
	// PrettyDebug("GetPreferredObjectInRange: returns " + GetName(oSpot));
	return (oSpot);
}

// 


//------------------------------------------------------------------------------
// Calulates the best ambush spot for the monster's using the area preset values
// If a placeable/waypoint is found, it will be stored as object in
// WM_AMBUSH_SPOT for later retrival
// If a door is used as spawnspot, it will be stored in WM_AMBUSH_DOOR
// for later retrieval
//------------------------------------------------------------------------------
location WMGetAmbushSpot(object oPC)
{
	object oArea = GetArea(oPC);
	location lRet;
	
	// Check Spawnpoints		
	int bSpawnPointDisabled = GetLocalInt(GetArea(oPC), VAR_WM_SPAWN_POINTS_DISABLED);
	if (!bSpawnPointDisabled)
	{
		//float fPreferredDist = GetLocalFloat(oArea, VAR_WM_SPAWN_POINT_PREFERRED_DIST);
		//if (fPreferredDist == 0.0f)
		//	fPreferredDist = WM_DEFAULT_SPAWN_POINT_PREFERRED_DIST;
		float fPreferredDist = GetDefaultedLocalFloat(oArea, VAR_WM_SPAWN_POINT_PREFERRED_DIST, WM_DEFAULT_SPAWN_POINT_PREFERRED_DIST);
	
		//float fMaxDist = GetLocalFloat(oArea, VAR_WM_SPAWN_POINT_MAX_DIST);
		//if (fMaxDist == 0.0f)
		//	fMaxDist = WM_DEFAULT_SPAWN_POINT_MAX_DIST;
		float fMaxDist = GetDefaultedLocalFloat(oArea, VAR_WM_SPAWN_POINT_MAX_DIST, WM_DEFAULT_SPAWN_POINT_MAX_DIST);
	
	
		// Check for designer marked spawnspots
		object oSpot = GetPreferredObjectInRange(oPC, WM_SPAWNSPOT_TAG, fPreferredDist, 0.0f, fMaxDist);
		
		// Found a spot?
		if (oSpot != OBJECT_INVALID)
		{
			SetLocalObject(oPC,"WM_AMBUSH_SPOT",oSpot);
			lRet = CalcSafeLocation(oPC, GetLocation(oSpot), fMaxDist, TRUE, FALSE);
			return lRet;
		}
	}
	
	// check if the designer has enabled the use of doors
	int bDoorsDisabled = GetLocalInt(GetArea(oPC), VAR_WM_SPAWN_DOORS_DISABLED);
	if (!bDoorsDisabled)
	{
		//float fMaxDoorDist = GetLocalFloat(oArea, VAR_WM_SPAWN_DOOR_MAX_DIST);
		//if (fMaxDoorDist == 0.0f)
		//	fMaxDoorDist = WM_DEFAULT_SPAWN_DOOR_MAX_DIST;
		float fMaxDoorDist = GetDefaultedLocalFloat(oArea, VAR_WM_SPAWN_DOOR_MAX_DIST, WM_DEFAULT_SPAWN_DOOR_MAX_DIST);
	
	
        // this tries to get the nearest door to the PC which is in line of sight.
        object oDoor = GetFirstObjectInShape(SHAPE_SPHERE, fMaxDoorDist, GetLocation(oPC), TRUE, OBJECT_TYPE_DOOR );
        object oDoor2 = GetNextObjectInShape(SHAPE_SPHERE, fMaxDoorDist,GetLocation(oPC),TRUE,OBJECT_TYPE_DOOR);

        if (oDoor2 != OBJECT_INVALID) // just see if the second door is better suited for an ambush
        {
            if (GetDistanceBetween(oDoor,oPC)> GetDistanceBetween(oDoor2,oPC) || GetLocked(oDoor) || GetPlotFlag(oDoor) )
                oDoor= oDoor2;
        }

        // Check if the selected door
        if (GetIsObjectValid(oDoor) /* && LineOfSightObject(oPC, oDoor)*/)
        {
            if ( !GetLocked(oDoor) && !GetPlotFlag(oDoor))
            {
                vector vDoor = GetPositionFromLocation(GetLocation(oDoor));
                vector vPC =  GetPositionFromLocation(GetLocation(oPC));
                vector vNew = vDoor;

                // Try to calculate a spot right behind the door on the opposite
                // side of the player
                if (vPC.x > vDoor.x)
                    vNew.x -= 0.8;
                else
                     vNew.x +=0.8;

                if (vPC.y> vDoor.y)
                    vNew.y -= 0.8;
                else
                    vNew.y += 0.8;

                location lLoc = Location(GetArea(oDoor),vNew,GetFacing(oDoor));
                SetLocalObject(oPC, "WM_AMBUSH_DOOR", oDoor);
				// Behind a door should be a safe location, but just in case...
                //lRet = lLoc;
				lRet = CalcSafeLocation(oPC, lLoc, fMaxDoorDist, TRUE, FALSE);
                return lRet;
           }
        }
	}
	
	// everything failed, so we just report the location of the PC
	// Random direction between min and max distance away.
	float fMaxLocDist = GetDefaultedLocalFloat(oArea, VAR_WM_SPAWN_LOC_MAX_DIST, WM_DEFAULT_SPAWN_LOC_MAX_DIST);
	float fMinLocDist = GetDefaultedLocalFloat(oArea, VAR_WM_SPAWN_LOC_MIN_DIST, WM_DEFAULT_SPAWN_LOC_MIN_DIST);
	lRet = GetNearbyLocation(GetLocation(oPC), fMaxLocDist, 0.0f, fMinLocDist);
	// get a location that the PC could walk to.
	lRet = CalcSafeLocation(oPC, lRet, fMaxLocDist, TRUE, FALSE);
	SetLocalInt(oPC, "WM_AMBUSH_ON_TOP_OF_PLAYER", TRUE);
	//SendMessageToPC(oPC,"**WM-Debug: Ambush will use player location");
	//return GetLocation(oPC);
	return lRet;
}

// -----------------------------------------------------------------------------
// External Functions
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// Setup the necessary variables for the restsys_ambus script
// You probably won't ever need this function as it is used internally by the
// system, but you could use it to build your own monster ambush
// (just call WMRunAmbush() to execute)
// oPC - The player to be ambushed
// sMonsters - one or more monster ResRefs, comma seperated with no whitespaces in between
// Examples:
//   WMSetupAmbush(GetEnteringObject(), "nw_dog,nw_dog") for multiple enemies
//   WMSetupAmbush(GetEnteringObject(), "nw_badger") for a single enemy
//------------------------------------------------------------------------------

void WMSetupAmbush(object oPC, string sMonsters)
{
    SetLocalString(oPC,"WM_AMBUSH",sMonsters);

    // Prevent Player to rest while ambush is running
    // This is cleared in WMRunAmbush()!
    SetLocalInt(oPC,"WM_AMBUSH_IN_PROGRESS",TRUE);
}

//------------------------------------------------------------------------------
// I had to make this a seperate function in order to delay it
// It is just called from inside WMRunAmbush
//------------------------------------------------------------------------------
void WMSpawnAmbushMonsters(object oPC, location lSpot)
{
    string sMonsters =  GetLocalString(oPC,"WM_AMBUSH");
	// PrettyDebug("WMSpawnAmbushMonsters() - sMonsters = " + sMonsters);
    DeleteLocalString(oPC,"WM_AMBUSH");

    // Check if this ambush is occuring on top of the player's head
    int bOnTop =   GetLocalInt(oPC, "WM_AMBUSH_ON_TOP_OF_PLAYER");
    DeleteLocalInt(oPC, "WM_AMBUSH_ON_TOP_OF_PLAYER");

    string sTemp;
    object oMonster;
    int nMonsterCount =0;

    // since sMonsters can contain comma seperated monsters, we are going to
    // explode the list here....
    int nPos = FindSubString(sMonsters,",");
    object oDoor = GetLocalObject(oPC, "WM_AMBUSH_DOOR");
     int bSpawnAnimation = FALSE;
     if (bOnTop)
     {
        if (WMGetUseAppearAnimation(GetArea(oPC)))
        {
            bSpawnAnimation = TRUE;
        }
    }

    // Create all creatures but the first
    while (nPos!= -1) // comma in remaining sMonster?
    {
        sTemp = GetSubString(sMonsters,0,nPos);
        sMonsters = GetSubString(sMonsters,nPos+1, GetStringLength(sMonsters) - GetStringLength(sTemp)-1);
        oMonster = CreateObject(OBJECT_TYPE_CREATURE,sTemp,lSpot,bSpawnAnimation);
		// PrettyDebug("WMSpawnAmbushMonsters() - spawned " + GetName(oMonster));
        AssignCommand(oMonster, SetFacing(GetFacing(oPC)));
        nPos = FindSubString(sMonsters,",");

        // If there is a door to open, have the last monster do it ...
        // this may trigger a trap the pc has set to secure his resting place
        if (oDoor != OBJECT_INVALID)
        {
            AssignCommand(oMonster,ActionOpenDoor(oDoor));
            DeleteLocalObject(oPC,"WM_AMBUSH_DOOR");
        }
        AssignCommand(oMonster, ActionMoveToObject(oPC,TRUE));
    }
    // Create the first Creature
    oMonster = CreateObject(OBJECT_TYPE_CREATURE,sMonsters,lSpot,bSpawnAnimation);
    if (oDoor != OBJECT_INVALID)
    {
        AssignCommand(oMonster,ActionOpenDoor(oDoor));
        DeleteLocalObject(oPC,"WM_AMBUSH_DOOR");
    }
    AssignCommand(oMonster, ActionMoveToObject(oPC,TRUE));

    // Allow Resting again
    DeleteLocalInt(oPC,"WM_AMBUSH_IN_PROGRESS");
}

//------------------------------------------------------------------------------
// This runs the actual wandering monster ambush on the pc, using the data stored
// by WMSetupAmbush.
//------------------------------------------------------------------------------
void WMRunAmbush(object oPC)
{
	PrettyMessage("WMRunAmbush()");
    //--------------------------------------------------------------------------
    // Get the best location from which to attack the player
    //--------------------------------------------------------------------------
    location lSpot = WMGetAmbushSpot(oPC);

    object oSpot = GetLocalObject(oPC,"WM_AMBUSH_SPOT");
    if (GetIsObjectValid(oSpot))
    {
        event eUser = EventUserDefined(WM_SPAWNSPOT_EVENTID);
        SignalEvent(oSpot,eUser);
        DeleteLocalObject(oPC, "WM_AMBUSH_SPOT");
    }
    //--------------------------------------------------------------------------
    // Brent: Removed Delay
    // DelayCommand(2.5f,WMSpawnAmbushMonsters(oPC, lSpot));
    //--------------------------------------------------------------------------
    // * remove ddelay (brent) from

    //--------------------------------------------------------------------------
    // Do the ambush
    //--------------------------------------------------------------------------
    WMSpawnAmbushMonsters(oPC, lSpot);
}
const int NUM_DICE_IN_QUEUE	=	5;

// set up a queue of 5 rolls
void InitDieQueue(int nSides)
{
	int i;
	for (i=1; i<=NUM_DICE_IN_QUEUE; i++)
	{
		string sDieArrayName = "DieArray"+IntToString(nSides);
		int nNewRoll = Random(nSides) + 1;
		SetGlobalArrayInt(sDieArrayName, i, nNewRoll);
	}
}

// Return results from a queue of pre-rolled dice
int GetNextDieRoll(int nSides)
{
	// get current pointer in array
	string sDiePointerVar = "DiePointer"+IntToString(nSides);
	int nDiePointer = GetGlobalInt(sDiePointerVar);
	
	// initialize array the first time
	if (nDiePointer == 0)
	{
		nDiePointer = 1;
		InitDieQueue(nSides);
	}
	
	// get the roll pointed to		
	string sDieArrayName = "DieArray"+IntToString(nSides);
	int nRoll = GetGlobalArrayInt(sDieArrayName, nDiePointer);
	
	// replace this roll in the array
	int nNewRoll = Random(nSides) + 1;
	SetGlobalArrayInt(sDieArrayName, nDiePointer, nNewRoll);
	
	// increment and store the pointer
	nDiePointer++;
	if (nDiePointer>NUM_DICE_IN_QUEUE)
		nDiePointer = 1;
	SetGlobalInt(sDiePointerVar, nDiePointer);
	
	return (nRoll);
}

//------------------------------------------------------------------------------
// Georg Zoeller,  2003-05-29
// Wandering Monster System, Check for wandering monster
//   oPC - the player who triggered the check
//
// This will check if the player has triggered a wandering monster and return TRUE if yes.
//
// To be used in the OnRest event handler. It will also setup the encounter so if
// ExecuteScript (DoWanderingMonster) is called on a PC, the encounter will start.
//
// Has integrated flood protection to prevent more than one encounter in WM_FLOODPROTPERIOD
// seconds (see header)
//------------------------------------------------------------------------------
int WMCheckForWanderingMonster(object oPC)
{

    if (WMGetWanderingMonstersDisabled(GetArea(oPC)))
    {
        return FALSE;
    }
    // we just had one encounter, we dont want another right now!
    if (GetLocalInt(GetArea(oPC), VAR_WM_AREA_FLOODPROTECTION))
    {
		PrettyDebug("Flood protection preventing Monster Check.");
        return FALSE;
    }
	
	object oArea = GetArea(oPC);
    // Get the probability for a wandering monster depending on the time of day
	int nProb = WMGetWanderingMonsterProbability(oPC);
	// PrettyDebug("WMCheckForWanderingMonster() nProb=" + IntToString(nProb));
	int nRoll = GetNextDieRoll(100);
	int nMinThreshold = GetLocalInt(oArea, CAMPAIGN_VAR_WM_MIN_THRESHOLD);
	if (nMinThreshold == 0)
		nMinThreshold = GetGlobalInt(CAMPAIGN_VAR_WM_MIN_THRESHOLD);
	
    //if (nProb > d100())
    if ((nProb > nRoll)
		&& (nRoll >= nMinThreshold))
    {
       	string sMonster = WMGetWanderingMonsterFrom2DA(oPC);
		// PrettyDebug("WMCheckForWanderingMonster() sMonster=" + sMonster);
       	WMSetupAmbush (oPC,sMonster);

       	// Flood Protection to prevent lots of spawns
        SetLocalInt(GetArea(oPC), VAR_WM_AREA_FLOODPROTECTION ,TRUE);
       	DelayCommand(WM_FLOOD_PROTECTION_PERIOD, DeleteLocalInt(GetArea(oPC) ,VAR_WM_AREA_FLOODPROTECTION));
       	return TRUE;
    }

   return FALSE;

}

//------------------------------------------------------------------------------
// Wandering Monster System, Set the Wandering Monster Table for an Area
//  oArea         - the Area
//  sSuffix		  - either VAR_WM_DAY_SUFFIX or VAR_WM_NIGHT_SUFFIX
//  sTableName    - The name of the encounter table (TableName Column in 2da)
//  bUseDoors     - Monsters will spawn behind the next not-locked door, open them
//                  and move onto the pc (default = TRUE )
// nListenCheckDC - The DC to beat in an listen check in order to wake up early.
//                  (default = -1, use value in 2da)
//
// NOTE: You can call WMSetAreaProbability later to change the probability
//       of having an encounter
//------------------------------------------------------------------------------
/*
void WMSetAreaTable(object oArea, string sSuffix, string sTableName, int bUseDoors = FALSE, int nListenCheckDC = 0)
{
    //struct wm_struct stTbl = GetWMStructByName(sTableName);
	//string sTableVar = GetStringTimeOfDayValue(VAR_WM_AREA_TABLE_DAY, VAR_WM_AREA_PROB_NIGHT);
	//string sProbVar = GetStringTimeOfDayValue(VAR_WM_AREA_PROB_DAY, VAR_WM_AREA_PROB_NIGHT);
    SetLocalInt(oArea, GetTableNameVar(sSuffix), stTbl.nRowNumber);
    SetLocalInt(oArea, GetProbabilityVar(sSuffix), stTbl.nProbability);
	
	SetLocalInt(oArea, VAR_WM_SPAWN_DOORS_DISABLED, bUseDoors);
	
    // get 2da defined listen check...
    //if (nListenCheckDC == 0)
    //{
    //    nListenCheckDC = stTbl.nListenCheckDC;
    //}

    //SetLocalInt(oArea, VAR_WM_AREA_LISTENCHECK, nListenCheckDC);

    //WMDebug("Set encounter table " + sTableName + "(" + IntToString(stTbl.nRowNumber) + ") on area " +GetName(oArea) );
}
*/

//------------------------------------------------------------------------------
// Wandering Monster System, set area probability for encountering wandering monsters on rest
//   oArea - Self Explaining
//   nDayPercent, nNightPercent - Percentage chance for encounter on resting
//   NOTE: If you change the encounter Table via WMSetAreaTable, probabilities for the area
//         are reset to their default values specified in the 2da.
//------------------------------------------------------------------------------
void WMSetAreaProbability(object oArea, int nDayPercent, int nNightPercent)
{
    //if (WMGetAreaHasTable(oArea)) // if there is an encounter table set....
    //{
        SetLocalInt(oArea, GetProbabilityVar(VAR_WM_DAY_SUFFIX), nDayPercent);
        SetLocalInt(oArea, GetProbabilityVar(VAR_WM_NIGHT_SUFFIX), nNightPercent);
    //}
}

//------------------------------------------------------------------------------
// Returns TRUE if oArea has the Wandering Monster System disabled
//------------------------------------------------------------------------------
int WMGetWanderingMonstersDisabled(object oArea)
{
    return (GetLocalInt(oArea, VAR_WM_DISABLED) || GetLocalInt(GetModule(), VAR_WM_DISABLED) || GetGlobalInt(VAR_WM_DISABLED));
}

//------------------------------------------------------------------------------
// Sets if oArea has the Wandering Monster System disabled
//------------------------------------------------------------------------------
void WMSetWanderingMonstersDisabled(object oArea, int bDisabled = FALSE )
{
    SetLocalInt(oArea, VAR_WM_DISABLED, bDisabled);
}

//------------------------------------------------------------------------------
// Will make the party of the character rest as long as everyone is in the
// same area currently not useds
//------------------------------------------------------------------------------
void WMMakePartyRest(object oPC)
{
	object oMember = GetFirstFactionMember(oPC, TRUE);
	{
	    if (GetArea(oPC) == GetArea(oMember))
	    {
	        AssignCommand(oMember,ActionRest());
	    }
	}
}

//------------------------------------------------------------------------------
// Player Rest code
// Fades Screen to Black for PC, applies sleep vfx
// If an ambush is in progress it will return FALSE so resting can be disabled
//------------------------------------------------------------------------------
int WMStartPlayerRest(object oPC)
{
    if  (GetLocalInt(oPC,"WM_AMBUSH_IN_PROGRESS"))
    {
        // do not allow to sleep when an ambush is already in progress
        return FALSE;
    }
	// this is not a "zzzz" effect in NWN2, so not really appropriate.
    //effect eSleep = EffectVisualEffect(VFX_IMP_SLEEP);
    //ApplyEffectToObject(DURATION_TYPE_INSTANT,eSleep, oPC);
    DelayCommand(0.1,FadeToBlack(oPC,FADE_SPEED_FAST));
    DelayCommand(2.6, FadeFromBlack(oPC, FADE_SPEED_MEDIUM));
    return TRUE;
}

//------------------------------------------------------------------------------
// Remove the cutscene blackness, etc
// Called after a rest is done from OnPlayerRest Event
//------------------------------------------------------------------------------
void WMFinishPlayerRest(object oPC, int bRestCanceled = FALSE)
{
    FadeFromBlack(oPC,FADE_SPEED_MEDIUM);  // Finish Resting (canceled)
}

//------------------------------------------------------------------------------
// Returns the DC to beat in a listen check to wake up. Its defined in the 2da
// but can be overwritten in WMSetAreaTable)
//------------------------------------------------------------------------------
int WMGetAreaListenCheck(object oArea)
{
    if (!GetIsObjectValid(oArea))
    {
        return WM_DEFAULT_LISTEN_CHECK; // return default
    }
	
    int nDC = GetLocalInt(oArea, VAR_WM_AREA_LISTENCHECK);    // this int is stored by WMSetAreaTable
    // some sanity checks
    if (nDC < 1 || nDC > 255 )
    {
        nDC = WM_DEFAULT_LISTEN_CHECK;  // return default
    }
    return nDC;
}

//------------------------------------------------------------------------------
// Do a listen check against the designer defined DC for waking up in that area
// See WMSetAreaTable() on how to set the DC.
//------------------------------------------------------------------------------
int WMDoListenCheck(object oPC)
{
    object oArea = GetArea(oPC);
    int nDC = WMGetAreaListenCheck(oArea);

    int nRet = (GetIsSkillSuccessful(oPC,SKILL_LISTEN,nDC) == TRUE);
    return nRet;
}

//------------------------------------------------------------------------------
// Returns TRUE if appear animations are used when monsters are spawned by
// the system.
//------------------------------------------------------------------------------
int WMGetUseAppearAnimation(object oArea)
{
    return GetLocalInt(oArea, VAR_WM_USE_APPEAR_ANIMATIONS);
}


// sets the local int to the specified value only if the 
// current value is 0
void DefaultLocalInt(object oObject, string sVar, int iValue)
{
	int iValue = GetLocalInt(oObject, sVar);
	if (iValue == 0)
	{
		SetLocalInt(oObject, sVar, iValue);
	}
}

// This handles the inizialization that occurs the first time 
// rest occurs in the area at day or at night.
void WMRestEncounterInit(object oPC)
{
/*
	PrettyMessage(" WMRestEncounterInit()");
	object oArea = GetArea (oPC);
	int iInit = GetIsInitialized(oArea);
	if (!iInit)
	{
		// set up defualt values from the 2DA
    	string s2DA = WMGet2DAFileName();
    	string sTableName	= GetLocalString(oArea, GetTableNameVar());
		int nRow = GetCached2DAIndex(s2DA, RSWMT_TABLE_NAME_COL, sTableName);
        int nProbability = StringToInt(GetCached2DAEntry(s2DA, RSWMT_BASE_PROBABILITY_COL, nRow));
		DefaultLocalInt(oArea, GetProbabilityVar(), nProbability);
		PrettyMessage(" nProbability = " + IntToString(nProbability));
		SetIsInitialized(oArea);
	}
*/
}


void ResetCumTotal(object oArea)
{
	PrettyDebug("ResetCumTotal() ");
	SetLocalInt(oArea, VAR_WM_ENC_CUM_TOTAL, 0);
}

void IncrementCumTotal(object oArea, int nEncounterChance = 0)
{
	int nCumIncrease;

	if (GetIsSoZ())
	{
		int nCumIncreaseL = nEncounterChance;
		int nCumIncreaseH = nEncounterChance * 2;
		nCumIncrease = RandomIntBetween(nCumIncreaseL, nCumIncreaseH);

		float fCumIncrease = IntToFloat(nCumIncrease);
		object oPC = GetFactionLeader(GetFirstPC());

		/* This applies the encounter chance modifiers for the various TW benefit feats. */
		if(GetHasFeat(FEAT_TW_IMPROVED_CAMP_ROUTINE, oPC))
		{
			fCumIncrease *= 0.5f;
			nCumIncrease = FloatToInt(fCumIncrease);
		}
		else if(GetHasFeat(FEAT_TW_CAMP_ROUTINE, oPC))
		{
			fCumIncrease *= 0.75f;
			nCumIncrease = FloatToInt(fCumIncrease);
		}
	}
	else
	{
		int nCumIncreaseL = GetLocalInt(oArea, VAR_WM_ENC_CUM_INCREASE_L);
		int nCumIncreaseH = GetLocalInt(oArea, VAR_WM_ENC_CUM_INCREASE_H);
		nCumIncrease = RandomIntBetween(nCumIncreaseL, nCumIncreaseH);
	}

	PrettyDebug("IncrementCumTotal() : " + IntToString(nCumIncrease));
	ModifyLocalInt(oArea, VAR_WM_ENC_CUM_TOTAL, nCumIncrease);
}

// we don't want the resting part of WMRestEncounterCheck()
/*
int SinglePartyWMRestEncounterCheck(object oPC)
{
	PrettyDebug("called SinglePartyWMRestEncounterInit()");
	int nRet = WMCheckForWanderingMonster(oPC);
	
	if (nRet)
	{
		PrettyDebug("SinglePartyWMRestEncounterInit() - executing ambush script");
	
		//This script MUST be run or the player won't be able to rest again ...
		// (defaults to gb_restsys_ambus)
		ExecuteScript(WM_AMBUSH_SCRIPT_NAME, oPC);
	}
	return (nRet);
}
*/

int SinglePartyWMRestEncounterCheck(object oPC)
{
	if (GetIsSoZ())
	{
		int nRet;
		object oArea = GetArea(oPC);
		
		object oTrigger = GetNearestTerrainTrigger(oPC);
	
		int nEncounterChance	= GetLocalInt(oTrigger, VAR_ENC_CHANCE);
		int nGameDifficulty		= GetGameDifficulty();
		
		//Encounter chance modifiers:
		//Easy: -5% chance.
		//D&D Harcore: +5% Chance.
		//Difficult: +10% Chance.
		if( nGameDifficulty <= GAME_DIFFICULTY_EASY )
		{
			nEncounterChance -= 5;
		}
		
		else if (nGameDifficulty == GAME_DIFFICULTY_CORE_RULES )
		{
			nEncounterChance += 5;
		}
		
		else if ( nGameDifficulty == GAME_DIFFICULTY_DIFFICULT )
		{
			nEncounterChance += 10;
		}
		
		nEncounterChance *= 2;	//Weighting terrain more heavily for random encounters.
		int nCumTotal = GetLocalInt(oArea, VAR_WM_ENC_CUM_TOTAL);
		
		if(GetIsNight())
		{
			nEncounterChance += 10;
		}
		
		PrettyDebug("nEncounterChance = " + IntToString(nEncounterChance));
		if( (nEncounterChance + nCumTotal ) >= 100)
		{
			ResetCumTotal(oArea);
			object oRandomEncounter = CreateEncounterNearPC(oPC);
			
			AssignCommand(oRandomEncounter, ActionJumpToObject(oPC));
			nRet = WM_CHECK_AMBUSH;
			PrettyDebug("Hey, your changes are actually getting compiled!");
			SetLocalInt(oRandomEncounter, "bHostile", TRUE);
			AssignCommand(oRandomEncounter, InitiateEncounter(0,0,FALSE,FALSE,FALSE,FALSE,FALSE,oPC));
			if (GetIsObjectValid(oRandomEncounter))
			{
				DestroyObject(oRandomEncounter, 2.0f);
			}
		}
		
		else
		{
			// mo wandering monsters so increse the threat for next time.
			nRet = WM_CHECK_NO_AMBUSH;
			IncrementCumTotal(oArea, nEncounterChance);
		}
		
		return (nRet);
	}
	else
	{
		object oArea = GetArea(oPC);
	
		//// PrettyDebug("call WMCheckForWanderingMonster");
		int nRet = WMCheckForWanderingMonster(oPC);
		if (nRet)
		{
			// PrettyDebug("called WMCheckForWanderingMonster");
			ResetCumTotal(oArea);
			//This script MUST be run or the player won't be able to rest again ...
			ExecuteScript(WM_AMBUSH_SCRIPT_NAME, oPC);
		}
		else
		{
			// mo wandering monsters so increse the threat for next time.
			IncrementCumTotal(oArea);
		}
	
		return (nRet);
	}
}

// To be called from the module's on rest script
// -1 = can't rest right now
// 0 = rest ok, no ambush
// 1 = rest interrupted by ambush
int WMRestEncounterCheck(object oPC)
{
	int nRet;
	// PrettyDebug("call WMRestEncounterCheck");
	if (!WMStartPlayerRest(oPC))
	{
		// The resting system has objections against resting here and now
		// Probably because there is an ambush already in progress
		FloatingTextStrRefOnCreature(84142  ,oPC);
		AssignCommand(oPC,ClearAllActions());
		return (WM_CHECK_CANT_REST);
	}
	nRet = SinglePartyWMRestEncounterCheck(oPC);
/*	
	object oArea = GetArea(oPC);
	
	//// PrettyDebug("call WMCheckForWanderingMonster");
	nRet = WMCheckForWanderingMonster(oPC);
	if (nRet)
	{
		// PrettyDebug("called WMCheckForWanderingMonster");
		ResetCumTotal(oArea);
		//This script MUST be run or the player won't be able to rest again ...
		ExecuteScript(WM_AMBUSH_SCRIPT_NAME, oPC);
	}
	else
	{
		// mo wandering monsters so increse the threat for next time.
		IncrementCumTotal(oArea);
	}
*/	
	return (nRet);
}



// returns a string ref based on the probabiltiy passed in.
int WMGetRestStringRef(int nDangerLevel)
{
	int nRet;
	if (nDangerLevel >= REST_IMMINENT_DANGER)
		nRet = STR_REF_REST_IMMINENT_DANGER;
	else if (nDangerLevel >= REST_EXTREME_DANGER)
		nRet = STR_REF_REST_EXTREME_DANGER;
	else if (nDangerLevel >= REST_VERY_DANGEROUS)
		nRet = STR_REF_REST_VERY_DANGEROUS;
	else if (nDangerLevel >= REST_DANGEROUS)
		nRet = STR_REF_REST_DANGEROUS;
	else if (nDangerLevel >= REST_SOMEWHAT_DANGEROUS)
		nRet = STR_REF_REST_SOMEWHAT_DANGEROUS;
	else if (nDangerLevel >= REST_RELATIVELY_SAFE)
		nRet = STR_REF_REST_RELATIVELY_SAFE;
	else // if (nDangerLevel >= REST_SAFE)
		nRet = STR_REF_REST_SAFE;
	
	return (nRet);
}	


//------------------------------------------------------------------------------
// === GUI Related ===
//------------------------------------------------------------------------------

// set the wait string to the appropriate value (wait till dusk or wait till dawn)
void SetWaitTextStringRef(object oPC)
{
	int nStrRef = STR_REF_WAIT_DUSK;
	string sText = ""; 
	//sText = "Wait here until dusk.";
	if (GetIsNight() || GetIsDusk())
	{
		 nStrRef = STR_REF_WAIT_DAWN;
		 //sText = "Wait here until dawn.";
	}
	//nStrRef = -1; // use text instead of str ref for testing.
	SetGUIObjectText(oPC, sSCREEN_GUI_REST, WAIT_LABEL, nStrRef, sText);
}

// Sets the state of the option - in GUI and in a global var
void SetRestOptionState(object oPlayerObject, int iState)
{
	//object oPlayerObject = GetControlledCharacter(OBJECT_SELF);
	
	SetLocalInt(oPlayerObject, VAR_REST_CHOICE, iState);
	//PrettyMessage(" iState =" + IntToString(iState));
	SetGUIObjectDisabled(oPlayerObject, sSCREEN_GUI_REST, REST_BUTTON, (iState == 0)); // disable (on) if state 0
	SetGUIObjectDisabled(oPlayerObject, sSCREEN_GUI_REST, WAIT_BUTTON, (iState == 1)); // disable (on) if state 1
}

// returns a String Ref
int GetRestMessageStrRef(object oPC)
{
	int nProb = 0;
	
	// if not disabled then check probability
	if (!WMGetWanderingMonstersDisabled(GetArea(oPC)))
		nProb = WMGetWanderingMonsterProbability(oPC);
		
	int nResRef = WMGetRestStringRef(nProb);
	//string sRestSafety = GetStringByStrRef(nResRef);
	return (nResRef);
	//SetCustomToken (99, sRestSafety);
}

//RWT-OEI 01/05/06
//This script function displays a message box popup on the client of the
//player passed in as the first parameter.
//////
// oPC           - The player object of the player to show this message box to
// nMessageStrRef- The STRREF for the Message Box message. 
// sMessage      - The text to display in the message box. Overrides anything 
//               - indicated by the nMessageStrRef
// sOkCB         - The callback script to call if the user clicks OK, defaults
//               - to none. The script name MUST start with 'gui'
// sCancelCB     - The callback script to call if the user clicks Cancel, defaults
//               - to none. The script name MUST start with 'gui'
// bShowCancel   - If TRUE, Cancel Button will appear on the message box.
// sScreenName   - The GUI SCREEN NAME to use in place of the default message box.
//               - The default is SCREEN_MESSAGEBOX_DEFAULT 
// nOkStrRef     - The STRREF to display in the OK button, defaults to OK
// sOkString     - The string to show in the OK button. Overrides anything that
//               - nOkStrRef indicates if it is not an empty string
// nCancelStrRef - The STRREF to dispaly in the Cancel button, defaults to Cancel.
// sCancelString - The string to display in the Cancel button. Overrides anything
//				 - that nCancelStrRef indicates if it is anything besides empty string
//void DisplayMessageBox( object oPC, int nMessageStrRef,
//						string sMessage, string sOkCB="", 
//                        string sCancelCB="", int bShowCancel=FALSE, 
//                        string sScreenName="",
//                        int nOkStrRef=0, string sOkString="",
//                        int nCancelStrRef=0, string sCancelString="" );
void DisplayRestGUI(object oPC)
{
	int nMessageStrRef 		= GetRestMessageStrRef(oPC);
	string sMessage 		= ""; 
	string sOkCB			= GUI_REST_SCRIPT_NAME;
	string sCancelCB		= "";	// no cancel script needed
	int bShowCancel			= TRUE; 
	string sScreenName		= sSCREEN_GUI_REST; // registered in ingamegui.ini
	int nOkStrRef			= 181744;
	string sOkString		= "";
	int nCancelStrRef		= 181745;
	string sCancelString	= "";
	

	// the gui script will always run on the owned PC, regardless of who the player has possessed.
	//object oObj = GetOwnedCharacter(oPC);
	//SetLocalObject(oObj, VAR_ENCHANTED_ITEM_OBJECT, oItem);

	DisplayMessageBox( oPC, nMessageStrRef, sMessage, sOkCB, sCancelCB, bShowCancel, 
                     sScreenName, nOkStrRef, sOkString, nCancelStrRef, sCancelString);
	
	// set the wait string to the appropriate value
	SetWaitTextStringRef(oPC);
	
	// default rest option to "rest"
	SetRestOptionState(oPC, 0);
}

// someday we'll have script commands for these.
int GetDuskHour()
{
	return 18;
}

int GetDawnHour()
{
	return 6;
}


void RestSendMessage(object oPC, int iStrRef)
{
	SendMessageToPCByStrRef(oPC, iStrRef);
	//string sOut = GetStringByStrRef(iStrRef);
	//SendMessageToPC(oPC, "Rest Message generated by script: " + sOut);
}