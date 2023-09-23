// ga_global_int
/*
	This script changes a global int variable's value

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
*/
// FAB 10/7
// BMA 4/15/05 added set operator, "=n"
// ChazM 5/4/05 mod

#include "ginc_var_ops"


void main(string sVariable, string sChange )
{

	int nOldValue = GetGlobalInt(sVariable);
	int nNewValue = CalcNewIntValue(nOldValue, sChange);

	// Debug Message - comment or take care of in final
	//SendMessageToPC( oPC, sTagOver + "'s variable " + sScript + " is now set to " + IntToString(nChange) );

	SetGlobalInt(sVariable, nNewValue);
}
