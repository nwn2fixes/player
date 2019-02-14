// ginc_param_const
/*
	Include file for interesting params and converting ints to constants.
*/
// 3/10/05 ChazM
// 4/22/05 ChazM - added param functions
// 4/27/05 BMA - GetTarget() identifiers
// 4/28/05 ChazM - add fation param constants and IsParameterConstant()
// 5/04/05 ChazM - added GetInfluenceVarName()
// 5/05/05 BMA - moved GetInfluenceVarName() to ginc_companions.nss
// 5/11/05 BMA - fixed bug in GetTarget()
// 5/23/05 ChazM - fixed bug in GetObjectTypes()
// 9/02/05 BMA-OEI - reorganized functions, added GetSkillConstant()
// 10/13/05 FAB - slight change to GetTarget() so that if target = 0, that it defaults to OBJECT_SELF
// 12/21/05 ChazM - added StringTrim(), GetTrimmedStringParam()
// 1/23/06 BMA-OEI - added TARGET_PC_LEADER, _NEAREST, _SPEAKER
// 1/25/06 ChazM - Fixed problem with GetTarget().
// 4/13/06 EPF - GetTarget() checks the owner's tag to make sure he's not the object we're looking for.
// 6/16/06 ChazM - added TARGET_OWNED_CHAR for GetTarget()
// 7/17/06 ChazM - chaged error text to debug text in GetTarget()
// 8/18/06 ChazM - added rNameValueStringPair, GetNameValuePairStruct(), GetNVPValue(), RemoveNVP(), AppendUniqueToNVP()
// 2/14/07 ChazM - added optional delimiter override to GetFloatParam(), GetIntParam(), and GetStringParam()
// 2018.12.11 Aqvilinus - use return from RemoveNVP() when adding an NVP with AppendUniqueToNVP()
// 2018.12.11 kevL - use the delimiter passed by AppendUniqueToNVP() for all NVP functs.


//void main(){}

#include "ginc_debug"
#include "nw_i0_plot"
#include "X0_I0_STRINGLIB"

///////////////////////////////////////////////////////////
// Constants & Structs
///////////////////////////////////////////////////////////

const string TARGET_KEY		 	= "$";
const string TARGET_OBJECT_SELF	= "$OBJECT_SELF";	// OBJECT_SELF
const string TARGET_OWNER 	 	= "$OWNER";			// OBJECT_SELF (conversation owner)
const string TARGET_OWNED_CHAR	= "$OWNED_CHAR";	// GetOwnedCharacter
const string TARGET_PC	 	 	= "$PC";			// PCSpeaker
const string TARGET_PC_LEADER	= "$PC_LEADER"; 	// FactionLeader (of first PC)
const string TARGET_PC_NEAREST	= "$PC_NEAREST";	// NearestPC (owned and alive)
const string TARGET_PC_SPEAKER	= "$PC_SPEAKER";	// PCSpeaker

const string TARGET_MODULE	 	= "$MODULE";
const string TARGET_LAST_SPEAKER = "$LASTSPEAKER";

const string PARAM_COMMONER	=  "$COMMONER";
const string PARAM_DEFENDER	=  "$DEFENDER";
const string PARAM_HOSTILE	=  "$HOSTILE";
const string PARAM_MERCHANT	=  "$MERCHANT";

// Similar to rNameValuePair in x0_i0_stringlib, but with a string value instead of an int.
struct rNameValueStringPair
{
	string sName;
	string sValue;
};	


///////////////////////////////////////////////////////////
// Prototypes
///////////////////////////////////////////////////////////
object	GetTarget(string sTarget, string sDefault=TARGET_OWNER);

float	GetFloatParam(string sString, int nPos, string sDelim=",");
int		GetIntParam(string sString, int nPos, string sDelim=",");
string	GetStringParam(string sString, int nPos, string sDelim=",");

int		IsParameterConstant(string sParameter);

int		GetObjectTypes(string sType);
int		GetDurationType(string sType);
int		GetStandardFaction(string sFactionName);
string	GetInfluenceVarName(string sTarget);

int		GetSkillConstant(int nSkill);


object GetSoundObjectByTag(string sTarget);

struct rNameValueStringPair GetNameValuePairStruct (string sNameValuePair, string sDelimiter = "=");
string GetNVPValue(string sNVPList, string sName, string sDelim="=");
string RemoveNVP(string sNVPList, string sName, string sDelim="=");
string AppendUniqueToNVP(string sNVPList, string sName, string sValue, string sDelim="=");

///////////////////////////////////////////////////////////
// Function Definitions
///////////////////////////////////////////////////////////


