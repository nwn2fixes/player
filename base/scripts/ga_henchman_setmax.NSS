//::///////////////////////////////////////////////////////////////////////////
//::
//::	ga_henchman_setmax
//::
//::	Sets the maximum number of allowed Henchmen (henchmen are not companions).
//::
//::		Parameters:
//::			sChange - Acts just like ga_local_int, give it the string of your change.
//::					= VALUE	  (EFFECT)
//::					  "5"     (Set to 5)
//::					  "=-2"   (Set to -2)
//::					  "+3"    (Add 3)
//::					  "+"     (Add 1)
//::					  "++"    (Add 1)
//::					  "-4"    (Subtract 4)
//::					  "-"     (Subtract 1)
//::					  "--"    (Subtract 1)
//::
//::///////////////////////////////////////////////////////////////////////////
// DBR 1/28/06  - I so ripped this off of ga_local_int. Thank you FAB.

#include "ginc_var_ops"


void main(string sChange)
{
	int nOldValue = GetMaxHenchmen();
	int nNewValue = CalcNewIntValue(nOldValue, sChange);

	SetMaxHenchmen(nNewValue);
}
