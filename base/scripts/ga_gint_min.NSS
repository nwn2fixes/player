// ga_gint_min
/*
	This script changes a global int variable's value (like ga_global_int)
	but also allows for a Minimum Value and Special Rules to apply.

	Parameters:
	 string sVariable	= Name of variable to change
	 string sChange		= VALUE (EFFECT)
						  "5"   (Set to 5)
						  "=-2" (Set to -2)
						  "+3"  (Add 3)
						  "+"   (Add 1)
						  "++"  (Add 1)
						  "-4"  (Subtract 4)
						  "-"   (Subtract 1)
						  "--"  (Subtract 1)
	 int iMin			= Minimum Value
	 int iRule			= Special case rule for when both the original value and the new calculated value
						  are below the minimum:
							0 - make no change to the original value
							1 - set to minimum value
							2 - use larget of either the original or the changed value
*/
// ChazM 8/26/05

#include "ginc_var_ops"


void main(string sVariable, string sChange, int iMin, int iRule)
{
	int nOldValue = GetGlobalInt(sVariable);
	int nNewValue = CalcNewIntValue(nOldValue, sChange);

	if (nNewValue < iMin)
	{
		if (nOldValue < iMin)
		{
			if (iRule == 0)
				return; // stick w/ old value
			if (iRule == 1)
				nNewValue = iMin;
			if (iRule == 2)
				if (nOldValue > nNewValue)
					return; // stick w/ old value, else just use new value
		}
		else
			nNewValue = iMin;
	}

	// Debug Message - comment or take care of in final
	//SendMessageToPC( oPC, sTagOver + "'s variable " + sScript + " is now set to " + IntToString(nChange) );

	SetGlobalInt(sVariable, nNewValue);
}
