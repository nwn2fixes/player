// ginc_var_ops
//
// include file for common functionality with g*_global_* and g*_local_* scripts
// ChazM 4/12/05 (mod)
// ChazM 5/4/05 added CalcNewIntValue()
// ChazM 6/15/05 modified CompareInts() to be able to reference a companion's influence
// BMA-OEI 1/13/06 modified CheckVariableFloat for EPSILON check
// ChazM 8/24/06 CompareInts() no longer able to reference a companion's influence to remove dependency on kinc_companion

#include "ginc_companion"
#include "ginc_math"

// Prototypes
int CheckVariableFloat(float fValue, string sOperator, float fCheck);
int CheckVariableInt(int nValue, string sOperator, int nCheck);
int CompareInts(int nValue, string sCheck);

int CalcNewIntValue(int nOldValue, string sChange, int bDefaultIsDelta = FALSE);


// CheckVariableFloat()
//
// Evaluates the expression [fValue] [sOperator] [fCheck], as in, say, 5 < 3
// and returns the result -- true or false
// sOperator is =, >, <, or ! (for not equals)
int CheckVariableFloat(float fValue, string sOperator, float fCheck)
{
	//GREATER THAN
	if ( sOperator == ">")
	{
		return (fValue > fCheck);
	}

	//LESS THAN
	if ( sOperator == "<")
	{
		return (fValue < fCheck);
	}

	//NOT EQUAL TO
	if ( sOperator == "!")
	{
		//return (fValue != fCheck);
		fValue = fabs(fValue - fCheck);
		return (fValue > EPSILON);
	}

	//EQUAL TO
	if( sOperator == "=")
	{
		//return (fValue == fCheck);
		fValue = fabs(fValue - fCheck);
		return (fValue < EPSILON);
	}

	return FALSE;
}

// CheckVariableInt()
//
// Evaluates the expression [nValue] [sOperator] [nCheck], as in, say, 5 < 3
// and returns the result -- true or false
// sOperator is =, >, <, or ! (for not equals)
int CheckVariableInt(int nValue, string sOperator, int nCheck)
{
	//GREATER THAN
	if ( sOperator == ">")
	{
		return (nValue > nCheck);
	}

	//LESS THAN
	if ( sOperator == "<")
	{
		return (nValue < nCheck);
	}

	//NOT EQUAL TO
	if ( sOperator == "!")
	{
		return (nValue != nCheck);
	}

	//EQUAL TO
	if( sOperator == "=")
	{
		return (nValue == nCheck);
	}

	return FALSE;
}


// compare integer values
//	nValue - value to compare
//	sCheck - string containing optional comparison operator and value
int CompareInts(int nValue, string sCheck)
{
	int nCheck;
	string sValue;
	string sOperator = GetStringLeft(sCheck, 1);

	//first we consider cases where the user specified an operator as the first character
	//of sCheck
	if(sOperator == ">" || sOperator == "<" || sOperator == "=" || sOperator == "!")
	{
		sValue = GetStringRight( sCheck,GetStringLength(sCheck)-1 );
	}
	//default case -- no operator specified so use whole string as our check value
	else
	{
		sValue = sCheck;
		sOperator = "=";
	}

	// sValue is now sCheck minus any operator on the front end
	// check if sValue has a tag
//	string sValueTag = GetStringLeft(sValue, 1);
//
//	if(sValueTag == "C" || sValueTag == "c")
//	{
//		int nCompanion = StringToInt(GetStringRight( sValue,GetStringLength(sValue)-1 ));
//		nCheck = GetGlobalInt(GetCompInfluenceGlobVar(nCompanion));
//	}
//	else
//	{
		nCheck = StringToInt(sValue);
//	}

	return (CheckVariableInt(nValue, sOperator, nCheck));
}


struct ChangeComponents
{
	string sOperator;
	string sValue;
};

// returns the operator and value from sChange.
// bDefaultIsDelta affect whether operator is "+" or "=" when an operator is not provided
struct ChangeComponents GetChangeComponents(string sChange, int bDefaultIsDelta)
{
	struct ChangeComponents xChange; // return value

	string sOperator = GetStringLeft(sChange, 1);

	if ((sOperator == "=") || (sOperator == "+") || (sOperator == "-")) {
		sChange = GetStringRight(sChange, GetStringLength(sChange) - 1);

		// handle ++, --, +, -
		string sChar2 = GetStringLeft(sChange, 1);
		if ((sChar2 == "+") || (sChar2 == "-") || (sChar2 == ""))
			sChange = "1";
	}
	else { // doesn't start with operator
		if (bDefaultIsDelta)
			sOperator = "+";
		else
			sOperator = "=";
	}

	xChange.sOperator = sOperator;
	xChange.sValue = sChange;


	return (xChange);
}


// applies sChange to nOldValue and returns the new value.
// nOldValue - previous value
// sChange - change string such as "5", "-2", "=3", etc.
// bDefaultIsDelta - TRUE = treat integer as Delta, FALSE = treat integer as value to set.
int CalcNewIntValue(int nOldValue, string sChange, int bDefaultIsDelta = FALSE)
{
	struct ChangeComponents xChange = GetChangeComponents(sChange, bDefaultIsDelta);

	int nValue = StringToInt(xChange.sValue);
	int nNewValue;

	if (xChange.sOperator == "+")
		nNewValue = nOldValue + nValue;
	else if (xChange.sOperator == "-")
		nNewValue = nOldValue - nValue;
	else { // if not + or - then just set the value
		nNewValue = nValue;
	}

	return(nNewValue);
}

/*
// applies sChange to nOldValue and returns the new value.
// nOldValue - previous value
// sChange - change string such as "5", "-2", "=3", etc.
// bDefaultIsDelta - TRUE = treat integer as Delta, FALSE = treat integer as value to set.
int OldCalcNewIntValue(int nOldValue, string sChange, int bDefaultIsDelta)
{
	int nChange;
	if (GetStringLeft(sChange, 1) == "=")
	{
	sChange = GetStringRight(sChange, GetStringLength(sChange) - 1);
	nChange = StringToInt(sChange);
	}
	else if (GetStringLeft(sChange, 1) == "+")
	{
		// If sChange is just "+" then default to increment by 1
		if (GetStringLength(sChange) == 1)
		{
			nChange = nOldValue + 1;
		}
		else	// This means there's more than just "+"
		{
			if (GetSubString(sChange, 1, 1) == "+") 	// "++" condition
			{
				nChange = nOldValue + 1;
			}
			else
			{
				sChange = GetStringRight(sChange, GetStringLength(sChange) - 1);
				nChange = nOldValue + StringToInt(sChange);
			}
		}
	}
	else if (GetStringLeft(sChange, 1) == "-")
	{
		// If sChange is just "-" then default to increment by 1
		if (GetStringLength(sChange) == 1)
		{
			nChange = nOldValue - 1;
		}
		else	// This means there's more than just "-"
		{
			if (GetSubString(sChange, 1, 1) == "-") 	// "--" condition
			{
				nChange = nOldValue - 1;
			}
			else
			{
				sChange = GetStringRight(sChange, GetStringLength(sChange) - 1);
				nChange = nOldValue - StringToInt(sChange);
			}
		}
	}
	else
	{
		if (sChange == "")
		nChange = nOldValue + 1;
	if (bDefaultIsDelta) {
				nChange = nOldValue + StringToInt(sChange);
	} else {
			nChange = StringToInt(sChange);
	}
	}
	return(nChange);
}
*/