// Return constant value for skill n
// Used in gc_skill_dc, gc_skill_rank
int GetSkillConstant(int nSkill)
{
	int nSkillVal;

	switch (nSkill)	
	{
        case 0:     // APPRAISE
            nSkillVal = SKILL_APPRAISE;
            break;
        case 1:     // BLUFF
            nSkillVal = SKILL_BLUFF;
            break;
        case 2:     // CONCENTRATION
            nSkillVal = SKILL_CONCENTRATION;
            break;
        case 3:     // CRAFT ALCHEMY
            nSkillVal = SKILL_CRAFT_ALCHEMY;
            break;
        case 4:     // CRAFT ARMOR
            nSkillVal = SKILL_CRAFT_ARMOR;
            break;
        case 5:     // CRAFT WEAPON
            nSkillVal = SKILL_CRAFT_WEAPON;
            break;
        case 6:     // DIPLOMACY
            nSkillVal = SKILL_DIPLOMACY;
            break;
        case 7:     // DISABLE DEVICE
            nSkillVal = SKILL_DISABLE_TRAP;
            break;
        case 8:     // DISCIPLINE
            nSkillVal = SKILL_DISCIPLINE;
            break;
        case 9:     // HEAL
            nSkillVal = SKILL_HEAL;
            break;
        case 10:     // HIDE
            nSkillVal = SKILL_HIDE;
            break;
        case 11:     // INTIMIDATE
            nSkillVal = SKILL_INTIMIDATE;
            break;
        case 12:     // LISTEN
            nSkillVal = SKILL_LISTEN;
            break;
        case 13:     // LORE
            nSkillVal = SKILL_LORE;
            break;
        case 14:     // MOVE SILENTLY
            nSkillVal = SKILL_MOVE_SILENTLY;
            break;
        case 15:     // OPEN LOCK
            nSkillVal = SKILL_OPEN_LOCK;
            break;
        case 16:     // PARRY
            nSkillVal = SKILL_PARRY;
            break;
        case 17:     // PERFORM
            nSkillVal = SKILL_PERFORM;
            break;
        case 18:     // RIDE
            nSkillVal = SKILL_RIDE;
            break;
        case 19:     // SEARCH
            nSkillVal = SKILL_SEARCH;
            break;
        case 20:     // SET TRAP
            nSkillVal = SKILL_CRAFT_TRAP;
            break;
        case 21:     // SLEIGHT OF HAND
            nSkillVal = SKILL_SLEIGHT_OF_HAND;
            break;
        case 22:     // SPELLCRAFT
            nSkillVal = SKILL_SPELLCRAFT;
            break;
        case 23:     // SPOT
            nSkillVal = SKILL_SPOT;
            break;
        case 24:     // SURVIVAL
            nSkillVal = SKILL_SURVIVAL;
            break;
        case 25:     // TAUNT
            nSkillVal = SKILL_TAUNT;
            break;
        case 26:     // TUMBLE
            nSkillVal = SKILL_TUMBLE;
            break;
        case 27:     // USE MAGIC DEVICE
            nSkillVal = SKILL_USE_MAGIC_DEVICE;
            break;
	}

	return (nSkillVal);
}


string StringTrim(string sString)
{
	int iLen = GetStringLength(sString);
	string sLeft = GetStringLeft(sString, 1);
	while (sLeft == " ")
	{
		sString = GetSubString(sString, 1, GetStringLength(sString)-1);
		sLeft = GetStringLeft(sString, 1);
	}

	string sRight = GetStringRight(sString, 1);
	while (sRight == " ")
	{
		sString = GetSubString(sString, 0, GetStringLength(sString)-1);
		sRight = GetStringRight(sString, 1);
	}
	return (sString);
}

// get specified param from comma delimited string.
// return as string
string GetTrimmedStringParam(string sString, int nPos)
{
	string sParam = GetTokenByPosition(sString, ",", nPos);
	return (StringTrim(sParam));
}


// get specified param from comma delimited string.
// return as string
string GetStringParam(string sString, int nPos, string sDelim=",")
{
	return (GetTokenByPosition(sString, sDelim, nPos));
}


// get specified param from comma delimited string.
// return as int
int GetIntParam(string sString, int nPos, string sDelim=",")
{
	return (StringToInt(GetTokenByPosition(sString, sDelim, nPos)));
}


// get specified param from comma delimited string.
// return as float
float GetFloatParam(string sString, int nPos, string sDelim=",")
{
	return (StringToFloat(GetTokenByPosition(sString, sDelim, nPos)));
}


// Return Target by tag or special identifier
// Leave sTarget blank to use sDefault override
object GetTarget(string sTarget, string sDefault=TARGET_OWNER)
{
	object oTarget = OBJECT_INVALID;
	
	// If sTarget is blank, use sDefault
	if ("" == sTarget || "0" == sTarget) sTarget = sDefault;
	
