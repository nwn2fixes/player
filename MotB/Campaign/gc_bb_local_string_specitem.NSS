// gc_bb_local_string_specitem(string sVariable, string sCheck, string sGlobalVarName)
// by B. Bellina, July 2008
// Required for the special items: Dagger of Chaos and Rod of Lordly Might

// based on gc_local_string
// this script determines the special item actor by checking a global
// variable and tests local string variables against the actor

/* 
   This script checks a local string variable's value.

   Parameters:
     string sVariable  = This is the name of the variable checked.
     string sCheck     = This is the string to compare equality against.
*/

#include "ginc_param_const"

int StartingConditional(string sVariable, string sCheck, string sGlobalVarName)
{
	string sActor = GetGlobalString(sGlobalVarName);
	object oTarget = GetTarget(sActor);
	if (!GetIsObjectValid(oTarget))
		oTarget =(GetPCSpeaker()==OBJECT_INVALID?OBJECT_SELF:GetPCSpeaker());
	string sValue = GetLocalString(oTarget, sVariable);

	PrintString("gc_bb_local_string_specitem: Object '" + GetName(oTarget) + "' variable '" + sVariable + "' = '" + sValue + "' compare to '" + sCheck + "'");
    if (sValue == sCheck)
    {
    	return TRUE;
    }
    else
    {
    	return FALSE;
    }
}