	// Check if sTarget is a special identifier
	if (IsParameterConstant(sTarget))
	{
		string sIdentifier = sTarget;
		sIdentifier = GetStringUpperCase(sIdentifier);
		
		if (TARGET_OWNER == sIdentifier) 			oTarget = OBJECT_SELF;
		else if (TARGET_OBJECT_SELF == sIdentifier)	oTarget = OBJECT_SELF;
		else if (TARGET_OWNED_CHAR == sIdentifier)	oTarget = GetOwnedCharacter(OBJECT_SELF);
		else if (TARGET_PC == sIdentifier)			oTarget = GetPCSpeaker();
		else if (TARGET_PC_LEADER == sIdentifier)	oTarget = GetFactionLeader(GetFirstPC());
		else if (TARGET_PC_NEAREST == sIdentifier)	oTarget = GetNearestPC();
		else if (TARGET_PC_SPEAKER == sIdentifier)	oTarget = GetPCSpeaker();
		else if (TARGET_MODULE == sIdentifier)		oTarget = GetModule();
		else if (TARGET_LAST_SPEAKER == sIdentifier) oTarget = GetLastSpeaker();
		else
		{
			PrettyError("GetTarget() -- " + sIdentifier + " not recognized as special identifier!");
		}
	}
	else
	{
		oTarget = GetNearestObjectByTag(sTarget);	// Search area
		

		//EPF 4/13/06 -- get nearest misses if the owner is the object we're looking for
		//	so check and see if the target is OBJECT_SELF.  I'm putting this after the GetNearest()
		// call since string compares are expensive, but before the GetObjectByTag() call, since
		// that's liable to return the wrong instance.  We can move this to before the GetNearest() call
		// if this becomes a problem.
		if(!GetIsObjectValid(oTarget))	
		{								
			if(sTarget == GetTag(OBJECT_SELF))
			{
				oTarget = OBJECT_SELF;
			}	
		}
		// If not found
		if (GetIsObjectValid(oTarget) == FALSE) 
		{	
			oTarget = GetObjectByTag(sTarget);		// Search module
		}
	}

	// If not found
	if (GetIsObjectValid(oTarget) == FALSE)
	{
		PrettyDebug("GetTarget() -- Could not find target with tag: " + sTarget);
	}
	
	return (oTarget);
}


// BMA 5/5/05 ginc_companions updated with GetCompInfluenceGlobVar()
// get the influence variable name of specified target
//string GetInfluenceVarName(string sTarget)
//{
//	string sVarName;
//    object oTarg = GetTarget(sTarget, TARGET_OBJECT_SELF);
//	
//	if (GetIsObjectValid(oTarg))
//		sVarName = GetTag(oTarg);
//	else
//		sVarName = sTarget;
//		
//	sVarName = sVarName + "_Influence";		
//	return (sVarName);
//}


// returns the combined object types of any of the following:
// not case sensitive
//                C = creature
//                I = item
//                T = trigger
//                D = door
//                A = area of effect
//                W = waypoint
//                P = placeable
//                S = store
//                E = encounter
//				  L = light
//                V = visual effect
//                ALL = everything

int GetObjectTypes(string sType)
{
    sType = GetStringUpperCase(sType);
    int iObjectType = 0;

    if (FindSubString(sType, "ALL") != -1)
        iObjectType = OBJECT_TYPE_ALL;
    else
    {
        iObjectType |= (FindSubString(sType, "C")==-1)?0:OBJECT_TYPE_CREATURE;
        iObjectType |= (FindSubString(sType, "I")==-1)?0:OBJECT_TYPE_ITEM;
        iObjectType |= (FindSubString(sType, "T")==-1)?0:OBJECT_TYPE_TRIGGER;
        iObjectType |= (FindSubString(sType, "D")==-1)?0:OBJECT_TYPE_DOOR;
        iObjectType |= (FindSubString(sType, "A")==-1)?0:OBJECT_TYPE_AREA_OF_EFFECT;
        iObjectType |= (FindSubString(sType, "W")==-1)?0:OBJECT_TYPE_WAYPOINT;
        iObjectType |= (FindSubString(sType, "P")==-1)?0:OBJECT_TYPE_PLACEABLE;
        iObjectType |= (FindSubString(sType, "S")==-1)?0:OBJECT_TYPE_STORE;
        iObjectType |= (FindSubString(sType, "E")==-1)?0:OBJECT_TYPE_ENCOUNTER;
		iObjectType |= (FindSubString(sType, "V")==-1)?0:OBJECT_TYPE_PLACED_EFFECT;
		iObjectType |= (FindSubString(sType, "L")==-1)?0:OBJECT_TYPE_LIGHT;
    }

    return iObjectType;
}

// return the duration type
// not case sensitive
// 	I = INSTANT
//  P = PERMANENT
//  T = TEMPORARY
int GetDurationType(string sType)
{
    sType = GetStringUpperCase(sType);
    int iType = DURATION_TYPE_INSTANT;

    if (FindSubString(sType, "P"))
        iType = DURATION_TYPE_PERMANENT;

    if (FindSubString(sType, "T"))
        iType = DURATION_TYPE_TEMPORARY;

	return (iType);
}


// returns the standard faction or -1 if not found
int GetStandardFaction(string sFactionName)
{
	int iFaction = -1;
	if (IsParameterConstant(sFactionName))
	{	
		string sTargetFaction = GetStringUpperCase(sFactionName);
	
		if (sTargetFaction == PARAM_COMMONER)
			iFaction = STANDARD_FACTION_COMMONER;
		else if (sTargetFaction == PARAM_DEFENDER)
			iFaction = STANDARD_FACTION_DEFENDER;
		else if (sTargetFaction == PARAM_HOSTILE)
			iFaction = STANDARD_FACTION_HOSTILE;
		else if (sTargetFaction == PARAM_MERCHANT)
			iFaction = STANDARD_FACTION_MERCHANT;
		
	}
	return (iFaction);
}


// check if this is a parameter constant - starts with TARGET_KEY
int IsParameterConstant(string sParameter)
{
	string sKey = GetStringLeft(sParameter, 1);
	return (TARGET_KEY == sKey);

}

// returns a sound object
object GetSoundObjectByTag(string sTarget)
{
	object oTarget = GetTarget(sTarget);

	if (GetIsObjectValid(oTarget) == FALSE)
		ErrorMessage("GetSoundObjetByTag: " + sTarget + " not found!");
	else 
	{	
		int iType = GetObjectType(oTarget);
		if (iType != OBJECT_TYPE_ALL) // sound object don't have their own special type...
			ErrorMessage("GetSoundObjetByTag: " + sTarget + " is wrong type: " + IntToString(iType) + " - attempting to use anyway.");
	}
	return oTarget;
}


//-------------------------------------------------------------
// Name-Value Pair Lists
//-------------------------------------------------------------

// splits apart a Name-Value Pair string into it's component parts.
struct rNameValueStringPair GetNameValuePairStruct (string sNameValuePair, string sDelimiter = "=")
{
	struct rNameValueStringPair oNameValuePair;
	int iDelimPostion = FindSubString(sNameValuePair, sDelimiter);
	if (iDelimPostion != -1)
	{
		int iStringLength = GetStringLength(sNameValuePair);
		oNameValuePair.sName = GetStringLeft(sNameValuePair, iDelimPostion);
		oNameValuePair.sValue = GetStringRight(sNameValuePair, iStringLength - iDelimPostion - GetStringLength(sDelimiter));
	}
	else
	{
		oNameValuePair.sName = sNameValuePair;
		oNameValuePair.sValue = "";
	}
	
	return (oNameValuePair);
}


// return Value string for name/value pair, empty string if not found.
// NOTE: GetStringParam() will search for the 'x0_i0_stringlib' default delimiter ","
string GetNVPValue(string sNVPList, string sName, string sDelim="=")
{
	struct rNameValueStringPair oNameValuePair;
	int bFound = FALSE;
	int i = 0;
	string sRet = "";
	
	string sNameValuePair = GetStringParam(sNVPList, i);
	while (sNameValuePair != "" && !bFound)
	{
		oNameValuePair = GetNameValuePairStruct(sNameValuePair, sDelim);
		if (oNameValuePair.sName == sName)
		{
			bFound = TRUE;
			sRet = oNameValuePair.sValue;
			break;
		}			
		i++;
		sNameValuePair = GetStringParam(sNVPList, i);
	}
	
	return sRet;
}

// Remove Name-Value pair from Name-Value pair list
// NOTE: RemoveListElement() will search for the 'x0_i0_stringlib' default delimiter ","
string RemoveNVP(string sNVPList, string sName, string sDelim="=")
{
	string sValue = GetNVPValue(sNVPList, sName);
	string sNameValuePair = sName + sDelim + sValue;
	sNVPList = RemoveListElement(sNVPList, sNameValuePair);
	return(sNVPList);
}

// Set a Name-Value pair in a list of Name-Value Pairs
// NOTE: AppendToList() will insert the 'x0_i0_stringlib' default delimiter ","
string AppendUniqueToNVP(string sNVPList, string sName, string sValue, string sDelim="=")
{
	string sNameValuePair = sName + sDelim + sValue;

	// Remove old value if it exists.
	sNVPList = RemoveNVP(sNVPList, sName, sDelim); // fix_Aqvilinus
	// append new value
	sNVPList = AppendToList(sNVPList, sNameValuePair);

	return (sNVPList);
}